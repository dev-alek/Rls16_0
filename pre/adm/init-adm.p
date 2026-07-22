block-level on error undo, throw.
define input  parameter inst     as logical   no-undo .
define input  parameter p-db-num as integer   no-undo .
define input  parameter p-create-adm as logical   no-undo .
define variable vss-revision    as character no-undo init "$Revision: 4886e87b5a2b, 3169, rls $":U .
define variable vss-author      as character no-undo init "$Author: DRuban $":U .
define variable vss-date        as character no-undo init "$Date: 2022/12/27 12:54:23 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: init-adm.p $":U .
define variable vss-archive     as character no-undo init "$Archive: adm/init-adm.p $":U .
define variable vss-description as character no-undo init "".
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
do
on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
on stop   undo, return error substitute( "&1. stop", vss-workfile )
on endkey undo, return error substitute( "&1. endkey", vss-workfile )
:
  for each dictdb._user
  on error undo, return error return-value
  :
    if dictdb._user._userid = 'sysadm':u
    or dictdb._user._userid = 'odbc':u
    or dictdb._user._userid = 'usr-flt':u
    then do:
      next.
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
  IF p-create-adm THEN DO:
   DEFINE VARIABLE v-encode-value AS CHARACTER NO-UNDO .
   define variable v-user-id      as character no-undo .
   disable triggers for  load   of dictdb.user-login .
   disable triggers for  load   of dictdb.user-account .
   FIND FIRST dictdb.user-login
        WHERE dictdb.user-login.db-num     = p-db-num
          AND dictdb.user-login.user-login = "адм":U
         exclusive-LOCK
         NO-ERROR
         no-wait.
   IF NOT AVAILABLE dictdb.user-login then do:
      IF LOCKED dictdb.user-login THEN DO:
      END.
      find first dictdb.user-account
           where dictdb.user-account.last-name = "System Administrator":U
             and dictdb.user-account.user-id  begins ( substitute ( '&1-':U
                                                                  ,  p-db-num
                                                                  )
                                                      )
            exclusive-lock
            no-error.
      if available dictdb.user-account then do:
         FIND FIRST dictdb.user-login
              WHERE dictdb.user-login.db-num  = p-db-num
                AND dictdb.user-login.user-id = dictdb.user-account.user-id
              EXCLUSIVE-LOCK
              NO-ERROR .
         IF NOT AVAILABLE dictdb.user-login THEN DO:
            CREATE dictdb.user-login.
            ASSIGN
               dictdb.user-login.db-num  = p-db-num
               dictdb.user-login.user-id = v-user-id
            .
         end.
      end.
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
      end.
   end.
   else do:
         find first dictdb.user-account
            where dictdb.user-account.user-id = dictdb.user-login.user-id
               exclusive-lock
               no-error.
         if NOT available dictdb.user-account then do:
            CREATE dictdb.user-account .
            ASSIGN
               dictdb.user-account.user-id      = dictdb.user-login.user-id
               dictdb.user-account.last-name    = "System Administrator":U
               dictdb.user-account.check-parent = false
               dictdb.user-account.nik          = "System Administrator":U
            .
         end.
   end.
   run adm/pswd-enc.p ( INPUT  ENCODE( "адм":U )
                        , OUTPUT v-encode-value
                        ) .
   ASSIGN
      v-encode-value = ENCODE( v-encode-value )
   .
   ASSIGN
      dictdb.user-login.user-login              = "адм":U
      dictdb.user-login.user-password-encoded   = v-encode-value
      dictdb.user-login.user-administrator      = TRUE
      dictdb.user-login.status_                 = 0
      dictdb.user-account.status_               = 0
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
DEFINE TEMP-TABLE tempUser NO-UNDO LIKE
dictdb._User
.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
    if dictdb.user-login.status_ = 0
    then do:
      find first dictdb.user-account
           where dictdb.user-account.user-id = dictdb.user-login.user-id
           no-lock
           no-error .
      if not available dictdb.user-account
      then do:
        create dictdb.user-account.
        assign
            dictdb.user-account.user-id               = dictdb.user-login.user-id
            dictdb.user-account.status_               = 0
            dictdb.user-account.first-name            = '':U
            dictdb.user-account.second-name           = '':U
            dictdb.user-account.last-name             = dictdb.user-login.user-login
            dictdb.user-account.nik                   = dictdb.user-login.user-login
            dictdb.user-account.company               = '':U
            dictdb.user-account.department            = '':U
            dictdb.user-account.e-mail                = '':U
            dictdb.user-account.internal-phone-number = '':U
            dictdb.user-account.mobile-phone-number   = '':U
            dictdb.user-account.phone-number          = '':U
            dictdb.user-account.position              = '':U
            dictdb.user-account.PS                    = '':U
            dictdb.user-account.room                  = '':U
            dictdb.user-account.parent-user-id        = '':U
            dictdb.user-account.check-parent          = false
        .
      end.
      else
         dictdb.user-login.status_ = dictdb.user-account.status_.
   end.
   if dictdb.user-login.status_ = 0
   then do:
      find first dictdb._user
           where dictdb._user._userid    = dictdb.user-login.user-login
           no-error
           .
      if not available dictdb._user then do:
         create dictdb._user .
         assign
            dictdb._user._userid    = dictdb.user-login.user-login
            dictdb._user._password  = dictdb.user-login.user-password-encoded
         .
      end.
      ELSE DO:
         BUFFER-COPY dictdb._User EXCEPT dictdb._User._Password dictdb._User._TenantId TO tempUser ASSIGN tempUser._Password = dictdb.user-login.user-password-encoded
         .
         DELETE dictdb._User.
         CREATE dictdb._User.
         BUFFER-COPY tempUser EXCEPT tempUser._TenantId TO _User.
      END.
      assign
        dictdb._user._user-name = substitute('&1 &2 &3'
                                        ,dictdb.user-account.last-name
                                        ,dictdb.user-account.first-name
                                        ,dictdb.user-account.second-name
                                        )
      .
      release _user.
    end.
 END.
   if inst = true then do:
      message "Инициализация" "адм":U ", sysadm и odbc закончена успешно."
      view-as alert-box.
   end.
   return.
end.
