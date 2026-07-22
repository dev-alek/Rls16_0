block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление градуировочной таблицы по резервуару на объекте

Автор: Уханов Дмитрий Юрьевич
Дата создания: 01/20/06
Author: Dmitry Ukhanov
Creation date: 01/20/06

*/

trigger procedure for delete of ub.pl-level.

define variable vss-revision    as character no-undo initial "$Revision$":U.
define variable vss-author      as character no-undo initial "$Author$":U.
define variable vss-date        as character no-undo initial "$Date$":U.
define variable vss-workfile    as character no-undo initial "$Workfile$":U.
define variable vss-archive     as character no-undo initial "$Archive$":U.
define variable vss-description as character no-undo initial "Триггер на удаление градуировочной таблицы по резервуару на объекте":U.

{ cmp/vssrevis.i "substitute('&1|&2|&3',ub.pl-level.obj-type,ub.pl-level.obj-code,ub.pl-level.pl-code)" }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }

define variable j#db-num like ub.db.db-num no-undo.
define variable str1     as   character    no-undo.
define variable jj       as   integer      no-undo.
define variable t#date   as   date         no-undo.
define variable j#time   as   integer      no-undo.

define buffer buf_c-pl-level for ub.c-pl-level.

Main-Block:
do on error   undo Main-Block, return error return-value
   on end-key undo Main-Block, return error return-value
   on stop    undo Main-Block, return error return-value :
  { gbl/objdbnum.i ub.pl-level.obj-type ub.pl-level.obj-code j#db-num }
  if g#db-num <> j#db-num and g#news <> yes then do:
    message vss-workfile skip vss-date skip vss-revision skip( 1 ) vss-description skip( 1 )
            "Нельзя удалять запись градуировочной таблицы на объекте в БД, отличной от БД объекта." skip
            "Номер текущей БД:" g#db-num skip
            "Номер БД объекта:" j#db-num skip( 1 )
    view-as alert-box error.
    undo Main-Block, return error.
  end.

  run nws/cmd-del.p ( input "pl-level":U, input ( buffer ub.pl-level :handle ), input "":U ) no-error.
  if error-status :error then do:
    assign str1 = {&new-line}.
    do jj = 1 to error-status :num-messages :
      assign str1 = str1 + {&new-line} + error-status :get-message ( jj ).
    end.
    undo, return error substitute( "&1. Ошибка при отправке в новости команды на удаление записи. &2&3&4",
                                   vss-workfile, {&new-line}, return-value, str1 ).
  end.

  if g#news <> yes then do:
    run cur-time in this-procedure( output t#date, output j#time ).
    create buf_c-pl-level.
    buffer-copy    ub.pl-level
             to buf_c-pl-level
         assign buf_c-pl-level.chip-num         = next-value( s-corr-chip, {&db-name_schema} )
                buf_c-pl-level.corr-time        = j#time
                buf_c-pl-level.corr-user-db-num = g#db-num
                buf_c-pl-level.corr-user-name   = g#userid
                buf_c-pl-level.corr-date        = t#date
                buf_c-pl-level.action           = integer( {&hn-delete} ).
  end. /* if not g#news */
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_delete}
        , input {&table_pl-level}
        , input ( buffer ub.pl-level:handle )
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
end. /* Main-Block */
