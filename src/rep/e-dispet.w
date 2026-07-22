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

Отчет диспетчера.  (ЗАКЛАДКА №2)

Автор: Белоусов Илья Александрович
Дата создания: 11/22/07
Author: Ilia Belousov
Creation date: 11/22/07

*/

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Отчет диспетчера  (ЗАКЛАДКА №2)".

{ cmp/vssrevis.i  }
{ cmp/str-glbl.i  }
{ gbl/cur-time.i  }
{ cmp/r-page1.i   }
{ gbl/key-rec.i   }
CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

DEFINE VARIABLE State-source      as WIDGET-HANDLE NO-UNDO .
DEFINE VARIABLE v-time-prediction AS INTEGER       NO-UNDO .
DEFINE VARIABLE v-date-prediction AS DATE          NO-UNDO .
define variable v-cli-list        as character     no-undo .
DEFINE VARIABLE v-output-type     AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-esys-id         AS integer NO-UNDO.
DEFINE VARIABLE v-profile-id         AS integer NO-UNDO.

define variable loc-ref-list as character no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE SmartViewer
&Scoped-define DB-AWARE no

&Scoped-define ADM-SUPPORTED-LINKS Record-Source,Record-Target,TableIO-Target

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME F-Main

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-7 v-hours v-minutes t-excel t-xml ~
b-esys
&Scoped-Define DISPLAYED-OBJECTS v-hours v-minutes t-excel t-xml f-text-2 ~
f-text-1 f-esys-id f-esys-name

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE BUTTON b-esys
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1"
     SIZE 4 BY 1.

DEFINE VARIABLE f-esys-id AS INTEGER FORMAT ">>>>>>9":U INITIAL 0
     LABEL "Код Внеш.системы, в которую идет выгрузка"
      VIEW-AS TEXT
     SIZE 10 BY .67 NO-UNDO.

DEFINE VARIABLE f-esys-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 68.5 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE f-text-1 AS CHARACTER FORMAT "X(256)":U INITIAL "Время отчета"
      VIEW-AS TEXT
     SIZE 13.5 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE f-text-2 AS CHARACTER FORMAT "X(256)":U INITIAL ":"
      VIEW-AS TEXT
     SIZE .8 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE v-hours AS INTEGER FORMAT "99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 3 BY 1
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE v-minutes AS INTEGER FORMAT "99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 3 BY 1
     BGCOLOR 15  NO-UNDO.

DEFINE RECTANGLE RECT-7
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 71.4 BY 16.27.

DEFINE VARIABLE t-excel AS LOGICAL INITIAL no
     LABEL "Excel"
     VIEW-AS TOGGLE-BOX
     SIZE 20 BY 1 NO-UNDO.

DEFINE VARIABLE t-xml AS LOGICAL INITIAL no
     LABEL "XML"
     VIEW-AS TOGGLE-BOX
     SIZE 20 BY 1 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     v-hours AT ROW 2.13 COL 17.5 COLON-ALIGNED NO-LABEL
     v-minutes AT ROW 2.13 COL 22 COLON-ALIGNED NO-LABEL
     t-excel AT ROW 4 COL 10.5 WIDGET-ID 6
     t-xml AT ROW 5 COL 10.5 WIDGET-ID 8
     b-esys AT ROW 7.4 COL 63 WIDGET-ID 16
     f-text-2 AT ROW 2.3 COL 22.8 NO-LABEL WIDGET-ID 12
     f-text-1 AT ROW 2.33 COL 2.5 COLON-ALIGNED NO-LABEL WIDGET-ID 10
     f-esys-id AT ROW 7.4 COL 48 COLON-ALIGNED WIDGET-ID 14
     f-esys-name AT ROW 9.53 COL 2 COLON-ALIGNED NO-LABEL WIDGET-ID 18
     RECT-7 AT ROW 1.27 COL 2
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
         HEIGHT             = 16.77
         WIDTH              = 73.
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

