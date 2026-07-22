block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-bn-2.p $
$Archive: rep/r-bn-2.p $

вызов отчета

Автор: Шальнев Иван Сергеевич
Дата создания: 23/07/10
Author: Shalnev ivan
Creation date: 23/07/10

*/
&glob Select-Post  ""and~ can-find(first g#post~
  where ~
 post-stk-line.cli-type = g#post.obj-type and ~
 post-stk-line.cli-code = g#post.obj-code ) = TRUE ""
&glob SSS "&p1 =  {&Select-Post}"
&glob fr-name "&framename='bonus':U"
&glob r-sort "&b3 = temp-t-post-stk-line.artic"         /* поле сортировки  */
&glob page-object  yes  /*используется в p-run1.i для перевода страниц между объектами */

{ rep/r-pst-mn.i {&fr-name} {&r-sort} {&SSS} yes }
{ rep/r-bn-dp.i cont-num}