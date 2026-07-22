block-level on error undo, throw.
/*

$Revision: da9d879638c6, 176, rls $
$Author: AShutilov $
$Date: Fri Apr 10 13:11:52 2015 +0400 $
$Workfile: g-ptrlch.p $
$Archive: rep/g-ptrlch.p $

Технологический отчет по ТРК

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/16/05
Author: Bakhtadze Natalya
Creation date: 10/16/05

*/

define input  parameter parparentproc as widget-handle no-undo.
define input parameter custom-par as char no-undo.

define variable vss-revision    as character no-undo init "$Revision: da9d879638c6, 176, rls $":U .
define variable vss-author      as character no-undo init "$Author: AShutilov $":U .
define variable vss-date        as character no-undo init "$Date: Fri Apr 10 13:11:52 2015 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: g-ptrlch.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/g-ptrlch.p $":U .
define variable vss-description as character no-undo init "Технологический отчет по ТРК".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/r-page0.i new }
{ gbl/getcntxt.i def }

define variable glog as logical   no-undo .
define variable conf-attr as character no-undo .
define variable conf-par as character no-undo .
define variable par-type as character no-undo .
define variable cas-shft as logical   no-undo .

{ gbl/getcntxt.i get }
{ gbl/chk-actg.i
v-cntxt-db-num
v-cntxt-userid
{&action-head-code-main}
'actn_cur-obj-proceeds_print':U
{&cntxt-firm}
v-cntxt-host-code-obj
'':U
0
0
0
0
true
glog
}
if not glog then return.

custom-par = "shop,{&send-check},{&Excel-yes}" + {&comma-char} +
             custom-par.


run rep/d-report.w (
                     input parparentproc
/*                    ,input 'rep/r-ptrlch.p'*/
                    ,input 'rep/e-ptrlch.w'
                    ,input 'Технологический отчет по ТРК'
                    ,input 4
                    ,input '':U
                    ,input "*"
                    ,input ""
                    ,input '':U
                    ,input custom-par
                    ,input no).