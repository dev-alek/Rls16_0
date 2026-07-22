&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER locked_thbj-attr FOR thbj-attr.
DEFINE TEMP-TABLE tt-scales-type NO-UNDO LIKE scales
       field is-tiger as logical
       field tiger-wt-cart as character
       index pi is unique primary scales-type.
DEFINE BUFFER X_scales FOR scales.
DEFINE BUFFER X_shop FOR shop.
DEFINE BUFFER X_sysconf FOR sysconf.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Редактирование атрибута магазина (thbj-attr) "scale-inf"

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/16/04
Author: Bakhtadze Natalya
Creation date: 09/16/04

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
DEFINE INPUT PARAMETER p-mode AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-obj-type LIKE ub.clients.obj-type NO-UNDO.
DEFINE INPUT PARAMETER p-obj-code LIKE ub.shop.obj-code NO-UNDO.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Редактирование атрибута магазина (thbj-attr) 'scale-inf'".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ gbl/thbjattr.i }
{ cmp/showinf.i  }
{ gbl/getcntxt.i def }


DEFINE VARIABLE v-db-num LIKE ub.db.db-num NO-UNDO.
DEFINE VARIABLE v-tab-order AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-to-create AS logical NO-UNDO.
DEFINE VARIABLE v-num-list AS CHARACTER NO-UNDO.
define variable v-noauto-scls as logical no-undo.
define variable v-obj-db-num like ub.db.db-num no-undo .
define temp-table temp-thbj-attr no-undo like ub.thbj-attr.
define variable v-tth as handle no-undo .
assign
v-tth = buffer thbjattr_thbj-attr:table-handle .

/*
&SCOPED-DEFINE scales-type "CAS_LP-15,CAS_LP-6,HELMAC_net,HELMAC_model-Z,HELMAC_model-T,CAS_LP-485,BOLET_P-280,BZB-SC515,DIGI_SM-80,CAS_LP-15v1.6,TIGER,MIRA":U
&SCOPED-DEFINE scales-pr "lp15s.exe,lp15s.exe,hcns.exe,hczs.exe,hcts.exe,lp485s.exe,scalex.exe,bzbs.exe,digis.exe,lp16s.exe,metos.exe,miras.exe":U
*/

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-scales

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_scales tt-scales-type

/* Definitions for BROWSE BR-scales                                     */
&Scoped-define FIELDS-IN-QUERY-BR-scales ~
mark-string(X_scales.scales-num, v-num-list) X_scales.db-num ~
X_scales.scales-num X_scales.scales-name X_scales.scales-type ~
X_scales.master 
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-scales 
&Scoped-define QUERY-STRING-BR-scales FOR EACH X_scales NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BR-scales OPEN QUERY BR-scales FOR EACH X_scales NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BR-scales X_scales
&Scoped-define FIRST-TABLE-IN-QUERY-BR-scales X_scales


/* Definitions for BROWSE BR-scales-type                                */
&Scoped-define FIELDS-IN-QUERY-BR-scales-type tt-scales-type.scales-type ~
tt-scales-type.scales-name tt-scales-type.is-tiger 
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-scales-type ~
tt-scales-type.scales-name 
&Scoped-define ENABLED-TABLES-IN-QUERY-BR-scales-type tt-scales-type
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-BR-scales-type tt-scales-type
&Scoped-define QUERY-STRING-BR-scales-type FOR EACH tt-scales-type NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BR-scales-type OPEN QUERY BR-scales-type FOR EACH tt-scales-type NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BR-scales-type tt-scales-type
&Scoped-define FIRST-TABLE-IN-QUERY-BR-scales-type tt-scales-type


/* Definitions for DIALOG-BOX Dialog-Frame                              */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit b-quit RS-sclin-ld B-Help EDITOR-1 ~
B-add B-del B-etc BR-scales-type B-mark BR-scales mark-num l-scallist 
&Scoped-Define DISPLAYED-OBJECTS RS-sclin-ld EDITOR-1 mark-num l-scallist 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD mark-string Dialog-Frame 
FUNCTION mark-string RETURNS CHARACTER
  ( input p-scales-num as integer, input p-list as character )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-add 
     LABEL "&Добавить" 
     SIZE 10 BY 1.

DEFINE BUTTON B-del 
     LABEL "&Удалить" 
     SIZE 10 BY 1.

DEFINE BUTTON B-etc 
     LABEL "Дополнительно" 
     SIZE 14.5 BY 1.

DEFINE BUTTON B-exit AUTO-GO 
     LABEL "&Ввод" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help 
     LABEL "Помо&щь" 
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-mark 
     LABEL "&*" 
     SIZE 10 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY 
     LABEL "&Отмена" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE EDITOR-1 AS CHARACTER INITIAL "Установка сроков годности при приходе и переоценке" 
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 30.5 BY 2 NO-UNDO.

DEFINE VARIABLE l-scallist AS CHARACTER FORMAT "X(256)":U INITIAL "Количество весов, используемых на объекте" 
      VIEW-AS TEXT 
     SIZE 41 BY .67 NO-UNDO.

DEFINE VARIABLE mark-num AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 6 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE RS-sclin-ld AS INTEGER 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "Из карточки товара", 0,
"Min из партий посл.прихода", 1,
"Max из партий посл.прихода", 2
     SIZE 29.5 BY 3 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-scales FOR 
      X_scales SCROLLING.

DEFINE QUERY BR-scales-type FOR 
      tt-scales-type SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-scales
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-scales Dialog-Frame _STRUCTURED
  QUERY BR-scales NO-LOCK DISPLAY
      mark-string(X_scales.scales-num, v-num-list) COLUMN-LABEL "*" FORMAT "X(1)":U
      X_scales.db-num FORMAT ">>>>9":U
      X_scales.scales-num FORMAT ">>9":U
      X_scales.scales-name FORMAT "X(40)":U
      X_scales.scales-type FORMAT "X(12)":U
      X_scales.master FORMAT ">>9":U WIDTH 8
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97.5 BY 7.5
         TITLE "Весы, используемые на объекте" ROW-HEIGHT-CHARS .67.

DEFINE BROWSE BR-scales-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-scales-type Dialog-Frame _STRUCTURED
  QUERY BR-scales-type NO-LOCK DISPLAY
      tt-scales-type.scales-type COLUMN-LABEL "Тип весов" FORMAT "X(16)":U
      tt-scales-type.scales-name COLUMN-LABEL "Название!программы!пересылки!данных" FORMAT "X(20)":U
      tt-scales-type.is-tiger COLUMN-LABEL "Задавать!коды тары" FORMAT "+/":U
            WIDTH 68.25
  ENABLE
      tt-scales-type.scales-name
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 8
         TITLE "Типы весов" FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     RS-sclin-ld AT ROW 1 COL 52.5 NO-LABEL WIDGET-ID 2
     B-Help AT ROW 1 COL 95
     EDITOR-1 AT ROW 2 COL 21 NO-LABEL WIDGET-ID 8
     B-add AT ROW 3 COL 1
     B-del AT ROW 3 COL 11
     B-etc AT ROW 3 COL 84.5
     BR-scales-type AT ROW 4 COL 1
     B-mark AT ROW 12 COL 1
     BR-scales AT ROW 13 COL 1
     mark-num AT ROW 12 COL 9.5 COLON-ALIGNED NO-LABEL
     l-scallist AT ROW 12 COL 16.5 COLON-ALIGNED NO-LABEL
     SPACE(39.74) SKIP(7.90)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Настройки, необходимые для работы весов"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: locked_thbj-attr B "?" ? ub thbj-attr
      TABLE: tt-scales-type T "?" NO-UNDO ub scales
      ADDITIONAL-FIELDS:
          field is-tiger as logical
          field tiger-wt-cart as character
          index pi is unique primary scales-type
      END-FIELDS.
      TABLE: X_scales B "?" ? ub scales
      TABLE: X_shop B "?" ? ub shop
      TABLE: X_sysconf B "?" ? ub sysconf
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BR-scales-type B-etc Dialog-Frame */
/* BROWSE-TAB BR-scales B-mark Dialog-Frame */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-scales
/* Query rebuild information for BROWSE BR-scales
     _TblList          = "X_scales"
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _FldNameList[1]   > "_<CALC>"
"mark-string(X_scales.scales-num, v-num-list)" "*" "X(1)" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[2]   = Temp-Tables.X_scales.db-num
     _FldNameList[3]   = Temp-Tables.X_scales.scales-num
     _FldNameList[4]   = Temp-Tables.X_scales.scales-name
     _FldNameList[5]   > Temp-Tables.X_scales.scales-type
"X_scales.scales-type" ? "X(12)" "character" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[6]   > Temp-Tables.X_scales.master
"X_scales.master" ? ? "integer" ? ? ? ? ? ? no ? no no "8" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _Query            is NOT OPENED
*/  /* BROWSE BR-scales */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-scales-type
/* Query rebuild information for BROWSE BR-scales-type
     _TblList          = "Temp-Tables.tt-scales-type"
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _FldNameList[1]   > Temp-Tables.tt-scales-type.scales-type
"tt-scales-type.scales-type" "Тип весов" "X(16)" "character" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[2]   > Temp-Tables.tt-scales-type.scales-name
"tt-scales-type.scales-name" "Название!программы!пересылки!данных" "X(20)" "character" ? ? ? ? ? ? yes ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[3]   > "_<CALC>"
"tt-scales-type.is-tiger" "Задавать!коды тары" "+/" ? ? ? ? ? ? ? no ? no no "68.25" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _Query            is NOT OPENED
*/  /* BROWSE BR-scales-type */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Настройки, необходимые для работы весов */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-add Dialog-Frame
ON CHOOSE OF B-add IN FRAME Dialog-Frame /* Добавить */
DO:
DEFINE VARIABLE vscales-type AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-type AS CHARACTER NO-UNDO.
DEFINE VARIABLE ii AS integer NO-UNDO.
DEFINE BUFFER buf_tt-scales-type FOR tt-scales-type.

assign
vscales-type = "":U
.
DO ii = 1 to num-entries({&scales-type}):
    assign
    vscales-type = vscales-type + {&comma-char} + entry(ii, {&scales-type})
    .

end.
run gbl/d-list.w (
              INPUT "b-sel":U
              ,INPUT "Выберите типы параметров для редактирования или просмотра"
              ,INPUT vscales-type
              ,INPUT vscales-type
              ,INPUT {&comma-char}
              ,INPUT "":U
              ,output v-type).
IF v-type = "":u THEN do:
  RETURN no-apply.
end.
FIND FIRST buf_tt-scales-type NO-LOCK WHERE
           buf_tt-scales-type.scales-type = v-type NO-ERROR.
IF AVAILABLE buf_tt-scales-type THEN DO:
    MESSAGE
    "В вашем списке уже есть весы типа " v-type
    VIEW-AS ALERT-BOX ERROR.
    RETURN NO-APPLY.
END.
CREATE buf_tt-scales-type.
ASSIGN
buf_tt-scales-type.scales-type = v-type
buf_tt-scales-type.scales-name = ENTRY(LOOKUP(v-type, {&scales-type}), {&scales-pr})
buf_tt-scales-type.is-tiger = (IF v-type = "TIGER":U OR v-type = "MIRA":U OR v-type = "TIGER2" THEN YES ELSE NO)
.
RUN Openbr-Scales-type IN THIS-PROCEDURE no-error.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-del Dialog-Frame
ON CHOOSE OF B-del IN FRAME Dialog-Frame /* Удалить */
DO:
  IF NOT AVAILABLE tt-scales-type  THEN RETURN NO-APPLY.
  DELETE tt-scales-type.
  RUN Openbr-Scales-type IN THIS-PROCEDURE no-error.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-etc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-etc Dialog-Frame
ON CHOOSE OF B-etc IN FRAME Dialog-Frame /* Дополнительно */
DO:
  /*  */
  run adm/shattr-6-1.w(input-output v-noauto-scls).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Ввод */
DO:
  RUN proc-save IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* * */
DO:
  define variable loc#log as logical no-undo .
  if available X_scales then do:
      if lookup(string( X_scales.scales-num ), v-num-list ) > 0  then do:
          v-num-list = TRIM( v-num-list, {&comma-char}) .
          v-num-list = {&comma-char} + v-num-list + {&comma-char}.
          v-num-list = replace( v-num-list, {&comma-char} + string( X_scales.scales-num ) + {&comma-char}, "") .
          v-num-list = TRIM( v-num-list, {&comma-char}) .
      end.
      else
      v-num-list = v-num-list + ( if v-num-list = "" then "" else {&comma-char} ) + string(  X_scales.scales-num ) .
      loc#log = br-scales:refresh() .

      if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
          loc#log = br-scales:select-next-row ().
          apply "VALUE-CHANGED" to br-scales in frame {&frame-name}.
      end.
      if num-entries( v-num-list ) = 0
      then
          hide mark-num in frame {&frame-name}.
      else
          disp num-entries( v-num-list ) @ mark-num with frame {&frame-name}.
  end.
  apply "entry" to br-scales in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME RS-sclin-ld
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RS-sclin-ld Dialog-Frame
ON VALUE-CHANGED OF RS-sclin-ld IN FRAME Dialog-Frame
DO:
  DO:
  IF p-mode <> {&LOOKUP}  THEN
  ASSIGN
  RS-sclin-ld.
  CASE RS-sclin-ld:
    WHEN 0 THEN DO:
      RS-sclin-ld = 0.
    END.
    WHEN 1 THEN DO:
      RS-sclin-ld = 1.
    END.
    WHEN 2 THEN DO:
      RS-sclin-ld = 2.
    END.
  END CASE.
  EDITOR-1 = string(RS-sclin-ld) .
END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-scales
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
{ ref/tabhndmv.i v-tab-order underline-tb }
{ gbl/rethndmv.i v-tab-order underline-tb "APPLY 'CHOOSE' TO b-exit in frame {&frame-name}." }
{ gbl/objdbnum.i p-obj-type p-obj-code v-obj-db-num }
  IF p-mode <> {&lookup}
  and p-mode <> {&update} THEN DO:
      MESSAGE
      vss-workfile vss-revision vss-description skip
      "Неверное значение параметра p-mode" p-mode
      VIEW-AS ALERT-BOX ERROR.
      UNDO, RETURN ERROR.
  END.
  IF p-obj-type <> {&shop}
  and p-obj-type <> {&cmp}
  and p-obj-type <> '':U
  THEN DO:
      MESSAGE
      vss-workfile vss-revision vss-description skip
      "Неверное значение параметра p-obj-type" p-obj-type
      VIEW-AS ALERT-BOX ERROR.
      UNDO, RETURN ERROR.
  END.
  if p-obj-type = {&shop} then do:
    FIND FIRST X_shop NO-LOCK WHERE X_shop.obj-code = p-obj-code NO-ERROR.
    IF NOT AVAILABLE X_shop THEN DO:
        MESSAGE
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметра p-obj-code" p-obj-code
        VIEW-AS ALERT-BOX ERROR.
        UNDO, RETURN ERROR.
    END.
    { gbl/objdbnum.i ~{&shop~} p-obj-code v-db-num }
    IF v-db-num <> v-cntxt-db-num
    AND v-cntxt-db-num <> 0
    and p-mode <> {&lookup}
    THEN DO:
        MESSAGE
        "Нельзя менять параметры магазина в чужой БД" skip
        "магазин принадлежит БД" v-db-num "текущая БД" v-cntxt-db-num
        VIEW-AS ALERT-BOX ERROR.
        UNDO, RETURN ERROR.
    END.
  end.
  if p-obj-type = {&cmp} then do:
    FIND FIRST X_sysconf NO-LOCK WHERE X_sysconf.host-code = p-obj-code NO-ERROR.
    IF NOT AVAILABLE X_sysconf THEN DO:
        MESSAGE
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметра p-obj-code" p-obj-code
        VIEW-AS ALERT-BOX ERROR.
        UNDO, RETURN ERROR.
    END.
    if v-cntxt-db-num <> 0
    and p-mode <> {&lookup}
    then do:
        MESSAGE
        "Нельзя менять параметры ФИРМЫ в УБД" skip
        VIEW-AS ALERT-BOX ERROR.
        UNDO, RETURN ERROR.
    end.
  end.
  if p-obj-type = '':U then do:
    if v-cntxt-db-num <> 0
    and p-mode <> {&lookup}
    then do:
        MESSAGE
        "Нельзя менять ГЛОБАЛЬНЫЕ параметры в УБД" skip
        VIEW-AS ALERT-BOX ERROR.
        UNDO, RETURN ERROR.
    end.
  end.
  IF p-mode = {&UPDATE} THEN DO:
    FIND FIRST LOCKED_thbj-attr EXCLUSIVE-LOCK WHERE
              LOCKED_thbj-attr.obj-type = p-obj-type
        AND   LOCKED_thbj-attr.obj-code = p-obj-code
        AND   LOCKED_thbj-attr.upper-prop-code = {&attr-scale-inf}
        AND   locked_thbj-attr.prop-code = '':U NO-WAIT NO-ERROR.
     if locked locked_thbj-attr then do:
        message
        vss-workfile vss-revision vss-description skip
         "Запись ПАРАМЕТРЫ(АТРИБУТЫ) МАГАЗИНА занята"
        view-as alert-box error .
        undo, return error.
      end.
  END.
  ELSE DO:
      FIND FIRST LOCKED_thbj-attr no-LOCK WHERE
          LOCKED_thbj-attr.obj-type = p-obj-type
    AND   LOCKED_thbj-attr.obj-code = p-obj-code
    AND   LOCKED_thbj-attr.upper-prop-code = {&attr-scale-inf}
    and   locked_thbj-attr.prop-code = '':U NO-ERROR.
  END.
  if not available locked_thbj-attr then do:
    ASSIGN
    v-to-create  = YES.
    message
    substitute ("Внимание!!!&1Параметра НЕТ в БД!&1Будут показаны ЗНАЧЕНИЯ ПО УМОЛЧАНИЮ",
                {&new-line})
    view-as alert-box WARNING.


  end.
  RUN FILL-WIDGETS IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN UNDO, RETURN ERROR.

  RUN Myenable.
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
  DISPLAY RS-sclin-ld EDITOR-1 mark-num l-scallist 
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit RS-sclin-ld B-Help EDITOR-1 B-add B-del B-etc 
         BR-scales-type B-mark BR-scales mark-num l-scallist 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-widgets Dialog-Frame 
PROCEDURE fill-widgets :
DEFINE VARIABLE ii AS INTEGER NO-UNDO.
DEFINE VARIABLE jj AS INTEGER NO-UNDO.
DEFINE VARIABLE v-entry AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-value AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-scales AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-scale-pr AS CHARACTER NO-UNDO.
define variable v-scale-pr-all as character no-undo .
DEFINE BUFFER buf_scales FOR ub.scales .
define variable v-param-type as character no-undo .
define variable v-param-value as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
FOR EACH thbjattr_thbj-attr:
  delete thbjattr_thbj-attr.
end.
FOR EACH temp-thbj-attr:
  delete temp-thbj-attr.
end.

run adm/shattri.p (
              input "init":U
            , input p-obj-type
            , input p-obj-code
            , input {&attr-scale-inf}
            , input "":U
            ,output v-value-character
            ,output v-value-date
            ,output v-value-decimal
            ,output v-value-integer
            ,output v-value-logical
            ,output v-param-type
            ,INPUT-OUTPUT TABLE-handle v-tth
            ) no-error .
if error-status:error
and not available locked_thbj-attr then do:
  message
  "Не удалось получить начальные значения настроек" skip
  error-status:get-message(1) return-value
  view-as alert-box error .
  undo, return error .
end.
FOR EACH tt-scales-type:
  DELETE tt-scales-type.
END.
for each thbjattr_thbj-attr:
  ASSIGN
  v-entry = thbjattr_thbj-attr.prop-code
  .
  IF v-entry = {&attr-scale-inf_scales-type} THEN DO:
    DO jj = 1 TO NUM-ENTRIES(thbjattr_thbj-attr.property-value-character):
      ASSIGN
      v-scales = ENTRY(jj, thbjattr_thbj-attr.property-value-character).
      FIND FIRST tt-scales-type WHERE
                  tt-scales-type.scales-type = v-scales NO-ERROR.
      IF NOT AVAILABLE tt-scales-type THEN DO:
          CREATE tt-scales-type.
          ASSIGN
          tt-scales-type.db-num = v-obj-db-num
          tt-scales-type.scales-num = jj
          tt-scales-type.scales-type =  v-scales
          tt-scales-type.is-tiger = (if v-scales = "MIRA":U or v-scales = "TIGER":U or v-scales = "TIGER2" then yes else no)
           .
      END.
    END. /*DO jj = 1 TO NUM-ENTRIES(v-value):*/
  END. /*IF v-entry BEGINS "scales=" THEN DO:*/
  IF v-entry = {&attr-scale-inf_scales-pr} THEN DO:
    v-scale-pr-all = thbjattr_thbj-attr.property-value-character.
  END.
  IF v-entry =  {&attr-scale-inf_scallist} THEN DO:
    v-num-list = "":U.
    DO jj = 1 TO NUM-ENTRIES(thbjattr_thbj-attr.property-value-character):
      FIND FIRST buf_scales WHERE
                buf_scales.db-num = v-obj-db-num
            AND buf_scales.scales-num = integer(ENTRY(jj, thbjattr_thbj-attr.property-value-character)) NO-ERROR.
      IF AVAILABLE buf_scales THEN DO:
        ASSIGN
        v-num-list = v-num-list + (IF v-num-list = "":U THEN "":U else {&comma-char}) + STRING(buf_scales.scales-num).
      END.
    END.
  END.
  if v-entry = {&attr-scale-inf_noauto-scls} then do:
    v-noauto-scls = thbjattr_thbj-attr.property-value-logical.
  end.
  
  IF v-entry = {&attr-scale-inf_sclin-ld} THEN DO:
    ASSIGN
    rs-sclin-ld = thbjattr_thbj-attr.property-value-integer
    rs-sclin-ld:private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
    .
  end.
  create temp-thbj-attr.
  buffer-copy thbjattr_thbj-attr to temp-thbj-attr.
  DO jj = 1 TO NUM-ENTRIES(v-scale-pr-all):
    ASSIGN
    v-scale-pr = ENTRY(jj, v-scale-pr-all).
    FIND FIRST tt-scales-type WHERE
                tt-scales-type.db-num = v-obj-db-num
            AND tt-scales-type.scales-num = jj NO-ERROR.
    IF AVAILABLE tt-scales-type THEN DO:
      ASSIGN
      tt-scales-type.scales-name =  v-scale-pr
      .
    END.
  end.
END. /*for each*/


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame 
PROCEDURE MyEnable :
ASSIGN
FRAME {&FRAME-NAME}:TITLE = FRAME {&FRAME-NAME}:TITLE + (if p-obj-type = {&cmp} then " фирма" else " маг") + STRING(p-obj-code)
v-tab-order = "rs-sclin-ld,b-add,b-del,br-scales-type,b-mark,br-scales"
mark-num = string(NUM-ENTRIES(v-num-list))
.
DISPLAY
rs-sclin-ld
br-scales-type
br-scales
mark-num
l-scallist
WITH FRAME {&frame-name}.
ENABLE
B-exit WHEN p-mode = {&UPDATE}
B-etc when p-mode = {&update}
b-quit
B-Help
br-scales-type
br-scales
rs-sclin-ld WHEN p-mode = {&UPDATE}
b-mark WHEN p-mode = {&UPDATE}
b-add WHEN p-mode = {&UPDATE}
b-del WHEN p-mode = {&UPDATE}
WITH FRAME {&frame-name}.
VIEW FRAME {&frame-name}.
IF p-mode = {&LOOKUP} THEN DO:
    HIDE
    b-exit
    IN FRAME {&FRAME-NAME}.
    ASSIGN
    b-quit:LABEL = "&Выход"
    tt-scales-type.scales-name:READ-ONLY IN browse br-scales-type =  YES
    .
END.
APPLY "value-changed" TO rs-sclin-ld.
RUN OpenBr-scales-type in this-procedure .
RUN OpenBR-scales in this-procedure .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBR-scales Dialog-Frame 
PROCEDURE OpenBR-scales :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
OPEN QUERY br-scales FOR EACH
X_scales.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBr-scales-type Dialog-Frame 
PROCEDURE OpenBr-scales-type :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
OPEN QUERY br-scales-type FOR EACH
tt-scales-type.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save Dialog-Frame 
PROCEDURE proc-save :
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-param-type as character no-undo .
define variable ii as integer no-undo .
define variable v-same as logical no-undo .

DEFINE BUFFER buf_scales FOR ub.scales.

define variable v-scales as character no-undo .
define variable v-scale-pr as character no-undo .
define variable v-scallist as character no-undo .
IF p-mode = {&LOOKUP} THEN RETURN ERROR.
assign
frame {&frame-name}
rs-sclin-ld.

FOR EACH tt-scales-type NO-LOCK:
 ASSIGN
 v-scales = v-scales + (if v-scales = "":U then "":U else {&comma-char}) + tt-scales-type.scales-type
 v-scale-pr = v-scale-pr + (if v-scale-pr = "":U then "":U else {&comma-char}) + tt-scales-type.scales-name
 .
END.
FOR EACH buf_scales NO-LOCK where buf_scales.db-num = v-obj-db-num:
  IF lookup(string(buf_scales.scales-num), v-num-list) > 0  THEN DO:
    ASSIGN
    ii = ii + 1
    v-scallist = v-scallist + (IF ii = 1 THEN "":U ELSE {&comma-char}) + string(buf_scales.scales-num).
  END.
END.
if v-scallist = '' then do:
  define variable choice as integer no-undo .
  run gbl/d-askw.w (input "Уточнение"
                        ,input  ("Вы не выбрали список весов для работы в магазине"  + {&new-line} +
                               "Как предполагается использовать весы данной БД в данном магазине")
                        ,input "|"
                        ,input "Все весы БД|Нет весов|Отменить"
                        ,input "Использовать все веcы текущей БД|Не использовать весы ВООБЩЕ|Отменить"
                        ,input 1
                        ,input 3
                        ,output choice) no-error.
  if choice = 3 then do:
    undo, return error.
  end.
  if choice = 2 then do:
    v-scallist = "-".
  end.
end.
find first thbjattr_thbj-attr where thbjattr_thbj-attr.prop-code = {&attr-scale-inf_scales-type}.
assign
thbjattr_thbj-attr.property-value-character = v-scales
.
find first thbjattr_thbj-attr where thbjattr_thbj-attr.prop-code = {&attr-scale-inf_scales-pr}.
assign
thbjattr_thbj-attr.property-value-character = v-scale-pr
.
find first thbjattr_thbj-attr where thbjattr_thbj-attr.prop-code = {&attr-scale-inf_scallist}.
assign
thbjattr_thbj-attr.property-value-character = v-scallist
.
find first thbjattr_thbj-attr where thbjattr_thbj-attr.prop-code = {&attr-scale-inf_noauto-scls}.
assign
thbjattr_thbj-attr.property-value-logical = v-noauto-scls
.
find first thbjattr_thbj-attr where thbjattr_thbj-attr.prop-code = {&attr-scale-inf_sclin-ld}.
assign
thbjattr_thbj-attr.property-value-integer = RS-sclin-ld
.




v-same = yes.
for each thbjattr_thbj-attr,
    first temp-thbj-attr where
          temp-thbj-attr.obj-type = thbjattr_thbj-attr.obj-type
      and temp-thbj-attr.obj-code = thbjattr_thbj-attr.obj-code
      and temp-thbj-attr.upper-prop-code = thbjattr_thbj-attr.upper-prop-code
      and temp-thbj-attr.prop-code = thbjattr_thbj-attr.prop-code:
   buffer-compare
   thbjattr_thbj-attr
   to temp-thbj-attr
   save result in v-same.
   if not v-same then leave.
end.
v-same = no.
IF v-same  and not v-to-create THEN RETURN.
/*проверим корректность*/
run adm/shattri.p (
              input "check":U
            , input p-obj-type
            , input p-obj-code
            , input {&attr-scale-inf}
            , INPUT '':U
             , output v-value-character
             , output v-value-date
             , output v-value-decimal
             , output v-value-integer
             , output v-value-logical
             , output v-param-type
             , input-output TABLE-handle v-tth
             ) no-error .

if error-status:error then do:
  message
  "Некорректное значение ПАРАМЕТРОВ" skip
  error-status:get-message(1) skip
  return-value
  view-as alert-box error .
  undo, return error .
end.
do TRANSACTION
on error undo, return error return-value
:

  RUN thbjattr_set-section IN THIS-PROCEDURE (
       input p-obj-type
      ,input p-obj-code
      ,input {&attr-scale-inf}
      ,INPUT table thbjattr_thbj-attr
  ) NO-ERROR.
  IF ERROR-STATUS:error THEN do:
    MESSAGE ERROR-STATUS:get-message(1)  SKIP
    RETURN-VALUE
    VIEW-AS ALERT-BOX.
    UNDO, RETURN ERROR.
  END.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION mark-string Dialog-Frame 
FUNCTION mark-string RETURNS CHARACTER
  ( input p-scales-num as integer, input p-list as character ) :
if lookup(string(p-scales-num), p-list) > 0 then return "*".
  RETURN "".   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

