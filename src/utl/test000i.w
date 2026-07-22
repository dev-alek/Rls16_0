&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Тест корректности отчета о продаже - накладные- чеки

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/20/05
Author: Bakhtadze Natalya
Creation date: 10/20/05

*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "тест корректности отчета о продаже - накладные- чеки" .
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ gbl/flt-def.i }
{ gbl/waitfram.i }
{ cmp/showinf.i }
{ gbl/getcntxt.i def }
{ str/trdcalib.i }
{ str/inkas-ps.i }
DEFINE NEW SHARED STREAM test.
define variable filter-name as char no-undo.
define variable where-phrase as char no-undo.
define variable MY-where-phrase as char no-undo.
define variable sort-phrase as char no-undo.
def NEW SHARED var ff as decimal.
def NEW SHARED var gg as decimal.
DEF NEW SHARED VAR accum1 as decimal.
DEF NEW SHARED VAR accum2 as decimal.
define variable test-number as integer no-undo.
define buffer c-doc for ub.chk-doc.
define var r-bar-code like ub.bar-code.b-code no-undo.
define variable v-curr-r-b as character no-undo .

&SCOPED-DEFINE proc-vars ~
define variable accumq as decimal no-undo.                                  ~
define variable accumc as decimal no-undo.                                  ~
define variable accumall as decimal no-undo.                                ~
define variable accumall1 as decimal no-undo.                               ~
define variable for-netto as decimal no-undo.                               ~
define variable for-discnt as decimal no-undo.                              ~
define variable for-sub-disc as decimal no-undo.                            ~
define variable for-num-chk as integer no-undo.                             ~
define variable for-brutto as decimal no-undo.                              ~
define variable for-netto-r as decimal no-undo.                             ~
define variable for-discnt-r as decimal no-undo.                            ~
define variable for-brutto-r as decimal no-undo.                            ~
define variable for-netto-v as decimal no-undo.                             ~
define variable for-discnt-v as decimal no-undo.                            ~
define variable for-brutto-v as decimal no-undo.                            ~
define variable for-sum as decimal no-undo.                                 ~
define variable for-base as decimal no-undo.                                ~
define variable for-rubl as decimal no-undo.                                ~
define variable newprice as decimal no-undo.                                ~
define variable flag as logical.                                            ~
define variable current-netto as  decimal no-undo.                          ~
define variable current-brutto as  decimal no-undo.                         ~
define variable current-discnt as  decimal no-undo.                         ~
define variable current-write-off as  decimal no-undo.                      ~
define variable for-write-off as  decimal no-undo.                          ~
                                                                            ~
def buffer ret-doc for ub.trn-doc.                                             ~
define buffer buf_sale-doc for ub.sale-doc.                          ~
define buffer locked_trn-doc for ub.trn-doc.

define temp-table temp-sale-gds no-undo
field price-r-b like ub.gds-dtl.price-rubl
field sum-r-b-check   like ub.gds-dtl.price-rubl
field sum-r-b-trn    like ub.gds-dtl.price-rubl
field doc-type as character
field doc-kind as character
field doc-label as character
field qnty-check like ub.gds-dtl.fact-qnty
field qnty-trn  like ub.gds-dtl.fact-qnty
index pi is unique primary
doc-kind.

define temp-table temp-sale-delta no-undo
field sum-r-b-delta  like ub.gds-dtl.price-rubl
field doc-kind as character
field doc-label as character
field qnty-delta like ub.gds-dtl.fact-qnty
index pi is unique primary
doc-kind.

&scop longdf "-999,999,999.99999"
&scop longdf-chr "X(18)"
&scop doclf "X(25)"
&scop doccf "X(16)"

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-Help r-sale my-inkas BUTTON-1 ~
BUTTON-2 BUTTON-3 BUTTON-4 BUTTON-5 BUTTON-6 BUTTON-7
&Scoped-Define DISPLAYED-OBJECTS my-inkas

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON BUTTON-1
     LABEL "Отчет по продаже - чеки : общие суммы"
     SIZE 56.38 BY 1.08.

DEFINE BUTTON BUTTON-2
     LABEL "Оплаты по продаже - оплаты по чекам"
     SIZE 56.38 BY 1.08.

DEFINE BUTTON BUTTON-3
     LABEL "Товарные суммы: отчет о продаже - накладные"
     SIZE 56.38 BY 1.08.

DEFINE BUTTON BUTTON-4
     LABEL "Товарные суммы: чеки - накладные"
     SIZE 56.38 BY 1.08.

DEFINE BUTTON BUTTON-5
     LABEL "Некорректные строки накладных"
     SIZE 56.38 BY 1.08.

DEFINE BUTTON BUTTON-6
     LABEL "Оплаты по кассам - Оплаты всего"
     SIZE 56.38 BY 1.08.

DEFINE BUTTON BUTTON-7
     LABEL "Количества строк и чеков - Примечание к продаже"
     SIZE 56.38 BY 1.08.

DEFINE BUTTON r-sale
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.

DEFINE VARIABLE my-inkas AS CHARACTER FORMAT "X(256)":U
     LABEL "Номер продажи"
     VIEW-AS FILL-IN
     SIZE 14.63 BY .92 TOOLTIP "HAHA" NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-Help AT ROW 1 COL 54.88
     r-sale AT ROW 3.46 COL 39
     my-inkas AT ROW 3.5 COL 21.63 COLON-ALIGNED
     BUTTON-1 AT ROW 4.79 COL 1.75
     BUTTON-2 AT ROW 6.29 COL 1.75
     BUTTON-3 AT ROW 7.79 COL 1.75
     BUTTON-4 AT ROW 9.21 COL 1.75
     BUTTON-5 AT ROW 10.79 COL 1.75
     BUTTON-6 AT ROW 12.29 COL 1.75
     BUTTON-7 AT ROW 13.79 COL 1.75
     "testi7.txt" VIEW-AS TEXT
          SIZE 17.25 BY 1 AT ROW 13.79 COL 59.13
          FGCOLOR 4
     "testi3.txt" VIEW-AS TEXT
          SIZE 17.25 BY 1 AT ROW 7.79 COL 59.25
          FGCOLOR 4
     "testi2.txt" VIEW-AS TEXT
          SIZE 17.25 BY 1 AT ROW 6.29 COL 59.25
          FGCOLOR 4
     "testi1.txt" VIEW-AS TEXT
          SIZE 17.25 BY 1 AT ROW 4.79 COL 59.25
          FGCOLOR 4
     "testi5.txt" VIEW-AS TEXT
          SIZE 17.25 BY 1 AT ROW 10.79 COL 59
          FGCOLOR 4
     "testi6.txt" VIEW-AS TEXT
          SIZE 17.25 BY 1 AT ROW 12.21 COL 59.13
          FGCOLOR 4
     "testi4.txt" VIEW-AS TEXT
          SIZE 17.25 BY 1 AT ROW 9.21 COL 59
          FGCOLOR 4
     "Результаты ищите в файле:" VIEW-AS TEXT
          SIZE 25.25 BY 1 AT ROW 3.38 COL 51.63
          FGCOLOR 4
     SPACE(2.61) SKIP(10.65)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Тесты корректности отчета о продаже"
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
                                                                        */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Тесты корректности отчета о продаже */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME BUTTON-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-1 Dialog-Frame
ON CHOOSE OF BUTTON-1 IN FRAME Dialog-Frame /* Отчет по продаже - чеки : общие суммы */
DO:
  assign my-inkas.
  assign test-number = 1.
  run test0 in this-procedure no-error.
  if NOT error-status:error then
  message "Тест работу завершил" view-as alert-box.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME BUTTON-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-2 Dialog-Frame
ON CHOOSE OF BUTTON-2 IN FRAME Dialog-Frame /* Оплаты по продаже - оплаты по чекам */
DO:
  assign my-inkas.
  assign test-number = 2.
  run test0 in this-procedure no-error.
  if NOT error-status:error then
  message "Тест работу завершил" view-as alert-box.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME BUTTON-3
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-3 Dialog-Frame
ON CHOOSE OF BUTTON-3 IN FRAME Dialog-Frame /* Товарные суммы: отчет о продаже - накладные */
DO:
  assign my-inkas.
  assign test-number = 3.
  run test0 in this-procedure no-error.
  if NOT error-status:error then
  message "Тест работу завершил" view-as alert-box.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME BUTTON-4
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-4 Dialog-Frame
ON CHOOSE OF BUTTON-4 IN FRAME Dialog-Frame /* Товарные суммы: чеки - накладные */
DO:
  assign my-inkas.
  assign test-number = 4.
  run test0 in this-procedure no-error.
  if NOT error-status:error then
  message "Тест работу завершил" view-as alert-box.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME BUTTON-5
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-5 Dialog-Frame
ON CHOOSE OF BUTTON-5 IN FRAME Dialog-Frame /* Некорректные строки накладных */
DO:
  assign my-inkas.
  assign test-number = 5.
  run test0 in this-procedure no-error.
  if NOT error-status:error then
  message "Тест работу завершил" view-as alert-box.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME BUTTON-6
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-6 Dialog-Frame
ON CHOOSE OF BUTTON-6 IN FRAME Dialog-Frame /* Оплаты по кассам - Оплаты всего */
DO:
  assign my-inkas.
  assign test-number = 6.
  run test0 in this-procedure no-error.
  if NOT error-status:error then
  message "Тест работу завершил" view-as alert-box.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME BUTTON-7
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-7 Dialog-Frame
ON CHOOSE OF BUTTON-7 IN FRAME Dialog-Frame /* Количества строк и чеков - Примечание к продаже */
DO:
  assign my-inkas.
  assign test-number = 7.
  run test0 in this-procedure no-error.
  if NOT error-status:error then
  message "Тест работу завершил" view-as alert-box.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME my-inkas
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL my-inkas Dialog-Frame
ON LEAVE OF my-inkas IN FRAME Dialog-Frame /* Номер продажи */
DO:
  assign my-inkas.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-sale
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-sale Dialog-Frame
ON CHOOSE OF r-sale IN FRAME Dialog-Frame
DO:
  DEFINE VARIABLE rid-list as character no-undo .
    if v-cntxt-obj-type = {&shop} then
    run str/salelist.w (
                        input parparentproc
                      ,input "b-sel":U
                      ,input "object-all"
                      ,input v-cntxt-host-code-obj
                      ,input v-cntxt-obj-type
                      ,input v-cntxt-obj-code
                      ,input-output rid-list) no-error.
    else do:
      BELL.
      message "Не могу вызвать справочник отчетов о продаж, если текущий объект не МАГАЗИН!"
      view-as alert-box ERROR.
      return no-apply.
    end.
    if rid-list  <> '':U then do:
        find first ub.inkas NO-LOCK WHERE recid(ub.inkas) = integer(rid-list) NO-ERROR.
        assign
        my-inkas = ub.inkas.inkas-code.
        display
        my-inkas
        WITH FRAME {&frame-name}.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/app_help.i }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  { gbl/getcntxt.i get }
  { gbl/curr-r-b.i
    v-curr-r-b
  }
   RUN enable_UI in this-procedure .
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI in this-procedure .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI Dialog-Frame  _DEFAULT-DISABLE
PROCEDURE disable_UI :
/*------------------------------------------------------------------------------
  Purpose:     DISABLE the User Interface
  Parameters:  <none>
  Notes:       Here we clean-up the user-interface by deleting
               dynamic widgets we have created and/or hide
               frames.  This procedure is usually called when
               we are ready to "clean-up" after running.
------------------------------------------------------------------------------*/
  /* Hide all frames. */
  HIDE FRAME Dialog-Frame.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI Dialog-Frame  _DEFAULT-ENABLE
PROCEDURE enable_UI :
/*------------------------------------------------------------------------------
  Purpose:     ENABLE the User Interface
  Parameters:  <none>
  Notes:       Here we display/view/enable the widgets in the
               user-interface.  In addition, OPEN all queries
               associated with each FRAME and BROWSE.
               These statements here are based on the "Other
               Settings" section of the widget Property Sheets.
------------------------------------------------------------------------------*/
  DISPLAY my-inkas
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-Help r-sale my-inkas BUTTON-1 BUTTON-2 BUTTON-3 BUTTON-4
         BUTTON-5 BUTTON-6 BUTTON-7
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE test0 Dialog-Frame
PROCEDURE test0 :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

FIND FIRST ub.inkas no-lock where ub.inkas.inkas-code = my-inkas NO-ERROR.
if not avail ub.inkas then do:
    message "Нет такой продажи!" view-as alert-box ERROR.
    return error.
END.
if ub.inkas.status_ = {&inquiry} then do:
  disable
  button-2
  button-3
  with frame {&frame-name}.
end.
else do:
  enable
  button-2
  button-3
  with frame {&frame-name} .
end.
run value("test" + string(test-number)) IN THIS-PROCEDURE ( INPUT my-inkas) no-error.
run waitfram-hide in this-procedure .
OUTPUT STREAM test close.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE test1 Dialog-Frame
PROCEDURE test1 :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE INPUT PARAMETER my-inkas LIKE ub.inkas.inkas-code no-undo.
define variable for-num-chk-nf as integer no-undo .
{&proc-vars}
OUTPUT STREAM TEST TO testi1.txt.
_chk-doc:
FOR EACH ub.chk-doc NO-LOCK where ub.chk-doc.out-code = my-inkas :
  run waitfram-show in this-procedure ( input "Ждите - идет обработка -  чек " + chk-doc.doc-code).
    if lookup(string(chk-doc.chk-type), {&no-docum-receipt-codes}) > 0 then do:
      for-num-chk-nf = for-num-chk-nf + 1.
      for-num-chk = for-num-chk + 1.
      NEXT _chk-doc.
    end.
    assign
    for-brutto = for-brutto + chk-doc.tot-doc
    for-netto = for-netto + chk-doc.netto
    for-discnt = for-discnt + chk-doc.discnt
    for-sub-disc = for-sub-disc + chk-doc.sub-discnt
    for-num-chk = for-num-chk + 1
    .
END.
PUT stream TEST UNFORMATTED
("СРАВНЕНИЕ ОБЩИХ СУММ ПО ОТЧЕТУ ПРОДАЖЕ " + my-inkas + " И ЧЕКАМ") skip(1)
"Брутто" format "X(22)" space(1)
"Нетто" format "X(22)" space(1)
"Скидка" format "X(22)" space(1)
"Сумма списанного" format "X(22)" space(1)
"Кол-во чеков Общее" format "X(18)" space(1)
"из них вне док-тов" format "X(18)" space(1)
skip
"ОТЧЕТ ПО ПРОДАЖЕ"
skip
ub.inkas.tot-doc format "-999,999,999.999999999" space(1)
ub.inkas.netto format "-999,999,999.999999999" space(1)
ub.inkas.discnt format "-999,999,999.999999999" space(1)
ub.inkas.sub-discnt format "-999,999,999.999999999" space(1)
ub.inkas.num-chk FORMAT "-999,999" space(10)
ub.inkas.num-chk-nf FORMAT "-999,999" space(1)
skip
"ЧЕКИ"
skip
for-brutto format "-999,999,999.999999999" space(1)
for-netto format "-999,999,999.999999999" space(1)
for-discnt format "-999,999,999.999999999" space(1)
for-sub-disc format "-999,999,999.999999999" space(1)
for-num-chk format "-999,999" space(10)
for-num-chk-nf format "-999,999" space(1)
skip
.
run waitfram-hide in this-procedure .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE test2 Dialog-Frame
PROCEDURE test2 :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE INPUT PARAMETER my-inkas LIKE ub.inkas.inkas-code no-undo.
{&proc-vars}
OUTPUT STREAM TEST TO testi2.txt.
PUT stream TEST UNFORMATTED
("СРАВНЕНИЕ СУММ ПЛАТЕЖЕЙ ПО ОТЧЕТУ ПО ПРОДАЖЕ " + my-inkas + " И ЧЕКАМ") skip(1)
space(16)
"Код платежа" format "X(11)" space(1)
"Код валюты " format "X(11)" space(1)
"Баз.вал." format "X(15)" space(1)
"{&abbr_rubli_firstshift}" format "X(15)" space(1)
"Валюта платежа" format "X(15)" space(1)
"Ошибка кода оплаты" format "X(20)"
skip
.
_chk-pay:
FOR EACH ub.chk-pay No-LOCK WHERE
        ub.chk-pay.out-code = my-inkas use-index out-sale,
    first ub.chk-doc no-lock where
         ub.chk-doc.doc-code = ub.chk-pay.doc-code
