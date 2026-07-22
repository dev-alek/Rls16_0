/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Представление одного правила с upper-code = 0

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/25/06
Author: Bakhtadze Natalya
Creation date: 10/25/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

{ rul/tempstrn.i }

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
  v-index = r-index(v-entry, {&space-char}).
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
                                                                ,fill( {&space-char}, p-level * 2)
                                                                ,p-rule-id
                                                                ,{&new-line})).
    FOR EACH buf_rule-script NO-LOCK WHERE
      buf_rule-script.RULE_id = p-RULE-id
      AND buf_rule-script.LANGUAGE = p-language
    by buf_rule-script.salience :
      if buf_rule-script.script-type = {&rule-script-COND} then do:
        run temp-string_write in this-procedure (input  substitute("&1/* salience &2 rule_id &3*/"
                                                                   ,fill({&space-char}, 70)
                                                                   ,buf_rule-script.salience
                                                                   ,buf_rule-script.rule_ID
                                                                   ) ).
        run temp-string_write in this-procedure (input  substitute("&1IF &2  THEN do:   "
                                                                    ,fill( {&space-char}, p-level * 2)
                                                                    ,replace(buf_rule-script.script, ({&ampersand} + {&ampersand}), {&ampersand})
                                                                    )).
        .
        assign
        v-exist-rule-script = yes
        .
      end.
      if buf_rule-script.script-type = {&rule-script-cycle-COND} then do:
        run temp-string_write in this-procedure (input  substitute("&1/* salience &2 rule_id &3*/"
                                                                   ,fill({&space-char}, 70)
                                                                   ,buf_rule-script.salience
                                                                   ,buf_rule-script.rule_ID
                                                                   ) ).
        run temp-string_write in this-procedure (input  substitute("&1DO WHILE &2 :   "
                                                                    ,fill( {&space-char}, p-level * 2)
                                                                    ,replace(buf_rule-script.script, ({&ampersand} + {&ampersand}), {&ampersand})
                                                                    )).
        .
        assign
        v-exist-rule-script = yes
        .
      end.
      if buf_rule-script.script-type = {&rule-script-CONS}
      or buf_rule-script.script-type = {&rule-script-GOTO}
      then do:
        run temp-string_write in this-procedure ( input  substitute("&1/* Salience &2 rule_id &3*/"
                                                                     ,fill({&space-char}, 70)
                                                                     ,buf_rule-script.salience
                                                                     ,buf_rule-script.rule_id
                                                                     )).
        find first buf_rule-i-script no-lock where
                  buf_rule-i-script.root_rule_id = buf_rule.root_rule_id
             and  buf_rule-i-script.script_id = buf_rule-script.script_id
             and  buf_rule-i-script.i-script-type = {&prop-script-type-variable} no-error.
        if available buf_rule-i-script then do:
          run temp-string_write in this-procedure ( input  substitute("/*&1&2 .*/"
                                                                      ,fill( {&space-char}, p-level * 2)
                                                                      ,replace(buf_rule-script.script, ({&ampersand} + {&ampersand}), {&ampersand})
                                                                      )).
        end.
        else do:
          run temp-string_write in this-procedure ( input  substitute("&1&2 ."
                                                                ,fill( {&space-char}, p-level * 2)
                                                                ,replace(buf_rule-script.script, ({&ampersand} + {&ampersand}), {&ampersand})
                                                                )).

        end.
      end.
      if buf_rule-script.script-type = {&rule-script-RULE}
      or buf_rule-script.script-type = {&rule-script-else-RULE}
      then do:
        find first buf_rule no-lock where
                buf_rule.upper_rule_id = p-rule-id
            and buf_rule.salience = buf_rule-script.salience no-error .
        if not available buf_rule then do:
          message
          substitute("Не найдено правило &1 вышестояшего уровня к скрипту типа &2:&3№ скрипта &4, порядок &5"
                     , p-rule-id
                     , buf_rule-script.script-type
                     , {&new-line}
                     , buf_rule-script.script_id
                     , buf_rule-script.salience )
          view-as alert-box error .
          return.
        end.
        if buf_rule-script.script-type = {&rule-script-else-rule} then do:
          run temp-string_write in this-procedure ( input substitute("&1else do: /*rule &2*/"
                                                                      ,fill( {&space-char}, p-level * 2)
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
                                                                      ,fill( {&space-char}, p-level * 2)
                                                                      ,buf_rule.rule_id)).
          v-exist-rule-script = no.
        end.
      end.
    END.
    if v-exist-rule-script then do:
      run temp-string_write in this-procedure ( input substitute("&1end.&2end. /*of rule &3*/"
                                                                  ,fill( {&space-char}, p-level * 2)
                                                                  ,{&new-line}
                                                                  ,p-rule-id)).
    end.
    else do:
      run temp-string_write in this-procedure ( input substitute("&1&2end. /*of rule &3*/"
                                                                  ,{&new-line}
                                                                  ,fill( {&space-char}, p-level * 2)
                                                                  ,p-rule-id)).
    end.
  END.
  WHEN "{&language}"
  or
  when "{&language}-ext"
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
      if p-language = "{&language}-ext" then do:
        run temp-string_write in this-procedure ( input substitute("&1/* порядок &2 правила &3 */"
                                                                  ,fill({&space-char}, 70)
                                                                  ,buf_rule.salience
                                                                  ,buf_rule.upper_rule_id
                                                                  )).
      end.
    end.
    run temp-string_write in this-procedure ( input substitute("_Правило &1:",  p-RULE-id)).
    FOR EACH buf_rule-script NO-LOCK WHERE
            buf_rule-script.RULE_id = p-rULE-id
        AND buf_rule-script.LANGUAGE = "{&language}":
     if buf_rule-script.script-type = {&rule-script-COND} then do:
        if p-language = "{&language}-ext" then do:
          run temp-string_write in this-procedure ( input  substitute("&1/* порядок &2 правила &3*/"
                                                                      ,fill({&space-char}, 70)
                                                                      ,buf_rule-script.salience
                                                                      ,buf_rule-script.rule_id
                                                                      )).
        end.
        run temp-string_write in this-procedure ( input  substitute("&1Если &2 тогда: "
                                                                      ,fill( {&space-char}, p-level * 2)
                                                                      ,buf_rule-script.script )).
        assign
        v-exist-rule-script = yes
        .
      end.
     if buf_rule-script.script-type = {&rule-script-CYCLE-COND} then do:
        if p-language = "{&language}-ext" then do:
          run temp-string_write in this-procedure ( input  substitute("&1/* порядок &2 правила &3*/"
                                                                      ,fill({&space-char}, 70)
                                                                      ,buf_rule-script.salience
                                                                      ,buf_rule-script.rule_id
                                                                      )).
        end.
        run temp-string_write in this-procedure ( input  substitute("&1ПОКА &2: "
                                                                      ,fill( {&space-char}, p-level * 2)
                                                                      ,buf_rule-script.script )).
        assign
        v-exist-rule-script = yes
        .
      end.
      if buf_rule-script.script-type = {&rule-script-RULE}
      or buf_rule-script.script-type = {&rule-script-else-RULE}
      then do:
        find first buf_rule no-lock where
                buf_rule.upper_rule_id = p-rule-id
            and buf_rule.salience = buf_rule-script.salience no-error .
        if not available buf_rule then do:
          message
          substitute("Не найдено правило &1 вышестояшего уровня к скрипту типа &2:&3№ скрипта &4, порядок &5"
                     , p-rule-id
                     , buf_rule-script.script-type
                     , {&new-line}
                     , buf_rule-script.script_id
                     , buf_rule-script.salience )
          view-as alert-box error .
          return.
        end.
        if buf_rule-script.script-type = {&rule-script-else-rule} then do:
          run temp-string_write in this-procedure ( input substitute("&1ИНАЧЕ: /*правило &2*/"
                                                                      ,fill( {&space-char}, p-level * 2)
                                                                      ,buf_rule.rule_id)).
          assign
          v-exist-rule-script = yes
          .
        end.
        p-level = p-level + 1.
        run display-rule ( input buf_rule.rule_id, input buf_rule.upper_rule_id, input p-language, input-output p-level).
        p-level = p-level - 1.
      end.
      if buf_rule-script.script-type = {&rule-script-CONS}
      or buf_rule-script.script-type = {&rule-script-GOTO}
      then do:
        if p-language = "{&language}-ext" then do:
          run temp-string_write in this-procedure ( input substitute("&1/* порядок &2 правила &3*/"
                                                                      ,fill({&space-char}, 70)
                                                                      ,buf_rule-script.salience
                                                                      ,buf_rule-script.rule_id
                                                                      )).
        end.
        run temp-string_write in this-procedure ( input substitute("&1&2 ;"
                                                                    ,fill( {&space-char}, p-level * 2)
                                                                    ,buf_rule-script.script )).
      end.
    END.
    if v-exist-rule-script then do:
      run temp-string_write in this-procedure ( input substitute("&1. /* конец правила &2 */"
                                                                    ,fill( {&space-char}, p-level * 2)
                                                                    ,p-rule-id) ).
    end.
    else do:
      run temp-string_write in this-procedure ( input substitute("&1. /* конец правила &2 */"
                                                                    ,fill( {&space-char}, p-level * 2)
                                                                    ,p-rule-id) ).
    end.
  END.
  when "DOT2-{&language}":U
  or
  when "DOT2-ABL":U then do:
    v-language = entry(2, p-language, "-").
    /*второй проход*/
      /*        a -> b -> c;   */
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
     /*
      run temp-string_write in this-procedure ( input  substitute('Rule&1_&2_&3 [shape=custom, shapefile="texture2.psd", label="Правило\n&1_&2_&3"];'
                                                                , buf_rule.rule_id
                                                                , buf_rule.upper_rule_id
                                                                , buf_rule.salience
                                                                )).
       */
      if buf_rule.hidden-content > 0 then do:
        return.
      end.
    end.
    else do:

    end.
    FOR EACH buf_rule-script NO-LOCK WHERE
            buf_rule-script.RULE_id = p-rULE-id
        AND buf_rule-script.LANGUAGE = v-language:
      if buf_rule-script.script-type = {&rule-script-COND} then do:
        run temp-string_write in this-procedure ( input   substitute('Condition&1_&2 [shape=diamond, fillcolor=yellow, style="rounded,filled", label="&3?"];'
                                                                    , buf_rule-script.rule_id
                                                                    , buf_rule-script.salience
                                                                    , replace(replace(replace(buf_rule-script.script, {&double-quote}, "&#34;":U), "~~n", "\n"), {&new-line}, "\n")
                                                                    )).
      end.
      if buf_rule-script.script-type = {&rule-script-cycle-COND} then do:
        run temp-string_write in this-procedure ( input   substitute('Cyclecondition&1_&2 [shape=trapezium, fillcolor=yellowgreen, style="rounded,filled", label="&3?"];'
                                                                    , buf_rule-script.rule_id
                                                                    , buf_rule-script.salience
                                                                    , replace(replace(replace(buf_rule-script.script, {&double-quote}, "&#34;":U), "~~n", "\n"), {&new-line}, "\n")
                                                                    )).
      end.
      if buf_rule-script.script-type = {&rule-script-CONS} then do:
        run temp-string_write in this-procedure ( input   substitute('Consequence&1_&2 [shape=box, fillcolor=lightgrey, style="rounded,filled", label="&3"];'
                                                                    , buf_rule-script.rule_id
                                                                    , buf_rule-script.salience
                                                                    , replace(replace(replace(buf_rule-script.script, {&double-quote}, "&#34;":U), "~~n", "\n"), {&new-line}, "\n")
                                                                    )).

      end.
      if buf_rule-script.script-type = {&rule-script-goto} then do:
        run temp-string_write in this-procedure ( input   substitute('Goto&1_&2 [shape=invtriangle, fillcolor=pink, style="rounded,filled", label="&3"];'
                                                                    , buf_rule-script.rule_id
                                                                    , buf_rule-script.salience
                                                                    , replace(replace(replace(buf_rule-script.script, {&double-quote}, "&#34;":U), "~~n", "\n"), {&new-line}, "\n")
                                                                    )).

      end.
      if buf_rule-script.script-type = {&rule-script-rule}
      or buf_rule-script.script-type = {&rule-script-else-rule}
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
    when "DOT1-{&language}"
    or
    when "DOT1-ABL"
    then do:
        /*первый проход*/
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
                  and buf_tt-rule-script.script-type <> {&rule-script-rule}
                  and buf_tt-rule-script.script-type <> {&rule-script-else-rule}
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
                    and buf_tt-rule-script.script-type <>  {&rule-script-rule}
                    and buf_tt-rule-script.script-type <>  {&rule-script-else-rule}
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
              end. /*            do while true:*/
              for each buf_tt-rule-script where
                      buf_tt-rule-script.rule_id = buf_tt-rule.rule_id:
                assign
                buf_tt-rule-script.start-script_id = v-start-script-id
                buf_tt-rule-script.end-script_id = v-end-script-id
                buf_tt-rule-script.edge-type = (if v-script-type = {&rule-script-rule}
                                                then "yes"
                                                else "no")
                .
              end.
            end. /*else if buf_tt-rule.rule_id = buf_tt-rule.root_rule_id then do:*/
          end. /*          for each buf_tt-rule no-lock where*/
        end. /*if p-upper-rule-id = 0 then do:*/
       /*
       output to jj.txt.

        for each buf_tt-rule-script:
          export buf_tt-rule-script.
        end.
        output close.
        */
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
          if buf_rule-script.script-type = {&rule-script-RULE}
          or buf_rule-script.script-type = {&rule-script-else-RULE}
          then do:
            find first buf_down-rule no-lock where
                      buf_down-rule.upper_rule_id = p-rule-id
                  and buf_down-rule.salience = buf_rule-script.salience no-error .
            if error-status :error then do:

            end.
            p-level = p-level + 1.
            run display-rule ( input buf_down-rule.rule_id, input buf_down-rule.upper_rule_id, input p-language, input-output p-level).
            p-level = p-level - 1.
          end. /*if buf_rule-script.script-type = {&rule-script-rule} then do:*/
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
            end. /*if buf_temp-edge.to-script_id = -1 then do:*/
            else do:
              find first buf_tt-rule-script where buf_tt-rule-script.script_id = buf_temp-edge.to-script_id no-error .
              if not available buf_tt-rule-script then do:
                next _temp-edge.
              end.
              case buf_tt-rule-script.script-type:
                when {&rule-script-cons} then do:
                  assign
                  v-next-node  = substitute("Consequence&1_&2"
                                      , buf_tt-rule-script.rule_id
                                      , buf_tt-rule-script.salience).

                end.
                when {&rule-script-goto} then do:
                  assign
                  v-next-node  = substitute("Goto&1_&2"
                                      , buf_tt-rule-script.rule_id
                                      , buf_tt-rule-script.salience).

                end.
                when {&rule-script-cond} then do:
                  assign
                  v-next-node  = substitute("Condition&1_&2"
                                      , buf_tt-rule-script.rule_id
                                      , buf_tt-rule-script.salience).

                end.
                when {&rule-script-cycle-cond} then do:
                  assign
                  v-next-node  = substitute("Cyclecondition&1_&2"
                                      , buf_tt-rule-script.rule_id
                                      , buf_tt-rule-script.salience).

                end.
                when {&rule-script-else-rule} then do:
                  next _temp-edge.
                  /*
                  assign
                  v-next-node  = substitute("Cycle&1_&2"
                                      , buf_tt-rule-script.rule_id
                                      , buf_tt-rule-script.salience).
                  */
                end.
              end case.
            end. /*else if buf_temp-edge.to-script_id = -1 then do:*/
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
          end. /*for each buf_temp-edge*/
        end. /*for each buf_rule-script*/
      end. /*when*/

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
    when {&rule-script-COND} then do:
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
            and buf_tt-rule-script.script-type <> {&rule-script-rule}
            and buf_tt-rule-script.script-type <> {&rule-script-else-rule}
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
     end. /*if not available buf_tt-rule-script then do:*/
    end.
    when {&rule-script-cycle-COND} then do:
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
        if v-script-type <> {&rule-script-rule}
        and v-script-type <> {&rule-script-else-rule} then do:
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
      end. /*do while true:*/
    end.
    when {&rule-script-cons}
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
    when {&rule-script-goto} then do:
      assign
      p-current-node  = substitute("Goto&1_&2"
                          , buf_rule-script.rule_id
                          , buf_rule-script.salience).
      find first buf_tt-rule-script where
              buf_tt-rule-script.rule_id = buf_rule-script.rule_id
          and buf_tt-rule-script.language = "ABL"
          and buf_tt-rule-script.salience = buf_rule-script.salience.
      v-goto-text = trim(buf_tt-rule-script.script, {&space-char}).
      if v-goto-text begins "leave":U then do:
        v-goto-rule = trim(trim(replace(v-goto-text, "leave":U, "":U), {&space-char}), "_":U).
        if v-goto-rule = string(buf_rule-script.root_rule_id) then do:
          create buf_temp-edge.
          assign
          buf_temp-edge.from-script_id = buf_rule-script.script_id
          buf_temp-edge.to-script_id =  -1
          buf_temp-edge.edge-type = ""
          .
        end. /*if trim(buf_tt-rule-script.script, {&space-char}*/
        else do:
          assign
          v-int = integer(v-goto-rule) no-error.
          if not error-status:error then do:
            /*надо найти следующее выражение за */
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
      end. /*if v-goto-text begins "leave":U then do:*/
      if v-goto-text begins "next":U then do:
        v-goto-rule = trim(replace(v-goto-text, "next":U, "":U), {&space-char}).
        if v-goto-rule = substitute("_&1", buf_rule-script.root_rule_id) then do:
          find first buf_tt-rule-script where
                    buf_tt-rule-script.rule_id = buf_rule-script.root_rule_id.
          create buf_temp-edge.
          assign
          buf_temp-edge.from-script_id = buf_rule-script.script_id
          buf_temp-edge.to-script_id = buf_tt-rule-script.script_id
          buf_temp-edge.edge-type = ""
          .
        end. /*if trim(buf_tt-rule-script.script, {&space-char}*/
        else do:
          assign
          v-int = integer(trim(v-goto-rule, "_")) no-error.
          if not error-status:error then do:
            /*надо найти следующее выражение за */
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
      end. /*if v-goto-text begins "next":U then do:*/
    end.
  end case. /*case buf_rule-script.script-type:*/
end.

end procedure. /* create-temp-edge */



/* $Workfile$ e n d */