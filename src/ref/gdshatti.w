&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE Temp-hattr NO-UNDO LIKE ub.gds-host-attr
       field user-can-edit as log
       field code as char
       field value_ as character.
DEFINE TEMP-TABLE tt0-gds-host-attr NO-UNDO LIKE ub.gds-host-attr.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Атрибуты товара на фирме

Автор: Чернова Светлана Александровна
Дата создания: 03/02/06
Author: Svetlana Chernova
Creation date: 03/02/06

Creation date: 05/08/01

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-mode as char no-undo.
define input parameter p-gds-code as int no-undo.
define input parameter p-obj-type like ub.clients.obj-type no-undo.
define input parameter p-obj-code like ub.clients.obj-code no-undo.
define input parameter p-update-instantly as logical no-undo .
define output parameter p-updated AS LOGICAL no-undo.
define INPUT-OUTPUT parameter table for tt0-gds-host-attr.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Атрибуты товара на фирме ".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ cmp/showinf.i }
{ ref/gdshattr.i "interface" parparentproc }
{ ref/attr-pop.i def }
{ ref/attr-pop.i proc }

define variable updated as logical no-undo.
define variable add-option as char no-undo.
define variable temp-doc-rec as recid no-undo.
DEFINE VARIABLE v-host-name AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-host-code LIKE ub.sysconf.host-code NO-UNDO.
define variable v-tab-order as character no-undo .

define buffer buf_clients for ub.clients.

DEFINE MENU MENU-b-add .

&scoped-define  gdshattr-type-get-error message "Ошибка при определении названия и типа атрибута товара на фирме!" ~
        skip "Обратитесь к администратору системы" skip error-status:get-message(1) skip ~
        return-value skip view-as alert-box ERROR.
&scoped-define  gdshattr-value-get-error message "Ошибка при определении значения атрибута товара на фирме!" ~
        skip "Обратитесь к администратору системы" skip error-status:get-message(1) skip ~
        return-value skip view-as alert-box ERROR.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-attr

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES Temp-hattr

/* Definitions for BROWSE br-attr                                       */
&Scoped-define FIELDS-IN-QUERY-br-attr Temp-hattr.attr-code ~
Temp-hattr.attr-value
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-attr
&Scoped-define QUERY-STRING-br-attr FOR EACH Temp-hattr NO-LOCK
&Scoped-define OPEN-QUERY-br-attr OPEN QUERY br-attr FOR EACH Temp-hattr NO-LOCK.
&Scoped-define TABLES-IN-QUERY-br-attr Temp-hattr
&Scoped-define FIRST-TABLE-IN-QUERY-br-attr Temp-hattr


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-attr}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit b-quit b-add b-lkp b-chg b-del b-help ~
goods-artic Goods-dsc-name goods-gds-code goods-prod-type goods-prod-code ~
goods-prod-name
&Scoped-Define DISPLAYED-OBJECTS goods-artic Goods-dsc-name goods-gds-code ~
goods-prod-type goods-prod-code goods-prod-name

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-add
     LABEL "&Добавить":L
     SIZE 10 BY 1 TOOLTIP "Добавить атрибут товара".

DEFINE BUTTON b-chg
     LABEL "&Изменить":L
     SIZE 10 BY 1 TOOLTIP "Изменить атрибут товара на фирме".

DEFINE BUTTON b-del
     LABEL "&Удалить":L
     SIZE 10 BY 1 TOOLTIP "Удалить  атрибут товара на фирме".

DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1 TOOLTIP "Выход с сохранением".

DEFINE BUTTON b-help
     LABEL "Помо&щь":L
     SIZE 3 BY 1.

DEFINE BUTTON b-lkp
     LABEL "&Просмотр"
     SIZE 10 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена":L
     SIZE 10 BY 1 TOOLTIP "Выход из режима".

DEFINE VARIABLE goods-artic AS CHARACTER FORMAT "X(16)":U
      VIEW-AS TEXT
     SIZE 16.4 BY 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE Goods-dsc-name AS CHARACTER FORMAT "X(60)":U
      VIEW-AS TEXT
     SIZE 61.6 BY 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE goods-gds-code AS INTEGER FORMAT ">>>>>>>>>>":U INITIAL 0
      VIEW-AS TEXT
     SIZE 11 BY 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE goods-prod-code AS INTEGER FORMAT ">>>>>>>>>":U INITIAL 0
      VIEW-AS TEXT
     SIZE 9.6 BY 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE goods-prod-name AS CHARACTER FORMAT "X(60)":U
      VIEW-AS TEXT
     SIZE 46.8 BY 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE goods-prod-type AS CHARACTER FORMAT "X(3)":U
      VIEW-AS TEXT
     SIZE 3.8 BY 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-attr FOR
      Temp-hattr SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-attr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-attr Dialog-Frame _STRUCTURED
  QUERY br-attr DISPLAY
      Temp-hattr.attr-code COLUMN-LABEL "Атрибут" FORMAT "X(50)":U
      Temp-hattr.attr-value COLUMN-LABEL "Значение" FORMAT "X(256)":U
            WIDTH 23
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 79 BY 15.33.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     b-add AT ROW 1 COL 21
     b-lkp AT ROW 1 COL 31
     b-chg AT ROW 1 COL 41
     b-del AT ROW 1 COL 51
     b-help AT ROW 1.03 COL 78
     br-attr AT ROW 4.47 COL 1
     goods-artic AT ROW 2.13 COL 1.9 NO-LABEL
     Goods-dsc-name AT ROW 2.13 COL 19 NO-LABEL
     goods-gds-code AT ROW 3.3 COL 1.8 NO-LABEL
     goods-prod-type AT ROW 3.3 COL 19 NO-LABEL
     goods-prod-code AT ROW 3.3 COL 23.4 NO-LABEL
     goods-prod-name AT ROW 3.3 COL 33.8 NO-LABEL
     SPACE(0.64) SKIP(15.65)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Атрибуты товара на фирме".


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: Temp-hattr T "?" NO-UNDO ub gds-host-attr
      ADDITIONAL-FIELDS:
          field user-can-edit as log
          field code as char
          field value_ as character
      END-FIELDS.
      TABLE: tt0-gds-host-attr T "?" NO-UNDO ub gds-host-attr
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-attr b-help Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR BROWSE br-attr IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN goods-artic IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN Goods-dsc-name IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN goods-gds-code IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN goods-prod-code IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN goods-prod-name IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN goods-prod-type IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-attr
/* Query rebuild information for BROWSE br-attr
     _TblList          = "Temp-Tables.Temp-hattr"
     _FldNameList[1]   > Temp-Tables.Temp-hattr.attr-code
"Temp-hattr.attr-code" "Атрибут" "X(50)" "character" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[2]   > Temp-Tables.Temp-hattr.attr-value
"Temp-hattr.attr-value" "Значение" "X(256)" "character" ? ? ? ? ? ? no ? no no "23" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _Query            is OPENED
*/  /* BROWSE br-attr */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Атрибуты товара на фирме */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add Dialog-Frame
ON CHOOSE OF b-add IN FRAME Dialog-Frame /* Добавить */
DO:
define buffer buf_temp-hattr for temp-hattr.
if add-option = "" then do:
  run gbl/pop-up.p ( input self:handle, input no) no-error.
end.
if add-option = "":U then return no-apply.
run proc-add-chg in this-procedure ( input yes) no-error .
if error-status:error then do:
  add-option = "":U.
  return no-apply.
end.
{&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
find first buf_temp-hattr no-lock where
                        buf_temp-hattr.code = add-option no-error.
add-option = "":U.
if avail buf_temp-hattr then
    temp-doc-rec = recid(buf_temp-hattr).
    else temp-doc-rec = ?.
reposition br-attr to recid temp-doc-rec no-error.
if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-chg Dialog-Frame
ON CHOOSE OF b-chg IN FRAME Dialog-Frame /* Изменить */
DO:
  if not avail temp-hattr then return NO-APPLY.
  run proc-add-chg in this-procedure ( input no) no-error .
  if error-status:error then return no-apply.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del Dialog-Frame
ON CHOOSE OF b-del IN FRAME Dialog-Frame /* Удалить */
DO:
define variable loc#log as logical no-undo.
define variable attr-type as character no-undo . /*тип атрибута*/
define variable attr-format as character no-undo .  /* формат атрибута*/
define variable attr-label as character no-undo .         /*лабел атрибута */
define variable attr-user-can-edit as logical no-undo .  /*пользователь может изменять в броусе*/
define variable attr-output-display as logical no-undo .  /*виден в броусе*/
define variable attr-other as char no-undo .              /*еще чего - нибудь*/
DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
  if not avail temp-hattr then return no-apply.

run gdshattr-name in this-procedure (
                                      input   temp-hattr.code
                                      ,output attr-type
                                      ,output attr-format
                                      ,output attr-label
                                      ,output attr-user-can-edit
                                      ,output attr-output-display
                                      ,output attr-other
                                                      ).
  if not attr-user-can-edit then do:
    message
    "Атрибут нельзя удалить вручную"
    view-as alert-box error .
    return no-apply.
  end.

  glog = no.
  message "Вы уверены, что хотите удалить атрибут " temp-hattr.attr-code skip
          "на фирме " v-host-name " для товара " goods-dsc-name
          view-as alert-box QUESTIOn buttons YES-NO update glog.
  if NOT glog then return no-apply.
  delete temp-hattr.
  updated = yes.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Ввод */
DO:
   RUN proc-save IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
     RETURN NO-APPLY.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-lkp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-lkp Dialog-Frame
ON CHOOSE OF b-lkp IN FRAME Dialog-Frame /* Просмотр */
DO:
  if not avail temp-hattr then return no-apply.
  RUN proc-b-lkp IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-attr
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */
 { gbl/app_help.i }
{ gbl/brwrepos.i
&line-num=5
}

{ gbl/brwrefre.i }

{ ref/tabhndmv.i v-tab-order underline-tb }
{ gbl/rethndmv.i v-tab-order underline-tb "APPLY 'CHOOSE' TO b-exit in frame {&frame-name}." }

 /* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */

MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  if NOT (p-mode = {&lookup}
        or p-mode = {&update}
        or p-mode = {&add-def}
        ) then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверный параметр вызова p-mode" p-mode
    view-as alert-box ERROR.
    return error.
  end.
  { gbl/hostcode.i p-obj-type p-obj-code v-host-code }
  find first buf_clients no-lock where
            buf_clients.obj-type = {&cmp}
        and buf_clients.obj-code = v-host-code.
  v-host-name = buf_clients.obj-name.
  { ref/attr-pop.i prepare }
  run myenable in this-procedure .
  run init-proc in this-procedure .
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
run disable_UI in this-procedure .
run attr-pop-clean-up in this-procedure ( input {&table_gds-host-attr} ).
if updated then return {&update}.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE choose-to-edit Dialog-Frame
PROCEDURE choose-to-edit :
define input parameter p-attr-code as character no-undo .
assign
add-option = p-attr-code
.
APPLY "CHOOSE" to b-add in frame {&frame-name} .
END PROCEDURE.

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
  DISPLAY goods-artic Goods-dsc-name goods-gds-code goods-prod-type
          goods-prod-code goods-prod-name
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit b-add b-lkp b-chg b-del b-help goods-artic
         Goods-dsc-name goods-gds-code goods-prod-type goods-prod-code
         goods-prod-name
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-proc Dialog-Frame
PROCEDURE init-proc :
define var  attr-type as character no-undo .          /* тип атрибута      */
define var  attr-format as character no-undo .        /* формат атрибута   */
define var  attr-label as character no-undo .         /* лабел атрибута    */
define var  attr-value as character no-undo .         /* значение атрибута */
define var  attr-user-can-edit as logical no-undo .   /* пользователь может изменять в броусе */
define var  attr-output-display as logical no-undo .  /* виден в броусе    */
define var  attr-other as char no-undo .              /* еще чего - нибудь */
define buffer buf_goods for ub.goods.
define buffer buf_prods for ub.clients.
for each  Temp-hattr share-lock:
  delete Temp-hattr.
end.
if p-mode <> {&add-def} then do:
  find first buf_goods where
          buf_goods.gds-code =  p-gds-code no-lock no-error .
  find first buf_prods where
            buf_prods.obj-code =  buf_goods.prod-code
        and buf_prods.obj-type =  buf_goods.prod-type   no-lock no-error .

  Assign
  Goods-dsc-name = buf_Goods.gds-name
  goods-artic    = buf_goods.artic
  goods-gds-code = buf_goods.gds-code
  goods-prod-type = buf_goods.prod-type
  goods-prod-code = buf_goods.prod-code
  goods-prod-name = buf_prods.obj-name

  .
  display Goods-dsc-name goods-gds-code goods-artic
  goods-prod-type goods-prod-code goods-prod-name
    with frame {&frame-name}  .
end.
For each tt0-gds-host-attr where
        tt0-gds-host-attr.host-code = v-host-code and
        tt0-gds-host-attr.gds-code  = p-gds-code
        no-lock :
  run gdshattr-name in this-procedure (
                                        input tt0-gds-host-attr.attr-code
                                        ,output attr-type
                                        ,output attr-format
                                        ,output attr-label
                                        ,output attr-user-can-edit
                                        ,output attr-output-display
                                        ,output attr-other ).
  if attr-output-display = true then DO:
    run gdshattr-value in this-procedure (
                                              input tt0-gds-host-attr.attr-code
                                            ,input p-obj-type
                                            ,input p-obj-code
                                            ,input tt0-gds-host-attr.gds-code
                                            ,output attr-value
                                            ,output attr-type ).
    create Temp-hattr.
    assign
    Temp-hattr.attr-code = attr-label
    Temp-hattr.value_ = tt0-gds-host-attr.attr-value
    Temp-hattr.attr-value = (if attr-type = {&type-log}
                            then string(tt0-gds-host-attr.attr-value = "yes":U, attr-format)
                            else tt0-gds-host-attr.attr-value)
    Temp-hattr.user-can-edit = attr-user-can-edit
    Temp-hattr.code = tt0-gds-host-attr.attr-code
    temp-hattr.gds-code = tt0-gds-host-attr.gds-code
    temp-hattr.host-code = tt0-gds-host-attr.host-code
    .
  End.
End.   /* FOR EACH */
{&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
assign
v-tab-order = "b-exit,b-quit,b-add,b-lkp,b-chg,b-del,b-help,br-attr"
b-add:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-b-add:HANDLE
temp-hattr.attr-value:RESIZABLE IN BROWSE br-attr = YES
.
frame {&frame-name}:TITLE = frame {&frame-name}:TITLE + " " + string(v-host-code) + " " + v-host-name.
if p-mode <> {&lookup} then do:
  run attr-pop-create-items in this-procedure  (
                                                 input {&table_gds-obj-attr}
                                                ,input 'gdshattr-manual-edit'   /*p-get-section-num-proc-name*/
                                                ,input 'gdshattr-tooltip'
                                                ,input 'choose-to-edit'
                                                ,input menu menu-b-add:handle
                                                ,input {&gdshattr-list}
                                              ).
end.
DISPLAY
Goods-dsc-name
goods-gds-code
goods-artic
WITH FRAME {&frame-name}.
ENABLE
b-exit when p-mode <> {&lookup}
b-quit
b-del when p-mode <> {&lookup}
b-add when p-mode <> {&lookup}
b-lkp
b-chg when p-mode <> {&lookup}
b-help br-attr Goods-dsc-name goods-gds-code goods-artic
WITH FRAME {&frame-name}.
VIEW FRAME {&frame-name}.
if p-mode = {&lookup} then do:
  hide
  b-exit
  in frame {&frame-name} .
  assign
  b-quit:label = "&Выход"
  b-quit:col    = 1
  .
end.
ASSIGN b-add:MENU-MOUSE = 1.
{&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-add-chg Dialog-Frame
PROCEDURE proc-add-chg :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-add as logical no-undo .
define variable attr-type as character no-undo . /*тип атрибута*/
define variable attr-format as character no-undo .  /* формат атрибута*/
define variable attr-label as character no-undo .         /*лабел атрибута */
define variable attr-user-can-edit as logical no-undo .  /*пользователь может изменять в броусе*/
define variable attr-output-display as logical no-undo .  /*виден в броусе*/
define variable attr-other as char no-undo .              /*еще чего - нибудь*/
define variable attr-value as character no-undo .
define variable v-attr-value as character no-undo .
define variable v-init as character no-undo .
define var loc#log as logical no-undo.
DEFINE VARIABLE v-spr as character no-undo .
define variable v-spr-param as character no-undo .
define variable v-check as character no-undo .
define variable jj as integer no-undo .
define variable v-setted as logical no-undo .
define variable v-correct as logical no-undo .
define variable v-error-code as character no-undo .

case p-add:
  when yes then do:
    if p-mode <> {&add-def} then do:
      run gdshattr-exist in this-procedure (
                                            input p-gds-code
                                            ,input p-obj-type
                                            ,input p-obj-code
                                            ,input add-option
                                            ,output loc#log)  no-error.
      if error-status:error then return error.
      if loc#log then do:
        message
        "Данный атрибут уже существует"
        view-as alert-box error .
        return error.
      end.
    end.
    run gdshattr-name in this-procedure (
                                          input  add-option          /* p-code           */
                                          ,output attr-type           /* p-type           */
                                          ,output attr-format         /* p-format         */
                                          ,output attr-label          /* p-label          */
                                          ,output attr-user-can-edit  /* p-user-can-edit  */
                                          ,output attr-output-display /* p-output-display */
                                          ,output attr-other          /* p-other          */
                                          ) no-error .
    if error-status :error then do:
      return error .
    end.
    CASE attr-type:
      when {&type-log} then do:
        assign
        v-attr-value = "yes":U
        .
      end.
      when {&type-int} or when {&type-dec} then do:
        assign
        v-attr-value = if v-init <> "":U
                      then attr-value
                      else string(0)
        .
      end.
      when {&type-date} then do:
        assign
        v-attr-value = ?
        .
      end.
      when {&type-char} then do:
        assign
        v-attr-value = if v-init <> "":U
                      then attr-value
                      else "":U
        .
      end.
    END CASE.
    assign
    attr-value = v-attr-value
    .
  end.
  when no then do:
    run gdshattr-name in this-procedure(
                                          input TEMP-hattr.code
                                          ,output attr-type
                                          ,output attr-format
                                          ,output attr-label
                                          ,output attr-user-can-edit
                                          ,output attr-output-display
                                          ,output attr-other) no-error.
    IF ERROR-STATUS:ERROR THEN DO:
        {&gdshattr-type-get-error}
        return error.
    END.
    attr-value  = temp-hattr.value_.
  end.
END CASE.
IF attr-user-can-edit Then DO:
  do jj = 1 to num-entries(attr-other, {&slash-char}):
    if entry(1, entry(jj, attr-other, {&slash-char}), "=":U) = "spr-ext":U
    or entry(1, entry(jj, attr-other, {&slash-char}), "=":U) = "spr":U
    then do:
      assign
      v-spr = string(entry(2, entry(jj, attr-other, {&slash-char}), "=":U))
      .
    end.
    if entry(1, entry(jj, attr-other, {&slash-char}), "=":U) = "spr-param":U then do:
      assign
      v-spr-param = string(entry(2, entry(jj, attr-other, {&slash-char}), "=":U))
      .
    end.
    if entry(1, entry(jj, attr-other, {&slash-char}), "=":U) = "check-ext":U then do:
      assign
      v-check = string(entry(2, entry(jj, attr-other, {&slash-char}), "=":U))
      .
    end.
  end.
  if v-spr = "":U then do:
    run gbl/d-prompt.w (
      'title=':u + "Изменение атрибута товара на фирме" + '\':u
    + 'text1=':u + attr-label + '\':u
    + 'format=' + (if attr-type = {&type-log} then "yes/no" else attr-format) + '\':u
    + 'type=' + attr-type + '\':u
    + 'fillin_row=2\':u
    + 'fillin_col=4\':u
    + 'fillin_width=20\':u
    + 'fillin_height=1\':u
    + 'max-chars=70\':u     /*- максимальное количество символов для редактора*/
    + 'readonly=' + (if p-mode = {&lookup} then 'yes':u else 'no':u) + '\':u
    , input-output attr-value
        ).
    if return-value = 'false':u then return error.
  end.
  else do:
    if v-spr-param = "":U then do:
      run  value(v-spr) in this-procedure  (
                                             input p-gds-code
                                            ,input p-obj-type
                                            ,input p-obj-code
                                            ,input-output attr-value
                                            ,output v-setted) no-error .

    end.
    else do:
      run  value(v-spr) in this-procedure (
                                            input p-gds-code
                                            ,input p-obj-type
                                            ,input p-obj-code
                                            ,input v-spr-param
                                            ,input-output attr-value
                                            ,output v-setted) no-error .


     end.
   if not v-setted then return error.
  end.
  if v-check <> "":U then do:
    run value(v-check) (
                       input p-gds-code
                      ,input p-obj-type
                      ,input p-obj-code
                      ,input attr-value
                      ,input (if p-add then {&add-def} else {&update})
                      ,output v-correct
                      ,output v-error-code) no-error.
    if error-status:error then do:
      message
      "Ошибка при проверке корректности задаваемого значения атрибута" skip
      error-status:get-message(1) skip
      view-as alert-box error .
      undo, return error .
    end.
    if not v-correct then do:
      message
      "Задаваемое значение атрибута некорректно" skip
      return-value
      view-as alert-box error .
      undo, return error .
    end.
  end.
  run temp-gdshattr-write in this-procedure (
                                              input p-gds-code
                                              ,input p-obj-type
                                              ,input p-obj-code
                                              ,input (if p-add then add-option else temp-hattr.code)
                                              ,input attr-value)  no-error.
  IF NOT error-status:error then do:
      assign
      updated = yes
      .
      br-attr:refresh() in frame {&frame-name} no-error .
  END.
End.
Else message "Изменение атрибута невозможно !" view-as alert-box error.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-lkp Dialog-Frame
PROCEDURE proc-b-lkp :
define variable attr-type as character no-undo . /*тип атрибута*/
define variable attr-format as character no-undo .  /* формат атрибута*/
define variable attr-label as character no-undo .         /*лабел атрибута */
define variable attr-user-can-edit as logical no-undo .  /*пользователь может изменять в броусе*/
define variable attr-output-display as logical no-undo .  /*виден в броусе*/
define variable attr-other as char no-undo .              /*еще чего - нибудь*/
define variable attr-value as char no-undo .              /*для знач по умолч*/
define variable v-run-name as character no-undo .
define variable jj as integer no-undo .

run gdshattr-name in this-procedure (
                                        input temp-hattr.code
                                        ,output attr-type
                                        ,output attr-format
                                        ,output attr-label
                                        ,output attr-user-can-edit
                                        ,output attr-output-display
                                        ,output attr-other) no-error.
IF ERROR-STATUS:ERROR THEN DO:
    {&gdshattr-type-get-error}
    return error.
END.
do jj = 1 to num-entries(attr-other, {&slash-char}):
  if entry(1, entry(jj, attr-other, {&slash-char}), "=":U) = "display" then do:
    v-run-name = entry(2, entry(jj, attr-other, {&slash-char}), "=":U).
    run value(v-run-name) in this-procedure (
                                             input p-gds-code
                                            ,input temp-hattr.attr-code
                                            ,input temp-hattr.value_
                                            ,input p-obj-type
                                            ,input p-obj-code
                                             )
                                             no-error .
    if error-status:error then undo, return error .
    return .
  end.
END.
BELL.

END PROCEDURE.

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save Dialog-Frame
PROCEDURE proc-save :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE VARIABLE v-updated AS LOGICAL NO-UNDO.
define variable v-created as logical no-undo .
define variable v-deleted as logical no-undo .
define variable v-updated-str as character no-undo .
define variable v-type as character no-undo .
for each temp-hattr NO-LOCK where
       temp-hattr.gds-code = p-gds-code
   AND temp-hattr.host-code = v-host-code :
   find first tt0-gds-host-attr NO-LOCK WHERE
          tt0-gds-host-attr.gds-code = temp-hattr.gds-code
    AND   tt0-gds-host-attr.host-code = temp-hattr.host-code
    AND   tt0-gds-host-attr.attr-code = temp-hattr.code no-error.
  assign
  v-updated = no.
  if available  tt0-gds-host-attr then do:
    BUFFER-COMPARE temp-hattr
                TO tt0-gds-host-attr
                case-sensitive
                SAVE result IN v-updated-str.
    assign
    v-created = yes
    v-updated = (v-updated-str <> "":U)
    .
  end.
  else do:
    assign
    v-updated = yes.
  end.
  if v-updated then do:
    run tt0-gdshattr-write in this-procedure (
                                                 input p-gds-code
                                                ,input p-obj-type
                                                ,input p-obj-code
                                                ,input temp-hattr.code
                                                ,input temp-hattr.value_)  no-error.
    if error-status:error then do:
      message
      "Ошибка при сохранении атрибута товара на фирме" skip
      "товар" p-gds-code skip
      "фирма" temp-hattr.host-code
      "Атрибут" temp-hattr.attr-code
      view-as alert-box  error .
      undo, return error  .
    end.
    updated = yes.
  end.
  ASSIGN
  p-updated = v-updated OR p-updated.
End.
FOR EACH tt0-gds-host-attr where
         tt0-gds-host-attr.gds-code = p-gds-code
    AND  tt0-gds-host-attr.host-code = v-host-code :
  FIND FIRST temp-hattr NO-LOCK WHERE
            temp-hattr.gds-code = tt0-gds-host-attr.gds-code
        AND temp-hattr.host-code = tt0-gds-host-attr.host-code
        AND temp-hattr.code = tt0-gds-host-attr.attr-code NO-ERROR.
    IF NOT AVAILABLE temp-hattr THEN DO:
      DELETE tt0-gds-host-attr.
      assign
      v-deleted = yes.
      ASSIGN
      p-updated = (v-deleted OR p-updated).
    END.
END.
if p-updated
and p-update-instantly then do:
  run ref/gdshatr1.p (
                     input p-mode
                    ,input p-gds-code
                    ,input v-host-code
                    ,input p-obj-type
                    ,input p-obj-code
                    ,INPUT table tt0-gds-host-attr
                    ) no-error .
  if error-status:error then do:
    message
    substitute("Ошибка при сохранении атрибутов товара на фирме:&1&2&1&3"
               , {&new-line}
               , error-status:get-message(1)
               , return-value )
    view-as alert-box
    error .
    undo, return error .
  end.
end.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE temp-gdshattr-exist Dialog-Frame
PROCEDURE temp-gdshattr-exist :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
  on error undo, return error
  :
    define input parameter p-gds-code like ub.gds-host-attr.gds-code   no-undo .
    define input parameter p-obj-type like ub.clients.obj-type   no-undo .
    define input parameter p-obj-code like ub.clients.obj-code   no-undo .
    define input parameter p-code     like ub.gds-host-attr.attr-code  no-undo .
    define OUTPUT parameter p-EXIST   AS LOGICAL no-undo .
    DEFINE buffer buf_temp-hattr for temp-hattr .

    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    define var attr-host-code as int no-undo .

   { gbl/hostcode.i p-obj-type p-obj-code attr-host-code no-error }.

    run gdshattr-name in this-procedure (
                                          input  p-code           /* p-code           */
                                          ,output v-type           /* p-type           */
                                          ,output v-format         /* p-format         */
                                          ,output v-label          /* p-label          */
                                          ,output v-user-can-edit  /* p-user-can-edit  */
                                          ,output v-output-display /* p-output-display */
                                          ,output v-other          /* p-other          */
                                          ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.

    find first buf_temp-hattr NO-lock where
               buf_temp-hattr.gds-code  = p-gds-code AND
               buf_temp-hattr.host-code  = attr-host-code AND
               buf_temp-hattr.attr-code = p-code no-error .
    if available buf_temp-hattr then do:
      P-EXIST = YES.
    end.
  end.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE temp-gdshattr-write Dialog-Frame
PROCEDURE temp-gdshattr-write :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  do
  on error undo, return error
  :
    define input parameter p-gds-code like ub.gds-host-attr.gds-code   no-undo .
    define input parameter p-obj-type like ub.clients.obj-type   no-undo .
    define input parameter p-obj-code like ub.clients.obj-code   no-undo .
    define input parameter p-code     like ub.gds-host-attr.attr-code  no-undo .
    define input parameter p-value    like ub.gds-host-attr.attr-value no-undo .

    define buffer buf_temp-hattr for temp-hattr .

    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    define var attr-host-code as int no-undo .

   { gbl/hostcode.i p-obj-type p-obj-code attr-host-code no-error }.

    run gdshattr-name in this-procedure (
                                          input  p-code           /* p-code           */
                                          ,output v-type           /* p-type           */
                                          ,output v-format         /* p-format         */
                                          ,output v-label          /* p-label          */
                                          ,output v-user-can-edit  /* p-user-can-edit  */
                                          ,output v-output-display /* p-output-display */
                                          ,output v-other          /* p-other          */
                                          ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.

    find first buf_temp-hattr exclusive-lock where
               buf_temp-hattr.gds-code  = p-gds-code AND
               buf_temp-hattr.host-code  = attr-host-code AND
               buf_temp-hattr.code = p-code no-error .
    if not available buf_temp-hattr then do:
      create buf_temp-hattr .
      assign
      buf_temp-hattr.gds-code  = p-gds-code
      buf_temp-hattr.host-code  = attr-host-code
      buf_temp-hattr.attr-code = v-label
      buf_temp-hattr.code      = p-code
      buf_temp-hattr.attr-value = (if v-type = {&type-log} then string(logical(p-value), v-format) else p-value)
      buf_temp-hattr.value_ = p-value
      no-error
      .
    end.
    ELSE
    assign
    buf_temp-hattr.attr-value = (if v-type = {&type-log} then string(logical(p-value), v-format) else p-value)
    buf_temp-hattr.value_ = p-value
    .

  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE tt0-gdshattr-write Dialog-Frame
PROCEDURE tt0-gdshattr-write :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  do
  on error undo, return error
  :
    define input parameter p-gds-code like ub.gds-host-attr.gds-code   no-undo .
    define input parameter p-obj-type like ub.clients.obj-type   no-undo .
    define input parameter p-obj-code like ub.clients.obj-code   no-undo .
    define input parameter p-code     like ub.gds-host-attr.attr-code  no-undo .
    define input parameter p-value    like ub.gds-host-attr.attr-value no-undo .

    define buffer buf_tt0-gds-host-attr for tt0-gds-host-attr .

    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    define var attr-host-code as int no-undo .

   { gbl/hostcode.i p-obj-type p-obj-code attr-host-code no-error }.

    run gdshattr-name in this-procedure (
                                          input  p-code           /* p-code           */
                                          ,output v-type           /* p-type           */
                                          ,output v-format         /* p-format         */
                                          ,output v-label          /* p-label          */
                                          ,output v-user-can-edit  /* p-user-can-edit  */
                                          ,output v-output-display /* p-output-display */
                                          ,output v-other          /* p-other          */
                                          ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.

    find first buf_tt0-gds-host-attr exclusive-lock where
               buf_tt0-gds-host-attr.gds-code  = p-gds-code AND
               buf_tt0-gds-host-attr.host-code  = attr-host-code AND
               buf_tt0-gds-host-attr.attr-code = p-code no-error .
    if not available buf_tt0-gds-host-attr then do:
      create buf_tt0-gds-host-attr .
      assign
        buf_tt0-gds-host-attr.gds-code  = p-gds-code
        buf_tt0-gds-host-attr.host-code  = attr-host-code
        buf_tt0-gds-host-attr.attr-code = p-code
        buf_tt0-gds-host-attr.attr-value = p-value no-error
      .
    end.
    ELSE
    assign
    buf_tt0-gds-host-attr.attr-value = p-value no-error
    .
    release buf_tt0-gds-host-attr no-error .
    if error-status:error then do:
      undo, return error return-value .
    end.


  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
