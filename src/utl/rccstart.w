&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME upg-load
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS upg-load
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Вызов программы сравнения директорий *.r кодов

Автор: Белоусов Илья Александрович
Дата создания: 11/22/07
Author: Ilia Belousov
Creation date: 11/22/07

Input:

Output:

*/
/* Create an unnamed pool to store all the widgets created
     by this procedure. This is a good default which assures
     that this procedure's triggers and internal procedures
     will execute in this procedure's storage, and that proper
     cleanup will occur on deletion of the procedure. */

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Вызов программы сравнения директорий *.r кодов".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/xmldom.i   }

define variable v-file-name as character no-undo .
define variable v-old-dir1  as character no-undo .
define variable v-old-dir2  as character no-undo .
define variable v-old-dir3  as character no-undo .

define stream sinp .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME DEFAULT-FRAME

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-compare b-quit log-edit
&Scoped-Define DISPLAYED-OBJECTS log-edit

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR upg-load AS WIDGET-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-compare DEFAULT
     LABEL "&Сравнение"
     SIZE 13 BY 1.

DEFINE BUTTON b-quit DEFAULT
     LABEL "Вы&ход"
     SIZE 10 BY 1.

DEFINE VARIABLE log-edit AS CHARACTER
     VIEW-AS EDITOR NO-WORD-WRAP SCROLLBAR-HORIZONTAL SCROLLBAR-VERTICAL LARGE
     SIZE 76.13 BY 13.92 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME DEFAULT-FRAME
     b-compare AT ROW 1 COL 1
     b-quit AT ROW 1 COL 14
     log-edit AT ROW 2.29 COL 2.5 NO-LABEL
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS THREE-D
         AT COL 1 ROW 1
         SIZE 78.63 BY 15.92.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Window
   Allow: Basic,Browse,DB-Fields,Window,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
IF SESSION:DISPLAY-TYPE = "GUI":U THEN
  CREATE WINDOW upg-load ASSIGN
         HIDDEN             = YES
         TITLE              = "Сравнение *.r кодов"
         HEIGHT             = 15.92
         WIDTH              = 78.63
         MAX-HEIGHT         = 23.04
         MAX-WIDTH          = 100
         VIRTUAL-HEIGHT     = 23.04
         VIRTUAL-WIDTH      = 100
         RESIZE             = no
         SCROLL-BARS        = no
         STATUS-AREA        = no
         BGCOLOR            = ?
         FGCOLOR            = ?
         KEEP-FRAME-Z-ORDER = yes
         THREE-D            = yes
         MESSAGE-AREA       = no
         SENSITIVE          = yes.
ELSE {&WINDOW-NAME} = CURRENT-WINDOW.
/* END WINDOW DEFINITION                                                */
&ANALYZE-RESUME



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR FRAME DEFAULT-FRAME
   UNDERLINE                                                            */
ASSIGN
       FRAME DEFAULT-FRAME:HIDDEN           = TRUE.

ASSIGN
       log-edit:READ-ONLY IN FRAME DEFAULT-FRAME        = TRUE.

IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(upg-load)
THEN upg-load:HIDDEN = no.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME DEFAULT-FRAME
/* Query rebuild information for FRAME DEFAULT-FRAME
     _Query            is NOT OPENED
*/  /* FRAME DEFAULT-FRAME */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME upg-load
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL upg-load upg-load
ON END-ERROR OF upg-load /* Сравнение *.r кодов */
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL upg-load upg-load
ON WINDOW-CLOSE OF upg-load /* Сравнение *.r кодов */
DO:
  /* This event will close the window and terminate the procedure.  */

  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-compare
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-compare upg-load
ON CHOOSE OF b-compare IN FRAME DEFAULT-FRAME /* Сравнение */
DO:
  run start-compile in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-quit upg-load
ON CHOOSE OF b-quit IN FRAME DEFAULT-FRAME /* Выход */
DO:
  QUIT .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK upg-load


/* ***************************  Main Block  *************************** */

/* Set CURRENT-WINDOW: this will parent dialog-boxes and frames.        */
ASSIGN CURRENT-WINDOW                = {&WINDOW-NAME}
       THIS-PROCEDURE:CURRENT-WINDOW = {&WINDOW-NAME}.

/* The CLOSE event can be used from inside or outside the procedure to  */
/* terminate it.                                                        */
ON CLOSE OF THIS-PROCEDURE
   RUN disable_UI.

/* Best default for GUI applications is...                              */
PAUSE 0 BEFORE-HIDE.

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

  RUN enable_UI.

  IF NOT THIS-PROCEDURE:PERSISTENT THEN
    WAIT-FOR CLOSE OF THIS-PROCEDURE.

  /* завершаем сессию progress */
  quit .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE callback-write-to-log upg-load
PROCEDURE callback-write-to-log :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

  define input parameter p-msg-str as character no-undo .

  define variable lok as logical   no-undo .

  do with frame {&frame-name}
  on error undo, return error
  :
    assign
      lok = log-edit :move-to-eof( )
      lok = log-edit :insert-string( p-msg-str )
      lok = log-edit :move-to-eof( )
    .
  end. /* do with frame */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI upg-load  _DEFAULT-DISABLE
PROCEDURE disable_UI :
/*------------------------------------------------------------------------------
  Purpose:     DISABLE the User Interface
  Parameters:  <none>
  Notes:       Here we clean-up the user-interface by deleting
               dynamic widgets we have created and/or hide
               frames.  This procedure is usually called when
               we are ready to "clean-up" after running.
------------------------------------------------------------------------------*/
  /* Delete the WINDOW we created */
  IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(upg-load)
  THEN DELETE WIDGET upg-load.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI upg-load  _DEFAULT-ENABLE
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
  DISPLAY log-edit
      WITH FRAME DEFAULT-FRAME IN WINDOW upg-load.
  ENABLE b-compare b-quit log-edit
      WITH FRAME DEFAULT-FRAME IN WINDOW upg-load.
  VIEW FRAME DEFAULT-FRAME IN WINDOW upg-load.
  {&OPEN-BROWSERS-IN-QUERY-DEFAULT-FRAME}
  VIEW upg-load.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE read-parameters upg-load
PROCEDURE read-parameters :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define input  parameter p-file-name    as character no-undo .
define output parameter p-dir1         as character no-undo .
define output parameter p-dir2         as character no-undo .
define output parameter p-dir3         as character no-undo .

    define variable v-tag-value as character    no-undo.
    define variable v-found     as logical      no-undo.
do
on error undo, return error return-value
:
    run xmldom-clear in this-procedure.
    run xmldom-load in this-procedure ( p-file-name ) no-error.
    if error-status :error
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip(1)
            skip "Ошибка чтения файла конфигурации."
            skip return-value
            skip trim( error-status :get-message( 1 ) )
                 trim( error-status :get-message( 2 ) )
                 trim( error-status :get-message( 3 ) )
        view-as alert-box error.
        undo, return error.
    end.
    run xmldom-read-unique in this-procedure ( input "comparer":U, input "version":U, output v-tag-value, output v-found   ).
    if v-found = no
    or v-tag-value <> "2.0":U
    then do:
        message
            "Несовместимый формат файла параметров компиляции"
            skip "Файл параметров компиляции:"
            skip p-file-name
            skip (1)
            skip "Программа рассчитана на считывание файла параметров "
            skip "Версии 2.0 "
        view-as alert-box error
        title "Параметры компиляции".
        return .
    end.
    run xmldom-read-unique in this-procedure ( input "comparer":U, input "directory_old":U      , output p-dir1, output v-found   ).
    run xmldom-read-unique in this-procedure ( input "comparer":U, input "directory_new":U      , output p-dir2, output v-found   ).
    run xmldom-read-unique in this-procedure ( input "comparer":U, input "directory_patch":U    , output p-dir3, output v-found   ).
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE save-parameters upg-load
PROCEDURE save-parameters :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define input  parameter p-file-name as character no-undo .
  define input  parameter p-dir1      as character no-undo .
  define input  parameter p-dir2      as character no-undo .
  define input  parameter p-dir3      as character no-undo .

  define variable v-full-path        as character no-undo .
  define variable v-path             as character no-undo .
  define variable v-file-name        as character no-undo .
  define variable v-file-name-no-ext as character no-undo .
  define variable v-file-name-ext    as character no-undo .

  define variable v-backup-file-name as character no-undo .

do
on error undo, return error return-value
:
/*    run gbl/filename.p*/
/*      (input  p-file-name*/
/*      ,output v-full-path*/
/*      ,output v-path*/
/*      ,output v-file-name*/
/*      ,output v-file-name-no-ext*/
/*      ,output v-file-name-ext*/
/*      ).*/

    /* сохраняем резервную копию параметров */
/*    if v-full-path <> ""*/
/*    then do:*/
/*      assign*/
/*        v-backup-file-name = v-path + '/':u + v-file-name-no-ext + '/':u + '.bak':u*/
/*      .*/

/*      os-delete value(v-backup-file-name) .*/
/*      os-rename value(v-full-path) value(v-backup-file-name) .*/
/*    end.*/

    /* сохраняем параметры */
    run xmldom-clear in this-procedure .
    run xmldom-add in this-procedure ( input "comparer":U, input "version":U        , input "2.0":U ).
    run xmldom-add in this-procedure ( input "comparer":U, input "directory_old":U  , input p-dir1  ).
    run xmldom-add in this-procedure ( input "comparer":U, input "directory_new":U  , input p-dir2  ).
    run xmldom-add in this-procedure ( input "comparer":U, input "directory_patch":U, input p-dir3  ).
    run xmldom-save in this-procedure ( input p-file-name ).

end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE start-compile upg-load
PROCEDURE start-compile :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

  define variable v-dir1 as character no-undo .
  define variable v-dir2 as character no-undo .
  define variable v-dir3 as character no-undo .
  define variable v-ok   as logical   no-undo .

  assign
    v-file-name = session :parameter
  .

  if v-file-name <> ""
  then do:
    if  search(v-file-name) <> ""
    and search(v-file-name) <> ?
    then do:
      run read-parameters in this-procedure
        (input  search(v-file-name) /* p-file-name */
        ,output v-dir1              /* p-dir1      */
        ,output v-dir2              /* p-dir2      */
        ,output v-dir3              /* p-dir3      */
        ) .
    end.
    else do:
      message
        "Не найден файл параметров" skip
        "Имя файла" v-file-name skip
        view-as alert-box error .
    end.
  end.

  assign
    v-old-dir1 = v-dir1
    v-old-dir2 = v-dir2
    v-old-dir3 = v-dir3
  .

  run utl/d-dirinp.w
    (input-output v-dir1 /* p-dir1 */
    ,input-output v-dir2 /* p-dir2 */
    ,input-output v-dir3 /* p-dir3 */
    ) .
  if v-dir1 = ""
  or v-dir2 = ""
  or v-dir3 = ""
  then do:
    return .
  end.

  if v-dir1 <> v-old-dir1
  or v-dir2 <> v-old-dir2
  or v-dir3 <> v-old-dir3
  then do:
    if v-file-name <> ""
    then do:
      assign
        v-ok = true
      .
      message
        "Файл с параметрами по умолчанию" search(v-file-name) skip
        "Вы изменили параметры сравнения файлов" skip
        "Сохранить новые значения параметров?" skip
        view-as alert-box question buttons yes-no update v-ok .
      if v-ok = true
      then do:
        run save-parameters in this-procedure
          (input  ( if search( v-file-name ) = ? then v-file-name else search( v-file-name ) ) /* p-file-name */
          ,input  v-dir1              /* p-dir1      */
          ,input  v-dir2              /* p-dir2      */
          ,input  v-dir3              /* p-dir3      */
          ) .
      end.
    end.
  end.

  if  v-file-name <> ""
  and v-file-name <> ?
  and (search(v-file-name) = ""
       or search(v-file-name) = ?
      )
  then do:
    assign
      v-ok = true
    .
    message
      "Имя файла" v-file-name skip
      "Файл с параметрами по умолчанию отсутствует" skip
      "Создать файл с параметрами?" skip
      view-as alert-box question buttons yes-no update v-ok .
    if v-ok = true
    then do:
      run save-parameters in this-procedure
        (input  v-file-name /* p-file-name */
        ,input  v-dir1      /* p-dir1      */
        ,input  v-dir2      /* p-dir2      */
        ,input  v-dir3      /* p-dir3      */
        ) .
    end.
  end.

  run utl/rcodecmp.p
    (input v-dir1 /* p-dir1 */
    ,input v-dir2 /* p-dir2 */
    ,input v-dir3 /* p-dir3 */
    ) .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME