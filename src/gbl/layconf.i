/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Шапка-файл для конифгурации раскладок

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/26/08
Author: Bakhtadze Natalya
Creation date: 09/26/08

*/


&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".


&glob layout-revision  "v15_1.11"
&glob layout-md5    { cmp/fix-lay.md5 }

procedure check-layout-version :
define output parameter p-check as logical no-undo .
define variable v-dopi1 as integer no-undo .
define variable v-dopi2 as integer no-undo .
define variable v-dopi3 as integer no-undo .
define variable v-dopi4 as integer no-undo .
define buffer buf_layout for ub.layout .


  do
  on error undo, return error
  :
    find first buf_layout no-lock where
              buf_layout.layout-id = '_'  no-error.

    if (not available buf_layout
    or buf_layout.layout-name <> {&layout-revision} )
    then do:
      assign
      v-dopi1 = integer(entry(2, buf_layout.layout-name,  "."))
      v-dopi2 = integer(entry(2, {&layout-revision}, "."))
      v-dopi3 = integer(entry(2, entry(1, buf_layout.layout-name, "."), "_"))
      v-dopi4 = integer(entry(2, entry(1, {&layout-revision}, "."), "_"))
      no-error .
      if error-status:error
      or v-dopi2 > v-dopi1
      or v-dopi4 > v-dopi3
      or left-trim(entry(1, buf_layout.layout-name, "."), "v":U) < "15"
      then do:
        assign
        p-check = yes.
      end.
    end.
  end.

end procedure. /* check-layout-version */

procedure get-layout-version :
define output parameter p-layout-version as character no-undo init ?.
define buffer buf_layout for ub.layout .

do
on error undo, return error
:
  find first buf_layout no-lock where
              buf_layout.layout-id = '_'  no-error.
  if available buf_layout then do:
    p-layout-version = buf_layout.layout-name.
  end.
end.
end procedure. /* get-rum-version */


/* $Workfile$ e n d */