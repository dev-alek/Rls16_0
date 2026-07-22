block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись фирмы

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

TRIGGER PROCEDURE FOR WRITE OF ub.firm OLD old-firm.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись фирмы".
{ cmp/vssrevis.i "substitute('&1', ub.firm.firm-code) " }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }
{ trg/new-bcod.i }
{ nws/lib-nws.i }

DEFINE VARIABLE conf-par as character no-undo .
DEFINE VARIABLE par-type as character no-undo .
DEFINE VARIABLE v-l as logical no-undo .
define variable v-date as date no-undo .
define variable v-time as integer no-undo .
define variable v-err-mess as character no-undo .
define variable v-inn-uniq-error as logical no-undo .
define variable v-new-inn like ub.person.inn no-undo .
define variable v-db-num as integer no-undo .
define variable v-trg-param as character no-undo .
assign
v-trg-param = ub.firm.trg-param
ub.firm.trg-param = '':U
.

define buffer buf_dis-card for ub.dis-card.
define buffer buf_c-cli-hist for ub.c-cli-hist.
define buffer buf_c-firm for ub.c-firm.
define buffer buf_code-range for ub.code-range.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:


  if not new(ub.firm) and not g#news then do:
     { ref/send-ref.i conf-par par-type }
    /*создаем batchporcess для отсылки на кассы*/
    if send-ref then do:
      /*выясним что изменилось*/
      assign
      v-l = yes
      .
      buffer-compare ub.firm using
      city ind addres1
      to old-firm
      case-sensitive
      save result in v-l .
      if not v-l then do:
        for each buf_dis-card no-lock where
                 buf_dis-card.cli-type = {&cmp}
             AND buf_dis-card.cli-code = firm.firm-code :
          run trg/nu_dcard.p (
                        input  buf_dis-card.d-card
                        ,input  buf_dis-card.emitent-host-code
                        ,input  "":U
                        ,input  0
                        ,input  "U":U
                      ).
        end.
      end.
    end.
  end.
  if g#news then do:
    v-new-inn = ub.firm.inn.
    run trg/inn-uniq.p (
                     input-output v-new-inn
                    ,input old-firm.inn
                    ,input {&cmp}
                    ,input ub.firm.firm-code
                    ,input yes
                    ,input recid(ub.firm)
                    ,input buffer ub.firm:handle
                    ,output v-inn-uniq-error
                    ) no-error.
    if error-status:error then do:
      v-err-mess = substitute("Контрагент &1&2&3Ошибка при проверке {&abbr_inn_allshift} на уникальность&3&4&3&5"
                              , {&cmp}
                              , ub.firm.firm-code
                              , {&new-line}
                              , error-status:get-message(1)
                              , return-value) .
            undo, return error v-err-mess.
    end.
    if v-inn-uniq-error then do:
      v-err-mess = substitute("Контрагент &1&2&3&4"
                              , {&prs}
                              , ub.firm.firm-code
                              , {&new-line}
                              , return-value) .
      undo, return error v-err-mess.
    end.
    if g#db-num = 0 then do:
      assign
      ub.firm.inn = v-new-inn.
    end.
  end. /*if g#news*/
  if new(ub.firm) then do:
   /* только для новых записей надо искать диапазон
    старые и так там находятся */
    if g#news then do:
      assign
        v-db-num = g#news-source-db
      .
    end.
    else do:
      assign
        v-db-num = g#db-num
      .
    end.
    run gen-new-code-range-if-neces (
                                      input v-db-num
                                     ,input {&gbl-fm-code}
                                     ,input ub.firm.firm-code
                                     ,input g#news
                                     ,input g#db-num
                                     ,input g#news-source-db
                                   ) no-error .
    if error-status:error then do:
      message
      vss-workfile vss-revision vss-description skip
      error-status:get-message(1) skip
      return-value
      view-as alert-box error .
      undo main-block,  return error .
    end.
  end.
  if lookup({&trg-param-no-hist}, v-trg-param) = 0 then do:
    if g#news then do:
      define variable v-send as integer no-undo .
      v-send = integer({&hn-is-on}).
      { gbl/get-hn.i
      g#db-num
      {&table_firm}
      0
      '':U
      0
      '':U
      '':U
      '':U
      0
      0
      0
      {&nws-to-hist}
      v-send
      no-error
      }

    end.
    if not g#news
    or v-send >= 0 then do:
      run cur-time in this-procedure(output v-date, output v-time).
      create buf_c-firm.
      buffer-copy old-firm to buf_c-firm
      assign
      buf_c-firm.firm-code           = ub.firm.firm-code
      buf_c-firm.chip-num           = next-value (s-cli-chip, {&db-name_schema})
      buf_c-firm.corr-time          = v-time
      buf_c-firm.corr-user-db-num   = g#db-num
      buf_c-firm.corr-user-name     = (if g#news
                                       then {&nts-user}
                                       else (if g#esys
                                             then {&esys-user}
                                             else g#userid)
                                       )
      buf_c-firm.corr-date          = v-date
      .
      create buf_c-cli-hist.
      buffer-copy buf_c-firm to buf_c-cli-hist
      assign
      buf_c-cli-hist.obj-type = {&cmp}
      buf_c-cli-hist.obj-code = ub.firm.firm-code
      buf_c-cli-hist.action = (if new (ub.firm )
                              then integer({&hn-create})
                              else integer({&hn-update}))
      buf_c-cli-hist.subject = {&table_firm}
      buf_c-cli-hist.host-code = (if can-find(first ub.sysconf no-lock where
                                                    ub.sysconf.host-code = ub.firm.firm-code)
                                  then ub.firm.firm-code
                                  else 0)
      buf_c-cli-hist.is-news = g#news
      buf_c-cli-hist.source-type = (if g#news
                                    then {&hn-source-db}
                                    else (if g#esys
                                          then {&hn-source-esys}
                                          else "":U)
                                    )
      buf_c-cli-hist.source-ref = (if g#news
                                   then string(g#news-source-db)
                                   else (if g#esys
                                         then string(g#esys-source-esys)
                                         else "":U)
                                   )
      .
    end.
  end.
  if lookup({&trg-param-no-callnews}, v-trg-param) = 0 then do:
    run str/callnews.p
      (input {&table_firm}
      ,input (buffer ub.firm:handle)
      ) no-error .
    if error-status:error then do:
      undo main-block, return error return-value .
    end.
  end.
  if g#oxml = yes
  then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_firm}
        , input ( buffer ub.firm:handle )
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