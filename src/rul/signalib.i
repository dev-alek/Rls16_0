/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Получение сигнатуры

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/12/07
Author: Bakhtadze Natalya
Creation date: 02/12/07

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

procedure signalib_fill-signature :
define input parameter p-script-name as character no-undo .
define input parameter p-script-head as character no-undo .
define input parameter p-proc-type as character no-undo .
DEFINE OUTPUT PARAMETER p-signature AS CHARACTER NO-UNDO.

define variable v-ii as integer no-undo .
define variable v-signature as character no-undo .
define variable v-params as character no-undo .
define variable v-entry as character no-undo .

do
on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
:

  CASE p-proc-type:
    when {&script-ptype-class} then do:
      p-signature = substitute("CLASS,,,,").
    end.
    when {&script-ptype-constructor} then do:
      p-signature = substitute("CONSTRUCTOR,PUBLIC,,,void,").
    end.
    when {&script-ptype-destructor} then do:
      p-signature = substitute("DESTRUCTOR,PUBLIC,,,void").
    end.
    when {&script-ptype-data-member} then do:
      p-signature = substitute("DATA-MEMBER,PUBLIC," ).
    end.
    when {&script-ptype-property} then do:
      p-signature = substitute("PROPERTY,PUBLIC,,").
    end.
    when {&script-ptype-method} then do:
      assign
      p-signature = entry(1, p-script-head, "(")
      p-signature = replace(p-signature, {&space-char} + {&space-char} , {&space-char} )
      p-signature = {&script-ptype-method} + {&comma-char} + entry(2, p-signature, {&space-char}) +
                                             {&comma-char} + entry(3, p-signature, {&space-char}) +
                                             {&comma-char} + (if num-entries(p-signature, {&space-char}) > 4
                                                              then  entry(5, p-signature, {&space-char})
                                                              else '':U) +
                                             {&comma-char} + (if num-entries(p-signature, {&space-char}) > 5
                                                              then  entry(6, p-signature, {&space-char})
                                                              else '':U)
      .
      assign
      v-params = trim(entry(2, p-script-head , "(":U), ")") no-error
      .
      ASSIGN
      v-params = REPLACE(v-params, ")", "":U)
      v-params = REPLACE(v-params, ":", "":U)
      .
      if v-params <> '':U then do:
        do v-ii = 1 to num-entries(v-params):
            assign
            v-entry = trim(entry(v-ii, v-params), {&space-char} )
            v-entry =  replace(v-entry, " as ", {&space-char})
            v-entry =  replace(v-entry, "ub.", {&space-char})
            v-entry =  replace(v-entry, " for ", "")
            v-entry = replace (v-entry, {&space-char} + {&space-char} , {&space-char} )
            p-signature = p-signature + {&comma-char} + v-entry.
        end.
      end.
      else do:
        p-signature = p-signature + {&comma-char}.
      end.
    end.
    when {&script-ptype-function} then do:
      assign
      p-signature = entry(1, p-script-head, "(")
      p-signature = replace(p-signature, {&space-char} + {&space-char} , {&space-char} )
      p-signature = replace(p-signature, "returns", "":U )
      p-signature = replace(p-signature, {&space-char} + {&space-char} , {&space-char} )
      p-signature = {&script-ptype-function} + {&comma-char} + entry(3, p-signature, {&space-char})
      p-signature = trim(p-signature, ':')
      .

      assign
      v-params = trim(entry(2, p-script-head , "(":U), ")") no-error
      .
      ASSIGN
      v-params = REPLACE(v-params, ")", "":U)
      v-params = REPLACE(v-params, ":", "":U)
      .
      if v-params <> '':U then do:
        do v-ii = 1 to num-entries(v-params):
            assign
            v-entry = trim(entry(v-ii, v-params), {&space-char} )
            v-entry =  replace(v-entry, " as ", {&space-char})
            v-entry =  replace(v-entry, "ub.", {&space-char})
            v-entry =  replace(v-entry, " for ", "")
            v-entry = replace (v-entry, {&space-char} + {&space-char} , {&space-char} )
            p-signature = p-signature + {&comma-char} + v-entry.
        end.
      end.
      else do:
        p-signature = p-signature + {&comma-char}.
      end.
    end. /*when {&script-ptype-function} */
  END CASE.
end.

end procedure. /* signalib_fill-signature */

FUNCTION signalib_get-params-from-signa returns character ( input p-proc-type as character
                                                           ,input p-signature-string as character):
define variable v-param-string as character no-undo .
v-param-string = p-signature-string.
case p-proc-type:
  when {&script-ptype-function}
  or
  when {&script-ptype-procedure} then do:
    entry(1, v-param-string) = '':U.
    if num-entries(v-param-string) > 1 then
    entry(2, v-param-string) = '':U.
    v-param-string = left-trim( v-param-string, {&comma-char}).
  end.
  when {&script-ptype-method}
  or when {&script-ptype-constructor}
  then do:
    entry(1, v-param-string) = '':U.
    entry(2, v-param-string) = '':U.
    entry(3, v-param-string) = '':U.
    entry(4, v-param-string) = '':U.
    entry(5, v-param-string) = '':U.
    v-param-string = left-trim( v-param-string, {&comma-char}).
  end.
  otherwise do:
    v-param-string = '':U.
  end.
end case.
return v-param-string.
end function.


procedure signalib_write-rdp :
define input parameter p-entry-id as integer no-undo .
define input parameter p-language as character no-undo .
define input parameter p-signature-param as character no-undo .

define variable v-ii as integer no-undo .
define buffer buf_ruledict-param for ub.ruledict-param.


do
on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
:

  for each buf_ruledict-param where
          buf_ruledict-param.entry-id = p-entry-id
      and buf_ruledict-param.language = p-language
  on error undo, return error:
      delete buf_ruledict-param.
  end.
  do v-ii = 1 to num-entries(p-signature-param):
    create buf_ruledict-param.
    assign
    buf_ruledict-param.entry-id = p-entry-id
    buf_ruledict-param.language = 'ABL':U
    buf_ruledict-param.param-num = v-ii
    buf_ruledict-param.param-mode = entry(1, entry(v-ii, p-signature-param), {&space-char} )
    buf_ruledict-param.param-name = entry(2, entry(v-ii, p-signature-param), {&space-char} )
    buf_ruledict-param.param-data-type = entry(3, entry(v-ii, p-signature-param), {&space-char} )
    .
  end.
end.

end procedure. /* getparam */



/* $Workfile$ e n d */