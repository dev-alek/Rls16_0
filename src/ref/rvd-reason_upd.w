&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v7r11 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME d-rvd-reason


/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE tt_ext-classif 
  field Key#_Two    as integer
  field CharKey_One as character
  field CharKey_Two as character
  field CharKey_Three as character
  index pi CharKey_One 
  .


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS d-rvd-reason 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Форма редактирования основания для документа 

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

Created: 20/04/95 -  7:11 pm

*/

/* ***************************  Definitions  ************************** */
/* Parameters Definitions ---                                           */
define input        parameter parparentproc as widget-handle no-undo .
define input        parameter ref-mode      as character     no-undo .
define input-output parameter rid           as recid         no-undo.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Форма редактирования основания документа".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i }
{ ref/extclass.i }

/* Local Variable Definitions ---                                       */

define buffer buf_ext-classif for ub.ext-classif .
define buffer buf2_ext-classif for ub.ext-classif .
define buffer buf_ext-classif1 for ub.ext-classif .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME d-rvd-reason

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt_ext-classif

/* Definitions for DIALOG-BOX d-rvd-reason                              */


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS tt_ext-classif.Key#_Two tt_ext-classif.CharKey_One tt_ext-classif.CharKey_Two tt_ext-classif.CharKey_Three
&Scoped-define ENABLED-TABLES tt_ext-classif
&Scoped-define FIRST-ENABLED-TABLE tt_ext-classif
&Scoped-Define ENABLED-OBJECTS b-OK b-cancel 
&Scoped-Define DISPLAYED-FIELDS tt_ext-classif.Key#_Two tt_ext-classif.CharKey_One tt_ext-classif.CharKey_Two tt_ext-classif.CharKey_Three
&Scoped-define DISPLAYED-TABLES tt_ext-classif
&Scoped-define FIRST-DISPLAYED-TABLE tt_ext-classif


/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-cancel AUTO-END-KEY 
  LABEL "&Отмена" 
  SIZE 10 BY 1.

DEFINE BUTTON b-OK AUTO-GO 
  LABEL "&Ввод " 
  SIZE 10 BY 1.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME d-rvd-reason
  b-OK AT ROW 1 COL 1
  b-cancel AT ROW 1 COL 11
  tt_ext-classif.CharKey_One AT ROW 3 COL 4 format "X(64)"
    LABEL "Код"        
    VIEW-AS FILL-IN 
    SIZE 10 BY 1
  tt_ext-classif.Key#_Two AT ROW 3 COL 21
    LABEL "Тип"        
    view-as combo-box inner-lines 2
    list-item-pairs "РГС",0,"ТРК",1
    DROP-DOWN-LIST
    size 7 by 1
  tt_ext-classif.CharKey_Two AT ROW 4.1 COL 4 format "X(255)"
    LABEL "Основание/причина"
    VIEW-AS fill-in 
    SIZE 50 BY 1 
  tt_ext-classif.CharKey_Three AT ROW 5.1 COL 4 format "X(255)"
    LABEL "Описание"
    VIEW-AS fill-in 
    SIZE 59 BY 1
  SPACE(1) SKIP(1)
  WITH VIEW-AS DIALOG-BOX 
  SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
  TITLE "Основание".


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Temp-Tables and Buffers:
      TABLE: tt_pay-type T "?" NO-UNDO ub pay-type
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX d-rvd-reason
   FRAME-NAME                                                           */
ASSIGN 
  FRAME d-rvd-reason:SCROLLABLE = FALSE.

/* SETTINGS FOR FILL-IN tt_ext-classif.CharKey_One IN FRAME d-rvd-reason
   ALIGN-R                                                              */
/* SETTINGS FOR EDITOR tt_ext-classif.CharKey_Two IN FRAME d-rvd-reason
   ALIGN-R                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX d-rvd-reason
/* Query rebuild information for DIALOG-BOX d-rvd-reason
     _TblList          = "Temp-Tables.tt_pay-type"
     _Options          = "SHARE-LOCK"
     _Query            is OPENED
*/  /* DIALOG-BOX d-rvd-reason */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME b-OK
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-OK d-rvd-reason
ON CHOOSE OF b-OK IN FRAME d-rvd-reason /* Ввод  */
DO:

  assign
    tt_ext-classif.Key#_Two
    tt_ext-classif.CharKey_One
    tt_ext-classif.CharKey_Two
    tt_ext-classif.CharKey_Three
  .

  if ref-mode = {&add-def}
  then do :
    find first buf_ext-classif1 no-lock where buf_ext-classif1.CharKey_One = tt_ext-classif.CharKey_One
                                    and buf_ext-classif1.classif-subject = {&extclass_rvd-reason} 
                                    and buf_ext-classif1.classif-name = {&extclass_rvd-reason}
                                    no-error .
    if available buf_ext-classif1 then 
    do:
      message substitute( "Причина изменения режима ввода данных с кодом &1 уже существует!", tt_ext-classif.CharKey_One )
      view-as alert-box .
      return no-apply .
    end.
    create buf_ext-classif .
    assign
      buf_ext-classif.Key#_One        = 0
      buf_ext-classif.classif-subject = {&extclass_rvd-reason}
      buf_ext-classif.classif-name    = {&extclass_rvd-reason}
      buf_ext-classif.db-num          = 0
      buf_ext-classif.key#_three      = 0
      buf_ext-classif.nonunique       = 0
    .
  end .
  else do :
    find first buf_ext-classif1 no-lock where buf_ext-classif1.CharKey_One = tt_ext-classif.CharKey_One
                                    and buf_ext-classif1.classif-subject = {&extclass_rvd-reason} 
                                    and buf_ext-classif1.classif-name = {&extclass_rvd-reason}
                                    and recid( buf_ext-classif1 ) <> rid
                                    no-error .
    if available buf_ext-classif1 then 
    do:
      message substitute( "Причина изменения режима ввода данных с кодом &1 уже существует!", tt_ext-classif.CharKey_One )
      view-as alert-box .
      return no-apply .
    end.
    find first buf2_ext-classif exclusive-lock where recid( buf2_ext-classif ) = rid .
    create buf_ext-classif .
    buffer-copy buf2_ext-classif to buf_ext-classif 
    assign buf_ext-classif.charkey_one = "-1" .
    delete buf2_ext-classif .
  end .
  
  assign
    buf_ext-classif.Key#_Two    = tt_ext-classif.Key#_Two
    buf_ext-classif.charkey_one = tt_ext-classif.CharKey_One
    buf_ext-classif.charkey_two = tt_ext-classif.CharKey_Two
    buf_ext-classif.charkey_three = tt_ext-classif.CharKey_Three
    buf_ext-classif.uniq-key-rec = {&extclass_rvd-reason} + {&delim-key}
                                 + buf_ext-classif.charkey_one
  .
  rid = recid( buf_ext-classif ) .
  release buf_ext-classif .
  

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK d-rvd-reason 


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
DO ON ERROR UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
  ON END-KEY  UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
  ON STOP     UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

  empty temp-table tt_ext-classif .
  define variable v-code as integer no-undo .
  define variable v-max-code as integer no-undo .
  
  create tt_ext-classif.
  if ref-mode = {&add-def} then  
  do:
    assign
      rid = ?
    .
    v-max-code = 0 .
    for each buf_ext-classif no-lock where buf_ext-classif.classif-subject = {&extclass_rvd-reason}
                                       and buf_ext-classif.classif-name = {&extclass_rvd-reason}
                                       :
      v-code = integer(buf_ext-classif.CharKey_One) no-error .
      if not error-status:error
      then do :
        v-max-code = max(v-max-code, v-code) .
      end .                                   
    end .
    v-max-code = v-max-code + 1 .
    assign
      tt_ext-classif.CharKey_One = string(v-max-code) .
    .
  end.
  else 
  do:
    find first buf2_ext-classif exclusive-lock
      where recid( buf2_ext-classif ) = rid
      .
    assign
      tt_ext-classif.Key#_Two    = buf2_ext-classif.Key#_Two
      tt_ext-classif.CharKey_One = buf2_ext-classif.CharKey_One
      tt_ext-classif.CharKey_Two = buf2_ext-classif.CharKey_Two
      tt_ext-classif.CharKey_Three = buf2_ext-classif.CharKey_Three
    .
    
  end.

  RUN enable_UI.

  
  WAIT-FOR GO OF FRAME {&FRAME-NAME} .
  
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI d-rvd-reason  _DEFAULT-DISABLE
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
  HIDE FRAME d-rvd-reason.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI d-rvd-reason 
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
  DISPLAY
    tt_ext-classif.Key#_Two
    tt_ext-classif.CharKey_One
    tt_ext-classif.CharKey_Two
    tt_ext-classif.CharKey_Three
  WITH FRAME d-rvd-reason.
  ENABLE
    b-OK
    b-cancel
    tt_ext-classif.Key#_Two
    tt_ext-classif.CharKey_One
    tt_ext-classif.CharKey_Two
    tt_ext-classif.CharKey_Three
  WITH FRAME d-rvd-reason.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

