&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME sch-frame

/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE tt_schedule NO-UNDO LIKE ub.schedule.


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS sch-frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Редактирование строки расписани

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/22/02
Author: Dmitry Ukhanov
Creation date: 03/22/02

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input        parameter parparentproc as widget-handle no-undo .
define input        parameter p-action     as   character              no-undo .
define input        parameter p-cre-db-num like ub.schedule.cre-db-num no-undo .
define input        parameter p-task-type  like ub.schedule.task-type  no-undo .
define input-output parameter p-recid      as   recid                  no-undo .
define output       parameter p-modify     as   logical                no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Редактирование строки рассписания".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/showinf.i  }
{ adm/schedule.i }
{ gbl/cur-time.i }
{ ref/shd-attr.i }
{ gbl/getcntxt.i def }

define buffer buf_schedule     for ub.schedule .
define buffer buf-src_schedule for ub.schedule .
define buffer buf_sys-ctrl     for ub.sys-ctrl.

define variable v-free-id         as character no-undo .
define variable v-cancel          as logical   no-undo .
define variable v-params          as character no-undo .
DEFINE VARIABLE v-enable-db-num   as logical   no-undo.
define variable v-free-task-name  as character no-undo .
define variable is-ubd            as logical   no-undo init yes.
define variable is-gbd            as logical   no-undo init yes.
define variable v-free-attr-value as character no-undo .

define temp-table tt-val no-undo
  field t-val as integer
  index pi as unique primary t-val

  .

&scop unkn-val if ~{&self-name~}:screen-value = "?":U then assign ~{&self-name~}:screen-value = "*":U .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME sch-frame

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt_schedule

/* Definitions for DIALOG-BOX sch-frame                              */
&Scoped-define FIELDS-IN-QUERY-sch-frame tt_schedule.active ~
tt_schedule.db-num-char tt_schedule.task-year tt_schedule.task-month ~
tt_schedule.task-day tt_schedule.task-weekday tt_schedule.task-hour ~
tt_schedule.task-minute
&Scoped-define ENABLED-FIELDS-IN-QUERY-sch-frame tt_schedule.active ~
tt_schedule.db-num-char tt_schedule.task-year tt_schedule.task-month ~
tt_schedule.task-day tt_schedule.task-weekday tt_schedule.task-hour ~
tt_schedule.task-minute
&Scoped-define ENABLED-TABLES-IN-QUERY-sch-frame tt_schedule
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-sch-frame tt_schedule
&Scoped-define QUERY-STRING-sch-frame FOR EACH tt_schedule SHARE-LOCK
&Scoped-define OPEN-QUERY-sch-frame OPEN QUERY sch-frame FOR EACH tt_schedule SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-sch-frame tt_schedule
&Scoped-define FIRST-TABLE-IN-QUERY-sch-frame tt_schedule


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS tt_schedule.active tt_schedule.db-num-char ~
tt_schedule.task-year tt_schedule.task-month tt_schedule.task-day ~
tt_schedule.task-weekday tt_schedule.task-hour tt_schedule.task-minute
&Scoped-define ENABLED-TABLES tt_schedule
&Scoped-define FIRST-ENABLED-TABLE tt_schedule
&Scoped-Define ENABLED-OBJECTS b-exit b-quit b-help
&Scoped-Define DISPLAYED-FIELDS tt_schedule.active tt_schedule.db-num-char ~
tt_schedule.task-year tt_schedule.task-month tt_schedule.task-day ~
tt_schedule.task-weekday tt_schedule.task-hour tt_schedule.task-minute
&Scoped-define DISPLAYED-TABLES tt_schedule
&Scoped-define FIRST-DISPLAYED-TABLE tt_schedule


/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-exit AUTO-GO DEFAULT
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-help DEFAULT
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-END-KEY DEFAULT
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY sch-frame FOR
      tt_schedule SCROLLING.
&ANALYZE-RESUME

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME sch-frame
     b-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     b-help AT ROW 1 COL 24
     tt_schedule.active AT ROW 2.25 COL 15.5
          VIEW-AS TOGGLE-BOX
          SIZE 8.75 BY 1
     tt_schedule.db-num-char AT ROW 3.5 COL 13 COLON-ALIGNED FORMAT "X(256)"
          VIEW-AS FILL-IN
          SIZE 60 BY 1
     tt_schedule.task-year AT ROW 5.25 COL 13 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 5 BY 1
     tt_schedule.task-month AT ROW 5.25 COL 27 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 3 BY 1
     tt_schedule.task-day AT ROW 5.25 COL 38.5 COLON-ALIGNED
          LABEL "Число"
          VIEW-AS FILL-IN
          SIZE 3 BY 1
     tt_schedule.task-weekday AT ROW 6.5 COL 13 COLON-ALIGNED HELP
          ""
          LABEL "Дни недели" FORMAT "X(13)"
          VIEW-AS FILL-IN
          SIZE 14 BY 1
     tt_schedule.task-hour AT ROW 8 COL 13 COLON-ALIGNED
          LABEL "Часы" FORMAT "X(75)"
          VIEW-AS FILL-IN
          SIZE 60 BY 1
     tt_schedule.task-minute AT ROW 9.25 COL 13 COLON-ALIGNED
          LABEL "Минуты" FORMAT "X(183)"
          VIEW-AS FILL-IN
          SIZE 60 BY 1
     SPACE(0.87) SKIP(0.45)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Строка расписания"
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: tt_schedule T "?" NO-UNDO ub schedule
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX sch-frame
                                                                        */
ASSIGN
       FRAME sch-frame:SCROLLABLE       = FALSE
       FRAME sch-frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN tt_schedule.db-num-char IN FRAME sch-frame
   EXP-FORMAT                                                           */
/* SETTINGS FOR FILL-IN tt_schedule.task-day IN FRAME sch-frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt_schedule.task-hour IN FRAME sch-frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN tt_schedule.task-minute IN FRAME sch-frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN tt_schedule.task-weekday IN FRAME sch-frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX sch-frame
/* Query rebuild information for DIALOG-BOX sch-frame
     _TblList          = "Temp-Tables.tt_schedule"
     _Options          = "SHARE-LOCK"
     _Query            is OPENED
*/  /* DIALOG-BOX sch-frame */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME sch-frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-frame sch-frame
ON WINDOW-CLOSE OF FRAME sch-frame /* Строка расписания */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt_schedule.active
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt_schedule.active sch-frame
ON RETURN OF tt_schedule.active IN FRAME sch-frame /* Актив */
DO:
  apply "entry" to tt_schedule.task-year in frame {&frame-name}.
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit sch-frame
ON CHOOSE OF b-exit IN FRAME sch-frame /* Ввод */
DO:
  assign
    tt_schedule.db-num-char
    tt_schedule.active
    tt_schedule.task-year
    tt_schedule.task-month
    tt_schedule.task-day
    tt_schedule.task-weekday
    tt_schedule.task-hour
    tt_schedule.task-minute
  .
  run proc-save in this-procedure
    no-error.
  if error-status:error then do:
    return no-apply.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt_schedule.db-num-char
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt_schedule.db-num-char sch-frame
ON LEAVE OF tt_schedule.db-num-char IN FRAME sch-frame /* БД */
DO:
  {&unkn-val}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt_schedule.db-num-char sch-frame
ON RETURN OF tt_schedule.db-num-char IN FRAME sch-frame /* БД */
DO:
  apply "entry" to tt_schedule.active in frame {&frame-name}.
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt_schedule.task-day
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt_schedule.task-day sch-frame
ON LEAVE OF tt_schedule.task-day IN FRAME sch-frame /* Число */
DO:
  {&unkn-val}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt_schedule.task-day sch-frame
ON RETURN OF tt_schedule.task-day IN FRAME sch-frame /* Число */
DO:
  apply "entry" to tt_schedule.task-weekday in frame {&frame-name}.
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt_schedule.task-hour
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt_schedule.task-hour sch-frame
ON LEAVE OF tt_schedule.task-hour IN FRAME sch-frame /* Часы */
DO:
  {&unkn-val}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt_schedule.task-hour sch-frame
ON RETURN OF tt_schedule.task-hour IN FRAME sch-frame /* Часы */
DO:
  apply "entry" to tt_schedule.task-minute in frame {&frame-name}.
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt_schedule.task-minute
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt_schedule.task-minute sch-frame
ON LEAVE OF tt_schedule.task-minute IN FRAME sch-frame /* Минуты */
DO:
  {&unkn-val}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt_schedule.task-minute sch-frame
ON RETURN OF tt_schedule.task-minute IN FRAME sch-frame /* Минуты */
DO:
  apply "choose" to b-exit in frame {&frame-name}.
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt_schedule.task-month
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt_schedule.task-month sch-frame
ON LEAVE OF tt_schedule.task-month IN FRAME sch-frame /* Месяц */
DO:
  {&unkn-val}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt_schedule.task-month sch-frame
ON RETURN OF tt_schedule.task-month IN FRAME sch-frame /* Месяц */
DO:
  apply "entry" to tt_schedule.task-day in frame {&frame-name}.
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt_schedule.task-weekday
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt_schedule.task-weekday sch-frame
ON LEAVE OF tt_schedule.task-weekday IN FRAME sch-frame /* Дни недели */
DO:
  {&unkn-val}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt_schedule.task-weekday sch-frame
ON RETURN OF tt_schedule.task-weekday IN FRAME sch-frame /* Дни недели */
DO:
  apply "entry" to tt_schedule.task-hour in frame {&frame-name}.
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt_schedule.task-year
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt_schedule.task-year sch-frame
ON LEAVE OF tt_schedule.task-year IN FRAME sch-frame /* Год */
DO:
  {&unkn-val}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt_schedule.task-year sch-frame
ON RETURN OF tt_schedule.task-year IN FRAME sch-frame /* Год */
DO:
  apply "entry" to tt_schedule.task-month in frame {&frame-name}.
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK sch-frame


/* ***************************  Main Block  *************************** */

{ gbl/app_help.i }

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

  define variable v-task-num like ub.schedule.task-num no-undo .

  { gbl/getcntxt.i get }

  assign
    v-task-num = 0
    v-free-id  = "":U
  .
  case p-action :
    when {&update} then do:
      find first buf_schedule exclusive-lock
        where recid( buf_schedule ) = p-recid
        no-error
      .
      if not available buf_schedule then do:
        message vss-workfile vss-revision vss-description skip
          "Не найдена строка расписания для редактирования!"
          view-as alert-box error.
        return error .
      end.
      else do:
        assign
          v-task-num = buf_schedule.task-num
        .
      end.
    end.
    when {&add-copy} then do:
      find first buf-src_schedule exclusive-lock
        where recid( buf-src_schedule ) = p-recid
        no-error
      .
      if not available buf-src_schedule then do:
        message vss-workfile vss-revision vss-description skip
          "Не найдена строка расписания для копирования!"
          view-as alert-box error.
        return error .
      end.
      else do:
        assign
          v-task-num = buf-src_schedule.task-num
        .
      end.
    end.
  end case.

  if ( not available buf_schedule
       and p-action = {&update}
     )
     or ( not available buf-src_schedule
          and p-action = {&add-copy}
        )
  then do:
  end.
  if p-task-type = {&btpr-type-autofree} then do:
    if p-action = {&add-copy} then do:
      run schedule-attr-get-free-id  in this-procedure
        ( input p-cre-db-num
         ,input p-task-type
         ,input v-task-num
         ,output v-free-id
        ) no-error .
      if error-status:error then do:
        undo, return error substitute( "&1. Невозможно получить название  произвольного задания по строке расписания &3&2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) ) .
      end.
    end.
    if v-free-id = "":U then do:
      run adm/freeshdp.w
        ( input parparentproc
        ,input 0 /*p-curr-host-code*/
        ,input '':U /*p-curr-obj-type*/
        ,input 0 /*p-curr-obj-code*/
        ,input p-action /*это реж редактирования */
        ,input p-cre-db-num
        ,input p-task-type
        ,input v-task-num /*task-num*/
        ,input '':U /*action - а это режим вызова - при отдельном редактиролваниия для авто запсука или рувное выполнение*/
        ,input-output v-free-id /*p-free-id*/
        ,output v-cancel
        ,output v-params
      ) no-error.
      if error-status :error then do:
        undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) ) .
      end.
      if v-free-id = '':U
        or ( v-cancel
            and p-action <> {&update}
          )
      then do:
        undo, return error return-value .
      end.
    end.
  end.

  run fill-temp-table in this-procedure no-error.
  if error-status:error then do:
    message
    substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    view-as alert-box .
    undo, return error.
  end.

  assign
    p-modify = false
  .
  frame {&frame-name}:title = substitute( "Строка расписания для БД &1", p-cre-db-num ).

  RUN Myenable.

  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.

RUN disable_UI.

delete tt_schedule .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI sch-frame  _DEFAULT-DISABLE
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
  HIDE FRAME sch-frame.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI sch-frame  _DEFAULT-ENABLE
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

  {&OPEN-QUERY-sch-frame}
  GET FIRST sch-frame.
  IF AVAILABLE tt_schedule THEN
    DISPLAY tt_schedule.active tt_schedule.db-num-char tt_schedule.task-year
          tt_schedule.task-month tt_schedule.task-day tt_schedule.task-weekday
          tt_schedule.task-hour tt_schedule.task-minute
      WITH FRAME sch-frame.
  ENABLE b-exit b-quit b-help tt_schedule.active tt_schedule.db-num-char
         tt_schedule.task-year tt_schedule.task-month tt_schedule.task-day
         tt_schedule.task-weekday tt_schedule.task-hour tt_schedule.task-minute
      WITH FRAME sch-frame.
  VIEW FRAME sch-frame.
  {&OPEN-BROWSERS-IN-QUERY-sch-frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-temp-table sch-frame
PROCEDURE fill-temp-table :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :

    define variable v-db-num-char like ub.schedule.db-num-char no-undo.
    define variable v-value       as   character               no-undo .

    define buffer buf_temp-schedule-free for temp-schedule-free.

    find first buf_sys-ctrl no-lock.

    create tt_schedule .

    if available buf_schedule then do:
      buffer-copy buf_schedule to tt_schedule .
    end.
    else do:
      if available buf-src_schedule then do:
        buffer-copy buf-src_schedule to tt_schedule .
      end.
      else do:
        assign
          tt_schedule.task-type   = p-task-type
          tt_schedule.db-num-char = "*":U
          tt_schedule.activ       = false
        .
      end.
    end.

    assign
      tt_schedule.task-second = "00"
    .

    case p-task-type:
      when  {&btpr-type-autosale}
      or when {&btpr-type-autogetcd}
      or when {&btpr-type-autooxml}
      or when {&btpr-type-autosuz}
      or when {&btpr-type-is_PM}
      then do:
        assign
          v-db-num-char = string (p-cre-db-num)
          is-gbd = no
          v-enable-db-num = no
        .
      end.
      when {&btpr-type-autofree} then do:
        run schedule-attr-get-free-props in this-procedure (input v-free-id, output v-free-attr-value).
        if v-free-attr-value <> '':u then do:
          assign
          is-gbd = (entry(buffer buf_temp-schedule-free:buffer-field("is-gbd"):position - 2, v-free-attr-value, {&delim-par} ) = "yes")
          is-ubd = (entry(buffer buf_temp-schedule-free:buffer-field("is-ubd"):position - 2, v-free-attr-value, {&delim-par} ) = "yes")
          v-free-task-name = entry(buffer buf_temp-schedule-free:buffer-field("free-task-name"):position - 2, v-free-attr-value, {&delim-par} )
          v-enable-db-num = no
          .
          if (is-ubd = yes
          and p-cre-db-num > 0)
          or (is-gbd = yes
          and p-cre-db-num = 0)
          then do:
            assign
            v-db-num-char = string (p-cre-db-num)
            .
          end.
          else do:
            undo, return error substitute("Задание &1 невыполнимо в БД &2", v-free-task-name, p-cre-db-num).
          end.
        end.
        else do:
          undo, return error return-value .
        end.
        if p-action = {&update} then do:
          assign
            v-enable-db-num = no
          .
        end.
      end.
      otherwise do:
        assign
          v-db-num-char = "*":u
          v-enable-db-num = yes
        .
        case p-task-type:
          when {&btpr-type-autonws}
          then do:
          end.
          when {&btpr-type-mercury}
          then do:
          end.
          when {&btpr-type-hddtest}
          then do:
          end.
          when {&btpr-type-is_motp}
          then do:
          end.
          when {&btpr-type-is_diadoc}
          then do:
          end.
          otherwise do:
            if p-action = {&update}
              or p-action = {&add-copy}
            then do:
              assign
                v-enable-db-num = yes
              .
            end.
          end.
        end case.
      end.
    end case.
    if p-action = {&add-def} then do:
      assign
        tt_schedule.db-num-char = v-db-num-char.
      .
    end.
  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyENable sch-frame
PROCEDURE MyENable :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
IF AVAILABLE tt_schedule THEN
DISPLAY
tt_schedule.db-num-char
tt_schedule.active
tt_schedule.task-year
tt_schedule.task-hour
tt_schedule.task-month
tt_schedule.task-minute
tt_schedule.task-day
tt_schedule.task-weekday
WITH FRAME {&frame-name}.
ENABLE
b-exit
b-quit
b-help
tt_schedule.db-num-char WHEN v-enable-db-num
tt_schedule.active
tt_schedule.task-year
tt_schedule.task-hour
tt_schedule.task-month
tt_schedule.task-minute
tt_schedule.task-day
tt_schedule.task-weekday
WITH FRAME {&frame-name}.
if p-task-type = {&btpr-type-autofree} then do:
  assign
  frame {&frame-name}:title = v-free-task-name.
end.
VIEW FRAME {&frame-name}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save sch-frame
PROCEDURE proc-save :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

do
on error undo, return error return-value
:
  define buffer buf-chk_db            for ub.db .
  define buffer buf-src_schedule-attr for ub.schedule-attr .
  define buffer buf_schedule-attr     for ub.schedule-attr .

  define variable v-tmp-int as integer   no-undo .
  define variable v-today   as date      no-undo .
  define variable v-time    as integer   no-undo .
  define variable v-equal   as logical   no-undo .

  define variable v-hour-str    as character no-undo .
  define variable v-num-entries as integer   no-undo .
  define variable v-ind         as integer   no-undo .
  define variable v-hour-int    as integer   no-undo .
  define variable v-hour-beg    as integer   no-undo .
  define variable v-hour-end    as integer   no-undo .
  
  define variable v-shift-num as integer no-undo .
  define variable v-shift-date as date no-undo .
  
  define buffer buf_shift-obj for ub.shift-obj .

  run cur-time ( output v-today
              ,output v-time
            ).

  assign
    tt_schedule.db-num-char  = trim( tt_schedule.db-num-char )
    tt_schedule.task-year    = trim( tt_schedule.task-year )
    tt_schedule.task-month   = trim( tt_schedule.task-month )
    tt_schedule.task-day     = trim( tt_schedule.task-day )
    tt_schedule.task-weekday = trim( tt_schedule.task-weekday )
    tt_schedule.task-hour    = trim( tt_schedule.task-hour )
    tt_schedule.task-minute  = trim( tt_schedule.task-minute )
  .
  if tt_schedule.db-num-char <> "*":U then do:
    for each tt-val
    on error undo, return error return-value
    :
      delete tt-val.
    end.
    run gbl/prcs-lst.p
      ( input tt_schedule.db-num-char
       ,input 0
       ,input 99999  /* (максимальное значение db.db-num) */
       ,input true
       ,input (buffer tt-val:handle)
       ,input "t-val":U
      ) no-error .

    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        'Номер БД может быть только числовым или "*"!'
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      apply "entry" to tt_schedule.db-num-char in frame {&frame-name}.
      undo, return error .
    end.

    for each tt-val no-lock
    on error undo, return error return-value
    :
      find first buf-chk_db no-lock
        where buf-chk_db.db-num = tt-val.t-val
        no-error
      .
      if not available buf-chk_db then do:
        message vss-workfile vss-revision vss-description skip
          "Нет БД с номером" tt-val.t-val
          view-as alert-box error.
        apply "entry" to tt_schedule.db-num-char in frame {&frame-name}.
        undo, return error .
      end.
      if p-task-type = {&btpr-type-autofree}
      and buf-chk_db.db-num <> 0
      and is-ubd = no
      then do:
        message
        substitute("Для произвольного задания &1 можно задать расписание ТОЛЬКО для ГБД", v-free-task-name)
        view-as alert-box error .
        undo, return error.
      end.

      if p-task-type = {&btpr-type-autogetcd} then do:
        if buf-chk_db.db-num <> buf_sys-ctrl.db-num then do:
          message
          "Для автоматического приема информации с касс можно задать расписание ТОЛЬКО для текущей БД"
          view-as alert-box error .
          undo, return error.
        end.
      end.
      if p-task-type = {&btpr-type-autosale} then do:
      find first buf_sys-ctrl no-lock.
      if buf-chk_db.db-num <> buf_sys-ctrl.db-num then do:
          message
          "Для автоматической обработки документов продаж можно задать расписание ТОЛЬКО для текущей БД"
          view-as alert-box error .
          undo, return error.
        end.
      end.
      if p-task-type = {&btpr-type-autocbnk} then do:
      find first buf_sys-ctrl no-lock.
      if buf-chk_db.db-num <> 0 then do:
          message
          "Для автоматической обработки документов продаж можно задать расписание ТОЛЬКО для ГБД"
          view-as alert-box error .
          undo, return error.
        end.
      end.
    end.
    /*гюнтнер согласен и извещен*/
    if p-task-type = {&btpr-type-autooxml} then do:
      if buf-chk_db.db-num <> buf_sys-ctrl.db-num then do:
        message
        "Для работы системы OpenXML можно задать расписание ТОЛЬКО для текущей БД"
        view-as alert-box error .
        undo, return error.
      end.
    end.
  end.
  else do:
    if p-task-type = {&btpr-type-autogetcd}
    or p-task-type = {&btpr-type-autosale}
    or p-task-type = {&btpr-type-autooxml}
    /*гюнтнер согласен и извещен*/
    then do:
      message
      "Для данного типа задач можно задать расписание только по текущей БД!"
      view-as alert-box error .
      undo, return error.
    end.
  end.

  if tt_schedule.task-weekday <> "*":U then do:
    for each tt-val
    on error undo, return error return-value
    :
      delete tt-val.
    end.
    run gbl/prcs-lst.p
      ( input tt_schedule.task-weekday
       ,input 1
       ,input 7
       ,input true
       ,input (buffer tt-val:handle)
       ,input "t-val":U
      ) no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        'Дни недели могут иметь только числовое значение в интервале от 1 до 7 или "*"!' skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      apply "entry" to tt_schedule.task-weekday in frame {&frame-name}.
      undo, return error .
    end.
  end.

  if tt_schedule.task-weekday <> "*":U
    and ( tt_schedule.task-year <> "*":U
         or tt_schedule.task-month <> "*":U
         or tt_schedule.task-day <> "*":U
        )
  then do:
    message vss-workfile vss-revision vss-description skip
      'Заданы дни недели, поэтому поля "год", "месяц" и "число" должны иметь значение "*"'
      view-as alert-box error.
    apply "entry" to tt_schedule.task-year in frame {&frame-name}.
    undo, return error .
  end.

  if tt_schedule.task-year <> "*":U then do:
    assign
      v-tmp-int = integer( tt_schedule.task-year )
      no-error
    .
    if error-status :error then do:
      message vss-workfile vss-revision vss-description skip
        'Год может быть только числовым или "*"!'
        view-as alert-box error.
      apply "entry" to tt_schedule.task-year in frame {&frame-name}.
      undo, return error .
    end.
    if year( v-today ) > integer( tt_schedule.task-year ) then do:
      message vss-workfile vss-revision vss-description skip
        "Год не может быть меньше текущего!"
        view-as alert-box error.
      apply "entry" to tt_schedule.task-year in frame {&frame-name}.
      undo, return error .
    end.
  end.

  if tt_schedule.task-month <> "*":U then do:
    assign
      v-tmp-int = integer( tt_schedule.task-month )
      no-error
    .
    if error-status :error then do:
      message vss-workfile vss-revision vss-description skip
        'Месяц может быть только числовым или "*"!'
        view-as alert-box error.
      apply "entry" to tt_schedule.task-month in frame {&frame-name}.
      undo, return error .
    end.
    if integer( tt_schedule.task-month ) > 12
      or integer( tt_schedule.task-month ) < 1
    then do:
      message vss-workfile vss-revision vss-description skip
        "Месяц может быть только в интервале от 1 до 12 !"
        view-as alert-box error.
      apply "entry" to tt_schedule.task-month in frame {&frame-name}.
      undo, return error .
    end.
  end.

  if tt_schedule.task-day <> "*":U then do:
    assign
      v-tmp-int = integer( tt_schedule.task-day )
      no-error
    .
    if error-status :error then do:
      message vss-workfile vss-revision vss-description skip
        'День месяца может быть только числовым или "*"!'
        view-as alert-box error.
      apply "entry" to tt_schedule.task-day in frame {&frame-name}.
      undo, return error .
    end.
    if integer( tt_schedule.task-day ) > 31
      or integer( tt_schedule.task-day ) < 1
    then do:
      message vss-workfile vss-revision vss-description skip
        "День месяца может быть только в интервале от 1 до 31 !"
        view-as alert-box error.
      apply "entry" to tt_schedule.task-day in frame {&frame-name}.
      undo, return error .
    end.
  end.

  if tt_schedule.task-hour <> "*":U then do:
    for each tt-val
    on error undo, return error return-value
    :
      delete tt-val.
    end.
    run gbl/prcs-lst.p
      ( input tt_schedule.task-hour
       ,input 0
       ,input 24
       ,input true
       ,input (buffer tt-val:handle)
       ,input "t-val":U
      ) no-error .

    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        'Часы могут иметь только числовое значение в интервале от 0 до 24 или "*"!' skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      apply "entry" to tt_schedule.task-hour in frame {&frame-name}.
      undo, return error .
    end.
  end.

  if tt_schedule.task-minute <> "*":U then do:
    for each tt-val
    on error undo, return error return-value
    :
      delete tt-val.
    end.
    run gbl/prcs-lst.p
      ( input tt_schedule.task-minute
       ,input 0
       ,input 60
       ,input true
       ,input (buffer tt-val:handle)
       ,input "t-val":U
      ) no-error .

    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        'Минуты могут иметь только числовое значение в интервале от 0 до 60 или "*"!' skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      apply "entry" to tt_schedule.task-minute in frame {&frame-name}.
      undo, return error .
    end.
  end.

  if not available buf_schedule then do:
    create buf_schedule.
    assign
      buf_schedule.cre-db-num = p-cre-db-num
      buf_schedule.task-type  = p-task-type
      buf_schedule.task-num   = next-value( s-task-num, {&db-name_schema} )
    .
  end.

  buffer-compare tt_schedule TO buf_schedule save result in v-equal no-error.
  if not v-equal then do:
    buffer-copy tt_schedule except cre-db-num task-type task-num TO buf_schedule.
    assign
      p-modify = true
    .
  end.
  if p-action = {&add-copy} then do:
    for each buf-src_schedule-attr no-lock
      where buf-src_schedule-attr.cre-db-num  = buf-src_schedule.cre-db-num
        and buf-src_schedule-attr.task-type   = buf-src_schedule.task-type
        and buf-src_schedule-attr.task-num    = buf-src_schedule.task-num
    on error undo, return error
    :
      find first buf_schedule-attr exclusive-lock
        where buf_schedule-attr.cre-db-num = buf_schedule.cre-db-num
          and buf_schedule-attr.task-type  = buf_schedule.task-type
          and buf_schedule-attr.task-num   = buf_schedule.task-num
          and buf_schedule-attr.attr-code  = buf-src_schedule-attr.attr-code
        no-error .
      if not available buf_schedule-attr then do:
        create buf_schedule-attr .
      end.
      buffer-copy buf-src_schedule-attr to buf_schedule-attr
        assign
          buf_schedule-attr.cre-db-num = buf_schedule.cre-db-num
          buf_schedule-attr.task-type  = buf_schedule.task-type
          buf_schedule-attr.task-num   = buf_schedule.task-num
        .
    end.      /* for each buf_schedule-attr */
  end.
  if p-task-type = {&btpr-type-autofree} then do:
    run schedule-attr-write in this-procedure
      ( input buf_schedule.cre-db-num
       ,input p-task-type
       ,input buf_schedule.task-num
       ,input ({&attr-schd-free-id} + {&delim-par} + v-free-id)
       ,input v-free-attr-value
      ).

  end.
  assign
    p-recid = recid( buf_schedule )
  .
  for each tt-val
  on error undo, return error return-value
  :
    delete tt-val.
  end.
  
  v-shift-num = 0 .
  v-shift-date = ? .
  for first buf_shift-obj
      where buf_shift-obj.obj-type = v-cntxt-obj-type
        and buf_shift-obj.obj-code = v-cntxt-obj-code
        and buf_shift-obj.status_ = {&sht-current}
      use-index stts :
    assign
      v-shift-date = buf_shift-obj.shift-date
      v-shift-num  = buf_shift-obj.shift-num
    .
  end.
  if v-shift-date = ? then v-shift-date = today .
  
  run trg/userlog.p (
          input 'schedule'
        , input ("Изменение расписания автозаданий на объекте " +
                v-cntxt-obj-type + string(v-cntxt-obj-code) + ";" + 
                buf_schedule.task-type + ";" +
                (if buf_schedule.task-type = {&btpr-type-autofree} then v-free-id else "0") + ";" +
                  string(buf_schedule.task-num) + "|" +
                  (if buf_schedule.active then "1" else "0") + "|" +
                  buf_schedule.task-year + "|" +
                  buf_schedule.task-month + "|" +
                  buf_schedule.task-day + "|" +
                  buf_schedule.task-weekday + "|" +
                  buf_schedule.task-hour + "|" +
                  buf_schedule.task-minute +
                {&delim-key} +
                v-cntxt-obj-type + {&delim-cmd} +
                string(v-cntxt-obj-code) + {&delim-cmd} +
                string(v-shift-date) + {&delim-cmd} +
                string(v-shift-num) + {&delim-cmd} +
                buf_schedule.task-type + {&delim-cmd} +
                (if buf_schedule.task-type = {&btpr-type-autofree} then v-free-id else "0") + {&delim-cmd} + 
                string(buf_schedule.task-num) + {&delim-cmd} +
                (if buf_schedule.active then "1" else "0") + {&delim-cmd} +
                buf_schedule.task-year + {&delim-cmd} +
                buf_schedule.task-month + {&delim-cmd} +
                buf_schedule.task-day + {&delim-cmd} +
                buf_schedule.task-weekday + {&delim-cmd} +
                buf_schedule.task-hour + {&delim-cmd} +
                buf_schedule.task-minute + {&delim-cmd} +
                "chg" + {&delim-cmd} +
                buf_schedule.db-num-char )
        , input ?
        , input ?
        , input ""
        ) no-error.
  if error-status :error
  then do:
      message return-value + error-status:get-message(1) view-as alert-box title "Ошибка записи истории действий пользователя".
  end.

end. /*doe*/

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME