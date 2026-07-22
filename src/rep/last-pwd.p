block-level on error undo, throw.
/*
$Revision: b30922a289ff, 3175, rls $
$Author: EShklyar $
$Date: 2022/12/27 12:54:24 $
$Workfile: last-pwd.p $
$Archive: rep/last-pwd.p $
Процедура для записи истории по БД добавляемые в группу
Автор: 
Дата 
Author: 
Creation date: 
*/
define variable vss-revision    as character no-undo init "$Revision: b30922a289ff, 3175, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: 2022/12/27 12:54:24 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: last-pwd.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/last-pwd.p $":U .
define variable vss-description as character no-undo init "Процедура для записи истории по БД добавляемые в группу".
{cmp\vssrevis.i }
{cmp\trg-def.i}
{adm\userpro.i}   
DEFINE VARIABLE v-TabUserAdm as handle no-undo.
DEFINE stream OutStr-html.
DEFINE INPUT  PARAMETER  v-report-name-html-list AS CHARACTER NO-UNDO.
DEFINE VARIABLE us_id     AS CHARACTER LABEL "id" FORMAT "x(256)" no-undo. 
DEFINE VARIABLE us_name   AS CHARACTER LABEL "us_NAME" FORMAT "x(256)" no-undo.
DEFINE VARIABLE us_login  AS CHARACTER LABEL "us_NAME" FORMAT "x(256)" no-undo. 
DEFINE VARIABLE adm_id    AS CHARACTER LABEL "id" FORMAT "x(256)" no-undo. 
DEFINE VARIABLE adm_name  AS CHARACTER LABEL "us_NAME" FORMAT "x(256)" no-undo.
DEFINE VARIABLE adm_login AS CHARACTER LABEL "us_NAME" FORMAT "x(256)" no-undo. 
DEFINE VARIABLE us_phone  AS CHARACTER FORMAT "x(32)" no-undo. 
DEFINE VARIABLE us_mobile AS CHARACTER FORMAT "x(32)" no-undo. 
DEFINE VARIABLE us_email  AS CHARACTER FORMAT "x(32)"no-undo. 
DEFINE VARIABLE us_dep    AS CHARACTER FORMAT "x(32)" no-undo. 
DEFINE VARIABLE us_dbnum  AS CHARACTER no-undo. 
DEFINE VARIABLE us_adm    AS CHARACTER no-undo. 
DEFINE VARIABLE vdate     AS CHARACTER no-undo. 
DEFINE VARIABLE vtime     AS INT       no-undo. 

define buffer buf_user-login   for ub.user-login .
define buffer buf_user-account for ub.user-account .

output stream OutStr-html to value(v-report-name-html-list) convert target 'UTF-8' /*no-convert*/.
put stream OutStr-html unformatted
      {rep/htmlhead.i}
   '<body>' skip
   '<TABLE name="1"  fit_to_page="true" orientation="landscape" CELLSPACING="0" BORDER="0">'skip
   '<thead>' skip
   ' <tr class="set_columns">' skip
   ' <td style="width:50px"></td>' skip
   ' <td style="width:200px"></td>' skip
   ' <td style="width:120px"></td>' skip
   ' <td style="width:70px"></td>' skip
   ' <td style="width:150px"></td>' skip
   ' <td style="width:150px"></td>' skip
   ' <td style="width:150px"></td>' skip
   ' <td style="width:150px"></td>' skip
   ' <td style="width:150px"></td>' skip
   '</tr>' skip
   '<tr><!-- шапка таблицы -->' skip
   '<td colspan="8" style="text-align: right;"></td>' skip
   '</tr>' skip
   '<tr>' skip
   '<td colspan="11" style="font-weight: bold; text-align: center;">Отчет о смене пароля пользователем</td>' skip
   '</tr>' skip
   '</thead>' skip
   '<tr>' skip
   '<td text_wrap="true" colspan=3 style="width: 250px; text-align: center; border: 1px solid black;">Для кого поменяли пароль:</td>' skip
   '<td text_wrap="true" colspan=3 style="width: 250px; text-align: center; border: 1px solid black;">Кто поменял пароль:</td>' skip
   '<td text_wrap="true" rowspan=2 style="width: 120px; text-align: center; border: 1px solid black;">Дата и время смены пароля</td>' skip
   '<td text_wrap="true" rowspan=2 style="width: 70px; text-align: center; border: 1px solid black;">Телефон</td>' skip
   '<td text_wrap="true" rowspan=2 style="width: 150px; text-align: center; border: 1px solid black;">Мобильный телефон</td>' skip
   '<td text_wrap="true" rowspan=2 style="width: 150px; text-align: center; border: 1px solid black;">e-mail</td>' skip
   '<td text_wrap="true" rowspan=2 style="width: 150px; text-align: center; border: 1px solid black;">Отдел</td>' skip
   '<td text_wrap="true" rowspan=2 style="width: 150px; text-align: center; border: 1px solid black;">№ БД</td>' skip
   '<td text_wrap="true" rowspan=2 style="width: 150px; text-align: center; border: 1px solid black;">Адм.БД</td>' skip
   '</tr>' skip
   '<tr>' skip
   '<td text_wrap="true" style="width: 50px; text-align: center;">User ID </td>' skip
   '<td text_wrap="true" style="width: 100px; text-align: center;">Пользователь</td>' skip
   '<td text_wrap="true" style="width: 100px; text-align: center;">Логин</td>' skip
   '<td text_wrap="true" style="width: 50px; text-align: center;">User ID </td>' skip
   '<td text_wrap="true" style="width: 100px; text-align: center;">Пользователь</td>' skip
   '<td text_wrap="true" style="width: 100px; text-align: center;">Логин</td>' skip
   '</tr>' skip
   '<tbody>' 
   .

FOR EACH user-account no-lock where user-account.status_ <> {&bef-user-status-deleted}:
   FOR EACH user-login WHERE user-login.user-id = user-account.user-id NO-LOCK:
      vdate  = ''.
      vtime  = 0.
      us_id = "".
      us_name = "".
      us_login = "" .
      adm_id = "".
      adm_name = "".
      adm_login = "" .
      us_phone = "".
      us_mobile = "".
      us_email = "".
      us_dep  = "".
      us_dbnum = "".
      if user-account.status_ = {&bef-user-status-normal} AND user-login.status_ = {&bef-user-status-normal}
         then 
      do:
         us_id = user-account.user-id.
         us_name = user-account.first-name + " " + user-account.last-name.
         us_login = user-login.user-login .
         us_phone = user-account.phone-number.
         us_mobile = user-account.mobile-phone-number.
         us_email = user-account.e-mail.
         us_dep  = user-account.department.
         us_dbnum = STRING(user-login.db-num).
         if user-login.user-administrator = yes then us_adm = 'админ.бд.'.
         else if user-login.user-administrator <> yes  then us_adm = ' '.
         run cur-time-mjd-to-date (user-login.user-password-set-mjd, output vdate, output vtime).
         if date(vdate) < 01/01/1900 then do:
            vdate = "" .
            vtime = 0 .
         end.

         find first user-login-attr no-lock where user-login-attr.attr-code = "ChangPwdUserId" and user-login-attr.user-id = user-login.user-id and
         user-login-attr.db-num = user-login.db-num no-error .
            if available (user-login-attr) then do:
            adm_id = user-login-attr.attr-value .
            FOR first buf_user-login WHERE buf_user-login.user-id = user-login-attr.attr-value NO-LOCK,
               first buf_user-account no-lock where buf_user-account.user-id = buf_user-login.user-id:
               adm_login = buf_user-login.user-login .
               adm_name = buf_user-account.first-name + " " + buf_user-account.last-name.
            end.   
         end.
         else do:
            if vdate <> "" then do:
            adm_id = us_id .
            adm_login = us_login .
            adm_name = us_name .
            end.
         end.
         put stream OutStr-html unformatted
            '<tr>' skip
            '<td text_wrap="true" style="width: 50px;">' us_id '</td>' skip
            '<td text_wrap="true" style="width: 100px;">' us_name '</td>' skip
            '<td text_wrap="true" style="width: 100px;">' us_login '</td>' skip
            '<td text_wrap="true" style="width: 50px;">' adm_id '</td>' skip
            '<td text_wrap="true" style="width: 100px;">' adm_name '</td>' skip
            '<td text_wrap="true" style="width: 100px;">' adm_login '</td>' skip
            /* '<td style="width: 120px;">' sys-time_mjd-to-loc-str-func(user-login.user-password-set-mjd) '</td>' skip */
            '<td text_wrap="true" style="width: 120px;">' vdate ' ' if vtime = 0 then "" else STRING(vtime, "HH:MM")  '</td>' skip 
            '<td text_wrap="true" style="width: 70px;">' us_phone '</td>' skip
            '<td text_wrap="true" style="width: 150px;">' us_mobile '</td>' skip
            '<td text_wrap="true" style="width: 150px;">' us_email '</td>' skip
            '<td text_wrap="true" style="width: 150px;">' us_dep '</td>' skip
            '<td text_wrap="true" style="width: 150px;">' us_dbnum  '</td>' skip
            '<td text_wrap="true" style="width: 150px;">' us_adm  '</td>' skip
            '</tr>' skip
            .
      END.
    END. 
END. 

put stream OutStr-html unformatted
'<tbody>' skip
'</table>'
.

output stream OutStr-html close.   





