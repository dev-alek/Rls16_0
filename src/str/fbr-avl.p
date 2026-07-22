block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: fbr-avl.p $
$Archive: str/fbr-avl.p $

расчет допустимого количества при производстве

Автор: Белоусов Илья Александрович
Дата создания: 04/12/06
Author: Ilia Belousov
Creation date: 04/12/06

Input:

Output:

   расчет производится с учетом свободного количества каждого ингредиента на объекте,
   а также суммарного количества данного ингредиента по всем рецептам, если он в свою очередь
   производился в данном документе

   нет никакой гарантии, что при резервировании потом любой из ингредиентов (неважно, нужен он для одного
   или нескольких рецептов) будет доступен, поскольку его количество может измениться, он после расчета
   свободного количества никак не блокируетс

*/

define input  parameter p-fbr-doc-doc-code  as character no-undo.           /* номер документа */
define input  parameter rcp-code            as character no-undo.           /* номер рецепта */
define input  parameter t-type              like fbr-line.trn-type no-undo. /* чтоб отличить комплектацию от разукомплектации */
define output parameter p-avail-qnty          as decimal no-undo.             /* допустимое количество комплектного товара */

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: fbr-avl.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/fbr-avl.p $":U .
define variable vss-description as character no-undo init "расчет допустимого количества при производстве".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ trg/partslib.i }
{ str/fbrrest.i  }

define variable dec-trunc           as integer no-undo.             /* допустимое количество дробных разрядов */
define variable ingr-qnty         like fbr-line.fact-qnty no-undo.  /* количество ингредиента, производимое по
                                                               всем рецептам в этом же док-те + свободное */
define variable par-type     as char no-undo.                       /* тип параметра конфигурации */
def buffer ingr-goods for goods.

find first fbr-doc no-lock
     where fbr-doc.doc-code = p-fbr-doc-doc-code
.
find first recipe no-lock
     where recipe.recipe-code = rcp-code
.
find first goods no-lock
     where goods.artic     = recipe.artic
       and goods.prod-type = recipe.prod-type
       and goods.prod-code = recipe.prod-code
.
find first units no-lock
     where units.unit-name = goods.unit-base
.
/* допустимое количество дробных разрядов */
if lookup ({&weight}, units.type) > 0
or lookup ({&divisional}, units.type) > 0
then do:
    assign
        dec-trunc = 3
    .
end.
else do:
    assign
        dec-trunc = 0
    .
end.

if recipe.recipe-type = {&dressing}
or recipe.recipe-type = {&gathering}
and t-type = {&write-off}
then do:
    run fbrrest-get-free-qnty in this-procedure (
              input fbr-doc.obj-type
            , input fbr-doc.obj-code
            , input goods.gds-code
            , input no
            , output p-avail-qnty
    ).
end.
else do:
  /* считаем максимально доступное количество, которое может быть произведено */
  for each recipe-gds
     where recipe-gds.recipe-code = rcp-code
    , each ingr-goods no-lock
     where ingr-goods.artic = recipe-gds.artic
       and ingr-goods.prod-type = recipe-gds.prod-type
       and ingr-goods.prod-code = recipe-gds.prod-code
       and ingr-goods.gds-type <> {&gds-office}
  :
    /* находим доступный остаток ингредиента с учетом свободного */
    run fbrrest-get-free-qnty in this-procedure (
          input fbr-doc.obj-type
        , input fbr-doc.obj-code
        , input ingr-goods.gds-code
        , input no
        , output ingr-qnty
    ) .
    accumulate
      /* считаем общее количество строк в рецепте */
      recipe-gds.artic (count)
      /* считаем доступное количество комплектного товара с учетом произведенных ингредиентов */
      /* просто проверять на ? нельзя, min не выдает правильного ? */
      trunc (ingr-qnty / recipe-gds.brutto-qnty * recipe.qnty, dec-trunc) (min)
      /* для альтернативы */
      trunc (ingr-qnty * recipe-gds.brutto-qnty, dec-trunc) (total)
      .
  end.
  if recipe.recipe-type = {&alternative} then
    p-avail-qnty = (accum total trunc (ingr-qnty * recipe-gds.brutto-qnty, dec-trunc)).
  else
    if /* отрицательное значение допустимо */
       (accum min trunc (ingr-qnty / recipe-gds.brutto-qnty * recipe.qnty, dec-trunc)) < 0 or
       /* нет свободных количеств ни по одному ингредиенту */
       (accum count recipe-gds.artic) = 0 or
       /* по одному из ингредиентов нет свободного */
       (accum count recipe-gds.artic) = 0 then
      p-avail-qnty = 0.
    else
      p-avail-qnty = (accum min trunc (ingr-qnty / recipe-gds.brutto-qnty * recipe.qnty, dec-trunc)).
end.