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

Связь событий на кассе с событиями СВ

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
define variable vss-description as character no-undo init "Связь событий на кассе с событиями СВ".

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ gbl/getcntxt.i def }

define variable v-mark        as logical FORMAT "*/ "     no-undo.
define variable v-change      as logical FORMAT "*/ "     no-undo.
define variable v-id          as integer      no-undo.
define variable v-vid-id      as character      no-undo.
define variable v-system-id   as character      no-undo.
define variable v-ok          as logical      no-undo.
define variable v-version     as integer      no-undo.

DEFINE BUFFER buf_cd-video-link FOR ub.cd-video-link.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-link

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES ub.cd-video-link

/* Definitions for BROWSE br-link                                       */
&Scoped-define FIELDS-IN-QUERY-br-link v-mark ub.cd-video-link.event-id ~
ub.cd-video-link.video-event-id ub.cd-video-link.video-id 
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-link 
&Scoped-define QUERY-STRING-br-link FOR EACH ub.cd-video-link NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-link OPEN QUERY br-link FOR EACH ub.cd-video-link NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br-link ub.cd-video-link
&Scoped-define FIRST-TABLE-IN-QUERY-br-link ub.cd-video-link


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-link}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit b-mark b-sel b-add b-chg b-del b-down ~
b-load b-help br-link 

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

DEFINE BUTTON b-sel 
     LABEL "Выбрать" 
     SIZE 10 BY 1.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-link FOR 
      ub.cd-video-link SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-link
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-link Dialog-Frame _STRUCTURED
  QUERY br-link NO-LOCK DISPLAY
      v-mark COLUMN-LABEL "*" WIDTH 1
      ub.cd-video-link.event-id FORMAT ">>>9":U
      ub.cd-video-link.video-event-id FORMAT "x(30)":U
      ub.cd-video-link.video-id FORMAT "x(30)":U WIDTH 69.25
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 108.5 BY 14.75 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     b-mark AT ROW 1 COL 13.5 WIDGET-ID 4
     b-sel AT ROW 1 COL 16.5 WIDGET-ID 2
     b-add AT ROW 1 COL 29 WIDGET-ID 10
     b-chg AT ROW 1 COL 39 WIDGET-ID 8
     b-del AT ROW 1 COL 49 WIDGET-ID 14
     b-down AT ROW 1 COL 61 WIDGET-ID 12
     b-load AT ROW 1 COL 71 WIDGET-ID 6
     b-help AT ROW 1 COL 99.5
     br-link AT ROW 2.25 COL 1 WIDGET-ID 200
     SPACE(0.37) SKIP(0.78)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Связь событий на кассе с событиями СВ"
         CANCEL-BUTTON b-quit WIDGET-ID 100.


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
   FRAME-NAME                                                           */
/* BROWSE-TAB br-link b-help Dialog-Frame */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-link
/* Query rebuild information for BROWSE br-link
     _TblList          = "ub.cd-video-link"
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _FldNameList[1]   > "_<CALC>"
"v-mark" "*" ? ? ? ? ? ? ? ? no ? no no "1" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[2]   = ub.cd-video-link.event-id
     _FldNameList[3]   = ub.cd-video-link.video-event-id
     _FldNameList[4]   > ub.cd-video-link.video-id
"ub.cd-video-link.video-id" ? ? "character" ? ? ? ? ? ? no ? no no "69.25" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _Query            is OPENED
*/  /* BROWSE br-link */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Связь событий на кассе с событиями СВ */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add Dialog-Frame
ON CHOOSE OF b-add IN FRAME Dialog-Frame /* Добавить */
DO:
   assign
      v-id        = 0
      v-vid-id    = "":U
      v-system-id = "":U
      v-ok        = FALSE
   .
   run ref/cdvided.w ( INPUT parparentproc
                     , INPUT-OUTPUT v-id
                     , INPUT-OUTPUT v-vid-id
                     , INPUT-OUTPUT v-system-id
                     , OUTPUT v-ok
                     ) NO-ERROR.
   IF ERROR-STATUS:ERROR
   THEN DO:
      message
         "Ошибка создания связки события на кассе и СВ"
         skip RETURN-VALUE
         skip ERROR-STATUS:GET-MESSAGE (1)
      view-as alert-box error.
   END.

   IF  v-ok
   AND v-ID        <> 0
   AND v-vid-id    <> "":U
   AND v-system-id <> "":U
   THEN DO:
      define buffer buf_cd-video-link      for ub.cd-video-link .
      FIND FIRST buf_cd-video-link
           WHERE buf_cd-video-link.event-id        = v-ID
             AND buf_cd-video-link.video-event-id  = v-vid-id
             AND buf_cd-video-link.video-id        = v-system-id
           NO-LOCK
           NO-ERROR
           .
      IF AVAILABLE buf_cd-video-link
      THEN DO:
         run enable_UI.
         run post_enable_UI.
         REPOSITION {&browse-name} to rowid rowid( buf_cd-video-link ) no-error.
      END.
   END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-chg Dialog-Frame
ON CHOOSE OF b-chg IN FRAME Dialog-Frame /* Изменить */
DO:
IF AVAILABLE ub.cd-video-link
   THEN DO:

      assign
         v-ok     = FALSE
      .

      run ref/cdvided.w  ( INPUT parparentproc
                         , INPUT-OUTPUT ub.cd-video-link.event-id 
                         , INPUT-OUTPUT ub.cd-video-link.video-event-id
                         , INPUT-OUTPUT ub.cd-video-link.video-id
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
   END. /*    IF AVAILABLE ub.cd-video-link                                                       */
/*    THEN DO:                                                                            */
/*       define variable v-id-old    as integer      no-undo.                             */
/*       define variable v-vid-id-old    as character      no-undo.                       */
/*       define variable v-system-id-old as character      no-undo.                       */
/*                                                                                        */
/*       assign                                                                           */
/*          v-id              = ub.cd-video-link.event-id                                 */
/*          v-vid-id          = ub.cd-video-link.video-event-id                           */
/*          v-system-id       = ub.cd-video-link.video-id                                 */
/*          v-id-old          = ub.cd-video-link.event-id                                 */
/*          v-vid-id-old      = ub.cd-video-link.video-event-id                           */
/*          v-system-id-old   = ub.cd-video-link.video-id                                 */
/*          v-ok              = FALSE                                                     */
/*       .                                                                                */
/*                                                                                        */
/*       run ref/cdvided.w ( INPUT parparentproc                                          */
/*                         , INPUT-OUTPUT v-id                                            */
/*                         , INPUT-OUTPUT v-vid-id                                        */
/*                         , INPUT-OUTPUT v-system-id                                     */
/*                         , OUTPUT v-ok                                                  */
/*                         ) NO-ERROR.                                                    */
/*       IF ERROR-STATUS:ERROR                                                            */
/*       THEN DO:                                                                         */
/*          message                                                                       */
/*             "Ошибка создания записи"                                                   */
/*             skip RETURN-VALUE                                                          */
/*             skip ERROR-STATUS:GET-MESSAGE (1)                                          */
/*          view-as alert-box error.                                                      */
/*       END.                                                                             */
/*                                                                                        */
/*       IF v-ok                                                                          */
/*       THEN DO:                                                                         */
/*          IF  v-ID        = v-ID-old                                                    */
/*          AND v-vid-id    = v-vid-id-old                                                */
/*          AND v-system-id = v-system-id-old                                             */
/*          THEN DO:                                                                      */
/*             {&browse-name}:refresh().                                                  */
/*          END.                                                                          */
/*          ELSE DO:                                                                      */
/*             define buffer buf_cd-video-link      for ub.cd-video-link .                */
/*             FIND FIRST buf_cd-video-link                                               */
/*                  WHERE buf_cd-video-link.event-id        = v-ID                        */
/*                    AND buf_cd-video-link.video-event-id  = v-vid-id                    */
/*                    AND buf_cd-video-link.video-id        = v-system-id                 */
/*                  NO-LOCK                                                               */
/*                  NO-ERROR                                                              */
/*                  .                                                                     */
/*             IF AVAILABLE buf_cd-video-link                                             */
/*             THEN DO:                                                                   */
/*                run enable_UI.                                                          */
/*                run post_enable_UI.                                                     */
/*                REPOSITION {&browse-name} to rowid rowid( buf_cd-video-link ) no-error. */
/*             END.                                                                       */
/*          END.                                                                          */
/*       END.                                                                             */
/*    END.                                                                                */
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del Dialog-Frame
ON CHOOSE OF b-del IN FRAME Dialog-Frame /* Удалить */
DO:
   IF AVAILABLE ub.cd-video-link
   THEN DO:
      ASSIGN
         v-ok = FALSE
      .
      message
         "Удалить запись?"
         skip ub.cd-video-link.event-id
         skip ub.cd-video-link.video-event-id
         skip ub.cd-video-link.video-id
         view-as alert-box QUESTION
         BUTTONS YES-NO
         update v-ok
      .
      IF v-ok
      THEN DO:
         run ref/cdviddel.p ( INPUT parparentproc
                            , INPUT ub.cd-video-link.event-id
                            , INPUT ub.cd-video-link.video-event-id
                            , INPUT ub.cd-video-link.video-id
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
            define buffer buf_cd-video-link      for ub.cd-video-link .
            FIND FIRST buf_cd-video-link
                 WHERE buf_cd-video-link.event-id        = ub.cd-video-link.event-id
                   AND buf_cd-video-link.video-event-id  = ub.cd-video-link.video-event-id
                   AND buf_cd-video-link.video-id        = ub.cd-video-link.video-id
                 EXCLUSIVE-LOCK
                 NO-ERROR
                 .
            IF AVAILABLE buf_cd-video-link
            THEN DO:
               run enable_UI.
               run post_enable_UI.
               DELETE  buf_cd-video-link.
               REPOSITION {&browse-name} to rowid rowid( buf_cd-video-link ) no-error.
            end.
            /*
            define buffer buf_cd-events      for ub.cd-events .
            FIND FIRST buf_cd-events
               WHERE buf_cd-events.event-id = v-ID
               NO-LOCK
               NO-ERROR
               .
            IF AVAILABLE buf_cd-events
            THEN DO:
            */
               run enable_UI.
               run post_enable_UI.
            /*
               REPOSITION {&browse-name} to rowid rowid( buf_cd-events ) no-error.
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
      run utl/cdvddown.p ( INPUT parparentproc
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
      run utl/cdvdload.p ( INPUT parparentproc
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

   if not available ub.cd-video-link then do:
      return no-apply.
   end.

   { gbl/markstrn.i ub.cd-video-link rid-list }

   v-ok = {&browse-name}:select-next-row ().
   v-ok = {&browse-name}:refresh( )  in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel Dialog-Frame
ON CHOOSE OF b-sel IN FRAME Dialog-Frame /* Выбрать */
DO:
   IF AVAILABLE ub.cd-video-link
   AND rid-list = ""
   then DO:
      assign
         rid-list = string( recid( ub.cd-video-link ) )
      .
   end.
   ASSIGN
      p-ok = true
   .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-link
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
  ENABLE b-quit b-mark b-sel b-add b-chg b-del b-down b-load b-help br-link 
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

