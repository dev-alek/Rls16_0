/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

отчет о налогах по релизации в магазине - кусок

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/20/05
Author: Bakhtadze Natalya
Creation date: 04/20/05

при исправлении tax-mag.i исправить и этот файл если надо
*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

_docline:
FOR EACH ub.doc-line WHERE ub.doc-line.doc-code = doc-num NO-LOCK:
  PROCESS EVENTS.
  jj = jj + 1 .
  if ( jj  modulo 10 ) = 0  then
  run waitfram-show in this-procedure (input ("Обработано строк накладных : " +   string(  jj ) ) ).

  IF good-choice  AND NOT (can-find(FIRST gds-list WHERE
                                    gds-list.artic = ub.doc-line.artic AND
                                    gds-list.prod-type = ub.doc-line.prod-type AND
                                    gds-list.prod-code = ub.doc-line.prod-code)) THEN NEXT.

  run clcprtsl_calc-line in this-procedure (input recid (ub.doc-line)).
  assign
  s-price = 0
  cur-quant = 0
  varsum-dsc-r-b-acc   = 0
  var-qnty                = 0
  .
  find first tt-allsum-line where
             tt-allsum-line.sum-type = {&sum-general} no-error .
  if not available tt-allsum-line then do:
  end.
  else do:
   assign
   varsum-dsc-r-b-acc   = (if v-curr-r-b = {&r-b-rubl} then tt-allsum-line.sum-dsc-rubl-acc else tt-allsum-line.sum-dsc-base-acc)
   var-qnty                = ub.doc-line.fact-qnty
   cur-quant = is-out * ub.doc-line.fact-qnty
   s-price = varsum-dsc-r-b-acc  / var-qnty
   .
  end.

  if NOT offc AND cur-quant = 0 and negparts then next _docline.
  FOR EACH ub.gds-dtl WHERE
          ub.gds-dtl.doc-code = doc-num AND
          ub.gds-dtl.artic = ub.doc-line.artic AND
          ub.gds-dtl.prod-type = ub.doc-line.prod-type AND
          ub.gds-dtl.prod-code = ub.doc-line.prod-code
          NO-LOCK:

    if method = "b-code":U then do:
      FIND FIRST ub.goods No-LOCK WHERE
               ub.goods.artic = ub.gds-dtl.artic AND
                ub.goods.prod-type = ub.gds-dtl.prod-type AND
                ub.goods.prod-code = ub.gds-dtl.prod-code No-ERROR.
      FIND FIRST ub.bar-code WHERE
                ub.bar-code.gds-code = ub.goods.gds-code AND
                ub.bar-code.in-code = "" AND
                ub.bar-code.unit-cli = ub.goods.unit-base AND
                ub.bar-code.part-code = "" AND
                ub.bar-code.node-code = ub.gds-dtl.prt-code
                NO-LOCK   NO-ERROR.
    end.

    assign
    cur-discnt = (if v-curr-r-b = {&r-b-rubl} then ub.gds-dtl.discnt-rubl else ub.gds-dtl.discnt-base)
    .
    CASE method :
      when "b-code":U THEN dO:
        FIND FIRST sj-goods WHERE
                  sj-goods.b-code = ub.bar-code.b-code
              AND sj-goods.is-out = (is-out > 0) NO-ERROR .
      END.
      when "Group" THEN do:
        FIND ub.goods WHERE
            ub.goods.prod-type = ub.doc-line.prod-type AND
            ub.goods.prod-code = ub.doc-line.prod-code AND
            ub.goods.artic = ub.doc-line.artic NO-LOCK .
        FIND FIRST t-3 where
                  ub.goods.grp-name begins t-3.serv-name No-ERROR.
        FIND FIRST sj-goods WHERE
                  sj-goods.grp-code = (if available t-3 then t-3.grp-code-sheet else 0)
              AND sj-goods.is-out = (is-out > 0) NO-ERROR .
      end.
    END CASE.

    if NOT available sj-goods then do:
      CREATE sj-goods.
      CASE method:
        WHEN  "b-code":U then DO:
          FIND ub.goods WHERE
              ub.goods.prod-type = ub.doc-line.prod-type AND
              ub.goods.prod-code = ub.doc-line.prod-code AND
              ub.goods.artic = ub.doc-line.artic NO-LOCK .
          assign
          sj-goods.b-code = ub.bar-code.b-code
          sj-goods.name = ub.goods.gds-name
          sj-goods.artic = ub.goods.artic
          sj-goods.unit  = ub.goods.unit-base
          sj-goods.is-out = (is-out > 0)
          sj-goods.prod-type = ub.goods.prod-type
          sj-goods.prod-code = ub.goods.prod-code
          .
        END.
        WHEN "GROUP":U then do:
          assign
          sj-goods.grp-code = (if available t-3 then t-3.grp-code-sheet else 0)
          sj-goods.is-out = (is-out > 0)
          .
        END.
      END CASE.
    end.
    assign
    cur-quant = is-out * ub.gds-dtl.fact-qnty
    sj-goods.qnty = sj-goods.qnty + cur-quant
    sj-goods.brutto-sum = sj-goods.brutto-sum + ( cur-quant * (if v-curr-r-b = {&r-b-rubl} then ub.gds-dtl.price-rubl else ub.gds-dtl.price-base))
    sj-goods.discnt-sum = sj-goods.discnt-sum + ( cur-discnt * cur-quant )
    sj-goods.netto-sum = sj-goods.brutto-sum -  sj-goods.discnt-sum
    sj-goods.uchet-sum = sj-goods.uchet-sum + s-price * cur-quant
    .
  END. /*FOR EACH GDS-DTL*/
END. /*FOR EACH doc-line*/

/* $Workfile$ e n d */