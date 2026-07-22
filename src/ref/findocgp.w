&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame

/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE tt-fdp No-UNDO LIKE ub.rep
       field rep-code as character
       index pi is unique primary rep-code.


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Настройка печати платежей

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/16/04
Author: Bakhtadze Natalya
Creation date: 09/16/04

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER  p-fin-doc-type LIKE ub.fin-doc.fin-doc-type NO-UNDO.
DEFINE INPUT PARAMETER  p-fin-ext-doc-type LIKE ub.fin-doc.fin-ext-doc-type NO-UNDO.
DEFINE INPUT PARAMETER  p-num-recs AS integer NO-UNDO.
DEFINE OUTPUT PARAMETER p-template-code AS CHARACTER NO-UNDO.
DEFINE OUTPUT PARAMETER p-copy-nums AS integer NO-UNDO.
DEFINE OUTPUT PARAMETER p-add-info AS character NO-UNDO.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Настройка печати платежей".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/trg-def.i }
{ cmp/showinf.i }
{ cmp/ini-lib.i }
DEFINE VARIABLE v-t-nums AS integer NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-fdp

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-fdp

/* Definitions for BROWSE BR-fdp                                        */
&Scoped-define FIELDS-IN-QUERY-BR-fdp tt-fdp.obj-name tt-fdp.num ~
tt-fdp.name1
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-fdp
&Scoped-define QUERY-STRING-BR-fdp FOR EACH tt-fdp NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BR-fdp OPEN QUERY BR-fdp FOR EACH tt-fdp NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BR-fdp tt-fdp
&Scoped-define FIRST-TABLE-IN-QUERY-BR-fdp tt-fdp


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BR-fdp}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-Help BR-fdp F-copy-nums ~
f-docs-num
&Scoped-Define DISPLAYED-OBJECTS F-copy-nums f-docs-num

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Выбор"
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

DEFINE VARIABLE F-copy-nums AS INTEGER FORMAT ">>9":U INITIAL 0
     LABEL "Кол-во копий"
     VIEW-AS FILL-IN
     SIZE 5 BY 1 NO-UNDO.

DEFINE VARIABLE f-docs-num AS INTEGER FORMAT ">>,>>9":U INITIAL 0
     LABEL "Количество платежей, выбранных для печати"
      VIEW-AS TEXT
     SIZE 8 BY .67
     FGCOLOR 4  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-fdp FOR
      tt-fdp SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-fdp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-fdp Dialog-Frame _STRUCTURED
  QUERY BR-fdp NO-LOCK DISPLAY
      tt-fdp.obj-name COLUMN-LABEL "Название шаблона" FORMAT "X(20)":U
      tt-fdp.num COLUMN-LABEL "Кол-во!копий" FORMAT ">9":U WIDTH 6
      tt-fdp.name1 COLUMN-LABEL "Доп. информация" FORMAT "X(50)":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 13.5 EXPANDABLE.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 54.88
     BR-fdp AT ROW 4 COL 1
     F-copy-nums AT ROW 18.25 COL 4
     f-docs-num AT ROW 2.5 COL 43.5 COLON-ALIGNED
     SPACE(45.74) SKIP(18.86)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Настройка печати платежей"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: tt-fdp T "?" NO-UNDO ub rep
      ADDITIONAL-FIELDS:
          field rep-code as character
          index pi is unique primary rep-code
      END-FIELDS.
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
                                                                        */
/* BROWSE-TAB BR-fdp B-Help Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN F-copy-nums IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-fdp
/* Query rebuild information for BROWSE BR-fdp
     _TblList          = "tt-fdp"
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _FldNameList[1]   > Temp-Tables.tt-fdp.obj-name
"obj-name" "Название шаблона" "X(20)" "character" ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _FldNameList[2]   > Temp-Tables.tt-fdp.num
"num" "Кол-во!копий" ? "integer" ? ? ? ? ? ? no ? no no "6" yes no no "U" "" ""
     _FldNameList[3]   > Temp-Tables.tt-fdp.name1
"name1" "Доп. информация" "X(50)" "character" ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _Query            is OPENED
*/  /* BROWSE BR-fdp */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Настройка печати платежей */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Ввод */
DO:
  IF NOT AVAILABLE tt-fdp THEN RETURN.
  ASSIGN
  f-copy-nums
  p-copy-nums = f-copy-nums
  p-add-info = tt-fdp.name1
  p-template-code = tt-fdp.rep-code
  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-fdp
&Scoped-define SELF-NAME BR-fdp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-fdp Dialog-Frame
ON VALUE-CHANGED OF BR-fdp IN FRAME Dialog-Frame /* Browse 4 */
DO:
  IF AVAILABLE tt-fdp THEN DO:
     DISPLAY tt-fdp.num @ f-copy-nums WITH FRAME {&FRAME-NAME}.
     ENABLE f-copy-nums WITH FRAME {&FRAME-NAME}.
  END.
  ELSE DO:
     DISPLAY 0 @ f-copy-nums WITH FRAME {&FRAME-NAME}.
     DISABLE f-copy-nums WITH FRAME {&FRAME-NAME}.
  END.
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
  RUN fill-tables IN THIS-PROCEDURE (OUTPUT v-t-nums) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
    MESSAGE
    SUBSTITUTE("Ошибка при получении настроек печати платежей типа &1 из ini-файла", p-fin-doc-type) SKIP
    ERROR-STATUS:get-message(1) SKIP
    RETURN-VALUE
    VIEW-AS ALERT-BOX.
    RETURN.
  END.
  IF v-t-nums = 0 THEN DO:
      MESSAGE
      SUBSTITUTE("В ini-файле не найдено настроек печати платежей типа &1", p-fin-doc-type)
      VIEW-AS ALERT-BOX.
      RETURN.
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
  DISPLAY F-copy-nums f-docs-num
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Help BR-fdp F-copy-nums f-docs-num
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Fill-tables Dialog-Frame
PROCEDURE Fill-tables :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE OUTPUT parameter p-t-nums AS integer NO-UNDO.
DEFINE VARIABLE ii AS INTEGER NO-UNDO.
DEFINE VARIABLE ss AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-value AS CHARACTER NO-UNDO.
FOR EACH tt-fdp:
  DELETE tt-fdp.
END.
_ii:
DO ii = 1 TO 1000 ON ERROR UNDO _ii, NEXT _ii:
  assign
  ss = SUBstitute("&1&2", p-fin-doc-type, ii ).
  ASSIGN
  v-value = ?.
  RUN verify-ini-entry IN THIS-PROCEDURE(
                                            INPUT  ss
                                            ,INPUT "fin-print":U
                                            ,INPUT  "":U /* error-msg-text*/
                                            ,INPUT  yes /*silence*/
                                            ,OUTPUT v-value) NO-ERROR.
  if v-value = ? THEN DO:
      LEAVE _ii.
  END.
  ELSE DO:
    CREATE tt-fdp.
    /*  <Название_шаблона>#<Код_шаблона>#<Кол-во_копий>#<Доп_информация>*/
    ASSIGN
    tt-fdp.obj-name = ENTRY(1, v-value, "#":U)
    tt-fdp.rep-code  = ENTRY(2, v-value, "#":U)
    tt-fdp.num  = integer(ENTRY(3, v-value, "#":U))
    tt-fdp.name1  = ENTRY(4, v-value, "#":U)
    NO-ERROR
    .
    IF ERROR-STATUS:ERROR  THEN DO:
      MESSAGE
      substitute("Не удалось получить из ini-файла данные по шаблону печати &1", ss)
      VIEW-AS ALERT-BOX ERROR.
      UNDO _ii, NEXT _ii.
    END.
    ASSIGN
    p-t-nums = p-t-nums + 1
    .
  END.
END. /*DO ii = 1 TO 1000:*/
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DISPLAY
p-num-recs @ f-docs-num
F-copy-nums
WITH FRAME {&frame-name}.
ENABLE
B-exit
b-quit
B-Help
BR-fdp
F-copy-nums
WITH FRAME Dialog-Frame.
VIEW FRAME Dialog-Frame.
OPEN QUERY br-fdp FOR EACH tt-fdp NO-LOCK.
APPLY "value-changed" TO br-fdp.
apply "entry" TO br-fdp.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME