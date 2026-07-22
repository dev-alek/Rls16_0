&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
/* Connected Databases
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

Редактирование привязки группы прав к пользователю из списка объектов или фирм

Автор: Белоусов Илья Александрович
Дата создания: 10/18/07
Author: Ilia Belousov
Creation date: 10/18/07

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
DEFINE INPUT PARAMETER p-user-id     AS CHARACTER     NO-UNDO.
DEFINE INPUT PARAMETER p-db-num      AS integer       NO-UNDO.
DEFINE INPUT PARAMETER p-obj-type      AS CHARACTER        NO-UNDO.
DEFINE INPUT PARAMETER p-obj-code      AS integer       NO-UNDO.

DEFINE TEMP-TABLE tt-work-place NO-UNDO
    FIELD wp-code AS INTEGER   column-label "№"             FORMAT ">>>>9"
    FIELD wp-type AS CHARACTER column-label "тип"           FORMAT "x(3)"
    FIELD wp-host AS INTEGER   column-label "фирма"         FORMAT ">>>>9"
    FIELD wp-name AS CHARACTER column-label "наименование"  FORMAT "x(40)"
    FIELD context AS CHARACTER column-label "привязка"
    FIELD db-num  AS INTEGER   column-label "БД"            FORMAT ">>>>9"
INDEX i-code-type IS PRIMARY UNIQUE
      wp-code
      wp-type
INDEX i-host
      wp-host
index i-context
      context
.

define temp-table temp_filter-fields no-undo
    field action-role-code as integer
    field record-on        as logical

    index pi is primary unique
        action-role-code
.
define temp-table temp_filter-fields-item no-undo
    field action-item-code as integer
    field record-on        as logical

    index pi is primary unique
        action-item-code
.

define buffer br_tt-work-place            for tt-work-place.
define buffer br_user-login-action-role   for user-login-action-role.
define buffer buf_user-login-action-role  for user-login-action-role.
define buffer br_action-role             for action-role.
define buffer br_action-role-item        for action-role-item.
define buffer br_action-item             for action-item.
define buffer br_temp_filter-fields-item for temp_filter-fields-item .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Редактирование привязки группы прав к пользователю из списка объектов или фирм".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/getcntxt.i def }
{ cmp/showinf.i  }
{ gbl/usrnickf.i }
{ gbl/color.i    }

/* Local Variable Definitions ---                                       */

define variable v-context  as character no-undo format "x(8)" column-label "Привязка".
define variable v-state    as character no-undo format "x(3)" column-label "Вкл" .
DEFINE VARIABLE g#log      AS LOGICAL   NO-UNDO.
define variable v-flt-role    as character    no-undo.
define variable v-flt-item    as character    no-undo.

define variable v-on-gbl    as logical      no-undo.
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME browse-action-item

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES buf_user-login-action-role ~
br_action-role-item br_temp_filter-fields-item br_action-item ~
br_user-login-action-role br_action-role temp_filter-fields

/* Definitions for BROWSE browse-action-item                            */
&Scoped-define FIELDS-IN-QUERY-browse-action-item /* get-item-state(BUFFER br_action-item) @ v-state */ br_action-item.action-item-name br_action-item.action-item-id /* br_action-item.action-item-description br_action-item.action-group-code buf_user-login-action-role.db-num buf_user-login-action-role.action-head-code buf_user-login-action-role.user-login-role-code buf_user-login-action-role.user-id buf_user-login-action-role.action-role-code br_action-item.action-group-code br_action-item.action-item-id br_action-item.action-group-id */
&Scoped-define ENABLED-FIELDS-IN-QUERY-browse-action-item
&Scoped-define SELF-NAME browse-action-item
&Scoped-define OPEN-QUERY-browse-action-item /* OPEN QUERY {&SELF-NAME} FOR EACH buf_user-login-action-role, ~
       first br_action-role-item, ~
       first br_temp_filter-fields-item, ~
        first br_action-item. */ RUN refresh-action-item .
&Scoped-define TABLES-IN-QUERY-browse-action-item ~
buf_user-login-action-role br_action-role-item br_temp_filter-fields-item ~
br_action-item
&Scoped-define FIRST-TABLE-IN-QUERY-browse-action-item buf_user-login-action-role
&Scoped-define SECOND-TABLE-IN-QUERY-browse-action-item br_action-role-item
&Scoped-define THIRD-TABLE-IN-QUERY-browse-action-item br_temp_filter-fields-item
&Scoped-define FOURTH-TABLE-IN-QUERY-browse-action-item br_action-item


/* Definitions for BROWSE browse-br_user-login-action-role              */
&Scoped-define FIELDS-IN-QUERY-browse-br_user-login-action-role get-role-context(BUFFER br_user-login-action-role) @ v-context br_action-role.action-role-name /* br_action-role.action-role-description br_user-login-action-role.host-code br_action-role.action-role-code br_user-login-action-role.obj-type br_user-login-action-role.obj-code br_user-login-action-role.user-id br_user-login-action-role.obj-type br_user-login-action-role.obj-code br_user-login-action-role.user-login-role-code */
&Scoped-define ENABLED-FIELDS-IN-QUERY-browse-br_user-login-action-role
&Scoped-define SELF-NAME browse-br_user-login-action-role
&Scoped-define OPEN-QUERY-browse-br_user-login-action-role /* OPEN QUERY {&SELF-NAME} FOR EACH br_user-login-action-role, ~
       FIRST br_action-role, ~
       FIRST temp_filter-fields. */ RUN refresh-action-role IN THIS-PROCEDURE .
