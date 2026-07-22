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
define stream LogStream .
define variable ttd        as character no-undo .
define variable v-old-time as int64     no-undo .
PROCEDURE write-to-log :
  define input parameter p-msg-str   as character no-undo .
  define input parameter p-call-back as handle    no-undo .
  do
  on error undo, return error
  :
    output stream LogStream to "press_db.log" page-size 0 append.
    put stream LogStream unformatted p-msg-str .
    output stream LogStream close.
    if  valid-handle(p-call-back)
    and lookup('callback-write-to-log', p-call-back :internal-entries) > 0
    then do:
      run callback-write-to-log in p-call-back
        (input p-msg-str
        ) no-error .
    end.
  end.
END PROCEDURE.
FUNCTION format-etime RETURNS CHARACTER
(INPUT p-etime AS INT64  )
:
  if p-etime = ?
  then do:
    return "?????????????" .
  end.
  assign
    p-etime = p-etime / 1000
  .
  return
    string( p-etime, '->>>>>>>9')
    + ' '
    + string( p-etime, 'HH:MM:SS')
  .
END FUNCTION.
define variable vWrkDir  as character no-undo init "press-db".
define variable vTables  as character no-undo init "tables.txt".
define variable vFileLog as character no-undo.
define variable v-updating  as logical   no-undo init false .
define stream sToFile.
DEFINE VAR w-login AS WIDGET-HANDLE NO-UNDO.
DEFINE BUTTON b-OK  NO-FOCUS
     LABEL "&Выполнить":L
     SIZE 13 BY 1
     BGCOLOR 15 .
DEFINE BUTTON b-quit AUTO-END-KEY  NO-FOCUS
     LABEL "&Закрыть":L
     SIZE 12.4 BY 1.
DEFINE VARIABLE log-edit AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 74 BY 7.91 NO-UNDO.
DEFINE VARIABLE f-db-rec AS CHARACTER FORMAT "X(256)":U INITIAL "c:~\baza~\etalon~\ub"
     LABEL "БД приемник"
     VIEW-AS FILL-IN
     SIZE 57.4 BY 1 TOOLTIP "Укажите полный путь к БД-приемник. Например: c:\baza\etalon\db" NO-UNDO.
DEFINE VARIABLE f-db-src AS CHARACTER FORMAT "X(256)":U INITIAL "c:~\baza~\ubd~\ub"
     LABEL "БД источник"
     VIEW-AS FILL-IN
     SIZE 57.2 BY 1 TOOLTIP "Укажите полный путь к БД-источник. Например: c:\baza\ubd\db." NO-UNDO.
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
DEFINE VARIABLE radio-mode AS INTEGER INITIAL 1
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          " - только выгрузка", 1,
" - только загрузка", 2,
" - выгрузка и загрузка", 3
     SIZE 31 BY 2.38 NO-UNDO.
DEFINE FRAME FRAME-A
     b-OK AT ROW 7.19 COL 13
     f-db-src AT ROW 1.76 COL 4.6 WIDGET-ID 2
     radio-mode AT ROW 2.91 COL 44 NO-LABEL WIDGET-ID 16
     name AT ROW 3 COL 16.8 COLON-ALIGNED
     password AT ROW 4.29 COL 16.8 COLON-ALIGNED PASSWORD-FIELD
     password_display AT ROW 4.29 COL 16.8 COLON-ALIGNED PASSWORD-FIELD
     f-db-rec AT ROW 5.57 COL 3.6 WIDGET-ID 14
     log-edit AT ROW 8.57 COL 4 NO-LABEL WIDGET-ID 12
     b-quit AT ROW 7.19 COL 26
    WITH 1 DOWN NO-BOX OVERLAY
         SIDE-LABELS THREE-D
         AT COL 1 ROW 1
         SIZE 79.8 BY 16.14.
IF SESSION:DISPLAY-TYPE = "GUI":U THEN
  CREATE WINDOW w-login ASSIGN
         HIDDEN             = YES
         TITLE              = "Trade House 16.0"
         COLUMN             = 27
         ROW                = 7.57
         HEIGHT             = 16.95
         WIDTH              = 80.2
         MAX-HEIGHT         = 48.43
         MAX-WIDTH          = 384
         VIRTUAL-HEIGHT     = 48.43
         VIRTUAL-WIDTH      = 384
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
  define variable vConnect       as character no-undo.
  define variable v-user-entered as logical   no-undo init false .
  define variable vDbSrc         as character no-undo.
  define variable vDbRec         as character no-undo.
  define variable vMess          as character no-undo.
  assign
    f-db-src
    name
    password
    f-db-rec
    radio-mode
  .
  if search(trim(f-db-src) + ".db") = ? then
  do:
    message
     "Не найдена БД источнк."
      view-as alert-box information .
    apply "entry" to f-db-src .
    return no-apply .
  end.
  if search(trim(f-db-rec) + ".db") = ? then
  do:
    message
     "Не найдена БД приемник."
      view-as alert-box information .
    apply "entry" to f-db-rec .
    return no-apply .
  end.
  if name :screen-value = ""
  then do:
    message
      "Введите имя пользователя"
      view-as alert-box information .
    apply "entry" to name .
    return no-apply .
  end.
  assign
    vDbSrc = substitute("-db &1 -ld ub -1", trim(f-db-src))
    vDbRec = substitute("-db &1 -ld &2 -1 -U sysadm -P sysadm -i" ,trim(f-db-rec), "dst")
    vConnect = vDbSrc
               + (if     name ne ""
                     and name ne ?
                  then " &1 "
                  else " ")
  .
  run gbl/dbconnnodisc.p
    (input vConnect
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
   run gbl/dbconnnodisc.p
    (input vDbRec
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
  assign
    session :data-entry-return = no
  .
  if v-user-entered then
  do:
    if radio-mode = 1 then
      vMess = "Выгрузить данные из БД источник?".
    else if radio-mode = 2 then
      vMess = "Загрузить выгруженные данные в БД приемник?".
    else
      vMess = "Вы уверены, что хотите произвести перенос данных в другую БД для сжатия базы?".
    message
      vMess skip
      view-as alert-box question buttons yes-no update v-ok as logical.
    if v-ok <> true then do:
      return no-apply .
    end.
    disable b-OK b-quit with frame FRAME-A.
    if radio-mode = 1 or radio-mode = 3 then
    do:
      run utl/pressdbbef.p (
        input vWrkDir,
        input vTables,
        input this-procedure :handle
      ) no-error.
      if error-status :error then do:
         message
           substitute( "Ошибка при выполнении подготовительных процедур!" ) skip
           return-value skip
           error-status :get-message ( error-status :num-messages )
           view-as alert-box error
         .
         disconnect ub.
         disconnect dst.
         enable b-OK b-quit with frame FRAME-A.
         return no-apply.
      end.
      disconnect ub.
      disconnect dst.
      run utl/pressdbdump.p (
        input search(vWrkDir + "\" + vTables),
        f-db-src,
        input this-procedure :handle
      ) no-error.
      if error-status :error then do:
        message
         substitute( "Ошибка при выполнении выгрузки данных БД!" ) skip
         return-value skip
         error-status :get-message ( error-status :num-messages )
         view-as alert-box error
        .
        enable b-OK b-quit with frame FRAME-A.
        return no-apply.
      end.
    end.
    else do:
      disconnect ub.
      disconnect dst.
    end.
    if radio-mode = 2 or radio-mode = 3 then
    do:
      run utl/pressdbload.p (
        input vWrkDir,
        f-db-rec,
        input this-procedure :handle
      ) no-error.
      if error-status :error then do:
        message
          substitute( "Ошибка при выполнении зарузки данных БД!" ) skip
          return-value skip
          error-status :get-message ( error-status :num-messages )
         view-as alert-box error
        .
        enable b-OK b-quit with frame FRAME-A.
        return no-apply.
      end.
      run gbl/dbconnnodisc.p
          (input substitute("-db &1 -ld &2 -1 -U sysadm -P sysadm -i" ,trim(f-db-rec), "ub")
        ,input ?
        ,input name
        ,input password
        ,input-output v-user-entered
      ) no-error.
      run write-to-log in this-procedure
        ( string(today, '99/99/9999') + " " + string(time, 'HH:MM') +
          " Восстановливаем Sequences" + chr(10)
       ,this-procedure
      ).
      run adm/restseqr.p
        ( input "rest-no-msg":U
         ,input "":U
         ,input no
      ) no-error .
      disconnect ub.
    end.
    if radio-mode = 1 then
      vMess = "Выгрузка данных завершена.".
    else if radio-mode = 2 then
      vMess = "Загрузка данных завершена.".
    else
      vMess = "Перенос БД завершен.".
    run write-to-log in this-procedure
    ( string(today, '99/99/9999') + " " + string(time, 'HH:MM') +
      " " + vMess + chr(10)
    ,this-procedure
    ).
    message
      vMess
      view-as alert-box
    .
    enable b-OK b-quit with frame FRAME-A.
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
        vConnect skip
        view-as alert-box error .
      enable b-OK b-quit with frame FRAME-A.
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
  DISPLAY f-db-src radio-mode f-db-rec log-edit
      WITH FRAME FRAME-A IN WINDOW w-login.
  ENABLE b-OK f-db-src radio-mode name password password_display f-db-rec log-edit b-quit
      WITH FRAME FRAME-A IN WINDOW w-login.
  VIEW w-login.
END PROCEDURE.
