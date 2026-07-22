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

Редактировать группы меню для пользователя.

Автор: Белоусов Илья Александрович
Дата создания: 07/16/07
Author: Ilia Belousov
Creation date: 07/16/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 01/31/07

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input  parameter parparentproc as widget-handle no-undo .
define input  parameter p-db-num      as integer   no-undo .
define input  parameter p-user-id     as character no-undo .
define input  parameter p-menu-code   as integer   no-undo .

DEFINE STREAM s-out.

DEFINE TEMP-TABLE tt-work-place NO-UNDO
    FIELD wp-code AS INTEGER   column-label "№"             FORMAT ">>>>>>>>9"
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
INDEX i-context
      context
.

DEFINE TEMP-TABLE tt-menu-group NO-UNDO
    FIELD menu-group-code        AS INTEGER   column-label "№"             FORMAT ">>>>9"
    FIELD menu-group-id          AS character column-label "ID"
    FIELD menu-group-name        as character column-label "Меню"   FORMAT "x(20)"
    FIELD menu-group-description as character column-label "Описание"   FORMAT "x(20)"
    FIELD sel-color              as integer
    field permit                 as logical
    FIELD selected               AS logical column-label "*" FORMAT "*/ "

INDEX i-code-type IS PRIMARY UNIQUE
      menu-group-code
.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Редактировать группы меню для пользователя".
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
&Scoped-define INTERNAL-TABLES br_tt-menu-group br_tt-work-place

/* Definitions for BROWSE BROWSE-menu                                   */
&Scoped-define FIELDS-IN-QUERY-BROWSE-menu br_tt-menu-group.menu-group-name
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-menu
&Scoped-define SELF-NAME BROWSE-menu
&Scoped-define OPEN-QUERY-BROWSE-menu /*OPEN QUERY {&SELF-NAME} FOR EACH br_tt-menu-group NO-LOCK INDEXED-REPOSITION.*/ RUN refresh-query-menu.
&Scoped-define TABLES-IN-QUERY-BROWSE-menu br_tt-menu-group
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-menu br_tt-menu-group


/* Definitions for BROWSE BROWSE-WP                                     */
&Scoped-define FIELDS-IN-QUERY-BROWSE-WP br_tt-work-place.wp-code br_tt-work-place.wp-type br_tt-work-place.wp-name
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-WP
&Scoped-define SELF-NAME BROWSE-WP
&Scoped-define OPEN-QUERY-BROWSE-WP /* OPEN QUERY {&SELF-NAME} FOR EACH br_tt-work-place. */ RUN refresh-query-wp .
&Scoped-define TABLES-IN-QUERY-BROWSE-WP br_tt-work-place
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-WP br_tt-work-place


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BROWSE-menu}~
    ~{&OPEN-QUERY-BROWSE-WP}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-chg-menu b-help BROWSE-menu ~
BROWSE-WP

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

DEFINE BUTTON b-desel
     LABEL "Снять все"
     SIZE 11 BY 1 TOOLTIP "Снять выделение со всех фирм и объектов".

DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-mark
     LABEL "&*"
     SIZE 3 BY 1.

DEFINE BUTTON b-sel-all
     LABEL "Выделить все"
     SIZE 14 BY 1 TOOLTIP "Выделить все фирмы и объекты".

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BROWSE-menu FOR
      br_tt-menu-group SCROLLING.

DEFINE QUERY BROWSE-WP FOR
      br_tt-work-place SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BROWSE-menu
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-menu Dialog-Frame _FREEFORM
  QUERY BROWSE-menu NO-LOCK DISPLAY
      br_tt-menu-group.menu-group-name FORMAT "X(32)":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 35.5 BY 16.25 FIT-LAST-COLUMN.

DEFINE BROWSE BROWSE-WP
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-WP Dialog-Frame _FREEFORM
  QUERY BROWSE-WP DISPLAY
      br_tt-work-place.wp-code
        br_tt-work-place.wp-type
        br_tt-work-place.wp-name
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 60 BY 16.17 ROW-HEIGHT-CHARS .83 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 2
     b-mark AT ROW 1 COL 12 WIDGET-ID 8
     b-chg-menu AT ROW 1 COL 12 WIDGET-ID 28
     b-sel-all AT ROW 1 COL 15 WIDGET-ID 26
     b-desel AT ROW 1 COL 29 WIDGET-ID 30
     b-help AT ROW 1 COL 88
     BROWSE-menu AT ROW 2.25 COL 2 WIDGET-ID 400
     BROWSE-WP AT ROW 2.25 COL 38 WIDGET-ID 300
     SPACE(0.37) SKIP(0.36)
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
/* BROWSE-TAB BROWSE-WP BROWSE-menu Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR BUTTON b-desel IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       b-desel:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR BUTTON b-mark IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       b-mark:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR BUTTON b-sel-all IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       b-sel-all:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-menu
/* Query rebuild information for BROWSE BROWSE-menu
     _START_FREEFORM
/*OPEN QUERY {&SELF-NAME} FOR EACH br_tt-menu-group NO-LOCK INDEXED-REPOSITION.*/
RUN refresh-query-menu.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE BROWSE-menu */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-WP
/* Query rebuild information for BROWSE BROWSE-WP
     _START_FREEFORM
/* OPEN QUERY {&SELF-NAME} FOR EACH br_tt-work-place. */
RUN refresh-query-wp .
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE BROWSE-WP */
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
   IF AVAILABLE br_tt-menu-group
   then do:
      run change-menu-2 in this-procedure .
      RUN refresh-query-wp IN THIS-PROCEDURE.
   end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-desel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-desel Dialog-Frame
ON CHOOSE OF b-desel IN FRAME Dialog-Frame /* Снять все */
DO:
   FOR EACH br_tt-menu-group
   ON ERROR UNDO, NEXT
   :
      assign
         br_tt-menu-group.selected = NO
      .
   END.
   run enable_UI in this-procedure .
   run post_enable_UI in this-procedure .
   RUN refresh-query-menu IN THIS-PROCEDURE .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-mark Dialog-Frame
ON CHOOSE OF b-mark IN FRAME Dialog-Frame /* * */
DO
:
   DEFINE VARIABLE v-log AS LOGICAL NO-UNDO .

   IF  AVAILABLE br_tt-work-place
   THEN DO
   ON ERROR UNDO, RETURN NO-APPLY
   :
      assign
         br_tt-menu-group.selected = NOT br_tt-menu-group.selected
      .
      v-log = BROWSE-menu:refresh() IN FRAME Dialog-Frame.
      if last-event :function <> "MOUSE-SELECT-DBLCLICK"
      then do:
        v-log = BROWSE-menu:select-next-row ().
        apply "iteration-changed" to BROWSE-menu in frame {&frame-name}.
      end.
      /*
      run fill-wp in this-procedure.
      run local-open-query-wp in this-procedure .
      */
   END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel-all
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel-all Dialog-Frame
ON CHOOSE OF b-sel-all IN FRAME Dialog-Frame /* Выделить все */
DO:
   FOR EACH br_tt-menu-group
   ON ERROR UNDO, NEXT
   :
      assign
         br_tt-menu-group.selected = YES
      .
   END.
   run enable_UI in this-procedure .
   run post_enable_UI in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-menu
&Scoped-define SELF-NAME BROWSE-menu
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-menu Dialog-Frame
ON VALUE-CHANGED OF BROWSE-menu IN FRAME Dialog-Frame
DO:
   IF  AVAILABLE br_tt-menu-group
   then do:
      RUN refresh-query-wp IN THIS-PROCEDURE.
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

{ gbl/app_help.i }
{ gbl/hot-key.i b-mark }
{ gbl/getcntxt.i get }


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

   define buffer buf_user-obj    for user-obj .
   define buffer buf_user-host   for user-host .

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
      return.
   end.
   IF NOT CAN-FIND (FIRST buf_user-obj where buf_user-obj.db-num  = p-db-num
                                         and buf_user-obj.user-id = p-user-id
                    NO-LOCK)
   AND NOT CAN-FIND (FIRST buf_user-host where buf_user-host.db-num  = p-db-num
                                           and buf_user-host.user-id = p-user-id
                    NO-LOCK)
   THEN DO:
      message "У пользователя не заданы ни объекты ни фирмы."
         skip "Выбор меню невозможен."
      view-as alert-box information.
      return.
   END.

   ASSIGN
        FRAME Dialog-Frame:TITLE = SUBSTITUTE ( "Меню пользователя &1 для БД &2"
                                              , usrnickf( p-user-id )
                                              , buf_user-login.db-num
                                              )
   .

   run fill-menu in this-procedure .
   run fill-wp in this-procedure .

   RUN enable_UI.
   run post_enable_UI in this-procedure .

   WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE change-menu-2 Dialog-Frame
PROCEDURE change-menu-2 :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
/*
define buffer buf_user-menu-group  for user-menu-group.
define buffer buf_menu-group       for menu-group.
*/

define buffer buf_tt-work-place    for tt-work-place.
define buffer buf_user-menu-group      for user-menu-group .

define variable v-menu-group-code    as integer      no-undo.
define variable v-ok                 as logical      no-undo.
define variable v-accepted    as logical      no-undo.
define variable v-changed    as logical      no-undo.
define variable v-user-menu-group-code    as integer      no-undo.

if available br_tt-menu-group then
DO
on error undo, return no-apply
   :

   { gbl/working.i }
   run twowin_clear in this-procedure.

   each-wp_:
   FOR EACH   buf_tt-work-place
       break by buf_tt-work-place.context
      :

      IF  p-db-num <> 0
      AND buf_tt-work-place.db-num <> p-db-num
      and buf_tt-work-place.context = {&cntxt-object}
      THEN do:
          next each-wp_ .
      end.

      /* IF FIRST-OF (buf_tt-work-place.context) then do: */
         assign
            v-ok = FALSE
         .
            { gbl/chkmngr.i
               br_tt-menu-group.menu-group-id
               buf_tt-work-place.context
               buf_tt-work-place.wp-type
               buf_tt-work-place.wp-code
               p-db-num
               v-ok
               no-error
            }
      /* end. */

      IF NOT v-ok THEN do:
         next each-wp_ .
      end.

      run twowin_add-item in this-procedure
         ( input SUBSTITUTE( "&2 &1", buf_tt-work-place.wp-code, buf_tt-work-place.wp-type  )
         , input SUBSTITUTE( "&1 &2 &3", buf_tt-work-place.wp-code, buf_tt-work-place.wp-type, buf_tt-work-place.wp-name )
         , input SUBSTITUTE( "БД: &1 Фирма: &2", buf_tt-work-place.db-num, buf_tt-work-place.wp-host )
         , input buf_tt-work-place.selected
         ) .
   end.
   { gbl/stopwork.i }

   run gbl/twowin.w
      ( input parparentproc
      , input 1
      , input SUBSTITUTE('Добавление меню "&1" на объектах и фирмах:', br_tt-menu-group.menu-group-name)
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
   /* проверяем изменения */
   { gbl/working.i }
   post-each-wp_:
   FOR EACH buf_tt-work-place
   :
      IF  p-db-num <> 0
      AND buf_tt-work-place.db-num <> p-db-num
      and buf_tt-work-place.context = {&cntxt-object}
      THEN do:
          next post-each-wp_ .
      end.

      find first temp_twowin_itemsSelected
               where temp_twowin_itemsSelected.itmExtKey = SUBSTITUTE( "&2 &1", buf_tt-work-place.wp-code, buf_tt-work-place.wp-type  )
           no-lock
           no-error
           .
      /* выбрано */
      IF available temp_twowin_itemsSelected then do:
         /* уже было */
         if buf_tt-work-place.selected = TRUE then do:
            next post-each-wp_ .
         end.
         /* не было, создаем */
         else do:
            /* проверяем наличие, на всякий случай */
            find first  buf_user-menu-group
            WHERE (buf_user-menu-group.db-num               = p-db-num
               AND buf_user-menu-group.user-id              = p-user-id
               and buf_user-menu-group.menu-group-code      = br_tt-menu-group.menu-group-code /* !!! */
               AND buf_user-menu-group.menu-group-context   = buf_tt-work-place.context
               AND buf_user-menu-group.menu-group-context   = {&cntxt-firm}
               AND buf_user-menu-group.host-code            = buf_tt-work-place.wp-host)

               OR
                  (buf_user-menu-group.db-num              = p-db-num
               AND buf_user-menu-group.user-id              = p-user-id
               and buf_user-menu-group.menu-group-code      = br_tt-menu-group.menu-group-code
               AND buf_user-menu-group.menu-group-context   = buf_tt-work-place.context
               AND buf_user-menu-group.menu-group-context   = {&cntxt-object}
               AND buf_user-menu-group.obj-type             = buf_tt-work-place.wp-type
               AND buf_user-menu-group.obj-code             = buf_tt-work-place.wp-code)
            no-lock
            no-error
            .

            IF NOT AVAILABLE buf_user-menu-group THEN DO:
               case buf_tt-work-place.context:
               when {&cntxt-object} THEN do:
                  assign
                     v-user-menu-group-code = next-value(s-user-menu-group)
                  .
                  CREATE buf_user-menu-group.
                  assign
                     buf_user-menu-group.db-num               = p-db-num
                     buf_user-menu-group.user-id              = p-user-id
                     buf_user-menu-group.menu-code            = {&menu-code-main}
                     buf_user-menu-group.menu-group-code      = br_tt-menu-group.menu-group-code
                     buf_user-menu-group.menu-group-id        = br_tt-menu-group.menu-group-id
                     buf_user-menu-group.menu-group-context   = {&cntxt-object}
                     buf_user-menu-group.obj-type             = buf_tt-work-place.wp-type
                     buf_user-menu-group.obj-code             = buf_tt-work-place.wp-code
                     buf_user-menu-group.host-code            = buf_tt-work-place.wp-host
                     buf_user-menu-group.user-menu-group-code = v-user-menu-group-code
                  .
               end.
               when {&cntxt-firm} THEN do:
                  assign
                     v-user-menu-group-code = next-value(s-user-menu-group)
                  .
                  CREATE buf_user-menu-group.
                  assign
                     buf_user-menu-group.db-num               = p-db-num
                     buf_user-menu-group.user-id              = p-user-id
                     buf_user-menu-group.menu-code            = {&menu-code-main}
                     buf_user-menu-group.menu-group-code      = br_tt-menu-group.menu-group-code
                     buf_user-menu-group.menu-group-id        = br_tt-menu-group.menu-group-id
                     buf_user-menu-group.menu-group-context   = {&cntxt-firm}
                     buf_user-menu-group.obj-type             = "":U
                     buf_user-menu-group.obj-code             = 0
                     buf_user-menu-group.host-code            = buf_tt-work-place.wp-host
                     buf_user-menu-group.user-menu-group-code = v-user-menu-group-code
                  .
               end.
               otherwise do:
               end.
               end case.
            END.
         end.
      end.
      /* не выбрано */
      else do:
         /* было, удаляем */
         if buf_tt-work-place.selected = TRUE then do:
            find first  buf_user-menu-group
            WHERE (buf_user-menu-group.db-num               = p-db-num
               AND buf_user-menu-group.user-id              = p-user-id
               and buf_user-menu-group.menu-group-code      = br_tt-menu-group.menu-group-code /* !!! */
               AND buf_user-menu-group.menu-group-context   = buf_tt-work-place.context
               AND buf_user-menu-group.menu-group-context   = {&cntxt-firm}
               AND buf_user-menu-group.host-code            = buf_tt-work-place.wp-host)

               OR
                   (buf_user-menu-group.db-num              = p-db-num
               AND buf_user-menu-group.user-id              = p-user-id
               and buf_user-menu-group.menu-group-code      = br_tt-menu-group.menu-group-code
               AND buf_user-menu-group.menu-group-context   = buf_tt-work-place.context
               AND buf_user-menu-group.menu-group-context   = {&cntxt-object}
               AND buf_user-menu-group.obj-type             = buf_tt-work-place.wp-type
               AND buf_user-menu-group.obj-code             = buf_tt-work-place.wp-code)
            exclusive-lock
            no-error
            .
            IF AVAILABLE buf_user-menu-group THEN DO:
               DELETE buf_user-menu-group.
            END.
         end.
         /* не было */
         else do:
            next post-each-wp_ .
         end.
      end.
   end. /* проверяем изменения */
   { gbl/stopwork.i }
end. /* do on error */
END PROCEDURE. /* change-menu-2 */

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
  ENABLE b-exit b-chg-menu b-help BROWSE-menu BROWSE-WP
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-menu Dialog-Frame
PROCEDURE fill-menu :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define buffer buf_menu-group     for menu-group .
do
on error undo, return error
:
   for each  buf_menu-group
       where buf_menu-group.menu-code = {&menu-code-main}
       no-lock
       by buf_menu-group.menu-group-name
       :
       IF buf_menu-group.menu-group-id = "all" then do:
          next .
       end.
       create tt-menu-group.
       assign
          tt-menu-group.menu-group-code        = buf_menu-group.menu-group-code
          tt-menu-group.menu-group-id          = buf_menu-group.menu-group-id
          tt-menu-group.menu-group-name        = buf_menu-group.menu-group-name
          tt-menu-group.menu-group-description = buf_menu-group.menu-group-description
       .
   end.

end.  /* do on error */
END PROCEDURE. /* fill-menu */

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
define buffer buf_user-menu-group      for user-menu-group .
define buffer del_user-menu-group      for user-menu-group .
define buffer buf_tt-work-place     for tt-work-place .

if available tt-menu-group then
do
on error undo, return error
:
   user-menu_:

   FOR EACH buf_user-obj
         WHERE buf_user-obj.db-num = p-db-num
         AND buf_user-obj.USER-ID  = p-user-id
      NO-LOCK
      :
         FIND FIRST buf_clients
            WHERE buf_clients.obj-code = buf_user-obj.obj-code
               AND buf_clients.obj-type = buf_user-obj.obj-type
            NO-LOCK
            .
         CREATE buf_tt-work-place.
         ASSIGN
            buf_tt-work-place.wp-code = buf_clients.obj-code
            buf_tt-work-place.wp-type = buf_clients.obj-type
            buf_tt-work-place.wp-host = buf_clients.host-code
            buf_tt-work-place.db-num  = buf_clients.db-num
            buf_tt-work-place.context = {&cntxt-object}
            buf_tt-work-place.wp-name = buf_clients.obj-name
         .
   end.
   FOR EACH buf_user-host
       WHERE buf_user-host.db-num  = p-db-num
         AND buf_user-host.USER-ID = p-user-id
       NO-LOCK
       :
         FIND FIRST buf_clients
            WHERE buf_clients.obj-code = buf_user-host.host-code
               AND buf_clients.obj-type = {&cmp}
            NO-LOCK
            .
         CREATE buf_tt-work-place.
         ASSIGN
            buf_tt-work-place.wp-code = buf_clients.obj-code
            buf_tt-work-place.wp-type = buf_clients.obj-type
            buf_tt-work-place.wp-host = buf_clients.obj-code
            buf_tt-work-place.db-num  = buf_clients.db-num
            buf_tt-work-place.context = {&cntxt-firm}
            buf_tt-work-place.wp-name = buf_clients.obj-name
         .
   end.
end. /* do on error */
END PROCEDURE. /* fill-wp */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-open-query-menu Dialog-Frame
PROCEDURE local-open-query-menu :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define variable v-ok    as logical      no-undo.
do
on error undo, return error return-value
:

   open query BROWSE-menu
        for each  br_tt-menu-group
        no-lock
        indexed-reposition
        .

end. /* do on error */
END PROCEDURE. /* local-open-query-menu */

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
    open query browse-wp
    for each br_tt-work-place
        where br_tt-work-place.selected = TRUE
        no-lock
    indexed-reposition
    .

end. /* do on error */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE mark-wp Dialog-Frame
PROCEDURE mark-wp :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define buffer buf_user-menu-group      for user-menu-group .
define buffer buf_tt-work-place     for tt-work-place .

if available br_tt-menu-group then
do
on error undo, return error
:

   user-menu_:
   FOR EACH buf_tt-work-place
      :

      case buf_tt-work-place.context:
      when {&cntxt-object} then do:
         IF CAN-FIND ( FIRST buf_user-menu-group
              where buf_user-menu-group.db-num             = p-db-num
                and buf_user-menu-group.user-id            = p-user-id
                and buf_user-menu-group.menu-code          = {&menu-code-main}
                and buf_user-menu-group.menu-group-code    = br_tt-menu-group.menu-group-code
                and buf_user-menu-group.obj-code           = buf_tt-work-place.wp-code
                AND buf_user-menu-group.obj-type           = buf_tt-work-place.wp-type
                and buf_user-menu-group.host-code          = buf_tt-work-place.wp-host
                and buf_user-menu-group.menu-group-context = {&cntxt-object}
                and buf_user-menu-group.menu-group-id      = br_tt-menu-group.menu-group-id
            NO-LOCK )
            then do:
               ASSIGN
                  buf_tt-work-place.selected = TRUE
               .
            end.
            else do:
               ASSIGN
                  buf_tt-work-place.selected = FALSE
               .
            end.
      end.
      when {&cntxt-firm} then do:
         IF CAN-FIND ( FIRST buf_user-menu-group
              where buf_user-menu-group.db-num             = p-db-num
                and buf_user-menu-group.user-id            = p-user-id
                and buf_user-menu-group.menu-code          = {&menu-code-main}
                and buf_user-menu-group.menu-group-code    = br_tt-menu-group.menu-group-code
                and buf_user-menu-group.obj-code           = 0
                AND buf_user-menu-group.obj-type           = "":U
                and buf_user-menu-group.host-code          = buf_tt-work-place.wp-host
                and buf_user-menu-group.menu-group-context = {&cntxt-firm}
                and buf_user-menu-group.menu-group-id      = br_tt-menu-group.menu-group-id
            NO-LOCK )
            then do:
               ASSIGN
                  buf_tt-work-place.selected = TRUE
               .
            end.
            else do:
               ASSIGN
                  buf_tt-work-place.selected = FALSE
               .
            end.
      end.
      otherwise do:
      end.
      end case.
   end. /* EACH buf_user-menu-group */
end. /* do on error */
END PROCEDURE. /* mark-wp */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE refresh-query-menu Dialog-Frame
PROCEDURE refresh-query-menu :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  do
  on error undo, return error return-value
  :
    run local-open-query-menu in this-procedure .
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
    RUN mark-wp IN THIS-PROCEDURE.
    run local-open-query-wp in this-procedure .
  end.
END PROCEDURE.

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