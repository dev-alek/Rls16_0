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

Синхранизация товаров с Меркурием

Автор: Шкляр Елена  
Дата создания: 10/10/08
Author: Shklyar Elena
Creation date: 10/10/08
*/
/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

&ANALYZE-SUSPEND _EXPORT-NUMBER AB_v10r12
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 


/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES gds-mercury

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS BROWSE-3 f-guid B-exit b-quit B-Help 
&Scoped-Define DISPLAYED-OBJECTS f-guid 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */

&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES

/* SETTINGS FOR DIALOG-BOX Dialog-Frame
                                                                        */
/* BROWSE-TAB BROWSE-3 1 Dialog-Frame */
/* SETTINGS FOR FILL-IN f-guid IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
/*&ANALYZE-RESUME*/

using ibs.th.str.gds.*.
using ibs.th.str.mercury.*.
using ibs.th.bge.mercury.*.
using ibs.th.gbl.storage.*.
using ibs.th.str.clients.*.


/* Parameters Definitions ---                                           */

define input parameter parparentproc as widget-handle no-undo .

/* Local Variable Definitions ---                                       */

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Синхранизация товаров с Меркурием".

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ str/lib-trn.i  }
{ cmp/showinf.i  }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ gbl/thbjattr.i }
{ gbl/clntattr.i }
{ gbl/color.i    }
{ ref/extclass.i }
{ gbl/key-rec.i  }
{ gbl/attr-lib.i }
{ ref/gds-attr.i }
{ cmp/gds-list.i gds-list def "new shared" }
{ str/temp_merq.i}

define temp-table tt-gds like ub.gds-mercury 
  field gds-name as character label "Наименование в ТН"
  field units-th as character label "Ед.измерения в ТН"
  field units    as character label "Ед.измерения".

define temp-table tt-gds-units no-undo 
  field GUID_ as character
  field units as character 
  .

define variable gdsMercsubsObj as class     gdsmercsubs.
define variable gdsMercObj     as class     gdsmercsub.
define variable gdsmercstrObj  as class     gdsmercstr.
define variable parser         as class     ParserXMLGds.

define variable v-login        as character no-undo .
define variable v-password     as character no-undo .
define variable v-server       as character no-undo .

define variable v-proxy-login  as character no-undo .
define variable v-proxy-pswd   as character no-undo .
define variable v-proxy-addres as character no-undo .
define variable v-proxy-ssl    as logical   no-undo .


define variable par-type       as character no-undo.

define buffer buf_tt-gds       for tt-gds .
define buffer buf_gds-mercury  for ub.gds-mercury .

define buffer buf_clients      for ub.clients .
define buffer buf_clients-attr for ub.clients-attr .
define buffer buf_goods        for ub.goods .
define buffer buf_goods-attr   for ub.goods-attr .

define variable select-list       as longchar  no-undo .
define variable v-select-list     as character no-undo .
define variable ref-list          as character no-undo .
define variable rid-list          as character no-undo .
define variable v-rid             as recid     no-undo .
define variable ii                as integer   no-undo .
define variable v-list            as character no-undo .
define variable v-gds-code        as integer   no-undo .

define variable glog              as logical   no-undo .

define variable gds-rec           as recid     no-undo .

define variable v-value-character as character no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .
define variable v-value-logical   as logical   no-undo .
define variable v-value-type      as character no-undo .
define variable v-value-date      as date      no-undo .

define variable gdsTHObj          as class     gdssub.

define variable vsdsTHObj         as class     vsdsubs.

define variable vsdStorage        as class     vsdtostorage.

function get-mark returns character
  (buffer local-gds for tt-gds ):
  if select-list <> ? or select-list <> "" then 
  do:
    if lookup (string (recid (local-gds)), select-list) > 0  then return "*".
    else return "".
  end.
  else return "".
  
end function.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-goods

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-gds

/* Definitions for BROWSE br-goods                                      */
&Scoped-define FIELDS-IN-QUERY-br-goods get-mark(BUFFER tt-gds) tt-gds.gds-code tt-gds.merc-name tt-gds.gds-name tt-gds.GUID tt-gds.UUID tt-gds.units tt-gds.units_th tt-gds.prod-type tt-gds.cr-date tt-gds.update-date   
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-goods   
&Scoped-define SELF-NAME br-goods
&Scoped-define QUERY-STRING-br-goods FOR EACH tt-gds
&Scoped-define OPEN-QUERY-br-goods OPEN QUERY {&SELF-NAME} FOR EACH tt-gds.
&Scoped-define TABLES-IN-QUERY-br-goods tt-gds
&Scoped-define FIRST-TABLE-IN-QUERY-br-goods tt-gds


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-goods}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-cancel b-load b-lkp b-update b-del ~
b-connect b-alt-units b-import r-type b-mark b-sel-all b-unmark rs-sort ~
guid_ br-goods 
&Scoped-Define DISPLAYED-OBJECTS r-type rs-sort guid_ 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Menu Definitions                                                     */
DEFINE MENU POPUP-MENU-b-import 
  MENU-ITEM m_item_import  LABEL "Импорт товаров"
  MENU-ITEM m_item_send    LABEL "Передача данных в УБД".


/* Definitions of the field level widgets                               */
DEFINE BUTTON b-alt-units 
  LABEL "Доп. ед. изм." 
  SIZE 14 BY 1.13
  BGCOLOR 8 .

DEFINE BUTTON b-cancel AUTO-END-KEY 
  LABEL "Выход" 
  SIZE 13 BY 1.13
  BGCOLOR 8 .

DEFINE BUTTON b-connect 
  LABEL "Связать" 
  SIZE 13 BY 1.13
  BGCOLOR 8 .

DEFINE BUTTON b-del 
  LABEL "Удалить" 
  SIZE 13 BY 1.13
  BGCOLOR 8 .

DEFINE BUTTON b-import 
  LABEL "Сервис" 
  SIZE 13 BY 1.13 TOOLTIP "Импорт"
  BGCOLOR 8 .

