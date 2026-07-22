&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME d-cur-date
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS d-cur-date

/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Запрос текущей даты

Автор: Белоусов Илья Александрович
Дата создания: 04/05/06
Author: Ilia Belousov
Creation date: 04/05/06

input:
    p-date-change as character  - режим изменения даты. Если 'change-date'
                                 то обязательно выводится запрос на изменение даты.

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

define input  parameter parParentProc   as widget-handle    no-undo.
define input  parameter p-obj-type      as character        no-undo .
define input  parameter p-obj-code      as integer          no-undo .
define input  parameter p-date-change   as character        no-undo .
define output parameter p-error-code    as integer          no-undo.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Запрос текущей даты".
{ cmp/vssrevis.i "substitute('&1|&2|&3':u,p-obj-type,p-obj-code,p-date-change)" }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/cur-time.i }
{ gbl/sel-date.i }
{ cmp/showinf.i  }

define variable v-today                 as date                    no-undo.
define variable v-time                  as integer                 no-undo.
define variable v-obj-date              as date                    no-undo.
define variable v-allow-date-change     as logical                 no-undo.
define variable v-auto-date-change      as logical                 no-undo.
define variable v-conf-parameter-string as character               no-undo.
define variable v-obj-date-is-from-base as logical init yes        no-undo.
define variable v-shift-obj-on          as logical                 no-undo.
define variable v-shift-start-date      as date                    no-undo.
define variable v-max-shift-days        as integer                 no-undo.
define variable v-par-type              as character               no-undo.
define variable v-shift-num             as integer                 no-undo.
define variable v-shift-name            as character               no-undo.
define variable v-void-date             as date                    no-undo.
define variable v-endkey-error          as logical init no         no-undo.
define variable v-exit-enabled          as logical init no         no-undo.
{ gbl/getcntxt.i def }
define buffer buf_obj-date      for ub.obj-date.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME d-cur-date

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-quit b-help ed-info cur-date ~
b-choose-date fi-description
&Scoped-Define DISPLAYED-OBJECTS ed-info cur-date fi-description

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-choose-date
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "b-choose-date"
     SIZE 3 BY .88.

DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Ввод "
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

DEFINE VARIABLE ed-info AS CHARACTER
     VIEW-AS EDITOR
     SIZE 36.38 BY 3.29
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE cur-date AS DATE FORMAT "99/99/9999":U
     VIEW-AS FILL-IN
     SIZE 11.5 BY 1 NO-UNDO.

DEFINE VARIABLE fi-description AS CHARACTER FORMAT "X(256)":U INITIAL "Текущая дата:"
      VIEW-AS TEXT
     SIZE 14 BY .67 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME d-cur-date
     b-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     b-help AT ROW 1 COL 21
     ed-info AT ROW 2.5 COL 1 NO-LABEL
     cur-date AT ROW 6.46 COL 14.13 COLON-ALIGNED NO-LABEL
     b-choose-date AT ROW 6.54 COL 28.75
     fi-description AT ROW 6.67 COL 1.38 NO-LABEL
     SPACE(23.48) SKIP(0.94)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Ввод даты"
         DEFAULT-BUTTON b-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX d-cur-date
                                                                        */
ASSIGN
       FRAME d-cur-date:SCROLLABLE       = FALSE
       FRAME d-cur-date:HIDDEN           = TRUE.

ASSIGN
       ed-info:READ-ONLY IN FRAME d-cur-date        = TRUE.

/* SETTINGS FOR FILL-IN fi-description IN FRAME d-cur-date
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX d-cur-date
/* Query rebuild information for DIALOG-BOX d-cur-date
     _Options          = "SHARE-LOCK"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX d-cur-date */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME d-cur-date
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL d-cur-date d-cur-date
ON WINDOW-CLOSE OF FRAME d-cur-date /* Ввод даты */
DO:
    if v-exit-enabled = no
    then do:
        return no-apply.
    end.
    APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-choose-date
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-choose-date d-cur-date
ON CHOOSE OF b-choose-date IN FRAME d-cur-date /* b-choose-date */
DO:
  run sel-date in this-procedure
    (input cur-date :handle
    ,input replace(ed-info :screen-value, {&new-line}, '. ') + {&new-line} +
           'Новая дата: &1'
    ) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-quit d-cur-date
ON CHOOSE OF b-quit IN FRAME d-cur-date /* Отмена */
DO:
  define variable v-ok as logical   no-undo .
  assign
    cur-date
  .
  if cur-date <> ?
  then do:
    message
      "Отказаться от изменения даты?" skip
      view-as alert-box question buttons yes-no update v-ok .
    if v-ok <> true
    then do:
      return no-apply .
    end.
  end.

  assign
    v-endkey-error = yes
    v-exit-enabled = yes
  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME cur-date
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL cur-date d-cur-date
ON RETURN OF cur-date IN FRAME d-cur-date
DO:
  assign
      v-exit-enabled = yes
  .
  apply "choose" to b-exit in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK d-cur-date


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/app_help.i }
{ gbl/ed_date.i cur-date }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  { gbl/getcntxt.i get }
  if v-cntxt-level <> {&cntxt-object} then do:
    message
    "Объект не определен"
    view-as alert-box  warning.
  end.
  else do:
    assign
        p-error-code = 0
    .
    run cur-time in this-procedure ( output v-today
                                  , output v-time
                                  ).
    run enter-on-object in this-procedure no-error.
    if error-status :error
    then do:
        if v-endkey-error = yes
        then do:
            if p-date-change <> 'change-date':U
            then do:
                message
                    "Без ввода даты работа на объекте невозможна."
                view-as alert-box error.
            end.
            undo, return error .
        end.
        else do:
            message
            vss-workfile vss-revision vss-description
            skip  "Ошибка входа на объект"
            skip
            skip  return-value
                    trim(error-status :get-message(1))
                    trim(error-status :get-message(2))
                    trim(error-status :get-message(3))
                    trim(error-status :get-message(4))
                    trim(error-status :get-message(5))
            view-as alert-box error.
            undo, return error .
        end.
    end.
  end.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE check-shift-days d-cur-date
PROCEDURE check-shift-days :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define output parameter p-error-code    as integer          no-undo.

do
on error undo, return error
:
    assign
        p-error-code = 0
    .
    if v-shift-obj-on = yes
    then do:
        { gbl/curshift.i
          p-obj-type
          p-obj-code
          v-shift-start-date
          v-shift-num
          v-shift-name
          no-error
        }
        if not error-status :error
        then do: /* Смена открыта. Проверка на продолжительность смены */
            define variable v-host-code like ub.shop.host-code     no-undo.
            { gbl/hostcode.i
              p-obj-type
              p-obj-code
              v-host-code
            }

            define variable v-value-character as character  no-undo .
            define variable v-value-date      as date       no-undo .
            define variable v-value-decimal   as decimal    no-undo .
            define variable v-value-logical   as logical    no-undo .
            define variable v-tth             as handle     no-undo .
            define variable v-param-type            as character no-undo .

            run adm/shattri.p ( input "get":U
                              , input  p-obj-type
                              , input  p-obj-code
                              , input  {&attr-obj-date}
                              , input  {&attr-obj-date_diffshft}
                              , output v-value-character
                              , output v-value-date
                              , output v-value-decimal
                              , output v-max-shift-days
                              , output v-value-logical
                              , output v-param-type
                              , input-output table-handle v-tth
                              ) no-error .
            if error-status :error
            then do:
               /* параметр может быть не задан */
               assign
                  v-max-shift-days = 3
               .
            end.
            delete object v-tth.

            if v-obj-date - v-shift-start-date > integer( v-max-shift-days )
            then do:
                if v-cntxt-is-admin = yes
                then do:
                    message
                        skip "С момента открытия смены N " v-shift-name " порядок " v-shift-num " от " v-shift-start-date
                        skip " до введенной даты: " v-obj-date
                        skip " прошло более " v-max-shift-days + 1 " дней"
                        skip (1)
                        skip "Вход на объект возможен"
                        skip "только для администратора системы."
                        skip "Для работы остальных пользователей на объекте"
                        skip "необходимо установить корректную дату ."
                    view-as alert-box error.
                    assign
                       p-error-code = 0
                    .
                    /* Можно продолжать работу. */
                end.
                else do:
                    assign
                       p-error-code = 1
                    .
                    message
                        skip "С момента открытия смены N " v-shift-name " порядок " v-shift-num " от " v-shift-start-date
                        skip " до введенной даты: " v-obj-date
                        skip " прошло более " v-max-shift-days + 1 " дней"
                        skip (1)
                        skip "Вход на объект возможен"
                        skip "только для администратора системы."
                    view-as alert-box error.
                    undo, return error .
                end.
            end.
        end.        /* Смена открыта. Проверка на продолжительность смены */
    end.        /* v-shift-obj-on = yes */
end.
END PROCEDURE. /* check-shift-days */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI d-cur-date  _DEFAULT-DISABLE
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
  HIDE FRAME d-cur-date.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI d-cur-date  _DEFAULT-ENABLE
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
  DISPLAY ed-info cur-date fi-description
      WITH FRAME d-cur-date.
  ENABLE b-exit b-quit b-help ed-info cur-date b-choose-date fi-description
      WITH FRAME d-cur-date.
  VIEW FRAME d-cur-date.
  {&OPEN-BROWSERS-IN-QUERY-d-cur-date}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enter-on-object d-cur-date
PROCEDURE enter-on-object :
/*------------------------------------------------------------------------------
  Purpose:     Основная процедура входа на объект
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  define variable v-obj-is-active as logical   no-undo .
  define variable v-shift-string  as character no-undo .
  define variable v-is-admin as logical no-undo .

  do
  on error undo, return error
  :
    { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      "'actn_object-date_update':U"
      {&cntxt-object}
      v-cntxt-host-code-obj
      v-cntxt-obj-type
      v-cntxt-obj-code
      0
      0
      0
      false
      v-allow-date-change
    }
    { gbl/objat.i
      p-obj-type
      p-obj-code
      "'shift-on=request'"
      v-shift-obj-on
      no-error
    }
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении типа сменный/не-сменный для объекта" skip
        "Объект" p-obj-type p-obj-code skip
        "Атрибут" 'autodate=request':u skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
    if v-shift-obj-on = yes
    then do:
      { gbl/curshift.i
        p-obj-type
        p-obj-code
        v-shift-start-date
        v-shift-num
        v-shift-name
        no-error
      }
      if not error-status :error
      then do:
        /* Смена открыта. */
        assign
          v-shift-string = "Открыта смена " + string( v-shift-name ) + " от " + string( v-shift-start-date )
        .
      end.
      else do:
        assign
          v-shift-string = "Смена закрыта"
        .
      end.
    end.

    for each buf_obj-date exclusive-lock
      where buf_obj-date.status_  = {&g___new}
    on error undo, return error return-value
    :
      /* Первая дата, установлена после upgrade */
      /* и еще не отправлена по новостям */
      assign
        buf_obj-date.status_  = {&objdt-current}
      .
      /* отправить дату по новостям */
    end.

    { gbl/objat.i
      p-obj-type
      p-obj-code
      "'autodate=request'"
      v-auto-date-change
      no-error
    }
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении атрибута объекта" skip
        "Объект" p-obj-type p-obj-code skip
        "Атрибут" 'autodate=request':u skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.

    { gbl/objat.i
      p-obj-type
      p-obj-code
      "'active=request'"
      v-obj-is-active
      no-error
    }
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не удалось определить активность объекта." skip
        "Объект" p-obj-type p-obj-code skip
        return-value skip
        error-status :get-message(1) skip
        view-as alert-box error .
      undo, return error .
    end.
    find first buf_obj-date
      where buf_obj-date.obj-type = p-obj-type
        and buf_obj-date.obj-code = p-obj-code
        and buf_obj-date.status_  = {&objdt-current}
    no-error .
    if not available buf_obj-date
    then do:   /* На объект еще не входили или нет текущей даты на объекте (все даты закрыты) */
        if v-obj-is-active = no
        then do:
            find first buf_obj-date
                where buf_obj-date.obj-type = p-obj-type
                  and buf_obj-date.obj-code = p-obj-code
            no-error .
            if not available buf_obj-date
            then do:        /* Первый вход на неактивный объект (после upgrade), дата еще не установлена */
                assign
                    v-obj-date              = v-today
                    v-obj-date-is-from-base = yes
                .
            end.
            else do:
                message
                    "Не удалось получить дату на неактивном объекте " p-obj-type p-obj-code "."
                    skip "Необходимо установить дату на активном объекте."
                    skip (1) "Обратитесь к администратору системы."
                view-as alert-box error.
                undo, return error .
            end.
        end.        /* v-obj-is-active = no */
        else do:
            if v-allow-date-change = no
            then do:
                message
                    "Это первый вход в систему на объекте " p-obj-type p-obj-code "."
                    skip "Необходимо установить дату на объекте."
                    skip (1) "Обратитесь к администратору системы."
                view-as alert-box error.
                undo, return error .
            end.
            else do:
                message
                    "Это первый вход в систему на этом объекте."
                    skip (1) "Установите, пожалуйста, дату на объекте."
                view-as alert-box information.
                run get-date-from-admin in this-procedure(
                        input "is-obj-date"
                        , input v-shift-obj-on
                        , input v-shift-string
                        , input v-auto-date-change
                        , input " не установлена"
                ) no-error.
                if error-status :error or v-endkey-error = yes
                then do:
                    undo, return no-apply .
                end.
            end.
        end.        /* v-obj-is-active = yes */
    end.        /* not available buf_obj-date */
    else do:   /* Нашли текущую дату на объекте */
        { gbl/objdtget.i p-obj-type p-obj-code v-obj-date }
        if v-obj-is-active = no
        then do:
            assign
                v-obj-date-is-from-base = yes
            .
        end.
        else do:
            if v-obj-date > v-today
            then do:
                undo, return error "Дата на объекте больше текущей даты".
            end.
            if v-obj-date = ?
            or v-obj-date + 10 < v-today
            then do:
                if v-auto-date-change = no
                and v-obj-date <> ?
                and p-date-change <> 'change-date':U
                then do:    /* Ручная смена даты и полученная из базы дата отличается от v-today более чем на 10 дней */
                    message
                        "Дата на объекте " p-obj-type p-obj-code
                        skip "отличается от текущей более чем на 10 дней."
                        skip "Вы можете изменить дату на объекте вручную."
                        skip "Для этого воспользуйтесь меню системы, пункт"
                        skip "        Сервис / Изменить дату."
                    view-as alert-box warning.
                    assign
                        v-obj-date-is-from-base = yes
                    .
                end.
                else do:
                    if v-allow-date-change = no
                    then do:
                        message
                            "Дата на объекте " p-obj-type p-obj-code " не определена"
                            skip "или на объект не входили более 10 дней."
                            skip "Необходимо установить дату на объекте."
                            skip (1) "Обратитесь к администратору системы."
                        view-as alert-box error.
                        undo, return error .
                    end.
                    else do:
                        if p-date-change <> 'change-date':U
                        then do:
                            message
                                "Дата на объекте " p-obj-type p-obj-code " не определена"
                                skip "или на объект не входили более 10 дней."
                                skip (1) "Установите, пожалуйста, дату на объекте."
                            view-as alert-box information.
                        end.
                        run get-date-from-admin in this-procedure(
                            input "is-obj-date"
                            , input v-shift-obj-on
                            , input v-shift-string
                            , input v-auto-date-change
                            , input ( if v-obj-date = ? then " не установлена" else string( v-obj-date, '99/99/9999':u ) )
                        ) no-error .
                        if error-status :error or v-endkey-error = yes
                        then do:
                            undo, return error .
                        end.
                    end.
                end.
            end.        /* v-obj-date = ? or v-obj-date + 10 < v-today */
            else do:
                if v-obj-date < v-today
                then do:
                    if v-auto-date-change = yes
                    or p-date-change = 'change-date':U
                    then do:
                        run get-date-from-admin in this-procedure(
                                          input ""
                                        , input v-shift-obj-on
                                        , input v-shift-string
                                        , input v-auto-date-change
                                        , input string( v-obj-date, '99/99/9999':u )
                        ) no-error.
                        if error-status :error or v-endkey-error = yes
                        then do:
                            undo, return error .
                        end.
                    end.        /* v-auto-date-change = yes  */
                    else do:
                        assign
                            v-obj-date-is-from-base = yes
                        .
                    end.        /* v-auto-date-change = no */
                    run check-shift-days in this-procedure (
                        output p-error-code
                    ) no-error.
                    if error-status :error
                    then do:
                        message
                          vss-workfile vss-revision vss-description
                          skip "Ошибка продолжительности смены."
                          skip return-value
                          skip trim(error-status :get-message(1))
                               trim(error-status :get-message(2))
                               trim(error-status :get-message(3))
                               trim(error-status :get-message(4))
                               trim(error-status :get-message(5))
                        view-as alert-box error.
                        undo, return error .
                    end.
                end.        /* v-obj-date < v-today */
                else do:
                    if p-date-change = 'change-date':U
                    then do:
                        message
                            "Дата на объекте равна или больше сегодняшней даты."
                            skip(1) "Изменение даты невозможно."
                        view-as alert-box information.
                    end.        /* p-date-change = 'change-date':U */
                end.        /* NOT( v-obj-date < v-today ) */
            end.        /* v-obj-date <> ? and v-obj-date + 10 > v-today */
        end.        /* v-obj-is-active = yes */
    end.        /* available buf_obj-date */
    if v-obj-is-active = yes
    then do:
        run check-shift-days in this-procedure (
            output p-error-code
        ) no-error.
        if error-status :error
        then do:
            message
                vss-workfile vss-revision vss-description
                skip "Ошибка продолжительности смены."
                skip return-value
                skip trim(error-status :get-message(1))
                    trim(error-status :get-message(2))
                    trim(error-status :get-message(3))
                    trim(error-status :get-message(4))
                    trim(error-status :get-message(5))
            view-as alert-box error.
            undo, return error .
        end.
    end.
    else do:
        if p-date-change = 'change-date':U
        then do:
            message
                skip "Изменение даты невозможно:"
                skip "Объект не активен."
            view-as alert-box error.
        end.
    end.
    if v-obj-date-is-from-base = no
    then do:
        find first buf_obj-date no-lock
             where buf_obj-date.obj-type = p-obj-type
               and buf_obj-date.obj-code = p-obj-code
               and buf_obj-date.status_  = {&objdt-current}
        no-error .
        if not available buf_obj-date
        then do:   /* На объект еще не входили или нет текущей даты на объекте (все даты закрыты) */
            { gbl/objdtcr.i
             p-obj-type
             p-obj-code
             v-obj-date
             no-error }
            if error-status :error then do:
                message
                    vss-workfile vss-revision vss-description
                    skip "Ошибка при создании даты на объекте"
                    skip return-value
                    skip trim(error-status :get-message(1))
                        trim(error-status :get-message(2))
                        trim(error-status :get-message(3))
                        trim(error-status :get-message(4))
                        trim(error-status :get-message(5))
                view-as alert-box error.
                undo, return error .
            end.
        end.
        else do:
            { gbl/objdtset.i p-obj-type p-obj-code v-obj-date }
        end.
    end.
   /* Вход на объект */
end.
END PROCEDURE. /* enter-on-object */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-date-from-admin d-cur-date
PROCEDURE get-date-from-admin :
/*------------------------------------------------------------------------------
  Purpose:      Ввод даты админом. Проверка полученной даты.
  Parameters:   p-is-obj-date - если "is-obj-date", то надо принять полученную дату
                                как дату на объекте. Если нет - сверить полученную
                                дату с датой на объекте
  Notes:        error-status :error означает неверно введенную дату или отмену
                входа на объект.
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-is-obj-date        as character    no-undo.
define input parameter p-shift-enabled      as logical      no-undo.
define input parameter p-shift-string       as character    no-undo.
define input parameter p-auto-date          as logical      no-undo.
define input parameter p-last-date-string   as character    no-undo.

    define variable v-entered-date-ok as logical    no-undo.

    RUN enable_UI.
    assign
        ed-info :screen-value in frame {&frame-name} = "Объект: " + p-obj-type + " " + string( p-obj-code )
                                + ( if p-shift-enabled then ", сменный" else "" )
                                + ( if p-shift-enabled then {&new-line} + p-shift-string else "" )
                                + {&new-line} + ( if p-auto-date     then "Автоматическая смена даты" else "Не автоматическая смена даты" )
                                + {&new-line} + "Дата на объекте: " + p-last-date-string
        v-entered-date-ok   = no
        v-endkey-error      = no
    .
    do while v-entered-date-ok = no
    and v-endkey-error = no
    :
        WAIT-FOR GO OF FRAME {&FRAME-NAME} focus cur-date.
        assign cur-date.
        if ( cur-date > v-obj-date
            and cur-date <= v-today )
        or v-obj-date = ?
        then do:
            assign
                v-entered-date-ok   = yes
            .
        end.
        else do:
            message
            "Введенная дата меньше или равна дате на объекте"
            skip "или больше текущей даты."
            skip (1) "Установите дату правильно или отмените операцию."
            view-as alert-box error.
        end.
    end.
    RUN disable_UI.
    if p-is-obj-date = "is-obj-date"
    then do:
        assign
            v-obj-date = cur-date
        .
    end.
    if cur-date < v-obj-date
    or cur-date > v-today
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Введенная дата больше даты на сервере"
          skip "или меньше текущей даты на объекте."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
               trim(error-status :get-message(4))
               trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return error .
    end.
    if v-auto-date-change = yes
    and cur-date <> v-today
    then do:
        undo, return error.
    end.
    assign
        v-obj-date = cur-date
        v-obj-date-is-from-base = no
    .
    run set-all-active-auto-objects in this-procedure (
        input v-obj-date
    ) no-error.
end.
END PROCEDURE. /* get-date-from-admin */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE set-all-active-auto-objects d-cur-date
PROCEDURE set-all-active-auto-objects :
/*------------------------------------------------------------------------------
  Purpose:     Установить текущую дату на всех активных автоматических объектах
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-obj-date   as date         no-undo.

    define buffer buf_obj-date      for ub.obj-date.
    define variable v-auto-date-change  as logical       no-undo.
    define variable v-obj-is-active     as logical       no-undo.

    define buffer buf_db for ub.db .
    define buffer buf_clients for ub.clients .

    objects-of-base:
    for each buf_db no-lock
    on error undo, return error return-value
    :
      for each buf_clients no-lock
        where buf_clients.db-num = buf_db.db-num
      :
          if  buf_clients.obj-type = p-obj-type
          and buf_clients.obj-code = p-obj-code
          then do:
              next objects-of-base.
          end.
          { gbl/objat.i
              buf_clients.obj-type
              buf_clients.obj-code
              "'autodate=request'"
              v-auto-date-change
              no-error
          }
          if error-status :error
          then do:
              message
                  vss-workfile vss-revision vss-description
                  skip "Ошибка при определении атрибута объекта."
                  skip "Объект" buf_clients.obj-type buf_clients.obj-code
                  skip "Атрибут" 'autodate=request':u
                  skip "(автоматическая/ручная смена даты на объекте)"
                  skip error-status :get-message(1)
                  skip return-value
                  skip "Дата на объекте не изменится."
              view-as alert-box error .
              undo, next objects-of-base.
          end.
          if v-auto-date-change = yes
          then do:
              { gbl/objat.i
                  buf_clients.obj-type
                  buf_clients.obj-code
                  "'active=request'"
                  v-obj-is-active
                  no-error
              }
              if error-status :error
              then do:
                  message
                      vss-workfile vss-revision vss-description
                      skip "Ошибка при определении атрибута объекта."
                      skip "Объект" buf_clients.obj-type buf_clients.obj-code
                      skip "Атрибут" 'active=request':u
                      skip "(активность объекта)"
                      skip error-status :get-message(1)
                      skip return-value
                      skip "Дата на объекте не изменится."
                  view-as alert-box error .
                  undo, next objects-of-base.
              end.
              if v-obj-is-active = yes
              then do:
                  find first buf_obj-date no-lock
                      where buf_obj-date.obj-type = buf_clients.obj-type
                        and buf_obj-date.obj-code = buf_clients.obj-code
                        and buf_obj-date.status_  = {&objdt-current}
                  no-error .
                  if not available buf_obj-date
                  then do:   /* На объект еще не входили или нет текущей даты на объекте (все даты закрыты) */
                      do transaction
                      on error undo, return error
                      :
                          find last buf_obj-date exclusive-lock
                              where buf_obj-date.obj-type = buf_clients.obj-type
                                and buf_obj-date.obj-code = buf_clients.obj-code
                          use-index pi
                          no-error
                          no-wait.
                          if not available buf_obj-date
                          then do:
                                  /* Ничего не делать. Таблица в обработке. */
                          end.        /* if not available buf_obj-date */
                          else do:
                              if buf_obj-date.status_ = {&objdt-closed}
                              then do:
                                  { gbl/objdtcr.i
                                      buf_clients.obj-type
                                      buf_clients.obj-code
                                      p-obj-date
                                      no-error
                                  }
                                  if error-status :error
                                  then do:
                                      message
                                          vss-workfile vss-revision vss-description
                                          skip "Ошибка при создании даты на объекте."
                                          skip "Объект" buf_clients.obj-type buf_clients.obj-code
                                          skip "Дата  " string( p-obj-date, "99/99/9999" )
                                          skip return-value
                                          skip trim(error-status :get-message(1))
                                      view-as alert-box error.
                                      undo, return error .
                                  end.
                              end.
                          end.        /* if available buf_obj-date */
                      end.        /* do transaction */
                  end.        /* not available buf_obj-date */
                  else do:
                      if buf_obj-date.sys-date < p-obj-date
                      then do:
                          do transaction
                          :
                              find last buf_obj-date exclusive-lock
                                  where buf_obj-date.obj-type = buf_clients.obj-type
                                    and buf_obj-date.obj-code = buf_clients.obj-code
                              use-index pi
                              no-error
                              no-wait.
                              if available buf_obj-date
                              and buf_obj-date.status_ = {&objdt-current}
                              and buf_obj-date.sys-date < p-obj-date
                              then do:
                                  { gbl/objdtset.i
                                      buf_clients.obj-type
                                      buf_clients.obj-code
                                      p-obj-date
                                      no-error
                                  }
                                  if error-status :error
                                  then do:
                                      message
                                          vss-workfile vss-revision vss-description
                                          skip "Ошибка при изменении даты на объекте."
                                          skip "Объект" buf_clients.obj-type buf_clients.obj-code
                                          skip "Дата  " string( p-obj-date, "99/99/9999" )
                                          skip return-value
                                          skip trim(error-status :get-message(1))
                                      view-as alert-box error.
                                      undo, return error .
                                  end.
                              end.        /* if available buf_obj-date */
                          end.        /* do transaction */
                      end.        /* if buf_obj-date.sys-date < p-obj-date */
                  end.        /* available buf_obj-date */
              end.        /* v-obj-is-active = yes */
          end.        /* v-auto-date-change = yes  */
      end.        /* for each buf_clients */
   end.       /* for each buf_db no-lock */
end.
END PROCEDURE. /* set-all-active-auto-objects */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME