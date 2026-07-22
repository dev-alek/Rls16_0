/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$



Автор: Гридчина Полина Дмитриевна
Дата создания: 10/23/07
Author: Polina Gridchina
Creation date: 10/23/07

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

/*А теперь МЦ, по которым не было движения */
if x-radio-task <> 4 or x-date-start = x-date-end then do:
 for each buf_wealth no-lock where
      not can-find(first tt-rep-doc where tt-rep-doc.wth-code = buf_wealth.wth-code )
      and ((p-wth-ser and buf_wealth.is-ser = 1) or
          (p-wth-money and buf_wealth.is-money) or
          (p-wth-un and buf_wealth.is-ser = 0 and not buf_wealth.is-money )) :
          DISPLAY STREAM PrnLibStream
                buf_wealth.wth-name @ v-wth-name
                sym1 sym2 sym3 sym4 sym5 sym6 sym7
                with frame f-wth
        .
        down stream PrnLibStream 1 with frame f-wth .
      /* Остатки по МХ */
      for each ub.wth-place
         where ub.wth-place.host-code = buf_clients.host-code
         and ub.wth-place.obj-type  = buf_clients.obj-type
         and ub.wth-place.obj-code  = buf_clients.obj-code:

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
                                    , input  buf_wealth.wth-code
                                    , input  wth-place.w-p-code
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

              display stream PrnLibStream
                      "     Остаток на конец  периода по " + wth-place.w-p-name @ v-wth-name
                      parstock-end @ v-sum
                      sym1 sym2 sym3 sym4 sym5 sym6 sym7
                      with frame f-wth
              .
              down stream PrnLibStream 1 with frame f-wth .
      end.        /*Остатки по МХ*/
          /* Остаток на конец по АЗК*/
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
                                            , input buf_wealth.wth-code
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
    display stream PrnLibStream
            "   Остаток на конец  Всего на АЗК" @ v-wth-name
            parstock-end @ v-sum
            sym1 sym2 sym3 sym4 sym5 sym6 sym7
            with frame f-wth
    .
    down stream PrnLibStream 1 with frame f-wth .

 end.
end.