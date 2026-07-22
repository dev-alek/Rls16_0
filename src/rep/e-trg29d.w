&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI ADM1
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS s-object
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Форма Торг-29 (закладка №2)

Автор: Демин Алексей Сергеевич
Дата создания: 10/24/08
Author: Alexey Demin
Creation date: 10/24/08

Input:

Output:

*/

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Форма Торг-29 (закладка №2)".

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i  }
{ rep/rep-bt.i   }
{ cmp/str-glbl.i }
{ gbl/key-rec.i   }

define variable v-profile-id as integer no-undo .
define variable v-output-type as character no-undo .
define variable v-price-type as integer no-undo .
define variable v-val-type as character no-undo .


CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

def var State-source as  WIDGET-HANDLE.
define variable lns-cnt as integer   no-undo .
define variable v-tax-rate-list as character no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE SmartObject
&Scoped-define DB-AWARE no

&Scoped-define ADM-SUPPORTED-LINKS Record-Source,Record-Target,TableIO-Target

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME F-Main

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS r-tax T-without-vat E-tax-list t-break-by-cp ~
t-no-covered-techrfsl t-ext-doc-type-subtotals t-excel t-TEXT f-tax-rate
&Scoped-Define DISPLAYED-OBJECTS T-without-vat E-tax-list t-break-by-cp ~
t-no-covered-techrfsl t-ext-doc-type-subtotals t-excel t-TEXT f-tax-rate

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE BUTTON r-tax
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U NO-FOCUS
     LABEL ""
     SIZE 4.4 BY .8 TOOLTIP "Выбор ставки НДС"
     BGCOLOR 8 FGCOLOR 8 .

DEFINE VARIABLE E-tax-list AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 78 BY 7.73 NO-UNDO.

DEFINE VARIABLE f-tax-rate AS CHARACTER FORMAT "X(256)":U INITIAL "Выбор ставки НДС"
      VIEW-AS TEXT
     SIZE 19.5 BY .67 NO-UNDO.

DEFINE VARIABLE t-break-by-cp AS LOGICAL INITIAL no
     LABEL "С разбивкой по типам кассовых платежей (только для документов продажи)"
     VIEW-AS TOGGLE-BOX
     SIZE 76.5 BY 1.07 NO-UNDO.

DEFINE VARIABLE t-excel AS LOGICAL INITIAL no
     LABEL "Excel"
     VIEW-AS TOGGLE-BOX
     SIZE 13 BY 1 NO-UNDO.

DEFINE VARIABLE t-ext-doc-type-subtotals AS LOGICAL INITIAL no 
     LABEL "Разделять по типам документов и выводить подитоги" 
     VIEW-AS TOGGLE-BOX
     SIZE 76.5 BY 1.07 NO-UNDO.

DEFINE VARIABLE t-no-covered-techrfsl AS LOGICAL INITIAL no
     LABEL "Не выводить полностью ПОГАШЕННЫЕ списание/приход по техпроливу"
     VIEW-AS TOGGLE-BOX
     SIZE 76.5 BY 1.07 NO-UNDO.

DEFINE VARIABLE t-TEXT AS LOGICAL INITIAL no
     LABEL "TEXT"
     VIEW-AS TOGGLE-BOX
     SIZE 13 BY 1 NO-UNDO.

DEFINE VARIABLE T-without-vat AS LOGICAL INITIAL no
     LABEL "Суммы без НДС"
     VIEW-AS TOGGLE-BOX
     SIZE 21 BY 1 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     r-tax AT ROW 3.37 COL 26 WIDGET-ID 4
     T-without-vat AT ROW 2.07 COL 35.5 WIDGET-ID 16
     E-tax-list AT ROW 4.73 COL 4.5 NO-LABEL WIDGET-ID 6
     t-break-by-cp AT ROW 12.73 COL 4.5 WIDGET-ID 10
     t-no-covered-techrfsl AT ROW 13.8 COL 4.5 WIDGET-ID 12
     t-ext-doc-type-subtotals AT ROW 15.07 COL 4.5 WIDGET-ID 14
     t-excel AT ROW 17 COL 4.5 WIDGET-ID 20
     t-TEXT AT ROW 17 COL 25 WIDGET-ID 22
     f-tax-rate AT ROW 3.13 COL 2.5 COLON-ALIGNED NO-LABEL WIDGET-ID 24
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
  CREATE WINDOW s-object ASSIGN
         HEIGHT             = 20.1
         WIDTH              = 112.4.
/* END WINDOW DEFINITION */
                                                                        */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB s-object
/* ************************* Included-Libraries *********************** */

{src/adm/method/viewer.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW s-object
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME F-Main
   NOT-VISIBLE FRAME-NAME Size-to-Fit                                   */
ASSIGN
       FRAME F-Main:SCROLLABLE       = FALSE
       FRAME F-Main:PRIVATE-DATA     =
                "DLGCLOSE".

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

&Scoped-define SELF-NAME r-tax
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-tax s-object
ON CHOOSE OF r-tax IN FRAME F-Main
DO:
  define variable v-num               as integer      no-undo.
  define variable v-ind               as integer      no-undo.
  define variable v-curr-rid          as integer      no-undo.
  define buffer buf_tax-rate          for ub.tax-rate.
  define variable tax-rate-rid as char no-undo init "".

  run ref/tax-tree.w (
         input my-handle
         ,INPUT "b-seltax-rate,b-marktax-rate"
         ,INPUT "ALL-TAX-RATES" /* ref-mode */
         ,INPUT 0 /*parhost-code */
         ,INPUT ""
         ,INPUT 0
         ,INPUT ?
         ,INPUT-OUTPUT tax-rate-rid
         ) NO-ERROR.
   IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
   ASSIGN
   v-num = num-entries (tax-rate-rid)
   e-tax-list = "":U
  v-tax-rate-list = ''
       .
   DO v-ind = 1 to v-num
    :
    v-curr-rid = int(entry(v-ind, tax-rate-rid)).
    find first buf_tax-rate no-lock
    where  recid(buf_tax-rate) = v-curr-rid
    no-error.
    if available buf_tax-rate
    then do:
        ASSIGN
        e-tax-list = SUBSTITUTE("&1&2&3", e-tax-list, (if e-tax-list = '' then '' else {&new-line}), buf_tax-rate.rate-name)
        v-tax-rate-list = v-tax-rate-list + (if v-tax-rate-list = '' then '' else {&comma-char}) + string(buf_tax-rate.rate-code)
        .
     END.
   END.
   DISPLAY e-tax-list with frame {&frame-name}.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK s-object


/* ***************************  Main Block  *************************** */
{ gbl/personly.i }
/* If testing in the UIB, initialize the SmartObject. */

&IF DEFINED(UIB_IS_RUNNING) <> 0 &THEN
  RUN dispatch IN THIS-PROCEDURE ('initialize':U).
&ENDIF

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI s-object  _DEFAULT-DISABLE
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE GOTO-first-page s-object
PROCEDURE GOTO-first-page :
message " Для этого отчета надо выбрать только один товар ! вернитесь на закладку <Параметры> и выберите 1 товар ".
   { rep/get-link.i 'State':U}
   run Select1 IN State-source.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ini-from-SET_PAY_TYPE s-object
PROCEDURE ini-from-SET_PAY_TYPE :
CASE x-SET_PAY_TYPE :
    WHEN {&p-cost} THEN DO:
      ENABLE
      t-without-vat
      WITH FRAME {&FRAME-NAME}.
    END. /* {&g-all} */
    otherwise DO:
      ASSIGN
      t-without-vat = NO
      .
      DISPLAY
      t-without-vat
      WITH FRAME {&FRAME-NAME}.
      DISABLE
      t-without-vat
      WITH FRAME {&FRAME-NAME}.

    END. /* otherwise */
  END CASE. /* X-Set_pay_type */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-initialize s-object
PROCEDURE local-initialize :
/*------------------------------------------------------------------------------
  Purpose:     Override standard ADM method
  Notes:
------------------------------------------------------------------------------*/

  /* Code placed here will execute PRIOR to standard behavior. */
CASE place-call:
  WHEN {&TABLE_schedule}
  or when {&table_rp-by-call}
  THEN DO:
    RUN rcps_get-profile-id IN parent-handle ( OUTPUT v-profile-id).
    CASE v-profile-id:
      WHEN 69 THEN DO:
        disable
        r-tax
        e-tax-list
        f-tax-rate
        with frame {&frame-name} .
        hide
        f-tax-rate
        r-tax
        e-tax-list
        in frame {&frame-name} .
        enable
        t-excel
        t-text
        with frame {&frame-name} .
      end.
    end case. /*CASE v-profile-id:*/
  end.
  otherwise do:
    disable
    t-excel
    t-text
    with frame {&frame-name} .
    hide
    t-excel
    t-text
    in frame {&frame-name} .
  end.
end case.

  /* Dispatch standard ADM method.                             */
  RUN dispatch IN THIS-PROCEDURE ( INPUT 'initialize':U ) .
  RUN ini-from-SET_PAY_TYPE IN THIS-PROCEDURE.
   END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-params s-object
PROCEDURE my-params :
define input parameter p-action as character no-undo .
define variable v-index-id as integer no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as integer no-undo .
define variable v-value-logical as logical no-undo .


CASE p-action :
  WHEN 'get' THEN DO:
    IF v-profile-id = 69  THEN DO:
       v-index-id = 0.
       RUN rcps_get-value IN parent-handle (
                                          input "p-without-vat"
                                         ,INPUT-output v-index-id
                                         ,output v-value-character /*p-value-character*/
                                         ,output v-value-date /*p-value-date*/
                                         ,output v-value-decimal /*p-value-decimal*/
                                         ,output v-value-integer /*p-value-integer*/
                                         ,output t-without-vat /*p-value-logical*/
                                         ) no-error .
       v-index-id = 0.
       RUN rcps_get-value IN parent-handle (
                                          input "p-break-by-cp"
                                         ,INPUT-output v-index-id
                                         ,output v-value-character /*p-value-character*/
                                         ,output v-value-date /*p-value-date*/
                                         ,output v-value-decimal /*p-value-decimal*/
                                         ,output v-value-integer /*p-value-integer*/
                                         ,output t-break-by-cp /*p-value-logical*/
                                         ) no-error .

       v-index-id = 0.
       RUN rcps_get-value IN parent-handle (
                                          input "p-no-covered-techrfsl"
                                         ,INPUT-output v-index-id
                                         ,output v-value-character /*p-value-character*/
                                         ,output v-value-date /*p-value-date*/
                                         ,output v-value-decimal /*p-value-decimal*/
                                         ,output v-value-integer /*p-value-integer*/
                                         ,output t-no-covered-techrfsl /*p-value-logical*/
                                         ) no-error .
       v-index-id = 0.
       RUN rcps_get-value IN parent-handle (
                                          input "p-ext-doc-type-subtotals"
                                         ,INPUT-output v-index-id
                                         ,output v-value-character /*p-value-character*/
                                         ,output v-value-date /*p-value-date*/
                                         ,output v-value-decimal /*p-value-decimal*/
                                         ,output v-value-integer /*p-value-integer*/
                                         ,output t-ext-doc-type-subtotals /*p-value-logical*/
                                         ) no-error .
       v-index-id = 0.
       RUN rcps_get-value IN parent-handle (
                                          input "p-price-type"
                                         ,INPUT-output v-index-id
                                         ,output v-value-character /*p-value-character*/
                                         ,output v-value-date /*p-value-date*/
                                         ,output v-value-decimal /*p-value-decimal*/
                                         ,output v-price-type /*p-value-integer*/
                                         ,output v-value-logical /*p-value-logical*/
                                         ) no-error .

       v-index-id = 0.
       RUN rcps_get-value IN parent-handle (
                                          input "p-r-b"
                                         ,INPUT-output v-index-id
                                         ,output v-val-type  /*p-value-character*/
                                         ,output v-value-date /*p-value-date*/
                                         ,output v-value-decimal /*p-value-decimal*/
                                         ,output v-value-integer /*p-value-integer*/
                                         ,output v-value-logical /*p-value-logical*/
                                         ) no-error .


       v-index-id = 0.
       RUN rcps_get-value IN parent-handle (
                                          input "p-output-type"
                                         ,INPUT-output v-index-id
                                         ,output v-output-type /*p-value-character*/
                                         ,output v-value-date /*p-value-date*/
                                         ,output v-value-decimal /*p-value-decimal*/
                                         ,output v-value-integer /*p-value-integer*/
                                         ,output v-value-logical /*p-value-logical*/
                                         ) no-error .
       assign
       t-without-vat:screen-value in frame {&frame-name} =  string(t-without-vat)
       t-break-by-cp:screen-value in frame {&frame-name} =  string(t-break-by-cp)
       t-no-covered-techrfsl:screen-value in frame {&frame-name} =  string(t-no-covered-techrfsl)
       t-ext-doc-type-subtotals:screen-value in frame {&frame-name} =  string(t-ext-doc-type-subtotals)
       t-excel:screen-value in frame {&frame-name} =  string(lookup({&output-type-excel}, v-output-type) > 0)
       t-text:screen-value in frame {&frame-name} = string(lookup({&output-type-plain-text}, v-output-type) > 0)
       .

    END. /*IF v-profile-id = 69  THEN DO:*/
    RUN local-initialize IN THIS-PROCEDURE.
  END.
  WHEN 'set' THEN DO:
    IF v-profile-id = 69 THEN DO:
      ASSIGN
      FRAME {&FRAME-NAME}
      t-without-vat
      t-break-by-cp
      t-no-covered-techrfsl
      t-ext-doc-type-subtotals
      t-text
      t-excel
      v-output-type = ","
      ENTRY(1, v-output-type) = (IF t-excel THEN {&output-type-excel} ELSE '')
      ENTRY(2, v-output-type) = (IF t-text THEN {&output-type-plain-text} ELSE '')
      v-output-type = TRIM(v-output-type, {&comma-char})
      .
      if not t-excel
      and not t-text then do:
        define variable glog as logical no-undo .
        message
        "Внимание!! Вы не выбрали ни вывод в текстовый файл, ни вывод в Excel!" skip
        "Продолжить?"
        view-as alert-box question buttons yes-no update glog.
        if not glog then return error.
      end.

      RUN rcps_set-value IN parent-handle (
                                        input "p-without-vat"
                                      ,INPUT 0
                                      ,input '' /*p-value-character*/
                                      ,input ?  /*p-value-date*/
                                      ,input 0.0 /*p-value-decimal*/
                                      ,input 0 /*p-value-integer*/
                                      ,input t-without-vat /*p-value-logical*/
                                      ) no-error .
      RUN rcps_set-value IN parent-handle (
                                        input "p-break-by-cp"
                                      ,INPUT 0
                                      ,input '' /*p-value-character*/
                                      ,input ?  /*p-value-date*/
                                      ,input 0.0 /*p-value-decimal*/
                                      ,input 0 /*p-value-integer*/
                                      ,input t-break-by-cp /*p-value-logical*/
                                      ) no-error .
      RUN rcps_set-value IN parent-handle (
                                        input "p-no-covered-techrfsl"
                                      ,INPUT 0
                                      ,input '' /*p-value-character*/
                                      ,input ?  /*p-value-date*/
                                      ,input 0.0 /*p-value-decimal*/
                                      ,input 0 /*p-value-integer*/
                                      ,input t-no-covered-techrfsl /*p-value-logical*/
                                      ) no-error .
      RUN rcps_set-value IN parent-handle (
                                        input "p-ext-doc-type-subtotals"
                                      ,INPUT 0
                                      ,input '' /*p-value-character*/
                                      ,input ?  /*p-value-date*/
                                      ,input 0.0 /*p-value-decimal*/
                                      ,input 0 /*p-value-integer*/
                                      ,input t-ext-doc-type-subtotals /*p-value-logical*/
                                      ) no-error .
      RUN rcps_set-value IN parent-handle (
                                        input "p-output-type"
                                      ,INPUT 0
                                      ,input v-output-type /*p-value-character*/
                                      ,input ?  /*p-value-date*/
                                      ,input 0.0 /*p-value-decimal*/
                                      ,input 0 /*p-value-integer*/
                                      ,input no /*p-value-logical*/
                                      ) no-error .

      RUN rcps_set-value IN parent-handle (
                                        input "p-price-type"
                                      ,INPUT 0
                                      ,input '' /*p-value-character*/
                                      ,input ?  /*p-value-date*/
                                      ,input 0.0 /*p-value-decimal*/
                                      ,input x-SET_PAY_TYPE  /*p-value-integer*/
                                      ,input no /*p-value-logical*/
                                      ) no-error .
      v-val-type = if X-SET_val_TYPE = {&v-base} then {&r-b-base} else {&r-b-rubl}.
      RUN rcps_set-value IN parent-handle (
                                        input "p-r-b"
                                      ,INPUT 0
                                      ,input v-val-type /*p-value-character*/
                                      ,input ?  /*p-value-date*/
                                      ,input 0.0 /*p-value-decimal*/
                                      ,input x-SET_PAY_TYPE  /*p-value-integer*/
                                      ,input no /*p-value-logical*/
                                      ) no-error .

    END. /*IF v-profile-id = 69 THEN DO:*/
  END.
END CASE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-report s-object
PROCEDURE my-report :
/*------------------------------------------------------------------------------
  Purpose:     здесь происходит вызов  процедуры отчета
------------------------------------------------------------------------------*/
run rep/r-trg29d.p (
                     input my-handle
                    ,input this-procedure:handle /*p-parent-handle*/
                    ,input this-procedure:handle /*      p-log-handle*/
                    ,input this-procedure:handle /*   p-cont-handle*/
                    ,input this-procedure:handle /*p-call-handle*/
                    ,input ? /*p-rebh*/
                    ,input ? /*p-redbh*/
                    ,input '' /*p-report-id*/
                    ,input integer({&repcalc-type-operator}) /*p-batch*/
                    ,input 0 /*p-codex-id*/
                    ,input 0 /*p-ruleset-id*/
                    ,input "" /*p-log-file-name*/
                    ,input t-without-vat
                   ,input v-tax-rate-list
                   ,INPUT t-break-by-cp
                   ,input t-no-covered-techrfsl
                   ,input t-ext-doc-type-subtotals
                    ,input t-text
                    ,input t-excel
                    ,input '' /*p-dir-name*/
                    ) no-error.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-var s-object
PROCEDURE my-var :
/*------------------------------------------------------------------------------
  Purpose:     здесь происходит вызов  значений переменных
  например  Название отчета, может быть еще пример шапки ???
------------------------------------------------------------------------------*/
/*строки в которых содержатся выбранные объекты */
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
ASSIGN FRAME {&FRAME-NAME}
t-without-vat
t-break-by-cp
t-no-covered-techrfsl
t-ext-doc-type-subtotals
.
ASSIGN
reportheader  =
(IF v-tax-rate-list <> ''
THEN substitute("Только товары со ставкой НДС на &1 из списка &2"
                , STRING(X-date-start)
                , v-tax-rate-list)
ELSE '') + {&NEW-LINE} +
(IF t-Without-vat
THEN "Суммы БЕЗ НДС"
ELSE '') + {&NEW-LINE} +
(IF t-break-by-cp
THEN "С разбивкой по типам кассовых платежей (только для документов продажи)"
ELSE '') + {&NEW-LINE} +
(IF t-no-covered-techrfsl
THEN "Не выводить полностью ПОГАШЕННЫЕ списание/приход по техпроливу"
ELSE '') + {&NEW-LINE} +
(IF t-ext-doc-type-subtotals
THEN "Рзаделять по типам документов и выводить подитоги"
ELSE '')

.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE state-changed s-object
PROCEDURE state-changed :
/* -----------------------------------------------------------
  Purpose:     Receive and process 'state-changed' methods
               (issued by 'new-state' event).
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  DEFINE INPUT PARAMETER p-issuer-hdl AS HANDLE    NO-UNDO.
  DEFINE INPUT PARAMETER p-state      AS CHARACTER NO-UNDO.

  CASE p-state:
      /* Object instance CASEs can go here to replace standard behavior
         or add new cases. */
    When 'link-changed':U then do:
         if lns-cnt > 1 and NOT Link# Then
            run goto-first-page in this-procedure.
      RUN ini-from-SET_PAY_TYPE IN THIS-PROCEDURE.
    End.

  END CASE.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE write-to-log s-object
PROCEDURE write-to-log :
define input param p-str as char no-undo.

do
on error undo, return error
:
   message
      p-str
      skip
   view-as alert-box error.

end. /* do on error */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
