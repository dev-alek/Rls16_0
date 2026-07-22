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

Выгрузка для Nielsen (ЗАКЛАДКА №2)

Автор: Белоусов Илья Александрович
Дата создания: 03/25/09
Author: Ilia Belousov
Creation date: 03/25/09

*/

def var vss-revision    as character no-undo init "$Revision$":U .
def var vss-author      as character no-undo init "$Author$":U .
def var vss-date        as character no-undo init "$Date$":U .
def var vss-workfile    as character no-undo init "$Workfile$":U .
def var vss-archive     as character no-undo init "$Archive$":U .
def var vss-description as character no-undo init "Выгрузка для Nielsen".
{ cmp/vssrevis.i  }
{ cmp/str-glbl.i  }
{ cmp/r-page1.i   }
{ adm/auto-def.i NEW }
{ rep/rep-bt.i    }
{ rep/exp-sl.i    }
{ gbl/usr-flt.i   }
CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

define variable  State-source as  WIDGET-HANDLE.



define variable loc-ref-list as character no-undo .
define stream StreamLog.

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
&Scoped-Define ENABLED-OBJECTS RECT-7 RADIO-doc v-login v-password v-name
&Scoped-Define DISPLAYED-OBJECTS RADIO-doc v-ftp-address v-login v-ftp-path ~
v-ftp-target-dir v-password v-name EDITOR-log
&scoped-define LogLineSize 80
/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE VARIABLE EDITOR-log AS CHARACTER
     VIEW-AS EDITOR NO-WORD-WRAP SCROLLBAR-HORIZONTAL SCROLLBAR-VERTICAL
     SIZE 69.6 BY 5.24 NO-UNDO.

DEFINE VARIABLE v-ftp-address AS CHARACTER FORMAT "X(40)":U
     LABEL "ftp"
     VIEW-AS FILL-IN
     SIZE 28 BY 1 NO-UNDO.

DEFINE VARIABLE v-ftp-path AS CHARACTER FORMAT "X(256)":U
     LABEL "Путь"
     VIEW-AS FILL-IN
     SIZE 46 BY 1 NO-UNDO.

DEFINE VARIABLE v-ftp-target-dir AS CHARACTER FORMAT "X(256)":U
     LABEL "Папка"
     VIEW-AS FILL-IN
     SIZE 46 BY 1 NO-UNDO.

DEFINE VARIABLE v-login AS CHARACTER FORMAT "X(25)":U
     LABEL "Логин"
     VIEW-AS FILL-IN
     SIZE 28 BY 1 NO-UNDO.

DEFINE VARIABLE v-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Префикс"
     VIEW-AS FILL-IN
     SIZE 17.2 BY 1 TOOLTIP "Префикс имени выходного файла." NO-UNDO.

DEFINE VARIABLE v-password AS CHARACTER FORMAT "X(25)":U
     LABEL "Пароль"
     VIEW-AS FILL-IN
     SIZE 28 BY 1 NO-UNDO.

DEFINE VARIABLE RADIO-doc AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Локальную папку", 1,
"FTP адрес", 2
     SIZE 24.4 BY 2.81 NO-UNDO.

DEFINE RECTANGLE RECT-7
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 71.4 BY 16.24.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     RADIO-doc AT ROW 2.57 COL 4.6 NO-LABEL
     v-ftp-address AT ROW 5.86 COL 11 COLON-ALIGNED
     v-login AT ROW 7.33 COL 11 COLON-ALIGNED
     v-ftp-path AT ROW 8.86 COL 11 COLON-ALIGNED
     v-ftp-target-dir AT ROW 8.86 COL 11 COLON-ALIGNED
     v-password AT ROW 8.86 COL 11 COLON-ALIGNED PASSWORD-FIELD
     v-name AT ROW 10.43 COL 11 COLON-ALIGNED WIDGET-ID 2
     EDITOR-log AT ROW 12 COL 3 NO-LABEL WIDGET-ID 4
     "Выгружать в:" VIEW-AS TEXT
          SIZE 15 BY .67 AT ROW 1.86 COL 4.6
          FGCOLOR 4
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
         HEIGHT             = 16.76
         WIDTH              = 73.2.
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

/* SETTINGS FOR EDITOR EDITOR-log IN FRAME F-Main
   NO-ENABLE                                                            */
ASSIGN
       EDITOR-log:READ-ONLY IN FRAME F-Main        = TRUE.

/* SETTINGS FOR FILL-IN v-ftp-address IN FRAME F-Main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN v-ftp-path IN FRAME F-Main
   NO-ENABLE                                                            */
ASSIGN
       v-ftp-path:HIDDEN IN FRAME F-Main           = TRUE.

/* SETTINGS FOR FILL-IN v-ftp-target-dir IN FRAME F-Main
   NO-ENABLE                                                            */
ASSIGN
       v-ftp-target-dir:HIDDEN IN FRAME F-Main           = TRUE.

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

&Scoped-define SELF-NAME RADIO-doc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RADIO-doc s-object
ON VALUE-CHANGED OF RADIO-doc IN FRAME F-Main
DO:
  assign
   RADIO-doc
  .
  CASE RADIO-doc:
  WHEN 2  /*При выборе выгрузки на ftp*/
  then do:
    ENABLE
        v-ftp-address
        v-login
        v-password
        editor-log
    WITH FRAME F-Main.
    DISPLAY
        v-ftp-address
        v-login
        v-password
        editor-log
    WITH FRAME F-Main.
  end.
  OTHERWISE DO: /*Выгрузка в локальную папку*/
      HIDE
          v-ftp-address
          v-login
          v-password
      IN FRAME F-Main.
      ENABLE
      editor-log
      WITH FRAME F-Main.
      DISPLAY
      editor-log
      WITH FRAME F-Main.
  END.
  END CASE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK s-object


/* ***************************  Main Block  *************************** */

/* If testing in the UIB, initialize the SmartObject. */

&IF DEFINED(UIB_IS_RUNNING) <> 0 &THEN
  { gbl/getcntxt.i get }
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
define variable v-void-log    as logical   no-undo .
   define variable v-call-point    as character    no-undo.
   define variable v-naim    as character    no-undo.  /*Введенный раннее ftp-адрес*/
   define variable v-list    as character    no-undo.  /*Введенное раннее название фирмы (добавляется в начало названия файла)*/
   define variable v-found    as logical      no-undo.
   define variable v-doc    as logical      no-undo.  /*Раннее выбранный тип вывода*/
   ASSIGN
      v-call-point = {&uf-exp-sl-1}
   .
   /*Получение сохраненных раннее введенных данных*/
   run uf-get ( input v-call-point
                     , input v-cntxt-userid
                     , output v-list
                     , output v-naim
                     , output v-doc
                     , output v-void-log
                     , output v-void-log
                     , output v-void-log
                     ) .
      ASSIGN
         v-ftp-address    = v-naim
         v-name           = v-list
         radio-doc        = IF v-doc THEN 1 ELSE 2
         v-call-point = {&uf-exp-sl-2}
         .
   .
   run uf-get( input v-call-point
                     , input v-cntxt-userid
                     , output v-list
                     , output v-naim
                     , output v-void-log
                     , output v-void-log
                     , output v-void-log
                     , output v-void-log
                     ) .
      ASSIGN
         v-login     = v-naim
         v-password  = v-list
      .

   DISPLAY
      RADIO-DOC
      v-name
   WITH FRAME F-Main.

   CASE RADIO-doc:
     WHEN 2 /*При выборе выгрузки на ftp*/
     then do:
       ENABLE
         v-ftp-address
         v-login
         v-password
         editor-log
       WITH FRAME F-Main.
       DISPLAY
         v-ftp-address
         v-login
         v-password
         editor-log
       WITH FRAME F-Main.
     end.
     OTHERWISE DO: /*Выгрузка в локальную папку*/
       HIDE
          v-ftp-address
          v-login
          v-password
       IN FRAME F-Main.
       ENABLE
       editor-log
       WITH FRAME F-Main.
       DISPLAY
       editor-log
       WITH FRAME F-Main.
     END.
   END CASE.

   RUN dispatch IN THIS-PROCEDURE ( INPUT 'initialize':U ) .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-report s-object
PROCEDURE my-report :
/*------------------------------------------------------------------------------
  Purpose:     здесь происходит вызов  процедуры отчета с любыми параметрами
------------------------------------------------------------------------------*/
define variable v-call-point    as character    no-undo.
define variable v-naim    as character    no-undo.
define variable v-list    as character    no-undo.
   define variable v-doc    as logical      no-undo.

   define buffer buf_clients     for ub.clients .

   DO with FRAME F-Main
   :
      ASSIGN
         v-ftp-address
         RADIO-doc
         v-login
         v-password
         v-name
      .
   END.
   ASSIGN
      v-call-point = {&uf-exp-sl-1}
      v-naim       = v-ftp-address
      v-list       = v-name
      v-doc        = IF RADIO-doc = 1 THEN TRUE
                                      ELSE FALSE
   .
   run uf-set ( input v-call-point
                     , input v-cntxt-userid
                     , input v-list
                     , input v-naim
                     , input v-doc
                     , input ?
                     , input ?
                     , input ?
                     ) .
   ASSIGN
      v-call-point = {&uf-exp-sl-2}
      v-naim       = v-login
      v-list       = v-password
   .
   run uf-set ( input v-call-point
                     , input v-cntxt-userid
                     , input v-list
                     , input v-naim
                     , input ?
                     , input ?
                     , input ?
                     , input ?
                     ) .
   /* список объектов с(!!!) кодом фирмы */
   EMPTY TEMP-TABLE tt-obj.
   FOR EACH obj-list
   :
      FIND FIRST buf_clients NO-LOCK
        WHERE buf_clients.obj-type = obj-list.obj-type
          AND buf_clients.obj-code = obj-list.obj-code
        NO-ERROR.

      IF AVAILABLE buf_clients
      THEN DO:
         CREATE tt-obj.
         ASSIGN
            tt-obj.obj-code  = obj-list.obj-code
            tt-obj.obj-type  = obj-list.obj-type
            tt-obj.obj-name  = obj-list.obj-name
            tt-obj.host-code = buf_clients.host-code
         .
      END.
   END. /* EACH obj-list */
   run rep/r-exp-sl.p ( INPUT x-Date-Alone
                 , INPUT IF RADIO-doc = 1 THEN "":U ELSE v-ftp-address
                 , input v-ftp-path
                 , input v-ftp-target-dir
                 , INPUT v-login
                 , INPUT v-password
                 , INPUT v-name
                 , INPUT this-procedure:handle
/*               , INPUT yes*/
                 , input table tt-obj
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
assign frame {&frame-name}  RADIO-doc v-ftp-address v-login v-password .
/*if cb-type > 0 then  assign ReportHeader = {&new-line} + "Форма отчета : " + entry( cb-type , {&alcdcl-region-name} ) + {&new-line} .*/

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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE write-log-and-file s-object
PROCEDURE write-log-and-file :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-tab-position   as integer      no-undo.
DEF INPUT PARAMETER p-file-name AS CHAR     NO-UNDO.
DEF INPUT PARAMETER p-log-level AS INTEGER  NO-UNDO.
DEF INPUT PARAMETER p-log-string  AS CHAR     NO-UNDO.
define variable sToWrite as character no-undo.

sToWrite = p-log-string + {&new-line}.

define variable v-text    as character    no-undo.

 DO WITH frame {&frame-name}:
      ASSIGN
         v-text = editor-log + {&new-line} + p-log-string
        editor-log = v-text.
      DISPLAY editor-log.
   END.

OUTPUT STREAM StreamLog TO VALUE(p-file-name) APPEND.
    PUT STREAM StreamLog UNFORMATTED {&new-line}.
    PUT STREAM StreamLog UNFORMATTED (IF (p-log-level = 0 OR sToWrite = "&DLine"
                                      OR sToWrite = "&Line") THEN "" ELSE
                                      cur-time-string-sec() + " ").
    PUT STREAM StreamLog UNFORMATTED
            (IF sToWrite = "&Line" THEN FILL("-", {&LogLineSize})
             ELSE IF sToWrite = "&DLine" THEN FILL("=", {&LogLineSize})
             ELSE sToWrite).
OUTPUT STREAM StreamLog CLOSE.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME