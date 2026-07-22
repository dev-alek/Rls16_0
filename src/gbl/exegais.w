&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
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

Редактирование секции параметры для обмена с ЕГАИС

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
define variable vss-description as character no-undo init "Редактирование секции параметры для обмена с ЕГАИС" .
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ gbl/thbjattr.i }
{ gbl/onewin.i   }

define temp-table temp-thbj-attr no-undo like ub.thbj-attr.
define buffer buf_ext-system for ub.ext-system.

define buffer buf_temp_onewin_itemsSelected for temp_onewin_itemsSelected.

define variable v-tth     as handle no-undo .

define variable v-tth-host as handle no-undo .
define variable v-to-create-host as logical no-undo.
define variable str-attr as character no-undo .

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

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit RECT-1 B-quit B-Help 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */
&Scoped-define List-2 B-egais-exsys f-egais-exsys 

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-egais-exsys 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1" 
     SIZE 4 BY 1.

DEFINE BUTTON B-exit AUTO-GO 
     LABEL "&Ввод" 
     SIZE 10 BY 1.

DEFINE BUTTON B-Help 
     LABEL "&Help" 
     SIZE 10 BY 1.

DEFINE BUTTON B-quit AUTO-END-KEY 
     LABEL "&Отмена" 
     SIZE 10 BY 1.

DEFINE VARIABLE f-egais-exsys AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN NATIVE 
     SIZE 49.5 BY 1
     FGCOLOR 3  NO-UNDO.

DEFINE VARIABLE v-egais-exsys AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 0 
     LABEL "Код ВС для обмена" 
     VIEW-AS FILL-IN 
     SIZE 9 BY 1 TOOLTIP "Код внешней системы, используемой для обмена" NO-UNDO.

DEFINE VARIABLE v-egais-fsrar AS CHARACTER FORMAT "X(256)":U 
     LABEL "Код ФСРАР" 
     VIEW-AS FILL-IN 
     SIZE 64.88 BY 1 NO-UNDO.

DEFINE VARIABLE v-egais-inn AS CHARACTER FORMAT "X(12)":U 
     LABEL "ИНН объекта" 
     VIEW-AS FILL-IN 
     SIZE 64.88 BY 1 NO-UNDO.

DEFINE VARIABLE v-egais-utm AS CHARACTER FORMAT "X(256)":U 
     LABEL "Адрес УТМ" 
     VIEW-AS FILL-IN 
     SIZE 64.88 BY 1 TOOLTIP "255.255.255.255:65536" NO-UNDO.

DEFINE VARIABLE v-egais-ver-xsd AS CHARACTER FORMAT "X(256)":U 
     LABEL "Версия xsd схем" 
     VIEW-AS COMBO-BOX INNER-LINES 12
     LIST-ITEMS "1","2"
     SIZE 64.88 BY 1 NO-UNDO
     .

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 85 BY 7.5.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     B-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 74.63
     v-egais-fsrar AT ROW 3.13 COL 17.63 COLON-ALIGNED WIDGET-ID 118
     v-egais-utm AT ROW 4.71 COL 17.63 COLON-ALIGNED WIDGET-ID 132
     v-egais-exsys AT ROW 4.75 COL 19.63 COLON-ALIGNED WIDGET-ID 22
     B-egais-exsys AT ROW 4.75 COL 30.75 WIDGET-ID 24
     f-egais-exsys AT ROW 4.75 COL 33 COLON-ALIGNED NO-LABEL WIDGET-ID 128
     v-egais-ver-xsd AT ROW 6.25 COL 17.63 COLON-ALIGNED WIDGET-ID 134
     v-egais-inn AT ROW 7.5 COL 17.63 COLON-ALIGNED WIDGET-ID 136
     "ИНН заполняется только в случае, если ИНН объекта отличается от ИНН фирмы" VIEW-AS TEXT
          SIZE 81.5 BY .67 AT ROW 8.75 COL 3 WIDGET-ID 138
     RECT-1 AT ROW 2.25 COL 1.5 WIDGET-ID 116
     SPACE(0.62) SKIP(0.28)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Настройки для обмена с ЕГАИС"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON B-quit WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR BUTTON B-egais-exsys IN FRAME Dialog-Frame
   NO-ENABLE 2                                                          */
ASSIGN 
       B-egais-exsys:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN f-egais-exsys IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE 2                                               */
ASSIGN 
       f-egais-exsys:HIDDEN IN FRAME Dialog-Frame           = TRUE
       f-egais-exsys:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN v-egais-exsys IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN 
       v-egais-exsys:HIDDEN IN FRAME Dialog-Frame           = TRUE
       v-egais-exsys:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN v-egais-fsrar IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN 
       v-egais-fsrar:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN v-egais-inn IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN 
       v-egais-inn:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN v-egais-utm IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN 
       v-egais-utm:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN v-egais-ver-xsd IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN 
       v-egais-ver-xsd:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Настройки для обмена с ЕГАИС */
DO:
  run save-proc in this-procedure no-error.
  if error-status :error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Настройки для обмена с ЕГАИС */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-egais-exsys
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-egais-exsys Dialog-Frame
ON CHOOSE OF B-egais-exsys IN FRAME Dialog-Frame /* Btn 1 */
DO:
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
define variable v-uniq-key-rec as character no-undo .
define variable v-ok as logical no-undo .

run bge/oxmlexts.p (
      input parparentproc
    , input 2                         /* 2- Единичный выбор - 0. Множественный - 1*/
    , input '' /*p-where-string*/
    , input v-uniq-key-rec        /* То, что уже выбрано (список) */
    , output v-rid-list          /* Список выбранных подсистем ( string( db-num ) + chr(6) + string( esys-id ) )*/
    , output v-ok               /* yes, если выбор был сделан. no - Если был отказ от выбора */
).

    if v-ok then do:
            v-egais-exsys = int(entry(2,v-rid-list,{&delim-key})). 
         find first buf_ext-system no-lock where buf_ext-system.esys-id = v-egais-exsys. 
              if AVAILABLE buf_ext-system then do:
                 v-egais-exsys = buf_ext-system.esys-id.
                 f-egais-exsys = buf_ext-system.esys-name.
                 display v-egais-exsys with frame {&frame-name} .
                 display f-egais-exsys with frame {&frame-name} .
         end.
    end. /*if v-ok then do:*/

end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME v-egais-exsys
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-egais-exsys Dialog-Frame
ON LEAVE OF v-egais-exsys IN FRAME Dialog-Frame /* Код ВС для обмена */
DO:

  find first buf_ext-system where buf_ext-system.esys-id = v-egais-exsys no-lock no-error. 
              if AVAILABLE buf_ext-system then do:
                 f-egais-exsys = buf_ext-system.esys-name.
                 display v-egais-exsys with frame {&frame-name} .
                 display f-egais-exsys with frame {&frame-name} .
         end.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
             
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME v-egais-inn
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-egais-inn Dialog-Frame
ON LEAVE OF v-egais-inn IN FRAME Dialog-Frame /* ИНН объекта */
DO:
  disp 1.
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

  if p-obj-type <> "" then do:
     FRAME {&FRAME-NAME}:TITLE = FRAME {&FRAME-NAME}:TITLE + (if p-obj-type = {&cmp} then " фирма" else " маг") + STRING(p-obj-code) .
  end.
    RUN init-tt.
    RUN enable_UI.
    RUN fill-widgets.

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
        ENABLE B-exit B-quit B-Help RECT-1  
        WITH FRAME Dialog-Frame.
 if p-obj-type = "" then do:
    DISPLAY v-egais-exsys f-egais-exsys 
      WITH FRAME Dialog-Frame.
      if p-mode = {&update} then do:
        ENABLE v-egais-exsys f-egais-exsys b-egais-exsys
        WITH FRAME Dialog-Frame.
        HIDE v-egais-fsrar v-egais-utm v-egais-ver-xsd v-egais-inn
        IN FRAME Dialog-Frame.
      end.  
 end.  
 else do:
   DISPLAY v-egais-fsrar v-egais-utm v-egais-ver-xsd v-egais-inn
      WITH FRAME Dialog-Frame.
      if p-mode = {&update} then do:
        ENABLE v-egais-fsrar v-egais-utm v-egais-ver-xsd v-egais-inn
        WITH FRAME Dialog-Frame.
        HIDE v-egais-exsys f-egais-exsys b-egais-exsys
        IN FRAME Dialog-Frame.
      end.  
 end.  
      
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
  
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

run adm/shattri.p (
    input "init":U
  , input p-obj-type
  , input p-obj-code
  , input {&attr-egais-host}
  , input "":U
  , output v-value-character
  , output v-value-date
  , output v-value-decimal
  , output v-value-integer
  , output v-value-logical
  , output v-param-type
  , input-output TABLE-HANDLE v-tth
  ) no-error .
if error-status:error then do:
  message
  "Не удалось получить начальные значения настроек" skip
  error-status:get-message(1) return-value
  view-as alert-box error .
  undo, return error .
end.

FOR EACH temp-thbj-attr
  :
  if p-obj-type = "" then do:
    IF temp-thbj-attr.prop-code = {&attr-egais-host_egais-exsys} THEN DO:
       find first buf_ext-system no-lock
          where buf_ext-system.esys-id = temp-thbj-attr.property-value-integer 
       no-error.
       if AVAILABLE buf_ext-system then do:
           v-egais-exsys = buf_ext-system.esys-id.
           f-egais-exsys = buf_ext-system.esys-name.
           display v-egais-exsys with frame {&frame-name} .
           display f-egais-exsys with frame {&frame-name} .
       end.
    END.
  end.
  else do:  
    IF temp-thbj-attr.prop-code = {&attr-egais-host_egais-fsrar} THEN DO:
       v-egais-fsrar = temp-thbj-attr.property-value-character.
       display v-egais-fsrar with frame {&frame-name} .
    END.
    IF temp-thbj-attr.prop-code = {&attr-egais-host_egais-utm} THEN DO:
       v-egais-utm = temp-thbj-attr.property-value-character.
       display v-egais-utm with frame {&frame-name} .
    END.
    IF temp-thbj-attr.prop-code = {&attr-egais-host_egais-ver-xsd} THEN DO:
       v-egais-ver-xsd = temp-thbj-attr.property-value-character.
       display v-egais-ver-xsd with frame {&frame-name} .
    END.
    IF temp-thbj-attr.prop-code = {&attr-egais-host_egais-inn} THEN DO:
       v-egais-inn = temp-thbj-attr.property-value-character.
       display v-egais-inn with frame {&frame-name} .
    END.
  end.
END.

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

if p-obj-type = "" then do:
ASSIGN FRAME {&FRAME-NAME}
    v-egais-exsys
    .
    find first temp-thbj-attr where temp-thbj-attr.prop-code = {&attr-egais-host_egais-exsys} .
    temp-thbj-attr.property-value-integer = v-egais-exsys.
    
end.
else do:
ASSIGN FRAME {&FRAME-NAME}
    v-egais-fsrar 
    v-egais-utm
    v-egais-ver-xsd
    v-egais-inn
    .
    find first temp-thbj-attr where temp-thbj-attr.prop-code = {&attr-egais-host_egais-fsrar} .
    temp-thbj-attr.property-value-character = v-egais-fsrar.

    find first temp-thbj-attr where temp-thbj-attr.prop-code = {&attr-egais-host_egais-utm} .
    temp-thbj-attr.property-value-character = v-egais-utm.
    
    find first temp-thbj-attr where temp-thbj-attr.prop-code = {&attr-egais-host_egais-ver-xsd} .
    temp-thbj-attr.property-value-character = v-egais-ver-xsd.
    
    find first temp-thbj-attr where temp-thbj-attr.prop-code = {&attr-egais-host_egais-inn} no-error.
    if not available (temp-thbj-attr) then do:
      create temp-thbj-attr.
      find first buf_temp-thbj-attr.
      buffer-copy buf_temp-thbj-attr except buf_temp-thbj-attr.prop-value-type to temp-thbj-attr.
    end.
    temp-thbj-attr.property-value-character = v-egais-inn.
    

end.  
    
    do transaction:
        RUN thbjattr_set-section IN THIS-PROCEDURE (
             input p-obj-type
            ,input p-obj-code
            ,input {&attr-egais-host}
            ,INPUT table temp-thbj-attr
        ) NO-ERROR.
        if error-status:error then do:
            message "Не удалось сохранить настройки"
            view-as alert-box.
            undo, return error.
        end.
    end.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

