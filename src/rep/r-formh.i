/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$



Автор: Чернова Светлана Александровна
Дата создания: 04/12/06
Author: Svetlana Chernova
Creation date: 04/12/06

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
form header
  line format "{1}" at 1 skip
  "Продолжение - на следующей странице" at 30 skip
  with frame bottomframe{3} width {2} page-bottom no-labels no-box .
view stream outstream frame bottomframe{3} .
/* $Workfile$ e n d */