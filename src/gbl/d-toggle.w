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

Универсальный диалог для задания вопроса и наборов действий.

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/25/05
Author: Bakhtadze Natalya
Creation date: 04/25/05

Показаны флаги с описаниями

Возвращается значение: строка со списком выбранных опций

При нажатии Escape возвращается "":U

Если в диалоге задана всего одна кнопка, то
p-default-toggle может совпадать p-cancel-toggle

Если текст описания не задан, то пустой editor описания не показывается на экране,
а размер флага в этом случае автоматически меняется для того,
чтобы был виден весь текст флага .
Но при этом размер флага ограничен размерами диалога .

После текста флага можно указать атрибут для того, чтобы флаг была недоступна

В данный момент доступны следующие атрибуты
  disable - Показать флаг, но сделать его недоступным для выбора

Примеры  использования:
define variable v-num as integer no-undo .
run gbl/d-toggle.w
  (input "Вопрос" /* Заголовок окна */
  ,input "Кажется придется сделать очень ответственную операцию." + {&new-line} /* Общее сообщение */
    + "Вы действительно хотите сделать это?" + {&new-line}
  ,input "|^" /* Символы разделители для кодирования двух следующих параметров */
              /* первый символ - разделитель списков названий флагов и описаний флагов */
              /* второй символ - разделитель атрибутов в описании флагов */
  ,input "Для всех|Для выбранных^disable" /* список названий флагов  */
                                  /* каждый флаг может иметь необязательный */
                                  /* список атрибутов, влияющих на поведение кнопки */
  ,input "Обрабатываем все элементы|" /* список описаний кнопок */
       + "Обрабатываем выбранные элементы. Доступно если выбран хотя бы один элемент"
  ,input "yes,no,yes" /*начальные значени флагов*/
  ,output v-str /* выбор пользователя */
  ).
message v-list view-as alert-box .

Пример задания вопроса о какие опции выбрать:

define variable v-num as integer no-undo .
run gbl/d-toggle.w
  (input "Вопрос" /* Заголовок окна */
  ,input "Выбрать оцпию." + {&new-line} /* Общее сообщение */
  ,input "|^" /* Символы разделители для кодирования двух следующих параметров */
  ,input "Опция 1|Опция 2|Опция 3" /* список названий флагов  */
  ,input "Описание опции 1|" /* список описаний флагов */
       + "Описание опции 2|"
       + "Описание опции 3"
  ,input "yes,no,yes" /*начальные значени флагов*/
  ,output v-list /* выбор пользователя */
  ).
message v-list view-as alert-box .

------------------------------------------------------------------------*/

/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input  parameter p-title               as character no-undo .
define input  parameter p-text                as character no-undo .
define input  parameter p-delimiter           as character no-undo .
define input  parameter p-toggles             as character no-undo .
define input  parameter p-toggles-description as character no-undo .
define input  parameter p-toggles-init        as character no-undo .
define output parameter p-list                as character no-undo .


/* Local Variable Definitions ---                                       */
def var vss-revision    as character no-undo init "$Revision$":U .
def var vss-author      as character no-undo init "$Author$":U .
def var vss-date        as character no-undo init "$Date$":U .
def var vss-workfile    as character no-undo init "$Workfile$":U .
def var vss-archive     as character no-undo init "$Archive$":U .
def var vss-description as character no-undo init "Универсальный диалог для задания вопроса и наборов действий.".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i }

define variable v-toggles    as integer no-undo.
define variable v-need-confirm as logical no-undo extent 9 .

define variable v-first-delimiter  as character no-undo init "|" .
define variable v-second-delimiter as character no-undo init "^" .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit b-quit EDITOR-1 B-Help
&Scoped-Define DISPLAYED-OBJECTS EDITOR-1 T-2

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

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE description-1 AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 61.75 BY 1.54 NO-UNDO.

DEFINE VARIABLE description-2 AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 61.75 BY 1.54 NO-UNDO.

DEFINE VARIABLE description-3 AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 61.75 BY 1.54 NO-UNDO.

DEFINE VARIABLE description-4 AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 61.75 BY 1.54 NO-UNDO.

DEFINE VARIABLE description-5 AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 61.75 BY 1.54 NO-UNDO.

DEFINE VARIABLE description-6 AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 61.75 BY 1.54 NO-UNDO.

DEFINE VARIABLE description-7 AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 61.75 BY 1.54 NO-UNDO.

DEFINE VARIABLE description-8 AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 61.75 BY 1.54 NO-UNDO.

DEFINE VARIABLE description-9 AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 61.75 BY 1.54 NO-UNDO.

DEFINE VARIABLE EDITOR-1 AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 57.25 BY 2.75
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE T-1 AS LOGICAL INITIAL no
     LABEL "1"
     VIEW-AS TOGGLE-BOX
     SIZE 35.5 BY 1 NO-UNDO.

DEFINE VARIABLE T-2 AS LOGICAL INITIAL no
     LABEL "2"
     VIEW-AS TOGGLE-BOX
     SIZE 35.5 BY 1 NO-UNDO.

DEFINE VARIABLE T-3 AS LOGICAL INITIAL no
     LABEL "3"
     VIEW-AS TOGGLE-BOX
     SIZE 35.5 BY 1 NO-UNDO.

DEFINE VARIABLE T-4 AS LOGICAL INITIAL no
     LABEL "4"
     VIEW-AS TOGGLE-BOX
     SIZE 35.5 BY 1 NO-UNDO.

DEFINE VARIABLE T-5 AS LOGICAL INITIAL no
     LABEL "5"
     VIEW-AS TOGGLE-BOX
     SIZE 35.5 BY 1 NO-UNDO.

DEFINE VARIABLE T-6 AS LOGICAL INITIAL no
     LABEL "6"
     VIEW-AS TOGGLE-BOX
     SIZE 35.5 BY 1 NO-UNDO.

DEFINE VARIABLE T-7 AS LOGICAL INITIAL no
     LABEL "7"
     VIEW-AS TOGGLE-BOX
     SIZE 35.5 BY 1 NO-UNDO.

DEFINE VARIABLE T-8 AS LOGICAL INITIAL no
     LABEL "8"
     VIEW-AS TOGGLE-BOX
     SIZE 35.5 BY 1 NO-UNDO.

DEFINE VARIABLE T-9 AS LOGICAL INITIAL no
     LABEL "9"
     VIEW-AS TOGGLE-BOX
     SIZE 35.5 BY 1 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     EDITOR-1 AT ROW 1 COL 22.5 NO-LABEL
     B-Help AT ROW 1 COL 81
     T-1 AT ROW 4 COL 1.5
     description-1 AT ROW 4 COL 37.25 NO-LABEL
     T-2 AT ROW 6 COL 1.5
     description-2 AT ROW 6 COL 37.25 NO-LABEL
     T-3 AT ROW 8 COL 1.5
     description-3 AT ROW 8 COL 37.25 NO-LABEL
     T-4 AT ROW 10 COL 1.5
     description-4 AT ROW 10 COL 37.25 NO-LABEL
     T-5 AT ROW 12 COL 1.5
     description-5 AT ROW 12 COL 37.25 NO-LABEL
     T-6 AT ROW 14 COL 1.5
     description-6 AT ROW 14 COL 37.25 NO-LABEL
     T-7 AT ROW 16 COL 1.5
     description-7 AT ROW 16 COL 37.25 NO-LABEL
     T-8 AT ROW 18 COL 1.5
     description-8 AT ROW 18 COL 37.25 NO-LABEL
     T-9 AT ROW 20 COL 1.5
     description-9 AT ROW 20 COL 37.25 NO-LABEL
     SPACE(0.24) SKIP(0.49)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "<insert dialog title>"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.


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

/* SETTINGS FOR EDITOR description-1 IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       description-1:HIDDEN IN FRAME Dialog-Frame           = TRUE
       description-1:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR EDITOR description-2 IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       description-2:HIDDEN IN FRAME Dialog-Frame           = TRUE
       description-2:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR EDITOR description-3 IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       description-3:HIDDEN IN FRAME Dialog-Frame           = TRUE
       description-3:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR EDITOR description-4 IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       description-4:HIDDEN IN FRAME Dialog-Frame           = TRUE
       description-4:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR EDITOR description-5 IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       description-5:HIDDEN IN FRAME Dialog-Frame           = TRUE
       description-5:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR EDITOR description-6 IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       description-6:HIDDEN IN FRAME Dialog-Frame           = TRUE
       description-6:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR EDITOR description-7 IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       description-7:HIDDEN IN FRAME Dialog-Frame           = TRUE
       description-7:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR EDITOR description-8 IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       description-8:HIDDEN IN FRAME Dialog-Frame           = TRUE
       description-8:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR EDITOR description-9 IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       description-9:HIDDEN IN FRAME Dialog-Frame           = TRUE
       description-9:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

ASSIGN
       EDITOR-1:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR TOGGLE-BOX T-1 IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       T-1:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR TOGGLE-BOX T-2 IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       T-2:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR TOGGLE-BOX T-3 IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       T-3:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR TOGGLE-BOX T-4 IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       T-4:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR TOGGLE-BOX T-5 IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       T-5:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR TOGGLE-BOX T-6 IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       T-6:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR TOGGLE-BOX T-7 IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       T-7:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR TOGGLE-BOX T-8 IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       T-8:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR TOGGLE-BOX T-9 IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       T-9:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* <insert dialog title> */
DO:
    /* запрещаем закрывать окно */
  /* пользователь должен нажать Excape */
  RETURN NO-APPLY .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Ввод */
DO:
  ASSIGN
  t-1 WHEN t-1:visible
  t-2 WHEN t-2:visible
  t-3 WHEN t-3:visible
  t-4 WHEN t-4:visible
  t-5 WHEN t-5:visible
  t-6 WHEN t-6:visible
  t-7 WHEN t-7:visible
  t-8 WHEN t-8:visible
  t-9 WHEN t-9:visible
  .
  ASSIGN
  p-list = (IF t-1:VISIBLE THEN (STRING(t-1) + v-first-delimiter) ELSE "":U) +
           (IF t-1:VISIBLE THEN (STRING(t-2) + v-first-delimiter) ELSE "":U) +
           (IF t-1:VISIBLE THEN (STRING(t-3) + v-first-delimiter) ELSE "":U) +
           (IF t-1:VISIBLE THEN (STRING(t-4) + v-first-delimiter) ELSE "":U) +
           (IF t-1:VISIBLE THEN (STRING(t-5) + v-first-delimiter) ELSE "":U) +
           (IF t-1:VISIBLE THEN (STRING(t-6) + v-first-delimiter) ELSE "":U) +
           (IF t-1:VISIBLE THEN (STRING(t-7) + v-first-delimiter) ELSE "":U) +
           (IF t-1:VISIBLE THEN (STRING(t-8) + v-first-delimiter) ELSE "":U) +
           (IF t-1:VISIBLE THEN (STRING(t-9) + v-first-delimiter) ELSE "":U)
  p-list = right-trim(p-list, v-first-delimiter)
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
on cursor-left anywhere do:
  apply "back-tab":u to focus .
end.

on cursor-right anywhere do:
  apply "tab":u to focus .
end.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  RUN Myenable.
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
  DISPLAY EDITOR-1 T-2
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit EDITOR-1 B-Help
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
DEFINE VARIABLE v-bottom AS DECIMAL NO-UNDO.
do with frame {&frame-name}:

  assign
    frame {&frame-name} :title = p-title
  .
  v-bottom = editor-1:FRAME-ROW + editor-1:HEIGHT-CHARS.
  if length (p-delimiter) >= 1 then do:
    assign
      v-first-delimiter = substring(p-delimiter, 1, 1)
    .
  end.

  if length (p-delimiter) >= 2 then do:
    assign
      v-second-delimiter = substring(p-delimiter, 2, 1)
    .
  end.


  assign
    v-toggles = num-entries(p-toggles, v-first-delimiter)
    editor-1 = p-text
  .

  if v-toggles > 9 then do:
    message
      vss-workfile vss-revision vss-description skip
      "Количество флагов больше 9" skip
      "p-toggles" p-toggles skip
      view-as alert-box .
    undo, return error .
  end.
  if v-toggles <> num-entries(p-toggles-description, v-first-delimiter) then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Количество описаний флагов не совпадает с количеством флагов" skip
      "флагов" v-toggles skip
      "Описаний флагов" num-entries(p-toggles-description) skip
      view-as alert-box error .
    undo, return error .
  end.
  if v-toggles <> num-entries(p-toggles-init, v-first-delimiter) then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Количество начальных значений флагов не совпадает с количеством флагов" skip
      "флагов" v-toggles skip
      "Начальных значений флагов" num-entries(p-toggles-init) skip
      view-as alert-box error .
    undo, return error .
  end.

  define variable v-toggle-handle             as handle no-undo extent 9 .
  define variable v-toggle-description-handle as handle no-undo extent 9 .
  assign
    v-toggle-handle[1]             = t-1         :handle
    v-toggle-handle[2]             = t-2         :handle
    v-toggle-handle[3]             = t-3         :handle
    v-toggle-handle[4]             = t-4         :handle
    v-toggle-handle[5]             = t-5         :handle
    v-toggle-handle[6]             = t-6         :handle
    v-toggle-handle[7]             = t-7         :handle
    v-toggle-handle[8]             = t-8         :handle
    v-toggle-handle[9]             = t-9         :handle
    v-toggle-description-handle[1] = description-1 :handle
    v-toggle-description-handle[2] = description-2 :handle
    v-toggle-description-handle[3] = description-3 :handle
    v-toggle-description-handle[4] = description-4 :handle
    v-toggle-description-handle[5] = description-5 :handle
    v-toggle-description-handle[6] = description-6 :handle
    v-toggle-description-handle[7] = description-7 :handle
    v-toggle-description-handle[8] = description-8 :handle
    v-toggle-description-handle[9] = description-9 :handle
      .

  define variable v-handle             as handle no-undo .
  define variable v-handle-description as handle no-undo .


  define variable ind as integer no-undo .
  do ind = 1 to v-toggles
  :
    assign
      v-handle             = v-toggle-handle[ind]
      v-handle-description = v-toggle-description-handle[ind]
    .

    define variable v-toggle-text      as character no-undo .
    define variable v-description-text as character no-undo .
    define variable l-sensitive        as logical no-undo .
    define variable l-confirm          as logical no-undo .
    define variable v-btn-text-ind     as integer no-undo .

    assign
      v-toggle-text      = entry(ind, p-toggles, v-first-delimiter)
      v-description-text = entry(ind, p-toggles-description, v-first-delimiter)
      l-sensitive        = true
      l-confirm          = false
    .

    define variable v-toggle-attribute as character no-undo .

    do v-btn-text-ind = 2 to num-entries(v-toggle-text, v-second-delimiter )
    :
      assign
        v-toggle-attribute = entry(v-btn-text-ind, v-toggle-text, v-second-delimiter)
      .

      case v-toggle-attribute :
        when 'disable' then do:
          assign
            l-sensitive = false
          .
        end.
        otherwise do:
          message
            vss-workfile vss-revision vss-description skip
            "Неизвестный атрибут флаг" skip
            "Атрибут" v-toggle-attribute skip
            "Описание флага" ind skip
            v-toggle-text skip
            view-as alert-box error .
        end.
      end case .
    end.

    if num-entries (v-toggle-text, v-second-delimiter ) >= 1 then do:
      assign
        v-toggle-text = entry(1, v-toggle-text, v-second-delimiter)
      .
    end.

    assign
      v-handle :label     = v-toggle-text
      v-handle :visible   = true
      v-handle :sensitive = l-sensitive
    .
    v-bottom = v-handle:frame-row + v-handle:HEIGHT-CHARS.
    v-handle:screen-value = entry(ind, p-toggles-init, v-first-delimiter).

    if v-description-text = "" then do:
      assign
        v-handle :width = min(max(v-handle :width
                                 ,length(v-toggle-text) + 2
                                 )
                             ,frame {&frame-name} :width - v-handle :column - 1
                             )
       .
    end.

    if v-description-text <> "" then do:
      assign
        v-handle-description :visible      = true
        v-handle-description :sensitive    = true
        v-handle-description :read-only    = true
        v-handle-description :screen-value = v-description-text

      .
    end.
  end.

end.
ASSIGN
FRAME {&FRAME-NAME}:HEIGHT-CHARS = v-bottom + 2
    .
DISPLAY
EDITOR-1
WITH FRAME {&frame-name}.
ENABLE
B-exit
b-quit
EDITOR-1
B-Help
WITH FRAME {&frame-name}.
VIEW FRAME {&frame-name}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
