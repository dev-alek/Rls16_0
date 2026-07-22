/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Шапка-файл для конфигурации атрибутов

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/04/07
Author: Bakhtadze Natalya
Creation date: 09/04/07

*/


&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".


&glob ap-revision  "v15_1.3"
&glob ap-md5    { cmp/fixattrp.md5 }

procedure check-ap-version :
define output parameter p-check as logical no-undo .
define variable v-dopi1 as integer no-undo .
define variable v-dopi2 as integer no-undo .
define variable v-dopi3 as integer no-undo .
define variable v-dopi4 as integer no-undo .

define buffer buf_attr-prop for ub.attr-prop .


  do
  on error undo, return error
  :
    find first buf_attr-prop no-lock where
              buf_attr-prop.node-code = 0
          and buf_attr-prop.table-name = '':U
          and buf_attr-prop.templ-rl-root = 0   no-error.

    if (not available buf_attr-prop
    or buf_attr-prop.property-value <> {&ap-revision} )
    then do:
      assign
      v-dopi1 = integer(entry(2, buf_attr-prop.property-value, "."))
      v-dopi2 = integer(entry(2, {&ap-revision}, "."))
      v-dopi3 = integer(entry(2, entry(1, buf_attr-prop.property-value, "."), "_"))
      v-dopi4 = integer(entry(2, entry(1, {&ap-revision}, "."), "_"))
      no-error .
      if error-status:error
      or v-dopi2 > v-dopi1
      or v-dopi4 > v-dopi3
      or left-trim(entry(1, buf_attr-prop.property-value, "."), "v":U) < "15"
      then do:
        assign
        p-check = yes.
      end.
    end.
  end.

end procedure. /* check-ap-version */

procedure get-ap-version :
define output parameter p-ap-version as character no-undo init ?.
define buffer buf_attr-prop for ub.attr-prop .
find first buf_attr-prop no-lock where
          buf_attr-prop.node-code = 0
      and buf_attr-prop.table-name = '':U
      and buf_attr-prop.templ-rl-root = 0   no-error.
if available buf_attr-prop then do:
  p-ap-version = buf_attr-prop.property-value.
end.
end procedure. /* get-ap-version */





/* $Workfile$ e n d */