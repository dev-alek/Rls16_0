&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER buf_goods FOR ub.goods.
DEFINE BUFFER buf_s-coeff FOR ub.s-coeff.
DEFINE TEMP-TABLE del-s-coeff NO-UNDO LIKE ub.s-coeff.
DEFINE BUFFER loc_s-coeff FOR ub.s-coeff.
DEFINE TEMP-TABLE tree-s-coeff NO-UNDO LIKE ub.s-coeff.
DEFINE TEMP-TABLE tt-s-coeff NO-UNDO LIKE ub.s-coeff.
DEFINE TEMP-TABLE tt0-s-coeff NO-UNDO LIKE ub.s-coeff.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Сезонные коэффициенты для товара

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/09/03
Author: Bakhtadze Natalya
Creation date: 09/09/03

*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
define input parameter par-mode as character no-undo.
/*lookup, update*/
define input parameter p-gds-code like ub.s-coeff.gds-code no-undo.
/*текущий объект*/
define input parameter p-obj-type like ub.s-coeff.obj-type no-undo.
define input parameter p-obj-code like ub.s-coeff.obj-code no-undo.
define input parameter p-update-instantly as logical no-undo .
define output parameter p-updated         as logical no-undo .
define input-output parameter table for tt0-s-coeff.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Сезонные коэффициенты для товара".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }
{ gbl/waitfram.i }
{ trg/factord.i  }
{ gbl/cur-time.i }
{ gbl/getcntxt.i def }
{ gbl/usrfulnf.i }
define variable v-host-code like ub.sysconf.host-code no-undo.
define variable add-option as character no-undo.
define variable v-recid as recid no-undo.
define variable v-db-num like ub.db.db-num no-undo.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-coeff

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-s-coeff tree-s-coeff

/* Definitions for BROWSE BR-coeff                                      */
&Scoped-define FIELDS-IN-QUERY-BR-coeff get-date(tt-s-coeff.s-date) tt-s-coeff.coeff-value get-region(tt-s-coeff.host-code, tt-s-coeff.obj-type, tt-s-coeff.obj-code)
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-coeff
&Scoped-define SELF-NAME BR-coeff
&Scoped-define QUERY-STRING-BR-coeff FOR EACH tt-s-coeff     BY tt-s-coeff.s-date
&Scoped-define OPEN-QUERY-BR-coeff OPEN QUERY {&SELF-NAME} FOR EACH tt-s-coeff     BY tt-s-coeff.s-date.
&Scoped-define TABLES-IN-QUERY-BR-coeff tt-s-coeff
&Scoped-define FIRST-TABLE-IN-QUERY-BR-coeff tt-s-coeff


/* Definitions for BROWSE BR-tree                                       */
&Scoped-define FIELDS-IN-QUERY-BR-tree get-date(tree-s-coeff.s-date) get-region(tree-s-coeff.host-code, tree-s-coeff.obj-type, tree-s-coeff.obj-code) tree-s-coeff.coeff-value usrfulnf(tree-s-coeff.creid) tree-s-coeff.credate
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-tree
&Scoped-define SELF-NAME BR-tree
&Scoped-define QUERY-STRING-BR-tree FOR EACH tree-s-coeff SHARE-LOCK
&Scoped-define OPEN-QUERY-BR-tree OPEN QUERY {&SELF-NAME} FOR EACH tree-s-coeff SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-BR-tree tree-s-coeff
&Scoped-define FIRST-TABLE-IN-QUERY-BR-tree tree-s-coeff


/* Definitions for DIALOG-BOX Dialog-Frame                              */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-exit B-add B-chg B-del B-hist ~
B-Help BR-coeff BR-tree

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-date Dialog-Frame
FUNCTION get-date RETURNS CHARACTER
  ( p-s-date as date )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-mark Dialog-Frame
FUNCTION get-mark RETURNS CHARACTER
  ( input par-ismarked as logical, input par-rid as recid, input par-s-coeff-rid as character )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-region Dialog-Frame
FUNCTION get-region RETURNS CHARACTER
  ( input parhost-code as integer, input parobj-type as character, input parobj-code as integer )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Menu Definitions                                                     */
