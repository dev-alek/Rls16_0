block-level on error undo, throw.
/*
$Revision:$
$Author:$
$Date:$
$Workfile:$
$Archive:$

Автор: Рубан Дмитрий Андреевич 
Дата создания: 16 февр. 2023 г.
Author:  Ruban Dmitriy Andreevich
Creation date: 16 февр. 2023 г.

*/
using ibs.th.bge.execlimpexp.

define variable mFileName as character no-undo init "cash-param.xslx".

define variable vss-revision    as character no-undo init "$Revision:$":U .
define variable vss-author      as character no-undo init "$Author:$":U .
define variable vss-date        as character no-undo init "$Date:$":U .
define variable vss-workfile    as character no-undo init "$Workfile:$":U .
define variable vss-archive     as character no-undo init "$Archive:$":U .
define variable vss-description as character no-undo init "".
{ cmp/vssrevis.i }
define variable vfileLog as character no-undo init "ImpCashParam.txt".
{ cmp/str-glbl.i }
{ utl/search.i }
{ cmp/trg-def.i }
{ gbl/is-num.i }

if g#db-num ne 0
then do:
   message "Импорт возможен только на ГБД" view-as alert-box.
   return error.
end.

define variable v-is-erpRN    as logical no-undo .
define variable par-is-erpRN  as character no-undo .
define variable par-type      as character no-undo .
{ gbl/conf-rd.i "'is-erpRN'"   "''" "''" 0 "''" "''" "''"  no par-is-erpRN     par-type      no-error}
v-is-erpRN = lookup(par-is-erpRN, "true,yes":U) > 0.
if v-is-erpRN then do:
   message "Импорт возможен только из 1С" view-as alert-box.
   return error.
end.

os-command  value (substitute ("del /F &1 &2 exit", searchfile(vfileLog),{&ampersand} )).

define variable Types      as ibs.th.str.cash.CashDevice no-undo.
Types = new ibs.th.str.cash.CashDevice().
{ bge/cashpartt.i }
define variable varlog as logical no-undo.
define variable mFileFullPath as character no-undo.
system-dialog get-file mFileName title "Выберите файл для загрузки эталонных параметров кассы"
    filters "MS Excel (*.xls,*.xlsx)" "*.xls,*.xlsx",
            "Все файлы" "*.*"
    initial-filter 1
    must-exist             
    update varlog.
if not varlog then return error "Отказ от импорта" .

assign
   file-info:file-name = mFileName
   mFileFullPath           = file-info:full-pathname
.
if length(mFileFullPath) > 0 then .
else return error substitute("Не найден файл &1", mFileName).   


define variable exlim as class ibs.th.bge.execlimpexp no-undo.

define variable choice as integer no-undo .
run gbl/d-askw.w (input "Режим работы"
                 ,input "Выберите режим работы"
                 ,input "|^"
                 ,input "Перезаписать^confirm|Вывести в лог|Добавить новые|Отмена"
                 ,input "Все совпадающие строки будут перезаписаны|Будет сформирован лог-файл с результатом сравнения|Добавить новые записи|Прервать загрузку"
                 ,input 2
                 ,input 4
                 ,output choice) no-error.
if choice eq 4
then do:
   run WriteLog ("Пользователь отказался.").
end.
else do:
   exlim = new ibs.th.bge.execlimpexp (this-procedure).
   subscribe "WriteLogExel" anywhere run-procedure "WriteLog".
   subscribe "WorkLineExel" anywhere.
   exlim:impExcel(mFileFullPath, temp-table tt-cash-param:handle).
   
   delete object exlim.
   unsubscribe "WorkLineExel".
   unsubscribe "WriteLogExel".
end.
define variable mStrLoad as integer no-undo.
define variable mStrAll  as integer no-undo.
 
if searchfile(vfileLog) ne ?
then
   message "Сформирован лог " searchfile(vfileLog) skip
           "Обработано строк: " mStrAll skip
           "Создано/Изменено записей: " mStrLoad
   view-as alert-box.
else
   message "Расхождений нет."
   view-as alert-box.

define stream Slog.
define variable mfirst as logical no-undo init true.
procedure WriteLog:
   define input  parameter itext as character no-undo.
   if mfirst
   then do:
      mFirst = false.
      output stream Slog to value(vfileLog).
   end.
   else
      output stream Slog to value(vfileLog) append.
   put stream Slog unformatted itext skip.
   output stream Slog close. 
end.

