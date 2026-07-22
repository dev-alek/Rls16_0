&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI ADM1
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS F-Frame-Win 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Отчет Итоги по дисконтным картам

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/07/05
Author: Bakhtadze Natalya
Creation date: 09/07/05

*/

/* Create an unnamed pool to store all the widgets created
     by this procedure. This is a good default which assures
     that this procedure's triggers and internal procedures
     will execute in this procedure's storage, and that proper
     cleanup will occur on deletion of the procedure. */

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Отчет Итоги по дисконтным картам" .
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i  }
{ rep/rep-bt.i   }
{ gbl/cur-time.i }
{ gbl/sel-date.i }

define variable dcard-mode as integer no-undo init 0.     /* переменная выбора по ДК */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE SmartObject
&Scoped-define DB-AWARE no

&Scoped-define ADM-CONTAINER FRAME

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME F-Main

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS rect-3 bt-date-to bt-date-from F-date-to ~
F-date-from flagOnlyDel 
&Scoped-Define DISPLAYED-OBJECTS F-date-to F-date-from flagOnlyDel 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE BUTTON bt-date-from 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "..." 
     SIZE 3.5 BY 1.04.

DEFINE BUTTON bt-date-to 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "..." 
     SIZE 3.5 BY 1.04.

DEFINE VARIABLE F-date-from AS DATE FORMAT "99/99/9999":U 
     VIEW-AS FILL-IN 
     SIZE 10.88 BY 1 NO-UNDO.

DEFINE VARIABLE F-date-to AS DATE FORMAT "99/99/9999":U 
     LABEL "За период с" 
     VIEW-AS FILL-IN 
     SIZE 10.88 BY 1 NO-UNDO.

DEFINE RECTANGLE rect-3
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 49.25 BY 4.29.

DEFINE VARIABLE flagOnlyDel AS LOGICAL INITIAL no 
     LABEL "Учитывать только дату/период удаления чеков" 
     VIEW-AS TOGGLE-BOX
     SIZE 46.5 BY .83 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     bt-date-to AT ROW 2.83 COL 28 WIDGET-ID 244
     bt-date-from AT ROW 2.83 COL 46.63 WIDGET-ID 246
     F-date-to AT ROW 2.88 COL 15.25 COLON-ALIGNED WIDGET-ID 238
     F-date-from AT ROW 2.88 COL 33.75 COLON-ALIGNED NO-LABEL WIDGET-ID 240
     flagOnlyDel AT ROW 4.25 COL 4.38 WIDGET-ID 248
     "Выбор даты/периода удаления чека" VIEW-AS TEXT
          SIZE 33.88 BY .79 AT ROW 1.58 COL 3.63
          FGCOLOR 4 
     "по" VIEW-AS TEXT
          SIZE 2.5 BY .67 AT ROW 3.04 COL 32.25 WIDGET-ID 242
     rect-3 AT ROW 1.21 COL 2.25
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 52.13 BY 4.58.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: SmartObject
   Allow: Basic,Browse,DB-Fields,Smart,Query
   Container Links: 
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB) 
  CREATE WINDOW F-Frame-Win ASSIGN
         HEIGHT             = 5.33
         WIDTH              = 52.63.
/* END WINDOW DEFINITION */
                                                                        */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB F-Frame-Win 
/* ************************* Included-Libraries *********************** */
{src/adm/method/containr.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW F-Frame-Win
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME F-Main
   NOT-VISIBLE FRAME-NAME                                               */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME F-Main
/* Query rebuild information for FRAME F-Main
     _Options          = ""
     _Query            is NOT OPENED
*/  /* FRAME F-Main */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME bt-date-from
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-date-from F-Frame-Win
ON CHOOSE OF bt-date-from IN FRAME F-Main /* ... */
DO:
    run sel-date in this-procedure
      (input F-date-from :handle
      ,input ""
      ) .
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-date-to
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-date-to F-Frame-Win
ON CHOOSE OF bt-date-to IN FRAME F-Main /* ... */
DO:
    run sel-date in this-procedure
      (input F-date-to :handle
      ,input ""
      ) .
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME F-date-from
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL F-date-from F-Frame-Win
ON LEAVE OF F-date-from IN FRAME F-Main
DO:
    assign F-date-from.
    if F-date-from < F-date-to then 
    do:
      message "Дата начала не может быть больше конечной даты"
        view-as alert-box.
      return no-apply .       
    end.      
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL F-date-from F-Frame-Win
ON RETURN OF F-date-from IN FRAME F-Main
DO:
    apply "TAB":U to self .
    return no-apply .
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL F-date-from F-Frame-Win
ON TAB OF F-date-from IN FRAME F-Main
DO:
    if string(F-date-from) <> F-date-from:screen-value then 
    do:
      assign F-date-from .
    end.
    if F-date-from < F-date-to then 
    do:
      message "Дата начала не может быть больше конечной даты"
        view-as alert-box.
      return no-apply .       
    end.
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME F-date-to
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL F-date-to F-Frame-Win
ON LEAVE OF F-date-to IN FRAME F-Main /* За период с */
DO:
    assign F-date-to .
    if F-date-from < F-date-to then 
    do:
      message "Дата начала не может быть больше конечной даты"
        view-as alert-box.
      return no-apply .       
    end.      
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL F-date-to F-Frame-Win
ON RETURN OF F-date-to IN FRAME F-Main /* За период с */
DO:
    apply "TAB":U to self .
    return no-apply .
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL F-date-to F-Frame-Win
ON TAB OF F-date-to IN FRAME F-Main /* За период с */
DO:
    if string(F-date-from) <> F-date-from:screen-value then 
    do:
      assign F-date-to .
    end.
    if F-date-from < F-date-to then 
    do:
      message "Дата начала не может быть больше конечной даты"
        view-as alert-box.
      return no-apply .       
    end.
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME flagOnlyDel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL flagOnlyDel F-Frame-Win
ON VALUE-CHANGED OF flagOnlyDel IN FRAME F-Main /* Учитывать только дату/период удаления чеков */
DO:
  assign flagOnlyDel .
  if flagOnlyDel then do:
    if F-date-from = ? or F-date-to = ? then do:
      message "Заполните даты удаления чека"
      view-as alert-box.
      flagOnlyDel = false .
      flagOnlyDel:screen-value = string(false) .
    end.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK F-Frame-Win 
{ gbl/ed_date.i f-date-from }
{ gbl/ed_date.i f-date-to }

&IF DEFINED(UIB_IS_RUNNING) <> 0 &THEN
/* Now enable the interface  if in test mode - otherwise this happens when
   the object is explicitly initialized from its container. */
run dispatch in this-procedure ('initialize':u).
&ENDIF

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-create-objects F-Frame-Win  _ADM-CREATE-OBJECTS
PROCEDURE adm-create-objects :
/*------------------------------------------------------------------------------
  Purpose:     Create handles for all SmartObjects used in this procedure.
               After SmartObjects are initialized, then SmartLinks are added.
  Parameters:  <none>
------------------------------------------------------------------------------*/

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-row-available F-Frame-Win  _ADM-ROW-AVAILABLE
PROCEDURE adm-row-available :
/*------------------------------------------------------------------------------
  Purpose:     Dispatched to this procedure when the Record-
               Source has a new row available.  This procedure
               tries to get the new row (or foriegn keys) from
               the Record-Source and process it.
  Parameters:  <none>
------------------------------------------------------------------------------*/

  /* Define variables needed by this internal procedure.             */
  {src/adm/template/row-head.i}

  /* Process the newly available records (i.e. display fields,
     open queries, and/or pass records on to any RECORD-TARGETS).    */
  {src/adm/template/row-end.i}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI F-Frame-Win  _DEFAULT-DISABLE
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
  HIDE FRAME F-Main.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI F-Frame-Win  _DEFAULT-ENABLE
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
  DISPLAY F-date-to F-date-from flagOnlyDel 
      WITH FRAME F-Main.
  ENABLE rect-3 bt-date-to bt-date-from F-date-to F-date-from flagOnlyDel 
      WITH FRAME F-Main.
  {&OPEN-BROWSERS-IN-QUERY-F-Main}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-initialize F-Frame-Win 
PROCEDURE local-initialize :
/*------------------------------------------------------------------------------
    Purpose:     Override standard ADM method
    Notes:
  ------------------------------------------------------------------------------*/
  /* Code placed here will execute PRIOR to standard behavior. */
  /* Dispatch standard ADM method.                             */
  run dispatch in this-procedure ( input 'initialize':u ) .
/* Code placed here will execute AFTER standard behavior.    */
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE My-report F-Frame-Win 
PROCEDURE My-report :
do:
    run rep/r-delChk.p (
      input my-handle,
      input F-date-to,
      input F-date-from,
      input flagOnlyDel
      ).
  end.
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-var F-Frame-Win 
PROCEDURE my-var :
.
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE state-changed F-Frame-Win 
PROCEDURE state-changed :
define input parameter p-issuer-hdl as handle no-undo.
  define input parameter p-state as character no-undo.
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

