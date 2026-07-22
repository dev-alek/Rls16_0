/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$



Автор: Чернова Светлана Александровна
Дата создания: 02/05/10
Author: Svetlana Chernova
Creation date: 02/05/10

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
/*
=use-column[97]    o_temp-parts.price-prod                   1.  Цена производителя без НДС.
=use-column[98]    o_temp-parts.price-prodwithvat            2.  Цена производителя с НДС.
=use-column[99]    o_temp-parts.prod-vat                     3.  НДС производителя, сумма
=use-column[100]   o_temp-parts.prod-vat-prc                 4.  НДС производителя, %
 use-column[101]   o_temp-parts.price-supp                   5.  Цена поставщика без НДС
=use-column[102]   o_temp-parts.price-suppvat                6.  Цена поставщика с НДС
 use-column[103]   o_temp-parts.suppvat                      7.  НДС поставщика, сумма
=use-column[104]   o_temp-parts.suppvat-prc                  8.  НДС поставщика, %
 use-column[105]   o_temp-parts.dis-1                        9.  Размер оптовой надбавки, сумма
 use-column[106]   o_temp-parts.dis-1-prc                    10. Размер оптовой надбавки, %
=use-column[107]   o_temp-parts.prod-crsavat                 11. Розничная цена с НДС
  use-column[108]   o_temp-parts.prod-crsa                    12. Розничная цена без НДС
  use-column[109]   o_temp-parts.vat-crsa                     13. Сумма НДС, руб
  use-column[110]   o_temp-parts.vat-crsa-prc                 14. Ставка НДС, %
  use-column[111]   o_temp-parts.dis-2                        15. Размер розничной надбавки, сумма
  use-column[112]   o_temp-parts.dis-2-prc                    16. Размер розничной надбавки, %.
  use-column[113]   o_temp-parts.dis-3                        17. Размер общей надбавки, сумма
  use-column[114]   o_temp-parts.dis-3-prc                    18. Размер общей надбавки, %
  use-column[115]   o_temp-parts.dis-2vat                     19. Размер розничной надбавки (с НДС), сумма
  use-column[116]   o_temp-parts.dis-2-prcvat                 20. Размер розничной надбавки (с НДС), %.
  use-column[117]   o_temp-parts.dis-3vat                     21. Размер общей надбавки (с НДС), сумма
  use-column[118]   o_temp-parts.dis-3-prcvat                 22. Размер общей надбавки (с НДС), %
*/

  { gbl/partppric.i
    {1}
    o_temp-parts.price-prod
    o_temp-parts.price-prodwithvat
    o_temp-parts.prod-vat-prc
  }
   o_temp-parts.prod-vat = o_temp-parts.price-prodwithvat -  o_temp-parts.price-prod .



assign
  o_temp-parts.gds-name    = f-cli-name ({1}.supp-type,{1}.supp-code)
  o_temp-parts.Cost-Price  = {1}.price-rubl


  o_temp-parts.b-code      = f-bar-code ({1}.artic,{1}.prod-type,{1}.prod-code,{1}.part-code,{1}.in-code)
  v-cur-dn = ""
  v-cur-pr = 0
  .

if o_temp-parts.b-code <> 0 then do:
/* цена баркода не конец отчета */
{ gbl/bcodeprc.i
  o_temp-parts.obj-type
  o_temp-parts.obj-code
  o_temp-parts.b-code
  0
  v-fact-order-end
  v-cur-dn
  v-cur-pr
  v-cur-rt
  v-cur-ex
  }
end.

  o_temp-parts.Last-Sale-Price = if v-cur-pr = ? then 0 else v-cur-pr.
  o_temp-parts.LastPer-Num     = if v-cur-dn = ? then "" else v-cur-dn.

  find first buf_price-doc no-lock where buf_price-doc.doc-num = v-cur-dn no-error .
  if available buf_price-doc then do:
      o_temp-parts.LastPer-Date = buf_price-doc.fact-date.
  end.
  else do:
      o_temp-parts.LastPer-Date = date("").
  end.

      create tt-clcparts.
      buffer-copy {1} to tt-clcparts.
      run clcprtsl_calc-parts (
            input recid( tt-clcparts )
          , input yes
          , input yes
          , input 0
          , input 0
          , input 0
          , input 0
          , input 0
          , input 0
          , input 0
          , input 0
          , input 0
          , input 0
          , input 0
          , input 0
          , input 0
          , input 0
      ) .
            find first tt-allsum
                 where tt-allsum.sum-type = {&sum-general}
            .

 { gbl/pftxvalg.i buf_goods.gds-code {&vat-tax-code} ? {1}.host-code {1}.obj-type {1}.obj-code v-vat-pc no-error }

  assign
    o_temp-parts.suppvat        = tt-allsum.vat-rubl-acc / {1}.fact-qnty
    o_temp-parts.price-suppvat  = {1}.price-rubl
    o_temp-parts.price-supp     = o_temp-parts.price-suppvat - o_temp-parts.suppvat
    o_temp-parts.suppvat-prc    = {1}.vat-pc

    o_temp-parts.prod-crsavat   = o_temp-parts.Last-Sale-Price
    o_temp-parts.dis-1          =   o_temp-parts.price-supp - o_temp-parts.price-prod
    o_temp-parts.dis-1-prc      = ((o_temp-parts.price-supp / o_temp-parts.price-prod) - 1 ) * 100

    o_temp-parts.vat-crsa-prc   = v-vat-pc
    o_temp-parts.vat-crsa       = o_temp-parts.prod-crsavat * o_temp-parts.vat-crsa-prc / ( 100 + o_temp-parts.vat-crsa-prc )
    o_temp-parts.prod-crsa      = o_temp-parts.prod-crsavat - o_temp-parts.vat-crsa

    o_temp-parts.dis-2          =    o_temp-parts.prod-crsa - o_temp-parts.price-supp
    o_temp-parts.dis-2-prc      = ((o_temp-parts.prod-crsa - o_temp-parts.price-supp) / o_temp-parts.price-prod ) * 100

    o_temp-parts.dis-3          =    o_temp-parts.prod-crsa - o_temp-parts.price-prod
    o_temp-parts.dis-3-prc      = (( o_temp-parts.prod-crsa / o_temp-parts.price-prod ) - 1 ) * 100

    o_temp-parts.dis-2vat       =    o_temp-parts.prod-crsavat - o_temp-parts.price-suppvat
    o_temp-parts.dis-2-prcvat   = ((o_temp-parts.prod-crsavat - o_temp-parts.price-suppvat) / o_temp-parts.price-prodwithvat ) * 100

    o_temp-parts.dis-3vat       =    o_temp-parts.prod-crsavat - o_temp-parts.price-prodwithvat
    o_temp-parts.dis-3-prcvat   = (( o_temp-parts.prod-crsavat / o_temp-parts.price-prodwithvat ) - 1 ) * 100

  .

/* $Workfile$ e n d */