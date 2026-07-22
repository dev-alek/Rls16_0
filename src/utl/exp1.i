/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Экспорт таблиц для чеков

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/14/06
Author: Bakhtadze Natalya
Creation date: 04/14/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

export  stream exp-stream  "{1}"
&if "{1}" = "chk-doc" &then
  {1}.out-code {1}.doc-code
&endif
 .
export  stream exp-stream  {&src}.{1}.


/* $Workfile$ e n d */