DEFINE BUTTON b-lkp 
  LABEL "Просмотр" 
  SIZE 13 BY 1.13
  BGCOLOR 8 .

DEFINE BUTTON b-load 
  LABEL "Запрос" 
  SIZE 13 BY 1.13 TOOLTIP "Отправить запрос в Меркурий"
  BGCOLOR 8 .

DEFINE BUTTON b-mark 
  LABEL "&*" 
  SIZE 3 BY 1.13.

DEFINE BUTTON b-prod 
  IMAGE-UP FILE "btn-down-arrow":U
  IMAGE-DOWN FILE "btn-down-arrow":U
  IMAGE-INSENSITIVE FILE "btn-down-arrow":U
  LABEL "" 
  SIZE 3 BY 1.13 TOOLTIP "Выбор производителя".

DEFINE BUTTON b-sel-all 
  LABEL "&+":L 
  SIZE 3 BY 1.13 TOOLTIP "Отметить все объекты".

DEFINE BUTTON b-spisok 
  IMAGE-UP FILE "btn-down-arrow":U
  IMAGE-DOWN FILE "btn-down-arrow":U
  IMAGE-INSENSITIVE FILE "btn-down-arrow":U
  LABEL "Товары" 
  SIZE 3 BY 1.13 TOOLTIP "Выбор товаров".

DEFINE BUTTON b-unmark 
  LABEL "&-":L 
  SIZE 3 BY 1.13 TOOLTIP "Снять все отметки".

DEFINE BUTTON b-update 
  LABEL "Изменить" 
  SIZE 13 BY 1.13
  BGCOLOR 8 .

DEFINE VARIABLE guid_       AS CHARACTER FORMAT "X(256)":U 
  LABEL "GUID" 
  VIEW-AS FILL-IN 
  SIZE 33.5 BY 1 NO-UNDO.

DEFINE VARIABLE v-prod      AS CHARACTER FORMAT "X(11)" 
  LABEL "Производитель" 
  VIEW-AS TEXT 
  SIZE 11 BY .67 NO-UNDO.

DEFINE VARIABLE v-prod-name AS CHARACTER FORMAT "X(30)" 
  VIEW-AS TEXT 
  SIZE 30 BY .67 NO-UNDO.

DEFINE VARIABLE r-type      AS INTEGER   INITIAL 1 
  VIEW-AS RADIO-SET VERTICAL
  RADIO-BUTTONS 
  "По производителю", 1,
  "По списку товаров", 2
  SIZE 26 BY 1.75 NO-UNDO.

DEFINE VARIABLE rs-sort     AS INTEGER   INITIAL 3 
  VIEW-AS RADIO-SET HORIZONTAL
  RADIO-BUTTONS 
  "&связан", 1,
  "&не связан", 2,
  "&все", 3
  SIZE 40 BY 1.13 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-goods FOR 
  tt-gds SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-goods
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-goods Dialog-Frame _FREEFORM
  QUERY br-goods DISPLAY
  get-mark(BUFFER tt-gds) column-label "*"  format "X(1)":U
  tt-gds.gds-code column-label "Код товара" format ">>>>>>>>9"
  tt-gds.merc-name column-label "Наименование товара" format "X(100)":U width 28
  tt-gds.gds-name column-label "Наим. товара в ТН" format "X(100)":U width 28
  tt-gds.GUID column-label "GUID" format "X(36)":U
  tt-gds.UUID column-label "UUID" format "X(36)":U
  tt-gds.units column-label "Ед.измерения" format "X(5)":U
  tt-gds.units-th column-label "Ед.измерения в ТН" format "X(5)":U 
  tt-gds.prod-type column-label "Тип продукции" format "X(36)":U
  tt-gds.cr-date column-label "Дата создания" format "99.99.9999":U
  tt-gds.update-date column-label "Дата последнего изменения в ТН" format "99.99.9999":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH SEPARATORS SIZE 105 BY 20.21 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
  b-cancel AT ROW 1.25 COL 2
  b-load AT ROW 1.25 COL 15
  b-lkp AT ROW 1.25 COL 28
  b-update AT ROW 1.25 COL 41
  b-del AT ROW 1.25 COL 54
  b-connect AT ROW 1.25 COL 67
  b-alt-units AT ROW 1.25 COL 80
  b-import AT ROW 1.25 COL 94
  r-type AT ROW 2.5 COL 2.25 NO-LABEL WIDGET-ID 20
  b-prod AT ROW 2.5 COL 71.5
  b-spisok AT ROW 3.25 COL 22.25 WIDGET-ID 26
  b-mark AT ROW 4.5 COL 2
  b-sel-all AT ROW 4.5 COL 5 WIDGET-ID 28
  b-unmark AT ROW 4.5 COL 8 WIDGET-ID 30
  rs-sort AT ROW 4.54 COL 28 NO-LABEL
  guid_ AT ROW 4.54 COL 71.25 COLON-ALIGNED WIDGET-ID 32
  br-goods AT ROW 5.79 COL 2 WIDGET-ID 200
  v-prod AT ROW 2.71 COL 57.5 COLON-ALIGNED
  v-prod-name AT ROW 2.71 COL 74.5 COLON-ALIGNED NO-LABEL
  "Сортировать по:" VIEW-AS TEXT
  SIZE 15 BY 1.13 AT ROW 4.54 COL 12 WIDGET-ID 18
  SPACE(81.00) SKIP(20.65)
  WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
  SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
  TITLE "Синхронизация товаров с Меркурием"
  DEFAULT-BUTTON b-load CANCEL-BUTTON b-cancel WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
   Other Settings: COMPILE
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-goods guid Dialog-Frame */
ASSIGN 
  FRAME Dialog-Frame:SCROLLABLE = FALSE
  FRAME Dialog-Frame:HIDDEN     = TRUE.

ASSIGN 
  b-import:POPUP-MENU IN FRAME Dialog-Frame = MENU POPUP-MENU-b-import:HANDLE.

