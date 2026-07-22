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

Универсальный диалог для задания вопроса и выбора действия.

Автор: Перваков Михаил Сергеевич
Дата создания: 05/24/00
Author: Mikhail Pervakov
Creation date: 05/24/00

Возвращается значение:
  p-number  номер выбранной пользователем кнопки

При нажании Enter  возвращается p-default-button
При нажатии Escape возвращается p-cancel-button

Если в диалоге задана всего одна кнопка, то
p-default-button может совпадать p-cancel-button

Если текст описания не задан, то пустой editor описания не показывается на экране,
а размер кнопки в этом случае автоматически меняется для того,
чтобы был виден весь текст кнопки .
Но при этом размер кнопки ограничен размерами диалога .

После текста кнопки можно указать атрибут для того, чтобы кнопка была недоступна

В данный момент доступны следующие атрибуты
  disable - Показать кнопку, но сделать ее недоступной для выбора
  confirm - При выборе кнопки пользователь должен подтвердить свой выбор

Примеры  использования:
define variable v-num as integer no-undo .
run gbl/d-askw.w
  (input "Вопрос[|код сообщения для автоответа]" /* Заголовок окна */
  ,input "Кажется придется сделать очень ответственную операцию." + {&new-line} /* Общее сообщение */
    + "Вы действительно хотите сделать это?" + {&new-line}
  ,input "|^" /* Символы разделители для кодирования двух следующих параметров */
              /* первый символ - разделитель списков названий кнопок и описаний кнопок */
              /* второй символ - разделитель атрибутов в описании кнопок */
  ,input "Для всех^confirm|Для выбранных^disable|Отказ" /* список названий кнопок  */
                                  /* каждая кнопка может иметь необязательный */
                                  /* список атрибутов, влияющих на поведение кнопки */
  ,input "Обрабатываем все элементы|" /* список описаний кнопок */
       + "Обрабатываем выбранные элементы. Доступно если выбран хотя бы один элемент|"
       + "Отказ от выполнения операции"
  ,input 2 /* значение возвращаемое при нажатии enter */
  ,input 3 /* значение возвращаемое при нажатии escape */
  ,output v-num /* выбор пользователя */
  ).
message v-num view-as alert-box .


Пример задания вопроса о том сохранять ли измененные данные при выходе из окна:

define variable v-num as integer no-undo .
run gbl/d-askw.w
  (input "Вопрос" /* Заголовок окна */
  ,input "Данные были изменены." + {&new-line} /* Общее сообщение */
    + "Вы хотите сохранить данные и выйти из окна?" + {&new-line}
  ,input "|^" /* Символы разделители для кодирования двух следующих параметров */
  ,input "Да|Нет^confirm|Отменить" /* список названий кнопок  */
  ,input "Сохранить данные и закрыть окно|" /* список описаний кнопок */
       + "Не сохранять данные и закрыть окно|"
       + "Не закрывать окно"
  ,input 1 /* значение возвращаемое при нажатии enter */
  ,input 3 /* значение возвращаемое при нажатии escape */
  ,output v-num /* выбор пользователя */
  ).
message v-num view-as alert-box .


*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input  parameter p-title               as character no-undo .
define input  parameter p-text                as character no-undo .
define input  parameter p-delimiter           as character no-undo .
define input  parameter p-buttons             as character no-undo .
define input  parameter p-buttons-description as character no-undo .
define input  parameter p-default-button      as integer   no-undo .
define input  parameter p-cancel-button       as integer   no-undo .
define output parameter p-number              as integer   no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Универсальный диалог для задания вопроса и выбора действия".
{ cmp/vssrevis.i "substitute('&1|&2':u,p-buttons,p-text)" }
{ cmp/showinf.i  }
define variable mCodeMes    as char no-undo.
if num-entries(p-title,"|") > 1
then
assign
   mCodeMes = entry(2,p-title,"|")
   p-title  = entry(1,p-title,"|")
.
define variable v-buttons    as integer no-undo.
define variable v-need-confirm as logical no-undo extent 5 .

define variable v-first-delimiter  as character no-undo init "|" .
define variable v-second-delimiter as character no-undo init "^" .

/* Local Variable Definitions ---                                       */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-help EDITOR-1 
&Scoped-Define DISPLAYED-OBJECTS EDITOR-1 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-help 
     LABEL "Помо&щь" 
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON Btn_1 AUTO-GO 
     LABEL "&1" 
     SIZE 15 BY 1
     BGCOLOR 8 .

DEFINE BUTTON Btn_2 AUTO-GO 
     LABEL "&2" 
     SIZE 15 BY 1
     BGCOLOR 8 .

DEFINE BUTTON Btn_3 AUTO-GO 
     LABEL "&3" 
     SIZE 15 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE description-1 AS CHARACTER 
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 45.8 BY 3.19 NO-UNDO.

DEFINE VARIABLE description-2 AS CHARACTER 
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 45.8 BY 3.19 NO-UNDO.

DEFINE VARIABLE description-3 AS CHARACTER 
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 45.8 BY 3.19 NO-UNDO.

DEFINE VARIABLE EDITOR-1 AS CHARACTER 
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 62 BY 5.38
     FGCOLOR 4  NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     Btn_1 AT ROW 7.14 COL 3
     Btn_2 AT ROW 10.81 COL 3
     Btn_3 AT ROW 14.48 COL 3
     b-help AT ROW 1 COL 65.2
     EDITOR-1 AT ROW 1.33 COL 3 NO-LABEL
     description-1 AT ROW 7.14 COL 64 RIGHT-ALIGNED NO-LABEL
     description-2 AT ROW 10.81 COL 19.2 NO-LABEL
     description-3 AT ROW 14.52 COL 19.2 NO-LABEL
     SPACE(3.59) SKIP(1.04)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Вопрос".


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
   FRAME-NAME Custom                                                    */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR BUTTON Btn_1 IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN 
       Btn_1:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR BUTTON Btn_2 IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN 
       Btn_2:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR BUTTON Btn_3 IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN 
       Btn_3:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR EDITOR description-1 IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE ALIGN-R                                         */
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

ASSIGN 
       EDITOR-1:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Вопрос */
DO:
  /* запрещаем закрывать окно */
  /* пользователь должен нажать Excape */
  RETURN NO-APPLY .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_1 Dialog-Frame
ON CHOOSE OF Btn_1 IN FRAME Dialog-Frame /* 1 */
DO:
  if v-need-confirm [1] then do:
    define variable lok as logical no-undo .
    assign
      lok = false
    .
    message
      self :label skip
      "" (if description-1 :visible
       then description-1 :screen-value
       else ""
      ) skip
      "Продолжить?"
      view-as alert-box question buttons yes-no update lok .
    if lok <> true then do:
      return no-apply .
    end.
  end.

  assign
    p-number = 1
  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_2 Dialog-Frame
ON CHOOSE OF Btn_2 IN FRAME Dialog-Frame /* 2 */
DO:
  if v-need-confirm [2] then do:
    define variable lok as logical no-undo .
    assign
      lok = false
    .
    message
      self :label skip
      "" (if description-2 :visible
       then description-2 :screen-value
       else ""
      ) skip
      "Продолжить?"
      view-as alert-box question buttons yes-no update lok .
    if lok <> true then do:
      return no-apply .
    end.
  end.

  assign
    p-number = 2
  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_3
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_3 Dialog-Frame
ON CHOOSE OF Btn_3 IN FRAME Dialog-Frame /* 3 */
DO:
  if v-need-confirm [3] then do:
    define variable lok as logical no-undo .
    assign
      lok = false
    .
    message
      self :label skip
      "" (if description-3 :visible
       then description-3 :screen-value
       else ""
      ) skip
      "Продолжить?"
      view-as alert-box question buttons yes-no update lok .
    if lok <> true then do:
      return no-apply .
    end.
  end.

  assign
    p-number = 3
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

do with frame {&frame-name}:

  assign
    frame {&frame-name} :title = p-title
  .

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
    v-buttons = num-entries(p-buttons, v-first-delimiter)
    editor-1 = p-text
  .

  if v-buttons > 5 then do:
    message
      vss-workfile vss-revision vss-description skip
      "Количество кнопок больше четырех" skip
      "p-buttons" p-buttons skip
      view-as alert-box .
    undo, return error .
  end.

  if v-buttons <> num-entries(p-buttons-description, v-first-delimiter) then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Количество описаний кнопок не совпадает с количество кнопок" skip
      "Кнопок" v-buttons skip
      "Описаний кнопок" num-entries(p-buttons-description) skip
      view-as alert-box error .
    undo, return error .
  end.

  define variable v-button-handle             as handle no-undo extent 3 .
  define variable v-button-description-handle as handle no-undo extent 3 .
  assign
    v-button-handle[1]             = Btn_1         :handle
    v-button-handle[2]             = Btn_2         :handle
    v-button-handle[3]             = Btn_3         :handle
    v-button-description-handle[1] = description-1 :handle
    v-button-description-handle[2] = description-2 :handle
    v-button-description-handle[3] = description-3 :handle
  .

  define variable v-handle             as handle no-undo .
  define variable v-handle-description as handle no-undo .

  if  p-default-button > 0
  and p-default-button <= v-buttons
  then do:
    assign
      v-handle = v-button-handle[p-default-button]
    .
    assign
      v-handle :default = true
      frame {&frame-name} :default-button = v-handle
    .
  end.
  else do:
    message
      vss-workfile vss-revision vss-description skip
      "Не задана кнопка по умолчанию" skip
      "p-default-button" p-default-button skip
      view-as alert-box .
    undo, return error .
  end.

  if  p-cancel-button > 0
  and p-cancel-button <= v-buttons
  then do:
    assign
      v-handle = v-button-handle[p-cancel-button]
    .
    assign
      frame {&frame-name} :cancel-button = v-handle
    .
  end.
  else do:
    message
      vss-workfile vss-revision vss-description skip
      "Не задана кнопка выбираемая при нажатии Escape" skip
      "p-cancel-button" p-cancel-button skip
      view-as alert-box .
    undo, return error .
  end.

  if  v-buttons > 1
  and p-cancel-button = p-default-button then do:
    message
      vss-workfile vss-revision vss-description skip
      "Номер кнопки по умолчанию совпадает с номером кнопки выбираемой при нажатии Escape" skip
      "p-default-button" p-default-button skip
      "p-cancel-button"  p-cancel-button  skip
      view-as alert-box .
  end.



  define variable ind as integer no-undo .
  do ind = 1 to v-buttons
  :
    assign
      v-handle             = v-button-handle[ind]
      v-handle-description = v-button-description-handle[ind]
    .

    define variable v-button-text      as character no-undo .
    define variable v-description-text as character no-undo .
    define variable l-sensitive        as logical no-undo .
    define variable l-confirm          as logical no-undo .
    define variable v-btn-text-ind     as integer no-undo .

    assign
      v-button-text      = entry(ind, p-buttons, v-first-delimiter)
      v-description-text = entry(ind, p-buttons-description, v-first-delimiter)
      l-sensitive        = true
      l-confirm          = false
    .

    define variable v-button-attribute as character no-undo .

    do v-btn-text-ind = 2 to num-entries(v-button-text, v-second-delimiter )
    :
      assign
        v-button-attribute = entry(v-btn-text-ind, v-button-text, v-second-delimiter)
      .

      case v-button-attribute :
        when 'disable' then do:
          assign
            l-sensitive = false
          .
        end.
        when 'confirm' then do:
          assign
            l-confirm = true
          .
        end.
        otherwise do:
          message
            vss-workfile vss-revision vss-description skip
            "Неизвестный атрибут кнопки" skip
            "Атрибут" v-button-attribute skip
            "Описание кнопки" ind skip
            v-button-text skip
            view-as alert-box error .
        end.
      end case .
    end.

    if num-entries (v-button-text, v-second-delimiter ) >= 1 then do:
      assign
        v-button-text = entry(1, v-button-text, v-second-delimiter)
      .
    end.

    assign
      v-need-confirm [ind] = l-confirm
    .

    assign
      v-handle :label     = v-button-text
      v-handle :visible   = true
      v-handle :sensitive = l-sensitive
    .

    if v-description-text = "" then do:
      assign
        v-handle :width = min(max(v-handle :width
                                 ,length(v-button-text) + 2
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
  def var mAnswer as char no-undo.   
  publish "ResponseToQuestion" (output mAnswer ).
  p-number = int (mAnswer) no-error.
  if error-status:error
  then do:
     define variable mbeg as integer no-undo.

     mbeg = index("," + mAnswer   , "," + mcodemes + "=") .
     mAnswer = substring (mAnswer, mbeg + length(mcodemes) + 1).
     mAnswer = entry(1,mAnswer).  
     p-number = int (mAnswer) no-error.
     if error-status:error
     then 
        block-num:
        do mbeg = 1 to num-entries (mAnswer):
             p-number = int (entry(mbeg, mAnswer)) no-error.
              if not error-status:error
              then 
                 leave block-num.
        end.         
        
     
  end.
  if   p-number eq 0 
  then do:
  RUN enable_UI.

  if  p-default-button > 0
  and p-default-button <= v-buttons
  then do:
    assign
      v-handle = v-button-handle[p-default-button]
    .
    apply 'entry':u to v-handle .
  end.

  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
  end.
END.
RUN disable_UI.

RETURN.

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
  DISPLAY EDITOR-1 
      WITH FRAME Dialog-Frame.
  ENABLE b-help EDITOR-1 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

