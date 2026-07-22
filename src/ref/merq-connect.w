&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
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

Связать товары с Меркурием

Автор: Шкляр Елена  
Дата создания: 10/10/08
Author: Shklyar Elena
Creation date: 10/10/08

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
using ibs.th.str.gds.*.
using ibs.th.str.mercury.*.
using ibs.th.gbl.storage.*.
using ibs.th.bge.mercury.*.

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER p-gds-code AS INTEGER NO-UNDO.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Связать товары с Меркурием".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ str/temp_merq.i}

define variable parser         as class     ParserXMLGds.
define variable gdsMercsubsObj as class     gdsmercsubs.
define variable gdsmercstrObj  as class     gdsmercstr.

define variable choice         as LOGICAL   NO-UNDO .
define VARIABLE Msg            as character no-undo .

define temp-table tt-gds-answer like tt-gds-merq .

define TEMP-TABLE tt-gds-search like tt-gds-answer .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR_GOODS

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-gds-answer

/* Definitions for BROWSE BR_GOODS                                      */
&Scoped-define FIELDS-IN-QUERY-BR_GOODS tt-gds-answer.merc-name tt-gds-answer.GUID_ tt-gds-answer.UUID tt-gds-answer.prod-type tt-gds-answer.update_Date tt-gds-answer.crDate   
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR_GOODS   
&Scoped-define SELF-NAME BR_GOODS
&Scoped-define QUERY-STRING-BR_GOODS FOR EACH tt-gds-answer NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BR_GOODS OPEN QUERY BR_GOODS FOR EACH tt-gds-answer NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BR_GOODS tt-gds-answer
&Scoped-define FIRST-TABLE-IN-QUERY-BR_GOODS tt-gds-answer


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BR_GOODS}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-Help r-search f-search ~
b-search BR_GOODS 
&Scoped-Define DISPLAYED-OBJECTS r-search f-search 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-exit AUTO-GO 
     LABEL "&Ввод" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help 
     LABEL "Помо&щь" 
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-END-KEY 
     LABEL "&Отмена" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-search 
     LABEL "Поиск" 
     SIZE 10 BY 1.

DEFINE VARIABLE f-search AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 43.13 BY 1 NO-UNDO.

DEFINE VARIABLE r-search AS INTEGER INITIAL 1
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS 
          "по наименованию", 1,
"по GUID", 2
     SIZE 38 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR_GOODS FOR 
      tt-gds-answer SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR_GOODS
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR_GOODS Dialog-Frame _FREEFORM
  QUERY BR_GOODS DISPLAY
      tt-gds-answer.merc-name FORMAT "x(20)":U
  tt-gds-answer.GUID_ FORMAT "x(36)":U
  tt-gds-answer.UUID FORMAT "x(36)":U
  tt-gds-answer.prod-type FORMAT ">>99":U
  tt-gds-answer.update_Date FORMAT "99.99.9999":U
  tt-gds-answer.crDate FORMAT "99.99.9999":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH SEPARATORS SIZE 93.5 BY 16.71 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 92.5
     r-search AT ROW 2.17 COL 2 NO-LABEL WIDGET-ID 20
     f-search AT ROW 2.21 COL 39.88 NO-LABEL WIDGET-ID 16
     b-search AT ROW 2.21 COL 83.88 WIDGET-ID 18
     BR_GOODS AT ROW 3.5 COL 1.5 WIDGET-ID 100
     SPACE(0.74) SKIP(0.16)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Связать с товарами из Меркурия"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.


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
/* BROWSE-TAB BR_GOODS b-search Dialog-Frame */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN 
       BR_GOODS:COLUMN-RESIZABLE IN FRAME Dialog-Frame       = TRUE.

/* SETTINGS FOR FILL-IN f-search IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR_GOODS
/* Query rebuild information for BROWSE BR_GOODS
     _START_FREEFORM
OPEN QUERY BR_GOODS FOR EACH tt-gds-answer NO-LOCK INDEXED-REPOSITION.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE BR_GOODS */
&ANALYZE-RESUME


/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Связать с товарами из Меркурия */
DO:
    APPLY "END-ERROR":U TO SELF.
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Ввод */
DO:
    RUN proc-save IN THIS-PROCEDURE NO-ERROR.
    IF ERROR-STATUS:error THEN RETURN NO-APPLY.
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-search
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-search Dialog-Frame
ON CHOOSE OF b-search IN FRAME Dialog-Frame /* Поиск */
DO:
    if f-search <> "" then 
    do:

      run find-in-browse in this-procedure (
        input f-search 
        ) no-error.
      if error-status :error then 
      do:
        message
          vss-workfile vss-revision vss-description
          skip 
          "Ошибка поиска."
          skip return-value
          skip error-status :get-message(1)
          skip error-status :get-message(2)
          skip error-status :get-message(3)
          skip error-status :get-message(4)
          skip error-status :get-message(5)
          view-as alert-box error.
        undo, return no-apply.
      end.
    end.
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-search
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-search Dialog-Frame
ON LEAVE OF f-search IN FRAME Dialog-Frame
DO:
    if f-search <> "" then 
    do:
      run tt-fill .
    end.  
    assign f-search .
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-search
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-search Dialog-Frame
ON VALUE-CHANGED OF r-search IN FRAME Dialog-Frame
DO:
  assign r-search .
  f-search:SCREEN-VALUE = "" .
  run tt-fill .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR_GOODS
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame 


/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
  THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/app_help.i }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
  ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  parser = new parserXmlGDS().
  run tt-fill .
  RUN enable_UI IN THIS-PROCEDURE.
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
  DISPLAY r-search f-search 
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Help r-search f-search b-search BR_GOODS 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE find-in-browse Dialog-Frame 
PROCEDURE find-in-browse :
define input parameter p-search as character no-undo . /* строка для поиска по наименованию */
  
  define variable v-search-str  as character no-undo .
  define variable v-is-found    as logical   no-undo .
  define variable v-focused-row as integer   no-undo .
  define variable v-is-name     as logical   no-undo INITIAL no.
  define variable v-is-guid     as logical   no-undo INITIAL no.

  /* буффер для поиска по наименованию */
  define buffer buf_tt-gds-answer      for tt-gds-answer .
  define buffer buf_tt-gds-search-name for tt-gds-search .
  define buffer buf_tt-gds-search-guid for tt-gds-search .
  
  if not available tt-gds-answer then return . /* пустой список */
  
  assign
    v-is-found = false
    .
case r-search:
  when 1 then do:
    FOR EACH buf_tt-gds-answer
      where buf_tt-gds-answer.merc-name begins p-search:
      create buf_tt-gds-search-name .
      BUFFER-COPY buf_tt-gds-answer to buf_tt-gds-search-name .
      v-is-found = true .        
    end.
    if v-is-found then 
    do:
      EMPTY TEMP-TABLE tt-gds-answer .  
      for EACH buf_tt-gds-search-name:
        create buf_tt-gds-answer .
        BUFFER-COPY buf_tt-gds-search-name to buf_tt-gds-answer .            
      end. 
    end. 
  end.         
  when 2 then 
  do:
    FOR EACH buf_tt-gds-answer
      where buf_tt-gds-answer.GUID_ begins p-search:
      create buf_tt-gds-search-guid .
      BUFFER-COPY buf_tt-gds-answer to buf_tt-gds-search-guid .
      v-is-found = true .        
    end.
    if v-is-found then 
    do:
      EMPTY TEMP-TABLE tt-gds-answer .
      for EACH buf_tt-gds-search-guid:
        create buf_tt-gds-answer .
        BUFFER-COPY buf_tt-gds-search-guid to buf_tt-gds-answer .            
      end.  
    end.
  end.     
  end case.
  
  if not v-is-found then 
  do:
    message substitute("Запись не найдена.") view-as alert-box .
  end . 
   
  OPEN QUERY {&browse-name} FOR EACH tt-gds-answer
    indexed-reposition .
  
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save Dialog-Frame 
PROCEDURE proc-save :
define variable gdsMercsubsObj  as class   gdsmercsubs.
  define variable GuidMercsubsObj as class   gdsmercsubs.
  define variable gdsMercObj      as class   gdsmercsub.
  define variable gdsmercstrObj   as class   gdsmercstr.
  define VARIABLE ii              as integer no-undo .
  
  /*получение, создание, апдейте справочника товаров всд*/
  gdsMercsubsObj = new gdsmercsubs ().
  gdsmercstrObj = new gdsmercstr ().
  
  gdsMercObj = new gdsmercsub().

  gdsMercsubsObj = gdsmercstrObj:getgdsmercs(p-gds-code).

  if VALID-OBJECT (gdsMercsubsObj:GdsMercsubsCurr) then 
  do:
    do ii = 1 to gdsMercsubsObj:GetItem (ii): 
      gdsMercObj = gdsMercsubsObj:GdsMercsubsCurr. /* выдернула конкретны объект*/
    end.            
    GuidMercsubsObj = gdsmercstrObj:getguidmercs(tt-gds-answer.GUID_). /*исправить на GUID*/
    if VALID-OBJECT (GuidMercsubsObj:GdsMercsubsCurr) then 
    do:
/*      message                                                   */
/*        "Уже есть товар с таким GUID, продолжить?"              */
/*        view-as alert-box QUestion buttons yes-no update choice.*/
/*      if not choice then                                        */
/*      do:                                                       */
/*        RETURN NO-APPLY .                                       */
/*      end.                                                      */
      message
        "Товар с таким GUID уже есть"
        view-as alert-box.
        RETURN NO-APPLY .
    end.  
    assign
      gdsMercObj:MercName    = tt-gds-answer.merc-name
      gdsMercObj:UUID        = tt-gds-answer.UUID
      gdsMercObj:GUID_       = tt-gds-answer.GUID_
      gdsMercObj:DateCr      = tt-gds-answer.crDate
      gdsMercObj:DateUpdate  = tt-gds-answer.update_Date
      gdsMercObj:ProdType    = STRING (tt-gds-answer.prod-type)
      gdsMercObj:GUIDType    = tt-gds-answer.GUID-type
      gdsMercObj:GUIDSubType = tt-gds-answer.GUID-subtype
      .
    gdsmercstrObj:updateDB(gdsMercObj). /*измение записи в бд */
  end.

  else 
  do:  
    GuidMercsubsObj = gdsmercstrObj:getguidmercs(tt-gds-answer.GUID_). /*исправить на GUID*/
    if VALID-OBJECT (GuidMercsubsObj:GdsMercsubsCurr) then 
    do:
/*      message                                                   */
/*        "Уже есть товар с таким GUID, продолжить?"              */
/*        view-as alert-box QUestion buttons yes-no update choice.*/
/*      if not choice then                                        */
/*      do:                                                       */
/*        RETURN NO-APPLY .                                       */
/*      end.                                                      */
      message
        "Товар с таким GUID уже есть"
        view-as alert-box.
        RETURN NO-APPLY .
    end.

    gdsMercObj = new gdsmercsub().
    assign
      gdsMercObj:MercName    = tt-gds-answer.merc-name
      gdsMercObj:UUID        = tt-gds-answer.UUID
      gdsMercObj:GUID_       = tt-gds-answer.GUID_
      gdsMercObj:DateCr      = tt-gds-answer.crDate
      gdsMercObj:DateUpdate  = tt-gds-answer.update_Date
      gdsMercObj:ProdType    = STRING (tt-gds-answer.prod-type)
      gdsMercObj:GUIDType    = tt-gds-answer.GUID-type
      gdsMercObj:GUIDSubType = tt-gds-answer.GUID-subtype
      gdsMercObj:GdsCode     = p-gds-code
      .
    /*добавление записис в БД*/
    
    gdsmercstrObj:insertDB(gdsMercObj).
  end.
  delete object gdsMercObj no-error .
  delete object gdsmercstrObj no-error .
  delete object gdsMercsubsObj no-error .
              
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE tt-fill Dialog-Frame 
PROCEDURE tt-fill :
parser:ParseResponse
    (search("ItemList_.xml")
    ,input-output TABLE tt-gds-answer
    ,output Msg) no-error.
  if msg <> "" then 
  do:
    MESSAGE Msg
      VIEW-AS ALERT-BOX.
  end.  
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

