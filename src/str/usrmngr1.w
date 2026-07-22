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

Редактировать группы меню для пользователя из списка объектов или фирм

Автор: Белоусов Илья Александрович
Дата создания: 11/09/07
Author: Ilia Belousov
Creation date: 11/09/07

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input  parameter parparentproc as widget-handle no-undo .
define input  parameter p-db-num      as integer   no-undo .
define input  parameter p-user-id     as character no-undo .
define input  parameter p-obj-type   as character no-undo .
define input  parameter p-obj-code   as integer   no-undo .

DEFINE TEMP-TABLE tt-work-place NO-UNDO
    FIELD wp-code AS INTEGER   column-label "№"             FORMAT ">>>>9"
    FIELD wp-type AS CHARACTER column-label "тип"           FORMAT "x(3)"
    FIELD wp-host AS INTEGER   column-label "фирма"         FORMAT ">>>>9"
    FIELD wp-name AS CHARACTER column-label "наименование"  FORMAT "x(40)"
    FIELD db-num  AS INTEGER   column-label "БД"            FORMAT ">>>>9"
    FIELD context AS CHARACTER column-label "привязка"
    FIELD selected AS logical column-label "*" FORMAT "*/ "
INDEX i-code-type IS PRIMARY UNIQUE
      wp-code
      wp-type
INDEX i-host
      wp-host
INDEX i-sel
      selected
.

DEFINE TEMP-TABLE tt-menu-group NO-UNDO
    FIELD menu-group-code AS INTEGER   column-label "№"             FORMAT ">>>>9"
    FIELD menu-group-name as character column-label "Меню"   FORMAT "x(20)"
    FIELD menu-group-description as character column-label "Описание"   FORMAT "x(20)"
    FIELD sel-color as integer
    field permit          as logical
INDEX i-code-type IS PRIMARY UNIQUE
      menu-group-code
.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Редактировать группы меню для пользователя из списка объектов или фирм".
{ cmp/vssrevis.i     }
{ cmp/str-glbl.i     }
{ cmp/showinf.i      }
{ cmp/library.i      }
{ gbl/getcntxt.i def }
{ gbl/twowin.i       }
{ gbl/color.i        }
{ gbl/usrnickf.i     }

/* Local Variable Definitions ---                                       */

define variable v-menu-group-name as character no-undo format "x(30)" column-label "Группа меню" .
define variable v-context-name    as character no-undo format "x(40)" column-label "Контекст"    .
define variable v-user-menu-group as logical   no-undo format "*/ "   column-label "*" .
define variable v-ok              as logical   no-undo.


DEFINE BUFFER br_tt-work-place FOR tt-work-place .
DEFINE buffer br_menu-group    FOR menu-group .
DEFINE buffer br_tt-menu-group FOR tt-menu-group .
define buffer buf_user-login   for user-login.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BROWSE-menu

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES br_tt-menu-group

/* Definitions for BROWSE BROWSE-menu                                   */
&Scoped-define FIELDS-IN-QUERY-BROWSE-menu br_tt-menu-group.menu-group-name br_tt-menu-group.menu-group-description
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-menu
&Scoped-define SELF-NAME BROWSE-menu
&Scoped-define OPEN-QUERY-BROWSE-menu /*OPEN QUERY {&SELF-NAME} FOR EACH br_tt-menu-group NO-LOCK INDEXED-REPOSITION.*/ RUN refresh-query.
&Scoped-define TABLES-IN-QUERY-BROWSE-menu br_tt-menu-group
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-menu br_tt-menu-group


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BROWSE-menu}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-chg-menu b-help BROWSE-menu fi-db
&Scoped-Define DISPLAYED-OBJECTS fi-db

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD check-user-menu-group Dialog-Frame
FUNCTION check-user-menu-group RETURNS logical
   ( BUFFER buf_menu-group FOR menu-group )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-context-name Dialog-Frame
FUNCTION get-context-name RETURNS CHARACTER
  (BUFFER buf_user-menu-group FOR user-menu-group )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-menu-group-name Dialog-Frame
FUNCTION get-menu-group-name RETURNS CHARACTER
  ( BUFFER buf_user-menu-group FOR user-menu-group )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-chg-menu
     LABEL "&Изменить"
     SIZE 10 BY 1.

DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE fi-db AS INTEGER FORMAT ">>>>9":U INITIAL 0
     LABEL "БД"
      VIEW-AS TEXT
     SIZE 10.38 BY .67
     FGCOLOR 4  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BROWSE-menu FOR
      br_tt-menu-group SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BROWSE-menu
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-menu Dialog-Frame _FREEFORM
  QUERY BROWSE-menu NO-LOCK DISPLAY
      br_tt-menu-group.menu-group-name FORMAT "X(32)":U
      br_tt-menu-group.menu-group-description FORMAT "X(42)":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 79.5 BY 15 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-chg-menu AT ROW 1 COL 11 WIDGET-ID 28
     b-help AT ROW 1 COL 71
     BROWSE-menu AT ROW 2.25 COL 1.5 WIDGET-ID 400
     fi-db AT ROW 1.25 COL 27 COLON-ALIGNED WIDGET-ID 2
     SPACE(42.11) SKIP(15.53)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Группы меню для пользователя"
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
/* BROWSE-TAB BROWSE-menu b-help Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-menu
/* Query rebuild information for BROWSE BROWSE-menu
     _START_FREEFORM
/*OPEN QUERY {&SELF-NAME} FOR EACH br_tt-menu-group NO-LOCK INDEXED-REPOSITION.*/
RUN refresh-query.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE BROWSE-menu */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Группы меню для пользователя */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-chg-menu
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-chg-menu Dialog-Frame
ON CHOOSE OF b-chg-menu IN FRAME Dialog-Frame /* Изменить */
DO:
  /**/
   IF  AVAILABLE br_tt-work-place
   then do:
      run change-menu in this-procedure .
      RUN refresh-query IN THIS-PROCEDURE.
   end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-menu
&Scoped-define SELF-NAME BROWSE-menu
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-menu Dialog-Frame
ON ROW-DISPLAY OF BROWSE-menu IN FRAME Dialog-Frame
DO:
  IF br_tt-menu-group.sel-color > 0
  then do:
     assign
      br_tt-menu-group.menu-group-name:bgcolor in browse BROWSE-menu = GRAY_COLOR
      br_tt-menu-group.menu-group-description:bgcolor in browse BROWSE-menu = GRAY_COLOR
     .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

define  buffer buf_tt-work-place for tt-work-place .
{ gbl/app_help.i }
{ gbl/getcntxt.i get }


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

       ASSIGN
        FRAME Dialog-Frame:TITLE = SUBSTITUTE ( "Меню пользователя &1 для &2"
                                              , usrnickf( p-user-id )
                                              , IF p-obj-type = {&cmp}
                                                THEN Substitute("фирмы &1", p-obj-code)
                                                ELSE Substitute(" &1 &2", p-obj-type, p-obj-code)

                                              )
     .

   FIND FIRST buf_user-login
        where buf_user-login.db-num  = p-db-num
          and buf_user-login.user-id = p-user-id
        no-lock
        no-error
        .
   if not available buf_user-login then do:
      message "У пользователя не задан логин."
         skip "Выбор меню невозможен."
      view-as alert-box information.
      return error "У пользователя не задан логин.".
   end.

   ASSIGN
      fi-db         = p-db-num
   .
   RUN fill-wp IN THIS-PROCEDURE.

   RUN enable_UI.
   RUN post_enable_UI.

   IF NOT CAN-FIND (FIRST buf_tt-work-place NO-LOCK) THEN DO:
      return .
   END.

   WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE change-menu Dialog-Frame
PROCEDURE change-menu :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define buffer buf_user-menu-group         for user-menu-group.
define buffer buf_menu-group              for menu-group.
define buffer buf_tt-work-place           for tt-work-place.
define buffer buf_tt-menu-group    for tt-menu-group.

define variable v-menu-group-code    as integer      no-undo.
define variable v-ok                 as logical      no-undo.
define variable v-accepted    as logical      no-undo.
define variable v-changed    as logical      no-undo.
define variable v-user-menu-group-code    as integer      no-undo.
define variable v-menu-group-available    as logical      no-undo.
define variable v-obj-type    as character    no-undo.
define variable v-obj-code    as integer      no-undo.
define variable v-context     as character    no-undo.

