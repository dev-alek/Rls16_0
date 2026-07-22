block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: 2014/01/27 14:27:46 $
$Workfile: cor-line.p $
$Archive: str/cor-line.p $

Редактирование линии внешней приходной накладной

Автор: Чернова Светлана Александровна
Дата создания: 10/10/06
Author: Svetlana Chernova
Creation date: 10/10/06

create: Суслов Алексей Юрьевич
Дата создания: 09/12/05


*/

define input        parameter parparentproc    as handle no-undo.
define input-output parameter par-rec-doc-line as recid  no-undo.

{ str/cor-line.i "param" }

define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: 2014/01/27 14:27:46 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: cor-line.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: str/cor-line.p $":U .
define variable vss-description as character no-undo initial "Редактирование линии внешней приходной накладной":U .

{ cmp/vssrevis.i "substitute('&1|&2|&3':u,substitute('&1|&2|&3|&4|&5|&6':u,parprod-type,parprod-code,parartic,parcli-qnty,parcli-base-rate,parfact-qnty,pardoc-qnty),substitute('&1|&2|&3|&4|&5|&6':u,parunit-cli,parvat-pc,parslt-pc,parprice-cli,parprice-base,parprice-rubl,parnum-place),substitute('&1|&2|&3|&4|&5|&6|&7':u,parwt-brutto,parroad-tax,parexcise,pardoc-density,parfact-density,partemperature,parcontract-code,parcst-code,parlast-date))" }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ str/tt-tax.i new }
{ str/lib-def.i  }
{ str/lib-trn.i  }
{ str/lib-calc.i }
{ cmp/strcodec.i }

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
  { str/cor-line.i eq }
  .

  if t-doc.status_ = {&wayb}
    and t-doc.flag = no
  then do:
    assign
      tt-doc-line.fact-density = tt-doc-line.doc-density
      tt-doc-line.fact-qnty    = pardoc-qnty
      tt-doc-line.fact-qnty-kg = pardoc-qnty * tt-doc-line.doc-density
    .
  end.
  else do:
/*    if parfact-qnty-kg <> parfact-qnty * tt-doc-line.fact-density then do:*/
/*      message */
/*        "Ошибка при пересчете линии документа (cor-line.p)" skip*/
/*      view-as alert-box error.*/
/*      undo, return error.*/
/*    end.*/
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
  { str/copy-inh.i
    parparentproc
    recid(t-doc)
    "'cr-upd'"
    yes
    yes
    lib-trn_ret-doc
    lib-trn_ret-line
    lib-trn_ret-line-attr
    lib-trn_ret-dtl
    lib-trn_ret-parts
    no-error}
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
      varaddparam = {&rsrv-dtl_cst-code} + '=':u
                  + str-encode (tt-doc-line.cst-code, '', ',=':u )
    .
  end.
  if tt-doc-line.contract-code <> ? then do:
    assign
      varaddparam = (if varaddparam = '' then '' else varaddparam + ',') +
                    {&rsrv-dtl_contract-code} + '=':u +
                    str-encode (string(tt-doc-line.contract-code), '', ',=':u )
    .
  end.
  if tt-doc-line.last-date <> ? then do:
    assign
      varaddparam = (if varaddparam = '' then '' else varaddparam + ',') +
                    {&rsrv-dtl_last-date} + '=':u +
                    str-encode (string(tt-doc-line.last-date), '', ',=':u )
    .
  end.

  /* Дополнительные атрибуты для партий алкогольной продукции */
  if tt-doc-line.alc-update then do:
    assign
      varaddparam = (if varaddparam = '' then '' else varaddparam + ',') +
                    {&rsrv-dtl_mark-db-num} + '=':u +
                    str-encode (string(tt-doc-line.alc-mark-db-num), '', ',=':u ) +
                    ',' +
                    {&rsrv-dtl_mark-code} + '=':u +
                    str-encode (string(tt-doc-line.alc-mark-code), '', ',=':u ) +
                    ',' +
                    {&rsrv-dtl_alc-bottling-date} + '=':u +
                    str-encode (string(tt-doc-line.alc-bottling-date), '', ',=':u ) +
                    ',' +
                    {&rsrv-dtl_alc-ref-ab-path} + '=':u +
                    str-encode (tt-doc-line.alc-ref-ab-path, '', ',=':u ) +
                    ',' +
                    {&rsrv-dtl_alc-quality-certif-path} + '=':u +
                    str-encode (tt-doc-line.alc-quality-certif-path, '', ',=':u ) +
                    ',' +
                    {&rsrv-dtl_alc-imp-type} + '=':u +
                    str-encode (tt-doc-line.alc-imp-type, '', ',=':u ) +
                    ',' +
                    {&rsrv-dtl_alc-imp-code} + '=':u +
                    str-encode (string(tt-doc-line.alc-imp-code), '', ',=':u ) +
                    ',' +
                    {&rsrv-dtl_alc-certif-path} + '=':u +
                    str-encode (tt-doc-line.alc-certif-path, '', ',=':u )
    .
  end.

  if varupdate = no then do:
    { str/clcintrn.i
      parparentproc
      recid(new-doc-line)
      new-doc-line.doc-code
      new-doc-line.artic
      new-doc-line.prod-type
      new-doc-line.prod-code
      0
      0
      0
      0
      0
      0
      0
      0
      0
      0
      0
      0
      0
      "'create'"
      varaddparam
    }
  end.
  else do:
    { str/clcintrn.i
      parparentproc
      recid(new-doc-line)
      new-doc-line.doc-code
      new-doc-line.artic
      new-doc-line.prod-type
      new-doc-line.prod-code
      old-doc-line.price-cli
      old-doc-line.price-rubl
      old-doc-line.price-base
      old-doc-line.cli-qnty
      old-doc-line.cli-base-rate
      old-doc-line.fact-qnty
      old-doc-line.doc-qnty
      old-doc-line.vat-pc
      old-doc-line.slt-pc
      old-doc-line.road-tax
      old-doc-line.excise
      old-doc-line.transport-rubl
      old-doc-line.other-rubl
      "'update'"
      varaddparam
    }
  end.

  { str/corinvln.i
    t-doc.doc-code
    new-doc-line.artic
    new-doc-line.prod-type
    new-doc-line.prod-code
    0
    0
    0
    0
    tt-doc-line.fact-qnty-kg
    "(if t-doc.status_ = {&wayb} and t-doc.flag = no then tt-doc-line.doc-density else tt-doc-line.fact-density)"
    rec-inv-line
    no-error
  }
  if error-status :error then do:
    return error return-value .
  end.

end.