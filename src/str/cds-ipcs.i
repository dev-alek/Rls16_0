/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Завершение работы с кассой типа IPC-servis+ подчистки сообщения и т.д.

Автор: Бахтадзе Наталья Викторовна
Дата создания: 06/23/03
Author: Bakhtadze Natalya
Creation date: 06/23/03

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&if "{&subject}" = "good" &then
  os-delete
  value( string( session:temp-directory + "plu" +
  string( var-report-num ) ) + '.plu' ) .
  os-delete
  value( string( session:temp-directory + "bar" +
  string( var-report-num ) ) + '.bar' ) .
&endif
/* $Workfile$ e n d */