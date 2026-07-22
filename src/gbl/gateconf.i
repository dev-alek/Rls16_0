/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Шапка-файл для конифгурации гейт

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/02/08
Author: Bakhtadze Natalya
Creation date: 02/02/08

*/


&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".


&glob gate-revision  "v15_1.60"
&glob gate-md5    { cmp/fix-gate.md5 }

procedure check-gate-version :
define output parameter p-check as logical no-undo .
define variable v-dopi1 as integer no-undo .
define variable v-dopi2 as integer no-undo .
define variable v-dopi3 as integer no-undo .
define variable v-dopi4 as integer no-undo .
define buffer buf_clob-bind for ub.clob-bind .


  do
  on error undo, return error
  :
    find first buf_clob-bind no-lock where
              buf_clob-bind.db-num = 0
         and  buf_clob-bind.int64-id = 0
              no-error.

    if (not available buf_clob-bind
    or buf_clob-bind.descr <> {&gate-revision} )
    then do:
      assign
      v-dopi1 = integer(entry(2, buf_clob-bind.descr,  "."))
      v-dopi2 = integer(entry(2, {&gate-revision}, "."))
      v-dopi3 = integer(entry(2, entry(1, buf_clob-bind.descr, "."), "_"))
      v-dopi4 = integer(entry(2, entry(1, {&gate-revision}, "."), "_"))
      no-error .
      if error-status:error
      or v-dopi2 > v-dopi1
      or v-dopi4 > v-dopi3
      or left-trim(entry(1, buf_clob-bind.descr, "."), "v":U) < "15"
      then do:
        assign
        p-check = yes.
      end.
    end.
  end.

end procedure. /* check-gate-version */

procedure get-gate-version :
define output parameter p-gate-version as character no-undo init ?.
define buffer buf_clob-bind for ub.clob-bind .

do
on error undo, return error
:
  find first buf_clob-bind no-lock where
            buf_clob-bind.db-num = 0
        and  buf_clob-bind.int64-id = 0
            no-error.
  if available buf_clob-bind then do:
    p-gate-version = buf_clob-bind.descr.
  end.
end.
end procedure. /* get-rum-version */


/* $Workfile$ e n d */