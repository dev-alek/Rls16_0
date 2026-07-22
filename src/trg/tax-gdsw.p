block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись для таблицы ставки налога на товар

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

TRIGGER PROCEDURE FOR WRITE OF ub.tax-rate-gds OLD old-tax-rate-gds.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись для таблицы ставки налога на товар".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5|&6|&7':u,ub.tax-rate-gds.fact-order,ub.tax-rate-gds.gds-code,ub.tax-rate-gds.host-code,ub.tax-rate-gds.obj-code,ub.tax-rate-gds.obj-type,ub.tax-rate-gds.rate-code,ub.tax-rate-gds.tax-code)" }
{ cmp/trg-def.i  }

DEFINE VARIABLE conf-par as character no-undo .
DEFINE VARIABLE par-type as character no-undo .
DEFINE VARIABLE v-l as logical no-undo .
{ gbl/cur-time.i }

define variable v-date as date      no-undo.
define variable v-time  as integer   no-undo.
define variable v-host-code like ub.sysconf.host-code no-undo .
define variable v-creation as logical no-undo .
define variable v-rate-code like ub.tax-rate-gds.rate-code no-undo .
define variable v-fact-order like ub.tax-rate-gds.fact-order no-undo .
define variable v-upgrade as logical no-undo .
define buffer buf_c-gds-hist for ub.c-gds-hist.
define buffer buf_tax-rate-gds for ub.tax-rate-gds.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:


  find ub.goods no-lock
    where ub.goods.gds-code     = ub.tax-rate-gds.gds-code
    no-error .
    run cur-time in this-procedure(output v-date, output v-time).
    assign
    ub.tax-rate-gds.chip-num           = (if not g#news then next-value (s-gds-chip, {&db-name_schema}) else ub.tax-rate-gds.chip-num)
    ub.tax-rate-gds.corr-time          = (if not g#news then v-time else ub.tax-rate-gds.corr-time)
    ub.tax-rate-gds.corr-user-db-num   = (if not g#news then g#db-num else ub.tax-rate-gds.corr-user-db-num)
    ub.tax-rate-gds.corr-user-name     = (if g#news
                                        then {&nts-user}
                                        else (if g#esys
                                              then {&esys-user}
                                              else g#userid)
                                        )
    ub.tax-rate-gds.corr-date          = (if not g#news then v-date      else ub.tax-rate-gds.corr-date)
    .
    if not (ub.tax-rate-gds.obj-type = "":U and ub.tax-rate-gds.obj-code = 0 ) then do:
      { gbl/hostcode.i ub.tax-rate-gds.obj-type ub.tax-rate-gds.obj-code v-host-code }
    end.
    assign
    v-upgrade = (if num-entries (ub.tax-rate-gds.corr-user-name, {&delim-par}) > 1
                and entry(2, ub.tax-rate-gds.corr-user-name, {&delim-par}) = {&hn-source-upgrade}
                then yes
                else no).
    if new(ub.tax-rate-gds)
    or v-upgrade
    then do:
      find last buf_tax-rate-gds no-lock
        where buf_tax-rate-gds.gds-code   = ub.tax-rate-gds.gds-code
          and buf_tax-rate-gds.tax-code   = ub.tax-rate-gds.tax-code
          and buf_tax-rate-gds.host-code  = 0
          and buf_tax-rate-gds.obj-type   = ""
          and buf_tax-rate-gds.obj-code   = 0
          and buf_tax-rate-gds.fact-order < ub.tax-rate-gds.fact-order
        no-error .
      if available buf_tax-rate-gds then do:
        assign
        v-rate-code = buf_tax-rate-gds.rate-code
        v-fact-order = buf_tax-rate-gds.fact-order
        .
      end.
    end.
    create buf_c-gds-hist.
    buffer-copy ub.tax-rate-gds
    except chip-num corr-user-db-num corr-user-name corr-time corr-date
    to buf_c-gds-hist
    assign
    buf_c-gds-hist.chip-num           = next-value (s-gds-chip, {&db-name_schema})
    buf_c-gds-hist.corr-time          = (if v-upgrade
                                        then ub.tax-rate-gds.corr-time
                                        else v-time)
    buf_c-gds-hist.corr-user-db-num   = g#db-num
    buf_c-gds-hist.corr-user-name     = (if g#news then {&nts-user} else g#userid)
    buf_c-gds-hist.corr-user-name     = (if g#news
                                        then {&nts-user}
                                        else (if g#esys
                                              then {&esys-user}
                                              else g#userid)
                                        )
    buf_c-gds-hist.corr-date          = (if v-upgrade
                                        then ub.tax-rate-gds.corr-date
                                        else v-date)
    buf_c-gds-hist.rate-code = (if v-upgrade
                                then v-rate-code
                                else (if new ub.tax-rate-gds then v-rate-code else old-tax-rate-gds.rate-code)
                                )
    buf_c-gds-hist.fact-order = (if v-upgrade
                                 then v-fact-order
                                 else (if new ub.tax-rate-gds then v-fact-order else old-tax-rate-gds.fact-order)
                                 )
    buf_c-gds-hist.action = (if new(ub.tax-rate-gds) then integer({&hn-create}) else integer({&hn-update}))
    buf_c-gds-hist.subject = {&table_tax-rate-gds}
    buf_c-gds-hist.host-code = v-host-code
    buf_c-gds-hist.is-news  = g#news
    buf_c-gds-hist.source-type = (if g#news
                                  then {&hn-source-db}
                                  else (if g#esys
                                        then {&hn-source-esys}
                                        else "":U)
                                  )
    buf_c-gds-hist.source-ref = (if g#news
                                  then string(g#news-source-db)
                                  else (if g#esys
                                        then string(g#esys-source-esys)
                                        else "":U)
                                  )
    .
  if not g#news then do:
    { ref/send-ref.i conf-par par-type }
    if send-ref then do:
      /*для новых товаров не имеет смысла т.к. они все равно вбез цен на кассу не должны попасть*/
      if new(ub.tax-rate-gds) then do:
        assign
        v-l = no
        .
      end.
      else do:
        /*выясним изменилось ли значение кода ставки на текущий момент*/
        assign
        v-l = yes
        .
        buffer-compare ub.tax-rate-gds using
        rate-code
        to old-tax-rate-gds
        case-sensitive
        save result in v-l .
      end.
      if not v-l then do:
        run trg/nu_gds.p (
                      input  ub.goods.gds-code
                      ,input  0
                      ,input  "":U
                      ,input  0
                      ,input  "U":U
                    ).
      end.

    end.
  end.
  if ( available ub.goods and not new (ub.goods))
  or not available ub.goods then do:
    /* если новая запись то итак все уйдет в новости
    в общем блоке с товаром */

    run str/callnews.p
      (input {&table_tax-rate-gds}
      ,input (buffer ub.tax-rate-gds:handle)
      ) no-error .
    if error-status:error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Невозможно маршрутизировать tax-rate-gds для отправки в новости" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box.
      undo main-block, return error .
    end.
  end.


    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_tax-rate-gds}
        , input ( buffer ub.tax-rate-gds:handle )
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