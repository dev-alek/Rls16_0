&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME w-login
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS w-login 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Окно входа в систему IBS Trade House

Автор: Белоусов Илья Александрович
Дата создания: 05/08/07
Author: Ilia Belousov
Creation date: 05/08/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 04/05/06


*/

/* ***************************  Definitions  ************************** */
using ibs.th.adm.upd.*.
using ibs.th.gbl.*.


define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Окно входа в систему".
{ cmp/vssrevis.i }
&global-define delim-par chr(4)
&global-define db-name_schema ub
/*{ cmp/str-glbl.i }*/
{ cmp/showinf.i }
define variable v-cConnect          as character no-undo .
define variable v-fltConnect        as character no-undo .
define variable v-user-entered      as logical   no-undo init false .
define variable v-name-for-load-cfg as character no-undo .
define variable v-name-for-init-db  as character no-undo .
define variable v-fname-cfg         as character no-undo .
define variable v-err-code          as integer   no-undo .
define variable v-try-connect       as logical   no-undo init false .
define variable v-is-copy           as logical   no-undo init false .
define variable v-load-cfg          as logical      no-undo.

define variable v-vid-ok            as logical  no-undo .
DEFINE VARIABLE v-updating          as logical   no-undo init false .
define variable v-vid-mes           as character no-undo .
define variable v-vid-param         as longchar no-undo .
define variable v-vid-descr         as character no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE WINDOW
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME FRAME-A

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-OK IMAGE-1 name password b-quit 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR w-login AS WIDGET-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-OK AUTO-GO  NO-FOCUS
     LABEL "&Ввод":L 
     SIZE 10 BY 1
     BGCOLOR 15 .

DEFINE BUTTON b-quit AUTO-END-KEY  NO-FOCUS
     LABEL "&Отмена":L 
     SIZE 10 BY 1.

DEFINE VARIABLE name AS CHARACTER FORMAT "X(12)":U 
     LABEL "Логин" 
     VIEW-AS FILL-IN 
     SIZE 20 BY 1 NO-UNDO.

DEFINE VARIABLE password AS CHARACTER FORMAT "X(16)":U 
     LABEL "Пароль" 
     VIEW-AS FILL-IN 
     SIZE 20 BY 1 NO-UNDO.

DEFINE VARIABLE password_display AS CHARACTER FORMAT "X(16)":U 
     LABEL "Пароль" 
     VIEW-AS FILL-IN 
     SIZE 20 BY 1 NO-UNDO.


DEFINE IMAGE IMAGE-1
     FILENAME "cmp/ith.bmp":U
     SIZE 40 BY 8.88.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME FRAME-A
     b-OK AT ROW 8.04 COL 11.75
     name AT ROW 4.96 COL 10 COLON-ALIGNED
     password AT ROW 6.17 COL 10 COLON-ALIGNED PASSWORD-FIELD 
     password_display AT ROW 6.17 COL 10 COLON-ALIGNED  PASSWORD-FIELD 
     b-quit AT ROW 8.04 COL 21.88
     IMAGE-1 AT ROW 1.08 COL 1.13
    WITH 1 DOWN NO-BOX OVERLAY 
         SIDE-LABELS THREE-D 
         AT COL 1 ROW 1
         SIZE 40.13 BY 8.96.


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
         TITLE              = "Trade House 16.0"
         COLUMN             = 27
         ROW                = 7.58
         HEIGHT             = 9.13
         WIDTH              = 40.25
         MAX-HEIGHT         = 35.63
         MAX-WIDTH          = 160
         VIRTUAL-HEIGHT     = 35.63
         VIRTUAL-WIDTH      = 160
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
   FRAME-NAME UNDERLINE                                                 */
/* SETTINGS FOR BUTTON b-OK IN FRAME FRAME-A
   NO-DISPLAY                                                           */
/* SETTINGS FOR BUTTON b-quit IN FRAME FRAME-A
   NO-DISPLAY                                                           */
/* SETTINGS FOR FILL-IN name IN FRAME FRAME-A
   NO-DISPLAY                                                           */
/* SETTINGS FOR FILL-IN password IN FRAME FRAME-A
   NO-DISPLAY                                                           */
IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(w-login)
THEN w-login:HIDDEN = no.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL password_display w-login
ON VALUE-CHANGED OF password_display IN FRAME FRAME-A DO:
    IF NOT v-updating THEN DO:
        ASSIGN password:SCREEN-VALUE = password_display:SCREEN-VALUE.
    END.
END.
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL password_display w-login
ON ANY-KEY OF password_display IN FRAME FRAME-A DO:
    IF LASTKEY = KEY-CODE("CTRL-V") THEN DO:
           ASSIGN 
           v-updating = TRUE
           password:SCREEN-VALUE = System.Windows.Forms.Clipboard:GetText()
           password_display:SCREEN-VALUE = System.Windows.Forms.Clipboard:GetText()
/*           password_display:SCREEN-VALUE = FILL("*", LENGTH(System.Windows.Forms.Clipboard:GetText()))*/
           v-updating = FALSE.
           System.Windows.Forms.Clipboard:Clear().
           RETURN NO-APPLY.
    END.
/*    IF LASTKEY = KEY-CODE("CTRL-C") THEN DO:
        RETURN NO-APPLY.
    END.*/
END.
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

on "ENTRY" of b-ok do:
  if lastkey = keycode ("RETURN") then do:
    apply "CHOOSE" to b-ok in frame {&frame-name}.
  end.
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

enable
  name password password_display b-ok b-quit
  with frame {&frame-name} in window {&window-name} .
  password:VISIBLE = FALSE.
assign
  session :data-entry-return = yes
.

/* 21/I-2019  текст комментария скопирован из gbl/font-chk.p:

Проверок теперь не проводится, так как не ясно, каким образом
проводить проверку для экранов с разными разрешениями

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
*/

define variable v-num-entries as integer no-undo.
define variable ind as integer no-undo.
define variable v-param as character no-undo.
define variable v-param-name as character no-undo.
define variable v-param-value as character no-undo.
define variable vAutolog as logical no-undo.
define variable v-preconnection as logical no-undo. 
if SESSION:PARAMETER <> "":U
  and SESSION:PARAMETER <> ?
then do:
  assign
    v-num-entries = num-entries( SESSION:PARAMETER, ",":U )
  .
  do ind = 1 to v-num-entries :
    assign
      v-param = entry( ind, SESSION:PARAMETER, ",":U )
    .
    if num-entries( v-param, ":":U ) > 1 then do:
      assign
        v-param-name  = entry( 1, v-param, ":":U )
        v-param-value = substring( v-param, length( v-param-name ) + 2 )
      .
      case v-param-name :
        when "U":U then do:
          if vAutolog
          then
          assign
            name = v-param-value
          .
        end.
        when "P":U then do:
           if vAutolog
           then
          assign
            password = v-param-value
          .
        end.
        when "M":U then do:
         /* assign
            v-mode = replace( v-param-value, {&delim-par}, ",":U )
          .*/
        end.
        when "A":U then do:
           if v-param-value = "admsys"
           then
           vAutolog = yes.
           
        end.
        otherwise do:
          message
            substitute("Неизвестный параметр сессии СПН: &1", v-param) skip
            substitute("Параметр игнорируется.") skip
            view-as alert-box information .
        end.
      end case.
    end.
    else do:
      message
        substitute("Неизвестный параметр сессии СПН: &1", v-param) skip
        substitute("Параметр игнорируется.") skip
        view-as alert-box information .
    end.
  end.
  if name <> "":U
    and password <> "":U
  then do:
    run utl/chkstrgbl.p.
    run adm/autoinit.p ( input name
                    ,input password
                  ) no-error.
    run adm/autoconn.p no-error.
    if error-status :error then do:
      assign
        password = "":U
      .
    end.
    else do:
      assign
        v-preconnection = TRUE
      .
    end.
    run gbl/dbdiscon.p no-error.
  end.
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

    define variable v-home-directory as character no-undo .
    define variable v-ind as integer   no-undo .
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
  if v-preconnection = FALSE then do:
     run enable_ui in this-procedure .
   
     WAIT-FOR GO OF frame {&FRAME-NAME} focus name.
     assign
       name
       password .
  end.
  if v-preconnection = FALSE 
  then
      run utl/chkstrgbl.p.
  
  v-cConnect = ibs.th.gbl.gbl-inipar:conPar.
   
  if v-cConnect = ?
  or trim (v-cConnect) = ""
  then do:
    v-vid-descr = substitute("Не указаны параметры подключения к БД (&1)", ibs.th.gbl.gbl-inipar:conParKeyName) .  
    v-vid-param = substitute("Login=&1&2RESULT=&3&2Description=&4", name, {&delim-par}, "101", v-vid-descr ) .
    run trg/video-action.p (input 50,
                            input v-vid-param,
                            output v-vid-ok,
                            output v-vid-mes) .
    message v-vid-descr view-as alert-box error .
    undo do1, leave.
  end.
  if index(v-cConnect, '&1':u) = 0
  then do:
    v-vid-descr = substitute("В строке подключения к БД не указан комбинация символов ~&1 (&1)", ibs.th.gbl.gbl-inipar:conParKeyName) .  
    v-vid-param = substitute("Login=&1&2RESULT=&3&2Description=&4", name, {&delim-par}, "102", v-vid-descr ) .
    run trg/video-action.p (input 50,
                            input v-vid-param,
                            output v-vid-ok,
                            output v-vid-mes) .
    message v-vid-descr view-as alert-box error .
    undo do1, leave.
  end.

  assign
    v-name-for-load-cfg  = "адм" + '2':U
    v-load-cfg           = false
  .
  if name = v-name-for-load-cfg
  then do:
    assign
      name     = "адм"
      v-load-cfg = true
    .
  end.

  v-fltConnect = ibs.th.gbl.gbl-inipar:conParFlt.
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
      v-vid-descr = substitute("В строке подключения к БД параметров не указана комбинация символов ~&1 (&1)", ibs.th.gbl.gbl-inipar:conParFltKeyName) .  
      message v-vid-descr view-as alert-box error .
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
    ) no-error.
  if userid('{&db-name_schema}':U) = '':U
  then do:
    def var vtext as char no-undo.
    vtext = return-value.
    v-vid-param = "Login=" + name + {&delim-par} + "RESULT=103" + {&delim-par} + "Description=Ошибка при подключении к базе данных. " + vtext.
    run trg/video-action.p (input 50,
                            input v-vid-param,
                            output v-vid-ok,
                            output v-vid-mes) .
    message
      "Ошибка при подключении к базе данных" skip
      vtext skip
      view-as alert-box error .
    disconnect ub no-error .
    quit.
  end.
  def var v-isUpdShm as logical no-undo.
  run adm/upddb.p (input v-cConnect, output v-isUpdShm) no-error.
  if error-status:error
  then do:
    message
      "Ошибка при обновлении схемы БД" skip
      return-value skip
      view-as alert-box error .
    disconnect ub no-error .
    quit.
  end.
  
  if v-isUpdShm
  then do:
    run gbl/dbconn.p
      (input v-cConnect
      ,input v-fltConnect
      ,input name
      ,input password
      ,input-output v-user-entered
      ) .
    if userid('{&db-name_schema}':U) = '':U
    then do:
      v-vid-param = "Login=" + name + {&delim-par} + "RESULT=103" + {&delim-par} + "Description=Ошибка при подключении к базе данных. Неизвестный пользователь".
      run trg/video-action.p (input 50,
                              input v-vid-param,
                              output v-vid-ok,
                              output v-vid-mes) .
      message
        "Ошибка при подключении к базе данных" skip
        "Неизвестный пользователь" skip
        view-as alert-box error .
      disconnect ub no-error .
      quit.
    end.
  end.
  
end. /* do1 */

assign
  session :data-entry-return = no
.
RUN disable_UI.

/* --------------------- Если произошло подключение к базе данных --------------------- */
if v-user-entered
then
DO2:
do
:
   
  run adm/unloaddb.w
    (input  name
    ,input  password
    ,output v-is-copy
    ) .
  def var v-msg as character no-undo.
  if v-is-copy = false
  then do:
    run adm/chk-db.p no-error .
    if error-status :error then do:
      v-msg = return-value.
      v-vid-param = "Login=" + name + {&delim-par} + "RESULT=104" + {&delim-par} + "Description=" + error-status :get-message(1) + ";" + v-msg .
      run trg/video-action.p (input 50,
                            input v-vid-param,
                            output v-vid-ok,
                            output v-vid-mes) .
      message
        error-status :get-message(1) skip v-msg skip
        return-value skip
        view-as alert-box error .
    end.
    else do:
      if v-load-cfg = true then do:
        /* зашли только для загрузки парамеметров */
        run adm/checkcnf.p
          ( input "cfg-load":U
          ) no-error .
        if error-status :error
          and error-status :get-message(1) <> ""
        then do:
          message
            vss-workfile vss-revision vss-description skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
        end.
      end.
      else do: /* зашли для работы */
        run adm/chkdbkey.p no-error .
        if error-status :error then do:
         /* ошибка проверки кодировки ключей БД - не запускаем систему */
          v-vid-param = "Login=" + name + {&delim-par} + "RESULT=105" + {&delim-par} + "Description=Ошибка проверки кодировки ключей БД" .
          run trg/video-action.p (input 50,
                                input v-vid-param,
                                output v-vid-ok,
                                output v-vid-mes) .
          if error-status :get-message(1) <> "" then do:
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
            ) no-error .
          if error-status :error then do:
              /* ошибка проверки параметров - не запускаем систему */
            v-vid-param = "Login=" + name + {&delim-par} + "RESULT=106" + {&delim-par} + "Description=Ошибка проверки параметров" .
            run trg/video-action.p (input 50,
                                    input v-vid-param,
                                    output v-vid-ok,
                                    output v-vid-mes) .
            if error-status :get-message(1) <> "" then do:
              message
                vss-workfile vss-revision vss-description skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
            end.
          end.
          else do:
            run gbl/sys-main.p
              (input name
              ,input password
              ) no-error .
            if error-status :error then do:
              v-vid-param = "Login=" + name + {&delim-par} + "RESULT=107" + {&delim-par} + "Description=" + error-status :get-message(1) .
              run trg/video-action.p (input 50,
                                    input v-vid-param,
                                    output v-vid-ok,
                                    output v-vid-mes) .
              message
                vss-workfile vss-revision vss-description skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
              LEAVE DO2.
            end.
          end.
        end.
      end.
    end.
  end.
end.
else do:
  if v-try-connect = true
  then do:
     if error-status :error then do:
        v-vid-param = "Login=" + name + {&delim-par} + "RESULT=108" + {&delim-par} + "Description=Ошибка при подключении к БД. " + error-status :get-message(1) .
        run trg/video-action.p (input 50,
                            input v-vid-param,
                            output v-vid-ok,
                            output v-vid-mes) .
        message
           "Ошибка при подключении к БД" skip
           error-status :get-message(1) skip
           return-value skip
           view-as alert-box error .
        disconnect ub no-error .
        quit.
     end.
     ELSE DO:
        v-vid-param = "Login=" + name + {&delim-par} + "RESULT=109" + {&delim-par} + "Description=Ошибка при подключении к БД. " + error-status :get-message(1) .
        run trg/video-action.p (input 50,
                            input v-vid-param,
                            output v-vid-ok,
                            output v-vid-mes) .
        message
           "Ошибка при подключении к базе данных" skip
           "Обратитесь к администратору" skip
           "Строка подключения к БД:" skip
           v-cConnect skip
           view-as alert-box error .
     end.
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
  ENABLE b-OK IMAGE-1 name password_display b-quit 
      WITH FRAME FRAME-A IN WINDOW w-login.
  {&OPEN-BROWSERS-IN-QUERY-FRAME-A}
  VIEW w-login.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

