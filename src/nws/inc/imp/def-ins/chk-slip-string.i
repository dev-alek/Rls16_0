/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

разбор записи chk-slip-string из пакета

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

if true
then do :
  run skip-rec in p-imp-handle no-error .
  return .
end .
else do :
end .

/* $Workfile$ e n d */