&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Просмотр истории операций с архивами объекта

Автор: Чернова Светлана Александровна
Дата создания: 07/23/08
Author: Svetlana Chernova
Creation date: 07/23/08

Автор1: Перваков Михаил Сергеевич
Дата создания: 01/12/04

*/

/* ***************************  Definitions  ************************** */

define input  parameter p-ah-infov-handle as handle    no-undo .

define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Просмотр истории операций с архивами объекта".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/showinf.i  }
{ gbl/arhisatr.i }

define variable v-hist-time as character no-undo format "x(8)" .

define variable v-available                as logical   no-undo .
define variable v-db-num                   as integer   no-undo .
define variable v-obj-type                 as character no-undo .
define variable v-obj-code                 as integer   no-undo .
define variable v-archive-type             as character no-undo .
define variable v-deleted                  as logical   no-undo .
define variable v-archive-calc             as logical   no-undo .
define variable v-archive-del              as logical   no-undo .
define variable v-archive-disable          as logical   no-undo .
define variable v-archive-rest             as logical   no-undo .
define variable v-archive-bpexist          as logical   no-undo .
define variable v-archive-detail-date      as date      no-undo .
define variable v-archive-start-date       as date      no-undo .
define variable v-archive-date-recalc      as date      no-undo .
define variable v-archive-lock-prc         as logical   no-undo .
define variable v-archive-execuser         as character no-undo .
define variable v-archive-execsysdate      as date      no-undo .
define variable v-archive-execsystime      as character no-undo .
define variable v-archive-rest-lock-prc    as logical   no-undo .
define variable v-archive-rest-execuser    as character no-undo .
define variable v-archive-rest-execsysdate as date      no-undo .
define variable v-archive-rest-execsystime as character no-undo .

define variable v-archive-type-name     as character no-undo .

define variable v-attr-calc    as logical   no-undo .
define variable v-attr-del     as logical   no-undo .
define variable v-attr-disable as logical   no-undo .
define variable v-attr-rest    as logical   no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BROWSE-1

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES archive-history

/* Definitions for BROWSE BROWSE-1                                      */
&Scoped-define FIELDS-IN-QUERY-BROWSE-1 history-description(archive-history.action-type) archive-history.corr-user-db-num archive-history.corr-user-name archive-history.corr-date archive-history.corr-time-str archive-history.archive-detail-date archive-history.archive-start-date archive-history.archive-recalc-date arhisatr_get-calc(archive-history.archive-calc, archive-history.archive-del, archive-history.ps) @ v-attr-calc arhisatr_get-del(archive-history.archive-calc, archive-history.archive-del, archive-history.ps) @ v-attr-del arhisatr_get-disable(archive-history.archive-calc, archive-history.archive-del, archive-history.ps) @ v-attr-disable arhisatr_get-rest(archive-history.archive-calc, archive-history.archive-del, archive-history.ps) @ v-attr-rest archive-history.file-name archive-history.file-valid archive-history.file-md5 archive-history.chip-num archive-history.file-invalid-chip-num
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-1
&Scoped-define SELF-NAME BROWSE-1
&Scoped-define OPEN-QUERY-BROWSE-1 /* OPEN QUERY {&SELF-NAME} FOR EACH archive-history NO-LOCK. */ run open-hist-query in this-procedure .
&Scoped-define TABLES-IN-QUERY-BROWSE-1 archive-history
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-1 archive-history


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BROWSE-1}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-prev b-next b-reason b-check-file ~
b-help toggle-file BROWSE-1 editor-description fi-object fi-archive
&Scoped-Define DISPLAYED-OBJECTS toggle-file editor-description fi-object ~
fi-archive

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD fill-up Dialog-Frame
FUNCTION fill-up RETURNS CHARACTER
  ( input p-message as character, input p-length as integer )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD history-description Dialog-Frame
FUNCTION history-description RETURNS CHARACTER
  ( input p-history-type as character )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-check-file
     LABEL "П&роверить"
     SIZE 10 BY 1.

DEFINE BUTTON b-exit AUTO-GO
     LABEL "Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-next
     LABEL "&>>"
     SIZE 4 BY 1.

DEFINE BUTTON b-prev
     LABEL "&<<"
     SIZE 4 BY 1.

DEFINE BUTTON b-reason
     LABEL "&Причина"
     SIZE 10 BY 1.

DEFINE VARIABLE editor-description AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 97.5 BY 6.88
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fi-archive AS CHARACTER FORMAT "X(256)":U
     LABEL "Архив"
      VIEW-AS TEXT
     SIZE 33.88 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fi-object AS CHARACTER FORMAT "X(256)":U
     LABEL "Объект"
      VIEW-AS TEXT
     SIZE 47.75 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE toggle-file AS LOGICAL INITIAL no
     LABEL "Только с файлами"
     VIEW-AS TOGGLE-BOX
     SIZE 28.5 BY .83
     FGCOLOR 4  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BROWSE-1 FOR
      archive-history SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BROWSE-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-1 Dialog-Frame _FREEFORM
  QUERY BROWSE-1 DISPLAY
      history-description(archive-history.action-type) format "x(18)" column-label "Действие"
      archive-history.corr-user-db-num      column-label "БД"
      archive-history.corr-user-name
      archive-history.corr-date             format '99/99/9999':u column-label "Дата"
      archive-history.corr-time-str         format "x(8)" column-label "Время"
      archive-history.archive-detail-date   column-label "Подробный"
      archive-history.archive-start-date    column-label "Сжатый"
      archive-history.archive-recalc-date   column-label "Перерасчёт"
      arhisatr_get-calc(archive-history.archive-calc, archive-history.archive-del, archive-history.ps)    @ v-attr-calc    format "+/ " column-label "Не рассчитан оборот"
      arhisatr_get-del(archive-history.archive-calc, archive-history.archive-del, archive-history.ps)     @ v-attr-del     format "+/ " column-label "Не рассчитан нач.остаток"
      arhisatr_get-disable(archive-history.archive-calc, archive-history.archive-del, archive-history.ps) @ v-attr-disable format "+/ " column-label "Расчет запрещен"
      arhisatr_get-rest(archive-history.archive-calc, archive-history.archive-del, archive-history.ps)    @ v-attr-rest    format "+/ " column-label "Сбой удал./восст."
      archive-history.file-name             column-label "Файл"
      archive-history.file-valid            format "+/ " column-label "Правильный"
      archive-history.file-md5              column-label "Контрольная сумма"
      archive-history.chip-num              column-label "Номер"
      archive-history.file-invalid-chip-num column-label "Причина"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 12.6 ROW-HEIGHT-CHARS .67.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-prev AT ROW 1 COL 11
     b-next AT ROW 1 COL 15
     b-reason AT ROW 1 COL 19
     b-check-file AT ROW 1 COL 29
     b-help AT ROW 1 COL 39
     toggle-file AT ROW 3 COL 59
     BROWSE-1 AT ROW 4 COL 1.5
     editor-description AT ROW 16.75 COL 2 NO-LABEL
     fi-object AT ROW 2.25 COL 8 COLON-ALIGNED
     fi-archive AT ROW 3.25 COL 8 COLON-ALIGNED
     SPACE(56.00) SKIP(19.71)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "История архива"
         DEFAULT-BUTTON b-exit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
                                                                        */
/* BROWSE-TAB BROWSE-1 toggle-file Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       BROWSE-1:NUM-LOCKED-COLUMNS IN FRAME Dialog-Frame     = 5.

ASSIGN
       editor-description:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-1
/* Query rebuild information for BROWSE BROWSE-1
     _START_FREEFORM
/* OPEN QUERY {&SELF-NAME} FOR EACH archive-history NO-LOCK. */
run open-hist-query in this-procedure .
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE BROWSE-1 */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* История архива */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-check-file
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-check-file Dialog-Frame
ON CHOOSE OF b-check-file IN FRAME Dialog-Frame /* Проверить */
DO:
  run check-file in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-next
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-next Dialog-Frame
ON CHOOSE OF b-next IN FRAME Dialog-Frame /* >> */
DO:
  define variable v-temp-obj-arh-available as logical   no-undo .

  run ah-infov_get-next in p-ah-infov-handle .

  run ah-infov_is-available in p-ah-infov-handle
    (output v-temp-obj-arh-available
    ) .
  if v-temp-obj-arh-available <> true
  then do:
    message
      "Текущая запись является последней записью" skip
      "Невозможно перейти на последующую запись" skip
      view-as alert-box information .

    run ah-infov_get-last in p-ah-infov-handle .
  end.

  run ah-infov_reposition-to-current in p-ah-infov-handle .

  run display-history in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-prev
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-prev Dialog-Frame
ON CHOOSE OF b-prev IN FRAME Dialog-Frame /* << */
DO:
  define variable v-temp-obj-arh-available as logical   no-undo .

  run ah-infov_get-prev in p-ah-infov-handle .

  run ah-infov_is-available in p-ah-infov-handle
    (output v-temp-obj-arh-available
    ) .
  if v-temp-obj-arh-available <> true
  then do:
    message
      "Текущая запись является первой записью" skip
      "Невозможно перейти на предыдущую запись" skip
      view-as alert-box information .

    run ah-infov_get-first in p-ah-infov-handle .
  end.

  run ah-infov_reposition-to-current in p-ah-infov-handle .

  run display-history in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-reason
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-reason Dialog-Frame
ON CHOOSE OF b-reason IN FRAME Dialog-Frame /* Причина */
DO:
  run show-reason in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-1
&Scoped-define SELF-NAME BROWSE-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-1 Dialog-Frame
ON VALUE-CHANGED OF BROWSE-1 IN FRAME Dialog-Frame
DO:
  run display-description in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME toggle-file
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL toggle-file Dialog-Frame
ON VALUE-CHANGED OF toggle-file IN FRAME Dialog-Frame /* Только с файлами */
DO:
  assign
    toggle-file
    .
  run open-hist-query in this-procedure .
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

do with frame {&frame-name}
:
  if valid-handle(p-ah-infov-handle) <> true
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Неизвестное значение указателя процедуры p-ah-infov-handle" skip
      p-ah-infov-handle string(p-ah-infov-handle) skip
      view-as alert-box error .
    undo, return error return-value .
  end.

  run ah-infov_get-current in p-ah-infov-handle
    (output v-available                /* p-available                */
    ,output v-db-num                   /* p-db-num                   */
    ,output v-obj-type                 /* p-obj-type                 */
    ,output v-obj-code                 /* p-obj-code                 */
    ,output v-archive-type             /* p-archive-type             */
    ,output v-deleted                  /* p-obj-deleted              */
    ,output v-archive-calc             /* p-archive-calc             */
    ,output v-archive-del              /* p-archive-del              */
    ,output v-archive-disable          /* p-archive-disable          */
    ,output v-archive-rest             /* p-archive-rest             */
    ,output v-archive-bpexist          /* p-archive-bpexist          */
    ,output v-archive-detail-date      /* p-archive-detail-date      */
    ,output v-archive-start-date       /* p-archive-start-date       */
    ,output v-archive-date-recalc      /* p-archive-recalc-date      */
    ,output v-archive-lock-prc         /* p-archive-lock-prc         */
    ,output v-archive-execuser         /* p-archive-execuser         */
    ,output v-archive-execsysdate      /* p-archive-execsysdate      */
    ,output v-archive-execsystime      /* p-archive-execsystime      */
    ,output v-archive-rest-lock-prc    /* p-archive-rest-lock-prc    */
    ,output v-archive-rest-execuser    /* p-archive-rest-execuser    */
    ,output v-archive-rest-execsysdate /* p-archive-rest-execsysdate */
    ,output v-archive-rest-execsystime /* p-archive-rest-execsystime */
    ) .
  if v-available <> true
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Недоступна исходная запись информации об архиве" skip
      view-as alert-box error .
    undo, return error return-value .
  end.

  run ah-infov_archive-type-name-proc in p-ah-infov-handle
    (input  v-archive-type
    ,output v-archive-type-name
    ) .

  define buffer buf_clients for ub.clients .
  find first buf_clients no-lock
    where buf_clients.obj-type = v-obj-type
      and buf_clients.obj-code = v-obj-code
    no-error .
  if not available buf_clients
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Не найден объект" v-obj-type v-obj-code skip
      view-as alert-box error .
    undo, return error return-value .
  end.

  assign
    fi-object = substitute('&1 &2 &3':u
                          ,v-obj-type
                          ,v-obj-code
                          ,buf_clients.obj-name
                          )
    fi-archive = v-archive-type-name
  .
end. /* do with frame */


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  RUN enable_UI.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE check-file Dialog-Frame
PROCEDURE check-file :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  do
  on error undo, return error return-value
  :

    if available archive-history
    then do:

      if archive-history.file-name = ""
      then do:
        message
          "Проверить файл можно только для записей об удалении архивов" skip
          "для которых была произведена выгрузка в файл" skip
          view-as alert-box information .
        return .
      end.

      if archive-history.file-valid <> true
      then do:
        if archive-history.file-invalid-chip-num <> 0
        then do:
          message
            "Файл помечен как недоступный для загрузки" skip
            "Для получения более подробной информации можно использовать кнопку 'Причина'" skip
            view-as alert-box information .
        end.
        else do:
          message
            "Файл помечен как недоступный для загрузки" skip
            view-as alert-box information .
        end.
        return .
      end.

      if search(archive-history.file-name) = ""
      or search(archive-history.file-name) = ?
      then do:
        message
          "Не найден файл" archive-history.file-name skip
          view-as alert-box error .
        return .
      end.

      define variable v-md5-signature as character no-undo .

      run gbl/md5.p
        (input  archive-history.file-name /* p-file-name     */
        ,output v-md5-signature           /* p-md5-signature */
        ) .
      if v-md5-signature <> archive-history.file-md5
      then do:
        message
          "Складской архив" v-archive-type-name skip
          "Объект" v-obj-type v-obj-code skip
          "Контрольная сумма файла не совпадает с информацией о выгрузке файла" skip
          "Файл" archive-history.file-name skip
          "Контрольная сумма" v-md5-signature skip
          "Информация о выгрузке файла" archive-history.file-md5 skip
          "" skip
          "Архивы не могут быть восстановлены на основании данных файла" skip
          view-as alert-box error .
        return .
      end.
      else do:
        message
          "Складской архив" v-archive-type-name skip
          "Объект" v-obj-type v-obj-code skip
          "Контрольная сумма файла совпадает с информацией о выгрузке файла" skip
          "Файл" archive-history.file-name skip
          "Контрольная сумма" v-md5-signature skip
          "Информация о выгрузке файла" archive-history.file-md5 skip
          "" skip
          "Архивы могут быть восстановлены на основании данных файла" skip
          view-as alert-box information .
        return .
      end.
    end.
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE display-description Dialog-Frame
PROCEDURE display-description :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

  do with frame {&frame-name}
  :
    if available archive-history
    then do:
      assign
        editor-description :screen-value =
            fill-up(substitute("Действие:        &1", history-description(archive-history.action-type))  , 50)  + substitute("Не рассчитан нач.ост.: &1", string(arhisatr_get-del(archive-history.archive-calc, archive-history.archive-del, archive-history.ps),  "да/нет")) + {&new-line}
          + fill-up(substitute("БД:              &1", archive-history.corr-user-db-num)                  , 50)  + substitute("Запрещен расчет:       &1", string(arhisatr_get-disable(archive-history.archive-calc, archive-history.archive-del, archive-history.ps),  "да/нет")) + {&new-line}
          + fill-up(substitute("Пользователь:    &1", archive-history.corr-user-name)                    , 50)  + substitute("Сбой удал./восст.:     &1", string(arhisatr_get-rest(archive-history.archive-calc, archive-history.archive-del, archive-history.ps), "да/нет")) + {&new-line}
          + fill-up(substitute("Дата:            &1", string(archive-history.corr-date, '99/99/9999':u)) , 50)  + substitute("Файл:                  &1", archive-history.file-name) + {&new-line}
          + fill-up(substitute("Время:           &1", archive-history.corr-time-str)                     , 50)  + substitute("Правильный:            &1", string(archive-history.file-valid, "да/нет")) + {&new-line}
          + fill-up(substitute("Подробный:       &1", archive-history.archive-detail-date)               , 50)  + substitute("Контрольная сумма:     &1", archive-history.file-md5) + {&new-line}
          + fill-up(substitute("Сжатый:          &1", archive-history.archive-start-date)                , 50)  + substitute("Номер:                 &1", archive-history.chip-num) + {&new-line}
          + fill-up(substitute("Перерасчёт:      &1", archive-history.archive-recalc-date)               , 50)  + substitute("Причина:               &1", archive-history.file-invalid-chip-num) + {&new-line}
          + fill-up(substitute("Не рассч.оборот: &1", string(arhisatr_get-calc(archive-history.archive-calc, archive-history.archive-del, archive-history.ps), "да/нет")), 50)
      .
    end.
    else do:
      assign
        editor-description :screen-value = ""
      .
    end.
  end. /* do with frame */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE display-history Dialog-Frame
