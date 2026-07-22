block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: cmd-dct.p $
$Archive: nws/cmd-dct.p $

Обработка команды отсылки данных по типу ДК

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/04/06
Author: Bakhtadze Natalya
Creation date: 11/04/06

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle as handle no-undo .
define input parameter p-log-handle as handle no-undo .
define input parameter p-imp-handle as handle    no-undo .
define input parameter p-counter  as integer   no-undo .
define input parameter p-emitent-host-code as integer no-undo .
define input parameter p-type as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: cmd-dct.p $":U .
define variable vss-archive     as character no-undo init "$Archive: nws/cmd-dct.p $":U .
define variable vss-description as character no-undo init "Обработка команды отсылки данных по типу ДК".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ gbl/key-rec.i }
{ gbl/waitfram.i }



define variable counter    as integer   no-undo .
define variable rec-full   as character no-undo .
define variable v-rec-name as character no-undo .
define variable log-file-name as character no-undo .
define variable v-action as character no-undo .
define variable v-curr-rowid as rowid no-undo .

define temp-table temp-dis-card-type no-undo like ub.dis-card-type
field action as integer
.
define buffer buf_temp-dis-card-type for temp-dis-card-type.
define buffer buf_dis-card-type for ub.dis-card-type.


define temp-table temp-dis-card-type-attr no-undo like ub.dis-card-type-attr
field action as integer
.
define buffer buf_temp-dis-card-type-attr for temp-dis-card-type-attr.
define buffer buf_dis-card-type-attr for ub.dis-card-type-attr.


define temp-table temp-rule-call-param no-undo like ub.rule-call-param
field action as integer
.
define buffer buf_temp-rule-call-param for temp-rule-call-param.
define buffer buf_rule-call-param for ub.rule-call-param.


define temp-table temp-rule-by-call no-undo like ub.rule-by-call
field action as integer
.
define buffer buf_temp-rule-by-call for temp-rule-by-call.
define buffer buf_rule-by-call for ub.rule-by-call.


define temp-table temp-rp-by-call no-undo like ub.rp-by-call
field action as integer
.
define buffer buf_temp-rp-by-call for temp-rp-by-call .
define buffer buf_rp-by-call for ub.rp-by-call.


define temp-table temp-hist-nws-option no-undo like ub.hist-nws-option
field action as integer
.
define buffer buf_temp-hist-nws-option for temp-hist-nws-option.
define buffer buf_hist-nws-option for ub.hist-nws-option.

define temp-table temp-prop-ref-call no-undo like ub.prop-ref-call
field action as integer
.
define buffer buf_temp-prop-ref-call for temp-prop-ref-call.
define buffer buf_prop-ref-call for ub.prop-ref-call.


define temp-table temp-dis-dct-rule no-undo like ub.dis-dct-rule
field action as integer
.
define buffer buf_temp-dis-dct-rule for temp-dis-dct-rule.
define buffer buf_dis-dct-rule for ub.dis-dct-rule.




define buffer root_dis-card-type for ub.dis-card-type.

main-block:
do
on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
on stop   undo, return error substitute( "&1. stop", vss-workfile )
on endkey undo, return error substitute( "&1. endkey", vss-workfile )
:

  do counter = 1 to p-counter
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :
    run waitfram-show in this-procedure
      (input substitute("Получение данных по типу ДК. Тип ДК &1 Эмитент &2. Получено записей: &3"
                        , p-type
                        , p-emitent-host-code
                        , counter)
      ) .
    find first root_dis-card-type no-lock where
              root_dis-card-type.emitent-host-code = p-emitent-host-code
          and root_dis-card-type.type = p-type
          and root_dis-card-type.host-code = 0
          and root_dis-card-type.obj-type = '':U
          and root_dis-card-type.obj-code = 0
          no-error.
    if available root_dis-card-type then do:
      find first root_dis-card-type exclusive-lock where
                root_dis-card-type.emitent-host-code = p-emitent-host-code
            and root_dis-card-type.type = p-type.
    end.
    run nws-imps in p-imp-handle
      ( input-output counter
       ,output       rec-full
      ) no-error.
    if error-status :error then do:
      return error return-value .
    end.
    assign
      v-rec-name = entry( 1, rec-full, {&delim-nws} )
      v-action = entry(2, rec-full, {&delim-nws})
    .
    CASE v-rec-name :
      when {&table_dis-card-type}
      then do:
        run proc-load-standart in p-imp-handle
          ( input {&table_dis-card-type}
            ,input '':U
            ,input (buffer buf_temp-dis-card-type:handle)
            ,input p-imp-handle
            ,input 0
            ,output v-curr-rowid
          ) no-error.
        if error-status :error then do:
          return error return-value .
        end.
        if v-action = "+delete" then do:
          find first buf_temp-dis-card-type where
                    rowid(buf_temp-dis-card-type) = v-curr-rowid.
          buf_temp-dis-card-type.action = integer({&hn-delete}).
        end.
      end.
      when {&table_dis-card-type-attr}
      then do:
        run proc-load-standart in p-imp-handle
          ( input {&table_dis-card-type-attr}
            ,input '':U
            ,input (buffer buf_temp-dis-card-type-attr:handle)
            ,input p-imp-handle
            ,input 0
            ,output v-curr-rowid
          ) no-error.
        if error-status :error then do:
          return error return-value .
        end.
        if v-action = "+delete" then do:
          find first buf_temp-dis-card-type-attr where
                    rowid(buf_temp-dis-card-type-attr) = v-curr-rowid.
          buf_temp-dis-card-type-attr.action = integer({&hn-delete}).
        end.
      end.
      when {&table_hist-nws-option}
      then do:
        run proc-load-standart in p-imp-handle
          ( input {&table_hist-nws-option}
            ,input '':U
            ,input (buffer buf_temp-hist-nws-option:handle)
            ,input p-imp-handle
            ,input 0
            ,output v-curr-rowid
          ) no-error.
        if error-status :error then do:
          return error return-value .
        end.
        if v-action = "+delete" then do:
          find first buf_temp-hist-nws-option where
                    rowid(buf_temp-hist-nws-option) = v-curr-rowid.
          buf_temp-hist-nws-option.action = integer({&hn-delete}).
        end.
      end.
      when {&table_rule-call-param}
      then do:
        run proc-load-standart in p-imp-handle
          ( input {&table_rule-call-param}
            ,input '':U
            ,input (buffer buf_temp-rule-call-param:handle)
            ,input p-imp-handle
            ,input 0
            ,output v-curr-rowid
          ) no-error.
        if error-status :error then do:
          return error return-value .
        end.
        if v-action = "+delete" then do:
          find first buf_temp-rule-call-param where
                    rowid(buf_temp-rule-call-param) = v-curr-rowid.
          buf_temp-rule-call-param.action = integer({&hn-delete}).
        end.
      end.
      when {&table_rule-by-call}
      then do:
        run proc-load-standart in p-imp-handle
          ( input {&table_rule-by-call}
            ,input '':U
            ,input (buffer buf_temp-rule-by-call:handle)
            ,input p-imp-handle
            ,input 0
            ,output v-curr-rowid
          ) no-error.
        if error-status :error then do:
          return error return-value .
        end.
        if v-action = "+delete" then do:
          find first buf_temp-rule-by-call where
                    rowid(buf_temp-rule-by-call) = v-curr-rowid.
          buf_temp-rule-by-call.action = integer({&hn-delete}).
        end.
      end.
      when {&table_rp-by-call}
      then do:
        run proc-load-standart in p-imp-handle
          ( input {&table_rp-by-call}
            ,input '':U
            ,input (buffer buf_temp-rp-by-call:handle)
            ,input p-imp-handle
            ,input 0
            ,output v-curr-rowid
          ) no-error.
        if error-status :error then do:
          return error return-value .
        end.
        if v-action = "+delete" then do:
          find first buf_temp-rp-by-call where
                    rowid(buf_temp-rp-by-call) = v-curr-rowid.
          buf_temp-rp-by-call.action = integer({&hn-delete}).
        end.
      end.
      when {&table_prop-ref-call}
      then do:
        run proc-load-standart in p-imp-handle
          ( input {&table_prop-ref-call}
            ,input '':U
            ,input (buffer buf_temp-prop-ref-call:handle)
            ,input p-imp-handle
            ,input 0
            ,output v-curr-rowid
          ) no-error.
        if error-status :error then do:
          return error return-value .
        end.
        if v-action = "+delete" then do:
          find first buf_temp-prop-ref-call where
                    rowid(buf_temp-prop-ref-call) = v-curr-rowid.
          buf_temp-prop-ref-call.action = integer({&hn-delete}).
        end.
      end.
      when {&table_dis-dct-rule}
      then do:
        run proc-load-standart in p-imp-handle
          ( input {&table_dis-dct-rule}
            ,input '':U
            ,input (buffer buf_temp-dis-dct-rule:handle)
            ,input p-imp-handle
            ,input 0
            ,output v-curr-rowid
          ) no-error.
        if error-status :error then do:
          return error return-value .
        end.
        if  v-action = "+delete" then do:
          find first buf_temp-dis-dct-rule where
                    rowid(buf_temp-dis-dct-rule) = v-curr-rowid.
          buf_temp-dis-dct-rule.action = integer({&hn-delete}).
        end.
      end.
      otherwise do:
        run waitfram-hide in this-procedure .
        message
          vss-workfile vss-revision vss-description skip
          "Не предусмотрен прием таблицы " v-rec-name skip
          "в составе команды" {&cmd-dct-send} skip
          view-as alert-box error .
        return error .
      end.

    END CASE.
  end. /*do counter*/

  run waitfram-show in this-procedure ( substitute("           Обновление информации по типу ДК: &1 эмитент &2"
                                                   , p-type
                                                   , p-emitent-host-code)
                                       ).
  for each buf_temp-dis-card-type
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
    find first buf_dis-card-type where
              buf_dis-card-type.emitent-host-code = buf_temp-dis-card-type.emitent-host-code
          and buf_dis-card-type.type = buf_temp-dis-card-type.type
          and buf_dis-card-type.host-code = buf_temp-dis-card-type.host-code
          and buf_dis-card-type.obj-type = buf_temp-dis-card-type.obj-type
          and buf_dis-card-type.obj-code = buf_temp-dis-card-type.obj-code no-error .
    if buf_temp-dis-card-type.host-code = 0
    and buf_temp-dis-card-type.obj-type = '':U
    and buf_temp-dis-card-type.obj-code = 0 then do:
      if not available buf_dis-card-type then do:
         create root_dis-card-type.
      end.
      buffer-copy buf_temp-dis-card-type to root_dis-card-type.
    end.
    else do:
      if buf_temp-dis-card-type.action = integer({&hn-delete}) then do:
        if not available buf_dis-card-type then do:
        end.
        else do:
          delete buf_Dis-card-type.
        end.
      end.
      else do:
        if not available buf_dis-card-type then do:
          create buf_dis-card-type.
        end.
        buffer-copy buf_temp-dis-card-type to buf_dis-card-type.
      end.
    end.
  end.
  for each buf_temp-dis-card-type-attr
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
    find first buf_dis-card-type-attr where
              buf_dis-card-type-attr.emitent-host-code = buf_temp-dis-card-type-attr.emitent-host-code
          and buf_dis-card-type-attr.type = buf_temp-dis-card-type-attr.type
          and buf_dis-card-type-attr.host-code = buf_temp-dis-card-type-attr.host-code
          and buf_dis-card-type-attr.obj-type = buf_temp-dis-card-type-attr.obj-type
          and buf_dis-card-type-attr.obj-code = buf_temp-dis-card-type-attr.obj-code
          and buf_dis-card-type-attr.attr-code = buf_temp-dis-card-type-attr.attr-code
          and buf_dis-card-type-attr.attr-value = buf_temp-dis-card-type-attr.attr-value
          no-error .
    if buf_temp-dis-card-type-attr.action = integer({&hn-delete}) then do:
      if not available buf_dis-card-type-attr then do:
      end.
      else do:
        delete buf_Dis-card-type-attr.
      end.
    end.
    else do:
      if not available buf_dis-card-type-attr then do:
          create buf_dis-card-type-attr.
      end.
      buffer-copy buf_temp-dis-card-type-attr to buf_dis-card-type-attr.
    end.

  end.
  for each buf_temp-hist-nws-option
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
    find first buf_hist-nws-option where
              buf_hist-nws-option.db-num = buf_temp-hist-nws-option.db-num
          and buf_hist-nws-option.hn-id  = buf_temp-hist-nws-option.hn-id
          no-error .
    if buf_temp-hist-nws-option.action = integer({&hn-delete}) then do:
      if not available buf_hist-nws-option then do:
      end.
      else do:
        delete buf_hist-nws-option.
      end.
    end.
    else do:
      if not available buf_hist-nws-option then do:
          create buf_hist-nws-option.
      end.
      buffer-copy buf_temp-hist-nws-option to buf_hist-nws-option.
    end.
  end.
  for each buf_temp-rp-by-call
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
    find first buf_rp-by-call where
              buf_rp-by-call.call#_id = buf_temp-rp-by-call.call#_id
          and buf_rp-by-call.profile_id = buf_temp-rp-by-call.profile_id
          and buf_rp-by-call.once-more = buf_temp-rp-by-call.once-more
          no-error .
    if buf_temp-rp-by-call.action = integer({&hn-delete}) then do:
      if not available buf_rp-by-call then do:
      end.
      else do:
        delete buf_rp-by-call.
      end.
    end.
    else do:
      if not available buf_rp-by-call then do:
          create buf_rp-by-call.
      end.
      buffer-copy buf_temp-rp-by-call to buf_rp-by-call.
    end.
  end.
  for each buf_temp-rule-by-call
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
    find first buf_rule-by-call where
              buf_rule-by-call.call#_id = buf_temp-rule-by-call.call#_id
          and buf_rule-by-call.codex_id = buf_temp-rule-by-call.codex_id
          and buf_rule-by-call.ruleset_id = buf_temp-rule-by-call.ruleset_id
          and buf_rule-by-call.order_id = buf_temp-rule-by-call.order_id  no-error .
    if buf_temp-rule-by-call.action = integer({&hn-delete}) then do:
      if not available buf_rule-by-call then do:
      end.
      else do:
        delete buf_rule-by-call.
      end.
    end.
    else do:
      if not available buf_rule-by-call then do:
          create buf_rule-by-call.
      end.
      buffer-copy buf_temp-rule-by-call to buf_rule-by-call.
    end.
  end.
  for each buf_temp-rule-call-param
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
    find first buf_rule-call-param where
              buf_rule-call-param.call#_id = buf_temp-rule-call-param.call#_id
          and buf_rule-call-param.codex_id = buf_temp-rule-call-param.codex_id
          and buf_rule-call-param.ruleset_id = buf_temp-rule-call-param.ruleset_id
          and buf_rule-call-param.order_id = buf_temp-rule-call-param.order_id
          and buf_rule-call-param.param-name = buf_temp-rule-call-param.param-name
          and buf_rule-call-param.p-index = buf_temp-rule-call-param.p-index    no-error .
    if buf_temp-rule-call-param.action = integer({&hn-delete}) then do:
      if not available buf_rule-call-param then do:
      end.
      else do:
        delete buf_rule-call-param.
      end.
    end.
    else do:
      if not available buf_rule-call-param then do:
          create buf_rule-call-param.
      end.
      buffer-copy buf_temp-rule-call-param to buf_rule-call-param.
    end.
  end.
  for each buf_temp-prop-ref-call
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
    find first buf_prop-ref-call where
              buf_prop-ref-call.call#_id = buf_temp-prop-ref-call.call#_id
          and buf_prop-ref-call.dt-code = buf_temp-prop-ref-call.dt-code no-error .
    if buf_temp-prop-ref-call.action = integer({&hn-delete}) then do:
      if not available buf_prop-ref-call then do:
      end.
      else do:
        delete buf_prop-ref-call.
      end.
    end.
    else do:
      if not available buf_prop-ref-call then do:
          create buf_prop-ref-call.
      end.
      buffer-copy buf_temp-prop-ref-call to buf_prop-ref-call.
    end.
  end.
  for each buf_temp-dis-dct-rule
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
    find first buf_dis-dct-rule where
              buf_dis-dct-rule.type = buf_temp-dis-dct-rule.type
          and buf_dis-dct-rule.emitent-host-code = buf_temp-dis-dct-rule.emitent-host-code
          and buf_dis-dct-rule.host-code = buf_temp-dis-dct-rule.host-code
          and buf_dis-dct-rule.obj-type = buf_temp-dis-dct-rule.obj-type
          and buf_dis-dct-rule.obj-code = buf_temp-dis-dct-rule.obj-code
          and buf_dis-dct-rule.discnt-role = buf_temp-dis-dct-rule.discnt-role
          and buf_dis-dct-rule.nonunique = buf_temp-dis-dct-rule.nonunique
          no-error .
    if buf_temp-dis-dct-rule.action = integer({&hn-delete}) then do:
      if not available buf_dis-dct-rule then do:
      end.
      else do:
        delete buf_dis-dct-rule.
      end.
    end.
    else do:
      if not available buf_dis-dct-rule then do:
          create buf_dis-dct-rule.
      end.
      buffer-copy buf_temp-dis-dct-rule to buf_dis-dct-rule.
    end.
  end.
  find first buf_temp-dis-card-type where
            buf_temp-dis-card-type.host-code = 0
        and buf_temp-dis-card-type.obj-type = ''
        and buf_temp-dis-card-type.obj-code = 0 no-error .
  if available buf_temp-dis-card-type
  and buf_temp-dis-card-type.action = integer({&hn-delete}) then do:
    delete root_dis-card-type .
  end.
  else do:
    release root_dis-card-type .
  end.
  run waitfram-hide in this-procedure .
end. /*doe*/

procedure write-to-log : /*не удалять!!!*/
define input parameter p-mess as character no-undo .

  do
  on error undo, return error
  :

  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input p-mess).
  end.

end procedure. /* write-to-log */