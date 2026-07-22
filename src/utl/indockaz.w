&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Главное окно утилиты импорта документов по датам

Автор: Суслов Алексей Юрьевич
Дата создания: 01/20/06
Author: Alexey Suslov
Creation date: 01/20/06

*/



/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER parparentproc AS HANDLE NO-UNDO.

/* Local Variable Definitions ---                                       */

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Главное окно утилиты импорта документов по датам".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i  }
{ cmp/library.i  }
{ gbl/userobjs.i }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ gbl/getsect.i  def }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES ub.clients

/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH ub.clients SHARE-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH ub.clients SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame ub.clients
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame ub.clients


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-cancel b-help varobj-code ~
varobj-type b-cli varfile-cli b-file-cli varfile-doc b-file-doc varstatus ~
varagnt b-agnt varboss b-boss varwrkr b-wrkr
&Scoped-Define DISPLAYED-OBJECTS varobj-code varobj-type varfile-cli ~
varfile-doc varstatus varagnt varagnt-name varboss varboss-name varwrkr ~
varwrkr-name

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-agnt
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY .88.

DEFINE BUTTON b-boss
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY .88.

DEFINE BUTTON b-cancel AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-cli
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "b-cli"
     SIZE 3 BY .88.

DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-file-cli
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "b-file-cli"
     SIZE 3 BY .88.

DEFINE BUTTON b-file-doc
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "b-file-doc"
     SIZE 3 BY .88.

DEFINE BUTTON b-help
     LABEL "&Помощь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-wrkr
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY .88.

DEFINE VARIABLE varstatus AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 0
     LABEL "Статус накладных"
     VIEW-AS COMBO-BOX INNER-LINES 3
     LIST-ITEM-PAIRS "накл-",0,
                     "накл+",1,
                     "факт",2
     DROP-DOWN-LIST
     SIZE 16 BY 1 NO-UNDO.

DEFINE VARIABLE varagnt AS INTEGER FORMAT ">>>>9":U INITIAL 0
     LABEL "Исполнитель"
     VIEW-AS FILL-IN
     SIZE 6 BY 1 NO-UNDO.

DEFINE VARIABLE varagnt-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 34 BY 1 NO-UNDO.

DEFINE VARIABLE varboss AS INTEGER FORMAT ">>>>9":U INITIAL 0
     LABEL "Менеджер"
     VIEW-AS FILL-IN
     SIZE 6 BY 1 NO-UNDO.

DEFINE VARIABLE varboss-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 34 BY 1 NO-UNDO.

DEFINE VARIABLE varfile-cli AS CHARACTER FORMAT "X(256)":U INITIAL "id.txt"
     LABEL "Файл идентификации поставщиков"
     VIEW-AS FILL-IN
     SIZE 62 BY 1 NO-UNDO.

DEFINE VARIABLE varfile-doc AS CHARACTER FORMAT "X(256)":U INITIAL "parts.txt"
     LABEL "Файл данных для накладных"
     VIEW-AS FILL-IN
     SIZE 62 BY 1 NO-UNDO.

DEFINE VARIABLE varobj-code AS INTEGER FORMAT ">>>>>>>>9" INITIAL 0
     LABEL "Объект"
     VIEW-AS FILL-IN
     SIZE 10 BY 1 NO-UNDO.

DEFINE VARIABLE varobj-type AS CHARACTER FORMAT "X(3)"
     VIEW-AS FILL-IN
     SIZE 4 BY 1 NO-UNDO.

DEFINE VARIABLE varwrkr AS INTEGER FORMAT ">>>>9":U INITIAL 0
     LABEL "Кладовщик"
     VIEW-AS FILL-IN
     SIZE 6 BY 1 NO-UNDO.

DEFINE VARIABLE varwrkr-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 34 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY Dialog-Frame FOR
      ub.clients SCROLLING.
&ANALYZE-RESUME

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-cancel AT ROW 1 COL 11
     b-help AT ROW 1 COL 21
     varobj-code AT ROW 2 COL 31 COLON-ALIGNED
     varobj-type AT ROW 2 COL 41.5 COLON-ALIGNED NO-LABEL
     b-cli AT ROW 2 COL 48.5
     varfile-cli AT ROW 4 COL 1.5
     b-file-cli AT ROW 4 COL 96
     varfile-doc AT ROW 6 COL 31 COLON-ALIGNED
     b-file-doc AT ROW 6 COL 96
     varstatus AT ROW 8 COL 31 COLON-ALIGNED
     varagnt AT ROW 10 COL 31 COLON-ALIGNED
     varagnt-name AT ROW 10 COL 37.5 COLON-ALIGNED NO-LABEL
     b-agnt AT ROW 10 COL 74
     varboss AT ROW 12 COL 31 COLON-ALIGNED
     varboss-name AT ROW 12 COL 37.5 COLON-ALIGNED NO-LABEL
     b-boss AT ROW 12 COL 74
     varwrkr AT ROW 14 COL 31 COLON-ALIGNED
     varwrkr-name AT ROW 14 COL 37.5 COLON-ALIGNED NO-LABEL
     b-wrkr AT ROW 14 COL 74
     SPACE(24.12) SKIP(1.15)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Утилита импорта внешнего прихода по датам"
         DEFAULT-BUTTON b-exit CANCEL-BUTTON b-cancel.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
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

/* SETTINGS FOR FILL-IN varagnt-name IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varboss-name IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varfile-cli IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN varwrkr-name IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "ub.clients"
     _Options          = "SHARE-LOCK"
     _Query            is OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Утилита импорта внешнего прихода по датам */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-agnt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-agnt Dialog-Frame
ON CHOOSE OF b-agnt IN FRAME Dialog-Frame
DO:
  DEFINE VARIABLE ref-rec  AS RECID     NO-UNDO.
  DEFINE VARIABLE ref-list AS CHARACTER NO-UNDO.
  DEFINE VARIABLE varrecid AS RECID NO-UNDO.
  DEFINE BUFFER bf_clients FOR ub.clients.
  run ref/cli-all.w (  input parparentproc
                ,  input "b-sel"
                ,  input 'чел':U
                ,  input ?
                ,  input ?
                ,  input ref-rec
                ,  input ?
                ,  input ?
                , output ref-list ) .
  IF NUM-ENTRIES(ref-list) > 0 THEN DO:
    ASSIGN
      varrecid = INTEGER(ENTRY(1, ref-list)).
    FIND FIRST bf_clients WHERE recid(bf_clients) = varrecid NO-LOCK.
    DISPLAY bf_clients.obj-code @ varagnt bf_clients.obj-name @ varagnt-name WITH FRAME {&FRAME-NAME}.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-boss
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-boss Dialog-Frame
ON CHOOSE OF b-boss IN FRAME Dialog-Frame
DO:
    DEFINE VARIABLE ref-rec  AS RECID     NO-UNDO.
    DEFINE VARIABLE ref-list AS CHARACTER NO-UNDO.
    DEFINE VARIABLE varrecid AS RECID NO-UNDO.
    DEFINE BUFFER bf_clients FOR ub.clients.
    run ref/cli-all.w (  input parparentproc
                  ,  input "b-sel"
                  ,  input 'чел':U
                  ,  input ?
                  ,  input ?
                  ,  input ref-rec
                  ,  input ?
                  ,  input ?
                  , output ref-list ) .
    IF NUM-ENTRIES(ref-list) > 0 THEN DO:
      ASSIGN
        varrecid = INTEGER(ENTRY(1, ref-list)).
      FIND FIRST bf_clients WHERE recid(bf_clients) = varrecid NO-LOCK.
      DISPLAY bf_clients.obj-code @ varboss bf_clients.obj-name @ varboss-name WITH FRAME {&FRAME-NAME}.
    END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-cli
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-cli Dialog-Frame
ON CHOOSE OF b-cli IN FRAME Dialog-Frame /* b-cli */
DO:
  define variable v-user-select as logical   no-undo .
  define variable v-obj-type    as character no-undo .
  define variable v-obj-code    as integer   no-undo .

  { gbl/uobjsone.i
    parparentproc
    v-cntxt-db-num
    v-cntxt-userid
    v-cntxt-host-code-obj
    v-cntxt-obj-type
    v-cntxt-obj-code
    v-user-select
    v-obj-type
    v-obj-code
  }
  if v-user-select <> true
  then do:
    RETURN NO-APPLY.
  end.
  DISPLAY
    v-obj-type @ varobj-type
    v-obj-code @ varobj-code
    WITH FRAME {&FRAME-NAME}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit Dialog-Frame
ON CHOOSE OF b-exit IN FRAME Dialog-Frame /* Ввод */
DO:
  DEFINE BUFFER bf_clients FOR ub.clients.
  define variable varchk-prs      as logical   no-undo .
  define variable varchk-prs-type as character no-undo.

  ASSIGN FRAME {&FRAME-NAME}
    varfile-cli
    varfile-doc
    varobj-type
    varobj-code
    varagnt
    varboss
    varwrkr
    varstatus.
  IF SEARCH(varfile-cli) = ? THEN DO:
    MESSAGE "Не найден файл идентификации поставщиков: " varfile-cli VIEW-AS ALERT-BOX ERROR.
    APPLY "entry" TO varfile-cli IN FRAME {&FRAME-NAME}.
    RETURN NO-APPLY.
  END.
  IF SEARCH(varfile-doc) = ? THEN DO:
      MESSAGE "Не найден файл данных для накладных: " varfile-doc VIEW-AS ALERT-BOX ERROR.
      APPLY "entry" TO varfile-doc IN FRAME {&FRAME-NAME}.
      RETURN NO-APPLY.
  END.
  IF varobj-type <> {&shop} AND varobj-type <> {&stock} THEN DO:
    MESSAGE "Объект должен быть типа " {&shop} " или " {&stock} " ."  VIEW-AS ALERT-BOX ERROR.
    APPLY "ENTRY" TO varobj-type IN FRAME {&FRAME-NAME}.
    RETURN NO-APPLY.
  END.
  FIND FIRST bf_clients WHERE bf_clients.obj-type = varobj-type AND
                              bf_clients.obj-code = varobj-code NO-LOCK NO-ERROR.
  IF NOT AVAILABLE bf_clients THEN DO:
    MESSAGE "Не найден объект " varobj-type " " varobj-code VIEW-AS ALERT-BOX ERROR.
    APPLY "ENTRY" TO varobj-code IN FRAME {&FRAME-NAME}.
    RETURN NO-APPLY.
  END.
  if varagnt <> 0 and varagnt <> ? then do:
    FIND FIRST bf_clients WHERE bf_clients.obj-type = {&prs}  AND
                                bf_clients.obj-code = varagnt NO-LOCK NO-ERROR.
    IF NOT AVAILABLE bf_clients THEN DO:
      MESSAGE "Не найден исполнитель " varagnt VIEW-AS ALERT-BOX ERROR.
      APPLY "ENTRY" TO varagnt IN FRAME {&FRAME-NAME}.
      RETURN NO-APPLY.
    END.
  END.
  if varboss <> 0 and varboss <> ? then do:
    FIND FIRST bf_clients WHERE bf_clients.obj-type = {&prs}  AND
                                bf_clients.obj-code = varboss NO-LOCK NO-ERROR.
    IF NOT AVAILABLE bf_clients THEN DO:
      MESSAGE "Не найден менеджер " varboss VIEW-AS ALERT-BOX ERROR.
      APPLY "ENTRY" TO varboss IN FRAME {&FRAME-NAME}.
      RETURN NO-APPLY.
    END.
  END.
  if varwrkr <> 0 and varwrkr <> ? then do:
    FIND FIRST bf_clients WHERE bf_clients.obj-type = {&prs}  AND
                                bf_clients.obj-code = varwrkr NO-LOCK NO-ERROR.
    IF NOT AVAILABLE bf_clients THEN DO:
      MESSAGE "Не найден кладовщик " varwrkr VIEW-AS ALERT-BOX ERROR.
      APPLY "ENTRY" TO varwrkr IN FRAME {&FRAME-NAME}.
      RETURN NO-APPLY.
    END.
  END.
{ gbl/getsect.i run "''" 0 {&attr-nakl-glob} }
for each thbjattr_thbj-attr :
    if thbjattr_thbj-attr.prop-code = 'chk-prs'   then varchk-prs     = thbjattr_thbj-attr.property-value-logical .
end.

  if varchk-prs then do:
    if varagnt = 0 or varagnt = ? then do:
      message "Не указан исполнитель " varagnt view-as alert-box error.
      apply "entry" to varagnt in frame {&frame-name}.
      return no-apply.
    end.
    if varboss = 0 or varboss = ? then do:
      message "Не указан менеджер " varboss view-as alert-box error.
      apply "entry" to varboss in frame {&frame-name}.
      return no-apply.
    end.
    if varwrkr = 0 or varwrkr = ? then do:
      message "Не указан кладовщик " varwrkr view-as alert-box error.
      apply "entry" to varwrkr in frame {&frame-name}.
      return no-apply.
    end.
  end.
  run utl/indocka.p (INPUT parparentproc, INPUT varobj-type, INPUT varobj-code, INPUT varfile-cli, INPUT varfile-doc, INPUT varstatus, INPUT varagnt, INPUT varboss, INPUT varwrkr) NO-ERROR.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-file-cli
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-file-cli Dialog-Frame
ON CHOOSE OF b-file-cli IN FRAME Dialog-Frame /* b-file-cli */
DO:
  DEFINE VARIABLE varfile-txt AS CHARACTER NO-UNDO.
  DEFINE VARIABLE varlog      AS LOGICAL   NO-UNDO.
  system-dialog get-file varfile-txt
  title "Выберите файл идентификации поставщиков"
       filters "txt" "*.txt",
               "Все файлы" "*.*"
       update varlog.
  IF varlog THEN DO:
    DISPLAY varfile-txt @ varfile-cli WITH FRAME {&FRAME-NAME}.
  END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-file-doc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-file-doc Dialog-Frame
ON CHOOSE OF b-file-doc IN FRAME Dialog-Frame /* b-file-doc */
DO:
  DEFINE VARIABLE varfile-txt AS CHARACTER NO-UNDO.
  DEFINE VARIABLE varlog      AS LOGICAL   NO-UNDO.
  system-dialog get-file varfile-txt
  title "Выберите файл данных для накладных"
       filters "txt" "*.txt",
               "Все файлы" "*.*"
       update varlog.
  IF varlog THEN DO:
    DISPLAY varfile-txt @ varfile-doc WITH FRAME {&FRAME-NAME}.
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


&Scoped-define SELF-NAME b-wrkr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-wrkr Dialog-Frame
ON CHOOSE OF b-wrkr IN FRAME Dialog-Frame
DO:
    DEFINE VARIABLE ref-rec  AS RECID     NO-UNDO.
    DEFINE VARIABLE ref-list AS CHARACTER NO-UNDO.
    DEFINE VARIABLE varrecid AS RECID NO-UNDO.
    DEFINE BUFFER bf_clients FOR ub.clients.
    run ref/cli-all.w (  input parparentproc
                  ,  input "b-sel"
                  ,  input 'чел':U
                  ,  input ?
                  ,  input ?
                  ,  input ref-rec
                  ,  input ?
                  ,  input ?
                  , output ref-list ) .
    IF NUM-ENTRIES(ref-list) > 0 THEN DO:
      ASSIGN
        varrecid = INTEGER(ENTRY(1, ref-list)).
      FIND FIRST bf_clients WHERE recid(bf_clients) = varrecid NO-LOCK.
      DISPLAY bf_clients.obj-code @ varwrkr bf_clients.obj-name @ varwrkr-name WITH FRAME {&FRAME-NAME}.
    END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME varagnt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varagnt Dialog-Frame
ON LEAVE OF varagnt IN FRAME Dialog-Frame /* Исполнитель */
DO:
    DEFINE BUFFER bf_clients FOR ub.clients.
    FIND FIRST bf_clients WHERE bf_clients.obj-type = {&prs} AND
                                bf_clients.obj-code = INPUT FRAME {&FRAME-NAME} varagnt NO-LOCK NO-ERROR.
    IF AVAILABLE bf_clients THEN DO:
      DISPLAY bf_clients.obj-name @ varagnt-name WITH FRAME {&FRAME-NAME}.
    END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME varboss
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varboss Dialog-Frame
ON LEAVE OF varboss IN FRAME Dialog-Frame /* Менеджер */
DO:
   DEFINE BUFFER bf_clients FOR ub.clients.
  FIND FIRST bf_clients WHERE bf_clients.obj-type = {&prs} AND
                              bf_clients.obj-code = INPUT FRAME {&FRAME-NAME} varboss NO-LOCK NO-ERROR.
  IF AVAILABLE bf_clients THEN DO:
    DISPLAY bf_clients.obj-name @ varboss-name WITH FRAME {&FRAME-NAME}.
  END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME varwrkr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varwrkr Dialog-Frame
ON LEAVE OF varwrkr IN FRAME Dialog-Frame /* Кладовщик */
DO:
    DEFINE BUFFER bf_clients FOR ub.clients.
    FIND FIRST bf_clients WHERE bf_clients.obj-type = {&prs} AND
                                bf_clients.obj-code = INPUT FRAME {&FRAME-NAME} varwrkr NO-LOCK NO-ERROR.
    IF AVAILABLE bf_clients THEN DO:
      DISPLAY bf_clients.obj-name @ varwrkr-name WITH FRAME {&FRAME-NAME}.
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
{ gbl/app_help.i
  &disable_diasize=true
}



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

  {&OPEN-QUERY-Dialog-Frame}
  GET FIRST Dialog-Frame.
  DISPLAY varobj-code varobj-type varfile-cli varfile-doc varstatus varagnt
          varagnt-name varboss varboss-name varwrkr varwrkr-name
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-cancel b-help varobj-code varobj-type b-cli varfile-cli
         b-file-cli varfile-doc b-file-doc varstatus varagnt b-agnt varboss
         b-boss varwrkr b-wrkr
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME