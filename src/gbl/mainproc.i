/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/10/10
Author: Bakhtadze Natalya
Creation date: 02/10/10

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

/*надо сделать так, чтобы такая процедура была единственной!*/
define variable v-uh{&vssseq} as handle no-undo .
define variable v-found{&vssseq} as logical no-undo .

v-uh{&vssseq} = session:first-procedure no-error.
do while valid-handle(v-uh{&vssseq}):
  if v-uh{&vssseq}:type = "PROCEDURE" then do:
    if v-uh{&vssseq}:file-name = "gbl/mainproc.p" then do:
      v-found{&vssseq} = yes.
      leave.
    end.
  end.
  v-uh{&vssseq} = v-uh{&vssseq}:next-sibling no-error.
end.
if not v-found{&vssseq} then do:
  run gbl/mainproc.p persistent.
end.

&if "{1}" ="def" &then
procedure mainhandle_parentproc_indicator :
/*НЕ УДАЛЯТЬ - ИНДИКАТОР САМОГО ГЛАВНОГО ОКНА!!!*/
return.
end procedure. /* mainhandle_parentproc_indicator */
&endif

/* $Workfile$ e n d */