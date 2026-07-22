block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: dtaxgrps.p $
$Archive: ref/dtaxgrps.p $

заполнение полей временной таблицы tt-tax налоги на товар по умолчанию для группы  товаров

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/31/06
Author: Bakhtadze Natalya
Creation date: 03/31/06

*/

DEFINE INPUT PARAMETER parnode-code like ub.gds-grp.node-code no-undo.
DEFINE INPUT PARAMETER parupper-code like ub.gds-grp.node-code no-undo.
define input parameter parhost-code like ub.sysconf.host-code no-undo .
define input parameter parobj-type like ub.clients.obj-type no-undo .
define input parameter parobj-code like ub.clients.obj-code no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: dtaxgrps.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/dtaxgrps.p $":U .
define variable vss-description as character no-undo init "Заполнение полей временной таблицы tt-tax для группы товаров".
{ cmp/vssrevis.i }

{ str/tt-tax.i SHARED tt-tax full }
{ cmp/trg-def.i }
{ trg/factord.i }
{ gbl/cur-time.i }
{ ref/grplib.i }

/*вспомогательные*/
define variable found as logical no-undo.

DEFINE VARIABLE varnode-code like ub.gds-grp.node-code no-undo .
DEFINE VARIABLE varrate-code like ub.tax-rate.rate-code no-undo .
DEFINE VARIABLE vartax-value like ub.tax-rate-value.rate-value no-undo .
DEFINE VARIABLE vtoday-fact-order as decimal no-undo .
DEFINE VARIABLE vgds-fact-order as decimal no-undo .
DEFINE VARIABLE varfact-date like ub.tax-rate-gds.fact-date no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable vattr-codes as character no-undo .
define variable vattr-labels as character no-undo .
define variable varrate-code-str as character no-undo .
define variable v-root-code as integer no-undo .

define buffer buf_gds-grp for ub.gds-grp.
define buffer buf_tax for ub.tax.
define buffer buf_tax-rate-gds-grp for ub.tax-rate-gds-grp.
define buffer buf_tax-rate for ub.tax-rate.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:


if parnode-code <> 0 then do:
  if parhost-code = 0 or
    parobj-type = "":U or
    parobj-code = 0 then do:
      undo main-block, return error substitute("&1 &2 &3&4" +
    "Неверные значения параметров объект и/или фирма при вызове процедуры dtaxgrps.p "
                                    ,vss-workfile
                                    ,vss-revision
                                    ,vss-description
                                    ,{&new-line}).
  end.
end.


for each tt-tax:
    delete tt-tax.
end.
run cur-time in this-procedure(output v-today, output v-time).
run factord-end-day in this-procedure (input v-today , output vtoday-fact-order).

/*товара еще нет тогда должен быть известен хотя бы группа */

/*определим какие налоги должны присутствовать на каждый товар*/


if parnode-code <> 0 then do:
  varnode-code = parnode-code.
  find first buf_gds-grp No-LOCK WHERE
              buf_gds-grp.node-code = parnode-code No-ERROR.
end.
else do:
  varnode-code = parupper-code.
  find first buf_gds-grp No-LOCK WHERE
              buf_gds-grp.node-code = parupper-code No-ERROR.
end.
run grplib-get-root-code ( output v-root-code).


  if not avail buf_gds-grp then do:
    undo main-block, return error substitute("&1 &2 &3&4" +
                                  "Нет группы товаров с кодом &5"
                                ,vss-workfile
                                ,vss-revision
                                ,vss-description
                                ,{&new-line}
                                ,varnode-code).
end.

_tax:
  FOR EACH buf_tax No-LOCK WHERE
          buf_tax.individual = no
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
    if buf_tax.individual = yes then next _tax.
    varrate-code = 0.

    FIND LAST buf_tax-rate-gds-grp No-LOCK WHERE
              buf_tax-rate-gds-grp.node-code = varnode-code
         AND  buf_tax-rate-gds-grp.tax-code = buf_tax.tax-code
         AND
            /*
            freeze
              buf_tax-rate-gds-grp.host-code = parhopst-code AND
              buf_tax-rate-gds-grp.obj-type = parobj-type AND
              buf_tax-rate-gds-grp.obj-code = parobj-code AND

            */
              buf_tax-rate-gds-grp.host-code = 0
          AND buf_tax-rate-gds-grp.obj-type = ""
          AND buf_tax-rate-gds-grp.obj-code = 0 NO-ERROR.


    if avail buf_tax-rate-gds-grp then do:
      found = yes.
      assign
        varrate-code = buf_tax-rate-gds-grp.rate-code
      .
    end.
    FIND FIRST buf_tax-rate No-LOCK WHERE
                    buf_tax-rate.tax-code = buf_tax.tax-code AND
                    buf_tax-rate.rate-code = varrate-code No-ERROR.
    if error-status:error or not avail buf_tax-rate then do:
      if varrate-code = 0
      and buf_gds-grp.node-code = v-root-code
      then do:
        assign
        vattr-codes = "":U
        vattr-labels = "":U
        .
        for each buf_tax-rate no-lock where
                buf_tax-rate.tax-code = buf_tax.tax-code:

          { gbl/pftaxval.i recid(buf_tax-rate) buf_tax-rate.tax-code buf_tax-rate.rate-code ? 0 '':U 0 vartax-value no-error }
          if error-status:error then do:
            message
            return-value view-as alert-box error .
            return error.
          end.
        if vartax-value = ? then NEXT.
        assign
        vattr-labels = vattr-labels +
                      (if vattr-labels = "":U then "" else {&comma-char}) +
                      string(string(buf_tax-rate.rate-code) + " - " + replace(buf_tax-rate.rate-name, {&comma-char}, "":U), "X(25)") +
                      fill({&space-char}, 5) + string(vartax-value, "99.99%":U)
        vattr-codes = vattr-codes +
                      (if vattr-codes = "":U then "" else {&comma-char}) +
                      string(buf_tax-rate.rate-code)
        .
        run gbl/d-list.w (
                      INPUT "b-sel":U
                      ,INPUT substitute("Выберите ставку налога (&1) для групп (по умолчанию)", buf_tax.tax-name)
                      ,INPUT vattr-codes
                      ,INPUT vattr-labels
                      ,INPUT {&comma-char}
                      ,INPUT "":U
                      ,output varrate-code-str).
        IF varrate-code-str = "":u THEN do:
          message
          substitute("Вы не выбрали ставку налога (&1) для групп!&2" +
                    "Это может привести к непредсказуемым результатам"
                    , buf_tax.tax-name
                    , {&new-line}
                    )
          view-as alert-box error .
          RETURN ERROR.
        end.
        create buf_tax-rate-gds-grp.
        assign
        buf_tax-rate-gds-grp.node-code = buf_gds-grp.node-code
        buf_tax-rate-gds-grp.tax-code =  buf_tax.tax-code
        buf_tax-rate-gds-grp.rate-code = integer(varrate-code-str)
        .
      end. /*    for each buf_tax-rate no-lock where*/
    end. /*if varrate-code = 0*/
    else do:
      undo main-block, return error substitute("&1 &2 &3&4" +
                                    "Не найдена запись ставки налога:&4" +
                                    "код налога: &5, код ставки &6&4" +
                                    "возможно у Вас не настроены ставки налога по умолчанию для групп товаров"
                                    ,vss-workfile
                                    ,vss-revision
                                    ,vss-description
                                    ,{&new-line}
                                    ,buf_tax.tax-code
                                    ,varrate-code).
    end.
  end. /*if error-status:error or not avail buf_tax-rate then do:*/
  if parhost-code > 0 and
     parobj-type <> "":U and
     parobj-code <> 0 then do:
      { gbl/pftaxval.i recid(buf_tax-rate) 0 0 ? parhost-code parobj-type parobj-code vartax-value no-error }
    if error-status:error or vartax-value = ? then do:
        undo main-block, return error substitute("&1 &2 &3&4" +
                                      "Ошибка при определении значения ставки налога по умолчанию на товар группы:&4" +
                                      "код налога: &5, ставка налога: &6"
                                      ,vss-workfile
                                      ,vss-revision
                                      ,vss-description
                                      ,{&new-line}
                                      ,buf_tax-rate.tax-code
                                      ,buf_tax-rate.rate-code).
    end. /*    if error-status:error or vartax-value = ? then do:*/
  end.
  FIND FIRST tt-tax NO-LOCK WHERE
                tt-tax.tax-code = buf_tax.tax-code No-ERROR.
  if not avail tt-tax then do:
      create
      tt-tax.
      assign
        tt-tax.tax-code = buf_tax.tax-code
        tt-tax.tax-name = buf_tax.tax-name
        tt-tax.rate-code = if buf_tax.individual then ? else buf_tax-rate.rate-code
        tt-tax.rate-name = if buf_tax.individual then buf_tax.tax-name else buf_tax-rate.rate-name
        tt-tax.tax-type = buf_tax.tax-type
        tt-tax.rate-value = if buf_tax.individual then ? else vartax-value
        tt-tax.individual = buf_tax.individual
        tt-tax.tax-rate-gds-rc = if (avail buf_gds-grp and avail buf_tax-rate-gds-grp )
                            then recid(buf_tax-rate-gds-grp)
                          else ?
      tt-tax.fact-date = varfact-date
      tt-tax.fact-order = vtoday-fact-order
      .
  end. /*not avail tt-tax*/
  END. /*for each ub.tax-unit*/
end.