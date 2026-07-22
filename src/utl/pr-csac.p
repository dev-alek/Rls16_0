block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: pr-csac.p $
$Archive: utl/pr-csac.p $



Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06

Creation date: 02/19/04 6:06

*/

/* chk_prc.p  - вызвать перед for each  */

{ cmp/trg-def.i  }
{ str/pr-lattr.i }
{ gbl/waitfram.i }

define variable var-pr-r-b as character no-undo .
{ gbl/curr-r-b.i  var-pr-r-b }

define buffer buf_price-doc  for price-doc  .
define buffer buf_price-list for price-list .
define variable col-part as integer no-undo .
define variable temp1 as integer init 10 no-undo .
define variable v-all as integer init 0 no-undo .

run waitfram-show in this-procedure ("Ждите...").
for each buf_price-doc no-lock
    where buf_price-doc.status_ = {&act-overvalue}
    on error undo, return error :
        for each buf_price-list no-lock
            where    buf_price-list.doc-num = buf_price-doc.doc-num
            on error undo, return error :
            v-all = v-all + 1.
        end. /* for each */
end. /* for each */


for each buf_price-doc no-lock
    where buf_price-doc.status_ = {&act-overvalue}
    on error undo, return error :

    for each buf_price-list no-lock
        where    buf_price-list.doc-num = buf_price-doc.doc-num
        on error undo, return error :

        run proc-cost-price-fact.
    end. /* for each */
end. /* for each */
run waitfram-hide in this-procedure .
message "Процесс завершен!"  view-as alert-box .


procedure proc-cost-price-fact :
 do
 on error undo, return error return-value
 :
/* запись средней учетной цены на объекте на момент закрытия переоценки до АКТ */

define variable v-total-avrg-base  as decimal no-undo .
define variable v-total-avrg-rubl  as decimal no-undo .
define variable v-total-avrg-qnty  as decimal no-undo .
define buffer buf_parts      for parts.
define buffer buf_price-list for price-list.

define variable p-price-base as decimal no-undo .
define variable p-price-rubl as decimal no-undo .

col-part = col-part + 1.
if ( col-part  modulo temp1 = 0 ) and ( col-part >= temp1 ) then run waitfram-show ( " Всего строк: " + string( v-all ) + " Обработано строк price-list : " + string( col-part )) .
run trg/chk_prc.p (buf_price-doc.doc-num) .
for each buf_price-list no-lock
    where buf_price-list.doc-num = buf_price-doc.doc-num
    on error undo, return error :

      for each buf_parts no-lock
        where buf_parts.obj-type  = buf_price-doc.obj-type
          and buf_parts.obj-code   = buf_price-doc.obj-code
          and buf_parts.artic      = buf_price-list.artic
          and buf_parts.prod-type  = buf_price-list.prod-type
          and buf_parts.prod-code  = buf_price-list.prod-code
          and ( buf_parts.out-code  = buf_price-doc.doc-num
              /* or
              buf_parts.out-code  = {&free-code} */
              )
      on error undo, return error
      :
      /*
       message buf_parts.artic skip
               buf_parts.price-base
               buf_parts.qnty
               buf_parts.out-code
               buf_parts.in-code
               buf_parts.status_
               .
        */
        assign
          v-total-avrg-base = v-total-avrg-base
                            + (buf_parts.price-base * buf_parts.qnty)
          v-total-avrg-rubl = v-total-avrg-rubl
                            + (buf_parts.price-rubl * buf_parts.qnty)
          v-total-avrg-qnty = v-total-avrg-qnty
                            + buf_parts.qnty
        .
      end.
      if v-total-avrg-qnty > 0 then do:
        assign
          p-price-base = ( v-total-avrg-base / v-total-avrg-qnty )
          p-price-rubl = ( v-total-avrg-rubl / v-total-avrg-qnty )
        .
      end.
      else do:
        assign
          p-price-base = ?
          p-price-rubl = ?
        .
      end.

 define variable p-attr-value as character no-undo .
 if var-pr-r-b = "rubl"  then
    p-attr-value = string ( p-price-rubl ) .
    else
    p-attr-value = string ( p-price-base ) .

  run create-price-list-attr (
    {&cost-price-fact}    ,
    p-attr-value          ,
    buf_price-list.b-code ,
    buf_price-doc.doc-num ,
    ""
    ) .

end. /* for each */

 end. /* do */
end procedure. /* proc-cost-price-fact */