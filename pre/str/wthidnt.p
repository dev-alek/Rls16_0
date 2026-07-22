block-level on error undo, throw.
define input  parameter p-bar-code  as character no-undo.
define output parameter p-ser-code  as integer no-undo.
define output parameter p-db-num    like ub.wth-ser.db-num no-undo.
define output parameter p-stts      as integer no-undo.
define output parameter p-wth-code  like ub.wth-parts.wth-code no-undo.
define output parameter p-gds-code  as character no-undo.
define output parameter p-par-code  like ub.wth-parts.par-code no-undo.
define output parameter p-zone      as character no-undo.
define output parameter p-FromDate  as date no-undo.
define output parameter p-ToDate    as date no-undo.
define output parameter p-range     like ub.wth-parts.fact-rangeFrom  no-undo.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: wthidnt.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/wthidnt.p $":U .
define variable vss-description as character no-undo init "Процедура идентификации топливных талонов".
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
    assign
      p-vss-parameters = substitute('&1|&2',p-bar-code,p-zone)
    .
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
define buffer   buf_wth-ser    for ub.wth-ser.
define buffer   buf_wth-parts  for ub.wth-parts.
define buffer   buf_wth-gds    for wth-gds.
define variable v-beg-yy    as character    no-undo.
define variable v-beg-mm    as character    no-undo.
define variable v-beg-dd    as character    no-undo.
define variable v-end-yy    as character    no-undo.
define variable v-end-mm    as character    no-undo.
define variable v-end-dd    as character    no-undo.
define variable v-isser     as logical      no-undo.
Main-Block: do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  if p-bar-code > '' then.
  else return error "Не задан параметр штрих-код!".
  for each buf_wth-ser  where buf_wth-ser.stts = 0
  no-lock on error undo, return error:
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
    p-range = int(substring(p-bar-code,int(buf_wth-ser.range-rule),int(buf_wth-ser.range-smb) - int(buf_wth-ser.range-rule) + 1)) no-error.
    if p-range = ? then next.
    if buf_wth-ser.chk-bdt = 1  then do:
      v-beg-yy = substring(p-bar-code,int(buf_wth-ser.beg-yy),length(buf_wth-ser.beg-yy-smb)) no-error.
      v-beg-mm = substring(p-bar-code,int(buf_wth-ser.beg-mm),2) no-error.
      v-beg-dd = substring(p-bar-code,int(buf_wth-ser.beg-dd),2) no-error.
      p-FromDate = date(substitute("&1/&2/&3":U,v-beg-dd,v-beg-mm,v-beg-yy)) no-error.
      if p-FromDate = ? then next.
    end.
    if buf_wth-ser.chk-bdt = 2  then do:
      p-FromDate = buf_wth-ser.beg-dt.
    end.
    if buf_wth-ser.chk-edt = 1  then do:
      v-end-yy = substring(p-bar-code,int(buf_wth-ser.end-yy),length(buf_wth-ser.end-yy-smb)) no-error.
      v-end-mm = substring(p-bar-code,int(buf_wth-ser.end-mm),2) no-error.
      v-end-dd = substring(p-bar-code,int(buf_wth-ser.end-dd),2) no-error.
      p-FromDate = date(substitute("&1/&2/&3":U,v-end-dd,v-end-mm,v-end-yy)) no-error.
      if p-ToDate = ? then next.
    end.
    if buf_wth-ser.chk-edt = 2  then do:
      p-ToDate = buf_wth-ser.end-dt.
    end.
    assign p-ser-code = buf_wth-ser.ser-code
           p-db-num   = buf_wth-ser.db-num
           p-stts     = buf_wth-ser.stts
           p-wth-code = buf_wth-ser.wth-code
           p-par-code = buf_wth-ser.par-code
           v-isser = yes.
           leave.
  end.
  if not v-isser then return error substitute("Штрих-код &1 не удалось идентифицировать.",p-bar-code).
  for each buf_wth-gds no-lock
    where buf_wth-gds.wth-code = p-wth-code
      and buf_wth-gds.stts = 0
  :
    p-gds-code = p-gds-code + (if p-gds-code > '':U then ',':U else '':U) + string(buf_wth-gds.gds-code).
  end.
  find first buf_wth-parts no-lock
  where  buf_wth-parts.ser-code = p-ser-code
     and buf_wth-parts.db-num   = p-db-num
     and buf_wth-parts.wth-code = p-wth-code
     and buf_wth-parts.par-code = p-par-code
     and buf_wth-parts.fact-rangeFrom <= p-range
     and buf_wth-parts.fact-rangeTo >= p-range
     and (buf_wth-parts.out-code = 'free-zone':U or
          buf_wth-parts.out-code = 'cli-zone':U  or
          buf_wth-parts.out-code = 'put-zone':U  or
          buf_wth-parts.out-code = 'out-zone':U  )
  no-error.
  if available buf_wth-parts then do:
    assign
        p-zone = buf_wth-parts.out-code
    .
    if buf_wth-parts.beg-dt <> ?  then p-FromDate = buf_wth-parts.beg-dt.
    if buf_wth-parts.end-dt <> ?  then p-ToDate = buf_wth-parts.end-dt.
  end.
end.