DEFINE MENU MENU-B-add
       MENU-ITEM m_global       LABEL "Глобальная"
       MENU-ITEM m_host         LABEL "Фирма"
       MENU-ITEM m_object       LABEL "Объект"        .

DEFINE MENU MENU-B-add-2
       MENU-ITEM m_global-2     LABEL "Глобальная"
       MENU-ITEM m_host-2       LABEL "Фирма"
       MENU-ITEM m_object-2     LABEL "Объект"        .

DEFINE MENU MENU-B-add-3
       MENU-ITEM m_global-3     LABEL "Глобальная"
       MENU-ITEM m_host-3       LABEL "Фирма"
       MENU-ITEM m_object-3     LABEL "Объект"        .

DEFINE MENU MENU-B-add-4
       MENU-ITEM m_global-4     LABEL "Глобальная"
       MENU-ITEM m_host-4       LABEL "Фирма"
       MENU-ITEM m_object-4     LABEL "Объект"        .


/* Definitions of the field level widgets                               */
DEFINE BUTTON B-add
     LABEL "&Добавить"
     SIZE 10 BY 1.

DEFINE BUTTON B-chg
     LABEL "&Изменить"
     SIZE 10 BY 1.

DEFINE BUTTON B-del
     LABEL "&Удалить"
     SIZE 10 BY 1.

DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-hist
     LABEL "Ис&тория"
     SIZE 3 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-coeff FOR
      tt-s-coeff SCROLLING.

DEFINE QUERY BR-tree FOR
      tree-s-coeff SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-coeff
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-coeff Dialog-Frame _FREEFORM
  QUERY BR-coeff DISPLAY
      get-date(tt-s-coeff.s-date) column-label "Дата" format "X(5)"
      tt-s-coeff.coeff-value column-label "Значение" format ">9.999%"
      get-region(tt-s-coeff.host-code, tt-s-coeff.obj-type, tt-s-coeff.obj-code) column-label "Обл.действия" format "X(12)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 29 BY 18
         TITLE "Значения для объекта".

DEFINE BROWSE BR-tree
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-tree Dialog-Frame _FREEFORM
  QUERY BR-tree SHARE-LOCK NO-WAIT DISPLAY
      get-date(tree-s-coeff.s-date)
      get-region(tree-s-coeff.host-code, tree-s-coeff.obj-type, tree-s-coeff.obj-code) COLUMN-LABEL "Обл.действия" FORMAT "X(12)":U
      tree-s-coeff.coeff-value FORMAT ">9.999%":U
      usrfulnf(tree-s-coeff.creid) FORMAT "X(10)":U
      tree-s-coeff.credate FORMAT "99/99/9999":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 53.4 BY 18
         TITLE "Все значения".


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-exit AT ROW 1 COL 11
     B-add AT ROW 1 COL 31
     B-chg AT ROW 1 COL 41
     B-del AT ROW 1 COL 51
     B-hist AT ROW 1 COL 79
     B-Help AT ROW 1 COL 82
     BR-coeff AT ROW 3 COL 1
     BR-tree AT ROW 3 COL 31
     SPACE(0.59) SKIP(1.03)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Сезон. коэфф. для товара"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: buf_goods B "?" ? ub goods
      TABLE: buf_s-coeff B "?" ? ub s-coeff
      TABLE: del-s-coeff T "?" NO-UNDO ub s-coeff
      TABLE: loc_s-coeff B "?" ? ub s-coeff
      TABLE: tree-s-coeff T "?" NO-UNDO ub s-coeff
      TABLE: tt-s-coeff T "?" NO-UNDO ub s-coeff
      TABLE: tt0-s-coeff T "?" NO-UNDO ub s-coeff
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BR-coeff B-Help Dialog-Frame */
/* BROWSE-TAB BR-tree BR-coeff Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       B-add:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-B-add:HANDLE.

ASSIGN
       B-chg:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-B-add-3:HANDLE.

ASSIGN
       B-del:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-B-add-4:HANDLE.

ASSIGN
       B-hist:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-B-add-2:HANDLE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-coeff
/* Query rebuild information for BROWSE BR-coeff
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-s-coeff
    BY tt-s-coeff.s-date.
     _END_FREEFORM
     _OrdList          = "Temp-Tables.tt-s-coeff.s-date|yes"
     _Query            is NOT OPENED
*/  /* BROWSE BR-coeff */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-tree
/* Query rebuild information for BROWSE BR-tree
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tree-s-coeff SHARE-LOCK.
     _END_FREEFORM
     _Options          = "SHARE-LOCK"
     _Query            is NOT OPENED
*/  /* BROWSE BR-tree */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Сезон. коэфф. для товара */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-add Dialog-Frame
ON CHOOSE OF B-add IN FRAME Dialog-Frame /* Добавить */
DO:
  if add-option = "":U then do:
    run gbl/pop-up.p (self:handle, no) no-error.
    if error-status:error then return no-apply.
  end.
  if add-option = "":U then return no-apply.
  run proc-b-add in this-procedure (add-option) no-error   .
  if error-status:error then do:
    add-option = "":U.
     return no-apply.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-chg Dialog-Frame
ON CHOOSE OF B-chg IN FRAME Dialog-Frame /* Изменить */
DO:
run proc-b-chg in this-procedure no-error.
if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-del Dialog-Frame
ON CHOOSE OF B-del IN FRAME Dialog-Frame /* Удалить */
DO:
  if not available tree-s-coeff then return no-apply.
  run proc-b-del in this-procedure no-error.
  if error-status:error then return no-apply.
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


&Scoped-define SELF-NAME B-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-hist Dialog-Frame
ON CHOOSE OF B-hist IN FRAME Dialog-Frame /* История */
DO:
define variable v-rid-list as character no-undo .
if available loc_s-coeff THEN
run ref/cgdshist.w (
                  input parparentproc
                , input v-host-code /*p-curr-host-code*/
                , input p-obj-type  /*p-curr-obj-type*/
                , input p-obj-code  /*p-curr-obj-code*/
                , input "":U /*bttns*/
                , "subject":U /*p-mode*/
                , input p-gds-code
                , input ? /*p-host-code*/
                , input p-obj-type /*p-obj-type*/
                , input p-obj-code /*p-obj-code*/
                , input ? /* p-corr-user-db-num  */
                , input "":U /* p-corr-user-name  */
                , input {&table_s-coeff} /* p-subject  */
                , input v-cntxt-db-num /* p-db-num */
                , input-output v-rid-list  ) no-error .

    apply "entry" to br-coeff.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_global
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_global Dialog-Frame
ON CHOOSE OF MENU-ITEM m_global /* Глобальная */
DO:
  add-option = "GLOBAL":U.
  run proc-b-add in this-procedure(add-option) No-ERROR.
  if error-status:error then do:
    add-option = "":U.
    return no-apply.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_global-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_global-2 Dialog-Frame
ON CHOOSE OF MENU-ITEM m_global-2 /* Глобальная */
DO:
  add-option = "GLOBAL":U.
  run proc-b-add in this-procedure(add-option) No-ERROR.
  if error-status:error then do:
    add-option = "":U.
    return no-apply.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_global-3
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_global-3 Dialog-Frame
ON CHOOSE OF MENU-ITEM m_global-3 /* Глобальная */
DO:
  add-option = "GLOBAL":U.
  run proc-b-add in this-procedure(add-option) No-ERROR.
  if error-status:error then do:
    add-option = "":U.
    return no-apply.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_global-4
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_global-4 Dialog-Frame
ON CHOOSE OF MENU-ITEM m_global-4 /* Глобальная */
DO:
  add-option = "GLOBAL":U.
  run proc-b-add in this-procedure(add-option) No-ERROR.
  if error-status:error then do:
    add-option = "":U.
    return no-apply.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_host
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_host Dialog-Frame
ON CHOOSE OF MENU-ITEM m_host /* Фирма */
DO:
  add-option = "HOST":U.
  run proc-b-add in this-procedure(add-option) No-ERROR.
  if error-status:error then do:
    add-option = "":U.
    return no-apply.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_host-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_host-2 Dialog-Frame
ON CHOOSE OF MENU-ITEM m_host-2 /* Фирма */
DO:
  add-option = "HOST":U.
  run proc-b-add in this-procedure(add-option) No-ERROR.
  if error-status:error then do:
    add-option = "":U.
    return no-apply.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_host-3
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_host-3 Dialog-Frame
ON CHOOSE OF MENU-ITEM m_host-3 /* Фирма */
DO:
  add-option = "HOST":U.
  run proc-b-add in this-procedure(add-option) No-ERROR.
  if error-status:error then do:
    add-option = "":U.
    return no-apply.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_host-4
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_host-4 Dialog-Frame
ON CHOOSE OF MENU-ITEM m_host-4 /* Фирма */
DO:
  add-option = "HOST":U.
  run proc-b-add in this-procedure(add-option) No-ERROR.
  if error-status:error then do:
    add-option = "":U.
    return no-apply.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_object
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_object Dialog-Frame
ON CHOOSE OF MENU-ITEM m_object /* Объект */
DO:
  add-option = "OBJECT":U.
  run proc-b-add in this-procedure(add-option) No-ERROR.
  if error-status:error then do:
    add-option = "":U.
    return no-apply.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_object-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_object-2 Dialog-Frame
ON CHOOSE OF MENU-ITEM m_object-2 /* Объект */
DO:
  add-option = "OBJECT":U.
  run proc-b-add in this-procedure(add-option) No-ERROR.
  if error-status:error then do:
    add-option = "":U.
    return no-apply.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_object-3
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_object-3 Dialog-Frame
ON CHOOSE OF MENU-ITEM m_object-3 /* Объект */
DO:
  add-option = "OBJECT":U.
  run proc-b-add in this-procedure(add-option) No-ERROR.
  if error-status:error then do:
    add-option = "":U.
    return no-apply.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_object-4
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_object-4 Dialog-Frame
ON CHOOSE OF MENU-ITEM m_object-4 /* Объект */
DO:
  add-option = "OBJECT":U.
  run proc-b-add in this-procedure(add-option) No-ERROR.
  if error-status:error then do:
    add-option = "":U.
    return no-apply.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-coeff
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
  if par-mode <> {&update}
  and  par-mode <> {&lookup}
  and  par-mode <> {&add-def}
  then do:
        message
    vss-workfile vss-revision vss-description skip
     "Неверный параметр вызова par-mode" par-mode
    view-as alert-box ERROR.
    return error.
  end.
  if par-mode <> {&add-def} then do:
    find first buf_goods no-lock where
                  buf_goods.gds-code = p-gds-code.
  end.
  { gbl/hostcode.i p-obj-type p-obj-code v-host-code }
  /*заблокируем первую запись если надо*/
  if par-mode = {&update} then do:
    find first loc_s-coeff exclusive-lock where
                 loc_s-coeff.gds-code = p-gds-code
           AND loc_s-coeff.s-date = {&s-coeff-start-date}
           AND loc_s-coeff.host-code = 0
           AND loc_s-coeff.obj-type = "":U
           AND loc_s-coeff.obj-code = 0 no-wait no-error.
    if locked loc_s-coeff then do:
        message
        "Записи сезонных коэффициентов к товару сейчас  заняты" skip
        "редактирование невозможно"
        view-as alert-box warning.
        return.
    end.
    if not available loc_s-coeff then do:
        /*создадим*/
        run ref/scoeff01.p (
                               input-output v-recid
                               ,input {&add-def}
                               ,input p-gds-code
                               ,input 0
                               ,input "":U
                               ,input 0
                               ,input {&s-coeff-start-date}
                               ,input 0
                                ).
        if v-recid <> ? then do:
            find first loc_s-coeff where recid(loc_s-coeff) = v-recid exclusive-lock.
        end.
    end.
  end.
  { gbl/curdbnum.i v-db-num }
  run fill-tables in this-procedure.
  RUN MyEnable.
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
  ENABLE b-quit B-exit B-add B-chg B-del B-hist B-Help BR-coeff BR-tree 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
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
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable v-s-date like ub.s-coeff.s-date no-undo .
define variable v-i as integer no-undo .
define buffer buf_tt-s-coeff for tt-s-coeff.
define buffer buf_tt0-s-coeff for tt0-s-coeff.
run cur-time in this-procedure(output v-today, output v-time).
for each tt-s-coeff:
  delete tt-s-coeff.
end.
for each tree-s-coeff:
  delete tree-s-coeff.
end.

/*пройдемся по объекту - если есть уже глобальные или фирменные на эту дату - перепишем*/
for each buf_tt0-s-coeff no-lock where
            buf_tt0-s-coeff.gds-code = p-gds-code
       AND buf_tt0-s-coeff.host-code = v-host-code
       AND buf_tt0-s-coeff.obj-type = p-obj-type
       AND buf_tt0-s-coeff.obj-code = p-obj-code
by buf_tt0-s-coeff.s-date :
    find first buf_tt-s-coeff where
                buf_tt-s-coeff.gds-code = p-gds-code
           AND buf_tt-s-coeff.s-date = buf_tt0-s-coeff.s-date no-error.
    if not available buf_tt-s-coeff then do:
        create buf_tt-s-coeff.
    end.
    buffer-copy buf_tt0-s-coeff to buf_tt-s-coeff.
     release buf_tt-s-coeff.
   if v-i = 0 then do:
     assign
     v-s-date = buf_tt0-s-coeff.s-date
     .
   end.
   assign
   v-i = v-i + 1
   .
end.

assign
v-i = 0
.
/*пройдемся по фирмам - если есть уже глобальные на эту дату - перепишем*/
for each buf_tt0-s-coeff no-lock where
            buf_tt0-s-coeff.gds-code = p-gds-code
       AND buf_tt0-s-coeff.host-code = v-host-code
       AND buf_tt0-s-coeff.obj-type = "":U
AND buf_tt0-s-coeff.obj-code = 0
AND ( v-s-date = ?  or buf_tt0-s-coeff.s-date < v-s-date)
by buf_tt0-s-coeff.s-date
:
    find first buf_tt-s-coeff where
                buf_tt-s-coeff.gds-code = p-gds-code
           AND buf_tt-s-coeff.s-date = buf_tt0-s-coeff.s-date no-error.
    if not available buf_tt-s-coeff then do:
        create buf_tt-s-coeff.
    end.
    buffer-copy buf_tt0-s-coeff to buf_tt-s-coeff
    .
      release buf_tt-s-coeff.
   if v-i = 0 then do:
     assign
     v-s-date = buf_tt0-s-coeff.s-date
     .
   end.
   assign
   v-i = v-i + 1
   .
end.
assign
v-i = 0
.
/*пройдемся по глобальным*/
for each buf_tt0-s-coeff no-lock where
            buf_tt0-s-coeff.gds-code = p-gds-code
       AND buf_tt0-s-coeff.host-code  = 0
AND (v-s-date = ?  or buf_tt0-s-coeff.s-date < v-s-date)
by buf_tt0-s-coeff.s-date
       :
    create tt-s-coeff.
    buffer-copy buf_tt0-s-coeff to tt-s-coeff
    .
    release tt-s-coeff.
end.
/*на текущий момент должны в tt-s-coeff лежать все значения по всем датам по этому товару*/
/*проверим там вообще чего-нибудь лежит или это новый товар для сезонного коэфф*/
find first buf_tt-s-coeff no-error.
if not available buf_tt-s-coeff then do:
      create tt-s-coeff.
    assign
    tt-s-coeff.gds-code = p-gds-code
    tt-s-coeff.host-code = 0
    tt-s-coeff.obj-type = "":U
    tt-s-coeff.obj-code = 0
    tt-s-coeff.s-date = {&s-coeff-start-date}
    tt-s-coeff.coeff-value = 0
    tt-s-coeff.credate = v-today
    tt-s-coeff.creid = v-cntxt-userid
    .
end.
for each buf_tt0-s-coeff no-lock:
    create tree-s-coeff.
    buffer-copy buf_tt0-s-coeff to tree-s-coeff
    .
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Myenable Dialog-Frame 
PROCEDURE Myenable :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
ASSIGN
b-add :MENU-MOUSE in frame {&frame-name}= 1.
if v-db-num <> 0 then do:
    menu-item m_global:sensitive in menu MENU-B-add = no  .
    menu-item m_host:sensitive in menu MENU-B-add = no  .
end.
ENABLE
b-quit
B-exit
B-add when par-mode <> {&lookup}
b-chg when par-mode <> {&lookup}
b-del when par-mode <> {&lookup}
B-Help
b-hist
BR-coeff
BR-tree
WITH FRAME Dialog-Frame.
VIEW FRAME Dialog-Frame.
if par-mode = {&lookup} then do:
  hide
  b-exit
  in frame {&frame-name}.
  assign
  b-quit:label = "&Выход"
  .
end.

assign
frame {&frame-name}:title = frame {&frame-name}:title + {&space-char} +
                            (if available buf_goods then string(buf_goods.gds-code)  else "":U)  + {&space-char} +
                            (if available buf_goods then string(buf_goods.gds-name, "X(30)") else "":U) + {&space-char} +
                            p-obj-type  + string(p-obj-code).
Run OpenBr in this-procedure.
Run OpenBrTree in this-procedure.

APPLY "ENTRY" to br-coeff.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBr Dialog-Frame 
PROCEDURE OpenBr :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:

------------------------------------------------------------------------------*/
Open QUery br-coeff for each tt-s-coeff
by tt-s-coeff.gds-code
by tt-s-coeff.s-date
.
APPLY "VALUE-CHANGED" to br-coeff in frame {&frame-name}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBrTree Dialog-Frame 
PROCEDURE OpenBrTree :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    Open Query br-tree
    for each tree-s-coeff No-LOCK where
                 tree-s-coeff.gds-code = p-gds-code
            use-index idate
        .
APPLY "entry" to br-coeff in frame {&frame-name}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-add Dialog-Frame 
PROCEDURE proc-b-add :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-option as character no-undo.
define variable v-result as character no-undo.
CASE p-option:
  when "global":U then do:
        run ref/scoeffi.w (       input parparentproc
                            ,input {&add-def}
                            ,input p-gds-code
                            ,input  0
                            ,input "":U
                            ,input 0
                            ,input-output TABLE tt-s-coeff
                            ,input-output table tree-s-coeff
                            ,output v-result
                            ) no-error.

    end.
    when "host":U then do:
        run ref/scoeffi.w (       input parparentproc
                            ,input {&add-def}
                            ,input p-gds-code
                            ,input  v-host-code
                            ,input "":U
                            ,input 0
                            ,input-output TABLE tt-s-coeff
                            ,input-output table tree-s-coeff
                            ,output v-result
                            ) no-error.

    end.
    when "object":U then do:
        run ref/scoeffi.w (       input parparentproc
                            ,input {&add-def}
                            ,input p-gds-code
                            ,input  v-host-code
                            ,input p-obj-type
                            ,input p-obj-code
                            ,input-output TABLE tt-s-coeff
                            ,input-output table tree-s-coeff
                            ,output v-result
                            ) no-error.
    end.

END CASE.
if error-status:error then do:
    return error.
end.
 find first del-s-coeff where
              del-s-coeff.gds-code = tree-s-coeff.gds-code
         AND   del-s-coeff.host-code = tree-s-coeff.host-code
         AND   del-s-coeff.obj-type = tree-s-coeff.obj-type
         AND   del-s-coeff.obj-code = tree-s-coeff.obj-code
         AND   del-s-coeff.s-date = tree-s-coeff.s-date
         no-error.
  if available del-s-coeff then do:
    delete del-s-coeff.
  end.
run OpenBr in this-procedure.
run OpenBrTree in this-procedure.
reposition br-coeff  to recid integer(v-result) no-error.
APPLY "ENTRY" to br-coeff in frame {&frame-name}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-chg Dialog-Frame 
PROCEDURE proc-b-chg :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable v-coeff-value as character no-undo .
define buffer loc_clients for ub.clients.
define buffer buf_tt-s-coeff  for tt-s-coeff.
if not available tree-s-coeff then return no-apply.
/*по фирме - только в ГБД*/
if (tree-s-coeff.host-code = 0
OR tree-s-coeff.obj-type = "":U
OR tree-s-coeff.obj-code = 0)
AND v-db-num <> 0
then do:
  message
  "Глобальные записи и записи по фирме можно редактировать только в ГБД"
  view-as alert-box error .
  undo, return error.
end.
if tree-s-coeff.obj-type <> "":U
or tree-s-coeff.obj-code <> 0 then do:
  find first loc_clients no-lock where
             loc_clients.obj-type = tree-s-coeff.obj-type
         AND loc_clients.obj-code = tree-s-coeff.obj-code no-error .
  if available loc_clients and
  loc_clients.db-num <> v-db-num then do:
    message
    "Записи по объектам можно редактировать только в той БД, к которой они принадлежат"
    view-as alert-box  error .
    undo, return error.
  end.
end.

assign
v-coeff-value = string(tree-s-coeff.coeff-value, ">9.999%")
.
  run gbl/d-prompt.w (
    'title=':u + "Изменение значения сезонного коэффициента" + '\':u
  + 'format=' + ">9.999%":U + '\':u
  + 'type=' + {&type-dec} + '\':u
  + 'fillin_row=2\':u
  + 'fillin_col=4\':u
  + 'fillin_width=20\':u
  + 'fillin_height=1\':u
  + 'max-chars=70\':u     /*- максимальное количество символов для редактора*/
  + 'readonly=no':u + '\':u
  , input-output v-coeff-value
      ).
if return-value = 'false':u then return no-apply.
do
on error undo, return error
:
  assign
  tree-s-coeff.coeff-value = decimal(trim(v-coeff-value, "%":U))
  v-recid  = recid(tree-s-coeff)
  .
  find first buf_tt-s-coeff where
             buf_tt-s-coeff.s-date = tree-s-coeff.s-date
         AND buf_tt-s-coeff.gds-code = tree-s-coeff.gds-code
         AND buf_tt-s-coeff.host-code = tree-s-coeff.host-code
         AND buf_tt-s-coeff.obj-type = tree-s-coeff.obj-type
         AND buf_tt-s-coeff.obj-code = tree-s-coeff.obj-code no-error .
  if avail buf_tt-s-coeff then do:
    assign
    buf_tt-s-coeff.coeff-value = tree-s-coeff.coeff-value
    .
  end.


end.
run OpenBr in this-procedure.
run OpenBrTree in this-procedure.
reposition br-coeff  to recid v-recid no-error.

APPLY "ENTRY" to br-coeff in frame {&frame-name}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-del Dialog-Frame 
PROCEDURE proc-b-del :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define buffer loc_clients   for ub.clients.

  if tree-s-coeff.host-code = 0
  AND tree-s-coeff.host-code = 0
AND tree-s-coeff.obj-type = "":U
AND tree-s-coeff.obj-code = 0
AND tree-s-coeff.s-date = {&s-coeff-start-date} then do:
    message
    "Нельзя удалить корневую запись сезонного коэффициента"
    view-as alert-box error.
    return error.
end.
/*по фирме - только в ГБД*/
if (tree-s-coeff.host-code = 0
OR tree-s-coeff.obj-type = "":U
OR tree-s-coeff.obj-code = 0)
AND v-db-num <> 0
then do:
  message
  "Глобальные записи и записи по фирме можно удалять только в ГБД"
  view-as alert-box error .
  undo, return error.
end.
if tree-s-coeff.obj-type <> "":U
or tree-s-coeff.obj-code <> 0 then do:
  find first loc_clients no-lock where
             loc_clients.obj-type = tree-s-coeff.obj-type
         AND loc_clients.obj-code = tree-s-coeff.obj-code no-error .
  if available loc_clients and
  loc_clients.db-num <> v-db-num then do:
    message
    "Записи по объектам можно удалять только в той БД, к которой они принадлежат"
    view-as alert-box  error .
    undo, return error.
  end.
end.


  find first del-s-coeff where
              del-s-coeff.gds-code = tree-s-coeff.gds-code
         AND   del-s-coeff.host-code = tree-s-coeff.host-code
         AND   del-s-coeff.obj-type = tree-s-coeff.obj-type
         AND   del-s-coeff.obj-code = tree-s-coeff.obj-code
         AND   del-s-coeff.s-date = tree-s-coeff.s-date
         no-error.
  if not available del-s-coeff then do:
    create del-s-coeff.
    buffer-copy tree-s-coeff to del-s-coeff.
  end.
  delete tree-s-coeff.
    run OpenBrTree in this-procedure no-error.
    if error-status:error then return error.
    APPLY "ENTRY" to br-tree in frame {&frame-name}.

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
define variable v-deleted as logical no-undo .
define variable v-updated as logical no-undo .
define buffer buf_tt0-s-coeff for tt0-s-coeff.
do
on error undo, return error
:

for each del-s-coeff :
   find first buf_tt0-s-coeff  where
              buf_tt0-s-coeff.gds-code = del-s-coeff.gds-code
          AND buf_tt0-s-coeff.host-code = del-s-coeff.host-code
          AND buf_tt0-s-coeff.obj-type = del-s-coeff.obj-type
          AND buf_tt0-s-coeff.obj-code = del-s-coeff.obj-code
          AND buf_tt0-s-coeff.s-date = del-s-coeff.s-date
        no-error.
    if available buf_tt0-s-coeff then do:
        delete buf_tt0-s-coeff.
        v-deleted = yes.
    end.
end.
ASSIGN
p-updated = v-deleted OR p-updated.

for each tree-s-coeff :
   find first buf_tt0-s-coeff no-lock where
                    buf_tt0-s-coeff.gds-code = tree-s-coeff.gds-code
               AND buf_tt0-s-coeff.host-code = tree-s-coeff.host-code
AND buf_tt0-s-coeff.obj-type = tree-s-coeff.obj-type
AND buf_tt0-s-coeff.obj-code = tree-s-coeff.obj-code
AND buf_tt0-s-coeff.s-date = tree-s-coeff.s-date
no-error.
if not available buf_tt0-s-coeff then do:
  create buf_tt0-s-coeff.
  buffer-copy tree-s-coeff except gds-code to buf_tt0-s-coeff
  assign
  buf_tt0-s-coeff.gds-code = p-gds-code
  v-updated = yes
  .
end.
else do:
  if buf_tt0-s-coeff.coeff-value <> tree-s-coeff.coeff-value then do:
    assign
    buf_tt0-s-coeff.coeff-value = tree-s-coeff.coeff-value
    v-updated = yes.
 end.
end.
end.
ASSIGN
p-updated = v-updated OR p-updated.
if p-updated
and p-update-instantly then do:
  run ref/s-coeff1.p (
                     input par-mode
                    ,input p-gds-code
                    ,input v-host-code
                    ,input p-obj-type
                    ,input p-obj-code
                    ,INPUT table tt0-s-coeff
                    ) no-error .
  if error-status:error then do:
    message
    substitute("Ошибка при сохранении сезонных коэффициентов товара:&1&2&1&3"
               , {&new-line}
               , error-status:get-message(1)
               , return-value )
    view-as alert-box
    error .
    undo, return error .
  end.
end.
end. /*doe*/

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-date Dialog-Frame 
FUNCTION get-date RETURNS CHARACTER
  ( p-s-date as date ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
define variable v-day as integer no-undo.
define variable v-month as integer no-undo.

    if p-s-date = ? then return {&question-mark}.

  RETURN (string(day(p-s-date)) + {&slash-char} + string(month(p-s-date), "99":U)).   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-mark Dialog-Frame 
FUNCTION get-mark RETURNS CHARACTER
  ( input par-ismarked as logical, input par-rid as recid, input par-s-coeff-rid as character ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/

  define variable var-mark as character no-undo.
var-mark = IF par-ismarked and  CAN-DO (string(par-s-coeff-rid), string( par-rid )) THEN ("*") ELSE (" ").
return var-mark.

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-region Dialog-Frame 
FUNCTION get-region RETURNS CHARACTER
  ( input parhost-code as integer, input parobj-type as character, input parobj-code as integer ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/

  define variable par-region as character no-undo.
  if parhost-code = 0 and
       parobj-type = "":U and
       parobj-code = 0 then do:
       par-region = "Глобально".
       return par-region.
    end.
    if parobj-type = "" and
       parobj-code = 0 then do:
       par-region = fill({&space-char}, 2) + "Фирма" + {&space-char} + string(parhost-code).
       return par-region.
    end.
    par-region = fill({&space-char}, 4) + parobj-type + {&space-char} + string(parobj-code).
    return par-region.


END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

