&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame

/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER buf_clients FOR ub.clients.
DEFINE BUFFER buf_fbr-prn FOR ub.fbr-prn.
DEFINE BUFFER buf_goods FOR ub.goods.
DEFINE BUFFER fbr_clients FOR ub.clients.
DEFINE BUFFER loc_fbr-prn-gds FOR ub.fbr-prn-gds.
DEFINE TEMP-TABLE tt-fbr-prn-gds NO-UNDO LIKE ub.fbr-prn-gds.


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Товар на  принтере кухни-создание, редактирование

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/25/03
Author: Bakhtadze Natalya
Creation date: 08/25/03

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
define input parameter par-mode as character no-undo.
/*может быть {&add-def} или {&update}*/
define input parameter par-call-mode as character no-undo.
/*может быть "goods" или "printer"*/
define input parameter p-db-num like ub.fbr-prn-gds.db-num no-undo.
define input parameter p-prn-num like ub.fbr-prn-gds.prn-num no-undo.
define input parameter p-obj-type like ub.fbr-prn-gds.obj-type no-undo.
define input parameter p-obj-code like ub.fbr-prn-gds.obj-code no-undo.
define input parameter p-gds-code like ub.fbr-prn-gds.gds-code no-undo.
define input-output parameter p-rec as recid no-undo.


/* Local Variable Definitions ---                                       */
def var vss-revision    as character no-undo init "$Revision$":U .
def var vss-author      as character no-undo init "$Author$":U .
def var vss-date        as character no-undo init "$Date$":U .
def var vss-workfile    as character no-undo init "$Workfile$":U .
def var vss-archive     as character no-undo init "$Archive$":U .
def var vss-description as character no-undo init "Группа товаров на  принтере кухни-создание, редактирование".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ ref/grplibfn.i }
{ gbl/getcntxt.i def }
{ gbl/userobjs.i }

define variable v-db-num like ub.db.db-num no-undo.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-fbr-prn-gds

/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define FIELDS-IN-QUERY-Dialog-Frame tt-fbr-prn-gds.obj-type ~
tt-fbr-prn-gds.obj-code tt-fbr-prn-gds.prn-num
&Scoped-define ENABLED-FIELDS-IN-QUERY-Dialog-Frame tt-fbr-prn-gds.obj-type ~
tt-fbr-prn-gds.obj-code tt-fbr-prn-gds.prn-num
&Scoped-define ENABLED-TABLES-IN-QUERY-Dialog-Frame tt-fbr-prn-gds
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-Dialog-Frame tt-fbr-prn-gds

&Scoped-define FIELD-PAIRS-IN-QUERY-Dialog-Frame~
 ~{&FP1}obj-type ~{&FP2}obj-type ~{&FP3}~
 ~{&FP1}obj-code ~{&FP2}obj-code ~{&FP3}~
 ~{&FP1}prn-num ~{&FP2}prn-num ~{&FP3}
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH tt-fbr-prn-gds SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame tt-fbr-prn-gds
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame tt-fbr-prn-gds


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS tt-fbr-prn-gds.obj-type ~
tt-fbr-prn-gds.obj-code tt-fbr-prn-gds.prn-num
&Scoped-define FIELD-PAIRS~
 ~{&FP1}obj-type ~{&FP2}obj-type ~{&FP3}~
 ~{&FP1}obj-code ~{&FP2}obj-code ~{&FP3}~
 ~{&FP1}prn-num ~{&FP2}prn-num ~{&FP3}
&Scoped-define ENABLED-TABLES tt-fbr-prn-gds
&Scoped-define FIRST-ENABLED-TABLE tt-fbr-prn-gds
&Scoped-Define ENABLED-OBJECTS b-quit B-exit B-Help b-gds B-shop B-printer ~
gds-name f-obj-name f-prn-name fbr-obj-name
&Scoped-Define DISPLAYED-FIELDS tt-fbr-prn-gds.obj-type ~
tt-fbr-prn-gds.obj-code tt-fbr-prn-gds.prn-num
&Scoped-Define DISPLAYED-OBJECTS gds-name f-obj-name f-prn-name ~
fbr-obj-name

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-gds
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 2"
     SIZE 3 BY 1.

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-printer
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 2"
     SIZE 3 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-shop
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 2"
     SIZE 3 BY 1.

DEFINE VARIABLE f-obj-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 45.75 BY .67 NO-UNDO.

DEFINE VARIABLE f-prn-name AS CHARACTER FORMAT "X(40)":U
      VIEW-AS TEXT
     SIZE 35.88 BY .67 NO-UNDO.

DEFINE VARIABLE fbr-obj-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 42.38 BY .67 NO-UNDO.

DEFINE VARIABLE gds-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 59.5 BY .67 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY Dialog-Frame FOR
      tt-fbr-prn-gds SCROLLING.
&ANALYZE-RESUME

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-exit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 54.88
     b-gds AT ROW 4.17 COL 62.38
     B-shop AT ROW 6.67 COL 19.25
     B-printer AT ROW 10.08 COL 47.13
     gds-name AT ROW 4.25 COL 1.88 NO-LABEL
     tt-fbr-prn-gds.obj-type AT ROW 6.71 COL 2 NO-LABEL
           VIEW-AS TEXT
          SIZE 7 BY .67
     tt-fbr-prn-gds.obj-code AT ROW 6.75 COL 8.5 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 7.13 BY .67
     f-obj-name AT ROW 7.83 COL 2.25 NO-LABEL
     tt-fbr-prn-gds.prn-num AT ROW 10.25 COL 2.25 NO-LABEL
           VIEW-AS TEXT
          SIZE 5.5 BY .67
     f-prn-name AT ROW 10.29 COL 7.88 COLON-ALIGNED NO-LABEL
     fbr-obj-name AT ROW 11.67 COL 22.75 NO-LABEL
     "Установлен:" VIEW-AS TEXT
          SIZE 18.63 BY .67 AT ROW 11.58 COL 2.25
          FGCOLOR 4
     "Принтер" VIEW-AS TEXT
          SIZE 18.63 BY .67 AT ROW 9.17 COL 2.25
          FGCOLOR 4
     "Объект" VIEW-AS TEXT
          SIZE 17.88 BY .67 AT ROW 5.42 COL 2.13
          FGCOLOR 4
     "Товар" VIEW-AS TEXT
          SIZE 17.88 BY .67 AT ROW 2.83 COL 2.38
          FGCOLOR 4
     SPACE(45.61) SKIP(9.28)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Принтер для товара"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: buf_clients B "?" ? ub clients
      TABLE: buf_fbr-prn B "?" ? ub fbr-prn
      TABLE: buf_goods B "?" ? ub goods
      TABLE: fbr_clients B "?" ? ub clients
      TABLE: loc_fbr-prn-gds B "?" ? ub fbr-prn-gds
      TABLE: tt-fbr-prn-gds T "?" NO-UNDO ub fbr-prn-gds
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS


/* ***************  Runtime Attributes and UIB Settings  ************** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
                                                                        */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN f-obj-name IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN fbr-obj-name IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN gds-name IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN tt-fbr-prn-gds.obj-type IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN tt-fbr-prn-gds.prn-num IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "Temp-Tables.tt-fbr-prn-gds"
     _Options          = "SHARE-LOCK"
     _Query            is OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME






/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Принтер для товара товаров */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Ввод */
DO:
  run proc-save in this-procedure no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-gds
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-gds Dialog-Frame
ON CHOOSE OF b-gds IN FRAME Dialog-Frame /* Btn 2 */
DO:
define variable rec-list as character no-undo.
  run ref/gds-ref.p (parparentproc
                 ,"b-sel":U
                 ,?               /*p-stat */
                 ,?               /*p-list  */
                 ,?               /*p-cond  */
                 ,?               /*p-rec   */
                 ,?               /*p-grp   */
                 ,?               /*p-cli-type */
                 ,?               /*p-cli-code  */
                 ,p-obj-type      /*p-obj-type  */
                 ,p-obj-code       /*p-obj-code  */
                 ,?               /*p-other     */
                 , output rec-list).
 if rec-list = "" then do:
     return no-apply.
  end.
  /* выбран товар */
   find buf_goods where recid (buf_goods) = integer (rec-list) no-lock no-error.
  if not avail buf_goods then do:
    return no-apply.
  end.
  assign
  tt-fbr-prn-gds.gds-code = buf_goods.gds-code
  .
display buf_goods.gds-name @ gds-name
with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-printer
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-printer Dialog-Frame
ON CHOOSE OF B-printer IN FRAME Dialog-Frame /* Btn 2 */
DO:
define variable v-recid as recid no-undo.
run ref/fbr-prns.w (
                        input parparentproc
                       ,input "db":U
                       ,input v-db-num
                       ,input "b-sel":U
                       ,input-output v-recid
) no-error.
if error-status:error then return no-apply.
find first buf_fbr-prn where
            recid(buf_fbr-prn) = v-recid no-error.
if error-status:error or buf_fbr-prn.db-num <> v-db-num then return no-apply.
find first fbr_clients no-lock where
            fbr_clients.obj-type = buf_fbr-prn.fbr-obj-type
       AND fbr_clients.obj-code = buf_fbr-prn.fbr-obj-code no-error.

assign
tt-fbr-prn-gds.prn-num = buf_fbr-prn.prn-num
f-prn-name = buf_fbr-prn.prn-name
fbr-obj-name = (if available fbr_clients
                         then fbr_clients.obj-name
                         else (buf_fbr-prn.fbr-obj-type + string(buf_fbr-prn.fbr-obj-code)))
.
display
f-obj-name
f-prn-name
tt-fbr-prn-gds.prn-num
with frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-shop
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-shop Dialog-Frame
ON CHOOSE OF B-shop IN FRAME Dialog-Frame /* Btn 2 */
DO:
  define variable v-host-code   as integer   no-undo .
  define variable v-user-select as logical   no-undo .
  define variable v-obj-type    as character no-undo .
  define variable v-obj-code    as integer   no-undo .

  { gbl/hostcode.i
    p-obj-type
    p-obj-code
    v-host-code
  }

  { gbl/uobjsone.i
    parparentproc
    v-cntxt-db-num
    v-cntxt-userid
    v-host-code
    p-obj-type
    p-obj-code
    v-user-select
    v-obj-type
    v-obj-code
  }
  if v-user-select = true
  then do:
    find first buf_clients no-lock
      where buf_clients.obj-type = v-obj-type
        and buf_clients.obj-code = v-obj-code
      no-error .
    if not available buf_clients then return no-apply.
    if buf_clients.db-num <> v-db-num
    then do:
      message
        "Можно выбать только объект текущей БД" skip
        view-as alert-box error.
      return no-apply.
    end.
    assign
    f-obj-name:screen-value = buf_clients.obj-name
    tt-fbr-prn-gds.obj-code = buf_clients.obj-code
    tt-fbr-prn-gds.obj-type = buf_clients.obj-type
    .
    display
    tt-fbr-prn-gds.obj-code
    tt-fbr-prn-gds.obj-type
    f-obj-name
    with frame {&frame-name}.
  end.
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
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
 { gbl/getcntxt.i get }
   if par-mode <> {&update} and par-mode <> {&add-def} then do:
    message
    vss-workfile vss-revision vss-description skip
     "Неверный параметр вызова par-mode" par-mode
    view-as alert-box ERROR.
    return error.
  end.
  if par-mode = {&add-def}
  AND  (par-call-mode <> "goods":U
        and par-call-mode <> "printer":U )
  then do:
      message
        vss-workfile vss-revision vss-description skip
         "Неверный параметр вызова par-call-mode" par-call-mode
        view-as alert-box ERROR.
        return error.
  end.
  { gbl/curdbnum.i v-db-num }

  run fill-tables in this-procedure.
  RUN Myenable in this-procedure.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI Dialog-Frame _DEFAULT-DISABLE
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


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI Dialog-Frame _DEFAULT-ENABLE
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

  {&OPEN-QUERY-Dialog-Frame}
  GET FIRST Dialog-Frame.
  DISPLAY gds-name f-obj-name f-prn-name fbr-obj-name
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-fbr-prn-gds THEN
    DISPLAY tt-fbr-prn-gds.obj-type tt-fbr-prn-gds.obj-code tt-fbr-prn-gds.prn-num
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-exit B-Help b-gds B-shop B-printer gds-name
         tt-fbr-prn-gds.obj-type tt-fbr-prn-gds.obj-code f-obj-name
         tt-fbr-prn-gds.prn-num f-prn-name fbr-obj-name
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Fill-tables Dialog-Frame
PROCEDURE Fill-tables :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
CASE par-mode:
  when {&add-def} then do:
    CASE par-call-mode:
      when "goods":U then do:
        create tt-fbr-prn-gds .
        assign
        tt-fbr-prn-gds.gds-code = p-gds-code
        .
      end.
      when "printer":U then do:
        create tt-fbr-prn-gds.
        assign
        tt-fbr-prn-gds.prn-num = p-prn-num.
      end.
    END CASE.
  end.
  when {&update} then do:
    find first loc_fbr-prn-gds exclusive-lock where
                recid(loc_fbr-prn-gds ) = p-rec no-error.
    if not available loc_fbr-prn-gds then do:
      message
      vss-workfile vss-revision vss-description skip
      "Неверное значение параметра p-rec" p-rec
      view-as alert-box error.
      return error.
    end.
    find first buf_goods no-lock where
               buf_goods.gds-code = p-gds-code no-error .
    if not available buf_goods then do:
      message
      vss-workfile vss-revision vss-description skip
      "Неверное значение параметра p-gds-code" p-rec
      view-as alert-box error.
      return error.
    end.
    find first buf_clients no-lock where
              buf_clients.obj-type = loc_fbr-prn-gds.obj-type
          AND buf_clients.obj-code = loc_fbr-prn-gds.obj-code no-error.
    if buf_clients.db-num <> v-db-num then do:
      message
      vss-workfile vss-revision vss-description skip
      "Нельзя редактировать запись, принадлежащую другой БД"
      "номер узла групп товаров" loc_fbr-prn-gds.gds-code skip
      "объект" loc_fbr-prn-gds.obj-type loc_fbr-prn-gds.obj-code skip
      "принтер" loc_fbr-prn-gds.prn-num
      view-as alert-box error.
      return error.
    end.
    create tt-fbr-prn-gds.
    buffer-copy loc_fbr-prn-gds to tt-fbr-prn-gds.
  end.
END CASE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
assign
frame {&frame-name}:title = frame {&frame-name}:title + {&space-char} + par-mode
.

CASE par-mode:
  when {&add-def} then do:
    CASE par-call-mode:
      when "goods":U then do:
      end.
      when "printer":U then do:
        find first buf_fbr-prn where
                    buf_fbr-prn.prn-num = tt-fbr-prn-gds.prn-num
                AND buf_fbr-prn.db-num = v-db-num .
        assign
        f-prn-name = buf_fbr-prn.prn-name
        .
        find first fbr_clients no-lock where
                  fbr_clients.obj-type = buf_fbr-prn.fbr-obj-type
              AND fbr_clients.obj-code = buf_fbr-prn.fbr-obj-code.
        assign
        fbr-obj-name = fbr_clients.obj-name
        .
      end.
    END CASE.
  end.
  when {&update} then do:
    find first buf_fbr-prn where
              buf_fbr-prn.prn-num = tt-fbr-prn-gds.prn-num
          AND buf_fbr-prn.db-num = v-db-num.
    assign
    f-prn-name = buf_fbr-prn.prn-name
    .
    find first fbr_clients no-lock where
              fbr_clients.obj-type = buf_fbr-prn.fbr-obj-type
          AND fbr_clients.obj-code = buf_fbr-prn.fbr-obj-code.
    assign
    fbr-obj-name = fbr_clients.obj-name
    .
    assign
    frame {&frame-name}:title = frame {&frame-name}:title + {&space-char} + buf_goods.gds-name
    .

  end.
END CASE.
  DISPLAY
  buf_goods.gds-name @ gds-name
  f-obj-name
  f-prn-name
  fbr-obj-name
  WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-fbr-prn-gds THEN
  DISPLAY
  tt-fbr-prn-gds.obj-type
  tt-fbr-prn-gds.obj-code
  tt-fbr-prn-gds.prn-num
  WITH FRAME Dialog-Frame.
  ENABLE
  b-quit
  B-exit
  B-Help
  b-gds when par-mode = {&add-def} and par-call-mode = "printer":U
  B-shop when par-mode = {&add-def}
  B-printer when par-call-mode = "goods"
  WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save Dialog-Frame
PROCEDURE proc-save :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
run ref/fprngrp1.p (
                    input-output p-rec
                    ,input par-mode
                    ,input tt-fbr-prn-gds.db-num
                    ,input tt-fbr-prn-gds.prn-num
                    ,input tt-fbr-prn-gds.obj-type
                    ,input tt-fbr-prn-gds.obj-code
                    ,input tt-fbr-prn-gds.gds-code

                    ) no-error.
if error-status:error then do:
    CASE return-value:
        when "gds-code":U then do:
            APPLY "ENTRY" to b-gds in frame {&frame-name}.
        end.
        when "obj-type":U or when "obj-code":U then do:
           APPLY "ENTRY" to b-shop.
        end.
        when "prn-num" then do:
             APPLY "ENTRY" to b-printer.
        end.
    END CASE.
    return error.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME