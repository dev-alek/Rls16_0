/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Продажи топлива и сервисного элемента

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

IF NOT chk-doc.office = {&gds-goods}  then NEXT.
if first-of(chk-gds.b-code)  then do:
    FIND FIRST ub.bar-code NO-LOCK WHERE
               ub.bar-code.b-code = ub.chk-gds.b-code No-ERROR.
    FIND FIRST ub.goods No-LOCK WHERE
               ub.goods.gds-code = ub.bar-code.gds-code NO-ERROR.
    FIND FIRST ub.units WHERE
               ub.units.unit-name = ub.goods.unit-base No-LOCK No-ERROR.
    assign
    b-qnty = 0
    b-sum = 0
    b-sum-brutto = 0.
end. /*first chk-gds.b-code*/
assign
b-qnty = b-qnty + ub.chk-gds.doc-qnty
b-sum = b-sum  + ub.chk-gds.doc-qnty * (ub.chk-gds.price-base - ub.chk-gds.discnt)
b-sum-brutto = b-sum-brutto  + ub.chk-gds.doc-qnty * (ub.chk-gds.price-base - ub.chk-gds.discnt + ub.chk-gds.price-service)
.
IF LASt-of(chk-gds.b-code) then do:
        IF me then /*break*/
        FIND FIRST benefits WHERE benefits.b-code = ub.chk-gds.b-code and
                                                        benefits.out-code = ub.chk-gds.out-code and
                                                        benefits.price = ub.chk-gds.price-base No-ERROR.
        else /*no-break*/
        FIND FIRST benefits WHERE benefits.b-code = ub.chk-gds.b-code No-ERROR.

        IF NOT avail benefits then do:
            create benefits.
            assign
            benefits.b-code = ub.chk-gds.b-code
            benefits.gds-name = ub.goods.gds-name
            benefits.artic = ub.goods.artic
            benefits.prod-type = ub.goods.prod-type
            benefits.prod-code = ub.goods.prod-code
            benefits.main_ =  IF LOOKUP({&petrolium}, units.type) > 0 and ub.goods.gds-type = {&gds-office} then no else yes
            benefits.out-code = if me then ub.chk-gds.out-code else ?
            benefits.price = if me then ub.chk-gds.price-base else 0
            benefits.unit-base = ub.goods.unit-base.
        end.
        assign
        benefits.qnty = benefits.qnty  + ub.chk-gds.doc-qnty
        benefits.tot-r-b = benefits.tot-r-b + b-sum
        benefits.tot-r-b-brutto = benefits.tot-r-b-brutto + b-sum-brutto
        .
end. /*last chk-gds.b-code*/

/* $Workfile$ e n d */