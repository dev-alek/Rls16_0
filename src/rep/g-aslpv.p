block-level on error undo, throw.
/*

$Revision: 3c5534ed78f6, 202, rls $
$Author: AShutilov $
$Date: Mon Jun 08 18:12:53 2015 +0400 $
$Workfile: g-asLPV.p $
$Archive: rep/g-asLPV.p $

Отчет об отчислениях в ЛПВ - запуск

Автор: Шутилов Арнольд Валерьевич
Дата создания: 23/05/15
Author: Shutilov Arnold
Creation date: 23/05/15

*/

/* ***************************  Definitions  ************************** */
define input parameter parparentproc as widget-handle no-undo .

define variable vss-revision    as character no-undo init "$Revision: 3c5534ed78f6, 202, rls $":U .
define variable vss-author      as character no-undo init "$Author: AShutilov $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jun 08 18:12:53 2015 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: g-asLPV.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/g-asLPV.p $":U .
define variable vss-description as character no-undo init "Отчет об отчислениях в ЛПВ - запуск".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }


/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
run rep/d-report.w (
                input parParentProc,                                /* 1. */
                input "rep/r-asLPV.p " + string(parParentProc) , /* 2. Вызываем файл отчёта + Параметр к нему. (Вообще, если работаем с 1 закладкой, то сразу r-отчёт, если есть 2 закладки, то вызов 2-й закладки) */
                input "Отчет об отчислениях в ЛПВ",                 /* 3. Наименование шапки окна параметров rep/s-object.w (которое вызовется из d-report.w */
                input 4,                                            /* 4. Даты и Смены (одна дата, период - две даты, одна смена и две даты и т.д. (период отчёта) */
                input "",                                           /* 5. Выбор Товаров */
                input "*",                                          /* 6. Выбор Объектов ("*" - показать все элементы блока) */
                input "",                                           /* 7. В Ценах (1-Продажная; 2-Учётная; 3-Документа) */
                input "",                                           /* 8. Блок Валюты (1-рубли; 2-Базовая; 3-рубли и валюта) */
                input "1,all,{&Excel-yes},x-SelectObject=obj-firm",                           /* 9. Типы Объектов, участвующих в выборе параметров (All-по всем; Stok-склады; магазины; ...-могут добавляться новые параметры!) */
                input yes).                                         /* 10.Используем одну закладку */