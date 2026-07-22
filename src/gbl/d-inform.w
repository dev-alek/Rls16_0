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

Информационное окно

Автор: Перваков Михаил Сергеевич
Дата создания: 03/10/01
Author: Mikhail Pervakov
Creation date: 03/10/01

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input  parameter h_focus-widget      as handle    no-undo .
define input  parameter h_current-procedure as handle    no-undo .
define output parameter p-action            as character no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Информационное окно".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ str/lib-trn.i  }


/* временная таблица, в которой описаны все действия */
define temp-table action-table no-undo
  field action-group        as character  format "x(10)"   label "Group"
  field action-num          as character  format "x(3)"    label "N"
  field action-name         as character  format "x(15)"   label "Name"
  field action-description  as character  format "x(30)"   label "Description"
  field action-external     as logical    format "ext/int" label "Ext"
  field action-close-dialog as logical
  field action-procedure    as character  format "x(30)"   label "Procedure"

  index xpk is primary unique action-num
.

define variable v-proc-name as character no-undo .

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
&Scoped-define INTERNAL-TABLES action-table

/* Definitions for BROWSE BROWSE-1                                      */
&Scoped-define FIELDS-IN-QUERY-BROWSE-1 action-group action-num action-name action-description action-external action-procedure
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-1
&Scoped-define SELF-NAME BROWSE-1
&Scoped-define OPEN-QUERY-BROWSE-1 /* OPEN QUERY {&SELF-NAME} FOR EACH action-table . */ run open-query in this-procedure .
&Scoped-define TABLES-IN-QUERY-BROWSE-1 action-table
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-1 action-table


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BROWSE-1}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS cb-category b-exit b-sel b-help BROWSE-1
&Scoped-Define DISPLAYED-OBJECTS cb-category

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-exit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-sel
     LABEL "В&ыполнить"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE cb-category AS CHARACTER FORMAT "X(256)":U
     LABEL "Category"
     VIEW-AS COMBO-BOX INNER-LINES 10
     LIST-ITEMS "Item 1"
     DROP-DOWN-LIST
     SIZE 16 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BROWSE-1 FOR
      action-table SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BROWSE-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-1 Dialog-Frame _FREEFORM
  QUERY BROWSE-1 DISPLAY
      action-group
      action-num
      action-name
      action-description
      action-external
      action-procedure
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 83.13 BY 15.08.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     cb-category AT ROW 1.08 COL 54.38 COLON-ALIGNED
     b-exit AT ROW 1.13 COL 1.75
     b-sel AT ROW 1.17 COL 13.63
     b-help AT ROW 1.21 COL 25.5
     BROWSE-1 AT ROW 2.42 COL 1.75
     SPACE(1.36) SKIP(0.45)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Information  Dialog"
         DEFAULT-BUTTON b-sel CANCEL-BUTTON b-exit.


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
/* BROWSE-TAB BROWSE-1 b-help Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       BROWSE-1:NUM-LOCKED-COLUMNS IN FRAME Dialog-Frame     = 2.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-1
/* Query rebuild information for BROWSE BROWSE-1
     _START_FREEFORM
/* OPEN QUERY {&SELF-NAME} FOR EACH action-table . */
run open-query in this-procedure .
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE BROWSE-1 */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Information  Dialog */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel Dialog-Frame
ON CHOOSE OF b-sel IN FRAME Dialog-Frame /* Выполнить */
DO:
  run perform-action in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-1
&Scoped-define SELF-NAME BROWSE-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-1 Dialog-Frame
ON DEFAULT-ACTION OF BROWSE-1 IN FRAME Dialog-Frame
DO:
  run perform-action in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME cb-category
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL cb-category Dialog-Frame
ON VALUE-CHANGED OF cb-category IN FRAME Dialog-Frame /* Category */
DO:
  run open-query in this-procedure .
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

  define variable l-permit as logical no-undo .

  if connected("ub") = true
  then do:
    run gbl/authoriz_main.p
      (input "Run information dialog"
      ,output l-permit
      ).
  end.
  else do:
    assign
      l-permit = true
    .
  end.

  if l-permit <> true
  then do:
    undo main-block, leave main-block .
  end.

  run make-temp-table in this-procedure .

  run update-cb-category in this-procedure .

  RUN enable_UI.

  apply "entry" to browse {&browse-name} .

  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.

RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE action-break-point Dialog-Frame
PROCEDURE action-break-point :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define variable lok as logical no-undo .

  run get-proc-name in this-procedure
    (input "Установить точку останова" /* p-title */
    ,output lok                        /* p-ok    */
    ).
  if lok
  then do:
    debugger:set-break(v-proc-name).
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE action-check-seq Dialog-Frame
PROCEDURE action-check-seq :
  run adm/restseqr.p
    ( input "check":U
     ,input "":U
     ,input no
    ) no-error .

  if error-status :error then do:
    return error return-value .
  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE action-check-syntax Dialog-Frame
PROCEDURE action-check-syntax :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define variable lok             as logical   no-undo .
  define variable h-proc-handle   as handle    no-undo .

  run get-proc-name in this-procedure
    (input "Run procedure" /* p-title */
    ,output lok            /* p-ok    */
    ).
  if lok
  then do:
    do
    on error undo, return no-apply
    :
      compile value (v-proc-name) .
      if compiler :error
      then do:
/*        message*/
/*          "Compilation error" COMPILER:FILENAME skip*/
/*          "Line"  COMPILER:ERROR-ROW skip*/
/*          view-as alert-box error .*/
      end.
      else do:
        message
          "Syntax is correct"
          view-as alert-box information .
      end.
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE action-clear-library Dialog-Frame
PROCEDURE action-clear-library :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define variable lok as logical no-undo .

  message
    "Очистка библиотечных процедур" skip
    "Продолжить?" skip
    view-as alert-box question buttons yes-no update lok .

  if lok = true
  then do:
    run gbl/clearlib.p .
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE action-cmdstring Dialog-Frame
PROCEDURE action-cmdstring :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define variable v-cmd-str as character no-undo .
  define variable v-exefile as character no-undo .
  define variable v-inifile as character no-undo .

  run gbl/getcmdln.p
    (output v-cmd-str /* chrCommandLine */
    ) .

  run gbl/d-prompt.w
    (input  'title=':u + "Командная строка запуска системы" + '\':u
    + 'text1=':u + "Командная строка запуска системы" + '\':u
    + 'format=x(256)\':u
    + 'fillin_width=80\':u
    + 'type=char\':u
    ,input-output v-cmd-str
    ).
  if return-value = 'false':u
  then do:
    return .
  end.

  run gbl/getexini.p
    (output v-exefile /* p-exefile */
    ,output v-inifile /* p-inifile */
    ).
  run gbl/d-prompt.w
    (input  'title=':u + "Путь к исполняемому файлу progress" + '\':u
    + 'text1=':u + "Путь к исполняемому файлу progress" + '\':u
    + 'format=x(256)\':u
    + 'fillin_width=80\':u
    + 'type=char\':u
    ,input-output v-exefile
    ).
  if return-value = 'false':u
  then do:
    return .
  end.

  run gbl/d-prompt.w
    (input  'title=':u + "Путь к *.ini файлу" + '\':u
    + 'text1=':u + "Путь к *.ini файлу" + '\':u
    + 'format=x(256)\':u
    + 'fillin_width=80\':u
    + 'type=char\':u
    ,input-output v-inifile
    ).
  if return-value = 'false':u
  then do:
    return .
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE action-conpar Dialog-Frame
PROCEDURE action-conpar :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

  define variable cConnect as character no-undo .

  GET-KEY-VALUE SECTION "REP-SETS" KEY "ConPar" VALUE cConnect.

  run gbl/d-prompt.w
    (input  'title=':u + "Параметры подключения к базе данных" + '\':u
    + 'text1=':u + "Параметры подключения к базе данных" + '\':u
    + 'text2=':u + "Задается в *.ini файле: секция ConPar, параметр REP-SETS" + '\':u
    + 'format=x(256)\':u
    + 'type=edit\':u
    + 'fillin_width=70\':u
    + 'fillin_height=6\':u
    + 'max-chars=256\':u
    + 'readonly=yes\':u
    ,input-output cConnect
    ).

  assign
    cConnect = dbparam('ub':U)
  .

  run gbl/d-prompt.w
    (input  'title=':u + "Параметры подключения к базе данных" + '\':u
    + 'text1=':u + "Параметры подключения, возвращаемые Progress" + '\':u
    + 'type=edit\':u
    + 'fillin_width=70\':u
    + 'fillin_height=6\':u
    + 'max-chars=256\':u
    + 'readonly=yes\':u
    ,input-output cConnect
    ).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE action-obj-info Dialog-Frame
PROCEDURE action-obj-info :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

  if valid-handle (h_focus-widget) then do:
    run gbl/d-infobj.w
      (input h_focus-widget
      ) .
  end.
  else do:
    message
      "There is no object in focus"
      view-as alert-box .
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE action-rest-seq Dialog-Frame
PROCEDURE action-rest-seq :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

  define variable lok as logical   no-undo .

  message
    "Восстановить значения счетчиков на основании информации," skip
    "содержащейся в первичных ключах БД." skip
    "Продолжить?" skip
    view-as alert-box question buttons yes-no update lok .
  if lok <> true
  then do:
    return .
  end.

  run adm/restseqr.p
    ( input "rest":U
     ,input "":U
     ,input no
    ) no-error .

  if error-status :error then do:
    return error return-value .
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE action-run-procedure Dialog-Frame
PROCEDURE action-run-procedure :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

  define variable v-parparentproc as handle no-undo .

  if lookup(h_current-procedure :file-name
            ,'gbl/mainmenu.w'
            ) > 0
  then do:
    assign
      v-parparentproc = h_current-procedure
    .
  end.
  else do:
    assign
      v-parparentproc = ?
    .
  end.

  run gbl/d-runpro.w
    (input v-parparentproc
    ) .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE action-search-procedure Dialog-Frame
PROCEDURE action-search-procedure :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define variable v-canonic-proc-name as character no-undo .

  run gbl/d-prompt.w
    (input 'title=Search procedure\'
    + 'text1=Enter procedure name\'
    + 'format=x(40)\'
    + 'type=char\'
    + 'boxprog=getfile.p\'
    ,input-output v-proc-name
    ).

  do
  on error undo, return no-apply
  on stop undo, return no-apply
  :
    if return-value <> "false":u
    then do:
      assign
        v-canonic-proc-name = entry(1, v-proc-name, '.')
      .

      define variable v-proc-name-p as character no-undo .
      define variable v-proc-name-w as character no-undo .
      define variable v-proc-name-i as character no-undo .
      define variable v-proc-name-r as character no-undo .

      assign
        v-proc-name-p = search(v-canonic-proc-name + '.p')
        v-proc-name-w = search(v-canonic-proc-name + '.w')
        v-proc-name-i = search(v-canonic-proc-name + '.i')
        v-proc-name-r = search(v-canonic-proc-name + '.r')
      .

      message
        "P-code:" {&tabulation} v-proc-name-p skip
        "W-code:" {&tabulation} v-proc-name-w skip
        "I-code:" {&tabulation} v-proc-name-i skip
        "R-code:" {&tabulation} v-proc-name-r skip
        view-as alert-box information title "Search: " + v-canonic-proc-name.

    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE action-show-context Dialog-Frame
PROCEDURE action-show-context :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  define variable v-parparentproc as handle no-undo .

  if lookup(h_current-procedure :file-name
            ,'gbl/mainmenu.w'
            ) > 0
  then do:
    assign
      v-parparentproc = h_current-procedure
    .
  end.
  else do:
    assign
      v-parparentproc = ?
    .
  end.

  run gbl/show-gbl.p
    (input v-parparentproc
    ) .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE action-show-lock Dialog-Frame
PROCEDURE action-show-lock :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

  do
  on error undo, return error return-value
  on stop  undo, return error return-value
  :
    run gbl/d-lock.w .
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
  DISPLAY cb-category
      WITH FRAME Dialog-Frame.
  ENABLE cb-category b-exit b-sel b-help BROWSE-1
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-proc-name Dialog-Frame
PROCEDURE get-proc-name :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define input parameter  p-title as character no-undo .
  define output parameter p-ok    as logical   no-undo .

  define variable v-new-proc-name    as character no-undo .
  define variable v-search-proc-name as character no-undo .
  define variable v-use-prog         as logical   no-undo .

  assign
    p-ok            = false
    v-new-proc-name = v-proc-name
  .

  run gbl/d-prompt.w
    (input  'title=':U + p-title + '\':U
    + 'text1=':U + "Введите имя программы" + '\':U
    + 'format=x(40)\':U
    + 'type=char\':U
    + 'boxprog=getfile.p\':U
    ,input-output v-new-proc-name
    ).
  if return-value <> 'false':U
  then do:
    assign
      v-proc-name = v-new-proc-name
    .

    /* ищем процедуру */

    search_block:
    do
    :
      define variable v-index-sub-dir       as integer   no-undo .
      define variable v-sub-dir-list        as character no-undo .
      define variable v-num-entries-sub-dir as integer   no-undo .
      define variable v-sub-dir-item        as character no-undo .
      define variable v-index-suffix        as integer   no-undo .
      define variable v-suffix-list         as character no-undo .
      define variable v-num-entries-suffix  as integer   no-undo .
      define variable v-suffix-item         as character no-undo .

      assign
        v-sub-dir-list        = ',adm/,arc/,bge/,cmp/,cus/,exe/,gbl/,nws/,osn/,rcs/,ref/,rep/,str/,trg/,utl/':U
        v-num-entries-sub-dir = num-entries(v-sub-dir-list)
        v-suffix-list         = ',.p,.w':U
        v-num-entries-suffix  = num-entries(v-suffix-list)
      .

      do v-index-sub-dir = 1 to v-num-entries-sub-dir
      :
        assign
          v-sub-dir-item = entry(v-index-sub-dir, v-sub-dir-list)
        .

        do v-index-suffix = 1 to v-num-entries-suffix
        :
          assign
            v-suffix-item = entry(v-index-suffix, v-suffix-list)
          .

          assign
            v-search-proc-name = search(v-sub-dir-item + v-proc-name + v-suffix-item)
          .
          if v-search-proc-name <> ?
          then do:
            message
              p-title skip
              substitute("Найдена процедура &1", v-search-proc-name) skip
              "Использовать её?" skip
              view-as alert-box question buttons yes-no update v-use-prog .
            if v-use-prog = true
            then do:
              assign
                v-proc-name = v-sub-dir-item + v-proc-name + v-suffix-item
                p-ok        = true
              .
              leave search_block . /* --->>>--- */
            end.
          end.
        end.
      end.
    end.

    if p-ok <> true
    then do:
      message
        p-title skip
        "Процедура не найдена" skip
        "Имя процедуры" v-proc-name skip
        "Продолжить?" skip
        view-as alert-box warning buttons yes-no update p-ok .
    end.
  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE make-temp-table Dialog-Frame
