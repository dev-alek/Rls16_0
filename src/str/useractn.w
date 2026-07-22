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

Редактирование привязки группы прав к пользователю

Автор: Белоусов Илья Александрович
Дата создания:
Author: Ilia Belousov
Creation date:

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
DEFINE INPUT PARAMETER p-user-id     AS CHARACTER     NO-UNDO.
DEFINE INPUT PARAMETER p-db-num      AS integer       NO-UNDO.

DEFINE TEMP-TABLE tt-work-place NO-UNDO
    FIELD wp-code AS INTEGER   column-label "Код"           FORMAT ">>>>>>>>>9"
    FIELD wp-type AS CHARACTER column-label "Тип"           FORMAT "x(3)"
    FIELD wp-host AS INTEGER   column-label "фирма"         FORMAT ">>>>>>>>>9"
    FIELD wp-name AS CHARACTER column-label "наименование"  FORMAT "x(40)"
    FIELD context AS CHARACTER column-label "привязка"
    FIELD db-num  AS INTEGER   column-label "БД"            FORMAT ">>>>>>>>>9"
    field marked  as logical
    field deleted  as logical
INDEX i-code-type IS PRIMARY UNIQUE
      wp-code
      wp-type
INDEX i-host
      wp-host
index i-context
      context
.
DEFINE TEMP-TABLE tt-user-login-action-role NO-UNDO like ub.user-login-action-role
    FIELD role-name AS CHARACTER column-label "название"  FORMAT "x(40)"
    FIELD description AS CHARACTER column-label "описание"  FORMAT "x(40)"
    field deleted  as logical
    field marked  as logical
index i-name
      role-name
.
define temp-table  tt-gds-grp no-undo
    field node-code as integer column-label "Вн.код группы" format ">>>>>>>>9"
    field full-name as character COLUMN-LABEL "Название группы" format "X(255)"
index i-code
      node-code
.


define buffer br_tt-gds-grp                  for tt-gds-grp.
define buffer br_tt-work-place               for tt-work-place.
define buffer br_tt-user-login-action-role   for tt-user-login-action-role.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Редактирование привязки группы прав к пользователю".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ ref/grplibfn.i }
{ cmp/library.i  }
{ gbl/getcntxt.i def }
{ cmp/showinf.i  }
{ gbl/usrnickf.i }
{ gbl/color.i    }
{ gbl/userhsts.i }
{ gbl/userobjs.i }
{ gbl/twowin.i   }
{ gbl/onewin.i   }

/* Local Variable Definitions ---                                       */

define variable v-context  as character no-undo format "x(8)" column-label "Привязка".
define variable v-state    as character no-undo format "x(3)" column-label "Вкл" .
DEFINE VARIABLE g#log      AS LOGICAL   NO-UNDO.
define variable v-on-grp    as logical      no-undo.
define variable v-on-gbl    as logical      no-undo.

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
&Scoped-define INTERNAL-TABLES br_tt-work-place ~
br_tt-user-login-action-role

/* Definitions for BROWSE BROWSE-2                                      */
&Scoped-define FIELDS-IN-QUERY-BROWSE-2 br_tt-work-place.wp-type br_tt-work-place.wp-code br_tt-work-place.wp-name
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-2
&Scoped-define SELF-NAME BROWSE-2
&Scoped-define QUERY-STRING-BROWSE-2 FOR EACH br_tt-work-place where br_tt-work-place.marked = true
&Scoped-define OPEN-QUERY-BROWSE-2 OPEN QUERY {&SELF-NAME} FOR EACH br_tt-work-place where br_tt-work-place.marked = true .
&Scoped-define TABLES-IN-QUERY-BROWSE-2 br_tt-work-place
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-2 br_tt-work-place


/* Definitions for BROWSE BROWSE-3                                      */
&Scoped-define FIELDS-IN-QUERY-BROWSE-3 br_tt-gds-grp.node-code br_tt-gds-grp.full-name
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-3
&Scoped-define SELF-NAME BROWSE-3
&Scoped-define QUERY-STRING-BROWSE-3 FOR EACH br_tt-gds-grp
&Scoped-define OPEN-QUERY-BROWSE-3 OPEN QUERY {&SELF-NAME} FOR EACH br_tt-gds-grp .
&Scoped-define TABLES-IN-QUERY-BROWSE-3 br_tt-gds-grp
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-3 br_tt-gds-grp


/* Definitions for BROWSE browse-br_user-login-action-role              */
&Scoped-define FIELDS-IN-QUERY-browse-br_user-login-action-role get-role-context(BUFFER br_tt-user-login-action-role) @ v-context br_tt-user-login-action-role.role-name
&Scoped-define ENABLED-FIELDS-IN-QUERY-browse-br_user-login-action-role
&Scoped-define SELF-NAME browse-br_user-login-action-role
&Scoped-define OPEN-QUERY-browse-br_user-login-action-role /* OPEN QUERY {&SELF-NAME} FOR EACH br_tt-user-login-action-role. */ RUN refresh-action-role IN THIS-PROCEDURE .
&Scoped-define TABLES-IN-QUERY-browse-br_user-login-action-role ~
br_tt-user-login-action-role
&Scoped-define FIRST-TABLE-IN-QUERY-browse-br_user-login-action-role br_tt-user-login-action-role


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BROWSE-2}~
    ~{&OPEN-QUERY-BROWSE-3}~
    ~{&OPEN-QUERY-browse-br_user-login-action-role}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-all b-help b-add b-lkp b-del ~
RADIO-SET-1 b-wp browse-br_user-login-action-role BROWSE-3 BROWSE-2 ~
role-editor object-EDITOR
&Scoped-Define DISPLAYED-OBJECTS RADIO-SET-1 role-editor object-EDITOR

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-full-name Dialog-Frame
FUNCTION get-full-name RETURNS CHARACTER
  ( INPUT p-node-code AS INTEGER )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-role-context Dialog-Frame
FUNCTION get-role-context RETURNS CHARACTER
  ( BUFFER buf_tt-user-login-action-role FOR tt-user-login-action-role )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-add
     LABEL "Добавить"
     SIZE 10 BY 1.

DEFINE BUTTON b-all
     LABEL "Все права"
     SIZE 11 BY 1 TOOLTIP "Просмотр всех прав пользователя".

DEFINE BUTTON b-del
     LABEL "Удалить"
     SIZE 10 BY 1.

DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-help
     LABEL "&Помощь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-lkp
     LABEL "&Просмотр"
     SIZE 10 BY 1 TOOLTIP "Просмотр прав, входящих в текущую группу".

DEFINE BUTTON b-wp
     LABEL "Изменить"
     SIZE 10 BY 1.

DEFINE VARIABLE object-EDITOR AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 50.5 BY 1.75 TOOLTIP "описание, того где выдано право" NO-UNDO.

DEFINE VARIABLE role-editor AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 47.5 BY 1.79 TOOLTIP "описание группы прав" NO-UNDO.

