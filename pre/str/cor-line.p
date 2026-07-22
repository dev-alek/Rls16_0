block-level on error undo, throw.
define input        parameter parparentproc    as handle no-undo.
define input-output parameter par-rec-doc-line as recid  no-undo.
 DEFINE INPUT PARAMETER pardoc-code                LIKE  doc-line.doc-code             NO-UNDO.
 DEFINE INPUT PARAMETER parprod-type               LIKE  doc-line.prod-type            NO-UNDO.
 DEFINE INPUT PARAMETER parprod-code               LIKE  doc-line.prod-code            NO-UNDO.
 DEFINE INPUT PARAMETER parartic                   LIKE  doc-line.artic                NO-UNDO.
 DEFINE INPUT PARAMETER parcli-qnty                LIKE  doc-line.cli-qnty             NO-UNDO.
 DEFINE INPUT PARAMETER parcli-base-rate           LIKE  doc-line.cli-base-rate        NO-UNDO.
 DEFINE INPUT PARAMETER parfact-qnty               LIKE  doc-line.fact-qnty            NO-UNDO.
 DEFINE INPUT PARAMETER pardoc-qnty                LIKE  doc-line.doc-qnty             NO-UNDO.
 DEFINE INPUT PARAMETER parunit-cli                LIKE  doc-line.unit-cli             NO-UNDO.
 DEFINE INPUT PARAMETER parvat-pc                  LIKE  doc-line.vat-pc               NO-UNDO.
 DEFINE INPUT PARAMETER parslt-pc                  LIKE  doc-line.slt-pc               NO-UNDO.
 DEFINE INPUT PARAMETER parprice-cli               LIKE  doc-line.price-cli            NO-UNDO.
 DEFINE INPUT PARAMETER parprice-base              LIKE  doc-line.price-base           NO-UNDO.
 DEFINE INPUT PARAMETER parprice-rubl              LIKE  doc-line.price-rubl           NO-UNDO.
 DEFINE INPUT PARAMETER parnew-price-sale          LIKE  doc-line.new-price-sale       NO-UNDO.
 DEFINE INPUT PARAMETER parnum-place               LIKE  doc-line.num-place            NO-UNDO.
 DEFINE INPUT PARAMETER parwt-brutto               LIKE  doc-line.wt-brutto            NO-UNDO.
 DEFINE INPUT PARAMETER parroad-tax                LIKE  doc-line.road-tax             NO-UNDO.
 DEFINE INPUT PARAMETER parexcise                  LIKE  doc-line.excise               NO-UNDO.
 DEFINE INPUT PARAMETER pardoc-density             LIKE  doc-line.doc-density          NO-UNDO.
 DEFINE INPUT PARAMETER partemperature             LIKE  doc-line.temperature          NO-UNDO.
 DEFINE INPUT PARAMETER parcontract-code           LIKE  parts.contract-code           NO-UNDO.
 DEFINE INPUT PARAMETER parlast-date               LIKE  parts.last-date               NO-UNDO.
 DEFINE INPUT PARAMETER parfact-qnty-kg            LIKE  doc-line.fact-qnty            NO-UNDO.
 DEFINE INPUT PARAMETER parfact-density            LIKE  doc-line.fact-density         NO-UNDO.
 DEFINE INPUT PARAMETER parcst-code                LIKE  parts.cst-code                NO-UNDO.
 DEFINE INPUT PARAMETER paralc-update              AS    logical                       NO-UNDO.
 DEFINE INPUT PARAMETER paralc-part-code           LIKE  parts.part-code               NO-UNDO.
 DEFINE INPUT PARAMETER paralc-mark-db-num         LIKE  parts.mark-db-num             NO-UNDO.
 DEFINE INPUT PARAMETER paralc-mark-code           LIKE  parts.mark-code               NO-UNDO.
 DEFINE INPUT PARAMETER paralc-bottling-date       LIKE  parts.alc-bottling-date       NO-UNDO.
 DEFINE INPUT PARAMETER paralc-ref-ab-path         LIKE  parts.alc-ref-ab-path         NO-UNDO.
 DEFINE INPUT PARAMETER paralc-quality-certif-path LIKE  parts.alc-quality-certif-path NO-UNDO.
 DEFINE INPUT PARAMETER paralc-imp-type            LIKE  parts.alc-imp-type            NO-UNDO.
 DEFINE INPUT PARAMETER paralc-imp-code            LIKE  parts.alc-imp-code            NO-UNDO.
 DEFINE INPUT PARAMETER paralc-certif-path         LIKE  parts.alc-certif-path         NO-UNDO.
define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: 2014/01/27 14:27:46 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: cor-line.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: str/cor-line.p $":U .
define variable vss-description as character no-undo initial "Редактирование линии внешней приходной накладной":U .
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
      p-vss-parameters = substitute('&1|&2|&3':u,substitute('&1|&2|&3|&4|&5|&6':u,parprod-type,parprod-code,parartic,parcli-qnty,parcli-base-rate,parfact-qnty,pardoc-qnty),substitute('&1|&2|&3|&4|&5|&6':u,parunit-cli,parvat-pc,parslt-pc,parprice-cli,parprice-base,parprice-rubl,parnum-place),substitute('&1|&2|&3|&4|&5|&6|&7':u,parwt-brutto,parroad-tax,parexcise,pardoc-density,parfact-density,partemperature,parcontract-code,parcst-code,parlast-date))
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
  define temp-table  tt-tax no-undo
field tax-code    like ub.tax.tax-code
FIELD individual  like ub.tax.individual
FIELD tax-name    like ub.tax.tax-name format "X(12)" column-label "Налог"
field rate-code   like ub.tax-rate.rate-code
FIELD rate-name   like ub.tax-rate.rate-name FORMAT "X(12)"
FIELD tax-type    like ub.tax.tax-type
field rate-value  like ub.tax-rate-value.rate-value
FIELD tax-rate-gds-rc  as recid
FIELD to-cashdesk like ub.tax.to-cashdesk
index tax-code is unique primary tax-code.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table lib-trn_ret-doc       no-undo like ub.trn-doc.
define temp-table lib-trn_ret-line      no-undo like ub.doc-line
  field cst-code                like ub.trn-doc.cst-code
  field part-code               like ub.parts.part-code
  .
define temp-table lib-trn_ret-line-attr no-undo like ub.doc-line-attr.
define temp-table lib-trn_ret-dtl       no-undo like ub.gds-dtl.
define temp-table lib-trn_ret-parts     no-undo like ub.parts.
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#lib-calc as handle no-undo .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function octal-to-char return character
( p-string as character ) :
  def var v-asc     as integer no-undo .
  def var v-new-asc as integer no-undo .
  def var ind       as integer no-undo .
  if length(p-string) <> 3 then do:
    return ? .
  end.
  assign
    v-asc = 0
  .
  do ind = 1 to length(p-string)
  :
    assign
      v-new-asc = asc(substring(p-string, ind, 1)) - asc('0')
    .
    if v-new-asc < 0 or v-new-asc >= 8 then do:
      return ? .
    end.
    assign
      v-asc = v-asc * 8 + v-new-asc
    .
  end.
  return chr(v-asc) .
end function .
function char-to-octal return character
( p-chr as character ) :
  def var v-asc    as integer   no-undo .
  def var ind      as integer   no-undo .
  def var v-string as character no-undo .
  if length(p-chr) <> 1 then do:
    return ? .
  end.
  assign
    v-asc    = asc(p-chr)
    v-string = ""
  .
  do ind = 1 to 3
  :
    assign
      v-string = chr( v-asc mod 8 + asc('0')) + v-string
    .
    assign
      v-asc = truncate(v-asc / 8, 0)
    .
  end.
  return v-string .
end.
function str-encode return character
(   p-init-string       as character
  , p-encode-char       as character
  , p-special-char-list as character
) :
  def var p-encode-string as character no-undo .
  def var ind                as integer no-undo .
  def var v-num-special-char as integer no-undo .
  def var v-special-char     as character no-undo .
  if p-encode-char = ?
  or p-encode-char = "" then do:
    assign
      p-encode-char = "~~"
    .
  end.
  if p-init-string = ? then do:
    return "?" .
  end.
  if p-init-string = "?" then do:
    return p-encode-char + char-to-octal("?") .
  end.
  assign
    v-num-special-char = length(p-special-char-list)
    p-encode-string    = replace(p-init-string
                                ,p-encode-char
                                ,p-encode-char + char-to-octal(p-encode-char)
                                )
  .
  do ind = 1 to v-num-special-char
  :
    assign
      v-special-char = substring(p-special-char-list, ind, 1)
    .
    if v-special-char <> p-encode-char then do:
      assign
        p-encode-string = replace (p-encode-string
                                  ,v-special-char
                                  ,p-encode-char + char-to-octal(v-special-char)
                                  )
      .
    end.
  end.
  return p-encode-string .
end.
function str-decode returns character
  (p-init-string   as character
  ,p-encode-char   as character
  ) :
  def var p-decode-string as character no-undo .
  def var ind                       as integer no-undo .
  def var v-num-entries-init-string as integer no-undo .
  def var v-sub-phrase              as character no-undo .
  def var v-special-char            as character no-undo .
  if p-encode-char = ?
  or p-encode-char = "" then do:
    assign
      p-encode-char = "~~"
    .
  end.
  if p-init-string = "?" then do:
    return ? .
  end.
  assign
    v-num-entries-init-string = num-entries(p-init-string, p-encode-char)
  .
  if v-num-entries-init-string > 1 then do:
    assign
      p-decode-string = entry(1, p-init-string, p-encode-char)
    .
    do ind = 2 to v-num-entries-init-string
    :
      assign
        v-sub-phrase = entry(ind, p-init-string, p-encode-char)
      .
      assign
        v-special-char = octal-to-char(substring(v-sub-phrase, 1, 3))
      .
      if v-special-char <> ? then do:
        assign
          p-decode-string = p-decode-string
                          + v-special-char
                          + substring(v-sub-phrase, 4)
        .
      end.
      else do:
        assign
          p-decode-string = p-decode-string
                          + p-encode-char
                          + v-sub-phrase
        .
      end.
    end.
  end.
  else do:
    assign
      p-decode-string = p-init-string
    .
  end.
  return p-decode-string .
end.
define buffer t-doc        for ub.trn-doc.
define buffer new-doc-line for ub.doc-line.
define buffer bf_doc-pl    for ub.doc-pl.
define variable varres        as   logical                no-undo.
define variable var-code-temp like ub.place.pl-code       no-undo.
define variable mode-create   as   logical                no-undo initial yes.
define variable rec-old       as   recid                  no-undo.
define variable varupdate     as   logical                no-undo.
define variable varaddparam   as   character              no-undo.
define variable price-vat     like ub.doc-line.price-base no-undo.
define variable rec-inv-line  as   recid                  no-undo.
define temp-table tt-doc-line no-undo like ub.doc-line
  field cst-code                like ub.parts.cst-code
  field contract-code           like ub.parts.contract-code
  field last-date               like ub.parts.last-date
  field fact-qnty-kg            like ub.doc-line.fact-qnty
  field alc-update              as   logical
  field part-code               like ub.parts.part-code
  field alc-mark-db-num         like ub.parts.mark-db-num
  field alc-mark-code           like ub.parts.mark-code
  field alc-bottling-date       like ub.parts.alc-bottling-date
  field alc-ref-ab-path         like ub.parts.alc-ref-ab-path
  field alc-quality-certif-path like ub.parts.alc-quality-certif-path
  field alc-certif-path         like ub.parts.alc-certif-path
  field alc-imp-type            like ub.parts.alc-imp-type
  field alc-imp-code            like ub.parts.alc-imp-code
  .
define temp-table old-doc-line no-undo like ub.doc-line.
do
on error undo, return error return-value
:
  find first t-doc
    where t-doc.doc-code = pardoc-code
  .
  create tt-doc-line.
  assign
 TT-doc-line.doc-code                 = pardoc-code
 TT-doc-line.prod-type                = parprod-type
 TT-doc-line.prod-code                = parprod-code
 TT-doc-line.artic                    = parartic
 TT-doc-line.cli-qnty                 = parcli-qnty
 TT-doc-line.cli-base-rate            = parcli-base-rate
 TT-doc-line.fact-qnty                = parfact-qnty
 TT-doc-line.doc-qnty                 = pardoc-qnty
 TT-doc-line.unit-cli                 = parunit-cli
 TT-doc-line.vat-pc                   = parvat-pc
 TT-doc-line.slt-pc                   = parslt-pc
 TT-doc-line.price-cli                = parprice-cli
 TT-doc-line.price-base               = parprice-base
 TT-doc-line.price-rubl               = parprice-rubl
 TT-doc-line.new-price-sale           = parnew-price-sale
 TT-doc-line.num-place                = parnum-place
 TT-doc-line.wt-brutto                = parwt-brutto
 TT-doc-line.road-tax                 = parroad-tax
 TT-doc-line.excise                   = parexcise
 TT-doc-line.doc-density              = pardoc-density
 TT-doc-line.temperature              = partemperature
 TT-doc-line.contract-code            = parcontract-code
 TT-doc-line.last-date                = parlast-date
 TT-doc-line.fact-qnty-kg             = parfact-qnty-kg
 TT-doc-line.fact-density             = parfact-density
 TT-doc-line.cst-code                 = parcst-code
 TT-doc-line.alc-update               = paralc-update
 TT-doc-line.part-code                = paralc-part-code
 TT-doc-line.alc-mark-db-num          = paralc-mark-db-num
 TT-doc-line.alc-mark-code            = paralc-mark-code
 TT-doc-line.alc-bottling-date        = paralc-bottling-date
 TT-doc-line.alc-ref-ab-path          = paralc-ref-ab-path
 TT-doc-line.alc-quality-certif-path  = paralc-quality-certif-path
 TT-doc-line.alc-imp-type             = paralc-imp-type
 TT-doc-line.alc-imp-code             = paralc-imp-code
 TT-doc-line.alc-certif-path          = paralc-certif-path
  .
  if t-doc.status_ = 'накл':U
    and t-doc.flag = no
  then do:
    assign
      tt-doc-line.fact-density = tt-doc-line.doc-density
      tt-doc-line.fact-qnty    = pardoc-qnty
      tt-doc-line.fact-qnty-kg = pardoc-qnty * tt-doc-line.doc-density
    .
  end.
  else do:
    assign
      tt-doc-line.fact-qnty    = parfact-qnty
      tt-doc-line.fact-qnty-kg = parfact-qnty * tt-doc-line.fact-density
    .
  end.
  find first ub.goods no-lock where
            ub.goods.artic     = parartic     and
            ub.goods.prod-type = parprod-type and
            ub.goods.prod-code = parprod-code.
  for each lib-trn_ret-doc:
    delete lib-trn_ret-doc.
  end.
  create lib-trn_ret-doc.
  buffer-copy t-doc to lib-trn_ret-doc.
  for each lib-trn_ret-line:
    delete lib-trn_ret-line.
  end.
  create lib-trn_ret-line.
  buffer-copy tt-doc-line to lib-trn_ret-line.
  find first ub.doc-line where
            ub.doc-line.doc-code  = t-doc.doc-code        and
            ub.doc-line.artic     = tt-doc-line.artic     and
            ub.doc-line.prod-type = tt-doc-line.prod-type and
            ub.doc-line.prod-code = tt-doc-line.prod-code no-error.
  if available ub.doc-line then do:
    assign varupdate = yes.
    for each old-doc-line:
        delete old-doc-line.
    end.
    create old-doc-line.
    buffer-copy ub.doc-line to old-doc-line.
  end.
  else do:
    assign varupdate = no.
  end.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_copy-inh in g#lib-trn
( input parparentproc
 ,input recid(t-doc)
 ,input 'cr-upd'
 ,input yes
 ,input yes
 ,input table lib-trn_ret-doc
 ,input table lib-trn_ret-line
 ,input table lib-trn_ret-line-attr
 ,input table lib-trn_ret-dtl
 ,input table lib-trn_ret-parts
  ) no-error .
  if error-status :error then do:
    message "Ошибка при пересчете линии документа (cor-line.p)" skip
            return-value                 skip
            error-status :get-message(1) skip
    view-as alert-box error.
    undo, return error.
  end.
  find first new-doc-line where new-doc-line.doc-code  = t-doc.doc-code        and
                                new-doc-line.artic     = tt-doc-line.artic     and
                                new-doc-line.prod-type = tt-doc-line.prod-type and
                                new-doc-line.prod-code = tt-doc-line.prod-code no-error .
  if error-status :error then return .
  assign
    par-rec-doc-line = recid(new-doc-line).
  if tt-doc-line.cst-code <> ? then do:
    assign
      varaddparam = 'cst-code':U + '=':u
                  + str-encode (tt-doc-line.cst-code, '', ',=':u )
    .
  end.
  if tt-doc-line.contract-code <> ? then do:
    assign
      varaddparam = (if varaddparam = '' then '' else varaddparam + ',') +
                    'contract-code':U + '=':u +
                    str-encode (string(tt-doc-line.contract-code), '', ',=':u )
    .
  end.
  if tt-doc-line.last-date <> ? then do:
    assign
      varaddparam = (if varaddparam = '' then '' else varaddparam + ',') +
                    'last-date':U + '=':u +
                    str-encode (string(tt-doc-line.last-date), '', ',=':u )
    .
  end.
  if tt-doc-line.alc-update then do:
    assign
      varaddparam = (if varaddparam = '' then '' else varaddparam + ',') +
                    'mark-db-num':U + '=':u +
                    str-encode (string(tt-doc-line.alc-mark-db-num), '', ',=':u ) +
                    ',' +
                    'mark-code':U + '=':u +
                    str-encode (string(tt-doc-line.alc-mark-code), '', ',=':u ) +
                    ',' +
                    'alc-bottling-date':U + '=':u +
                    str-encode (string(tt-doc-line.alc-bottling-date), '', ',=':u ) +
                    ',' +
                    'alc-ref-ab-path':U + '=':u +
                    str-encode (tt-doc-line.alc-ref-ab-path, '', ',=':u ) +
                    ',' +
                    'alc-quality-certif-path':U + '=':u +
                    str-encode (tt-doc-line.alc-quality-certif-path, '', ',=':u ) +
                    ',' +
                    'alc-imp-type':U + '=':u +
                    str-encode (tt-doc-line.alc-imp-type, '', ',=':u ) +
                    ',' +
                    'alc-imp-code':U + '=':u +
                    str-encode (string(tt-doc-line.alc-imp-code), '', ',=':u ) +
                    ',' +
                    'alc-certif-path':U + '=':u +
                    str-encode (tt-doc-line.alc-certif-path, '', ',=':u )
    .
  end.
  if varupdate = no then do:
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_clcintrn in g#lib-trn
  (
   input parparentproc
  ,input recid(new-doc-line)
  ,input new-doc-line.doc-code
  ,input new-doc-line.artic
  ,input new-doc-line.prod-type
  ,input new-doc-line.prod-code
  ,input 0
  ,input 0
  ,input 0
  ,input 0
  ,input 0
  ,input 0
  ,input 0
  ,input 0
  ,input 0
  ,input 0
  ,input 0
  ,input 0
  ,input 0
  ,input 'create'
  ,input varaddparam
  ) .
  end.
  else do:
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_clcintrn in g#lib-trn
  (
   input parparentproc
  ,input recid(new-doc-line)
  ,input new-doc-line.doc-code
  ,input new-doc-line.artic
  ,input new-doc-line.prod-type
  ,input new-doc-line.prod-code
  ,input old-doc-line.price-cli
  ,input old-doc-line.price-rubl
  ,input old-doc-line.price-base
  ,input old-doc-line.cli-qnty
  ,input old-doc-line.cli-base-rate
  ,input old-doc-line.fact-qnty
  ,input old-doc-line.doc-qnty
  ,input old-doc-line.vat-pc
  ,input old-doc-line.slt-pc
  ,input old-doc-line.road-tax
  ,input old-doc-line.excise
  ,input old-doc-line.transport-rubl
  ,input old-doc-line.other-rubl
  ,input 'update'
  ,input varaddparam
  ) .
  end.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_corinvln in g#lib-trn3
( input  t-doc.doc-code
 ,input  new-doc-line.artic
 ,input  new-doc-line.prod-type
 ,input  new-doc-line.prod-code
 ,input  0
 ,input  0
 ,input  0
 ,input  0
 ,input  tt-doc-line.fact-qnty-kg
 ,input  (if t-doc.status_ = 'накл':U and t-doc.flag = no then tt-doc-line.doc-density else tt-doc-line.fact-density)
 ,output rec-inv-line
 ) no-error.
  if error-status :error then do:
    return error return-value .
  end.
end.
