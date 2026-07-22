block-level on error undo, throw.
&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME w-login
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS w-login
/*

$Revision: 21e3183bea69, 738, rls $
$Author: SShalanin $
$Date: Mon Aug 01 17:35:56 2016 +0300 $
$Workfile: l-i-mtps.p $
$Archive: adm/l-i-mtps.p $

Окно входа в систему обмена информации с радиотерминалом

Автор: Хныкин Павел Андреевич
Дата создания:
Author: Pavel Khnykin
Creation date:

create: Перваков Михаил Сергеевич
Дата создания: 04/05/06

*/

/* ***************************  Definitions  ************************** */

define variable vss-revision    as character no-undo init "$Revision: 21e3183bea69, 738, rls $":U .
define variable vss-author      as character no-undo init "$Author: SShalanin $":U .
define variable vss-date        as character no-undo init "$Date: Mon Aug 01 17:35:56 2016 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: l-i-mtps.p $":U .
define variable vss-archive     as character no-undo init "$Archive: adm/l-i-mtps.p $":U .
define variable vss-description as character no-undo init "Окно входа в систему".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }

define variable v-cConnect          as character no-undo .
define variable v-fltConnect        as character no-undo .
define variable v-user-entered      as logical   no-undo init false .
define variable v-name-for-load-cfg as character no-undo .
define variable v-name-for-init-db  as character no-undo .
define variable v-fname-cfg         as character no-undo .
define variable v-err-code          as integer   no-undo .
define variable v-try-connect       as logical   no-undo init false .
define variable v-is-copy           as logical   no-undo init false .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE WINDOW
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME FRAME-A

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS IMAGE-1 name password b-OK b-quit FILL-IN-1 ~
FILL-IN-2
&Scoped-Define DISPLAYED-OBJECTS FILL-IN-1 FILL-IN-2

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR w-login AS WIDGET-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-OK AUTO-GO
     LABEL "&Ввод":L
     SIZE 10 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена":L
     SIZE 10 BY 1.

DEFINE VARIABLE FILL-IN-1 AS CHARACTER FORMAT "X(256)":U INITIAL "Имя:"
      VIEW-AS TEXT
     SIZE 5 BY .67 NO-UNDO.

DEFINE VARIABLE FILL-IN-2 AS CHARACTER FORMAT "X(256)":U INITIAL "Пароль:"
      VIEW-AS TEXT
     SIZE 7.5 BY .67 NO-UNDO.

DEFINE VARIABLE name AS CHARACTER FORMAT "X(12)":U
     VIEW-AS FILL-IN
     SIZE 13.5 BY 1 NO-UNDO.

DEFINE VARIABLE password AS CHARACTER FORMAT "X(16)":U
     VIEW-AS FILL-IN
     SIZE 13.5 BY 1 NO-UNDO.

DEFINE IMAGE IMAGE-1
     FILENAME "cmp/ith.bmp":U
     STRETCH-TO-FIT RETAIN-SHAPE
     SIZE 24.75 BY 3.25.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME FRAME-A
     name AT ROW 5.75 COL 8.5 COLON-ALIGNED NO-LABEL
     password AT ROW 7 COL 8.5 COLON-ALIGNED NO-LABEL BLANK
     b-OK AT ROW 9 COL 7
     b-quit AT ROW 9 COL 17
     FILL-IN-1 AT ROW 5.92 COL 2.5 NO-LABEL
     FILL-IN-2 AT ROW 7.17 COL 2.5 NO-LABEL
     IMAGE-1 AT ROW 1.75 COL 4
    WITH 1 DOWN NO-BOX OVERLAY
         SIDE-LABELS THREE-D
         AT COL 1 ROW 1
         SIZE 30.88 BY 10.25.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: WINDOW
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
IF SESSION:DISPLAY-TYPE = "GUI":U THEN
  CREATE WINDOW w-login ASSIGN
         HIDDEN             = YES
         TITLE              = "Mobile TH Сервер касс"
         COLUMN             = 27
         ROW                = 7.58
         HEIGHT             = 10.25
         WIDTH              = 30.88
         MAX-HEIGHT         = 24.21
         MAX-WIDTH          = 100
         VIRTUAL-HEIGHT     = 24.21
         VIRTUAL-WIDTH      = 100
         RESIZE             = no
         SCROLL-BARS        = yes
         STATUS-AREA        = no
         BGCOLOR            = ?
         FGCOLOR            = ?
         THREE-D            = yes
         MESSAGE-AREA       = no
         SENSITIVE          = yes.
ELSE {&WINDOW-NAME} = CURRENT-WINDOW.
/* END WINDOW DEFINITION                                                */
&ANALYZE-RESUME



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR FRAME FRAME-A
   UNDERLINE                                                            */
/* SETTINGS FOR BUTTON b-OK IN FRAME FRAME-A
   NO-DISPLAY                                                           */
/* SETTINGS FOR BUTTON b-quit IN FRAME FRAME-A
   NO-DISPLAY                                                           */
/* SETTINGS FOR FILL-IN FILL-IN-1 IN FRAME FRAME-A
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN FILL-IN-2 IN FRAME FRAME-A
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN name IN FRAME FRAME-A
   NO-DISPLAY                                                           */
/* SETTINGS FOR FILL-IN password IN FRAME FRAME-A
   NO-DISPLAY                                                           */
IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(w-login)
THEN w-login:HIDDEN = no.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME b-OK
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-OK w-login
ON CHOOSE OF b-OK IN FRAME FRAME-A /* Ввод */
DO:
  if name :screen-value = ""
  then do:
    message
      "Введите имя пользователя"
      view-as alert-box information .
    apply "entry" to name .
    return no-apply .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK w-login


/* ***************************  Main Block  *************************** */

{ gbl/app_help.i &disable-button=yes }

{ cmp/showinf.i }

on "ENTRY" of b-ok do:
  if lastkey = keycode ("RETURN") then apply "CHOOSE" to b-ok in frame {&frame-name}.
end.

on window-close of {&window-name} do:
  apply "end-error" to frame {&frame-name}.
end.

ASSIGN
  CURRENT-WINDOW             = {&WINDOW-NAME}
  SESSION:SYSTEM-ALERT-BOXES = (CURRENT-WINDOW:MESSAGE-AREA = NO)
  session:three-d = yes
.

PAUSE 0 BEFORE-HIDE.

if session:date-format <> "dmy":U
  or session:numeric-decimal-point <> ".":U
  or session:numeric-separator <> ",":U
then do:
  message
    vss-workfile vss-revision vss-description skip
    "Неправильные установки сессии progress!" skip
    "Формат даты должен быть - " "'dmy'":U skip
    "Десятичный разделитель - " "'.'":U skip
    "Разделитель тысяч - " "','":U skip
    view-as alert-box error .
  quit.
end.

IMAGE-1 :load-image("cmp/ith.bmp") .

define variable v-auto-start          as logical   no-undo .
define variable v-num-entries         as integer   no-undo .
define variable v-ind                 as integer   no-undo .
define variable v-param               as character no-undo .
define variable v-port-param          as integer   no-undo .
define variable v-pos-num-param       as integer   no-undo .
define variable v-find-port-param     as logical   no-undo .
define variable v-find-pos-num-param  as logical   no-undo .


if  session :parameter <> "":u
and session :parameter <> ?
then do:

  assign
    v-auto-start = true
  .
  assign
    v-num-entries = num-entries( session:parameter, ",":u )
  .

  do v-ind = 1 to v-num-entries :
    assign
      v-param = entry( v-ind, SESSION:PARAMETER, ",":U )
    .
    if num-entries( v-param, ":":U ) = 2 then do:

      if v-param begins "U:" then do:
        assign
          name = entry( 2, v-param, ":":U )
        .
      end.
      if v-param begins "P:" then do:
        assign
          password = entry( 2, v-param, ":":U )
        .
      end.
      if v-param begins "port:" then do:
        assign
          v-port-param = integer(entry( 2, v-param, ":":U ))
        no-error .
        if error-status :error
        then do:
          message
            "Неправильное значение параметра port" skip
            "Обратитесь к администратору" skip
            error-status :get-message(1) skip
            return-value skip
          view-as alert-box error .
          quit.
        end.
        assign
          v-find-port-param = yes
        .
      end.
      if v-param begins "pos:" then do:
        assign
          v-pos-num-param = integer(entry( 2, v-param, ":":U ))
        no-error .
        if error-status :error
        then do:
          message
            "Неправильное значение параметра pos" skip
            "Обратитесь к администратору" skip
            error-status :get-message(1) skip
            return-value skip
          view-as alert-box error .
          quit.
        end.
        assign
          v-find-pos-num-param = yes
        .
      end.
    end.
  end.
end.
else do:
  message
    "Не заданы обязательные параметры port и pos" skip
    "Обратитесь к администратору"
  view-as alert-box error.
  quit.
end.

  if v-find-port-param <> yes
  then do:
    message
      "Не задан обязательный параметр port" skip
      "Обратитесь к администратору"
    view-as alert-box error.
    quit.
  end.
  if v-find-pos-num-param <> yes
  then do:
    message
      "Не задан обязательный параметр pos" skip
      "Обратитесь к администратору"
    view-as alert-box error.
    quit.
  end.

  assign
    v-auto-start = false
  .
  enable
    name password b-ok b-quit
    with frame {&frame-name} in window {&window-name} .
  assign
    session :data-entry-return = yes
  .

run gbl/font-chk.p no-error .
if error-status :error
then do:
  message
    "Неправильные установки системных шрифтов" skip
    "Обратитесь к администратору" skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box information .
end.

do1:
do
on error  undo, leave
on endkey undo, leave
on stop   undo, leave
:
  if lookup( '.', propath) > 0
  then do:
    /* если в пути присутствует текущая директория, */
    /* то определяем её абсолютный путь */
    /* и заменяем символ точка в Propath на абсолютный путь текущей директории */
    /* это делается для того, чтобы в случае когда изменитcя текущая директория */
    /* *.r коды, которые там находились продолжали бы выполняться */

    define variable v-home-directory      as character no-undo .
    define variable v-num-entries-propath as integer   no-undo .
    define variable v-old-propath         as character no-undo .
    define variable v-new-propath         as character no-undo .
    define variable v-path-item           as character no-undo .

    assign
      file-info :file-name = '.'
      v-home-directory = file-info :full-pathname
    .

    assign
      v-old-propath = propath
      v-new-propath = ''
    .
    assign
      v-num-entries-propath = num-entries(v-old-propath)
    .

    do v-ind = 1 to v-num-entries-propath
    :
      assign
        v-path-item = entry(v-ind, v-old-propath)
      .
      if v-path-item = '.'
      then do:
        assign
          v-path-item = v-home-directory
        .
      end.
      assign
        v-new-propath = v-new-propath
                      + (if v-new-propath <> '' then ',' else '')
                      + v-path-item
      .
    end.

    assign
      propath = v-new-propath
    .
  end.

  run enable_ui in this-procedure .

  if v-auto-start <> true
  then do:
    WAIT-FOR GO OF frame {&FRAME-NAME} focus name.
    assign
      name
      password .
  end.

  GET-KEY-VALUE SECTION "REP-SETS" KEY "ConPar" VALUE v-cConnect.
  if v-cConnect = ?
  or trim (v-cConnect) = ""
  then do:
    message
      "Не указаны параметры подключения к БД"
      "(секция REP-SETS ключ ConPar в .ini файле)."
      view-as alert-box error .
    undo do1, leave.
  end.
  if index(v-cConnect, '&1':u) = 0
  then do:
    message
      "В строке подключения к БД не указан комбинация символов &1"
      "(секция REP-SETS ключ ConPar в .ini файле)."
      view-as alert-box error .
    undo do1, leave.
  end.
  GET-KEY-VALUE SECTION "REP-SETS":U KEY "ConParFlt":U VALUE v-fltConnect .
  if trim (v-fltConnect) = "":U
    or trim( v-fltConnect ) = trim( v-cConnect )
  then do:
    assign
      v-fltConnect = ?
    .
  end.
  else do:
    if index(v-fltConnect, '&1':u) = 0
    then do:
      message
        "В строке подключения к БД параметров не указана комбинация символов &1"
        "(секция REP-SETS ключ ConParFlt в .ini файле)."
        view-as alert-box error .
      undo do1, leave.
    end.
  end.

  assign
    v-try-connect = true
  .
  run gbl/dbconn.p
    (input v-cConnect
    ,input v-fltConnect
    ,input name
    ,input password
    ,input-output v-user-entered
    ) .

  if userid('{&db-name_schema}':U) = '':U
  then do:
    message
      "Ошибка при подключении к базе данных" skip
      "Неизвестный пользователь" skip
      view-as alert-box error .
    disconnect ub no-error .
    quit.
  end.
end.  /* do1:  on endkey ... */
assign
  session :data-entry-return = no
.
RUN disable_UI.

/* --------------------- Если произошло подключение к базе данных --------------------- */
if v-user-entered
then do:
  run adm/unloaddb.w
    ( input name
     ,input password
     ,output v-is-copy
    ).
  if v-is-copy = false
  then do:
    run adm/chkdbkey.p no-error.
    if error-status :error
    then do:
      /* ошибка проверки кодировки ключей БД - не запускаем систему */
      if error-status :get-message(1) <> ""
      then do:
        message
          vss-workfile vss-revision vss-description skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
      end.
    end.
    else do:
      run adm/checkcnf.p
        ( input "cfg-check":U
        ) no-error.
      if error-status :error
      then do:
        /* ошибка проверки параметров - не запускаем систему */
        if error-status :get-message(1) <> ""
        then do:
          message
            vss-workfile vss-revision vss-description skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
        end.
      end.
      else do:
        run gbl/mt-serv.w ( input name
                          , input password
                          , input v-port-param
                          , input v-pos-num-param
                          , input v-auto-start
                          ) no-error .
        if error-status :error
        then do:
          disconnect ub no-error .
          quit. /* иначе будет после выхода из системы вылетать редактор */
        end.
      end.
    end.
  end.
end.
else do:
  if v-try-connect = true
  then do:
    message
      "Ошибка при подключении к базе данных" skip
      "Обратитесь к администратору" skip
      "Строка подключения к БД:" skip
      v-cConnect skip
      view-as alert-box error .
  end.
end.
disconnect ub no-error .
quit. /* иначе будет после выхода из системы вылетать редактор */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ARM-users w-login
PROCEDURE ARM-users :
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI w-login  _DEFAULT-DISABLE
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
  IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(w-login)
  THEN DELETE WIDGET w-login.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI w-login  _DEFAULT-ENABLE
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
  DISPLAY FILL-IN-1 FILL-IN-2
      WITH FRAME FRAME-A IN WINDOW w-login.
  ENABLE IMAGE-1 name password b-OK b-quit FILL-IN-1 FILL-IN-2
      WITH FRAME FRAME-A IN WINDOW w-login.
  {&OPEN-BROWSERS-IN-QUERY-FRAME-A}
  VIEW w-login.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
