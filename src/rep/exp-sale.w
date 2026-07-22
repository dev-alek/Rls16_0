&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Параметры автоматической выгрузки для Nielsen

Автор: Белоусов Илья Александрович
Дата создания: 04/16/09
Author: Ilia Belousov
Creation date: 04/16/09

*/


/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/
{ rep/exp-sl.i       }

/* ***************************  Definitions  ************************** */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Параметры автоматической выгрузки для Nielsen".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ gbl/getcntxt.i def }
{ ref/shd-attr.i }
/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-curr-host-code like ub.sysconf.host-code no-undo .
define input parameter p-curr-obj-type  like ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code  like ub.clients.obj-code no-undo .
define input PARAMETER p-mode           AS CHARACTER NO-UNDO.
/*вызывается для задания параметров или перед непосредственнно выполнением*/
/*может быть 'shd' или 'run' */
define input parameter p-db-num-char    as character    no-undo.
define input parameter p-task-type      as character    no-undo.
define input parameter p-task-num       as integer      no-undo.

/*при p-mode = 'run'*/
define input parameter p-action         as character    no-undo.
/**/
define output parameter p-cancel        as logical      no-undo.
define output parameter p-params        as character    no-undo.

/* Local Variable Definitions ---                                       */
define variable v-rid-list    as character    no-undo.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-quit b-help RECT-1 RECT-8 EDITOR-1 ~
RADIO-SET-1 BUTTON-1 v-Host-code-List v-place v-name
&Scoped-Define DISPLAYED-OBJECTS EDITOR-1 RADIO-SET-1 v-Host-code-List ~
v-place v-ftp-address v-login v-password v-name

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON BUTTON-1
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 2.6 BY 1 TOOLTIP "Выбор фирм".

DEFINE VARIABLE EDITOR-1 AS CHARACTER INITIAL "Все"
     VIEW-AS EDITOR NO-WORD-WRAP SCROLLBAR-HORIZONTAL SCROLLBAR-VERTICAL
     SIZE 40.6 BY 4 NO-UNDO.

DEFINE VARIABLE v-ftp-address AS CHARACTER FORMAT "X(40)":U
     LABEL "ftp"
     VIEW-AS FILL-IN
     SIZE 47 BY 1 NO-UNDO.

DEFINE VARIABLE v-Host-code-List AS CHARACTER FORMAT "X(256)":U
     LABEL "Коды Фирм"
     VIEW-AS FILL-IN
     SIZE 26.2 BY 1 TOOLTIP "Для режима все по фирме - здесь должен быть указан список кодов фирм." NO-UNDO.

DEFINE VARIABLE v-login AS CHARACTER FORMAT "X(25)":U
     LABEL "Логин"
     VIEW-AS FILL-IN
     SIZE 25 BY 1 NO-UNDO.

DEFINE VARIABLE v-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Префикс"
     VIEW-AS FILL-IN
     SIZE 16.2 BY 1 TOOLTIP "Префикс имени выходного файла." NO-UNDO.

DEFINE VARIABLE v-password AS CHARACTER FORMAT "X(25)":U
     LABEL "Пароль"
     VIEW-AS FILL-IN
     SIZE 25 BY 1 NO-UNDO.

DEFINE VARIABLE RADIO-SET-1 AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Все", 1,
"Все по фирме", 3,
"Выборочно", 4
     SIZE 15 BY 3 NO-UNDO.

DEFINE VARIABLE v-place AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Локальную папку", 1,
"FTP адрес", 2
     SIZE 19.6 BY 2.24 NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 60 BY 5.86.

DEFINE RECTANGLE RECT-8
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 60 BY 6.24.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 2.6
     b-quit AT ROW 1 COL 12.6
     b-help AT ROW 1 COL 49
     EDITOR-1 AT ROW 2.52 COL 21.2 NO-LABEL
     RADIO-SET-1 AT ROW 3.1 COL 4 NO-LABEL
     BUTTON-1 AT ROW 6.71 COL 40
     v-Host-code-List AT ROW 6.76 COL 12 COLON-ALIGNED
     v-place AT ROW 8.71 COL 4.6 NO-LABEL
     v-ftp-address AT ROW 11 COL 11 COLON-ALIGNED
     v-login AT ROW 12.14 COL 11 COLON-ALIGNED
     v-password AT ROW 13.29 COL 11 COLON-ALIGNED BLANK
     v-name AT ROW 14.76 COL 11 COLON-ALIGNED
     " Выбор объектов:" VIEW-AS TEXT
          SIZE 17 BY .67 AT ROW 2.05 COL 3.4
          FGCOLOR 4
     " Выгрузка в:" VIEW-AS TEXT
          SIZE 13.6 BY .67 AT ROW 8.05 COL 5
          FGCOLOR 4
     RECT-1 AT ROW 2.29 COL 2.6
     RECT-8 AT ROW 8.29 COL 2.6
     SPACE(1.39) SKIP(1.59)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "параметры выгрузки для Nielsen"
         DEFAULT-BUTTON b-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
   Other Settings: COMPILE
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       EDITOR-1:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN v-ftp-address IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN v-login IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN v-password IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* параметры выгрузки для Nielsen */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit Dialog-Frame
ON CHOOSE OF b-exit IN FRAME Dialog-Frame /* Ввод */
DO:
  RUN proc-save IN THIS-PROCEDURE .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-help
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-help Dialog-Frame
ON CHOOSE OF b-help IN FRAME Dialog-Frame /* Помощь */
OR HELP OF FRAME {&FRAME-NAME}
DO: /* Call Help Function (or a simple message). */
  MESSAGE "Help for File: {&FILE-NAME}" VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME BUTTON-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-1 Dialog-Frame
ON CHOOSE OF BUTTON-1 IN FRAME Dialog-Frame
DO:
  def var pHost-code-list as character no-undo.
  do with frame {&frame-name}:
    run procedure-user-login-user-host in this-procedure (
          input v-cntxt-db-num
        , input v-cntxt-userid
        , output pHost-code-list
    ) no-error .
    if pHost-code-list > '' then do:
      v-Host-code-List = pHost-code-list.
      display v-Host-code-List.
      apply "LEAVE":U to v-Host-code-List.
    end.
  end. /* do with frame */
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME RADIO-SET-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RADIO-SET-1 Dialog-Frame
ON VALUE-CHANGED OF RADIO-SET-1 IN FRAME Dialog-Frame
DO:

  ASSIGN
      Radio-set-1
  .
  CASE RADIO-SET-1:
  WHEN 4
  THEN DO:
     hide v-Host-code-List button-1 in frame {&frame-name}.
     run ref/cli-all.w ( parParentProc
                   , input "b-sel,b-mark"
                   , {&shop}
                   , ?
                   , ?
                   , ?
                   , ?
                   , ?
                   , output  v-rid-list
                   ) .
     IF  v-rid-list <> "":U
     AND v-rid-list <> ?
     THEN DO:
         EDITOR-1 = "":U.
         define variable v-ii1    as integer      no-undo.
         define variable v-text    as character    no-undo.

         EMPTY TEMP-TABLE tt-obj.
         DO v-ii1 = 1 to num-entries(v-rid-list):
            FIND FIRST ub.clients
                 WHERE RECID( ub.clients ) = integer(entry(v-ii1, v-rid-list))
                 NO-LOCK
                 .
            ASSIGN
               v-text = v-text + {&new-line} + ub.clients.obj-name
            .
            CREATE tt-obj.
            ASSIGN
               tt-obj.obj-code  = ub.clients.obj-code
               tt-obj.obj-type  = ub.clients.obj-type
               tt-obj.obj-name  = ub.clients.obj-name
               tt-obj.host-code = ub.clients.host-code
            .

         END.
         ASSIGN
            v-text = TRIM(v-text, {&new-line})
            EDITOR-1 = v-text
         .
     END.
  END.
