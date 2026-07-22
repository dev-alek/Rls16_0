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

Редактирование объектной секции настроек «Сервер авторизации АСУ

Автор: Харитонов Владимир Александрович
Дата создания: 14/01/14
Author: Kharitonov Vladimir
Creation date: 14/01/14

*/

DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
DEFINE INPUT PARAMETER p-mode AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-obj-type LIKE ub.clients.obj-type NO-UNDO.
DEFINE INPUT PARAMETER p-obj-code LIKE ub.shop.obj-code NO-UNDO.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Редактирование объектной секции настроек «Сервер авторизации АСУ".

{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/thbjattr.i }
{ cmp/showinf.i  }
{ gbl/getcntxt.i DEF }
{ gbl/getcntxt.i GET }

define buffer buf_sel-client for ub.clients. /* буфер для выбранного контрагента */

define temp-table temp-thbj-attr no-undo like ub.thbj-attr.

define variable v-tth as handle no-undo .

v-tth = buffer temp-thbj-attr:table-handle.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit b-quit fi-cli-text 
&Scoped-Define DISPLAYED-OBJECTS fi-cli-text fi-cli-adr 

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

DEFINE BUTTON b-quit AUTO-END-KEY 
     LABEL "&Отмена" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-sel-cli 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "" 
     SIZE 3 BY 1 TOOLTIP "Выбор из списка объектов".

DEFINE VARIABLE fi-cli-adr AS CHARACTER FORMAT "X(256)":U 
     LABEL "Адрес сервера авторизации" 
     VIEW-AS FILL-IN 
     SIZE 37 BY 1 NO-UNDO.

DEFINE VARIABLE fi-cli-text AS CHARACTER FORMAT "X(20)":U 
     LABEL "Код контрагента РКО обязательного к авторизации" 
     VIEW-AS FILL-IN 
     SIZE 12.4 BY 1 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1 WIDGET-ID 10
     b-quit AT ROW 1 COL 11 WIDGET-ID 12
     fi-cli-text AT ROW 2.19 COL 1.6 WIDGET-ID 2
     b-sel-cli AT ROW 2.19 COL 63 WIDGET-ID 6
     fi-cli-adr AT ROW 3.38 COL 1.6 WIDGET-ID 8
     SPACE(0.40) SKIP(0.37)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Сервер авторизации АСУ" WIDGET-ID 100.


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
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR BUTTON b-sel-cli IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN fi-cli-adr IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN fi-cli-text IN FRAME Dialog-Frame
   ALIGN-L                                                              */
ASSIGN 
       fi-cli-text:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Сервер авторизации АСУ */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-quit Dialog-Frame
ON CHOOSE OF b-quit IN FRAME Dialog-Frame /* Отмена */
DO:
    /*  */

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel-cli
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel-cli Dialog-Frame
ON CHOOSE OF b-sel-cli IN FRAME Dialog-Frame
DO:
    /* выбираем контрагента */
    define variable v-cli-type as character no-undo.
    define variable v-cli-code as integer no-undo.
    
    run str/clisel.p(parparentproc, input-output v-cli-type, input-output v-cli-code) no-error.
    if error-status:error then
        return no-apply.
    
    find first buf_sel-client no-lock
        where buf_sel-client.obj-type = v-cli-type
        and buf_sel-client.obj-code = v-cli-code.
    
    fi-cli-text = subst("&1 &2", v-cli-type, v-cli-code).
    display fi-cli-text with frame {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


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
  RUN enable_UI.
  run my-enable.
  run proc-load.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
  run proc-save.
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
  DISPLAY fi-cli-text fi-cli-adr 
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit fi-cli-text 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-enable Dialog-Frame 
PROCEDURE my-enable :
/*  */
    if p-mode = {&update} then do:
        enable fi-cli-adr b-sel-cli with frame {&FRAME-NAME}.
    end.
    else do:
        hide B-exit in frame {&FRAME-NAME}.
    end.
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-load Dialog-Frame 
PROCEDURE proc-load :
    /*  */
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
                , input {&attr-srv-auth-ASU}
                , input "":U
                , output v-value-character
                , output v-value-date
                , output v-value-decimal
                , output v-value-integer
                , output v-value-logical
                , output v-param-type
                , INPUT-OUTPUT TABLE-handle v-tth
                ) no-error .
    if error-status:error then do:
        message "Не удалось прочитать настройки"
        view-as alert-box.
        undo, return error.
    end.

    for each temp-thbj-attr:
        if temp-thbj-attr.prop-code = {&attr-srv-auth-ASU_pko-cli} then do:
            find first buf_sel-client no-lock
                where buf_sel-client.obj-type = entry(1, temp-thbj-attr.property-value-character)
                and buf_sel-client.obj-code = int(entry(2, temp-thbj-attr.property-value-character))
                no-error.
            if available buf_sel-client then do:
                fi-cli-text = subst("&1 &2", buf_sel-client.obj-type, buf_sel-client.obj-code).
                display fi-cli-text with frame {&FRAME-NAME}.
            end.
        end.
        if temp-thbj-attr.prop-code = {&attr-srv-auth-ASU_srv-auth-adr} then do:
            fi-cli-adr = temp-thbj-attr.property-value-character.
            display fi-cli-adr with frame {&FRAME-NAME}.
        end.
    end.
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save Dialog-Frame 
PROCEDURE proc-save :
    assign frame {&FRAME-NAME}
        fi-cli-text
        fi-cli-adr
    .
    
    find first temp-thbj-attr where temp-thbj-attr.prop-code = {&attr-srv-auth-ASU_pko-cli}.
    temp-thbj-attr.property-value-character = subst("&1,&2", buf_sel-client.obj-type, buf_sel-client.obj-code).
    
    find first temp-thbj-attr where temp-thbj-attr.prop-code = {&attr-srv-auth-ASU_srv-auth-adr}.
    temp-thbj-attr.property-value-character = fi-cli-adr.
    
    do transaction:
        RUN thbjattr_set-section IN THIS-PROCEDURE (
             input p-obj-type
            ,input p-obj-code
            ,input {&attr-srv-auth-ASU}
            ,INPUT table temp-thbj-attr
        ) NO-ERROR.
        if error-status:error then do:
            message "Не удалось сохранить настройки"
            view-as alert-box.
            undo, return error.
        end.
    end.
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

