block-level on error undo, throw.
define input  parameter iKey     as integer no-undo.
define output parameter oChekSum as character no-undo.
if userid("ub") eq ""
then do:
   oChekSum = encode(string(iKey * 13)) + string(index(encode(string(iKey)), "k"))
 .
   return.
end.
define input parameter p-range-db as character no-undo.
define input parameter p-region   as character no-undo.
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
procedure db-attr-code :
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-code in g#attr-lib
      (input  p-code
      ,output p-type
      ,output p-format
      ,output p-label
      ,output p-user-can-edit
      ,output p-output-display
      ,output p-other
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure db-attr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-tooltip in g#attr-lib
      (input  p-code
      ,output p-tooltip
      ,output p-label
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure db-attr-value :
  define input  parameter p-db-num    like ub.db-attr.db-num     no-undo .
  define input  parameter p-code      like ub.db-attr.attr-code  no-undo .
  define output parameter p-value     like ub.db-attr.attr-value no-undo .
  define output parameter p-type      as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-value in g#attr-lib
      (input  p-db-num
      ,input  p-code
      ,output p-value
      ,output p-type
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure db-attr-write :
  define input parameter p-db-num    like ub.db-attr.db-num     no-undo .
  define input parameter p-code      like ub.db-attr.attr-code  no-undo .
  define input parameter p-value     like ub.db-attr.attr-value no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-write in g#attr-lib
      (input p-db-num
      ,input p-code
      ,input p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure db-attr-exist :
  define input  parameter p-db-num    like ub.db-attr.db-num     no-undo .
  define input  parameter p-code      like ub.db-attr.attr-code  no-undo .
  define output parameter p-exist    as logical  no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-exist in g#attr-lib
      (input  p-db-num
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure db-attr-delete :
  define input  parameter p-db-num   like ub.db-attr.db-num     no-undo .
  define input  parameter p-code     like ub.db-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo.
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-delete in g#attr-lib
      (input  p-db-num
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure db-attr-news :
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-news in g#attr-lib
      (input  p-code
      ,output p-news
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure db-attr-manual-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-manual-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure db-attr-batch-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-batch-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
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
