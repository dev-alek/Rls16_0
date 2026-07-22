&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE type-marking NO-UNDO
  field mark-orig       as character
  field mark-type       as character
  field EDO             as logical
  field mark            as logical
  field artic           as logical
  field transitional    as logical
  field blockCashUnMark as logical
  field saleReturn      as logical
  field saleUPD         as logical
  field onlySale        as logical
  field checkBlock      as logical
  field checkDate       as logical
  field checkMRC        as logical
  field checkOwner      as logical
  field checkStatusKM   as logical
  field checkTracking   as logical
  index mark-type mark-type
  .



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Редактирование секции параметры для Электронный документооборот

Автор: Шкляр Елена Львовна
Дата создания: 15/11/03
Author: Elena Shklyar
Creation date: 15/11/03

This .W file was created with the Progress AppBuilder.

*/

define input parameter parparentproc as widget-handle no-undo.
define input parameter p-mode     as character no-undo.
define input parameter p-obj-type like ub.clients.obj-type no-undo.
define input parameter p-obj-code like ub.clients.obj-code no-undo.


define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-Workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Редактирование секции параметры для для Электронный документооборот" .
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ gbl/thbjattr.i }
{ gbl/color.i        }
{ gbl/objsrv.i }
{ str/def-thbjattr-list.i "new shared" }  
define variable Types as ibs.th.str.marking.Types no-undo.
Types = ObjSrv:Env:Marking:Types.
   
define temp-table temp-thbj-attr no-undo like ub.thbj-attr.

define variable v-tth     as handle no-undo .

define variable v-tth-host as handle no-undo .
define variable v-to-create-host as logical no-undo.
define variable str-attr as character no-undo .
/* define variable S-type-mark as character no-undo . */
define variable S-type-EDO as character no-undo .
define variable S-type-artic as character no-undo .
define variable S-type-transitional as character no-undo .
/* define variable S-type-blockCashUnMark as character no-undo . */
define variable S-type-saleReturn      as character no-undo .
/* define variable S-type-saleUPD         as character no-undo . */
/* define variable S-type-onlySale        as character no-undo . */
define variable S-type-checkBlock      as character no-undo .
define variable S-type-checkDate       as character no-undo .
define variable S-type-checkMRC        as character no-undo .
define variable S-type-checkOwner      as character no-undo .
define variable S-type-checkStatusKM   as character no-undo .
define variable S-type-checkTracking   as character no-undo .


assign
v-tth      = buffer temp-thbj-attr:table-handle .


/*if p-obj-type = "" then do:                                     */
/*if g#db-num <> 0  and p-obj-type = "" then  p-mode = {&lookup} .*/
/*end.                                                            */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br_marking-type

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES type-marking

/* Definitions for BROWSE br_marking-type                                      */
&Scoped-define FIELDS-IN-QUERY-br_marking-type type-marking.mark-type ~
type-marking.mark type-marking.edo type-marking.artic type-marking.transitional type-marking.blockCashUnMark type-marking.saleReturn type-marking.saleUPD type-marking.onlySale~
type-marking.checkBlock type-marking.checkDate type-marking.checkMRC type-marking.checkOwner type-marking.checkStatusKM type-marking.checkTracking
&Scoped-define ENABLED-FIELDS-IN-QUERY-br_marking-type type-marking.mark-type ~
type-marking.mark type-marking.edo type-marking.artic type-marking.transitional type-marking.blockCashUnMark type-marking.saleReturn type-marking.saleUPD type-marking.onlySale~
type-marking.checkBlock type-marking.checkDate type-marking.checkMRC type-marking.checkOwner type-marking.checkStatusKM type-marking.checkTracking
&Scoped-define ENABLED-TABLES-IN-QUERY-br_marking-type type-marking
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-br_marking-type type-marking
&Scoped-define QUERY-STRING-br_marking-type FOR EACH type-marking INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br_marking-type OPEN QUERY br_marking-type FOR EACH type-marking INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br_marking-type type-marking
&Scoped-define FIRST-TABLE-IN-QUERY-br_marking-type type-marking


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br_marking-type}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit B-quit t-edo t-edo-NotMark t-manual ~
t-ban_recipes t-ban-altr t-bar-code t-rus-key cb-gray_zone_qnty maxColMarks ~
br_marking-type 
&Scoped-Define DISPLAYED-OBJECTS t-edo t-edo-NotMark t-manual t-ban_recipes ~
t-ban-altr t-bar-code t-rus-key cb-gray_zone_qnty maxColMarks 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD isArticAvail Dialog-Frame  _DB-REQUIRED
FUNCTION isArticAvail RETURNS LOGICAL
  ( /* parameter-definitions */ )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD isMarkAZKAvail Dialog-Frame  _DB-REQUIRED 
FUNCTION isMarkAZKAvail RETURNS LOGICAL
  ( /* parameter-definitions */ )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

FUNCTION isMarkVnAvail RETURNS LOGICAL
  ( /* parameter-definitions */ )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD isTransitionalAvail Dialog-Frame 
FUNCTION isTransitionalAvail RETURNS LOGICAL
  ( /* parameter-definitions */ )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD isblockCashUnMarkAvail Dialog-Frame 
FUNCTION isblockCashUnMarkAvail RETURNS LOGICAL
  ( /* parameter-definitions */ )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD issaleReturnAvail Dialog-Frame 
FUNCTION issaleReturnAvail RETURNS LOGICAL
  ( /* parameter-definitions */ )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD issaleUPDAvail Dialog-Frame 
FUNCTION issaleUPDAvail RETURNS LOGICAL
  ( /* parameter-definitions */ )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD isonlySaleAvail Dialog-Frame 
FUNCTION isonlySaleAvail RETURNS LOGICAL
  ( /* parameter-definitions */ )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD ischeckBlockAvail Dialog-Frame 
FUNCTION ischeckBlockAvail RETURNS LOGICAL
  ( /* parameter-definitions */ )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD ischeckDateAvail Dialog-Frame 
FUNCTION ischeckDateAvail RETURNS LOGICAL
  ( /* parameter-definitions */ )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD ischeckMRCAvail Dialog-Frame 
FUNCTION ischeckMRCAvail RETURNS LOGICAL
  ( /* parameter-definitions */ )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD ischeckOwnerAvail Dialog-Frame 
FUNCTION ischeckOwnerAvail RETURNS LOGICAL
  ( /* parameter-definitions */ )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD ischeckStatusKMAvail Dialog-Frame 
FUNCTION ischeckStatusKMAvail RETURNS LOGICAL
  ( /* parameter-definitions */ )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD ischeckTrackingAvail Dialog-Frame 
FUNCTION ischeckTrackingAvail RETURNS LOGICAL
  ( /* parameter-definitions */ )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-exit AUTO-GO 
     LABEL "&Ввод" 
     SIZE 10 BY 1.

DEFINE BUTTON B-quit AUTO-END-KEY 
     LABEL "&Отмена" 
     SIZE 10 BY 1.

DEFINE VARIABLE cb-gray_zone_qnty AS INTEGER FORMAT "->>9":U INITIAL 0 
     LABEL "Допустимое отсутствие КМ для ~"Серой зоны~"" 
     VIEW-AS COMBO-BOX INNER-LINES 6
     LIST-ITEMS "0" ,
     "1",
     "2",
     "3",
     "4",
     "5",
     "6",
     "7",
     "8",
     "9",
     "10",
     "100"     
     DROP-DOWN-LIST
     SIZE 27.75 BY 1 NO-UNDO.



DEFINE VARIABLE t-ban-altr AS LOGICAL INITIAL no 
     LABEL "Использования рецепта Альтернатива только для получения ингредиентов" 
     VIEW-AS TOGGLE-BOX
     SIZE 74.75 BY .83 NO-UNDO.

DEFINE VARIABLE t-ban_recipes AS LOGICAL INITIAL no 
     LABEL "Запрет на создание рецептов и маркетинговых акций" 
     VIEW-AS TOGGLE-BOX
     SIZE 79.25 BY .83 NO-UNDO.

DEFINE VARIABLE t-bar-code AS LOGICAL INITIAL no 
     LABEL "Определение товара по штрих-коду" 
     VIEW-AS TOGGLE-BOX
     SIZE 74.75 BY .83 NO-UNDO.

DEFINE VARIABLE t-rus-key AS LOGICAL INITIAL no 
     LABEL "Автоматическое переключение раскладки на русский" 
     VIEW-AS TOGGLE-BOX
     SIZE 74.75 BY .83 NO-UNDO.

DEFINE VARIABLE t-edo AS LOGICAL INITIAL no 
     LABEL "Включена работа с ЭДО для маркированных документов" 
     VIEW-AS TOGGLE-BOX
     SIZE 60 BY .83 NO-UNDO.

DEFINE VARIABLE t-edo-NotMark AS LOGICAL INITIAL no 
     LABEL "Включена работа с ЭДО для не маркированных документов" 
     VIEW-AS TOGGLE-BOX
     SIZE 60 BY .83 NO-UNDO.

DEFINE VARIABLE t-manual AS LOGICAL INITIAL no 
     LABEL "Ручной ввод марок" 
     VIEW-AS TOGGLE-BOX
     SIZE 30.5 BY .83 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br_marking-type FOR 
      type-marking SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br_marking-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br_marking-type Dialog-Frame _STRUCTURED
  QUERY br_marking-type NO-LOCK DISPLAY
  type-marking.mark-type COLUMN-LABEL "Тип!маркировки" LABEL-BGCOLOR 8 FORMAT "X(35)":U 
/*  type-marking.mark COLUMN-LABEL "Помарочный!учет АЗК" LABEL-BGCOLOR 8 FORMAT "yes/no":U view-as toggle-box*/
  type-marking.EDO column-label "Поэкземплярный!учет" LABEL-BGCOLOR 8 FORMAT "yes/no":U view-as toggle-box
  type-marking.artic column-label "Объемно-!артикульный!учет" LABEL-BGCOLOR 8 FORMAT "yes/no":U 
  view-as toggle-box
  type-marking.transitional column-label "Переходный!период" LABEL-BGCOLOR 8 FORMAT "yes/no":U view-as toggle-box
  /*      type-marking.blockCashUnMark column-label "Блок.на кассе!операций!с неизвестными!марками" LABEL-BGCOLOR 8 FORMAT "yes/no":U view-as toggle-box*/
  type-marking.saleReturn column-label "Разрешена!продажа!возвращенных!товаров" LABEL-BGCOLOR 8 FORMAT "yes/no":U view-as toggle-box
  /*      type-marking.saleUPD column-label "Разрешена!продажа до!подписания!УПД" LABEL-BGCOLOR 8 FORMAT "yes/no":U view-as toggle-box*/
  /*      type-marking.onlySale column-label "Возврат!только!проданных" LABEL-BGCOLOR 8 FORMAT "yes/no":U view-as toggle-box          */
  type-marking.checkBlock column-label "Проверка!блокировок!контрол.!органов" LABEL-BGCOLOR 8 FORMAT "yes/no":U view-as toggle-box
  type-marking.checkDate column-label "Проверка!срока!годности" LABEL-BGCOLOR 8 FORMAT "yes/no":U view-as toggle-box
  type-marking.checkMRC column-label "Проверка!МРЦ" LABEL-BGCOLOR 8 FORMAT "yes/no":U view-as toggle-box
  type-marking.checkOwner column-label "Проверка!владельцев" LABEL-BGCOLOR 8 FORMAT "yes/no":U view-as toggle-box
  type-marking.checkStatusKM column-label "Проверка!статуса КМ" LABEL-BGCOLOR 8 FORMAT "yes/no":U view-as toggle-box
  type-marking.checkTracking column-label "Проверка!прослежи-!ваемости" LABEL-BGCOLOR 8 FORMAT "yes/no":U view-as toggle-box
  ENABLE
/*      type-marking.mark*/
      type-marking.EDO
      type-marking.artic
      type-marking.transitional
      type-marking.checkBlock
      type-marking.checkDate
      type-marking.checkMRC
      type-marking.checkOwner
      type-marking.checkStatusKM
      type-marking.checkTracking
/*      type-marking.blockCashUnMark*/
      type-marking.saleReturn
/*      type-marking.saleUPD */
/*      type-marking.onlySale*/
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 107 BY 12.42 .


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     B-quit AT ROW 1 COL 11
     t-edo AT ROW 2 COL 5.75 WIDGET-ID 142
     t-edo-NotMark AT ROW 3 COL 5.75 WIDGET-ID 164
     t-manual AT ROW 3.88 COL 5.75 WIDGET-ID 148
     t-ban_recipes AT ROW 4.92 COL 5.75 WIDGET-ID 156
     t-ban-altr AT ROW 6.63 COL 5.75 WIDGET-ID 160
     t-bar-code AT ROW 7.79 COL 5.75 WIDGET-ID 162
     t-rus-key AT ROW 8.79 COL 5.75 WIDGET-ID 162
     cb-gray_zone_qnty AT ROW 10.08 COL 49.38 COLON-ALIGNED WIDGET-ID 150
     br_marking-type AT ROW 13.08 COL 2 WIDGET-ID 200
     "с маркированными товарами" VIEW-AS TEXT
          SIZE 33 BY .67 AT ROW 5.75 COL 8 WIDGET-ID 158
     SPACE(68.24) SKIP(19.24)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Настройки для Электронного документооборота"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON B-quit WIDGET-ID 100.

{ gbl/diasize.i }
    run diasize_init in this-procedure .

/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: type-marking T "?" NO-UNDO 
      ADDITIONAL-FIELDS:
       field mark-type as character
       field EDO as logical
       field mark as logical
       field artic as logical
       field transitional  as logical
      END-FIELDS.
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */
ASSIGN {&BROWSE-NAME} :NUM-LOCKED-COLUMNS IN FRAME {&FRAME-NAME} = 1 .
&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br_marking-type cb-gray_zone_qnty Dialog-Frame */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       type-marking.mark-type:COLUMN-READ-ONLY IN BROWSE br_marking-type = true.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br_marking-type
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Настройки для Электронного документооборота */
DO:
  run save-proc in this-procedure no-error.
  if error-status :error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Настройки для Электронного документооборота */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME cb-gray_zone_qnty
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL cb-gray_zone_qnty Dialog-Frame
ON VALUE-CHANGED OF cb-gray_zone_qnty IN FRAME Dialog-Frame /* Допустимое отсутствие КМ для "Серой зоны" */
DO:
  define buffer tt-mark for type-marking.
  if  cb-gray_zone_qnty:screen-value  eq "100"
  then do:
     for each tt-mark where     tt-mark.mark-orig eq Types:tabak:NameProp
                             or tt-mark.mark-orig eq Types:stiki:NameProp
     no-lock:
        if tt-mark.mark
        then do:
           message 'При помарочном учете для "' tt-mark.mark-type '" нельзя выставлять серую зону в 100'
              view-as alert-box.
           cb-gray_zone_qnty:screen-value = string(cb-gray_zone_qnty).
           return no-apply.
        end.
     end.
  end.
  assign cb-gray_zone_qnty .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME t-ban-altr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL t-ban-altr Dialog-Frame
ON VALUE-CHANGED OF t-ban-altr IN FRAME Dialog-Frame /* Использования рецепта Альтернатива только для получения ингредиентов */
DO:
  assign t-ban-altr .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME t-ban_recipes
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL t-ban_recipes Dialog-Frame
ON VALUE-CHANGED OF t-ban_recipes IN FRAME Dialog-Frame /* Запрет на создание рецептов и маркетинговых акций */
DO:
  assign t-ban_recipes .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME t-bar-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL t-bar-code Dialog-Frame
ON VALUE-CHANGED OF t-bar-code IN FRAME Dialog-Frame /* Определение товара по штрих-коду */
DO:
  assign t-bar-code .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME t-rus-key
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL t-rus-key Dialog-Frame
ON VALUE-CHANGED OF t-rus-key IN FRAME Dialog-Frame /* Авто переключение раскладки на русский */
DO:
  assign t-rus-key .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME t-edo
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL t-edo Dialog-Frame
ON VALUE-CHANGED OF t-edo IN FRAME Dialog-Frame /* Включена работа с ЭДО для маркированных документов */
DO:
  assign t-edo .
  /* if t-edo then do:
     t-edo-NotMark = true .
     display t-edo-NotMark with frame {&frame-name} .
     disable 
     t-edo-NotMark
     with frame {&frame-name} .
  end.   
  else */ do:
     enable
     t-edo-NotMark
     with frame {&frame-name} .
  end.   
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME t-edo-NotMark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL t-edo-NotMark Dialog-Frame
ON VALUE-CHANGED OF t-edo-NotMark IN FRAME Dialog-Frame /* Включена работа с ЭДО для не маркированных документов */
DO:
  assign t-edo-NotMark .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME t-manual
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL t-manual Dialog-Frame
ON VALUE-CHANGED OF t-manual IN FRAME Dialog-Frame /* Ручной ввод марок */
DO:
  assign t-manual .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define BROWSE-NAME br_marking-type
&Scoped-define SELF-NAME br_marking-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br_marking-type Dialog-Frame
ON ROW-DISPLAY OF br_marking-type IN FRAME Dialog-Frame
  DO:
    type-marking.artic       :bgcolor  IN BROWSE br_marking-type = if isArticAvail()        then WHITE_COLOR else GRAY_COLOR .
    type-marking.edo         :bgcolor  IN BROWSE br_marking-type = if isMarkVnAvail()       then WHITE_COLOR else GRAY_COLOR .
    type-marking.transitional:bgcolor  IN BROWSE br_marking-type = if isTransitionalAvail() then WHITE_COLOR else GRAY_COLOR .
