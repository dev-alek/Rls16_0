/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определение временной таблицы  для отчета по комиссионному товару

Автор: Бахтадзе Наталья Викторовна
Дата создания: 06/09/03
Author: Bakhtadze Natalya
Creation date: 06/09/03

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define temp-table sj-goods no-undo
/*общая часть*/
field artic     like ub.goods.artic
field prod-type like ub.goods.prod-type
field prod-code like ub.goods.prod-code
field in-code like ub.parts.in-code
field part-code like ub.parts.part-code
field is-out_    as integer
field gds-name   like ub.goods.gds-name format "x(30)"
field unit like ub.goods.unit-base
field qnty              as   decimal

&if "{1}" = "list" &then
field supp-type like ub.clients.obj-type
field supp-code like ub.clients.obj-code
&endif

/*учетная часть*/
/*ставки налогов поставщика*/
field VAT-supp  like ub.parts.VAT-pc
field SLT-supp  like ub.parts.SLT-pc
/*цена учетная без налогов*/
FIELD price-without-tax-cost_ like ub.doc-line.price-rubl
/*сумма учетная без налогов*/
FIELD sum-without-tax-cost_ like ub.doc-line.price-rubl
/*сумма учетного НДС*/
FIELD sum-vat-cost_        like ub.doc-line.price-rubl
/*цена учетная с налогами*/
FIELD price-with-tax-cost_ like ub.doc-line.price-rubl
/*сумма учетная с налогами*/
FIELD sum-with-tax-cost_  like ub.doc-line.price-rubl

/*продажная часть*/

/*цена продажная без налогов*/
FIELD price-without-tax-sale_ like ub.doc-line.price-rubl
/*сумма продажная с налогами*/
FIELD sum-with-tax-sale_  like ub.doc-line.price-rubl
/*сумма продажная без налогов*/
FIELD sum-without-tax-sale_ like ub.doc-line.price-rubl
/*сумма продажного НДС */
FIELD sum-vat-sale_  like ub.doc-line.price-rubl
/*сумма продажного НП */
FIELD sum-slt-sale_  like ub.doc-line.price-rubl
INDEX pi
artic
prod-type
prod-code
&if "{1}" = "list" &then
supp-type
supp-code
&endif
is-out_
Vat-supp
price-with-tax-cost_
in-code
part-code
&if "{1}" = "list" &then
INDEX isupp
supp-type
supp-code
&endif
.

DEFINE VARIABLE my-accum as integer no-undo .
define buffer t-doc for ub.trn-doc.


procedure cr-sj-goods :
define input parameter doc-num like ub.trn-doc.doc-code no-undo.
define input parameter is-out as integer no-undo .
define input parameter ocons-pay like ub.sysconf.purch-code no-undo .
define input parameter ocons-pay-2 like ub.sysconf.purch-code no-undo .

DEFINE VARIABLE prt-qnty as decimal no-undo .
DEFINE VARIABLE v-gds-code like ub.goods.gds-code no-undo .
DEFINE VARIABLE         v-parts-VAt-pc  like ub.parts-attr.vat-pc           no-undo .
DEFINE VARIABLE         v-parts-SLT-pc  like ub.parts-attr.SLT-pc           no-undo .
DEFINE VARIABLE         v-in-code       like ub.parts-attr.income-in-code   no-undo .
DEFINE VARIABLE         v-part-code     like ub.parts-attr.income-part-code no-undo .
define  variable price-rubl-without-tax-sale-b like ub.doc-line.price-rubl no-undo.
define buffer buf_parts-attr for ub.parts-attr.
{ str/in-vatp.i  def }
{ str/out-vatp.i def }

  do
  on error undo, return error
  :
     { cus/e-komis.i {1} }
  end.

end procedure. /* cr-sj-goods */



procedure filltable :
DEFINE VARiable v-host-code like ub.sysconf.host-code no-undo.
DEFINE VARIABLE loc#retail as logical no-undo.
DEFINE VARIABLE real-code like ub.clients.obj-code no-undo.
DEFINE VARIABLE real-type like ub.clients.obj-type no-undo.
DEFINE VARIABLE ocons-pay like ub.sysconf.purch-code no-undo.
DEFINE VARIABLE ocons-pay-2 like ub.sysconf.purch-code no-undo.
DEFINE VARIABLE is-out as integer no-undo .
DEFINE VARIABLE doc-num like ub.trn-doc.doc-code no-undo.
DEFINE VARIABLE offc as logical no-undo.
DEFINE VARIABLE prt-qnty as decimal no-undo .


  do
  on error undo, return error
  :
    run waitfram-show in this-procedure ( input "Ждите") .


    FOR EACH sj-goods :
        delete sj-goods .
    END .
    _obj-list:
    FOR EACH obj-list NO-LOCK:
      { gbl/hostcode.i obj-list.obj-type obj-list.obj-code v-host-code }
      FIND FIRST ub.sysconf NO-LOCK WHERE ub.sysconf.host-code = v-host-code.
      IF AVAIL ub.sysconf
      then
      assign
      loc#retail = ub.sysconf.ord-prt
      real-code = ub.sysconf.sale-code
      real-type = ub.sysconf.sale-type
      ocons-pay = integer({&consignation-code})
      ocons-pay-2 = integer({&old-consignation-code})
      .
      else NEXT _obj-list.
      CASE RS-by:
        when 1 then do:
        /*продажи*/
        _inkas:
          FOR EACH ub.inkas WHERE
                  ub.inkas.doc-date >= X-date-start and
                  ub.inkas.doc-date <= X-date-end AND
                  ub.inkas.obj-code = obj-list.obj-code and
                  ub.inkas.obj-type = obj-list.obj-type AND
                  ub.inkas.status_ = {&fact} NO-LOCK,
              each ub.sale-doc no-lock where
                    ub.sale-doc.inkas-code = ub.inkas.inkas-code
                and ub.sale-doc.order > 0:
            if ub.sale-doc.in-inkas then do:
              FIND FIRST t-doc No-LOCK WHERE
                      t-doc.doc-code = ub.sale-doc.doc-code no-error.
              if available t-doc then do:
                assign
                doc-num = t-doc.doc-code
                is-out = ub.sale-doc.dir
                .
                if t-doc.office then NEXT _inkas.
                run cr-sj-goods in this-procedure (
                                                  input doc-num
                                                  ,input is-out
                                                  ,input ocons-pay
                                                  ,input ocons-pay-2
                                                  ).
              end.
            end.
          END. /*FOR EACH inkas*/
        END. /* RS-by = 1 */
        when 2 then do:
        /*накладные*/
        _trn-doc:
          FOR EACH t-doc NO-LOCK WHERE
                  t-doc.obj-type = obj-list.obj-type AND
                  t-doc.obj-code = obj-list.obj-code AND
                  t-doc.cli-type = real-type AND
                  t-doc.cli-code = real-code AND
                  t-doc.status_ = {&fact} AND
                  t-doc.doc-date >= X-date-start AND
                  t-doc.doc-date <= X-date-end AND
                  t-doc.ext-doc-type = {&TDEDT_Ras_Vnesh}
                  :
            assign
            doc-num = t-doc.doc-code
            offc = t-doc.office
            is-out = 1.
            if offc then NEXT _trn-doc.
            run cr-sj-goods in this-procedure (
                                                input doc-num
                                               ,input is-out
                                               ,input ocons-pay
                                               ,input ocons-pay-2
                                               ).
          END.
          _ret-doc:
          FOR EACH t-doc NO-LOCK WHERE
                  t-doc.obj-type = obj-list.obj-type AND
                  t-doc.obj-code = obj-list.obj-code AND
                  t-doc.cli-type = real-type AND
                  t-doc.cli-code = real-code AND
                  t-doc.status_ = {&fact} AND
                  t-doc.doc-date >= X-date-start AND
                  t-doc.doc-date <= X-date-end AND
                  t-doc.ext-doc-type = {&TDEDT_Vozvrat_Vnesh}:
            assign
            doc-num = t-doc.doc-code
            offc = t-doc.office
            is-out = -1.
            if offc then NEXT _ret-doc.
            run cr-sj-goods in this-procedure (
                                                input doc-num
                                               ,input is-out
                                               ,input ocons-pay
                                               ,input ocons-pay-2
                                               ).
          END.
        END. /*RS-by 2 */
        WHEN 3 or when 4 then do:
          _3trn-doc:
          FOR EACH t-doc NO-LOCK WHERE
                  t-doc.obj-type = obj-list.obj-type AND
                  t-doc.obj-code = obj-list.obj-code AND
                  t-doc.status_ = {&fact} AND
                  t-doc.doc-date >= X-date-start AND
                  t-doc.doc-date <= X-date-end AND
                  (t-doc.ext-doc-type = {&TDEDT_Ras_Vnesh}
                  or t-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_Kass}) :
            assign
            doc-num = t-doc.doc-code
            offc = t-doc.office
            is-out = 1.
            if offc then NEXT _3trn-doc.
            run cr-sj-goods in this-procedure (
                                                input doc-num
                                               ,input is-out
                                               ,input ocons-pay
                                               ,input ocons-pay-2
                                               ).
            if Rs-by = 3 then do:
              if t-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_Kass} then NEXT _3trn-doc.
            end.
          END.
          if Rs-by = 4 then do:
            _3trn-doc-ret:
            FOR EACH t-doc NO-LOCK WHERE
                    t-doc.obj-type = obj-list.obj-type AND
                    t-doc.obj-code = obj-list.obj-code AND
                    t-doc.status_ = {&fact} AND
                    t-doc.doc-date >= X-date-start AND
                    t-doc.doc-date <= X-date-end AND
                    (t-doc.ext-doc-type = {&TDEDT_Vozvrat_Vnesh} OR
                    t-doc.ext-doc-type = {&TDEDT_Vozvrat_Vnesh_Kass}):
              assign
              doc-num = t-doc.doc-code
              offc = t-doc.office
              is-out = - 1.
              if offc then NEXT _3trn-doc-ret.
              run cr-sj-goods in this-procedure (
                                                  input doc-num
                                                ,input is-out
                                                ,input ocons-pay
                                                ,input ocons-pay-2
                                                ).
            END.
          end.
          _spitrn-doc:
          FOR EACH t-doc NO-LOCK WHERE
                  t-doc.obj-type = obj-list.obj-type AND
                  t-doc.obj-code = obj-list.obj-code AND
                  t-doc.status_ = {&fact} AND
                  t-doc.doc-date >= X-date-start AND
                  t-doc.doc-date <= X-date-end AND
                  t-doc.internal = no AND
                  (t-doc.ext-doc-type = {&TDEDT_Spi_Prvo}
                  OR (Rs-by = 4 and
                      t-doc.ext-doc-type = {&TDEDT_Spi_Vnesh})
                  )
                  :
            assign
            doc-num = t-doc.doc-code
            offc = t-doc.office
            is-out = 1.
            if offc then NEXT _spitrn-doc.
            run cr-sj-goods in this-procedure (
                                                input doc-num
                                              ,input is-out
                                              ,input ocons-pay
                                              ,input ocons-pay-2
                                              ).
          END.
        end.
      END CASE.
    END. /*FOR EACH obj*/

    run waitfram-hide in this-procedure .

  end.

end procedure. /* filltable */



/* $Workfile$ e n d */