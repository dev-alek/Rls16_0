block-level on error undo, throw.
define input  parameter p-calc-method    as character                no-undo .
define input  parameter p-doc-code       as character                no-undo .
define input  parameter p-gds-code       as integer                  no-undo .
define input  parameter p-price-cli      like ub.doc-line.price-cli  no-undo .
define input  parameter p-price-base     like ub.doc-line.price-base no-undo .
define input  parameter p-price-rubl     like ub.doc-line.price-rubl no-undo .
define output parameter p-new-price-cli  like ub.doc-line.price-cli  no-undo .
define output parameter p-new-price-base like ub.doc-line.price-base no-undo .
define output parameter p-new-price-rubl like ub.doc-line.price-rubl no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Пересчет цен разного типа друг в друга".
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
      p-vss-parameters = substitute('&1|&2|&3|&4|&5|&6':u,p-calc-method,p-doc-code,p-gds-code,p-price-cli,p-price-base,p-price-rubl)
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
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
define variable p-new-price-cli-unit-base      like ub.doc-line.price-rubl no-undo.
define variable p-new-price-road-tax           like ub.doc-line.price-rubl no-undo.
define variable p-new-price-other-exp          like ub.doc-line.price-rubl no-undo.
define variable p-new-price-transport-exp      like ub.doc-line.price-rubl no-undo.
define variable p-new-price-without-abs        like ub.doc-line.price-rubl no-undo.
define variable p-new-price-slt                like ub.doc-line.price-rubl no-undo.
define variable p-new-price-no-slt             like ub.doc-line.price-rubl no-undo.
define variable p-new-price-vat                like ub.doc-line.price-rubl no-undo.
define variable p-new-price-no-vat-slt         like ub.doc-line.price-rubl no-undo.
define variable p-new-price-road-tax-rubl      like ub.doc-line.price-rubl no-undo.
define variable p-new-price-other-exp-rubl     like ub.doc-line.price-rubl no-undo.
define variable p-new-price-transport-exp-rubl like ub.doc-line.price-rubl no-undo.
define variable p-new-price-without-abs-rubl   like ub.doc-line.price-rubl no-undo.
define variable p-new-price-slt-rubl           like ub.doc-line.price-rubl no-undo.
define variable p-new-price-no-slt-rubl        like ub.doc-line.price-rubl no-undo.
define variable p-new-price-vat-rubl           like ub.doc-line.price-rubl no-undo.
define variable p-new-price-no-vat-slt-rubl    like ub.doc-line.price-rubl no-undo.
define variable p-new-price-road-tax-base      like ub.doc-line.price-base no-undo.
define variable p-new-price-other-exp-base     like ub.doc-line.price-base no-undo.
define variable p-new-price-transport-exp-base like ub.doc-line.price-base no-undo.
define variable p-new-price-without-abs-base   like ub.doc-line.price-base no-undo.
define variable p-new-price-slt-base           like ub.doc-line.price-base no-undo.
define variable p-new-price-no-slt-base        like ub.doc-line.price-base no-undo.
define variable p-new-price-vat-base           like ub.doc-line.price-base no-undo.
define variable p-new-price-no-vat-slt-base    like ub.doc-line.price-base no-undo.
define buffer buf_doc-line for ub.doc-line .
define buffer t-doc        for ub.trn-doc .
define buffer buf_goods    for ub.goods .
find first t-doc no-lock
  where t-doc.doc-code = p-doc-code
  .
find first buf_goods no-lock
  where buf_goods.gds-code = p-gds-code
  .
find first buf_doc-line no-lock
  where buf_doc-line.doc-code  = p-doc-code
    and buf_doc-line.artic     = buf_goods.artic
    and buf_doc-line.prod-type = buf_goods.prod-type
    and buf_doc-line.prod-code = buf_goods.prod-code
  .
