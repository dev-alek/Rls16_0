&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
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


def input param parParentProc as Widget-handle no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Список Путевых листов. Документы->Путевые листы".

{ str/travel-sheets-inc.i }
{ str/travel-sheets-inc2.i }
{ ref/dc-prop.i }
{ cmp/vssrevis.i }
{ cmp/showinf.i }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BROWSE-refills

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES cd-doc-line cd-doc

/* Definitions for BROWSE BROWSE-refills                                */
&Scoped-define FIELDS-IN-QUERY-BROWSE-refills cd-doc-line.CharKey_Two ~
get-refill-str-stat() cd-doc-line.CharKey_Three cd-doc-line.DecKey_One 
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-refills 
&Scoped-define QUERY-STRING-BROWSE-refills FOR EACH cd-doc-line NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BROWSE-refills OPEN QUERY BROWSE-refills FOR EACH cd-doc-line NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BROWSE-refills cd-doc-line
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-refills cd-doc-line


/* Definitions for BROWSE BROWSE-tsheets                                */
&Scoped-define FIELDS-IN-QUERY-BROWSE-tsheets cd-doc.CharKey_One ~
get-ts-str-stat() cd-doc.datekey_one cd-doc.CharKey_Two get-car-mark() ~
get-car-num() cd-doc.DecKey_One cd-doc.DecKey_Two cd-doc.DecKey_Three 
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-tsheets 
&Scoped-define QUERY-STRING-BROWSE-tsheets FOR EACH cd-doc ~
      WHERE cd-doc.doc-type = {&travel-sheet} NO-LOCK ~
    BY cd-doc.DecKey_One DESCENDING INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BROWSE-tsheets OPEN QUERY BROWSE-tsheets FOR EACH cd-doc ~
      WHERE cd-doc.doc-type = {&travel-sheet} NO-LOCK ~
    BY cd-doc.DecKey_One DESCENDING INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BROWSE-tsheets cd-doc
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-tsheets cd-doc


/* Definitions for DIALOG-BOX Dialog-Frame                              */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS Btn_exit BROWSE-tsheets BROWSE-refills ~
Btn_add Btn_edit Btn_remove Btn_fact 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-car-mark Dialog-Frame 
FUNCTION get-car-mark RETURNS CHARACTER
  ( )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-car-num Dialog-Frame 
FUNCTION get-car-num RETURNS CHARACTER
  ( )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-refill-str-stat Dialog-Frame 
FUNCTION get-refill-str-stat RETURNS CHARACTER
  (  )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-ts-str-stat Dialog-Frame 
FUNCTION get-ts-str-stat RETURNS CHARACTER
  ( )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON Btn_add 
     LABEL "Добавить" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON Btn_edit 
     LABEL "Изменить" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON Btn_exit AUTO-GO 
     LABEL "Выход" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON Btn_fact 
     LABEL "Ввести факт" 
     SIZE 12 BY 1
     BGCOLOR 8 .

DEFINE BUTTON Btn_remove 
     LABEL "Удалить" 
     SIZE 10 BY 1
     BGCOLOR 8 .

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BROWSE-refills FOR 
      cd-doc-line SCROLLING.

DEFINE QUERY BROWSE-tsheets FOR 
      cd-doc SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BROWSE-refills
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-refills Dialog-Frame _STRUCTURED
  QUERY BROWSE-refills NO-LOCK DISPLAY
      cd-doc-line.CharKey_Two COLUMN-LABEL "Номер RFN" FORMAT "X(12)":U
            WIDTH 30
      get-refill-str-stat() COLUMN-LABEL "Статус" WIDTH 30
      cd-doc-line.CharKey_Three COLUMN-LABEL "Номер чека" FORMAT "X(12)":U
            WIDTH 30
      cd-doc-line.DecKey_One COLUMN-LABEL "Объем" FORMAT "->>,>>9.99":U
            WIDTH 30
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 122 BY 11.43
         TITLE "Заправки" FIT-LAST-COLUMN.

DEFINE BROWSE BROWSE-tsheets
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-tsheets Dialog-Frame _STRUCTURED
  QUERY BROWSE-tsheets NO-LOCK DISPLAY
      cd-doc.CharKey_One COLUMN-LABEL "Номер ПЛ" FORMAT "X(20)":U
      get-ts-str-stat() COLUMN-LABEL "Статус" WIDTH 10
      cd-doc.datekey_one COLUMN-LABEL "Дата" FORMAT "99/99/9999":U
      cd-doc.CharKey_Two COLUMN-LABEL "Код!машины" FORMAT "X(12)":U
      get-car-mark() COLUMN-LABEL "Марка!машины" WIDTH 11
      get-car-num() COLUMN-LABEL "Номер!машины" WIDTH 11
      cd-doc.DecKey_One COLUMN-LABEL "Разрешенный!объем" FORMAT "->>,>>9.99":U
            WIDTH 13
      cd-doc.DecKey_Two COLUMN-LABEL "Фактический!объем" FORMAT "->>,>>9.99":U
            WIDTH 13
      cd-doc.DecKey_Three COLUMN-LABEL "Заблокированный! к наливу объем" FORMAT "->>,>>9.99":U
            WIDTH 12.6
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 122 BY 11.19
         TITLE "Путевые листы" FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     Btn_exit AT ROW 1 COL 2
     BROWSE-tsheets AT ROW 2.19 COL 2 WIDGET-ID 200
     BROWSE-refills AT ROW 13.38 COL 2 WIDGET-ID 300
     Btn_add AT ROW 1 COL 13 WIDGET-ID 2
     Btn_edit AT ROW 1 COL 23 WIDGET-ID 4
     Btn_remove AT ROW 1 COL 33 WIDGET-ID 6
     Btn_fact AT ROW 1 COL 43 WIDGET-ID 8
     SPACE(69.79) SKIP(23.04)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Путевые листы"
         DEFAULT-BUTTON Btn_exit WIDGET-ID 100.


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
   FRAME-NAME L-To-R,COLUMNS                                            */
/* BROWSE-TAB BROWSE-tsheets Btn_exit Dialog-Frame */
/* BROWSE-TAB BROWSE-refills BROWSE-tsheets Dialog-Frame */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-refills
/* Query rebuild information for BROWSE BROWSE-refills
     _TblList          = "ub.cd-doc-line"
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _FldNameList[1]   > ub.cd-doc-line.CharKey_Two
"cd-doc-line.CharKey_Two" "Номер RFN" ? "character" ? ? ? ? ? ? no ? no no "30" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[2]   > "_<CALC>"
"get-refill-str-stat()" "Статус" ? ? ? ? ? ? ? ? no ? no no "30" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[3]   > ub.cd-doc-line.CharKey_Three
"cd-doc-line.CharKey_Three" "Номер чека" ? "character" ? ? ? ? ? ? no ? no no "30" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[4]   > ub.cd-doc-line.DecKey_One
"cd-doc-line.DecKey_One" "Объем" ? "decimal" ? ? ? ? ? ? no ? no no "25.2" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _Query            is NOT OPENED
*/  /* BROWSE BROWSE-refills */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-tsheets
/* Query rebuild information for BROWSE BROWSE-tsheets
     _TblList          = "ub.cd-doc"
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _OrdList          = "ub.cd-doc.DecKey_One|no"
     _Where[1]         = "cd-doc.doc-type = {&travel-sheet}"
     _FldNameList[1]   > ub.cd-doc.CharKey_One
"CharKey_One" "Номер ПЛ" "X(20)" "character" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[2]   > "_<CALC>"
"get-ts-str-stat()" "Статус" ? ? ? ? ? ? ? ? no ? no no "10" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[3]   > ub.cd-doc.datekey_one
"datekey_one" "Дата" ? "date" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[4]   > ub.cd-doc.CharKey_Two
"CharKey_Two" "Код!машины" ? "character" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[5]   > "_<CALC>"
"get-car-mark()" "Марка!машины" ? ? ? ? ? ? ? ? no ? no no "11" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[6]   > "_<CALC>"
"get-car-num()" "Номер!машины" ? ? ? ? ? ? ? ? no ? no no "11" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[7]   > ub.cd-doc.DecKey_One
"DecKey_One" "Разрешенный!объем" ? "decimal" ? ? ? ? ? ? no ? no no "13" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[8]   > ub.cd-doc.DecKey_Two
"DecKey_Two" "Фактический!объем" ? "decimal" ? ? ? ? ? ? no ? no no "13" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[9]   > ub.cd-doc.DecKey_Three
"DecKey_Three" "Заблокированный! к наливу объем" ? "decimal" ? ? ? ? ? ? no ? no no "9.6" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _Query            is NOT OPENED
*/  /* BROWSE BROWSE-tsheets */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _Options          = "SHARE-LOCK"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Путевые листы */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-tsheets
&Scoped-define SELF-NAME BROWSE-tsheets
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-tsheets Dialog-Frame
ON VALUE-CHANGED OF BROWSE-tsheets IN FRAME Dialog-Frame /* Путевые листы */
DO:
  run open-cd-doc-line.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_add Dialog-Frame
ON CHOOSE OF Btn_add IN FRAME Dialog-Frame /* Добавить */
DO:
    def var res as logical no-undo.
    def var rid as recid no-undo init 0.

    run str/travel-sheet-edit.w(parParentProc, {&add-def}, output res, input-output rid).

    if res then
        run open-cd-doc.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_edit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_edit Dialog-Frame
ON CHOOSE OF Btn_edit IN FRAME Dialog-Frame /* Изменить */
DO:
      def var res as logical no-undo.
      def var rid as recid no-undo.

      if not avail ub.cd-doc then do:
          message "Не выбран путевой лист" view-as alert-box.
          return.
      end.

      rid = recid(ub.cd-doc).

      run str/travel-sheet-edit.w(parParentProc, {&update}, output res, input-output rid).

      if res then
           run open-cd-doc.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_fact
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_fact Dialog-Frame
ON CHOOSE OF Btn_fact IN FRAME Dialog-Frame /* Ввести факт */
DO:
    def var rid as recid no-undo.
    def var ret-stat as logical no-undo.

    if not avail ub.cd-doc then do:
        message "Не выбран путевой лист" view-as alert-box.
        return.
    end.

    if ub.cd-doc.Key#_One = 1 then do:
        message "Путевой лист закрыт" view-as alert-box.
        return.
    end.

    rid = recid(ub.cd-doc).
    run str/travel-sheet-line-add.w(parparentproc, rid, output ret-stat).

    if ret-stat then do:
        run open-cd-doc-line.
        browse-tsheets:REFRESH().
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_remove
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_remove Dialog-Frame
ON CHOOSE OF Btn_remove IN FRAME Dialog-Frame /* Удалить */
DO:
  def var ret-stat as logical no-undo.

  if not avail ub.cd-doc then do:
      message "Не выбран путевой лист" view-as alert-box.
      return.
  end.

  message "Удалить выбранный путевой лист?" view-as alert-box question buttons yes-no update confirm as logical.

  if not confirm then return.

  run delete-travel-sheet(recid(ub.cd-doc)) no-error.

  if error-status:ERROR then
    message return-value view-as alert-box.
  else
    run open-cd-doc.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-refills
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
  run my-init.
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
  ENABLE Btn_exit BROWSE-tsheets BROWSE-refills Btn_add Btn_edit Btn_remove 
         Btn_fact 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-init Dialog-Frame 
PROCEDURE my-init :
run open-cd-doc.
apply "VALUE-CHANGED" to BROWSE-tsheets in frame {&frame-name}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE open-cd-doc Dialog-Frame 
PROCEDURE open-cd-doc :
open query BROWSE-tsheets
        for each ub.cd-doc
            where ub.cd-doc.doc-type = {&travel-sheet}
            and ub.cd-doc.obj-type = v-cntxt-obj-type
            and ub.cd-doc.obj-code = v-cntxt-obj-code
            BY cd-doc.DecKey_One DESCENDING.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE open-cd-doc-line Dialog-Frame 
PROCEDURE open-cd-doc-line :
open query BROWSE-refills
        for each ub.cd-doc-line
            where ub.cd-doc-line.doc-type = {&travel-sheet}
            and ub.cd-doc-line.doc-code = ub.cd-doc.doc-code
            and ub.cd-doc-line.obj-type = v-cntxt-obj-type
            and ub.cd-doc-line.obj-code = v-cntxt-obj-code.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-car-mark Dialog-Frame 
FUNCTION get-car-mark RETURNS CHARACTER
  ( ) :
    find first ub.dis-card-property no-lock
        where ub.dis-card-property.d-card = ub.cd-doc.CharKey_Two
        and ub.dis-card-property.dtm-code = {&dc-prop_easyfuel2}
        and ub.dis-card-property.node-code = {&dc_prop_easyfuel2_car-brand}
        no-error.

        return
            (if avail ub.dis-card-property then ub.dis-card-property.property-value-character else "").

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-car-num Dialog-Frame 
FUNCTION get-car-num RETURNS CHARACTER
  ( ) :
    find first ub.dis-card-property no-lock
        where ub.dis-card-property.d-card = ub.cd-doc.CharKey_Two
        and ub.dis-card-property.dtm-code = {&dc-prop_easyfuel2}
        and ub.dis-card-property.node-code = {&dc_prop_easyfuel2_car-reg-number}
        no-error.

        return
            (if avail ub.dis-card-property then ub.dis-card-property.property-value-character else "").
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-refill-str-stat Dialog-Frame 
FUNCTION get-refill-str-stat RETURNS CHARACTER
  (  ) :
    return ( if ub.cd-doc-line.Key#_One > 0 then "Факт" else "Зарезерв" ).

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-ts-str-stat Dialog-Frame 
FUNCTION get-ts-str-stat RETURNS CHARACTER
  ( ) :
    return ( if ub.cd-doc.Key#_One > 0 then "Факт" else "Новый" ).
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

