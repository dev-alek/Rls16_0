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

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
define input parameter as-ref as log no-undo.
define output parameter unit-name as character init ? no-undo.

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
{ gbl/getcntxt.i def }

/* Local Variable Definitions ---                                       */

define variable ri as recid no-undo.
define variable glog as logical no-undo .
define variable v-guid_ as character no-undo .

define buffer buf_units-attr for ub.units-attr .

define temp-table tt-units like ub.units
  field guid_ as character format "X(40)"
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

DEFINE BUTTON b-connect
     LABEL "&Связать":L
     SIZE 10 BY 1.

DEFINE BUTTON b-exit AUTO-END-KEY
     LABEL "&Выход ":L
     SIZE 10 BY 1.

DEFINE BUTTON b-del
     LABEL "&Удалить":L
     SIZE 10 BY 1 tooltip "Удалить связку с данными ФГИС Меркурий".

DEFINE BUTTON b-select
     LABEL "Вы&брать":L
     SIZE 10 BY 1.

/* Query definitions                                                    */
DEFINE QUERY br-units FOR tt-units SCROLLING.

/* Browse definitions                                                   */
DEFINE BROWSE br-units QUERY br-units NO-LOCK DISPLAY
      tt-units.unit-name
      tt-units.long-name FORMAT "X(30)"
      tt-units.OKEI COLUMn-LABEL "Код!ОКЕИ"
      tt-units.guid_ column-label "GUID в ФГИС Меркурий" format "X(40)"
    WITH SEPARATORS
          &IF '{&WINDOW-SYSTEM}' = 'TTY':U &THEN SIZE 69 BY 13
          &ELSE size 86.25 by 12.58 &ENDIF
         .


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME d-units
     br-units at row 2.5 col 3
     b-exit at row 1 col 1
     b-connect at row 1 col 11
     b-select at row 1 col 11
     b-del at row 1 col 21
    WITH VIEW-AS DIALOG-BOX
         SIDE-LABELS THREE-D
         SCROLLABLE size 91.88 by 16.25
         TITLE "Синхронизация единиц измерения с ФГИС Меркурий":L.




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
ON CHOOSE OF b-connect IN FRAME d-units /* Связать */
DO:
  if not available tt-units then return no-apply .
  
  run bge\units-merc-connect.w (input parparentproc,
                                output v-guid_ ) .
  if v-guid_ <> ""
  then do :                            
    tt-units.guid_ = v-guid_ .                            
    
    find first buf_units-attr exclusive-lock where buf_units-attr.unit-name = tt-units.unit-name
                                               and buf_units-attr.attr-code = "MercGuid"
                                               no-error .
    if not available buf_units-attr
    then do :
      create buf_units-attr .
      assign
        buf_units-attr.unit-name = tt-units.unit-name
        buf_units-attr.attr-code = "MercGuid"
      .
    end.
    buf_units-attr.attr-value = v-guid_ .                                           
    
    br-units:refresh () .
  end.                            
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-del d-units
ON CHOOSE OF B-del IN FRAME d-units /* Удалить */
DO:
  if not available tt-units or tt-units.guid_ = "" then return no-apply .
  
  find first buf_units-attr exclusive-lock where buf_units-attr.unit-name = tt-units.unit-name
                                               and buf_units-attr.attr-code = "MercGuid"
                                               no-error .
  if available buf_units-attr
  then do :
    delete buf_units-attr .
  end.
  
  tt-units.guid_ = "" .
  
  br-units:refresh () .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-select
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-select d-units
ON CHOOSE OF b-select IN FRAME d-units /* Выбрать */
DO:
    if available tt-units then
        do:
            unit-name = tt-units.unit-name .
            apply  "GO" to FRAME {&FRAME-NAME}.
        end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-units
&Scoped-define SELF-NAME br-units
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-units d-units
ON DEFAULT-ACTION OF br-units IN FRAME d-units
DO:
    if as-ref then
        do:
                apply "CHOOSE":U to b-select.
        end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-units d-units
ON RETURN OF br-units IN FRAME d-units
DO:
    if as-ref then
        do:
                apply "CHOOSE":U to b-select.
        end.
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
  
  empty temp-table tt-units .
  for each ub.units no-lock :
    create tt-units.
    buffer-copy ub.units to tt-units.
    find first ub.units-attr no-lock where ub.units-attr.unit-name = ub.units.unit-name
                                       and ub.units-attr.attr-code = "MercGuid" no-error .
    if available ub.units-attr then tt-units.guid_ =  ub.units-attr.attr-value .                                  
  end.
 
  RUN enable_UI.

  if available tt-units then
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
    b-select:visible IN FRAME {&frame-name} = as-ref .
    b-connect:visible IN FRAME {&frame-name} = not as-ref .
    b-del:visible IN FRAME {&frame-name} = not as-ref .
    ENABLE  br-units b-exit
                    b-connect     WHEN v-cntxt-db-num = 0
                    b-del         WHEN v-cntxt-db-num = 0
                    b-select      WHEN b-select:visible
        WITH FRAME d-units.
        
    OPEN QUERY br-units FOR EACH tt-units exclusive-LOCK  .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE BROWSE-NAME
&UNDEFINE FRAME-NAME
&UNDEFINE WINDOW-NAME