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

Задание атрибута группа типа кассовых платежей

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/16/04
Author: Bakhtadze Natalya
Creation date: 09/16/04

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
/* Parameters Definitions ---                                           */
define input parameter p-cdpay-code   like ub.cash-pay-attr.cdpay-code     no-undo .
define input parameter p-curr-code    like ub.cash-pay-attr.curr-code      no-undo .
define INPUT parameter p-host-code    like ub.cash-pay-attr.host-code      no-undo .
define INPUT parameter p-obj-type     like ub.cash-pay-attr.obj-type       no-undo .
define INPUT parameter p-obj-code     like ub.cash-pay-attr.obj-code       no-undo .
DEFINE INPUT-OUTPUT PARAMETER p-attr-value AS character NO-UNDO.
DEFINE OUTPUT PARAMETER p-ok AS logical NO-UNDO.
/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Задание атрибута группа типа кассовых платежей".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }
{ gbl/waitfram.i }

DEFINE VARIABLE v-obj-db-num LIKE ub.db.db-num NO-UNDO.
define variable cpgrpnam as character no-undo .
DEFINE VARIABLE v-dops AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-dopi AS INTEGER NO-UNDO.
DEFINE VARIABLE ii AS INTEGER NO-UNDO.
DEFINE VARIABLE v-ok AS LOGICAL NO-UNDO.
define variable v-param-type as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-tth as handle no-undo .


/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-Help S-grp-name
&Scoped-Define DISPLAYED-OBJECTS S-grp-name f-grp-code

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

DEFINE VARIABLE f-grp-code AS INTEGER FORMAT ">>>9":U INITIAL 0
     LABEL "Код группы"
     VIEW-AS FILL-IN
     SIZE 8 BY 1 NO-UNDO.

DEFINE VARIABLE S-grp-name AS CHARACTER
     VIEW-AS SELECTION-LIST SINGLE SCROLLBAR-VERTICAL
     SIZE 26 BY 5.25 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 54.88
     S-grp-name AT ROW 2.5 COL 21 NO-LABEL
     f-grp-code AT ROW 8 COL 19 COLON-ALIGNED
     SPACE(39.74) SKIP(1.57)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Группа типа кассового платежа"
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

/* SETTINGS FOR FILL-IN f-grp-code IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Группа типа кассового платежа */
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
  s-grp-name.
  f-grp-code = INTEGER(s-grp-name).
  RUN proc-save IN THIS-PROCEDURE(s-grp-name:LOOKUP(s-grp-name)) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
      RETURN NO-APPLY.
  END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME S-grp-name
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL S-grp-name Dialog-Frame
ON VALUE-CHANGED OF S-grp-name IN FRAME Dialog-Frame
DO:

  ASSIGN
  s-grp-name.

  f-grp-code = INTEGER(s-grp-name).
  DISPLAY f-grp-code
  WITH FRAME {&FRAME-NAME}.
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
  /*найдем настройку*/
  run adm/shattri.p (
      input "get":U
    ,input  '':U
    ,input  0
    ,input  {&attr-cashpays}
    ,input  {&attr-cashpays_cpgrpnam} /*p-param-code*/
    ,output cpgrpnam
    ,output v-value-date
    ,output v-value-decimal
    ,output v-value-integer
    ,output v-value-integer
    ,output v-param-type
    ,INPUT-OUTPUT table-handle v-tth
    ) no-error .

  delete object v-tth.
  if cpgrpnam = '':U then do:
    MESSAGE
    "Неверное значение настроечного параметра" SKIP
    "(Группа меню АДМИНИСТРАТОР-ГЛОБАЛЬНЫЕ НАСТРОЙКИ-ДРУГИЕ ПАРАМЕТРЫ-Набор опций для работы со справочником типов кассовых платежей"
    "Невозможно изменить или добавить атрибут"
    VIEW-AS ALERT-BOX ERROR.
    UNDO main-block, RETURN ERROR.
  end.
  DO ii = 1 TO NUM-ENTRIES(cpgrpnam) by 2:
      ASSIGN
      v-dops = ENTRY(ii, cpgrpnam)
      v-dopi = integer(ENTRY(ii + 1, cpgrpnam))
      NO-ERROR.
      IF ERROR-STATUS:ERROR
      or v-dopi = 0
      or v-dopi >= 10000
      THEN DO:
          MESSAGE
          "Неверное значение настроечного параметра" SKIP
          "(Группа меню АДМИНИСТРАТОР-ГЛОБАЛЬНЫЕ НАСТРОЙКИ-ДРУГИЕ ПАРАМЕТРЫ-Набор опций для работы со справочником типов кассовых платежей"
          "четные элементы списка должны быть положительными целыми числами < 10000" SKIP
          "Невозможно изменить или добавить атрибут"
          VIEW-AS ALERT-BOX ERROR.
          UNDO main-block, RETURN ERROR.
      END.
  END.



  RUN Myenable.
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
  DISPLAY S-grp-name f-grp-code
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Help S-grp-name
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
DEFINE VARIABLE v-dops AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-dopi AS INTEGER NO-UNDO.
DEFINE VARIABLE ii AS INTEGER NO-UNDO.
DEFINE VARIABLE v-ok AS LOGICAL NO-UNDO.
s-grp-name:LIST-ITEM-pairs IN FRAME {&FRAME-NAME} = cpgrpnam.
if p-attr-value = '':U THEN DO:
    ASSIGN
    s-grp-name = ENTRY(2, cpgrpnam)
    f-grp-code = INTEGER(ENTRY(2, cpgrpnam))
    .
END.
ELSE do:
   ASSIGN
    v-dops = ENTRY(2, p-attr-value, {&delim-par})
    v-dopi = INTEGER(ENTRY(2, p-attr-value, {&delim-par}))
    NO-ERROR
    .
    IF ERROR-STATUS:ERROR  THEN DO:
       MESSAGE
       substitute("Неверное старое значение атрибута &1") SKIP
       "Необходимо переустановить атрибут"
       VIEW-AS ALERT-BOX WARNING.
       ASSIGN
        s-grp-name = ENTRY(1, cpgrpnam)
        f-grp-code = INTEGER(ENTRY(2, cpgrpnam))
        .
    END.
    DO ii = 1 TO NUM-ENTRIES(cpgrpnam)  by 2:
        IF v-dops = ENTRY(ii + 1, cpgrpnam)
        AND v-dopi = integer(ENTRY(ii + 1, cpgrpnam)) THEN DO:
            v-ok = YES.
        END.
    END.
    IF NOT v-ok  THEN DO:
        MESSAGE
        substitute("Неверное старое значение атрибута &1", p-attr-value) SKIP
        "Оно не соответствует списку разрешенныз названий и  кодов групп типов кассовых платежей" SKIP
        "(настроечный параметр cpgrpnam)" skip
        "Необходимо переустановить атрибут" SKIP
        VIEW-AS ALERT-BOX WARNING.
        ASSIGN
         s-grp-name = ENTRY(2, cpgrpnam)
         f-grp-code = INTEGER(ENTRY(2, cpgrpnam))
         .

    END.

END.

DISPLAY
s-grp-name
f-grp-code
WITH FRAME {&frame-name}.
ENABLE
B-exit
b-quit
B-Help
s-grp-name
WITH FRAME {&frame-name}.
VIEW FRAME {&frame-name}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save Dialog-Frame
PROCEDURE proc-save :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE INPUT parameter p-item AS INTEGER NO-UNDO.
DEFINE VARIABLE v-dop AS character NO-UNDO.
ASSIGN
FRAME {&frame-name}
s-grp-name
.

IF f-grp-code = 0  THEN DO:
    MESSAGE
    "Нельзя ввести код, группы равный 0"
    VIEW-AS ALERT-BOX.
END.
v-dop  = entry(p-item * 2 - 1, s-grp-name:LIST-ITEM-PAIRS).

IF v-dop = '':U  THEN DO:
    MESSAGE
    "Нельзя ввести пустое название группы"
    VIEW-AS ALERT-BOX.
END.

ASSIGN
p-attr-value = v-dop + {&delim-par} + STRING(f-grp-code)
p-ok = yes
.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME