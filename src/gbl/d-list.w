&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE temp-sel NO-UNDO LIKE ub.clients-attr
       field attr-label as character format "X(30)"
       field line-num as integer
       index pi is primary unique
       line-num.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Форма выбора из неизвестного количества опций

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/20/06
Author: Bakhtadze Natalya
Creation date: 03/20/06

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER bttns as character no-undo.
/*какие кнопки высвечивать b-sel b-mark*/
DEFINE INPUT PARAMETER ptitle as character no-undo.
DEFINE INPUT PARAMETER pattr-codes as character no-undo.
/*список*/
DEFINE INPUT PARAMETER pattr-labels as character no-undo.
/*список*/
DEFINE INPUT PARAMETER pdelim as character no-undo.
/*разделитель*/
DEFINE INPUT PARAMETER ppresel-codes as character no-undo.
/*перечень уже выбранных*/
DEFINE OUTPUT PARAMETER psel-codes as character no-undo.
/*список*/

/* Local Variable Definitions ---                                       */
def var vss-revision    as character no-undo init "$Revision$":u .
def var vss-author      as character no-undo init "$Author$":u .
def var vss-date        as character no-undo init "$Date$":u .
def var vss-workfile    as character no-undo init "$Workfile$":u .
def var vss-archive     as character no-undo init "$Archive$":u .
def var vss-description as character no-undo init "Форма выбора из неизвестного количества опций" .
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/showinf.i  }

define variable rid-list as character no-undo.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-list

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES temp-sel

/* Definitions for BROWSE BR-list                                       */
&Scoped-define FIELDS-IN-QUERY-BR-list ~
(IF ( CAN-DO (rid-list, string( recid( temp-sel ) ) ) ) THEN ("*") ELSE (" ")) ~
temp-sel.attr-label
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-list
&Scoped-define QUERY-STRING-BR-list FOR EACH temp-sel NO-LOCK
&Scoped-define OPEN-QUERY-BR-list OPEN QUERY BR-list FOR EACH temp-sel NO-LOCK.
&Scoped-define TABLES-IN-QUERY-BR-list temp-sel
&Scoped-define FIRST-TABLE-IN-QUERY-BR-list temp-sel


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BR-list}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-mark B-sel B-Help BR-list mark-num
&Scoped-Define DISPLAYED-OBJECTS mark-num

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-mark
     LABEL "&*"
     SIZE 4 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-sel AUTO-GO
     LABEL "Вы&бор"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE mark-num AS INTEGER FORMAT ">>9":U INITIAL 0
      VIEW-AS TEXT
     SIZE 5 BY 1
     FGCOLOR 4  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-list FOR
      temp-sel SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-list
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-list Dialog-Frame _STRUCTURED
  QUERY BR-list DISPLAY
      (IF ( CAN-DO (rid-list, string( recid( temp-sel ) ) ) ) THEN ("*") ELSE (" ")) COLUMN-LABEL "*" FORMAT "X(1)":U
      temp-sel.attr-label COLUMN-LABEL "Выбор" FORMAT "X(80)":U
            WIDTH 80
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 84.5 BY 19.43.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 11
     B-sel AT ROW 1 COL 21
     B-Help AT ROW 1 COL 75
     BR-list AT ROW 2.83 COL 1
     mark-num AT ROW 1 COL 13.8 COLON-ALIGNED NO-LABEL
     SPACE(66.29) SKIP(20.49)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "<insert dialog title>"
         DEFAULT-BUTTON B-sel CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: temp-sel T "?" NO-UNDO ub clients-attr
      ADDITIONAL-FIELDS:
          field attr-label as character format "X(30)"
          field line-num as integer
          index pi is primary unique
          line-num
      END-FIELDS.
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BR-list B-Help Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-list
/* Query rebuild information for BROWSE BR-list
     _TblList          = "Temp-Tables.temp-sel"
     _FldNameList[1]   > "_<CALC>"
"(IF ( CAN-DO (rid-list, string( recid( temp-sel ) ) ) ) THEN (""*"") ELSE ("" ""))" "*" "X(1)" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[2]   > "_<CALC>"
"temp-sel.attr-label" "Выбор" "X(80)" ? ? ? ? ? ? ? no ? no no "80" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _Query            is OPENED
*/  /* BROWSE BR-list */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* <insert dialog title> */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* * */
DO:
  run proc-b-mark no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sel Dialog-Frame
ON CHOOSE OF B-sel IN FRAME Dialog-Frame /* Выбор */
DO:
  if rid-list = "" then  do:
    if available temp-sel then
      rid-list = string( recid( temp-sel ) ) .
  end.
  else do:
    if not b-mark:sensitive in frame {&frame-name} then do:
      rid-list = string( recid( temp-sel ) ) .
    end.
  end.
  Run fill-parameter(input pdelim,
                     output psel-codes) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-list
&Scoped-define SELF-NAME BR-list
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-list Dialog-Frame
ON LEFT-MOUSE-DBLCLICK OF BR-list IN FRAME Dialog-Frame
DO:
   if lookup("b-mark":U, bttns) > 0 then do:
      run proc-b-mark no-error.
      if error-status:error then return no-apply.
   end.
   else do:
      APPLY "CHOOSE" to b-sel.
   end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-list Dialog-Frame
ON RETURN OF BR-list IN FRAME Dialog-Frame
DO:
   if lookup("b-mark":U, bttns) > 0 then do:
      run proc-b-mark no-error.
      if error-status:error then return no-apply.
   end.
   else do:
      APPLY "CHOOSE" to b-sel.
   end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/app_help.i }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

  run fill-table(pattr-codes, pattr-labels, pdelim) no-error.
  if error-status:error then return.
  RUN MyEnable.
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
  DISPLAY mark-num
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-mark B-sel B-Help BR-list mark-num
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-parameter Dialog-Frame
PROCEDURE fill-parameter :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE INPUT PARAMETER loc-delim as character no-undo.
DEFINE OUTPUT PARAMETER loc-attr-codes as chAracter no-undo.
DEFINE BUFFER loc-temp-sel for temp-sel.
DEFINE VAR ii as integer no-undo.

DO II = 1 to num-entries(rid-list):
    FIND FIRST loc-temp-sel where
               recid(loc-temp-sel) = integer(entry(ii, rid-list)) No-error.
    if avail temp-sel then
    loc-attr-codes = loc-attr-codes + (if loc-attr-codes = "" then "" else loc-delim) +
                     loc-temp-sel.attr-code.
end.



END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-table Dialog-Frame
PROCEDURE fill-table :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE INPUT PARAMETER loc-attr-codes as character no-undo.
DEFINE INPUT PARAMETER loc-attr-labels as character no-undo.
DEFINE INPUT PARAMETER loc-delim as character no-undo.

def var ii as integer no-undo.

if num-entries(loc-attr-codes, loc-delim) <> num-entries(loc-attr-labels, loc-delim) then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неправильный вызов программы d-list.w" skip
    "параметр pattr-codes и параметр pattr-labels имют разное количество элементов списка"
    view-as alert-box error.
    return error.
end.

for each temp-sel:
delete temp-sel.
end.

do ii = 1 to num-entries(loc-attr-codes, loc-delim):
if entry(ii, loc-attr-codes, loc-delim) = "" then NEXT.
create temp-sel.
assign
temp-sel.attr-code = entry(ii, loc-attr-codes, loc-delim)
temp-sel.attr-label = entry(ii, loc-attr-labels, loc-delim)
temp-sel.line-num = ii
.
If lookup(temp-sel.attr-code, ppresel-codes) > 0 then do:
  rid-list = rid-list + (if rid-list = "":U then "":U else {&comma-char} ) + string(recid(temp-sel)).
end.

end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
ENABLE
b-quit
B-mark when lookup("b-mark", bttns) > 0
B-sel when lookup("b-sel", bttns) > 0
B-Help BR-list
WITH FRAME {&frame-name}.
frame {&frame-name}:title = ptitle.
  VIEW FRAME {&frame-name}.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
  APPLY "entry" to br-list in frame {&frame-name}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-mark Dialog-Frame
PROCEDURE proc-b-mark :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
def var loc#log as logical no-undo.
  if available temp-sel then do:
    { gbl/markstrn.i temp-sel rid-list }
    loc#log = br-list:refresh() in frame {&frame-name}.
    if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
        loc#log = br-List:select-next-row ().
        apply "iteration-changed" to br-List in frame {&frame-name}.
    end.
    if num-entries( rid-list ) = 0 then
        hide mark-num in frame {&frame-name}.
    else
        disp num-entries( rid-list ) @ mark-num with frame {&frame-name}.
    end.
    apply "entry" to br-List in frame {&frame-name}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME