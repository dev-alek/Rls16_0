block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Тригер на запись истории заказов

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06

Creation date: 06/11/04 1:06

*/
TRIGGER PROCEDURE FOR WRITE OF c-ord-doc.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Тригер на запись истории заказов".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }


main-block :
do transaction
on error undo main-block, return error return-value
:
define variable v-db-num as integer   no-undo .
define variable v-db-num-cli as integer   no-undo .
 if  g#news  = false   then do:

   v-db-num-cli = g#db-num  .
   v-db-num = g#db-num      .

    { gbl/objdbnum.i
    ub.c-ord-doc.obj-type
    ub.c-ord-doc.obj-code
    v-db-num
    no-error }
    if v-db-num = ? then v-db-num = g#db-num .

    { gbl/objdbnum.i
    ub.c-ord-doc.cli-type
    ub.c-ord-doc.cli-code
    v-db-num-cli
    no-error }
    if v-db-num-cli = ? then v-db-num-cli = g#db-num .
    if not (v-db-num-cli = g#db-num and v-db-num = g#db-num ) then do:
        run str/callnews.p
          (input "c-ord-doc"
          ,input (buffer ub.c-ord-doc:handle)
          ) no-error .
        if error-status :error then do:
          message
            vss-workfile vss-revision vss-description skip
            "Невозможно маршрутизировать c-ord-doc для отправки в новости" skip
            "Заказ" ub.c-ord-doc.doc-code skip
            "chip-num" ub.c-ord-doc.chip-num skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error .
        end.
    end.
  end.
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_c-ord-doc}
        , input ( buffer ub.c-ord-doc:handle )
    ) no-error.
    if error-status :error
    then do:
        undo, return error substitute( "&2&1Ошибка при отправке записи в систему OpenXML&1&3&1&4"
                             , {&new-line}
                             , vss-workfile
                             , return-value
                             , error-status :get-message ( 1 ) ).
    end.
    end.
end.