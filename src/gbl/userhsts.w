&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
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

Выбор фирмы или списка объектов из доступных пользователю фирм

Автор: Белоусов Илья Александрович
Дата создания: 05/08/07
Author: Ilia Belousov
Creation date: 05/08/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 09/04/06


*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input  parameter parparentproc      as widget-handle no-undo .
define input  parameter p-callback-handle  as handle    no-undo .
define input  parameter p-db-num           as integer   no-undo .
define input  parameter p-user-id          as character no-undo .
define input  parameter p-curr-host-code   as integer   no-undo .
define input  parameter p-bttns            as character NO-UNDO .
define output parameter p-user-select      as logical   no-undo .
define output parameter p-select-host-code as integer   no-undo .
/* Для множественного выбора добавляем параметр - список выбранных host-code  */
DEFINE OUTPUT PARAMETER p-List-select-host-code AS CHARACTER NO-UNDO INITIAL "".

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Список фирм системы".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/thbj-def.i }
{ gbl/thbjattr.i }
{ adm/shattrg.i  }
{ cmp/showinf.i  }
{ gbl/waitfram.i }
{ gbl/getcntxt.i def }
{ gbl/colwidth.i }
{ gbl/twowin.i   }
{ gbl/color.i    }
{ gbl/usrnickf.i }

define variable v-default-object as character no-undo format "X(9)" .

define variable v-brws-mark        as character no-undo column-label "*"        format "x(1)":u  .
define variable v-host-name        as character no-undo .
define variable v-curr-name        as character no-undo .
define variable attr-option        as character no-undo .
define variable v-object-name      as character no-undo column-label "Имя" format "X(40)":U .
define variable v-object-db-num    as integer   no-undo column-label "БД"  format ">>>>9" .
define variable v-object-available as character no-undo column-label "Доступен для тек.пользователя" format "X(8)":U .

define variable v-total-select-num as integer   no-undo .

define temp-table temp-user-host no-undo
  field host-code as integer
  field db-num    as integer
  field host-name as character

  index xpk is primary unique
        host-code
        db-num
  .
define temp-table temp-user-menu-group no-undo
  field menu-group-code as integer
  field menu-group-name as character
  field menu-group-description as character
  field sel-color       as integer

  index pu is primary unique
        menu-group-code
  .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-host

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES ub.user-host ub.user-obj

/* Definitions for BROWSE br-host                                       */
&Scoped-define FIELDS-IN-QUERY-br-host mark-string(ub.user-host.host-code) @ v-brws-mark ub.user-host.host-code get-host-name(ub.user-host.host-code) @ v-host-name get-default-object(ub.user-host.host-code) @ v-default-object
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-host
&Scoped-define SELF-NAME br-host
&Scoped-define OPEN-QUERY-br-host /* OPEN QUERY {&SELF-NAME} FOR EACH ub.user-host NO-LOCK INDEXED-REPOSITION. */ run open-query-user-host in this-procedure .
&Scoped-define TABLES-IN-QUERY-br-host ub.user-host
&Scoped-define FIRST-TABLE-IN-QUERY-br-host ub.user-host


/* Definitions for BROWSE br-obj                                        */
&Scoped-define FIELDS-IN-QUERY-br-obj ub.user-obj.obj-type ub.user-obj.obj-code get-object-name(ub.user-obj.obj-type, ub.user-obj.obj-code) @ v-object-name get-object-db-num(ub.user-obj.obj-type, ub.user-obj.obj-code) @ v-object-db-num
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-obj
&Scoped-define SELF-NAME br-obj
&Scoped-define OPEN-QUERY-br-obj /* OPEN QUERY {&SELF-NAME} FOR EACH ub.user-obj NO-LOCK INDEXED-REPOSITION. */ run open-query-user-obj in this-procedure .
&Scoped-define TABLES-IN-QUERY-br-obj ub.user-obj
&Scoped-define FIRST-TABLE-IN-QUERY-br-obj ub.user-obj


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-host}~
    ~{&OPEN-QUERY-br-obj}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-mark B-sel b-action b-menu B-Help ~
b-add B-lookup B-company b-del B-obj br-host br-obj mark-num
&Scoped-Define DISPLAYED-OBJECTS mark-num

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-curr-name Dialog-Frame
FUNCTION get-curr-name RETURNS CHARACTER
  ( input p-curr-code as integer )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-default-object Dialog-Frame
FUNCTION get-default-object RETURNS CHARACTER
  ( input p-host-code as integer )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-host-name Dialog-Frame
FUNCTION get-host-name RETURNS CHARACTER
  ( INPUT p-host-code AS integer )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-object-db-num Dialog-Frame
FUNCTION get-object-db-num RETURNS INTEGER
  ( INPUT p-obj-type AS CHARACTER, INPUT p-obj-code AS integer )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-object-name Dialog-Frame
FUNCTION get-object-name RETURNS CHARACTER
  ( INPUT p-obj-type AS CHARACTER, INPUT p-obj-code AS integer )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD mark-string Dialog-Frame
FUNCTION mark-string RETURNS CHARACTER
  ( INPUT p-host-code AS integer )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-action
     LABEL "Права"
     SIZE 10 BY 1 TOOLTIP "Права, доступные пользователю на фирме".

DEFINE BUTTON b-add
     LABEL "&Добавить"
     SIZE 10 BY 1.

DEFINE BUTTON B-company
     LABEL "&Фирма"
     SIZE 10 BY 1.

DEFINE BUTTON b-del
     LABEL "&Удал."
     SIZE 10 BY 1.

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-lookup
     LABEL "&Просмотр"
     SIZE 10 BY 1.

DEFINE BUTTON B-mark
     LABEL "&*"
     SIZE 3 BY 1.

DEFINE BUTTON b-menu
     LABEL "Меню"
     SIZE 10 BY 1 TOOLTIP "Группы меню, доступные пользователю на фирме".

DEFINE BUTTON B-obj
     LABEL "Просмотр"
     SIZE 10 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-sel AUTO-GO
     LABEL "В&ыбор"
     SIZE 10 BY 1.

DEFINE VARIABLE mark-num AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 6 BY 1
     FGCOLOR 4  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-host FOR
      ub.user-host SCROLLING.

DEFINE QUERY br-obj FOR
      ub.user-obj SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-host
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-host Dialog-Frame _FREEFORM
  QUERY br-host NO-LOCK DISPLAY
      mark-string(ub.user-host.host-code) @ v-brws-mark
      ub.user-host.host-code format "999999999"
      get-host-name(ub.user-host.host-code) @ v-host-name COLUMN-LABEL "Название" FORMAT "X(40)":U
      get-default-object(ub.user-host.host-code) @ v-default-object COLUMN-LABEL "Главн.объект!межфирм.перем."
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 53.5 BY 17 ROW-HEIGHT-CHARS .67.

DEFINE BROWSE br-obj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-obj Dialog-Frame _FREEFORM
  QUERY br-obj NO-LOCK DISPLAY
      ub.user-obj.obj-type column-label "Тип"
      ub.user-obj.obj-code column-label "Код"
      get-object-name(ub.user-obj.obj-type, ub.user-obj.obj-code)   @ v-object-name
      get-object-db-num(ub.user-obj.obj-type, ub.user-obj.obj-code) @ v-object-db-num
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 42.5 BY 17 ROW-HEIGHT-CHARS .67.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 11
     B-sel AT ROW 1 COL 21
     b-action AT ROW 1 COL 31 WIDGET-ID 8
     b-menu AT ROW 1 COL 41 WIDGET-ID 10
     B-Help AT ROW 1 COL 88
     b-add AT ROW 2 COL 1 WIDGET-ID 2
     B-lookup AT ROW 2 COL 11
     B-company AT ROW 2 COL 21
     b-del AT ROW 2 COL 31 WIDGET-ID 4
     B-obj AT ROW 2 COL 55.5
     br-host AT ROW 3.25 COL 1
     br-obj AT ROW 3.25 COL 55.5
     mark-num AT ROW 1 COL 12.5 COLON-ALIGNED NO-LABEL
     SPACE(77.99) SKIP(18.45)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Список <Своих> фирм системы"
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-host B-obj Dialog-Frame */
/* BROWSE-TAB br-obj br-host Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       br-host:NUM-LOCKED-COLUMNS IN FRAME Dialog-Frame     = 1.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-host
/* Query rebuild information for BROWSE br-host
     _START_FREEFORM
/* OPEN QUERY {&SELF-NAME} FOR EACH ub.user-host NO-LOCK INDEXED-REPOSITION. */
run open-query-user-host in this-procedure .
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE br-host */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-obj
/* Query rebuild information for BROWSE br-obj
     _START_FREEFORM
/* OPEN QUERY {&SELF-NAME} FOR EACH ub.user-obj NO-LOCK INDEXED-REPOSITION. */
run open-query-user-obj in this-procedure .
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE br-obj */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Список <Своих> фирм системы */
DO:
  run choose-select in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Список <Своих> фирм системы */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-action
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-action Dialog-Frame
ON CHOOSE OF b-action IN FRAME Dialog-Frame /* Права */
DO:
   if not available ub.user-host
   then do:
      return no-apply.
   end.

   run str/usractn1.w ( INPUT parparentproc
                      , INPUT ub.user-host.user-id
                      , INPUT ub.user-host.db-num
                      , INPUT {&cmp}
                      , INPUT ub.user-host.host-code
                      ) NO-ERROR.
   if error-status :error
   then do:
        message
              vss-workfile vss-revision vss-description
           skip(1)
           skip "Ошибка изменения прав пользователя на фирме"
           skip return-value
           skip trim( error-status :get-message( 1 ) )
              trim( error-status :get-message( 2 ) )
              trim( error-status :get-message( 3 ) )
        view-as alert-box error.
      return no-apply.
   end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add Dialog-Frame
ON CHOOSE OF b-add IN FRAME Dialog-Frame /* Добавить */
DO:
  run create_user_host.
  run enable_UI.
  run MyEnable in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-company
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-company Dialog-Frame
ON CHOOSE OF B-company IN FRAME Dialog-Frame /* Фирма */
DO:
  define variable v-ok as logical   no-undo .
  if available ub.user-host
  then do:
    { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      "'actn_host-reference_lookup':U"
      {&cntxt-global}
      0
      '':U
      0
      0
      0
      0
      true
      v-ok
    }
    if v-ok <> true
    then do:
      return no-apply.
    end.
    run adm/config.w
      (input parParentProc
      ,input ub.user-host.host-code
      ,input  {&lookup}
      ,input no /*p-is-deploy*/
      ) no-error.
    if error-status :error
    then do:
      return no-apply.
    end.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del Dialog-Frame
