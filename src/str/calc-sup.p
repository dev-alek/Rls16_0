block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: calc-sup.p $
$Archive: str/calc-sup.p $

Определение сумм по документу по различным разбиениям

Автор: Чернова Светлана Александровна
Дата создания: 10/10/06
Author: Svetlana Chernova
Creation date: 10/10/06

create: Суслов Алексей Юрьевич

*/

/* ******************************************************************************************************************** *\

Input Parameters:
  rec-id     - recid записи trn-doc;
  use-table  - список временных таблиц необходимых для употребления:
    tt-title                 - титульные переменные тип приобретения (создаются всегда);
    d-supp-grp               - разбивка по поставщикам - тип приобретения - группа товаров/услуг;
    d-supp                   - разбивка по поставщикам - тип приобретения;
    d-slt-vat                - разбивка НДС реализации - НП реализации;
    d-slt-vat-cons           - разбивка НДС реализации - НП реализации - тип приобретения;
    d-slt-vat-cons-grp       - разбивка НДС реализации - НП реализации - тип приобретения - группа товаров/услуг;
    d-supp-slts-vats         - разбивка по поставщикам - НДС поставщика - НП поставщика;
    d-slts-vats              - разбивка НДС поставщика - НП поставщика;
    d-slts-vats-cons         - разбивка НДС поставщика - НП поставщика - тип приобретения;
    d-slts-vats-cons-grp     - разбивка НДС поставщика - НП поставщика - тип приобретения - группа товаров/услуг;
               и договоры:
    tt-title-fin             - титульные переменные "тип приобретения - договор" (создаются, если есть хоть одна таблица
                               с разбиением на договоры);
    d-supp-grp-fin           - разбивка по поставщикам - тип приобретения - группа товаров/услуг - договоры;
    d-supp-fin               - разбивка по поставщикам - тип приобретения - договоры;
    d-slt-vat-cons-fin       - разбивка НДС реализации - НП реализации - тип приобретения - договоры;
    d-slt-vat-cons-grp-fin   - разбивка НДС реализации - НП реализации - тип приобретения - группа товаров/услуг - договоры;
    d-supp-slts-vats-fin     - разбивка по поставщикам - НДС поставщика - НП поставщика   - договоры;
    d-slts-vats-cons-fin     - разбивка НДС поставщика - НП поставщика - тип приобретения - договоры;
    d-slts-vats-cons-grp-fin - разбивка НДС поставщика - НП поставщика - тип приобретения - группа товаров/услуг - договоры;
  mes-on     - yes - ругается, no - все молча делает;
  inv-type   - важен только для инвентаризации: = излишки (2), недостача (3) - информация по соответствующим строкам,
               любое другое значение - то и другое вместе;
  is-wait-on - yes - запускать wait-on / wait-off, no - не запускать.

\* ******************************************************************************************************************** */

/* расчет сумм по trn-doc по консигнации и выкупу */
define input parameter rec-id     as recid     no-undo. /* recid записи trn-doc */
define input parameter use-table  as character no-undo. /* список временных таблиц */
define input parameter mes-on     as logical   no-undo. /* yes - ругается, no - все молча делает */
define input parameter inv-type   as integer   no-undo. /* для инвентаризации: излишки (2), недостача (3) */
define input parameter is-wait-on as logical   no-undo. /* yes - запускать wait-on / wait-off, no - не запускать */

define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U.
define variable vss-author      as character no-undo initial "$Author: expertek $":U.
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U.
define variable vss-workfile    as character no-undo initial "$Workfile: calc-sup.p $":U.
define variable vss-archive     as character no-undo initial "$Archive: str/calc-sup.p $":U.
define variable vss-description as character no-undo initial "Определение сумм по документу по различным разбиениям ":U.

{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|5',rec-id,use-table,mes-on,inv-type,is-wait-on)" }

{ cmp/str-glbl.i }
{ cmp/library.i  }
{ str/trdcalib.i }
{ str/clcprtsl.i only-one-parts }
{ gbl/waitfram.i }
{ str/d-supp.i   }
{ str/out-vatp.i def }
{ str/out-vatp.i def "''" "''" "''" -cur }

define buffer bf_trn-doc  for ub.trn-doc.
define buffer bf_sysconf  for ub.sysconf.
define buffer bf_doc-line for ub.doc-line.
define buffer bf_goods    for ub.goods.
define buffer bf_parts    for ub.parts.
define buffer bf_clients  for ub.clients.
define buffer bf_gds-dtl  for ub.gds-dtl.

define variable varprice-sale       like ub.price-list.price-sale no-undo.
define variable vardoc-num          like ub.price-doc.doc-num     no-undo.
define variable varb-code           like ub.bar-code.b-code       no-undo.
define variable varr-b              as   character                no-undo.
define variable varr-btype          as   character                no-undo.
define variable varcur-vat-pc       like ub.doc-line.vat-pc       no-undo.
define variable varcur-cons-vat-pc  like ub.doc-line.cons-vat-pc  no-undo.
define variable varcur-slt-pc       like ub.doc-line.slt-pc       no-undo.
define variable varcur-base         like ub.gds-dtl.price-base    no-undo.
define variable varcur-road-tax     like ub.doc-line.road-tax     no-undo.
define variable varcur-excise       like ub.doc-line.excise       no-undo.
define variable varcur-fact-qnty    like ub.gds-dtl.fact-qnty     no-undo.
define variable vartime             as   integer                  no-undo.
define variable varcount            as   integer                  no-undo.
define variable varoutput-string    as   character                no-undo.
define variable varlastcur-base     like ub.gds-dtl.price-base    no-undo.
define variable varlastcur-road-tax like ub.gds-dtl.price-base    no-undo.
define variable varlastcur-excise   like ub.gds-dtl.price-base    no-undo.
define variable varroad-tax         like ub.price-list.road-tax   no-undo.
define variable varexcise           like ub.price-list.excise     no-undo.
define variable varfull-name-grp    as   character                no-undo.
define variable varcalc-title-fin   as   logical                  no-undo initial ?.

define variable sum-price-rubl-with-tax-sale     like ub.doc-line.price-rubl no-undo.
define variable sum-price-base-with-tax-sale     like ub.doc-line.price-base no-undo.
define variable sum-vat-base-sale                like ub.doc-line.price-base no-undo.
define variable sum-vat-rubl-sale                like ub.doc-line.price-rubl no-undo.
define variable sum-vat-base-buyer               like ub.doc-line.price-base no-undo.
define variable sum-vat-rubl-buyer               like ub.doc-line.price-rubl no-undo.
define variable sum-slt-base-sale                like ub.doc-line.price-base no-undo.
define variable sum-slt-rubl-sale                like ub.doc-line.price-rubl no-undo.
define variable sum-road-tax-base-sale           like ub.doc-line.road-tax   no-undo.
define variable sum-road-tax-rubl-sale           like ub.doc-line.road-tax   no-undo.
define variable sum-excise-base-sale             like ub.doc-line.price-base no-undo.
define variable sum-excise-rubl-sale             like ub.doc-line.price-rubl no-undo.
define variable sum-discnt-base-sale             like ub.gds-dtl.discnt-base no-undo.
define variable sum-discnt-rubl-sale             like ub.gds-dtl.discnt-rubl no-undo.
define variable sum-price-rubl-with-tax-sale-cur like ub.doc-line.price-rubl no-undo.
define variable sum-price-base-with-tax-sale-cur like ub.doc-line.price-base no-undo.
define variable sum-vat-base-sale-cur            like ub.doc-line.price-base no-undo.
define variable sum-vat-rubl-sale-cur            like ub.doc-line.price-rubl no-undo.
define variable sum-vat-base-buyer-cur           like ub.doc-line.price-base no-undo.
define variable sum-vat-rubl-buyer-cur           like ub.doc-line.price-rubl no-undo.
define variable sum-slt-base-sale-cur            like ub.doc-line.price-base no-undo.
define variable sum-slt-rubl-sale-cur            like ub.doc-line.price-rubl no-undo.
define variable sum-road-tax-base-sale-cur       like ub.doc-line.road-tax   no-undo.
define variable sum-road-tax-rubl-sale-cur       like ub.doc-line.road-tax   no-undo.
define variable sum-excise-base-sale-cur         like ub.doc-line.price-base no-undo.
define variable sum-excise-rubl-sale-cur         like ub.doc-line.price-rubl no-undo.
define variable sum-discnt-base-sale-cur         like ub.gds-dtl.discnt-base no-undo.
define variable sum-discnt-rubl-sale-cur         like ub.gds-dtl.discnt-rubl no-undo.
define variable varqnty                          as   decimal                no-undo.
define variable varvat-pc-doc                    like ub.doc-line.vat-pc     no-undo.

/* ***************************  Main Block  *************************** */
assign varcalc-title-fin = lookup( "tt-title-fin",              use-table ) > 0 or
                           lookup( "d-supp-fin",                use-table ) > 0 or
                           lookup( "d-supp-grp-fin",            use-table ) > 0 or
                           lookup( "d-slt-vat-cons-fin",        use-table ) > 0 or
                           lookup( "d-slt-vat-cons-grp-fin",    use-table ) > 0 or
                           lookup( "d-supp-slts-vats-cons-fin", use-table ) > 0 or
                           lookup( "d-slts-vats-cons-fin",      use-table ) > 0 or
                           lookup( "d-slts-vats-cons-grp-fin",  use-table ) > 0.

find first bf_trn-doc no-lock where recid( bf_trn-doc ) = rec-id.
find first bf_sysconf no-lock where bf_sysconf.host-code = bf_trn-doc.host-code.

run ClearAllTempTables in this-procedure.
assign vartime  = TIME
       varcount = 0.
{ gbl/curr-r-b.i
  varr-b
}

line:
for each bf_doc-line no-lock where
         bf_doc-line.doc-code = bf_trn-doc.doc-code
on error undo, return error substitute( "&1 &2 &3", return-value, error-status :get-message( 1 ),
                                                                  error-status :get-message( 2 ) ) :
  if is-wait-on then do:
    assign varcount = varcount + 1.
    run waitfram-join in this-procedure (  input substitute( "Расчет по строкам товаров. Товар: &1 &2 &3.",
                                                             bf_doc-line.artic,
                                                             bf_doc-line.prod-type,
                                                             bf_doc-line.prod-code ),
                                           input substitute( "Обработано строк: &1", varcount ),
                                           input substitute( "Время: &1", TIME - vartime ),
                                          output varoutput-string ).
    run waitfram-show in this-procedure (  input varoutput-string ).
  end.
  /* при инв-и отбираем только интересующие записи */
  if ( bf_trn-doc.ext-doc-type = {&TDEDT_Inv} or bf_trn-doc.ext-doc-type = {&TDEDT_Peresort}      ) and
     ( inv-type = 2 and bf_doc-line.fact-qnty <= 0 or inv-type = 3 and bf_doc-line.fact-qnty >= 0 ) then do:
    next.
  end.
  find first bf_goods no-lock where
             bf_goods.artic     = bf_doc-line.artic     and
             bf_goods.prod-type = bf_doc-line.prod-type and
             bf_goods.prod-code = bf_doc-line.prod-code.
  run str/fnamegrp.p ( input bf_goods.grp-code, output varfull-name-grp ).
  if bf_trn-doc.office then do:
    run calc-office in this-procedure.
    if is-wait-on then do: run waitfram-hide in this-procedure. end.
    return.
  end.
  /* Если есть по строке хотя бы одна партия */
  find first bf_parts no-lock where
             bf_parts.out-code  = bf_trn-doc.doc-code   and
             bf_parts.obj-type  = bf_trn-doc.obj-type   and
             bf_parts.obj-code  = bf_trn-doc.obj-code   and
             bf_parts.artic     = bf_doc-line.artic     and
             bf_parts.prod-type = bf_doc-line.prod-type and
             bf_parts.prod-code = bf_doc-line.prod-code no-error.
  if not available bf_parts then do:
    run peresortica_gds-dtl in this-procedure.
    if return-value = "line":u then do:
      next line.
    end.
  end. /* нет ни одной партии */
  assign varlastcur-base      = 0
         varlastcur-road-tax  = 0
         varlastcur-excise    = 0
         varcur-base          = 0
         varcur-road-tax      = 0
         varcur-excise        = 0
         varcur-vat-pc        = 0
         varcur-slt-pc        = 0
         varcur-fact-qnty     = 0.
  /* найдем значения налогов для товара на момент закрытия документа */
  { gbl/gdsbcode.i bf_goods.gds-code ? varb-code }
  /* по умолчанию налоги берутся из последней переоценки */
  { gbl/bcprcex.i bf_trn-doc.obj-type bf_trn-doc.obj-code varb-code 0 bf_trn-doc.fact-order vardoc-num varprice-sale varroad-tax varexcise varcur-vat-pc varcur-slt-pc }
  if varprice-sale = ? then do:
    assign varcur-vat-pc = 0
           varcur-slt-pc = 0.
  end.
  /* Если в переоценке налоги не заданы - берем текущие налоги на дату закрытия документа */
  if varcur-vat-pc = ? then do:
    { gbl/pftxvalg.i bf_goods.gds-code {&vat-tax-code} bf_trn-doc.fact-date bf_trn-doc.host-code bf_trn-doc.obj-type bf_trn-doc.obj-code varcur-vat-pc }
  end.
  if varcur-slt-pc = ? then do:
    { gbl/pftxvalg.i bf_goods.gds-code {&slt-tax-code} bf_trn-doc.fact-date bf_trn-doc.host-code bf_trn-doc.obj-type bf_trn-doc.obj-code varcur-slt-pc }
  end.
  if varcur-vat-pc = ? then do:
    return error substitute( "Нет текущего продажного НДС по товару &1 &2 &3", bf_goods.artic,
                                                                               bf_goods.prod-type,
                                                                               bf_goods.prod-code ).
  end.
  if varcur-slt-pc = ? then do:
    return error substitute( "Нет текущего продажного НП по товару &1 &2 &3", bf_goods.artic,
                                                                              bf_goods.prod-type,
                                                                              bf_goods.prod-code ).
  end.
  find first bf_sysconf where bf_sysconf.host-code = bf_trn-doc.host-code no-lock.
  assign varcur-cons-vat-pc = bf_sysconf.cons-vat-pc.
  if varcur-cons-vat-pc = ? then do:
    return error substitute( "Нет текущего продажного консигнационного НДС по фирме &1", bf_trn-doc.host-code ).
  end.
  for each bf_gds-dtl no-lock where
           bf_gds-dtl.doc-code  = bf_doc-line.doc-code  and
           bf_gds-dtl.artic     = bf_doc-line.artic     and
           bf_gds-dtl.prod-type = bf_doc-line.prod-type and
           bf_gds-dtl.prod-code = bf_doc-line.prod-code on error undo, return error return-value :
    { gbl/gdsbcode.i bf_goods.gds-code bf_gds-dtl.prt-code varb-code no-error}
    { gbl/bcodeprc.i bf_trn-doc.obj-type bf_trn-doc.obj-code varb-code 0 bf_trn-doc.fact-order vardoc-num varprice-sale varroad-tax varexcise }
    if varprice-sale = ? then do:
      assign varprice-sale = 0
             varroad-tax   = 0
             varexcise     = 0.
    end.
    assign varlastcur-base     = varprice-sale
           varlastcur-road-tax = varroad-tax
           varlastcur-excise   = varexcise
           varcur-base         = varcur-base      + varprice-sale * bf_gds-dtl.fact-qnty
           varcur-road-tax     = varcur-road-tax  + varroad-tax   * bf_gds-dtl.fact-qnty
           varcur-excise       = varcur-excise    + varexcise     * bf_gds-dtl.fact-qnty
           varcur-fact-qnty    = varcur-fact-qnty +                 bf_gds-dtl.fact-qnty.
  end. /* for each bf_gds-dtl */
  if varcur-fact-qnty = 0 then do:
    assign varcur-base      = varlastcur-base
           varcur-road-tax  = varlastcur-road-tax
           varcur-excise    = varlastcur-excise.
  end.                    else do:
    assign varcur-base      = varcur-base     / varcur-fact-qnty
           varcur-road-tax  = varcur-road-tax / varcur-fact-qnty
           varcur-excise    = varcur-excise   / varcur-fact-qnty.
  end.

  doc-parts:
  for each bf_parts no-lock where
           bf_parts.out-code  = bf_doc-line.doc-code  and
           bf_parts.obj-type  = bf_trn-doc.obj-type   and
           bf_parts.obj-code  = bf_trn-doc.obj-code   and
           bf_parts.artic     = bf_doc-line.artic     and
           bf_parts.prod-type = bf_doc-line.prod-type and
           bf_parts.prod-code = bf_doc-line.prod-code on error undo, return error return-value :
    if ( bf_trn-doc.ext-doc-type = {&TDEDT_Corr_Acc_Price}        or
         bf_trn-doc.ext-doc-type = {&TDEDT_Chg_Purch_Code}        or
         bf_trn-doc.ext-doc-type = {&TDEDT_Corr_Minus_Parts})     and
       ( inv-type = 2 and bf_parts.in-code <> bf_parts.out-code   or
         inv-type = 3 and bf_parts.in-code  = bf_parts.out-code ) then do:
       next doc-parts.
    end.

    &scop purchase-code string( bf_parts.purch-code )

    find first tt-title where tt-title.purch-code = bf_parts.purch-code no-error.
    if not available tt-title then do:
      create tt-title.
      assign tt-title.purch-code = bf_parts.purch-code
             tt-title.purch-name = {&purchase-codes-name}.
    end.

    if varcalc-title-fin = yes then do:
      find first tt-title-fin where
                 tt-title-fin.purch-code    = bf_parts.purch-code    and
                 tt-title-fin.contract-code = bf_parts.contract-code no-error.
      if not available tt-title-fin then do:
        create tt-title-fin.
        assign tt-title-fin.purch-code    = bf_parts.purch-code
               tt-title-fin.purch-name    = {&purchase-codes-name}
               tt-title-fin.contract-code = bf_parts.contract-code.
      end.
    end.
    assign
      varvat-pc-doc = (if bf_parts.purch-code = {&bef-consignation-code} and bf_trn-doc.ext-doc-type <> {&TDEDT_Ras_Vnesh_Vp} then bf_doc-line.cons-vat-pc else bf_doc-line.vat-pc).

    if lookup( "d-slt-vat", use-table ) > 0 then do:
      find first d-slt-vat where
                 d-slt-vat.vat-pc = varvat-pc-doc      and
                 d-slt-vat.slt-pc = bf_doc-line.slt-pc no-error.
      if not available d-slt-vat then do:
        create d-slt-vat.
        assign d-slt-vat.vat-pc = varvat-pc-doc
               d-slt-vat.slt-pc = bf_doc-line.slt-pc.
      end.
    end.
    if lookup( "d-slt-vat-cons", use-table ) > 0 then do:
      find first d-slt-vat-cons where
                 d-slt-vat-cons.vat-pc     = varvat-pc-doc       and
                 d-slt-vat-cons.slt-pc     = bf_doc-line.slt-pc  and
                 d-slt-vat-cons.purch-code = bf_parts.purch-code no-error.
      if not available d-slt-vat-cons then do:
        create d-slt-vat-cons.
        assign d-slt-vat-cons.vat-pc     = varvat-pc-doc
               d-slt-vat-cons.slt-pc     = bf_doc-line.slt-pc
               d-slt-vat-cons.purch-code = bf_parts.purch-code
               d-slt-vat-cons.purch-name = {&purchase-codes-name}.
      end.
    end.

    if lookup( "d-slt-vat-cons-fin", use-table ) > 0 then do:
      find first d-slt-vat-cons-fin where
                 d-slt-vat-cons-fin.vat-pc        = varvat-pc-doc          and
                 d-slt-vat-cons-fin.slt-pc        = bf_doc-line.slt-pc     and
                 d-slt-vat-cons-fin.contract-code = bf_parts.contract-code and
                 d-slt-vat-cons-fin.purch-code    = bf_parts.purch-code    no-error.
      if not available d-slt-vat-cons-fin then do:
        create d-slt-vat-cons-fin.
        assign d-slt-vat-cons-fin.vat-pc        = varvat-pc-doc
               d-slt-vat-cons-fin.slt-pc        = bf_doc-line.slt-pc
               d-slt-vat-cons-fin.contract-code = bf_parts.contract-code
               d-slt-vat-cons-fin.purch-code    = bf_parts.purch-code
               d-slt-vat-cons-fin.purch-name    = {&purchase-codes-name}.
      end.
    end.

    if lookup( "d-slt-vat-cons-grp", use-table ) > 0 then do:
      find first d-slt-vat-cons-grp where
                 d-slt-vat-cons-grp.vat-pc     = varvat-pc-doc       and
                 d-slt-vat-cons-grp.slt-pc     = bf_doc-line.slt-pc  and
                 d-slt-vat-cons-grp.purch-code = bf_parts.purch-code and
                 d-slt-vat-cons-grp.grp-code   = bf_goods.grp-code   no-error.
      if not available d-slt-vat-cons-grp then do:
        create d-slt-vat-cons-grp.
        assign d-slt-vat-cons-grp.vat-pc     = varvat-pc-doc
               d-slt-vat-cons-grp.slt-pc     = bf_doc-line.slt-pc
               d-slt-vat-cons-grp.purch-code = bf_parts.purch-code
               d-slt-vat-cons-grp.purch-name = {&purchase-codes-name}
               d-slt-vat-cons-grp.grp-code   = bf_goods.grp-code
               d-slt-vat-cons-grp.grp-name   = varfull-name-grp.
      end.
    end.
    if lookup( "d-slt-vat-cons-grp-fin", use-table ) > 0 then do:
      find first d-slt-vat-cons-grp-fin where
                 d-slt-vat-cons-grp-fin.vat-pc        = varvat-pc-doc          and
                 d-slt-vat-cons-grp-fin.slt-pc        = bf_doc-line.slt-pc     and
                 d-slt-vat-cons-grp-fin.contract-code = bf_parts.contract-code and
                 d-slt-vat-cons-grp-fin.purch-code    = bf_parts.purch-code    and
                 d-slt-vat-cons-grp-fin.grp-code      = bf_goods.grp-code      no-error.
      if not available d-slt-vat-cons-grp-fin then do:
        create d-slt-vat-cons-grp-fin.
        assign d-slt-vat-cons-grp-fin.vat-pc        = varvat-pc-doc
               d-slt-vat-cons-grp-fin.slt-pc        = bf_doc-line.slt-pc
               d-slt-vat-cons-grp-fin.contract-code = bf_parts.contract-code
               d-slt-vat-cons-grp-fin.purch-code    = bf_parts.purch-code
               d-slt-vat-cons-grp-fin.purch-name    = {&purchase-codes-name}
               d-slt-vat-cons-grp-fin.grp-code      = bf_goods.grp-code
               d-slt-vat-cons-grp-fin.grp-name      = varfull-name-grp.
      end.
    end.

    if lookup( "d-slts-vats", use-table ) > 0 then do:
      find first d-slts-vats where
                 d-slts-vats.vat-pc = bf_parts.vat-pc and
                 d-slts-vats.slt-pc = bf_parts.slt-pc no-error.
      if not available d-slts-vats then do:
        create d-slts-vats.
        assign d-slts-vats.vat-pc = bf_parts.vat-pc
               d-slts-vats.slt-pc = bf_parts.slt-pc.
      end.
    end.

    if lookup( "d-slts-vats-cons", use-table ) > 0 then do:
      find first d-slts-vats-cons where
                 d-slts-vats-cons.vat-pc     = bf_parts.vat-pc     and
                 d-slts-vats-cons.slt-pc     = bf_parts.slt-pc     and
                 d-slts-vats-cons.purch-code = bf_parts.purch-code no-error.
      if not available d-slts-vats-cons then do:
        create d-slts-vats-cons.
        assign d-slts-vats-cons.vat-pc     = bf_parts.vat-pc
               d-slts-vats-cons.slt-pc     = bf_parts.slt-pc
               d-slts-vats-cons.purch-code = bf_parts.purch-code
               d-slts-vats-cons.purch-name = {&purchase-codes-name}.
      end.
    end.

    if lookup( "d-slts-vats-cons-fin", use-table ) > 0 then do:
      find first d-slts-vats-cons-fin where
                 d-slts-vats-cons-fin.vat-pc        = bf_parts.vat-pc        and
                 d-slts-vats-cons-fin.slt-pc        = bf_parts.slt-pc        and
                 d-slts-vats-cons-fin.contract-code = bf_parts.contract-code and
                 d-slts-vats-cons-fin.purch-code    = bf_parts.purch-code    no-error.
      if not available d-slts-vats-cons-fin then do:
        create d-slts-vats-cons-fin.
        assign d-slts-vats-cons-fin.vat-pc        = bf_parts.vat-pc
               d-slts-vats-cons-fin.slt-pc        = bf_parts.slt-pc
               d-slts-vats-cons-fin.contract-code = bf_parts.contract-code
               d-slts-vats-cons-fin.purch-code    = bf_parts.purch-code
               d-slts-vats-cons-fin.purch-name    = {&purchase-codes-name}.
      end.
    end.

    if lookup( "d-slts-vats-cons-grp", use-table ) > 0 then do:
      find first d-slts-vats-cons-grp where
                 d-slts-vats-cons-grp.vat-pc     = bf_parts.vat-pc     and
                 d-slts-vats-cons-grp.slt-pc     = bf_parts.slt-pc     and
                 d-slts-vats-cons-grp.purch-code = bf_parts.purch-code and
                 d-slts-vats-cons-grp.grp-code   = bf_goods.grp-code   no-error.
      if not available d-slts-vats-cons-grp then do:
        create d-slts-vats-cons-grp.
        assign d-slts-vats-cons-grp.vat-pc     = bf_parts.vat-pc
               d-slts-vats-cons-grp.slt-pc     = bf_parts.slt-pc
               d-slts-vats-cons-grp.purch-code = bf_parts.purch-code
               d-slts-vats-cons-grp.purch-name = {&purchase-codes-name}
               d-slts-vats-cons-grp.grp-code   = bf_goods.grp-code
               d-slts-vats-cons-grp.grp-name   = varfull-name-grp.
      end.
    end.

    if lookup( "d-slts-vats-cons-grp-fin", use-table ) > 0 then do:
      find first d-slts-vats-cons-grp-fin where
                 d-slts-vats-cons-grp-fin.vat-pc        = bf_parts.vat-pc        and
                 d-slts-vats-cons-grp-fin.slt-pc        = bf_parts.slt-pc        and
                 d-slts-vats-cons-grp-fin.contract-code = bf_parts.contract-code and
                 d-slts-vats-cons-grp-fin.purch-code    = bf_parts.purch-code    and
                 d-slts-vats-cons-grp-fin.grp-code      = bf_goods.grp-code      no-error.
      if not available d-slts-vats-cons-grp-fin then do:
        create d-slts-vats-cons-grp-fin.
        assign d-slts-vats-cons-grp-fin.vat-pc        = bf_parts.vat-pc
               d-slts-vats-cons-grp-fin.slt-pc        = bf_parts.slt-pc
               d-slts-vats-cons-grp-fin.contract-code = bf_parts.contract-code
               d-slts-vats-cons-grp-fin.purch-code    = bf_parts.purch-code
               d-slts-vats-cons-grp-fin.purch-name    = {&purchase-codes-name}
               d-slts-vats-cons-grp-fin.grp-code      = bf_goods.grp-code
               d-slts-vats-cons-grp-fin.grp-name      = varfull-name-grp.
      end.
    end.

    /* Если в количестве 0, то мы заносим сумму не на поставщика */
    if bf_doc-line.fact-qnty   =  0                         and
       bf_trn-doc.ext-doc-type <> {&TDEDT_Corr_Acc_Price}   and
       bf_trn-doc.ext-doc-type <> {&TDEDT_Chg_Purch_Code}   and
       bf_trn-doc.ext-doc-type <> {&TDEDT_Corr_Minus_Parts} then do:
      if lookup( "d-supp", use-table ) > 0 then do:
        find first d-supp where
                   d-supp.supp-type = ?                    and
                   d-supp.supp-code = ?                    and
                   d-supp.purch-code = bf_parts.purch-code no-error.
        if not available d-supp then do:
          create d-supp.
          assign d-supp.supp-type  = ?
                 d-supp.supp-code  = ?
                 d-supp.purch-code = bf_parts.purch-code
                 d-supp.supp-name  = "Разница при продаже-возврате"
                 d-supp.purch-name = {&purchase-codes-name}.
        end.
      end.

      if lookup( "d-supp-fin", use-table ) > 0 then do:
        find first d-supp-fin where
                   d-supp-fin.supp-type     = ?                      and
                   d-supp-fin.supp-code     = ?                      and
                   d-supp-fin.purch-code    = bf_parts.purch-code    and
                   d-supp-fin.contract-code = bf_parts.contract-code no-error.
        if not available d-supp-fin then do:
          create d-supp-fin.
          assign d-supp-fin.supp-type     = ?
                 d-supp-fin.supp-code     = ?
                 d-supp-fin.purch-code    = bf_parts.purch-code
                 d-supp-fin.contract-code = bf_parts.contract-code
                 d-supp-fin.supp-name     = "Разница при продаже-возврате"
                 d-supp-fin.purch-name    = {&purchase-codes-name}.
        end.
      end.

      if lookup( "d-supp-grp", use-table ) > 0 then do:
        find first d-supp-grp where
                   d-supp-grp.supp-type  = ?                   and
                   d-supp-grp.supp-code  = ?                   and
                   d-supp-grp.purch-code = bf_parts.purch-code and
                   d-supp-grp.grp-code   = bf_goods.grp-code   no-error.
        if not available d-supp-grp then do:
          create d-supp-grp.
          assign d-supp-grp.supp-type  = ?
                 d-supp-grp.supp-code  = ?
                 d-supp-grp.purch-code = bf_parts.purch-code
                 d-supp-grp.grp-code   = bf_goods.grp-code
                 d-supp-grp.supp-name  = "Разница при продаже-возврате"
                 d-supp-grp.purch-name = {&purchase-codes-name}
                 d-supp-grp.grp-name   = varfull-name-grp.
        end.
      end.

      if lookup( "d-supp-grp-fin", use-table ) > 0 then do:
        find first d-supp-grp-fin where
                   d-supp-grp-fin.supp-type     = ?                      and
                   d-supp-grp-fin.supp-code     = ?                      and
                   d-supp-grp-fin.contract-code = bf_parts.contract-code and
                   d-supp-grp-fin.purch-code    = bf_parts.purch-code    and
                   d-supp-grp-fin.grp-code      = bf_goods.grp-code      no-error.
        if not available d-supp-grp-fin then do:
          create d-supp-grp-fin.
          assign d-supp-grp-fin.supp-type     = ?
                 d-supp-grp-fin.supp-code     = ?
                 d-supp-grp-fin.contract-code = bf_parts.contract-code
                 d-supp-grp-fin.purch-code    = bf_parts.purch-code
                 d-supp-grp-fin.grp-code      = bf_goods.grp-code
                 d-supp-grp-fin.supp-name     = "Разница при продаже-возврате"
                 d-supp-grp-fin.purch-name    = {&purchase-codes-name}
                 d-supp-grp-fin.grp-name      = varfull-name-grp.
        end.
      end.

      if lookup( "d-supp-slts-vats-cons", use-table ) > 0 then do:
        find first d-supp-slts-vats-cons where
                   d-supp-slts-vats-cons.supp-type  = ?                   and
                   d-supp-slts-vats-cons.supp-code  = ?                   and
                   d-supp-slts-vats-cons.vat-pc     = bf_parts.vat-pc     and
                   d-supp-slts-vats-cons.slt-pc     = bf_parts.slt-pc     and
                   d-supp-slts-vats-cons.purch-code = bf_parts.purch-code no-error.
        if not available d-supp-slts-vats-cons then do:
          create d-supp-slts-vats-cons.
          assign d-supp-slts-vats-cons.vat-pc     = bf_parts.vat-pc
                 d-supp-slts-vats-cons.slt-pc     = bf_parts.slt-pc
                 d-supp-slts-vats-cons.supp-type  = ?
                 d-supp-slts-vats-cons.supp-code  = ?
                 d-supp-slts-vats-cons.supp-name  = "Разница при продаже-возврате"
                 d-supp-slts-vats-cons.purch-code = bf_parts.purch-code
                 d-supp-slts-vats-cons.purch-name = {&purchase-codes-name}.
        end.
      end.

      if lookup( "d-supp-slts-vats-cons-fin", use-table ) > 0 then do:
        find first d-supp-slts-vats-cons-fin where
                   d-supp-slts-vats-cons-fin.supp-type     = ?                      and
                   d-supp-slts-vats-cons-fin.supp-code     = ?                      and
                   d-supp-slts-vats-cons-fin.vat-pc        = bf_parts.vat-pc        and
                   d-supp-slts-vats-cons-fin.slt-pc        = bf_parts.slt-pc        and
                   d-supp-slts-vats-cons-fin.contract-code = bf_parts.contract-code and
                   d-supp-slts-vats-cons-fin.purch-code    = bf_parts.purch-code    no-error.
        if not available d-supp-slts-vats-cons-fin then do:
          create d-supp-slts-vats-cons-fin.
          assign d-supp-slts-vats-cons-fin.vat-pc        = bf_parts.vat-pc
                 d-supp-slts-vats-cons-fin.slt-pc        = bf_parts.slt-pc
                 d-supp-slts-vats-cons-fin.supp-type     = ?
                 d-supp-slts-vats-cons-fin.supp-code     = ?
                 d-supp-slts-vats-cons-fin.contract-code = bf_parts.contract-code
                 d-supp-slts-vats-cons-fin.supp-name     = "Разница при продаже-возврате"
                 d-supp-slts-vats-cons-fin.purch-code    = bf_parts.purch-code
                 d-supp-slts-vats-cons-fin.purch-name    = {&purchase-codes-name}.
        end.
      end.
    end. /* Если в количестве 0, то мы заносим сумму не на поставщика */
    else do:
      find first bf_clients no-lock where
                 bf_clients.obj-code = bf_parts.supp-code and
                 bf_clients.obj-type = bf_parts.supp-type.
      if lookup( "d-supp", use-table ) > 0 then do:
        find first d-supp where
                   d-supp.supp-type  = bf_parts.supp-type  and
                   d-supp.supp-code  = bf_parts.supp-code  and
                   d-supp.purch-code = bf_parts.purch-code no-error.
        if not available d-supp then do:
          create d-supp.
          assign d-supp.supp-type  = bf_parts.supp-type
                 d-supp.supp-code  = bf_parts.supp-code
                 d-supp.purch-code = bf_parts.purch-code
                 d-supp.supp-name  = bf_clients.obj-name
                 d-supp.purch-name = {&purchase-codes-name}.
        end.
      end.

      if lookup( "d-supp-fin", use-table ) > 0 then do:
        find first d-supp-fin where
                   d-supp-fin.supp-type     = bf_parts.supp-type     and
                   d-supp-fin.supp-code     = bf_parts.supp-code     and
                   d-supp-fin.contract-code = bf_parts.contract-code and
                   d-supp-fin.purch-code    = bf_parts.purch-code    no-error.
        if not available d-supp-fin then do:
          create d-supp-fin.
          assign d-supp-fin.supp-type     = bf_parts.supp-type
                 d-supp-fin.supp-code     = bf_parts.supp-code
                 d-supp-fin.contract-code = bf_parts.contract-code
                 d-supp-fin.purch-code    = bf_parts.purch-code
                 d-supp-fin.supp-name     = bf_clients.obj-name
                 d-supp-fin.purch-name    = {&purchase-codes-name}.
        end.
      end.

      if lookup( "d-supp-grp", use-table ) > 0 then do:
        find first d-supp-grp where
                   d-supp-grp.supp-type  = bf_parts.supp-type  and
                   d-supp-grp.supp-code  = bf_parts.supp-code  and
                   d-supp-grp.purch-code = bf_parts.purch-code and
                   d-supp-grp.grp-code   = bf_goods.grp-code   no-error.
        if not available d-supp-grp then do:
          create d-supp-grp.
          assign d-supp-grp.supp-type  = bf_parts.supp-type
                 d-supp-grp.supp-code  = bf_parts.supp-code
                 d-supp-grp.purch-code = bf_parts.purch-code
                 d-supp-grp.grp-code   = bf_goods.grp-code
                 d-supp-grp.supp-name  = bf_clients.obj-name
                 d-supp-grp.purch-name = {&purchase-codes-name}
                 d-supp-grp.grp-name   = varfull-name-grp.
        end.
      end.

      if lookup( "d-supp-grp-fin", use-table ) > 0 then do:
        find first d-supp-grp-fin where
                   d-supp-grp-fin.supp-type     = bf_parts.supp-type     and
                   d-supp-grp-fin.supp-code     = bf_parts.supp-code     and
                   d-supp-grp-fin.purch-code    = bf_parts.purch-code    and
                   d-supp-grp-fin.contract-code = bf_parts.contract-code and
                   d-supp-grp-fin.grp-code      = bf_goods.grp-code      no-error.
        if not available d-supp-grp-fin then do:
          create d-supp-grp-fin.
          assign d-supp-grp-fin.supp-type     = bf_parts.supp-type
                 d-supp-grp-fin.supp-code     = bf_parts.supp-code
                 d-supp-grp-fin.purch-code    = bf_parts.purch-code
                 d-supp-grp-fin.contract-code = bf_parts.contract-code
                 d-supp-grp-fin.grp-code      = bf_goods.grp-code
                 d-supp-grp-fin.supp-name     = bf_clients.obj-name
                 d-supp-grp-fin.purch-name    = {&purchase-codes-name}
                 d-supp-grp-fin.grp-name      = varfull-name-grp.
        end.
      end.

      if lookup( "d-supp-slts-vats-cons", use-table ) > 0 then do:
        find first d-supp-slts-vats-cons where
                   d-supp-slts-vats-cons.supp-type  = bf_parts.supp-type  and
                   d-supp-slts-vats-cons.supp-code  = bf_parts.supp-code  and
                   d-supp-slts-vats-cons.vat-pc     = bf_parts.vat-pc     and
                   d-supp-slts-vats-cons.slt-pc     = bf_parts.slt-pc     and
                   d-supp-slts-vats-cons.purch-code = bf_parts.purch-code no-error.
        if not available d-supp-slts-vats-cons then do:
          create d-supp-slts-vats-cons.
          assign d-supp-slts-vats-cons.vat-pc     = bf_parts.vat-pc
                 d-supp-slts-vats-cons.slt-pc     = bf_parts.slt-pc
                 d-supp-slts-vats-cons.supp-type  = bf_parts.supp-type
                 d-supp-slts-vats-cons.supp-code  = bf_parts.supp-code
                 d-supp-slts-vats-cons.supp-name  = bf_clients.obj-name
                 d-supp-slts-vats-cons.purch-code = bf_parts.purch-code
                 d-supp-slts-vats-cons.purch-name = {&purchase-codes-name}.
        end.
      end.

      if lookup( "d-supp-slts-vats-cons-fin", use-table ) > 0 then do:
        find first d-supp-slts-vats-cons-fin where
                   d-supp-slts-vats-cons-fin.supp-type     = bf_parts.supp-type     and
                   d-supp-slts-vats-cons-fin.supp-code     = bf_parts.supp-code     and
                   d-supp-slts-vats-cons-fin.vat-pc        = bf_parts.vat-pc        and
                   d-supp-slts-vats-cons-fin.slt-pc        = bf_parts.slt-pc        and
                   d-supp-slts-vats-cons-fin.contract-code = bf_parts.contract-code and
                   d-supp-slts-vats-cons-fin.purch-code    = bf_parts.purch-code    no-error.
        if not available d-supp-slts-vats-cons-fin then do:
          create d-supp-slts-vats-cons-fin.
          assign d-supp-slts-vats-cons-fin.vat-pc        = bf_parts.vat-pc
                 d-supp-slts-vats-cons-fin.slt-pc        = bf_parts.slt-pc
                 d-supp-slts-vats-cons-fin.supp-type     = bf_parts.supp-type
                 d-supp-slts-vats-cons-fin.supp-code     = bf_parts.supp-code
                 d-supp-slts-vats-cons-fin.contract-code = bf_parts.contract-code
                 d-supp-slts-vats-cons-fin.supp-name     = bf_clients.obj-name
                 d-supp-slts-vats-cons-fin.purch-code    = bf_parts.purch-code
                 d-supp-slts-vats-cons-fin.purch-name    = {&purchase-codes-name}.
        end.
      end.
    end.
    empty temp-table tt-allsum.
    empty temp-table tt-clcparts.
    create tt-clcparts.
    buffer-copy bf_parts to tt-clcparts.
    run clcprtsl_calc-parts in this-procedure ( input recid( tt-clcparts ),
                                                input yes,
                                                input yes,
                                                input bf_doc-line.road-tax,
                                                input bf_doc-line.excise,
                                                input bf_doc-line.vat-pc,
                                                input bf_doc-line.cons-vat-pc,
                                                input bf_doc-line.slt-pc,
                                                input bf_trn-doc.base-rate,
                                                input bf_trn-doc.base-scale,
                                                input varr-b,
                                                input varcur-base,
                                                input varcur-road-tax,
                                                input varcur-excise,
                                                input varcur-vat-pc,
                                                input varcur-cons-vat-pc,
                                                input varcur-slt-pc ).
    find first tt-allsum where tt-allsum.sum-type = {&sum-general}.

    /* Заполнение таблиц */
    &scop calc-sum assign ~{&table-name}.fact-qnty           = ~{&table-name}.fact-qnty           + tt-allsum.fact-qnty  ~
                          ~{&table-name}.acc-base            = ~{&table-name}.acc-base            + tt-allsum.sum-dsc-base-acc ~
                          ~{&table-name}.acc-rubl            = ~{&table-name}.acc-rubl            + tt-allsum.sum-dsc-rubl-acc ~
                          ~{&table-name}.acc-vat-base        = ~{&table-name}.acc-vat-base        + tt-allsum.vat-base-acc ~
                          ~{&table-name}.acc-vat-rubl        = ~{&table-name}.acc-vat-rubl        + tt-allsum.vat-rubl-acc ~
                          ~{&table-name}.acc-slt-base        = ~{&table-name}.acc-slt-base        + tt-allsum.slt-base-acc ~
                          ~{&table-name}.acc-slt-rubl        = ~{&table-name}.acc-slt-rubl        + tt-allsum.slt-rubl-acc ~
                          ~{&table-name}.acc-road-tax-base   = ~{&table-name}.acc-road-tax-base   + tt-allsum.road-tax-base-acc ~
                          ~{&table-name}.acc-road-tax-rubl   = ~{&table-name}.acc-road-tax-rubl   + tt-allsum.road-tax-rubl-acc ~
                          ~{&table-name}.acc-excise-base     = ~{&table-name}.acc-excise-base     + tt-allsum.excise-base-acc ~
                          ~{&table-name}.acc-excise-rubl     = ~{&table-name}.acc-excise-rubl     + tt-allsum.excise-rubl-acc ~
                          ~{&table-name}.acc-transport-base  = ~{&table-name}.acc-transport-base  + tt-allsum.transport-base-acc ~
                          ~{&table-name}.acc-transport-rubl  = ~{&table-name}.acc-transport-rubl  + tt-allsum.transport-rubl-acc ~
                          ~{&table-name}.acc-other-base      = ~{&table-name}.acc-other-base      + tt-allsum.other-base-acc ~
                          ~{&table-name}.acc-other-rubl      = ~{&table-name}.acc-other-rubl      + tt-allsum.other-rubl-acc ~
                          ~{&table-name}.pay-base            = ~{&table-name}.pay-base            + tt-allsum.sum-dsc-base-doc ~
                          ~{&table-name}.pay-rubl            = ~{&table-name}.pay-rubl            + tt-allsum.sum-dsc-rubl-doc ~
                          ~{&table-name}.no-vat-base         = ~{&table-name}.no-vat-base         + tt-allsum.sum-dsc-base-doc - tt-allsum.vat-base-doc ~
                          ~{&table-name}.no-vat-rubl         = ~{&table-name}.no-vat-rubl         + tt-allsum.sum-dsc-rubl-doc - tt-allsum.vat-rubl-doc ~
                          ~{&table-name}.vat-base            = ~{&table-name}.vat-base            + tt-allsum.vat-base-doc ~
                          ~{&table-name}.vat-rubl            = ~{&table-name}.vat-rubl            + tt-allsum.vat-rubl-doc ~
                          ~{&table-name}.vat-base-buyer      = ~{&table-name}.vat-base-buyer      + tt-allsum.vat-base-buyer-doc ~
                          ~{&table-name}.vat-rubl-buyer      = ~{&table-name}.vat-rubl-buyer      + tt-allsum.vat-rubl-buyer-doc ~
                          ~{&table-name}.slt-base            = ~{&table-name}.slt-base            + tt-allsum.slt-base-doc ~
                          ~{&table-name}.slt-rubl            = ~{&table-name}.slt-rubl            + tt-allsum.slt-rubl-doc ~
                          ~{&table-name}.road-tax            = ~{&table-name}.road-tax            + (if varr-b = "base" then tt-allsum.road-tax-base-doc else tt-allsum.road-tax-rubl-doc) ~
                          ~{&table-name}.excise              = ~{&table-name}.excise              + (if varr-b = "base" then tt-allsum.excise-base-doc   else tt-allsum.excise-rubl-doc)   ~
                          ~{&table-name}.sale-base           = ~{&table-name}.sale-base           + tt-allsum.sum-dsc-base-cur ~
                          ~{&table-name}.sale-rubl           = ~{&table-name}.sale-rubl           + tt-allsum.sum-dsc-rubl-cur ~
                          ~{&table-name}.sale-vat-base       = ~{&table-name}.sale-vat-base       + tt-allsum.vat-base-cur     ~
                          ~{&table-name}.sale-vat-rubl       = ~{&table-name}.sale-vat-rubl       + tt-allsum.vat-rubl-cur     ~
                          ~{&table-name}.sale-vat-buyer-base = ~{&table-name}.sale-vat-buyer-base + tt-allsum.vat-base-buyer-cur ~
                          ~{&table-name}.sale-vat-buyer-rubl = ~{&table-name}.sale-vat-buyer-rubl + tt-allsum.vat-rubl-buyer-cur ~
                          ~{&table-name}.sale-slt-base       = ~{&table-name}.sale-slt-base       + tt-allsum.slt-base-cur       ~
                          ~{&table-name}.sale-slt-rubl       = ~{&table-name}.sale-slt-rubl       + tt-allsum.slt-rubl-cur       ~
                          ~{&table-name}.sale-road-tax-base  = ~{&table-name}.sale-road-tax-base  + tt-allsum.road-tax-base-cur  ~
                          ~{&table-name}.sale-road-tax-rubl  = ~{&table-name}.sale-road-tax-rubl  + tt-allsum.road-tax-rubl-cur  ~
                          ~{&table-name}.sale-excise-base    = ~{&table-name}.sale-excise-base    + tt-allsum.excise-base-cur    ~
                          ~{&table-name}.sale-excise-rubl    = ~{&table-name}.sale-excise-rubl    + tt-allsum.excise-rubl-cur    ~
                          ~{&table-name}.ov-base             = ~{&table-name}.ov-base             + (if varr-b = "base" then (tt-allsum.sum-dsc-base-cur - tt-allsum.sum-dsc-base-doc) else (tt-allsum.sum-dsc-rubl-cur - tt-allsum.sum-dsc-rubl-doc)) ~
                          ~{&table-name}.ov-vat              = ~{&table-name}.ov-vat              + (if varr-b = "base" then (tt-allsum.sum-dsc-base-cur - tt-allsum.sum-dsc-base-doc) else (tt-allsum.sum-dsc-rubl-cur - tt-allsum.sum-dsc-rubl-doc)) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc).
     &scop table-name tt-title
     {&calc-sum}

     &scop table-name tt-title-fin
     if varcalc-title-fin = yes then do:
       {&calc-sum}
     end.

     &scop table-name d-supp
     if lookup( "{&table-name}", use-table ) > 0 then do:
       {&calc-sum}
     end.

     &scop table-name d-supp-fin
     if lookup( "{&table-name}", use-table ) > 0 then do:
       {&calc-sum}
     end.

     &scop table-name d-supp-grp
     if lookup( "{&table-name}", use-table ) > 0 then do:
       {&calc-sum}
     end.

     &scop table-name d-supp-grp-fin
     if lookup( "{&table-name}", use-table ) > 0 then do:
       {&calc-sum}
     end.

     &scop table-name d-slt-vat
     if lookup( "{&table-name}", use-table ) > 0 then do:
       {&calc-sum}
     end.

     &scop table-name d-slt-vat-cons
     if lookup( "{&table-name}", use-table ) > 0 then do:
       {&calc-sum}
     end.

     &scop table-name d-slt-vat-cons-fin
     if lookup( "{&table-name}", use-table ) > 0 then do:
       {&calc-sum}
     end.

     &scop table-name d-slt-vat-cons-grp
     if lookup( "{&table-name}", use-table ) > 0 then do:
       {&calc-sum}
     end.

     &scop table-name d-slt-vat-cons-grp-fin
     if lookup( "{&table-name}", use-table ) > 0 then do:
       {&calc-sum}
     end.

     &scop table-name d-slts-vats
     if lookup( "{&table-name}", use-table ) > 0 then do:
       {&calc-sum}
     end.

     &scop table-name d-supp-slts-vats-cons
     if lookup( "{&table-name}", use-table ) > 0 then do:
       {&calc-sum}
     end.

     &scop table-name d-supp-slts-vats-cons-fin
     if lookup( "{&table-name}", use-table ) > 0 then do:
       {&calc-sum}
     end.

     &scop table-name d-slts-vats-cons
     if lookup( "{&table-name}", use-table ) > 0 then do:
       {&calc-sum}
     end.

     &scop table-name d-slts-vats-cons-fin
     if lookup( "{&table-name}", use-table ) > 0 then do:
       {&calc-sum}
     end.

     &scop table-name d-slts-vats-cons-grp
     if lookup( "{&table-name}", use-table ) > 0 then do:
       {&calc-sum}
     end.

     &scop table-name d-slts-vats-cons-grp-fin
     if lookup( "{&table-name}", use-table ) > 0 then do:
       {&calc-sum}
     end.
  end.
end.
if is-wait-on then do: run waitfram-hide in this-procedure. end.

procedure calc-office :
  define buffer bf_gds-dtl for ub.gds-dtl.

  define variable sum-acc-base            as decimal no-undo.
  define variable sum-acc-rubl            as decimal no-undo.
  define variable sum-acc-vat-base        as decimal no-undo.
  define variable sum-acc-vat-rubl        as decimal no-undo.
  define variable sum-acc-slt-base        as decimal no-undo.
  define variable sum-acc-slt-rubl        as decimal no-undo.
  define variable sum-acc-road-tax-base   as decimal no-undo.
  define variable sum-acc-road-tax-rubl   as decimal no-undo.
  define variable sum-acc-excise-base     as decimal no-undo.
  define variable sum-acc-excise-rubl     as decimal no-undo.
  define variable sum-acc-transport-base  as decimal no-undo.
  define variable sum-acc-transport-rubl  as decimal no-undo.
  define variable sum-acc-other-base      as decimal no-undo.
  define variable sum-acc-other-rubl      as decimal no-undo.

  do on error undo, return error return-value :
    /* Заполнение таблиц */
    &scop calc-sum-office assign ~{&table-name}.fact-qnty           = ~{&table-name}.fact-qnty           + varqnty  ~
                                 ~{&table-name}.acc-base            = ~{&table-name}.acc-base            + sum-acc-base           ~
                                 ~{&table-name}.acc-rubl            = ~{&table-name}.acc-rubl            + sum-acc-rubl           ~
                                 ~{&table-name}.acc-vat-base        = ~{&table-name}.acc-vat-base        + sum-acc-vat-base       ~
                                 ~{&table-name}.acc-vat-rubl        = ~{&table-name}.acc-vat-rubl        + sum-acc-vat-rubl       ~
                                 ~{&table-name}.acc-slt-base        = ~{&table-name}.acc-slt-base        + sum-acc-slt-base       ~
                                 ~{&table-name}.acc-slt-rubl        = ~{&table-name}.acc-slt-rubl        + sum-acc-slt-rubl       ~
                                 ~{&table-name}.acc-road-tax-base   = ~{&table-name}.acc-road-tax-base   + sum-acc-road-tax-base  ~
                                 ~{&table-name}.acc-road-tax-rubl   = ~{&table-name}.acc-road-tax-rubl   + sum-acc-road-tax-rubl  ~
                                 ~{&table-name}.acc-excise-base     = ~{&table-name}.acc-excise-base     + sum-acc-excise-base    ~
                                 ~{&table-name}.acc-excise-rubl     = ~{&table-name}.acc-excise-rubl     + sum-acc-excise-rubl    ~
                                 ~{&table-name}.acc-transport-base  = ~{&table-name}.acc-transport-base  + sum-acc-transport-base ~
                                 ~{&table-name}.acc-transport-rubl  = ~{&table-name}.acc-transport-rubl  + sum-acc-transport-rubl ~
                                 ~{&table-name}.acc-other-base      = ~{&table-name}.acc-other-base      + sum-acc-other-base     ~
                                 ~{&table-name}.acc-other-rubl      = ~{&table-name}.acc-other-rubl      + sum-acc-other-rubl     ~
                                 ~{&table-name}.pay-base            = ~{&table-name}.pay-base            + sum-price-base-with-tax-sale ~
                                 ~{&table-name}.pay-rubl            = ~{&table-name}.pay-rubl            + sum-price-rubl-with-tax-sale ~
                                 ~{&table-name}.vat-base            = ~{&table-name}.vat-base            + sum-vat-base-sale ~
                                 ~{&table-name}.vat-rubl            = ~{&table-name}.vat-rubl            + sum-vat-rubl-sale ~
                                 ~{&table-name}.no-vat-base         = ~{&table-name}.no-vat-base         + sum-price-base-with-tax-sale - sum-vat-base-sale ~
                                 ~{&table-name}.no-vat-rubl         = ~{&table-name}.no-vat-rubl         + sum-price-rubl-with-tax-sale - sum-vat-rubl-sale ~
                                 ~{&table-name}.vat-base-buyer      = ~{&table-name}.vat-base-buyer      + sum-vat-base-buyer ~
                                 ~{&table-name}.vat-rubl-buyer      = ~{&table-name}.vat-rubl-buyer      + sum-vat-rubl-buyer ~
                                 ~{&table-name}.slt-base            = ~{&table-name}.slt-base            + sum-slt-base-sale ~
                                 ~{&table-name}.slt-rubl            = ~{&table-name}.slt-rubl            + sum-slt-rubl-sale ~
                                 ~{&table-name}.road-tax            = ~{&table-name}.road-tax            + (if varr-b = "base" then sum-road-tax-base-sale else sum-road-tax-rubl-sale) ~
                                 ~{&table-name}.excise              = ~{&table-name}.excise              + (if varr-b = "base" then sum-excise-base-sale   else sum-excise-rubl-sale)   ~
                                 ~{&table-name}.sale-base           = ~{&table-name}.sale-base           + sum-price-base-with-tax-sale-cur ~
                                 ~{&table-name}.sale-rubl           = ~{&table-name}.sale-rubl           + sum-price-rubl-with-tax-sale-cur ~
                                 ~{&table-name}.sale-vat-base       = ~{&table-name}.sale-vat-base       + sum-vat-base-sale-cur      ~
                                 ~{&table-name}.sale-vat-rubl       = ~{&table-name}.sale-vat-rubl       + sum-vat-rubl-sale-cur      ~
                                 ~{&table-name}.sale-vat-buyer-base = ~{&table-name}.sale-vat-buyer-base + sum-vat-base-buyer-cur     ~
                                 ~{&table-name}.sale-vat-buyer-rubl = ~{&table-name}.sale-vat-buyer-rubl + sum-vat-rubl-buyer-cur     ~
                                 ~{&table-name}.sale-slt-base       = ~{&table-name}.sale-slt-base       + sum-slt-base-sale-cur      ~
                                 ~{&table-name}.sale-slt-rubl       = ~{&table-name}.sale-slt-rubl       + sum-slt-rubl-sale-cur      ~
                                 ~{&table-name}.sale-road-tax-base  = ~{&table-name}.sale-road-tax-base  + sum-road-tax-base-sale-cur ~
                                 ~{&table-name}.sale-road-tax-rubl  = ~{&table-name}.sale-road-tax-rubl  + sum-road-tax-rubl-sale-cur ~
                                 ~{&table-name}.sale-excise-base    = ~{&table-name}.sale-excise-base    + sum-excise-base-sale-cur   ~
                                 ~{&table-name}.sale-excise-rubl    = ~{&table-name}.sale-excise-rubl    + sum-excise-rubl-sale-cur   ~
                                 ~{&table-name}.ov-base             = ~{&table-name}.ov-base             + (if varr-b = "base" then (sum-price-base-with-tax-sale-cur - sum-price-base-with-tax-sale) else (sum-price-rubl-with-tax-sale-cur - sum-price-rubl-with-tax-sale)) ~
                                 ~{&table-name}.ov-vat              = ~{&table-name}.ov-vat              + (if varr-b = "base" then (sum-price-base-with-tax-sale-cur - sum-price-base-with-tax-sale) else (sum-price-rubl-with-tax-sale-cur - sum-price-rubl-with-tax-sale)) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc).
    for each bf_doc-line no-lock where
             bf_doc-line.doc-code = bf_trn-doc.doc-code on error undo, return error return-value :
      find first bf_gds-dtl no-lock where
                 bf_gds-dtl.doc-code  = bf_doc-line.doc-code  and
                 bf_gds-dtl.artic     = bf_doc-line.artic     and
                 bf_gds-dtl.prod-type = bf_doc-line.prod-type and
                 bf_gds-dtl.prod-code = bf_doc-line.prod-code.
      { str/out-vatp.i calc-gds-dtl bf_doc-line. bf_trn-doc. bf_gds-dtl. }
      { str/out-vatp.i calc-gds-dtl bf_doc-line. bf_trn-doc. bf_gds-dtl. "-cur" "''" "doc-code" "cur" }
      assign varqnty                          = bf_gds-dtl.fact-qnty
             sum-price-base-with-tax-sale     = price-base-with-tax-sale     * varqnty
             sum-price-rubl-with-tax-sale     = price-rubl-with-tax-sale     * varqnty
             sum-vat-base-sale                = vat-base-sale                * varqnty
             sum-vat-rubl-sale                = vat-rubl-sale                * varqnty
             sum-vat-base-buyer               = vat-base-buyer               * varqnty
             sum-vat-rubl-buyer               = vat-rubl-buyer               * varqnty
             sum-slt-base-sale                = slt-base-sale                * varqnty
             sum-slt-rubl-sale                = slt-rubl-sale                * varqnty
             sum-road-tax-base-sale           = road-tax-base-sale           * varqnty
             sum-road-tax-rubl-sale           = road-tax-rubl-sale           * varqnty
             sum-excise-base-sale             = excise-base-sale             * varqnty
             sum-excise-rubl-sale             = excise-rubl-sale             * varqnty
             sum-discnt-base-sale             = discnt-base-sale             * varqnty
             sum-discnt-rubl-sale             = discnt-rubl-sale             * varqnty
             sum-price-rubl-with-tax-sale-cur = price-rubl-with-tax-sale-cur * varqnty
             sum-price-base-with-tax-sale-cur = price-base-with-tax-sale-cur * varqnty
             sum-vat-base-sale-cur            = vat-base-sale-cur            * varqnty
             sum-vat-rubl-sale-cur            = vat-rubl-sale-cur            * varqnty
             sum-vat-base-buyer-cur           = vat-base-buyer-cur           * varqnty
             sum-vat-rubl-buyer-cur           = vat-rubl-buyer-cur           * varqnty
             sum-slt-base-sale-cur            = slt-base-sale-cur            * varqnty
             sum-slt-rubl-sale-cur            = slt-rubl-sale-cur            * varqnty
             sum-road-tax-base-sale-cur       = road-tax-base-sale-cur       * varqnty
             sum-road-tax-rubl-sale-cur       = road-tax-rubl-sale-cur       * varqnty
             sum-excise-base-sale-cur         = excise-base-sale-cur         * varqnty
             sum-excise-rubl-sale-cur         = excise-rubl-sale-cur         * varqnty
             sum-discnt-base-sale-cur         = discnt-base-sale-cur         * varqnty
             sum-discnt-rubl-sale-cur         = discnt-rubl-sale-cur         * varqnty
             sum-acc-base                     = bf_doc-line.price-base       * varqnty
             sum-acc-rubl                     = bf_doc-line.price-rubl       * varqnty
             sum-acc-vat-base                 = (bf_doc-line.price-base * varqnty - bf_doc-line.price-base * bf_doc-line.slt-pc / (100 + bf_doc-line.slt-pc) * varqnty) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc)
             sum-acc-vat-rubl                 = (bf_doc-line.price-rubl * varqnty - bf_doc-line.price-rubl * bf_doc-line.slt-pc / (100 + bf_doc-line.slt-pc) * varqnty) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc)
             sum-acc-slt-base                 = bf_doc-line.price-base * bf_doc-line.slt-pc / (100 + bf_doc-line.slt-pc) * varqnty
             sum-acc-slt-rubl                 = bf_doc-line.price-rubl * bf_doc-line.slt-pc / (100 + bf_doc-line.slt-pc) * varqnty
             sum-acc-road-tax-base            = 0
             sum-acc-road-tax-rubl            = 0
             sum-acc-excise-base              = 0
             sum-acc-excise-rubl              = 0
             sum-acc-transport-base           = 0
             sum-acc-transport-rubl           = 0
             sum-acc-other-base               = 0
             sum-acc-other-rubl               = 0.
      &scop table-name tt-title
      find first {&table-name} where {&table-name}.purch-code = {&bef-repayment-code} no-error.
      if not available {&table-name} then do:
        create {&table-name}.
        assign {&table-name}.purch-code = {&bef-repayment-code}
               {&table-name}.purch-name = {&repayment-code-full}.
      end.
      {&calc-sum-office}

      &scop table-name tt-title-fin
      if varcalc-title-fin = yes then do:
        find first {&table-name} where
                   {&table-name}.purch-code    = {&bef-repayment-code} and
                   {&table-name}.contract-code = 0                     no-error.
        if not available {&table-name} then do:
          create {&table-name}.
          assign {&table-name}.purch-code    = {&bef-repayment-code}
                 {&table-name}.contract-code = 0
                 {&table-name}.purch-name    = {&repayment-code-full}.
        end.
        {&calc-sum-office}
      end.

      &scop table-name d-slt-vat
      if lookup( "{&table-name}", use-table ) > 0 then do:
        find first {&table-name} where
                   {&table-name}.vat-pc = bf_doc-line.vat-pc and
                   {&table-name}.slt-pc = bf_doc-line.slt-pc no-error.
        if not available {&table-name} then do:
          create {&table-name}.
          assign {&table-name}.vat-pc = bf_doc-line.vat-pc
                 {&table-name}.slt-pc = bf_doc-line.slt-pc.
        end.
        {&calc-sum-office}
      end.

      &scop table-name d-slt-vat-cons
      if lookup( "{&table-name}", use-table ) > 0 then do:
        find first {&table-name} where
                   {&table-name}.vat-pc     = bf_doc-line.vat-pc    and
                   {&table-name}.slt-pc     = bf_doc-line.slt-pc    and
                   {&table-name}.purch-code = {&bef-repayment-code} no-error.
        if not available {&table-name} then do:
          create {&table-name}.
          assign {&table-name}.vat-pc     = bf_doc-line.vat-pc
                 {&table-name}.slt-pc     = bf_doc-line.slt-pc
                 {&table-name}.purch-code = {&bef-repayment-code}
                 {&table-name}.purch-name = {&repayment-code-full}.
        end.
        {&calc-sum-office}
      end.

      &scop table-name d-slt-vat-cons-fin
      if lookup( "{&table-name}", use-table ) > 0 then do:
        find first {&table-name} where
                   {&table-name}.vat-pc        = bf_doc-line.vat-pc    and
                   {&table-name}.slt-pc        = bf_doc-line.slt-pc    and
                   {&table-name}.contract-code = 0                     and
                   {&table-name}.purch-code    = {&bef-repayment-code} no-error.
        if not available {&table-name} then do:
          create {&table-name}.
          assign {&table-name}.vat-pc        = bf_doc-line.vat-pc
                 {&table-name}.slt-pc        = bf_doc-line.slt-pc
                 {&table-name}.contract-code = 0
                 {&table-name}.purch-code    = {&bef-repayment-code}
                 {&table-name}.purch-name    = {&repayment-code-full}.
        end.
        {&calc-sum-office}
      end.

      &scop table-name d-slt-vat-cons-grp
      if lookup( "{&table-name}", use-table ) > 0 then do:
        find first {&table-name} where
                   {&table-name}.vat-pc     = bf_doc-line.vat-pc    and
                   {&table-name}.slt-pc     = bf_doc-line.slt-pc    and
                   {&table-name}.purch-code = {&bef-repayment-code} and
                   {&table-name}.grp-code   = bf_goods.grp-code     no-error.
        if not available {&table-name} then do:
          create {&table-name}.
          assign {&table-name}.vat-pc     = bf_doc-line.vat-pc
                 {&table-name}.slt-pc     = bf_doc-line.slt-pc
                 {&table-name}.purch-code = {&bef-repayment-code}
                 {&table-name}.purch-name = {&repayment-code-full}
                 {&table-name}.grp-code   = bf_goods.grp-code
                 {&table-name}.grp-name   = varfull-name-grp.
        end.
        {&calc-sum-office}
      end.

      &scop table-name d-slt-vat-cons-grp-fin
      if lookup( "{&table-name}", use-table ) > 0 then do:
        find first {&table-name} where
                   {&table-name}.vat-pc        = bf_doc-line.vat-pc    and
                   {&table-name}.slt-pc        = bf_doc-line.slt-pc    and
                   {&table-name}.contract-code = 0                     and
                   {&table-name}.purch-code    = {&bef-repayment-code} and
                   {&table-name}.grp-code      = bf_goods.grp-code     no-error.
        if not available {&table-name} then do:
          create {&table-name}.
          assign {&table-name}.vat-pc        = bf_doc-line.vat-pc
                 {&table-name}.slt-pc        = bf_doc-line.slt-pc
                 {&table-name}.contract-code = 0
                 {&table-name}.purch-code    = {&bef-repayment-code}
                 {&table-name}.purch-name    = {&repayment-code-full}
                 {&table-name}.grp-code      = bf_goods.grp-code
                 {&table-name}.grp-name      = varfull-name-grp.
        end.
        {&calc-sum-office}
      end.

      &scop table-name d-slts-vats
      if lookup( "{&table-name}", use-table ) > 0 then do:
        find first {&table-name} where
                   {&table-name}.vat-pc = ? and
                   {&table-name}.slt-pc = ? no-error.
        if not available d-slts-vats then do:
          create {&table-name}.
          assign {&table-name}.vat-pc = ?
                 {&table-name}.slt-pc = ?.
        end.
        {&calc-sum-office}
      end.

      &scop table-name d-slts-vats-cons
      if lookup( "{&table-name}", use-table ) > 0 then do:
        find first {&table-name} where
                   {&table-name}.vat-pc     = ?                     and
                   {&table-name}.slt-pc     = ?                     and
                   {&table-name}.purch-code = {&bef-repayment-code} no-error.
        if not available d-slts-vats-cons then do:
          create {&table-name}.
          assign {&table-name}.vat-pc     = ?
                 {&table-name}.slt-pc     = ?
                 {&table-name}.purch-code = {&bef-repayment-code}
                 {&table-name}.purch-name = {&repayment-code-full}.
        end.
        {&calc-sum-office}
      end.

      &scop table-name d-slts-vats-cons-fin
      if lookup( "{&table-name}", use-table ) > 0 then do:
        find first {&table-name} where
                   {&table-name}.vat-pc        = ?                     and
                   {&table-name}.slt-pc        = ?                     and
                   {&table-name}.contract-code = 0                     and
                   {&table-name}.purch-code    = {&bef-repayment-code} no-error.
        if not available d-slts-vats-cons then do:
          create {&table-name}.
          assign {&table-name}.vat-pc        = ?
                 {&table-name}.slt-pc        = ?
                 {&table-name}.contract-code = 0
                 {&table-name}.purch-code    = {&bef-repayment-code}
                 {&table-name}.purch-name    = {&repayment-code-full}.
        end.
        {&calc-sum-office}
      end.

      &scop table-name d-slts-vats-cons-grp
      if lookup( "{&table-name}", use-table ) > 0 then do:
        find first {&table-name} where
                   {&table-name}.vat-pc     = ?                     and
                   {&table-name}.slt-pc     = ?                     and
                   {&table-name}.purch-code = {&bef-repayment-code} and
                   {&table-name}.grp-code   = bf_goods.grp-code     no-error.
        if not available {&table-name} then do:
          create {&table-name}.
          assign {&table-name}.vat-pc     = ?
                 {&table-name}.slt-pc     = ?
                 {&table-name}.purch-code = {&bef-repayment-code}
                 {&table-name}.purch-name = {&repayment-code-full}
                 {&table-name}.grp-code   = bf_goods.grp-code
                 {&table-name}.grp-name   = varfull-name-grp.
        end.
        {&calc-sum-office}
      end.

      &scop table-name d-slts-vats-cons-grp-fin
      if lookup( "{&table-name}", use-table ) > 0 then do:
        find first {&table-name} where
                   {&table-name}.vat-pc        = ?                     and
                   {&table-name}.slt-pc        = ?                     and
                   {&table-name}.contract-code = 0                     and
                   {&table-name}.purch-code    = {&bef-repayment-code} and
                   {&table-name}.grp-code      = bf_goods.grp-code     no-error.
        if not available {&table-name} then do:
          create {&table-name}.
          assign {&table-name}.vat-pc        = ?
                 {&table-name}.slt-pc        = ?
                 {&table-name}.contract-code = 0
                 {&table-name}.purch-code    = {&bef-repayment-code}
                 {&table-name}.purch-name    = {&repayment-code-full}
                 {&table-name}.grp-code      = bf_goods.grp-code
                 {&table-name}.grp-name      = varfull-name-grp.
        end.
        {&calc-sum-office}
      end.

      &scop table-name d-supp
      if lookup( "{&table-name}", use-table ) > 0 then do:
         find first {&table-name} where
                    {&table-name}.supp-type  = bf_trn-doc.cli-type   and
                    {&table-name}.supp-code  = bf_trn-doc.cli-code   and
                    {&table-name}.purch-code = {&bef-repayment-code} no-error.
         if not available {&table-name} then do:
            create {&table-name}.
            assign {&table-name}.supp-type  = bf_trn-doc.cli-type
                   {&table-name}.supp-code  = bf_trn-doc.cli-code
                   {&table-name}.purch-code = {&bef-repayment-code}
                   {&table-name}.supp-name  = bf_trn-doc.cli-name
                   {&table-name}.purch-name = {&repayment-code-full}.
         end.
         {&calc-sum-office}
      end.

      &scop table-name d-supp-fin
      if lookup( "{&table-name}", use-table ) > 0 then do:
         find first {&table-name} where
                    {&table-name}.supp-type     = bf_trn-doc.cli-type   and
                    {&table-name}.supp-code     = bf_trn-doc.cli-code   and
                    {&table-name}.contract-code = 0                     and
                    {&table-name}.purch-code    = {&bef-repayment-code} no-error.
         if not available {&table-name} then do:
            create {&table-name}.
            assign {&table-name}.supp-type     = bf_trn-doc.cli-type
                   {&table-name}.supp-code     = bf_trn-doc.cli-code
                   {&table-name}.contract-code = 0
                   {&table-name}.purch-code    = {&bef-repayment-code}
                   {&table-name}.supp-name     = bf_trn-doc.cli-name
                   {&table-name}.purch-name    = {&repayment-code-full}.
         end.
         {&calc-sum-office}
      end.

      &scop table-name d-supp-grp
      if lookup( "{&table-name}", use-table ) > 0 then do:
         find first {&table-name} where
                    {&table-name}.supp-type  = bf_trn-doc.cli-type   and
                    {&table-name}.supp-code  = bf_trn-doc.cli-code   and
                    {&table-name}.purch-code = {&bef-repayment-code} and
                    {&table-name}.grp-code   = bf_goods.grp-code     no-error.
         if not available {&table-name} then do:
            create {&table-name}.
            assign {&table-name}.supp-type  = bf_trn-doc.cli-type
                   {&table-name}.supp-code  = bf_trn-doc.cli-code
                   {&table-name}.purch-code = {&bef-repayment-code}
                   {&table-name}.grp-code   = bf_goods.grp-code
                   {&table-name}.supp-name  = bf_trn-doc.cli-name
                   {&table-name}.purch-name = {&repayment-code-full}
                   {&table-name}.grp-name   = varfull-name-grp.
         end.
         {&calc-sum-office}
      end.

      &scop table-name d-supp-grp-fin
      if lookup( "{&table-name}", use-table ) > 0 then do:
        find first {&table-name} where
                   {&table-name}.supp-type     = bf_trn-doc.cli-type   and
                   {&table-name}.supp-code     = bf_trn-doc.cli-code   and
                   {&table-name}.contract-code = 0                     and
                   {&table-name}.purch-code    = {&bef-repayment-code} and
                   {&table-name}.grp-code      = bf_goods.grp-code     no-error.
        if not available {&table-name} then do:
          create {&table-name}.
          assign {&table-name}.supp-type     = bf_trn-doc.cli-type
                 {&table-name}.supp-code     = bf_trn-doc.cli-code
                 {&table-name}.contract-code = 0
                 {&table-name}.purch-code    = {&bef-repayment-code}
                 {&table-name}.grp-code      = bf_goods.grp-code
                 {&table-name}.supp-name     = bf_trn-doc.cli-name
                 {&table-name}.purch-name    = {&repayment-code-full}
                 {&table-name}.grp-name      = varfull-name-grp.
        end.
        {&calc-sum-office}
      end.

      &scop table-name d-supp-slts-vats-cons
      if lookup( "{&table-name}", use-table ) > 0 then do:
        find first {&table-name} where
                   {&table-name}.supp-type  = bf_trn-doc.cli-type   and
                   {&table-name}.supp-code  = bf_trn-doc.cli-code   and
                   {&table-name}.vat-pc     = ?                     and
                   {&table-name}.slt-pc     = ?                     and
                   {&table-name}.purch-code = {&bef-repayment-code} no-error.
        if not available {&table-name} then do:
          create {&table-name}.
          assign {&table-name}.vat-pc     = ?
                 {&table-name}.slt-pc     = ?
                 {&table-name}.supp-type  = bf_trn-doc.cli-type
                 {&table-name}.supp-code  = bf_trn-doc.cli-code
                 {&table-name}.supp-name  = bf_trn-doc.cli-name
                 {&table-name}.purch-code = {&bef-repayment-code}
                 {&table-name}.purch-name = {&repayment-code-full}.
        end.
        {&calc-sum-office}
      end.

      &scop table-name d-supp-slts-vats-cons-fin
      if lookup( "{&table-name}", use-table ) > 0 then do:
        find first {&table-name} where
                   {&table-name}.supp-type     = bf_trn-doc.cli-type   and
                   {&table-name}.supp-code     = bf_trn-doc.cli-code   and
                   {&table-name}.vat-pc        = ?                     and
                   {&table-name}.slt-pc        = ?                     and
                   {&table-name}.contract-code = 0                     and
                   {&table-name}.purch-code    = {&bef-repayment-code} no-error.
        if not available {&table-name} then do:
          create {&table-name}.
          assign {&table-name}.vat-pc        = ?
                 {&table-name}.slt-pc        = ?
                 {&table-name}.contract-code = 0
                 {&table-name}.supp-type     = bf_trn-doc.cli-type
                 {&table-name}.supp-code     = bf_trn-doc.cli-code
                 {&table-name}.supp-name     = bf_trn-doc.cli-name
                 {&table-name}.purch-code    = {&bef-repayment-code}
                 {&table-name}.purch-name    = {&repayment-code-full}.
        end.
        {&calc-sum-office}
      end.
    end. /* for each bf_doc-line */
  end. /* transaction */
end procedure. /* calc-office */

procedure ClearAllTempTables :
  do on error undo, return error return-value :
    empty temp-table tt-title.
    empty temp-table d-supp.
    empty temp-table d-supp-grp.
    empty temp-table d-slt-vat.
    empty temp-table d-slt-vat-cons.
    empty temp-table d-slt-vat-cons-grp.
    empty temp-table d-supp-slts-vats-cons.
    empty temp-table d-slts-vats.
    empty temp-table d-slts-vats-cons.
    empty temp-table d-slts-vats-cons-grp.
    empty temp-table tt-title-fin.
    empty temp-table d-supp-fin.
    empty temp-table d-supp-grp-fin.
    empty temp-table d-slt-vat-cons-fin.
    empty temp-table d-slt-vat-cons-grp-fin.
    empty temp-table d-supp-slts-vats-cons-fin.
    empty temp-table d-slts-vats-cons-fin.
    empty temp-table d-slts-vats-cons-grp-fin.
  end.
end procedure. /* ClearAllTempTables */

procedure peresortica_gds-dtl:
do on error undo, return error return-value :
/* Имеется ли пересортица по признакам */
for each bf_gds-dtl no-lock where
         bf_gds-dtl.doc-code  = bf_doc-line.doc-code  and
         bf_gds-dtl.artic     = bf_doc-line.artic     and
         bf_gds-dtl.prod-code = bf_doc-line.prod-code and
         bf_gds-dtl.prod-type = bf_doc-line.prod-type on error undo, return error return-value :
  assign varqnty = ( if bf_trn-doc.doc-type = {&inventory} then bf_gds-dtl.doc-qnty else bf_gds-dtl.fact-qnty ).
  { str/out-vatp.i calc-gds-dtl bf_doc-line. bf_trn-doc. bf_gds-dtl. }
  { str/out-vatp.i calc-gds-dtl bf_doc-line. bf_trn-doc. bf_gds-dtl. "-cur" "''" "doc-code" "cur" }
  assign sum-price-rubl-with-tax-sale     = sum-price-rubl-with-tax-sale     + price-rubl-with-tax-sale     * varqnty
         sum-price-base-with-tax-sale     = sum-price-base-with-tax-sale     + price-base-with-tax-sale     * varqnty
         sum-vat-base-sale                = sum-vat-base-sale                + vat-base-sale                * varqnty
         sum-vat-rubl-sale                = sum-vat-rubl-sale                + vat-rubl-sale                * varqnty
         sum-vat-base-buyer               = sum-vat-base-buyer               + vat-base-buyer               * varqnty
         sum-vat-rubl-buyer               = sum-vat-rubl-buyer               + vat-rubl-buyer               * varqnty
         sum-slt-base-sale                = sum-slt-base-sale                + slt-base-sale                * varqnty
         sum-slt-rubl-sale                = sum-slt-rubl-sale                + slt-rubl-sale                * varqnty
         sum-road-tax-base-sale           = sum-road-tax-base-sale           + road-tax-base-sale           * varqnty
         sum-road-tax-rubl-sale           = sum-road-tax-rubl-sale           + road-tax-rubl-sale           * varqnty
         sum-excise-base-sale             = sum-excise-base-sale             + excise-base-sale             * varqnty
         sum-excise-rubl-sale             = sum-excise-rubl-sale             + excise-rubl-sale             * varqnty
         sum-discnt-base-sale             = sum-discnt-base-sale             + discnt-base-sale             * varqnty
         sum-discnt-rubl-sale             = sum-discnt-rubl-sale             + discnt-rubl-sale             * varqnty
         sum-price-rubl-with-tax-sale-cur = sum-price-rubl-with-tax-sale-cur + price-rubl-with-tax-sale-cur * varqnty
         sum-price-base-with-tax-sale-cur = sum-price-base-with-tax-sale-cur + price-base-with-tax-sale-cur * varqnty
         sum-vat-base-sale-cur            = sum-vat-base-sale-cur            + vat-base-sale-cur            * varqnty
         sum-vat-rubl-sale-cur            = sum-vat-rubl-sale-cur            + vat-rubl-sale-cur            * varqnty
         sum-vat-base-buyer-cur           = sum-vat-base-buyer-cur           + vat-base-buyer-cur           * varqnty
         sum-vat-rubl-buyer-cur           = sum-vat-rubl-buyer-cur           + vat-rubl-buyer-cur           * varqnty
         sum-slt-base-sale-cur            = sum-slt-base-sale-cur            + slt-base-sale-cur            * varqnty
         sum-slt-rubl-sale-cur            = sum-slt-rubl-sale-cur            + slt-rubl-sale-cur            * varqnty
         sum-road-tax-base-sale-cur       = sum-road-tax-base-sale-cur       + road-tax-base-sale-cur       * varqnty
         sum-road-tax-rubl-sale-cur       = sum-road-tax-rubl-sale-cur       + road-tax-rubl-sale-cur       * varqnty
         sum-excise-base-sale-cur         = sum-excise-base-sale-cur         + excise-base-sale-cur         * varqnty
         sum-excise-rubl-sale-cur         = sum-excise-rubl-sale-cur         + excise-rubl-sale-cur         * varqnty
         sum-discnt-base-sale-cur         = sum-discnt-base-sale-cur         + discnt-base-sale-cur         * varqnty
         sum-discnt-rubl-sale-cur         = sum-discnt-rubl-sale-cur         + discnt-rubl-sale-cur         * varqnty.
end. /* for each bf_gds-dtl */
if sum-price-rubl-with-tax-sale = 0 and sum-price-rubl-with-tax-sale-cur = 0 then do:
  return "line":u.
end.
else do:
  /* Заполнение таблиц */
  &scop calc-sum-dtl assign ~{&table-name}.fact-qnty           = 0 ~
                            ~{&table-name}.acc-base            = 0 ~
                            ~{&table-name}.acc-rubl            = 0 ~
                            ~{&table-name}.acc-vat-base        = 0 ~
                            ~{&table-name}.acc-vat-rubl        = 0 ~
                            ~{&table-name}.acc-slt-base        = 0 ~
                            ~{&table-name}.acc-slt-rubl        = 0 ~
                            ~{&table-name}.acc-road-tax-base   = 0 ~
                            ~{&table-name}.acc-road-tax-rubl   = 0 ~
                            ~{&table-name}.acc-excise-base     = 0 ~
                            ~{&table-name}.acc-excise-rubl     = 0 ~
                            ~{&table-name}.acc-transport-base  = 0 ~
                            ~{&table-name}.acc-transport-rubl  = 0 ~
                            ~{&table-name}.acc-other-base      = 0 ~
                            ~{&table-name}.acc-other-rubl      = 0 ~
                            ~{&table-name}.pay-base            = ~{&table-name}.pay-base            + sum-price-base-with-tax-sale ~
                            ~{&table-name}.pay-rubl            = ~{&table-name}.pay-rubl            + sum-price-rubl-with-tax-sale ~
                            ~{&table-name}.no-vat-base         = ~{&table-name}.no-vat-base         + sum-price-base-with-tax-sale - sum-vat-base-sale ~
                            ~{&table-name}.no-vat-rubl         = ~{&table-name}.no-vat-rubl         + sum-price-rubl-with-tax-sale - sum-vat-rubl-sale ~
                            ~{&table-name}.vat-base            = ~{&table-name}.vat-base            + sum-vat-base-sale  ~
                            ~{&table-name}.vat-rubl            = ~{&table-name}.vat-rubl            + sum-vat-rubl-sale  ~
                            ~{&table-name}.vat-base-buyer      = ~{&table-name}.vat-base-buyer      + sum-vat-base-buyer ~
                            ~{&table-name}.vat-rubl-buyer      = ~{&table-name}.vat-rubl-buyer      + sum-vat-rubl-buyer ~
                            ~{&table-name}.slt-base            = ~{&table-name}.slt-base            + sum-slt-base-sale ~
                            ~{&table-name}.slt-rubl            = ~{&table-name}.slt-rubl            + sum-slt-rubl-sale ~
                            ~{&table-name}.road-tax            = ~{&table-name}.road-tax            + (if varr-b = "base" then sum-road-tax-base-sale else sum-road-tax-rubl-sale) ~
                            ~{&table-name}.excise              = ~{&table-name}.excise              + (if varr-b = "base" then sum-excise-base-sale   else sum-excise-rubl-sale ) ~
                            ~{&table-name}.sale-base           = ~{&table-name}.sale-base           + sum-price-base-with-tax-sale-cur ~
                            ~{&table-name}.sale-rubl           = ~{&table-name}.sale-rubl           + sum-price-rubl-with-tax-sale-cur ~
                            ~{&table-name}.sale-vat-base       = ~{&table-name}.sale-vat-base       + sum-vat-base-sale-cur            ~
                            ~{&table-name}.sale-vat-rubl       = ~{&table-name}.sale-vat-rubl       + sum-vat-rubl-sale-cur            ~
                            ~{&table-name}.sale-vat-buyer-base = ~{&table-name}.sale-vat-buyer-base + sum-vat-base-buyer-cur           ~
                            ~{&table-name}.sale-vat-buyer-rubl = ~{&table-name}.sale-vat-buyer-rubl + sum-vat-rubl-buyer-cur           ~
                            ~{&table-name}.sale-slt-base       = ~{&table-name}.sale-slt-base       + sum-slt-base-sale-cur            ~
                            ~{&table-name}.sale-slt-rubl       = ~{&table-name}.sale-slt-rubl       + sum-slt-rubl-sale-cur            ~
                            ~{&table-name}.sale-road-tax-base  = ~{&table-name}.sale-road-tax-base  + sum-road-tax-base-sale-cur       ~
                            ~{&table-name}.sale-road-tax-rubl  = ~{&table-name}.sale-road-tax-rubl  + sum-road-tax-rubl-sale-cur       ~
                            ~{&table-name}.sale-excise-base    = ~{&table-name}.sale-excise-base    + sum-excise-base-sale-cur         ~
                            ~{&table-name}.sale-excise-rubl    = ~{&table-name}.sale-excise-rubl    + sum-excise-rubl-sale-cur         ~
                            ~{&table-name}.ov-base             = ~{&table-name}.ov-base             + (if varr-b = "base" then (sum-price-base-with-tax-sale-cur - sum-price-base-with-tax-sale) else (sum-price-rubl-with-tax-sale-cur - sum-price-rubl-with-tax-sale)) ~
                            ~{&table-name}.ov-vat              = ~{&table-name}.ov-vat              + (if varr-b = "base" then (sum-price-base-with-tax-sale-cur - sum-price-base-with-tax-sale) else (sum-price-rubl-with-tax-sale-cur - sum-price-rubl-with-tax-sale)) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc).
  &scop table-name tt-title
  find first {&table-name} where {&table-name}.purch-code = ? no-error.
  if not available {&table-name} then do:
    create {&table-name}.
    assign {&table-name}.purch-code = ?
           {&table-name}.purch-name = ?.
    {&calc-sum-dtl}
  end.

  &scop table-name tt-title-fin
  if varcalc-title-fin = yes then do:
    find first {&table-name} where
               {&table-name}.purch-code    = ? and
               {&table-name}.contract-code = 0 no-error.
    if not available {&table-name} then do:
      create {&table-name}.
      assign {&table-name}.purch-code    = ?
             {&table-name}.purch-name    = ?
             {&table-name}.contract-code = 0.
      {&calc-sum-dtl}
    end.
  end.

  &scop table-name d-slt-vat
  if lookup( "{&table-name}", use-table ) > 0 then do:
    find first {&table-name} where
               {&table-name}.vat-pc = bf_doc-line.vat-pc and
               {&table-name}.slt-pc = bf_doc-line.slt-pc no-error.
    if not available {&table-name} then do:
      create {&table-name}.
      assign {&table-name}.vat-pc = bf_doc-line.vat-pc
             {&table-name}.slt-pc = bf_doc-line.slt-pc.
    end.
    {&calc-sum-dtl}
  end.

  &scop table-name d-supp
  if lookup( "{&table-name}", use-table ) > 0 then do:
    find first {&table-name} where
               {&table-name}.supp-type  = ? and
               {&table-name}.supp-code  = ? and
               {&table-name}.purch-code = ? no-error.
    if not available {&table-name} then do:
      create {&table-name}.
      assign {&table-name}.supp-type  = ?
             {&table-name}.supp-code  = ?
             {&table-name}.purch-code = ?
             {&table-name}.supp-name  = "Пересортица по признакам"
             {&table-name}.purch-name = ?.
    end.
    {&calc-sum-dtl}
  end.

  &scop table-name d-supp-fin
  if lookup( "{&table-name}", use-table ) > 0 then do:
    find first {&table-name} where
               {&table-name}.supp-type     = ? and
               {&table-name}.supp-code     = ? and
               {&table-name}.purch-code    = ? and
               {&table-name}.contract-code = 0 no-error.
    if not available {&table-name} then do:
      create {&table-name}.
      assign {&table-name}.supp-type     = ?
             {&table-name}.supp-code     = ?
             {&table-name}.purch-code    = ?
             {&table-name}.supp-name     = "Пересортица по признакам"
             {&table-name}.purch-name    = ?
             {&table-name}.contract-code = 0.
    end.
    {&calc-sum-dtl}
  end.

  &scop table-name d-supp-grp
  if lookup( "{&table-name}", use-table ) > 0 then do:
    find first {&table-name} where
               {&table-name}.supp-type  = ?                 and
               {&table-name}.supp-code  = ?                 and
               {&table-name}.purch-code = ?                 and
               {&table-name}.grp-code   = bf_goods.grp-code no-error.
    if not available d-supp-grp then do:
      create {&table-name}.
      assign {&table-name}.supp-type  = ?
             {&table-name}.supp-code  = ?
             {&table-name}.purch-code = ?
             {&table-name}.grp-code   = bf_goods.grp-code
             {&table-name}.supp-name  = "Пересортица по признакам"
             {&table-name}.purch-name = ?
             {&table-name}.grp-name   = varfull-name-grp.
    end.
    {&calc-sum-dtl}
  end.

  &scop table-name d-supp-grp-fin
  if lookup( "{&table-name}", use-table ) > 0 then do:
    find first {&table-name} where
               {&table-name}.supp-type     = ?                 and
               {&table-name}.supp-code     = ?                 and
               {&table-name}.purch-code    = ?                 and
               {&table-name}.grp-code      = bf_goods.grp-code and
               {&table-name}.contract-code = 0                 no-error.
    if not available {&table-name} then do:
      create {&table-name}.
      assign {&table-name}.supp-type     = ?
             {&table-name}.supp-code     = ?
             {&table-name}.purch-code    = ?
             {&table-name}.grp-code      = bf_goods.grp-code
             {&table-name}.contract-code = 0
             {&table-name}.supp-name     = "Пересортица по признакам"
             {&table-name}.purch-name    = ?
             {&table-name}.grp-name      = varfull-name-grp.
    end.
    {&calc-sum-dtl}
  end.

  &scop table-name d-slt-vat-cons
  if lookup( "{&table-name}", use-table ) > 0 then do:
    find first {&table-name} where
               {&table-name}.vat-pc     = bf_doc-line.vat-pc and
               {&table-name}.slt-pc     = bf_doc-line.slt-pc and
               {&table-name}.purch-code = ?                  no-error.
    if not available {&table-name} then do:
      create {&table-name}.
      assign {&table-name}.vat-pc     = bf_doc-line.vat-pc
             {&table-name}.slt-pc     = bf_doc-line.slt-pc
             {&table-name}.purch-code = ?
             {&table-name}.purch-name = ?.
    end.
    {&calc-sum-dtl}
  end.

  &scop table-name d-slt-vat-cons-fin
  if lookup( "{&table-name}", use-table ) > 0 then do:
    find first {&table-name} where
               {&table-name}.vat-pc        = bf_doc-line.vat-pc and
               {&table-name}.slt-pc        = bf_doc-line.slt-pc and
               {&table-name}.contract-code = 0                  and
               {&table-name}.purch-code    = ?                  no-error.
    if not available {&table-name} then do:
      create {&table-name}.
      assign {&table-name}.vat-pc        = bf_doc-line.vat-pc
             {&table-name}.slt-pc        = bf_doc-line.slt-pc
             {&table-name}.purch-code    = ?
             {&table-name}.contract-code = 0
             {&table-name}.purch-name    = ?.
    end.
    {&calc-sum-dtl}
  end.

  &scop table-name d-slt-vat-cons-grp
  if lookup( "{&table-name}", use-table ) > 0 then do:
    find first {&table-name} where
               {&table-name}.vat-pc     = bf_doc-line.vat-pc and
               {&table-name}.slt-pc     = bf_doc-line.slt-pc and
               {&table-name}.purch-code = ?                  and
               {&table-name}.grp-code   = bf_goods.grp-code  no-error.
    if not available {&table-name} then do:
      create {&table-name}.
      assign {&table-name}.vat-pc     = bf_doc-line.vat-pc
             {&table-name}.slt-pc     = bf_doc-line.slt-pc
             {&table-name}.purch-code = ?
             {&table-name}.purch-name = ?
             {&table-name}.grp-code   = bf_goods.grp-code
             {&table-name}.grp-name   = varfull-name-grp.
    end.
    {&calc-sum-dtl}
  end.

  &scop table-name d-slt-vat-cons-grp-fin
  if lookup( "{&table-name}", use-table ) > 0 then do:
    find first {&table-name} where
               {&table-name}.vat-pc        = bf_doc-line.vat-pc and
               {&table-name}.slt-pc        = bf_doc-line.slt-pc and
               {&table-name}.purch-code    = ?                  and
               {&table-name}.contract-code = 0                  and
               {&table-name}.grp-code      = bf_goods.grp-code  no-error.
    if not available {&table-name} then do:
      create {&table-name}.
      assign {&table-name}.vat-pc        = bf_doc-line.vat-pc
             {&table-name}.slt-pc        = bf_doc-line.slt-pc
             {&table-name}.purch-code    = ?
             {&table-name}.purch-name    = ?
             {&table-name}.grp-code      = bf_goods.grp-code
             {&table-name}.grp-name      = varfull-name-grp
             {&table-name}.contract-code = 0.
    end.
    {&calc-sum-dtl}
  end.

  &scop table-name d-supp-slts-vats-cons
  if lookup( "{&table-name}", use-table ) > 0 then do:
    find first {&table-name} where
               {&table-name}.supp-type  = ? and
               {&table-name}.supp-code  = ? and
               {&table-name}.vat-pc     = ? and
               {&table-name}.slt-pc     = ? and
               {&table-name}.purch-code = ? no-error.
    if not available {&table-name} then do:
      create {&table-name}.
      assign {&table-name}.vat-pc     = ?
             {&table-name}.slt-pc     = ?
             {&table-name}.supp-type  = ?
             {&table-name}.supp-code  = ?
             {&table-name}.supp-name  = "пересортица по признакам"
             {&table-name}.purch-code = ?
             {&table-name}.purch-name = ?.
    end.
    {&calc-sum-dtl}
  end.

  &scop table-name d-supp-slts-vats-cons-fin
  if lookup( "{&table-name}", use-table ) > 0 then do:
    find first {&table-name} where
               {&table-name}.supp-type     = ? and
               {&table-name}.supp-code     = ? and
               {&table-name}.vat-pc        = ? and
               {&table-name}.slt-pc        = ? and
               {&table-name}.purch-code    = ? and
               {&table-name}.contract-code = 0 no-error.
    if not available {&table-name} then do:
      create {&table-name}.
      assign {&table-name}.vat-pc        = ?
             {&table-name}.slt-pc        = ?
             {&table-name}.supp-type     = ?
             {&table-name}.supp-code     = ?
             {&table-name}.supp-name     = "пересортица по признакам"
             {&table-name}.purch-code    = ?
             {&table-name}.purch-name    = ?
             {&table-name}.contract-code = 0.
    end.
    {&calc-sum-dtl}
  end.

  &scop table-name d-slts-vats
  if lookup( "{&table-name}", use-table ) > 0 then do:
    find first {&table-name} where
               {&table-name}.vat-pc = ? and
               {&table-name}.slt-pc = ? no-error.
    if not available {&table-name} then do:
      create {&table-name}.
      assign {&table-name}.vat-pc = ?
             {&table-name}.slt-pc = ?.
    end.
    {&calc-sum-dtl}
  end.

  &scop table-name d-slts-vats-cons
  if lookup( "{&table-name}", use-table ) > 0 then do:
    find first {&table-name} where
               {&table-name}.vat-pc     = ? and
               {&table-name}.slt-pc     = ? and
               {&table-name}.purch-code = ? no-error.
    if not available {&table-name} then do:
      create {&table-name}.
      assign {&table-name}.vat-pc     = ?
             {&table-name}.slt-pc     = ?
             {&table-name}.purch-code = ?
             {&table-name}.purch-name = ?.
    end.
    {&calc-sum-dtl}
  end.

  &scop table-name d-slts-vats-cons-fin
  if lookup( "{&table-name}", use-table ) > 0 then do:
    find first {&table-name} where
               {&table-name}.vat-pc        = ? and
               {&table-name}.slt-pc        = ? and
               {&table-name}.contract-code = 0 and
               {&table-name}.purch-code    = ? no-error.
    if not available {&table-name} then do:
      create {&table-name}.
      assign {&table-name}.vat-pc        = ?
             {&table-name}.slt-pc        = ?
             {&table-name}.contract-code = 0
             {&table-name}.purch-code    = ?
             {&table-name}.purch-name    = ?.
    end.
    {&calc-sum-dtl}
  end.

  &scop table-name d-slts-vats-cons-grp
  if lookup( "{&table-name}", use-table ) > 0 then do:
    find first {&table-name} where
               {&table-name}.vat-pc     = ?                 and
               {&table-name}.slt-pc     = ?                 and
               {&table-name}.purch-code = ?                 and
               {&table-name}.grp-code   = bf_goods.grp-code no-error.
    if not available {&table-name} then do:
      create {&table-name}.
      assign {&table-name}.vat-pc     = ?
             {&table-name}.slt-pc     = ?
             {&table-name}.purch-code = ?
             {&table-name}.purch-name = ?
             {&table-name}.grp-code   = bf_goods.grp-code
             {&table-name}.grp-name   = varfull-name-grp.
    end.
    {&calc-sum-dtl}
  end.
  &scop table-name d-slts-vats-cons-grp-fin
  if lookup( "{&table-name}", use-table ) > 0 then do:
    find first {&table-name} where
               {&table-name}.vat-pc        = ?                 and
               {&table-name}.slt-pc        = ?                 and
               {&table-name}.purch-code    = ?                 and
               {&table-name}.contract-code = 0                 and
               {&table-name}.grp-code      = bf_goods.grp-code no-error.
    if not available {&table-name} then do:
      create {&table-name}.
      assign {&table-name}.vat-pc        = ?
             {&table-name}.slt-pc        = ?
             {&table-name}.purch-code    = ?
             {&table-name}.purch-name    = ?
             {&table-name}.contract-code = 0
             {&table-name}.grp-code      = bf_goods.grp-code
             {&table-name}.grp-name      = varfull-name-grp.
    end.
    {&calc-sum-dtl}
  end.
  return.
end. /* Заполнение таблиц */

end.
end procedure.

