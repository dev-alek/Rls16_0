block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: g-hazkrt.p $
$Archive: rep/g-hazkrt.p $

Отчет "ПочасоваЯ реализация на АЗК"

Автор: Хныкин Павел Андреевич
Дата создания: 07/04/07
Author: Pavel Khnykin
Creation date: 07/04/07

*/

define input parameter parparentproc as widget-handle no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: g-hazkrt.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/g-hazkrt.p $":U .
define variable vss-description as character no-undo init "Отчет ПочасоваЯ реализация на АЗК".
{ cmp/vssrevis.i      }
{ cmp/str-glbl.i      }
{ cmp/r-page1.i new   }
{ gbl/getcntxt.i def  }


define variable v-object-select as character no-undo .
{ gbl/getcntxt.i get }
assign
  my-handle     = parparentproc
.
if v-cntxt-db-num = 0 then do:
  assign
    v-object-select = "{&o-currency},{&o-choice},{&o-all}"
  .
end.
else do:
  assign
    v-object-select = "{&o-currency}"
  .
end.

run rep/d-report.w
    ( input parparentproc
    , input 'rep/e-hazkrt.w'
    , input "Отчет почасовая реализация на АЗК":U
    , input 0
    , input ""
    , input v-object-select
    , input ""
    , input ""
    , input "all,{&Excel-yes}"
    , input no
    ).