block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление СКИДКИ по ДК

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/25/06
Author: Bakhtadze Natalya
Creation date: 12/25/06

*/

TRIGGER PROCEDURE FOR DELETE OF ub.dis-dc-rule.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление СКИДКИ по ДК ".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5|&6|&7|&8'
                         , ub.dis-dc-rule.d-card
                        , ub.dis-dc-rule.host-code
                        , ub.dis-dc-rule.obj-type
                        , ub.dis-dc-rule.obj-code
                        , ub.dis-dc-rule.pos-type
                        , ub.dis-dc-rule.discnt-role
                        , ub.dis-dc-rule.nonunique
                         ) " }

{ cmp/trg-def.i }
{ trg/disdcruh.i trigger }
{ gbl/cur-time.i }

define variable conf-par as character no-undo .
define variable par-type as character no-undo .
define variable v-type           as character no-undo .
define variable v-format         as character no-undo .
define variable v-label          as character no-undo .
define variable v-tooltip        as character no-undo .
define variable v-range          as integer   no-undo .
define variable v-user-can-edit  as logical   no-undo .
define variable v-output-display as logical   no-undo .
define variable v-other          as character no-undo .
define variable jj as integer no-undo .
define variable v-dop1 as character no-undo .
define variable v-dop2 as character no-undo .
define variable v-date as date no-undo .
define variable v-time as integer no-undo .
define variable v-host-code like ub.sysconf.host-code no-undo .
define variable v-db-list as character no-undo .
define variable v-news as logical no-undo .
define variable v-obj-db-num like ub.db.db-num no-undo .
define variable v-manual-editing as integer no-undo .

define buffer buf_c-dis-dc-rule for ub.c-dis-dc-rule.
define buffer buf_c-dc-hist for ub.c-dc-hist.
define buffer new_dis-dc-rule  for ub.dis-dc-rule.
define buffer locked_dis-dc-rule for ub.dis-dc-rule.


main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1) )
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  if not (     ub.dis-dc-rule.obj-type  = '':U
          and ub.dis-dc-rule.obj-code  = 0
          and ub.dis-dc-rule.host-code = 0
          and ub.dis-dc-rule.pos-type = '':U
          and ub.dis-dc-rule.discnt-role = '':U
          and ub.dis-dc-rule.nonunique = '')
   then do:
      Find first locked_dis-dc-rule exclusive-lock  where
              locked_dis-dc-rule.d-card    = ub.dis-dc-rule.d-card
          AND locked_dis-dc-rule.obj-type  = '':U
          AND locked_dis-dc-rule.obj-code  = 0
          AND locked_dis-dc-rule.host-code = 0
          and locked_dis-dc-rule.pos-type = '':U
          and locked_dis-dc-rule.discnt-role = '':U
          and locked_dis-dc-rule.nonunique = '':U
          no-error no-wait.
    if locked locked_dis-dc-rule then do:
      undo main-block, return error substitute("Скидка по ДК: карта &1 занята"
                                               , ub.dis-dc-rule.d-card
                                               ).
    end.
    /*если ub.dis-dc-rule.card-num < 0 это удаление несипользованных карт two-commit*/
    if ub.dis-dc-rule.card-num >= 0 then do:
      { ref/send-ref.i conf-par par-type }
      if send-ref then do:
        run trg/nu_dcard.p (
                      input  ub.dis-dc-rule.d-card
                      ,input  ub.dis-dc-rule.host-code
                      ,input  "":U
                      ,input  0
                      ,input  "U":U
                    ).
      end. /*if send-ref*/
      run cur-time in this-procedure(output v-date, output v-time).
      create buf_c-dis-dc-rule.
      buffer-copy ub.dis-dc-rule to buf_c-dis-dc-rule
      assign
      buf_c-dis-dc-rule.d-card             = ub.dis-dc-rule.d-card
      buf_c-dis-dc-rule.obj-type           = ub.dis-dc-rule.obj-type
      buf_c-dis-dc-rule.obj-code           = ub.dis-dc-rule.obj-code
      buf_c-dis-dc-rule.host-code          = ub.dis-dc-rule.host-code
      buf_c-dis-dc-rule.pos-type           = ub.dis-dc-rule.pos-type
      buf_c-dis-dc-rule.discnt-role        = ub.dis-dc-rule.discnt-role
      buf_c-dis-dc-rule.nonunique          = ub.dis-dc-rule.nonunique
      buf_c-dis-dc-rule.chip-num           = next-value (s-dc-chip, {&db-name_schema})
      buf_c-dis-dc-rule.corr-time          = v-time
      buf_c-dis-dc-rule.corr-user-db-num   = g#db-num
      buf_c-dis-dc-rule.corr-user-name     = (if g#news
                                              then {&nts-user}
                                              else (if g#esys
                                                    then {&esys-user}
                                                    else g#userid
                                                    )
                                              )
      buf_c-dis-dc-rule.corr-date          = v-date
      .
      create buf_c-dc-hist.
      buffer-copy buf_c-dis-dc-rule to buf_c-dc-hist
      assign
      buf_c-dc-hist.action = integer({&hn-delete})
      buf_c-dc-hist.subject = {&table_dis-dc-rule}
      buf_c-dc-hist.is-news  = g#news
      buf_c-dc-hist.source-type = (if g#news
                                    then {&hn-source-db}
                                    else (if g#esys
                                          then {&hn-source-esys}
                                          else "":U)
                                    )
      buf_c-dc-hist.source-ref = (if g#news
                                  then string(g#news-source-db)
                                  else (if g#esys
                                        then string(g#esys-source-esys)
                                        else "":U)
                                  )
      .
      if (not g#news
      or g#db-num = 0)
      then do:
        if ub.dis-dc-rule.obj-code <> 0 then do:
          { gbl/objdbnum.i ub.dis-dc-rule.obj-type ub.dis-dc-rule.obj-code v-obj-db-num }
          if g#db-num = 0 then do:
            if v-obj-db-num > 0 then do:
              v-db-list = string(v-obj-db-num).
            end.
          end.
          else do:
            v-db-list = string(0).
          end.
        end.
        else do:
          v-db-list = '':U.
        end.
        run nws/cmd-del.p
          ( input {&table_dis-dc-rule}
          ,input (buffer ub.dis-dc-rule:handle)
          ,input v-db-list
          ) no-error .
        if error-status :error then do:
          undo main-block, return error substitute( "&1. Ошибка при отправке в новости команды на удаление записи. &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message ( error-status :num-messages ) ).
        end.
      end.
    end.  /*card-num > 0*/
  end. /*не локирующая*/
  if g#oxml = yes
  then do:
    run str/calloxml.p (
          input {&nwsdochs_action_delete}
        , input {&table_dis-dc-rule}
        , input ( buffer ub.dis-dc-rule:handle )
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
end. /*doe*/