/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Шапка-файл для конифгурации настраиваемых полей

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/12/07
Author: Bakhtadze Natalya
Creation date: 09/12/07

*/


&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".


&glob rum-revision  "v16_0.13"
&glob rum-md5    { cmp/fixrum.md5 }

procedure check-rum-version :
define output parameter p-check as logical no-undo .
define variable v-dopi1 as integer no-undo .
define variable v-dopi2 as integer no-undo .
define variable v-dopi3 as integer no-undo .
define variable v-dopi4 as integer no-undo .
define buffer buf_ruledict for ub.ruledict .


  do
  on error undo, return error
  :
    find first buf_ruledict no-lock where
              buf_ruledict.entry-id = 0  no-error.

    if (not available buf_ruledict
    or buf_ruledict.documentation <> {&rum-revision} )
    then do:
      assign
      v-dopi1 = integer(entry(2, buf_ruledict.documentation,  "."))
      v-dopi2 = integer(entry(2, {&rum-revision}, "."))
      v-dopi3 = integer(entry(2, entry(1, buf_ruledict.documentation, "."), "_"))
      v-dopi4 = integer(entry(2, entry(1, {&rum-revision}, "."), "_"))
      no-error .
      if error-status:error
      or v-dopi2 > v-dopi1
      or v-dopi4 > v-dopi3
      or left-trim(entry(1, buf_ruledict.documentation, "."), "v":U) < "16"
      then do:
        assign
        p-check = yes.
      end.
    end.
  end.

end procedure. /* check-rum-version */

procedure get-rum-version :
define output parameter p-rum-version as character no-undo init ?.

define buffer buf_ruledict for ub.ruledict .


do
on error undo, return error
:
  find first buf_ruledict no-lock where
            buf_ruledict.entry-id = 0  no-error.
  if available buf_ruledict then do:
    p-rum-version = buf_ruledict.documentation.
  end.
end.
end procedure. /* get-rum-version */


/* $Workfile$ e n d */