/*    type-marking.mark        :bgcolor  IN BROWSE br_marking-type = if isMarkAZKAvail()      then WHITE_COLOR else GRAY_COLOR .*/
    /*     type-marking.blockCashUnMark   :bgcolor  IN BROWSE br_marking-type = if isblockCashUnMarkAvail() then WHITE_COLOR else GRAY_COLOR .*/
    type-marking.saleReturn        :bgcolor  IN BROWSE br_marking-type = if issaleReturnAvail()      then WHITE_COLOR else GRAY_COLOR .
    /*     type-marking.saleUPD           :bgcolor  IN BROWSE br_marking-type = if issaleUPDAvail()         then WHITE_COLOR else GRAY_COLOR .*/
    /*     type-marking.onlySale          :bgcolor  IN BROWSE br_marking-type = if isonlySaleAvail()        then WHITE_COLOR else GRAY_COLOR .*/
    type-marking.checkBlock        :bgcolor  IN BROWSE br_marking-type = if ischeckBlockAvail()      then WHITE_COLOR else GRAY_COLOR .
    type-marking.checkDate        :bgcolor  IN BROWSE br_marking-type = if ischeckDateAvail()      then WHITE_COLOR else GRAY_COLOR .
    type-marking.checkMRC        :bgcolor  IN BROWSE br_marking-type = if ischeckMRCAvail()      then WHITE_COLOR else GRAY_COLOR .
    type-marking.checkOwner        :bgcolor  IN BROWSE br_marking-type = if ischeckOwnerAvail()      then WHITE_COLOR else GRAY_COLOR .
    type-marking.checkStatusKM        :bgcolor  IN BROWSE br_marking-type = if ischeckStatusKMAvail()      then WHITE_COLOR else GRAY_COLOR .
    type-marking.checkTracking        :bgcolor  IN BROWSE br_marking-type = if ischeckTrackingAvail()      then WHITE_COLOR else GRAY_COLOR .
  end.
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br_marking-type Dialog-Frame
ON row-leave OF br_marking-type IN FRAME Dialog-Frame
  DO:
    define variable vMarkvn        as logical no-undo.
    define variable vartic         as logical no-undo.
    define variable vtransitional  as logical no-undo.
    define variable vMarkAZK       as logical no-undo.
    define variable vBlockCashMark as logical no-undo .
    define variable vSaleReturn    as logical no-undo .
    define variable vSaleUPD       as logical no-undo .
    define variable vOnlySale      as logical no-undo .
    define variable vcheckBlock    as logical no-undo .
    define variable vcheckDate     as logical no-undo .
    define variable vcheckMRC      as logical no-undo .
    define variable vcheckOwner    as logical no-undo .
    define variable vcheckStatusKM as logical no-undo .
    define variable vcheckTracking as logical no-undo .

    assign
      vMarkvn        = type-marking.edo
      vartic         = type-marking.artic
      vtransitional  = type-marking.transitional
      vMarkAZK       = type-marking.mark
      /*      vBlockCashMark = type-marking.blockCashUnMark*/
      vSaleReturn    = type-marking.saleReturn
      /*      vSaleUPD = type-marking.saleUPD  */
      /*      vOnlySale = type-marking.onlySale*/
      vcheckBlock    = type-marking.checkBlock
      vcheckDate     = type-marking.checkDate
      vcheckMRC      = type-marking.checkMRC
      vcheckOwner    = type-marking.checkOwner
      vcheckStatusKM = type-marking.checkStatusKM
      vcheckTracking = type-marking.checkTracking
      browse br_marking-type type-marking.edo
      browse br_marking-type type-marking.artic
      browse br_marking-type type-marking.transitional
/*      browse br_marking-type type-marking.mark*/
/*      browse br_marking-type type-marking.blockCashUnMark*/
      browse br_marking-type type-marking.saleReturn
      /*      browse br_marking-type type-marking.saleUPD */
      /*      browse br_marking-type type-marking.onlySale*/
      browse br_marking-type type-marking.checkBlock
      browse br_marking-type type-marking.checkDate
      browse br_marking-type type-marking.checkMRC
      browse br_marking-type type-marking.checkOwner
      browse br_marking-type type-marking.checkStatusKM
      browse br_marking-type type-marking.checkTracking
      .
    if      not isArticAvail()
      and  type-marking.artic ne vartic
      and  type-marking.artic ne no
   then do:
      type-marking.artic:checked IN BROWSE br_marking-type = no.
      type-marking.artic = no.
   end.
   if      not isMarkVnAvail()
      and  type-marking.edo ne vMarkvn
      and  type-marking.edo ne no
   then do:
      assign
      type-marking.edo:checked IN BROWSE br_marking-type = no.
      type-marking.edo = no.
   end.
   if    not  type-marking.edo   
     or   (not isMarkAZKAvail()
      and  type-marking.mark ne vMarkAZK
      and  type-marking.mark ne no)
   then do:
      assign
/*      type-marking.mark:checked IN BROWSE br_marking-type = no.*/
      type-marking.mark = no.
      vMarkAZK = no.
   end.
   if      not isTransitionalAvail()
      and  type-marking.transitional ne vtransitional
      and  type-marking.transitional ne no
   then do:
      type-marking.transitional:checked IN BROWSE br_marking-type = no.
      type-marking.transitional = no.
   end.
/*      if      not isblockCashUnMarkAvail()                                */
/*      and  type-marking.blockCashUnMark ne vBlockCashMark                 */
/*      and  type-marking.blockCashUnMark ne no                             */
/*   then do:                                                               */
/*      type-marking.blockCashUnMark:checked IN BROWSE br_marking-type = no.*/
/*      type-marking.blockCashUnMark = no.                                  */
/*   end.                                                                   */
      if      not issaleReturnAvail()
      and  type-marking.saleReturn ne vSaleReturn
      and  type-marking.saleReturn ne no
   then do:
      type-marking.saleReturn:checked IN BROWSE br_marking-type = no.
      type-marking.saleReturn = no.
   end.
/*      if      not issaleUPDAvail()                                 */
/*      and  type-marking.saleUPD ne vSaleUPD                        */
/*      and  type-marking.saleUPD ne no                              */
/*   then do:                                                        */
/*      type-marking.saleUPD:checked IN BROWSE br_marking-type = no. */
/*      type-marking.saleUPD = no.                                   */
/*   end.                                                            */
/*      if      not isonlySaleAvail()                                */
/*      and  type-marking.onlySale ne vOnlySale                      */
/*      and  type-marking.onlySale ne no                             */
/*   then do:                                                        */
/*      type-marking.onlySale:checked IN BROWSE br_marking-type = no.*/
/*      type-marking.onlySale = no.                                  */
/*   end.                                                            */
   apply "ROW-DISPLAY" to br_marking-type IN FRAME Dialog-Frame.
   
   
   if    (type-marking.mark-orig eq Types:tabak:NameProp
       or type-marking.mark-orig eq Types:stiki:NameProp)
       and type-marking.mark ne vMarkAZK
       and type-marking.mark eq yes
       and cb-gray_zone_qnty :screen-value = "100"
   then do:
      cb-gray_zone_qnty = 2.
      cb-gray_zone_qnty :screen-value = "2".
      message 'Значение для Серой зоны изменено со 100  на ' cb-gray_zone_qnty
              view-as alert-box.
 
   end.
      
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br_marking-type Dialog-Frame
ON VALUE-CHANGED  OF br_marking-type IN FRAME Dialog-Frame
DO:
   apply "row-leave" to br_marking-type IN FRAME Dialog-Frame.
end.


/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/*ON RETURN, MOUSE-SELECT-DBLCLICK OF br-list IN FRAME {&frame-name} DO:*/
/*    apply "choose" to b-lkp in frame {&frame-name}.                   */
/*END.                                                                  */
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

  if p-obj-type <> "" then do:
     FRAME {&FRAME-NAME}:TITLE = FRAME {&FRAME-NAME}:TITLE + (if p-obj-type = {&cmp} then " фирма" else " маг") + STRING(p-obj-code) .
  end.
/*    type-marking.mark-type:column-bgcolor = 8 .*/
    RUN init-tt.
    RUN fill-widgets.
    RUN enable_UI.
    
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
  DISPLAY t-edo t-edo-NotMark t-manual t-ban_recipes t-ban-altr t-bar-code t-rus-key
          cb-gray_zone_qnty 
      WITH FRAME Dialog-Frame.
  ENABLE B-exit B-quit t-edo t-edo-NotMark t-manual t-ban_recipes t-ban-altr 
    t-bar-code t-rus-key cb-gray_zone_qnty
    WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  if p-mode <> {&update} then disable B-exit with frame Dialog-Frame.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-widgets Dialog-Frame 
PROCEDURE fill-widgets :
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-param-type as character no-undo .
define variable v-param-value as character no-undo .
for each temp-thbj-attr:
  delete temp-thbj-attr.
end.

  ENABLE  br_marking-type WITH FRAME Dialog-Frame.
  if p-mode = {&update} then 
  do:
    ENABLE  t-edo cb-gray_zone_qnty t-manual t-ban_recipes t-ban-altr t-edo-NotMark t-bar-code t-rus-key
      WITH FRAME Dialog-Frame.
  end.  
  else do:
    Display  t-edo cb-gray_zone_qnty t-manual t-ban_recipes t-ban-altr t-edo-NotMark t-bar-code t-rus-key br_marking-type
      WITH FRAME Dialog-Frame. 
    br_marking-type:read-only in frame Dialog-Frame = true.
    disable B-exit with frame Dialog-Frame.
   end.  
run adm/shattri.p (
    input "init":U
    , input p-obj-type
    , input p-obj-code
    , input {&attr-marking}
    , input "":U
    , output v-value-character
    , output v-value-date
    , output v-value-decimal
    , output v-value-integer
    , output v-value-logical
    , output v-param-type
    , input-output TABLE-HANDLE v-tth
    ) no-error .
  if error-status:error then 
  do:
    message
      "Не удалось получить начальные значения настроек" skip
      error-status:get-message(1) return-value
      view-as alert-box error .
    undo, return error .
  end.

  FOR EACH temp-thbj-attr where temp-thbj-attr.obj-code = p-obj-code and temp-thbj-attr.obj-type = p-obj-type
    :
    IF temp-thbj-attr.prop-code = {&attr-marking_marking-EDO} THEN 
    DO:
      t-edo = temp-thbj-attr.property-value-logical .
      display t-edo with frame {&frame-name} .
    END.
    else IF temp-thbj-attr.prop-code = {&attr-marking_marking-EDO-NotMark} THEN 
      DO:
        t-edo-NotMark = temp-thbj-attr.property-value-logical .
        display t-edo-NotMark with frame {&frame-name} .
      END.
      else IF temp-thbj-attr.prop-code = {&attr-marking_marking-manual} THEN 
        DO:
          t-manual = temp-thbj-attr.property-value-logical .
          display t-manual with frame {&frame-name} .
        END.
        else IF temp-thbj-attr.prop-code = {&attr-marking_marking-type} THEN 
          DO:
          /* S-type-mark = temp-thbj-attr.property-value-character .*/
          /*       display s-type with frame {&frame-name} .*/
          END.
          else IF temp-thbj-attr.prop-code = {&attr-marking_marking-type-edo} THEN 
            DO:
              S-type-edo = temp-thbj-attr.property-value-character .
            /*       display S-type-edo with frame {&frame-name} .*/
            END.
            else IF temp-thbj-attr.prop-code = {&attr-marking_marking-type-artic} THEN 
              DO:
                S-type-artic = temp-thbj-attr.property-value-character .
              END.
              else IF temp-thbj-attr.prop-code = {&attr-marking_marking-type-transitional} THEN 
                DO:
                  S-type-transitional = temp-thbj-attr.property-value-character .
                END.
                else IF temp-thbj-attr.prop-code = {&attr-marking_marking-type-blockCashUnMark} THEN 
                  DO:
                    /* S-type-blockCashUnMark = temp-thbj-attr.property-value-character . */
                  END.
                  else IF temp-thbj-attr.prop-code = {&attr-marking_marking-type-saleReturn} THEN 
                    DO:
                      S-type-saleReturn = temp-thbj-attr.property-value-character .
                    END.
                    else IF temp-thbj-attr.prop-code = {&attr-marking_marking-type-saleUPD} THEN 
                      DO:
                        /* S-type-saleUPD = temp-thbj-attr.property-value-character . */
                      END.
                      else IF temp-thbj-attr.prop-code = {&attr-marking_marking-type-onlySale} THEN 
                        DO:
                          /* S-type-onlySale = temp-thbj-attr.property-value-character . */
                        END.                
                        else IF temp-thbj-attr.prop-code = {&attr-marking_gray_zone_qnty} THEN 
                          DO:
                            cb-gray_zone_qnty = temp-thbj-attr.property-value-integer .
                            display cb-gray_zone_qnty with frame {&frame-name} .
                          END.
                          else IF temp-thbj-attr.prop-code = {&attr-marking_ban-recipes} THEN 
                            DO:
                              t-ban_recipes = temp-thbj-attr.property-value-logical .
                              display t-ban_recipes with frame {&frame-name} .
                            END.    
                            else IF temp-thbj-attr.prop-code = {&attr-marking_ban-altr} THEN 
                              DO:
                                t-ban-altr = temp-thbj-attr.property-value-logical .
                                display t-ban-altr with frame {&frame-name} .
                              END.    
                              else IF temp-thbj-attr.prop-code = {&attr-marking_bar-code} THEN 
                                DO:
                                  t-bar-code = temp-thbj-attr.property-value-logical .
                                  display t-bar-code with frame {&frame-name} .
                                END.
                                else IF temp-thbj-attr.prop-code = {&attr-marking_rus-key} THEN 
                                  DO:
                                    t-rus-key = temp-thbj-attr.property-value-logical .
                                    display t-rus-key with frame {&frame-name} .
                                  END.
                                  else IF temp-thbj-attr.prop-code = {&attr-marking_checkBlock} THEN 
                                    DO:
                                      S-type-checkBlock = temp-thbj-attr.property-value-character .
                                    END.
                                    else IF temp-thbj-attr.prop-code = {&attr-marking_checkDate} THEN 
                                      DO:
                                        S-type-checkDate = temp-thbj-attr.property-value-character .
                                      END.
                                      else IF temp-thbj-attr.prop-code = {&attr-marking_checkMRC} THEN 
                                        DO:
                                          S-type-checkMRC = temp-thbj-attr.property-value-character .
                                        END.
                                        else IF temp-thbj-attr.prop-code = {&attr-marking_checkOwner} THEN 
                                          DO:
                                            S-type-checkOwner = temp-thbj-attr.property-value-character .
                                          END.
                                          else IF temp-thbj-attr.prop-code = {&attr-marking_checkStatusKM} THEN 
                                            DO:
                                              S-type-checkStatusKM = temp-thbj-attr.property-value-character .
                                            END.                                                         
                                            else IF temp-thbj-attr.prop-code = {&attr-marking_checkTracking} THEN 
                                              DO:
                                                S-type-checkTracking = temp-thbj-attr.property-value-character .
                                              END.                                                                                                               
  END.
  for each type-marking:
/*    if lookup (type-marking.mark-orig,S-type-mark) > 0 then type-marking.mark = true .*/
/*    else type-marking.mark = false .                                                  */
    if lookup (type-marking.mark-orig,S-type-EDO) > 0 then type-marking.EDO = true .
    else type-marking.EDO = false .
    if lookup (type-marking.mark-orig,S-type-artic) > 0 then type-marking.artic = true .
    else type-marking.artic = false . 
    if lookup (type-marking.mark-orig,S-type-transitional) > 0 then type-marking.transitional = true .
    else type-marking.transitional = false .
/*    if lookup (type-marking.mark-orig,S-type-blockCashUnMark) > 0 then type-marking.blockCashUnMark = true .
    else type-marking.blockCashUnMark = false . */
    if lookup (type-marking.mark-orig,S-type-saleReturn) > 0 then type-marking.saleReturn = true .
    else type-marking.saleReturn = false .
/*    if lookup (type-marking.mark-orig,S-type-saleUPD) > 0 then type-marking.saleUPD = true .
    else type-marking.saleUPD = false . */
/*    if lookup (type-marking.mark-orig,S-type-onlySale) > 0 then type-marking.onlySale = true .
    else type-marking.onlySale = false .  */
    if lookup (type-marking.mark-orig,S-type-checkBlock) > 0 then type-marking.checkBlock = true .
    else type-marking.checkBlock = false .    
    if lookup (type-marking.mark-orig,S-type-checkDate) > 0 then type-marking.checkDate = true .
    else type-marking.checkDate = false .  
    if lookup (type-marking.mark-orig,S-type-checkMRC) > 0 then type-marking.checkMRC = true .
    else type-marking.checkMRC = false .  
    if lookup (type-marking.mark-orig,S-type-checkOwner) > 0 then type-marking.checkOwner = true .
    else type-marking.checkOwner = false .  
    if lookup (type-marking.mark-orig,S-type-checkStatusKM) > 0 then type-marking.checkStatusKM = true .
    else type-marking.checkStatusKM = false .
    if lookup (type-marking.mark-orig,S-type-checkTracking) > 0 then type-marking.checkTracking = true .
    else type-marking.checkTracking = false .                   
  end.   
  
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}    
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-tt Dialog-Frame 
PROCEDURE init-tt :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable ii as integer no-undo .
define variable MarkType as ibs.th.gbl.map.mapstring no-undo.
define variable objType  as ibs.th.gbl.propmap no-undo.

define variable Types as ibs.th.gbl.TypeMap no-undo.
Types = ObjSrv:Env:Marking:Types.
MarkType = Types:mapType.

do ii = 1 to MarkType:GetItemByLab(ii):
objType  = ObjSrv:Env:Marking:Types:CurrProp.
create type-marking .
assign
   type-marking.mark-orig = objType:NameProp 
   type-marking.mark-type = objType:Label_ . 
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE save-proc Dialog-Frame 
PROCEDURE save-proc :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-param-type as character no-undo .
define variable v-gds-copy-list as character no-undo .
define variable v-gdsreffi as character no-undo .
define variable wh as widget-handle no-undo .
define variable fh as widget-handle no-undo .
define variable v-same as logical no-undo .

define buffer buf_temp-thbj-attr for temp-thbj-attr .

IF p-mode = {&LOOKUP} THEN RETURN ERROR.


ASSIGN FRAME {&FRAME-NAME}
    t-edo
    t-edo-NotMark
/*    S-type    */
/*    S-type-edo*/
    t-manual
    cb-gray_zone_qnty
    t-ban_recipes
    t-ban-altr
        t-bar-code
        t-rus-key
    .
  /* S-type-mark = "" . */
  S-type-artic = "" .
  S-type-EDO = "" .
  S-type-transitional = "".    
/*  S-type-blockCashUnMark = "". */
  S-type-saleReturn = "".
/*  S-type-saleUPD = "". */
/*  S-type-onlySale = "". */
  S-type-checkBlock = "".
  S-type-checkDate = "".
  S-type-checkMRC = "".
  S-type-checkOwner = "".
  S-type-checkStatusKM = "".
  S-type-checkTracking = "".
  for each thbjattr-list :
      delete thbjattr-list.
  end.    
  for each type-marking:
/*    if type-marking.mark = true then S-type-mark = S-type-mark + "," + type-marking.mark-orig .*/
    if type-marking.edo = true then S-type-EDO = S-type-edo + "," + type-marking.mark-orig .
    if type-marking.artic = true then S-type-artic = S-type-artic + "," + type-marking.mark-orig .
    if type-marking.transitional = true then S-type-transitional = S-type-transitional + "," + type-marking.mark-orig .   
/*    if type-marking.blockCashUnMark = true then S-type-blockCashUnMark = S-type-blockCashUnMark + "," + type-marking.mark-orig .   */
    if type-marking.saleReturn = true then S-type-saleReturn = S-type-saleReturn + "," + type-marking.mark-orig .   
/*    if type-marking.saleUPD = true then S-type-saleUPD = S-type-saleUPD + "," + type-marking.mark-orig .    */
/*    if type-marking.onlySale = true then S-type-onlySale = S-type-onlySale + "," + type-marking.mark-orig .    */
    if type-marking.checkBlock = true then S-type-checkBlock = S-type-checkBlock + "," + type-marking.mark-orig .
    if type-marking.checkDate = true then S-type-checkDate = S-type-checkDate + "," + type-marking.mark-orig .
    if type-marking.checkMRC = true then S-type-checkMRC = S-type-checkMRC + "," + type-marking.mark-orig .
    if type-marking.checkOwner = true then S-type-checkOwner = S-type-checkOwner + "," + type-marking.mark-orig .
    if type-marking.checkStatusKM = true then S-type-checkStatusKM = S-type-checkStatusKM + "," + type-marking.mark-orig .
    if type-marking.checkTracking = true then S-type-checkTracking = S-type-checkTracking + "," + type-marking.mark-orig .   
  end.    

  find first temp-thbj-attr where temp-thbj-attr.prop-code = {&attr-marking_marking-edo} and temp-thbj-attr.obj-code = p-obj-code and temp-thbj-attr.obj-type = p-obj-type.
  temp-thbj-attr.property-value-logical = t-edo.
  find first temp-thbj-attr where temp-thbj-attr.prop-code = {&attr-marking_marking-EDO-NotMark} and temp-thbj-attr.obj-code = p-obj-code and temp-thbj-attr.obj-type = p-obj-type.
  temp-thbj-attr.property-value-logical = t-edo-NotMark.
  find first temp-thbj-attr where temp-thbj-attr.prop-code = {&attr-marking_marking-manual} and temp-thbj-attr.obj-code = p-obj-code and temp-thbj-attr.obj-type = p-obj-type.
  temp-thbj-attr.property-value-logical = t-manual.
  /* find first temp-thbj-attr where temp-thbj-attr.prop-code = {&attr-marking_marking-type} and temp-thbj-attr.obj-code = p-obj-code and temp-thbj-attr.obj-type = p-obj-type.
  temp-thbj-attr.property-value-character = trim(S-type-mark,","). */
  find first temp-thbj-attr where temp-thbj-attr.prop-code = {&attr-marking_marking-type-edo} and temp-thbj-attr.obj-code = p-obj-code and temp-thbj-attr.obj-type = p-obj-type.
  temp-thbj-attr.property-value-character = trim(S-type-edo,","). 
  find first temp-thbj-attr where temp-thbj-attr.prop-code = {&attr-marking_marking-type-artic} and temp-thbj-attr.obj-code = p-obj-code and temp-thbj-attr.obj-type = p-obj-type.
  temp-thbj-attr.property-value-character = trim(S-type-artic,",").
  find first temp-thbj-attr where temp-thbj-attr.prop-code = {&attr-marking_marking-type-transitional} and temp-thbj-attr.obj-code = p-obj-code and temp-thbj-attr.obj-type = p-obj-type.
  temp-thbj-attr.property-value-character = trim(S-type-transitional,",").
/*  find first temp-thbj-attr where temp-thbj-attr.prop-code = {&attr-marking_marking-type-blockCashUnMark} and temp-thbj-attr.obj-code = p-obj-code and temp-thbj-attr.obj-type = p-obj-type.
  temp-thbj-attr.property-value-character = trim(S-type-blockCashUnMark,","). */
  find first temp-thbj-attr where temp-thbj-attr.prop-code = {&attr-marking_marking-type-saleReturn} and temp-thbj-attr.obj-code = p-obj-code and temp-thbj-attr.obj-type = p-obj-type.
  temp-thbj-attr.property-value-character = trim(S-type-saleReturn,",").
/*  find first temp-thbj-attr where temp-thbj-attr.prop-code = {&attr-marking_marking-type-saleUPD} and temp-thbj-attr.obj-code = p-obj-code and temp-thbj-attr.obj-type = p-obj-type.
  temp-thbj-attr.property-value-character = trim(S-type-saleUPD,","). */
/*  find first temp-thbj-attr where temp-thbj-attr.prop-code = {&attr-marking_marking-type-onlySale} and temp-thbj-attr.obj-code = p-obj-code and temp-thbj-attr.obj-type = p-obj-type.
  temp-thbj-attr.property-value-character = trim(S-type-onlySale,","). */
  find first temp-thbj-attr where temp-thbj-attr.prop-code = {&attr-marking_gray_zone_qnty} and temp-thbj-attr.obj-code = p-obj-code and temp-thbj-attr.obj-type = p-obj-type.
  temp-thbj-attr.property-value-integer = cb-gray_zone_qnty.    
  find first temp-thbj-attr where temp-thbj-attr.prop-code = {&attr-marking_ban-recipes} and temp-thbj-attr.obj-code = p-obj-code and temp-thbj-attr.obj-type = p-obj-type.
  temp-thbj-attr.property-value-logical = t-ban_recipes.    
  find first temp-thbj-attr where temp-thbj-attr.prop-code = {&attr-marking_ban-altr} and temp-thbj-attr.obj-code = p-obj-code and temp-thbj-attr.obj-type = p-obj-type.
  temp-thbj-attr.property-value-logical = t-ban-altr. 
  find first temp-thbj-attr where temp-thbj-attr.prop-code = {&attr-marking_bar-code} and temp-thbj-attr.obj-code = p-obj-code and temp-thbj-attr.obj-type = p-obj-type.
  temp-thbj-attr.property-value-logical = t-bar-code. 
  find first temp-thbj-attr where temp-thbj-attr.prop-code = {&attr-marking_rus-key} and temp-thbj-attr.obj-code = p-obj-code and temp-thbj-attr.obj-type = p-obj-type.
  IF AVAILABLE temp-thbj-attr THEN temp-thbj-attr.property-value-logical = t-rus-key.  
  find first temp-thbj-attr where temp-thbj-attr.prop-code = {&attr-marking_checkBlock} and temp-thbj-attr.obj-code = p-obj-code and temp-thbj-attr.obj-type = p-obj-type.
  IF AVAILABLE temp-thbj-attr THEN DO:
     IF temp-thbj-attr.property-value-character <> trim(S-type-checkBlock,",")
     THEN DO:
         create thbjattr-list.
         buffer-copy temp-thbj-attr to thbjattr-list.           
     END.
     temp-thbj-attr.property-value-character = trim(S-type-checkBlock,",").
  END.     
  find first temp-thbj-attr where temp-thbj-attr.prop-code = {&attr-marking_checkDate} and temp-thbj-attr.obj-code = p-obj-code and temp-thbj-attr.obj-type = p-obj-type.
  IF AVAILABLE temp-thbj-attr THEN DO:
     IF temp-thbj-attr.property-value-character <> trim(S-type-checkDate,",")
     THEN DO:
         create thbjattr-list.
         buffer-copy temp-thbj-attr to thbjattr-list.           
     END. 
     temp-thbj-attr.property-value-character = trim(S-type-checkDate,",").
  END.     
  find first temp-thbj-attr where temp-thbj-attr.prop-code = {&attr-marking_checkMRC} and temp-thbj-attr.obj-code = p-obj-code and temp-thbj-attr.obj-type = p-obj-type.
  IF AVAILABLE temp-thbj-attr THEN DO:
     IF temp-thbj-attr.property-value-character <> trim(S-type-checkMRC,",")
     THEN DO:
         create thbjattr-list.
         buffer-copy temp-thbj-attr to thbjattr-list.           
     END. 
     temp-thbj-attr.property-value-character = trim(S-type-checkMRC,",").
  END.     
  find first temp-thbj-attr where temp-thbj-attr.prop-code = {&attr-marking_checkOwner} and temp-thbj-attr.obj-code = p-obj-code and temp-thbj-attr.obj-type = p-obj-type.  
  IF AVAILABLE temp-thbj-attr THEN DO:
     IF temp-thbj-attr.property-value-character <> trim(S-type-checkOwner,",")
     THEN DO:
         create thbjattr-list.
         buffer-copy temp-thbj-attr to thbjattr-list.           
     END.  
     temp-thbj-attr.property-value-character = trim(S-type-checkOwner,",").
  END.     
  find first temp-thbj-attr where temp-thbj-attr.prop-code = {&attr-marking_checkStatusKM} and temp-thbj-attr.obj-code = p-obj-code and temp-thbj-attr.obj-type = p-obj-type.
  IF AVAILABLE temp-thbj-attr THEN DO:
     IF temp-thbj-attr.property-value-character <> trim(S-type-checkStatusKM,",")
     THEN DO:
         create thbjattr-list.
         buffer-copy temp-thbj-attr to thbjattr-list.           
     END.
     temp-thbj-attr.property-value-character = trim(S-type-checkStatusKM,",").
  END.   
  find first temp-thbj-attr where temp-thbj-attr.prop-code = {&attr-marking_checkTracking} and temp-thbj-attr.obj-code = p-obj-code and temp-thbj-attr.obj-type = p-obj-type.
  IF AVAILABLE temp-thbj-attr THEN DO:
     IF temp-thbj-attr.property-value-character <> trim(S-type-checkTracking,",")
     THEN DO:
         create thbjattr-list.
         buffer-copy temp-thbj-attr to thbjattr-list.           
     END. 
     temp-thbj-attr.property-value-character = trim(S-type-checkTracking,",").
  END.     

  do transaction:
    RUN thbjattr_set-section IN THIS-PROCEDURE (
      input p-obj-type
      ,input p-obj-code
      ,input {&attr-marking}
      ,INPUT table temp-thbj-attr
      ) NO-ERROR.
    if error-status:error then 
    do:
      message "Не удалось сохранить настройки"
        view-as alert-box.
      undo, return error.
    end.
    if can-find(first thbjattr-list) then 
        run str/diallog.w (
            input parparentproc
          , input this-procedure
          , input "str/send-all.p":U
          , input ( p-obj-type + {&delim-par} + string(p-obj-code) + {&delim-par} + 'U':U + {&delim-par} + 'gismt':U + {&delim-par} + 'Передача параметров работы с ТСПИоТ':U)
          , input ? /*p-auto-go*/
          , input "":U
          , input substitute("Отсылка параметров работы с ТСПИоТ")
          ) no-error.
  end.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION isArticAvail Dialog-Frame 
FUNCTION isArticAvail RETURNS LOGICAL
  ( /* parameter-definitions */ ) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/

  RETURN not type-marking.EDO .   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION isMarkAZKAvail Dialog-Frame 
FUNCTION isMarkAZKAvail RETURNS LOGICAL
  ( /* parameter-definitions */ ) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/

  RETURN not type-marking.artic and type-marking.EDO and not type-marking.transitional.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION isMarkVnAvail Dialog-Frame 
FUNCTION isMarkVnAvail RETURNS LOGICAL
  ( /* parameter-definitions */ ) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/

  RETURN not type-marking.artic and not type-marking.transitional.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION isTransitionalAvail Dialog-Frame 
FUNCTION isTransitionalAvail RETURNS LOGICAL
  ( /* parameter-definitions */ ) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/

  RETURN not type-marking.mark and ( type-marking.EDO or type-marking.artic).   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION isblockCashUnMarkAvail Dialog-Frame 
FUNCTION isblockCashUnMarkAvail RETURNS LOGICAL
  ( /* parameter-definitions */ ) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/
 
  RETURN isMarkAZKAvail().   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION issalereturnAvail Dialog-Frame 
FUNCTION issaleReturnAvail RETURNS LOGICAL
  ( /* parameter-definitions */ ) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/

  RETURN yes.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION issaleUPDAvail Dialog-Frame 
FUNCTION issaleUPDAvail RETURNS LOGICAL
  ( /* parameter-definitions */ ) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/

  RETURN yes.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION isonlySaleAvail Dialog-Frame 
FUNCTION isonlySaleAvail RETURNS LOGICAL
  ( /* parameter-definitions */ ) :
  /*------------------------------------------------------------------------------
    Purpose:  
      Notes:  
  ------------------------------------------------------------------------------*/

  RETURN yes.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION ischeckBlockAvail Dialog-Frame 
FUNCTION ischeckBlockAvail RETURNS LOGICAL
  ( /* parameter-definitions */ ) :
  /*------------------------------------------------------------------------------
    Purpose:  
      Notes:  
  ------------------------------------------------------------------------------*/

  RETURN yes.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION ischeckDateAvail Dialog-Frame 
FUNCTION ischeckDateAvail RETURNS LOGICAL
  ( /* parameter-definitions */ ) :
  /*------------------------------------------------------------------------------
    Purpose:  
      Notes:  
  ------------------------------------------------------------------------------*/

  RETURN yes.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION ischeckMRCAvail Dialog-Frame 
FUNCTION ischeckMRCAvail RETURNS LOGICAL
  ( /* parameter-definitions */ ) :
  /*------------------------------------------------------------------------------
    Purpose:  
      Notes:  
  ------------------------------------------------------------------------------*/

  RETURN yes.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION ischeckOwnerAvail Dialog-Frame 
FUNCTION ischeckOwnerAvail RETURNS LOGICAL
  ( /* parameter-definitions */ ) :
  /*------------------------------------------------------------------------------
    Purpose:  
      Notes:  
  ------------------------------------------------------------------------------*/

  RETURN yes.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION ischeckStatusKMAvail Dialog-Frame 
FUNCTION ischeckStatusKMAvail RETURNS LOGICAL
  ( /* parameter-definitions */ ) :
  /*------------------------------------------------------------------------------
    Purpose:  
      Notes:  
  ------------------------------------------------------------------------------*/

  RETURN yes.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION ischeckTrackingAvail Dialog-Frame 
FUNCTION ischeckTrackingAvail RETURNS LOGICAL
  ( /* parameter-definitions */ ) :
  /*------------------------------------------------------------------------------
    Purpose:  
      Notes:  
  ------------------------------------------------------------------------------*/

  RETURN yes.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