&Scoped-define TABLES-IN-QUERY-browse-br_user-login-action-role ~
br_user-login-action-role br_action-role temp_filter-fields
&Scoped-define FIRST-TABLE-IN-QUERY-browse-br_user-login-action-role br_user-login-action-role
&Scoped-define SECOND-TABLE-IN-QUERY-browse-br_user-login-action-role br_action-role
&Scoped-define THIRD-TABLE-IN-QUERY-browse-br_user-login-action-role temp_filter-fields


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-browse-action-item}~
    ~{&OPEN-QUERY-browse-br_user-login-action-role}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-add b-del b-help tg-detail b-filter ~
v-filter tb-filter browse-br_user-login-action-role browse-action-item ~
role-EDITOR item-EDITOR
&Scoped-Define DISPLAYED-OBJECTS tg-detail v-filter tb-filter role-EDITOR ~
item-EDITOR

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-item-state Dialog-Frame
FUNCTION get-item-state RETURNS CHARACTER
  ( BUFFER buf_action-item FOR action-item )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-role-context Dialog-Frame
FUNCTION get-role-context RETURNS CHARACTER
  ( BUFFER buf_user-login-action-role FOR user-login-action-role )  FORWARD.

/* _UIB-CODE-BLOCK-END */
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
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-filter
     LABEL "ФПоиск"
     SIZE 10 BY 1.

DEFINE BUTTON b-help
     LABEL "&Помощь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE item-EDITOR AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 47.5 BY 1.58 TOOLTIP "Описание права" NO-UNDO.

DEFINE VARIABLE role-EDITOR AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 49.5 BY 1.5 TOOLTIP "Описание группы" NO-UNDO.

DEFINE VARIABLE v-filter AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 44.5 BY 1 NO-UNDO.

DEFINE VARIABLE tb-filter AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 3 BY .83 NO-UNDO.

DEFINE VARIABLE tg-detail AS LOGICAL INITIAL yes
     LABEL "Детализировать по группам"
     VIEW-AS TOGGLE-BOX
     SIZE 27.5 BY .75 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY browse-action-item FOR
      buf_user-login-action-role,
      br_action-role-item,
      br_temp_filter-fields-item,
      br_action-item SCROLLING.

DEFINE QUERY browse-br_user-login-action-role FOR
      br_user-login-action-role,
      br_action-role,
      temp_filter-fields SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE browse-action-item
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS browse-action-item Dialog-Frame _FREEFORM
  QUERY browse-action-item DISPLAY
      /*       get-item-state(BUFFER br_action-item) @ v-state */
         br_action-item.action-item-name
         br_action-item.action-item-id
/*
         br_action-item.action-item-description
         br_action-item.action-group-code
            buf_user-login-action-role.db-num
            buf_user-login-action-role.action-head-code
            buf_user-login-action-role.user-login-role-code
            buf_user-login-action-role.user-id
            buf_user-login-action-role.action-role-code
         br_action-item.action-group-code
         br_action-item.action-item-id
         br_action-item.action-group-id
         */
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 47.5 BY 15.5.

DEFINE BROWSE browse-br_user-login-action-role
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS browse-br_user-login-action-role Dialog-Frame _FREEFORM
  QUERY browse-br_user-login-action-role DISPLAY
      get-role-context(BUFFER br_user-login-action-role) @ v-context column-label "Привязка"
      br_action-role.action-role-name                                column-label "Название группы прав"

/*      br_action-role.action-role-description                         column-label "Описание группы прав"
      br_user-login-action-role.host-code
br_user-login-action-role.db-num
br_user-login-action-role.user-id
 br_user-login-action-role.user-login-role-code
      br_action-role.action-role-code
      br_user-login-action-role.obj-type
      br_user-login-action-role.obj-code
      br_user-login-action-role.user-id
      br_user-login-action-role.obj-type
      br_user-login-action-role.obj-code
      br_user-login-action-role.user-login-role-code
*/
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 49.5 BY 15.5.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-add AT ROW 1 COL 11 WIDGET-ID 6
     b-del AT ROW 1 COL 21 WIDGET-ID 8
     b-help AT ROW 1 COL 89.5
     tg-detail AT ROW 1.08 COL 31.5 WIDGET-ID 14
     b-filter AT ROW 2 COL 1 WIDGET-ID 16
     v-filter AT ROW 2 COL 9 COLON-ALIGNED NO-LABEL WIDGET-ID 18 NO-TAB-STOP
     tb-filter AT ROW 2 COL 57 WIDGET-ID 20
     browse-br_user-login-action-role AT ROW 3.25 COL 1.5 WIDGET-ID 200
     browse-action-item AT ROW 3.25 COL 51.75 WIDGET-ID 300
     role-EDITOR AT ROW 19 COL 1.5 NO-LABEL WIDGET-ID 22
     item-EDITOR AT ROW 19 COL 52 NO-LABEL WIDGET-ID 24
     SPACE(0.00) SKIP(0.08)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Права пользователя"
         DEFAULT-BUTTON b-exit WIDGET-ID 100.


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
/* BROWSE-TAB browse-br_user-login-action-role tb-filter Dialog-Frame */
/* BROWSE-TAB browse-action-item browse-br_user-login-action-role Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       item-EDITOR:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

ASSIGN
       role-EDITOR:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

ASSIGN
       v-filter:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE browse-action-item
/* Query rebuild information for BROWSE browse-action-item
     _START_FREEFORM
/* OPEN QUERY {&SELF-NAME} FOR EACH buf_user-login-action-role, first br_action-role-item, first br_temp_filter-fields-item,  first br_action-item. */
RUN refresh-action-item .
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE browse-action-item */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE browse-br_user-login-action-role
/* Query rebuild information for BROWSE browse-br_user-login-action-role
     _START_FREEFORM
/* OPEN QUERY {&SELF-NAME} FOR EACH br_user-login-action-role, FIRST br_action-role, FIRST temp_filter-fields. */
RUN refresh-action-role IN THIS-PROCEDURE .
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE browse-br_user-login-action-role */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Права пользователя */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add Dialog-Frame
ON CHOOSE OF b-add IN FRAME Dialog-Frame /* Добавить */
DO:
   IF available br_tt-work-place THEN do:
      RUN add-action-roles in this-procedure no-error.
      IF ERROR-STATUS:ERROR THEN DO:
         MESSAGE RETURN-VALUE SKIP
                  ERROR-STATUS:GET-MESSAGE(1)
         VIEW-AS ALERT-BOX.
         UNDO, RETURN NO-APPLY.
      END.
      run assign-filter-mark in this-procedure (
            input v-flt-role
         , input v-flt-item
      ).
      run refresh-action-role in this-procedure .
      run post_enable_UI IN THIS-PROCEDURE.
   end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del Dialog-Frame
ON CHOOSE OF b-del IN FRAME Dialog-Frame /* Удалить */
DO:
   IF AVAILABLE br_action-role THEN DO:
      MESSAGE SUBSTITUTE( "Отключить группу прав (&1) для пользователя &2?"
                        , br_action-role.action-role-name
                        , usrnickf( p-user-id )
                        )
      VIEW-AS ALERT-BOX
      BUTTONS YES-NO
      UPDATE v-yes AS LOGICAL
      .
      IF v-yes THEN DO:
         RUN delete-user-role.
      END.

      run refresh-action-role in this-procedure .
      run post_enable_UI IN THIS-PROCEDURE.
   END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-filter
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-filter Dialog-Frame
ON CHOOSE OF b-filter IN FRAME Dialog-Frame /* Фильтр */
DO:
   define variable v-ok    as logical      no-undo.
      run adm/actnrolf.w (
          input-output v-flt-role
        , input-output v-flt-item
        , output v-ok
    ) no-error.
   if error-status :error
   then do:
      message
               vss-workfile vss-revision vss-description
         skip(1)
         skip "Ошибка изменения фильтра."
         skip return-value
         skip trim( error-status :get-message( 1 ) )
               trim( error-status :get-message( 2 ) )
               trim( error-status :get-message( 3 ) )
      view-as alert-box error.
      undo, return no-apply.
   end.

   IF NOT v-ok then do:
      RETURN NO-APPLY.
   end.

   IF v-flt-role <> "":U THEN DO:
      IF v-flt-item <> "":U THEN DO:
      assign
         v-filter = SUBSTITUTE("В группе: &1, в правах: &2", v-flt-role, v-flt-item)
      .
      END.
      else do:
      assign
         v-filter = SUBSTITUTE("В группе: &1", v-flt-role)
      .
      end.
   end.
   else do:
      IF v-flt-item <> "":U THEN DO:
      assign
         v-filter = SUBSTITUTE("В правах: &1", v-flt-item)
      .
      END.
      else do:
      assign
         v-filter = "":U
      .
      end.
   end.

   if v-filter = "":U
   then do:
      assign
            tb-filter               = no
            tb-filter :sensitive    = no
      .
      assign
            v-filter :bgcolor   = GREY_COLOR
            b-filter :bgcolor = GREY_COLOR
      .
   end.
   else do:
      assign
            tb-filter = yes
            tb-filter :sensitive    = yes
      .
      assign
            v-filter :bgcolor = RED_COLOR
            b-filter :bgcolor = RED_COLOR
      .
   end.
   display
      v-filter
      tb-filter
   with frame {&frame-name}.

   { gbl/working.i }
   run assign-filter-mark in this-procedure (
         input v-flt-role
      , input v-flt-item
   ).
   RUN enable_UI.
   RUN post_enable_UI IN THIS-PROCEDURE.
   { gbl/stopwork.i }
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




&Scoped-define BROWSE-NAME browse-action-item
&Scoped-define SELF-NAME browse-action-item
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL browse-action-item Dialog-Frame
ON VALUE-CHANGED OF browse-action-item IN FRAME Dialog-Frame
DO:
   if available br_action-item then do:
    assign
        item-editor = br_action-item.action-item-description
    .
    display
      item-editor
    with frame {&frame-name}.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME browse-br_user-login-action-role
&Scoped-define SELF-NAME browse-br_user-login-action-role
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL browse-br_user-login-action-role Dialog-Frame
ON VALUE-CHANGED OF browse-br_user-login-action-role IN FRAME Dialog-Frame
DO:
  run refresh-action-item in this-procedure .
  if available br_action-role then do:
      assign
          role-editor = br_action-role.action-role-description
      .
      display
         role-editor
      with frame {&frame-name}.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tb-filter
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tb-filter Dialog-Frame
ON VALUE-CHANGED OF tb-filter IN FRAME Dialog-Frame
DO:
    assign
        tb-filter
    .
    if tb-filter = yes
    then do:
        assign
            v-filter :bgcolor = RED_COLOR
            b-filter :bgcolor = RED_COLOR
        .
         run assign-filter-mark in this-procedure (
               input v-flt-role
            , input v-flt-item
         ).
    end.
    else do:
        assign
            v-filter :bgcolor = GREY_COLOR
            b-filter :bgcolor = GREY_COLOR
        .
         run assign-filter-mark in this-procedure (
               input "":U
             , input "":U
         ).
    end.
   RUN enable_UI.
   RUN post_enable_UI IN THIS-PROCEDURE.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tg-detail
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tg-detail Dialog-Frame
ON VALUE-CHANGED OF tg-detail IN FRAME Dialog-Frame /* Детализировать по группам */
DO:
  IF LOGICAL(tg-detail:screen-value) then do:
      assign
         browse-br_user-login-action-role:hidden = FALSE
      .
      ENABLE
         browse-br_user-login-action-role
         b-del
      WITH FRAME Dialog-Frame.
  end.
  else do:
      assign
         browse-br_user-login-action-role:hidden = TRUE
      .
      disable
        browse-br_user-login-action-role
        b-del
      WITH FRAME Dialog-Frame.
  end.
   run assign-filter-mark in this-procedure (
         input v-flt-role
      , input v-flt-item
   ).
  RUN refresh-action-role IN THIS-PROCEDURE .
  run post_enable_UI IN THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME browse-action-item
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
{ adm/actn-gbl.i
  v-on-gbl
  no-error
}

  RUN fill-wp IN THIS-PROCEDURE.
  FIND FIRST br_tt-work-place no-lock.

       ASSIGN
        FRAME Dialog-Frame:TITLE = SUBSTITUTE ( "Права пользователя &1 для &2"
                                              , usrnickf( p-user-id )
                                              , IF p-obj-type = {&cmp}
                                                THEN Substitute("фирмы &1", p-obj-code)
                                                ELSE Substitute(" &1 &2", p-obj-type, p-obj-code)
                                              )
     .

    run assign-filter-mark in this-procedure (
          input v-flt-role
        , input v-flt-item
    ).

  RUN enable_UI.
  RUN post_enable_UI IN THIS-PROCEDURE.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE add-action-roles Dialog-Frame
PROCEDURE add-action-roles :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define variable v-action-role-code     as integer   no-undo .
  define variable current-role           as integer   no-undo .
  define variable v-rid-list             as character no-undo .
  define variable v-context              as character no-undo .
  define variable v-obj-code             as integer   no-undo .
  define variable v-obj-type             as character no-undo .
  define variable v-host-code            as integer   no-undo .
  define variable v-user-select          as logical   no-undo .


   do
   on error undo, return error return-value
   :
      ASSIGN
         v-context = br_tt-work-place.context
      .
      run str/actnrole.w ( input parparentproc
                        , input  'b-sel,b-mark':U
                        , input-output v-context
                        , output v-action-role-code
                        , INPUT-OUTPUT v-rid-list
                        , input p-db-num
                        ) .
      IF v-context <> br_tt-work-place.context THEN DO:
         message
            "Выбранное право не соответствует типу объекта"
            skip
         view-as alert-box information.
         RETURN.
      END.
      IF v-rid-list <> "" THEN
      DO current-role = 1 TO NUM-ENTRIES(v-rid-list) :
         case v-context :
            WHEN {&cntxt-firm} THEN DO:
               RUN add-one-action-role ( INPUT ENTRY(current-role, v-rid-list)
                                       , INPUT 0
                                       , INPUT '':U
                                       , INPUT br_tt-work-place.wp-code
                                       ).
            END.
            WHEN {&cntxt-object} THEN DO:
               RUN add-one-action-role ( INPUT ENTRY(current-role, v-rid-list)
                                       , INPUT br_tt-work-place.wp-code
                                       , INPUT br_tt-work-place.wp-type
                                       , INPUT 0
                                       ).
            END.
            OTHERWISE DO:
               RUN add-one-action-role ( INPUT ENTRY(current-role, v-rid-list)
                                       , INPUT 0
                                       , INPUT '':U
                                       , INPUT 0
                                       ).
            END.
         END.
      END.
   end. /* do on error */
END PROCEDURE. /* add-action-roles */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE add-one-action-role Dialog-Frame
PROCEDURE add-one-action-role :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
DEFINE INPUT PARAMETER p-rid AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-obj-code      AS INTEGER   NO-UNDO.
DEFINE INPUT PARAMETER p-obj-type      AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-host-code     AS INTEGER   NO-UNDO.

DEFINE BUFFER buf_action-role            FOR action-role.
DEFINE BUFFER buf_user-login-action-role FOR user-login-action-role.
   do
   on error undo, return error return-value
   :
      FIND FIRST buf_action-role WHERE RECID(buf_action-role) = INTEGER(p-rid)
                                 NO-LOCK.
      IF NOT CAN-FIND( FIRST buf_user-login-action-role
                       WHERE buf_user-login-action-role.db-num           = p-db-num
                         AND buf_user-login-action-role.action-head-code = {&action-head-code-main}
                         AND buf_user-login-action-role.action-role-code = buf_action-role.action-role-code
                         AND buf_user-login-action-role.action-role-context  = buf_action-role.action-role-context
                         AND buf_user-login-action-role.user-id          = p-user-id
                         AND buf_user-login-action-role.host-code            = p-host-code
                         AND buf_user-login-action-role.obj-type             = p-obj-type
                         AND buf_user-login-action-role.obj-code             = p-obj-code
                     )
      THEN DO:
         create buf_user-login-action-role .
         assign
           buf_user-login-action-role.db-num               = p-db-num
           buf_user-login-action-role.action-head-code     = {&action-head-code-main}
           buf_user-login-action-role.user-login-role-code = NEXT-VALUE(s-user-login-action-role)
           buf_user-login-action-role.user-id              = p-user-id
           buf_user-login-action-role.action-role-code     = buf_action-role.action-role-code
           buf_user-login-action-role.action-role-context  = buf_action-role.action-role-context
           buf_user-login-action-role.host-code            = p-host-code
           buf_user-login-action-role.obj-type             = p-obj-type
           buf_user-login-action-role.obj-code             = p-obj-code
           buf_user-login-action-role.gds-grp-code         = ?
           buf_user-login-action-role.gds-code             = ?
           buf_user-login-action-role.cli-grp-code         = ?
         .
      END.
    END.
END PROCEDURE. /* add-one-action-role */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE assign-filter-mark Dialog-Frame
PROCEDURE assign-filter-mark :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-name-filter    as character        no-undo.
define input parameter p-name2-filter   as character        no-undo.

define buffer buf_action-role          for action-role .
define buffer buf_action-role-item     for action-role-item .
define buffer buf_action-item          for action-item .
define buffer buf_temp_filter-fields   for temp_filter-fields .
define buffer buf_user-login-action-role     for user-login-action-role .

do
on error undo, return error
:
   IF available br_tt-work-place THEN DO:
      FOR EACH buf_user-login-action-role WHERE buf_user-login-action-role.db-num           = p-db-num
                                          AND buf_user-login-action-role.action-head-code    = {&action-head-code-main}
                                          AND buf_user-login-action-role.user-id             = p-user-id
                                          AND buf_user-login-action-role.action-role-context = br_tt-work-place.context
                                          AND (
                                             (br_tt-work-place.context = {&cntxt-global})
                                             OR
                                             (br_tt-work-place.context = {&cntxt-firm}
                                                AND
                                                buf_user-login-action-role.host-code = br_tt-work-place.wp-code
                                             )
                                             OR
                                             (br_tt-work-place.context = {&cntxt-object}
                                                AND
                                                buf_user-login-action-role.obj-code = br_tt-work-place.wp-code
                                                AND
                                                buf_user-login-action-role.obj-type = br_tt-work-place.wp-type
                                             )
                                             )
            no-lock,
            FIRST buf_action-role        WHERE buf_action-role.db-num                      = (if v-on-gbl then 0 else p-db-num)
                                          AND buf_action-role.action-head-code            = {&action-head-code-main}
                                          AND buf_action-role.action-role-code            = buf_user-login-action-role.action-role-code
                                          and buf_action-role.action-role-context         = br_tt-work-place.context
                                       NO-LOCK
                                       :
        find first buf_temp_filter-fields
             where buf_temp_filter-fields.action-role-code = buf_action-role.action-role-code
        no-error.
        if not available buf_temp_filter-fields
        then do:
            create buf_temp_filter-fields.
            assign
                buf_temp_filter-fields.action-role-code = buf_action-role.action-role-code
                buf_temp_filter-fields.record-on = no
            .
        end.
        if ( p-name-filter = "":U AND p-name2-filter = "":U)
        or (( p-name-filter <> "":U )
        and index(buf_action-role.action-role-name , p-name-filter ) <> 0 )
        or (( p-name-filter <> "":U )
        and index(buf_action-role.action-role-description , p-name-filter ) <> 0 )
        then do:
            assign
                buf_temp_filter-fields.record-on = yes
            .
        end.
        else do:
            assign
                buf_temp_filter-fields.record-on = no
            .
            search-in-item:
            for each buf_action-role-item
                where buf_action-role-item.db-num           = buf_action-role.db-num
                  and buf_action-role-item.action-head-code = buf_action-role.action-head-code
                  and buf_action-role-item.action-role-code = buf_action-role.action-role-code
/*                  and buf_action-role-item.action-item-code = buf_action-item.action-item-code */
                no-lock,
                first buf_action-item
                where buf_action-item.action-head-code = buf_action-role.action-head-code
                  and buf_action-item.action-item-code = buf_action-role-item.action-item-code

            :
                if ( p-name2-filter = "":U AND p-name-filter = "":U)
                OR index( buf_action-item.action-item-name, p-name2-filter ) <> 0
                or index( buf_action-item.action-item-description, p-name2-filter ) <> 0
                then do:
                    assign
                        buf_temp_filter-fields.record-on = yes
                    .
                    leave search-in-item.
                end.
            end.
        end.
    end.
    end.
end.
END PROCEDURE. /* assign-filter-mark */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE delete-user-role Dialog-Frame
PROCEDURE delete-user-role :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
   define buffer buf_user-login-action-role     for user-login-action-role.

   DO
   TRANSACTION
   ON ERROR UNDO, RETURN
   :
      FIND FIRST buf_user-login-action-role
           WHERE RECID(buf_user-login-action-role) = RECID(br_user-login-action-role)
           EXCLUSIVE-LOCK
           .
      DELETE buf_user-login-action-role.
   END.

END PROCEDURE. /* delete-user-role */

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
  DISPLAY tg-detail v-filter tb-filter role-EDITOR item-EDITOR
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-add b-del b-help tg-detail b-filter v-filter tb-filter
         browse-br_user-login-action-role browse-action-item role-EDITOR
         item-EDITOR
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-wp Dialog-Frame
PROCEDURE fill-wp :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE BUFFER buf_user-obj  FOR user-obj.
DEFINE BUFFER buf_user-host FOR user-host.
DEFINE BUFFER buf_clients   FOR clients.

