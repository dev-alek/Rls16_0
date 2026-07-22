/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определения, необходимые для расчета складского архива по типам приобретени

Автор: Чернова Светлана Александровна
Дата создания: 07/23/08
Author: Svetlana Chernova
Creation date: 07/23/08

Автор1: Перваков Михаил Сергеевич
Дата создания: 12/10/02

*/

&scoped-define vssseq {&sequence}
def var vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define stream ahtlog .

&glob price-single-list ~
   ~{&FL1~}sum-base~{&FLS1~}       ~{&FL2~} ~{&FL3~} ~
   ~{&FL1~}sum-rubl~{&FLS1~}       ~{&FL2~} ~{&FL3~} ~
   ~{&FL1~}vat-base~{&FLS1~}       ~{&FL2~} ~{&FL3~} ~
   ~{&FL1~}vat-rubl~{&FLS1~}       ~{&FL2~} ~{&FL3~} ~
   ~{&FL1~}slt-base~{&FLS1~}       ~{&FL2~} ~{&FL3~} ~
   ~{&FL1~}slt-rubl~{&FLS1~}       ~{&FL2~} ~{&FL3~} ~
   ~{&FL1~}road-tax-base~{&FLS1~}  ~{&FL2~} ~{&FL3~} ~
   ~{&FL1~}road-tax-rubl~{&FLS1~}  ~{&FL2~} ~{&FL3~} ~
   ~{&FL1~}excise-base~{&FLS1~}    ~{&FL2~} ~{&FL3~} ~
   ~{&FL1~}excise-rubl~{&FLS1~}    ~{&FL2~} ~{&FL3~} ~
   ~{&FL1~}transport-base~{&FLS1~} ~{&FL2~} ~{&FL3~} ~
   ~{&FL1~}transport-rubl~{&FLS1~} ~{&FL2~} ~{&FL3~} ~
   ~{&FL1~}other-base~{&FLS1~}     ~{&FL2~} ~{&FL3~} ~
   ~{&FL1~}other-rubl~{&FLS1~}     ~{&FL2~} ~{&FL3~} ~
   ~{&FL1~}discnt-base~{&FLS1~}    ~{&FL2~} ~{&FL3~} ~
   ~{&FL1~}discnt-rubl~{&FLS1~}    ~{&FL2~}

/*
   &scop fl1
   &scop fls1
   &scop fl2
   &scop fl3
   {&price-single-list}
*/

&glob price-pair-list ~
   ~{&FP1~}sum-base~{&FPS1~}       ~{&FP2~}sum-base~{&FPS2~}        ~{&FP3~} ~{&FP4~} ~
   ~{&FP1~}sum-rubl~{&FPS1~}       ~{&FP2~}sum-rubl~{&FPS2~}        ~{&FP3~} ~{&FP4~} ~
   ~{&FP1~}vat-base~{&FPS1~}       ~{&FP2~}vat-base~{&FPS2~}        ~{&FP3~} ~{&FP4~} ~
   ~{&FP1~}vat-rubl~{&FPS1~}       ~{&FP2~}vat-rubl~{&FPS2~}        ~{&FP3~} ~{&FP4~} ~
   ~{&FP1~}slt-base~{&FPS1~}       ~{&FP2~}slt-base~{&FPS2~}        ~{&FP3~} ~{&FP4~} ~
   ~{&FP1~}slt-rubl~{&FPS1~}       ~{&FP2~}slt-rubl~{&FPS2~}        ~{&FP3~} ~{&FP4~} ~
   ~{&FP1~}road-tax-base~{&FPS1~}  ~{&FP2~}road-tax-base~{&FPS2~}   ~{&FP3~} ~{&FP4~} ~
   ~{&FP1~}road-tax-rubl~{&FPS1~}  ~{&FP2~}road-tax-rubl~{&FPS2~}   ~{&FP3~} ~{&FP4~} ~
   ~{&FP1~}excise-base~{&FPS1~}    ~{&FP2~}excise-base~{&FPS2~}     ~{&FP3~} ~{&FP4~} ~
   ~{&FP1~}excise-rubl~{&FPS1~}    ~{&FP2~}excise-rubl~{&FPS2~}     ~{&FP3~} ~{&FP4~} ~
   ~{&FP1~}transport-base~{&FPS1~} ~{&FP2~}transport-base~{&FPS2~}  ~{&FP3~} ~{&FP4~} ~
   ~{&FP1~}transport-rubl~{&FPS1~} ~{&FP2~}transport-rubl~{&FPS2~}  ~{&FP3~} ~{&FP4~} ~
   ~{&FP1~}other-base~{&FPS1~}     ~{&FP2~}other-base~{&FPS2~}      ~{&FP3~} ~{&FP4~} ~
   ~{&FP1~}other-rubl~{&FPS1~}     ~{&FP2~}other-rubl~{&FPS2~}      ~{&FP3~} ~{&FP4~} ~
   ~{&FP1~}discnt-base~{&FPS1~}    ~{&FP2~}discnt-base~{&FPS2~}     ~{&FP3~} ~{&FP4~} ~
   ~{&FP1~}discnt-rubl~{&FPS1~}    ~{&FP2~}discnt-rubl~{&FPS2~}     ~{&FP3~}

/*
   &scop fp1
   &scop fps1
   &scop fp2
   &scop fps2
   &scop fp3
   &scop fp4
   {&price-pair-list}
*/


&glob price-trio-list~
   ~{&FT1~}sum-base~{&FTS1~}       ~{&FT2~}sum-base~{&FTS2~}       ~{&FT3~}sum-base~{&FTS3~}       ~{&FT4~} ~{&FT5~} ~
   ~{&FT1~}sum-rubl~{&FTS1~}       ~{&FT2~}sum-rubl~{&FTS2~}       ~{&FT3~}sum-rubl~{&FTS3~}       ~{&FT4~} ~{&FT5~} ~
   ~{&FT1~}vat-base~{&FTS1~}       ~{&FT2~}vat-base~{&FTS2~}       ~{&FT3~}vat-base~{&FTS3~}       ~{&FT4~} ~{&FT5~} ~
   ~{&FT1~}vat-rubl~{&FTS1~}       ~{&FT2~}vat-rubl~{&FTS2~}       ~{&FT3~}vat-rubl~{&FTS3~}       ~{&FT4~} ~{&FT5~} ~
   ~{&FT1~}slt-base~{&FTS1~}       ~{&FT2~}slt-base~{&FTS2~}       ~{&FT3~}slt-base~{&FTS3~}       ~{&FT4~} ~{&FT5~} ~
   ~{&FT1~}slt-rubl~{&FTS1~}       ~{&FT2~}slt-rubl~{&FTS2~}       ~{&FT3~}slt-rubl~{&FTS3~}       ~{&FT4~} ~{&FT5~} ~
   ~{&FT1~}road-tax-base~{&FTS1~}  ~{&FT2~}road-tax-base~{&FTS2~}  ~{&FT3~}road-tax-base~{&FTS3~}  ~{&FT4~} ~{&FT5~} ~
   ~{&FT1~}road-tax-rubl~{&FTS1~}  ~{&FT2~}road-tax-rubl~{&FTS2~}  ~{&FT3~}road-tax-rubl~{&FTS3~}  ~{&FT4~} ~{&FT5~} ~
   ~{&FT1~}excise-base~{&FTS1~}    ~{&FT2~}excise-base~{&FTS2~}    ~{&FT3~}excise-base~{&FTS3~}    ~{&FT4~} ~{&FT5~} ~
   ~{&FT1~}excise-rubl~{&FTS1~}    ~{&FT2~}excise-rubl~{&FTS2~}    ~{&FT3~}excise-rubl~{&FTS3~}    ~{&FT4~} ~{&FT5~} ~
   ~{&FT1~}transport-base~{&FTS1~} ~{&FT2~}transport-base~{&FTS2~} ~{&FT3~}transport-base~{&FTS3~} ~{&FT4~} ~{&FT5~} ~
   ~{&FT1~}transport-rubl~{&FTS1~} ~{&FT2~}transport-rubl~{&FTS2~} ~{&FT3~}transport-rubl~{&FTS3~} ~{&FT4~} ~{&FT5~} ~
   ~{&FT1~}other-base~{&FTS1~}     ~{&FT2~}other-base~{&FTS2~}     ~{&FT3~}other-base~{&FTS3~}     ~{&FT4~} ~{&FT5~} ~
   ~{&FT1~}other-rubl~{&FTS1~}     ~{&FT2~}other-rubl~{&FTS2~}     ~{&FT3~}other-rubl~{&FTS3~}     ~{&FT4~} ~{&FT5~} ~
   ~{&FT1~}discnt-base~{&FTS1~}    ~{&FT2~}discnt-base~{&FTS2~}    ~{&FT3~}discnt-base~{&FTS3~}     ~{&FT4~} ~{&FT5~} ~
   ~{&FT1~}discnt-rubl~{&FTS1~}    ~{&FT2~}discnt-rubl~{&FTS2~}    ~{&FT3~}discnt-rubl~{&FTS3~}     ~{&FT4~}

/*
   &scop FT1
   &scop FTs1
   &scop FT2
   &scop FTs2
   &scop FT3
   &scop FTs3
   &scop FT4
   &scop FT5
   {&price-trio-list}
*/


&glob price-quadro-list~
   ~{&fq1~}sum-base~{&fqS1~}       ~{&fq2~}sum-base~{&fqS2~}       ~{&fq3~}sum-base~{&fqS3~}       ~{&fq4~}sum-base~{&fqS4~}       ~{&fq5~} ~{&fq6~} ~
   ~{&fq1~}sum-rubl~{&fqS1~}       ~{&fq2~}sum-rubl~{&fqS2~}       ~{&fq3~}sum-rubl~{&fqS3~}       ~{&fq4~}sum-rubl~{&fqS4~}       ~{&fq5~} ~{&fq6~} ~
   ~{&fq1~}vat-base~{&fqS1~}       ~{&fq2~}vat-base~{&fqS2~}       ~{&fq3~}vat-base~{&fqS3~}       ~{&fq4~}vat-base~{&fqS4~}       ~{&fq5~} ~{&fq6~} ~
   ~{&fq1~}vat-rubl~{&fqS1~}       ~{&fq2~}vat-rubl~{&fqS2~}       ~{&fq3~}vat-rubl~{&fqS3~}       ~{&fq4~}vat-rubl~{&fqS4~}       ~{&fq5~} ~{&fq6~} ~
   ~{&fq1~}slt-base~{&fqS1~}       ~{&fq2~}slt-base~{&fqS2~}       ~{&fq3~}slt-base~{&fqS3~}       ~{&fq4~}slt-base~{&fqS4~}       ~{&fq5~} ~{&fq6~} ~
   ~{&fq1~}slt-rubl~{&fqS1~}       ~{&fq2~}slt-rubl~{&fqS2~}       ~{&fq3~}slt-rubl~{&fqS3~}       ~{&fq4~}slt-rubl~{&fqS4~}       ~{&fq5~} ~{&fq6~} ~
   ~{&fq1~}road-tax-base~{&fqS1~}  ~{&fq2~}road-tax-base~{&fqS2~}  ~{&fq3~}road-tax-base~{&fqS3~}  ~{&fq4~}road-tax-base~{&fqS4~}  ~{&fq5~} ~{&fq6~} ~
   ~{&fq1~}road-tax-rubl~{&fqS1~}  ~{&fq2~}road-tax-rubl~{&fqS2~}  ~{&fq3~}road-tax-rubl~{&fqS3~}  ~{&fq4~}road-tax-rubl~{&fqS4~}  ~{&fq5~} ~{&fq6~} ~
   ~{&fq1~}excise-base~{&fqS1~}    ~{&fq2~}excise-base~{&fqS2~}    ~{&fq3~}excise-base~{&fqS3~}    ~{&fq4~}excise-base~{&fqS4~}    ~{&fq5~} ~{&fq6~} ~
   ~{&fq1~}excise-rubl~{&fqS1~}    ~{&fq2~}excise-rubl~{&fqS2~}    ~{&fq3~}excise-rubl~{&fqS3~}    ~{&fq4~}excise-rubl~{&fqS4~}    ~{&fq5~} ~{&fq6~} ~
   ~{&fq1~}transport-base~{&fqS1~} ~{&fq2~}transport-base~{&fqS2~} ~{&fq3~}transport-base~{&fqS3~} ~{&fq4~}transport-base~{&fqS4~} ~{&fq5~} ~{&fq6~} ~
   ~{&fq1~}transport-rubl~{&fqS1~} ~{&fq2~}transport-rubl~{&fqS2~} ~{&fq3~}transport-rubl~{&fqS3~} ~{&fq4~}transport-rubl~{&fqS4~} ~{&fq5~} ~{&fq6~} ~
   ~{&fq1~}other-base~{&fqS1~}     ~{&fq2~}other-base~{&fqS2~}     ~{&fq3~}other-base~{&fqS3~}     ~{&fq4~}other-base~{&fqS4~}     ~{&fq5~} ~{&fq6~} ~
   ~{&fq1~}other-rubl~{&fqS1~}     ~{&fq2~}other-rubl~{&fqS2~}     ~{&fq3~}other-rubl~{&fqS3~}     ~{&fq4~}other-rubl~{&fqS4~}     ~{&fq5~} ~{&fq6~} ~
   ~{&fq1~}discnt-base~{&fqS1~}    ~{&fq2~}discnt-base~{&fqS2~}    ~{&fq3~}discnt-base~{&fqS3~}    ~{&fq4~}other -base~{&fqS4~}    ~{&fq5~} ~{&fq6~} ~
   ~{&fq1~}discnt-rubl~{&fqS1~}    ~{&fq2~}discnt-rubl~{&fqS2~}    ~{&fq3~}discnt-rubl~{&fqS3~}    ~{&fq4~}other -rubl~{&fqS4~}    ~{&fq5~}


/*
   &scop fq1
   &scop fqs1
   &scop fq2
   &scop fqs2
   &scop fq3
   &scop fqs3
   &scop fq4
   &scop fqs4
   &scop fq5
   &scop fq6
   {&price-quadro-list}
*/


&glob def-temp-aht-ot-tot define temp-table temp-aht-ot-tot no-undo like ub.aht-ot-tot .
&glob def-temp-aht-ot-line define temp-table temp-aht-ot-line no-undo like ub.aht-ot-line .
&glob def-temp-aht-stk-tot define temp-table temp-aht-stk-tot no-undo like ub.aht-stk-tot .
&glob def-temp-aht-stk-line define temp-table temp-aht-stk-line no-undo like ub.aht-stk-line .
{&def-temp-aht-ot-tot}
{&def-temp-aht-ot-line}
{&def-temp-aht-stk-tot}
{&def-temp-aht-stk-line}

&glob aht-ot-tot-pair-list ~
  ~{&FP1~}doc-code     ~{&FP2~}doc-code     ~
  ~{&FP1~}sum-type     ~{&FP2~}sum-type     ~
  ~{&FP1~}ext-doc-type ~{&FP2~}ext-doc-type ~
  ~{&FP1~}obj-type     ~{&FP2~}obj-type     ~
  ~{&FP1~}obj-code     ~{&FP2~}obj-code     ~
  ~{&FP1~}fact-order   ~{&FP2~}fact-order

&glob aht-ot-line-pair-list ~
  ~{&FP1~}doc-code     ~{&FP2~}doc-code     ~
  ~{&FP1~}gds-code     ~{&FP2~}gds-code     ~
  ~{&FP1~}sum-type     ~{&FP2~}sum-type     ~
  ~{&FP1~}ext-doc-type ~{&FP2~}ext-doc-type ~
  ~{&FP1~}obj-type     ~{&FP2~}obj-type     ~
  ~{&FP1~}obj-code     ~{&FP2~}obj-code     ~
  ~{&FP1~}fact-order   ~{&FP2~}fact-order

&glob aht-stk-tot-pair-list  ~
  ~{&FP1~}obj-type     ~{&FP2~}obj-type   ~
  ~{&FP1~}obj-code     ~{&FP2~}obj-code   ~
  ~{&FP1~}fact-order   ~{&FP2~}fact-order ~
  ~{&FP1~}sum-type     ~{&FP2~}sum-type

&glob aht-stk-line-pair-list  ~
  ~{&FP1~}obj-type     ~{&FP2~}obj-type   ~
  ~{&FP1~}obj-code     ~{&FP2~}obj-code   ~
  ~{&FP1~}gds-code     ~{&FP2~}gds-code   ~
  ~{&FP1~}fact-order   ~{&FP2~}fact-order ~
  ~{&FP1~}sum-type     ~{&FP2~}sum-type


procedure aht_get-sum-type :

  define input  parameter p-aht-type        as character no-undo .
  define output parameter p-allsum-sum-type as character no-undo .

  do
  on error undo, return error return-value
  :
    case p-aht-type :
      when {&aht-repayment} then do:
        assign
          p-allsum-sum-type = {&sum-repayment-sign}
        .
      end.
      when {&aht-cons_acc} then do:
        assign
          p-allsum-sum-type = {&sum-cons_acc-sign}
        .
      end.
      when {&aht-cons_benf} then do:
        assign
          p-allsum-sum-type = {&sum-cons_benf-sign}
        .
      end.
      when {&aht-resp_stor} then do:
        assign
          p-allsum-sum-type = {&sum-resp_stor-sign}
        .
      end.
      when {&aht-old_cons} then do:
        assign
          p-allsum-sum-type = {&sum-old-cons-sign}
        .
      end.
      when {&aht-service} then do:
        assign
          p-allsum-sum-type = {&sum-office-sign}
        .
      end.
      otherwise do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info{&vssseq} skip
          "Неизвестное значение типа приобретения" skip
          "Тип приобретения" p-aht-type skip
          view-as alert-box error .
        undo, return error .
      end.
    end.
  end.

end procedure. /* aht_get-sum-type */


procedure aht_get-stk-sum-type :

  define input  parameter p-ot-sum-type      as character no-undo .
  define input  parameter p-ext-doc-type     as character no-undo .
  define output parameter p-stk-ext-sum-type as character no-undo .

  do
  on error undo, return error return-value
  :
    assign
      p-stk-ext-sum-type = p-ot-sum-type + p-ext-doc-type
    .
  end.

end procedure. /* aht_get-stk-sum-type */

procedure aht_store-ot-line :

  define input  parameter p-doc-code       as character no-undo .
  define input  parameter p-gds-code       as integer   no-undo .
  define input  parameter p-sum-type       as character no-undo .
  define input  parameter p-ext-doc-type   as character no-undo .
  define input  parameter p-obj-type       as character no-undo .
  define input  parameter p-obj-code       as integer   no-undo .
  define input  parameter p-fact-order     as decimal   no-undo .
  define input  parameter p-fact-qnty      as decimal   no-undo .
  &scop fl1    define input  parameter p-cost-
  &scop fls1
  &scop fl2    as decimal   no-undo .
  &scop fl3
  {&price-single-list}
  &scop fl1    define input  parameter p-crsa-
  &scop fls1
  &scop fl2    as decimal   no-undo .
  &scop fl3
  {&price-single-list}
  &scop fl1    define input  parameter p-sale-
  &scop fls1
  &scop fl2    as decimal   no-undo .
  &scop fl3
  {&price-single-list}

  define buffer buf_temp-aht-ot-line for temp-aht-ot-line .

  do
  on error undo, return error return-value
  :
    find first buf_temp-aht-ot-line
      where buf_temp-aht-ot-line.doc-code  = p-doc-code
        and buf_temp-aht-ot-line.gds-code  = p-gds-code
        and buf_temp-aht-ot-line.sum-type  = p-sum-type
      no-error .
    if not available buf_temp-aht-ot-line then do:
      create buf_temp-aht-ot-line .
      assign
        buf_temp-aht-ot-line.doc-code     = p-doc-code
        buf_temp-aht-ot-line.gds-code     = p-gds-code
        buf_temp-aht-ot-line.sum-type     = p-sum-type
        buf_temp-aht-ot-line.ext-doc-type = p-ext-doc-type
        buf_temp-aht-ot-line.obj-type     = p-obj-type
        buf_temp-aht-ot-line.obj-code     = p-obj-code
        buf_temp-aht-ot-line.fact-order   = p-fact-order
      .
    end.
    assign
      buf_temp-aht-ot-line.fact-qnty = buf_temp-aht-ot-line.fact-qnty + p-fact-qnty
      &scop FT1    buf_temp-aht-ot-line.cost-
      &scop FTs1
      &scop FT2    = buf_temp-aht-ot-line.cost-
      &scop FTs2
      &scop FT3    + p-cost-
      &scop FTs3
      &scop FT4
      &scop FT5
      {&price-trio-list}
      &scop FT1    buf_temp-aht-ot-line.crsa-
      &scop FTs1
      &scop FT2    = buf_temp-aht-ot-line.crsa-
      &scop FTs2
      &scop FT3    + p-crsa-
      &scop FTs3
      &scop FT4
      &scop FT5
      {&price-trio-list}
      &scop FT1    buf_temp-aht-ot-line.sale-
      &scop FTs1
      &scop FT2    = buf_temp-aht-ot-line.sale-
      &scop FTs2
      &scop FT3    + p-sale-
      &scop FTs3
      &scop FT4
      &scop FT5
      {&price-trio-list}
    .
  end.

end procedure. /* store-aht-ot-line */


procedure aht_update-ot-tot :

  define input  parameter p-obj-type            like ub.trn-doc.obj-type     no-undo .
  define input  parameter p-obj-code            like ub.trn-doc.obj-code     no-undo .
  define input  parameter p-fact-order          like ub.trn-doc.fact-order   no-undo .
  define input  parameter p-ext-doc-type        like ub.trn-doc.ext-doc-type no-undo .

  define buffer buf_temp-aht-ot-line for temp-aht-ot-line .
  define buffer buf_temp-aht-ot-tot for temp-aht-ot-tot .

  do
  on error undo, return error
  :

    for each buf_temp-aht-ot-line
    on error undo, return error
    :
      find first buf_temp-aht-ot-tot
        where buf_temp-aht-ot-tot.doc-code = buf_temp-aht-ot-line.doc-code
          and buf_temp-aht-ot-tot.sum-type = buf_temp-aht-ot-line.sum-type
        no-error .
      if not available buf_temp-aht-ot-tot then do:
        create buf_temp-aht-ot-tot .
        assign
          buf_temp-aht-ot-tot.doc-code     = buf_temp-aht-ot-line.doc-code
          buf_temp-aht-ot-tot.sum-type     = buf_temp-aht-ot-line.sum-type
          buf_temp-aht-ot-tot.ext-doc-type = p-ext-doc-type
          buf_temp-aht-ot-tot.obj-type     = p-obj-type
          buf_temp-aht-ot-tot.obj-code     = p-obj-code
          buf_temp-aht-ot-tot.fact-order   = p-fact-order
        .
      end.
      assign
        buf_temp-aht-ot-tot.fact-qnty = buf_temp-aht-ot-tot.fact-qnty + buf_temp-aht-ot-line.fact-qnty
        &scop FT1    buf_temp-aht-ot-tot.cost-
        &scop FTs1
        &scop FT2    = buf_temp-aht-ot-tot.cost-
        &scop FTs2
        &scop FT3    + buf_temp-aht-ot-line.cost-
        &scop FTs3
        &scop FT4
        &scop FT5
        {&price-trio-list}
        &scop FT1    buf_temp-aht-ot-tot.crsa-
        &scop FTs1
        &scop FT2    = buf_temp-aht-ot-tot.crsa-
        &scop FTs2
        &scop FT3    + buf_temp-aht-ot-line.crsa-
        &scop FTs3
        &scop FT4
        &scop FT5
        {&price-trio-list}
        &scop FT1    buf_temp-aht-ot-tot.sale-
        &scop FTs1
        &scop FT2    = buf_temp-aht-ot-tot.sale-
        &scop FTs2
        &scop FT3    + buf_temp-aht-ot-line.sale-
        &scop FTs3
        &scop FT4
        &scop FT5
        {&price-trio-list}
      .
    end.
  end.

end procedure. /* update-aht-ot-tot */


procedure aht_update-stk-table :

  define input  parameter p-fact-order     like ub.trn-doc.fact-order   no-undo .
  define input  parameter p-cut-fact-order like ub.trn-doc.fact-order   no-undo .
  define input  parameter p-ext-doc-type   like ub.trn-doc.ext-doc-type no-undo .
  define input  parameter p-trn-doc        as logical   no-undo .

  define buffer buf_temp-aht-ot-tot for temp-aht-ot-tot .
  define buffer buf_temp-aht-ot-line for temp-aht-ot-line .

  define variable v-stk-ext-sum-type as character no-undo .

  do
  on error undo, return error
  :
    for each buf_temp-aht-ot-tot
    on error undo, return error
    :
      run aht_get-stk-sum-type in this-procedure
        (input  buf_temp-aht-ot-tot.sum-type
        ,input  p-ext-doc-type
        ,output v-stk-ext-sum-type
        ) .

      run aht_store-stk-tot in this-procedure
        (buffer buf_temp-aht-ot-tot
        ,input buf_temp-aht-ot-tot.sum-type /* v-stk-sum-type   */
        ,input p-fact-order                 /* p-fact-order     */
        ,input p-cut-fact-order             /* p-cut-fact-order */
        ,input p-ext-doc-type               /* p-ext-doc-type   */
        ,input false                        /* p-update-sale    */
        ) .

      run aht_store-stk-tot in this-procedure
        (buffer buf_temp-aht-ot-tot
        ,input v-stk-ext-sum-type /* v-stk-sum-type   */
        ,input p-fact-order       /* p-fact-order     */
        ,input p-cut-fact-order   /* p-cut-fact-order */
        ,input p-ext-doc-type     /* p-ext-doc-type   */
        ,input p-trn-doc          /* p-update-sale    */
        ) .
    end.

    for each buf_temp-aht-ot-line
    on error undo, return error
    :
      run aht_get-stk-sum-type in this-procedure
        (input  buf_temp-aht-ot-line.sum-type
        ,input  p-ext-doc-type
        ,output v-stk-ext-sum-type
        ) .

      run aht_store-stk-line in this-procedure
        (buffer buf_temp-aht-ot-line         /* buf_temp-aht-ot-line */
        ,input buf_temp-aht-ot-line.sum-type /* p-stk-sum-type       */
        ,input p-fact-order                  /* p-fact-order         */
        ,input p-cut-fact-order              /* p-cut-fact-order     */
        ,input p-ext-doc-type                /* p-ext-doc-type       */
        ,input false                         /* p-update-sale        */
        ) .

      run aht_store-stk-line in this-procedure
        (buffer buf_temp-aht-ot-line  /* buf_temp-aht-ot-line */
        ,input v-stk-ext-sum-type     /* p-stk-sum-type       */
        ,input p-fact-order           /* p-fact-order         */
        ,input p-cut-fact-order       /* p-cut-fact-order     */
        ,input p-ext-doc-type         /* p-ext-doc-type       */
        ,input p-trn-doc              /* p-update-sale        */
        ) .
    end.
  end.

end procedure. /* update-stk-table */


procedure aht_store-stk-tot :

  define parameter buffer buf_temp-aht-ot-tot for temp-aht-ot-tot .
  define input  parameter p-stk-sum-type      as character no-undo .
  define input  parameter p-fact-order        like ub.trn-doc.fact-order   no-undo .
  define input  parameter p-cut-fact-order    like ub.trn-doc.fact-order   no-undo .
  define input  parameter p-ext-doc-type      like ub.trn-doc.ext-doc-type no-undo .
  define input  parameter p-update-sale       as logical   no-undo .


  define buffer buf_aht-stk-tot for ub.aht-stk-tot .
  define buffer new-buf_aht-stk-tot for ub.aht-stk-tot .

  do
  on error undo, return error return-value
  :
    /* создаём остаток на конец дня */
    find last buf_aht-stk-tot exclusive-lock
      where buf_aht-stk-tot.obj-type   = buf_temp-aht-ot-tot.obj-type
        and buf_aht-stk-tot.obj-code   = buf_temp-aht-ot-tot.obj-code
        and buf_aht-stk-tot.sum-type   = p-stk-sum-type
        and buf_aht-stk-tot.fact-order <= p-fact-order
      use-index category
      no-error .
    if not available buf_aht-stk-tot
    or buf_aht-stk-tot.fact-order <> p-fact-order
    then do:
      create new-buf_aht-stk-tot .
      assign
        new-buf_aht-stk-tot.obj-type   = buf_temp-aht-ot-tot.obj-type
        new-buf_aht-stk-tot.obj-code   = buf_temp-aht-ot-tot.obj-code
        new-buf_aht-stk-tot.fact-order = p-fact-order
        new-buf_aht-stk-tot.sum-type   = p-stk-sum-type
      .
      if available buf_aht-stk-tot then do:
        assign
          new-buf_aht-stk-tot.fact-qnty = buf_aht-stk-tot.fact-qnty
          &scop fp1   new-buf_aht-stk-tot.cost-
          &scop fps1
          &scop fp2   = buf_aht-stk-tot.cost-
          &scop fps2
          &scop fp3
          &scop fp4
          {&price-pair-list}
          &scop fp1   new-buf_aht-stk-tot.crsa-
          &scop fps1
          &scop fp2   = buf_aht-stk-tot.crsa-
          &scop fps2
          &scop fp3
          &scop fp4
          {&price-pair-list}
        .
        if p-update-sale then do:
          assign
            &scop fp1   new-buf_aht-stk-tot.sale-
            &scop fps1
            &scop fp2   = buf_aht-stk-tot.sale-
            &scop fps2
            &scop fp3
            &scop fp4
            {&price-pair-list}
          .
        end.
      end.
    end.

    /* обновляем текущий и все более поздние остатки */
    if p-stk-sum-type <> {&aht-service}
    then do:
      for each buf_aht-stk-tot exclusive-lock
        where buf_aht-stk-tot.obj-type   = buf_temp-aht-ot-tot.obj-type
          and buf_aht-stk-tot.obj-code   = buf_temp-aht-ot-tot.obj-code
          and buf_aht-stk-tot.sum-type   = p-stk-sum-type
          and buf_aht-stk-tot.fact-order >= p-fact-order
          and buf_aht-stk-tot.fact-order <= p-cut-fact-order
      :
        assign
          buf_aht-stk-tot.fact-qnty = buf_aht-stk-tot.fact-qnty + buf_temp-aht-ot-tot.fact-qnty
          &scop FT1    buf_aht-stk-tot.cost-
          &scop FTs1
          &scop FT2    = buf_aht-stk-tot.cost-
          &scop FTs2
          &scop FT3    + buf_temp-aht-ot-tot.cost-
          &scop FTs3
          &scop FT4
          &scop FT5
          {&price-trio-list}
          &scop FT1    buf_aht-stk-tot.crsa-
          &scop FTs1
          &scop FT2    = buf_aht-stk-tot.crsa-
          &scop FTs2
          &scop FT3    + buf_temp-aht-ot-tot.crsa-
          &scop FTs3
          &scop FT4
          &scop FT5
          {&price-trio-list}
        .
        if p-update-sale then do:
          assign
            &scop FT1    buf_aht-stk-tot.sale-
            &scop FTs1
            &scop FT2    = buf_aht-stk-tot.sale-
            &scop FTs2
            &scop FT3    + buf_temp-aht-ot-tot.sale-
            &scop FTs3
            &scop FT4
            &scop FT5
            {&price-trio-list}
          .
        end.
      end.
    end.
  end.

end procedure. /* store-aht-stk-tot */


procedure aht_store-stk-line :

  define parameter buffer buf_temp-aht-ot-line for temp-aht-ot-line .
  define input  parameter p-stk-sum-type   as character no-undo .
  define input  parameter p-fact-order     like ub.trn-doc.fact-order   no-undo .
  define input  parameter p-cut-fact-order like ub.trn-doc.fact-order   no-undo .
  define input  parameter p-ext-doc-type   like ub.trn-doc.ext-doc-type no-undo .
  define input  parameter p-update-sale    as logical   no-undo .

  define buffer buf_aht-stk-line for ub.aht-stk-line .
  define buffer new-buf_aht-stk-line for ub.aht-stk-line .

  do
  on error undo, return error return-value
  :
    /* создаём остаток на конец дня */
    find last buf_aht-stk-line exclusive-lock
      where buf_aht-stk-line.obj-type   = buf_temp-aht-ot-line.obj-type
        and buf_aht-stk-line.obj-code   = buf_temp-aht-ot-line.obj-code
        and buf_aht-stk-line.gds-code   = buf_temp-aht-ot-line.gds-code
        and buf_aht-stk-line.sum-type   = p-stk-sum-type
        and buf_aht-stk-line.fact-order <= p-fact-order
      use-index category
      no-error .
    if not available buf_aht-stk-line
    or buf_aht-stk-line.fact-order <> p-fact-order
    then do:
      create new-buf_aht-stk-line .
      assign
        new-buf_aht-stk-line.obj-type   = buf_temp-aht-ot-line.obj-type
        new-buf_aht-stk-line.obj-code   = buf_temp-aht-ot-line.obj-code
        new-buf_aht-stk-line.gds-code   = buf_temp-aht-ot-line.gds-code
        new-buf_aht-stk-line.fact-order = p-fact-order
        new-buf_aht-stk-line.sum-type   = p-stk-sum-type
      .
      if available buf_aht-stk-line then do:
        assign
          new-buf_aht-stk-line.fact-qnty = buf_aht-stk-line.fact-qnty
          &scop fp1   new-buf_aht-stk-line.cost-
          &scop fps1
          &scop fp2   = buf_aht-stk-line.cost-
          &scop fps2
          &scop fp3
          &scop fp4
          {&price-pair-list}
          &scop fp1   new-buf_aht-stk-line.crsa-
          &scop fps1
          &scop fp2   = buf_aht-stk-line.crsa-
          &scop fps2
          &scop fp3
          &scop fp4
          {&price-pair-list}
        .
        if p-update-sale then do:
          assign
            &scop fp1   new-buf_aht-stk-line.sale-
            &scop fps1
            &scop fp2   = buf_aht-stk-line.sale-
            &scop fps2
            &scop fp3
            &scop fp4
            {&price-pair-list}
          .
        end.
      end.
    end.

    /* обновляем текущий и все более поздние остатки */
    if p-stk-sum-type <> {&aht-service}
    then do:
      for each buf_aht-stk-line exclusive-lock
        where buf_aht-stk-line.obj-type   = buf_temp-aht-ot-line.obj-type
          and buf_aht-stk-line.obj-code   = buf_temp-aht-ot-line.obj-code
          and buf_aht-stk-line.gds-code   = buf_temp-aht-ot-line.gds-code
          and buf_aht-stk-line.sum-type   = p-stk-sum-type
          and buf_aht-stk-line.fact-order >= p-fact-order
          and buf_aht-stk-line.fact-order <= p-cut-fact-order
      :
        assign
          buf_aht-stk-line.fact-qnty = buf_aht-stk-line.fact-qnty + buf_temp-aht-ot-line.fact-qnty
          &scop FT1  buf_aht-stk-line.cost-
          &scop FTs1
          &scop FT2  = buf_aht-stk-line.cost-
          &scop FTs2
          &scop FT3  + buf_temp-aht-ot-line.cost-
          &scop FTs3
          &scop FT4
          &scop FT5
          {&price-trio-list}
          &scop FT1  buf_aht-stk-line.crsa-
          &scop FTs1
          &scop FT2  = buf_aht-stk-line.crsa-
          &scop FTs2
          &scop FT3  + buf_temp-aht-ot-line.crsa-
          &scop FTs3
          &scop FT4
          &scop FT5
          {&price-trio-list}
        .
        if p-update-sale then do:
          assign
            &scop FT1  buf_aht-stk-line.sale-
            &scop FTs1
            &scop FT2  = buf_aht-stk-line.sale-
            &scop FTs2
            &scop FT3  + buf_temp-aht-ot-line.sale-
            &scop FTs3
            &scop FT4
            &scop FT5
            {&price-trio-list}
          .
        end.
      end.
    end.
  end.

end procedure. /* store-aht-stk-line */



procedure aht_store-ot-table :

  define buffer buf_temp-aht-ot-tot for temp-aht-ot-tot .
  define buffer buf_aht-ot-tot for ub.aht-ot-tot .
  define buffer buf_temp-aht-ot-line for temp-aht-ot-line .
  define buffer buf_aht-ot-line for ub.aht-ot-line .
  define buffer buf_temp-aht-stk-tot for temp-aht-stk-tot .
  define buffer buf_aht-stk-tot for ub.aht-stk-tot .
  define buffer buf_temp-aht-stk-line for temp-aht-stk-line .
  define buffer buf_aht-stk-line for ub.aht-stk-line .

  do
  on error undo, return error
  :
    for each buf_temp-aht-ot-tot
    on error undo, return error
    :
      if
      &scop fl1  buf_temp-aht-ot-tot.cost-
      &scop fls1
      &scop fl2  = ?
      &scop fl3  or
      {&price-single-list}
      or
      &scop fl1  buf_temp-aht-ot-tot.crsa-
      &scop fls1
      &scop fl2  = ?
      &scop fl3  or
      {&price-single-list}
      or
      &scop fl1  buf_temp-aht-ot-tot.sale-
      &scop fls1
      &scop fl2  = ?
      &scop fl3  or
      {&price-single-list}
      then do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info{&vssseq} skip
          "При расчета складского архива по типам приобретения получено неопределенное значение" skip
          "Документ" buf_temp-aht-ot-tot.doc-code skip
          "Тип суммы" buf_temp-aht-ot-tot.sum-type skip
          view-as alert-box error .

        output stream ahtlog to ahtlog.txt append .
        export stream ahtlog
          vss-include-info{&vssseq} buf_temp-aht-ot-tot.doc-code .
        &scop fp1   export stream ahtlog "temp-aht-ot-tot.cost-
        &scop fps1  "
        &scop fp2   buf_temp-aht-ot-tot.cost-
        &scop fps2
        &scop fp3   .
        &scop fp4
        {&price-pair-list}
        &scop fp1   export stream ahtlog "temp-aht-ot-tot.crsa-
        &scop fps1  "
        &scop fp2   buf_temp-aht-ot-tot.crsa-
        &scop fps2
        &scop fp3   .
        &scop fp4
        {&price-pair-list}
        &scop fp1   export stream ahtlog "temp-aht-ot-tot.sale-
        &scop fps1  "
        &scop fp2   buf_temp-aht-ot-tot.sale-
        &scop fps2
        &scop fp3   .
        &scop fp4
        {&price-pair-list}
        output stream ahtlog close .


        undo, return error .
      end.

      find first buf_aht-ot-tot exclusive-lock
        where buf_aht-ot-tot.doc-code = buf_temp-aht-ot-tot.doc-code
          and buf_aht-ot-tot.sum-type = buf_temp-aht-ot-tot.sum-type
        no-error .
      if not available buf_aht-ot-tot then do:
        create buf_aht-ot-tot .
      end.
      &scop fp1   buf_aht-ot-tot.
      &scop fp2   = buf_temp-aht-ot-tot.
      assign
        {&aht-ot-tot-pair-list}
      .
      assign
        buf_aht-ot-tot.fact-qnty = buf_temp-aht-ot-tot.fact-qnty
        &scop fp1   buf_aht-ot-tot.cost-
        &scop fps1
        &scop fp2   = buf_temp-aht-ot-tot.cost-
        &scop fps2
        &scop fp3
        &scop fp4
        {&price-pair-list}
        &scop fp1   buf_aht-ot-tot.crsa-
        &scop fps1
        &scop fp2   = buf_temp-aht-ot-tot.crsa-
        &scop fps2
        &scop fp3
        &scop fp4
        {&price-pair-list}
        &scop fp1   buf_aht-ot-tot.sale-
        &scop fps1
        &scop fp2   = buf_temp-aht-ot-tot.sale-
        &scop fps2
        &scop fp3
        &scop fp4
        {&price-pair-list}
      .
    end. /*each tt-aht-ot-tot*/


    for each buf_temp-aht-ot-line
    on error undo, return error
    :
      if
      &scop fl1  buf_temp-aht-ot-line.cost-
      &scop fls1
      &scop fl2  = ?
      &scop fl3  or
      {&price-single-list}
      or
      &scop fl1  buf_temp-aht-ot-line.crsa-
      &scop fls1
      &scop fl2  = ?
      &scop fl3  or
      {&price-single-list}
      or
      &scop fl1  buf_temp-aht-ot-line.sale-
      &scop fls1
      &scop fl2  = ?
      &scop fl3  or
      {&price-single-list}
      then do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info{&vssseq} skip
          "При расчета складского архива по типам приобретения получено неопределенное значение" skip
          "Документ" buf_temp-aht-ot-line.doc-code skip
          "Код товара" buf_temp-aht-ot-line.gds-code skip
          "Тип суммы" buf_temp-aht-ot-line.sum-type skip
          view-as alert-box error .
        undo, return error .
      end.

      find first buf_aht-ot-line exclusive-lock
        where buf_aht-ot-line.doc-code  = buf_temp-aht-ot-line.doc-code
          and buf_aht-ot-line.gds-code  = buf_temp-aht-ot-line.gds-code
          and buf_aht-ot-line.sum-type  = buf_temp-aht-ot-line.sum-type
        no-error .
      if not available buf_aht-ot-line then do:
        create buf_aht-ot-line .
      end.
      &scop fp1   buf_aht-ot-line.
      &scop fp2   = buf_temp-aht-ot-line.
      assign
        {&aht-ot-line-pair-list}
      .

      assign
        buf_aht-ot-line.fact-qnty = buf_temp-aht-ot-line.fact-qnty
        &scop fp1   buf_aht-ot-line.cost-
        &scop fps1
        &scop fp2   = buf_temp-aht-ot-line.cost-
        &scop fps2
        &scop fp3
        &scop fp4
        {&price-pair-list}
        &scop fp1   buf_aht-ot-line.crsa-
        &scop fps1
        &scop fp2   = buf_temp-aht-ot-line.crsa-
        &scop fps2
        &scop fp3
        &scop fp4
        {&price-pair-list}
        &scop fp1   buf_aht-ot-line.sale-
        &scop fps1
        &scop fp2   = buf_temp-aht-ot-line.sale-
        &scop fps2
        &scop fp3
        &scop fp4
        {&price-pair-list}
      .
    end. /*each tt-aht-ot-line*/
  end.

end procedure. /* store-ot-table */


procedure aht_add-document :

  define input  parameter p-doc-code     like ub.aht-doc.doc-code     no-undo .
  define input  parameter p-obj-type     like ub.aht-doc.obj-type     no-undo .
  define input  parameter p-obj-code     like ub.aht-doc.obj-code     no-undo .
  define input  parameter p-ext-doc-type like ub.aht-doc.ext-doc-type no-undo .
  define input  parameter p-is-trn-doc   like ub.aht-doc.is-trn-doc   no-undo .
  define input  parameter p-fact-order   like ub.aht-doc.fact-order   no-undo .
  define input  parameter p-fact-date    like ub.aht-doc.fact-date    no-undo .
  define input  parameter p-shift-date   like ub.aht-doc.shift-date   no-undo .
  define input  parameter p-shift-num    like ub.aht-doc.shift-num    no-undo .

  define buffer buf_aht-doc for ub.aht-doc .

  do
  on error undo, return error return-value
  :

    find first buf_aht-doc exclusive-lock
      where buf_aht-doc.doc-code = p-doc-code
      no-error .
    if available buf_aht-doc then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info{&vssseq} skip
        "Попытка повторного создания записи" skip
        "Документ" p-doc-code skip
        view-as alert-box error .
      undo, return error .
    end.

    if p-fact-order = ?
    or p-fact-order = 0
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info{&vssseq} skip
        "Ошибка задания входных параметров" skip
        "Не задан номер документа" skip
        "Документ" p-doc-code skip
        "Номер документа" p-fact-order skip
        view-as alert-box error .
      undo, return error .
    end.

    create buf_aht-doc .
    assign
      buf_aht-doc.doc-code     = p-doc-code
      buf_aht-doc.obj-type     = p-obj-type
      buf_aht-doc.obj-code     = p-obj-code
      buf_aht-doc.ext-doc-type = p-ext-doc-type
      buf_aht-doc.is-trn-doc   = p-is-trn-doc
      buf_aht-doc.fact-order   = p-fact-order
      buf_aht-doc.fact-date    = p-fact-date
      buf_aht-doc.shift-date   = p-shift-date
      buf_aht-doc.shift-num    = p-shift-num
    .
  end.

end procedure. /* aht_add-document */


procedure aht_add-date :

  define input  parameter p-obj-type     like ub.aht-stk.obj-type     no-undo .
  define input  parameter p-obj-code     like ub.aht-stk.obj-code     no-undo .
  define input  parameter p-stk-type     like ub.aht-stk.stk-type     no-undo .
  define input  parameter p-fact-order   like ub.aht-stk.fact-order   no-undo .
  define input  parameter p-fact-date    like ub.aht-stk.fact-date    no-undo .
  define input  parameter p-shift-date   like ub.aht-stk.shift-date   no-undo .
  define input  parameter p-shift-num    like ub.aht-stk.shift-num    no-undo .

  define buffer buf_aht-stk for ub.aht-stk .

  do
  on error undo, return error return-value
  :
    find first buf_aht-stk no-lock
      where buf_aht-stk.obj-type   = p-obj-type
        and buf_aht-stk.obj-code   = p-obj-code
        and buf_aht-stk.stk-type   = p-stk-type
        and buf_aht-stk.fact-order = p-fact-order
      no-error .
    if not available buf_aht-stk then do:
      create buf_aht-stk .
      assign
        buf_aht-stk.obj-type   = p-obj-type
        buf_aht-stk.obj-code   = p-obj-code
        buf_aht-stk.stk-type   = p-stk-type
        buf_aht-stk.fact-order = p-fact-order
        buf_aht-stk.fact-date  = p-fact-date
        buf_aht-stk.shift-date = p-shift-date
        buf_aht-stk.shift-num  = p-shift-num
      .
    end.
  end.

end procedure. /* aht_add-date */


/* $Workfile$ e n d */