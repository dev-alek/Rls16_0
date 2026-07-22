block-level on error undo, throw.
define input parameter p-display-mode as character no-undo .
define input parameter p-rule-id as integer no-undo .
DEFINE INPUT PARAMETER p-codex-id AS INTEGER NO-UNDO.
DEFINE INPUT PARAMETER p-ruleset-id AS INTEGER NO-UNDO.
DEFINE INPUT PARAMETER p-call-id AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-order-id AS INTEGER NO-UNDO.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Просмотр одного правила".
procedure vss-get-info :
  define output parameter p-vss-revision    like vss-revision    no-undo .
  define output parameter p-vss-author      like vss-author      no-undo .
  define output parameter p-vss-date        like vss-date        no-undo .
  define output parameter p-vss-workfile    like vss-workfile    no-undo .
  define output parameter p-vss-archive     like vss-archive     no-undo .
  define output parameter p-vss-description like vss-description no-undo .
  assign
    p-vss-revision    = vss-revision
    p-vss-author      = vss-author
    p-vss-date        = vss-date
    p-vss-workfile    = vss-workfile
    p-vss-archive     = vss-archive
    p-vss-description = vss-description
  .
end procedure.
procedure vss-get-parameters :
  define output parameter p-vss-parameters as character no-undo .
end procedure.
define new global shared variable g#vssrevis-logger as handle    no-undo .
define variable v-vssrevis-logevent                 as logical   no-undo init false .
define variable v-vssrevis-logger                   as handle    no-undo .
procedure vss-logevent :
  define input  parameter p-extra-paramters as character no-undo .
  define variable v-vssrevis-parameters as character no-undo .
  do
  on error undo, return error return-value
  :
    if  valid-handle(v-vssrevis-logger)
    and v-vssrevis-logger :get-signature("logevent") <> ""
    then do:
      run vss-get-parameters in this-procedure
        (output v-vssrevis-parameters
        ).
      run logevent in v-vssrevis-logger
        (input vss-workfile
        ,input vss-revision
        ,input v-vssrevis-parameters
        ,input p-extra-paramters
        ).
    end.
  end.
end procedure.
assign
  v-vssrevis-logger = g#vssrevis-logger
.
if  valid-handle(v-vssrevis-logger)
and v-vssrevis-logger :get-signature("logevent") <> ""
then do:
  assign
    v-vssrevis-logevent = true
  .
  run vss-logevent in this-procedure (input vss-description) .
end.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table temp-string no-undo
field v-string as character
field string-num as integer
index pi is unique primary string-num.
procedure temp-string_clear :
  define buffer buf_temp-string for temp-string .
  do
  on error undo, return error return-value
  :
    for each buf_temp-string
    on error undo, return error
    :
      delete buf_temp-string.
    end.
  end.
end procedure.
procedure temp-string_write :
  define input  parameter p-v-string    as character no-undo .
  define variable v-string-num as integer no-undo .
  define buffer buf_temp-string for temp-string .
  do
  on error undo, return error return-value
  :
    find last buf_temp-string no-error .
    if not available buf_temp-string then do:
      create buf_temp-string .
      assign
      buf_temp-string.string-num     = 1
      buf_temp-string.v-string       = p-v-string
      .
    end.
    else do:
      v-string-num = buf_temp-string.string-num.
      create buf_temp-string .
      assign
      buf_temp-string.string-num = v-string-num + 1
      buf_temp-string.v-string = p-v-string
      .
    end.
  end.
end procedure.
procedure temp-string_read :
  define input  parameter p-string-num    as integer   no-undo .
  define output parameter p-v-string      as character no-undo .
  define buffer buf_temp-string for temp-string .
  do
  on error undo, return error return-value
  :
    find first buf_temp-string
      where buf_temp-string.string-num     = p-string-num
      no-error .
    if available buf_temp-string then do:
      assign
        p-v-string = buf_temp-string.v-string
      .
    end.
    else do:
      assign
        p-v-string = '':U
      .
    end.
  end.
end procedure.
procedure temp-string_append :
  define input  parameter p-string-num  as integer   no-undo .
  define input  parameter p-v-string    as character no-undo .
  define input  parameter p-append-char as character no-undo .
  define buffer buf_temp-string for temp-string .
  do
  on error undo, return error return-value
  :
    find first buf_temp-string
         where buf_temp-string.string-num = p-string-num
      no-error .
    if not available buf_temp-string then do:
      create buf_temp-string .
      assign
        buf_temp-string.string-num  = p-string-num
        buf_temp-string.v-string    = p-v-string
      .
    end.
    else do:
        assign
        buf_temp-string.v-string = buf_temp-string.v-string + p-append-char + p-v-string
        .
    end.
  end.
end procedure.
procedure temp-string_get-last-num:
define output parameter p-string-num  as integer   no-undo .
define buffer buf_temp-string for temp-string .
find last buf_temp-string no-error.
if available buf_temp-string then do:
  p-string-num = buf_temp-string.string-num.
end.
end procedure.
procedure temp-string_delete-range:
define input parameter p-first-string-num  as integer   no-undo .
define input parameter p-last-string-num  as integer   no-undo .
define buffer buf_temp-string for temp-string .
for each buf_temp-string where
        buf_temp-string.string-num >= p-first-string-num
    and buf_temp-string.string-num <= p-last-string-num:
  delete buf_temp-string.
end.
end procedure.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE TEMP-TABLE tt-rule NO-UNDO LIKE ub.rule
       field level as integer.
DEFINE TEMP-TABLE tt-rule-script NO-UNDO LIKE ub.rule-script
       field level as integer
       field gen-order as character
       field upper_rule_id as integer
       field start-script_id as integer
       field end-script_id as integer
       field edge-type as character
       .
define temp-table temp-rule-i-script no-undo
like ub.rule-i-script.
PROCEDURE fill-tables :
DEFINE INPUT PARAMETER p-rule-id AS INTEGER NO-UNDO.
DEFINE INPUT PARAMETER p-root-rule-id AS INTEGER NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER p-level AS INTEGER NO-UNDO.
DEFINE INPUT PARAMETER p-gen-order AS character NO-UNDO.
DEFINE BUFFER buf_rule FOR ub.RULE.
DEFINE BUFFER buf_rule-script FOR ub.RULE-script.
DEFINE BUFFER buf_tt-rule FOR tt-RULE.
DEFINE BUFFER buf_tt-rule-script FOR tt-RULE-script.
if p-level = 0 then do:
  find first buf_rule where
            buf_rule.rule_id = p-root-rule-id.
  create buf_tt-rule.
  buffer-copy buf_rule to buf_tt-rule.
  release buf_tt-rule.
end.
p-level = p-level + 1.
FOR EACH buf_rule NO-LOCK WHERE
        buf_rule.UPPER_rule_id = p-rule-id:
   find first buf_tt-rule where
            buf_tt-rule.rule_id = buf_rule.rule_id no-error.
   if not available buf_tt-rule then do:
    CREATE buf_tt-rule.
    buffer-copy buf_rule to buf_tt-rule.
    ASSIGN
    buf_tt-rule.root_rule_id = p-root-rule-id
    .
   end.
   buf_tt-rule.level = p-level.
   RUN fill-tables IN THIS-PROCEDURE (  INPUT buf_tt-rule.RULE_id
                                       ,INPUT p-root-rule-id
                                       ,INPUT-OUTPUT p-level
                                       ,INPUT (p-gen-order +
                                        STRING(p-level, "99") +
                                        STRING(buf_tt-rule.salience, "999"))).
END.
FOR EACH buf_rule-script NO-LOCK WHERE
        buf_rule-script.rule_id = p-rule-id:
   find first buf_tt-rule-script where
            buf_tt-rule-script.script_id = buf_rule-script.script_id
       AND  buf_tt-rule-script.LANGUAGE = buf_rule-script.LANGUAGE
       no-error.
   if not available buf_tt-rule-script
   then do:
    find first buf_tt-rule no-lock where
              buf_tt-rule.rule_id = buf_rule-script.rule_id.
    CREATE buf_tt-rule-script.
    buffer-copy buf_rule-script to buf_tt-rule-script.
    ASSIGN
    buf_tt-rule-script.root_rule_id = p-root-rule-id
    buf_tt-rule-script.upper_rule_id = buf_tt-rule.upper_rule_id
    .
   end.
   assign
   buf_tt-rule-script.level = p-level
   buf_tt-rule-script.gen-order = p-gen-order +
                                  STRING(buf_tt-rule-script.level, "99") +
                                  STRING(buf_tt-rule-script.salience, "999").
   .
END.
p-level = p-level - 1.
END PROCEDURE.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table temp-edge no-undo
field from-script_id as integer
field to-script_id as integer
field edge-type as character
index pi is unique primary
from-script_id
to-script_id
.
function break-string-for-dot returns character (input p-string as character, input p-line-length AS INTEGER):
define variable v-string as character no-undo .
define variable v-output-string as character no-undo .
define variable v-entry as character no-undo .
define variable v-index as integer no-undo .
v-string = p-string.
v-output-string = p-string.
do while length(v-string) > p-line-length :
  ASSIGN
  v-entry = substring(v-string, 1, p-line-length)
  v-index = r-index(v-entry, chr(32)).
  if v-index > 0
  and v-index <= p-line-length then do:
     assign
     v-output-string = v-output-string + substring(v-entry, 1, v-index - 1)  + '\N'.
     v-string = substring(v-string, v-index + 1)
     no-error.
     if error-status:error then leave.
  end.
  ELSE DO:
      assign
      v-output-string = v-output-string + v-entry.
      v-string = substring(v-string, 71)
      no-error.
  END.
end.
return v-output-string.
end.
PROCEDURE DISPLAY-RULE :
define INPUT parameter p-rule-id AS integer no-undo.
define input parameter p-upper-rule-id as integer no-undo .
define input parameter p-language as character no-undo.
define input-output parameter p-level as integer no-undo .
define variable v-exist-condition-script as logical no-undo .
define variable v-exist-rule-script as logical no-undo .
define variable v-main-seq as character no-undo .
define variable v-prev-node as character no-undo .
define variable v-current-node as character no-undo .
define variable v-next-node as character no-undo .
define variable v-bottom-node as character no-undo .
define variable v-top-node as character no-undo .
define variable v-edge-label as logical no-undo .
define variable v-language as character no-undo .
define variable v-upper-rule-id as integer no-undo .
define variable v-rule-id as integer no-undo .
define variable v-salience as integer no-undo .
define variable v-gen-order as character no-undo .
define variable v-goto-text as character no-undo .
define variable v-goto-rule as character no-undo .
define buffer buf_rule for ub.rule.
define buffer buf_upper-rule for ub.rule.
define buffer buf_upper-rule-script for ub.rule-script.
define buffer buf_down-rule for ub.rule.
define buffer buf2_rule-script for ub.rule-script.
define buffer buf3_rule-script for ub.rule-script.
define buffer buf2_rule for ub.rule.
define buffer buf_rule-script for ub.rule-script.
define buffer buf_prop-script for ub.prop-script.
define buffer buf_rule-i-script for ub.rule-i-script.
define buffer buf_tt-rule-script for tt-rule-script.
define buffer buf_temp-edge for temp-edge.
define buffer buf_tt-rule for tt-rule.
CASE p-language:
  WHEN "ABL" THEN DO:
    find first buf_rule no-lock where
              buf_rule.rule_id = p-rule-id.
    if buf_rule.hidden-content > 0 then do:
      run temp-string_write in this-procedure ( input substitute("/* содержимое скрыто*/")).
      return.
    end.
    if p-upper-rule-id = 0 then do:
      run temp-string_write in this-procedure ( input substitute("/* &1", buf_Rule.name)).
      run temp-string_write in this-procedure ( input substitute("&1 */", buf_Rule.documentation)).
      run temp-string_write in this-procedure ( input '':U).
    end.
    else do:
      run temp-string_write in this-procedure ( input substitute("/* salience &1 in upper-rule-id &2*/"
                                                                , buf_rule.salience
                                                                , buf_rule.upper_rule_id
                                                                )).
    end.
    run temp-string_write in this-procedure ( input  substitute("&1_&2:&3&1do:"
                                                                ,fill( chr(32), p-level * 2)
                                                                ,p-rule-id
                                                                ,chr(10))).
    FOR EACH buf_rule-script NO-LOCK WHERE
      buf_rule-script.RULE_id = p-RULE-id
      AND buf_rule-script.LANGUAGE = p-language
    by buf_rule-script.salience :
      if buf_rule-script.script-type = 'COND':U then do:
        run temp-string_write in this-procedure (input  substitute("&1/* salience &2 rule_id &3*/"
                                                                   ,fill(chr(32), 70)
                                                                   ,buf_rule-script.salience
                                                                   ,buf_rule-script.rule_ID
                                                                   ) ).
        run temp-string_write in this-procedure (input  substitute("&1IF &2  THEN do:   "
                                                                    ,fill( chr(32), p-level * 2)
                                                                    ,replace(buf_rule-script.script, (chr(38) + chr(38)), chr(38))
                                                                    )).
        .
        assign
        v-exist-rule-script = yes
        .
      end.
      if buf_rule-script.script-type = 'CYCLE-COND':U then do:
        run temp-string_write in this-procedure (input  substitute("&1/* salience &2 rule_id &3*/"
                                                                   ,fill(chr(32), 70)
                                                                   ,buf_rule-script.salience
                                                                   ,buf_rule-script.rule_ID
                                                                   ) ).
        run temp-string_write in this-procedure (input  substitute("&1DO WHILE &2 :   "
                                                                    ,fill( chr(32), p-level * 2)
                                                                    ,replace(buf_rule-script.script, (chr(38) + chr(38)), chr(38))
                                                                    )).
        .
        assign
        v-exist-rule-script = yes
        .
      end.
      if buf_rule-script.script-type = 'CONS':U
      or buf_rule-script.script-type = 'GOTO':U
      then do:
        run temp-string_write in this-procedure ( input  substitute("&1/* Salience &2 rule_id &3*/"
                                                                     ,fill(chr(32), 70)
                                                                     ,buf_rule-script.salience
                                                                     ,buf_rule-script.rule_id
                                                                     )).
        find first buf_rule-i-script no-lock where
                  buf_rule-i-script.root_rule_id = buf_rule.root_rule_id
             and  buf_rule-i-script.script_id = buf_rule-script.script_id
             and  buf_rule-i-script.i-script-type = 'variable':U no-error.
        if available buf_rule-i-script then do:
          run temp-string_write in this-procedure ( input  substitute("/*&1&2 .*/"
                                                                      ,fill( chr(32), p-level * 2)
                                                                      ,replace(buf_rule-script.script, (chr(38) + chr(38)), chr(38))
                                                                      )).
        end.
        else do:
          run temp-string_write in this-procedure ( input  substitute("&1&2 ."
                                                                ,fill( chr(32), p-level * 2)
                                                                ,replace(buf_rule-script.script, (chr(38) + chr(38)), chr(38))
                                                                )).
        end.
      end.
      if buf_rule-script.script-type = 'RULE':U
      or buf_rule-script.script-type = 'ELSE-RULE':U
      then do:
        find first buf_rule no-lock where
                buf_rule.upper_rule_id = p-rule-id
            and buf_rule.salience = buf_rule-script.salience no-error .
        if not available buf_rule then do:
          message
          substitute("Не найдено правило &1 вышестояшего уровня к скрипту типа &2:&3№ скрипта &4, порядок &5"
                     , p-rule-id
                     , buf_rule-script.script-type
                     , chr(10)
                     , buf_rule-script.script_id
                     , buf_rule-script.salience )
          view-as alert-box error .
          return.
        end.
        if buf_rule-script.script-type = 'ELSE-RULE':U then do:
          run temp-string_write in this-procedure ( input substitute("&1else do: /*rule &2*/"
                                                                      ,fill( chr(32), p-level * 2)
                                                                      ,buf_rule.rule_id)).
          assign
          v-exist-rule-script = yes
          .
        end.
        p-level = p-level + 1.
        run display-rule ( input buf_rule.rule_id, input buf_rule.upper_rule_id, input p-language, input-output p-level).
        p-level = p-level - 1.
        if v-exist-rule-script then do:
          run temp-string_write in this-procedure ( input substitute("&1end. /*of rule &2*/"
                                                                      ,fill( chr(32), p-level * 2)
                                                                      ,buf_rule.rule_id)).
          v-exist-rule-script = no.
        end.
      end.
    END.
    if v-exist-rule-script then do:
      run temp-string_write in this-procedure ( input substitute("&1end.&2end. /*of rule &3*/"
                                                                  ,fill( chr(32), p-level * 2)
                                                                  ,chr(10)
                                                                  ,p-rule-id)).
    end.
    else do:
      run temp-string_write in this-procedure ( input substitute("&1&2end. /*of rule &3*/"
                                                                  ,chr(10)
                                                                  ,fill( chr(32), p-level * 2)
                                                                  ,p-rule-id)).
    end.
  END.
  WHEN "rus"
  or
  when "rus-ext"
  THEN DO:
    find first buf_rule no-lock where
              buf_rule.rule_id = p-rule-id.
    if p-upper-rule-id = 0 then do:
      run temp-string_write in this-procedure ( input buf_rule.name ).
      run temp-string_write in this-procedure ( input buf_rule.documentation ).
      run temp-string_write in this-procedure ( input '':U).
      if buf_rule.hidden-content > 0 then do:
        run temp-string_write in this-procedure ( input "НЕЛЬЗЯ ПРОСМОТРЕТЬ СОДЕРЖИМОЕ ПРАВИЛА").
        return.
      end.
    end.
    else do:
      if p-language = "rus-ext" then do:
        run temp-string_write in this-procedure ( input substitute("&1/* порядок &2 правила &3 */"
                                                                  ,fill(chr(32), 70)
                                                                  ,buf_rule.salience
                                                                  ,buf_rule.upper_rule_id
                                                                  )).
      end.
    end.
    run temp-string_write in this-procedure ( input substitute("_Правило &1:",  p-RULE-id)).
    FOR EACH buf_rule-script NO-LOCK WHERE
            buf_rule-script.RULE_id = p-rULE-id
        AND buf_rule-script.LANGUAGE = "rus":
     if buf_rule-script.script-type = 'COND':U then do:
        if p-language = "rus-ext" then do:
          run temp-string_write in this-procedure ( input  substitute("&1/* порядок &2 правила &3*/"
                                                                      ,fill(chr(32), 70)
                                                                      ,buf_rule-script.salience
                                                                      ,buf_rule-script.rule_id
                                                                      )).
        end.
        run temp-string_write in this-procedure ( input  substitute("&1Если &2 тогда: "
                                                                      ,fill( chr(32), p-level * 2)
                                                                      ,buf_rule-script.script )).
        assign
        v-exist-rule-script = yes
        .
      end.
     if buf_rule-script.script-type = 'CYCLE-COND':U then do:
        if p-language = "rus-ext" then do:
          run temp-string_write in this-procedure ( input  substitute("&1/* порядок &2 правила &3*/"
                                                                      ,fill(chr(32), 70)
                                                                      ,buf_rule-script.salience
                                                                      ,buf_rule-script.rule_id
                                                                      )).
        end.
        run temp-string_write in this-procedure ( input  substitute("&1ПОКА &2: "
                                                                      ,fill( chr(32), p-level * 2)
                                                                      ,buf_rule-script.script )).
        assign
        v-exist-rule-script = yes
        .
      end.
      if buf_rule-script.script-type = 'RULE':U
      or buf_rule-script.script-type = 'ELSE-RULE':U
      then do:
        find first buf_rule no-lock where
                buf_rule.upper_rule_id = p-rule-id
            and buf_rule.salience = buf_rule-script.salience no-error .
        if not available buf_rule then do:
          message
          substitute("Не найдено правило &1 вышестояшего уровня к скрипту типа &2:&3№ скрипта &4, порядок &5"
                     , p-rule-id
                     , buf_rule-script.script-type
                     , chr(10)
                     , buf_rule-script.script_id
                     , buf_rule-script.salience )
          view-as alert-box error .
          return.
        end.
        if buf_rule-script.script-type = 'ELSE-RULE':U then do:
          run temp-string_write in this-procedure ( input substitute("&1ИНАЧЕ: /*правило &2*/"
                                                                      ,fill( chr(32), p-level * 2)
                                                                      ,buf_rule.rule_id)).
          assign
          v-exist-rule-script = yes
          .
        end.
        p-level = p-level + 1.
        run display-rule ( input buf_rule.rule_id, input buf_rule.upper_rule_id, input p-language, input-output p-level).
        p-level = p-level - 1.
      end.
      if buf_rule-script.script-type = 'CONS':U
      or buf_rule-script.script-type = 'GOTO':U
      then do:
        if p-language = "rus-ext" then do:
          run temp-string_write in this-procedure ( input substitute("&1/* порядок &2 правила &3*/"
                                                                      ,fill(chr(32), 70)
                                                                      ,buf_rule-script.salience
                                                                      ,buf_rule-script.rule_id
                                                                      )).
        end.
        run temp-string_write in this-procedure ( input substitute("&1&2 ;"
                                                                    ,fill( chr(32), p-level * 2)
                                                                    ,buf_rule-script.script )).
      end.
    END.
    if v-exist-rule-script then do:
      run temp-string_write in this-procedure ( input substitute("&1. /* конец правила &2 */"
                                                                    ,fill( chr(32), p-level * 2)
                                                                    ,p-rule-id) ).
    end.
    else do:
      run temp-string_write in this-procedure ( input substitute("&1. /* конец правила &2 */"
                                                                    ,fill( chr(32), p-level * 2)
                                                                    ,p-rule-id) ).
    end.
  END.
  when "DOT2-rus":U
  or
  when "DOT2-ABL":U then do:
    v-language = entry(2, p-language, "-").
    find first buf_rule no-lock where
              buf_rule.rule_id = p-rule-id.
    if p-upper-rule-id = 0 then do:
      run temp-string_write in this-procedure ( input  substitute('Rule&1_&2_&3 [shape=ellipse , fillcolor=pink, style="rounded,filled",  label="Правило&4\n&1_&2_&3"];'
                                                                , buf_rule.rule_id
                                                                , buf_rule.upper_rule_id
                                                                , buf_rule.salience
                                                                , (if buf_rule.hidden-content > 0 then " (содержимое скрыто) " else "")
                                                                )
                                                                ).
      if buf_rule.hidden-content > 0 then do:
        return.
      end.
    end.
    else do:
    end.
    FOR EACH buf_rule-script NO-LOCK WHERE
            buf_rule-script.RULE_id = p-rULE-id
        AND buf_rule-script.LANGUAGE = v-language:
      if buf_rule-script.script-type = 'COND':U then do:
        run temp-string_write in this-procedure ( input   substitute('Condition&1_&2 [shape=diamond, fillcolor=yellow, style="rounded,filled", label="&3?"];'
                                                                    , buf_rule-script.rule_id
                                                                    , buf_rule-script.salience
                                                                    , replace(replace(replace(buf_rule-script.script, chr(34), "&#34;":U), "~~n", "\n"), chr(10), "\n")
                                                                    )).
      end.
      if buf_rule-script.script-type = 'CYCLE-COND':U then do:
        run temp-string_write in this-procedure ( input   substitute('Cyclecondition&1_&2 [shape=trapezium, fillcolor=yellowgreen, style="rounded,filled", label="&3?"];'
                                                                    , buf_rule-script.rule_id
                                                                    , buf_rule-script.salience
                                                                    , replace(replace(replace(buf_rule-script.script, chr(34), "&#34;":U), "~~n", "\n"), chr(10), "\n")
                                                                    )).
      end.
      if buf_rule-script.script-type = 'CONS':U then do:
        run temp-string_write in this-procedure ( input   substitute('Consequence&1_&2 [shape=box, fillcolor=lightgrey, style="rounded,filled", label="&3"];'
                                                                    , buf_rule-script.rule_id
                                                                    , buf_rule-script.salience
                                                                    , replace(replace(replace(buf_rule-script.script, chr(34), "&#34;":U), "~~n", "\n"), chr(10), "\n")
                                                                    )).
      end.
      if buf_rule-script.script-type = 'GOTO':U then do:
        run temp-string_write in this-procedure ( input   substitute('Goto&1_&2 [shape=invtriangle, fillcolor=pink, style="rounded,filled", label="&3"];'
                                                                    , buf_rule-script.rule_id
                                                                    , buf_rule-script.salience
                                                                    , replace(replace(replace(buf_rule-script.script, chr(34), "&#34;":U), "~~n", "\n"), chr(10), "\n")
                                                                    )).
      end.
      if buf_rule-script.script-type = 'RULE':U
      or buf_rule-script.script-type = 'ELSE-RULE':U
      then do:
        find first buf_down-rule no-lock where
                  buf_down-rule.upper_rule_id = p-rule-id
              and buf_down-rule.salience = buf_rule-script.salience.
        p-level = p-level + 1.
        run display-rule ( input buf_down-rule.rule_id
                         , input buf_down-rule.upper_rule_id
                         , input p-language
                         , input-output p-level).
        p-level = p-level - 1.
      end.
    end.
    if p-upper-rule-id = 0 then do:
      run temp-string_write in this-procedure ( input substitute('End_Rule&1 [shape=ellipse , fillcolor=pink, style="rounded,filled", label="Конец\nправила &1"];'
                                                                  , p-rule-id)).
    end.
    if p-upper-rule-id = 0 then do:
      run temp-string_write in this-procedure ( input substitute("~}")).
    end.
   end.
    when "DOT1-rus"
    or
    when "DOT1-ABL"
    then do:
        DEFINE VARIABLE v-level AS INTEGER NO-UNDO.
        define variable v-start-script-id as integer no-undo .
        define variable v-end-script-id as integer no-undo .
        define variable v-script-type as character no-undo .
        define buffer buf2_tt-rule for tt-rule.
        v-language = entry(2, p-language, "-").
        find first buf_rule no-lock where
                  buf_rule.rule_id = p-rule-id.
        if p-upper-rule-id = 0 then do:
          RUN fill-tables IN THIS-PROCEDURE (  INPUT buf_rule.RULE_id
                                          ,INPUT buf_rule.root_RULE_id
                                          ,INPUT-OUTPUT v-level
                                          ,INPUT "") no-error.
          run temp-string_write in this-procedure ( input substitute("digraph rule&1 ~{", p-rule-id)).
          run temp-string_write in this-procedure ( input substitute('node [fontsize=12];')).
          run temp-string_write in this-procedure ( input substitute('nodesep=0.30;')).
          run temp-string_write in this-procedure ( input substitute('ranksep=0.30;')).
          if buf_rule.hidden-content > 0 then do:
            return.
          end.
          _tt-rule:
          for each buf_tt-rule no-lock where
                  buf_tt-rule.root_rule_id = buf_rule.root_rule_id:
            if buf_tt-rule.rule_id = buf_tt-rule.root_rule_id then do:
              find first buf_tt-rule-script where
                        buf_tt-rule.rule_id = buf_tt-rule.rule_id.
              assign
              v-start-script-id = buf_tt-rule-script.script_id
              v-end-script-id = -1
              .
            end.
            else do:
              find first buf_tt-rule-script no-lock where
                      buf_tt-rule-script.rule_id = buf_tt-rule.upper_rule_id
                  and buf_tt-rule-script.salience = buf_tt-rule.salience.
              assign
              v-salience = buf_tt-rule-script.salience
              v-script-type = buf_tt-rule-script.script-type
              .
              find last buf_tt-rule-script no-lock where
                      buf_tt-rule-script.rule_id = buf_tt-rule.upper_rule_id
                  and buf_tt-rule-script.salience < buf_tt-rule.salience
                  and buf_tt-rule-script.script-type <> 'RULE':U
                  and buf_tt-rule-script.script-type <> 'ELSE-RULE':U
                  .
              assign
              v-start-script-id = buf_tt-rule-script.script_id.
              find first buf2_tt-rule where
                        buf2_tt-rule.rule_id = buf_tt-rule.rule_id.
              assign
              v-salience = buf_tt-rule.salience
              v-rule-id = buf_tt-rule.upper_rule_id
              .
              _TTT:
              do while true:
                find first buf_tt-rule-script no-lock where
                        buf_tt-rule-script.rule_id = v-rule-id
                    and buf_tt-rule-script.salience > v-salience
                    and buf_tt-rule-script.script-type <>  'RULE':U
                    and buf_tt-rule-script.script-type <>  'ELSE-RULE':U
                    no-error
                    .
                if not available buf_tt-rule-script then do:
                  if buf2_tt-rule.upper_rule_id = 0 then do:
                    v-end-script-id = -1.
                    leave _ttt.
                  end.
                  else do:
                    find first buf2_tt-rule where
                              buf2_tt-rule.rule_id = v-rule-id.
                    assign
                    v-salience = buf2_tt-rule.salience
                    v-rule-id = buf2_tt-rule.upper_rule_id
                    .
                  end.
                end.
                else do:
                  assign
                  v-end-script-id = buf_tt-rule-script.script_id.
                  leave _ttt.
                end.
              end.
              for each buf_tt-rule-script where
                      buf_tt-rule-script.rule_id = buf_tt-rule.rule_id:
                assign
                buf_tt-rule-script.start-script_id = v-start-script-id
                buf_tt-rule-script.end-script_id = v-end-script-id
                buf_tt-rule-script.edge-type = (if v-script-type = 'RULE':U
                                                then "yes"
                                                else "no")
                .
              end.
            end.
          end.
        end.
        if p-upper-rule-id = 0 then do:
          assign
          v-prev-node =  substitute("Rule&1_&2_&3"
                                  , buf_rule.rule_id
                                  , buf_rule.upper_rule_id
                                  , buf_rule.salience
                                  ).
          for each buf_tt-rule-script by
                buf_tt-rule-script.gen-order:
            create buf_temp-edge.
            assign
            buf_temp-edge.from-script_id = 0
            buf_temp-edge.to-script_id = buf_tt-rule-script.script_id
            buf_temp-edge.edge-type = "":U
            .
            release buf_temp-edge.
            leave.
          end.
        end.
        FOR EACH buf_rule-script NO-LOCK WHERE
                buf_rule-script.RULE_id = p-rULE-id
            AND buf_rule-script.LANGUAGE = v-language:
          if buf_rule-script.script-type = 'RULE':U
          or buf_rule-script.script-type = 'ELSE-RULE':U
          then do:
            find first buf_down-rule no-lock where
                      buf_down-rule.upper_rule_id = p-rule-id
                  and buf_down-rule.salience = buf_rule-script.salience no-error .
            if error-status :error then do:
            end.
            p-level = p-level + 1.
            run display-rule ( input buf_down-rule.rule_id, input buf_down-rule.upper_rule_id, input p-language, input-output p-level).
            p-level = p-level - 1.
          end.
          run create-temp-edge in this-procedure ( buffer buf_rule-script
                                                  ,input v-language
                                                  ,output v-current-node
                                                  ).
          _temp-edge:
          for each buf_temp-edge where
                  buf_temp-edge.from-script_id = buf_rule-script.script_id:
            if buf_temp-edge.to-script_id = -1 then do:
              assign
              v-next-node =  substitute("End_Rule&1"
                                , buf_rule-script.root_rule_id
                                ).
            end.
            else do:
              find first buf_tt-rule-script where buf_tt-rule-script.script_id = buf_temp-edge.to-script_id no-error .
              if not available buf_tt-rule-script then do:
                next _temp-edge.
              end.
              case buf_tt-rule-script.script-type:
                when 'CONS':U then do:
                  assign
                  v-next-node  = substitute("Consequence&1_&2"
                                      , buf_tt-rule-script.rule_id
                                      , buf_tt-rule-script.salience).
                end.
                when 'GOTO':U then do:
                  assign
                  v-next-node  = substitute("Goto&1_&2"
                                      , buf_tt-rule-script.rule_id
                                      , buf_tt-rule-script.salience).
                end.
                when 'COND':U then do:
                  assign
                  v-next-node  = substitute("Condition&1_&2"
                                      , buf_tt-rule-script.rule_id
                                      , buf_tt-rule-script.salience).
                end.
                when 'CYCLE-COND':U then do:
                  assign
                  v-next-node  = substitute("Cyclecondition&1_&2"
                                      , buf_tt-rule-script.rule_id
                                      , buf_tt-rule-script.salience).
                end.
                when 'ELSE-RULE':U then do:
                  next _temp-edge.
                end.
              end case.
            end.
            if can-find(first temp-edge where
                            temp-edge.from-script_id = 0
                        and temp-edge.to-script_id = buf_rule-script.script_id) then do:
              run temp-string_write in this-procedure ( input substitute("&1 -> &2"
                                                                          ,v-prev-node
                                                                          ,v-current-node
                                                                          )).
            end.
            run temp-string_write in this-procedure ( input substitute("&1 -> &2&3"
                                                                        ,v-current-node
                                                                        ,v-next-node
                                                    ,(if buf_temp-edge.edge-type = ""
                                                      then "":U
                                                      else substitute('[taillabel="&1"]'
                                                                      , buf_temp-edge.edge-type)
                                                      )
                                                                        )).
          end.
        end.
      end.
END CASE.
END procedure.
procedure create-temp-edge :
define parameter buffer buf_rule-script for ub.rule-script.
define input parameter p-language as character no-undo .
define output parameter p-current-node as character no-undo .
define variable v-salience as integer no-undo .
define variable v-rule-id as integer no-undo .
define variable v-gen-order as character no-undo .
define variable v-goto-text as character no-undo .
define variable v-goto-rule as character no-undo .
define variable v-ii as integer no-undo .
define variable v-script-id as integer no-undo .
define variable v-script-type as character no-undo .
define variable v-int as integer no-undo .
define buffer buf_tt-rule-script for tt-rule-script.
define buffer buf_tt-rule for tt-rule.
define buffer buf_temp-edge for temp-edge.
define buffer buf2_rule for ub.rule.
do
on error undo, return error
:
  case buf_rule-script.script-type:
    when 'COND':U then do:
      assign
      p-current-node  = substitute("Condition&1_&2"
                        , buf_rule-script.rule_id
                        , buf_rule-script.salience).
     for each buf_tt-rule-script where
              buf_tt-rule-script.start-script_id = buf_rule-script.script_id
          and buf_tt-rule-script.edge-type = "yes"
      by buf_tt-rule-script.gen-order:
        create buf_temp-edge.
        assign
        buf_temp-edge.from-script_id = buf_rule-script.script_id
        buf_temp-edge.to-script_id = buf_tt-rule-script.script_id
        buf_temp-edge.edge-type = buf_tt-rule-script.edge-type
        .
        leave.
     end.
     for each buf_tt-rule-script where
              buf_tt-rule-script.start-script_id = buf_rule-script.script_id
          and buf_tt-rule-script.edge-type = "no"
      by buf_tt-rule-script.gen-order:
        create buf_temp-edge.
        assign
        buf_temp-edge.from-script_id = buf_rule-script.script_id
        buf_temp-edge.to-script_id = buf_tt-rule-script.script_id
        buf_temp-edge.edge-type = buf_tt-rule-script.edge-type
        .
        leave.
     end.
     if not available buf_tt-rule-script then do:
      assign
      v-rule-id = buf_rule-script.rule_id
      v-salience = buf_rule-script.salience
      .
      find first buf_tt-rule-script where
                buf_tt-rule-script.rule_id = v-rule-id
            and buf_tt-rule-script.salience > v-salience
            and buf_tt-rule-script.script-type <> 'RULE':U
            and buf_tt-rule-script.script-type <> 'ELSE-RULE':U
            no-error.
      if not available buf_tt-rule-script then do:
        if buf_rule-script.rule_id = buf_rule-script.root_rule_id then do:
          create buf_temp-edge.
          assign
          buf_temp-edge.from-script_id = buf_rule-script.script_id
          buf_temp-edge.to-script_id = -1
          buf_temp-edge.edge-type = "no"
          .
        end.
        else do:
          find first buf_tt-rule-script where
                    buf_tt-rule-script.script_id = buf_rule-script.script_id.
          create buf_temp-edge.
          assign
          buf_temp-edge.from-script_id = buf_rule-script.script_id
          buf_temp-edge.to-script_id = buf_tt-rule-script.end-script_id
          buf_temp-edge.edge-type = "no"
          .
        end.
      end.
      else do:
        create buf_temp-edge.
        assign
        buf_temp-edge.from-script_id = buf_rule-script.script_id
        buf_temp-edge.to-script_id = buf_tt-rule-script.script_id
        buf_temp-edge.edge-type = "no"
        .
      end.
     end.
    end.
    when 'CYCLE-COND':U then do:
      assign
      p-current-node  = substitute("Cyclecondition&1_&2"
                        , buf_rule-script.rule_id
                        , buf_rule-script.salience).
     for each buf_tt-rule-script where
              buf_tt-rule-script.start-script_id = buf_rule-script.script_id
          and buf_tt-rule-script.edge-type = "yes"
      by buf_tt-rule-script.gen-order:
        v-ii = v-ii + 1.
        if v-ii = 1 then do:
          create buf_temp-edge.
          assign
          buf_temp-edge.from-script_id = buf_rule-script.script_id
          buf_temp-edge.to-script_id = buf_tt-rule-script.script_id
          buf_temp-edge.edge-type = buf_tt-rule-script.edge-type
          .
        end.
        assign
        v-script-id = buf_tt-rule-script.script_id
        v-script-type = buf_tt-rule-script.script-type
        v-rule-id = buf_tt-rule-script.rule_id
        v-salience = buf_tt-rule-script.salience
        .
      end.
      _cont:
      do while true:
        if v-script-type <> 'RULE':U
        and v-script-type <> 'ELSE-RULE':U then do:
          create buf_temp-edge.
          assign
          buf_temp-edge.to-script_id = buf_rule-script.script_id
          buf_temp-edge.from-script_id = v-script-id
          buf_temp-edge.edge-type = "continue"
          .
          leave _cont.
        end.
        find first buf_tt-rule where
                  buf_tt-rule.upper_rule_id = v-rule-id
              and buf_tt-rule.salience = v-salience.
        for each buf_tt-rule-script where
                buf_tt-rule-script.rule_id = buf_tt-rule.rule_id
        by buf_tt-rule-script.gen-order:
          assign
          v-script-id = buf_tt-rule-script.script_id
          v-script-type = buf_tt-rule-script.script-type
          v-rule-id = buf_tt-rule-script.rule_id
          v-salience = buf_tt-rule-script.salience
          .
        end.
      end.
    end.
    when 'CONS':U
    then do:
      assign
      p-current-node  = substitute("Consequence&1_&2"
                          , buf_rule-script.rule_id
                          , buf_rule-script.salience).
      assign
      v-rule-id = buf_rule-script.rule_id
      v-salience = buf_rule-script.salience
      .
      find first buf_tt-rule-script where
                buf_tt-rule-script.rule_id = v-rule-id
            and buf_tt-rule-script.salience > v-salience no-error.
      if not available buf_tt-rule-script then do:
        if buf_rule-script.rule_id = buf_rule-script.root_rule_id then do:
          create buf_temp-edge.
          assign
          buf_temp-edge.from-script_id = buf_rule-script.script_id
          buf_temp-edge.to-script_id = -1
          buf_temp-edge.edge-type = ""
          .
        end.
        else do:
          find first buf_tt-rule-script where
                    buf_tt-rule-script.script_id = buf_rule-script.script_id.
          create buf_temp-edge.
          assign
          buf_temp-edge.from-script_id = buf_rule-script.script_id
          buf_temp-edge.to-script_id = buf_tt-rule-script.end-script_id
          buf_temp-edge.edge-type = ""
          .
        end.
      end.
      else do:
        create buf_temp-edge.
        assign
        buf_temp-edge.from-script_id = buf_rule-script.script_id
        buf_temp-edge.to-script_id = buf_tt-rule-script.script_id
        buf_temp-edge.edge-type = ""
        .
      end.
    end.
    when 'GOTO':U then do:
      assign
      p-current-node  = substitute("Goto&1_&2"
                          , buf_rule-script.rule_id
                          , buf_rule-script.salience).
      find first buf_tt-rule-script where
              buf_tt-rule-script.rule_id = buf_rule-script.rule_id
          and buf_tt-rule-script.language = "ABL"
          and buf_tt-rule-script.salience = buf_rule-script.salience.
      v-goto-text = trim(buf_tt-rule-script.script, chr(32)).
      if v-goto-text begins "leave":U then do:
        v-goto-rule = trim(trim(replace(v-goto-text, "leave":U, "":U), chr(32)), "_":U).
        if v-goto-rule = string(buf_rule-script.root_rule_id) then do:
          create buf_temp-edge.
          assign
          buf_temp-edge.from-script_id = buf_rule-script.script_id
          buf_temp-edge.to-script_id =  -1
          buf_temp-edge.edge-type = ""
          .
        end.
        else do:
          assign
          v-int = integer(v-goto-rule) no-error.
          if not error-status:error then do:
            find first buf_tt-rule-script where
                        buf_tt-rule-script.upper_rule_id = v-int .
            create buf_temp-edge.
            assign
            buf_temp-edge.from-script_id = buf_rule-script.script_id
            buf_temp-edge.to-script_id = buf_tt-rule-script.end-script_id
            buf_temp-edge.edge-type = "leave"
            .
          end.
        end.
      end.
      if v-goto-text begins "next":U then do:
        v-goto-rule = trim(replace(v-goto-text, "next":U, "":U), chr(32)).
        if v-goto-rule = substitute("_&1", buf_rule-script.root_rule_id) then do:
          find first buf_tt-rule-script where
                    buf_tt-rule-script.rule_id = buf_rule-script.root_rule_id.
          create buf_temp-edge.
          assign
          buf_temp-edge.from-script_id = buf_rule-script.script_id
          buf_temp-edge.to-script_id = buf_tt-rule-script.script_id
          buf_temp-edge.edge-type = ""
          .
        end.
        else do:
          assign
          v-int = integer(trim(v-goto-rule, "_")) no-error.
          if not error-status:error then do:
            find first buf_tt-rule-script where
                        buf_tt-rule-script.upper_rule_id = v-int .
            create buf_temp-edge.
            assign
            buf_temp-edge.from-script_id = buf_rule-script.script_id
            buf_temp-edge.to-script_id = buf_tt-rule-script.end-script_id
            buf_temp-edge.edge-type = "next"
            .
          end.
          else do:
            create buf_temp-edge.
            assign
            buf_temp-edge.from-script_id = buf_rule-script.script_id
            buf_temp-edge.to-script_id = -1
            buf_temp-edge.edge-type = "next"
            .
          end.
        end.
      end.
    end.
  end case.
end.
end procedure.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure display-prop-script :
define parameter buffer buf_prop-script for ub.prop-script.
  do
  on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  :
    if buf_prop-script.script-type = 'ifunction':U then do:
      run temp-string_write in this-procedure ( input buf_prop-script.script-body ).
    end.
    else do:
      if lookup(buf_prop-script.proc-type, 'class,data-member,property,method,constructor,destructor':u) > 0 then do:
      end.
      else do:
        run temp-string_write in this-procedure ( input buf_prop-script.script-head ).
        run temp-string_write in this-procedure ( input buf_prop-script.script-body ).
        run temp-string_write in this-procedure ( input buf_prop-script.script-foot ).
      end.
    end.
  end.
end procedure.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure display-rule-call-params :
define input parameter p-mode as character no-undo .
define input parameter p-codex-id as integer no-undo .
define input parameter p-ruleset-id as integer no-undo .
define input parameter p-call-id as character no-undo .
define input parameter p-once-more as integer no-undo .
define input parameter p-order-id as integer no-undo .
define input parameter p-handle as handle no-undo .
define buffer buf_rule-call-param for ub.rule-call-param.
define variable v-string as character no-undo .
do
on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
:
  run temp-string_write in p-handle ( input "ПАРАМЕТРЫ").
  if p-mode = "text"
  or p-mode = "text-temp"
  then do:
    run temp-string_write in p-handle ( input "").
  end.
  _rr:
  for each buf_rule-call-param no-lock where
          buf_rule-call-param.codex_id = p-codex-id
      and buf_rule-call-param.ruleset_id = p-ruleset-id
      and buf_rule-call-param.call_id = p-call-id
      and buf_rule-call-param.order_id = p-order-id:
    if p-once-more >= 0 and
    buf_rule-call-param.once-more <> p-once-more then next.
    v-string = '':U.
    if lookup("LIST", buf_rule-call-param.param-3-data-type) > 0 then do:
      if buf_rule-call-param.p-index = 0 then do:
        assign
        v-string = buf_rule-call-param.param-label +  chr(32)  + "=".
        run temp-string_write in p-handle ( input v-string).
        next _rr.
      end.
      else do:
        assign
        v-string = fill( chr(32), length(buf_rule-call-param.param-label) + 2).
      end.
    end.
    else do:
      assign
      v-string = buf_rule-call-param.param-label +  chr(32)  + "=".
    end.
    CASE buf_rule-call-param.param-data-type:
      when 'character':U then do:
        v-string = v-string + buf_rule-call-param.param-value-character.
      end.
      when 'date':U then do:
        v-string = v-string + string(buf_rule-call-param.param-value-date, "99/99/9999").
      end.
      when 'logical':U then do:
        v-string = v-string + string(buf_rule-call-param.param-value-logical, "ДА/НЕТ").
      end.
      when 'decimal':U then do:
        v-string = v-string + string(buf_rule-call-param.param-value-decimal).
      end.
      when 'integer':U then do:
        v-string = v-string + string(buf_rule-call-param.param-value-integer).
      end.
    END CASE.
    run temp-string_write in p-handle ( input v-string).
  end.
  if p-mode = "text"
  or p-mode = "text-temp"
  then do:
    run temp-string_write in p-handle ( input "").
  end.
end.
end procedure.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure display-ruledict-params :
define input parameter p-mode as character no-undo .
define input parameter p-rule-id as integer no-undo .
define buffer buf_ruledict-param for ub.ruledict-param.
define buffer buf_ruledict for ub.ruledict.
define buffer buf_rule for ub.rule.
define variable v-string as character no-undo .
do
on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
:
  find first buf_rule no-lock where
            buf_rule.rule_id = p-rule-id.
  find first buf_ruledict no-lock where
            buf_ruledict.entry-type = 'rule':U
        and buf_ruledict.uniq-key-rec = buf_rule.uniq-key-rec.
  run temp-string_write in this-procedure ( input "ПАРАМЕТРЫ").
  if p-mode = "text" then do:
    run temp-string_write in this-procedure ( input "").
  end.
  for each buf_ruledict-param no-lock where
          buf_ruledict-param.entry-id = buf_ruledict.entry-id:
    assign
    v-string = substitute("&1 (&2) (&3)"
                          , buf_ruledict-param.param-label
                          , buf_ruledict-param.param-data-type
                          , buf_ruledict-param.param-name).
    run temp-string_write in this-procedure ( input v-string).
  end.
end.
end procedure.
DEFINE VARIABLE v-level AS INTEGER NO-UNDO.
run temp-string_clear in this-procedure .
CASE P-DISPLAY-MODE:
  WHEN "TEXT" THEN DO:
    if p-call-id = '':U
    or p-ruleset-id = 0 then do:
      RUN display-ruledict-params IN THIS-PROCEDURE (
                                                       input p-display-mode
                                                      ,input p-rule-id).
    end.
    else do:
      RUN display-rule-call-params IN THIS-PROCEDURE (
                                                         input p-display-mode
                                                        ,INPUT p-codex-id
                                                        ,INPUT p-ruleset-id
                                                        ,INPUT p-call-id
                                                        ,input -1
                                                        ,INPUT p-order-id
                                                        ,input this-procedure:handle
                                                        ).
   end.
     run display-rule in this-procedure ( input p-rule-id
                                      , input 0
                                      , input "rus":U
                                      , input-output v-level).
     run gbl/notese.w ( INPUT THIS-PROCEDURE:HANDLE
                          ,input substitute("Содержание правила &1", p-rule-id)).
  END.
  WHEN "GRAPH" THEN DO:
      run rul/grafdisp.p ( input p-rule-id
                          ,input "RUS"
                           ).
  END.
END CASE.
PROCEDURE request-add-line :
DEFINE INPUT PARAMETER p-notes-handle AS HANDLE NO-UNDO.
DEFINE BUFFER buf_temp-string FOR temp-string.
for each buf_temp-string:
    RUN add-line IN p-notes-handle ( INPUT buf_temp-string.v-string).
    RUN add-line IN p-notes-handle ( INPUT chr(10)).
  end.
END PROCEDURE.
