&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame

/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE tt-fin-doc NO-UNDO LIKE ub.fin-doc.
DEFINE TEMP-TABLE tt0-fin-doc-attr NO-UNDO LIKE ub.fin-doc-attr.
DEFINE TEMP-TABLE tt0-fin-doc-tax NO-UNDO LIKE ub.fin-doc-tax
       INDEX pi1 vat-pc slt-pc with-vat with-slt
       .
DEFINE TEMP-TABLE tt0-payment NO-UNDO LIKE ub.payment.


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Автоматическая оплата финансовых обязательств

Автор: Чернова Светлана Александровна
Дата создания: 09/14/05
Author: Svetlana Chernova
Creation date: 09/14/05

*/
/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

  DEFINE temp-table temp-fin-ob no-undo
    field   ri             as  recid
    field   ind            as integer
    field   del            as logical
    INDEX pi  IS PRIMARY   ind
    INDEX pi1  ri
    INDEX pi2  del
  .

/* Parameters Definitions ---                                           */
  define input  parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input  parameter p-host-code    as integer   no-undo . /* надо передавать фирму */
  define input  parameter table for temp-fin-ob.
  define output parameter p-ri as recid no-undo .

/* Local Variable Definitions ---                                       */

define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Автомат. оплата фин. обязательств" .
{ cmp/vssrevis.i }
{ cmp/showinf.i  }
{ cmp/str-glbl.i }
{ ref/fndocip.i }
{ cmp/library.i }
{ trg/new-bcod.i }

  define variable g-log as logical   no-undo .
  define variable is-expense  as logical   no-undo .
  define buffer buf_contract for ub.contract .
  define buffer b1_fin-schet for ub.fin-schet .
  define buffer b2_fin-schet for ub.fin-schet .
  define variable curr-rc as character no-undo .
  define variable v-curr-r-b as integer   no-undo .
  define variable num-fo as integer initial 0  no-undo .
  define variable sss as character no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-quit B-tax b-help FILL-code b-nal ~
FILL-sum b-val B-calc naznach-plat curr RECT-7 RECT-8
&Scoped-Define DISPLAYED-OBJECTS FILL-code b-nal FILL-sum b-val ~
naznach-plat curr

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-calc
     LABEL "Расчет сумм и курсов"
     SIZE 22 BY 1.

DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-tax
     LABEL "&Налоги"
     SIZE 10 BY 1.

DEFINE VARIABLE naznach-plat AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 51.5 BY 5.5 NO-UNDO.

DEFINE VARIABLE curr AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 6 BY .67 NO-UNDO.

DEFINE VARIABLE FILL-code AS CHARACTER FORMAT "X(16)":U
     LABEL "Номер"
     VIEW-AS FILL-IN
     SIZE 17.5 BY 1 NO-UNDO.

DEFINE VARIABLE FILL-sum AS DECIMAL FORMAT ">,>>>,>>>,>>>,>>9.99":U INITIAL 0
     LABEL "Сумма"
     VIEW-AS FILL-IN
     SIZE 24.5 BY 1 NO-UNDO.

DEFINE VARIABLE b-nal AS INTEGER INITIAL 1
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "б/н", 1,
"нал.", 2,
"АПЗ", 3
     SIZE 18 BY 1 NO-UNDO.

DEFINE VARIABLE b-val AS INTEGER INITIAL 1
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "abbr_rub_firstshift.", 1,
"Б.вал.", 2,
"Вал.дог.", 3
     SIZE 11 BY 2.5 NO-UNDO.

DEFINE RECTANGLE RECT-7
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 25.5 BY 1.5.

DEFINE RECTANGLE RECT-8
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 51.5 BY 3.75.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-tax AT ROW 1 COL 33
     b-help AT ROW 1 COL 43
     FILL-code AT ROW 2.25 COL 7 COLON-ALIGNED
     b-nal AT ROW 2.25 COL 34.5 NO-LABEL
     FILL-sum AT ROW 4 COL 26 COLON-ALIGNED
     b-val AT ROW 4.58 COL 3.13 NO-LABEL
     B-calc AT ROW 5.25 COL 30
     naznach-plat AT ROW 9.5 COL 1.5 NO-LABEL
     curr AT ROW 3.75 COL 10 COLON-ALIGNED NO-LABEL
     RECT-7 AT ROW 2 COL 27.5
     RECT-8 AT ROW 3.5 COL 1.5
     "Основание платежа" VIEW-AS TEXT
          SIZE 19.38 BY 1 AT ROW 8.25 COL 2
          FGCOLOR 4
     "Тип:" VIEW-AS TEXT
          SIZE 5 BY .83 AT ROW 2.25 COL 28.5
          FGCOLOR 4
     "Валюта:" VIEW-AS TEXT
          SIZE 9 BY .83 AT ROW 3.67 COL 3
          FGCOLOR 4
     SPACE(41.49) SKIP(10.57)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Новый платеж"
         DEFAULT-BUTTON b-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
   Other Settings: COMPILE
   Temp-Tables and Buffers:
      TABLE: tt-fin-doc T "?" NO-UNDO ub ub.fin-doc
      TABLE: tt0-fin-doc-attr T "?" NO-UNDO ub ub.fin-doc-attr
      TABLE: tt0-fin-doc-tax T "?" NO-UNDO ub ub.fin-doc-tax
      ADDITIONAL-FIELDS:
          INDEX pi1 vat-pc slt-pc with-vat with-slt

      END-FIELDS.
      TABLE: tt0-payment T "?" NO-UNDO ub ub.payment
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
                                                                        */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       FILL-sum:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Новый платеж */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-calc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-calc Dialog-Frame
ON CHOOSE OF B-calc IN FRAME Dialog-Frame /* Расчет сумм и курсов */
DO:
  define variable old-sum as decimal   no-undo .
  assign old-sum = tt-fin-doc.sum-doc .

  run ref/findclci.w (
   INPUT          parParentProc
  ,input          "":U /*p-mode про запас*/
  ,INPUT          tt-fin-doc.doc-date
  ,INPUT          tt-fin-doc.curr-code
  ,INPUT          v-curr-r-b
  ,INPUT          tt-fin-doc.contract-curr
  ,INPUT-OUTPUT   tt-fin-doc.sum-doc
  ,INPUT-OUTPUT   tt-fin-doc.exch-rate
  ,INPUT-OUTPUT   tt-fin-doc.exch-scale
  ,INPUT-OUTPUT   tt-fin-doc.sum-rubl
  ,INPUT-OUTPUT   tt-fin-doc.sum-base
  ,INPUT-OUTPUT   tt-fin-doc.base-rate
  ,INPUT-OUTPUT   tt-fin-doc.base-scale
  ,INPUT-OUTPUT   tt-fin-doc.sum-contr
  ,INPUT-OUTPUT   tt-fin-doc.contract-rate
  ,INPUT-OUTPUT   tt-fin-doc.contract-scale ) no-error.
  if error-status:error then return no-apply.
  assign FILL-sum = tt-fin-doc.sum-doc .
  DISPLAY FILL-sum WITH FRAME Dialog-Frame.
  if tt-fin-doc.sum-doc <> tt-fin-doc.sum-doc then run CorrectNalog in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit Dialog-Frame
ON CHOOSE OF b-exit IN FRAME Dialog-Frame /* Ввод */
DO:
  assign naznach-plat FILL-code .
  run CreateDoc no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-nal
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-nal Dialog-Frame
ON VALUE-CHANGED OF b-nal IN FRAME Dialog-Frame
DO:
 if b-nal:screen-value = "1" then do:
   if not available b1_fin-schet or not available b2_fin-schet then do:
      message  "Не найден счет плательщика или получателя."   view-as alert-box.
      assign b-nal:screen-value = string(b-nal) .
      return .
    end.
  end.
  assign b-nal .
  if b-nal = 1 then do:
    DISABLE b-val WITH FRAME Dialog-Frame .
    case b2_fin-schet.curr-code :
      when 0 then assign tt-fin-doc.sum-doc = tt-fin-doc.sum-rubl .
      when v-curr-r-b then assign tt-fin-doc.sum-doc = tt-fin-doc.sum-base .
      when buf_contract.curr-code then assign tt-fin-doc.sum-doc = tt-fin-doc.sum-contr .
      otherwise do:
        { gbl/exchrate.i  b2_fin-schet.curr-code today tt-fin-doc.exch-rate tt-fin-doc.exch-scale curr-rc }
        assign tt-fin-doc.sum-doc = tt-fin-doc.sum-rubl * tt-fin-doc.exch-scale / tt-fin-doc.exch-rate  .
        assign  FILL-sum = tt-fin-doc.sum-doc .
      end.
    end.

    assign
      curr = curr-rc
      tt-fin-doc.curr-code = b1_fin-schet.curr-code
    .
    assign naznach-plat .
    define variable si as character no-undo .
    si = entry(2,naznach-plat,'@') no-error .
    if si = "" then assign
      tt-fin-doc.naznach-plat = tt-fin-doc.naznach-plat + "@" + tt-fin-doc.including
      naznach-plat = tt-fin-doc.naznach-plat
    .
    DISPLAY curr FILL-sum naznach-plat WITH FRAME Dialog-Frame.
  end.
  else do:
    ENABLE  b-val WITH FRAME Dialog-Frame .
    apply "VALUE-CHANGED"  to b-val in frame {&frame-name}.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-quit Dialog-Frame
ON CHOOSE OF b-quit IN FRAME Dialog-Frame /* Отмена */
DO:
  message "Вы действительно хотите отменить создание платежа?" view-as alert-box QUESTION BUTTONS YES-NO UPDATE g-log .
  if g-log = no then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-tax
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-tax Dialog-Frame
ON CHOOSE OF B-tax IN FRAME Dialog-Frame /* Налоги */
DO:
  run ref/fndocti.w (
                  INPUT parParentProc
                  ,input p-host-code
                  ,input {&add-def}
                  ,input tt-fin-doc.host-code
                  ,input tt-fin-doc.fin-doc-code
                  ,input tt-fin-doc.fin-doc-type
                  ,input tt-fin-doc.fin-ext-doc-type
                  ,input tt-fin-doc.trn-doc-code
                  ,input tt-fin-doc.contract-code
                  ,input tt-fin-doc.sum-doc
                  ,input tt-fin-doc.curr-code
                  ,input tt-fin-doc.base-rate
                  ,input tt-fin-doc.base-scale
                  ,input tt-fin-doc.exch-rate
                  ,input tt-fin-doc.exch-scale
                  ,input tt-fin-doc.obj-type
                  ,input tt-fin-doc.obj-code
                  ,input-output table tt0-fin-doc-tax
                  ,input 0 /*chip-num в моде показа истории*/
                  ).
  assign naznach-plat .
  if num-entries(naznach-plat, "@":U) > 1 then do:
    assign sss = ""  .
    run StrTax (input-output sss) .
    assign  entry(2, naznach-plat, "@":U) = sss.
    DISPLAY naznach-plat WITH FRAME Dialog-Frame.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-val
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-val Dialog-Frame
ON VALUE-CHANGED OF b-val IN FRAME Dialog-Frame
DO:
  assign b-val .
  case b-val :
    when 1 then do:
      find first ub.currency no-lock where ub.currency.curr-code = 0 .
      assign
        FILL-sum = tt-fin-doc.sum-rubl
        tt-fin-doc.curr-code = 0
      .
    end.
    when 2 then do:
      find first ub.currency no-lock where ub.currency.curr-code = v-curr-r-b .
      assign
        FILL-sum = tt-fin-doc.sum-base
        tt-fin-doc.curr-code = v-curr-r-b
      .
    end.
    when 3 then do:
      find first ub.currency no-lock where ub.currency.curr-code = buf_contract.curr-code .
      assign
        FILL-sum = tt-fin-doc.sum-contr
        tt-fin-doc.curr-code = buf_contract.curr-code
      .
    end.
  end.
  assign curr = ub.currency.curr-abbr .
  DISPLAY curr WITH FRAME Dialog-Frame.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */
{ gbl/app_help.i }

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

  { gbl/basecode.i p-host-code v-curr-r-b }

  { gbl/ed-uho.i  naznach-plat 1 }

  find first ub.sysconf no-lock where ub.sysconf.host-code = p-host-code .
  find first ub.firm no-lock where ub.firm.firm-code = p-host-code .

  run StartProc in this-procedure .
  assign
    tt-fin-doc.prn-doc-code = string(tt-fin-doc.fin-doc-code)
    FILL-sum     = tt-fin-doc.sum-doc
    naznach-plat = tt-fin-doc.naznach-plat
    FILL-code    = tt-fin-doc.prn-doc-code
  .

  case buf_contract.pay-nal :
    when no  then assign b-nal = 1 .
    when yes then assign b-nal = 2 .
    when ?   then assign b-nal = 3 .
  end.

  case tt-fin-doc.contract-curr :
    when 0          then             assign b-val = 1 .
    when v-curr-r-b then             assign b-val = 2 .
    when buf_contract.curr-code then assign b-val = 3 .
    otherwise                        assign b-val = 1 .
  end.
  assign
  b-val:radio-buttons in frame {&frame-name} =
  "{&abbr_rub_firstshift}." + {&comma-char} + "1" + {&comma-char} +
  "Б.вал." + {&comma-char} + "2" + {&comma-char} +
  "Вал.дог." + {&comma-char} + "3"
  .

  RUN enable_UI.

  apply "VALUE-CHANGED"  to b-nal in frame {&frame-name}.

  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE CorrectNalog Dialog-Frame
PROCEDURE CorrectNalog :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  do
  on error undo, return error return-value
  :
    for each tt0-fin-doc-tax : delete tt0-fin-doc-tax . end.
    create tt0-fin-doc-tax .
    assign
      tt0-fin-doc-tax.fin-doc-code       = tt-fin-doc.fin-doc-code
      tt0-fin-doc-tax.host-code          = p-host-code
      tt0-fin-doc-tax.line-num           = 1
      tt0-fin-doc-tax.VAT-pc             = buf_contract.fin-VAT-pc
      tt0-fin-doc-tax.sum-line-doc       =  tt-fin-doc.sum-doc
      tt0-fin-doc-tax.sum-vat-line-doc   =  tt-fin-doc.sum-doc * buf_contract.fin-VAT-pc / (100 + buf_contract.fin-VAT-pc)
      tt0-fin-doc-tax.sum-line-rubl      =  tt-fin-doc.sum-rubl
      tt0-fin-doc-tax.sum-vat-line-rubl  =  tt-fin-doc.sum-rubl * buf_contract.fin-VAT-pc / (100 + buf_contract.fin-VAT-pc)
      tt0-fin-doc-tax.sum-line-base      =  tt-fin-doc.sum-base
      tt0-fin-doc-tax.sum-vat-line-base  =  tt-fin-doc.sum-base * buf_contract.fin-VAT-pc / (100 + buf_contract.fin-VAT-pc)
      tt0-fin-doc-tax.sum-line-contr     =  tt-fin-doc.sum-contr
      tt0-fin-doc-tax.sum-vat-line-contr =  tt-fin-doc.sum-contr * buf_contract.fin-VAT-pc / (100 + buf_contract.fin-VAT-pc)
    .
  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE CreateDoc Dialog-Frame
PROCEDURE CreateDoc :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  do on error undo, return error return-value :
    assign
      tt-fin-doc.naznach-plat = naznach-plat
      tt-fin-doc.prn-doc-code = FILL-code
    .
    if b-nal > 1 then do:
      case b-val:
        when 1 then assign tt-fin-doc.curr-code = 0 .
        when 2 then assign tt-fin-doc.curr-code = v-curr-r-b .
        when 3 then assign tt-fin-doc.curr-code = buf_contract.curr-code .
      end.
      assign
        tt-fin-doc.receiver-code-schet = 0
        tt-fin-doc.receiver-bank-name  = ""
        tt-fin-doc.receiver-c-schet    = ""
        tt-fin-doc.receiver-r-schet    = ""
        tt-fin-doc.payer-code-schet = 0
        tt-fin-doc.payer-bank-name  = ""
        tt-fin-doc.payer-c-schet    = ""
        tt-fin-doc.payer-r-schet    = ""
      .
    end.
    else do:
      if not available b1_fin-schet or not available b2_fin-schet then do:
        message  "Не найден счет плательщика или получателя."   view-as alert-box.
        return error .
      end.
      assign tt-fin-doc.curr-code    = b1_fin-schet.curr-code .
    end.

   if is-expense then
     assign
       tt-fin-doc.payer-sign1        = ub.firm.director
       tt-fin-doc.payer-sign2        = ub.sysconf.snr-accnt
       tt-fin-doc.payer-sign3        = ub.sysconf.cashier
     .
   else
     assign
       tt-fin-doc.receiver-sign1        = ub.firm.director
       tt-fin-doc.receiver-sign2        = ub.sysconf.snr-accnt
       tt-fin-doc.receiver-sign3        = ub.sysconf.cashier
     .

    case b-nal :
      when 1 then do:
        if b1_fin-schet.curr-code <> b2_fin-schet.curr-code then do:
          message "Валюта счета плательщика отличается от валюты счета получателя." view-as alert-box.
          return error .
        end.
        if buf_contract.doc-type = {&income} then do:
          if is-expense then do:
            assign
            tt-fin-doc.fin-doc-type = {&expense-cashless}
            tt-fin-doc.fin-ext-doc-type = {&FDEDT_Expense_Cashless}
            .
          end.
          else do:
            assign
            tt-fin-doc.fin-doc-type = {&income-cashless}
            tt-fin-doc.fin-ext-doc-type = {&FDEDT_Income_Cashless}
            .
          end.
        end.
        else do:
          if is-expense then do:
            assign
            tt-fin-doc.fin-doc-type = {&income-cashless}
            tt-fin-doc.fin-ext-doc-type = {&FDEDT_Income_Cashless}
            .
          end.
          else do:
            assign
            tt-fin-doc.fin-doc-type = {&expense-cashless}
            tt-fin-doc.fin-ext-doc-type = {&FDEDT_Expense_Cashless}
            .
          end.
        end.
      end.
      when 2 then do:
        run StrTax (input-output tt-fin-doc.including) .
        if buf_contract.doc-type = {&income} then do:
          if is-expense then do:
            assign
            tt-fin-doc.fin-doc-type = {&expense-cash}
            tt-fin-doc.fin-ext-doc-type = {&FDEDT_Expense_Cash}
            .
        end.
        else do:
            assign
            tt-fin-doc.fin-doc-type = {&income-cash}
            tt-fin-doc.fin-ext-doc-type = {&FDEDT_Income_Cash}
            .
          end.
        end.
        else do:
          if is-expense then do:
            assign
            tt-fin-doc.fin-doc-type = {&income-cash}
            tt-fin-doc.fin-ext-doc-type = {&FDEDT_Income_Cash}
            .
          end.
          else do:
            assign
            tt-fin-doc.fin-doc-type = {&expense-cash}
            tt-fin-doc.fin-ext-doc-type = {&FDEDT_expense_Cash}
            .
          end.
        end.
      end.
      when 3 then do:
        if buf_contract.doc-type = {&income} then do:
          if is-expense then do:
            assign
            tt-fin-doc.fin-doc-type = {&expense-payoff}
            tt-fin-doc.fin-ext-doc-type = {&FDEDT_expense_payoff}
            .
          end.
          else do:
            assign
            tt-fin-doc.fin-doc-type = {&income-payoff}
            tt-fin-doc.fin-ext-doc-type = {&FDEDT_income_payoff}
            .
          end.
        end.
        else do:
          if is-expense then do:
            assign
            tt-fin-doc.fin-doc-type = {&income-payoff}
            tt-fin-doc.fin-ext-doc-type = {&FDEDT_income_payoff}
            .
        end.
        else do:
            assign
            tt-fin-doc.fin-doc-type = {&expense-payoff}
            tt-fin-doc.fin-ext-doc-type = {&FDEDT_expense_payoff}
            .
          end.
        end.
      end.
    end.


    define variable p-doc-rec as recid no-undo.

    &scop prfx tt-fin-doc.

    run UchetCode in this-procedure .

    /* округляем  */
    run RoundTax in this-procedure .

    tt-fin-doc.doc-author = "fin-ob".

    run ref/findoc0.p (
        input-output p-doc-rec
       ,input {&add-def}
       ,input no /*p-silent*/
       {&all-fin-doc-params-doc-status-transfer}
       {&all-fin-doc-params-doc-status-transfer-2}
       ,input table tt0-fin-doc-tax
       ,input table tt0-fin-doc-attr
       ,input no /*p-save-payment*/
       ,input table tt0-payment
     ) no-error .
    if error-status:error then do:
      undo, return error.
    end.
    assign p-ri = p-doc-rec .
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

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
  DISPLAY FILL-code b-nal FILL-sum b-val naznach-plat curr
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-quit B-tax b-help FILL-code b-nal FILL-sum b-val B-calc
         naznach-plat curr RECT-7 RECT-8
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE RoundTax Dialog-Frame
PROCEDURE RoundTax :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  do
  on error undo, return error return-value
  :
    for each tt0-fin-doc-tax :
      assign
        tt0-fin-doc-tax.sum-line-doc       =  ROUND( tt0-fin-doc-tax.sum-line-doc      , 2)
        tt0-fin-doc-tax.sum-vat-line-doc   =  ROUND( tt0-fin-doc-tax.sum-vat-line-doc  , 2)
        tt0-fin-doc-tax.sum-line-rubl      =  ROUND( tt0-fin-doc-tax.sum-line-rubl     , 2)
        tt0-fin-doc-tax.sum-vat-line-rubl  =  ROUND( tt0-fin-doc-tax.sum-vat-line-rubl , 2)
        tt0-fin-doc-tax.sum-line-base      =  ROUND( tt0-fin-doc-tax.sum-line-base     , 2)
        tt0-fin-doc-tax.sum-vat-line-base  =  ROUND( tt0-fin-doc-tax.sum-vat-line-base , 2)
/*        tt0-fin-doc-tax.sum-line-contr     =  ROUND( tt0-fin-doc-tax.sum-line-contr    , 2)*/
/*        tt0-fin-doc-tax.sum-vat-line-contr =  ROUND( tt0-fin-doc-tax.sum-vat-line-contr, 2)*/
      .
    end.
  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE StartProc Dialog-Frame
PROCEDURE StartProc :
  do
  on error undo, return error return-value
  :
    define variable line as integer   no-undo .
    define buffer b_fin-ob for ub.fin-ob .
    define variable num-cont as integer  no-undo .
    define variable pay-type as character no-undo .
    define variable rec-type as character no-undo .
    define variable obj-type as character no-undo .
    define variable pay-code as integer no-undo .
    define variable rec-code as integer no-undo .
    define variable obj-code as integer no-undo .
    define variable is-full-sum as logical   no-undo .
    define variable p-koef-rubl as decimal   no-undo .
    define variable p-koef-base as decimal   no-undo .
    define variable p-koef-cont as decimal   no-undo .
    define variable p-koef-doc  as decimal   no-undo .
    define variable v-fd-code as integer no-undo .
/*run inidebug.p .*/
    assign
      num-cont = - 1
      line = 1
      is-full-sum = yes .
    .
    for each temp-fin-ob :
      find first b_fin-ob no-lock where recid(b_fin-ob) = temp-fin-ob.ri .
      if b_fin-ob.con-stat = 2 then do:
        message
          "Фин. обязательство № " b_fin-ob.prn-doc-code " (дата платежа " b_fin-ob.pay-date ") уже полностью связано с платежем!"
        view-as alert-box.
        return error .
      end.
      if b_fin-ob.contract-code < 1 then do:
        message "Автоматическая оплата фин. обязательств без договора невозможна! Фин. обязательство № " b_fin-ob.prn-doc-code " (дата платежа " b_fin-ob.pay-date "). " view-as alert-box.
        return error .
      end.
      assign num-fo = num-fo + 1 .

      if num-cont = - 1 then do:  /* первое об-во */
        find first buf_contract no-lock where buf_contract.host-code = p-host-code and buf_contract.contract-code = b_fin-ob.contract-code no-error .
        assign
          num-cont = b_fin-ob.contract-code
          pay-type = b_fin-ob.payer-type
          pay-code = b_fin-ob.payer-code
          rec-type = b_fin-ob.receiver-type
          rec-code = b_fin-ob.receiver-code
          obj-type = b_fin-ob.obj-type
          obj-code = b_fin-ob.obj-code
        .
        run gen-b-code in this-procedure ( input {&gbl-fd-code}
                                        , output v-fd-code) no-error .
        if error-status:error then do:
          define variable v-mess as character no-undo .
          v-mess = substitute("Ошибка при генерации внутреннего номера фин. док-та:&1&2&1&3"
                                      , {&new-line}
                                      , error-status:get-message(1)
                                      , return-value ).

          message
          v-mess
          view-as alert-box error .
          undo, return error .
        end.

        create tt-fin-doc .
        assign
          tt-fin-doc.host-code       = p-host-code
          tt-fin-doc.fin-doc-code    = v-fd-code
/*          tt-fin-doc.prn-doc-code    = string(tt-fin-doc.fin-doc-code)*/
          tt-fin-doc.contract-code   = b_fin-ob.contract-code
          tt-fin-doc.contract-curr   = b_fin-ob.contract-curr
          tt-fin-doc.curr-code       = b_fin-ob.curr-code
          tt-fin-doc.doc-date        = today
          tt-fin-doc.prn-doc-code    = ""
          tt-fin-doc.PS              = ""
          tt-fin-doc.ocher-pl        = "6"
          tt-fin-doc.stat-pl         = ""
          tt-fin-doc.naznach-plat    = "Оплата по договору № " + buf_contract.contract-prn-code + " от " + string( buf_contract.contract-date,"99/99/9999")
          tt-fin-doc.payer-name      = b_fin-ob.payer-name
          tt-fin-doc.payer-code      = b_fin-ob.payer-code
          tt-fin-doc.payer-type      = b_fin-ob.payer-type
          tt-fin-doc.receiver-code   = b_fin-ob.receiver-code
          tt-fin-doc.receiver-name   = b_fin-ob.receiver-name
          tt-fin-doc.receiver-type   = b_fin-ob.receiver-type
          tt-fin-doc.sum-base        = b_fin-ob.sum-base     - b_fin-ob.con-sum-base
          tt-fin-doc.sum-rubl        = b_fin-ob.sum-rubl     - b_fin-ob.con-sum-rubl
          tt-fin-doc.sum-contr       = b_fin-ob.sum-contract - b_fin-ob.con-sum-contr
          tt-fin-doc.sum-doc         = b_fin-ob.sum-doc      - b_fin-ob.con-sum-doc
          tt-fin-doc.base-scale      = b_fin-ob.base-scale
          tt-fin-doc.contract-scale  = b_fin-ob.contract-scale
          tt-fin-doc.exch-scale      = b_fin-ob.exch-scale
          p-koef-rubl                = ( b_fin-ob.sum-rubl     - b_fin-ob.con-sum-rubl ) / b_fin-ob.sum-rubl
          p-koef-base                = ( b_fin-ob.sum-rubl     - b_fin-ob.con-sum-base ) / b_fin-ob.sum-rubl
          p-koef-cont                = ( b_fin-ob.sum-contract - b_fin-ob.con-sum-contr) / b_fin-ob.sum-contract
          p-koef-doc                 = ( b_fin-ob.sum-doc      - b_fin-ob.con-sum-doc  ) / b_fin-ob.sum-doc
        .
        run CheckCli no-error .
        if error-status:error then do:
          message "Несоответствие плательщика или получателя договору!" view-as alert-box.
          return error .
        end.
        run FindBank .
      end.
      else do: /* не первое фин.об. */
        /* проверка на совпадение */
        if num-cont <> b_fin-ob.contract-code then do:
          message "Фин. обязательство № " b_fin-ob.prn-doc-code " (дата платежа " b_fin-ob.pay-date ") относится к другому договору, чем предыдущие док-ты!"
          view-as alert-box.
          return error .
        end.
        if pay-type <> b_fin-ob.payer-type or pay-code <> b_fin-ob.payer-code then do:
          message "Плательщик в фин. обяз. № " b_fin-ob.prn-doc-code " (дата платежа " b_fin-ob.pay-date ") иной, чем в предыдущих док-тах! Продолжить? (В платеж будет прописан плательщик 1-го фин.обяз.)"
          view-as alert-box QUESTION BUTTONS YES-NO UPDATE g-log .
          if g-log = no then return error.
        end.
        if rec-type <> b_fin-ob.receiver-type or rec-code <> b_fin-ob.receiver-code then do:
          message "Получатель в фин. обяз. № " b_fin-ob.prn-doc-code " (дата платежа " b_fin-ob.pay-date ") иной, чем в предыдущих док-тах! Продолжить? (В платеж будет прописан получатель 1-го фин.обяз.)"
          view-as alert-box QUESTION BUTTONS YES-NO UPDATE g-log .
          if g-log = no then return error.
        end.
        if obj-code <> 0 then do:
          if obj-type <> b_fin-ob.obj-type or obj-code <> b_fin-ob.obj-code then assign obj-code = 0 .
        end.

        assign
          tt-fin-doc.sum-base  = tt-fin-doc.sum-base  + b_fin-ob.sum-base     - b_fin-ob.con-sum-base
          tt-fin-doc.sum-rubl  = tt-fin-doc.sum-rubl  + b_fin-ob.sum-rubl     - b_fin-ob.con-sum-rubl
          tt-fin-doc.sum-contr = tt-fin-doc.sum-contr + b_fin-ob.sum-contract - b_fin-ob.con-sum-contr
          tt-fin-doc.sum-doc   = tt-fin-doc.sum-doc   + b_fin-ob.sum-doc      - b_fin-ob.con-sum-doc
          p-koef-rubl          = ( b_fin-ob.sum-rubl     - b_fin-ob.con-sum-rubl ) / b_fin-ob.sum-rubl
          p-koef-base          = ( b_fin-ob.sum-rubl     - b_fin-ob.con-sum-base ) / b_fin-ob.sum-rubl
          p-koef-cont          = ( b_fin-ob.sum-contract - b_fin-ob.con-sum-contr) / b_fin-ob.sum-contract
          p-koef-doc           = ( b_fin-ob.sum-doc      - b_fin-ob.con-sum-doc  ) / b_fin-ob.sum-doc
        .
      end.

      for each ub.fin-ob-tax no-lock where ub.fin-ob-tax.host-code = p-host-code and ub.fin-ob-tax.doc-code = b_fin-ob.doc-code :
        find first tt0-fin-doc-tax
          where tt0-fin-doc-tax.vat-pc   = ub.fin-ob-tax.vat-pc
            and tt0-fin-doc-tax.slt-pc   = ub.fin-ob-tax.slt-pc
            and tt0-fin-doc-tax.with-vat = ub.fin-ob-tax.with-vat
            and tt0-fin-doc-tax.with-slt = ub.fin-ob-tax.with-slt
        no-error .

        if not available tt0-fin-doc-tax then do:
          create tt0-fin-doc-tax .
          BUFFER-COPY ub.fin-ob-tax TO tt0-fin-doc-tax .
          assign
            tt0-fin-doc-tax.fin-doc-code = tt-fin-doc.fin-doc-code
            tt0-fin-doc-tax.host-code    = p-host-code
            tt0-fin-doc-tax.line-num     = line
            line = line + 1
            tt0-fin-doc-tax.sum-line-doc       = tt0-fin-doc-tax.sum-line-doc       * p-koef-doc
            tt0-fin-doc-tax.sum-vat-line-doc   = tt0-fin-doc-tax.sum-vat-line-doc   * p-koef-doc
            tt0-fin-doc-tax.sum-slt-line-doc   = tt0-fin-doc-tax.sum-slt-line-doc   * p-koef-doc
            tt0-fin-doc-tax.sum-line-rubl      = tt0-fin-doc-tax.sum-line-rubl      * p-koef-rubl
            tt0-fin-doc-tax.sum-vat-line-rubl  = tt0-fin-doc-tax.sum-vat-line-rubl  * p-koef-rubl
            tt0-fin-doc-tax.sum-slt-line-rubl  = tt0-fin-doc-tax.sum-slt-line-rubl  * p-koef-rubl
            tt0-fin-doc-tax.sum-line-base      = tt0-fin-doc-tax.sum-line-base      * p-koef-base
            tt0-fin-doc-tax.sum-vat-line-base  = tt0-fin-doc-tax.sum-vat-line-base  * p-koef-base
            tt0-fin-doc-tax.sum-slt-line-base  = tt0-fin-doc-tax.sum-slt-line-base  * p-koef-base
            tt0-fin-doc-tax.sum-line-contr     = tt0-fin-doc-tax.sum-line-contr     * p-koef-cont
            tt0-fin-doc-tax.sum-vat-line-contr = tt0-fin-doc-tax.sum-vat-line-contr * p-koef-cont
            tt0-fin-doc-tax.sum-slt-line-contr = tt0-fin-doc-tax.sum-slt-line-contr * p-koef-cont
          .
        end.
        else do:
          assign
            tt0-fin-doc-tax.sum-line-doc       = tt0-fin-doc-tax.sum-line-doc       + ub.fin-ob-tax.sum-line-doc       * p-koef-doc
            tt0-fin-doc-tax.sum-vat-line-doc   = tt0-fin-doc-tax.sum-vat-line-doc   + ub.fin-ob-tax.sum-vat-line-doc   * p-koef-doc
            tt0-fin-doc-tax.sum-slt-line-doc   = tt0-fin-doc-tax.sum-slt-line-doc   + ub.fin-ob-tax.sum-slt-line-doc   * p-koef-doc
            tt0-fin-doc-tax.sum-line-rubl      = tt0-fin-doc-tax.sum-line-rubl      + ub.fin-ob-tax.sum-line-rubl      * p-koef-rubl
            tt0-fin-doc-tax.sum-vat-line-rubl  = tt0-fin-doc-tax.sum-vat-line-rubl  + ub.fin-ob-tax.sum-vat-line-rubl  * p-koef-rubl
            tt0-fin-doc-tax.sum-slt-line-rubl  = tt0-fin-doc-tax.sum-slt-line-rubl  + ub.fin-ob-tax.sum-slt-line-rubl  * p-koef-rubl
            tt0-fin-doc-tax.sum-line-base      = tt0-fin-doc-tax.sum-line-base      + ub.fin-ob-tax.sum-line-base      * p-koef-base
            tt0-fin-doc-tax.sum-vat-line-base  = tt0-fin-doc-tax.sum-vat-line-base  + ub.fin-ob-tax.sum-vat-line-base  * p-koef-base
            tt0-fin-doc-tax.sum-slt-line-base  = tt0-fin-doc-tax.sum-slt-line-base  + ub.fin-ob-tax.sum-slt-line-base  * p-koef-base
            tt0-fin-doc-tax.sum-line-contr     = tt0-fin-doc-tax.sum-line-contr     + ub.fin-ob-tax.sum-line-contr     * p-koef-cont
            tt0-fin-doc-tax.sum-vat-line-contr = tt0-fin-doc-tax.sum-vat-line-contr + ub.fin-ob-tax.sum-vat-line-contr * p-koef-cont
            tt0-fin-doc-tax.sum-slt-line-contr = tt0-fin-doc-tax.sum-slt-line-contr + ub.fin-ob-tax.sum-slt-line-contr * p-koef-cont
          .
        end.
      end.
    end.

    if obj-code <> 0 then do:   /* все было с 1 объекта */
      assign
        tt-fin-doc.obj-type = obj-type
        tt-fin-doc.obj-code = obj-code
      .
    end.
    else do:
      if ub.sysconf.fin-calc = {&fin-calc-obj} then do:
        message
          substitute ("По фирме &1 ведется раздельный учет по объектам с поставщиками. Нельзя создать платеж по ФО с разных объектов.",sysconf.host-code)
        view-as alert-box.
        return error .
      end.
    end.

    /* посчитаем курсы по факту */
    assign
      tt-fin-doc.base-rate       = if tt-fin-doc.sum-base  <> 0 then tt-fin-doc.sum-rubl * tt-fin-doc.base-scale / tt-fin-doc.sum-base      else 0
      tt-fin-doc.contract-rate   = if tt-fin-doc.sum-contr <> 0 then tt-fin-doc.sum-rubl * tt-fin-doc.contract-scale / tt-fin-doc.sum-contr else 0
      tt-fin-doc.exch-rate       = if tt-fin-doc.sum-doc   <> 0 then tt-fin-doc.sum-rubl * tt-fin-doc.exch-scale / tt-fin-doc.sum-doc       else 0
    .
    /* ecли вал сета <> р_у_бл, б.в. или вал дог, то считаем */
    if not available b1_fin-schet or not available b2_fin-schet then do:
      if buf_contract.pay-nal = no then do:
        message  "Не найден счет плательщика или получателя."   view-as alert-box.
        return error .
      end.
    end.
    else do:
      find first ub.currency no-lock where ub.currency.curr-code = b2_fin-schet.curr-code .
      assign  curr-rc = ub.currency.curr-abbr  .
      if buf_contract.pay-nal = no then do:
        assign
          curr = ub.currency.curr-abbr
          tt-fin-doc.curr-code = b2_fin-schet.curr-code
        .

        case b2_fin-schet.curr-code :
          when 0 then do:
            assign tt-fin-doc.sum-doc = tt-fin-doc.sum-rubl .
            for each tt0-fin-doc-tax no-lock :
              assign
                tt0-fin-doc-tax.sum-line-doc       = tt0-fin-doc-tax.sum-line-rubl
                tt0-fin-doc-tax.sum-vat-line-doc   = tt0-fin-doc-tax.sum-vat-line-rubl
                tt0-fin-doc-tax.sum-slt-line-doc   = tt0-fin-doc-tax.sum-slt-line-rubl
              .
            end.
          end.
          when v-curr-r-b then do:
            assign tt-fin-doc.sum-doc = tt-fin-doc.sum-base .
            for each tt0-fin-doc-tax no-lock :
              assign
                tt0-fin-doc-tax.sum-line-doc       = tt0-fin-doc-tax.sum-line-base
                tt0-fin-doc-tax.sum-vat-line-doc   = tt0-fin-doc-tax.sum-vat-line-base
                tt0-fin-doc-tax.sum-slt-line-doc   = tt0-fin-doc-tax.sum-slt-line-base
              .
            end.
          end.
          when buf_contract.curr-code then do:
            assign tt-fin-doc.sum-doc = tt-fin-doc.sum-contr .
            for each tt0-fin-doc-tax no-lock :
              assign
                tt0-fin-doc-tax.sum-line-doc       = tt0-fin-doc-tax.sum-line-contr
                tt0-fin-doc-tax.sum-vat-line-doc   = tt0-fin-doc-tax.sum-vat-line-contr
                tt0-fin-doc-tax.sum-slt-line-doc   = tt0-fin-doc-tax.sum-slt-line-contr
              .
            end.
          end.
          otherwise do:
            { gbl/exchrate.i  b2_fin-schet.curr-code today tt-fin-doc.exch-rate tt-fin-doc.exch-scale curr-rc }
            assign
              is-full-sum = no
              tt-fin-doc.sum-doc = tt-fin-doc.sum-rubl * tt-fin-doc.exch-scale / tt-fin-doc.exch-rate

            .
          end.
        end.
      end.
    end.

    assign is-expense = yes .
    if tt-fin-doc.sum-rubl < 0 then do: /* надо перевернуть плател-получателя */
      assign is-expense = no .
      run InvertCli .
    end.
    for each tt0-fin-doc-tax :   if tt0-fin-doc-tax.sum-line-doc < 0 then assign is-full-sum = no .   end.
    if is-full-sum = no then do: /* берем налоги из договора */
      run CorrectNalog in this-procedure .
    end.
    run RoundTax in this-procedure .

    if buf_contract.pay-nal = no then do:  /* вставляем разбивку по налогам */
      run StrTax (input-output sss) .
      assign tt-fin-doc.naznach-plat = tt-fin-doc.naznach-plat + "@" + sss .
    end.
    else if buf_contract.pay-nal = yes then do:
      run StrTax (input-output tt-fin-doc.including) .
/*      assign tt-fin-doc.naznach-plat = tt-fin-doc.naznach-plat + "@" + tt-fin-doc.including .*/
    end.

  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

{ str/pay-fo.i }