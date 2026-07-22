/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

действия на CREATE wth-dtl

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

CREATE {1}.
ASSIGN
  {1}.doc-code = {2}.doc-code
  {1}.wth-code = {2}.wth-code
  {1}.w-p-code = {2}.w-p-code
  {1}.par-code = {3}
  {1}.creid    = g#userid
  {1}.credate  = TODAY
.

/* $Workfile$   E n d */
