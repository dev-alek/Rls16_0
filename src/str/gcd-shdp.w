&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
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

Выбор параметров для автоматическиго приема информации с касс по расписанию.

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/21/05
Author: Bakhtadze Natalya
Creation date: 01/21/05

*/

/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input  parameter parparentproc as widget-handle no-undo .
define input  parameter p-cre-db-num  as integer   no-undo .
define input  parameter p-task-type   as character no-undo .
define input  parameter p-task-num    as integer   no-undo .
define output parameter p-cancel      as logical      no-undo.
/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Выбор параметров для автоматическиго приема информации с касс по расписанию..".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ cmp/library.i  }
{ cmp/operlist.i }
{ gbl/cur-time.i }
{ gbl/getcntxt.i def }
{ gbl/userobjs.i }
{ ref/shd-attr.i }
define variable v-obj-list              as character    no-undo.
define variable v-host-code             as integer      no-undo.
define variable v-host-name             as character    no-undo.
dEFINE variable v-param-type            as character     no-undo.
define temp-table temp_obj-list no-undo
    field obj-type as character
    field obj-code as integer
    index pi is primary unique obj-type obj-code
.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS rct-obj RECT-6 Btn_OK Btn_Cancel b-help rs-1 ~
bt-sel-obj rs-remote
&Scoped-Define DISPLAYED-OBJECTS rs-1 ed-object rs-remote

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1.

DEFINE BUTTON bt-sel-obj
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "..."
     SIZE 3.63 BY 1.04.

DEFINE BUTTON Btn_Cancel AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON Btn_OK DEFAULT
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE ed-object AS CHARACTER
     VIEW-AS EDITOR NO-BOX
     SIZE 40.75 BY 3.38
     FGCOLOR 1  NO-UNDO.

DEFINE VARIABLE rs-1 AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "все объекты БД", 1,
"все объекты БД по фирме", 2,
"объекты выборочно", 3
     SIZE 28 BY 3.25 NO-UNDO.

DEFINE VARIABLE rs-remote AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Прием информации с локальных касс", 0,
"Запрос на удаленные кассы", 1
     SIZE 49.5 BY 1.75 NO-UNDO.

DEFINE RECTANGLE rct-obj
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 79 BY 4.25.

DEFINE RECTANGLE RECT-6
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 79 BY 2.75.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     Btn_OK AT ROW 1.25 COL 1.5
     Btn_Cancel AT ROW 1.25 COL 11.5
     b-help AT ROW 1.25 COL 71
     rs-1 AT ROW 3.25 COL 3.5 NO-LABEL
     ed-object AT ROW 3.25 COL 38 NO-LABEL
     bt-sel-obj AT ROW 5.54 COL 33
     rs-remote AT ROW 7.5 COL 3.5 NO-LABEL
     rct-obj AT ROW 2.75 COL 2
     RECT-6 AT ROW 7 COL 2
     SPACE(0.37) SKIP(0.00)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Параметры приема информации с касс по расписанию"
         CANCEL-BUTTON Btn_Cancel.


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
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR EDITOR ed-object IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Параметры приема информации с касс по расписанию */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-sel-obj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-sel-obj Dialog-Frame
ON CHOOSE OF bt-sel-obj IN FRAME Dialog-Frame /* ... */
DO:
  define variable v-exclude-obj-list     as character     no-undo.
  assign
    rs-1 :screen-value  = "3"
  .
  { gbl/uobjclr.i  }

  define variable v-object-available as logical   no-undo .
  { gbl/usobjava.i
    v-cntxt-db-num
    {&action-head-code-main}
    v-cntxt-userid
    v-cntxt-obj-type
    v-cntxt-obj-code
    v-object-available
  }

  if v-object-available = true
  then do:
    { gbl/uobjapnd.i
      v-cntxt-obj-type
      v-cntxt-obj-code
    }
  end.

  define variable v-user-select as logical   no-undo .
  { gbl/uobjsman.i
    parparentproc
    v-cntxt-db-num
    v-cntxt-userid
    v-cntxt-host-code-obj
    v-cntxt-obj-type
    v-cntxt-obj-code
    v-user-select
  }
  if v-user-select <> true
  then do:
    message
      "Объект не выбран"
      view-as alert-box information .
    return no-apply .
  end.

  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .

  define variable v-store as integer   no-undo .

  assign
    v-store = 0
  .
  for each temp_obj-list :
    delete temp_obj-list.
  end.
  for each buf_userobjs_temp-user-obj
  on error undo, return no-apply
  :
    if buf_userobjs_temp-user-obj.obj-type = {&stock}
    then do:
      assign
        v-store = v-store + 1
      .
    end.
    else do:
      find first temp_obj-list where
              temp_obj-list.obj-type = buf_userobjs_temp-user-obj.obj-type
           and temp_obj-list.obj-code = buf_userobjs_temp-user-obj.obj-code no-error.
      if not available temp_obj-list then do:
        create temp_obj-list .
        assign
          temp_obj-list.obj-type = buf_userobjs_temp-user-obj.obj-type
          temp_obj-list.obj-code = buf_userobjs_temp-user-obj.obj-code
        .
      end.
    end.
  end.
  if v-store > 0
  then do:
    message
      substitute("Среди выбранных Вами объектов было &1 объекта типа &2 - ПРОПУЩЕНЫ"
                , v-store
                , {&stock}
                )
      view-as alert-box information .
  end.


  run select-objects-only-this-db in this-procedure
    (output v-obj-list
    ,output v-exclude-obj-list
    ).
    if v-exclude-obj-list <> ""
    then do:
        message
            "Из списка выбранных объектов исключены"
            skip "объекты, не принадлежащие БД, указанной в расписании:"
            skip(1)
            skip v-exclude-obj-list
        view-as alert-box information.
    end.
    assign
        ed-object :screen-value = v-obj-list
    .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_Cancel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_Cancel Dialog-Frame
ON CHOOSE OF Btn_Cancel IN FRAME Dialog-Frame /* Отмена */
DO:
    assign
        p-cancel = yes
    .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_OK
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_OK Dialog-Frame
ON CHOOSE OF Btn_OK IN FRAME Dialog-Frame /* Ввод */
DO:
    define variable v-obj-list as character     no-undo.
    ASSIGN
        rs-1
        rs-remote
    .
    case rs-1
    :
    when 1
    then do:
        assign
            v-obj-list = ""
        .
    end.
    when 2
    then do:
        assign
            v-obj-list = ""
        .
    end.
    when 3
    then do:
        assign
            v-obj-list = ""
        .
        for each temp_obj-list
        :
            assign
                v-obj-list = v-obj-list
                        + ( if v-obj-list = "" then "" else "," ) + temp_obj-list.obj-type
                        + "," + string( temp_obj-list.obj-code )
            .
        end.
    end.
    end case.
    find first temp_obj-list no-error.
    if not available temp_obj-list
    and rs-1 = 3
    then do:
        message
            "Не выбраны объекты для приема информации с касс."
        view-as alert-box warning.
        undo, return no-apply.
    end.
    run attach-attr-to-schedule-line in this-procedure (
          input rs-1
        , input v-obj-list
        , INPUT rs-remote
    ).
    APPLY "GO" TO FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rs-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-1 Dialog-Frame
ON VALUE-CHANGED OF rs-1 IN FRAME Dialog-Frame
DO:
    assign
        rs-1
    .
    run object-select in this-procedure (
        input rs-1
    ) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rs-remote
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-remote Dialog-Frame
ON VALUE-CHANGED OF rs-remote IN FRAME Dialog-Frame
DO:
     assign
        rs-remote
    .
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
    assign
        frame {&frame-name} :title = frame {&frame-name} :title
                    + ". " + p-task-type + ": Задача номер " + string( p-task-num )
    .
    { gbl/getcntxt.i get }
    { gbl/hostcode.i v-cntxt-obj-type v-cntxt-obj-code v-host-code no-error }
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Ошибка при определении кода фирмы текущего объекта"
          skip "Тип объекта:" v-cntxt-obj-type
          skip "Код объекта:" v-cntxt-obj-code
          skip "Выполнение приема информации с касс невозможно"
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error.
    end.
    run get-host-name in this-procedure ( output v-host-name ) no-error .
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Ошибка при определении имени фирмы"
          skip "Код фирмы:" v-host-code
          skip "Имя фирмы будет отображаться как '" + {&cmp} + string( v-host-code ) + "'"
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
        view-as alert-box warning.
        assign
            v-host-name = {&cmp} + string( v-host-code )
        .
    end.
    run init-param-values in this-procedure (
          input p-cre-db-num
        , input p-task-type
        , input p-task-num
        , output v-obj-list
        , output rs-1
        , OUTPUT rs-remote
    ).
    run enable_UI.
    run object-select in this-procedure (
        input rs-1
    ).
    run init-fields in this-procedure .
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
do
on error undo, return error
:
    define input parameter p-rs-1               as integer      no-undo.
    define input parameter p-object-list        as character    no-undo.
    define input parameter p-rs-remote               as integer      no-undo.


    define variable v-attr-value as character     no-undo.

    define buffer buf_schedule      for ub.schedule.
    define buffer buf_schedule-attr for ub.schedule-attr.
    find first buf_schedule no-lock
         where buf_schedule.cre-db-num = p-cre-db-num
           and buf_schedule.task-type  = p-task-type
           and buf_schedule.task-num   = p-task-num
    no-error.
    if not available buf_schedule
    and (  p-task-type   <> {&btpr-type-autogetcd}
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
    assign
        v-attr-value = string( p-rs-1 )
                       + "," + string( v-cntxt-host-code-obj )
                       + "," + string( p-rs-remote )
    .
    run schedule-attr-write in this-procedure (
          input p-cre-db-num
        , input p-task-type
        , input p-task-num
        , input {&attr-schedule-param-list-h}
        , input v-attr-value
    ).
    run schedule-attr-write in this-procedure (
          input p-cre-db-num
        , input p-task-type
        , input p-task-num
        , input {&attr-schedule-obj-list-h}
        , input p-object-list
    ).
    for each buf_schedule-attr
    on error undo, return error
    :
        if buf_schedule-attr.cre-db-num <> p-cre-db-num
        or buf_schedule-attr.task-type  <> {&btpr-type-autogetcd}
        or buf_schedule-attr.task-num   <> -1
        or (
                buf_schedule-attr.attr-code <> {&attr-schedule-param-list-h}
            and buf_schedule-attr.attr-code <> {&attr-schedule-obj-list-h}
)
        then do:
            find first buf_schedule
                 where buf_schedule.cre-db-num = buf_schedule-attr.cre-db-num
                   and buf_schedule.task-type  = buf_schedule-attr.task-type
                   and buf_schedule.task-num   = buf_schedule-attr.task-num
            no-error.
            if not available buf_schedule
            then do:
                delete buf_schedule-attr.
            end.
        end.
    end.        /* for each buf_schedule-attr */
end.
END PROCEDURE. /* attach-attr-to-schedule-line */

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
  DISPLAY rs-1 ed-object rs-remote
      WITH FRAME Dialog-Frame.
  ENABLE rct-obj RECT-6 Btn_OK Btn_Cancel b-help rs-1 bt-sel-obj rs-remote
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-host-name Dialog-Frame
PROCEDURE get-host-name :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define output parameter p-host-name as character    no-undo.

define buffer buf_clients   for ub.clients.

    find first buf_clients no-lock
         where buf_clients.obj-type = {&cmp}
           and buf_clients.obj-code = v-host-code
    no-error.
    if not available buf_clients
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Не удалось найти текущую фирму"
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
               trim(error-status :get-message(4))
               trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return error .
    end.
    else do:
        assign
            p-host-name = buf_clients.obj-name
        .
    end.
end.
END PROCEDURE. /* get-host-name */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-fields Dialog-Frame
PROCEDURE init-fields :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
    define variable v-oper-num     as integer           no-undo.
    run manage-options          in this-procedure.
/*    assign*/
/*        rs-1 :screen-value in frame dialog-frame = "2"*/
/*        ed-object :screen-value in frame Dialog-frame = {&cmp} + string( v-host-code ) + " " + v-host-name*/
/*    .*/
/*    assign*/
/*        rs-1*/
/*    .*/
end.
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
define output parameter p-obj-list              as character    no-undo.
define output parameter p-rs-1                  as integer      no-undo.
define output parameter p-rs-remote             as integer      no-undo.

    define variable v-counter       as integer       no-undo.
    define variable v-param-list    as character     no-undo.

    run schedule-attr-value in this-procedure (
          input p-cre-db-num
        , input p-task-type
        , input p-task-num
        , input {&attr-schedule-obj-list-h}
        , output p-obj-list
        , output v-param-type
    ) .
    for each temp_obj-list
    :
        delete temp_obj-list.
    end.
    do v-counter = 1 to num-entries( p-obj-list ) / 2
    :
        create temp_obj-list.
        assign
            temp_obj-list.obj-type = entry( 2 * v-counter - 1,  p-obj-list )
            temp_obj-list.obj-code = integer( entry( 2 * v-counter,      p-obj-list ) )
        .
    end.
    run schedule-attr-value in this-procedure (
          input p-cre-db-num
        , input p-task-type
        , input p-task-num
        , input {&attr-schedule-param-list-h}
        , output v-param-list
        , output v-param-type
    ) .
    if v-param-list = ""
    then do:
        assign
            p-rs-1                  = 1
            p-rs-remote             = 0
        .
    end.
    else do:
        assign
            p-rs-1 = integer( entry( 1, v-param-list ) )
            p-rs-remote = integer( entry( 3, v-param-list ) )
        .


    end.
end.
END PROCEDURE. /* init-param-values */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE manage-options Dialog-Frame
PROCEDURE manage-options :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
assign
    rct-obj             :visible in frame {&frame-name} = yes
    rs-1                :visible in frame {&frame-name} = yes
    bt-sel-obj          :visible in frame {&frame-name} = yes
    ed-object           :visible in frame {&frame-name} = yes
.
run object-select in this-procedure (
    input rs-1
).

end.
END PROCEDURE. /* manage-options */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE object-select Dialog-Frame
PROCEDURE object-select :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-rs-1   as integer      no-undo.
case p-rs-1
:
    when 1
    then do:
        assign
            ed-object :screen-value in frame Dialog-frame = "Все объекты БД"
        .
    end.
    when 2
    then do:
        assign
            ed-object :screen-value = v-host-name
        .
    end.
    when 3
    then do:
        assign
            ed-object :screen-value = ""
        .
        for each temp_obj-list
        :
            assign
                ed-object :screen-value = ed-object :screen-value
                    + ( if ed-object :screen-value = "" then "" else ", " )
                    + temp_obj-list.obj-type + string( temp_obj-list.obj-code )
            .
        end.
    end.
end case.

end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE select-objects-only-this-db Dialog-Frame
PROCEDURE select-objects-only-this-db :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define output parameter p-only-this-db-obj-list as character    no-undo.
define output parameter p-exclude-obj-list      as character    no-undo.

    define variable v-db-num                as integer       no-undo.
    define variable v-obj-type              as character     no-undo.
    define variable v-obj-code              as integer       no-undo.

    define buffer buf_clients       for ub.clients.
    define buffer buf_temp_obj-list for temp_obj-list.
    define buffer buf_schedule for ub.schedule.

    assign
        p-only-this-db-obj-list = ""
        p-exclude-obj-list      = ""
    .
    if p-task-num > 0 then do:
      find first buf_schedule no-lock where
                buf_schedule.cre-db-num = p-cre-db-num
            and buf_schedule.task-type = p-task-type
            and buf_schedule.task-num = p-task-num no-error.
      if not available buf_schedule then do:
        undo, return error .
      end.
      assign
      v-db-num = ( if buf_schedule.db-num-char = "*" then -10 else integer( buf_schedule.db-num-char ) )
      .
    end.
    else do:
      v-db-num = v-cntxt-db-num.
    end.
    for each buf_temp_obj-list:
        find first buf_clients no-lock
                where buf_clients.obj-type = buf_temp_obj-list.obj-type
                and buf_clients.obj-code = buf_temp_obj-list.obj-code
        .
        if buf_schedule.db-num-char = "*"
        or buf_clients.db-num = v-db-num
        then do:
            assign
                p-only-this-db-obj-list = p-only-this-db-obj-list
                                        + ( if p-only-this-db-obj-list <> "" then ", " else "" )
                                        + buf_temp_obj-list.obj-type + string( buf_temp_obj-list.obj-code )
            .
        end.
        else do:
            assign
                p-exclude-obj-list = p-exclude-obj-list
                                        + ( if p-exclude-obj-list <> "" then ", " else "" )
                                        + buf_temp_obj-list.obj-type + string( buf_temp_obj-list.obj-code )
            .
            delete buf_temp_obj-list.
        end.
    end.
end.
END PROCEDURE. /* select-objects-only-this-db */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME