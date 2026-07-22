block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: g-inv-rn.p $
$Archive: rep/g-inv-rn.p $

Описание файла

Автор: Сливенко Сергей Андреевич
Дата создания: 09/14/11
Author: Sergey Slivenko
Creation date: 09/14/11

*/

define input parameter parparentproc as widget-handle no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: g-inv-rn.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/g-inv-rn.p $":U .
define variable vss-description as character no-undo init "Сличительная ведомость по результатам инвентаризации (Роснефть)".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/library.i }
{ gbl/getcntxt.i def }
{ cmp/r-page1.i new }

define variable glog as logical no-undo .
{ gbl/getcntxt.i get }
{ gbl/chk-actg.i
v-cntxt-db-num
v-cntxt-userid
{&action-head-code-main}
'actn_prod-monthly_print':U
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
if NOT gLog then do:
  return.
end.
 run rep/d-report.w (            input parparentproc
                            ,input 'rep/e-inv-RN.w'
                            ,input ('Сличительная ведомость по результатам инвентаризации ТНП')
                            ,input 8
                            ,input  "{&g-all},{&g-grp},{&g-prod},{&g-choice},{&g-one}":U
                            ,input "*"
                            ,input ""
                            ,input ""
                            ,input "shop,{&send-check},{&Excel-yes}"
                    /*        ,input "shop,{&Excel-yes}"    */
                            ,input no).