/* SETTINGS FOR BUTTON b-prod IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN 
  b-prod:HIDDEN IN FRAME Dialog-Frame = TRUE.

/* SETTINGS FOR BUTTON b-spisok IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN 
  b-spisok:HIDDEN IN FRAME Dialog-Frame = TRUE.

ASSIGN 
  br-goods:COLUMN-RESIZABLE IN FRAME Dialog-Frame = TRUE.

/* SETTINGS FOR FILL-IN v-prod IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN 
  v-prod:HIDDEN IN FRAME Dialog-Frame = TRUE.

/* SETTINGS FOR FILL-IN v-prod-name IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN 
  v-prod-name:HIDDEN IN FRAME Dialog-Frame = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-goods
/* Query rebuild information for BROWSE br-goods
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-gds.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE br-goods */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON window-close OF FRAME Dialog-Frame /* Синхронизация товаров с Меркурием */
  do:
    apply "END-ERROR":U to self.
  end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-cancel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-cancel Dialog-Frame
ON choose OF b-cancel IN FRAME Dialog-Frame /* Выход */
  do:
    for each tt-gds:
      delete tt-gds .
    end.
  end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-connect
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-connect Dialog-Frame
ON choose OF b-connect IN FRAME Dialog-Frame /* Связать */
  do:
    if not available tt-gds then 
    do:
      message "Не выбран товар" view-as alert-box.
      return no-apply.
    end.
    v-rid = recid (tt-gds) .
    find first ub.goods-attr no-lock where ub.goods-attr.attr-code = {&attr-mercur_FGIS}
      and ub.goods-attr.attr-value = "yes" and ub.goods-attr.gds-code = tt-gds.gds-code no-error .
    if not available (ub.goods-attr) then 
    do:
      message
        "У товара нет атрибута - 'Является подконтрольным ФГИС Меркурий'"
        view-as alert-box.
      leave .
    end. 
    run ref/merq-connect.w (parparentproc, 
      input-output tt-gds.gds-code) no-error .
    run fill-tt .
    run refresh-query in this-procedure.
    if v-rid <> ? then
      reposition br-goods to recid v-rid .
  end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del Dialog-Frame
ON choose OF b-del IN FRAME Dialog-Frame /* Удалить */
  do:
    define variable choice         as logical no-undo .
    define variable ii             as integer no-undo .
    define variable jj             as integer no-undo .
    define variable gdsMercsubsObj as class   gdsmercsubs.
    define variable gdsmercstrObj  as class   gdsmercstr.
    
    if not available tt-gds then 
    do:
      message "Не выбран товар" view-as alert-box.
      return no-apply.
    end.
    v-rid = recid(tt-gds) .
    gdsMercsubsObj = new gdsmercsubs ().
    gdsmercstrObj = new gdsmercstr ().
    if select-list = "" then 
    do:
      gdsMercsubsObj = gdsmercstrObj:getgdsmercs(tt-gds.gds-code).
      message
        "Удалить связку товара с Меркурием?"
        view-as alert-box question buttons yes-no update choice.
      if choice then 
      do:
        if valid-object (gdsMercsubsObj:GdsMercsubsCurr) then 
        do:
          do ii = 1 to gdsMercsubsObj:GetItem (ii): 
            gdsMercObj = gdsMercsubsObj:GdsMercsubsCurr.
          end.
          gdsmercstrObj:deleteDB(gdsMercObj).         
        end.
        else 
        do:
          message "У товара нет привязки к Меркурию"
            view-as alert-box.
        end.  
      end.
    end.
    else 
    do:
      select-list = trim(select-list) .
      message
        "Удалить связки выбранных товаров с Меркурием?"
        view-as alert-box question buttons yes-no update choice.
      if choice then 
      do:
        do jj = 1 to num-entries (select-list):
          v-list = entry(jj,select-list) no-error .
          for first tt-gds exclusive-lock where recid(tt-gds) = integer(v-list):
            gdsMercsubsObj = gdsmercstrObj:getgdsmercs(tt-gds.gds-code).

            if valid-object (gdsMercsubsObj:GdsMercsubsCurr) then 
            do:
              do ii = 1 to gdsMercsubsObj:GetItem (ii): 
                gdsMercObj = gdsMercsubsObj:GdsMercsubsCurr.
              end.
              gdsmercstrObj:deleteDB(gdsMercObj).         
            end.
          end.
        end.
      end.  
    end.  

    delete object gdsMercObj no-error .
    delete object gdsmercstrObj no-error .
    delete object gdsMercsubsObj no-error .
    run fill-tt.
    run refresh-query in this-procedure.   
    reposition br-goods to recid v-rid .
  end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-lkp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-lkp Dialog-Frame
ON choose OF b-lkp IN FRAME Dialog-Frame /* Просмотр */
  do:
    if not available tt-gds then 
    do:
      message "Не выбран товар" view-as alert-box.
      return no-apply.
    end.
    v-rid = recid(tt-gds) .
    run ref/merq-gds.w (
      parparentproc
      ,input-output tt-gds.gds-code
      ,input {&lookup}
      ) no-error .
    
    run refresh-query in this-procedure.    
    reposition br-goods to recid v-rid .
     
  end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-load
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-load Dialog-Frame
ON choose OF b-load IN FRAME Dialog-Frame /* Запрос */
  do:
    
    define variable cmd        as character no-undo .
    define variable sw         as handle    no-undo .
    define variable v-file     as character no-undo initial "getProductItemList_.xml".
    define variable v-file-gds as character no-undo initial "getItemList_.xml".
    define buffer buf_ext-classif for ub.ext-classif.
    define buffer buf_ext-system  for ub.ext-system.
    define variable v-prod-guid as character no-undo .
    define variable v-gds-guid  as character no-undo .
    define variable jj          as integer   no-undo . 
    define variable Msg         as character no-undo .
    gdsMercsubsObj = new gdsmercsubs ().
    gdsmercstrObj = new gdsmercstr ().
    
    if not available tt-gds then 
    do:
      message "Не выбран товар" view-as alert-box.
      return no-apply.
    end.
    
    if select-list = "" and v-prod = "" then select-list = string(recid(tt-gds)) .
    
    if select-list <> "" then 
    do:
      select-list = trim (select-list) .
      do jj = 1 to num-entries (select-list):
        v-list = (entry(jj, select-list)).
        for first tt-gds exclusive-lock where recid(tt-gds) = integer(v-list) :
          if tt-gds.GUID <> "" then 
          do:
            gdsMercsubsObj = gdsmercstrObj:getgdsmercs(tt-gds.gds-code).

            if valid-object (gdsMercsubsObj:GdsMercsubsCurr) then
            do:
              v-gds-guid = gdsMercsubsObj:GdsMercsubsCurr:GUID_ .
              create sax-writer sw .
    
              sw:formatted = true.
              sw:set-output-destination ("file", v-file-gds).
              sw:encoding = "UTF-8".
    
              sw:start-document () .
              sw:start-element ("se:Envelope") .
    
              sw:insert-attribute ("xmlns:se", "http://schemas.xmlsoap.org/soap/envelope/") .
              sw:insert-attribute ("xmlns:ws", "http://api.vetrf.ru/schema/cdm/registry/ws-definitions/v2") .
              sw:insert-attribute ("xmlns:bs", "http://api.vetrf.ru/schema/cdm/base") .
              sw:insert-attribute ("xmlns:dt", "http://api.vetrf.ru/schema/cdm/dictionary/v2") .
    
              sw:start-element ("se:Body") .
              sw:start-element ("ws:getProductItemByGuidRequest") .
              sw:write-data-element ("bs:guid", v-gds-guid) .
              sw:end-element ("ws:getProductItemByGuidRequest") .
              sw:end-element ("se:Body") .
    
              sw:end-element ("se:Envelope") .
              sw:end-document () .
    

              if trim(v-proxy-addres) <> "" and v-proxy-addres <> ?
                then 
              do :
                if v-proxy-ssl
                  then 
                do :
                  cmd = substitute ("&1 -k --proxy-negotiate -x &7 -U : -u &4:&5 -d @&2 &6/platform/services/2.1/ProductService >&3",
                    search ("exe/curl.exe"), search (v-file-gds), "ItemList_.xml", v-login, v-password, v-server, v-proxy-addres).
                end.
                else 
                do :
                  cmd = substitute ("&1 -x &7 -U &8:&9 -u &4:&5 -d @&2 &6/platform/services/2.1/ProductService >&3",
                    search ("exe/curl.exe"), search (v-file-gds), "ItemList_.xml", v-login, v-password, v-server, v-proxy-addres, v-proxy-login, v-proxy-pswd).
                end.
              end.
              else 
              do :
                cmd = substitute ("&1 -u &4:&5 -d @&2 &6/platform/services/2.1/ProductService >&3", search ("exe/curl.exe"), search (v-file-gds), "ItemList_.xml", v-login, v-password, v-server).
              end.
              os-command silent value (cmd). /*закрытие окна*/
          
              parser = new parserXmlGDS().
              parser:ParseResponse
                (search("ItemList_.xml")
                ,input-output TABLE tt-gds-merq
                ,output Msg) no-error.
              if Msg <> "" then 
              do:
                message Msg
                  view-as alert-box.
              end.  
              else 
              do:
                find first tt-gds-merq no-lock no-error .
                if available (tt-gds-merq) then 
                do:
    
                  gdsMercsubsObj = gdsmercstrObj:getguidmercs(tt-gds-merq.GUID_). /*исправить на GUID*/
                  if valid-object (gdsMercsubsObj:GdsMercsubsCurr) then 
                  do:
                    do ii = 1 to gdsMercsubsObj:GetItem (ii): 
                      gdsMercObj = gdsMercsubsObj:GdsMercsubsCurr. /* выдернула конкретны объект*/
                    end.            
                    create tt-gds-units .
                    assign
                      gdsMercObj:MercName    = tt-gds-merq.merc-name
                      gdsMercObj:UUID        = tt-gds-merq.UUID
                      gdsMercObj:DateCr      = tt-gds-merq.crDate
                      gdsMercObj:DateUpdate  = tt-gds-merq.update_Date
                      gdsMercObj:ProdType    = string (tt-gds-merq.prod-type)
                      gdsMercObj:GUIDType    = tt-gds-merq.GUID-type
                      gdsMercObj:GUIDSubType = tt-gds-merq.GUID-subtype
                      tt-gds-units.units     = tt-gds-merq.units
                      tt-gds-units.GUID_     = tt-gds-merq.GUID_
                      .
                    gdsmercstrObj:updateDB(gdsMercObj). /*измение записи в бд */
                  end. /*if VALID-OBJECT (gdsMercsubsObj:GdsMercsubsCurr) then */
                end. /*if AVAILABLE (tt-gds-merq) then */
              end.
            end. /*if VALID-OBJECT (gdsMercsubsObj:GdsMercsubsCurr) then*/
          end. /*if tt-gds.GUID <> "" then */
        end. /*do jj = 1 to NUM-ENTRIES (select-list):*/
      end. /*if select-list <> "" then */
      run fill-tt .
      run refresh-query in this-procedure.
    end.
    else 
    do:  

      find first buf_ext-system no-lock where buf_ext-system.esys-type = integer({&openxml-type-mercury}) no-error.
      if not available buf_ext-system
        then 
      do :
      end.
      find first buf_ext-classif no-lock 
        where buf_ext-classif.classif-subject = {&table_clients}
        and buf_ext-classif.classif-name = {&extclass_clients_esys}
        and buf_ext-classif.db-num = 0
        and buf_ext-classif.key#_one = buf_ext-system.esys-id
        and buf_ext-classif.uniq-key-rec = {&table_clients} + {&delim-key} + buf_clients.obj-type + {&delim-key} + string (buf_clients.obj-code)
        no-error.
      if not available  buf_ext-classif
        then 
      do :
      
      end.     
      v-prod-guid = entry(2, buf_ext-classif.charKey_Two, {&delim-cmd}) no-error.      
      create sax-writer sw .
    
      sw:formatted = true.
      sw:set-output-destination ("file", v-file).
      sw:encoding = "UTF-8".
    
      sw:start-document () .
      sw:start-element ("se:Envelope") .
    
      sw:insert-attribute ("xmlns:se", "http://schemas.xmlsoap.org/soap/envelope/") .
      sw:insert-attribute ("xmlns:ws", "http://api.vetrf.ru/schema/cdm/registry/ws-definitions/v2") .
      sw:insert-attribute ("xmlns:bs", "http://api.vetrf.ru/schema/cdm/base") .
      sw:insert-attribute ("xmlns:dt", "http://api.vetrf.ru/schema/cdm/dictionary/v2") .
    
      sw:start-element ("se:Body") .
      sw:start-element ("ws:getProductItemListRequest") .
      sw:start-element ("bs:listOptions") .
      sw:write-data-element ("bs:count", "1000") .
      sw:write-data-element ("bs:offset", "0") .
      sw:end-element ("bs:listOptions") .
      sw:start-element ("dt:producer") .
      sw:start-element ("dt:enterprise") .
      sw:write-data-element ("bs:guid", v-prod-guid) .
      sw:end-element ("dt:enterprise") .  
      sw:end-element ("dt:producer") .
      sw:end-element ("ws:getProductItemListRequest") .
      sw:end-element ("se:Body") .
    
      sw:end-element ("se:Envelope") .
      sw:end-document () .
    
      if trim(v-proxy-addres) <> "" and v-proxy-addres <> ?
        then 
      do :
        if v-proxy-ssl
          then 
        do :
          cmd = substitute ("&1 -k --proxy-negotiate -x &7 -U : -u &4:&5 -d @&2 &6/platform/services/2.1/ProductService >&3",
            search ("exe/curl.exe"), search (v-file-gds), "ItemList_.xml", v-login, v-password, v-server, v-proxy-addres).
        end.
        else 
        do :
          cmd = substitute ("&1 -x &7 -U &8:&9 -u &4:&5 -d @&2 &6/platform/services/2.1/ProductService >&3",
            search ("exe/curl.exe"), search (v-file-gds), "ItemList_.xml", v-login, v-password, v-server, v-proxy-addres, v-proxy-login, v-proxy-pswd).
        end.
      end.
      else 
      do :
        cmd = substitute ("&1 -u &4:&5 -d @&2 &6/platform/services/2.1/ProductService >&3", search ("exe/curl.exe"), search (v-file-gds), "ItemList_.xml", v-login, v-password, v-server).
      end.
      os-command silent value (cmd).
    end.
    
    delete object gdsMercObj no-error .
    delete object gdsmercstrObj no-error .
    delete object gdsMercsubsObj no-error .
  end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-mark Dialog-Frame
ON choose OF b-mark IN FRAME Dialog-Frame /* * */
  do:
    
    run proc-b-mark in this-procedure no-error.

  end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-prod
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-prod Dialog-Frame
ON choose OF b-prod IN FRAME Dialog-Frame
  do:
    os-delete value( search("ItemList_.xml")) no-error .
    run sel-prod in this-procedure .
    assign
      rs-sort
      .
    run refresh-query in this-procedure.   
  end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-alt-units
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-alt-units Dialog-Frame
on choose of b-alt-units in frame Dialog-Frame
do:
define variable v-ret-unit-name  as character no-undo .
define variable v-ret-unit-coeff as decimal no-undo .  
  if not available tt-gds then return no-apply .
  
  run ref\alt-units.w (input parparentproc,
                       input (if v-cntxt-db-num = 0 then {&update} else {&lookup}),
                       input tt-gds.gds-code,
                       input "", /* ограничение списка выбора */
                       output v-ret-unit-name,
                       output v-ret-unit-coeff) . 
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel-all
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel-all Dialog-Frame
ON choose OF b-sel-all IN FRAME Dialog-Frame /* + */
  do:
    assign 
      select-list = "".
    if not available tt-gds then return.
    for each tt-gds no-lock :
      { gbl/markstrn.i tt-gds select-list }
    end.
    {&browse-name}:refresh() in frame {&frame-name} .
  end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-spisok
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-spisok Dialog-Frame
ON choose OF b-spisok IN FRAME Dialog-Frame /* Товары */
  do:
    run sel-goods in this-procedure .
    assign
      rs-sort
      .
      
    run refresh-query in this-procedure.   
  end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-unmark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-unmark Dialog-Frame
ON choose OF b-unmark IN FRAME Dialog-Frame /* - */
  do:
    if not available tt-gds then return.
    select-list  = "".
    {&browse-name}:refresh() in frame {&frame-name} .
  end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-update
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-update Dialog-Frame
ON choose OF b-update IN FRAME Dialog-Frame /* Изменить */
  do:
    if not available tt-gds then 
    do:
      message "Не выбран товар" view-as alert-box.
      return no-apply.
    end.
    v-rid = recid(tt-gds) .
    find first ub.goods-attr no-lock where ub.goods-attr.attr-code = {&attr-mercur_FGIS}
      and ub.goods-attr.attr-value = "yes" and ub.goods-attr.gds-code = tt-gds.gds-code no-error .
    if not available (ub.goods-attr) then 
    do:
      message
        "У товара нет атрибута - 'Является подконтрольным ФГИС Меркурий'"
        view-as alert-box.
      return no-apply .
    end. 
    run ref/merq-gds.w (
      parparentproc
      ,input-output tt-gds.gds-code
      ,input {&update}
      ) no-error .

    run fill-tt .
    run refresh-query in this-procedure.
      
  /*    reposition br-goods to recid v-rid .*/

  end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL guid_ Dialog-Frame
ON value-changed OF guid_ IN FRAME Dialog-Frame /* GUID */
  DO:
    assign guid_ .
    run fill-tt .
    run refresh-query in this-procedure.
  
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME m_item_import
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_item_import Dialog-Frame
ON choose OF MENU-ITEM m_item_import /* Импорт товаров */
  do:
    define variable jj as integer no-undo .
    v-select-list = "" .
    run ref/merq-import.w (parparentproc, 
      output v-select-list) no-error .
    if v-select-list <> "" then 
    do:
      assign 
        r-type = 2 .
      run ini_enable .
      run fill-tt .
      run refresh-query in this-procedure.
    end.
  end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_item_send
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_item_send Dialog-Frame
ON choose OF MENU-ITEM m_item_send /* Передача данных в УБД */
  do:
    for each ub.gds-mercury exclusive-lock:
      run str/callnews.p
        (input {&table_gds-mercury}
        ,input (buffer ub.gds-mercury:handle)
        ) no-error .

      if error-status :error then 
      do:
        message
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box.
        return no-apply.
      end.
    end. 
    message "Передача данных в УБД - выполнена"
      view-as alert-box. 
  end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-type Dialog-Frame
ON value-changed OF r-type IN FRAME Dialog-Frame
  do:
    assign
      v-prod:SCREEN-VALUE      = "" 
      v-prod-name:SCREEN-VALUE = ""
      .
    assign
      r-type
      .
      
    run ini_enable.
    for each tt-gds:
      delete tt-gds .
    end.  
    run refresh-query in this-procedure.
  end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rs-sort
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-sort Dialog-Frame
ON value-changed OF rs-sort IN FRAME Dialog-Frame
  do:
    assign
      rs-sort
      .
    run refresh-query in this-procedure.
  end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-goods
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
if valid-handle(active-window) and frame {&FRAME-NAME}:PARENT eq ?
  then frame {&FRAME-NAME}:PARENT = active-window.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
do on error   undo MAIN-BLOCK, leave MAIN-BLOCK
  on end-key undo MAIN-BLOCK, leave MAIN-BLOCK: 
  { gbl/diasize.i &browse-name=br-goods }
  run diasize_init in this-procedure .
  run enable_UI.
  run ini_enable.
  wait-for go of frame {&FRAME-NAME}.
end.
run disable_UI.

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
  DISPLAY r-type rs-sort guid_ 
    WITH FRAME Dialog-Frame.
  ENABLE b-cancel b-load b-lkp b-update b-del b-connect b-alt-units b-import 
    r-type b-mark b-sel-all b-unmark rs-sort guid_ br-goods 
    WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-tt Dialog-Frame 
PROCEDURE fill-tt :
  /* -----------------------------------------------------------
            Purpose:
            Parameters:  <none>
            Notes:
          -------------------------------------------------------------*/
  define buffer buf_goods       for ub.goods .
  define buffer buf_goods-attr  for ub.goods-attr .
  define buffer buf_gds-mercury for ub.gds-mercury .
  define variable ii             as integer no-undo .
  define variable i              as integer no-undo .
  define variable jj             as integer no-undo .
  define variable gdsMercsubsObj as class   gdsmercsubs.
  define variable gdsmercstrObj  as class   gdsmercstr.

  /*получение, создание, апдейте справочника товаров всд*/
  gdsMercsubsObj = new gdsmercsubs ().
  gdsmercstrObj = new gdsmercstr ().
  
  for each tt-gds:
    delete tt-gds .
  end .  

  case r-type :
    when 1 then
      do:
        ii = 0 .
        if v-prod <> "" then
        do:
          /*Товары по выбранному производителю*/
          /*          for each buf_goods-attr no-lock where buf_goods-attr.attr-code = {&attr-mercur_FGIS}*/
          /*            and buf_goods-attr.attr-value = "yes",                                            */
          for each buf_goods no-lock where buf_goods.prod-code = INTEGER (entry(2,v-prod)) and buf_goods.prod-type = ENTRY (1,v-prod) and buf_goods.stts = 0:
            ii = ii + 1.

            gdsMercsubsObj = gdsmercstrObj:getgdsmercs(buf_goods.gds-code).

            if valid-object (gdsMercsubsObj:GdsMercsubsCurr) then
            do:
              if (guid_ <> "" and gdsMercsubsObj:GdsMercsubsCurr:GUID_ begins guid_) or guid_ = "" then 
              do:
                create tt-gds .
                do i = 1 to gdsMercsubsObj:GetItem (i):
                  find first tt-gds-units no-lock where tt-gds-units.GUID_ = gdsMercsubsObj:GdsMercsubsCurr:GUID_ no-error .
                  if available (tt-gds-units) then tt-gds.units = tt-gds-units.units .
                  tt-gds.ID           = ii .
                  tt-gds.gds-code     = gdsMercsubsObj:GdsMercsubsCurr:GdsCode .
                  tt-gds.prod-type    = gdsMercsubsObj:GdsMercsubsCurr:ProdType .
                  tt-gds.db-num       = gdsMercsubsObj:GdsMercsubsCurr:DBNum .
                  tt-gds.gds-name     = buf_goods.gds-name .
                  tt-gds.units-th     = buf_goods.unit-base .
                  tt-gds.merc-name    = gdsMercsubsObj:GdsMercsubsCurr:MercName .
                  tt-gds.cr-date      = gdsMercsubsObj:GdsMercsubsCurr:DateCr .
                  tt-gds.update-date  = gdsMercsubsObj:GdsMercsubsCurr:DateUpdate .
                  tt-gds.GUID-type    = gdsMercsubsObj:GdsMercsubsCurr:GUIDType .
                  tt-gds.GUID-subtype = gdsMercsubsObj:GdsMercsubsCurr:GUIDSubType .
                  tt-gds.GUID         = gdsMercsubsObj:GdsMercsubsCurr:GUID_ .
                  tt-gds.UUID         = gdsMercsubsObj:GdsMercsubsCurr:UUID .
                end.
              end.
            end.
            else 
            do:
              if guid_ = "" then 
              do:
                create tt-gds .
                tt-gds.ID = ii .
                tt-gds.gds-code   = buf_goods.gds-code .
                tt-gds.gds-name   = buf_goods.gds-name .
                tt-gds.units-th   = buf_goods.unit-base .
              end.
            end.
          end.
        end.
      end.
    when 2 then 
      do:
        if select-list <> "" then 
        do:
          select-list = trim (select-list) no-error .
          do jj = 1 to num-entries (select-list):
            v-list = (entry(jj, select-list)) no-error.
            for first tt-gds exclusive-lock where recid(tt-gds) = integer(v-list):
              for each buf_goods no-lock where buf_goods.gds-code = integer(entry(jj,v-list))
                /*                first buf_goods-attr no-lock where buf_goods-attr.attr-code = {&attr-mercur_FGIS}     */
                /*                and buf_goods-attr.attr-value = "yes" and buf_goods-attr.gds-code = buf_goods.gds-code*/
                :
                gdsMercsubsObj = gdsmercstrObj:getgdsmercs(buf_goods.gds-code).

                if valid-object (gdsMercsubsObj:GdsMercsubsCurr) then
                do:
                  do i = 1 to gdsMercsubsObj:GetItem (i):
                    if (guid_ <> "" and gdsMercsubsObj:GdsMercsubsCurr:GUID_ begins guid_) or guid_ = "" then 
                    do:
                      find first tt-gds-units no-lock where tt-gds-units.GUID_ = gdsMercsubsObj:GdsMercsubsCurr:GUID_ and tt-gds-units.GUID_ begins guid_ no-error .
                      if available (tt-gds-units) then tt-gds.units = tt-gds-units.units .
                      tt-gds.prod-type    = gdsMercsubsObj:GdsMercsubsCurr:ProdType .
                      tt-gds.db-num       = gdsMercsubsObj:GdsMercsubsCurr:DBNum .
                      tt-gds.gds-name     = buf_goods.gds-name .
                      tt-gds.units-th     = buf_goods.unit-base .
                      tt-gds.merc-name    = gdsMercsubsObj:GdsMercsubsCurr:MercName .
                      tt-gds.cr-date      = gdsMercsubsObj:GdsMercsubsCurr:DateCr .
                      tt-gds.update-date  = gdsMercsubsObj:GdsMercsubsCurr:DateUpdate .
                      tt-gds.GUID-type    = gdsMercsubsObj:GdsMercsubsCurr:GUIDType .
                      tt-gds.GUID-subtype = gdsMercsubsObj:GdsMercsubsCurr:GUIDSubType .
                      tt-gds.GUID         = gdsMercsubsObj:GdsMercsubsCurr:GUID_ .
                      tt-gds.UUID         = gdsMercsubsObj:GdsMercsubsCurr:UUID .
                    end.
                  end.
                end.
                else 
                do:
                  if guid_ = "" then 
                  do:
                    tt-gds.gds-code   = buf_goods.gds-code .
                    tt-gds.gds-name   = buf_goods.gds-name .
                    tt-gds.units-th   = buf_goods.unit-base .
                  end.
                end.
              end.
            end.
          end.
        end.
        if v-select-list <> "" then 
        do:
          v-select-list = trim (v-select-list) no-error .
          do jj = 1 to num-entries (v-select-list):
            for each buf_goods no-lock where buf_goods.gds-code = integer(entry(jj,v-select-list)):
              /*              first buf_goods-attr no-lock where buf_goods-attr.attr-code = {&attr-mercur_FGIS}      */
              /*              and buf_goods-attr.attr-value = "yes" and buf_goods-attr.gds-code = buf_goods.gds-code:*/
              gdsMercsubsObj = gdsmercstrObj:getgdsmercs(buf_goods.gds-code).

              if valid-object (gdsMercsubsObj:GdsMercsubsCurr) then
              do:
                do i = 1 to gdsMercsubsObj:GetItem (i):
                  if (guid_ <> "" and gdsMercsubsObj:GdsMercsubsCurr:GUID_ begins guid_) or guid_ = "" then 
                  do:
                    create tt-gds .
                    find first tt-gds-units no-lock where tt-gds-units.GUID_ = gdsMercsubsObj:GdsMercsubsCurr:GUID_ and tt-gds-units.GUID_ begins guid_ no-error .
                    if available (tt-gds-units) then tt-gds.units = tt-gds-units.units .
                    tt-gds.ID           = jj .
                    tt-gds.gds-code     = gdsMercsubsObj:GdsMercsubsCurr:GdsCode .
                    tt-gds.prod-type    = gdsMercsubsObj:GdsMercsubsCurr:ProdType .
                    tt-gds.db-num       = gdsMercsubsObj:GdsMercsubsCurr:DBNum .
                    tt-gds.gds-name     = buf_goods.gds-name .
                    tt-gds.units-th     = buf_goods.unit-base .
                    tt-gds.merc-name    = gdsMercsubsObj:GdsMercsubsCurr:MercName .
                    tt-gds.cr-date      = gdsMercsubsObj:GdsMercsubsCurr:DateCr .
                    tt-gds.update-date  = gdsMercsubsObj:GdsMercsubsCurr:DateUpdate .
                    tt-gds.GUID-type    = gdsMercsubsObj:GdsMercsubsCurr:GUIDType .
                    tt-gds.GUID-subtype = gdsMercsubsObj:GdsMercsubsCurr:GUIDSubType .
                    tt-gds.GUID         = gdsMercsubsObj:GdsMercsubsCurr:GUID_ .
                    tt-gds.UUID         = gdsMercsubsObj:GdsMercsubsCurr:UUID .
                  end.
                end.
              end.
              else 
              do:
                if guid_ = "" then 
                do:
                  create tt-gds .
                  tt-gds.ID = jj .
                  tt-gds.gds-code  = buf_goods.gds-code .
                  tt-gds.gds-name = buf_goods.gds-name .
                  tt-gds.units-th     = buf_goods.unit-base .
                end.
              end.
            end.
          end.
        end. 
      end.
  end case .

  delete object gdsMercsubsObj no-error .    
  delete object gdsmercstrObj no-error .
  
  select-list = "" .

end procedure.

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE refresh-query Dialog-Frame
procedure refresh-query :
  /*------------------------------------------------------------------------------
    Purpose:
    Parameters:  <none>
    Notes:
  ------------------------------------------------------------------------------*/
  case rs-sort :
    when 1 then 
      do:
        open query {&browse-name} for each tt-gds where tt-gds.uuid <> ""
          by tt-gds.gds-code indexed-reposition .
      end.
    when 2 then 
      do:
        open query {&browse-name} for each tt-gds where tt-gds.uuid = ""
          by tt-gds.gds-code indexed-reposition .
      end.
    otherwise 
    do:
      open query {&browse-name} for each tt-gds
        by tt-gds.gds-code indexed-reposition .
    end.
  end case.
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-mark Dialog-Frame 
PROCEDURE local-mark :
  /* -----------------------------------------------------------
            Purpose:
            Parameters:  <none>
            Notes:
          -------------------------------------------------------------*/
  
  if not available tt-gds then 
  do:
    message "Неправильный выбор строки.".
    return no-apply.
  end.
  { gbl/markstrn.i tt-gds select-list }

  {&browse-name}:refresh() in frame {&frame-name} .

end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-mark Dialog-Frame 
PROCEDURE proc-b-mark :
  /* -----------------------------------------------------------
            Purpose:
            Parameters:  <none>
            Notes:
          -------------------------------------------------------------*/
  define variable varlog as logical no-undo .
  if not available tt-gds then return.
  run local-mark in this-procedure.
  assign 
    varlog = {&browse-name} :select-next-row( ) in frame {&frame-name}.
  apply "ENTRY":U to {&browse-name} in frame {&frame-name}.
  {&browse-name}:refresh() in frame {&frame-name} .

end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE sel-goods Dialog-Frame 
PROCEDURE sel-goods :
  v-select-list = "" .
  run str/gds-list.w (
    input parparentproc
    , input v-cntxt-host-code-obj
    , input v-cntxt-obj-type
    , input v-cntxt-obj-code) no-error.

  for each gds-list no-lock:
    v-select-list = v-select-list + "," + string(gds-list.gds-code) no-error.
  end.
  if v-select-list <> "" then 
  do:
    v-select-list = trim (v-select-list) no-error.
    run fill-tt.
    run refresh-query in this-procedure .  
    apply "value-changed" to br-goods in frame Dialog-Frame .
  end .
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE sel-prod Dialog-Frame 
PROCEDURE sel-prod :
  assign
    ref-list = "":U
    .
  run ref/cli-all.w (
    input parparentproc
    ,  input "b-sel"
    ,  input {&all}
    ,  input {&all}
    ,  input {&current}
    ,  input ?
    ,  input ",,,,,,NO,,,"
    ,  input ?
    , output ref-list
    ) .
  if ref-list = "":U then 
  do:       
    run enable_UI in this-procedure.
    return no-apply.
  end.
  find first buf_clients no-lock where recid(buf_clients) = integer(ref-list) no-error. 
  if available buf_clients then 
  do :
    assign
      v-prod      = buf_clients.obj-type + "," + string(buf_clients.obj-code)
      v-prod-name = buf_clients.obj-name
      . 
  end.     
  display v-prod v-prod-name with frame Dialog-Frame.
  run fill-tt.
  run refresh-query in this-procedure .  
  apply "value-changed" to br-goods in frame Dialog-Frame .
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ini_enable Dialog-Frame  _DEFAULT-ENABLE
procedure ini_enable :
  case r-type :
    when 1 then 
      do:
        enable 
          v-prod
          v-prod-name
          b-prod
          b-connect 
          with frame {&frame-name}.
        hide
          b-spisok
          in frame {&frame-name} .
        disable
          b-mark
          b-sel-all
          b-unmark
          with frame {&frame-name} .           
      end.
    when 2 then 
      do:
        hide
          v-prod
          v-prod-name
          b-prod
          in frame {&frame-name}.
        enable
          b-spisok
          b-mark
          b-sel-all
          b-unmark
          with frame {&frame-name} .
        disable
          b-connect

          with frame {&frame-name} .  
      end.
  end case .
  if v-cntxt-db-num <> 0 then 
  do:
    disable
      b-update
      b-connect
      b-import
      b-del
      b-load
      with frame {&frame-name} .        
  end.
  else 
  do:
    SECURITY-POLICY:SYMMETRIC-ENCRYPTION-KEY = GENERATE-PBE-KEY("sysadm").
    
    { gbl/getsect.i run v-cntxt-obj-type v-cntxt-obj-code {&attr-mercur} }

    for each thbjattr_thbj-attr :
      case thbjattr_thbj-attr.prop-code : 
        when "login" then 
          v-login = thbjattr_thbj-attr.property-value-character .
        when "password" then 
          v-password = thbjattr_thbj-attr.property-value-character .
        when "server" then 
          do:
            case thbjattr_thbj-attr.property-value-integer :
              when 1 then 
                do:
                  v-server = "https://api2.vetrf.ru:8002" .
                end.
              when 2 then 
                do:
                  v-server = "https://api.vetrf.ru" .
                end.    
            end case .  
          end.
        when "proxy-addres" then 
          v-proxy-addres = thbjattr_thbj-attr.property-value-character .
        when "proxy-login" then
          do:
            if thbjattr_thbj-attr.property-value-character <> ""
              then 
            do :
              {gbl/pdecrypt.i thbjattr_thbj-attr.property-value-character v-proxy-login no-error}
            end.
          end. 
        when "proxy-pswd" then
          do:
            if thbjattr_thbj-attr.property-value-character <> ""
              then 
            do :
              {gbl/pdecrypt.i thbjattr_thbj-attr.property-value-character v-proxy-pswd no-error}
            end.  
          end. 
        when "proxy-ssl" then 
          v-proxy-ssl = thbjattr_thbj-attr.property-value-logical .           
      end case.
    end.
    
  end.  
end procedure.
  /* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME