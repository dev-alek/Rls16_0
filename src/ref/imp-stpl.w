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

Запуск импорта стоплистов

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/06/07
Author: Bakhtadze Natalya
Creation date: 07/06/07


------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-mode as character no-undo .
define input parameter p-stop-list-code as character no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Запуск импорта стоплистов".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }
{ gbl/getcntxt.i def }
define buffer buf_stop-list for ub.stop-list.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-Help file-name B-file ~
f-stop-list-code t-fact T-tocd
&Scoped-Define DISPLAYED-OBJECTS file-name f-stop-list-code t-fact T-tocd

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

DEFINE BUTTON B-file
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE f-stop-list-code AS INTEGER FORMAT ">>>>>>>>9":U INITIAL 0
     LABEL "№ стоплиста"
     VIEW-AS FILL-IN
     SIZE 10 BY 1 NO-UNDO.

DEFINE VARIABLE file-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Файл импорта (.xls)"
     VIEW-AS FILL-IN
     SIZE 73.5 BY 1 NO-UNDO.

DEFINE VARIABLE t-fact AS LOGICAL INITIAL no
     LABEL "Поставить статус <факт> в случае удачного импорта"
     VIEW-AS TOGGLE-BOX
     SIZE 53 BY 1 NO-UNDO.

DEFINE VARIABLE T-tocd AS LOGICAL INITIAL no
     LABEL "Отправить на кассу по окончании УДАЧНОГО импорта"
     VIEW-AS TOGGLE-BOX
     SIZE 53 BY 1 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 54.9
     file-name AT ROW 3.13 COL 1.5
     B-file AT ROW 3.13 COL 96.5
     f-stop-list-code AT ROW 5.8 COL 13 COLON-ALIGNED
     t-fact AT ROW 7.4 COL 14.5
     T-tocd AT ROW 8.73 COL 14.5
     SPACE(32.39) SKIP(0.63)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE ""
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

/* SETTINGS FOR FILL-IN file-name IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame
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


&Scoped-define SELF-NAME B-file
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-file Dialog-Frame
ON CHOOSE OF B-file IN FRAME Dialog-Frame
DO:

define variable v_os-file   AS CHAR NO-UNDO INIT "".
define variable ll_commit AS LOG    NO-UNDO INIT NO.
define variable v-full-path        as character no-undo .
define variable v-path             as character no-undo .
define variable v-file-name        as character no-undo .
define variable v-file-name-no-ext as character no-undo .
define variable v-file-name-ext    as character no-undo .

    SYSTEM-DIALOG GET-FILE v_os-file
        TITLE "Выберите файл для импорта"
        FILTERS
          " Все текстовые файлы (*.xls) " "*.xls",
          " Все файлы (*.*) "                      "*.*"
        INITIAL-FILTER 1
        DEFAULT-EXTENSION ".xls"
        USE-FILENAME
        MUST-EXIST
        UPDATE ll_commit
        .

    IF ll_commit <> YES THEN do:
       RETURN NO-APPLY.
    end.
    IF v_os-file = PROGRAM-NAME( 1 ) THEN DO:
        BELL.
        MESSAGE "Рекурсия!" VIEW-AS ALERT-BOX ERROR.
        RETURN NO-APPLY.
    END.
    ASSIGN file-name = ( IF SEARCH( v_os-file ) = ? THEN v_os-file ELSE SEARCH( v_os-file ) ).
    run gbl/filename.p (
                    input  v_os-file
                    ,output v-full-path
                    ,output v-path
                    ,output v-file-name
                    ,output v-file-name-no-ext
                    ,output v-file-name-ext
                    ) no-error .
    if error-status:error  = ? then do:
      return no-apply.
    end.
    assign
    file-name = v-full-path.
    DISP file-name WITH FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME file-name
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL file-name Dialog-Frame
ON LEAVE OF file-name IN FRAME Dialog-Frame /* Файл импорта (.xls) */
DO:
    ASSIGN file-name.
    IF SEARCH( file-name ) <> ? AND SEARCH( file-name ) <> "":U THEN DO:
        ASSIGN FILE-INFO:FILE-NAME = file-name.
        IF FILE-INFO:FULL-PATHNAME <> ? THEN ASSIGN file-name = FILE-INFO:FULL-PATHNAME.
        DISP file-name WITH FRAME {&FRAME-NAME}.
    END.
    APPLY "TAB":U TO file-name IN FRAME {&FRAME-NAME}.
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
  if v-cntxt-db-num > 0 then do:
    message
    "Запрещен импорт стоплистов в УБД"
    view-as alert-box error .
    undo, return error .
  end.
  if p-mode <> {&add-def}
  and p-mode <> {&update} then do:
    message
    substitute("Неверное значение параметра p-mode=&1", p-mode)
    view-as alert-box error .
    undo, return error .
  end.
  if p-stop-list-code <> '':U then do:
    find first buf_stop-list exclusive-lock where
              buf_stop-list.classif-type = {&table_dis-card}
          and buf_stop-list.stop-list-code = p-stop-list-code
           no-error .
    if not available buf_stop-list then do:
      message
      vss-workfile vss-revision vss-description skip
      "Неверное значение параметра p-stop-list-code" p-stop-list-code
      view-as alert-box error .
      undo, return error .
    end.
    if buf_stop-list.status_ = {&fact} then do:
      message
      substitute("Стоплист &1 закрыт до статуса &2"
                  , p-stop-list-code
                  , buf_stop-list.status_
                  )
      view-as alert-box error .
      undo, return error .
    end.
  end.
  ELSE DO:
      find last buf_stop-list no-lock where
                buf_stop-list.classif-type = {&table_dis-card} no-error .
      if not available buf_stop-list then do:
      end.
      ELSE DO:
         if buf_stop-list.status_ <> {&fact} then do:
           message
           substitute("Предыдущий стоплист &1 не закрыт до статуса &2&3Добавление невозможно"
                      ,buf_stop-list.stop-list-code
                      ,{&fact}
                      ,{&new-line})
           view-as alert-box error .
           undo, return error .

         end.
         p-stop-list-code = STRING(next-value(s-stop-list, {&db-name_schema}), "999999999").
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
  DISPLAY file-name f-stop-list-code t-fact T-tocd
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Help file-name B-file f-stop-list-code t-fact T-tocd
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
define buffer buf_clients for ub.clients.
find first buf_clients no-lock where
           buf_clients.obj-type = {&shop}
      and  buf_clients.db-num = 0
      and buf_clients.stts = integer({&current-status-int}) no-error.

assign
f-stop-list-code = integer(p-stop-list-code).
DISPLAY
file-name
f-stop-list-code
T-tocd
WITH FRAME {&frame-name} .
ENABLE
B-exit
b-quit
B-Help
file-name
t-fact
B-file
f-stop-list-code  when p-stop-list-code = '':U
T-tocd when (available buf_clients)
WITH FRAME {&frame-name} .
VIEW FRAME {&frame-name} .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save Dialog-Frame
PROCEDURE proc-save :
ASSIGN FRAME {&FRAME-NAME}
f-stop-list-code
t-tocd
t-fact
file-name
.
 run str/diallog.w (
               input parparentproc
              ,input this-procedure
              ,input 'ref/in-stpl1.p':U
              ,input (file-name                        + {&delim-par} +
                      string(f-stop-list-code, "999999999") + {&delim-par} +
                      p-mode + {&delim-par} +
                      string(t-fact)
                 )
              ,input no /*p-auto-go*/
              ,input "&Стоп"
              ,input 'Импорт стоплистов') .

if t-tocd /*это важно */
then do:
  find first buf_stop-list no-lock where
            buf_stop-list.classif-type = {&table_dis-card}
          and buf_stop-list.stop-list-code = string(f-stop-list-code, "999999999").
  if available buf_stop-list
  and buf_stop-list.status_ = {&fact} then do:
    run str/diallog.w (
                  input parparentproc
                  ,input this-procedure
                  ,input 'str/snd-stpl.p':U
                  ,input f-stop-list-code
                  ,input yes /*p-auto-go*/
                  ,input '':U
                  ,input 'Отправка информации по стоплистам на кассы') no-error .
  end.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME