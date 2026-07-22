&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME d-scalesi

/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER locked_scales FOR ub.scales.
DEFINE TEMP-TABLE tt-scales NO-UNDO LIKE ub.scales.


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS d-scalesi
/*не забыть поменять навание фрейма ВЕСЫ на препроцессинг {&scales}!!!!*/

/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Карточка весов

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/07/05
Author: Bakhtadze Natalya
Creation date: 10/07/05

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define input parameter p-mode as char no-undo .
define input parameter p-db-num like ub.db.db-nu  no-undo .
define input parameter p-scales-num like ub.scales.scales-num no-undo .
define output parameter p-rid as recid no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Карточка весов".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/showinf.i }
{ cmp/library.i }
{ gbl/getcntxt.i def }

define buffer b-scales for ub.scales .

define variable ini-types as char no-undo init ?.
define variable ini-model as char no-undo .

define variable ii as int no-undo .
/*
define variable conf-attr as char no-undo.  /* для чтения параметра конфигурации */
define variable conf-par as char no-undo.  /* для чтения параметра конфигурации */
define variable par-type as char no-undo.
*/
define variable glog as logical no-undo .
define variable v-rid as recid no-undo .
define variable v-param-type as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-tth as handle no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME d-scalesi

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES ub.scales tt-scales

/* Definitions for DIALOG-BOX d-scalesi                                 */
&Scoped-define FIELDS-IN-QUERY-d-scalesi tt-scales.scales-num ~
tt-scales.master tt-scales.scales-name tt-scales.max-gds tt-scales.address ~
tt-scales.unit-base
&Scoped-define ENABLED-FIELDS-IN-QUERY-d-scalesi tt-scales.scales-num ~
tt-scales.master tt-scales.scales-name tt-scales.max-gds tt-scales.address ~
tt-scales.unit-base
&Scoped-define ENABLED-TABLES-IN-QUERY-d-scalesi tt-scales
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-d-scalesi tt-scales
&Scoped-define QUERY-STRING-d-scalesi FOR EACH ub.scales SHARE-LOCK, ~
      EACH tt-scales WHERE TRUE /* Join to ub.scales incomplete */ SHARE-LOCK
&Scoped-define OPEN-QUERY-d-scalesi OPEN QUERY d-scalesi FOR EACH ub.scales SHARE-LOCK, ~
      EACH tt-scales WHERE TRUE /* Join to ub.scales incomplete */ SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-d-scalesi ub.scales tt-scales
&Scoped-define FIRST-TABLE-IN-QUERY-d-scalesi ub.scales
&Scoped-define SECOND-TABLE-IN-QUERY-d-scalesi tt-scales


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS tt-scales.scales-num tt-scales.master ~
tt-scales.scales-name tt-scales.max-gds tt-scales.address ~
tt-scales.unit-base
&Scoped-define ENABLED-TABLES tt-scales
&Scoped-define FIRST-ENABLED-TABLE tt-scales
&Scoped-Define ENABLED-OBJECTS B-exit B-quit b-attr B-help RECT-1 S-type ~
r-base
&Scoped-Define DISPLAYED-FIELDS tt-scales.scales-num tt-scales.master ~
tt-scales.scales-name tt-scales.max-gds tt-scales.address ~
tt-scales.unit-base
&Scoped-define DISPLAYED-TABLES tt-scales
&Scoped-define FIRST-DISPLAYED-TABLE tt-scales
&Scoped-Define DISPLAYED-OBJECTS S-type

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-attr
     LABEL "&Атрибуты"
     SIZE 10 BY 1.

DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON r-base
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 72.75 BY 16.25.

DEFINE VARIABLE S-type AS CHARACTER
     VIEW-AS SELECTION-LIST SINGLE SCROLLBAR-VERTICAL
     SIZE 18.25 BY 9
     BGCOLOR 15  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY d-scalesi FOR
      ub.scales,
      tt-scales SCROLLING.
&ANALYZE-RESUME

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME d-scalesi
     B-exit AT ROW 1 COL 1
     B-quit AT ROW 1 COL 11
     b-attr AT ROW 1 COL 37
     B-help AT ROW 1 COL 73
     tt-scales.scales-num AT ROW 3 COL 14.88 COLON-ALIGNED
          LABEL "Номер"
          VIEW-AS FILL-IN
          SIZE 7 BY 1
     tt-scales.master AT ROW 4.25 COL 14.88 COLON-ALIGNED
          LABEL "Главные"
          VIEW-AS FILL-IN
          SIZE 6.75 BY 1
     tt-scales.scales-name AT ROW 5.5 COL 14.88 COLON-ALIGNED
          LABEL "Название"
          VIEW-AS FILL-IN
          SIZE 31.38 BY 1
     S-type AT ROW 6.75 COL 17 NO-LABEL
     tt-scales.max-gds AT ROW 7 COL 62 COLON-ALIGNED
          LABEL "Максимальная номенклатура"
          VIEW-AS FILL-IN
          SIZE 6 BY 1.13
     tt-scales.address AT ROW 16 COL 14.88 COLON-ALIGNED
          LABEL "Адрес"
          VIEW-AS FILL-IN
          SIZE 38.13 BY 1
     tt-scales.unit-base AT ROW 17.25 COL 35.88 COLON-ALIGNED
          LABEL "Основная единица измерения"
          VIEW-AS FILL-IN
          SIZE 4.88 BY 1.08
     r-base AT ROW 17.25 COL 44
     " Тип" VIEW-AS TEXT
          SIZE 8 BY 1 AT ROW 7.33 COL 7.63
     RECT-1 AT ROW 2.25 COL 2.38
     SPACE(1.11) SKIP(0.25)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "  Весы"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON B-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: locked_scales B "?" ? ub scales
      TABLE: tt-scales T "?" NO-UNDO ub scales
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX d-scalesi
                                                                        */
ASSIGN
       FRAME d-scalesi:SCROLLABLE       = FALSE
       FRAME d-scalesi:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN tt-scales.address IN FRAME d-scalesi
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-scales.master IN FRAME d-scalesi
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-scales.max-gds IN FRAME d-scalesi
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-scales.scales-name IN FRAME d-scalesi
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-scales.scales-num IN FRAME d-scalesi
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-scales.unit-base IN FRAME d-scalesi
   EXP-LABEL                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX d-scalesi
/* Query rebuild information for DIALOG-BOX d-scalesi
     _TblList          = "ub.scales,Temp-Tables.tt-scales WHERE ub.scales ..."
     _Options          = "SHARE-LOCK"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX d-scalesi */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME d-scalesi
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL d-scalesi d-scalesi
ON WINDOW-CLOSE OF FRAME d-scalesi /*   Весы */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-attr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-attr d-scalesi
ON CHOOSE OF b-attr IN FRAME d-scalesi /* Атрибуты */
DO:
    run ref/scl-atti.w ( INPUT parparentproc
                  ,INPUT   {&lookup}
                  ,INPUT tt-scales.db-num
                  ,INPUT tt-scales.scales-num
                 ) NO-ERROR.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit d-scalesi
ON CHOOSE OF B-exit IN FRAME d-scalesi /* Ввод */
DO:
RUN proc-save IN THIS-PROCEDURE no-error.
IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-base
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-base d-scalesi
ON CHOOSE OF r-base IN FRAME d-scalesi
DO:
  define variable ref-rec as recid no-undo .
  DEFINE BUFFER buf_units FOR ub.units.
    run ref/units.w ( input parparentproc, input yes, output ref-rec ).
    if ref-rec = ? THEN do:
            apply "entry" to r-base in frame {&frame-name}.
            return no-apply.
    end.
    FIND buf_units WHERE recid (buf_units) = ref-rec NO-LOCK.
    if lookup({&weight}, buf_units.type) = 0 then do:
        message "Вы выбрали невесовую единицу измерения!" view-as alert-box ERROR.
        apply "entry" to r-base in frame {&frame-name}.
        return no-apply.
    end.
    DISPLAY
    buf_units.unit-name @ tt-scales.unit-base
    with frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK d-scalesi


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/app_help.i }


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON STOP UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   :
   { gbl/getcntxt.i get }
   IF p-mode <> {&UPDATE}
   AND p-mode <> {&add-def} THEN DO:
      MESSAGE
      substitute("Неверное значение параметра p-mode = &1", p-mode)
      VIEW-AS ALERT-BOX ERROR.
      RETURN ERROR.
   END.
   if p-db-num <> v-cntxt-db-num
   and (p-mode = {&add-def}
        or
        p-mode = {&update})
   then do:
    message
    "Нельзя изменять/добавлять ВЕСЫ в чужой БД"
    view-as alert-box error .
    undo, return error .
   end.
    run adm/shattri.p (
        input "get":U
      ,input  p-obj-type
      ,input  p-obj-code
      ,input  {&attr-scale-inf}
      ,input  {&attr-scale-inf_scales-type} /*p-param-code*/
      , output v-value-character
      , output v-value-date
      , output v-value-decimal
      , output v-value-integer
      , output v-value-logical
      , output v-param-type
      , INPUT-OUTPUT table-handle v-tth
      ) no-error .
    IF error-status:error then do:
      delete object v-tth.
        message
        substitute("Ошибка при получении настроек, необъодимых для работы весов НА ОБЪЕКТЕ &1&2:&3&4 &5"
                , p-obj-type
                , p-obj-code
                , {&new-line}
                , error-status:get-message(1)
                , return-value )
        view-as alert-box error .
        undo, return error .
    end.
    delete object v-tth.
    assign
    ini-types =  v-value-character.
    if ini-types = ?
    or ini-types = '':U then do:
      message
      'Ошибка! Не заданы используемые типы весов!' SKIP
      'АРМ Администратор-Справочники-Магазины-Параметры-Опции работы с весами'
      view-as alert-box error .
      return error .
    end.
    IF p-mode = {&UPDATE} THEN DO:
        FIND FIRST LOCKED_scales exclusive-LOCK WHERE
                 LOCKED_scales.db-num = p-db-num
             AND LOCKED_scales.scales-num = p-scales-num .
      v-rid = recid(locked_scales).
    END.
    if p-mode = {&UPDATE} then do:
        glog = no.
        DO ii = 1 TO num-entries( ini-types ) :
            if entry(ii, ini-types) = locked_scales.scales-type then glog = yes.
        END .
      if not glog then do:
        message
        substitute("Ошибка! В списке используемых весов&1"  +
                   "нет типа весов &2!", LOCKED_scales.scales-type)
        view-as alert-box error .
        return error .
      end.
    end.
    S-Type:list-items = ini-types .
    if can-do( {&add-def}, p-mode ) then do:
        CREATE tt-scales.
        assign
        tt-scales.max-gds = 999
        tt-scales.scales-type = entry( 1, ini-types )
        tt-scales.address = "COM1"
        tt-scales.db-num  = p-db-num
        tt-scales.sts     = integer({&current-status-int})
        frame {&frame-name}:title = substitute("&1    - &2"
                                               ,frame {&frame-name}:title
                                               ,{&add-def}) .
    end.
    else do:
        CREATE tt-scales.
        BUFFER-COPY locked_scales TO tt-scales.
        frame {&frame-name}:title = substitute("&1    - &2"
                                               ,frame {&frame-name}:title
                                               ,{&update}) .
   end.

    RUN MyEnable IN THIS-PROCEDURE.

    if S-Type:num-items < 2 then
        S-Type:inner-lines = 1 .
    S-Type:screen-value = tt-scales.scales-type .
    glog = S-Type:scroll-to-item ( tt-scales.scales-type ) .

    if can-do( {&add-def}, p-mode ) then
        WAIT-FOR GO OF FRAME {&FRAME-NAME} focus tt-scales.scales-num.
    else
        WAIT-FOR GO OF FRAME {&FRAME-NAME} focus tt-scales.scales-name .
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI d-scalesi  _DEFAULT-DISABLE
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
  HIDE FRAME d-scalesi.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI d-scalesi  _DEFAULT-ENABLE
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
  DISPLAY S-type
      WITH FRAME d-scalesi.
  IF AVAILABLE tt-scales THEN
    DISPLAY tt-scales.scales-num tt-scales.master tt-scales.scales-name
          tt-scales.max-gds tt-scales.address tt-scales.unit-base
      WITH FRAME d-scalesi.
  ENABLE B-exit B-quit b-attr B-help RECT-1 tt-scales.scales-num
         tt-scales.master tt-scales.scales-name S-type tt-scales.max-gds
         tt-scales.address tt-scales.unit-base r-base
      WITH FRAME d-scalesi.
  VIEW FRAME d-scalesi.
  {&OPEN-BROWSERS-IN-QUERY-d-scalesi}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable d-scalesi
PROCEDURE MyEnable :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
IF AVAILABLE tt-scales THEN do:
    if tt-scales.master = 0 and LOOKUP({&add-def}, p-mode) = 0 then
    HIDE tt-scales.master
    IN frame {&frame-name}.
    ELSE
    DISPLAY
    tt-scales.master
    WITH FRAME {&frame-name}.
    DISPLAY
    tt-scales.max-gds
    tt-scales.scales-num
    tt-scales.scales-name
    tt-scales.address
    tt-scales.unit-base
    S-Type
    WITH FRAME {&FRAME-NAME}.
end.
ENABLE
tt-scales.max-gds WHEN not(lookup({&update}, p-mode) > 0 and tt-scales.master > 0)
b-exit
b-quit
b-help
r-base WHEN not(lookup({&update}, p-mode) > 0 and tt-scales.master > 0)
tt-scales.scales-num WHEN can-do( {&add-def}, p-mode )
tt-scales.master WHEN  can-do( {&add-def}, p-mode )
tt-scales.scales-name
tt-scales.address
tt-scales.unit-base WHEN not(lookup({&update}, p-mode) > 0 and tt-scales.master > 0)
S-Type WHEN not(lookup({&update}, p-mode) > 0 and tt-scales.master > 0)
b-attr when p-mode <> {&add-def}
WITH FRAME {&FRAME-NAME}.
VIEW FRAME {&frame-name}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save d-scalesi
PROCEDURE proc-save :
define variable choice as log no-undo .
define buffer b-scales-gds for ub.scales-gds.
define buffer b-scales-grp for ub.scales-grp.

ASSIGN FRAME {&FRAME-NAME}
tt-scales.scales-num
tt-scales.scales-name
tt-scales.address
tt-scales.unit-base
tt-scales.master
tt-scales.max-gds
s-type
tt-scales.scales-type = s-type
.
if p-mode = {&update} then p-rid = recid(locked_scales).
run ref/scales1.p (
 input-output p-rid
,input p-mode
,INPUT NO /*p-silent*/
,input tt-scales.db-num
,input tt-scales.scales-num
,input tt-scales.address
,input tt-scales.master
,input tt-scales.max-gds
,input tt-scales.scales-name
,input tt-scales.scales-type
,input tt-scales.remote
,input tt-scales.sts
,input tt-scales.unit-base
,input tt-scales.wt-cart
) no-error .
if error-status:error then do:
 { gbl/reterhnd.i error }
  undo, return error.
end.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME