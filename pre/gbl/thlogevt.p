block-level on error undo, throw.
define input  parameter p-server-name      as character no-undo .
define input  parameter p-vss-workfile     as character no-undo .
define input  parameter p-vss-revision     as character no-undo .
define input  parameter p-vss-parameters   as character no-undo .
define input  parameter p-extra-parameters as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: thlogevt.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/thlogevt.p $":U .
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
do
on error undo, return error return-value
:
  define variable v-vss-event-suffix as character no-undo .
  if p-vss-workfile = ? then do:
    assign
      p-vss-workfile = '?'
    .
  end.
  if p-vss-revision = ? then do:
    assign
      p-vss-revision = '?'
    .
  end.
  if p-vss-parameters = ? then do:
    assign
      p-vss-parameters = '?'
    .
  end.
  if p-extra-parameters = ? then do:
    assign
      p-extra-parameters = '?'
    .
  end.
  if p-vss-parameters <> "" then do:
    assign
      v-vss-event-suffix = '_PARAM':U
    .
  end.
  if p-extra-parameters <> "" then do:
    assign
      v-vss-event-suffix = v-vss-event-suffix + '_EXTRA':U
    .
  end.
  if p-extra-parameters <> "" then do:
    assign
      p-vss-parameters = p-vss-parameters
                       + (if p-vss-parameters <> "" then "|" else "")
                       + p-extra-parameters
    .
  end.
  if num-entries(p-vss-workfile, " ") > 1 then do:
    assign
      p-vss-workfile = entry(2, p-vss-workfile, " ")
    .
  end.
  if num-entries(p-vss-revision, " ") > 1 then do:
    assign
      p-vss-revision = entry(2, p-vss-revision, " ")
    .
  end.
  run gbl/logevent.p
    (input p-server-name
    ,input 'TH15.0_':U + lc(p-vss-workfile) + '_':U + p-vss-revision + v-vss-event-suffix
    ,input p-vss-parameters
    ) .
end.
