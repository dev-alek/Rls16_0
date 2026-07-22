block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись истории градуировочной таблицы

Автор: Уханов Дмитрий Юрьевич
Дата создания: 01/20/06
Author: Dmitry Ukhanov
Creation date: 01/20/06

*/

trigger procedure for write of ub.c-pl-level new buffer buf_new old buffer buf_old.

define variable vss-revision    as character no-undo initial "$Revision$":U.
define variable vss-author      as character no-undo initial "$Author$":U.
define variable vss-date        as character no-undo initial "$Date$":U.
define variable vss-workfile    as character no-undo initial "$Workfile$":U.
define variable vss-archive     as character no-undo initial "$Archive$":U.
define variable vss-description as character no-undo initial "Триггер на запись истории градуировочной таблицы":U.

{ cmp/vssrevis.i "substitute('&1|&2|&3|&4',buf_new.obj-type,buf_new.obj-code,buf_new.pl-code,buf_new.chip-num)" }
{ cmp/trg-def.i  }

Main-Block:
do transaction on error   undo Main-Block, return error return-value
               on end-key undo Main-Block, return error return-value
               on stop    undo Main-Block, return error return-value :
  run str/callnews.p ( input "c-pl-level", input ( buffer buf_new :handle ) ).
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_c-pl-level}
        , input ( buffer ub.c-pl-level:handle )
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
end. /* Main-Block */
