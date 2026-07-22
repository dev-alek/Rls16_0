&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
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

Откат архивации по чекам

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

define input parameter parparentproc as widget-handle no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i }

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
define stream imp-str.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS Btn_OK Btn_Cancel b-help BUTTON-1
&Scoped-Define DISPLAYED-OBJECTS filename ii ii-ok

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1.

DEFINE BUTTON Btn_Cancel AUTO-END-KEY
     LABEL "Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON Btn_OK
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON BUTTON-1
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.

DEFINE VARIABLE filename AS CHARACTER FORMAT "X(256)":U
     LABEL "Имя файла"
     VIEW-AS FILL-IN
     SIZE 51 BY 1 NO-UNDO.

DEFINE VARIABLE ii AS INTEGER FORMAT ">,>>>,>>9":U INITIAL 0
     LABEL "Просмотрено чеков"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE ii-ok AS INTEGER FORMAT ">,>>>,>>9":U INITIAL 0
     LABEL "Импортировано чеков"
     VIEW-AS FILL-IN
     SIZE 14 BY 1.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     Btn_OK AT ROW 1 COL 1
     Btn_Cancel AT ROW 1 COL 11
     b-help AT ROW 1 COL 58 WIDGET-ID 2
     filename AT ROW 2.6 COL 11 COLON-ALIGNED
     BUTTON-1 AT ROW 2.6 COL 65.5
     ii AT ROW 4.07 COL 19.6 COLON-ALIGNED
     ii-ok AT ROW 5.4 COL 20 COLON-ALIGNED
     SPACE(32.89) SKIP(2.62)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Загрузка Архивов по чекам"
         DEFAULT-BUTTON Btn_OK CANCEL-BUTTON Btn_Cancel.


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
   FRAME-NAME                                                           */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN filename IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN ii IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN ii-ok IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Загрузка Архивов по чекам */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_OK
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_OK Dialog-Frame
ON CHOOSE OF Btn_OK IN FRAME Dialog-Frame /* Ввод */
DO:
    if filename = ""  then   do:
        message "Неправильно введено имя дампа" view-as alert-box message.
        return no-apply.
    end.
    RUN exp-arh(filename).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME BUTTON-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-1 Dialog-Frame
ON CHOOSE OF BUTTON-1 IN FRAME Dialog-Frame
DO:
  DEFINE VARIABLE OKpressed AS LOGICAL INITIAL TRUE.
  system-dialog get-file filename
  SAVE-AS
         USE-FILENAME
        UPDATE OKpressed.
  if okpressed then
    disp filename with frame dialog-frame.
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
  RUN enable_UI.
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
  DISPLAY filename ii ii-ok
      WITH FRAME Dialog-Frame.
  ENABLE Btn_OK Btn_Cancel b-help BUTTON-1
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE exp-arh Dialog-Frame
PROCEDURE exp-arh :
/*------------------------------------------------------------------------------
  Purpose:     загрузка из тектового файла
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    def input param filename as char no-undo.
    define variable t-name as char no-undo.
    define variable date-ga as char no-undo.


disable triggers for  load   of ub.chk-doc.
disable triggers for  load   of ub.chk-gds.
disable triggers for  load   of ub.chk-pay.
disable triggers for  load   of ub.chk-discnt.
disable triggers for  load   of ub.chk-doc-attr.
define buffer buf_chk-doc for ub.chk-doc.
define buffer buf_inkas   for ub.inkas.
define variable v-import as logical no-undo .
define variable v-doc-code   like ub.chk-doc.doc-code no-undo .
define variable v-inkas-code like ub.inkas.inkas-code no-undo .
define variable v-skip as character no-undo .
define variable v-version as decimal no-undo .
define variable glog as logical no-undo .
message
"Внимание!" skip
"Файл-источник" filename
"после импорта будет уничтожен, сделайте резервную копию" skip
"Продолжить?"
view-as alert-box question update glog.
if not glog then return.

assign
ii = 0
ii-ok = 0
.
    input stream imp-str from value(filename).
    import stream imp-str unformatted t-name.
    if index(t-name, "v1.01":U) > 0 then do:
      assign
      v-version = 1.01
      .
    end.
    else do:
      assign
      v-inkas-code = "":U
      v-import = yes
      .
    end.
    DO ON ERROR   UNDO, RETURN ERROR
      ON ENDKEY UNDO, RETURN ERROR
      ON STOP      UNDO, RETURN ERROR:
        _repeat:
        repeat:
            disp ii ii-ok with frame {&frame-name}.
            if v-version = 0 then do:
              import stream imp-str t-name.
            end.
            if v-version = 1.01 then do:
              import stream imp-str t-name v-inkas-code v-doc-code.
            end.
            case t-name:
                { utl/imp-chk.i "chk-doc" }
                { utl/imp-chk.i "chk-pay" }
                { utl/imp-chk.i "chk-gds" }
                { utl/imp-chk.i "chk-discnt" }
                { utl/imp-chk.i "chk-doc-attr" }
            end case.
        end.
    end.
    input stream imp-str close.
    os-delete value(filename).
    message "Загрузка чеков закончена. "  view-as alert-box message.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME