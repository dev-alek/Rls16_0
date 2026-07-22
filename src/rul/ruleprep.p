block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Сборка одного правила

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/25/06
Author: Bakhtadze Natalya
Creation date: 10/25/06

*/

define input parameter p-rule-id as integer no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Сборка одного правила".
{ cmp/vssrevis.i }{ cmp/str-glbl.i }
{ rul/tempstrn.i }
{ rul/fillrule.i }
{ rul/disprule.i }
{ rul/dispscrp.i }
{ gbl/key-rec.i }


define variable v-tbl-row as rowid no-undo .
define variable v-tbl-name as character no-undo .
define variable v-level as integer no-undo .
define variable ss as character no-undo .
define variable v-path                    as character                no-undo .
DEFINE VARIABLE v-full-path               as character                no-undo .
DEFINE VARIABLE v-file-name               as character                no-undo .
DEFINE VARIABLE v-file-name-no-ext        as character                no-undo .
DEFINE VARIABLE v-file-name-ext           as character                no-undo .
define variable v-ii as integer no-undo .
define variable v-script-type-list as character no-undo .
define variable v-include-flag            as logical no-undo .
define variable v-key-ruleset             as character no-undo .
define variable v-key-ruleset-2           as character no-undo .
define variable v-count-retry-action as logical no-undo .
define variable v-found as logical no-undo .

define stream Outstream.
define stream instream.
define stream errstream .

define buffer buf_rule-i-script for ub.rule-i-script.
define buffer buf_prop-script for ub.prop-script.
define buffer buf_prop-ruleset for ub.prop-ruleset.
define buffer buf_temp-string for temp-string.
define buffer buf_rule-by-set  for ub.rule-by-set.
define buffer buf_rule for ub.rule.


