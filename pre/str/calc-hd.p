block-level on error undo, throw.
define input parameter v-doc-code like ub.trn-doc.doc-code no-undo .
define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: calc-hd.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: str/calc-hd.p $":U .
define variable vss-description as character no-undo initial "Пересчет шапки документа в учетных ценах, расчет величины автоматической переоценки":U .
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
    assign
      p-vss-parameters = substitute('&1':U,v-doc-code)
    .
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
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
define variable v-total-doc-line_tot-ov    like ub.trn-doc.tot-ov    no-undo.
define variable v-total-doc-line_fact-rubl like ub.trn-doc.fact-rubl no-undo.
define variable v-total-doc-line_fact-base like ub.trn-doc.fact-base no-undo.
define variable v-total-doc-line_fact-qnty like ub.trn-doc.fact-qnty no-undo.
define variable v-total-doc-line_doc-qnty  like ub.trn-doc.doc-qnty  no-undo.
define variable v-total-doc-line_cli-qnty  like ub.trn-doc.cli-qnty  no-undo.
define variable v-total-trn-doc_tot-ov     like ub.trn-doc.tot-ov    no-undo.
define variable v-total-trn-doc_fact-rubl  like ub.trn-doc.fact-rubl no-undo.
define variable v-total-trn-doc_fact-base  like ub.trn-doc.fact-base no-undo.
define variable v-total-trn-doc_fact-qnty  like ub.trn-doc.fact-qnty no-undo.
define variable v-total-trn-doc_doc-qnty   like ub.trn-doc.doc-qnty  no-undo.
define variable v-total-trn-doc_cli-qnty   like ub.trn-doc.cli-qnty  no-undo.
define buffer bf_goods for ub.goods.
do on error undo, return error return-value :
  assign
    v-total-trn-doc_tot-ov    = 0
    v-total-trn-doc_fact-rubl = 0
    v-total-trn-doc_fact-base = 0
    v-total-trn-doc_fact-qnty = 0
    v-total-trn-doc_doc-qnty  = 0
    v-total-trn-doc_cli-qnty  = 0
  .
  find first ub.trn-doc exclusive-lock where
             ub.trn-doc.doc-code = v-doc-code.
  if ub.trn-doc.doc-type <> 'инв':U then do:
    assign
      ub.trn-doc.doc-qnty  = 0.
  end.
  assign
    ub.trn-doc.fact-qnty = 0
    ub.trn-doc.cli-qnty  = 0
    ub.trn-doc.fact-base = 0
    ub.trn-doc.fact-rubl = 0
    ub.trn-doc.tot-ov    = 0
  .
  for each ub.doc-line no-lock where
           ub.doc-line.doc-code = ub.trn-doc.doc-code
  on error undo, return error return-value :
    find first bf_goods no-lock where
               bf_goods.artic     = ub.doc-line.artic     and
               bf_goods.prod-type = ub.doc-line.prod-type and
               bf_goods.prod-code = ub.doc-line.prod-code no-error.
    if not available bf_goods then do:
      return error substitute( "Не найден товар &1 &2 &3."
                             , ub.doc-line.artic
                             , ub.doc-line.prod-type
                             , ub.doc-line.prod-code ).
    end.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_acc-cost in g#lib-trn
(
 input  ub.doc-line.obj-type
,input  ub.doc-line.obj-code
,input  ub.doc-line.doc-code
,input  ub.doc-line.artic
,input  ub.doc-line.prod-type
,input  ub.doc-line.prod-code
,input  ub.doc-line.cli-qnty
,input  ub.doc-line.doc-qnty
,input  ub.doc-line.fact-qnty
,input  ub.doc-line.price-base
,input  ub.doc-line.price-rubl
,input  ''
,output v-total-doc-line_tot-ov
,output v-total-doc-line_fact-rubl
,output v-total-doc-line_fact-base
,output v-total-doc-line_fact-qnty
,output v-total-doc-line_doc-qnty
,output v-total-doc-line_cli-qnty
)
no-error.
     if error-status :error then do:
       return error return-value.
     end.
     assign
       v-total-trn-doc_tot-ov    = v-total-trn-doc_tot-ov    + v-total-doc-line_tot-ov
       v-total-trn-doc_fact-rubl = v-total-trn-doc_fact-rubl + v-total-doc-line_fact-rubl
       v-total-trn-doc_fact-base = v-total-trn-doc_fact-base + v-total-doc-line_fact-base
       v-total-trn-doc_fact-qnty = v-total-trn-doc_fact-qnty + v-total-doc-line_fact-qnty
       v-total-trn-doc_doc-qnty  = v-total-trn-doc_doc-qnty  + v-total-doc-line_doc-qnty
       v-total-trn-doc_cli-qnty  = v-total-trn-doc_cli-qnty  + v-total-doc-line_cli-qnty
     .
  end.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_ass-cost in g#lib-trn
(
 input recid(ub.trn-doc)
,input v-total-trn-doc_tot-ov
,input v-total-trn-doc_fact-rubl
,input v-total-trn-doc_fact-base
,input v-total-trn-doc_fact-qnty
,input v-total-trn-doc_doc-qnty
,input v-total-trn-doc_cli-qnty
,input 0
,input 0
,input 0
,input 0
,input 0
,input 0
)
no-error.
  if error-status :error then do:
    undo, return error return-value.
  end.
end.