do for buf_user-menu-group
   on error undo, return no-apply
   :

   find first buf_tt-work-place
        where buf_tt-work-place.selected = TRUE
      no-error
      .
   if available buf_tt-work-place then do:
      define variable v-list-host   as character    no-undo.
      define variable v-ccc         as integer      no-undo.
      assign
         v-ccc = 0
      .

      FOR EACH buf_tt-work-place
            where buf_tt-work-place.selected = TRUE
      :
         assign
            v-list-host = SUBSTITUTE("&1&2&3&4 &5"
                                       , v-list-host
                                       , (if v-list-host = "":U then "":U else {&new-line})
                                       , buf_tt-work-place.wp-code
                                       , buf_tt-work-place.wp-type
                                       , buf_tt-work-place.wp-name
                                       )
            v-ccc = v-ccc + 1
         .
         IF v-ccc = 1 THEN DO:
            assign
               v-obj-type = buf_tt-work-place.wp-type
               v-obj-code = buf_tt-work-place.wp-code
               v-context  = buf_tt-work-place.context
            .
         end.
         IF buf_tt-work-place.context = {&cntxt-object} THEN DO:
            assign
               v-obj-type = buf_tt-work-place.wp-type
               v-obj-code = buf_tt-work-place.wp-code
               v-context  = buf_tt-work-place.context
            .
         END.
      END.
   end.
   else do:
      assign
         v-obj-type = br_tt-work-place.wp-type
         v-obj-code = br_tt-work-place.wp-code
         v-context  = br_tt-work-place.context
      .
   end.

   run twowin_clear in this-procedure.

   FOR EACH  buf_menu-group
       NO-LOCK
       on error undo, return error
       :
         assign
            v-ok  = FALSE
         .
         { gbl/chkmngr.i
         buf_menu-group.menu-group-id
         v-context
         v-obj-type
         v-obj-code
         p-db-num
         v-ok
         no-error
         }

         IF NOT v-ok THEN DO:
            NEXT.
         end.

         FIND FIRST buf_tt-menu-group
         where buf_tt-menu-group.menu-group-code    = buf_menu-group.menu-group-code
         no-lock
         no-error
         .

         run twowin_add-item in this-procedure
            ( input string( buf_menu-group.menu-group-code  )
            , input buf_menu-group.menu-group-name
            , input buf_menu-group.menu-group-description
            , input ( available buf_tt-menu-group )
            ) .

   end. /* each buf_menu-group */

   run gbl/twowin.w
      ( input parparentproc
      , input 1
      , input "Добавление меню"
      , input "":U
      , input "&Тест"
      , input table temp_twowin_items
      , output table temp_twowin_itemsSelected
      , output v-changed
      , output v-accepted
      ) .

   IF NOT v-accepted THEN DO:
      RETURN.
   END.

   if v-ccc > 0 then do:
      IF v-ccc > 1 THEN DO:
         message
            "Будет изменен список доступных меню для фирм пользователя:"
            SKIP(1)
            v-list-host
            SKIP(1) "Вы уверены?"
         view-as alert-box buttons yes-no
         update v-ok .
         if v-ok = no then do:
            undo, return.
         end.
      end.

      FOR EACH buf_tt-work-place
      :
         /* проверяем удаление меню */
         FOR EACH buf_user-menu-group
            WHERE (buf_user-menu-group.db-num    = p-db-num
               AND buf_user-menu-group.user-id   = p-user-id
               AND buf_user-menu-group.menu-group-context = buf_tt-work-place.context
               AND buf_user-menu-group.menu-group-context = {&cntxt-firm}
               AND buf_user-menu-group.host-code = buf_tt-work-place.wp-host)

               OR
                   (buf_user-menu-group.db-num    = p-db-num
               AND buf_user-menu-group.user-id   = p-user-id
               AND buf_user-menu-group.menu-group-context   = buf_tt-work-place.context
               AND buf_user-menu-group.menu-group-context = {&cntxt-object}
               AND buf_user-menu-group.obj-type = buf_tt-work-place.wp-type
               AND buf_user-menu-group.obj-code = buf_tt-work-place.wp-code)
            exclusive-lock
            on error undo, return error
            :
            find first temp_twowin_itemsSelected
               where temp_twowin_itemsSelected.itmExtKey = string( buf_user-menu-group.menu-group-code )
            no-error.
            if not available temp_twowin_itemsSelected
            then do:
               delete buf_user-menu-group.
            end.
         end. /* EACH  buf_user-menu-group */
         /*
         case buf_tt-work-place.context:
         when {&cntxt-firm} then do:
         end.
         when {&cntxt-firm} then do:
         end.
         otherwise do:
         end.
         end case.
         */

         /* проверяем установку меню */
         _add:
         for each temp_twowin_itemsSelected
         :
            assign
               v-menu-group-code = integer( temp_twowin_itemsSelected.itmExtKey )
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
            find first  buf_user-menu-group
            WHERE (buf_user-menu-group.db-num    = p-db-num
               AND buf_user-menu-group.user-id   = p-user-id
               and buf_user-menu-group.menu-group-code = v-menu-group-code /* !!! */
               AND buf_user-menu-group.menu-group-context = buf_tt-work-place.context
               AND buf_user-menu-group.menu-group-context = {&cntxt-firm}
               AND buf_user-menu-group.host-code = buf_tt-work-place.wp-host)

               OR
                   (buf_user-menu-group.db-num    = p-db-num
               AND buf_user-menu-group.user-id   = p-user-id
               and buf_user-menu-group.menu-group-code = v-menu-group-code
               AND buf_user-menu-group.menu-group-context   = buf_tt-work-place.context
               AND buf_user-menu-group.menu-group-context = {&cntxt-object}
               AND buf_user-menu-group.obj-type = buf_tt-work-place.wp-type
               AND buf_user-menu-group.obj-code = buf_tt-work-place.wp-code)
            no-lock
            no-error
            .
            if not available buf_user-menu-group
            then do:
               FIND FIRST buf_menu-group
                  WHERE buf_menu-group.menu-code = {&menu-code-main}
                  and buf_menu-group.menu-group-code =v-menu-group-code
                  NO-LOCK
                  no-error
                  .
                  if error-status :error
                  then do:
                     message
                           vss-workfile vss-revision vss-description
                        skip(1)
                        skip "Ошибка поиска Меню в системе."
                        skip return-value
                        skip trim( error-status :get-message( 1 ) )
                           trim( error-status :get-message( 2 ) )
                           trim( error-status :get-message( 3 ) )
                     view-as alert-box error.
                     undo, return error.
                  end.
                  { gbl/chkmngr.i
                  buf_menu-group.menu-group-id
                  buf_tt-work-place.context
                  buf_tt-work-place.wp-type
                  buf_tt-work-place.wp-code
                  p-db-num
                  v-menu-group-available
                  no-error
                  }
                  if error-status :error
                  OR NOT v-menu-group-available
                  then do:
                     next _add.
                  end.

                  case buf_tt-work-place.context :
                     when {&cntxt-firm} then do:
                        assign
                           v-user-menu-group-code = NEXT-VALUE(s-user-menu-group)
                        .
                        CREATE buf_user-menu-group .
                        ASSIGN
                           buf_user-menu-group.db-num               = p-db-num
                           buf_user-menu-group.user-id              = p-user-id
                           buf_user-menu-group.user-menu-group-code = v-user-menu-group-code
                           buf_user-menu-group.menu-code            = buf_menu-group.menu-code
                           buf_user-menu-group.menu-group-code      = buf_menu-group.menu-group-code
                           buf_user-menu-group.menu-group-id        = buf_menu-group.menu-group-id
                           buf_user-menu-group.menu-group-context   = {&cntxt-firm}
                           buf_user-menu-group.host-code            = buf_tt-work-place.wp-host
                           buf_user-menu-group.obj-type             = '':U
                           buf_user-menu-group.obj-code             = 0
                        .
                     end.
                     when {&cntxt-object} then do:
                        assign
                           v-user-menu-group-code = NEXT-VALUE(s-user-menu-group)
                        .
                        CREATE buf_user-menu-group .
                        ASSIGN
                           buf_user-menu-group.db-num               = p-db-num
                           buf_user-menu-group.user-id              = p-user-id
                           buf_user-menu-group.user-menu-group-code = v-user-menu-group-code
                           buf_user-menu-group.menu-code            = buf_menu-group.menu-code
                           buf_user-menu-group.menu-group-code      = buf_menu-group.menu-group-code
                           buf_user-menu-group.menu-group-id        = buf_menu-group.menu-group-id
                           buf_user-menu-group.menu-group-context   = {&cntxt-object}
                           buf_user-menu-group.host-code            = buf_tt-work-place.wp-host
                           buf_user-menu-group.obj-type             = buf_tt-work-place.wp-type
                           buf_user-menu-group.obj-code             = buf_tt-work-place.wp-code
                        .
                     end.
                     otherwise do:
                     end.
                  end case.
            end. /* not available buf_user-menu-group */
         end. /* each temp_twowin_itemsSelected */
      end. /* EACH buf_tt-work-place */
   end.
   /* одиночный объект */
   else do:
      IF NOT v-changed THEN DO:
         RETURN.
      END.
      /* проверяем удаление меню */
      for each  buf_user-menu-group
            WHERE (buf_user-menu-group.db-num    = p-db-num
               AND buf_user-menu-group.user-id   = p-user-id
               AND buf_user-menu-group.menu-group-context = br_tt-work-place.context
               AND buf_user-menu-group.menu-group-context = {&cntxt-firm}
               AND buf_user-menu-group.host-code = br_tt-work-place.wp-host)

               OR
                   (buf_user-menu-group.db-num    = p-db-num
               AND buf_user-menu-group.user-id   = p-user-id
               AND buf_user-menu-group.menu-group-context   = br_tt-work-place.context
               AND buf_user-menu-group.menu-group-context = {&cntxt-object}
               AND buf_user-menu-group.obj-type = br_tt-work-place.wp-type
               AND buf_user-menu-group.obj-code = br_tt-work-place.wp-code)
         exclusive-lock
         on error undo, return error
         :
         find first temp_twowin_itemsSelected
               where temp_twowin_itemsSelected.itmExtKey = string( buf_user-menu-group.user-menu-group-code )
         no-error.
         if not available temp_twowin_itemsSelected
         then do:
            delete buf_user-menu-group.
         end.
      end.

      /* проверяем установку меню */
      _add2:
      for each temp_twowin_itemsSelected
      :
         assign
            v-menu-group-code = integer( temp_twowin_itemsSelected.itmExtKey )
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
         find first  buf_user-menu-group
            WHERE (buf_user-menu-group.db-num    = p-db-num
               AND buf_user-menu-group.user-id   = p-user-id
               and buf_user-menu-group.menu-group-code = v-menu-group-code
               AND buf_user-menu-group.menu-group-context = br_tt-work-place.context
               AND buf_user-menu-group.menu-group-context = {&cntxt-firm}
               AND buf_user-menu-group.host-code = br_tt-work-place.wp-host)

               OR
                   (buf_user-menu-group.db-num    = p-db-num
               AND buf_user-menu-group.user-id   = p-user-id
               and buf_user-menu-group.menu-group-code = v-menu-group-code
               AND buf_user-menu-group.menu-group-context   = br_tt-work-place.context
               AND buf_user-menu-group.menu-group-context = {&cntxt-object}
               AND buf_user-menu-group.obj-type = br_tt-work-place.wp-type
               AND buf_user-menu-group.obj-code = br_tt-work-place.wp-code)
         no-lock
         no-error
         .
         if not available buf_user-menu-group
         then do:
            FIND FIRST buf_menu-group
               WHERE buf_menu-group.menu-code     = {&menu-code-main}
               and buf_menu-group.menu-group-code = v-menu-group-code
               NO-LOCK
               no-error
               .
               if not available buf_menu-group
               then do:
                  message
                        vss-workfile vss-revision vss-description
                     skip(1)
                     skip "Ошибка поиска Меню в системе."
                     skip return-value
                     skip trim( error-status :get-message( 1 ) )
                        trim( error-status :get-message( 2 ) )
                        trim( error-status :get-message( 3 ) )
                  view-as alert-box error.
                  undo, return error.
               end.
               { gbl/chkmngr.i
               buf_menu-group.menu-group-id
               br_tt-work-place.context
               br_tt-work-place.wp-type
               br_tt-work-place.wp-code
               p-db-num
               v-menu-group-available
               no-error
               }
               if error-status :error
               OR NOT v-menu-group-available
               then do:
                  next _add2.
               end.

               case br_tt-work-place.context :
                  when {&cntxt-firm} then do:
                     assign
                        v-user-menu-group-code = NEXT-VALUE(s-user-menu-group)
                     .
                     CREATE buf_user-menu-group .
                     ASSIGN
                        buf_user-menu-group.db-num               = p-db-num
                        buf_user-menu-group.user-id              = p-user-id
                        buf_user-menu-group.user-menu-group-code = v-user-menu-group-code
                        buf_user-menu-group.menu-code            = buf_menu-group.menu-code
                        buf_user-menu-group.menu-group-code      = buf_menu-group.menu-group-code
                        buf_user-menu-group.menu-group-id        = buf_menu-group.menu-group-id
                        buf_user-menu-group.menu-group-context   = {&cntxt-firm}
                        buf_user-menu-group.host-code            = br_tt-work-place.wp-host
                        buf_user-menu-group.obj-type             = '':U
                        buf_user-menu-group.obj-code             = 0
                     .
                  end.
                  when {&cntxt-object} then do:
                     assign
                        v-user-menu-group-code = NEXT-VALUE(s-user-menu-group)
                     .
                     CREATE buf_user-menu-group .
                     ASSIGN
                        buf_user-menu-group.db-num               = p-db-num
                        buf_user-menu-group.user-id              = p-user-id
                        buf_user-menu-group.user-menu-group-code = v-user-menu-group-code
                        buf_user-menu-group.menu-code            = buf_menu-group.menu-code
                        buf_user-menu-group.menu-group-code      = buf_menu-group.menu-group-code
                        buf_user-menu-group.menu-group-id        = buf_menu-group.menu-group-id
                        buf_user-menu-group.menu-group-context   = {&cntxt-object}
                        buf_user-menu-group.host-code            = br_tt-work-place.wp-host
                        buf_user-menu-group.obj-type             = br_tt-work-place.wp-type
                        buf_user-menu-group.obj-code             = br_tt-work-place.wp-code
                     .
                  end.
                  otherwise do:
                  end.
               end case.
         end. /* not available buf_user-menu-group */
      end. /* each temp_twowin_itemsSelected */
   end.
end. /* do on error */
END PROCEDURE. /* change-menu */

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
  DISPLAY fi-db
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-chg-menu b-help BROWSE-menu fi-db
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE post_enable_UI {&FRAME-NAME}
PROCEDURE post_enable_UI :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define variable v-ok    as logical      no-undo.

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
              b-chg-menu
        WITH FRAME Dialog-Frame.
    end.
end.  /* do on error */
END PROCEDURE. /* post_enable_UI */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-temp-menu-group Dialog-Frame
PROCEDURE fill-temp-menu-group :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define buffer buf_tt-work-place    for tt-work-place.
define buffer buf_user-menu-group   for user-menu-group.
define buffer buf_menu-group        for menu-group.

define variable v-sel-host-count    as integer      no-undo.

IF AVAILABLE br_tt-work-place then do:

   find first buf_tt-work-place
         where buf_tt-work-place.selected = TRUE
         no-lock
         no-error
         .
   /* не выбрано несколько объектов */
   if NOT available buf_tt-work-place then do:
         empty temp-table tt-menu-group.
      FOR EACH  buf_user-menu-group
            WHERE (buf_user-menu-group.db-num    = p-db-num
               AND buf_user-menu-group.user-id   = p-user-id
               AND buf_user-menu-group.menu-group-context = br_tt-work-place.context
               AND buf_user-menu-group.menu-group-context = {&cntxt-firm}
               AND buf_user-menu-group.host-code = br_tt-work-place.wp-host)

               OR
                   (buf_user-menu-group.db-num    = p-db-num
               AND buf_user-menu-group.user-id   = p-user-id
               AND buf_user-menu-group.menu-group-context   = br_tt-work-place.context
               AND buf_user-menu-group.menu-group-context = {&cntxt-object}
               AND buf_user-menu-group.obj-type = br_tt-work-place.wp-type
               AND buf_user-menu-group.obj-code = br_tt-work-place.wp-code)
         NO-LOCK
         ,
         FIRST buf_menu-group
         WHERE buf_menu-group.menu-code       = buf_user-menu-group.menu-code
           AND buf_menu-group.menu-group-code = buf_user-menu-group.menu-group-code
         NO-LOCK
         :
         create tt-menu-group.
         assign
            tt-menu-group.menu-group-code          = buf_user-menu-group.menu-group-code
            tt-menu-group.menu-group-name          = buf_menu-group.menu-group-name
            tt-menu-group.menu-group-description   = buf_menu-group.menu-group-description
            tt-menu-group.sel-color                = 0
         .
      END.
   END.
   else do:
     empty temp-table tt-menu-group.
     assign
        v-sel-host-count = 0
     .
     for each  buf_tt-work-place
         where buf_tt-work-place.selected = TRUE
     :
        assign
           v-sel-host-count = v-sel-host-count + 1
        .
     end.
     for each  buf_tt-work-place
         where buf_tt-work-place.selected = TRUE
     :
         FOR  EACH buf_user-menu-group
            WHERE (buf_user-menu-group.db-num    = p-db-num
               AND buf_user-menu-group.user-id   = p-user-id
               AND buf_user-menu-group.menu-group-context = buf_tt-work-place.context
               AND buf_user-menu-group.menu-group-context = {&cntxt-firm}
               AND buf_user-menu-group.host-code = buf_tt-work-place.wp-host)

               OR
                   (buf_user-menu-group.db-num    = p-db-num
               AND buf_user-menu-group.user-id   = p-user-id
               AND buf_user-menu-group.menu-group-context   = buf_tt-work-place.context
               AND buf_user-menu-group.menu-group-context = {&cntxt-object}
               AND buf_user-menu-group.obj-type = buf_tt-work-place.wp-type
               AND buf_user-menu-group.obj-code = buf_tt-work-place.wp-code)
            NO-LOCK
            ,
            FIRST buf_menu-group
            WHERE buf_menu-group.menu-code     = buf_user-menu-group.menu-code
            AND buf_menu-group.menu-group-code = buf_user-menu-group.menu-group-code
            NO-LOCK
            :

            find first tt-menu-group
               where tt-menu-group.menu-group-code = buf_user-menu-group.menu-group-code
               no-error
               .
            IF NOT AVAILABLE tt-menu-group then do:
               create tt-menu-group.
               assign
                  tt-menu-group.menu-group-code          = buf_user-menu-group.menu-group-code
                  tt-menu-group.menu-group-name          = buf_menu-group.menu-group-name
                  tt-menu-group.sel-color                = v-sel-host-count
                  tt-menu-group.menu-group-description   = buf_menu-group.menu-group-description
               .
            end.
            assign
               tt-menu-group.sel-color = tt-menu-group.sel-color - 1
            .
         END.
     end.
  end.
