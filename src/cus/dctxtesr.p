block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: dctxtesr.p $
$Archive: cus/dctxtesr.p $

Экспорт данных по продажам по ДК в текстовый файл - исполняемый модуль - вызов по расписанию

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/18/05
Author: Bakhtadze Natalya
Creation date: 11/18/05

*/

define input parameter parparentproc    as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-cre-db-num     as integer      no-undo .
define input parameter p-task-type      as character    no-undo.
define input parameter p-task-num       as integer      no-undo.
define input parameter p-db-num         as integer      no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: dctxtesr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/dctxtesr.p $":U .
define variable vss-description as character no-undo init "Экспорт данных по продажам по ДК в текстовый файл - исполняемый модуль - вызов по расписанию".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
{ adm/auto-def.i    }
{ ref/shd-attr.i    }
{ cmp/ini-lib.i }


do
on error undo, return error return-value
:
  define variable v-counter                   as integer      no-undo.
  define variable v-param-list                as character    no-undo.
  define variable v-param-type                as character    no-undo.
  define variable v-range                     as integer      no-undo.
  define variable v-host-code                 as integer      no-undo.
  define variable v-parameter                 as character    no-undo .
  define variable v-dir-name  as character no-undo .
  define variable v-dir-type  as character no-undo .
  define variable v-can-write as logical   no-undo .
  define variable v-file-rule as character no-undo .
  define variable v-file-name as character no-undo .
  define variable v-dc-type-list as character no-undo .
  define variable glog        as logical   no-undo .
  define variable v-ii          as integer   no-undo .
  DEFINE VARIABLE v-today as date no-undo .
  DEFINE VARIABLE v-time as integer no-undo .
  define variable v-other-params as character no-undo .
  define variable v-rule-profile-id as integer   no-undo .
  define variable v-codex-id as integer no-undo init 5.
  define variable v-ruleset-id as integer no-undo init 1.
  define variable v-rid-list as character no-undo .
  define buffer buf_rule-call-param for ub.rule-call-param.
  DEFINE NEW SHARED TEMP-TABLE tt0-rule-call-param NO-UNDO LIKE ub.rule-call-param.
  define buffer buf_tt0-rule-call-param for tt0-rule-call-param.
  DEFINE BUFFER X_dis-card-type FOR ub.dis-card-type.
  DEFINE BUFFER X_rp-by-call FOR ub.rp-by-call.
  DEFINE BUFFER X_rule FOR ub.rule.
  DEFINE BUFFER X_rule-by-profile FOR ub.rule-by-profile.
  DEFINE BUFFER X_rule-profile FOR ub.rule-profile.
  DEFINE BUFFER X_rule-by-call FOR ub.rule-by-call.

/*
ЛАНТАБ
rule-profile.profile_id = 12
ruleset.codex_id = 5
ruleset.ruleset_id = 1

ЭКСПОРТ XML
rule-profile.profile_id = 20
ruleset.codex_id = 5
ruleset.ruleset_id = 2

*/



  define stream OutStream.


&scop display-message    run write-log-and-file in p-log-handle (  ~
        input 1                                                      ~
      , input log-file-name                                          ~
      , input 1                                                      ~
      , input ~{&my-message~})


    assign
    log-file-name = "shd-free.log".


 
    run schedule-attr-value in this-procedure (
          input p-cre-db-num
        , input p-task-type
        , input p-task-num
        , input {&attr-schedule-param-list-h}
        , output v-param-list
        , output v-param-type
    ).
    if v-param-list = "":U then do:

&scop my-message   substitute("!!!Не заданы параметры экспорта данных по продажам по ДК в текстовый файл в задаче &1&2" ~
                                     , p-task-num                                                                       ~
                                     , ~{&new-line~})

       {&display-message}.
       return.
    end.
    assign
    v-rule-profile-id = integer(entry(1, v-param-list, {&delim-par} ))
    v-dir-name = entry(2, v-param-list, {&delim-par} )
    v-file-rule = entry(3, v-param-list, {&delim-par} )
    v-file-name = entry(4, v-param-list, {&delim-par} )
    v-dc-type-list = entry(5, v-param-list, {&delim-par} )
    no-error
    .
    if error-status :error then do:
&scop my-message substitute("!!!Ошибки при получении параметров экспорта данных&1" +  ~
                            "&2&1&3&1"                                                ~
                            , error-status:get-message(1)                             ~
                            , return-value )
      {&display-message}.
      return.
    end.
    v-other-params = v-param-list.
    ENTRY(1, v-other-params, {&delim-par}) = '':U.
    ENTRY(2, v-other-params, {&delim-par}) = '':U.
    ENTRY(3, v-other-params, {&delim-par}) = '':U.
    ENTRY(4, v-other-params, {&delim-par}) = '':U.
    ENTRY(5, v-other-params, {&delim-par}) = '':U.
    v-other-params = substring(v-other-params, 6).
    FIND FIRST X_rule-profile NO-LOCK WHERE
              X_rule-profile.profile_id = v-rule-profile-id NO-ERROR.
    IF NOT AVAILABLE X_rule-profile THEN DO:
