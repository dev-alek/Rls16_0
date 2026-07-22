
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

if (p-wth-ser and wealth.is-ser = 1) or
   (p-wth-money and wealth.is-money) or
   (p-wth-un and wealth.is-ser = 0 and not wealth.is-money ) then.
else next.

/*---S----- При первом появлении мат. ценности выводим остатки на начало ------ */
if first-of (tt-rep-doc.wth-code)
then do:
    if not first(tt-rep-doc.wth-code)
    then put stream PrnLibStream
        skip
          "|" at {&P-S}
          v-single-line format "X({&P-X0})"
          "|"
    .
        DISPLAY STREAM PrnLibStream
                wealth.wth-name @ v-wth-name
                sym1 sym2 sym3 sym4 sym5 sym6 sym7
                with frame f-wth
        .
        down stream PrnLibStream 1 with frame f-wth .
    if x-radio-task <> 4 or x-date-start = x-date-end
    then do:

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
                                            , input tt-rep-doc.wth-code
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
        display stream PrnLibStream
                "   Остаток на начало Всего на АЗК" @ v-wth-name
                parstock-start  @ v-sum
                sym1 sym2 sym3 sym4 sym5 sym6 sym7
                with frame f-wth
        .
        down stream PrnLibStream 1 with frame f-wth .
    end.
end.
/*---E----- При первом появлении мат. ценности выводим остатки на начало ------ */

/**/
if first-of(tt-rep-doc.w-p-code) then do:
  if x-radio-task <> 4 or x-date-start = x-date-end then do:
  /*      for each buf_wth-place
          where buf_wth-place.host-code = g#host-code
            and buf_wth-place.obj-type  = buf_clients.obj-type
            and buf_wth-place.obj-code  = buf_clients.obj-code
        :      */
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
                                  , input  tt-rep-doc.wth-code
                                  , input  tt-rep-doc.w-p-code
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
            display stream PrnLibStream
                    "     Остаток на начало периода по " + buf_wth-place.w-p-name  @ v-wth-name
                    parstock-start @ v-sum
                    sym1 sym2 sym3 sym4 sym5 sym6 sym7
                    with frame f-wth
            .
            down stream PrnLibStream 1 with frame f-wth .
  end.
  else do:
            display stream PrnLibStream
                    "     " + buf_wth-place.w-p-name  @ v-wth-name
                    parstock-start @ v-sum
                    sym1 sym2 sym3 sym4 sym5 sym6 sym7
                    with frame f-wth
            .
            down stream PrnLibStream 1 with frame f-wth .
  end.
end.                                               /* first-of(wth-place) */
if first-of(tt-rep-doc.chk-type) or
   first-of(tt-rep-doc.ext-doc-type)
/*if first-of(tt-rep-doc.chk-type) or
   (first-of(tt-rep-doc.ext-doc-type)  and not tt-rep-doc.chk-type = 0)  */
/*   or (first-of(tt-rep-doc.exter_) and  tt-rep-doc.chk-type = 99)  or
   (first-of(tt-rep-doc.inter_) and  tt-rep-doc.chk-type = 99)     */
 then do: /*Тип документа*/
 v-type-sum = 0.
    /* if tt-rep-doc.doc-type = {&inventory} and tt-rep-doc.chk-type = 99
        then v-chk-type = 'Инвентаризация'.
    else  if  tt-rep-doc.chk-type = 99 and tt-rep-doc.exter_ and tt-rep-doc.doc-type = {&income}
        then v-chk-type = 'Внешний приход'.
    else  if  tt-rep-doc.chk-type = 99 and tt-rep-doc.exter_ and tt-rep-doc.doc-type = {&expense}
        then v-chk-type = 'Внешний расход'.
    else  if  tt-rep-doc.chk-type = 99 and tt-rep-doc.exter_ = no and tt-rep-doc.doc-type = {&income}
        then v-chk-type = 'Внутренний приход'.
    else  if  tt-rep-doc.chk-type = 99 and tt-rep-doc.exter_ = no and tt-rep-doc.doc-type = {&expense}
        then v-chk-type = 'Внутренний расход'.
    else  if  tt-rep-doc.chk-type = 99 and tt-rep-doc.exter_ = no and tt-rep-doc.doc-type = {&return}
        then v-chk-type = 'Внутренний возврат'.
    else  if  tt-rep-doc.chk-type = 99
         then v-chk-type = 'Прочее'.
    else  if tt-rep-doc.chk-type = 0
         then v-chk-type =  'Реализация'  .
    else if tt-rep-doc.chk-type = 2 and tt-rep-doc.exter_ then v-chk-type = 'Инкассировано в  банк'   .
    else v-chk-type = entry( lookup(string(tt-rep-doc.chk-type),{&wth-receipt-codes}), {&wth-receipt-codes-full}  ). */
    if tt-rep-doc.chk-type <> 99 then case tt-rep-doc.chk-type:
      when 0 then v-chk-type = 'Реализация'.
      when 2 then v-chk-type = 'Инкассация'.
      when 3 then v-chk-type = 'Кассовый фонд'.
      when 4 then v-chk-type = 'Перевод оплаты'.
      when 5 then v-chk-type = 'Выплата'.
      otherwise  v-chk-type =  'Прочее'.
    end.
    else v-chk-type =  ENTRY(LOOKUP(tt-rep-doc.ext-doc-type, {&WDEDT_List}), {&WDEDT_List-full}).
    DISPLAY STREAM PrnLibStream
 '                     '  + v-chk-type
     @ v-wth-name

       with frame f-wth
.
/*DOWN STREAM PrnLibStream 1 with frame f-wth .  */

end.
assign
    v-wth-name = wealth.wth-name
    v-doc-date = tt-rep-doc.fact-date
    v-doc-code = tt-rep-doc.doc-code
    v-sum      = (if (tt-rep-doc.doc-type = {&expense} or tt-rep-doc.doc-type = {&write-off}) then 0 - tt-rep-doc.fact-sum else tt-rep-doc.fact-sum )
    v-type-sum = v-type-sum + v-sum
.

if tt-rep-doc.inter_ = yes
then do:    /* Документ внутренний */
    find first buf_out_wth-place no-lock
         where buf_out_wth-place.host-code = tt-rep-doc.host-code
          and  buf_out_wth-place.obj-type = tt-rep-doc.obj-type
          and  buf_out_wth-place.obj-code = tt-rep-doc.obj-code
          and  buf_out_wth-place.w-p-code = tt-rep-doc.out-code
    .
    assign
        v-deliver  = (if     tt-rep-doc.doc-type = {&income}
                        then buf_out_wth-place.w-p-name
                        else buf_wth-place.w-p-name
                     )
        v-receiver = (if     tt-rep-doc.doc-type = {&income}
                        then buf_wth-place.w-p-name
                        else buf_out_wth-place.w-p-name
                     )
    .
end.        /* tt-rep-doc.inter_ = yes  */
else do:
    assign
        v-deliver  = (if     tt-rep-doc.doc-type = {&income}
                        then tt-rep-doc.cli-name
                        else buf_wth-place.w-p-name
                    )
        v-receiver = (if     tt-rep-doc.doc-type = {&income}
                        then buf_wth-place.w-p-name
                        else tt-rep-doc.cli-name
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

if last-of(tt-rep-doc.chk-type) or
   (last-of(tt-rep-doc.ext-doc-type) and not tt-rep-doc.chk-type = 0)
/*   or (last-of(tt-rep-doc.exter_) and  tt-rep-doc.chk-type = 99)  or
   (last-of(tt-rep-doc.inter_) and  tt-rep-doc.chk-type = 99)    */
 then do: /*Итого по типу документа*/
  v-sum = v-type-sum.
    DISPLAY STREAM PrnLibStream
    '               Итого ' + v-chk-type  @ v-wth-name
    v-sum
    sym1 sym2 sym3 sym4 sym5 sym6 sym7
    with frame f-wth
    .
DOWN STREAM PrnLibStream 1 with frame f-wth .

end.  /*last chk-type*/
/*Итого по МХ*/
if last-of(tt-rep-doc.w-p-code) then do:

     if x-radio-task <> 4 or x-date-start = x-date-end
  then do:
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
                                , input  tt-rep-doc.wth-code
                                , input  tt-rep-doc.w-p-code
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
                  "     Остаток на конец  периода по " + buf_wth-place.w-p-name @ v-wth-name
                  parstock-end @ v-sum
                  sym1 sym2 sym3 sym4 sym5 sym6 sym7
                  with frame f-wth
          .
          down stream PrnLibStream 1 with frame f-wth .
      end.
end.
/*---S----- При последнем появлении сцене мат. ценности выводим остатки на конец ------ */
if last-of (tt-rep-doc.wth-code)
then do:
 /*Остатки по МХ, по которым нет движения*/
   if x-radio-task <> 4 or x-date-start = x-date-end
   then do:
      for each wth-place
         where wth-place.host-code = buf_clients.host-code
         and wth-place.obj-type  = buf_clients.obj-type
         and wth-place.obj-code  = buf_clients.obj-code
         and not can-find(first buf_tt-doc where buf_tt-doc.w-p-code = wth-place.w-p-code and buf_tt-doc.wth-code = tt-rep-doc.wth-code):
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
                                    , input  tt-rep-doc.wth-code
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

/*   end.   */

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
                                        , input tt-rep-doc.wth-code
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
/*---E----- При последнем появлении мат. ценности выводим остатки на конец ------ */

/* $Workfile$   E n d */