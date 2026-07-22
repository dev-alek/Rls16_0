block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: g-wth-mv.p $
$Archive: rep/g-wth-mv.p $

Автор: Гридчина Полина Дмитриевна
Дата создания: 09/09/05
Author: Polina Gridchina
Creation date: 09/09/05

*/

define input  parameter parParentProc  as widget-handle no-undo.

{ cmp/str-glbl.i }
{ cmp/r-page0.i NEW}

run rep/d-report.w (   input parParentProc
                  ,input "rep/e-wth-mv.w"
                  ,input "Движение материальных ценностей на АЗК"
                  ,input 5
                  ,input ""
                  ,input ""
                  ,input ""
                  ,input ""
                  ,input "all"
                  ,input no
              )
    .