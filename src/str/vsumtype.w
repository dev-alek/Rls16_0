&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame

/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE tt-sum NO-UNDO LIKE ub.trn-doc-sum.


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Суммы по документу

Автор: Чернова Светлана Александровна
Дата создания: 09/12/07
Author: Svetlana Chernova
Creation date: 09/12/07

Автор1: Суслов Алексей Юрьевич
Дата создания: 03/24/06


*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter paris-doc      as logical no-undo.
define input parameter pardoc-code like ub.trn-doc.doc-code no-undo.
define input parameter pargds-code like ub.goods.gds-code no-undo.
define variable varvalue        as character no-undo.
define variable vartype         as character no-undo.
define variable rdtaxname       as character no-undo.


/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Суммы по документу".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i }
{ gbl/tax-name.i }
{ str/trdcalib.i }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BROWSE-1

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-sum

/* Definitions for BROWSE BROWSE-1                                      */
&Scoped-define FIELDS-IN-QUERY-BROWSE-1 fname-sum-type (buffer tt-sum) ~
tt-sum.fact-qnty tt-sum.crsa-sum-base tt-sum.crsa-sum-rubl ~
tt-sum.crsa-discnt-base tt-sum.crsa-discnt-rubl tt-sum.crsa-VAT-base ~
tt-sum.crsa-VAT-rubl tt-sum.crsa-SLT-base tt-sum.crsa-SLT-rubl ~
tt-sum.crsa-road-tax-base tt-sum.crsa-road-tax-rubl tt-sum.crsa-excise-base ~
tt-sum.crsa-excise-rubl tt-sum.cost-sum-base tt-sum.cost-sum-rubl ~
tt-sum.cost-VAT-base tt-sum.cost-VAT-rubl tt-sum.cost-SLT-base ~
tt-sum.cost-SLT-rubl tt-sum.cost-road-tax-base tt-sum.cost-road-tax-rubl ~
tt-sum.cost-transport-base tt-sum.cost-transport-rubl ~
tt-sum.cost-other-base tt-sum.cost-other-rubl tt-sum.cost-excise-base ~
tt-sum.cost-excise-rubl tt-sum.sale-sum-base tt-sum.sale-sum-rubl ~
tt-sum.sale-discnt-base tt-sum.sale-discnt-rubl tt-sum.sale-VAT-base ~
tt-sum.sale-VAT-rubl tt-sum.sale-SLT-base tt-sum.sale-SLT-rubl ~
tt-sum.sale-road-tax-base tt-sum.sale-road-tax-rubl tt-sum.sale-excise-base ~
tt-sum.sale-excise-rubl tt-sum.sale-transport-base ~
tt-sum.sale-transport-rubl tt-sum.sale-other-base tt-sum.sale-other-rubl
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-1
&Scoped-define QUERY-STRING-BROWSE-1 FOR EACH tt-sum NO-LOCK
&Scoped-define OPEN-QUERY-BROWSE-1 OPEN QUERY BROWSE-1 FOR EACH tt-sum NO-LOCK.
&Scoped-define TABLES-IN-QUERY-BROWSE-1 tt-sum
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-1 tt-sum


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BROWSE-1}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-help BROWSE-1

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD fname-sum-type Dialog-Frame
FUNCTION fname-sum-type RETURNS CHARACTER
  ( buffer local-tt-sum for tt-sum )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-exit AUTO-GO
  LABEL "&Выход"
  SIZE 10 BY 1
  BGCOLOR 8 .

DEFINE BUTTON b-help
  LABEL "&Помощь"
  SIZE 10 BY 1
  BGCOLOR 8 .

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BROWSE-1 FOR
  tt-sum SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BROWSE-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-1 Dialog-Frame _STRUCTURED
  QUERY BROWSE-1 DISPLAY
  fname-sum-type (buffer tt-sum) COLUMN-LABEL "Тип суммы" FORMAT "x(39)":U
  tt-sum.fact-qnty FORMAT "->>>,>>>,>>>,>>9.999":U
  tt-sum.crsa-sum-base FORMAT "->>>,>>>,>>>,>>9.99":U
  tt-sum.crsa-sum-rubl FORMAT "->>>,>>>,>>>,>>9.99":U
  tt-sum.crsa-discnt-base FORMAT "->>>,>>>,>>>,>>9.99":U
  tt-sum.crsa-discnt-rubl FORMAT "->>>,>>>,>>>,>>9.99":U
  tt-sum.crsa-VAT-base FORMAT "->>>,>>>,>>>,>>9.99":U
  tt-sum.crsa-VAT-rubl FORMAT "->>>,>>>,>>>,>>9.99":U
  tt-sum.crsa-SLT-base FORMAT "->>>,>>>,>>>,>>9.99":U
  tt-sum.crsa-SLT-rubl FORMAT "->>>,>>>,>>>,>>9.99":U
  tt-sum.crsa-road-tax-base FORMAT "->>>,>>>,>>>,>>9.99":U
  tt-sum.crsa-road-tax-rubl FORMAT "->>>,>>>,>>>,>>9.99":U
  tt-sum.crsa-excise-base FORMAT "->>>,>>>,>>>,>>9.99":U
  tt-sum.crsa-excise-rubl FORMAT "->>>,>>>,>>>,>>9.99":U
  tt-sum.cost-sum-base FORMAT "->>>,>>>,>>>,>>9.99":U
  tt-sum.cost-sum-rubl FORMAT "->>>,>>>,>>>,>>9.99":U
  tt-sum.cost-VAT-base FORMAT "->>>,>>>,>>>,>>9.99":U
  tt-sum.cost-VAT-rubl FORMAT "->>>,>>>,>>>,>>9.99":U
  tt-sum.cost-SLT-base FORMAT "->>>,>>>,>>>,>>9.99":U
  tt-sum.cost-SLT-rubl FORMAT "->>>,>>>,>>>,>>9.99":U
  tt-sum.cost-road-tax-base FORMAT "->>>,>>>,>>>,>>9.99":U
  tt-sum.cost-road-tax-rubl FORMAT "->>>,>>>,>>>,>>9.99":U
  tt-sum.cost-transport-base FORMAT "->>>,>>>,>>>,>>9.99":U
  tt-sum.cost-transport-rubl FORMAT "->>>,>>>,>>>,>>9.99":U
  tt-sum.cost-other-base FORMAT "->>>,>>>,>>>,>>9.99":U
  tt-sum.cost-other-rubl FORMAT "->>>,>>>,>>>,>>9.99":U
  tt-sum.cost-excise-base FORMAT "->>>,>>>,>>>,>>9.99":U
  tt-sum.cost-excise-rubl FORMAT "->>>,>>>,>>>,>>9.99":U
  tt-sum.sale-sum-base FORMAT "->>>,>>>,>>>,>>9.99":U
  tt-sum.sale-sum-rubl FORMAT "->>>,>>>,>>>,>>9.99":U
  tt-sum.sale-discnt-base FORMAT "->>>,>>>,>>>,>>9.99":U
  tt-sum.sale-discnt-rubl FORMAT "->>>,>>>,>>>,>>9.99":U
  tt-sum.sale-VAT-base FORMAT "->>>,>>>,>>>,>>9.99":U
  tt-sum.sale-VAT-rubl FORMAT "->>>,>>>,>>>,>>9.99":U
  tt-sum.sale-SLT-base FORMAT "->>>,>>>,>>>,>>9.99":U
  tt-sum.sale-SLT-rubl FORMAT "->>>,>>>,>>>,>>9.99":U
  tt-sum.sale-road-tax-base FORMAT "->>>,>>>,>>>,>>9.99":U
  tt-sum.sale-road-tax-rubl FORMAT "->>>,>>>,>>>,>>9.99":U
  tt-sum.sale-excise-base FORMAT "->>>,>>>,>>>,>>9.99":U
  tt-sum.sale-excise-rubl FORMAT "->>>,>>>,>>>,>>9.99":U
  tt-sum.sale-transport-base FORMAT "->>>,>>>,>>>,>>9.99":U
  tt-sum.sale-transport-rubl FORMAT "->>>,>>>,>>>,>>9.99":U
  tt-sum.sale-other-base FORMAT "->>>,>>>,>>>,>>9.99":U
  tt-sum.sale-other-rubl FORMAT "->>>,>>>,>>>,>>9.99":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97.63 BY 9.92.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
  b-exit AT ROW 1 COL 1
  b-help AT ROW 1 COL 11
  BROWSE-1 AT ROW 2.33 COL 1
  SPACE(0.11) SKIP(0.03)
  WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
  SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
  TITLE "Суммы по документу"
  DEFAULT-BUTTON b-exit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: tt-sum T "?" NO-UNDO ub trn-doc-sum
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
                                                                        */
/* BROWSE-TAB BROWSE-1 b-help Dialog-Frame */
ASSIGN
  FRAME Dialog-Frame:SCROLLABLE = FALSE
  FRAME Dialog-Frame:HIDDEN     = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-1
/* Query rebuild information for BROWSE BROWSE-1
     _TblList          = "Temp-Tables.tt-sum"
     _FldNameList[1]   > "_<CALC>"
"fname-sum-type (buffer tt-sum)" "Тип суммы" "x(27)" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _FldNameList[2]   = Temp-Tables.tt-sum.fact-qnty
     _FldNameList[3]   > Temp-Tables.tt-sum.crsa-sum-base
"crsa-sum-base" ? "->>>,>>>,>>>,>>9.99" "decimal" ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _FldNameList[4]   > Temp-Tables.tt-sum.crsa-sum-rubl
"crsa-sum-rubl" ? "->>>,>>>,>>>,>>9.99" "decimal" ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _FldNameList[5]   > Temp-Tables.tt-sum.crsa-discnt-base
"crsa-discnt-base" ? "->>>,>>>,>>>,>>9.99" "decimal" ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _FldNameList[6]   > Temp-Tables.tt-sum.crsa-discnt-rubl
"crsa-discnt-rubl" ? "->>>,>>>,>>>,>>9.99" "decimal" ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _FldNameList[7]   > Temp-Tables.tt-sum.crsa-VAT-base
"crsa-VAT-base" ? "->>>,>>>,>>>,>>9.99" "decimal" ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _FldNameList[8]   > Temp-Tables.tt-sum.crsa-VAT-rubl
"crsa-VAT-rubl" ? "->>>,>>>,>>>,>>9.99" "decimal" ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _FldNameList[9]   > Temp-Tables.tt-sum.crsa-SLT-base
"crsa-SLT-base" ? "->>>,>>>,>>>,>>9.99" "decimal" ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _FldNameList[10]   > Temp-Tables.tt-sum.crsa-SLT-rubl
"crsa-SLT-rubl" ? "->>>,>>>,>>>,>>9.99" "decimal" ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _FldNameList[11]   > Temp-Tables.tt-sum.crsa-road-tax-base
"crsa-road-tax-base" ? "->>>,>>>,>>>,>>9.99" "decimal" ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _FldNameList[12]   > Temp-Tables.tt-sum.crsa-road-tax-rubl
"crsa-road-tax-rubl" ? "->>>,>>>,>>>,>>9.99" "decimal" ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _FldNameList[13]   > Temp-Tables.tt-sum.crsa-excise-base
"crsa-excise-base" ? "->>>,>>>,>>>,>>9.99" "decimal" ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _FldNameList[14]   > Temp-Tables.tt-sum.crsa-excise-rubl
"crsa-excise-rubl" ? "->>>,>>>,>>>,>>9.99" "decimal" ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _FldNameList[15]   > Temp-Tables.tt-sum.cost-sum-base
"cost-sum-base" ? "->>>,>>>,>>>,>>9.99" "decimal" ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _FldNameList[16]   > Temp-Tables.tt-sum.cost-sum-rubl
"cost-sum-rubl" ? "->>>,>>>,>>>,>>9.99" "decimal" ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _FldNameList[17]   > Temp-Tables.tt-sum.cost-VAT-base
"cost-VAT-base" ? "->>>,>>>,>>>,>>9.99" "decimal" ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _FldNameList[18]   > Temp-Tables.tt-sum.cost-VAT-rubl
"cost-VAT-rubl" ? "->>>,>>>,>>>,>>9.99" "decimal" ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _FldNameList[19]   > Temp-Tables.tt-sum.cost-SLT-base
"cost-SLT-base" ? "->>>,>>>,>>>,>>9.99" "decimal" ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _FldNameList[20]   > Temp-Tables.tt-sum.cost-SLT-rubl
"cost-SLT-rubl" ? "->>>,>>>,>>>,>>9.99" "decimal" ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _FldNameList[21]   > Temp-Tables.tt-sum.cost-road-tax-base
"cost-road-tax-base" ? "->>>,>>>,>>>,>>9.99" "decimal" ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _FldNameList[22]   > Temp-Tables.tt-sum.cost-road-tax-rubl
"cost-road-tax-rubl" ? "->>>,>>>,>>>,>>9.99" "decimal" ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _FldNameList[23]   > Temp-Tables.tt-sum.cost-transport-base
"cost-transport-base" ? "->>>,>>>,>>>,>>9.99" "decimal" ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _FldNameList[24]   > Temp-Tables.tt-sum.cost-transport-rubl
"cost-transport-rubl" ? "->>>,>>>,>>>,>>9.99" "decimal" ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _FldNameList[25]   > Temp-Tables.tt-sum.cost-other-base
"cost-other-base" ? "->>>,>>>,>>>,>>9.99" "decimal" ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _FldNameList[26]   > Temp-Tables.tt-sum.cost-other-rubl
"cost-other-rubl" ? "->>>,>>>,>>>,>>9.99" "decimal" ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _FldNameList[27]   > Temp-Tables.tt-sum.cost-excise-base
"cost-excise-base" ? "->>>,>>>,>>>,>>9.99" "decimal" ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _FldNameList[28]   > Temp-Tables.tt-sum.cost-excise-rubl
"cost-excise-rubl" ? "->>>,>>>,>>>,>>9.99" "decimal" ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _FldNameList[29]   > Temp-Tables.tt-sum.sale-sum-base
"sale-sum-base" ? "->>>,>>>,>>>,>>9.99" "decimal" ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _FldNameList[30]   > Temp-Tables.tt-sum.sale-sum-rubl
"sale-sum-rubl" ? "->>>,>>>,>>>,>>9.99" "decimal" ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _FldNameList[31]   > Temp-Tables.tt-sum.sale-discnt-base
"sale-discnt-base" ? "->>>,>>>,>>>,>>9.99" "decimal" ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _FldNameList[32]   > Temp-Tables.tt-sum.sale-discnt-rubl
"sale-discnt-rubl" ? "->>>,>>>,>>>,>>9.99" "decimal" ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _FldNameList[33]   > Temp-Tables.tt-sum.sale-VAT-base
"sale-VAT-base" ? "->>>,>>>,>>>,>>9.99" "decimal" ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _FldNameList[34]   > Temp-Tables.tt-sum.sale-VAT-rubl
"sale-VAT-rubl" ? "->>>,>>>,>>>,>>9.99" "decimal" ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _FldNameList[35]   > Temp-Tables.tt-sum.sale-SLT-base
"sale-SLT-base" ? "->>>,>>>,>>>,>>9.99" "decimal" ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _FldNameList[36]   > Temp-Tables.tt-sum.sale-SLT-rubl
"sale-SLT-rubl" ? "->>>,>>>,>>>,>>9.99" "decimal" ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _FldNameList[37]   > Temp-Tables.tt-sum.sale-road-tax-base
"sale-road-tax-base" ? "->>>,>>>,>>>,>>9.99" "decimal" ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _FldNameList[38]   > Temp-Tables.tt-sum.sale-road-tax-rubl
"sale-road-tax-rubl" ? "->>>,>>>,>>>,>>9.99" "decimal" ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _FldNameList[39]   > Temp-Tables.tt-sum.sale-excise-base
"sale-excise-base" ? "->>>,>>>,>>>,>>9.99" "decimal" ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _FldNameList[40]   > Temp-Tables.tt-sum.sale-excise-rubl
"sale-excise-rubl" ? "->>>,>>>,>>>,>>9.99" "decimal" ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _FldNameList[41]   > Temp-Tables.tt-sum.sale-transport-base
"sale-transport-base" ? "->>>,>>>,>>>,>>9.99" "decimal" ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _FldNameList[42]   > Temp-Tables.tt-sum.sale-transport-rubl
"sale-transport-rubl" ? "->>>,>>>,>>>,>>9.99" "decimal" ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _FldNameList[43]   > Temp-Tables.tt-sum.sale-other-base
"sale-other-base" ? "->>>,>>>,>>>,>>9.99" "decimal" ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _FldNameList[44]   > Temp-Tables.tt-sum.sale-other-rubl
"sale-other-rubl" ? "->>>,>>>,>>>,>>9.99" "decimal" ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _Query            is OPENED
*/  /* BROWSE BROWSE-1 */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Суммы по документу */
  DO:
    APPLY "END-ERROR":U TO SELF.
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-1
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

  define variable v-sum-type as character no-undo.
  define variable isPrlSum   as logical   no-undo.
  

  { str/tdat-val.i
      pardoc-code
      {&trdcattr-addsum}
      varvalue
      vartype
      no-error
  }
  if error-status :error then 
  do:
    return error return-value.
  end.

  for each tt-sum :
    delete tt-sum.
  end.
  if paris-doc then 
  do:
    for each trn-doc-sum where trn-doc-sum.doc-code = pardoc-code no-lock :
      if lookup (trn-doc-sum.sum-type, varvalue) <> 0 then 
      do:
        create tt-sum.
        buffer-copy trn-doc-sum to tt-sum.
      end.
    end.
  end.
  else 
  do:
    varvalue = varvalue + ",mterr".
    for each doc-line-sum where doc-line-sum.doc-code = pardoc-code and
      doc-line-sum.gds-code = pargds-code no-lock :

      if num-entries (doc-line-sum.sum-type, {&delim-par}) > 1 
        then do:
          v-sum-type =  entry (1, doc-line-sum.sum-type, {&delim-par}).
          isPrlSum = true.
        end.
        else v-sum-type = doc-line-sum.sum-type.

         
      if lookup (v-sum-type, varvalue) <> 0 then 
      do:
        create tt-sum.
        buffer-copy doc-line-sum to tt-sum.
      end.
    end.
    find first tt-sum where isPrlSum and tt-sum.sum-type = {&sum-wastage-doc} no-error.
    if available (tt-sum) then delete tt-sum. 
  end.
  run tax-name in this-procedure ({&road-tax}, output rdtaxname).
  assign
    tt-sum.cost-road-tax-base:label in browse {&browse-name} = rdtaxname + "  учет. (вал)"
    tt-sum.cost-road-tax-rubl:label in browse {&browse-name} = rdtaxname + " учет. ({&abbr_rub})"
    tt-sum.crsa-road-tax-base:label in browse {&browse-name} = rdtaxname + " тек. прод. (вал)"
    tt-sum.crsa-road-tax-rubl:label in browse {&browse-name} = rdtaxname + " тек. прод. ({&abbr_rub})"
    tt-sum.sale-road-tax-base:label in browse {&browse-name} = rdtaxname + " прод. (вал)"
    tt-sum.sale-road-tax-rubl:label in browse {&browse-name} = rdtaxname + " прод. ({&abbr_rub})"   .

  if paris-doc = no then 
  do:
    find first goods where goods.gds-code = pargds-code no-lock.
    assign
      frame {&frame-name}:title = "Суммы по товару: " + goods.artic + " " + goods.prod-type + " " + string(goods.prod-code) + " " + string(goods.gds-name, "x(30)").
  end.
  RUN enable_UI.
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
  ENABLE b-exit b-help BROWSE-1
    WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION fname-sum-type Dialog-Frame
FUNCTION fname-sum-type RETURNS CHARACTER
  ( buffer local-tt-sum for tt-sum ) :
  /*------------------------------------------------------------------------------
    Purpose:
      Notes:
  ------------------------------------------------------------------------------*/
  define variable v-sum-type as char no-undo.
  
  &scop sum-type local-tt-sum.sum-type
  if available local-tt-sum then 
  do:
    if num-entries (local-tt-sum.sum-type, {&delim-par}) > 1 
    then do: 
      case entry (1, local-tt-sum.sum-type, {&delim-par}) + {&delim-par} + entry (2, local-tt-sum.sum-type, {&delim-par}):
        when {&sum-wastage-doc} + {&delim-par} + "base":U then do:
          return "Сумма_естест_убыли,_л,_мест.хр.-" + entry (3, local-tt-sum.sum-type, {&delim-par}).
        end.
        when {&sum-wastage-doc} + {&delim-par} + "cli":U then do:
          return "Сумма_естест_убыли,_кг,_мест.хр.-" + entry (3, local-tt-sum.sum-type, {&delim-par}).
        end.
        when "mterr" + {&delim-par} + "base":U then do:
          return "Погреш. измерения,_л,_мест.хр.-" + entry (3, local-tt-sum.sum-type, {&delim-par}).
        end.
        when "mterr" + {&delim-par} + "cli":U then do:
          return "Погреш. измерения,_кг,_мест.хр.-" + entry (3, local-tt-sum.sum-type, {&delim-par}).
        end.
      end.
    end.
    else 
    do:
      RETURN {&sum-name}.   /* Function return value. */
    end.
  end.
/*  else return local-tt-sum.sum-type .*/

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME