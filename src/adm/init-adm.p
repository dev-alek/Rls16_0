block-level on error undo, throw.
/*

$Revision: 4886e87b5a2b, 3169, rls $
$Author: DRuban $
$Date: 2022/12/27 12:54:23 $
$Workfile: init-adm.p $
$Archive: adm/init-adm.p $

init-adm.p -- инициализация адм, sysadm и odbc - приведение в начальное состояние (из редактора)

Автор: Уханов Дмитрий Юрьевич
Дата создания: 01/25/00
Author: Dmitry Ukhanov
Creation date: 01/25/00

*/

define input  parameter inst     as logical   no-undo . /* YES - вопросы задавать */
define input  parameter p-db-num as integer   no-undo .
define input  parameter p-create-adm as logical   no-undo .

define variable vss-revision    as character no-undo init "$Revision: 4886e87b5a2b, 3169, rls $":U .
define variable vss-author      as character no-undo init "$Author: DRuban $":U .
define variable vss-date        as character no-undo init "$Date: 2022/12/27 12:54:23 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: init-adm.p $":U .
define variable vss-archive     as character no-undo init "$Archive: adm/init-adm.p $":U .
define variable vss-description as character no-undo init "".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }


&Scoped-define admin "адм":U

do
on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
on stop   undo, return error substitute( "&1. stop", vss-workfile )
on endkey undo, return error substitute( "&1. endkey", vss-workfile )
:

  /* _________ удаляем всех пользовалелей PROGRESS (не системы), кроме 'sysadm' и 'odbc' ________*/

  for each dictdb._user
  on error undo, return error return-value
  :
    if dictdb._user._userid = 'sysadm':u
    or dictdb._user._userid = 'odbc':u
    or dictdb._user._userid = 'usr-flt':u
    then do:
      next. /* --->>>--- */
    end.
    find first dictdb.user-login
      where dictdb.user-login.db-num   = p-db-num
        and dictdb.user-login.user-login = dictdb._user._userid
      no-error .
    if not available dictdb.user-login
    then do:
      message "В БД найдена запись о пользователе системы с именем:"
              DICTDB._user._userid skip
              "Это имя не является пользовательским для входа в систему IBS Trade House. Уничтожаем."
              view-as alert-box.
      delete DICTDB._user.
    end.
  end.

  /* _________________ инициализация пользователя PROGRESS с именем 'odbc' ______________________*/

  find first dictdb._user
    where dictdb._user._userid = "odbc":u
    no-error .
  if available dictdb._user
  then do:
    find first dictdb.user-login
      where dictdb.user-login.db-num   = p-db-num
        and dictdb.user-login.user-login = 'odbc':u
      no-error .
    if available dictdb.user-login
    then do:
      message
        "В БД найдена запись о пользователе системы с именем 'odbc'." skip
        "Это имя не может принадлежать пользователю системы,"
        "оно должно быть зарезервировано для connect из внешних приложений через ODBC." skip(2)
        "Необходимо создать пользователя PROGRESS для connect из внешних приложений с именем 'odbc', паролем 'odbc'." skip
        view-as alert-box error .
      return error.
    end.
  end.
  else do:
    message
      "В БД отсутствует пользователь PROGRESS с именем 'odbc',"
      "которое зарезервировано для connect внешних приложений через ODBC." skip
      "Дальнейшая инициализация данной БД невозможна!!!" skip
      view-as alert-box error.
    return error .
  end.

  /* _________________ инициализация пользователя PROGRESS 'sysadm' ______________________*/

  find first dictdb._user
    where dictdb._user._userid = 'sysadm':u
    no-error .
  if available dictdb._user then do:
    find first dictdb.user-login
      where dictdb.user-login.db-num   = p-db-num
        and dictdb.user-login.user-login = 'sysadm':U
      no-error .
    if available DICTDB.user-login
    then do:
      message
        "В БД найдена запись о пользователе системы с именем 'sysadm'." skip
        "Это имя не может принадлежать пользователю системы,"
        "оно должно быть зарезервировано для connect из PROGRESS Procedure Editor." skip
        view-as alert-box error .
      return error.
    end.
  end.

  /* _________________ инициализация пользователя PROGRESS 'usr-flt' ______________________*/
 /*
  find first dictdb._user
    where dictdb._user._userid = 'usr-flt':u
    no-error .
  if available dictdb._user then do:
    find first dictdb.user-login
      where dictdb.user-login.db-num   = p-db-num
        and dictdb.user-login.user-login = 'usr-flt':U
      no-error .
    if available DICTDB.user-login
    then do:
      message
        "В БД найдена запись о пользователе системы с именем 'usr-flt'." skip
        "Это имя не может принадлежать пользователю системы,"
        "оно должно быть зарезервировано для connect из TH для работы с настройками пользователей." skip
        "Дальнейшая инициализация данной БД невозможна!!!" skip
        view-as alert-box error .
      return error.
    end.
  end.
  else do:
    message
      "В БД отсутствует пользователь PROGRESS с именем 'usr-flt',"
      "которое зарезервировано для connect из TH для работы с настройками пользователей." skip
      "Дальнейшая инициализация данной БД невозможна!!!" skip
      view-as alert-box error.
    return error .
  end.
   */
  IF p-create-adm THEN DO:
   /* _________________ инициализация пользователя системы 'адм' ______________________*/
   DEFINE VARIABLE v-encode-value AS CHARACTER NO-UNDO .
   define variable v-user-id      as character no-undo .

   disable triggers for  load   of dictdb.user-login .
   disable triggers for  load   of dictdb.user-account .


   FIND FIRST dictdb.user-login
        WHERE dictdb.user-login.db-num     = p-db-num
          AND dictdb.user-login.user-login = {&admin}
         exclusive-LOCK
         NO-ERROR
         no-wait.
   IF NOT AVAILABLE dictdb.user-login then do:
      IF LOCKED dictdb.user-login THEN DO:

      END.
      /* пробуем найти по аккаунту */
      find first dictdb.user-account
           where dictdb.user-account.last-name = "System Administrator":U
             and dictdb.user-account.user-id  begins ( substitute ( '&1-':U
                                                                  ,  p-db-num
                                                                  )
                                                      )
            exclusive-lock
            no-error.
      /* пробуем найти логин для этой БД */
      if available dictdb.user-account then do:
         FIND FIRST dictdb.user-login
              WHERE dictdb.user-login.db-num  = p-db-num
                AND dictdb.user-login.user-id = dictdb.user-account.user-id
              EXCLUSIVE-LOCK
              NO-ERROR .
         /* создаем */
         IF NOT AVAILABLE dictdb.user-login THEN DO:
            CREATE dictdb.user-login.
            ASSIGN
               dictdb.user-login.db-num  = p-db-num
               dictdb.user-login.user-id = v-user-id
            .
         end.
      end. /* available dictdb.user-account */
      /* нет ни логина, ни аккаунта, то создаем и то и другое */
      else do:
            define variable v-count    as integer      no-undo.

            for each  dictdb.user-account
                  where dictdb.user-account.user-id begins ( substitute ( '&1-':U
                                                                  ,  p-db-num
                                                                  )
                                                      )
                  no-lock
                  :
                  if v-count < INTEGER(entry(2, dictdb.user-account.user-id, "-")) then do:
                     assign
                     v-count = INTEGER(entry(2, dictdb.user-account.user-id, "-"))
                     .
                  end.
            end.
            if v-count <= current-value(s-user-id, dictdb) then do:
               assign
                  v-count = next-value(s-user-id, dictdb)
               .
            end.
            else do:
               assign
                  current-value(s-user-id, dictdb) = v-count
               .
            end.

            v-user-id = substitute ( '&1-&2':U
                                 , p-db-num
                                 , v-count
                                 ) .
            CREATE dictdb.user-account .
            ASSIGN
               dictdb.user-account.user-id      = v-user-id
               dictdb.user-account.last-name    = "System Administrator":U
               dictdb.user-account.nik          = "System Administrator":U
               dictdb.user-account.check-parent = false
            .
            CREATE dictdb.user-login.
            ASSIGN
               dictdb.user-login.db-num                = p-db-num
               dictdb.user-login.user-id               = v-user-id
            .
      end. /* NOT available dictdb.user-account */
   end. /* NOT AVAILABLE dictdb.user-login */
   else do:
         /* наличие аккаунта */
         find first dictdb.user-account
            where dictdb.user-account.user-id = dictdb.user-login.user-id
               exclusive-lock
               no-error.
         /* если потерян или физически удален, восстанавливаем */
         if NOT available dictdb.user-account then do:
            CREATE dictdb.user-account .
            ASSIGN
               dictdb.user-account.user-id      = dictdb.user-login.user-id
               dictdb.user-account.last-name    = "System Administrator":U
               dictdb.user-account.check-parent = false
               dictdb.user-account.nik          = "System Administrator":U
            .
         end.
   end. /* AVAILABLE dictdb.user-login */


   /* даже если уже существует, принудительно прописываем */
   run adm/pswd-enc.p ( INPUT  ENCODE( {&admin} )
                        , OUTPUT v-encode-value
                        ) .
   ASSIGN
      v-encode-value = ENCODE( v-encode-value )
   .

   ASSIGN
      dictdb.user-login.user-login              = {&admin}
      dictdb.user-login.user-password-encoded   = v-encode-value
      dictdb.user-login.user-administrator      = TRUE
      dictdb.user-login.status_                 = {&bef-user-status-normal}
      dictdb.user-account.status_               = {&bef-user-status-normal}
   .
   find first dictdb.user-account-attr where dictdb.user-account-attr.user-id    eq dictdb.user-account.user-id
                                         and dictdb.user-account-attr.attr-code  eq "superadm"
   exclusive-lock no-error.
   if not available dictdb.user-account-attr
   then do:
      create dictdb.user-account-attr.
      assign
         dictdb.user-account-attr.user-id    = dictdb.user-account.user-id
         dictdb.user-account-attr.attr-code = "superadm"
      .
   end.
   dictdb.user-account-attr.attr-value = "yes".
   release dictdb.user-account-attr.
   
    
   { trg/user.i dictdb }
 END.
   if inst = true then do:
      message "Инициализация" {&admin} ", sysadm и odbc закончена успешно."
      view-as alert-box.
   end.

   return.

end.