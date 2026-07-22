block-level on error undo, throw.
using ibs.th.str.ptrl.forms.* from propath.
define  input parameter parparentproc as handle    no-undo.
define  input parameter pardoc-mode   as character no-undo.
define output parameter parrvs-rec    as recid     no-undo.
define variable vss-revision    as character no-undo initial "$Revision$":U.
define variable vss-author      as character no-undo initial "$Author$":U.
define variable vss-date        as character no-undo initial "$Date$":U.
define variable vss-workfile    as character no-undo initial "$Workfile$":U.
define variable vss-archive     as character no-undo initial "$Archive$":U.
define variable vss-description as character no-undo initial "Добавление документа проверки корректности работы АСИ в резервуаре":U.
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
define variable vForm as ibs.th.str.ptrl.forms.TestAsiAdd no-undo .
define variable v-type as character no-undo init "" .
define variable v-full as logical no-undo .
vForm = new ibs.th.str.ptrl.forms.TestAsiAdd() .
wait-for vForm:ShowDialog() .
v-type = vForm:pType .
v-full = vForm:pFull .
vForm:Dispose() .
if not v-type > ""
then return .
run str/test-asi-doc.w
 ( input        parparentproc
  ,input        pardoc-mode
  ,input        v-type
  ,input        v-full
  ,input-output parrvs-rec
 ) no-error.
if error-status :error then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при создании документа проверки корректности работы АСИ в резервуаре." skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  return .
end.
