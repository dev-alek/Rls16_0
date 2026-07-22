&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME d-mark

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DECLARATIONS d-mark 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Проверка кодов маркировки

Автор: Шкляр Елена
Дата создания: 20/04/95
Author: Shklyar Elena
Creation date: 20/04/95

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Проверка кодов маркировки".
{ str/temp_upd.i }
define input parameter parparentproc as widget-handle no-undo .
define input-output  PARAMETER TABLE FOR tt-tech-mark.
define input parameter p-mode as character no-undo .
define output parameter p-ok  as logical no-undo .

{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/library.i }
{ cmp/showinf.i }
{ cmp/r-pril.i new }
{ gbl/userobjs.i }
{ gbl/cur-time.i }
{ gbl/getcntxt.i def }
{ gbl/prn-lib.i }
{ gbl/waitfram.i }
{ cmp/mrk-strf.i }
{ gbl/color.i }

{ gbl/key-rec.i  }
{ utl/gtin.i }


/* Local Variable Definitions ---                                       */

DEFINE BUFFER X_marking             FOR tt-tech-mark.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS d-mark 
/*------------------------------------------------------------------------

  File: 

  Description: 

  Input Parameters:
      <none>

  Output Parameters:
      <none>

  Author: 

  Created: 16/02/20 - 12:57 pm

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME d-mark
&Scoped-define BROWSE-NAME br-no-mark

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_marking

/* Definitions for BROWSE br-no-mark                                    */
&Scoped-define FIELDS-IN-QUERY-br-no-mark X_marking.gds-code ~
X_marking.gds-name X_marking.qnty-doc X_marking.qnty-fact 
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-no-mark X_marking.qnty-fact 
&Scoped-define ENABLED-TABLES-IN-QUERY-br-no-mark X_marking
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-br-no-mark X_marking
&Scoped-define QUERY-STRING-br-no-mark FOR EACH X_marking exclusive-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-no-mark OPEN QUERY br-no-mark FOR EACH X_marking exclusive-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br-no-mark X_marking
&Scoped-define FIRST-TABLE-IN-QUERY-br-no-mark X_marking


/* Definitions for DIALOG-BOX d-mark                                    */
&Scoped-define OPEN-BROWSERS-IN-QUERY-d-mark ~
    ~{&OPEN-QUERY-br-no-mark}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-save b-exit br-no-mark 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-exit AUTO-GO 
     LABEL "&Выход ":L 
     SIZE 10 BY 1.

DEFINE BUTTON b-save AUTO-GO 
     LABEL "&Ввод":L 
     SIZE 10 BY 1.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-no-mark FOR 
      X_marking SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-no-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-no-mark d-mark _STRUCTURED
  QUERY br-no-mark NO-LOCK DISPLAY
      X_marking.gds-code COLUMN-LABEL "Код товара" FORMAT "999999999":U
      X_marking.gds-name COLUMN-LABEL "Наименование" FORMAT "x(210)":U width 25
      X_marking.qnty-doc COLUMN-LABEL "Кол-во марок!документ" FORMAT "->,>>>,>>9":U
      X_marking.qnty-fact COLUMN-LABEL "Кол-во марок!фактическое" FORMAT "->,>>>,>>9":U
 
  ENABLE
      X_marking.qnty-fact
    
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 86 BY 15.25 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME d-mark
     b-save AT ROW 1 COL 1
     b-exit AT ROW 1 COL 11 WIDGET-ID 292
     br-no-mark AT ROW 2.5 COL 1.5 WIDGET-ID 200
     SPACE(1.24) SKIP(0.41)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Немаркированная продукция":L.


/* *********************** Procedure Settings ************************ */

/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX d-mark
   FRAME-NAME                                                           */
/* BROWSE-TAB br-no-mark b-exit d-mark */
ASSIGN 
       FRAME d-mark:SCROLLABLE       = FALSE.

ASSIGN 
       br-no-mark:COLUMN-RESIZABLE IN FRAME d-mark       = TRUE.
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* ************************  Control Triggers  ************************ */


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-no-mark d-mark
ON leave OF br-no-mark IN FRAME d-mark
  DO:
    if available (tt-tech-mark) then do:
      if tt-tech-mark.qnty-fact > tt-tech-mark.qnty-doc then do:
        message "Фактическое кол-во марок не может быть больше кол-ва марок по документу"
        view-as alert-box.
        return no-apply.
      end.  
    end.  
      END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-no-mark d-mark
ON value-changed OF br-no-mark IN FRAME d-mark
  DO:
    if available (tt-tech-mark) then do:
      if tt-tech-mark.qnty-fact > tt-tech-mark.qnty-doc then do:
        message "Фактическое кол-во марок не может быть больше кол-ва марок по документу"
        view-as alert-box.
        return no-apply.
      end.  
    end.  
      END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-no-mark d-mark
ON return OF br-no-mark IN FRAME d-mark
  DO:
    if available (tt-tech-mark) then do:
      if tt-tech-mark.qnty-fact > tt-tech-mark.qnty-doc then do:
        message "Фактическое кол-во марок не может быть больше кол-ва марок по документу"
        view-as alert-box.
        return no-apply.
      end.  
    end.  
      END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK d-mark 
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-mark d-mark
ON choose OF b-exit IN FRAME d-mark
  DO:
    p-ok = false .
      END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK d-mark 
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-mark d-mark
ON choose OF b-save IN FRAME d-mark
  DO:
    for each tt-tech-mark:

      if tt-tech-mark.qnty-fact > tt-tech-mark.qnty-doc then do:
        message "Фактическое кол-во марок не может быть больше кол-ва марок по документу"
        view-as alert-box.
        return no-apply.
      end.  
  
    end.
    p-ok = true .
    
      END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
  THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

/* Add Trigger to equate WINDOW-CLOSE to END-ERROR                      */
ON WINDOW-CLOSE OF FRAME {&FRAME-NAME} 
  APPLY "END-ERROR":U TO SELF.

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
  ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

  { gbl/getcntxt.i get }

  { gbl/brwrepos.i
  &line-num= 5
}
  run init-temp in this-procedure .
  run enable_UI in this-procedure .

  WAIT-FOR GO OF FRAME {&FRAME-NAME} focus {&browse-name}.
END.

run disable_UI in this-procedure .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI d-mark  _DEFAULT-DISABLE
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
  HIDE FRAME d-mark.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI d-mark 
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
  

  ENABLE
    b-exit
    b-save
    with frame {&frame-name} .
    if p-mode <> {&lookup} then do:
      enable br-no-mark with frame {&frame-name} .
    end.
    else do:
      disable br-no-mark with frame {&frame-name} .
    end.      
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-temp d-mark 
PROCEDURE init-temp :
/* --------------------------------------------------------------------
                      Purpose:     ENABLE the User Interface
                      Parameters:  <none>
                      Notes:       Here we display/view/enable the widgets in the
                                   user-interface.  In addition, OPEN all queries
                                   associated with each FRAME and BROWSE.
                                   These statements here are based on the "Other
                                   Settings" section of the widget Property Sheets.
                       -------------------------------------------------------------------- */
  {&OPEN-QUERY-br-no-mark}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */



