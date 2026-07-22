block-level on error undo, throw.
/*

$Revision: 58f87cea8c94, 2624, rls $
$Author: EShklyar $
$Date: Пн окт 19 09:22:02 2020 +0300 $
$Workfile: g-regdoc.p $
$Archive: rep/g-regdoc.p $

Реестр документов расширенный

Автор: Демин Алексей Сергеевич
Дата создания: 11/19/08
Author: Alexey Demin
Creation date: 11/19/08

*/
define input parameter parparentproc as widget-handle no-undo .


define variable vss-revision    as character no-undo init "$Revision: 58f87cea8c94, 2624, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Пн окт 19 09:22:02 2020 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: g-regdoc.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/g-regdoc.p $":U .
define variable vss-description as character no-undo init "Реестр документов расширенный".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/r-page1.i new }

assign
  my-handle = parparentproc
.
run rep/d-report.w
    ( input parparentproc
    , input 'rep/e-regdoc.w'
    , input 'Реестр документов расширенный':U
    , input 4
    , input '{&g-all},{&g-grp},{&g-prod},{&g-choice},{&g-one},{&g-grp-prod}':U
    , input '{&o-firm},{&o-currency},{&o-choice},{&o-all}'
    , input ''
    , input '{&v-rubl},{&v-base}'
    , input 'all,{&Show-cost},{&Show-crsa},{&Show-sale},{&Excel-yes}'
    , input no
    ).