end. /* AVAILABLE br_tt-work-place */
end. /* do on error */
END PROCEDURE. /* fill-temp-menu-group */

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
      FOR EACH  buf_user-host
         WHERE buf_user-host.db-num  = p-db-num
            AND buf_user-host.USER-ID = p-user-id
            and buf_user-host.host-code = p-obj-code
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
      FOR EACH  buf_user-obj
          WHERE buf_user-obj.db-num  = p-db-num
            AND buf_user-obj.USER-ID = p-user-id
            and buf_user-obj.obj-type = p-obj-type
            and buf_user-obj.obj-code = p-obj-code
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
            message
               Substitute( "Объект &1&2 &3 не относится к текущей БД"
                         , buf_clients.obj-type
                         , buf_clients.obj-code
                         , buf_clients.obj-name
                         )
               skip "Меню изменять нельзя"
            view-as alert-box information.
            return.
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
   end.

end. /* do on error */
END PROCEDURE. /* fill-wp */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-open-query Dialog-Frame
PROCEDURE local-open-query :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define variable v-ok    as logical      no-undo.

   do
   on error undo, return error return-value
   :
      RUN fill-temp-menu-group IN THIS-PROCEDURE.

      open query BROWSE-menu
      for each  br_tt-menu-group
            no-lock
         indexed-reposition .
   end. /* do on error */
END PROCEDURE. /* local-open-query */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-open-query-wp Dialog-Frame
PROCEDURE local-open-query-wp :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  do
  on error undo, return error return-value
  :

  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE procedure-user-menu-group-add Dialog-Frame
