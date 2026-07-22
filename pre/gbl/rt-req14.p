block-level on error undo, throw.
define input  parameter parparentproc       as widget-handle no-undo .
define input  parameter p-directory-out     as character no-undo .
define input  parameter p-file-name         as character no-undo .
define input  parameter p-session-valid     as logical   no-undo .
define input  parameter p-error-message     as character no-undo .
define input  parameter p-user-login        as character no-undo .
define input  parameter p-obj-type          as character no-undo .
define input  parameter p-obj-code          as character no-undo .
define input  parameter p-host-code         as character no-undo .
define input  parameter p-doc-type          as character no-undo .
define input  parameter p-doc-code          as character no-undo .
define input  parameter p-bar-code          as character no-undo .
define input  parameter p-cli-qnty          as character no-undo .
define input  parameter p-unit-cli          as character no-undo .
define input  parameter p-cli-base-rate     as character no-undo .
define input  parameter p-line-number       as character no-undo .
define input  parameter p-price-cli         as character no-undo .
define input  parameter p-prod-artic        as character no-undo .
define input  parameter p-prod-artic-search as character no-undo .
define input  parameter p-price-docf        as character no-undo .
define input  parameter p-deadline-date     as character no-undo .
define input  parameter p-cop-check         as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: rt-req14.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/rt-req14.p $":U .
define variable vss-description as character no-undo init "Обрабока запроса радиотерминала 14. Приемка товара. Редактирование количеств по документу".
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure integerm :
  define input  parameter p-string      as character no-undo .
  define input  parameter p-allow-sign  as logical   no-undo .
  define input  parameter p-allow-comma as logical   no-undo .
  define output parameter p-value       as integer   no-undo .
  define output parameter p-data-valid  as logical   no-undo .
  define output parameter p-message     as character no-undo .
  define variable v-replace-string as character no-undo .
  do
  on error undo, return error return-value
  :
    if p-string = ?
    then do:
      assign
        p-value      = ?
        p-data-valid = false
        p-message    = "Ошибка задания входных параметров. Не задана строка для преобразования"
      .
      return .
    end.
    if p-string = ""
    then do:
      assign
        p-value      = ?
        p-data-valid = false
        p-message    = "Ошибка задания входных параметров. Задана пустая строка для преобразования"
      .
      return .
    end.
    assign
      p-value = integer(p-string) no-error
    .
    if error-status :error = true
    then do:
      assign
        p-value      = ?
        p-data-valid = false
        p-message    = substitute("Ошибка при преобразовании к целому числу строки '&1'"
                                 ,p-string
                                 )
      .
      return .
    end.
    if index(p-string, ' ':u) > 0
    then do:
      assign
        p-value      = ?
        p-data-valid = false
        p-message    = substitute("Ошибка при преобразовании к целому числу строки '&1'. "
                                 + "Строка содержит символы пробела"
                                 ,p-string
                                 )
      .
      return .
    end.
    assign
      v-replace-string = p-string
      v-replace-string = replace(v-replace-string, '0':u, '9':u)
      v-replace-string = replace(v-replace-string, '1':u, '9':u)
      v-replace-string = replace(v-replace-string, '2':u, '9':u)
      v-replace-string = replace(v-replace-string, '3':u, '9':u)
      v-replace-string = replace(v-replace-string, '4':u, '9':u)
      v-replace-string = replace(v-replace-string, '5':u, '9':u)
      v-replace-string = replace(v-replace-string, '6':u, '9':u)
      v-replace-string = replace(v-replace-string, '7':u, '9':u)
      v-replace-string = replace(v-replace-string, '8':u, '9':u)
    .
    if p-allow-sign = true
    then do:
      if index('+-':u, substring(v-replace-string, 1, 1)) > 0
      then do:
        assign
          v-replace-string = substring(v-replace-string, 2)
        .
      end.
    end.
    else do:
      if substring(v-replace-string, 1, 1) = '+':u
      then do:
        assign
          p-value      = ?
          p-data-valid = false
          p-message    = substitute("Ошибка при преобразовании к целому числу строки '&1'. "
                                  + "Задан параметр недопустимости знака челого числа. "
                                  + "Строка содержит символ плюс. "
                                  ,p-string
                                  )
        .
        return .
      end.
      if substring(v-replace-string, 1, 1) = '-':u
      then do:
        assign
          p-value      = ?
          p-data-valid = false
          p-message    = substitute("Ошибка при преобразовании к целому числу строки '&1'. "
                                  + "Задан параметр недопустимости знака челого числа. "
                                  + "Строка содержит символ минус. "
                                  ,p-string
                                  )
        .
        return .
      end.
    end.
    if p-allow-comma = true
    then do:
      assign
        v-replace-string = replace(v-replace-string, ',', '')
      .
    end.
    else do:
      if index(v-replace-string, ',') > 0
      then do:
        assign
          p-value      = ?
          p-data-valid = false
          p-message    = substitute("Ошибка при преобразовании к целому числу строки '&1'. "
                                  + "Задан параметр недопустимости знака разделителя тысяч."
                                  + "Строка содержит знак разделителя тысяч. "
                                  ,p-string
                                  )
        .
        return .
      end.
    end.
    if index(p-string, '.') > 0
    then do:
      assign
        p-value      = ?
        p-data-valid = false
        p-message    = substitute("Ошибка при преобразовании к целому числу строки '&1'. "
                                 + "Строка содержит знак десятичной точки"
                                 ,p-string
                                 )
      .
      return .
    end.
    if v-replace-string <> fill('9', length(v-replace-string))
    then do:
      assign
        p-value      = ?
        p-data-valid = false
        p-message    = substitute("Ошибка при преобразовании к целому числу строки '&1'. "
                                 + "Встречены символы, недопустимые для целого числа '&2'"
                                 ,p-string
                                 ,replace(v-replace-string, '9', '')
                                 )
      .
      return .
    end.
    assign
      p-data-valid = true
      p-message    = ""
    .
  end.
end procedure.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table lib-trn_ret-doc       no-undo like ub.trn-doc.
define temp-table lib-trn_ret-line      no-undo like ub.doc-line
  field cst-code                like ub.trn-doc.cst-code
  field part-code               like ub.parts.part-code
  .
define temp-table lib-trn_ret-line-attr no-undo like ub.doc-line-attr.
define temp-table lib-trn_ret-dtl       no-undo like ub.gds-dtl.
define temp-table lib-trn_ret-parts     no-undo like ub.parts.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function rtencode returns character
  ( p-init-string as character
  ) :
  define variable v-encode-string as character no-undo .
  if p-init-string = ?
  then do:
    assign
      v-encode-string = '?':u
    .
    return v-encode-string .
  end.
  if p-init-string = '?':u
  then do:
    assign
      v-encode-string = '~~077':u
    .
    return v-encode-string .
  end.
  assign
    v-encode-string = replace(p-init-string,   '~~':u,      '~~176':u)
    v-encode-string = replace(v-encode-string, ':':u,       '~~072':u)
    v-encode-string = replace(v-encode-string, chr(10), '~~015':u)
  .
  return v-encode-string .
end function .
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-waitfram-action01         as character   no-undo .
define variable v-waitfram-action02         as character   no-undo .
define variable v-waitfram-action03         as character   no-undo .
define variable mWaitFramTextBeg            as character   no-undo.
define variable mWaitFramTextEnd            as character   no-undo.
define variable mWaitFramView               as logical     no-undo.
define variable mWaitProcEvent              as logical     no-undo init yes.
define variable mWaitFramInterval           as integer     no-undo init 1 .
define variable mWaitFramStop               as logical     no-undo.
define variable mWaitFramStopUser           as logical     no-undo.
define variable mWaitFramStopTimeOut        as logical     no-undo.
define variable mWaitFramStartProc          as datetime-tz no-undo.
define variable mWaitFramTimeOut            as decimal     no-undo init ?.
define button B-WaitFramStop auto-end-key
     label "Стоп"
     size 10 by 1 tooltip "Остоновить процесс".
define button B-viewProcInfo
     label "Информация"
     size 15 by 1 tooltip "Информация о процесс".
define frame waitfram
  v-waitfram-action01 format "x(72)" no-label skip
  v-waitfram-action02 format "x(72)" no-label skip
  v-waitfram-action03 format "x(72)" no-label skip
  B-viewProcInfo
  B-WaitFramStop at row 4 col 30
  with view-as dialog-box side-labels three-d cancel-button B-WaitFramStop
  .
define new global shared variable mBatchMode as logical no-undo init ?.
define variable mFramBachModHandle as handle no-undo.
mFramBachModHandle = frame waitfram:handle.
define variable mFameOldVis as logical no-undo.
define variable mVisCUrentVin as logical no-undo.
if session:batch-mode
then
   mBatchMode = yes.
if mBatchMode = ? then do:
  mVisCUrentVin = current-window:visible.
  mFameOldVis = mFramBachModHandle:visible.
  mFramBachModHandle:visible  = yes.
  mBatchMode = mFramBachModHandle:visible ne yes.
  mFramBachModHandle:visible = mFameOldVis.
  current-window:visible = mVisCUrentVin.
end.
 if  log-manager:logfile-name ne ?
  then DO:
      log-manager:write-message("Logname=" + log-manager:logfile-name , "frameRepError").
      log-manager:write-message("Batch-mod=" + string(session:batch-mode) , "frameRepError").
      log-manager:write-message("visible-frame-mod=" + string(mFramBachModHandle:visible), "frameRepError").
  end.
on choose of B-WaitFramStop in frame waitfram
do:
  mWaitFramStop = yes.
  mWaitFramStopUser = yes.
end.
function waitfram-check-timeout returns logical():
   define variable vtime as int64 no-undo.
   if mWaitFramStopTimeOut
   then
      return yes.
   vtime = ( now - mWaitFramStartProc ) / 1000 .
   if     mWaitFramTimeOut ne ?
      and mWaitFramTimeOut ne 0
      and mWaitFramTimeOut lt vtime
   then do:
      mWaitFramStopTimeOut = yes.
   end.
   return mWaitFramStopTimeOut.
end.
procedure waitfram-hide :
  if not session:batch-mode
  then do
  on error undo, return error return-value
  :
    pause 0 before-hide .
    if not mBatchMode then
      hide frame waitfram .
  if     not mWaitFramView
     and mWaitProcEvent
  then
    process events .
  end.
end procedure.
procedure waitfram-show :
  define input  parameter p-message as character no-undo .
  define variable v-left-margin as integer   no-undo .
  if not session:batch-mode
  then do
  on error undo, return error return-value
  :
    if length(p-message) <= 70 then do:
      assign
        v-left-margin = integer((70 - length(p-message)) / 2)
      .
      assign
        v-left-margin = max(0, v-left-margin - (v-left-margin mod 5))
      .
      assign
        v-waitfram-action01 = " "
        v-waitfram-action02 = " "
                                 + fill(" ", v-left-margin)
                                 + p-message
        v-waitfram-action03 = " "
      .
    end.
    else do:
      define variable vRindex1 as integer no-undo.
      define variable vRindex2 as integer no-undo.
      vRindex1 = r-index(p-message," ",70).
      if vRindex1 = 0
      then
         vRindex1 = 70.
      if length(p-message)  <= vRindex1 + 70 then do:
        assign
          v-waitfram-action01 = " "
          v-waitfram-action02 = " " + substring(p-message,   1          , vRindex1)
          v-waitfram-action03 = " " + substring(p-message,  vRindex1 + 1, 70      )
        .
      end.
      else do:
        vRindex2 = r-index(p-message," ",vRindex1 + 70).
        if vRindex2 <= vRindex1
        then
           vRindex2 = vRindex1 + 70.
        assign
          v-waitfram-action01 = " " + substring(p-message,   1          , vRindex1)
          v-waitfram-action02 = " " + substring(p-message,  vRindex1 + 1, vRindex2 - vRindex1 )
          v-waitfram-action03 = " " + substring(p-message,  vRindex2 + 1, 70)
        .
      end.
    end.
    B-viewProcInfo:visible   in frame waitfram = no.
    B-viewProcInfo:sensitive in frame waitfram = no.
    B-WaitFramStop:visible   in frame waitfram = if not mBatchMode and mWaitFramView then yes else no .
    B-WaitFramStop:sensitive in frame waitfram = if not mBatchMode and mWaitFramView then yes else no .
    if  (   mWaitFramView
       or  mWaitProcEvent)
       and not mBatchMode
    then
       display
          v-waitfram-action01 skip
          v-waitfram-action02 skip
          v-waitfram-action03 skip
       with frame waitfram .
    if     mWaitFramView
       then do:
          if     mWaitFramInterval ne ?
             and not mBatchMode
          then
             wait-for go of frame waitfram pause mWaitFramInterval.
       end.
       else
          if     mWaitProcEvent
             and not mBatchMode
          then
             process events .
  end.
end procedure.
   procedure waitfram-show-this:
      define input  parameter iInterval as int64 no-undo.
      define variable vtime as int64 no-undo.
      vtime = ( now - mWaitFramStartProc  ) / 1000 .
      mWaitFramInterval = iInterval.
      run waitfram-show (substitute("&1&2 &3&4" ,
                                    mWaitFramTextBeg ,
                                    if vtime eq ? then "" else substitute (" Прошло: &1 сек" , string( vtime)),
                                    if mWaitFramTimeOut ne 0 and mWaitFramTimeOut ne ? then " из " + string(mWaitFramTimeOut) + " сек. " else "",
                                    mWaitFramTextEnd
                                   )
                        ).
   end.
   procedure WaitFramRunPause:
      define input  parameter iInterval as dec no-undo.
      define variable vStart  as datetime-tz no-undo.
      define variable vend    as datetime-tz no-undo.
      define variable vint as int64 no-undo.
      define variable vOk as logical no-undo.
      vStart = now.
      vend   = vStart.
      publish "WaitFramPause" (iInterval,output vOk).
      vend   =  now.
      vint = vend - vStart.
      vint = iInterval - vint / 1000.
      if     not mWaitFramStop
         and (   vint > 0
              or (    not vOk
                  and iInterval eq ?
                  )
              )
      then
         run waitfram-show-this (iInterval).
      vend   =  now.
      vint = vend - vStart.
      vint = iInterval - vint / 1000.
      if     not mWaitFramStop
         and vint > 0
      then do:
         run gbl/pause.p (vint * 1000).
      end.
      if iInterval ne ?
      then
         publish "WaitFramStop".
      waitfram-check-timeout().
   end.
   procedure WaitFramWaitFor:
      define input  parameter iInterval as dec no-undo.
      assign
         mWaitFramStartProc   = now
         mWaitFramStopUser    = no
         mWaitFramStopTimeOut = no
      .
      block-wait:
      do while not mWaitFramStop:
         run WaitFramRunPause (iInterval).
         if  waitfram-check-timeout()
         then do:
            leave block-wait.
         end.
      end.
      run waitfram-hide.
   end.
procedure waitfram-join :
  define input  parameter p-line-1  as character no-undo .
  define input  parameter p-line-2  as character no-undo .
  define input  parameter p-line-3  as character no-undo .
  define output parameter p-message as character no-undo .
  do
  on error undo, return error return-value
  :
    assign
      p-message = substring(p-line-1 + fill(' ', 70), 1, 70)
                + substring(p-line-2 + fill(' ', 70), 1, 70)
                + substring(p-line-3 + fill(' ', 70), 1, 70)
    .
  end.
end procedure.
function waitfram-join-function returns character
  (input p-line-1 as character
  ,input p-line-2 as character
  ,input p-line-3 as character
  ).
  define variable v-message as character no-undo .
  run waitfram-join in this-procedure
    (input  p-line-1
    ,input  p-line-2
    ,input  p-line-3
    ,output v-message
    ) .
  return v-message .
end function .
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure rt-cnvdc_decode :
  define input  parameter p-encoded-str as character no-undo .
  define output parameter p-decoded-str as character no-undo .
do
on error undo, return error return-value
:
  define variable v-decoded-str as character no-undo .
  assign
    v-decoded-str = replace(p-encoded-str,  'c':u, 'с':u )
    v-decoded-str = replace(v-decoded-str,  'm':u, 'м':u )
    p-decoded-str = v-decoded-str
  .
end.
end procedure.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure strtdate :
  define input  parameter p-str         as character no-undo .
  define output parameter p-value       as date      no-undo .
  define output parameter p-data-valid  as logical   no-undo .
  define output parameter p-message     as character no-undo .
do
on error undo, return error return-value
:
  define variable v-value       as date      no-undo .
  define variable v-i           as integer   no-undo .
  define variable v-num         as integer   no-undo .
  define variable v-delim       as character no-undo .
  define variable v-delim-list  as character no-undo .
  define variable v-day         as integer   no-undo .
  define variable v-month       as integer   no-undo .
  define variable v-year        as integer   no-undo .
  define variable v-day-str     as character no-undo .
  define variable v-month-str   as character no-undo .
  define variable v-year-str    as character no-undo .
  assign
    p-value       = ?
    p-data-valid  = false
  .
  if p-str = ?
  then do:
    assign
      p-message = substitute("Ошибка задания входных параметров. Не задана строка для преобразования. " )
    .
    return .
  end.
  if p-str = ""
  then do:
    assign
      p-message = substitute("Ошибка задания входных параметров. Задана пустая строка для преобразования. " )
    .
    return .
  end.
  if length(p-str)  > 10
  then do:
    assign
      p-message = substitute("Ошибка при преобразовании к дате. Неверная длина строки. " )
    .
    return .
  end.
  assign
    v-delim-list = '/,-,.':U
  .
  _delim:
  do v-i = 1 to num-entries( v-delim-list )
  :
    assign
      v-delim = entry( v-i , v-delim-list )
      v-num   = num-entries( p-str , v-delim )
    .
    if v-num <> 3
    then do:
      assign
        v-delim = ''
      .
    end.
    else do:
      leave _delim.
    end.
  end.
  if v-delim = ''
  then do:
    assign
      p-message = substitute( "Ошибка при преобразовании к дате. Неправильный разделитель, либо ошибочное количество разделителей. " )
    .
    return .
  end.
  assign
    v-day-str   = entry( 1, p-str , v-delim)
    v-month-str = entry( 2, p-str , v-delim)
    v-year-str  = entry( 3, p-str , v-delim)
  .
  if  length(v-day-str) > 2   or
      length(v-day-str) < 1   or
      length(v-month-str) > 2 or
      length(v-month-str) < 1 or
      (
        length(v-year-str) <> 2 and
        length(v-year-str) <> 4
      )
  then do:
    assign
      p-message = substitute("Ошибка при преобразовании к дате. Неправильное количество символов числа, месяца, либо года. " )
    .
    return .
  end.
  if length( v-year-str ) = 2
  then do:
    assign
      v-year-str = substring( string( year(today) ), 1 , 2 ) + v-year-str
    .
  end.
  assign
    v-day   = integer( v-day-str )
    v-month = integer( v-month-str)
    v-year  = integer( v-year-str)
  no-error .
  if error-status :error
  then do:
    assign
      p-message = substitute("Ошибка при преобразовании к дате. Неверный формат символов числа, месяца, либо года. " )
    .
    return .
  end.
  if v-day < 1  or
     v-day > 31 or
     v-month < 1 or
     v-month > 12 or
     v-year < 0   or
     v-year > 5000
  then do:
    assign
      p-message = substitute("Ошибка при преобразовании к дате. Неверный диапозон числа, месяца, года. " )
    .
    return .
  end.
  assign
    v-value = date( v-month, v-day, v-year )
  no-error .
  if error-status :error
  then do:
    assign
      p-message = substitute("Ошибка при преобразовании к дате. &1. " , error-status :get-message(1))
    .
    return .
  end.
  assign
    p-value       = v-value
    p-data-valid  = true
  .
end.
end procedure.
    define buffer   in-vatp-trn-doc  for ub.trn-doc .
    define buffer   in-vatp-parts    for ub.parts   .
    define buffer   in-vatp-doc      for ub.trn-doc .
    define buffer   in-vatp-goods    for ub.goods   .
    define buffer   in-vatp-sysconf  for ub.sysconf .
    define buffer   in-vatp_doc-attr for ub.doc-attr.
    define variable in-vatp-have-vat-slt       as   logical initial yes    no-undo.
    define variable vat-pc-loc                 like ub.doc-line.vat-pc     no-undo.
    define variable varinvprb                  as   character              no-undo.
    define variable slt-pc-loc                 like ub.doc-line.slt-pc     no-undo.
    define variable cli-base-rate              as   decimal                no-undo.
    define variable price-rubl-with-tax-loc    like ub.doc-line.price-rubl no-undo.
    define variable price-base-with-tax-loc    like ub.doc-line.price-base no-undo.
    define variable price-cli-with-tax-loc     like ub.doc-line.price-cli  no-undo.
    define variable price-rubl-without-tax-loc like ub.doc-line.price-rubl no-undo.
    define variable price-base-without-tax-loc like ub.doc-line.price-base no-undo.
    define variable price-cli-without-tax-loc  like ub.doc-line.price-base no-undo.
    define variable vat-base-loc               like ub.doc-line.price-base no-undo.
    define variable vat-rubl-loc               like ub.doc-line.price-rubl no-undo.
    define variable vat-cli-loc                like ub.doc-line.price-rubl no-undo.
    define variable slt-base-loc               like ub.doc-line.price-base no-undo.
    define variable slt-rubl-loc               like ub.doc-line.price-rubl no-undo.
    define variable slt-cli-loc                like ub.doc-line.price-rubl no-undo.
    define variable road-tax-base-loc          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-rubl-loc          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-cli-loc           like ub.doc-line.road-tax   no-undo.
    define variable transport-base-loc         like ub.doc-line.price-base no-undo.
    define variable transport-rubl-loc         like ub.doc-line.price-rubl no-undo.
    define variable transport-cli-loc          like ub.doc-line.price-rubl no-undo.
    define variable other-base-loc             like ub.doc-line.price-base no-undo.
    define variable other-rubl-loc             like ub.doc-line.price-rubl no-undo.
    define variable other-cli-loc              like ub.doc-line.price-rubl no-undo.
    define variable exch-rate-cli-loc          like ub.trn-doc.exch-rate   no-undo.
    define variable varinvatp-envd             as   character              no-undo.
    define variable varinvatp-type             as   character              no-undo.
define stream sout .
define new shared buffer t-doc for ub.trn-doc.
define variable v-status          as character no-undo .
define variable v-error-message   as character no-undo .
define variable v-unique-doc-code as character no-undo .
define variable v-b-code          as integer   no-undo .
define variable v-artic           as character no-undo .
define variable v-name            as character no-undo .
define variable v-prod-name       as character no-undo .
define variable v-unit-cli        as character no-undo .
define variable v-cli-base-rate   as character no-undo .
define variable v-price-cli       as character no-undo .
define variable v-vat-pc          as character no-undo .
define variable v-curr-abbr       as character no-undo .
define variable v-unit-base       as character no-undo .
do
on error undo, return error return-value
:
  if p-session-valid = true
  then do:
    run check-data in this-procedure
      (output  v-status
      ,output  v-error-message
      ) no-error .
    if error-status :error
    then do:
      undo, return error substitute("ошибка при вызове функции check-data. &1, &2"
                                  ,error-status :get-message(1)
                                  ,return-value
                                  ) .
    end.
  end.
  else do:
    assign
      v-status        = '1'
      v-error-message = p-error-message
    .
  end.
  define variable v-temp-file-name as character no-undo .
  assign
    v-temp-file-name = entry(1, p-file-name, '.':u) + '.tmp':u
  .
  output stream sout to value(p-directory-out + '/':u + v-temp-file-name) .
  put stream sout unformatted substitute('status:&1', rtencode(v-status))
                              + chr(10) .
  put stream sout unformatted substitute('message:&1',rtencode(v-error-message))
                              + chr(10) .
  output stream sout close .
  os-delete value(p-directory-out + '/':u + p-file-name) .
  os-rename value(p-directory-out + '/':u + v-temp-file-name)
            value(p-directory-out + '/':u + p-file-name)
            .
end.
procedure check-data :
  define output parameter p-status        as character no-undo .
  define output parameter p-error-message as character no-undo .
  define buffer buf_clients    for ub.clients .
  define buffer buf_sysconf    for ub.sysconf .
  define buffer buf_bar-code   for ub.bar-code .
  define buffer buf_goods      for ub.goods .
  define buffer buf_units      for ub.units .
  define buffer buf_doc-line   for ub.doc-line .
  define buffer buf_sys-ctrl   for ub.sys-ctrl .
  define buffer buf_user-login for ub.user-login .
  define buffer buf_ext-artic  for ub.ext-artic.
  define variable v-bar-code          like ub.bar-code.b-code  no-undo .
  main_block:
  do transaction
  on error undo main_block, return error return-value
  :
    find first buf_sys-ctrl no-lock .
    find first buf_user-login no-lock
      where buf_user-login.db-num     = buf_sys-ctrl.db-num
        and buf_user-login.status_    = 0
        and buf_user-login.user-login = p-user-login
      no-error .
    if not available buf_user-login
    then do:
      assign
        p-status        = '1'
        p-error-message = substitute("Неизвестный пользователь &1"
                                    ,p-user-login
                                    )
      .
      return .
    end.
    define variable v-obj-code      as integer   no-undo .
    define variable v-data-valid    as logical   no-undo .
    define variable v-error-message as character no-undo .
    if p-obj-code = ""
    then do:
      assign
        p-status        = '1'
        p-error-message = "Не задан код объекта"
      .
      return .
    end.
    run integerm in this-procedure
      (input  p-obj-code
      ,input  false
      ,input  false
      ,output v-obj-code
      ,output v-data-valid
      ,output v-error-message
      ) .
    if v-data-valid <> true
    then do:
      assign
        p-status        = '1'
        p-error-message = substitute("Ошибка преобразования кода объекта &1. &2"
                                    ,p-obj-code
                                    ,v-error-message
                                    )
      .
      return .
    end.
    find first buf_clients no-lock
      where buf_clients.obj-type = p-obj-type
        and buf_clients.obj-code = v-obj-code
      no-error .
    if not available buf_clients
    then do:
      assign
        p-status        = '1'
        p-error-message = substitute("Не найден объект &1 &2"
                                    ,p-obj-type
                                    ,v-obj-code
                                    )
      .
      return .
    end.
    if  p-obj-type <> 'маг':U
    and p-obj-type <> 'скл':U
    then do:
      assign
        p-status        = '1'
        p-error-message = substitute("Неправильный тип объекта &1 &2"
                                    ,p-obj-type
                                    ,v-obj-code
                                    )
      .
      return .
    end.
    define variable v-host-code as integer   no-undo .
    run integerm in this-procedure
      (input  p-host-code
      ,input  false
      ,input  false
      ,output v-host-code
      ,output v-data-valid
      ,output v-error-message
      ) .
    if v-data-valid <> true
    then do:
      assign
        p-status        = '1'
        p-error-message = substitute("Ошибка преобразования кода фирмы &1. &2"
                                    ,p-host-code
                                    ,v-error-message
                                    )
      .
      return .
    end.
    define variable v-obj-host-code as integer   no-undo .
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  buf_clients.obj-type
  ,input  buf_clients.obj-code
  ,output v-obj-host-code
  )  .
    if v-host-code <> v-obj-host-code
    then do:
      assign
        p-status        = '1':u
        p-error-message = substitute("Заданный код фирмы &1 отличается от кода фирмы &2 объекта &3 &4."
                                    ,p-host-code
                                    ,v-obj-host-code
                                    ,buf_clients.obj-type
                                    ,buf_clients.obj-code
                                    )
      .
      return .
    end.
    find first buf_sysconf no-lock
      where buf_sysconf.host-code = v-host-code
      no-error .
    if not available buf_sysconf
    then do:
      assign
        p-status        = '1'
        p-error-message = substitute("Не найдена фирма &1"
                                    ,v-host-code
                                    )
      .
      return .
    end.
    define variable v-prod-artic-search as logical   no-undo .
    if( lookup ( p-prod-artic-search , '0,1':U ) = 0 )
    then do:
      assign
        p-status        = '1'
        p-error-message = substitute("Недопустимое значение поля prod_artic_search: &1"
                                    ,p-prod-artic-search
                                    )
      .
      return .
    end.
    else do:
      assign
        v-prod-artic-search = if ( p-prod-artic-search = '0') then no else yes
      .
    end.
    define variable v-cop-check as logical   no-undo .
    if( lookup ( p-cop-check , '0,1':U ) = 0 )
    then do:
      assign
        p-status        = '1'
        p-error-message = substitute("Недопустимое значение поля cop_check: &1"
                                    ,p-cop-check
                                    )
      .
      return .
    end.
    else do:
      assign
        v-cop-check = if ( p-cop-check = '0') then no else yes
      .
    end.
    define variable v-price-docf as decimal   no-undo .
    if p-price-docf = ""
    then do:
      assign
        p-status        = '1'
        p-error-message = "Не задана фактическая цена"
      .
      return .
    end.
    define variable v-last-date as date      no-undo .
    if p-deadline-date <> "" and p-deadline-date <> ?
    then do:
      run strtdate in this-procedure ( input  p-deadline-date
                                     , output v-last-date
                                     , output v-data-valid
                                     , output v-error-message
                                     ).
      if v-data-valid <> true then do:
        assign
          p-status        = '1'
          p-error-message = substitute("Ошибка преобразования срока годности &1. &2"
                                      ,p-deadline-date
                                      ,v-error-message
                                      )
        .
        return .
      end.
    end.
    define variable v-search-doc-code as character no-undo .
    run rt-cnvdc_decode in this-procedure ( input   p-doc-code
                                          , output  v-search-doc-code
                                          ) .
    case p-doc-type
    :
      when 'ПТ':u
      then do:
        assign
          p-status        = '1'
          p-error-message = "Нельзя редактировать количества по документу для поставки"
        .
        return .
      end.
      when 'ПН':u
      then do:
        find first t-doc exclusive-lock
          where t-doc.doc-code = v-search-doc-code
          no-error .
        if not available t-doc
        then do:
          assign
            p-status        = '1'
            p-error-message = substitute("Не найден документ &1"
                                        ,v-search-doc-code
                                        )
          .
          return .
        end.
        if t-doc.obj-type <> p-obj-type
        or t-doc.obj-code <> v-obj-code
        then do:
          assign
            p-status        = '1'
            p-error-message = substitute("Документ &1 принадлежит объекту &2 &3"
                                        ,v-search-doc-code
                                        ,p-obj-type
                                        ,v-obj-code
                                        )
          .
          return .
        end.
        if t-doc.ext-doc-type <> 'ie':U
        then do:
          assign
            p-status        = '1'
            p-error-message = substitute("Документа &1 не является документом внешнего прихода"
                                        ,v-search-doc-code
                                        )
          .
          return .
        end.
        if t-doc.status_ <> 'накл':U
        then do:
          assign
            p-status        = '1'
            p-error-message = substitute("Статус документа &1 отличен от &2. Невозможно редактировать количество"
                                        ,v-search-doc-code
                                        ,'накл':U
                                        )
          .
          return .
        end.
        define variable v-object-available as logical   no-undo .
define variable vss-include-info7 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run usobjava in g#library2
  (input  buf_sys-ctrl.db-num
  ,input  0
  ,input  buf_user-login.user-id
  ,input  buf_clients.obj-type
  ,input  buf_clients.obj-code
  ,output v-object-available
  )  .
        if v-object-available <> true
        then do:
          assign
            p-status        = '1':u
            p-error-message = substitute("Пользователю не доступен объект &1 &2"
                                        ,buf_clients.obj-type
                                        ,buf_clients.obj-code
                                        )
          .
          return .
        end.
        define variable v-valid-act   as logical   no-undo .
define variable vss-include-info8 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  buf_sys-ctrl.db-num
    ,input  buf_user-login.user-id
    ,input  0
    ,input  'actn_rt-edit-doc_add-def':U
    ,input  'object':U
    ,input  v-host-code
    ,input  buf_clients.obj-type
    ,input  buf_clients.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output v-valid-act
    )  .
end.
        if v-valid-act <> true
        then do:
          assign
            p-status        = '1':u
            p-error-message = return-value
          .
          return .
        end.
        assign
          v-unique-doc-code = p-doc-type + '|':u + t-doc.doc-code
        .
        run gbl/rt-doced.p
          (input  v-unique-doc-code
          ,input  buf_user-login.user-id
          ,input  '':u
          ,input  'check':u
          ,input "":U
          ,output p-status
          ,output p-error-message
          ) .
        if p-status <> '2':u
        then do:
          if p-status = '3':u
          then do:
            assign
              p-status = '1':u
            .
            return .
          end.
          assign
            p-status = '1':u
            p-error-message = substitute("Неизвестный статус &1 складского документа &2"
                                        ,p-status
                                        ,t-doc.doc-code
                                        )
          .
          return .
        end.
        if v-prod-artic-search = true
        then do:
          find first buf_ext-artic no-lock
            where buf_ext-artic.cli-type  = t-doc.cli-type
              and buf_ext-artic.cli-code  = t-doc.cli-code
              and buf_ext-artic.ext-artic = p-bar-code
              and buf_ext-artic.status_   = 'тек':U
          no-error .
          if available buf_ext-artic
          then do:
              find first buf_goods no-lock
                where buf_goods.gds-code = buf_ext-artic.gds-code
              no-error .
              if available buf_goods
              then do:
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  buf_goods.gds-code
  ,input  ?
  ,output v-bar-code
  ) no-error .
                if error-status :error
                then do:
                assign
                  p-status = '1':u
                  p-error-message = substitute( "&1. &2"
                                              , return-value
                                              , error-status :get-message(1)
                                              )
                .
                return .
                end.
                assign
                  p-bar-code = string( v-bar-code )
                .
              end.
          end.
        end.
        run gbl/rt-bcdoc.p
          (input  parparentproc
          ,input  v-unique-doc-code
          ,input  p-obj-type
          ,input  v-obj-code
          ,input  v-host-code
          ,input  p-bar-code
          ,output p-status
          ,output p-error-message
          ,output v-b-code
          ,output v-artic
          ,output v-name
          ,output v-prod-name
          ,output v-unit-cli
          ,output v-cli-base-rate
          ,output v-price-cli
          ,output v-vat-pc
          ,output v-curr-abbr
          ,output v-unit-base
          ,output v-price-docf
          ) .
        if p-status <> '0':u
        then do:
          assign
            p-status = '1':u
          .
          return .
        end.
        find first buf_bar-code no-lock
          where buf_bar-code.b-code = v-b-code
          no-error .
        if not available buf_bar-code
        then do:
          assign
            p-status = '1':u
            p-error-message = substitute("Не найдена запись штрих-код &1"
                                        ,v-b-code
                                        )
          .
          return .
        end.
        find first buf_goods no-lock
          where buf_goods.gds-code = buf_bar-code.gds-code
          no-error .
        if not available buf_goods
        then do:
          assign
            p-status = '1':u
            p-error-message = substitute("Не найдена запись товар &1"
                                        ,v-b-code
                                        )
          .
          return .
        end.
        define variable v-goods-serial as logical   no-undo .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdscdat in g#library
  (input  buf_goods.gds-code
  ,input  'serial=request':u
  ,output v-goods-serial
  ) no-error .
        if error-status :error
        then do:
          assign
            p-status = '1':u
            p-error-message = substitute("Ошибка при определении атрибута товара 'serial=request':u. &1 &2"
                                        ,error-status :get-message(1)
                                        ,return-value
                                        )
          .
          return .
        end.
        if v-goods-serial = true
        then do:
          assign
            p-status = '1':u
            p-error-message = substitute("Серийный товар нельзя приходовать через радиотерминал. Товар &1 &2 &3"
                                        ,buf_goods.artic
                                        ,buf_goods.prod-type
                                        ,buf_goods.prod-code
                                        )
          .
          return .
        end.
        define variable v-node-code as integer   no-undo .
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsrtnod in g#library
  (input  buf_goods.gds-code
  ,output v-node-code
  )  .
        define variable v-request-cli-qnty      as decimal   no-undo .
        define variable v-request-cli-base-rate as decimal   no-undo .
        define variable v-request-line-number   as integer   no-undo .
        define variable v-request-price-cli     as decimal   no-undo .
        if p-cli-qnty = ''
        then do:
          assign
            p-status        = '1':u
            p-error-message = "Не задано количество"
          .
          return .
        end.
        assign
          v-request-cli-qnty = decimal(p-cli-qnty) no-error
        .
        if error-status :error
        then do:
          assign
            p-status        = '1':u
            p-error-message = substitute("Ошибка в задании количества &1"
                                        ,p-cli-qnty
                                        )
          .
          return .
        end.
        if v-request-cli-qnty = ?
        then do:
          assign
            p-status        = '1':u
            p-error-message = substitute("Не задано количество &1"
                                        ,p-cli-qnty
                                        )
          .
          return .
        end.
        if v-request-cli-qnty <= 0
        then do:
          assign
            p-status        = '1':u
            p-error-message = substitute("Количество должно быть положительным &1"
                                        ,p-cli-qnty
                                        )
          .
          return .
        end.
        if p-cli-base-rate = ''
        then do:
          assign
            p-status        = '1':u
            p-error-message = "Не задан коэффициент"
          .
          return .
        end.
        assign
          v-request-cli-base-rate = decimal(p-cli-base-rate) no-error
        .
        if error-status :error
        then do:
          assign
            p-status        = '1':u
            p-error-message = substitute("Ошибка в задании коэффициента &1"
                                        ,p-cli-base-rate
                                        )
          .
          return .
        end.
        if v-request-cli-base-rate = ?
        then do:
          assign
            p-status        = '1':u
            p-error-message = substitute("Не задан коэффициент &1"
                                        ,p-cli-base-rate
                                        )
          .
          return .
        end.
        if v-request-cli-base-rate <= 0
        then do:
          assign
            p-status        = '1':u
            p-error-message = substitute("Коэффициент должен быть положительным &1"
                                        ,p-cli-base-rate
                                        )
          .
          return .
        end.
        if p-unit-cli = ''
        then do:
          assign
            p-status        = '1':u
            p-error-message = "Не задана единица измерения поставщка"
          .
          return .
        end.
        find first buf_units no-lock
          where buf_units.unit-name = p-unit-cli
          no-error .
        if not available buf_units
        then do:
          define variable v-okei as integer   no-undo .
          run integerm in this-procedure
            (input  p-unit-cli
            ,input  false
            ,input  false
            ,output v-okei
            ,output v-data-valid
            ,output v-error-message
            ) .
          if v-data-valid <> true
          then do:
            assign
              p-status        = '1'
              p-error-message = substitute("Не найдена единица измерения &1"
                                          ,p-unit-cli
                                          )
            .
            return .
          end.
          find first buf_units no-lock
            where buf_units.OKEI = v-okei
            no-error .
        end.
        if not available buf_units
        then do:
          assign
            p-status        = '1':u
            p-error-message = substitute("Не найдена единица измерения поставщка &1. Для задания единицы измерения поставщика можно использовать код ОКЕИ"
                                        ,p-unit-cli
                                        )
          .
          return .
        end.
        if  buf_units.unit-name     = v-unit-base
        and v-request-cli-base-rate <> 1
        then do:
          assign
            p-status        = '1':u
            p-error-message = substitute("При указании в качестве единицы измерения поставщика базовой единицы измерения &1 коэффициент не может отличаться от 1."
                                        ,p-unit-cli
                                        )
          .
          return .
        end.
        if lookup('шту':U, buf_units.type) > 0
        or lookup('сер':U, buf_units.type) > 0
        then do:
          if v-request-cli-qnty <> truncate(v-request-cli-qnty, 0)
          then do:
            assign
              p-status        = '1'
              p-error-message = substitute('Для штучного и серийного товаров резервируемое количество должно быть целым.&1Кол-во: &2'
                                          ,chr(10)
                                          ,v-request-cli-qnty
                                          )
            .
            return .
          end.
        end.
        assign
          v-request-line-number = 0
        .
        if p-line-number <> ''
        then do:
          run integerm in this-procedure
            (input  p-line-number
            ,input  false
            ,input  false
            ,output v-request-line-number
            ,output v-data-valid
            ,output v-error-message
            ) .
          if v-data-valid <> true
          then do:
            assign
              p-status        = '1'
              p-error-message = substitute("Ошибка преобразования номера строки &1. &2"
                                          ,p-line-number
                                          ,v-error-message
                                          )
            .
            return .
          end.
        end.
        if p-price-cli = ''
        then do:
          assign
            v-request-price-cli = 0.01
          .
        end.
        else do:
          assign
            v-request-price-cli     = decimal(p-price-cli) no-error
          .
          if error-status :error
          then do:
            assign
              p-status        = '1':u
              p-error-message = substitute("Ошибка при задании цены &1"
                                          ,p-price-cli
                                          )
            .
            return .
          end.
        end.
        if v-request-price-cli < 0
        then do:
          assign
            p-status        = '1':u
            p-error-message = substitute("Цена не может быть отрицательной &1"
                                        ,p-price-cli
                                        )
          .
          return .
        end.
        if v-request-price-cli = 0
        then do:
          assign
            v-request-price-cli = 0.01
          .
        end.
        find first buf_doc-line exclusive-lock
          where buf_doc-line.doc-code  = t-doc.doc-code
            and buf_doc-line.artic     = buf_goods.artic
            and buf_doc-line.prod-type = buf_goods.prod-type
            and buf_doc-line.prod-code = buf_goods.prod-code
          no-error .
        if available buf_doc-line
        then do:
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_clcintrn in g#lib-trn
  (
   input parparentproc
  ,input ?
  ,input buf_doc-line.doc-code
  ,input buf_doc-line.artic
  ,input buf_doc-line.prod-type
  ,input buf_doc-line.prod-code
  ,input buf_doc-line.price-cli
  ,input buf_doc-line.price-rubl
  ,input buf_doc-line.price-base
  ,input buf_doc-line.cli-qnty
  ,input buf_doc-line.cli-base-rate
  ,input buf_doc-line.fact-qnty
  ,input buf_doc-line.doc-qnty
  ,input buf_doc-line.vat-pc
  ,input buf_doc-line.slt-pc
  ,input buf_doc-line.road-tax
  ,input buf_doc-line.excise
  ,input buf_doc-line.transport-rubl
  ,input buf_doc-line.other-rubl
  ,input 'delete':u
  ,input ''
  ) no-error.
          if error-status :error
          then do:
            undo main_block, return error return-value.
          end.
          delete buf_doc-line .
        end.
        create lib-trn_ret-doc .
        buffer-copy t-doc to lib-trn_ret-doc .
        create lib-trn_ret-line .
        assign
          lib-trn_ret-line.doc-code       = lib-trn_ret-doc.doc-code
          lib-trn_ret-line.artic          = buf_goods.artic
          lib-trn_ret-line.prod-type      = buf_goods.prod-type
          lib-trn_ret-line.prod-code      = buf_goods.prod-code
          lib-trn_ret-line.cli-qnty       = v-request-cli-qnty
          lib-trn_ret-line.unit-cli       = buf_units.unit-name
          lib-trn_ret-line.cli-base-rate  = v-request-cli-base-rate
          lib-trn_ret-line.price-cli      = v-request-price-cli
          lib-trn_ret-line.vat-pc         = decimal(v-vat-pc)
          lib-trn_ret-line.slt-pc         = 0
          lib-trn_ret-line.price-rubl     = v-request-price-cli / v-request-cli-base-rate
          lib-trn_ret-line.road-tax       = 0
          lib-trn_ret-line.transport-rubl = 0
          lib-trn_ret-line.other-rubl     = 0
          lib-trn_ret-line.doc-qnty       = v-request-cli-qnty * v-request-cli-base-rate
          lib-trn_ret-line.fact-qnty      = v-request-cli-qnty * v-request-cli-base-rate
        .
        create lib-trn_ret-dtl .
        assign
          lib-trn_ret-dtl.doc-code    = lib-trn_ret-doc.doc-code
          lib-trn_ret-dtl.artic       = buf_goods.artic
          lib-trn_ret-dtl.prod-type   = buf_goods.prod-type
          lib-trn_ret-dtl.prod-code   = buf_goods.prod-code
          lib-trn_ret-dtl.prt-code    = v-node-code
          lib-trn_ret-dtl.price-rubl  = v-request-price-cli / v-request-cli-base-rate
          lib-trn_ret-dtl.discnt-rubl = 0
          lib-trn_ret-dtl.doc-qnty    = v-request-cli-qnty * v-request-cli-base-rate
          lib-trn_ret-dtl.fact-qnty   = v-request-cli-qnty * v-request-cli-base-rate
        .
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn4) <> true) then do:   run str/lib-trn4.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn4) <> true) then do:     message       "Error starting lib-trn4.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn4 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn4 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn4 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn4_copy-in in g#lib-trn4
( input ?
 ,input recid(t-doc)
 ,input table lib-trn_ret-doc
 ,input table lib-trn_ret-line
 ,input table lib-trn_ret-line-attr
 ,input table lib-trn_ret-dtl
 ,input table lib-trn_ret-parts
 ,input false
 ,input false
 ,input true
 ,input false
 ,input this-procedure
  ) no-error .
        if error-status :error
        then do:
          assign
            p-status        = '1':u
            p-error-message = substitute('Ошибка при создании строки &1 &2':u
                                        ,error-status :get-message(1)
                                        ,return-value
                                        )
          .
          undo main_block, return .
        end.
        find first buf_doc-line exclusive-lock
          where buf_doc-line.doc-code  = t-doc.doc-code
            and buf_doc-line.artic     = buf_goods.artic
            and buf_doc-line.prod-type = buf_goods.prod-type
            and buf_doc-line.prod-code = buf_goods.prod-code
          no-error .
        if not available buf_doc-line
        then do:
          assign
            p-status        = '1':u
            p-error-message = substitute('Неизвестная ошибка при создании строки документа &1 &2 &3 &4':u
                                        ,v-unique-doc-code
                                        ,buf_goods.artic
                                        ,buf_goods.prod-type
                                        ,buf_goods.prod-code
                                        )
          .
          undo main_block, return .
        end.
        if v-request-line-number <> 0
        then do:
          assign
            buf_doc-line.line-num = v-request-line-number
          .
        end.
        define buffer buf_parts for ub.parts .
        define variable varprice-check as decimal no-undo.
        define variable v-price-correct as logical   no-undo .
        define variable v-message       as character no-undo .
        if v-last-date <> ?
        then do:
          for each buf_parts exclusive-lock
            where buf_parts.obj-type  = buf_doc-line.obj-type
              and buf_parts.obj-code  = buf_doc-line.obj-code
              and buf_parts.artic     = buf_doc-line.artic
              and buf_parts.prod-type = buf_doc-line.prod-type
              and buf_parts.prod-code = buf_doc-line.prod-code
              and buf_parts.in-code   = buf_doc-line.doc-code
          :
            assign
              buf_parts.last-date = v-last-date
            .
          end.
        end.
        assign
          p-status        = '0':u
          p-error-message = '':u
        .
        return .
      end.
      otherwise do:
        assign
          p-status        = '1':u
          p-error-message = substitute("Неизвестный тип документа &1"
                                      ,p-doc-type
                                      )
        .
        undo main_block, return .
      end.
    end case .
    assign
      p-status        = '1'
      p-error-message = "Неизвестная ошибка"
    .
    undo main_block, return .
  end.
end procedure.
