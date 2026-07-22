&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
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

Справочник событий на кассе

Автор: Белоусов Илья Александрович
Дата создания: 12/02/08
Author: Ilia Belousov
Creation date: 12/02/08

Input:

Output:

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input         parameter parparentproc  as widget-handle  no-undo .
define input         parameter p-bttns        as character     no-undo .
define input-output  parameter rid-list       as character      no-undo .
define output        parameter p-ok           as logical        no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Справочник событий на кассе".

define buffer buf_cd-events      for ub.cd-events .

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ gbl/getcntxt.i def }

define variable v-mark    as logical FORMAT "*/ "     no-undo.
define variable v-change  as logical FORMAT "*/ "     no-undo.
define variable v-ok      as logical      no-undo.
define variable v-version    as integer      no-undo.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BROWSE-2

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES buf_cd-events

/* Definitions for BROWSE BROWSE-2                                      */
&Scoped-define FIELDS-IN-QUERY-BROWSE-2 ~
(IF ( INDEX (rid-list, string( recid( buf_cd-events ) ) ) > 0 ) THEN TRUE ELSE FALSE) @ v-mark ~
buf_cd-events.event-id buf_cd-events.event-level buf_cd-events.event-name ~
buf_cd-events.event-status buf_cd-events.event-type buf_cd-events.event-description
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-2
&Scoped-define QUERY-STRING-BROWSE-2 FOR EACH buf_cd-events NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BROWSE-2 OPEN QUERY BROWSE-2 FOR EACH buf_cd-events NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BROWSE-2 buf_cd-events
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-2 buf_cd-events


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BROWSE-2}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit b-mark b-sel b-add b-chg b-del b-load ~
b-down b-help BROWSE-2

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-add
     LABEL "&Добавить"
     SIZE 10 BY 1.

DEFINE BUTTON b-chg
     LABEL "&Изменить"
     SIZE 10 BY 1.

DEFINE BUTTON b-del
     LABEL "&Удалить"
     SIZE 10 BY 1.

DEFINE BUTTON b-down
     LABEL "Выгрузить"
     SIZE 10 BY 1.

DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-load
     LABEL "&Загрузить"
     SIZE 10 BY 1.

DEFINE BUTTON b-mark
     LABEL "*"
     SIZE 3 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-sel AUTO-GO
     LABEL "Выбор"
     SIZE 10 BY 1.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BROWSE-2 FOR
      buf_cd-events SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BROWSE-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-2 Dialog-Frame _STRUCTURED
  QUERY BROWSE-2 NO-LOCK DISPLAY
      (IF ( INDEX (rid-list, string( recid( buf_cd-events ) ) ) > 0 ) THEN TRUE ELSE FALSE) @ v-mark COLUMN-LABEL "*"
      buf_cd-events.event-id FORMAT ">>>9":U
      buf_cd-events.event-level FORMAT ">9":U
      buf_cd-events.event-name FORMAT "x(30)":U
      buf_cd-events.event-status FORMAT ">9":U
      buf_cd-events.event-type FORMAT "x(1)":U
      buf_cd-events.event-description FORMAT "x(255)":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97 BY 19.75 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     b-mark AT ROW 1 COL 13.5 WIDGET-ID 4
     b-sel AT ROW 1 COL 16.5 WIDGET-ID 6
     b-add AT ROW 1 COL 29 WIDGET-ID 10
     b-chg AT ROW 1 COL 39 WIDGET-ID 8
     b-del AT ROW 1 COL 49 WIDGET-ID 14
     b-load AT ROW 1 COL 61.63 WIDGET-ID 2
     b-down AT ROW 1 COL 71.63 WIDGET-ID 12
     b-help AT ROW 1 COL 88
     BROWSE-2 AT ROW 2.25 COL 1 WIDGET-ID 200
     SPACE(0.00) SKIP(0.99)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Справочник событий на кассе"
         CANCEL-BUTTON b-quit WIDGET-ID 100.


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
/* BROWSE-TAB BROWSE-2 b-help Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-2
/* Query rebuild information for BROWSE BROWSE-2
     _TblList          = "buf_cd-events"
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _FldNameList[1]   > "_<CALC>"
"(IF ( INDEX (rid-list, string( recid( buf_cd-events ) ) ) > 0 ) THEN TRUE ELSE FALSE) @ v-mark" "*" "X(1)" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[2]   = buf_cd-events.event-id
     _FldNameList[3]   = buf_cd-events.event-level
     _FldNameList[4]   = buf_cd-events.event-name
     _FldNameList[5]   = buf_cd-events.event-status
     _FldNameList[6]   = buf_cd-events.event-type
     _FldNameList[7]   = buf_cd-events.event-description
     _Query            is OPENED
*/  /* BROWSE BROWSE-2 */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Справочник событий на кассе */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add Dialog-Frame
ON CHOOSE OF b-add IN FRAME Dialog-Frame /* Добавить */
DO:
   define variable v-id    as integer      no-undo.
   assign
      v-ok = FALSE
   .
   run ref/cdevened.w ( INPUT parparentproc
                      , INPUT v-version
                      , INPUT-OUTPUT v-id
                      , OUTPUT v-ok
                      ) NO-ERROR.
   IF ERROR-STATUS:ERROR
   THEN DO:
      message
         "Ошибка создания записи в справочнике событий на кассе"
         skip RETURN-VALUE
         skip ERROR-STATUS:GET-MESSAGE (1)
      view-as alert-box error.
   END.

   IF  v-ok
   AND v-ID <> 0
   THEN DO:
      define buffer buf_buf_cd-events      for ub.cd-events .
      FIND FIRST buf_buf_cd-events
           WHERE buf_buf_cd-events.event-id = v-ID
           NO-LOCK
           NO-ERROR
           .
      IF AVAILABLE buf_buf_cd-events
      THEN DO:
         run enable_UI.
         run post_enable_UI.
         REPOSITION {&browse-name} to rowid rowid( buf_buf_cd-events ) no-error.
      END.
   END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-chg Dialog-Frame
ON CHOOSE OF b-chg IN FRAME Dialog-Frame /* Изменить */
DO:
   IF AVAILABLE buf_cd-events
   THEN DO:

      assign
         v-ok     = FALSE
      .

      run ref/cdevened.w ( INPUT parparentproc
                         , INPUT v-version
                         , INPUT-OUTPUT buf_cd-events.event-id
                         , OUTPUT v-ok
                         ) NO-ERROR.
      IF ERROR-STATUS:ERROR
      THEN DO:
         message
            "Ошибка создания записи"
            skip RETURN-VALUE
            skip ERROR-STATUS:GET-MESSAGE (1)
         view-as alert-box error.
      END.

      IF v-ok
      THEN DO:
         {&browse-name}:refresh().
      END.
   END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del Dialog-Frame
ON CHOOSE OF b-del IN FRAME Dialog-Frame /* Удалить */
DO:
   IF AVAILABLE buf_cd-events
   THEN DO:
      ASSIGN
         v-ok = FALSE
      .
      message
         "Удалить запись?"
         skip buf_cd-events.event-id
         skip buf_cd-events.event-name
         skip buf_cd-events.event-description
         view-as alert-box QUESTION
         BUTTONS YES-NO
         update v-ok
      .
      IF v-ok
      THEN DO:
         run ref/cdevdel.p ( INPUT parparentproc
                           , INPUT v-version
                           , INPUT buf_cd-events.event-id
                           , OUTPUT v-ok
                           ) NO-ERROR.
         IF ERROR-STATUS:ERROR
         THEN DO:
            message
               "Ошибка удаления записи"
               skip RETURN-VALUE
               skip ERROR-STATUS:GET-MESSAGE (1)
            view-as alert-box error.
         END.

         IF  v-ok
         THEN DO:
            /*
            define buffer buf_buf_cd-events      for ub.cd-events .
            FIND FIRST buf_buf_cd-events
               WHERE buf_buf_cd-events.event-id = v-ID
               NO-LOCK
               NO-ERROR
               .
            IF AVAILABLE buf_buf_cd-events
            THEN DO:
            */
               run enable_UI.
               run post_enable_UI.
            /*
               REPOSITION {&browse-name} to rowid rowid( buf_buf_cd-events ) no-error.
            END.
            */
         END.
      END.
   END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-down
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-down Dialog-Frame
ON CHOOSE OF b-down IN FRAME Dialog-Frame /* Выгрузить */
DO:
   IF v-cntxt-db-num = 0
   THEN DO:
      run utl/cdevdown.p ( INPUT parparentproc
                         , INPUT-OUTPUT v-version
                         ) NO-ERROR.
      IF ERROR-STATUS:ERROR
      THEN DO:
         message
            RETURN-VALUE
            skip
         view-as alert-box ERROR.
      END.
      ELSE DO:
         run enable_UI.
         run post_enable_UI.
      END.
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


&Scoped-define SELF-NAME b-load
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-load Dialog-Frame
ON CHOOSE OF b-load IN FRAME Dialog-Frame /* Загрузить */
DO:
   IF v-cntxt-db-num = 0
   THEN DO:
      run utl/cdevload.p ( INPUT parparentproc
                         , INPUT-OUTPUT v-version
                         ) NO-ERROR.
      IF ERROR-STATUS:ERROR
      THEN DO:
         message
            RETURN-VALUE
            skip
         view-as alert-box ERROR.
      END.
      ELSE DO:
         run enable_UI.
         run post_enable_UI.
      END.
   END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-mark Dialog-Frame
ON CHOOSE OF b-mark IN FRAME Dialog-Frame /* * */
DO:
   define variable v-ok as logical no-undo .

   if not available buf_cd-events then do:
      return no-apply.
   end.

   { gbl/markstrn.i buf_cd-events rid-list }

   v-ok = {&browse-name}:select-next-row ().
   v-ok = {&browse-name}:refresh( )  in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel Dialog-Frame
ON CHOOSE OF b-sel IN FRAME Dialog-Frame /* Выбор */
DO:
   IF AVAILABLE buf_cd-events
   AND rid-list = ""
   then DO:
      assign
         rid-list = string( recid( buf_cd-events ) )
      .
   end.
   ASSIGN
      p-ok = true
   .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-2
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

   FIND LAST buf_cd-events NO-LOCK NO-ERROR.
   IF AVAILABLE buf_cd-events
   THEN DO:
      ASSIGN
         v-version = buf_cd-events.version
      .
      RELEASE buf_cd-events.
      ASSIGN
         frame {&frame-name}:TITLE = SUBSTITUTE("&1, версия &2", frame {&frame-name}:TITLE, v-version ).
      .
   END.


   { gbl/getcntxt.i get }
   { gbl/app_help.i }

   run enable_UI.
   run post_enable_UI.

   WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
run disable_UI.

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
  ENABLE b-quit b-mark b-sel b-add b-chg b-del b-load b-down b-help BROWSE-2
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Post_enable_UI Dialog-Frame
PROCEDURE Post_enable_UI :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
   DISABLE
      b-sel
      b-mark
      b-load
      b-down
      b-chg
      b-del
      b-add
   WITH FRAME Dialog-Frame.

   ENABLE
      b-sel  WHEN (( lookup  ( "b-sel":U  , p-bttns) > 0 ) OR  ( lookup  ( "b-mark":U , p-bttns) > 0 ))
      b-mark WHEN (  lookup  ( "b-mark":U , p-bttns) > 0 )
      b-load WHEN (( lookup  ( "b-add":U , p-bttns) > 0 ) AND ( v-cntxt-db-num = 0 ))
      b-down WHEN (( lookup  ( "b-add":U , p-bttns) > 0 ) AND ( v-cntxt-db-num = 0 ))
      b-chg  WHEN (( lookup  ( "b-add":U , p-bttns) > 0 ) AND ( v-cntxt-db-num = 0 ))
      b-del  WHEN (( lookup  ( "b-add":U , p-bttns) > 0 ) AND ( v-cntxt-db-num = 0 ))
      b-add  WHEN (( lookup  ( "b-add":U , p-bttns) > 0 ) AND ( v-cntxt-db-num = 0 ))
   WITH FRAME Dialog-Frame.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME