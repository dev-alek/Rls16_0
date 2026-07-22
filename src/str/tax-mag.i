/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

отчет о налогах по релизации в магазине - кусок

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/13/06
Author: Bakhtadze Natalya
Creation date: 01/13/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable p-grp-code as integer.
define variable p-grp-name as char.
define variable v-curr-grp-name as character.
_docline:
FOR EACH doc-line WHERE doc-line.doc-code = doc-num NO-LOCK:
  PROCESS EVENTS.
  jj = jj + 1 .
  if ( jj  modulo 10 ) = 0  then
  run waitfram-show in this-procedure (input ("Обработано строк накладных : " +   string(  jj ) ) ).

    /*  IF good-choice  AND NOT (can-find(FIRST gds-list WHERE                                */
    /*                                    gds-list.artic = doc-line.artic AND                 */
    /*                                    gds-list.prod-type = doc-line.prod-type AND         */
    /*                                    gds-list.prod-code = doc-line.prod-code)) THEN NEXT.*/



find first goods where goods.prod-type = doc-line.prod-type and
           goods.prod-code = doc-line.prod-code and 
            goods.artic = doc-line.artic .
            p-grp-code = goods.grp-code.
            p-grp-name = goods.grp-name.
         
/*       find first gds-grp where                                                                                                          */
/*                       ub.goods.grp-code = gds-grp.node-code  no-error.                                                                  */
/*                                                                                                                                         */
/*            message p-grp-code p-grp-name "!!!!!!!!!" gds-grp.node-code "nmtmp" gds-grp.node-name   gds-grp.upper-code view-as alert-box.*/
          
         
    case x-SelectGood:  
        when {&g-one} 
        then 
            do:
                find  first gds-list no-lock
                    where gds-list.artic     = goods.artic
                    and gds-list.prod-type = goods.prod-type
                    and gds-list.prod-code = goods.prod-code
                    no-error .
                if not available gds-list then next.
            end.
        when {&g-all}  then 
            do: /* все товары */
            end.
        when {&g-grp} then 
            do:
           find first tmp#grp where
                         ub.goods.grp-name begins tmp#grp.grp-name no-error.
                if not avail tmp#grp then NEXT.
                
/*                find first  gds-grp where                                                         */
/*                    ub.goods.grp-code = gds-grp.node-code  no-error.                              */
/*                                                                                                  */
/*                                                                                                  */
/*                                                                                                  */
/*                find   first tmp#grp no-lock where                                                */
/*                    (tmp#grp.node-code = gds-grp.upper-code or tmp#grp.node-code = goods.grp-code)*/
/*                    no-error.                                                                     */
/*                                                                                                  */
/*                     if not available tmp#grp then next.                                          */
            end.
        otherwise 
        do:     /*список товаров*/
            find  first gds-list no-lock
                where goods.artic     = gds-list.artic
                and goods.prod-type = gds-list.prod-type
                and goods.prod-code = gds-list.prod-code no-error .
            if not available  gds-list then next.
                
        end.
    end case.
    

  run clcprtsl_calc-line in this-procedure (input recid (doc-line)).
  assign
  s-price = 0
  cur-quant = 0
  varsum-dsc-r-b-acc   = 0
  varvat-r-b-acc       = 0
  var-qnty                = 0
  varvat-r-b-doc       = 0
  varslt-r-b-doc       = 0
  .
  find first tt-allsum-line where
             tt-allsum-line.sum-type = {&sum-general} no-error .
  if not available tt-allsum-line then do:
  end.
  else do:
   assign
   varsum-dsc-r-b-acc   = (if v-curr-r-b = {&r-b-rubl} then tt-allsum-line.sum-dsc-rubl-acc else tt-allsum-line.sum-dsc-base-acc)
   varvat-r-b-acc       = (if v-curr-r-b = {&r-b-rubl} then tt-allsum-line.vat-rubl-acc else tt-allsum-line.vat-base-acc)
   var-qnty                = doc-line.fact-qnty
   varvat-r-b-doc       = (if v-curr-r-b = {&r-b-rubl} then tt-allsum-line.vat-rubl-doc else tt-allsum-line.vat-base-doc)
   varslt-r-b-doc       = (if v-curr-r-b = {&r-b-rubl} then tt-allsum-line.slt-rubl-doc else tt-allsum-line.slt-rubl-doc)
   cur-quant = is-out * doc-line.fact-qnty
   s-price = ( varsum-dsc-r-b-acc - varvat-r-b-acc ) / var-qnty
   .
  end.

  if NOT offc AND cur-quant = 0 and negparts then next _docline.
  FOR EACH gds-dtl WHERE
          gds-dtl.doc-code = doc-num AND
          gds-dtl.artic = doc-line.artic AND
          gds-dtl.prod-type = doc-line.prod-type AND
          gds-dtl.prod-code = doc-line.prod-code
          NO-LOCK:

    if method = "b-code":U then do:
      FIND FIRST goods No-LOCK WHERE
                goods.artic = gds-dtl.artic AND
                goods.prod-type = gds-dtl.prod-type AND
                goods.prod-code = gds-dtl.prod-code No-ERROR.
      FIND FIRST bar-code WHERE
                bar-code.gds-code = goods.gds-code AND
                bar-code.in-code = "" AND
                bar-code.unit-cli = goods.unit-base AND
                bar-code.part-code = "" AND
                bar-code.node-code = gds-dtl.prt-code
                NO-LOCK   NO-ERROR.
    end.

    assign
    cur-discnt = (if v-curr-r-b = {&r-b-rubl} then gds-dtl.discnt-rubl else gds-dtl.discnt-base)
    .
    

    CASE method :
      when "b-code":U THEN dO:
        FIND FIRST sj-goods WHERE
                  sj-goods.b-code = bar-code.b-code AND
                  sj-goods.VAT-pc = doc-line.VAT-pc AND
                  sj-goods.SLT-pc = doc-line.SLT-pc AND
                  sj-goods.is-out = (is-out > 0) NO-ERROR .
      END.
      when "artic":U THEN DO:
        FIND FIRST sj-goods WHERE
                  sj-goods.artic = doc-line.artic AND
                  sj-goods.prod-type = doc-line.prod-type AND
                  sj-goods.prod-code = doc-line.prod-code AND
                  sj-goods.VAT-pc = doc-line.VAT-pc AND
                  sj-goods.SLT-pc = doc-line.SLT-pc AND
                  sj-goods.is-out = (is-out > 0) USE-INDEX p3 NO-ERROR .
      END.
      otherwise do:
        FIND FIRST sj-goods WHERE
                  sj-goods.VAT-pc = doc-line.VAT-pc AND
                  sj-goods.SLT-pc = doc-line.SLT-pc AND
                  sj-goods.is-out = (is-out > 0) NO-ERROR .
      end.
    END CASE.

    if NOT available sj-goods then do:
      FIND goods WHERE
          goods.prod-type = doc-line.prod-type AND
          goods.prod-code = doc-line.prod-code AND
          goods.artic = doc-line.artic NO-LOCK .
      if method = "artic":U then do:
        /*найдем самый основной корневой бар-код*/
        { gbl/gdsbcode.i goods.gds-code ? r-bar-code no-error }
        if error-status:error then NEXT _docline.
      end.
      CREATE sj-goods.
      CASE method:
        WHEN  "b-code":U then DO:
          assign
          sj-goods.b-code = bar-code.b-code
          sj-goods.name = goods.gds-name
          sj-goods.artic = goods.artic
          sj-goods.VAT-pc = doc-line.VAT-pc
          sj-goods.SLT-pc = doc-line.SLT-pc
          sj-goods.unit  = goods.unit-base
          sj-goods.is-out = (is-out > 0)
            .
        END.
        WHEN "artic":U then do:
          assign
          sj-goods.b-code = r-bar-code
          sj-goods.name = goods.gds-name
          sj-goods.artic = goods.artic
          sj-goods.prod-type = goods.prod-type
          sj-goods.prod-code = goods.prod-code
          sj-goods.VAT-pc = doc-line.VAT-pc
          sj-goods.SLT-pc = doc-line.SLT-pc
          sj-goods.unit  = goods.unit-base
          sj-goods.is-out = (is-out > 0)
            .
        END.
        WHEN "TOTALS":U then do:
          assign
          sj-goods.VAT-pc = doc-line.VAT-pc
          sj-goods.SLT-pc = doc-line.SLT-pc
          sj-goods.is-out = (is-out > 0)
          .
        END.
      END CASE.
    &if "{1}" = "grp" &then
      sj-goods.grp-code = ub.goods.grp-code.
      sj-goods.grp-name = ub.goods.grp-name.
    &endif
    end.
    { str/out-vatp.i calc-gds-dtl doc-line. t-doc. gds-dtl. }
    assign
    cur-quant = is-out * gds-dtl.fact-qnty
    slt-calc = (if v-curr-r-b = {&r-b-rubl} then slt-rubl-sale else slt-base-sale) * cur-quant
    vat-cost = (if v-curr-r-b = {&r-b-rubl} then vat-rubl-sale else vat-base-sale) * cur-quant
    slt-calc = if gds-dtl.fact-qnty = 0 then 0 else slt-calc
    vat-cost = if gds-dtl.fact-qnty = 0 then 0 else vat-cost
    sj-goods.qnty = sj-goods.qnty + cur-quant
    sj-goods.brutto-sum = sj-goods.brutto-sum + ( cur-quant * (if v-curr-r-b = {&r-b-rubl} then gds-dtl.price-rubl else gds-dtl.price-base))
    sj-goods.discnt-sum = sj-goods.discnt-sum + ( cur-discnt * cur-quant )
    sj-goods.uchet-with-vat-sum = sj-goods.uchet-with-vat-sum + (if var-qnty = 0
                                                                 then 0
                                                                 else (varsum-dsc-r-b-acc / var-qnty) * cur-quant)
    sj-goods.uchet-sum = sj-goods.uchet-sum + s-price * cur-quant
    sj-goods.SLT-r-b = sj-goods.SLT-r-b + slt-calc
    sj-goods.VAT-r-b = sj-goods.VAT-r-b + vat-cost
    .
  END. /*FOR EACH GDS-DTL*/
END. /*FOR EACH doc-line*/

/* $Workfile$ e n d */