/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Понедельный отчет по товарам (реализация)

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

   FOR EACH ub.doc-line WHERE ub.doc-line.doc-code = doc-num NO-LOCK,
            EACH ub.gds-dtl WHERE ub.gds-dtl.doc-code = doc-num AND
                                                ub.gds-dtl.artic = ub.doc-line.artic AND
                                                ub.gds-dtl.prod-type = ub.doc-line.prod-type AND
                                                ub.gds-dtl.prod-code = ub.doc-line.prod-code
                                                NO-LOCK:
        PROCESS EVENTS.
        jj = jj + 1 .
        if ( jj  modulo 10 ) = 0  then
            run waitfram-show in this-procedure (input ( "Обработано строк накладных : " +
                                        string(  jj ) ) ).

           IF X-SelectGood = {&g-choice}  AND NOT (can-find(FIRST gds-list WHERE
                                             gds-list.artic = ub.doc-line.artic AND
                                             gds-list.prod-type = ub.doc-line.prod-type AND
                                             gds-list.prod-code = ub.doc-line.prod-code)) THEN NEXT.

        assign
        s-price = (if v-curr-r-b = {&r-b-rubl} then ub.gds-dtl.price-rubl else ub.gds-dtl.price-base)
        cur-discnt = (if v-curr-r-b = {&r-b-rubl} then  ub.gds-dtl.discnt-rubl else ub.gds-dtl.discnt-base)
        cur-quant = is-out * ub.gds-dtl.doc-qnty.
        IF RS-method = "artic":U THEN
        FIND FIRST sj-goods WHERE
                            sj-goods.artic = ub.doc-line.artic AND
                            sj-goods.prod-type = ub.doc-line.prod-type AND
                            sj-goods.prod-code = ub.doc-line.prod-code AND
                            sj-goods.date_ = doc-date NO-ERROR .
        ELSE
        FIND FIRST sj-goods WHERE
                            sj-goods.date_ = doc-date
                                               NO-ERROR .

        if NOT available sj-goods then
            do:
                CREATE sj-goods.
                CASE RS-method:
                    WHEN "artic":U then do:
                        assign
                        sj-goods.date_ = doc-date
                        sj-goods.weekn = TRUNCATE(decimal(sj-goods.date_ - my-X-date-Start) / 7 , 0)
                        sj-goods.artic = ub.doc-line.artic
                        sj-goods.prod-type = ub.doc-line.prod-type
                        sj-goods.prod-code = ub.doc-line.prod-code.
                    end.
                    WHEN "TOTALS":U then
                        assign
                        sj-goods.date_ = doc-date
                        sj-goods.weekn = TRUNCATE(decimal(sj-goods.date_ - my-X-date-Start) /  7 , 0)
                        .
              END CASE.

            end.
            assign
            sj-goods.qnty = sj-goods.qnty + cur-quant
            sj-goods.brutto-sum = sj-goods.brutto-sum + ( cur-quant * s-price )
            sj-goods.discnt-sum = sj-goods.discnt-sum + ( cur-discnt * cur-quant )
            sj-goods.uchet-sum = sj-goods.uchet-sum +
                                 (if v-curr-r-b = {&r-b-rubl}
                                 then ub.doc-line.price-rubl
                                 else ub.doc-line.price-base) * cur-quant
            .
        END. /*FOR EACH doc-line*/


/* $Workfile$ e n d */