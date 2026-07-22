block-level on error undo, throw.
define input  parameter parparentproc  as widget-handle no-undo.
define input  parameter p-recid  as recid no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: show-ord.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/show-ord.p $":U .
define variable vss-description as character no-undo init "Ïðîñìîòð çàêàçîâ".
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
define   shared variable g#auto as logical no-undo.
define   shared variable g#news as logical no-undo.
define   shared variable g#oxml as logical no-undo.
define   shared variable g#esys as logical no-undo.
define   shared variable g#news-source-db as integer no-undo.
define   shared variable g#esys-source-esys as integer no-undo.
define   shared variable g#db-num as integer   no-undo .
define   shared variable g#userid as character no-undo .
define   shared variable g#passwd as character no-undo .
define buffer buf_clients for ub.clients.
define new shared buffer shar-buf_ord-doc for ub.ord-doc.
define new shared buffer buf-or_ord-doc for ub.ord-doc.
define new shared buffer buf-oo_ord-doc for ub.ord-doc.
define new shared buffer buf-po_ord-doc for ub.ord-doc.
define new shared variable br-handle as handle no-undo.
define new SHARED VARIABLE next-prev as logical   no-undo .
find first  shar-buf_ord-doc no-lock where recid (shar-buf_ord-doc) = p-recid no-error .
if error-status :error then return .
define variable rr as recid no-undo .
rr = recid (shar-buf_ord-doc) .
case shar-buf_ord-doc.doc-type:
when 'ÏÎ':U
then do:
  run cus/ord-pou.w ( input  PARPARENTPROC , input-output rr  , input 'ÏÐÎÑÌÎÒÐ':U ) no-error .
end.
when 'ÎÎ':U
then do:
  run cus/ord-oou.w (
    input parParentProc ,
    input 'ÏÐÎÑÌÎÒÐ':U ,
    input-output rr  ,
    input-output br-handle ,
    input-output next-prev )
    .
end.
when 'ÎÐ':U
then do:
  run cus/ord-oru.w (
    input parParentProc ,
    input-output rr ,
    input 'ÏÐÎÑÌÎÒÐ':U ,
    input-output br-handle ,
    input-output next-prev )
    .
end.
otherwise do:
  define variable bf-handle as handle no-undo .
  run cus/lkp-zakz.w
  ( input PARPARENTPROC ,
    input-output  br-handle,
    input-output  bf-handle,
    input-output next-prev
  ) no-error.
end.
end case.
if error-status :error then message
    vss-workfile vss-revision vss-description skip
    error-status :get-message (1) skip
    return-value
    view-as alert-box error .