PROCEDURE display-history :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  do with frame {&frame-name}
  :
    run ah-infov_get-current in p-ah-infov-handle
      (output v-available                /* p-available                */
      ,output v-db-num                   /* p-db-num                   */
      ,output v-obj-type                 /* p-obj-type                 */
      ,output v-obj-code                 /* p-obj-code                 */
      ,output v-archive-type             /* p-archive-type             */
      ,output v-deleted                  /* p-obj-deleted              */
      ,output v-archive-calc             /* p-archive-calc             */
      ,output v-archive-del              /* p-archive-del              */
      ,output v-archive-disable          /* p-archive-disable          */
      ,output v-archive-rest             /* p-archive-rest             */
      ,output v-archive-bpexist          /* p-archive-bpexist          */
      ,output v-archive-detail-date      /* p-archive-detail-date      */
      ,output v-archive-start-date       /* p-archive-start-date       */
      ,output v-archive-date-recalc      /* p-archive-recalc-date      */
      ,output v-archive-lock-prc         /* p-archive-lock-prc         */
      ,output v-archive-execuser         /* p-archive-execuser         */
      ,output v-archive-execsysdate      /* p-archive-execsysdate      */
      ,output v-archive-execsystime      /* p-archive-execsystime      */
      ,output v-archive-rest-lock-prc    /* p-archive-rest-lock-prc    */
      ,output v-archive-rest-execuser    /* p-archive-rest-execuser    */
      ,output v-archive-rest-execsysdate /* p-archive-rest-execsysdate */
      ,output v-archive-rest-execsystime /* p-archive-rest-execsystime */
      ) .
    if v-available <> true
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Недоступна исходная запись информации об архиве" skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    run ah-infov_archive-type-name-proc in p-ah-infov-handle
      (input  v-archive-type
      ,output v-archive-type-name
      ) .

    define buffer buf_clients for ub.clients .
    find first buf_clients no-lock
      where buf_clients.obj-type = v-obj-type
        and buf_clients.obj-code = v-obj-code
      no-error .
    if not available buf_clients
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Не найден объект" v-obj-type v-obj-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    assign
      fi-object = substitute('&1 &2 &3':u
                            ,v-obj-type
                            ,v-obj-code
                            ,buf_clients.obj-name
                            )
      fi-archive = v-archive-type-name
    .

    display
      fi-object
      fi-archive
      with frame {&frame-name} .

    run open-hist-query in this-procedure .

  end. /* do with frame */

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
  DISPLAY toggle-file editor-description fi-object fi-archive
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-prev b-next b-reason b-check-file b-help toggle-file BROWSE-1
         editor-description fi-object fi-archive
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE open-hist-query Dialog-Frame
PROCEDURE open-hist-query :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

  do
  on error undo, return error return-value
  :
    open query {&browse-name} FOR EACH archive-history NO-LOCK
      where archive-history.archive-type  = v-archive-type
        and archive-history.obj-type      = v-obj-type
        and archive-history.obj-code      = v-obj-code
        and (toggle-file = false
             or
             (toggle-file = true
              and
              archive-history.file-name <> ''
             )
            )
      use-index ishow
      by archive-history.chip-num descending
      .

    run display-description in this-procedure .
  end.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE show-reason Dialog-Frame
PROCEDURE show-reason :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  do
  on error undo, return error return-value
  :
    define buffer buf_archive-history for ub.archive-history .

    if available archive-history
    then do:
      if archive-history.file-invalid-chip-num = 0
      or archive-history.file-name = ""
      then do:
        message
          "Причину можно показать только для записи истории" skip
          "выгрузки файла" skip
          "с кодом причины, отличным от нуля" skip
          view-as alert-box information .
      end.
      else do:
        find first buf_archive-history no-lock
          where buf_archive-history.chip-num = archive-history.file-invalid-chip-num
          no-error .
        if not available buf_archive-history
        then do:
          message
            "Запись истории с номером"
            archive-history.file-invalid-chip-num
            "не найдена" skip
            view-as alert-box information .
        end.
        else do:
          if archive-history.file-valid = false
          then do:
            define variable v-reason as character no-undo .
            assign
              v-reason  = "Причина того, что файл с архивными данными не может быть загружен" + {&new-line}
                        + {&new-line}
                        + substitute("Действие:              &1", history-description(buf_archive-history.action-type)) + {&new-line}
                        + substitute("БД:                    &1", buf_archive-history.corr-user-db-num) + {&new-line}
                        + substitute("Пользователь:          &1", buf_archive-history.corr-user-name) + {&new-line}
                        + substitute("Дата:                  &1", string(buf_archive-history.corr-date, '99/99/9999':u)) + {&new-line}
                        + substitute("Время:                 &1", buf_archive-history.corr-time-str) + {&new-line}
                        + substitute("Подробный:             &1", buf_archive-history.archive-detail-date) + {&new-line}
                        + substitute("Сжатый:                &1", buf_archive-history.archive-start-date) + {&new-line}
                        + substitute("Перерасчёт:            &1", buf_archive-history.archive-recalc-date) + {&new-line}
                        + substitute("Не рассчитан оборот:   &1", string(arhisatr_get-calc(buf_archive-history.archive-calc, buf_archive-history.archive-del, buf_archive-history.ps)   ,"да/нет")) + {&new-line}
                        + substitute("Не рассчитан нач.ост.: &1", string(arhisatr_get-del(buf_archive-history.archive-calc, buf_archive-history.archive-del, buf_archive-history.ps)    ,"да/нет")) + {&new-line}
                        + substitute("Выключен расчет:      &1", string(arhisatr_get-disable(buf_archive-history.archive-calc, buf_archive-history.archive-del, buf_archive-history.ps),"да/нет")) + {&new-line}
                        + substitute("Сбой удал./восст.:     &1", string(arhisatr_get-rest(buf_archive-history.archive-calc, buf_archive-history.archive-del, buf_archive-history.ps)   ,"да/нет")) + {&new-line}
                        + substitute("Файл:                  &1", buf_archive-history.file-name) + {&new-line}
                        + substitute("Правильный:            &1", string(buf_archive-history.file-valid,"да/нет")) + {&new-line}
                        + substitute("Контрольная сумма:     &1", buf_archive-history.file-md5) + {&new-line}
                        + substitute("Номер:                 &1", buf_archive-history.chip-num) + {&new-line}
            .

            run gbl/d-prompt.w
              (input  'title=\'
                      + 'type=editor\'
                      + 'fillin_width=96\'
                      + 'fillin_height=15\'
                      + 'readonly=yes\'
              , input-output v-reason
              ).
          end.
        end.
      end.
    end.
  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION fill-up Dialog-Frame
FUNCTION fill-up RETURNS CHARACTER
  ( input p-message as character, input p-length as integer ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/

  define variable v-new-message as character no-undo .

  assign
    v-new-message = substitute('&1', p-message)
  .

  if length(v-new-message) < p-length
  then do:
    assign
      v-new-message = v-new-message + fill(' ', p-length - length(v-new-message))
    .
  end.

  return v-new-message .   /* function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION history-description Dialog-Frame
FUNCTION history-description RETURNS CHARACTER
  ( input p-history-type as character ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/

  define variable v-history-description as character no-undo .

  run ah-infov_history-description in p-ah-infov-handle
    (input  p-history-type
    ,output v-history-description
    ) .

  return v-history-description .

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME