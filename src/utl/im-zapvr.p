block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: im-zapvr.p $
$Archive: utl/im-zapvr.p $

Импорт накладных ЗАПР+ из заданной директории

Автор: Чернова Светлана Александровна
Дата создания: 07/16/09
Author: Svetlana Chernova
Creation date: 07/16/09

считать из директории файлы в ТТ
Каждый файл закачать в  ТТшапки и строки
Создать ВнешРасх ЗАПР+
Переложить файлы в архив

*/

define input parameter parparentproc as widget-handle no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: im-zapvr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/im-zapvr.p $":U .
define variable vss-description as character no-undo init "Импорт накладных ЗАПР+ из заданной директории".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/filelist.i }

define variable v-source-dir  as character no-undo .
define variable v-archive-dir as character no-undo .
define variable v-ok as logical   no-undo .
define variable v-err as logical   no-undo .
define variable v-os-error as integer   no-undo .
define variable v-kol as integer   no-undo .
define variable v-file-arh as character no-undo .
define variable v-trn-doc as character no-undo .
define variable i as integer   no-undo .

v-err = false .
v-kol = 0 .
define stream err .
output stream err to value("ExpenseExternal.err" )  .

run utl/dir-izp.w (
    output v-source-dir  ,
    output v-archive-dir ).
if v-source-dir  = ? or v-archive-dir = ? then do:
   put stream err unformatted  "Не заданы директроии Источника и Архива" skip .
   output stream err close .
   return .
end.


define variable g#log as logical no-undo .

g#log =  session:SET-WAIT-STATE("GENERAL") .
    run filelist-init
        ( v-source-dir ,
          true         ,
          "xml"        ,
          v-source-dir
          )  no-error .
            if error-status :error then do:
            put stream err unformatted  substitute("&3 &4 &5 - не верно заданы директории. Ошибка:  &1 &2" , return-value , error-status :get-message(1) , string(today , "99/99/9999") , string( time, "hh:mm:ss") ) skip .
            output stream err close .
            return error  .
          end.
      for each temp-filelist
          on error undo, return error :
          v-file-arh =  substitute("&1\&2" , v-archive-dir , temp-filelist.file-name ) .

          run utl/im-zaptt.p (
              input parparentproc ,
              input temp-filelist.full-name ,
              output  v-ok  ,
              output  v-trn-doc )
              no-error .
              if error-status :error then do:
                 put stream err unformatted
                    substitute("&3 &4 &5 - не принят Ошибка:  &1 &2" , return-value , error-status :get-message(1) , string(today , "99/99/9999") , string( time, "hh:mm:ss") , temp-filelist.file-name )
                    {&new-line} .
              .
              end.
              if v-ok then do:
                  v-kol = v-kol + 1.
                  os-rename value(temp-filelist.full-name) value(v-file-arh)  .
                  v-os-error = os-error .
                  run make-error (v-os-error) .
              end.
              else do:
                 v-err = true .
                 run make-error (v-os-error) .
              end.

      end. /* for each */
output stream err close .
g#log =  session:SET-WAIT-STATE("") .

if v-err = true then do:
  message "НЕ все файлы закачались !"  skip
  "Закачалось файлов: " v-kol skip
  "Ошибки в файле ExpenseExternal.err"
   view-as alert-box information .
end.
else do:
  message "ВСЕ!"  skip
   "Закачалось файлов: " v-kol view-as alert-box information .
end.



procedure make-error :
define input  parameter p-error as integer   no-undo .
  do
  on error undo, return error return-value
  :

define variable v-temp-name as character no-undo .
define variable v-err-txt as character no-undo .
define variable varchip-num as integer no-undo .
define buffer buf_trn-doc for ub.trn-doc  .


   case p-error:
     when 0 then do:
     end.
     when 10 then do:
        message "Такой файл уже есть в архиве, будет перенесен с другим именем" view-as alert-box information .
        v-temp-name =  substitute("&1\&2_&3&4.&5" , v-archive-dir , temp-filelist.file-name-no-ext, integer(today), time ,temp-filelist.file-extension) .
        message v-temp-name.
        os-rename value(temp-filelist.full-name) value(v-temp-name)  .
     end.
     otherwise do:
       v-err = false .

       run adm/os-err.p ( output v-err-txt ) .
        if v-ok = false then do:
          repeat i = 1 to num-entries(v-trn-doc) :
            find first buf_trn-doc no-lock where buf_trn-doc.doc-code = entry(i,v-trn-doc) no-error .
            if available buf_trn-doc then do:
                  run str/del-doc.p
                  ( input  parparentproc,
                    input  v-trn-doc,
                    input  g#db-num,
                    input  "del-doc.err",
                    input  ?,
                    input  ?,
                    input  g#userid,
                    input  "",
                    input  "",
                    output varchip-num ) no-error .
            end.
          end.
        end.
        if v-err-txt <> ""  then  put stream err unformatted v-err-txt skip.
     end.
   end case.
  end.

end procedure. /* make-error */