PROCEDURE make-temp-table :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

  do
  on error undo, return error
  :
    create action-table .
    assign
      action-table.action-group        = "Common"
      action-table.action-num          = "10"
      action-table.action-name         = "Pr Editor"
      action-table.action-description  = "Launch Procedure Editor"
      action-table.action-external     = false
      action-table.action-close-dialog = true
      action-table.action-procedure    = "run,_edit.p"
    .

    create action-table .
    assign
      action-table.action-group        = "Procedure"
      action-table.action-num          = "11"
      action-table.action-name         = "Run Proc."
      action-table.action-description  = "Run procedure"
      action-table.action-external     = false
      action-table.action-close-dialog = false
      action-table.action-procedure    = "action-run-procedure"
    .

    create action-table .
    assign
      action-table.action-group        = "Common"
      action-table.action-num          = "12"
      action-table.action-name         = "Check Sum"
      action-table.action-description  = "Check system integrity"
      action-table.action-external     = true
      action-table.action-close-dialog = false
      action-table.action-procedure    = "gbl/chksum.p"
    .

    create action-table .
    assign
      action-table.action-group        = "Procedure"
      action-table.action-num          = "13"
      action-table.action-name         = "Trace log"
      action-table.action-description  = "Trace program execution"
      action-table.action-external     = false
      action-table.action-close-dialog = true
      action-table.action-procedure    = "runpersistent,logger.w"
    .

    create action-table .
    assign
      action-table.action-group        = "Common"
      action-table.action-num          = "14"
      action-table.action-name         = "Proc. Info"
      action-table.action-description  = "Display Procedure Stack Information"
      action-table.action-external     = true
      action-table.action-close-dialog = false
      action-table.action-procedure    = "gbl/prwnshow.p"
    .

    create action-table .
    assign
      action-table.action-group        = "Common"
      action-table.action-num          = "15"
      action-table.action-name         = "Object Info"
      action-table.action-description  = "Display interface object information"
      action-table.action-external     = false
      action-table.action-close-dialog = false
      action-table.action-procedure    = "action-obj-info"
    .

    create action-table .
    assign
      action-table.action-group        = "Common"
      action-table.action-num          = "16"
      action-table.action-name         = "Conn. DB"
      action-table.action-description  = "Connected Database Information"
      action-table.action-external     = false
      action-table.action-close-dialog = true
      action-table.action-procedure    = "run,protools/_dblist.w"
    .

    create action-table .
    assign
      action-table.action-group        = "Common"
      action-table.action-num          = "17"
      action-table.action-name         = "Messages"
      action-table.action-description  = "Display recent system error messages"
      action-table.action-external     = true
      action-table.action-close-dialog = false
      action-table.action-procedure    = "prohelp/_rcntmsg.p"
    .

    create action-table .
    assign
      action-table.action-group        = "Common"
      action-table.action-num          = "18"
      action-table.action-name         = "Propath"
      action-table.action-description  = "Propath View/Edit"
      action-table.action-external     = true
      action-table.action-close-dialog = false
      action-table.action-procedure    = "protools/_propath.p"
    .

    create action-table .
    assign
      action-table.action-group        = "Common"
      action-table.action-num          = "19"
      action-table.action-name         = "Session"
      action-table.action-description  = "Session Parameters"
      action-table.action-external     = true
      action-table.action-close-dialog = false
      action-table.action-procedure    = "protools/_session.p"
    .

    create action-table .
    assign
      action-table.action-group        = "Common"
      action-table.action-num          = "20"
      action-table.action-name         = "Pro Tools"
      action-table.action-description  = "Star Protools"
      action-table.action-external     = false
      action-table.action-close-dialog = true
      action-table.action-procedure    = "run,protools/_protool.p"
    .

    create action-table .
    assign
      action-table.action-group        = "Common"
      action-table.action-num          = "21"
      action-table.action-name         = "Con.Par."
      action-table.action-description  = "Connection Parameters"
      action-table.action-external     = false
      action-table.action-close-dialog = false
      action-table.action-procedure    = "action-conpar"
    .

    create action-table .
    assign
      action-table.action-group        = "Common"
      action-table.action-num          = "22"
      action-table.action-name         = "Cmd. String"
      action-table.action-description  = "Progress Command String"
      action-table.action-external     = false
      action-table.action-close-dialog = false
      action-table.action-procedure    = "action-cmdstring"
    .

    create action-table .
    assign
      action-table.action-group        = "Common"
      action-table.action-num          = "23"
      action-table.action-name         = "Context Vars"
      action-table.action-description  = "Show context variables"
      action-table.action-external     = true
      action-table.action-close-dialog = false
      action-table.action-procedure    = "action-show-context"
    .

    create action-table .
    assign
      action-table.action-group        = "Common"
      action-table.action-num          = "24"
      action-table.action-name         = "Show locks"
      action-table.action-description  = "Show locks"
      action-table.action-external     = false
      action-table.action-close-dialog = false
      action-table.action-procedure    = "action-show-lock"
    .

    create action-table .
    assign
      action-table.action-group        = "Debug"
      action-table.action-num          = "41"
      action-table.action-name         = "Debugger"
      action-table.action-description  = "Launch and Initialise Debugger"
      action-table.action-external     = true
      action-table.action-close-dialog = false
      action-table.action-procedure    = "gbl/inidebug.p"
    .

    create action-table .
    assign
      action-table.action-group        = "Debug"
      action-table.action-num          = "42"
      action-table.action-name         = "Break Point"
      action-table.action-description  = "Set Break Point"
      action-table.action-external     = false
      action-table.action-close-dialog = false
      action-table.action-procedure    = "action-break-point"
    .

    create action-table .
    assign
      action-table.action-group        = "Data"
      action-table.action-num          = "50"
      action-table.action-name         = "ERWin df"
      action-table.action-description  = "Generate df for ERWin synchronisation"
      action-table.action-external     = true
      action-table.action-close-dialog = false
      action-table.action-procedure    = "utl/df_erwin.p"
    .

    create action-table .
    assign
      action-table.action-group        = "Data"
      action-table.action-num          = "51"
      action-table.action-name         = "Make price.df"
      action-table.action-description  = "Generate price.df for denomination"
      action-table.action-external     = true
      action-table.action-close-dialog = false
      action-table.action-procedure    = "utl/df_price.p"
    .

    create action-table .
    assign
      action-table.action-group        = "Data"
      action-table.action-num          = "52"
      action-table.action-name         = "DF Description"
      action-table.action-description  = "Generate DF descriptions for translation"
      action-table.action-external     = true
      action-table.action-close-dialog = false
      action-table.action-procedure    = "utl/dfdescr.p"
    .

    create action-table .
    assign
      action-table.action-group        = "Data"
      action-table.action-num          = "53"
      action-table.action-name         = "Inactive Idx"
      action-table.action-description  = "Check Inactive Indexes"
      action-table.action-external     = true
      action-table.action-close-dialog = false
      action-table.action-procedure    = "utl/idxinact.p"
    .

    create action-table .
    assign
      action-table.action-group        = "Data"
      action-table.action-num          = "54"
      action-table.action-name         = "DF Duplicate"
      action-table.action-description  = "Generate DF duplicate"
      action-table.action-external     = true
      action-table.action-close-dialog = false
      action-table.action-procedure    = "utl/dfdupl.p"
    .

    create action-table .
    assign
      action-table.action-group        = "Data"
      action-table.action-num          = "55"
      action-table.action-name         = "Check Seq."
      action-table.action-description  = "Check sequence values"
      action-table.action-external     = false
      action-table.action-close-dialog = false
      action-table.action-procedure    = "action-check-seq"
    .

    create action-table .
    assign
      action-table.action-group        = "Data"
      action-table.action-num          = "56"
      action-table.action-name         = "Rest. Seq."
      action-table.action-description  = "Restore sequence values"
      action-table.action-external     = false
      action-table.action-close-dialog = false
      action-table.action-procedure    = "action-rest-seq"
    .

    create action-table .
    assign
      action-table.action-group        = "Data"
      action-table.action-num          = "57"
      action-table.action-name         = "Check DB schema"
      action-table.action-description  = "Check database schema"
      action-table.action-external     = true
      action-table.action-close-dialog = false
      action-table.action-procedure    = "utl/chkdd.p"
    .

    create action-table .
    assign
      action-table.action-group        = "Data"
      action-table.action-num          = "58"
      action-table.action-name         = "Check c-"
      action-table.action-description  = "Check table where deleted documents stored"
      action-table.action-external     = true
      action-table.action-close-dialog = false
      action-table.action-procedure    = "utl/compc-f.p"
    .

    create action-table .
    assign
      action-table.action-group        = "Data"
      action-table.action-num          = "59"
      action-table.action-name         = "DF Descr. Format"
      action-table.action-description  = "Create database description and format df file"
      action-table.action-external     = true
      action-table.action-close-dialog = false
      action-table.action-procedure    = "utl/dfdscfrm.p"
    .

    create action-table .
    assign
      action-table.action-group        = "Data"
      action-table.action-num          = "61"
      action-table.action-name         = "Gen. Include"
      action-table.action-description  = "Generate include files for news and database utilities"
      action-table.action-external     = true
      action-table.action-close-dialog = false
      action-table.action-procedure    = "utl/gen-main.p"
    .

    create action-table .
    assign
      action-table.action-group        = "Data"
      action-table.action-num          = "62"
      action-table.action-name         = "Gen. Include"
      action-table.action-description  = "Generate include files for cutting utilities"
      action-table.action-external     = true
      action-table.action-close-dialog = false
      action-table.action-procedure    = "utl/gencutld.p"
    .


    create action-table .
    assign
      action-table.action-group        = "Procedure"
      action-table.action-num          = "63"
      action-table.action-name         = "Check Syntax"
      action-table.action-description  = "Check Syntax of procedure"
      action-table.action-external     = false
      action-table.action-close-dialog = false
      action-table.action-procedure    = "action-check-syntax"
    .

    create action-table .
    assign
      action-table.action-group        = "Procedure"
      action-table.action-num          = "64"
      action-table.action-name         = "Search Proc."
      action-table.action-description  = "Search procedure"
      action-table.action-external     = false
      action-table.action-close-dialog = false
      action-table.action-procedure    = "action-search-procedure"
    .

    create action-table .
    assign
      action-table.action-group        = "Procedure"
      action-table.action-num          = "65"
      action-table.action-name         = "Upd ub.exe"
      action-table.action-description  = "Обновление болванки"
      action-table.action-external     = true
      action-table.action-close-dialog = false
      action-table.action-procedure    = "utl/ubexeupd.p"
    .
    
    create action-table .
    assign
      action-table.action-group        = "Procedure"
      action-table.action-num          = "66"
      action-table.action-name         = "ObjReg"
      action-table.action-description  = "Загруженные объекты"
      action-table.action-external     = true
      action-table.action-close-dialog = false
      action-table.action-procedure    = "utl/objreg.w"
    .

    create action-table .
    assign
      action-table.action-group        = "Procedure"
      action-table.action-num          = "67"
      action-table.action-name         = "GenDF"
      action-table.action-description  = "Генерация DF-файла"
      action-table.action-external     = true
      action-table.action-close-dialog = false
      action-table.action-procedure    = "utl/gendffile.w"
    .

    create action-table .
    assign
      action-table.action-group        = "Procedure"
      action-table.action-num          = "68"
      action-table.action-name         = "Clear Library"
      action-table.action-description  = "Clear library"
      action-table.action-external     = false
      action-table.action-close-dialog = false
      action-table.action-procedure    = "action-clear-library"
    .

    create action-table .
    assign
      action-table.action-group        = "Procedure"
      action-table.action-num          = "69"
      action-table.action-name         = "R-Code inf"
      action-table.action-description  = "Display R-Code information"
      action-table.action-external     = true
      action-table.action-close-dialog = false
      action-table.action-procedure    = "gbl/rcodeinf.p"
    .
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE open-query Dialog-Frame
PROCEDURE open-query :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

  do with frame {&frame-name}:
    open query {&browse-name} for each action-table
      where (cb-category :screen-value = "ALL")
        or (action-table.action-group = cb-category :screen-value)
        .
  end. /* do with frame */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE perform-action Dialog-Frame
PROCEDURE perform-action :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

  do
  on error undo, return no-apply
  on stop undo, return no-apply
  :
    if available action-table
    then do:
      if action-table.action-close-dialog = true
      then do:
        ASSIGN
          p-action = action-table.action-procedure
        .
        apply "go" to frame {&frame-name} .
      end.
      else do:
        if action-table.action-external = true
        then do:
          run value(action-table.action-procedure) .
        end.
        else do:
          run value(action-table.action-procedure) in this-procedure .
        end.
      end.
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE update-cb-category Dialog-Frame
PROCEDURE update-cb-category :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

  define buffer buf_action-table for action-table .

  do with frame {&frame-name}:
    define variable v-ok as logical   no-undo .
    assign
      cb-category :list-items = "ALL"
    .

    for each buf_action-table
      break by buf_action-table.action-group
    :
      if first-of(buf_action-table.action-group)
      then do:
        assign
          v-ok = cb-category :add-last(buf_action-table.action-group)
        .
      end.
    end.

    assign
      cb-category :screen-value = "ALL"
    .
  end. /* do with frame */


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME