block-level on error undo, throw.
 /*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: g-mar1.p $
$Archive: cus/g-mar1.p $

Дни продажи товара - отчет для Марии - запуск

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/14/04
Author: Bakhtadze Natalya
Creation date: 04/14/04

*/

define input parameter parparentproc as widget-handle no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: g-mar1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/g-mar1.p $":U .
define variable vss-description as character no-undo init "Дни продажи товара - отчет для Марии:запуск".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page0.i new }


run rep/d-report.w (
                            input parparentproc
                            ,input 'cus/e-mar1.w'
                            ,input ('Дни продажи товара')
                            ,input 2  /* с по*/
                            ,input "*"  /*все варианты выбора товаров*/
                            ,input "*"  /*все варианты выбора объектов*/
                            ,input ""   /*тип цен не показывать*/
                            ,input ""   /*тип валют не показывать*/
                            ,input "all,{&Excel-yes}"   /*все типы объектов*/
                            ,input no).