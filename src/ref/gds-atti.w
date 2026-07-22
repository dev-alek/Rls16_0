&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame

using ibs.th.str.mercury.*.
using ibs.th.gbl.storage.*.
using ibs.th.bge.mercury.*.

/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE temp-attr NO-UNDO LIKE ub.goods-attr
       field user-can-edit as log
       field code as char
       field value_ as char
       field grp as logical
       field fdisable as logical
       INDEX attrc is
       UNIQUE PRIMARY
       code
       grp
       INDEX attrcl is UNIQUE
       attr-code
       grp
       .
{ ref/g-attr-tt.i}



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Атрибуты товара

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/04/05
Author: Bakhtadze Natalya
Creation date: 10/04/05

------------------------------------------------------------------------*/
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-mode as character no-undo.
define input parameter p-gds-code as integer no-undo.
define input parameter p-update-instantly as logical no-undo .
define output parameter p-updated AS LOGICAL no-undo.
define INPUT-OUTPUT parameter table for tt0-goods-attr.


define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Атрибуты товара".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }
{ ref/gds-attr.i "interface" parparentproc }
{ gbl/getcntxt.i def }
{ ref/attr-pop.i def }
{ ref/attr-pop.i proc }
{ gbl/objsrv.i }
   
{ gbl/color.i }
{ gbl/ggoattr.i  }

define variable updated      as logical   no-undo .
DEFINE VARIABLE added        as logical   no-undo .
define variable add-option   as character no-undo .
define variable ini-title    as character no-undo .
define variable temp-doc-rec as recid     no-undo .
define variable dops         as character no-undo .
define variable dopst        as character no-undo .
define variable v-tab-order  as character no-undo .
define variable alco-val-log as logical   no-undo .
define buffer buf_db for ub.db.

{ cmp/gds-list.i gds-list def "new shared" }
&scoped-define  gds-attr-type-get-error message "Ошибка при определении названия и типа атрибута товара" ~
        "Обратитесь к администратору системы" skip error-status:get-message(1) skip ~
        return-value skip view-as alert-box ERROR.
&scoped-define  gds-attr-value-get-error message "Ошибка при определении значения атрибута товара!" ~
        "Обратитесь к администратору системы" skip error-status:get-message(1) skip ~
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
&Scoped-define INTERNAL-TABLES temp-attr

/* Definitions for BROWSE br-attr                                       */
&Scoped-define FIELDS-IN-QUERY-br-attr temp-attr.attr-code ~
temp-attr.attr-value
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-attr
&Scoped-define QUERY-STRING-br-attr FOR EACH temp-attr no-lock where temp-attr.fdisable ne yes
&Scoped-define OPEN-QUERY-br-attr OPEN QUERY br-attr FOR EACH temp-attr no-lock where temp-attr.fdisable ne yes.
&Scoped-define TABLES-IN-QUERY-br-attr temp-attr
&Scoped-define FIRST-TABLE-IN-QUERY-br-attr temp-attr


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-attr}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit b-quit b-add b-lkp b-chg b-del ~
b-help goods-artic Goods-dsc-name goods-gds-code goods-prod-type ~
goods-prod-code goods-prod-name
&Scoped-Define DISPLAYED-OBJECTS goods-artic Goods-dsc-name goods-gds-code ~
goods-prod-type goods-prod-code goods-prod-name

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Menu Definitions                                                     */
DEFINE MENU MENU-b-add .

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-add
     LABEL "&Добавить":L
     SIZE 10 BY 1 TOOLTIP "Добавить атрибут товара".

DEFINE BUTTON b-chg
     LABEL "&Изменить":L
     SIZE 10 BY 1 TOOLTIP "Изменить атрибут товара".

DEFINE BUTTON b-del
     LABEL "&Удалить":L
     SIZE 10 BY 1 TOOLTIP "Удалить атрибут товара".

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
      temp-attr SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-attr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-attr Dialog-Frame _STRUCTURED
  QUERY br-attr DISPLAY
      temp-attr.attr-code COLUMN-LABEL "Атрибут" FORMAT "X(50)":U
      temp-attr.attr-value COLUMN-LABEL "Значение" FORMAT "X(255)":U width 48
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98.8 BY 15.33.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     b-add AT ROW 1 COL 21
     b-lkp AT ROW 1 COL 31
     b-chg AT ROW 1 COL 41
     b-del AT ROW 1 COL 51
     b-help AT ROW 1 COL 95
     br-attr AT ROW 4.47 COL 1
     goods-artic AT ROW 2.13 COL 1.9 NO-LABEL
     Goods-dsc-name AT ROW 2.13 COL 19 NO-LABEL
     goods-gds-code AT ROW 3.3 COL 1.8 NO-LABEL
     goods-prod-type AT ROW 3.3 COL 19 NO-LABEL
     goods-prod-code AT ROW 3.3 COL 23.4 NO-LABEL
     goods-prod-name AT ROW 3.3 COL 33.8 NO-LABEL
     SPACE(19.15) SKIP(17.89)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Атрибуты товара".


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: temp-attr T "?" NO-UNDO ub goods-attr
      ADDITIONAL-FIELDS:
          field user-can-edit as log
          field code as char
          field value_ as char
          INDEX attrc is
          UNIQUE PRIMARY
          code
          INDEX attrcl is UNIQUE
          attr-code

      END-FIELDS.
      TABLE: tt0-goods-attr T "?" NO-UNDO ub goods-attr
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

ASSIGN
   b-add:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-b-add:HANDLE.
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
     _TblList          = "Temp-Tables.temp-attr"
     _FldNameList[1]   > Temp-Tables.temp-attr.attr-code
"temp-attr.attr-code" "Атрибут" "X(50)" "character" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[2]   > Temp-Tables.temp-attr.attr-value
"temp-attr.attr-value" "Значение" "X(255)" "character" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _Query            is OPENED
*/  /* BROWSE br-attr */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Атрибуты товара */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add Dialog-Frame
ON CHOOSE OF b-add IN FRAME Dialog-Frame /* Добавить */
DO:
  define buffer buf_temp-attr for temp-attr.
  if add-option = "" then do:
       run gbl/pop-up.p ( input self:handle, input no) no-error.
  end.
  if add-option = "":U then return no-apply.
  run proc-add-chg in this-procedure ( input yes ) no-error.
  if error-status:error then do:
    add-option = "":U.
    return no-apply.
  end.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
  apply "VALUE-CHANGED" to br-attr IN frame {&frame-name}.
  find first buf_temp-attr no-lock where
             buf_temp-attr.code = add-option no-error.
  add-option = "":U.
  if avail buf_temp-attr then
      temp-doc-rec = recid(buf_temp-attr).
      else temp-doc-rec = ?.
  reposition br-attr to recid temp-doc-rec no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-attr Dialog-Frame
ON ROW-DISPLAY OF br-attr IN FRAME Dialog-Frame
DO:
   define buffer buf_temp-attr for temp-attr.
   define variable vColor as integer no-undo.
   if available (temp-attr) 
   then do:
      if temp-attr.grp eq no
      then
         find first buf_temp-attr where buf_temp-attr.gds-code  eq temp-attr.gds-code
                                    and buf_temp-attr.attr-code eq temp-attr.attr-code
                                    and buf_temp-attr.grp       ne temp-attr.grp
         no-lock no-error.
      
      vColor = if temp-attr.grp
               then GRAY_COLOR
               else if available buf_temp-attr
               then (if buf_temp-attr.attr-value eq temp-attr.attr-value
                    then LIGHT_RED_COLOR
                    else DARK_GREY_COLOR)
               else BLACK_COLOR.
      temp-attr.attr-value:fGCOLOR in browse br-attr = vColor.
      temp-attr.attr-code:fGCOLOR in browse br-attr = vColor. 
   end.
end.
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-chg Dialog-Frame
ON CHOOSE OF b-chg IN FRAME Dialog-Frame /* Изменить */
DO:
  if not avail temp-attr then return no-apply.
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
  define buffer buf_temp-attr for temp-attr.
  define variable loc#log             as logical   no-undo .
  define variable attr-type           as character no-undo . /*тип атрибута*/
  define variable attr-format         as character no-undo . /* формат атрибута*/
  define variable attr-label          as character no-undo . /*лабел атрибута */
  define variable attr-user-can-edit  as logical   no-undo . /*пользователь может изменять в броусе*/
  define variable attr-output-display as logical   no-undo . /*виден в броусе*/
  define variable attr-other          as character no-undo . /*еще чего - нибудь*/
  define variable jj                  as integer   no-undo .
  define variable v-check             as character no-undo .
  define variable v-correct           as logical   no-undo .
  define variable v-error-code        as character no-undo .
  if not available temp-attr then return no-apply.
  /*  if temp-attr.code = {&attr-alcohol-prod}*/
  /*  and alco-val-log <> yes  then do:       */
  /*     message                              */
  /*     "Запрещена работа с атрибутом"       */
  /*     view-as alert-box error.             */
  /*     return no-apply.                     */
  /*  end.                                    */
  if temp-attr.code = {&attr-mercur_FGIS} then 
  do:
    define variable ii             as integer   no-undo .
    define variable gdsMercsubsObj as class     gdsmercsubs.
    define variable gdsmercstrObj  as class     gdsmercstr.
    define variable gdsMercObj     as class     gdsmercsub.
    define VARIABLE f-guid         as character no-undo .     
  
    gdsMercsubsObj = new gdsmercsubs ().
    gdsmercstrObj = new gdsmercstr ().
  
    gdsMercsubsObj = gdsmercstrObj:getgdsmercs(p-gds-code).
  
    if VALID-OBJECT (gdsMercsubsObj:GdsMercsubsCurr) then
    do:
      do ii = 1 to gdsMercsubsObj:GetItem (ii): 
        gdsMercObj = gdsMercsubsObj:GdsMercsubsCurr. /* выдернула конкретны объект*/
        assign
          f-guid = gdsMercObj:GUID_       
          .
      end.
    end. 
    if f-guid <> "" then 
    do:
      message
        "Необходимо удалить синхронизацию товара с Меркурием" skip
        view-as alert-box error .
      return NO-APPLY .
    end.         
  end.    

  if temp-attr.code = {&attr-item-matter-mark} then 
  do:
    message
      "Атрибут нельзя удалить"
      view-as alert-box error .
    return no-apply.     
  end.   
  run gds-attr-name in this-procedure (
    input  temp-attr.code      /* p-code           */
    ,output attr-type           /* p-type           */
    ,output attr-format         /* p-format         */
    ,output attr-label          /* p-label          */
    ,output attr-user-can-edit  /* p-user-can-edit  */
    ,output attr-output-display /* p-output-display */
    ,output attr-other          /* p-other          */
    ) no-error .
  if error-status :error then 
  do:
    return no-apply .
  end.
  if not attr-user-can-edit then 
  do:
    message
      "Атрибут нельзя удалить вручную"
      view-as alert-box error .
    return no-apply.
  end.
  do jj = 1 to num-entries(attr-other, {&slash-char}):
    if entry(1, entry(jj, attr-other, {&slash-char}), "=":U) = "check":U then 
    do:
      assign
        v-check = string(entry(2, entry(jj, attr-other, {&slash-char}), "=":U))
        .
    end.
  end.
  if v-check <> "":U then 
  do:
    run value(v-check) (
      input p-gds-code
      ,input temp-attr.code
      ,input attr-value
      ,input {&deletion}
      ,output v-correct
      ,output v-error-code) no-error.
    if error-status:error then 
    do:
      message
        "Ошибка при проверке корректности удаления атрибута" skip
        error-status:get-message(1) skip
        return-value
        view-as alert-box error .
      undo, return no-apply .
    end.
    if not v-correct then 
    do:
      message
        "Удаление атрибута некорректно" skip
        return-value
        view-as alert-box error .
      undo, return no-apply .
    end.
  end.
  loc#log = no.
  message
    "Вы уверены, что хотите удалить атрибут " temp-attr.attr-code skip
    " для товара " goods-dsc-name
    view-as alert-box QUESTIOn buttons YES-NO update loc#log.
  if NOT loc#log then return no-apply.
        if temp-attr.grp then 
      do: 
         define buffer bf_temp-attr for temp-attr .     
         find first buf_temp-attr where buf_temp-attr.gds-code eq temp-attr.gds-code
            and buf_temp-attr.code     eq temp-attr.code
            and buf_temp-attr.grp no-error.
         if available buf_temp-attr
            then
            buf_temp-attr.fdisable = no.
         create bf_temp-attr.
         buffer-copy buf_temp-attr except buf_temp-attr.grp buf_temp-attr.attr-value buf_temp-attr.value_ to bf_temp-attr .
         bf_temp-attr.fdisable = true .
         delete temp-attr.
      end.
      else 
      do:
         find first buf_temp-attr where buf_temp-attr.gds-code eq temp-attr.gds-code
            and buf_temp-attr.code     eq temp-attr.code
            and buf_temp-attr.grp no-error.
         if available buf_temp-attr
            then
            buf_temp-attr.fdisable = no.
         delete temp-attr.
      end.
  updated = yes.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
  apply "VALUE-CHANGED" to br-attr IN frame {&frame-name}.
  
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
  if not avail temp-attr then return no-apply.
  RUN proc-b-lkp IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-quit
&Scoped-define BROWSE-NAME br-attr
&Scoped-define SELF-NAME br-attr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-attr Dialog-Frame
ON MOUSE-SELECT-DBLCLICK OF br-attr IN FRAME Dialog-Frame
DO:
  if not avail temp-attr then return no-apply.
  RUN proc-b-lkp IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-attr Dialog-Frame
ON VALUE-CHANGED OF br-attr IN FRAME Dialog-Frame
DO:
   if p-mode ne {&lookup}
   then do:
      b-chg:visible = available temp-attr and not temp-attr.grp.
      b-del:visible = available temp-attr and not temp-attr.grp.
   end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-attr Dialog-Frame
ON RETURN OF br-attr IN FRAME Dialog-Frame
DO:
  if not avail temp-attr then return no-apply.
  RUN proc-b-lkp IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


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
  ini-title  = frame {&frame-name}:TITLE.
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
  /*проверим что update может быть */
  if p-mode = {&update}
  or p-mode = {&add-def}
  then do:
    { gbl/getcntxt.i get }
    find first buf_db no-lock where buf_db.db-num = v-cntxt-db-num.
    if not buf_db.add-goods then do:
      message
      vss-workfile vss-revision vss-description skip
      "Редактирование атрибутов товара доступно только в той БД,  которой разрешено добавление товаров" skip
      "Текущая БД" v-cntxt-db-num
      view-as alert-box error .
      undo, return error.
    end.
  end.
  for each  temp-attr share-lock:
    delete temp-attr.
  end.
  { ref/attr-pop.i prepare }
  RUN MyEnable in this-procedure .
  Run init-proc in this-procedure .
  apply "VALUE-CHANGED" to br-attr IN frame {&frame-name}.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI in this-procedure .
run attr-pop-clean-up in this-procedure ( input {&table_goods-attr} ).
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
define buffer buf_clients for ub.clients.
define buffer buf_prods for ub.clients.


  if p-mode = {&update}  then.
  else empty temp-table temp-attr.

if p-mode <> {&add-def} then do:
  find first buf_goods where
           buf_goods.gds-code =  p-gds-code no-lock no-error .
  find first buf_prods where
              buf_prods.obj-code =  buf_goods.prod-code
          and buf_prods.obj-type =  buf_goods.prod-type  no-lock no-error .

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
 For each tt0-goods-attr where
         tt0-goods-attr.gds-code  = p-gds-code  no-lock :
    run gds-attr-name in this-procedure (
                                             input tt0-goods-attr.attr-code
                                            ,output attr-type
                                            ,output attr-format
                                            ,output attr-label
                                            ,output attr-user-can-edit
                                            ,output attr-output-display
                                            ,output attr-other ).
    if attr-output-display = true then DO:
      find first temp-attr where
                temp-attr.code = tt0-goods-attr.attr-code
            AND temp-attr.gds-code = tt0-goods-attr.gds-code
            and temp-attr.grp      = tt0-goods-attr.grp no-error.
      if not available temp-attr then do:
        create temp-attr.
        assign
        temp-attr.attr-code = attr-label
        temp-attr.value_ = tt0-goods-attr.attr-value
        temp-attr.attr-value = (if attr-type = {&type-log}
                                then string(tt0-goods-attr.attr-value = "yes":U, attr-format)
                                else tt0-goods-attr.attr-value)
        temp-attr.user-can-edit = attr-user-can-edit
        temp-attr.code = tt0-goods-attr.attr-code
        temp-attr.gds-code = tt0-goods-attr.gds-code
        temp-attr.grp      = tt0-goods-attr.grp
        temp-attr.fdisable = tt0-goods-attr.fdisable
        
        .
        
      end.
    End.
  End.   /* FOR EACH */
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
  apply "VALUE-CHANGED" to br-attr IN frame {&frame-name}.
  
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
define variable alco-val as character no-undo .
define variable alco-type as character no-undo .
assign
v-tab-order = "b-exit,b-quit,b-add,b-lkp,b-chg,b-del,b-help,br-attr".
ASSIGN
temp-attr.attr-code:resizable in browse br-attr = yes
temp-attr.attr-value:resizable in browse br-attr = yes.
.

if p-mode <> {&lookup} then do:
  run attr-pop-create-items in this-procedure  (
                                                input {&table_goods-attr}
                                                ,input 'gds-attr-manual-edit'   /*p-get-section-num-proc-name*/
                                                ,input 'gds-attr-tooltip'
                                                ,input 'choose-to-edit'
                                                ,input menu menu-b-add:handle
                                                ,input {&gds-attr-list}
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
b-chg when p-mode <> {&lookup}
b-lkp
b-help
br-attr
Goods-dsc-name
goods-gds-code
goods-artic
WITH FRAME {&frame-name} .
VIEW FRAME {&frame-name} .
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
/*{ gbl/conf-rd.i                          */
/*  "'alcohol'"                            */
/*  "''"                                   */
/*  "''"                                   */
/*  0                                      */
/*  "''"                                   */
/*  "''"                                   */
/*  "''"                                   */
/*  no                                     */
/*  alco-val                               */
/*  alco-type                              */
/*  no-error }                             */
/*assign                                   */
/*alco-val-log = logical(alco-val) no-error*/
/*.                                        */
/*if p-mode <> {&lookup}                                                 */
/*and alco-val-log <> yes then do:                                       */
/*  find first tt-attr-property where                                    */
/*            tt-attr-property.table-name = {&table_goods-attr}          */
/*        and tt-attr-property.attr-code = {&attr-alcohol-prod} no-error.*/
/*  if available tt-attr-property then do:                               */
/*    assign                                                             */
/*    tt-attr-property.menu-item-handle:sensitive = no                   */
/*                                                                       */
/*    .                                                                  */
/*  end.                                                                 */
/*end.                                                                   */

{&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
APPLY "ENTRY" to br-attr.
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
define input parameter p-add as logical no-undo.
define variable attr-type as character no-undo . /*тип атрибута*/
define variable attr-format as character no-undo .  /* формат атрибута*/
define variable attr-label as character no-undo .         /*лабел атрибута */
define variable attr-user-can-edit as logical no-undo .  /*пользователь может изменять в броусе*/
define variable attr-output-display as logical no-undo .  /*виден в броусе*/
define variable attr-other as char no-undo .              /*еще чего - нибудь*/
define variable attr-value as char no-undo .              /*для знач по умолч*/
DEFINE VARIABLE v-attr-value as character no-undo .
define var loc#log as logical no-undo.
DEFINE VARIABLE v-init as character no-undo .
define variable jj as integer no-undo.
DEFINE VARIABLE v-spr as character no-undo .
define variable v-spr-ext as character no-undo .
define variable v-spr-param as character no-undo .
DEFINE VARIABLE v-setted as logical no-undo .
DEFINE VARIABLE v-deleted as logical no-undo .
define variable v-check as character no-undo .
define variable v-error-code as character no-undo .
define variable v-correct as logical no-undo .
define variable v-attr-entry as character no-undo .
define buffer buf_temp-attr for temp-attr.
CASE p-add:
  when yes then do:
    if p-mode <> {&add-def} then do:
      run temp-gds-attr-exist in this-procedure (
                                                 input p-gds-code
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
    run gds-attr-name in this-procedure (
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
    assign
    added = yes.
    do jj = 1 to num-entries(attr-other, {&slash-char}):
      v-attr-entry = entry(jj, attr-other, {&slash-char}) .
      if entry(1, v-attr-entry, "=":U) = "init":U then do:
        assign
        v-init = string(entry(2, v-attr-entry, "=":U))
        .
      end.
    end. /*jj*/
    if  v-init <> "":U then do:
        run  value(v-init)
                    in this-procedure (
                                        input p-gds-code
                                      , output attr-value) no-error .
          if error-status:error then do:
              assign
              attr-value = "":U
              .
          end.
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
  end. /*when add*/
  when no then do:
/*    if temp-attr.code = {&attr-alcohol-prod}*/
/*    and alco-val-log <> yes  then do:       */
/*        message                             */
/*        "Запрещена работа с атрибутом"      */
/*        view-as alert-box error.            */
/*        undo, return error.                 */
/*    end.                                    */
    run gds-attr-name in this-procedure (
                                          input temp-attr.code
                                          ,output attr-type
                                          ,output attr-format
                                          ,output attr-label
                                          ,output attr-user-can-edit
                                          ,output attr-output-display
                                          ,output attr-other) no-error.
    IF ERROR-STATUS:ERROR THEN DO:
        {&gds-attr-type-get-error}
        return error.
    END.
    attr-value  = temp-attr.value_.
  end. /*when chg*/
END CASE.
IF attr-user-can-edit Then DO:
  do jj = 1 to num-entries(attr-other, {&slash-char}):
    v-attr-entry = entry(jj, attr-other, {&slash-char}) .
    if entry(1, v-attr-entry, "=":U) = "spr":U
    then do:
      assign
      v-spr = string(entry(2, v-attr-entry, "=":U))
      .
    end.
    if  entry(1, v-attr-entry, "=":U) = "spr-ext":U
    then do:
      assign
      v-spr-ext = string(entry(2, v-attr-entry, "=":U))
      .
    end.
    if entry(1, v-attr-entry, "=":U) = "spr-param":U then do:
      assign
      v-spr-param = string(entry(2, v-attr-entry, "=":U))
      .
    end.
    if entry(1, v-attr-entry, "=":U) = "check":U then do:
      assign
      v-check = string(entry(2, v-attr-entry, "=":U))
      .
    end.
  end.
  if v-spr = "":U
  and v-spr-ext = '':U
  then do:
    run gbl/d-prompt.w (
      'title=':u + "Изменение атрибута товара" + '\':u
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
    if v-spr = '':u then do:
      if v-spr-param = "":U then do:
        run  value(v-spr-ext)  (
                           input (if p-add then {&add-def} else {&update})
                          ,input p-gds-code
                          ,input-output attr-value
                          ,output v-setted) no-error .

      end.
      else do:
        run  value(v-spr-ext) (
                             input (if p-add then {&add-def} else {&update})
                            ,input p-gds-code
                            ,input v-spr-param
                            ,input-output attr-value
                            ,output v-setted) no-error .
      end.
      if not v-setted then return error.

    end.
    if v-spr-ext = '':U then do:
      if v-spr-param = "":U then do:
        run  value(v-spr) in this-procedure (
                                             input p-gds-code
                                            ,input-output attr-value
                                            ,output v-setted) no-error .

      end.
      else do:
        run  value(v-spr) in this-procedure (
                                               input p-gds-code
                                              ,input v-spr-param
                                              ,input-output attr-value
                                              ,output v-setted) no-error .
      end.
      if not v-setted then return error.
    end.
  end.
  if v-check <> "":U then do:
    run value(v-check) (
                         input p-gds-code
                        ,input (if p-add then add-option else temp-attr.code)
                        ,input attr-value
                        ,input (if p-add then {&add-def} else {&update})
                        ,output v-correct
                        ,output v-error-code) no-error.
    if error-status:error then do:
      message
      "Ошибка при проверке корректности задаваемого значения атрибута" skip
      error-status:get-message(1) skip
      return-value
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
  if AVAILABLE (temp-attr) then do:
  if attr-label = "Является подконтрольным ФГИС Меркурий" and
  temp-attr.code = {&attr-mercur_FGIS} then do:
  define variable ii             as integer no-undo .
  define variable gdsMercsubsObj as class   gdsmercsubs.
  define variable gdsmercstrObj  as class   gdsmercstr.
  define variable gdsMercObj     as class     gdsmercsub.
  define VARIABLE f-guid         as character no-undo .     
  
  gdsMercsubsObj = new gdsmercsubs ().
  gdsmercstrObj = new gdsmercstr ().
  
  gdsMercsubsObj = gdsmercstrObj:getgdsmercs(p-gds-code).
  
  if VALID-OBJECT (gdsMercsubsObj:GdsMercsubsCurr) then
  do:
    do ii = 1 to gdsMercsubsObj:GetItem (ii): 
      gdsMercObj = gdsMercsubsObj:GdsMercsubsCurr. /* выдернула конкретны объект*/
      assign
        f-guid         = gdsMercObj:GUID_       
        .
    end.
  end. 
  if f-guid <> "" then do:
      message
      "Необходимо удалить синхронизацию товара с Меркурием" skip
      view-as alert-box error .
      undo, return error .
  end.         
  end.    
  end.
  run temp-gds-attr-write (
                             input p-gds-code
                            ,input (if p-add then add-option else temp-attr.code)
                            ,input attr-value) no-error .
  IF not error-status:error then do:
      assign
      updated = yes
      .
     if p-add 
     then do:
        find first buf_temp-attr where buf_temp-attr.gds-code eq p-gds-code
                                   and buf_temp-attr.code     eq add-option
                                   and buf_temp-attr.grp no-error.
        if available buf_temp-attr
        then
           buf_temp-attr.fdisable = yes.
     end.
     br-attr:refresh() in frame {&frame-name} no-error .
  END.
  assign
  added = no.
End.
Else message "Изменение атрибута невозможно !" view-as alert-box error.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-lkp Dialog-Frame
PROCEDURE proc-b-lkp :
define variable attr-type           as character no-undo .  /*тип атрибута*/
define variable attr-format         as character no-undo .  /* формат атрибута*/
define variable attr-label          as character no-undo .  /*лабел атрибута */
define variable attr-user-can-edit  as logical   no-undo .  /*пользователь может изменять в броусе*/
define variable attr-output-display as logical   no-undo .  /*виден в броусе*/
define variable attr-other          as character no-undo .  /*еще чего - нибудь*/
define variable attr-value          as character no-undo .  /*для знач по умолч*/
define variable v-run-name          as character no-undo .
define variable v-spr-param         as character no-undo .
define variable v-setted            as logical   no-undo .
define variable jj                  as integer   no-undo .

run gds-attr-name in this-procedure (
                                         input temp-attr.code
                                        ,output attr-type
                                        ,output attr-format
                                        ,output attr-label
                                        ,output attr-user-can-edit
                                        ,output attr-output-display
                                        ,output attr-other) no-error.
IF ERROR-STATUS:ERROR THEN DO:
    {&gds-attr-type-get-error}
    return error.
END.
do jj = 1 to num-entries(attr-other, {&slash-char}):
  if entry(1, entry(jj, attr-other, {&slash-char}), "=":U) = "spr-ext" then do:
    v-run-name = entry(2, entry(jj, attr-other, {&slash-char}), "=":U).
  end.
  if entry(1, entry(jj, attr-other, {&slash-char}), "=":U) = "spr-param":U then do:
    assign
    v-spr-param = string(entry(2, entry(jj, attr-other, {&slash-char}), "=":U))
    .
  end.
END.
if v-run-name = "" then next.
if v-spr-param = '':U then do:
  run value(v-run-name) (
                         input {&lookup}
                        ,input p-gds-code
                        ,input-output temp-attr.value_
                        ,output v-setted
                          )
                        no-error .
end.
else do:
  run value(v-run-name) (
                         input {&lookup}
                        ,input p-gds-code
                        ,input v-spr-param
                        ,input-output temp-attr.value_
                        ,output v-setted
                          )
                        no-error .
end.
if error-status:error then do:
  message error-status:get-message(1)  skip
  return-value
  view-as alert-box error .
  undo, return error .
end.
return .
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
DEFINE VARIABLE v-updated AS LOGICAL NO-UNDO.
define variable v-created as logical no-undo .
define variable v-deleted as logical no-undo .
define variable v-updated-str as character no-undo .
define variable v-type as character no-undo .
define variable v-issue-host-code like ub.sysconf.host-code no-undo .
define variable v-emrc-type as character no-undo .
define variable v-emrc-value as character no-undo .

define buffer buf_goods for ub.goods .

for each temp-attr NO-LOCK where
         temp-attr.gds-code = p-gds-code
     and temp-attr.grp  ne yes       :
   find first tt0-goods-attr NO-LOCK WHERE
          tt0-goods-attr.gds-code = temp-attr.gds-code
    AND   tt0-goods-attr.attr-code = temp-attr.code 
    AND   tt0-goods-attr.grp       = temp-attr.grp
    no-error.
  assign
  v-updated = no.
  if available  tt0-goods-attr then do:
    BUFFER-COMPARE temp-attr
                TO tt0-goods-attr
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
     if temp-attr.code = {&attr-emrc-type} then 
     do:
        for first buf_goods no-lock where buf_goods.gds-code = p-gds-code:
           run ggoattr-value (
              input   buf_goods.grp-code
              ,input   0
              ,input   ""
              ,input   0
              ,input   {&ggoattr-emrc-type}
              ,output   v-emrc-value
              ,output   v-emrc-type 
              ) no-error .

        end.
        if v-emrc-value <> temp-attr.value_ then 
        do:
           message "Для товара и группы установлено отличное значение «тип ЕМЦ»" skip
              "Наследовать «тип ЕМЦ» группы?" skip
              view-as alert-box question buttons yes-no update choice as logical . 
           case choice:
              when true then
                 temp-attr.value_ = v-emrc-value .
           end case.
        end.

        find last ub.Code no-lock where ub.Code.parent = "emc" + {&delim-par} + temp-attr.value_ and  
           ub.Code.status_ = {&bef-current-status-int} and ub.Code.code <= iso-date(today) no-error .
        if available (ub.Code) then 
        do:
           for last ub.price-all no-lock where ub.price-all.gds-code = p-gds-code and 
              /*         ub.price-all.obj-code = temp_obj-list.obj-code and*/
              /*         ub.price-all.obj-type = temp_obj-list.obj-type and*/
              ub.price-all.main-indication = 0 and
              ub.price-all.type-price = 0:
              if ub.price-all.price-sale < decimal(ub.Code.CodeValue) then 
              do:
                 message "Стоимость товара в базе ниже установленной ЕМЦ. Продажа товара по цене базы запрещена."
                    view-as alert-box .   
              end.
           end.
        end.
     end.
    run tt0-gds-attr-write in this-procedure (
                                               input p-gds-code
                                              ,input temp-attr.code
                                              ,input temp-attr.value_)  no-error.
    if error-status:error then do:
      message
      "Ошибка при сохранении атрибута товара" skip
      "товар" p-gds-code skip
      "Атрибут" temp-attr.attr-code
      view-as alert-box  error .
      undo, return error  .
    end.
    updated = yes.
  end.
  ASSIGN
  p-updated = v-updated OR p-updated.
End.
FOR EACH tt0-goods-attr where
         tt0-goods-attr.gds-code = p-gds-code
     and tt0-goods-attr.grp ne yes:
  FIND FIRST temp-attr NO-LOCK WHERE
            temp-attr.gds-code = tt0-goods-attr.gds-code
        AND temp-attr.code = tt0-goods-attr.attr-code 
        AND temp-attr.grp = tt0-goods-attr.grp 
        
        NO-ERROR.
    IF NOT AVAILABLE temp-attr THEN DO:
      DELETE tt0-goods-attr.
      assign
      v-deleted = yes.
      ASSIGN
      p-updated = (v-deleted OR p-updated).
    END.
END.
if p-updated
and p-update-instantly then do:
  run ref/gds-atr1.p (
                     input p-mode
                    ,input p-gds-code
                    ,INPUT table tt0-goods-attr
                    ) no-error .
  if error-status:error then do:
    message
    substitute("Ошибка при сохранении атрибутов товара:&1&2&1&3"
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE temp-gds-attr-exist Dialog-Frame
PROCEDURE temp-gds-attr-exist :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

  do
  on error undo, return error
  :
    define input parameter p-gds-code like ub.goods-attr.gds-code   no-undo .
    define input parameter p-code     like ub.goods-attr.attr-code  no-undo .
    define output parameter p-exist    as logical no-undo .

    define buffer buf_goods-attr for ub.goods-attr .
    define buffer buf_temp-attr for temp-attr .

    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .

    run gds-attr-name in this-procedure (
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

    find first buf_temp-attr no-lock where
               buf_temp-attr.gds-code  = p-gds-code AND
               buf_temp-attr.attr-code = p-code no-error .
    if available buf_temp-attr then do:
      P-EXIST = YES.
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE temp-gds-attr-write Dialog-Frame
PROCEDURE temp-gds-attr-write :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  do
  on error undo, return error
  :

    define input parameter p-gds-code like ub.goods-attr.gds-code   no-undo .
    define input parameter p-code     like ub.goods-attr.attr-code  no-undo .
    define input parameter p-value    like ub.goods-attr.attr-value no-undo .

    define buffer buf_temp-attr for temp-attr .

    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .

    run gds-attr-name in this-procedure (
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
    find first buf_temp-attr exclusive-lock where
               buf_temp-attr.gds-code  = p-gds-code AND
               buf_temp-attr.code      = p-code     and 
               buf_temp-attr.grp ne yes no-error .
    if not available buf_temp-attr then do:
      create buf_temp-attr .
      assign
        buf_temp-attr.gds-code  = p-gds-code
        buf_temp-attr.attr-code = v-label
        buf_temp-attr.code      = p-code
        buf_temp-attr.attr-value = (if v-type = {&type-log} then string(logical(p-value), v-format) else p-value)
        buf_temp-attr.value_ = p-value
        no-error
      .
    end.
    ELSE
    ASSIGN
    buf_temp-attr.attr-value = (if v-type = {&type-log} then string(logical(p-value), v-format) else p-value)
    buf_temp-attr.value_ = p-value
    no-error.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE tt0-gds-attr-write Dialog-Frame
PROCEDURE tt0-gds-attr-write :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  do
  on error undo, return error
  :

    define input parameter p-gds-code like ub.goods-attr.gds-code   no-undo .
    define input parameter p-code     like ub.goods-attr.attr-code  no-undo .
    define input parameter p-value    like ub.goods-attr.attr-value no-undo .

    define buffer buf_tt0-goods-attr for tt0-goods-attr .

    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .

    run gds-attr-name in this-procedure (
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

    find first buf_tt0-goods-attr exclusive-lock where
               buf_tt0-goods-attr.gds-code  = p-gds-code AND
               buf_tt0-goods-attr.attr-code = p-code     and
               buf_tt0-goods-attr.grp ne yes 
               no-error .
    if not available buf_tt0-goods-attr then do:
      create buf_tt0-goods-attr .
      assign
        buf_tt0-goods-attr.gds-code  = p-gds-code
        buf_tt0-goods-attr.attr-code = p-code
        buf_tt0-goods-attr.attr-value = p-value no-error
      .
    end.
    ELSE
    ASSIGN
    buf_tt0-goods-attr.attr-value = p-value no-error.
    release buf_tt0-goods-attr no-error .
    if error-status:error then do:
      undo, return error return-value .
    end.

  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
