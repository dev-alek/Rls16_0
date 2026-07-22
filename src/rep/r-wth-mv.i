/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$


Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/09/05
Author: Bakhtadze Natalya
Creation date: 09/09/05

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

/*---S----- При первом появлении мат. ценности выводим остатки на начало ------ */
if first-of (wealth.wth-code)
then do:
    if not first(wealth.wth-code)
    then put stream PrnLibStream
        skip
          "|" at {&P-S}
          v-single-line format "X({&P-X0})"
          "|"
    .
    if x-radio-task <> 4 or x-date-start = x-date-end
    then do:
        DISPLAY STREAM PrnLibStream
                wealth.wth-name @ v-wth-name
                sym1 sym2 sym3 sym4 sym5 sym6 sym7
                with frame f-wth
        .
        down stream PrnLibStream 1 with frame f-wth .

        for each buf_wth-place
          where buf_wth-place.host-code = buf_wth-doc.host-code
            and buf_wth-place.obj-type  = buf_wth-doc.obj-type
            and buf_wth-place.obj-code  = buf_wth-doc.obj-code
        :
    &if "{1}" = "1" &then
            run wth-lib_full-inf-calend-date-place(
    &endif
    &if "{1}" = "2" &then
            run wth-lib_full-inf-shift-date-place(
    &endif
    &if "{1}" = "3" or "{1}" = "4" &then
            run wth-lib_full-inf-shift-place(
    &endif
                                    input  buf_clients.obj-type
                                  , input  buf_clients.obj-code
                                  , input  buf_wth-line.wth-code
                                  , input  buf_wth-place.w-p-code
                                  , input  x-date-start
&if "{1}" = "3" or "{1}" = "4" &then
                                  , input  x-shift-start
&endif
                                  , output parstock-start
                                  , output parstock-end
                                  , output parincome
                                  , output parincome-cassa
                                  , output parincome-other
                                  , output parincass
                                  , output parincass-bank
                                  , output parincass-other
                                  , output parincass-cassa
            ).
/*                                                                            if index(wealth.wth-name, "{&abbr_rubli}") <> 0*/
/*                                                                            then do:*/
/*                                                                                message*/
/*                                                                                    "Место: " buf_wth-place.w-p-code*/
/*                                                                                skip "x-date-start: " x-date-start*/
/*                                                                                skip "x-shift-start: " x-shift-start*/
/*                                                                                skip "parstock-start: " parstock-start*/
/*                                                                                view-as alert-box.*/
/*                                                                            end.*/
            display stream PrnLibStream
                    "     Остаток на начало периода по " + buf_wth-place.w-p-name @ v-wth-name
                    parstock-start @ v-sum
                    sym1 sym2 sym3 sym4 sym5 sym6 sym7
                    with frame f-wth
            .
            down stream PrnLibStream 1 with frame f-wth .
        end.
    &if "{1}" = "1" &then
        run wth-lib_full-inf-calend-date (
    &endif
    &if "{1}" = "2" &then
        run wth-lib_full-inf-shift-date (
    &endif
    &if "{1}" = "3" or "{1}" = "4" &then
        run wth-lib_full-inf-shift(
    &endif
                                              input buf_clients.obj-type
                                            , input buf_clients.obj-code
                                            , input buf_wth-line.wth-code
                                            , input x-date-start
&if "{1}" = "3" or "{1}" = "4" &then
                                            , input  x-shift-start
&endif
                                            , output  parstock-start
                                            , output  parstock-end
                                            , output  parincome
                                            , output  parincome-cassa
                                            , output  parincome-other
                                            , output  parincass
                                            , output  parincass-bank
                                            , output  parincass-other
                                            , output  parincass-cassa

                                  ).
/*                                                                            if index(wealth.wth-name, "{&abbr_rubli}") <> 0*/
/*                                                                            then do:*/
/*                                                                                message*/
/*                                                                                    "Всего... "*/
/*                                                                                skip "x-date-start: " x-date-start*/
/*                                                                                skip "x-shift-start: " x-shift-start*/
/*                                                                                skip "parstock-start: " parstock-start*/
/*                                                                                view-as alert-box.*/
/*                                                                            end.*/
        display stream PrnLibStream
                "       Остаток на начало Всего на АЗК" @ v-wth-name
                parstock-start  @ v-sum
                sym1 sym2 sym3 sym4 sym5 sym6 sym7
                with frame f-wth
        .
        down stream PrnLibStream 1 with frame f-wth .
    end.
end.
/*---E----- При первом появлении мат. ценности выводим остатки на начало ------ */


assign
    v-wth-name = wealth.wth-name
    v-doc-date = buf_wth-line.fact-date
    v-doc-code = buf_wth-line.doc-code
    v-sum      = buf_wth-line.fact-sum
.
if buf_wth-doc.inter_ = yes
then do:    /* Документ внутренний */
    find first buf_out_wth-place no-lock
         where buf_out_wth-place.w-p-code = buf_wth-line.out-code
    .
    assign
        v-deliver  = (if     buf_wth-doc.doc-type = {&income}
                        then buf_out_wth-place.w-p-name
                        else wth-place.w-p-name
                     )
        v-receiver = (if     buf_wth-doc.doc-type = {&income}
                        then wth-place.w-p-name
                        else buf_out_wth-place.w-p-name
                     )
    .
end.        /* buf_wth-doc.inter_ = yes  */
else do:
    assign
        v-deliver  = (if     buf_wth-doc.doc-type = {&income}
                        then buf_wth-doc.cli-name
                        else wth-place.w-p-name
                    )
        v-receiver = (if     buf_wth-doc.doc-type = {&income}
                        then wth-place.w-p-name
                        else buf_wth-doc.cli-name
                    )
    .
end.

DISPLAY STREAM PrnLibStream
        v-doc-date
        v-doc-code
        v-deliver
        v-receiver
        v-sum
        sym1 sym2 sym3 sym4 sym5 sym6 sym7
        with frame f-wth
.
DOWN STREAM PrnLibStream 1 with frame f-wth .

/*---S----- При последнем появлении сцене мат. ценности выводим остатки на конец ------ */
if last-of (wealth.wth-code)
then do:
if x-radio-task <> 4 or x-date-start = x-date-end
then do:
    for each buf_wth-place
      where buf_wth-place.host-code = buf_wth-doc.host-code
        and buf_wth-place.obj-type  = buf_wth-doc.obj-type
        and buf_wth-place.obj-code  = buf_wth-doc.obj-code
    :
&if "{1}" = "1" &then
        run wth-lib_full-inf-calend-date-place(
&endif
&if "{1}" = "2" &then
        run wth-lib_full-inf-shift-date-place(
&endif
&if "{1}" = "3" or "{1}" = "4" &then
        run wth-lib_full-inf-shift-place(
&endif
                                input  buf_clients.obj-type
                              , input  buf_clients.obj-code
                              , input  buf_wth-line.wth-code
                              , input  buf_wth-place.w-p-code
                              , input  x-date-end
&if "{1}" = "3" or "{1}" = "4" &then
                              , input  x-shift-end
&endif
                              , output parstock-start
                              , output parstock-end
                              , output parincome
                              , output parincome-cassa
                              , output parincome-other
                              , output parincass
                              , output parincass-bank
                              , output parincass-other
                              , output parincass-cassa
        ).

/*                                                                            if index(wealth.wth-name, "{&abbr_rubli}") <> 0*/
/*                                                                            then do:*/
/*                                                                                message*/
/*                                                                                    "Место: " buf_wth-place.w-p-name*/
/*                                                                                skip "x-date-end: " x-date-end*/
/*                                                                                skip "x-shift-end: " x-shift-end*/
/*                                                                                skip "parstock-end: " parstock-end*/
/*                                                                                view-as alert-box.*/
/*                                                                            end.*/
        display stream PrnLibStream
                "     Остаток на конец  периода по " + buf_wth-place.w-p-name @ v-wth-name
                parstock-end @ v-sum
                sym1 sym2 sym3 sym4 sym5 sym6 sym7
                with frame f-wth
        .
        down stream PrnLibStream 1 with frame f-wth .
    end.

&if "{1}" = "1" &then
    run wth-lib_full-inf-calend-date (
&endif
&if "{1}" = "2" &then
    run wth-lib_full-inf-shift-date (
&endif
&if "{1}" = "3" or "{1}" = "4" &then
        run wth-lib_full-inf-shift (
&endif
                                          input buf_clients.obj-type
                                        , input buf_clients.obj-code
                                        , input buf_wth-line.wth-code
                                        , input x-date-end
&if "{1}" = "3" or "{1}" = "4" &then
                                        , input  x-shift-end
&endif
                                        , output  parstock-start
                                        , output  parstock-end
                                        , output  parincome
                                        , output  parincome-cassa
                                        , output  parincome-other
                                        , output  parincass
                                        , output  parincass-bank
                                        , output  parincass-other
                                        , output  parincass-cassa
                                        ).
/*                                                                            if index(wealth.wth-name, "{&abbr_rubli}") <> 0*/
/*                                                                            then do:*/
/*                                                                                message*/
/*                                                                                    "Всего... "*/
/*                                                                                skip "x-date-end: " x-date-end*/
/*                                                                                skip "x-shift-end: " x-shift-end*/
/*                                                                                skip "parstock-end: " parstock-end*/
/*                                                                                view-as alert-box.*/
/*                                                                            end.*/
    display stream PrnLibStream
            "       Остаток на конец  Всего на АЗК" @ v-wth-name
            parstock-end @ v-sum
            sym1 sym2 sym3 sym4 sym5 sym6 sym7
            with frame f-wth
    .
    down stream PrnLibStream 1 with frame f-wth .

end.
end.
/*---E----- При последнем появлении мат. ценности выводим остатки на конец ------ */
/* $Workfile$   E n d */