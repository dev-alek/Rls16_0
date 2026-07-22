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

вызов отчета "сведения о показаниях счетчиков ККМ и выручке КМ-3"

Автор: Комаров Иван Сергеевич
Дата создания: 21/10/09
Author: Ivan Komarov
Creation date: 21/10/09

Автор1: Белоусов Илья Александрович

*/
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "вызов второй страницы параметров отчета КМ-3".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i  }
{ rep/rep-bt.i   }
{ gbl/onewin.i   }
{ gbl/thbjattr.i }
{ gbl/key-rec.i   }

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
define Shared variable is-doc as logical no-undo .

DEFINE VARIABLE rid-list   AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-db-num   AS INTEGER   NO-UNDO.
DEFINE VARIABLE v-obj-code AS INTEGER   NO-UNDO.
DEFINE VARIABLE v-pos-type AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-cash-num AS CHARACTER NO-UNDO.
DEFINE VARIABLE p-date AS DATE NO-UNDO.

DEFINE TEMP-TABLE tt-cash-desk NO-UNDO like ub.cash-desk    .

DEFINE BUFFER buf_cash-desk FOR ub.cash-desk.
/* define buffer buf_tt-cash-desk for tt-cash-desk . */

def var State-source as  WIDGET-HANDLE.
define variable loc-ref-list as character no-undo .

define variable v-count as integer no-undo .
define variable v-profile-id as integer no-undo .
define variable v-output-type as character no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE SmartViewer
&Scoped-define DB-AWARE no

&Scoped-define ADM-SUPPORTED-LINKS Record-Source,Record-Target,TableIO-Target

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME F-Main
&Scoped-define BROWSE-NAME BR-cash-desk

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-cash-desk

/* Definitions for BROWSE BR-cash-desk                                  */
&Scoped-define FIELDS-IN-QUERY-BR-cash-desk tt-cash-desk.cash-num tt-cash-desk.db-num tt-cash-desk.obj-code tt-cash-desk.pos-type
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-cash-desk
&Scoped-define SELF-NAME BR-cash-desk
&Scoped-define QUERY-STRING-BR-cash-desk FOR EACH tt-cash-desk NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BR-cash-desk OPEN QUERY {&SELF-NAME} FOR EACH tt-cash-desk NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BR-cash-desk tt-cash-desk
&Scoped-define FIRST-TABLE-IN-QUERY-BR-cash-desk tt-cash-desk


/* Definitions for FRAME F-Main                                         */
&Scoped-define OPEN-BROWSERS-IN-QUERY-F-Main ~
    ~{&OPEN-QUERY-BR-cash-desk}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-7 BUTTON-cash-desk f-list-kkm ~
BR-cash-desk t-excel t-TEXT f-sel-kkm
&Scoped-Define DISPLAYED-OBJECTS f-text1 f-text2 f-list-kkm t-excel t-TEXT ~
f-sel-kkm

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE BUTTON BUTTON-cash-desk
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "..."
     SIZE 3.63 BY 1.04.

DEFINE VARIABLE f-list-kkm AS CHARACTER FORMAT "X(256)":U INITIAL "Список ККМ:"
     VIEW-AS FILL-IN NATIVE
     SIZE 63.5 BY .88
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE f-sel-kkm AS CHARACTER FORMAT "X(256)":U INITIAL "Выбор ККМ:"
      VIEW-AS TEXT
     SIZE 10 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE f-text1 AS CHARACTER FORMAT "X(256)":U INITIAL "ПЕЧАТЬ АКТА ВЫПОЛНЯЕТСЯ ТОЛЬКО ПО ТЕМ ККМ,"
     VIEW-AS FILL-IN
     SIZE 43.5 BY .75 NO-UNDO.

DEFINE VARIABLE f-text2 AS CHARACTER FORMAT "X(256)":U INITIAL "ПО КОТОРЫМ БЫЛИ НЕИСПОЛЬЗОВАННЫЕ ЧЕКИ"
     VIEW-AS FILL-IN
     SIZE 43.5 BY .75 NO-UNDO.

DEFINE RECTANGLE RECT-7
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 71.38 BY 16.75.

DEFINE VARIABLE t-excel AS LOGICAL INITIAL no
     LABEL "Excel"
     VIEW-AS TOGGLE-BOX
     SIZE 13 BY 1 NO-UNDO.

DEFINE VARIABLE t-TEXT AS LOGICAL INITIAL no
     LABEL "TEXT"
     VIEW-AS TOGGLE-BOX
     SIZE 13 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-cash-desk FOR
      tt-cash-desk SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-cash-desk
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-cash-desk s-object _FREEFORM
  QUERY BR-cash-desk NO-LOCK DISPLAY
      tt-cash-desk.cash-num COLUMN-LABEL "Номер кассы" FORMAT ">>>9":U
      tt-cash-desk.db-num COLUMN-LABEL "БД" FORMAT ">>>>9":U
      tt-cash-desk.obj-code COLUMN-LABEL "Магазин" FORMAT "99999":U WIDTH 8
      tt-cash-desk.pos-type COLUMN-LABEL "Тип кассы" FORMAT "X(20)" WIDTH 20
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 70.5 BY 13.5 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     f-text1 AT ROW 1.25 COL 1.5 NO-LABEL WIDGET-ID 30
     f-text2 AT ROW 2 COL 1.5 NO-LABEL WIDGET-ID 32
     BUTTON-cash-desk AT ROW 3 COL 65.5
     f-list-kkm AT ROW 3.13 COL 1.5 NO-LABEL WIDGET-ID 26
     BR-cash-desk AT ROW 4.25 COL 1.5 WIDGET-ID 100
     t-excel AT ROW 5.13 COL 31 WIDGET-ID 24
     t-TEXT AT ROW 5.13 COL 51.5 WIDGET-ID 22
     f-sel-kkm AT ROW 2.08 COL 59.5 COLON-ALIGNED NO-LABEL WIDGET-ID 28
     RECT-7 AT ROW 1 COL 1
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 1 ROW 1 SCROLLABLE
         BGCOLOR 8 .


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: SmartViewer
   Allow: Basic,DB-Fields
   Frames: 1
   Add Fields to: EXTERNAL-TABLES
   Other Settings: PERSISTENT-ONLY
 */

/* This procedure should always be RUN PERSISTENT.  Report the error,  */
/* then cleanup and return.                                            */
IF NOT THIS-PROCEDURE:PERSISTENT THEN DO:
  MESSAGE "{&FILE-NAME} should only be RUN PERSISTENT.":U
          VIEW-AS ALERT-BOX ERROR BUTTONS OK.
  RETURN.
END.

&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB)
  CREATE WINDOW s-object ASSIGN
         HEIGHT             = 16.75
         WIDTH              = 71.38.
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
/* BROWSE-TAB BR-cash-desk f-list-kkm F-Main */
ASSIGN
       FRAME F-Main:SCROLLABLE       = FALSE
       FRAME F-Main:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN f-list-kkm IN FRAME F-Main
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN f-text1 IN FRAME F-Main
   NO-ENABLE ALIGN-L                                                    */
ASSIGN
       f-text1:HIDDEN IN FRAME F-Main           = TRUE
       f-text1:READ-ONLY IN FRAME F-Main        = TRUE.

/* SETTINGS FOR FILL-IN f-text2 IN FRAME F-Main
   NO-ENABLE ALIGN-L                                                    */
ASSIGN
       f-text2:HIDDEN IN FRAME F-Main           = TRUE
       f-text2:READ-ONLY IN FRAME F-Main        = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-cash-desk
/* Query rebuild information for BROWSE BR-cash-desk
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-cash-desk NO-LOCK INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE BR-cash-desk */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME F-Main
/* Query rebuild information for FRAME F-Main
     _Options          = "NO-LOCK"
     _Query            is NOT OPENED
*/  /* FRAME F-Main */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME BUTTON-cash-desk
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-cash-desk s-object
ON CHOOSE OF BUTTON-cash-desk IN FRAME F-Main /* ... */
DO:
  run ref/cashlist.w
        ( INPUT  my-handle
        , INPUT  'b-sel,b-mark':U
        , INPUT  (if is-doc then {&g___object} else {&all})
        , INPUT  v-cntxt-db-num
        , INPUT  v-cntxt-host-code-obj
        , INPUT  v-cntxt-obj-type /* !!! */
        , INPUT  v-cntxt-obj-code /* !!! */
        , INPUT  ?
        , OUTPUT rid-list
        )
        NO-ERROR
        .
  IF ERROR-STATUS:ERROR THEN
  DO:
     MESSAGE vss-workfile vss-revision vss-description
              skip(1)
              skip "Ошибка выбора ККМ."
              skip return-value
              skip trim(error-status :get-message(1))
                 trim(error-status :get-message(2))
                 trim(error-status :get-message(3))
        view-as alert-box error.
        RETURN NO-APPLY.
  END.
  IF rid-list = '' THEN
  DO:
      MESSAGE "Не была выбрана ни одна ККМ."
               view-as alert-box error.
      RETURN NO-APPLY.
  END.
ASSIGN
  v-cash-num = ""
    .
FOR EACH tt-cash-desk:
    DELETE tt-cash-desk.
END.
DO v-count = 1 TO NUM-ENTRIES(rid-list):
  FIND FIRST buf_cash-desk WHERE RECID(buf_cash-desk) = INTEGER(ENTRY(v-count,rid-list))
                           NO-LOCK
                           NO-ERROR
                           .
  IF NOT AVAILABLE buf_cash-desk THEN DO:
     MESSAGE vss-workfile vss-revision vss-description
             skip(1)
             skip "Ошибка выбора ККМ."
             skip return-value
             skip trim(error-status :get-message(1))
                  trim(error-status :get-message(2))
                  trim(error-status :get-message(3))
             view-as alert-box error.
      RETURN NO-APPLY.
  END.

  IF v-cash-num = "" THEN DO:
    ASSIGN
      v-cash-num = STRING(buf_cash-desk.cash-num)
    .
  END.
  ELSE DO:
      ASSIGN
        v-cash-num = v-cash-num + "," + STRING(buf_cash-desk.cash-num)
      .
  END.
  CREATE tt-cash-desk.
      ASSIGN
       tt-cash-desk.cash-num = buf_cash-desk.cash-num
       tt-cash-desk.db-num   = buf_cash-desk.db-num
       tt-cash-desk.obj-code = buf_cash-desk.obj-code
       tt-cash-desk.pos-type = buf_cash-desk.pos-type
       tt-cash-desk.cash-os  = buf_cash-desk.cash-os

       .
      RELEASE tt-cash-desk.
END.
  if is-doc <> yes then do :
    find first ubflt.usr-flt WHERE ubflt.usr-flt.user-name  = v-cntxt-userid AND ubflt.usr-flt.call-point = "e-km3.w":U EXCLUSIVE-LOCK no-error.
     IF AVAILABLE ubflt.usr-flt THEN do:
        ASSIGN
          ubflt.usr-flt.list_ = rid-list
         .
     END.
     ELSE DO:
         CREATE ubflt.usr-flt.
         ASSIGN ubflt.usr-flt.user-name = v-cntxt-userid
                ubflt.usr-flt.call-point = "e-km3.w":U
                ubflt.usr-flt.list_ = rid-list
         .
         RELEASE ubflt.usr-flt.
     END.
  end.
assign
  f-list-kkm = "Список ККМ: " + v-cash-num
.

DISPLAY f-list-kkm WITH FRAME F-Main.
{&OPEN-QUERY-BR-cash-desk}

  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-cash-desk
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK s-object


/* ***************************  Main Block  *************************** */

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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-apply-layout s-object
PROCEDURE local-apply-layout :
/*------------------------------------------------------------------------------
  Purpose:     Override standard ADM method
  Notes:
------------------------------------------------------------------------------*/

  /* Code placed here will execute PRIOR to standard behavior. */

  /* Dispatch standard ADM method.                             */
  RUN dispatch IN THIS-PROCEDURE ( INPUT 'apply-layout':U ) .

  /* Code placed here will execute AFTER standard behavior.    */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-initialize s-object
PROCEDURE local-initialize :
RUN dispatch IN THIS-PROCEDURE ( INPUT 'initialize':U ) .
if is-doc then do :
  CASE place-call:
    WHEN {&TABLE_schedule}
    or when {&table_rp-by-call}
    THEN DO:
      RUN rcps_get-profile-id IN parent-handle ( OUTPUT v-profile-id).
      CASE v-profile-id:
        WHEN 72 THEN DO:
          disable
          br-cash-desk
          button-cash-desk
          with frame {&frame-name} .
          hide
          br-cash-desk
          button-cash-desk
          f-sel-kkm
          f-list-kkm
          in frame {&frame-name} .
          enable
          t-excel
          t-text
          with frame {&frame-name} .
        end.
      end case. /*CASE v-profile-id:*/
    end.
    otherwise do:
      hide
      t-excel
      t-text
      in frame {&frame-name} .
      display
      f-text1 f-text2 f-list-kkm f-sel-kkm
      with frame {&frame-name} .
      for each buf_cash-desk no-lock
        where buf_cash-desk.obj-code = v-cntxt-obj-code
          :
          IF v-cash-num = "" THEN DO:
          ASSIGN v-cash-num = STRING(buf_cash-desk.cash-num)
          .
          END.
          ELSE DO:
              ASSIGN v-cash-num = {&all}
              .
          END.
          CREATE tt-cash-desk.
          ASSIGN
          tt-cash-desk.cash-num = buf_cash-desk.cash-num
          tt-cash-desk.db-num   = buf_cash-desk.db-num
          tt-cash-desk.obj-code = buf_cash-desk.obj-code
          tt-cash-desk.pos-type = buf_cash-desk.pos-type
          .
          RELEASE tt-cash-desk.
      end.
      ASSIGN f-list-kkm = "Выбор ККМ: " + v-cash-num
      .
      DISPLAY f-list-kkm WITH FRAME F-Main.

    end.
  end case. /*  CASE place-call:*/
end.
else do :
  hide
  t-excel
  t-text
  in frame {&frame-name} .
DEFINE BUFFER buf_usr-flt FOR  ubflt.usr-flt .
 find first buf_usr-flt where buf_usr-flt.user-name  = v-cntxt-userid AND buf_usr-flt.call-point = "e-km3.w":U
                           NO-LOCK
                           NO-ERROR
                           .
IF AVAILABLE buf_usr-flt THEN do:
      ASSIGN rid-list = buf_usr-flt.list_
      .

    DO v-count = 1 TO NUM-ENTRIES(rid-list):

        FIND FIRST buf_cash-desk WHERE RECID(buf_cash-desk) = INTEGER(ENTRY(v-count,rid-list))
                           NO-LOCK
                           NO-ERROR
                           .
        IF NOT AVAILABLE buf_cash-desk THEN DO:
        MESSAGE vss-workfile vss-revision vss-description
             skip(1)
             skip "Ошибка выбора ККМ."
             skip return-value
             skip trim(error-status :get-message(1))
                  trim(error-status :get-message(2))
                  trim(error-status :get-message(3))
             view-as alert-box error.
        RETURN NO-APPLY.
        END.

        IF v-cash-num = "" THEN DO:
        ASSIGN v-cash-num = STRING(buf_cash-desk.cash-num)
        .
        END.
        ELSE DO:
            ASSIGN v-cash-num = v-cash-num + "," + STRING(buf_cash-desk.cash-num)
             .
        END.
        CREATE tt-cash-desk.
        ASSIGN
        tt-cash-desk.cash-num = buf_cash-desk.cash-num
        tt-cash-desk.db-num   = buf_cash-desk.db-num
        tt-cash-desk.obj-code = buf_cash-desk.obj-code
        tt-cash-desk.pos-type = buf_cash-desk.pos-type
        .
        RELEASE tt-cash-desk.
    END.
      ASSIGN f-list-kkm = "Выбор ККМ: " + v-cash-num
      .
      DISPLAY f-list-kkm WITH FRAME F-Main.
END.
end.
{&OPEN-QUERY-BR-cash-desk}

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
    IF v-profile-id = 72  THEN DO:
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
    END. /*IF v-profile-id = 72  THEN DO:*/
    RUN local-initialize IN THIS-PROCEDURE.
  END.
  WHEN 'set' THEN DO:
    IF v-profile-id = 72 THEN DO:
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
IF v-cash-num = "" THEN
  DO:
      MESSAGE "Не выбрана ни одна ККМ."
               view-as alert-box error.
      RETURN NO-APPLY.
  END.
  ASSIGN p-date = x-date-start
      .
  run rep/r-km3.p (
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
                  , INPUT p-date
                    ,input is-doc
                    ,input yes /*t-text*/
                    ,input yes /*t-excel*/
                    ,input '' /*p-dir-name*/
                    ,input table tt-cash-desk
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
assign /*frame {&frame-name}  f-list-kkm*/
ReportHeader = "Выбор касс: " + {&new-line} + v-cash-num
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
      /* link-changed */
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