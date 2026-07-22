block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: exp-gds.p $
$Archive: utl/exp-gds.p $

Экспорт справочника товаров в формате импорта

Автор: Суслов Алексей Юрьевич
Дата создания: 09/19/05
Author: Alexey Suslov
Creation date: 09/19/05

*/

define input parameter parparentproc as widget-handle no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: exp-gds.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/exp-gds.p $":U .
define variable vss-description as character no-undo init "Экспорт справочника товаров в формате импорта".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ gbl/waitfram.i }
{ gbl/getcntxt.i def }


{ cmp/gds-list.i gds-list def "new shared" }

define variable f-name as character no-undo .
define variable v-ind  as integer   no-undo .

define variable v-num as integer no-undo .
run gbl/d-askw.w
  (input "Вопрос"
  ,input "Экспорт справочника товаров в формате импорта."
  ,input "|^"
  ,input "Все^confirm|Выборочно|Отказ"
  ,input "Экспорт всего справочника товаров|"
       + "Экспорт товаров по списку|"
       + ""
  ,input 2
  ,input 3
  ,output v-num
  ).


if  v-num <> 1
and v-num <> 2 then do:
  return . /* --->>>--- */
end.

define variable lok as logical no-undo .
system-dialog get-file f-name
  filters "Файл импорта товаров *.gim" "*.gim"
  ask-overwrite
  save-as
  use-filename
  update lok
  default-extension "gim".
if lok <> true then do:
  return . /* --->>>--- */
end.

output to value (f-name) .
output close .

run waitfram-show in this-procedure ("Экспорт товаров.").
{ gbl/getcntxt.i get }
case v-num :
  when 1 then do:
    for each ub.goods no-lock
      where ub.goods.stts = 0
    by ub.goods.prod-type
    by ub.goods.prod-code
    by ub.goods.grp-code
    by ub.goods.prt-root
    :
      run export-goods in this-procedure .
    end.
  end.
  when 2 then do:
    /* получаем список товаров */
    run str/gds-list.w (input parparentproc, input v-cntxt-host-code-obj, input v-cntxt-obj-type, input v-cntxt-obj-code) .

    /* производим вывод товаров по списку */
    for each gds-list
    :
      find first ub.goods no-lock
        where ub.goods.artic = gds-list.artic
          and ub.goods.prod-type = gds-list.prod-type
          and ub.goods.prod-code = gds-list.prod-code
        .
      run export-goods in this-procedure .
    end.
  end.
  otherwise do:
    message
      vss-workfile vss-revision vss-description skip
      "Неверное значение параметра выбора" skip
      "v-num" v-num skip
      view-as alert-box error .
    return error . /* --->>>--- */
  end.
end.

run waitfram-hide in this-procedure .


message
  "Экспорт товаров в файл " f-name " закончен." skip
  "Всего было выведено " v-ind "товаров." skip
  view-as alert-box information .

procedure export-goods :
  assign
    v-ind = v-ind + 1
  .
run waitfram-show in this-procedure (input "Экспорт товаров. Всего выведено " + string(v-ind) + "."
    + "Артикул " + string(ub.goods.artic)
    + " " + string(ub.goods.prod-type)
    + " " + string(ub.goods.prod-code)
    ).

/* input p-artic,*/
/* input p-name,*/
/* input p-engl-name,*/
/* input p-unit-base,*/
/* input p-VAT-code,*/
/* input p-SLT-code,*/

  output to value (f-name) append .
  put unformatted
    trim(replace(ub.goods.artic, ";", "")) + ";"
    + trim(replace(ub.goods.gds-name, ";", "")) + ";"
    + trim(replace(ub.goods.engl-name, ";", "")) + ";"
    + trim(replace(ub.goods.unit-base, ";", ""))
    + {&new-line} .

  output close .
end procedure. /* export-goods */