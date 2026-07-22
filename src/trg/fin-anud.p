block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление кода аналит. учета

Автор: Чернова Светлана Александровна
Дата создания: 03/20/06
Author: Svetlana Chernova
Creation date: 03/20/06


*/

TRIGGER PROCEDURE FOR DELETE OF ub.fin-code-an-uchet .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление кода аналит. учета".
{ cmp/vssrevis.i "substitute('&1|&2', ub.fin-code-an-uchet.fin-code, ub.fin-code-an-uchet.host-code) " }
{ cmp/trg-def.i }


main-block :
do transaction
on error undo main-block, return error
:
find first sysconf no-lock where
          (sysconf.an-uchet-code-in         = fin-code-an-uchet.fin-code and
            sysconf.host-code               = fin-code-an-uchet.host-code) or
          (sysconf.an-uchet-code-in-cash    = fin-code-an-uchet.fin-code and
            sysconf.host-code               = fin-code-an-uchet.host-code) or
          (sysconf.an-uchet-code-in-payoff  = fin-code-an-uchet.fin-code and
            sysconf.host-code               = fin-code-an-uchet.host-code) or
          (sysconf.an-uchet-code-out        = fin-code-an-uchet.fin-code and
            sysconf.host-code               = fin-code-an-uchet.host-code) or
          (sysconf.an-uchet-code-out-cash   = fin-code-an-uchet.fin-code and
            sysconf.host-code               = fin-code-an-uchet.host-code) or
          (sysconf.an-uchet-code-out-payoff = fin-code-an-uchet.fin-code and
            sysconf.host-code               = fin-code-an-uchet.host-code)
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

    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_delete}
        , input {&table_fin-code-an-uchet}
        , input ( buffer ub.fin-code-an-uchet:handle )
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