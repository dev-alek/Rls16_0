&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME D-add-tax

/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE tt-tax NO-UNDO LIKE ub.tax.
DEFINE TEMP-TABLE tt-tax-units NO-UNDO LIKE ub.tax-units
       field is-found as logical column-label ""
       index pi is unique primary tax-code type.


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS D-add-tax
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Карточка вида налога

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/05/06
Author: Bakhtadze Natalya
Creation date: 04/05/06

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
def input parameter ref-mode as char no-undo.
def input-output param rid as recid init ? no-undo.

/* Local Variable Definitions ---                                       */

define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Карточка вида налога" .
{ cmp/vssrevis.i }
&scop tax-type-code tt-tax.tax-type
&scop num-taxes 4

{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME D-add-tax
&Scoped-define BROWSE-NAME BR-tt-tax-units

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-tax-units tt-tax

/* Definitions for BROWSE BR-tt-tax-units                               */
&Scoped-define FIELDS-IN-QUERY-BR-tt-tax-units is-found tt-tax-units.type ~
get-description(tt-tax-units.type)
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-tt-tax-units
&Scoped-define FIELD-PAIRS-IN-QUERY-BR-tt-tax-units
&Scoped-define OPEN-QUERY-BR-tt-tax-units OPEN QUERY BR-tt-tax-units FOR EACH tt-tax-units WHERE tt-tax-units.tax-code = ub.tax.tax-code NO-LOCK.
&Scoped-define TABLES-IN-QUERY-BR-tt-tax-units tt-tax-units
&Scoped-define FIRST-TABLE-IN-QUERY-BR-tt-tax-units tt-tax-units


/* Definitions for DIALOG-BOX D-add-tax                                 */
&Scoped-define OPEN-BROWSERS-IN-QUERY-D-add-tax ~
    ~{&OPEN-QUERY-BR-tt-tax-units}
&Scoped-define OPEN-QUERY-D-add-tax OPEN QUERY D-add-tax FOR EACH tt-tax SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-D-add-tax tt-tax
&Scoped-define FIRST-TABLE-IN-QUERY-D-add-tax tt-tax


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS tt-tax.tax-name tt-tax.to-cashdesk ~
tt-tax.individual
&Scoped-define FIELD-PAIRS~
 ~{&FP1}tax-name ~{&FP2}tax-name ~{&FP3}
&Scoped-define ENABLED-TABLES tt-tax
&Scoped-define FIRST-ENABLED-TABLE tt-tax
&Scoped-Define ENABLED-OBJECTS B-exit B-quit B-Help B-mark BR-tt-tax-units
&Scoped-Define DISPLAYED-FIELDS tt-tax.tax-code tt-tax.tax-name ~
tt-tax.to-cashdesk tt-tax.individual
&Scoped-Define DISPLAYED-OBJECTS TaxType

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-description D-add-tax
FUNCTION get-description RETURNS CHARACTER
  ( input partype as character )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод "
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-mark
     LABEL "&*"
     SIZE 3 BY 1.

DEFINE BUTTON B-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE TaxType AS CHARACTER FORMAT "X(256)":U
     LABEL "Тип налога"
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEMS "Item 1"
     SIZE 19.5 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-tt-tax-units FOR
      tt-tax-units SCROLLING.

DEFINE QUERY D-add-tax FOR
      tt-tax SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-tt-tax-units
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-tt-tax-units D-add-tax _STRUCTURED
  QUERY BR-tt-tax-units DISPLAY
      is-found FORMAT "+/"
      tt-tax-units.type COLUMN-LABEL "" FORMAT "X(3)"
      get-description(tt-tax-units.type) COLUMN-LABEL "Тип товара" FORMAT "X(12)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 21.13 BY 10.13
         TITLE "Налог определен для:".


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME D-add-tax
     B-exit AT ROW 1 COL 1
     B-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 41
     B-mark AT ROW 1.83 COL 54.75
     tt-tax.tax-code AT ROW 3.04 COL 14.63 COLON-ALIGNED
          LABEL "Код"
          VIEW-AS FILL-IN
          SIZE 6 BY 1
     BR-tt-tax-units AT ROW 3.04 COL 54.5
     TaxType AT ROW 4.42 COL 14.63 COLON-ALIGNED
     tt-tax.tax-name AT ROW 6.42 COL 14.63 COLON-ALIGNED
          LABEL "Название"
          VIEW-AS FILL-IN
          SIZE 33.5 BY 1
     tt-tax.to-cashdesk AT ROW 8.08 COL 16.63
          VIEW-AS TOGGLE-BOX
          SIZE 25.38 BY .96
     tt-tax.individual AT ROW 9.83 COL 16.63
          VIEW-AS TOGGLE-BOX
          SIZE 25.38 BY 1
     SPACE(56.86) SKIP(3.41)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Вид налога"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON B-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: tt-tax T "?" NO-UNDO ub tax
      TABLE: tt-tax-units T "?" NO-UNDO ub tax-units
      ADDITIONAL-FIELDS:
          field is-found as logical column-label ""
          index pi is unique primary tax-code type
      END-FIELDS.
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS


/* ***************  Runtime Attributes and UIB Settings  ************** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX D-add-tax
                                                                        */
/* BROWSE-TAB BR-tt-tax-units tax-code D-add-tax */
ASSIGN
       FRAME D-add-tax:SCROLLABLE       = FALSE
       FRAME D-add-tax:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN tt-tax.tax-code IN FRAME D-add-tax
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN tt-tax.tax-name IN FRAME D-add-tax
   EXP-LABEL                                                            */
/* SETTINGS FOR COMBO-BOX TaxType IN FRAME D-add-tax
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-tt-tax-units
/* Query rebuild information for BROWSE BR-tt-tax-units
     _TblList          = "Temp-Tables.tt-tax-units WHERE ub.tax ..."
     _JoinCode[1]      = "Temp-Tables.tt-tax-units.tax-code = ub.tax.tax-code"
     _FldNameList[1]   > "_<CALC>"
"is-found" ? "+/" ? ? ? ? ? ? ? no ?
     _FldNameList[2]   > Temp-Tables.tt-tax-units.type
"tt-tax-units.type" "" "X(3)" "character" ? ? ? ? ? ? no ?
     _FldNameList[3]   > "_<CALC>"
"get-description(tt-tax-units.type)" "Тип товара" "X(12)" ? ? ? ? ? ? ? no ?
     _Query            is OPENED
*/  /* BROWSE BR-tt-tax-units */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX D-add-tax
/* Query rebuild information for DIALOG-BOX D-add-tax
     _TblList          = "tt-tax"
     _Options          = "SHARE-LOCK"
     _Query            is OPENED
*/  /* DIALOG-BOX D-add-tax */
&ANALYZE-RESUME






/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME D-add-tax
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL D-add-tax D-add-tax
ON GO OF FRAME D-add-tax /* Вид налога */
DO:
    find first tt-tax  no-error.
    if not avail tt-tax then create tt-tax.
       assign
       TaxType
       tt-tax.individual
       tt-tax.tax-code
       tt-tax.tax-name
       tt-tax.to-cashdesk
       .
    run ref/taxesi01.p (input-output rid,
                   input ref-mode,
                   tt-tax.tax-code,
                    tt-tax.tax-name,
                    taxtype,
                    tt-tax.individual,
                    tt-tax.to-cashdesk,
                   input table tt-tax-units) no-error.
  if error-status:error then do:
        if return-value = "":U then return no-apply.
    case return-value:
            when "tax-name":U then do:
                APPLY "ENTRY" to tt-tax.tax-name.
            end.
            when "tax-code":U then do:
                 APPLY "ENTRY" to tt-tax.tax-code.
            end.
            when "individual":U then do:
                 APPLY "ENTRY" to tt-tax.individual.
            end.
        end.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL D-add-tax D-add-tax
ON WINDOW-CLOSE OF FRAME D-add-tax /* Вид налога */
DO:
  rid = ?.
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark D-add-tax
ON CHOOSE OF B-mark IN FRAME D-add-tax /* * */
DO:
  if not avail tt-tax-units then return no-apply.
    run proc-b-mark(tt-tax.tax-code, tt-tax-units.type) no-error.
    if error-status:error then return no-apply.
    OPEN QUERY br-tt-tax-units for each tt-tax-units No-LOCK.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-quit D-add-tax
ON CHOOSE OF B-quit IN FRAME D-add-tax /* Отказ */
DO:
  rid = ?.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-tt-tax-units
&Scoped-define SELF-NAME BR-tt-tax-units
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-tt-tax-units D-add-tax
ON MOUSE-SELECT-DBLCLICK OF BR-tt-tax-units IN FRAME D-add-tax /* Налог определен для: */
DO:
  if tt-tax.tax-code <= {&num-taxes} then return no-apply.
  APPLY "CHOOSE" to b-mark.
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK D-add-tax


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
  if ref-mode <> {&update} and ref-mode <> {&add-def} then do:
        message vss-workfile vss-revision vss-description skip
                    "Неверный параметр вызова ref-mode"
        view-as alert-box ERROR.
        return error.
    end.
  TaxType:INNER-LINES = num-entries ({&tax-types}) .
  TaxType:list-items = {&tax-types} .
  TaxType:screen-value = entry (1, {&tax-types}) .
  for each tt-tax:
        delete tt-tax.
    end.
  if ref-mode = {&update} then do:
    find first ub.tax EXCLUSIVE-LOCK where recid(ub.tax) = rid NO-WAIT NO-ERROR.
    if locked ub.tax then do:
      message vss-workfile vss-revision vss-description skip
              "Запись налога занята"
      view-as alert-box error .
      return error.
    end.
    if not avail tax then do:
      message vss-workfile vss-revision vss-description skip
              "Запись налога не найдена"
      view-as alert-box error .
      return error.
    end.
    create tt-tax.
    buffer-copy tax to tt-tax.
   end.
  RUN MyEnable.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI D-add-tax _DEFAULT-DISABLE
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
  HIDE FRAME D-add-tax.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI D-add-tax _DEFAULT-ENABLE
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

  {&OPEN-QUERY-D-add-tax}
  GET FIRST D-add-tax.
  DISPLAY TaxType
      WITH FRAME D-add-tax.
  IF AVAILABLE tt-tax THEN
    DISPLAY tt-tax.tax-code tt-tax.tax-name tt-tax.to-cashdesk tt-tax.individual
      WITH FRAME D-add-tax.
  ENABLE B-exit B-quit B-Help B-mark BR-tt-tax-units tt-tax.tax-name
         tt-tax.to-cashdesk tt-tax.individual
      WITH FRAME D-add-tax.
  VIEW FRAME D-add-tax.
  {&OPEN-BROWSERS-IN-QUERY-D-add-tax}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-tt D-add-tax
PROCEDURE fill-tt :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable ii as integer  no-undo.
for each tt-tax-units:
delete tt-tax-units.
end.
do ii = 1 to num-entries({&unit-type-tax-list}):
    FIND FIRST ub.tax-units No-LOCK WHERE
                          ub.tax-units.tax-code = tt-tax.tax-code AND
                          ub.tax-units.type = entry(ii, {&unit-type-tax-list}) No-ERROR.
    create tt-tax-units.
    assign
    tt-tax-units.tax-code = tt-tax.tax-code
    tt-tax-units.type = entry(ii, {&unit-type-tax-list})
    tt-tax-units.is-found = avail ub.tax-units
    .
end.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable D-add-tax
PROCEDURE MyEnable :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  DISPLAY TaxType
      WITH FRAME D-add-tax.
  IF AVAILABLE tt-tax THEN
    DISPLAY tt-tax.tax-code tt-tax.tax-name tt-tax.to-cashdesk
      WITH FRAME D-add-tax.
  ENABLE
  B-exit
  B-quit
    B-Help
    tt-tax.tax-name when ref-mode = {&add-def} or tt-tax.tax-code > {&num-taxes}
    tt-tax.to-cashdesk
    tt-tax.individual when ref-mode = {&add-def} or tt-tax.tax-code > {&num-taxes}
    b-mark when ref-mode = {&add-def} or tt-tax.tax-code > {&num-taxes}
      WITH FRAME D-add-tax.
  VIEW FRAME D-add-tax.
  ENABLE
      tt-tax.tax-code when ref-mode = {&add-def}
      BR-tt-tax-units
      TaxType when ref-mode = {&add-def}
      WITH FRAME {&frame-name}.
  IF ref-mode = {&update} then do:
      FRAME {&frame-name}:title = "Изменение вида налога".
      DISPLAY
      tt-tax.tax-code
      tt-tax.tax-name
      tt-tax.to-cashdesk
      tt-tax.individual
      WITH frame {&frame-name}.
      TaxType:screen-value = {&tax-type-name} .
      DISABLE
      tt-tax.individual
      WITH FRAME {&FRAME-NAME}.
  END.
  RUN fill-tt.
  OPEN QUERY BR-tt-tax-units for each tt-tax-units.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-mark D-add-tax
PROCEDURE proc-b-mark :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE INPUT PARAMETER partax-code like ub.tax-units.tax-code no-undo.
DEFINE INPUT PARAMETER partype like ub.tax-units.type no-undo.
define buffer b_tt-tax-units for tt-tax-units.
FIND FIRST b_tt-tax-units where
                  b_tt-tax-units.type = partype AND
                  b_tt-tax-units.tax-code = partax-code No-ERROR.
if avail b_tt-tax-units then dO:
    assign
    b_tt-tax-units.is-found = not b_tt-tax-units.is-found.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-description D-add-tax
FUNCTION get-description RETURNS CHARACTER
  ( input partype as character ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
  RETURN entry(LOOKUP(partype, {&unit-type-list}), {&unit-types}).   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
