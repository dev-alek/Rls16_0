block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-option as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: staffr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/staffr.p $":U .
define variable vss-description as character no-undo init "Толкач для вызова справочника персонала из m_e_n_u.txt и других мест".
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
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define variable v-role as character no-undo .
define variable v-db-num as integer no-undo .
define variable v-current-db-num as integer no-undo .
define variable v-ri-list as character no-undo .
define variable v-bttns as character no-undo .
define buffer buf_db for ub.db.
define buffer buf2_db for ub.db.
if p-option = 'allcashiers':U
or p-option = 'curdbcashiers':u then do:
  v-role = 'C':U.
end.
if p-option = 'allsellers':U
or p-option = 'curdbsellers':u then do:
  v-role = 'S':U.
end.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output v-current-db-num
  )  .
find buf_db no-lock
  where buf_db.db-num = v-current-db-num
   .
if p-option = 'allcashiers':U
or p-option = 'allsellers':U then do:
  v-db-num = ?.
end.
if p-option = 'curdbcashiers':U
or p-option = 'curdbsellers':U then do:
  v-db-num = v-current-db-num.
end.
if buf_db.add-clients
or not (can-find(first ub.db no-lock where ub.db.db-num > 0)) then do:
  v-bttns = 'b-add'.
end.
else do:
  if buf_db.db-num = 0
  and buf_db.add-clients = no then do:
    for each buf2_db no-lock:
      if buf2_db.add-clients then do:
        leave.
      end.
    end.
    if not available buf2_db then do:
      v-bttns = 'b-add'.
    end.
  end.
end.
    run ref/staffs.w (
                      input parparentproc
                , input v-bttns
                    , input v-role
                    , input v-db-num
                    , input 0
                , output v-ri-list) no-error .
