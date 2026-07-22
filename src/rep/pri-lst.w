&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME pri-lst
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS pri-lst
/*------------------------------------------------------------------------

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Выбор типа печати по списку

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/12/06
Author: Bakhtadze Natalya
Creation date: 04/12/06

Andrew Isakov
09/10/98
------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-curr-obj-type like ub.clients.obj-type  no-undo .
define input parameter p-curr-obj-code like ub.clients.obj-code  no-undo .
define input parameter lst-type as char no-undo.
define input parameter table-name as character no-undo .

/*может быть gds-list или bb-list*/
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Выбор типа печати по списку".
{ cmp/vssrevis.i }

/* Local Variable Definitions ---                                       */
{ cmp/str-glbl.i }
{ cmp/showinf.i }
{ ref/gdsoattr.i }
DEFINE VARIABLE varattr-value as character no-undo .
DEFINE VARIABLE varattr-type as character no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME pri-lst

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit b-help t-1 t-2
&Scoped-Define DISPLAYED-OBJECTS t-1 t-2

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-help DEFAULT
     LABEL "Помо&щь"
     SIZE 10 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY DEFAULT
     LABEL "&Отмена"
     SIZE 10 BY 1.

DEFINE VARIABLE t-1 AS LOGICAL INITIAL no
     LABEL "Печать &списка"
     VIEW-AS TOGGLE-BOX
     SIZE 44.25 BY .79 NO-UNDO.

DEFINE VARIABLE t-2 AS LOGICAL INITIAL no
     LABEL "Печать ценников (этикеток)"
     VIEW-AS TOGGLE-BOX
     SIZE 44.25 BY .79 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME pri-lst
     b-quit AT ROW 1 COL 10.5
     b-help AT ROW 1 COL 32.5
     t-1 AT ROW 2.5 COL 2
     t-2 AT ROW 3.67 COL 2
     SPACE(0.98) SKIP(0.78)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Что напечатать".


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX pri-lst
                                                                        */
ASSIGN
       FRAME pri-lst:SCROLLABLE       = FALSE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX pri-lst
/* Query rebuild information for DIALOG-BOX pri-lst
     _Options          = "SHARE-LOCK"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX pri-lst */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME t-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL t-1 pri-lst
ON VALUE-CHANGED OF t-1 IN FRAME pri-lst /* Печать списка */
DO:
    run rep/r-gdslst.w (
                     input parparentproc
                   , input p-curr-obj-type
                   , input p-curr-obj-code
                   , input lst-type
                   , input table-name
                   ).
    apply "GO" to FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME t-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL t-2 pri-lst
ON VALUE-CHANGED OF t-2 IN FRAME pri-lst /* Печать ценников (этикеток) */
DO:
  CASE table-name :
    when "gds-list" then do:
      CASE lst-type:
        when "LIST" then do:
          run rep/tickslst.p (input parparentproc, input p-curr-obj-type, input p-curr-obj-code).
        end.
        when "ALL" then do:
          run rep/tick-lst.p (input parparentproc, input p-curr-obj-type, input p-curr-obj-code).
        end.
      END CASE.
    end.
    when "bb-list" then do:
      CASE lst-type:
        when "LIST" then do:
          run rep/tckbslst.p (input parparentproc, input p-curr-obj-type, input p-curr-obj-code).
        end.
        when "ALL" then do:
          run rep/tckb-lst.p (input parparentproc, input p-curr-obj-type, input p-curr-obj-code).
        end.
      END CASE.
    end.
  END CASE.


    apply "GO" to FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK pri-lst


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

/* Add Trigger to equate WINDOW-CLOSE to END-ERROR                      */
ON WINDOW-CLOSE OF FRAME {&FRAME-NAME} APPLY "END-ERROR":U TO SELF.

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  { gbl/app_help.i }
  RUN enable_UI.
/*
              t-2:label = "По &1 ценнику на каждый товар списка" .
              t-3:label = "Бар-коды на партии по &остаткам на объекте" .
*/
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI pri-lst  _DEFAULT-DISABLE
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
  HIDE FRAME pri-lst.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI pri-lst  _DEFAULT-ENABLE
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
  DISPLAY t-1 t-2
      WITH FRAME pri-lst.
  ENABLE b-quit b-help t-1 t-2
      WITH FRAME pri-lst.
  {&OPEN-BROWSERS-IN-QUERY-pri-lst}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME