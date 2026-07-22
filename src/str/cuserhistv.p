block-level on error undo, throw.
/*

$Revision: 4886e87b5a2b, 3169, rls $
$Author: DRuban $
$Date: 2022/12/27 12:54:23 $
$Workfile: cuserhistv.p $
$Archive: str/cuserhistv.p $

Заполнение временной таблицы для показа изменений по таблицам истории пользователя

Автор: Шкляр Елена
Дата создания: 08/07/05
Author: Shklyar Elena
Creation date: 08/07/05

*/

define input parameter p-user-id like ub.c-usr-hist.user-id no-undo .
define input parameter p-chip-num like ub.c-usr-hist.chip-num no-undo .
define input parameter p-corr-user-db-num like ub.c-usr-hist.corr-user-db-num no-undo .
define input parameter p-subject like ub.c-usr-hist.subject no-undo .
define input parameter p-action   like ub.c-usr-hist.action no-undo .
define input parameter p-silent  as logical no-undo .
define output parameter p-description as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: 4886e87b5a2b, 3169, rls $":U .
define variable vss-author      as character no-undo init "$Author: DRuban $":U .
define variable vss-date        as character no-undo init "$Date: 2022/12/27 12:54:23 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: cuserhistv.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/cuserhistv.p $":U .
define variable vss-description as character no-undo init "Заполнение временной таблицы для показа изменений по таблицам истории пользователя".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ gbl/placattr.i }
{ gbl/plgdattr.i }

define variable v-chg-fields    as character no-undo.
define variable v-old-fields    as character no-undo.
define variable v-new-fields    as character no-undo.
define variable ii              as integer   no-undo.
define variable v-mess          as character no-undo .

define buffer buf_c-usr-hist for ub.c-usr-hist.
&Glob VisibleKeyField yes
{ ref/tmpchgs.i "SHARED" " " "with-action" }


find first buf_c-usr-hist no-lock where
  buf_c-usr-hist.user-id = p-user-id
  AND buf_c-usr-hist.chip-num = p-chip-num
  AND buf_c-usr-hist.corr-user-db-num = p-corr-user-db-num
  AND buf_c-usr-hist.subject  = p-subject no-error .
if not available buf_c-usr-hist then 
do:
  return error .
end.
if p-subject begins {&table_user-account-attr} + "."
then
   run user-obj-proc in this-procedure(output p-description) no-error  .
else CASE p-subject:
  when {&table_user-login} then 
    do:
      run user-login-proc in this-procedure(output p-description) no-error  .
    end.
  when {&table_user-account} then 
    do:
      run user-account-proc in this-procedure(output p-description) no-error  .
    end.
  when {&table_user-obj} then 
    do:
      run user-obj-proc in this-procedure(output p-description) no-error  .
    end.
  when {&table_user-host} then 
    do:
      run user-obj-proc in this-procedure(output p-description) no-error  .
    end.
  when {&table_user-login-action-role} then 
    do:
      run user-obj-proc in this-procedure(output p-description) no-error  .
    end.
END CASE.
if error-status:error then 
do:
  return error substitute("&1 &2", error-status:get-message(1), return-value ) .
end.

procedure user-login-proc :
  define output parameter p-description as character no-undo .
  define buffer curr_c-user-login for ub.c-user-login  .
  do
    on error undo, return error
    :
    find first curr_c-user-login no-lock where
      curr_c-user-login.user-id = p-user-id
      AND curr_c-user-login.chip-num = p-chip-num
      AND curr_c-user-login.corr-user-db-num = p-corr-user-db-num
      no-error .
    if not avail curr_c-user-login then 
    do:
      v-mess = "Неверная ссылка на c-user-login в таблице c-usr-hist".
      run err-mess in this-procedure ( input-output v-mess).
      return error v-mess.
    end.
&scop fields-name-list  "db-num,user-login,user-password-encoded,user-administrator,max-discnt,last-login-mjd,status_,user-password-set-mjd,cntxt-menu-code,cntxt-menu-group-id,last-login-computer-name,last-login-computer-userid,last-login-process-id,login-error-count,show-goods-fields,action-check-parent,quest-print"

    define variable v-label-param as character no-undo .

    v-label-param =
      "user-login" + {&delim-par} + "Логин" + {&delim-par} + "" + {&delim-flf}
      + "user-password-encoded" + {&delim-par} + "Пароль" + {&delim-par} + "" + {&delim-flf}
      + "user-administrator" + {&delim-par} + "Администратор" + {&delim-par} + "" + {&delim-flf}
      + "max-discnt" + {&delim-par} + "Максимальная скидка" + {&delim-par} + "" + {&delim-flf}
      + "last-login-mjd" + {&delim-par} + "Дата и время последнего входа в систему" + {&delim-par} + "" + {&delim-flf}
      + "status_" + {&delim-par} + "Статус" + {&delim-par} + "" + {&delim-flf}
      + "user-password-set-mjd" + {&delim-par} + "Дата и время задания пароля" + {&delim-par} + "" + {&delim-flf}
      + "cntxt-menu-code" + {&delim-par} + "Код меню" + {&delim-par} + "" + {&delim-flf}
      + "cntxt-menu-group-id" + {&delim-par} + "Идентификатор группы пунктов меню" + {&delim-par} + "" + {&delim-flf}
      + "last-login-computer-name" + {&delim-par} + "Компьютер" + {&delim-par} + "" + {&delim-flf}
      + "last-login-computer-userid" + {&delim-par} + "Имя пользователя в компьютере" + {&delim-par} + "" + {&delim-flf}
      + "last-login-process-id" + {&delim-par} + "Идентификатор процесса" + {&delim-par} + "" + {&delim-flf}
      + "login-error-count" + {&delim-par} + "Попыток доступа" + {&delim-par} + "" + {&delim-flf}
      + "show-goods-fields" + {&delim-par} + "Список полей" + {&delim-par} + "" + {&delim-flf}
      + "action-check-parent" + {&delim-par} + "Проверять права в соответствии с родительским ид" + {&delim-par} + "" + {&delim-flf}
      + "db-num" + {&delim-par} + "БД" + {&delim-par} + "" + {&delim-flf}
      + "quest-print" + {&delim-par} + "Задавать вопрос: куда выводить документ?" + {&delim-par} + "".
    run proc-full-temp-changes in this-procedure (
      input buf_c-usr-hist.action = integer({&hn-create})
      ,input buf_c-usr-hist.action = integer({&hn-delete})
      ,input  buffer curr_c-user-login:handle
      ,input  {&table_user-login}
      ,input  {&fields-name-list}
      ,input  v-label-param).

  end.

end procedure. /* user-login-proc */


procedure user-account-proc :
  define output parameter p-description as character no-undo .
  define buffer curr_c-user-account for ub.c-user-account  .

  do
    on error undo, return error
    :
    find first curr_c-user-account no-lock where
      curr_c-user-account.user-id = buf_c-usr-hist.user-id
      AND curr_c-user-account.chip-num = p-chip-num
      AND curr_c-user-account.corr-user-db-num = p-corr-user-db-num   no-error .
    if not avail curr_c-user-account then 
    do:
      v-mess = "Неверная ссылка на c-user-account в таблице c-usr-hist".
      run err-mess in this-procedure ( input-output v-mess).
      return error v-mess.
    end.

&scop fields-name-list  "nik,status_,last-name,first-name,second-name,phone-number,internal-phone-number,mobile-phone-number,e-mail,company,department,position,room,PS"

    define variable v-label-param as character no-undo .

    v-label-param =
      "nik" + {&delim-par} + "Псевдоним" + {&delim-par} + "" + {&delim-flf}
      + "status_" + {&delim-par} + "Статус" + {&delim-par} + "" + {&delim-flf}
      + "last-name" + {&delim-par} + "Фамилия" + {&delim-par} + "" + {&delim-flf}
      + "first-name" + {&delim-par} + "Имя" + {&delim-par} + "" + {&delim-flf}
      + "second-name" + {&delim-par} + "Отчество" + {&delim-par} + "" + {&delim-flf}
      + "phone-number" + {&delim-par} + "Городской телефон" + {&delim-par} + "" + {&delim-flf}
      + "internal-phone-number" + {&delim-par} + "Внутренний телефон" + {&delim-par} + "" + {&delim-flf}
      + "mobile-phone-number" + {&delim-par} + "Мобильный телефон" + {&delim-par} + "" + {&delim-flf}
      + "e-mail" + {&delim-par} + "Эл.почта" + {&delim-par} + "" + {&delim-flf}
      + "company" + {&delim-par} + "Компания" + {&delim-par} + "" + {&delim-flf}
      + "department" + {&delim-par} + "Отдел" + {&delim-par} + "" + {&delim-flf}
      + "position" + {&delim-par} + "Должность" + {&delim-par} + "" + {&delim-flf}
      + "room" + {&delim-par} + "Комната" + {&delim-par} + "" + {&delim-flf}
      + "PS" + {&delim-par} + "Примечание" + {&delim-par} + ""  .
    run proc-full-temp-changes in this-procedure (
      input buf_c-usr-hist.action = integer({&hn-create})
      ,input buf_c-usr-hist.action = integer({&hn-delete})
      ,input  buffer curr_c-user-account:handle
      ,input  {&table_user-account}
      ,input  {&fields-name-list}
      ,input  v-label-param).




  end.

end procedure. /* user-account-proc */


procedure user-obj-proc :
  define output parameter p-description as character no-undo .
  define buffer curr_c-usr-hist for ub.c-usr-hist  .

  do
    on error undo, return error
    :
    find first curr_c-usr-hist no-lock where
      curr_c-usr-hist.user-id = buf_c-usr-hist.user-id
      AND curr_c-usr-hist.chip-num = p-chip-num
      AND curr_c-usr-hist.corr-user-db-num = p-corr-user-db-num   no-error .
    if not avail curr_c-usr-hist then 
    do:
      v-mess = "Неверная ссылка на c-usr-hist".
      run err-mess in this-procedure ( input-output v-mess).
      return error v-mess.
    end.
    define variable vobj as character no-undo.
    define variable vDB as character no-undo.
    assign
       vobj = entry(1,curr_c-usr-hist.source-ref,{&delim-par})
       vDB  = entry(2,curr_c-usr-hist.source-ref,{&delim-par})
    no-error.
    create  temp-changes.
    assign
      temp-changes.l_name       = curr_c-usr-hist.subject
      temp-changes.uniq-key-rec = STRING (curr_c-usr-hist.chip-num)
      .
    if curr_c-usr-hist.action = integer({&hn-create}) then temp-changes.v_new = vobj . 
    else temp-changes.v_old = vobj .
    if vDB ne ""
    then do:
       create  temp-changes.
       assign
         temp-changes.f_name       = "db-num"
         temp-changes.l_name       = "БД"
         temp-changes.uniq-key-rec = STRING (curr_c-usr-hist.chip-num)
         .
       if curr_c-usr-hist.action = integer({&hn-create}) then temp-changes.v_new = vDB . 
       else temp-changes.v_old = vDB .
    end.

  end.

end procedure. /* user-obj-proc */


PROCEDURE err-mess:
  DEFINE INPUT-output PARAMETER p-mess as character No-UNDO.
  CASE p-silent:
    when yes then 
      do:
        p-mess =
          substitute("История пользователя &1: щепка &2 БД:&3  Предмет изменений &4&5&6"
          ,p-user-id
          , p-chip-num
          , p-corr-user-db-num
          , p-subject
          , {&new-line}
          , p-mess
          ).
      end.
    otherwise 
    do:
      message
        p-mess
        view-as alert-box error .
    end.
  end.
END PROCEDURE.