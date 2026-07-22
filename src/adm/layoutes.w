&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER X_layout-elem FOR ub.layout-elem.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список элементов раскладок

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/26/08
Author: Bakhtadze Natalya
Creation date: 09/26/08

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
define input parameter bttns as character no-undo.
define input parameter p-list-mode as character no-undo .
/*{&all}  layout-type layout-device-type layout-device-type-mode */
define input parameter p-layout-type as character no-undo .
define input parameter p-device-type as character no-undo .
define input parameter p-mode-id as character no-undo .
define input parameter p-elem-type as integer no-undo .
define input-output parameter p-rid-list as character no-undo.


/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Список элементов раскладок".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i }
{ cmp/mrk-strf.i }
{ gbl/getcntxt.i def }
{ gbl/key-rec.i }
{ adm/cd-mode2.i DEF }
DEFINE VARIABLE v-doc-rec AS RECID NO-UNDO.
define variable v-admin as logical no-undo .
DEFINE VARIABLE link-option AS CHARACTER NO-UNDO.
define variable v-rid-list as character no-undo .
DEFINE VARIABLE lkp-option AS CHARACTER NO-UNDO.
define variable v-list-mode as character no-undo.
define variable vh-layout-type-name as handle no-undo .
define variable vh-cdm-name as handle no-undo .
DEFINE VARIABLE v-all-devices-list-itemS AS CHARACTER NO-UNDO.
DEFINE VARIABLE V-SCREEN-LIST-ITEMS AS CHARACTER NO-UNDO.
DEFINE VARIABLE V-KEYBOARD-LIST-ITEMS AS CHARACTER NO-UNDO.
&SCOPED-DEFINE layout-type-code X_layout-elem.layout-type
&scop label-1 "Тип раскладки"
&scop label-2 "Режим"
&scop label-3 "Тип"
&SCOPED-DEFINE lelem-type-code STRING(X_layout-elem.elem-type)

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-layout-elem

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_layout-elem

/* Definitions for BROWSE br-layout-elem                                */
&Scoped-define FIELDS-IN-QUERY-br-layout-elem mark-string(recid(X_layout-elem), v-rid-list) {&layout-type-name} X_layout-elem.device-type get-cdm-name(X_layout-elem.mode-id) X_layout-elem.widget-id X_layout-elem.DES {&lelem-type-name}
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-layout-elem
&Scoped-define SELF-NAME br-layout-elem
&Scoped-define QUERY-STRING-br-layout-elem FOR EACH X_layout-elem NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-layout-elem OPEN QUERY {&SELF-NAME} FOR EACH X_layout-elem NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br-layout-elem X_layout-elem
&Scoped-define FIRST-TABLE-IN-QUERY-br-layout-elem X_layout-elem


/* Definitions for DIALOG-BOX Dialog-Frame                              */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit b-mark b-sel b-add b-chg b-del b-lkp ~
B-Help CB-layout-type CB-device-type Cb-elem-type CB-mode-id br-layout-elem ~
mark-num
&Scoped-Define DISPLAYED-OBJECTS CB-layout-type CB-device-type Cb-elem-type ~
CB-mode-id mark-num

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-add
     LABEL "&Добавить"
     SIZE 10 BY 1.

DEFINE BUTTON b-chg
     LABEL "&Изменить"
     SIZE 10 BY 1.

DEFINE BUTTON b-del
     LABEL "&Удалить"
     SIZE 10 BY 1.

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-lkp
     LABEL "&Просмотр"
     SIZE 10 BY 1.

DEFINE BUTTON b-mark
     LABEL "&*"
     SIZE 4 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-sel AUTO-GO
     LABEL "Выбор"
     SIZE 10 BY 1.

DEFINE VARIABLE CB-device-type AS CHARACTER FORMAT "X(256)":U
     LABEL "Устройство"
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEMS "Item 1"
     DROP-DOWN-LIST
     SIZE 21.5 BY 1 NO-UNDO.

DEFINE VARIABLE Cb-elem-type AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 0
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEM-PAIRS "Item 1",0
     DROP-DOWN-LIST
     SIZE 31 BY 1 NO-UNDO.

DEFINE VARIABLE CB-layout-type AS CHARACTER FORMAT "X(256)":U
     LABEL "Тип раскладки"
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEM-PAIRS "Item 1","Item 1"
     DROP-DOWN-LIST
     SIZE 24 BY 1 NO-UNDO.

DEFINE VARIABLE CB-mode-id AS CHARACTER FORMAT "X(256)":U
     LABEL "Режим"
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEM-PAIRS "Item 1","Item 1"
     DROP-DOWN-LIST
     SIZE 48 BY 1 NO-UNDO.

DEFINE VARIABLE mark-num AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 0
      VIEW-AS TEXT
     SIZE 9 BY .67
     FGCOLOR 10  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-layout-elem FOR
      X_layout-elem SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-layout-elem
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-layout-elem Dialog-Frame _FREEFORM
  QUERY br-layout-elem NO-LOCK DISPLAY
      mark-string(recid(X_layout-elem), v-rid-list) Format "X(1)" COLUMN-LABEL "*"
{&layout-type-name} COLUMN-LABEL {&label-1} FORMAT "X(255)" WIDTH 20
X_layout-elem.device-type COLUMN-LABEL "Для устройства" FORMAT "X(15)"
get-cdm-name(X_layout-elem.mode-id) COLUMN-LABEL {&label-2} FORMAT "X(255)" width 25
X_layout-elem.widget-id COLUMN-LABEL "Элемент"
X_layout-elem.DES COLUMN-LABEL "Описание" format "X(255)" width 35
{&lelem-type-name} COLUMN-LABEL {&LABEL-3} FORMAT "X(15)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97 BY 18 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     b-mark AT ROW 1 COL 20 WIDGET-ID 12
     b-sel AT ROW 1 COL 24 WIDGET-ID 10
     b-add AT ROW 1 COL 34 WIDGET-ID 2
     b-chg AT ROW 1 COL 44 WIDGET-ID 4
     b-del AT ROW 1 COL 54 WIDGET-ID 8
     b-lkp AT ROW 1 COL 64 WIDGET-ID 6
     B-Help AT ROW 1 COL 95
     CB-layout-type AT ROW 2 COL 1.5 WIDGET-ID 16
     CB-device-type AT ROW 2 COL 41 WIDGET-ID 18
     Cb-elem-type AT ROW 2.87 COL 65.5 COLON-ALIGNED NO-LABEL WIDGET-ID 22
     CB-mode-id AT ROW 3 COL 1 WIDGET-ID 20
     br-layout-elem AT ROW 4.87 COL 1.5 WIDGET-ID 100
     mark-num AT ROW 1 COL 11 NO-LABEL WIDGET-ID 14
     SPACE(78.59) SKIP(21.21)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE ""
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: X_layout-elem B "?" ? ub layout-elem
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-layout-elem CB-mode-id Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR COMBO-BOX CB-device-type IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR COMBO-BOX CB-layout-type IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR COMBO-BOX CB-mode-id IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN mark-num IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-layout-elem
/* Query rebuild information for BROWSE br-layout-elem
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_layout-elem NO-LOCK INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is NOT OPENED
*/  /* BROWSE br-layout-elem */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame
DO:
  p-rid-list = v-rid-list.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add Dialog-Frame
ON CHOOSE OF b-add IN FRAME Dialog-Frame /* Добавить */
DO:
 define variable v-rec as recid no-undo.
  run adm/layoutei.w ( input parparentproc
                       ,input {&add-def} + {&comma-char} + (if v-admin then "admin" else '')
                       ,input cb-layout-type /*p-layout-type*/
                       ,input cb-device-type /*p-device-type*/
                       ,input cb-mode-id /*p-mode-id*/
                       ,input '' /*p-widget-id*/
                       ,input-output v-rec) no-error.
  if v-rec <> ? then do:
    RUN openbr IN THIS-PROCEDURE.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-chg Dialog-Frame
