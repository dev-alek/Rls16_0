/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Автор: Чернова Светлана Александровна
Дата создания: 10/10/06
Author: Svetlana Chernova
Creation date: 10/10/06

create: Суслов Алексей Юрьевич


*/
if doc-line.fact-qnty = 0 then next.
ACCUMULATE
    /*Налог с пр. (вал.) SLT-{1}-base*/        acc-slt-base-inv        * parts.fact-qnty / doc-line.fact-qnty (TOTAL {1})
    /*НДС (вал.) VAT-{1}-base*/                acc-vat-base-inv        * parts.fact-qnty / doc-line.fact-qnty (TOTAL {1})
    /*Налог  с пр. (р_уб.) SLT-{1}-rubl*/       acc-slt-rubl-inv        * parts.fact-qnty / doc-line.fact-qnty (TOTAL {1})
    /*НДС (р_уб.) VAT-{1}-rubl*/                acc-vat-rubl-inv        * parts.fact-qnty / doc-line.fact-qnty (TOTAL {1})
    /*К оплате (вал.) pay-{1}-base*/           acc-no-vat-base-inv     * parts.fact-qnty / doc-line.fact-qnty (TOTAL {1})
    /*К оплате (р_уб.) pay-{1}-rubl*/           acc-no-vat-rubl-inv     * parts.fact-qnty / doc-line.fact-qnty (TOTAL {1})
    /*Продаж. цены (вал.) sal-{1}-base*/       acc-cur-base-inv        * parts.fact-qnty / doc-line.fact-qnty (TOTAL {1})
    /*Переоценка (вал.) ov-{1}-base*/          acc-cur-price-base-inv  * parts.fact-qnty / doc-line.fact-qnty (TOTAL {1})
    /*НДС {&overvalue} (вал.) ov-{1}-vat*/     acc-cur-price-vat-inv   * parts.fact-qnty / doc-line.fact-qnty (TOTAL {1})
    /*дорожный налог*/                         acc-road-tax-inv        * parts.fact-qnty / doc-line.fact-qnty (TOTAL {1})
    /*акциз*/                                  acc-excise-inv          * parts.fact-qnty / doc-line.fact-qnty (TOTAL {1})
    /* А это не при инвентаризации*/
    /*acc-{1}-base*/       parts.price-base * parts.fact-qnty (TOTAL {1})
    /*acc-{1}-rubl*/       parts.price-rubl * parts.fact-qnty (TOTAL {1})
    /*SLT-{1}-base*/       acc-slt-base * parts.fact-qnty / doc-line.fact-qnty (TOTAL {1})
    /*VAT-{1}-base*/       acc-vat-base * parts.fact-qnty / doc-line.fact-qnty (TOTAL {1})
   /*no-VAT-{1}-base*/     acc-no-vat-base * parts.fact-qnty / doc-line.fact-qnty (TOTAL {1})
    /*SLT-{1}-rubl*/       acc-slt-rubl * parts.fact-qnty / doc-line.fact-qnty (TOTAL {1})
    /*VAT-{1}-rubl*/       acc-vat-rubl * parts.fact-qnty / doc-line.fact-qnty (TOTAL {1})
    /*no-VAT-{1}-rubl*/    acc-no-vat-rubl  * parts.fact-qnty / doc-line.fact-qnty (TOTAL {1})
    /*pay-{1}-base*/       acc-price-base * parts.fact-qnty / doc-line.fact-qnty (TOTAL {1})
    /*pay-{1}-rubl*/       acc-price-rubl * parts.fact-qnty / doc-line.fact-qnty (TOTAL {1})
    /*sal-{1}-base*/       acc-cur-base * parts.fact-qnty / doc-line.fact-qnty (TOTAL {1})
    /*ov-{1}-base*/        acc-cur-price-base  *  parts.fact-qnty / doc-line.fact-qnty (TOTAL {1})
    /*ov-{1}-vat*/         acc-cur-price-vat  *  parts.fact-qnty / doc-line.fact-qnty (TOTAL {1})
    /*дорожный налог*/     varroad-tax-fact * parts.fact-qnty / doc-line.fact-qnty (TOTAL {1})
    /*акциз*/              varexcise-fact * parts.fact-qnty / doc-line.fact-qnty (TOTAL {1}).
if t-doc.doc-type = {&inventory} then
  assign
    {2}varfact-qnty   = parts.fact-qnty * doc-line.fact-qnty / doc-line.fact-qnty
    {2}varfact-base   = parts.fact-qnty * parts.price-base * doc-line.fact-qnty / doc-line.fact-qnty
    {2}varfact-rubl   = parts.fact-qnty * parts.price-rubl * doc-line.fact-qnty / doc-line.fact-qnty
    {2}varsale-base   = acc-cur-base-inv * parts.fact-qnty / doc-line.fact-qnty
    {2}varpay-base    = acc-no-vat-base-inv * parts.fact-qnty / doc-line.fact-qnty
    {2}varpay-rubl    = acc-no-vat-rubl-inv * parts.fact-qnty / doc-line.fact-qnty
    {2}varSLT-base    = acc-slt-base-inv * parts.fact-qnty / doc-line.fact-qnty
    {2}varVAT-base    = acc-vat-base-inv * parts.fact-qnty / doc-line.fact-qnty
    {2}varSLT-rubl    = acc-slt-rubl-inv * parts.fact-qnty / doc-line.fact-qnty
    {2}varVAT-rubl    = acc-vat-rubl-inv * parts.fact-qnty / doc-line.fact-qnty
    {2}varov-base     = acc-cur-price-base-inv * parts.fact-qnty / doc-line.fact-qnty
    {2}varov-vat      = acc-cur-price-vat-inv * parts.fact-qnty / doc-line.fact-qnty
    {2}varno-VAT-base = acc-no-vat-base-inv * parts.fact-qnty / doc-line.fact-qnty
    {2}varno-VAT-rubl = acc-no-vat-rubl-inv * parts.fact-qnty / doc-line.fact-qnty
    {2}varroad-tax    = acc-road-tax-inv * parts.fact-qnty / doc-line.fact-qnty
    {2}varexcise      = acc-excise-inv   * parts.fact-qnty / doc-line.fact-qnty.
else
  assign
    {2}varfact-qnty =  parts.fact-qnty
    {2}varfact-base =  parts.fact-qnty * parts.price-base
    {2}varfact-rubl =  parts.fact-qnty * parts.price-rubl
    {2}varsale-base =  acc-cur-base * parts.fact-qnty / doc-line.fact-qnty
    {2}varpay-base  =  acc-price-base * parts.fact-qnty / doc-line.fact-qnty
    {2}varpay-rubl  =  acc-price-rubl  * parts.fact-qnty / doc-line.fact-qnty
    {2}varSLT-base  =  acc-slt-base * parts.fact-qnty / doc-line.fact-qnty
    {2}varVAT-base  = acc-vat-base * parts.fact-qnty / doc-line.fact-qnty
    {2}varno-VAT-base = acc-no-vat-base  *  parts.fact-qnty / doc-line.fact-qnty
    {2}varSLT-rubl = acc-slt-rubl * parts.fact-qnty / doc-line.fact-qnty
    {2}varVAT-rubl = acc-vat-rubl * parts.fact-qnty / doc-line.fact-qnty
    {2}varno-VAT-rubl =  acc-no-vat-rubl  *    parts.fact-qnty / doc-line.fact-qnty
    {2}varov-base =  acc-cur-price-base * parts.fact-qnty / doc-line.fact-qnty
    {2}varov-vat =  acc-cur-price-vat * parts.fact-qnty / doc-line.fact-qnty
    {2}varroad-tax    = acc-road-tax * parts.fact-qnty / doc-line.fact-qnty
    {2}varexcise      = acc-excise * parts.fact-qnty / doc-line.fact-qnty.
/* $Workfile$ e n d */