/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Автор: Хныкин Павел Андреевич
Дата создания: 11/28/05
Author: Pavel Khnykin
Creation date: 11/28/05

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

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
                    gds-str1 @ goods.gds-name
                    sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
                    sym11 sym12 sym13 sym14 sym15 sym16
                with frame f-doc-m .
                down stream out-stream 1 with frame f-doc-m .
            end.        /* v-torgconf-outt12 = yes */
            else do:
                display stream out-stream
                    gds-str1 @ goods.gds-name
                    sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
                    sym11 sym12 sym13 sym14 sym15 sym16 sym17
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
                display stream out-stream
                    "Итого" @ ub.goods.gds-name
                    Pg-tqnty @ tqnty
                    Pg-stoim-noNDS @ stoim-noNDS
                    Pg-VAT-gds  @ VAT-gds
                    Pg-stoim @ stoim
                with frame f-doc .
                down stream out-stream 1 with frame f-doc .
        end.
/* $Workfile$   E n d */