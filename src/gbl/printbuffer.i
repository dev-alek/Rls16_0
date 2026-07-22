/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/21/08
Author: Bakhtadze Natalya
Creation date: 07/21/08


*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

procedure printbuffer private:
define input parameter p-bh as handle no-undo .
define variable v-ii as integer no-undo .
if search("printbuffer.fld") <> ? then do:
  output to value( substitute("&1.txt", p-bh:name)) append.
  put unformatted today {&space-char} string(time, "HH:MM:SS")
  this-procedure :name skip
  skip.
  do v-ii = 1 to p-bh:num-fields:
    if p-bh:buffer-field(v-ii):data-type = {&abl-datatype-rowid} then do:
      put unformatted fill( {&space-char}, 10) p-bh:buffer-field(v-ii):name string(p-bh:buffer-field(v-ii):buffer-value) at 35 skip.
    end.
    else do:
      put unformatted fill( {&space-char}, 10) p-bh:buffer-field(v-ii):name p-bh:buffer-field(v-ii):buffer-value at 35 skip.
    end.
  end.
end.

output close.
end procedure.