/* SETTINGS FOR FILL-IN f-esys-id IN FRAME F-Main
   NO-ENABLE                                                            */
ASSIGN
       f-esys-id:READ-ONLY IN FRAME F-Main        = TRUE.

/* SETTINGS FOR FILL-IN f-esys-name IN FRAME F-Main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN f-text-1 IN FRAME F-Main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN f-text-2 IN FRAME F-Main
   NO-ENABLE ALIGN-L                                                    */
ASSIGN
       t-excel:HIDDEN IN FRAME F-Main           = TRUE.

ASSIGN
       t-xml:HIDDEN IN FRAME F-Main           = TRUE.

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

&Scoped-define SELF-NAME b-esys
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-esys s-object
ON CHOOSE OF b-esys IN FRAME F-Main /* Btn 1 */
DO:
RUN get-ext-system IN THIS-PROCEDURE  ( INPUT YES).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME v-hours
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-hours s-object
ON LEAVE OF v-hours IN FRAME F-Main
DO:
   ASSIGN
     v-hours
   .
   RUN mandatory-24 IN THIS-PROCEDURE
      (INPUT-OUTPUT v-hours ) .
   ASSIGN
      v-time-prediction = v-hours * 60 * 60 + v-minutes * 60
   .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME v-minutes
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-minutes s-object
ON LEAVE OF v-minutes IN FRAME F-Main
DO:
   ASSIGN
     v-minutes
   .
   RUN mandatory-60 IN THIS-PROCEDURE
      (INPUT-OUTPUT v-minutes ) .
   ASSIGN
        v-time-prediction = v-hours * 60 * 60 + v-minutes * 60
   .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-ext-system s-object
PROCEDURE get-ext-system :
DEFINE INPUT PARAMETER p-interface AS LOGICAL NO-UNDO.
DEFINE VARIABLE v-ok AS LOGICAL NO-UNDO.
DEFINE VARIABLE v-int AS integer NO-UNDO.
DEFINE VARIABLE v-uniq-key-rec AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-tbl-row AS rowid NO-UNDO.
DEFINE VARIABLE v-tbl-name AS CHARACTER NO-UNDO.
DEFINE BUFFER buf_ext-system FOR ub.ext-system.
IF f-esys-id <> 0  THEN DO:
   FIND FIRST buf_ext-system NO-LOCK WHERE
                buf_ext-system.esys-id = f-esys-id
         AND buf_ext-system.db-num = 0 NO-ERROR.
   IF AVAILABLE buf_ext-system THEN DO:
       RUN gen-key-rec IN THIS-PROCEDURE ( INPUT {&TABLE_ext-system}
                                          ,INPUT (BUFFER buf_ext-system:HANDLE)
                                          ,OUTPUT v-uniq-key-rec) NO-ERROR.
   END.
END.
 IF p-interface THEN DO:
      run bge/oxmlexts.p (
            input my-handle
          , input 2                         /* 2- Единичный выбор - 0. Множественный - 1*/
          , input substitute("esys-type = &1", {&openxml-type-com-dashboard}) /*p-where-string*/
          , input v-uniq-key-rec        /* То, что уже выбрано (список) */
          , output v-rid-list          /* Список выбранных подсистем ( string( db-num ) + chr(6) + string( esys-id ) )*/
          , output v-ok               /* yes, если выбор был сделан. no - Если был отказ от выбора */
      ).

     IF NOT v-ok  THEN RETURN ERROR.

          run gen-row-keyr in this-procedure
          ( input v-rid-list
           ,input ?
           ,input "ub"
           ,input ?
           ,input no-lock
           ,output v-tbl-row
           ,output v-tbl-name
         ).
        find first buf_ext-system no-lock where
                  rowid(buf_ext-system) = v-tbl-row.

  END.
  IF AVAILABLE buf_ext-system
  AND (buf_ext-system.esys-id   <> f-esys-id
  OR NOT p-interface) THEN DO:
    f-esys-id = buf_ext-system.esys-id.
    f-esys-name = buf_ext-system.esys-NAME.
    DISPLAY
    f-esys-id
    f-esys-name
    WITH FRAME {&FRAME-NAME}.

  END.
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
define variable v-seconds    as integer      no-undo.
   define variable v-time    as integer      no-undo.

   RUN dispatch IN THIS-PROCEDURE ( INPUT 'initialize':U ) .
   CASE place-call:
     WHEN {&TABLE_schedule} THEN DO:
       RUN rcps_get-profile-id IN parent-handle ( OUTPUT v-profile-id).
       CASE v-profile-id:
         WHEN 50 THEN DO:
       HIDE
       v-hours IN FRAME {&FRAME-NAME}
       v-minutes
       f-text-1
               f-esys-id
               b-esys
               f-esys-name
       IN FRAME {&FRAME-NAME}.
       t-excel = LOOKUP({&output-type-excel}, v-output-type) > 0.
       t-xml = LOOKUP({&output-type-xml}, v-output-type) > 0.
       display
       t-excel
       t-xml
       WITH FRAME {&FRAME-NAME}.
       ENABLE
       t-excel WHEN params-only-mode <> {&LOOKUP}
       t-xml WHEN params-only-mode <> {&LOOKUP}
       WITH FRAME {&FRAME-NAME}.

     END.
           WHEN 52 THEN DO:
             HIDE
             v-hours IN FRAME {&FRAME-NAME}
             v-minutes
             f-text-1
             t-excel
             t-xml
             IN FRAME {&FRAME-NAME}.
             f-esys-id = v-esys-id.
             RUN get-ext-system IN THIS-PROCEDURE ( INPUT NO).
             DISPLAY
             f-esys-id
             f-esys-name
             WITH FRAME {&FRAME-NAME}.
             ENABLE
             b-esys WHEN params-only-mode <> {&LOOKUP}
             WITH FRAME {&FRAME-NAME}.

           END.

       END CASE.
     END.
     OTHERWISE DO:
         run cur-time ( output v-date-prediction
                      , output v-time-prediction
                      ).

         assign
            v-time = v-time-prediction
            v-seconds = v-time MODULO 60
            v-time = (v-time - v-seconds) / 60
         .

         assign
            v-minutes = v-time MODULO 60
         .

         assign
            v-hours = (v-time - v-minutes) / 60
         .

         display
         v-hours
         v-minutes
         f-text-1
         f-text-2
         with frame {&FRAME-NAME} .
         HIDE
         t-excel
         t-xml
         b-esys
         f-esys-id
         f-esys-name
         in FRAME {&frame-name}.
     END.
   END CASE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE mandatory-24 s-object
PROCEDURE mandatory-24 :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE INPUT-OUTPUT PARAMETER p-time AS INTEGER NO-UNDO .
DO
ON error undo, RETURN:
   IF p-time > 23 THEN DO:
       ASSIGN
           p-time = 23
       .
       RETURN .
   END.
   IF p-time < 0 THEN DO:
       ASSIGN
           p-time = 0
       .
       RETURN .
   END.
END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE mandatory-60 s-object
PROCEDURE mandatory-60 :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE INPUT-OUTPUT PARAMETER p-time AS INTEGER NO-UNDO .
DO
ON error undo, RETURN:
   IF p-time > 59 THEN DO:
       ASSIGN
           p-time = 59
       .
       RETURN .
   END.
   IF p-time < 0 THEN DO:
       ASSIGN
           p-time = 0
       .
       RETURN .
   END.
END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-params s-object
PROCEDURE my-params :
define input parameter p-action as character no-undo .
/*------------------------------------------------------------------------------
  Purpose:     здесь происходит чтение параметров
------------------------------------------------------------------------------*/
define variable v-shop-code as integer no-undo .
define variable v-index-id as integer no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as integer no-undo .
define variable v-value-logical as logical no-undo .

define variable v-loc-output-type as character no-undo .

case p-action:
  when "get" then do:
    empty temp-table X-init_obj-list.
    v-index-id = 1.
    do while v-index-id >= 1 :
      RUN rcps_get-value IN parent-handle (
                                       input "p-shops"
                                      ,INPUT-output v-index-id
                                      ,output v-value-character /*p-value-character*/
                                      ,output v-value-date /*p-value-date*/
                                      ,output v-value-decimal /*p-value-decimal*/
                                      ,output v-shop-code /*p-value-integer*/
                                      ,output v-value-logical /*p-value-logical*/
                                      ) no-error .
      if error-status:error
      or v-shop-code <= 0
      then do:
       leave.
      end.
      find first X-init_obj-list where
                X-init_obj-list.obj-type = {&shop}
            and  X-init_obj-list.obj-code = v-shop-code no-error.
      if not available X-init_obj-list then do:
        create X-init_obj-list.
        assign
        X-init_obj-list.obj-type = {&shop}
        X-init_obj-list.obj-code = v-shop-code
        .
        release X-init_obj-list.
      end.
    end.
     X-selectobject =  {&obj-choice}.
     IF v-profile-id = 50 THEN DO:

     RUN rcps_get-value IN parent-handle (
                                      input "p-output-type"
                                     ,INPUT-output v-index-id
                                     ,output v-output-type /*p-value-character*/
                                     ,output v-value-date /*p-value-date*/
                                     ,output v-value-decimal /*p-value-decimal*/
                                     ,output v-shop-code /*p-value-integer*/
                                     ,output v-value-logical /*p-value-logical*/
                                     ) no-error .
     END.
     IF v-profile-id = 52  THEN DO:
       v-index-id = 0.
       RUN rcps_get-value IN parent-handle (
                                          input "p-esys-id"
                                         ,INPUT-output v-index-id
                                         ,output v-output-type /*p-value-character*/
                                         ,output v-value-date /*p-value-date*/
                                         ,output v-value-decimal /*p-value-decimal*/
                                         ,output v-esys-id /*p-value-integer*/
                                         ,output v-value-logical /*p-value-logical*/
                                         ) no-error .
     END.
    RUN local-initialize IN THIS-PROCEDURE.
  end.
  when "set" then do:
    IF v-profile-id = 50 THEN DO:
    ASSIGN
    FRAME {&FRAME-NAME}
    t-excel
    t-xml
    v-loc-output-type = ","
    ENTRY(1, v-loc-output-type) = (IF t-excel THEN {&output-type-excel} ELSE '')
    ENTRY(2, v-loc-output-type) = (IF t-xml THEN {&output-type-xml} ELSE '')
    v-loc-output-type = TRIM(v-loc-output-type, {&comma-char})
    .

    RUN rcps_set-value IN parent-handle (
                                     input "p-output-type"
                                    ,INPUT 0
                                    ,input v-loc-output-type /*p-value-character*/
                                    ,input ?  /*p-value-date*/
                                    ,input 0.0 /*p-value-decimal*/
                                    ,input 0 /*p-value-integer*/
                                    ,input no /*p-value-logical*/
                                    ) no-error .


    END.
    IF v-profile-id = 52 THEN DO:
        ASSIGN
        FRAME {&FRAME-NAME}
        f-esys-id
        .
        RUN rcps_set-value IN parent-handle (
                                         input "p-esys-id"
                                        ,INPUT 0
                                        ,input '' /*p-value-character*/
                                        ,input ?  /*p-value-date*/
                                        ,input 0.0 /*p-value-decimal*/
                                        ,input f-esys-id /*p-value-integer*/
                                        ,input no /*p-value-logical*/
                                        ) no-error .


    END.
    v-index-id = 0.
    for each obj-list :
      v-index-id = v-index-id + 1.
      RUN rcps_set-value IN parent-handle (
                                       input "p-shops"
                                      ,INPUT v-index-id
                                      ,input '' /*p-value-character*/
                                      ,input ?  /*p-value-date*/
                                      ,input 0.0 /*p-value-decimal*/
                                      ,input obj-list.obj-code /*p-value-integer*/
                                      ,input no /*p-value-logical*/
                                      ) no-error .
      if error-status:error then do:
        message
        error-status:get-message(1) return-value
        view-as alert-box .
        undo, return error .
      end.
    end. /*    for each obj-list :*/
    v-index-id = v-index-id + 1.
    do while true:
      run rcps_proc-b-del in parent-handle (
                                              input "p-shops"
                                             ,input v-index-id) no-error.
      if error-status:error
      or return-value = "not-found" then leave.
      v-index-id = v-index-id + 1.
    end.
    if error-status:error then do:
      message
      error-status:get-message(1) return-value
      view-as alert-box .
      undo, return error .
    end.
  end.
end case.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-report s-object
PROCEDURE my-report :
/*------------------------------------------------------------------------------
  Purpose:     здесь происходит вызов  процедуры отчета с любыми параметрами
------------------------------------------------------------------------------*/
define variable v-dataseth as handle no-undo .
define variable v-xmlh as handle no-undo .
define buffer buf_clients     for ub.clients .
    ASSIGN
        v-cli-list = "":U
    .
    FOR EACH obj-list
        ,
        FIRST buf_clients
        WHERE buf_clients.obj-type = obj-list.obj-type
          AND buf_clients.obj-code = obj-list.obj-code
        NO-LOCK
        :
        ASSIGN
           v-cli-list = v-cli-list + "," + STRING(RECID(buf_clients))
        .
    END.
    ASSIGN
        v-cli-list = TRIM(v-cli-list, ",")
    .
    run rep/r-dispet.p ( INPUT my-handle
                  , input ? /*p-parent-handle*/
                  , input this-procedure /*p-log-handle*/
                  , input ? /*p-cont-handle*/
                  , input this-procedure:handle /*p-call-handle*/
                  , input ? /*p-repe-bh handle буфера ошибок*/
                  , input ? /*p-repd-bh handle буфера desitonation*/
                  , input "" /*p-report-id - нужна для распис*/
                  , input '' /*p-xsd-file */
                  , input '' /*log-file-name*/
                  , input integer({&repcalc-type-operator}) /*p-batch*/
                  , input 0 /*p-codex-id*/
                  , input 0 /*p-ruleset-id*/
                  , input v-time-prediction
                  , input x-Date-Alone
                  , input v-cli-list
                  , input FALSE /*p-excel*/
                  , input FALSE /*p-xml*/
                  , input "":U /*p-dir-excel*/
                  , input "":U /*p-xml-dir*/
                  , output v-dataseth
                  , output v-xmlh
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
CASE place-call:
  WHEN {&TABLE_schedule} THEN DO:
    case v-profile-id:
      when 50 THEN DO:
        assign
        frame {&frame-name}
        t-excel
        t-xml
        ReportHeader = substitute("&1Направление вывода: &2 &3"
                                  , {&new-line}
                                  , (if t-excel then {&output-type-Excel} else '')
                                  , (if t-xml then {&output-type-xml} else '')).
      end.
      when 52 then do:
        assign
        frame {&frame-name}
        f-esys-id
        .
        ReportHeader = substitute("&1Маршрутизация во ВС: &2 &3"
                                  , {&new-line}
                                  , f-esys-id
                                  , f-esys-name).

      end.
    end case.
  end.
  otherwise do:
/*if cb-type > 0 then  assign ReportHeader = {&new-line} + "Форма отчета : " + entry( cb-type , {&alcdcl-region-name} ) + {&new-line} .*/
    assign
    frame {&frame-name}
    v-hours v-minutes .
    assign
    ReportHeader = substitute("&1Время отчета: &2:&3"
                              , {&new-line}
                              , v-hours
                              , v-minutes).
 end.
end case.
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
