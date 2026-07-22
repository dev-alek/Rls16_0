&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Окно истории документа производства

Автор: Белоусов Илья Александрович
Дата создания: 03/05/08
Author: Ilia Belousov
Creation date: 03/05/08

Input:

Output:

*/
/* ***************************  Definitions  ************************** */

define temp-table temp_fbr-history  no-undo
    field fbh-key       as integer
    field fbhType       as character
    field fbhAction     as character
    field fbhDate       as character
    field fbhTime       as character
    field fbhUser       as character
    field fbhChangeList as character

    index pi is primary unique
        fbh-key
.
define temp-table temp_fbr-history-line no-undo
    field fbl-key       as integer
    field fbh-key       as integer
    field fblLabel      as character
    field fblOldValue   as character
    field fblNewValue   as character
    field fblFieldName  as character
    field fblType       as character
    field fblVisible    as logical

    index pi is primary unique
        fbl-key
    index visible
        fbh-key
        fblVisible
.
define temp-table temp_fbr-history-fields no-undo
    field fbf-key       as integer
    field fbfName       as character
    field fbfLabel      as character
    field fbfFormat     as character
    field fbfVisible    as logical

    index pi is primary unique
        fbf-key
.
define variable v-fbrdocsh-fbf-key    as integer      no-undo.
define variable v-fbrdocsh-fbl-key    as integer      no-undo.
define variable v-fbrdocsh-fbh-key    as integer      no-undo.

/* Parameters Definitions ---                                           */
define input parameter parparentproc    as widget-handle    no-undo.
define input parameter p-fbr-doc-code   as character        no-undo.

/* Local Variable Definitions ---                                       */

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Окно истории документа производства".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/schemlib.i }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-lines

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES temp_fbr-history-line temp_fbr-history

/* Definitions for BROWSE br-lines                                      */
&Scoped-define FIELDS-IN-QUERY-br-lines temp_fbr-history-line.fblLabel temp_fbr-history-line.fblOldValue temp_fbr-history-line.fblNewValue temp_fbr-history-line.fblFieldName temp_fbr-history-line.fblType   
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-lines   
&Scoped-define SELF-NAME br-lines
&Scoped-define OPEN-QUERY-br-lines run local-open-query-line in this-procedure. /* OPEN QUERY {&SELF-NAME} FOR EACH temp_fbr-history-line NO-LOCK INDEXED-REPOSITION. */.
&Scoped-define TABLES-IN-QUERY-br-lines temp_fbr-history-line
&Scoped-define FIRST-TABLE-IN-QUERY-br-lines temp_fbr-history-line


/* Definitions for BROWSE br-table                                      */
&Scoped-define FIELDS-IN-QUERY-br-table temp_fbr-history.fbhType temp_fbr-history.fbhAction temp_fbr-history.fbhDate temp_fbr-history.fbhTime temp_fbr-history.fbhUser   
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-table   
&Scoped-define SELF-NAME br-table
&Scoped-define OPEN-QUERY-br-table run local-open-query in this-procedure. /* OPEN QUERY {&SELF-NAME} FOR EACH temp_fbr-history NO-LOCK INDEXED-REPOSITION. */.
&Scoped-define TABLES-IN-QUERY-br-table temp_fbr-history
&Scoped-define FIRST-TABLE-IN-QUERY-br-table temp_fbr-history


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-lines}~
    ~{&OPEN-QUERY-br-table}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-cancel b-help br-table br-lines 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-nik Dialog-Frame 
FUNCTION get-nik RETURNS CHARACTER
  ( input p-userid as character )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-cancel AUTO-END-KEY 
     LABEL "&Отмена" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-exit AUTO-GO 
     LABEL "В&ыход" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-help 
     LABEL "Помо&щь" 
     SIZE 10 BY 1
     BGCOLOR 8 .

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-lines FOR 
      temp_fbr-history-line SCROLLING.

DEFINE QUERY br-table FOR 
      temp_fbr-history SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-lines
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-lines Dialog-Frame _FREEFORM
  QUERY br-lines NO-LOCK DISPLAY
      temp_fbr-history-line.fblLabel     FORMAT "X(40)":U column-label "Поле"
      temp_fbr-history-line.fblOldValue  FORMAT "X(40)":U column-label "Старое значение"
      temp_fbr-history-line.fblNewValue  FORMAT "X(40)":U column-label "Значение после изменения"
      temp_fbr-history-line.fblFieldName FORMAT "X(20)":U column-label "Имя поля"
      temp_fbr-history-line.fblType      FORMAT "X(20)":U column-label "Тип поля"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98.5 BY 6.13 FIT-LAST-COLUMN.

DEFINE BROWSE br-table
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-table Dialog-Frame _FREEFORM
  QUERY br-table NO-LOCK DISPLAY
      temp_fbr-history.fbhType    format "X(10)" label "Тип"
    temp_fbr-history.fbhAction  format "X(10)" label "Действие"
    temp_fbr-history.fbhDate    format "X(10)" label "ДатаКорр"
    temp_fbr-history.fbhTime    format "X(10)" label "ВремяКорр"
    temp_fbr-history.fbhUser    format "X(30)" label "Пользователь"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 14.75 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-cancel AT ROW 1 COL 11
     b-help AT ROW 1 COL 89.5
     br-table AT ROW 2.5 COL 1.5 WIDGET-ID 200
     br-lines AT ROW 17.5 COL 1 WIDGET-ID 300
     SPACE(0.37) SKIP(0.00)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "История документа производства"
         DEFAULT-BUTTON b-exit CANCEL-BUTTON b-cancel WIDGET-ID 100.


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
/* BROWSE-TAB br-table b-help Dialog-Frame */
/* BROWSE-TAB br-lines br-table Dialog-Frame */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN 
       br-lines:COLUMN-RESIZABLE IN FRAME Dialog-Frame       = TRUE.

ASSIGN 
       br-table:COLUMN-RESIZABLE IN FRAME Dialog-Frame       = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-lines
/* Query rebuild information for BROWSE br-lines
     _START_FREEFORM
run local-open-query-line in this-procedure. /* OPEN QUERY {&SELF-NAME} FOR EACH temp_fbr-history-line NO-LOCK INDEXED-REPOSITION. */
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE br-lines */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-table
/* Query rebuild information for BROWSE br-table
     _START_FREEFORM
run local-open-query in this-procedure. /* OPEN QUERY {&SELF-NAME} FOR EACH temp_fbr-history NO-LOCK INDEXED-REPOSITION. */
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE br-table */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* История документа производства */
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


&Scoped-define BROWSE-NAME br-table
&Scoped-define SELF-NAME br-table
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-table Dialog-Frame
ON VALUE-CHANGED OF br-table IN FRAME Dialog-Frame
DO:
    if available temp_fbr-history
    then do:
        run manage-fields in this-procedure (
            input temp_fbr-history.fbh-key
        ).
    end.
    {&OPEN-QUERY-br-lines}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-lines
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame 


/* ***************************  Main Block  *************************** */

{ gbl/app_help.i }
/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
    run init-fields in this-procedure .
    RUN enable_UI.
    apply "entry":U to br-table.
    {&OPEN-QUERY-br-lines}
    WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE create-field-exception Dialog-Frame 
PROCEDURE create-field-exception :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-name     as character        no-undo.
define input parameter p-label    as character        no-undo.
define input parameter p-format   as character        no-undo.
define input parameter p-visible  as logical          no-undo.

    define buffer buf_temp_fbr-history-fields       for temp_fbr-history-fields.
do
for buf_temp_fbr-history-fields
on error undo, return error
:
    assign
        v-fbrdocsh-fbf-key = v-fbrdocsh-fbf-key + 1
    .
    create buf_temp_fbr-history-fields.
    assign
        buf_temp_fbr-history-fields.fbf-key     = v-fbrdocsh-fbf-key
        buf_temp_fbr-history-fields.fbfName     = p-name
        buf_temp_fbr-history-fields.fbfLabel    = p-label
        buf_temp_fbr-history-fields.fbfFormat   = p-format
        buf_temp_fbr-history-fields.fbfVisible  = p-visible
    .
end.
END PROCEDURE. /* create-field-exception */

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
  ENABLE b-exit b-cancel b-help br-table br-lines 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-fields Dialog-Frame 
PROCEDURE init-fields :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define variable v-buffer-handle     as handle       no-undo.
    define variable v-old-buffer-handle as handle       no-undo.
    define variable v-counter           as integer      no-undo.
    define variable v-num-fields        as integer      no-undo.
    define variable v-field-handle      as handle       no-undo.
    define variable v-query-handle      as handle       no-undo.
    define variable v-query             as character    no-undo.
    define variable v-changes           as character    no-undo.

    define buffer buf_temp_fbr-history          for temp_fbr-history.
    define buffer buf_temp_fbr-history-line     for temp_fbr-history-line.
    define buffer buf_temp_fbr-history-fields   for temp_fbr-history-fields.
do
for buf_temp_fbr-history
  , buf_temp_fbr-history-line
  , buf_temp_fbr-history-fields
on error undo, return error
:
    run create-field-exception in this-procedure ( input "pay-code":U       , input "Код оплаты"    , input "":U        , input yes ).
    run create-field-exception in this-procedure ( input "sys-time-int":U   , input "Время(целое)"  , input "":U        , input no  ).
    run create-field-exception in this-procedure ( input "corr-time":U      , input "":U            , input "HH:MM:SS":U, input yes  ).

    create buffer v-buffer-handle       for table "c-fbr-doc":U buffer-name "buf_c-fbr-doc":U .
    create buffer v-old-buffer-handle   for table "c-fbr-doc":U buffer-name "buf_new_c-fbr-doc":U .
    assign
        v-num-fields = v-buffer-handle :num-fields
    .
    create query v-query-handle .
    v-query-handle :set-buffers( v-buffer-handle ).
    assign
        v-query     = substitute( "for each buf_c-fbr-doc where buf_c-fbr-doc.doc-code = '&1'"
                                , p-fbr-doc-code )
    .
    v-query-handle :query-prepare( v-query ).
    v-query-handle :query-open.
    v-query-handle :get-first.
    if v-query-handle :query-off-end = no
    then do:
        assign
            v-fbrdocsh-fbh-key              = v-fbrdocsh-fbh-key + 1
        .
        create buf_temp_fbr-history.
        assign
            buf_temp_fbr-history.fbh-key    = v-fbrdocsh-fbh-key
            buf_temp_fbr-history.fbhType    = "Документ"
            buf_temp_fbr-history.fbhAction  = "Создание"
            buf_temp_fbr-history.fbhDate    = string( v-buffer-handle :buffer-field ( "corr-date":U )       :buffer-value, "99.99.9999":U )
            buf_temp_fbr-history.fbhTime    = string( v-buffer-handle :buffer-field ( "corr-time":U )       :buffer-value, "HH:MM":U      )
            buf_temp_fbr-history.fbhUser    = v-buffer-handle         :buffer-field ( "corr-user-name":U )  :buffer-value
        .
        do v-counter = 1 to v-num-fields
        on error undo, return error substitute( "&1. &2", vss-workfile, error-status :get-message ( 1 ) )
        :
            assign
                v-fbrdocsh-fbl-key              = v-fbrdocsh-fbl-key + 1
            .
            create buf_temp_fbr-history-line.
            assign
                buf_temp_fbr-history-line.fbl-key       = v-fbrdocsh-fbl-key
                buf_temp_fbr-history-line.fbh-key       = buf_temp_fbr-history.fbh-key
                buf_temp_fbr-history-line.fblLabel      = v-buffer-handle :buffer-field( v-counter ) :label
                buf_temp_fbr-history-line.fblOldValue   = "":U
                buf_temp_fbr-history-line.fblNewValue   = string( v-buffer-handle :buffer-field( v-counter ) :buffer-value )
                buf_temp_fbr-history-line.fblFieldName  = v-buffer-handle :buffer-field( v-counter ) :name
                buf_temp_fbr-history-line.fblVisible    = yes
                buf_temp_fbr-history-line.fblType       = v-buffer-handle :buffer-field( v-counter ) :data-type
            .
            find first buf_temp_fbr-history-fields
                 where buf_temp_fbr-history-fields.fbfName = buf_temp_fbr-history-line.fblFieldName
            no-error.
            if available buf_temp_fbr-history-fields
            then do:
                if buf_temp_fbr-history-fields.fbfFormat <> "":U
                then do:
                    assign
                        buf_temp_fbr-history-line.fblNewValue      = string( v-buffer-handle :buffer-field( v-counter ) :buffer-value, buf_temp_fbr-history-fields.fbfFormat )
                    .
                end.
                if buf_temp_fbr-history-fields.fbfLabel <> "":U
                then do:
                    assign
                        buf_temp_fbr-history-line.fblLabel      = buf_temp_fbr-history-fields.fbfLabel
                    .
                end.
                assign
                    buf_temp_fbr-history-line.fblVisible    = buf_temp_fbr-history-fields.fbfVisible
                .
            end.
        end.
        calc-changes:
        do
        while yes
        on error undo, return error
        :
            run schemlib-set-buffer in this-procedure (
                  input "c-fbr-doc":U
                , input "doc-code,corr-user-db-num,chip-num":U
                , input substitute( "&1,&2,&3"
                                    , v-buffer-handle :buffer-field( "doc-code":U ) :buffer-value
                                    , v-buffer-handle :buffer-field( "corr-user-db-num":U ) :buffer-value
                                    , v-buffer-handle :buffer-field( "chip-num":U ) :buffer-value
                                    )
                , output v-old-buffer-handle
            ).
            v-query-handle :get-next( no-lock ).
            if v-query-handle :query-off-end = yes
            then do:
                undo calc-changes, leave calc-changes.
            end.
            else do:
                assign
                    v-fbrdocsh-fbh-key              = v-fbrdocsh-fbh-key + 1
                .
                create buf_temp_fbr-history.
                assign
                    buf_temp_fbr-history.fbh-key    = v-fbrdocsh-fbh-key
                    buf_temp_fbr-history.fbhType    = "Документ"
                    buf_temp_fbr-history.fbhAction  = "Изменение"
                    buf_temp_fbr-history.fbhDate    = string( v-old-buffer-handle :buffer-field ( "corr-date":U )       :buffer-value, "99.99.9999":U )
                    buf_temp_fbr-history.fbhTime    = string( v-old-buffer-handle :buffer-field ( "corr-time":U )       :buffer-value, "HH:MM":U      )
                    buf_temp_fbr-history.fbhUser    = v-old-buffer-handle         :buffer-field ( "corr-user-name":U )  :buffer-value
                .
                do v-counter = 1 to v-num-fields
                on error undo, return error substitute( "&1. &2", vss-workfile, error-status :get-message ( 1 ) )
                :
                    assign
                        v-field-handle = v-buffer-handle :buffer-field( v-counter )
                    .
                    /* replace( replace( v-field-handle:buffer-value, '"':U, '""':U ), '~~':U, '~~~~':U ) */
                    if v-field-handle :buffer-value <> v-old-buffer-handle :buffer-field ( v-counter ) :buffer-value
/*                    and v-field-handle :field-name <> "":U*/
                    then do:
                        assign
                            v-fbrdocsh-fbl-key              = v-fbrdocsh-fbl-key + 1
                        .
                        create buf_temp_fbr-history-line.
                        assign
                            buf_temp_fbr-history-line.fbl-key       = v-fbrdocsh-fbl-key
                            buf_temp_fbr-history-line.fbh-key       = buf_temp_fbr-history.fbh-key
                            buf_temp_fbr-history-line.fblLabel      = v-buffer-handle :buffer-field( v-counter ) :label
                            buf_temp_fbr-history-line.fblOldValue   = string( v-old-buffer-handle :buffer-field ( v-counter ) :buffer-value )
                            buf_temp_fbr-history-line.fblNewValue   = string( v-field-handle :buffer-value )
                            buf_temp_fbr-history-line.fblFieldName  = v-buffer-handle :buffer-field( v-counter ) :name
                            buf_temp_fbr-history-line.fblType       = v-buffer-handle :buffer-field( v-counter ) :data-type
                            buf_temp_fbr-history-line.fblVisible    = yes
                        .
                        find first buf_temp_fbr-history-fields
                             where buf_temp_fbr-history-fields.fbfName = buf_temp_fbr-history-line.fblFieldName
                        no-error.
                        if available buf_temp_fbr-history-fields
                        then do:
                            if buf_temp_fbr-history-fields.fbfFormat <> "":U
                            then do:
                                assign
                                    buf_temp_fbr-history-line.fblOldValue      = string( v-old-buffer-handle :buffer-field ( v-counter ) :buffer-value  , buf_temp_fbr-history-fields.fbfFormat )
                                    buf_temp_fbr-history-line.fblNewValue      = string( v-field-handle :buffer-value                                   , buf_temp_fbr-history-fields.fbfFormat )
                                .
                            end.
                            if buf_temp_fbr-history-fields.fbfLabel <> "":U
                            then do:
                                assign
                                    buf_temp_fbr-history-line.fblLabel      = buf_temp_fbr-history-fields.fbfLabel
                                .
                            end.
                            assign
                                buf_temp_fbr-history-line.fblVisible    = buf_temp_fbr-history-fields.fbfVisible
                            .
                        end.
                    end.
                end.
            end.
        end.
    end.
end.
END PROCEDURE. /* init-fields */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-open-query Dialog-Frame 
PROCEDURE local-open-query :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
    open query br-table
      for each temp_fbr-history no-lock
    .
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-open-query-line Dialog-Frame 
PROCEDURE local-open-query-line :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
    if available temp_fbr-history
    then do:
        open query br-lines
            for each temp_fbr-history-line no-lock
               where temp_fbr-history-line.fbh-key     = temp_fbr-history.fbh-key
                 and temp_fbr-history-line.fblVisible  = yes
        .
    end.
    else do:
        open query br-lines
            for each temp_fbr-history-line no-lock
               where temp_fbr-history-line.fbh-key = 0
                 and temp_fbr-history-line.fblVisible  = yes
        .
    end.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE manage-fields Dialog-Frame 
PROCEDURE manage-fields :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-fbh-key as integer          no-undo.

do
on error undo, return error
:
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-nik Dialog-Frame 
FUNCTION get-nik RETURNS CHARACTER
  ( input p-userid as character ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
    define variable v-nik    as character    no-undo.
    { gbl/usrnick.i
        p-userid
        v-nik
    }
  RETURN v-nik.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

