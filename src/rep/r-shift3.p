block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-shift3.p $
$Archive: rep/r-shift3.p $

печать сменного отчета (ЮКОС лист 3)

Автор: Уханов Дмитрий Юрьевич
Дата создания: 04/12/06
Author: Dmitry Ukhanov
Creation date: 04/12/06

*/

define input parameter parparentproc            as widget-handle           no-undo.
define input parameter p-parent-handle          as handle                  no-undo .
define input parameter p-log-handle             as handle                  no-undo .
define input parameter p-cont-handle            as handle                  no-undo .
define input parameter p-rebh                   as handle                  no-undo .
define input parameter p-report-id              as character               no-undo .
define input parameter p-xsd-file               as character               no-undo .
define input parameter p-log-file-name          as character               no-undo .
define input parameter p-batch                  as integer                 no-undo .
define input parameter p-codex-id               as integer                 no-undo .
define input parameter p-ruleset-id             as integer                 no-undo .
define input parameter p-obj-type               like ub.clients.obj-type   no-undo .
define input parameter p-obj-code               like ub.clients.obj-code   no-undo .
define input parameter p-z-number-list          as character               no-undo .

define input parameter pClassify  as character no-undo.
define input parameter pSortType  as character no-undo.
define input parameter ptog-lavel as logical   no-undo.
define input parameter pvar-lavel as integer   no-undo.
define input parameter p-previous-shift-date as date no-undo .

define variable  vss-revision    AS character NO-UNDO INIT "$Revision: aea5316774be, 0, rls $":U.
define variable  vss-author      AS character NO-UNDO INIT "$Author: expertek $":U.
define variable  vss-date        AS character NO-UNDO INIT "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U.
define variable  vss-workfile    AS character NO-UNDO INIT "$Workfile: r-shift3.p $":U.
define variable  vss-archive     AS character NO-UNDO INIT "$Archive: rep/r-shift3.p $":U.
define variable  vss-description AS character NO-UNDO INIT "$Печать сменного отчета - лист 3 $":U.


{ cmp/trg-def.i }
{ cmp/r-page1.i }
{ cmp/r-pril.i  }
{ rep/r-sym.i   }
{ rep/real-3df.i SHARED treal-3 }
{ rep/real-3df.i " " actreal-3 }
{ rep/icm-3df.i  SHARED }
{ rep/real-3cr.i treal-3 }
{ rep/real-3cr.i actreal-3 }
{ rep/rshiftd1.i t "shared" }
{ gbl/gate-clb.i }
{ str/trdcalib.i }

define shared stream  PrnLibstream.
define variable pol1  as character no-undo .
define variable pol2  as decimal   no-undo .
define variable pol3  as decimal   no-undo .
define variable pol4  as character no-undo .
define variable pol5  as integer   no-undo .
define variable pol6  as character no-undo .
define variable pol7  as decimal   no-undo .
define variable pol8  as decimal   no-undo .
define variable pol9  as character no-undo .
define variable pol10 as decimal   no-undo .
define variable pol11 as decimal   no-undo .
define variable pol12 as decimal   no-undo .
define variable pol13 as decimal   no-undo .
define variable pol6-excel as character no-undo .

define variable line          as character no-undo .
DEFINE VARIABLE areal-is-pay-qnty1 as decimal no-undo.
DEFINE VARIABLE areal-is-pay-netto as decimal no-undo.
DEFINE VARIABLE areal-no-pay-qnty1 as decimal no-undo.
DEFINE VARIABLE areal-no-pay-netto as decimal no-undo.
DEFINE VARIABLE areal-qnty1   as decimal   no-undo.
DEFINE VARIABLE areal-netto   as decimal   no-undo.
DEFINE VARIABLE aincome-qnty1 as decimal   no-undo.
DEFINE VARIABLE aincome-netto as decimal   no-undo.
DEFINE VARIABLE loc-real-ii   as integer   no-undo.
DEFINE VARIABLE curr-real-ii  as integer   no-undo.
DEFINE VARIABLE loc-income-ii as integer   no-undo.
DEFINE VARIABLE jj            as integer   no-undo.
DEFINE VARIABLE loc-jj        as integer   no-undo.
DEFINE VARIABLE main-line     as logical   no-undo.
DEFINE VARIABLE supp-line     as logical   no-undo.
DEFINE VARIABLE pay-line      as logical   no-undo.
DEFINE VARIABLE rc            as recid     no-undo.
DEFINE VARIABLE accum-2       as decimal   no-undo.
DEFINE VARIABLE accum-3       as decimal   no-undo.
DEFINE VARIABLE accum-7       as decimal   no-undo.
DEFINE VARIABLE accum-8       as decimal   no-undo.
DEFINE VARIABLE accum-10      as decimal   no-undo.
DEFINE VARIABLE accum-11      as decimal   no-undo.
DEFINE VARIABLE accum-12      as decimal   no-undo.
DEFINE VARIABLE accum-13      as decimal   no-undo.
DEFINE VARIABLE acii          as integer   no-undo .
define variable v-attr-value  as character no-undo .
define variable v-attr-type   as character no-undo .
define buffer buf_shift-grp     for shift-grpt.
define buffer buf_shift-grp-in  for shift-grp-int.
define buffer buf_shift-grp-out for shift-grp-outt.
define buffer buf_cash-pay      for ub.cash-pay.
{ rep/r-shfth.i proc-def }
{ rep/r-shfth.i r-shift3 }

&scop All-sym12 sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10 sym11 sym12
&scop all-sym-pol ~{&All-sym12} pol1 pol2 pol3 pol4 pol5 pol6 pol7 pol8 pol9 pol10 pol11 pol12 pol13

DEFINE FRAME FRAME-3
  pol1 column-label   "3.1":C32                    FORMAT "x(32)"         space(0)
  sym1 column-label ":" format "x(1)" space(0)
  pol2 column-label   "3.2":C9                     FORMAT "->>>>9.99"     space(0)
  sym2 column-label ":" format "x(1)" space(0)
  pol3 column-label   "3.3":C12                    FORMAT "->>>>>>>9.99"  space(0)
  sym3 column-label ":" format "x(1)" space(0)
  pol4 column-label   "3.4":C20                    FORMAT "x(20)"         space(0)
  sym4 column-label ":" format "x(1)" space(0)
  pol5 column-label   "3.5":C9                     FORMAT ">>>>>>>>9"     space(0)
  sym5 column-label ":" format "x(1)" space(0)
  pol6 column-label   "3.6":C16                    FORMAT "x(16)"         space(0)
  sym6 column-label ":" format "x(1)" space(0)
  pol7 column-label   "3.7":C8                     FORMAT ">>>>>.99"      space(0)
  sym7 column-label ":" format "x(1)" space(0)
  pol8 column-label   "3.8":C11                    FORMAT ">>>>>>>9.99"   space(0)
  sym8 column-label ":" format "x(1)" space(0)
  pol9 column-label   "3.9":C20                    FORMAT "x(20)"         space(0)
  sym9 column-label ":" format "x(1)" space(0)
.
DEFINE FRAME FRAME-3
  pol10 column-label  "3.10":C9                    FORMAT "->>>>9.99"     space(0)
  sym10 column-label ":" format "x(1)" space(0)
  pol11 column-label  "3.11":C12                   FORMAT "->>>>>>>9.99"  space(0)
  sym11 column-label ":" format "x(1)" space(0)
  pol12 column-label  "3.12":C9                    FORMAT "->>>>9.99"     space(0)
  sym12 column-label ":" format "x(1)" space(0)
  pol13 column-label  "3.13":C12                   FORMAT "->>>>>>>9.99"  space(0)
with width {&DOS_CW_2} down stream-io use-text NO-BOX.

/*к этому моменту должна быть уже заполнена таблица treal-3 - все записи с is-pay = yes - оплаченный расход*/
/*заполним таблицу tincom-3 и treal-3 -  в части прочих расходов*/
/*соглашения по умолчанию*/
/*out-name = "Инвентаризации"    cpay-code = -4 ii = ? is-pay = no*/
/*out-name = "Отпуск без ККМ"    cpay-code = -3 ii = ? is-pay = no*/
/*out-name = "Прочий докум.расход"    cpay-code = -1 ii = ? is-pay = no*/


run rep/r-shft3r.p
                (input p-obj-type,
                 input p-obj-code,
                 input X-date-Start,
                 input X-Shift-Start,
                 input X-date-End,
                 input X-Shift-End,
                 input pClassify,
                 input pSorttype,
                 input ptog-lavel,
                 input pvar-lavel,
                 input p-previous-shift-date,
                 input p-batch
                 ) no-error.

FORM HEADER
{&Header-Text3}
with FRAME TopFrame width {&DOS_CW_2} PAGE-Top NO-LABELS NO-BOX .
VIEW STREAM PrnLibstream FRAME TOpFrame .
for each actreal-3:
  delete actreal-3.
end.
/*ЦИКЛ по товарам-топливам*/
FOR EACH t-3 where (pclassify <> "totals":U or t-3.grp-code-sheet = 0) use-index pi:
  assign
  areal-is-pay-qnty1 = 0
  areal-is-pay-netto = 0
  areal-no-pay-qnty1 = 0
  areal-no-pay-netto = 0
  areal-qnty1 = 0
  areal-netto = 0
  aincome-qnty1 = 0
  aincome-netto = 0
  loc-real-ii = 1
  curr-real-ii = 1
  loc-income-ii = 0
  .

  /*чтобы прописать ii для тех у кого ii = ?*/
  FIND LAST treal-3 No-LOCK WHERE
            treal-3.grp-code-sheet = t-3.grp-code-sheet AND
            treal-3.is-pay = yes use-index vi No-ERROR.
  if avail treal-3 then
  assign
  loc-real-ii = treal-3.ii + 1
  curr-real-ii = treal-3.ii + 1
  .
  /*родим записи таблицы treal-3 - подитоги*/
  IF can-find(first treal-3 WHERE
                    treal-3.grp-code-sheet = t-3.grp-code-sheet) then do:
    /*если есть вообще оплаченный расход*/
    FOR EACh  treal-3 where
              treal-3.grp-code-sheet = t-3.grp-code-sheet use-index pi:
      assign
      areal-qnty1 = areal-qnty1 + treal-3.qnty1
      areal-netto = areal-netto + treal-3.netto
      .
      if treal-3.is-pay then
      assign
      areal-is-pay-qnty1 = areal-is-pay-qnty1 + treal-3.qnty1
      areal-is-pay-netto = areal-is-pay-netto + treal-3.netto
      .
      else
      assign
      rc = recid(treal-3)
      curr-real-ii = (if curr-real-ii = loc-real-ii AND /*первый проход*/
                         (loc-real-ii > 1  /*оплаченные были и есть неоплач раз мы здесь*/ OR
                          can-find(first treal-3 No-LOCK WHERE
                                         treal-3.grp-code-sheet = t-3.grp-code-sheet AND
                                         treal-3.is-pay = no AND
                                         recid(treal-3) <> rc)
                          )
                      then (curr-real-ii + 1)
                      else curr-real-ii
                     )
      treal-3.ii = curr-real-ii
      curr-real-ii = curr-real-ii + 1
      areal-no-pay-qnty1 = areal-no-pay-qnty1 + treal-3.qnty1
      areal-no-pay-netto = areal-no-pay-netto + treal-3.netto
      .
    END.
    if curr-real-ii > 2 then do:
      /*treal-3 большей одной */
      /*рожаем запись ИТОГО ОПЛАЧ.РАСХОД*/
      run create-treal-3 (
                          INPUT t-3.grp-code-sheet,
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
      run create-treal-3 (
                          INPUT t-3.grp-code-sheet,
                          INPUT 0,
                          INPUT 0,
                          INPUT areal-no-pay-qnty1,
                          INPUT areal-no-pay-netto,
                          INPUT "ИТОГО ПРОЧ.РАСХОДОВ",
                          INPUT no,
                          INPUT curr-real-ii) no-error.
      curr-real-ii = curr-real-ii + 1.
      run create-treal-3 (
                          INPUT t-3.grp-code-sheet,
                          INPUT 0,
                          INPUT 0,
                          INPUT areal-qnty1,
                          INPUT areal-netto,
                          INPUT "ВСЕГО  РАСХОД", /*пробелы не стирать!*/
                          INPUT ?,
                          INPUT curr-real-ii) no-error.
    END.
    else curr-real-ii = 1.
  END. /*if curr-real-ii > 2*/

  /*родим записи таблицы tincome-3 - итоги*/
  /*если есть вообще оплаченный расход*/
  FOR EACh  tincome-3 where
            tincome-3.grp-code-sheet = t-3.grp-code-sheet use-index vi:
    assign
    aincome-qnty1 = aincome-qnty1 + tincome-3.qnty1
    aincome-netto = aincome-netto + tincome-3.netto
    loc-income-ii = tincome-3.ii
    .
  END.
  if loc-income-ii > 1 then do:
    /*tincome-2 большей одной */
    /*рожаем запись ИТОГО ОПЛАЧ.РАСХОД*/
    run create-tincome-3 (
                        INPUT t-3.grp-code-sheet,
                        INPUT "",
                        INPUT aincome-qnty1,
                        INPUT aincome-netto,
                        INPUT "ИТОГО ПОСТУПЛЕНИЙ",
                        INPUT 0,
                        INPUT no,
                        INPUT (loc-income-ii + 1)) no-error .
    loc-income-ii = loc-income-ii + 1.
  END.
  assign
  t-3.lines = MAX(curr-real-ii, loc-income-ii, 1)
  .
END. /*for each t-3*/
{&putexcel} skip.

/*непосредственно печать*/
FOR EACH t-3 No-LOCK WHERE (pclassify <> "totals":U or t-3.grp-code-sheet = 0)
    break by grp-name:
  DO jj = 1 to t-3.lines :
    assign
    pol1 = ""
    pol2 = 0
    pol3 = 0
    pol4 = ""
    pol5 = 0
    pol6 = ""
    pol7 = 0
    pol8 = 0
    pol9 = ""
    pol10 = 0
    pol11 = 0
    pol12 = 0
    pol13 = 0
    main-line = no
    supp-line = no
    pay-line = no
    .
    IF jj = 1 then do:
      assign
      pol1 = t-3.grp-name
      pol2 = t-3.qnty1-before
      pol3 = t-3.netto-before
      pol12 = t-3.qnty1-after
      pol13 = t-3.netto-after
      main-line = yes
      .
    END.
    FIND FIRST tincome-3 No-LOCK WHERE
               tincome-3.grp-code-sheet = t-3.grp-code-sheet AND
               tincome-3.ii = jj No-ERROR.
    FIND FIRST treal-3 No-LOCK WHERE
               treal-3.grp-code-sheet = t-3.grp-code-sheet AND
               treal-3.ii = jj No-ERROR.
    if p-batch > 0
    and (available tincome-3
    or available treal-3)
    and p-report-id  = "53/2040"
    then do:
      find first buf_shift-grp where
                buf_shift-grp.obj-type = p-obj-type
            and buf_shift-grp.obj-code = p-obj-code
            and buf_shift-grp.shift-date = x-date-end
            and buf_shift-grp.shift-num = x-shift-end
            and buf_shift-grp.grp-code = t-3.grp-code-sheet no-error.
      if not available buf_shift-grp then do:
        create buf_shift-grp.
        assign
        buf_shift-grp.obj-type = p-obj-type
        buf_shift-grp.obj-code = p-obj-code
        buf_shift-grp.shift-date = x-date-end
        buf_shift-grp.shift-num = x-shift-end
        buf_shift-grp.grp-code = t-3.grp-code-sheet
        buf_shift-grp.full-grp-name = t-3.grp-name
        buf_shift-grp.start-qnty = t-3.qnty1-before
        buf_shift-grp.end-qnty = t-3.qnty1-after
        buf_shift-grp.start-sum = t-3.netto-before
        buf_shift-grp.end-sum = t-3.netto-after
        .
        release buf_shift-grp.
      end.
    end.
    IF AVAIl tincome-3 then do:
      /* номер документа из атрибутов */
      { str/tdat-val.i
        tincome-3.doc-code
        {&trdcattr-nids}
        v-attr-value
        v-attr-type
        }
      assign
        pol6 = if v-attr-value = "" or v-attr-value = ?
               then tincome-3.doc-code
               else v-attr-value
        pol6-excel = if v-attr-value = "" or v-attr-value = ?
               then tincome-3.doc-code
               else '="' + v-attr-value + '"'
      .

      assign
      pol4 = tincome-3.supp-name
      pol5 = tincome-3.supp-code
      pol7 = tincome-3.qnty1
      pol8 = tincome-3.netto
      supp-line = yes
      .
      if p-batch > 0
      and tincome-3.supp-code > 0
      and tincome-3.grp-code > 0
      and p-report-id  = "53/2040"
      then do:
        find first buf_shift-grp-in where
                  buf_shift-grp-in.obj-type = p-obj-type
              and buf_shift-grp-in.obj-code = p-obj-code
              and buf_shift-grp-in.shift-date = x-date-end
              and buf_shift-grp-in.shift-num = x-shift-end
              and buf_shift-grp-in.grp-code = tincome-3.grp-code-sheet
              and buf_shift-grp-in.doc-code = tincome-3.doc-code   no-error.
        if not available buf_shift-grp-in then do:
          create buf_shift-grp-in.
          assign
          buf_shift-grp-in.obj-type = p-obj-type
          buf_shift-grp-in.obj-code = p-obj-code
          buf_shift-grp-in.shift-date = x-date-end
          buf_shift-grp-in.shift-num = x-shift-end
          buf_shift-grp-in.grp-code = tincome-3.grp-code-sheet
          buf_shift-grp-in.doc-code = tincome-3.doc-code
          buf_shift-grp-in.cli-type-code = substitute("&1&2", tincome-3.supp-type, tincome-3.supp-code)
          buf_shift-grp-in.cli-name = tincome-3.supp-name
          buf_shift-grp-in.fact-qnty = tincome-3.qnty1
          buf_shift-grp-in.fact-cost-sum = tincome-3.netto
          .
          release buf_shift-grp-in.
        end.
      end. /*if p-batch > 0 */
    END.
    IF AVAIl treal-3 then do:
      if treal-3.cpay-code <> 0 then do:
        FIND FIRST actreal-3 WHERE
                  actreal-3.grp-code-sheet = 0 AND
                  actreal-3.cpay-code = treal-3.cpay-code AND
                  actreal-3.curr-code = treal-3.curr-code AND
                  actreal-3.is-pay = treal-3.is-pay NO-ERROR.
        if not avail actreal-3 then do:
          acii = acii + 1.
          run create-actreal-3 (
                              INPUT 0,
                              INPUT treal-3.cpay-code,
                              INPUT treal-3.curr-code,
                              INPUT treal-3.qnty1,
                              INPUT treal-3.netto,
                              INPUT treal-3.out-name,
                              INPUT treal-3.is-pay,
                              INPUT acii) no-error.
        end.
        else
        assign
        actreal-3.qnty1 = actreal-3.qnty1 + treal-3.qnty1
        actreal-3.netto = actreal-3.netto + treal-3.netto
        .
      end.
      assign
      pol9 = treal-3.out-name
      pol10 = treal-3.qnty1
      pol11 = treal-3.netto
      pay-line = yes
      .
      if p-batch > 0
      and (treal-3.curr-code > 0
      or not (treal-3.curr-code = 0 and treal-3.cpay-code = 0))
      and treal-3.grp-code > 0
      and p-report-id  = "53/2040"
      then do:
        find first buf_shift-grp-out where
                  buf_shift-grp-out.obj-type = p-obj-type
              and buf_shift-grp-out.obj-code = p-obj-code
              and buf_shift-grp-out.shift-date = x-date-end
              and buf_shift-grp-out.shift-num = x-shift-end
              and buf_shift-grp-out.grp-code = treal-3.grp-code-sheet
              and buf_shift-grp-out.pay-code = treal-3.cpay-code
              and buf_shift-grp-out.curr-code = treal-3.curr-code
              no-error.
        if not available buf_shift-grp-out then do:
            find first buf_cash-pay no-lock where
                      buf_cash-pay.cdpay-code = treal-3.cpay-code
                 and  buf_cash-pay.curr-code = treal-3.curr-code no-error.
          create buf_shift-grp-out.
          assign
          buf_shift-grp-out.obj-type = p-obj-type
          buf_shift-grp-out.obj-code = p-obj-code
          buf_shift-grp-out.shift-date = x-date-end
          buf_shift-grp-out.shift-num = x-shift-end
          buf_shift-grp-out.grp-code = treal-3.grp-code-sheet
          buf_shift-grp-out.pay-code = treal-3.cpay-code
          buf_shift-grp-out.curr-code = treal-3.curr-code
          buf_shift-grp-out.out-name = treal-3.out-name
          buf_shift-grp-out.fact-qnty = treal-3.qnty1
          buf_shift-grp-out.fact-sum = treal-3.netto
          buf_shift-grp-out.cp-type = (if available buf_cash-pay
                                        and buf_cash-pay.is-cash
                                        then 1
                                        else 2)
          .
          release buf_shift-grp-out.
        end.
      end. /*if p-batch > 0 */
    END.
    DISPLAY stream PrnLibstream
    pol1
    pol2 when main-line
    pol3 when main-line
    pol4
    pol5 when pol5 <> 0
    pol6
    pol7 when supp-line
    pol8 when supp-line
    pol9
    pol10 when pay-line
    pol11 when pay-line
    pol12 when main-line
    pol13 when main-line
    {&All-sym12}
    with frame frame-3 .
    if jj < t-3.lines then
    DOWN stream PrnLibstream
    with frame frame-3 .
    if main-line then do:
      assign
      accum-2 = accum-2 + pol2
      accum-3 = accum-3 + pol3
      accum-12 = accum-12 + pol12
      accum-13 = accum-13 + pol13
      .
      {&PutExcel}
      pol1 {&tabulation}
      pol2 {&tabulation}
      pol3 {&tabulation}
      .
    end.
    else do:
      {&PutExcel}
      {&tabulation}
      {&tabulation}
      {&tabulation}
      .
    end.
    if supp-line then do:
      if tincome-3.is-fact = yes then
      assign
      accum-7 = accum-7 + pol7
      accum-8 = accum-8 + pol8
      .
      {&putExcel}
      pol4 {&tabulation}
      (if pol5 <> 0 then string(pol5) else "") {&tabulation}
      pol6-excel {&tabulation}
      pol7 {&tabulation}
      pol8 {&tabulation}
      .
    end.
    else do:
      {&PutExcel}
      {&tabulation}
      {&tabulation}
      {&tabulation}
      {&tabulation}
      {&tabulation}
      .
    end.
    if pay-line then do:
      if treal-3.cpay-code <> 0 then
      assign
      accum-10 = accum-10 + pol10
      accum-11 = accum-11 + pol11
      .
      {&PutExcel}
      pol9 {&tabulation}
      pol10 {&tabulation}
      pol11 {&tabulation}
      .
    end.
    else do:
      {&PutExcel}
      {&tabulation}
      {&tabulation}
      {&tabulation}
      .
    end.
    if main-line then do:
      {&putexcel}
      pol12 {&tabulation}
      pol13
      skip.
    end.
    else do:
      {&putexcel}
      {&tabulation}
      skip.
    end.
 END.
  DOWN 1 stream PrnLibstream
  with frame frame-3 .
  {&PutExcel}
  fill({&tabulation}, 12)
  skip.
  if pclassify <> "totals":U and last(t-3.grp-name) then do:
     /* печатаем итоги*/
    assign
    pol1 = "ИТОГО ПО ВСЕМ ГРУППАМ"
    pol2 = accum-2
    pol3 = accum-3
    pol7 = accum-7
    pol8 = accum-8
    pol9 = "ИТОГО РАСХОД"
    pol10 = accum-10
    pol11 = accum-11
    pol12 = accum-12
    pol13 = accum-13
    .
    run on-same-page in this-procedure ({&bottom-height} + 2 + acii +
                                        (if acii = 0 then 0 else 1) +
                                        (if can-find(first actreal-3 where
                                                           actreal-3.is-pay = yes) then 1 else 0
                                        ) +
                                        (if can-find(first actreal-3 where
                                                            actreal-3.is-pay = no) then 1 else 0
                                        )
                                       ) .
    UNDERLINE stream PrnLibstream
    {&ALL-sym-pol}
    with frame frame-3.
    DISPLAY stream PrnLibstream
    pol1
    pol2
    pol3
    pol7
    pol8
    pol9
    pol10
    pol11
    pol12
    pol13
    {&All-sym12}
    with frame frame-3.
    {&PutExcel}
    pol1 {&tabulation}
    pol2 {&tabulation}
    pol3 {&tabulation}
    {&tabulation}
    {&tabulation}
    {&tabulation}
    pol7 {&tabulation}
    pol8 {&tabulation}
    pol9 {&tabulation}
    pol10 {&tabulation}
    pol11 {&tabulation}
    pol12 {&tabulation}
    pol13 {&tabulation}
    skip.
    DOWN 1 stream PrnLibstream
    with frame frame-3 .
    if can-find(first actreal-3 No-LOCK) then do:
      pol9 = "     в том числе:".
      DISPLAY stream PrnLibstream
      pol9
      {&All-sym12}
      with frame frame-3.
      {&PutExcel}
      {&tabulation}
      {&tabulation}
      {&tabulation}
      {&tabulation}
      {&tabulation}
      {&tabulation}
      {&tabulation}
      {&tabulation}
      pol9 {&tabulation}
      {&tabulation}
      {&tabulation}
      {&tabulation}
      {&tabulation}
      skip.
      DOWN 1 stream PrnLibstream
      with frame frame-3 .
      assign
      areal-is-pay-qnty1 = 0
      areal-is-pay-netto = 0
      areal-no-pay-qnty1 = 0
      areal-no-pay-netto = 0
      .
      FOR EACH actreal-3 No-LOCK
      BREAK
      BY actreal-3.grp-code-sheet
      By actreal-3.is-pay descending
      BY actreal-3.cpay-code descending
      BY actreal-3.curr-code:

        if actreal-3.is-pay = yes then
        assign
        areal-is-pay-qnty1 = areal-is-pay-qnty1 + actreal-3.qnty1
        areal-is-pay-netto = areal-is-pay-netto + actreal-3.netto
        .
        else
        assign
        areal-no-pay-qnty1 = areal-no-pay-qnty1 + actreal-3.qnty1
        areal-no-pay-netto = areal-no-pay-netto + actreal-3.netto
        .
        assign
        pol9 = actreal-3.out-name
        pol10 = actreal-3.qnty1
        pol11 = actreal-3.netto
        .
        DISPLAY stream PrnLibstream
        pol9
        pol10
        pol11
        {&All-sym12}
        with frame frame-3.
        {&PutExcel}
        {&tabulation}
        {&tabulation}
        {&tabulation}
        {&tabulation}
        {&tabulation}
        {&tabulation}
        {&tabulation}
        {&tabulation}
        pol9 {&tabulation}
        pol10 {&tabulation}
        pol11 {&tabulation}
        {&tabulation}
        {&tabulation}
        skip.
        DOWN 1 stream PrnLibstream
        with frame frame-3 .
        {&PutExcel}
        fill({&tabulation}, 12)
        skip.
       if last-of(actreal-3.is-pay) /*and actreal-3.is-pay <> ? */ then do:
          if actreal-3.is-pay = yes then
          assign
          pol9 = "ИТОГО ОПЛАЧ.РАСХОД"
          pol10 = areal-is-pay-qnty1
          pol11 = areal-is-pay-netto
          .
          else
          assign
          pol9 = "ИТОГО ПРОЧ.РАСХОД"
          pol10 = areal-no-pay-qnty1
          pol11 = areal-no-pay-netto
          .
          DISPLAY stream PrnLibstream
          pol9
          pol10
          pol11
          {&All-sym12}
          with frame frame-3.
          {&PutExcel}
          {&tabulation}
          {&tabulation}
          {&tabulation}
          {&tabulation}
          {&tabulation}
          {&tabulation}
          {&tabulation}
          {&tabulation}
          pol9 {&tabulation}
          pol10 {&tabulation}
          pol11 {&tabulation}
          {&tabulation}
          {&tabulation}
          skip.
          DOWN 1 stream PrnLibstream
          with frame frame-3 .
          {&PutExcel}
          fill({&tabulation}, 12)
          skip.
        end. /*lasit-of(ctreal-2.is-pay) and is-pay <> ?*/
      END. /*FOR EACH actreal-3*/
    end. /* can-find(first actreal-3 No-LOCK) */
  end.
END.

PROCEDURE create-tincome-3.
DEFINE INPUT PARAMETER pgrp-code-sheet like ub.gds-grp.node-code no-undo.
DEFINE INPUT PARAMETER pdoc-code like ub.trn-doc.doc-code no-undo.
DEFINE INPUT PARAMETER pqnty1 as decimal no-undo.
DEFINE INPUT PARAMETER pnetto as decimal no-undo.
DEFINE INPUT PARAMETER psupp-name as character no-undo.
DEFINE INPUT PARAMETER psupp-code like ub.clients.obj-code no-undo.
DEFINE INPUT PARAMETER pis-fact as logical no-undo.
DEFINE INPUT PARAMETER pii as integer no-undo.

_main:
DO ON ERROR UNDO _main, return error:
    create tincome-3.
    assign
    tincome-3.grp-code-sheet = pgrp-code-sheet
    tincome-3.doc-code = pdoc-code
    tincome-3.qnty1  =  pqnty1
    tincome-3.netto  = pnetto
    tincome-3.supp-code = psupp-code
    tincome-3.supp-name = psupp-name
    tincome-3.is-fact = pis-fact
    tincome-3.ii = pii
    no-error
    .
    if error-status:error then undo _main, return error.
END.
END PROCEDURE.
