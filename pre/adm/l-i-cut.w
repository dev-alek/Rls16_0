define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define variable v-updating      as logical   no-undo init false .
DEFINE VAR w-login AS WIDGET-HANDLE NO-UNDO.
DEFINE BUTTON b-OK AUTO-GO  NO-FOCUS
     LABEL "&Ввод":L
     SIZE 10 BY 1
     BGCOLOR 15 .
DEFINE BUTTON b-quit AUTO-END-KEY  NO-FOCUS
     LABEL "&Отмена":L
     SIZE 10 BY 1.
DEFINE VARIABLE f-dst AS CHARACTER FORMAT "X(1000)":U INITIAL "-db c:\baza\16_etalon\ub -ld dst -1 -U sysadm -P sysadm -i "
     LABEL "DST"
     VIEW-AS FILL-IN
     SIZE 59 BY 1 NO-UNDO.
DEFINE VARIABLE f-ub AS CHARACTER FORMAT "X(256)":U INITIAL "-db c:\baza\16_TBD\ub -ld ub -1"
     LABEL "UB"
     VIEW-AS FILL-IN
     SIZE 59 BY 1 NO-UNDO.
DEFINE VARIABLE name AS CHARACTER FORMAT "X(12)":U INITIAL "адм"
     LABEL "Логин"
     VIEW-AS FILL-IN
     SIZE 20 BY 1 NO-UNDO.
DEFINE VARIABLE password AS CHARACTER FORMAT "X(16)":U INITIAL "адм"
     LABEL "Пароль"
     VIEW-AS FILL-IN
     SIZE 20 BY 1 NO-UNDO.
DEFINE VARIABLE password_display AS CHARACTER FORMAT "X(16)":U INITIAL "адм"
     LABEL "Пароль"
     VIEW-AS FILL-IN
     SIZE 20 BY 1 NO-UNDO.
DEFINE FRAME FRAME-A
     b-OK AT ROW 7 COL 12
     f-ub AT ROW 2 COL 10 COLON-ALIGNED WIDGET-ID 2
     name AT ROW 3.25 COL 10 COLON-ALIGNED
     password AT ROW 4.5 COL 10 COLON-ALIGNED PASSWORD-FIELD
     password_display AT ROW 4.5 COL 10 COLON-ALIGNED PASSWORD-FIELD
     b-quit AT ROW 7 COL 22.5
     f-dst AT ROW 5.75 COL 10 COLON-ALIGNED WIDGET-ID 6
    WITH 1 DOWN NO-BOX OVERLAY
         SIDE-LABELS THREE-D
         AT COL 1 ROW 1
         SIZE 72.63 BY 7.58.
IF SESSION:DISPLAY-TYPE = "GUI":U THEN
  CREATE WINDOW w-login ASSIGN
         HIDDEN             = YES
         TITLE              = "Trade House 15.0"
         COLUMN             = 27
         ROW                = 7.58
         HEIGHT             = 7.75
         WIDTH              = 72.63
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
ELSE w-login = CURRENT-WINDOW.
IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(w-login)
THEN w-login:HIDDEN = no.
ON VALUE-CHANGED OF password_display IN FRAME FRAME-A DO:
    IF NOT v-updating THEN DO:
        ASSIGN password:SCREEN-VALUE = password_display:SCREEN-VALUE.
    END.
END.
ON ANY-KEY OF password_display IN FRAME FRAME-A DO:
    IF LASTKEY = KEY-CODE("CTRL-V") THEN DO:
           ASSIGN
           v-updating = TRUE
           password:SCREEN-VALUE = System.Windows.Forms.Clipboard:GetText()
           password_display:SCREEN-VALUE = System.Windows.Forms.Clipboard:GetText()
           v-updating = FALSE.
           System.Windows.Forms.Clipboard:Clear().
           RETURN NO-APPLY.
    END.
END.
ON CHOOSE OF b-OK IN FRAME FRAME-A
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame FRAME-A
do:
  run gbl/app_help.p
    (input this-procedure :file-name
    ,input ''
    ,input ?
    ) no-error.
  if error-status :error then do:
    message
      "Ошибка при вызове помощи"
      error-status :get-message(1)
      view-as alert-box .
  end.
end.
on "ENTRY" of b-ok do:
  if lastkey = keycode ("RETURN") then do:
    apply "CHOOSE" to b-ok in frame FRAME-A.
  end.
end.
on window-close of w-login do:
  apply "end-error" to frame FRAME-A.
end.
ASSIGN
  CURRENT-WINDOW             = w-login
  SESSION:SYSTEM-ALERT-BOXES = (CURRENT-WINDOW:MESSAGE-AREA = NO)
  session:three-d = yes
.
PAUSE 0 BEFORE-HIDE.
if session:date-format <> "dmy":U
  or session:numeric-decimal-point <> ".":U
  or session:numeric-separator <> ",":U
then do:
  message
    "Неправильные установки сессии progress!" skip
    "Формат даты должен быть - " "'dmy'":U skip
    "Десятичный разделитель - " "'.'":U skip
    "Разделитель тысяч - " "','":U skip
    view-as alert-box error .
  quit.
end.
enable
  name password_display b-ok b-quit
  with frame FRAME-A in window w-login .
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
  run enable_ui in this-procedure .
  WAIT-FOR GO OF frame FRAME-A focus name.
  assign
    f-ub
    name
    password
    f-dst .
  def vAR  v-cConnect AS CHAR NO-UNDO.
  DEF VAR v-try-connect AS logical no-undo.
  define variable v-user-entered      as logical   no-undo init false .
  assign
    v-cConnect = f-ub
               + (if     name ne ""
                     and name ne ?
                  then " &1 "
                  else " ")
    v-try-connect = true
  .
  run gbl/dbconnnodisc.p
    (input v-cConnect
    ,input ?
    ,input name
    ,input password
    ,input-output v-user-entered
    ) no-error.
  if error-status:error
  then do:
     message return-value view-as alert-box.
     quit.
  end.
  if userid('ub':U) = '':U
  then do:
    message
      "Ошибка при подключении к базе данных" skip
      "Неизвестный пользователь" skip
      view-as alert-box error .
    disconnect ub no-error .
    quit.
  end.
   run gbl/dbconnnodisc.p
    (input f-dst
    ,input ?
    ,input name
    ,input password
    ,input-output v-user-entered
    ) no-error.
  if error-status:error
  then do:
     message return-value view-as alert-box.
    disconnect ub no-error .
     quit.
  end.
  if userid('dst':U) = '':U
  then do:
    message
      "Ошибка при подключении к базе данных" skip
      "Неизвестный пользователь" skip
      view-as alert-box error .
    disconnect ub no-error .
    quit.
  end.
end.
assign
  session :data-entry-return = no
.
RUN disable_UI.
if v-user-entered
then
DO2:
do
:
  RUN UTL\CUT-LOAD.W  no-error.
end.
else do:
  if v-try-connect = true
  then do:
     if error-status :error then do:
        message
           "Ошибка при подключении к БД" skip
           error-status :get-message(1) skip
           return-value skip
           view-as alert-box error .
        disconnect ub no-error .
        quit.
     end.
     ELSE DO:
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
quit.
PROCEDURE ARM-users :
END PROCEDURE.
PROCEDURE disable_UI :
  IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(w-login)
  THEN DELETE WIDGET w-login.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY f-ub f-dst
      WITH FRAME FRAME-A IN WINDOW w-login.
  ENABLE b-OK f-ub name password_display b-quit f-dst
      WITH FRAME FRAME-A IN WINDOW w-login.
  VIEW w-login.
END PROCEDURE.
