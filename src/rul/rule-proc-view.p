block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Просмотр правил, запускающихся в rum, для конкретного процесса и конкретного вызова

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/26/08
Author: Bakhtadze Natalya
Creation date: 02/26/08

*/

define input parameter p-pchain-type as character no-undo .
define input parameter p-pchain-id as character no-undo .
define input parameter p-start-from as integer no-undo .
define input parameter p-call-id as character no-undo .
define input parameter p-profile-id as integer no-undo .
define input parameter p-once-more as integer no-undo .
define input parameter p-mode as character no-undo .
define input parameter p-txt-cont-handle as handle no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Просмотр правил, запускающихся в rum, для конкретного процесса и конкретного вызова".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ rul/pch-link.i "SHARED" }
{ rul/tempstrn.i }
{ rul/disprclp.i }
{ rul/disprdps.i }
{ rul/calldscr.i }
{ gbl/waitfram.i }
{ gbl/key-rec.i }


define temp-table temp-edge no-undo
field from-link-id as integer
field to-link-id as integer
field from-order_id as integer
field to-order_id as integer
field edge-type as character
index pi is unique primary
from-link-id
to-link-id
from-order_id
to-order_id
index isearch
to-link-id
to-order_id
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


define variable v-can-calc-string as character no-undo .
define variable v-label as character no-undo .
define variable v-name as character no-undo .
define variable v-node-name as character no-undo .
define variable v-proc-name as character no-undo .
define variable v-name-full as character no-undo .
define variable err-file as character no-undo .
define variable res as character no-undo .
define variable v-cmdln as character no-undo .
define variable v-before-string-num as integer no-undo .
define variable v-after-string-num as integer no-undo .
define variable v-param-string-num as integer no-undo .
define variable v-prev-node-name as character no-undo .
define variable v-fill-color as character no-undo .
define variable v-blank as integer no-undo .
define variable v-first-node-name as character no-undo .
define variable v-last-node-name as character no-undo .
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
define variable v-prev-link-id as integer no-undo .
define variable v-prev-order-id as integer no-undo .
define variable v-handle as handle no-undo .
define buffer buf_rule-process for ub.rule-process .
define buffer buf_temp-pchain-link-rule for temp-pchain-link-rule .
define buffer buf_rule-by-call for ub.rule-by-call.
define buffer buf_rule-by-profile for ub.rule-by-profile.
define buffer buf_rule-profile for ub.rule-profile.
define buffer buf_rule for ub.rule.
define buffer buf_ruleset for ub.ruleset.
define buffer buf_TEMP-STRING  for temp-string.
define buffer buf_temp-edge for temp-edge.
define stream outstream.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  for each buf_temp-pchain-link-rule:
    delete buf_temp-pchain-link-rule.
  end.
  if p-txt-cont-handle = ?
  or not valid-handle(p-txt-cont-handle)
  then do:
    v-handle = this-procedure:handle.
  end.
  else do:
    v-handle = p-txt-cont-handle.
  end.
  run temp-string_clear in v-handle .
  if p-profile-id > 0 then do:
    find first buf_rule-profile no-lock where
              buf_rule-profile.profile_id = p-profile-id.
  end.
  case p-pchain-type:
    when {&table_dis-card-type} then do:
  &scop dct-proc-code p-pchain-id
      v-proc-name = {&dct-proc-name}.
    end.
  end case.
  v-name-full =  substitute("&1: выполнение процесса &2 &3"
                                          , (if p-call-id = '':U
                                              then buf_rule-profile.name
                                              else calldscr( p-call-id))
                                          , v-proc-name
                                          , (if p-start-from = 0
                                              then "Актив.сторона-ГБД"
                                              else (if p-start-from = 1
                                                    then "Актив.сторона-УБД"
                                                    else "")
                                                    )
                                          ).
  for each buf_rule-process where
          buf_rule-process.pchain-type = p-pchain-type
      and buf_rule-process.pchain-id = p-pchain-id
      and buf_rule-process.start-from = p-start-from:
    if p-call-id = '':u then do:
      for each buf_rule-by-profile no-lock where
              buf_rule-by-profile.profile_id = p-profile-id
          and buf_rule-by-profile.codex_id = buf_rule-process.codex_id
          and buf_rule-by-profile.ruleset_id = buf_rule-process.ruleset_id:
        create buf_temp-pchain-link-rule.
        buffer-copy buf_rule-process to buf_temp-pchain-link-rule.
        buffer-copy buf_rule-by-profile to buf_temp-pchain-link-rule
        assign
        buf_temp-pchain-link-rule.order_id = buf_rule-by-profile.rp_order_id
        buf_temp-pchain-link-rule.can-calc = not (buf_rule-by-profile.is_dynamic)
        .
      end.
    end.
    else do:
      for each buf_rule-by-call no-lock where
          buf_rule-by-call.call_id = p-call-id
      and buf_rule-by-call.codex_id = buf_rule-process.codex_id
      and buf_rule-by-call.ruleset_id = buf_rule-process.ruleset_id:
        if p-profile-id > 0
        and buf_rule-by-call.profile_id <> p-profile-id then next.
        if p-once-more >= 0
        and buf_rule-by-call.once-more <> p-once-more then next.
        create buf_temp-pchain-link-rule.
        buffer-copy buf_rule-process to buf_temp-pchain-link-rule.
        buffer-copy buf_rule-by-call to buf_temp-pchain-link-rule.
      end.
    end.
  end.
  case p-mode:
    when "text"
    or when "text-temp"
    then do:
      for each buf_temp-pchain-link-rule
      break
      by buf_temp-pchain-link-rule.pchain-id
      by buf_temp-pchain-link-rule.start-from
      by buf_temp-pchain-link-rule.link-id:
        if first-of(buf_temp-pchain-link-rule.link-id) then do:
          find first buf_ruleset no-lock where
                    buf_ruleset.codex_id = buf_temp-pchain-link-rule.codex_id
                and buf_ruleset.ruleset_id = buf_temp-pchain-link-rule.ruleset_id.
          run temp-string_write in v-handle ( input fill("=", 80)).
          run temp-string_write in v-handle ( input  substitute("&1:   &2"
                                                                      ,(if buf_temp-pchain-link-rule.run-db0 > 0
                                                                        then "ГБД"
                                                                        else "УБД")
                                                                      ,CAPS(buf_ruleset.name))).
        end.
        find first buf_rule no-lock where
                  buf_rule.rule_id = buf_temp-pchain-link-rule.rule_id.
        if p-call-id = '':U then do:
          if buf_temp-pchain-link-rule.can-calc = false then do:
            v-can-calc-string = "[Вкл/Выкл] ".
          end.
          else do:
            v-can-calc-string = '':U.
          end.
        end.
        else do:
          if buf_temp-pchain-link-rule.can-calc = false then do:
            v-can-calc-string = '[Выкл] ':U.
          end.
          else do:
            v-can-calc-string = '[Вкл] ':U.
          end.
        end.
        if p-call-id = '':U then do:
          run temp-string_write in v-handle ( input substitute("Правило &1", buf_rule.rule_id)).
        end.
        else do:
          run temp-string_write in v-handle ( input substitute("Правило &1, Профайл &2"
                                                                    , buf_rule.rule_id
                                                                    , buf_temp-pchain-link-rule.profile_id
                                                                    )).
        end.
        run temp-string_write in v-handle ( input substitute("&1&2&3&4"
                                                                  ,v-can-calc-string
                                                                  ,buf_rule.name
                                                                  ,{&new-line}
                                                                  ,buf_rule.documentation)).
        if p-call-id = '':U then do:
          RUN display-ruledict-params IN v-handle (
                                                           input p-mode
                                                          ,input buf_rule.rule_id).
        end.
        else do:
          if p-mode = "text" then do:
          RUN display-rule-call-params IN THIS-PROCEDURE (
                                                             input p-mode
                                                            ,INPUT buf_temp-pchain-link-rule.codex_id
                                                            ,INPUT buf_temp-pchain-link-rule.ruleset_id
                                                            ,INPUT p-call-id
                                                            ,input p-once-more
                                                            ,INPUT buf_temp-pchain-link-rule.order_id
                                                            ,input v-handle
                                                            ).
        end.
          if p-mode = "text-temp" then do:
            RUN display-rule-call-params IN v-handle (
                                                              input p-mode
                                                              ,INPUT buf_temp-pchain-link-rule.codex_id
                                                              ,INPUT buf_temp-pchain-link-rule.ruleset_id
                                                              ,INPUT p-call-id
                                                              ,input p-once-more
                                                              ,INPUT buf_temp-pchain-link-rule.order_id
                                                              ,input v-handle
                                                              ).

          end.
        end.
        if last-of(buf_temp-pchain-link-rule.link-id) then do:
          run temp-string_write in v-handle ( input fill({&new-line}, 2)).
        end.
        else do:
          run temp-string_write in v-handle ( input fill({&new-line}, 1)).
        end.

      end.
      if v-handle = this-procedure:handle then do:
      run gbl/notese.w ( INPUT THIS-PROCEDURE:HANDLE
                          ,input v-name-full).
    end.
    end.
    when "graph" then do:
      /*сначала сделаем edge*/
      for each buf_temp-pchain-link-rule
      break
      by buf_temp-pchain-link-rule.pchain-id
      by buf_temp-pchain-link-rule.start-from
      by buf_temp-pchain-link-rule.link-id:
        if buf_temp-pchain-link-rule.link-btwn-profiles >= 0 then do:
          create buf_temp-edge.
          assign
          buf_temp-edge.from-link-id = v-prev-link-id
          buf_temp-edge.to-link-id   = buf_temp-pchain-link-rule.link-id
          buf_temp-edge.from-order_id = v-prev-order-id
          buf_temp-edge.to-order_id = buf_temp-pchain-link-rule.order_id
          .
        end.
        assign
        v-prev-link-id = buf_temp-pchain-link-rule.link-id
        v-prev-order-id = buf_temp-pchain-link-rule.order_id
        .
      end.

      run temp-string_write in this-procedure ( input substitute("digraph ruleproc ~{"
                                                                )).
      run temp-string_write in this-procedure ( input substitute("compaund=true;"
                                                                )).
      run temp-string_write in this-procedure ( input substitute("rankdir=TB;"
                                                                )).
      run temp-string_write in this-procedure ( input substitute("ratio=auto;"
                                                                )).

      for each buf_temp-pchain-link-rule
      break
      by buf_temp-pchain-link-rule.pchain-id
      by buf_temp-pchain-link-rule.start-from
      by buf_temp-pchain-link-rule.link-id:
        if first-of(buf_temp-pchain-link-rule.link-id) then do:
          find first buf_ruleset no-lock where

                    buf_ruleset.codex_id = buf_temp-pchain-link-rule.codex_id
                and buf_ruleset.ruleset_id = buf_temp-pchain-link-rule.ruleset_id.
           run temp-string_write in this-procedure ( input substitute("subgraph cluster&1_&2 ~{"
                                                                     , buf_temp-pchain-link-rule.codex_id
                                                                     , buf_temp-pchain-link-rule.ruleset_id
                                                                     )).
           run temp-string_write in this-procedure ( input substitute("node  [style=filled, fontsize=12];")).
          run temp-string_write in this-procedure ( input substitute('nodesep=0.30;')).
          run temp-string_write in this-procedure ( input substitute('ranksep=0.30;')).
        end.
        v-node-name = substitute("n&1_&2"
                                  , buf_temp-pchain-link-rule.link-id
                                  , buf_temp-pchain-link-rule.order_id).
        find first buf_rule no-lock where
                  buf_rule.rule_id = buf_temp-pchain-link-rule.rule_id.
        if p-call-id = '':U then do:
          if buf_temp-pchain-link-rule.can-calc = false then do:
            v-can-calc-string = "[Вкл/Выкл] ".
            v-fill-color = "yellow".
          end.
          else do:
            v-can-calc-string = '':U.
            v-fill-color = "palegreen".
          end.
        end.
        else do:
          if buf_temp-pchain-link-rule.can-calc = false then do:
            v-can-calc-string = '[Выкл] ':U.
            v-fill-color = "lightgrey".
          end.
          else do:
            v-can-calc-string = '[Вкл] ':U.
            v-fill-color = "palegreen".
          end.
        end.
        if p-call-id = '':U then do:
          v-label = substitute("Правило &1", buf_rule.rule_id).
        end.
        else do:
          v-label = substitute("Правило &1, Профайл &2"
                              , buf_rule.rule_id
                              , buf_temp-pchain-link-rule.profile_id
                              ).
        end.
        v-label = substitute("&1&2&3&4&5&6"
                            ,v-label
                            ,"\n"
                            ,v-can-calc-string
                            ,buf_rule.name
                            , /*{&new-line}*/ "\n"
                            ,buf_rule.documentation).
        run temp-string_write in this-procedure ( input substitute('&1 [label="&2", fillcolor=&3, shape=box, style=filled, group=&1];'
                                                                    ,v-node-name
                                                                    ,v-label
                                                                    ,v-fill-color
                                                                    )).

        run temp-string_get-last-num in this-procedure ( output v-before-string-num).

        if p-call-id = '':U then do:
          v-blank = 1.
          RUN display-ruledict-params IN THIS-PROCEDURE (   input p-mode
                                                          ,input buf_rule.rule_id).
        end.
        else do:
          v-blank = 2.
          if p-mode = "text" then do:
          RUN display-rule-call-params IN THIS-PROCEDURE (
                                                             input p-mode
                                                            ,INPUT buf_temp-pchain-link-rule.codex_id
                                                            ,INPUT buf_temp-pchain-link-rule.ruleset_id
                                                            ,INPUT p-call-id
                                                            ,input p-once-more
                                                            ,INPUT buf_temp-pchain-link-rule.order_id
                                                            ,input v-handle
                                                            ).
        end.
          if p-mode = "text-temp" then do:
            RUN display-rule-call-params IN v-handle (
                                                              input p-mode
                                                              ,INPUT buf_temp-pchain-link-rule.codex_id
                                                              ,INPUT buf_temp-pchain-link-rule.ruleset_id
                                                              ,INPUT p-call-id
                                                              ,input p-once-more
                                                              ,INPUT buf_temp-pchain-link-rule.order_id
                                                              ,input v-handle
                                                              ).

          end.
        end.

        run temp-string_get-last-num in this-procedure ( output v-after-string-num).
        v-prev-node-name = substitute("&1", v-node-name).
        if (v-after-string-num - v-before-string-num) > v-blank then do:
          run temp-string_get-last-num in this-procedure ( output v-param-string-num).

          run temp-string_write in this-procedure ( input substitute('p&1 [shape=record,label="~{'
                                                                     ,v-node-name
                                                                     )).

          for each buf_temp-string where
                  buf_temp-string.string-num > v-before-string-num
             and buf_temp-string.string-num <= v-after-string-num
          break
          by buf_temp-string.string-num:
            run temp-string_read in this-procedure (
                                                      input buf_temp-string.string-num
                                                      ,output v-label).
            if v-label > '':U then do:
              run temp-string_append in this-procedure (
                                                        input (v-param-string-num + 1)
                                                        ,input substitute("<f&1>&2&3"
                                                                          ,buf_temp-string.string-num
                                                                          ,replace(v-label, "|", "/")
                                                                          ,(if last(buf_temp-string.string-num)
                                                                            then ''
                                                                            else "|")
                                                                          )
                                                        ,input '':U).
           end.
           run temp-string_delete-range in this-procedure ( input buf_temp-string.string-num
                                                            ,input buf_temp-string.string-num).

          end.
          run temp-string_append in this-procedure (
                                                    input v-param-string-num + 1
                                                   ,input substitute('~}"];')
                                                    ,input '').
          run temp-string_write in this-procedure ( input substitute('~{rank=same; p&1; &1;~}'
                                                                    ,v-node-name
                                                                      )).

        end.
        else do:
           run temp-string_delete-range in this-procedure ( input (v-before-string-num + 1)
                                                           ,input v-after-string-num
                                                           ).
        end.
        find first buf_temp-edge where
                  buf_temp-edge.to-link-id = buf_temp-pchain-link-rule.link-id
              and buf_temp-edge.to-order_id = buf_temp-pchain-link-rule.order_id no-error.
        if available buf_temp-edge
        and buf_temp-edge.from-link-id > 0
        then do:
           run temp-string_write in this-procedure ( input substitute("n&1_&2:s->n&3_&4:n [weight=1000000];"
                                                                       ,buf_temp-edge.from-link-id
                                                                       ,buf_temp-edge.from-order_id
                                                                       ,buf_temp-edge.to-link-id
                                                                       ,buf_temp-edge.to-order_id
                                                                         )).

        end.
        if last-of(buf_temp-pchain-link-rule.link-id) then do:
           v-label = substitute("&1:   &2"
                                ,(if buf_temp-pchain-link-rule.run-db0 > 0
                                  then "ГБД"
                                  else "УБД")
                                ,CAPS(buf_ruleset.name)).
           run temp-string_write in this-procedure ( input substitute('label ="&1";'
                                                                      ,v-label)).
           run temp-string_write in this-procedure ( input "~}").
        end.
      end.

      run temp-string_write in this-procedure ( input "~}").
      v-name = substitute( "&1_&2_3_&4_5"
                        ,p-pchain-type
                        ,p-pchain-id
                        ,replace(p-call-id, {&delim-key}, "")
                        ,p-profile-id).

      output stream outstream to value( v-name  + ".dot") convert target "UTF-8" .

      for each buf_temp-string
      on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
      :
        put stream outstream unformatted buf_temp-string.v-string {&new-line}.

      end.
      output stream outstream close.

      /*  return.*/
      run gbl/_tmpfile.p ( input ""
                          ,input  ""
                          ,output err-file) .

      assign
      v-short-file-name = v-name + ".dot"
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
      /*run rep/killspac.p ( input-output v-file-name-cmd).*/
      /* формирование командной строки для запуска дополнительной сессии */
      assign
      err-file = err-file + ".err":u
      v-cmdln = substitute('"&1" -Tgif &2 -o &3 -Gcharset=UTF-8 > &4'
                          ,v-file-name-cmd
                          ,v-file-name-dot
                          ,v-file-name-gif
                          ,err-file
                          ).
      .
      /*
      run gbl/syn3.p
        (input v-cmdln
        ,input err-file
        ,input "Ждите! Идет форматирование файла..."
        ,output res
        ) no-error .
      */
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
      /*теперь сделаем html страницу*/
      v-file-name-html = replace(v-file-name-dot, ".dot", ".html").
      output stream Outstream to value(v-file-name-html).
      put stream Outstream unformatted
      substitute('<IMG SRC="&1.gif" ALT="&2">', v-name, v-name-full)
      skip.
      output stream Outstream close.

      run gbl/open_url.p ( input  v-file-name-html) no-error .
      if search("grafdisp.dbg") = ? then do:
        os-delete value(v-file-name-dot).
        /*пыталась убивть чтобы не мусорить на диске - не работает так6*/
        /*
        os-delete value(v-file-name-gif).
        os-delete value(v-file-name-html).
        */
      end.
      os-delete value(err-file).

    end.
    otherwise do:
      message
      substitute("Неверный параметр p-mode=&1 при вызове показа процесса", p-mode)
      view-as alert-box .
    end.
  end case.
end.

/*callback не стирать*/
PROCEDURE request-add-line :
DEFINE INPUT PARAMETER p-notes-handle AS HANDLE NO-UNDO.
DEFINE BUFFER buf_temp-string FOR temp-string.

for each buf_temp-string:
    RUN add-line IN p-notes-handle ( INPUT buf_temp-string.v-string).
    RUN add-line IN p-notes-handle ( INPUT {&new-line}).

  end.
END PROCEDURE.