main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
:
  find first buf_rule no-lock where buf_rule.rule_id = p-rule-id no-error.
  if not available buf_rule then do:
    undo main-block, return error substitute("Не найдено правило &1", p-rule-id).
  end.
  if buf_rule.upper_rule_id <> 0 then do:
    undo main-block, return error substitute("Правило &1 не является корневым", p-rule-id).
  end.
  run temp-string_clear in this-procedure .
  for each buf_rule-by-set no-lock where
          buf_rule-by-set.rule_id = buf_rule.rule_id :
    run gbl/filename.p (
                    input substitute( "rul/&1&2.i", string(buf_rule.codex_id, "9999"), string(buf_rule-by-set.ruleset_id, "9999"))
                  ,output v-full-path
                  ,output v-path
                  ,output v-file-name
                  ,output v-file-name-no-ext
                  ,output v-file-name-ext
                  ) no-error .
    if error-status:error then do:
      next.
    end.
    else do:
      v-found = yes.
      leave .
    end.
  end.
  if v-found then do:
  end.
  else do:
    run gbl/filename.p (
                    input substitute( "rul/&10000.i", string(buf_rule.codex_id, "9999"))
                  ,output v-full-path
                  ,output v-path
                  ,output v-file-name
                  ,output v-file-name-no-ext
                  ,output v-file-name-ext
                  ) no-error .
    if error-status:error then do:
      undo main-block, return error return-value.
    end.
  end.
  RUN fill-tables IN THIS-PROCEDURE (  INPUT buf_rule.RULE_id
                                  ,INPUT buf_rule.root_RULE_id
                                  ,INPUT-OUTPUT v-level
                                  ,INPUT "") no-error.

  input stream instream from value (v-full-path).
  v-include-flag = yes.
  _repeat:
  repeat :
    import stream instream unformatted ss.
    if index(ss, "&start-codex_id") > 0 then do:
      assign
      v-key-ruleset = entry(2, ss, "&").
      for each buf_rule-by-set no-lock where
              buf_rule-by-set.rule_id = buf_rule.root_rule_id:
        assign
        v-key-ruleset-2 = substitute("start-codex_id=&1;ruleset_id=&2"
                                      , buf_rule-by-set.codex_id
                                      , buf_rule-by-set.ruleset_id).
        if v-key-ruleset-2 = v-key-ruleset then do:
           v-include-flag = no.
        end.
      end.
    end.
    if index(ss, "&end-codex_id") > 0 then do:
      v-include-flag = yes.
    end.
    if v-include-flag = no then next _repeat.
    run temp-string_write in this-procedure ( input  ss).
    if index(ss, "&start-using-class&") > 0 then do:
      run using-class in this-procedure (  buffer buf_rule ).
    end.
    if index(ss, "&start-rule-call-param&") > 0 then do:
      run rule-call-param in this-procedure (  buffer buf_rule ).
    end.
    if index(ss, "&start-def-vars&") > 0 then do:
      run process-def-vars in this-procedure (  input buf_rule.rule_id ) no-error.
      if error-status:error then do:
         undo, return error .
      end.
    end.
    if index(ss, "&count-retry-action-start&") > 0 then do:
      v-count-retry-action = yes.
    end.
    if index(ss, "&count-retry-action-end&") > 0 then do:
      v-count-retry-action = no.
    end.
    if index(ss, "&start-release-obj&") > 0 then do:
      run process-release-obj in this-procedure (  input buf_rule.rule_id ) no-error.
      if error-status:error then do:
         undo, return error .
      end.
    end.
    if index(ss, "&start-process-rule-call-param&") > 0 then do:
      run process-rule-call-param in this-procedure ( buffer buf_rule ).
    end.
    if index(ss, "&start-i-script&") > 0 then do:
      run hist-news-class in this-procedure (  buffer buf_rule ).
      v-script-type-list = {&prop-script-type-define-b} + {&comma-char} +
                            {&prop-script-type-define-tt} + {&comma-char} +
                            {&prop-script-type-define-h} + {&comma-char} +
                            {&prop-script-type-variable}
                            .
      do v-ii = 1 to num-entries(v-script-type-list):
        run cycle-script-type in this-procedure ( input p-rule-id, input entry(v-ii, v-script-type-list)) no-error .
        if error-status:error then do:
          undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)).
        end.
      end.
      _rule-i-script:
      for each buf_rule-i-script no-lock where
              buf_rule-i-script.root_rule_id = p-rule-id,
          each  buf_prop-script no-lock where
                    buf_prop-script.dtm-code = buf_rule-i-script.dtm-code
                and  buf_prop-script.language = "ABL"
                and  buf_prop-script.script-name = buf_rule-i-script.script-name
                and  buf_prop-script.revis_id = buf_rule-i-script.revis_id
      break
      by buf_rule-i-script.i-script-name
      on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
      :
        if first-of(buf_rule-i-script.i-script-name) then do:
          if not (buf_prop-script.language = "ABL") then next _rule-i-script.
          if lookup(buf_rule-i-script.i-script-type, v-script-type-list) > 0 then next _rule-i-script.
          if lookup(buf_prop-script.script-type, "hist-nws") > 0 then next _rule-i-script.
          run display-prop-script in this-procedure ( buffer buf_prop-script).
        end.
      end.  /*for each buf_rule-i-script no-lock where*/
      _rule-i-script:
      for each buf_rule-i-script no-lock where
              buf_rule-i-script.root_rule_id = p-rule-id
          and buf_rule-i-script.script-type = '':U
      break
      by buf_rule-i-script.i-script-name
      on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
      :
        if first-of(buf_rule-i-script.i-script-name) then do:
          if not (buf_prop-script.language = "ABL") then next _rule-i-script.
          if lookup(buf_rule-i-script.i-script-type, v-script-type-list) > 0 then next _rule-i-script.
          if lookup(buf_prop-script.script-type, "hist-nws") > 0 then next _rule-i-script.
          run display-subsid-rule-i-script in this-procedure ( buffer buf_rule-i-script).
        end.
      end.  /*for each buf_rule-i-script no-lock where*/
    end. /*if index(ss, &start-rule-i-script) > 0 then do:*/
    if index(ss, "&start-hn-option&") > 0 then do:
      run cycle-script-type in this-procedure ( input p-rule-id, "hist-nws") no-error .
      if error-status:error then do:
        undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)).
      end.
    end.
    if index(ss, "&start-rule&") > 0 then do:
      run display-rule in this-procedure ( input p-rule-id
                                        , input 0 /*p-upper-rule-id*/
                                        , input "ABL":U
                                        , input-output v-level).
    end. /*if index(ss, "&start-rule") > 0 then do:*/
  end.

  input stream instream close.

  output stream outstream to value( substitute( "rul/&1.p" ,string(p-rule-id, "999999999"))).

  for each buf_temp-string
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  :
    put stream outstream unformatted buf_temp-string.v-string {&new-line}.

  end.
  output stream outstream close.
  define variable v-old-sys-alert-box as logical no-undo .
  define variable v-err-num as integer no-undo .
  define variable v-err-size as integer no-undo .
  define variable v-tmp-str as character no-undo .
  define variable v-err-cmp as character no-undo .
  v-old-sys-alert-box    = session :system-alert-boxes.
  session :system-alert-boxes = false.
  output to value( "cmp-err.txt":U) .
  COMPILE value( substitute( "rul/&1.p" ,string(p-rule-id, "999999999"))).
  assign
    v-err-num  = error-status :GET-NUMBER(1)
    v-err-size = seek(output)
  .
  output close .
  assign
    session :system-alert-boxes = v-old-sys-alert-box
  .

  if error-status :error
    or compiler :error
  then do:
    input stream errstream from value( "cmp-err.txt":U).
    repeat :
      import stream errstream unformatted v-tmp-str .
      assign
        v-err-cmp = v-err-cmp + {&new-line} + v-tmp-str
      .
    end.
    input stream errstream close.
      message
        vss-workfile vss-revision vss-description skip
        substitute( "Ошибка компиляции файла &1 строка &2", COMPILER:FILENAME, COMPILER:ERROR-ROW ) skip
        v-err-cmp skip
        error-status :get-message(1) skip
        view-as alert-box error .
      return error.
   end.
end. /*doe*/


procedure cycle-script-type:
define input parameter p-rule-id as integer no-undo .
define input parameter p-i-script-type as character no-undo .
define buffer buf_rule-i-script for ub.rule-i-script.
define buffer buf_dis-porp-script for ub.prop-script.

  main-block:
  do
  on error undo, return error
  :

    _rule-i-script:
    for each buf_rule-i-script no-lock where
            buf_rule-i-script.root_rule_id = p-rule-id
        and buf_rule-i-script.i-script-type = p-i-script-type
            ,
        each  buf_prop-script no-lock where
                  buf_prop-script.dtm-code = buf_rule-i-script.dtm-code
              and  buf_prop-script.script-name = buf_rule-i-script.script-name
              and  buf_prop-script.script-type = buf_rule-i-script.script-type
              and  buf_prop-script.revis_id = buf_rule-i-script.revis_id
    on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    :
      if not (buf_prop-script.language = "ABL") then next _rule-i-script.
      if buf_rule-i-script.i-script-type = {&prop-script-type-variable} then do:
        run temp-string_write in this-procedure ( input substitute("define variable &1 as &2 no-undo."
                                                                   ,buf_rule-i-script.i-script-name
                                                                   ,buf_prop-script.script-value-type)
                                                ).
      end.
      else do:
        run display-prop-script in this-procedure ( buffer buf_prop-script).
      end.
    end.  /*for each buf_rule-i-script no-lock where*/
  end.

end procedure. /* cycle-script-typ */

procedure rule-call-param :
define parameter buffer buf_rule for ub.rule.
define variable v-uniq-key-rec as character no-undo .
define buffer buf_ruledict-param  for ub.ruledict-param.
define buffer buf_ruledict for ub.ruledict.
define variable v-string as character no-undo .

_main:
do
on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
:
  run gen-key-rec in this-procedure (
                                     input  {&table_rule}
                                    ,input buffer buf_rule:handle
                                    ,output v-uniq-key-rec ).
  find first buf_ruledict no-lock where
           buf_ruledict.entry-type = {&rdict-etype-rule}
       AND buf_ruledict.uniq-key-rec = v-uniq-key-rec
       AND buf_ruledict.language = "ABL"       .
  for each buf_ruledict-param no-lock where
          buf_ruledict-param.entry-id = buf_ruledict.entry-id
      and buf_ruledict-param.language = "ABL":U
  by buf_ruledict-param.param-num
  on error undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)):
    CASE buf_ruledict-param.param-mode:
      when {&script-parmode-input} then do:
        assign
        v-string = substitute(" define variable &1 as &2 no-undo."
                                ,buf_ruledict-param.param-name
                                ,buf_ruledict-param.param-data-type
                                ).
      end.
      when {&script-parmode-output} then do:
      end.
      when {&script-parmode-inout} then do:
      end.
      when {&script-parmode-buffer } then do:
      end.
      when {&script-parmode-intable} then do:
      end.
      when {&script-parmode-outtable} then do:
      end.
      when {&script-parmode-inouttable} then do:
      end.
    end case.

    run temp-string_write in this-procedure ( input v-string ).
  end.
end.
end procedure. /* rule-call-param */

procedure using-class :
define parameter buffer buf_rule for ub.rule.

main-block:
do
on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
:

