&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
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
DEFINE INPUT        PARAMETER parparentproc AS WIDGET-HANDLE  NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER p-gds-code    AS integer        NO-UNDO.
DEFINE INPUT        PARAMETER p-mode        as character      NO-UNDO.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Связать товары с Меркурием".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/trg-def.i }
{ cmp/showinf.i }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ gbl/thbjattr.i }
{ str/temp_merq.i}
{ str/checkmerq.i}

DEFINE BUFFER buf_gds-mercury for ub.gds-mercury .
DEFINE BUFFER buf_goods       for ub.goods .

define variable v-login           as character no-undo .
define variable v-password        as character no-undo .
define variable v-server          as character no-undo .

define variable v-proxy-login     as character no-undo .
define variable v-proxy-pswd      as character no-undo .
define variable v-proxy-addres    as character no-undo .
define variable v-proxy-ssl       as logical   no-undo .

define variable par-type          as character no-undo.

define variable gdsMercsubsObj    as class     gdsmercsubs.
define variable gdsMercObj        as class     gdsmercsub.
define variable gdsmercstrObj     as class     gdsmercstr.
define variable parser            as class     ParserXMLGds.

define variable v-value-character as character no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .
define variable v-value-logical   as logical   no-undo .
define variable v-value-type      as character no-undo .
define variable v-value-date      as date      no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-Help f-uuid 
&Scoped-Define DISPLAYED-OBJECTS f-gds-name f-merc-name f-guid f-uuid ~
f-prod-type f-guid-type f-guid-subtype 

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

DEFINE BUTTON B-prod-type 
  IMAGE-UP FILE "btn-down-arrow":U
  IMAGE-DOWN FILE "btn-down-arrow":U
  IMAGE-INSENSITIVE FILE "btn-down-arrow":U
  LABEL "" 
  SIZE 3 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY 
  LABEL "&Отмена" 
  SIZE 10 BY 1
  BGCOLOR 8 .

DEFINE VARIABLE f-gds-name     AS CHARACTER FORMAT "X(256)":U 
  LABEL "Наим. товара в ТН" 
  VIEW-AS FILL-IN 
  SIZE 45 BY 1 NO-UNDO.

DEFINE VARIABLE f-guid         AS CHARACTER FORMAT "X(256)":U 
  LABEL "GUID" 
  VIEW-AS FILL-IN 
  SIZE 45 BY 1 NO-UNDO.

DEFINE VARIABLE f-guid-subtype AS CHARACTER FORMAT "X(256)":U 
  LABEL "GUID подгруппы" 
  VIEW-AS FILL-IN 
  SIZE 45 BY 1 NO-UNDO.

DEFINE VARIABLE f-guid-type    AS CHARACTER FORMAT "X(256)":U 
  LABEL "GUID группы" 
  VIEW-AS FILL-IN 
  SIZE 45 BY 1 NO-UNDO.

DEFINE VARIABLE f-merc-name    AS CHARACTER FORMAT "X(256)":U 
  LABEL "Наим. товара" 
  VIEW-AS FILL-IN 
  SIZE 45 BY 1 NO-UNDO.

DEFINE VARIABLE f-prod-type    AS CHARACTER FORMAT "X(256)":U 
  LABEL "Тип продукции" 
  VIEW-AS FILL-IN 
  SIZE 41.75 BY 1 NO-UNDO.

