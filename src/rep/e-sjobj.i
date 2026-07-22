/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

журнал продаж

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/05/06
Author: Bakhtadze Natalya
Creation date: 04/05/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

    if last-of( sj-goods.obj-attr ) AND ( ObjsQnty > 1 ) then do:
            CASE my-set_val_type :
                when {&v-base} then do:
                        UNDERLINE STREAM PrnLibStream
                        sj-goods.name
                        sj-adv.qnty
&if "{1}" = "-t" &then
                        sj-adv.qnty-2
                        sj-adv.qnty-3
&endif
                        sj-adv.brutto-sum
                        sj-adv.discnt-sum
                        pcnt
                        sj-adv.netto-sum
                        with FRAME sj-base{1} .
                        DISPLAY STREAM PrnLibStream
                        string( "Итого " + sj-goods.obj-attr )
                            @ sj-goods.name
                        ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.qnty    @ sj-adv.qnty
&if "{1}" = "-t" &then
                        ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.qnty-2    @ sj-adv.qnty-2
                        ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.qnty-3    @ sj-adv.qnty-3
&endif
                        ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.brutto-sum
                            @ sj-adv.brutto-sum
                        ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.discnt-sum
                            @ sj-adv.discnt-sum
                        round( ( ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.discnt-sum ) /
                            ( ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.brutto-sum ) * 100 , 1 )
                            @ pcnt
                        ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.netto-sum
                            @ sj-adv.netto-sum
                        with FRAME sj-base{1} .
                        DOWN STREAM PrnLibStream 1 with FRAME sj-base{1} .
                    end.
                when {&v-all} then do:
                        UNDERLINE STREAM PrnLibStream
                        sj-goods.name
                        sj-adv.qnty
&if "{1}" = "-t" &then
                        sj-adv.qnty-2
                        sj-adv.qnty-3
&endif
                        sj-adv.brutto-sum
                        sj-adv.brutto-sum-r
                        sj-adv.discnt-sum
                        pcnt
                        sj-adv.netto-sum
                        sj-adv.netto-sum-r
                        with FRAME sj-full{1} .
                        DISPLAY STREAM PrnLibStream
                        string( "Итого " + sj-goods.obj-attr )
                            @ sj-goods.name
                        ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.qnty    @ sj-adv.qnty
&if "{1}" = "-t" &then
                        ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.qnty-2    @ sj-adv.qnty-2
                        ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.qnty-3    @ sj-adv.qnty-3
&endif
                        ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.brutto-sum  @ sj-adv.brutto-sum
                        ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.brutto-sum-r @ sj-adv.brutto-sum-r
                        ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.discnt-sum      @ sj-adv.discnt-sum
                        round( ( ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.discnt-sum ) /
                                    ( ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.brutto-sum) * 100 , 1 )
                                        @ pcnt
                        ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.netto-sum   @ sj-adv.netto-sum
                        ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.netto-sum-r @ sj-adv.netto-sum-r
                        with FRAME sj-full{1} .
                        DOWN STREAM PrnLibStream 1 with FRAME sj-full{1} .
                    end.
            END CASE .
            if NOT last(  sj-adv.price ) then
                CASE my-set_val_type :
                    when {&v-base} then
                        UNDERLINE STREAM PrnLibStream
                        sj-goods.name
                        sj-adv.qnty
&if "{1}" = "-t" &then
                        sj-adv.qnty-2
                        sj-adv.qnty-3
&endif
                        sj-adv.brutto-sum
                        sj-adv.discnt-sum
                        pcnt
                        sj-adv.netto-sum
                        with FRAME sj-base{1} .
                    when {&v-all} then
                        UNDERLINE STREAM PrnLibStream
                        sj-goods.name
                        sj-adv.qnty
&if "{1}" = "-t" &then
                        sj-adv.qnty-2
                        sj-adv.qnty-3
&endif
                        sj-adv.brutto-sum
                        sj-adv.brutto-sum-r
                        sj-adv.discnt-sum
                        pcnt
                        sj-adv.netto-sum
                        sj-adv.netto-sum-r
                        with FRAME sj-full{1} .
                END CASE .
            OneLinePrinted = TRUE .
        end.

/* $Workfile$ e n d */