PROCEDURE procedure-user-menu-group-add :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  DEFINE PARAMETER BUFFER buf_tt-work-place FOR tt-work-place.
  define variable v-update-data               as logical   no-undo .
  define variable v-output-menu-code          as integer   no-undo .
  define variable v-output-menu-group-code    as integer   no-undo .
  define variable v-output-menu-group-context as character no-undo .
  define variable v-output-host-code          as integer   no-undo .
  define variable v-output-obj-type           as character no-undo .
  define variable v-output-obj-code           as integer   no-undo .
  define variable v-user-menu-group-code      as integer   no-undo .

  define buffer buf_user-menu-group for ub.user-menu-group .

  do
  on error undo, return error return-value
  :
       case buf_tt-work-place.wp-type :
       when {&cmp} THEN DO:
            FIND FIRST buf_user-menu-group
                 WHERE buf_user-menu-group.db-num          = p-db-num
                   AND buf_user-menu-group.user-id         = p-user-id
                   AND buf_user-menu-group.menu-group-code = br_menu-group.menu-group-code
                   AND buf_user-menu-group.host-code       = buf_tt-work-place.wp-code
                   and buf_user-menu-group.menu-group-context = {&cntxt-firm}
                 EXCLUSIVE-LOCK
                 NO-ERROR
                 .
            /* !!! todo проверка текущей группы у текущего пользователя */
            IF AVAILABLE buf_user-menu-group THEN DO:
               DELETE buf_user-menu-group.
            END.
            ELSE DO:
               ASSIGN
                  v-user-menu-group-code = next-value(s-user-menu-group)
               .
               CREATE buf_user-menu-group .
               ASSIGN
                  buf_user-menu-group.db-num               = p-db-num
                  buf_user-menu-group.user-id              = p-user-id
                  buf_user-menu-group.user-menu-group-code = v-user-menu-group-code
                  buf_user-menu-group.menu-code            = br_menu-group.menu-code
                  buf_user-menu-group.menu-group-code      = br_menu-group.menu-group-code
                  buf_user-menu-group.menu-group-id        = br_menu-group.menu-group-id
                  buf_user-menu-group.menu-group-context   = {&cntxt-firm}
                  buf_user-menu-group.host-code            = buf_tt-work-place.wp-code
                  buf_user-menu-group.obj-type             = '':U
                  buf_user-menu-group.obj-code             = 0
               .
            END. /* create */
       END. /* cntxt-firm */
       when {&shop} OR
       when {&stock} then DO:
            FIND FIRST buf_user-menu-group
                 WHERE buf_user-menu-group.db-num          = p-db-num
                   AND buf_user-menu-group.user-id         = p-user-id
                   AND buf_user-menu-group.menu-group-code = br_menu-group.menu-group-code
                   AND buf_user-menu-group.obj-code        = buf_tt-work-place.wp-code
                   AND buf_user-menu-group.obj-type        = buf_tt-work-place.wp-type
                   and buf_user-menu-group.menu-group-context = {&cntxt-object}
                 EXCLUSIVE-LOCK
                 NO-ERROR
                 .
            /* !!! todo проверка текущей группы у текущего пользователя */
            IF AVAILABLE buf_user-menu-group THEN DO:
               DELETE buf_user-menu-group.
            END.
            ELSE DO:
               ASSIGN
                  v-user-menu-group-code = next-value(s-user-menu-group)
               .
               { gbl/hostcode.i
                  buf_tt-work-place.wp-type
                  buf_tt-work-place.wp-code
                  v-output-host-code
               }
               CREATE buf_user-menu-group .
               ASSIGN
                  buf_user-menu-group.db-num               = p-db-num
                  buf_user-menu-group.user-id              = p-user-id
                  buf_user-menu-group.user-menu-group-code = v-user-menu-group-code
                  buf_user-menu-group.menu-code            = br_menu-group.menu-code
                  buf_user-menu-group.menu-group-code      = br_menu-group.menu-group-code
                  buf_user-menu-group.menu-group-id        = br_menu-group.menu-group-id
                  buf_user-menu-group.menu-group-context   = {&cntxt-object}
                  buf_user-menu-group.host-code            = v-output-host-code
                  buf_user-menu-group.obj-type             = buf_tt-work-place.wp-type
                  buf_user-menu-group.obj-code             = buf_tt-work-place.wp-code
               .
            END. /* create */
       END. /* cntxt-object*/
       otherwise do:
            FIND FIRST buf_user-menu-group
                 WHERE buf_user-menu-group.db-num             = p-db-num
                   AND buf_user-menu-group.user-id            = p-user-id
                   AND buf_user-menu-group.menu-group-code    = br_menu-group.menu-group-code
                   and buf_user-menu-group.menu-group-context = {&cntxt-global}
                 EXCLUSIVE-LOCK
                 NO-ERROR
                 .
            /* !!! todo проверка текущей группы у текущего пользователя */
            IF AVAILABLE buf_user-menu-group THEN DO:
               DELETE buf_user-menu-group.
            END.
            ELSE DO:
               ASSIGN
                  v-user-menu-group-code = next-value(s-user-menu-group)
               .
               CREATE buf_user-menu-group .
               ASSIGN
                  buf_user-menu-group.db-num               = p-db-num
                  buf_user-menu-group.user-id              = p-user-id
                  buf_user-menu-group.user-menu-group-code = v-user-menu-group-code
                  buf_user-menu-group.menu-code            = br_menu-group.menu-code
                  buf_user-menu-group.menu-group-code      = br_menu-group.menu-group-code
                  buf_user-menu-group.menu-group-id        = br_menu-group.menu-group-id
                  buf_user-menu-group.menu-group-context   = {&cntxt-global}
                  buf_user-menu-group.host-code            = 0
                  buf_user-menu-group.obj-type             = '':U
                  buf_user-menu-group.obj-code             = 0
               .
            END. /* create */
       end.
       end case.
  END. /* do on error */
END PROCEDURE. /* procedure-user-menu-group-add */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE refresh-query Dialog-Frame
PROCEDURE refresh-query :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  do
  on error undo, return error return-value
  :
    run local-open-query in this-procedure .
  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE refresh-query-wp Dialog-Frame
PROCEDURE refresh-query-wp :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  do
  on error undo, return error return-value
  :
    run local-open-query-wp in this-procedure .
  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE user-menu-group-add Dialog-Frame
PROCEDURE user-menu-group-add :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  DEFINE PARAMETER BUFFER buf_tt-work-place FOR tt-work-place.
  define variable v-update-data               as logical   no-undo .
  define variable v-output-menu-code          as integer   no-undo .
  define variable v-output-menu-group-code    as integer   no-undo .
  define variable v-output-menu-group-context as character no-undo .
  define variable v-output-host-code          as integer   no-undo .
  define variable v-output-obj-type           as character no-undo .
  define variable v-output-obj-code           as integer   no-undo .
  define variable v-user-menu-group-code      as integer   no-undo .

  define buffer buf_user-menu-group for ub.user-menu-group .

  do
  on error undo, return error return-value
  :

       case buf_tt-work-place.wp-type :
       WHEN {&cmp} THEN DO:
            FIND FIRST buf_user-menu-group
                 WHERE buf_user-menu-group.db-num          = p-db-num
                   AND buf_user-menu-group.user-id         = p-user-id
                   AND buf_user-menu-group.menu-group-code = br_menu-group.menu-group-code
                   AND buf_user-menu-group.host-code       = buf_tt-work-place.wp-code
                   and buf_user-menu-group.menu-group-context = {&cntxt-firm}
                 EXCLUSIVE-LOCK
                 NO-ERROR
                 .
            /* !!! todo проверка текущей группы у текущего пользователя */
            IF NOT AVAILABLE buf_user-menu-group THEN DO:
               ASSIGN
                  v-user-menu-group-code = next-value(s-user-menu-group)
               .
               CREATE buf_user-menu-group .
               ASSIGN
                  buf_user-menu-group.db-num               = p-db-num
                  buf_user-menu-group.user-id              = p-user-id
                  buf_user-menu-group.user-menu-group-code = v-user-menu-group-code
                  buf_user-menu-group.menu-code            = br_menu-group.menu-code
                  buf_user-menu-group.menu-group-code      = br_menu-group.menu-group-code
                  buf_user-menu-group.menu-group-id        = br_menu-group.menu-group-id
                  buf_user-menu-group.menu-group-context   = {&cntxt-firm}
                  buf_user-menu-group.host-code            = buf_tt-work-place.wp-code
                  buf_user-menu-group.obj-type             = '':U
                  buf_user-menu-group.obj-code             = 0
               .
            END. /* create */
       END. /* {&CMP} */
       when {&shop} OR
       when {&stock} then DO:
            FIND FIRST buf_user-menu-group
                 WHERE buf_user-menu-group.db-num          = p-db-num
                   AND buf_user-menu-group.user-id         = p-user-id
                   AND buf_user-menu-group.menu-group-code = br_menu-group.menu-group-code
                   AND buf_user-menu-group.obj-code        = buf_tt-work-place.wp-code
                   AND buf_user-menu-group.obj-type        = buf_tt-work-place.wp-type
                   and buf_user-menu-group.menu-group-context = {&cntxt-object}
                 EXCLUSIVE-LOCK
                 NO-ERROR
                 .
            /* !!! todo проверка текущей группы у текущего пользователя */
            IF NOT AVAILABLE buf_user-menu-group THEN DO:
               ASSIGN
                  v-user-menu-group-code = next-value(s-user-menu-group)
               .
               { gbl/hostcode.i
                  buf_tt-work-place.wp-type
                  buf_tt-work-place.wp-code
                  v-output-host-code
               }
               CREATE buf_user-menu-group .
               ASSIGN
                  buf_user-menu-group.db-num               = p-db-num
                  buf_user-menu-group.user-id              = p-user-id
                  buf_user-menu-group.user-menu-group-code = v-user-menu-group-code
                  buf_user-menu-group.menu-code            = br_menu-group.menu-code
                  buf_user-menu-group.menu-group-code      = br_menu-group.menu-group-code
                  buf_user-menu-group.menu-group-id        = br_menu-group.menu-group-id
                  buf_user-menu-group.menu-group-context   = {&cntxt-object}
                  buf_user-menu-group.host-code            = v-output-host-code
                  buf_user-menu-group.obj-type             = buf_tt-work-place.wp-type
                  buf_user-menu-group.obj-code             = buf_tt-work-place.wp-code
               .
            END. /* create */
       END. /* cntxt-object*/
       otherwise do:
            FIND FIRST buf_user-menu-group
                 WHERE buf_user-menu-group.db-num          = p-db-num
                   AND buf_user-menu-group.user-id         = p-user-id
                   AND buf_user-menu-group.menu-group-code = br_menu-group.menu-group-code
                   and buf_user-menu-group.menu-group-context = {&cntxt-global}
                 EXCLUSIVE-LOCK
                 NO-ERROR
                 .
            /* !!! todo проверка текущей группы у текущего пользователя */
            IF NOT AVAILABLE buf_user-menu-group THEN DO:
               ASSIGN
                  v-user-menu-group-code = next-value(s-user-menu-group)
               .
               CREATE buf_user-menu-group .
               ASSIGN
                  buf_user-menu-group.db-num               = p-db-num
                  buf_user-menu-group.user-id              = p-user-id
                  buf_user-menu-group.user-menu-group-code = v-user-menu-group-code
                  buf_user-menu-group.menu-code            = br_menu-group.menu-code
                  buf_user-menu-group.menu-group-code      = br_menu-group.menu-group-code
                  buf_user-menu-group.menu-group-id        = br_menu-group.menu-group-id
                  buf_user-menu-group.menu-group-context   = {&cntxt-global}
                  buf_user-menu-group.host-code            = 0
                  buf_user-menu-group.obj-type             = "":U
                  buf_user-menu-group.obj-code             = 0
               .
            END. /* create */
       end. /* otherwise */
       end case.
  END. /* do on error */
END PROCEDURE. /* user-menu-group-add */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE user-menu-group-del Dialog-Frame
PROCEDURE user-menu-group-del :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  DEFINE PARAMETER BUFFER buf_tt-work-place FOR tt-work-place.
  define variable v-update-data               as logical   no-undo .
  define variable v-output-menu-code          as integer   no-undo .
  define variable v-output-menu-group-code    as integer   no-undo .
  define variable v-output-menu-group-context as character no-undo .
  define variable v-output-host-code          as integer   no-undo .
  define variable v-output-obj-type           as character no-undo .
  define variable v-output-obj-code           as integer   no-undo .
  define variable v-user-menu-group-code      as integer   no-undo .

  define buffer buf_user-menu-group for ub.user-menu-group .

  do
  on error undo, return error return-value
  :

       case buf_tt-work-place.wp-type :
       WHEN {&cmp} THEN DO:
            FIND FIRST buf_user-menu-group
                 WHERE buf_user-menu-group.db-num          = p-db-num
                   AND buf_user-menu-group.user-id         = p-user-id
                   AND buf_user-menu-group.menu-group-code = br_menu-group.menu-group-code
                   AND buf_user-menu-group.host-code       = buf_tt-work-place.wp-code
                   and buf_user-menu-group.menu-group-context = {&cntxt-firm}
                 EXCLUSIVE-LOCK
                 NO-ERROR
                 .
            /* !!! todo проверка текущей группы у текущего пользователя */
            IF AVAILABLE buf_user-menu-group THEN DO:
               DELETE buf_user-menu-group.
            END.
       END. /* cntxt-firm */
       when {&shop} OR
       when {&stock} then DO:
            FIND FIRST buf_user-menu-group
                 WHERE buf_user-menu-group.db-num          = p-db-num
                   AND buf_user-menu-group.user-id         = p-user-id
                   AND buf_user-menu-group.menu-group-code = br_menu-group.menu-group-code
                   AND buf_user-menu-group.obj-code        = buf_tt-work-place.wp-code
                   AND buf_user-menu-group.obj-type        = buf_tt-work-place.wp-type
                   and buf_user-menu-group.menu-group-context = {&cntxt-object}
                 EXCLUSIVE-LOCK
                 NO-ERROR
                 .
            /* !!! todo проверка текущей группы у текущего пользователя */
            IF AVAILABLE buf_user-menu-group THEN DO:
               DELETE buf_user-menu-group.
            END.
       END. /* cntxt-object*/
       otherwise do:
            FIND FIRST buf_user-menu-group
                 WHERE buf_user-menu-group.db-num          = p-db-num
                   AND buf_user-menu-group.user-id         = p-user-id
                   AND buf_user-menu-group.menu-group-code = br_menu-group.menu-group-code
                   and buf_user-menu-group.menu-group-context = {&cntxt-global}
                 EXCLUSIVE-LOCK
                 NO-ERROR
                 .
            /* !!! todo проверка текущей группы у текущего пользователя */
            IF AVAILABLE buf_user-menu-group THEN DO:
               DELETE buf_user-menu-group.
            END.
       end.
       end case.
  END. /* do on error */
END PROCEDURE. /* user-menu-group-del */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION check-user-menu-group Dialog-Frame
FUNCTION check-user-menu-group RETURNS logical
   ( BUFFER buf_menu-group FOR menu-group ) :

   define variable v-return-value as logical no-undo .
   IF AVAILABLE br_tt-work-place THEN DO:
      case br_tt-work-place.wp-type:
      when {&cmp} THEN DO:
         v-return-value =  CAN-FIND( FIRST user-menu-group
                                     WHERE user-menu-group.db-num          = p-db-num
                                       AND user-menu-group.user-id         = p-user-id
                                       AND user-menu-group.menu-group-code = buf_menu-group.menu-group-code
                                       AND user-menu-group.host-code       = br_tt-work-place.wp-code
                                       AND user-menu-group.menu-group-context   = {&cntxt-firm}
                                       ).
      END.
      when {&shop} OR
      WHEN {&stock} THEN DO:
         v-return-value =  CAN-FIND( FIRST user-menu-group
                                     WHERE user-menu-group.db-num          = p-db-num
                                       AND user-menu-group.user-id         = p-user-id
                                       AND user-menu-group.menu-group-code = buf_menu-group.menu-group-code
                                       AND user-menu-group.obj-code        = br_tt-work-place.wp-code
                                       AND user-menu-group.obj-type        = br_tt-work-place.wp-type
                                       AND user-menu-group.menu-group-context   = {&cntxt-object}
                                       ).
      END.
      otherwise do:
         v-return-value =  CAN-FIND( FIRST user-menu-group
                                     WHERE user-menu-group.db-num          = p-db-num
                                       AND user-menu-group.user-id         = p-user-id
                                       AND user-menu-group.menu-group-code = buf_menu-group.menu-group-code
                                       AND user-menu-group.menu-group-context   = {&cntxt-global}
                                       ).
      end.
      end case.
   END.
   /*
   message v-return-value
   view-as alert-box.
   */
   return v-return-value .   /* function return value. */
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-context-name Dialog-Frame
FUNCTION get-context-name RETURNS CHARACTER
  (BUFFER buf_user-menu-group FOR user-menu-group ) :

  define variable v-return-value as character no-undo .

  run procedure-get-context-name in this-procedure
    (input  buf_user-menu-group.menu-group-context
    ,input  buf_user-menu-group.host-code
    ,input  buf_user-menu-group.obj-type
    ,input  buf_user-menu-group.obj-code
    ,output v-return-value
    ) .

  return v-return-value .

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-menu-group-name Dialog-Frame
FUNCTION get-menu-group-name RETURNS CHARACTER
  ( BUFFER buf_user-menu-group FOR user-menu-group ) :

  define variable v-return-value as character no-undo .

  run procedure-get-menu-group-name in this-procedure
    (input  buf_user-menu-group.menu-code
    ,input  buf_user-menu-group.menu-group-code
    ,input  buf_user-menu-group.menu-group-id
    ,output v-return-value
    ) .

  return v-return-value .   /* function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME