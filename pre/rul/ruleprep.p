block-level on error undo, throw.
define input parameter p-rule-id as integer no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Сборка одного правила".
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
def var vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure gen-key-rec :
  define input  parameter p-tbl-name    as character no-undo.
  define input  parameter p-bh_tbl-name as handle    no-undo.
  define output parameter p-key-rec     as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-key-rec). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-rec). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-rec). endkey", vss-workfile )
  :
    define variable fh               as handle    no-undo .
    define variable v-ok             as logical   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    if p-tbl-name = ?
      or p-tbl-name = "":U
    then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Не задано имя таблицы.", vss-include-info4 ).
    end.
    if not p-bh_tbl-name:available then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Переданый буфер таблицы &2 не доступен", vss-include-info4, p-tbl-name ).
    end.
    assign
      p-key-rec = p-tbl-name
      v-inform  = p-bh_tbl-name:index-information(1)
      v-ind     = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = p-bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info4, p-tbl-name ).
    end.
    else do:
      assign
        v-idx-field-qnty = num-entries( v-inform ) - 4
      .
      if v-idx-field-qnty < 2 then do:
        return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info4, v-inform, p-tbl-name ).
      end.
      do v-ind = 1 to v-idx-field-qnty by 2
      on error undo, return error
      :
        assign
          fh = p-bh_tbl-name:buffer-field( entry( 4 + v-ind, v-inform, ",":U ) ).
          p-key-rec = p-key-rec + chr(3) + substitute("&1", replace(fh:buffer-value(),chr(3),chr(2) + chr(9) + chr (2)))
        .
      end.
    end.
    if p-key-rec = ? then do:
      assign
        p-key-rec = "":U
      .
      return error substitute( "&1. Поле(поля) первичного ключа таблицы &2 имеет(ют) неопределенное значение", vss-include-info4, p-tbl-name ).
    end.
  end.
  return.
end procedure.
procedure gen-where-keyr-tab :
  define input  parameter i-tableSerach as character no-undo.
  define input  parameter i-tablekey   as character  no-undo.
  define input  parameter p-key-rec    as character  no-undo.
  define input  parameter p-key-handle as handle     no-undo .
  define input  parameter p-db-name    as character  no-undo .
  define input  parameter p-tt-handle  as handle     no-undo .
  define output parameter o-Where      as character  no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-row-keyr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-row-keyr). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-row-keyr). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable fh_key           as handle    no-undo .
    define variable fh_search        as handle    no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-field-name     as character no-undo .
    define variable v-field-val      as character no-undo .
    define variable v-word-link      as character no-undo .
    define variable vTable           as character no-undo.
    define variable bh_tbl-key       as handle    no-undo .
    assign
      p-key-rec = trim( p-key-rec )
    .
    if p-key-handle <> ? then do:
      if not valid-handle(p-key-handle)
         or p-key-handle:type <> "buffer"
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Задан невалидный буфер для поиска.", vss-include-info4 ).
      end.
      if num-entries( p-key-rec, chr(3) ) > 1
        or p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. При поиске по буферу вместо ключа (&2) должено быть 'имя таблицы'.", vss-include-info4, p-key-rec ).
      end.
    end.
    else do:
      if p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info4 ).
      end.
    end.
    assign
      vTable = entry( 1 , p-key-rec, chr(3) )
    .
    if p-tt-handle <> ?
      and ( not valid-handle(p-tt-handle)
            or p-tt-handle:type <> "buffer"
          )
    then do:
      return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. &2&3Передан невалидный handle для поиска или handle не типа BUFFER", vss-include-info4, vTable, chr(10) ).
    end.
    if p-tt-handle = ? then do:
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, vTable )
      .
      create buffer bh_tbl-name for table v-full-tbl-name .
    end.
    else do:
      create buffer bh_tbl-name for table p-tt-handle:table-handle .
    end.
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Таблица &2 не имеет первичного ключа", vss-include-info4, vTable ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info4, v-inform, vTable ).
    end.
    assign
      o-where     = "where":U
      v-word-link = "":U
      v-field-num = num-entries( p-key-rec, chr(3) ) - 1
      v-count-fld = 0
    .
    if i-tablekey ne "" and i-tablekey ne ?
    then do:
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tablekey )
      .
      create buffer bh_tbl-key for table v-full-tbl-name .
    end.
    if i-tableSerach ne "" and i-tableSerach ne ?
    then do:
      delete object bh_tbl-name no-error.
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tableSerach )
      .
      create buffer bh_tbl-name for table v-full-tbl-name .
    end.
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      if p-key-handle = ?
        and v-count-fld > v-field-num
      then do:
        leave block_where.
      end.
      define variable VfieldKeyTable as handle no-undo.
      assign
        v-field-name = entry( 4 + v-ind, v-inform, ",":U )
        fh_search    = bh_tbl-name:buffer-field( v-field-name )
      .
      if     bh_tbl-key ne ?
      then do:
         VfieldKeyTable = bh_tbl-key:buffer-field( v-field-name ) no-error.
         if VfieldKeyTable eq ?
         then next block_where.
      end.
      if v-full-tbl-name ne "" and v-full-tbl-name ne ?
      then
         o-where = substitute( "&1 &2 &3.&4 =", o-where, v-word-link,v-full-tbl-name, v-field-name ).
      else
         o-where = substitute( "&1 &2 &3 =", o-where, v-word-link, v-field-name ).
      if p-key-handle = ? then do:
        assign
          v-field-val = replace (entry( v-count-fld + 1 , p-key-rec, chr(3) ),chr(2) + chr(9) + chr (2),chr(3))
        .
      end.
      else do:
        assign
          fh_key = p-key-handle:buffer-field( v-field-name )
        .
        if fh_key = ?
          or not valid-handle( fh_key )
        then do:
          delete object bh_tbl-name.
          if     bh_tbl-key ne ?
          then
             delete object bh_tbl-key.
          return error substitute( "&1. Буфер &2 не содержит поля &3 необходимого для поиска.", vss-include-info4, p-key-handle:name, v-field-name ).
        end.
        assign
          v-field-val = fh_key:buffer-value
        .
      end.
      if fh_search:data-type ="character":U then do:
        assign
          v-field-val = replace( v-field-val, '~~':U, '~~~~':U )
          v-field-val = replace( v-field-val, '"':U, '~~"':U )
          v-field-val = replace( v-field-val, "'":U, "~~'":U )
          v-field-val = replace( v-field-val, '~{':U, '~~~{':U )
          v-field-val = replace( v-field-val, '~}':U, '~~~}':U )
          v-field-val = replace( v-field-val, '~\':U, '~~~\':U )
          v-field-val = replace( v-field-val, chr(10), '~~n':U )
          v-field-val = replace( v-field-val, chr(9), '~~t':U )
          v-field-val = replace( v-field-val, chr(13), '~~r':U )
          v-field-val = replace( v-field-val, chr(27), '~~E':U )
          v-field-val = replace( v-field-val, chr(8), '~~b':U )
          v-field-val = replace( v-field-val, chr(12), '~~f':U )
          v-field-val = substitute( '"&1"', v-field-val )
        .
      end.
      assign
        o-where = substitute( "&1 &2", o-where, v-field-val )
      .
      if v-word-link = "":U then do:
        assign
          v-word-link = "and":U
        .
      end.
    end.
    delete object bh_tbl-name.
    if     bh_tbl-key ne ?
    then
       delete object bh_tbl-key.
    if p-key-handle = ?
      and v-count-fld <> v-field-num
    then do:
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2", vss-include-info4, vTable ).
    end.
  end.
end procedure.
procedure gen-hn-keyr-tab :
  define input  parameter i-tableSerach as character no-undo.
  define input  parameter i-tablekey   as character no-undo.
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter o-hn         as handle    no-undo.
  define variable v-full-tbl-name as character no-undo.
  define variable v-where         as character no-undo.
  define variable bh_tbl-name     as handle    no-undo.
  define variable vTable          as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-row-keyr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-row-keyr). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-row-keyr). endkey", vss-workfile ):
      run gen-where-keyr-tab(i-tableSerach,
                             i-tablekey,
                             p-key-rec,
                             p-key-handle,
                             p-db-name,
                             p-tt-handle,
                             output v-where).
      if i-tableSerach ne "" and i-tableSerach ne ?
      then do:
         v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tableSerach ).
         create buffer bh_tbl-name for table v-full-tbl-name .
      end.
      else do:
         if p-tt-handle = ? then do:
            assign
               vTable = entry( 1 , p-key-rec, chr(3) )
            .
            v-full-tbl-name = substitute( "&1.&2":U, p-db-name, vTable ).
            create buffer bh_tbl-name for table v-full-tbl-name .
         end.
         else do:
            create buffer bh_tbl-name for table p-tt-handle:table-handle .
         end.
      end.
      if p-tt-handle = ? then do:
         bh_tbl-name:find-first( v-where, p-stts-lock ) no-error .
      end.
      else do:
         bh_tbl-name:find-first( v-where ) no-error .
      end.
      o-hn = bh_tbl-name.
   end.
end procedure.
procedure gen-hn-keyr :
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter o-hn         as handle    no-undo.
  run gen-hn-keyr-tab(?,?,p-key-rec,p-key-handle,p-db-name,p-tt-handle,p-stts-lock,output o-hn).
end.
procedure gen-row-keyr :
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter p-tbl-row    as rowid     no-undo.
  define output parameter p-tbl-name   as character no-undo.
  define variable vHn as handle no-undo.
    run gen-hn-keyr-tab(?,?,p-key-rec,p-key-handle,p-db-name,p-tt-handle,p-stts-lock,output vHn).
    p-tbl-row = if vHn:available then vHn:rowid else ?.
    p-tbl-name =  vHn:table.
    delete object vHn no-error.
  if p-tbl-row = ? then do:
    return substitute( "Не найдена запись таблицы &2 по ключу &3", vss-include-info4, p-tbl-name, p-key-rec ).
  end.
  else do:
    return.
  end.
end procedure.
procedure gen-key-fv :
  define input  parameter p-key-rec    as character no-undo .
  define output parameter p-field-list as character no-undo .
  define output parameter p-value-list as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-key-fv). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-fv). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-fv). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable v-tbl-name       as character no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-delim-key      as character no-undo .
    if p-key-rec = ?
      or p-key-rec = "":U
    then do:
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info4 ).
    end.
    assign
      v-tbl-name      = entry( 1 , p-key-rec, chr(3) )
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверный уникальный ключ.", vss-include-info4 ).
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info4, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info4, v-inform, v-tbl-name ).
    end.
    assign
      p-field-list = "":U
      p-value-list = "":U
      v-delim-key  = "":U
      v-field-num  = num-entries( p-key-rec, chr(3) ) - 1
      v-count-fld  = 0
    .
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      if v-count-fld > v-field-num then do:
        leave block_where.
      end.
      assign
        p-field-list = p-field-list + v-delim-key + entry( 4 + v-ind, v-inform, ",":U )
        p-value-list = p-value-list + v-delim-key + entry( v-count-fld + 1 , p-key-rec, chr(3) )
      .
      if v-ind = 1 then do:
        assign
          v-delim-key = chr(3)
        .
      end.
    end.
    delete object bh_tbl-name.
    if v-count-fld <> v-field-num then do:
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2 в БД", vss-include-info4, v-tbl-name ).
    end.
  end.
end procedure.
procedure gen-key-field :
  define input  parameter p-table      as character no-undo .
  define output parameter p-field-list as character no-undo .
  do
  on error  undo, return error substitute( "&1 (gen-key-fv). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-fv). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-fv). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable v-tbl-name       as character no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-delim-key      as character no-undo .
    if p-table = ?
      or p-table = "":U
    then do:
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан таблица.", vss-include-info4 ).
    end.
    assign
      v-tbl-name      = p-table
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверная таблица.", vss-include-info4 ).
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info4, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info4, v-inform, v-tbl-name ).
    end.
    assign
      p-field-list = "":U
      v-delim-key  = "":U
      v-count-fld  = 0
    .
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      p-field-list = p-field-list + v-delim-key + entry( 4 + v-ind, v-inform, ",":U ).
      if v-ind = 1 then do:
        assign
          v-delim-key = chr(3)
        .
      end.
    end.
    delete object bh_tbl-name.
  end.
end procedure.
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
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
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
      v-script-type-list = 'define_b':U + chr(44) +
                            'define_tt':U + chr(44) +
                            'define_h':U + chr(44) +
                            'variable':U
                            .
      do v-ii = 1 to num-entries(v-script-type-list):
        run cycle-script-type in this-procedure ( input p-rule-id, input entry(v-ii, v-script-type-list)) no-error .
        if error-status:error then do:
          undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1)).
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
      on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
      :
        if first-of(buf_rule-i-script.i-script-name) then do:
          if not (buf_prop-script.language = "ABL") then next _rule-i-script.
          if lookup(buf_rule-i-script.i-script-type, v-script-type-list) > 0 then next _rule-i-script.
          if lookup(buf_prop-script.script-type, "hist-nws") > 0 then next _rule-i-script.
          run display-prop-script in this-procedure ( buffer buf_prop-script).
        end.
      end.
      _rule-i-script:
      for each buf_rule-i-script no-lock where
              buf_rule-i-script.root_rule_id = p-rule-id
          and buf_rule-i-script.script-type = '':U
      break
      by buf_rule-i-script.i-script-name
      on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
      :
        if first-of(buf_rule-i-script.i-script-name) then do:
          if not (buf_prop-script.language = "ABL") then next _rule-i-script.
          if lookup(buf_rule-i-script.i-script-type, v-script-type-list) > 0 then next _rule-i-script.
          if lookup(buf_prop-script.script-type, "hist-nws") > 0 then next _rule-i-script.
          run display-subsid-rule-i-script in this-procedure ( buffer buf_rule-i-script).
        end.
      end.
    end.
    if index(ss, "&start-hn-option&") > 0 then do:
      run cycle-script-type in this-procedure ( input p-rule-id, "hist-nws") no-error .
      if error-status:error then do:
        undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1)).
      end.
    end.
    if index(ss, "&start-rule&") > 0 then do:
      run display-rule in this-procedure ( input p-rule-id
                                        , input 0
                                        , input "ABL":U
                                        , input-output v-level).
    end.
  end.
  input stream instream close.
  output stream outstream to value( substitute( "rul/&1.p" ,string(p-rule-id, "999999999"))).
  for each buf_temp-string
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  :
    put stream outstream unformatted buf_temp-string.v-string chr(10).
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
        v-err-cmp = v-err-cmp + chr(10) + v-tmp-str
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
end.
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
    on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
    :
      if not (buf_prop-script.language = "ABL") then next _rule-i-script.
      if buf_rule-i-script.i-script-type = 'variable':U then do:
        run temp-string_write in this-procedure ( input substitute("define variable &1 as &2 no-undo."
                                                                   ,buf_rule-i-script.i-script-name
                                                                   ,buf_prop-script.script-value-type)
                                                ).
      end.
      else do:
        run display-prop-script in this-procedure ( buffer buf_prop-script).
      end.
    end.
  end.
end procedure.
procedure rule-call-param :
define parameter buffer buf_rule for ub.rule.
define variable v-uniq-key-rec as character no-undo .
define buffer buf_ruledict-param  for ub.ruledict-param.
define buffer buf_ruledict for ub.ruledict.
define variable v-string as character no-undo .
_main:
do
on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
:
  run gen-key-rec in this-procedure (
                                     input  'rule':U
                                    ,input buffer buf_rule:handle
                                    ,output v-uniq-key-rec ).
  find first buf_ruledict no-lock where
           buf_ruledict.entry-type = 'rule':U
       AND buf_ruledict.uniq-key-rec = v-uniq-key-rec
       AND buf_ruledict.language = "ABL"       .
  for each buf_ruledict-param no-lock where
          buf_ruledict-param.entry-id = buf_ruledict.entry-id
      and buf_ruledict-param.language = "ABL":U
  by buf_ruledict-param.param-num
  on error undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1)):
    CASE buf_ruledict-param.param-mode:
      when 'input':U then do:
        assign
        v-string = substitute(" define variable &1 as &2 no-undo."
                                ,buf_ruledict-param.param-name
                                ,buf_ruledict-param.param-data-type
                                ).
      end.
      when 'output':U then do:
      end.
      when 'input-output':U then do:
      end.
      when 'buffer':U then do:
      end.
      when 'input table':U then do:
      end.
      when 'output table':U then do:
      end.
      when 'input-output table':U then do:
      end.
    end case.
    run temp-string_write in this-procedure ( input v-string ).
  end.
end.
end procedure.
procedure using-class :
define parameter buffer buf_rule for ub.rule.
main-block:
do
on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
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
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  :
    if first-of(buf_rule-i-script.script-name) then do:
      if buf_rule-i-script.script-type = '':U then next _rule-i-script.
      if buf_rule-i-script.i-script-type = 'variable':U then do:
        if lookup(buf_rule-i-script.script-type, 'character,date,datetime,datetime-tz,decimal,integer,void,logical,memptr,raw,recid,rowid,widget-handle,handle,blob,clob,class,com-handle,longchar,int64':U) > 0 then next.
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
                     , chr(10)
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
                    , chr(10)
                     , buf_rule-i-script.script-type
                     , buf_rule-i-script.i-script-name
                     , buf_rule-i-script.script-name
                     , buf_rule-i-script.dtm-code
                     , buf_rule-i-script.class-dtm-code
                     )
          view-as alert-box .
          return error.
        END.
        if lookup(buf0_prop-script.proc-type, 'class,data-member,property,method,constructor,destructor':u) = 0  then next _rule-i-script.
        find last  buf_prop-script no-lock where
                  buf_prop-script.dtm-code = buf_rule-i-script.class-dtm-code
              and buf_prop-script.script-name = buf_rule-i-script.script-type
              and  buf_prop-script.proc-type = 'class':U
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
                     , chr(10)
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
      buf_temp-rule-i-script.i-script-type = 'class':U
      buf_temp-rule-i-script.i-script-name = buf_prop-script.script-body
      .
      run temp-string_write in this-procedure ( input buf_prop-script.script-body ).
    end.
  end.
end.
end procedure.
procedure hist-news-class :
define parameter buffer buf_rule for ub.rule.
main-block:
do
on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
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
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  :
    if buf_rule-i-script.i-script-type = 'variable':U
    or buf_rule-i-script.i-script-type = 'get':U
    or buf_rule-i-script.i-script-type = 'find':U
    or buf_rule-i-script.i-script-type = 'define_b':U
    or buf_rule-i-script.i-script-type = 'define_tt':U
    or buf_rule-i-script.i-script-type = 'define_h':U
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
                , chr(10)
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
    if lookup(buf0_prop-script.proc-type, 'class,data-member,property,method,constructor,destructor':u) = 0  then next _rule-i-script.
    for each buf_prop-script no-lock where
              buf_prop-script.class-dtm-code = buf_rule-i-script.class-dtm-code
          and buf_prop-script.dtm-code = buf_rule-i-script.dtm-code
          and  buf_prop-script.script-type = 'ifunction':U
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
          and buf_prop-script.script-type = 'ifunction':U
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
                  , chr(10)
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
  end.
end.
end procedure.
procedure process-rule-call-param :
define parameter buffer buf_rule for ub.rule.
define variable v-uniq-key-rec as character no-undo .
define variable v-string as character no-undo .
define buffer buf_ruledict-param  for ub.ruledict-param.
define buffer buf_ruledict for ub.ruledict.
_main:
do
on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
:
  run gen-key-rec in this-procedure (
                                     input  'rule':U
                                    ,input buffer buf_rule:handle
                                    ,output v-uniq-key-rec ).
  find first buf_ruledict no-lock where
           buf_ruledict.entry-type = 'rule':U
       AND buf_ruledict.uniq-key-rec = v-uniq-key-rec
       AND buf_ruledict.language = "ABL"
       .
  for each buf_ruledict-param no-lock where
          buf_ruledict-param.entry-id = buf_ruledict.entry-id
      and buf_ruledict-param.language = "ABL":U
  by buf_ruledict-param.param-num
  on error undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1)):
    CASE buf_ruledict-param.param-mode:
      when 'input':U then do:
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
         , chr(10)
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
                                  , chr(10)
                                  , buf_ruledict-param.param-name
                                  , buf_ruledict-param.param-data-type).
        end.
      end.
      when 'output':U then do:
      end.
      when 'input-output':U then do:
      end.
      when 'buffer':U then do:
      end.
      when 'input table':U then do:
      end.
      when 'output table':U then do:
      end.
      when 'input-output table':U then do:
      end.
    end case.
    run temp-string_write in this-procedure ( input v-string ).
  end.
end.
end procedure.
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
       and  buf_rule-i-script.i-script-type = 'variable':U
       and buf_rule-i-script.script_id = buf_tt-rule-script.script_id
  by buf_tt-rule-script.gen-order
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  :
    find first buf_rule-script where
              buf_rule-script.root_rule_id = p-rule-id
          and  buf_rule-script.script_id = buf_rule-i-script.script_id.
    if lookup(buf_rule-i-script.script-type, 'character,date,datetime,datetime-tz,decimal,integer,void,logical,memptr,raw,recid,rowid,widget-handle,handle,blob,clob,class,com-handle,longchar,int64':U) = 0 then do:
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
            and buf_prop-script.proc-type = 'method':U
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
            and buf_prop-script.proc-type = 'method':U
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
                    , chr(10)
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
              and buf2_prop-script.proc-type = 'class':U
              and buf2_prop-script.script-name = buf_rule-i-script.script-type
              and buf2_prop-script.revis_id = v-revis-id no-error .
        if not available buf2_prop-script then do:
          message
          substitute("Секция &&start-release-obj&&&2" +
                      "Не найден класс &1&2" +
                      "Код объекта-операнда &3&2" +
                      "Код класса &4"
                    ,buf_rule-i-script.script-type
                    ,chr(10)
                    ,buf_rule-i-script.dtm-code
                    ,buf_rule-i-script.class-dtm-code
                    )
          view-as alert-box error .
          undo, return error .
        end.
        v-release-name =  replace(buf_prop-script.script-name
                                      ,buf2_prop-script.script-name
                                      ,buf2_prop-script.script-head).
      end.
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
      buf_temp-rule-i-script.i-script-type = 'method':U
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
  end.
  for each buf_temp-rule-i-script where
          buf_temp-rule-i-script.script-name = "release":
    delete buf_temp-rule-i-script.
  end.
end.
end procedure.
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
       and  buf_rule-i-script.i-script-type = 'variable':U
  break
  by buf_rule-i-script.i-script-name
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  :
    if first-of(buf_rule-i-script.i-script-name) then do:
      find first buf_temp-rule-i-script no-lock where
                buf_temp-rule-i-script.root_rule_id = p-rule-id
            and buf_temp-rule-i-script.i-script-name = buf_rule-i-script.script-name no-error.
      if available buf_temp-rule-i-script then next.
      create buf_temp-rule-i-script.
      assign
      buf_temp-rule-i-script.root_rule_id  = p-rule-id
      buf_temp-rule-i-script.i-script-type = 'variable':U
      buf_temp-rule-i-script.i-script-name = buf_rule-i-script.script-name
      .
      find first buf_rule-script where
                buf_rule-script.root_rule_id = p-rule-id
           and  buf_rule-script.script_id = buf_rule-i-script.script_id.
      run temp-string_write in this-procedure ( input  substitute("&1 ."
                                                                  ,buf_rule-script.script)).
      if lookup(buf_rule-i-script.script-type, 'character,date,datetime,datetime-tz,decimal,integer,void,logical,memptr,raw,recid,rowid,widget-handle,handle,blob,clob,class,com-handle,longchar,int64':U) = 0 then do:
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
              and buf_prop-script.proc-type = 'constructor':U
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
              and buf_prop-script.proc-type = 'constructor':U
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
                     ,chr(10)
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
                and buf2_prop-script.proc-type = 'class':U
                and buf2_prop-script.script-name = buf_rule-i-script.script-type
                and buf2_prop-script.revis_id = v-revis-id no-error .
          if not available buf2_prop-script then do:
            message
            substitute("Секция &&start-def-vars&&&2" +
                        "Не найден класс &1&2" +
                        "Код объекта-операнда &3&2" +
                        "Код класса &4"
                      ,buf_rule-i-script.script-type
                      ,chr(10)
                      ,buf_rule-i-script.dtm-code
                      ,buf_rule-i-script.class-dtm-code
                      )
            view-as alert-box error .
            undo, return error .
          end.
          v-constructor-name =  replace(buf_prop-script.script-name
                                        ,buf2_prop-script.script-name
                                        ,buf2_prop-script.script-head).
        end.
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
    end.
  end.
end.
end procedure.
procedure display-subsid-rule-i-script :
define parameter buffer buf_rule-i-script for ub.rule-i-script.
  do
  on error undo, return error
  :
    run temp-string_write in this-procedure ( input buf_rule-i-script.script-name ).
  end.
end procedure.
