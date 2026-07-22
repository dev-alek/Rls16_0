block-level on error undo, throw.
 /*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: g-mattov.p $
$Archive: rep/g-mattov.p $

Представленность матрицы товаров на объекте- запуск

Автор: Демин Алексей Сергеевич
Дата создания: 09/03/07
Author: Alexey Demin
Creation date: 09/03/07

*/

define input parameter parparentproc as widget-handle no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: g-mattov.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/g-mattov.p $":U .
define variable vss-description as character no-undo init "Представленность матрицы товаров на объекте - запуск".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i new }

run rep/d-report.w (
                  input parparentproc
                  ,input 'rep/e-mattov.w'
                  ,input ('Представленность матрицы товаров на объекте')
                  ,input 0  /*param-date*/
                  ,input "*" /*param-goods*/
                  ,input ""  /*param-obj*/
                  ,input ""  /*param-pay*/
                  ,input ""  /*param-pay-hide*/
                  ,input ""
                  ,input no).

