block-level on error undo, throw.
/*

$Revision: 138b369dad6e, 2892, rls $
$Author: DRuban $
$Date: Пн ноя 22 19:49:12 2021 +0300 $
$Workfile: dbconn.p $
$Archive: gbl/dbconn.p $

Процедура подключения к базе данных

Автор: Перваков Михаил Сергеевич
Дата создания: 06/21/00
Author: Mikhail Pervakov
Creation date: 06/21/00

*/

define input        parameter p-connect       as character no-undo .
define input        parameter p-fltConnect    as character no-undo .
define input        parameter p-user-login    as character no-undo .
define input        parameter p-user-password as character no-undo .
define input-output parameter p-connected     as logical   no-undo .

define variable vss-revision    as character no-undo init "$Revision: 138b369dad6e, 2892, rls $":U .
define variable vss-author      as character no-undo init "$Author: DRuban $":U .
define variable vss-date        as character no-undo init "$Date: Пн ноя 22 19:49:12 2021 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: dbconn.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/dbconn.p $":U .
define variable vss-description as character no-undo init "Процедура подключения к базе данных".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }

define variable v-connect-option    as character no-undo .
define variable v-user-passwd       as character no-undo .
define variable v-usr-flt-pswd      as character no-undo .

do
on error undo, return error return-value
on stop undo, return error return-value
on end-key undo, return error return-value
:
  run gbl/dbdiscon.p .

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
                             ,{&new-line}
                      /*       ,error-status :get-message(1)      */
                           ).

     connect value(substitute(p-connect)) no-error .
     IF error-status :error
     then
        vtext =  substitute( "Не удалось подключиться к основной БД с параметрами: &2&1&2&3 Не найдена база данных."
                             ,substitute(p-connect)
                             ,{&new-line}
                           /*  ,error-status :get-message(1)  */
                           ).

 
    return error vtext.
  end.
  if p-fltConnect <> ?
  then do:
    connect value(substitute(p-fltConnect, v-usr-flt-pswd, v-usr-flt-pswd)) no-error .
    if error-status :error
    then do:
      return error substitute( "Не удалось подключиться к БД настроек пользователя с параметрами: &2&1&2&3"
                              ,p-fltConnect
                              ,{&new-line}
                              ,error-status :get-message(1)
                            ).
    end.
    if lookup( 'READ-ONLY':U, DBRESTRICTIONS('ubflt':U) ) > 0
    then do:
      return error substitute( "Нет доступа на запись в БД настроек пользователя с параметрами: &2&1"
                              ,p-fltConnect
                              ,{&new-line}
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