break
by ub.chk-pay.pay-code
by ub.chk-pay.curr-code:
  run waitfram-show in this-procedure ( input "Ждите - идет обработка -  чек " + chk-pay.doc-code).
  if first-of(chk-pay.curr-code) then do:
    assign
    for-base = 0
    for-rubl = 0
    for-sum = 0
    flag = no
    .
    FIND FIRST ub.inkas-pay NO-LOCK WHERE
              ub.inkas-pay.inkas-code = my-inkas
         AND  ub.inkas-pay.pay-code = chk-pay.pay-code
         AND  ub.inkas-pay.curr-code = chk-pay.curr-code No-ERROR.
    if not avail ub.inkas-pay then flag = yes.
    else flag = no.
  end. /*first-of(chk-pay.curr-code)*/
  if lookup(string(ub.chk-doc.chk-type), {&no-docum-receipt-codes}) > 0 then NEXT _chk-pay.
  assign
  for-base = for-base + ub.chk-pay.tot-base
  for-rubl = for-rubl + ub.chk-pay.tot-rubl
  for-sum = for-sum + ub.chk-pay.tot-sum
  .
  if last-of(ub.chk-pay.curr-code) then do:
      PUT stream TEST UNFORMATTED
      space(16)
      chk-pay.pay-code format "9999" space(8)
      chk-pay.curr-code format "99999" space(7)
      skip(0)
      "ОПЛАТЫ ПО ПРОДАЖЕ" format "X(15)" space(1)
      space(12)
      space(10)
      (if avail inkas-pay then inkas-pay.tot-base else 0) format "-999,999,999.99" space(1)
      (if avail inkas-pay then inkas-pay.tot-rubl else 0) format "-999,999,999.99" space(1)
      (if avail inkas-pay then inkas-pay.tot-sum else 0) format "-999,999,999.99" space(1)
      string(flag, "yes/no") format "X(20)"
      skip
      "ОПЛАТЫ ПО ЧЕКАМ" format "X(15)" space(1)
      space(12)
      space(10)
      for-base format "-999,999,999.99" space(1)
      for-rubl format "-999,999,999.99" space(1)
      for-sum format "-999,999,999.99" space(1)
      skip
      .
  end. /*last-of(chk-pay.curr-code)*/
end. /*FOR EACH chk-pay*/
FOR EACH inkas-pay NO-LOCK WHERE inkas-pay.inkas-code = my-inkas :
  IF not can-find(FIRST chk-pay NO-LOCK WHERE
                       chk-pay.out-code = my-inkas
                 AND   chk-pay.pay-code = inkas-pay.pay-code
                 AND   chk-pay.curr-code = inkas-pay.curr-code) then do:
    PUT stream TEST UNFORMATTED
    space(16)
    inkas-pay.pay-code  format "X(20)" space(1)
    inkas-pay.curr-code  format "99999" space(1)
    "ОПЛАТЫ ПО ПРОДАЖЕ" format "X(15)" space(1)
    space(12)
    space(10)
    inkas-pay.tot-base format "-999,999,999.99" space(1)
    inkas-pay.tot-rubl format "-999,999,999.99" space(1)
    inkas-pay.tot-sum format "-999,999,999.99" space(1)
    string(yes, "yes/no") format "X(20)"
    skip
    "ОПЛАТЫ ПО ЧЕКАМ" format "X(15)" space(1)
    space(12)
    space(10)
    0 format "-999,999,999.99" space(1)
    0 format "-999,999,999.99" space(1)
    0 format "-999,999,999.99" space(1)
    skip
    .
  end.
END. /*FOR EACH INKAS-PAY*/
run waitfram-hide in this-procedure .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE test3 Dialog-Frame
PROCEDURE test3 :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE INPUT PARAMETER my-inkas LIKE ub.inkas.inkas-code no-undo.
{&proc-vars}
define variable delta as decimal no-undo .
define buffer dop_trn-doc for ub.trn-doc.

OUTPUT STREAM TEST TO testi3.txt.
run waitfram-show in this-procedure ( input "Ждите ...").
PUT STREAM test unformatted
"СРАВНЕНИЕ ТОВАРНЫХ СУММ ПО ДОКУМЕНТАМ ПРОДАЖИ И ПРОДАЖЕ В ЦЕЛОМ" SKIP(0)
"ПРОДАЖА"  {&space-char} my-inkas skip(1)
string('':U, {&doclf})  {&space-char}
string('':U, {&doccf}) +  {&space-char}
string('Брутто', "X(19)")  {&space-char}
string('Скидка товарная', "X(19)")  {&space-char}
string('Нетто', "X(19)")  {&space-char}
skip(0)
.
for each buf_sale-doc where
       buf_sale-doc.inkas-code = my-inkas
    and buf_sale-doc.order > 0:
  if lookup(buf_sale-doc.doc-kind, {&sale-all-doc-kinds}) = 0 then NEXT.
  if ub.inkas.status_ <> {&FACT} then do:
    find first dop_trn-doc no-lock where
              dop_trn-doc.doc-code = buf_sale-doc.doc-code.
    run gbl/calc-trn.p ( input parparentproc
                       , input recid(dop_trn-doc)).
  end.
  find first locked_trn-doc where locked_trn-doc.doc-code = buf_sale-doc.doc-code.
  if buf_sale-doc.doc-kind = {&sale-add-tech-refuell} then do:
  end.
  else do:
    assign
    current-brutto = if v-curr-r-b = {&r-b-rubl}
                      then locked_trn-doc.tot-sale
                      else locked_trn-doc.tot-fact
    current-netto = if v-curr-r-b = {&r-b-rubl}
                then locked_trn-doc.tot-sale - (if locked_trn-doc.discnt-rubl = ? then 0 else locked_trn-doc.discnt-rubl)
                else locked_trn-doc.tot-fact - (if locked_trn-doc.tot-calc = ? then 0 else locked_trn-doc.tot-calc)
    current-discnt = if v-curr-r-b = {&r-b-rubl}
                    then locked_trn-doc.discnt-rubl
                    else locked_trn-doc.tot-calc
    .
    if buf_sale-doc.in-inkas then
    assign
    for-netto = for-netto + current-netto * buf_sale-doc.dir
    for-brutto = for-brutto + current-brutto * buf_sale-doc.dir
    for-discnt = for-discnt + (if current-discnt = ? then 0 else current-discnt) * buf_sale-doc.dir
    .
    if buf_sale-doc.doc-type = {&write-off} then
    assign
    current-write-off = if v-curr-r-b = {&r-b-rubl}
                then locked_trn-doc.tot-sale - locked_trn-doc.discnt-rubl
                else locked_trn-doc.tot-fact - locked_trn-doc.tot-calc
    for-write-off = for-write-off + current-write-off
    .
&scop sale-doc-kind buf_sale-doc.doc-kind
    PUT STREAM test unformatted
    string({&sale-doc-name}, {&doclf})  {&space-char}
    string(buf_sale-doc.doc-code, {&doccf}) +  {&space-char}
    string(current-brutto * buf_sale-doc.dir, {&longdf})  {&space-char}

    (if current-discnt = ?
    then string({&question-mark}, {&longdf-chr})
    else
    string(current-discnt * buf_sale-doc.dir, {&longdf})
    )                                                    {&space-char}

    string(current-netto * buf_sale-doc.dir, {&longdf})  {&space-char}
    skip(0).
  end. /*не техпролив*/
end. /*ОСНОВНЫЕ ДОКУМЕНТЫ ПОСЧИТАЛИ*/
delta = inkas.netto - (for-netto  - (inkas.sub-discnt - for-write-off)).
PUT STREAM test unformatted
skip(1)
string("Итого по документам", {&doclf})  {&space-char}
string('':U, {&doccf})  {&space-char}
string(for-brutto, {&longdf})  {&space-char}
string(for-discnt, {&longdf})   {&space-char}
string(for-netto, {&longdf})  skip(0)
string("Сумма списаний", {&doclf}) {&space-char}
string('':U, {&doccf})  {&space-char}
string(for-write-off, {&longdf})  {&space-char}
string(0, {&longdf})  {&space-char}
string(0, {&longdf}) skip.
PUT STREAM test unformatted
skip(1)
string("Продажа в общем", {&doclf})  {&space-char}
string('':U, {&doccf}) +  {&space-char}
string(inkas.tot-doc, {&longdf})  {&space-char}
string(inkas.discnt, {&longdf})   {&space-char}
string(inkas.netto, {&longdf})  {&space-char}
skip(0)
string("Сумма списаний", {&doclf}) {&space-char}
string('':U, {&doccf})  {&space-char}
string(inkas.sub-discnt, {&longdf})  {&space-char}
string(0, {&longdf})  {&space-char}
string(0, {&longdf}) skip(0).
PUT STREAM test unformatted
skip(1)
string("Нетто по продаже", {&doclf})  {&space-char}
string(inkas.netto, {&longdf})  {&space-char}
skip(0)
string(" - (", {&doclf}) skip(0)
string("    нетто по документам", {&doclf})  {&space-char}
string(for-netto, {&longdf})  {&space-char}
skip(0)
string("     - (", {&doclf}) skip(0)
string("        спис. по продаже", {&doclf})  {&space-char}
string(inkas.sub-discnt, {&longdf})  {&space-char}
skip(0)
string("     - ", {&doclf}) skip(0)
string("        спис. по документ", {&doclf})  {&space-char}
string(for-write-off, {&longdf})  {&space-char}
skip(0)
string("     - )", {&doclf})  {&space-char}
skip(0)
string(" - )", {&doclf})  {&space-char}
skip(0)
string(" = ", {&doclf})  {&space-char}
string(delta, {&longdf})  {&space-char}
skip(0)
string("Погрешность=", {&doclf}) {&space-char}
string(abs(delta), {&longdf}) skip(0)
(if abs(delta) < 0.015
then "В пределах нормы"
else "Больше допустимой")
skip(0).
run waitfram-hide in this-procedure .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE test4 Dialog-Frame
PROCEDURE test4 :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE INPUT PARAMETER my-inkas LIKE ub.inkas.inkas-code no-undo.
{&proc-vars}
define buffer buf_temp-sale-gds for temp-sale-gds.
define buffer buf_temp-sale-delta for temp-sale-delta.
define variable v-doc-kinds as character no-undo .
define variable ii as integer no-undo .
define variable v-dopi as integer no-undo .
define buffer buf_chk-doc for ub.chk-doc.
for each buf_temp-sale-delta:
  delete buf_temp-sale-delta.
end.
OUTPUT STREAM TEST TO testi4.txt.
run waitfram-show in this-procedure ( input "Ждите ...").
PUT STREAM TEST UNFORMATTED
substitute("РАЗЛИЧИЕ ТОВАРНЫХ СУММ ПО СТРОКАМ НАКЛАДНЫХ ПО ПРОДАЖЕ И ЧЕКАМ&1" +
             "ПО ПРОДАЖЕ &2&1&3"
             ,{&new-line}
             ,my-inkas
             ,(if index(ub.inkas.PS, "компенс")  > 0 then "БЫЛА ПРОВЕДЕНА КОМПЕНСАЦИЯ" else "")
             ) skip(1)
string("Бар-код", "X(9)") {&space-char}
string("Артикул", {&doccf}) {&space-char}
string("Про", "X(3)") {&space-char}
string("изводитель", "X(9)") {&space-char}
string("Вид документа", "X(20)") {&space-char}
string("Кол-во док-ты", "X(12)") {&space-char}
string("Сумма док-ты", "X(18)")
skip(0)
fill( {&space-char} , 9 ) {&space-char}
fill( {&space-char} , 16 ) {&space-char}
fill( {&space-char} , 3 ) {&space-char}
fill( {&space-char} , 9 ) {&space-char}
fill( {&space-char} , 20 ) {&space-char}
string("Кол-во чеки", "X(12)") {&space-char}
string("Сумма чеки", "X(18)")
skip.

FOR EACH ub.chk-gds No-LOCK WHERE ub.chk-gds.out-code = my-inkas,
    FIRST ub.chk-doc NO-LOCK where ub.chk-doc.doc-code = ub.chk-gds.doc-code,
    FIRST ub.bar-code No-LOCK WHERE ub.bar-code.b-code = ub.chk-gds.b-code,
    FIRST ub.goods NO-LOCK WHERE ub.goods.gds-code = ub.bar-code.gds-code
BREAK
BY ub.goods.gds-code:
  run waitfram-show in this-procedure ( input substitute("Ждите ... Обработка баркода &1", chk-gds.b-code)).
  IF FIRST-OF(ub.goods.gds-code) then do:
    for each buf_temp-sale-gds:
      delete buf_temp-sale-gds.
    end.
    for each buf_sale-doc where
            buf_sale-doc.inkas-code = my-inkas
        and buf_sale-doc.order > 0 :
      FOR EACH ub.gds-dtl No-LOCK WHERE
            ub.gds-dtl.doc-code = buf_sale-doc.doc-code
        AND ub.gds-dtl.artic = ub.goods.artic
        AND ub.gds-dtl.prod-type = ub.goods.prod-type
        AND ub.gds-dtl.prod-code = ub.goods.prod-code
        AND ub.gds-dtl.prt-code = ub.bar-code.node-code:
        create buf_temp-sale-gds.
&scop sale-doc-kind buf_sale-doc.doc-kind
        assign
        buf_temp-sale-gds.doc-type = buf_sale-doc.doc-type
        buf_temp-sale-gds.doc-kind = buf_sale-doc.doc-kind
        buf_temp-sale-gds.doc-label = {&sale-doc-name}
        buf_temp-sale-gds.qnty-trn = gds-dtl.fact-qnty * buf_sale-doc.msign
        buf_temp-sale-gds.sum-r-b-trn = gds-dtl.fact-qnty *
                                        (if v-curr-r-b = {&r-b-rubl}
                                        then (gds-dtl.price-rubl - gds-dtl.discnt-rubl)
                                        else (gds-dtl.price-base - gds-dtl.discnt-base)
                                        ) * buf_sale-doc.msign
        .
      END.
    end.
  END. /*IF FIFRST-OF chk-gds.b-code*/
  if lookup(string(chk-doc.chk-type), {&no-docum-receipt-codes}) = 0 then do:
    assign
    v-dopi = num-entries(chk-gds.line-type, {&delim-par})
    no-error .
    if not error-status:error
    and v-dopi > 1 then do:
      v-doc-kinds = entry(2, chk-gds.line-type, {&delim-par}).
    end.
    else do:
      if chk-gds.doc-qnty = 0 then v-doc-kinds = '':U.
      else do:
        find first buf_chk-doc no-lock where
                buf_chk-doc.doc-code = chk-gds.doc-code .
        v-doc-kinds = (if buf_chk-doc.netto >= 0
                            then {&TDEDT_Ras_Vnesh_Kass}
                            else {&TDEDT_VOzvrat_Vnesh_Kass})
        .
      end.
    end.
    do ii = 1 to num-entries(v-doc-kinds):
      find first buf_temp-sale-gds where
              buf_temp-sale-gds.doc-kind = entry(ii, v-doc-kinds) no-error .
      if not available buf_temp-sale-gds then do:
        create buf_temp-sale-gds.
        assign
        buf_temp-sale-gds.doc-kind = entry(ii, v-doc-kinds)
        .
      end.
      assign
      buf_temp-sale-gds.qnty-check = buf_temp-sale-gds.qnty-check + chk-gds.doc-qnty
      buf_temp-sale-gds.sum-r-b-check = buf_temp-sale-gds.sum-r-b-check +
                                        chk-gds.doc-qnty * (chk-gds.price-base -
                                                           (if buf_temp-sale-gds.doc-type = {&write-off}
                                                           then 0
                                                           else chk-gds.discnt))
      .
    end.
  end.
  IF LAST-OF(goods.gds-code) then do:
    for each buf_temp-sale-gds:
      if buf_temp-sale-gds.qnty-trn <> buf_temp-sale-gds.qnty-check
      or abs(buf_temp-sale-gds.sum-r-b-trn - buf_temp-sale-gds.sum-r-b-check) > 0.0001
      then do:
        find first buf_temp-sale-delta where
                  buf_temp-sale-delta.doc-kind = buf_temp-sale-gds.doc-kind no-error .
        if not available buf_temp-sale-delta then do:
          CREATE BUF_TEMP-SALE-DELTA.
          ASSIGN
          buf_temp-sale-delta.doc-kind = buf_temp-sale-gds.doc-kind
          buf_temp-sale-delta.doc-label = buf_temp-sale-gds.doc-label
          .
        end.
        assign
        buf_temp-sale-delta.qnty-delta = buf_temp-sale-delta.qnty-delta + (buf_temp-sale-gds.qnty-trn - buf_temp-sale-gds.qnty-check)
        buf_temp-sale-delta.sum-r-b-delta = buf_temp-sale-delta.sum-r-b-delta + (buf_temp-sale-gds.sum-r-b-trn - buf_temp-sale-gds.sum-r-b-check)
        .
        PUT STREAM TEST UNFORMATTED
        chk-gds.b-code format ">>>>>>>>9" {&space-char}
        goods.artic format {&doccf} {&space-char}
        goods.prod-type format "X(3)" {&space-char}
        goods.prod-code format "999999999" {&space-char}
        buf_temp-sale-gds.doc-label format "X(20)" {&space-char}
        buf_temp-sale-gds.qnty-trn  format "-99,999.999" {&space-char}
        buf_temp-sale-gds.sum-r-b-trn format   "-99,999.999999999"
        skip(0)
        fill( {&space-char} , 9 ) {&space-char}
        fill( {&space-char} , 16 ) {&space-char}
        fill( {&space-char} , 3 ) {&space-char}
        fill( {&space-char} , 9 ) {&space-char}
        fill( {&space-char} , 20 ) {&space-char}
        buf_temp-sale-gds.qnty-check  format "-99,999.999" {&space-char}
        buf_temp-sale-gds.sum-r-b-check format "-99,999.999999999"
        skip.
      end.
    end. /*for eac buf_temp-sale-gds*/
  END.  /*IF LAST-OF(chk-gds.b-code)*/
END. /*FOR EACH chk-gds*/
PUT STREAM TEST UNFORMATTED
"ИТОГО ПОГРЕШНОСТИ ПО ВИДАМ ДОКУМЕНТОВ:" skip(0).
for each buf_temp-sale-delta:
  PUT STREAM TEST UNFORMATTED
  buf_temp-sale-delta.doc-label format "X(20)" {&space-char}
  buf_temp-sale-delta.qnty-delta  format "-99,999.999" {&space-char}
  buf_temp-sale-delta.sum-r-b-delta format "-99,999.999999999"
  skip(0).
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE test5 Dialog-Frame
PROCEDURE test5 :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE INPUT PARAMETER my-inkas LIKE ub.inkas.inkas-code no-undo.
{&proc-vars}
OUTPUT STREAM TEST TO testi5.txt.
run waitfram-show in this-procedure ( input "Ждите ...").
PUT STREAM TEST UNFORMATTED
("НЕКОРРЕКТНЫЕ СТРОКИ НАКЛАДНЫХ ПО ПРОДАЖЕ " + my-inkas) skip(1)
"Артикул" format {&doccf} space(1)
"Про изводитель" format "X(14)" space(1)
"Кол-во-накл" format "X(11)" space(1)
"Скидка" format "X(15)" space(1)
"Вид докум" format "X(20)"
skip
.

IF error-status:ERROR THEN do:
  MESSAGE ERROR-STATUS:GET-MESSAGE(1) RETURN-VALUE.
  return error.
end.
for each buf_sale-doc where
        buf_sale-doc.inkas-code = my-inkas
    and  buf_sale-doc.order > 0
        :
  FOR EACH ub.gds-dtl No-LOCK WHERE
        ub.gds-dtl.doc-code = buf_sale-doc.doc-code,
    FIRST ub.goods No-LOCK WHERE
        ub.goods.artic = ub.gds-dtl.artic AND
        ub.goods.prod-type = ub.gds-dtl.prod-type AND
        ub.goods.prod-code = ub.gds-dtl.prod-code:
  run waitfram-show in this-procedure ( input string("Ждите ... Обработка товара " +
                            string(gds-dtl.artic, "9999999999") + gds-dtl.prod-type + string(gds-dtl.prod-code)
                  )         ).
&scop sale-doc-kind buf_sale-doc.doc-kind
  IF (gds-dtl.fact-qnty = 0 or (gds-dtl.doc-qnty = 0 and  buf_sale-doc.status_ = {&fact})) and
     (gds-dtl.discnt-rubl <> 0 or gds-dtl.discnt-base <>  0)  then
    PUT STREAM TEST UNFORMATTED
    goods.artic format {&doccf} space(1)
    goods.prod-type format "X(3)" space(1)
    goods.prod-code format "9999999999" space(1)
    gds-dtl.fact-qnty  format "-99,999.999" space(1)
    (if v-curr-r-b = {&r-b-base}
    then gds-dtl.discnt-base
    else gds-dtl.discnt-rubl) format "-99,999.999999999" space(1)
    {&sale-doc-name} format "X(20)"
    skip.
  END. /*FOR EACH gds-dtl*/
end. /*for each buf_sale-doc*/
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE test6 Dialog-Frame
PROCEDURE test6 :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE INPUT PARAMETER my-inkas LIKE ub.inkas.inkas-code no-undo.
{&proc-vars}
&scop pay-decf "-999,999,999.99"
OUTPUT STREAM TEST TO testi6.txt.
PUT stream TEST UNFORMATTED
("СРАВНЕНИЕ СУММ ПЛАТЕЖЕЙ ПО ОТЧЕТУ ПО ПРОДАЖЕ В ЦЕЛОМ " + my-inkas + " И ПО КАССАМ") skip(1)
space(16)
"Код платежа" format "X(11)" space(1)
"Код валюты " format "X(11)" space(1)
"Баз.вал." format "X(15)" space(1)
"{&abbr_rubli_firstshift}" format "X(15)" space(1)
"Валюта платежа" format "X(15)" space(1)
"Ошибка кода оплаты" format "X(20)"
skip
.
FOR EACH ub.inkas-pay-desk No-LOCK WHERE
        ub.inkas-pay-desk.inkas-code = my-inkas
break
by ub.inkas-pay-desk.pay-code
by ub.inkas-pay-desk.curr-code:
  run waitfram-show in this-procedure ( input "Ждите - идет обработка -  оплата по кассе " + string(inkas-pay-desk.pay-desk)).
  if first-of(ub.inkas-pay-desk.curr-code) then do:
      assign
      for-base = 0
      for-rubl = 0
      for-sum = 0
      flag = no
      .
      FIND FIRST ub.inkas-pay NO-LOCK WHERE
                  ub.inkas-pay.inkas-code = my-inkas AND
                  ub.inkas-pay.pay-code = ub.inkas-pay-desk.pay-code AND
                  ub.inkas-pay.curr-code = ub.inkas-pay-desk.curr-code No-ERROR.
      if not avail ub.inkas-pay then flag = yes.
      else flag = no.
  end. /*first-of(chk-pay.curr-code)*/
  assign
  for-base = for-base + ub.inkas-pay-desk.tot-base
  for-rubl = for-rubl + ub.inkas-pay-desk.tot-rubl
  for-sum = for-sum + ub.inkas-pay-desk.tot-sum
  .
  if last-of(inkas-pay-desk.curr-code) then do:
    PUT stream TEST UNFORMATTED
    space(16)
    inkas-pay-desk.pay-code format "9999" space(8)
    inkas-pay-desk.curr-code format "99999" space(7)
    skip(0)
    "ОПЛАТЫ ПО ПРОДАЖЕ" format "X(15)" space(1)
    space(12)
    space(10)
    (if avail inkas-pay then inkas-pay.tot-base else 0) format {&pay-decf} space(1)
    (if avail inkas-pay then inkas-pay.tot-rubl else 0) format {&pay-decf} space(1)
    (if avail inkas-pay then inkas-pay.tot-sum else 0) format {&pay-decf} space(1)
    string(flag, "yes/no") format "X(20)"
    skip
    "ОПЛАТЫ ПО КАССАМ" format "X(15)" space(1)
    space(12)
    space(10)
    for-base format {&pay-decf} space(1)
    for-rubl format {&pay-decf} space(1)
    for-sum format {&pay-decf} space(1)
    skip
    .
  end. /*last-of(chk-pay.curr-code)*/
end. /*FOR EACH chk-pay*/
FOR EACH inkas-pay NO-LOCK WHERE
        inkas-pay.inkas-code = my-inkas :
  IF not can-find(FIRST inkas-pay-desk NO-LOCK WHERE
                        inkas-pay-desk.inkas-code = my-inkas AND
                      inkas-pay-desk.pay-code = inkas-pay.pay-code AND
                      inkas-pay-desk.curr-code = inkas-pay.curr-code) then do:
    PUT stream TEST UNFORMATTED
    space(16)
    inkas-pay.pay-code  format "X(20)" space(1)
    inkas-pay.curr-code  format "99999" space(1)
    "ОПЛАТЫ ПО ПРОДАЖЕ" format "X(15)" space(1)
    space(12)
    space(10)
    inkas-pay.tot-base format {&pay-decf} space(1)
    inkas-pay.tot-rubl format {&pay-decf} space(1)
    inkas-pay.tot-sum format {&pay-decf} space(1)
    string(yes, "yes/no") format "X(20)"
    skip
    "ОПЛАТЫ ПО КАССАМ" format "X(15)" space(1)
    space(12)
    space(10)
    0 format {&pay-decf} space(1)
    0 format {&pay-decf} space(1)
    0 format {&pay-decf} space(1)
    skip
    .
  end.
END. /*FOR EACH INKAS-PAY*/
run waitfram-hide in this-procedure .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE test7 Dialog-Frame
PROCEDURE test7 :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE INPUT PARAMETER my-inkas LIKE ub.inkas.inkas-code no-undo.

define VARIABLE chk-amount as integer no-undo .
define VARIABLE gds-amount as integer no-undo .
define VARIABLE line-out as integer no-undo .
define VARIABLE dtl-out as integer no-undo .
define VARIABLE line-ret as integer no-undo .
define VARIABLE dtl-ret as integer no-undo .
define VARIABLE nf-chk-amount as integer no-undo .
define VARIABLE nf-gds-amount as integer no-undo .
define VARIABLE ps-where-rus as character no-undo .
define VARIABLE v-ps as character no-undo .
define buffer buf_inkas for ub.inkas.
OUTPUT STREAM TEST TO testi7.txt.
find first buf_inkas no-lock where buf_inkas.inkas-code = my-inkas.
run get-inkas-ps in this-procedure (
                                    buffer buf_inkas
                                  , output chk-amount
                                  , output gds-amount
                                  , output line-out
                                  , output dtl-out
                                  , output line-ret
                                  , output dtl-ret
                                  , output nf-chk-amount
                                  , output nf-gds-amount
                                  , output ps-where-rus
                                  ).


if ub.inkas.status_ <> {&fact} then do:

  v-PS = substitute("Кол-во_чеков &1&3строк_чеков &2"
                      , chk-amount
                      , gds-amount
                      , {&new-line})
                + {&new-line}.
end.
v-ps = v-ps +
       SUBSTITUTE("товаров_расход &1&3признаков_расход &2"
                    , line-out
                    , dtl-out
                    , {&new-line}
                    )
       + {&new-line} +
       SUBSTITUTE("товаров_возврат &1&3признаков_возврат &2"
                    , line-ret
                    , dtl-ret
                    , {&new-line}
                    ).
if inkas.status_ <> {&fact} then do:
  v-ps = v-ps + {&new-line} +
               substitute("без_докум_чеков &1&3без_докум_строк_чеков &2"
                         , nf-chk-amount
                         , nf-gds-amount
                         , {&new-line}
                         ).

end.
PUT stream TEST UNFORMATTED
substitute("КОЛИЧЕСТВО СТРОК ЧЕКОВ И ЧЕКОВ ПО ПРОДАЖЕ &1", my-inkas)
skip(0)
"По подсчету:" SKIP(1)
v-ps skip(1)
"В примечаниях к продаже" SKIP(1)
replace(inkas.ps, {&delim-par}, {&new-line})
SKIP.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE testi Dialog-Frame
PROCEDURE testi :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE INPUT PARAMETER test-number as integer.
DEFINE INPUT PARAMETER my-inkas as char.
define variable accumq as decimal no-undo.
define variable accumc as decimal no-undo.
define variable accumall as decimal no-undo.
define variable accumall1 as decimal no-undo.
define variable for-netto as decimal no-undo.
define variable for-discnt as decimal no-undo.
define variable for-sub-disc as decimal no-undo.
define variable for-num-chk as integer no-undo.
define variable for-brutto as decimal no-undo.
define variable for-netto-r as decimal no-undo.
define variable for-discnt-r as decimal no-undo.
define variable for-brutto-r as decimal no-undo.
define variable for-netto-v as decimal no-undo.
define variable for-discnt-v as decimal no-undo.
define variable for-brutto-v as decimal no-undo.
define variable for-sum as decimal no-undo.
define variable for-base as decimal no-undo.
define variable for-rubl as decimal no-undo.
define variable newprice as decimal no-undo.
define variable flag as logical.
define variable current-netto as  decimal no-undo.
define variable current-brutto as  decimal no-undo.
define variable current-discnt as  decimal no-undo.
define variable current-write-off as  decimal no-undo.
define variable for-write-off as  decimal no-undo.

def buffer ret-doc for ub.trn-doc.
define buffer buf_sale-doc for ub.sale-doc.
define buffer locked_trn-doc for ub.trn-doc.



END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME