/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Шапка-файл для конифгурации настраиваемых полей

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/04/07
Author: Bakhtadze Natalya
Creation date: 09/04/07

*/


&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".


&glob cl-revision  "v15_1.12"
&glob cl-md5    { cmp/fixcstml.md5 }

procedure check-cl-version :
define output parameter p-check as logical no-undo .
define variable v-dopi1 as integer no-undo .
define variable v-dopi2 as integer no-undo .
define variable v-dopi3 as integer no-undo .
define variable v-dopi4 as integer no-undo .

define buffer buf_custom-labels for ub.custom-labels .


  do
  on error undo, return error
  :
    find first buf_custom-labels no-lock where
              buf_custom-labels.tbl-name = '':U
          and buf_custom-labels.fld-name = '':U
          and buf_custom-labels.call-type = '':U
          and buf_custom-labels.call-point = '':U  no-error.

    if (not available buf_custom-labels
    or buf_custom-labels.custom-tooltip <> {&cl-revision} )
    then do:
      assign
      v-dopi1 = integer(entry(2, buf_custom-labels.custom-tooltip, "."))
      v-dopi2 = integer(entry(2, {&cl-revision}, "."))
      v-dopi3 = integer(entry(2, entry(1, buf_custom-labels.custom-tooltip, "."), "_"))
      v-dopi4 = integer(entry(2, entry(1, {&cl-revision}, "."), "_"))
      no-error .
      if error-status:error
      or v-dopi2 > v-dopi1
      or v-dopi4 > v-dopi3
      or left-trim(entry(1, buf_custom-labels.custom-tooltip, "."), "v":U) < "15"
      then do:
        assign
        p-check = yes.
      end.
    end.
  end.

end procedure. /* check-cl-version */

procedure get-cl-version :
define output parameter p-cl-version as character no-undo init ?.
define buffer buf_custom-labels for ub.custom-labels .

do
on error undo, return error
:
  find first buf_custom-labels no-lock where
            buf_custom-labels.tbl-name = '':U
        and buf_custom-labels.fld-name = '':U
        and buf_custom-labels.call-type = '':U
        and buf_custom-labels.call-point = '':U  no-error.
  if available buf_custom-labels then do:
      p-cl-version = buf_custom-labels.custom-tooltip.
  end.
end.
end procedure. /* get-cl-version */


/* $Workfile$ e n d */