DEFINE VARIABLE f-uuid         AS CHARACTER FORMAT "X(256)":U 
  LABEL "UUID" 
  VIEW-AS FILL-IN 
  SIZE 45 BY 1 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
  B-exit AT ROW 1 COL 1
  b-quit AT ROW 1 COL 11
  B-Help AT ROW 1 COL 68
  f-gds-name AT ROW 2.29 COL 3 WIDGET-ID 24
  f-merc-name AT ROW 3.58 COL 8 WIDGET-ID 34
  f-guid AT ROW 4.92 COL 16 WIDGET-ID 14
  f-uuid AT ROW 6.13 COL 16 WIDGET-ID 22
  f-prod-type AT ROW 7.33 COL 7.13 WIDGET-ID 26
  B-prod-type AT ROW 7.33 COL 64.38 WIDGET-ID 32
  f-guid-type AT ROW 8.54 COL 9.13 WIDGET-ID 28
  f-guid-subtype AT ROW 9.75 COL 6.25 WIDGET-ID 30
  SPACE(4.37) SKIP(0.49)
  WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
  SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
  TITLE "Товары из Меркурия"
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
ASSIGN 
  FRAME Dialog-Frame:SCROLLABLE = FALSE
  FRAME Dialog-Frame:HIDDEN     = TRUE.

/* SETTINGS FOR BUTTON B-prod-type IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN f-gds-name IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN f-guid IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN f-guid-subtype IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN f-guid-type IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN f-merc-name IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN f-prod-type IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN f-uuid IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Товары из Меркурия */
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


&Scoped-define SELF-NAME B-prod-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-prod-type Dialog-Frame
ON CHOOSE OF B-prod-type IN FRAME Dialog-Frame
  DO:

    run bge/merq-ref-tnved.w (parparentproc, {&lookup}, "") no-error.
    
    if RETURN-VALUE = "" then 
    do:
      MESSAGE "Не выбран тип продукции"
        VIEW-AS ALERT-BOX.
      return no-apply.
    end.  
    assign
      f-prod-type    = entry(1,RETURN-VALUE)
      f-guid-type    = entry(3,RETURN-VALUE)
      f-guid-subtype = entry(4,RETURN-VALUE)
      .
    
    DISPLAY
      f-guid-subtype
      f-guid-type
      f-prod-type
      with frame {&frame-name} .
    
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME v-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-guid Dialog-Frame
ON return, MOUSE-SELECT-DBLCLICK OF f-guid IN FRAME {&frame-name} DO:
apply "leave" to f-guid in frame {&frame-name}.
apply "choose" to B-exit in frame {&frame-name}.

END.
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME f-guid
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-guid Dialog-Frame
ON LEAVE OF f-guid IN FRAME Dialog-Frame /* GUID */
  DO:
    define variable Msg as character no-undo .   
    ASSIGN f-guid .
    run checkguid(INPUT-OUTPUT f-guid,OUTPUT Msg) no-error .
    if Msg <> "" then 
    do:
      MESSAGE Msg
        VIEW-AS ALERT-BOX.
      return NO-APPLY .
    end.
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-uuid
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-uuid Dialog-Frame
ON LEAVE OF f-uuid IN FRAME Dialog-Frame /* UUID */
  DO:
  /*    assign f-uuid .*/
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
  RUN Myenable IN THIS-PROCEDURE.
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
  DISPLAY f-gds-name f-merc-name f-guid f-uuid f-prod-type f-guid-type 
    f-guid-subtype 
    WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Help f-uuid 
    WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-tt Dialog-Frame 
PROCEDURE fill-tt :
  define variable ii             as integer no-undo .
  define variable gdsMercsubsObj as class   gdsmercsubs.
  define variable gdsmercstrObj  as class   gdsmercstr.

  
  gdsMercsubsObj = new gdsmercsubs ().
  gdsmercstrObj = new gdsmercstr ().
  
  gdsMercsubsObj = gdsmercstrObj:getgdsmercs(p-gds-code).
  
  if VALID-OBJECT (gdsMercsubsObj:GdsMercsubsCurr) then
  do:
    do ii = 1 to gdsMercsubsObj:GetItem (ii): 
      gdsMercObj = gdsMercsubsObj:GdsMercsubsCurr. /* выдернула конкретны объект*/
      assign
        f-merc-name    = gdsMercObj:MercName    
        f-uuid         = gdsMercObj:UUID
        f-guid         = gdsMercObj:GUID_       
        f-prod-type    = gdsMercObj:ProdType 
        f-guid-type    = gdsMercObj:GUIDType
        f-guid-subtype = gdsMercObj:GUIDSubType
        .
    end.
  end.
  find first buf_goods no-lock where buf_goods.gds-code = p-gds-code no-error .
  if AVAILABLE (buf_goods) then 
  do:
    ASSIGN
      f-gds-name = buf_goods.gds-name
      .
  end.

    
