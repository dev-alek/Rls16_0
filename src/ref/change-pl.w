&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME d-place


/* Temp-Table and Buffer definitions                                    */
/*DEFINE TEMP-TABLE tt-place NO-UNDO LIKE place*/
/*       field obj-name as character           */
/*       field mark as character.              */



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS d-place 
/*------------------------------------------------------------------------

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список активных резервуаров

Автор: Шкляр Елена
Дата создания: 20/04/95
Author: Shklyar Elena
Creation date: 20/04/95
------------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter  parparentproc as widget-handle no-undo .
define output parameter p-rid-list as character no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Список активных резервуаров".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/library.i }
{ cmp/showinf.i }
{ gbl/cur-time.i }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ gbl/waitfram.i }
{ cmp/mrk-strf.i }
{ cmp/r-page1.i }

/* Local Variable Definitions ---                                       */
      
define variable row_place  as recid     no-undo .
define variable v-rid-list as character no-undo .
define buffer tt-place for ub.place .
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME d-place
&Scoped-define BROWSE-NAME br-pl

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES obj-list tt-place 

/* Definitions for BROWSE br-pl                                         */
&Scoped-define FIELDS-IN-QUERY-br-pl mark-string( input recid(tt-place), input v-rid-list) tt-place.obj-code  ~
obj-name(input tt-place.obj-code, input tt-place.obj-type) tt-place.pl-code tt-place.loc1 tt-place.pl-name 
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-pl 
&Scoped-define SELF-NAME br-pl
&Scoped-define QUERY-STRING-br-pl FOR EACH obj-list no-lock, ~
                                      each tt-place where tt-place.obj-code = obj-list.obj-code and tt-place.obj-type = obj-list.obj-type NO-LOCK
&Scoped-define OPEN-QUERY-br-pl OPEN QUERY {&SELF-NAME} FOR EACH                           obj-list NO-LOCK, ~
                                 EACH tt-place WHERE                           tt-place.obj-code = obj-list.obj-code and                           tt-place.obj-type = obj-list.obj-type                           NO-LOCK.
&Scoped-define TABLES-IN-QUERY-br-pl obj-list tt-place 
&Scoped-define FIRST-TABLE-IN-QUERY-br-pl obj-list
&Scoped-define SECOND-TABLE-IN-QUERY-br-pl tt-place 
 
/* Definitions for DIALOG-BOX d-place                                   */
&Scoped-define OPEN-BROWSERS-IN-QUERY-d-place ~
    ~{&OPEN-QUERY-br-pl}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-sel b-mark br-pl 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD obj-name d-place 
FUNCTION obj-name RETURNS CHARACTER
  ( input p-obj-code as integer, input p-obj-type as character )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-exit AUTO-GO 
  LABEL "&Выход ":L 
  SIZE 10 BY 1.

DEFINE BUTTON b-mark 
  LABEL "&*" 
  SIZE 3 BY 1.

DEFINE BUTTON b-sel AUTO-GO 
  LABEL "&Выбор":L 
  SIZE 10 BY 1.

DEFINE BUTTON bt-not-sel-all 
  LABEL "+" 
  SIZE 3 BY 1 TOOLTIP "Выбрать все".

DEFINE BUTTON bt-not-sel-desel-all 
  LABEL "-" 
  SIZE 3 BY 1 TOOLTIP "Отменить выбор".

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-pl FOR 
  obj-list,
  tt-place SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-pl
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-pl d-place _STRUCTURED
  QUERY br-pl NO-LOCK DISPLAY
  mark-string( input recid(tt-place), input v-rid-list) column-label "*" format "X(1)":U
  tt-place.obj-code COLUMN-LABEL "Код объекта" FORMAT "9999999999":U
  WIDTH 11.25
  obj-name(input tt-place.obj-code, input tt-place.obj-type) COLUMN-LABEL "Наименование объекта" FORMAT "X(256)":U
  WIDTH 21
  tt-place.pl-code COLUMN-LABEL "Код резервуара" FORMAT "999999999999999":U
  WIDTH 17
  tt-place.loc1 FORMAT "X(8)":U WIDTH 22
  tt-place.pl-name COLUMN-LABEL "Наименование резервуара" FORMAT "X(40)":U
  WIDTH 54.88
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 131 BY 16.5 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME d-place
  b-exit AT ROW 1 COL 1.63 WIDGET-ID 2
  b-sel AT ROW 1 COL 11.38 WIDGET-ID 302
  bt-not-sel-all AT ROW 2.25 COL 1.63 WIDGET-ID 10 NO-TAB-STOP 
  bt-not-sel-desel-all AT ROW 2.25 COL 4.63 WIDGET-ID 12 NO-TAB-STOP 
  b-mark AT ROW 2.25 COL 7.63 WIDGET-ID 4 NO-TAB-STOP 
  br-pl AT ROW 3.25 COL 1.25 WIDGET-ID 200
  SPACE(0.00) SKIP(0.32)
  WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
  SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
  TITLE "Список активных резервуаров" WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
   Other Settings: COMPILE
   Temp-Tables and Buffers:
      TABLE: tt-place T "?" NO-UNDO ub place
      ADDITIONAL-FIELDS:
          field obj-name as character
      END-FIELDS.
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX d-place
   FRAME-NAME                                                           */
/* BROWSE-TAB br-pl b-mark d-place */
ASSIGN 
  FRAME d-place:SCROLLABLE = FALSE
  FRAME d-place:HIDDEN     = TRUE.

ASSIGN 
  br-pl:COLUMN-RESIZABLE IN FRAME d-place = TRUE.

/* SETTINGS FOR BUTTON bt-not-sel-all IN FRAME d-place
   NO-ENABLE                                                            */
/* SETTINGS FOR BUTTON bt-not-sel-desel-all IN FRAME d-place
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-pl
/* Query rebuild information for BROWSE br-pl
     _TblList          = "Temp-Tables.tt-place"
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _FldNameList[1]   > Temp-Tables.tt-place.obj-code
"obj-code" "Код объекта" "9999999999" "integer" ? ? ? ? ? ? no ? no no "11.25" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[2]   > Temp-Tables.tt-place.obj-type
"obj-type" "Наименование объекта" "X(256)" "character" ? ? ? ? ? ? no ? no no "21" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[3]   > Temp-Tables.tt-place.pl-code
"pl-code" "Код резервуара" "999999999999999" "integer" ? ? ? ? ? ? no ? no no "17" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[4]   > Temp-Tables.tt-place.loc1
"loc1" ? ? "character" ? ? ? ? ? ? no ? no no "22" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[5]   > Temp-Tables.tt-place.pl-name
"pl-name" "Наименование резервуара" ? "character" ? ? ? ? ? ? no ? no no "54.88" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _Query            is OPENED
*/  /* BROWSE br-pl */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME d-place
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL d-place d-place
ON WINDOW-CLOSE OF FRAME d-place /* Список активных резервуаров */
  DO:
    APPLY "END-ERROR":U TO SELF.
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-mark d-place
ON CHOOSE OF b-mark IN FRAME d-place /* * */
  DO:
    define variable loc#log as logical no-undo .
      
    if available tt-place then 
    do:
      { gbl/markstrn.i tt-place v-rid-list }
      row_place = recid(tt-place).
      loc#log = {&browse-name}:refresh() .
      reposition br-pl to recid row_place no-error.

      if last-event:function <> "MOUSE-SELECT-DBLCLICK" then 
      do:
        loc#log = {&browse-name}:select-next-row ().
        apply "VALUE-CHANGED" to {&browse-name} in frame {&frame-name}.
      end.
    end.
    apply "entry" to {&browse-name} in frame {&frame-name}.

  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel d-place
ON CHOOSE OF b-sel IN FRAME d-place /* Выбор */
  DO:
    define buffer buf_place for ub.place .

    define variable vv       as integer   no-undo .
    define variable rid-list as character no-undo .

    if v-rid-list = "" then 
    do:
      if available (tt-place) then 
      do:
        v-rid-list = string(recid(tt-place)) .
      end.  
    end.
    p-rid-list = v-rid-list .
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-not-sel-all
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-not-sel-all d-place
ON CHOOSE OF bt-not-sel-all IN FRAME d-place /* + */
  DO:
    define variable loc#log as logical no-undo .

    if available tt-place then 
    do:
      v-rid-list = "" .
      for each tt-place no-lock:
            { gbl/markstrn.i tt-place v-rid-list }
        loc#log = {&browse-name}:refresh() .
      end.
    end.
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-not-sel-desel-all
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-not-sel-desel-all d-place
ON CHOOSE OF bt-not-sel-desel-all IN FRAME d-place /* - */
  DO:
    define variable loc#log as logical no-undo .
    v-rid-list = "" .
    loc#log = {&browse-name}:refresh() .
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-pl
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK d-place 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
  THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
  ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  { gbl/brwrepos.i
  &line-num= 9
}

  RUN enable_UI.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI d-place  _DEFAULT-DISABLE
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
  HIDE FRAME d-place.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI d-place  _DEFAULT-ENABLE
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
  ENABLE b-exit b-sel b-mark br-pl bt-not-sel-desel-all bt-not-sel-all
    WITH FRAME d-place.
  VIEW FRAME d-place.
  {&OPEN-BROWSERS-IN-QUERY-d-place}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION obj-name d-place 
FUNCTION obj-name RETURNS CHARACTER
  ( input p-obj-code as integer,
  input p-obj-type as character ) :
  /*------------------------------------------------------------------------------
    Purpose:  
      Notes:  
  ------------------------------------------------------------------------------*/
  find first ub.clients no-lock where ub.clients.obj-code = p-obj-code and
    ub.clients.obj-type = p-obj-type no-error .
  if available (ub.clients) then return ub.clients.obj-name .
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


