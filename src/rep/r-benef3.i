/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Печать отчета о выручке

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/11/06
Author: Bakhtadze Natalya
Creation date: 01/11/06

Byinkass

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

{ gbl/cur-time.i }

&global-define  no-benefits    "Не было никакой выручки на выбранных объектах ~
в течение заданного Вами периода времени."


assign
date_string = cur-time-print()
Line = fill( "-", 140 ).

for each benefits:
    delete benefits.
end.

for each inkas-num:
    delete inkas-num.
end.

for each day_sum:
    delete day_sum.
end.

for each all-days_sum:
    delete all-days_sum.
end.


if v-curr-r-b = {&r-b-base} then do:
&if "{1}" = "rubl" &then
sale-price-type = "{&abbr_rubley}".
&else
sale-price-type = base-type.
&endif
end.
else sale-price-type = "{&abbr_rubley}".

run no-benq-i(output found).

if not found then do:
  run waitfram-hide in this-procedure .
  message {&no-benefits} view-as alert-box information .
  return.
end.


run rep/r-beneq2.p (input cas-num,
               output allday-basesum,
               output allday-rublsum) no-error.
if error-status:error then return error .
assign
allday-r-bsum = (if v-curr-r-b = {&r-b-base} then allday-basesum else allday-rublsum).
run waitfram-hide in this-procedure .

if x-date-start = x-date-end
then choice = TRUE .
else choice = HowBreak .

&if "{1}" = "tot" &then
  run prn-lib-open-stream  in this-procedure (
                                              input parParentProc
                                              ,input {&LS_PS_A4}
                                              ,input yes /*p-is-stream*/
                                              ,input no /*p-append*/
                                              ).

&else
  run prn-lib-open-stream  in this-procedure (
                                              input parParentProc
                                              ,input {&CS_PS}
                                              ,input yes /*p-is-stream*/
                                              ,input no /*p-append*/
                                              ).
&endif


FORM HEADER
Line format "X(136)" AT 1 SKIP
"Продолжение - на следующей странице" AT 30 SKIP
with FRAME BottomFrame width {&A4_CW} PAGE-BOTTOM NO-LABELS NO-BOX .
VIEW stream PrnLibStream FRAME BottomFrame .
&if "{1}" = "tot" &then
PUT stream PrnLibStream space(15) .
&else
PUT stream PrnLibStream space(5) .
&endif
PUT stream PrnLibStream UNFORMATTED
string( "ОТЧЕТ  О  ВЫРУЧКЕ " + str1)  format "X(120)" SKIP(1)
str4 SKIP(0)
space(5)
(IF NotInc
 then
 ( "( сформирован НЕ ПО ВСЕМ ЧЕКАМ " + (IF cas-num = 0
                                       then "ВСЕХ КАСС"
                                       ELSE ("КАССЫ " + string(cas-num))
                                       )
 )
  else ("( сформирован ПО ЧЕКАМ " +
        (IF cas-num = 0
          then "ВСЕХ КАСС"
          ELSE ("КАССЫ " + string(cas-num) )
          )
       )
        + ")"
  )                 format "x(80)" skip(1)




.

if choice
then do:
  FORM with frame Benefit-{1} .
end.
else do:
  FORM with FRAME PayCodes-{1} .
end.
DatePrinted = FALSE .

/* MAIN */
FOR EACH obj-list WHERE
         obj-list.obj-type = {&shop} BREAK BY obj-list.obj-code :
  FIND FIRST clients WHERE
            clients.obj-type = obj-list.obj-type  AND
            clients.obj-code = obj-list.obj-code  NO-LOCK .
  if choice then do:
    DOWN stream PrnLibStream 1 with frame Benefit-{1} .
  end.
  else do:
    DOWN stream PrnLibStream 1 with FRAME PayCodes-{1} .
  end.
  PUT stream PrnLibStream space(10) clients.obj-name format "x(60)" skip.
  if choice then do:
    UNDERLINE stream PrnLibStream
    benefits.pay-name
&if "{1}" = "tot" &then
    benefits.curr-name
    benefits.tot-base
&endif
&if "{1}" = "base" &then
    benefits.tot-r-b
&else
    benefits.tot-rubl
&endif
    benefits.pcnt
    with frame Benefit-{1}.
  end. /*if choice*/
  else do:
    UNDERLINE stream PrnLibStream
    benefits.pay-name
&if "{1}" = "tot" &then
    benefits.curr-name
    benefits.tot-base
&endif
&if "{1}" = "base" &then
    benefits.tot-r-b
&else
    benefits.tot-rubl
&endif
    benefits.pcnt
    with frame PAyCodes-{1}.
  end. /*not choice*/
  ACCUMULATE
  obj-list.obj-code ( COUNT ) .
  if choice then do:
    define variable v-list as character no-undo .
    FOR EACH ub.inkas WHERE
             ub.inkas.obj-type = obj-list.obj-type AND
            ub.inkas.obj-code = obj-list.obj-code AND
            ub.inkas.status_ = {&fact} AND
            ub.inkas.doc-date >= x-date-start AND
            ub.inkas.doc-date <= x-date-end NO-LOCK,
        FIRST inkas-num NO-LOCK WHERE
              (inkas-num.inkas-code = ub.inkas.inkas-code),
        EACH ub.inkas-pay-desk WHERE
             ub.inkas-pay-desk.inkas-code = ub.inkas.inkas-code AND
        (IF cas-num > 0 then ub.inkas-pay-desk.pay-desk = cas-num else TRUE)
             NO-LOCK
    BREAK
    BY ub.inkas.obj-type
    BY ub.inkas.obj-code
    BY ub.inkas.status_
    BY ub.inkas.doc-date
    BY ub.inkas-pay-desk.pay-code
    BY ub.inkas-pay-desk.curr-code :
      if first-of( ub.inkas.doc-date ) then  do:
        assign
        accum-total-num-chk = 0
        accum-total-num-chk-nf = 0
        .
        FOR EACH b-inkas WHERE
                b-inkas.obj-type = obj-list.obj-type AND
                b-inkas.obj-code = obj-list.obj-code AND
                b-inkas.status_ = {&fact} AND
                b-inkas.doc-date = inkas.doc-date NO-LOCK:
            assign
            accum-total-num-chk = accum-total-num-chk + b-inkas.num-chk
          accum-total-num-chk-nf = accum-total-num-chk-nf + b-inkas.num-chk-nff
            .
          for EACH b-inkas-pay-desk NO-LOCK WHERE
                 b-inkas-pay-desk.inkas-code = b-inkas.inkas-code AND
                 (IF cas-num > 0 then inkas-pay-desk.pay-desk = cas-num else TRUE):
          ACCUMULATE
          b-inkas-pay-desk.tot-base ( TOTAL )
          b-inkas-pay-desk.tot-rubl ( TOTAL )
          b-inkas-pay-desk.tot-sum ( TOTAL ) .
          end.
        END. /*for each b-inkas*/
        assign
        Day-Tot-Sum = ACCUM TOTAL b-inkas-pay-desk.tot-sum
        Day-Tot-Base = ACCUM TOTAL b-inkas-pay-desk.tot-base
        Day-Tot-Rubl = ACCUM TOTAL b-inkas-pay-desk.tot-rubl
        Day-Tot-R-b  = (if v-curr-r-b = {&r-b-base} then Day-Tot-Base else Day-Tot-rubl)
        day-Num-Chk = accum-total-num-chk
        Day-Num-Chk-nf = accum-total-num-chk-nf.
        ACCUMULATE  Day-Num-Chk (TOTAL).
        ACCUMULATE  Day-Num-Chk-nf (TOTAL).
      end.  /*first-of ub.inkas.doc=date*/
      ACCUMULATE
      ub.inkas-pay-desk.tot-base ( TOTAL )
      ub.inkas-pay-desk.tot-rubl ( TOTAL )
      (if v-curr-r-b = {&r-b-base}
       then ub.inkas-pay-desk.tot-base
       else ub.inkas-pay-desk.tot-rubl) ( TOTAL )
      ub.inkas-pay-desk.tot-sum ( SUB-TOTAL BY ub.inkas-pay-desk.curr-code )
      ub.inkas-pay-desk.tot-base ( SUB-TOTAL BY ub.inkas-pay-desk.curr-code )
      ub.inkas-pay-desk.tot-rubl ( SUB-TOTAL BY ub.inkas-pay-desk.curr-code )
      (if v-curr-r-b = {&r-b-base}
      then ub.inkas-pay-desk.tot-base
      else ub.inkas-pay-desk.tot-rubl)  ( SUB-TOTAL BY ub.inkas-pay-desk.curr-code )
      ub.inkas-pay-desk.tot-sum ( SUB-TOTAL BY ub.inkas-pay-desk.pay-code )
      ub.inkas-pay-desk.tot-base ( SUB-TOTAL BY ub.inkas-pay-desk.pay-code )
      ub.inkas-pay-desk.tot-rubl ( SUB-TOTAL BY ub.inkas-pay-desk.pay-code )
      (if v-curr-r-b = {&r-b-base}
      then ub.inkas-pay-desk.tot-base
      else ub.inkas-pay-desk.tot-rubl)  ( SUB-TOTAL BY ub.inkas-pay-desk.pay-code )
      .
      if first-of( ub.inkas-pay-desk.curr-code ) then
      FIND FIRST ub.currency WHERE
                ub.currency.curr-code = ub.inkas-pay-desk.curr-code NO-LOCK.
      if first-of( ub.inkas-pay-desk.curr-code ) then
      FIND FIRST ub.cash-pay WHERE
                  ub.cash-pay.cdpay-code = ub.inkas-pay-desk.pay-code AND
                  ub.cash-pay.curr-code = ub.inkas-pay-desk.curr-code NO-LOCK NO-ERROR.
&if "{1}" = "tot" &then
      if last-of( ub.inkas-pay-desk.curr-code ) AND
         ( ACCUM SUB-TOTAL BY ub.inkas-pay-desk.curr-code
           (if v-curr-r-b = {&r-b-base}
            then ub.inkas-pay-desk.tot-base
            else ub.inkas-pay-desk.tot-rubl)
            )  <> 0
      then do:
        DISPLAY stream PrnLibStream
        sym1
        ub.inkas.doc-date WHEN ( NOT DatePrinted ) @ benefits.date_
        sym2
        if avail ub.cash-pay then ub.cash-pay.obj-name else "Неопознанная оплата" @ benefits.pay-name
        sym3
        ub.currency.curr-name @ benefits.curr-name
        sym4
        ( ACCUM SUB-TOTAL BY ub.inkas-pay-desk.curr-code ub.inkas-pay-desk.tot-sum ) @ benefits.tot-sum
        sym5
        ( ACCUM SUB-TOTAL BY ub.inkas-pay-desk.curr-code ub.inkas-pay-desk.tot-base ) @ benefits.tot-base
        sym6
        ( ACCUM SUB-TOTAL BY ub.inkas-pay-desk.curr-code ub.inkas-pay-desk.tot-rubl ) @ benefits.tot-rubl
        sym7
        round( ( ACCUM SUB-TOTAL BY ub.inkas-pay-desk.curr-code
           (if v-curr-r-b = {&r-b-base}
            then ub.inkas-pay-desk.tot-base
            else ub.inkas-pay-desk.tot-rubl)
                                              ) /
                      Day-Tot-r-b * 100, 2 ) @ benefits.pcnt
        sym8
        with frame Benefit-{1} .
        DOWN stream PrnLibStream 1 with frame Benefit-{1} .
      end. /*if last-of( ub.inkas-pay-desk.curr-code ) AND*/
&else
      if last-of( ub.inkas-pay-desk.curr-code ) AND
         ( ACCUM SUB-TOTAL BY ub.inkas-pay-desk.curr-code
           (if v-curr-r-b = {&r-b-base}
            then ub.inkas-pay-desk.tot-base
            else ub.inkas-pay-desk.tot-rubl)
                  ) <> 0
      then do:
&if "{1}" = "base" &then
        DISPLAY stream PrnLibStream
        sym1
        ub.inkas.doc-date WHEN ( NOT DatePrinted ) @ benefits.date_
        sym2
        (if avail ub.cash-pay then ub.cash-pay.obj-name else "Неопознанная оплата") @ benefits.pay-name
        sym6
        ( ACCUM SUB-TOTAL BY ub.inkas-pay-desk.curr-code
           (if v-curr-r-b = {&r-b-base}
            then ub.inkas-pay-desk.tot-base
            else ub.inkas-pay-desk.tot-rubl)
        ) @ benefits.tot-r-b
        sym7
        round( ( ACCUM SUB-TOTAL BY ub.inkas-pay-desk.curr-code
           (if v-curr-r-b = {&r-b-base}
            then ub.inkas-pay-desk.tot-base
            else ub.inkas-pay-desk.tot-rubl)
                ) /
                      Day-Tot-r-b * 100, 2 ) @ benefits.pcnt
        sym8
        with frame Benefit-{1} .
&endif
&if "{1}" = "rubl" &then
        DISPLAY stream PrnLibStream
        sym1
        ub.inkas.doc-date WHEN ( NOT DatePrinted ) @ benefits.date_
        sym2
        (if avail ub.cash-pay then ub.cash-pay.obj-name else "Неопознанная оплата") @ benefits.pay-name
        sym6
        ( ACCUM SUB-TOTAL BY ub.inkas-pay-desk.curr-code ub.inkas-pay-desk.tot-rubl ) @ benefits.tot-rubl
        sym7
        round( ( ACCUM SUB-TOTAL BY ub.inkas-pay-desk.curr-code ub.inkas-pay-desk.tot-rubl ) /
                      Day-Tot-rubl * 100, 2 ) @ benefits.pcnt
        sym8
        with frame Benefit-{1} .
&endif

        DOWN stream PrnLibStream 1 with frame Benefit-{1}.
      end. /*if last-of( ub.inkas-pay-desk.pay-code ) AND*/
&endif
      if last-of( ub.inkas.doc-date ) then  do:
        UNDERLINE stream PrnLibStream
        benefits.pay-name
&if "{1}" = "tot" &then
        benefits.curr-name
        benefits.tot-base
&endif
&if "{1}" = "base" &then
        benefits.tot-r-b
&else
        benefits.tot-rubl
&endif
        benefits.pcnt
        with frame Benefit-{1}.
&if "{1}" = "tot" &then
        DISPLAY stream PrnLibStream
        sym1
        ( "чеков: " + string( Day-Num-Chk,  ">>>>>" )  +  ", ") @ benefits.pay-name
        (string( ROUND( (Day-Tot-BASE  / Day-Num-Chk) , 2) ,  "->>>,>>9.99" ) +
                        "/ чек" ) @ benefits.curr-name
        Day-Tot-Base @ benefits.tot-base
        Day-Tot-Rubl @ benefits.tot-rubl
        "100.00%" @ benefits.pcnt
        sym8
        with frame Benefit-{1} .
        DOWN stream PrnLibStream 1 with frame Benefit-{1}.
        DISPLAY stream PrnLibStream
        sym1
        ( "чеков ф: " + string( (Day-Num-Chk - day-num-chk-nf),  ">>>>>" )  +  ", ") @ benefits.pay-name
        (string( ROUND( (Day-Tot-BASE  / (Day-Num-Chk - day-num-chk-nf)) , 2) ,  "->>>,>>9.99" ) +
                        "/ чек" ) @ benefits.curr-name
        Day-Tot-Base @ benefits.tot-base
        Day-Tot-Rubl @ benefits.tot-rubl
        "100.00%" @ benefits.pcnt
        sym8
        with frame Benefit-{1} .
&endif
&if "{1}" = "base" &then
        DISPLAY stream PrnLibStream
        sym1
        ( "чеков: " + string( Day-Num-Chk,  ">>>>>" )  +  ", в среднем " +
        string( ROUND( (Day-Tot-r-b  / Day-Num-Chk) , 2) ,  "->>>,>>9.99" ) +
                    "/ чек" ) @ benefits.pay-name
        Day-Tot-r-b @ benefits.tot-r-b
        "100.00%" @ benefits.pcnt
        sym8
        with frame Benefit-{1} .
        DOWN stream PrnLibStream 1 with frame Benefit-{1}.
        DISPLAY stream PrnLibStream
        sym1
        ( "чеков ф: " + string( Day-Num-Chk - day-num-chk-nf,  ">>>>>" )  +  ", в среднем " +
        string( ROUND( (Day-Tot-r-b  / (Day-Num-Chk - day-num-chk-nf)) , 2) ,  "->>>,>>9.99" ) +
                    "/ чек" ) @ benefits.pay-name
        Day-Tot-r-b @ benefits.tot-r-b
        "100.00%" @ benefits.pcnt
        sym8
        with frame Benefit-{1} .

&endif
&if "{1}" = "rubl" &then
        DISPLAY stream PrnLibStream
        sym1
        ( "чеков: " + string( Day-Num-Chk,  ">>>>>" )  +  ", в среднем " +
        string( ROUND( (Day-Tot-rubl  / Day-Num-Chk) , 2) ,  "->>>,>>9.99" ) +
                    "/ чек" ) @ benefits.pay-name
        Day-Tot-rubl @ benefits.tot-rubl
        "100.00%" @ benefits.pcnt
        sym8
        with frame Benefit-{1} .
        DOWN stream PrnLibStream 1 with frame Benefit-{1}.
        DISPLAY stream PrnLibStream
        sym1
        ( "чеков ф: " + string( Day-Num-Chk - day-num-chk-nf,  ">>>>>" )  +  ", в среднем " +
        string( ROUND( (Day-Tot-rubl  / (Day-Num-Chk - day-num-chk-nf)) , 2) ,  "->>>,>>9.99" ) +
                    "/ чек" ) @ benefits.pay-name
        Day-Tot-rubl @ benefits.tot-rubl
        "100.00%" @ benefits.pcnt
        sym8
        with frame Benefit-{1} .

&endif
        UNDERLINE stream PrnLibStream
        benefits.pay-name
&if "{1}" = "tot" &then
        benefits.curr-name
        benefits.tot-base
&endif
&if "{1}" = "base" &then
        benefits.tot-r-b
&else
        benefits.tot-rubl
&endif
        benefits.pcnt
        with frame Benefit-{1}.
        DatePrinted = FALSE .
      end. /*if last-of( ub.inkas.doc-date ) */
      if last( ub.inkas.doc-date ) AND ( x-date-start <> x-date-end ) then do:
        ALLDay-Num-Chk = ACCUM TOTAL Day-Num-Chk.
        ALLDay-Num-Chk-nf = ACCUM TOTAL Day-Num-Chk-nf.
        UNDERLINE stream PrnLibStream
        benefits.pay-name
&if "{1}" = "tot" &then
        benefits.curr-name
        benefits.tot-base
&endif
&if "{1}" = "base" &then
        benefits.tot-r-b
&else
        benefits.tot-rubl
&endif
        benefits.pcnt
        with frame Benefit-{1}.
&if "{1}" = "tot" &then
        DISPLAY stream PrnLibStream
        ( " ИТОГО чеков: " + string( AllDay-Num-Chk )  + " - " +
          string( round( (  ( ACCUM TOTAL
                              (if v-curr-r-b = {&r-b-base}
                               then ub.inkas-pay-desk.tot-base
                               else ub.inkas-pay-desk.tot-rubl)
                               ) / AllDay-Num-Chk )  , 2  ) , "->>>,>>9.99")
          + "/чек") @ benefits.pay-name
        ACCUM TOTAL ub.inkas-pay-desk.tot-base  @ benefits.tot-base
        ACCUM TOTAL ub.inkas-pay-desk.tot-rubl  @ benefits.tot-rubl
        with frame Benefit-{1}.
        DOWN stream PrnLibStream 1 with frame Benefit-{1}.
        DISPLAY stream PrnLibStream
        ( " ИТОГО чеков ф: " + string( AllDay-Num-Chk - allday-num-chk-nf )  + " - " +
          string( round( (  ( ACCUM TOTAL
                              (if v-curr-r-b = {&r-b-base}
                               then ub.inkas-pay-desk.tot-base
                               else ub.inkas-pay-desk.tot-rubl)
                               ) / (AllDay-Num-Chk - allday-num-chk-nf ))  , 2  ) , "->>>,>>9.99")
          + "/чек") @ benefits.pay-name
        ACCUM TOTAL ub.inkas-pay-desk.tot-base  @ benefits.tot-base
        ACCUM TOTAL ub.inkas-pay-desk.tot-rubl  @ benefits.tot-rubl
        with frame Benefit-{1}.

&endif
&if "{1}" = "base" &then
        DISPLAY stream PrnLibStream
        ( " ИТОГО чеков: " + string( AllDay-Num-Chk )  + " - " +
          string( round( (  ( ACCUM TOTAL
                              (if v-curr-r-b = {&r-b-base}
                               then ub.inkas-pay-desk.tot-base
                               else ub.inkas-pay-desk.tot-rubl)
          ) / AllDay-Num-Chk )  , 2  ) , "->>>,>>9.99")
          + "/чек") @ benefits.pay-name
        ACCUM TOTAL
                              (if v-curr-r-b = {&r-b-base}
                               then ub.inkas-pay-desk.tot-base
                               else ub.inkas-pay-desk.tot-rubl)

        @ benefits.tot-r-b
        with frame Benefit-{1} .
        DOWN stream PrnLibStream 1 with frame Benefit-{1}.
        DISPLAY stream PrnLibStream
        ( " ИТОГО чеков ф: " + string( AllDay-Num-Chk - allday-num-chk-nf)  + " - " +
          string( round( (  ( ACCUM TOTAL
                              (if v-curr-r-b = {&r-b-base}
                               then ub.inkas-pay-desk.tot-base
                               else ub.inkas-pay-desk.tot-rubl)
          ) / (AllDay-Num-Chk - allday-num-chk-nf) )  , 2  ) , "->>>,>>9.99")
          + "/чек") @ benefits.pay-name
        ACCUM TOTAL
                              (if v-curr-r-b = {&r-b-base}
                               then ub.inkas-pay-desk.tot-base
                               else ub.inkas-pay-desk.tot-rubl)

        @ benefits.tot-r-b
        with frame Benefit-{1} .
&endif
&if "{1}" = "rubl" &then
        DISPLAY stream PrnLibStream
        ( " ИТОГО чеков: " + string( AllDay-Num-Chk )  + " - " +
          string( round( (  ( ACCUM TOTAL ub.inkas-pay-desk.tot-rubl ) / AllDay-Num-Chk )  , 2  ) , "->>>,>>9.99")
          + "/чек") @ benefits.pay-name
        ACCUM TOTAL ub.inkas-pay-desk.tot-rubl  @ benefits.tot-rubl
        with frame Benefit-{1} .
        DOWN stream PrnLibStream 1 with frame Benefit-{1} .
        DISPLAY stream PrnLibStream
        ( " ИТОГО чеков ф: " + string( AllDay-Num-Chk - allday-num-chk-nf )  + " - " +
          string( round( (  ( ACCUM TOTAL ub.inkas-pay-desk.tot-rubl ) / (AllDay-Num-Chk - allday-num-chk-nf) )  , 2  ) , "->>>,>>9.99")
          + "/чек") @ benefits.pay-name
        ACCUM TOTAL ub.inkas-pay-desk.tot-rubl  @ benefits.tot-rubl
        with frame Benefit-{1} .

&endif
        DOWN stream PrnLibStream 1 with frame Benefit-{1} .
      end. /* if last( inkas.doc-date ) AND ( x-date-start <> x-date-end ) */
    END . /* FOR EACH inkas ... */
  end. /*if choice*/
  else do: /* сводный за период */
    assign
    ACCUM-TOTAL-num-chk = 0
    ACCUM-TOTAL-num-chk-nf  = 0
    .
   FOR EACH ub.inkas WHERE
            ub.inkas.obj-type = obj-list.obj-type AND
            ub.inkas.obj-code = obj-list.obj-code AND
            ub.inkas.status_ = {&fact} AND
            ub.inkas.doc-date >= x-date-start AND
            ub.inkas.doc-date <= x-date-end NO-LOCK USE-INDEX pi:
      assign
      accum-total-num-chk = accum-total-num-chk + ub.inkas.num-chk.
      accum-total-num-chk-nf = accum-total-num-chk-nf + ub.inkas.num-chk-nff.
    end.
    FOR EACH ub.inkas WHERE
            ub.inkas.obj-type = obj-list.obj-type AND
            ub.inkas.obj-code = obj-list.obj-code AND
            ub.inkas.status_ = {&fact} AND
            ub.inkas.doc-date >= x-date-start AND
            ub.inkas.doc-date <= x-date-end NO-LOCK USE-INDEX pi,
        FIRST inkas-num WHERE
              inkas-num.inkas-code = ub.inkas.inkas-code,
        EACH ub.inkas-pay-desk WHERE
             ub.inkas-pay-desk.inkas-code = ub.inkas.inkas-code AND
            (IF cas-num > 0 then ub.inkas-pay-desk.pay-desk = cas-num else TRUE)
             NO-LOCK
    BREAK
    BY ub.inkas-pay-desk.pay-code
    BY ub.inkas-pay-desk.curr-code :
      ACCUMULATE
      ub.inkas-pay-desk.tot-sum ( TOTAL )
      ub.inkas-pay-desk.tot-base ( TOTAL )
      ub.inkas-pay-desk.tot-rubl ( TOTAL )
      (if v-curr-r-b = {&r-b-base}
       then ub.inkas-pay-desk.tot-base
       else ub.inkas-pay-desk.tot-rubl) ( TOTAL )
      ub.inkas-pay-desk.tot-sum ( SUB-TOTAL BY ub.inkas-pay-desk.curr-code )
      ub.inkas-pay-desk.tot-base ( SUB-TOTAL BY ub.inkas-pay-desk.curr-code )
      ub.inkas-pay-desk.tot-rubl ( SUB-TOTAL BY ub.inkas-pay-desk.curr-code )
      (if v-curr-r-b = {&r-b-base}
       then ub.inkas-pay-desk.tot-base
       else ub.inkas-pay-desk.tot-rubl) ( SUB-TOTAL BY ub.inkas-pay-desk.curr-code )
      ub.inkas-pay-desk.tot-sum ( SUB-TOTAL BY ub.inkas-pay-desk.pay-code )
      ub.inkas-pay-desk.tot-base ( SUB-TOTAL BY ub.inkas-pay-desk.pay-code )
      ub.inkas-pay-desk.tot-rubl ( SUB-TOTAL BY ub.inkas-pay-desk.pay-code )
      (if v-curr-r-b = {&r-b-base}
       then ub.inkas-pay-desk.tot-base
       else ub.inkas-pay-desk.tot-rubl) ( SUB-TOTAL BY ub.inkas-pay-desk.pay-code )
      .
      if first-of( ub.inkas-pay-desk.curr-code ) then
      FIND FIRST ub.currency WHERE ub.currency.curr-code = ub.inkas-pay-desk.curr-code NO-LOCK.
      if first-of( ub.inkas-pay-desk.curr-code ) then
      FIND FIRST ub.cash-pay WHERE
                ub.cash-pay.cdpay-code = ub.inkas-pay-desk.pay-code AND
                ub.cash-pay.curr-code = ub.inkas-pay-desk.curr-code NO-LOCK NO-ERROR.
&if "{1}" = "tot" &then
      if last-of( ub.inkas-pay-desk.curr-code ) AND
        ( ACCUM SUB-TOTAL BY ub.inkas-pay-desk.curr-code ub.inkas-pay-desk.tot-base ) <> 0 then do:
        find first all-days_sum where
                  all-days_sum.obj-type = obj-list.obj-type
              and all-days_sum.obj-code = obj-list.obj-code no-error .

        DISPLAY stream PrnLibStream
        sym1
        (if avail ub.cash-pay then ub.cash-pay.obj-name else "Неопознанная оплата") @ benefits.pay-name
        sym3
        ub.currency.curr-name @ benefits.curr-name
        sym4
        ( ACCUM SUB-TOTAL BY ub.inkas-pay-desk.curr-code ub.inkas-pay-desk.tot-sum ) @ benefits.tot-sum
        sym5
        ( ACCUM SUB-TOTAL BY ub.inkas-pay-desk.curr-code ub.inkas-pay-desk.tot-base ) @ benefits.tot-base
        sym6
        ( ACCUM SUB-TOTAL BY ub.inkas-pay-desk.curr-code ub.inkas-pay-desk.tot-rubl ) @ benefits.tot-rubl
        sym7
        ( round( ( ACCUM SUB-TOTAL BY ub.inkas-pay-desk.curr-code ub.inkas-pay-desk.tot-base ) /
                       (if available all-days_sum
                       then all-days_sum.tot-base
                       else 0)
                         * 100, 2 ) ) @ benefits.pcnt
        sym8
        with frame PayCodes-{1} .
        DOWN stream PrnLibStream 1 with frame PayCodes-{1}.
      end.
&else
      if last-of( ub.inkas-pay-desk.curr-code ) AND
        ( ACCUM SUB-TOTAL BY inkas-pay-desk.curr-code
                              (if v-curr-r-b = {&r-b-base}
                               then ub.inkas-pay-desk.tot-base
                               else ub.inkas-pay-desk.tot-rubl)
                ) <> 0 then do:
        find first all-days_sum where
                  all-days_sum.obj-type = obj-list.obj-type
              and all-days_sum.obj-code = obj-list.obj-code no-error .

&if "{1}" = "base" &then
        DISPLAY stream PrnLibStream
        sym1
        (if avail ub.cash-pay then ub.cash-pay.obj-name else "Неопознанная оплата") @ benefits.pay-name
        sym6
        ( ACCUM SUB-TOTAL BY ub.inkas-pay-desk.curr-code
                              (if v-curr-r-b = {&r-b-base}
                               then ub.inkas-pay-desk.tot-base
                               else ub.inkas-pay-desk.tot-rubl)
                ) @ benefits.tot-r-b
        sym7
        ( round( ( ACCUM SUB-TOTAL BY ub.inkas-pay-desk.curr-code
                              (if v-curr-r-b = {&r-b-base}
                               then ub.inkas-pay-desk.tot-base
                               else ub.inkas-pay-desk.tot-rubl)
                ) /
                      (if available all-days_sum
                       then all-days_sum.tot-r-b
                       else 0)
                           * 100, 2 ) ) @ benefits.pcnt
        sym8
        with frame PayCodes-{1} .
&endif
&if "{1}" = "rubl" &then
        DISPLAY stream PrnLibStream
        sym1
        (if avail ub.cash-pay then ub.cash-pay.obj-name else "Неопознанная оплата") @ benefits.pay-name
        sym6
        ( ACCUM SUB-TOTAL BY ub.inkas-pay-desk.curr-code ub.inkas-pay-desk.tot-rubl ) @ benefits.tot-rubl
        sym7
        ( round( ( ACCUM SUB-TOTAL BY ub.inkas-pay-desk.curr-code ub.inkas-pay-desk.tot-rubl ) /
                       (if available all-days_sum
                       then all-days_sum.tot-rubl
                       else 0)
                           * 100, 2 ) ) @ benefits.pcnt
        sym8
        with frame PayCodes-{1} .
&endif
        DOWN stream PrnLibStream 1 with FRAME PayCodes-{1} .
      end.
&endif
      if last( ub.inkas-pay-desk.curr-code ) then do:
        UNDERLINE stream PrnLibStream
        benefits.pay-name
&if "{1}" = "tot" &then
        benefits.curr-name
        benefits.tot-base
&endif
&if "{1}" = "base" &then
        benefits.tot-r-b
&else
        benefits.tot-rubl
&endif
        benefits.pcnt
        with frame Paycodes-{1}.
&if "{1}" = "tot" &then
        DISPLAY stream PrnLibStream
        ( " ИТОГО чеков: " + string( ACCUM-TOTAL-num-chk  )  + " - " +
        string( round( (  ( ACCUM TOTAL
                              (if v-curr-r-b = {&r-b-base}
                               then ub.inkas-pay-desk.tot-base
                               else ub.inkas-pay-desk.tot-rubl)
                ) / (ACCUM-TOTAL-num-chk ) )  , 2  ) , "->>>,>>9.99")
                                  + "/чек") @ benefits.pay-name
        ( ACCUM TOTAL ub.inkas-pay-desk.tot-base ) @ benefits.tot-base
        ( ACCUM TOTAL ub.inkas-pay-desk.tot-rubl ) @ benefits.tot-rubl
        "100.00%" @ benefits.pcnt
        with frame PayCodes-{1}.
        DOWN stream PrnLibStream 1 with FRAME PayCodes-{1} .
        DISPLAY stream PrnLibStream
        ( " ИТОГО чеков ф: " + string( ACCUM-TOTAL-num-chk - accum-total-num-chk-nf )  + " - " +
        string( round( (  ( ACCUM TOTAL
                              (if v-curr-r-b = {&r-b-base}
                               then ub.inkas-pay-desk.tot-base
                               else ub.inkas-pay-desk.tot-rubl)
                ) / ( ACCUM-TOTAL-num-chk - accum-total-num-chk-nf) )  , 2  ) , "->>>,>>9.99")
                                  + "/чек") @ benefits.pay-name
        ( ACCUM TOTAL ub.inkas-pay-desk.tot-base ) @ benefits.tot-base
        ( ACCUM TOTAL ub.inkas-pay-desk.tot-rubl ) @ benefits.tot-rubl
        "100.00%" @ benefits.pcnt
        with frame PayCodes-{1}.

&endif
&if "{1}" = "base" &then
        DISPLAY stream PrnLibStream
        ( " ИТОГО чеков: " + string( ACCUM-TOTAL-num-chk )  + " - " +
        string( round( (  ( ACCUM TOTAL
                              (if v-curr-r-b = {&r-b-base}
                               then ub.inkas-pay-desk.tot-base
                               else ub.inkas-pay-desk.tot-rubl)
                ) / ( ACCUM-TOTAL-num-chk ) )  , 2  ) , "->>>,>>9.99")
                            + "/чек")  @ benefits.pay-name
        ( ACCUM TOTAL
                              (if v-curr-r-b = {&r-b-base}
                               then ub.inkas-pay-desk.tot-base
                               else ub.inkas-pay-desk.tot-rubl)
                ) @ benefits.tot-r-b
        "100.00%" @ benefits.pcnt
        with frame PayCodes-{1} .
        DOWN stream PrnLibStream 1 with FRAME PayCodes-{1} .
        DISPLAY stream PrnLibStream
        ( " ИТОГО чеков ф: " + string( ACCUM-TOTAL-num-chk - accum-total-num-chk-nf)  + " - " +
        string( round( (  ( ACCUM TOTAL
                              (if v-curr-r-b = {&r-b-base}
                               then ub.inkas-pay-desk.tot-base
                               else ub.inkas-pay-desk.tot-rubl)
                ) / ( ACCUM-TOTAL-num-chk  - accum-total-num-chk-nf) )  , 2  ) , "->>>,>>9.99")
                            + "/чек")  @ benefits.pay-name
        ( ACCUM TOTAL
                              (if v-curr-r-b = {&r-b-base}
                               then ub.inkas-pay-desk.tot-base
                               else ub.inkas-pay-desk.tot-rubl)
                ) @ benefits.tot-r-b
        "100.00%" @ benefits.pcnt
        with frame PayCodes-{1} .

&endif
&if "{1}" = "rubl" &then
        DISPLAY stream PrnLibStream
        ( " ИТОГО чеков: " + string( ACCUM-TOTAL-num-chk )  + " - " +
        string( round( (  ( ACCUM TOTAL ub.inkas-pay-desk.tot-rubl ) / ( ACCUM-TOTAL-num-chk  ))  , 2  ) , "->>>,>>9.99")
                            + "/чек")  @ benefits.pay-name
        ( ACCUM TOTAL inkas-pay-desk.tot-rubl ) @ benefits.tot-rubl
        "100.00%" @ benefits.pcnt
        with frame PayCodes-{1} .
        DOWN stream PrnLibStream 1 with FRAME PayCodes-{1}.
        DISPLAY stream PrnLibStream
        ( " ИТОГО чеков ф: " + string( ACCUM-TOTAL-num-chk - accum-total-num-chk-nf )  + " - " +
        string( round( (  ( ACCUM TOTAL ub.inkas-pay-desk.tot-rubl ) / ( ACCUM-TOTAL-num-chk - accum-total-num-chk-nf ) )  , 2  ) , "->>>,>>9.99")
                            + "/чек")  @ benefits.pay-name
        ( ACCUM TOTAL ub.inkas-pay-desk.tot-rubl ) @ benefits.tot-rubl
        "100.00%" @ benefits.pcnt
        with frame PayCodes-{1} .

&endif
        DOWN stream PrnLibStream 1 with FRAME PayCodes-{1}.
      end. /*if last( inkas-pay-desk.curr-code ) */
    END. /*FOR EACH inkas WHERE*/
  end. /*not choice*/
  if choice
  then
  assign
  ALLOBJ-ALlDAy-Num-CHk = ALLOBJ-ALlDay-Num-CHk + /*ACCUM-TOTAL-num-chk*/  accum total Day-Num-Chk
  ALLOBJ-ALlDAy-Num-CHk-nf = ALLOBJ-ALlDay-Num-CHk-nf + /*aCCUM-TOTAL-num-chk-nf*/ accum total Day-Num-Chk-nf
  .
  else
  assign
  ALLDay-Num-Chk = AllDay-Num-Chk + ACCUM-TOTAL-num-chk
  ALLDay-Num-Chk-nf = AllDay-Num-Chk-nf + ACCUM-TOTAL-num-chk-nf
  .
  if last-of( obj-list.obj-code ) then do:
    if choice then do:
      UNDERLINE stream PrnLibStream
      benefits.pay-name
&if "{1}" = "tot" &then
      benefits.curr-name
      benefits.tot-base
&endif
&if "{1}" = "base" &then
      benefits.tot-r-b
&else
      benefits.tot-rubl
&endif
      benefits.pcnt
      with frame Benefit-{1}.
    end. /*if choice */
    else do:
      UNDERLINE stream PrnLibStream
      benefits.pay-name
&if "{1}" = "tot" &then
      benefits.curr-name
      benefits.tot-base
&endif
&if "{1}" = "base" &then
      benefits.tot-r-b
&else
      benefits.tot-rubl
&endif
      benefits.pcnt
      with frame Paycodes-{1}.
    end. /*not choice*/
  end. /*if last-of( obj-list.obj-code )*/
  if last( obj-list.obj-code ) AND ( ACCUM COUNT obj-list.obj-code ) > 1 then do:
    if choice then do:
&if "{1}" = "tot" &then
      DISPLAY stream PrnLibStream
      ( "ИТОГО по всем - чеков "  + string(ALlObj-ALLDay-Num-Chk) + " - " +
        string( ROUND ( ( AllDay-BaseSum / (ALlObj-ALLDay-Num-Chk)), 2)) +
        "/чек (баз.вал.)" )  @ benefits.pay-name
      AllDay-BaseSum @ benefits.tot-base
      AllDay-RublSum @ benefits.tot-rubl
      with FRAME Benefit-{1}.
      DOWN stream PrnLibStream 1 with FRAME benefit-{1}.
      DISPLAY stream PrnLibStream
      ( "ИТОГО по всем - чеков ф"  + string(ALlObj-ALLDay-Num-Chk - allobj-allday-num-chk-nf) + " - " +
        string( ROUND ( ( AllDay-BaseSum / (ALlObj-ALLDay-Num-Chk - allobj-allday-num-chk-nf)), 2)) +
        "/чек (баз.вал.)" )  @ benefits.pay-name
      AllDay-BaseSum @ benefits.tot-base
      AllDay-RublSum @ benefits.tot-rubl
      with FRAME Benefit-{1}.

&endif
&if "{1}" = "base" &then
      DISPLAY stream PrnLibStream
      ( "ИТОГО по всем - чеков "  + string(ALlObj-ALLDay-Num-Chk) + " -  " +
        string( ROUND ( ( AllDay-BaseSum / ( ALLObj-ALLDay-Num-Chk)), 2)) +
        "/чек(баз.вал.)" )  @ benefits.pay-name
      AllDay-BaseSum @ benefits.tot-r-b
      with FRAME Benefit-{1} .
      DOWN stream PrnLibStream 1 with FRAME benefit-{1}.
      DISPLAY stream PrnLibStream
      ( "ИТОГО по всем - чеков ф"  + string(ALlObj-ALLDay-Num-Chk - allobj-allday-num-chk-nf) + " -  " +
        string( ROUND ( ( AllDay-BaseSum / ( ALLObj-ALLDay-Num-Chk - allobj-allday-num-chk-nf)), 2)) +
        "/чек(баз.вал.)" )  @ benefits.pay-name
      AllDay-BaseSum @ benefits.tot-r-b
      with FRAME Benefit-{1} .
&endif
&if "{1}" = "rubl" &then
      DISPLAY stream PrnLibStream
      ( "ИТОГО по всем - чеков "  + string(ALlObj-ALLDay-Num-Chk) + " -  " +
        string( ROUND ( ( AllDay-RublSum / ( ALLObj-ALLDay-Num-Chk)), 2)) +
        "/чек(баз.вал.)" )  @ benefits.pay-name
      AllDay-RublSum @ benefits.tot-rubl
      with FRAME Benefit-{1} .
      DOWN stream PrnLibStream 1 with FRAME benefit-{1}.
      DISPLAY stream PrnLibStream
      ( "ИТОГО по всем - чеков ф"  + string(ALlObj-ALLDay-Num-Chk - allobj-allday-num-chk-nf) + " -  " +
        string( ROUND ( ( AllDay-RublSum / ( ALLObj-ALLDay-Num-Chk - allobj-allday-num-chk-nf)), 2)) +
        "/чек(баз.вал.)" )  @ benefits.pay-name
      AllDay-RublSum @ benefits.tot-rubl
      with FRAME Benefit-{1} .
&endif
    end. /*choice = yes*/
    else do:
&if "{1}" = "tot" &then
      DISPLAY stream PrnLibStream
      ( "ИТОГО по всем - чеков "  + string(ALLDay-Num-Chk) + " - " +
      string( ROUND ( ( AllDay-r-bSum / ALLDay-Num-Chk), 2)) +
      "/чек(баз.вал.)" )  @ benefits.pay-name
      AllDay-BaseSum @ benefits.tot-base
      AllDay-RublSum @ benefits.tot-rubl
      with FRAME PayCodes-{1} .
      DOWN stream PrnLibStream 1 with FRAME paycodes-{1}.
      DISPLAY stream PrnLibStream
      ( "ИТОГО по всем - чеков ф"  + string(ALLDay-Num-Chk - ALLDay-Num-Chk-nf) + " - " +
      string( ROUND ( ( AllDay-r-bSum / (ALLDay-Num-Chk - ALLDay-Num-Chk-nf)), 2)) +
      "/чек(баз.вал.)" )  @ benefits.pay-name
      AllDay-BaseSum @ benefits.tot-base
      AllDay-RublSum @ benefits.tot-rubl
      with FRAME PayCodes-{1} .

&endif
&if "{1}" = "base" &then
      DISPLAY stream PrnLibStream
      ( "ИТОГО по всем - чеков "  + string(ALLDay-Num-Chk) + " - " +
        string( ROUND ( ( AllDay-r-bSum / ALLDay-Num-Chk), 2)) +
        "/чек(баз.вал.)" )  @ benefits.pay-name
      AllDay-BaseSum @ benefits.tot-r-b
      with FRAME PayCodes-{1} .
      DOWN stream PrnLibStream 1 with FRAME paycodes-{1}.
      DISPLAY stream PrnLibStream
      ( "ИТОГО по всем - чеков ф"  + string(ALLDay-Num-Chk - allday-num-chk-nf) + " - " +
        string( ROUND ( ( AllDay-r-bSum / (ALLDay-Num-Chk - allday-num-chk-nf)), 2)) +
        "/чек(баз.вал.)" )  @ benefits.pay-name
      AllDay-BaseSum @ benefits.tot-r-b
      with FRAME PayCodes-{1} .

&endif
&if "{1}" = "rubl" &then
      DISPLAY stream PrnLibStream
      ( "ИТОГО по всем - чеков "  + string(ALLDay-Num-Chk) + " - " +
        string( ROUND ( ( AllDay-rublSum / ALLDay-Num-Chk), 2)) +
        "/чек(баз.вал.)" )  @ benefits.pay-name
      AllDay-rublSum @ benefits.tot-rubl
      with FRAME PayCodes-{1} .
      DOWN stream PrnLibStream 1 with FRAME paycodes-{1}.
      DISPLAY stream PrnLibStream
      ( "ИТОГО по всем - чеков ф"  + string(ALLDay-Num-Chk - allday-num-chk-nf) + " - " +
        string( ROUND ( ( AllDay-rublSum / (ALLDay-Num-Chk - allday-num-chk-nf)), 2)) +
        "/чек(баз.вал.)" )  @ benefits.pay-name
      AllDay-rublSum @ benefits.tot-rubl
      with FRAME PayCodes-{1} .

&endif
    end. /*choice = no*/
  end. /* if last( obj-list.obj-code ) AND ( ACCUM COUNT obj-list.obj-code ) > 1   */
END.  /* FOR EACH obj-list ... */

ObjAmount = ( ACCUM COUNT obj-list.obj-code ) .
if choice AND ( ObjAmount > 1 ) then do:
  FORM with frame ZUM-PayCodes-{1} .
  FOR EACH obj-list WHERE
           obj-list.obj-type = {&shop},
      EACH ub.inkas WHERE
           ub.inkas.obj-type = obj-list.obj-type AND
          ub.inkas.obj-code = obj-list.obj-code AND
          ub.inkas.status_ = {&fact} AND
          ub.inkas.doc-date >= x-date-start AND
          ub.inkas.doc-date <= x-date-end NO-LOCK,
      FIRST inkas-num WHERE
            inkas-num.inkas-code = inkas.inkas-code,
      EACH ub.inkas-pay-desk WHERE
           ub.inkas-pay-desk.inkas-code = inkas.inkas-code AND
     (IF cas-num > 0 then ub.inkas-pay-desk.pay-desk = cas-num else TRUE)
           NO-LOCK
  BREAK
  BY ub.inkas-pay-desk.pay-code
  BY ub.inkas-pay-desk.curr-code :
    ACCUMULATE
    inkas-pay-desk.tot-sum ( SUB-TOTAL BY ub.inkas-pay-desk.pay-code )
    inkas-pay-desk.tot-base ( SUB-TOTAL BY ub.inkas-pay-desk.pay-code )
    inkas-pay-desk.tot-rubl ( SUB-TOTAL BY ub.inkas-pay-desk.pay-code )
    inkas-pay-desk.tot-sum ( SUB-TOTAL BY ub.inkas-pay-desk.curr-code )
    inkas-pay-desk.tot-base ( SUB-TOTAL BY ub.inkas-pay-desk.curr-code )
    inkas-pay-desk.tot-rubl ( SUB-TOTAL BY ub.inkas-pay-desk.curr-code )
    (if v-curr-r-b = {&r-b-base}
      then inkas-pay-desk.tot-base
      else inkas-pay-desk.tot-rubl) ( SUB-TOTAL BY ub.inkas-pay-desk.pay-code )
    (if v-curr-r-b = {&r-b-base}
      then inkas-pay-desk.tot-base
      else inkas-pay-desk.tot-rubl) ( SUB-TOTAL BY ub.inkas-pay-desk.curr-code )
    .
    if first-of( ub.inkas-pay-desk.curr-code ) then
    FIND FIRST ub.currency WHERE
               ub.currency.curr-code = ub.inkas-pay-desk.curr-code NO-LOCK.
    if first-of( ub.inkas-pay-desk.curr-code ) then
    FIND FIRST ub.cash-pay WHERE
              ub.cash-pay.cdpay-code = ub.inkas-pay-desk.pay-code AND
              ub.cash-pay.curr-code = ub.inkas-pay-desk.curr-code NO-LOCK NO-ERROR.
&if "{1}" = "tot" &then
    if last-of( ub.inkas-pay-desk.curr-code ) AND
       ( ACCUM SUB-TOTAL BY ub.inkas-pay-desk.curr-code ub.inkas-pay-desk.tot-base ) <> 0 then do:
      DISPLAY stream PrnLibStream
      ( "/итого по " + (if avail ub.cash-pay then ub.cash-pay.obj-name else "Неопознанная оплата") ) @ benefits.pay-name
      currency.curr-name @ benefits.curr-name
      ( ACCUM SUB-TOTAL BY ub.inkas-pay-desk.curr-code ub.inkas-pay-desk.tot-base ) @ benefits.tot-base
      ( ACCUM SUB-TOTAL BY ub.inkas-pay-desk.curr-code ub.inkas-pay-desk.tot-rubl ) @ benefits.tot-rubl
      with frame ZUM-PayCodes-Tot .
      DOWN stream PrnLibStream 1 with frame ZUM-PayCodes-{1}.
    end.
&else
    if last-of( ub.inkas-pay-desk.curr-code ) AND
       ( ACCUM SUB-TOTAL BY inkas-pay-desk.curr-code
                              (if v-curr-r-b = {&r-b-base}
                               then ub.inkas-pay-desk.tot-base
                               else ub.inkas-pay-desk.tot-rubl)
              ) <> 0 then do:
&if "{1}" = "base" &then
      DISPLAY stream PrnLibStream
      ( "/итого по " + (iF avail ub.cash-pay then ub.cash-pay.obj-name else "Неопознанная оплата") ) @ benefits.pay-name
      ( ACCUM SUB-TOTAL BY inkas-pay-desk.curr-code
                              (if v-curr-r-b = {&r-b-base}
                               then ub.inkas-pay-desk.tot-base
                               else ub.inkas-pay-desk.tot-rubl)
            ) @ benefits.tot-r-b
      with frame ZUM-PayCodes-{1} .
&endif
&if "{1}" = "rubl" &then
      DISPLAY stream PrnLibStream
      ( "/итого по " + (iF avail ub.cash-pay then ub.cash-pay.obj-name else "Неопознанная оплата") ) @ benefits.pay-name
      ( ACCUM SUB-TOTAL BY ub.inkas-pay-desk.curr-code ub.inkas-pay-desk.tot-rubl ) @ benefits.tot-rubl
      with frame ZUM-PayCodes-{1} .
&endif
      DOWN stream PrnLibStream 1 with FRAME ZUM-PayCodes-{1} .
     end.
&endif
  END.
end.

HIDE stream PrnLibStream FRAME BottomFrame .
&if "{1}" = "tot" &then
PUT stream PrnLibStream Line format "X(136)" SKIP(1) .
&else
PUT stream PrnLibStream Line format "X(82)" SKIP(1) .
&endif
if ( ACCUM COUNT obj-list.obj-code ) < 2 then do:
    if ( line-counter( PrnLibStream ) + 9 ) > page-size( PrnLibStream ) then page stream PrnLibStream.
    PUT stream PrnLibStream
    space(10) "Директор _______________" format "X(30)"
    "Старший продавец ______________" format "X(30)" SKIP(2)
    space(10) "Бухгалтер ______________" format "X(30)"
    "Кассир ________________________" format "X(30)" SKIP .
end.
output stream PrnLibStream CLOSE.
/*
assign
g#rep-tblname = ""
g#rep-tblrid = -101
g#rep-updflds = string( "Отчет о выручке|" + str1 ) .
*/
&if "{1}" = "tot" &then
run prn-lib-prn-file in this-procedure (
                                          input parParentProc
                                          ,input 8
                                          ).
&else
run prn-lib-prn-file in this-procedure (
                                          input parParentProc
                                          ,input 0
                                          ).

&endif

/* $Workfile$ e n d */