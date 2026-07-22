using System.Runtime.InteropServices.ComTypes.IMoniker from assembly.
block-level on error undo, throw.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define input  parameter iParparentproc as handle    no-undo.
define input  parameter iCodeTrg       as class ibs.th.ref.code.code_trg no-undo.
define input  parameter iMode          as character no-undo.
define input  parameter IBuffer        as handle    no-undo.
define output parameter OSave          as logical   no-undo.
define variable vss-revision    as character no-undo init "$Revision:$":U .
define variable vss-author      as character no-undo init "$Author:$":U .
define variable vss-date        as character no-undo init "$Date:$":U .
define variable vss-workfile    as character no-undo init "$Workfile:$":U .
define variable vss-archive     as character no-undo init "$Archive:$":U .
define variable vss-description as character no-undo init "".
procedure vss-get-info :
  define output parameter p-vss-revision    like vss-revision    no-undo .
  define output parameter p-vss-author      like vss-author      no-undo .
  define output parameter p-vss-date        like vss-date        no-undo .
  define output parameter p-vss-workfile    like vss-workfile    no-undo .
  define output parameter p-vss-archive     like vss-archive     no-undo .
  define output parameter p-vss-description like vss-description no-undo .
  assign
    p-vss-revision    = vss-revision
    p-vss-author      = vss-author
    p-vss-date        = vss-date
    p-vss-workfile    = vss-workfile
    p-vss-archive     = vss-archive
    p-vss-description = vss-description
  .
end procedure.
procedure vss-get-parameters :
  define output parameter p-vss-parameters as character no-undo .
end procedure.
define new global shared variable g#vssrevis-logger as handle    no-undo .
define variable v-vssrevis-logevent                 as logical   no-undo init false .
define variable v-vssrevis-logger                   as handle    no-undo .
procedure vss-logevent :
  define input  parameter p-extra-paramters as character no-undo .
  define variable v-vssrevis-parameters as character no-undo .
  do
  on error undo, return error return-value
  :
    if  valid-handle(v-vssrevis-logger)
    and v-vssrevis-logger :get-signature("logevent") <> ""
    then do:
      run vss-get-parameters in this-procedure
        (output v-vssrevis-parameters
        ).
      run logevent in v-vssrevis-logger
        (input vss-workfile
        ,input vss-revision
        ,input v-vssrevis-parameters
        ,input p-extra-paramters
        ).
    end.
  end.
end procedure.
assign
  v-vssrevis-logger = g#vssrevis-logger
.
if  valid-handle(v-vssrevis-logger)
and v-vssrevis-logger :get-signature("logevent") <> ""
then do:
  assign
    v-vssrevis-logevent = true
  .
  run vss-logevent in this-procedure (input vss-description) .
end.
define temp-table tt-code-frm like code
  field Frecid as int64 init ?.
define variable mSDedit as class   ibs.th.ref.code.SDedit_ no-undo.
define variable v-ip  as character no-undo .
if iMode = 'ДОБАВЛЕНИЕ':U then do:
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
      if num-entries(ub.cash-desk.addr-path, chr(4)) > 1 then v-ip = entry(2,ub.cash-desk.addr-path,chr(4)) .
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
