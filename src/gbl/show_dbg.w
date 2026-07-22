&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12 GUI
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

Просмотр файла

Автор: Перваков Михаил Сергеевич
Дата создания: 02/25/05
Author: Mikhail Pervakov
Creation date: 02/25/05

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
{ gbl/prwnshow.i }

define input  parameter table for temp-show-file .
define input  parameter p-line-num as integer   no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Просмотр файла".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i  }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BROWSE-3

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES temp-show-file

/* Definitions for BROWSE BROWSE-3                                      */
&Scoped-define FIELDS-IN-QUERY-BROWSE-3 temp-show-file.line-text   
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-3   
&Scoped-define SELF-NAME BROWSE-3
&Scoped-define QUERY-STRING-BROWSE-3 FOR EACH temp-show-file by temp-show-file.line-num   indexed-reposition
&Scoped-define OPEN-QUERY-BROWSE-3 OPEN QUERY {&SELF-NAME} FOR EACH temp-show-file by temp-show-file.line-num   indexed-reposition .
&Scoped-define TABLES-IN-QUERY-BROWSE-3 temp-show-file
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-3 temp-show-file


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BROWSE-3}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-goto b-search b-help BROWSE-3 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-exit AUTO-GO 
     LABEL "&Выход" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-goto 
     LABEL "&Перейти" 
     SIZE 10 BY 1.

DEFINE BUTTON b-help 
     LABEL "Помо&щь" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-search 
     LABEL "По&иск" 
     SIZE 10 BY 1.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BROWSE-3 FOR 
      temp-show-file SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BROWSE-3
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-3 Dialog-Frame _FREEFORM
  QUERY BROWSE-3 DISPLAY
      temp-show-file.line-text
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 126 BY 28 ROW-HEIGHT-CHARS .67 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-goto AT ROW 1 COL 11
     b-search AT ROW 1 COL 21
     b-help AT ROW 1 COL 31
     BROWSE-3 AT ROW 2.25 COL 1.5
     SPACE(0.24) SKIP(0.20)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Просмотр файла"
         DEFAULT-BUTTON b-exit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BROWSE-3 b-help Dialog-Frame */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-3
/* Query rebuild information for BROWSE BROWSE-3
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH temp-show-file by temp-show-file.line-num
  indexed-reposition .
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE BROWSE-3 */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Просмотр файла */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-goto
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-goto Dialog-Frame
ON CHOOSE OF b-goto IN FRAME Dialog-Frame /* Перейти */
DO:
  define variable v-max-line      as integer   no-undo .
  define variable v-max-line-char as character no-undo .

  define buffer buf_temp-show-file for temp-show-file .

  find last buf_temp-show-file
    use-index xpk
    no-error .
  if available buf_temp-show-file
  then do:
    assign
      v-max-line = buf_temp-show-file.line-num
    .
  end.
  else do:
    message
      "В файле нет ни одной строки" skip
      "Нельзя произвести переход по номеру строки" skip
      view-as alert-box error .
    return no-apply .
  end.

  assign
    v-max-line-char = string(v-max-line)
  .
  run gbl/d-prompt.w (
      'title=':u + "Введите номер строки" + '\':u
    + 'text1=':u + "Введите номер строки" + '\':u
    + 'text2=':u + substitute("от 1 до &1", v-max-line) + '\':u
    + 'format=>>>>>>9\':u
    + 'type=int\':u
    ,input-output v-max-line-char
    ).
  if return-value = 'false':u
  then do:
    return no-apply .
  end.

  assign
    v-max-line = integer(v-max-line-char)
  .

  find first buf_temp-show-file
    where buf_temp-show-file.line-num = v-max-line
    no-error .
  if available buf_temp-show-file
  then do:
    reposition {&browse-name} to rowid rowid(buf_temp-show-file) .
  end.
  else do:
    message
      "В файле отсутствует строка с номером" v-max-line skip
      view-as alert-box error .
    undo, return no-apply .
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-search
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-search Dialog-Frame
ON CHOOSE OF b-search IN FRAME Dialog-Frame /* Поиск */
DO:
  define variable v-search-string as character no-undo .
  define variable v-ok            as logical   no-undo .

  run gbl/d-prompt.w (
      'title=':u + "Введите строку поиска" + '\':u
    + 'text1=':u + "Введите строку поиска" + '\':u
    + 'format=x(255)\':u
    + 'type=char\':u
    + 'fillin_width=60\':u
    ,input-output v-search-string
    ).
  if return-value = 'false':u
  then do:
    return no-apply .
  end.

  define buffer buf_temp-show-file for temp-show-file .

  define variable v-start-search-num as integer   no-undo .
  define variable v-last-search-num  as integer   no-undo .
  define variable v-can-wrap         as logical   no-undo .
  define variable v-find-str         as logical   no-undo .

  assign
    v-start-search-num = temp-show-file.line-num
    v-can-wrap         = true
    v-find-str         = false
  .

  assign
    v-last-search-num = temp-show-file.line-num
  .
  search_block :
  do while true
  :
    find first buf_temp-show-file
      where buf_temp-show-file.line-num = v-last-search-num
      no-error .
    if not available buf_temp-show-file
    then do:
      if  v-start-search-num > 1
      and v-can-wrap = true
      then do:
        message
          "Строка не найдена" skip
          "Строка поиска" v-search-string  skip
          "Продолжить поиск с начала файла?" skip
          view-as alert-box question buttons yes-no update v-ok
          .
        if v-ok = true
        then do:
          assign
            v-can-wrap = false
          .
          find first buf_temp-show-file
            use-index xpk
            no-error .
        end.
        else do:
          leave search_block .
        end.
      end.
      else do:
        leave search_block .
      end.
    end.
    if buf_temp-show-file.line-text matches '*':u + v-search-string + '*':u
    then do:
      assign
        v-find-str = true
      .
      reposition {&browse-name} to rowid rowid(buf_temp-show-file) .
      leave search_block .
    end.

    assign
      v-last-search-num = v-last-search-num + 1
    .
  end.

  if v-find-str <> true
  then do:
    message
      "Строка поиска на найдена" skip
      "Строка поиска" v-search-string skip
      view-as alert-box error .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-3
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/brwrepos.i
  &line-num=10
}
{ gbl/app_help.i &disable_diasize=true}

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  RUN enable_UI.

  define buffer buf_temp-show-file for temp-show-file .
  find first buf_temp-show-file
    where buf_temp-show-file.line-num = p-line-num
    no-error .
  if available buf_temp-show-file
  then do:
    reposition {&browse-name} to rowid rowid(buf_temp-show-file) .
  end.

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
  ENABLE b-exit b-goto b-search b-help BROWSE-3 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

