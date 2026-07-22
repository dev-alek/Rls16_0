&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
/* Connected Databases
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

Список групп товаров на которое распространяется данное право

Автор: Белоусов Илья Александрович
Дата создания: 04/09/08
Author: Ilia Belousov
Creation date: 04/09/08

Input:

Output:

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                          */
define input parameter parparentproc  as widget-handle no-undo .
define input parameter  p-head-code   as integer       no-undo .
define input parameter p-role-code as integer          no-undo.
define input parameter p-item-code as integer          no-undo.
define INPUT-output parameter p-gds-list  as character     no-undo .
define output parameter p-ok          as logical       no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Список групп товаров на которое распространяется данное право".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ gbl/getcntxt.i def }

define variable v-ref-list    as character                     no-undo.

define temp-table tt-goods no-undo like ub.gds-grp.

define buffer buf_tt-goods for tt-goods .

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
&Scoped-define INTERNAL-TABLES buf_tt-goods

/* Definitions for BROWSE BROWSE-2                                      */
&Scoped-define FIELDS-IN-QUERY-BROWSE-2 buf_tt-goods.node-name
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-2
&Scoped-define SELF-NAME BROWSE-2
&Scoped-define QUERY-STRING-BROWSE-2 FOR EACH buf_tt-goods
&Scoped-define OPEN-QUERY-BROWSE-2 OPEN QUERY {&SELF-NAME} FOR EACH buf_tt-goods.
&Scoped-define TABLES-IN-QUERY-BROWSE-2 buf_tt-goods
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-2 buf_tt-goods


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BROWSE-2}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-quit b-add b-del b-help BROWSE-2

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-add
     LABEL "Добавить"
     SIZE 10 BY 1.

DEFINE BUTTON b-del
     LABEL "Удалить"
     SIZE 10 BY 1.

DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-GO
     LABEL "&Отмена"
     SIZE 10 BY 1.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BROWSE-2 FOR
      buf_tt-goods SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BROWSE-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-2 Dialog-Frame _FREEFORM
  QUERY BROWSE-2 DISPLAY
      buf_tt-goods.node-name
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 64 BY 19.76 ROW-HEIGHT-CHARS .75 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11 WIDGET-ID 6
     b-add AT ROW 1 COL 21 WIDGET-ID 2
     b-del AT ROW 1 COL 31 WIDGET-ID 4
     b-help AT ROW 1 COL 55
     BROWSE-2 AT ROW 2.24 COL 1 WIDGET-ID 200
     SPACE(0.13) SKIP(0.99)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "<insert dialog title>"
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
/* BROWSE-TAB BROWSE-2 b-help Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-2
/* Query rebuild information for BROWSE BROWSE-2
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH buf_tt-goods.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE BROWSE-2 */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* <insert dialog title> */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add Dialog-Frame
ON CHOOSE OF b-add IN FRAME Dialog-Frame /* Добавить */
DO:

   run ref/gds-grp.w ( INPUT parparentproc
                     , INPUT "b-sel,b-mark"
                     , INPUT v-cntxt-obj-type
                     , INPUT v-cntxt-obj-code
                     , INPUT-OUTPUT v-ref-list).

   if v-ref-list <> "" then do:
      RUN create-actn-gds IN THIS-PROCEDURE ( INPUT v-ref-list ) no-error.
      if error-status:error then do:
         message
            vss-workfile vss-revision vss-description skip
            "Ошибка при вызове процедуры создания товара" skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
         return no-apply.
      end.
      {&OPEN-QUERY-{&BROWSE-NAME}}
   end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del Dialog-Frame
ON CHOOSE OF b-del IN FRAME Dialog-Frame /* Удалить */
DO:
  IF AVAILABLE buf_tt-goods THEN DO:
     delete buf_tt-goods.
  END.
  {&OPEN-QUERY-{&BROWSE-NAME}}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit Dialog-Frame
ON CHOOSE OF b-exit IN FRAME Dialog-Frame /* Выход */
DO:
  for each tt-goods
      :
      assign
         p-gds-list = IF p-gds-list = "":U THEN STRING(tt-goods.node-code)
                                           ELSE p-gds-list + {&delim-par} + STRING(tt-goods.node-code)
      .
  end.

  ASSIGN
      p-ok = TRUE
  .
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


&Scoped-define BROWSE-NAME BROWSE-2
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
  run fill-tt-goods in this-procedure.

  RUN enable_UI.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.

END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE create-actn-gds Dialog-Frame
PROCEDURE create-actn-gds :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-ref-list as character        no-undo.

define variable v-count as integer no-undo .

define buffer buf_gds-grp                 for ub.gds-grp .
define buffer bf_tt-goods                 for tt-goods .
define buffer buf_action-role-item-gds-grp    for ub.action-role-item-gds-grp .

do
on error undo, return error
:
   _add-goods:
   DO v-count = 1 TO NUM-ENTRIES(p-ref-list)
   on error undo, next
   :
      find first buf_gds-grp
           where recid( buf_gds-grp ) = INTEGER(ENTRY(v-count, p-ref-list))
           NO-LOCK
           no-error
           .
      IF NOT AVAILABLE buf_gds-grp
      THEN NEXT _add-goods.

      find first bf_tt-goods
           where bf_tt-goods.node-code = buf_gds-grp.node-code
           no-lock
           no-error
           .
      IF NOT AVAILABLE bf_tt-goods THEN DO:
         create bf_tt-goods.
         buffer-copy buf_gds-grp to bf_tt-goods .
      END.
   end. /* _add-goods */
end.  /* do on error */
END PROCEDURE. /* create-actn-gds */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE delete-actn-gds Dialog-Frame
PROCEDURE delete-actn-gds :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-gds-code as integer        no-undo.

define buffer buf_action-role-item-gds    for ub.action-role-item-gds .

do
on error undo, return error
:
   /*
   find first buf_action-role-item-gds
        where buf_action-role-item-gds.db-num            = v-cntxt-db-num
          AND buf_action-role-item-gds.action-head-code = p-head-code
          AND buf_action-role-item-gds.action-role-code = p-role-code
          AND buf_action-role-item-gds.action-item-code = p-item-code
          AND buf_action-role-item-gds.gds-code         = p-gds-code
        exclusive-lock
        no-error
        .
   IF AVAILABLE buf_action-role-item-gds then do:
      delete buf_action-role-item-gds.
   end.
   */
end.  /* do on error */
END PROCEDURE. /* delete-actn-gds */

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
  ENABLE b-exit b-quit b-add b-del b-help BROWSE-2
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-tt-goods Dialog-Frame
PROCEDURE fill-tt-goods :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define buffer buf_gds-grp                   for ub.gds-grp .
define buffer buf_action-role-item-gds-grp    for ub.action-role-item-gds-grp .

define variable v-count    as integer      no-undo.

do
on error undo, return error
:
   IF p-gds-list = "":U
   THEN DO:
      FOR EACH  buf_action-role-item-gds-grp
          where buf_action-role-item-gds-grp.db-num           = v-cntxt-db-num
            AND buf_action-role-item-gds-grp.action-head-code = p-head-code
            AND buf_action-role-item-gds-grp.action-role-code = p-role-code
            AND buf_action-role-item-gds-grp.action-item-code = p-item-code
       no-lock
       :

         FIND first buf_gds-grp
            where buf_gds-grp.node-code = buf_action-role-item-gds-grp.gds-grp-code
            no-lock
            no-error
            .

         create tt-goods.
         buffer-copy buf_gds-grp to tt-goods .
      END.
   END.
   ELSE DO:
      DO v-count = 1 TO NUM-ENTRIES(p-Gds-List, {&delim-par})
      on error undo, next
      :
         FIND first buf_gds-grp
              where buf_gds-grp.node-code = INTEGER(ENTRY(v-count, p-Gds-List, {&delim-par}))
              no-lock
              no-error
             .
         IF AVAILABLE buf_gds-grp THEN DO:
            create tt-goods.
            buffer-copy buf_gds-grp to tt-goods .
         END.
      END. /* _add-goods */
   END.
end.  /* do on error */
END PROCEDURE. /* fill-tt-goods */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME