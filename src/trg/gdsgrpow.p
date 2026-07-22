block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись gds-grp-obj

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

TRIGGER PROCEDURE FOR WRITE OF ub.gds-grp-obj  OLD oldgds-grp-obj.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись gds-grp-obj".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4'
                                    ,ub.gds-grp-obj.node-code
                                    ,ub.gds-grp-obj.host-code
                                    ,ub.gds-grp-obj.obj-type
                                    ,ub.gds-grp-obj.obj-code
                                    )" }

{ cmp/trg-def.i  }
{ gbl/cur-time.i }
{ trg/gds-grph.i gds-grp-obj-trig oldgds-grp-obj ub.gds-grp-obj }

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:


  run str/callnews.p
    ( input "gds-grp-obj"
     ,input (buffer ub.gds-grp-obj:handle)
    ) .

  if not g#news then do:
    run gds-grph_write-gds-grp-obj-trigger  in this-procedure (
                                                                input new(ub.gds-grp-obj)
                                                               ,input "":U /*p-source-type*/
                                                               ,input "":U /*p-source-ref*/
                                                               ,input (if new(ub.gds-grp-obj)
                                                                       then integer({&Hn-create})
                                                                       else integer({&hn-update})
                                                                      )
                                                              ).
  end.
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_gds-grp-obj}
        , input ( buffer ub.gds-grp-obj:handle )
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