/*  WHEN 2 THEN DO:*/
/*      EMPTY TEMP-TABLE tt-obj.*/
/*      FIND FIRST ub.clients*/
/*            WHERE ub.clients.obj-type = v-cntxt-obj-type*/
/*              AND ub.clients.obj-code = v-cntxt-obj-code*/
/*            NO-LOCK*/
/*            .*/
/*      CREATE tt-obj.*/
/*      ASSIGN*/
/*         tt-obj.obj-code  = ub.clients.obj-code*/
/*         tt-obj.obj-type  = ub.clients.obj-type*/
/*         tt-obj.obj-name  = ub.clients.obj-name*/
/*         tt-obj.host-code = ub.clients.host-code*/
/*      .*/
/*      ASSIGN*/
/*         EDITOR-1 = ub.clients.obj-name*/
/*      .*/
/*  END.*/
  WHEN 3 THEN DO:
      view v-Host-code-List button-1 in frame {&frame-name}.
      EDITOR-1 = "":U.
      EMPTY TEMP-TABLE tt-obj.
      FOR EACH ub.clients NO-LOCK
        WHERE ub.clients.obj-type = {&shop}
      :
        if lookup( string( ub.clients.host-code ), v-Host-code-List ) = 0 then
          next.
        CREATE tt-obj.
        ASSIGN
           tt-obj.obj-code  = ub.clients.obj-code
           tt-obj.obj-type  = ub.clients.obj-type
           tt-obj.obj-name  = ub.clients.obj-name
           tt-obj.host-code = ub.clients.host-code
        .
        ASSIGN
           v-text = v-text + {&new-line} + ub.clients.obj-name
        .
      END.
      ASSIGN
         v-text = TRIM(v-text, {&new-line})
         EDITOR-1 = v-text
      .
  END.
  WHEN 1 THEN DO:
      hide v-Host-code-List button-1 in frame {&frame-name}.
      EDITOR-1 = "Все":U.
      EMPTY TEMP-TABLE tt-obj.
      FOR EACH ub.clients
            WHERE ub.clients.obj-type = {&shop}
            NO-LOCK
            :
            CREATE tt-obj.
            ASSIGN
               tt-obj.obj-code  = ub.clients.obj-code
               tt-obj.obj-type  = ub.clients.obj-type
               tt-obj.obj-name  = ub.clients.obj-name
               tt-obj.host-code = ub.clients.host-code
            .
            ASSIGN
               v-text = v-text + {&new-line} + ub.clients.obj-name
            .
      END.
  END.
  OTHERWISE DO:
  END.
  END case.
   DISPLAY
      EDITOR-1
   WITH FRAME Dialog-Frame.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME v-Host-code-List
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-Host-code-List Dialog-Frame
ON LEAVE OF v-Host-code-List IN FRAME Dialog-Frame /* Коды Фирм */
DO:
do with frame {&frame-name}:
  ASSIGN
    v-Host-code-List
  .
  run check-host-list( input-output v-Host-code-List ).
  display v-Host-code-List.
  apply "VALUE-CHANGED" TO RADIO-SET-1.
end. /* do with frame */
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME v-name
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-name Dialog-Frame
ON LEAVE OF v-name IN FRAME Dialog-Frame /* Префикс */
DO:
  ASSIGN
    v-name
  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME v-place
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-place Dialog-Frame
ON VALUE-CHANGED OF v-place IN FRAME Dialog-Frame
DO:
  ASSIGN
   v-place
  .
  CASE v-place:
      WHEN 2
      THEN DO:
        ENABLE
            v-ftp-address
            v-login
            v-password
        WITH FRAME Dialog-Frame.
          DISPLAY
             v-ftp-address
             v-login
             v-password
          WITH FRAME Dialog-Frame.
      END.
      OTHERWISE DO:
          DISABLE
              v-ftp-address
              v-login
              v-password
          WITH FRAME Dialog-Frame.
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


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
   { gbl/getcntxt.i get }
   if p-mode = 'shd':U then do:
      assign
      frame {&frame-name} :title = frame {&frame-name} :title +
                        substitute(". &1: БД &2, Задача номер &3"
                        , p-task-type
                        , p-db-num-char
                        , p-task-num )
      .
  end.
  run init-param-values in this-procedure ( input p-task-type
                                          , input p-db-num-char
                                          , input p-task-num
/*                                          , OUTPUT v-dir-name*/
                                          ) .

/*  RUN init-fields in this-procedure .*/

  RUN enable_UI.
  apply "VALUE-CHANGED" TO RADIO-SET-1.
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
define input  parameter p-obj-list as character no-undo .
define buffer buf_schedule      for schedule.
define buffer buf_schedule-attr for schedule-attr.
define buffer lock-batchprocess for ub.batchprocess.

CASE p-mode:
  when 'shd':U then do:
    /*данная конкретная задача может быть ТОЛЬКО ОДНА в одной БД - отследим*/
      /*заблокируем*/
      run gbl/lock-prc.p
          (input {&lock-prc-schd-free}
          ,input 'exp-sale':U
          ,input 0
          ,input 0
          ,input '':U
          ,input ""
          ,input ""
          ,input (
                  "выгрузки для Nielsen"
                )
          ,input yes
          ,buffer lock-batchprocess
          ) no-error .

      FIND FIRST buf_schedule-attr NO-LOCK WHERE
                 buf_schedule-attr.task-type   = p-task-type
             and buf_schedule-attr.cre-db-num = INTEGER(p-db-num-char)
             and buf_schedule-attr.attr-code = ({&attr-schd-free-id} + {&delim-par} + 'exp-sale') NO-ERROR.
      IF AVAILABLE  buf_schedule-attr
          AND buf_schedule-attr.task-num <> p-task-num
          AND buf_schedule-attr.task-num <> - 1
          and p-task-num <> - 1
          THEN DO:
        MESSAGE
        substitute("Уже есть расписание выгрузки для Nielsenпо ДК для БД &1&2" +
                   "номер расписания &3"
                   ,buf_schedule-attr.cre-db-num
                   ,{&NEW-LINE}
                   ,buf_schedule-attr.task-num)
        VIEW-AS ALERT-BOX ERROR.
        UNDO, RETURN ERROR.
      END.
      find first buf_schedule no-lock
           where buf_schedule.task-type   = p-task-type
             and buf_schedule.cre-db-num  = INTEGER(p-db-num-char)
             and buf_schedule.task-num    = p-task-num
      no-error.
      if not available buf_schedule
      and (  p-task-type   <> {&btpr-type-autofree}
          or p-db-num-char <> p-db-num-char
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
          input INTEGER(p-db-num-char)
        , input p-task-type
        , input p-task-num
        , input {&attr-schedule-param-list-h}
        , input p-param-list
    ).
    run schedule-attr-write in this-procedure (
          input INTEGER(p-db-num-char)
        , input p-task-type
        , input p-task-num
        , input {&attr-schedule-obj-list-h}
        , input p-obj-list
    ).

  end.
  when 'run':U then do:
    p-params = p-param-list.
  end.
END CASE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE check-host-list Dialog-Frame
PROCEDURE check-host-list :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define input-output parameter pHost-code-list as character no-undo.

define variable iCount as integer no-undo.
define variable cTemp as character no-undo.
define variable iTempHostCode as integer no-undo.
define variable cNewHostList as character no-undo.
define variable lOk as logical no-undo.

do iCount = 1 to num-entries( pHost-code-list ):
  cTemp = entry( iCount, pHost-code-list ).
  assign
    iTempHostCode = integer( cTemp ) no-error
  .
  run validate-host( iTempHostCode, no, no, output lOk ).
  if lOk and lookup( string( iTempHostCode ), cNewHostList ) = 0
  then do:
    assign
      cNewHostList = cNewHostList + ',' + string( iTempHostCode )
    .
  end.
end.
pHost-code-list = trim( cNewHostList, ',' ).

return.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE convert Dialog-Frame
PROCEDURE convert :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  define input-output parameter v-rid-list as character no-undo.

  define variable v-list as character no-undo .
  define variable v-ind  as integer   no-undo .

  define buffer buf_sysconf for ub.sysconf.

  do
  on error undo, return error return-value
  :
    do v-ind = 1 to num-entries(v-rid-list)
    :
      find first buf_sysconf no-lock
        where recid(buf_sysconf) = integer(entry(v-ind, v-rid-list))
        no-error .
      if available buf_sysconf
      then do:
        assign
          v-list = v-list
                  + (if v-list = '':U
                    then '':U
                    else {&comma-char}
                    )
                  + string(buf_sysconf.host-code)
        .
      end.
    end.
    assign
      v-rid-list = v-list
    .
  end.
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
  DISPLAY EDITOR-1 RADIO-SET-1 v-Host-code-List v-place v-ftp-address v-login
          v-password v-name
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-quit b-help RECT-1 RECT-8 EDITOR-1 RADIO-SET-1 BUTTON-1
         v-Host-code-List v-place v-name
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
/*
DEFINE VARIABLE v-out AS CHARACTER NO-UNDO.
DEFINE VARIABLE glog AS logical NO-UNDO.
ASSIGN
rs-dir = (if v-dir = 'ini' then v-dir else 'other').
IF rs-dir = "ini":u THEN DO:
    run verify-ini-entry in this-procedure (
                                         INPUT  'lantab-e_out'
                                        ,INPUT  'schedule-free'
                                        ,INPUT substitute("отсутствует параметр &1 секция &2 в ini-файле"
                                                          , 'lantab-e_out'
                                                          , 'schedule-free')
                                        ,INPUT no
                                        ,output v-out) no-error .
    if error-status:error or v-out = ? then return error return-value .
    RUN verify-file in this-procedure
                                      (input v-out
                                      ,input substitute("Не найден каталог &1 параметр &2, секция &3 ini-файла"
                                                    , v-out
                                                    , 'schedule-free'
                                                   , 'lantab-e_out')
                                      ,input no
                                      ,output glog) no-error.
    if error-status:error or not glog then return error return-value .
  v-dir-name = v-out.
END.
ELSE DO:
    RUN verify-file in this-procedure
                                      (input v-dir
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
ASSIGN
rs-file-rule = v-file-rule
file-name-1 = ENTRY(1, v-file-name, {&question-mark})
file-name-2 = (IF NUM-ENTRIES(v-file-name, {&question-mark}) > 1
               AND rs-file-rule = "seq"
               THEN ENTRY(2, v-file-name, {&question-mark})
               ELSE '':U)
e-dc-type /*:SCREEN-VALUE in frame {&frame-name}*/  = v-dc-type-list
.
*/
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
define input parameter p-task-type              as character    no-undo.
define input parameter p-db-num-char            as character    no-undo.
define input parameter p-task-num               as integer      no-undo.
/*define output parameter p-dir                   as character    no-undo.*/

define variable v-param-list    as character     no-undo.
define variable v-param-type    as character     no-undo.
define variable v-obj-list      as character no-undo .
define variable ii as integer   no-undo .
define variable v-entry  as character no-undo .
define variable v-task-num as integer   no-undo .
define variable v-ii1    as integer      no-undo.
define variable v-text    as character    no-undo.
define variable v-ii2    as integer      no-undo.

define buffer buf_tt-obj for tt-obj.
define buffer buf_schedule for ub.schedule.
define buffer buf_schedule-attr for ub.schedule-attr.

DO WITH FRAME Dialog-Frame:
  CASE p-mode:
    when 'shd':U then do:

      if p-task-num > 0
      then do:
        v-task-num = p-task-num.
      end.
      else do:
         for each buf_schedule
            where buf_schedule.task-type     = p-task-type
              AND buf_schedule.cre-db-num    = INTEGER(p-db-num-char)
            no-lock
            ,
            first buf_schedule-attr
            where buf_schedule-attr.task-type   = p-task-type
              AND buf_schedule-attr.cre-db-num  = INTEGER(p-db-num-char)
              AND buf_schedule-attr.task-num    = buf_schedule.task-num
              AND buf_schedule-attr.attr-code   = ({&attr-schd-free-id} + {&delim-par} + 'exp-sale')
            no-lock
            :
            ASSIGN
               v-task-num = buf_schedule.task-num
            .
            leave .
         end.
      end.
      if v-task-num > 0
      then do:
        run schedule-attr-value in this-procedure  ( input p-db-num-char
                                                   , input p-task-type
                                                   , input v-task-num
                                                   , input {&attr-schedule-param-list-h}
                                                   , output v-param-list
                                                   , output v-param-type
                                                   ) .
        run schedule-attr-value in this-procedure  ( input p-db-num-char
                                                   , input p-task-type
                                                   , input v-task-num
                                                   , input {&attr-schedule-obj-list-h}
                                                   , output v-obj-list
                                                   , output v-param-type
                                                   ) .
      end.
      v-ii2 = num-entries( v-param-list, {&delim-par} ).
      if v-ii2 < 6 THEN do:
        do v-ii1 = v-ii2 to 6:
          v-param-list = v-param-list
                       + '':U
                       + {&delim-par}.
        end.
      end.

      ASSIGN
        v-ftp-address    = ENTRY(1, v-param-list, {&delim-par})
        v-login          = ENTRY(2, v-param-list, {&delim-par})
        v-password       = ENTRY(3, v-param-list, {&delim-par})
        v-name           = ENTRY(4, v-param-list, {&delim-par})
        RADIO-SET-1      = INTEGER( ENTRY(5, v-param-list, {&delim-par}) )
        v-Host-code-List = ENTRY(6, v-param-list, {&delim-par})
      .
/*      IF v-name = 0 THEN*/
/*        v-name = v-cntxt-host-code-obj.*/
      DISPLAY
         v-ftp-address
         v-login
         v-password
         v-name
         RADIO-SET-1
         v-Host-code-List
      .

      EMPTY TEMP-TABLE buf_tt-obj.
      IF v-obj-list <> "":U
      and RADIO-SET-1 = 4
      THEN
      do ii = 1 to num-entries(v-obj-list, {&delim-par})
      on error undo, next
      :
         assign
            v-entry = entry(ii, v-obj-list, {&delim-par})
         .
         FIND FIRST ub.clients
              WHERE ub.clients.obj-type = ENTRY(1, v-entry, {&comma-char})
                AND ub.clients.obj-code = INTEGER(ENTRY(2, v-entry, {&comma-char}))
              NO-LOCK
              NO-ERROR
              .
         IF AVAILABLE ub.clients
         THEN DO:
            create tt-obj.
            ASSIGN
               tt-obj.obj-code  = ub.clients.obj-code
               tt-obj.obj-type  = ub.clients.obj-type
               tt-obj.obj-name  = ub.clients.obj-name
               tt-obj.host-code = ub.clients.host-code
               v-text = v-text + {&new-line} + ub.clients.obj-name
            .
         END.
         ASSIGN
            v-text = TRIM(v-text, {&new-line})
            EDITOR-1 = v-text
/*            RADIO-SET-1 = 4 WHEN RADIO-SET-1 = 0*/
         .
      end.
      ELSE DO:
        if RADIO-SET-1 = 1 then do:
         EDITOR-1 = "Все":U.
         FOR EACH ub.clients
               WHERE ub.clients.obj-type = {&shop}
               NO-LOCK
               :
               CREATE tt-obj.
               ASSIGN
                  tt-obj.obj-code  = ub.clients.obj-code
                  tt-obj.obj-type  = ub.clients.obj-type
                  tt-obj.obj-name  = ub.clients.obj-name
                  tt-obj.host-code = ub.clients.host-code
               .
         END.
       end.
       else do:
         apply "VALUE-CHANGED" TO RADIO-SET-1.
       end.
      END.
      DISPLAY
        EDITOR-1
        WITH FRAME Dialog-Frame.
    END.
    WHEN 'run'
    THEN DO:
      v-param-list = '':U
                   + {&delim-par}
                   + '':U
                   + {&delim-par}
                   + '':U
                   + {&delim-par}
                   + '':U
                   + {&delim-par}
                   + '':U
                   + {&delim-par}.
    END.

  END CASE.
  IF v-ftp-address = "":U THEN v-place = 1.
  ELSE DO:
      v-place = 2.
      ENABLE
          v-ftp-address
          v-login
          v-password
      .
      DISPLAY
         v-ftp-address
         v-login
         v-password
      .
  END.
END. /*DO WITH FRAME Dialog-Frame*/
END.
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
define variable v-dop-file-name as character no-undo .
define variable v-obj-list as character no-undo .
define variable ii as integer   no-undo .
define variable v-exists as logical no-undo .
define buffer buf_tt-obj      for tt-obj .

   ASSIGN
   FRAME {&frame-name}
      v-ftp-address
      v-login
      v-password
      v-place
      v-name
      RADIO-SET-1
      v-Host-code-List
   .
   case v-place:
   WHEN 2
   then do:
      IF trim(v-ftp-address) = '':U
      THEN DO:
         message
         "Не задано FTP адрес"
         view-as alert-box error .
         return error.
      END.
   end.
   OTHERWISE do:
      ASSIGN
         v-ftp-address = "":U
      .
   end.
   END CASE.

   if not can-find( first buf_tt-obj ) then do:
      message
      "Не заданы объекты для выгрузки"
      view-as alert-box error .
      return error.
   end.

   /* !!!
   if  then do:
   message
   "Не задано имя фирмы для экспорта"
   view-as alert-box error .
   return error.
   end.
   */

   v-obj-list = ''.

   for each buf_tt-obj :
      assign
      v-obj-list = v-obj-list
                 + buf_tt-obj.obj-type + {&comma-char}
                 + string(buf_tt-obj.obj-code) + {&delim-par}
      .
   end.
   v-ftp-address = trim(trim(replace(v-ftp-address,'ftp:',""),{&slash-char}),{&back-slash-char}).
   ASSIGN

      v-obj-list = TRIM(v-obj-list, {&delim-par}).
      v-param-list = v-ftp-address + {&delim-par} +
                     v-login       + {&delim-par} +
                     v-password    + {&delim-par} +
                     v-name        + {&delim-par} +
                     STRING( RADIO-SET-1 ) + {&delim-par} +
                     v-Host-code-List
   .
   IF p-mode = 'shd' THEN DO:
      run attach-attr-to-schedule-line in this-procedure ( INPUT v-param-list
                                                         , INPUT v-obj-list
                                                         ) .
/*      IF ERROR-STATUS:ERROR*/
/*      THEN DO*/
/*         RETURN NO-APPLY.*/
/*      END.*/
   END.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE procedure-user-login-user-host Dialog-Frame
PROCEDURE procedure-user-login-user-host :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-db-num         as integer          no-undo.
define input parameter p-user-id        as character        no-undo.
define output parameter v-List-select-host-code as character        no-undo.

define variable v-current-host-code    as integer      no-undo.
/*define variable v-user-select      as logical   no-undo .*/

do with frame {&frame-name}:
  v-List-select-host-code = v-Host-code-List.
end. /* do with frame */

do
on error undo, return error
:
    run adm/sconfs.w (
          input parParentProc
        , input "b-sel,b-mark,convert":U
        , input no
        , input 0
        , output v-current-host-code
        , input-output v-List-select-host-code
    ) no-error.
    if error-status :error
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip(1)
            skip "Ошибка выбора фирмы."
            skip return-value
            skip trim(error-status :get-message(1))
                 trim(error-status :get-message(2))
                 trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return no-apply .
    end.
    run convert( input-output v-List-select-host-code ).
/*    run gbl/userhsts.w*/
/*      (input  parparentproc          /* parparentproc      */*/
/*      ,input  this-procedure :handle /* p-callback-handle  */*/
/*      ,input  p-db-num               /* p-db-num           */*/
/*      ,input  p-user-id              /* p-user-id          */*/
/*      ,input  v-cntxt-host-code-obj  /* p-curr-host-code   */*/
/*      ,input  "b-sel,b-mark"         /* b-bttns            */*/
/*      ,output v-user-select          /* p-user-select      */*/
/*      ,output v-current-host-code    /* p-select-host-code */*/
/*      ,OUTPUT v-List-Select-host-code /* v-List-Select-host-code */*/
/*      ) .*/
end.
END PROCEDURE. /* procedure-user-login-user-host */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE userhsts_append Dialog-Frame
PROCEDURE userhsts_append :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define input  parameter p-host-code as integer   no-undo .

end procedure. /* userhsts_append */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE userhsts_clear Dialog-Frame
PROCEDURE userhsts_clear :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

end procedure. /* userhsts_clear */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE validate-host Dialog-Frame
PROCEDURE validate-host :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define input  parameter pHost-code as integer no-undo.
define input  parameter plMessageYN as logical no-undo.
define input  parameter plEmptyIsAvailYN as logical no-undo.
define output parameter plOk as logical no-undo.

if pHost-code = 0 then do:
  if plEmptyIsAvailYN then do:
    plOk = yes.
    return.
  end.
  plOk = no.
  if plMessageYN then do:
    message "Код фирмы не может быть пустым." view-as alert-box.
  end.
end.
else do:
  find first ub.clients no-lock
    where ub.clients.obj-code = pHost-code
      and ub.clients.obj-type = {&cmp}
    no-error.
  if not avail ub.clients then do:
    plOk = no.
    if plMessageYN then do:
      message substitute( "Не верный код фирмы &1.", pHost-code ) view-as alert-box.
    end.
  end.
  else do:
    plOk = yes.
  end.
end.

return.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
