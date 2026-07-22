/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Функции псевдокласса КОНТЕКСТ ПРАВИЛА

Автор: Бахтадзе Наталья Викторовна
Дата создания: 05/13/07
Author: Bakhtadze Natalya
Creation date: 05/13/07

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

{ bge/sendesys.i {1}}

&if "{1}" = "get-next-rule-call-param" &then
FUNCTION context_get-next-rule-call-param returns logical ( input p-param-name as character
                                                          , input-output p-index as integer):
define buffer buf_temp-rule-call-param for temp-rule-call-param.
find first buf_temp-rule-call-param where
          buf_temp-rule-call-param.param-name = p-param-name
      and buf_temp-rule-call-param.p-index > p-index no-error .
if available buf_temp-rule-call-param then do:
  p-index = buf_temp-rule-call-param.p-index.
end.
return available(buf_temp-rule-call-param).
END FUNCTION.

&endif

&if "{1}" = "get-last-rule-call-param" &then

FUNCTION context_get-next-rule-call-param returns logical ( input p-param-name as character
                                                           , output p-index as integer):
define buffer buf_temp-rule-call-param for temp-rule-call-param.
find last buf_temp-rule-call-param where
          buf_temp-rule-call-param.param-name = p-param-name no-error .
if available buf_temp-rule-call-param then do:
  p-index = buf_temp-rule-call-param.p-index.
end.
return available(buf_temp-rule-call-param).
END FUNCTION.

&endif

&if "{1}" = "get-rule-call-param_integer" &then
FUNCTION context_get-rule-call-param_integer returns integer (  input p-param-name as character
                                                               ,input p-index as integer):
define buffer buf_temp-rule-call-param for temp-rule-call-param.
find first buf_temp-rule-call-param where
          buf_temp-rule-call-param.param-name = p-param-name
      and buf_temp-rule-call-param.p-index = p-index
          no-error .
if available buf_temp-rule-call-param then do:
  return buf_temp-rule-call-param.param-value-integer.
end.
end function.
&endif










/* $Workfile$ e n d */