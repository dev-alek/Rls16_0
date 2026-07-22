&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI ADM1
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS V-table-Win
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Оборот в валюте поставщика

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/28/05
Author: Bakhtadze Natalya
Creation date: 12/28/05

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
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Оборот в валюте поставщика".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/library.i }
{ cmp/showinf.i }
{ cmp/r-page1.i  }
{ gbl/prn-lib.i }
{ cus/r-obval.i "def" "NEW SHARED" }
{ cmp/cli-list.i cli-list def "NEW shared" }
{ gbl/waitfram.i }
{ gbl/getcntxt.i def " " my-handle }

define buffer cli-post for ub.clients .
define variable     cli-list                  as char         no-undo.
define buffer buf_currency for ub.currency.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE SmartObject
&Scoped-define DB-AWARE no

&Scoped-define ADM-SUPPORTED-LINKS Record-Source,Record-Target,TableIO-Target

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME F-Main

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-2 RECT-3 RECT-1 R-curr T-terms F-val ~
b-valp T-price-brutto T-price-netto button-prod T-qnty-all E-post T-VAT ~
T-slt T-part-code F-val-name
&Scoped-Define DISPLAYED-OBJECTS R-curr T-terms F-val T-price-brutto ~
T-price-netto T-qnty-all E-post T-VAT T-slt T-part-code F-val-name

/* Custom List Definitions                                              */
/* ADM-CREATE-FIELDS,ADM-ASSIGN-FIELDS,List-3,List-4,List-5,List-6      */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _XFTR "Foreign Keys" V-table-Win _INLINE
/* Actions: ? adm/support/keyedit.w ? ? ? */
/* STRUCTURED-DATA
<KEY-OBJECT>
THIS-PROCEDURE
</KEY-OBJECT>
<FOREIGN-KEYS>
</FOREIGN-KEYS>
<EXECUTING-CODE>
**************************
* Set attributes related to FOREIGN KEYS
*/
RUN set-attribute-list (
    'Keys-Accepted = "",
     Keys-Supplied = ""':U).
/**************************
</EXECUTING-CODE> */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE BUTTON b-valp
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY .88.

DEFINE BUTTON button-prod
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "button-prod"
     SIZE 3 BY .88.

DEFINE VARIABLE E-post AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 32.63 BY 8.88 NO-UNDO.

DEFINE VARIABLE F-val AS INTEGER FORMAT ">>9":U INITIAL ?
     VIEW-AS FILL-IN
     SIZE 3.38 BY 1 NO-UNDO.

DEFINE VARIABLE F-val-name AS CHARACTER FORMAT "X(256)":U INITIAL "?"
      VIEW-AS TEXT
     SIZE 22.13 BY 1 NO-UNDO.

DEFINE VARIABLE R-curr AS INTEGER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Все", 0,
"Выборочно", 1
     SIZE 31 BY 1 NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 34.88 BY 11.13.

DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 34.63 BY 4.54.

DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 25.5 BY 15.75.

DEFINE VARIABLE T-part-code AS LOGICAL INITIAL no
     LABEL "Номер партии"
     VIEW-AS TOGGLE-BOX
     SIZE 21.88 BY .83 NO-UNDO.

DEFINE VARIABLE T-price-brutto AS LOGICAL INITIAL no
     LABEL "Цена по ТТН"
     VIEW-AS TOGGLE-BOX
     SIZE 21.88 BY .83 NO-UNDO.

DEFINE VARIABLE T-price-netto AS LOGICAL INITIAL no
     LABEL "Цена нетто"
     VIEW-AS TOGGLE-BOX
     SIZE 21.88 BY .83 NO-UNDO.

DEFINE VARIABLE T-qnty-all AS LOGICAL INITIAL no
     LABEL "Внешний  приход"
     VIEW-AS TOGGLE-BOX
     SIZE 21.88 BY .83 NO-UNDO.

DEFINE VARIABLE T-slt AS LOGICAL INITIAL no
     LABEL "Значение НП п-ка"
     VIEW-AS TOGGLE-BOX
     SIZE 21.88 BY .83 NO-UNDO.

DEFINE VARIABLE T-terms AS LOGICAL INITIAL no
     LABEL "Условия   поставки"
     VIEW-AS TOGGLE-BOX
     SIZE 21.88 BY .83 NO-UNDO.

DEFINE VARIABLE T-VAT AS LOGICAL INITIAL no
     LABEL "Значение НДС п-ка"
     VIEW-AS TOGGLE-BOX
     SIZE 21.88 BY .83 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     R-curr AT ROW 2.83 COL 4 NO-LABEL
     T-terms AT ROW 3.25 COL 38.75
     F-val AT ROW 4.33 COL 1.13 COLON-ALIGNED NO-LABEL
     b-valp AT ROW 4.33 COL 32
     T-price-brutto AT ROW 4.46 COL 38.75
     T-price-netto AT ROW 5.71 COL 38.75
     button-prod AT ROW 6.38 COL 28.13
     T-qnty-all AT ROW 6.88 COL 38.75
     E-post AT ROW 7.79 COL 2.88 NO-LABEL
     T-VAT AT ROW 8.21 COL 38.75
     T-slt AT ROW 9.5 COL 38.75
     T-part-code AT ROW 10.63 COL 38.63
     F-val-name AT ROW 4.29 COL 6 COLON-ALIGNED NO-LABEL
     "Выбор поставщиков" VIEW-AS TEXT
          SIZE 20.25 BY .88 AT ROW 6.29 COL 3.13
          FGCOLOR 4
     "Выводить поля :" VIEW-AS TEXT
          SIZE 22.25 BY 1 AT ROW 1.67 COL 38.88
          FGCOLOR 4
     "Выбор валюты поставки" VIEW-AS TEXT
          SIZE 21.75 BY .88 AT ROW 1.63 COL 3.75
          FGCOLOR 4
     RECT-2 AT ROW 1.21 COL 2.13
     RECT-3 AT ROW 1.29 COL 37.38
     RECT-1 AT ROW 5.88 COL 1.88
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 1 ROW 1 SCROLLABLE .


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: SmartObject
   Allow: Basic,DB-Fields
   Frames: 1
   Add Fields to: External-Tables
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB)
  CREATE WINDOW V-table-Win ASSIGN
         HEIGHT             = 16.21
         WIDTH              = 62.5.
/* END WINDOW DEFINITION */
                                                                        */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB V-table-Win
/* ************************* Included-Libraries *********************** */

{src/adm/method/viewer.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW V-table-Win
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME F-Main
   NOT-VISIBLE Size-to-Fit                                              */
ASSIGN
       FRAME F-Main:SCROLLABLE       = FALSE
       FRAME F-Main:HIDDEN           = TRUE.

ASSIGN
       b-valp:HIDDEN IN FRAME F-Main           = TRUE.

ASSIGN
       E-post:READ-ONLY IN FRAME F-Main        = TRUE.

ASSIGN
       F-val:HIDDEN IN FRAME F-Main           = TRUE.

ASSIGN
       F-val-name:HIDDEN IN FRAME F-Main           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME F-Main
/* Query rebuild information for FRAME F-Main
     _Options          = "NO-LOCK"
     _Query            is NOT OPENED
*/  /* FRAME F-Main */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME b-valp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-valp V-table-Win
ON CHOOSE OF b-valp IN FRAME F-Main
DO:
define variable v-ref-rec as recid no-undo .
find first buf_currency no-lock where
          buf_currency.curr-code = f-val no-error.
if available buf_currency then do:
  assign
  v-ref-rec = recid(buf_currency)
  .
end.
else do:
  assign
  v-ref-rec = ?.
end.
run ref/currency.w (input my-handle, INPUT "b-sel", INPUT-OUTPUT v-ref-rec ).
apply "ENTRY" to self .
if v-ref-rec = ? then do:
    assign
    F-val  = ?
    F-val-name = "?"
    .
    display
    F-val
    F-val-name
    with frame {&frame-name}.
    return no-apply.
end.
else do:
    FIND FIRST Buf_currency No-LOCK WHERE
                recid( buf_currency ) = v-ref-rec NO-ERROR .
    assign
    F-val  = buf_currency.curr-code
    F-val-name = buf_currency.curr-abbr
    .
    display
    F-val
    F-val-name
    with frame {&frame-name}.
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME button-prod
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL button-prod V-table-Win
ON CHOOSE OF button-prod IN FRAME F-Main /* button-prod */
DO:
    run str/cli-list.w (my-handle, v-cntxt-host-code-obj, v-cntxt-obj-type, v-cntxt-obj-code).
    E-post:screen-value = "".
    for each cli-list:
        assign
        E-post:screen-value = E-post:screen-value + cli-list.obj-name + {&new-line} .
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME F-val
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL F-val V-table-Win
ON LEAVE OF F-val IN FRAME F-Main
DO:
define buffer buf_currency for ub.currency.
  assign
  F-val.
  FIND FIRST buf_currency No-LOCK WHERE
             buf_currency.curr-code = F-val No-ERROR.
  IF AVAIL buf_currency then do:
    assign
    F-val-name = buf_currency.curr-abbr.
    DISPLAY
    F-val
    F-val-name
    with frame {&frame-name}
    .
  end.
  else do:
    APPLY "CHOOSE" to b-valp.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME R-curr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL R-curr V-table-Win
ON VALUE-CHANGED OF R-curr IN FRAME F-Main
DO:
  assign r-curr.
  CASE r-curr:
    when 0 then do:
    /*все*/
        DISABLE
        b-valp F-val F-val-name
        with frame {&frame-name}.
        HIDE
        b-valp F-val F-val-name
        IN frame {&frame-name}.
    end.
    when 1 then do:
    /*выборочно*/
        ENABLE
        b-valp F-val F-val-name
        with frame {&frame-name}.

    end.
  END CASE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK V-table-Win


/* ***************************  Main Block  *************************** */
{ gbl/personly.i }
{ gbl/getcntxt.i get " " my-handle }
  &IF DEFINED(UIB_IS_RUNNING) <> 0 &THEN
    RUN dispatch IN THIS-PROCEDURE ('initialize':U).
  &ENDIF

  /************************ INTERNAL PROCEDURES ********************/

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-row-available V-table-Win  _ADM-ROW-AVAILABLE
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI V-table-Win  _DEFAULT-DISABLE
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-initialize V-table-Win
PROCEDURE local-initialize :
/*------------------------------------------------------------------------------
  Purpose:     Override standard ADM method
  Notes:
------------------------------------------------------------------------------*/

  /* Code placed here will execute PRIOR to standard behavior. */

  /* Dispatch standard ADM method.                             */
  RUN dispatch IN THIS-PROCEDURE ( INPUT 'initialize':U ) .

  /* Code placed here will execute AFTER standard behavior.    */
  APPLY "VALUE-CHANGED" TO r-curr in frame {&frame-name}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE My-report V-table-Win
PROCEDURE My-report :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable vnum-obj as integer no-undo.
define variable v-frame-width as integer no-undo.
run My-var in this-procedure .
if r-curr = 1 then do:
    if not avail buf_currency or f-val = ? or f-val-name = "?" then do:
        Message "Не выбрана валюта  поставки!"
        view-as alert-box ERROR.
        return.
    end.
end.
find first cli-list No-ERROR.
if not avail cli-list then do:
    message "Не выбрано ни одного поставщика!"
    view-as alert-box ERROR.
    return.
end.


FOR EACH obj-list No-LOCK:
  assign
  vnum-obj = vnum-obj + 1
  .
  if vnum-obj > 1 then LEAVE.
END.


run cus/r-obval.p (
               input my-handle
              ,input      (if r-curr = 1 then f-val else ?),
                     vnum-obj) no-error  .
run cus/p-obval.p (input my-handle,
              input (if r-curr = 1 then f-val else ?),
              input vnum-obj,
              input (X-selectobject = {&all}),
              input ReportHeader,
              output v-frame-width) no-error.
if v-frame-width <= 198 then do:
  if v-frame-width <= 136
  then
  run prn-lib-prn-file in this-procedure (
                                            input my-handle
                                            ,input 0
                                            ).
  else
  run prn-lib-prn-file in this-procedure (
                                            input my-handle
                                            ,input 8
                                            ).
end.
else do:
    if v-frame-width <= 232 then
    run prn-lib-prn-file in this-procedure (
                                              input my-handle
                                              ,input 1
                                              ).

    else
    run prn-lib-prn-file in this-procedure (
                                              input my-handle
                                              ,input 20
                                              ).

end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE My-var V-table-Win
PROCEDURE My-var :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
Assign
r-curr frame {&frame-name}
T-part-code T-price-brutto T-price-netto T-qnty-all T-slt T-terms T-VAT
f-val
E-post
use-column[5] = T-terms
use-column[6] = T-part-code
use-column[10] = T-price-brutto
use-column[11] = T-vat
use-column[12] = T-slt
use-column[13] = T-price-netto
use-column[14] = T-qnty-all

 STR-obj-type = ''
 STR-obj-code = ''
 STR-obj-name = ''
 STR-obj      = ''.

ReportNAme = "Оборот в валюте поставщика".
ReportHeader =  (if (frame {&frame-name} r-curr = 1 )
                then
                ("Валюта  поставки:  " + F-val-name + {&new-line})
                else ""
               ) +
               "Поставщики: " + {&new-line} + E-post
               .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE send-records V-table-Win  _ADM-SEND-RECORDS
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE state-changed V-table-Win
PROCEDURE state-changed :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  DEFINE INPUT PARAMETER p-issuer-hdl AS HANDLE    NO-UNDO.
  DEFINE INPUT PARAMETER p-state      AS CHARACTER NO-UNDO.

  CASE p-state:
      /* Object instance CASEs can go here to replace standard behavior
         or add new cases. */
      {src/adm/template/vstates.i}
  END CASE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME