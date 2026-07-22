block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: h_list.p $
$Archive: utl/h_list.p $

формирование списка файлов-исходников

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06

Creation date: 09/09/04 5:32

*/
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: h_list.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/h_list.p $":U .
define variable vss-description as character no-undo init "формирование списка файлов-исходников    ".
{ cmp/vssrevis.i }
{ gbl/filelist.i }

define variable  v-fill-name   as character no-undo .
define variable  v-workfile_   as character no-undo .
define variable  v-author      as character no-undo .
define variable  v-description as character no-undo .
define variable  v-hlp as logical no-undo .
define variable g#log as logical no-undo .
define variable my-dir as character no-undo init "c:\work15_0\".
define variable v-exist as logical no-undo init false .
g#log =  session:SET-WAIT-STATE("GENERAL") .

define stream out-stream .
define stream htm-stream .

output stream out-stream to value (my-dir + "tt-help.txt") .
put stream out-stream unformatted
"Имя файла"                             at 1
"Workfile"                              at 12
"Author"                                at 25
"app"                                   at 40
"Написан"                               at 42
"Описание , то что после Archive"       at 50
skip
.


run filelist-dirlist-subdir-init (input  "y:\ver14_0\") no-error .
if error-status :error then
        message vss-workfile vss-revision vss-description skip
       "Ошибка  1" skip
        skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error
.


for each temp-dirlist
    on error undo, return error :
    run filelist-clear .
    /* пропускаю */
   /*
    if /* temp-dirlist.dir-short-name = "rep"  or
       temp-dirlist.dir-short-name = "trg"  or
       temp-dirlist.dir-short-name = "utl" */
       temp-dirlist.dir-short-name <> "ref"
       then next.
     */

    run filelist-init
        ( temp-dirlist.dir-full-name  ,
          true                        ,
          "w"                         ,
          temp-dirlist.dir-short-name
          )  no-error .
        if error-status :error then
                message vss-workfile vss-revision vss-description skip
              "Ошибка 2 " skip
                skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error
        .
      for each temp-filelist
          on error undo, return error :
          /*if temp-filelist.file-name-no-ext <> "findocgp" then next.*/
          run utl/h_ttable.p (
              input temp-filelist.full-name ,
              output   v-fill-name   ,
              output   v-workfile_   ,
              output   v-author      ,
              output   v-description ,
              output   v-hlp
                )
              no-error .
              if error-status :error then message vss-workfile vss-revision vss-description skip
                     "Ошибка 3 " skip
                      skip
                      error-status :get-message(1) skip
                      return-value skip
                      view-as alert-box error
              .

            if not ( caps(trim(v-workfile_)) begins "E-" ) or true = true  then do:
                put stream out-stream unformatted
                temp-filelist.file-name                 at 1
                trim(v-workfile_)                       at 12
                trim(v-author)                          at 25
                .

                run make-htm.

                put stream out-stream unformatted
                string(v-hlp,"+/-")                                      at 40
                temp-dirlist.dir-short-name + string(v-exist,"+/-")      at 42
                substring(trim(v-description), 1, 200 )                  at 50
                skip
                .

            end.

      end. /* for each */


end. /* for each */

output stream out-stream close.
g#log =  session:SET-WAIT-STATE("") .

message "ВСЕ готово в " my-dir "tt-help.txt " .




procedure make-htm :
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :

define variable v-header-page as character no-undo .
define variable v-descr        as character no-undo .
assign
v-header-page = v-description
v-descr =  temp-filelist.dir-short-name + " " + temp-filelist.file-name  + " " + v-author  + " " +  string(v-hlp,"+/-")
v-exist = false
.

if search(my-dir + temp-filelist.file-name-no-ext + ".htm") > '' then  do:
   v-exist = true .
   return . /* уже есть !!!*/
end.

output stream htm-stream to value ( my-dir + temp-filelist.file-name-no-ext + ".htm") .
put stream htm-stream unformatted
'<html>                                                                                                          ' skip
'<head>                                                                                                          ' skip
'<title>' + v-header-page + '</title>                                                                            ' skip
'<meta http-equiv="Content-Type" content="text/html; charset=windows-1251">                                      ' skip
'</head>                                                                                                         ' skip
'                                                                                                                ' skip
'<table border=0 cellspacing=0 cellpadding=0 width="100%" bgcolor="#649ccc"                                      ' skip
'style="width:100.0%;mso-cellspacing:0cm;background:#649CCC;mso-padding-alt:1.5pt 1.5pt 1.5pt 1.5pt">            ' skip
'  <tr>                                                                                                          ' skip
'    <td align="left">                                                                                           ' skip
'                                                                                                                ' skip
'      <span style="font-family:Helvetica,Arial; font-size:12pt; color:#FFFFFF"><b>' + v-header-page + '</b><b>  ' skip
'<br>                                                                                                            ' skip
'</b></span>                                                                                                     ' skip
'    </td>                                                                                                       ' skip
'    <td align="right">                                                                                          ' skip
'     <font face="Arial" size="2">                                                                               ' skip
'     <a href="th.htm">                                                                                          ' skip
'        <img name=main src="button_main.gif" border=0 alt="На главную страницу"></a>&nbsp;                      ' skip
'     <a href="th.htm">                                                                                          ' skip
'        <img name=prev src="button_prev.gif" border=0 alt="Предыдущая страница"></a>&nbsp;                      ' skip
'     <a href="th.htm">                                                                                          ' skip
'        <img name=next src="button_next.gif" border=0 alt="Следующая страница"></a>                             ' skip
'     </font>                                                                                                    ' skip
'    </td>                                                                                                       ' skip
'  </tr>                                                                                                         ' skip
'</table>                                                                                                        ' skip
'<br>                                                                                                            ' skip
'<body bgcolor="#FFFFFF" text="#000000" link=blue alink=purpul>                                                  ' skip
'                                                                                                                ' skip
'<p>' + v-descr + '</p>                                                                                            ' skip
'                                                                                                                ' skip
'<p><i><b><font size="+2">Управляющие кнопки:</font></b></i></p>                                                 ' skip
'<table width="100%" border="0" height="91">                                                                     '  skip
'  <tr>                                                                                                          ' skip
'    <td width="16%"><b>Выход</b></td>                                                                           ' skip
'    <td width="84%">Выход из режима</td>                                                                        ' skip
'  </tr>                                                                                                         ' skip
'  <tr>                                                                                                          ' skip
'    <td width="16%"><b>Печать</b></td>                                                                          ' skip
'    <td width="84%">Печать текущего списка </td>                                                                ' skip
'  </tr>                                                                                                         ' skip
'  <tr>                                                                                                          ' skip
'    <td width="16%"><b>История</b></td>                                                                         ' skip
'    <td width="84%">Просмотр истории изменений текущей строки </td>                                             ' skip
'  </tr>                                                                                                         ' skip
'  <tr>                                                                                                          ' skip
'    <td width="16%"><b>Ввод</b></td>                                                                            ' skip
'    <td width="84%">Запомнить изменения и выйти из режима ввода и корректировки записи</td>                     ' skip
'  </tr>                                                                                                         ' skip
'  <tr>                                                                                                          ' skip
'    <td width="16%"><b>Отказ</b></td>                                                                           ' skip
'    <td width="84%">Выход без запоминания изменений или без создания новой записи</td>                          ' skip
'  </tr>                                                                                                         ' skip
'  <tr>                                                                                                          ' skip
'    <td width="16%"><b>Фильтр</b></td>                                                                          ' skip
'    <td width="84%">Вызов режима задания параметров для фильтрации записей</td>                                 '  skip
'  </tr>                                                                                                         ' skip
'  <tr>                                                                                                          ' skip
'    <td width="16%">&nbsp;</td>                                                                                 ' skip
'    <td width="84%">&nbsp;</td>                                                                                 ' skip
'  </tr>                                                                                                         ' skip
'</table>                                                                                                        ' skip
'</body>                                                                                                         ' skip
'</html>                                                                                                         ' skip
.




output stream htm-stream close.
return .
 end. /* do */
end procedure. /* make-htm */