END PROCEDURE.

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI_fill Dialog-Frame 
PROCEDURE enable_UI_fill :
  
  DISPLAY
    f-gds-name
    f-merc-name
    f-guid
    f-guid-subtype
    f-guid-type
    f-prod-type
    f-uuid
    with frame {&frame-name}.
    
    
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame 
PROCEDURE MyEnable :
  if p-mode = {&update} then 
  do:
    enable
      f-guid
      B-prod-type
      B-exit b-quit B-Help
      with frame {&frame-name} .
      
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
            then do :
              {gbl/pdecrypt.i thbjattr_thbj-attr.property-value-character v-proxy-login no-error}
            end.
          end. 
        when "proxy-pswd" then
          do:
            if thbjattr_thbj-attr.property-value-character <> ""
            then do :
              {gbl/pdecrypt.i thbjattr_thbj-attr.property-value-character v-proxy-pswd no-error}
            end.  
          end. 
        when "proxy-ssl" then 
          v-proxy-ssl = thbjattr_thbj-attr.property-value-logical .     
      end case.
    end.
  end.
  else 
  do:
    enable
      B-exit b-quit B-Help
      with frame {&frame-name} .
  end.   
  VIEW FRAME {&frame-name}. 
  run fill-tt .
  run enable_UI_fill .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save Dialog-Frame 
PROCEDURE proc-save :
  define variable ii              as integer   no-undo .
  define variable cmd             as character no-undo .
  define variable sw              as handle    no-undo .
  define variable v-file-gds      as character no-undo initial "getItemList_.xml".
  define variable Msg             as character no-undo .
  define variable choice          as logical   no-undo .
  define variable gdsMercsubsObj  as class     gdsmercsubs.
  define variable gdsmercstrObj   as class     gdsmercstr.
  define variable GuidMercsubsObj as class     gdsmercsubs.
  
  gdsMercsubsObj = new gdsmercsubs ().
  gdsmercstrObj = new gdsmercstr ().
  
  gdsMercsubsObj = gdsmercstrObj:getgdsmercs(p-gds-code).
  
  if p-mode = {&update} then 
  do:
    if f-guid <> "" then 
    do:
      GuidMercsubsObj = gdsmercstrObj:getguidmercs(f-guid). /*исправить на GUID*/
      if VALID-OBJECT (GuidMercsubsObj:GdsMercsubsCurr) then 
      do:
