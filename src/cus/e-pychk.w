&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI ADM1
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS F-Frame-Win
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Суммы продаж с разбивкой по типам кассовых платежей и НДС - запуск

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/20/06
Author: Bakhtadze Natalya
Creation date: 03/20/06

*/

/* Create an unnamed pool to store all the widgets created
     by this procedure. This is a good default which assures
     that this procedure's triggers and internal procedures
     will execute in this procedure's storage, and that proper
     cleanup will occur on deletion of the procedure. */

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Суммы продаж с разбивкой по типам кассовых платежей и НДС - запуск" .
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/showinf.i }
{ gbl/cur-time.i }
{ cmp/r-pril.i new }
{ cmp/r-page1.i  }
{ gbl/waitfram.i }
{ cus/real-vat.i "NEW SHARED" "treal-vat" }
{ gbl/usr-flt.i }
{ gbl/getcntxt.i def }
define variable Line            as character no-undo.
define variable date_string     as character no-undo.
define variable parparentproc   as widget-handle no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE SmartObject
&Scoped-define DB-AWARE no

&Scoped-define ADM-CONTAINER FRAME

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME F-Main
&Scoped-define BROWSE-NAME BR-cash-pay

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-cash-pay tt-cash-group

/* Definitions for BROWSE BR-cash-pay                                   */
&Scoped-define FIELDS-IN-QUERY-BR-cash-pay tt-cash-pay.cdpay-code tt-cash-pay.curr-code trim(tt-cash-pay.grp-code, {&delim-par}) tt-cash-pay.obj-name
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-cash-pay
&Scoped-define SELF-NAME BR-cash-pay
&Scoped-define QUERY-STRING-BR-cash-pay FOR EACH tt-cash-pay NO-LOCK
&Scoped-define OPEN-QUERY-BR-cash-pay OPEN QUERY {&SELF-NAME} FOR EACH tt-cash-pay NO-LOCK.
&Scoped-define TABLES-IN-QUERY-BR-cash-pay tt-cash-pay
&Scoped-define FIRST-TABLE-IN-QUERY-BR-cash-pay tt-cash-pay


/* Definitions for BROWSE BR-cpay-group                                 */
&Scoped-define FIELDS-IN-QUERY-BR-cpay-group trim(tt-cash-group.grp-code, {&delim-par}) tt-cash-group.obj-name
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-cpay-group tt-cash-group.obj-name
&Scoped-define ENABLED-TABLES-IN-QUERY-BR-cpay-group tt-cash-group
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-BR-cpay-group tt-cash-group
&Scoped-define SELF-NAME BR-cpay-group
&Scoped-define QUERY-STRING-BR-cpay-group FOR EACH tt-cash-group
&Scoped-define OPEN-QUERY-BR-cpay-group OPEN QUERY {&SELF-NAME} FOR EACH tt-cash-group.
&Scoped-define TABLES-IN-QUERY-BR-cpay-group tt-cash-group
&Scoped-define FIRST-TABLE-IN-QUERY-BR-cpay-group tt-cash-group


/* Definitions for FRAME F-Main                                         */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS T-cdpay-group BR-cpay-group B-add B-del ~
BR-cash-pay T-rv
&Scoped-Define DISPLAYED-OBJECTS T-cdpay-group T-rv

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE BUTTON B-add
     LABEL "&Добавить"
     SIZE 10 BY 1.

DEFINE BUTTON B-del
     LABEL "&Удалить"
     SIZE 10 BY 1.

DEFINE VARIABLE T-cdpay-group AS LOGICAL INITIAL no
     LABEL "С группировкой типов кассовых платежей"
     VIEW-AS TOGGLE-BOX
     SIZE 46.13 BY 1 NO-UNDO.

DEFINE VARIABLE T-rv AS LOGICAL INITIAL no
     LABEL "Отдельно по чекам расхода и возврата"
     VIEW-AS TOGGLE-BOX
     SIZE 46.13 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-cash-pay FOR
      tt-cash-pay SCROLLING.

DEFINE QUERY BR-cpay-group FOR
      tt-cash-group SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-cash-pay
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-cash-pay F-Frame-Win _FREEFORM
  QUERY BR-cash-pay DISPLAY
      tt-cash-pay.cdpay-code COLUMN-LABEL "Код!пл-жа" FORMAT "99999"
      tt-cash-pay.curr-code COLUMN-LABEL "Код!валюты"
      trim(tt-cash-pay.grp-code, {&delim-par}) COLUMN-LABEL "№!группы" FORMAT "X(2)"
      tt-cash-pay.obj-name
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 63.75 BY 8.67
         TITLE "Типы кассовых платежей".

DEFINE BROWSE BR-cpay-group
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-cpay-group F-Frame-Win _FREEFORM
  QUERY BR-cpay-group DISPLAY
      trim(tt-cash-group.grp-code, {&delim-par}) column-label "№"
tt-cash-group.obj-name column-label "Название группы" FORMAT "X(23)"
ENABLE
tt-cash-group.obj-name
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 52.5 BY 5.04
         TITLE "Группы типов кассовых платежей".


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     T-cdpay-group AT ROW 1.17 COL 3.38
     BR-cpay-group AT ROW 2.08 COL 2.88
     B-add AT ROW 2.46 COL 56.38
     B-del AT ROW 3.83 COL 56.63
     BR-cash-pay AT ROW 7.29 COL 3.13
     T-rv AT ROW 16 COL 3
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 1 ROW 1
         SIZE 67.88 BY 16.21.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: SmartObject
   Allow: Basic,Browse,DB-Fields,Smart,Query
   Container Links:
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB)
  CREATE WINDOW F-Frame-Win ASSIGN
         HEIGHT             = 16.21
         WIDTH              = 67.88.
/* END WINDOW DEFINITION */
                                                                        */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB F-Frame-Win
/* ************************* Included-Libraries *********************** */

{src/adm/method/containr.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW F-Frame-Win
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME F-Main
   NOT-VISIBLE                                                          */
/* BROWSE-TAB BR-cpay-group T-cdpay-group F-Main */
/* BROWSE-TAB BR-cash-pay B-del F-Main */
ASSIGN
       B-add:HIDDEN IN FRAME F-Main           = TRUE.

ASSIGN
       B-del:HIDDEN IN FRAME F-Main           = TRUE.

ASSIGN
       BR-cash-pay:HIDDEN  IN FRAME F-Main                = TRUE.

ASSIGN
       BR-cpay-group:HIDDEN  IN FRAME F-Main                = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-cash-pay
/* Query rebuild information for BROWSE BR-cash-pay
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-cash-pay NO-LOCK.
     _END_FREEFORM
     _Query            is NOT OPENED
*/  /* BROWSE BR-cash-pay */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-cpay-group
/* Query rebuild information for BROWSE BR-cpay-group
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-cash-group.
     _END_FREEFORM
     _Query            is NOT OPENED
*/  /* BROWSE BR-cpay-group */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME F-Main
/* Query rebuild information for FRAME F-Main
     _Options          = ""
     _Query            is NOT OPENED
*/  /* FRAME F-Main */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME B-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-add F-Frame-Win
ON CHOOSE OF B-add IN FRAME F-Main /* Добавить */
DO:
define buffer buf_tt-cash-group for tt-cash-group.
define buffer buf_tt-cash-pay for tt-cash-pay.
define buffer buf_cash-pay for ub.cash-pay.

define variable varrid-list as character no-undo.
define variable ii as integer no-undo.
define variable jj as integer no-undo.

define variable v-cash-pay-list as character no-undo.
 varrid-list = "" .
run ref/cashpays.w (
               input my-handle
              ,input "b-sel,b-mark"
              ,input {&all}
              ,input 0
              ,input '':U
              ,input 0
              ,output varrid-list ) .
if varrid-list = "":U then return no-apply.
find last buf_tt-cash-group no-lock use-index pi no-error.
if available buf_tt-cash-group then do:
    assign
    jj = integer(trim(buf_tt-cash-group.grp-code, {&delim-par}))
    .
end.
do ii = 1 to num-entries(varrid-list):
    find first buf_cash-pay no-lock where
                recid(buf_cash-pay) = integer(entry(ii, varrid-list)) no-error.
    if available buf_cash-pay then do:
        assign
        v-cash-pay-list = v-cash-pay-list + (if v-cash-pay-list = "":U then "":U else ";":U) +
                                  string(buf_cash-pay.cdpay-code) + "-":U + string(buf_cash-pay.curr-code)
       .
    end.
end.
run proc-add-cash-group in this-procedure ({&delim-par} + string(jj + 1), "Группа" + {&space-char} + string(jj + 1),  v-cash-pay-list) no-error.
if error-status:error then do:
    undo, return no-apply.
end.
run set-cash-group in this-procedure(no, yes) no-error.



END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-del F-Frame-Win
ON CHOOSE OF B-del IN FRAME F-Main /* Удалить */
DO:
define variable ii as integer no-undo.
define buffer buf_tt-cash-group for tt-cash-group.
define buffer buf2_tt-cash-group for tt-cash-group.

define buffer buf_tt-cash-pay for tt-cash-pay.

  if not available tt-cash-group then return no-apply.
  find first buf_tt-cash-group exclusive-lock where buf_tt-cash-group.grp-code = tt-cash-group.grp-code.
  ii = integer(trim(buf_tt-cash-group.grp-code, {&delim-par})).
  for each buf_tt-cash-pay where
            buf_tt-cash-pay.grp-code = buf_tt-cash-group.grp-code :
         buf_tt-cash-pay.grp-code = {&delim-par} + "0":U.
  end.
  delete buf_tt-cash-group.
  for each buf_tt-cash-pay where
            integer(trim(buf_tt-cash-pay.grp-code, {&delim-par})) > ii:
      assign
      buf_tt-cash-pay.grp-code = {&delim-par} + string(integer(trim(buf_tt-cash-pay.grp-code, {&delim-par})) - 1      )
      .
  end.
    for each buf2_tt-cash-group where
            integer(trim(buf2_tt-cash-group.grp-code, {&delim-par})) > ii:
      assign
      buf2_tt-cash-group.grp-code = {&delim-par} + string(integer(trim(buf2_tt-cash-group.grp-code, {&delim-par})) - 1      )
      .
  end.
run set-cash-group in this-procedure(no, yes) no-error.
{&open-query-BR-cash-pay}
{&open-query-BR-cpay-group}

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-cpay-group
&Scoped-define SELF-NAME BR-cpay-group
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-cpay-group F-Frame-Win
ON LEAVE OF BR-cpay-group IN FRAME F-Main /* Группы типов кассовых платежей */
DO:
  ASSIGN
  TT-CASH-GROUP.OBJ-NAME = TT-CASH-GROUP.OBJ-NAME:SCREEN-VALUE IN browse br-cpay-group.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME T-cdpay-group
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL T-cdpay-group F-Frame-Win
ON VALUE-CHANGED OF T-cdpay-group IN FRAME F-Main /* С группировкой типов кассовых платежей */
DO:
  assign
  t-cdpay-group.
  CASE t-cdpay-group:
    when yes then do:
        run get-cash-group in this-procedure no-error.
        display
        B-add B-del BR-cash-pay BR-cpay-group
        with frame {&frame-name}.
    end.
    when no then do:
        run set-cash-group in this-procedure(yes, no) no-error.
        hide
        B-add B-del BR-cash-pay BR-cpay-group
        in frame {&frame-name}.

    end.

  END CASE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-cash-pay
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK F-Frame-Win


/* ***************************  Main Block  *************************** */
{ gbl/personly.i }
&IF DEFINED(UIB_IS_RUNNING) <> 0 &THEN
   /* Now enable the interface  if in test mode - otherwise this happens when
      the object is explicitly initialized from its container. */
   RUN dispatch IN THIS-PROCEDURE ('initialize':U).
&ENDIF

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-create-objects F-Frame-Win  _ADM-CREATE-OBJECTS
PROCEDURE adm-create-objects :
/*------------------------------------------------------------------------------
  Purpose:     Create handles for all SmartObjects used in this procedure.
               After SmartObjects are initialized, then SmartLinks are added.
  Parameters:  <none>
------------------------------------------------------------------------------*/

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-row-available F-Frame-Win  _ADM-ROW-AVAILABLE
PROCEDURE adm-row-available :
/*------------------------------------------------------------------------------
  Purpose:     Dispatched to this procedure when the Record-
               Source has a new row available.  This procedure
               tries to get the new row (or foriegn keys) from
               the Record-Source and process it.
  Parameters:  <none>
------------------------------------------------------------------------------*/

  /* Define variables needed by this internal procedure.             */
  {src/adm/template/row-head.i}

  /* Process the newly available records (i.e. display fields,
     open queries, and/or pass records on to any RECORD-TARGETS).    */
  {src/adm/template/row-end.i}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI F-Frame-Win  _DEFAULT-DISABLE
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
  HIDE FRAME F-Main.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI F-Frame-Win  _DEFAULT-ENABLE
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
  DISPLAY T-cdpay-group T-rv
      WITH FRAME F-Main.
  ENABLE T-cdpay-group BR-cpay-group B-add B-del BR-cash-pay T-rv
      WITH FRAME F-Main.
  {&OPEN-BROWSERS-IN-QUERY-F-Main}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-cash-group F-Frame-Win
PROCEDURE get-cash-group :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable v-grp-int-code as integer no-undo.
define variable v-grp-name as character no-undo.
define variable v-cash-pay-list as character no-undo.

define variable ii as integer no-undo.
run uf-get in this-procedure(
     input  {&uf-pychk-rep}
    ,input  g#userid
    ,output v-uf-List_
    ,output v-uf-Naim
    ,output v-uf-print-graft
    ,output v-uf-sort-gr
    ,output v-uf-type-price
    ,output v-uf-type-val
)  no-error.

if not error-status:error then do:
    do ii = 1 to num-entries (v-uf-list_, {&delim-par}):
        assign
        v-grp-int-code = integer(entry(1, entry(ii, v-uf-list_, {&delim-par}), "=":U))
        v-grp-name = entry(2, entry(ii, v-uf-list_, {&delim-par}), "=":U)
        v-cash-pay-list = entry(ii, v-uf-Naim, {&delim-par})
        .
        run proc-add-cash-group in this-procedure ({&delim-par} + string(v-grp-int-code), v-grp-name, v-cash-pay-list) no-error.
        if error-status:error then undo, return error.
    end.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-apply-layout F-Frame-Win
PROCEDURE local-apply-layout :
/*------------------------------------------------------------------------------
  Purpose:     Override standard ADM method
  Notes:
------------------------------------------------------------------------------*/

  /* Code placed here will execute PRIOR to standard behavior. */

  /* Dispatch standard ADM method.                             */
  RUN dispatch IN THIS-PROCEDURE ( INPUT 'apply-layout':U ) .

  /* Code placed here will execute AFTER standard behavior.    */
define buffer buf_cash-pay for ub.cash-pay.
define buffer buf_tt-cash-pay for tt-cash-pay.

for each tt-cash-pay:
    delete tt-cash-pay.
end.
for each buf_cash-pay no-lock:
    create buf_tt-cash-pay.
    buffer-copy buf_cash-pay to buf_tt-cash-pay
    assign
    buf_tt-cash-pay.grp-code = {&delim-par} + "0":U
    .
end.
{&open-query-BR-cash-pay}
{&open-query-BR-cpay-group}
apply "VALUE-CHANGED" to T-cdpay-group in frame {&frame-name}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-initialize F-Frame-Win
PROCEDURE local-initialize :
/*------------------------------------------------------------------------------
  Purpose:     Override standard ADM method
  Notes:
------------------------------------------------------------------------------*/

  /* Code placed here will execute PRIOR to standard behavior. */

  /* Dispatch standard ADM method.                             */
  RUN dispatch IN THIS-PROCEDURE ( INPUT 'initialize':U ) .
  parparentproc = my-handle.
  { gbl/getcntxt.i get }

  /* Code placed here will execute AFTER standard behavior.    */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE My-report F-Frame-Win
PROCEDURE My-report :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
run My-var.
if return-value = "error":U then return.

run set-cash-group in this-procedure (no, T-cdpay-group) no-error.


run cus/r-pychk2.p ( input my-handle
                    ,input T-cdpay-group
                    ,input T-rv) no-error.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE My-var F-Frame-Win
PROCEDURE My-var :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define buffer buf_tt-cash-group for tt-cash-group.
Assign
frame {&frame-name} t-cdpay-group
t-rv
.
Assign
 STR-obj-type = ''
 STR-obj-code = ''
 STR-obj-name = ''
 STR-obj      = ''.


For each obj-list no-lock:
 Assign
 STR-obj-type = STR-obj-type + obj-list.obj-type + ','
 STR-obj-code = STR-obj-code + String(obj-list.obj-code) + ','
 STR-obj-name = STR-obj-name + obj-list.obj-name + ','
 STR-obj = STR-obj +  obj-list.obj-type + '#' + string(obj-list.obj-code)  + ',' .
End.
Reportname = "Разбивка товаров в чеке по типам кассовых платежей и НДС "
.
ReportHeader =  (if t-cdpay-group
                  then "С группировкой типов кассовых платежей"
                 else "":U) + {&new-line} +
                (if t-rv
                 then "Раздельно по чекам расхода и возврата"
                 else '':U)
.

For each obj-list no-lock:
 Assign
 STR-obj-type = STR-obj-type + obj-list.obj-type + ','
 STR-obj-code = STR-obj-code + String(obj-list.obj-code) + ','
 STR-obj-name = STR-obj-name + obj-list.obj-name + ','
 STR-obj = STR-obj +  obj-list.obj-type + '#' + string(obj-list.obj-code)  + ',' .
End.
for each buf_tt-cash-group:
    if buf_tt-cash-group.obj-name = "":U        then do:
        message "Введите название для всех групп"
        view-as alert-box error.
        return "error":U.
    end.

end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-add-cash-group F-Frame-Win
PROCEDURE proc-add-cash-group :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-grp-code as character no-undo.
define input parameter p-grp-name as character no-undo.
define input parameter p-cash-pay-list as character no-undo.

define variable ii as integer no-undo.
define buffer buf_tt-cash-group for tt-cash-group.
define buffer buf_tt-cash-pay for tt-cash-pay.
define buffer buf_cash-pay for ub.cash-pay.

create buf_tt-cash-group.
assign
buf_tt-cash-group.grp-code = p-grp-code
buf_tt-cash-group.obj-name = p-grp-name
.
do ii = 1 to num-entries(p-cash-pay-list, ";":U):
    find first buf_cash-pay no-lock where
                buf_cash-pay.cdpay-code = integer(entry(1, entry(ii, p-cash-pay-list, ";":U), "-":U))
             AND  buf_cash-pay.curr-code = integer(entry(2, entry(ii, p-cash-pay-list, ";":U), "-":U))          no-error.
    if available buf_cash-pay then do:
        find first buf_tt-cash-pay where
                    buf_tt-cash-pay.cdpay-code =  buf_cash-pay.cdpay-code
                AND buf_tt-cash-pay.curr-code =  buf_cash-pay.curr-code no-error.
                if available buf_tt-cash-pay then do:
                    assign
                    buf_tt-cash-pay.grp-code = buf_tt-cash-group.grp-code
                    .
               end.
    end.
end.
{&open-query-BR-cash-pay}
{&open-query-BR-cpay-group}


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE send-records F-Frame-Win  _ADM-SEND-RECORDS
PROCEDURE send-records :
/*------------------------------------------------------------------------------
  Purpose:     Send record ROWID's for all tables used by
               this file.
  Parameters:  see template/snd-head.i
------------------------------------------------------------------------------*/

  /* Define variables needed by this internal procedure.               */
  {src/adm/template/snd-head.i}

  /* For each requested table, put it's ROWID in the output list.      */
  {src/adm/template/snd-list.i "tt-cash-group"}
  {src/adm/template/snd-list.i "tt-cash-pay"}

  /* Deal with any unexpected table requests before closing.           */
  {src/adm/template/snd-end.i}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE set-cash-group F-Frame-Win
PROCEDURE set-cash-group :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-clear as logical no-undo.
define input parameter p-set as logical no-undo.
define variable ii as integer no-undo.
define buffer buf_tt-cash-group for tt-cash-group.
define buffer buf_tt-cash-pay for tt-cash-pay.
assign
v-uf-list_ = "":U
v-uf-naim = "":U
.
for each buf_tt-cash-group:
    assign
    ii = 0
    v-uf-list_ = v-uf-list_ + (if v-uf-list_ = "":U then "":U else {&delim-par}) +
                     trim(buf_tt-cash-group.grp-code, {&delim-par}) + "=":U +
                     buf_tt-cash-group.obj-name
    v-uf-naim = v-uf-Naim + (if v-uf-Naim = "":U then "":U else {&delim-par})
    .
    for each buf_tt-cash-pay where
                buf_tt-cash-pay.grp-code = buf_tt-cash-group.grp-code:
           ii = ii + 1.
          assign
          v-uf-NAim = v-uf-Naim + (if ii = 1 then "":U else ";") +
                string(buf_tt-cash-pay.cdpay-code) + "-":U + string(buf_tt-cash-pay.curr-code)
          .
          if p-clear then
          assign
          buf_tt-cash-pay.grp-code = {&delim-par} + "0":U
          .
      end.
      if p-clear then
      delete buf_tt-cash-group.
    .
end.
if p-set then do:
  run uf-set in this-procedure(
    input  {&uf-pychk-rep}
    ,input  g#userid
    ,input v-uf-List_
    ,input v-uf-Naim
    ,input v-uf-print-graft
    ,input v-uf-sort-gr
    ,input v-uf-type-price
    ,input v-uf-type-val
)  no-error .
if error-status:error then undo, return error.
end.



END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE state-changed F-Frame-Win
PROCEDURE state-changed :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  DEFINE INPUT PARAMETER p-issuer-hdl AS HANDLE NO-UNDO.
  DEFINE INPUT PARAMETER p-state AS CHARACTER NO-UNDO.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME