block-level on error undo, throw.

/*

$Revision: 11f5f5a9eb60, 681, rls $
$Author: EShklyar $
$Date: Mon Jun 27 11:01:10 2016 +0400 $
$Workfile: g-alc-rees.p $
$Archive: rep/g-alc-rees.p $

Реестр документов ЕГАИС

Автор: Шаланин Сергей
Дата создания: 11/04/2016
Author: Shalanin Sergey
Creation date: 11/04/2016



*/
define input parameter parparentproc as widget-handle no-undo .

define variable vss-revision    as character no-undo init "$Revision: 11f5f5a9eb60, 681, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jun 27 11:01:10 2016 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: g-alc-rees.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/g-alc-rees.p $":U .
define variable vss-description as character no-undo init "Отчет по бонусам".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/r-page1.i new }

run rep/d-report.w (
                input parParentProc,
                input "rep/alc-rees.w " , /* Вызываем файл отчёта + Параметр к нему. (Вообще, если работаем с 1 закладкой, то сразу, если есть 2 закладки, то вызов при переходе с 1-й на 2-ю закладку) */
                input "Реестр документов ЕГАИС",    /* Наименование окна rep/s-object.w (которое вызовется из d-report.w */
                input 2,                                            /* Используется две даты (задание периода отчёта) */
                input "",
                input "{&o-currency},{&o-choice}",     
                input "",                                           /* Форма для выбора товара - здесь не используется. */
                input "",
                input "all,{&Excel-yes}" ,                         /* На всякий случай вывод галочки для excel (было в образце) */
                  input no).