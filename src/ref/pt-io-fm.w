&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER locked_point-io FOR ub.point-io.
DEFINE TEMP-TABLE tt-point-io NO-UNDO LIKE ub.point-io.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Создание и изменение пунктов отгрузки/доставки

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/29/09
Author: Bakhtadze Natalya
Creation date: 09/29/09

/* Кочетков Михаил Юрьевич*/

*/
/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-db-num      as integer   no-undo .
define input parameter p-cli-type like ub.clients.obj-type no-undo .
define input parameter p-cli-code like ub.clients.obj-code no-undo .
define input parameter p-mode        as character no-undo.
define input-output parameter p-rep-rec     as recid no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "создание и изменение пунктов отгрузки/доставки".
{ cmp/vssrevis.i }
{ cmp/showinf.i  }
{ cmp/str-glbl.i }
{ gbl/getcntxt.i def }

define buffer buf_clients for ub.clients.
define buffer buf_person for ub.person.
define buffer buf_firm for ub.firm.

define variable glog as logical no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-point-io

/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define FIELDS-IN-QUERY-Dialog-Frame tt-point-io.cli-code ~
tt-point-io.cli-type tt-point-io.point-type tt-point-io.point-code ~
tt-point-io.point-name tt-point-io.deliv-subj-code tt-point-io.address ~
tt-point-io.is-default tt-point-io.PS
&Scoped-define ENABLED-FIELDS-IN-QUERY-Dialog-Frame tt-point-io.cli-code ~
tt-point-io.cli-type tt-point-io.point-type tt-point-io.point-code ~
tt-point-io.point-name tt-point-io.deliv-subj-code tt-point-io.address ~
tt-point-io.is-default tt-point-io.PS
&Scoped-define ENABLED-TABLES-IN-QUERY-Dialog-Frame tt-point-io
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-Dialog-Frame tt-point-io
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH tt-point-io SHARE-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH tt-point-io SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame tt-point-io
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame tt-point-io


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS tt-point-io.cli-code tt-point-io.cli-type ~
tt-point-io.point-type tt-point-io.point-code tt-point-io.point-name ~
tt-point-io.deliv-subj-code tt-point-io.address tt-point-io.is-default ~
tt-point-io.PS
&Scoped-define ENABLED-TABLES tt-point-io
&Scoped-define FIRST-ENABLED-TABLE tt-point-io
&Scoped-Define ENABLED-OBJECTS b-exit RECT-2 b-quit B-hist b-help B-object ~
b-cli b-deliv-subj
&Scoped-Define DISPLAYED-FIELDS tt-point-io.cli-code tt-point-io.cli-type ~
tt-point-io.point-type tt-point-io.point-code tt-point-io.point-name ~
tt-point-io.deliv-subj-code tt-point-io.address tt-point-io.is-default ~
tt-point-io.PS
&Scoped-define DISPLAYED-TABLES tt-point-io
&Scoped-define FIRST-DISPLAYED-TABLE tt-point-io
&Scoped-Define DISPLAYED-OBJECTS cli-name deliv-subj-name

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-cli
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "2"
     SIZE 2.9 BY 1.

DEFINE BUTTON b-deliv-subj
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "2"
     SIZE 2.9 BY 1.

DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1.

DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 3 BY 1.

DEFINE BUTTON B-hist
     LABEL "Ис&тория"
     SIZE 3 BY 1.

DEFINE BUTTON B-object
     LABEL "О&бъект"
     SIZE 10 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1.

DEFINE VARIABLE cli-name AS CHARACTER FORMAT "X(40)"
      VIEW-AS TEXT
     SIZE 90.7 BY 1.

DEFINE VARIABLE deliv-subj-name AS CHARACTER FORMAT "X(40)"
      VIEW-AS TEXT
     SIZE 58.7 BY 1.

DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 98 BY 2.5.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY Dialog-Frame FOR
      tt-point-io SCROLLING.
&ANALYZE-RESUME

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-hist AT ROW 1 COL 92
     b-help AT ROW 1 COL 95
     B-object AT ROW 2.43 COL 31 WIDGET-ID 4
     tt-point-io.cli-code AT ROW 2.47 COL 13.3 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 6 BY 1
     tt-point-io.cli-type AT ROW 2.47 COL 19.6 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 4.4 BY 1
     b-cli AT ROW 2.47 COL 26.8
     tt-point-io.point-type AT ROW 5 COL 3 NO-LABEL
          VIEW-AS RADIO-SET HORIZONTAL
          RADIO-BUTTONS
                    "доставки", "1":U,
"отгрузки", "2":U
          SIZE 26.5 BY 1
     tt-point-io.point-code AT ROW 5 COL 42.5 COLON-ALIGNED
          LABEL "Номер"
          VIEW-AS FILL-IN
          SIZE 19.5 BY 1
     tt-point-io.point-name AT ROW 6.33 COL 10 COLON-ALIGNED
          LABEL "Название"
          VIEW-AS FILL-IN
          SIZE 52 BY 1
     tt-point-io.deliv-subj-code AT ROW 7.4 COL 4.5 WIDGET-ID 8
          LABEL "Код субъекта доставки" FORMAT "->,>>>,>>9"
          VIEW-AS FILL-IN
          SIZE 9 BY 1
     b-deliv-subj AT ROW 7.4 COL 37 WIDGET-ID 6
     tt-point-io.address AT ROW 9 COL 3 COLON-ALIGNED NO-LABEL WIDGET-ID 12
          VIEW-AS FILL-IN
          SIZE 87 BY 1
     tt-point-io.is-default AT ROW 11 COL 31.5
          LABEL "По умолчанию"
          VIEW-AS TOGGLE-BOX
          SIZE 32.5 BY .83
     tt-point-io.PS AT ROW 13 COL 1 NO-LABEL
          VIEW-AS FILL-IN
          SIZE 98 BY 3.67
     cli-name AT ROW 3.47 COL 2.8 NO-LABEL
     deliv-subj-name AT ROW 7.4 COL 41 NO-LABEL WIDGET-ID 10
     "Примечание:" VIEW-AS TEXT
          SIZE 15 BY .67 AT ROW 12.3 COL 3
     "Контрагент:" VIEW-AS TEXT
          SIZE 12.1 BY 1 AT ROW 2.47 COL 2.9
          FGCOLOR 4
     RECT-2 AT ROW 2.27 COL 1.5
     SPACE(0.39) SKIP(13.29)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Пункт отгрузки/доставки".


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: locked_point-io B "?" ? ub point-io
      TABLE: tt-point-io T "?" NO-UNDO ub point-io
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN tt-point-io.address IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-point-io.cli-code IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN cli-name IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN tt-point-io.cli-type IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-point-io.deliv-subj-code IN FRAME Dialog-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT                                         */
/* SETTINGS FOR FILL-IN deliv-subj-name IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR TOGGLE-BOX tt-point-io.is-default IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-point-io.point-code IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
ASSIGN
       tt-point-io.point-code:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN tt-point-io.point-name IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-point-io.PS IN FRAME Dialog-Frame
   ALIGN-L EXP-LABEL                                                    */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "Temp-Tables.tt-point-io"
     _Options          = "SHARE-LOCK"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Пункт отгрузки/доставки */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-cli
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-cli Dialog-Frame
ON CHOOSE OF b-cli IN FRAME Dialog-Frame /* 2 */
DO:
  define variable  v-rid-list as character no-undo .
  run ref/cli-all.w ( input parParentProc
                    ,input "b-sel"
                    ,input {&all}
                    ,input {&all}
                    ,input  {&current}
                    ,input ?
                    ,input "
                    ,,,,,,NO,,":u
                    , "without-obj":U
                    ,output v-rid-list ) .
  if v-rid-list <> "" then do:
    find first buf_clients no-lock where RECID(buf_clients) = int (v-rid-list) no-error.
    assign
    tt-point-io.cli-type = buf_clients.obj-type
    tt-point-io.cli-code = buf_clients.obj-code
    .
    assign
    tt-point-io.point-type .
    run find-cli in this-procedure ( input tt-point-io.cli-type
                                    , input tt-point-io.cli-code)  .
  end.
  else do:
    assign
    cli-name = ""
    tt-point-io.cli-code = ?
    tt-point-io.cli-type  = ? .
    display
    cli-name
    tt-point-io.cli-type
    tt-point-io.cli-code
    with frame {&frame-name}.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-deliv-subj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-deliv-subj Dialog-Frame
ON CHOOSE OF b-deliv-subj IN FRAME Dialog-Frame /* 2 */
DO:
  define buffer buf_delivery-subject for ub.delivery-subject.

  define variable v-rid-list as character no-undo.
  define variable v-stts as integer no-undo .
  v-stts = integer({&current-status-int}).
  run ref/dlvsubjs.w (input parParentProc
                , v-cntxt-obj-type
                , v-cntxt-obj-code
                , "b-sel":U
                , {&all}
                , input-output v-stts
                , input-output v-rid-list ) no-error .
  /*apply "ENTRY" to b-exit.  АНАЛОГИЧНО*/
  if v-rid-list <> ? then do :
    find first buf_delivery-subject no-lock
      where recid(buf_delivery-subject) = integer(v-rid-list)
    no-error .
    if not available buf_delivery-subject then do:
      message
      "Неверный код субъекта доставки " v-rid-list
      view-as alert-box error.
      return no-apply.
    end.
    else do:
      assign
      tt-point-io.deliv-subj-code = buf_delivery-subject.deliv-subj-code
      .
      display
      tt-point-io.deliv-subj-code
      buf_delivery-subject.deliv-subj-name @ deliv-subj-name
      with frame {&frame-name}.
    end.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit Dialog-Frame
ON CHOOSE OF b-exit IN FRAME Dialog-Frame /* Ввод */
DO:
  run proc-save in this-procedure no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-hist Dialog-Frame
ON CHOOSE OF B-hist IN FRAME Dialog-Frame /* История */
DO:
  DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
  if not available locked_point-io then return .
  run ref/ptiohist.w ( INPUT parParentProc
                     , input locked_point-io.db-num
                     , input locked_point-io.point-code
                     , input "":U /*bttns  */
                     , input-output v-rid-list
                     ) no-error .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-object
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-object Dialog-Frame
ON CHOOSE OF B-object IN FRAME Dialog-Frame /* Объект */
DO:
  define buffer b#clients for ub.clients.
  define variable v-type as char no-undo.
  define variable v-code as int no-undo.
  define buffer buf_person for ub.person.
  define buffer buf_firm for ub.firm.
  define buffer buf_shop for ub.shop.
  define buffer buf_store for ub.store.

  run str/chshobj.w ( tt-point-io.cli-code
                      , input ""
                      , input 0
                      , output v-type
                      , OUTPUT v-code).

  find first b#clients WHERE
         v-code = b#clients.obj-code
     AND v-type = b#clients.obj-type No-LOCK No-ERROR.
  if available b#clients then do:
    assign tt-point-io.point-name = b#clients.obj-name .
    Case b#clients.obj-type :
      when  {&cmp} then do :
        FIND buf_firm  WHERE
              buf_firm.firm-code = b#clients.obj-code NO-LOCK.
        Assign tt-point-io.address = buf_firm.addres1 .
      end.
      when  {&prs} then do :
        FIND buf_person  WHERE
           buf_person.psn-code = b#clients.obj-code NO-LOCK.
        Assign tt-point-io.address = buf_person.address .
      end.
      when  {&shop} then do :
        FIND buf_shop  WHERE buf_shop.obj-code = b#clients.obj-code NO-LOCK.
        Assign tt-point-io.address = buf_shop.addres1 .
      end.
      when  {&stock} then do :
        FIND buf_store  WHERE buf_store.obj-code = b#clients.obj-code NO-LOCK.
        Assign tt-point-io.address = buf_store.addres1 .
      end.
    End case.
    display
    tt-point-io.point-name
    tt-point-io.address with frame {&frame-name}.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-quit Dialog-Frame
ON CHOOSE OF b-quit IN FRAME Dialog-Frame /* Отмена */
DO:
p-rep-rec = ?.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-point-io.cli-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-point-io.cli-code Dialog-Frame
ON LEAVE OF tt-point-io.cli-code IN FRAME Dialog-Frame /* cli-code */
DO:
  if tt-point-io.cli-code = int ( tt-point-io.cli-code:screen-value ) then return.
  assign
  tt-point-io.cli-code
  tt-point-io.point-type .

  run find-cli in this-procedure ( input tt-point-io.cli-type
                                 , input tt-point-io.cli-code)  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-point-io.cli-code Dialog-Frame
ON RETURN OF tt-point-io.cli-code IN FRAME Dialog-Frame /* cli-code */
DO:
  if tt-point-io.cli-code = int ( tt-point-io.cli-code:screen-value ) then return.
  assign
  tt-point-io.cli-code
  tt-point-io.point-type .
  run find-cli in this-procedure ( input tt-point-io.cli-type
                                 , input tt-point-io.cli-code)  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-point-io.cli-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-point-io.cli-type Dialog-Frame
ON LEAVE OF tt-point-io.cli-type IN FRAME Dialog-Frame /* cli-type */
DO:
  assign
  tt-point-io.cli-type
  tt-point-io.point-type .
  run find-cli in this-procedure ( input tt-point-io.cli-type
                                  , input tt-point-io.cli-code)  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/app_help.i }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON stop UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
{ gbl/getcntxt.i get }
 if p-mode  <> {&add-def}
 and p-mode <> {&update}
 and p-mode <> {&lookup}
 then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметров вызова p-mode"  p-mode
    view-as alert-box ERROR.
    undo, return error.
 end.
 if p-cli-code > 0
 and p-mode = {&add-def}
 then do:
   find first buf_clients no-lock where
            buf_clients.obj-type = p-cli-type
       AND buf_clients.obj-code = p-cli-code no-error.
  if not available buf_clients then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметра вызова p-cli-type/p-cli-code"
    p-cli-type p-cli-code
    view-as alert-box ERROR.
    return error .
  end.
 end.
 for each tt-point-io:
    delete tt-point-io.
  end.
  if p-mode = {&update}
  or p-mode = {&lookup} then do:
    if p-mode = {&update} then do:
      find first locked_point-io EXclusive-lock where
                   recid(locked_point-io) = p-rep-rec no-error.
    end.
    else do:
      find first locked_point-io no-lock where
                       recid(locked_point-io) = p-rep-rec no-error .
    end.
    if not available locked_point-io then do:
      message
      vss-workfile vss-revision vss-description skip
      "Не найдена запись ПУНКТ ДОСТАВКИ/ОТГРУЗКИ"
      view-as alert-box error .
      undo, return error.
    end.
    find first buf_clients no-lock where
            buf_clients.obj-type = locked_point-io.cli-type
       AND buf_clients.obj-code = locked_point-io.cli-code no-error.
    create tt-point-io.
    buffer-copy locked_point-io to tt-point-io.
    if available buf_clients then do:
      cli-name = buf_clients.obj-name.
    end.
  end.
  else do:
    create tt-point-io.
    assign
    tt-point-io.db-num = v-cntxt-db-num.
    tt-point-io.point-type = {&point-in}.
    if available buf_clients then do:
      assign
      cli-name = buf_clients.obj-name
      tt-point-io.cli-type = p-cli-type
      tt-point-io.cli-code = p-cli-code
      .
    end.
  end.
  RUN Myenable in this-procedure .
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI Dialog-Frame  _DEFAULT-DISABLE
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
  HIDE FRAME Dialog-Frame.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI Dialog-Frame  _DEFAULT-ENABLE
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
  DISPLAY cli-name deliv-subj-name
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-point-io THEN
    DISPLAY tt-point-io.cli-code tt-point-io.cli-type tt-point-io.point-type
          tt-point-io.point-code tt-point-io.point-name
          tt-point-io.deliv-subj-code tt-point-io.address tt-point-io.is-default
          tt-point-io.PS
      WITH FRAME Dialog-Frame.
  ENABLE b-exit RECT-2 b-quit B-hist b-help B-object tt-point-io.cli-code
         tt-point-io.cli-type b-cli tt-point-io.point-type
         tt-point-io.point-code tt-point-io.point-name
         tt-point-io.deliv-subj-code b-deliv-subj tt-point-io.address
         tt-point-io.is-default tt-point-io.PS
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE find-cli Dialog-Frame
PROCEDURE find-cli :
define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code as integer   no-undo .
define buffer buf_sysconf for ub.sysconf.
define buffer buf_point-io for ub.point-io.
if p-obj-type <> {&cmp} and p-obj-type <> {&prs} then do:
  find first buf_clients no-lock where
           buf_clients.obj-type = {&cmp}
       and buf_clients.obj-code = p-obj-code no-error.
  if not available buf_clients then do:
    find first buf_clients no-lock where
           buf_clients.obj-type = {&prs}
       and buf_clients.obj-code = p-obj-code no-error.
  end.
end.
else do:
  find first buf_clients no-lock where
           buf_clients.obj-type = p-obj-type
       and buf_clients.obj-code = p-obj-code no-error.
end.
if not available buf_clients then do:
  if p-obj-code = 0 then assign p-obj-code = ? .
  if p-obj-code = ? then do:
    assign
    cli-name = ""
    tt-point-io.cli-code = ?
    tt-point-io.cli-type  = ? .
    display
    cli-name
    tt-point-io.cli-code
    tt-point-io.cli-type
    with frame {&frame-name}.
  end.
  else do:
    apply "CHOOSE" to b-cli IN FRAME {&frame-name}  .
  end.
  return.
end.


if buf_clients.obj-type = {&cmp} then do:
  find first buf_firm no-lock where
            buf_firm.firm-code = buf_clients.obj-code no-error.
  if available buf_firm then
  assign tt-point-io.address = buf_firm.addres1 .
  find first buf_sysconf no-lock where
           buf_sysconf.host-code = buf_clients.obj-code no-error .
  if available buf_sysconf then do:
     assign
     B-object:visible = yes .
  end.
  else do:
    assign
    B-object:visible = no .
  end.
end.
else do:
  find first buf_person no-lock where
           buf_person.psn-code = buf_clients.obj-code no-error.
  if available buf_person then
  assign  tt-point-io.address = buf_person.address .
end.

find first buf_point-io no-lock
  where buf_point-io.cli-code   = buf_clients.obj-code
    and buf_point-io.cli-type   = buf_clients.obj-type
    and buf_point-io.point-type = tt-point-io.point-type
    and buf_point-io.is-default = yes
no-error .
if available buf_point-io then do:
  assign
  tt-point-io.is-default = no .
end.
else do:
  assign
  tt-point-io.is-default = yes .
end.

assign
cli-name  = buf_clients.obj-name
tt-point-io.cli-code  = p-obj-code
tt-point-io.cli-type  = buf_clients.obj-type.
display
cli-name
tt-point-io.cli-code
tt-point-io.cli-type
tt-point-io.address
tt-point-io.is-default
with frame {&frame-name}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Myenable Dialog-Frame
PROCEDURE Myenable :
define buffer buf_sysconf for ub.sysconf.
define buffer buf_delivery-subject for ub.delivery-subject.
IF tt-point-io.deliv-subj-code > 0  THEN DO:
  find first buf_delivery-subject no-lock
      where buf_delivery-subject.deliv-subj-code = tt-point-io.deliv-subj-code
    no-error .
  if not available buf_delivery-subject then do:
    message
    SUBSTITUTE("Неверный код субъекта доставки &1", tt-point-io.deliv-subj-code)
    view-as alert-box error.
   end.
   deliv-subj-name = buf_delivery-subject.deliv-subj-name.
END.

assign
frame {&frame-name}:title = substitute("Пункт отгрузки/доставки         &1", p-mode).
assign
tt-point-io.point-type:radio-buttons  in frame {&frame-name}
 =  {&point-in} + {&comma-char} + {&point-in} + {&comma-char} +
                          {&point-out} + {&comma-char} + {&point-out} .


DISPLAY
cli-name
deliv-subj-name
WITH FRAME {&frame-name} .
IF AVAILABLE tt-point-io THEN do:
  DISPLAY
  tt-point-io.cli-code
  tt-point-io.cli-type
  tt-point-io.point-code
  tt-point-io.point-name
  tt-point-io.deliv-subj-code
  tt-point-io.address
  tt-point-io.is-default
  tt-point-io.PS
  tt-point-io.point-type
  WITH FRAME {&frame-name} .
end.
if p-mode <> {&lookup} then do:
  if tt-point-io.cli-type = {&cmp} then do:
    find first buf_sysconf no-lock where
            buf_sysconf.host-code = cli-code no-error .
    if available buf_sysconf then do:
      assign B-object:visible = yes .
    end.
    else do:
      assign B-object:visible = no .
    end.
  end.
  else do:
    assign B-object:visible = no .
  end.
end.
else
assign
B-object:visible = no .
ENABLE
b-exit when p-mode <> {&lookup}
b-quit
B-hist  when p-mode <> {&add-def}
b-help
B-object  when b-object:visible in frame {&frame-name}
tt-point-io.cli-code when p-mode = {&add-def}
tt-point-io.cli-type when p-mode = {&add-def}
b-cli when p-mode = {&add-def}
tt-point-io.point-type  when p-mode <> {&lookup}
tt-point-io.point-code
tt-point-io.point-name  when p-mode <> {&lookup}
b-deliv-subj when p-mode <> {&lookup}
tt-point-io.address  when p-mode <> {&lookup}
tt-point-io.is-default  when p-mode <> {&lookup}
tt-point-io.ps
RECT-2
WITH FRAME {&frame-name} .
if p-mode = {&lookup} then do:
  tt-point-io.PS:read-only = yes.
  b-quit:column = 1.
  b-exit:visible = no.
  b-quit:label = "&Выход".
end.
VIEW FRAME {&frame-name} .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save Dialog-Frame
PROCEDURE proc-save :
define variable v-rep-rec as recid no-undo .
assign
frame {&frame-name}
tt-point-io.ps
tt-point-io.point-name
tt-point-io.point-type
tt-point-io.address
tt-point-io.is-default
tt-point-io.deliv-subj-code
v-rep-rec = recid(locked_point-io)
.
run ref/pt-io-f1.p ( input-output v-rep-rec
                    ,input p-mode
                    ,input no /*p-silent*/
                    ,input tt-point-io.point-code
                    ,input tt-point-io.db-num
                    ,input tt-point-io.cli-type
                    ,input tt-point-io.cli-code
                    ,input tt-point-io.point-name
                    ,input tt-point-io.point-type
                    ,input tt-point-io.deliv-subj-code
                    ,input tt-point-io.is-default
                    ,input tt-point-io.address
                    ,input tt-point-io.ps ) no-error.

if error-status:error then do:
 { gbl/reterhnd.i error }
  undo, return error.
end.
if return-value = "quit" then undo, return error .
p-rep-rec = v-rep-rec.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME