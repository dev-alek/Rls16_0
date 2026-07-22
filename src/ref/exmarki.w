&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame

/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE tt-ex-mark NO-UNDO LIKE ub.ex-mark.


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Корректировка акцизной или специальной марки

Автор: Хныкин Павел Андреевич
Дата создания: 03/01/06
Author: Pavel Khnykin
Creation date: 03/01/06

*/

define input parameter parParentProc as widget-handle no-undo.
define input parameter p-mode        as character no-undo.
define input parameter p-mark-type   as integer no-undo.
define input-output parameter p-rec  as recid no-undo.

def var vss-revision    as character no-undo init "$Revision$":U .
def var vss-author      as character no-undo init "$Author$":U .
def var vss-date        as character no-undo init "$Date$":U .
def var vss-workfile    as character no-undo init "$Workfile$":U .
def var vss-archive     as character no-undo init "$Archive$":U .
def var vss-description as character no-undo init "Корректировка акцизной или специальной марки".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }

define variable v-db-num like ub.db.db-num no-undo.

define buffer locked_ex-mark for ub.ex-mark.
define buffer locked_ex-mark-attr for ub.ex-mark-attr.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-ex-mark

/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define FIELDS-IN-QUERY-Dialog-Frame tt-ex-mark.mark-name ~
tt-ex-mark.db-num tt-ex-mark.mark-code
&Scoped-define ENABLED-FIELDS-IN-QUERY-Dialog-Frame tt-ex-mark.mark-name
&Scoped-define ENABLED-TABLES-IN-QUERY-Dialog-Frame tt-ex-mark
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-Dialog-Frame tt-ex-mark
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH tt-ex-mark SHARE-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH tt-ex-mark SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame tt-ex-mark
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame tt-ex-mark


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS tt-ex-mark.mark-name
&Scoped-define ENABLED-TABLES tt-ex-mark
&Scoped-define FIRST-ENABLED-TABLE tt-ex-mark
&Scoped-Define ENABLED-OBJECTS B-exit B-quit B-Help r-mark-type ~
FILL-IN-Date-to 
&Scoped-Define DISPLAYED-FIELDS tt-ex-mark.mark-name tt-ex-mark.db-num ~
tt-ex-mark.mark-code
&Scoped-define DISPLAYED-TABLES tt-ex-mark
&Scoped-define FIRST-DISPLAYED-TABLE tt-ex-mark
&Scoped-Define DISPLAYED-OBJECTS r-mark-type FILL-IN-Date-to FILL-IN-Descr 

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

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE FILL-IN-Date-to AS DATE FORMAT "99/99/9999":U INITIAL ? 
     LABEL "Действительна до" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE FILL-IN-Descr AS CHARACTER FORMAT "X(256)":U INITIAL "Тип марки:"
      VIEW-AS TEXT
     SIZE 10.6 BY .67 NO-UNDO.

DEFINE VARIABLE r-mark-type AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Специальная", 0,
"Акцизная", 1
     SIZE 22 BY 1.62 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY Dialog-Frame FOR
      tt-ex-mark SCROLLING.
&ANALYZE-RESUME

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     B-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 50.6
     tt-ex-mark.mark-name AT ROW 4.71 COL 24 COLON-ALIGNED
          LABEL "Код марки" FORMAT "X(20)"
          VIEW-AS FILL-IN
          SIZE 30.6 BY 1
     r-mark-type AT ROW 6.05 COL 26 NO-LABEL
     FILL-IN-Date-to AT ROW 7.91 COL 24 COLON-ALIGNED WIDGET-ID 2
     tt-ex-mark.db-num AT ROW 2.62 COL 24 COLON-ALIGNED
          LABEL "Код БД создания"
           VIEW-AS TEXT
          SIZE 5.6 BY .67
          FGCOLOR 4
     tt-ex-mark.mark-code AT ROW 3.67 COL 24 COLON-ALIGNED
          LABEL "Внутренний код"
           VIEW-AS TEXT
          SIZE 10 BY .67
          FGCOLOR 4
     FILL-IN-Descr AT ROW 6.05 COL 13 COLON-ALIGNED NO-LABEL
     SPACE(37.59) SKIP(2.75)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Акцизная или специальная марка"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON B-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: tt-ex-mark T "?" NO-UNDO ub ex-mark
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

/* SETTINGS FOR FILL-IN tt-ex-mark.db-num IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN FILL-IN-Descr IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN tt-ex-mark.mark-code IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN tt-ex-mark.mark-name IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "Temp-Tables.tt-ex-mark"
     _Options          = "SHARE-LOCK"
     _Query            is OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Акцизная или специальная марка */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Ввод */
DO:
  { gbl/stdbtn.i }

  if p-mode = {&lookup} then return no-apply.

  do on error undo, return no-apply:
    run proc-save in this-procedure.
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

assign frame {&frame-name}:title = frame {&frame-name}:title + " - " + p-mode.

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

  if p-mode <> {&add-def} and
     p-mode <> {&update}  and
     p-mode <> {&lookup}
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неверное значение параметров вызова p-mode"  p-mode
      view-as alert-box error.
    return error.
  end.

  /* Проверяем существование записи (для режима просмотра) */
  if p-mode = {&lookup} then do:
    find first locked_ex-mark no-lock
      where recid(locked_ex-mark) = p-rec no-error .
    if not available locked_ex-mark then do:
      message
        "Не найдена запись Акцизной или Специальной марки"
        view-as alert-box error.
        return error.
    end.
  end.

  /* Пытаемся заблокировать запись (для режима обновления) */
  if p-mode = {&update} then
  do transaction on error undo, return error:
    find first locked_ex-mark exclusive-lock
      where recid(locked_ex-mark) = p-rec no-error no-wait.
    if not available locked_ex-mark then do:
      if locked locked_ex-mark then do:
        message "Запись редактируется другим пользователем"
          view-as alert-box error.
      end.
      else do:
        message "Не найдена запись Акцизной или Специальной марки"
          view-as alert-box error.
      end.
      return error.
    end.
  end. /* do transaction - запись остается share-locked */

  create tt-ex-mark.
  if p-mode = {&add-def} then do:
    { gbl/curdbnum.i v-db-num }
    assign
      tt-ex-mark.db-num    = v-db-num
      tt-ex-mark.mark-code = 0
      tt-ex-mark.mark-type = 0
    .
    /* Если при добавлении записи в браузе установлен фильтр по типу,
       то в форме редактирования устанавливаем тот же тип */
    if p-mark-type <> ? then do:
      assign
        tt-ex-mark.mark-type = p-mark-type
      .
    end.
  end.
  else do:
    buffer-copy locked_ex-mark to tt-ex-mark.
  end.

  run MyEnable in this-procedure.

  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
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
  DISPLAY r-mark-type FILL-IN-Date-to FILL-IN-Descr 
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-ex-mark THEN
    DISPLAY tt-ex-mark.mark-name tt-ex-mark.db-num tt-ex-mark.mark-code
      WITH FRAME Dialog-Frame.
  ENABLE B-exit B-quit B-Help tt-ex-mark.mark-name r-mark-type FILL-IN-Date-to 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
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

  if available tt-ex-mark then do:
    r-mark-type = tt-ex-mark.mark-type.
  end.

  /* Марка действительна до */
  find first locked_ex-mark-attr no-lock 
    where locked_ex-mark-attr.db-num = tt-ex-mark.db-num
    and locked_ex-mark-attr.mark-code = tt-ex-mark.mark-code
    and locked_ex-mark-attr.attr-code = "exp-date" no-error.
  if available locked_ex-mark-attr then do:
    FILL-IN-Date-to = date(locked_ex-mark-attr.attr-value).
  end.

  display
    tt-ex-mark.db-num
    tt-ex-mark.mark-code
    tt-ex-mark.mark-name
    r-mark-type
    FILL-IN-Date-to
   with frame {&frame-name}.

  view frame {&frame-name}.

  enable B-quit B-Help
    with frame {&frame-name}.

  if p-mode = {&lookup} then do:
    assign
      b-exit:label  = "&Выход"
    .
    hide b-quit in frame {&frame-name}.
  end.
  else do:
    enable B-exit
           tt-ex-mark.mark-name
           r-mark-type when p-mark-type = ? /* В браузе фильтр "Все" */
           FILL-IN-Date-to
      with frame {&frame-name}.
    apply "entry" to tt-ex-mark.mark-name in frame {&frame-name}.
  end.

  return.

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
  define variable v-new-code like ex-mark.mark-code no-undo.

  define buffer buf_ex-mark for ub.ex-mark.
  if p-mode = {&lookup} then do:
      return error.
  end.

  assign frame {&frame-name}
    tt-ex-mark.mark-name
    r-mark-type
    FILL-IN-Date-to
  .

  /* Предварительные проверки */
  if tt-ex-mark.mark-name = "":U then do:
    message "Не указан код марки"
      view-as alert-box error.
    apply "entry" to tt-ex-mark.mark-name in frame {&frame-name}.
    return error.
  end.

  find first buf_ex-mark no-lock
    where buf_ex-mark.mark-name = tt-ex-mark.mark-name
      and buf_ex-mark.stts      = integer({&current-status-int})
      and (p-mode = {&add-def} or p-rec <> recid(buf_ex-mark))
    no-error.
  if available buf_ex-mark then do:
    message substitute("Уже существует &1 марка с указанным кодом"
                      , (if buf_ex-mark.mark-type = 0 then "Специальная"
                                                      else "Акцизная")
                      )
      view-as alert-box error.
    apply "entry" to tt-ex-mark.mark-name in frame {&frame-name}.
    return error.
  end.

  /* Создание/Обновление записи в базе */
  do on error undo, return error
     on stop  undo, return error
    :
    if p-mode = {&add-def} then do:
      create locked_ex-mark.
      assign
        locked_ex-mark.db-num    = v-db-num
        locked_ex-mark.mark-code = NEXT-VALUE( s-ex-mark, {&db-name_schema} )
      .
      if FILL-IN-Date-to <> ? then do:
        create locked_ex-mark-attr.
        assign
        locked_ex-mark-attr.db-num = locked_ex-mark.db-num
        locked_ex-mark-attr.mark-code = locked_ex-mark.mark-code
        locked_ex-mark-attr.attr-code = "exp-date"
        locked_ex-mark-attr.attr-value = string(FILL-IN-Date-to).
      end.
    end.
    else do:
      find current locked_ex-mark exclusive-lock.
      
      /* Найём дату */
      find first locked_ex-mark-attr exclusive-lock 
            where locked_ex-mark-attr.db-num = locked_ex-mark.db-num
              and locked_ex-mark-attr.mark-code = locked_ex-mark.mark-code
              and locked_ex-mark-attr.attr-code = "exp-date" no-error.
      
      /* Если не было и что-то поставили, то создадим */
      if not available(locked_ex-mark-attr) and FILL-IN-Date-to <> ? then do:
            create locked_ex-mark-attr.
            assign
            locked_ex-mark-attr.db-num = locked_ex-mark.db-num
            locked_ex-mark-attr.mark-code = locked_ex-mark.mark-code
            locked_ex-mark-attr.attr-code = "exp-date"
            locked_ex-mark-attr.attr-value = string(FILL-IN-Date-to).
      end.
      /* Если обнуление */
      else do:
        if FILL-IN-Date-to <> ? then
        locked_ex-mark-attr.attr-value = string(FILL-IN-Date-to).
      end.
    end.

    assign
      locked_ex-mark.mark-type = r-mark-type
      locked_ex-mark.mark-name = tt-ex-mark.mark-name
    .
    p-rec = recid(locked_ex-mark).

    release locked_ex-mark no-error.
    if error-status:error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при сохранении записи Акцизной или Специальной марки" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error.
    end.
  end.

  return.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
