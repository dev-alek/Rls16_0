block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление истории документа

Автор: Чернова Светлана Александровна
Дата создания: 10/10/06
Author: Svetlana Chernova
Creation date: 10/10/06

create: Суслов Алексей Юрьевич


*/

TRIGGER PROCEDURE FOR DELETE OF ub.nws-doc-hist .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление истории документа".
{ cmp/vssrevis.i "substitute('&1|&2', ub.nws-doc-hist.db-num, ub.nws-doc-hist.ord-num) " }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }


/* позволяем удалять историю, если прошло более 31 дня */
main-block :
do transaction
on error undo main-block, return error
:
  define variable v-today as date      no-undo .
  define variable v-time  as integer   no-undo .

  run cur-time in this-procedure
    (output v-today
    ,output v-time
    ) .

  if ub.nws-doc-hist.sys-date > v-today - 30
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Историю по документам нельзя удалять в течение 30 дней" skip
      "Номер записи истории" ub.nws-doc-hist.db-num ub.nws-doc-hist.ord-num skip
      "Дата создания" ub.nws-doc-hist.sys-date skip
      "Сегодня" v-today skip
      view-as alert-box error .
    undo, return error return-value .
  end.
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_delete}
        , input {&table_nws-doc-hist}
        , input ( buffer ub.nws-doc-hist:handle )
    ) no-error.
    if error-status :error
    then do:
        undo, return error substitute( "&2&1Ошибка при отправке в систему OpenXML команды на удаление записи&1&3&1&4"
                             , {&new-line}
                             , vss-workfile
                             , return-value
                             , error-status :get-message ( 1 ) ).
    end.
    end.
end.