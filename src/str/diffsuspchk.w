&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*------------------------------------------------------------------------

  File: 

  Description: 

  Input Parameters:
      <none>

  Output Parameters:
      <none>

  Author: 

  Created: 
------------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
{ ref/extclass.i }
/* Parameters Definitions ---                                           */
define input parameter parParentProc as Widget-handle no-undo .
define input-output parameter p-doc-rec as recid no-undo .
define output parameter p-susp-chk as character no-undo .
define output parameter p-link-chk as character no-undo .

/* Local Variable Definitions ---                                       */
define buffer buf_reportShift for ub.reportShift .
define buffer buf_report      for ub.reportShift .
define variable v-susp as character no-undo .
{ cmp/str-glbl.i }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-2 b-quit CsuspChk BUTTON-susp ~
v-link-chk 
&Scoped-Define DISPLAYED-OBJECTS CsuspChk v-link-chk 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-quit AUTO-END-KEY 
    LABEL "&Выход" 
    SIZE 10 BY 1 TOOLTIP "Выход"
    BGCOLOR 8 .

DEFINE BUTTON BUTTON-susp 
    IMAGE-DOWN FILE "btn-down-arrow":U
    IMAGE-INSENSITIVE FILE "btn-down-arrow":U
    LABEL "..." 
    SIZE 4.13 BY 1 TOOLTIP "Выбор причин".

DEFINE VARIABLE CsuspChk   AS CHARACTER FORMAT "X(150)":U INITIAL "-1" 
    VIEW-AS COMBO-BOX INNER-LINES 5
    LIST-ITEM-PAIRS "Все",-1
    DROP-DOWN-LIST
    SIZE 87 BY 1 NO-UNDO.

DEFINE VARIABLE v-link-chk AS CHARACTER FORMAT "X(256)":U 
    LABEL "Ссылка на ~"корректный~" чек" 
    VIEW-AS FILL-IN 
    SIZE 44.13 BY 1 NO-UNDO.

DEFINE VARIABLE v-susp-chk AS CHARACTER FORMAT "X(256)":U 
    VIEW-AS FILL-IN 
    SIZE 87 BY 1 NO-UNDO.

DEFINE RECTANGLE RECT-2
    EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
    SIZE 95.5 BY 5.25.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
    b-quit AT ROW 1.25 COL 1.5 WIDGET-ID 24
    CsuspChk AT ROW 3.38 COL 2 COLON-ALIGNED NO-LABEL WIDGET-ID 92
    BUTTON-susp AT ROW 3.42 COL 91.88 WIDGET-ID 88
    v-susp-chk AT ROW 4.88 COL 2 COLON-ALIGNED NO-LABEL WIDGET-ID 42
    v-link-chk AT ROW 6.38 COL 90.01 RIGHT-ALIGNED WIDGET-ID 44
    "  Причина подозрительного чека" VIEW-AS TEXT
    SIZE 32 BY .67 AT ROW 2.29 COL 32.63 WIDGET-ID 38
    RECT-2 AT ROW 2.63 COL 2.5 WIDGET-ID 36
    SPACE(2.12) SKIP(0.61)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
    SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
    TITLE "Параметры по смене" WIDGET-ID 100.


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
    FRAME Dialog-Frame:SCROLLABLE = FALSE
    FRAME Dialog-Frame:HIDDEN     = TRUE.

/* SETTINGS FOR FILL-IN v-link-chk IN FRAME Dialog-Frame
   ALIGN-R                                                              */
/* SETTINGS FOR FILL-IN v-susp-chk IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN 
    v-susp-chk:HIDDEN IN FRAME Dialog-Frame = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Параметры по смене */
    DO:
        APPLY "END-ERROR":U TO SELF.
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-quit Dialog-Frame
ON CHOOSE OF b-quit IN FRAME Dialog-Frame /* Выход */
    DO:
        define buffer buf_reason for ub.code .  
                
        assign
            v-link-chk
            v-susp-chk
            CsuspChk
            .
          
        if v-susp = "" then 
        do:
            find first buf_reason no-lock where buf_reason.parent = {&extclass_reasons-suspicious-check} and 
                buf_reason.code = CsuspChk no-error .
            if available (buf_reason) then 
            do:
                v-susp = buf_reason.CodeName .
            end.
        end.
        if v-susp-chk = "" then p-susp-chk = v-susp .
        else p-susp-chk = v-susp + ": " + v-susp-chk .
        p-link-chk = v-link-chk .
            
        if CsuspChk = "0" and v-susp-chk = "" then 
        do:
            message 'Заполните поле с описанием "иной причины" возникновения подозрительного чека'
                view-as alert-box.
            apply "entry" to v-susp-chk IN FRAME {&frame-name} . 
            return no-apply .
        end.    
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME BUTTON-susp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-susp Dialog-Frame
ON CHOOSE OF BUTTON-susp IN FRAME Dialog-Frame /* ... */
    DO:
        define variable v-code as character no-undo .
        define buffer buf_reason for ub.code .  
        do with frame {&frame-name}:

            run ref/reasonSuspCheck.w(parparentproc,{&select},output v-code).

            find first buf_reason no-lock where buf_reason.parent = {&extclass_reasons-suspicious-check} and 
                buf_reason.code = v-code no-error .
            if available (buf_reason) then 
            do:
                if buf_reason.code = "0" then 
                do:
                    /*            charKey_one = buf_reason.code .*/
                    v-susp = buf_reason.CodeName .
                    v-susp-chk = "" .
                    display v-susp-chk .
                    CsuspChk = string(buf_reason.code) . 
                    display CsuspChk .
                    v-susp-chk:hidden in frame {&frame-name} = false . 
                    enable v-susp-chk with frame {&frame-name} .  
                    apply "entry" to v-susp-chk IN FRAME {&frame-name} . 
                end.
                else 
                do:
                    v-susp = "".
                    v-susp-chk = buf_reason.CodeName . 
                    v-susp-chk:hidden in frame {&frame-name} = true . 
                    CsuspChk = string(buf_reason.code) . 
                    display CsuspChk .
                    assign
                        v-susp = v-susp-chk
                        .
                    apply "entry" to v-link-chk IN FRAME {&frame-name} .     
                end.
            end.
        end. /* do with frame */
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME CsuspChk
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL CsuspChk Dialog-Frame
ON VALUE-CHANGED OF CsuspChk IN FRAME Dialog-Frame
    DO:
        assign CsuspChk .
        if CsuspChk = "0" then 
        do:
            v-susp-chk:hidden in frame {&frame-name} = false . 
            enable v-susp-chk with frame {&frame-name} . 
            apply "entry" to v-susp-chk IN FRAME {&frame-name} .
        end.
        else 
        do:
            v-susp-chk:hidden in frame {&frame-name} = true . 
            v-susp-chk = "" .
            v-susp-chk:screen-value = "" .
            assign v-susp-chk .
            apply "entry" to v-link-chk IN FRAME {&frame-name} .
        end.
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME v-link-chk
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-link-chk Dialog-Frame
ON LEAVE OF v-link-chk IN FRAME Dialog-Frame /* Ссылка на "корректный" чек */
    DO:
        assign
            v-link-chk.
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME v-susp-chk
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-susp-chk Dialog-Frame
ON LEAVE OF v-susp-chk IN FRAME Dialog-Frame
    DO:
        assign v-susp-chk .
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
    define variable reason_Chk as character no-undo .
    define variable null_Code  as character no-undo .
    
    define buffer buf_Code for ub.Code .
    reason_Chk = " " + {&delim-par} + "-1":U .

    for each ub.Code no-lock where ub.Code.parent = {&extclass_reasons-suspicious-check} and
        ub.Code.status_ = 0  BY ub.Code.Code desc:
        if ub.Code.code = "0" then null_Code = ub.Code.CodeName .
        reason_Chk = reason_Chk + {&delim-par} + ub.Code.CodeName + {&delim-par} + string(ub.Code.code) .
    end.

    ASSIGN
        CsuspChk:delimiter = {&delim-par} .
    CsuspChk:LIST-ITEM-PAIRS  in frame {&frame-name} = reason_Chk .       
     
    find first ub.susp-chk exclusive-lock where recid(ub.susp-chk) = p-doc-rec no-error .
    if not available (ub.susp-chk) then return no-apply .
    if ub.susp-chk.reason-name <> "" then 
    do:
        if ub.susp-chk.reason-name begins null_Code then 
        do:
            
            CsuspChk = "0" .
            v-susp-chk = replace(ub.susp-chk.reason-name, null_code, "") no-error .
            v-susp-chk = trim(v-susp-chk,": ").
            assign v-susp-chk .
            display v-susp-chk with frame {&frame-name} .
            enable v-susp-chk with frame {&frame-name} .
        end.
        else 
        do:
            find first buf_Code no-lock where buf_Code.parent = {&extclass_reasons-suspicious-check} and
                buf_Code.CodeName = ub.susp-chk.reason-name no-error .
            if available (buf_Code) then 
            do:
                CsuspChk = buf_Code.code .
            end.
        end.
        
    end.
    if ub.susp-chk.link-chk <> "" then v-link-chk = ub.susp-chk.link-chk .
    RUN enable_UI.
    WAIT-FOR GO OF FRAME {&FRAME-NAME} .
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
    DISPLAY CsuspChk v-link-chk 
        WITH FRAME Dialog-Frame.
    ENABLE RECT-2 b-quit CsuspChk BUTTON-susp v-link-chk 
        WITH FRAME Dialog-Frame.
    VIEW FRAME Dialog-Frame.
    {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

