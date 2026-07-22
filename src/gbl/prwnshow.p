block-level on error undo, throw.
&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: prwnshow.p $
$Archive: gbl/prwnshow.p $

Показывает сессии Progress, запущенные на компьютере

Автор: Перваков Михаил Сергеевич
Дата создания: 05/26/03
Author: Mikhail Pervakov
Creation date: 05/26/03

*/

/* ***************************  Definitions  ************************** */

{ gbl/prwnshow.i }
{ cmp/str-glbl.i }

/* Информация о дате и времени сбора информации */
define variable v-info as character no-undo .

define stream sinp .
define stream sout .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BROWSE-1

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES temp-prwninfo temp-prwnprocinfo

/* Definitions for BROWSE BROWSE-1                                      */
&Scoped-define FIELDS-IN-QUERY-BROWSE-1 temp-prwninfo.proc-id temp-prwninfo.progress-self temp-prwninfo.progress-version temp-prwninfo.trans-active temp-prwninfo.widget-num temp-prwninfo.message-text temp-prwninfo.proc-line temp-prwninfo.proc-name temp-prwninfo.module-file-name temp-prwninfo.max-widget-num temp-prwninfo.progress-inifile temp-prwninfo.progress-curdir temp-prwninfo.progress-propath   
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-1   
&Scoped-define SELF-NAME BROWSE-1
&Scoped-define OPEN-QUERY-BROWSE-1 /* OPEN QUERY {&SELF-NAME} FOR EACH temp-prwninfo. */ run local-open-query in this-procedure .
&Scoped-define TABLES-IN-QUERY-BROWSE-1 temp-prwninfo
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-1 temp-prwninfo


/* Definitions for BROWSE BROWSE-2                                      */
&Scoped-define FIELDS-IN-QUERY-BROWSE-2 temp-prwnprocinfo.proc-level temp-prwnprocinfo.h-proc temp-prwnprocinfo.proc-name temp-prwnprocinfo.proc-line temp-prwnprocinfo.r-code-name temp-prwnprocinfo.sub-procedure temp-prwnprocinfo.subproc-num   
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-2   
&Scoped-define SELF-NAME BROWSE-2
&Scoped-define OPEN-QUERY-BROWSE-2 /* OPEN QUERY {&SELF-NAME} FOR EACH temp-prwnprocinfo . */ run local-open-query-prwnprocinfo in this-procedure .
&Scoped-define TABLES-IN-QUERY-BROWSE-2 temp-prwnprocinfo
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-2 temp-prwnprocinfo


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BROWSE-1}~
    ~{&OPEN-QUERY-BROWSE-2}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-refresh b-propath b-cur-dir ~
b-debug-file b-cur-line b-export b-terminate b-about t-self-view BROWSE-1 ~
BROWSE-2 fi-info 
&Scoped-Define DISPLAYED-OBJECTS t-self-view fi-info 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-about 
     LABEL "О программе" 
     SIZE 14.5 BY 1.

DEFINE BUTTON b-cur-dir 
     LABEL "Cur Dir" 
     SIZE 10 BY 1.

DEFINE BUTTON b-cur-line 
     LABEL "Cur Ln" 
     SIZE 8 BY 1.

DEFINE BUTTON b-debug-file 
     LABEL "Dbg File" 
     SIZE 11 BY 1.

DEFINE BUTTON b-exit AUTO-GO 
     LABEL "&Выход" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-export 
     LABEL "Экспорт" 
     SIZE 10 BY 1.

DEFINE BUTTON b-propath 
     LABEL "Propath" 
     SIZE 10 BY 1.

DEFINE BUTTON b-refresh 
     LABEL "Обновить" 
     SIZE 10 BY 1.

DEFINE BUTTON b-terminate 
     LABEL "Завершить" 
     SIZE 12 BY 1.

DEFINE VARIABLE fi-info AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 92.13 BY .67 NO-UNDO.

DEFINE VARIABLE t-self-view AS LOGICAL INITIAL no 
     LABEL "Показывать процесс ~"сам~"" 
     VIEW-AS TOGGLE-BOX
     SIZE 27.5 BY .83 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BROWSE-1 FOR 
      temp-prwninfo SCROLLING.

DEFINE QUERY BROWSE-2 FOR 
      temp-prwnprocinfo SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BROWSE-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-1 Dialog-Frame _FREEFORM
  QUERY BROWSE-1 DISPLAY
      temp-prwninfo.proc-id
      temp-prwninfo.progress-self
      temp-prwninfo.progress-version
      temp-prwninfo.trans-active
      temp-prwninfo.widget-num
      temp-prwninfo.message-text format "X(256)" width 100
      temp-prwninfo.proc-line
      temp-prwninfo.proc-name
      temp-prwninfo.module-file-name
      temp-prwninfo.max-widget-num
      temp-prwninfo.progress-inifile
      temp-prwninfo.progress-curdir
      temp-prwninfo.progress-propath
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 126 BY 7.75.

DEFINE BROWSE BROWSE-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-2 Dialog-Frame _FREEFORM
  QUERY BROWSE-2 DISPLAY
      temp-prwnprocinfo.proc-level
      temp-prwnprocinfo.h-proc
      temp-prwnprocinfo.proc-name
      temp-prwnprocinfo.proc-line
      temp-prwnprocinfo.r-code-name
      temp-prwnprocinfo.sub-procedure
      temp-prwnprocinfo.subproc-num
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 126 BY 16.46.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-refresh AT ROW 1 COL 11
     b-propath AT ROW 1 COL 21
     b-cur-dir AT ROW 1 COL 31
     b-debug-file AT ROW 1 COL 41
     b-cur-line AT ROW 1 COL 52
     b-export AT ROW 1 COL 60
     b-terminate AT ROW 1 COL 70
     b-about AT ROW 1 COL 82
     t-self-view AT ROW 3.25 COL 2.5 WIDGET-ID 2
     BROWSE-1 AT ROW 4.25 COL 1
     BROWSE-2 AT ROW 12.29 COL 1
     fi-info AT ROW 2.38 COL 1.13 NO-LABEL
     SPACE(33.98) SKIP(25.86)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Сессии Progress"
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
   FRAME-NAME                                                           */
/* BROWSE-TAB BROWSE-1 t-self-view Dialog-Frame */
/* BROWSE-TAB BROWSE-2 BROWSE-1 Dialog-Frame */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN 
       BROWSE-1:NUM-LOCKED-COLUMNS IN FRAME Dialog-Frame     = 3.

ASSIGN 
       BROWSE-2:NUM-LOCKED-COLUMNS IN FRAME Dialog-Frame     = 1.

/* SETTINGS FOR FILL-IN fi-info IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-1
/* Query rebuild information for BROWSE BROWSE-1
     _START_FREEFORM
/* OPEN QUERY {&SELF-NAME} FOR EACH temp-prwninfo. */
run local-open-query in this-procedure .
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE BROWSE-1 */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-2
/* Query rebuild information for BROWSE BROWSE-2
     _START_FREEFORM
/* OPEN QUERY {&SELF-NAME} FOR EACH temp-prwnprocinfo . */
run local-open-query-prwnprocinfo in this-procedure .
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE BROWSE-2 */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Сессии Progress */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-about
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-about Dialog-Frame
ON CHOOSE OF b-about IN FRAME Dialog-Frame /* О программе */
DO:
  message
    "ProwinShow 1.0" skip
    "Программа просмотра процессов Progress" skip
    "Автор Михаил Перваков" skip
    "Москва, 2003-2006" skip
    "" skip
    "E-mail: kogosy@mail.ru" skip
    view-as alert-box information .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-cur-dir
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-cur-dir Dialog-Frame
ON CHOOSE OF b-cur-dir IN FRAME Dialog-Frame /* Cur Dir */
DO:
  { gbl/stdbtn.i }

  define variable v-current-directory as character no-undo .

  if available temp-prwninfo
  then do:
    if temp-prwninfo.progress-curdir = ""
    then do:
      run get-current-directory in this-procedure
        (input  temp-prwninfo.proc-id
        ,output v-current-directory
        ) .
      assign
        temp-prwninfo.progress-curdir = v-current-directory
      .
      display temp-prwninfo.progress-curdir with browse browse-1 .
    end.

    message
      "Сессия Progress 4GL" skip
      "Идентификатор процесса" temp-prwninfo.proc-id skip
      "Текущая рабочая директория" skip
      temp-prwninfo.progress-curdir skip
      view-as alert-box information .
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-cur-line
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-cur-line Dialog-Frame
ON CHOOSE OF b-cur-line IN FRAME Dialog-Frame /* Cur Ln */
DO:
  { gbl/stdbtn.i }

  run generate-debug-file in this-procedure
    (input 'cur-line':u
    ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-debug-file
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-debug-file Dialog-Frame
ON CHOOSE OF b-debug-file IN FRAME Dialog-Frame /* Dbg File */
DO:
  { gbl/stdbtn.i }

  run generate-debug-file in this-procedure
    (input 'debug-file':u
    ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-export
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-export Dialog-Frame
ON CHOOSE OF b-export IN FRAME Dialog-Frame /* Экспорт */
DO:
  { gbl/stdbtn.i }

  run export-info in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-propath
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-propath Dialog-Frame
ON CHOOSE OF b-propath IN FRAME Dialog-Frame /* Propath */
DO:
  { gbl/stdbtn.i }

  run show-propath in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-refresh
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-refresh Dialog-Frame
ON CHOOSE OF b-refresh IN FRAME Dialog-Frame /* Обновить */
DO:
  { gbl/stdbtn.i }

  run local-open-query .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-terminate
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-terminate Dialog-Frame
ON CHOOSE OF b-terminate IN FRAME Dialog-Frame /* Завершить */
DO:
  run terminate-process in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-1
&Scoped-define SELF-NAME BROWSE-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-1 Dialog-Frame
ON DEFAULT-ACTION OF BROWSE-1 IN FRAME Dialog-Frame
DO:
  run show-propath in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-1 Dialog-Frame
ON VALUE-CHANGED OF BROWSE-1 IN FRAME Dialog-Frame
DO:
  run local-open-query-prwnprocinfo in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-2
&Scoped-define SELF-NAME BROWSE-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-2 Dialog-Frame
ON DEFAULT-ACTION OF BROWSE-2 IN FRAME Dialog-Frame
DO:
  run generate-debug-file in this-procedure
    (input 'cur-line':u
    ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME t-self-view
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL t-self-view Dialog-Frame
ON VALUE-CHANGED OF t-self-view IN FRAME Dialog-Frame /* Показывать процесс "сам" */
DO:
  run local-open-query .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-1
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

define variable v-ok as logical   no-undo .

assign
  v-ok = {&browse-name} :set-repositioned-row(5, 'CONDITIONAL':u)
  v-ok = browse-2 :set-repositioned-row(5, 'CONDITIONAL':u)
.

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
:
  RUN enable_UI.
  assign
  temp-prwninfo.progress-version:resizable in browse browse-1 = yes
  temp-prwninfo.message-text:resizable     in browse browse-1 = yes
  .

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
  DISPLAY t-self-view fi-info 
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-refresh b-propath b-cur-dir b-debug-file b-cur-line b-export 
         b-terminate b-about t-self-view BROWSE-1 BROWSE-2 fi-info 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE export-info Dialog-Frame 
PROCEDURE export-info :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

  define variable v-command-line as character no-undo .
  define variable v-num          as integer   no-undo .
  define variable v-info-type    as character no-undo .

  do
  on error undo, return error return-value
  :
    run gbl/d-askw.w
      (input "Вопрос" /* Заголовок окна */
      ,input "Произвести сбор отладочной информации " /* Общее сообщение */
      + "и вывод информации в текстовый файл." + {&new-line}
      + "В любом из режимов не будет производится сбор личной информации." + {&new-line}
      + "По завершении экспорта в текстовый файл его можно будет просмотреть, "
      + "при необходимости удалить лишнюю информацию, "
      + "отправить в службу поддержки для определения причины ошибки"
      ,input '|^':u /* Символы разделители для кодирования двух следующих параметров */
                    /* первый символ - разделитель списков названий кнопок и описаний кнопок */
                    /* второй символ - разделитель атрибутов в описании кнопок */
      ,input "Краткая"        /* список названий кнопок  */
      + '|':u + "Подробная" /* каждая кнопка может иметь необязательный */
      + '|':u + "Отказ"     /* список атрибутов, влияющих на поведение кнопки */
      ,input "Собрать минимальное количество информации"
          + "|":u + "Собрать максимально подробную информацию "
                  + "(запущенные сервисы, программы, установленные программы, "
                  + "установленные обновления, сообщения об ошибках из журнала)"
          + "|":u
      ,input 1 /* значение возвращаемое при нажатии enter */
      ,input 3 /* значение возвращаемое при нажатии escape */
      ,output v-num /* выбор пользователя */
      ).

    case v-num
    :
      when 1
      then do:
        assign
          v-info-type = 'common':u
        .
      end.
      when 2
      then do:
        assign
          v-info-type = 'detail':u
        .
      end.
      when 3
      then do:
        return . /* --->>>--- */
      end.
    end case .

    define variable v-error-log-file-name as character no-undo .

    run gbl/_tmpfile.p
      (input "pwn"
      ,input ".txt"
      ,output v-error-log-file-name
      ).

    output stream sout to value(v-error-log-file-name) .

    define buffer buf_temp-prwninfo for temp-prwninfo .
    define buffer buf_temp-prwnprocinfo for temp-prwnprocinfo .

    put stream sout unformatted 'ProwinShow 1.0':u + {&new-line} .
    put stream sout unformatted v-info + {&new-line} .

    if  available temp-prwninfo
    and temp-prwninfo.message-text <> ''
    then do:
      put stream sout unformatted {&new-line} .
      put stream sout unformatted {&new-line} .
      put stream sout unformatted fill('#':u, 80) + {&new-line}.
      put stream sout unformatted substitute("Идентификатор процесса (PID) : &1&2"
                                            ,temp-prwninfo.proc-id
                                            ,{&new-line}
                                            ).
      put stream sout unformatted substitute('Сообщение                    : &1&2':u
                                            ,temp-prwninfo.message-text
                                            ,{&new-line}
                                            ) .
      put stream sout unformatted substitute('Процедура                    : &1&2':u
                                            ,temp-prwninfo.proc-name
                                            ,{&new-line}
                                            ) .
      put stream sout unformatted substitute('Номер строки                 : &1&2':u
                                            ,temp-prwninfo.proc-line
                                            ,{&new-line}
                                            ) .
      put stream sout unformatted substitute('Файл                         : &1&2':u
                                            ,temp-prwninfo.r-code-name
                                            ,{&new-line}
                                            ) .
    end.

    put stream sout unformatted {&new-line} .

    for each buf_temp-prwninfo
    on error undo, return error return-value
    :
      put stream sout unformatted {&new-line} .
      put stream sout unformatted {&new-line} .
      put stream sout unformatted fill('#':u, 80) + {&new-line}.
      put stream sout unformatted substitute("Идентификатор процесса (PID)            : &1&2"
                                            ,buf_temp-prwninfo.proc-id
                                            ,{&new-line}
                                            ).
      put stream sout unformatted substitute("Версия Progress                         : &1&2"
                                            ,buf_temp-prwninfo.progress-version
                                            ,{&new-line}
                                            ).
      put stream sout unformatted substitute("Текущий процесс ProwinShow              : &1&2"
                                            ,string(buf_temp-prwninfo.progress-self, "да/нет")
                                            ,{&new-line}
                                            ).
      put stream sout unformatted substitute("Исполняемый файл                        : &1&2"
                                            ,buf_temp-prwninfo.module-file-name
                                            ,{&new-line}
                                            ).
      define variable v-index                as integer   no-undo .
      define variable v-num-entries-propath as integer   no-undo .
      assign
        v-num-entries-propath = num-entries(buf_temp-prwninfo.progress-propath)
      .
      put stream sout unformatted substitute("Путь поиска файлов Progress (PROPATH)   : &1&2"
                                            ,entry(1, buf_temp-prwninfo.progress-propath)
                                            ,{&new-line}
                                            ).
      do v-index = 2 to v-num-entries-propath
      :
        put stream sout unformatted substitute("                                          &1&2"
                                              ,entry(v-index, buf_temp-prwninfo.progress-propath)
                                              ,{&new-line}
                                              ).
      end.
      put stream sout unformatted substitute("Файл конфигурации Progress (*.ini файл) : &1&2"
                                            ,buf_temp-prwninfo.progress-inifile
                                            ,{&new-line}
                                            ).
      put stream sout unformatted substitute("Рабочая папка                           : &1&2"
                                            ,buf_temp-prwninfo.progress-curdir
                                            ,{&new-line}
                                            ).
      put stream sout unformatted substitute("Транзакция активна                      : &1&2"
                                            ,string(buf_temp-prwninfo.trans-active, "да/нет")
                                            ,{&new-line}
                                            ).
      put stream sout unformatted substitute("Указатель окна                          : &1&2"
                                            ,buf_temp-prwninfo.message-handle
                                            ,{&new-line}
                                            ).
      put stream sout unformatted substitute("Сообщение                               : &1&2"
                                            ,buf_temp-prwninfo.message-text
                                            ,{&new-line}
                                            ).
      put stream sout unformatted substitute("Имя процедуры                           : &1&2"
                                            ,buf_temp-prwninfo.proc-name
                                            ,{&new-line}
                                            ).
      put stream sout unformatted substitute("Номер строки                            : &1&2"
                                            ,buf_temp-prwninfo.proc-line
                                            ,{&new-line}
                                            ).
      put stream sout unformatted substitute("Исполняемый файл                        : &1&2"
                                            ,buf_temp-prwninfo.r-code-name
                                            ,{&new-line}
                                            ).
      put stream sout unformatted substitute("Строка подключения к БД                 : &1&2"
                                            ,buf_temp-prwninfo.db-connect-string
                                            ,{&new-line}
                                            ).
      put stream sout unformatted substitute("Количество интерфейсных элементов       : &1&2"
                                            ,buf_temp-prwninfo.widget-num
                                            ,{&new-line}
                                            ).

      put stream sout unformatted {&new-line} .
      put stream sout unformatted "Стек вызова процедур" + {&new-line}.

      put stream sout unformatted "Порядок Имя процедуры                          Номер строки   Исполняемый файл" + {&new-line}.
      put stream sout unformatted fill('-':u, 80) + {&new-line}.


      for each buf_temp-prwnprocinfo
        where buf_temp-prwnprocinfo.proc-id = buf_temp-prwninfo.proc-id
      on error undo, return error return-value
      :
        put stream sout unformatted substitute(' &1 &2 &3       &4&5':u
                                              ,string(buf_temp-prwnprocinfo.proc-level, '>>,>>9':u)
                                              ,string(buf_temp-prwnprocinfo.proc-name, 'x(40)':u)
                                              ,string(buf_temp-prwnprocinfo.proc-line, '>>,>>9':u)
                                              ,string(buf_temp-prwnprocinfo.r-code-name, 'x(40)':u)
                                              ,{&new-line}
                                              ).
      end.
      put stream sout unformatted fill('-':u, 80) + {&new-line}.
    end.

    put stream sout unformatted {&new-line}.
    put stream sout unformatted fill('#':u, 80) + {&new-line}.
    put stream sout unformatted substitute("Информация о компьютере и процессах Progress. Дата &1. Время &2.", string(today, '99/99/9999':u), string(time, 'HH:MM:SS':u)) + {&new-line} .
    output stream sout close .

    define variable v-compinfo-filename as character no-undo .

    assign
      v-compinfo-filename = search('exe/compinfo.bat':u)
    .
    if  v-compinfo-filename = ""
    and v-compinfo-filename = ?
    then do:
      message
        "Не найден файл определения информации о компьютере" 'exe/compinfo.bat':u skip
        "Сбор информации об ошибке будет продолжен" skip
        view-as alert-box information  .
    end.
    else do:
      define variable v-full-path        as character no-undo .
      define variable v-path             as character no-undo .
      define variable v-file-name        as character no-undo .
      define variable v-file-name-no-ext as character no-undo .
      define variable v-file-name-ext    as character no-undo .

      run gbl/filename.p
        (input  v-compinfo-filename /* p-search-file-name */
        ,output v-full-path         /* p-full-path        */
        ,output v-path              /* p-path             */
        ,output v-file-name         /* p-file-name        */
        ,output v-file-name-no-ext  /* p-file-name-no-ext */
        ,output v-file-name-ext     /* p-file-name-ext    */
        ) .

      assign
        v-command-line =  substitute("&1 &2 &3 &4"
                                    ,v-compinfo-filename
                                    ,v-path
                                    ,v-error-log-file-name
                                    ,v-info-type
                                    )
      .

      os-command value(v-command-line).
    end.

    define variable v-procinfo-filename as character no-undo .

    assign
      v-procinfo-filename = search('exe/procinfo.bat':u)
    .
    if  v-procinfo-filename = ""
    and v-procinfo-filename = ?
    then do:
      message
        "Не найден файл определения информации о процессе" 'exe/procinfo.bat':u skip
        "Сбор информации об ошибке будет продолжен" skip
        view-as alert-box information  .
    end.
    else do:
      run gbl/filename.p
        (input  v-procinfo-filename /* p-search-file-name */
        ,output v-full-path         /* p-full-path        */
        ,output v-path              /* p-path             */
        ,output v-file-name         /* p-file-name        */
        ,output v-file-name-no-ext  /* p-file-name-no-ext */
        ,output v-file-name-ext     /* p-file-name-ext    */
        ) .

      for each buf_temp-prwninfo
      on error undo, return error return-value
      :
        assign
          v-command-line =  substitute("&1 &2 &3 &4"
                                      ,v-procinfo-filename
                                      ,v-path
                                      ,buf_temp-prwninfo.proc-id
                                      ,v-error-log-file-name
                                      )
        .

        os-command value(v-command-line).
      end.
    end.

    output stream sout to value(v-error-log-file-name) append .
    put stream sout unformatted fill('#':u, 80) + {&new-line} .
    put stream sout unformatted '>>> EOF <<<':u + {&new-line} .
    output stream sout close .

    os-command no-wait value ('start notepad ' + v-error-log-file-name).
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE generate-debug-file Dialog-Frame 
PROCEDURE generate-debug-file :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

  define input  parameter p-show-type as character no-undo .

  define variable v-current-directory as character no-undo .

  if  available temp-prwninfo
  and available temp-prwnprocinfo
  then do:
    find first temp-dbg-file-header
      where temp-dbg-file-header.proc-id     = temp-prwninfo.proc-id
        and temp-dbg-file-header.r-code-name = temp-prwnprocinfo.r-code-name
      no-error .
    if not available temp-dbg-file-header
    then do:
      if temp-prwninfo.progress-curdir = ""
      then do:
        run get-current-directory in this-procedure
          (input  temp-prwninfo.proc-id
          ,output v-current-directory
          ) .
        assign
          temp-prwninfo.progress-curdir = v-current-directory
        .
        display temp-prwninfo.progress-curdir with browse browse-1 .
      end.

      define variable v-connect-string as character no-undo .
      assign
        v-connect-string = temp-prwninfo.db-connect-string
      .

      run gbl/getinist.p
        (input  temp-prwninfo.progress-inifile /* p-ini-filename */
        ,input  "rep-sets"                     /* p-section      */
        ,input  "conpar"                       /* p-key          */
        ,output v-connect-string               /* p-value        */
        ) .


      define variable v-new-connect-string as character no-undo .

      if v-connect-string = ?
      then do:
        assign
          v-new-connect-string = ""
        .
      end.
      else do:
        if index(v-connect-string, '&1':u) > 0
        then do:
          assign
            v-new-connect-string = substitute(v-connect-string, '-U sysadm -P &1':u)
          .
        end.
        else do:
          assign
            v-new-connect-string = v-connect-string + ' -U sysadm -P &1':u
          .
        end.
      end.

      run gbl/d-prompt.w
        ( 'title=':u + "Параметры подключения к базе данных" + '\':u
        + 'text1=':u + "Отредактируйте строку подключения к базе данных" + '\':u
        + 'text2=':u + "или нажмите Отмену, чтобы не подключаться к базе" + '\':u
        + 'format=X(128)\':u
        + 'fillin_width=60\':u
        + 'type=char\':u
        ,input-output v-new-connect-string
        ).
      if return-value = 'false':u
      then do:
        assign
          v-connect-string = ""
        .
      end.
      else do:
        assign
          v-connect-string = v-new-connect-string
        .
      end.

      if index(v-connect-string, "&1") > 0
      then do:
        define variable v-sysadm-passwd as character no-undo .
        run gbl/d-prompt.w
          ( 'title=':u + "Введите пароль sysadm для базы данных" + '\':u
          + 'text1=':u + "Введите пароль sysadm для базы данных" + '\':u
          + 'text1=':u + "или нажмите Отмену, чтобы не подключаться к базе" + '\':u
          + 'format=X(12)\':u
          + 'type=char\':u
          + 'blank=yes\':u
          ,input-output v-sysadm-passwd
          ).
        if return-value = 'false':u
        then do:
          assign
            v-connect-string = ""
          .
        end.
        else do:
          assign
            v-connect-string = substitute(v-connect-string, v-sysadm-passwd)
          .
        end.
      end.

      assign
        temp-prwninfo.db-connect-string = v-connect-string
      .

      define variable v-dbg-file       as character no-undo .

      /* создание *.dbg файла */
      run gbl/comp_dbg.p
        (input  temp-prwninfo.module-file-name  /* p-module-file-name  */
        ,input  temp-prwninfo.progress-curdir   /* p-progress-curdir   */
        ,input  temp-prwninfo.progress-inifile  /* p-progress-inifile  */
        ,input  temp-prwninfo.progress-propath  /* p-progress-propath  */
        ,input  temp-prwnprocinfo.r-code-name   /* p-r-code-name       */
        ,input  temp-prwnprocinfo.proc-line     /* p-proc-line         */
        ,input  temp-prwninfo.db-connect-string /* p-db-connect-string */
        ,output v-dbg-file                      /* p-dbg-file          */
        ) .

      if search(v-dbg-file) = ""
      or search(v-dbg-file) = ?
      then do:
        message
          "Ошибка создания *.dbg файла" skip
          view-as alert-box error .
        undo, return error return-value  .
      end.

      define variable v-file-num as integer   no-undo .
      find last temp-dbg-file-header
        use-index x-file-num
        no-error .
      if available temp-dbg-file-header
      then do:
        assign
          v-file-num = temp-dbg-file-header.file-num + 1
        .
      end.
      else do:
        assign
          v-file-num = 1
        .
      end.

      create temp-dbg-file-header .
      assign
        temp-dbg-file-header.proc-id     = temp-prwninfo.proc-id
        temp-dbg-file-header.r-code-name = temp-prwnprocinfo.r-code-name
        temp-dbg-file-header.file-num    = v-file-num
      .

      define variable v-line-text as character no-undo .
      define variable v-line-num as integer   no-undo .

      assign
        v-line-num = 0
      .
      input stream sinp from value(v-dbg-file) .
      repeat
      :
        assign
          v-line-text = ""

        .
        import stream sinp unformatted
          v-line-text
          .
        assign
          v-line-num = v-line-num + 1
        .
        create temp-dbg-file .
        assign
          temp-dbg-file.file-num  = v-file-num
          temp-dbg-file.line-num  = v-line-num
          temp-dbg-file.line-text = v-line-text
        .
      end.
      input stream sinp close .

      os-delete value(v-dbg-file) .
    end.

    find first temp-dbg-file-header
      where temp-dbg-file-header.proc-id     = temp-prwninfo.proc-id
        and temp-dbg-file-header.r-code-name = temp-prwnprocinfo.r-code-name
      no-error .
    if available temp-dbg-file-header
    then do:

      case p-show-type :
        when 'cur-line':u
        then do:
          define variable v-program-text as character no-undo .

          assign
            v-program-text = ""
          .

          for each temp-dbg-file
            where temp-dbg-file.file-num = temp-dbg-file-header.file-num
              and temp-dbg-file.line-num >= temp-prwnprocinfo.proc-line - 10
              and temp-dbg-file.line-num <= temp-prwnprocinfo.proc-line + 10
          :
            assign
              v-program-text = v-program-text
                              + (if temp-dbg-file.line-num = temp-prwnprocinfo.proc-line
                                then "##>"
                                else "   "
                                )
                              + temp-dbg-file.line-text
                              + {&new-line}
            .
          end.

          run gbl/d-prompt.w
            (input 'title=Текущая выполняемая строка\'
              + 'type=editor\'
              + 'fillin_width=96\'
              + 'fillin_height=17\'
              + 'readonly=yes\'
            , input-output v-program-text
            ).
        end.
        when 'debug-file':u
        then do:
          for each temp-show-file
          :
            delete temp-show-file .
          end.

          for each temp-dbg-file
            where temp-dbg-file.file-num = temp-dbg-file-header.file-num
          :
            create temp-show-file .
            assign
              temp-show-file.line-num  = temp-dbg-file.line-num
              temp-show-file.line-text = temp-dbg-file.line-text
            .
          end.

          run gbl/show_dbg.w
            (input table temp-show-file         /* table temp-show-file */
            ,input  temp-prwnprocinfo.proc-line /* p-line-num           */
            ) .
        end.
        otherwise do:
          message
            "Внутренняя ошибка" skip
            "Неизвестное значение переменной p-show-type" skip
            "p-show-type" p-show-type skip
            view-as alert-box error .
        end.
      end case .
    end.
    else do:
      message
        "Ошибка при создании *.dbg файла"
        view-as alert-box error .
    end.

  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-current-directory Dialog-Frame 
PROCEDURE get-current-directory :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define input  parameter p-process-id        as integer   no-undo .
  define output parameter p-current-directory as character no-undo .

  define variable v-getcurdr-filename as character no-undo .
  define variable v-output-filename   as character no-undo .
  define variable v-command-line      as character no-undo .

  do
  on error undo, return error return-value
  :
    assign
      v-getcurdr-filename = search("exe/getcurdr.bat")
    .

    if  v-getcurdr-filename = ""
    and v-getcurdr-filename = ?
    then do:
      message
        "Не найден файл программы определения текущей директории" skip
        "exe/getcurdr.bat" skip
        view-as alert-box information  .
    end.
    else do:
      define variable v-full-path        as character no-undo .
      define variable v-path             as character no-undo .
      define variable v-file-name        as character no-undo .
      define variable v-file-name-no-ext as character no-undo .
      define variable v-file-name-ext    as character no-undo .

      run gbl/filename.p
        (input  v-getcurdr-filename /* p-search-file-name */
        ,output v-full-path         /* p-full-path        */
        ,output v-path              /* p-path             */
        ,output v-file-name         /* p-file-name        */
        ,output v-file-name-no-ext  /* p-file-name-no-ext */
        ,output v-file-name-ext     /* p-file-name-ext    */
        ) .

      run gbl/_tmpfile.p
        (input  "err"
        ,input  ".txt"
        ,output v-output-filename
        ).
      output stream sout to value(v-output-filename).
      put stream sout unformatted "ERROR" skip .
      output stream sout close .

      assign
        file-info :file-name = v-output-filename
        v-output-filename = file-info :full-pathname
      .

      assign
        v-command-line = substitute("&1 &2 &3 &4"
          ,v-getcurdr-filename
          ,v-path
          ,p-process-id
          ,v-output-filename
          )
      .
      os-command value(v-command-line).

      assign
        p-current-directory = ""
      .

      input stream sout from value(v-output-filename) .

      repeat :
        import stream sout unformatted p-current-directory .
      end.
      input stream sout close .

      os-delete value(v-output-filename) .

      if p-current-directory = "ERROR"
      then do:
        message
          "Ошибка при определении текущей директории программы" skip
          view-as alert-box error .
        assign
          p-current-directory = ""
        .
      end.
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-open-query Dialog-Frame 
PROCEDURE local-open-query :
/*------------------------------------------------------------------------------
  Purpose:     Override standard ADM method
  Notes:
------------------------------------------------------------------------------*/

  assign
    v-info = substitute("Информация о сессиях Progress. Дата &1. Время &2.", string(today, '99/99/9999':u), string(time, 'HH:MM:SS':u))
  .

  do with frame {&frame-name}:
    assign
      fi-info :screen-value = v-info
    .
    assign
      t-self-view
    .
  end. /* do with frame */

  run gbl/prwninfo.p
    (output table temp-prwninfo
    ,output table temp-prwnprocinfo
    ) .

  if t-self-view = true then do:
    OPEN QUERY {&browse-name} FOR EACH temp-prwninfo .
  end.
  else do:
    OPEN QUERY {&browse-name} FOR EACH temp-prwninfo where temp-prwninfo.progress-self = false .
  end.

  /* встаем на первую запись у которой на экране присутствует сообщение об ошибке */
  define variable v-rowid as rowid no-undo .

  define buffer buf_temp-prwninfo for temp-prwninfo .
  find first buf_temp-prwninfo
    where buf_temp-prwninfo.message-text <> ""
    no-error .
  if available buf_temp-prwninfo
  then do:
    assign
      v-rowid = rowid(buf_temp-prwninfo)
    .
    reposition {&browse-name} to rowid v-rowid .
  end.

  /* показываем подробную информацию о процесса */
  run local-open-query-prwnprocinfo in this-procedure .

  do with frame {&frame-name}:
    apply 'entry':u to browse {&browse-name} .
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-open-query-prwnprocinfo Dialog-Frame 
PROCEDURE local-open-query-prwnprocinfo :
/*------------------------------------------------------------------------------
  Purpose:     Override standard ADM method
  Notes:
------------------------------------------------------------------------------*/

  if available temp-prwninfo
  then do:
    open query browse-2 for each temp-prwnprocinfo
      where temp-prwnprocinfo.proc-id = temp-prwninfo.proc-id
      by temp-prwnprocinfo.proc-level descending .
  end.
  else do:
    open query browse-2 for each temp-prwnprocinfo where false .
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE show-propath Dialog-Frame 
PROCEDURE show-propath :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

  if available temp-prwninfo
  then do:
    message
      "Сессия Progress 4GL" skip
      "Номер процесса" temp-prwninfo.proc-id skip
      "Версия Progress" temp-prwninfo.progress-version skip
      "Транзакция" (if temp-prwninfo.trans-active then "АКТИВНА" else "не активна") skip
      "Ini файл" skip
      temp-prwninfo.progress-inifile skip
      "Propath" skip
      temp-prwninfo.progress-propath skip
      view-as alert-box information .
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE terminate-process Dialog-Frame 
PROCEDURE terminate-process :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  if available temp-prwninfo
  then do:
    define variable v-ok as logical   no-undo .

    message
      substitute("Процесс с номером &1 будет завершен."
                ,temp-prwninfo.proc-id
                ) skip
      "Продолжить?" skip
      view-as alert-box question buttons yes-no update v-ok .
    if v-ok <> true
    then do:
      return .
    end.

    run gbl/termprc.p
      (input temp-prwninfo.proc-id /* p-process-id */
      ) .

    run local-open-query .
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

