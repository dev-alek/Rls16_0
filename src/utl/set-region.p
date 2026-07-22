block-level on error undo, throw.
/*
$Revision:$
$Author:$
$Date:$
$Workfile:$
$Archive:$

Автор: Белова Марина Михайловна 
Дата создания: 16.06.2026
Author:  Belova Marina
Creation date: 16.06.2026

*/
{ utl/runpro.i}
define input parameter p-range-db as character no-undo.
define input parameter p-region   as character no-undo.

define variable vss-revision    as character no-undo init "$Revision:$":U .
define variable vss-author      as character no-undo init "$Author:$":U .
define variable vss-date        as character no-undo init "$Date:$":U .
define variable vss-workfile    as character no-undo init "$Workfile:$":U .
define variable vss-archive     as character no-undo init "$Archive:$":U .
define variable vss-description as character no-undo init "".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ utl/search.i }
{ cmp/trg-def.i }
{ gbl/is-num.i }
{ gbl/db-attr.i }

define variable vStartDb as integer no-undo.
define variable vEndDb as integer no-undo.
define variable vRegCode as integer no-undo.
define variable vFlg as log no-undo.

define buffer buf_regions for ub.regions.
define buffer buf_db      for ub.db.

if g#db-num ne 0
then do:
   message "Запуск процедуры возможен только на ГБД" view-as alert-box.
   return error "Запуск процедуры возможен только на ГБД".
end.

if num-entries(p-range-db,"-") = 2 then  
   assign
      vStartDb = INT(entry(1,p-range-db,"-"))
      vEndDb   = INT(entry(2,p-range-db,"-"))
      no-error.
else       
   assign
      vStartDb = INT(p-range-db)
      vEndDb   = vStartDb
      no-error.      
if error-status:error or 
   vStartDb = ? or 
   vStartDb = 0 or 
   vEndDb = ? or 
   vEndDb = 0 
then do:
    message "Неверно задан диапазон номеров БД - должны быть два числа разделенных дефисом, или одно число." view-as alert-box.
    return error "Неверно задан диапазон номеров БД - должны быть два числа разделенных дефисом, или одно число.".
end.  

vRegCode = INT(p-region) no-error.
if error-status:error or 
   vRegCode = ? then do:
    message "Неверно задан код региона - должно быть число." view-as alert-box.
    return error "Неверно задан код региона - должно быть число.".
end.

/* если задали 0 - то это удаление связи БД и региона */
if vRegCode <> 0 then do:    
    find first buf_regions no-lock
         where buf_regions.reg-code = vRegCode
         no-error .
    if not available buf_regions then do:
        message "Отсутствует регион с кодом " vRegCode view-as alert-box.
        return error substitute("Отсутствует регион с кодом &1",vRegCode).
    end.   
end.      

  def var vOk as logical no-undo .
  def var vMess as char no-undo.
  
  vMess = if vRegCode = 0 then "Удалить" else "Установить".     
  if vStartDb = vEndDb then
     vMess = substitute("&1 для базы данных номер &2", vMess, vStartDb).
  else    
     vMess = substitute("&1 для баз данных с номера &2 по номер &3",vMess, vStartDb, vEndDb).
  if vRegCode = 0 then
     vMess = substitute("&1 связь с регионом?",vMess).     
  else    
     vMess = substitute("&1 код региона &2?",vMess, vRegCode).
     
  message    
    vMess
    view-as alert-box question buttons yes-no update vOk .
  if not vOk then do:
    return .
  end.
  
vFlg = no.

do transaction
on error undo, return error:
    for each buf_db no-lock where 
             buf_db.db-num >= vStartDb
         and buf_db.db-num <= vEndDb
         :
      if vRegCode <> 0 then 
      do:       
         run db-attr-write in this-procedure (buf_db.db-num, "reg-code", vRegCode) no-error.         
         if error-status:error then do:
            message substitute("Ошибка сохранения кода региона &1 для БД &2: &3", vRegCode, buf_db.db-num, return-value)
              view-as alert-box error.
            vFlg = no.  
            undo, return no-apply. 
         end. 
         vFlg = yes.
      end.
      else do:
         run db-attr-exist in this-procedure (buf_db.db-num, "reg-code", output vFlg) no-error.
         if vFlg then do:
             run db-attr-delete in this-procedure (buf_db.db-num, "reg-code", output vFlg) no-error.
             if error-status:error or vFlg = no then do:
                message substitute("Ошибка удаления кода региона для БД &1: &2", buf_db.db-num, return-value)
                  view-as alert-box error.
                vFlg = no.  
                undo, return no-apply. 
             end.
         end.
         else vFlg = yes.
      end.       
    end.         
end.    

if not vFlg then vMess = "".
else if vRegCode = 0 then 
   vMess = "Код региона успешно удален.".
else 
   vMess = "Код региона успешно установлен.".
          
if vMess <> "" then
 MESSAGE vMess
 VIEW-AS ALERT-BOX.
 