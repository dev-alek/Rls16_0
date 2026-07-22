block-level on error undo, throw.
/*
$Revision: 4886e87b5a2b, 3169, rls $
$Author: DRuban $
$Date: 2022/12/27 12:54:23 $
$Workfile: adm_bd.p $
$Archive: rep/adm_bd.p $
Процедура для записи истории по БД добавляемые в группу
Автор: 
Дата 
Author: 
Creation date: 
*/
define variable vss-revision    as character no-undo init "$Revision: 4886e87b5a2b, 3169, rls $":U .
define variable vss-author      as character no-undo init "$Author: DRuban $":U .
define variable vss-date        as character no-undo init "$Date: 2022/12/27 12:54:23 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: adm_bd.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/adm_bd.p $":U .
define variable vss-description as character no-undo init "Процедура для записи истории по БД добавляемые в группу".
{cmp\vssrevis.i }
{cmp\trg-def.i}
{adm\userpro.i}   

DEFINE VARIABLE i-user-id AS CHARACTER LABEL "id" FORMAT "x(15)" no-undo.
DEFINE VARIABLE o-adm-Ubd  as logical no-undo.
DEFINE VARIABLE v-adm-GBD  as logical no-undo. 
DEFINE VARIABLE o-superAdm as logical no-undo.
DEFINE VARIABLE v-TabUserAdm as handle no-undo.
DEFINE stream OutStr-html.
define variable ubd-chr as character no-undo.
define variable nom-ubd-chr as character no-undo.
define variable nom-ubd-chr_na as character no-undo.
define variable gbd-chr as character no-undo.
define variable superadm-chr as character no-undo.
DEFINE INPUT  PARAMETER  v-report-name-html-list AS CHARACTER NO-UNDO.

    output stream OutStr-html to value(v-report-name-html-list) convert target 'UTF-8'.
    put stream OutStr-html unformatted
        "<!DOCTYPE HTML>" skip
        ' <html>' skip
        '  <head>' skip
        '   <meta charset="utf-8">' skip
        '    <style type="text/css">' skip
        '      table ' + chr(123) + ' border-collapse: collapse; ' + chr(125) skip
        '      .class1 ' + chr(123) + ' border-collapse: collapse; ' + chr(125) skip
        '      tbody td, th ' + chr(123) + ' border-collapse: collapse; border: 1px solid black; height: 14px;' + chr(125) skip
        '   </style>' skip
        '  </head>' skip
        '<body>' skip
        '<TABLE name="1"  fit_to_page="true" orientation="portrait" CELLSPACING="0" BORDER="0">'skip
        '<thead>' skip
        ' <tr class="set_columns">' skip
        ' <td style="width:50px"></td>' skip
        ' <td style="width:200px"></td>' skip
        ' <td style="width:60px"></td>' skip
        ' <td style="width:60px"></td>' skip
        ' <td style="width:60px"></td>' skip
        ' <td style="width:60px"></td>' skip
        ' <td style="width:60px"></td>' skip
        '</tr>' skip
        '<tr><!-- шапка таблицы -->' skip
        '<td colspan="8" style="text-align: right;"> </td>' skip
        '</tr>' skip
        '<tr>' skip
        '<td colspan="8" style="font-weight: bold; text-align: center;">Список пользователей с правами доступа к бд.</td>' skip
        '</tr>' skip
        '</thead>' skip
        '<tr>' skip
        '<td style="width: 50px; text-align: center;">User ID</td>' skip
        '<td style="width: 200px; text-align: center;">Пользователь</td>' skip
        '<td style="width: 60px; text-align: center;">  админ   GBD  </td>' skip
        '<td style="width: 60px; text-align: center;">    superadmin  </td>' skip
        '<td style="width: 60px; text-align: center">  админ UBD</td>' skip
        '<td style="width: 60px; text-align: center">  Адм. БД </td>' skip
        '<td style="width: 60px; text-align: center">  Польз. БД </td>' skip
        '</tr>' skip
	'<tbody>' 
        .
    
 FOR EACH user-account NO-LOCK:

       run getAccountSetting(input user-account.user-id, 
	                       	output o-adm-Ubd, 
				output v-adm-GBD, 
				output o-superAdm, 
				input-output table-handle v-TabUserAdm).

 if v-adm-GBD = yes OR o-superAdm = yes OR o-adm-Ubd = yes then 
   do:

	if  v-adm-GBD = yes THEN 
        	gbd-chr = "да ".
        ELSE IF v-adm-GBD = no THEN
		gbd-chr = "нет ".
        ELSE 
		gbd-chr = "".

	if  o-superAdm = yes THEN 
        	superadm-chr = "да ".

        ELSE IF o-superAdm = no THEN
		superadm-chr = "нет ".
        ELSE 
		superadm-chr = "".


	if  o-adm-Ubd = yes THEN 
        	ubd-chr = "да".

        ELSE IF o-adm-Ubd = no THEN
		ubd-chr = "нет ".
        ELSE 
		ubd-chr = "".


             FOR EACH user-login   WHERE user-account.user-id = user-login.user-id and user-login.db <>0 and user-login.user-administrator = yes  NO-LOCK:
                  nom-ubd-chr = nom-ubd-chr + "," +  STRING(user-login.db-num) NO-ERROR .
              END. 

             FOR EACH user-login   WHERE user-account.user-id = user-login.user-id 
                                  and user-login.db <> 0 and user-login.user-administrator = no  NO-LOCK:
                  nom-ubd-chr_na = nom-ubd-chr_na + "," +  STRING(user-login.db-num) NO-ERROR .
             END. 


        nom-ubd-chr = SUBSTRING(nom-ubd-chr,2).
        nom-ubd-chr_na = SUBSTRING(nom-ubd-chr_na,2).
        put stream OutStr-html unformatted
            '<tr>' skip                                    
            '<td style="width: 50px;"> '  user-account.user-id '</td>' skip
            '<td style="width: 200px;"> ' user-account.first-name " "  user-account.last-name '</td>' skip
            '<td style="width: 60px; text-align: center"> ' gbd-chr '</td>' skip
            '<td style="width: 60px; text-align: center"> ' superadm-chr '</td>' skip
            '<td style="width: 60px; text-align: center"> ' ubd-chr '</td>' skip
            '<td style="width: 60px;">' nom-ubd-chr  '</td>' skip
            '<td style="width: 60px;">' nom-ubd-chr_na '</td>' skip
            '</tr>' skip
            .
        nom-ubd-chr = ''.
        nom-ubd-chr_na = ''.
       END. 
 END. 

put stream OutStr-html unformatted
'<tbody>' skip
'</table>'
.

output stream OutStr-html close.   





