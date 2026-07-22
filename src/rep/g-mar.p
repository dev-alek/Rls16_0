block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: g-mar.p $
$Archive: rep/g-mar.p $

Марочный отчет на самом деле это журнал продаж

Автор: Чернова Светлана Александровна
Дата создания: 12/26/03
Author: Svetlana Chernova
Creation date: 12/26/03

*/

define input  parameter parParentProc  as widget-handle no-undo.
{ cmp/str-glbl.i     }
{ cmp/r-page1.i  new }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }

define variable g#log as logical   no-undo .
define NEW SHARED variable cas-shft as logical no-undo init no.
define variable conf-attr as char no-undo.                  /* для чтения параметра конфигурации */
define variable conf-par as char no-undo.                  /* для чтения параметра конфигурации */
define variable par-type as char no-undo.
/*точка вызова отчета для его различных модификаций*/
define new shared var call-point as char no-undo init "".
define variable v-curr-r-b as character no-undo .
define variable base-code as integer   no-undo .
{ gbl/basecode.i v-cntxt-host-code-obj base-code }
{ gbl/curr-r-b.i v-curr-r-b }
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
  g#log
}
if not g#log then return.

/*найдем параметр - использовать смены на кассе или нет*/
{ gbl/cas-shft.i v-cntxt-obj-type v-cntxt-obj-code cas-shft }

run rep/d-report.w (
   input parParentProc
  ,input 'rep/e-sj.w'
  ,input 'Марочный отчет'
  ,input (if cas-shft then 5 else 6)
  ,input "{&g-all},{&g-prod}"
  ,input "*"
  ,input ""
  ,input (if v-curr-r-b = {&r-b-base}
        then (if base-code = 0 then "{&v-base}" else "{&v-base},{&v-all}")
        else "":U)
  ,input "shop,{&send-check},{&Print-List-Hist-yes}"
  ,input no).