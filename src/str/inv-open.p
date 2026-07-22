block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: inv-open.p $
$Archive: str/inv-open.p $

Открытие инвентаризации из статуса разр+, разр-

Автор: Суслов Алексей Юрьевич
Дата создания: 08/03/05
Author: Alexey Suslov
Creation date: 08/03/05

*/

define input parameter parrec-doc as recid                no-undo.
define input parameter parstatus  like ub.trn-doc.status_ no-undo.
define input parameter parflag    like ub.trn-doc.flag_   no-undo.

{ cmp/str-glbl.i }
{ cmp/library.i  }
{ str/trdcalib.i }
{ gbl/getsect.i def }

define buffer io_trn-doc     for ub.trn-doc.
define buffer io_trn-doc-sum for ub.trn-doc-sum.
define buffer io_doc-line    for ub.doc-line.
define buffer io_gds-obj     for ub.gds-obj.

define variable varlns-cnt as integer  no-undo.
define variable varvaluewt    as character no-undo.
define variable vartypewt     as character no-undo.
define variable varvalueol    as character no-undo.
define variable vartypeol     as character no-undo.
define variable wastagevalue  as character no-undo.
define variable wastagetype   as character no-undo.
define variable varinvclcspvalue as character no-undo.
define variable varinvclcsptype  as character no-undo.
define variable varcount         as integer   no-undo.

do
on error undo, return error return-value
:
  find first io_trn-doc where recid(io_trn-doc) = parrec-doc.
  { gbl/getsect.i run io_trn-doc.obj-type io_trn-doc.obj-code  {&attr-inv-obj} }
  for each thbjattr_thbj-attr :
      if thbjattr_thbj-attr.prop-code = 'invclcsp'  then varinvclcspvalue = string( thbjattr_thbj-attr.property-value-logical, "yes/no").
  end.

  /* Разблокирование товаров
    Снятие всех резервов, возврат документа к исходному виду */
  assign
    io_trn-doc.doc-qnty    = 0 /* количество до инвентаризации */
    io_trn-doc.fact-qnty   = 0
    io_trn-doc.tot-calc    = 0 /* сумма в учетных вал до инвентаризации */
    io_trn-doc.discnt-rubl = 0 /* сумма в учетных р_у_б до инвентаризации */
    io_trn-doc.tot-doc     = 0
    io_trn-doc.tot-rubl    = 0
    io_trn-doc.fact-base   = 0
    io_trn-doc.fact-rubl   = 0
    io_trn-doc.tot-ov      = 0
    io_trn-doc.re-grading-parts-minus = no
  .
  /* Захватываем все gds-obj перед заданием количества по строкам (было) */
  run trg/lock-gds.p
    (input io_trn-doc.doc-code /* v-trn-doc-doc-code */
    ,input no               /* p-check-inv        */
    ,input no               /* p-check-inv-rasr-minus */
    ,input 0                /* p-document-fact-order  */
    ,input 0                /* p-document-fact-order-price  */
    ,input false            /* p-fact-close           */
    ,input false            /* p-is-news              */
    ) no-error .
  if error-status :error then do:
    undo, return error return-value.
  end.
  assign
    varcount = 0.
  for each io_doc-line
    where io_doc-line.doc-code = io_trn-doc.doc-code
  on error undo, return error return-value
  :
    assign
      varcount = varcount + 1.
    if io_trn-doc.status_ <> {&inquiry} then do:
      run trg/rsrv-del.p
        (input io_doc-line.doc-code
        ,input io_doc-line.artic
        ,input io_doc-line.prod-type
        ,input io_doc-line.prod-code
        ) no-error .
    end.
    if error-status :error then do:
      undo, return error substitute("Ошибка при снятии резервов. Документ &1 Артикул: &2 &3 &4 Открыть инвентаризацию невозможно.",
                                    io_doc-line.doc-code,
                                    io_doc-line.artic,
                                    io_doc-line.prod-type,
                                    io_doc-line.prod-code).
    end.
  end.
  run gbl/conf-rd.p ("wastage":u , io_trn-doc.host-code, io_trn-doc.obj-type, io_trn-doc.obj-code, "", "", "", no,  output wastagevalue, output wastagetype) no-error.
  { str/tdat-val.i
      io_trn-doc.doc-code
      {&trdcattr-clcaswt}
      varvaluewt
      vartypewt
  }
  { str/tdat-val.i
      io_trn-doc.doc-code
      {&trdcattr-clcasol}
      varvalueol
      vartypeol
  }
  &scop scop-delete-trn ~
        find first io_trn-doc-sum where io_trn-doc-sum.doc-code = io_trn-doc.doc-code  and ~
                                        io_trn-doc-sum.sum-type = ~{&delete-sum-type~} no-error. ~
        if available io_trn-doc-sum then do: ~
          run delete-trn  in this-procedure (input io_trn-doc.doc-code,  ~
                                             input ~{&delete-sum-type~}) no-error. ~
          if error-status:error then do: ~
            undo, return error return-value. ~
          end. ~
        end.
  &scop delete-sum-type {&sum-before-doc}
  {&scop-delete-trn}
  &scop delete-sum-type {&sum-before-cli-doc}
  {&scop-delete-trn}
  &scop delete-sum-type {&sum-wastage-doc}
  {&scop-delete-trn}
  &scop delete-sum-type {&sum-wastage-cli-doc}
  {&scop-delete-trn}
  &scop delete-sum-type {&sum-general-doc}
  {&scop-delete-trn}
  &scop delete-sum-type {&sum-general-cli-doc}
  {&scop-delete-trn}
  &scop delete-sum-type {&sum-extra-doc}
  {&scop-delete-trn}
  &scop delete-sum-type {&sum-extra-cli-doc}
  {&scop-delete-trn}
  &scop delete-sum-type {&sum-miss-doc}
  {&scop-delete-trn}
  &scop delete-sum-type {&sum-miss-cli-doc}
  {&scop-delete-trn}
  &scop delete-sum-type {&sum-after-doc}
  {&scop-delete-trn}
  &scop delete-sum-type {&sum-after-cli-doc}
  {&scop-delete-trn}
  { str/tdat-wrt.i
      io_trn-doc.doc-code
      {&trdcattr-addsum}
      "' '"
      no-error
  }
  if error-status :error then do:
    undo, return error substitute( "Ошибка при вызове процедуры tdatr-wrt &1.", return-value ).
  end.
end.

/* удаление сумм документа */
procedure delete-trn :
  define input parameter pardoc-code like ub.trn-doc.doc-code     no-undo.
  define input parameter parsum-type like ub.trn-doc-sum.sum-type no-undo.

  define buffer bf_trn-doc      for ub.trn-doc.
  define buffer bf_trn-doc-sum  for ub.trn-doc-sum.
  define buffer bf_doc-line-sum for ub.doc-line-sum.

  do on error undo, return error return-value :
    find first bf_trn-doc where bf_trn-doc.doc-code = pardoc-code.
    for each bf_trn-doc-sum where bf_trn-doc-sum.doc-code = pardoc-code and
                                  bf_trn-doc-sum.sum-type = parsum-type exclusive-lock on error undo, return error return-value :
      for each bf_doc-line-sum where bf_doc-line-sum.doc-code = bf_trn-doc.doc-code and
                                     bf_doc-line-sum.sum-type = parsum-type         exclusive-lock on error undo, return error return-value :
        delete bf_doc-line-sum.
      end.
      delete bf_trn-doc-sum.
    end.
  end.
end procedure. /* delete-trn */