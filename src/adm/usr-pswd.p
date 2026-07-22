block-level on error undo, throw.
/*

$Revision: 3c72df46e096, 3170, rls $
$Author: EShklyar $
$Date: 2022/12/27 12:54:23 $
$Workfile: usr-pswd.p $
$Archive: adm/usr-pswd.p $

Изменить пароль для текущего пользовател

Автор: Белоусов Илья Александрович
Дата создания: 05/08/07
Author: Ilia Belousov
Creation date: 05/08/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 01/30/07


*/

define input  parameter parParentProc  as widget-handle no-undo.

define variable vss-revision    as character no-undo init "$Revision: 3c72df46e096, 3170, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: 2022/12/27 12:54:23 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: usr-pswd.p $":U .
define variable vss-archive     as character no-undo init "$Archive: adm/usr-pswd.p $":U .
define variable vss-description as character no-undo init "Изменить пароль для текущего пользователя".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ gbl/getcntxt.i def }
{ cmp/trg-def.i }

DO
   ON ERROR UNDO, RETURN ERROR RETURN-VALUE
   :
   { gbl/getcntxt.i get }

   define variable v-user-adm        as logical   no-undo .
   DEFINE VARIABLE v-encode-password AS CHARACTER NO-UNDO .
   DEFINE VARIABLE v-password        AS CHARACTER NO-UNDO .
   DEFINE VARIABLE v-nextcon         AS logical   NO-UNDO .
   define variable v-adm-Ubd         as logical   no-undo init ?.
   define variable v-adm-gbd         as logical   no-undo init ?.
   define variable v-superAdm        as logical   no-undo.
   define variable v-TabUserAdm      as handle    no-undo.
   define variable voneadm           as logical   no-undo.
   define buffer lock_user-login for ub.user-login .
   define buffer user-login-attr for ub.user-login-attr .

   { gbl/user-adm.i
    v-cntxt-db-num
    v-cntxt-userid
    v-user-adm
  }
  { adm/userpro.i &CheckWorkUser = yes}
   DO
      TRANSACTION
      ON ERROR UNDO, RETURN ERROR RETURN-VALUE
      :
      FIND FIRST lock_user-login
         WHERE lock_user-login.db-num  = v-cntxt-db-num
           AND lock_user-login.user-id = v-cntxt-userid
         EXCLUSIVE-LOCK
         NO-ERROR
         .
      IF NOT AVAILABLE lock_user-login
         THEN 
      DO:
         MESSAGE
            vss-workfile vss-revision vss-description SKIP
            "Ошибка задания входных параметров" SKIP
            "Не найден логин пользователя" SKIP
            "БД" v-cntxt-db-num SKIP
            "Идентификатор" v-cntxt-userid SKIP
            VIEW-AS ALERT-BOX ERROR .
         UNDO, RETURN ERROR RETURN-VALUE .
      END.
   END.

   run getAccountSetting (input  v-cntxt-userid,
      output v-adm-Ubd,
      output v-adm-gbd,
      output v-superAdm,
      input-output table-handle v-TabUserAdm).
      run availOneAdm(input-output table-handle v-TabUserAdm, output voneadm).                         
   run adm/chg-pswd.w ( INPUT  parParentProc
      , INPUT  v-cntxt-db-num
      , INPUT  v-cntxt-userid
      , input  lock_user-login.user-login
      , INPUT  ""             /* p-name */
      , INPUT  no
      /*                     v-user-adm*/
      , input yes
      , INPUT  lock_user-login.user-password-encoded
      , yes
      , v-adm-gbd or v-adm-ubd or voneadm
      , OUTPUT v-password
      , output v-nextcon 
      ) NO-ERROR.
   IF ERROR-STATUS:ERROR
      then 
   do:
      message
         vss-workfile vss-revision vss-description skip
         "Ошибка при смене пароля. Пароль не сменен" skip
         error-status :get-message(1) skip
         return-value skip
         view-as alert-box error .
      return.
   end.
   IF v-password = ?
      then 
   do:
      return.
   end.

   DO
      TRANSACTION
      ON ERROR UNDO, RETURN ERROR RETURN-VALUE
      :
      FIND CURRENT lock_user-login
         EXCLUSIVE-LOCK
         .
      ASSIGN
         lock_user-login.user-password-encoded = v-password
         .
      if no /* v-nextcon ne ? */
         then 
      do:
         find first user-login-attr where user-login-attr.db-num    = lock_user-login.db-num
            and user-login-attr.user-id   = lock_user-login.user-id
            and user-login-attr.attr-code = "ChangPwdNextConect"
            exclusive-lock no-error.
         if not available user-login-attr
            then 
         do:
            create user-login-attr.
            assign
               user-login-attr.db-num    = lock_user-login.db-num
               user-login-attr.user-id   = lock_user-login.user-id
               user-login-attr.attr-code = "ChangPwdNextConect"
               .
         end.
         user-login-attr.attr-value = string(v-nextcon ).
      end.
      release user-login-attr.
      RELEASE lock_user-login .
   END.


   MESSAGE
      "Пароль успешно изменен"
      view-as alert-box information
      .


END. /* DO ON ERROR */