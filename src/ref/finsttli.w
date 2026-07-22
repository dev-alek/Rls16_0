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

Ввод данных неучтенного в TH платежа

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/11/05
Author: Bakhtadze Natalya
Creation date: 11/11/05

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter p-start-date as date no-undo .
define input parameter p-end-date as date no-undo .
DEFINE output PARAMETER p-prn-doc-code AS CHARACTER NO-UNDO.
DEFINE output PARAMETER p-fin-ext-doc-type AS CHARACTER NO-UNDO.
define output parameter p-pay-date as date no-undo .
define output parameter p-bik as character no-undo .
define output parameter p-bank-name as character no-undo .
define output parameter p-bank-city as character no-undo .
define output parameter p-c-schet as character no-undo .
define output parameter p-r-schet as character no-undo .
define output parameter p-name as character no-undo .
define output parameter p-inn as character no-undo .
define output parameter p-kpp as character no-undo .
DEFINE output PARAMETER p-sum AS decimal NO-UNDO.
DEFINE output PARAMETER p-ps AS character NO-UNDO.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Ввод данных неучтенного в TH платежа".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }
DEFINE VARIABLE v-tab-order AS CHARACTER NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-Help f-prn-doc-code ~
S-fin-ext-doc-type f-bik f-bank-name f-bank-city f-c-schet f-r-schet f-name ~
f-inn f-kpp f-pay-date f-sum E-ps
&Scoped-Define DISPLAYED-OBJECTS f-prn-doc-code S-fin-ext-doc-type f-bik ~
f-bank-name f-bank-city f-c-schet f-r-schet f-name f-inn f-kpp f-pay-date ~
f-sum E-ps

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE E-ps AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 66 BY 4 NO-UNDO.

DEFINE VARIABLE f-bank-city AS CHARACTER FORMAT "X(20)":U
     LABEL "Город Банка"
     VIEW-AS FILL-IN
     SIZE 24.5 BY 1.07 NO-UNDO.

DEFINE VARIABLE f-bank-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Банк"
     VIEW-AS FILL-IN
     SIZE 87.5 BY 1.07 NO-UNDO.

DEFINE VARIABLE f-bik AS CHARACTER FORMAT "X(10)":U
     LABEL "БИК"
     VIEW-AS FILL-IN
     SIZE 11 BY 1 NO-UNDO.

DEFINE VARIABLE f-c-schet AS CHARACTER FORMAT "X(20)":U
     LABEL "Коррсчет"
     VIEW-AS FILL-IN
     SIZE 31.5 BY 1 NO-UNDO.

DEFINE VARIABLE f-inn AS CHARACTER FORMAT "X(20)":U
     LABEL "INN"
     VIEW-AS FILL-IN
     SIZE 24.5 BY 1.07 NO-UNDO.

DEFINE VARIABLE f-kpp AS CHARACTER FORMAT "X(20)":U
     LABEL "kpp"
     VIEW-AS FILL-IN
     SIZE 24.5 BY 1.07 NO-UNDO.

DEFINE VARIABLE f-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Плат/Получ"
     VIEW-AS FILL-IN
     SIZE 74.5 BY 1.07 NO-UNDO.

DEFINE VARIABLE f-pay-date AS DATE FORMAT "99/99/9999":U
     LABEL "Дата платежа"
     VIEW-AS FILL-IN
     SIZE 14.5 BY 1 NO-UNDO.

DEFINE VARIABLE f-prn-doc-code AS CHARACTER FORMAT "X(256)":U
     LABEL "№ платежа"
     VIEW-AS FILL-IN
     SIZE 31 BY 1 NO-UNDO.

DEFINE VARIABLE f-r-schet AS CHARACTER FORMAT "X(20)":U
     LABEL "Расчсчет"
     VIEW-AS FILL-IN
     SIZE 31.5 BY 1 NO-UNDO.

DEFINE VARIABLE f-sum AS DECIMAL FORMAT ">>>,>>>,>>9.99":U INITIAL 0
     LABEL "Сумма"
     VIEW-AS FILL-IN
     SIZE 30.5 BY 1 NO-UNDO.

DEFINE VARIABLE S-fin-ext-doc-type AS CHARACTER
     VIEW-AS SELECTION-LIST SINGLE SCROLLBAR-VERTICAL
     SIZE 31.5 BY 2 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 54.9
     f-prn-doc-code AT ROW 2.5 COL 11 COLON-ALIGNED
     S-fin-ext-doc-type AT ROW 2.5 COL 55 NO-LABEL
     f-bik AT ROW 4.5 COL 5 COLON-ALIGNED
     f-bank-name AT ROW 5.77 COL 5 COLON-ALIGNED
     f-bank-city AT ROW 7 COL 2.5
     f-c-schet AT ROW 8.27 COL 13.5 COLON-ALIGNED
     f-r-schet AT ROW 9.5 COL 13.5 COLON-ALIGNED
     f-name AT ROW 10.77 COL 3.5
     f-inn AT ROW 12 COL 10.5
     f-kpp AT ROW 12 COL 42
     f-pay-date AT ROW 13.27 COL 13.5 COLON-ALIGNED
     f-sum AT ROW 13.27 COL 43.5 COLON-ALIGNED
     E-ps AT ROW 15.67 COL 1 NO-LABEL
     "Примечания:" VIEW-AS TEXT
          SIZE 22.5 BY 1 AT ROW 14.33 COL 2
          FGCOLOR 4
     SPACE(70.99) SKIP(4.49)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Неучтенный в TH платеж"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.


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

/* SETTINGS FOR FILL-IN f-bank-city IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN f-inn IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN f-kpp IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN f-name IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Неучтенный в TH платеж */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Ввод */
DO:
  ASSIGN
  f-prn-doc-code
  f-bik
  f-bank-name
  f-bank-city
  f-r-schet
  f-c-schet
  f-name
  f-inn
  f-kpp
  f-pay-date
  f-sum
  S-fin-ext-doc-type

  .
  IF f-prn-doc-code = '':U THEN DO:
    MESSAGE
    "Введите номер платежа!"
    VIEW-AS ALERT-BOX ERROR.
    RETURN NO-APPLY.
  END.
  IF s-fin-ext-doc-type = "":U THEN DO:
    MESSAGE
    "Укажите тип платежа"
    VIEW-AS ALERT-BOX ERROR.
    RETURN NO-APPLY.
  END.
  IF f-bik = '':U
  and f-bank-name = '':U
  THEN DO:
      MESSAGE
      "Вы должны указать хотя бы один из следующих реквизитов:" SKIP
      "БИК, название банка"
      VIEW-AS ALERT-BOX ERROR.
      RETURN NO-APPLY.
  END.

  IF f-inn = '':U
  and f-kpp = '':U
  AND f-name = '':U THEN DO:
      MESSAGE
      "Вы должны указать хотя бы один из следующих реквизитов:" SKIP
      "{&abbr_inn_allshift}, {&abbr_kpp_allshift}, название Плат/Получ"
      VIEW-AS ALERT-BOX ERROR.
      RETURN NO-APPLY.
  END.
  IF f-r-schet = '':U THEN DO:
      MESSAGE
      "Укажите расч. счет"
      VIEW-AS ALERT-BOX ERROR.
      RETURN NO-APPLY.
  END.
  IF f-sum = ?
  OR f-sum < 0 THEN DO:
      MESSAGE
      "Укажите сумму платежа"
      VIEW-AS ALERT-BOX ERROR.
      RETURN NO-APPLY.
  END.
  if f-pay-date = ? then do:
    MESSAGE
    "Укажите дату платежа"
    VIEW-AS ALERT-BOX ERROR.
    RETURN NO-APPLY.
  end.
  if f-pay-date < p-start-date
  or f-pay-date > p-end-date then do:
    MESSAGE
    substitute("Дата платежа может быть: &1 - &2 ", p-start-date, p-end-date)
    VIEW-AS ALERT-BOX ERROR.
    RETURN NO-APPLY.
  end.
  ASSIGN
  p-prn-doc-code = f-prn-doc-code
  p-fin-ext-doc-type = s-fin-ext-doc-type
  p-bik = f-bik
  p-bank-name = f-bank-name
  p-bank-city = f-bank-city
  p-name = f-name
  p-c-schet = f-c-schet
  p-r-schet = f-r-schet
  p-inn = f-inn
  p-kpp = f-kpp
  p-pay-date = f-pay-date
  p-sum = f-sum
  p-ps = e-ps:SCREEN-VALUE
  .
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
{ gbl/ed_date.i f-pay-date }
{ gbl/rethndmv.i v-tab-order }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  RUN Myenable IN THIS-PROCEDURE.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

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
  DISPLAY f-prn-doc-code S-fin-ext-doc-type f-bik f-bank-name f-bank-city
          f-c-schet f-r-schet f-name f-inn f-kpp f-pay-date f-sum E-ps
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Help f-prn-doc-code S-fin-ext-doc-type f-bik
         f-bank-name f-bank-city f-c-schet f-r-schet f-name f-inn f-kpp
         f-pay-date f-sum E-ps
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
DEFINE VARIABLE V-ITEM-1 AS CHARACTER NO-UNDO.
DEFINE VARIABLE V-ITEM-2 AS CHARACTER NO-UNDO.
ASSIGN
f-kpp:label in frame {&frame-name} = "{&abbr_kpp_allshift}"
f-inn:label in frame {&frame-name} = "{&abbr_inn_allshift}"
v-tab-order = "f-prn-doc-code,S-fin-ext-doc-type,f-bik,f-bank-name,f-bank-city,f-c-schet," +
              "f-r-schet,f-name,f-inn,f-kpp,f-pay-date,f-sum,e-ps".

&SCOP fin-ext-doc-type-code   {&FDEDT_Income_Cashless}

V-ITEM-1 = {&fin-ext-doc-type-name} + {&COMMA-CHAR} +
            {&FDEDT_Income_Cashless} .

&SCOP fin-ext-doc-type-code  {&FDEDT_eXPENSE_Cashless}
V-ITEM-2 = {&fin-ext-doc-type-name} + {&COMMA-CHAR} +
            {&FDEDT_EXPENSE_Cashless}.

ASSIGN
s-fin-ext-doc-type:LIST-ITEM-PAIRS in frame {&frame-name} = V-ITEM-1 + {&COMMA-CHAR} + V-ITEM-2.

DISPLAY
f-prn-doc-code
S-fin-ext-doc-type
f-bik
f-bank-name
f-bank-city
f-c-schet
f-r-schet
f-name
f-inn
f-kpp
f-sum
WITH FRAME {&frame-name}.
ENABLE
B-exit
b-quit
B-Help
f-prn-doc-code
S-fin-ext-doc-type
f-bik
f-bank-name
f-bank-city
f-c-schet
f-r-schet
f-name
f-inn
f-kpp
f-pay-date
f-sum
E-PS
WITH FRAME {&frame-name}.
VIEW FRAME {&frame-name}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME