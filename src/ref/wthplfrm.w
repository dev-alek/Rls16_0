&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER buf_cash-desk FOR ub.cash-desk.
DEFINE BUFFER buf_obj FOR ub.clients.
DEFINE BUFFER buf_sysconf FOR ub.sysconf.
DEFINE BUFFER locked_wth-place FOR ub.wth-place.
DEFINE TEMP-TABLE tt-wth-place NO-UNDO LIKE ub.wth-place.


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Карточка места хранения материальной ценности

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
define input parameter par-mode as character no-undo.
define input parameter parhost-code like ub.clients.obj-code no-undo.
define input parameter parobj-type like ub.clients.obj-type no-undo.
define input parameter parobj-code like ub.clients.obj-code no-undo.
define input-output parameter par-ri as recid no-undo.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Карточка места хранения МЦ ".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/showinf.i }
DEFINE VARIABLE vardb-num like ub.clients.db-num.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-wth-place

/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define FIELDS-IN-QUERY-Dialog-Frame tt-wth-place.obj-code ~
tt-wth-place.obj-type tt-wth-place.w-p-code tt-wth-place.w-p-name ~
tt-wth-place.cash-desk tt-wth-place.main-cash-desk tt-wth-place.PS ~
tt-wth-place.host-code
&Scoped-define ENABLED-FIELDS-IN-QUERY-Dialog-Frame tt-wth-place.obj-code ~
tt-wth-place.obj-type tt-wth-place.w-p-code tt-wth-place.w-p-name ~
tt-wth-place.cash-desk tt-wth-place.main-cash-desk tt-wth-place.PS ~
tt-wth-place.host-code
&Scoped-define ENABLED-TABLES-IN-QUERY-Dialog-Frame tt-wth-place
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-Dialog-Frame tt-wth-place
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH tt-wth-place SHARE-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH tt-wth-place SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame tt-wth-place
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame tt-wth-place


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS tt-wth-place.obj-code tt-wth-place.obj-type ~
tt-wth-place.w-p-code tt-wth-place.w-p-name tt-wth-place.cash-desk ~
tt-wth-place.main-cash-desk tt-wth-place.PS tt-wth-place.host-code
&Scoped-define ENABLED-TABLES tt-wth-place
&Scoped-define FIRST-ENABLED-TABLE tt-wth-place
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-hist B-Help b-cash-desk ~
for-obj-name
&Scoped-Define DISPLAYED-FIELDS tt-wth-place.obj-code tt-wth-place.obj-type ~
tt-wth-place.w-p-code tt-wth-place.w-p-name tt-wth-place.cash-desk ~
tt-wth-place.main-cash-desk tt-wth-place.PS tt-wth-place.host-code
&Scoped-define DISPLAYED-TABLES tt-wth-place
&Scoped-define FIRST-DISPLAYED-TABLE tt-wth-place
&Scoped-Define DISPLAYED-OBJECTS for-obj-name

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-cash-desk
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "":L
     SIZE 3 BY 1
     BGCOLOR 8 FGCOLOR 0 .

DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-hist
     LABEL "Ис&тория"
     SIZE 10 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE for-obj-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 36.25 BY .67
     FGCOLOR 4  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY Dialog-Frame FOR
      tt-wth-place SCROLLING.
&ANALYZE-RESUME

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-hist AT ROW 1 COL 41
     B-Help AT ROW 1 COL 61
     tt-wth-place.obj-code AT ROW 3.67 COL 20.75 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 10 BY 1
     tt-wth-place.obj-type AT ROW 3.71 COL 13.75 NO-LABEL
          VIEW-AS SELECTION-LIST SINGLE SCROLLBAR-VERTICAL
          SIZE 7.88 BY 1
     tt-wth-place.w-p-code AT ROW 5.04 COL 20.88 COLON-ALIGNED
          LABEL "Код места хранения"
          VIEW-AS FILL-IN
          SIZE 13 BY 1
          FGCOLOR 4
     tt-wth-place.w-p-name AT ROW 6.42 COL 20.88 COLON-ALIGNED
          LABEL "Название" FORMAT "X(100)"
          VIEW-AS FILL-IN
          SIZE 37.75 BY 1
     b-cash-desk AT ROW 7.67 COL 30.75
     tt-wth-place.cash-desk AT ROW 7.75 COL 20.88 COLON-ALIGNED
          LABEL "Номер кассы" FORMAT ">>>9"
          VIEW-AS FILL-IN
          SIZE 6.75 BY 1
     tt-wth-place.main-cash-desk AT ROW 9.08 COL 22.75
          LABEL "Главная касса"
          VIEW-AS TOGGLE-BOX
          SIZE 26.75 BY 1
     tt-wth-place.PS AT ROW 11.25 COL 1.63 NO-LABEL
          VIEW-AS EDITOR SCROLLBAR-VERTICAL
          SIZE 75.13 BY 2.75
     tt-wth-place.host-code AT ROW 2.46 COL 12.25 COLON-ALIGNED
          LABEL "Фирма"
           VIEW-AS TEXT
          SIZE 10 BY .67
     for-obj-name AT ROW 3.83 COL 37.63 COLON-ALIGNED NO-LABEL
     "Примечание" VIEW-AS TEXT
          SIZE 12.63 BY .75 AT ROW 10.13 COL 1.5
     SPACE(63.86) SKIP(3.36)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Место хранения МЦ"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: buf_cash-desk B "?" ? ub cash-desk
      TABLE: buf_obj B "?" ? ub clients
      TABLE: buf_sysconf B "?" ? ub sysconf
      TABLE: locked_wth-place B "?" ? ub wth-place
      TABLE: tt-wth-place T "?" NO-UNDO ub wth-place
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

/* SETTINGS FOR FILL-IN tt-wth-place.cash-desk IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN tt-wth-place.host-code IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR TOGGLE-BOX tt-wth-place.main-cash-desk IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-wth-place.obj-code IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
ASSIGN
       tt-wth-place.PS:RETURN-INSERTED IN FRAME Dialog-Frame  = TRUE.

/* SETTINGS FOR FILL-IN tt-wth-place.w-p-code IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-wth-place.w-p-name IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "Temp-Tables.tt-wth-place"
     _Options          = "SHARE-LOCK"
     _Query            is OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Место хранения МЦ */
DO:
 run proc-save-record in this-procedure No-ERROR.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Место хранения МЦ */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-cash-desk
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-cash-desk Dialog-Frame
ON CHOOSE OF b-cash-desk IN FRAME Dialog-Frame
DO:
 define variable rid-list as character no-undo .
  run ref/cashlist.w (
                 input parparentproc
                ,input "b-sel":U
                ,input {&g___object}
                ,input vardb-num
                ,input parhost-code
                ,input parobj-type
                ,input parobj-code
                ,input ?
                ,output rid-list).
  if rid-list <> "":U then do:
      FIND FIRST buf_cash-desk WHERE
                  recid(buf_cash-desk) = integer(entry(1, rid-list)) NO-LOCK .
      if buf_cash-desk.obj-code <> parobj-code then do:
        message "Выбранная касса принадлежит другому магазину"
        view-as alert-box.
        return no-apply.
      end.
      if buf_cash-desk.db-num <> vardb-num then do:
          message "Выбранная касса принадлежит другой БД"
          view-as alert-box.
          return no-apply.
      end.
      DISPLAY
      buf_cash-desk.cash-num @ tt-wth-place.cash-desk
      with frame {&frame-name} .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-hist Dialog-Frame
ON CHOOSE OF B-hist IN FRAME Dialog-Frame /* История */
DO:
  DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
  run ref/wthc-pls.w (
                    INPUT parParentProc
                   ,input '':U /*bttns*/
                   ,input 'one':U /*p-mode*/
                   ,input parobj-type
                   ,input parobj-code
                   ,INPUT tt-wth-place.w-p-code
                   ,INPUT-OUTPUT v-rid-list) NO-ERROR.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-wth-place.cash-desk
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-wth-place.cash-desk Dialog-Frame
ON LEAVE OF tt-wth-place.cash-desk IN FRAME Dialog-Frame /* Номер кассы */
DO:
  if INPUT FRAME {&FRAME-NAME} tt-WTH-PLACE.cash-desk = 0 then return.
  FIND FIRST buf_CASH-DESK NO-LOCK WHERE
             buf_CASH-DESK.CASH-NUM = INPUT FRAME {&FRAME-NAME} tt-WTH-PLACE.cash-desk AND
             buf_cash-desk.obj-code = tt-wth-place.obj-code AND
             buf_cash-desk.db-num = vardb-num NO-ERROR.
  if not avail buf_cash-desk then do:
    message
    "Нет кассы с N" INPUT FRAME {&FRAME-NAME} tt-WTH-PLACE.cash-desk
    view-as alert-box ERROR.
  end.
  else if buf_cash-desk.obj-code <> tt-wth-place.obj-code then do:
    message
    "Выбранная касса принадлежит другому магазину"
    view-as alert-box ERROR.
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
    if par-mode <> {&update} and par-mode <> {&add-def} and par-mode <> {&lookup} then do:
        message vss-workfile vss-revision vss-description skip
                    "Неверный параметр вызова par-mode"
        view-as alert-box ERROR.
        return error.
    end.
    find first ub.sysconf No-LOCK WHERE
                     ub.sysconf.host-code = parhost-code No-ERROR.
    if not avail ub.sysconf then do:
        message vss-workfile vss-revision vss-description skip
                        "Неверный параметр вызова parhost-code"
            view-as alert-box ERROR.
            return error.
    end.
    find first ub.clients No-LOCK WHERE
                ub.clients.obj-type = parobj-type AND
                ub.clients.obj-code = parobj-code No-ERROR.
    if not avail ub.clients then do:
        message vss-workfile vss-revision vss-description skip
                        "Неверный параметр вызова parobj-type/parobj-code"
            view-as alert-box ERROR.
            return error.
    end.
    vardb-num = ub.clients.db-num.
    find first ub.sys-ctrl No-LOCK.
    if vardb-num <> ub.sys-ctrl.db-num then do:
      /*БД не этого объекта*/
      if par-mode <> {&lookup} then do:
        message
        vss-workfile vss-revision vss-description skip
        "Неверный параметр вызова par-mode" par-mode
        "для объекта, принадлежащего другой БД"
        view-as alert-box error .
        return error .
      end.
    end.
    tt-wth-place.obj-type:list-items =
                                    {&shop} + {&comma-char} +
                                    {&stock} + {&comma-char}.

  Run fill-tables in this-procedure no-error.
  if error-status:error then return error.
  RUN MYenable.
  WAIT-FOR GO OF FRAME {&FRAME-NAME} FOCUS tt-wth-place.w-p-name.
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

  {&OPEN-QUERY-Dialog-Frame}
  GET FIRST Dialog-Frame.
  DISPLAY for-obj-name
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-wth-place THEN
    DISPLAY tt-wth-place.obj-code tt-wth-place.obj-type tt-wth-place.w-p-code
          tt-wth-place.w-p-name tt-wth-place.cash-desk
          tt-wth-place.main-cash-desk tt-wth-place.PS tt-wth-place.host-code
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-hist B-Help tt-wth-place.obj-code
         tt-wth-place.obj-type tt-wth-place.w-p-code tt-wth-place.w-p-name
         b-cash-desk tt-wth-place.cash-desk tt-wth-place.main-cash-desk
         tt-wth-place.PS tt-wth-place.host-code for-obj-name
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-tables Dialog-Frame
PROCEDURE fill-tables :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
for each tt-wth-place:
    delete tt-wth-place.
end.

IF par-mode = {&add-def} then do:
    DO TRANSACTION ON ERROR UNDO, RETURN ERROR return-value :
      create tt-wth-place.
      assign
      tt-wth-place.host-code = parhost-code
      tt-wth-place.obj-type = parobj-type
      tt-wth-place.obj-code = parobj-code
      tt-wth-place.status_ = {&current-status}
      .
    END.
    FIND FIRST buf_obj No-LOCK WHERe
                buf_obj.obj-type = parobj-type AND
                buf_obj.obj-code = parobj-code No-ERROR.
end.
else do:
  if par-mode = {&lookup} then do:
    FIND FIRST locked_wth-place NO-LOCK WHERE
                recid(locked_wth-place) = par-ri.
  end.
  ELSE do:
    DO TRANSACTION
      ON ERROR UNDO, RETURN ERROR:
           FIND FIRST locked_wth-place NO-LOCK WHERE
                recid(locked_wth-place) = par-ri.

    END.
  END.
  if
  locked_wth-place.host-code <> parhost-code or
  locked_wth-place.obj-type<> parobj-type or
  locked_wth-place.obj-code <> parobj-code then do:
    message vss-workfile vss-revision vss-description skip
                        "Неверный параметр вызова parhost-code и/или"
                        "parobj-type/parobj-code"
            view-as alert-box ERROR.
            return error.
end.



  IF NOT AVAIL locked_wth-place then
  return error.
  create tt-wth-place.
  buffer-copy locked_wth-place to tt-wth-place.
    FIND FIRST buf_obj No-LOCK WHERe
                buf_obj.obj-type = tt-wth-place.obj-type AND
                buf_obj.obj-code = tt-wth-place.obj-code No-ERROR.
    if not avail buf_obj then do:
      message "Место хранения" locked_wth-place.w-p-code  skip
              "Неверный объект" locked_wth-place.obj-type locked_wth-place.obj-code
      view-as alert-box ERROR.
      return error.
    end.
    if tt-wth-place.obj-type = {&stock} then do:
        if tt-wth-place.cash-desk <>  0 then do:
        FIND FIRST buf_cash-desk No-LOCK WHERE
                buf_cash-desk.db-num = vardb-num AND
                buf_cash-desk.obj-code = tt-wth-place.obj-code AND
                buf_cash-desk.cash-num = tt-wth-place.cash-desk No-ERROR.
            if not avail buf_cash-desk then do:
              message "Место хранения" locked_wth-place.w-p-code  skip
                      "Неверный номер кассы" locked_wth-place.cash-desk
              view-as alert-box ERROR.
              return error.
            end.
    end.
    end.

end.

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
  DISPLAY for-obj-name
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-wth-place THEN
    DISPLAY
    tt-wth-place.obj-type
    tt-wth-place.obj-code
    tt-wth-place.w-p-code
    tt-wth-place.w-p-name
    tt-wth-place.cash-desk
    tt-wth-place.main-cash-desk
    tt-wth-place.PS
    tt-wth-place.host-code
    WITH FRAME Dialog-Frame.
    if available buf_obj then
    display
    buf_obj.obj-name @ for-obj-name
    WITH FRAME Dialog-Frame.
    CASE par-mode:
        when {&add-def} then do:
            ENABLE
            B-exit
            b-quit
            B-Help
            tt-wth-place.w-p-name
            b-cash-desk when tt-wth-place.obj-type = {&shop}
            tt-wth-place.cash-desk when tt-wth-place.obj-type = {&shop}
            tt-wth-place.main-cash-desk  when tt-wth-place.obj-type = {&shop}
            tt-wth-place.PS
            WITH FRAME Dialog-Frame.
        end.
        when {&update} then do:
                    ENABLE
                    B-exit
                    b-quit
                    B-Help
                    tt-wth-place.w-p-name
                    b-cash-desk when tt-wth-place.obj-type = {&shop}
                    tt-wth-place.cash-desk when tt-wth-place.obj-type = {&shop}
                    tt-wth-place.main-cash-desk  when tt-wth-place.obj-type = {&shop}
                    tt-wth-place.PS
                    WITH FRAME Dialog-Frame.
        end.
        when {&lookup} then do:
            b-quit:label = "&Выход".
                        HIDE
                        b-exit
                        in frame {&frame-name}.
        end.
    END CASE.
  ENABLE
  b-quit
  B-Help
  b-hist WHEN par-mode <> {&ADD-DEF}
  WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save-record Dialog-Frame 
PROCEDURE proc-save-record :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
 IF par-mode = {&lookup} THEN DO:
    RETURN error.
 END.
 assign
tt-wth-place.w-p-code frame {&frame-name}
tt-wth-place.host-code
tt-wth-place.obj-type
tt-wth-place.obj-code
tt-wth-place.w-p-name
tt-wth-place.cash-desk
tt-wth-place.main-cash-desk
tt-wth-place.PS
 .
 if par-mode <> {&add-def} then
 par-ri = recid(locked_wth-place).
 else par-ri = ?.
 run ref/wthplfr1.p (
                  input-output par-ri
                 ,input        par-mode
                 ,input tt-wth-place.w-p-code
                 ,input tt-wth-place.host-code
                 ,input tt-wth-place.obj-type
                 ,input tt-wth-place.obj-code
                 ,input tt-wth-place.w-p-name
                 ,input tt-wth-place.status_
                 ,input tt-wth-place.cash-desk
                 ,input tt-wth-place.main-cash-desk
                 ,input tt-wth-place.PS
                 ) no-error .
    IF ERROR-STATUS:ERROR THEN DO:
    if return-value <> '':U then do:
      CASE return-value:
        when "obj-code":U then do:
          APPLY "ENTRY":U TO tt-wth-place.obj-code IN FRAME {&FRAME-NAME}.
        end.
        when "cash-desk":U then do:
          APPLY "ENTRY":U TO tt-wth-place.cash-desk IN FRAME {&FRAME-NAME}.
        end.
        when "main-cash-desk":U then do:
          APPLY "ENTRY":U TO tt-wth-place.main-cash-desk IN FRAME {&FRAME-NAME}.
        end.

      END CASE.
    end.
    RETURN error.
  END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

