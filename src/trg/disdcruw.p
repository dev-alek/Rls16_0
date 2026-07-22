block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись в таблице dis-dc-rule

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/20/06
Author: Bakhtadze Natalya
Creation date: 12/20/06


*/

TRIGGER PROCEDURE FOR WRITE OF ub.dis-dc-rule OLD olddis-dc-rule.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись в таблице dis-dc-rule".
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
{ gbl/cur-time.i }
{ trg/disdcruh.i trig olddis-dc-rule ub.dis-dc-rule }

define variable conf-par as character no-undo .
define variable par-type as character no-undo .
define variable v-date as date no-undo .
define variable v-time as integer no-undo .
define variable v-host-code like ub.sysconf.host-code no-undo .
define variable v-manual-editing as integer no-undo .
define buffer buf_c-dis-dc-rule for ub.c-dis-dc-rule.
define buffer buf_c-dc-hist for ub.c-dc-hist.
define buffer locked_dis-dc-rule for ub.dis-dc-rule.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  if not ub.dis-dc-rule.templ-rl-root = 0 then do:
    Find first locked_dis-dc-rule exclusive-lock  where
            locked_dis-dc-rule.d-card    = ub.dis-dc-rule.d-card
        AND locked_dis-dc-rule.obj-type  = '':U
        AND locked_dis-dc-rule.obj-code  = 0
        AND locked_dis-dc-rule.host-code = 0
        and locked_dis-dc-rule.pos-type = '':U
        and locked_dis-dc-rule.discnt-role = '':U
        and locked_dis-dc-rule.nonunique = '':U
        no-error no-wait.
&scop dis-dc-rule-code ub.dis-dc-rule.discnt-role
    if locked locked_dis-dc-rule then
    undo main-block, return error substitute("СКИДКА по ДК карта &1 место использ. &2 тип скидки &3 занята"
                                              , ub.dis-dc-rule.d-card
                                              , ub.dis-dc-rule.pos-type
                                              , {&dis-dc-rule-name}

                                              ).
  end.
  if ub.dis-dc-rule.obj-type  = '':U
        AND ub.dis-dc-rule.obj-code  = 0
        AND ub.dis-dc-rule.host-code = 0
        and ub.dis-dc-rule.pos-type = '':U
        and ub.dis-dc-rule.discnt-role = '':U
        and ub.dis-dc-rule.nonunique = '':U then do:
   /*это просто блокирующая запись*/

 end.
 else do:
  { ref/send-ref.i conf-par par-type }
    if send-ref and not g#news then do:
      run trg/nu_dcard.p (
                    input  ub.dis-dc-rule.d-card
                    ,input  ub.dis-dc-rule.host-code
                    ,input  "":U
                    ,input  0
                    ,input  "U":U
                  ).
    end. /*if send-ref*/
      run disdcruh_write-dis-dc-rule-trigger in this-procedure  (
                                          input new(ub.dis-dc-rule)
                                        ,input (if g#news
                                                then {&hn-source-db}
                                                else (if g#esys
                                                      then {&hn-source-esys}
                                                      else "":U)
                                                )
                                        ,input  (if g#news
                                                  then string(g#news-source-db)
                                                  else (if g#esys
                                                        then string(g#esys-source-esys)
                                                        else "":U)
                                                  )
                                        ) .



    run str/callnews.p
      ( input {&table_dis-dc-rule}
      ,input (buffer ub.dis-dc-rule:handle )
      ) no-error .
    if error-status:error then undo main-block, return error return-value .

    if g#oxml = yes
    then do:
      run str/calloxml.p (
            input {&nwsdochs_action_update}
          , input {&table_dis-dc-rule}
          , input ( buffer ub.dis-dc-rule:handle )
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
end.