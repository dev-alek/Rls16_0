&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*------------------------------------------------------------------------

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Жесткое архивирование чеков

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/11/06
Author: Bakhtadze Natalya
Creation date: 04/11/06

с версии 5 добавлено условное удаление - используется для переноса чеков в другие БД


------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .

/* Local Variable Definitions ---                                       */
&scop src ub

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Жесткое архивирование чеков".
{ cmp/vssrevis.i }
{ cmp/showinf.i }


define stream exp-stream.
define variable rid-list as character no-undo.
{ cmp/str-glbl.i }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES ub.chk-doc

/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define FIELDS-IN-QUERY-Dialog-Frame ub.chk-doc.chk-date
&Scoped-define ENABLED-FIELDS-IN-QUERY-Dialog-Frame ub.chk-doc.chk-date
&Scoped-define ENABLED-TABLES-IN-QUERY-Dialog-Frame ub.chk-doc
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-Dialog-Frame ub.chk-doc
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH ub.chk-doc SHARE-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH ub.chk-doc SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame ub.chk-doc
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame ub.chk-doc


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS ub.chk-doc.chk-date
&Scoped-define ENABLED-TABLES ub.chk-doc
&Scoped-define FIRST-ENABLED-TABLE ub.chk-doc
&Scoped-Define ENABLED-OBJECTS Btn_OK Btn_Cancel b-help i-obj-code b-obj ~
i-month i-year dirname b-dir T-del
&Scoped-Define DISPLAYED-FIELDS ub.chk-doc.chk-date
&Scoped-define DISPLAYED-TABLES ub.chk-doc
&Scoped-define FIRST-DISPLAYED-TABLE ub.chk-doc
&Scoped-Define DISPLAYED-OBJECTS i-obj-code sh-name i-month i-year i ~
dirname T-del

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-dir
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.

DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1.

DEFINE BUTTON b-obj
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 2.8 BY 1.

DEFINE BUTTON Btn_Cancel AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON Btn_OK
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE dirname AS CHARACTER FORMAT "X(256)":U INITIAL ".~\"
     LABEL "Каталог для архива"
     VIEW-AS FILL-IN
     SIZE 29.5 BY 1 NO-UNDO.

DEFINE VARIABLE i AS INTEGER FORMAT ">,>>>,>>9":U INITIAL 0
     LABEL "Обработано"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE i-month AS INTEGER FORMAT "99":U INITIAL 0
     LABEL "Месяц архивации"
     VIEW-AS FILL-IN
     SIZE 3.1 BY 1 NO-UNDO.

DEFINE VARIABLE i-obj-code AS INTEGER FORMAT "->,>>>,>>9" INITIAL 0
     LABEL "Код магазина"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE i-year AS INTEGER FORMAT "9999":U INITIAL 0
     LABEL "Год архивации"
     VIEW-AS FILL-IN
     SIZE 4.8 BY 1 NO-UNDO.

DEFINE VARIABLE sh-name AS CHARACTER FORMAT "X(50)":U
     VIEW-AS FILL-IN
     SIZE 34.9 BY 1 NO-UNDO.

DEFINE VARIABLE T-del AS LOGICAL INITIAL no
     LABEL "С удалением чеков"
     VIEW-AS TOGGLE-BOX
     SIZE 21.5 BY .87 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY Dialog-Frame FOR
      ub.chk-doc SCROLLING.
&ANALYZE-RESUME

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     Btn_OK AT ROW 1 COL 1
     Btn_Cancel AT ROW 1 COL 11
     b-help AT ROW 1 COL 58 WIDGET-ID 2
     i-obj-code AT ROW 2.33 COL 13 COLON-ALIGNED
     b-obj AT ROW 2.4 COL 28.7
     sh-name AT ROW 2.4 COL 30.1 COLON-ALIGNED NO-LABEL
     i-month AT ROW 3.83 COL 16 COLON-ALIGNED
     i-year AT ROW 3.83 COL 33.5 COLON-ALIGNED
     i AT ROW 3.9 COL 50.6 COLON-ALIGNED
     dirname AT ROW 5.27 COL 19 COLON-ALIGNED
     b-dir AT ROW 5.27 COL 51
     ub.chk-doc.chk-date AT ROW 5.27 COL 59 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 10.9 BY 1
     T-del AT ROW 6.7 COL 2.5
     SPACE(48.89) SKIP(2.22)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Архивирование чеков"
         DEFAULT-BUTTON Btn_OK CANCEL-BUTTON Btn_Cancel.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
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

/* SETTINGS FOR FILL-IN i IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN sh-name IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "ub.chk-doc"
     _Options          = "SHARE-LOCK"
     _Query            is OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Архивирование чеков */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-dir
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-dir Dialog-Frame
ON CHOOSE OF b-dir IN FRAME Dialog-Frame /* R */
DO:
    define variable v_os-file   AS CHAR NO-UNDO INIT "":U.
    define variable ll_commit AS LOG    NO-UNDO INIT NO.

    SYSTEM-DIALOG GET-DIR v_os-file
        TITLE      "Выберите каталог для архива"
        UPDATE ll_commit.

    IF ll_commit <> YES THEN RETURN NO-APPLY.
    ASSIGN dirname = v_os-file + "\" .

    DISP dirname WITH FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-obj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-obj Dialog-Frame
ON CHOOSE OF b-obj IN FRAME Dialog-Frame
DO:
  run ref/cli-all.w ( input parparentproc
                     ,input "{&lookup},b-sel"
                     ,input ?
                     ,input ?
                     ,input ?
                     ,input ?
                     ,input ?
                     ,input ?
                     ,output rid-list) .
  if rid-list = "":U then return no-apply.
  find clients no-lock
    where recid(clients) = integer(rid-list)
    no-error
    .
  assign
    i-obj-code = clients.obj-code
    sh-name = clients.obj-name.
  disp
    i-obj-code
    sh-name
  with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_OK
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_OK Dialog-Frame
ON CHOOSE OF Btn_OK IN FRAME Dialog-Frame /* Ввод */
DO:
  assign
    i-obj-code
    i-month
    i-year
    dirname
    t-del.
  dirname = right-trim(dirname, "\").
  dirname = dirname + "\".
  find clients where clients.obj-type = {&shop} and clients.obj-code = i-obj-code no-lock no-error.
  if not available clients then do:
    message "Неправильно задан объект" view-as alert-box error.
    return no-apply.
  end.
  sh-name = clients.obj-name.
  disp sh-name with frame {&frame-name}.
  if i-month > 12 or i-month = 0 then do:
    message "Неправильно задан месяц архивации" view-as alert-box error.
    return no-apply.
  end.
  if i-year = 0  then do:
    message "Неправильно задан год архивации" view-as alert-box error.
    return no-apply.
  end.
  if (year(today) = i-year and month(today) <= i-month) or year(today) < i-year then do:
    message "Дата архива должна быть меньше текущей!" view-as alert-box error.
    return no-apply.
  end.
  if dirname = "" then dirname = ".\".
  if search( dirname + string(i-month, "99") + string(i-year) + ".txt") <> ? then do:
    message "Уже есть архив за этот месяц Переместите файл в другое место!" view-as alert-box error.
    return no-apply.
  end.
  run chk-out(t-del).
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE chk-out Dialog-Frame
PROCEDURE chk-out :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:       сама выкачка чеков
------------------------------------------------------------------------------*/
define input parameter p-del as logical no-undo.
  ON DELETE of chk-doc override do: end.
  output stream exp-stream to value( dirname + string(i-month, "99") + string(i-year) + ".txt").
  put stream exp-stream unformatted
  i-obj-code {&space-char}
  i-month {&space-char}
  i-year {&space-char}
  "v1.01"  skip(0).
  for each chk-doc where chk-doc.obj-type = {&shop} and
                                      chk-doc.obj-code = i-obj-code and
                                      year(chk-doc.chk-date) = i-year and
                                      month(chk-doc.chk-date) = i-month
                                      use-index obj-date exclusive:
      { utl/exp1.i chk-doc }
      for each chk-gds where chk-gds.doc-code = chk-doc.doc-code exclusive-lock:
          { utl/exp1.i chk-gds }
          if p-del then delete chk-gds.
      end.
      for each chk-pay where chk-pay.doc-code = chk-doc.doc-code exclusive-lock:
          { utl/exp1.i chk-pay }
          if p-del then delete chk-pay.
      end.
      for each chk-discnt where chk-discnt.doc-code = chk-doc.doc-code exclusive-lock:
          { utl/exp1.i chk-discnt }
          if p-del then delete chk-discnt.
      end.
      for each chk-doc-attr where chk-doc-attr.doc-code = chk-doc.doc-code exclusive-lock:
          { utl/exp1.i chk-doc-attr }
          if p-del then delete chk-doc-attr.
      end.
     i = i + 1.
     disp i chk-doc.chk-date with frame {&frame-name} .
     if p-del then delete chk-doc.
  end.
  output stream exp-stream close.
  ON DELETE of chk-doc revert.
  message "Архивация закончена. архив в каталоге " dirname view-as alert-box message.
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

  {&OPEN-QUERY-Dialog-Frame}
  GET FIRST Dialog-Frame.
  DISPLAY i-obj-code sh-name i-month i-year i dirname T-del
      WITH FRAME Dialog-Frame.
  IF AVAILABLE ub.chk-doc THEN
    DISPLAY ub.chk-doc.chk-date
      WITH FRAME Dialog-Frame.
  ENABLE Btn_OK Btn_Cancel b-help i-obj-code b-obj i-month i-year dirname b-dir
         ub.chk-doc.chk-date T-del
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME