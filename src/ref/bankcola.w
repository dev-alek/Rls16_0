&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*------------------------------------------------------------------------

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Создание и изменение банковского атрибута - счета для инкассации

Автор: Белоусов Илья Александрович
Дата создания: 04/15/08
Author: Ilia Belousov
Creation date: 04/15/08

Input:

Output:

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER parParentProc   AS WIDGET-HANDLE  NO-UNDO .
define input parameter p-host-code     AS INTEGER        no-undo .
define input parameter p-code-bank     as integer        no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Создание и изменение банковского атрибута - счета для инкассации".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i  }

define buffer buf_fin-bank-attr for ub.fin-bank-attr .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-quit b-help v-collect-account ~
v-credit-account v-qr-code v-firm v-bank 
&Scoped-Define DISPLAYED-OBJECTS v-collect-account v-credit-account ~
v-qr-code v-firm v-bank 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
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

DEFINE VARIABLE v-qr-code AS CHARACTER FORMAT "X(256)":U 
     LABEL "QR код" 
     VIEW-AS COMBO-BOX INNER-LINES 2
     LIST-ITEM-PAIRS " ","0",
                     "Сбербанк","1"
     DROP-DOWN-LIST
     SIZE 15.25 BY 1 NO-UNDO.

DEFINE VARIABLE v-bank AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 60.5 BY .67 NO-UNDO.

DEFINE VARIABLE v-collect-account AS CHARACTER FORMAT "X(256)":U 
     LABEL "Дебет" 
     VIEW-AS FILL-IN 
     SIZE 46.5 BY 1 NO-UNDO.

DEFINE VARIABLE v-credit-account AS CHARACTER FORMAT "X(256)":U 
     LABEL "Кредит" 
     VIEW-AS FILL-IN 
     SIZE 46.5 BY 1 NO-UNDO.

DEFINE VARIABLE v-firm AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 60 BY .67 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     b-help AT ROW 1 COL 55
     v-collect-account AT ROW 5 COL 9 WIDGET-ID 8
     v-credit-account AT ROW 6.5 COL 8 WIDGET-ID 10
     v-qr-code AT ROW 7.96 COL 14.25 COLON-ALIGNED WIDGET-ID 14
     v-firm AT ROW 2.25 COL 1 COLON-ALIGNED NO-LABEL WIDGET-ID 4
     v-bank AT ROW 3.25 COL 3 NO-LABEL WIDGET-ID 6
     SPACE(1.62) SKIP(5.82)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Настройки банка-вносителя для инкассации"
         DEFAULT-BUTTON b-exit CANCEL-BUTTON b-quit WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
   Other Settings: COMPILE
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN v-bank IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN v-collect-account IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN v-credit-account IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Настройки банка-вносителя для инкассации */
DO:
    APPLY "END-ERROR":U TO SELF.
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit Dialog-Frame
ON CHOOSE OF b-exit IN FRAME Dialog-Frame /* Ввод */
DO:
    assign
      v-collect-account
      v-firm
      v-bank
      v-credit-account
      v-QR-code
      .

    run save-attr in this-procedure no-error.
    IF ERROR-STATUS:ERROR THEN 
    DO:
      MESSAGE RETURN-VALUE SKIP
        ERROR-STATUS:GET-MESSAGE(1)
        VIEW-AS ALERT-BOX.
      UNDO, RETURN NO-APPLY.
    END.
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-help
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-help Dialog-Frame
ON CHOOSE OF b-help IN FRAME Dialog-Frame /* Помощь */
OR HELP OF FRAME {&FRAME-NAME}
  DO: /* Call Help Function (or a simple message). */
    MESSAGE "Help for File: {&FILE-NAME}" VIEW-AS ALERT-BOX INFORMATION.
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME v-collect-account
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-collect-account Dialog-Frame
ON LEAVE OF v-collect-account IN FRAME Dialog-Frame /* Дебет */
DO:
    assign v-collect-account .
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME v-credit-account
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-credit-account Dialog-Frame
ON LEAVE OF v-credit-account IN FRAME Dialog-Frame /* Кредит */
DO:
    assign v-credit-account .
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

  RUN load-attr IN THIS-PROCEDURE.

  RUN enable_UI.
  APPLY "ENTRY" TO v-collect-account .
  APPLY "ENTRY" TO v-credit-account .
  APPLY "ENTRY" TO v-QR-code .
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
  DISPLAY v-collect-account v-credit-account v-qr-code v-firm v-bank 
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-quit b-help v-collect-account v-credit-account v-qr-code 
         v-firm v-bank 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE load-attr Dialog-Frame 
PROCEDURE load-attr :
/*------------------------------------------------------------------------------
    Purpose:
    Parameters:  <none>
    Notes:
  ------------------------------------------------------------------------------*/
  define buffer buf_fin-bank for ub.fin-bank .
  define buffer buf_clients  for ub.clients .
  DO
    ON ERROR UNDO, RETURN ERROR
    :
    FIND FIRST buf_clients
      WHERE buf_clients.obj-type = {&cmp}
      AND buf_clients.obj-code = p-host-code
      NO-LOCK
      NO-ERROR
      .
    IF NOT AVAILABLE buf_clients
      THEN 
    DO:
      RETURN ERROR SUBSTITUTE("Не найдена фирма №&1", p-host-code).
    END.

    FIND FIRST buf_fin-bank
      WHERE buf_fin-bank.host-code = p-host-code
      AND buf_fin-bank.code-bank = p-code-bank
      NO-LOCK
      NO-ERROR
      .
    IF NOT AVAILABLE buf_clients
      THEN 
    DO:
      RETURN ERROR SUBSTITUTE ( "Не найден банк &1 для фирмы &2 &3"
        , p-code-bank
        , p-host-code
        , buf_clients.obj-name
        ) .
    END.
    ASSIGN
      v-firm = SUBSTITUTE("Фирма: &1", buf_clients.obj-name)
      v-bank = SUBSTITUTE(" Банк: &1", buf_fin-bank.bank-name)
      .

    FIND FIRST buf_fin-bank-attr
      where buf_fin-bank-attr.host-code  = p-host-code
      and buf_fin-bank-attr.code-bank  = p-code-bank
      and buf_fin-bank-attr.attr-code  = "collect-debt":U  /* !!! ? str-glbl, ?? ????? ?????? */
      no-lock
      no-error
      .
    IF AVAILABLE buf_fin-bank-attr
      THEN 
    DO:
      assign
        v-collect-account = buf_fin-bank-attr.attr-value
        .
    END.
    FIND FIRST buf_fin-bank-attr
      where buf_fin-bank-attr.host-code  = p-host-code
      and buf_fin-bank-attr.code-bank  = p-code-bank
      and buf_fin-bank-attr.attr-code  = "collect-credit":U  /* !!! ? str-glbl, ?? ????? ?????? */
      no-lock
      no-error
      .
    IF AVAILABLE buf_fin-bank-attr
      THEN 
    DO:
      assign
        v-credit-account = buf_fin-bank-attr.attr-value
        .
    END.
    FIND FIRST buf_fin-bank-attr
      where buf_fin-bank-attr.host-code  = p-host-code
      and buf_fin-bank-attr.code-bank  = p-code-bank
      and buf_fin-bank-attr.attr-code  = "collect-qrcode":U  /* !!! ? str-glbl, ?? ????? ?????? */
      no-lock
      no-error
      .
    IF AVAILABLE buf_fin-bank-attr
      THEN 
    DO:
      assign
        v-QR-code = buf_fin-bank-attr.attr-value
        .
    END.   
  END. /* DO ON ERROR */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE save-attr Dialog-Frame 
PROCEDURE save-attr :
/*------------------------------------------------------------------------------
    Purpose:
    Parameters:  <none>
    Notes:
  ------------------------------------------------------------------------------*/
  DO
    ON ERROR UNDO, RETURN ERROR
    :
    if v-collect-account <> "" then 
    do:
      FIND first buf_fin-bank-attr EXCLUSIVE-LOCK where 
        buf_fin-bank-attr.host-code = p-host-code and
        buf_fin-bank-attr.code-bank = p-code-bank and 
        buf_fin-bank-attr.attr-code = "collect-debt":U
        no-error.
      if not available (buf_fin-bank-attr) then 
      DO:
        CREATE buf_fin-bank-attr.
        assign
          buf_fin-bank-attr.host-code = p-host-code
          buf_fin-bank-attr.code-bank = p-code-bank
          buf_fin-bank-attr.attr-code = "collect-debt":U  /* !!! ? str-glbl, ?? ????? ?????? */
          .
      END.
      ASSIGN
        buf_fin-bank-attr.attr-value = v-collect-account
        .
    end.
    IF v-credit-account <> ""
      THEN 
    DO:
      FIND first buf_fin-bank-attr EXCLUSIVE-LOCK where 
        buf_fin-bank-attr.host-code = p-host-code and
        buf_fin-bank-attr.code-bank = p-code-bank and 
        buf_fin-bank-attr.attr-code = "collect-credit":U
        no-error.
      if not available (buf_fin-bank-attr) then     
      DO:
        CREATE buf_fin-bank-attr.
        assign
          buf_fin-bank-attr.host-code = p-host-code
          buf_fin-bank-attr.code-bank = p-code-bank
          buf_fin-bank-attr.attr-code = "collect-credit":U  /* !!! ? str-glbl, ?? ????? ?????? */
          .
      END.
      ASSIGN
        buf_fin-bank-attr.attr-value = v-credit-account
        .
    end.
    IF v-QR-code <> ""
      THEN 
    DO:
      FIND first buf_fin-bank-attr EXCLUSIVE-LOCK where 
        buf_fin-bank-attr.host-code = p-host-code and
        buf_fin-bank-attr.code-bank = p-code-bank and 
        buf_fin-bank-attr.attr-code = "collect-qrcode":U
        no-error .
      if not available (buf_fin-bank-attr) then 
      do:    
    
        CREATE buf_fin-bank-attr.
        assign
          buf_fin-bank-attr.host-code = p-host-code
          buf_fin-bank-attr.code-bank = p-code-bank
          buf_fin-bank-attr.attr-code = "collect-qrcode":U  /* !!! ? str-glbl, ?? ????? ?????? */
          .
      END.
      ASSIGN
        buf_fin-bank-attr.attr-value = v-QR-code
        .
    end.
  END. /* DO ON ERROR */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

