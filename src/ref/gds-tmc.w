&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*
$Revision: f7d97dfc4a3c, 2896, rls $
$Author: ARostovtsev $
$Date: 05/24/2024 $
$Workfile: gds-tmc.w $
$Archive: ref/gds-tmc.w $

Выбор признака сособа оплаты, атрибут товара

Автор: Ростовцев Александр
Дата создания: 24/05/2024
Author: Rostovtsev Aleksandr
Creation date: 24/05/2024
*/

define input parameter p-mode as character no-undo .
DEFINE INPUT PARAMETER p-gds-code AS INTEGER NO-UNDO.
DEFINE INPUT PARAMETER p-spr-param AS character NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER p-attr-value AS character NO-UNDO.
DEFINE OUTPUT PARAMETER p-setted AS LOGICAL NO-UNDO.

define variable vss-revision    as character no-undo init "$Revision: f7d97dfc4a3c, 2896, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Пн ноя 22 19:49:12 2021 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: gds-imm.w $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/gds-imm.w $":U .
define variable vss-description as character no-undo init "Выбор типа услуги, атрибут товара".

{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i }
{ rep/frmlib.i }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit 
&Scoped-Define DISPLAYED-OBJECTS type-method-calc withLimit 

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

DEFINE BUTTON b-quit AUTO-END-KEY 
     LABEL "&Отмена" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE type-method-calc AS CHARACTER FORMAT "X":U 
     LABEL "Признак" 
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEM-PAIRS "ПРЕДОПЛАТА 100%","1",
                     "ПРЕДОПЛАТА","2",
                     "АВАНС","3",
                     "ПОЛНЫЙ РАСЧЕТ","4",
                     "ЧАСТИЧНЫЙ РАСЧЕТ И КРЕДИТ","5",
                     "ПЕРЕДАЧА В КРЕДИТ","6",
                     "ОПЛАТА КРЕДИТА","7"
     DROP-DOWN-LIST
     SIZE 81 BY 1 NO-UNDO.

DEFINE VARIABLE withLimit AS LOGICAL INITIAL no 
     LABEL "с ограничениями" 
     VIEW-AS TOGGLE-BOX
     SIZE 23.8 BY .81 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1 WIDGET-ID 2
     b-quit AT ROW 1 COL 11 WIDGET-ID 4
     type-method-calc AT ROW 2.67 COL 11.2 COLON-ALIGNED WIDGET-ID 6
     withLimit AT ROW 4.33 COL 13.2 WIDGET-ID 8
     SPACE(59.19) SKIP(1.42)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Признак способа расчета" WIDGET-ID 100.


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

/* SETTINGS FOR BUTTON B-exit IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR COMBO-BOX type-method-calc IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR TOGGLE-BOX withLimit IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Признак способа расчета */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Ввод */
DO:
  RUN proc-save IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  RUN enable_UI.
  run proc-load.
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
  DISPLAY type-method-calc withLimit 
      WITH FRAME Dialog-Frame.
  ENABLE b-quit 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-load Dialog-Frame 
PROCEDURE proc-load :
if p-mode = {&add-def} OR p-mode = {&update} then do:
    enable b-exit type-method-calc withLimit with frame {&FRAME-NAME}.
end.

assign
  p-setted = false
  type-method-calc = if p-attr-value <> "" then entry(1,p-attr-value,",") else "3"
  withLimit = p-attr-value = "" or (num-entries(p-attr-value,",") > 1 and entry(2,p-attr-value,",") = "1")
no-error.
display type-method-calc withLimit with frame {&FRAME-NAME}.

end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save Dialog-Frame 
PROCEDURE proc-save :
/*  */
 assign frame {&FRAME-NAME}
    type-method-calc
    withLimit 
 .
 
 if trim(type-method-calc) = "" then do:
     message "Не выбрано значение"
     view-as alert-box.
     return error.
 end. 
 
 assign
   p-setted = true
   p-attr-value = substitute("&1,&2", type-method-calc, if withLimit then "1" else "2") 
 .
 
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

