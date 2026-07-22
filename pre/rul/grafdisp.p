block-level on error undo, throw.
DEFINE INPUT PARAMETER p-rule-id AS INTEGER NO-UNDO.
define input parameter p-language as character no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "".
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
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define   shared variable g#auto as logical no-undo.
define   shared variable g#news as logical no-undo.
define   shared variable g#oxml as logical no-undo.
define   shared variable g#esys as logical no-undo.
define   shared variable g#news-source-db as integer no-undo.
define   shared variable g#esys-source-esys as integer no-undo.
define   shared variable g#db-num as integer   no-undo .
define   shared variable g#userid as character no-undo .
define   shared variable g#passwd as character no-undo .
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
def var vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Не задано имя таблицы.", vss-include-info5 ).
    end.
    if not p-bh_tbl-name:available then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Переданый буфер таблицы &2 не доступен", vss-include-info5, p-tbl-name ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info5, p-tbl-name ).
    end.
    else do:
      assign
        v-idx-field-qnty = num-entries( v-inform ) - 4
      .
      if v-idx-field-qnty < 2 then do:
        return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info5, v-inform, p-tbl-name ).
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
      return error substitute( "&1. Поле(поля) первичного ключа таблицы &2 имеет(ют) неопределенное значение", vss-include-info5, p-tbl-name ).
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
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Задан невалидный буфер для поиска.", vss-include-info5 ).
      end.
      if num-entries( p-key-rec, chr(3) ) > 1
        or p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. При поиске по буферу вместо ключа (&2) должено быть 'имя таблицы'.", vss-include-info5, p-key-rec ).
      end.
    end.
    else do:
      if p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info5 ).
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
      return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. &2&3Передан невалидный handle для поиска или handle не типа BUFFER", vss-include-info5, vTable, chr(10) ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа", vss-include-info5, vTable ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info5, v-inform, vTable ).
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
          return error substitute( "&1. Буфер &2 не содержит поля &3 необходимого для поиска.", vss-include-info5, p-key-handle:name, v-field-name ).
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
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2", vss-include-info5, vTable ).
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
    return substitute( "Не найдена запись таблицы &2 по ключу &3", vss-include-info5, p-tbl-name, p-key-rec ).
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
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info5 ).
    end.
    assign
      v-tbl-name      = entry( 1 , p-key-rec, chr(3) )
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверный уникальный ключ.", vss-include-info5 ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info5, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info5, v-inform, v-tbl-name ).
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
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2 в БД", vss-include-info5, v-tbl-name ).
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
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан таблица.", vss-include-info5 ).
    end.
    assign
      v-tbl-name      = p-table
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверная таблица.", vss-include-info5 ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info5, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info5, v-inform, v-tbl-name ).
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-waitfram-action01         as character   no-undo .
define variable v-waitfram-action02         as character   no-undo .
define variable v-waitfram-action03         as character   no-undo .
define variable mWaitFramTextBeg            as character   no-undo.
define variable mWaitFramTextEnd            as character   no-undo.
define variable mWaitFramView               as logical     no-undo.
define variable mWaitProcEvent              as logical     no-undo init yes.
define variable mWaitFramInterval           as integer     no-undo init 1 .
define variable mWaitFramStop               as logical     no-undo.
define variable mWaitFramStopUser           as logical     no-undo.
define variable mWaitFramStopTimeOut        as logical     no-undo.
define variable mWaitFramStartProc          as datetime-tz no-undo.
define variable mWaitFramTimeOut            as decimal     no-undo init ?.
define button B-WaitFramStop auto-end-key
     label "Стоп"
     size 10 by 1 tooltip "Остоновить процесс".
define button B-viewProcInfo
     label "Информация"
     size 15 by 1 tooltip "Информация о процесс".
define frame waitfram
  v-waitfram-action01 format "x(72)" no-label skip
  v-waitfram-action02 format "x(72)" no-label skip
  v-waitfram-action03 format "x(72)" no-label skip
  B-viewProcInfo
  B-WaitFramStop at row 4 col 30
  with view-as dialog-box side-labels three-d cancel-button B-WaitFramStop
  .
define new global shared variable mBatchMode as logical no-undo init ?.
define variable mFramBachModHandle as handle no-undo.
mFramBachModHandle = frame waitfram:handle.
define variable mFameOldVis as logical no-undo.
define variable mVisCUrentVin as logical no-undo.
if session:batch-mode
then
   mBatchMode = yes.
if mBatchMode = ? then do:
  mVisCUrentVin = current-window:visible.
  mFameOldVis = mFramBachModHandle:visible.
  mFramBachModHandle:visible  = yes.
  mBatchMode = mFramBachModHandle:visible ne yes.
  mFramBachModHandle:visible = mFameOldVis.
  current-window:visible = mVisCUrentVin.
end.
 if  log-manager:logfile-name ne ?
  then DO:
      log-manager:write-message("Logname=" + log-manager:logfile-name , "frameRepError").
      log-manager:write-message("Batch-mod=" + string(session:batch-mode) , "frameRepError").
      log-manager:write-message("visible-frame-mod=" + string(mFramBachModHandle:visible), "frameRepError").
  end.
on choose of B-WaitFramStop in frame waitfram
do:
  mWaitFramStop = yes.
  mWaitFramStopUser = yes.
end.
function waitfram-check-timeout returns logical():
   define variable vtime as int64 no-undo.
   if mWaitFramStopTimeOut
   then
      return yes.
   vtime = ( now - mWaitFramStartProc ) / 1000 .
   if     mWaitFramTimeOut ne ?
      and mWaitFramTimeOut ne 0
      and mWaitFramTimeOut lt vtime
   then do:
      mWaitFramStopTimeOut = yes.
   end.
   return mWaitFramStopTimeOut.
end.
procedure waitfram-hide :
  if not session:batch-mode
  then do
  on error undo, return error return-value
  :
    pause 0 before-hide .
    if not mBatchMode then
      hide frame waitfram .
  if     not mWaitFramView
     and mWaitProcEvent
  then
    process events .
  end.
end procedure.
procedure waitfram-show :
  define input  parameter p-message as character no-undo .
  define variable v-left-margin as integer   no-undo .
  if not session:batch-mode
  then do
  on error undo, return error return-value
  :
    if length(p-message) <= 70 then do:
      assign
        v-left-margin = integer((70 - length(p-message)) / 2)
      .
      assign
        v-left-margin = max(0, v-left-margin - (v-left-margin mod 5))
      .
      assign
        v-waitfram-action01 = " "
        v-waitfram-action02 = " "
                                 + fill(" ", v-left-margin)
                                 + p-message
        v-waitfram-action03 = " "
      .
    end.
    else do:
      define variable vRindex1 as integer no-undo.
      define variable vRindex2 as integer no-undo.
      vRindex1 = r-index(p-message," ",70).
      if vRindex1 = 0
      then
         vRindex1 = 70.
      if length(p-message)  <= vRindex1 + 70 then do:
        assign
          v-waitfram-action01 = " "
          v-waitfram-action02 = " " + substring(p-message,   1          , vRindex1)
          v-waitfram-action03 = " " + substring(p-message,  vRindex1 + 1, 70      )
        .
      end.
      else do:
        vRindex2 = r-index(p-message," ",vRindex1 + 70).
        if vRindex2 <= vRindex1
        then
           vRindex2 = vRindex1 + 70.
        assign
          v-waitfram-action01 = " " + substring(p-message,   1          , vRindex1)
          v-waitfram-action02 = " " + substring(p-message,  vRindex1 + 1, vRindex2 - vRindex1 )
          v-waitfram-action03 = " " + substring(p-message,  vRindex2 + 1, 70)
        .
      end.
    end.
    B-viewProcInfo:visible   in frame waitfram = no.
    B-viewProcInfo:sensitive in frame waitfram = no.
    B-WaitFramStop:visible   in frame waitfram = if not mBatchMode and mWaitFramView then yes else no .
    B-WaitFramStop:sensitive in frame waitfram = if not mBatchMode and mWaitFramView then yes else no .
    if  (   mWaitFramView
       or  mWaitProcEvent)
       and not mBatchMode
    then
       display
          v-waitfram-action01 skip
          v-waitfram-action02 skip
          v-waitfram-action03 skip
       with frame waitfram .
    if     mWaitFramView
       then do:
          if     mWaitFramInterval ne ?
             and not mBatchMode
          then
             wait-for go of frame waitfram pause mWaitFramInterval.
       end.
       else
          if     mWaitProcEvent
             and not mBatchMode
          then
             process events .
  end.
end procedure.
   procedure waitfram-show-this:
      define input  parameter iInterval as int64 no-undo.
      define variable vtime as int64 no-undo.
      vtime = ( now - mWaitFramStartProc  ) / 1000 .
      mWaitFramInterval = iInterval.
      run waitfram-show (substitute("&1&2 &3&4" ,
                                    mWaitFramTextBeg ,
                                    if vtime eq ? then "" else substitute (" Прошло: &1 сек" , string( vtime)),
                                    if mWaitFramTimeOut ne 0 and mWaitFramTimeOut ne ? then " из " + string(mWaitFramTimeOut) + " сек. " else "",
                                    mWaitFramTextEnd
                                   )
                        ).
   end.
   procedure WaitFramRunPause:
      define input  parameter iInterval as dec no-undo.
      define variable vStart  as datetime-tz no-undo.
      define variable vend    as datetime-tz no-undo.
      define variable vint as int64 no-undo.
      define variable vOk as logical no-undo.
      vStart = now.
      vend   = vStart.
      publish "WaitFramPause" (iInterval,output vOk).
      vend   =  now.
      vint = vend - vStart.
      vint = iInterval - vint / 1000.
      if     not mWaitFramStop
         and (   vint > 0
              or (    not vOk
                  and iInterval eq ?
                  )
              )
      then
         run waitfram-show-this (iInterval).
      vend   =  now.
      vint = vend - vStart.
      vint = iInterval - vint / 1000.
      if     not mWaitFramStop
         and vint > 0
      then do:
         run gbl/pause.p (vint * 1000).
      end.
      if iInterval ne ?
      then
         publish "WaitFramStop".
      waitfram-check-timeout().
   end.
   procedure WaitFramWaitFor:
      define input  parameter iInterval as dec no-undo.
      assign
         mWaitFramStartProc   = now
         mWaitFramStopUser    = no
         mWaitFramStopTimeOut = no
      .
      block-wait:
      do while not mWaitFramStop:
         run WaitFramRunPause (iInterval).
         if  waitfram-check-timeout()
         then do:
            leave block-wait.
         end.
      end.
      run waitfram-hide.
   end.
procedure waitfram-join :
  define input  parameter p-line-1  as character no-undo .
  define input  parameter p-line-2  as character no-undo .
  define input  parameter p-line-3  as character no-undo .
  define output parameter p-message as character no-undo .
  do
  on error undo, return error return-value
  :
    assign
      p-message = substring(p-line-1 + fill(' ', 70), 1, 70)
                + substring(p-line-2 + fill(' ', 70), 1, 70)
                + substring(p-line-3 + fill(' ', 70), 1, 70)
    .
  end.
end procedure.
function waitfram-join-function returns character
  (input p-line-1 as character
  ,input p-line-2 as character
  ,input p-line-3 as character
  ).
  define variable v-message as character no-undo .
  run waitfram-join in this-procedure
    (input  p-line-1
    ,input  p-line-2
    ,input  p-line-3
    ,output v-message
    ) .
  return v-message .
end function .
define variable v-level as integer no-undo .
define buffer buf_TEMP-STRING  for temp-string.
define variable v-cmdln as character no-undo .
define variable err-file as character no-undo .
define variable res as character no-undo .
define variable v-short-file-name as character no-undo .
define variable v-path                    as character                no-undo .
DEFINE VARIABLE v-full-path               as character                no-undo .
DEFINE VARIABLE v-file-name               as character                no-undo .
DEFINE VARIABLE v-file-name-cmd           as character                no-undo .
DEFINE VARIABLE v-file-name-dot           as character                no-undo .
DEFINE VARIABLE v-file-name-gif           as character                no-undo .
define variable v-file-name-html          as character                no-undo .
DEFINE VARIABLE v-file-name-no-ext        as character                no-undo .
DEFINE VARIABLE v-file-name-ext           as character                no-undo .
define stream outstream .
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  run temp-string_clear in this-procedure .
  run display-rule in this-procedure ( input p-rule-id
                                  , input 0
                                  , input substitute("DOT1-&1", p-language)
                                  , input-output v-level).
  run display-rule in this-procedure ( input p-rule-id
                                  , input 0
                                  , input substitute("DOT2-&1", p-language)
                                  , input-output v-level).
  output stream outstream to value( substitute( "&1.dot" ,string(p-rule-id, "999999999"))) convert target "UTF-8" .
  for each buf_temp-string
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  :
  put stream outstream unformatted buf_temp-string.v-string chr(10).
  end.
  output stream outstream close.
  run gbl/_tmpfile.p ( input ""
                      ,input  ""
                      ,output err-file) .
  assign
  v-short-file-name = string(p-rule-id, "999999999") + ".dot"
  .
  run gbl/filename.p (
                 input  v-short-file-name
                ,output v-file-name-dot
                ,output v-path
                ,output v-file-name
                ,output v-file-name-no-ext
                ,output v-file-name-ext
                ) no-error .
  if error-status:error then do:
    message
    return-value
    view-as alert-box ERROR.
    return.
  end.
  run rep/killspac.p ( input-output v-file-name-dot).
  assign
  v-file-name-gif = replace(v-file-name-dot, ".dot", ".gif")
  .
  assign
  v-short-file-name = "exe/graphviz/dot.exe".
  run gbl/filename.p (
                 input  v-short-file-name
                ,output v-file-name-cmd
                ,output v-path
                ,output v-file-name
                ,output v-file-name-no-ext
                ,output v-file-name-ext
                ) no-error .
  if error-status:error then do:
    message
    return-value
    view-as alert-box ERROR.
    return.
  end.
  assign
  err-file = err-file + ".err":u
  v-cmdln = substitute('"&1" -Tgif &2 -o &3 -Gcharset=UTF-8 > &4'
                       ,v-file-name-cmd
                       ,v-file-name-dot
                       ,v-file-name-gif
                       ,err-file
                       ).
  .
  run gbl/syn.p
    (input v-cmdln
    ,input "":U
    ,input "Ждите! Идет форматирование файла..."
    ,output res
    ) no-error .
  run waitfram-hide in this-procedure .
  run gbl/filename.p (
                 input  v-file-name-gif
                ,output v-full-path
                ,output v-path
                ,output v-file-name
                ,output v-file-name-no-ext
                ,output v-file-name-ext
                ) no-error .
  if error-status:error then do:
    message
    return-value
    view-as alert-box ERROR.
    return.
  end.
  run rep/killspac.p ( input-output v-full-path).
  v-file-name-html = replace(v-file-name-dot, ".dot", ".html").
  output stream Outstream to value(v-file-name-html).
  put stream Outstream unformatted
  substitute('<IMG SRC="&1.gif" ALT="ПРАВИЛО &2">', string(p-rule-id, "999999999"), p-rule-id)
  skip.
  output stream Outstream close.
  run gbl/open_url.p ( input  v-file-name-html) no-error .
  if search("grafdisp.dbg") = ? then do:
    os-delete value(v-file-name-dot).
  end.
  os-delete value(err-file).
end.
