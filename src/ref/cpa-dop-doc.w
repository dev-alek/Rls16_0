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

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo.
define input parameter p-cdpay-code   like ub.cash-pay-attr.cdpay-code     no-undo .
define input parameter p-curr-code    like ub.cash-pay-attr.curr-code      no-undo .
define input parameter p-host-code    like ub.cash-pay-attr.host-code      no-undo .
define input parameter p-obj-type     like ub.cash-pay-attr.obj-type       no-undo .
define input parameter p-obj-code     like ub.cash-pay-attr.obj-code       no-undo .
define input-output parameter p-attr-value as character no-undo.
define output parameter p-ok as logical no-undo.

/* Local Variable Definitions ---                                       */
def var vss-revision    as character no-undo init "$Revision$":U .
def var vss-author      as character no-undo init "$Author$":U .
def var vss-date        as character no-undo init "$Date$":U .
def var vss-workfile    as character no-undo init "$Workfile$":U .
def var vss-archive     as character no-undo init "$Archive$":U .
def var vss-description as character no-undo init "Задание атрибута дополнительного документа".

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }

&Scoped-define dop-docs {&sale-add-write-off} + ',' + {&sale-add-tech-refuell} + ',' + {&sale-add-vir-res} + ',none'
&Scoped-define dop-docs-full 'Списание,ТехПролив,Перемещение в вирт.рез.,Не создавать'

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS Btn_Cancel Btn_OK cb-doc-type btn-cli 
&Scoped-Define DISPLAYED-OBJECTS cb-doc-type FILL-IN-cli 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON btn-cli 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-acc" 
     SIZE 3 BY 1.

DEFINE BUTTON Btn_Cancel AUTO-END-KEY 
     LABEL "Выход" 
     SIZE 8 BY .96
     BGCOLOR 8 .

DEFINE BUTTON Btn_OK AUTO-GO 
     LABEL "Сохранить" 
     SIZE 10 BY .96
     BGCOLOR 8 .

DEFINE VARIABLE cb-doc-type AS CHARACTER FORMAT "X(256)":U 
     LABEL "Тип документа" 
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEM-PAIRS "Item 1","Item 1"
     DROP-DOWN-LIST
     SIZE 23 BY 1 NO-UNDO.

DEFINE VARIABLE FILL-IN-cli AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 12 BY .96 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     Btn_Cancel AT ROW 1 COL 1
     Btn_OK AT ROW 1 COL 11
     cb-doc-type AT ROW 2.17 COL 1.57 WIDGET-ID 4
     FILL-IN-cli AT ROW 3.39 COL 23 COLON-ALIGNED NO-LABEL WIDGET-ID 8
     btn-cli AT ROW 3.39 COL 37 WIDGET-ID 10
     "Контрагент:" VIEW-AS TEXT
          SIZE 13 BY .96 AT ROW 3.39 COL 2 WIDGET-ID 6
     SPACE(27.79) SKIP(0.74)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Создание дополнительного документа"
         DEFAULT-BUTTON Btn_OK CANCEL-BUTTON Btn_Cancel WIDGET-ID 100.


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

/* SETTINGS FOR COMBO-BOX cb-doc-type IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN FILL-IN-cli IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN 
       FILL-IN-cli:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Создание дополнительного документа */
DO:
        APPLY "END-ERROR":U TO SELF.
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btn-cli
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btn-cli Dialog-Frame
ON CHOOSE OF btn-cli IN FRAME Dialog-Frame /* r-acc */
DO:
        define variable v-ok       as logical   no-undo.
        define variable v-cli-type as character no-undo.
        define variable v-cli-code as integer   no-undo.
    
        run ref/selcli.p(
            parparentproc,
            ?,
            {&cmp},
            false,
            output v-ok,
            output v-cli-type,
            output v-cli-code
        ).
        
        if v-ok then
            FILL-IN-cli:screen-value = v-cli-type + " " + string(v-cli-code).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_OK
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_OK Dialog-Frame
ON CHOOSE OF Btn_OK IN FRAME Dialog-Frame /* Сохранить */
DO:
                RUN proc-save IN THIS-PROCEDURE NO-ERROR.
                IF ERROR-STATUS:ERROR THEN 
                DO:
                    RETURN NO-APPLY.
                END.
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
            run proc-load.
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
  DISPLAY cb-doc-type FILL-IN-cli 
      WITH FRAME Dialog-Frame.
  ENABLE Btn_Cancel Btn_OK cb-doc-type btn-cli 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-load Dialog-Frame 
PROCEDURE proc-load :
define variable i      as integer   no-undo.
    define variable v-list as character no-undo.

    do with frame {&FRAME-NAME}:
        do i = 1 to num-entries ({&dop-docs}):
            v-list = v-list + subst(",&1,&2", entry(i, {&dop-docs-full}), i).
        end.
    
        cb-doc-type:list-item-pairs = trim(v-list, ",").
    
        if p-attr-value <> "" then 
        do:
            FILL-IN-cli:screen-value = entry(2, p-attr-value) + " " + entry(3, p-attr-value).
            cb-doc-type:screen-value = string(lookup(entry(1, p-attr-value), {&dop-docs})).
        end.
        else 
        do:
            cb-doc-type:screen-value = string(lookup({&sale-add-write-off}, {&dop-docs})).
        end.
    end.
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save Dialog-Frame 
PROCEDURE proc-save :
/*------------------------------------------------------------------------------
                            Purpose: Проверка параметров и помещение их в инпуты                                                                                                                                      
                            Notes:                                                                                                                                            
            ------------------------------------------------------------------------------*/
    define variable v-cli-type as character no-undo.
    define variable v-cli-code as integer no-undo.
    
    do with frame {&FRAME-NAME}:
        
        v-cli-type = ''.
        v-cli-code = 0.
        
        assign
        v-cli-type = entry(1, FILL-IN-cli:screen-value, " ")
        v-cli-code = int(entry(2, FILL-IN-cli:screen-value, " ")) no-error.
        
        p-attr-value = entry(int(cb-doc-type:input-value), {&dop-docs}) +
                       ',' +
                       v-cli-type +
                       "," + 
                       string(v-cli-code).
        p-ok = yes.
    end.
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

