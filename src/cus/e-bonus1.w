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

Начисление и списание бонусов по программе БОНУС-КЛУБ - форма запроса

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/21/06
Author: Bakhtadze Natalya
Creation date: 09/21/06

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
define variable vss-description as character no-undo init "Начисление и списание бонусов по программе БОНУС-КЛУБ-форма запроса" .
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/library.i }
{ cmp/showinf.i }
{ gbl/cur-time.i }
{ cmp/r-page1.i  }
{ cmp/r-pril.i }
{ gbl/prn-lib.i }
{ cmp/operlist.i  }
{ gbl/waitfram.i }
define variable parparentproc as widget-handle no-undo .
{ gbl/usr-flt.i }
{ gbl/getcntxt.i def }

define variable State-source as Widget-Handle.
DEFINE VARIABLE f-cdpay-code AS INTEGER NO-UNDO.
DEFINE VARIABLE f-curr-code AS INTEGER NO-UNDO.

define buffer buf_dis-card-type for ub.dis-card-type.

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
&Scoped-Define ENABLED-OBJECTS RECT-checks f-schema-code b-cashpay TOG-1 ~
TOG-2 TOG-3 f-obj-name
&Scoped-Define DISPLAYED-OBJECTS f-schema-code TOG-1 TOG-2 TOG-3 f-obj-name

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE BUTTON b-cashpay
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "":L
     SIZE 3 BY 1
     BGCOLOR 8 FGCOLOR 0 .

DEFINE VARIABLE f-obj-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Платеж-списание бонусов"
      VIEW-AS TEXT
     SIZE 28.5 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE f-schema-code AS INTEGER FORMAT "999999999":U INITIAL 0
     LABEL "№ бонусной схемы"
     VIEW-AS FILL-IN
     SIZE 10 BY 1 NO-UNDO.

DEFINE RECTANGLE RECT-checks
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 62.38 BY 10.25.

DEFINE VARIABLE TOG-1 AS LOGICAL INITIAL no
     LABEL "Часть 1 - Оборот по товару"
     VIEW-AS TOGGLE-BOX
     SIZE 60 BY .83 TOOLTIP "Лист отчета ~"Движение Нефтепродуктов по количеству~"" NO-UNDO.

DEFINE VARIABLE TOG-2 AS LOGICAL INITIAL no
     LABEL "Часть 2 - Оборот по обслуживанию"
     VIEW-AS TOGGLE-BOX
     SIZE 60 BY .83 TOOLTIP "Лист отчета ~"Движение Нефтепродуктов по количеству и суммам~"" NO-UNDO.

DEFINE VARIABLE TOG-3 AS LOGICAL INITIAL no
     LABEL "Часть 3 - Оборот по датам"
     VIEW-AS TOGGLE-BOX
     SIZE 60 BY .83 TOOLTIP "Лист отчета ~"Движение ТНП по количеству и суммам~"" NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     f-schema-code AT ROW 2.08 COL 19 COLON-ALIGNED
     b-cashpay AT ROW 3.92 COL 58
     TOG-1 AT ROW 6.5 COL 2.5
     TOG-2 AT ROW 7.5 COL 2.5
     TOG-3 AT ROW 8.5 COL 2.5
     f-obj-name AT ROW 4.21 COL 4
     "Показать :" VIEW-AS TEXT
          SIZE 11.5 BY .75 AT ROW 5.79 COL 11.88
          FGCOLOR 4
     RECT-checks AT ROW 1.25 COL 1.5
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 1 ROW 1
         SIZE 63.88 BY 10.92.


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
         HEIGHT             = 10.88
         WIDTH              = 64.5.
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
/* SETTINGS FOR FILL-IN f-obj-name IN FRAME F-Main
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

&Scoped-define SELF-NAME b-cashpay
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-cashpay F-Frame-Win
ON CHOOSE OF b-cashpay IN FRAME F-Main
DO:
    define variable v-rid-list as character no-undo.
    DEFINE BUFFER buf_cash-pay FOR ub.cash-pay.
    run ref/cashpays.w (
                   input parparentproc
                  ,input "b-sel"
                  ,input {&all}
                  ,input v-cntxt-host-code-obj
                  ,input v-cntxt-obj-type
                  ,input v-cntxt-obj-code
                  ,output v-rid-list ).
    if v-rid-list <> "":U then do:
      FIND FIRST buf_cash-pay WHERE
              recid( buf_cash-pay ) = integer(entry(1, v-rid-list)) NO-LOCK .
     DISPLAY
     buf_cash-pay.obj-name @ f-obj-name
     with frame {&frame-name} .
     assign
     f-cdpay-code = buf_cash-pay.cdpay-code
     f-curr-code = buf_cash-pay.curr-code
     .
   end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME TOG-3
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL TOG-3 F-Frame-Win
ON VALUE-CHANGED OF TOG-3 IN FRAME F-Main /* Часть 3 - Оборот по датам */
DO:
  ASSIGN tog-3.
  IF NOT tog-3 THEN
    DO:
      DISABLE /*Classify SortType */ WITH FRAME {&FRAME-NAME} .
    END.
    ELSE DO:
      ENABLE  /*Classify SortType */ WITH FRAME {&FRAME-NAME} .
    END.
  DISPLAY /*Classify  SortType */ WITH FRAME {&FRAME-NAME} .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK F-Frame-Win


/* ***************************  Main Block  *************************** */
{ gbl/personly.i }
parparentproc = my-handle.
{ gbl/getcntxt.i get }
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
  DISPLAY f-schema-code TOG-1 TOG-2 TOG-3 f-obj-name
      WITH FRAME F-Main.
  ENABLE RECT-checks f-schema-code b-cashpay TOG-1 TOG-2 TOG-3 f-obj-name
      WITH FRAME F-Main.
  {&OPEN-BROWSERS-IN-QUERY-F-Main}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-initialize F-Frame-Win
PROCEDURE local-initialize :
define buffer buf_cash-pay for ub.cash-pay.
run uf-get in this-procedure (
     input  {&uf-bon1-rep}
    ,input  v-cntxt-userid
    ,output v-uf-List_
    ,output v-uf-Naim
    ,output v-uf-print-graft
    ,output v-uf-sort-gr
    ,output v-uf-type-price
    ,output v-uf-type-val
)  no-error.

if not error-status:error
and num-entries(v-uf-List_, {&delim-par}) = 3 then do:
  assign
  f-schema-code = integer(entry(1, v-uf-List_, {&delim-par}))
  f-cdpay-code = integer(entry(2, v-uf-List_, {&delim-par}))
  f-curr-code = integer(entry(3, v-uf-List_, {&delim-par}))
  NO-ERROR
  .
  FIND FIRST buf_cash-pay NO-LOCK WHERE
            buf_cash-pay.cdpay-code = f-cdpay-code
        AND buf_cash-pay.curr-code = f-curr-code NO-ERROR.
  IF AVAILABLE buf_cash-pay THEN DO:
    ASSIGN
    f-obj-name = buf_cash-pay.obj-name.
  END.
  ELSE DO:
      ASSIGN
      buf_cash-pay.cdpay-code = 0
      buf_cash-pay.curr-code = 0
      f-obj-name = {&question-mark}.
  END.
end.
run enable_UI IN THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE My-Report F-Frame-Win
PROCEDURE My-Report :
run cus/r-bonus1.p (
                INPUT my-handle
              , INPUT tog-1
              , INPUT tog-2
              , INPUT tog-3
              , INPUT f-schema-code
              , input f-cdpay-code
              , input f-curr-code
              ) .

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
 assign
 FRAME {&frame-name}
 f-schema-code
 tog-1
 tog-2
 tog-3
 .

 if f-schema-code = 0
 or (TOG-1 = NO AND TOG-2 = NO AND TOG-3 = no)
 OR f-cdpay-code = 0  THEN DO:

  message
  "Вы не ввели параметры для формирования отчета" skip(1)
  (if f-schema-code  = 0
   then ("Введите код бонусной схемы"  + {&new-line})
   else "":U)
  (IF (TOG-1 = NO AND TOG-2 = NO AND TOG-3 = no)
   then ("Выберите части отчета, которые Вы хотите вывести"  + {&new-line})
   else "":U)
  (IF f-cdpay-code = 0
   THEN "Выберите тип кассового платежа, соответствующий списанию бонусов"
   ELSE "":U)
   view-as alert-box error .
   return error .
 end.
 assign
 v-uf-list_ = string(f-schema-code, "99999999":U) + {&DELIM-PAR} +
              STRING(f-cdpay-code, "999999999":U) + {&delim-par} +
              STRING(f-curr-code, "999999999":U)

.
/*
код схемы "999999999"
*/
  run uf-set in this-procedure (
     input  {&uf-bon1-rep}
    ,input  v-cntxt-userid
    ,input v-uf-List_
    ,input v-uf-Naim
    ,input v-uf-print-graft
    ,input v-uf-sort-gr
    ,input v-uf-type-price
    ,input v-uf-type-val
)  no-error .


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
ReportHeader =
               substitute("Код бонусной схемы: &1&2"
              , f-schema-code
              , {&NEW-LINE})
                .


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
