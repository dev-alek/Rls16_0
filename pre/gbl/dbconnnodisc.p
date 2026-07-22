define input        parameter p-connect       as character no-undo .
define input        parameter p-fltConnect    as character no-undo .
define input        parameter p-user-login    as character no-undo .
define input        parameter p-user-password as character no-undo .
define input-output parameter p-connected     as logical   no-undo .
define variable vss-revision    as character no-undo init "$Revision: 1d8a718f013f, 3351, rls $":U .
define variable vss-author      as character no-undo init "$Author: druban $":U .
define variable vss-date        as character no-undo init "$Date: 2020/06/19 14:54:04 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: dbconnnodisc.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/dbconnnodisc.p $":U .
define variable vss-description as character no-undo init "Процедура подключения к базе данных".
procedure vss-get-info :
  define output parameter p-vss-revision    like vss-revision    no-undo .
  define output parameter p-vss-author      like vss-author      no-undo .
  define output parameter p-vss-date        like vss-date        no-undo .
  define output parameter p-vss-workfile    like vss-workfile    no-undo .
  define output parameter p-vss-archive     like vss-archive     no-undo .
  define output parameter p-vss-description like vss-description no-undo .
  assign
    p-vss-revision    = vss-revision
    p-vss-author      = vss-author
    p-vss-date        = vss-date
    p-vss-workfile    = vss-workfile
    p-vss-archive     = vss-archive
    p-vss-description = vss-description
  .
end procedure.
procedure vss-get-parameters :
  define output parameter p-vss-parameters as character no-undo .
end procedure.
define new global shared variable g#vssrevis-logger as handle    no-undo .
define variable v-vssrevis-logevent                 as logical   no-undo init false .
define variable v-vssrevis-logger                   as handle    no-undo .
procedure vss-logevent :
  define input  parameter p-extra-paramters as character no-undo .
  define variable v-vssrevis-parameters as character no-undo .
  do
  on error undo, return error return-value
  :
    if  valid-handle(v-vssrevis-logger)
    and v-vssrevis-logger :get-signature("logevent") <> ""
    then do:
      run vss-get-parameters in this-procedure
        (output v-vssrevis-parameters
        ).
      run logevent in v-vssrevis-logger
        (input vss-workfile
        ,input vss-revision
        ,input v-vssrevis-parameters
        ,input p-extra-paramters
        ).
    end.
  end.
end procedure.
assign
  v-vssrevis-logger = g#vssrevis-logger
.
if  valid-handle(v-vssrevis-logger)
and v-vssrevis-logger :get-signature("logevent") <> ""
then do:
  assign
    v-vssrevis-logevent = true
  .
  run vss-logevent in this-procedure (input vss-description) .
end.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define variable v-connect-option    as character no-undo .
define variable v-user-passwd       as character no-undo .
define variable v-usr-flt-pswd      as character no-undo .
do
on error undo, return error return-value
on stop undo, return error return-value
on end-key undo, return error return-value
:
  run adm/pswd-enc.p
    (input  encode(p-user-password)
    ,output p-user-password
    ).
  assign
    v-user-passwd = substitute("-U &1 -P &2":U
                              ,p-user-login
                              ,p-user-password
                              )
    v-usr-flt-pswd = substitute("-ld ubflt -U usr-flt -P usr-flt":U)
  .
  connect value(substitute(p-connect, v-user-passwd, v-user-passwd)) no-error .
  if error-status :error
  then do:
     def var vtext as char no-undo.
     vtext =  substitute( "Не удалось подключиться к основной БД с параметрами: &2&1&2&3 Неизвестный пользователь или пароль"
                             ,substitute(p-connect)
                             ,chr(10)
                           ).
     connect value(substitute(p-connect)) no-error .
     IF error-status :error
     then
        vtext =  substitute( "Не удалось подключиться к основной БД с параметрами: &2&1&2&3 Не найдена база данных."
                             ,substitute(p-connect)
                             ,chr(10)
                           ).
    return error vtext.  end.
  if p-fltConnect <> ?
  then do:
    connect value(substitute(p-fltConnect, v-usr-flt-pswd, v-usr-flt-pswd)) no-error .
    if error-status :error
    then do:
      return error substitute( "Не удалось подключиться к БД настроек пользователя с параметрами: &2&1&2&3"
                              ,p-fltConnect
                              ,chr(10)
                              ,error-status :get-message(1)
                            ).
    end.
    if lookup( 'READ-ONLY':U, DBRESTRICTIONS('ubflt':U) ) > 0
    then do:
      return error substitute( "Нет доступа на запись в БД настроек пользователя с параметрами: &2&1"
                              ,p-fltConnect
                              ,chr(10)
                            ).
    end.
  end.
  else do:
    create alias ubflt for database ub .
  end.
  assign
    p-connected = true
  .
end.
