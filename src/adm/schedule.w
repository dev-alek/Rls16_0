&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
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

Расписание автоматических заданий

Автор: Уханов Дмитрий Юрьевич
Дата создания: 09/08/03
Author: Dmitry Ukhanov
Creation date: 09/08/03

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Расписание автоматических заданий".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
{ adm/schedule.i }
{ cmp/showinf.i }
{ cmp/library.i  }
{ ref/shd-attr.i }



define buffer buf_schedule for ub.schedule .
define buffer buf_sys-ctrl for ub.sys-ctrl .

define variable v-btpr-type   as character no-undo .
define variable v-par-val     as character no-undo .
define variable v-par-type    as character no-undo .
define variable v-log         as logical   no-undo .
define variable v-modify-task as character no-undo .
define variable v-modify-btpr as character no-undo .
define variable v-PS          as character no-undo .
define variable v-curr-db     as integer   no-undo .

&scop bef-autonws Обмен новостями
&scop autonws '{&bef-autonws}':U
&scop bef-autoarh Расчет архивов
&scop autoarh '{&bef-autoarh}':U
&scop bef-autoexp Экспорт
&scop autoexp '{&bef-autoexp}':U
&scop bef-autooxml OpenXML
&scop autooxml '{&bef-autooxml}':U
&scop bef-autocdi Импорт через кассы
&scop autocdi '{&bef-autocdi}':U
&scop bef-autogcd Прием информации с касс
&scop autogcd '{&bef-autogcd}':U
&scop bef-autosuz Запуск отчетов
&scop autosuz '{&bef-autosuz}':U
&scop bef-autosale Работа с документами продажи
&scop autosale '{&bef-autosale}':U
&scop bef-autocbnk Эксп/имп в КЛИЕНТ-БАНК
&scop autocbnk '{&bef-autocbnk}':U
&scop bef-autofree Произвольные задани~377
&scop autofree '{&bef-autofree}':U
&scop bef-mercury Меркурий
&scop mercury '{&bef-mercury}':U
&scop bef-hddtest Мониторинг HDD
&scop hddtest '{&bef-hddtest}':U
&scop bef-is_motp ИС МОТП
&scop is_motp '{&bef-is_motp}':U
&scop bef-is_diadoc ИС Диадок
&scop is_diadoc '{&bef-is_diadoc}':U
&scop bef-sktsrv Сокет-Сервер
&scop sktsrv '{&bef-sktsrv}':U
&scop bef-is_PM Президентский мониторинг
&scop is_PM '{&bef-is_PM}':U

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-schedule

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES buf_schedule

/* Definitions for BROWSE br-schedule                                   */
&Scoped-define FIELDS-IN-QUERY-br-schedule buf_schedule.active buf_schedule.db-num-char buf_schedule.task-year buf_schedule.task-month buf_schedule.task-day buf_schedule.task-weekday buf_schedule.task-hour buf_schedule.task-minute buf_schedule.task-num get-free-task-name(buf_schedule.cre-db-num, buf_schedule.task-type, buf_schedule.task-num) @ v-ps
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-schedule
&Scoped-define SELF-NAME br-schedule
&Scoped-define QUERY-STRING-br-schedule FOR EACH buf_schedule no-lock where buf_schedule.cre-db-num = v-cre-db-num AND buf_schedule.task-type = v-btpr-type
&Scoped-define OPEN-QUERY-br-schedule OPEN QUERY {&SELF-NAME} FOR EACH buf_schedule no-lock where buf_schedule.cre-db-num = v-cre-db-num AND buf_schedule.task-type = v-btpr-type .
&Scoped-define TABLES-IN-QUERY-br-schedule buf_schedule
&Scoped-define FIRST-TABLE-IN-QUERY-br-schedule buf_schedule


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-schedule}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit b-add b-chg b-copy b-del b-help ~
v-cre-db-num v-task-type br-schedule
&Scoped-Define DISPLAYED-OBJECTS v-cre-db-num v-task-type

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-free-task-name Dialog-Frame
FUNCTION get-free-task-name RETURNS CHARACTER
  ( input p-cre-db-num as integer, INPUT p-task-type AS character, INPUT p-task-num AS integer )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-add DEFAULT
     LABEL "&Добавить"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-chg DEFAULT
     LABEL "&Изменить"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-copy DEFAULT
     LABEL "Копи&я"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-del DEFAULT
     LABEL "&Удалить"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-END-KEY DEFAULT
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON bt-param
     LABEL "&Параметры"
     SIZE 10 BY 1.

DEFINE VARIABLE v-cre-db-num AS INTEGER FORMAT "->>>>9":U INITIAL 0
     LABEL "Расписание для БД"
     VIEW-AS COMBO-BOX INNER-LINES 10
     LIST-ITEMS "0"
     DROP-DOWN-LIST
     SIZE 9.5 BY 1 NO-UNDO.

DEFINE VARIABLE v-task-type AS CHARACTER FORMAT "X(256)":U
     VIEW-AS COMBO-BOX INNER-LINES 12
     DROP-DOWN-LIST
     SIZE 40.3 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-schedule FOR
      buf_schedule SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-schedule
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-schedule Dialog-Frame _FREEFORM
  QUERY br-schedule DISPLAY
      buf_schedule.active format "+/-"
buf_schedule.db-num-char format "x(255)"
buf_schedule.task-year
buf_schedule.task-month format "x(2)"
buf_schedule.task-day column-label "Число"
buf_schedule.task-weekday column-label "Дни недели" format "x(13)"
buf_schedule.task-hour column-label "Часы" format "x(72)"
buf_schedule.task-minute column-label "Минуты" format "x(183)"
buf_schedule.task-num column-label "N задачи" format ">>>>>>>>>9"
get-free-task-name(buf_schedule.cre-db-num, buf_schedule.task-type, buf_schedule.task-num) @ v-ps column-label "Примечание" format "x(40)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 11.43.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     b-add AT ROW 1 COL 11
     b-chg AT ROW 1 COL 21
     b-copy AT ROW 1 COL 31
     b-del AT ROW 1 COL 41
     bt-param AT ROW 1 COL 51
     b-help AT ROW 1 COL 71
     v-cre-db-num AT ROW 2.5 COL 2.5
     v-task-type AT ROW 2.5 COL 32.5 NO-LABEL
     br-schedule AT ROW 3.8 COL 1
     SPACE(0.00) SKIP(0.26)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Расписание"
         CANCEL-BUTTON b-quit.


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
   FRAME-NAME                                                           */
/* BROWSE-TAB br-schedule v-task-type Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR BUTTON bt-param IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR COMBO-BOX v-cre-db-num IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR COMBO-BOX v-task-type IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-schedule
/* Query rebuild information for BROWSE br-schedule
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH buf_schedule no-lock where buf_schedule.cre-db-num = v-cre-db-num AND buf_schedule.task-type = v-btpr-type .
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE br-schedule */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Расписание */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add Dialog-Frame
ON CHOOSE OF b-add IN FRAME Dialog-Frame /* Добавить */
DO:

  define variable v-recid as recid   no-undo.
  define variable v-mod   as logical no-undo .
  define buffer buf-check_db for ub.db .

  find first buf-check_db share-lock
    where buf-check_db.db-num = v-cre-db-num
    .

  if v-cre-db-num = v-curr-db
    or ( v-cre-db-num <> v-curr-db
         and v-curr-db = 0
         and ( buf-check_db.db-key = "":U
               or buf-check_db.db-key = ?
             )
       )
  then do:
    assign
      v-recid = ?
    .
    run adm/sch-edit.w
      ( input parparentproc
      ,input {&add-def}
      ,input v-cre-db-num
      ,input v-btpr-type
      ,input-output v-recid
      ,output v-mod
      ) no-error.
    if error-status :error then do:
      message vss-workfile vss-revision vss-description skip
        "Не удалось создать строку расписания!"
        view-as alert-box error.
      return no-apply.
    end.

    if v-mod = true then do:
      if v-curr-db = v-cre-db-num then do:
        run add-modify-task in this-procedure.
      end.
      {&OPEN-QUERY-br-schedule}
      reposition br-schedule to recid v-recid no-error.
    end.
    
    if v-btpr-type = {&btpr-type-is_PM}
    then do :
      apply "choose" to bt-param IN FRAME Dialog-Frame .
    end .
  end.
  else do:
    message
      substitute( "Новую строку расписания можно создавать только для текущей БД" ) skip
      substitute( "или в ГБД для невыгруженной БД (т.е. БД у которой нет ключа)") skip
      view-as alert-box error .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-chg Dialog-Frame
ON CHOOSE OF b-chg IN FRAME Dialog-Frame /* Изменить */
DO:

  define variable v-recid as recid   no-undo.
  define variable v-mod   as logical no-undo .

  if not available buf_schedule then do:
    message vss-workfile vss-revision vss-description skip
      "Не выбрана строка расписания!"
      view-as alert-box error.
    return no-apply.
  end.

  assign
    v-recid = recid( buf_schedule )
  .
  run adm/sch-edit.w
    ( input parparentproc
     ,input {&update}
     ,input v-cre-db-num
     ,input v-btpr-type
     ,input-output v-recid
     ,output v-mod
    ) no-error.
  if error-status :error then do:
    message vss-workfile vss-revision vss-description skip
      "Не удалось изменить строку расписания!"
      view-as alert-box error.
    return no-apply.
  end.
  if v-mod = true then do:
    if v-curr-db = v-cre-db-num then do:
      run add-modify-task in this-procedure.
    end.
    {&OPEN-QUERY-br-schedule}
    reposition br-schedule to recid v-recid no-error.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-copy
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-copy Dialog-Frame
ON CHOOSE OF b-copy IN FRAME Dialog-Frame /* Копия */
DO:

  define variable v-recid as recid   no-undo.
  define variable v-mod   as logical no-undo .

  if not available buf_schedule then do:
    message vss-workfile vss-revision vss-description skip
      "Не выбрана строка расписания!"
      view-as alert-box error.
    return no-apply.
  end.

  assign
    v-recid = recid( buf_schedule )
  .
  run adm/sch-edit.w
    ( input parparentproc
     ,input {&add-copy}
     ,input v-cre-db-num
     ,input v-btpr-type
     ,input-output v-recid
     ,output v-mod
    ) no-error.
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      substitute("Не удалось скопировать строку расписания!") skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return no-apply.
  end.

  if v-mod = true then do:
    if v-curr-db = v-cre-db-num then do:
      run add-modify-task in this-procedure.
    end.
    {&OPEN-QUERY-br-schedule}
    reposition br-schedule to recid v-recid no-error.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del Dialog-Frame
ON CHOOSE OF b-del IN FRAME Dialog-Frame /* Удалить */
DO:

  define variable v-log as logical no-undo .

  if not available buf_schedule then do:
    message vss-workfile vss-revision vss-description skip
      "Не выбрана строка расписания!"
      view-as alert-box error.
    return no-apply.
  end.

  assign
    v-log = false
  .

  message "Вы действительно хотите удалить строку расписания?"
    view-as alert-box question buttons yes-no update v-log.

  if v-log = false
  then do:
    return no-apply.
  end.
  else do:
    run adm/schedul3.p (  input parparentproc
                         ,input recid( buf_schedule )
                         ,input no /*p-silent*/
                        ) no-error.
    if error-status:error then do:
      undo, return no-apply.
    end.
    if v-curr-db = v-cre-db-num then do:
      run add-modify-task in this-procedure.
    end.

    {&OPEN-QUERY-br-schedule}
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-quit Dialog-Frame
ON CHOOSE OF b-quit IN FRAME Dialog-Frame /* Выход */
DO:
  define variable v-ind           as integer   no-undo .
  define variable v-num-entries   as integer   no-undo .
  define variable v-loc-btpr-type as character no-undo .
  define variable v-loc-btpr-task as character no-undo .
  define variable v-not-change    as character no-undo .

  if v-modify-btpr <> "":U then do:
    message
      "Были произведены изменения расписания для задач:" skip
      v-modify-task skip
      "Вы хотите переформировать время выполнения этих задач в соответствии с новым расписанием?"
      view-as alert-box question buttons yes-no update v-log.

    assign
      v-not-change = "":U
    .
    if v-log = true then do:
      assign
        v-num-entries = num-entries( v-modify-btpr )
      .
      do v-ind = 1 to v-num-entries:
        assign
          v-loc-btpr-type = entry( v-ind, v-modify-btpr )
          v-loc-btpr-task = entry( v-ind, v-modify-task )
        .

        run delete-btpr in this-procedure
          ( input        v-loc-btpr-type
           ,input        v-loc-btpr-task
           ,input-output v-not-change
          ) no-error.
        if error-status :error then do:
          message
            "Ошибка при удалении времени очередного сеанса." skip
            return-value skip
            error-status :get-message(1)
            view-as alert-box error .
          return no-apply.
        end.
      end.
      if v-not-change = "":U then do:
        message
          "Время очередного(ых) сеанса(ов) будет обновлено в течении минуты," skip
          "если соответствующие сеансы активны."
          view-as alert-box information.
      end.
      else do:
        message
          substitute( "Время сеансов &1 не изменено т.к. оно задано вручную", v-not-change ) skip
          "Время остальных очередных сеансов будет обновлено в течении минуты," skip
          "если соответствующие сеансы активны."
          view-as alert-box information.
      end.
    end.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-param
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-param Dialog-Frame
ON CHOOSE OF bt-param IN FRAME Dialog-Frame /* Параметры */
DO:
  define variable v-cancel as logical no-undo.
  define variable v-free-id as character no-undo .
  if not available buf_schedule then return no-apply.
  define buffer buf_schedule-attr for ub.schedule-attr.
  case v-task-type:

    when {&btpr-type-autonws} then do:

    end.
    when {&btpr-type-mercury} then do:

    end.
    when {&btpr-type-hddtest} then do:

    end.
    when {&btpr-type-is_motp} then do:

    end.
    when {&btpr-type-is_diadoc} then do:

    end.
    when {&btpr-type-is_PM} then do:
      run adm/isPM-shdp.w
        (input  buf_schedule.cre-db-num
        ,input  buf_schedule.task-type
        ,input  buf_schedule.task-num
        ,output v-cancel
        ) no-error.
      if error-status :error
      then do:
          message
            vss-workfile vss-revision vss-description
            skip "Ошибка изменения параметров для строки расписания."
            skip return-value
            skip trim(error-status :get-message(1))
                trim(error-status :get-message(2))
                trim(error-status :get-message(3))
          view-as alert-box error.
          undo, return no-apply.
      end.
    end.
    when {&btpr-type-autoarh} then do:
      run adm/arc-shdp.w
        (input  buf_schedule.cre-db-num
        ,input  buf_schedule.task-type
        ,input  buf_schedule.task-num
        ,output v-cancel
        ) no-error.
      if error-status :error
      then do:
          message
            vss-workfile vss-revision vss-description
            skip "Ошибка изменения параметров для строки расписания."
            skip return-value
            skip trim(error-status :get-message(1))
                trim(error-status :get-message(2))
                trim(error-status :get-message(3))
          view-as alert-box error.
          undo, return no-apply.
      end.
    end.
    when {&btpr-type-autoexp} then do:
      run bge/bge-shdp.w (
            input parparentproc
          , input buf_schedule.cre-db-num
          , input buf_schedule.task-type
          , input buf_schedule.task-num
          , output v-cancel
      ) no-error.
      if error-status :error
      then do:
          message
            vss-workfile vss-revision vss-description
            skip "Ошибка изменения параметров для строки расписания."
            skip return-value
            skip trim(error-status :get-message(1))
                trim(error-status :get-message(2))
                trim(error-status :get-message(3))
          view-as alert-box error.
          undo, return no-apply.
      end.
    end.
/*    when {&btpr-type-autooxml} then do:*/
/*      run bge/oxmlshdp.w (*/
/*            input parparentproc*/
/*          , input buf_schedule.cre-db-num*/
/*          , input buf_schedule.task-type*/
/*          , input buf_schedule.task-num*/
/*          , output v-cancel*/
/*      ) no-error.*/
/*      if error-status :error*/
/*      then do:*/
/*          message*/
/*            vss-workfile vss-revision vss-description*/
/*            skip "Ошибка изменения параметров для строки расписания."*/
/*            skip return-value*/
/*            skip trim(error-status :get-message(1))*/
/*                trim(error-status :get-message(2))*/
/*                trim(error-status :get-message(3))*/
/*          view-as alert-box error.*/
/*          undo, return no-apply.*/
/*      end.*/
/*    end.*/
    when {&btpr-type-autogetcd} then do:
      run str/gcd-shdp.w (
            input parparentproc
          , input buf_schedule.cre-db-num
          , input buf_schedule.task-type
          , input buf_schedule.task-num
          , output v-cancel
      ) no-error.
      if error-status :error
      then do:
          message
            vss-workfile vss-revision vss-description
            skip "Ошибка изменения параметров для строки расписания."
            skip return-value
            skip trim(error-status :get-message(1))
                trim(error-status :get-message(2))
                trim(error-status :get-message(3))
          view-as alert-box error.
          undo, return no-apply.
      end.
    end.
    when {&btpr-type-autosale} then do:
      run str/sal-shdp.w (
            input parparentproc
          , input buf_schedule.cre-db-num
          , input buf_schedule.task-type
          , input buf_schedule.task-num
          , output v-cancel
      ) no-error.
      if error-status :error
      then do:
          message
            vss-workfile vss-revision vss-description
            skip "Ошибка изменения параметров для строки расписания."
            skip return-value
            skip trim(error-status :get-message(1))
                trim(error-status :get-message(2))
                trim(error-status :get-message(3))
          view-as alert-box error.
          undo, return no-apply.
      end.
    end.
    when {&btpr-type-autosuz} then do:
      if buf_schedule.cre-db-num <>  g#db-num
      and g#db-num <> 0 then do:
        message
        "Невозможно менять/просматривать параметры расписания в чужой УБД"
        view-as alert-box .
        undo, return no-apply.
      end.
      run str/suz-shdp.w (
            input parparentproc
          , input buf_schedule.cre-db-num
          , input buf_schedule.task-type
          , input buf_schedule.task-num
          , output v-cancel
      ) no-error.
      if error-status :error
      then do:
          message
            vss-workfile vss-revision vss-description
            skip "Ошибка изменения параметров для строки расписания."
            skip return-value
            skip trim(error-status :get-message(1))
                trim(error-status :get-message(2))
                trim(error-status :get-message(3))
          view-as alert-box error.
          undo, return no-apply.
      end.
    end.
    when {&btpr-type-autocbnk} then do:
      define variable v-params        as character    no-undo.
      define variable v-object-list        as character    no-undo.
      define variable v-doc-type-list      as character    no-undo.
      define variable v-hsch-list          as character    no-undo.
      define variable v-csch-list          as character    no-undo.
      define variable v-date-list          as character    no-undo.

      run bge/clb-shdp.w (
            input parparentproc
          , input 0
          , input 'shd':U
          , input buf_schedule.cre-db-num
          , input buf_schedule.task-type
          , input buf_schedule.task-num
          , input ? /*p-action*/
          , output v-cancel
          , output v-params
          , output v-object-list
          , output v-doc-type-list
          , output v-date-list
          , output v-hsch-list
          , output v-csch-list
      ) no-error.
      if error-status :error
      then do:
          message
            vss-workfile vss-revision vss-description
            skip "Ошибка изменения параметров для строки расписания."
            skip return-value
            skip trim(error-status :get-message(1))
                trim(error-status :get-message(2))
                trim(error-status :get-message(3))
          view-as alert-box error.
          undo, return no-apply.
      end.
    end.
    when {&btpr-type-autofree} then do:
      run schedule-attr-get-free-id  in this-procedure (
                                                         input buf_schedule.cre-db-num
                                                        ,input buf_schedule.task-type
                                                        ,input buf_schedule.task-num
                                                        ,output v-free-id) no-error .
      if error-status:error then do:
        message
        "Невозможно получить название  произвольного задания по строке расписания"
        view-as alert-box error .
        undo, return no-apply.
      end.
      run adm/freeshdp.w (
            input parparentproc
          , input 0 /*p-curr-host-code*/
          , input '':U /*p-curr-obj-type*/
          , input 0 /*p-curr-obj-code*/
          , input 'shd':U
          , input buf_schedule.cre-db-num
          , input buf_schedule.task-type
          , input buf_schedule.task-num
          , input ? /*p-action*/
          , input-output v-free-id
          , output v-cancel
          , output v-params
      ) no-error.
      if error-status :error
      then do:
          message
            vss-workfile vss-revision vss-description
            skip "Ошибка изменения параметров для строки расписания."
            skip return-value
            skip trim(error-status :get-message(1))
                trim(error-status :get-message(2))
                trim(error-status :get-message(3))
          view-as alert-box error.
          undo, return no-apply.
      end.
    end.
    otherwise do:
      message vss-workfile vss-revision vss-description skip
        "НЕТ ОБРАБОТКИ АТРИБУТА" v-task-type
        view-as alert-box error.
      return no-apply.
    end.
  end case.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME v-cre-db-num
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-cre-db-num Dialog-Frame
ON VALUE-CHANGED OF v-cre-db-num IN FRAME Dialog-Frame /* Расписание для БД */
DO:
  assign
    v-cre-db-num
  .
  {&OPEN-QUERY-br-schedule}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME v-task-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-task-type Dialog-Frame
ON VALUE-CHANGED OF v-task-type IN FRAME Dialog-Frame
DO:
  assign
    v-task-type
    v-btpr-type = v-task-type
  .
  case v-task-type:
       when {&btpr-type-autonws} 
    or when {&btpr-type-autooxml}
    or when {&btpr-type-mercury}
    or when {&btpr-type-hddtest}
    or when {&btpr-type-is_motp}
    or when {&btpr-type-is_diadoc}
    then do:
      disable bt-param with frame {&frame-name} .
    end.
    
       when {&btpr-type-autogetcd}
    or when {&btpr-type-autoarh}
    or when {&btpr-type-autoexp}
    or when {&btpr-type-autosale}
    or when {&btpr-type-autosuz}
    or when {&btpr-type-autocbnk}
    or when {&btpr-type-autofree}
    or when {&btpr-type-is_PM} 
    then do:
      enable bt-param with frame {&frame-name} .
    end.
    otherwise do:
      message vss-workfile vss-revision vss-description skip
        "НЕТ ОБРАБОТКИ АТРИБУТА" v-task-type
        view-as alert-box error.
      return no-apply.
    end.
  end case.

  {&OPEN-QUERY-br-schedule}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-schedule
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


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

  define buffer buf_db for ub.db .

  for each buf_db no-lock
    where buf_db.db-num > 0
  on error undo, return error return-value
  :
    v-cre-db-num:add-last( string( buf_db.db-num ) ).
  end.

  find first buf_sys-ctrl no-lock .

  assign
    v-curr-db    = buf_sys-ctrl.db-num
    v-cre-db-num = v-curr-db
    v-task-type:list-item-pairs = {&autonws} + {&comma-char} + {&btpr-type-autonws} + {&comma-char} +
                                   {&autoarh} + {&comma-char} + {&btpr-type-autoarh} + {&comma-char} +
                                   {&autogcd} + {&comma-char} + {&btpr-type-autogetcd} + {&comma-char} +
                                   {&autosale} + {&comma-char} + {&btpr-type-autosale} + {&comma-char} +
                                   {&autosuz} + {&comma-char}  + {&btpr-type-autosuz} + {&comma-char} +
                                   {&autocbnk} + {&comma-char}  + {&btpr-type-autocbnk} + {&comma-char} +
                                   {&autofree} + {&comma-char}  + {&btpr-type-autofree} + {&comma-char} +
                                   {&mercury} + {&comma-char}  + {&btpr-type-mercury} + {&comma-char} +
                                   {&hddtest} + {&comma-char}  + {&btpr-type-hddtest} + {&comma-char} +
                                   {&is_motp} + {&comma-char}  + {&btpr-type-is_motp} + {&comma-char} +
                                   {&is_diadoc} + {&comma-char}  + {&btpr-type-is_diadoc} + {&comma-char} +
                                   {&is_PM} + {&comma-char}  + {&btpr-type-is_PM}

    /*"{&bef-autonws},{&bef-autoarh},{&bef-autogcd},{&bef-autosale},{&bef-autosuz},{&bef-autocbnk},{&bef-autofree}":U*/
    v-task-type   = {&btpr-type-autonws}
    v-btpr-type   = {&btpr-type-autonws}
    v-modify-task = "":U
    v-modify-btpr = "":U
    buf_schedule.db-num-char:resizable in browse {&browse-name} = yes
    buf_schedule.db-num-char:width = 5
    buf_schedule.task-weekday:resizable in browse {&browse-name} = yes
    buf_schedule.task-weekday:width = 10
    buf_schedule.task-hour:resizable in browse {&browse-name} = yes
    buf_schedule.task-hour:width = 15
    buf_schedule.task-minute:resizable in browse {&browse-name} = yes
    buf_schedule.task-minute:width = 15
    v-PS:resizable in browse {&browse-name} = yes
    v-PS:width = 40
  .

  { gbl/conf-rd.i "'is-bge'" "''" "''" 0 "''" "''" "''" yes v-par-val v-par-type no-error }
   if error-status:error
     or v-par-type <> "L":U
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка чтения конфигурационного параметра is-bge!"
      view-as alert-box error.
    return error .
  end.
  if v-par-val = "yes" then do:
    assign
      v-log = v-task-type:add-last( {&autoexp} , {&btpr-type-autoexp}  ).
    .
  end.
  assign
    v-log = v-task-type:add-last( {&autooxml} , {&btpr-type-autooxml}  ).
  .
  RUN enable_UI.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.

RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE add-modify-task Dialog-Frame
PROCEDURE add-modify-task :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  if lookup( v-btpr-type, v-modify-btpr ) = 0 then do:
    if v-modify-btpr <> "":U then do:
      assign
        v-modify-btpr = v-modify-btpr + ",":U
        v-modify-task = v-modify-task + ",":U
      .
    end.
    assign
      v-modify-btpr = v-modify-btpr + v-btpr-type
      v-modify-task = v-modify-task + '"':U + v-task-type + '"':U
    .
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE delete-btpr Dialog-Frame
PROCEDURE delete-btpr :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  define input        parameter p-btpr-type  as character no-undo .
  define input        parameter p-btpr-task  as character no-undo .
  define input-output parameter p-not-change as character no-undo .

  do
  on error undo, return error
  :
    define variable v-str    as character no-undo .
    define buffer buf_BatchProcess for ub.BatchProcess .

    assign
      v-str = "":U
    .

    for each buf_BatchProcess exclusive-lock
      where buf_BatchProcess.BP_Status = {&btpr-normal}
        and buf_BatchProcess.BP_Type   = p-btpr-type
    on error undo, return error
    :
      if buf_BatchProcess.Key#_One = 1 then do:
        /* время задания изменено вручную, поэтому его не будем обновлять */
        if v-str = "":U then do:
          assign
            v-str = substitute( "&1 для БД: &2", p-btpr-task, buf_BatchProcess.CharKey_One )
          .
        end.
        else do:
          assign
            v-str = v-str + substitute( ",&1", buf_BatchProcess.CharKey_One )
          .
        end.
      end.
      else do:
        delete buf_BatchProcess.
      end.

      if v-str <> "":U then do:
        if p-not-change = "":U then do:
          assign
            p-not-change = v-str
          .
        end.
        else do:
          assign
            p-not-change = p-not-change + {&comma-char} + v-str
          .
        end.
      end.

    end.
  end.
  return.

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
  DISPLAY v-cre-db-num v-task-type
      WITH FRAME Dialog-Frame.
  ENABLE b-quit b-add b-chg b-copy b-del b-help v-cre-db-num v-task-type
         br-schedule
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-free-task-name Dialog-Frame
FUNCTION get-free-task-name RETURNS CHARACTER
  ( input p-cre-db-num as integer, INPUT p-task-type AS character, INPUT p-task-num AS integer ) :
define variable v-dop as character no-undo .
define variable v-value as character no-undo .
define variable v-type as character no-undo .

IF p-task-type <> {&btpr-type-autofree} THEN
  RETURN "".   /* Function return value. */


/*можно найти из значения атрибута schd-free-id*/
run schedule-attr-value in this-procedure (
                                             input  p-cre-db-num
                                            ,input  p-task-type
                                            ,input  p-task-num
                                            ,input  ({&attr-schd-free-id} + {&delim-par})
                                            ,output v-value
                                            ,output v-type ) no-error .
if error-status:error then return {&question-mark}.
assign
v-dop = entry(1, v-value, {&delim-par} )
no-error .
if error-status:error then do:
  return {&question-mark}.
end.
return v-dop.
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME