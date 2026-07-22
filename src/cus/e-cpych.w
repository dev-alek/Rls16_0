&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI ADM1
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS F-Frame-Win
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Отчет по продажам в разрезе платежных карт - форма задания параметров

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/11/10
Author: Bakhtadze Natalya
Creation date: 02/11/10

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
define variable vss-description as character no-undo init "Суммы продаж с разбивкой по типам кассовых платежей и НДС - форма задания параметров" .
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/showinf.i }
{ gbl/cur-time.i }
{ cmp/r-pril.i new }
{ cmp/r-page1.i  }
{ gbl/waitfram.i }
{ gbl/usr-flt.i }
{ gbl/getcntxt.i def }
define variable parparentproc   as widget-handle no-undo .
DEFINE new shared TEMP-TABLE tt-cash-pay  no-undo LIKE ub.cash-pay.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE SmartObject
&Scoped-define DB-AWARE no

&Scoped-define ADM-CONTAINER FRAME

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME F-Main

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-cp E-cp T-discnt-dtl f-pay-card FILL-IN-1
&Scoped-Define DISPLAYED-OBJECTS E-cp T-discnt-dtl f-pay-card FILL-IN-1

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD display-cp F-Frame-Win
FUNCTION display-cp RETURNS CHARACTER
  ( input p-obj-code as integer, input p-obj-name as character )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE BUTTON b-cp
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1"
     SIZE 3 BY 1.

DEFINE VARIABLE E-cp AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 50 BY 9.6 NO-UNDO.

DEFINE VARIABLE f-pay-card AS CHARACTER FORMAT "X(19)":U
     LABEL "№ плат. карты"
     VIEW-AS FILL-IN
     SIZE 20 BY 1 NO-UNDO.

DEFINE VARIABLE FILL-IN-1 AS CHARACTER FORMAT "X(256)":U INITIAL "Учитываемые в отчете типы кассовых платежей"
      VIEW-AS TEXT
     SIZE 50 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE T-discnt-dtl AS LOGICAL INITIAL no
     LABEL "Детализация по видам скидок"
     VIEW-AS TOGGLE-BOX
     SIZE 46.1 BY 1 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     b-cp AT ROW 2 COL 2 WIDGET-ID 4
     E-cp AT ROW 2.07 COL 6 NO-LABEL WIDGET-ID 2
     T-discnt-dtl AT ROW 12.73 COL 2.5
     f-pay-card AT ROW 13.8 COL 4 WIDGET-ID 6
     FILL-IN-1 AT ROW 1 COL 4 COLON-ALIGNED NO-LABEL WIDGET-ID 8
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
         HEIGHT             = 16.2
         WIDTH              = 67.9.
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
   NOT-VISIBLE FRAME-NAME                                               */
/* SETTINGS FOR FILL-IN f-pay-card IN FRAME F-Main
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME F-Main
/* Query rebuild information for FRAME F-Main
     _Options          = ""
     _Query            is NOT OPENED
*/  /* FRAME F-Main */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME b-cp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-cp F-Frame-Win
ON CHOOSE OF b-cp IN FRAME F-Main /* Btn 1 */
DO:
  run select-cash-pays in this-procedure no-error.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


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
  DISPLAY E-cp T-discnt-dtl f-pay-card FILL-IN-1
      WITH FRAME F-Main.
  ENABLE b-cp E-cp T-discnt-dtl f-pay-card FILL-IN-1
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


for each tt-cash-pay:
    delete tt-cash-pay.
end.
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
find first tt-cash-pay no-error.
if not available tt-cash-pay then do:
  message
  "Не выбран ни один тип кассового платежа"
  view-as alert-box error .
  return .
end.

run My-var IN THIS-PROCEDURE.
if return-value = "error":U then return.



run cus/r-cpych.p ( input my-handle
                    ,input T-discnt-dtl
                    ,input f-pay-card) no-error.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE My-var F-Frame-Win
PROCEDURE My-var :
Assign
frame {&frame-name} t-discnt-dtl
f-pay-card
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
Reportname = "Отчет по продажам в разрезе платежных карт "
.
ReportHeader =  (if t-discnt-dtl
                  then "С детализацией по типам скидок"
                 else "":U) + {&new-line} +
                (if f-pay-card <> ''
                 then substitute("Для платежной карты &1", f-pay-card)
                 else '':U) + {&new-line} +
                 "Учитываемые типы кассовых платежей:"

.
for each tt-cash-pay:
  assign
  reportHeader = reportHeader +  {&new-line} +
                 substitute("&1 - &2"
                            , string(tt-cash-pay.cdpay-code, ">>>>9")
                            , tt-cash-pay.obj-name )
  .
end.

For each obj-list no-lock:
 Assign
 STR-obj-type = STR-obj-type + obj-list.obj-type + ','
 STR-obj-code = STR-obj-code + String(obj-list.obj-code) + ','
 STR-obj-name = STR-obj-name + obj-list.obj-name + ','
 STR-obj = STR-obj +  obj-list.obj-type + '#' + string(obj-list.obj-code)  + ',' .
End.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE select-cash-pays F-Frame-Win
PROCEDURE select-cash-pays :
define variable v-ii as integer   no-undo .
define variable v-rid-list as character no-undo .
define variable glog AS LOGICAL no-undo .
DEFINE BUFFER buf_cash-pay FOR ub.cash-pay.
DEFINE BUFFER buf_tt-cash-pay FOR tt-cash-pay.
ASSIGN
e-cp:SCREEN-VALUE IN FRAME {&FRAME-NAME} = ''.
FOR EACH buf_tt-cash-pay:
   FIND FIRST buf_cash-pay NO-LOCK WHERE
                buf_cash-pay.cdpay-code = buf_tt-cash-pay.cdpay-code
       AND buf_cash-pay.curr-code = buf_tt-cash-pay.curr-code NO-ERROR.
   IF AVAILABLE buf_cash-pay THEN DO:
       v-rid-list = v-rid-list + (IF v-rid-list = '' THEN '' ELSE {&comma-char}) + STRING(RECID(buf_cash-pay)).
   END.
END.
empty temp-table tt-cash-pay.
run ref/cashpays.w
    ( input parparentproc
    , input "b-mark,b-sel"
    , input {&all}
    , input v-cntxt-host-code-obj
    , input v-cntxt-obj-type
    , input v-cntxt-obj-code
    , output v-rid-list ) no-error .
if v-rid-list <> '' then do:
  do v-ii = 1 to num-entries(v-rid-list):
    find first buf_cash-pay no-lock where
              recid(buf_cash-pay) = integer(entry(v-ii, v-rid-list)) no-error.
    if available buf_cash-pay then do:
       FIND FIRST buf_tt-cash-pay NO-LOCK WHERE
                buf_tt-cash-pay.cdpay-code = buf_cash-pay.cdpay-code
           AND buf_tt-cash-pay.curr-code = buf_cash-pay.curr-code NO-ERROR.
       IF NOT AVAILABLE buf_tt-cash-pay  THEN DO:
          CREATE buf_tt-cash-pay.
          BUFFER-COPY buf_cash-pay TO buf_tt-cash-pay.

       END.
       glog = e-cp:INSERT-STRING ( display-cp(
                                                 buf_tt-cash-pay.cdpay-code
                                                 , buf_tt-cash-pay.obj-name )) in frame {&frame-name} .
       glog = e-cp:INSERT-STRING ( {&new-line} ) in frame {&frame-name} .
       release buf_tt-cash-pay.
    end.
  end.
end.
else do:
  undo, return error .
end.

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

  /* SEND-RECORDS does nothing because there are no External
     Tables specified for this SmartObject, and there are no
     tables specified in any contained Browse, Query, or Frame. */

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

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION display-cp F-Frame-Win
FUNCTION display-cp RETURNS CHARACTER
  ( input p-obj-code as integer, input p-obj-name as character ) :
define variable v-string as character no-undo .
v-string = substitute("&1   &2",  string(p-obj-code, ">>>>9"), p-obj-name).
return v-string.

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME