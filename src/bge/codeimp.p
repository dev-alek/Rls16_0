/*
Автор: Рубан Дмитрий Андреевич 
Дата создания: 16 марта 2025 г.
Author:  Ruban Dmitriy Andreevich
Creation date: 16 февр. 2023 г.

*/
using ibs.th.bge.xmlimpexp.


define variable vss-revision    as character no-undo init "нету ее":U .
define variable vss-author      as character no-undo init "Рубан Дмитрий Андреевич":U .
define variable vss-date        as character no-undo init "16 марта 2025 г":U .
define variable vss-workfile    as character no-undo init "bge/codeimp.p":U .
define variable vss-archive     as character no-undo init "codeimp.p":U .
define variable vss-description as character no-undo init "Импорт файлов".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ utl/search.i }

define variable varlog          as logical         no-undo.
define variable mFileName       as character       no-undo.
define variable mfile           as character       no-undo.
define variable mfilemd5        as character       no-undo.
define variable mtxt            as character       no-undo.
define variable v-md5-signature as character       no-undo.
define variable vimport         as class xmlimpexp no-undo.
define stream md5in.
define variable vErrMes as character no-undo.
system-dialog get-file mFileName title "Выберите файл для загрузки"
    filters "Файлы (*.xml)" "*.xml,",
            "Все файлы" "*.*"
    initial-filter 1
    must-exist             
    update varlog.
if not varlog then return error "Отказ от импорта" .

mfile    = search(mFileName).
entry(num-entries(mFileName,"."),mFileName,".")= "md5".
mfilemd5 = search(mFileName).
if    mfile    eq ? 
   or mfilemd5 eq ?
then 
   return error "файл не найден".
input  stream md5in from value (mfilemd5).
import stream md5in mtxt no-error.
input  stream md5in close.
run gbl/md5.p (
       input  mfile
      ,output v-md5-signature /* p-md5-signature */
      ) .
if mtxt eq {utl/chekmd5.i v-md5-signature } 
then do:
   vimport = new xmlimpexp(). 
   
   vimport:xmldom-load-ver  ( mfile,? ) no-error.
   if error-status:error
   then
      return error return-value.
   
   UPD_TBL:
   do transaction on error undo UPD_TBL, leave UPD_TBL:
       vimport:updatetablefordb(this-procedure) no-error.
       if error-status:error
       then return error return-value.
         
   end.
   return-value = "".
   vimport:xmldom-clear().
   
   message "Загрузка успешно завершена."
   view-as alert-box.
end.
else do:
   vErrMes = substitute("Файл &1 имеет не правильную сигнатуру md5.", mfile).
   return error vErrMes.
 end.   
finally:
   if valid-object (vimport)
   then 
      delete object vimport.
end.