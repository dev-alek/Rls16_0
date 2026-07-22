block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись c-point-point-rel

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/29/09
Author: Bakhtadze Natalya
Creation date: 09/29/09

*/

TRIGGER PROCEDURE FOR WRITE OF ub.c-point-point-rel.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись c-point-point-rel".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5|&6|&7|&8'~
                             , ub.c-point-point-rel.from-db-num ~
                             , ub.c-point-point-rel.from-point-code ~
                             , ub.c-point-point-rel.to-db-num ~
                             , ub.c-point-point-rel.to-point-code ~
                             , ub.c-point-point-rel.deliv-type-code ~
                             , ub.c-point-point-rel.cond-keep-code ~
                             , ub.c-point-point-rel.corr-user-db-num ~
                             , ub.c-point-point-rel.chip-num ~
                              ) " }

{ cmp/trg-def.i  }
main-block:
do on error undo main-block, return error return-value :
  run str/callnews.p ( input {&table_c-point-io}
                     , input (buffer ub.c-point-io:handle) ) .
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