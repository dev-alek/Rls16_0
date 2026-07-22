block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

процедура коннекта к db

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/22/04
Author: Dmitry Ukhanov
Creation date: 03/22/06

*/

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "процедура коннекта к db".
{ cmp/vssrevis.i }
{ adm/auto-def.i }

do
on error  undo, return error substitute( "&1. ERROR &2", vss-workfile, error-status:get-message( error-status:num-messages ) )
on stop   undo, return error substitute( "&1. STOP", vss-workfile )
on endkey undo, return error substitute( "&1. ENDKEY", vss-workfile )
on quit   undo, return error substitute( "&1. QUIT", vss-workfile )
:

  define stream PidStream.

  define variable v-file-name         as character no-undo .
  define variable v-user-password-enc as character no-undo .
  define variable v-conpar            as character no-undo .
  define variable v-ind               as integer   no-undo .
  define variable v-num-entries       as integer   no-undo .

  run gbl/dbdiscon.p no-error.
  if error-status:error
  then do:
    return error substitute( "&1. (1) Не удалось отсоединиться от БД", vss-workfile ).
  end.
  if not g#auto-user-password begins "nocrypt:"
  then do:
     run adm/pswd-enc.p
       (input  encode(g#auto-user-password)
       ,output v-user-password-enc
       ) no-error .
     if error-status:error
     then do:
       return error substitute( "&1. Ошибка кодировки. &2", vss-workfile, return-value ).
     end.
  end.
  else
     v-user-password-enc = substring (g#auto-user-password,9).
  /* параметры для подключения к БД */
  get-key-value section "REP-SETS"
                    key "ConPar"
                  value conn-par.
  if conn-par = ?
  or trim( conn-par ) = ""
  then do:
    return error "Не указаны параметры подключения к БД (секция REP-SETS ключ ConPar в .ini файле)." .
  end.

  define variable v-connect-option as character no-undo .
  assign
    v-file-name      = substitute( "./ATH&1.pid":U, g#auto-pid )
    v-connect-option = substitute('-U &1 -P "&2"':u
                              ,g#auto-user-login
                              ,v-user-password-enc
                              ) when  g#auto-user-login ne ""
  .


  output stream PidStream to value( v-file-name ) .
  output stream PidStream close.

  connect value( substitute(conn-par, v-connect-option, v-connect-option) ) no-error.
  if error-status :error
  then do:

    connect value( substitute(conn-par, /* '-U odbc -P odbc':U */ "") ) no-error.
    if error-status :error
    then do:
      return error substitute("&1. Не удалось подключиться к БД с параметрами &2", vss-workfile, conn-par ).
    end.

    run gbl/dbdiscon.p no-error.
    if error-status :error
    then do:
      return error substitute( "&1. (2) Не удалось отсоединиться от БД", vss-workfile ).
    end.

    return error substitute( "&1. Неверно задан(ы) имя пользователя и(или) пароль", vss-workfile ).
  end.

  os-delete value( v-file-name ) .

  /* определить user-id пользователя */
  if not g#auto-user-password begins "nocrypt:"
  then do:
     run adm/autousid.p no-error .
     if error-status :error
     then do:
       undo, return error return-value .
     end.
  end.

  assign
    session:time-source = 'ub':U
    v-conpar            = dbparam('ub':U)
    v-num-entries       = num-entries( v-conpar )
    v-socket            = false
  .
  search-block:
  do v-ind = 1 to v-num-entries
  on error undo, return error
  :
    if entry( v-ind, v-conpar ) begins "-S":U
    or entry( v-ind, v-conpar ) begins "-1":U
    then do:
      assign
        v-socket = true
      .
      leave search-block.
    end.
  end.

  create alias ubflt for database ub .

end.
/* $Workfile$ end */