block-level on error undo, throw.
/*

$Revision: bad134532210, 3354, test $
$Author: EShklyar $
$Date: 2023/05/03 11:41:39 $
$Workfile: g-benefi.p $
$Archive: rep/g-benefi.p $

Отчет о выручке и Отчет о выручке  с выбором интервалов времени - запуск

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/05/06
Author: Bakhtadze Natalya
Creation date: 04/05/06

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-procedure-name as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: bad134532210, 3354, test $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: 2023/05/03 11:41:39 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: g-benefi.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/g-benefi.p $":U .
define variable vss-description as character no-undo init "".
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
define variable v-base-code like ub.sysconf.host-code no-undo .
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
if p-procedure-name <> 'rep/e-benefi.w'
and p-procedure-name <> 'rep/e-bennew.w' then do:
  message
  "Неверная вызываема процедура" p-procedure-name
  view-as alert-box error .
  return.
end.

/*найдем параметр - использовать смены на кассе или нет*/
{ gbl/cas-shft.i v-cntxt-obj-type v-cntxt-obj-code  cas-shft }

define variable v-curr-r-b as character no-undo .
{ gbl/curr-r-b.i
  v-curr-r-b
}
{ gbl/basecode.i v-cntxt-host-code-obj v-base-code }

run rep/d-report.w (     input parparentproc
                    ,input p-procedure-name
                    ,input 'Отчет о выручке'
                    ,input (if cas-shft then 5 else 6)
                    ,input ""
                    ,input "*"
                    ,input ""
                    ,input (if v-curr-r-b = {&r-b-base}
                            then (if v-base-code = 0
                                  then "{&v-base}"
                                  else "{&v-rubl},{&v-base},{&v-all}")
                            else "":U)
                    ,input "shop,{&send-check}"
                    ,input no).