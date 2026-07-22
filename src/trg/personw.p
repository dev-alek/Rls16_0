block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись person

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

TRIGGER PROCEDURE FOR WRITE OF ub.person OLD oldb.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись person".
{ cmp/vssrevis.i "substitute('&1', ub.person.psn-code) " }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }
{ trg/new-bcod.i }
{ nws/lib-nws.i }

DEFINE VARIABLE conf-par as character no-undo .
DEFINE VARIABLE par-type as character no-undo .
DEFINE VARIABLE v-l as logical no-undo .
define variable v-inn-uniq-error as logical no-undo .
define variable v-new-inn like ub.person.inn no-undo .

define variable v-date as date no-undo .
define variable v-time as integer no-undo .
define variable v-err-mess as character no-undo .
define variable v-db-num as integer no-undo .
define variable v-trg-param as character no-undo .
assign
v-trg-param = ub.person.trg-param
ub.person.trg-param = '':U
.

define buffer buf_c-cli-hist for ub.c-cli-hist.
define buffer buf_c-person for ub.c-person.

define buffer buf_dis-card for ub.dis-card.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:


  if not g#news then do:
     { ref/send-ref.i conf-par par-type }
    /*создаем batchporcess для отсылки на кассы*/
    if send-ref then do:
      /*выясним что изменилось*/
      assign
      v-l = yes
      .
      IF not new(ub.person) then do:
        buffer-compare ub.person using
        city ind address name1 name2
        to oldb
        case-sensitive
        save result in v-l .
        if not v-l then do:
          for each buf_dis-card no-lock where
                  buf_dis-card.cli-type = {&prs}
              AND buf_dis-card.cli-code = person.psn-code :
            run trg/nu_dcard.p (
                          input  buf_dis-card.d-card
                          ,input  buf_dis-card.emitent-host-code
                          ,input  "":U
                          ,input  0
                          ,input  "U":U
                        ).
          end.
        end.
      end. /*IF not new(ub.person) then do:*/
    end. /*if p-send-ref*/
  end. /*not g#news*/
  if g#news then do:
    v-new-inn = ub.person.inn.
    run trg/inn-uniq.p (
                     input-output v-new-inn
                    ,input oldb.inn
                    ,input {&prs}
                    ,input ub.person.psn-code
                    ,input yes
                    ,input recid(ub.person)
                    ,input buffer ub.person:handle
                    ,output v-inn-uniq-error
                    ) no-error.
    if error-status:error then do:
      v-err-mess = substitute("Контрагент &1&2&3Ошибка при проверке {&abbr_inn_allshift} на уникальность&3&4&3&5"
                              , {&prs}
                              , ub.person.psn-code
                              , {&new-line}
                              , error-status:get-message(1)
                              , return-value) .
      undo, return error v-err-mess.
    end.
    if v-inn-uniq-error then do:
      v-err-mess = substitute("Контрагент &1&2&3&4"
                              , {&prs}
                              , ub.person.psn-code
                              , {&new-line}
                              , return-value) .
      undo, return error v-err-mess.
    end.
    if g#db-num = 0 then do:
      assign
      ub.person.inn = v-new-inn.
    end.
  end.
  if new(ub.person) then do:
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
                                     ,input {&gbl-pn-code}
                                     ,input ub.person.psn-code
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
      {&table_person}
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
      create buf_c-person.
      buffer-copy oldb to buf_c-person
      assign
      buf_c-person.psn-code           = ub.person.psn-code
      buf_c-person.chip-num           = next-value (s-cli-chip, {&db-name_schema})
      buf_c-person.corr-time          = v-time
      buf_c-person.corr-user-db-num   = g#db-num
      buf_c-person.corr-user-name     = (if g#news
                                       then {&nts-user}
                                       else (if g#esys
                                             then {&esys-user}
                                             else g#userid)
                                       )
      buf_c-person.corr-date          = v-date
      .
      create buf_c-cli-hist.
      buffer-copy buf_c-person to buf_c-cli-hist
      assign
      buf_c-cli-hist.obj-type = {&prs}
      buf_c-cli-hist.obj-code = ub.person.psn-code
      buf_c-cli-hist.action = (if new (ub.person )
                              then integer({&hn-create})
                              else integer({&hn-update}))
      buf_c-cli-hist.subject = {&table_person}
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
      (input {&table_person}
      ,input (buffer ub.person:handle)
      ) no-error .
    if error-status:error then do:
      undo main-block, return error return-value .
    end.
  end.
  if g#oxml = yes
  then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_person}
        , input ( buffer ub.person:handle )
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
end. /*DOE*/