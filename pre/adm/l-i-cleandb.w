define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define new  shared variable g#auto as logical no-undo.
define new  shared variable g#news as logical no-undo.
define new  shared variable g#oxml as logical no-undo.
define new  shared variable g#esys as logical no-undo.
define new  shared variable g#news-source-db as integer no-undo.
define new  shared variable g#esys-source-esys as integer no-undo.
define new  shared variable g#db-num as integer   no-undo .
define new  shared variable g#userid as character no-undo .
define new  shared variable g#passwd as character no-undo .
define variable v-updating      as logical   no-undo init false .
DEFINE VAR w-login AS WIDGET-HANDLE NO-UNDO.
DEFINE BUTTON b-OK  NO-FOCUS
     LABEL "&Очистить":L
     SIZE 13 BY 1
     BGCOLOR 15 .
DEFINE BUTTON b-quit AUTO-END-KEY  NO-FOCUS
     LABEL "&Закрыть":L
     SIZE 12.4 BY 1.
DEFINE VARIABLE log-edit AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 69 BY 5.24 NO-UNDO.
DEFINE VARIABLE f-date AS DATE FORMAT "99/99/9999":U
     LABEL "Дата"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 TOOLTIP "Дата актуальности документов" NO-UNDO.
DEFINE VARIABLE f-ub AS CHARACTER FORMAT "X(256)":U INITIAL "-db ub -ld ub -H ... -S ..."
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
DEFINE VARIABLE password_display AS CHARACTER FORMAT "X(16)":U
     LABEL "Пароль"
     VIEW-AS FILL-IN
     SIZE 20 BY 1 NO-UNDO.
DEFINE FRAME FRAME-A
     b-OK AT ROW 7.19 COL 12
     f-ub AT ROW 2 COL 10 COLON-ALIGNED WIDGET-ID 2
     name AT ROW 3.24 COL 10 COLON-ALIGNED
     b-quit AT ROW 7.19 COL 25
     password AT ROW 4.52 COL 10 COLON-ALIGNED PASSWORD-FIELD
     password_display AT ROW 4.52 COL 10 COLON-ALIGNED PASSWORD-FIELD
     f-date AT ROW 5.81 COL 10 COLON-ALIGNED WIDGET-ID 10
     log-edit AT ROW 8.62 COL 3 NO-LABEL WIDGET-ID 12
    WITH 1 DOWN NO-BOX OVERLAY
         SIDE-LABELS THREE-D
         AT COL 1 ROW 1
         SIZE 72.6 BY 13.57.
IF SESSION:DISPLAY-TYPE = "GUI":U THEN
  CREATE WINDOW w-login ASSIGN
         HIDDEN             = YES
         TITLE              = "Trade House 15.0"
         COLUMN             = 27
         ROW                = 7.57
         HEIGHT             = 13.57
         WIDTH              = 73
         MAX-HEIGHT         = 35.62
         MAX-WIDTH          = 160
         VIRTUAL-HEIGHT     = 35.62
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
ASSIGN
       log-edit:READ-ONLY IN FRAME FRAME-A        = TRUE.
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
  define variable v-cConnect     as CHAR no-undo.
  define variable v-user-entered as logical   no-undo init false .
  assign
    f-ub
    name
    password
    f-date.
  if name :screen-value = ""
  then do:
    message
      "Введите имя пользователя"
      view-as alert-box information .
    apply "entry" to name .
    return no-apply .
  end.
  if f-date = ? then
  do:
    message "Необходимо ввести дату актуальности документов" view-as alert-box.
    apply "entry":U to f-date in frame FRAME-A.
    return no-apply.
  end.
  assign
    v-cConnect = f-ub
               + (if     name ne ""
                     and name ne ?
                  then " &1 "
                  else " ")
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
     return no-apply.
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
  assign
    session :data-entry-return = no
  .
  if v-user-entered then
  do:
    message
      'Вы уверены, что хотите произвести чистку базы данных до' string(f-date,"99/99/9999") '?' skip
      view-as alert-box question buttons yes-no update v-ok as logical.
    if v-ok <> true then do:
      return no-apply .
    end.
    run utl/clean_db.p
      ( input f-date
       ,input this-procedure :handle
      ) no-error.
    if error-status :error then do:
       message
       substitute( "Ошибка при работе утилит!" ) skip
       return-value skip
       error-status :get-message ( error-status :num-messages )
       view-as alert-box error
     .
    end.
  end.
  else do:
    if error-status :error then
    do:
      message
        "Ошибка при подключении к БД" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      disconnect ub no-error .
    end.
    else
    do:
      message
        "Ошибка при подключении к базе данных" skip
        "Обратитесь к администратору" skip
        "Строка подключения к БД:" skip
        v-cConnect skip
        view-as alert-box error .
    end.
  end.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME FRAME-A:PARENT eq ?
THEN FRAME FRAME-A:PARENT = ACTIVE-WINDOW.
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
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
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
  run enable_UI in this-procedure .
  WAIT-FOR GO OF frame FRAME-A focus name.
END.
RUN disable_UI in this-procedure.
quit.
PROCEDURE callback-write-to-log :
  define input parameter p-msg-str as character no-undo .
  define variable lok as logical   no-undo .
  do with frame FRAME-A
  on error undo, return error return-value
  :
    assign
      lok = log-edit :move-to-eof( )
      lok = log-edit :insert-string( p-msg-str )
      lok = log-edit :move-to-eof( )
    .
  end.
END PROCEDURE.
PROCEDURE disable_UI :
  IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(w-login)
  THEN DELETE WIDGET w-login.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY f-ub f-date log-edit
      WITH FRAME FRAME-A IN WINDOW w-login.
  ENABLE b-OK f-ub name b-quit  password_display f-date log-edit
      WITH FRAME FRAME-A IN WINDOW w-login.
  VIEW w-login.
END PROCEDURE.
