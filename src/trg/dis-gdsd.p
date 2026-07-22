block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление dis-gds-rule

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/13/06
Author: Bakhtadze Natalya
Creation date: 11/13/06

*/

TRIGGER PROCEDURE FOR DELETE OF ub.dis-gds-rule.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление dis-gds-rule".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5|&6'
                              ,ub.dis-gds-rule.obj-type
                              ,ub.dis-gds-rule.obj-code
                             , ub.dis-gds-rule.gds-code
                              ,ub.dis-gds-rule.pos-type
                              ,ub.dis-gds-rule.discnt-role
                              ,ub.dis-gds-rule.nonunique
                              )" }

{ cmp/trg-def.i  }
{ ref/disgdsru.i trigger }
{ gbl/cur-time.i }
{ nws/lib-nws.i }

define variable conf-par as character no-undo .
define variable par-type as character no-undo .
define variable v-host-code like ub.sysconf.host-code no-undo .
define variable v-date as date no-undo .
define variable v-time as integer no-undo .
define variable v-obj-db-num like ub.db.db-num no-undo .
define variable v-db-list as character no-undo .
define buffer buf_c-dis-gds-rule for ub.c-dis-gds-rule.
define buffer buf_c-gds-hist for ub.c-gds-hist.
define buffer locked_dis-gds-rule for ub.dis-gds-rule.


main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  if not g#news
  and g#db-num > 0
  and (
      ub.dis-gds-rule.obj-type  = '':U
      or
      ub.dis-gds-rule.obj-code = 0
      or
      ub.dis-gds-rule.obj-type  = {&cmp}
      or
      ub.dis-gds-rule.gds-code = 0
      ) then do:
    message
    vss-workfile vss-revision vss-description skip
    substitute("&1&2 POS &3 тип &4 товар &5&6" +
               "Нельзя удалять запись СКИДОК НА ТОВАР в УБД"
               ,ub.dis-gds-rule.obj-type
               ,ub.dis-gds-rule.obj-code
               ,ub.dis-gds-rule.pos-type
               ,ub.dis-gds-rule.discnt-role
               ,ub.dis-gds-rule.gds-code
               )
    view-as alert-box error .
    undo main-block, return error .
  end.
  if ub.dis-gds-rule.obj-type = {&shop}
  or ub.dis-gds-rule.obj-type = {&stock} then do:
    { gbl/objdbnum.i ub.dis-gds-rule.obj-type ub.dis-gds-rule.obj-code v-obj-db-num }
    if v-obj-db-num <> g#db-num
    and g#db-num <> 0 then do:
      message
      vss-workfile vss-revision vss-description skip
      substitute("&1&2 POS &3 тип &4 товар &5 &6" +
                "Нельзя удалять запись СКИДОК НА ТОВАР в чужой БД"
               ,ub.dis-gds-rule.obj-type
               ,ub.dis-gds-rule.obj-code
               ,ub.dis-gds-rule.pos-type
               ,ub.dis-gds-rule.discnt-role
               ,ub.dis-gds-rule.gds-code
               )
      view-as alert-box error .
      undo main-block, return error .
    end.
  end.


  if not ub.dis-gds-rule.templ-rl-root = 0 then do:
    Find first locked_dis-gds-rule exclusive-lock  where
            locked_dis-gds-rule.gds-code = ub.dis-gds-rule.gds-code
        AND locked_dis-gds-rule.obj-type = (if g#db-num = 0 then '':U else ub.dis-gds-rule.obj-type)
        AND locked_dis-gds-rule.obj-code = (if g#db-num = 0 then 0 else ub.dis-gds-rule.obj-code)
        and locked_dis-gds-rule.pos-type = '':U
        and locked_dis-gds-rule.discnt-role = '':U
        and locked_dis-gds-rule.nonunique = '':U
        no-error no-wait.
   if locked locked_dis-gds-rule then do:
    undo main-block, return error substitute("Скидки товара для товара &1 &2&3 заняты"
                                              , ub.dis-gds-rule.gds-code
                                              , ub.dis-gds-rule.obj-type
                                              , ub.dis-gds-rule.obj-code).
     end.
    { ref/send-ref.i conf-par par-type }
    if send-ref then do:
    run trg/nu_gds.p (
                  input  ub.dis-gds-rule.gds-code
                  ,input  0
                  ,input  ub.dis-gds-rule.obj-type
                  ,input  ub.dis-gds-rule.obj-code
                  ,input  "U":U  /*здесь действительно надо U!!! не меняйте на D*/
                ).

    end. /*if send-ref*/
    if g#news then do:
      define variable v-send as integer no-undo .
      v-send = integer({&hn-is-on}).
      { gbl/get-hn.i
      g#db-num
      ~{&table_dis-gds-rule~}
      0
      '':U
      0
      '':U
      '':U
      '':U
      0
      0
      0
      ~{&nws-to-hist~}
      v-send
      no-error
      }

    end.
    if not g#news
    or v-send >= 0 then do:
      run cur-time in this-procedure(output v-date, output v-time).
      create buf_c-dis-gds-rule.
      buffer-copy ub.dis-gds-rule to buf_c-dis-gds-rule
      assign
      buf_c-dis-gds-rule.chip-num           = next-value (s-gds-chip, {&db-name_schema})
      buf_c-dis-gds-rule.corr-time          = v-time
      buf_c-dis-gds-rule.corr-user-db-num   = g#db-num
      buf_c-dis-gds-rule.corr-user-name     = g#userid
      buf_c-dis-gds-rule.corr-user-name     = (if g#news
                                                then {&nts-user}
                                                else (if g#esys
                                                      then {&esys-user}
                                                      else g#userid)
                                                )
      buf_c-dis-gds-rule.corr-date          = v-date
      .
      if ub.dis-gds-rule.obj-type = {&shop}
      or ub.dis-gds-rule.obj-type = {&stock} then do:
        { gbl/hostcode.i ub.dis-gds-rule.obj-type ub.dis-gds-rule.obj-code v-host-code }
      end.
      if ub.dis-gds-rule.obj-type = {&cmp} then do:
        v-host-code = ub.dis-gds-rule.obj-code.
      end.
      create buf_c-gds-hist.
      buffer-copy buf_c-dis-gds-rule to buf_c-gds-hist
      assign
      buf_c-gds-hist.obj-type = (if ub.dis-gds-rule.obj-type = {&shop}
                                 or ub.dis-gds-rule.obj-type = {&stock}
                                 then ub.dis-gds-rule.obj-type
                                 else '':U)
      buf_c-gds-hist.obj-code = (if ub.dis-gds-rule.obj-type = {&shop}
                                 or ub.dis-gds-rule.obj-type = {&stock}
                                 then ub.dis-gds-rule.obj-code
                                 else 0)
      buf_c-gds-hist.action = integer({&hn-delete})
      buf_c-gds-hist.subject = {&table_dis-gds-rule}
      buf_c-gds-hist.host-code = v-host-code
      buf_c-gds-hist.is-news   = g#news
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
    end.
    if ub.dis-gds-rule.obj-type = {&shop}
    or ub.dis-gds-rule.obj-type = {&stock} then do:
      { gbl/objdbnum.i ub.dis-gds-rule.obj-type ub.dis-gds-rule.obj-code  v-obj-db-num }
      if g#db-num = 0 and v-obj-db-num <> 0  then do:
        assign v-db-list = string( v-obj-db-num ) .
      end.
      if g#db-num <> 0 and not g#news then do:
        assign v-db-list = "0" .
      end.
    end.
    run nws/cmd-del.p
      ( input {&table_dis-gds-rule}
      ,input (buffer ub.dis-gds-rule:handle)
      ,input v-db-list
      ) no-error .
    if error-status :error then do:
      undo, return error substitute( "&1. Ошибка при отправке в новости команды на удаление записи. &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message ( error-status :num-messages ) ).
    end.
  end.
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_delete}
        , input {&table_dis-gds-rule}
        , input ( buffer ub.dis-gds-rule:handle )
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