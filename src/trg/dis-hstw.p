block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись итогов по диcконтной карте

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/08/05
Author: Bakhtadze Natalya
Creation date: 12/08/05

*/

TRIGGER PROCEDURE FOR WRITE OF ub.dis-host OLD oldb .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись итогов по диcконтной карте  на фирме".
{ cmp/vssrevis.i "substitute('&1|&2':u,ub.dis-host.d-card,ub.dis-host.dt-code,ub.dis-host.host-code)" }
{ cmp/trg-def.i  }

define variable for-saldo-rubl as decimal no-undo.
define variable for-saldo-base as decimal no-undo.
define variable l-is-updated-saldo as logical no-undo .
define temp-table tt-dis-host no-undo like ub.dis-host.


main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status:get-message (1) )
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  /* на всякий случай ограничим только ГБД */
  if g#db-num = 0 then do:
    /*изменилось сальдо*/
    define variable v-curr-r-b as character no-undo .
    { gbl/curr-r-b.i
      v-curr-r-b
    }
    if ub.dis-host.host-code > 0
    and ub.dis-host.dt-code = 0
    then do:
      buffer-compare oldb to ub.dis-host
      case-sensitive
      save result in l-is-updated-saldo.
      if l-is-updated-saldo <> yes then do:
        assign
          for-saldo-rubl = ub.dis-host.pay-tot-rubl - (ub.dis-host.gds-tot-rubl - ub.dis-host.gds-dis-rubl )
          for-saldo-base = ub.dis-host.pay-tot-base - (ub.dis-host.gds-tot-base - ub.dis-host.gds-dis-base )
        .

        find first ub.dis-card
          where ub.dis-card.d-card = ub.dis-host.d-card
          no-error .
        if not available ub.dis-card then do:
          undo main-block, return error substitute( "&1. &2&3&4Не найдена дисконтная карта с номером &5"
                                                   , vss-workfile
                                                   , vss-revision
                                                   , vss-description
                                                   , {&new-line}
                                                   , ub.dis-host.d-card).
        end.

        if (
            (v-curr-r-b = {&r-b-base} and (for-saldo-base) < ( -0.001))
            OR
            (v-curr-r-b = {&r-b-rubl} and (for-saldo-rubl) < ( -0.001))
            )
        and (not ub.dis-card.credit-card
            or ub.dis-card.emitent-host-code = 0
            )
        then do:
          if ub.dis-card.emitent-host-code = 0
          then do:
            /* карта глобальная */
            undo main-block, return error substitute( "&1. &2&3&4Не может быть отрицательного сальдо на глобальной дисконтной карте &5"
                                                    , vss-workfile
                                                    , vss-revision
                                                    , vss-description
                                                    , {&new-line}
                                                    , ub.dis-host.d-card).

          end.
        end.
        assign
        ub.dis-card.saldo-rubl = for-saldo-rubl
        ub.dis-card.saldo-base = for-saldo-base
        .
      end. /*if l-is-updated-saldo <> yes then do:*/
    end. /*if ub.dis-host.host-code > 0 then do:*/
  end. /*if g#db-num = 0 then do:*/
  if g#oxml = yes
  then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_dis-host}
        , input ( buffer ub.dis-host:handle )
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