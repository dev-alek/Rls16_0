block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: g-petsal.p $
$Archive: rep/g-petsal.p $

Расход нефтепродуктов через ТРК - запуск

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/07/05
Author: Bakhtadze Natalya
Creation date: 09/07/05

*/

define input parameter parparentproc as widget-handle no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: g-petsal.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/g-petsal.p $":U .
define variable vss-description as character no-undo init "Расход нефтепродуктов через ТРК - запуск".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/r-page0.i new }
{ gbl/getcntxt.i def }
define NEW SHARED variable cas-shft as logical no-undo init no.
define variable conf-attr as char no-undo.                  /* для чтения параметра конфигурации */
define variable conf-par as char no-undo.                  /* для чтения параметра конфигурации */
define variable par-type as char no-undo.
define variable glog as logical no-undo .
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

/*найдем параметр - использовать смены на кассе или нет*/
{ gbl/cas-shft.i  v-cntxt-obj-type v-cntxt-obj-code cas-shft }

CASE cas-shft:
  WHEN YES THEN DO:
    run rep/d-report.w (
                        input parparentproc
                        ,input 'rep/e-petsal.w'
                        ,input 'Расход нефтепродуктов через ТРК'
                        ,input 5
                        ,input ""
                        ,input  "*"
                        ,input ""
                        ,input ""
                        ,input "shop"
                        ,input no).
  END.
  WHEN NO THEN DO:
    run rep/d-report.w (
                        input parparentproc
                        ,input 'rep/e-petsal.w'
                        ,input 'Расход нефтепродуктов через ТРК'
                        ,input 6
                        ,input ""
                        ,input  "*"
                        ,input ""
                        ,input ""
                        ,input "shop"
                        ,input no).
  END.
END CASE.