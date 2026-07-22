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

Динамика продаж на АЗС по текущей смене

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/22/10
Author: Bakhtadze Natalya
Creation date: 04/22/10


*/

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Динамика продаж на АЗС по текущей смене".

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
DEFINE VARIABLE v-esys-id         AS integer NO-UNDO.
DEFINE VARIABLE v-profile-id         AS integer NO-UNDO.
define variable v-keep-days-num as integer no-undo .

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
&Scoped-Define ENABLED-OBJECTS RECT-7 b-esys f-keep-days-num
&Scoped-Define DISPLAYED-OBJECTS f-keep-days-num f-esys-id f-esys-name

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

DEFINE VARIABLE f-keep-days-num AS INTEGER FORMAT ">>9":U INITIAL 0
     LABEL "Срок хранения отчета (дни)"
     VIEW-AS FILL-IN
     SIZE 5 BY 1 NO-UNDO.

DEFINE RECTANGLE RECT-7
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 71.4 BY 16.27.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     b-esys AT ROW 7.4 COL 63 WIDGET-ID 16
     f-keep-days-num AT ROW 11.67 COL 48.5 COLON-ALIGNED WIDGET-ID 20
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
           WHEN 51 THEN DO:
             f-keep-days-num = v-keep-days-num.
             f-esys-id = v-esys-id.
             RUN get-ext-system IN THIS-PROCEDURE ( INPUT NO).
             DISPLAY
             f-esys-id
             f-esys-name
             f-keep-days-num
             WITH FRAME {&FRAME-NAME}.
             ENABLE
             b-esys WHEN params-only-mode <> {&LOOKUP}
             WITH FRAME {&FRAME-NAME}.
           END.
       END CASE.
     END.
     OTHERWISE DO:
        HIDE
        b-esys
        f-esys-id
        f-esys-name
        f-keep-days-num
        in FRAME {&frame-name}.
     END.
   END CASE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-params s-object
PROCEDURE my-params :
define input parameter p-action as character no-undo .
/*------------------------------------------------------------------------------
  Purpose:     здесь происходит чтение параметров
------------------------------------------------------------------------------*/
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as integer no-undo .
define variable v-value-logical as logical no-undo .
define variable v-index-id as integer no-undo .
define variable v-loc-output-type as character no-undo .

case p-action:
  when "get" then do:
     IF v-profile-id = 51  THEN DO:
       v-index-id = 0.
       RUN rcps_get-value IN parent-handle (
                                          input "p-esys-id"
                                         ,INPUT-output v-index-id
                                         ,output v-value-character /*p-value-character*/
                                         ,output v-value-date /*p-value-date*/
                                         ,output v-value-decimal /*p-value-decimal*/
                                         ,output v-esys-id /*p-value-integer*/
                                         ,output v-value-logical /*p-value-logical*/
                                         ) no-error .
       v-index-id = 0.
       RUN rcps_get-value IN parent-handle (
                                          input "p-keep-days-num"
                                         ,INPUT-output v-index-id
                                         ,output v-value-character /*p-value-character*/
                                         ,output v-value-date /*p-value-date*/
                                         ,output v-value-decimal /*p-value-decimal*/
                                         ,output v-keep-days-num /*p-value-integer*/
                                         ,output v-value-logical /*p-value-logical*/
                                         ) no-error .

     END.
     RUN local-initialize IN THIS-PROCEDURE.
  end.
  when "set" then do:
    IF v-profile-id = 51 THEN DO:
        ASSIGN
        FRAME {&FRAME-NAME}
        f-esys-id
        f-keep-days-num
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
        RUN rcps_set-value IN parent-handle (
                                         input "p-keep-days-num"
                                        ,INPUT 0
                                        ,input '' /*p-value-character*/
                                        ,input ?  /*p-value-date*/
                                        ,input 0.0 /*p-value-decimal*/
                                        ,input f-keep-days-num /*p-value-integer*/
                                        ,input no /*p-value-logical*/
                                        ) no-error .



    END.
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
message
"Данный отчет запускается только по расписанию!!!"
view-as alert-box error .
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
      when 51 then do:        assign
        frame {&frame-name}
        f-esys-id
        f-keep-days-num
        .
        ReportHeader = substitute("&1Маршрутизация во ВС: &2 &3&1Срок хранения отчетов: &4 (дни)"
                                  , {&new-line}
                                  , f-esys-id
                                  , f-esys-name
                                  , f-keep-days-num
                                  ).

      end.
    end case.
  end.
  otherwise do:
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