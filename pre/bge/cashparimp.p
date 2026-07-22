block-level on error undo, throw.
using ibs.th.bge.execlimpexp.
define variable mFileName as character no-undo init "cash-param.xslx".
define variable vss-revision    as character no-undo init "$Revision:$":U .
define variable vss-author      as character no-undo init "$Author:$":U .
define variable vss-date        as character no-undo init "$Date:$":U .
define variable vss-workfile    as character no-undo init "$Workfile:$":U .
define variable vss-archive     as character no-undo init "$Archive:$":U .
define variable vss-description as character no-undo init "".
procedure vss-get-info :
  define output parameter p-vss-revision    like vss-revision    no-undo .
  define output parameter p-vss-author      like vss-author      no-undo .
  define output parameter p-vss-date        like vss-date        no-undo .
  define output parameter p-vss-workfile    like vss-workfile    no-undo .
  define output parameter p-vss-archive     like vss-archive     no-undo .
  define output parameter p-vss-description like vss-description no-undo .
  assign
    p-vss-revision    = vss-revision
    p-vss-author      = vss-author
    p-vss-date        = vss-date
    p-vss-workfile    = vss-workfile
    p-vss-archive     = vss-archive
    p-vss-description = vss-description
  .
end procedure.
procedure vss-get-parameters :
  define output parameter p-vss-parameters as character no-undo .
end procedure.
define new global shared variable g#vssrevis-logger as handle    no-undo .
define variable v-vssrevis-logevent                 as logical   no-undo init false .
define variable v-vssrevis-logger                   as handle    no-undo .
procedure vss-logevent :
  define input  parameter p-extra-paramters as character no-undo .
  define variable v-vssrevis-parameters as character no-undo .
  do
  on error undo, return error return-value
  :
    if  valid-handle(v-vssrevis-logger)
    and v-vssrevis-logger :get-signature("logevent") <> ""
    then do:
      run vss-get-parameters in this-procedure
        (output v-vssrevis-parameters
        ).
      run logevent in v-vssrevis-logger
        (input vss-workfile
        ,input vss-revision
        ,input v-vssrevis-parameters
        ,input p-extra-paramters
        ).
    end.
  end.
end procedure.
assign
  v-vssrevis-logger = g#vssrevis-logger
.
if  valid-handle(v-vssrevis-logger)
and v-vssrevis-logger :get-signature("logevent") <> ""
then do:
  assign
    v-vssrevis-logevent = true
  .
  run vss-logevent in this-procedure (input vss-description) .
end.
define variable vfileLog as character no-undo init "ImpCashParam.txt".
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
function objExists return character
(input  ifolder as character,
 input  iType   as character  ):
    define variable vFileType as character no-undo init "D,F".
    define variable vi        as integer no-undo.
    define variable vtype as character no-undo.
    if iType ne ?
    then
       vFileType = iType.
    do vi = 1 to num-entries(vFileType):
       file-information:file-name = ".\" + right-trim(replace(ifolder,"/","\"),"\").
       vtype = file-information:file-type.
       if entry(num-entries(file-information:file-name, "\"), file-information:file-name, "\")
          = entry(num-entries(file-information:full-pathname, "\"), file-information:full-pathname ,"\") and
          index(vtype , entry(vi,vFileType )) > 0
       then return file-information:full-pathname .
       file-information:file-name = right-trim(replace(ifolder,"/","\"),"\").
       vtype = file-information:file-type.
       if file-information:file-name <> "" and
          entry(num-entries(file-information:file-name, "\"), file-information:file-name, "\")
          = entry(num-entries(file-information:full-pathname, "\"), file-information:full-pathname ,"\") and
          index( vtype, entry(vi,vFileType )) > 0
       then return file-information:full-pathname .
    end.
    return ? .
end.
function SearchFile return character
(input  ifile as character):
   return objExists(ifile,?).
end.
function SearchPFile return character
(input inFile as char):
     define variable oFile       as character no-undo.
     define variable vFileSearch as character no-undo.
     define variable vNumEntry   as integer no-undo.
     if inFile = "" then return ?.
     vNumEntry = num-entries(inFile,".").
     vFileSearch = inFile.
     if    vNumEntry > 0
        and (   entry(vNumEntry,inFile,".") eq "p"
             or entry(vNumEntry,inFile,".") eq "w")
     then do:
        entry(vNumEntry,vFileSearch, ".") = "r".
        oFile = search(vFileSearch ).
        if oFile eq ?
        then
           oFile = search(inFile).
     end.
     else
        oFile = search(vFileSearch).
     return oFile.
  end.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define   shared variable g#auto as logical no-undo.
define   shared variable g#news as logical no-undo.
define   shared variable g#oxml as logical no-undo.
define   shared variable g#esys as logical no-undo.
define   shared variable g#news-source-db as integer no-undo.
define   shared variable g#esys-source-esys as integer no-undo.
define   shared variable g#db-num as integer   no-undo .
define   shared variable g#userid as character no-undo .
define   shared variable g#passwd as character no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function is-numeral return logical
  (input p-string   as character ,
   input char-avail as character) :
  define variable p-replace-string as character no-undo .
  define variable log-result       as logical  no-undo .
  if p-string = ? then
    return false .
  p-replace-string = p-string.
  if lookup ("*", char-avail) > 0 then
      p-replace-string = replace (p-replace-string, '*', '9').
  if lookup ("digit", char-avail) > 0 then
    assign
      p-replace-string = replace (p-replace-string, '0', '9')
      p-replace-string = replace (p-replace-string, '1', '9')
      p-replace-string = replace (p-replace-string, '2', '9')
      p-replace-string = replace (p-replace-string, '3', '9')
      p-replace-string = replace (p-replace-string, '4', '9')
      p-replace-string = replace (p-replace-string, '5', '9')
      p-replace-string = replace (p-replace-string, '6', '9')
      p-replace-string = replace (p-replace-string, '7', '9')
      p-replace-string = replace (p-replace-string, '8', '9')
      .
  else
     p-replace-string = replace (p-replace-string, '9', chr(15))
      .
  if lookup ("letter", char-avail) > 0 then
    assign
      p-replace-string = replace (p-replace-string, 'A', '9')
      p-replace-string = replace (p-replace-string, 'B', '9')
      p-replace-string = replace (p-replace-string, 'C', '9')
      p-replace-string = replace (p-replace-string, 'D', '9')
      p-replace-string = replace (p-replace-string, 'E', '9')
      p-replace-string = replace (p-replace-string, 'F', '9')
      p-replace-string = replace (p-replace-string, 'G', '9')
      p-replace-string = replace (p-replace-string, 'H', '9')
      p-replace-string = replace (p-replace-string, 'I', '9')
      p-replace-string = replace (p-replace-string, 'J', '9')
      p-replace-string = replace (p-replace-string, 'K', '9')
      p-replace-string = replace (p-replace-string, 'L', '9')
      p-replace-string = replace (p-replace-string, 'M', '9')
      p-replace-string = replace (p-replace-string, 'N', '9')
      p-replace-string = replace (p-replace-string, 'O', '9')
      p-replace-string = replace (p-replace-string, 'P', '9')
      p-replace-string = replace (p-replace-string, 'Q', '9')
      p-replace-string = replace (p-replace-string, 'R', '9')
      p-replace-string = replace (p-replace-string, 'S', '9')
      p-replace-string = replace (p-replace-string, 'T', '9')
      p-replace-string = replace (p-replace-string, 'U', '9')
      p-replace-string = replace (p-replace-string, 'V', '9')
      p-replace-string = replace (p-replace-string, 'W', '9')
      p-replace-string = replace (p-replace-string, 'X', '9')
      p-replace-string = replace (p-replace-string, 'Y', '9')
      p-replace-string = replace (p-replace-string, 'Z', '9')
      p-replace-string = replace (p-replace-string, '_', '9')
      .
  return p-replace-string = fill ('9', length (p-string)).
end.
if g#db-num ne 0
then do:
   message "Импорт возможен только на ГБД" view-as alert-box.
   return error.
end.
define variable v-is-erpRN    as logical no-undo .
define variable par-is-erpRN  as character no-undo .
define variable par-type      as character no-undo .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-erpRN'
  ,input  ''
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output par-is-erpRN
  ,output par-type
  ) no-error .
v-is-erpRN = lookup(par-is-erpRN, "true,yes":U) > 0.
if v-is-erpRN then do:
   message "Импорт возможен только из 1С" view-as alert-box.
   return error.
end.
os-command  value (substitute ("del /F &1 &2 exit", searchfile(vfileLog),chr(38) )).
define variable Types      as ibs.th.str.cash.CashDevice no-undo.
Types = new ibs.th.str.cash.CashDevice().
define temp-table tt-Cash-Param no-undo
field device   as integer   label "Тип устройства"
field source   as integer   label "Источник"
field section  as character label "Группа/функция"
field fparam   as character label "Параметр"
field fvalue   as character label "Значение"
field fstatus  as integer   label "Обязательный"
field fname    as character label "Описание"
field NumLine_ as integer
index device device source section fparam .
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
   oDelRec = yes.
   mStrAll = mStrAll + 1.
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
                         chr(4),
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
