block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: g-gendoc.p $
$Archive: rep/g-gendoc.p $

ОБЩИЕ КОЛИЧЕСТВА И СУММЫ ПО ТОВАРАМ СПИСКА ДОКУМЕНТОВ - запуск

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/13/06
Author: Bakhtadze Natalya
Creation date: 04/13/06

*/

DEFINE INPUT PARAMETER p-objects as integer no-undo.
DEFINE INPUT PARAMETER p-FRAME-TITLE as char no-undo.
define input  parameter parParentProc  as widget-handle no-undo.


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: g-gendoc.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/g-gendoc.p $":U .
define variable vss-description as character no-undo init "ОБЩИЕ КОЛИЧЕСТВА И СУММЫ ПО ТОВАРАМ СПИСКА ДОКУМЕНТОВ - запуск".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/library.i }
{ gbl/getcntxt.i def }
{ cmp/r-page1.i new}

DEFINE NEW SHARED VAR objects as integer no-undo.
DEFINE NEW SHARED VAR FRAME-TITLE as char no-undo.
assign
objects = p-objects
frame-title = p-frame-title
.
define variable  g#Log  as logical   no-undo .
{ gbl/getcntxt.i get }
{ gbl/chk-actg.i
v-cntxt-db-num
v-cntxt-userid
{&action-head-code-main}
'actn_document-reports-cost_print':U
{&cntxt-firm}
v-cntxt-host-code-obj
'':U
0
0
0
0
true
g#log
}

if not g#Log then return "NO".

{ gbl/chk-actg.i
v-cntxt-db-num
v-cntxt-userid
{&action-head-code-main}
'actn_document-reports-sale_print':U
{&cntxt-firm}
v-cntxt-host-code-obj
'':U
0
0
0
0
true
g#log
}

if not g#Log then return "NO".


run rep/d-report.w (
                    input parParentProc
                    ,input 'rep/e-gendoc.w'
                    ,input ('Общие количества и суммы по товарам списка документов')
                    ,input 5
                    ,input "{&g-all},{&g-choice}"
                    ,input if objects < 2 then "*" else "{&o-currency}"
                    ,input ""
                    ,input ""
                    ,input "all"
                    ,input no).