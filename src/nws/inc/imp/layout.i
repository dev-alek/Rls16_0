/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Разбор раскладки в новостях

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/26/08
Author: Bakhtadze Natalya
Creation date: 09/26/08


*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".


DO counter = 1 TO l-counter
on error  undo, return error
on endkey undo, return error :

  { nws/imps-nws.i rec-full }

  assign
    rec-name = entry( 1, rec-full, {&delim-nws} )
    .

  {&test-count}

  CASE rec-name :
    when {&table_layout-elem-rule} then do:
      create locb-layout-elem-rule.
      { nws/impl-nws.i "layout-elem-rule" "locb-" }
    end.
    when {&table_rule-by-call} then do:
      create locb-rule-by-call.
      { nws/impl-nws.i "rule-by-call" "locb-" }
    end.
    when {&table_rule-call-param} then do:
      create locb-rule-call-param.
      { nws/impl-nws.i "rule-call-param" "locb-" }
    end.


    otherwise do:
      message "Не предусмотрен прием таблицы " rec-name skip
              "в составе раскалдки."
              view-as alert-box error.
      return error.
    end.
  END CASE.
end.

run  layouth_create-layout_h  in this-procedure (
                                                input {&update}
                                              ,input wt-layout.layout-id
                                              ,buffer tb-layout
                                              ,output v-chip-num).

if wt-layout.is-default = integer({&layout-ordinal})
or wt-layout.is-default = integer({&layout-default})
then do:
  find first buf2_layout share-lock where
            buf2_layout.layout-type = wt-layout.layout-type
        and buf2_layout.device-type = wt-layout.device-type
        and buf2_layout.is-default = integer({&layout-mandatory}) no-error.
  if available buf2_layout then do:
    for each buf2_layout-elem-rule no-lock where
            buf2_layout-elem-rule.layout-id = buf2_layout.layout-id
    on error  undo, return error:
      find first locb-layout-elem-rule where
               locb-layout-elem-rule.layout-id = wt-layout.layout-id
          and locb-layout-elem-rule.mode-id = buf2_layout-elem-rule.mode-id
          and locb-layout-elem-rule.widget-id = buf2_layout-elem-rule.widget-id no-error.
      if not available locb-layout-elem-rule
      or locb-layout-elem-rule.rule_id <> buf2_layout-elem-rule.rule_id then do:
        if available locb-layout-elem-rule then do:
          assign
          locb-layout-elem-rule.sts = integer({&deleted-status-int})
          .
        end.
        wt-layout.sts = (if wt-layout.sts <> integer({&to-delete-status-int})
                        then integer({&blocked-status-int})
                        else wt-layout.sts).
      end.
    end.
  end.
end.


for each locb-layout-elem-rule where locb-layout-elem-rule.layout-id = wt-layout.layout-id
on error  undo, return error:

  find first buf_wi-mode no-lock where
          buf_wi-mode.mode-type = {&wi-mode-IBS-TH-pos}
      and buf_wi-mode.mode-id = locb-layout-elem-rule.mode-id no-error.
  if not available buf_wi-mode then do:
    assign
    locb-layout-elem-rule.sts = integer({&deleted-status-int})
    wt-layout.sts = (if wt-layout.sts <> integer({&to-delete-status-int})
                     then integer({&blocked-status-int})
                     else wt-layout.sts)
    .
  end.
  find first buf_layout-elem no-lock where
          buf_layout-elem.layout-type = wt-layout.layout-type
      and buf_layout-elem.device-type = wt-layout.device-type
      and buf_layout-elem.mode-id = locb-layout-elem-rule.mode-id
      and buf_layout-elem.widget-id = locb-layout-elem-rule.widget-id
      no-error.
  if not available buf_layout-elem
  or (wt-layout.is-default = integer({&layout-ordinal})
      and
      buf_layout-elem.elem-type = integer({&lelem-type-programmable})
      )
  then do:
    assign
    locb-layout-elem-rule.sts = integer({&deleted-status-int})
    wt-layout.sts = (if wt-layout.sts <> integer({&to-delete-status-int})
                     then integer({&blocked-status-int})
                     else wt-layout.sts)
    .
  end.
  v-cmp = yes.
  find first buf_layout-elem-rule where
            buf_layout-elem-rule.layout-id = locb-layout-elem-rule.layout-id
        and buf_layout-elem-rule.mode-id = locb-layout-elem-rule.mode-id
        and buf_layout-elem-rule.widget-id = locb-layout-elem-rule.widget-id no-error.
  if not available buf_layout-elem-rule then do:
    v-cmp = no.
    create buf_layout-elem-rule.
  end.
  else do:
    buffer-compare buf_layout-elem-rule to locb-layout-elem-rule case-sensitive  save result in v-cmp.
  end.
  if not v-cmp then do:
    run  layouth_create-layout-elem-rule_h  in this-procedure (
                                                    input (if new (buf_layout-elem-rule) then {&add-def} else {&update})
                                                  ,input locb-layout-elem-rule.layout-id
                                                  ,input locb-layout-elem-rule.mode-id
                                                  ,input locb-layout-elem-rule.widget-id
                                                  ,buffer buf_layout-elem-rule
                                                  ,input v-chip-num).
    buffer-copy locb-layout-elem-rule to buf_layout-elem-rule.
  end.
    for each locb-rule-by-call where
         locb-rule-by-call.call_id = locb-layout-elem-rule.uniq-key-rec
  on error  undo, return error:
     v-cmp = yes.
     find first buf_rule-by-call where
              buf_rule-by-call.call_id = locb-rule-by-call.call_id
          and buf_rule-by-call.codex_id = locb-rule-by-call.codex_id
          and buf_rule-by-call.ruleset_id = locb-rule-by-call.ruleset_id
          and buf_rule-by-call.order_id = locb-rule-by-call.order_id no-error.
     if not available buf_rule-by-call then do:
       v-cmp = no.
       create buf_rule-by-call.
       buffer-copy locb-rule-by-call to buf_rule-by-call.
     end.
     else do:
       buffer-compare locb-rule-by-call to buf_rule-by-call case-sensitive  save result in v-cmp.
     end.
     if v-cmp = no then do:
        buffer-copy locb-rule-by-call to buf_rule-by-call.
     end.
  end.
  for each locb-rule-call-param where
         locb-rule-call-param.call_id = locb-layout-elem-rule.uniq-key-rec
  on error  undo, return error:
     v-cmp = yes.
     find first buf_rule-call-param where
              buf_rule-call-param.call_id = locb-rule-call-param.call_id
          and buf_rule-call-param.codex_id = locb-rule-call-param.codex_id
          and buf_rule-call-param.ruleset_id = locb-rule-call-param.ruleset_id
          and buf_rule-call-param.order_id = locb-rule-call-param.order_id
          and buf_rule-call-param.param-name = locb-rule-call-param.param-name
          and buf_rule-call-param.p-index = locb-rule-call-param.p-index
          no-error.
     if not available buf_rule-call-param then do:
       v-cmp = no.
       create buf_rule-call-param.
       buffer-copy locb-rule-call-param to buf_rule-call-param.
     end.
     else do:
       buffer-compare locb-rule-call-param to buf_rule-call-param case-sensitive  save result in v-cmp.
     end.
     if v-cmp = no then do:
        run  layouth_create-rule-call-param_h  in this-procedure (
                                                        input (if new(buf_rule-call-param)
                                                               then {&add-def}
                                                               else {&update})
                                                      ,input locb-rule-call-param.call#_id
                                                      ,input locb-rule-call-param.codex_id
                                                      ,input locb-rule-call-param.ruleset_id
                                                      ,input locb-rule-call-param.order_id
                                                      ,input locb-rule-call-param.param-name
                                                      ,input locb-rule-call-param.p-index
                                                      ,input locb-rule-call-param.call_id
                                                      ,buffer buf_rule-call-param
                                                      ,input v-chip-num).
        buffer-copy locb-rule-call-param to buf_rule-call-param.
     end.
  end. /*for each locb-rule-call-param where*/
  for each buf_rule-call-param where
         buf_rule-call-param.call_id = locb-layout-elem-rule.uniq-key-rec
  on error  undo, return error:
     v-cmp = yes.
     find first locb-rule-call-param where
              locb-rule-call-param.call_id = buf_rule-call-param.call_id
          and locb-rule-call-param.codex_id = buf_rule-call-param.codex_id
          and locb-rule-call-param.ruleset_id = buf_rule-call-param.ruleset_id
          and locb-rule-call-param.order_id = buf_rule-call-param.order_id
          and locb-rule-call-param.param-name = buf_rule-call-param.param-name
          and locb-rule-call-param.p-index = buf_rule-call-param.p-index
          no-error.
     if not available locb-rule-call-param then do:
        run  layouth_create-rule-call-param_h  in this-procedure (
                                                        input {&deletion}
                                                      ,input buf_rule-call-param.call#_id
                                                      ,input buf_rule-call-param.codex_id
                                                      ,input buf_rule-call-param.ruleset_id
                                                      ,input buf_rule-call-param.order_id
                                                      ,input buf_rule-call-param.param-name
                                                      ,input buf_rule-call-param.p-index
                                                      ,input buf_rule-call-param.call_id
                                                      ,buffer buf_rule-call-param
                                                      ,input v-chip-num).
     end.
  end. /*for each buf_rule-call-param where*/
end. /*for each locb-layout-elem-rule where locb-layout-elem-rule.layout-id = wt-layout.layout-id*/

for each buf_layout-elem-rule where buf_layout-elem-rule.layout-id = wt-layout.layout-id
on error  undo, return error
:

  v-cmp = yes.
  find first locb-layout-elem-rule where
            locb-layout-elem-rule.layout-id = buf_layout-elem-rule.layout-id
        and locb-layout-elem-rule.mode-id = buf_layout-elem-rule.mode-id
        and locb-layout-elem-rule.widget-id = buf_layout-elem-rule.widget-id no-error.
  if not available buf_layout-elem-rule then do:
    run  layouth_create-layout-elem-rule_h  in this-procedure (
                                                    input {&deletion}
                                                  ,input buf_layout-elem-rule.layout-id
                                                  ,input buf_layout-elem-rule.mode-id
                                                  ,input buf_layout-elem-rule.widget-id
                                                  ,buffer buf_layout-elem-rule
                                                  ,input v-chip-num).

    for each buf_rule-by-call where
            buf_rule-by-call.call_id = buf_layout-elem-rule.uniq-key-rec
    on error  undo, return error:
      delete buf_rule-by-call.
    end.
    for each buf_rule-call-param where
            buf_rule-call-param.call_id = buf_layout-elem-rule.uniq-key-rec
    on error  undo, return error:
        run  layouth_create-rule-call-param_h  in this-procedure (
                                                        input {&deletion}
                                                      ,input buf_rule-call-param.call#_id
                                                      ,input buf_rule-call-param.codex_id
                                                      ,input buf_rule-call-param.ruleset_id
                                                      ,input buf_rule-call-param.order_id
                                                      ,input buf_rule-call-param.param-name
                                                      ,input buf_rule-call-param.p-index
                                                      ,input buf_rule-call-param.call_id
                                                      ,buffer buf_rule-call-param
                                                      ,input v-chip-num).

      delete buf_rule-by-call.
    end.
    delete buf_layout-elem-rule.
  end.
end. /*for each buf_layout-elem-rule where buf_layout-elem-rule.layout-id = wt-layout.layout-id*/

if not available tb-layout then do:
  create tb-layout.
end.

/* обновляем раскладку */
buffer-copy wt-layout to tb-layout.

/* ---------------------------- почистим за собой -------------------------------- */
for each locb-layout-elem-rule
on error  undo, return error
:
  delete locb-layout-elem-rule.
end.

for each locb-rule-call-param
on error  undo, return error
:
  delete locb-rule-call-param.
end.

for each locb-rule-by-call
on error  undo, return error
:
  delete locb-rule-by-call.
end.



/* $Workfile$ e n d */