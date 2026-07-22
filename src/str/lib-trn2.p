block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Библиотека процедур для работы со складскими документами (2)

Автор: Чернова Светлана Александровна
Дата создания: 03/26/08
Author: Svetlana Chernova
Creation date: 03/26/08

Автор1: Суслов Алексей Юрьевич
Дата создания: 04/03/02

*/

using ibs.th.gbl.gbl-hndllib from propath.

define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Библиотека процедур для работы со складскими документами (2)":U .

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ str/trdcalib.i }
{ cmp/operlist.i }
{ str/lib-trn.i  }
{ cmp/library.i  }
{ trg/partslib.i }
{ str/clcprtsl.i }
{ str/lib-rwds.i }
{ cmp/gds-list.i gds-list def }
{ ref/gdsoattr.i }
{ str/plgdsfnd.i no-interface }
{ trg/prdoclib.i }
{ trg/factord.i }
{ str/valddnst.i def }
{ gbl/getsect.i  def }
{ gbl/cur-time.i }
{ str/placelib.i }
{ str/is-sug.i   }

define variable lns-cnt  as integer no-undo.
define variable line-rec as recid   no-undo.

if valid-handle (g#lib-trn2)
and g#lib-trn2 <> this-procedure :handle
and g#lib-trn2 :get-signature('lib-trn2_crinvdoc':u) <> ""
then do:
  message
    vss-workfile vss-revision vss-description skip
    "Попытка повторной загрузки библиотеки для работы с документами" skip
    g#lib-trn2 skip
    g#lib-trn2 :type skip
    g#lib-trn2 :file-name skip
    valid-handle(g#lib-trn2) skip
    this-procedure :handle skip
    this-procedure :type skip
    this-procedure :file-name skip
    valid-handle(this-procedure) skip
    view-as alert-box error .
  undo, return error .
end.
else do:
  assign
    g#lib-trn2 = this-procedure :handle
  .
  def var gbl-hndllibObj as class gbl-hndllib no-undo.
  gbl-hndllibObj = new gbl-hndllib ().
  gbl-hndllibObj:InitHndl("g#lib-trn2", g#lib-trn2).
  delete object gbl-hndllibObj.
end.

on delete of this-procedure do:
  assign
    g#lib-trn2 = ?
  .
  def var gbl-hndllibObj as class gbl-hndllib no-undo.
  gbl-hndllibObj = new gbl-hndllib ().
  gbl-hndllibObj:InitHndl("g#lib-trn2", g#lib-trn2).
  delete object gbl-hndllibObj.
end.

define stream str-err.

/* Создание шапки дополнения к документу инвентаризации */
procedure lib-trn2_crinvdoc :
define input parameter pardoc-code like ub.trn-doc.doc-code no-undo.
define buffer cr_trn-doc for ub.trn-doc.
define variable varwastagevalue as character no-undo.
define variable varwastagetype  as character no-undo.
define variable varinvclcwt     as character no-undo.
define variable varinvclcwttype as character no-undo.
define variable varinvclcas     as character no-undo.
define variable varinvclcastype as character no-undo.
do on error undo, return error return-value :
find first cr_trn-doc where cr_trn-doc.doc-code = pardoc-code no-lock.

{ gbl/getsect.i run "''" 0  {&attr-inv-global} }
for each thbjattr_thbj-attr :
    if thbjattr_thbj-attr.prop-code = 'invclcas'  then varinvclcas = string( thbjattr_thbj-attr.property-value-logical, "yes/no").
    if thbjattr_thbj-attr.prop-code = 'invclcwt'  then varinvclcwt = string( thbjattr_thbj-attr.property-value-logical, "yes/no").
end.

{ gbl/getsect.i run cr_trn-doc.obj-type cr_trn-doc.obj-code {&attr-inv-obj} }
for each thbjattr_thbj-attr :
    if thbjattr_thbj-attr.prop-code = 'wastage'  then varwastagevalue = string( thbjattr_thbj-attr.property-value-logical, "yes/no").
end.
empty temp-table thbjattr_thbj-attr.

{ str/tdat-wrt.i cr_trn-doc.doc-code
             {&trdcattr-othermoves}
             "yes" no-error }
if error-status :error then do:
  return error substitute( "Ошибка при вызове процедуры tdat-wrt &1 &2"
                         , return-value
                         , error-status :get-message( 1 ) ).
end.                
if varwastagevalue = "yes" and
   varinvclcwt     = "yes" then do:
   { str/tdat-wrt.i cr_trn-doc.doc-code
                {&trdcattr-clcaswt}
                "yes" no-error }
   if error-status :error then do:
     return error substitute( "Ошибка при вызове процедуры tdat-wrt &1 &2"
                            , return-value
                            , error-status :get-message( 1 ) ).
   end.
end.
else do:
   { str/tdat-wrt.i cr_trn-doc.doc-code
                {&trdcattr-clcaswt}
                "no" no-error }
   if error-status :error then do:
     return error substitute( "Ошибка при вызове процедуры tdat-wrt &1 &2"
                            , return-value
                            , error-status :get-message( 1 ) ).
   end.
end.
if varinvclcas = "yes" then do:
   { str/tdat-wrt.i cr_trn-doc.doc-code
                {&trdcattr-clcasol}
                "yes" no-error }
   if error-status :error then do:
     return error substitute( "Ошибка при вызове процедуры tdat-wrt &1 &2"
                            , return-value
                            , error-status :get-message( 1 ) ).
   end.
end.
else do:
   { str/tdat-wrt.i cr_trn-doc.doc-code
                {&trdcattr-clcasol}
                "no" no-error }
   if error-status :error then do:
     return error substitute( "Ошибка при вызове процедуры tdat-wrt &1 &2"
                            , return-value
                            , error-status :get-message( 1 ) ).
   end.
end.
end.
end procedure. /* lib-trn2_crinvdoc */

/* Полный пересчет шапки по строкам */
procedure lib-trn2_reclctsl :
define input parameter pardoc-code like ub.trn-doc.doc-code     no-undo.
define input parameter parsum-type like ub.trn-doc-sum.sum-type no-undo.
define buffer bf_trn-doc-sum         for ub.trn-doc-sum.
define buffer bf-ext_trn-doc-sum     for ub.trn-doc-sum.
define buffer bf-mis_trn-doc-sum     for ub.trn-doc-sum.
define buffer bf-ext-cli_trn-doc-sum for ub.trn-doc-sum.
define buffer bf-mis-cli_trn-doc-sum for ub.trn-doc-sum.
define buffer bf_doc-line-sum        for ub.doc-line-sum.
define variable vartime as integer no-undo.
do on error undo, return error return-value :

assign
  vartime = time.
find first bf_trn-doc-sum where bf_trn-doc-sum.doc-code = pardoc-code and
                                bf_trn-doc-sum.sum-type = parsum-type no-error.
if error-status :error then do:
  return error substitute( "Не найдена запись дополнительных сумм по документу &1. Тип суммы &2."
                         , pardoc-code
                         , parsum-type ).
end.
{ str/cltrnsum.i pardoc-code
             parsum-type no-error }
if error-status :error then do:
  return error substitute( "Ошибка при вызове процедуры lib-rwds_cltrnsum для документа &1. Тип суммы &2."
                         , pardoc-code
                         , parsum-type ).
end.
if parsum-type = {&sum-general-doc} then do:
  find first bf-ext_trn-doc-sum where bf-ext_trn-doc-sum.doc-code = pardoc-code      and
                                      bf-ext_trn-doc-sum.sum-type = {&sum-extra-doc} no-error.
  if error-status :error then do:
    return error substitute( "Не найдена запись дополнительных сумм по документу &1. Тип суммы &2."
                           , pardoc-code
                           , parsum-type ).
  end.
  { str/cltrnsum.i pardoc-code
               {&sum-extra-doc} no-error }
  if error-status :error then do:
    return error substitute( "Ошибка при вызове процедуры lib-rwds_cltrnsum для документа &1. Тип суммы &2."
                           , pardoc-code
                           , parsum-type ).
  end.
  find first bf-mis_trn-doc-sum where bf-mis_trn-doc-sum.doc-code = pardoc-code      and
                                      bf-mis_trn-doc-sum.sum-type = {&sum-miss-doc} no-error.
  if error-status :error then do:
    return error substitute( "Не найдена запись дополнительных сумм по документу &1. Тип суммы &2."
                           , pardoc-code
                           , parsum-type ).
  end.
  { str/cltrnsum.i pardoc-code
               {&sum-miss-doc} no-error }
  if error-status :error then do:
    return error substitute( "Ошибка при вызове процедуры lib-rwds_cltrnsum для документа &1. Тип суммы &2."
                           , pardoc-code
                           , parsum-type ).
  end.
end.
if parsum-type = {&sum-general-cli-doc} then do:
  find first bf-ext-cli_trn-doc-sum where bf-ext-cli_trn-doc-sum.doc-code = pardoc-code          and
                                          bf-ext-cli_trn-doc-sum.sum-type = {&sum-extra-cli-doc} no-error.
  if error-status :error then do:
    return error substitute( "Не найдена запись дополнительных сумм по документу &1. Тип суммы &2."
                           , pardoc-code
                           , parsum-type ).
  end.
  { str/cltrnsum.i pardoc-code
               {&sum-extra-cli-doc} no-error }
  if error-status :error then do:
    return error substitute( "Ошибка при вызове процедуры lib-rwds_cltrnsum для документа &1. Тип суммы &2."
                           , pardoc-code
                           , parsum-type ).
  end.
  find first bf-mis-cli_trn-doc-sum where bf-mis-cli_trn-doc-sum.doc-code = pardoc-code      and
                                          bf-mis-cli_trn-doc-sum.sum-type = {&sum-miss-cli-doc} no-error.
  if error-status :error then do:
    return error substitute( "Не найдена запись дополнительных сумм по документу &1. Тип суммы &2."
                           , pardoc-code
                           , parsum-type ).
  end.
  { str/cltrnsum.i pardoc-code
               {&sum-miss-cli-doc} no-error }
  if error-status :error then do:
    return error substitute( "Ошибка при вызове процедуры lib-rwds_cltrnsum для документа &1. Тип суммы &2."
                           , pardoc-code
                           , parsum-type ).
  end.
end.

for each bf_doc-line-sum where bf_doc-line-sum.doc-code = pardoc-code and
                               bf_doc-line-sum.sum-type = parsum-type on error undo, return error return-value :
   assign
    bf_trn-doc-sum.fact-qnty             = bf_trn-doc-sum.fact-qnty            + bf_doc-line-sum.fact-qnty
    bf_trn-doc-sum.sale-sum-base         = bf_trn-doc-sum.sale-sum-base        + bf_doc-line-sum.sale-sum-base
    bf_trn-doc-sum.sale-sum-rubl         = bf_trn-doc-sum.sale-sum-rubl        + bf_doc-line-sum.sale-sum-rubl
    bf_trn-doc-sum.sale-VAT-base         = bf_trn-doc-sum.sale-VAT-base        + bf_doc-line-sum.sale-VAT-base
    bf_trn-doc-sum.sale-VAT-rubl         = bf_trn-doc-sum.sale-VAT-rubl        + bf_doc-line-sum.sale-VAT-rubl
    bf_trn-doc-sum.sale-SLT-base         = bf_trn-doc-sum.sale-SLT-base        + bf_doc-line-sum.sale-SLT-base
    bf_trn-doc-sum.sale-SLT-rubl         = bf_trn-doc-sum.sale-SLT-rubl        + bf_doc-line-sum.sale-SLT-rubl
    bf_trn-doc-sum.sale-road-tax-base    = bf_trn-doc-sum.sale-road-tax-base   + bf_doc-line-sum.sale-road-tax-base
    bf_trn-doc-sum.sale-road-tax-rubl    = bf_trn-doc-sum.sale-road-tax-rubl   + bf_doc-line-sum.sale-road-tax-rubl
    bf_trn-doc-sum.sale-excise-base      = bf_trn-doc-sum.sale-excise-base     + bf_doc-line-sum.sale-excise-base
    bf_trn-doc-sum.sale-excise-rubl      = bf_trn-doc-sum.sale-excise-rubl     + bf_doc-line-sum.sale-excise-rubl
    bf_trn-doc-sum.sale-transport-base   = bf_trn-doc-sum.sale-transport-base  + bf_doc-line-sum.sale-transport-base
    bf_trn-doc-sum.sale-transport-rubl   = bf_trn-doc-sum.sale-transport-rubl  + bf_doc-line-sum.sale-transport-rubl
    bf_trn-doc-sum.sale-other-base       = bf_trn-doc-sum.sale-other-base      + bf_doc-line-sum.sale-other-base
    bf_trn-doc-sum.sale-other-rubl       = bf_trn-doc-sum.sale-other-rubl      + bf_doc-line-sum.sale-other-rubl
    bf_trn-doc-sum.sale-discnt-base      = bf_trn-doc-sum.sale-discnt-base     + bf_doc-line-sum.sale-discnt-base
    bf_trn-doc-sum.sale-discnt-rubl      = bf_trn-doc-sum.sale-discnt-rubl     + bf_doc-line-sum.sale-discnt-rubl
    bf_trn-doc-sum.crsa-sum-base         = bf_trn-doc-sum.crsa-sum-base        + bf_doc-line-sum.crsa-sum-base
    bf_trn-doc-sum.crsa-sum-rubl         = bf_trn-doc-sum.crsa-sum-rubl        + bf_doc-line-sum.crsa-sum-rubl
    bf_trn-doc-sum.crsa-VAT-base         = bf_trn-doc-sum.crsa-VAT-base        + bf_doc-line-sum.crsa-VAT-base
    bf_trn-doc-sum.crsa-VAT-rubl         = bf_trn-doc-sum.crsa-VAT-rubl        + bf_doc-line-sum.crsa-VAT-rubl
    bf_trn-doc-sum.crsa-SLT-base         = bf_trn-doc-sum.crsa-SLT-base        + bf_doc-line-sum.crsa-SLT-base
    bf_trn-doc-sum.crsa-SLT-rubl         = bf_trn-doc-sum.crsa-SLT-rubl        + bf_doc-line-sum.crsa-SLT-rubl
    bf_trn-doc-sum.crsa-road-tax-base    = bf_trn-doc-sum.crsa-road-tax-base   + bf_doc-line-sum.crsa-road-tax-base
    bf_trn-doc-sum.crsa-road-tax-rubl    = bf_trn-doc-sum.crsa-road-tax-rubl   + bf_doc-line-sum.crsa-road-tax-rubl
    bf_trn-doc-sum.crsa-excise-base      = bf_trn-doc-sum.crsa-excise-base     + bf_doc-line-sum.crsa-excise-base
    bf_trn-doc-sum.crsa-excise-rubl      = bf_trn-doc-sum.crsa-excise-rubl     + bf_doc-line-sum.crsa-excise-rubl
    bf_trn-doc-sum.crsa-transport-base   = bf_trn-doc-sum.crsa-transport-base  + bf_doc-line-sum.crsa-transport-base
    bf_trn-doc-sum.crsa-transport-rubl   = bf_trn-doc-sum.crsa-transport-rubl  + bf_doc-line-sum.crsa-transport-rubl
    bf_trn-doc-sum.crsa-other-base       = bf_trn-doc-sum.crsa-other-base      + bf_doc-line-sum.crsa-other-base
    bf_trn-doc-sum.crsa-other-rubl       = bf_trn-doc-sum.crsa-other-rubl      + bf_doc-line-sum.crsa-other-rubl
    bf_trn-doc-sum.crsa-discnt-base      = bf_trn-doc-sum.crsa-discnt-base     + bf_doc-line-sum.crsa-discnt-base
    bf_trn-doc-sum.crsa-discnt-rubl      = bf_trn-doc-sum.crsa-discnt-rubl     + bf_doc-line-sum.crsa-discnt-rubl
    bf_trn-doc-sum.cost-sum-base         = bf_trn-doc-sum.cost-sum-base        + bf_doc-line-sum.cost-sum-base
    bf_trn-doc-sum.cost-sum-rubl         = bf_trn-doc-sum.cost-sum-rubl        + bf_doc-line-sum.cost-sum-rubl
    bf_trn-doc-sum.cost-VAT-base         = bf_trn-doc-sum.cost-VAT-base        + bf_doc-line-sum.cost-VAT-base
    bf_trn-doc-sum.cost-VAT-rubl         = bf_trn-doc-sum.cost-VAT-rubl        + bf_doc-line-sum.cost-VAT-rubl
    bf_trn-doc-sum.cost-SLT-base         = bf_trn-doc-sum.cost-SLT-base        + bf_doc-line-sum.cost-SLT-base
    bf_trn-doc-sum.cost-SLT-rubl         = bf_trn-doc-sum.cost-SLT-rubl        + bf_doc-line-sum.cost-SLT-rubl
    bf_trn-doc-sum.cost-road-tax-base    = bf_trn-doc-sum.cost-road-tax-base   + bf_doc-line-sum.cost-road-tax-base
    bf_trn-doc-sum.cost-road-tax-rubl    = bf_trn-doc-sum.cost-road-tax-rubl   + bf_doc-line-sum.cost-road-tax-rubl
    bf_trn-doc-sum.cost-excise-base      = bf_trn-doc-sum.cost-excise-base     + bf_doc-line-sum.cost-excise-base
    bf_trn-doc-sum.cost-excise-rubl      = bf_trn-doc-sum.cost-excise-rubl     + bf_doc-line-sum.cost-excise-rubl
    bf_trn-doc-sum.cost-transport-base   = bf_trn-doc-sum.cost-transport-base  + bf_doc-line-sum.cost-transport-base
    bf_trn-doc-sum.cost-transport-rubl   = bf_trn-doc-sum.cost-transport-rubl  + bf_doc-line-sum.cost-transport-rubl
    bf_trn-doc-sum.cost-other-base       = bf_trn-doc-sum.cost-other-base      + bf_doc-line-sum.cost-other-base
    bf_trn-doc-sum.cost-other-rubl       = bf_trn-doc-sum.cost-other-rubl      + bf_doc-line-sum.cost-other-rubl
    bf_trn-doc-sum.cost-discnt-base      = bf_trn-doc-sum.cost-discnt-base     + bf_doc-line-sum.cost-discnt-base
    bf_trn-doc-sum.cost-discnt-rubl      = bf_trn-doc-sum.cost-discnt-rubl     + bf_doc-line-sum.cost-discnt-rubl
    .

  if parsum-type = {&sum-general-doc} then do:
    if bf_doc-line-sum.fact-qnty > 0 then do:
      assign
        bf-ext_trn-doc-sum.fact-qnty             = bf-ext_trn-doc-sum.fact-qnty            + bf_doc-line-sum.fact-qnty .
    end.
    else do:
      assign
        bf-mis_trn-doc-sum.fact-qnty             = bf-mis_trn-doc-sum.fact-qnty            - bf_doc-line-sum.fact-qnty .
    end.
    if bf_doc-line-sum.sale-sum-base > 0 then do:
      assign
        bf-ext_trn-doc-sum.sale-sum-base         = bf-ext_trn-doc-sum.sale-sum-base        + bf_doc-line-sum.sale-sum-base
        bf-ext_trn-doc-sum.sale-sum-rubl         = bf-ext_trn-doc-sum.sale-sum-rubl        + bf_doc-line-sum.sale-sum-rubl
        bf-ext_trn-doc-sum.sale-VAT-base         = bf-ext_trn-doc-sum.sale-VAT-base        + bf_doc-line-sum.sale-VAT-base
        bf-ext_trn-doc-sum.sale-VAT-rubl         = bf-ext_trn-doc-sum.sale-VAT-rubl        + bf_doc-line-sum.sale-VAT-rubl
        bf-ext_trn-doc-sum.sale-SLT-base         = bf-ext_trn-doc-sum.sale-SLT-base        + bf_doc-line-sum.sale-SLT-base
        bf-ext_trn-doc-sum.sale-SLT-rubl         = bf-ext_trn-doc-sum.sale-SLT-rubl        + bf_doc-line-sum.sale-SLT-rubl
        bf-ext_trn-doc-sum.sale-road-tax-base    = bf-ext_trn-doc-sum.sale-road-tax-base   + bf_doc-line-sum.sale-road-tax-base
        bf-ext_trn-doc-sum.sale-road-tax-rubl    = bf-ext_trn-doc-sum.sale-road-tax-rubl   + bf_doc-line-sum.sale-road-tax-rubl
        bf-ext_trn-doc-sum.sale-excise-base      = bf-ext_trn-doc-sum.sale-excise-base     + bf_doc-line-sum.sale-excise-base
        bf-ext_trn-doc-sum.sale-excise-rubl      = bf-ext_trn-doc-sum.sale-excise-rubl     + bf_doc-line-sum.sale-excise-rubl
        bf-ext_trn-doc-sum.sale-transport-base   = bf-ext_trn-doc-sum.sale-transport-base  + bf_doc-line-sum.sale-transport-base
        bf-ext_trn-doc-sum.sale-transport-rubl   = bf-ext_trn-doc-sum.sale-transport-rubl  + bf_doc-line-sum.sale-transport-rubl
        bf-ext_trn-doc-sum.sale-other-base       = bf-ext_trn-doc-sum.sale-other-base      + bf_doc-line-sum.sale-other-base
        bf-ext_trn-doc-sum.sale-other-rubl       = bf-ext_trn-doc-sum.sale-other-rubl      + bf_doc-line-sum.sale-other-rubl
        bf-ext_trn-doc-sum.sale-discnt-base      = bf-ext_trn-doc-sum.sale-discnt-base     + bf_doc-line-sum.sale-discnt-base
        bf-ext_trn-doc-sum.sale-discnt-rubl      = bf-ext_trn-doc-sum.sale-discnt-rubl     + bf_doc-line-sum.sale-discnt-rubl
      .
    end.
    else do:
      assign
        bf-mis_trn-doc-sum.sale-sum-base         = bf-mis_trn-doc-sum.sale-sum-base        - bf_doc-line-sum.sale-sum-base
        bf-mis_trn-doc-sum.sale-sum-rubl         = bf-mis_trn-doc-sum.sale-sum-rubl        - bf_doc-line-sum.sale-sum-rubl
        bf-mis_trn-doc-sum.sale-VAT-base         = bf-mis_trn-doc-sum.sale-VAT-base        - bf_doc-line-sum.sale-VAT-base
        bf-mis_trn-doc-sum.sale-VAT-rubl         = bf-mis_trn-doc-sum.sale-VAT-rubl        - bf_doc-line-sum.sale-VAT-rubl
        bf-mis_trn-doc-sum.sale-SLT-base         = bf-mis_trn-doc-sum.sale-SLT-base        - bf_doc-line-sum.sale-SLT-base
        bf-mis_trn-doc-sum.sale-SLT-rubl         = bf-mis_trn-doc-sum.sale-SLT-rubl        - bf_doc-line-sum.sale-SLT-rubl
        bf-mis_trn-doc-sum.sale-road-tax-base    = bf-mis_trn-doc-sum.sale-road-tax-base   - bf_doc-line-sum.sale-road-tax-base
        bf-mis_trn-doc-sum.sale-road-tax-rubl    = bf-mis_trn-doc-sum.sale-road-tax-rubl   - bf_doc-line-sum.sale-road-tax-rubl
        bf-mis_trn-doc-sum.sale-excise-base      = bf-mis_trn-doc-sum.sale-excise-base     - bf_doc-line-sum.sale-excise-base
        bf-mis_trn-doc-sum.sale-excise-rubl      = bf-mis_trn-doc-sum.sale-excise-rubl     - bf_doc-line-sum.sale-excise-rubl
        bf-mis_trn-doc-sum.sale-transport-base   = bf-mis_trn-doc-sum.sale-transport-base  - bf_doc-line-sum.sale-transport-base
        bf-mis_trn-doc-sum.sale-transport-rubl   = bf-mis_trn-doc-sum.sale-transport-rubl  - bf_doc-line-sum.sale-transport-rubl
        bf-mis_trn-doc-sum.sale-other-base       = bf-mis_trn-doc-sum.sale-other-base      - bf_doc-line-sum.sale-other-base
        bf-mis_trn-doc-sum.sale-other-rubl       = bf-mis_trn-doc-sum.sale-other-rubl      - bf_doc-line-sum.sale-other-rubl
        bf-mis_trn-doc-sum.sale-discnt-base      = bf-mis_trn-doc-sum.sale-discnt-base     - bf_doc-line-sum.sale-discnt-base
        bf-mis_trn-doc-sum.sale-discnt-rubl      = bf-mis_trn-doc-sum.sale-discnt-rubl     - bf_doc-line-sum.sale-discnt-rubl
      .

    end.
    if bf_doc-line-sum.crsa-sum-base > 0 then do:
      assign
        bf-ext_trn-doc-sum.crsa-sum-base         = bf-ext_trn-doc-sum.crsa-sum-base        + bf_doc-line-sum.crsa-sum-base
        bf-ext_trn-doc-sum.crsa-sum-rubl         = bf-ext_trn-doc-sum.crsa-sum-rubl        + bf_doc-line-sum.crsa-sum-rubl
        bf-ext_trn-doc-sum.crsa-VAT-base         = bf-ext_trn-doc-sum.crsa-VAT-base        + bf_doc-line-sum.crsa-VAT-base
        bf-ext_trn-doc-sum.crsa-VAT-rubl         = bf-ext_trn-doc-sum.crsa-VAT-rubl        + bf_doc-line-sum.crsa-VAT-rubl
        bf-ext_trn-doc-sum.crsa-SLT-base         = bf-ext_trn-doc-sum.crsa-SLT-base        + bf_doc-line-sum.crsa-SLT-base
        bf-ext_trn-doc-sum.crsa-SLT-rubl         = bf-ext_trn-doc-sum.crsa-SLT-rubl        + bf_doc-line-sum.crsa-SLT-rubl
        bf-ext_trn-doc-sum.crsa-road-tax-base    = bf-ext_trn-doc-sum.crsa-road-tax-base   + bf_doc-line-sum.crsa-road-tax-base
        bf-ext_trn-doc-sum.crsa-road-tax-rubl    = bf-ext_trn-doc-sum.crsa-road-tax-rubl   + bf_doc-line-sum.crsa-road-tax-rubl
        bf-ext_trn-doc-sum.crsa-excise-base      = bf-ext_trn-doc-sum.crsa-excise-base     + bf_doc-line-sum.crsa-excise-base
        bf-ext_trn-doc-sum.crsa-excise-rubl      = bf-ext_trn-doc-sum.crsa-excise-rubl     + bf_doc-line-sum.crsa-excise-rubl
        bf-ext_trn-doc-sum.crsa-transport-base   = bf-ext_trn-doc-sum.crsa-transport-base  + bf_doc-line-sum.crsa-transport-base
        bf-ext_trn-doc-sum.crsa-transport-rubl   = bf-ext_trn-doc-sum.crsa-transport-rubl  + bf_doc-line-sum.crsa-transport-rubl
        bf-ext_trn-doc-sum.crsa-other-base       = bf-ext_trn-doc-sum.crsa-other-base      + bf_doc-line-sum.crsa-other-base
        bf-ext_trn-doc-sum.crsa-other-rubl       = bf-ext_trn-doc-sum.crsa-other-rubl      + bf_doc-line-sum.crsa-other-rubl
        bf-ext_trn-doc-sum.crsa-discnt-base      = bf-ext_trn-doc-sum.crsa-discnt-base     + bf_doc-line-sum.crsa-discnt-base
        bf-ext_trn-doc-sum.crsa-discnt-rubl      = bf-ext_trn-doc-sum.crsa-discnt-rubl     + bf_doc-line-sum.crsa-discnt-rubl
      .
    end.
    else do:
      assign
        bf-mis_trn-doc-sum.crsa-sum-base         = bf-mis_trn-doc-sum.crsa-sum-base        - bf_doc-line-sum.crsa-sum-base
        bf-mis_trn-doc-sum.crsa-sum-rubl         = bf-mis_trn-doc-sum.crsa-sum-rubl        - bf_doc-line-sum.crsa-sum-rubl
        bf-mis_trn-doc-sum.crsa-VAT-base         = bf-mis_trn-doc-sum.crsa-VAT-base        - bf_doc-line-sum.crsa-VAT-base
        bf-mis_trn-doc-sum.crsa-VAT-rubl         = bf-mis_trn-doc-sum.crsa-VAT-rubl        - bf_doc-line-sum.crsa-VAT-rubl
        bf-mis_trn-doc-sum.crsa-SLT-base         = bf-mis_trn-doc-sum.crsa-SLT-base        - bf_doc-line-sum.crsa-SLT-base
        bf-mis_trn-doc-sum.crsa-SLT-rubl         = bf-mis_trn-doc-sum.crsa-SLT-rubl        - bf_doc-line-sum.crsa-SLT-rubl
        bf-mis_trn-doc-sum.crsa-road-tax-base    = bf-mis_trn-doc-sum.crsa-road-tax-base   - bf_doc-line-sum.crsa-road-tax-base
        bf-mis_trn-doc-sum.crsa-road-tax-rubl    = bf-mis_trn-doc-sum.crsa-road-tax-rubl   - bf_doc-line-sum.crsa-road-tax-rubl
        bf-mis_trn-doc-sum.crsa-excise-base      = bf-mis_trn-doc-sum.crsa-excise-base     - bf_doc-line-sum.crsa-excise-base
        bf-mis_trn-doc-sum.crsa-excise-rubl      = bf-mis_trn-doc-sum.crsa-excise-rubl     - bf_doc-line-sum.crsa-excise-rubl
        bf-mis_trn-doc-sum.crsa-transport-base   = bf-mis_trn-doc-sum.crsa-transport-base  - bf_doc-line-sum.crsa-transport-base
        bf-mis_trn-doc-sum.crsa-transport-rubl   = bf-mis_trn-doc-sum.crsa-transport-rubl  - bf_doc-line-sum.crsa-transport-rubl
        bf-mis_trn-doc-sum.crsa-other-base       = bf-mis_trn-doc-sum.crsa-other-base      - bf_doc-line-sum.crsa-other-base
        bf-mis_trn-doc-sum.crsa-other-rubl       = bf-mis_trn-doc-sum.crsa-other-rubl      - bf_doc-line-sum.crsa-other-rubl
        bf-mis_trn-doc-sum.crsa-discnt-base      = bf-mis_trn-doc-sum.crsa-discnt-base     - bf_doc-line-sum.crsa-discnt-base
        bf-mis_trn-doc-sum.crsa-discnt-rubl      = bf-mis_trn-doc-sum.crsa-discnt-rubl     - bf_doc-line-sum.crsa-discnt-rubl
      .

    end.
    if bf_doc-line-sum.cost-sum-base > 0 then do:
      assign
        bf-ext_trn-doc-sum.cost-sum-base         = bf-ext_trn-doc-sum.cost-sum-base        + bf_doc-line-sum.cost-sum-base
        bf-ext_trn-doc-sum.cost-sum-rubl         = bf-ext_trn-doc-sum.cost-sum-rubl        + bf_doc-line-sum.cost-sum-rubl
        bf-ext_trn-doc-sum.cost-VAT-base         = bf-ext_trn-doc-sum.cost-VAT-base        + bf_doc-line-sum.cost-VAT-base
        bf-ext_trn-doc-sum.cost-VAT-rubl         = bf-ext_trn-doc-sum.cost-VAT-rubl        + bf_doc-line-sum.cost-VAT-rubl
        bf-ext_trn-doc-sum.cost-SLT-base         = bf-ext_trn-doc-sum.cost-SLT-base        + bf_doc-line-sum.cost-SLT-base
        bf-ext_trn-doc-sum.cost-SLT-rubl         = bf-ext_trn-doc-sum.cost-SLT-rubl        + bf_doc-line-sum.cost-SLT-rubl
        bf-ext_trn-doc-sum.cost-road-tax-base    = bf-ext_trn-doc-sum.cost-road-tax-base   + bf_doc-line-sum.cost-road-tax-base
        bf-ext_trn-doc-sum.cost-road-tax-rubl    = bf-ext_trn-doc-sum.cost-road-tax-rubl   + bf_doc-line-sum.cost-road-tax-rubl
        bf-ext_trn-doc-sum.cost-excise-base      = bf-ext_trn-doc-sum.cost-excise-base     + bf_doc-line-sum.cost-excise-base
        bf-ext_trn-doc-sum.cost-excise-rubl      = bf-ext_trn-doc-sum.cost-excise-rubl     + bf_doc-line-sum.cost-excise-rubl
        bf-ext_trn-doc-sum.cost-transport-base   = bf-ext_trn-doc-sum.cost-transport-base  + bf_doc-line-sum.cost-transport-base
        bf-ext_trn-doc-sum.cost-transport-rubl   = bf-ext_trn-doc-sum.cost-transport-rubl  + bf_doc-line-sum.cost-transport-rubl
        bf-ext_trn-doc-sum.cost-other-base       = bf-ext_trn-doc-sum.cost-other-base      + bf_doc-line-sum.cost-other-base
        bf-ext_trn-doc-sum.cost-other-rubl       = bf-ext_trn-doc-sum.cost-other-rubl      + bf_doc-line-sum.cost-other-rubl
        bf-ext_trn-doc-sum.cost-discnt-base      = bf-ext_trn-doc-sum.cost-discnt-base     + bf_doc-line-sum.cost-discnt-base
        bf-ext_trn-doc-sum.cost-discnt-rubl      = bf-ext_trn-doc-sum.cost-discnt-rubl     + bf_doc-line-sum.cost-discnt-rubl
      .
    end.
    else do:
      assign
        bf-mis_trn-doc-sum.cost-sum-base         = bf-mis_trn-doc-sum.cost-sum-base        - bf_doc-line-sum.cost-sum-base
        bf-mis_trn-doc-sum.cost-sum-rubl         = bf-mis_trn-doc-sum.cost-sum-rubl        - bf_doc-line-sum.cost-sum-rubl
        bf-mis_trn-doc-sum.cost-VAT-base         = bf-mis_trn-doc-sum.cost-VAT-base        - bf_doc-line-sum.cost-VAT-base
        bf-mis_trn-doc-sum.cost-VAT-rubl         = bf-mis_trn-doc-sum.cost-VAT-rubl        - bf_doc-line-sum.cost-VAT-rubl
        bf-mis_trn-doc-sum.cost-SLT-base         = bf-mis_trn-doc-sum.cost-SLT-base        - bf_doc-line-sum.cost-SLT-base
        bf-mis_trn-doc-sum.cost-SLT-rubl         = bf-mis_trn-doc-sum.cost-SLT-rubl        - bf_doc-line-sum.cost-SLT-rubl
        bf-mis_trn-doc-sum.cost-road-tax-base    = bf-mis_trn-doc-sum.cost-road-tax-base   - bf_doc-line-sum.cost-road-tax-base
        bf-mis_trn-doc-sum.cost-road-tax-rubl    = bf-mis_trn-doc-sum.cost-road-tax-rubl   - bf_doc-line-sum.cost-road-tax-rubl
        bf-mis_trn-doc-sum.cost-excise-base      = bf-mis_trn-doc-sum.cost-excise-base     - bf_doc-line-sum.cost-excise-base
        bf-mis_trn-doc-sum.cost-excise-rubl      = bf-mis_trn-doc-sum.cost-excise-rubl     - bf_doc-line-sum.cost-excise-rubl
        bf-mis_trn-doc-sum.cost-transport-base   = bf-mis_trn-doc-sum.cost-transport-base  - bf_doc-line-sum.cost-transport-base
        bf-mis_trn-doc-sum.cost-transport-rubl   = bf-mis_trn-doc-sum.cost-transport-rubl  - bf_doc-line-sum.cost-transport-rubl
        bf-mis_trn-doc-sum.cost-other-base       = bf-mis_trn-doc-sum.cost-other-base      - bf_doc-line-sum.cost-other-base
        bf-mis_trn-doc-sum.cost-other-rubl       = bf-mis_trn-doc-sum.cost-other-rubl      - bf_doc-line-sum.cost-other-rubl
        bf-mis_trn-doc-sum.cost-discnt-base      = bf-mis_trn-doc-sum.cost-discnt-base     - bf_doc-line-sum.cost-discnt-base
        bf-mis_trn-doc-sum.cost-discnt-rubl      = bf-mis_trn-doc-sum.cost-discnt-rubl     - bf_doc-line-sum.cost-discnt-rubl
      .

    end.
  end.
  if parsum-type = {&sum-general-cli-doc} then do:
    if bf_doc-line-sum.fact-qnty > 0 then do:
      assign
        bf-ext-cli_trn-doc-sum.fact-qnty             = bf-ext-cli_trn-doc-sum.fact-qnty            + bf_doc-line-sum.fact-qnty .
    end.
    else do:
      assign
        bf-mis-cli_trn-doc-sum.fact-qnty          = bf-mis-cli_trn-doc-sum.fact-qnty            - bf_doc-line-sum.fact-qnty .
    end.
    if bf_doc-line-sum.sale-sum-base > 0 then do:
      assign
        bf-ext-cli_trn-doc-sum.sale-sum-base         = bf-ext-cli_trn-doc-sum.sale-sum-base        + bf_doc-line-sum.sale-sum-base
        bf-ext-cli_trn-doc-sum.sale-sum-rubl         = bf-ext-cli_trn-doc-sum.sale-sum-rubl        + bf_doc-line-sum.sale-sum-rubl
        bf-ext-cli_trn-doc-sum.sale-VAT-base         = bf-ext-cli_trn-doc-sum.sale-VAT-base        + bf_doc-line-sum.sale-VAT-base
        bf-ext-cli_trn-doc-sum.sale-VAT-rubl         = bf-ext-cli_trn-doc-sum.sale-VAT-rubl        + bf_doc-line-sum.sale-VAT-rubl
        bf-ext-cli_trn-doc-sum.sale-SLT-base         = bf-ext-cli_trn-doc-sum.sale-SLT-base        + bf_doc-line-sum.sale-SLT-base
        bf-ext-cli_trn-doc-sum.sale-SLT-rubl         = bf-ext-cli_trn-doc-sum.sale-SLT-rubl        + bf_doc-line-sum.sale-SLT-rubl
        bf-ext-cli_trn-doc-sum.sale-road-tax-base    = bf-ext-cli_trn-doc-sum.sale-road-tax-base   + bf_doc-line-sum.sale-road-tax-base
        bf-ext-cli_trn-doc-sum.sale-road-tax-rubl    = bf-ext-cli_trn-doc-sum.sale-road-tax-rubl   + bf_doc-line-sum.sale-road-tax-rubl
        bf-ext-cli_trn-doc-sum.sale-excise-base      = bf-ext-cli_trn-doc-sum.sale-excise-base     + bf_doc-line-sum.sale-excise-base
        bf-ext-cli_trn-doc-sum.sale-excise-rubl      = bf-ext-cli_trn-doc-sum.sale-excise-rubl     + bf_doc-line-sum.sale-excise-rubl
        bf-ext-cli_trn-doc-sum.sale-transport-base   = bf-ext-cli_trn-doc-sum.sale-transport-base  + bf_doc-line-sum.sale-transport-base
        bf-ext-cli_trn-doc-sum.sale-transport-rubl   = bf-ext-cli_trn-doc-sum.sale-transport-rubl  + bf_doc-line-sum.sale-transport-rubl
        bf-ext-cli_trn-doc-sum.sale-other-base       = bf-ext-cli_trn-doc-sum.sale-other-base      + bf_doc-line-sum.sale-other-base
        bf-ext-cli_trn-doc-sum.sale-other-rubl       = bf-ext-cli_trn-doc-sum.sale-other-rubl      + bf_doc-line-sum.sale-other-rubl
        bf-ext-cli_trn-doc-sum.sale-discnt-base      = bf-ext-cli_trn-doc-sum.sale-discnt-base     + bf_doc-line-sum.sale-discnt-base
        bf-ext-cli_trn-doc-sum.sale-discnt-rubl      = bf-ext-cli_trn-doc-sum.sale-discnt-rubl     + bf_doc-line-sum.sale-discnt-rubl
      .
    end.
    else do:
      assign
        bf-mis-cli_trn-doc-sum.sale-sum-base         = bf-mis-cli_trn-doc-sum.sale-sum-base        - bf_doc-line-sum.sale-sum-base
        bf-mis-cli_trn-doc-sum.sale-sum-rubl         = bf-mis-cli_trn-doc-sum.sale-sum-rubl        - bf_doc-line-sum.sale-sum-rubl
        bf-mis-cli_trn-doc-sum.sale-VAT-base         = bf-mis-cli_trn-doc-sum.sale-VAT-base        - bf_doc-line-sum.sale-VAT-base
        bf-mis-cli_trn-doc-sum.sale-VAT-rubl         = bf-mis-cli_trn-doc-sum.sale-VAT-rubl        - bf_doc-line-sum.sale-VAT-rubl
        bf-mis-cli_trn-doc-sum.sale-SLT-base         = bf-mis-cli_trn-doc-sum.sale-SLT-base        - bf_doc-line-sum.sale-SLT-base
        bf-mis-cli_trn-doc-sum.sale-SLT-rubl         = bf-mis-cli_trn-doc-sum.sale-SLT-rubl        - bf_doc-line-sum.sale-SLT-rubl
        bf-mis-cli_trn-doc-sum.sale-road-tax-base    = bf-mis-cli_trn-doc-sum.sale-road-tax-base   - bf_doc-line-sum.sale-road-tax-base
        bf-mis-cli_trn-doc-sum.sale-road-tax-rubl    = bf-mis-cli_trn-doc-sum.sale-road-tax-rubl   - bf_doc-line-sum.sale-road-tax-rubl
        bf-mis-cli_trn-doc-sum.sale-excise-base      = bf-mis-cli_trn-doc-sum.sale-excise-base     - bf_doc-line-sum.sale-excise-base
        bf-mis-cli_trn-doc-sum.sale-excise-rubl      = bf-mis-cli_trn-doc-sum.sale-excise-rubl     - bf_doc-line-sum.sale-excise-rubl
        bf-mis-cli_trn-doc-sum.sale-transport-base   = bf-mis-cli_trn-doc-sum.sale-transport-base  - bf_doc-line-sum.sale-transport-base
        bf-mis-cli_trn-doc-sum.sale-transport-rubl   = bf-mis-cli_trn-doc-sum.sale-transport-rubl  - bf_doc-line-sum.sale-transport-rubl
        bf-mis-cli_trn-doc-sum.sale-other-base       = bf-mis-cli_trn-doc-sum.sale-other-base      - bf_doc-line-sum.sale-other-base
        bf-mis-cli_trn-doc-sum.sale-other-rubl       = bf-mis-cli_trn-doc-sum.sale-other-rubl      - bf_doc-line-sum.sale-other-rubl
        bf-mis-cli_trn-doc-sum.sale-discnt-base      = bf-mis-cli_trn-doc-sum.sale-discnt-base     - bf_doc-line-sum.sale-discnt-base
        bf-mis-cli_trn-doc-sum.sale-discnt-rubl      = bf-mis-cli_trn-doc-sum.sale-discnt-rubl     - bf_doc-line-sum.sale-discnt-rubl
      .

    end.
    if bf_doc-line-sum.crsa-sum-base > 0 then do:
      assign
        bf-ext-cli_trn-doc-sum.crsa-sum-base         = bf-ext-cli_trn-doc-sum.crsa-sum-base        + bf_doc-line-sum.crsa-sum-base
        bf-ext-cli_trn-doc-sum.crsa-sum-rubl         = bf-ext-cli_trn-doc-sum.crsa-sum-rubl        + bf_doc-line-sum.crsa-sum-rubl
        bf-ext-cli_trn-doc-sum.crsa-VAT-base         = bf-ext-cli_trn-doc-sum.crsa-VAT-base        + bf_doc-line-sum.crsa-VAT-base
        bf-ext-cli_trn-doc-sum.crsa-VAT-rubl         = bf-ext-cli_trn-doc-sum.crsa-VAT-rubl        + bf_doc-line-sum.crsa-VAT-rubl
        bf-ext-cli_trn-doc-sum.crsa-SLT-base         = bf-ext-cli_trn-doc-sum.crsa-SLT-base        + bf_doc-line-sum.crsa-SLT-base
        bf-ext-cli_trn-doc-sum.crsa-SLT-rubl         = bf-ext-cli_trn-doc-sum.crsa-SLT-rubl        + bf_doc-line-sum.crsa-SLT-rubl
        bf-ext-cli_trn-doc-sum.crsa-road-tax-base    = bf-ext-cli_trn-doc-sum.crsa-road-tax-base   + bf_doc-line-sum.crsa-road-tax-base
        bf-ext-cli_trn-doc-sum.crsa-road-tax-rubl    = bf-ext-cli_trn-doc-sum.crsa-road-tax-rubl   + bf_doc-line-sum.crsa-road-tax-rubl
        bf-ext-cli_trn-doc-sum.crsa-excise-base      = bf-ext-cli_trn-doc-sum.crsa-excise-base     + bf_doc-line-sum.crsa-excise-base
        bf-ext-cli_trn-doc-sum.crsa-excise-rubl      = bf-ext-cli_trn-doc-sum.crsa-excise-rubl     + bf_doc-line-sum.crsa-excise-rubl
        bf-ext-cli_trn-doc-sum.crsa-transport-base   = bf-ext-cli_trn-doc-sum.crsa-transport-base  + bf_doc-line-sum.crsa-transport-base
        bf-ext-cli_trn-doc-sum.crsa-transport-rubl   = bf-ext-cli_trn-doc-sum.crsa-transport-rubl  + bf_doc-line-sum.crsa-transport-rubl
        bf-ext-cli_trn-doc-sum.crsa-other-base       = bf-ext-cli_trn-doc-sum.crsa-other-base      + bf_doc-line-sum.crsa-other-base
        bf-ext-cli_trn-doc-sum.crsa-other-rubl       = bf-ext-cli_trn-doc-sum.crsa-other-rubl      + bf_doc-line-sum.crsa-other-rubl
        bf-ext-cli_trn-doc-sum.crsa-discnt-base      = bf-ext-cli_trn-doc-sum.crsa-discnt-base     + bf_doc-line-sum.crsa-discnt-base
        bf-ext-cli_trn-doc-sum.crsa-discnt-rubl      = bf-ext-cli_trn-doc-sum.crsa-discnt-rubl     + bf_doc-line-sum.crsa-discnt-rubl
      .
    end.
    else do:
      assign
        bf-mis-cli_trn-doc-sum.crsa-sum-base         = bf-mis-cli_trn-doc-sum.crsa-sum-base        - bf_doc-line-sum.crsa-sum-base
        bf-mis-cli_trn-doc-sum.crsa-sum-rubl         = bf-mis-cli_trn-doc-sum.crsa-sum-rubl        - bf_doc-line-sum.crsa-sum-rubl
        bf-mis-cli_trn-doc-sum.crsa-VAT-base         = bf-mis-cli_trn-doc-sum.crsa-VAT-base        - bf_doc-line-sum.crsa-VAT-base
        bf-mis-cli_trn-doc-sum.crsa-VAT-rubl         = bf-mis-cli_trn-doc-sum.crsa-VAT-rubl        - bf_doc-line-sum.crsa-VAT-rubl
        bf-mis-cli_trn-doc-sum.crsa-SLT-base         = bf-mis-cli_trn-doc-sum.crsa-SLT-base        - bf_doc-line-sum.crsa-SLT-base
        bf-mis-cli_trn-doc-sum.crsa-SLT-rubl         = bf-mis-cli_trn-doc-sum.crsa-SLT-rubl        - bf_doc-line-sum.crsa-SLT-rubl
        bf-mis-cli_trn-doc-sum.crsa-road-tax-base    = bf-mis-cli_trn-doc-sum.crsa-road-tax-base   - bf_doc-line-sum.crsa-road-tax-base
        bf-mis-cli_trn-doc-sum.crsa-road-tax-rubl    = bf-mis-cli_trn-doc-sum.crsa-road-tax-rubl   - bf_doc-line-sum.crsa-road-tax-rubl
        bf-mis-cli_trn-doc-sum.crsa-excise-base      = bf-mis-cli_trn-doc-sum.crsa-excise-base     - bf_doc-line-sum.crsa-excise-base
        bf-mis-cli_trn-doc-sum.crsa-excise-rubl      = bf-mis-cli_trn-doc-sum.crsa-excise-rubl     - bf_doc-line-sum.crsa-excise-rubl
        bf-mis-cli_trn-doc-sum.crsa-transport-base   = bf-mis-cli_trn-doc-sum.crsa-transport-base  - bf_doc-line-sum.crsa-transport-base
        bf-mis-cli_trn-doc-sum.crsa-transport-rubl   = bf-mis-cli_trn-doc-sum.crsa-transport-rubl  - bf_doc-line-sum.crsa-transport-rubl
        bf-mis-cli_trn-doc-sum.crsa-other-base       = bf-mis-cli_trn-doc-sum.crsa-other-base      - bf_doc-line-sum.crsa-other-base
        bf-mis-cli_trn-doc-sum.crsa-other-rubl       = bf-mis-cli_trn-doc-sum.crsa-other-rubl      - bf_doc-line-sum.crsa-other-rubl
        bf-mis-cli_trn-doc-sum.crsa-discnt-base      = bf-mis-cli_trn-doc-sum.crsa-discnt-base     - bf_doc-line-sum.crsa-discnt-base
        bf-mis-cli_trn-doc-sum.crsa-discnt-rubl      = bf-mis-cli_trn-doc-sum.crsa-discnt-rubl     - bf_doc-line-sum.crsa-discnt-rubl
      .

    end.
    if bf_doc-line-sum.cost-sum-base > 0 then do:
      assign
        bf-ext-cli_trn-doc-sum.cost-sum-base         = bf-ext-cli_trn-doc-sum.cost-sum-base        + bf_doc-line-sum.cost-sum-base
        bf-ext-cli_trn-doc-sum.cost-sum-rubl         = bf-ext-cli_trn-doc-sum.cost-sum-rubl        + bf_doc-line-sum.cost-sum-rubl
        bf-ext-cli_trn-doc-sum.cost-VAT-base         = bf-ext-cli_trn-doc-sum.cost-VAT-base        + bf_doc-line-sum.cost-VAT-base
        bf-ext-cli_trn-doc-sum.cost-VAT-rubl         = bf-ext-cli_trn-doc-sum.cost-VAT-rubl        + bf_doc-line-sum.cost-VAT-rubl
        bf-ext-cli_trn-doc-sum.cost-SLT-base         = bf-ext-cli_trn-doc-sum.cost-SLT-base        + bf_doc-line-sum.cost-SLT-base
        bf-ext-cli_trn-doc-sum.cost-SLT-rubl         = bf-ext-cli_trn-doc-sum.cost-SLT-rubl        + bf_doc-line-sum.cost-SLT-rubl
        bf-ext-cli_trn-doc-sum.cost-road-tax-base    = bf-ext-cli_trn-doc-sum.cost-road-tax-base   + bf_doc-line-sum.cost-road-tax-base
        bf-ext-cli_trn-doc-sum.cost-road-tax-rubl    = bf-ext-cli_trn-doc-sum.cost-road-tax-rubl   + bf_doc-line-sum.cost-road-tax-rubl
        bf-ext-cli_trn-doc-sum.cost-excise-base      = bf-ext-cli_trn-doc-sum.cost-excise-base     + bf_doc-line-sum.cost-excise-base
        bf-ext-cli_trn-doc-sum.cost-excise-rubl      = bf-ext-cli_trn-doc-sum.cost-excise-rubl     + bf_doc-line-sum.cost-excise-rubl
        bf-ext-cli_trn-doc-sum.cost-transport-base   = bf-ext-cli_trn-doc-sum.cost-transport-base  + bf_doc-line-sum.cost-transport-base
        bf-ext-cli_trn-doc-sum.cost-transport-rubl   = bf-ext-cli_trn-doc-sum.cost-transport-rubl  + bf_doc-line-sum.cost-transport-rubl
        bf-ext-cli_trn-doc-sum.cost-other-base       = bf-ext-cli_trn-doc-sum.cost-other-base      + bf_doc-line-sum.cost-other-base
        bf-ext-cli_trn-doc-sum.cost-other-rubl       = bf-ext-cli_trn-doc-sum.cost-other-rubl      + bf_doc-line-sum.cost-other-rubl
        bf-ext-cli_trn-doc-sum.cost-discnt-base      = bf-ext-cli_trn-doc-sum.cost-discnt-base     + bf_doc-line-sum.cost-discnt-base
        bf-ext-cli_trn-doc-sum.cost-discnt-rubl      = bf-ext-cli_trn-doc-sum.cost-discnt-rubl     + bf_doc-line-sum.cost-discnt-rubl
      .
    end.
    else do:
      assign
        bf-mis-cli_trn-doc-sum.cost-sum-base         = bf-mis-cli_trn-doc-sum.cost-sum-base        - bf_doc-line-sum.cost-sum-base
        bf-mis-cli_trn-doc-sum.cost-sum-rubl         = bf-mis-cli_trn-doc-sum.cost-sum-rubl        - bf_doc-line-sum.cost-sum-rubl
        bf-mis-cli_trn-doc-sum.cost-VAT-base         = bf-mis-cli_trn-doc-sum.cost-VAT-base        - bf_doc-line-sum.cost-VAT-base
        bf-mis-cli_trn-doc-sum.cost-VAT-rubl         = bf-mis-cli_trn-doc-sum.cost-VAT-rubl        - bf_doc-line-sum.cost-VAT-rubl
        bf-mis-cli_trn-doc-sum.cost-SLT-base         = bf-mis-cli_trn-doc-sum.cost-SLT-base        - bf_doc-line-sum.cost-SLT-base
        bf-mis-cli_trn-doc-sum.cost-SLT-rubl         = bf-mis-cli_trn-doc-sum.cost-SLT-rubl        - bf_doc-line-sum.cost-SLT-rubl
        bf-mis-cli_trn-doc-sum.cost-road-tax-base    = bf-mis-cli_trn-doc-sum.cost-road-tax-base   - bf_doc-line-sum.cost-road-tax-base
        bf-mis-cli_trn-doc-sum.cost-road-tax-rubl    = bf-mis-cli_trn-doc-sum.cost-road-tax-rubl   - bf_doc-line-sum.cost-road-tax-rubl
        bf-mis-cli_trn-doc-sum.cost-excise-base      = bf-mis-cli_trn-doc-sum.cost-excise-base     - bf_doc-line-sum.cost-excise-base
        bf-mis-cli_trn-doc-sum.cost-excise-rubl      = bf-mis-cli_trn-doc-sum.cost-excise-rubl     - bf_doc-line-sum.cost-excise-rubl
        bf-mis-cli_trn-doc-sum.cost-transport-base   = bf-mis-cli_trn-doc-sum.cost-transport-base  - bf_doc-line-sum.cost-transport-base
        bf-mis-cli_trn-doc-sum.cost-transport-rubl   = bf-mis-cli_trn-doc-sum.cost-transport-rubl  - bf_doc-line-sum.cost-transport-rubl
        bf-mis-cli_trn-doc-sum.cost-other-base       = bf-mis-cli_trn-doc-sum.cost-other-base      - bf_doc-line-sum.cost-other-base
        bf-mis-cli_trn-doc-sum.cost-other-rubl       = bf-mis-cli_trn-doc-sum.cost-other-rubl      - bf_doc-line-sum.cost-other-rubl
        bf-mis-cli_trn-doc-sum.cost-discnt-base      = bf-mis-cli_trn-doc-sum.cost-discnt-base     - bf_doc-line-sum.cost-discnt-base
        bf-mis-cli_trn-doc-sum.cost-discnt-rubl      = bf-mis-cli_trn-doc-sum.cost-discnt-rubl     - bf_doc-line-sum.cost-discnt-rubl
      .
    end.
  end.
end.
end.
end procedure. /* lib-trn2_reclctsl */

procedure lib-trn2_filinvon :
define input  parameter pariodoc-code like ub.trn-doc.doc-code   no-undo.
define input  parameter pariostatus   like ub.trn-doc.status_    no-undo.
define input  parameter parioflag     like ub.trn-doc.flag_      no-undo.
define input  parameter parchk-rsrv   as   logical               no-undo.
define input  parameter parhandle     as   handle                no-undo.
define output parameter parchg-inv    as   logical               no-undo.
define output parameter table for gds-list.

define variable variocur-qnty         like ub.doc-line.fact-qnty   no-undo.
define variable variocur-cli-qnty     like ub.doc-line.fact-qnty   no-undo.
define variable wastagevalue          as   character               no-undo.
define variable wastagetype           as   character               no-undo.
define variable varchg-inv            as   logical                 no-undo.
define variable varlns-cnt            as   integer                 no-undo.
define variable varvalue              like ub.doc-attr.attr-value  no-undo.
define variable vartype               as   character               no-undo.
define variable varvaluewt            as   character               no-undo.
define variable vartypewt             as   character               no-undo.
define variable varvalueol            as   character               no-undo.
define variable vartypeol             as   character               no-undo.
define variable is-petrol             as   logical                 no-undo.
define variable is-pieces             as   logical                 no-undo.
define variable v-density             like ub.doc-line.doc-density no-undo.

define buffer io_trn-doc              for ub.trn-doc.
define buffer io_doc-line             for ub.doc-line.
define buffer io_inv-line             for ub.inv-line.
define buffer io_goods                for ub.goods.
define buffer io_parts                for ub.parts.
define buffer io-bef_trn-doc-sum      for ub.trn-doc-sum.
define buffer io-bef-cli_trn-doc-sum  for ub.trn-doc-sum.
define buffer io-wst_trn-doc-sum      for ub.trn-doc-sum.
define buffer io-wst-cli_trn-doc-sum  for ub.trn-doc-sum.
define buffer io-bef_doc-line-sum     for ub.doc-line-sum.
define buffer io-bef-cli_doc-line-sum for ub.doc-line-sum.
define buffer io-wst_doc-line-sum     for ub.doc-line-sum.
define buffer io-wst-cli_doc-line-sum for ub.doc-line-sum.
define buffer io-aft-cli_doc-line-sum for ub.doc-line-sum.
define buffer io-aft_doc-line-sum     for ub.doc-line-sum.

define buffer buf_doc-prts for ub.doc-prts  .

define variable varinvclcspvalue as character no-undo.
define variable varinvclcsptype  as character no-undo.
define variable vartime          as integer   no-undo.
define variable varcount         as integer   no-undo.
define variable varmessage       as character no-undo.
bl-inv-on:
do transaction on error undo bl-inv-on, return error substitute( "Ошибка &1 &2 при вызове процедуры inv-on."
                                                               , return-value
                                                               , error-status :get-message( 1 ) ) :
  find first io_trn-doc where io_trn-doc.doc-code = pariodoc-code.
  /*Проверяем расширенный тип*/
  if io_trn-doc.ext-doc-type <> {&TDEDT_Inv}              and
     io_trn-doc.ext-doc-type <> {&TDEDT_Corr_Acc_Price}   and
     io_trn-doc.ext-doc-type <> {&TDEDT_Chg_Purch_Code}   and
     io_trn-doc.ext-doc-type <> {&TDEDT_Corr_Minus_Parts} and
     io_trn-doc.ext-doc-type <> {&TDEDT_Peresort}         then do:
     return error substitute( "Неверный расширенный тип документа &1.", io_trn-doc.ext-doc-type ).
  end.
  /* Проверка отсутствия резервов на товарах, кроме резервов текущей инвентаризации*/
  /* Блокировка товаров*/
  /* Фиксация в инвентаризации факт количеств, путем сложения исходных количеств и резервов */
  /* Захватываем все gds-obj перед заданием количества по строкам (было) */
  /* Проверяем отсутствие инвентаризаций в статусах "разр +" и "разр -" */
  run trg/lock-gds.p
    (input io_trn-doc.doc-code /* v-trn-doc-doc-code     */
    ,input (if io_trn-doc.ext-doc-type = {&TDEDT_Inv} then yes else no) /* p-check-inv            */
    ,input (if io_trn-doc.ext-doc-type = {&TDEDT_Inv} then yes else no) /* p-check-inv-rasr-minus */
    ,input 0                   /* p-document-fact-order  */
    ,input 0                   /* p-document-fact-order-price  */
    ,input false               /* p-fact-close           */
    ,input false               /* p-is-news              */
    ) no-error.
  if error-status :error then do:
    run waitfram-hide in parhandle no-error.
    undo bl-inv-on, return error return-value.
  end.
  assign
    io_trn-doc.doc-qnty    = 0 /* количество до инвентаризации */
    io_trn-doc.tot-calc    = 0 /* сумма в учетных вал до инвентаризации */
    io_trn-doc.discnt-rubl = 0 /* сумма в учетных р_уб до инвентаризации */
  .
    { gbl/getsect.i run io_trn-doc.obj-type io_trn-doc.obj-code {&attr-inv-obj} }
    for each thbjattr_thbj-attr :
        if thbjattr_thbj-attr.prop-code = 'invclcsp'  then varinvclcspvalue = string( thbjattr_thbj-attr.property-value-logical, "yes/no").
        if thbjattr_thbj-attr.prop-code = 'wastage'   then wastagevalue  = string( thbjattr_thbj-attr.property-value-logical, "yes/no").
    end.
    empty temp-table thbjattr_thbj-attr.
  assign
    vartime = time.
  if io_trn-doc.ext-doc-type = {&TDEDT_Inv}      or
     io_trn-doc.ext-doc-type = {&TDEDT_Peresort} then do:
    if io_trn-doc.ext-doc-type = {&TDEDT_Inv} then do:
      { str/tdat-val.i
        io_trn-doc.doc-code
        {&trdcattr-clcaswt}
        varvaluewt
        vartypewt
        no-error
      }
      if error-status :error then do:
        undo bl-inv-on, return error substitute( "Ошибка при вызове процедуры tdat-val &1 &2."
                                               , return-value
                                               , error-status :get-message( 1 ) ).
      end.
    end.
    else do:
      assign
        wastagevalue = "no":u.
    end.
    if io_trn-doc.ext-doc-type = {&TDEDT_Peresort} then do:
      assign
        varvalueol = "yes":u.
    end.
    else do:
      { str/tdat-val.i
        io_trn-doc.doc-code
        {&trdcattr-clcasol}
        varvalueol
        vartypeol
        no-error
      }
      if error-status :error then do:
        undo bl-inv-on, return error substitute( "Ошибка при вызове процедуры tdat-val &1 &2."
                                               , return-value
                                               , error-status :get-message( 1 ) ).
      end.
    end.
    assign
      varinvclcspvalue = "no".
  end.
  /*Переход из разр-. Надо пересчитать суммы "перед документом"*/
  if io_trn-doc.status_ = {&permitted} and
     not io_trn-doc.flag_              then do:
    if io_trn-doc.ext-doc-type = {&TDEDT_Inv} then do:
      run waitfram-show in parhandle ("Очистка сумм <перед документом>.").
      { str/cltrnsum.i io_trn-doc.doc-code
                   {&sum-before-doc}   no-error }
      if error-status :error then do:
        run waitfram-hide in parhandle no-error.
        undo bl-inv-on, return error return-value.
      end.
      for each io_doc-line where io_doc-line.doc-code = io_trn-doc.doc-code on error undo, return error return-value :
        { str/cllinsum.i io_doc-line.doc-code
                     {&sum-before-doc}
                     io_doc-line.artic
                     io_doc-line.prod-type
                     io_doc-line.prod-code  no-error }
        if error-status :error then do:
          run waitfram-hide in parhandle no-error.
          undo bl-inv-on, return error return-value.
        end.
      end.
      find first io-bef_trn-doc-sum where io-bef_trn-doc-sum.doc-code = io_trn-doc.doc-code and
                                          io-bef_trn-doc-sum.sum-type = {&sum-before-doc}   exclusive-lock.
      if varinvclcspvalue = "yes" then do:
        { str/cltrnsum.i io_trn-doc.doc-code
                     {&sum-before-cli-doc} no-error }
        if error-status :error then do:
          undo bl-inv-on, return error return-value.
        end.
        for each io_doc-line where io_doc-line.doc-code = io_trn-doc.doc-code on error undo, return error return-value :
          { str/cllinsum.i io_doc-line.doc-code
                       {&sum-before-cli-doc}
                       io_doc-line.artic
                       io_doc-line.prod-type
                       io_doc-line.prod-code no-error }
          if error-status :error then do:
            run waitfram-hide in parhandle no-error.
            undo bl-inv-on, return error return-value.
          end.
        end.
        find first io-bef-cli_trn-doc-sum where io-bef-cli_trn-doc-sum.doc-code = io_trn-doc.doc-code   and
                                                io-bef-cli_trn-doc-sum.sum-type = {&sum-before-cli-doc} exclusive-lock.
      end.
    end.
  end.
  else do:
    if io_trn-doc.ext-doc-type = {&TDEDT_Inv}      or
       io_trn-doc.ext-doc-type = {&TDEDT_Peresort} then do:
      { str/crtrnsum.i io_trn-doc.doc-code
                   {&sum-before-doc}   no-error }
      if error-status :error then do:
        run waitfram-hide in parhandle no-error.
        undo bl-inv-on, return error return-value.
      end.
      find first io-bef_trn-doc-sum where io-bef_trn-doc-sum.doc-code = io_trn-doc.doc-code and
                                          io-bef_trn-doc-sum.sum-type = {&sum-before-doc}   exclusive-lock.
      if varinvclcspvalue = "yes" then do:
        { str/crtrnsum.i io_trn-doc.doc-code
                     {&sum-before-cli-doc} no-error }
        if error-status :error then do:
          run waitfram-hide in parhandle no-error.
          undo bl-inv-on, return error return-value.
        end.
        find first io-bef-cli_trn-doc-sum where io-bef-cli_trn-doc-sum.doc-code = io_trn-doc.doc-code and
                                                io-bef-cli_trn-doc-sum.sum-type = {&sum-before-cli-doc}   exclusive-lock.
      end.
      /*пересчет сумм после док-та*/
      define buffer free_parts    for ub.parts  .
      define buffer out_parts     for ub.parts  .
      define buffer free_bar-code for ub.bar-code  .

      for each io_doc-line where io_doc-line.doc-code = io_trn-doc.doc-code on error undo, return error return-value :
        find first io_goods where io_goods.artic     = io_doc-line.artic     and
                                  io_goods.prod-type = io_doc-line.prod-type and
                                  io_goods.prod-code = io_doc-line.prod-code no-lock.


        for each free_parts no-lock where
                 free_parts.artic     = io_goods.artic     and
                 free_parts.prod-type = io_goods.prod-type and
                 free_parts.prod-code = io_goods.prod-code and
                 free_parts.obj-type  = io_trn-doc.obj-type and
                 free_parts.obj-code  = io_trn-doc.obj-code and
                 free_parts.out-code  = {&free-code}
                 :
            find first free_bar-code no-lock where
                       free_bar-code.in-code   = free_parts.in-code   and
                       free_bar-code.part-code = free_parts.part-code and
                       free_bar-code.gds-code  = io_goods.gds-code
                       no-error .
          if available free_bar-code then do:
             find first buf_doc-prts exclusive-lock where
                        buf_doc-prts.out-code = io_trn-doc.doc-code and
                        buf_doc-prts.b-code   = free_bar-code.b-code no-error .
             if not available buf_doc-prts then do:
                 create buf_doc-prts.
             end.
             assign
                buf_doc-prts.gds-code = free_bar-code.gds-code
                buf_doc-prts.out-code = io_trn-doc.doc-code
                buf_doc-prts.b-code   = free_bar-code.b-code
                buf_doc-prts.fact-qnty = free_parts.fact-qnty
             .
          end.
        end.
        for each out_parts no-lock where
                 out_parts.artic     = io_goods.artic     and
                 out_parts.prod-type = io_goods.prod-type and
                 out_parts.prod-code = io_goods.prod-code and
                 out_parts.obj-type  = io_trn-doc.obj-type and
                 out_parts.obj-code  = io_trn-doc.obj-code and
                 out_parts.out-code  = {&output-code}
                 :
            find first free_bar-code no-lock where
                       free_bar-code.in-code   = out_parts.in-code   and
                       free_bar-code.part-code = out_parts.part-code and
                       free_bar-code.gds-code  = io_goods.gds-code
                       no-error .
          if available free_bar-code then do:
             find first buf_doc-prts exclusive-lock where
                        buf_doc-prts.out-code = io_trn-doc.doc-code and
                        buf_doc-prts.b-code   = free_bar-code.b-code no-error .
             if not available buf_doc-prts then do:
                 create buf_doc-prts.
                  assign
                      buf_doc-prts.gds-code = free_bar-code.gds-code
                      buf_doc-prts.out-code = io_trn-doc.doc-code
                      buf_doc-prts.b-code   = free_bar-code.b-code
                      buf_doc-prts.fact-qnty = 0
                  .
             end.
          end.
        end.

        find first io-aft_doc-line-sum where io-aft_doc-line-sum.doc-code = io_doc-line.doc-code and
                                             io-aft_doc-line-sum.gds-code = io_goods.gds-code    and
                                             io-aft_doc-line-sum.sum-type = {&sum-after-doc}
                                             no-error.
        if available io-aft_doc-line-sum then do:
          { str/cctrnsum.i io_doc-line.doc-code
                       io_doc-line.artic
                       io_doc-line.prod-type
                       io_doc-line.prod-code
                       {&sum-after-doc}
                       tt-allsum-line
                       tt-doc-line-sum
                       tt-clcparts
                       temp-parts
                       no-error }
          if error-status :error then do:
            run waitfram-hide in parhandle no-error.
            undo bl-inv-on, return error substitute( "Ошибка при вызове процедуры lib-rwds_cctrnsum &1 &2 "
                                                   + "документ &3 товар &4 &5 &6"
                                                   , return-value
                                                   , error-status :get-message( 1 )
                                                   , io_trn-doc.doc-code
                                                   , io_doc-line.artic
                                                   , io_doc-line.prod-type
                                                   , io_doc-line.prod-code ).
          end.
        end.
        if varinvclcspvalue = "yes" then do:
          find first io-aft-cli_doc-line-sum where io-aft-cli_doc-line-sum.doc-code = io_doc-line.doc-code and
                                                   io-aft-cli_doc-line-sum.gds-code = io_goods.gds-code    and
                                                   io-aft-cli_doc-line-sum.sum-type = {&sum-after-cli-doc} no-error.
          if available io-aft-cli_doc-line-sum then do:
            { str/cctrnsum.i io_doc-line.doc-code
                         io_doc-line.artic
                         io_doc-line.prod-type
                         io_doc-line.prod-code
                         {&sum-after-cli-doc}
                         tt-allsum-line
                         tt-doc-line-sum
                         tt-clcparts
                         temp-parts            no-error }
            if error-status :error then do:
              run waitfram-hide in parhandle no-error.
              undo bl-inv-on, return error substitute( "Ошибка при вызове процедуры lib-rwds_cctrnsum &1 &2 "
                                                     + "документ &3 товар &4 &5 &6"
                                                     , return-value
                                                     , error-status :get-message( 1 )
                                                     , io_trn-doc.doc-code
                                                     , io_doc-line.artic
                                                     , io_doc-line.prod-type
                                                     , io_doc-line.prod-code ).
            end.
          end.
        end.
      end. /* Создание и пересчет линий */
    end. /* стандартная инвентаризация */
  end. /* накл + */
  assign
    varcount = 0.
  for each io_doc-line where io_doc-line.doc-code = io_trn-doc.doc-code on error undo bl-inv-on, return error :
    find first io_goods where io_goods.artic     = io_doc-line.artic     and
                              io_goods.prod-type = io_doc-line.prod-type and
                              io_goods.prod-code = io_doc-line.prod-code no-lock.
    assign
      varcount = varcount + 1.
    run waitfram-join in parhandle (  input "Заполнение  сумм <перед документом>."
                                   ,  input substitute( "Обработано строк: &1.", varcount )
                                   ,  input substitute( "Время: &1.", string( time - vartime, "hh:mm:ss":U ) )
                                   , output varmessage ).

    run waitfram-show in parhandle (  input varmessage ) no-error.
    { str/filinvbd.i
      io_trn-doc.ext-doc-type
      pariostatus
      parioflag
      io_trn-doc.doc-code
      io_trn-doc.obj-type
      io_trn-doc.obj-code
      io_doc-line.artic
      io_doc-line.prod-type
      io_doc-line.prod-code
      varinvclcspvalue
      varvalueol
      variocur-qnty
      variocur-cli-qnty
      no-error
    }
    if error-status :error then do:
      run waitfram-hide in parhandle no-error.
      undo bl-inv-on, return error substitute( "Ошибка при пересчете документа &1 процедурой str/filinvbd.i &2 &3"
                                             , io_trn-doc.doc-code
                                             , return-value
                                             , error-status :get-message( 1 ) ).
    end.
    { str/is-petrl.i
      io_doc-line.artic
      io_doc-line.prod-type
      io_doc-line.prod-code
      is-petrol
      is-pieces
    }
    if is-petrol = yes
      and is-pieces = no
    then do:
      /*По топливным товарам заполняем количество "было в кг"*/
      find first io_inv-line
        where io_inv-line.doc-code  = io_doc-line.doc-code
          and io_inv-line.artic     = io_doc-line.artic
          and io_inv-line.prod-type = io_doc-line.prod-type
          and io_inv-line.prod-code = io_doc-line.prod-code
        .
      assign
        io_inv-line.before-cli-qnty = variocur-cli-qnty
      .
    end.
    if io_trn-doc.ext-doc-type = {&TDEDT_Inv} then do:
      if pariostatus = {&wayb}
        and parioflag   = yes
      then do:
        assign
          io_doc-line.doc-qnty  = variocur-qnty
          io_doc-line.fact-qnty = 0
        .
        if is-petrol = yes
          and is-pieces = no
        then do:
          assign
            io_doc-line.cli-qnty        = 0
            io_inv-line.wast-cli-qnty   = io_inv-line.before-cli-qnty
          .
        end.
      end.
      else do:
        run recalc-rasr- in this-procedure
          ( input  recid(io_doc-line)
           ,input  variocur-qnty
           ,input  (if available io_inv-line then recid(io_inv-line) else ? )
           ,input  variocur-cli-qnty
           ,output varchg-inv
          ) no-error.
        if error-status :error then do:
          run waitfram-hide in parhandle no-error.
          undo bl-inv-on, return error substitute( "Ошибка при пересчете линии пересортицы: &1 &2."
                                                 , return-value
                                                 , error-status :get-message( 1 ) ).
        end.
      end.
    end.
    else do:
      if io_trn-doc.ext-doc-type = {&TDEDT_Peresort} and
         parioflag = no                              then do:
        assign
          io_doc-line.doc-qnty  = variocur-qnty + io_doc-line.fact-qnty
        .
        if is-petrol = yes
          and is-pieces = no
        then do:
          assign
            io_inv-line.wast-cli-qnty   = io_doc-line.cli-qnty + variocur-cli-qnty
          .
        end.
      end.
      else do:
        assign
          io_doc-line.doc-qnty  = variocur-qnty
          io_doc-line.fact-qnty = 0
        .
        if is-petrol = yes
          and is-pieces = no
        then do:
          assign
            io_doc-line.cli-qnty        = 0
            io_inv-line.wast-cli-qnty   = io_inv-line.before-cli-qnty
          .
        end.
      end.
    end.

    if is-petrol = yes
      and is-pieces = no
    then do:
      assign
        io_inv-line.after-cli-qnty  = io_inv-line.wast-cli-qnty
        v-density = io_inv-line.after-cli-qnty / io_doc-line.doc-qnty
      .
      if v-density = ?
        or v-density = 0.0
      then do:
        assign
          v-density = 1 / io_goods.cli-base-rate
        .
        if valid-density( v-density, (io_goods.unit-base = io_goods.unit-cli) ) <> true then do:
          undo, return error substitute(  'В карточке товара указан некорректный коэффициент единиц измерения поставщика.&1'
                                          + 'Невозможно установить плотность товара.&1'
                                          + 'Документ: &2&1'
                                          + 'Товар: &3&1'
                                          + 'Плотность: &4&1'
                                          ,{&new-line}
                                          ,io_trn-doc.doc-code
                                          ,io_goods.gds-code
                                          ,v-density
                                        ).
        end.
      end.
      assign
        io_doc-line.doc-density  = v-density
        io_doc-line.fact-density = io_doc-line.doc-density
      .
    end.

    run waitfram-show in parhandle ("Проверка возможности инвентаризации по товарам.") no-error.
    if parchk-rsrv = yes then do:
      for { str/invchkrs.i io_trn-doc.doc-code io_parts io_doc-line}
            on error undo bl-inv-on, return error
      :
        if io_trn-doc.ext-doc-type = {&TDEDT_Inv} then do:
          undo bl-inv-on, return error substitute( "Включить инвентаризацию нельзя - на товарах есть резервы. Товар &1 &2 "
                                                 + "&3. Документ &4 Список мешающих документов - на кнопке Список в докуме"
                                                 + "нте инвентаризации. Снятие по ним резервов - Главное меню / Сервис."
                                                 , io_doc-line.artic
                                                 , io_doc-line.prod-type
                                                 , io_doc-line.prod-code
                                                 , io_parts.out-code ).
        end.
        else do:
          undo bl-inv-on, return error substitute
                         ("Включить инвентаризацию нельзя - на товарах есть резервы. Товар &1 &2 &3. Документ &4.",
                         io_doc-line.artic,
                         io_doc-line.prod-type,
                         io_doc-line.prod-code,
                         io_parts.out-code).
        end.
      end.
    end.
  end.
  if io_trn-doc.ext-doc-type = {&TDEDT_Inv}      or
     io_trn-doc.ext-doc-type = {&TDEDT_Peresort} then do:
    if (io_trn-doc.ext-doc-type = {&TDEDT_Inv}      and pariostatus = {&wayb} and parioflag   = yes or
        io_trn-doc.ext-doc-type = {&TDEDT_Peresort} and pariostatus = {&wayb} and parioflag   = no     ) then do:
      /*Если начинаем с расчета сумм on-line, то создаем болванки сумм.
        general(cli)=extra(cli)=miss(cli)=wastage(cli)=0
        after(cli)=before(cli)                                                    */
      if varvalueol = "yes" then do:
        run waitfram-show in parhandle ("Создание основных сумм по документу.") no-error.
        { str/crtrnsum.i io_trn-doc.doc-code
                     {&sum-general-doc}  no-error }
        if error-status :error then do:
          run waitfram-hide in parhandle no-error.
          undo bl-inv-on, return error return-value.
        end.
        { str/crtrnsum.i io_trn-doc.doc-code
                     {&sum-extra-doc}    no-error }
        if error-status :error then do:
          run waitfram-hide in parhandle no-error.
          undo bl-inv-on, return error return-value.
        end.
        { str/crtrnsum.i io_trn-doc.doc-code
                     {&sum-miss-doc}     no-error }
        if error-status :error then do:
          run waitfram-hide in parhandle no-error.
          undo bl-inv-on, return error return-value.
        end.
        { str/crtrnsum.i io_trn-doc.doc-code
                     {&sum-after-doc}    no-error }
        if error-status :error then do:
          run waitfram-hide in parhandle no-error.
          undo bl-inv-on, return error return-value.
        end.
        if varinvclcspvalue = "yes" then do:
          { str/crtrnsum.i io_trn-doc.doc-code
                       {&sum-extra-cli-doc}   no-error }
          if error-status :error then do:
            run waitfram-hide in parhandle no-error.
            undo bl-inv-on, return error return-value.
          end.
          { str/crtrnsum.i io_trn-doc.doc-code
                       {&sum-miss-cli-doc}    no-error }
          if error-status :error then do:
            run waitfram-hide in parhandle no-error.
            undo bl-inv-on, return error return-value.
          end.
          { str/crtrnsum.i io_trn-doc.doc-code
                       {&sum-general-cli-doc} no-error }
          if error-status :error then do:
            run waitfram-hide in parhandle no-error.
            undo bl-inv-on, return error return-value.
          end.
          { str/crtrnsum.i io_trn-doc.doc-code
                       {&sum-after-cli-doc}   no-error }
          if error-status :error then do:
            run waitfram-hide in parhandle no-error.
            undo bl-inv-on, return error return-value.
          end.
        end.
        for each io_doc-line where io_doc-line.doc-code = io_trn-doc.doc-code on error undo, return error return-value :
          { str/crlinsum.i io_trn-doc.doc-code
                       {&sum-general-doc}
                       io_doc-line.artic
                       io_doc-line.prod-type
                       io_doc-line.prod-code no-error }
          if error-status :error then do:
            run waitfram-hide in parhandle no-error.
            undo bl-inv-on, return error return-value.
          end.
          if io_trn-doc.ext-doc-type = {&TDEDT_Peresort} then do:
            { str/cctrnsum.i
              io_doc-line.doc-code
              io_doc-line.artic
              io_doc-line.prod-type
              io_doc-line.prod-code
              {&sum-general-doc}
              tt-allsum-line
              tt-doc-line-sum
              tt-clcparts
              temp-parts
              no-error
            }
            if error-status :error then do:
              undo bl-inv-on, return error substitute( "Ошибка при вызове процедуры lib-rwds_cctrnsum &1 &2 документ &3 " +
                                                       "товар &4 &5 &6"
                                                       , return-value
                                                       , error-status :get-message( 1 )
                                                       , io_trn-doc.doc-code
                                                       , io_doc-line.artic
                                                       , io_doc-line.prod-type
                                                       , io_doc-line.prod-code ).
            end.
          end.
          { str/crlinsum.i io_trn-doc.doc-code
                       {&sum-after-doc}
                       io_doc-line.artic
                       io_doc-line.prod-type
                       io_doc-line.prod-code no-error }
          if error-status :error then do:
            run waitfram-hide in parhandle no-error.
            undo bl-inv-on, return error return-value.
          end.
          { str/cctrnsum.i io_doc-line.doc-code
                       io_doc-line.artic
                       io_doc-line.prod-type
                       io_doc-line.prod-code
                       {&sum-after-doc}
                       tt-allsum-line
                       tt-doc-line-sum
                       tt-clcparts
                       temp-parts            no-error }
          if error-status :error then do:
            run waitfram-hide in parhandle no-error.
            undo bl-inv-on, return error substitute( "Ошибка при вызове процедуры lib-rwds_cctrnsum &1 &2 документ &3 товар &4 &5 &6", return-value, error-status :get-message( 1 ), io_trn-doc.doc-code, io_doc-line.artic, io_doc-line.prod-type, io_doc-line.prod-code).
          end.
          if varinvclcspvalue = "yes" then do:
            { str/crlinsum.i io_trn-doc.doc-code
                         {&sum-general-cli-doc}
                         io_doc-line.artic
                         io_doc-line.prod-type
                         io_doc-line.prod-code  no-error }
            if error-status :error then do:
              run waitfram-hide in parhandle no-error.
              undo bl-inv-on, return error return-value.
            end.
            if io_trn-doc.ext-doc-type = {&TDEDT_Peresort} then do:
              { str/cctrnsum.i
                io_doc-line.doc-code
                io_doc-line.artic
                io_doc-line.prod-type
                io_doc-line.prod-code
                {&sum-general-cli-doc}
                tt-allsum-line
                tt-doc-line-sum
                tt-clcparts
                temp-parts
                no-error
              }
              if error-status :error then do:
                undo bl-inv-on, return error substitute( "Ошибка при вызове процедуры lib-rwds_cctrnsum &1 &2 документ &3 " +
                                                         "товар &4 &5 &6"
                                                         , return-value
                                                         , error-status :get-message( 1 )
                                                         , io_trn-doc.doc-code
                                                         , io_doc-line.artic
                                                         , io_doc-line.prod-type
                                                         , io_doc-line.prod-code ).
              end.
            end.
            { str/crlinsum.i io_trn-doc.doc-code
                         {&sum-after-cli-doc}
                         io_doc-line.artic
                         io_doc-line.prod-type
                         io_doc-line.prod-code no-error }
            if error-status :error then do:
              run waitfram-hide in parhandle no-error.
              undo bl-inv-on, return error return-value.
            end.
            { str/cctrnsum.i io_doc-line.doc-code
                         io_doc-line.artic
                         io_doc-line.prod-type
                         io_doc-line.prod-code
                         {&sum-after-cli-doc}
                         tt-allsum-line
                         tt-doc-line-sum
                         tt-clcparts
                         temp-parts            no-error }
            if error-status :error then do:
              run waitfram-hide in parhandle no-error.
              undo bl-inv-on, return error substitute( "Ошибка при вызове процедуры lib-rwds_cctrnsum &1 &2 документ &3 товар &4 &5 &6", return-value, error-status :get-message( 1 ), io_trn-doc.doc-code, io_doc-line.artic, io_doc-line.prod-type, io_doc-line.prod-code).
            end.
          end.
        end. /*Создание и пересчет линий*/
      end. /*Необходимо создать болванки*/
    end.
    run waitfram-show in parhandle ("Расчет сумм 'перед документом' по документу.") no-error.
    { str/reclctsl.i
      io_trn-doc.doc-code
      {&sum-before-doc}
      no-error
    }
    if error-status :error then do:
      run waitfram-hide in parhandle no-error.
      undo bl-inv-on, return error substitute( "Ошибка: <&1 &2> при вызове процедуры str/reclctsl.i для документа &3. Тип суммы &4.", return-value, error-status :get-message( 1 ), io_trn-doc.doc-code, {&sum-before-doc}).
    end.
    if varinvclcspvalue = "yes" then do:
      { str/reclctsl.i
        io_trn-doc.doc-code
        {&sum-before-cli-doc}
        no-error
      }
      if error-status :error then do:
        run waitfram-hide in parhandle no-error.
        undo bl-inv-on, return error substitute( "Ошибка: <&1 &2> при вызове процедуры str/reclctsl.i для документа &1. Тип суммы &2.", return-value, error-status :get-message( 1 ), io_trn-doc.doc-code, {&sum-before-cli-doc}).
      end.
    end.
    if varvalueol = "yes" then do:
      if io_trn-doc.ext-doc-type = {&TDEDT_Peresort} then do:
        { str/reclctsl.i
          io_trn-doc.doc-code
          {&sum-general-doc}
          no-error
        }
      end.
      { str/reclctsl.i
        io_trn-doc.doc-code
        {&sum-after-doc}
        no-error
      }
      if error-status :error then do:
        run waitfram-hide in parhandle no-error.
        undo bl-inv-on, return error return-value.
      end.
      if varinvclcspvalue = "yes" then do:
        if io_trn-doc.ext-doc-type = {&TDEDT_Peresort} then do:
          { str/reclctsl.i
            io_trn-doc.doc-code
            {&sum-general-cli-doc}
            no-error
          }
        end.
        { str/reclctsl.i
          io_trn-doc.doc-code
          {&sum-after-cli-doc}
          no-error
        }
        if error-status :error then do:
          run waitfram-hide in parhandle no-error.
          undo bl-inv-on, return error return-value.
        end.
      end.
    end.
    if io_trn-doc.status_ = {&permitted} and
       not io_trn-doc.flag_              then do:
      if wastagevalue = "yes" and
         varvaluewt   = "yes" then do:
        run waitfram-show in parhandle ("Очистка сумм <естественная убыль>.").
        { str/cltrnsum.i io_trn-doc.doc-code
                     {&sum-wastage-doc}  no-error }
        if error-status :error then do:
          run waitfram-hide in parhandle no-error.
          undo bl-inv-on, return error return-value.
        end.
        find first io-wst_trn-doc-sum where io-wst_trn-doc-sum.doc-code = io_trn-doc.doc-code and
                                            io-wst_trn-doc-sum.sum-type = {&sum-wastage-doc}  exclusive-lock.
        for each io_doc-line where io_doc-line.doc-code = io_trn-doc.doc-code on error undo, return error return-value :
          { str/cllinsum.i io_doc-line.doc-code
                       {&sum-wastage-doc}
                       io_doc-line.artic
                       io_doc-line.prod-type
                       io_doc-line.prod-code  no-error }
          if error-status :error then do:
            run waitfram-hide in parhandle no-error.
            undo bl-inv-on, return error return-value.
          end.
        end.
        if varinvclcspvalue = "yes" then do:
          { str/cltrnsum.i io_trn-doc.doc-code
                       {&sum-wastage-cli-doc} no-error }
          if error-status :error then do:
            run waitfram-hide in parhandle no-error.
            undo bl-inv-on, return error return-value.
          end.
          find first io-wst-cli_trn-doc-sum where io-wst-cli_trn-doc-sum.doc-code = io_trn-doc.doc-code    and
                                                  io-wst-cli_trn-doc-sum.sum-type = {&sum-wastage-cli-doc} exclusive-lock.
          for each io_doc-line where io_doc-line.doc-code = io_trn-doc.doc-code on error undo, return error return-value :
            { str/cllinsum.i io_doc-line.doc-code
                         {&sum-wastage-cli-doc}
                         io_doc-line.artic
                         io_doc-line.prod-type
                         io_doc-line.prod-code  no-error }
            if error-status :error then do:
              run waitfram-hide in parhandle no-error.
              undo bl-inv-on, return error return-value.
            end.
          end.
        end.
      end.
    end.
    else do:
      if wastagevalue = "yes" and
         varvaluewt   = "yes" then do:
        run waitfram-show in parhandle ("Создание сумм естественной убыли по документу.") no-error.
        { str/crtrnsum.i io_trn-doc.doc-code
                     {&sum-wastage-doc}  no-error }
        if error-status :error then do:
          run waitfram-hide in parhandle no-error.
          undo bl-inv-on, return error return-value.
        end.

        find first io-wst_trn-doc-sum where io-wst_trn-doc-sum.doc-code = io_trn-doc.doc-code and
                                            io-wst_trn-doc-sum.sum-type = {&sum-wastage-doc}  exclusive-lock.
        for each io_doc-line where io_doc-line.doc-code = io_trn-doc.doc-code on error undo, return error return-value :
          { str/crlinsum.i io_doc-line.doc-code
                       {&sum-wastage-doc}
                       io_doc-line.artic
                       io_doc-line.prod-type
                       io_doc-line.prod-code no-error }
          if error-status :error then do:
            run waitfram-hide in parhandle no-error.
            undo bl-inv-on, return error return-value.
          end.
        end.
        if varinvclcspvalue = "yes" then do:
          { str/crtrnsum.i io_trn-doc.doc-code
                       {&sum-wastage-cli-doc} no-error }
          if error-status :error then do:
            run waitfram-hide in parhandle no-error.
            undo bl-inv-on, return error return-value.
          end.
          find first io-wst-cli_trn-doc-sum where io-wst-cli_trn-doc-sum.doc-code = io_trn-doc.doc-code   and
                                                  io-wst-cli_trn-doc-sum.sum-type = {&sum-wastage-cli-doc} exclusive-lock.
          for each io_doc-line where io_doc-line.doc-code = io_trn-doc.doc-code on error undo, return error return-value :
            { str/crlinsum.i io_doc-line.doc-code
                         {&sum-wastage-cli-doc}
                         io_doc-line.artic
                         io_doc-line.prod-type
                         io_doc-line.prod-code no-error }
            if error-status :error then do:
              run waitfram-hide in parhandle no-error.
              undo bl-inv-on, return error return-value.
            end.
          end.
        end.
      end.
    end.
    /*Подсчет фонда естественной убыли при реализации в магазине*/
    if wastagevalue = "yes" and
       varvaluewt   = "yes" then do:
      run waitfram-show in parhandle ("Расчет естественной убыли по документу.") no-error.
      { str/ccwstsum.i io_trn-doc.doc-code
                   parhandle
                   tt-wast-line        no-error }
      if error-status :error then do:
         run waitfram-hide in parhandle no-error.
         undo bl-inv-on, return error substitute( "Ошибка &1 &2 при расчете норм естественной убыли.",
                                                  return-value,
                                                  error-status :get-message( 1 ) ).
      end.
      { str/reclctsl.i
        io_trn-doc.doc-code
        {&sum-wastage-doc}
        no-error
      }
      if error-status :error then do:
         run waitfram-hide in parhandle no-error.
         undo bl-inv-on, return error substitute( "Ошибка &1 &2 при записи в шапку документа естественной убыли.",
                                      return-value,
                                      error-status :get-message( 1 ) ).
      end.
      if varinvclcspvalue = "yes" then do:
        { str/reclctsl.i
          io_trn-doc.doc-code
          {&sum-wastage-cli-doc}
          no-error
        }
        if error-status :error then do:
           run waitfram-hide in parhandle no-error.
           undo bl-inv-on, return error substitute( "Ошибка &1 &2 при записи в шапку документа естественной убыли.",
                                        return-value,
                                        error-status :get-message( 1 ) ).
        end.
      end.
    end.
  end.
end.
run waitfram-hide in parhandle no-error.
end procedure. /* lib-trn2_filinvon */

procedure lib-trn2_filinvln :
define input  parameter pariodoc-code   like ub.doc-line.doc-code   no-undo.
define input  parameter parioartic      like ub.doc-line.artic      no-undo.
define input  parameter parioprod-type  like ub.doc-line.prod-type  no-undo.
define input  parameter parioprod-code  like ub.doc-line.prod-code  no-undo.
define input  parameter parhandle       as   handle                 no-undo.

define variable variocur-qnty         like ub.doc-line.fact-qnty  no-undo.
define variable variocur-cli-qnty     like ub.doc-line.fact-qnty  no-undo.
define variable wastagevalue          as   character              no-undo.
define variable wastagetype           as   character              no-undo.
define variable varchg-inv            as   logical                no-undo.
define variable varlns-cnt            as   integer                no-undo.
define variable varvalue              like ub.doc-attr.attr-value no-undo.
define variable vartype               as   character              no-undo.
define variable varvaluewt            as   character              no-undo.
define variable vartypewt             as   character              no-undo.
define variable varvalueol            as   character              no-undo.
define variable vartypeol             as   character              no-undo.
define buffer io_trn-doc              for ub.trn-doc.
define buffer io_doc-line             for ub.doc-line.
define buffer io_goods                for ub.goods.
define buffer io_parts                for ub.parts.
define buffer io-bef_trn-doc-sum      for ub.trn-doc-sum.
define buffer io-bef-cli_trn-doc-sum  for ub.trn-doc-sum.
define buffer io-wst_trn-doc-sum      for ub.trn-doc-sum.
define buffer io-wst-cli_trn-doc-sum  for ub.trn-doc-sum.
define buffer io-bef_doc-line-sum     for ub.doc-line-sum.
define buffer io-bef-cli_doc-line-sum for ub.doc-line-sum.
define buffer io-wst_doc-line-sum     for ub.doc-line-sum.
define buffer io-wst-cli_doc-line-sum for ub.doc-line-sum.
define buffer io-aft-cli_doc-line-sum for ub.doc-line-sum.
define buffer io-aft_doc-line-sum     for ub.doc-line-sum.
define variable varinvclcspvalue as character no-undo.
define variable varinvclcsptype  as character no-undo.
define variable vartime          as integer   no-undo.
define variable varcount         as integer   no-undo.
define variable varmessage       as character no-undo.
bl-inv-on:
do transaction on error undo bl-inv-on, return error substitute( "Ошибка &1 &2 при вызове процедуры filinvln.", return-value, error-status :get-message( 1 ) ):
  find first io_trn-doc  where io_trn-doc.doc-code =  pariodoc-code.
  find first io_doc-line where io_doc-line.doc-code  = io_trn-doc.doc-code and
                               io_doc-line.artic     = parioartic          and
                               io_doc-line.prod-type = parioprod-type      and
                               io_doc-line.prod-code = parioprod-code      .
  find first io_goods where io_goods.artic     = io_doc-line.artic     and
                            io_goods.prod-type = io_doc-line.prod-type and
                            io_goods.prod-code = io_doc-line.prod-code no-lock.
  /*Проверяем расширенный тип*/
  if not ( io_trn-doc.ext-doc-type = {&TDEDT_Inv}      or
           io_trn-doc.ext-doc-type = {&TDEDT_Peresort} )
     then do:
     return error substitute( "Неверный расширенный тип документа &1.", io_trn-doc.ext-doc-type).
  end.
  /* Проверка отсутствия резервов на товарах, кроме резервов текущей инвентаризации*/
  /* Блокировка товаров*/
  /* Фиксация в инвентаризации факт количеств, путем сложения исходных количеств и резервов */
  /* Захватываем все gds-obj перед заданием количества по строкам (было) */
  /* Проверяем отсутствие инвентаризаций в статусах "разр +" и "разр -" */
  run trg/lock-gds.p
    (input io_trn-doc.doc-code /* v-trn-doc-doc-code     */
    ,input yes                 /* p-check-inv            */
    ,input yes                 /* p-check-inv-rasr-minus */
    ,input 0                   /* p-document-fact-order  */
    ,input 0                   /* p-document-fact-order-price  */
    ,input false               /* p-fact-close           */
    ,input false               /* p-is-news              */
    ) no-error.
  if error-status :error then do:
    undo bl-inv-on, return error return-value.
  end.
  assign
    vartime = time.
    { gbl/getsect.i run io_trn-doc.obj-type io_trn-doc.obj-code {&attr-inv-obj} }
    for each thbjattr_thbj-attr :
        if thbjattr_thbj-attr.prop-code = 'invclcsp'  then varinvclcspvalue = string( thbjattr_thbj-attr.property-value-logical, "yes/no").
        if thbjattr_thbj-attr.prop-code = 'wastage'   then wastagevalue  = string( thbjattr_thbj-attr.property-value-logical, "yes/no").
    end.
    empty temp-table thbjattr_thbj-attr.
  { str/tdat-val.i io_trn-doc.doc-code
               {&trdcattr-clcaswt}
               varvaluewt
               vartypewt  no-error }
  if error-status :error then do:
    undo bl-inv-on, return error substitute( "Ошибка при вызове процедуры tdat-val &1 &2."
                                           , return-value
                                           , error-status :get-message( 1 ) ).
  end.
  { str/tdat-val.i io_trn-doc.doc-code
               {&trdcattr-clcasol}
               varvalueol
               vartypeol  no-error }
  if error-status :error then do:
    undo bl-inv-on, return error substitute( "Ошибка при вызове процедуры tdat-val &1 &2."
                                           , return-value
                                           , error-status :get-message( 1 ) ).
  end.


  find first io-bef_trn-doc-sum where io-bef_trn-doc-sum.doc-code = io_trn-doc.doc-code and
                                      io-bef_trn-doc-sum.sum-type = {&sum-before-doc}   exclusive-lock.
  if varinvclcspvalue = "yes" then do:
    find first io-bef-cli_trn-doc-sum where io-bef-cli_trn-doc-sum.doc-code = io_trn-doc.doc-code   and
                                            io-bef-cli_trn-doc-sum.sum-type = {&sum-before-cli-doc} exclusive-lock.
  end.
  if varinvclcspvalue = "yes" then do:
    find first io-bef-cli_trn-doc-sum where io-bef-cli_trn-doc-sum.doc-code = io_trn-doc.doc-code and
                                            io-bef-cli_trn-doc-sum.sum-type = {&sum-before-cli-doc}   exclusive-lock.
  end.
  { str/filinvbd.i
    io_trn-doc.ext-doc-type
    {&wayb}
    yes
    io_trn-doc.doc-code
    io_trn-doc.obj-type
    io_trn-doc.obj-code
    io_doc-line.artic
    io_doc-line.prod-type
    io_doc-line.prod-code
    varinvclcspvalue
    varvalueol
    variocur-qnty
    variocur-cli-qnty
    no-error
  }
  if error-status :error then do:
    undo bl-inv-on, return error substitute( "Ошибка при пересчете документа &1 процедурой str/filinvbd.i &2 &3", io_trn-doc.doc-code, return-value, error-status :get-message( 1 ) ).
  end.
  if varvalueol = "yes" then do:
    { str/crlinsum.i io_trn-doc.doc-code
                 {&sum-general-doc}
                 io_doc-line.artic
                 io_doc-line.prod-type
                 io_doc-line.prod-code no-error }
    if error-status :error then do:
      undo bl-inv-on, return error return-value.
    end.
    { str/crlinsum.i io_trn-doc.doc-code
                 {&sum-after-doc}
                 io_doc-line.artic
                 io_doc-line.prod-type
                 io_doc-line.prod-code no-error }
    if error-status :error then do:
      undo bl-inv-on, return error return-value.
    end.
    { str/cctrnsum.i io_doc-line.doc-code
                 io_doc-line.artic
                 io_doc-line.prod-type
                 io_doc-line.prod-code
                 {&sum-after-doc}
                 tt-allsum-line
                 tt-doc-line-sum
                 tt-clcparts
                 temp-parts            no-error }
    if error-status :error then do:
      undo bl-inv-on, return error substitute( "Ошибка при вызове процедуры lib-rwds_cctrnsum &1 &2 документ &3 товар &4 &5 &6", return-value, error-status :get-message( 1 ), io_trn-doc.doc-code, io_doc-line.artic, io_doc-line.prod-type, io_doc-line.prod-code).
    end.
    if varinvclcspvalue = "yes" then do:
      { str/crlinsum.i io_trn-doc.doc-code
                   {&sum-general-cli-doc}
                   io_doc-line.artic
                   io_doc-line.prod-type
                   io_doc-line.prod-code  no-error }
      if error-status :error then do:
        undo bl-inv-on, return error return-value.
      end.
      { str/crlinsum.i io_trn-doc.doc-code
                   {&sum-after-cli-doc}
                   io_doc-line.artic
                   io_doc-line.prod-type
                   io_doc-line.prod-code  no-error }
      if error-status :error then do:
        undo bl-inv-on, return error return-value.
      end.
      { str/cctrnsum.i io_doc-line.doc-code
                   io_doc-line.artic
                   io_doc-line.prod-type
                   io_doc-line.prod-code
                   {&sum-after-cli-doc}
                   tt-allsum-line
                   tt-doc-line-sum
                   tt-clcparts
                   temp-parts            no-error }
      if error-status :error then do:
        undo bl-inv-on, return error substitute( "Ошибка при вызове процедуры lib-rwds_cctrnsum &1 &2 документ &3 товар &4 &5 &6", return-value, error-status :get-message( 1 ), io_trn-doc.doc-code, io_doc-line.artic, io_doc-line.prod-type, io_doc-line.prod-code).
      end.
    end.
  end. /*Необходимо создать болванки*/
  { str/reclctsl.i
    io_trn-doc.doc-code
    {&sum-before-doc}
    no-error
  }
  if error-status :error then do:
    undo bl-inv-on, return error substitute( "Ошибка: <&1 &2> при вызове процедуры str/reclctsl.i для документа &3. Тип суммы &4.", return-value, error-status :get-message( 1 ), io_trn-doc.doc-code, {&sum-before-doc}).
  end.
  if varinvclcspvalue = "yes" then do:
    { str/reclctsl.i
      io_trn-doc.doc-code
      {&sum-before-cli-doc}
      no-error
    }
    if error-status :error then do:
      undo bl-inv-on, return error substitute( "Ошибка: <&1 &2> при вызове процедуры str/reclctsl.i для документа &1. Тип суммы &2.", return-value, error-status :get-message( 1 ), io_trn-doc.doc-code, {&sum-before-cli-doc}).
    end.
  end.
  if varvalueol = "yes" then do:
    { str/reclctsl.i
      io_trn-doc.doc-code
      {&sum-after-doc}
      no-error
    }
    if error-status :error then do:
      undo bl-inv-on, return error return-value.
    end.
    if varinvclcspvalue = "yes" then do:
      { str/reclctsl.i
        io_trn-doc.doc-code
        {&sum-after-cli-doc}
        no-error
      }
      if error-status :error then do:
        undo bl-inv-on, return error return-value.
      end.
    end.
  end.
  if wastagevalue = "yes" and
     varvaluewt   = "yes" then do:
    find first io-wst_trn-doc-sum where io-wst_trn-doc-sum.doc-code = io_trn-doc.doc-code and
                                        io-wst_trn-doc-sum.sum-type = {&sum-wastage-doc}  exclusive-lock.
    { str/crlinsum.i io_doc-line.doc-code
                 {&sum-wastage-doc}
                 io_doc-line.artic
                 io_doc-line.prod-type
                 io_doc-line.prod-code no-error }
    if error-status :error then do:
      undo bl-inv-on, return error return-value.
    end.
    if varinvclcspvalue = "yes" then do:
      find first io-wst-cli_trn-doc-sum where io-wst-cli_trn-doc-sum.doc-code = io_trn-doc.doc-code   and
                                              io-wst-cli_trn-doc-sum.sum-type = {&sum-wastage-cli-doc} exclusive-lock.
      { str/crlinsum.i io_doc-line.doc-code
                   {&sum-wastage-cli-doc}
                   io_doc-line.artic
                   io_doc-line.prod-type
                   io_doc-line.prod-code  no-error }
      if error-status :error then do:
        undo bl-inv-on, return error return-value.
      end.
    end.
  end.
  if wastagevalue = "yes" and
     varvaluewt   = "yes" then do:
    { str/ccwstsum.i io_trn-doc.doc-code
                 parhandle
                 tt-wast-line        no-error }
    if error-status :error then do:
       undo bl-inv-on, return error substitute( "Ошибка &1 &2 при расчете норм естественной убыли.",
                                                return-value,
                                                error-status :get-message( 1 ) ).
    end.
    { str/reclctsl.i
      io_trn-doc.doc-code
      {&sum-wastage-doc}
      no-error
    }
    if error-status :error then do:
       undo bl-inv-on, return error substitute( "Ошибка &1 &2 при записи в шапку документа естественной убыли.",
                                    return-value,
                                    error-status :get-message( 1 ) ).
    end.
    if varinvclcspvalue = "yes" then do:
      { str/reclctsl.i
        io_trn-doc.doc-code
        {&sum-wastage-cli-doc}
        no-error
      }
      if error-status :error then do:
         undo bl-inv-on, return error substitute( "Ошибка &1 &2 при записи в шапку документа естественной убыли.",
                                      return-value,
                                      error-status :get-message( 1 ) ).
      end.
    end.
  end.
end.
end procedure. /* lib-trn2_filinvln */

procedure lib-trn2_filinvbd :
  define input parameter  par-cb-ext-doc-type like ub.trn-doc.ext-doc-type    no-undo.
  define input parameter  par-cb-status       like ub.trn-doc.doc-code        no-undo.
  define input parameter  par-cb-flag         like ub.trn-doc.flag_           no-undo.
  define input parameter  par-cb-doc-code     like ub.trn-doc.doc-code        no-undo.
  define input parameter  par-cb-obj-type     like ub.trn-doc.obj-type        no-undo.
  define input parameter  par-cb-obj-code     like ub.trn-doc.obj-code        no-undo.
  define input parameter  par-cb-artic        like ub.doc-line.artic          no-undo.
  define input parameter  par-cb-prod-type    like ub.doc-line.prod-type      no-undo.
  define input parameter  par-cb-prod-code    like ub.doc-line.prod-code      no-undo.
  define input parameter  parinvclcspvalue    as   character                  no-undo.
  define input parameter  parvalueol          as   character                  no-undo.
  define output parameter parcur-qnty         like ub.doc-line.fact-qnty       no-undo.
  define output parameter parcur-cli-qnty     like ub.inv-line.before-cli-qnty no-undo.

  do
  on error undo, return error return-value
  :
    define variable vartot-doc              like ub.trn-doc.doc-code  no-undo.
    define variable vartot-rubl             like ub.trn-doc.tot-rubl  no-undo.
    define variable v-ts-doc-line_tot-ov    like ub.trn-doc.tot-ov    no-undo.
    define variable v-ts-doc-line_fact-rubl like ub.trn-doc.fact-rubl no-undo.
    define variable v-ts-doc-line_fact-base like ub.trn-doc.fact-base no-undo.
    define variable v-ts-doc-line_fact-qnty like ub.trn-doc.fact-qnty no-undo.
    define variable v-ts-doc-line_doc-qnty  like ub.trn-doc.doc-qnty  no-undo.
    define variable v-ts-doc-line_cli-qnty  like ub.trn-doc.cli-qnty  no-undo.
    define variable varfact-date            as date      no-undo.
    define variable varfact-time            as integer   no-undo.
    define variable varfact-num             as integer   no-undo.
    define variable varshift-date           as date      no-undo.
    define variable varshift-num            as integer   no-undo.
    define variable varshift-on             as logical   no-undo.
    define variable varfact-order           as decimal   no-undo.
    define variable varshift-fo             as decimal   no-undo.
    define variable varday-fo               as decimal   no-undo.
    define variable v-pl-qnty               as decimal   no-undo.
    define variable v-pl-cli-qnty           as decimal   no-undo.
    define variable v-reserv-pl             as logical   no-undo .
    define variable v-rowid                 as rowid     no-undo .
    define variable is-petrol               as logical   no-undo.
    define variable is-pieces               as logical   no-undo.
    define variable v-day                   as date      no-undo .
    define variable v-ok                    as logical   no-undo .
    define variable v-value                 as character no-undo .

    define buffer cb_gds-obj    for ub.gds-obj.
    define buffer cb_trn-doc    for ub.trn-doc.
    define buffer cb_doc-line   for ub.doc-line.
    define buffer cb_inv-line   for ub.inv-line .
    define buffer cb_prt-obj    for ub.prt-obj.
    define buffer cb_gds-dtl    for ub.gds-dtl.
    define buffer cb_doc-pl     for ub.doc-pl.
    define buffer cb_goods      for ub.goods .
    define buffer cb_pl-gds     for ub.pl-gds .
    define buffer prev_doc-line for ub.doc-line .
    define buffer prev_inv-line for ub.inv-line .

  /* считаем количество и сумму в учетных ценах по документу ДО инвентаризации */
    find first cb_trn-doc
      where cb_trn-doc.doc-code = par-cb-doc-code
      .
    find first cb_doc-line
      where cb_doc-line.doc-code  = cb_trn-doc.doc-code
        and cb_doc-line.artic     = par-cb-artic
        and cb_doc-line.prod-type = par-cb-prod-type
        and cb_doc-line.prod-code = par-cb-prod-code
      .

    find first cb_goods
      where cb_goods.artic     = par-cb-artic
        and cb_goods.prod-type = par-cb-prod-type
        and cb_goods.prod-code = par-cb-prod-code
      .

    { gbl/gdsobjat.i
      cb_doc-line.obj-type
      cb_doc-line.obj-code
      cb_doc-line.artic
      cb_doc-line.prod-type
      cb_doc-line.prod-code
      "'place-rsrv=request'"
      v-reserv-pl
    }
    { str/is-petrl.i
      cb_doc-line.artic
      cb_doc-line.prod-type
      cb_doc-line.prod-code
      is-petrol
      is-pieces
    }

    if cb_trn-doc.fact-date = ? then do:
      assign
        varfact-order = ?
      .
      find first cb_gds-obj
          where cb_gds-obj.obj-type  = par-cb-obj-type
            and cb_gds-obj.obj-code  = par-cb-obj-code
            and cb_gds-obj.artic     = par-cb-artic
            and cb_gds-obj.prod-type = par-cb-prod-type
            and cb_gds-obj.prod-code = par-cb-prod-code
          no-error .
      if available cb_gds-obj then do:
        assign
          cb_trn-doc.doc-qnty    = cb_trn-doc.doc-qnty    + cb_gds-obj.fact-qnty
          cb_trn-doc.tot-calc    = cb_trn-doc.tot-calc    + cb_gds-obj.fact-base
          cb_trn-doc.discnt-rubl = cb_trn-doc.discnt-rubl + cb_gds-obj.fact-rubl
          parcur-qnty            = cb_gds-obj.fact-qnty.
      end.
      else do:
        assign
          parcur-qnty = cb_gds-obj.fact-qnty.
      end.
      if cb_trn-doc.ext-doc-type = {&TDEDT_Peresort} then do:
        for each cb_gds-dtl exclusive-lock
          where cb_gds-dtl.doc-code  = cb_doc-line.doc-code
            and cb_gds-dtl.artic     = cb_doc-line.artic
            and cb_gds-dtl.prod-type = cb_doc-line.prod-type
            and cb_gds-dtl.prod-code = cb_doc-line.prod-code
        on error undo, return error return-value
        :
          find first cb_prt-obj
            where cb_prt-obj.obj-type  = par-cb-obj-type
              and cb_prt-obj.obj-code  = par-cb-obj-code
              and cb_prt-obj.artic     = par-cb-artic
              and cb_prt-obj.prod-type = par-cb-prod-type
              and cb_prt-obj.prod-code = par-cb-prod-code
              and cb_prt-obj.prt-code  = cb_gds-dtl.prt-code
            no-error.
          if available cb_prt-obj then do:
            assign
              cb_gds-dtl.fact-qnty = cb_gds-dtl.doc-qnty + cb_prt-obj.fact-qnty
            .
          end.
          else do:
            assign
              cb_gds-dtl.fact-qnty = cb_gds-dtl.doc-qnty
            .
          end.
        end.
      end.
      if v-reserv-pl = true then do:
        for each cb_pl-gds share-lock
          where cb_pl-gds.gds-code  = cb_goods.gds-code
            and cb_pl-gds.obj-type  = cb_doc-line.obj-type
            and cb_pl-gds.obj-code  = cb_doc-line.obj-code
        on error undo, return error return-value
        :
          run placelib_get-attr  ( input {&place-com-tanks}
                                  ,input cb_pl-gds.obj-code
                                  ,input cb_pl-gds.obj-type
                                  ,input cb_pl-gds.pl-code
                                  ,output v-value
                                  ,output v-ok      ) no-error.
    
          if  v-ok
          and v-value > ""
          then do :
            run placelib_get-attr  ( input {&place-is-main}
                                    ,input cb_pl-gds.obj-code
                                    ,input cb_pl-gds.obj-type
                                    ,input cb_pl-gds.pl-code
                                    ,output v-value
                                    ,output v-ok      ) no-error.
            if v-ok and logical(v-value)
            then do :
              
            end .
            else do :
              next .
            end .                        
          end .
          { str/crdocpl.i
            cb_doc-line.doc-code
            cb_pl-gds.gds-code
            cb_pl-gds.pl-code
            cb_pl-gds.obj-type
            cb_pl-gds.obj-code
            v-rowid
          }
          find first cb_doc-pl exclusive-lock
            where rowid(cb_doc-pl) = v-rowid
            .
          assign
            cb_doc-pl.rest-bf-qnty     = cb_pl-gds.fact-qnty
            cb_doc-pl.cli-rest-bf-qnty = cb_pl-gds.cli-fact-qnty
          .
        end.
      end.
    end. /* if cb_trn-doc.fact-date = ? */
    else do:
      assign
        varfact-date  = cb_trn-doc.fact-date
        varfact-time  = cb_trn-doc.fact-time
        varfact-num   = current-value( s-trn-fact, {&db-name_schema} ) + 1
        varshift-date = cb_trn-doc.shift-date
        varshift-num  = cb_trn-doc.shift-num
      .
      { gbl/objat.i
        cb_trn-doc.obj-type
        cb_trn-doc.obj-code
        "'shift-on=request'"
        varshift-on
        no-error
      }
      if error-status :error or
        varshift-on = ? then do:
        assign
          varshift-date = ?
          varshift-num  = 0
          varshift-on   = no
        .
      end.
      if varfact-time = ? or
         varfact-time = 0 then do:
        /* return error substitute ("Установлена фактическая дата закрытия документа задним числом, но не установлено фактическое время. Номер документа: &1.", cb_trn-doc.doc-code).*/
        run cur-time in this-procedure
          ( output v-day
           ,output varfact-time
          ) .
      end.
      if varshift-on = yes then do:
        if varshift-date = ? then do:
          return error substitute ("Установлена фактическая дата закрытия документа задним числом, но не установлена дата смены. Номер документа: &1.", cb_trn-doc.doc-code).
        end.
        if varshift-num = 0 or
          varshift-num = ? then do:
          return error substitute ("Установлена фактическая дата закрытия документа задним числом, но не установлен номер смены. Номер документа: &1.", cb_trn-doc.doc-code).
        end.
      end. /* v-shift-on */
      run factord in this-procedure
        ( input varfact-date
         ,input varfact-time
         ,input varfact-num
         ,input varshift-date
         ,input varshift-num
         ,input varshift-on
         ,output varfact-order
         ,output varshift-fo
         ,output varday-fo
        ) no-error.

      if error-status:error then do:
        return error substitute ("Ошибка при определении fact-order для документа закрываемого задним числом. Дата документа &1 время &2 фактический номер &3 дата смены &4 номер смены &5.",
                                varfact-date,
                                varfact-time,
                                varfact-num,
                                varshift-date,
                                varshift-num).
      end.
      for each temp-prt-obj
      on error undo, return error return-value
      :
        delete temp-prt-obj.
      end.
      run prdoclib-init-prt-obj-by-factord in this-procedure
        ( input cb_doc-line.obj-type
         ,input cb_doc-line.obj-code
         ,input cb_doc-line.artic
         ,input cb_doc-line.prod-type
         ,input cb_doc-line.prod-code
         ,input varfact-order
         ,input true
        ) no-error.
      if error-status:error then do:
        return error substitute ("Документ &1. Ошибка при расчете остатка по признакам товара &2.", cb_doc-line.doc-code, return-value).
      end.
      assign
        parcur-qnty = 0.0
      .
      for each temp-prt-obj
      on error undo, return error return-value
      :
        assign
          parcur-qnty = parcur-qnty + temp-prt-obj.fact-qnty
        .
      end.
      for each cb_gds-dtl exclusive-lock
        where cb_gds-dtl.doc-code  = cb_doc-line.doc-code
          and cb_gds-dtl.artic     = cb_doc-line.artic
          and cb_gds-dtl.prod-type = cb_doc-line.prod-type
          and cb_gds-dtl.prod-code = cb_doc-line.prod-code
      on error undo, return error return-value
      :
        find first temp-prt-obj
          where temp-prt-obj.prt-code = cb_gds-dtl.prt-code
          no-error.
        if available temp-prt-obj then do:
          assign
            cb_gds-dtl.fact-qnty = cb_gds-dtl.doc-qnty + temp-prt-obj.fact-qnty.
        end.
        else do:
          assign
            cb_gds-dtl.fact-qnty = cb_gds-dtl.doc-qnty.
        end.
      end.

      if v-reserv-pl = true then do:
        run prdoclib-init-pl-gds-by-factord in this-procedure
          ( input cb_doc-line.obj-type
           ,input cb_doc-line.obj-code
           ,input cb_doc-line.artic
           ,input cb_doc-line.prod-type
           ,input cb_doc-line.prod-code
           ,input varfact-order
           ,input true
          ) no-error.
        if error-status:error then do:
          return error substitute ("Документ &2.&1Ошибка при расчете остатка по местам хранения товара.&1&3.", {&new-line}, cb_doc-line.doc-code, return-value).
        end.
        for each temp-pl-gds
        on error undo, return error return-value
        :
          run placelib_get-attr  ( input {&place-com-tanks}
                                  ,input temp-pl-gds.obj-code
                                  ,input temp-pl-gds.obj-type
                                  ,input temp-pl-gds.pl-code
                                  ,output v-value
                                  ,output v-ok      ) no-error.
    
          if  v-ok
          and v-value > ""
          then do :
            run placelib_get-attr  ( input {&place-is-main}
                                    ,input temp-pl-gds.obj-code
                                    ,input temp-pl-gds.obj-type
                                    ,input temp-pl-gds.pl-code
                                    ,output v-value
                                    ,output v-ok      ) no-error.
            if v-ok and logical(v-value)
            then do :
              
            end .
            else do :
              next .
            end .                        
          end .
          { str/crdocpl.i
            cb_doc-line.doc-code
            temp-pl-gds.gds-code
            temp-pl-gds.pl-code
            temp-pl-gds.obj-type
            temp-pl-gds.obj-code
            v-rowid
          }
          find first cb_doc-pl exclusive-lock
            where rowid(cb_doc-pl) = v-rowid
            .
          assign
            cb_doc-pl.rest-bf-qnty     = temp-pl-gds.fact-qnty
            cb_doc-pl.cli-rest-bf-qnty = temp-pl-gds.cli-fact-qnty
          .
        end.
      end. /* if v-reserv-pl = true */
    end. /* if cb_trn-doc.fact-date <> ? */

    if v-reserv-pl = true then do:
      assign
        v-pl-qnty     = 0.0
        v-pl-cli-qnty = 0.0
      .
      for each cb_doc-pl exclusive-lock
        where cb_doc-pl.out-code = cb_doc-line.doc-code
          and cb_doc-pl.gds-code = cb_goods.gds-code
          and cb_doc-pl.obj-type = cb_doc-line.obj-type
          and cb_doc-pl.obj-code = cb_doc-line.obj-code
      on error undo, return error return-value
      :
        find first cb_pl-gds share-lock
          where cb_pl-gds.obj-type = cb_doc-pl.obj-type
            and cb_pl-gds.obj-code = cb_doc-pl.obj-code
            and cb_pl-gds.pl-code  = cb_doc-pl.pl-code
            and cb_pl-gds.gds-code = cb_doc-pl.gds-code
          no-error .
        if not available cb_pl-gds then do:
          delete cb_doc-pl.
        end.
        else do:
          assign
            cb_doc-pl.rest-af-qnty     = cb_doc-pl.rest-bf-qnty     + (if cb_doc-pl.fact-qnty <> ? then cb_doc-pl.fact-qnty else 0.0)
            cb_doc-pl.cli-rest-af-qnty = cb_doc-pl.cli-rest-bf-qnty + (if cb_doc-pl.cli-fact-qnty <> ? then cb_doc-pl.cli-fact-qnty else 0.0)
            v-pl-qnty                  = v-pl-qnty     + cb_doc-pl.rest-bf-qnty
            v-pl-cli-qnty              = v-pl-cli-qnty + cb_doc-pl.cli-rest-bf-qnty
          .
        end.
      end.
      if v-pl-qnty <> parcur-qnty then do:
        return error substitute( "Документ &2.&1"
                                + "Ошибка при расчете остатка по местам хранения товара.&1"
                                + "Товар: &3&1"
                                + "Остаток по товару: &4 (&6)&1"
                                + "Остаток по местам хранения: &5 (&6)&1"
                                ,{&new-line}
                                ,cb_doc-line.doc-code
                                ,cb_goods.gds-code
                                ,parcur-qnty
                                ,v-pl-qnty
                                ,cb_goods.unit-base
                                ).
      end.
      if is-petrol = yes
        and is-pieces = no
      then do:
        /*По топливным товарам заполняем количество "было в кг"*/
        find first cb_inv-line
          where cb_inv-line.doc-code  = cb_doc-line.doc-code
            and cb_inv-line.artic     = cb_doc-line.artic
            and cb_inv-line.prod-type = cb_doc-line.prod-type
            and cb_inv-line.prod-code = cb_doc-line.prod-code
          .
        assign /* выставляем значения по умолчанию */
          parcur-cli-qnty = 0.0
        .
        if varfact-order = ? then do:
          find last prev_doc-line no-lock
            where prev_doc-line.obj-type   = cb_doc-line.obj-type
              and prev_doc-line.obj-code   = cb_doc-line.obj-code
              and prev_doc-line.prod-type  = cb_doc-line.prod-type
              and prev_doc-line.prod-code  = cb_doc-line.prod-code
              and prev_doc-line.artic      = cb_doc-line.artic
              and prev_doc-line.status_    = {&fact}
              and prev_doc-line.fact-order > 0
            use-index fact-order
            no-error.
        end.
        else do:
          find last prev_doc-line no-lock
            where prev_doc-line.obj-type   = cb_doc-line.obj-type
              and prev_doc-line.obj-code   = cb_doc-line.obj-code
              and prev_doc-line.prod-type  = cb_doc-line.prod-type
              and prev_doc-line.prod-code  = cb_doc-line.prod-code
              and prev_doc-line.artic      = cb_doc-line.artic
              and prev_doc-line.status_    = {&fact}
              and prev_doc-line.fact-order > 0
              and prev_doc-line.fact-order < varfact-order
            use-index fact-order
            no-error.
        end.
        if available prev_doc-line then do:
          find first prev_inv-line no-lock
            where prev_inv-line.doc-code  = prev_doc-line.doc-code
              and prev_inv-line.artic     = prev_doc-line.artic
              and prev_inv-line.prod-code = prev_doc-line.prod-code
              and prev_inv-line.prod-type = prev_doc-line.prod-type
            no-error.
          if available prev_inv-line then do:
            assign
              parcur-cli-qnty = prev_inv-line.after-cli-qnty
            .
            if parcur-cli-qnty <> v-pl-cli-qnty and abs (v-pl-cli-qnty - parcur-cli-qnty) <= 0.001 /* коррекция накопленной погрешности */ 
            then do:
              for last cb_doc-pl exclusive-lock
                where cb_doc-pl.out-code = cb_doc-line.doc-code
                  and cb_doc-pl.gds-code = cb_goods.gds-code
                  and cb_doc-pl.obj-type = cb_doc-line.obj-type
                  and cb_doc-pl.obj-code = cb_doc-line.obj-code
              on error undo, return error return-value
              :
                  assign
                    cb_doc-pl.cli-rest-bf-qnty = cb_doc-pl.cli-rest-bf-qnty - (v-pl-cli-qnty - parcur-cli-qnty)
                    v-pl-cli-qnty = v-pl-cli-qnty -  (v-pl-cli-qnty - parcur-cli-qnty) 
                  .
              end.
            end.
          end.
        end.
        if parcur-cli-qnty <> v-pl-cli-qnty then do:
          return error substitute( "Документ &2.&1"
                                  + "Ошибка при расчете остатка по местам хранения товара.&1"
                                  + "Товар: &3&1"
                                  + "Остаток по товару: &4 (&6)&1"
                                  + "Остаток по местам хранения: &5 (&6)&1"
                                  ,{&new-line}
                                  ,cb_doc-line.doc-code
                                  ,cb_goods.gds-code
                                  ,parcur-cli-qnty
                                  ,v-pl-cli-qnty
                                  ,cb_goods.unit-cli
                                  ).
        end.
      end.
    end. /* if v-reserv-pl = true */

    if par-cb-ext-doc-type = {&TDEDT_Inv}      or
      par-cb-ext-doc-type = {&TDEDT_Peresort} then do:
      if (par-cb-ext-doc-type = {&TDEDT_Inv}      and par-cb-status = {&wayb} and par-cb-flag   = yes or
          par-cb-ext-doc-type = {&TDEDT_Peresort} and par-cb-status = {&wayb} and par-cb-flag   = no    ) then do:
        { str/crlinsum.i cb_trn-doc.doc-code
                      {&sum-before-doc}
                      cb_doc-line.artic
                      cb_doc-line.prod-type
                      cb_doc-line.prod-code no-error }
        if error-status :error then do:
          return error substitute( "&1 &2", return-value, error-status :get-message( 1 ) ).
        end.
        if parinvclcspvalue = "yes" then do:
          { str/crlinsum.i cb_trn-doc.doc-code
                        {&sum-before-cli-doc}
                        cb_doc-line.artic
                        cb_doc-line.prod-type
                        cb_doc-line.prod-code no-error }
          if error-status :error then do:
            return error substitute( "&1 &2", return-value, error-status :get-message( 1 ) ).
          end.
        end.
        if parinvclcspvalue = "yes" then do:
          { str/cctrnsum.i cb_trn-doc.doc-code
                        cb_doc-line.artic
                        cb_doc-line.prod-type
                        cb_doc-line.prod-code
                        "'{&bef-sum-before-doc},{&bef-sum-before-cli-doc}':U"
                        tt-allsum-line
                        tt-doc-line-sum
                        tt-clcparts
                        temp-parts            no-error }
          if error-status :error then do:
            return error substitute( "&1 &2", return-value, error-status :get-message( 1 ) ).
          end.
        end.
        else do:
          { str/cctrnsum.i cb_trn-doc.doc-code
                        cb_doc-line.artic
                        cb_doc-line.prod-type
                        cb_doc-line.prod-code
                        {&sum-before-doc}
                        tt-allsum-line
                        tt-doc-line-sum
                        tt-clcparts
                        temp-parts            no-error }
          if error-status :error then do:
            return error substitute( "&1 &2", return-value, error-status :get-message( 1 ) ).
          end.
        end.
      end.
      else do:
        /* разр- */
        if cb_trn-doc.status_ = {&permitted} and
          cb_trn-doc.flag_   = no      then do:
          if parvalueol = "yes" then do:
            if parinvclcspvalue = "yes" then do:
              { str/cctrnsum.i cb_trn-doc.doc-code
                          cb_doc-line.artic
                          cb_doc-line.prod-type
                          cb_doc-line.prod-code
                          "'{&bef-sum-before-doc},{&bef-sum-before-cli-doc},{&bef-sum-general-doc},{&bef-sum-general-cli-doc},{&bef-sum-after-doc},{&bef-sum-after-cli-doc}':U"
                          tt-allsum-line
                          tt-doc-line-sum
                          tt-clcparts
                          temp-parts            no-error }
              if error-status :error then undo, return error substitute( "&1 &2", return-value, error-status :get-message( 1 ) ).
            end.
            else do:
              { str/cctrnsum.i cb_trn-doc.doc-code
                          cb_doc-line.artic
                          cb_doc-line.prod-type
                          cb_doc-line.prod-code
                          "'{&bef-sum-before-doc},{&bef-sum-general-doc},{&bef-sum-after-doc}':U"
                          tt-allsum-line
                          tt-doc-line-sum
                          tt-clcparts
                          temp-parts            no-error }
              if error-status :error then undo, return error substitute( "&1 &2", return-value, error-status :get-message( 1 ) ).
            end.
          end.
          else do:
            if parinvclcspvalue = "yes" then do:
              { str/cctrnsum.i cb_trn-doc.doc-code
                          cb_doc-line.artic
                          cb_doc-line.prod-type
                          cb_doc-line.prod-code
                          "'{&bef-sum-before-doc},{&bef-sum-before-cli-doc}':U"
                          tt-allsum-line
                          tt-doc-line-sum
                          tt-clcparts
                          temp-parts            no-error }
              if error-status :error then undo, return error substitute( "&1 &2", return-value, error-status :get-message( 1 ) ).
            end.
            else do:
              { str/cctrnsum.i cb_trn-doc.doc-code
                          cb_doc-line.artic
                          cb_doc-line.prod-type
                          cb_doc-line.prod-code
                          "'{&bef-sum-before-doc}':U"
                          tt-allsum-line
                          tt-doc-line-sum
                          tt-clcparts
                          temp-parts                  no-error }
              if error-status :error then undo, return error substitute( "&1 &2", return-value, error-status :get-message( 1 ) ).
            end.

          end.
          /* пересчитываем учетные цены излишки-недостачи, записываем правильное "стало" */
          { str/acc-cost.i
            cb_doc-line.obj-type
            cb_doc-line.obj-code
            cb_doc-line.doc-code
            cb_doc-line.artic
            cb_doc-line.prod-type
            cb_doc-line.prod-code
            cb_doc-line.cli-qnty
            cb_doc-line.doc-qnty
            cb_doc-line.fact-qnty
            cb_doc-line.price-base
            cb_doc-line.price-rubl
            "''"
            v-ts-doc-line_tot-ov
            v-ts-doc-line_fact-rubl
            v-ts-doc-line_fact-base
            v-ts-doc-line_fact-qnty
            v-ts-doc-line_doc-qnty
            v-ts-doc-line_cli-qnty
            no-error
            }
          if error-status :error then do:
            return error substitute( "&1 &2", return-value, error-status :get-message( 1 ) ).
          end.
          /* пересчитываем продажные цены, записываем правильное "стало" */
          { str/clclninv.i
            recid(cb_doc-line)
            no
            "''"
            vartot-doc
            vartot-rubl
            no-error
            }
          if error-status :error then do:
            return error return-value.
          end.
        end.
      end.
    end.
  end.
end procedure. /* lib-trn2_filinvbd */

procedure recalc-rasr- :
define input parameter  par-rc-doc-line      as   recid                 no-undo.
define input parameter  par-rc-cur-qnty      like ub.doc-line.fact-qnty no-undo.
define input parameter  par-rc-inv-line      as   recid                 no-undo.
define input parameter  par-rc-cur-cli-qnty  like ub.doc-line.fact-qnty no-undo.
define output parameter par-rc-chg-inv       as   logical               no-undo.

do
on error undo, return error return-value
:
  define variable var-rc-cur-qnty     like ub.doc-line.fact-qnty no-undo.
  define variable var-rc-cur-cli-qnty like ub.doc-line.fact-qnty no-undo.

  define buffer rc_doc-line for ub.doc-line.
  define buffer rc_inv-line for ub.inv-line.
  define buffer rc_gds-dtl  for ub.gds-dtl.
  define buffer rc_prt-obj  for ub.prt-obj.
  define buffer rc_doc-pl   for ub.doc-pl.
  define buffer rc_pl-gds   for ub.pl-gds.
  define buffer rc_goods    for ub.goods.

  for each gds-list :
    delete gds-list.
  end.
  find first rc_doc-line where recid(rc_doc-line) = par-rc-doc-line.
  if par-rc-inv-line <> ? then do:
    find first rc_inv-line where recid(rc_inv-line) = par-rc-inv-line.
  end.
  find rc_goods no-lock
    where rc_goods.artic     = rc_doc-line.artic
      and rc_goods.prod-type = rc_doc-line.prod-type
      and rc_goods.prod-code = rc_doc-line.prod-code
  .
  /*РАЗРЕШЕН-*/
  if rc_doc-line.doc-qnty <> par-rc-cur-qnty + rc_doc-line.fact-qnty then do:
    assign par-rc-chg-inv = yes.
    { cmp/gds-list.i gds-list assign " " rc_goods }
    /* поэтому заново пересчитываем doc-line.doc-qnty на основе резервов */
    assign
      rc_doc-line.doc-qnty = par-rc-cur-qnty + rc_doc-line.fact-qnty
    .
    if available rc_inv-line then do:
      assign
        rc_inv-line.wast-cli-qnty   = rc_doc-line.cli-qnty + par-rc-cur-cli-qnty
      .
    end.
  end.
  for each rc_gds-dtl exclusive-lock
    where rc_gds-dtl.doc-code  = rc_doc-line.doc-code
      and rc_gds-dtl.artic     = rc_doc-line.artic
      and rc_gds-dtl.prod-code = rc_doc-line.prod-code
      and rc_gds-dtl.prod-type = rc_doc-line.prod-type
  on error undo, return error return-value
  :
    find rc_prt-obj no-lock
      where rc_prt-obj.obj-type   = rc_doc-line.obj-type
        and rc_prt-obj.obj-code   = rc_doc-line.obj-code
        and rc_prt-obj.artic      = rc_doc-line.artic
        and rc_prt-obj.prod-type  = rc_doc-line.prod-type
        and rc_prt-obj.prod-code  = rc_doc-line.prod-code
        and rc_prt-obj.prt-code   = rc_gds-dtl.prt-code
      no-error .
    if available rc_prt-obj then do:
      assign
        var-rc-cur-qnty = rc_prt-obj.fact-qnty
      .
    end.
    else do:
      assign
        var-rc-cur-qnty = 0
      .
    end.
    if rc_gds-dtl.fact-qnty <> var-rc-cur-qnty + rc_gds-dtl.doc-qnty then do:
      if par-rc-chg-inv <> yes then do:
        assign par-rc-chg-inv = yes.
        { cmp/gds-list.i gds-list assign " " rc_goods }
      end.
      /* поэтому заново пересчитываем doc-line.doc-qnty на основе резервов */
      assign
        rc_gds-dtl.fact-qnty = var-rc-cur-qnty + rc_gds-dtl.doc-qnty
      .
    end.
  end.
  for each rc_doc-pl exclusive-lock
    where rc_doc-pl.out-code = rc_doc-line.doc-code
      and rc_doc-pl.gds-code = rc_goods.gds-code
  on error undo, return error return-value
  :
    find first rc_pl-gds no-lock
      where rc_pl-gds.obj-type   = rc_doc-line.obj-type
        and rc_pl-gds.obj-code   = rc_doc-line.obj-code
        and rc_pl-gds.pl-code    = rc_doc-pl.pl-code
        and rc_pl-gds.gds-code   = rc_goods.gds-code
      no-error .
    if available rc_pl-gds then do:
      assign
        var-rc-cur-qnty     = rc_pl-gds.fact-qnty
        var-rc-cur-cli-qnty = rc_pl-gds.cli-fact-qnty
      .
    end.
    else do:
      assign
        var-rc-cur-qnty     = 0.0
        var-rc-cur-cli-qnty = 0.0
      .
    end.
    if rc_doc-pl.rest-af-qnty <> var-rc-cur-qnty + rc_doc-pl.doc-qnty
      or rc_doc-pl.cli-rest-af-qnty <> var-rc-cur-cli-qnty + rc_doc-pl.cli-doc-qnty
    then do:
      if par-rc-chg-inv <> yes then do:
        assign par-rc-chg-inv = yes.
        { cmp/gds-list.i gds-list assign " " rc_goods }
      end.
      /* поэтому заново пересчитываем doc-line.doc-qnty на основе резервов */
      assign
        rc_doc-pl.rest-bf-qnty     = var-rc-cur-qnty
        rc_doc-pl.cli-rest-bf-qnty = var-rc-cur-cli-qnty
        rc_doc-pl.rest-af-qnty     = rc_doc-pl.rest-bf-qnty + rc_doc-pl.doc-qnty
        rc_doc-pl.cli-rest-af-qnty = rc_doc-pl.cli-rest-bf-qnty + rc_doc-pl.cli-doc-qnty
      .
    end.
  end.
end.
end procedure. /* recalc-rasr- */

procedure lib-trn2_reclcinv :
  define input parameter work-mode   as   character           no-undo.
  define input parameter parrec-line as   recid               no-undo.
  define input parameter pardoc-code like ub.trn-doc.doc-code no-undo.

  /* Когда редактирование или удаление, то старое значение по строке приходит как input parameter.
     В случае "old" это output parameters. */
  define input-output parameter vartot-docold                       like ub.trn-doc.tot-doc            no-undo.
  define input-output parameter vartot-rublold                      like ub.trn-doc.tot-rubl           no-undo.
  define input-output parameter i-total-doc-line_tot-ovold          like ub.trn-doc.tot-ov             no-undo.
  define input-output parameter i-total-doc-line_fact-rublold       like ub.trn-doc.fact-rubl          no-undo.
  define input-output parameter i-total-doc-line_fact-baseold       like ub.trn-doc.fact-base          no-undo.
  define input-output parameter i-total-doc-line_fact-qntyold       like ub.trn-doc.fact-qnty          no-undo.
  define input-output parameter i-total-doc-line_doc-qntyold        like ub.trn-doc.doc-qnty           no-undo.
  define input-output parameter i-total-doc-line_cli-qntyold        like ub.trn-doc.cli-qnty           no-undo.
  define input-output parameter i-total-parts_fact-baseold          as   decimal                       no-undo.
  define input-output parameter i-total-parts_fact-rublold          as   decimal                       no-undo.
  define input-output parameter i-total-parts_fact-qntyold          as   decimal                       no-undo.

  define variable vartot-docnew                       like ub.trn-doc.tot-doc            no-undo.
  define variable vartot-rublnew                      like ub.trn-doc.tot-rubl           no-undo.
  define variable i-total-doc-line_tot-ovnew          like ub.trn-doc.tot-ov             no-undo.
  define variable i-total-doc-line_fact-rublnew       like ub.trn-doc.fact-rubl          no-undo.
  define variable i-total-doc-line_fact-basenew       like ub.trn-doc.fact-base          no-undo.
  define variable i-total-doc-line_fact-qntynew       like ub.trn-doc.fact-qnty          no-undo.
  define variable i-total-doc-line_doc-qntynew        like ub.trn-doc.doc-qnty           no-undo.
  define variable i-total-doc-line_cli-qntynew        like ub.trn-doc.cli-qnty           no-undo.
  define variable i-total-parts_fact-basenew          as   decimal                       no-undo.
  define variable i-total-parts_fact-rublnew          as   decimal                       no-undo.
  define variable i-total-parts_fact-qntynew          as   decimal                       no-undo.
  define variable varvalueol                          as   character                     no-undo.
  define variable vartypeol                           as   character                     no-undo.
  define variable varr-b                              as   character                     no-undo.

  define buffer rc_trn-doc           for ub.trn-doc.
  define buffer rc_doc-line          for ub.doc-line.
  define buffer rc_goods             for ub.goods.
  define buffer rc-old_doc-line-sum  for ub.doc-line-sum.

  do on error undo, return error return-value :
    find first rc_doc-line where recid(rc_doc-line)  = parrec-line.
    find first rc_trn-doc  where rc_trn-doc.doc-code = pardoc-code.
    find first rc_goods    where
               rc_goods.artic      = rc_doc-line.artic     and
               rc_goods.prod-type  = rc_doc-line.prod-type and
               rc_goods.prod-code  = rc_doc-line.prod-code no-error.
    if not available rc_goods then do:
      return error substitute( "Не найден товар &1 &2 &3", rc_goods.artic, rc_goods.prod-type, rc_goods.prod-code ).
    end.

    define variable varinvclcspvalue as character no-undo.
    { gbl/getsect.i run rc_trn-doc.obj-type rc_trn-doc.obj-code {&attr-inv-obj} }
    for each thbjattr_thbj-attr :
        if thbjattr_thbj-attr.prop-code = 'invclcsp'  then varinvclcspvalue = string( thbjattr_thbj-attr.property-value-logical, "yes/no").
    end.
    empty temp-table thbjattr_thbj-attr.

    if work-mode = "old":u then do:
      assign
        vartot-docold             = 0
        vartot-rublold            = 0 .
      if rc_trn-doc.ext-doc-type = {&TDEDT_Inv}      or
         rc_trn-doc.ext-doc-type = {&TDEDT_Peresort} then do:
        for each tt-old-doc-line-sum where
                 tt-old-doc-line-sum.doc-code  = rc_doc-line.doc-code  and
                 tt-old-doc-line-sum.gds-code  = rc_goods.gds-code     on error undo, return error return-value :
          delete tt-old-doc-line-sum.
        end.

        for each rc-old_doc-line-sum where
                 rc-old_doc-line-sum.doc-code  = rc_doc-line.doc-code  and
                 rc-old_doc-line-sum.gds-code  = rc_goods.gds-code     on error undo, return error return-value :
          create tt-old-doc-line-sum.
          buffer-copy rc-old_doc-line-sum to tt-old-doc-line-sum.
        end.
      end.
      { str/clclninv.i
          recid(rc_doc-line)
          no
          "'old'"
          vartot-docold
          vartot-rublold
          no-error
      }
      assign
        i-total-doc-line_tot-ovold       = 0
        i-total-doc-line_fact-rublold    = 0
        i-total-doc-line_fact-baseold    = 0
        i-total-doc-line_fact-qntyold    = 0
        i-total-doc-line_doc-qntyold     = 0
        i-total-doc-line_cli-qntyold     = 0
        i-total-parts_fact-baseold       = 0
        i-total-parts_fact-rublold       = 0
        i-total-parts_fact-qntyold       = 0
      .
      { str/acc-cost.i
          rc_doc-line.obj-type
          rc_doc-line.obj-code
          rc_doc-line.doc-code
          rc_doc-line.artic
          rc_doc-line.prod-type
          rc_doc-line.prod-code
          rc_doc-line.cli-qnty
          rc_doc-line.doc-qnty
          rc_doc-line.fact-qnty
          rc_doc-line.price-base
          rc_doc-line.price-rubl
          "'old':u"
          i-total-doc-line_tot-ovold
          i-total-doc-line_fact-rublold
          i-total-doc-line_fact-baseold
          i-total-doc-line_fact-qntyold
          i-total-doc-line_doc-qntyold
          i-total-doc-line_cli-qntyold
          no-error
      }
      if error-status :error then do:
        message
          "Ошибка при обсчете документа инвентаризации." skip
          return-value skip
          trim( error-status :get-message( 1 ) )
        view-as alert-box error.
        undo, return error .
      end.
    end.
    if work-mode = "update":u or
       work-mode = "delete":u then do:
      assign
        vartot-docnew             = 0
        vartot-rublnew            = 0
        .

      if rc_trn-doc.status_ = {&fact} then do:
        assign
          varvalueol = "yes".
      end.
      else do:
        if rc_trn-doc.status_ = {&permitted} then do:
          { str/tdat-val.i rc_doc-line.doc-code
                       {&trdcattr-clcasol}
                       varvalueol
                       vartypeol  no-error }
          if error-status :error then do:
            return error return-value.
          end.
        end.
        else do:
          assign
            varvalueol = "no".
        end.
      end.

      if work-mode = "update":u then do:
        { str/clclninv.i
            recid(rc_doc-line)
            yes
            "'new'"
            vartot-docnew
            vartot-rublnew
          no-error }
        if error-status :error then do:
          message
            "Ошибка при обсчете линии документа инвентаризации." skip
            return-value skip
            trim( error-status :get-message( 1 ) )
          view-as alert-box error.
          undo, return error .
        end.
      end.
      if varr-b = "rubl":u then do:
        assign
          rc_trn-doc.tot-rubl = rc_trn-doc.tot-rubl + vartot-rublnew - vartot-rublold
          rc_trn-doc.tot-doc  = rc_trn-doc.tot-rubl / rc_trn-doc.base-rate * rc_trn-doc.base-scale
        .
      end.
      else do:
        assign
          rc_trn-doc.tot-doc  = rc_trn-doc.tot-doc + vartot-docnew - vartot-docold
          rc_trn-doc.tot-rubl = rc_trn-doc.tot-doc * rc_trn-doc.base-rate / rc_trn-doc.base-scale
        .
      end.

      if varvalueol = "yes" and
         (rc_trn-doc.ext-doc-type = {&TDEDT_Inv} or rc_trn-doc.ext-doc-type = {&TDEDT_Peresort}) then do:
        if work-mode = "update":u then do:
          { str/cllinsum.i rc_doc-line.doc-code
                       {&sum-general-doc}
                       rc_doc-line.artic
                       rc_doc-line.prod-type
                       rc_doc-line.prod-code no-error }
          if error-status :error then do:
            return error return-value.
          end.
          { str/cllinsum.i rc_doc-line.doc-code
                       {&sum-after-doc}
                       rc_doc-line.artic
                       rc_doc-line.prod-type
                       rc_doc-line.prod-code no-error }
          if error-status :error then do:
            return error return-value.
          end.

          if varinvclcspvalue = "yes" then do:
            { str/cllinsum.i rc_doc-line.doc-code
                         {&sum-general-cli-doc}
                         rc_doc-line.artic
                         rc_doc-line.prod-type
                         rc_doc-line.prod-code no-error }
            if error-status :error then do:
              return error return-value.
            end.
            { str/cllinsum.i rc_doc-line.doc-code
                         {&sum-after-cli-doc}
                         rc_doc-line.artic
                         rc_doc-line.prod-type
                         rc_doc-line.prod-code no-error }
            if error-status :error then do:
              return error return-value.
            end.
          end.
          { str/ttdlsdel.i rc_doc-line.doc-code
                       rc_doc-line.artic
                       rc_doc-line.prod-type
                       rc_doc-line.prod-code
                       tt-doc-line-sum       no-error }
          if error-status :error then do:
            undo, return error return-value.
          end.
          if varinvclcspvalue = "yes" then do:
            { str/cctrnsum.i rc_doc-line.doc-code
                         rc_doc-line.artic
                         rc_doc-line.prod-type
                         rc_doc-line.prod-code
                         "'{&bef-sum-general-doc},{&bef-sum-general-cli-doc},{&bef-sum-after-doc},{&bef-sum-after-cli-doc}':U"
                         tt-allsum-line
                         tt-doc-line-sum
                         tt-clcparts
                         temp-parts                  no-error }
            if error-status :error then do:
              return error return-value.
            end.
          end.
          else do:
            { str/cctrnsum.i rc_doc-line.doc-code
                         rc_doc-line.artic
                         rc_doc-line.prod-type
                         rc_doc-line.prod-code
                         "'{&bef-sum-general-doc},{&bef-sum-after-doc}':U"
                         tt-allsum-line
                         tt-doc-line-sum
                         tt-clcparts
                         temp-parts                  no-error }
            if error-status :error then do:
              return error return-value.
            end.
          end.
        end.
        { str/updtrsum.i rc_doc-line.doc-code
                     rc_doc-line.artic
                     rc_doc-line.prod-type
                     rc_doc-line.prod-code
                     work-mode
                     tt-allsum-line
                     tt-doc-line-sum
                     tt-old-doc-line-sum   no-error }
        if error-status :error then do:
          return error return-value.
        end.
      end.
      assign
        i-total-doc-line_tot-ovnew       = 0
        i-total-doc-line_fact-rublnew    = 0
        i-total-doc-line_fact-basenew    = 0
        i-total-doc-line_fact-qntynew    = 0
        i-total-doc-line_doc-qntynew     = 0
        i-total-doc-line_cli-qntynew     = 0
        i-total-parts_fact-basenew       = 0
        i-total-parts_fact-rublnew       = 0
        i-total-parts_fact-qntynew       = 0
      .
      if work-mode = "update":u then do:
        { str/acc-cost.i
            rc_doc-line.obj-type
            rc_doc-line.obj-code
            rc_doc-line.doc-code
            rc_doc-line.artic
            rc_doc-line.prod-type
            rc_doc-line.prod-code
            rc_doc-line.cli-qnty
            rc_doc-line.doc-qnty
            rc_doc-line.fact-qnty
            rc_doc-line.price-base
            rc_doc-line.price-rubl
            "'new'"
            i-total-doc-line_tot-ovnew
            i-total-doc-line_fact-rublnew
            i-total-doc-line_fact-basenew
            i-total-doc-line_fact-qntynew
            i-total-doc-line_doc-qntynew
            i-total-doc-line_cli-qntynew
            no-error
        }
        if error-status :error then do:
          message
            "Ошибка при расчете шапки документа инвентаризации." skip
            return-value skip
            trim( error-status :get-message( 1 ) )
          view-as alert-box error.
          undo, return error .
        end.
      end.
      { str/ass-cost.i
          recid(rc_trn-doc)
          i-total-doc-line_tot-ovnew
          i-total-doc-line_fact-rublnew
          i-total-doc-line_fact-basenew
          i-total-doc-line_fact-qntynew
          i-total-doc-line_doc-qntynew
          i-total-doc-line_cli-qntynew
          i-total-doc-line_tot-ovold
          i-total-doc-line_fact-rublold
          i-total-doc-line_fact-baseold
          i-total-doc-line_fact-qntyold
          i-total-doc-line_doc-qntyold
          i-total-doc-line_cli-qntyold
          no-error
      }
      if error-status :error then do:
        message
          "Ошибка при редактировании шапки документа инвентаризации." skip
          return-value skip
          trim( error-status :get-message( 1 ) )
        view-as alert-box error.
        undo, return error .
      end.
    end.
  end. /* on error */
end procedure. /* lib-trn2_reclcinv */

/* Проверка установки цены по документу */
procedure lib-trn2_chkprdtl :
define input parameter pardoc-code like ub.trn-doc.doc-code no-undo.
define buffer bf_trn-doc for ub.trn-doc.
define buffer bf_gds-dtl for ub.gds-dtl.
define buffer bf_goods   for ub.goods  .
define variable varmax-disc-str              as   character                   no-undo.
define variable varmax-disc                  as   decimal                     no-undo.
define variable vartype                      as   character                   no-undo.
define variable varr-b                       as   character                   no-undo.
define variable v-is-mdificator-null-price   as   character                   no-undo.
{ str/get-pr.i def }
do on error undo, return error return-value :
{ gbl/curr-r-b.i varr-b }
find first bf_trn-doc where bf_trn-doc.doc-code = pardoc-code no-lock.
for each bf_gds-dtl where bf_gds-dtl.doc-code  = pardoc-code on error undo, return error return-value :
  find first bf_goods where bf_goods.artic     = bf_gds-dtl.artic     and
                            bf_goods.prod-type = bf_gds-dtl.prod-type and
                            bf_goods.prod-code = bf_gds-dtl.prod-code no-lock.
/* Закомментировал, чтобы были доступны 100% скидки в накладных */
/*  if bf_gds-dtl.fact-qnty  <> 0 and (                                                                                                                                                                                                            */
/*     bf_gds-dtl.price-base - bf_gds-dtl.discnt-base = 0 or                                                                                                                                                                                       */
/*     bf_gds-dtl.price-rubl - bf_gds-dtl.discnt-rubl = 0 ) then do:                                                                                                                                                                               */
/*     { gbl/fgdsobjt.i bf_trn-doc.obj-type bf_trn-doc.obj-code bf_goods.gds-code "'is-modificator-null-price=request'" v-is-mdificator-null-price }                                                                                               */
/*     if v-is-mdificator-null-price <> "1" then do:                                                                                                                                                                                               */
/*        undo, return error substitute( "Цена со скидкой по товару &1 &2 &3 равна 0 . (gds-dtl) Продажная цена = &4 и Скидка = &5", bf_gds-dtl.artic, bf_gds-dtl.prod-type, bf_gds-dtl.prod-code, bf_gds-dtl.price-rubl, bf_gds-dtl.discnt-rubl ).*/
/*     end.                                                                                                                                                                                                                                        */
/*  end.                                                                                                                                                                                                                                           */
  if bf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh} then do:
    define variable v-limit as decimal no-undo .
    define buffer buf_dis-gds-rule for ub.dis-gds-rule.
    define buffer buf_dis-rule for ub.dis-rule.
    _buf_dis-gds-rule:
    for each buf_dis-gds-rule no-lock where
              buf_dis-gds-rule.gds-code = bf_goods.gds-code
         and  buf_dis-gds-rule.obj-type = bf_gds-dtl.obj-type
         and  buf_dis-gds-rule.obj-code = bf_gds-dtl.obj-code
         and  buf_dis-gds-rule.pos-type = {&cd-type-no-cd}
         and  buf_dis-gds-rule.discnt-role = {&dgr-max-disc},
        first buf_dis-rule no-lock where
              buf_dis-rule.rule-num = buf_dis-gds-rule.rule-num
          and buf_dis-rule.sts = integer({&current-status-int}):
      leave _buf_dis-gds-rule.
    end.
    if available buf_dis-gds-rule then do:
      { str/get-pr.i "calc" bf_gds-dtl.obj-type bf_gds-dtl.obj-code bf_goods.gds-code bf_gds-dtl.prt-code }
      if gp-price-sale <> ? then do:
        if buf_Dis-rule.value-type = integer({&discnt-v-pcnt}) then do:
          v-limit = gp-price-sale * ( 1 - buf_Dis-rule.discnt-value * 0.01 ).
          varmax-disc-str = substitute("&1%", buf_Dis-rule.discnt-value).
        end.
        if buf_Dis-rule.value-type = integer({&discnt-v-abs}) then do:
          v-limit = gp-price-sale - varmax-disc.
          varmax-disc-str = substitute("&1 (&2)"
                                      , buf_Dis-rule.discnt-value
                                      , if varr-b = "rubl":u
                                        then "нац.вал."
                                        else "баз.вал."
                                      ).
        end.
        if varr-b = "rubl":u then do:
          if bf_gds-dtl.price-rubl - bf_gds-dtl.discnt-rubl < v-limit then do:
            return error substitute( "Текущая цена по товару &1 &2 &3 &4 равна &5. Максимальная скидка при продаже через расходную накладную &6. Цена в документе &7, равная &8, меньше минимальной цены с максимальной скидкой, равной &9. (gds-dtl)",
                                     bf_goods.artic,
                                     bf_goods.prod-type,
                                     bf_goods.prod-code,
                                     bf_goods.gds-name,
                                     gp-price-sale,
                                     varmax-disc-str,
                                     bf_gds-dtl.doc-code,
                                     bf_gds-dtl.price-rubl,
                                     v-limit
                                    ).
          end.
        end.
        else do:
          if bf_gds-dtl.price-base - bf_gds-dtl.discnt-base < v-limit then do:
            return error substitute( "Текущая цена по товару &1 &2 &3 &4 равна &5. Максимальная скидка при продаже через расходную накладную &6. Цена в документе &7, равная &8, меньше минимальной цены с максимальной скидкой, равной &9. (gds-dtl)",
                                     bf_goods.artic,
                                     bf_goods.prod-type,
                                     bf_goods.prod-code,
                                     bf_goods.gds-name,
                                     gp-price-sale,
                                     varmax-disc-str,
                                     bf_gds-dtl.doc-code,
                                     bf_gds-dtl.price-base,
                                     v-limit
                                    ).
          end.

        end.
      end.
    end.
  end.
end.
end.
end procedure. /* lib-trn2_chkprdtl */