procedure WorkLineExel:
   define input  parameter iBuffer as handle no-undo.
   define output parameter oDelRec as logical no-undo.
   /* будем считать что запись нам больше не нужна */
   oDelRec = yes.
   mStrAll = mStrAll + 1.
   /* Не красиво но*/
   if not iBuffer:available then return.
   if Types:GetProp(iBuffer::device) eq Types:Unknow
   then do:
      run WriteLog(
                   substitute ("Строка &1 недопустимое значение &2 поля &3",
                               iBuffer::NumLine_,
                               iBuffer::device, 
                               iBuffer:buffer-field( "device"):label
                               )
                   ).
      return.
   end.
   if     iBuffer::source ne 1 
      and iBuffer::source ne 2   
   then do:
      run WriteLog(
                   substitute ("Строка &1 недопустимое значение &2 поля &3 Допустимы 1 и 2",
                               iBuffer::NumLine_,
                               iBuffer::device, 
                               iBuffer:buffer-field( "source"):label)).
      return.
   end.
   if     iBuffer::fstatus ne 1 
      and iBuffer::fstatus ne 2   
   then do:
      run WriteLog(substitute ("Строка &1 недопустимое значение &2 поля &3 Допустимы 1 - обязательный и 2 - Необязательный",
                               iBuffer::NumLine_,
                               iBuffer::fstatus, 
                               iBuffer:buffer-field( "fstatus"):label)).
      return.
   end.
   if     iBuffer::section eq "" 
      or  iBuffer::section eq ?   
   then do:
      run WriteLog(substitute ("Строка &1 недопустимое значение '&2' поля &3 Не может быть пустым",
                               iBuffer::NumLine_,
                               iBuffer::section, 
                               iBuffer:buffer-field( "section"):label)).
      return.
   end.
   if not is-numeral (iBuffer::section,
                      if iBuffer::source eq 1
                      then "letter,digit"
                      else "digit")
   then do:
      run WriteLog(substitute ("Строка &1 недопустимое значение '&2' поля &3 Допустимы только &4",
                               iBuffer::NumLine_,
                               iBuffer::section, 
                               iBuffer:buffer-field( "section"):label,
                               if iBuffer::source eq 1 then "Латинкские буквы и цифры" else "Цифры" )).
      return.
   end.
   if iBuffer::source eq 1
   then do:
      if     iBuffer::fparam eq "" 
         or  iBuffer::fparam eq ?   
      then do:
         run WriteLog(substitute ("Строка &1 недопустимое значение '&2' поля &3 Не может быть пустым",
                                  iBuffer::NumLine_,
                                  iBuffer::fparam, 
                                  iBuffer:buffer-field( "fparam"):label)).
         return.
      end.
      if not is-numeral (iBuffer::fparam,
                         "letter,digit"
                         )
      then do:
         run WriteLog(substitute ("Строка &1 недопустимое значение '&2' поля &3 Допустимы только &4",
                                  iBuffer::NumLine_,
                                  iBuffer::fparam, 
                                  iBuffer:buffer-field( "fparam"):label,
                                  if iBuffer::source eq 1 then "Латинкские буквы и цыфры" else "Цыфры")).
         return.
      end.
   end.
   else do:
      if     iBuffer::fvalue ne "MGR"
         and iBuffer::fvalue ne "REG"   
      then do:
         run WriteLog(substitute ("Строка &1 недопустимое значение &2 поля &3 Допустимы MGR - менаджер и REG - кассир",
                                  iBuffer::NumLine_,
                                  iBuffer::fvalue, 
                                  iBuffer:buffer-field( "fvalue"):label)).
         return.
      end.
   end.
   define variable mparent as character no-undo.
   mparent = substitute ("cash-param&1&2&1&3&1&4",
                         {&delim-par},
                         iBuffer::device,
                         iBuffer::source,
                         iBuffer::section).
   find first code where Code.parent eq mparent
                     and Code.code   eq iBuffer::fparam
   no-lock no-error.
   if not available code
   then do:
      if    choice ne 2
      then do:
         create code.
         assign
            Code.parent = mparent
            Code.code   = iBuffer::fparam
         .
         assign
            Code.code      = iBuffer::fparam  
            Code.CodeName  = iBuffer::fname   
            Code.CodeValue = iBuffer::fvalue  
            Code.status_   = iBuffer::fstatus - 1
            Code.nwsgbd    = yes
         .
         mStrLoad = mStrLoad + 1.
         run WriteLog("Создана запись " +
                      substitute ("&1:&2 ",exlim:getFieldName(iBuffer:buffer-field ("device")),iBuffer::device) +
                      substitute ("&1:&2 ",exlim:getFieldName(iBuffer:buffer-field ("source")),iBuffer::source) +
                      substitute ("&1:&2 ",exlim:getFieldName(iBuffer:buffer-field ("section")),iBuffer::section) +
                      substitute ("&1:&2 ",exlim:getFieldName(iBuffer:buffer-field ("fparam")),iBuffer::fparam) +
                      substitute ("&1:&2 ",exlim:getFieldName(iBuffer:buffer-field ("fvalue")),iBuffer::fvalue) +
                      substitute ("&1:&2 ",exlim:getFieldName(iBuffer:buffer-field ("fname")),iBuffer::fname) +
                      substitute ("&1:&2 ",exlim:getFieldName(iBuffer:buffer-field ("fstatus")),iBuffer::fstatus)
                      ).  
      end.
      else do:
         run WriteLog("Отсутствует запись " +
                      substitute ("&1:&2 ",exlim:getFieldName(iBuffer:buffer-field ("device")),iBuffer::device) +
                      substitute ("&1:&2 ",exlim:getFieldName(iBuffer:buffer-field ("source")),iBuffer::source) +
                      substitute ("&1:&2 ",exlim:getFieldName(iBuffer:buffer-field ("section")),iBuffer::section) +
                      substitute ("&1:&2 ",exlim:getFieldName(iBuffer:buffer-field ("fparam")),iBuffer::fparam) +
                      substitute ("&1:&2 ",exlim:getFieldName(iBuffer:buffer-field ("fvalue")),iBuffer::fvalue) +
                      substitute ("&1:&2 ",exlim:getFieldName(iBuffer:buffer-field ("fname")),iBuffer::fname) +
                      substitute ("&1:&2 ",exlim:getFieldName(iBuffer:buffer-field ("fstatus")),iBuffer::fstatus)
                      ).
      end.
   end.
   else do:
      if     Code.code      ne iBuffer::fparam  
         or  Code.CodeName  ne iBuffer::fname   
         or  Code.CodeValue ne iBuffer::fvalue  
         or  Code.status_   ne iBuffer::fstatus - 1
      then do:
         
         if choice eq 1
         then do:
            run WriteLog("Изменена запись " +
                      substitute ("&1:&2 ",exlim:getFieldName(iBuffer:buffer-field ("device")),iBuffer::device) +
                      substitute ("&1:&2 ",exlim:getFieldName(iBuffer:buffer-field ("source")),iBuffer::source) +
                      substitute ("&1:&2 ",exlim:getFieldName(iBuffer:buffer-field ("section")),iBuffer::section) +
                      (if Code.code      ne iBuffer::fparam  then substitute ("&1: старое &2 новое &3 ",exlim:getFieldName(iBuffer:buffer-field ("fparam" )),Code.code,     iBuffer::fparam)  else "")  +
                      (if Code.CodeName  ne iBuffer::fname   then substitute ("&1: старое &2 новое &3 ",exlim:getFieldName(iBuffer:buffer-field ("fname"  )),Code.CodeName, iBuffer::fname)   else "")  +
                      (if Code.CodeValue ne iBuffer::fvalue  then substitute ("&1: старое &2 новое &3 ",exlim:getFieldName(iBuffer:buffer-field ("fvalue" )),Code.CodeValue,iBuffer::fvalue)  else "")  +
                      (if Code.status_   ne iBuffer::fstatus then substitute ("&1: старое &2 новое &3 ",exlim:getFieldName(iBuffer:buffer-field ("fstatus")),Code.status_ , iBuffer::fstatus) else "")  
                      ).
      
            find first code where Code.parent eq mparent
                     and Code.code   eq iBuffer::fparam
            exclusive-lock no-error.
            assign
               Code.code      = iBuffer::fparam  
               Code.CodeName  = iBuffer::fname   
               Code.CodeValue = iBuffer::fvalue  
               Code.status_   = iBuffer::fstatus - 1
               Code.nwsgbd    = yes
            .
         
            mStrLoad = mStrLoad + 1.
         end.
         else do:
            run WriteLog("Отличается запись " +
                      substitute ("&1:&2 ",exlim:getFieldName(iBuffer:buffer-field ("device")),iBuffer::device) +
                      substitute ("&1:&2 ",exlim:getFieldName(iBuffer:buffer-field ("source")),iBuffer::source) +
                      substitute ("&1:&2 ",exlim:getFieldName(iBuffer:buffer-field ("section")),iBuffer::section) +
                      (if Code.code      ne iBuffer::fparam  then substitute ("&1: старое &2 новое &3 ",exlim:getFieldName(iBuffer:buffer-field ("fparam" )),Code.code,     iBuffer::fparam)  else "")  +
                      (if Code.CodeName  ne iBuffer::fname   then substitute ("&1: старое &2 новое &3 ",exlim:getFieldName(iBuffer:buffer-field ("fname"  )),Code.CodeName, iBuffer::fname)   else "")  +
                      (if Code.CodeValue ne iBuffer::fvalue  then substitute ("&1: старое &2 новое &3 ",exlim:getFieldName(iBuffer:buffer-field ("fvalue" )),Code.CodeValue,iBuffer::fvalue)  else "")  +
                      (if Code.status_   ne iBuffer::fstatus then substitute ("&1: старое &2 новое &3 ",exlim:getFieldName(iBuffer:buffer-field ("fstatus")),Code.status_ , iBuffer::fstatus) else "")  
                      ).
         end.
      end.
   end.
   
end.