/*        message                                                   */
/*          "Уже есть товар с таким GUID, продолжить?"              */
/*          view-as alert-box QUestion buttons yes-no update choice.*/
/*        if not choice then                                        */
/*        do:                                                       */
/*          RETURN NO-APPLY .                                       */
/*        end.                                                      */

      if GuidMercsubsObj:iCounter >= 1 then do:        
        message
          "Товар с таким GUID уже есть"
          view-as alert-box.
          RETURN NO-APPLY .
        end.
      end.
      /*отправляем запрос*/
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
      sw:write-data-element ("bs:guid", f-guid) .
      sw:end-element ("ws:getProductItemByGuidRequest") .
      sw:end-element ("se:Body") .
    
      sw:end-element ("se:Envelope") .
      sw:end-document () .
    

      
      if trim(v-proxy-addres) <> "" and v-proxy-addres <> ?
      then do :
        if v-proxy-ssl
        then do :
          cmd = substitute ("&1 -k --proxy-negotiate -x &7 -U : -u &4:&5 -d @&2 &6/platform/services/2.1/ProductService >&3",
                          search ("exe/curl.exe"), search (v-file-gds), "ItemList_.xml", v-login, v-password, v-server, v-proxy-addres).
        end.
        else do :
          cmd = substitute ("&1 -x &7 -U &8:&9 -u &4:&5 -d @&2 &6/platform/services/2.1/ProductService >&3",
                          search ("exe/curl.exe"), search (v-file-gds), "ItemList_.xml", v-login, v-password, v-server, v-proxy-addres, v-proxy-login, v-proxy-pswd).
        end.
      end.
      else do :
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
        MESSAGE Msg
          VIEW-AS ALERT-BOX.
      end.          
      if Msg = "" then 
      do:  
        find first tt-gds-merq no-lock no-error .
        if AVAILABLE (tt-gds-merq) then 
        do:
          if VALID-OBJECT (gdsMercsubsObj:GdsMercsubsCurr) then
          do:
            do ii = 1 to gdsMercsubsObj:GetItem (ii): 
              gdsMercObj = gdsMercsubsObj:GdsMercsubsCurr. /* выдернула конкретны объект*/
              assign
                gdsMercObj:MercName    = tt-gds-merq.merc-name
                gdsMercObj:UUID        = tt-gds-merq.UUID
                gdsMercObj:GUID_       = tt-gds-merq.GUID_
                gdsMercObj:ProdType    = STRING (tt-gds-merq.prod-type)
                gdsMercObj:GUIDType    = tt-gds-merq.GUID-type
                gdsMercObj:GUIDSubType = tt-gds-merq.GUID-subtype
                .
            end.
            gdsmercstrObj:updateDB(gdsMercObj). /*измение записи в бд */
          end.
          else 
          do:
            gdsMercObj = new gdsmercsub().
            assign
              gdsMercObj:GdsCode     = p-gds-code
              gdsMercObj:MercName    = tt-gds-merq.merc-name
              gdsMercObj:UUID        = tt-gds-merq.UUID
              gdsMercObj:GUID_       = tt-gds-merq.GUID_
              gdsMercObj:ProdType    = STRING (tt-gds-merq.prod-type)
              gdsMercObj:GUIDType    = tt-gds-merq.GUID-type
              gdsMercObj:GUIDSubType = tt-gds-merq.GUID-subtype
              .
            gdsmercstrObj:insertDB(gdsMercObj).
          end.  
        end. 
      end.
    end.
    if f-guid = "" or Msg <> "" then 
    do:
      
      if VALID-OBJECT (gdsMercsubsObj:GdsMercsubsCurr) then
      do:
        do ii = 1 to gdsMercsubsObj:GetItem (ii): 
          gdsMercObj = gdsMercsubsObj:GdsMercsubsCurr. /* выдернула конкретны объект*/
          assign
            gdsMercObj:MercName    = f-merc-name
            gdsMercObj:UUID        = f-uuid
            gdsMercObj:GUID_       = f-guid
            gdsMercObj:ProdType    = f-prod-type
            gdsMercObj:GUIDType    = f-guid-type
            gdsMercObj:GUIDSubType = f-guid-subtype
            .
        end.
        gdsmercstrObj:updateDB(gdsMercObj). /*измение записи в бд */
      end.
      else 
      do:
        gdsMercObj = new gdsmercsub().
        assign
          gdsMercObj:GdsCode     = p-gds-code
          gdsMercObj:MercName    = f-merc-name
          gdsMercObj:UUID        = f-uuid
          gdsMercObj:GUID_       = f-guid
          gdsMercObj:ProdType    = f-prod-type
          gdsMercObj:GUIDType    = f-guid-type
          gdsMercObj:GUIDSubType = f-guid-subtype
          .
        gdsmercstrObj:insertDB(gdsMercObj).
      end.  
    end.
  end.
  delete object gdsMercObj no-error .
  delete object gdsmercstrObj no-error .
  delete object gdsMercsubsObj no-error .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


