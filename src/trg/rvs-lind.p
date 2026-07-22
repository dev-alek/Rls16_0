block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление документа сверки

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/24/08
Author: Dmitry Ukhanov
Creation date: 03/24/08


*/

TRIGGER PROCEDURE FOR DELETE OF ub.rvs-line.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление документа сверки".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

    for each ub.rvs-line-attr
       where ub.rvs-line-attr.rvs-code = ub.rvs-line.rvs-code
         and ub.rvs-line-attr.obj-type = ub.rvs-line.obj-type
         and ub.rvs-line-attr.obj-code = ub.rvs-line.obj-code
         and ub.rvs-line-attr.pl-code  = ub.rvs-line.pl-code
         and ub.rvs-line-attr.gds-code = ub.rvs-line.gds-code
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    :
      delete ub.rvs-line-attr .
    end.
         
    for each ub.rvs-line-pump
      where ub.rvs-line-pump.rvs-code = ub.rvs-line.rvs-code
        and ub.rvs-line-pump.obj-type = ub.rvs-line.obj-type
        and ub.rvs-line-pump.obj-code = ub.rvs-line.obj-code
        and ub.rvs-line-pump.pl-code  = ub.rvs-line.pl-code
        and ub.rvs-line-pump.gds-code = ub.rvs-line.gds-code
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    :
      delete ub.rvs-line-pump.
    end.

    if g#oxml = yes then do:
      run str/calloxml.p (
            input {&nwsdochs_action_delete}
          , input {&table_rvs-line}
          , input ( buffer ub.rvs-line:handle )
      ) no-error.
      if error-status :error then do:
        undo, return error substitute( "&2&1Ошибка при отправке в систему OpenXML команды на удаление записи&1&3&1&4"
                                      , {&new-line}
                                      , vss-workfile
                                      , return-value
                                      , error-status :get-message ( 1 )
                                     ).
      end.
    end.
end.