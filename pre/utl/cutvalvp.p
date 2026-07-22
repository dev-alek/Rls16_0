block-level on error undo, throw.
define input  parameter p-cut-date as date no-undo .
define output parameter p-ok as logical   no-undo .
define output parameter p-mess as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: cutvalvp.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/cutvalvp.p $":U .
define variable vss-description as character no-undo init "ѕроверка наличи€ документов внутреннего перемещени ".
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
define buffer pri_trn-doc for ub.trn-doc  .
define buffer ras_trn-doc for ub.trn-doc  .
define buffer buf_clients for ub.clients  .
p-ok = true .
for each buf_clients no-lock where buf_clients.host-code > 0 :
for each ras_trn-doc no-lock where
         ras_trn-doc.obj-type     = buf_clients.obj-type and
         ras_trn-doc.obj-code     = buf_clients.obj-code and
         ras_trn-doc.status_      = 'факт':U and
         ras_trn-doc.ext-doc-type = 'ev':U and
         ras_trn-doc.fact-date   >= p-cut-date
        :
    find first pri_trn-doc no-lock where
        pri_trn-doc.out-code = ras_trn-doc.doc-code and
        pri_trn-doc.status_  = 'факт':U no-error .
    if not available pri_trn-doc then do:
        p-ok = false .
        p-mess = substitute("≈сть незакрытые внутренние приходы по документу &1 до даты обрезани€ " , ras_trn-doc.doc-code ) .
        leave.
    end.
end.
for each ras_trn-doc no-lock where
         ras_trn-doc.obj-type     = buf_clients.obj-type and
         ras_trn-doc.obj-code     = buf_clients.obj-code and
         ras_trn-doc.status_      = 'факт':U and
         ras_trn-doc.fact-date   >= p-cut-date and
         ras_trn-doc.ext-doc-type = 'ee':U and
         ras_trn-doc.hold-obj-code > 0
        :
    find first pri_trn-doc no-lock where
        pri_trn-doc.out-code = ras_trn-doc.doc-code and
        pri_trn-doc.status_  = 'факт':U no-error .
    if not available pri_trn-doc then do:
        p-ok = false .
        p-mess = substitute("≈сть незакрытые ћ‘ приходы по документу &1 до даты обрезани€ " , ras_trn-doc.doc-code ) .
        leave.
    end.
end.
end.
