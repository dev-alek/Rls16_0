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
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
 define shared temp-table tmprecid
    field Frecid as recid init ?
    field fnum as character
    field fTable as character
 index num  fnum Frecid
 index itable is primary unique fTable Frecid
 .
define variable fSelect as logical no-undo format "*/" column-label "".
function isSelect return logical
    (iBuffer as handle  ):
    define buffer tmprecid for tmprecid.
    if iBuffer:available
    then
       find first tmprecid where tmprecid.fTable = iBuffer:TABLE
                             and tmprecid.Frecid = iBuffer:recid
       no-lock no-error.
    return available tmprecid.
 end.
function setSelect return logical
    (iBuffer as handle  ):
    define buffer tmprecid for tmprecid.
    if iBuffer:available
    then do:
       find first tmprecid where tmprecid.fTable = iBuffer:TABLE
                             and tmprecid.Frecid = iBuffer:recid
       no-lock no-error.
       if available tmprecid
       then
          delete tmprecid.
       else do:
          create tmprecid.
          assign
             tmprecid.fTable = iBuffer:TABLE
             tmprecid.Frecid = iBuffer:recid
          .
       end.
    end.
    return available tmprecid.
 end.
 procedure rid-keep :
     run gbl/rid-keep.p (input table tmprecid) no-error.
 end.
 procedure rid-rest :
      run gbl/rid-rest.p (output table tmprecid) no-error.
 end.
define output  parameter table    for tmprecid.
