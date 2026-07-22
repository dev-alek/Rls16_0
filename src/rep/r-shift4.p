block-level on error undo, throw.
/*

$Revision: ac2de8611dbf, 1057, rls $
$Author: EShklyar $
$Date: Fri Oct 06 18:33:18 2017 +0300 $
$Workfile: r-shift4.p $
$Archive: rep/r-shift4.p $

печать сменного отчета (ЮКОС лист 4)

Автор: Уханов Дмитрий Юрьевич
Дата создания: 04/12/06
Author: Dmitry Ukhanov
Creation date: 04/12/06

*/

define input parameter parparentproc         as   widget-handle       no-undo.
define input parameter p-parent-handle            as handle    no-undo .
define input parameter p-log-handle               as handle    no-undo .
define input parameter p-cont-handle              as handle    no-undo .
define input parameter p-rebh                     as handle    no-undo .
define input parameter p-report-id                as character no-undo .
define input parameter p-xsd-file                 as character no-undo .
define input parameter p-log-file-name            as character no-undo .
define input parameter p-batch                    as integer   no-undo .
define input parameter p-codex-id                 as integer   no-undo .
define input parameter p-ruleset-id               as integer   no-undo .
define input parameter p-obj-type            like ub.clients.obj-type no-undo.
define input parameter p-obj-code            like ub.clients.obj-code no-undo.
define input parameter p-z-number-list       as   character           no-undo.
define input parameter p-previous-shift-date as   date                no-undo.

DEF VAR vss-revision    AS CHAR NO-UNDO INIT "$Revision: ac2de8611dbf, 1057, rls $":U.
DEF VAR vss-author      AS CHAR NO-UNDO INIT "$Author: EShklyar $":U.
DEF VAR vss-date        AS CHAR NO-UNDO INIT "$Date: Fri Oct 06 18:33:18 2017 +0300 $":U.
DEF VAR vss-workfile    AS CHAR NO-UNDO INIT "$Workfile: r-shift4.p $":U.
DEF VAR vss-archive     AS CHAR NO-UNDO INIT "$Archive: rep/r-shift4.p $":U.
DEF VAR vss-description AS CHAR NO-UNDO INIT "$Печать сменного отчета - лист 4 $":U.


{ cmp/trg-def.i }
{ cmp/r-page1.i }
{ cmp/r-pril.i }
{ rep/r-sym.i }
{ rep/real-4df.i SHARED treal-4 }
{ rep/real-4df.i " " actreal-4 }
{ rep/icm-4df.i  "NEW SHARED" }
{ rep/real-4cr.i treal-4 }
{ rep/real-4cr.i actreal-4 }
{ rep/mat-4df.i "NEW SHARED" }

define shared stream  PrnLibstream.
define variable pol1 as character no-undo .
define variable pol2 as integer no-undo .
define variable pol3 as decimal no-undo .
define variable pol4 as character no-undo .
define variable pol5 as decimal no-undo .
define variable pol6 as decimal no-undo .

define variable line as character no-undo .
DEFINE VARIABLE  areal-is-pay-qnty1 as decimal no-undo.
DEFINE VARIABLE  areal-is-pay-netto as decimal no-undo.
DEFINE VARIABLE  areal-no-pay-qnty1 as decimal no-undo.
DEFINE VARIABLE  areal-no-pay-netto as decimal no-undo.
DEFINE VARIABLE  areal-qnty1 as decimal no-undo.
DEFINE VARIABLE  areal-netto as decimal no-undo.
DEFINE VARIABLE  a-qnty1 as decimal no-undo.
DEFINE VARIABLE  a-netto as decimal no-undo.
DEFINE VARIABLE  loc-real-ii as integer no-undo.
DEFINE VARIABLE  curr-real-ii as integer no-undo.
DEFINE VARIABLE  jj as integer no-undo.
DEFINE VARIABLE  loc-jj as integer no-undo.
DEFINE VARIABLE main-line as logical no-undo.
DEFINE VARIABLE mat-line as logical no-undo.
DEFINE VARIABLE pay-line as logical no-undo.
DEFINE VARIABLE a-line as logical no-undo.
/*количество строк подлежащее выводу*/
DEFINE VARIABLE max-line as integer no-undo.
/*количество строк по услугам подлежащее выводу*/
DEFINE VARIABLE max-real as integer no-undo.
DEFINE VARIABLE rc as recid no-undo.
DEFINE VARIABLE acii as integer no-undo .
{ rep/r-shfth.i proc-def }
{ rep/r-shfth.i r-shift4 }

&scop display-message ~
   if p-batch > 0 then do: ~
     run write-log-and-file in p-log-handle ( ~
                input 1                            ~
              , input p-log-file-name                ~
              , input 1                            ~
              , input ~{&my-message}~). ~
   end. ~
   else do: ~
      run write-to-log in p-log-handle ( input ~{&my-message~}). ~
   end


&scop All-sym5 sym1 sym2 sym3 sym4 sym5

DEFINE FRAME FRAME-4
  pol1  column-label "4.1":C32                                FORMAT "x(32)"       space(0)
  sym1 column-label ":" format "x(1)" space(0)
  pol2 column-label   "4.2":C9                                FORMAT  ">>>>>>>>9"  space(0)
  sym2 column-label ":" format "x(1)" space(0)
  pol3 column-label    "4.3":C8                               FORMAT  ">>>>9.99"  space(0)
  sym3 column-label ":" format "x(1)" space(0)
  pol4 column-label     "4.4":C19                             FORMAT "x(19)"    space(0)
  sym4 column-label ":" format "x(1)" space(0)
  pol5 column-label "4.5":C8                                  FORMAT "->>>>>>>9"          space(0)
  sym5 column-label ":" format "x(1)" space(0)
  pol6 column-label     "4.6":C14                             FORMAT "->>>,>>>,>>9.99"  space(0)
with width {&DOS_CW_2} down stream-io use-text NO-BOX.
/* строки отчета  */

/*к этому моменту должна быть уже заполнена таблица treal-4 - все записи с is-pay = yes - оплаченный расход*/
/*заполним таблицу treal-4 -  в части прочих расходов*/
/*соглашения по умолчанию*/
/*out-name = "Прочий докум.расход"    cpay-code = -1 ii = ? is-pay = no*/

run rep/r-shft4r.p
                (input p-obj-type,
                 input p-obj-code,
                 input X-date-Start,
                 input X-Shift-Start,
                 input X-date-End,
                 input X-Shift-End,
input p-previous-shift-date
                 ) no-error.

FORM HEADER
{&Header-Text4}
with FRAME TopFrame width {&DOS_CW_2} PAGE-Top NO-LABELS NO-BOX .
VIEW STREAM PrnLibstream FRAME TOpFrame .

for each actreal-4:
  delete actreal-4.
end.

/*цикл по услугам*/
FOR EACH t-4 use-index pi:
  assign
  areal-is-pay-qnty1 = 0
  areal-is-pay-netto = 0
  areal-no-pay-qnty1 = 0
  areal-no-pay-netto = 0
  areal-qnty1 = 0
  areal-netto = 0
  loc-real-ii = 1
  curr-real-ii = 1
  .

  /*чтобы прописать ii для тех у кого ii = ?*/
  FIND LAST treal-4 No-LOCK WHERE
            treal-4.gds-code = t-4.gds-code AND
            treal-4.is-pay = yes use-index vi No-ERROR.
  if avail treal-4 then
  assign
  loc-real-ii = treal-4.ii + 1
  curr-real-ii = treal-4.ii + 1
  .
  /*родим записи таблицы treal-4 - подитоги*/
  IF can-find(first treal-4 WHERE
                    treal-4.gds-code = t-4.gds-code) then do:
    /*если есть вообще оплаченный расход*/
    FOR EACh  treal-4 where
              treal-4.gds-code = t-4.gds-code use-index pi:
      assign
      areal-qnty1 = areal-qnty1 + treal-4.qnty1
      areal-netto = areal-netto + treal-4.netto
      .
      if treal-4.is-pay then
      assign
      areal-is-pay-qnty1 = areal-is-pay-qnty1 + treal-4.qnty1
      areal-is-pay-netto = areal-is-pay-netto + treal-4.netto
      .
     else
      assign
      rc = recid(treal-4)
      curr-real-ii = (if curr-real-ii = loc-real-ii AND /*первый проход*/
                         (loc-real-ii > 1  /*оплаченные были и есть неоплач раз мы здесь*/ OR
                          can-find(first treal-4 No-LOCK WHERE
                                         treal-4.gds-code = t-4.gds-code AND
                                         treal-4.is-pay = no AND
                                         recid(treal-4) <> rc)
                          )
                      then (curr-real-ii + 1)
                      else curr-real-ii
                     )
      treal-4.ii = curr-real-ii
      curr-real-ii = curr-real-ii + 1
      areal-no-pay-qnty1 = areal-no-pay-qnty1 + treal-4.qnty1
      areal-no-pay-netto = areal-no-pay-netto + treal-4.netto
      .
    END.
    if curr-real-ii > 2 then do:
      /*treal-4 большей одной -просто счетчик еще раз перевелся*/
      /*рожаем запись ИТОГО ОПЛАЧ.РАСХОД*/
      run create-treal-4 (
                          INPUT t-4.gds-code,
                          INPUT 0,
                          INPUT 0,
                          INPUT areal-is-pay-qnty1,
                          INPUT areal-is-pay-netto,
                          INPUT "ИТОГО ОПЛАЧ.РАСХОД",
                          INPUT yes,
                          INPUT loc-real-ii) no-error.
      /*рожаем запись ИТОГО ПРОЧ.РАСХОДОВ*/
      /*если не было прочих расходов - переведем счетчик*/
      if loc-real-ii = curr-real-ii then
      curr-real-ii = curr-real-ii + 1.
      run create-treal-4 (
                          INPUT t-4.gds-code,
                          INPUT 0,
                          INPUT 0,
                          INPUT areal-no-pay-qnty1,
                          INPUT areal-no-pay-netto,
                          INPUT "ИТОГО ПРОЧ.РАСХОДОВ",
                          INPUT no,
                          INPUT curr-real-ii) no-error.
      curr-real-ii = curr-real-ii + 1.
      run create-treal-4 (
                          INPUT t-4.gds-code,
                          INPUT 0,
                          INPUT 0,
                          INPUT areal-qnty1,
                          INPUT areal-netto,
                          INPUT "ВСЕГО  РАСХОД",  /*пробелы не стирать!*/
                          INPUT ?,
                          INPUT curr-real-ii) no-error.
    END.
  END. /*if curr-real-ii > 2*/
  assign
  t-4.lines = MAX(curr-real-ii, 1)
  .
END. /*FOR EACH t-4*/


{&putexcel} skip.

FOR EACH t-4 No-LOCK,
    EACH treal-4 No-LOCK WHERE
         treal-4.gds-code = t-4.gds-code
   BREAK BY treal-4.gds-code
         BY treal-4.is-pay descending
         BY treal-4.ii:
    assign
    pol1 = ""
    pol2 = 0
    pol3 = 0
    pol4 = ""
    pol5 = 0
    pol6 = 0
    main-line = no
    pay-line = no
    .

   IF FIRST-OF(treal-4.gds-code) then do:
      assign
      pol1 = t-4.gds-name
      pol2 = t-4.main-code
      pol3 = t-4.last-price
      main-line = yes

      .
      {&PutExcel}
      pol1 {&tabulation}
      pol2 {&tabulation}
      pol3 {&tabulation}
      .
   END.
   ELSE
    {&PutExcel}
    {&tabulation}
    {&tabulation}
    {&tabulation}
    .
   assign
   pol4 = treal-4.out-name
   pol5 = treal-4.qnty1
   pol6 = treal-4.netto
   .
   if treal-4.discnt-type = -99 then do:
	assign
      a-netto = a-netto + treal-4.netto
      a-qnty1 = a-qnty1 + treal-4.qnty1
	.
    end. 	
   if treal-4.cpay-code <> 0 then dO:
    /*создадим записи по подитогам по типам оплат*/
    FIND FIRST actreal-4 WHERE
                  actreal-4.gds-code = 0 AND
                  actreal-4.cpay-code = treal-4.cpay-code AND
                  actreal-4.curr-code = treal-4.curr-code AND
                  actreal-4.is-pay = treal-4.is-pay NO-ERROR.
        if not avail actreal-4 then do:
          acii = acii + 1.
          run create-actreal-4 (
                              INPUT 0,
                              INPUT treal-4.cpay-code,
                              INPUT treal-4.curr-code,
                              INPUT treal-4.qnty1,
                              INPUT treal-4.netto,
                              INPUT treal-4.out-name,
                              INPUT treal-4.is-pay,
                              INPUT acii) no-error.
        end.
        else
        assign
        actreal-4.qnty1 = actreal-4.qnty1 + treal-4.qnty1
        actreal-4.netto = actreal-4.netto + treal-4.netto
        .
   end.
   DISPLAY stream PrnLibstream
   pol1 when main-line
   pol2 when main-line
   pol3 when main-line
   pol4
   pol5
   pol6
   {&all-sym5}
   WITH FRAME FRAME-4.
   DOWN STREAM PrnLibstream
   WITH FRAME FRAME-4.
   {&PutExcel}
    pol4 {&tabulation}
    pol5 {&tabulation}
    pol6
    skip.
    IF LAST(treal-4.gds-code) then do:
      run on-same-page in this-procedure ({&bottom-height} + 2 + acii +
                                          (if acii = 0 then 0 else 1) +
                                          (if can-find(first actreal-4 where
                                                             actreal-4.is-pay = yes) then 1 else 0
                                          ) +
                                          (if can-find(first actreal-4 where
                                                              actreal-4.is-pay = no) then 1 else 0
                                          )
                                         ) .
      DOWN STREAM PrnLibstream
      WITH FRAME FRAME-4.
      assign
      pol1 = "ВСЕГО РЕАЛИЗОВАНО УСЛУГ  :"
      pol5 = a-qnty1
      pol6 = a-netto
      .
      DISPLAY stream PrnLibstream
      pol1
      pol5
      pol6
      {&all-sym5}
      WITH FRAME FRAME-4.
      {&PutExcel}
      skip.
      {&PutExcel}
      pol1 {&tabulation}
      {&tabulation}
      {&tabulation}
      {&tabulation}
      pol5 {&tabulation}
      pol6
      skip.
      if can-find(first actreal-4) then do:
        pol4 = "     в том числе:".
        DISPLAY stream PrnLibstream
        pol4
        {&all-sym5}
        with frame frame-4.
        {&PutExcel}
        {&tabulation}
        {&tabulation}
        {&tabulation}
        pol4 {&tabulation}
        {&tabulation}
        skip.
        DOWN 1 stream PrnLibstream
        with frame frame-4 .
        assign
        areal-is-pay-qnty1 = 0
        areal-is-pay-netto = 0
        areal-no-pay-qnty1 = 0
        areal-no-pay-netto = 0
        .
RELEASE actreal-4 no-error.
        FOR EACH actreal-4 No-LOCK
        BREAK
        BY actreal-4.gds-code
        By actreal-4.is-pay descending
        BY actreal-4.cpay-code descending
        BY actreal-4.curr-code:

          if actreal-4.is-pay = yes then
          assign
          areal-is-pay-qnty1 = areal-is-pay-qnty1 + actreal-4.qnty1
          areal-is-pay-netto = areal-is-pay-netto + actreal-4.netto
          .
          else
          assign
          areal-no-pay-qnty1 = areal-no-pay-qnty1 + actreal-4.qnty1
          areal-no-pay-netto = areal-no-pay-netto + actreal-4.netto
          .
          assign
          pol4 = actreal-4.out-name
          pol5 = actreal-4.qnty1
          pol6 = actreal-4.netto
          .
          DISPLAY stream PrnLibstream
          pol4
          pol5
          pol6
          {&All-sym5}
          with frame frame-4.
          {&PutExcel}
          {&tabulation}
          {&tabulation}
          {&tabulation}
          pol4 {&tabulation}
          pol5 {&tabulation}
          pol6 skip.
          DOWN 1 stream PrnLibstream
          with frame frame-4 .
        if last-of(actreal-4.is-pay) /*and actreal-4.is-pay <> ? */ then do:
            if actreal-4.is-pay = yes then
            assign
            pol4 = "ИТОГО ОПЛАЧ.РАСХОД"
            pol5 = areal-is-pay-qnty1
            pol6 = areal-is-pay-netto
            .
            else
            assign
            pol4 = "ИТОГО ПРОЧ.РАСХОД"
            pol5 = areal-no-pay-qnty1
            pol6 = areal-no-pay-netto
            .
            DISPLAY stream PrnLibstream
            pol4
            pol5
            pol6
            {&All-sym5}
            with frame frame-4.
            {&PutExcel}
            {&tabulation}
            {&tabulation}
            {&tabulation}
            pol4 {&tabulation}
            pol5 {&tabulation}
            pol6 skip.
            DOWN 1 stream PrnLibstream
            with frame frame-4 .
          end. /*lasit-of(ctreal-4.is-pay) and is-pay <> ?*/
        END. /*FOR EACH actreal-4*/
      end.
   end. /*IF LAST(treal-4.gds-code) */
END.
