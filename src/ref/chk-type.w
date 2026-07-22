&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME f-chk-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS f-chk-type 
/*

$Revision: $
$Author: $
$Date: $
$Workfile: $
$Archive: $

Типы чеков

Автор: Рукавишников Вадим
Дата создания: 24/05/21
Author: Rukavishnikov Vadim
Creation date: 24/05/21

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

define input parameter  parparentproc as widget-handle no-undo .

define variable vss-revision    as character no-undo init "$Revision: $":U .
define variable vss-author      as character no-undo init "$Author: $":U .
define variable vss-date        as character no-undo init "$Date: $":U .
define variable vss-workfile    as character no-undo init "$Workfile: $":U .
define variable vss-archive     as character no-undo init "$Archive: $":U .
define variable vss-description as character no-undo init "Код ОКЕИ код ККТ".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/library.i }
{ cmp/showinf.i }
{ cmp/r-pril.i new }
{ gbl/cur-time.i }
{ gbl/getcntxt.i def }
{ gbl/prn-lib.i }
{ gbl/waitfram.i }
{ cmp/mrk-strf.i }
{ ref/chk-type-desc.i }
{ ref/chk-type.i "shared"}
define temp-table tt-work-chk-type no-undo like tt-chk-type.

/* Local Variable Definitions ---                                       */

define variable log-res     as log       no-undo.
define variable ri          as recid     no-undo.
define variable v-rid       as recid     no-undo .
define variable v-db-num like ub.db.db-num no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME f-chk-type
&Scoped-define BROWSE-NAME br-chk-type

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-work-chk-type

/* Definitions for BROWSE br-chk-type                                   */
&Scoped-define FIELDS-IN-QUERY-br-chk-type tt-work-chk-type.sel tt-work-chk-type.code tt-work-chk-type.name   
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-chk-type   
&Scoped-define SELF-NAME br-chk-type
&Scoped-define QUERY-STRING-br-chk-type FOR EACH tt-work-chk-type NO-LOCK
&Scoped-define OPEN-QUERY-br-chk-type OPEN QUERY {&SELF-NAME} FOR EACH tt-work-chk-type NO-LOCK.
&Scoped-define TABLES-IN-QUERY-br-chk-type tt-work-chk-type
&Scoped-define FIRST-TABLE-IN-QUERY-br-chk-type tt-work-chk-type


/* Definitions for DIALOG-BOX f-chk-type                                */
&Scoped-define OPEN-BROWSERS-IN-QUERY-f-chk-type ~
    ~{&OPEN-QUERY-br-chk-type}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-mark b-sel br-chk-type 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-exit AUTO-GO 
     LABEL "&Выход ":L 
     SIZE 10 BY 1.

DEFINE BUTTON b-mark 
     LABEL "&*":L 
     SIZE 3.5 BY 1.

DEFINE BUTTON b-sel AUTO-GO 
     LABEL "Вы&бор ":L 
     SIZE 10 BY 1.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-chk-type FOR 
      tt-work-chk-type SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-chk-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-chk-type f-chk-type _FREEFORM
  QUERY br-chk-type DISPLAY
      tt-work-chk-type.sel COLUMN-LABEL "*" FORMAT "*/":U
  tt-work-chk-type.code COLUMN-LABEL "Код" FORMAT ">>>>9":U
  tt-work-chk-type.name COLUMN-LABEL "Наименование" FORMAT "X(20)":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH SEPARATORS SIZE 49 BY 15.25.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME f-chk-type
     b-exit AT ROW 1 COL 1
     b-mark AT ROW 1 COL 12.5 WIDGET-ID 2
     b-sel AT ROW 1 COL 16
     br-chk-type AT ROW 2.5 COL 3
     SPACE(1.99) SKIP(0.82)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Типы чеков":L.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX f-chk-type
   FRAME-NAME                                                           */
/* BROWSE-TAB br-chk-type b-sel f-chk-type */
ASSIGN 
       FRAME f-chk-type:SCROLLABLE       = FALSE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-chk-type
/* Query rebuild information for BROWSE br-chk-type
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-work-chk-type NO-LOCK.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE br-chk-type */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME f-chk-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-chk-type f-chk-type
ON GO OF FRAME f-chk-type /* Типы чеков */
DO:

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-mark f-chk-type
ON CHOOSE OF b-mark IN FRAME f-chk-type /* * */
DO:
   define variable v-focused-row       as integer no-undo.
   define variable v-repositioned-row  as integer no-undo.

   if not avail tt-work-chk-type then return.
   tt-work-chk-type.sel = not tt-work-chk-type.sel.

   assign
      v-focused-row      = {&BROWSE-NAME}:focused-row in frame {&FRAME-NAME}
      v-repositioned-row = current-result-row("{&BROWSE-NAME}")
      .
   {&OPEN-BROWSERS-IN-QUERY-f-chk-type}
   if v-focused-row > {&BROWSE-NAME}:height - 2
   then do:
      assign
         v-repositioned-row  = v-repositioned-row + 1
         .
   end.
   else do:
      assign
         v-focused-row       = v-focused-row + 1
         v-repositioned-row  = v-repositioned-row + 1
         .
   end.
   {&BROWSE-NAME}:set-repositioned-row(v-focused-row, "ALWAYS") in frame {&FRAME-NAME}.
   reposition {&BROWSE-NAME} to row v-repositioned-row.
   apply "entry" to {&BROWSE-NAME} in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel f-chk-type
ON CHOOSE OF b-sel IN FRAME f-chk-type /* Выбор  */
DO:
   define buffer b-tt-work-chk-type for tt-work-chk-type.
   if not can-find(first b-tt-work-chk-type where b-tt-work-chk-type.sel = yes) then
      tt-work-chk-type.sel = yes.
   
   empty temp-table tt-chk-type.
   for each tt-work-chk-type:
      create tt-chk-type.
      buffer-copy tt-work-chk-type to tt-chk-type.
   end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-chk-type
&Scoped-define SELF-NAME br-chk-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-chk-type f-chk-type
ON RETURN OF br-chk-type IN FRAME f-chk-type
DO:
    apply "DEFAULT-ACTION":U to self.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK f-chk-type 


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
  { gbl/curdbnum.i v-db-num }
  
  run FillTT.
  run enable_UI in this-procedure .

  WAIT-FOR GO OF FRAME {&FRAME-NAME} focus {&browse-name}.
END.
run disable_UI in this-procedure .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI f-chk-type  _DEFAULT-DISABLE
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
  HIDE FRAME f-chk-type.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI f-chk-type 
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
    br-chk-type
    b-exit
    b-sel
    b-mark
    WITH FRAME {&frame-name}.

  {&OPEN-BROWSERS-IN-QUERY-f-chk-type}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE FillTT f-chk-type 
PROCEDURE FillTT :
/* --------------------------------------------------------------------
        Purpose:     ENABLE the User Interface
        Parameters:  <none>
        Notes:       Here we display/view/enable the widgets in the
                     user-interface.  In addition, OPEN all queries
                     associated with each FRAME and BROWSE.
                     These statements here are based on the "Other
                     Settings" section of the widget Property Sheets.
         -------------------------------------------------------------------- */
   define variable vCode    as integer   no-undo.
   define variable vName    as character no-undo.
   define variable vI       as integer   no-undo.
   
   if not can-find(first tt-chk-type) then do:
      do vI = 1 to num-entries({&CHK_CODE_LIST}):
         vCode = integer(entry(vI, {&CHK_CODE_LIST})).
         vName = entry(vI, {&CHK_NAME_LIST}).
         
         create tt-work-chk-type.
         assign
            tt-work-chk-type.code = vCode
            tt-work-chk-type.name = vName
            .
      end.
   end.
   else do:
      for each tt-chk-type:
         create tt-work-chk-type.
         buffer-copy tt-chk-type to tt-work-chk-type.
      end.
   end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

