/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

вызов процедуры создания obj-list

Автор: Чернова Светлана Александровна
Дата создания: 09/12/05
Author: Svetlana Chernova
Creation date: 09/12/05

Creation date: 09/17/02 1:40
1 - obj-type
2 - obj-code
3 - no-error


*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run create_obj-list in this-procedure
 ( input {1} ,
   input {2} )
  {3} .

/* $Workfile$ e n d */