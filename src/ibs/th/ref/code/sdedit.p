/*
$Revision:$
$Author:$
$Date:$
$Workfile:$
$Archive:$

Автор: Шкляр Елена
Дата создания: 31 июля 2019 г.
Author:  Shklyar Elena
Creation date: 31 июля 2019 г.

*/



using System.Runtime.InteropServices.ComTypes.IMoniker from assembly.
block-level on error undo, throw.
{cmp/str-glbl.i }
{ ibs\th\ref\code\codefrmpar.i }

define variable vss-revision    as character no-undo init "$Revision:$":U .
define variable vss-author      as character no-undo init "$Author:$":U .
define variable vss-date        as character no-undo init "$Date:$":U .
define variable vss-workfile    as character no-undo init "$Workfile:$":U .
define variable vss-archive     as character no-undo init "$Archive:$":U .
define variable vss-description as character no-undo init "".
{ cmp/vssrevis.i }

define temp-table tt-code-frm like code
  field Frecid as int64 init ?. 

define variable mSDedit as class   ibs.th.ref.code.SDedit_ no-undo.
define variable v-ip  as character no-undo .
if iMode = {&add-def} then do:
define variable v-ok    as logical no-undo .
message "Загрузить список касс?"
  view-as alert-box question buttons yes-no update v-ok.
end.  
if v-ok = true then 
do:
  for each ub.cash-desk no-lock where ub.cash-desk.autonomy = 0 and ub.cash-desk.is-del = no:
    find first ub.code where ub.Code.parent = "SpravDevice" and ub.Code.code = string(ub.cash-desk.cash-num) no-error .
    if not available (ub.Code) then do:
      create ub.Code .
      assign
      ub.Code.code = string(ub.cash-desk.cash-num)
      ub.Code.misc9 = string(ub.cash-desk.cash-num)
      ub.Code.parent = "SpravDevice"
      ub.Code.CodeName = "Касса" + " " + string(ub.cash-desk.cash-num)
      .
     end. 
      ub.Code.status_ = 0.
      if num-entries(ub.cash-desk.addr-path, {&delim-par}) > 1 then v-ip = entry(2,ub.cash-desk.addr-path,{&delim-par}) .
      if num-entries (v-ip,":") > 1 then ub.Code.misc1 = entry(1,v-ip,":") + ":" + "8000/hddsmart" . else ub.Code.misc1 = v-ip .  
  
end.  
  mSDedit = new ibs.th.ref.code.SDedit_(iMode).

  OSave = mSDedit:DialogResult = System.Windows.Forms.DialogResult:OK.
end.
else do:
  mSDedit = new ibs.th.ref.code.SDedit_(iMode).
  mSDedit:bindcode:Handle = IBuffer .

  wait-for  mSDedit:ShowDialog() .
  OSave = mSDedit:DialogResult = System.Windows.Forms.DialogResult:OK.
end.
  finally:
    delete object mSDedit.
  end finally. 