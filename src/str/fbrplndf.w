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

План-меню: список документов производства.

Автор: Белоусов Илья Александрович
Дата создания: 04/12/06
Author: Ilia Belousov
Creation date: 04/12/06

Input:

Output:

*/
/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

define input parameter parparentproc        as widget-handle    no-undo.
define input parameter p-fbr-pln-doc-code   as character        no-undo.
define input parameter p-fbr-pln-obj-type   as character        no-undo.
define input parameter p-fbr-pln-obj-code   as integer          no-undo.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "План-меню: список документов производства.".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ str/fbrpln.i   }
{ cmp/showinf.i  }
{ gbl/getcntxt.i def }

define new shared variable br-handle as handle no-undo.
define new shared buffer f-doc      for fbr-doc.
define new shared query br-docs     for f-doc scrolling.

define temp-table temp_kitchen-object no-undo
    field obj-type  as character
    field obj-code  as integer
.
define temp-table temp_fbr-doc no-undo
    field doc-code  as character
    field status_   as character
    field doc-date  as date
    field obj-type  as character
    field obj-code  as integer
    field PS        as character
.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-table

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES temp_fbr-doc

/* Definitions for BROWSE br-table                                      */
&Scoped-define FIELDS-IN-QUERY-br-table temp_fbr-doc.doc-code temp_fbr-doc.status_ temp_fbr-doc.doc-date temp_fbr-doc.obj-type temp_fbr-doc.obj-code temp_fbr-doc.PS
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-table
&Scoped-define SELF-NAME br-table
&Scoped-define QUERY-STRING-br-table FOR EACH temp_fbr-doc NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-table OPEN QUERY {&SELF-NAME} FOR EACH temp_fbr-doc NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br-table temp_fbr-doc
&Scoped-define FIRST-TABLE-IN-QUERY-br-table temp_fbr-doc


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-table}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-lkp b-help br-table

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-exit AUTO-GO
     LABEL "В&ыход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-lkp
     LABEL "Просмотр"
     SIZE 10 BY 1.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-table FOR
      temp_fbr-doc SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-table
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-table Dialog-Frame _FREEFORM
  QUERY br-table NO-LOCK DISPLAY
      temp_fbr-doc.doc-code format "X(10)"  column-label "Номер"
temp_fbr-doc.status_  format "X(4)"         column-label "Статус"
temp_fbr-doc.doc-date format "99.99.99"     column-label "Дата"
temp_fbr-doc.obj-type format "X(3)"         column-label "Тип"
temp_fbr-doc.obj-code format "99999"        column-label "Код объекта"
temp_fbr-doc.PS       format "X(40)"        column-label "Примечание"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 21 ROW-HEIGHT-CHARS .67 EXPANDABLE.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-lkp AT ROW 1 COL 11
     b-help AT ROW 1 COL 89.5
     br-table AT ROW 2.25 COL 1.5
     SPACE(0.37) SKIP(0.24)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Список документов производства"
         DEFAULT-BUTTON b-exit.


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
/* BROWSE-TAB br-table b-help Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-table
/* Query rebuild information for BROWSE br-table
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH temp_fbr-doc NO-LOCK INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE br-table */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Список документов производства */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit Dialog-Frame
ON CHOOSE OF b-exit IN FRAME Dialog-Frame /* Выход */
DO:
{ gbl/stdbtn.i }

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-lkp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-lkp Dialog-Frame
ON CHOOSE OF b-lkp IN FRAME Dialog-Frame /* Просмотр */
DO:
    { gbl/stdbtn.i }

    define variable v-allow-lookup          as logical      no-undo.
    define variable v-fbr-doc-next-prev     as logical      no-undo.
    define variable v-fbr-doc-recid         as recid        no-undo.

    find first f-doc
         where f-doc.doc-code = temp_fbr-doc.doc-code
    no-error.

    { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      'actn_manufacturing_lookup':U
      {&cntxt-object}
      f-doc.host-code
      f-doc.obj-type
      f-doc.obj-code
      0
      0
      0
      true
      v-allow-lookup
    }
    if v-allow-lookup = no
    then do:
        undo, return no-apply.
    end.
    assign
        v-fbr-doc-next-prev = yes
        br-handle           = br-table :handle
    .
    do while v-fbr-doc-next-prev <> ?
    :
        if not available f-doc
        then do:
            message
                "Неправильный выбор документа."
            view-as alert-box error.
            return no-apply.
        end.
        run str/fbr-doc.w (
            input parparentproc
          , input this-procedure
          , input {&lookup}
          , input recid( f-doc )
          , output v-fbr-doc-recid
          , input-output v-fbr-doc-next-prev
        ).
    end.
    if br-handle = ?
    then do:
        find first f-doc no-lock
             where recid( f-doc ) = v-fbr-doc-recid
        no-error.
        find first temp_fbr-doc
             where temp_fbr-doc.doc-code = f-doc.doc-code
        no-error.
        reposition br-table to recid recid( temp_fbr-doc ) no-error.
    end.
    apply "entry" to br-table in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-table
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

{ gbl/app_help.i }

{ gbl/hot-key.i b-lkp }

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

  { gbl/getcntxt.i get }

    run fill-temp_kitchen-object in this-procedure (
        input p-fbr-pln-doc-code
    ).
    run fill-temp_fbr-doc in this-procedure (
        input p-fbr-pln-doc-code
    ).
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
  ENABLE b-exit b-lkp b-help br-table
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-temp_fbr-doc Dialog-Frame
PROCEDURE fill-temp_fbr-doc :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-fbr-pln-doc-code   as character        no-undo.

    define buffer buf_fbr-doc       for fbr-doc.
    define buffer buf_temp_fbr-doc  for temp_fbr-doc.
do
on error undo, return error
:
    for each buf_fbr-doc no-lock
       where buf_fbr-doc.out-code = p-fbr-pln-doc-code
    on error undo, return error
    :
        create buf_temp_fbr-doc.
        assign
            buf_temp_fbr-doc.doc-code = buf_fbr-doc.doc-code
            buf_temp_fbr-doc.status_  = buf_fbr-doc.status_
            buf_temp_fbr-doc.doc-date = buf_fbr-doc.doc-date
            buf_temp_fbr-doc.obj-type = buf_fbr-doc.obj-type
            buf_temp_fbr-doc.obj-code = buf_fbr-doc.obj-code
            buf_temp_fbr-doc.PS       = buf_fbr-doc.PS
        .
    end.        /* for each buf_fbr-doc */
end.
END PROCEDURE. /* fill-temp_fbr-doc */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-temp_kitchen-object Dialog-Frame
PROCEDURE fill-temp_kitchen-object :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-fbr-pln-doc-code   as character        no-undo.

    define buffer buf_fbr-pln-line          for fbr-pln-line.
    define buffer buf_temp_kitchen-object   for temp_kitchen-object.
do
on error undo, return error
:
    for each buf_fbr-pln-line no-lock
       where buf_fbr-pln-line.doc-code = p-fbr-pln-doc-code
    on error undo, return error
    :
        find first buf_temp_kitchen-object
             where buf_temp_kitchen-object.obj-type = buf_fbr-pln-line.fbr-obj-type
               and buf_temp_kitchen-object.obj-code = buf_fbr-pln-line.fbr-obj-code
        no-error.
        if not available buf_temp_kitchen-object
        then do:
            create buf_temp_kitchen-object.
            assign
                buf_temp_kitchen-object.obj-type = buf_fbr-pln-line.fbr-obj-type
                buf_temp_kitchen-object.obj-code = buf_fbr-pln-line.fbr-obj-code
            .
        end.
    end.        /* for each buf_fbr-pln-line */
end.
END PROCEDURE. /* fill-temp_kitchen-object */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME