&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame

/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE temp-obj NO-UNDO LIKE ub.inkas
       field fact-order as decimal
       field c-inkas-code like ub.c-inkas.inkas-code
       field chip-num like ub.c-inkas.chip-num
       field orig-inkas-code like ub.inkas.inkas-code
       field orig-fact-order as decimal
       field orig-c-inkas-code like ub.c-inkas.inkas-code
       field orig-chip-num like ub.c-inkas.chip-num
       field is-new as logical
       index pi is unique primary
       obj-type obj-code inkas-code
       index idel
       is-del.


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Параметры досылки файлов, недошедших до POS IBM-XML

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/11/05
Author: Bakhtadze Natalya
Creation date: 11/11/05

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-curr-host-code like ub.sysconf.host-code no-undo .
define input parameter p-curr-obj-type  like ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code  like ub.clients.obj-code no-undo .
define input PARAMETER p-mode           AS CHARACTER NO-UNDO.
/*вызывается для задания параметров или перед непосредственнно выполнением*/
/*может быть 'shd' или 'run' */
define input parameter p-cre-db-num     as integer      no-undo .
define input parameter p-task-type      as character    no-undo.
define input parameter p-task-num       as integer      no-undo.

/*при p-mode = 'run'*/
define input parameter p-action         as character    no-undo.
/**/
define output parameter p-cancel        as logical      no-undo.
define output parameter p-params        as character    no-undo.


/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Параметры досылки файлов, недошедших до POS IBM-XML".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/trg-def.i }
{ cmp/library.i }
{ cmp/showinf.i }
{ ref/shd-attr.i }
{ gbl/cur-time.i }
{ cmp/ini-lib.i }
{ gbl/getcntxt.i def }
{ gbl/lowascii.i }

DEFINE VARIABLE v-dir AS CHARACTER NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-Help rs-dir b-dir-sel
&Scoped-Define DISPLAYED-OBJECTS rs-dir v-dir-name f-rs-dir-label

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-dir-sel
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "..."
     SIZE 3.63 BY 1.04.

DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE f-rs-dir-label AS CHARACTER FORMAT "X(256)":U INITIAL "Настройка директории недоставленных до кассы файлов"
      VIEW-AS TEXT
     SIZE 51 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE v-dir-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Директория"
     VIEW-AS FILL-IN
     SIZE 82.5 BY 1
     BGCOLOR 8 FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE rs-dir AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "берется из Ini-файла ([kassa-ibm-xml] out=)\undelivered", "ini",
"привязана к строке расписания", "other"
     SIZE 65 BY 2 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 54.88
     rs-dir AT ROW 4 COL 2 NO-LABEL
     b-dir-sel AT ROW 5 COL 70
     v-dir-name AT ROW 7.25 COL 13 COLON-ALIGNED
     f-rs-dir-label AT ROW 2.75 COL 2.5 COLON-ALIGNED NO-LABEL
     SPACE(42.24) SKIP(5.53)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Параметры досылки файлов, недоставленных до POS IBM-XML"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: temp-obj T "?" NO-UNDO ub inkas
      ADDITIONAL-FIELDS:
          field fact-order as decimal
          field c-inkas-code like ub.c-inkas.inkas-code
          field chip-num like ub.c-inkas.chip-num
          field orig-inkas-code like ub.inkas.inkas-code
          field orig-fact-order as decimal
          field orig-c-inkas-code like ub.c-inkas.inkas-code
          field orig-chip-num like ub.c-inkas.chip-num
          field is-new as logical
          index pi is unique primary
          obj-type obj-code inkas-code
          index idel
          is-del
      END-FIELDS.
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
                                                                        */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN f-rs-dir-label IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN v-dir-name IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Параметры досылки файлов, недоставленных до POS IBM-XML */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-dir-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-dir-sel Dialog-Frame
ON CHOOSE OF b-dir-sel IN FRAME Dialog-Frame /* ... */
DO:
  define variable c-dir-name  as character no-undo.
  define variable c-dir-type  as character no-undo.
  define variable l-can-write as logical   no-undo.

  { gbl/stdbtn.i }
  run gbl/dir-sel.p ( output c-dir-name, output c-dir-type, output l-can-write ).
  if c-dir-name = '':U or c-dir-name = ? or
     c-dir-type = '':U or c-dir-type = ? then do:
    return no-apply.
  end.
  if l-can-write <> yes then do:
    message 'Вы не имеете права писать в выбранную директорию:' c-dir-name view-as alert-box error.
    return no-apply.
  end.
  assign  v-dir-name = c-dir-name.
  display v-dir-name with frame {&FRAME-NAME}.

    .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Ввод */
DO:
  RUN proc-save IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
  APPLY "GO" TO FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-quit Dialog-Frame
ON CHOOSE OF b-quit IN FRAME Dialog-Frame /* Отказ */
DO:
      assign
        p-cancel = yes
    .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rs-dir
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-dir Dialog-Frame
ON VALUE-CHANGED OF rs-dir IN FRAME Dialog-Frame
DO:
  ASSIGN
  rs-dir.
  CASE rs-dir:
      WHEN 'ini' THEN DO:
         HIDE
         b-dir-sel
         IN FRAME {&FRAME-NAME}.
      END.
      OTHERWISE DO:
          DISPLAY
          b-dir-sel
          with FRAME {&FRAME-NAME}.
          ENABLE
          b-dir-sel
          with FRAME {&FRAME-NAME}.
     END.
  END CASE.


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
  if p-mode = 'shd':U then do:
    assign
    frame {&frame-name} :title = frame {&frame-name} :title +
                      substitute(". &1: Задача номер &2"
                      , p-task-type
                      , p-task-num )
    .
  end.
  run init-param-values in this-procedure (
      input p-cre-db-num
    , input p-task-type
    , input p-task-num
    , OUTPUT v-dir-name).

  RUN init-fields in this-procedure .
  RUN Myenable in this-procedure .
  apply "value-changed" to rs-dir.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE attach-attr-to-schedule-line Dialog-Frame
PROCEDURE attach-attr-to-schedule-line :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE INPUT PARAMETER p-param-list AS CHARACTER NO-UNDO.
define buffer buf_schedule      for ub.schedule.
define buffer buf_schedule-attr for ub.schedule-attr.
define buffer lock-batchprocess for ub.batchprocess.

CASE p-mode:
  when 'shd':U then do:
    /*данная конкретная задача может быть ТОЛЬКО ОДНА в одной БД - отследим*/
      /*заблокируем*/
      run gbl/lock-prc.p
          (input {&lock-prc-schd-free}
          ,input 'rsndxibm':U
          ,input 0
          ,input 0
          ,input '':U
          ,input ""
          ,input ""
          ,input (
                  "Досылка файлов, недоставленных до POS IBM-XML"
                )
          ,input yes
          ,buffer lock-batchprocess
          ) no-error .

      FIND FIRST buf_schedule-attr NO-LOCK WHERE
                 buf_schedule-attr.cre-db-num = p-cre-db-num
             and buf_schedule-attr.task-type  = p-task-type
             and buf_schedule-attr.attr-code = ({&attr-schd-free-id} + {&delim-par} + 'rsndxibm') NO-ERROR.
      IF AVAILABLE  buf_schedule-attr
          AND buf_schedule-attr.task-num <> p-task-num
          AND buf_schedule-attr.task-num <> - 1
          and p-task-num <> - 1
          THEN DO:
        MESSAGE
        substitute("Уже есть расписание для досылки файлов, недоставленных до POS IBM-XML. номер расписания &1"
                   ,buf_schedule-attr.task-num)
        VIEW-AS ALERT-BOX ERROR.
        UNDO, RETURN ERROR.
      END.
      find first buf_schedule no-lock
           where buf_schedule.cre-db-num = p-cre-db-num
             and buf_schedule.task-type  = p-task-type
             and buf_schedule.task-num   = p-task-num
      no-error.
      if not available buf_schedule
      and (  p-task-type   <> {&btpr-type-autofree}
          or p-task-num    <> -1 )
      then do:
          message
            vss-workfile vss-revision vss-description
            skip "Не найдена строка расписания."
            skip return-value
            skip trim(error-status :get-message(1))
                 trim(error-status :get-message(2))
                 trim(error-status :get-message(3))
          view-as alert-box error.
          undo, return error .
      end.

    run schedule-attr-write in this-procedure (
          input p-cre-db-num
        , input p-task-type
        , input p-task-num
        , input {&attr-schedule-param-list-h}
        , input p-param-list
    ).
  end.
  when 'run':U then do:
    p-params = p-param-list.
  end.
END CASE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

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
  DISPLAY rs-dir v-dir-name f-rs-dir-label
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Help rs-dir b-dir-sel
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-fields Dialog-Frame
PROCEDURE init-fields :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE VARIABLE v-out AS CHARACTER NO-UNDO.
DEFINE VARIABLE glog AS logical NO-UNDO.
ASSIGN
rs-dir = (if v-dir = 'ini' then v-dir else 'other').
IF rs-dir = "ini":u THEN DO:
    run verify-ini-entry in this-procedure (
                                         INPUT  'out'
                                        ,INPUT  'kassa-ibm-xml'
                                        ,INPUT substitute("отсутствует параметр &1 секция &2 в ini-файле"
                                                          , 'out'
                                                          , 'kassa-ibm-xml')
                                        ,INPUT no
                                        ,output v-out) no-error .
    if error-status:error or v-out = ? then return error return-value .
    RUN verify-file in this-procedure (
                                       input v-out
                                      ,input substitute("Не найден каталог &1 параметр &2, секция &3 ini-файла"
                                                    , v-out
                                                    , 'kassa-ibm-xml'
                                                   , 'out')
                                      ,input no
                                      ,output glog) no-error.
    if error-status:error or not glog then return error return-value .
  v-dir-name = v-out + "undelivered":U.
END.
ELSE DO:
    RUN verify-file in this-procedure (
                                       input v-dir
                                      ,input substitute("Не найден каталог &1"
                                                    , v-dir
                                                    )
                                      ,input no
                                      ,output glog) no-error.
    if error-status:error or not glog then do:
      v-dir-name = "".
    end.
    else do:
      v-dir-name = v-dir.
   end.
END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-param-values Dialog-Frame
PROCEDURE init-param-values :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-cre-db-num             as integer      no-undo .
define input parameter p-task-type              as character    no-undo.
define input parameter p-task-num               as integer      no-undo.
define output parameter p-dir                   as character    no-undo.
define variable v-param-list    as character     no-undo.
define variable v-param-type    as character     no-undo.
define variable ii as integer   no-undo .
define variable v-entry  as character no-undo .
define variable v-task-num as integer   no-undo .

define buffer buf_schedule for ub.schedule.
define buffer buf_schedule-attr for ub.schedule-attr.

  CASE p-mode:
    when 'shd':U then do:
      if p-task-num > 0 then do:
        v-task-num = p-task-num.
      end.
      else do:
        for each buf_schedule no-lock where
                buf_schedule.cre-db-num = p-cre-db-num
            AND buf_schedule.task-type = p-task-type,
            first buf_schedule-attr no-lock where
                  buf_schedule-attr.cre-db-num = p-cre-db-num
              AND buf_schedule-attr.task-type = p-task-type
              AND buf_schedule-attr.task-num = buf_schedule.task-num
              AND buf_schedule-attr.attr-code = ({&attr-schd-free-id} + {&delim-par} + 'rsndxibm') :
           v-task-num = buf_schedule.task-num.
           leave .
        end.
      end.
      if v-task-num > 0 then do:
        run schedule-attr-value in this-procedure (
              input p-cre-db-num
            , input p-task-type
            , input v-task-num
            , input {&attr-schedule-param-list-h}
            , output v-param-list
            , output v-param-type
        ) NO-ERROR.
      end.
      if v-param-list = '':U then
      v-param-list = 'ini' .
    END.
    WHEN 'run' THEN DO:
      assign
      v-param-list = 'ini'.
    END.
  END CASE.
  ASSIGN
  v-dir = entry(1, v-param-list, {&delim-par})
  .

END. /*doe*/
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
CASE p-mode:
    WHEN 'run':U THEN DO:
        ASSIGN
        rs-dir:RADIO-BUTTONS IN FRAME {&FRAME-NAME}
                             = "берется из Ini-файла ([kassa-IBM-XML] out=)\undelivered" + {&comma-char} +
                               "ini":U + {&comma-char} +
                               "задать директорию недоставленных файлов" + {&comma-char} +
                               "other".
    END.
    WHEN 'shd':U THEN DO:
        ASSIGN
        rs-dir:RADIO-BUTTONS = "берется из Ini-файла ([kassa-IBM-XML] out=)\undelivered" + {&comma-char} +
                               "ini":U + {&comma-char} +
                               "задать директорию недоставленных файлов" + {&comma-char} +
                               "other".

    END.
END CASE.

DISPLAY
rs-dir
f-rs-dir-label
v-dir-name
WITH FRAME {&frame-name}.
ENABLE
B-exit
b-quit
B-Help
rs-dir
b-dir-sel WHEN rs-dir <> 'Ini':U
WITH FRAME {&frame-name}.
VIEW FRAME {&frame-name}.
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
DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
DEFINE VARIABLE v-param-list AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-file-name AS CHARACTER NO-UNDO.
define variable ii as integer   no-undo .
define variable v-exists as logical no-undo .
ASSIGN
FRAME {&frame-name}
rs-dir
.

IF rs-dir <> 'ini' THEN DO:
    ASSIGN
    v-dir-name.
    RUN verify-file in this-procedure
                                      ( input v-dir-name
                                      , input substitute("Не найден каталог &1"
                                                    , v-dir-name)
                                      ,input no
                                      ,output glog) no-error.
   if error-status:error or not glog then do:
       v-dir-name = '':U.
    end.
    run low-ascii in this-procedure ( input v-dir-name, input no ) no-error .
    if error-status:error then do:
      v-dir-name = '':U.
      undo, return error.
    end.
    else
    v-dir = v-dir-name.
END.
ASSIGN
v-param-list = (IF rs-dir = 'ini' THEN 'ini' ELSE v-dir-name).
IF p-mode = 'shd' THEN DO:
    run attach-attr-to-schedule-line in this-procedure (
          INPUT v-param-list
          ) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME