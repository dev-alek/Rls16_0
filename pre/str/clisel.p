block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define input-output parameter p-supp-type like ub.parts.supp-type no-undo .
define input-output parameter p-supp-code like ub.parts.supp-code no-undo .
def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: clisel.p $":U .
def var vss-archive     as character no-undo init "$Archive: str/clisel.p $":U .
def var vss-description as character no-undo init "Выбор клиента".
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
def var ref-list as character no-undo .
define variable v-ref-rec as recid no-undo .
find first clients no-lock
  where clients.obj-type = p-supp-type
    and clients.obj-code = p-supp-code
  no-error .
if available clients then do:
  assign
    v-ref-rec = recid(clients)
  .
end.
run ref/cli-all.w
  ( parparentproc
    , input  "b-sel"
    , ?
    , ?
    , ?
    , v-ref-rec
    , ?
    , ?
  ,output ref-list
  ).
if ref-list <> "" then do:
  v-ref-rec = integer (ref-list).
  find clients no-lock
    where recid (clients) = v-ref-rec
    no-error .
  if available clients then do:
    assign
      p-supp-type = clients.obj-type
      p-supp-code = clients.obj-code
    .
    return .
  end.
end.
return error .
