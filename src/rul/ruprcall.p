block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Сохранение привязки профайла, правил, параметров вызова правил к точке вызова

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/07/07
Author: Bakhtadze Natalya
Creation date: 03/07/07

*/

define input parameter p-call-type as character no-undo .
define input parameter p-call-id as character no-undo .
define input parameter p-data-completeness  as character no-undo .
define input parameter p-cmd-proc-handle as handle no-undo .
define input parameter p-cmd-code as integer no-undo .
define temp-table tt0-rp-by-call no-undo like ub.rp-by-call.
define temp-table tt0-rule-by-call no-undo like ub.rule-by-call.
define temp-table tt0-rule-call-param no-undo like ub.rule-call-param.
define input parameter table for tt0-rp-by-call.
define input parameter table for tt0-rule-by-call.
define input parameter table for tt0-rule-call-param.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Сохранение привязки профайла, правил, параметров вызова правил".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ rul/rulereus.i }
{ gbl/key-rec.i }
{ cmp/library.i }
{ rul/calldscr.i }
{ gbl/who-lk.i }
{ cmp/strcodec.i }
{ gbl/chk-entr.i }

define variable v-call#-id as integer no-undo .
DEFINE VARIABLE v-value-character AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-value-integer AS integer NO-UNDO.
DEFINE VARIABLE v-value-decimal AS decimal NO-UNDO.
DEFINE VARIABLE v-value-logical AS logical NO-UNDO.
DEFINE VARIABLE v-value-date AS date NO-UNDO.
define variable v-ok as logical no-undo .
define variable v-run-bush-command as logical no-undo .
define variable v-cmp as logical no-undo .
define variable v-cmp-loc as logical no-undo .
define variable v-old-can-run as logical no-undo .
define variable v-old-can-calc as logical no-undo .
define variable v-create-command as logical no-undo .
define variable v-command as character no-undo .
define variable v-field-list as character no-undo .
define variable v-value-list as character no-undo .
define variable v-par-val as character no-undo .
define variable v-par-type as character no-undo .
define variable v-rec-ord as integer no-undo .
define variable v-rcp-key-rec as character no-undo .
define variable v-db-list as character no-undo .


define buffer buf_db for ub.db .
define buffer buf_rp-by-call for ub.rp-by-call.
define buffer buf_rule-by-call for ub.rule-by-call.
define buffer buf_rule-call-param for ub.rule-call-param.
define buffer buf_rule-profile for ub.rule-profile.
define buffer buf_rule for ub.rule.
define buffer buf_ruledict for ub.ruledict.
define buffer buf_ruledict-param for ub.ruledict-param.
define buffer buf_tt0-rule-call-param for tt0-rule-call-param.
define temp-table temp-prop-ref-call  no-undo like ub.prop-ref-call.
define temp-table temp-uniq-key no-undo
field key-rec as character
index pi is unique primary key-rec
.


/*удаление p-cmd-proc-handle в случае ошибки будем делать в вызывающей процедуре*/

&glob add-dump ~
run add-dump in p-cmd-proc-handle                                                                            ~
  (input p-cmd-code                                                                                          ~
  ,input ~{&table__~}                                                                                        ~
  ,input ~{&action__~}                                                                                       ~
  ,input ~{&buffer-handle~}                                                                                  ~
  ,input '':U                                                                                                ~
  ,output v-rec-ord                                                                                          ~
  ) no-error .                                                                                               ~
if error-status :error                                                                                       ~
then do:                                                                                                     ~
  if v-create-command then delete procedure p-cmd-proc-handle.                                               ~
  undo _main, return error substitute("&1 &2 &3&4Ошибка при добавлении записи &5 в команду с кодом &6&4&8&4&9&4" ~
                                      ,vss-workfile                                                          ~
                                      ,vss-revision                                                          ~
                                      ,vss-description                                                       ~
                                      ,~{&new-line~}                                                         ~
                                      ,~{&table__~}                                                          ~
                                      ,p-cmd-code                                                            ~
                                      ,error-status:get-message(1)                                           ~
                                      ,return-value                                                          ~
                                      ) .                                                                    ~
end

_main:
do
on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
:
  assign
  v-run-bush-command = valid-handle(p-cmd-proc-handle).

  if v-call#-id = 0 then do:
    run rul/g-callid.p ( input p-call-type
                        ,input p-call-id
                        ,output v-call#-id).
  end.
  if not v-run-bush-command then do:
    if p-cmd-code = 0 then do:
      v-create-command = yes.
      run  gen-key-fv in this-procedure (
                                          input p-call-id
                                         ,output v-field-list
                                         ,output v-value-list).
      case p-call-type:
        when {&table_dis-card-type} then do:
          assign
          v-command =  substitute("&2&1&3&1&4"
                                , {&delim-cmd}
                                , {&cmd-dct-send}
                                , integer(entry(lookup("emitent-host-code", v-field-list, {&delim-key}), v-value-list, {&delim-key}))
                                , entry(lookup("type", v-field-list, {&delim-key}), v-value-list, {&delim-key})
                                ).
        end.
        when {&table_goods}
        or
        when {&table_clients}
        or
        when {&table_gds-grp}
        or
        when {&table_cli-grp}
        or
        when {&thref}
        or
        when {&edoc}
        or
        when {&rep}
        or
        when {&table_chk-doc} + "_" + {&cd-type-ibs-th}
        or
        when {&table_chk-doc} + "_" + {&cd-type-ibs-th-mob}
        or
        when {&ord}
        then do:
          if p-call-type = {&rep}
          or p-call-type = {&ord}
          then do:
            if entry(1, p-call-id, {&delim-key}) = {&table_schedule} then do:
              define variable v-cre-db-num as integer no-undo .
              v-cre-db-num =  integer(entry(lookup("cre-db-num", v-field-list, {&delim-key}), v-value-list, {&delim-key})).
              if v-cre-db-num > 0
              then do:
                if g#db-num > 0 then do:
                  v-db-list = string(0).
                end.
                else do:
                  v-db-list = string(v-cre-db-num).
                end.
              end.
              else do:
                /*не шлем никуда*/
                v-create-command = no.
              end.
            end.
          end.
          if v-create-command then do:
          assign
            v-command =  substitute("&2&1&3&1"
                                , {&delim-cmd}
                                  , {&cmd-rum-send}
                                ,  str-encode( p-call-id
                                       , "" /*p-encode-char*/
                                       , {&delim-key})
                                ).
        end.
        end.
      end case.
      if v-create-command then do:
      /* инициализируем библиотеку формирования команды */
      run nws/cmd-bush.p persistent set p-cmd-proc-handle no-error .
      if error-status :error
      then do:
        delete procedure p-cmd-proc-handle .
        message
        substitute("&1 &2 &3&4Ошибка при запуске процедуры cmd-bush.p&4" +
                                            "&5&4&6"
                                            ,vss-workfile
                                            ,vss-revision
                                            ,vss-description
                                            ,{&new-line}
                                            ,error-status:get-message(1)
                                            ,return-value ).
        undo _main, return error.
      end.
      if g#db-num = 0 then do:
        for each buf_db no-lock
        where buf_db.db-num > 0
        :
          assign
          v-db-list = v-db-list + {&delim-nws} + string(buf_db.db-num).
        end.
        v-db-list = trim(v-db-list, {&delim-nws}).
      end.
      else do:
        v-db-list = '0'.
      end.
      run begin-create-command in p-cmd-proc-handle
        (input v-command /* p-command-name */
          ,input v-db-list               /* p-db-list      */
        ,output p-cmd-code        /* p-command-code */
        ) no-error.
      if error-status :error
      then do:
        message
        vss-workfile vss-revision vss-description skip
        substitute( "Ошибка при создании команды &1", {&cmd-dct-send} ) skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
        delete procedure p-cmd-proc-handle .
        undo _main, return error return-value .
      end.
      v-run-bush-command = yes.
      end. /*if v-create-command*/
    end.
  end.
  if lookup({&table_rp-by-call}, p-data-completeness) > 0 then do:
    for each buf_rp-by-call where
              buf_rp-by-call.call_id = p-call-id
      on ERROR UNDO _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
      ON STOP undo _MAIN, return error '':u:
      find first tt0-rp-by-call no-lock where
                tt0-rp-by-call.call_id = p-call-id
            and tt0-rp-by-call.profile_id = buf_rp-by-call.profile_id
            and tt0-rp-by-call.once-more = buf_rp-by-call.once-more  no-error.
      if not available tt0-rp-by-call then do:
        if v-run-bush-command then do:
&scop table__  ~{&table_rp-by-call~}
&scop action__ '+delete'
&scop buffer-handle buffer buf_rp-by-call:handle
          {&add-dump}.
        end.
        /*надо стереть rule-by-call и rule-call-param*/
        run delete-from-rp-by-call in this-procedure ( input buf_rp-by-call.call_id
                                                      ,input buf_rp-by-call.profile_id
                                                      ,input buf_rp-by-call.once-more) .
        delete buf_rp-by-call.
      end.
    end.
    for each tt0-rp-by-call
    where tt0-rp-by-call.call_id = p-call-id
    on ERROR UNDO _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
    ON STOP undo _MAIN, return error '':u:
      v-cmp-loc = yes.

      find first buf_rp-by-call where
                buf_rp-by-call.call_id = tt0-rp-by-call.call_id
            and buf_rp-by-call.profile_id = tt0-rp-by-call.profile_id
            and buf_rp-by-call.once-more = tt0-rp-by-call.once-more  no-error .
      if not available buf_rp-by-call then do:
        find first buf_rule-profile no-lock where
                  buf_rule-profile.profile_id = tt0-rp-by-call.profile_id no-error.
        if not available buf_rule-profile then do:
          UNDO _main, return error substitute( "&1. Не найден профайл правил с id &2", vss-workfile, tt0-rp-by-call.profile_id).
        end.
        if buf_rule-profile.param-code <> '':U then do:
          /*проверим параметр*/

          if buf_rule-profile.param-code = 'sys-key' then do:
            { gbl/currsysk.i
              v-par-val
              no-error
            }
            if error-status:error then do:
              undo _main, return error
              substitute("Ошибка при определении значения конфигурационного параметра &1,&2" +
                          "который должен быть включен для работы профайла &3"
                          ,buf_rule-profile.param-code
                          ,{&new-line}
                          ,buf_rule-profile.profile_id).
            end.
          end.
          else do:
            { gbl/conf-rd.i
              buf_rule-profile.param-code
              "''"
              "''"
              0
              "''"
              "''"
              "''"
              no
              v-par-val
              v-par-type
              no-error
            }
            if error-status:error then do:
              undo _main, return error
              substitute("Ошибка при определении значения конфигурационного параметра &1,&2" +
                          "который должен быть включен для работы профайла &3"
                          ,buf_rule-profile.param-code
                          ,{&new-line}
                          ,buf_rule-profile.profile_id).
            end.
          end.
          if (buf_rule-profile.param-code = 'sys-key'
          and check-entry-with-mask(v-par-val, buf_rule-profile.param-value, {&delim-par}) = no
          and not (buf_rule-profile.param-code = 'sys-key'
                      and
                      v-par-val = 'IBS')
                )
              or (buf_rule-profile.param-code <> 'sys-key'
              and lookup(v-par-val, buf_rule-profile.param-value, {&delim-par}) = 0)
          then do:
              undo _main, return error
              substitute("Значения конфигурационного параметра &1=&2,&3" +
                          "что не удовлетворяет условиям работы профайла &4"
                          ,buf_rule-profile.param-code
                          ,v-par-val
                          ,{&new-line}
                          ,buf_rule-profile.profile_id).
          end.
        end. /*if buf_rule-profile.param-code <> '':U then do:*/
        if v-call#-id = 0 then do:
          run rul/g-callid.p ( input p-call-type
                              ,input p-call-id
                              ,output v-call#-id).
        end.
        create buf_rp-by-call.
        assign
        buf_rp-by-call.call_id = tt0-rp-by-call.call_id
        buf_rp-by-call.call#_id = v-call#-id
        buf_rp-by-call.profile_id = tt0-rp-by-call.profile_id
        buf_rp-by-call.once-more = tt0-rp-by-call.once-more
        buf_rp-by-call.ps = tt0-rp-by-call.ps
        buf_rp-by-call.parent-profile_id = tt0-rp-by-call.parent-profile_id
        buf_rp-by-call.parent-once-more = tt0-rp-by-call.parent-once-more
        .
        assign
        v-cmp-loc = no
        .

      end.
      else do:
        buffer-compare tt0-rp-by-call to
        buf_rp-by-call save result in v-cmp-loc.
        if not v-cmp-loc then
        do:
           assign buf_rp-by-call.ps = tt0-rp-by-call.ps
           .

        end.
      end.
      if not v-cmp-loc and v-run-bush-command then do:
&scop table__  ~{&table_rp-by-call~}
&scop action__ '+update'
&scop buffer-handle buffer buf_rp-by-call:handle
          {&add-dump}.

      end. /*      if not v-cmp-loc and v-run-bush-command then do:*/
    end. /*for each tt0-rp-by-call*/
  end. /*if lookup({&table_rp-by-call}, p-data-completeness) > 0 then do:*/
  define buffer on_tt0-rule-by-call for tt0-rule-by-call.
  define buffer on_buf_rule-by-call for ub.rule-by-call.
  if lookup({&table_rule-call-param}, p-data-completeness) > 0 then do:
    _tt0-rule-call-param:
    for each tt0-rule-call-param
    where tt0-rule-call-param.call_id = p-call-id
    break
    by tt0-rule-call-param.call_id
    by tt0-rule-call-param.codex_id
    by tt0-rule-call-param.ruleset_id
    by tt0-rule-call-param.order_id
    by tt0-rule-call-param.rule_id
    on ERROR UNDO _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
    ON STOP undo _MAIN, return error '':u:
      if first-of (tt0-rule-call-param.rule_id) then do:
        find first buf_rule exclusive-lock where
                  buf_rule.rule_id = tt0-rule-call-param.rule_id .
        find first buf_ruledict exclusive-lock where
                  buf_ruledict.entry-type = {&rdict-etype-rule}
              and buf_ruledict.uniq-key-rec = buf_rule.uniq-key-rec.
        _ruledict-param:
        for each buf_ruledict-param no-lock where
                buf_ruledict-param.entry-id  = buf_ruledict.entry-id
        on ERROR UNDO _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
        ON STOP undo _MAIN, return error '':u:
          if lookup("temp", buf_ruledict-param.param-3-data-type) > 0  then do:
            next _ruledict-param.
          end.
          find first buf_tt0-rule-call-param where
                  buf_tt0-rule-call-param.rule_id = tt0-rule-call-param.rule_id
              and buf_tt0-rule-call-param.call_id = tt0-rule-call-param.call_id
              and buf_tt0-rule-call-param.codex_id = tt0-rule-call-param.codex_id
              and buf_tt0-rule-call-param.ruleset_id = tt0-rule-call-param.ruleset_id
              and buf_tt0-rule-call-param.order_id = tt0-rule-call-param.order_id
              and buf_tt0-rule-call-param.param-num = buf_ruledict-param.param-num no-error .
          if not available buf_tt0-rule-call-param then do:
            undo _main, return error substitute("Не найдено значение параметра № &1 для вызова правила &2:&3" +
                                                "точка вызова &4, кодекс &5, набор правил &6, порядок вызова &7"
                                                , buf_tt0-rule-call-param.param-num
                                                , tt0-rule-call-param.rule_id
                                                , {&new-line}
                                                , p-call-id
                                                , tt0-rule-call-param.codex_id
                                                , tt0-rule-call-param.ruleset_id
                                                , tt0-rule-call-param.order_id).
          end.
          for each buf_tt0-rule-call-param where
                  buf_tt0-rule-call-param.rule_id = tt0-rule-call-param.rule_id
              and buf_tt0-rule-call-param.call_id = tt0-rule-call-param.call_id
              and buf_tt0-rule-call-param.codex_id = tt0-rule-call-param.codex_id
              and buf_tt0-rule-call-param.ruleset_id = tt0-rule-call-param.ruleset_id
              and buf_tt0-rule-call-param.order_id = tt0-rule-call-param.order_id
              and buf_tt0-rule-call-param.param-num = buf_ruledict-param.param-num
          on ERROR UNDO _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
          ON STOP undo _MAIN, return error '':u:
            if buf_tt0-rule-call-param.param-data-type <> buf_ruledict-param.param-data-type
            or buf_tt0-rule-call-param.param-mode <> buf_ruledict-param.param-mode then do:
              undo _main, return error substitute("Неверный тип или мода параметра № &1 для вызова правила &2:&3" +
                                                  "точка вызова &4, кодекс &5, набор правил &6, порядок вызова &7"
                                                  , buf_tt0-rule-call-param.param-num
                                                  , tt0-rule-call-param.rule_id
                                                  , {&new-line}
                                                  , p-call-id
                                                  , tt0-rule-call-param.codex_id
                                                  , tt0-rule-call-param.ruleset_id
                                                  , tt0-rule-call-param.order_id) +
                                      substitute("&1Для правила задано: тип данных &2, мода &3&1" +
                                                  "Для точки вызова: тип данных &4, мода &5"
                                                  , {&new-line}
                                                  , buf_ruledict-param.param-data-type
                                                  , buf_ruledict-param.param-mode
                                                  , buf_tt0-rule-call-param.param-data-type
                                                  , buf_tt0-rule-call-param.param-mode).
            end. /*if buf_tt0-rule-call-param.param-data-type <> buf_ruledict-param.param-data-type*/
            if buf_tt0-rule-call-param.p-index = 0
            and lookup("SORTED-LIST", buf_tt0-rule-call-param.param-3-data-type) > 0
            then do:
              run check-list-unique in this-procedure ( input buf_tt0-rule-call-param.call_id
                                                       ,input buf_tt0-rule-call-param.codex_id
                                                       ,input buf_tt0-rule-call-param.ruleset_id
                                                       ,input buf_tt0-rule-call-param.order_id
                                                       ,input buf_tt0-rule-call-param.param-name
                                                       ,input buf_tt0-rule-call-param.param-data-type
                                                        ) no-error.
              if error-status:error then do:
                undo _main, return error substitute("Неверное значение параметра № &1(&8) для вызова правила &2:&3" +
                                                    "точка вызова &4, кодекс &5, набор правил &6, порядок вызова &7&3" +
                                                    "профайл &8&3" +
                                                    "Имеются ДУБЛИ в параметре типа СПИСОК"
                                                    , buf_tt0-rule-call-param.param-num
                                                    , tt0-rule-call-param.rule_id
                                                    , {&new-line}
                                                    , p-call-id
                                                    , tt0-rule-call-param.codex_id
                                                    , tt0-rule-call-param.ruleset_id
                                                    , tt0-rule-call-param.order_id
                                                    , tt0-rule-call-param.profile_id
                                                    , buf_tt0-rule-call-param.param-name
                                                    ).
              end.
            end.
            /*проверим корректность параметра*/
            if buf_tt0-rule-call-param.param-2-data-type <> '':U then do:
              /*те которые не могут быть запущены не проверяем*/
              /*просто не включенные ПРОВЕРЯЕМ !!! потому что привязать prop-ref и dis-rule надо*/
              if  lookup({&table_rule-by-call}, p-data-completeness) > 0 then do:
                find first on_tt0-rule-by-call where
                          on_tt0-rule-by-call.call_id = buf_tt0-rule-call-param.call_id
                      and on_tt0-rule-by-call.codex_id = buf_tt0-rule-call-param.codex_id
                      and on_tt0-rule-by-call.ruleset_id = buf_tt0-rule-call-param.ruleset_id
                      and on_tt0-rule-by-call.order_id = buf_tt0-rule-call-param.order_id no-error .
                /*if on_tt0-rule-by-call.can-run = no then next _tt0-rule-call-param.*/
              end.
              else do:
                find first on_buf_rule-by-call where
                          on_buf_rule-by-call.call_id = buf_tt0-rule-call-param.call_id
                      and on_buf_rule-by-call.codex_id = buf_tt0-rule-call-param.codex_id
                      and on_buf_rule-by-call.ruleset_id = buf_tt0-rule-call-param.ruleset_id
                      and on_buf_rule-by-call.order_id = buf_tt0-rule-call-param.order_id no-error .
                /*if on_buf_rule-by-call.can-run = no then next _tt0-rule-call-param.*/
              end.
              assign
              v-ok = no
              v-value-character = buf_tt0-rule-call-param.param-value-character
              v-value-date = buf_tt0-rule-call-param.param-value-date
              v-value-decimal = buf_tt0-rule-call-param.param-value-decimal
              v-value-integer = buf_tt0-rule-call-param.param-value-integer
              v-value-logical = buf_tt0-rule-call-param.param-value-logical
              .

              run ref/rule-dtt.p (
                                  input ? /*parparentproc для verify не должен быть нужен*/
                                  ,input {&verify}
                                  ,input p-call-id
                                  ,input buf_tt0-rule-call-param.param-data-type
                                  ,input buf_tt0-rule-call-param.param-2-data-type
                                  ,input buf_tt0-rule-call-param.param-3-data-type
                                  ,input buf_tt0-rule-call-param.p-index
                                  ,input-output v-value-character
                                  ,input-output v-value-date
                                  ,input-output v-value-decimal
                                  ,input-output v-value-integer
                                  ,input-output v-value-logical
                                  ,output v-ok
                                  ) no-error.
              if error-status:error
              or not v-ok then do:
                undo _main, return error substitute("Неверное значение параметра № &1(&8) для вызова правила &2:&3" +
                                                    "точка вызова &4, кодекс &5, набор правил &6, порядок вызова &7&3&9"
                                                    , buf_tt0-rule-call-param.param-num
                                                    , tt0-rule-call-param.rule_id
                                                    , {&new-line}
                                                    , p-call-id
                                                    , tt0-rule-call-param.codex_id
                                                    , tt0-rule-call-param.ruleset_id
                                                    , tt0-rule-call-param.order_id
                                                    , buf_tt0-rule-call-param.param-name
                                                    , return-value
                                                    ).
              end.
              if buf_tt0-rule-call-param.p-index > 0
              or lookup("LIST", buf_tt0-rule-call-param.param-3-data-type) = 0
              or lookup("SORTED-LIST", buf_tt0-rule-call-param.param-3-data-type) = 0
              then do:
                run gen-key-rec in this-procedure (
                                                   input {&table_rule-call-param}
                                                  ,input buffer buf_tt0-rule-call-param:handle
                                                  ,output v-rcp-key-rec).
                find first temp-uniq-key where temp-uniq-key.key-rec = v-rcp-key-rec no-error.
                if not available temp-uniq-key then do:

                  create temp-uniq-key.
                  temp-uniq-key.key-rec = v-rcp-key-rec.
                  run update-prop-ref-call in this-procedure ( input buf_tt0-rule-call-param.param-data-type
                                                              ,input buf_tt0-rule-call-param.param-2-data-type
                                                              ,input buf_tt0-rule-call-param.param-3-data-type
                                                              ,input buf_tt0-rule-call-param.param-value-character
                                                              ,input buf_tt0-rule-call-param.call_id).
                end.
                run update-dis-rule in this-procedure ( input buf_tt0-rule-call-param.param-data-type
                                                        ,input buf_tt0-rule-call-param.param-2-data-type
                                                        ,input buf_tt0-rule-call-param.param-3-data-type
                                                        ,input buf_tt0-rule-call-param.param-value-integer
                                                        ,input buf_tt0-rule-call-param.call_id
                                                        ).
                run update-ext-system in this-procedure ( input buf_tt0-rule-call-param.param-data-type
                                                        ,input buf_tt0-rule-call-param.param-2-data-type
                                                        ,input buf_tt0-rule-call-param.param-3-data-type
                                                        ,input buf_tt0-rule-call-param.param-value-integer
                                                        ,input buf_tt0-rule-call-param.call_id
                                                        ).
                find first buf_rule-call-param share-lock where
                          buf_rule-call-param.call#_id = buf_tt0-rule-call-param.call#_id
                      and buf_rule-call-param.codex_id = buf_tt0-rule-call-param.codex_id
                      and buf_rule-call-param.ruleset_id = buf_tt0-rule-call-param.ruleset_id
                      and buf_rule-call-param.order_id = buf_tt0-rule-call-param.order_id
                      and buf_rule-call-param.param-num = buf_ruledict-param.param-num
                      and buf_rule-call-param.param-name = buf_tt0-rule-call-param.param-name
                      and buf_rule-call-param.p-index = buf_tt0-rule-call-param.p-index
                      no-error.
                if available buf_rule-call-param then do:
                  if buf_tt0-rule-call-param.param-value-character <> buf_rule-call-param.param-value-character then do:
                    run delete-prop-ref-call in this-procedure ( input buf_rule-call-param.param-data-type
                                                                ,input buf_rule-call-param.param-2-data-type
                                                                ,input buf_rule-call-param.param-3-data-type
                                                                ,input buf_rule-call-param.param-value-character
                                                                ,input buf_rule-call-param.call_id).
                  end.
                  if buf_tt0-rule-call-param.param-value-integer <> buf_rule-call-param.param-value-integer then do:
                    run delete-dis-rule in this-procedure (  input buf_rule-call-param.param-data-type
                                                            ,input buf_rule-call-param.param-2-data-type
                                                            ,input buf_rule-call-param.param-3-data-type
                                                            ,input buf_rule-call-param.param-value-integer
                                                            ,input buf_rule-call-param.call_id
                                                            ,buffer buf_rule-call-param
                                                            ).
                    run delete-ext-system in this-procedure (  input buf_rule-call-param.param-data-type
                                                            ,input buf_rule-call-param.param-2-data-type
                                                            ,input buf_rule-call-param.param-3-data-type
                                                            ,input buf_rule-call-param.param-value-integer
                                                            ,input buf_rule-call-param.call_id
                                                            ,buffer buf_rule-call-param
                                                            ).
                  end.
                end.
              end.
            end. /*if buf_tt0-rule-call-param.param-2-data-type <> '':U then do:*/
            if lookup({&table_rule-by-call}, p-data-completeness) = 0
            and lookup({&table_rp-by-call}, p-data-completeness) = 0
            and lookup({&table_rule-call-param}, p-data-completeness) > 0 then do:
              find first buf_rule-call-param share-lock where
                        buf_rule-call-param.call#_id = buf_tt0-rule-call-param.call#_id
                    and buf_rule-call-param.codex_id = buf_tt0-rule-call-param.codex_id
                    and buf_rule-call-param.ruleset_id = buf_tt0-rule-call-param.ruleset_id
                    and buf_rule-call-param.order_id = buf_tt0-rule-call-param.order_id
                    and buf_rule-call-param.param-num = buf_ruledict-param.param-num
                    and buf_rule-call-param.param-name = buf_tt0-rule-call-param.param-name
                    and buf_rule-call-param.p-index = buf_tt0-rule-call-param.p-index
                    no-error.
              if not available buf_rule-call-param then do:
                if v-call#-id = 0 then do:
                  run rul/g-callid.p ( input p-call-type
                                      ,input p-call-id
                                      ,output v-call#-id).
                end.
                create buf_rule-call-param.
                assign
                v-cmp-loc = no
                v-cmp = v-cmp and v-cmp-loc
                .
              end.
              else do:
                if v-call#-id = 0 then do:
                  run rul/g-callid.p ( input p-call-type
                                      ,input p-call-id
                                      ,output v-call#-id).
                end.
                if buf_tt0-rule-call-param.param-2-data-type <> '':U
                and (buf_tt0-rule-call-param.p-index > 0
                or lookup("LIST", buf_tt0-rule-call-param.param-3-data-type) = 0
                or lookup("SORTED-LIST", buf_tt0-rule-call-param.param-3-data-type) = 0)
                then do:
                  if buf_tt0-rule-call-param.param-value-character <> buf_rule-call-param.param-value-character then do:
                    run delete-prop-ref-call in this-procedure ( input buf_rule-call-param.param-data-type
                                                                ,input buf_rule-call-param.param-2-data-type
                                                                ,input buf_rule-call-param.param-3-data-type
                                                                ,input buf_rule-call-param.param-value-character
                                                                ,input buf_rule-call-param.call_id).
                  end.
                  if buf_tt0-rule-call-param.param-value-integer <> buf_rule-call-param.param-value-integer then do:
                    run delete-dis-rule in this-procedure (  input buf_rule-call-param.param-data-type
                                                            ,input buf_rule-call-param.param-2-data-type
                                                            ,input buf_rule-call-param.param-3-data-type
                                                            ,input buf_rule-call-param.param-value-integer
                                                            ,input buf_rule-call-param.call_id
                                                            ,buffer buf_rule-call-param
                                                            ).
                    run delete-ext-system in this-procedure (  input buf_rule-call-param.param-data-type
                                                            ,input buf_rule-call-param.param-2-data-type
                                                            ,input buf_rule-call-param.param-3-data-type
                                                            ,input buf_rule-call-param.param-value-integer
                                                            ,input buf_rule-call-param.call_id
                                                            ,buffer buf_rule-call-param
                                                            ).
                  end.
                end. /*if buf_tt0-rule-call-param.param-2-data-type <> '':U*/
              end. /*else if availabel buf_rule-call-param*/
              buffer-compare buf_tt0-rule-call-param to
              buf_rule-call-param save result in v-cmp-loc.
              buffer-copy buf_tt0-rule-call-param
              except call#_id
              to buf_rule-call-param
              assign
              buf_rule-call-param.call#_id = v-call#-id
              .
              if not v-cmp-loc and v-run-bush-command then do:
  &scop table__  ~{&table_rule-call-param~}
  &scop buffer-handle buffer buf_rule-call-param:handle
  &scop action__ '+update'
            {&add-dump}.
              end.
            end.
          end. /*          for each buf_tt0-rule-call-param where*/
        end. /*        for each buf_ruledict-param no-lock where*/
        for each buf_tt0-rule-call-param where
                buf_tt0-rule-call-param.call_id = p-call-id
            and buf_tt0-rule-call-param.codex_id = tt0-rule-call-param.codex_id
            and buf_tt0-rule-call-param.ruleset_id = tt0-rule-call-param.ruleset_id
            and buf_tt0-rule-call-param.order_id = tt0-rule-call-param.order_id
        on ERROR UNDO _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
        ON STOP undo _MAIN, return error '':u:
          find first buf_ruledict-param no-lock where
                    buf_ruledict-param.entry-id = buf_Ruledict.entry-id
                and buf_ruledict-param.param-num = buf_tt0-rule-call-param.param-num no-error .
          if not available buf_ruledict-param then do:
            undo _main, return error substitute("Неизвестный параметр № &1 для вызова правила &2:&3" +
                                                "точка вызова &4, кодекс &5, набор правил &6, порядок вызова &7"
                                                , buf_tt0-rule-call-param.param-num
                                                , tt0-rule-call-param.rule_id
                                                , {&new-line}
                                                , p-call-id
                                                , tt0-rule-call-param.codex_id
                                                , tt0-rule-call-param.ruleset_id
                                                , tt0-rule-call-param.order_id).
          end.
        end.
        if lookup({&table_rule-by-call}, p-data-completeness) = 0
        and lookup({&table_rp-by-call}, p-data-completeness) = 0
        and lookup({&table_rule-call-param}, p-data-completeness) > 0 then do:
          for each buf_rule-call-param share-lock where
                  buf_rule-call-param.call_id = p-call-id
              and buf_rule-call-param.codex_id = tt0-rule-call-param.codex_id
              and buf_rule-call-param.ruleset_id = tt0-rule-call-param.ruleset_id
              and buf_rule-call-param.order_id = tt0-rule-call-param.order_id
          on ERROR UNDO _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
          ON STOP undo _MAIN, return error '':u:
            find first buf_tt0-rule-call-param where
                  buf_tt0-rule-call-param.call_id = p-call-id
              and buf_tt0-rule-call-param.codex_id = tt0-rule-call-param.codex_id
              and buf_tt0-rule-call-param.ruleset_id = tt0-rule-call-param.ruleset_id
              and buf_tt0-rule-call-param.order_id = tt0-rule-call-param.order_id
              and buf_tt0-rule-call-param.param-num = tt0-rule-call-param.param-num
              and buf_tt0-rule-call-param.param-name = tt0-rule-call-param.param-name
              and buf_tt0-rule-call-param.p-index = tt0-rule-call-param.p-index
              no-error.
            if not available buf_tt0-rule-call-param then do:
              if v-run-bush-command then do:
&scop table__  ~{&table_rule-call-param~}
&scop buffer-handle buffer buf_rule-call-param:handle
&scop action__ '+delete'
                {&add-dump}.
              end.
              delete buf_rule-call-param.
            end.
          end.
        end. /*if lookup({&table_rule-by-call}, p-data-completeness) = 0*/
      end. /*if first-of (tt0-rule-call-param.rule_id) then do:*/
    end. /*    for each tt0-rule-call-param*/
  end. /*if lookup({&table_rule-call-param}, p-data-completeness) > 0 then do:*/

  if lookup({&table_rule-by-call}, p-data-completeness) > 0
  and lookup({&table_rule-call-param}, p-data-completeness) > 0
  then do:
    for each buf_rule-by-call where
              buf_rule-by-call.call_id = p-call-id
      on ERROR UNDO _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
      ON STOP undo _MAIN, return error '':u:
      find first tt0-rule-by-call no-lock where
                tt0-rule-by-call.call_id = p-call-id
            and tt0-rule-by-call.codex_id = buf_rule-by-call.codex_id
            and tt0-rule-by-call.ruleset_id = buf_rule-by-call.ruleset_id
            and tt0-rule-by-call.order_id = buf_rule-by-call.order_id  no-error.
      if not available tt0-rule-by-call then do:
        for each buf_rule-call-param where
              buf_rule-call-param.codex_id = buf_rule-by-call.codex_id
          and buf_rule-call-param.ruleset_id = buf_rule-by-call.ruleset_id
          and buf_rule-call-param.call_id = buf_rule-by-call.call_id
          and buf_rule-call-param.order_id = buf_rule-by-call.order_id
        on ERROR UNDO _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
        ON STOP undo _MAIN, return error '':u:
          if buf_rule-call-param.p-index > 0
          or lookup("LIST", buf_rule-call-param.param-3-data-type) = 0
          or lookup("SORTED-LIST", buf_rule-call-param.param-3-data-type) = 0
          then do:
            run delete-prop-ref-call in this-procedure ( input buf_rule-call-param.param-data-type
                                                        ,input buf_rule-call-param.param-2-data-type
                                                        ,input buf_rule-call-param.param-3-data-type
                                                        ,input buf_rule-call-param.param-value-character
                                                        ,input buf_rule-call-param.call_id).
            run delete-dis-rule in this-procedure (  input buf_rule-call-param.param-data-type
                                                    ,input buf_rule-call-param.param-2-data-type
                                                    ,input buf_rule-call-param.param-3-data-type
                                                    ,input buf_rule-call-param.param-value-integer
                                                    ,input buf_rule-call-param.call_id
                                                    ,buffer buf_rule-call-param
                                                    ).
            run delete-ext-system in this-procedure (  input buf_rule-call-param.param-data-type
                                                    ,input buf_rule-call-param.param-2-data-type
                                                    ,input buf_rule-call-param.param-3-data-type
                                                    ,input buf_rule-call-param.param-value-integer
                                                    ,input buf_rule-call-param.call_id
                                                    ,buffer buf_rule-call-param
                                                    ).
          end.
          if v-run-bush-command then do:
&scop table__  ~{&table_rule-call-param~}
&scop buffer-handle buffer buf_rule-call-param:handle
&scop action__ '+delete'
            {&add-dump}.
          end.
          delete buf_rule-call-param.
        end.
        find first buf_rule no-lock where
                  buf_rule.rule_id = buf_rule-by-call.rule_id no-error.
        if available buf_rule then do:
          find  current buf_rule exclusive-lock .
        end.
        if v-run-bush-command then do:
&scop table__  ~{&table_rule-by-call~}
&scop buffer-handle buffer buf_rule-by-call:handle
&scop action__ '+delete'
          {&add-dump}.
        end.
        delete buf_rule-by-call.
        if available buf_rule then do:
          define variable v-mess as character no-undo .
          v-ok = no.
          run trg/rule-chk.p ( input {&deletion}
                              ,input buf_rule.rule_id
                              ,output v-ok
                              ,output v-mess
                              ) no-error.
          if not error-status:error
          and not v-ok then do:
            if buf_rule.sts <> integer({&ready-status-int}) then do:
              buf_rule.sts = integer({&ready-status-int}).
            end.
          end.
        end. /*if available buf_rule then do:*/
      end. /*if not available tt0-rule-by-call then do:*/
    end. /*    for each buf_rule-by-call where*/
    for each tt0-rule-by-call
    where tt0-rule-by-call.call_id = p-call-id
    on ERROR UNDO _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
    ON STOP undo _MAIN, return error '':u:
      find first buf_rule-by-call where
                buf_rule-by-call.call_Id = tt0-rule-by-call.call_id
            and buf_rule-by-call.codex_id = tt0-rule-by-call.codex_id
            and buf_rule-by-call.ruleset_id = tt0-rule-by-call.ruleset_id
            and buf_rule-by-call.order_id = tt0-rule-by-call.order_id  no-error .
      if not available buf_rule-by-call then do:
        if v-call#-id = 0 then do:
          run rul/g-callid.p ( input p-call-type
                              ,input p-call-id
                              ,output v-call#-id).
        end.
      end.
      else do:
        define variable v-rec as recid no-undo .
        v-rec = recid(buf_rule-by-call).
      end.
      run rul/rule-by-call1.p ( input (if not available buf_rule-by-call
                                        then {&add-def}
                                        else {&update})
                                ,input yes /*p-silent*/
                                ,input-output v-rec /*p-rec*/
                                ,input p-cmd-proc-handle
                                ,input p-cmd-code
                                ,input (if not available buf_rule-by-call
                                        then v-call#-id
                                        else buf_rule-by-call.call#_ID)
                                ,input tt0-rule-by-call.codex_id
                                ,input tt0-rule-by-call.ruleset_id
                                ,input tt0-rule-by-call.order_id
                                ,input tt0-rule-by-call.call_id
                                ,input tt0-rule-by-call.rule_id
                                ,input tt0-rule-by-call.profile_id
                                ,input tt0-rule-by-call.once-more
                                ,input tt0-rule-by-call.is_dynamic
                                ,input tt0-rule-by-call.can-calc
                                ,input tt0-rule-by-call.algo-des) no-error .
      if error-status:error then do:
        UNDO _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) ).
      end.
      for each buf_rule-call-param where
            buf_rule-call-param.codex_id = tt0-rule-by-call.codex_id
        and buf_rule-call-param.ruleset_id = tt0-rule-by-call.ruleset_id
        and buf_rule-call-param.call_id = tt0-rule-by-call.call_id
        and buf_rule-call-param.order_id = tt0-rule-by-call.order_id
      on ERROR UNDO _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
      ON STOP undo _MAIN, return error '':u:
        find first tt0-rule-call-param where
            tt0-rule-call-param.codex_id = tt0-rule-by-call.codex_id
        and tt0-rule-call-param.ruleset_id = tt0-rule-by-call.ruleset_id
        and tt0-rule-call-param.call_id = tt0-rule-by-call.call_Id
        and tt0-rule-call-param.order_id = tt0-rule-by-call.order_id
        and tt0-rule-call-param.param-name = buf_rule-call-param.param-name
        and tt0-rule-call-param.p-index = buf_rule-call-param.p-index no-error.
        if not available tt0-rule-call-param then do:
          if v-run-bush-command then do:
&scop table__  ~{&table_rule-call-param~}
&scop buffer-handle buffer buf_rule-call-param:handle
&scop action__ '+delete'
            {&add-dump}.
          end.
          delete buf_rule-call-param.
        end.
      end.
      for each tt0-rule-call-param where
            tt0-rule-call-param.call_id = p-call-id
        and tt0-rule-call-param.codex_id = tt0-rule-by-call.codex_id
        and tt0-rule-call-param.ruleset_id = tt0-rule-by-call.ruleset_id
        and tt0-rule-call-param.call_id = tt0-rule-by-call.call_Id
        and tt0-rule-call-param.order_id = tt0-rule-by-call.order_id
      on ERROR UNDO _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
      ON STOP undo _MAIN, return error '':u:
        find first buf_rule-call-param where
                  buf_rule-call-param.codex_id = tt0-rule-by-call.codex_id
              and buf_rule-call-param.ruleset_id = tt0-rule-by-call.ruleset_id
              and buf_rule-call-param.call_id = tt0-rule-by-call.call_Id
              and buf_rule-call-param.order_id = tt0-rule-by-call.order_id
              and buf_rule-call-param.param-name = tt0-rule-call-param.param-name
              and buf_rule-call-param.p-index = tt0-rule-call-param.p-index
              no-error.
        if not available buf_rule-call-param then do:
          if v-call#-id = 0 then do:
            run rul/g-callid.p ( input p-call-type
                                ,input p-call-id
                                ,output v-call#-id).
          end.
          create buf_rule-call-param.
          assign
          v-cmp-loc = no
          v-cmp = v-cmp and v-cmp-loc
          .
        end.
        else do:
          buffer-compare tt0-rule-call-param
          except call#_id to buf_rule-call-param save result in v-cmp-loc.
        end.
        buffer-copy tt0-rule-call-param
        except call#_id
        to buf_rule-call-param
        assign
        buf_rule-call-param.call#_id = v-call#-id
        .
        if not v-cmp-loc and v-run-bush-command then do:
&scop table__  ~{&table_rule-call-param~}
&scop buffer-handle buffer buf_rule-call-param:handle
&scop action__ '+update'
           {&add-dump}.
        end.

      end.
    end. /*    for each tt0-rule-by-call*/
    /*проверим можно ли вызвать*/
    define variable v-can-run as logical no-undo .
    _rule-by-call:
    for each buf_rule-by-call exclusive-lock where
              buf_rule-by-call.call_id = p-call-id,
      first buf_rule no-lock where
            buf_rule.rule_id = buf_rule-by-call.rule_id
    by buf_rule-by-call.call_Id
    by buf_rule-by-call.codex_id
    by buf_rule-by-call.ruleset_id
    by buf_rule-by-call.order_id
    on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
    on endkey undo _main, return error substitute( "&1. endkey", vss-workfile ) :
      run check-reusable in this-procedure ( input p-call-id
                                              ,input buf_rule-by-call.codex_id
                                              ,input buf_rule-by-call.ruleset_id
                                              ,input buf_rule-by-call.order_id
                                              ,input buf_rule-by-call.profile_id
                                              ,input buf_rule-by-call.rule_id
                                              ,input buf_rule.reusable-params
                                              ,output v-can-run
                                              ).
      if buf_rule-by-call.can-run <> v-can-run
      or (v-can-run = no and buf_rule-by-call.can-calc = yes)
      or (v-can-run = yes and buf_rule-by-call.can-calc = no and not buf_rule-by-call.is_dynamic /*выключилось потому что лишнее*/ )
      then do:
        assign
        v-old-can-run = buf_rule-by-call.can-run
        v-old-can-calc = buf_rule-by-call.can-calc
        buf_rule-by-call.can-run = v-can-run
        buf_rule-by-call.can-calc = (if v-can-run
                                      then (if not buf_rule-by-call.is_dynamic
                                            then yes
                                            else buf_rule-by-call.can-calc)
                                      else no)
        v-cmp-loc = ((v-old-can-run = buf_rule-by-call.can-run)
                      and
                      (v-old-can-calc = buf_rule-by-call.can-calc)
                    )
        .
        if not v-cmp-loc and v-run-bush-command then do:
&scop table__  ~{&table_rule-by-call~}
&scop buffer-handle buffer buf_rule-by-call:handle
&scop action__ '+update'
          {&add-dump}.
        end.
      end.
    end.
  end. /*if lookup({&table_rule-by-call}, p-data-completeness) > 0
         and lookup({&table_rule-call-param}, p-data-completeness) > 0
         then do:*/
  if v-create-command then do:
    run send-command in p-cmd-proc-handle
      ( input p-cmd-code  /* p-command-code */
        ,input '':U
        ) no-error .
    if error-status:error then do:
      delete procedure p-cmd-proc-handle .
      message
      vss-workfile vss-revision vss-description skip
      substitute( "Ошибка при отсылке команды &1", v-command ) skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
      undo _main, return error .
    end.
  end.
end. /*doe*/

procedure update-prop-ref-call :
define input parameter p-param-data-type as character no-undo .
define input parameter p-param-2-data-type as character no-undo .
define input parameter p-param-3-data-type as character no-undo .
define input parameter p-value-character as character no-undo .
define input parameter p-call-id as character no-undo .
define variable v-dtm-code as integer no-undo init -1.
define buffer buf_prop-ref for ub.prop-ref.
define buffer buf_prop-ref-call for ub.prop-ref-call.

_main:
do
on error undo, return error
:

  if p-param-2-data-type begins ({&table_prop-ref} + "_") then do:
    assign
    v-dtm-code = integer(entry(2, p-param-2-data-type, "_"))
    no-error
    .
    find first buf_prop-ref no-lock where
        buf_prop-ref.dtm-code = v-dtm-code
    and buf_prop-ref.sum-id = p-value-character no-error .
    if available buf_prop-ref then do:
      find first buf_prop-ref-call where
                buf_prop-ref-call.dt-code = buf_prop-ref.dt-code
            and buf_prop-ref-call.call_id = p-call-id no-error .
      if not available buf_prop-ref-call then do:
        if v-call#-id = 0 then do:
          run rul/g-callid.p ( input p-call-type
                              ,input p-call-id
                              ,output v-call#-id).
        end.
        create buf_prop-ref-call.
        assign
        buf_prop-ref-call.call_id = p-call-id
        buf_prop-ref-call.dt-code = buf_prop-ref.dt-code
        buf_prop-ref-call.dtm-code = buf_prop-ref.dtm-code
        buf_prop-ref-call.call#_id = v-call#-id
        .
      end.
      find first temp-prop-ref-call where
                temp-prop-ref-call.dt-code = buf_prop-ref.dt-code no-error.
      if not available temp-prop-ref-call then do:
        create temp-prop-ref-call.
        buffer-copy buf_prop-ref-call to temp-prop-ref-call.
      end.
      assign
      temp-prop-ref-call.counter = temp-prop-ref-call.counter + 1
      buf_prop-ref-call.counter = temp-prop-ref-call.counter.
      release temp-prop-ref-call.
      if v-run-bush-command then do:
&scop table__  ~{&table_prop-ref-call~}
&scop buffer-handle buffer buf_prop-ref-call:handle
&scop action__ '+update'
           {&add-dump}.
      end.
    end.
  end.
end.

end procedure. /* update-prop-ref-call */

procedure delete-prop-ref-call :
define input parameter p-param-data-type as character no-undo .
define input parameter p-param-2-data-type as character no-undo .
define input parameter p-param-3-data-type as character no-undo .
define input parameter p-value-character as character no-undo .
define input parameter p-call-id as character no-undo .
define variable v-dtm-code as integer no-undo init -1.
define variable v-ok as logical no-undo .
define variable v-mwss as character no-undo .

define buffer buf_prop-ref for ub.prop-ref.
define buffer buf_prop-ref-call for ub.prop-ref-call.

_main:
do
on error undo, return error
:

  if  p-param-2-data-type begins ({&table_prop-ref} + "_") then do:
    assign
    v-dtm-code = integer(entry(2, p-param-2-data-type, "_"))
    no-error
    .
    find first buf_prop-ref no-lock where
        buf_prop-ref.dtm-code = v-dtm-code
    and buf_prop-ref.sum-id = p-value-character no-error .
    if available buf_prop-ref then do:
      find first buf_prop-ref-call where
                buf_prop-ref-call.dt-code = buf_prop-ref.dt-code
            and buf_prop-ref-call.call_id = p-call-id no-error .
      if available buf_prop-ref-call then do:
        buf_prop-ref-call.counter = buf_prop-ref-call.counter - 1.
        if buf_prop-ref-call.counter = 0 then do:
          run rul/pref-chk.p ( input {&deletion}
                              ,input "ruprcall"
                              ,input buf_prop-ref-call.dtm-code
                              ,input buf_prop-ref-call.dt-code
                              ,output v-ok
                              ,output v-mess) no-error .
          if v-ok then do:
            if v-run-bush-command then do:
    &scop table__  ~{&table_prop-ref-call~}
    &scop buffer-handle buffer buf_prop-ref-call:handle
    &scop action__ '+delete'
              {&add-dump}.
            end.
            delete buf_prop-ref-call.
          end.
        end.
      end.
    end.
  end.
end.

end procedure. /* delete-prop-ref-call */


procedure update-dis-rule :
define input parameter p-param-data-type as character no-undo .
define input parameter p-param-2-data-type as character no-undo .
define input parameter p-param-3-data-type as character no-undo .
define input parameter p-param-value-integer as integer no-undo .
define input parameter p-call-id as character no-undo .
define variable v-templ-rl-root as integer no-undo.
define variable v-type as character no-undo .
define variable v-emitent-host-code as integer no-undo .
define variable v-field-list as character no-undo .
define variable v-value-list as character no-undo .
define variable jj as integer no-undo .
define variable v-nonunique as character no-undo .
define variable v-curr-field as character no-undo .
define buffer buf_dis-rule for ub.dis-rule.
define buffer buf_dis-cfg-rule for ub.dis-cfg-rule.
define buffer buf_dis-dct-rule for ub.dis-dct-rule.

_main:
do
on error undo, return error
:

  if p-param-2-data-type begins ({&table_dis-rule} + "_")
  then do:
    assign
    v-templ-rl-root = integer(entry(2, p-param-2-data-type, "_"))
    no-error
    .
    case p-call-type:
      when {&table_dis-card-type} then do:
        run gen-key-fv in this-procedure ( input p-call-id
                                          ,output v-field-list
                                          ,output v-value-list).
        assign
        v-type =  entry(lookup("type", v-field-list, {&delim-key}), v-value-list, {&delim-key})
        v-emitent-host-code = integer(entry(lookup("emitent-host-code", v-field-list, {&delim-key}), v-value-list, {&delim-key}))
        .
        find first buf_dis-cfg-rule no-lock where
            buf_dis-cfg-rule.templ-rl-root = v-templ-rl-root
        and buf_dis-cfg-rule.pos-type = {&cd-type-bo}
        and buf_dis-cfg-rule.table-name = {&table_dis-dct-rule} no-error .
        if available buf_Dis-cfg-rule then do:
          find first buf_dis-rule no-lock where
                      buf_dis-rule.rule-num = p-param-value-integer no-error.
          if available buf_dis-rule then do:
            do jj = 1 to num-entries(buf_dis-cfg-rule.nonunique):
              assign
              v-curr-field = entry(jj, buf_dis-cfg-rule.nonunique)
              .
              assign
              v-nonunique = v-nonunique + (if v-nonunique = '':u then '':U else {&delim-par}) +
                            string(buffer buf_dis-rule:buffer-field(v-curr-field):buffer-value).
            end.
            find first buf_dis-dct-rule where
                  buf_dis-dct-rule.type = v-type
              and buf_dis-dct-rule.emitent-host-code = v-emitent-host-code
              and buf_dis-dct-rule.host-code = buf_dis-rule.host-code
              and buf_dis-dct-rule.obj-type = buf_dis-rule.obj-type
              and buf_dis-dct-rule.obj-code = buf_dis-rule.obj-code
              and buf_dis-dct-rule.pos-type = {&cd-type-bo}
              and buf_dis-dct-rule.nonunique = v-nonunique
              and buf_dis-dct-rule.discnt-role = buf_dis-cfg-rule.discnt-role
              no-error .
            if not available buf_dis-dct-rule then do:
              create buf_dis-dct-rule.
              assign
              buf_dis-dct-rule.type = v-type
              buf_dis-dct-rule.emitent-host-code = v-emitent-host-code
              buf_dis-dct-rule.templ-rl-root = buf_dis-rule.templ-rl-root
              buf_dis-dct-rule.time-templ-rl-root = buf_dis-rule.time-templ-rl-root
              buf_dis-dct-rule.rule-num = buf_dis-rule.rule-num
              buf_dis-dct-rule.host-code = buf_dis-rule.host-code
              buf_dis-dct-rule.obj-type = buf_dis-rule.obj-type
              buf_dis-dct-rule.obj-code = buf_dis-rule.obj-code
              buf_dis-dct-rule.pos-type = {&cd-type-bo}
              buf_dis-dct-rule.nonunique = v-nonunique
              buf_dis-dct-rule.discnt-role = buf_dis-cfg-rule.discnt-role
              buf_dis-dct-rule.rl-root = buf_dis-rule.rl-root
              .
              if v-run-bush-command then do:
        &scop table__  ~{&table_dis-dct-rule~}
        &scop buffer-handle buffer buf_dis-dct-rule:handle
        &scop action__ '+update'
                  {&add-dump}.
              end.
            end.
          end. /*if available buf_dis-rule then do:*/

        end. /*if available buf_Dis-cfg-rule then do:*/
      end. /*when {&tabel_dis-card-type} then do:*/
    end case.
  end. /**  if p-param-2-data-type begins ({&table_dis-rule} + "_") */
end. /*doe */

end procedure. /* update-dis-dct-rule */

procedure delete-dis-rule :
define input parameter p-param-data-type as character no-undo .
define input parameter p-param-2-data-type as character no-undo .
define input parameter p-param-3-data-type as character no-undo .
define input parameter p-value-integer as integer no-undo .
define input parameter p-call-id as character no-undo .
define parameter buffer buf_rule-call-param for ub.rule-call-param.
define variable v-templ-rl-root as integer no-undo.
define variable v-type as character no-undo .
define variable v-emitent-host-code as integer no-undo .
define variable v-field-list as character no-undo .
define variable v-value-list as character no-undo .
define variable v-found as logical no-undo .
define buffer buf_dis-rule for ub.dis-rule.
define buffer buf_dis-dct-rule for ub.dis-dct-rule.
define buffer buf_tt0-rule-call-param for tt0-rule-call-param.

_main:
do
on error undo, return error
:

  if  p-param-2-data-type begins ({&table_dis-rule} + "_") then do:
    assign
    v-templ-rl-root = integer(entry(2, p-param-2-data-type, "_"))
    no-error
    .
    case p-call-type:
      when {&table_dis-card-type} then do:
        run gen-key-fv in this-procedure ( input p-call-id
                                          ,output v-field-list
                                          ,output v-value-list).
        assign
        v-type =  entry(lookup("type", v-field-list, {&delim-key}), v-value-list, {&delim-key})
        v-emitent-host-code = integer(entry(lookup("emitent-host-code", v-field-list, {&delim-key}), v-value-list, {&delim-key}))
        .
        v-found = no.
        _buf_tt0-rule-call-param:
        for each buf_tt0-rule-call-param no-lock where
                buf_tt0-rule-call-param.call_id = p-call-id:
          if buf_tt0-rule-call-param.param-2-data-type = p-param-2-data-type
          and buf_tt0-rule-call-param.param-value-integer = p-value-integer
          then do:
            v-found = yes.
            leave _buf_tt0-rule-call-param.
          end.
        end.
        if not v-found then do:
          for each buf_dis-dct-rule where
                    buf_dis-dct-rule.rule-num = p-value-integer
                and buf_dis-dct-rule.templ-rl-root = v-templ-rl-root
                and buf_dis-dct-rule.type = v-type
                and buf_dis-dct-rule.emitent-host-code = v-emitent-host-code
          on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
          on stop   undo , return error substitute( "&1. stop", vss-workfile )
          on endkey undo , return error substitute( "&1. endkey", vss-workfile )
          :

            if v-run-bush-command then do:
    &scop table__  ~{&table_dis-dct-rule~}
    &scop buffer-handle buffer buf_dis-dct-rule:handle
    &scop action__ '+delete'
              {&add-dump}.
            end.
            delete buf_dis-dct-rule.
          end.
        end. /*if not v-found then do:*/
      end. /*table-dis-card-type*/
    end case.
  end. /*if  p-param-2-data-type begins ({&table_dis-rule} + "_") then do:*/
end. /*doe*/

end procedure. /* delete-dis-rule-call */


procedure update-ext-system :
define input parameter p-param-data-type as character no-undo .
define input parameter p-param-2-data-type as character no-undo .
define input parameter p-param-3-data-type as character no-undo .
define input parameter p-param-value-integer as integer no-undo .
define input parameter p-call-id as character no-undo .

define variable v-resource-id as character no-undo .
define buffer buf_ext-system for ub.ext-system.
_main:
do
on error undo, return error
:

  if p-param-2-data-type =  {&table_ext-system}
  then do:
    case p-call-type:
      when {&table_dis-card-type} then do:
        find first buf_ext-system no-lock where
                  buf_ext-system.esys-id = p-param-value-integer
              and buf_ext-system.db-num = 0.
        run gen-key-rec in this-procedure (
                                            input {&table_ext-system}
                                           ,input (buffer buf_ext-system:handle)
                                           ,output v-resource-id).
        if v-call#-id = 0 then do:
          run rul/g-callid.p ( input p-call-type
                              ,input p-call-id
                              ,output v-call#-id).
        end.
        run who-lk_make-some-lk in this-procedure (
                                                   input v-resource-id
                                                  ,input p-call-id
                                                  ,input v-call#-id
                                                  ,input {&lk-type_update-delete}
                                                  ,input g#db-num /*p-corr-user-db-num*/
                                                  ,input substitute("&1: Параметр работы алгоритма", calldscr(p-call-id))
                                                  ,input "" /*PS*/
                                                  ).

      end. /*when {&tabel_dis-card-type} then do:*/
    end case.
  end. /**  if p-param-2-data-type begins ({&table_dis-rule} + "_") */
end. /*doe */

end procedure. /* update-ext-system */

procedure delete-ext-system :
define input parameter p-param-data-type as character no-undo .
define input parameter p-param-2-data-type as character no-undo .
define input parameter p-param-3-data-type as character no-undo .
define input parameter p-value-integer as integer no-undo .
define input parameter p-call-id as character no-undo .
define parameter buffer buf_rule-call-param for ub.rule-call-param.

define variable v-resource-id as character no-undo .
define buffer buf_ext-system for ub.ext-system.


_main:
do
on error undo, return error
:

  if  p-param-2-data-type = {&table_ext-system} then do:
    case p-call-type:
      when {&table_dis-card-type} then do:
        find first buf_ext-system no-lock where
                  buf_ext-system.esys-id = p-value-integer
              and buf_ext-system.db-num = 0 no-error.
        if not available buf_Ext-system then return.
        run gen-key-rec in this-procedure (
                                            input {&table_ext-system}
                                           ,input (buffer buf_ext-system:handle)
                                           ,output v-resource-id).
        run who-lk_delete-some-lk in this-procedure (
                                                   input v-resource-id
                                                  ,input p-call-id
                                                  ,input {&lk-type_update-delete}
                                                  ,input g#db-num /*p-corr-user-db-num*/
                                                  ).
      end. /*table-dis-card-type*/
    end case.
  end. /*if  p-param-2-data-type = {&table_ext-system} then do:*/
end. /*doe*/

end procedure. /* delete-ext-system */


procedure delete-from-rp-by-call:
define input parameter p-call-id as character no-undo .
define input parameter p-profile-id as integer no-undo .
define input parameter p-once-more as integer no-undo .

define buffer buf_rule-by-call for ub.rule-by-call.
define buffer buf_rule-call-param for ub.rule-call-param.

_main:
do
on error undo, return error
:
  for each buf_rule-by-call share-lock where
         buf_rule-by-call.call_id = p-call-id
     and buf_rule-by-call.profile_id = p-profile-id
     and buf_rule-by-call.once-more = p-once-more
  on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
  on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
  :
    for each buf_rule-call-param share-lock where
           buf_rule-call-param.call_id = buf_rule-by-call.call_id
       and buf_rule-call-param.codex_id = buf_rule-by-call.codex_id
       and buf_rule-call-param.ruleset_id = buf_rule-by-call.ruleset_id
       and buf_rule-call-param.order_id = buf_rule-by-call.order_id
    on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
    on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
    :
        if buf_rule-call-param.p-index > 0
        or lookup("LIST", buf_rule-call-param.param-3-data-type) = 0
        or lookup("SORTED-LIST", buf_rule-call-param.param-3-data-type) = 0
        then do:
          run delete-prop-ref-call in this-procedure ( input buf_rule-call-param.param-data-type
                                                      ,input buf_rule-call-param.param-2-data-type
                                                      ,input buf_rule-call-param.param-3-data-type
                                                      ,input buf_rule-call-param.param-value-character
                                                      ,input buf_rule-call-param.call_id).
          run delete-dis-rule in this-procedure (  input buf_rule-call-param.param-data-type
                                                  ,input buf_rule-call-param.param-2-data-type
                                                  ,input buf_rule-call-param.param-3-data-type
                                                  ,input buf_rule-call-param.param-value-integer
                                                  ,input buf_rule-call-param.call_id
                                                  ,buffer buf_rule-call-param
                                                  ).
          run delete-ext-system in this-procedure (  input buf_rule-call-param.param-data-type
                                                  ,input buf_rule-call-param.param-2-data-type
                                                  ,input buf_rule-call-param.param-3-data-type
                                                  ,input buf_rule-call-param.param-value-integer
                                                  ,input buf_rule-call-param.call_id
                                                  ,buffer buf_rule-call-param
                                                  ).
        end.
        if v-run-bush-command then do:
&scop table__  ~{&table_rule-call-param~}
&scop action__ '+delete'
&scop buffer-handle buffer buf_rule-call-param:handle
          {&add-dump}.
        end.
    end.
    if v-run-bush-command then do:
&scop table__  ~{&table_rule-by-call~}
&scop action__ '+delete'
&scop buffer-handle buffer buf_rule-by-call:handle
          {&add-dump}.
    end.
   end.
end.

end procedure. /* delete-from-rp-by-call: */


procedure check-list-unique :
define input parameter p-call-id as character no-undo .
define input parameter p-codex-id as integer no-undo .
define input parameter p-ruleset-id as integer no-undo .
define input parameter p-order-id as integer no-undo .
define input parameter p-param-name as character no-undo .
define input parameter p-param-data-type as character no-undo .

define variable v-current-index as integer no-undo .

define buffer buf_tt0-rule-call-param for tt0-rule-call-param.
define buffer buf2_tt0-rule-call-param for tt0-rule-call-param.
find first buf_tt0-rule-call-param where
        buf_tt0-rule-call-param.call_id = p-call-id
    and buf_tt0-rule-call-param.codex_id = p-codex-id
    and buf_tt0-rule-call-param.ruleset_id = p-ruleset-id
    and buf_tt0-rule-call-param.order_id = p-order-id
    and buf_tt0-rule-call-param.param-name = p-param-name
    and buf_tt0-rule-call-param.p-index > 0
    no-error.
do while available buf_tt0-rule-call-param:
  v-current-index = buf_tt0-rule-call-param.p-index.
  for each buf2_tt0-rule-call-param where
        buf2_tt0-rule-call-param.call_id = p-call-id
    and buf2_tt0-rule-call-param.codex_id = p-codex-id
    and buf2_tt0-rule-call-param.ruleset_id = p-ruleset-id
    and buf2_tt0-rule-call-param.order_id = p-order-id
    and buf2_tt0-rule-call-param.param-name = p-param-name
    and buf2_tt0-rule-call-param.p-index > buf_tt0-rule-call-param.p-index   :
    if buffer buf_tt0-rule-call-param:handle:buffer-field( substitute("param-value-&1", p-param-data-type)):buffer-value =
       buffer buf2_tt0-rule-call-param:handle:buffer-field( substitute("param-value-&1", p-param-data-type)):buffer-value
    then do:
      undo, return error ''.
    end.
  end.
  find first buf_tt0-rule-call-param where
          buf_tt0-rule-call-param.call_id = p-call-id
      and buf_tt0-rule-call-param.codex_id = p-codex-id
      and buf_tt0-rule-call-param.ruleset_id = p-ruleset-id
      and buf_tt0-rule-call-param.order_id = p-order-id
      and buf_tt0-rule-call-param.param-name = p-param-name
      and buf_tt0-rule-call-param.p-index > v-current-index
      no-error.

end. /*do while available buf_tt0-rule-call-param*/
end procedure. /* check-list-unique */