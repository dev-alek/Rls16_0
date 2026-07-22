/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Прием dis-rule по СПН

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/19/05
Author: Bakhtadze Natalya
Creation date: 10/19/05

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&scop check-fields  "discnt-value"

DO counter = 1 TO l-counter
on error  undo, return error
on endkey undo, return error :

  { nws/imps-nws.i rec-full }

  assign
    rec-name = entry( 1, rec-full, {&delim-nws} )
    .

  {&test-count}

  CASE rec-name :
    when {&table_dis-rule} then do:
      create locb1-dis-rule.
      { nws/impl-nws.i "dis-rule" "locb1-" }
    end.

    otherwise do:
      message "Не предусмотрен прием таблицы " rec-name skip
              "в составе истории чека"
              view-as alert-box error.
      return error.
    end.
  END CASE.
end.



do
on error  undo, return error
on endkey undo, return error
on stop   undo, return error :

  if (available tb-dis-rule
      and tb-dis-rule.rule-num = wt-dis-rule.rule-num
      and (tb-dis-rule.sts  = wt-dis-rule.sts
          /*статус совпадает*/
          OR
          wt-dis-rule.sts <> integer({&current-status-int})
          /*статус не ИСПОЛЬЗУЕТСЯ*/
          ))
  or wt-dis-rule.lvl-num = 0
  then do:
    v-ok = yes. /* зачем чего-то делать, если у нас ничего не меняется */
  end.
  if not v-ok then do:
    find first template_dis-rule no-lock where
              template_dis-rule.rule-num = wt-dis-rule.templ-rl-root no-error.
    if not available template_dis-rule then do:
      run write-to-log( substitute("Не найден шаблон №&1 для правила скидок №&2"
                                  , wt-dis-rule.templ-rl-root
                                  , wt-dis-rule.rule-num)).
      return error .
    end.
    if not can-find(first ub.drt-prop no-lock where
                         ub.drt-prop.templ-rl-root = template_dis-rule.templ-rl-root
                     and ub.drt-prop.upper-prop-code = '':U
                     and ub.drt-prop.prop-code = 'uniq':U) then do:
      v-ok = yes.
    end.
    else do:
      v-uniq-field = {&space-char} .
    end.
  end.
  if not v-ok then do:
    /*найдем поле для uniq*/
    do jj = 1 to num-entries({&check-fields}):
      assign
      v-curr-field = entry(jj, {&check-fields})
      .
      if can-find(first ub.drt-prop no-lock where
                        ub.drt-prop.templ-rl-root = template_dis-rule.templ-rl-root
                    and ub.drt-prop.upper-prop-code = '':U
                    and ub.drt-prop.prop-code = v-curr-field + 'uniq=':U
                    and ub.drt-prop.property-value  = "yes") then do:
        assign
        v-uniq-field = v-uniq-field + {&comma-char} + v-curr-field.
      end. /*if can-find(first ub.drt-prop no-lock where*/
    end. /*do jj*/
    v-uniq-field = trim(v-uniq-field, {&comma-char}).
    if wt-dis-rule.sts = integer({&current-status-int}) then do:
&scop write-log-dis-rule-ubd ~
          run write-to-log( substitute("Выключено правило скидки №&1, так как получено новое активное правило №&2&3" + ~
                                        "Тип правила: &4"                                                               ~
                                        , buf_dis-rule.rule-num                                                         ~
                                        , wt-dis-rule.rule-num                                                          ~
                                        , ~{&new-line~}                                                                 ~
                                        , template_dis-rule.des))

&scop write-log-dis-rule-gbd ~
          run write-to-log( substitute("Выключено полученное правило скидки №&1, так как имеется активное правило №&2&3" + ~
                                        "Тип правила: &4"                                                               ~
                                        , wt-dis-rule.rule-num                                                          ~
                                        , buf_dis-rule.rule-num                                                         ~
                                        , ~{&new-line~}                                                                 ~
                                        , template_dis-rule.des))

      assign
      h_wt-dis-rule = buffer wt-dis-rule:handle
      h_buf_dis-rule = buffer buf_dis-rule:handle
      .
      _dis-rule:
      for each buf_dis-rule where buf_dis-rule.upper-rule-num   = wt-dis-rule.upper-rule-num
                                      and buf_dis-rule.host-code = wt-dis-rule.host-code
                                      and buf_dis-rule.obj-type = wt-dis-rule.obj-type
                                      and buf_dis-rule.obj-code = wt-dis-rule.obj-code
                                      and buf_dis-rule.sts   = integer({&current-status-int})
        on error undo, return error return-value:
        if buf_dis-rule.rule-num = wt-dis-rule.rule-num then next _dis-rule.
        if buf_dis-rule.sts = integer({&deleted-status-int}) then nEXT _dis-rule.
        if v-uniq-field = '':U then do:
          if g#db-num = 0 then do:
            /*принимаем из УБД - выключаем то что пришло*/
            assign
            wt-dis-rule.sts = integer({&deleted-status-int})
            .
            {&write-log-dis-rule-gbd}.
          end.
          else do:
            /*принимаем из ГБД - выключаем те что у нас лежат*/
            assign
            buf_dis-rule.sts = integer({&deleted-status-int})
            .
            {&write-log-dis-rule-ubd}.
          end.
          leave _dis-rule.
        end.
        do jj = 1 to num-entries(v-uniq-field):
          if h_wt-dis-rule:buffer-field(entry(jj, v-uniq-field)):buffer-value = h_buf_dis-rule:buffer-field(entry(jj, v-uniq-field)):buffer-value
          then do:
            if g#db-num = 0 then do:
              /*принимаем из УБД - выключаем то что пришло*/
              assign
              wt-dis-rule.sts = integer({&deleted-status-int})
              .
              {&write-log-dis-rule-gbd}.
            end.
            else do:
              /*принимаем из ГБД - выключаем те что у нас лежат*/
              assign
              buf_dis-rule.sts = integer({&deleted-status-int})
              .
              {&write-log-dis-rule-ubd}.
            end.
          end.
        end.
      end. /*for each buf_dis-rule w*/
    end. /*if wt-dis-rule.sts = integer({&current-status-int}) then do:*/
  end. /*if not v-ok then do:*/
  if not available tb-dis-rule then do:
    create tb-dis-rule.
  end.
/* обновляем документ */
  buffer-copy wt-dis-rule to tb-dis-rule.
end.

/* ------------------------------- dis-rule --------------------------------------------- */
if wt-dis-rule.rule-num > {&max-num-dr-template} then do:
  for each locb1-dis-rule where
          locb1-dis-rule.upper-rule-num = wt-dis-rule.rule-num
      no-lock
  on error  undo, return error substitute( "&1&2&3", return-value, {&new-line}, error-status :get-message (1))
  :
    find first buf1_dis-rule exclusive-lock where
              buf1_dis-rule.rule-num = locb1-dis-rule.rule-num no-error.
    if not available buf1_dis-rule then do:
      create buf1_dis-rule.
    end.
    buffer-copy locb1-dis-rule to buf1_dis-rule.
  end.
  for each buf1_dis-rule where
          buf1_dis-rule.upper-rule-num = wt-dis-rule.rule-num
  on error  undo, return error substitute( "&1&2&3", return-value, {&new-line}, error-status :get-message (1))
  :
    find first locb1-dis-rule exclusive-lock where
              locb1-dis-rule.rule-num = buf1_dis-rule.rule-num no-error.
    if not available locb1-dis-rule then do:
      if wt-dis-rule.upper-rule-num <> 0 then do:
        delete buf1_dis-rule.
      end.
    end.
  end.

end.


/* ------------------------ почистим за собой ---------------------------------------------- */

for each locb1-dis-rule
on error  undo, return error
:
  delete locb1-dis-rule.
end.
for each buf_dis-cfg-rule no-lock where
        buf_dis-cfg-rule.templ-rl-root = tb-dis-rule.templ-rl-root
    and buf_dis-cfg-rule.time-templ-rl-root = tb-dis-rule.time-templ-rl-root:
  if buf_dis-cfg-rule.table-name = {&table_dis-gds-rule}
  and lookup(buf_dis-cfg-rule.pos-type, {&cd-type-codes-real}) > 0 then do:
    v-gds-send = yes.
  end.
  if buf_dis-cfg-rule.table-name = {&table_dis-dc-rule}
  and lookup(buf_dis-cfg-rule.pos-type, {&cd-type-codes-real}) > 0 then do:
    v-dc-send = yes.
  end.
  if v-gds-send
  or v-dc-send then leave.
end.
if v-gds-send then do:
  for each buf_dis-gds-rule no-lock where
          buf_Dis-gds-rule.rule-num = tb-dis-rule.rule-num:
    if lookup(buf_dis-gds-rule.pos-type, {&cd-type-codes-real}) > 0 then do:
      run fill-g-list in p-imp-handle ( input buf_dis-gds-rule.gds-code
                                      ,input buf_dis-gds-rule.obj-type
                                      ,input buf_dis-gds-rule.obj-code
                                      ).
    end.
  end.
end.
if v-dc-send then do:
  for each buf_dis-dc-rule no-lock where
          buf_dis-dc-rule.rule-num = tb-dis-rule.rule-num,
      first buf_Dis-card no-lock where
           buf_Dis-card.d-card = buf_dis-dc-rule.d-card:
    run fill-dc-list in p-imp-handle ( buffer buf_Dis-card) .
  end.

end.


/* $Workfile$ e n d */