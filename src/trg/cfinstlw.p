block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись истории строки банковской выписки

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/28/05
Author: Bakhtadze Natalya
Creation date: 07/28/05

*/


TRIGGER PROCEDURE FOR WRITE OF ub.c-fin-statement-line.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись истории строки банковской выписки".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5'
             , ub.c-fin-statement-line.host-code
             , ub.c-fin-statement-line.sttm-code
             , ub.c-fin-statement-line.line-num
             , ub.c-fin-statement-line.corr-user-db-num
             , ub.c-fin-statement-line.chip-num) " }
{ cmp/trg-def.i }

define buffer buf_fin-statement for ub.fin-statement.
define buffer buf_sysconf for ub.sysconf.

main-block :
do transaction
on error undo main-block, return error return-value
:
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_c-fin-statement-line}
        , input ( buffer ub.c-fin-statement-line:handle )
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