define variable p-artic          like ub.doc-line.artic         no-undo.
define variable p-prod-type      like ub.doc-line.prod-type     no-undo.
define variable p-prod-code      like ub.doc-line.prod-code     no-undo.
define variable p-SLT-PC         like ub.doc-line.SLT-PC        no-undo.
define variable p-VAT-PC         like ub.doc-line.VAT-PC        no-undo.
define variable p-cli-base-rate  like ub.doc-line.cli-base-rate no-undo.
define variable p-doc-qnty       like ub.doc-line.doc-qnty      no-undo.
define variable p-fact-qnty      like ub.doc-line.fact-qnty     no-undo.
define variable p-road-tax       like ub.doc-line.road-tax      no-undo.
define variable p-other-base     like ub.doc-line.road-tax      no-undo.
define variable p-other-rubl     like ub.doc-line.road-tax      no-undo.
define variable p-transport-base like ub.doc-line.road-tax      no-undo.
define variable p-transport-rubl like ub.doc-line.road-tax      no-undo.
case p-calc-method :
  when "price-cli":U then do:
   assign
     p-artic          = buf_doc-line.artic
     p-prod-type      = buf_doc-line.prod-type
     p-prod-code      = buf_doc-line.prod-code
     p-new-price-cli  = p-price-cli
     p-SLT-PC         = buf_doc-line.SLT-pc
     p-VAT-PC         = buf_doc-line.VAT-pc
     p-cli-base-rate  = buf_doc-line.cli-base-rate
     p-doc-qnty       = buf_doc-line.doc-qnty
     p-fact-qnty      = buf_doc-line.fact-qnty
     p-road-tax       = buf_doc-line.road-tax
   .
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_in-vat in g#lib-trn
  (
   input   t-doc.doc-code
  ,input   t-doc.base-rate
  ,input   t-doc.base-scale
  ,input   t-doc.exch-rate
  ,input   t-doc.exch-scale
  ,input   t-doc.vat-type
  ,input   t-doc.slt-type
  ,input   buf_doc-line.artic
  ,input   buf_doc-line.prod-type
  ,input   buf_doc-line.prod-code
  ,input   p-price-cli
  ,input   buf_doc-line.cli-base-rate
  ,input   buf_doc-line.price-rubl
  ,input   buf_doc-line.vat-pc
  ,input   buf_doc-line.slt-pc
  ,input   buf_doc-line.road-tax
  ,input   buf_doc-line.transport-rubl
  ,input   buf_doc-line.other-rubl
  ,output  p-new-price-cli
  ,output  p-new-price-cli-unit-base
  ,output  p-new-price-road-tax
  ,output  p-new-price-other-exp
  ,output  p-new-price-transport-exp
  ,output  p-new-price-without-abs
  ,output  p-new-price-slt
  ,output  p-new-price-no-slt
  ,output  p-new-price-vat
  ,output  p-new-price-no-vat-slt
  ,output  p-new-price-rubl
  ,output  p-new-price-road-tax-rubl
  ,output  p-new-price-other-exp-rubl
  ,output  p-new-price-transport-exp-rubl
  ,output  p-new-price-without-abs-rubl
  ,output  p-new-price-slt-rubl
  ,output  p-new-price-no-slt-rubl
  ,output  p-new-price-vat-rubl
  ,output  p-new-price-no-vat-slt-rubl
  ,output  p-new-price-base
  ,output  p-new-price-road-tax-base
  ,output  p-new-price-other-exp-base
  ,output  p-new-price-transport-exp-base
  ,output  p-new-price-without-abs-base
  ,output  p-new-price-slt-base
  ,output  p-new-price-no-slt-base
  ,output  p-new-price-vat-base
  ,output  p-new-price-no-vat-slt-base
  ) no-error.
    if error-status:error then do:
      return error "Ошибка при пересчете линии документа".
    end.
  end.
  when "price-base":U then do:
    assign
      p-new-price-cli  = p-price-cli
      p-new-price-base = p-price-base
    .
    assign
      p-new-price-rubl = p-price-base * t-doc.base-rate / t-doc.base-scale
    .
  end.
  when "price-rubl":U then do:
    assign
      p-new-price-cli  = p-price-cli
      p-new-price-rubl = p-price-rubl
    .
    assign
      p-new-price-base = p-price-rubl / t-doc.base-rate * t-doc.base-scale
    .
  end.
  otherwise do:
    message
      vss-workfile vss-revision vss-description skip
      "Неизвестное значение параметра" skip
      "p-calc-method":U p-calc-method skip
      view-as alert-box error .
    undo, return error .
  end.
end case .
