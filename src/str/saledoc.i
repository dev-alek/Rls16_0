/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Временная таблица хранящая номера автодокументов по продаже

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/03/05
Author: Bakhtadze Natalya
Creation date: 10/03/05

*/


&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&if defined(tsaledoc_i) = 0 or "{3}" <> "" &then

&glob tsaledoc_i


FUNCTION set-sale-doc-PS returns character( buffer buf_sale-doc for ub.sale-doc):
define variable v-ps as character no-undo .
&scop sale-doc-kind buf_sale-doc.doc-kind
if available buf_sale-doc then
assign
v-PS = substitute('&1&2 &1&3&1Кол-во_чеков &4&1строк_чеков &5&1товаров &6&1признаков &7&1'
                    , {&delim-par}
                    , (if buf_sale-doc.chr-office = {&gds-office} then "УСЛУГИ." else "ТОВАРЫ." )
                    , {&sale-doc-name}
                    , buf_sale-doc.chk-amount
                    , buf_sale-doc.gds-amount
                    , buf_sale-doc.tot-lines
                    , buf_sale-doc.tot-dtl
                    ).
else  do:
&scop sale-doc-kind {&TDEDT_Ras_Vnesh_KASS}
assign
v-PS = substitute('&1&2 &1&3&1Кол-во_чеков &4&1строк_чеков &5&1товаров &6&1признаков &7&1'
                    , {&delim-par}
                    , '':U
                    , {&sale-doc-name}
                    , 0
                    , 0
                    , 0
                    , 0
                    ).
end.
return v-ps.
END FUNCTION.
FUNCTION get-sale-doc-kind returns character (
                                             input p-doc-kind as character
                                           , input p-ext-doc-type as character
                                           , output p-order as integer
                                           , output p-msign as integer
                                           , output p-main as logical
                                           , output p-in-inkas as logical
                                           , output p-dir_ as integer
                                           ):
define variable v-doc-kind as character no-undo.
define variable v-type as character no-undo .
define variable v-value as character no-undo .
CASE p-doc-kind:
  when {&TDEDT_Ras_vnesh_kass} then do:
    assign
    p-order = 100
    p-msign = 1
    p-main = yes
    p-in-inkas = yes
    p-dir_ = 1
    .
    return p-ext-doc-type.
  end.
  when  {&TDEDT_vozvrat_vnesh_kass} then do:
    assign
    p-order = 200
    p-msign = - 1
    p-main = no
    p-in-inkas = yes
    p-dir_ = - 1
    .
    return p-ext-doc-type.
  end.
  when {&sale-add-return-write-off} then do:
    assign
    p-msign = - 1
    p-main = no
    p-in-inkas = no
    p-order = 300
    p-dir_ = 1
    .
    return {&sale-add-return-write-off}.
  end.
  when {&sale-add-tech-refuell} then do:
    assign
    p-msign = 1
    p-main = no
    p-in-inkas = no
    p-order = 400
    p-dir_ = 1
    .
    return {&sale-add-tech-refuell}.
  end.
  when {&sale-add-write-off} then do:
   assign
   p-msign = 1
   p-main = no
   p-in-inkas = no
   p-order =  500
   p-dir_ = 1
   .
   return {&sale-add-write-off}.
 end.
 when {&sale-add-vir-res} then do:
   assign
   p-msign = 1
   p-main = no
   p-in-inkas = no
   p-order = 600
   p-dir_ = 1
   .
   return {&sale-add-vir-res}.
 end.
 when {&sale-add2-in-tech-refuell} then do:
   assign
   p-msign = 1
   p-main = no
   p-in-inkas = no
   p-order = -1
   p-dir_ = -1
   .
  return {&sale-add2-in-tech-refuell}.
 end.
 when {&sale-add-nat-gas} then do:
   assign
   p-msign = 1
   p-main = no
   p-in-inkas = no
   p-order = 700
   p-dir_ = 1
   .
   return {&sale-add-nat-gas}.
 end.
 when {&sale-add-ret-nat-gas} then do:
   assign
   p-msign = -1
   p-main = no
   p-in-inkas = no
   p-order = 701
   p-dir_ = -1
   .
   return {&sale-add-ret-nat-gas}.
 end.
 otherwise do:
    /*другие неопределенные типы документов*/
    assign
    p-msign = 1
    p-main = no
    p-in-inkas = no
    p-order = -1.
    return p-ext-doc-type.
  end.
END CASE.
END FUNCTION.

procedure saledoc-create :
define input parameter p-inkas-code like ub.inkas.inkas-code no-undo .
define input parameter p-host-code like ub.sysconf.host-code no-undo .
define input parameter p-obj-type  like ub.clients.obj-type no-undo .
define input parameter p-obj-code  like ub.clients.obj-code no-undo .
define input parameter p-doc-kind as character no-undo .
define input parameter p-office as character no-undo .
define input parameter p-tpsidoc as logical no-undo .
define input parameter p-alias-type-price as character no-undo .
define input parameter p-price-obj-type as character no-undo .
define input parameter p-price-obj-code as integer no-undo .
define parameter buffer buf_trn-doc for ub.trn-doc.

define variable v-order as integer no-undo.
define variable v-main as logical no-undo .
define variable v-in-inkas as logical no-undo .
define variable v-msign as integer no-undo .
define variable v-dir_ as integer no-undo .
define variable v-trn-doc-code as character no-undo .

define buffer buf_sale-doc for ub.sale-doc.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

   if available buf_trn-doc then do:
     v-trn-doc-code = buf_trn-doc.doc-code.
   end.
   find first buf_sale-doc where
            buf_sale-doc.inkas-code = p-inkas-code
        and buf_sale-doc.doc-kind = p-doc-kind
        and buf_sale-doc.chr-office = p-office
        and (v-trn-doc-code = '' or buf_sale-doc.doc-code = v-trn-doc-code)
        no-error .
   if not available buf_sale-doc  then do:
      create buf_sale-doc.
      assign
      buf_sale-doc.inkas-code = p-inkas-code
      buf_sale-doc.storage =  {&table_trn-doc}
      buf_sale-doc.host-code = p-host-code
      buf_sale-doc.obj-type = p-obj-type
      buf_sale-doc.obj-code = p-obj-code
      buf_sale-doc.doc-kind  = p-doc-kind
      buf_sale-doc.order = lookup(p-doc-kind, {&sale-all-doc-kinds}) * 100 + (if p-office = {&gds-office} then 5 else 0)
      buf_sale-doc.chr-office = p-office
      buf_sale-doc.doc-code = v-trn-doc-code
      .
   end.
   if available buf_trn-doc then
   buffer-copy buf_trn-doc
   to buf_sale-doc
   .
&scop sale-doc-kind buf_sale-doc.doc-kind
  assign
  buf_sale-doc.doc-kind = get-sale-doc-kind (
                                             input p-doc-kind
                                            ,input buf_sale-doc.ext-doc-type
                                            ,output v-order
                                            ,output v-msign
                                            ,output v-main
                                            ,output v-in-inkas
                                            ,output v-dir_).

  assign
  buf_sale-doc.order = v-order + (if p-office = {&gds-office} then 5 else 0)
  buf_sale-doc.main-doc = v-main
  buf_sale-doc.in-inkas = v-in-inkas
  buf_sale-doc.msign = v-msign
  buf_sale-doc.dir = v-dir_
  buf_sale-doc.fbrsale = lookup(buf_sale-doc.doc-kind, {&sale-doc-fbrsale}) > 0
  buf_sale-doc.main-receipt-type = integer({&sale-doc-main-receipt-type})
  buf_sale-doc.poss-wro-codes = '':U
  buf_sale-doc.chr-office = p-office
  buf_sale-doc.tpsidoc = p-tpsidoc
  buf_sale-doc.alias-type-price = p-alias-type-price
  buf_sale-doc.price-obj-type = (if p-tpsidoc
                                 then p-price-obj-type
                                 else '':U)
  buf_sale-doc.price-obj-code = (if p-tpsidoc
                                 then p-price-obj-code
                                 else 0)
  .
  assign
  buf_sale-doc.poss-wro-codes = (if (v-order > 0 and {&sale-doc-kind} <> {&sale-add-vir-res}) then {&sale-doc-poss-wro-codes} else '':U)
  no-error.

end. /*doe*/
END.

procedure fbr-saledoc-create :
define input parameter p-inkas-code as character no-undo .

define variable v-pri-prvo-doc-qnty like ub.trn-doc.doc-qnty no-undo .
define variable v-pri-prvo-fact-qnty like ub.trn-doc.doc-qnty no-undo .
define variable v-pri-prvo-tot-lines like ub.trn-doc.tot-lines no-undo .


define buffer buf_fbr-doc for ub.fbr-doc.
define buffer buf_trn-doc for ub.trn-doc.
define buffer buf_sale-doc for ub.sale-doc.
define buffer buf2_sale-doc for ub.sale-doc.
define buffer buf2_trn-doc for ub.trn-doc.
define buffer buf_doc-line for ub.doc-line.
define buffer buf_gds-dtl for ub.gds-dtl.
define buffer buf_chk-gds for ub.chk-gds.
define buffer buf_chk-doc for ub.chk-doc.


do
on error undo, return error
:

&scop create-no-auto-sale-doc ~
         create ~{&my-sale-buffer~}.                                                                                   ~
          buffer-copy ~{&my-buffer~}                                                                                   ~
          to ~{&my-sale-buffer~}.                                                                                      ~
          assign                                                                                                        ~
          ~{&my-sale-buffer~}.storage  =  ~{&table_trn-doc~}                                                                ~
          ~{&my-sale-buffer~}.doc-kind = ~{&my-buffer~}.ext-doc-type                                                      ~
          ~{&my-sale-buffer~}.order =  - 1                                                                                ~
          ~{&my-sale-buffer~}.main-doc = no                                                                                   ~
          ~{&my-sale-buffer~}.in-inkas = no                                                                               ~
          ~{&my-sale-buffer~}.fbrsale = yes                                                                               ~
          ~{&my-sale-buffer~}.msign = 1                                                                                   ~
          ~{&my-sale-buffer~}.filled   = ~{&my-sale-buffer~}.fact-qnty <> 0 or ~{&my-sale-buffer~}.tot-lines <> 0             ~
          ~{&my-sale-buffer~}.doc-qnty = (if ~{&my-sale-buffer~}.ext-doc-type = ~{&TDEDT_Chg_Purch_Code~}                   ~
                                        then ?                                                                          ~
                                        else ~{&my-sale-buffer~}.doc-qnty)                                                ~
          ~{&my-sale-buffer~}.fact-qnty = (if ~{&my-sale-buffer~}.ext-doc-type = ~{&TDEDT_Chg_Purch_Code~}                  ~
                                        then ?                                                                          ~
                                        else ~{&my-sale-buffer~}.fact-qnty)                                              ~
          ~{&my-sale-buffer~}.inkas-code = p-inkas-code



  for each buf_fbr-doc no-lock where
        buf_fbr-doc.out-code = p-inkas-code:
    for each buf_trn-doc no-lock where
          buf_trn-doc.out-code = buf_fbr-doc.doc-code
    by buf_trn-doc.fact-order
    on error undo, return error:
      if buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Prvo}
      or buf_trn-doc.ext-doc-type = {&TDEDT_Pri_Prvo}
      or buf_trn-doc.ext-doc-type = {&TDEDT_Spi_Prvo}
      or buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Perem}
      or buf_trn-doc.ext-doc-type = {&TDEDT_Pri_Perem}
      then do:        /* Добавляем в таблицу только документы, порожденные документом производства */
        find first buf_sale-doc where
                buf_sale-doc.inkas-code = p-inkas-code
            and buf_sale-doc.doc-code = buf_trn-doc.doc-code
            AND buf_sale-doc.storage  = {&table_trn-doc}
                no-error .
        if not available buf_sale-doc then do:
&scop my-buffer  buf_trn-doc
&scop my-sale-buffer  buf_sale-doc
        {&create-no-auto-sale-doc}.
        end.
        if buf_trn-doc.ext-doc-type = {&TDEDT_Pri_Prvo} then do:
          assign
          v-pri-prvo-doc-qnty = buf_trn-doc.doc-qnty
          v-pri-prvo-fact-qnty = buf_trn-doc.fact-qnty
          v-pri-prvo-tot-lines = buf_trn-doc.tot-lines
          .
        end.
        for each buf2_trn-doc no-lock where
                buf2_trn-doc.out-code = buf_sale-doc.doc-code:
          find first buf2_sale-doc where
                  buf2_sale-doc.inkas-code = p-inkas-code
              and buf2_sale-doc.doc-code = buf2_trn-doc.doc-code
              AND buf2_sale-doc.storage = {&table_trn-doc} no-error .
          if not available buf2_sale-doc then do:
&scop my-buffer  buf2_trn-doc
&scop my-sale-buffer  buf2_sale-doc
            {&create-no-auto-sale-doc}.
          end.
        end.
      end.
    end.
    find first buf_sale-doc where
              buf_sale-doc.inkas-code = p-inkas-code
          AND buf_sale-doc.storage = {&table_fbr-doc}
          AND buf_sale-doc.doc-code = buf_fbr-doc.doc-code no-error .
    if not available buf_sale-doc then do:
      create buf_sale-doc.
      assign
      buf_sale-doc.storage       =  {&table_fbr-doc}
      buf_sale-doc.doc-type      = {&manufacturing}
      buf_sale-doc.doc-code      = buf_fbr-doc.doc-code
      buf_sale-doc.ext-doc-type  = {&manufacturing}
      buf_sale-doc.doc-kind      = {&manufacturing}
      buf_sale-doc.obj-type      = buf_fbr-doc.obj-type
      buf_sale-doc.obj-code      = buf_fbr-doc.obj-code
      buf_sale-doc.cli-type      = buf_fbr-doc.obj-type
      buf_sale-doc.cli-code      = buf_fbr-doc.obj-code
      buf_sale-doc.doc-qnty      = v-pri-prvo-doc-qnty
      buf_sale-doc.fact-qnty     = v-pri-prvo-fact-qnty
      buf_sale-doc.tot-lines     = v-pri-prvo-tot-lines
      buf_sale-doc.tot-dtl       = v-pri-prvo-tot-lines
      buf_sale-doc.fbrsale       = yes
      buf_sale-doc.inkas-code    = p-inkas-code
      .
    end.
  end. /*      for each buf_fbr-doc no-lock where*/
end. /*doe*/

end procedure. /* fbr-saledoc-create */


&endif
/*&if defined(tsaledoc_i) = 0 or "{3}" <> "" &then*/


/* $Workfile$   E n d */