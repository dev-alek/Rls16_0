block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-zum5.p $
$Archive: cus/r-zum5.p $

Заказной отчет дял ЦУМА-5

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/03/04
Author: Bakhtadze Natalya
Creation date: 02/03/04

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-by as integer no-undo .
define input parameter p-by2 as integer no-undo .
define input parameter p-start-date as date no-undo .
define input parameter p-end-date as date no-undo .
define input parameter p-report-header as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-zum5.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/r-zum5.p $":U .
define variable vss-description as character no-undo init "Заказной отчет дял ЦУМА-5".
{ cmp/vssrevis.i }


{ cmp/str-glbl.i }
{ cmp/library.i }
{ gbl/waitfram.i }
{ cmp/r-pril.i }
{ cmp/r-page1.i }
{ gbl/prn-lib.i }
{ cmp/doc-list.i doc-list def "shared" }
{ cmp/library.i  }
{ str/out-vatp.i def }
{ str/in-vatp.i def }
{ str/lib-calc.i }
{ cus/e-zum5.i " " }
{ gbl/cur-time.i }
{ cmp/isengfrm.i }

{ gbl/getcntxt.i def }
{ rep/lhstprex.i doc-list-hist }


/*вспомогательные*/
define variable slt-calc as dec.
define variable vat-cost as dec.
define variable is-out as integer init 1.

DEFINE variable v-root-b-code like ub.bar-code.b-code no-undo.
DEFINE VARIABLE v-need-postformat as logical no-undo .

define buffer buf_trn-doc for ub.trn-doc.
define buffer obj_clients for ub.clients.
define variable p-XL-delim as character no-undo .
define variable type-par1 as character no-undo .
define variable tmp-var1  as character no-undo .

FOR EACH sj-goods :
    delete sj-goods .
END .

FOR EACH sj-parts :
    delete sj-parts .
END .

FOR EACH sj-gds-dtl :
    delete sj-gds-dtl .
END .

{ gbl/getcntxt.i get }
{ gbl/getsect.i def }
{ gbl/getsect.i run v-cntxt-obj-type  v-cntxt-obj-code {&attr-report-firm} }
for each thbjattr_thbj-attr :
    if thbjattr_thbj-attr.prop-code = 'XL-delim'  then tmp-var1   = thbjattr_thbj-attr.property-value-character.
end.
IF tmp-var1 = "" then p-XL-delim = ";".
else p-XL-delim = tmp-var1.

run prn-lib-open-stream  in this-procedure (
                                             input parParentProc
                                            ,input 0
                                            ,input yes /*p-is-stream*/
                                            ,input no /*p-append*/
                                            ).


run waitfram-show in this-procedure ("Ждите...").
PUT stream PrnLibStream UNFORMATTED
("Отчет по документам с " +
string( X-date-start, "99/99/9999" ) + " по " + string(X-date-end, "99/99/9999") + ".")
format "x(110)" SKIP(1).
PUT stream PrnLibStream p-report-header format "X(100)" SKIP(0).
PUT stream PrnLibStream string("По объектам: "  )
    format "X(20)" SKIP.

FOR EACH obj-list :
FIND FIRST obj_clients WHERE
          obj_clients.obj-type = obj-list.obj-type
      AND obj_clients.obj-code = obj-list.obj-code NO-LOCK .
PUT stream PrnLibStream UNFORMATTED obj_clients.obj-name  ", ".
END.

PUT stream PrnLibStream UNFORMATTED
SKIP
cur-time-print() format "x(35)"  SKIP.

PUT stream PrnLibStream UNFORMATTED
replace(sheetf.Excel-Column-Lable, {&comma-char}, p-XL-delim)
SKIP(0).
run rep/extitle.p (1).

_obj-list:
FOR EACH obj-list NO-LOCK:
  CASE p-by:
    when 1 or
    when 2 or
    when 3
    then do:
      if p-by2 = 1
      or p-by2 = 3 then  do:
      /*розница или все */
        /*расход розница*/
        if p-by = 1
        or p-by = 3 then do:
          /*расход*/
          is-out = 1.
          for each buf_trn-doc where
                  buf_trn-doc.fact-date >= p-start-date
              AND buf_trn-doc.fact-date <= p-end-date
              AND buf_trn-doc.obj-code = obj-list.obj-code
              AND buf_trn-doc.obj-type = obj-list.obj-type
              AND buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_Kass}
              AND buf_trn-doc.status_ = {&fact}
              AND buf_trn-doc.internal = no
              AND buf_trn-doc.doc-type = {&expense}:
            run cr-sj-goods in this-procedure (buf_trn-doc.doc-code) no-error .
          end.
        end.
        /*возврат розница*/
        if p-by = 1
        or p-by = 3 then do:
        /*возврат*/
          is-out =  - 1.
          for each buf_trn-doc where
                  buf_trn-doc.fact-date >= p-start-date
              AND buf_trn-doc.fact-date <= p-end-date
              AND buf_trn-doc.obj-code = obj-list.obj-code
              AND buf_trn-doc.obj-type = obj-list.obj-type
              AND buf_trn-doc.ext-doc-type = {&TDEDT_Vozvrat_Vnesh_Kass}
              AND buf_trn-doc.status_ = {&fact}
              AND buf_trn-doc.internal = no
              AND buf_trn-doc.doc-type = {&return}:
            run cr-sj-goods in this-procedure (buf_trn-doc.doc-code) no-error .
          end.
        end.
      end.
      if p-by2 = 2
      or p-by2 = 3 then do:
        /*расход опт*/
        if p-by = 1
        or p-by = 2
        then do:
          /*расход или расход и возврат*/
          is-out = 1.
          for each buf_trn-doc where
                  buf_trn-doc.fact-date >= p-start-date
              AND buf_trn-doc.fact-date <= p-end-date
              AND buf_trn-doc.obj-code = obj-list.obj-code
              AND buf_trn-doc.obj-type = obj-list.obj-type
              AND buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh}
              AND buf_trn-doc.status_ = {&fact}
              AND buf_trn-doc.internal = no
              AND buf_trn-doc.doc-type = {&expense}:
            run cr-sj-goods in this-procedure (buf_trn-doc.doc-code) no-error .
          end.
        end.
        /*возврат опт*/
        if p-by = 1
        or p-by = 3
        then do:
          /*возварт или расход и возврат*/
          is-out =  - 1.
          for each buf_trn-doc where
                  buf_trn-doc.fact-date >= p-start-date
              AND buf_trn-doc.fact-date <= p-end-date
              AND buf_trn-doc.obj-code = obj-list.obj-code
              AND buf_trn-doc.obj-type = obj-list.obj-type
              AND buf_trn-doc.ext-doc-type = {&TDEDT_Vozvrat_Vnesh}
              AND buf_trn-doc.status_ = {&fact}
              AND buf_trn-doc.internal = no
              AND buf_trn-doc.doc-type = {&return}:
            run cr-sj-goods in this-procedure (buf_trn-doc.doc-code) no-error .
          end.
        end.
      end.
    end. /*when p-by = 1  2 3*/
    when 4 then do:
      /*списание*/
      is-out = 1.
      for each buf_trn-doc where
              buf_trn-doc.fact-date >= p-start-date
          AND buf_trn-doc.fact-date <= p-end-date
          AND buf_trn-doc.obj-code = obj-list.obj-code
          AND buf_trn-doc.obj-type = obj-list.obj-type
          AND buf_trn-doc.ext-doc-type = {&TDEDT_Spi_Vnesh}
          AND buf_trn-doc.status_ = {&fact}
          AND buf_trn-doc.internal = no :
        run cr-sj-goods in this-procedure (buf_trn-doc.doc-code) no-error .
      end.
    end.
    when 5 then do:
      for each doc-list no-lock:
         if doc-list.fact-date < p-start-date
         or doc-list.fact-date > p-end-date
         or doc-list.obj-code <> obj-list.obj-code
         or doc-list.obj-type <> obj-list.obj-type then NEXT.
         if doc-list.ext-doc-type = {&TDEDT_Ras_Vnesh_Kass}
         or doc-list.ext-doc-type = {&TDEDT_Vozvrat_Vnesh_Kass}
         or doc-list.ext-doc-type = {&TDEDT_Ras_Vnesh}
         or doc-list.ext-doc-type = {&TDEDT_Vozvrat_Vnesh}
         or doc-list.ext-doc-type = {&TDEDT_Spi_Vnesh}
         then
         run cr-sj-goods in this-procedure (doc-list.doc-code) no-error .
      end.
    end.
  END CASE.
END. /*FOR EACH obj*/

if Print-List-hist
and can-find(first doc-list) then do:
  run lhistprex-print-doc-list-hist-excel  in this-procedure (input yes, input yes, 2).
end.

output stream PrnLibStream CLOSE .
{&CloseExcel}
if v-need-postformat then do:
  assign
  sheetf.colformat = sheetf.colformat + {&delim-par} + "13=@"
  .
end.
run waitfram-hide in this-procedure .
run prn-lib-prn-file in this-procedure (
                                          input parParentProc
                                          ,input 11
                                          ).




procedure cr-sj-goods :
define input parameter p-doc-code like ub.trn-doc.doc-code no-undo .


define variable jj as integer no-undo .
define variable cur-quant like ub.gds-dtl.doc-qnty no-undo.
define variable v-is-attr       as logical no-undo .
define variable v-supp-type         like ub.parts-attr.supp-type no-undo .
define variable v-supp-code         like ub.parts-attr.supp-code no-undo .
define variable v-supp-pay-code     like ub.parts-attr.pay-code no-undo .
define variable v-purch-code        like ub.parts-attr.purch-code no-undo .
define variable v-in-code           like ub.parts-attr.income-in-code no-undo .
define variable v-part-code         like ub.parts-attr.part-code no-undo .
define variable v-supp-vat-pc       like ub.parts-attr.vat-pc no-undo .
define variable v-price-sale        like ub.price-list.price-sale no-undo .
define variable v-doc-num           like ub.price-list.doc-num no-undo .
define variable v-road-tax          like ub.price-list.road-tax no-undo .
define variable v-excise            like ub.price-list.excise no-undo .
define variable v-leave-cycle      as logical no-undo .

define buffer buf_trn-doc for ub.trn-doc.
define buffer buf_doc-line for ub.doc-line.
define buffer buf_gds-dtl for ub.gds-dtl.
define buffer buf_goods for ub.goods.
define buffer buf_bar-code for ub.bar-code.
define buffer buf_gds-prt for ub.gds-prt.
define buffer buf_parts for ub.parts.
define buffer buf_parts-attr for ub.parts-attr.
define buffer buf_clients for ub.clients.
define buffer buf_sup_clients for ub.clients.
define buffer buf_sj-gds-dtl for sj-gds-dtl.

&scoped-define PLUS-docs 'ie,re,rs,vt,im':U

  do
  on error undo, return error
  :
    find first buf_trn-doc no-lock where
              buf_trn-doc.doc-code = p-doc-code .
    if buf_trn-doc.office then return.
    if buf_trn-doc.status_ <> {&fact}
    or buf_trn-doc.internal <> no
    then return.
    is-out = if lookup(buf_trn-doc.ext-doc-type, {&Plus-docs}) > 0 then 1 else -1.

   _docline:
    FOR EACH buf_doc-line WHERE
            buf_doc-line.doc-code = p-doc-code NO-LOCK:
      PROCESS EVENTS.
      jj = jj + 1 .
      if ( jj  modulo 10 ) = 0  then
      run waitfram-show in this-procedure (input ("Обработано строк накладных : " +   string(  jj ) ) ).

      FIND FIRST buf_goods No-LOCK WHERE
                 buf_goods.artic = buf_doc-line.artic
             AND buf_goods.prod-type = buf_doc-line.prod-type
             AND buf_goods.prod-code = buf_doc-line.prod-code No-ERROR.
      if not avail buf_goods then do:
        message
        vss-workfile vss-revision vss-description skip
        "Не найден товар" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code
        view-as alert-box error .
        return error.
      end.

      assign
      v-need-postformat = v-need-postformat or IsEngFrm(buf_goods.artic)
      .


      find first buf_clients no-lock where
                buf_clients.obj-type = buf_goods.prod-type
            AND buf_clients.obj-code = buf_goods.prod-code no-error .

      { gbl/gdsbcode.i buf_goods.gds-code ? v-root-b-code no-error }

      FOR EACH buf_parts NO-LOCK WHERE
              buf_parts.artic = buf_doc-line.artic
         AND  buf_parts.prod-type = buf_doc-line.prod-type
         AND  buf_parts.prod-code = buf_doc-line.prod-code
         AND  buf_parts.out-code = p-doc-code
         AND  buf_parts.obj-type = buf_doc-line.obj-type
         AND  buf_parts.obj-code = buf_doc-line.obj-code:
        { str/in-vatp.i calc-parts buf_parts. buf_trn-doc. " " " " }
        find first buf_parts-attr no-lock where
                  buf_parts-attr.in-code  = buf_parts.in-code
            AND  buf_parts-attr.gds-code = buf_goods.gds-code
            AND buf_parts-attr.part-code = buf_parts.part-code no-error .
        if available buf_parts-attr then do:
          assign
          v-is-attr      = yes
          v-supp-VAt-pc  = buf_parts-attr.vat-pc
          v-supp-type    = buf_parts-attr.supp-type
          v-supp-code    = buf_parts-attr.supp-code
          v-purch-code   = buf_parts-attr.purch-code
          v-in-code      = buf_parts-attr.income-in-code
          v-part-code    = buf_parts-attr.part-code
          v-supp-pay-code     = buf_parts-attr.pay-code
          .
        end.
        else do:
          assign
          v-is-attr      = no
          v-supp-VAt-pc  = buf_parts.vat-pc
          v-supp-type    = buf_parts.supp-type
          v-supp-code    = buf_parts.supp-code
          v-purch-code   = buf_parts.purch-code
          v-in-code      = buf_parts.in-code
          v-part-code    = buf_parts.part-code
          v-supp-pay-code = buf_parts.pay-code
          .
        end.
        find first sj-parts where
                  sj-parts.gds-code = buf_goods.gds-code
              AND sj-parts.doc-code = p-doc-code
              AND sj-parts.in-code = v-in-code
              AND sj-parts.part-code = v-part-code no-error .
        if not available sj-parts then do:
          create sj-parts.
          assign
          sj-parts.gds-code          = buf_goods.gds-code
          sj-parts.doc-code          = p-doc-code
          sj-parts.supp-VAt-pc       = v-supp-VAt-pc
          sj-parts.supp-type         = v-supp-type
          sj-parts.supp-code         = v-supp-code
          sj-parts.supp-purch-code   = v-purch-code
          sj-parts.in-code           = v-in-code
          sj-parts.part-code         = v-part-code
          sj-parts.supp-pay-code     = v-supp-pay-code
          .
        end.
        assign
        cur-quant = buf_parts.qnty
        sj-parts.qnty = sj-parts.qnty + cur-quant
        sj-parts.uchet-with-vat-sum = sj-parts.uchet-with-vat-sum + price-rubl-with-tax-loc * cur-quant
        sj-parts.uchet-with-vat-price = sj-parts.uchet-with-vat-sum / sj-parts.qnty
        sj-parts.supp-vat-sum = sj-parts.supp-vat-sum + vat-rubl-loc * cur-quant
        sj-parts.supp-vat-price = sj-parts.supp-vat-sum / sj-parts.qnty
        .
      end.
      FOR EACH buf_gds-dtl no-LOCK WHERE
              buf_gds-dtl.doc-code = p-doc-code
          AND buf_gds-dtl.artic = buf_doc-line.artic
          AND buf_gds-dtl.prod-type = buf_doc-line.prod-type
          AND buf_gds-dtl.prod-code = buf_doc-line.prod-code:

        FIND FIRST buf_bar-code No-LOCK WHERE
                  buf_bar-code.gds-code = buf_goods.gds-code
              AND buf_bar-code.in-code = ""
              AND buf_bar-code.unit-cli = buf_goods.unit-base
              AND buf_bar-code.part-code = ""
              AND buf_bar-code.node-code = buf_gds-dtl.prt-code   NO-ERROR.

        find first buf_gds-prt no-lock where
                  buf_gds-prt.node-code = buf_bar-code.node-code no-error.

        { gbl/bcodeprc.i
          buf_trn-doc.obj-type
          buf_trn-doc.obj-code
          buf_bar-code.b-code
          v-root-b-code
          buf_trn-doc.fact-order
          v-doc-num
          v-price-sale
          v-road-tax
          v-excise
          no-error }
        if error-status:error then do:
          message
          vss-workfile vss-revision vss-description skip
          "Не найден продажная цена товара" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
          "на дату" buf_trn-doc.fact-date
          view-as alert-box error .
          return error.
        end.
        FIND FIRST sj-gds-dtl WHERE
                  sj-gds-dtl.b-code = ub.bar-code.b-code
              AND sj-gds-dtl.doc-code = p-doc-code NO-ERROR .

        if NOT available sj-gds-dtl then do:
          CREATE sj-gds-dtl.
          assign
          sj-gds-dtl.gds-code   = buf_goods.gds-code
          sj-gds-dtl.b-code   = buf_bar-code.b-code
          sj-gds-dtl.prt-code = buf_bar-code.node-code
          sj-gds-dtl.doc-code = p-doc-code
          sj-gds-dtl.VAT-pc   = buf_doc-line.VAT-pc
          .
        end.
        { str/out-vatp.i calc-buf_gds-dtl buf_doc-line. buf_trn-doc. buf_gds-dtl. }
        assign
        cur-quant = buf_gds-dtl.fact-qnty
        vat-cost = vat-rubl-sale * cur-quant
        vat-cost = if buf_gds-dtl.fact-qnty = 0 then 0 else vat-cost
        sj-gds-dtl.qnty           = sj-gds-dtl.qnty + cur-quant
        sj-gds-dtl.doc-sum        = sj-gds-dtl.doc-sum + ( cur-quant * buf_gds-dtl.price-rubl )
        sj-gds-dtl.doc-price      = sj-gds-dtl.doc-sum  / cur-quant
        sj-gds-dtl.doc-discnt-sum = sj-gds-dtl.doc-discnt-sum + ( buf_gds-dtl.discnt-rubl * cur-quant )
        sj-gds-dtl.doc-discnt     = sj-gds-dtl.doc-discnt-sum / cur-quant
        sj-gds-dtl.VAT-sum        = sj-gds-dtl.VAT-sum + vat-cost
        sj-gds-dtl.VAT-price      = sj-gds-dtl.VAT-sum / cur-quant
        sj-gds-dtl.sale-price     = v-price-sale
        sj-gds-dtl.sale-sum       = sj-gds-dtl.sale-sum + (v-price-sale * cur-quant)
        sj-gds-dtl.sale-price-pr  = sj-gds-dtl.sale-sum / cur-quant
        .
      END. /*FOR EACH buf_gds-dtl*/
      /*совместим матрицы*/
      assign
      v-leave-cycle = no
      .
      do while v-leave-cycle = no:
        for each sj-gds-dtl where
                sj-gds-dtl.gds-code = buf_goods.gds-code:
          find first sj-parts where
                    sj-parts.gds-code = sj-gds-dtl.gds-code no-error .
          if not available sj-parts then do:
            for each sj-goods:
              delete sj-goods.
            end.
            for each sj-parts:
              delete sj-parts.
            end.
            for each buf_sj-gds-dtl:
              delete buf_sj-gds-dtl.
            end.
            return.
          end.
          create sj-goods.
          buffer-copy sj-gds-dtl except qnty to sj-goods.
          buffer-copy sj-parts except qnty to sj-goods.
          assign
          sj-goods.qnty = min(sj-gds-dtl.qnty, sj-parts.qnty)

          sj-goods.doc-sum        = sj-goods.doc-price * sj-goods.qnty
          sj-goods.doc-discnt-sum = sj-goods.doc-discnt * sj-goods.qnty
          sj-goods.vat-sum        = sj-goods.vat-price * sj-goods.qnty
          sj-goods.uchet-with-vat-sum = sj-goods.uchet-with-vat-price * sj-goods.qnty
          sj-goods.supp-vat-sum   = sj-goods.supp-vat-price * sj-goods.qnty
          sj-goods.sale-sum       = sj-goods.sale-price-pr * sj-goods.qnty
          .
          if sj-gds-dtl.qnty = sj-parts.qnty then do:
            v-leave-cycle = yes.
            delete sj-parts.
            delete  sj-gds-dtl.
          end.
          else do:
            if sj-gds-dtl.qnty > sj-parts.qnty then do:
              assign
              sj-gds-dtl.qnty  = sj-gds-dtl.qnty - sj-parts.qnty
              .
              delete sj-parts.
            end.
            else do:
              assign
              sj-parts.qnty = sj-parts.qnty - sj-gds-dtl.qnty
              v-leave-cycle = yes
              .
              delete sj-gds-dtl.
            end.
          end.
        end.
      end. /*cycle*/
      for each sj-goods :
        find first buf_sup_clients no-lock where
                   buf_sup_clients.obj-type = sj-goods.supp-type
              AND buf_sup_clients.obj-code = sj-goods.supp-code no-error .
        find first buf_gds-prt no-lock where
                  buf_gds-prt.node-code = sj-goods.prt-code no-error.

        Put Stream PrnLibStream Unformatted
        entry(lookup(buf_trn-doc.ext-doc-type, {&TDEDT_List}), {&TDEDT_List-full})  p-XL-delim
        p-doc-code     p-XL-delim
        (obj-list.obj-type + string(obj-list.obj-code)) p-XL-delim
        string(buf_trn-doc.doc-date, "99/99/9999") p-XL-delim
        string(buf_trn-doc.fact-date, "99/99/9999") p-XL-delim
        string(buf_trn-doc.cli-type + string(buf_trn-doc.cli-code)) p-XL-delim
        buf_trn-doc.pay-code p-XL-delim

        buf_goods.gds-code p-XL-delim
        sj-goods.b-code p-XL-delim
        buf_goods.gds-name p-XL-delim
        buf_goods.grp-name p-XL-delim
        (if available buf_gds-prt
        then buf_gds-prt.f-name
        else "Неизвестный признак!!!") p-XL-delim
        buf_goods.artic                p-XL-delim
        string(buf_goods.prod-type + string(buf_goods.prod-code))            p-XL-delim
        (if avail buf_clients
        then buf_clients.obj-name
        else string(buf_goods.prod-type  + string( buf_goods.prod-code)))
                                       p-XL-delim
        buf_goods.struct               p-XL-delim
        buf_goods.unit-base            p-XL-delim
        (is-out * sj-goods.qnty)       p-XL-delim

        /*учетная часть*/
        string(sj-goods.supp-type  + string( sj-goods.supp-code))           p-XL-delim
        (if avail buf_sup_clients
        then buf_sup_clients.obj-name
        else string(sj-goods.supp-type  + string( sj-goods.supp-code)))
                                       p-XL-delim
        sj-goods.supp-purch-code       p-XL-delim
        sj-goods.supp-pay-code         p-XL-delim
        sj-goods.in-code               p-XL-delim
        sj-goods.part-code             p-XL-delim
        sj-goods.uchet-with-vat-price  p-XL-delim
        (is-out * sj-goods.uchet-with-vat-sum)
                                       p-XL-delim
        sj-goods.supp-vat-pc           p-XL-delim
        (is-out *
        sj-goods.supp-vat-sum)          p-XL-delim

        /*продажная */
        sj-goods.VAT-pc                p-XL-delim
        (is-out *
        sj-goods.VAT-sum)              p-XL-delim
        sj-goods.sale-price            p-XL-delim
        (is-out *
        sj-goods.sale-sum)              p-XL-delim
        sj-goods.doc-price             p-XL-delim
        (is-out *
        sj-goods.doc-sum)               p-XL-delim
        (is-out *
        sj-goods.doc-discnt-sum)
        skip.

        {&PutExcel}
        entry(lookup(buf_trn-doc.ext-doc-type, {&TDEDT_List}), {&TDEDT_List-full}) {&tabulation}
        p-doc-code     {&tabulation}
        (obj-list.obj-type + string(obj-list.obj-code)) {&tabulation}
        string(buf_trn-doc.doc-date, "99/99/9999") {&tabulation}
        string(buf_trn-doc.fact-date, "99/99/9999") {&tabulation}
        string(buf_trn-doc.cli-type + string(buf_trn-doc.cli-code)) {&tabulation}
        buf_trn-doc.pay-code {&tabulation}

        buf_goods.gds-code {&tabulation}
        sj-goods.b-code {&tabulation}
        buf_goods.gds-name {&tabulation}
        buf_goods.grp-name {&tabulation}
        (if available buf_gds-prt
        then buf_gds-prt.f-name
        else "Неизвестный признак!!!") {&tabulation}
        string(if IsEngFrm(sj-goods.artic)
            then ({&delim-par} + buf_goods.artic)
            else buf_goods.artic) {&tabulation}
        string(buf_goods.prod-type + string(buf_goods.prod-code))            {&tabulation}
        (if avail buf_clients
        then buf_clients.obj-name
        else string(buf_goods.prod-type  + string( buf_goods.prod-code)))
                                       {&tabulation}
        buf_goods.struct               {&tabulation}
        buf_goods.unit-base            {&tabulation}
        (is-out *
        sj-goods.qnty)                  {&tabulation}

        /*учетная часть*/
        string(sj-goods.supp-type  + string( sj-goods.supp-code))           {&tabulation}
        (if avail buf_sup_clients
        then buf_sup_clients.obj-name
        else string(sj-goods.supp-type  + string( sj-goods.supp-code)))
                                        {&tabulation}
        sj-goods.supp-purch-code       {&tabulation}
        sj-goods.supp-pay-code         {&tabulation}
        sj-goods.in-code               {&tabulation}
        sj-goods.part-code             {&tabulation}
        sj-goods.uchet-with-vat-price  {&tabulation}
        (is-out *
        sj-goods.uchet-with-vat-sum)    {&tabulation}
        sj-goods.supp-vat-pc           {&tabulation}
        (is-out *
        sj-goods.supp-vat-sum)          {&tabulation}

        /*продажная */
        sj-goods.VAT-pc                {&tabulation}
        (is-out *
        sj-goods.VAT-sum)               {&tabulation}
        sj-goods.sale-price            {&tabulation}
        (is-out *
        sj-goods.sale-sum)              {&tabulation}
        sj-goods.doc-price             {&tabulation}
        (is-out *
        sj-goods.doc-sum)               {&tabulation}
        (is-out *
        sj-goods.doc-discnt-sum)
        skip.


        delete sj-goods.
      end.
    END. /*FOR EACH buf_doc-line*/
  end.

end procedure. /* cr-sj-goods */