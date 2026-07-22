block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: g-kfreba.p $
$Archive: rep/g-kfreba.p $

Запуск отчета Реализация и остатки (Кедр)

Автор: Хныкин Павел Андреевич
Дата создания: 05/13/08
Author: Pavel Khnykin
Creation date: 05/13/08

*/
define input parameter p-parent-proc as widget-handle no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: g-kfreba.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/g-kfreba.p $":U .
define variable vss-description as character no-undo init "Запуск отчета Реализация и остатки (Кедр)".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i    }
{ cmp/r-page1.i new }

run rep/d-report.w
    ( input p-parent-proc
    , input 'rep/m-kfreba.p'
    , input "Реализация и остатки (Кедр)":U
    , input 0
    , input ""
    , input "{&o-currency}"
    , input ""
    , input ""
    , input "all,{&send-check},{&Excel-yes}"
    , input yes
    ).