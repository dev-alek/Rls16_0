block-level on error undo, throw.
{ utl/setpwd.i}
  
/*
$Revision: e9d5d9294a87, 3458, rls $
$Author: DRuban $
$Date: 2023/10/16 15:13:33 $
$Workfile: chgpsw.p $
$Archive: utl/chgpsw.p $

Процедура установки паролей при запуске TH

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/22/00
Author: Dmitry Ukhanov
Creation date: 03/22/00

*/
define input  parameter ichgpsw as logical no-undo.
define variable vss-revision    as character no-undo init "$Revision: e9d5d9294a87, 3458, rls $":U .
define variable vss-author      as character no-undo init "$Author: DRuban $":U .
define variable vss-date        as character no-undo init "$Date: 2023/10/16 15:13:33 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: chgpsw.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/chgpsw.p $":U .
define variable vss-description as character no-undo init "Процедура установки паролей при запуске TH".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/trg-def.i }
{ adm/userpro.i &NoCheckWorkUser = yes}
{ gbl/objsrv.i}
define variable mProwin32FileName as character no-undo.
define variable mRunProcFile as character no-undo.
define variable isRcode as logical no-undo.
define variable mCmd as character no-undo.
define variable mConPar as character no-undo.
define variable logdir as character no-undo.
define variable v-sys-key   as character         no-undo.
define variable varpar-type as character no-undo.
function put-log returns character (input itext as character ) forward. 
define temp-table tempUserCopy no-undo like _User.

procedure SetPwdsysadm :
   
      get-key-value section "rep-sets" key "logDir"    value logDir .
      if logDir = ?
      then do :
         logDir = ".\" .
      end .
      else do :
         logDir = right-trim(logDir, "\") .
         logDir = right-trim(logDir, "/") .
         logDir = logDir + "\" .
      end.
         
      define variable mnewpas as character no-undo.
      define variable mcurpas as character no-undo.
      mnewpas = {&paswordnew}.
      mcurpas = {&paswordCur}.
      find first _user no-lock
                    where _user._userid    = {&login}
                    no-error
                    .
                    
      if not available _user 
      then do trans:
         create _user .
         assign
            _user._userid    = {&login}
            _user._password  = encode(mnewpas)
         .
      end.
      else do:
         
         if _User._Password eq encode(mnewpas)
         then do:
            put-log("Cмена пароля пользователя " + {&login} + " не требуется.").
            
            return.
         end.
         else do:
            put-log("Начинаем смену пароля " + {&login} + ".").
         end.
         if _User._Password eq encode(mcurpas)
         then do:
            put-log("Подключаемся пользователем " + {&login} + " и меняем свой пароль.").
            mProwin32FileName =  search ("bin/prowin32.exe").
            mRunProcFile = search ("utl/setmypwd.r").
            if mRunProcFile <> ?
            then 
               isRcode = true.
            else 
               mRunProcFile = search ("utl/setmypwd.p").
            get-key-value section "REP-SETS" key "ConPar" value mConPar.
              
            release _User.
            mConPar = substitute(mConPar, "-U ":U + {&login} + " -P " + mcurpas).
            if isRcode
            then mCMD = substitute ("&1 &2  -rx -p &3 -b -param &4",mprowin32FileName, mConPar, mRunProcFile, mnewpas).
            else mCMD = substitute ("&1 &2      -p &3 -b -param &4",mprowin32FileName, mConPar, mRunProcFile, mnewpas).
               
            os-command silent value (mcmd).
         end.
         find first _user no-lock
                    where _user._userid    = {&login}
                    no-error
                    .
         if _User._Password eq encode(mnewpas)
         then do:
            run trg/userlog.p (
                  input 'sysadm-pwd'
                , input ("Изменен пароль пользователя " + {&login} + {&delim-key} + _user._userid )
                , input ?
                , input ?
                , input "") no-error.
            put-log("У пользователя {&login} Установлен новый пароль.").
         end.
         else do trans:
            find first _user exclusive-lock
                 where _user._userid    = {&login}
            no-error.     
            buffer-copy _User except _User._TenantId _User._Password to tempUserCopy 
            assign tempUserCopy._Password = encode(mnewpas).
            delete _User.
            create _User.
            buffer-copy tempUserCopy except tempUserCopy._TenantId to _User.
            run trg/userlog.p (
                  input 'sysadm-pwd'
                , input ("Изменен пароль пользователя " + {&login} + {&delim-key} + _user._userid )
                , input ?
                , input ?
                , input "") no-error.
            put-log("У пользователя " + {&login} + " установлен новый пароль.").
         end. 
      end.
   
end.
if ichgpsw
then do:
 { gbl/currsysk.i
      v-sys-key 
      no-error
   }                                                      
   if v-sys-key begins "Rosneft-" or v-sys-key eq "yukos" or v-sys-key eq "ibs" or v-sys-key eq   {&SuperSysKey}
   then do:
      run SetPwdsysadm .
      {&login} = "odbc".
      run SetPwdsysadm .
      
      
      find first _file where _file._file-name eq "_user"
      no-lock.
      if    can-do(_file._Can-Create,"odbc") 
         or can-do(_file._Can-delete,"odbc") 
      then do trans:
         find first _file where _file._file-name eq "_user"
         exclusive-lock.
         if can-do(_file._Can-Create,"odbc") 
         then
            _file._Can-Create = "!odbc," + _file._Can-Create.
      
         if can-do(_file._Can-delete,"odbc") 
         then
            _file._Can-delete = "!odbc," + _file._Can-delete.
   
      end.
      do trans:
         find first _user exclusive-lock
                          where _user._userid    = "usr-flt"
                     no-error.
         if available _user
         then
            delete _user.
      end.
   end.
   find first sys-ctrl  no-lock no-error.
   find first _user no-lock
        where _user._userid    =userid ("ub")
        no-error
        .
   if available  _User
   then do:
      find first user-login where user-login.user-login eq userid ("ub")
                              and user-login.db-num     eq sys-ctrl.db-num
      no-lock no-error.
      if available user-login
      then do:
         run  procedure-user-login-change-password in this-procedure (sys-ctrl.db-num,user-login.user-id,no) no-error.
         if error-status:error
         then 
            return error return-value.
      end.
   end.
end.
else
   run mylogin.
{ trg/user.i def ub}
procedure mylogin:
   define variable vlogin as character no-undo.
   define variable vPSwd  as character no-undo.
   vlogin = objsrv:SystemSetting:CrLogin.
   vPswd = objsrv:SystemSetting:CrPSWD.
   if vlogin ne ""
   then
   MAIN-BLOCK:
   do on error   undo MAIN-BLOCK, leave MAIN-BLOCK
      on end-key undo MAIN-BLOCK, leave MAIN-BLOCK:
      
      find first sys-ctrl  no-lock.
      /* _________________ инициализация пользователя системы 'адм' ______________________*/
      define variable v-encode-value as character no-undo .
      define variable v-user-id      as character no-undo .
      
      run adm/pswd-enc.p ( input  encode( if vPswd ne ""
                                          then vPswd 
                                          else vLogin
                                          
                                          )
                         , output v-encode-value
                         ) .
      v-encode-value = encode( v-encode-value ).
        
    /*
      find first _user no-lock
                       where _user._userid    = vLogin
                       no-error
                       .
                       
      if not available _user 
      then do trans:
         create _user .
         assign
            _user._userid    = {&login}
            _user._password  = v-encode-value
         .
      end.
 */     /* else do:
          так поменять нельзя если пользователь другой
         if _user._password  ne v-encode-value
         then do:
            find first _user exclusive-lock
                       where _user._userid    = vLogin
                       .
            _user._password  = v-encode-value.
         end. 
      end. */
   
   
   
   
      disable triggers for  load   of user-login .
      disable triggers for  load   of user-account .
      find first user-login
           where user-login.db-num     = sys-ctrl.db-num
             and user-login.user-login = vLogin
      exclusive-lock no-wait no-error.
      if not available user-login and not locked user-login 
      then do:
         
         
                /* пробуем найти по аккаунту */
         define variable v-count    as integer      no-undo.
      
         for each  user-account
             where user-account.user-id begins ( substitute ( '&1-':U
                                                            ,  sys-ctrl.db-num
                                                            )
                                               )
         no-lock:
            if v-count < INTEGER(entry(2, user-account.user-id, "-")) 
            then 
               v-count = integer(entry(2, user-account.user-id, "-")).
            
         end.
         if v-count <= current-value(s-user-id, ub) 
         then do:
            v-count = next-value(s-user-id, ub).
         end.
         else do:
            current-value(s-user-id, ub) = v-count.
         end.
         v-user-id = substitute ( '&1-&2':U
                                 , sys-ctrl.db-num
                                 , v-count
                                 ) .
         create user-account .
         assign
            user-account.user-id      = v-user-id
            user-account.last-name    = vlogin + " sysadm":U
            user-account.nik          = vlogin + " sysadm":U
            user-account.check-parent = false
         .
         create user-login.
         assign
            user-login.db-num                = sys-ctrl.db-num
            user-login.user-id               = v-user-id
         .
         /* даже если уже существует, принудительно прописываем */
        
         assign
            user-login.user-login              = vlogin
            user-login.user-password-encoded   = v-encode-value
            user-login.user-administrator      = true
            user-login.status_                 = {&bef-user-status-normal}
            user-account.status_               = {&bef-user-status-normal}
         .
         { trg/user.i ub }
      end. /* NOT AVAILABLE user-login */
      else do: 
         find first  user-account
             where user-account.user-id eq user-login.user-id
               and user-account.status_ ne {&bef-user-status-normal}
         exclusive-lock no-error.
         if avail user-account
         then do:
            assign
               user-login.status_                 = {&bef-user-status-normal}
               user-account.status_               = {&bef-user-status-normal}
            .
            { trg/user.i ub }
         end.
      end.
      if locked user-login 
      then     
         find first user-login
           where user-login.db-num     = sys-ctrl.db-num
             and user-login.user-login = vlogin
         no-lock no-error.
      g#db-num = sys-ctrl.db-num.
      run addobj (sys-ctrl.db-num, user-login.user-id).
   end.
end.

function put-log returns character (input itext as character ):
    run gbl/fileapnd.p
          ( logDir + "setpwd.txt"
          ,input substitute ("&1 &2", now, itext)
          ,input 10 /* время ожинания освобождения файла */
          ) no-error .
    
end.