&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME upg-btpr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS upg-btpr
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Проведение upgrade

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/22/02
Author: Dmitry Ukhanov
Creation date: 03/22/02

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Проведение upgrade".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i  }
{ gbl/cur-time.i }

define variable log-exit as logical no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME upg-btpr

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-5 RECT-4 b-quit b-help b-start ~
b-unblock
&Scoped-Define DISPLAYED-OBJECTS bp-date bp-time bp-step

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-start AUTO-GO DEFAULT
     LABEL "&Запуск"
     SIZE 10 BY 1.

DEFINE BUTTON b-unblock DEFAULT
     LABEL "&Разблокировка пользователей"
     SIZE 30 BY 1.

DEFINE VARIABLE bp-date AS DATE FORMAT "99/99/9999":U
     LABEL "Дата"
      VIEW-AS TEXT
     SIZE 11 BY .67 NO-UNDO.

DEFINE VARIABLE bp-step AS INTEGER FORMAT "9":U INITIAL 0
     LABEL "Шаг"
      VIEW-AS TEXT
     SIZE 2 BY .67 NO-UNDO.

DEFINE VARIABLE bp-time AS CHARACTER FORMAT "X(5)":U
     LABEL "Время"
      VIEW-AS TEXT
     SIZE 6 BY .67 NO-UNDO.

DEFINE RECTANGLE RECT-4
     EDGE-PIXELS 3 GRAPHIC-EDGE  NO-FILL
     SIZE 33.13 BY 3.58.

DEFINE RECTANGLE RECT-5
     EDGE-PIXELS 3 GRAPHIC-EDGE  NO-FILL
     SIZE 33.13 BY 1.75.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME upg-btpr
     b-quit AT ROW 1.17 COL 2
     b-help AT ROW 1.17 COL 12
     b-start AT ROW 2.96 COL 4.38
     b-unblock AT ROW 6.54 COL 3.38
     bp-date AT ROW 3 COL 21 COLON-ALIGNED
     bp-time AT ROW 4 COL 21 COLON-ALIGNED
     bp-step AT ROW 5.08 COL 21 COLON-ALIGNED
     RECT-5 AT ROW 6.13 COL 2.25
     RECT-4 AT ROW 2.54 COL 2.25
     SPACE(1.24) SKIP(2.25)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Запуск Upgrade"
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS


/* ***************  Runtime Attributes and UIB Settings  ************** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX upg-btpr
                                                                        */
ASSIGN
       FRAME upg-btpr:SCROLLABLE       = FALSE.

/* SETTINGS FOR FILL-IN bp-date IN FRAME upg-btpr
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN bp-step IN FRAME upg-btpr
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN bp-time IN FRAME upg-btpr
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX upg-btpr
/* Query rebuild information for DIALOG-BOX upg-btpr
     _Options          = "SHARE-LOCK"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX upg-btpr */
&ANALYZE-RESUME






/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME upg-btpr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL upg-btpr upg-btpr
ON WINDOW-CLOSE OF FRAME upg-btpr /* Запуск Upgrade */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-quit upg-btpr
ON CHOOSE OF b-quit IN FRAME upg-btpr /* Выход */
DO:
  assign
    log-exit = true
  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-start
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-start upg-btpr
ON CHOOSE OF b-start IN FRAME upg-btpr /* Запуск */
DO:

  define buffer buf_BatchProcess for ub.BatchProcess .

  define variable v-curr-date as date    no-undo .
  define variable v-curr-time as integer no-undo .
  define variable v-date      as date    no-undo .
  define variable v-time      as integer no-undo .

  run cur-time in this-procedure
    ( output v-curr-date
      ,output v-curr-time
    ) no-error.
  if error-status :error then do:
    message vss-workfile vss-revision vss-description skip
      "Ошибка при определении текущей даты!"
      view-as alert-box error.
    return no-apply.
  end.

  assign
    v-date = v-curr-date
    v-time = v-curr-time
  .

  do while true
  on error undo, return no-apply
  :
    run adm/d-ed-d-t.w ( input-output v-date
                    ,input-output v-time
                  ) no-error .
    if error-status :error then do:
      message vss-workfile vss-revision vss-description skip
        "Ошибка при редактировании даты!"
        view-as alert-box error.
      return no-apply.
    end.
    if v-date = ?
      or v-time = ?
    then do:
      message "Время запуска не изменено!"
        view-as alert-box information.
      return no-apply.
    end.
    if v-date > v-curr-date
      or ( v-date = v-curr-date
            and v-time >= v-curr-time
          )
    then do:
      assign
        v-curr-date = v-date
        v-curr-time = v-time
      .
      leave.
    end.
    else do:
      message vss-workfile vss-revision vss-description skip(1)
        "Время запуска не может быть меньше текущего!"
        view-as alert-box error.
    end.
  end.

  run upg/upg-edbp.p
    ( input "upg":U      /* p-action   as character */
     ,input 1           /* p-step     as integer   */
     ,input 0           /* p-db-num   as integer   */
     ,input "Run":U     /* p-flag     as character */
     ,input "":U        /* p-msg      as character */
     ,input v-curr-date /* p-date     as date      */
     ,input v-curr-time /* p-time     as integer   */
    ) no-error .
  if error-status :error then do:
    message vss-workfile vss-revision vss-description skip(1)
      "Ошибка при записи времени запуска Upgrade!"
      view-as alert-box error.
  end.
  else do:
    message 'Команда на запуск Upgrade отправлена' skip
      "и должна быть обработана в течении минуты." skip
      view-as alert-box information.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-unblock
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-unblock upg-btpr
ON CHOOSE OF b-unblock IN FRAME upg-btpr /* Разблокировка пользователей */
DO:

  define buffer buf_BatchProcess for ub.BatchProcess .

  define variable v-curr-date as date    no-undo .
  define variable v-curr-time as integer no-undo .
  define variable v-log       as logical no-undo .

  message
    "Вы действительно хотите разблокировать пользователей и прекратить Upgrade?"
    view-as alert-box question buttons yes-no update v-log.

  if v-log = false then do:
    return no-apply.
  end.

  run cur-time in this-procedure
    ( output v-curr-date
     ,output v-curr-time
    ) no-error.
  if error-status :error then do:
    message vss-workfile vss-revision vss-description skip
      "Ошибка при определении текущей даты!"
      view-as alert-box error.
    return no-apply.
  end.

  run upg/upg-clbp.p no-error .
  if error-status :error then do:
    message vss-workfile vss-revision vss-description skip
      "Ошибка при удалении записей о времени запуска Upgrade !"
      view-as alert-box error.
    return no-apply.
  end.

  run upg/upg-edbp.p
    ( input "upg":U      /* p-action   as character */
     ,input 0           /* p-step     as integer   */
     ,input 0           /* p-db-num   as integer   */
     ,input "Run":U     /* p-flag     as character */
     ,input "":U        /* p-msg      as character */
     ,input v-curr-date /* p-date     as date      */
     ,input v-curr-time /* p-time     as integer   */
    ) no-error .
  if error-status :error then do:
    message vss-workfile vss-revision vss-description skip(1)
      "Ошибка при записи времени запуска Upgrade!"
      view-as alert-box error.
  end.
  else do:
    message 'Команда отправлена' skip
      "и должна быть обработана в течении минуты." skip
      view-as alert-box information.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK upg-btpr


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
  RUN enable_UI.

  define buffer buf_BatchProcess for BatchProcess .

  define variable v-curr-date as date    no-undo .
  define variable v-curr-time as integer no-undo .

  assign
    log-exit = false
  .

  RUN enable_UI.

  do while not log-exit
  on error undo, return error
  :

    run cur-time in this-procedure
      ( output v-curr-date
       ,output v-curr-time
      ) no-error.
    if error-status :error then do:
      message vss-workfile vss-revision vss-description skip
        "Ошибка при определении текущей даты!"
        view-as alert-box error.
      next.
    end.

    find first buf_BatchProcess no-lock
      where buf_BatchProcess.BP_Type     = {&btpr-type-autoupg}
        and buf_BatchProcess.Key#_One    = 0
        and buf_BatchProcess.CharKey_One = "upg":U
      no-error
    .
    if available buf_BatchProcess then do:
      if buf_BatchProcess.Key#_Three = 1 then do:
        enable b-unblock with frame {&frame-name}.
      end.
      assign
        bp-date = buf_BatchProcess.BP_ExecSysDate
        bp-time = buf_BatchProcess.BP_ExecSysTime
        bp-step = buf_BatchProcess.Key#_Three
      .
      if buf_BatchProcess.BP_ExecSysDate < v-curr-date
        or ( buf_BatchProcess.BP_ExecSysDate = v-curr-date
             and buf_BatchProcess.BP_ExecSysTimeInt < v-curr-time
           )
      then do:
        disable b-start with frame {&frame-name}.
      end.
    end.
    else do:
      assign
        bp-date = ?
        bp-time = ?
        bp-step = ?
      .
    end.

    display
      bp-date
      bp-time
      bp-step
      with frame {&frame-name}
    .

    wait-for
      go of frame {&frame-name}
      or close of this-procedure
      or choose of b-start in frame {&frame-name}
      or choose of b-unblock in frame {&frame-name}
      focus frame {&frame-name}
      pause 1
    .

  end.

END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI upg-btpr _DEFAULT-DISABLE
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
  HIDE FRAME upg-btpr.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI upg-btpr _DEFAULT-ENABLE
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
  DISPLAY bp-date bp-time bp-step
      WITH FRAME upg-btpr.
  ENABLE RECT-5 RECT-4 b-quit b-help b-start b-unblock
      WITH FRAME upg-btpr.
  {&OPEN-BROWSERS-IN-QUERY-upg-btpr}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME