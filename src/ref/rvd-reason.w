&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME d-rvd-reason


/* Temp-Table and Buffer definitions                                    */
DEFINE NEW SHARED BUFFER X_ext-classif FOR ub.ext-classif.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS d-rvd-reason 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Справочник оснований для установки РВД

Автор: Бахтадзе Наталья Викторовна
Дата создания: 20/04/95
Author: Bakhtadze Natalya
Creation date: 20/04/95

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

define input parameter  parparentproc as widget-handle no-undo .
define input parameter  bttns         as character   no-undo .
define input parameter  p-mode        as character no-undo .
define input parameter  p-type        as integer no-undo .
define output parameter p-rid-list    as character no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Справочник оснований для коррекции".
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
&Scoped-define FRAME-NAME d-rvd-reason
&Scoped-define BROWSE-NAME br-rvd-reason

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_ext-classif

/* Definitions for BROWSE br-rvd-reason                                  */
&Scoped-define FIELDS-IN-QUERY-br-rvd-reason X_ext-classif.Key#_One X_ext-classif.CharKey_One X_ext-classif.CharKey_Two  
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-rvd-reason   
&Scoped-define SELF-NAME br-rvd-reason
&Scoped-define QUERY-STRING-br-rvd-reason FOR EACH X_ext-classif NO-LOCK where X_ext-classif.classif-subject = {&extclass_rvd-reason} and X_ext-classif.classif-name = {&extclass_rvd-reason} BY X_ext-classif.CharKey_One
&Scoped-define OPEN-QUERY-br-rvd-reason OPEN QUERY br-rvd-reason FOR EACH X_ext-classif NO-LOCK where X_ext-classif.classif-subject = {&extclass_rvd-reason} and X_ext-classif.classif-name = {&extclass_rvd-reason} BY X_ext-classif.CharKey_One .
&Scoped-define TABLES-IN-QUERY-br-rvd-reason X_ext-classif
&Scoped-define FIRST-TABLE-IN-QUERY-br-rvd-reason X_ext-classif


/* Definitions for DIALOG-BOX d-rvd-reason                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-d-rvd-reason ~
    ~{&OPEN-QUERY-br-rvd-reason}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-sel b-add b-del b-upd b-mark ~
br-rvd-reason 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-add 
  LABEL "&Добавить":L 
  SIZE 10 BY 1.

DEFINE BUTTON b-del 
  LABEL "&Удалить":L 
  SIZE 10 BY 1.

DEFINE BUTTON b-exit AUTO-GO 
  LABEL "&Выход ":L 
  SIZE 10 BY 1.

DEFINE BUTTON b-sel AUTO-GO 
  LABEL "Вы&бор ":L 
  SIZE 10 BY 1.

DEFINE BUTTON b-upd 
  LABEL "&Изменить":L 
  SIZE 10 BY 1.
  
DEFINE BUTTON b-mark 
  LABEL "&*":L 
  SIZE 3 BY 1.
  
define variable t-del as logical init no
  label "Показывать удаленные":L
  view-as toggle-box
  size 22 by 1.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-rvd-reason FOR 
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
DEFINE BROWSE br-rvd-reason
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-rvd-reason d-rvd-reason _FREEFORM
  QUERY br-rvd-reason NO-LOCK DISPLAY
  X_ext-classif.charkey_one COLUMN-LABEL "Код" FORMAT "X(64)":U width 10
  X_ext-classif.charkey_two COLUMN-LABEL "Основание/причина" FORMAT "X(255)":U width 35
  rvd-stat(X_ext-classif.nonuniq) COLUMN-LABEL "Статус" FORMAT "X(6)":U width 6
  rvd-type(X_ext-classif.key#_two) COLUMN-LABEL "Тип" FORMAT "X(4)":U width 4
  X_ext-classif.CharKey_Three COLUMN-LABEL "Описание" FORMAT "X(255)":U width 50
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH SEPARATORS SIZE 72 BY 15.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME d-rvd-reason
  b-exit AT ROW 1 COL 1
  b-mark at row 1 col 11
  b-sel AT ROW 1 COL 14
  b-add AT ROW 1 COL 24
  b-del AT ROW 1 COL 34 WIDGET-ID 2
  b-upd AT ROW 1 COL 44
  t-del at row 1 col 55
  br-rvd-reason AT ROW 3 COL 3
  SPACE(1) SKIP(1)
  WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
  SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
  TITLE "Причины изменения режима ввода данных":L.


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
/* SETTINGS FOR DIALOG-BOX d-rvd-reason
   FRAME-NAME                                                           */
/* BROWSE-TAB br-rvd-reason b-help d-rvd-reason */
ASSIGN 
  FRAME d-rvd-reason:SCROLLABLE = FALSE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-rvd-reason
/* Query rebuild information for BROWSE br-rvd-reason
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_pay-type NO-LOCK
    BY X_pay-type.obj-name.
     _END_FREEFORM
     _Options          = "NO-LOCK"
     _OrdList          = "ub.pay-type.obj-name|yes"
     _Query            is OPENED
*/  /* BROWSE br-rvd-reason */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX d-rvd-reason
/* Query rebuild information for DIALOG-BOX d-rvd-reason
     _Options          = "SHARE-LOCK"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX d-rvd-reason */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME d-rvd-reason
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL d-rvd-reason d-rvd-reason
ON GO OF FRAME d-rvd-reason /* Основания для проведения коррекции */
  DO:
    p-rid-list = v-rid-list.
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add d-rvd-reason
ON CHOOSE OF b-add IN FRAME d-rvd-reason /* Добавить */
  DO:

    run ref/rvd-reason_upd.w
      (  input parparentproc
      , input {&add-def}
      , input-output rr ).
    if rr <> ? then 
    do:
      if t-del
      then do :
        OPEN QUERY br-rvd-reason FOR EACH X_ext-classif NO-LOCK where X_ext-classif.classif-subject = {&extclass_rvd-reason}
                                                                and X_ext-classif.classif-name = {&extclass_rvd-reason}
                                                                and (X_ext-classif.key#_Two = p-type or p-type = -1)
                                                                by X_ext-classif.nonuniq BY X_ext-classif.CharKey_One .
      end .
      else do :
        OPEN QUERY br-rvd-reason FOR EACH X_ext-classif NO-LOCK where X_ext-classif.classif-subject = {&extclass_rvd-reason}
                                                                and X_ext-classif.classif-name = {&extclass_rvd-reason}
                                                                and (X_ext-classif.key#_Two = p-type or p-type = -1)
                                                                and X_ext-classif.nonuniq = 0
                                                                by X_ext-classif.nonuniq BY X_ext-classif.CharKey_One .
      end .
      reposition br-rvd-reason to recid rr.
      log-res  = br-rvd-reason:select-focused-row( ).
      apply "ENTRY":U to br-rvd-reason.
    end.
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del d-rvd-reason
ON CHOOSE OF b-del IN FRAME d-rvd-reason /* Удалить */
  DO:
    define buffer del_ext-classif for ub.ext-classif .
    
    if v-rid-list = "" then do:
      rr = recid( X_ext-classif ) .
      find first X_ext-classif exclusive-lock where recid(X_ext-classif) = rr no-error .
    end.
    else do:
      find first X_ext-classif exclusive-lock where recid(X_ext-classif) = integer(v-rid-list) no-error .
    end.
    if available (X_ext-classif)
    then do :
      create del_ext-classif .
      buffer-copy X_ext-classif to del_ext-classif
      assign
        del_ext-classif.nonuniq = 1 when X_ext-classif.nonuniq = 0
        del_ext-classif.nonuniq = 0 when X_ext-classif.nonuniq = 1
      .
      delete X_ext-classif .
    end .
    v-rid-list = "" .
    rr = ? .
    apply "ENTRY":U to br-rvd-reason.
    
    if t-del
    then do :
      OPEN QUERY br-rvd-reason FOR EACH X_ext-classif NO-LOCK where X_ext-classif.classif-subject = {&extclass_rvd-reason}
                                                              and X_ext-classif.classif-name = {&extclass_rvd-reason}
                                                              and (X_ext-classif.key#_Two = p-type or p-type = -1)
                                                              by X_ext-classif.nonuniq BY X_ext-classif.CharKey_One .
    end .
    else do :
      OPEN QUERY br-rvd-reason FOR EACH X_ext-classif NO-LOCK where X_ext-classif.classif-subject = {&extclass_rvd-reason}
                                                              and X_ext-classif.classif-name = {&extclass_rvd-reason}
                                                              and (X_ext-classif.key#_Two = p-type or p-type = -1)
                                                              and X_ext-classif.nonuniq = 0
                                                              by X_ext-classif.nonuniq BY X_ext-classif.CharKey_One .
    end .
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




&Scoped-define SELF-NAME b-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel d-rvd-reason
ON CHOOSE OF b-sel IN FRAME d-rvd-reason /* Выбор  */
  DO:
    if ( available X_ext-classif )
    AND ( v-rid-list = "" or b-mark:sensitive = no )
    then
      v-rid-list = string( recid( X_ext-classif ) ) .
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-mark d-rvd-reason
ON CHOOSE OF b-mark IN FRAME d-rvd-reason /* * */
  DO:
    define variable g-log as logical no-undo.
    if available X_ext-classif then 
    do:
      { gbl/markstrn.i X_ext-classif v-rid-list }

      g-log = {&browse-name}:refresh() .
      if last-event:function <> "mouse-select-dblclick" then 
      do:
        g-log = {&browse-name}:select-next-row ().
        apply "value-changed" to {&browse-name} in frame {&frame-name}.
      end.

    end.
    apply "entry" to {&browse-name} in frame {&frame-name}.


  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-upd
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-upd d-rvd-reason
ON CHOOSE OF b-upd IN FRAME d-rvd-reason /* Изменить */
  DO:
    define variable glog as logical no-undo .
    if not available X_ext-classif THEN  return no-apply.
    rr = recid( X_ext-classif ).
    run ref/rvd-reason_upd.w
      ( input parparentproc
      , input {&update}
      , input-output rr
      ).
    if t-del
    then do :
      OPEN QUERY br-rvd-reason FOR EACH X_ext-classif NO-LOCK where X_ext-classif.classif-subject = {&extclass_rvd-reason}
                                                              and X_ext-classif.classif-name = {&extclass_rvd-reason}
                                                              and (X_ext-classif.key#_Two = p-type or p-type = -1)
                                                              by X_ext-classif.nonuniq BY X_ext-classif.CharKey_One .
    end .
    else do :
      OPEN QUERY br-rvd-reason FOR EACH X_ext-classif NO-LOCK where X_ext-classif.classif-subject = {&extclass_rvd-reason}
                                                              and X_ext-classif.classif-name = {&extclass_rvd-reason}
                                                              and (X_ext-classif.key#_Two = p-type or p-type = -1)
                                                              and X_ext-classif.nonuniq = 0
                                                              by X_ext-classif.nonuniq BY X_ext-classif.CharKey_One .
    end .
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME t-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL t-del d-rvd-reason
ON VALUE-CHANGED OF t-del IN FRAME d-rvd-reason 
DO:
    assign
      t-del
    .
    if t-del
    then do :
      OPEN QUERY br-rvd-reason FOR EACH X_ext-classif NO-LOCK where X_ext-classif.classif-subject = {&extclass_rvd-reason}
                                                              and X_ext-classif.classif-name = {&extclass_rvd-reason}
                                                              and (X_ext-classif.key#_Two = p-type or p-type = -1)
                                                              by X_ext-classif.nonuniq BY X_ext-classif.CharKey_One .
    end .
    else do :
      OPEN QUERY br-rvd-reason FOR EACH X_ext-classif NO-LOCK where X_ext-classif.classif-subject = {&extclass_rvd-reason}
                                                              and X_ext-classif.classif-name = {&extclass_rvd-reason}
                                                              and (X_ext-classif.key#_Two = p-type or p-type = -1)
                                                              and X_ext-classif.nonuniq = 0
                                                              by X_ext-classif.nonuniq BY X_ext-classif.CharKey_One .
    end .
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
  ENABLE
    br-rvd-reason
    b-exit
    b-sel WHEN can-do( bttns, "b-sel" )
    b-mark WHEN can-do( bttns, "b-mark" )
    b-add WHEN can-do( bttns, "b-add" ) 
    b-del when can-do ( bttns, "b-del" )
    b-upd WHEN can-do( bttns, "b-upd" ) 
    WITH FRAME {&frame-name}.
  
  if p-mode = {&all}
  then do :    
    enable
      t-del
    WITH FRAME {&frame-name}.
  end .
  OPEN QUERY br-rvd-reason FOR EACH X_ext-classif NO-LOCK where X_ext-classif.classif-subject = {&extclass_rvd-reason}
                                                            and X_ext-classif.classif-name = {&extclass_rvd-reason}
                                                            and (X_ext-classif.key#_Two = p-type or p-type = -1)
                                                            and X_ext-classif.nonuniq = 0
                                                            by X_ext-classif.nonuniq by X_ext-classif.CharKey_One .
  
  if available X_ext-classif
    then log-res  = br-rvd-reason:select-focused-row( ).
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

