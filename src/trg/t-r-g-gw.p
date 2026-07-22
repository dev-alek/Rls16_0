block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись для таблицы налоги на группу товаров

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

TRIGGER PROCEDURE FOR WRITE OF ub.tax-rate-gds-grp OLD old-tax-rate-gds-grp.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись для таблицы налоги на группу товаров".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5'
                                    ,ub.tax-rate-gds-grp.node-code
                                    ,ub.tax-rate-gds-grp.tax-code
                                    ,ub.tax-rate-gds-grp.host-code
                                    ,ub.tax-rate-gds-grp.obj-type
                                    ,ub.tax-rate-gds-grp.obj-code
                                    )" }

{ cmp/trg-def.i  }
{ gbl/cur-time.i }
{ trg/gds-grph.i tax-rate-gds-grp-trig old-tax-rate-gds-grp ub.tax-rate-gds-grp }

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:


  run str/callnews.p
    (input "tax-rate-gds-grp"
    ,input (buffer ub.tax-rate-gds-grp:handle)
    ).

  if not g#news then do:
    run gds-grph_write-tax-rate-gds-grp-trigger  in this-procedure (
                                                                input new(ub.tax-rate-gds-grp)
                                                               ,input "":U /*p-source-type*/
                                                               ,input "":U /*p-source-ref*/
                                                               ,input (if new(ub.tax-rate-gds-grp)
                                                                       then integer({&Hn-create})
                                                                       else integer({&hn-update})
                                                                      )
                                                              ).
  end.
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_tax-rate-gds-grp}
        , input ( buffer ub.tax-rate-gds-grp:handle )
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