DEFINE VARIABLE RADIO-SET-1 AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Объекты(Фирмы)", "obj-firm",
"Группы товаров", "gds-grp"
     SIZE 36.5 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BROWSE-2 FOR
      br_tt-work-place SCROLLING.

DEFINE QUERY BROWSE-3 FOR
      br_tt-gds-grp SCROLLING.

DEFINE QUERY browse-br_user-login-action-role FOR
      br_tt-user-login-action-role SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BROWSE-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-2 Dialog-Frame _FREEFORM
  QUERY BROWSE-2 DISPLAY
      br_tt-work-place.wp-type
      br_tt-work-place.wp-code
      br_tt-work-place.wp-name
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 50.5 BY 16.75
         TITLE "Объекты(Фирмы)" ROW-HEIGHT-CHARS .67 FIT-LAST-COLUMN TOOLTIP "Объекты и фирмы, где включена группа прав".

DEFINE BROWSE BROWSE-3
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-3 Dialog-Frame _FREEFORM
  QUERY BROWSE-3 DISPLAY
      br_tt-gds-grp.node-code
      br_tt-gds-grp.full-name
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 50.5 BY 16.75
         TITLE "Группы товаров" ROW-HEIGHT-CHARS .67 TOOLTIP "Группы товаров, для которых включена группа прав".

DEFINE BROWSE browse-br_user-login-action-role
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS browse-br_user-login-action-role Dialog-Frame _FREEFORM
  QUERY browse-br_user-login-action-role DISPLAY
      get-role-context(BUFFER br_tt-user-login-action-role) @ v-context column-label "Привязка" FORMAT "x(12)"
      br_tt-user-login-action-role.role-name                                column-label "Название группы прав"
       br_tt-user-login-action-role.db-num  column-label "БД"    
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 47.5 BY 16.75
         TITLE "Группы прав" ROW-HEIGHT-CHARS .67.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-all AT ROW 1 COL 11 WIDGET-ID 44
     b-help AT ROW 1 COL 89.5
     b-add AT ROW 2 COL 1 WIDGET-ID 6
     b-lkp AT ROW 2 COL 11 WIDGET-ID 38
     b-del AT ROW 2 COL 21 WIDGET-ID 8
     RADIO-SET-1 AT ROW 2 COL 49.5 NO-LABEL WIDGET-ID 46
     b-wp AT ROW 2 COL 89.5 WIDGET-ID 30
     browse-br_user-login-action-role AT ROW 3.25 COL 1 WIDGET-ID 200
     BROWSE-3 AT ROW 3.25 COL 49 WIDGET-ID 500
     BROWSE-2 AT ROW 3.25 COL 49 WIDGET-ID 400
     role-editor AT ROW 20.25 COL 1 NO-LABEL WIDGET-ID 40
     object-EDITOR AT ROW 20.25 COL 49 NO-LABEL WIDGET-ID 42
     SPACE(0.00) SKIP(0.28)
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
/* BROWSE-TAB browse-br_user-login-action-role b-wp Dialog-Frame */
/* BROWSE-TAB BROWSE-3 browse-br_user-login-action-role Dialog-Frame */
/* BROWSE-TAB BROWSE-2 BROWSE-3 Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       object-EDITOR:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

ASSIGN
       role-editor:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-2
/* Query rebuild information for BROWSE BROWSE-2
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH br_tt-work-place where br_tt-work-place.marked = true .
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE BROWSE-2 */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-3
/* Query rebuild information for BROWSE BROWSE-3
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH br_tt-work-place where br_tt-work-place.marked = true .
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE BROWSE-3 */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE browse-br_user-login-action-role
/* Query rebuild information for BROWSE browse-br_user-login-action-role
     _START_FREEFORM
/* OPEN QUERY {&SELF-NAME} FOR EACH br_tt-user-login-action-role. */
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
   RUN add-action-roles in this-procedure no-error.
   IF ERROR-STATUS:ERROR THEN DO:
      MESSAGE RETURN-VALUE SKIP
               ERROR-STATUS:GET-MESSAGE(1)
      VIEW-AS ALERT-BOX.
      UNDO, RETURN NO-APPLY.
   END.
   run refresh-action-role in this-procedure .
   run post_enable_UI IN THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-all
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-all Dialog-Frame
ON CHOOSE OF b-all IN FRAME Dialog-Frame /* Все права */
DO:
   if available br_tt-user-login-action-role then do:
      run view-all-item in this-procedure .
   end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del Dialog-Frame
ON CHOOSE OF b-del IN FRAME Dialog-Frame /* Удалить */
DO:
   IF NOT AVAILABLE br_tt-user-login-action-role then do:
      return no-apply.
   end.
      MESSAGE SUBSTITUTE( "Отключить группу прав (&1) для пользователя &2?"
                        , br_tt-user-login-action-role.role-name
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

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-lkp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-lkp Dialog-Frame
ON CHOOSE OF b-lkp IN FRAME Dialog-Frame /* Просмотр */
DO:
   if available br_tt-user-login-action-role then do:
      run view-item in this-procedure
                     ( INPUT br_tt-user-login-action-role.action-head-code
                     , INPUT br_tt-user-login-action-role.action-role-code
                     , INPUT br_tt-user-login-action-role.role-name
                     ) .
   end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-wp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-wp Dialog-Frame
ON CHOOSE OF b-wp IN FRAME Dialog-Frame /* Изменить */
DO:
   if available br_tt-user-login-action-role then do:
     if radio-set-1:visible =  true then do :
       case radio-set-1 :
         when "obj-firm" then do :
           RUN change-object in this-procedure .
           run mark-object in this-procedure .
           {&OPEN-QUERY-BROWSE-2}
         end.
         when "gds-grp" then do :
           run change-gds-grp in this-procedure.
           run fill-gds-grp in this-procedure .
           {&OPEN-QUERY-BROWSE-3}
         end.
       end case.
     end.
     else do :
       RUN change-object in this-procedure .
       run mark-object in this-procedure .
       {&OPEN-QUERY-BROWSE-2}
     end.
   end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME browse-br_user-login-action-role
&Scoped-define SELF-NAME browse-br_user-login-action-role
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL browse-br_user-login-action-role Dialog-Frame
ON VALUE-CHANGED OF browse-br_user-login-action-role IN FRAME Dialog-Frame /* Группы прав */
DO:
  run mark-object in this-procedure .
  {&OPEN-QUERY-BROWSE-2}
  run fill-gds-grp in this-procedure .
  {&OPEN-QUERY-BROWSE-3}
  RUN post_enable_UI IN THIS-PROCEDURE .
  if available br_tt-user-login-action-role then do:
     assign
         role-editor = br_tt-user-login-action-role.description
     .
     display
         role-editor
     with frame {&frame-name}.
   end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME RADIO-SET-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RADIO-SET-1 Dialog-Frame
ON VALUE-CHANGED OF RADIO-SET-1 IN FRAME Dialog-Frame
DO:
  assign
    RADIO-SET-1
  .
  case RADIO-SET-1 :
    when "obj-firm" then do :
      browse-3:visible = false.
      browse-2:visible = true.
    end.
    when "gds-grp" then do :
      browse-2:visible = false.
      browse-3:visible = true.
    end.
  end case.
  run post_enable_UI in this-procedure.
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
       ASSIGN
        FRAME Dialog-Frame:TITLE = SUBSTITUTE ( "Права пользователя &1", usrnickf( p-user-id ) )
     .
    { adm/actn-grp.i
      v-on-grp
      no-error
    }
    { adm/actn-gbl.i
  v-on-gbl
  no-error
}

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
  define variable v-not-first-obj        as logical   no-undo .
  define variable v-not-first-firm       as logical   no-undo .
  define variable v-rec-list             as character no-undo .
  define variable ii                     as integer   no-undo .
  define variable v-gds-grp              as logical   no-undo .

  define buffer buf_clients      for ub.clients .
  define buffer buf_gds-grp      for ub.gds-grp.
  define buffer buf_action-role     for ub.action-role .
  define buffer buf_action-role-item for ub.action-role-item.
  define buffer buf_action-item for ub.action-item.
  define buffer buf_action-item-attr for ub.action-item-attr.


   do
   on error undo, return error return-value
   :
      ASSIGN
         v-context = "All"
      .
      run str/actnrole.w ( input parparentproc
                        , input  'b-sel,b-mark':U
                        , input-output v-context
                        , output v-action-role-code
                        , INPUT-OUTPUT v-rid-list
                        , input p-db-num
                        ) .
                 
      IF v-rid-list <> "" THEN
      DO current-role = 1 TO NUM-ENTRIES(v-rid-list) :
         find first buf_action-role
              where RECID(buf_action-role) = INTEGER(ENTRY(current-role, v-rid-list))
              no-lock
              .
         v-rec-list = "" .
         v-gds-grp = false .
         if v-on-grp then for each buf_action-role-item no-lock
           where buf_action-role-item.action-head-code = buf_action-role.action-head-code
             and buf_action-role-item.action-role-code = buf_action-role.action-role-code
             :
             find first buf_action-item no-lock
                 where buf_action-item.action-item-code = buf_action-role-item.action-item-code
                   and buf_action-item.action-head-code = buf_action-role-item.action-head-code no-error.
             if available buf_action-item then do :
                 if can-find (first buf_action-item-attr no-lock
                              where buf_action-item-attr.attr-code = "Linking"
                                and buf_action-item-attr.action-item-code = buf_action-item.action-item-code)
                 then do :
                     assign
                       v-gds-grp = true
                     .
                     leave.
                 end.
             end.
         end.

         case buf_action-role.action-role-context :
            WHEN {&cntxt-object} THEN DO:
               IF v-not-first-obj = FALSE THEN DO:
                  { gbl/uobjsman.i
                    parparentproc
                    p-db-num
                    p-user-id
                    v-cntxt-host-code-obj
                    v-cntxt-obj-type
                    v-cntxt-obj-code
                    v-not-first-obj
                    NO-ERROR
                  }
                  IF v-not-first-obj = FALSE THEN DO:
                     return.
                  end.
               end.
               if v-gds-grp = true then do :
                  run ref/gds-grp.w (
                      input parparentproc
                    , input "b-sel,b-mark,b-actn-mark"
                    , input 0
                    , input "":U
                    , input-output v-rec-list).
               end.
               
               for each  userobjs_temp-user-obj
                  :
                  FIND FIRST buf_clients
                        WHERE buf_clients.obj-code = userobjs_temp-user-obj.obj-code
                        AND buf_clients.obj-type   = userobjs_temp-user-obj.obj-type
                     NO-LOCK
                     .
                  IF  buf_clients.db-num <> p-db-num
                  and p-db-num <> 0
                  then do:
                     next.
                  end.
                  if v-rec-list <> "" then do :
                    do ii = 1 to num-entries(v-rec-list) :
                      find buf_gds-grp where recid (buf_gds-grp) = integer(entry(ii,v-rec-list)).
                      if available buf_gds-grp then do :
                        RUN add-one-action-role ( INPUT ENTRY(current-role, v-rid-list)
                                                , INPUT userobjs_temp-user-obj.obj-code
                                                , INPUT userobjs_temp-user-obj.obj-type
                                                , INPUT 0
                                                , input ?
                                                ).
                        RUN add-one-action-role ( INPUT ENTRY(current-role, v-rid-list)
                                                , INPUT userobjs_temp-user-obj.obj-code
                                                , INPUT userobjs_temp-user-obj.obj-type
                                                , INPUT 0
                                                , input buf_gds-grp.node-code
                                                ).
                      end.
                    end.
                  end.
                  else do :
                    RUN add-one-action-role ( INPUT ENTRY(current-role, v-rid-list)
                                            , INPUT userobjs_temp-user-obj.obj-code
                                            , INPUT userobjs_temp-user-obj.obj-type
                                            , INPUT 0
                                            , input ?
                                            ).
                  end.
               end.
            END.
            WHEN {&cntxt-firm} THEN DO:
               IF v-not-first-firm = FALSE THEN DO:
                  { gbl/uhstsman.i
                    parparentproc
                    p-db-num
                    p-user-id
                    v-cntxt-host-code-obj
                    v-not-first-firm
                    NO-ERROR
                  }
                  IF v-not-first-firm = FALSE THEN DO:
                     return.
                  end.
               end.
               if v-gds-grp = true then do :
                  run ref/gds-grp.w (
                      input parparentproc
                    , input "b-sel,b-mark,b-actn-mark"
                    , input 0
                    , input "":U
                    , input-output v-rec-list).
               end.
               for each userhsts_temp-user-host
                  :
                  if v-rec-list <> "" then do :
                    do ii = 1 to num-entries(v-rec-list) :
                      find buf_gds-grp where recid (buf_gds-grp) = integer(entry(ii,v-rec-list)).
                      if available buf_gds-grp then do :
                        RUN add-one-action-role ( INPUT ENTRY(current-role, v-rid-list)
                                                , INPUT 0
                                                , INPUT '':U
                                                , INPUT userhsts_temp-user-host.host-code
                                                , input ?
                                                ).
                        RUN add-one-action-role ( INPUT ENTRY(current-role, v-rid-list)
                                                , INPUT 0
                                                , INPUT '':U
                                                , INPUT userhsts_temp-user-host.host-code
                                                , input buf_gds-grp.node-code
                                                ).
                      end.
                    end.
                  end.
                  else do :
                    RUN add-one-action-role ( INPUT ENTRY(current-role, v-rid-list)
                                            , INPUT 0
                                            , INPUT '':U
                                            , INPUT userhsts_temp-user-host.host-code
                                            , input ?
                                            ).
                  end.
               end.
            END.
            OTHERWISE DO:
               if v-gds-grp = true then do :
                 run ref/gds-grp.w (
                     input parparentproc
                   , input "b-sel,b-mark,b-actn-mark"
                   , input 0
                   , input "":U
                   , input-output v-rec-list).
              end.
              if v-rec-list <> "" then do :
                do ii = 1 to num-entries(v-rec-list) :
                  find buf_gds-grp where recid (buf_gds-grp) = integer(entry(ii,v-rec-list)).
                  if available buf_gds-grp then do :
                    RUN add-one-action-role ( INPUT ENTRY(current-role, v-rid-list)
                                                , INPUT 0
                                                , INPUT '':U
                                                , INPUT 0
                                                , input ?
                                                ).
                    RUN add-one-action-role ( INPUT ENTRY(current-role, v-rid-list)
                                            , INPUT 0
                                            , INPUT '':U
                                            , INPUT 0
                                            , input buf_gds-grp.node-code
                                            ).
                  end.
                end.
              end.
              else do :
                RUN add-one-action-role ( INPUT ENTRY(current-role, v-rid-list)
                                            , INPUT 0
                                            , INPUT '':U
                                            , INPUT 0
                                            , input ?
                                            ).
              end.
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
DEFINE INPUT PARAMETER p-node-code     AS INTEGER   NO-UNDO.

DEFINE BUFFER buf_action-role            FOR ub.action-role.
DEFINE BUFFER buf_user-login-action-role FOR ub.user-login-action-role.
   do
   on error undo, return error return-value
   :
      FIND FIRST buf_action-role WHERE RECID(buf_action-role) = INTEGER(p-rid)
                                 NO-LOCK.
      IF NOT CAN-FIND( FIRST buf_user-login-action-role
                       WHERE buf_user-login-action-role.db-num           = p-db-num
                         AND buf_user-login-action-role.action-head-code = buf_action-role.action-head-code
                         AND buf_user-login-action-role.action-role-code = buf_action-role.action-role-code
                         AND buf_user-login-action-role.action-role-context  = buf_action-role.action-role-context
                         AND buf_user-login-action-role.user-id          = p-user-id
                         AND buf_user-login-action-role.host-code            = p-host-code
                         AND buf_user-login-action-role.obj-type             = p-obj-type
                         AND buf_user-login-action-role.obj-code             = p-obj-code
                         and buf_user-login-action-role.gds-grp-code         = p-node-code
                     )
      THEN DO:
         create buf_user-login-action-role .
         assign
           buf_user-login-action-role.db-num               = p-db-num
           buf_user-login-action-role.action-head-code     = buf_action-role.action-head-code
           buf_user-login-action-role.user-login-role-code = NEXT-VALUE(s-user-login-action-role)
           buf_user-login-action-role.user-id              = p-user-id
           buf_user-login-action-role.action-role-code     = buf_action-role.action-role-code
           buf_user-login-action-role.action-role-context  = buf_action-role.action-role-context
           buf_user-login-action-role.host-code            = p-host-code
           buf_user-login-action-role.obj-type             = p-obj-type
           buf_user-login-action-role.obj-code             = p-obj-code
           buf_user-login-action-role.gds-grp-code         = p-node-code
           buf_user-login-action-role.gds-code             = ?
           buf_user-login-action-role.cli-grp-code         = ?
         .
      END.
    END.
END PROCEDURE. /* add-one-action-role */


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE change-object Dialog-Frame
PROCEDURE change-object :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define buffer buf_user-login-action-role     for ub.user-login-action-role .
define buffer buf_action-role     for ub.action-role .

define variable v-changed    as logical      no-undo.
define variable v-accepted    as logical      no-undo.
define variable v-space-pos    as integer      no-undo.
define variable v-code    as integer      no-undo.
define variable v-type    as character    no-undo.

do
on error undo, return error
:

   run twowin_clear in this-procedure.

   FOR EACH tt-work-place
      WHERE tt-work-place.context = br_tt-user-login-action-role.action-role-context
      :
      case tt-work-place.context :
      WHEN {&cntxt-object} THEN DO:
         IF  tt-work-place.db-num <> p-db-num
         and p-db-num <> 0
         then do:
               next.
         end.
         FIND FIRST buf_user-login-action-role
            where  buf_user-login-action-role.db-num              = br_tt-user-login-action-role.db-num
               and buf_user-login-action-role.user-id             = br_tt-user-login-action-role.user-id
               and buf_user-login-action-role.action-head-code    = br_tt-user-login-action-role.action-head-code
               and buf_user-login-action-role.action-role-context = tt-work-place.context
               and buf_user-login-action-role.obj-type            = tt-work-place.wp-type
               and buf_user-login-action-role.obj-code            = tt-work-place.wp-code
               and buf_user-login-action-role.action-role-code    = br_tt-user-login-action-role.action-role-code
            no-lock
            no-error
            .
      end.
      WHEN {&cntxt-firm} THEN DO:
         FIND FIRST buf_user-login-action-role
            where buf_user-login-action-role.db-num               = br_tt-user-login-action-role.db-num
               and buf_user-login-action-role.user-id             = br_tt-user-login-action-role.user-id
               and buf_user-login-action-role.action-head-code    = br_tt-user-login-action-role.action-head-code
               and buf_user-login-action-role.action-role-context = tt-work-place.context
               and buf_user-login-action-role.host-code           = tt-work-place.wp-code
               and buf_user-login-action-role.action-role-code    = br_tt-user-login-action-role.action-role-code
            no-lock
            no-error
            .
      end.
      OTHERWISE DO:
         RETURN.
      END.
      end case.

      run twowin_add-item in this-procedure
         ( input SUBSTITUTE ( "&1 &2"
                              , tt-work-place.wp-type
                              , tt-work-place.wp-code
                              )

         , input SUBSTITUTE ( "&1&2 &3"
                              , tt-work-place.wp-type
                              , tt-work-place.wp-code
                              , tt-work-place.wp-name
                              )
         , input ""
         , input ( available buf_user-login-action-role )
         ) .
   END.
   run gbl/twowin.w
      ( input parparentproc
      , input 1
      , input SUBSTITUTE( "Добавление права &1 на объектах", br_tt-user-login-action-role.role-name )
      , input "":U
      , input "&Тест"
      , input table temp_twowin_items
      , output table temp_twowin_itemsSelected
      , output v-changed
      , output v-accepted
      ) .
   IF NOT v-accepted
   THEN DO:
      RETURN.
   END.

   IF v-changed then do:
      find first buf_action-role
           where buf_action-role.db-num = (if v-on-gbl then 0 else br_tt-user-login-action-role.db-num)
             and buf_action-role.action-head-code = br_tt-user-login-action-role.action-head-code
             and buf_action-role.action-role-code = br_tt-user-login-action-role.action-role-code
             no-lock
             .

      /* проверяем удаление прав */
      for each  buf_user-login-action-role
          where buf_user-login-action-role.db-num           = br_tt-user-login-action-role.db-num
            and buf_user-login-action-role.user-id          = br_tt-user-login-action-role.user-id
            and buf_user-login-action-role.action-head-code = br_tt-user-login-action-role.action-head-code
            and buf_user-login-action-role.action-role-code = br_tt-user-login-action-role.action-role-code
         exclusive-lock
         on error undo, return error
         :
         case buf_user-login-action-role.action-role-context :
         WHEN {&cntxt-object} THEN DO:
            find first temp_twowin_itemsSelected
              where temp_twowin_itemsSelected.itmExtKey = SUBSTITUTE ( "&1 &2"
                              , buf_user-login-action-role.obj-type
                              , buf_user-login-action-role.obj-code
                              )
                     no-error.
         end.
         WHEN {&cntxt-firm} THEN DO:
            find first temp_twowin_itemsSelected
              where temp_twowin_itemsSelected.itmExtKey = SUBSTITUTE ( "&1 &2"
                              , {&cmp}
                              , buf_user-login-action-role.host-code
                              )
                     no-error.
         end.
         OTHERWISE DO:
         end.
         end case.

         if not available temp_twowin_itemsSelected
         then do:
            delete buf_user-login-action-role.
         end.
      end.

      /* проверяем установку прав */
      for each temp_twowin_itemsSelected
      :
         assign
            v-space-pos = INDEX( temp_twowin_itemsSelected.itmExtKey
                               , " "
                               )
            v-code = integer( SUBSTRING( temp_twowin_itemsSelected.itmExtKey
                                       , v-space-pos
                                       ) )
            v-type =  SUBSTRING( temp_twowin_itemsSelected.itmExtKey
                               , 1
                               , v-space-pos
                               )
         no-error.
         if error-status :error
         then do:
            message
                  vss-workfile vss-revision vss-description
               skip(1)
               skip "Ошибка передачи первичного ключа из двухоконного интерфейса."
               skip return-value
               skip trim( error-status :get-message( 1 ) )
                  trim( error-status :get-message( 2 ) )
                  trim( error-status :get-message( 3 ) )
            view-as alert-box error.
            undo, return error.
         end.
         case v-type:
         when {&cmp} then do:
            FIND FIRST buf_user-login-action-role
               where buf_user-login-action-role.db-num               = br_tt-user-login-action-role.db-num
                  and buf_user-login-action-role.user-id             = br_tt-user-login-action-role.user-id
                  and buf_user-login-action-role.action-head-code    = br_tt-user-login-action-role.action-head-code
                  and buf_user-login-action-role.action-role-context = {&cntxt-firm}
                  and buf_user-login-action-role.host-code           = v-code
                  and buf_user-login-action-role.action-role-code    = br_tt-user-login-action-role.action-role-code
               no-lock
               no-error
               .
            if not available buf_user-login-action-role
            then do:
               RUN add-one-action-role ( INPUT STRING(RECID(buf_action-role))
                                       , INPUT 0
                                       , INPUT '':U
                                       , INPUT v-code
                                       , INPUT ?
                                       ).
            end.
         end.
         otherwise do:
            FIND FIRST buf_user-login-action-role
               where  buf_user-login-action-role.db-num              = br_tt-user-login-action-role.db-num
                  and buf_user-login-action-role.user-id             = br_tt-user-login-action-role.user-id
                  and buf_user-login-action-role.action-head-code    = br_tt-user-login-action-role.action-head-code
                  and buf_user-login-action-role.action-role-context = {&cntxt-object}
                  and buf_user-login-action-role.obj-type            = v-type
                  and buf_user-login-action-role.obj-code            = v-code
                  and buf_user-login-action-role.action-role-code    = br_tt-user-login-action-role.action-role-code
               no-lock
               no-error
               .
            if not available buf_user-login-action-role
            then do:
               RUN add-one-action-role ( INPUT STRING(RECID(buf_action-role))
                                       , INPUT v-code
                                       , INPUT v-type
                                       , INPUT 0
                                       , INPUT ?
                                       ).
            end.
         end.
         end case.
      end.  /* each temp_twowin_itemsSelected */
   end. /* v-changed */


end.  /* do on error */
END PROCEDURE. /* change-object */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE change-gds-grp Dialog-Frame
PROCEDURE change-gds-grp :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define buffer buf_user-login-action-role for ub.user-login-action-role .
define buffer buf2_user-login-action-role for ub.user-login-action-role .
define buffer buf_gds-grp for ub.gds-grp .

define variable old-rec-list as character no-undo .
define variable rec-list as character no-undo.
define variable ii       as integer   no-undo.


do
on error undo, return error
:
  assign
    rec-list = ""
  .
  if available br_tt-user-login-action-role then do :
    for each buf_user-login-action-role
      where buf_user-login-action-role.db-num           = p-db-num
        and buf_user-login-action-role.action-head-code = br_tt-user-login-action-role.action-head-code
        and buf_user-login-action-role.user-id          = p-user-id
        and buf_user-login-action-role.action-role-code = br_tt-user-login-action-role.action-role-code
        and buf_user-login-action-role.gds-grp-code <> 0
        and buf_user-login-action-role.gds-grp-code <> ?
        no-lock
        :
        find first buf_gds-grp no-lock
             where buf_gds-grp.node-code = buf_user-login-action-role.gds-grp-code no-error.
        if available buf_gds-grp then do :
        assign
          rec-list = rec-list + ( if rec-list = "" then "" else "," ) + string( recid( buf_gds-grp ) )
        .
        end.
    end. /*for each buf_user-login-action-role*/
    run ref/gds-grp.w (
                      input parparentproc
                    , input "b-sel,b-mark,b-actn-mark"
                    , input 0
                    , input "":U
                    , input-output rec-list).
    if ( NOT error-status:error) then do :
      case br_tt-user-login-action-role.action-role-context :
        when {&cntxt-object} then do :
          for each buf_user-login-action-role
            where buf_user-login-action-role.db-num              = p-db-num
              and buf_user-login-action-role.action-head-code    = br_tt-user-login-action-role.action-head-code
              and buf_user-login-action-role.user-id             = p-user-id
              and buf_user-login-action-role.action-role-code    = br_tt-user-login-action-role.action-role-code
              and buf_user-login-action-role.action-role-context = br_tt-user-login-action-role.action-role-context
              and buf_user-login-action-role.obj-code            <> 0
              and buf_user-login-action-role.obj-type            <> ""
              and buf_user-login-action-role.gds-grp-code <> 0
              and buf_user-login-action-role.gds-grp-code <> ?
              exclusive-lock
              :
              delete buf_user-login-action-role .
          end.
        end.
        when {&cntxt-firm} then do :
          for each buf_user-login-action-role
            where buf_user-login-action-role.db-num              = p-db-num
              and buf_user-login-action-role.action-head-code    = br_tt-user-login-action-role.action-head-code
              and buf_user-login-action-role.user-id             = p-user-id
              and buf_user-login-action-role.action-role-code    = br_tt-user-login-action-role.action-role-code
              and buf_user-login-action-role.action-role-context = br_tt-user-login-action-role.action-role-context
              and buf_user-login-action-role.host-code           <> 0
              and buf_user-login-action-role.gds-grp-code <> 0
              and buf_user-login-action-role.gds-grp-code <> ?
              exclusive-lock
              :
              delete buf_user-login-action-role .
          end.
        end.
        otherwise do :
          for each buf_user-login-action-role
            where buf_user-login-action-role.db-num              = p-db-num
              and buf_user-login-action-role.action-head-code    = br_tt-user-login-action-role.action-head-code
              and buf_user-login-action-role.user-id             = p-user-id
              and buf_user-login-action-role.action-role-code    = br_tt-user-login-action-role.action-role-code
              and buf_user-login-action-role.action-role-context = br_tt-user-login-action-role.action-role-context
              and buf_user-login-action-role.host-code           = 0
              and buf_user-login-action-role.obj-code            = 0
              and buf_user-login-action-role.gds-grp-code <> 0
              and buf_user-login-action-role.gds-grp-code <> ?
              exclusive-lock
              :
              delete buf_user-login-action-role .
          end.
        end.
      end case.
    end.

    if ( NOT error-status:error )
    AND ( rec-list <> "" ) then do :
      do ii = 1 to num-entries(rec-list) :
        find buf_gds-grp where recid (buf_gds-grp) = integer(entry(ii,rec-list)).
        if available buf_gds-grp then do :
          case br_tt-user-login-action-role.action-role-context :
            when {&cntxt-object} then do :
              for each buf_user-login-action-role
                where buf_user-login-action-role.db-num           = p-db-num
                  and buf_user-login-action-role.action-head-code = br_tt-user-login-action-role.action-head-code
                  and buf_user-login-action-role.user-id          = p-user-id
                  and buf_user-login-action-role.action-role-code = br_tt-user-login-action-role.action-role-code
                  and buf_user-login-action-role.obj-code <> 0
                  and buf_user-login-action-role.obj-type <> ""
                  no-lock
                  :
                  if not can-find
                     ( first buf2_user-login-action-role no-lock
                       where buf2_user-login-action-role.db-num           = buf_user-login-action-role.db-num
                         and buf2_user-login-action-role.action-head-code = buf_user-login-action-role.action-head-code
                         and buf2_user-login-action-role.user-id          = p-user-id
                         and buf2_user-login-action-role.action-role-code = buf_user-login-action-role.action-role-code
                         and buf2_user-login-action-role.obj-code <> 0
                         and buf2_user-login-action-role.obj-type <> ""
                         and buf2_user-login-action-role.gds-grp-code = buf_gds-grp.node-code )
                  then do :
                    create buf2_user-login-action-role.
                    buffer-copy buf_user-login-action-role except buf_user-login-action-role.user-login-role-code to buf2_user-login-action-role no-error.
                    assign
                      buf2_user-login-action-role.gds-grp-code = buf_gds-grp.node-code
                      buf2_user-login-action-role.user-login-role-code = NEXT-VALUE(s-user-login-action-role)
                    .
                  end. /*if not can-find*/
              end. /*for each buf_user-login-action-role*/
            end.
            when {&cntxt-firm} then do :
              for each buf_user-login-action-role
                where buf_user-login-action-role.db-num           = p-db-num
                  and buf_user-login-action-role.action-head-code = br_tt-user-login-action-role.action-head-code
                  and buf_user-login-action-role.user-id          = p-user-id
                  and buf_user-login-action-role.action-role-code = br_tt-user-login-action-role.action-role-code
                  and buf_user-login-action-role.host-code <> 0
                  no-lock
                  :
                  if not can-find
                     ( first buf2_user-login-action-role no-lock
                       where buf2_user-login-action-role.db-num           = buf_user-login-action-role.db-num
                         and buf2_user-login-action-role.action-head-code = buf_user-login-action-role.action-head-code
                         and buf2_user-login-action-role.user-id          = p-user-id
                         and buf2_user-login-action-role.action-role-code = buf_user-login-action-role.action-role-code
                         and buf2_user-login-action-role.host-code <> 0
                         and buf2_user-login-action-role.gds-grp-code = buf_gds-grp.node-code )
                  then do :
                    create buf2_user-login-action-role.
                    buffer-copy buf_user-login-action-role except buf_user-login-action-role.user-login-role-code to buf2_user-login-action-role no-error.
                    assign
                      buf2_user-login-action-role.gds-grp-code = buf_gds-grp.node-code
                      buf2_user-login-action-role.user-login-role-code = NEXT-VALUE(s-user-login-action-role)
                    .
                  end. /*if not can-find*/
              end. /*for each buf_user-login-action-role*/
            end.
            otherwise do :
              for each buf_user-login-action-role
                where buf_user-login-action-role.db-num           = p-db-num
                  and buf_user-login-action-role.action-head-code = br_tt-user-login-action-role.action-head-code
                  and buf_user-login-action-role.user-id          = p-user-id
                  and buf_user-login-action-role.action-role-code = br_tt-user-login-action-role.action-role-code
                  and buf_user-login-action-role.host-code        = 0
                  and buf_user-login-action-role.obj-code         = 0
                  no-lock
                  :
                  if not can-find
                     ( first buf2_user-login-action-role no-lock
                       where buf2_user-login-action-role.db-num           = buf_user-login-action-role.db-num
                         and buf2_user-login-action-role.action-head-code = buf_user-login-action-role.action-head-code
                         and buf2_user-login-action-role.user-id          = p-user-id
                         and buf2_user-login-action-role.action-role-code = buf_user-login-action-role.action-role-code
                         and buf2_user-login-action-role.host-code        = 0
                         and buf2_user-login-action-role.obj-code         = 0
                         and buf2_user-login-action-role.gds-grp-code = buf_gds-grp.node-code )
                  then do :
                    create buf2_user-login-action-role.
                    buffer-copy buf_user-login-action-role except buf_user-login-action-role.user-login-role-code to buf2_user-login-action-role no-error.
                    assign
                      buf2_user-login-action-role.gds-grp-code = buf_gds-grp.node-code
                      buf2_user-login-action-role.user-login-role-code = NEXT-VALUE(s-user-login-action-role)
                    .
                  end. /*if not can-find*/
              end. /*for each buf_user-login-action-role*/
            end.
          end case.
        end.
      end.
    end.
  end.
end.  /* do on error */
END PROCEDURE. /* change-gds-grp */

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
      FOR EACH buf_user-login-action-role
         where buf_user-login-action-role.db-num           = p-db-num
           AND buf_user-login-action-role.user-id          = p-user-id
           and buf_user-login-action-role.action-head-code = br_tt-user-login-action-role.action-head-code
           and buf_user-login-action-role.action-role-code = br_tt-user-login-action-role.action-role-code
         exclusive-lock
         :
         DELETE buf_user-login-action-role.
      end.
      DELETE br_tt-user-login-action-role.
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
  DISPLAY  radio-set-1 role-editor object-EDITOR
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-all b-help b-add b-lkp b-del RADIO-SET-1 b-wp
         browse-br_user-login-action-role BROWSE-3 BROWSE-2 role-editor
         object-EDITOR
      WITH FRAME Dialog-Frame.

find first ub.global-state no-lock .
if can-find ( first ub.global-state-attr no-lock
     where ub.global-state-attr.gls-id = ub.global-state.gls-id
       and ub.global-state-attr.attr-code = "action-gds-groups"
       and logical(ub.global-state-attr.attr-value ) = true    )
then do :
  radio-set-1:visible = true.
  browse-3:visible = true.
end.
else do :
  radio-set-1:visible = false.
  browse-3:visible = false.
end.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-action-role Dialog-Frame
PROCEDURE fill-action-role :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define buffer buf_action-role                for ub.action-role .
define buffer buf_user-login-action-role     for ub.user-login-action-role .
define buffer buf_tt-user-login-action-role  for tt-user-login-action-role .
define buffer buf_action-role-item           for ub.action-role-item .
define buffer buf_action-item                for ub.action-item .

do
on error undo, return error
:

   empty temp-table buf_tt-user-login-action-role.

   FOR EACH buf_user-login-action-role
      WHERE buf_user-login-action-role.db-num           = p-db-num
        AND buf_user-login-action-role.action-head-code = {&action-head-code-main}
        AND buf_user-login-action-role.user-id          = p-user-id
      no-lock
      :
      IF CAN-FIND( FIRST buf_tt-user-login-action-role
                   WHERE buf_tt-user-login-action-role.db-num = p-db-num
                     AND buf_tt-user-login-action-role.action-head-code = {&action-head-code-main}
                     AND buf_tt-user-login-action-role.user-id          = p-user-id
                     AND buf_tt-user-login-action-role.action-role-code = buf_user-login-action-role.action-role-code
                 )
      then do:
         next.
      end.

      FIND
      FIRST buf_action-role
      WHERE buf_action-role.db-num                      = (if v-on-gbl then 0 else p-db-num)
        AND buf_action-role.action-head-code            = {&action-head-code-main}
        AND buf_action-role.action-role-code            = buf_user-login-action-role.action-role-code
      NO-LOCK
      NO-ERROR
      .
      IF NOT AVAILABLE buf_action-role
      THEN DO:
         NEXT.
      END.
      create buf_tt-user-login-action-role.
      buffer-copy buf_user-login-action-role to buf_tt-user-login-action-role.
      assign
         buf_tt-user-login-action-role.role-name   = buf_action-role.action-role-name
         buf_tt-user-login-action-role.description = buf_action-role.action-role-description
         buf_tt-user-login-action-role.marked      = TRUE
      .

   end.
end.  /* do on error */
END PROCEDURE. /* fill-action-role */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-gds-grp Dialog-Frame
PROCEDURE fill-gds-grp :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE BUFFER buf_user-login-action-role  FOR ub.user-login-action-role.
DEFINE BUFFER buf_tt-gds-grp FOR tt-gds-grp.

do
on error undo, return error
:
  for each buf_tt-gds-grp exclusive-lock :
    delete buf_tt-gds-grp .
  end.
  if available br_tt-user-login-action-role then do :
    for each buf_user-login-action-role
      where buf_user-login-action-role.db-num           = p-db-num
        and buf_user-login-action-role.action-head-code = {&action-head-code-main}
        and buf_user-login-action-role.user-id          = p-user-id
        and buf_user-login-action-role.action-role-code = br_tt-user-login-action-role.action-role-code
        and buf_user-login-action-role.gds-grp-code <> 0
        and buf_user-login-action-role.gds-grp-code <> ?
        no-lock
        :
        if not can-find ( first buf_tt-gds-grp no-lock
              where buf_tt-gds-grp.node-code = buf_user-login-action-role.gds-grp-code ) then do :
          create buf_tt-gds-grp .
          assign
            buf_tt-gds-grp.node-code = buf_user-login-action-role.gds-grp-code.
            buf_tt-gds-grp.full-name = get-full-name(buf_user-login-action-role.gds-grp-code)
          .
        end.
    end.
  end.
end. /* do on error */
END PROCEDURE. /* fill-gds-grp */

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

   empty temp-table br_tt-work-place.

   FOR EACH buf_user-obj
      WHERE buf_user-obj.db-num  = p-db-num
        AND buf_user-obj.USER-ID = p-user-id
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

   FOR EACH  buf_user-host
      WHERE buf_user-host.db-num  = p-db-num
         AND buf_user-host.USER-ID = p-user-id
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

    CREATE br_tt-work-place.
    ASSIGN
       br_tt-work-place.wp-code = 0
       br_tt-work-place.wp-type = '---':U
       br_tt-work-place.wp-name = 'По всей системе':U
       br_tt-work-place.context = {&cntxt-global}
       br_tt-work-place.db-num  = 0
    .

end. /* do on error */
END PROCEDURE. /* fill-wp */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE mark-object Dialog-Frame
PROCEDURE mark-object :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define buffer buf_tt-work-place     for tt-work-place .
define buffer buf_user-login-action-role     for user-login-action-role .

do
on error undo, return error
:
   FOR EACH buf_tt-work-place:
       assign
         buf_tt-work-place.marked = FALSE
       .
   end.
   IF available br_tt-user-login-action-role then do:
      FOR EACH buf_user-login-action-role
         WHERE buf_user-login-action-role.db-num           = p-db-num
         AND buf_user-login-action-role.action-head-code = {&action-head-code-main}
         AND buf_user-login-action-role.user-id          = p-user-id
         AND buf_user-login-action-role.action-role-code = br_tt-user-login-action-role.action-role-code
         no-lock
         :
         case buf_user-login-action-role.action-role-context :
         WHEN {&cntxt-object} then do:
            find first buf_tt-work-place
               where buf_tt-work-place.wp-code = buf_user-login-action-role.obj-code
                 and buf_tt-work-place.wp-type = buf_user-login-action-role.obj-type
            .
               assign
                  buf_tt-work-place.marked = TRUE
               .
         end.
         when {&cntxt-firm} then do:
            find first buf_tt-work-place
               where buf_tt-work-place.wp-code = buf_user-login-action-role.host-code
                 and buf_tt-work-place.wp-type = {&cmp}
            .
            assign
               buf_tt-work-place.marked = TRUE
            .
         end.
         otherwise do:
            find first buf_tt-work-place
               where buf_tt-work-place.wp-code = 0
                 and buf_tt-work-place.wp-type = '---':U
            .
            assign
               buf_tt-work-place.marked = TRUE
            .
         end.
         end case.
      end.
   end.
end.  /* do on error */
END PROCEDURE. /* mark-object */

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
   define buffer buf_action-role-item  for action-role-item.
   define buffer buf_action-item       for action-item.
   define buffer buf_action-item-attr  for action-item-attr.

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
        IF AVAILABLE br_tt-user-login-action-role THEN DO:
          if radio-set-1:visible = true and radio-set-1 = "gds-grp" then do :
            for each buf_action-role-item
              where buf_action-role-item.action-head-code = br_tt-user-login-action-role.action-head-code
                and buf_action-role-item.action-role-code = br_tt-user-login-action-role.action-role-code
                no-lock,
                each buf_action-item no-lock
                    where buf_action-item.action-item-code = buf_action-role-item.action-item-code
                      and buf_action-item.action-head-code = buf_action-role-item.action-head-code
                :
                    find first buf_action-item-attr no-lock
                                where buf_action-item-attr.attr-code = "Linking"
                                  and buf_action-item-attr.action-item-code = buf_action-item.action-item-code no-error.
                    if available buf_action-item-attr then do :
                      ENABLE
                        b-wp
                      WITH FRAME Dialog-Frame.
                      leave.
                    end.
                    else do :
                      DISABLE
                        b-wp
                      WITH FRAME Dialog-Frame.
                    end.
            end.
          end.
          else do :
            ENABLE
                  b-add
                  b-del
            WITH FRAME Dialog-Frame.
            IF br_tt-user-login-action-role.action-role-context = {&cntxt-global} THEN DO:
              DISABLE
                b-wp
              WITH FRAME Dialog-Frame.
            end.
            else do:
              ENABLE
                b-wp
              WITH FRAME Dialog-Frame.
            end.
          end.
        END.
        ELSE DO:
            ENABLE
                  b-add
            WITH FRAME Dialog-Frame.
            DISABLE
                  b-del
                  b-wp
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
            b-wp
        WITH FRAME Dialog-Frame.
    end.

end.
END PROCEDURE.   /* post_enable_UI */

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
      run fill-action-role in this-procedure .
      OPEN QUERY browse-br_user-login-action-role
            FOR EACH br_tt-user-login-action-role
               where br_tt-user-login-action-role.deleted = FALSE
                 AND br_tt-user-login-action-role.marked  = TRUE
               NO-LOCK
               by br_tt-user-login-action-role.action-role-context
       INDEXED-REPOSITION .

        if available br_tt-user-login-action-role then do:
           assign
               role-editor = br_tt-user-login-action-role.description
           .
           display
               role-editor
           with frame {&frame-name}.
        end.
  END.

END PROCEDURE. /* query-action-role */

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
    run fill-wp in this-procedure.
    run mark-object in this-procedure .
    {&OPEN-QUERY-BROWSE-2}
    run fill-gds-grp in this-procedure .
    {&OPEN-QUERY-BROWSE-3}
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE view-all-item Dialog-Frame
PROCEDURE view-all-item :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define buffer buf_action-role-item     for action-role-item .
define buffer buf_action-item    for action-item .
define buffer buf_tt-user-login-action-role    for tt-user-login-action-role .
define buffer buf_temp_onewin_items    for temp_onewin_items .

define variable v-ok    as logical      no-undo.
define variable v-code    as character    no-undo.
do
on error undo, return error
:
   run onewin_clear in this-procedure.

   FOR EACH buf_tt-user-login-action-role
       where buf_tt-user-login-action-role.db-num  = p-db-num
         and buf_tt-user-login-action-role.user-id = p-user-id
       no-lock
       ,
       EACH buf_action-role-item
         where buf_action-role-item.db-num = (if v-on-gbl then 0 else p-db-num)
         and buf_action-role-item.action-head-code = buf_tt-user-login-action-role.action-head-code
         and buf_action-role-item.action-role-code = buf_tt-user-login-action-role.action-role-code
         no-lock
         ,
         first buf_action-item
         where buf_action-item.action-head-code = buf_action-role-item.action-head-code
           and buf_action-item.action-item-code = buf_action-role-item.action-item-code
         no-lock
         :
        IF NOT CAN-FIND( first buf_temp_onewin_items
                         where buf_temp_onewin_items.itm-key = buf_action-item.action-item-code NO-LOCK)
        THEN DO:
            run onewin_add-item in this-procedure
                  ( input buf_action-item.action-item-code
                  , input buf_action-item.action-item-name
                  , input buf_action-item.action-item-description
                  , input FALSE
                  ) .
        END.
   end.
   run gbl/onewin.w
      ( input parParentProc
      , input 0
      , input SUBSTITUTE ( "Детализация прав пользователя &1", usrnickf( p-user-id ) )
      , input "":U
      , input "":U
      , input table temp_onewin_items
      , output table temp_onewin_itemsSelected
      , output v-code
      , output v-ok
   ).

end.  /* do on error */
END PROCEDURE. /* view-all-item */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE view-item Dialog-Frame
PROCEDURE view-item :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-action-head-code as integer          no-undo.
define input parameter p-action-role-code as integer          no-undo.
define input parameter p-action-role-name as character        no-undo.

define buffer buf_action-role-item     for action-role-item .
define buffer buf_action-item    for action-item .
define variable v-ok    as logical      no-undo.
define variable v-code    as character    no-undo.

do
on error undo, return error
:
   run onewin_clear in this-procedure.

   FOR EACH  buf_action-role-item
         where buf_action-role-item.db-num = ( if v-on-gbl then 0 else p-db-num)
         and buf_action-role-item.action-head-code = p-action-head-code
         and buf_action-role-item.action-role-code = p-action-role-code
         no-lock,
         first buf_action-item
         where buf_action-item.action-head-code = buf_action-role-item.action-head-code
           and buf_action-item.action-item-code = buf_action-role-item.action-item-code
         no-lock
         :
        run onewin_add-item in this-procedure
            ( input buf_action-item.action-item-code
            , input buf_action-item.action-item-name
            , input buf_action-item.action-item-description
            , input FALSE
            ) .
   end.
   run gbl/onewin.w
      ( input parParentProc
      , input 0
      , input SUBSTITUTE( "Права входящие в группу &1", p-action-role-name )
      , input "":U
      , input "":U
      , input table temp_onewin_items
      , output table temp_onewin_itemsSelected
      , output v-code
      , output v-ok
   ).

end.  /* do on error */
END PROCEDURE. /* view-item */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-full-name Dialog-Frame
FUNCTION get-full-name RETURNS CHARACTER
  ( INPUT p-node-code AS INTEGER ) :
DEFINE VARIABLE v-full-grpname AS CHARACTER NO-UNDO.
RUN grplib-get-full-name in this-procedure( input p-node-code, output v-full-grpname ) NO-ERROR.
IF ERROR-STATUS:ERROR THEN DO:
   v-full-grpname = "!!!НЕИЗВЕСТНАЯ ГРУППА".
END.
RETURN v-full-grpname.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-role-context Dialog-Frame
FUNCTION get-role-context RETURNS CHARACTER
  ( BUFFER buf_tt-user-login-action-role FOR tt-user-login-action-role ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/

  define variable v-return-value as character no-undo .

  run procedure-get-role-context in this-procedure
    (input  buf_tt-user-login-action-role.action-role-context
    ,output v-return-value
    ) .

  return v-return-value .

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
