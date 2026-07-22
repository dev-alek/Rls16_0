block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: wthidnt.p $
$Archive: str/wthidnt.p $

Процедура идентификации топливных талонов

Автор: Гридчина Полина Дмитриевна
Дата создания: 07/02/07
Author: Polina Gridchina
Creation date: 07/02/07


*/
define input  parameter p-bar-code  as character no-undo.   /* Штрих-код */
define output parameter p-ser-code  as integer no-undo.
define output parameter p-db-num    like ub.wth-ser.db-num no-undo.
define output parameter p-stts      as integer no-undo.
define output parameter p-wth-code  like ub.wth-parts.wth-code no-undo.
define output parameter p-gds-code  as character no-undo.
define output parameter p-par-code  like ub.wth-parts.par-code no-undo.
define output parameter p-zone      as character no-undo.
define output parameter p-FromDate  as date no-undo.
define output parameter p-ToDate    as date no-undo.
/*define output parameter p-priceRubl like ub.wth-parts.price-rubl  no-undo.
define output parameter p-priceBase like ub.wth-parts.price-base  no-undo.   */
define output parameter p-range     like ub.wth-parts.fact-rangeFrom  no-undo.
/*define output parameter p-payCode   as integer no-undo.       */

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: wthidnt.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/wthidnt.p $":U .
define variable vss-description as character no-undo init "Процедура идентификации топливных талонов".
{ cmp/vssrevis.i substitute('&1|&2',p-bar-code,p-zone)}
{ cmp/trg-def.i  }
{ cmp/library.i  }

define buffer   buf_wth-ser    for ub.wth-ser.
define buffer   buf_wth-parts  for ub.wth-parts.
define buffer   buf_wth-gds    for wth-gds.
/*define variable p-range       as integer      no-undo. */
define variable v-beg-yy    as character    no-undo.
define variable v-beg-mm    as character    no-undo.
define variable v-beg-dd    as character    no-undo.
define variable v-end-yy    as character    no-undo.
define variable v-end-mm    as character    no-undo.
define variable v-end-dd    as character    no-undo.
define variable v-isser     as logical      no-undo.

Main-Block: do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  if p-bar-code > '' then.
  else return error "Не задан параметр штрих-код!".
/*Определим к какой маске\серии относится штрих-код. Это будет первая серия, все условия проверки которой датут полож. результат
Если набор символов, вырезанный по правилам определения даты не может быть датой, считаем, что тогда штрих-код не относитс
 к данной маске, даже если по всем остальным парметрам проверка прошла успешно.*/
  for each buf_wth-ser  where buf_wth-ser.stts = 0
  no-lock on error undo, return error:
  /*  if buf_wth-ser.auth = 0 then next.  */
    if buf_wth-ser.chk-ser <> 0 then do:
      if substring(p-bar-code,int(buf_wth-ser.ser-rule),length(buf_wth-ser.ser-smb)) <> buf_wth-ser.ser-smb
      then next.
    end.
    if buf_wth-ser.chk-gds = 1 then do:
      if substring(p-bar-code,int(buf_wth-ser.gds-rule),length(buf_wth-ser.gds-smb)) <> buf_wth-ser.gds-smb
      then next.
    end.
    if buf_wth-ser.chk-par = 1 then do:
      if substring(p-bar-code,int(buf_wth-ser.par-rule),length(buf_wth-ser.par-smb)) <> buf_wth-ser.par-smb
      then next.
    end.
    /*номер талона*/
    p-range = int(substring(p-bar-code,int(buf_wth-ser.range-rule),int(buf_wth-ser.range-smb) - int(buf_wth-ser.range-rule) + 1)) no-error.
    if p-range = ? then next.

    if buf_wth-ser.chk-bdt = 1  then do:  /*указано правило вырезания даты начала из штрих-кода */
      v-beg-yy = substring(p-bar-code,int(buf_wth-ser.beg-yy),length(buf_wth-ser.beg-yy-smb)) no-error.
      v-beg-mm = substring(p-bar-code,int(buf_wth-ser.beg-mm),2) no-error.
      v-beg-dd = substring(p-bar-code,int(buf_wth-ser.beg-dd),2) no-error.
      p-FromDate = date(substitute("&1/&2/&3":U,v-beg-dd,v-beg-mm,v-beg-yy)) no-error.
      if p-FromDate = ? then next.
    end.
    if buf_wth-ser.chk-bdt = 2  then do:  /*указана дата начала срока действия */
      p-FromDate = buf_wth-ser.beg-dt.
    end.

    if buf_wth-ser.chk-edt = 1  then do:  /*указано правило вырезания даты конца  из штрих-кода */
      v-end-yy = substring(p-bar-code,int(buf_wth-ser.end-yy),length(buf_wth-ser.end-yy-smb)) no-error.
      v-end-mm = substring(p-bar-code,int(buf_wth-ser.end-mm),2) no-error.
      v-end-dd = substring(p-bar-code,int(buf_wth-ser.end-dd),2) no-error.
      p-FromDate = date(substitute("&1/&2/&3":U,v-end-dd,v-end-mm,v-end-yy)) no-error.
      if p-ToDate = ? then next.
    end.
    if buf_wth-ser.chk-edt = 2  then do:  /*указана дата конца срока действия */
      p-ToDate = buf_wth-ser.end-dt.
    end.
   /* message buf_wth-ser.ser-code buf_wth-ser.wth-code  buf_wth-ser.series buf_wth-ser.maska view-as alert-box.*/
    assign p-ser-code = buf_wth-ser.ser-code
           p-db-num   = buf_wth-ser.db-num
           p-stts     = buf_wth-ser.stts
           p-wth-code = buf_wth-ser.wth-code
           p-par-code = buf_wth-ser.par-code
           v-isser = yes.
           leave.
  end.     /*each buf_wth-ser*/

  if not v-isser then return error substitute("Штрих-код &1 не удалось идентифицировать.",p-bar-code).
  /*Список товаров*/
  for each buf_wth-gds no-lock
    where buf_wth-gds.wth-code = p-wth-code
      and buf_wth-gds.stts = 0
  :
    p-gds-code = p-gds-code + (if p-gds-code > '':U then ',':U else '':U) + string(buf_wth-gds.gds-code).
  end.

  /*Поиск партий*/
  find first buf_wth-parts no-lock
  where  buf_wth-parts.ser-code = p-ser-code
     and buf_wth-parts.db-num   = p-db-num
     and buf_wth-parts.wth-code = p-wth-code
     and buf_wth-parts.par-code = p-par-code
     and buf_wth-parts.fact-rangeFrom <= p-range
     and buf_wth-parts.fact-rangeTo >= p-range
     and (buf_wth-parts.out-code = {&free-code} or
          buf_wth-parts.out-code = {&cli-zone}  or
          buf_wth-parts.out-code = {&put-zone}  or
          buf_wth-parts.out-code = {&output-code}  )
  no-error.
  if available buf_wth-parts then do:
    assign
/*        p-priceRubl = buf_wth-parts.price-rubl
        p-priceBase = buf_wth-parts.price-base  */
        p-zone = buf_wth-parts.out-code
    .
    if buf_wth-parts.beg-dt <> ?  then p-FromDate = buf_wth-parts.beg-dt.
    if buf_wth-parts.end-dt <> ?  then p-ToDate = buf_wth-parts.end-dt.
  end.

end. /*main-block*/