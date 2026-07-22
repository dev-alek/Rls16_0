block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-zps-6.p $
$Archive: rep/r-zps-6.p $

вызов отчета

Автор: Чернова Светлана Александровна
Дата создания: 03/20/06
Author: Svetlana Chernova
Creation date: 03/20/06

*/
&glob Select-Post  ""and~ can-find(first g#post~
  where ~
 post-stk-line.cli-type = g#post.obj-type and ~
 post-stk-line.cli-code = g#post.obj-code ) = TRUE ""
&glob SSS "&p1 =  {&Select-Post}"                                 /* доп условие */
&glob fr-name "&framename = 'zapas':U"                           /* фрайм */
&glob r-sort "&b3 = temp-t-post-stk-line.gds-name"              /* поле сортировки */
{ rep/r-pst-mn.i {&fr-name}  {&r-sort} {&SSS}}
{ rep/r-zps-dp.i }