ON CHOOSE OF b-del IN FRAME Dialog-Frame /* Удал. */
DO:
   if not available ub.user-host
   then do:
      return no-apply.
   end.

   run delete_user_host.
   run enable_UI.
   run MyEnable in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-lookup
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-lookup Dialog-Frame
ON CHOOSE OF B-lookup IN FRAME Dialog-Frame /* Просмотр */
DO:
if available ub.user-host
then do:
  run ref/showcli.p (
    input parParentProc
    ,input {&cmp} /* p-obj-type */
    ,input ub.user-host.host-code /* p-obj-code */
    ).
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* * */
DO:
   run choose-mark in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-menu
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-menu Dialog-Frame
ON CHOOSE OF b-menu IN FRAME Dialog-Frame /* Меню */
DO:
   if not available ub.user-host
   then do:
      return no-apply.
   end.

   run str/usrmngr1.w ( INPUT parparentproc
                      , INPUT ub.user-host.db-num
                      , INPUT ub.user-host.user-id
                      , INPUT {&cmp}
                      , INPUT ub.user-host.host-code
                      ) NO-ERROR.
   if error-status :error
   then do:
        message
              vss-workfile vss-revision vss-description
           skip(1)
           skip "Ошибка изменения меню пользователя на фирме"
           skip return-value
           skip trim( error-status :get-message( 1 ) )
              trim( error-status :get-message( 2 ) )
              trim( error-status :get-message( 3 ) )
        view-as alert-box error.
      return no-apply.
   end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-obj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-obj Dialog-Frame
ON CHOOSE OF B-obj IN FRAME Dialog-Frame /* Просмотр */
DO:
  run br-obj-show-object in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-quit Dialog-Frame
ON CHOOSE OF b-quit IN FRAME Dialog-Frame /* Выход */
DO:
  assign
    p-select-host-code =  ?
    p-List-select-host-code =  ""
  .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sel Dialog-Frame
ON CHOOSE OF B-sel IN FRAME Dialog-Frame /* Выбор */
DO:
  { gbl/stdbtn.i }

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-host
&Scoped-define SELF-NAME br-host
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-host Dialog-Frame
ON DEFAULT-ACTION OF br-host IN FRAME Dialog-Frame
DO:
   if INDEX ( p-bttns, "b-sel") > 0
   then do:
      apply 'go':u to frame {&frame-name} .
   end.
   else do:
      run choose-mark in this-procedure .
   end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-host Dialog-Frame
ON VALUE-CHANGED OF br-host IN FRAME Dialog-Frame
DO:
  run update-br-host-dependent in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-obj
&Scoped-define SELF-NAME br-obj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-obj Dialog-Frame
ON DEFAULT-ACTION OF br-obj IN FRAME Dialog-Frame
DO:
  run br-obj-show-object in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-host
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/getcntxt.i get }

{ gbl/app_help.i
  &disable_diasize=true
}
{ gbl/hot-key.i b-mark }
{ gbl/hot-key.i b-del }
{ gbl/hot-key.i b-add }

{ gbl/diasize.i
  &browse-name="br-host"
}
run diasize_add_browse in this-procedure
  (input  'width':u
  ,input  browse br-obj :handle
  ) .
run diasize_init in this-procedure .

assign
  p-user-select      = false
  p-select-host-code = ?
  p-List-select-host-code = ""
.

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
:
  assign
    v-host-name   :resizable in browse br-host = true
    v-object-name :resizable in browse br-obj  = true
  .

  define variable v-colwidth-data-exist as logical   no-undo .

  { gbl/colw_rd.i
    v-cntxt-db-num
    v-cntxt-userid
    'gbl/userhsts.w':U
    v-colwidth-data-exist
  }
  if v-colwidth-data-exist = true
  then do:
    assign
      v-host-name   :width in browse br-host = v-colwidth-width-01
      v-object-name :width in browse br-obj  = v-colwidth-width-02
    .
  end.
  else do:
    assign
      v-host-name   :width in browse br-host = 25
      v-object-name :width in browse br-obj  = 25
    .
  end.

  RUN MyEnable.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.

assign
  v-colwidth-width-01 = v-host-name   :width in browse br-host
  v-colwidth-width-02 = v-object-name :width in browse br-obj
.
{ gbl/colw_wr.i }

RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE br-obj-show-object Dialog-Frame
PROCEDURE br-obj-show-object :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

  do
  on error undo, return error return-value
  :
    if available ub.user-obj
    then do:
      run ref/showcli.p
        (input parparentproc
        ,input ub.user-obj.obj-type
        ,input ub.user-obj.obj-code
        ) no-error.
    end.
  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE change-menu Dialog-Frame
PROCEDURE change-menu :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define buffer buf_user-menu-group for ub.user-menu-group.
define buffer buf_menu-group      for ub.menu-group.
define buffer buf_temp-user-host  for temp-user-host.
define buffer buf_temp-user-menu-group    for temp-user-menu-group.

define variable v-menu-group-code    as integer      no-undo.
define variable v-ok                 as logical      no-undo.
define variable v-accepted    as logical      no-undo.
define variable v-changed    as logical      no-undo.
define variable v-user-menu-group-code    as integer      no-undo.

do for buf_user-menu-group
   on error undo, return no-apply
   :

   run twowin_clear in this-procedure.

   FOR EACH  buf_menu-group
       NO-LOCK
       on error undo, return error
       :
         { gbl/chkmngr.i
         buf_menu-group.menu-group-id
         {&cntxt-firm}
         {&cmp}
         ub.user-host.host-code
         p-db-num
         v-ok
         no-error
         }
       IF NOT v-ok THEN DO:
          NEXT.
       end.

       FIND FIRST buf_temp-user-menu-group
       where buf_temp-user-menu-group.menu-group-code    = buf_menu-group.menu-group-code
       no-lock
       no-error
       .

       run twowin_add-item in this-procedure
         ( input string( buf_menu-group.menu-group-code  )
         , input buf_menu-group.menu-group-name
         , input buf_menu-group.menu-group-description
         , input ( available buf_temp-user-menu-group )
         ) .

   end. /* each  buf_action-item */

   run gbl/twowin.w
      ( input parparentproc
      , input 1
      , input "Добавление меню фирме"
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

   find first buf_temp-user-host
      no-error
      .
   if available buf_temp-user-host then do:
   define variable v-list-host    as character    no-undo.
   define variable v-ccc    as integer      no-undo.
      assign
         v-ok  = FALSE
         v-ccc = 0
      .

      FOR EACH buf_temp-user-host
      :
        assign
         v-list-host = SUBSTITUTE("&1&2&3 &4"
                                    , v-list-host
                                    , (if v-list-host = "":U then "":U else {&new-line})
                                    , buf_temp-user-host.host-code
                                    , buf_temp-user-host.host-name
                                    )
         v-ccc = v-ccc + 1
        .
      END.

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

      FOR EACH buf_temp-user-host
      :
         /* проверяем удаление меню */
         for each  buf_user-menu-group
            where buf_user-menu-group.db-num = p-db-num
               and buf_user-menu-group.user-id = p-user-id
               and buf_user-menu-group.host-code = buf_temp-user-host.host-code
               and buf_user-menu-group.menu-group-context = {&cntxt-firm}
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
            where buf_user-menu-group.db-num = p-db-num
               and buf_user-menu-group.user-id = p-user-id
               and buf_user-menu-group.host-code = buf_temp-user-host.host-code
               and buf_user-menu-group.menu-group-context = {&cntxt-firm}
               and buf_user-menu-group.menu-group-code =v-menu-group-code
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
                  assign
                  v-user-menu-group-code = NEXT-VALUE(s-user-menu-group, {&db-name_schema})
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
                        buf_user-menu-group.host-code            = buf_temp-user-host.host-code
                        buf_user-menu-group.obj-type             = '':U
                        buf_user-menu-group.obj-code             = 0
                     .
            end. /* not available buf_user-menu-group */
         end. /* each temp_twowin_itemsSelected */
      end. /* EACH buf_temp-user-host */
   end.
   else do:
      IF NOT v-changed THEN DO:
         RETURN.
      END.
      /* проверяем удаление меню */
      for each  buf_user-menu-group
         where buf_user-menu-group.db-num = p-db-num
            and buf_user-menu-group.user-id = p-user-id
            and buf_user-menu-group.host-code = ub.user-host.host-code
            and buf_user-menu-group.menu-group-context = {&cntxt-firm}
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
         where buf_user-menu-group.db-num = p-db-num
            and buf_user-menu-group.user-id = p-user-id
            and buf_user-menu-group.host-code = ub.user-host.host-code
            and buf_user-menu-group.menu-group-context = {&cntxt-firm}
            and buf_user-menu-group.menu-group-code =v-menu-group-code
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
               assign
               v-user-menu-group-code = NEXT-VALUE(s-user-menu-group, {&db-name_schema})
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
                     buf_user-menu-group.host-code            = ub.user-host.host-code
                     buf_user-menu-group.obj-type             = '':U
                     buf_user-menu-group.obj-code             = 0
                  .
         end. /* not available buf_user-menu-group */
      end. /* each temp_twowin_itemsSelected */
   end.
end. /* do on error */
END PROCEDURE. /* change-menu */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE check-selection Dialog-Frame
PROCEDURE check-selection :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define variable v-ok as logical   no-undo .

  define buffer buf_temp-user-host for temp-user-host .

  do
  on error undo, return error return-value
  :
    do with frame {&frame-name}
    :
      if can-do ( p-bttns, "b-mark")
      then do:
        find first buf_temp-user-host
          no-error .

        if available buf_temp-user-host
        then do:
          message
            "Информация о выбранных элементах будет потеряна" Skip
            "Продолжить?" Skip
            view-as alert-box question buttons yes-no update v-ok .
          if v-ok = true
          then do:
            for each buf_temp-user-host
            on error undo, return error return-value
            :
              delete buf_temp-user-host .
            end.
          end.
          else do:
            undo, return error return-value .
          end.
        end.
      end.
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE choose-mark Dialog-Frame
PROCEDURE choose-mark :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define variable v-log as logical no-undo .

  define buffer buf_temp-user-host for temp-user-host .

  do
  on error undo, return error return-value
  :
    if available ub.user-host
    then do:
      find first buf_temp-user-host
        where buf_temp-user-host.host-code = ub.user-host.host-code
        no-error .
      if available buf_temp-user-host
      then do:
        run userhsts_delete in this-procedure
          ( input  ub.user-host.host-code
          , input  ub.user-host.db-num
          ) .
      end.
      else do:
        run userhsts_append in this-procedure
          ( input  ub.user-host.host-code
          , input  ub.user-host.db-num
          ) .
      end.

      v-log = br-host:refresh() in frame {&frame-name}.
      if last-event :function <> "MOUSE-SELECT-DBLCLICK"
      then do:
        v-log = br-host:select-next-row ().
        run update-br-host-dependent in this-procedure .
      end.

      run display-select-num in this-procedure .

      apply 'entry':U to br-host in frame {&frame-name}.
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE choose-select Dialog-Frame
PROCEDURE choose-select :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

  define buffer buf_temp-user-host for temp-user-host .

  do
  on error undo, return error return-value
  :
    do with frame {&frame-name}
    :
      if available ub.user-host
      then do:
        if INDEX ( p-bttns, "b-mark") > 0
        then do:
          find first buf_temp-user-host
            no-error .
          if not available buf_temp-user-host
          then do:
            run userhsts_append in this-procedure
              ( input  ub.user-host.host-code
              , input  ub.user-host.db-num
              ) .
          end.

          run userhsts_clear in p-callback-handle .

          for each buf_temp-user-host
          on error undo, return error return-value
          :
            run userhsts_append in p-callback-handle
              ( input  buf_temp-user-host.host-code
              ) .
          /* Добавляем при множественноме выборе заполнение параметра
            список выбранных host-code  */
          ASSIGN
             p-List-Select-Host-code = p-List-select-host-code +
                                       (IF p-List-select-host-code = "" THEN "" ELSE "," ) +
                                       STRING(buf_temp-user-host.host-code).

          end.
        end.
        else do:
          assign
            p-select-host-code = ub.user-host.host-code
          .
        end.
      end.
    end.

    assign
      p-user-select = true
    .
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE create_user_host Dialog-Frame
PROCEDURE create_user_host :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
DEFINE VARIABLE v-out-host-code AS INTEGER   NO-UNDO.
DEFINE VARIABLE v-rid-list      AS CHARACTER NO-UNDO .
define variable v-count         as integer   no-undo.

define buffer buf_sysconf       FOR ub.sysconf.
define buffer buf_clients     for ub.clients .
define buffer buf_user-host      for ub.user-host .

do
on error undo, return error return-value
:
   run adm/sconfs.w ( INPUT parparentproc
                    , INPUT "b-sel,b-mark"
                    , FALSE
                    , p-curr-host-code
                    , OUTPUT v-out-host-code
                    , INPUT-OUTPUT v-rid-list
                    ) .
   IF  v-rid-list <> ""
   AND v-rid-list <> ?
   THEN
   count_:
   DO v-count = 1 to num-entries(v-rid-list)
   transaction
   :
      FIND FIRST buf_sysconf
         WHERE RECID( buf_sysconf ) = INTEGER(ENTRY(v-count, v-rid-list))
         NO-LOCK
         NO-ERROR.
      if ERROR-STATUS :ERROR
      OR NOT AVAILABLE buf_sysconf
      then do:
           NEXT count_.
      end.
      /*
      find first buf_clients
            where buf_clients.db-num = p-db-num
            and buf_clients.obj-type = {&cmp}
            and buf_clients.obj-code = buf_sysconf.host-code
      no-lock
      no-error
      .
      IF NOT AVAILABLE buf_clients THEN DO:
         NEXT count_.
      END.
      */
      IF CAN-FIND (buf_user-host where buf_user-host.host-code     = buf_sysconf.host-code
                                    and buf_user-host.user-id      = p-user-id
                                    AND buf_user-host.db-num       = p-db-num
                           no-lock)
      then do:
         next count_.
      end.

      CREATE ub.user-host.
      ASSIGN
         ub.user-host.db-num    = p-db-num
         ub.user-host.user-id   = p-user-id
         ub.user-host.host-code = buf_sysconf.host-code
      .
   END.
END.
END PROCEDURE. /* create_user_host */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE delete_user_host Dialog-Frame
PROCEDURE delete_user_host :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  DEFINE VARIABLE v-out-host-code AS INTEGER   NO-UNDO.
  DEFINE VARIABLE v-rid-list      AS CHARACTER NO-UNDO .

  do
  transaction
  on error undo, return error return-value
  :
     define variable v-ok                    as logical   no-undo .
     define variable v-message-text          as character no-undo .

     define variable v-cntxt-valid           as logical   no-undo .
     define variable v-cntxt-menu-code       as integer   no-undo .
     define variable v-cntxt-menu-group-code as integer   no-undo .
     define variable v-cntxt-level           as character no-undo .
     define variable v-cntxt-host-code-obj   as integer   no-undo .
     define variable v-cntxt-obj-type        as character no-undo .
     define variable v-cntxt-obj-code        as integer   no-undo .

     define buffer   buf_user-host for ub.user-host.

     v-ok = no.
     run gbl/cntxtget.p ( INPUT  p-db-num
                        , INPUT  p-user-id
                        , OUTPUT v-cntxt-valid
                        , OUTPUT v-cntxt-menu-code
                        , OUTPUT v-cntxt-menu-group-code
                        , OUTPUT v-cntxt-level
                        , OUTPUT v-cntxt-host-code-obj
                        , OUTPUT v-cntxt-obj-type
                        , OUTPUT v-cntxt-obj-code
                        ) .

     if  v-cntxt-host-code-obj = ub.user-host.host-code
     THEN DO:
        v-message-text = "Удаляемая фирма - текущая для данного пользователя.~n".
     END.
     v-message-text = v-message-text + SUBSTITUTE("Удалить фирму &1 (сделать ее недоступной для данного пользователя) ?", get-host-name(ub.user-host.host-code) ).

     MESSAGE v-message-text
     VIEW-AS ALERT-BOX
     BUTTONS OK-CANCEL
     TITLE "Удаление фирмы":U
     UPDATE v-ok.

     IF NOT v-ok THEN RETURN NO-APPLY.

     run userhsts_delete in this-procedure ( INPUT ub.user-host.host-code
                                           , INPUT ub.user-host.db-num
                                           ) .

     FIND buf_user-host WHERE buf_user-host.db-num    = ub.user-host.db-num
                          AND buf_user-host.user-id   = p-user-id
                          AND buf_user-host.host-code = ub.user-host.host-code
                        EXCLUSIVE-LOCK.
     DELETE buf_user-host.
     IF INDEX("текущая", v-message-text) > 0 THEN DO:
        run gbl/cntxtstr.p ( INPUT  p-db-num
                           , INPUT  p-user-id
                           , INPUT  v-cntxt-menu-code
                           , INPUT  v-cntxt-menu-group-code
                           , INPUT  {&cntxt-global}
                           , INPUT  ""
                           , INPUT  ""
                           , INPUT  ""
                           )  .
        MESSAGE "Удалена текущая фирма для данного пользователя." skip (2)
                "Пользователю по умолчанию выставлен контекст без фирмы"
        VIEW-AS ALERT-BOX WARNING.
     END.
  end.
END PROCEDURE. /* delete_user_host */

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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE display-select-num Dialog-Frame
PROCEDURE display-select-num :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  do
  on error undo, return error return-value
  :
    assign
      mark-num = string(v-total-select-num)
    .

    if v-total-select-num = 0
    then do:
      hide
        mark-num
        in frame {&frame-name}.
    end.
    else do:
      display
        mark-num
        with frame {&frame-name}.
    end.
  end.

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
  DISPLAY mark-num
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-mark B-sel b-action b-menu B-Help b-add B-lookup B-company
         b-del B-obj br-host br-obj mark-num
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

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
define buffer buf_temp-user-host    for temp-user-host.
define buffer buf_user-menu-group   for ub.user-menu-group.
define buffer buf_menu-group        for ub.menu-group.

define variable v-sel-host-count    as integer      no-undo.

   find first buf_temp-user-host
      no-error
      .
   if NOT available buf_temp-user-host then do:
      empty temp-table temp-user-menu-group.
      FOR EACH  buf_user-menu-group
         WHERE buf_user-menu-group.db-num     = p-db-num
            AND buf_user-menu-group.user-id   = p-user-id
            AND buf_user-menu-group.host-code = ub.user-host.host-code  /* AVAIL !!! */
            AND buf_user-menu-group.menu-group-context = {&cntxt-firm}
         NO-LOCK
         ,
         FIRST buf_menu-group
         WHERE buf_menu-group.menu-code       = buf_user-menu-group.menu-code
           AND buf_menu-group.menu-group-code = buf_user-menu-group.menu-group-code
         NO-LOCK
         :
         create temp-user-menu-group.
         assign
            temp-user-menu-group.menu-group-code = buf_user-menu-group.menu-group-code
            temp-user-menu-group.menu-group-name = buf_menu-group.menu-group-name
            temp-user-menu-group.menu-group-description = buf_menu-group.menu-group-description
            temp-user-menu-group.sel-color       = 0
         .
      END.
  END.
  else do:
     empty temp-table temp-user-menu-group.
     assign
        v-sel-host-count = 0
     .
     for each buf_temp-user-host
     :
        assign
           v-sel-host-count = v-sel-host-count + 1
        .
     end.
     for each buf_temp-user-host
     :
         FOR EACH  buf_user-menu-group
            WHERE buf_user-menu-group.db-num     = p-db-num
               AND buf_user-menu-group.user-id   = p-user-id
               AND buf_user-menu-group.host-code = buf_temp-user-host.host-code  /* AVAIL !!! */
               AND buf_user-menu-group.menu-group-context = {&cntxt-firm}
            NO-LOCK
            ,
            FIRST buf_menu-group
            WHERE buf_menu-group.menu-code       = buf_user-menu-group.menu-code
            AND buf_menu-group.menu-group-code = buf_user-menu-group.menu-group-code
            NO-LOCK
            :

            find first temp-user-menu-group
               where temp-user-menu-group.menu-group-code = buf_user-menu-group.menu-group-code
               no-error
               .
            IF NOT AVAILABLE temp-user-menu-group then do:
               create temp-user-menu-group.
               assign
                  temp-user-menu-group.menu-group-code = buf_user-menu-group.menu-group-code
                  temp-user-menu-group.menu-group-name = buf_menu-group.menu-group-name
                  temp-user-menu-group.sel-color       = v-sel-host-count
                  temp-user-menu-group.menu-group-description = buf_menu-group.menu-group-description
               .
            end.
            assign
               temp-user-menu-group.sel-color = temp-user-menu-group.sel-color - 1
            .
         END.
     end.
  end.
end.
END PROCEDURE. /* fill-temp-menu-group */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-host-name-proc Dialog-Frame
PROCEDURE get-host-name-proc :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define input  parameter p-host-code as integer   no-undo .
  define output parameter p-host-name as character no-undo .

  define buffer buf_clients for ub.clients .

  do
  on error undo, return error return-value
  :
    find first buf_clients no-lock
      where buf_clients.obj-type = {&cmp}
        and buf_clients.obj-code = p-host-code
      no-error .
    if available buf_clients
    then do:
      assign
        p-host-name = (if buf_clients.stts = 0
                       then buf_clients.obj-name
                       else (substring (buf_clients.obj-name, 1, 20)
                            + fill (" " , 20 - length (substring (buf_clients.obj-name, 1, 20)))
                            + {&deleted-stat_}
                            )
                      )
      .
    end.
  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-object-db-num-proc Dialog-Frame
PROCEDURE get-object-db-num-proc :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define input  parameter p-obj-type      as character no-undo .
  define input  parameter p-obj-code      as integer   no-undo .
  define output parameter p-object-db-num as integer   no-undo .

  define buffer buf_clients for ub.clients .

  do
  on error undo, return error return-value
  :
    find first buf_clients no-lock
      where buf_clients.obj-type = p-obj-type
        and buf_clients.obj-code = p-obj-code
      no-error .
    if available buf_clients
    then do:
      assign
        p-object-db-num = buf_clients.db-num
      .
    end.
    else do:
      assign
        p-object-db-num = ?
      .
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-object-name-proc Dialog-Frame
PROCEDURE get-object-name-proc :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define input  parameter p-obj-type    as character no-undo .
  define input  parameter p-obj-code    as integer   no-undo .
  define output parameter p-object-name as character no-undo .

  define buffer buf_clients for ub.clients .

  do
  on error undo, return error return-value
  :
    find first buf_clients no-lock
      where buf_clients.obj-type = p-obj-type
        and buf_clients.obj-code = p-obj-code
      no-error .
    if available buf_clients
    then do:
      assign
        p-object-name = buf_clients.obj-name
      .
    end.
    else do:
      assign
        p-object-name = ?
      .
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE host-default-object Dialog-Frame
PROCEDURE host-default-object :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

   define input parameter p-host-code as integer no-undo .
   define output parameter p-obj-type as character no-undo .
   define output parameter p-obj-code as integer no-undo .

   define buffer buf_firm for ub.firm .

   find first buf_firm no-lock
     where buf_firm.firm-code = p-host-code
     no-error .
   if available buf_firm then do:
     assign
       p-obj-type = main-obj-type
       p-obj-code = main-obj-code
     .
   end.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE mark-string-proc Dialog-Frame
PROCEDURE mark-string-proc :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

  define input  parameter p-host-code   as integer   no-undo .
  define output parameter p-mark-string as character no-undo .

  define buffer buf_temp-user-host for temp-user-host .

  do
  on error undo, return error return-value
  :
    find first buf_temp-user-host
         where buf_temp-user-host.host-code = p-host-code
         no-error
         .
    if available buf_temp-user-host
    then do:
      assign
        p-mark-string = '*':U
      .
    end.
    else do:
      assign
        p-mark-string = '':U
      .
    end.

  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

  do
  on error undo, return error return-value
  :

    disable
    all
    with frame dialog-frame
    .
    define variable v-user-name as character no-undo .
    /*
    { gbl/usrfulnm.i
      v-cntxt-userid
      v-user-name
    }
    */
    assign
      frame dialog-frame :title = substitute("Фирмы пользователя &1"
                                            , usrnickf( p-user-id )
                                            )
    .

    enable
      b-quit
      b-sel  when can-do ( p-bttns, "b-sel")
      b-mark when can-do ( p-bttns, "b-mark")
      b-add  when can-do ( p-bttns, "b-add")
      b-del  when can-do ( p-bttns, "b-add")
      b-lookup
      b-company
      b-action
      b-menu
      b-help
      br-host
      br-obj
      b-obj
    with frame dialog-frame.
    view frame dialog-frame.
    {&open-browsers-in-query-dialog-frame}
    hide
      mark-num
      in frame {&frame-name} .

    if p-curr-host-code <> ?
    then do:
      define variable v-user-host-rowid as rowid no-undo .

      define buffer buf_reposition_user-host for ub.user-host .
      find first buf_reposition_user-host no-lock
        where buf_reposition_user-host.db-num    = p-db-num
          and buf_reposition_user-host.user-id   = p-user-id
          and buf_reposition_user-host.host-code = p-curr-host-code
        no-error .
      if available buf_reposition_user-host
      then do:
        reposition br-host to rowid rowid(buf_reposition_user-host) no-error .
      end.
    end.
    apply 'entry':U to br-host .
    run update-br-host-dependent in this-procedure .
  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE open-query-user-host Dialog-Frame
PROCEDURE open-query-user-host :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

  do
  on error undo, return error return-value
  :
    open query br-host for each ub.user-host no-lock
         where ub.user-host.db-num  = p-db-num
           and ub.user-host.user-id = p-user-id
         indexed-reposition
         .

  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE open-query-user-obj Dialog-Frame
PROCEDURE open-query-user-obj :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  do
  on error undo, return error return-value
  :
    do
    on error undo, return error return-value
    :
      if available ub.user-host
      then do:
        open query br-obj
          for each ub.user-obj
             no-lock
             where ub.user-obj.db-num    = ub.user-host.db-num
               and ub.user-obj.user-id   = ub.user-host.user-id
               and ub.user-obj.host-code = ub.user-host.host-code
                by ub.user-obj.obj-type
                by ub.user-obj.obj-code
          indexed-reposition
          .
      end.
      else do:
        open query br-obj for  each ub.user-obj no-lock
             where ub.user-obj.db-num  = 0
               and ub.user-obj.user-id = '':U
           indexed-reposition
          .
      end.
    end.
  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE update-br-host-dependent Dialog-Frame
PROCEDURE update-br-host-dependent :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  do
  on error undo, return error return-value
  :
    /*
    B-obj !!!
    do with frame {&frame-name}
    :
      define buffer buf_clients for ub.clients .
      if available ub.user-host
      then do:
        find first buf_clients no-lock
          where buf_clients.obj-type = {&cmp}
            and buf_clients.obj-code = ub.user-host.host-code
          no-error .
        if available buf_clients
        then do:
          assign
            fi-object-list-description :screen-value = buf_clients.obj-name
          .
        end.
        else do:
          assign
            fi-object-list-description :screen-value = '':U
          .
        end.
      end.
      else do:
        assign
          fi-object-list-description :screen-value = '':U
        .
      end.
    end.
    */
    {&OPEN-QUERY-br-obj}
    IF AVAILABLE ub.user-obj THEN DO:
       enable b-obj
       with frame dialog-frame.
    END.
    ELSE do:
       disable b-obj
       with frame dialog-frame.
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE userhsts_append Dialog-Frame
PROCEDURE userhsts_append :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define input  parameter p-host-code as integer   no-undo .
  define input  parameter p-db-num    as integer   no-undo .

  define buffer buf_temp-user-host for temp-user-host .

  do
  on error undo, return error return-value
  :
    find first buf_temp-user-host
         where buf_temp-user-host.host-code = p-host-code
           and buf_temp-user-host.db-num    = p-db-num
         no-error
         .
    if not available buf_temp-user-host
    then do:
      create buf_temp-user-host .
      assign
        buf_temp-user-host.host-code = p-host-code
        buf_temp-user-host.db-num    = p-db-num
      .
      assign
        buf_temp-user-host.host-name = get-host-name(p-host-code)
        v-total-select-num = v-total-select-num + 1
      .
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE userhsts_delete Dialog-Frame
PROCEDURE userhsts_delete :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define input  parameter p-host-code as integer   no-undo .
  define input  parameter p-db-num    as integer   no-undo .

  define buffer buf_temp-user-host for temp-user-host .

  do
  on error undo, return error return-value
  :
    find first buf_temp-user-host
      where buf_temp-user-host.host-code = p-host-code
        and buf_temp-user-host.db-num    = p-db-num
      no-error .
    if available buf_temp-user-host
    then do:
      delete buf_temp-user-host .
      assign
        v-total-select-num = v-total-select-num - 1
      .
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-curr-name Dialog-Frame
FUNCTION get-curr-name RETURNS CHARACTER
  ( input p-curr-code as integer ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
  find first ub.currency no-lock where
                 ub.currency.curr-code = p-curr-code no-error.
    if available ub.currency then do:
        return ub.currency.curr-abbr.
    end.
    else do:
        return {&question-mark}.
    end.

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-default-object Dialog-Frame
FUNCTION get-default-object RETURNS CHARACTER
  ( input p-host-code as integer ) :

  define variable v-obj-type as character no-undo .
  define variable v-obj-code as integer no-undo .

  run host-default-object
    (input p-host-code
    ,output v-obj-type
    ,output v-obj-code
    ) .
  if v-obj-type <> "" then do:
    return substitute('&1 &2':u, v-obj-type, v-obj-code) .
  end.
  else do:
    return "" .
  end.


END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-host-name Dialog-Frame
FUNCTION get-host-name RETURNS CHARACTER
  ( INPUT p-host-code AS integer ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/

  define variable v-host-name as character no-undo .
  run get-host-name-proc in this-procedure
    (input  p-host-code
    ,output v-host-name
    ) .
  return v-host-name .


END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-object-db-num Dialog-Frame
FUNCTION get-object-db-num RETURNS INTEGER
  ( INPUT p-obj-type AS CHARACTER, INPUT p-obj-code AS integer ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/

  define variable v-object-db-num as integer   no-undo .
  run get-object-db-num-proc in this-procedure
    (input  p-obj-type
    ,input  p-obj-code
    ,output v-object-db-num
    ) .
  return v-object-db-num .

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-object-name Dialog-Frame
FUNCTION get-object-name RETURNS CHARACTER
  ( INPUT p-obj-type AS CHARACTER, INPUT p-obj-code AS integer ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/

  define variable v-object-name as character no-undo .
  run get-object-name-proc in this-procedure
    (input  p-obj-type
    ,input  p-obj-code
    ,output v-object-name
    ) .
  return v-object-name .

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION mark-string Dialog-Frame
FUNCTION mark-string RETURNS CHARACTER
  ( INPUT p-host-code AS integer ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
  define variable v-mark-string as character no-undo .

  run mark-string-proc in this-procedure
    (input  p-host-code
    ,output v-mark-string
    ) .
  return v-mark-string .

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME