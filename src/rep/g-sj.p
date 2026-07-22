block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: g-sj.p $
$Archive: rep/g-sj.p $

Журнал продаж - запуск

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/07/05
Author: Bakhtadze Natalya
Creation date: 09/07/05

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-call-point as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: g-sj.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/g-sj.p $":U .
define variable vss-description as character no-undo init "Журнал продаж - запуск".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/r-page0.i new }
{ gbl/getcntxt.i def }

define NEW SHARED variable cas-shft as logical no-undo init no.
define variable conf-attr as char no-undo.                  /* для чтения параметра конфигурации */
define variable conf-par as char no-undo.                  /* для чтения параметра конфигурации */
define variable par-type as char no-undo.
/*точка вызова отчета для его различных модификаций*/
def new shared var call-point as char no-undo .
define variable glog as logical no-undo .
define variable v-base-code like ub.sysconf.base-code no-undo .
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

define variable v-curr-r-b as character no-undo .
{ gbl/curr-r-b.i
  v-curr-r-b
}
call-point = p-call-point.
{ gbl/basecode.i v-cntxt-host-code-obj v-base-code }
run rep/d-report.w (
                     input parparentproc
                    ,input 'rep/e-sj.w'
                    ,input 'Журнал продаж'
                    ,input (if cas-shft then 5  else 6)
                    ,input "{&g-all},{&g-prod},{&g-choice}"
                    ,input "*"
                    ,input ""
                    ,input (if v-curr-r-b = {&r-b-base}
                            then (if v-base-code = 0 then "{&v-base}" else "{&v-base},{&v-all}")
                            else "":U)
                    ,input "shop,{&send-check},{&Print-List-Hist-yes}"
                    ,input no).