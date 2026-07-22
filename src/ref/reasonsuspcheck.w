&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME d-reasons-suspicious-check


/* Temp-Table and Buffer definitions                                    */
DEFINE NEW SHARED BUFFER X_ext-classif FOR ub.code.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS d-reasons-suspicious-check 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Справочник причин подозрительных чеков

Автор: Шкляр Елена
Дата создания: 20/04/95
Author: Shklyar Elena
Creation date: 20/04/95

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

define input parameter  parparentproc as widget-handle no-undo .
define input parameter  bttns         as character   no-undo .
define output parameter p-code        as character no-undo init ?.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Справочник причин подозрительных чеков".
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
{ ref/extclass.i }
/* Local Variable Definitions ---                                       */

define variable log-res     as log       no-undo.
define variable rr          as recid     no-undo.
define variable v_type      as char      no-undo.
define variable v-is-deploy as logical   no-undo .
define variable v-rid-list  as character no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME d-reasons-suspicious-check
&Scoped-define BROWSE-NAME br-reasons-suspicious-check

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_ext-classif

/* Definitions for BROWSE br-reasons-suspicious-check                                  */
&Scoped-define FIELDS-IN-QUERY-br-reasons-suspicious-check X_ext-classif.Code X_ext-classif.CodeName X_ext-classif.status_  
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-reasons-suspicious-check   
&Scoped-define SELF-NAME br-reasons-suspicious-check
&Scoped-define QUERY-STRING-br-reasons-suspicious-check FOR EACH X_ext-classif NO-LOCK where X_ext-classif.parent = {&extclass_reasons-suspicious-check} BY X_ext-classif.Code desc
&Scoped-define OPEN-QUERY-br-reasons-suspicious-check OPEN QUERY br-reasons-suspicious-check FOR EACH X_ext-classif NO-LOCK where X_ext-classif.parent = {&extclass_reasons-suspicious-check} BY X_ext-classif.Code desc.
&Scoped-define TABLES-IN-QUERY-br-reasons-suspicious-check X_ext-classif
&Scoped-define FIRST-TABLE-IN-QUERY-br-reasons-suspicious-check X_ext-classif


/* Definitions for DIALOG-BOX d-reasons-suspicious-check                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-d-reasons-suspicious-check ~
    ~{&OPEN-QUERY-br-reasons-suspicious-check}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-sel b-add b-del b-upd  ~
br-reasons-suspicious-check 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
/*DEFINE BUTTON b-add  */
/*  LABEL "&Добавить":L*/
/*  SIZE 10 BY 1.      */

/*DEFINE BUTTON b-del */
/*  LABEL "&Удалить":L*/
/*  SIZE 10 BY 1.     */

DEFINE BUTTON b-exit AUTO-GO 
  LABEL "&Выход ":L 
  SIZE 10 BY 1.

DEFINE BUTTON b-sel AUTO-GO 
  LABEL "Вы&бор ":L 
  SIZE 10 BY 1.

 
define variable t-del as logical init no
  label "Показывать удаленные":L
  view-as toggle-box
  size 22 by 1.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-reasons-suspicious-check FOR 
  X_ext-classif SCROLLING.
&ANALYZE-RESUME

function rvd-stat returns character (input p-nonuniq as integer) :
  if p-nonuniq = 1
  then return "Удал" .
  else return "Тек" .
end function .

function rvd-type returns character (input p-type as integer) :
  if p-type = 1
  then return "ТРК" .
  else return "РГС" .
end function .

/* Browse definitions                                                   */
DEFINE BROWSE br-reasons-suspicious-check
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-reasons-suspicious-check d-reasons-suspicious-check _FREEFORM
  QUERY br-reasons-suspicious-check NO-LOCK DISPLAY
  X_ext-classif.code COLUMN-LABEL "Код" FORMAT "X(64)":U width 10
  X_ext-classif.CodeName COLUMN-LABEL "Наименование" FORMAT "X(255)":U width 80
  rvd-stat(X_ext-classif.status_) COLUMN-LABEL "Статус" FORMAT "X(6)":U width 10
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH separators SIZE 102 BY 15 .


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME d-reasons-suspicious-check
  b-exit AT ROW 1 COL 1
  b-sel AT ROW 1 COL 11
  t-del at row 1 col 55
  br-reasons-suspicious-check AT ROW 3 COL 3
  SPACE(1) SKIP(1)
  WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
  SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
  TITLE "Причины подозрительных чеков":L.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Temp-Tables and Buffers:
      TABLE: X_pay-type B "NEW SHARED" ? ub pay-type
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX d-reasons-suspicious-check
   FRAME-NAME                                                           */
/* BROWSE-TAB br-reasons-suspicious-check b-help d-reasons-suspicious-check */
ASSIGN 
  FRAME d-reasons-suspicious-check:SCROLLABLE = FALSE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME
ASSIGN 
    br-reasons-suspicious-check:COLUMN-RESIZABLE IN FRAME d-reasons-suspicious-check = TRUE.

/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-reasons-suspicious-check
/* Query rebuild information for BROWSE br-reasons-suspicious-check
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_pay-type NO-LOCK
    BY X_pay-type.obj-name.
     _END_FREEFORM
     _Options          = "NO-LOCK"
     _OrdList          = "ub.pay-type.obj-name|yes"
     _Query            is OPENED
*/  /* BROWSE br-reasons-suspicious-check */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX d-reasons-suspicious-check
/* Query rebuild information for DIALOG-BOX d-reasons-suspicious-check
     _Options          = "SHARE-LOCK"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX d-reasons-suspicious-check */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME d-reasons-suspicious-check
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL d-reasons-suspicious-check d-reasons-suspicious-check
ON GO OF FRAME d-reasons-suspicious-check /* Основания для проведения коррекции */
  DO:
    p-code = X_ext-classif.Code no-error.
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel d-reasons-suspicious-check
ON CHOOSE OF b-sel IN FRAME d-reasons-suspicious-check /* Выбор  */
  DO:
    if ( available X_ext-classif )
    AND v-rid-list = "" 
    then
      v-rid-list = string( recid( X_ext-classif ) ) .
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
&Scoped-define SELF-NAME t-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL t-del d-reasons-suspicious-check
ON VALUE-CHANGED OF t-del IN FRAME d-reasons-suspicious-check
DO:
    assign
      t-del
    .
    if t-del
    then do :
      OPEN QUERY br-reasons-suspicious-check FOR EACH X_ext-classif NO-LOCK where X_ext-classif.parent = {&extclass_reasons-suspicious-check}
                                                              by X_ext-classif.status_ BY X_ext-classif.code desc .
    end .
    else do :
      OPEN QUERY br-reasons-suspicious-check FOR EACH X_ext-classif NO-LOCK where X_ext-classif.parent = {&extclass_reasons-suspicious-check}
                                                              and X_ext-classif.status_ = 0
                                                              by X_ext-classif.status_ BY X_ext-classif.code desc.
    end .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK d-reasons-suspicious-check 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
  THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

/*{ gbl/app_help.i }*/

/* Add Trigger to equate WINDOW-CLOSE to END-ERROR                      */
ON WINDOW-CLOSE OF FRAME {&FRAME-NAME} 
  APPLY "END-ERROR":U TO SELF.

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
  ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

  { gbl/getcntxt.i get }
  run enable_UI in this-procedure .
  WAIT-FOR GO OF FRAME {&FRAME-NAME} focus {&browse-name}.
END.
run disable_UI in this-procedure .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI d-reasons-suspicious-check  _DEFAULT-DISABLE
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
  HIDE FRAME d-reasons-suspicious-check.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI d-reasons-suspicious-check 
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
    br-reasons-suspicious-check
    b-exit
    b-sel WHEN can-do( bttns, {&select} )
    WITH FRAME {&frame-name}.
  
    enable
      t-del
    WITH FRAME {&frame-name}.

  OPEN QUERY br-reasons-suspicious-check FOR EACH X_ext-classif NO-LOCK where X_ext-classif.parent = {&extclass_reasons-suspicious-check}
                                                            and X_ext-classif.status_ = 0
                                                            by X_ext-classif.status_ by X_ext-classif.code desc.
  
  if available X_ext-classif
    then log-res  = br-reasons-suspicious-check:select-focused-row( ).
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

