block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление кода корресп. счета

Автор: Чернова Светлана Александровна
Дата создания: 03/20/06
Author: Svetlana Chernova
Creation date: 03/20/06

*/

TRIGGER PROCEDURE FOR DELETE OF ub.fin-code-cor-acc .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление кода корресп. счета ".
{ cmp/vssrevis.i "substitute('&1|&2', ub.fin-code-cor-acc.fin-code, ub.fin-code-cor-acc.host-code) " }
{ cmp/trg-def.i }


main-block :
do transaction
on error undo main-block, return error
:

find first sysconf no-lock where
            ( sysconf.cor-acc-in   = ub.fin-code-cor-acc.fin-code    and
              sysconf.host-code = ub.fin-code-cor-acc.host-code ) or
            ( sysconf.cor-acc1-in  = ub.fin-code-cor-acc.fin-code    and
              sysconf.host-code = ub.fin-code-cor-acc.host-code ) or
            ( sysconf.cor-acc-out  = ub.fin-code-cor-acc.fin-code    and
              sysconf.host-code = ub.fin-code-cor-acc.host-code ) or
            ( sysconf.cor-acc1-out = ub.fin-code-cor-acc.fin-code    and
              sysconf.host-code = ub.fin-code-cor-acc.host-code ) or
            ( sysconf.cor-acc-in-cash  = ub.fin-code-cor-acc.fin-code    and
              sysconf.host-code = ub.fin-code-cor-acc.host-code ) or
            ( sysconf.cor-acc1-in-cash  = ub.fin-code-cor-acc.fin-code    and
              sysconf.host-code = ub.fin-code-cor-acc.host-code ) or
            ( sysconf.cor-acc-out-cash  = ub.fin-code-cor-acc.fin-code    and
              sysconf.host-code = ub.fin-code-cor-acc.host-code ) or
            ( sysconf.cor-acc1-out-cash  = ub.fin-code-cor-acc.fin-code    and
              sysconf.host-code = ub.fin-code-cor-acc.host-code ) or
            ( sysconf.cor-acc-in-payoff  = ub.fin-code-cor-acc.fin-code    and
              sysconf.host-code = ub.fin-code-cor-acc.host-code ) or
            ( sysconf.cor-acc1-in-payoff  = ub.fin-code-cor-acc.fin-code    and
              sysconf.host-code = ub.fin-code-cor-acc.host-code ) or
            ( sysconf.cor-acc-out-payoff  = ub.fin-code-cor-acc.fin-code    and
              sysconf.host-code = ub.fin-code-cor-acc.host-code ) or
            ( sysconf.cor-acc1-out-payoff = ub.fin-code-cor-acc.fin-code    and
              sysconf.host-code = ub.fin-code-cor-acc.host-code )
        no-error .
if available sysconf
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Нельзя удалять запись! " skip
      "Значение справочника используется в настройке фирмы"  skip
      view-as alert-box error .
    undo main-block, return error .
  end.
 if not g#news then do:
    run nws/cmd-del.p
      ( input "fin-code-cor-acc":U
       ,input (buffer ub.fin-code-cor-acc:handle)
       ,input "":U
      ) no-error .
    if error-status :error then do:
      undo, return error substitute( "&1. Ошибка при отправке в новости команды на удаление записи. &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message ( error-status :num-messages ) ).
    end.
   end.  
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_delete}
        , input {&table_fin-code-cor-acc}
        , input ( buffer ub.fin-code-cor-acc:handle )
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