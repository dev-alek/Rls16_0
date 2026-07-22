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

Кассовая книга

Автор: Комаров Иван Сергеевич
Дата создания: 11/26/09
Author: Ivan Komarov
Creation date: 11/26/09

*/

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Кассовая книга".
{ cmp/vssrevis.i  }
{ cmp/str-glbl.i  }
{ cmp/r-page1.i   }
{ cmp/operlist.i  }
{ rep/rep-bt.i    }
{ gbl/twowin.i   }
{ gbl/usr-flt.i }

CREATE WIDGET-POOL.
{ gbl/key-rec.i   }


/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
define variable v-nn as integer   no-undo .
define variable State-source as  WIDGET-HANDLE.
define variable g#log as logical   no-undo .

define variable v-curr-r-b               as character no-undo .
define variable v-print-rubl             as logical   no-undo .

define variable p-customer as integer no-undo .
define variable v-res as character no-undo .

define variable v-profile-id as integer no-undo .
define variable v-output-type as character no-undo .

define variable ii as integer no-undo .
DEFINE VARIABLE v-printform AS integer NO-UNDO.

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
&Scoped-Define ENABLED-OBJECTS RECT-13 print-form t-excel t-TEXT
&Scoped-Define DISPLAYED-OBJECTS print-form t-excel t-TEXT

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE VARIABLE print-form AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Вкладной лист кассовой книги", 1,
"Отчет кассира", 2
     SIZE 34 BY 3 NO-UNDO.

DEFINE RECTANGLE RECT-13
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 42 BY 5.

DEFINE VARIABLE t-excel AS LOGICAL INITIAL no
     LABEL "Excel"
     VIEW-AS TOGGLE-BOX
     SIZE 13 BY 1 NO-UNDO.

DEFINE VARIABLE t-TEXT AS LOGICAL INITIAL no
     LABEL "TEXT"
     VIEW-AS TOGGLE-BOX
     SIZE 13 BY 1 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     print-form AT ROW 2.27 COL 5.5 NO-LABEL WIDGET-ID 14
     t-excel AT ROW 6.33 COL 3.5 WIDGET-ID 24
     t-TEXT AT ROW 6.33 COL 24 WIDGET-ID 22
     RECT-13 AT ROW 1.27 COL 2 WIDGET-ID 18
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
         HEIGHT             = 16.77
         WIDTH              = 75.
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
       FRAME F-Main:HIDDEN           = TRUE.

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

&Scoped-define SELF-NAME print-form
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL print-form s-object
ON VALUE-CHANGED OF print-form IN FRAME F-Main
DO:
  assign print-form.
  if not (place-call = {&TABLE_schedule}
          or
          place-call = {&table_rp-by-call}
          ) then do:
  find first ubflt.usr-flt share-lock
   where ubflt.usr-flt.user-name  = v-cntxt-userid
     and ubflt.usr-flt.call-point = "e-cash-bk":U
     no-error .
     if available ubflt.usr-flt then do:
        assign
           ubflt.usr-flt.naim  = string(print-form)
        .
     End.
     else do:
        assign frame {&frame-name} print-form.
        create ubflt.usr-flt.
        assign
          ubflt.usr-flt.user-name = v-cntxt-userid
          ubflt.usr-flt.call-point = "e-cash-bk":U
          ubflt.usr-flt.naim  = string(print-form)
        .
     end.
    end.
assign
  v-printform = print-form
.
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-initialize s-object
PROCEDURE local-initialize :
/*------------------------------------------------------------------------------
  Purpose:     Override standard ADM method
  Notes:
------------------------------------------------------------------------------*/

  /* Code placed here will execute PRIOR to standard behavior. */

  /* Dispatch standard ADM method.                             */
  RUN dispatch IN THIS-PROCEDURE ( INPUT 'initialize':U ) .

  /* Code placed here will execute AFTER standard behavior.    */

CASE place-call:
  WHEN {&TABLE_schedule}
  or when {&table_rp-by-call}
  THEN DO:
    RUN rcps_get-profile-id IN parent-handle ( OUTPUT v-profile-id).
    CASE v-profile-id:
      WHEN 71 THEN DO:
        print-form = 2.
        display
        print-form
        with frame {&frame-name} .
        disable
        print-form
        with frame {&frame-name} .
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
  find first ubflt.usr-flt share-lock
   where ubflt.usr-flt.user-name  = v-cntxt-userid
     and ubflt.usr-flt.call-point = "e-cash-bk":U
   no-error .
     if available ubflt.usr-flt then do:
         assign print-form = integer(ubflt.usr-flt.naim) .
     end.
     else do:
         assign frame {&frame-name} print-form.
         create ubflt.usr-flt.
         assign
           ubflt.usr-flt.user-name = v-cntxt-userid
           ubflt.usr-flt.call-point = "e-cash-bk":U
           ubflt.usr-flt.naim  = string(print-form)
         .
     end.
    display
    print-form
    with frame {&FRAME-NAME} .
assign
  v-printform = print-form
.
  end.
end case.
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
    IF v-profile-id = 71  THEN DO:
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
       t-excel:screen-value in frame {&frame-name} =  string(lookup({&output-type-excel}, v-output-type) > 0)
       t-text:screen-value in frame {&frame-name} = string(lookup({&output-type-plain-text}, v-output-type) > 0)
       .
    END. /*IF v-profile-id = 71  THEN DO:*/
    RUN local-initialize IN THIS-PROCEDURE.
  END.
  WHEN 'set' THEN DO:
    IF v-profile-id = 71 THEN DO:
      ASSIGN
      FRAME {&FRAME-NAME}
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
                                        input "p-output-type"
                                      ,INPUT 0
                                      ,input v-output-type /*p-value-character*/
                                      ,input ?  /*p-value-date*/
                                      ,input 0.0 /*p-value-decimal*/
                                      ,input 0 /*p-value-integer*/
                                      ,input no /*p-value-logical*/
                                      ) no-error .
    END. /*IF v-profile-id = 71 THEN DO:*/
  END.
END CASE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-report s-object
PROCEDURE my-report :
/*------------------------------------------------------------------------------
  Purpose:     здесь происходит вызов  процедуры отчета с любыми параметрами
------------------------------------------------------------------------------*/
run rep/r-cashbk.p
    (
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
    ,input print-form
    ,input yes /*t-text*/
    ,input yes /*t-excel*/
    ,input '' /*p-dir-name*/
      ) .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-var s-object
PROCEDURE my-var :
/*------------------------------------------------------------------------------
  Purpose:     здесь происходит вызов  значений переменных
  например  Название отчета, может быть еще пример шапки???
------------------------------------------------------------------------------*/
assign frame {&frame-name} print-form
.
  assign
    ReportHeader = if v-printform = 1 then "Вкладной лист кассовой книги" else "Отчет кассира"
  .
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
