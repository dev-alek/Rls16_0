block-level on error undo, throw.
define input  parameter p-doc-code as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: u-status.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/u-status.p $":U .
define variable vss-description as character no-undo init "Статусы документов".
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
find first ub.trn-doc no-lock where
           ub.trn-doc.doc-code = p-doc-code and
           ub.trn-doc.status_ = 'факт':U no-error .
if not available ub.trn-doc then do:
   message "Нет документа закрытого на факт" p-doc-code view-as alert-box information .
   return.
end.
for each ub.parts exclusive-lock where
         ub.parts.out-code = ub.trn-doc.doc-code and
         ub.parts.obj-type = ub.trn-doc.obj-type and
         ub.parts.obj-code = ub.trn-doc.obj-code and
         ub.parts.status_   = false :
   ub.parts.status_   = true  .
end.
for each ub.doc-line exclusive-lock where
         ub.doc-line.doc-code = ub.trn-doc.doc-code and
         ub.doc-line.status_  <> ub.trn-doc.status_ :
   ub.doc-line.status_   = ub.trn-doc.status_  .
end.
message 'Все по документу' p-doc-code view-as alert-box information  .
