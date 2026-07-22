block-level on error undo, throw.
define input parameter        p-mode       as character no-undo .
define input parameter        p-ser-code   as integer no-undo .
define input parameter        p-db-num     as int no-undo .
define input parameter        p-maska     as character no-undo .
define input parameter        p-series    as character no-undo .
define input parameter        p-authr     as int no-undo.
define input parameter        p-wth-code  as integer   no-undo .
define input parameter        p-par-code  as integer no-undo .
define input parameter        p-beg-dd    as character no-undo .
define input parameter        p-beg-dt    as date no-undo .
define input parameter        p-beg-mm    as character no-undo .
define input parameter        p-beg-yy-smb as character no-undo .
define input parameter        p-beg-yy     as character no-undo .
define input parameter        p-chk-bdt    as integer no-undo .
define input parameter        p-chk-edt    as integer no-undo .
define input parameter        p-chk-gds    as integer no-undo .
define input parameter        p-chk-par    as integer no-undo .
define input parameter        p-chk-ser    as integer no-undo .
define input parameter        p-end-dd     as character no-undo .
define input parameter        p-end-dt     as date no-undo .
define input parameter        p-end-mm     as character no-undo .
define input parameter        p-end-yy-smb as character no-undo .
define input parameter        p-end-yy     as character no-undo .
define input parameter        p-gds-rule   as character no-undo .
define input parameter        p-gds-smb    as character no-undo .
define input parameter        p-par-rule   as character no-undo .
define input parameter        p-par-smb    as character no-undo .
define input parameter        p-PS         as character no-undo .
define input parameter        p-qnty       as integer no-undo .
define input parameter        p-range-rule as character no-undo .
define input parameter        p-range-smb  as character no-undo .
define input parameter        p-ser-rule   as character no-undo .
define input parameter        p-ser-smb    as character no-undo .
define input parameter        p-silent     as logical no-undo .
define input-output parameter p-rec        as recid     no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: wth-ser.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/wth-ser.p $":U .
define variable vss-description as character no-undo init "Сохранение маски(серии)МЦ".
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
define variable v-mess as character no-undo .
define buffer buf_wealth   for ub.wealth.
define buffer buf_wth-ser  for ub.wth-ser.
define buffer buf_wth-par  for ub.wth-par.
define buffer b_wth-ser    for ub.wth-ser.
define variable v-db-num  as integer   no-undo .
define variable v-int     as integer   no-undo.
define variable v-date    as date      no-undo.
define variable v-ChkMask as character no-undo init 0 .
define variable v-maxSmb  as integer   no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output v-db-num
  )  .
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  if p-wth-code > 0 then.
  else do:
    v-mess =  "Не указан код МЦ" .
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else 'wth-code':U).
  end.
  find first buf_wealth no-lock where
          buf_wealth.wth-code = p-wth-code no-error .
  if not available buf_wealth then do:
    v-mess = substitute("Не найдена МЦ &1!",p-wth-code).
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else 'wth-code':U).
  end.
  if buf_wealth.is-ser <> 1 then do:
    v-mess = substitute("Серия не может относиться к несерийной МЦ (&1)!",p-wth-code).
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else 'wth-code':U).
  end.
  if p-par-code > 0 then.
  else do:
    v-mess =  "Не указан код номинала МЦ" .
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else 'par-code':U).
  end.
  find first buf_wth-par no-lock where
          buf_wth-par.par-code = p-par-code
          and buf_wth-par.wth-code = p-wth-code no-error .
  if not available buf_wth-par then do:
    v-mess = substitute("Не найден номинал МЦ с кодом &1 и кодом МЦ &2!",p-par-code,p-wth-code).
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else 'par-code':U).
  end.
  if p-series = '' then do:
    v-mess =  "Не указан внешний код серии" .
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else 'series':U).
  end.
  if p-maska = '' then do:
    v-mess =  "Не указана маска по форматам кассы" .
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else 'maska':U).
  end.
  do v-int = 1 to length(p-maska):
    if index('?*0123456789':U,substring(p-maska,v-int,1)) = 0 then do:
      v-mess = 'Неверно указана маска. Разрешены только символы ?*0123456789!'.
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else 'maska':U).
    end.
    if substring(p-maska,v-int,1) = '*':U and v-int <> length(p-maska) then do:
      v-mess = 'Неверно указана маска. Символ * может быть использоваться только в конце маски!'.
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else 'maska':U).
    end.
  end.
  if p-chk-ser = 1 then do:
    v-int = int(p-ser-rule) no-error.
    if v-int > 0 then.
    else do:
      v-mess = 'Неверно указан символ проверки серии'.
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else 'ser-rule':U).
    end.
    if p-ser-smb > '' then.
    else do:
      v-mess = 'Неверно указано значение для проверки серии'.
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else 'ser-smb':U).
    end.
    run ChkMask(p-ser-rule,length(p-ser-smb)) no-error.
    if error-status:error then do:
      v-mess = return-value.
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else 'ser-smb':U).
    end.
  end.
  if p-chk-gds = 1 then do:
    v-int = int(p-gds-rule) no-error.
    if v-int > 0 then.
    else do:
      v-mess = 'Неверно указан символ проверки товара'.
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else 'gds-rule':U).
    end.
    run ChkMask(p-gds-rule,length(p-gds-smb)) no-error.
    if error-status:error then do:
      v-mess = return-value.
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else 'gds-smb':U).
    end.
  end.
  if p-chk-par = 1 then do:
    v-int = int(p-par-rule) no-error.
    if v-int > 0 then.
    else do:
      v-mess = 'Неверно указан символ проверки номинала'.
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else 'par-rule':U).
    end.
    if p-par-smb > '' then.
    else do:
      v-mess = 'Неверно указано значение для проверки номинала'.
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else 'par-smb':U).
    end.
    run ChkMask(p-par-rule,length(p-par-smb)) no-error.
    if error-status:error then do:
      v-mess = return-value.
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else 'par-smb':U).
    end.
  end.
  if p-chk-bdt = 2 and p-beg-dt = ? then do:
      v-mess = 'Не указана дата начала срока действия! '.
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else 'beg-dt':U).
  end.
  if p-chk-bdt = 1 then do:
    v-int = int(p-beg-yy) no-error.
    if v-int > 0 then.
    else do:
      v-mess = 'Неверно указан символ проверки года начала срока действия'.
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else 'beg-yy':U).
    end.
    v-int = int(p-beg-yy-smb) no-error.
    if v-int > 0 then.
    else do:
      v-mess = 'Неверно указано кол-во символов для проверки года начала срока действия'.
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else 'beg-yy-smb':U).
    end.
    if v-int > 0 and v-int <= 4 then.
    else do:
      v-mess = 'Кол-во символов для проверки года начала срока действия не должно быть больше 4-х'.
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else 'end-yy-smb':U).
    end.
    run ChkMask(p-beg-yy,int(p-beg-yy-smb) ) no-error.
    if error-status:error then do:
      v-mess = return-value.
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else 'beg-yy-smb':U).
    end.
    v-int = int(p-beg-mm) no-error.
    if v-int > 0 then.
    else do:
      v-mess = 'Неверно указан символ проверки месяца начала срока действия'.
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else 'beg-mm':U).
    end.
    run ChkMask(p-beg-mm,2 ) no-error.
    if error-status:error then do:
      v-mess = return-value.
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else 'beg-mm':U).
    end.
    v-int = int(p-beg-dd) no-error.
    if v-int > 0 then.
    else do:
      v-mess = 'Неверно указан символ проверки дня начала срока действия'.
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else 'beg-dd':U).
    end.
    run ChkMask(p-beg-dd,2 ) no-error.
    if error-status:error then do:
      v-mess = return-value.
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else 'beg-dd':U).
    end.
  end.
  if p-chk-edt = 2 and p-end-dt = ? then do:
      v-mess = 'Не указана дата начала срока действия! '.
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else 'end-dt':U).
  end.
  if p-chk-edt = 1 then do:
    v-int = int(p-end-yy) no-error.
    if v-int > 0 then.
    else do:
      v-mess = 'Неверно указан символ проверки года окончания срока действия'.
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else 'end-yy':U).
    end.
    v-int = int(p-end-yy-smb) no-error.
    if v-int > 0 then.
    else do:
      v-mess = 'Неверно указано кол-во символов для проверки года окончания срока действия'.
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else 'end-yy-smb':U).
    end.
    if v-int > 0 and v-int <= 4 then.
    else do:
      v-mess = 'Кол-во символов для проверки года окончания срока действия не должно быть больше 4-х'.
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else 'end-yy-smb':U).
    end.
    run ChkMask(p-end-yy,int(p-end-yy-smb) ) no-error.
    if error-status:error then do:
      v-mess = return-value.
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else 'end-yy-smb':U).
    end.
    v-int = int(p-end-mm) no-error.
    if v-int > 0 then.
    else do:
      v-mess = 'Неверно указан символ проверки месяца окончания срока действия'.
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else 'end-mm':U).
    end.
    run ChkMask(p-end-mm,2 ) no-error.
    if error-status:error then do:
      v-mess = return-value.
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else 'end-mm':U).
    end.
    v-int = int(p-end-dd) no-error.
    if v-int > 0 then.
    else do:
      v-mess = 'Неверно указан символ проверки дня окончания срока действия'.
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else 'end-dd':U).
    end.
    run ChkMask(p-end-dd,2 ) no-error.
    if error-status:error then do:
      v-mess = return-value.
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else 'end-dd':U).
    end.
  end.
  v-int = int(p-range-rule) no-error.
  if v-int > 0 then.
  else do:
    v-mess = 'Неверно указан символ-начало для вырезания диапазона'.
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else 'range-rule':U).
  end.
  v-int = int(p-range-smb) no-error.
  if v-int > 0 then.
  else do:
    v-mess = 'Неверно указан символ-конец для вырезания диапазона'.
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else 'range-smb':U).
  end.
  run ChkMask(p-range-rule,int(p-range-smb) - int(p-range-rule) + 1 ) no-error.
  if error-status:error then do:
    v-mess = return-value.
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else 'range-smb':U).
  end.
  if p-mode = 'ДОБАВЛЕНИЕ':U then do:
    create buf_wth-ser.
    assign
    buf_wth-ser.ser-code = next-value(s-wth-ser, ub)
    buf_wth-ser.db-num =  v-db-num.
    .
  end.
  if p-mode = 'ИЗМЕНЕНИЕ':U then do:
    find first buf_wth-ser exclusive-lock where
              recid(buf_wth-ser) = p-rec .
    if buf_wth-ser.ser-code <> p-ser-code or buf_wth-ser.db-num <> p-db-num then do:
      v-mess = substitute("Для уже имеющейся записи Серии номинала МЦ нельзя изменить код Серии или № БД &1" +
                           "старый код серии - &2 № БД - &3"
                           ,chr(10)
                           , buf_wth-ser.ser-code
                           , buf_wth-ser.db-num).
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else '':U).
    end.
  end.
  assign
  buf_wth-ser.maska      =  p-maska
  buf_wth-ser.series     =  p-series
  buf_wth-ser.authr      =  p-authr
  buf_wth-ser.wth-code   =  p-wth-code
  buf_wth-ser.par-code   =  p-par-code
  buf_wth-ser.beg-dd      = p-beg-dd
  buf_wth-ser.beg-dt     =  p-beg-dt
  buf_wth-ser.beg-mm     =  p-beg-mm
  buf_wth-ser.beg-yy-smb =  p-beg-yy-smb
  buf_wth-ser.beg-yy     =  p-beg-yy
  buf_wth-ser.chk-bdt    =  p-chk-bdt
  buf_wth-ser.chk-edt    =  p-chk-edt
  buf_wth-ser.chk-gds    =  p-chk-gds
  buf_wth-ser.chk-par    =  p-chk-par
  buf_wth-ser.chk-ser    =  p-chk-ser
  buf_wth-ser.end-dd     =  p-end-dd
  buf_wth-ser.end-dt     =  p-end-dt
  buf_wth-ser.end-mm     =  p-end-mm
  buf_wth-ser.end-yy-smb =  p-end-yy-smb
  buf_wth-ser.end-yy     =  p-end-yy
  buf_wth-ser.gds-rule   =  p-gds-rule
  buf_wth-ser.gds-smb    =  p-gds-smb
  buf_wth-ser.par-rule   =  p-par-rule
  buf_wth-ser.par-smb    =  p-par-smb
  buf_wth-ser.PS          = p-PS
  buf_wth-ser.qnty        = p-qnty
  buf_wth-ser.range-rule  = p-range-rule
  buf_wth-ser.range-smb   = p-range-smb
  buf_wth-ser.ser-rule    = p-ser-rule
  buf_wth-ser.ser-smb     = p-ser-smb
  .
  p-rec =   recid(buf_wth-ser).
  release buf_wth-ser no-error .
  if error-status:error then do:
    v-mess = substitute("Ошибка при сохранения записи номинала МЦ:&1&2&3"
                         , error-status:get-message(1)
                         , chr(10)
                         , return-value
                         ).
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else '':U).
  end.
end.
PROCEDURE err-mess:
  DEFINE INPUT-OUTPUT PARAMETER p-mess as character No-UNDO.
  CASE p-silent:
    when yes then do:
      assign
      p-mess = substitute("Серия МЦ: код &1-&2 &3&4"
                         , p-ser-code
                         , p-db-num
                         , chr(10)
                         , p-mess)
      .
    end.
    when no then do:
      message
      p-mess
      view-as alert-box error .
    end.
  end.
END PROCEDURE.
PROCEDURE ChkMask:
  DEFINE INPUT PARAMETER p-rule as char.
  DEFINE INPUT PARAMETER p-ln as int.
  def var v-i as int.
  do v-i = int(p-rule) to int(p-rule)+ p-ln - 1:
    if v-i > length(p-maska) and substring(p-maska,length(p-maska),1) <> '*' then  return error substitute('Символ &1, заданный в проверках по маске больше чем длина маски &2!',v-i,length(p-maska)).
    if lookup(string(v-i),v-ChkMask) > 0 then return error substitute('Не верно заданы проверки по маске.~nПозиция &1 используется более одного раза!',v-i).
    else  v-ChkMask =  v-ChkMask + ',' + string(v-i).
    if v-maxSmb < v-i then v-maxSmb = v-i.
  end.
END PROCEDURE.
