/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Топливные платежи по видам топлива и продажа топлива по типам оплаты - общая часть

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/07/05
Author: Bakhtadze Natalya
Creation date: 09/07/05

*/


{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/r-page0.i new }
{ gbl/getcntxt.i def }

define NEW SHARED variable cas-shft as logical no-undo init no.
define variable conf-attr as char no-undo.                  /* для чтения параметра конфигурации */
define variable conf-par as char no-undo.                  /* для чтения параметра конфигурации */
define variable par-type as char no-undo.
define variable glog as logical no-undo .
define variable v-base-code like ub.sysconf.base-code no-undo .
define variable v-curr-r-b as character no-undo .
{ gbl/curr-r-b.i
  v-curr-r-b
}
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

if not glog then return "NO".

/*найдем параметр - использовать смены на кассе или нет*/
{ gbl/cas-shft.i v-cntxt-obj-type v-cntxt-obj-code cas-shft }

{ gbl/basecode.i v-cntxt-host-code-obj v-base-code }

if method = "b-code":U then do:
run rep/d-report.w (
                    input parparentproc
                    ,input 'rep/e-toppay_pay.w'
                    ,input 'Продажи топлива по видам оплаты'
                    ,input 4
                    ,input ""
                    ,input "*"
                    ,input ""
                    ,input if v-curr-r-b = {&r-b-base}
                            then (if v-base-code = 0 then "" else "{&v-base},{&v-all}")
                            else "":U
                    ,input "shop" /*было убрано: ,{&send-check}*/
                    ,input no).
end.
else do:                    
run rep/d-report.w (
                    input parparentproc
                    ,input 'rep/e-toppay1.p'
                    ,input 'Топливные платежи по видам топлива'
                    ,input (if cas-shft then 5 else 6)
                    ,input ""
                    ,input "*"
                    ,input ""
                    ,input if v-curr-r-b = {&r-b-base}
                            then (if v-base-code = 0 then "" else "{&v-base},{&v-all}")
                            else "":U
                    ,input "shop" /*было убрано: ,{&send-check}*/
                    ,input yes).
end.
/* $Workfile$ e n d */