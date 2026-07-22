block-level on error undo, throw.
define input parameter parrecdoc-line as recid no-undo.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
define variable varprice-cli                like ub.doc-line.price-rubl no-undo.
define variable varprice-cli-unit-base      like ub.doc-line.price-rubl no-undo.
define variable varprice-road-tax           like ub.doc-line.price-rubl no-undo.
define variable varprice-other-exp          like ub.doc-line.price-rubl no-undo.
define variable varprice-transport-exp      like ub.doc-line.price-rubl no-undo.
define variable varprice-without-abs        like ub.doc-line.price-rubl no-undo.
define variable varprice-slt                like ub.doc-line.price-rubl no-undo.
define variable varprice-no-slt             like ub.doc-line.price-rubl no-undo.
define variable varprice-vat                like ub.doc-line.price-rubl no-undo.
define variable varprice-no-vat-slt         like ub.doc-line.price-rubl no-undo.
define variable varprice-rubl               like ub.doc-line.price-rubl no-undo.
define variable varprice-road-tax-rubl      like ub.doc-line.price-rubl no-undo.
define variable varprice-other-exp-rubl     like ub.doc-line.price-rubl no-undo.
define variable varprice-transport-exp-rubl like ub.doc-line.price-rubl no-undo.
define variable varprice-without-abs-rubl   like ub.doc-line.price-rubl no-undo.
define variable varprice-slt-rubl           like ub.doc-line.price-rubl no-undo.
define variable varprice-no-slt-rubl        like ub.doc-line.price-rubl no-undo.
define variable varprice-vat-rubl           like ub.doc-line.price-rubl no-undo.
define variable varprice-no-vat-slt-rubl    like ub.doc-line.price-rubl no-undo.
define variable varprice-base               like ub.doc-line.price-base no-undo.
define variable varprice-road-tax-base      like ub.doc-line.price-base no-undo.
define variable varprice-other-exp-base     like ub.doc-line.price-base no-undo.
define variable varprice-transport-exp-base like ub.doc-line.price-base no-undo.
define variable varprice-without-abs-base   like ub.doc-line.price-base no-undo.
define variable varprice-slt-base           like ub.doc-line.price-base no-undo.
define variable varprice-no-slt-base        like ub.doc-line.price-base no-undo.
define variable varprice-vat-base           like ub.doc-line.price-base no-undo.
define variable varprice-no-vat-slt-base    like ub.doc-line.price-base no-undo.
define buffer t-doc for trn-doc.
find first doc-line where recid(doc-line) = parrecdoc-line.
find first t-doc where t-doc.doc-code = doc-line.doc-code.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_in-vat in g#lib-trn
  (
   input   t-doc.doc-code
  ,input   t-doc.base-rate
  ,input   t-doc.base-scale
  ,input   t-doc.exch-rate
  ,input   t-doc.exch-scale
  ,input   t-doc.vat-type
  ,input   t-doc.slt-type
  ,input   doc-line.artic
  ,input   doc-line.prod-type
  ,input   doc-line.prod-code
  ,input   doc-line.price-cli
  ,input   doc-line.cli-base-rate
  ,input   doc-line.price-rubl
  ,input   doc-line.vat-pc
  ,input   doc-line.slt-pc
  ,input   doc-line.road-tax
  ,input   doc-line.transport-rubl
  ,input   doc-line.other-rubl
  ,output  varprice-cli
  ,output  varprice-cli-unit-base
  ,output  varprice-road-tax
  ,output  varprice-other-exp
  ,output  varprice-transport-exp
  ,output  varprice-without-abs
  ,output  varprice-slt
  ,output  varprice-no-slt
  ,output  varprice-vat
  ,output  varprice-no-vat-slt
  ,output  varprice-rubl
  ,output  varprice-road-tax-rubl
  ,output  varprice-other-exp-rubl
  ,output  varprice-transport-exp-rubl
  ,output  varprice-without-abs-rubl
  ,output  varprice-slt-rubl
  ,output  varprice-no-slt-rubl
  ,output  varprice-vat-rubl
  ,output  varprice-no-vat-slt-rubl
  ,output  varprice-base
  ,output  varprice-road-tax-base
  ,output  varprice-other-exp-base
  ,output  varprice-transport-exp-base
  ,output  varprice-without-abs-base
  ,output  varprice-slt-base
  ,output  varprice-no-slt-base
  ,output  varprice-vat-base
  ,output  varprice-no-vat-slt-base
  ) no-error.
if error-status:error then do:
  return error "Ошибка при пересчете линии документа".
end.
assign doc-line.price-cli  = varprice-cli
       doc-line.price-base = varprice-base
       doc-line.price-rubl = varprice-rubl.