&scop my-message       "Не найден профайл для экспорта в текстовый файл"
      {&display-message}.
      return.
    END.
    FIND FIRST X_rule-by-profile NO-LOCK WHERE
            X_rule-by-profile.profile_id = v-rule-profile-id
        AND X_rule-by-profile.codex_id = v-codex-id
        AND X_rule-by-profile.ruleset_id = v-ruleset-id NO-ERROR.
    IF NOT AVAILABLE X_rule-profile THEN DO:
&scop my-message        "Не найдено или неопределено правило для экспорта в текстовый файл"
      {&display-message}.
      return.
    END.
    FIND FIRST X_rule NO-LOCK WHERE
          X_rule.rule_id = X_rule-by-profile.rule_id.
    IF NOT AVAILABLE X_rule THEN DO:
&scop my-message   substitute("Не найдено правило &1 для экспорта в текстовый файл", X_rule-by-profile.rule_id)
      {&display-message}.
      return.
    END.
    do v-ii = 1 to num-entries(v-dc-type-list, {&new-line}):

      FIND FIRST X_dis-card-type NO-LOCK WHERE
                  X_dis-card-type.emitent-host-code = 0
            AND   X_dis-card-type.type = entry(v-ii, v-dc-type-list, {&new-line})
            AND X_dis-card-type.host-code = 0
            AND X_dis-card-type.obj-type = '':U
            AND X_dis-card-type.obj-code = 0 NO-ERROR.
      IF NOT AVAILABLE X_dis-card-type  THEN DO:
  &scop my-message substitute("Неизвестный тип ДК &1 эмитент &2" ~
                  , entry(v-ii, v-dc-type-list, ~{&new-line~})       ~
                  , 0)
        {&display-message}.
        return.
      END.
      FIND FIRST X_rp-by-call NO-LOCK WHERE
                X_rp-by-call.profile_id = v-rule-profile-id
          AND   X_rp-by-call.call_id = X_dis-card-type.uniq-key-rec NO-ERROR.
      IF NOT AVAILABLE X_rp-by-call THEN DO:
  &scop my-message  substitute("Тип ДК &1 эмитент &2 не привязан к профайлу импорта-экспорта в текстовый файл" ~
                    , X_dis-card-type.type ~                                               ~
                    , 0)
        {&display-message}.
        return.
      END.
      find X_rule-by-call where
          X_rule-by-call.call#_id = X_rp-by-call.call#_id
      and X_rule-by-call.rule_id = X_rule-by-profile.rule_id
      and X_rule-by-call.profile_id = X_rule-by-profile.profile_id no-error .
      if ambiguous X_rule-by-call then do:
        /*надо выбрать какой*/
        if not g#auto then do:
          message
          "Выберите какой вызов правила Вас необходим"
          view-as alert-box .
          run rul/rule-by-call-s.w ( input parparentproc
                                    ,input "b-sel"
                                    ,input "call_id"
                                    ,input X_rp-by-call.call_id
                                    ,input X_rule-by-profile.codex_id
                                    ,input X_rule-by-profile.ruleset_id
                                    ,input X_rule-by-profile.rule_id
                                    ,input-output v-rid-list) no-error .
          if v-rid-list = '':u then do:
            UNDO, RETURN ERROR.
          end.
        end.
        else do:
        &scop my-message  substitute("К Типу ДК &1 эмитент &2 привязано два профайла импорта-экспорта в текстовый файл" ~
                  , X_dis-card-type.type                                                                                ~
                  , 0)
       {&display-message}.
        return.
        end.
        find first X_rule-by-call no-lock where
                  recid(X_rule-by-call) = integer(v-rid-list) no-error .
        if not available X_rule-by-call then do:
          UNDO, RETURN ERROR.
        end.
      end.
      for each buf_tt0-rule-call-param:
        delete buf_tt0-rule-call-param.
      end.
      FOR each buf_Rule-call-param no-lock where
            buf_rule-call-param.call#_id = X_rp-by-call.call#_id
      and  buf_rule-call-param.codex_id = X_rule-by-profile.codex_id
      and  buf_rule-call-param.ruleset_id = X_rule-by-profile.ruleset_id
      and  buf_rule-call-param.order_id = X_rule-by-call.order_id:
        create buf_tt0-rule-call-param.
        buffer-copy buf_rule-call-param to buf_tt0-rule-call-param.
        CASE buf_rule-call-param.param-data-type:
          WHEN {&abl-datatype-character} THEN DO:
            ASSIGN
            buf_tt0-rule-call-param.param-value-character = ENTRY(buf_tt0-rule-call-param.param-num, v-other-params, {&delim-par})
            NO-ERROR.
          END.
          WHEN {&abl-datatype-date} THEN DO:
            ASSIGN
            buf_tt0-rule-call-param.param-value-date = IF entry(buf_tt0-rule-call-param.param-num, v-other-params, {&delim-par}) = {&question-mark}
                                                        THEN ?
                                                        ELSE DATE(ENTRY(buf_tt0-rule-call-param.param-num, v-other-params, {&delim-par}))
            NO-ERROR.
          END.
          WHEN {&abl-datatype-decimal} THEN DO:
            ASSIGN
            buf_tt0-rule-call-param.param-value-decimal = decimal(ENTRY(buf_tt0-rule-call-param.param-num, v-other-params, {&delim-par}))
            NO-ERROR.
          END.
          WHEN {&abl-datatype-integer} THEN DO:
            ASSIGN
            buf_tt0-rule-call-param.param-value-integer = integer(ENTRY(buf_tt0-rule-call-param.param-num, v-other-params, {&delim-par}))
            NO-ERROR.
          END.
          WHEN {&abl-datatype-logical} THEN DO:
            ASSIGN
            buf_tt0-rule-call-param.param-value-logical = logical(ENTRY(buf_tt0-rule-call-param.param-num, v-other-params, {&delim-par}))
            NO-ERROR.
          END.
        END CASE.
        IF ERROR-STATUS:ERROR THEN DO:
  &scop my-message   substitute("Некорректное значение параметра &1=&2"  ~
                      ,buf_tt0-rule-call-param.param-label               ~
                      ,BUFFER buf_tt0-rule-call-param:HANDLE:BUFFER-FIELD(substitute("param-value-&1", buf_tt0-rule-call-param.param-data-type)):buffer-value)

        {&display-message}.
        return.
        END.
      end.
      case v-dir-name:
        when 'ini':U then do:
          run verify-ini-entry in this-procedure (
                                              INPUT  'dctxt-e_out'
                                              ,INPUT  'schedule-free'
                                              ,INPUT substitute("отсутствует параметр &1 секция &2 в ini-файле"
                                                                , 'dctxt-e_out'
                                                                , 'schedule-free')
                                              ,INPUT no
                                              ,output v-dir-name) no-error .
          if error-status:error or v-dir-name = ? then do:
  &scop my-message  return-value
            {&display-message}.
            return .
          end.
          RUN verify-file in this-procedure
                                            (input v-dir-name
                                            ,input substitute("Не найден каталог &1 параметр &2, секция &3 ini-файла"
                                                          , v-dir-name
                                                          , 'schedule-free'
                                                        , 'dctxt-e_out')
                                            ,input no
                                            ,output  glog) no-error.
          if error-status:error or not glog then do:
  &scop my-message  return-value
            {&display-message}.
            return .
          end.
        end.
        otherwise do:
          v-dir-name = v-dir-name.
        end.
      END CASE.
      assign
      file-info:file-name = v-dir-name
      v-dir-type = file-info:file-type
      v-can-write = ( index( v-dir-type, "W" ) > 0 )
      .
      if index( v-dir-type, "D" ) = 0 then do:
  &scop my-message substitute("Выбранный для экспорта каталог &1 - недоступен", v-dir-name)
        {&display-message}.
        return .
      end.
      if not v-can-write then do:
  &scop my-messsage substitute("В выбранный для экспорта каталог &1 запись файла невозможна", v-dir-name)
        {&display-message}.
        return .
      end.
      CASE v-file-rule:
        when "seq":U then do:
          v-file-name = replace(v-file-name, {&question-mark}, string(next-value( s-spool, {&db-name_schema} ))).
        end.
        when "const":U then do:
          v-file-name = v-file-name.
        end.
      END CASE.
&scop my-message substitute(("&1Экспорт в текстовый файл&1директория экспорта &2&1" +                            ~
                            "имя файла для экспорта &3&1" +                                                       ~
                            "данные по ДК типa &4")                                                           ~
                            ,(~{&new-line~}  + fill("-", 15))                                                     ~
                            ,v-dir-name                                                                           ~
                            ,v-file-name                                                                          ~
                            ,entry(v-ii,v-dc-type-list, {&new-line}))
      {&display-message}.
      define variable v-doc-code as character no-undo .
      v-doc-code =  string(next-value(s-v-doc, {&db-name_schema})) + {&delim-par} +
                    trim(trim(v-dir-name, {&back-slash-char}), {&slash-char}) + {&back-slash-char} + v-file-name
                    .

      run str/saledc.p
      (
        input parparentproc
      ,input this-procedure :handle
      ,input p-log-handle
      ,input {&dct-proc_text-export}
      ,input X_dis-card-type.emitent-host-code
      ,input X_dis-card-type.type
      ,input X_rule-by-profile.profile_id
      ,input 0 /*p-codex-id*/
      ,input 0 /*p-ruleset-id*/
      ,input g#db-num
      ,input v-doc-code
      ,input ? /*doc-date - выставим внутри*/
      ,input ? /*fact-date - выставим внутри*/
      ,input ? /*cre-pay*/
      ,input 1 /*p-sign*/
      ,input 1 /* p-direction */
      ,input no /*p-save*/
      ) no-error .
      if error-status:error then do:
&scop my-message substitute("&1Ошибка при экспорте&1" +                ~
                            "&2&1&3"                                    ~
                            ,(~{&new-line~}  + fill("-", 15))           ~
                            , error-status:get-message(1)               ~
                            , return-value )

        {&display-message}.

      end.
    end. /*do v-ii*/
end. /*doe*/