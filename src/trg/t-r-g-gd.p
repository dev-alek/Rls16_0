block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление налога на группу товаров

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/30/06
Author: Bakhtadze Natalya
Creation date: 03/30/06

*/

TRIGGER PROCEDURE FOR DELETE OF ub.tax-rate-gds-grp.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление tax-rate-gds-grp".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4'
                                    ,ub.tax-rate-gds-grp.node-code
                                    ,ub.tax-rate-gds-grp.host-code
                                    ,ub.tax-rate-gds-grp.obj-type
                                    ,ub.tax-rate-gds-grp.obj-code
                                    )" }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }
{ trg/gds-grph.i }
define buffer buf_gds-grp for ub.gds-grp.


main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1) )
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  if not g#news then do:
    run nws/cmd-del.p
      ( input "tax-rate-gds-grp":U
      ,input (buffer ub.tax-rate-gds-grp:handle)
      ,input "":U
      ) no-error .
    if error-status :error then do:
      undo, return error substitute( "&1. Ошибка при отправке в новости команды на удаление записи. &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message ( error-status :num-messages ) ).
    end.
  end.

  if not g#news then do:
    find first buf_gds-grp no-lock where
              buf_gds-grp.node-code = ub.tax-rate-gds-grp.node-code no-error .
    if available buf_gds-grp then
    run gds-grph_write-tax-rate-gds-grp-proc   in this-procedure (
                                                      buffer ub.tax-rate-gds-grp
                                                      ,integer({&hn-delete})
                                                      ,"":U /*p-source-type*/
                                                      ,"":U
                                                      ).
  end.
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_delete}
        , input {&table_tax-rate-gds-grp}
        , input ( buffer ub.tax-rate-gds-grp:handle )
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