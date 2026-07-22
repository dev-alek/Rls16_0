block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись c-point-io

Автор: Чернова Светлана Александровна
Дата создания: 04/26/06
Author: Svetlana Chernova
Creation date: 04/26/06

*/

TRIGGER PROCEDURE FOR WRITE OF ub.c-point-io .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись c-point-io".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4'~
                           ,ub.c-point-io.db-num~
                           , ub.c-point-io.point-code
                           , ub.c-point-io.corr-user-db-num
                           , ub.c-point-io.chip-num) " }
{ cmp/trg-def.i  }

main-block:
do on error undo main-block, return error return-value :
  run str/callnews.p ( input {&table_c-point-io}, input (buffer ub.c-point-io:handle) ) .
  if g#oxml = yes
  then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_c-point-io}
        , input ( buffer ub.c-point-io:handle )
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