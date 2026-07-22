&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame

/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER buf_clients FOR ub.clients.
DEFINE BUFFER buf_goods FOR ub.goods.
DEFINE BUFFER loc_fbr-gds-obj FOR ub.fbr-gds-obj.
DEFINE TEMP-TABLE tt-fbr-gds-obj NO-UNDO LIKE ub.fbr-gds-obj.
DEFINE TEMP-TABLE tt0-fbr-gds-obj NO-UNDO LIKE ub.fbr-gds-obj.


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Атрибуты товара на объекте- РЕСТОРАН

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/04/03
Author: Bakhtadze Natalya
Creation date: 09/04/03

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
define input parameter par-mode as character no-undo.
/*может быть {&updatel}, {&add-def}, {&lookup} или 'template':U */

define input parameter p-gds-code like ub.fbr-gds-obj.gds-code no-undo.
define input parameter p-obj-type like ub.fbr-gds-obj.obj-type no-undo.
define input parameter p-obj-code like ub.fbr-gds-obj.obj-code no-undo.
define input parameter p-update-instantly as logical no-undo .
define input-output parameter p-template as character    no-undo.
define output parameter p-updated AS LOGICAL no-undo.
define input-output parameter par-recid as recid no-undo.


/* Local Variable Definitions ---                                       */
def var vss-revision    as character no-undo init "$Revision$":U .
def var vss-author      as character no-undo init "$Author$":U .
def var vss-date        as character no-undo init "$Date$":U .
def var vss-workfile    as character no-undo init "$Workfile$":U .
def var vss-archive     as character no-undo init "$Archive$":U .
def var vss-description as character no-undo init "Атрибуты товара на объекте- РЕСТОРАН".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ str/lib-trn.i  }
{ cmp/showinf.i  }
{ gbl/temphost.i }
{ cmp/titlmode.i }
{ gbl/getcntxt.i def }
{ gbl/userobjs.i }


define variable v-db-num like ub.db.db-num no-undo.
define variable v-fbr-obj-type like ub.fbr-gds-obj.fbr-obj-type no-undo.
define variable v-fbr-obj-code like ub.fbr-gds-obj.fbr-obj-code no-undo.
define buffer X_fbr-gds-grp for ub.fbr-gds-grp.
define buffer X_clients for ub.clients.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-fbr-gds-obj

/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define FIELDS-IN-QUERY-Dialog-Frame tt-fbr-gds-obj.fbr-obj-code ~
tt-fbr-gds-obj.fbr-obj-type tt-fbr-gds-obj.is-cd tt-fbr-gds-obj.is-menu ~
tt-fbr-gds-obj.is-semi-finished tt-fbr-gds-obj.is-season ~
tt-fbr-gds-obj.is-modificator tt-fbr-gds-obj.is-null-price
&Scoped-define ENABLED-FIELDS-IN-QUERY-Dialog-Frame ~
tt-fbr-gds-obj.fbr-obj-code tt-fbr-gds-obj.fbr-obj-type ~
tt-fbr-gds-obj.is-cd tt-fbr-gds-obj.is-menu tt-fbr-gds-obj.is-semi-finished ~
tt-fbr-gds-obj.is-season tt-fbr-gds-obj.is-modificator ~
tt-fbr-gds-obj.is-null-price
&Scoped-define ENABLED-TABLES-IN-QUERY-Dialog-Frame tt-fbr-gds-obj
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-Dialog-Frame tt-fbr-gds-obj
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH tt-fbr-gds-obj SHARE-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH tt-fbr-gds-obj SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame tt-fbr-gds-obj
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame tt-fbr-gds-obj


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS tt-fbr-gds-obj.fbr-obj-code ~
tt-fbr-gds-obj.fbr-obj-type tt-fbr-gds-obj.is-cd tt-fbr-gds-obj.is-menu ~
tt-fbr-gds-obj.is-semi-finished tt-fbr-gds-obj.is-season ~
tt-fbr-gds-obj.is-modificator tt-fbr-gds-obj.is-null-price
&Scoped-define ENABLED-TABLES tt-fbr-gds-obj
&Scoped-define FIRST-ENABLED-TABLE tt-fbr-gds-obj
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-hist B-Help B-fbr-gds-grp ~
F-out-code B-fbr-obj
&Scoped-Define DISPLAYED-FIELDS tt-fbr-gds-obj.fbr-obj-code ~
tt-fbr-gds-obj.fbr-obj-type tt-fbr-gds-obj.is-cd tt-fbr-gds-obj.is-menu ~
tt-fbr-gds-obj.is-semi-finished tt-fbr-gds-obj.is-season ~
tt-fbr-gds-obj.is-modificator tt-fbr-gds-obj.is-null-price
&Scoped-define DISPLAYED-TABLES tt-fbr-gds-obj
&Scoped-define FIRST-DISPLAYED-TABLE tt-fbr-gds-obj
&Scoped-Define DISPLAYED-OBJECTS F-out-code f-fbr-grp-name fbr-obj-name ~
EDITOR-fbr

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Prototypes ********************** */



&IF DEFINED(EXCLUDE-check-is-petrol) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD check-is-petrol Dialog-Frame
function check-is-petrol returns logical 
  (  ) forward.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF





/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-fbr-gds-grp
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1"
     SIZE 3 BY 1.

DEFINE BUTTON B-fbr-obj
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1"
     SIZE 3 BY 1.

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-hist
     LABEL "Ис&тория"
     SIZE 10 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE EDITOR-fbr AS CHARACTER
     VIEW-AS EDITOR
     SIZE 85 BY 3.04
     BGCOLOR 15 FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE f-fbr-grp-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 45 BY 1 NO-UNDO.

DEFINE VARIABLE F-out-code LIKE ub.fbr-gds-grp.out-code
     LABEL "Код группы меню(на кассе)"
     VIEW-AS FILL-IN
     SIZE 11 BY 1 NO-UNDO.

DEFINE VARIABLE fbr-obj-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 45 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY Dialog-Frame FOR
      tt-fbr-gds-obj SCROLLING.
&ANALYZE-RESUME

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-hist AT ROW 1 COL 51
     B-Help AT ROW 1 COL 61
     B-fbr-gds-grp AT ROW 2.21 COL 27.63
     F-out-code AT ROW 2.25 COL 13.5 COLON-ALIGNED
          LABEL "Группа меню" FORMAT ">>9"
     f-fbr-grp-name AT ROW 2.25 COL 30 COLON-ALIGNED NO-LABEL
     tt-fbr-gds-obj.fbr-obj-code AT ROW 3.42 COL 13.5 COLON-ALIGNED
          LABEL "Кухня"
          VIEW-AS FILL-IN
          SIZE 7 BY 1
     tt-fbr-gds-obj.fbr-obj-type AT ROW 3.42 COL 21 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 4 BY 1
     B-fbr-obj AT ROW 3.42 COL 27.63
     fbr-obj-name AT ROW 3.42 COL 29.75 COLON-ALIGNED NO-LABEL
     EDITOR-fbr AT ROW 4.75 COL 2 NO-LABEL
     tt-fbr-gds-obj.is-cd AT ROW 8.13 COL 44
          LABEL "Отправлять на кассу РЕСТОРАНА"
          VIEW-AS TOGGLE-BOX
          SIZE 40 BY 1
     tt-fbr-gds-obj.is-menu AT ROW 8.17 COL 1.25
          LABEL "Является блюдом меню"
          VIEW-AS TOGGLE-BOX
          SIZE 40 BY 1
     tt-fbr-gds-obj.is-semi-finished AT ROW 9.38 COL 1.25
          LABEL "Является полуфабрикатом"
          VIEW-AS TOGGLE-BOX
          SIZE 40 BY 1
     tt-fbr-gds-obj.is-season AT ROW 10.58 COL 1.25
          LABEL "Применять сезонный коэффициент"
          VIEW-AS TOGGLE-BOX
          SIZE 40 BY 1
     tt-fbr-gds-obj.is-modificator AT ROW 11.79 COL 1.25
          LABEL "Модификатор блюда"
          VIEW-AS TOGGLE-BOX
          SIZE 40 BY 1
     tt-fbr-gds-obj.is-null-price AT ROW 13 COL 1.25
          LABEL "Без цены"
          VIEW-AS TOGGLE-BOX
          SIZE 40 BY 1
     SPACE(46.12) SKIP(0.32)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Атрибуты товара - РЕСТОРАН"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: buf_clients B "?" ? ub clients
      TABLE: buf_goods B "?" ? ub goods
      TABLE: loc_fbr-gds-obj B "?" ? ub fbr-gds-obj
      TABLE: tt-fbr-gds-obj T "?" NO-UNDO ub fbr-gds-obj
      TABLE: tt0-fbr-gds-obj T "?" NO-UNDO ub fbr-gds-obj
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
                                                                        */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR EDITOR EDITOR-fbr IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       EDITOR-fbr:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN f-fbr-grp-name IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN F-out-code IN FRAME Dialog-Frame
   LIKE = ub.fbr-gds-grp.out-code EXP-LABEL EXP-FORMAT                  */
/* SETTINGS FOR FILL-IN tt-fbr-gds-obj.fbr-obj-code IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN fbr-obj-name IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN tt-fbr-gds-obj.fbr-obj-type IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR TOGGLE-BOX tt-fbr-gds-obj.is-cd IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR TOGGLE-BOX tt-fbr-gds-obj.is-menu IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR TOGGLE-BOX tt-fbr-gds-obj.is-modificator IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR TOGGLE-BOX tt-fbr-gds-obj.is-null-price IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR TOGGLE-BOX tt-fbr-gds-obj.is-season IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR TOGGLE-BOX tt-fbr-gds-obj.is-semi-finished IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "Temp-Tables.tt-fbr-gds-obj"
     _Options          = "SHARE-LOCK"
     _Query            is OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Атрибуты товара - РЕСТОРАН */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Ввод */
DO:
  run proc-save in this-procedure no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-fbr-gds-grp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-fbr-gds-grp Dialog-Frame
ON CHOOSE OF B-fbr-gds-grp IN FRAME Dialog-Frame /* Btn 1 */
DO:
define variable v-recid-list    as character      no-undo.

define buffer buf_fbr-gds-grp for ub.fbr-gds-grp.
find first buf_fbr-gds-grp where
          buf_fbr-gds-grp.node-code = tt-fbr-gds-obj.fbr-grp-code
     AND  buf_fbr-gds-grp.OBJ-TYPE = tt-fbr-gds-obj.obj-type
     and  buf_fbr-gds-grp.obj-code = tt-fbr-gds-obj.obj-code no-error .
if available buf_fbr-gds-grp then do:
  assign
  v-recid-list = string(recid(buf_fbr-gds-grp))
  .
end.
    run ref/fbrggrp.w (
          input parparentproc
        , input p-obj-type
        , input p-obj-code
        , input "{&Btn_Select}"
        , input-output v-recid-list
    ).
    if v-recid-list <> ""
    then do:
        find first buf_fbr-gds-grp no-lock
             where recid( buf_fbr-gds-grp )  = integer( entry( 1, v-recid-list ) )
        no-error.
        if not available buf_fbr-gds-grp
        then do:
            return no-apply.
        end.
        assign
            f-fbr-grp-name:screen-value = buf_fbr-gds-grp.node-name
            tt-fbr-gds-obj.fbr-grp-code = buf_fbr-gds-grp.node-code
            f-out-code = buf_fbr-gds-grp.out-code
        .
        display
        f-out-code
        with frame {&frame-name}.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-fbr-obj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-fbr-obj Dialog-Frame
ON CHOOSE OF B-fbr-obj IN FRAME Dialog-Frame /* Btn 1 */
DO:
def buffer buf_clients for ub.clients .

  define variable v-user-select as logical   no-undo .
  define variable v-host-code   as integer   no-undo .
  define variable v-obj-type    as character no-undo .
  define variable v-obj-code    as integer   no-undo .

  { gbl/hostcode.i
    p-obj-type
    p-obj-code
    v-host-code
  }
  { gbl/uobjsone.i
    parparentproc
    v-cntxt-db-num
    v-cntxt-userid
    v-host-code
    p-obj-type
    p-obj-code
    v-user-select
    v-obj-type
    v-obj-code
  }
  if v-user-select = true
  then do:
    find first buf_clients no-lock
      where buf_clients.obj-type = v-obj-type
        and buf_clients.obj-code = v-obj-code
      no-error .
    if not available buf_clients then do:
      return no-apply.
    end.
    assign
      fbr-obj-name:screen-value                = buf_clients.obj-name
      tt-fbr-gds-obj.fbr-obj-code:screen-value = string(buf_clients.obj-code)
      tt-fbr-gds-obj.fbr-obj-type:screen-value = string(buf_clients.obj-type)
    .
        run fbr-warning in this-procedure (tt-fbr-gds-obj.fbr-obj-type:screen-value, tt-fbr-gds-obj.fbr-obj-code:screen-value) no-error.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-hist Dialog-Frame
ON CHOOSE OF B-hist IN FRAME Dialog-Frame /* История */
DO:
define variable v-rid-list as character no-undo.
  if available loc_fbr-gds-obj then
  run ref/cfgdsobs.w (
                                input parparentproc
                              , input "":U /*bttns*/
                              , input "one":U
                              , input p-obj-type
                              , input p-obj-code
                              , input p-gds-code
                             , output v-rid-list ) no-error.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME F-out-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL F-out-code Dialog-Frame
ON LEAVE OF F-out-code IN FRAME Dialog-Frame /* Группа меню */
DO:
     define buffer buf_fbr-gds-grp for ub.fbr-gds-grp.
   define buffer buf_clients     for ub.clients.

   find first buf_clients no-lock
        where buf_clients.obj-type = p-obj-type
          and buf_clients.obj-code = p-obj-code
   .
  find first buf_fbr-gds-grp no-lock where
             buf_fbr-gds-grp.obj-type  = p-obj-type
         AND buf_fbr-gds-grp.obj-code  = p-obj-code
         AND buf_fbr-gds-grp.out-code = input frame {&frame-name}  f-out-code
  no-error.
  if available buf_fbr-gds-grp then do:
    assign
    f-out-code
    tt-fbr-gds-obj.fbr-grp-code = buf_fbr-gds-grp.node-code
    f-fbr-grp-name = buf_fbr-gds-grp.node-name.
  end.
  else do:
      assign
    tt-fbr-gds-obj.fbr-grp-code = 0
    f-fbr-grp-name = "":U

    f-out-code = ?
    .
  end.
    display
    f-out-code
    f-fbr-grp-name
    with frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-fbr-gds-obj.fbr-obj-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-fbr-gds-obj.fbr-obj-code Dialog-Frame
ON LEAVE OF tt-fbr-gds-obj.fbr-obj-code IN FRAME Dialog-Frame /* Кухня */
DO:
 define buffer buf_shop for ub.shop.
  define buffer buf_clients for ub.clients.
  find first buf_shop no-lock where
                buf_shop.obj-code = input frame {&frame-name} tt-fbr-gds-obj.fbr-obj-code no-error.
  if available buf_shop then do:
    find first buf_clients no-lock where
                buf_clients.obj-type = {&shop}
           AND buf_clients.obj-code = buf_shop.obj-code .
    assign
    tt-fbr-gds-obj.fbr-obj-code
    tt-fbr-gds-obj.fbr-obj-type = {&shop}
    fbr-obj-name = buf_clients.obj-name.
    display
   tt-fbr-gds-obj.fbr-obj-code
    tt-fbr-gds-obj.fbr-obj-type
    fbr-obj-name
    with frame {&frame-name}.
       run fbr-warning in this-procedure (tt-fbr-gds-obj.fbr-obj-type:screen-value, tt-fbr-gds-obj.fbr-obj-code:screen-value) no-error.
  end.
  else do:
      assign
        tt-fbr-gds-obj.fbr-obj-code = 0
        tt-fbr-gds-obj.fbr-obj-type = "":U
        fbr-obj-name = "":U.
        run fbr-warning in this-procedure (tt-fbr-gds-obj.fbr-obj-type:screen-value, tt-fbr-gds-obj.fbr-obj-code:screen-value) no-error.
      if int(tt-fbr-gds-obj.fbr-obj-code:screen-value) > 0 then return no-apply.
      else tt-fbr-gds-obj.fbr-obj-type:screen-value = ''.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-fbr-gds-obj.fbr-obj-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-fbr-gds-obj.fbr-obj-type Dialog-Frame
ON LEAVE OF tt-fbr-gds-obj.fbr-obj-type IN FRAME Dialog-Frame /* fbr-obj-type */
DO:
    run fbr-warning in this-procedure (self:screen-value, tt-fbr-gds-obj.fbr-obj-code:screen-value) no-error.
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

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  
  if check-is-petrol() then do:
      message "Запрещено для топливных товаров"
      view-as alert-box ERROR.
      return error.
  end.
  
  { gbl/getcntxt.i get }
  if par-mode <> {&update}
  and par-mode <> {&add-def}
  and par-mode <> {&lookup}
  and par-mode <> 'template':U
  then do:
    message
    vss-workfile vss-revision vss-description skip
     "Неверный параметр вызова par-mode"
    view-as alert-box ERROR.
    return error.
  end.
  if par-mode <> {&add-def} then do:
    find first buf_goods no-lock where
               buf_goods.gds-code = p-gds-code no-error.
        if not available buf_goods
        and par-mode <> 'template':U
        then do:
        message
        vss-workfile vss-revision vss-description skip
        "Неверный параметр вызова p-gds-code" p-gds-code
        view-as alert-box ERROR.
        return error.
        end.
  end.
    find first buf_clients no-lock where
                    buf_clients.obj-type = p-obj-type
                AND buf_clients.obj-code = p-obj-code.
        if not available buf_clients
        or (buf_clients.obj-type <> {&shop} and buf_clients.obj-type <> {&stock})
        then do:
        message
        vss-workfile vss-revision vss-description skip
        "Неверные параметры вызова p-obj-type и/или p-obj-code" p-obj-type p-obj-code
        view-as alert-box ERROR.
        return error.
    end.
    { gbl/curdbnum.i v-db-num }
    if par-mode <> {&lookup} and
    buf_clients.db-num <> v-db-num then do:
        message
        vss-workfile vss-revision vss-description skip
        "Нельзя редактировать атрибуты товара на объекте-РЕСТОРАН для объекта чужой БД"
        view-as alert-box error.
        return error.

    end.
    case PAR-MODE:
        WHEN {&UPDATE} THEN DO:
           do transaction:
            find first loc_fbr-gds-obj exclusive-lock where
                        loc_fbr-gds-obj.gds-code = p-gds-code
                    AND loc_fbr-gds-obj.obj-type = p-obj-type
                    AND loc_fbr-gds-obj.obj-code = p-obj-code no-wait no-error.
            if not available loc_fbr-gds-obj then do:
                if locked loc_fbr-gds-obj then do:
                    message
                    "Запись атрибутов товара на объекте-РЕСТОРАН занята"
                    view-as alerT-box error.
                    return error.
                end.
                else do:
                    /*создавать не будем - создадим на выходе - если он действительно хочет*/
                end.
            end.
            assign
            par-recid = recid(loc_fbr-gds-obj)
            .
          end.
        END.
        when {&lookup} then do:
        find first loc_fbr-gds-obj no-lock where
                loc_fbr-gds-obj.gds-code = p-gds-code
            AND loc_fbr-gds-obj.obj-type = p-obj-type
            AND loc_fbr-gds-obj.obj-code = p-obj-code no-error.
        end.
        when 'template':U
        then do:
            if p-gds-code <> 0
            then do:
                find first loc_fbr-gds-obj no-lock
                     where loc_fbr-gds-obj.gds-code = p-gds-code
                       and loc_fbr-gds-obj.obj-type = p-obj-type
                       and loc_fbr-gds-obj.obj-code = p-obj-code
                no-error.
            end.
        end.        /* when 'template':U */
    end CASE.
    run fill-tables in this-procedure .
    RUN MyEnable.
    if par-mode = 'template':U
    then do:
        hide
            b-hist
            f-out-code
            b-fbr-gds-grp
        in FRAME Dialog-Frame.
        assign
            frame {&frame-name}:title = "Выбор атрибутов для группы товаров"
        .
    end.        /* if par-mode = 'template':U */
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

  {&OPEN-QUERY-Dialog-Frame}
  GET FIRST Dialog-Frame.
  DISPLAY F-out-code f-fbr-grp-name fbr-obj-name EDITOR-fbr
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-fbr-gds-obj THEN
    DISPLAY tt-fbr-gds-obj.fbr-obj-code tt-fbr-gds-obj.fbr-obj-type
          tt-fbr-gds-obj.is-cd tt-fbr-gds-obj.is-menu
          tt-fbr-gds-obj.is-semi-finished tt-fbr-gds-obj.is-season
          tt-fbr-gds-obj.is-modificator tt-fbr-gds-obj.is-null-price
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-hist B-Help B-fbr-gds-grp F-out-code
         tt-fbr-gds-obj.fbr-obj-code tt-fbr-gds-obj.fbr-obj-type B-fbr-obj
         tt-fbr-gds-obj.is-cd tt-fbr-gds-obj.is-menu
         tt-fbr-gds-obj.is-semi-finished tt-fbr-gds-obj.is-season
         tt-fbr-gds-obj.is-modificator tt-fbr-gds-obj.is-null-price
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fbr-warning Dialog-Frame
PROCEDURE fbr-warning :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-fbr-obj-type-new like ub.fbr-gds-obj.fbr-obj-type no-undo.
define input parameter p-fbr-obj-code-new like ub.fbr-gds-obj.fbr-obj-code no-undo.
if p-fbr-obj-type-new <> v-fbr-obj-type
OR p-fbr-obj-code-new <> v-fbr-obj-code then do:
    assign
    Editor-fbr = "ВНИМАНИЕ!" + {&new-line} +
                 "Смена КУХНИ для товара повлечет за собой смену КУХНИ для данного товара в атрибутах <РЕСТОРАН> на ВСЕХ объектах текущей БД," +
                 {&new-line} +
                 "однако не влечет за собой смену КУХНИ для товара в ПЛАН-МЕНЮ!!!"
                 .
    display
    editor-fbr
    with frame {&frame-name}.
end.
else do:
    hide
    editor-fbr
    in frame {&frame-name}.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-tables Dialog-Frame
PROCEDURE fill-tables :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define buffer buf0_fbr-gds-grp for ub.fbr-gds-grp.
define buffer bf_fbr-gds-grp for ub.fbr-gds-grp.
define variable v-node-code like ub.fbr-gds-grp.node-code no-undo .
define variable ii as integer no-undo .
for each tt-fbr-gds-obj:
  delete tt-fbr-gds-obj.
end.
if par-mode = {&add-def}
or (par-mode = {&update} and not available loc_fbr-gds-obj ) then do:
  if par-mode <> {&add-def} then do:
    if buf_goods.fbr-grp-code <> ? then do:
      find first buf0_fbr-gds-grp no-lock where
                buf0_fbr-gds-grp.obj-type = "":U
            AND buf0_fbr-gds-grp.obj-code = 0
            AND buf0_fbr-gds-grp.node-code = buf_goods.fbr-grp-code no-error .
      if available buf0_fbr-gds-grp then do:
        for each bf_fbr-gds-grp no-lock where
                bf_fbr-gds-grp.global-code = buf0_fbr-gds-grp.global-code
            AND bf_fbr-gds-grp.obj-type = p-obj-type
            AND bf_fbr-gds-grp.obj-code = p-obj-code:
          assign
          v-node-code = bf_fbr-gds-grp.node-code
          ii = ii + 1
          .
        end.
        if ii = 1 then do:
          find first X_fbr-gds-grp no-lock where
                    X_fbr-gds-grp.obj-type = p-obj-type
                AND X_fbr-gds-grp.obj-code = p-obj-code
                AND  X_fbr-gds-grp.node-code = v-node-code no-error .
        end.
      end.
    end.
  end.
end.
create tt-fbr-gds-obj.
case par-mode:
  when {&add-def} then do:
    assign
    tt-FBR-gds-obj.gds-code = p-gds-code
    tt-FBR-gds-obj.obj-type = p-obj-type
    tt-FBR-gds-obj.obj-code = p-obj-code
    tt-fbr-gds-obj.fbr-grp-code = v-node-code
    .
  end.
  otherwise do:
    if available loc_fbr-gds-obj then do:
      buffer-copy loc_fbr-gds-obj to TT-fbr-gds-OBJ.
    end.
    else do:
      assign
      tt-FBR-gds-obj.gds-code = p-gds-code
      tt-FBR-gds-obj.obj-type = p-obj-type
      tt-FBR-gds-obj.obj-code = p-obj-code
      tt-fbr-gds-obj.fbr-grp-code = v-node-code
      .
    end.
    create tt0-fbr-gds-obj.
    buffer-copy tt-fbr-gds-obj to TT0-fbr-gds-OBJ.
  end.
END CASE.
if p-template <> "":U then do:
  assign
  tt-fbr-gds-obj.is-cd   = logical(entry(1, p-template))
  tt-fbr-gds-obj.is-menu = logical(entry(2, p-template))
  tt-fbr-gds-obj.is-modificator = logical(entry(3, p-template))
  tt-fbr-gds-obj.is-null-price = logical(entry(4, p-template))
  tt-fbr-gds-obj.is-season     = logical(entry(5, p-template))
  tt-fbr-gds-obj.is-semi-finished  = logical(entry(6, p-template))
  tt-fbr-gds-obj.fbr-obj-type      = entry(7, p-template)
  tt-fbr-gds-obj.fbr-obj-code      = integer(entry(8, p-template))
  tt-fbr-gds-obj.fbr-grp-code      = integer(entry(9, p-template))
  .
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
define buffer other_kitchen for ub.fbr-gds-obj.
define buffer buf_shop for ub.shop.
run init-temphost in this-procedure .
find first buf_shop no-lock where
          buf_shop.obj-code = p-obj-code no-error.
if not avail loc_fbr-gds-obj then do:
  _temp-obj:
  for each temp-obj no-lock where
           temp-obj.db-num = v-db-num,
      first other_kitchen no-lock where
            other_kitchen.gds-code = p-gds-code
        AND other_kitchen.obj-type = temp-obj.obj-type
        AND other_kitchen.obj-code = temp-obj.obj-code
            :
    assign
    tt-fbr-gds-obj.fbr-obj-type = other_kitchen.fbr-obj-type
    tt-fbr-gds-obj.fbr-obj-code = other_kitchen.fbr-obj-code
    .
    find first X_clients no-lock where
              X_clients.obj-type = tt-fbr-gds-obj.fbr-obj-type
          AND X_clients.obj-code = tt-fbr-gds-obj.fbr-obj-code no-error .
    leave _temp-obj.
  end.
  assign
  frame {&frame-name}:title = frame {&frame-name}:title + {&space-char}  + title-mode({&add-def}).
end.
else do :
  find first X_fbr-gds-grp no-lock where
             X_fbr-gds-grp.obj-type = p-obj-type
         AND X_fbr-gds-grp.obj-code = p-obj-code
         AND  X_fbr-gds-grp.node-code = tt-fbr-gds-obj.fbr-grp-code no-error .
  find first X_clients no-lock where
             X_clients.obj-type = tt-fbr-gds-obj.fbr-obj-type
        AND X_clients.obj-code = tt-fbr-gds-obj.fbr-obj-code no-error .
  assign
  frame {&frame-name}:title = frame {&frame-name}:title + {&space-char}  + title-mode(par-mode).

end.
assign
v-fbr-obj-type = tt-fbr-gds-obj.fbr-obj-type
v-fbr-obj-code= tt-fbr-gds-obj.fbr-obj-code
.
  IF AVAILABLE tt-fbr-gds-obj THEN
    DISPLAY
    (if avail X_clients then X_clients.obj-name else "":U) @ fbr-obj-name
    tt-fbr-gds-obj.fbr-obj-type
    tt-fbr-gds-obj.fbr-obj-code
    tt-fbr-gds-obj.is-cd
    tt-fbr-gds-obj.is-menu
    tt-fbr-gds-obj.is-modificator
    tt-fbr-gds-obj.is-null-price
    tt-fbr-gds-obj.is-season
    tt-fbr-gds-obj.is-semi-finished
    WITH FRAME Dialog-Frame.
   DISPLAY
  (if avail X_fbr-gds-grp then X_fbr-gds-grp.node-name else "":U) @ f-fbr-grp-name
  (if avail X_fbr-gds-grp then X_fbr-gds-grp.out-code else ?) @ f-out-code
  WITH FRAME Dialog-Frame.
  ENABLE
  b-quit
  B-exit
  b-hist when available loc_fbr-gds-obj
  B-Help
  f-out-code when par-mode <> {&lookup}
  tt-fbr-gds-obj.fbr-obj-code when par-mode <> {&lookup}
  tt-fbr-gds-obj.is-menu when par-mode <> {&lookup}
  tt-fbr-gds-obj.is-modificator when par-mode <> {&lookup}
  tt-fbr-gds-obj.is-null-price when par-mode <> {&lookup}
  tt-fbr-gds-obj.is-cd when (par-mode <> {&lookup}
                        and
                      ((not buf_shop.is-kitchen and not buf_shop.is-kitchen-store )
                        or buf_shop.is-catering
                      )
                     )
  tt-fbr-gds-obj.is-season when par-mode <> {&lookup}
  tt-fbr-gds-obj.is-semi-finished when par-mode <> {&lookup}
  b-fbr-gds-grp when par-mode <> {&lookup}
  b-fbr-obj when (par-mode <> {&lookup}
                        and
                      ((not buf_shop.is-kitchen and not buf_shop.is-kitchen-store )
                        or buf_shop.is-catering
                      )
                     )
  WITH FRAME Dialog-Frame.
  IF PAR-MODE = {&LOOKUP} THEN DO:
    ASSIGN
    B-QUIT:LABEL = "&Выход"
    .
    hide
    b-exit in frame {&frame-name}.
  END.
  VIEW FRAME Dialog-Frame.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save Dialog-Frame
PROCEDURE proc-save :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable v-ident as logical no-undo .
define buffer buf_fbr-gds-grp for ub.fbr-gds-grp.
define buffer buf_inkas for ub.inkas .
define buffer buf_bar-code for ub.bar-code .
define buffer buf_chk-gds for ub.chk-gds .

assign
tt-fbr-gds-obj.is-cd                frame {&frame-name}
tt-fbr-gds-obj.is-menu
tt-fbr-gds-obj.is-season
tt-fbr-gds-obj.is-semi-finished
f-out-code
tt-fbr-gds-obj.fbr-obj-code
tt-fbr-gds-obj.fbr-obj-type
tt-fbr-gds-obj.is-modificator
tt-fbr-gds-obj.is-null-price
.
if f-out-code = ? then do:
  assign
  tt-fbr-gds-obj.fbr-grp-code = 0
  .
end.
else do:
  find buf_fbr-gds-grp no-lock where
            buf_fbr-gds-grp.obj-type = p-obj-type
      AND  buf_fbr-gds-grp.obj-code = p-obj-code
      AND buf_fbr-gds-grp.out-code = f-out-code no-error .
  if not avail buf_fbr-gds-grp then do:
    if  AMBIGUOUS buf_fbr-gds-grp then do:
      message
      "Неверный код группы меню" skip
      "Есть более одной группы мен. с кодом на кассе равным"  f-out-code
      view-as alert-box error .
      return error .
    end.
    else do:
      message
      "Неверный код группы меню"
      view-as alert-box error .
      return error .
    end.
  end.
end.

for each buf_bar-code no-lock where buf_bar-code.gds-code = buf_goods.gds-code,                             
first buf_chk-gds no-lock where (buf_chk-gds.out-code = "" or buf_chk-gds.out-code = ?)
                            and buf_chk-gds.b-code = buf_bar-code.b-code
                            :
  message
    ("Есть неучтенный чек с этим товаром " + string(buf_chk-gds.doc-code) + {&new-line} +
     "Невозможно изменить атрибуты РЕСТОРАН на товаре. Сначала удалите неучтенный чек." + {&new-line} +
     "После этого установите атрибуты РЕСТОРАН на товаре и заново примите чек с кассы.")
  view-as alert-box error .
  return error .                             
end .

for each buf_inkas no-lock where buf_inkas.obj-type = v-cntxt-obj-type
                             and buf_inkas.obj-code = v-cntxt-obj-code
                             and buf_inkas.status_ <> {&fact},
each buf_bar-code no-lock where buf_bar-code.gds-code = buf_goods.gds-code,                             
first buf_chk-gds no-lock where buf_chk-gds.out-code = buf_inkas.inkas-code
                            and buf_chk-gds.b-code = buf_bar-code.b-code
                            :
  message
    ("Есть незакрытая продажа " + string(buf_inkas.inkas-code) + 
     " с этим товаром. Чек " + string(buf_chk-gds.doc-code) + {&new-line} +
     "Невозможно изменить атрибуты РЕСТОРАН на товаре. Сначала исключите чек из незакрытой продажи и удалите его." + {&new-line} +
     "После этого установите атрибуты РЕСТОРАН на товаре и заново примите чек с кассы.")
  view-as alert-box error .
  return error .                             
end .

if available tt-fbr-gds-obj
then do:
    assign
        p-template = substitute( "&2&1&3&1&4&1&5&1&6&1&7"
                        , {&comma-char}
                        , tt-fbr-gds-obj.is-cd
                        , tt-fbr-gds-obj.is-menu
                        , tt-fbr-gds-obj.is-modificator
                        , tt-fbr-gds-obj.is-null-price
                        , tt-fbr-gds-obj.is-season
                        , tt-fbr-gds-obj.is-semi-finished
                                )
    .
    assign
        p-template = p-template
                    + substitute( "&1&2&1&3&1&4"
                        , {&comma-char}
                        , tt-fbr-gds-obj.fbr-obj-type
                        , tt-fbr-gds-obj.fbr-obj-code
                        , tt-fbr-gds-obj.fbr-grp-code
                    )
    .
    if par-mode <> 'template':U
    then do:
      if p-update-instantly then do:
        run ref/fgdsobj1.p (
                            input-output par-recid
                        , input (if available loc_fbr-gds-obj
                                    then {&update}
                                    else {&add-def})
                        , input no /*p-silent*/
                        , input p-gds-code
                        , input p-obj-type
                        , input p-obj-code
                        , input tt-fbr-gds-obj.fbr-grp-code
                        , input tt-fbr-gds-obj.fbr-obj-type
                        , input tt-fbr-gds-obj.fbr-obj-code
                        , input tt-fbr-gds-obj.is-cd
                        , input tt-fbr-gds-obj.is-menu
                        , input tt-fbr-gds-obj.is-modificator
                        , input tt-fbr-gds-obj.is-null-price
                        , input tt-fbr-gds-obj.is-season
                        , input tt-fbr-gds-obj.is-semi-finished
                        ) no-error.
        if error-status:error then do:
          if return-value <> '' then do:
            define variable v-rv as character no-undo .
            v-rv = return-value .
            entry(1, v-rv, {&new-line}) = ''.
            message
            left-trim(v-rv, {&new-line})
            view-as alert-box error.
          end.
           { gbl/reterhnd.i error }
           undo, return error.
        end.
      end.
      else do:
        if par-mode = {&add-def} then do:
          p-updated = yes.
        end.
        else do:
          buffer-compare tt0-fbr-gds-obj
          to
          tt-fbr-gds-obj
          case-sensitive
          save result in v-ident.
          assign
          p-updated = not v-ident.
        end.
      end.
    end.        /* NOT ( if par-mode = 'template':U ) */
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */



&IF DEFINED(EXCLUDE-check-is-petrol) = 0 &THEN
		
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION check-is-petrol Dialog-Frame
function check-is-petrol returns logical 
  (  ):
define variable v-is-petrolium as logical no-undo .
define variable v-is-pieces as logical no-undo .

define buffer lc_goods for ub.goods.

find first lc_goods no-lock where lc_goods.gds-code = p-gds-code.
{ str/is-petrl.i lc_goods.artic lc_goods.prod-type lc_goods.prod-code v-is-petrolium v-is-pieces }

return v-is-petrolium.

end function.
	
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF


