/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определения, необходимые для расчета складского архива по поставщикам

Автор: Чернова Светлана Александровна
Дата создания: 07/23/08
Author: Svetlana Chernova
Creation date: 07/23/08

Автор1: Перваков Михаил Сергеевич
Дата создания: 05/25/01

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&glob price-single-list ~
   ~{&FL1~}fact-qnty~{&FLS1~}      ~{&FL2~} ~{&FL3~} ~
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
   ~{&FL1~}other-rubl~{&FLS1~}     ~{&FL2~}

/*
   &scop fl1
   &scop fls1
   &scop fl2
   &scop fl3
   {&price-single-list}
*/

&glob price-pair-list ~
   ~{&FP1~}fact-qnty~{&FPS1~}      ~{&FP2~}fact-qnty~{&FPS2~}       ~{&FP3~} ~{&FP4~} ~
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
   ~{&FP1~}other-rubl~{&FPS1~}     ~{&FP2~}other-rubl~{&FPS2~}      ~{&FP3~}

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
   ~{&FT1~}fact-qnty~{&FTS1~}      ~{&FT2~}fact-qnty~{&FTS2~}      ~{&FT3~}fact-qnty~{&FTS3~}      ~{&FT4~} ~{&FT5~} ~
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
   ~{&FT1~}other-rubl~{&FTS1~}     ~{&FT2~}other-rubl~{&FTS2~}     ~{&FT3~}other-rubl~{&FTS3~}     ~{&FT4~}

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
   ~{&fq1~}fact-qnty~{&fqS1~}      ~{&fq2~}fact-qnty~{&fqS2~}      ~{&fq3~}fact-qnty~{&fqS3~}      ~{&fq4~}fact-qnty~{&fqS4~}      ~{&fq5~} ~{&fq6~} ~
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
   ~{&fq1~}other-rubl~{&fqS1~}     ~{&fq2~}other-rubl~{&fqS2~}     ~{&fq3~}other-rubl~{&fqS3~}     ~{&fq4~}other-rubl~{&fqS4~}     ~{&fq5~}


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


&scop FT1    field new-
&scop FTs1
&scop FT2    like ub.stk-supp-tot.
&scop FTs2
&scop FT3    column-label 'new-
&scop FTs3   '
&scop FT4
&scop FT5
&glob def-temp-stk-supp-tot define temp-table temp-stk-supp-tot no-undo like ub.stk-supp-tot ~
  {&price-trio-list} ~
  index pi is primary unique  obj-type obj-code cli-type cli-code fact-order sum-type cat-id ~
  index category              obj-type obj-code cli-type cli-code sum-type cat-id fact-order ~
  index sum-type              sum-type cat-id .

&scop FT1    field new-
&scop FTs1
&scop FT2    like ub.stk-supp-tot.
&scop FTs2
&scop FT3    column-label 'new-
&scop FTs3   '
&scop FT4
&scop FT5
&glob def-temp-shift-stk-supp-tot define temp-table temp-shift-stk-supp-tot no-undo like ub.stk-supp-tot ~
  {&price-trio-list} ~
  index pi is primary unique  obj-type obj-code cli-type cli-code fact-order sum-type cat-id ~
  index category              obj-type obj-code cli-type cli-code sum-type cat-id fact-order ~
  index sum-type              sum-type cat-id .


&scop FT1    field new-
&scop FTs1
&scop FT2    like ub.stk-supp-line.
&scop FTs2
&scop FT3    column-label 'new-
&scop FTs3   '
&scop FT4
&scop FT5
&glob def-temp-stk-supp-line define temp-table temp-stk-supp-line no-undo like ub.stk-supp-line ~
  {&price-trio-list} ~
  index pi is primary unique obj-type obj-code cli-type cli-code artic prod-type prod-code fact-order sum-type cat-id ~
  index category             obj-type obj-code cli-type cli-code artic prod-type prod-code sum-type cat-id fact-order ~
  index sum-type             sum-type cat-id .

&scop FT1    field new-
&scop FTs1
&scop FT2    like ub.stk-supp-line.
&scop FTs2
&scop FT3    column-label 'new-
&scop FTs3   '
&scop FT4
&scop FT5
&glob def-temp-shift-stk-supp-line define temp-table temp-shift-stk-supp-line no-undo like ub.stk-supp-line ~
  {&price-trio-list} ~
  index pi is primary unique obj-type obj-code cli-type cli-code artic prod-type prod-code fact-order sum-type cat-id ~
  index category             obj-type obj-code cli-type cli-code artic prod-type prod-code sum-type cat-id fact-order ~
  index sum-type             sum-type cat-id .

&scop FT1    field new-
&scop FTs1
&scop FT2    like ub.ot-supp-tot.
&scop FTs2
&scop FT3    column-label 'new-
&scop FTs3   '
&scop FT4
&scop FT5
&glob def-temp-ot-supp-tot define temp-table temp-ot-supp-tot no-undo like ub.ot-supp-tot ~
  {&price-trio-list} ~
  index pi is primary unique doc-code cli-type cli-code sum-type cat-id ~
  index obj-ot               obj-type obj-code cli-type cli-code fact-order sum-type cat-id ~
  index sum-type             sum-type cat-id .


&scop FT1    field new-
&scop FTs1
&scop FT2    like ub.ot-supp-line.
&scop FTs2
&scop FT3    column-label 'new-
&scop FTs3   '
&scop FT4
&scop FT5
&glob def-temp-ot-supp-line define temp-table temp-ot-supp-line no-undo like ub.ot-supp-line ~
  {&price-trio-list} ~
  index pi is primary unique  doc-code cli-type cli-code artic prod-type prod-code sum-type cat-id ~
  index art-ot                obj-type obj-code cli-type cli-code artic prod-type prod-code fact-order sum-type cat-id ~
  index sum-type              sum-type cat-id .

&glob def-temp-init-stk-supp-tot define temp-table temp-init-stk-supp-tot no-undo ~
  field cli-type  like ub.stk-supp-tot.cli-type  ~
  field cli-code  like ub.stk-supp-tot.cli-code  ~
  index xpk is primary unique cli-type cli-code .

&glob def-temp-init-stk-supp-line define temp-table temp-init-stk-supp-line no-undo ~
  field cli-type  like ub.stk-supp-line.cli-type  ~
  field cli-code  like ub.stk-supp-line.cli-code  ~
  field artic     like ub.stk-supp-line.artic     ~
  field prod-type like ub.stk-supp-line.prod-type ~
  field prod-code like ub.stk-supp-line.prod-code ~
  index xpk is primary unique cli-type cli-code artic prod-type prod-code .

&scop fp1   def var v-
&scop fps1
&scop fp2   like ub.ot-supp-tot.
&scop fps2
&scop fp3   no-undo .
&scop fp4
&glob def-var-supp-list {&price-pair-list}

&scop fp1   def var v-sale-
&scop fps1
&scop fp2   like ub.ot-supp-tot.
&scop fps2
&scop fp3   no-undo .
&scop fp4
&glob def-var-sale-list {&price-pair-list}

&glob ot-supp-tot-pair-list ~
  ~{&FP1~}doc-code     ~{&FP2~}doc-code     ~
  ~{&FP1~}cli-type     ~{&FP2~}cli-type     ~
  ~{&FP1~}cli-code     ~{&FP2~}cli-code     ~
  ~{&FP1~}sum-type     ~{&FP2~}sum-type     ~
  ~{&FP1~}cat-id       ~{&FP2~}cat-id       ~
  ~{&FP1~}ext-doc-type ~{&FP2~}ext-doc-type ~
  ~{&FP1~}obj-type     ~{&FP2~}obj-type     ~
  ~{&FP1~}obj-code     ~{&FP2~}obj-code     ~
  ~{&FP1~}fact-order   ~{&FP2~}fact-order

&glob ot-supp-line-pair-list ~
  ~{&FP1~}doc-code     ~{&FP2~}doc-code     ~
  ~{&FP1~}cli-type     ~{&FP2~}cli-type     ~
  ~{&FP1~}cli-code     ~{&FP2~}cli-code     ~
  ~{&FP1~}artic        ~{&FP2~}artic        ~
  ~{&FP1~}prod-type    ~{&FP2~}prod-type    ~
  ~{&FP1~}prod-code    ~{&FP2~}prod-code    ~
  ~{&FP1~}sum-type     ~{&FP2~}sum-type     ~
  ~{&FP1~}cat-id       ~{&FP2~}cat-id       ~
  ~{&FP1~}ext-doc-type ~{&FP2~}ext-doc-type ~
  ~{&FP1~}obj-type     ~{&FP2~}obj-type     ~
  ~{&FP1~}obj-code     ~{&FP2~}obj-code     ~
  ~{&FP1~}fact-order   ~{&FP2~}fact-order

&glob stk-supp-tot-pair-list  ~
  ~{&FP1~}obj-type     ~{&FP2~}obj-type   ~
  ~{&FP1~}obj-code     ~{&FP2~}obj-code   ~
  ~{&FP1~}cli-type     ~{&FP2~}cli-type   ~
  ~{&FP1~}cli-code     ~{&FP2~}cli-code   ~
  ~{&FP1~}fact-order   ~{&FP2~}fact-order ~
  ~{&FP1~}sum-type     ~{&FP2~}sum-type   ~
  ~{&FP1~}cat-id       ~{&FP2~}cat-id     ~
  ~{&FP1~}fact-date    ~{&FP2~}fact-date  ~
  ~{&FP1~}shift-num    ~{&FP2~}shift-num  ~
  ~{&FP1~}shift-date   ~{&FP2~}shift-date

&glob stk-supp-line-pair-list  ~
  ~{&FP1~}obj-type     ~{&FP2~}obj-type   ~
  ~{&FP1~}obj-code     ~{&FP2~}obj-code   ~
  ~{&FP1~}cli-type     ~{&FP2~}cli-type   ~
  ~{&FP1~}cli-code     ~{&FP2~}cli-code   ~
  ~{&FP1~}artic        ~{&FP2~}artic      ~
  ~{&FP1~}prod-type    ~{&FP2~}prod-type  ~
  ~{&FP1~}prod-code    ~{&FP2~}prod-code  ~
  ~{&FP1~}fact-order   ~{&FP2~}fact-order ~
  ~{&FP1~}sum-type     ~{&FP2~}sum-type   ~
  ~{&FP1~}cat-id       ~{&FP2~}cat-id     ~
  ~{&FP1~}fact-date    ~{&FP2~}fact-date  ~
  ~{&FP1~}shift-num    ~{&FP2~}shift-num  ~
  ~{&FP1~}shift-date   ~{&FP2~}shift-date

/* $Workfile$ e n d */