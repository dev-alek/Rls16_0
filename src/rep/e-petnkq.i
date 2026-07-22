/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Расход нефтепродуктов по документам

Автор: Суслов Алексей Юрьевич
Дата создания: 03/27/06
Author: Alexey Suslov
Creation date: 03/27/06

*/

           FOR EACH ub.doc-pl No-LOCK where ub.doc-pl.out-code = ub.trn-doc.doc-code,
                FIRST ub.goods No-LOCK WHERE ub.goods.gds-code = ub.doc-pl.gds-code,
                FIRST ub.gds-dtl No-LOCK WHERE ub.gds-dtl.doc-code = ub.trn-doc.doc-code AND
                                                                    ub.gds-dtl.artic = ub.goods.artic AND
                                                                    ub.gds-dtl.prod-type = ub.goods.prod-type AND
                                                                    ub.gds-dtl.prod-code = ub.goods.prod-code:
                if HOWBREAK then do:
                    FIND FIRST tops WHERE tops.gds-code = ub.goods.gds-code AND
                                                              tops.obj-type = ub.trn-doc.obj-type AND
                                                              tops.obj-code = ub.trn-doc.obj-code AND
                                                              tops.shift-num = ub.trn-doc.shift-num AND
                                                              tops.sale-date = ub.trn-doc.fact-date AND
                                                              tops.doc-code  = ub.doc-pl.out-code AND
                                                              tops.pl-code = ub.doc-pl.pl-code No-ERROR.
                END.
                ELSE do:
                    FIND FIRST tops WHERE tops.gds-code = ub.goods.gds-code AND
                                                              tops.obj-type = "" AND
                                                              tops.obj-code = 0 AND
                                                              tops.shift-num = ub.trn-doc.shift-num AND
                                                              tops.sale-date = ub.trn-doc.doc-date AND
                                                              tops.pl-code = 0 No-ERROR.
                END.
                   IF NOT AVAIL tops then do:
                        create tops.
                        assign
                        tops.gds-code = ub.doc-pl.gds-code
                        tops.gds-name = ub.goods.gds-name
                        tops.obj-type = if HowBreak then ub.trn-doc.obj-type else ""
                        tops.obj-code = if HowBreak then ub.trn-doc.obj-code else 0
                        tops.shift-num = ub.trn-doc.shift-num
                        tops.shift-name = ub.trn-doc.shift-name
                        tops.sale-date = ub.trn-doc.doc-date
                        tops.doc-code = if HowBreak then  ub.trn-doc.doc-code else ""
                        tops.doc-type = if HowBreak
                                                  then (if dt = ""
                                                           then ub.trn-doc.doc-type
                                                           else dt)
                                                  else ""
                        tops.pl-code = if HowBreak then ub.doc-pl.pl-code else 0
                        .

                   END.
                   assign
                   tops.qnty = tops.qnty + {1} * ub.doc-pl.fact-qnty
                   tops.tot-r-b = tops.tot-r-b +
                                  (if v-curr-r-b = {&r-b-base}
                                   then ub.gds-dtl.price-base
                                   else ub.gds-dtl.price-rubl ) * {1} * ub.doc-pl.fact-qnty
                   tops.discnt-r-b = tops.discnt-r-b +
                                  (if v-curr-r-b = {&r-b-base}
                                   then ub.gds-dtl.discnt-base
                                   else ub.gds-dtl.discnt-rubl ) *  {1} * ub.doc-pl.fact-qnty
                   .
        END. /*FOR EACH doc-pl No-LOCK where doc-pl.out-code = trn-doc.out-code*/

/* $Workfile$ e n d */