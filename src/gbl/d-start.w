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

Запуск внешних программ

Автор: Перваков Михаил Сергеевич
Дата создания: 08/11/04
Author: Mikhail Pervakov
Creation date: 08/11/04

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Запуск внешних программ".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i  }
{ gbl/dtm.i      }

define stream readconf .

define variable v-readconf-filename as character no-undo init "cmp/starter.txt":u .
define variable v-read-file         as character no-undo .

define variable v-conf-name    as character no-undo init "name=":u .
define variable v-conf-path    as character no-undo init "path=":u .
define variable v-conf-comment as character no-undo init "comment=":u .

define temp-table temp-program no-undo
  field prog-num     as integer
  field prog-name    as character label "Имя "             format "X(15)"
  field prog-path    as character label "Командная строка" format "X(38)"
  field prog-comment as character label "Комментарий"      format "X(40)"
.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BROWSE-1

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES temp-program

/* Definitions for BROWSE BROWSE-1                                      */
&Scoped-define FIELDS-IN-QUERY-BROWSE-1 prog-name prog-path prog-comment
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-1
&Scoped-define FIELD-PAIRS-IN-QUERY-BROWSE-1
&Scoped-define SELF-NAME BROWSE-1
&Scoped-define OPEN-QUERY-BROWSE-1 OPEN QUERY {&SELF-NAME} FOR EACH temp-program NO-LOCK.
&Scoped-define TABLES-IN-QUERY-BROWSE-1 temp-program
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-1 temp-program


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BROWSE-1}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-sel b-config b-help BROWSE-1

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-config
     LABEL "&Конфиг."
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-exit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-sel
     LABEL "Вы&бор"
     SIZE 10 BY 1
     BGCOLOR 8 .

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BROWSE-1 FOR
      temp-program SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BROWSE-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-1 Dialog-Frame _FREEFORM
  QUERY BROWSE-1 DISPLAY
      prog-name
      prog-path
      prog-comment
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97.88 BY 11.75
         BGCOLOR 15 .


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-sel AT ROW 1 COL 11
     b-config AT ROW 1 COL 21
     b-help AT ROW 1 COL 31
     BROWSE-1 AT ROW 2.29 COL 1
     SPACE(0.00) SKIP(1.08)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Запуск внешних программ"
         DEFAULT-BUTTON b-exit CANCEL-BUTTON b-exit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS


/* ***************  Runtime Attributes and UIB Settings  ************** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
                                                                        */
/* BROWSE-TAB BROWSE-1 b-help Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       BROWSE-1:NUM-LOCKED-COLUMNS IN FRAME Dialog-Frame = 1.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-1
/* Query rebuild information for BROWSE BROWSE-1
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH temp-program NO-LOCK.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE BROWSE-1 */
&ANALYZE-RESUME






/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Запуск внешних программ */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-config
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-config Dialog-Frame
ON CHOOSE OF b-config IN FRAME Dialog-Frame /* Конфиг. */
DO:
  /* выдать информацию о конфигурации программы */
  define variable v-help-str as character no-undo .

  assign
    v-help-str = "Для конфигурации списка внешних программ" + {&new-line}
               + "обратитесь к администратору вашей системы" + {&new-line}
               + {&new-line}
               + "В случае, если какая-либо из программ не запускается" + {&new-line}
               + "обратитесь к администратору вашей системы" + {&new-line}
               + {&new-line}
               + "Список программ задается в файле " + v-readconf-filename + {&new-line}
               + "Текущая конфигурация прочитана из файла " + dtm-char(v-read-file) + {&new-line}
               + "Для каждой внешней программы необходимо задать" + {&new-line}
               + "следующие строки в указанном порядке" + {&new-line}
               + v-conf-name    + "Имя файла" + {&new-line}
               + v-conf-path    + "Командная строка" + {&new-line}
               + v-conf-comment + "Комментарий" + {&new-line}
               + {&new-line}
               + "Пример:" + {&new-line}
               + v-conf-name    + "IBS" + {&new-line}
               + v-conf-path    + "http://www.ibs.ru/" + {&new-line}
               + v-conf-comment + "IBS" + {&new-line}
               + v-conf-name    + "IBS Retail" + {&new-line}
               + v-conf-path    + "http://retail.ibs.ru/" + {&new-line}
               + v-conf-comment + "Торговые решения IBS" + {&new-line}
               + v-conf-name    + "IBS Trade House" + {&new-line}
               + v-conf-path    + "http://www.google.ru/search?q=%22IBS+Trade+House%22" + {&new-line}
               + v-conf-comment + "Поиск информации об IBS Trade House" + {&new-line}
               + v-conf-name    + "Гугл" + {&new-line}
               + v-conf-path    + "http://www.google.ru/" + {&new-line}
               + v-conf-comment + "Поисковая система Google" + {&new-line}
               + v-conf-name    + "Яндекс" + {&new-line}
               + v-conf-path    + "http://www.yandex.ru/" + {&new-line}
               + v-conf-comment + "Поисковая система Яндекс" + {&new-line}
               + v-conf-name    + "name=Калькулятор" + {&new-line}
               + v-conf-path    + "calc.exe" + {&new-line}
               + v-conf-comment + "Калькулятор" + {&new-line}
               + v-conf-name    + "Word" + {&new-line}
               + v-conf-path    + "winword.exe" + {&new-line}
               + v-conf-comment + "Microsoft Word" + {&new-line}
               + v-conf-name    + "Excel" + {&new-line}
               + v-conf-path    + "excel.exe" + {&new-line}
               + v-conf-comment + "Microsoft Excel" + {&new-line}
               + {&new-line}
               + "Обратите внимание, что последняя строка должна завершаться символом конец строки" + {&new-line}
               + {&new-line}
  .

  run gbl/d-prompt.w
    (input
      'title=':u + "Информация о конфигурации" + '\':u
    + 'text1=':u + "Информация о конфигурации" + '\':u
    + 'text2=':u + '\':u
    + 'type=edit\':u
    + 'fillin_width=60\':u
    + 'fillin_height=12\':u
    + 'readonly=true\':u
    ,input-output v-help-str
    ).

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel Dialog-Frame
ON CHOOSE OF b-sel IN FRAME Dialog-Frame /* Выбор */
DO:
  run start-program in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-1
&Scoped-define SELF-NAME BROWSE-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-1 Dialog-Frame
ON DEFAULT-ACTION OF BROWSE-1 IN FRAME Dialog-Frame
DO:
  run start-program in this-procedure .
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

run load-temp-program in this-procedure .

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  RUN enable_UI.

  if num-results( "{&browse-name}" ) = ?
  or num-results( "{&browse-name}" ) = 0
  then do:
    assign
      b-sel :sensitive = false
    .
  end.

  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI Dialog-Frame _DEFAULT-DISABLE
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


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI Dialog-Frame _DEFAULT-ENABLE
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
  ENABLE b-exit b-sel b-config b-help BROWSE-1
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE load-temp-program Dialog-Frame
PROCEDURE load-temp-program :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

  define variable v-read-string    as character no-undo .
  define variable v-ind            as integer   no-undo .
  define variable v-curr-string    as integer   no-undo .
  define variable v-process-string as logical   no-undo .

  assign
    v-read-file = search(v-readconf-filename)
  .

  if  v-read-file <> ""
  and v-read-file <> ?
  then do:
    input stream readconf from value(v-read-file) no-echo.

    repeat
    :
      import stream readconf unformatted v-read-string .

      assign
        v-curr-string    = v-curr-string + 1
        v-process-string = false
      .

      if v-read-string begins v-conf-name
      then do:
        assign
          v-ind            = v-ind + 1
          v-process-string = true
        .
        create temp-program .
        assign
          temp-program.prog-num  = v-ind
          temp-program.prog-name = substring(v-read-string, length(v-conf-name) + 1)
        .
      end.

      if v-read-string begins v-conf-path
      then do:
        assign
          v-process-string = true
        .
        if available temp-program
        then do:
          assign
            temp-program.prog-path = substring(v-read-string, length(v-conf-path) + 1)
          .
        end.
        else do:
          message
            "Ошибка задания конфигурации" skip
            "Сначала необходимо задать имя программы при помощи строки" v-conf-name + "Имя программы" skip
            "Файл конфигурации" v-read-file skip
            "Номер строки" v-curr-string skip
            "Строка" v-read-string skip
            view-as alert-box error .
        end.
      end.

      if v-read-string begins v-conf-comment
      then do:
        assign
          v-process-string = true
        .
        if available temp-program
        then do:
          assign
            temp-program.prog-comment = substring(v-read-string, length(v-conf-comment) + 1)
          .
        end.
        else do:
          message
            "Ошибка задания конфигурации" skip
            "Сначала необходимо задать имя программы при помощи строки" v-conf-name skip
            "Файл конфигурации" v-read-file skip
            "Номер строки" v-curr-string skip
            "Строка" v-read-string skip
            view-as alert-box error .
        end.
      end.

      if v-process-string = false
      then do:
        message
          "Ошибка задания конфигурации" skip
          "Неизвестный формат строки файла конфигурации" skip
          "Файл конфигурации" v-read-file skip
          "Номер строки" v-curr-string skip
          "Строка" v-read-string skip
          view-as alert-box error .
      end.
    end.

    input stream readconf close .
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE start-program Dialog-Frame
PROCEDURE start-program :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  if not available temp-program
  then do:
    message
      "Не выбрана программа" skip
      view-as alert-box .
    return . /* --->>>--- */
  end.

  run gbl/open_url.p
    (input temp-program.prog-path
    ) .


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
