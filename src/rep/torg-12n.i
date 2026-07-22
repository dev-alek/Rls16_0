/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Формы для Торг-12n

Автор: Демин Алексей Сергеевич
Дата создания: 04/12/06
Author: Alexey Demin
Creation date: 04/12/06

Required:

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

&if "{2}" <> "" &then
    if FullGdsName
    then do:
        do while gds-str2 <> ""
        :
            assign
                gds-str = gds-str2
                gds-str1 = breakstr(gds-str, {2}, input-output gds-str1, input-output gds-str2)
            .
            if v-torgconf-outt12 = yes
            then do:
                display stream out-stream
                    gds-str1 @ ub.goods.gds-name
                    sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
                    sym11 sym12 sym13 sym14 sym15 sym16
                    &if "{3}" <> "torg-12z" &then
                        sym19
                    &endif
                with frame f-doc-m .
                down stream out-stream 1 with frame f-doc-m .
            end.        /* v-torgconf-outt12 = yes */
            else do:
                display stream out-stream
                    gds-str1 @ ub.goods.gds-name
                    sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
                    sym11 sym12 sym13 sym14 sym15 sym16 sym17 sym18
                    &if "{3}" <> "torg-12z" &then
                        sym19
                    &endif
                with frame f-doc .
                down stream out-stream 1 with frame f-doc .
            end.        /* NOT ( v-torgconf-outt12 = yes ) */
        end. /* do while ... */
    end.
&endif

if page-number( out-stream ) > prevpage then
    assign
        Pg-tqnty = 0
        Pg-VAT-gds = 0
        Pg-SLT-gds = 0
        Pg-stoim-noNDS = 0
        Pg-stoim = 0
        .

&if "{1}" <> "itog" &then
    &if "{1}" <> "no-sum" &then
        assign
            PrevPage = page-number( Out-Stream )
            Pg-tqnty = Pg-tqnty + {1}tqnty
            Pg-VAT-gds = Pg-VAT-gds + {1}VAT-gds
            Pg-SLT-gds = Pg-SLT-gds + {1}SLT-gds
            Pg-stoim-noNDS = Pg-stoim-noNDS + {1}stoim-noNDS
            Pg-stoim = Pg-stoim + {1}stoim
            .
    &endif
    if line-counter( Out-Stream ) + 1 > page-size( Out-Stream ) then
&endif
        do:
            put stream out-stream v-single-line format "x(198)" skip.
            if v-torgconf-outt12 = yes
            then do:
                display stream out-stream
                    "Итого" @ ub.goods.gds-name
                    Pg-tqnty @ tqnty
                    Pg-stoim-noNDS @ stoim-noNDS
                    Pg-VAT-gds  @ VAT-gds
                    Pg-stoim @ stoim
                with frame f-doc-m .
                down stream out-stream 1 with frame f-doc-m .
            end.        /* v-torgconf-outt12 = yes */
            else do:
                display stream out-stream
                    "Итого" @ ub.goods.gds-name
                    Pg-tqnty @ tqnty
                    Pg-stoim-noNDS @ stoim-noNDS
                    Pg-VAT-gds  @ VAT-gds
                    Pg-stoim @ stoim
                    Pg-SLT-gds  @ SLT-gds
                with frame f-doc .
                down stream out-stream 1 with frame f-doc .
            end.        /* NOT ( v-torgconf-outt12 = yes ) */
        end.

/* $Workfile$ e n d */