/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Расход нефтепродуктов через ТРК

Автор: Суслов Алексей Юрьевич
Дата создания: 03/27/06
Author: Alexey Suslov
Creation date: 03/27/06

*/
           FOR EACH ub.doc-pl-pump No-LOCK where ub.doc-pl-pump.out-code = {1},
                FIRST ub.goods No-LOCK WHERE ub.goods.gds-code = ub.doc-pl-pump.gds-code,
                FIRST ub.gds-dtl No-LOCK WHERE ub.gds-dtl.doc-code = {1} AND
                                                                    ub.gds-dtl.artic = ub.goods.artic AND
                                                                    ub.gds-dtl.prod-type = ub.goods.prod-type AND
                                                                    ub.gds-dtl.prod-code = ub.goods.prod-code:
                if HOWBREAK then do:
                    FIND FIRST tops WHERE tops.gds-code = ub.goods.gds-code AND
                                                              tops.obj-type = ub.inkas.obj-type AND
                                                              tops.obj-code = ub.inkas.obj-code AND
                                                              tops.shift-num = ub.inkas.shift-num AND
                                                              tops.sale-date = ub.inkas.doc-date AND
                                                              tops.pump-code  = ub.doc-pl-pump.pump-code AND
                                                              tops.pl-code = ub.doc-pl-pump.pl-code No-ERROR.
                END.
                ELSE do:
                    FIND FIRST tops WHERE tops.gds-code = goods.gds-code AND
                                                              tops.obj-type = "" AND
                                                              tops.obj-code = 0 AND
                                                              tops.shift-num = ub.inkas.shift-num AND
                                                              tops.sale-date = ub.inkas.doc-date AND
                                                              tops.pump-code  = 0 AND
                                                              tops.pl-code = 0 No-ERROR.
                END.
                   IF NOT AVAIL tops then do:
                        create tops.
                        assign
                        tops.gds-code = ub.doc-pl-pump.gds-code
                        tops.gds-name = ub.goods.gds-name
                        tops.obj-type = if HowBreak then ub.inkas.obj-type else ""
                        tops.obj-code = if HowBreak then ub.inkas.obj-code else 0
                        tops.shift-num = ub.inkas.shift-num
                        tops.shift-name = ub.inkas.shift-name
                        tops.sale-date = ub.inkas.doc-date
                        tops.pump-code = if HowBreak then ub.doc-pl-pump.pump-code else 0
                        tops.pl-code = if HowBreak then ub.doc-pl-pump.pl-code else 0
                        .

                   END.
                   assign
                   tops.qnty = tops.qnty + {2} * ub.doc-pl-pump.fact-qnty
                   tops.tot-r-b = tops.tot-r-b +
                                  (if v-curr-r-b = {&r-b-base}
                                   then ub.gds-dtl.price-base
                                   else ub.gds-dtl.price-rubl ) * {2} * ub.doc-pl-pump.fact-qnty
                   tops.discnt-r-b = tops.discnt-r-b +
                                  (if v-curr-r-b = {&r-b-base}
                                   then ub.gds-dtl.discnt-base
                                   else ub.gds-dtl.discnt-rubl ) * {2} * ub.doc-pl-pump.fact-qnty
                   .
        END. /*FOR EACH doc-pl-pump No-LOCK where doc-pl-pump.out-code = trn-doc.out-code*/

/* $Workfile$ e n d */