ON CHOOSE OF b-chg IN FRAME Dialog-Frame /* Изменить */
DO:
  define variable v-rec as recid no-undo.
  if not available X_layout-elem then return no-apply.
  v-rec = recid(X_layout-elem).
  run adm/layoutei.w ( input parparentproc
                       ,input {&update} + {&comma-char} + (if v-admin then "admin" else '')
                       ,input X_layout-elem.layout-type
                       ,input X_layout-elem.device-type
                       ,input X_layout-elem.mode-id
                       ,input X_layout-elem.widget-id
                       ,input-output v-rec) no-error.
  if v-rec <> ? then do:
     br-layout-elem:refresh().
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del Dialog-Frame
ON CHOOSE OF b-del IN FRAME Dialog-Frame /* Удалить */
DO:
  define variable v-rec as recid no-undo.
  define variable glog as logical no-undo.
  if not available X_layout-elem then return no-apply.
  v-rec = recid(X_layout-elem).
  message
  "Вы уверены, что хотите удалить элемент раскладки?"
  view-as alert-box question buttons yes-no update glog.
  if not glog then return no-apply.
 run adm/layoute3.p (
                           input no /*p-silent*/
                          ,input v-rec
                          ) no-error.
 if error-status:error then return no-apply.
 run Openbr in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-lkp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-lkp Dialog-Frame
ON CHOOSE OF b-lkp IN FRAME Dialog-Frame /* Просмотр */
DO:

if not available X_layout-elem then return no-apply.
run proc-b-lkp IN THIS-PROCEDURE ( INPUT {&table_layout-elem}) NO-ERROR.
IF ERROR-STATUS:ERROR THEN DO:
    lkp-option = '':U.
    RETURN NO-APPLY.
END.
lkp-option = '':U.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-mark Dialog-Frame
ON CHOOSE OF b-mark IN FRAME Dialog-Frame /* * */
DO:
  define variable glog as logical no-undo .
  if available X_layout-elem then do:
 { gbl/markstrn.i X_layout-elem v-rid-list }
  glog = br-layout-elem:refresh() .

  if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
      glog = br-layout-elem:select-next-row ().
      apply "VALUE-CHANGED" to br-layout-elem in frame {&frame-name}.
  end.
  if num-entries( v-rid-list ) = 0
  then
      hide mark-num in frame {&frame-name}.
  else
      disp num-entries( v-rid-list ) @ mark-num with frame {&frame-name}.
end.
apply "entry" to br-layout-elem in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel Dialog-Frame
ON CHOOSE OF b-sel IN FRAME Dialog-Frame /* Выбор */
DO:
  if available X_layout-elem then do:
    if  ( v-rid-list = "" ) or b-mark:sensitive = no
    then  v-rid-list = string( recid( X_layout-elem ) ) .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME CB-device-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL CB-device-type Dialog-Frame
ON VALUE-CHANGED OF CB-device-type IN FRAME Dialog-Frame /* Устройство */
DO:
    assign
  cb-device-type.
  run openbr in this-procedure no-error.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Cb-elem-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Cb-elem-type Dialog-Frame
ON VALUE-CHANGED OF Cb-elem-type IN FRAME Dialog-Frame
DO:
    assign
  cb-elem-type.
  run openbr in this-procedure no-error.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME CB-layout-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL CB-layout-type Dialog-Frame
ON VALUE-CHANGED OF CB-layout-type IN FRAME Dialog-Frame /* Тип раскладки */
DO:
  assign
  cb-layout-type.
  case cb-layout-type:
    when '' then do:
      ASSIGN
     cb-device-type:LIST-ITEMS IN FRAME {&FRAME-NAME} = {&comma-char} +
                                                             v-keyboard-list-items + {&comma-char} +
                                                             v-screen-list-items
                                                        .

    end.
    when {&th-pos-keyboard} then do:
      assign
      cb-device-type:list-items in frame {&frame-name} = {&comma-char} +
                                                             v-keyboard-list-items .

    end.
    when {&th-pos-screen} then do:
      assign
      cb-device-type:list-items in frame {&frame-name} = {&comma-char} +
                                                             v-screen-list-items .


    end.
  end case.

  run openbr in this-procedure no-error.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME CB-mode-id
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL CB-mode-id Dialog-Frame
ON VALUE-CHANGED OF CB-mode-id IN FRAME Dialog-Frame /* Режим */
DO:
    assign
  cb-mode-id.
  run openbr in this-procedure no-error.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-layout-elem
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

{ gbl/brwrefre.i " v-doc-rec = recid(X_layout-elem).  ~
  RUn OpenBR in this-procedure.  REPOSITION br-layout-elem to recid v-doc-rec No-ERROR. ~
  apply 'value-changed' to br-layout-elem. " }

{ gbl/app_help.i }

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  { gbl/getcntxt.i get }
  v-admin = lookup('admin', bttns) > 0.
  if (p-list-mode = "layout-type"
        or
        p-list-mode = "layout-device-type"
        or
        p-list-mode = "layout-device-type-mode")
  and lookup(p-layout-type, {&layout-type-list}) = 0 then do:
    message
    substitute("Неверное значение параметра p-layout-type = &1", p-layout-type)
    view-as alert-box error .
    undo main-block, return error .
  end.
  if (  p-list-mode = "layout-device-type"
        or
        p-list-mode = "layout-device-type-mode")
  and lookup(p-device-type, {&layout-type-list}) = 0 then do:
    message
    substitute("Неверное значение параметра p-device-type = &1", p-device-type)
    view-as alert-box error .
    undo main-block, return error .
  end.
  v-list-mode = p-list-mode.
  run Myenable in this-procedure .
  v-rid-list = p-rid-list.
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
  DISPLAY CB-layout-type CB-device-type Cb-elem-type CB-mode-id mark-num
      WITH FRAME Dialog-Frame.
  ENABLE b-quit b-mark b-sel b-add b-chg b-del b-lkp B-Help CB-layout-type
         CB-device-type Cb-elem-type CB-mode-id br-layout-elem mark-num
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
DEFINE VARIABLE v-ii AS INTEGER NO-UNDO.
DEFINE VARIABLE v-list-items AS CHARACTER NO-UNDO.
define variable v-h as handle no-undo .
DEFINE BUFFER buf_wi-mode FOR ub.wi-mode.
v-list-items = {&comma-char}.
DO v-ii = 1 TO NUM-ENTRIES({&layout-type-list}):
   v-list-items = v-list-items  + {&comma-char} +
                 ENTRY(v-ii, {&layout-type-list-full}) + {&comma-char} +
                  ENTRY(v-ii, {&layout-type-list}).
END.
ASSIGN
cb-layout-type:LIST-ITEM-PAIRS IN FRAME {&FRAME-NAME} = v-list-items .
v-list-items = {&comma-char}.
DO v-ii = 1 TO NUM-ENTRIES({&lelem-type-codes}):
   v-list-items = v-list-items  + {&comma-char} +
                 ENTRY(v-ii, {&lelem-type-codes-full}) + {&comma-char} +
                  ENTRY(v-ii, {&lelem-type-codes}).
END.
ASSIGN
cb-elem-type:LIST-ITEM-PAIRS IN FRAME {&FRAME-NAME} = v-list-items .

v-keyboard-list-items = {&th-pos-device-keyboard-list}.
v-SCREEN-list-items = {&th-pos-device-screen-list}.
ASSIGN
v-h = br-layout-elem:FIRST-COLUMN in frame {&frame-name}
.
DO while valid-handle(v-h) :
  if v-h:LABEL = {&label-1} then do:
    vh-layout-type-name = v-h.
  end.
  if v-h:LABEL = {&label-2} then do:
    vh-cdm-name = v-h.
  end.
  v-h = v-h:NEXT-COLUMN.
END.
v-list-items = {&comma-char}.
assign
cb-mode-id:list-item-pairs in frame {&frame-name} = v-list-items.
for each buf_wi-mode NO-LOCK WHERE buf_wi-mode.mode-type = {&wi-mode-ibs-th-pos}
:
  cb-mode-id:add-last ( substitute("&1 (&2)", string(buf_wi-mode.mode-name, "X(35)"), buf_wi-mode.mode-id), buf_wi-mode.mode-id).
end.
cb-mode-id:delete(1).
IF p-elem-type <> ? THEN do:
    cb-elem-type = p-elem-type.
END.
case p-list-mode:
   when {&all} then do:
     display
     cb-layout-type
     cb-device-type
     cb-mode-id
     with frame {&frame-name}.
   end.
   when "layout-type" then do:
      cb-layout-type = p-layout-type.
     display
     cb-device-type
     cb-mode-id
     with frame {&frame-name}.

   end.
   when "layout-device-type" then do:
     cb-layout-type = p-layout-type.
     cb-device-type = p-device-type.
     display
     cb-mode-id
     with frame {&frame-name}.
   end.
   when "layout-type" then do:
      cb-layout-type = p-layout-type.
      cb-device-type = p-device-type.
      cb-mode-id = p-mode-id.
   end.
end case.
ASSIGN
X_layout-elem.device-type:RESIZABLE IN BROWSE br-layout-elem = YES
vh-layout-type-name:resizable = yes
vh-cdm-name:resizable = yes

.
ENABLE
b-quit
b-add when (lookup("b-add", bttns) > 0) and v-admin
b-chg when (lookup("b-add", bttns) > 0) and v-admin
b-del when (lookup("b-add", bttns) > 0) and v-admin
b-lkp
B-Help
b-mark when lookup("b-mark", bttns) > 0
b-sel when lookup("b-sel", bttns) > 0
br-layout-elem
cb-layout-type when p-list-mode = {&all}
cb-device-type when (p-list-mode = {&all} or p-list-mode = "layout-type")
cb-mode-id when (p-list-mode = {&all} or p-list-mode = "layout-type" or p-list-mode = "layout-device-type")
cb-elem-type WHEN p-elem-type = ?
WITH FRAME {&frame-name}.
VIEW FRAME {&frame-name}.
IF p-elem-type <> ?  THEN DO:
  HIDE
  cb-elem-type
  IN FRAME {&FRAME-NAME}.
END.
apply "value-changed" to cb-layout-type.
run Openbr in this-procedure .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Openbr Dialog-Frame 
PROCEDURE Openbr :
OPEN QUERY br-layout-elem
FOR EACH X_layout-elem NO-LOCK where
(cb-layout-type = ''
or
X_layout-elem.layout-type = cb-layout-type)
and
(cb-device-type = ''
or
X_layout-elem.device-type = cb-device-type)
and
(cb-mode-id = ''
or
X_layout-elem.mode-id = cb-mode-id)
AND 
(cb-elem-type = ?
 OR 
 X_layout-elem.elem-type = cb-elem-type)


INDEXED-REPOSITION.
CASE v-list-mode:
   when {&all} then do:
      frame {&frame-name} :title = "Все элементы раскладки".
    assign
    vh-layout-type-name:visible  = yes
    X_layout-elem.device-type:visible in browse br-layout-elem = yes
    vh-cdm-name:visible  = yes
    .

   end.
   when "layout-type" then do:
      frame {&frame-name} :title = substitute("Элементы раскладок типа &1", p-layout-type).
      assign
      vh-layout-type-name:visible  = no
      X_layout-elem.device-type:visible in browse br-layout-elem = yes
      vh-cdm-name:visible  = yes
      .
   end.
   when "layout-device-type" then do:
      frame {&frame-name} :title = substitute("Элементы для раскладок типа &1  для &2", p-layout-type, p-device-type).
      assign
      vh-layout-type-name:visible  = no
      X_layout-elem.device-type:visible in browse br-layout-elem = no
      vh-cdm-name:visible  = yes
      .

   end.
   when "layout-device-type-mode" then do:
      frame {&frame-name} :title = substitute("Элементы раскладок типа &1 для &2 в режиме", p-layout-type, p-device-type, p-mode-id).
     assign
     vh-layout-type-name:visible  = no
     X_layout-elem.device-type:visible in browse br-layout-elem = no
     vh-cdm-name:visible  = no
     .
   end.
end case.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-lkp Dialog-Frame 
PROCEDURE proc-b-lkp :
DEFINE INPUT PARAMETER p-option AS CHARACTER NO-UNDO.
define variable v-rec as recid no-undo.
CASE p-option:
  WHEN {&TABLE_layout-elem} THEN DO:
      run adm/layoutei.w ( input parparentproc
                           ,input {&lookup} + {&comma-char} + (if v-admin then "admin" else '')
                           ,input X_layout-elem.layout-type
                           ,input X_layout-elem.device-type
                           ,input X_layout-elem.mode-id
                           ,input X_layout-elem.widget-id
                           ,input-output v-rec) no-error.

  END.
END CASE.
IF ERROR-STATUS:ERROR THEN UNDO, RETURN ERROR.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