do
on error undo, return error
:

   IF p-obj-type = {&cmp} THEN DO:
      FOR FIRST buf_user-host
          WHERE buf_user-host.db-num  = p-db-num
            AND buf_user-host.USER-ID = p-user-id
            AND buf_user-host.host-code = p-obj-code
         NO-LOCK
         :
         FIND FIRST buf_clients
               WHERE buf_clients.obj-code = buf_user-host.host-code
               AND buf_clients.obj-type = {&cmp}
               NO-LOCK
            .
         CREATE br_tt-work-place.
         ASSIGN
            br_tt-work-place.wp-code = buf_clients.obj-code
            br_tt-work-place.wp-type = buf_clients.obj-type
            br_tt-work-place.wp-host = buf_clients.obj-code
            br_tt-work-place.db-num  = buf_clients.db-num
            br_tt-work-place.context = {&cntxt-firm}
            br_tt-work-place.wp-name = buf_clients.obj-name
         .
      END.
   end.
   else do:
      FOR FIRST buf_user-obj
         WHERE buf_user-obj.db-num = p-db-num
         AND buf_user-obj.USER-ID  = p-user-id
         AND buf_user-obj.obj-type = p-obj-type
         AND buf_user-obj.obj-code = p-obj-code
         NO-LOCK
         :
         FIND FIRST buf_clients
            WHERE buf_clients.obj-code = buf_user-obj.obj-code
               AND buf_clients.obj-type = buf_user-obj.obj-type
            NO-LOCK
            .
         IF  buf_clients.db-num <> p-db-num
         and p-db-num <> 0
         then do:
            next.
         end.

         CREATE br_tt-work-place.
         ASSIGN
            br_tt-work-place.wp-code = buf_clients.obj-code
            br_tt-work-place.wp-type = buf_clients.obj-type
            br_tt-work-place.wp-host = buf_clients.host-code
            br_tt-work-place.db-num  = buf_clients.db-num
            br_tt-work-place.context = {&cntxt-object}
            br_tt-work-place.wp-name = buf_clients.obj-name
         .
      END.
   END.
end. /* do on error */
END PROCEDURE. /* fill-wp */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE filter-for-item Dialog-Frame
PROCEDURE filter-for-item :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-name-filter    as character        no-undo.

define buffer buf_action-role-item        for action-role-item .
define buffer buf_temp_filter-fields-item for temp_filter-fields-item .
define buffer buf_action-item             for action-item .
define buffer buf_user-login-action-role  for user-login-action-role .

do
on error undo, return error
:

   IF AVAILABLE br_user-login-action-role then do:
      IF LOGICAL(tg-detail:screen-value in FRAME Dialog-Frame) then do:
         FOR EACH buf_action-role-item
               WHERE buf_action-role-item.db-num = p-db-num
                  AND buf_action-role-item.action-head-code   = {&action-head-code-main}
                  AND buf_action-role-item.action-role-code   = br_user-login-action-role.action-role-code
               NO-LOCK,
               first buf_action-item
               where buf_action-item.action-head-code     = {&action-head-code-main}
                  AND buf_action-item.action-item-code    = buf_action-role-item.action-item-code
               no-lock
         :
            find first buf_temp_filter-fields-item
                  where buf_temp_filter-fields-item.action-item-code = buf_action-item.action-item-code
            no-error.
            if not available buf_temp_filter-fields-item
            then do:
                  create buf_temp_filter-fields-item.
                  assign
                     buf_temp_filter-fields-item.action-item-code = buf_action-item.action-item-code
                     buf_temp_filter-fields-item.record-on = no
                  .
            end.
            if ( p-name-filter = "":U )
            or index( buf_action-item.action-item-name, p-name-filter ) <> 0
            or index( buf_action-item.action-item-description, p-name-filter ) <> 0
            then do:
               assign
                  buf_temp_filter-fields-item.record-on = yes
               .
            end.
            else do:
               assign
                  buf_temp_filter-fields-item.record-on = no
               .
            end.
         end.
      end.
      else do:
         FOR EACH  buf_user-login-action-role
             WHERE buf_user-login-action-role.db-num             = p-db-num
              AND  buf_user-login-action-role.action-head-code   = {&action-head-code-main}
              AND  buf_user-login-action-role.user-id            = p-user-id
             no-lock
             ,
             EACH buf_action-role-item
               WHERE buf_action-role-item.db-num = p-db-num
                  AND buf_action-role-item.action-head-code   = {&action-head-code-main}
                  AND buf_action-role-item.action-role-code   = buf_user-login-action-role.action-role-code
               NO-LOCK,
               first buf_action-item
               where buf_action-item.action-head-code    = {&action-head-code-main}
                  AND buf_action-item.action-item-code    = buf_action-role-item.action-item-code
               no-lock
         :
            find first buf_temp_filter-fields-item
                  where buf_temp_filter-fields-item.action-item-code = buf_action-item.action-item-code
            no-error.
            if not available buf_temp_filter-fields-item
            then do:
                  create buf_temp_filter-fields-item.
                  assign
                     buf_temp_filter-fields-item.action-item-code = buf_action-item.action-item-code
                     buf_temp_filter-fields-item.record-on = no
                  .
            end.
            if ( p-name-filter = "":U )
            or index( buf_action-item.action-item-name, p-name-filter ) <> 0
            or index( buf_action-item.action-item-description, p-name-filter ) <> 0
            then do:
               assign
                  buf_temp_filter-fields-item.record-on = yes
               .
            end.
            else do:
               assign
                  buf_temp_filter-fields-item.record-on = no
               .
            end.
         end.
      end.
   end. /* AVAILABLE action-role */
end.  /* do on error */
END PROCEDURE. /* filter-for-item */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE post_enable_UI Dialog-Frame
PROCEDURE post_enable_UI :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
   define buffer buf_tt-work-place     for tt-work-place.

   define variable v-ok    as logical      no-undo.
do
on error undo, return error
:
   IF p-db-num <> v-cntxt-db-num and v-cntxt-db-num <> 0 THEN DO:
      DISABLE
            b-add
            b-del
      WITH FRAME Dialog-Frame.
   END.
   ELSE DO:
      IF AVAILABLE br_action-role THEN DO:
          ENABLE
                b-add
                b-del
          WITH FRAME Dialog-Frame.
      END.
      ELSE DO:
          ENABLE
                b-add
          WITH FRAME Dialog-Frame.
          DISABLE
                b-del
          WITH FRAME Dialog-Frame.
      END.
   END.

    { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      "'actn_users-update':U"
      {&cntxt-global}
      0
      '':U
      0
      0
      0
      0
      FALSE
      v-ok
    }
    if v-ok = FALSE
    then do:
        disable
            b-add
            b-del
        WITH FRAME Dialog-Frame.
    end.

end.
END PROCEDURE.   /* post_enable_UI */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE procedure-get-item-state Dialog-Frame
PROCEDURE procedure-get-item-state :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define input  parameter p-action-item-code       as integer   no-undo .
  define output parameter p-state as character no-undo .

  define buffer buf_action-role-item for ub.action-role-item .

  do
  on error undo, return error return-value
  :
    if available br_user-login-action-role
    then do:
      find first buf_action-role-item no-lock
        where buf_action-role-item.db-num              = br_user-login-action-role.db-num
          and buf_action-role-item.action-head-code    = br_user-login-action-role.action-head-code
          and buf_action-role-item.action-role-code    = br_user-login-action-role.action-role-code
          and buf_action-role-item.action-item-code    = p-action-item-code
        no-error .

      if available buf_action-role-item
      then do:
        assign
          p-state = '*':U
        .
      end.
      else do:
        assign
          p-state = '':U
        .
      end.
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE procedure-get-role-context Dialog-Frame
PROCEDURE procedure-get-role-context :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define input  parameter p-action-context as character no-undo .
  define output parameter p-action-name    as character no-undo .

  do
  on error undo, return error return-value
  :
    case p-action-context
    :
      when {&cntxt-global}
      then do:
        assign
          p-action-name = "Без привязки"
        .
      end.
      when {&cntxt-firm}
      then do:
        assign
          p-action-name = "Фирма"
        .
      end.
      when {&cntxt-object}
      then do:
        assign
          p-action-name = "Объект"
        .
      end.
      otherwise do:
        message
          vss-workfile vss-revision vss-description skip
          "Незвестное значение контекста" skip
          "p-action-context" p-action-context skip
          view-as alert-box error .
      end.

    end case .
  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE query-action-item Dialog-Frame
PROCEDURE query-action-item :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  do
  on error undo, return error return-value
  :
    if available br_user-login-action-role
    then do:
      if tb-filter = yes then do:
         run filter-for-item IN THIS-PROCEDURE
                        ( input v-flt-item
                        ) .
      end.
      else do:
         run filter-for-item IN THIS-PROCEDURE
                        ( input ""
                        ) .
      end.
      IF LOGICAL(tg-detail:screen-value in FRAME Dialog-Frame) then do:
         open query browse-action-item
            FOR EACH buf_user-login-action-role
                WHERE RECID(buf_user-login-action-role) = RECID(br_user-login-action-role)
                  NO-LOCK
                  ,
                  EACH  br_action-role-item
                  WHERE br_action-role-item.db-num = p-db-num
                     AND br_action-role-item.action-head-code   = {&action-head-code-main}
                     AND br_action-role-item.action-role-code   = buf_user-login-action-role.action-role-code
                  NO-LOCK,
                  FIRST br_temp_filter-fields-item
                  WHERE br_temp_filter-fields-item.action-item-code = br_action-role-item.action-item-code
                    and br_temp_filter-fields-item.record-on = YES
                  NO-LOCK
                  ,
                  first br_action-item
                  where br_action-item.action-head-code    = {&action-head-code-main}
                     AND br_action-item.action-item-code    = br_action-role-item.action-item-code
                     AND br_action-item.action-item-context = br_tt-work-place.context
                  no-lock
                  indexed-reposition .
      end.
      else do:
         open query browse-action-item
            FOR EACH buf_user-login-action-role
                  WHERE buf_user-login-action-role.db-num             = p-db-num
                  AND buf_user-login-action-role.action-head-code     = {&action-head-code-main}
                  AND buf_user-login-action-role.user-id              = p-user-id
                  AND (
                           (
                           buf_user-login-action-role.action-role-context  = br_tt-work-place.context
                           AND
                           buf_user-login-action-role.action-role-context = {&cntxt-global}
                           AND
                           buf_user-login-action-role.host-code = 0
                           AND
                           buf_user-login-action-role.obj-code  = 0
                           AND
                           buf_user-login-action-role.obj-type  = "":U
                           )
                        OR
                           (
                           buf_user-login-action-role.action-role-context  = br_tt-work-place.context
                           AND
                           buf_user-login-action-role.action-role-context = {&cntxt-firm}
                           AND
                           buf_user-login-action-role.host-code = br_tt-work-place.wp-code
                           AND
                           buf_user-login-action-role.obj-code  = 0
                           AND
                           buf_user-login-action-role.obj-type  = "":U
                           )
                        OR
                           (
                           buf_user-login-action-role.action-role-context  = br_tt-work-place.context
                           AND
                           buf_user-login-action-role.action-role-context = {&cntxt-object}
                           AND
                           buf_user-login-action-role.obj-code = br_tt-work-place.wp-code
                           AND
                           buf_user-login-action-role.obj-type = br_tt-work-place.wp-type
                           )
                        )
                  no-lock
                  ,
                  EACH  br_action-role-item
                  WHERE br_action-role-item.db-num = p-db-num
                     AND br_action-role-item.action-head-code   = {&action-head-code-main}
                     AND br_action-role-item.action-role-code   = buf_user-login-action-role.action-role-code
                  NO-LOCK
                  ,
                  FIRST br_temp_filter-fields-item
                  WHERE br_temp_filter-fields-item.action-item-code = br_action-role-item.action-item-code
                    and br_temp_filter-fields-item.record-on = YES
                  NO-LOCK
                  ,
                  first br_action-item
                  where br_action-item.action-head-code    = {&action-head-code-main}
                     AND br_action-item.action-item-code    = br_action-role-item.action-item-code
                     AND br_action-item.action-item-context = br_tt-work-place.context
                  no-lock
                  indexed-reposition .

      end.
    end.
    else do:
      /* задаем такое условие - чтобы на экране не было записей */
      open query browse-action-item
           FOR EACH buf_user-login-action-role
               WHERE buf_user-login-action-role.db-num           = p-db-num
                 AND buf_user-login-action-role.action-head-code = {&action-head-code-main}
                 AND buf_user-login-action-role.user-id          = p-user-id
                 AND buf_user-login-action-role.action-role-context = "":U
               NO-LOCK
               ,
               FIRST br_action-role-item
               WHERE br_action-role-item.db-num = p-db-num
                 AND br_action-role-item.action-head-code            = {&action-head-code-main}
                 AND br_action-role-item.action-role-code            = buf_user-login-action-role.action-role-code
               NO-LOCK
               ,
               FIRST br_temp_filter-fields-item
               WHERE br_temp_filter-fields-item.action-item-code = br_action-role-item.action-item-code
                 and br_temp_filter-fields-item.record-on = YES
               NO-LOCK
               ,
               first br_action-item
               where br_action-item.action-head-code    = {&action-head-code-main}
                 AND br_action-item.action-item-code    = br_action-role-item.action-item-code
               no-lock
        indexed-reposition .
    end.
  if available br_action-item then do:
    assign
        item-editor = br_action-item.action-item-description
    .
    display
      item-editor
    with frame {&frame-name}.
  end.
  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE query-action-role Dialog-Frame
PROCEDURE query-action-role :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

  DO
  ON ERROR UNDO, RETURN ERROR RETURN-VALUE
  :
    IF available br_tt-work-place THEN DO:
      OPEN QUERY browse-br_user-login-action-role
            FOR EACH br_user-login-action-role WHERE br_user-login-action-role.db-num           = p-db-num
                                              AND br_user-login-action-role.action-head-code    = {&action-head-code-main}
                                              AND br_user-login-action-role.user-id             = p-user-id
                                              AND br_user-login-action-role.action-role-context = br_tt-work-place.context
                                              AND (
                                                   (br_tt-work-place.context = {&cntxt-global})
                                                  OR
                                                   (br_tt-work-place.context = {&cntxt-firm}
                                                    AND
                                                    br_user-login-action-role.host-code = br_tt-work-place.wp-code
                                                   )
                                                  OR
                                                   (br_tt-work-place.context = {&cntxt-object}
                                                    AND
                                                    br_user-login-action-role.obj-code = br_tt-work-place.wp-code
                                                    AND
                                                    br_user-login-action-role.obj-type = br_tt-work-place.wp-type
                                                   )
                                                  )
                no-lock,
                FIRST br_action-role        WHERE br_action-role.db-num                      = (if v-on-gbl then 0 else p-db-num)
                                              AND br_action-role.action-head-code            = {&action-head-code-main}
                                              AND br_action-role.action-role-code            = br_user-login-action-role.action-role-code
                                              and br_action-role.action-role-context         = br_tt-work-place.context
                                            NO-LOCK,
                first temp_filter-fields
                where temp_filter-fields.action-role-code = br_action-role.action-role-code
                  AND temp_filter-fields.record-on = YES
                no-lock
      INDEXED-REPOSITION .
    END.
    if available br_action-role then do:
      assign
          role-editor = br_action-role.action-role-description
      .
      display
         role-editor
      with frame {&frame-name}.
    end.
  END.

END PROCEDURE. /* query-action-role */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE refresh-action-item Dialog-Frame
PROCEDURE refresh-action-item :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  do
  on error undo, return error return-value
  :
    run query-action-item in this-procedure .
  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE refresh-action-role Dialog-Frame
PROCEDURE refresh-action-role :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

  do
  on error undo, return error return-value
  :
    run query-action-role in this-procedure .
    run refresh-action-item in this-procedure .
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-item-state Dialog-Frame
FUNCTION get-item-state RETURNS CHARACTER
  ( BUFFER buf_action-item FOR action-item ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
  define variable v-return-value as character no-undo .

  run procedure-get-item-state in this-procedure
    (input  buf_action-item.action-item-code
    ,output v-return-value
    ) .
  return v-return-value .
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-role-context Dialog-Frame
FUNCTION get-role-context RETURNS CHARACTER
  ( BUFFER buf_user-login-action-role FOR user-login-action-role ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/

  define variable v-return-value as character no-undo .

  run procedure-get-role-context in this-procedure
    (input  buf_user-login-action-role.action-role-context
    ,output v-return-value
    ) .

  return v-return-value .

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME