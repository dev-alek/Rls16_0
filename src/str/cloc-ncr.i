/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Закрытие потока и сопутствующие операции для кассы NCR

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/08/03
Author: Bakhtadze Natalya
Creation date: 12/08/03

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".


&if "{&subject}" <> "parameters" &then
  output stream IBMStream close.
&endif

&if "{&subject}" = "parameters" &then
  { str/cloc-ncp.i
  &cd-buffer={&cd-buffer}
  &subject={&subject}
  &out-title-add="{&out-title-add}"
  &out-title-del="{&out-title-del}"
  }
&endif



/* $Workfile$ e n d */