block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-specsr.p $
$Archive: rep/r-specsr.p $

Печать Приложение к документу по серийным номерам

Автор: Демин Алексей Сергеевич
Дата создания: 03/27/06
Author: Alexey Demin
Creation date: 03/27/06

*/

define input parameter parparentproc        as widget-handle    no-undo.
define input parameter rec_id               as recid            no-undo.
define input parameter type-doc             as character        no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-specsr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-specsr.p $":U .
define variable vss-description as character no-undo init " Печать Приложение к документу по серийным номерам   ".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/r-pril.i   }
{ gbl/prn-lib.i  }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }

define variable sym1 as char init ":" no-undo.
define variable sym2 as char init ":" no-undo.
define variable sym3 as char init ":" no-undo.
define variable sym4 as char init ":" no-undo.

def buffer cli-store for clients.
def buffer Our_Host for clients.
define variable Line                   as      char    no-undo.
define variable Lines_Counter   as      integer                 no-undo.

/*define variable i   as      integer                 no-undo.*/

if type-doc = {&cash-desk} then do:
  FIND chk-doc WHERE recid( chk-doc ) = rec_id  NO-LOCK.
  &scop receipt-code string(chk-doc.chk-type)
        if lookup(string(chk-doc.chk-type), {&no-sale-receipt-codes}) > 0 then do:
           message
           substitute("Нельзя напечатать данный документ по чекаи типа &1", {&receipt-name})
           view-as alert-box error .
           undo, return error .
        end.

  if chk-doc.obj-type = {&shop} then do:
    FIND shop WHERE shop.obj-code = chk-doc.obj-code NO-LOCK.
    FIND Our_Host WHERE Our_Host.obj-type = {&cmp}
                                            AND Our_Host.obj-code = shop.host-code NO-LOCK.
  end.
  else do:
    FIND store WHERE store.obj-code = chk-doc.obj-code NO-LOCK.
    FIND Our_Host WHERE Our_Host.obj-type = {&cmp}
                                            AND Our_Host.obj-code = store.host-code NO-LOCK.
  end.
end.
else do:
  FIND trn-doc WHERE recid( trn-doc ) = rec_id  NO-LOCK.
  FIND Our_Host WHERE Our_Host.obj-type = {&cmp}
                                          AND Our_Host.obj-code = trn-doc.host-code NO-LOCK.
end.

DEFINE FRAME parts-print
sym1 column-label ":" format "X(1)"
Lines_Counter COLUMN-LABEL "N п/п" format ">>>>9"
sym2 column-label ":" format "X(1)"
goods.gds-name COLUMN-LABEL "Наименование" format "X(93)"
sym3 column-label ":" format "X(1)"
parts.part-code COLUMN-LABEL "Серийный номер" format "X(27)"
sym4 column-label ":" format "X(1)"
HEADER
"Страница " AT 120 PAGE-NUMBER( PrnLibStream ) AT 130 FORMAT ">>9" SKIP
Line format "X(135)" AT 1
with width {&DOS_CW} down stream-io.

if session:set-wait-state("compiler") then.
Line = fill("-", 200).
assign Lines_Counter = 1.

run prn-lib-open-stream  in this-procedure (
                                             input parParentProc
                                            ,input {&CS_PS}
                                            ,input yes /*p-is-stream*/
                                            ,input no /*p-append*/
                                            ).

FORM with FRAME parts-print .

FORM HEADER
Line format "X(135)" AT 1 SKIP
"Продолжение - на следующей странице" AT 30 SKIP
with FRAME BottomFrame width {&A4_CW} PAGE-BOTTOM NO-LABELS NO-BOX .
VIEW STREAM PrnLibStream FRAME BottomFrame .

CASE type-doc:
    WHEN {&cash-desk} THEN  do:
      FIND cli-store WHERE cli-store.obj-type = chk-doc.obj-type AND cli-store.obj-code = chk-doc.obj-code NO-LOCK.
      PUT STREAM PrnLibStream "Поставщик : " AT 10
          string( trim( Our_Host.obj-name ) + ", " + trim( cli-store.obj-name ) ) format "X(100)" SKIP(1).
      PUT STREAM PrnLibStream "ПРИЛОЖЕНИЕ К КАССОВОМУ ЧЕКУ Nr "
          AT 37 format "X(37)" string( chk-doc.chk-num ) format "X(10)" "  от  "
          chk-doc.chk-date format "99.99.9999" SKIP(1).
      FIND dis-card WHERE dis-card.d-card = chk-doc.d-card NO-LOCK .
      FIND clients WHERE clients.obj-type = dis-card.cli-type AND
                                          clients.obj-code = dis-card.cli-code NO-LOCK .
      PUT STREAM PrnLibStream "Получатель : " AT 9 clients.obj-name format "X(50)" SKIP(1).
    end.
    WHEN {&expense} THEN  do:
      FIND cli-store WHERE cli-store.obj-type = trn-doc.obj-type AND cli-store.obj-code = trn-doc.obj-code NO-LOCK.
      PUT STREAM PrnLibStream "Поставщик : " AT 10
          string( trim( Our_Host.obj-name ) + ", " + trim( cli-store.obj-name ) ) format "X(100)" SKIP(1).
      PUT STREAM PrnLibStream "ПРИЛОЖЕНИЕ К РАСХОДНОЙ НАКЛАДНОЙ Nr "
          AT 37 format "X(37)" trn-doc.doc-code format "X(10)" "  от  "
          trn-doc.doc-date format "99.99.9999" SKIP(1).
      FIND clients WHERE clients.obj-type = trn-doc.cli-type AND clients.obj-code = trn-doc.cli-code NO-LOCK.
      PUT STREAM PrnLibStream "Получатель : " AT 9 clients.obj-name format "X(50)" SKIP(1).
    end.
    WHEN {&income} THEN do:
      FIND clients WHERE clients.obj-type = trn-doc.cli-type AND clients.obj-code = trn-doc.cli-code NO-LOCK.
      PUT STREAM PrnLibStream "Поставщик : " AT 10 clients.obj-name format "X(50)" SKIP(1).
      PUT STREAM PrnLibStream "ПРИЛОЖЕНИЕ К ПРИХОДНОЙ НАКЛАДНОЙ Nr "
          AT 37 format "X(37)" trn-doc.doc-code format "X(10)" "  от  "
          trn-doc.doc-date format "99.99.9999" SKIP(1).
      FIND clients WHERE clients.obj-type = {&cmp} AND clients.obj-code = Our_Host.obj-code NO-LOCK.
      FIND cli-store WHERE cli-store.obj-type = trn-doc.obj-type AND cli-store.obj-code = trn-doc.obj-code NO-LOCK.
      PUT STREAM PrnLibStream "Получатель : " AT 9
          string( trim( Our_Host.obj-name ) + ", " + trim( cli-store.obj-name ) ) format "X(100)" SKIP(1).
    end.
END CASE.

CASE clients.obj-type :
    WHEN {&cmp} THEN do:
      FIND firm WHERE firm.firm-code = clients.obj-code NO-LOCK.
      PUT STREAM PrnLibStream
      "Основание :  Лицензия " AT 10 firm.phone1-note format "X(100)" SKIP
      "выдана " AT 23 firm.e-mail format "X(100)" SKIP(1) .
    end.
    WHEN {&prs} THEN do:
        FIND person WHERE person.psn-code = clients.obj-code NO-LOCK.
        PUT STREAM PrnLibStream "Адрес : " AT 14
        trim( string( trim( person.city ) + " " + trim( person.address ) ) ) format "X(100)" SKIP(1)
        "Основание :  Лицензия " AT 10 person.phone1-note format "X(100)" SKIP
        "выдана " AT 23 person.e-mail format "X(100)" SKIP(1) .
    end.
END CASE.

if type-doc = {&cash-desk} then do:
  FOR EACH chk-gds WHERE chk-gds.doc-code = chk-doc.doc-code NO-LOCK :
    FIND bar-code WHERE bar-code.b-code = chk-gds.b-code NO-LOCK NO-ERROR.
    IF AVAIL bar-code then do:
      FIND goods WHERE goods.gds-code = bar-code.gds-code  NO-LOCK .
      FIND units WHERE units.unit-name = goods.unit-base NO-LOCK.
      if LOOKUP({&serial}, units.type) = 0 then  NEXT.
    end.
    DISPLAY STREAM PrnLibStream
    sym1 Lines_Counter
    sym2 if avail bar-code then goods.gds-name else "" @ goods.gds-name
    sym3 if avail bar-code then bar-code.part-code else "" @ parts.part-code
    sym4
    with FRAME parts-print .
    DOWN STREAM PrnLibStream 1 with FRAME parts-print .
    assign
    Lines_Counter = Lines_Counter + 1 .
    .
  END.
end.
else do:
  FOR EACH doc-line WHERE
          doc-line.doc-code = trn-doc.doc-code NO-LOCK
  BY doc-line.artic:
    FIND goods WHERE goods.prod-type = doc-line.prod-type AND
                                      goods.prod-code = doc-line.prod-code AND
                                      goods.artic = doc-line.artic NO-LOCK .
    FIND units WHERE units.unit-name = goods.unit-base NO-LOCK.
    if LOOKUP({&serial}, units.type) = 0 then
        NEXT.
    FOR EACH parts WHERE
             parts.obj-type = cli-store.obj-type
        AND parts.obj-code = cli-store.obj-code
        AND parts.artic = doc-line.artic
        AND parts.prod-type = doc-line.prod-type
        AND parts.prod-code = doc-line.prod-code
        AND parts.out-code = trn-doc.doc-code
    NO-LOCK BY parts.part-code:
      DISPLAY STREAM PrnLibStream
      sym1 Lines_Counter
      sym2 goods.gds-name
      sym3 parts.part-code
      sym4
      with FRAME parts-print .
      DOWN STREAM PrnLibStream 1 with FRAME parts-print .
      assign
      Lines_Counter = Lines_Counter + 1 .
      .
    END.
  END.
end.

PUT STREAM PrnLibStream Line format "X(135)" SKIP(1) .
if type-doc <> {&income} then
PUT STREAM PrnLibStream
string( "Товар технически исправен, не имеет повреждений, " +
                                                          "укомплектован полностью, имеет надлежащий вид." ) format "X(135)" SKIP(1) .
PUT STREAM PrnLibStream
"Поставщик :" AT 15 "Получатель :" AT 95 SKIP(1)
"___________" AT 15 "____________" AT 95 SKIP.


HIDE STREAM PrnLibStream FRAME BottomFrame .

output STREAM PrnLibStream CLOSE.

if session:set-wait-state("") then.
define variable Log-Res as log no-undo .

{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_waybills-to-file_print':U
  {&cntxt-firm}
  Our_Host.obj-code
  '':U
  0
  0
  0
  0
  false
  Log-Res
}

if type-doc = {&cash-desk} then DO:
  if Log-Res then do:
     run prn-lib-prn-file in this-procedure (
                                          input parParentProc
                                          ,input 0
                                          ).

  end.
  else do:
    run prn-lib-prn-file in this-procedure (
                                              input parParentProc
                                              ,input 4
                                              ).
  end.
end.
else do:
  define variable g#quest-print as logical no-undo .
  define variable g#report-num as integer no-undo .
  define variable g#log as logical no-undo .
  run get-quest-print in parparentproc
    (output g#quest-print
    ) .
  run get-report-num  in parParentProc(output g#report-num).
  if Log-Res then DO:
    { rep/q-print.i 0}
  End.
  else  DO:
    { rep/q-print.i 4}
  End.
end.