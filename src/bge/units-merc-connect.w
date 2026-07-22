&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v7r11 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME    d-units
&Scoped-define FRAME-NAME     d-units
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS d-units
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Справочник единиц измерения.

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/20/06
Author: Bakhtadze Natalya
Creation date: 03/20/06

Created: 10/21/94 - 11:41 pm

*/

/* ***************************  Definitions  ************************** */

using ibs.th.bge.mercury.*.

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
define output parameter p-guid as character no-undo .

define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Справочник единиц измерения" .
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }
{ gbl/thbjattr.i }
{ gbl/getcntxt.i def }

/* Local Variable Definitions ---                                       */

define variable ri as recid no-undo.
define variable glog as logical no-undo .

define variable v-login        as character no-undo .
define variable v-password     as character no-undo .
define variable v-server       as character no-undo .
define variable cmd            as character no-undo .

define variable v-proxy-login     as character no-undo .
define variable v-proxy-pswd      as character no-undo .
define variable v-proxy-addres    as character no-undo .
define variable v-proxy-ssl       as logical   no-undo .

define variable v-value-character as character no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .
define variable v-value-logical   as logical   no-undo .
define variable v-value-type      as character no-undo .
define variable v-value-date      as date      no-undo .
define variable par-type          as character no-undo.

define temp-table tt-units-merc
  field guid_ as character format "X(38)"
  field uuid_ as character format "X(38)"
  field name1 as character format "X(10)"
  field name2 as character format "X(16)"
  index pi as primary unique
    guid_
.


/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME



/* ********************  Preprocessor Definitions  ******************** */

/* Name of first Frame and/or Browse (alphabetically)                   */
&Scoped-define FRAME-NAME  d-units
&Scoped-define BROWSE-NAME br-units

/* Custom List Definitions                                              */
&Scoped-define LIST-1
&Scoped-define LIST-2
&Scoped-define LIST-3

/* Definitions for BROWSE br-units                                      */

/* Definitions for DIALOG-BOX d-units                                   */

/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */

DEFINE BUTTON b-select
     LABEL "Выбор":L
     SIZE 10 BY 1.

DEFINE BUTTON b-exit AUTO-END-KEY
     LABEL "&Выход ":L
     SIZE 10 BY 1.


/* Query definitions                                                    */
DEFINE QUERY br-units FOR tt-units-merc SCROLLING.

/* Browse definitions                                                   */
DEFINE BROWSE br-units QUERY br-units NO-LOCK DISPLAY
      tt-units-merc.name1 column-label "Аббр."
      tt-units-merc.name2 column-label "Наименование"
      tt-units-merc.guid_ column-label "GUID в ФГИС Меркурий"
      tt-units-merc.uuid_ column-label "UUID в ФГИС Меркурий"
    WITH SEPARATORS
          &IF '{&WINDOW-SYSTEM}' = 'TTY':U &THEN SIZE 69 BY 13
          &ELSE size 106.75 by 12.58 &ENDIF
         .


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME d-units
     br-units at row 2.5 col 3
     b-exit at row 1 col 1
     b-select at row 1 col 11
    WITH VIEW-AS DIALOG-BOX
         SIDE-LABELS THREE-D
         SCROLLABLE size 111.88 by 16.25
         TITLE "Выбор ед. изм. ФГИС Меркурий для связи с TH":L.




/* ***************  Runtime Attributes and UIB Settings  ************** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX d-units
   UNDERLINE                                                            */
ASSIGN
       FRAME d-units:SCROLLABLE       = FALSE.

/* SETTINGS FOR BUTTON b-add-unit IN FRAME d-units
   NO-DISPLAY                                                           */
/* SETTINGS FOR BUTTON b-select IN FRAME d-units
   NO-DISPLAY                                                           */
/* SETTINGS FOR BUTTON b-help IN FRAME d-units
   NO-DISPLAY                                                           */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-units
/* Query rebuild information for BROWSE br-units
     _TblList          = "ub.units"
     _Options          = "NO-LOCK"
     _OrdList          = ""
     _FldNameList[1]   = ub.units.unit-name
     _FldNameList[2]   = ub.units.long-name
     _FldFormatList[2] = "X(30)"
     _FldNameList[3]   = "(IF (ub.units.type = """" ) THEN ("""") ELSE ({&unit-type-name}))"
     _FldLabelList[3]  = "Тип"
     _FldFormatList[3] = "x(30)"
     _Query            is OPENED
*/  /* BROWSE br-units */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */



&Scoped-define SELF-NAME b-connect
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-connect d-units
ON CHOOSE OF b-select IN FRAME d-units /* Выбор */
DO:
  if not available tt-units-merc then return no-apply .
  
  p-guid = tt-units-merc.guid_ .
  
  apply "go" to frame d-units .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit d-units
ON CHOOSE OF b-exit IN FRAME d-units /* Выбор */
DO:
  p-guid = "" .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK d-units


/* ***************************  Main Block  *************************** */

/* Restore the current-window if it is an icon.                         */
/* Otherwise the dialog box will be hidden                              */
IF CURRENT-WINDOW:WINDOW-STATE = WINDOW-MINIMIZED
THEN CURRENT-WINDOW:WINDOW-STATE = WINDOW-NORMAL.


/* Add Trigger to equate WINDOW-CLOSE to END-ERROR                      */
ON WINDOW-CLOSE OF FRAME {&FRAME-NAME} APPLY "END-ERROR":U TO SELF.

/* Now enable the interface and wait for the exit condition.            */
 { gbl/getcntxt.i get }
 
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
  
  run fill-tt .
  
  RUN enable_UI.

  if available units then
      glog = br-units:select-focused-row( ).

do  on endkey undo, leave  on error undo, leave:
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
end.

RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI d-units _DEFAULT-DISABLE
PROCEDURE disable_UI :
/* --------------------------------------------------------------------
  Purpose:     DISABLE the User Interface
  Parameters:  <none>
  Notes:       Here we clean-up the user-interface by deleting
               dynamic widgets we have created and/or hide
               frames.  This procedure is usually called when
               we are ready to "clean-up" after running.
   -------------------------------------------------------------------- */
  /* Hide all frames. */
  HIDE FRAME d-units.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI d-units
PROCEDURE enable_UI :
/* --------------------------------------------------------------------
  Purpose:     ENABLE the User Interface
  Parameters:  <none>
  Notes:       Here we display/view/enable the widgets in the
               user-interface.  In addition, OPEN all queries
               associated with each FRAME and BROWSE.
               These statements here are based on the "Other
               Settings" section of the widget Property Sheets.
   -------------------------------------------------------------------- */
    ENABLE  br-units b-exit
                    b-select  
        WITH FRAME d-units.
        
    OPEN QUERY br-units FOR EACH tt-units-merc NO-LOCK  .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

PROCEDURE fill-tt :
  define variable v-get-units as character no-undo initial "getUnitList_.xml" .
  define variable sw          as handle    no-undo .
  define variable parser      as class     ParserXMLUnits.
  define variable Msg         as character no-undo .
  
  create sax-writer sw .
    
  sw:formatted = true.
  sw:set-output-destination ("file", v-get-units).
  sw:encoding = "UTF-8".

  sw:start-document () .
  sw:start-element ("se:Envelope") .

  sw:insert-attribute ("xmlns:se", "http://schemas.xmlsoap.org/soap/envelope/") .
  sw:insert-attribute ("xmlns:ws", "http://api.vetrf.ru/schema/cdm/registry/ws-definitions/v2") .
  sw:insert-attribute ("xmlns:bs", "http://api.vetrf.ru/schema/cdm/base") .

    sw:start-element ("se:Body") .
      sw:start-element ("ws:getUnitListRequest") .
        sw:start-element ("bs:listOptions") .
        sw:write-data-element ("bs:count", "1000") .
        sw:write-data-element ("bs:offset", "0") .
        sw:end-element ("bs:listOptions") .
      sw:end-element ("ws:getUnitListRequest") .
    sw:end-element ("se:Body") .

  sw:end-element ("se:Envelope") .
  sw:end-document () .


  if trim(v-proxy-addres) <> "" and v-proxy-addres <> ?
  then do :
    if v-proxy-ssl
    then do :
      cmd = substitute ("&1 -k --proxy-negotiate -x &7 -U : -u &4:&5 -d @&2 &6/platform/services/2.1/DictionaryService >&3",
                      search ("exe/curl.exe"), search (v-get-units), "UnitList_.xml", v-login, v-password, v-server, v-proxy-addres).
    end.
    else do :
      cmd = substitute ("&1 -x &7 -U &8:&9 -u &4:&5 -d @&2 &6/platform/services/2.1/DictionaryService >&3",
                      search ("exe/curl.exe"), search (v-get-units), "UnitList_.xml", v-login, v-password, v-server, v-proxy-addres, v-proxy-login, v-proxy-pswd).
    end.
  end.
  else do :
    cmd = substitute ("&1 -u &4:&5 -d @&2 &6/platform/services/2.1/DictionaryService >&3", search ("exe/curl.exe"), search (v-get-units), "UnitList_.xml", v-login, v-password, v-server).
  end.                  
  os-command silent value (cmd). /*закрытие окна*/
  
  parser = new parserXmlUnits().
  parser:ParseResponse
    (search("UnitList_.xml")
    ,input-output TABLE tt-units-merc
    ,output Msg) no-error.
  if Msg <> "" then 
  do:
    message Msg
      view-as alert-box.
  end.  
  
END PROCEDURE.

&UNDEFINE BROWSE-NAME
&UNDEFINE FRAME-NAME
&UNDEFINE WINDOW-NAME