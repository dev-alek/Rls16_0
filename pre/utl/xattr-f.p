block-level on error undo, throw.
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
define input parameter iGroupObj-Code   as character   no-undo.
define input parameter iForce-assign as logical no-undo.
find first _file where _file._file-name = iGroupObj-Code no-lock no-error.
if not available _file then return.
find first xGroupObj where xGroupObj.GroupObj-Code = iGroupObj-Code no-lock no-error.
for each _field of _file no-lock:
   find first xattr where xattr.GroupObj-Code = iGroupObj-Code
                      and xattr.xattr-code = _field._field-name
      exclusive-lock no-wait no-error.
   if not available xattr then
      create xattr.
   if new xattr or iForce-assign then
   do:
      assign
         Xattr.GroupObj-Code     = xGroupObj.GroupObj-Code
         Xattr.Xattr-Code     = _field._field-name
         Xattr.Progress-Field = yes
         Xattr.Name           = _field._label
         Xattr.Description    = _field._help
         Xattr.Data-Type      = _field._data-type
         Xattr.Data-Format    = _field._format
         Xattr.Initial        = _field._initial
         Xattr.Mandatory      = _field._mandatory
         Xattr.sign-inherit   = "á"
         Xattr.order          = _field._order
         Xattr.xattr-label    = _field._label
         Xattr.xattr-clabel   = _field._col-label
         Xattr.Accuracy       = _field._decimals
      .
   end.
end.
for each xattr where xattr.GroupObj-Code = iGroupObj-Code
                 and xattr.progress-field
                 and xattr.sign-inherit = "á" exclusive-lock:
   find first _field of _file where xattr.xattr-code = _field._field-name no-lock no-error.
   if not available _field then
   do:
      delete xattr.
   end.
end.