define buffer buf_temp-rule-i-script for temp-rule-i-script.
define buffer buf_rule-i-script for ub.rule-i-script.
define buffer buf_prop-script for ub.prop-script.
define buffer buf0_prop-script for ub.prop-script.
  _rule-i-script:
  for each buf_rule-i-script no-lock where
            buf_rule-i-script.root_rule_id = p-rule-id
  break
  by buf_rule-i-script.script-name
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  :
    if first-of(buf_rule-i-script.script-name) then do:
      if buf_rule-i-script.script-type = '':U then next _rule-i-script.
      if buf_rule-i-script.i-script-type = {&prop-script-type-variable} then do:
        if lookup(buf_rule-i-script.script-type, {&ABL-datatype-list}) > 0 then next.
        find last  buf_prop-script no-lock where
                   buf_prop-script.dtm-code = buf_rule-i-script.dtm-code
              and  buf_prop-script.script-name = buf_rule-i-script.script-type
              and  buf_prop-script.language = "ABL"  no-error.
        if not available buf_prop-script then do:
          message
          substitute( "Секция &&start-using-class&&&2" +
                      "Не найден класс &1&2" +
                      "Переменная &3&2" +
                      "Код объекта-операнда &4&2" +
                      "Код класса &5&2"
                     , buf_rule-i-script.script-type
                     , {&new-line}
                     , buf_rule-i-script.script-name
                     , buf_rule-i-script.dtm-code
                     , buf_rule-i-script.class-dtm-code
                     )
          view-as alert-box .
          return error.
        end.
      end.
      else do:
        find first buf0_prop-script no-lock where
                  buf0_prop-script.dtm-code = buf_rule-i-script.dtm-code
              and buf0_prop-script.script-name = buf_rule-i-script.script-name
              and buf0_prop-script.language = "ABL" no-error .
        if not available buf0_prop-script then do:
          message
          substitute("Секция &&start-using-class&&&1" +
                     "Не найдено определение скрипта &1" +
                      "Тип Скрипта &2&1" +
                      "Скрипт &3&1" +
                      "Ссылка на определение &4&1" +
                      "Код объекта-операнда &5&1" +
                      "Код класса &6&1"
                    , {&new-line}
                     , buf_rule-i-script.script-type
                     , buf_rule-i-script.i-script-name
                     , buf_rule-i-script.script-name
                     , buf_rule-i-script.dtm-code
                     , buf_rule-i-script.class-dtm-code
                     )
          view-as alert-box .
          return error.
        END.
        if lookup(buf0_prop-script.proc-type, {&script-class-child-list}) = 0  then next _rule-i-script.
        find last  buf_prop-script no-lock where
                  buf_prop-script.dtm-code = buf_rule-i-script.class-dtm-code
              and buf_prop-script.script-name = buf_rule-i-script.script-type
              and  buf_prop-script.proc-type = {&script-ptype-class}
              and  buf_prop-script.language = "ABL"  no-error.
        if not available buf_prop-script then do:
          message
          substitute("Секция &&start-using-class&&&1" +
                      "Не найден класс &2&1" +
                      "Тип Скрипта &2&1" +
                      "Скрипт &3&1" +
                      "Ссылка на определение &4&1" +
                      "Код объекта-операнда &5&1" +
                      "Код класса &6"
                     , {&new-line}
                     , buf_rule-i-script.script-type
                     , buf_rule-i-script.i-script-name
                     , buf_rule-i-script.script-name
                     , buf_rule-i-script.dtm-code
                     , buf_rule-i-script.class-dtm-code
                     )
          view-as alert-box .
          return error.
        end.
      end.
      find first buf_temp-rule-i-script no-lock where
                buf_temp-rule-i-script.root_rule_id = p-rule-id
            and buf_temp-rule-i-script.i-script-name = buf_prop-script.script-body no-error.
      if available buf_temp-rule-i-script then next.
      create buf_temp-rule-i-script.
      assign
      buf_temp-rule-i-script.root_rule_id  = p-rule-id
      buf_temp-rule-i-script.i-script-type = {&script-ptype-class}
      buf_temp-rule-i-script.i-script-name = buf_prop-script.script-body
      .
      run temp-string_write in this-procedure ( input buf_prop-script.script-body ).
    end. /*if first-of(buf_rule-i-script.i-script-name) then do:*/
  end.   /*for each buf_rule-i-script no-lock where*/
end. /*dor*/

end procedure. /* using-class */


procedure hist-news-class :
define parameter buffer buf_rule for ub.rule.

main-block:
do
on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
:
define variable v-revis-id as integer no-undo .
define variable v-script-name as character no-undo .
define buffer buf_temp-rule-i-script for temp-rule-i-script.
define buffer buf_rule-i-script for ub.rule-i-script.
define buffer buf_prop-script for ub.prop-script.
define buffer buf0_prop-script for ub.prop-script.
  _rule-i-script:
  for each buf_rule-i-script no-lock where
            buf_rule-i-script.root_rule_id = p-rule-id
  break
  by buf_rule-i-script.script-name
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  :
    if buf_rule-i-script.i-script-type = {&prop-script-type-variable}
    or buf_rule-i-script.i-script-type = {&prop-script-type-get}
    or buf_rule-i-script.i-script-type = {&prop-script-type-find}
    or buf_rule-i-script.i-script-type = {&prop-script-type-define-b}
    or buf_rule-i-script.i-script-type = {&prop-script-type-define-tt}
    or buf_rule-i-script.i-script-type = {&prop-script-type-define-h}
    or buf_rule-i-script.script-type = '':U
    then next _rule-i-script.
    find first buf0_prop-script no-lock where
              buf0_prop-script.dtm-code = buf_rule-i-script.dtm-code
          and buf0_prop-script.script-name = buf_rule-i-script.script-name
          and buf0_prop-script.language = "ABL"
          and buf0_prop-script.revis_id = buf_rule-i-script.revis_id no-error .
    if not available buf0_prop-script then do:
      message
      substitute("Секция &&start-hn-option&&&1" +
                  "Не найдено определение скрипта &1" +
                  "Тип Скрипта &2&1" +
                  "Скрипт &3&1" +
                  "Ссылка на определение &4&1" +
                  "Код объекта-операнда &5&1" +
                  "Код класса &6&1" +
                  "Версия &7"
                , {&new-line}
                  , buf_rule-i-script.script-type
                  , buf_rule-i-script.i-script-name
                  , buf_rule-i-script.script-name
                  , buf_rule-i-script.dtm-code
                  , buf_rule-i-script.class-dtm-code
                  , buf_rule-i-script.revis_id
                  )
      view-as alert-box .
      return error.
    END.
    v-revis-id = -1.
    v-script-name = '':U.
    if lookup(buf0_prop-script.proc-type, {&script-class-child-list}) = 0  then next _rule-i-script.
    for each buf_prop-script no-lock where
              buf_prop-script.class-dtm-code = buf_rule-i-script.class-dtm-code
          and buf_prop-script.dtm-code = buf_rule-i-script.dtm-code
          and  buf_prop-script.script-type = {&prop-script-type-ifunction}
          and  buf_prop-script.language = "ABL"
    by buf_prop-script.script-name
    by buf_prop-script.revis_id:
      if not (index(buf_prop-script.script-name, "~{&hist-nws_") > 0
              and  buf_prop-script.script-head = buf_rule-i-script.script-type )
      and not buf_prop-script.script-name begins(buf_rule-i-script.script-type + "~{&hist-nws_")
              then next.
      if buf_prop-script.revis_id > v-revis-id then do:
        v-revis-id = buf_prop-script.revis_id.
        v-script-name = buf_prop-script.script-name.
      end.
    end.
    find first buf_prop-script no-lock where
              buf_prop-script.dtm-code = buf_rule-i-script.dtm-code
          and buf_prop-script.class-dtm-code = buf_rule-i-script.class-dtm-code
          and buf_prop-script.language = "ABL"
          and buf_prop-script.script-type = {&prop-script-type-ifunction}
          and buf_prop-script.script-name = v-script-name
          and buf_prop-script.revis_id = v-revis-id no-error .
    if not available buf_prop-script then do:
      message
      substitute("Секция &&start-hn-option&&&2" +
                  "Не найдена процедура обработки истории и маршрутизации для класса &1&2(&6)&2" +
                  "Скрипт &3&2" +
                  "Код объекта-операнда &4&2" +
                  "Код класса &5"
                  , buf_rule-i-script.script-type
                  , {&new-line}
                  , buf_rule-i-script.i-script-name
                  , buf_rule-i-script.dtm-code
                  , buf_rule-i-script.class-dtm-code
                  , v-script-name
                  )
      view-as alert-box .
      return error.
    end.
    find first buf_temp-rule-i-script no-lock where
              buf_temp-rule-i-script.root_rule_id = p-rule-id
          and buf_temp-rule-i-script.i-script-name = buf_prop-script.script-name
          and buf_temp-rule-i-script.i-script-type = "hist-news"
          no-error.
    if available buf_temp-rule-i-script then next.
    create buf_temp-rule-i-script.
    assign
    buf_temp-rule-i-script.root_rule_id  = p-rule-id
    buf_temp-rule-i-script.i-script-type = "hist-news"
    buf_temp-rule-i-script.i-script-name = buf_prop-script.script-name
    .
    run temp-string_write in this-procedure ( input buf_prop-script.script-body ).
  end.   /*for each buf_rule-i-script no-lock where*/
end. /*dor*/

end procedure. /* hist-news-class */



procedure process-rule-call-param :
define parameter buffer buf_rule for ub.rule.
define variable v-uniq-key-rec as character no-undo .
define variable v-string as character no-undo .
define buffer buf_ruledict-param  for ub.ruledict-param.
define buffer buf_ruledict for ub.ruledict.


_main:
do
on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
:
  run gen-key-rec in this-procedure (
                                     input  {&table_rule}
                                    ,input buffer buf_rule:handle
                                    ,output v-uniq-key-rec ).
  find first buf_ruledict no-lock where
           buf_ruledict.entry-type = {&rdict-etype-rule}
       AND buf_ruledict.uniq-key-rec = v-uniq-key-rec
       AND buf_ruledict.language = "ABL"
       .
  for each buf_ruledict-param no-lock where
          buf_ruledict-param.entry-id = buf_ruledict.entry-id
      and buf_ruledict-param.language = "ABL":U
  by buf_ruledict-param.param-num
  on error undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)):
    CASE buf_ruledict-param.param-mode:
      when {&script-parmode-input} then do:
        if
        lookup("LIST", buf_ruledict-param.param-3-data-type) > 0
        or
        lookup("SORTED-LIST", buf_ruledict-param.param-3-data-type) > 0
        then do:
          assign
          v-string = substitute(
         "for each buf_rule-call-param no-lock where&1" +
                "buf_rule-call-param.codex_id = p-codex-id&1" +
            "and buf_rule-call-param.ruleset_id = p-ruleset-id&1" +
            "and buf_rule-call-param.call_id = p-call-id&1" +
            "and buf_rule-call-param.order_id = p-order-id&1" +
            "and buf_rule-call-param.rule_id = p-rule-id&1" +
            'and buf_rule-call-param.param-name = "&2"&1' +
            'and buf_rule-call-param.p-index > 0:&1' +
            'create buf_temp-rule-call-param.&1' +
            'buffer-copy buf_rule-call-param to buf_temp-rule-call-param.&1' +
            'release buf_temp-rule-call-param.&1' +
         'end.&1'
         , {&new-line}
         , buf_ruledict-param.param-name
         ).
        end.
        else do:
          assign
          v-string = substitute(" find first buf_rule-call-param no-lock where&1" +
                                            "buf_rule-call-param.codex_id = p-codex-id&1" +
                                        "and buf_rule-call-param.ruleset_id = p-ruleset-id&1" +
                                        "and buf_rule-call-param.call_id = p-call-id&1" +
                                        "and buf_rule-call-param.order_id = p-order-id&1" +
                                        "and buf_rule-call-param.rule_id = p-rule-id&1" +
                                        'and buf_rule-call-param.param-name = "&2"&1 no-error.&1' +
                                        "if available buf_rule-call-param then do:&1" +
                                        "assign &2 = buf_rule-call-param.param-value-&3.&1" +
                                        "end.&1"
                                  , {&new-line}
                                  , buf_ruledict-param.param-name
                                  , buf_ruledict-param.param-data-type).
        end.
      end.
      when {&script-parmode-output} then do:
      end.
      when {&script-parmode-inout} then do:
      end.
      when {&script-parmode-buffer } then do:
      end.
      when {&script-parmode-intable} then do:
      end.
      when {&script-parmode-outtable} then do:
      end.
      when {&script-parmode-inouttable} then do:
      end.
    end case.
    run temp-string_write in this-procedure ( input v-string ).
  end.
end.

end procedure. /* process-rule-call-param */

procedure process-release-obj :
define input parameter p-rule-id as integer no-undo .

define variable v-revis-id as integer no-undo .
define variable v-script-name as character no-undo .
define variable v-release-name as character no-undo .
define variable v-retry-action as integer no-undo .
define buffer buf_rule-i-script for ub.rule-i-script.
define buffer buf_prop-script for ub.prop-script.
define buffer buf2_prop-script for ub.prop-script.
define buffer buf_pscript-ruleset for ub.pscript-ruleset.
define buffer buf_temp-rule-i-script for temp-rule-i-script.
define buffer buf_rule-script for ub.rule-script.
define buffer buf_tt-rule-script for tt-rule-script.
main-block:
do
on error undo, return error
:
  _rule-script:
  for each buf_tt-rule-script,
      each  buf_rule-i-script no-lock where
            buf_rule-i-script.root_rule_id = p-rule-id
       and  buf_rule-i-script.i-script-type = {&prop-script-type-variable}
       and buf_rule-i-script.script_id = buf_tt-rule-script.script_id
  by buf_tt-rule-script.gen-order
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  :
    find first buf_rule-script where
              buf_rule-script.root_rule_id = p-rule-id
          and  buf_rule-script.script_id = buf_rule-i-script.script_id.
    if lookup(buf_rule-i-script.script-type, {&ABL-datatype-list}) = 0 then do:
      assign
      v-revis-id = -1
      v-script-name = '':U
      .
      for each buf_pscript-ruleset no-lock where
              buf_pscript-ruleset.codex_id = buf_rule.codex_id
          and buf_pscript-ruleset.dtm-code = buf_rule-i-script.dtm-code
          and buf_pscript-ruleset.script-name begins (buf_rule-i-script.script-type + "~{&release_")
          and buf_pscript-ruleset.language = "ABL",
          first  buf_prop-script no-lock where
                buf_prop-script.dtm-code = buf_rule-i-script.dtm-code
            and buf_prop-script.class-dtm-code = buf_rule-i-script.class-dtm-code
            and buf_prop-script.language = "ABL"
            and buf_prop-script.proc-type = {&script-ptype-method}
            and buf_prop-script.script-name = buf_pscript-ruleset.script-name
            and buf_prop-script.revis_id = buf_pscript-ruleset.revis_id
      by buf_pscript-ruleset.script-name
      by buf_pscript-ruleset.revis_id :
        if buf_prop-script.revis_id > v-revis-id then do:
          v-revis-id = buf_prop-script.revis_id.
          v-script-name = buf_prop-script.script-name.
        end.
      end.
      find first buf_prop-script no-lock where
                buf_prop-script.dtm-code = buf_rule-i-script.dtm-code
            and buf_prop-script.class-dtm-code = buf_rule-i-script.class-dtm-code
            and buf_prop-script.language = "ABL"
            and buf_prop-script.proc-type = {&script-ptype-method}
            and buf_prop-script.script-name = v-script-name
            and buf_prop-script.revis_id = v-revis-id no-error .
      if not available buf_prop-script then do:
        message
        substitute("Секция &&start-release-obj&&&3" +
                    "Не найден метод освобождения переменной &1 для класса &2&3" +
                    "Код объекта-операнда &4&3" +
                    "Код класса &5"
                  , v-script-name
                    , buf_rule-i-script.script-type
                    , {&new-line}
                    , buf_rule-i-script.dtm-code
                    , buf_rule-i-script.class-dtm-code
                    )
        view-as alert-box error .
        undo, return error .
      end.
      if buf_rule-i-script.dtm-code <> buf_rule-i-script.class-dtm-code then do:
        find first buf2_prop-script no-lock where
                  buf2_prop-script.dtm-code = buf_rule-i-script.dtm-code
              and buf2_prop-script.class-dtm-code = buf_rule-i-script.class-dtm-code
              and buf2_prop-script.language = "ABL"
              and buf2_prop-script.proc-type = {&script-ptype-CLASS}
              and buf2_prop-script.script-name = buf_rule-i-script.script-type
              and buf2_prop-script.revis_id = v-revis-id no-error .
        if not available buf2_prop-script then do:
          message
          substitute("Секция &&start-release-obj&&&2" +
                      "Не найден класс &1&2" +
                      "Код объекта-операнда &3&2" +
                      "Код класса &4"
                    ,buf_rule-i-script.script-type
                    ,{&new-line}
                    ,buf_rule-i-script.dtm-code
                    ,buf_rule-i-script.class-dtm-code
                    )
          view-as alert-box error .
          undo, return error .
        end.
        v-release-name =  replace(buf_prop-script.script-name
                                      ,buf2_prop-script.script-name
                                      ,buf2_prop-script.script-head).
      end. /*if buf_rule-i-script.dtm-code <> buf_rule-i-script.class-dtm-code then do:*/
      else do:
        v-release-name =  buf_prop-script.script-name.
      end.
      find first buf_temp-rule-i-script no-lock where
                buf_temp-rule-i-script.root_rule_id = p-rule-id
            and buf_temp-rule-i-script.script_id = buf_tt-rule-script.script_id
            and buf_temp-rule-i-script.i-script-name = v-release-name no-error.
      if available buf_temp-rule-i-script then next _rule-script.
      create buf_temp-rule-i-script.
      assign
      buf_temp-rule-i-script.root_rule_id  = p-rule-id
      buf_temp-rule-i-script.script_id     = buf_tt-rule-script.script_id
      buf_temp-rule-i-script.i-script-type = {&script-ptype-method}
      buf_temp-rule-i-script.i-script-name = v-release-name
      buf_temp-rule-i-script.script-name = "release"
      .
      if v-count-retry-action = yes then do:
        v-retry-action = v-retry-action + 1.
        run temp-string_write in this-procedure ( input  substitute("if v-retry-action < &1 then do:"
                                                                    ,v-retry-action
                                                                    )).
      end.
      run temp-string_write in this-procedure ( input  substitute("&1"
                                                                  ,buf_prop-script.script-foot
                                                                  )).

      run temp-string_write in this-procedure ( input  substitute("&1:&2 ."
                                                                  ,buf_rule-i-script.script-name
                                                                  ,v-release-name
                                                                  )).
      if v-count-retry-action = yes then do:
        run temp-string_write in this-procedure ( input  substitute("end."
                                                                    )).
      end.

    end.
  end.   /*for each buf_rule-i-script no-lock where*/
  for each buf_temp-rule-i-script where
          buf_temp-rule-i-script.script-name = "release":
    delete buf_temp-rule-i-script.
  end.
end.

end procedure. /* process-def-vars */


procedure process-def-vars :
define input parameter p-rule-id as integer no-undo .

define variable v-revis-id as integer no-undo .
define variable v-script-name as character no-undo .
define variable v-constructor-name as character no-undo .
define buffer buf_rule-i-script for ub.rule-i-script.
define buffer buf_prop-script for ub.prop-script.
define buffer buf2_prop-script for ub.prop-script.
define buffer buf_pscript-ruleset for ub.pscript-ruleset.
define buffer buf_temp-rule-i-script for temp-rule-i-script.
define buffer buf_rule-script for ub.rule-script.
main-block:
do
on error undo, return error
:

  for each buf_rule-i-script no-lock where
            buf_rule-i-script.root_rule_id = p-rule-id
       and  buf_rule-i-script.i-script-type = {&prop-script-type-variable}
  break
  by buf_rule-i-script.i-script-name
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  :
    if first-of(buf_rule-i-script.i-script-name) then do:
      find first buf_temp-rule-i-script no-lock where
                buf_temp-rule-i-script.root_rule_id = p-rule-id
            and buf_temp-rule-i-script.i-script-name = buf_rule-i-script.script-name no-error.
      if available buf_temp-rule-i-script then next.
      create buf_temp-rule-i-script.
      assign
      buf_temp-rule-i-script.root_rule_id  = p-rule-id
      buf_temp-rule-i-script.i-script-type = {&prop-script-type-variable}
      buf_temp-rule-i-script.i-script-name = buf_rule-i-script.script-name
      .
      find first buf_rule-script where
                buf_rule-script.root_rule_id = p-rule-id
           and  buf_rule-script.script_id = buf_rule-i-script.script_id.
      run temp-string_write in this-procedure ( input  substitute("&1 ."
                                                                  ,buf_rule-script.script)).
      if lookup(buf_rule-i-script.script-type, {&ABL-datatype-list}) = 0 then do:
        assign
        v-revis-id = -1
        v-script-name = '':U
        .
        for each buf_pscript-ruleset no-lock where
                buf_pscript-ruleset.codex_id = buf_rule.codex_id
            and buf_pscript-ruleset.dtm-code = buf_rule-i-script.dtm-code
            and buf_pscript-ruleset.script-name begins (buf_rule-i-script.script-type + "~{&constructor_")
            and buf_pscript-ruleset.language = "ABL",
           first  buf_prop-script no-lock where
                  buf_prop-script.dtm-code = buf_rule-i-script.dtm-code
              and buf_prop-script.class-dtm-code = buf_rule-i-script.class-dtm-code
              and buf_prop-script.language = "ABL"
              and buf_prop-script.proc-type = {&script-ptype-constructor}
              and buf_prop-script.script-name = buf_pscript-ruleset.script-name
              and buf_prop-script.revis_id = buf_pscript-ruleset.revis_id
       by buf_prop-script.script-name
       by buf_prop-script.revis_id :
          if buf_prop-script.revis_id > v-revis-id then do:
            v-revis-id = buf_prop-script.revis_id.
            v-script-name = buf_prop-script.script-name.
          end.
        end.
        find first buf_prop-script no-lock where
                  buf_prop-script.dtm-code = buf_rule-i-script.dtm-code
              and buf_prop-script.class-dtm-code = buf_rule-i-script.class-dtm-code
              and buf_prop-script.language = "ABL"
              and buf_prop-script.proc-type = {&script-ptype-constructor}
              and buf_prop-script.script-name = v-script-name
              and buf_prop-script.revis_id = v-revis-id no-error .
        if not available buf_prop-script then do:
          message
          substitute("Секция &&start-def-vars&&&3" +
                      "Не найден конструктор &1 для класса &2&3" +
                      "Код объекта-операнда &4&3" +
                      "Код класса &5"
                     ,v-script-name
                     ,buf_rule-i-script.script-type
                     ,{&new-line}
                     ,buf_rule-i-script.dtm-code
                     ,buf_rule-i-script.class-dtm-code
                     )
          view-as alert-box error .
          undo, return error .
        end.
        if buf_rule-i-script.dtm-code <> buf_rule-i-script.class-dtm-code then do:
          find first buf2_prop-script no-lock where
                    buf2_prop-script.dtm-code = buf_rule-i-script.dtm-code
                and buf2_prop-script.class-dtm-code = buf_rule-i-script.class-dtm-code
                and buf2_prop-script.language = "ABL"
                and buf2_prop-script.proc-type = {&script-ptype-CLASS}
                and buf2_prop-script.script-name = buf_rule-i-script.script-type
                and buf2_prop-script.revis_id = v-revis-id no-error .
          if not available buf2_prop-script then do:
            message
            substitute("Секция &&start-def-vars&&&2" +
                        "Не найден класс &1&2" +
                        "Код объекта-операнда &3&2" +
                        "Код класса &4"
                      ,buf_rule-i-script.script-type
                      ,{&new-line}
                      ,buf_rule-i-script.dtm-code
                      ,buf_rule-i-script.class-dtm-code
                      )
            view-as alert-box error .
            undo, return error .
          end.
          v-constructor-name =  replace(buf_prop-script.script-name
                                        ,buf2_prop-script.script-name
                                        ,buf2_prop-script.script-head).
        end. /*if buf_rule-i-script.dtm-code <> buf_rule-i-script.class-dtm-code then do:*/
        else do:
          v-constructor-name =  buf_prop-script.script-name.
        end.
        run temp-string_write in this-procedure ( input  substitute("&1"
                                                                    ,buf_prop-script.script-foot
                                                                    )).

        run temp-string_write in this-procedure ( input  substitute("&1 = new &2 ."
                                                                    ,buf_rule-i-script.script-name
                                                                    ,v-constructor-name
                                                                    )).
      end.
    end. /*if first-of(buf_rule-i-script.i-script-name) then do:*/
  end.   /*for each buf_rule-i-script no-lock where*/

end.

end procedure. /* process-def-vars */



procedure display-subsid-rule-i-script :
define parameter buffer buf_rule-i-script for ub.rule-i-script.

  do
  on error undo, return error
  :
    run temp-string_write in this-procedure ( input buf_rule-i-script.script-name ).

  end.

end procedure. /* display-subsid-rule-i-script */