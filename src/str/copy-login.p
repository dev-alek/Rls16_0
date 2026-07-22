block-level on error undo, throw.
/*

$Revision: 4886e87b5a2b, 3169, rls $
$Author: DRuban $
$Date: 2022/12/27 12:54:23 $
$Workfile: copy-login.p $
$Archive: str/copy-login.p $

Копирование логинов пользователя

Автор: Шкля Елена
Дата создания: 10/13/09
Author: Dmitry Ukhanov
Creation date: 10/13/09

*/
define input parameter p-user-id        as character        no-undo .
define input parameter p-user-login     as character        no-undo .
define input parameter p-db-num         as integer          no-undo .
define input parameter p-db-list        as character        no-undo .
define output parameter p-ok            as logical          no-undo .


define variable vss-revision    as character no-undo initial "$Revision: 4886e87b5a2b, 3169, rls $":U .
define variable vss-author      as character no-undo initial "$Author: DRuban $":U .
define variable vss-date        as character no-undo initial "$Date: 2022/12/27 12:54:23 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: copy-login.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: str/copy-login.p $":U .
define variable vss-description as character no-undo initial "Копирование логинов".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/trg-def.i  }

define variable v-counter   as integer   no-undo.
define variable v-ini-login as character no-undo.
define variable v-ini-name  as character no-undo.
define variable v-ini-nick  as character no-undo.

define variable ii          as integer   no-undo .

define buffer buf_sys-ctrl               for ub.sys-ctrl .
  
define buffer buf_user-login             for ub.user-login .
define buffer buf_user-obj               for user-obj .
define buffer buf_user-host              for user-host .
define buffer buf_user-menu-group        for user-menu-group .
define buffer buf_user-login-action-role for user-login-action-role .

define buffer new_user-login             for user-login .
define buffer new_user-obj               for user-obj .
define buffer new_user-host              for user-host .
define buffer new_user-menu-group        for user-menu-group .
define buffer new_user-login-action-role for user-login-action-role .

define buffer buf_user-account           for ub.user-account .
define buffer buf_db                     for ub.db .

define buffer buf_clients                for ub.clients .

do
   on error undo, return error return-value
   :

   define variable v-new-name             as character no-undo.
   define variable v-new-nick             as character no-undo.
   define variable v-new-login            as character no-undo.
   define variable v-success              as logical   no-undo.
   define variable v-user-rowid           as rowid     no-undo.

   define variable v-next-user-id         as character no-undo .
   define variable v-user-menu-group-code as integer   no-undo.
   define variable v-user-login-role-code as integer   no-undo.

   find first buf_user-login no-lock
      where buf_user-login.user-id = p-user-id
      and buf_user-login.db-num  = p-db-num
      no-error
      .
   if not available buf_user-login
      then 
   do:
      message
         "Логин пользователя редактируется администратором."
         skip (1)
         skip substitute( "БД:           &1", p-db-num             )
         skip (1)
         skip 
         "Повторите операцию через некоторое время."
         view-as alert-box warning.
      undo, return error .
   end.

   if p-db-list = "Все" then 
   do:
      p-db-list = "" .
      For each buf_db no-LOCK:
         if buf_db.db-num <> 0 and buf_db.db-num <> p-db-num then 
         do:
            assign
               p-db-list = substitute( "&1&2&3", p-db-list, {&comma-char}, buf_db.db-num )
               .
         end.  
      end.
      p-db-list = trim (p-db-list,{&comma-char}) .
   end.          
   _next :
   do ii = 1 to num-entries (p-db-list, {&comma-char}):

      /*Проверка есть ли такой логин в базе*/
      find first new_user-login exclusive-lock where new_user-login.user-login = p-user-login
         and new_user-login.db-num = integer (entry(ii,p-db-list,{&comma-char})) no-error .
      if available (new_user-login) then 
      do:
         output to value (ibs.th.gbl.gbl-inipar:logDir + "login-error.log") append .
         /*  for each buf_temp-rvs no-lock where buf_temp-rvs.rvs-error = yes:*/

         put unformatted                "Логин =" + new_user-login.user-login + " уже есть в БД " + string (new_user-login.db-num) skip .


         output close .    
         next _next .
      end.

      /*Создание нового логина*/
      find first new_user-login exclusive-lock where new_user-login.user-id = p-user-id
         and new_user-login.db-num = integer (entry(ii,p-db-list,{&comma-char})) no-error .
      if not available (new_user-login) then 
      do:
         create new_user-login.
         buffer-copy buf_user-login
            except db-num user-login user-administrator to new_user-login 
            assign
            new_user-login.db-num     = integer (entry(ii,p-db-list,{&comma-char})) 
            new_user-login.user-login = p-user-login .
      end.  
    
      /*Удаление фирм*/
      FOR EACH buf_user-host
         where buf_user-host.db-num  = integer (entry(ii,p-db-list,{&comma-char}))
         and buf_user-host.user-id = p-user-id
         exclusive-lock
         :
         delete buf_user-host .
      end.
    /*Создание фирм*/
    FOR EACH buf_user-host
      where buf_user-host.db-num  = p-db-num
      and buf_user-host.user-id = p-user-id
      no-lock
      :
      create new_user-host.
      buffer-copy buf_user-host
        except db-num 
        to new_user-host
        .
      new_user-host.db-num = integer (entry(ii,p-db-list,{&comma-char})) .
    end.
        
    /*Удаление объектов*/  
    FOR EACH  buf_user-obj exclusive-lock
      where buf_user-obj.db-num  = integer (entry(ii,p-db-list,{&comma-char}))
      and buf_user-obj.user-id = p-user-id
      :
      delete buf_user-obj .
    end.
    
    /*Создание объектов*/  
    for each ub.clients no-lock where ub.clients.db-num = integer (entry(ii,p-db-list,{&comma-char})) and (ub.clients.obj-type = {&shop} or ub.clients.obj-type = {&stock}):   
      create new_user-obj.
      assign
        new_user-obj.db-num    = integer (entry(ii,p-db-list,{&comma-char}))
        new_user-obj.host-code = new_user-host.host-code
        new_user-obj.obj-code  = ub.clients.obj-code
        new_user-obj.obj-type  = ub.clients.obj-type
        new_user-obj.user-id   = p-user-id
        .
    end.

    /*Удаление меню*/
    FOR EACH  buf_user-menu-group
      where buf_user-menu-group.db-num  = integer (entry(ii,p-db-list,{&comma-char}))
      and buf_user-menu-group.user-id = p-user-id
      exclusive-lock
      :
      delete buf_user-menu-group .
    end.        
    
    /*Создание меню*/
    FOR EACH  buf_user-menu-group
      where buf_user-menu-group.db-num  = p-db-num
      and buf_user-menu-group.user-id = p-user-id
      no-lock
      :
      assign
        v-user-menu-group-code = next-value(s-user-menu-group)
        .
      create new_user-menu-group.
      buffer-copy buf_user-menu-group
        except db-num user-menu-group-code host-code obj-code obj-type
        to new_user-menu-group
        .
      assign
        new_user-menu-group.db-num               = integer (entry(ii,p-db-list,{&comma-char}))
        new_user-menu-group.user-menu-group-code = v-user-menu-group-code
        new_user-menu-group.host-code            = new_user-host.host-code
        new_user-menu-group.obj-code             = new_user-obj.obj-code
        new_user-menu-group.obj-type             = new_user-obj.obj-type
        .
    end.
        
    /*Удаление ролей*/
    FOR EACH  buf_user-login-action-role
      where buf_user-login-action-role.db-num  = integer (entry(ii,p-db-list,{&comma-char}))
      and buf_user-login-action-role.user-id = p-user-id
      exclusive-lock
      :
      delete buf_user-login-action-role .
    end.
    
    /*Создание ролей типа global*/
    FOR EACH  buf_user-login-action-role
      where buf_user-login-action-role.db-num  = p-db-num
      and buf_user-login-action-role.user-id = p-user-id
      and buf_user-login-action-role.action-role-context = "global"
      no-lock
      :
      assign
        v-user-login-role-code = next-value(s-user-login-action-role)
        .
      create new_user-login-action-role.
      buffer-copy buf_user-login-action-role
        except db-num user-login-role-code user-id
        to new_user-login-action-role
        .
      assign
        new_user-login-action-role.db-num               = integer (entry(ii,p-db-list,{&comma-char}))
        new_user-login-action-role.user-login-role-code = v-user-login-role-code
        new_user-login-action-role.user-id              = p-user-id
        .
    end.

    /*Создание ролей типа firm*/
    FOR EACH  buf_user-login-action-role
      where buf_user-login-action-role.db-num  = p-db-num
      and buf_user-login-action-role.user-id = p-user-id
      and buf_user-login-action-role.action-role-context = "firm"
      no-lock
      :
      assign
        v-user-login-role-code = next-value(s-user-login-action-role)
        .
      create new_user-login-action-role.

      buffer-copy buf_user-login-action-role
        except db-num user-login-role-code host-code user-id
        to new_user-login-action-role
        .
      assign
        new_user-login-action-role.db-num               = integer (entry(ii,p-db-list,{&comma-char}))
        new_user-login-action-role.user-login-role-code = v-user-login-role-code
        new_user-login-action-role.host-code            = new_user-host.host-code
        new_user-login-action-role.user-id              = p-user-id
        .
    end.
    
    /*Создание ролей типа object*/
    FOR EACH  buf_user-login-action-role
      where buf_user-login-action-role.db-num  = p-db-num
      and buf_user-login-action-role.user-id = p-user-id
      and buf_user-login-action-role.action-role-context = "object"
      no-lock
      :
      assign
        v-user-login-role-code = next-value(s-user-login-action-role)
        .
      create new_user-login-action-role.

      buffer-copy buf_user-login-action-role
        except db-num user-login-role-code obj-code obj-type user-id
        to new_user-login-action-role
        .
      assign
        new_user-login-action-role.db-num               = integer (entry(ii,p-db-list,{&comma-char}))
        new_user-login-action-role.user-login-role-code = v-user-login-role-code
        new_user-login-action-role.obj-code             = new_user-obj.obj-code
        new_user-login-action-role.obj-type             = new_user-obj.obj-type
        new_user-login-action-role.user-id              = p-user-id
        .
    end.
    
  end.


end.