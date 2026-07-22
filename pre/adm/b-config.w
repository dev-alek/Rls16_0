define input parameter parparentproc as widget-handle no-undo .
def var vss-revision    as character no-undo init "$Revision$":U .
def var vss-author      as character no-undo init "$Author$":U.
def var vss-date        as character no-undo init "$Date$":U.
def var vss-workfile    as character no-undo init "$Workfile$":U.
def var vss-archive     as character no-undo init "$Archive$":U.
def var vss-description as character no-undo init "Настройки и конфигурация системы".
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
procedure proc-alt-shift-f2:
  if not ibs.th.gbl.gbl-var:rcode
then
  run gbl\inidebug.p .
end.
procedure proc-alt-shift-f3:
  run gbl/prvssinf.p
    ( input this-procedure
    ) .
end.
define variable v-inform-launched as logical no-undo initial false .
procedure proc-alt-shift-f4:
  define variable v-action as character no-undo .
  if v-inform-launched = false then do:
    assign
      v-inform-launched = true
    .
    run gbl/d-inform.w
      (  input self
      ,  input this-procedure
      , output v-action
      ) no-error .
    run gbl/infrmact.p (input self, input this-procedure, input v-action) no-error .
    assign
      v-inform-launched = false
    .
  end.
end.
procedure proc-alt-f1:
  run gbl/corrhelp.p
    (input this-procedure
    ) .
end .
on alt-shift-f2 anywhere do:
  run proc-alt-shift-f2.
end.
on alt-shift-f3 anywhere do:
  run proc-alt-shift-f3 in this-procedure .
end.
on alt-shift-f4 anywhere do:
  run proc-alt-shift-f4 in this-procedure.
end.
on alt-f1 anywhere do:
  run proc-alt-f1 in this-procedure .
end.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define new shared temp-table cnf no-undo
    field param-code    as character   format "x(8)"        column-label "Код"                               field param-type    as character                        column-label "Тип"                               field param-value   as character   format "x(250)"      column-label "Значение"                          field param-encoded as character                        column-label "Кодированное значение"             field host-code     as integer                          column-label "Фирма"                             field obj-type      as character                        column-label "Тип объекта"                       field obj-code      as integer     format ">>>>>>"      column-label "Код объекта"                       field conf-type     as character                        column-label "Кодировка"                         field beg-date      as date                             column-label "Начало действия параметра"         field end-date      as date                             column-label "Окончание действия параметра"      field db-num        as integer     format ">>>>>"       column-label "БД"                                field stts          as integer                          column-label "Статус"
    field db-key        as character   format "x(12)"       column-label "Ключ БД"
    field param-PS      as character   format "x(40)"       column-label "PS"
    field param-name    as character   format "x(30)"       column-label "Название"
    field is-changed    as logical initial false            column-label "Изменен"
    field NotUsed       as logical initial False            column-label "Выключен"
    field ErrorExist    as integer initial 0  format ">>"   column-label "Уровень ошибки"
    index pi
      is unique
      param-code
      host-code
      obj-type
      obj-code
      beg-date
      end-date
      db-num
    index db-num
      db-num
    index db-key
      db-key
    index par-name
      is word-index
      param-name
    index par-value
      is word-index
      param-value
 .
def new shared temp-table log-table no-undo
    field stroka       as character format "x(256)".
def new shared variable err-level as integer no-undo.
def var vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared temp-table cnf-struct no-undo
  field param-code    as character
  field param-type    as character
  field data-type     as character
  field param-name    as character
  field attach-type   as character
  field list-value    as character
  field default-value as character
  field PS            as character
  field param-group   as character
  field user-resp     as character
  index by-code is unique param-code
.
define temp-table t_cnf-struct no-undo like cnf-struct .
define stream TxtStream.
define stream temp-stream .
function coding-user-resp returns character
  ( input p-param-code as character
   ,input p-user-resp  as character
  )
:
  return encode( p-param-code + p-user-resp ) .
end function.
function decoding-user-resp returns character
  ( input p-param-code as character
   ,input p-code-usr   as character
  )
:
  define variable v-ind         as integer   no-undo .
  define variable v-user-list   as character no-undo .
  define variable v-num-entries as integer   no-undo .
  define variable v-user-resp   as character no-undo .
  assign
    v-user-list   = "Бахтадзе,Булгаков,Белоусов,Гюнтнер,Исаков,Перваков,Суслов,Уханов,Чернова,Кочетков,Степанов,Хныкин,Гридчина,Шальнев,Сливенко,Харитонов,Кирюхин,Морозов"
    v-num-entries = num-entries( v-user-list )
    v-user-resp   = "":U
  .
  block_do:
  do v-ind = 1 to v-num-entries :
    if encode( p-param-code + entry( v-ind, v-user-list ) ) = p-code-usr then do:
      assign
        v-user-resp = entry( v-ind, v-user-list )
      .
      leave block_do.
    end.
  end.
  if v-user-resp = "":U then do:
    message
      vss-include-info1 skip
      substitute( "Невозможно распознать ответственного за параметр <&1>!",  p-param-code) skip
      substitute( "Возможно его нет в списке." ) skip
      view-as alert-box error
    .
    return "unknown":U.
  end.
  else do:
    return v-user-resp .
  end.
end function.
function sum-enc returns character (str as character, num-rev as integer).
   define variable rev_incl_s as character init "" no-undo .
   define variable rev_incl_i as integer no-undo .
   define variable rev_incl_l as integer no-undo .
   rev_incl_l = length(str).
   do rev_incl_i = 1 to rev_incl_l:
      if rev_incl_i <= num-rev
        or rev_incl_l - rev_incl_i < num-rev
      then do:
        assign
          rev_incl_s = rev_incl_s + substr(str, rev_incl_l - rev_incl_i + 1, 1)
        .
      end.
      else do:
        assign
          rev_incl_s = rev_incl_s + substr(str, rev_incl_i, 1)
        .
      end.
   end.
   return rev_incl_s.
end.
procedure check-cfg :
  define input-output parameter p-param-code    as character no-undo .
  define input-output parameter p-param-type    as character no-undo .
  define input-output parameter p-data-type     as character no-undo .
  define input-output parameter p-param-name    as character no-undo .
  define input-output parameter p-attach-type   as character no-undo .
  define input-output parameter p-list-value    as character no-undo .
  define input-output parameter p-default-value as character no-undo .
  define input-output parameter p-param-PS      as character no-undo .
  define input-output parameter p-param-group   as character no-undo .
  define input-output parameter p-user-resp     as character no-undo .
  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-include-info1, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-include-info1 )
  on endkey undo, return error substitute( "&1. endkey", vss-include-info1 )
  :
    define variable v-ind as character no-undo .
    assign
      p-param-code    = trim( p-param-code )
      p-param-type    = trim( p-param-type )
      p-data-type     = trim( p-data-type )
      p-param-name    = trim( p-param-name )
      p-attach-type   = trim( p-attach-type )
      p-list-value    = trim( p-list-value )
      p-default-value = trim( p-default-value )
      p-param-PS      = trim( p-param-PS )
      p-param-group   = trim( p-param-group )
      p-user-resp     = trim( p-user-resp )
    .
    if p-param-code = "":U then do:
      undo, return error substitute( "&1. Не задана метка параметра", vss-include-info1 ).
    end.
    if length( p-param-code ) > 8 then do:
      undo, return error substitute( "&1. Длина метки параметра не может превышать 8 символов (&2)", vss-include-info1, p-param-code ).
    end.
    if lookup( p-param-type, ',о,к,п':U ) = 0 then do:
      undo, return error substitute( '&1. Значение типа настройки "&2" не допустимо (&3)', vss-include-info1, p-param-type, p-param-code ).
    end.
    if lookup( p-param-type, 'к,п':U ) <> 0
      and lookup( p-attach-type, 'Нет':U ) = 0
    then do:
      undo, return error substitute( '&1. Для параметров с типом "&2" допустимы только привязки "&3" (&4)', vss-include-info1, 'к,п':U, 'Нет':U, p-param-code ).
    end.
    if p-param-name = "":U then do:
      undo, return error substitute( "&1. Не задано название параметра &2", vss-include-info1, p-param-code  ).
    end.
    if lookup( entry( 1, p-data-type ), "logical,integer,decimal,date,character":U ) = 0
      or num-entries( p-data-type ) > 2
      or ( num-entries( p-data-type ) = 2
           and entry( 2, p-data-type ) <> "list":U
         )
    then do:
      undo, return error substitute( "&1. Значение типа параметра &2 не допустимо (&3)", vss-include-info1, p-data-type, p-param-code ).
    end.
    if lookup( p-attach-type, 'Нет,Фирма,Объект':U ) = 0
    then do:
      undo, return error substitute( '&1. Значение привязки "&2" не допустимо (&3)', vss-include-info1, p-attach-type, p-param-code ).
    end.
  end.
  return.
end procedure.
procedure fill-cnf-struct :
  define input parameter p-file-name as character no-undo .
  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :
    define variable v-file-name as character no-undo .
    define variable v-counter as integer   no-undo .
    define variable v-temp-fname       as character           no-undo.
    define variable v-last-key         as integer             no-undo .
    define variable v-new-line         as integer             no-undo .
    define variable v-read-chksum      as logical             no-undo .
    define variable v-md5-signature-av as character           no-undo .
    define variable v-md5-signature    as character           no-undo .
    define frame inf-cfg
      v-counter label "Просмотрено"
      with view-as dialog-box side-labels 1 columns three-d title ""
    .
    assign
      v-file-name = search( p-file-name )
    .
    if v-file-name = ""
      or v-file-name = ?
    then do:
      return error substitute( "&1. Не задан файл схемы конфигурации!", vss-include-info1 ).
    end.
    assign
      v-last-key         = 0
      v-read-chksum      = false
      v-md5-signature-av = "":U
      file-info:file-name = ".":U
      v-temp-fname = substitute( "&1\&2-&3-&4.tmp", file-info:full-pathname, time, etime, random( 1111111 , 9999999 ) )
    .
    input stream TxtStream from value( v-file-name ).
    output stream temp-stream to value(v-temp-fname) .
    block_read:
    repeat while v-last-key <> -2
    on error undo, return error
    :
      readkey stream TxtStream pause 0.
      assign
        v-last-key = lastkey
      .
      if chr( v-last-key ) = chr(1) then do:
        assign
          v-read-chksum = true
        .
      end.
      else do:
        if v-read-chksum = true then do:
          if v-last-key = 13 then do:
            leave block_read.
          end.
          else do:
            assign
              v-md5-signature-av = v-md5-signature-av + chr( v-last-key )
            .
          end.
        end.
        else do:
          if v-last-key = 13 then do:
            put stream temp-stream skip(v-new-line).
            assign
              v-new-line = 1
            .
          end.
          else do:
            put stream temp-stream unformatted chr( v-last-key ).
            assign
              v-new-line = 0
            .
          end.
        end.
      end.
    end.
    output stream temp-stream close.
    input stream TxtStream close.
    run gbl/md5.p
      ( input  search( v-temp-fname )
       ,output v-md5-signature
      ) no-error.
    if error-status :error then do:
      return error substitute("Ошибка при подсчете контрольной суммы текстового файла схемы &1", v-file-name ) .
    end.
    os-delete value( v-temp-fname ).
    assign
      v-md5-signature = sum-enc( v-md5-signature, 8 )
    .
    if v-md5-signature-av <> v-md5-signature then do:
      return error substitute( "Некорректная контрольная сумма текстового файла схемы &1", v-file-name ) .
    end.
    input stream TxtStream from value( v-file-name ).
    assign
      v-counter = 0
    .
    assign
      frame inf-cfg:title = "Чтение параметров конфигурации"
    .
    view frame inf-cfg.
    for each t_cnf-struct:
      delete t_cnf-struct.
    end.
    create t_cnf-struct no-error.
    read-cycle:
    repeat transaction
    on error  undo, return error substitute( "&1. &2&3&4", vss-include-info1, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      assign
        v-counter = v-counter + 1
      .
      if ( v-counter modulo 10 ) = 0 then do:
        display
          v-counter
          with frame inf-cfg.
      end.
      import stream TxtStream delimiter '`':U t_cnf-struct.param-code t_cnf-struct.param-type t_cnf-struct.data-type t_cnf-struct.param-name t_cnf-struct.attach-type t_cnf-struct.list-value t_cnf-struct.default-value t_cnf-struct.PS t_cnf-struct.param-group t_cnf-struct.user-resp no-error.
      if error-status:error then do:
        return error substitute( "&1. Ошибка при чтении текстового файла схемы! Cтрока &1. (&2)", vss-include-info1, v-counter, error-status :get-message ( error-status :num-messages ) ).
      end.
      else do:
        if not ( t_cnf-struct.param-code begins chr(1) ) then do:
          assign
            t_cnf-struct.user-resp = decoding-user-resp( t_cnf-struct.param-code, t_cnf-struct.user-resp )
          .
          if t_cnf-struct.user-resp = "unknown":U then do:
            return error substitute( "&1. Ошибка параметра! Cтрока &2.", vss-include-info1, v-counter ).
          end.
          run check-cfg in this-procedure
            ( input-output t_cnf-struct.param-code
            ,input-output t_cnf-struct.param-type
            ,input-output t_cnf-struct.data-type
            ,input-output t_cnf-struct.param-name
            ,input-output t_cnf-struct.attach-type
            ,input-output t_cnf-struct.list-value
            ,input-output t_cnf-struct.default-value
            ,input-output t_cnf-struct.PS
            ,input-output t_cnf-struct.param-group
            ,input-output t_cnf-struct.user-resp
            ) no-error .
          if error-status :error then do:
            return error substitute( "&1. Ошибка параметра! Cтрока &2. &3 (&4)", vss-include-info1, v-counter, return-value, error-status :get-message ( error-status :num-messages ) ).
          end.
          else do:
            find first cnf-struct
              where cnf-struct.param-code = t_cnf-struct.param-code
              no-error
            .
            if not available cnf-struct then do:
              create cnf-struct .
            end.
            buffer-copy t_cnf-struct to cnf-struct .
          end.
        end.
      end.
    end.
    delete t_cnf-struct no-error.
    hide frame inf-cfg.
    input stream TxtStream close.
  end.
  return.
end procedure.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable c-point  as character no-undo .
define variable tbl      as character no-undo .
define variable join-tbl as character no-undo .
define variable fld      as character no-undo .
define variable lab      as character no-undo .
define variable spr      as character no-undo .
define variable dim      as character no-undo .
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure fltfield-clear :
  define output parameter loc-fld as character no-undo.
  define output parameter loc-lab as character no-undo .
  define output parameter loc-spr as character no-undo .
  define output parameter loc-dim as character no-undo .
  assign
    loc-fld = ""
    loc-lab = ""
    loc-spr = ""
    loc-dim = "0"
  .
end procedure .
procedure fltfield-add :
  define input        parameter par-fld as character no-undo.
  define input        parameter par-lab as character no-undo .
  define input        parameter par-spr as character no-undo .
  define input-output parameter loc-fld as character no-undo.
  define input-output parameter loc-lab as character no-undo .
  define input-output parameter loc-spr as character no-undo .
  define input-output parameter loc-dim as character no-undo .
  do
  on error undo, return error
  :
    assign
    loc-fld = if loc-dim = '0'
              then par-fld
              else (loc-fld + chr(44) + par-fld)
    loc-lab = if loc-dim = '0'
              then par-lab
              else (loc-lab + chr(44) + par-lab)
    loc-spr = if loc-dim = '0'
              then par-spr
              else (loc-spr + chr(44) + par-spr)
    loc-dim = (if num-entries(loc-dim) > 1 then (entry(1, loc-dim) + chr(44)) else "") +
              string(integer(if num-entries(loc-dim) > 1
                            then entry(2, loc-dim)
                            else entry(1, loc-dim)
                            ) + 1)
    no-error
    .
  end.
end procedure.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-fltopend-rowid as rowid extent 18 no-undo .
procedure fltopend_fltopend :
define input parameter p-parent-handle as handle no-undo .
define input parameter p-qh as handle no-undo .
define input parameter p-flt-open-open-query  as character no-undo .
define input parameter p-where-cond as character no-undo .
define input parameter p-use-indFIRST-query-tail as character no-undo .
define input parameter p-use-ind-sort-clmn-by as character no-undo .
define input parameter p-indexed-reposition as character no-undo .
  do
  on error undo, return error
  :
define variable v-prepare-string as character no-undo .
define variable glog as logical no-undo .
assign
v-prepare-string = p-flt-open-open-query + " where " + chr(32) +
                   p-where-cond + chr(32)  +
                   p-use-indFIRST-query-tail + chr(32) +
                   p-use-ind-sort-clmn-by + chr(32) +
                   p-indexed-reposition
.
assign
glog = p-qh:query-prepare(v-prepare-string) no-error .
if not glog
or error-status:error then do:
  message error-status:get-message(1) view-as alert-box .
  undo, return error .
end.
assign
glog = p-qh:query-open no-error .
if not glog
or error-status:error then do:
  message error-status:get-message(1) view-as alert-box .
  undo, return error .
end.
  end.
end procedure.
procedure fltopend_fltfindd :
define input parameter p-parent-handle as handle no-undo .
define input parameter p-qh as handle no-undo .
define input parameter p-rowid as rowid no-undo .
define input parameter p-next as logical no-undo .
define input parameter p-lock as integer no-undo .
define input parameter p-bh as handle no-undo .
define input parameter p-where-cond as character no-undo .
define input parameter p-use-index-phrase as character no-undo .
define variable glog as logical no-undo .
define variable v-qh as handle no-undo .
define variable v-bh as handle no-undo .
define variable v-recid as recid no-undo .
define variable v-prepare-string as character no-undo .
do
on error undo, return error
on stop undo, return error
:
  glog = p-bh:find-by-rowid( p-rowid, p-lock) no-error.
  create buffer v-bh for table p-bh buffer-name p-bh:name.
  create query v-qh.
  v-qh:set-buffers(v-bh).
  v-prepare-string = substitute("for each &1 &2 &3"
                                  ,v-bh:name
                                  ,p-where-cond
                                  ,p-use-index-phrase).
  glog = v-qh:query-prepare(v-prepare-string) no-error.
  if not glog then do:
    delete object v-qh.
    delete object v-bh.
    undo, return error .
  end.
  glog = v-qh:query-open no-error .
  if not glog then do:
    delete object v-qh.
    delete object v-bh.
    undo, return error .
  end.
  if p-next then do:
    v-qh:reposition-to-rowid(p-rowid) no-error .
    glog = v-qh:get-next( p-lock) no-error .
    glog = v-qh:get-next( p-lock) no-error .
    if not glog or v-qh:query-off-end = yes then do:
      glog = v-qh:get-first( p-lock) no-error .
    end.
  end.
  else do:
    glog = v-qh:get-first( p-lock) no-error .
  end.
  v-recid = v-bh:recid no-error .
  delete object v-qh.
  delete object v-bh.
  return string(v-recid) .
end.
end procedure.
procedure fltopend_fltfindq :
define input parameter p-parent-handle as handle no-undo .
define input parameter p-qh as handle no-undo .
define input parameter p-next as logical no-undo .
define input parameter p-lock as integer no-undo .
define input parameter p-flt-open-open-query  as character no-undo .
define input parameter p-where-cond as character no-undo .
define input parameter p-use-indFIRST-query-tail as character no-undo .
define input parameter p-use-ind-sort-clmn-by as character no-undo .
define input parameter p-indexed-reposition as character no-undo .
define output parameter p-fltopend-rowid as rowid extent 18 no-undo .
define variable glog as logical no-undo .
define variable v-qh as handle no-undo .
define variable v-bh as handle no-undo extent 18.
define variable v-rowid as rowid no-undo extent 18.
define variable v-ii as integer no-undo .
define variable v-prepare-string as character no-undo .
do
on error undo, return error
on stop undo, return error
:
  create query v-qh.
  do v-ii = 1 to p-qh:num-buffers:
    create buffer v-bh[v-ii] for table p-qh:get-buffer-handle(v-ii) buffer-name p-qh:get-buffer-handle(v-ii):name .
    assign
    v-rowid[v-ii] = p-qh:get-buffer-handle(v-ii):rowid
    no-error.
    v-qh:add-buffer(v-bh[v-ii]).
  end.
  assign
  v-prepare-string = p-flt-open-open-query + " where " + chr(32) +
                    p-where-cond + chr(32)  +
                    p-use-indFIRST-query-tail + chr(32) +
                    p-use-ind-sort-clmn-by + chr(32) +
                    p-indexed-reposition
  .
  glog = v-qh:query-prepare( v-prepare-string) no-error .
  if not glog then do:
    delete object v-qh.
    do v-ii = 1 to p-qh:num-buffers:
      delete object v-bh[v-ii].
    end.
    undo, return error .
  end.
  glog = v-qh:query-open no-error .
  if not glog then do:
    delete object v-qh.
    do v-ii = 1 to p-qh:num-buffers:
      delete object v-bh[v-ii].
    end.
    undo, return error .
  end.
  if p-next then do:
    glog = v-qh:reposition-to-rowid(v-rowid) no-error .
    glog = v-qh:get-next( p-lock) no-error .
    glog = v-qh:get-next( p-lock) no-error .
    if not glog or v-qh:query-off-end = yes then do:
      glog = v-qh:get-first( p-lock) no-error .
    end.
  end.
  else do:
    glog = v-qh:get-first( p-lock) no-error .
  end.
  do v-ii = 1 to p-qh:num-buffers:
    assign
    p-fltopend-rowid[v-ii] = v-bh[v-ii]:rowid
    no-error.
  end.
  delete object v-qh.
  do v-ii = 1 to p-qh:num-buffers:
    delete object v-bh[v-ii].
  end.
end.
end procedure.
  define buffer buf-curr_db for ub.db.
define variable mark             as character   no-undo .
define variable mark-list        as character   no-undo .
define variable Cnf-hdl          as handle      no-undo .
define variable db-hdl           as handle      no-undo .
define variable CurCnf-hdl       as handle      no-undo .
define variable fname            as character   no-undo .
define variable v-cnf-rec          as recid no-undo.
define variable v-title0           as character no-undo init "Настройки и конфигурация системы" .
define variable v-sort-column-name as character no-undo .
define variable v-filter-pointr    as character no-undo init "Настройки и конфигурация системы" .
define variable v-filter-point0    as character no-undo init "b-config" .
define variable v-filter-point     as character no-undo .
define temp-table tt_cnf no-undo like cnf .
FUNCTION attach-ext RETURNS CHARACTER
  ()  FORWARD.
FUNCTION attach-short RETURNS CHARACTER
  () FORWARD.
FUNCTION can-process RETURNS LOGICAL
  ( input mes as character, input param-type as character) FORWARD.
DEFINE BUTTON b-chg
     LABEL "&Изменить":L
     SIZE 10 BY 1 TOOLTIP "Изменить значение и/или привязку параметра".
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Выход":L
     SIZE 10 BY 1 TOOLTIP "Сохранить изменения и выйти из режима".
DEFINE BUTTON b-Exp
     LABEL "&Экспорт":L
     SIZE 10 BY 1 TOOLTIP "Вывести в файл набор парметров".
DEFINE BUTTON b-help
     LABEL "Помо&щь":L
     SIZE 3 BY 1.
DEFINE BUTTON b-hist
     LABEL "Ис&тория":L
     SIZE 3 BY 1.
DEFINE BUTTON b-Imp
     LABEL "И&мпорт":L
     SIZE 10 BY 1 TOOLTIP "Считать из файла набор параметров".
DEFINE BUTTON b-lkp
     LABEL "&Просмотр":L
     SIZE 10 BY 1 TOOLTIP "Просмотр параметра".
DEFINE BUTTON b-Log
     LABEL "&Протокол":L
     SIZE 10 BY 1 TOOLTIP "Посмотреть протокол работы".
DEFINE BUTTON b-mark
     LABEL "&*":L
     SIZE 3 BY 1 TOOLTIP "Поставить/снять отметку записи".
DEFINE BUTTON b-save
     LABEL "&Сохранить":L
     SIZE 10 BY 1 TOOLTIP "Сохранить сделанные изменения".
DEFINE BUTTON b-sch
     LABEL "&Фильтр"
     SIZE 3 BY 1.
DEFINE BUTTON b-Tgle
     LABEL "В&кл/выкл":L
     SIZE 10 BY 1 TOOLTIP "Поставить/снять отметку работы с параметром".
DEFINE VARIABLE f-db-num AS INTEGER FORMAT ">>>>9" INITIAL ?
     VIEW-AS FILL-IN
     SIZE 6 BY .83 NO-UNDO.
DEFINE VARIABLE f-param-name AS CHARACTER FORMAT "X(85)"
     LABEL "Параметр"
      VIEW-AS TEXT
     SIZE 86 BY .67 NO-UNDO.
DEFINE VARIABLE sch-param AS CHARACTER FORMAT "X(80)":U
     VIEW-AS FILL-IN
     SIZE 46.5 BY .83 NO-UNDO.
DEFINE VARIABLE r-cnf-db AS CHARACTER INITIAL "all"
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Все", "all",
"Текущая", "curr-db",
"Выбранная", "sel-db"
     SIZE 31 BY .83 NO-UNDO.
DEFINE VARIABLE r-cnf-encoded AS CHARACTER INITIAL "all"
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Все", "all",
"Выборочно", "sel-type"
     SIZE 20 BY .83 NO-UNDO.
DEFINE VARIABLE r-find-in-br AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "По коду", "param-code",
"По названию", "param-name",
"По значению", "param-value"
     SIZE 42 BY .83 NO-UNDO.
DEFINE VARIABLE r-show-cnf AS CHARACTER INITIAL "used"
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Все", "all",
"Включенные", "used",
"Выключенные", "notused",
"Только с ошибками", "onlyerror"
     SIZE 57 BY .83 NO-UNDO.
DEFINE VARIABLE t-cnf-type-k AS LOGICAL INITIAL no
     LABEL "К"
     VIEW-AS TOGGLE-BOX
     SIZE 4 BY .83 NO-UNDO.
DEFINE VARIABLE t-cnf-type-notenc AS LOGICAL INITIAL no
     LABEL "Без кодировки"
     VIEW-AS TOGGLE-BOX
     SIZE 16 BY .83 NO-UNDO.
DEFINE VARIABLE t-cnf-type-o AS LOGICAL INITIAL no
     LABEL "О"
     VIEW-AS TOGGLE-BOX
     SIZE 4 BY .83 NO-UNDO.
DEFINE VARIABLE t-cnf-type-s AS LOGICAL INITIAL no
     LABEL "П"
     VIEW-AS TOGGLE-BOX
     SIZE 4 BY .83 NO-UNDO.
DEFINE QUERY br-config FOR Cnf, cnf-struct SCROLLING.
DEFINE BROWSE br-config
  QUERY br-config DISPLAY
      mark  COLUMN-LABEL '*'  FORMAT "X(1)"
      (if Cnf.NotUsed   THEN '-' ELSE '+')  COLUMN-LABEL '+'  FORMAT "X(1)"
      (if Cnf.Is-Changed THEN 'X' ELSE ' ')  COLUMN-LABEL 'И'  FORMAT "X(1)"
      Cnf.Conf-Type  COLUMN-LABEL 'Т'  FORMAT "X(1)"
      attach-short()  COLUMN-LABEL 'П'  FORMAT "X(1)"
      string(Cnf.db-num)  COLUMN-LABEL 'БД'
      Cnf.Param-Code  COLUMN-LABEL 'Код'
      Cnf.Param-Name  COLUMN-LABEL 'Название'  format "x(256)"
      Cnf.Param-Value  COLUMN-LABEL 'Значение'
      attach-ext() COLUMN-LABEL 'Привязка' FORMAT "X(25)"
      Cnf.Param-PS COLUMN-LABEL 'Примечание'
      cnf-struct.list-value COLUMN-LABEL 'Возможные значения' FORMAT "X(18)"
      cnf-struct.default-value COLUMN-LABEL 'Значение по умолчанию' FORMAT "X(15)"
      String(Cnf.ErrorExist) COLUMN-LABEL ' Ош. '
      cnf-struct.data-type COLUMN-LABEL ' Тип   параметра ' FORMAT "X(17)"
      (if cnf.beg-date <> 01/01/1900 then string(cnf.beg-date,'99/99/9999') else 'неограничено' ) COLUMN-LABEL 'Действует с' FORMAT "X(12)"
      (if cnf.end-date <> 01/01/9999 then string(cnf.end-date,'99/99/9999') else 'неограничено.' ) COLUMN-LABEL 'Действует по' FORMAT "X(12)"
    WITH SEPARATORS SIZE 97 BY 15.75 ROW-HEIGHT-CHARS .63.
DEFINE FRAME fr-config
     b-exit AT ROW 1 COL 2 WIDGET-ID 4
     b-mark AT ROW 1 COL 12 WIDGET-ID 18
     b-save AT ROW 1 COL 15 WIDGET-ID 20
     b-lkp AT ROW 1 COL 25 WIDGET-ID 14
     b-chg AT ROW 1 COL 35 WIDGET-ID 2
     b-Tgle AT ROW 1 COL 45 WIDGET-ID 22
     b-Exp AT ROW 1 COL 55 WIDGET-ID 6
     b-Imp AT ROW 1 COL 65 WIDGET-ID 12
     b-Log AT ROW 1 COL 75 WIDGET-ID 16
     b-sch AT ROW 1 COL 90 WIDGET-ID 40
     b-hist AT ROW 1 COL 93 WIDGET-ID 10
     b-help AT ROW 1 COL 96 WIDGET-ID 8
     r-show-cnf AT ROW 2.5 COL 14.5 NO-LABEL WIDGET-ID 34
     r-cnf-encoded AT ROW 3.5 COL 14.5 NO-LABEL WIDGET-ID 50
     t-cnf-type-k AT ROW 3.5 COL 46 WIDGET-ID 56
     t-cnf-type-s AT ROW 3.5 COL 51 WIDGET-ID 58
     t-cnf-type-o AT ROW 3.5 COL 56 WIDGET-ID 60
     t-cnf-type-notenc AT ROW 3.5 COL 61 WIDGET-ID 62
     r-cnf-db AT ROW 4.5 COL 14.5 NO-LABEL WIDGET-ID 42
     f-db-num AT ROW 4.5 COL 44 COLON-ALIGNED NO-LABEL WIDGET-ID 66
     r-find-in-br AT ROW 5.75 COL 10.5 NO-LABEL WIDGET-ID 70
     sch-param AT ROW 5.75 COL 50.5 COLON-ALIGNED NO-LABEL WIDGET-ID 30
     br-config AT ROW 6.75 COL 2 WIDGET-ID 200
     f-param-name AT ROW 22.75 COL 2 WIDGET-ID 32
     "Параметры:" VIEW-AS TEXT
          SIZE 12 BY .83 AT ROW 2.5 COL 2 WIDGET-ID 46
     "Поиск:" VIEW-AS TEXT
          SIZE 7 BY .83 AT ROW 5.75 COL 2 WIDGET-ID 68
     "Кодировка:" VIEW-AS TEXT
          SIZE 12 BY .83 AT ROW 3.5 COL 2 WIDGET-ID 64
     "БД:" VIEW-AS TEXT
          SIZE 5 BY .83 AT ROW 4.5 COL 9 WIDGET-ID 48
     SPACE(85.87) SKIP(18.29)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "" WIDGET-ID 100.
ASSIGN
       FRAME fr-config:SCROLLABLE       = FALSE.
ASSIGN
       f-db-num:HIDDEN IN FRAME fr-config           = TRUE.
ASSIGN
       f-param-name:READ-ONLY IN FRAME fr-config        = TRUE.
ASSIGN
       t-cnf-type-k:HIDDEN IN FRAME fr-config           = TRUE.
ASSIGN
       t-cnf-type-notenc:HIDDEN IN FRAME fr-config           = TRUE.
ASSIGN
       t-cnf-type-o:HIDDEN IN FRAME fr-config           = TRUE.
ASSIGN
       t-cnf-type-s:HIDDEN IN FRAME fr-config           = TRUE.
ON WINDOW-CLOSE OF FRAME fr-config
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-chg IN FRAME fr-config
DO:
  if not can-process("Параметр закодирован. Изменение не допускается", 'к,п':U) then do:
    return no-apply.
  end.
  run chg-param in this-procedure
    ( input recid( cnf )
    , input false
    ) .
  apply "entry" to browse br-config.
END.
ON CHOOSE OF b-exit IN FRAME fr-config
DO:
  define buffer buf-chg_cnf for cnf .
    find first buf-chg_cnf
      where buf-chg_cnf.is-changed = true
      no-error .
    if available buf-chg_cnf then do:
      message
        "Завершение работы с конфигурацией."
        "Сохранить сделанные изменения?"
        view-as alert-box question buttons yes-no-cancel update go-ahead as logical.
      if go-ahead = true then do:
        run waitfram-show in this-procedure ("Сохранение набора параметров").
        run save-cfg in db-hdl
          ( input no
          ) no-error.
        if error-status :error
          or return-value <> ""
        then do:
            message
              "Попытка сохранить изменения не удалась!" skip
              error-status :get-message(1) skip
              return-value skip
              "Выйти без сохранения?" skip
              view-as alert-box buttons yes-no update go-out as logical.
            if go-out = false then do:
              run waitfram-hide in this-procedure .
              return no-apply.
            end.
        end.
        run waitfram-hide in this-procedure .
      end.
    end.
END.
ON CHOOSE OF b-Exp IN FRAME fr-config
DO:
  define variable v-err-code     as character no-undo .
  define variable v-qnty-exp-cnf as integer   no-undo .
  define buffer buf_cnf for cnf .
  run export-cnf in CurCnf-hdl
    ( input this-procedure :handle
    , input (false )
    , input (if available cnf then recid( cnf ) else ? )
    , input mark-list
    , output v-qnty-exp-cnf
    ) no-error .
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      substitute("Произошли ошибки при экспорте параметров!") skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
  end.
  else do:
    if v-qnty-exp-cnf <> ? then do:
      message
        "Экспорт параметров завершен!" skip
        substitute( "Выгружено &1 параметров", v-qnty-exp-cnf ) skip
        view-as alert-box information.
    end.
  end.
  apply "entry" to browse br-config.
END.
ON CHOOSE OF b-hist IN FRAME fr-config
DO:
   run adm/cfg-hist.w
    ( input parparentproc
     ,buffer cnf
    )
  .
  apply "entry" to browse br-config.
END.
ON CHOOSE OF b-Imp IN FRAME fr-config
DO:
  define variable clearcnf   as logical   no-undo.
  define variable uselast    as logical   no-undo.
  define variable v-err-code as character no-undo .
  define variable v-db-load  as character no-undo .
  assign
    fname = "config.cfg"
  .
  run adm/impi.w
    ( input-output fname
    , output clearcnf
    , output uselast
    ) no-error.
  if error-status:error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при запуске процедуры impi.w" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    return no-apply.
  end.
  if fname = "":U then do:
    apply "entry" to browse br-config.
    return no-apply.
  end.
  run waitfram-show in this-procedure ("Импорт конфигурации").
  assign
    v-db-load = "":U
  .
    if buf-curr_db.db-num > 0 then do:
      assign
        v-db-load = string( buf-curr_db.db-num )
      .
    end.
  run toggle-mes in cnf-hdl
    ( input false
    ).
  run import in CurCnf-hdl
  ( input fname
  , input clearcnf
  , input uselast
  , input false
  , input v-db-load
  ).
  run toggle-mes in cnf-hdl
    ( input true
    ).
  assign
    v-err-code = return-value
  .
  run chk-unref in curcnf-hdl
    ( input ?
    , input ?
    , input ?
    , input false
    ) no-error.
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      substitute("Ошибка при создании недостающих параметров") skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    run waitfram-hide in this-procedure .
    return no-apply.
  end.
  run waitfram-hide in this-procedure .
  if available cnf then do:
    assign
      v-cnf-rec = recid( cnf )
    .
  end.
  run reopen-query in this-procedure
    ( input true
    , input false
    , input '':U
    ) .
  reposition br-config to recid v-cnf-rec no-error .
  assign
    v-cnf-rec = ?
  .
  if v-err-code = "":U then do:
    message
      "Импорт параметров завершен"
      view-as alert-box information.
  end.
  else do:
    message
      "Параметры не загружены!!!" skip
      "Произошли ошибки при импорте параметров!" skip
      'Просмотреть ошибки можно по кнопке "протокол"'
      view-as alert-box error .
  end.
  apply "entry" to browse br-config.
END.
ON CHOOSE OF b-lkp IN FRAME fr-config
DO:
  define variable rid as integer no-undo.
  rid = recid (cnf).
    run adm/cnfi.w (parparentproc, curcnf-hdl, db-hdl, cnf-hdl, "lkp":U, input-output rid).
  apply "entry" to browse br-config.
END.
ON CHOOSE OF b-Log IN FRAME fr-config
DO:
  run adm/show-log.w .
  apply "entry" to browse br-config.
END.
ON CHOOSE OF b-mark IN FRAME fr-config
DO:
  define variable v-log as logical no-undo .
  if not available Cnf then do:
    message "Неправильный выбор строки.".
    return no-apply.
  end.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-str-recid7 as character no-undo .
define variable v-num-entry7 as integer   no-undo .
assign
  v-str-recid7 = trim( string( recid( cnf ) , "->>>>>>>>>>>9":U ) )
  v-num-entry7 = lookup( v-str-recid7 , mark-list )
.
if v-num-entry7 > 0 then do:
  assign
    entry( v-num-entry7, mark-list ) = "":U
    mark-list = trim( replace( mark-list , chr(44) + chr(44) , chr(44) ) , chr(44) )
  .
end.
else do:
  assign
    mark-list = mark-list + ( if mark-list = "":U then "":U else chr(44) ) + v-str-recid7
  .
end.
  assign
    v-log = br-config:refresh() in frame fr-config
    v-log = br-config:select-next-row () in frame fr-config
  .
END.
ON CHOOSE OF b-save IN FRAME fr-config
DO:
    run waitfram-show in this-procedure ("Сохранение набора параметров").
    run save-cfg in db-hdl
      ( input no
      ) no-error .
    if error-status :error
      or return-value <> ""
    then do:
      message
        substitute( "Попытка сохранить изменения не удалась." ) skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
    end.
    else do:
      for each cnf
        where cnf.is-changed
      :
        assign
          cnf.is-changed = false
        .
      end.
      run reopen-query in this-procedure
        ( input true
        , input false
        , input '':U
        ) .
    end.
    run waitfram-hide in this-procedure .
    apply "entry" to browse br-config.
END.
ON CHOOSE OF b-sch IN FRAME fr-config
DO:
  run proc-b-sch in this-procedure no-error.
  apply "entry" to browse br-config.
END.
ON CHOOSE OF b-Tgle IN FRAME fr-config
DO:
  if not can-process("Параметр кодированный. Включение/отключение не допускается", 'к,п':U )
    or ( cnf.NotUsed = false
         and not can-process("Параметр обязательный. Отключение не допускается", 'о':U )
       )
  then do:
    return no-apply.
  end.
  run chg-param in this-procedure
    ( input recid( cnf )
    , input true
    ) .
  apply "entry" to browse br-config.
END.
ON ANY-PRINTABLE OF br-config IN FRAME fr-config
DO:
  assign
    sch-param:screen-value = sch-param:screen-value + last-event:label
  .
  apply "entry" to sch-param in frame fr-config.
  apply "end" to sch-param in frame fr-config.
END.
ON MOUSE-SELECT-DBLCLICK OF br-config IN FRAME fr-config
OR RETURN OF br-config IN FRAME fr-config
DO:
  apply "choose" to b-chg in frame fr-config.
END.
ON ROW-DISPLAY OF br-config IN FRAME fr-config
DO:
  if lookup( string( recid( cnf ) ), mark-list ) > 0 then do:
    assign
      mark = "*":U
    .
  end.
  else do:
    assign
      mark = "":U
    .
  end.
  case cnf.ErrorExist:
    when 0 then do:
       Cnf.Param-Code:fgcolor in browse br-config = 0 .
    end.
    when 1 then do:
       Cnf.Param-Code:fgcolor in browse br-config = 9 .
    end.
    when 2 then do:
       Cnf.Param-Code:fgcolor in browse br-config = 12 .
    end.
  end case.
END.
ON VALUE-CHANGED OF br-config IN FRAME fr-config
DO:
  if available cnf then do:
    assign
      f-param-name :screen-value = cnf.param-name
    .
  end.
  else do:
    assign
      f-param-name :screen-value = "":U
    .
  end.
END.
ON RETURN OF f-db-num IN FRAME fr-config
DO:
  assign
    f-db-num
  .
  if available cnf then do:
    assign
      v-cnf-rec = recid( cnf )
    .
  end.
  run reopen-query in this-procedure
    ( input true
    , input false
    , input '':U
    ) .
  reposition br-config to recid v-cnf-rec no-error .
  assign
    v-cnf-rec = ?
  .
END.
ON VALUE-CHANGED OF r-cnf-db IN FRAME fr-config
DO:
  assign
    r-cnf-db
  .
  disable
    f-db-num
    with frame fr-config
  .
  hide
    f-db-num
    in frame fr-config
  .
  case r-cnf-db :
      when "curr-db":U then do:
        if available buf-curr_db then do:
          assign
            f-db-num = buf-curr_db.db-num
          .
          display
            f-db-num
            with frame fr-config
          .
        end.
      end.
    when "sel-db":U then do:
      enable
        f-db-num
        with frame fr-config
      .
      apply "entry" to f-db-num in frame fr-config.
    end.
  end case.
  if lookup( r-cnf-db, "all,curr-db":U ) > 0 then do:
    if available cnf then do:
      assign
        v-cnf-rec = recid( cnf )
      .
    end.
    run reopen-query in this-procedure
      ( input true
      , input false
      , input '':U
      ) .
    reposition br-config to recid v-cnf-rec no-error .
    assign
      v-cnf-rec = ?
    .
  end.
END.
ON VALUE-CHANGED OF r-cnf-encoded IN FRAME fr-config
DO:
  assign
    r-cnf-encoded
  .
  if r-cnf-encoded = "all":U then do:
    hide
      t-cnf-type-k
      t-cnf-type-s
      t-cnf-type-o
      t-cnf-type-notenc
      in frame fr-config
    .
  end.
  else do:
    enable
      t-cnf-type-k
      t-cnf-type-s
      t-cnf-type-o
      t-cnf-type-notenc
      with frame fr-config
    .
  end.
  if available cnf then do:
    assign
      v-cnf-rec = recid( cnf )
    .
  end.
  run reopen-query in this-procedure
    ( input true
    , input false
    , input '':U
    ) .
  reposition br-config to recid v-cnf-rec no-error .
  assign
    v-cnf-rec = ?
  .
END.
ON VALUE-CHANGED OF r-find-in-br IN FRAME fr-config
DO:
  assign
    r-find-in-br
  .
  case r-find-in-br :
    when "param-code":U then do:
      assign
        sch-param :format       = "X(12)"
        sch-param :width-chars = 13.0
      .
    end.
    when "param-name":U
      or when "param-vale":U
    then do:
      assign
        sch-param :format       = "X(80)"
        sch-param :width-chars = 46.5
      .
    end.
  end case.
  assign
    sch-param:screen-value = "":U
  .
END.
ON VALUE-CHANGED OF r-show-cnf IN FRAME fr-config
DO:
  assign
    r-show-cnf
  .
  if available cnf then do:
    assign
      v-cnf-rec = recid( cnf )
    .
  end.
  run reopen-query in this-procedure
    ( input true
    , input false
    , input '':U
    ) .
  reposition br-config to recid v-cnf-rec no-error .
  assign
    v-cnf-rec = ?
  .
END.
ON CTRL-J OF sch-param IN FRAME fr-config
DO:
  assign
    r-find-in-br
  .
  run find-param in this-procedure
    ( input true
    , input r-find-in-br
    , input ( input frame fr-config sch-param )
    ) no-error.
  if error-status:error then return no-apply.
END.
ON RETURN OF sch-param IN FRAME fr-config
DO:
  assign
    r-find-in-br
  .
  run find-param in this-procedure
    ( input false
    , input r-find-in-br
    , input ( input frame fr-config sch-param )
    ) no-error.
  if error-status:error then return no-apply.
END.
ON VALUE-CHANGED OF t-cnf-type-k IN FRAME fr-config
DO:
   assign
     t-cnf-type-k
   .
  if available cnf then do:
    assign
      v-cnf-rec = recid( cnf )
    .
  end.
  run reopen-query in this-procedure
    ( input true
    , input false
    , input '':U
    ) .
  reposition br-config to recid v-cnf-rec no-error .
  assign
    v-cnf-rec = ?
  .
END.
ON VALUE-CHANGED OF t-cnf-type-notenc IN FRAME fr-config
DO:
  assign
    t-cnf-type-notenc
  .
  if available cnf then do:
    assign
      v-cnf-rec = recid( cnf )
    .
  end.
  run reopen-query in this-procedure
    ( input true
    , input false
    , input '':U
    ) .
  reposition br-config to recid v-cnf-rec no-error .
  assign
    v-cnf-rec = ?
  .
END.
ON VALUE-CHANGED OF t-cnf-type-o IN FRAME fr-config
DO:
  assign
    t-cnf-type-o
  .
  if available cnf then do:
    assign
      v-cnf-rec = recid( cnf )
    .
  end.
  run reopen-query in this-procedure
    ( input true
    , input false
    , input '':U
    ) .
  reposition br-config to recid v-cnf-rec no-error .
  assign
    v-cnf-rec = ?
  .
END.
ON VALUE-CHANGED OF t-cnf-type-s IN FRAME fr-config
DO:
  assign
    t-cnf-type-s
  .
  if available cnf then do:
    assign
      v-cnf-rec = recid( cnf )
    .
  end.
  run reopen-query in this-procedure
    ( input true
    , input false
    , input '':U
    ) .
  reposition br-config to recid v-cnf-rec no-error .
  assign
    v-cnf-rec = ?
  .
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME fr-config:PARENT eq ?
THEN FRAME fr-config:PARENT = ACTIVE-WINDOW.
run adm/cnf-str.p persistent set cnf-hdl no-error.
if not valid-handle (cnf-hdl)  then do:
   message
     vss-workfile vss-revision vss-description skip
     "Ошибка при попытке инициализировать работу со схемой конфигурации cnf-str.p" skip
     error-status :get-message(1) skip
     return-value skip
     view-as alert-box error .
   return.
end.
  run adm/cnf-db.p persistent set db-hdl no-error.
  if not valid-handle (db-hdl)  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при попытке инициализировать работу со схемой конфигурации cnf-db.p" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    return.
  end.
run adm/cnf-cnf.p persistent set CurCnf-hdl no-error.
if not valid-handle (CurCnf-hdl)  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при попытке инициализировать работу со схемой конфигурации cnf-cnf.p" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
   return.
end.
assign
  br-config:num-locked-columns in frame fr-config = 7
  .
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEF VAR cur-clmn-numbr-config as INT EXTENT 15 no-undo.
DEF VAR varmvibr-config       as INT no-undo.
DEF VAR varmvjbr-config       as INT no-undo.
DEF VAR varmvkbr-config       as INT no-undo.
DEF VAR varmvlbr-config       as INT no-undo.
DEF VAR move-elementbr-config as INT no-undo.
def var jjbr-config           as int no-undo.
do varmvibr-config = 1 to EXTENT(cur-clmn-numbr-config):
  ASSIGN cur-clmn-numbr-config[varmvibr-config] = varmvibr-config.
END.
RUN start-mv-clmnbr-config.
PROCEDURE start-mv-clmnbr-config:
def var old-session as logical no-undo.
   old-session = SESSION:IMMEDIATE-DISPLAY.
   IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
   SESSION:IMMEDIATE-DISPLAY = old-session.
END.
ON ctrl-cursor-right OF BROWSE br-config do:
  RUN re-move-clmnbr-config ( 8, 15).
END.
ON ctrl-cursor-left OF BROWSE br-config do:
  RUN re-move-clmnbr-config (15, 8).
END.
PROCEDURE re-move-clmnbr-config:
  DEFINE INPUT PARAMETER source-column as INTEGER NO-UNDO.
  DEFINE INPUT PARAMETER target-column as INTEGER NO-UNDO.
  DO varmvibr-config = 1 TO EXTENT(cur-clmn-numbr-config):
    if cur-clmn-numbr-config[varmvibr-config] = source-column THEN cur-clmn-numbr-config[varmvibr-config] = -1.
  END.
  if br-config:MOVE-COLUMN(source-column, target-column) IN FRAME fr-config then.
  if source-column > target-column THEN
  DO varmvjbr-config = source-column - 1 to target-column BY -1:
    DO varmvibr-config = 1 TO EXTENT(cur-clmn-numbr-config):
        if cur-clmn-numbr-config[varmvibr-config] = varmvjbr-config THEN DO:
          cur-clmn-numbr-config[varmvibr-config] = cur-clmn-numbr-config[varmvibr-config] + 1.
        END.
    END.
  END.
  ELSE
  DO varmvjbr-config = source-column + 1 to target-column:
    DO varmvibr-config = 1 TO EXTENT(cur-clmn-numbr-config):
      if cur-clmn-numbr-config[varmvibr-config] = varmvjbr-config THEN DO:
        cur-clmn-numbr-config[varmvibr-config] = cur-clmn-numbr-config[varmvibr-config] - 1.
      END.
    END.
  END.
  DO varmvibr-config = 1 TO EXTENT(cur-clmn-numbr-config):
    if cur-clmn-numbr-config[varmvibr-config] = -1 THEN cur-clmn-numbr-config[varmvibr-config] = target-column.
  END.
END PROCEDURE.
PROCEDURE ch-clmnbr-config:
  DEFINE INPUT PARAMETER cur-clmn-loc as INTEGER NO-UNDO.
  if cur-clmn-loc <= 8 then do:
    return .
  end.
  DO varmvibr-config = 1 TO EXTENT(cur-clmn-numbr-config):
    if cur-clmn-numbr-config[varmvibr-config] = cur-clmn-loc THEN move-elementbr-config = varmvibr-config.
  END.
  RUN re-move-clmnbr-config (cur-clmn-loc, 8).
END PROCEDURE.
PROCEDURE mv-brw-defaultbr-config:
def var old-session as logical no-undo.
  old-session = SESSION:IMMEDIATE-DISPLAY.
  IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
  do varmvlbr-config = 8 to EXTENT(cur-clmn-numbr-config):
    RUN re-move-clmnbr-config (cur-clmn-numbr-config[varmvlbr-config], varmvlbr-config).
  END.
  RUN start-mv-clmnbr-config.
  SESSION:IMMEDIATE-DISPLAY = old-session.
END PROCEDURE.
.
def var sort-labelbr-config   as character no-undo .
def var sort-clmnbr-config    as handle    no-undo .
def var cur-clmnbr-config     as handle    no-undo .
def var cur-clmn-locbr-config as integer   no-undo .
def var re-querybr-config     as logical   initial no no-undo .
on start-search, ctrl-o of br-config in frame fr-config do:
   run sort-brbr-config
     (input (if available cnf
             then recid(cnf)
             else ?
            )
     ).
end.
PROCEDURE sort-brbr-config :
  define input parameter p-recid as recid no-undo .
  if re-querybr-config = no then do:
    assign
       cur-clmnbr-config = br-config:current-column in frame fr-config
    .
    if sort-clmnbr-config <> ? then sort-clmnbr-config:column-fgcolor = 0.
    if cur-clmnbr-config = sort-clmnbr-config then do:
      assign
         sort-labelbr-config = ""
         sort-clmnbr-config = ?
      .
     end.
     else do:
       assign
         sort-labelbr-config = cur-clmnbr-config:label
         sort-clmnbr-config  = cur-clmnbr-config
         sort-clmnbr-config:column-fgcolor = 4
       .
     end.
   end.
  assign
    cur-clmn-locbr-config = 1
  .
  def var column-handle as handle no-undo .
  column-handle = br-config:first-column.
  do while valid-handle(column-handle) :
    if column-handle = cur-clmnbr-config then do:
      leave .
    end.
    column-handle = column-handle:NEXT-COLUMN.
    assign
      cur-clmn-locbr-config = cur-clmn-locbr-config + 1
    .
  end.
  case sort-labelbr-config:
        when '*'  then DO:    assign       v-sort-column-name = "mark"     .     run reopen-query in this-procedure ( input true, input false, input '':U ).   . END.
        when '+'  then DO:    assign       v-sort-column-name = "(if Cnf.NotUsed   THEN '-' ELSE '+')"     .     run reopen-query in this-procedure ( input true, input false, input '':U ).   . END.
        when 'И'  then DO:    assign       v-sort-column-name = "(if Cnf.Is-Changed THEN 'X' ELSE ' ')"     .     run reopen-query in this-procedure ( input true, input false, input '':U ).   . END.
        when 'Т'  then DO:    assign       v-sort-column-name = "Cnf.Conf-Type"     .     run reopen-query in this-procedure ( input true, input false, input '':U ).   . END.
        when 'П'  then DO:    assign       v-sort-column-name = "attach-short()"     .     run reopen-query in this-procedure ( input true, input false, input '':U ).   . END.
        when 'БД'  then DO:    assign       v-sort-column-name = "string(Cnf.db-num)"     .     run reopen-query in this-procedure ( input true, input false, input '':U ).   . END.
        when 'Код'  then DO:    assign       v-sort-column-name = "Cnf.Param-Code"     .     run reopen-query in this-procedure ( input true, input false, input '':U ).   . END.
        when 'Название'  then DO:    assign       v-sort-column-name = "Cnf.Param-Name"     .     run reopen-query in this-procedure ( input true, input false, input '':U ).   . END.
        when 'Значение'  then DO:    assign       v-sort-column-name = "substring(Cnf.Param-Value,1,180)"     .     run reopen-query in this-procedure ( input true, input false, input '':U ).   . END.
        when 'Привязка'  then DO:    assign       v-sort-column-name = "attach-ext()"     .     run reopen-query in this-procedure ( input true, input false, input '':U ).   . END.
        when 'Примечание'  then DO:    assign       v-sort-column-name = "substring(Cnf.Param-PS,1,180)"     .     run reopen-query in this-procedure ( input true, input false, input '':U ).   . END.
        when 'Возможные значения'  then DO:    assign       v-sort-column-name = "substring(cnf-struct.list-value,1,180)"     .     run reopen-query in this-procedure ( input true, input false, input '':U ).   . END.
        when 'Значение по умолчанию'  then DO:    assign       v-sort-column-name = "cnf-struct.default-value"     .     run reopen-query in this-procedure ( input true, input false, input '':U ).   . END.
        when ' Ош. '  then DO:    assign       v-sort-column-name = "String(Cnf.ErrorExist)"     .     run reopen-query in this-procedure ( input true, input false, input '':U ).   . END.
        when ' Тип   параметра '  then DO:    assign       v-sort-column-name = "cnf-struct.data-type"     .     run reopen-query in this-procedure ( input true, input false, input '':U ).   . END.
        when 'Действует с'  then DO:    assign       v-sort-column-name = "(if cnf.beg-date <> 01/01/1900 then string(cnf.beg-date,'99/99/9999') else 'неограничено' )"     .     run reopen-query in this-procedure ( input true, input false, input '':U ).   . END.
        when 'Действует по'  then DO:    assign       v-sort-column-name = "(if cnf.end-date <> 01/01/9999 then string(cnf.end-date,'99/99/9999') else 'неограничено.' )"     .     run reopen-query in this-procedure ( input true, input false, input '':U ).   . END.
    otherwise do:
      assign
        v-sort-column-name = ""
      .
      run reopen-query in this-procedure ( input true, input false, input '':U ).
        if can-do( this-procedure:internal-entries, 'mv-brw-defaultbr-config') then do:
          run mv-brw-defaultbr-config.
        end.
      if sort-labelbr-config <> "" then do:
        assign
          cur-clmnbr-config:column-fgcolor = 0
        .
      end.
      assign
        cur-clmn-locbr-config = ?
      .
    end.
  end case.
    if cur-clmn-locbr-config <> ? then do:
      if can-do( this-procedure:internal-entries, 'ch-clmnbr-config') then do:
        run ch-clmnbr-config in this-procedure (cur-clmn-locbr-config).
      end.
    end.
  if p-recid <> ? then do:
    reposition br-config to recid p-recid no-error.
    apply "value-changed" to br-config in frame fr-config.
  end.
  apply "entry" to br-config in frame fr-config.
END PROCEDURE.
procedure re-open-query-srt-clmnbr-config:
if cur-clmnbr-config = ? then do:
   run reopen-query in this-procedure ( input true, input false, input '':U ).
end.
else do:
   assign re-querybr-config = yes.
   run sort-brbr-config
     (input (if available cnf
             then recid(cnf)
             else ?
            )
     ).
   assign re-querybr-config = no.
end.
end.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  br-config :SET-REPOSITIONED-ROW(5, "CONDITIONAL") .
end.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on f5 of frame fr-config anywhere
do:
  v-cnf-rec = recid(cnf).                   run reopen-query in this-procedure ( input yes, input no, input '':U). reposition br-config to recid v-cnf-rec no-error.                   v-cnf-rec = ?.                   apply 'value-changed' TO br-config.
    apply "VALUE-CHANGED" to br-config.
end.
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure set-filter-name :
define input parameter p-filter-name as character no-undo .
  do with frame fr-config:
    if p-filter-name > "" then do:
      assign
        frame fr-config:title
          = frame fr-config:title + "   ФИЛЬТР: " + p-filter-name.
      .
      assign
        b-sch :tooltip = "Установлен фильтр " + p-filter-name
      .
    end.
    else do:
      assign
        b-sch :tooltip = ""
      .
    end.
  end.
end procedure.
define variable vss-include-info12 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on INS of frame fr-config anywhere do:
  if b-mark :sensitive then DO: apply "CHOOSE":U to b-mark in frame fr-config. END.
  return no-apply.
end.
define variable vss-include-info13 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F3 of frame fr-config anywhere do:
  if b-lkp :sensitive then DO: apply "CHOOSE":U to b-lkp in frame fr-config. END.
  return no-apply.
end.
define variable vss-include-info14 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F2 of frame fr-config anywhere do:
  if b-exit :sensitive then DO: apply "CHOOSE":U to b-exit in frame fr-config. END.
  return no-apply.
end.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame fr-config
do:
  run gbl/app_help.p
    (input this-procedure :file-name
    ,input ''
    ,input ?
    ) no-error.
  if error-status :error then do:
    message
      "Ошибка при вызове помощи"
      error-status :get-message(1)
      view-as alert-box .
  end.
end.
run minbtn-set in this-procedure .
on choose of b-help in frame fr-config
do:
  apply "help":u to frame fr-config .
end.
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure minbtn-set :
    do
        on error undo, return error return-value
        :
        define variable ii              as integer       no-undo .
        define variable fh              as widget-handle no-undo .
        define variable hh              as widget-handle no-undo .
        define variable v-h             as handle        extent 4 no-undo .
        define variable v-name-button   as character     no-undo .
        define variable v-help-old-x    as decimal       no-undo .
        define variable v-help-old-y    as decimal       no-undo .
        define variable v-help-old-size as decimal       no-undo .
        define variable v-frame-width   as decimal       no-undo .
        define variable jj              as integer       no-undo .
        do
            on error undo, return error
            :
            assign
                v-frame-width = frame fr-config:width - 0.3
                fh            = frame fr-config:first-child
                hh            = fh:first-child
                ii            = 1
                .
            do while valid-handle(hh):
                if LOOKUP(lc(hh:name), "b-help,b-print,b-history,b-hist,b-hist-user,b-sch") > 0  then
                do:
                    case lc(hh:name) :
                        when "b-help" then
                            do:
                                hh:load-image-up("cmp/b-help.bmp":u) .
                                hh:load-image-down("cmp/b-help.bmp":u) .
                                hh:load-image-insensitive("cmp/b-help.bmp":u) .
                                hh:TOOLTIP = "Помощь" .
                                v-help-old-x = hh:column .
                                v-help-old-y = hh:row    .
                                v-help-old-size = hh:width .
                                hh:width-chars = 2.5 .
                            end.
                        when "b-print" then
                            do:
                                hh:load-image("cmp/b-print.bmp":u) .
                                hh:TOOLTIP = "Печать" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-history" or
                        when "b-hist" then
                            do:
                                hh:load-image("cmp/b-hist.bmp":u) .
                                hh:TOOLTIP = "История" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-sch" then
                            do:
                                hh:load-image("cmp/b-sch.bmp":u) .
                                hh:TOOLTIP = "Установка Фильтра" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-hist-user" then
                            do:
                                hh:load-image("cmp/b-hist.bmp":u) .
                                hh:TOOLTIP = "История пользователя" .
                                ii = ii + 1 .
                            end.
                    end case.
                end.
                hh = hh:next-sibling.
            end.
            b-help:column = v-frame-width - b-help:width-chars.
            jj = 0.
            repeat ii = 4 to 1 by -1 :
                if valid-handle (v-h[ii] ) then
                do:
                    jj  = jj + 1 .
                    v-h[ii]:column = v-frame-width - b-help:width-chars - ( 3 * jj ).
                    v-h[ii]:row    = v-help-old-y .
                end.
            end.
        end.
    end.
end procedure.
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
define variable v-diasize-need-maximize        as logical   no-undo init true  .
define variable v-diasize-orig-frame-height    as decimal   no-undo .
define variable v-diasize-orig-frame-width     as decimal   no-undo .
define variable v-diasize-current-frame-width  as decimal   no-undo .
define variable v-diasize-current-frame-height as decimal   no-undo .
define variable v-diasize-change-size          as logical   no-undo .
define variable v-diasize-resize-button        as handle    no-undo .
define variable v-diasize-wndmax               as logical   no-undo .
define variable v-diasize-wndstore             as logical   no-undo .
define variable v-diasize-proc-name            as character no-undo .
define variable v-diasize-browse-handle        as handle    no-undo .
define variable v-diasize-browse-number        as integer   no-undo .
define variable v-diasize-need-full-display    as logical   no-undo init false .
define temp-table temp-diasize-handle no-undo
  field handle-value  as handle
  field save-position as decimal
  index xpk is primary unique handle-value
  .
define temp-table temp-browse-handle no-undo
  field browse-type   as character
  field browse-number as integer
  field browse-handle as handle
  field original-size as decimal
  index xpk is primary unique browse-type browse-number
  index xie browse-type browse-handle
.
procedure diasize_change-height :
  define input  parameter p-change-value  as decimal   no-undo .
  define input  parameter p-move-resize   as logical   no-undo .
  define variable v-field-group-handle    as handle    no-undo .
  define variable v-object-handle         as handle    no-undo .
  define variable v-frame-height          as decimal   no-undo .
  define variable v-frame-virtual-height  as decimal   no-undo .
  define variable v-browse-height         as decimal   no-undo .
  define variable v-window-height         as decimal   no-undo .
  define variable v-window-virtual-height as decimal   no-undo .
  define variable v-change-sign           as integer   no-undo .
  define buffer buf_temp-diasize-handle for temp-diasize-handle .
  define buffer buf_temp-browse-handle  for temp-browse-handle .
  if p-change-value > 0
  then do:
    if frame fr-config :height + p-change-value
        > decimal(session :work-area-height-pixels) / session :pixels-per-row
    then do:
      assign
        p-change-value = decimal(session :work-area-height-pixels) / session :pixels-per-row
                        - (frame fr-config :height-chars)
      .
      if p-change-value <= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value < 0
  then do:
    if frame fr-config :height + p-change-value < v-diasize-orig-frame-height
    then do:
      assign
        p-change-value = v-diasize-orig-frame-height
                       - (frame fr-config :height-chars)
      .
      if p-change-value >= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value >= 0
  then do:
    assign
      v-change-sign = 1
    .
  end.
  else do:
    assign
      v-change-sign = -1
    .
  end.
  assign
    p-change-value = truncate(abs(p-change-value), 0) * v-change-sign
  .
  if p-change-value = 0
  then do:
    run diasize_position-resize-button in this-procedure .
    return .
  end.
  move_block:
  do
  on error undo move_block, retry move_block
  :
    if retry
    then do:
      do
      on error undo move_block, leave move_block
      :
        if p-change-value > 0
        then do:
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :row = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          assign
            v-diasize-browse-handle :height = v-browse-height
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'height':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :height = buf_temp-browse-handle.original-size
            .
          end.
          assign
            frame fr-config :height = v-frame-height
          .
          if frame fr-config :scrollable = true
          then do:
            assign
              frame fr-config :virtual-height = v-frame-virtual-height
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame fr-config :scrollable = true
          then do:
            assign
              frame fr-config :virtual-height = v-frame-virtual-height
            .
          end.
          assign
            frame fr-config :height = v-frame-height
          .
          assign
            v-diasize-browse-handle :height = v-browse-height
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'height':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :height = buf_temp-browse-handle.original-size
            .
          end.
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :row = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        assign
          v-diasize-change-size = false
        .
        leave move_block .
      end.
    end.
    assign
      v-diasize-need-full-display = true
    .
    if v-diasize-change-size = false
    then do:
      assign
        v-diasize-change-size = true
      .
    end.
    else do:
      return .
    end.
    assign
      v-frame-height = frame fr-config :height
      v-frame-virtual-height = frame fr-config :virtual-height
      v-browse-height = v-diasize-browse-handle :height
    .
    for each buf_temp-browse-handle
      where buf_temp-browse-handle.browse-type = 'height':u
    :
      assign
        buf_temp-browse-handle.original-size = buf_temp-browse-handle.browse-handle :height
      .
    end.
    for each buf_temp-diasize-handle
    :
      delete buf_temp-diasize-handle .
    end.
    assign
      v-field-group-handle = frame fr-config :first-child
    .
    do while valid-handle(v-field-group-handle)
    :
      assign
        v-object-handle = v-field-group-handle :first-child
      .
      do while valid-handle(v-object-handle)
      :
        if  v-object-handle <> v-diasize-browse-handle :handle
        and can-query(v-object-handle, "row")
        and can-query(v-object-handle, "height")
        and ( v-object-handle :row > v-diasize-browse-handle :row )
        then do:
          find first buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type   = 'height':u
              and buf_temp-browse-handle.browse-handle = v-object-handle
            no-error .
          if available buf_temp-browse-handle
          then do:
          end.
          else do:
            create buf_temp-diasize-handle .
            assign
              buf_temp-diasize-handle.handle-value  = v-object-handle
              buf_temp-diasize-handle.save-position = v-object-handle :row
            .
          end.
        end.
        assign
          v-object-handle = v-object-handle :next-sibling
        .
      end.
      assign
        v-field-group-handle = v-field-group-handle :next-sibling
      .
    end.
    do with frame fr-config
    :
      hide v-diasize-resize-button .
      assign
        v-diasize-resize-button :row    = 1
        v-diasize-resize-button :column = 1
      .
    end.
    if p-change-value > 0
    then do:
      if frame fr-config :scrollable = true
      then do:
        assign
          frame fr-config :virtual-height = frame fr-config :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame fr-config :height = frame fr-config :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      assign
        v-diasize-browse-handle :height = v-diasize-browse-handle :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'height':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :height
            = buf_temp-browse-handle.browse-handle :height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :row = v-object-handle :row + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
    end.
    else do:
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :row = v-object-handle :row + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
      assign
        v-diasize-browse-handle :height = v-diasize-browse-handle :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'height':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :height
            = buf_temp-browse-handle.browse-handle :height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame fr-config :height = frame fr-config :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      if frame fr-config :scrollable = true
      then do:
        assign
          frame fr-config :virtual-height = frame fr-config :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
    end.
    if p-move-resize = true
    then do:
      run diasize_position-resize-button in this-procedure .
    end.
    if v-diasize-wndstore = true
    then do:
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndsizew.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  v-diasize-proc-name
          ,input  'height':u
          ,input  string(frame fr-config :height - v-diasize-orig-frame-height)
          ) .
      end.
    end.
  end.
  assign
    v-diasize-change-size = false
  .
end procedure.
procedure diasize_set-height :
  define input  parameter p-new-height  as decimal   no-undo .
  define input  parameter p-move-resize as logical   no-undo .
  do
  on error undo, return error return-value
  :
    run diasize_change-height in this-procedure
      (input  (p-new-height - frame fr-config :height)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_change-width :
  define input  parameter p-change-value as decimal   no-undo .
  define input  parameter p-move-resize  as logical   no-undo .
  define variable v-field-group-handle   as handle    no-undo .
  define variable v-object-handle        as handle    no-undo .
  define variable v-frame-width          as decimal   no-undo .
  define variable v-frame-virtual-width  as decimal   no-undo .
  define variable v-browse-width         as decimal   no-undo .
  define variable v-window-width         as decimal   no-undo .
  define variable v-window-virtual-width as decimal   no-undo .
  define variable v-change-sign          as integer   no-undo .
  define buffer buf_temp-diasize-handle for temp-diasize-handle .
  define buffer buf_temp-browse-handle  for temp-browse-handle .
  if p-change-value > 0
  then do:
    if frame fr-config :width + p-change-value >
        session :width-chars
    then do:
      assign
        p-change-value = session :width-chars - frame fr-config :width
      .
      if p-change-value <= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value < 0
  then do:
    if frame fr-config :width + p-change-value < v-diasize-orig-frame-width
    then do:
      assign
        p-change-value = v-diasize-orig-frame-width
                       - frame fr-config :width
      .
      if p-change-value >= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value >= 0
  then do:
    assign
      v-change-sign = 1
    .
  end.
  else do:
    assign
      v-change-sign = -1
    .
  end.
  assign
    p-change-value = truncate(abs(p-change-value), 0) * v-change-sign
  .
  if p-change-value = 0
  then do:
    run diasize_position-resize-button in this-procedure .
    return .
  end.
  move_block:
  do
  on error undo move_block, leave move_block
  :
    if retry
    then do:
      do
      on error undo move_block, leave move_block
      :
        if p-change-value > 0
        then do:
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :col = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          assign
            v-diasize-browse-handle :width = v-browse-width
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'width':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :width = buf_temp-browse-handle.original-size
            .
          end.
          assign
            frame fr-config :width = v-frame-width
          .
          if frame fr-config :scrollable = true
          then do:
            assign
              frame fr-config :virtual-width = v-frame-virtual-width
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame fr-config :scrollable = true
          then do:
            assign
              frame fr-config :virtual-width = v-frame-virtual-width
            .
          end.
          assign
            frame fr-config :width = v-frame-width
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'width':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :width = buf_temp-browse-handle.original-size
            .
          end.
          assign
            v-diasize-browse-handle :width = v-browse-width
          .
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :col = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        assign
          v-diasize-change-size = false
        .
        leave move_block .
      end.
    end.
    assign
      v-diasize-need-full-display = true
    .
    if v-diasize-change-size = false
    then do:
      assign
        v-diasize-change-size = true
      .
    end.
    else do:
      return .
    end.
    assign
      v-frame-width = frame fr-config :width
      v-frame-virtual-width = frame fr-config :virtual-width
      v-browse-width = v-diasize-browse-handle :width
    .
    for each buf_temp-browse-handle
      where buf_temp-browse-handle.browse-type = 'width':u
    :
      assign
        buf_temp-browse-handle.original-size = buf_temp-browse-handle.browse-handle :width
      .
    end.
    for each buf_temp-diasize-handle
    :
      delete buf_temp-diasize-handle .
    end.
    assign
      v-field-group-handle = frame fr-config :first-child
    .
    do while valid-handle(v-field-group-handle)
    :
      assign
        v-object-handle = v-field-group-handle :first-child
      .
      do while valid-handle(v-object-handle)
      :
        if  v-object-handle <> v-diasize-browse-handle :handle
        and v-object-handle <> v-diasize-resize-button
        and can-query(v-object-handle, "row")
        and can-query(v-object-handle, "height")
        and ( v-object-handle :col + v-object-handle :width
              > v-diasize-browse-handle :col + v-diasize-browse-handle :width
            )
        then do:
          find first buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type   = 'width':u
              and buf_temp-browse-handle.browse-handle = v-object-handle
            no-error .
          if available buf_temp-browse-handle
          then do:
          end.
          else do:
            create buf_temp-diasize-handle .
            assign
              buf_temp-diasize-handle.handle-value  = v-object-handle
              buf_temp-diasize-handle.save-position = v-object-handle :col
            .
          end.
        end.
        assign
          v-object-handle = v-object-handle :next-sibling
        .
      end.
      assign
        v-field-group-handle = v-field-group-handle :next-sibling
      .
    end.
    do with frame fr-config
    :
      hide v-diasize-resize-button .
      v-diasize-resize-button :row = 1.
      v-diasize-resize-button :column = 1.
    end.
    if p-change-value > 0
    then do:
      if frame fr-config :scrollable = true
      then do:
        assign
          frame fr-config :virtual-width = frame fr-config :virtual-width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
      assign
        frame fr-config :width = v-frame-width + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      assign
        v-diasize-browse-handle :width = v-browse-width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'width':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :width
            = buf_temp-browse-handle.browse-handle :width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :col = v-object-handle :col + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
    end.
    else do:
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :col = v-object-handle :col + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'width':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :width
            = buf_temp-browse-handle.browse-handle :width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        v-diasize-browse-handle :width = v-diasize-browse-handle :width + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      assign
        frame fr-config :width = frame fr-config :width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      if frame fr-config :scrollable = true
      then do:
        assign
          frame fr-config :virtual-width = frame fr-config :virtual-width + p-change-value
        no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
    end.
    if p-move-resize
    then do:
      run diasize_position-resize-button in this-procedure .
    end.
    if v-diasize-wndstore = true
    then do:
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndsizew.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  v-diasize-proc-name
          ,input  'width':u
          ,input  string(frame fr-config :width - v-diasize-orig-frame-width)
          ) .
      end.
    end.
  end.
  assign
    v-diasize-change-size = false
  .
end procedure.
procedure diasize_set-width :
  define input  parameter p-new-width  as decimal   no-undo .
  define input  parameter p-move-resize as logical   no-undo .
  do
  on error undo, return error return-value
  :
    run diasize_change-width in this-procedure
      (input  (p-new-width - frame fr-config :width)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_position-resize-button :
  do with frame fr-config
  :
    hide v-diasize-resize-button .
    assign
      v-diasize-resize-button :row = frame fr-config :height - v-diasize-resize-button :height
                  - 1
                  - (frame fr-config :border-bottom-pixels / session :pixels-per-row)
      v-diasize-resize-button :col = frame fr-config :width - v-diasize-resize-button :width
                  - 1
                  - (frame fr-config :border-right-pixels / session :pixels-per-column)
    .
    view v-diasize-resize-button .
  end.
end procedure.
on alt-right anywhere
do:
  run diasize_change-width in this-procedure
    (input 1
    ,input true
    ) .
  return no-apply .
end.
on alt-left anywhere
do:
  run diasize_change-width in this-procedure
    (input -1
    ,input true
    ) .
  return no-apply .
end.
on alt-down anywhere
do:
  run diasize_change-height in this-procedure
    (input 1
    ,input true
    ) .
  return no-apply .
end.
on alt-up anywhere
do:
  run diasize_change-height in this-procedure
    (input -1
    ,input true
    ) .
  return no-apply .
end.
on alt-enter of frame fr-config
do:
  run diasize_maximize in this-procedure
    (input  ?
    ).
  return no-apply .
end.
procedure diasize_end-move :
  do
  on error undo, return error return-value
  :
    define variable v-row-delta as decimal   no-undo .
    define variable v-col-delta as decimal   no-undo .
    define variable v-new-row as decimal   no-undo .
    define variable v-new-col as decimal   no-undo .
    assign
      v-new-row = decimal(last-event :y) / (session :pixels-per-row)
      v-new-col = decimal(last-event :x) / (session :pixels-per-column)
    .
    assign
      v-row-delta = v-new-row - frame fr-config :height
      v-col-delta = v-new-col - frame fr-config :width
    .
    run diasize_change-height in this-procedure
      (input v-row-delta
      ,input true
      ) .
    run diasize_change-width in this-procedure
      (input v-col-delta
      ,input true
      ) .
  end.
end procedure.
procedure diasize_maximize :
  define input  parameter p-action as logical   no-undo .
  do
  on error undo, return error return-value
  :
    if p-action = ?
    then do:
      if v-diasize-need-maximize = true
      then do:
        assign
          p-action = true
        .
      end.
      else do:
        assign
          p-action = false
        .
      end.
    end.
    if p-action = true
    then do:
      run diasize_change-height in this-procedure
        (input decimal(session :work-area-height-pixels) / session :pixels-per-row
            - frame fr-config :height-chars
        ,input true
        ) .
      run diasize_change-width in this-procedure
        (input session :width-chars
            - frame fr-config :width-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = false
      .
    end.
    else do:
      run diasize_change-width in this-procedure
        (input v-diasize-orig-frame-width
            - frame fr-config :width-chars
        ,input true
        ) .
      run diasize_change-height in this-procedure
        (input v-diasize-orig-frame-height
            - frame fr-config :height-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = true
      .
    end.
  end.
end procedure.
procedure diasize_restore-orig-size :
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-current-frame-width  = frame fr-config :width
      v-diasize-current-frame-height = frame fr-config :height
    .
    run diasize_set-height in this-procedure
      (input  v-diasize-orig-frame-height
      ,input  true
      ) .
    run diasize_set-width in this-procedure
      (input  v-diasize-orig-frame-width
      ,input  true
      ) .
  end.
end procedure.
procedure diasize_restore-current-size :
  do
  on error undo, return error return-value
  :
    run diasize_set-height in this-procedure
      (input  v-diasize-current-frame-height
      ,input  true
      ) .
    run diasize_set-width in this-procedure
      (input  v-diasize-current-frame-width
      ,input  true
      ) .
  end.
end procedure.
procedure diasize_set-browse-handle :
  define input  parameter p-browse-handle as handle   no-undo .
  define buffer buf_temp-browse-handle for temp-browse-handle .
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-browse-handle = p-browse-handle
    .
    for each buf_temp-browse-handle
    on error undo, return error return-value
    :
      delete buf_temp-browse-handle .
    end.
  end.
end procedure.
procedure diasize_add_browse :
  define input  parameter p-browse-type   as character no-undo .
  define input  parameter p-browse-handle as handle    no-undo .
  define buffer buf_temp-browse-handle for temp-browse-handle .
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-browse-number = v-diasize-browse-number + 1
    .
    create buf_temp-browse-handle .
    assign
      buf_temp-browse-handle.browse-type   = p-browse-type
      buf_temp-browse-handle.browse-number = v-diasize-browse-number
      buf_temp-browse-handle.browse-handle = p-browse-handle
    .
  end.
end procedure.
procedure diasize_init :
  define variable v-default-value    as logical   no-undo .
  define variable v-restore-saved    as logical   no-undo .
  define variable v-resize-value-str as character no-undo .
  do
  on error undo, return error return-value
  :
    do with frame fr-config
    :
      assign
        v-diasize-orig-frame-height = frame fr-config :height
        v-diasize-orig-frame-width  = frame fr-config :width
        v-diasize-browse-handle     = browse br-config :handle
      .
      create button v-diasize-resize-button
      assign
        parent        = frame fr-config :first-child
        label         = "s"
        height-pixels = 16
        width-pixels  = 16
        visible       = true
        sensitive     = true
        movable       = true
        triggers:
          on end-move persistent run diasize_end-move in this-procedure .
        end triggers.
      v-diasize-resize-button :load-mouse-pointer("SIZE") .
      v-diasize-resize-button :load-image("exe/grip.bmp":U) .
      v-diasize-resize-button :load-image-down("exe/grip.bmp":U) .
      v-diasize-resize-button :load-image-insensitive("exe/grip.bmp":U) .
      assign
        v-diasize-wndmax = false
      .
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndpar_r.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  'wndmax':U
          ,output v-diasize-wndmax
          ,output v-default-value
          ) .
      end.
      assign
        v-diasize-wndstore = false
      .
      if connected("ub") = true
      then do:
        run gbl/wndpar_r.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  'wndstore':U
          ,output v-diasize-wndstore
          ,output v-default-value
          ) .
      end.
      assign
        v-diasize-proc-name = entry(1, program-name(2), '.')
      .
      if v-diasize-wndstore = true
      then do:
        assign
          v-restore-saved = false
        .
        if connected("ub") = true
        then do:
          run gbl/wndsizer.p
            (input  v-cntxt-db-num
            ,input  v-cntxt-userid
            ,input  v-diasize-proc-name
            ,input  'height':u
            ,output v-resize-value-str
            ) .
          if v-resize-value-str <> '':U
          then do:
            run diasize_change-height in this-procedure
              (input  integer(v-resize-value-str)
              ,input  true
              ) .
            assign
              v-restore-saved = true
            .
          end.
        end.
        if connected("ub") = true
        then do:
          run gbl/wndsizer.p
            (input  v-cntxt-db-num
            ,input  v-cntxt-userid
            ,input  v-diasize-proc-name
            ,input  'width':u
            ,output v-resize-value-str
            ) .
          if v-resize-value-str <> '':U
          then do:
            run diasize_change-width in this-procedure
              (input  integer(v-resize-value-str)
              ,input  true
              ) .
            assign
              v-restore-saved = true
            .
          end.
        end.
        if v-restore-saved <> true
        then do:
          if v-diasize-wndmax = true
          then do:
            run diasize_maximize in this-procedure
              (input  true
              ) .
          end.
        end.
      end.
      else do:
        if v-diasize-wndmax = true
        then do:
          run diasize_maximize in this-procedure
            (input  true
            ) .
        end.
      end.
    end.
  end.
end procedure.
procedure diasize_need-full-display :
  define output parameter p-need-full-display as logical   no-undo .
  do
  on error undo, return error return-value
  :
    assign
      p-need-full-display = v-diasize-need-full-display
    .
    assign
      v-diasize-need-full-display = false
    .
  end.
end procedure.
procedure get-context :
   define output parameter p-db-num as integer          no-undo.
   define output parameter p-user-id as character        no-undo.
   define variable v-login               as character    no-undo.
   define buffer buf_sys-ctrl    for ub.sys-ctrl .
   define buffer buf_user-login  for ub.user-login .
   do
   on error undo, return error
   :
         FIND FIRST buf_sys-ctrl no-lock.
         ASSIGN
            v-login = USERID("ub")
            p-db-num = buf_sys-ctrl.db-num
         .
         FIND FIRST buf_user-login
              WHERE buf_user-login.db-num = p-db-num
                AND buf_user-login.user-login = v-login
              no-lock
              no-error
              .
         IF AVAILABLE buf_user-login
         THEN DO:
            assign
               p-user-id = buf_user-login.user-id
            .
         END.
   end.
end procedure.
    run diasize_init in this-procedure .
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  define variable par-type as character         no-undo .
  define variable ErrExist as integer initial 0 no-undo.
  define variable v-log    as logical           no-undo .
    define buffer buf_sys-ctrl for ub.sys-ctrl .
  run waitfram-show in this-procedure ("Чтение схемы конфигурации").
  run init in cnf-hdl
    ( input ""
    , input no
    , input no
    ) no-error.
  if error-status:error then do:
    message
      vss-workfile vss-revision vss-description skip
      substitute( "Ошибка при старте init in cnf-hdl" ) skip
      return-value skip
      error-status :get-message ( error-status :num-messages )
      view-as alert-box error
    .
    run waitfram-hide in this-procedure .
    return error.
  end.
  if return-value <> "" then do:
    assign
      ErrExist = max(integer (return-value), ErrExist)
    .
  end.
    run init in db-hdl
      ( input cnf-hdl
      ) no-error.
    if error-status:error then do:
      message
        vss-workfile vss-revision vss-description skip
        substitute( "Ошибка при старте init in db-hdl" ) skip
        return-value skip
        error-status :get-message ( error-status :num-messages )
        view-as alert-box error
      .
      run waitfram-hide in this-procedure .
      return error.
    end.
    if return-value <> "" then do:
      assign
        ErrExist = max(integer (return-value), ErrExist)
      .
    end.
  run init in CurCnf-hdl
    ( input cnf-hdl
    , input db-hdl
    ) no-error.
  if error-status:error then do:
    message
      vss-workfile vss-revision vss-description skip
      substitute( "Ошибка при старте init in CurCnf-hdl" ) skip
      return-value skip
      error-status :get-message ( error-status :num-messages )
      view-as alert-box error
    .
    run waitfram-hide in this-procedure .
    return error.
  end.
  if return-value <> "" then do:
    assign
      ErrExist = max(integer (return-value), ErrExist)
    .
  end.
  run fill-cnf-struct in this-procedure
    ( input "cmp/mold_db.sch"
    ) no-error.
  if error-status:error then do:
    message
      vss-workfile vss-revision vss-description skip
      substitute( "Ошибка при старте fill-cnf-struct" ) skip
      return-value skip
      error-status :get-message ( error-status :num-messages )
      view-as alert-box error
    .
    run waitfram-hide in this-procedure .
    return error.
  end.
  if return-value <> "" then do:
    assign
      ErrExist = max(integer (return-value), ErrExist)
    .
  end.
  find first buf_sys-ctrl no-lock .
  find first buf-curr_db no-lock
    where buf-curr_db.db-num = buf_sys-ctrl.db-num
    no-error.
  if not available buf-curr_db then do:
    message
      "Ошибка при чтении списка баз данных" skip
      view-as alert-box error .
    undo, return error .
  end.
  assign
    v-title0 = substitute( "&1 (Текущая БД &2, ключ &3)", v-title0, buf-curr_db.db-num, buf-curr_db.db-key )
  .
  run LoadDB in db-hdl
    no-error.
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      substitute("Ошибка при чтении параметров из БД") skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    run waitfram-hide in this-procedure .
    return error.
  end.
  if return-value <> "" then do:
    assign
      ErrExist = max(integer (return-value), ErrExist)
    .
  end.
  run chk-unref in curcnf-hdl
    ( input ?
    , input ?
    , input ?
    , input false
    ) no-error.
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      substitute("Ошибка при создании недостающих параметров") skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    run waitfram-hide in this-procedure .
    return error.
  end.
  run waitfram-hide in this-procedure .
  if ErrExist > 0 then do:
    message
      substitute("При загрузке параметров были ошибки.") skip
      substitute("Проверьте протокол работы.") skip
      view-as alert-box error .
  end.
  run enable_UI in this-procedure .
  apply "value-changed":u to r-find-in-br in frame fr-config .
  run reopen-query in this-procedure
    ( input true
    , input false
    , input '':U
    ) .
  assign
    Cnf.Param-Name:resizable in browse br-config = true
    Cnf.Param-Name:width in browse br-config = 30
    Cnf.Param-Value:resizable in browse br-config  = true
    Cnf.Param-Value:width in browse br-config = 30
  .
  run toggle-mes in cnf-hdl
    ( input true
    ).
    assign
      b-save:sensitive in frame fr-config = true
    .
  wait-for go of frame fr-config.
end.
run disable_UI in this-procedure .
run kill in cnf-hdl.
run kill in curcnf-hdl.
  run kill in db-hdl.
for each cnf
:
  delete cnf .
end.
for each cnf-struct
:
  delete cnf-struct .
end.
PROCEDURE chg-param :
  define input parameter p-rid         as integer   no-undo .
  define input parameter p-turn-on-off as logical   no-undo .
  chg-block:
  do transaction
  on error  undo chg-block, return error substitute( "&1 (chg-param). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo chg-block, return error substitute( "&1 (chg-param). stop", vss-workfile )
  on endkey undo chg-block, return error substitute( "&1 (chg-param). endkey", vss-workfile )
  :
    define buffer buf_cnf      for cnf .
    define buffer buf-chg_cnf  for cnf .
    define buffer buf-all_cnf  for cnf .
    define buffer buf-next_cnf for cnf .
    define variable v-log           as logical   no-undo .
    define variable v-chg-db-num    as logical   no-undo .
    define variable v-chg-key       as logical   no-undo .
    define variable v-old-db-num    as integer   no-undo .
    define variable v-old-db-key    as character no-undo .
    find first buf_cnf
      where recid( buf_cnf ) = p-rid
      no-error .
    if not available buf_cnf then do:
      return .
    end.
    if p-turn-on-off = true
      and buf_cnf.NotUsed = false
    then do:
      assign
        buf_cnf.NotUsed = true
      .
    end.
    else do:
      if buf_cnf.db-num = ? then do:
        create buf-chg_cnf .
        buffer-copy buf_cnf to buf-chg_cnf .
        assign
          p-rid = recid( buf-chg_cnf )
        .
      end.
      else do:
        find first buf-chg_cnf
          where recid( buf-chg_cnf ) = p-rid
          .
      end.
      for each tt_cnf
      :
        delete tt_cnf .
      end.
      create tt_cnf .
      buffer-copy buf-chg_cnf to tt_cnf .
      assign
        v-old-db-num = buf-chg_cnf.db-num
        v-old-db-key = buf-chg_cnf.db-key
      .
        run adm/cnfi.w (parparentproc, curcnf-hdl, db-hdl, cnf-hdl, "edit":U, input-output p-rid).
      buffer-compare tt_cnf except is-changed to buf-chg_cnf save result in v-log .
      if tt_cnf.host-code = 0
        and tt_cnf.obj-type = "":U
        and tt_cnf.obj-code = 0
        and tt_cnf.beg-date = 01/01/1900
        and tt_cnf.end-date = 01/01/9999
        and ( tt_cnf.host-code <> buf-chg_cnf.host-code
              or tt_cnf.obj-type <> buf-chg_cnf.obj-type
              or tt_cnf.obj-code <> buf-chg_cnf.obj-code
              or tt_cnf.beg-date <> buf-chg_cnf.beg-date
              or tt_cnf.end-date <> buf-chg_cnf.end-date
              or tt_cnf.db-num   <> buf-chg_cnf.db-num
            )
      then do:
        create buf_cnf .
        buffer-copy tt_cnf to buf_cnf .
      end.
      for each tt_cnf
      :
        delete tt_cnf .
      end.
      if p-rid = ?
        or ( p-rid <> ?
             and p-rid > 0
             and v-log = true
           )
      then do:
        undo chg-block, return .
      end.
      if p-rid = -1
        and available buf-chg_cnf
      then do:
        delete buf-chg_cnf.
      end.
      if available buf-chg_cnf then do:
        run chk-param in curcnf-hdl
          ( buffer buf-chg_cnf
          ).
        assign
          buf-chg_cnf.errorexist = 0
          buf-chg_cnf.is-changed = true
        .
      end.
    end.
  end.
  if available buf-chg_cnf then do:
    assign
      v-cnf-rec = recid( buf-chg_cnf )
    .
  end.
  run reopen-query in this-procedure
    ( input true
    , input false
    , input '':U
    ) .
  reposition br-config to recid v-cnf-rec no-error .
  assign
    v-cnf-rec = ?
  .
  return.
END PROCEDURE.
PROCEDURE chk-param :
  define parameter buffer b-cnf for cnf.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME fr-config.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY r-show-cnf r-cnf-encoded r-cnf-db r-find-in-br sch-param f-param-name
      WITH FRAME fr-config.
  ENABLE b-exit b-mark b-lkp b-chg b-Tgle b-Exp b-Imp b-Log b-sch b-hist b-help
         r-show-cnf r-cnf-encoded r-cnf-db r-find-in-br sch-param br-config
         f-param-name
      WITH FRAME fr-config.
END PROCEDURE.
PROCEDURE find-param :
  define input  parameter p-find-next as logical   no-undo .
  define input  parameter p-sch-type  as character no-undo .
  define input  parameter p-sch-code  as character no-undo .
  define variable v-add-where as character no-undo .
  assign
    p-sch-code = replace( p-sch-code, chr(39), chr(39) + chr(39) )
  .
  case p-sch-type :
    when "param-code":U then do:
      assign
        v-add-where = substitute("and cnf.param-code begins &1&2&1", chr(34), p-sch-code)
      .
    end.
    when "param-name":U then do:
      assign
        v-add-where = substitute("and cnf.param-name contains &1&2&1", chr(34), p-sch-code)
      .
    end.
    when "param-vale":U then do:
      assign
        v-add-where = substitute("and cnf.param-name contains &1&2&1", chr(34), p-sch-code)
      .
    end.
  end case.
  run reopen-query in this-procedure
    ( input false
    , input p-find-next
    , input v-add-where
    ) .
  apply "entry":u to sch-param in frame fr-config .
END PROCEDURE.
PROCEDURE proc-b-sch :
assign
  tbl = substitute( "temp-handle#cnf#&1", buffer cnf:handle ) + chr(44) + substitute( "temp-handle#cnf-struct#&1", buffer cnf-struct:handle )
  join-tbl = 'cnf,cnf-struct':U
  fld = ""
  lab = ""
  spr = ""
  dim = '0'
  .
run fltfield-add in this-procedure('NotUsed'    , '', ''    , input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('Is-Changed' , '', ''    , input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('param-code' , '', ''    , input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('param-name' , '', ''    , input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('db-num'     , '', 'db'  , input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('host-code'  , '', 'cli' , input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ('obj-type*obj-code', 'Объект', 'cli',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('beg-date'   , '', 'date', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('end-date'   , '', 'date', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('param-value', '', ''    , input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
assign
  dim = dim + chr(44)
.
run fltfield-add in this-procedure('list-value', 'Возможные значения', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('default-value', 'Значение по умолчанию', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
Filter-Block:
DO ON STOP    UNDO Filter-Block, LEAVE Filter-Block
    ON ERROR   UNDO Filter-Block, LEAVE Filter-Block
    ON END-KEY UNDO Filter-Block, LEAVE Filter-Block :
  run gbl/filter.w ( INPUT parparentproc, INPUT v-filter-point, INPUT tbl, INPUT join-tbl, INPUT fld, INPUT lab, INPUT spr, INPUT dim ).
  run reopen-query in this-procedure
    ( input true
    , input false
    , input '':U
    ) .
END.
END PROCEDURE.
PROCEDURE reopen-query :
  define input  parameter p-open-query     as logical   no-undo .
  define input  parameter p-find-next      as logical   no-undo .
  define input  parameter p-find-condition as character no-undo .
  define variable l-query-was-opened   as logical   no-undo .
  define variable v-sort-column-phrase as character no-undo .
  run waitfram-show in this-procedure ( input "Ждите...").
  case v-sort-column-name :
    when "" then do:
      assign
        v-sort-column-phrase = "":U
      .
    end.
    otherwise do:
      assign
        v-sort-column-phrase = substitute( "by &1", v-sort-column-name )
      .
    end.
  end case.
  assign
    v-filter-point = v-filter-point0 + chr(4) + v-filter-pointr
    frame fr-config:title = substitute( "&1", v-title0 )
  .
  case r-show-cnf :
    when "all":U then do:
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-19  as logical   no-undo .
define variable  l-filter-open-19    as logical   .
define variable  flt-rec-19       as recid     no-undo .
define variable  filter-name-19      as character no-undo .
define variable  where-phrase-19     as character no-undo .
define variable  sort-phrase-19      as character no-undo .
define variable  where-phrase-rus-19 as character no-undo .
define variable  sort-phrase-rus-19  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input v-filter-point
  ,output flt-rec-19
  ,output filter-name-19
  ,output where-phrase-19
  ,output sort-phrase-19
  ,output where-phrase-rus-19
  ,output sort-phrase-rus-19
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-19
      ) no-error .
  assign
    l-filter-open-19 = false
  .
  if flt-rec-19 <> ?
    or v-sort-column-phrase > ""
  then do:
    define variable  parameter-2-19 as character no-undo .
    define variable  parameter-3-19 as character no-undo .
    define variable  parameter-4-19 as character no-undo .
    define variable  parameter-5-19 as character no-undo .
    define variable  parameter-6-19 as character no-undo .
    define variable  parameter-7-19 as character no-undo .
      assign
      parameter-3-19 =
                              "FOR EACH cnf"
      parameter-4-19 =
        (
          if ("                            ( r-cnf-encoded = 'all':U                              or ( t-cnf-type-k = true      and cnf.conf-type = 'к':U )                              or ( t-cnf-type-s = true      and cnf.conf-type = 'п':U )                              or ( t-cnf-type-o = true      and cnf.conf-type = 'о':U )                              or ( t-cnf-type-notenc = true and cnf.conf-type = '':U       )                            )                            and
                           ( r-cnf-db = 'all':U                              or ( r-cnf-db <> 'all':U and cnf.db-num = f-db-num )                            )                           " + " " + where-phrase-19) <> ""
          then substitute( '( &2                                               or ( &3 and cnf.conf-type = &1к&1 )                                               or ( &4 and cnf.conf-type = &1п&1 )                                               or ( &5 and cnf.conf-type = &1о&1 )                                               or ( &6 and cnf.conf-type = &1&1   )                                             )                                         and                                          (  &1&7&1                                            or ( not &7 and cnf.db-num = &1&8&1 )                                          )'                                         ,chr(34)                                         ,r-cnf-encoded = 'all':U                                         ,t-cnf-type-k = true                                         ,t-cnf-type-s = true                                         ,t-cnf-type-o = true                                         ,t-cnf-type-notenc = true                                         ,r-cnf-db ='all':U                                         ,f-db-num                                      )                            + " " + where-phrase-19
          else "true"
        )
      parameter-5-19 = (" " + "" + " " + substitute(', first cnf-struct no-lock where cnf-struct.param-code = cnf.param-code' ))
      parameter-6-19 = if sort-phrase-19 = ''
                           then
        (
        " " + " " +
          " " + v-sort-column-phrase +
        " " + " "
        )
                           else
        (
        " " + " " +
          " " + v-sort-column-phrase +
        " " + sort-phrase-19
        )
      parameter-7-19 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-19 =
          ("                            ( r-cnf-encoded = 'all':U                              or ( t-cnf-type-k = true      and cnf.conf-type = 'к':U )                              or ( t-cnf-type-s = true      and cnf.conf-type = 'п':U )                              or ( t-cnf-type-o = true      and cnf.conf-type = 'о':U )                              or ( t-cnf-type-notenc = true and cnf.conf-type = '':U       )                            )                            and
                           ( r-cnf-db = 'all':U                              or ( r-cnf-db <> 'all':U and cnf.db-num = f-db-num )                            )                           " + " " + where-phrase-19 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-config :handle
                          ,input parameter-3-19
                          ,input parameter-4-19
                          ,input parameter-5-19
                          ,input parameter-6-19
                          ,input parameter-7-19
                          )
      .
      assign
        l-filter-open-19 = true
      .
    end.
    if l-filter-open-19 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
        assign
          l-query-was-opened = true
        .
    end.
  end.
  if l-filter-open-19 = false then do:
    OPEN QUERY br-config FOR EACH cnf
      where                             ( r-cnf-encoded = 'all':U                              or ( t-cnf-type-k = true      and cnf.conf-type = 'к':U )                              or ( t-cnf-type-s = true      and cnf.conf-type = 'п':U )                              or ( t-cnf-type-o = true      and cnf.conf-type = 'о':U )                              or ( t-cnf-type-notenc = true and cnf.conf-type = '':U       )                            )                            and
                           ( r-cnf-db = 'all':U                              or ( r-cnf-db <> 'all':U and cnf.db-num = f-db-num )                            )
    , first cnf-struct no-lock where cnf-struct.param-code = cnf.param-code
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-cnf-rec = recid( cnf )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-config :handle:get-buffer-handle(1) = (buffer cnf:handle) then do:
      assign
      parameter-2-19 = (if p-find-next then "true":u else "false":u )
      parameter-4-19 =
        "where ":u + substitute( '( &2                                               or ( &3 and cnf.conf-type = &1к&1 )                                               or ( &4 and cnf.conf-type = &1п&1 )                                               or ( &5 and cnf.conf-type = &1о&1 )                                               or ( &6 and cnf.conf-type = &1&1   )                                             )                                         and                                          (  &1&7&1                                            or ( not &7 and cnf.db-num = &1&8&1 )                                          )'                                         ,chr(34)                                         ,r-cnf-encoded = 'all':U                                         ,t-cnf-type-k = true                                         ,t-cnf-type-s = true                                         ,t-cnf-type-o = true                                         ,t-cnf-type-notenc = true                                         ,r-cnf-db ='all':U                                         ,f-db-num                                      )                            + " ":u + where-phrase-19 + " ":u + p-find-condition + " " + ""
      parameter-5-19 = " "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-config :handle
                          ,input rowid(cnf)
                          ,input logical(parameter-2-19)
                          ,input no-lock
                          ,input (buffer cnf:handle)
                          ,input parameter-4-19
                          ,input parameter-5-19
                          ) no-error.
      .
      assign
        v-cnf-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-19 = (if p-find-next then "true":u else "false":u )
      parameter-3-19 =  "FOR EACH cnf"
      parameter-4-19 =
        (
          if ("                            ( r-cnf-encoded = 'all':U                              or ( t-cnf-type-k = true      and cnf.conf-type = 'к':U )                              or ( t-cnf-type-s = true      and cnf.conf-type = 'п':U )                              or ( t-cnf-type-o = true      and cnf.conf-type = 'о':U )                              or ( t-cnf-type-notenc = true and cnf.conf-type = '':U       )                            )                            and
                           ( r-cnf-db = 'all':U                              or ( r-cnf-db <> 'all':U and cnf.db-num = f-db-num )                            )                           " + " " + where-phrase-19) <> ""
          then substitute( '( &2                                               or ( &3 and cnf.conf-type = &1к&1 )                                               or ( &4 and cnf.conf-type = &1п&1 )                                               or ( &5 and cnf.conf-type = &1о&1 )                                               or ( &6 and cnf.conf-type = &1&1   )                                             )                                         and                                          (  &1&7&1                                            or ( not &7 and cnf.db-num = &1&8&1 )                                          )'                                         ,chr(34)                                         ,r-cnf-encoded = 'all':U                                         ,t-cnf-type-k = true                                         ,t-cnf-type-s = true                                         ,t-cnf-type-o = true                                         ,t-cnf-type-notenc = true                                         ,r-cnf-db ='all':U                                         ,f-db-num                                      )                            + " " + where-phrase-19
          else "true"
        )
      parameter-5-19 = (" " + "" + " " + substitute(', first cnf-struct no-lock where cnf-struct.param-code = cnf.param-code' ) + " " + p-find-condition)
      parameter-6-19 = if sort-phrase-19 = ''
                           then
        (
        " " + " " +
          " " + v-sort-column-phrase +
        " " + " "
        )
                           else
        (
        " " + " " +
          " " + v-sort-column-phrase +
        " " + sort-phrase-19
        )
      parameter-7-19 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-config :handle
                          ,input logical(parameter-2-19)
                          ,input no-lock
                          ,input parameter-3-19
                          ,input parameter-4-19
                          ,input parameter-5-19
                          ,input parameter-6-19
                          ,input parameter-7-19
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      v-cnf-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
    end.
    when "used":U then do:
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-21  as logical   no-undo .
define variable  l-filter-open-21    as logical   .
define variable  flt-rec-21       as recid     no-undo .
define variable  filter-name-21      as character no-undo .
define variable  where-phrase-21     as character no-undo .
define variable  sort-phrase-21      as character no-undo .
define variable  where-phrase-rus-21 as character no-undo .
define variable  sort-phrase-rus-21  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input v-filter-point
  ,output flt-rec-21
  ,output filter-name-21
  ,output where-phrase-21
  ,output sort-phrase-21
  ,output where-phrase-rus-21
  ,output sort-phrase-rus-21
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-21
      ) no-error .
  assign
    l-filter-open-21 = false
  .
  if flt-rec-21 <> ?
    or v-sort-column-phrase > ""
  then do:
    define variable  parameter-2-21 as character no-undo .
    define variable  parameter-3-21 as character no-undo .
    define variable  parameter-4-21 as character no-undo .
    define variable  parameter-5-21 as character no-undo .
    define variable  parameter-6-21 as character no-undo .
    define variable  parameter-7-21 as character no-undo .
      assign
      parameter-3-21 =
                              "FOR EACH cnf"
      parameter-4-21 =
        (
          if ("cnf.notused = false                            and                            ( r-cnf-encoded = 'all':U                              or ( t-cnf-type-k = true      and cnf.conf-type = 'к':U )                              or ( t-cnf-type-s = true      and cnf.conf-type = 'п':U )                              or ( t-cnf-type-o = true      and cnf.conf-type = 'о':U )                              or ( t-cnf-type-notenc = true and cnf.conf-type = '':U       )                            )                            and
                           ( r-cnf-db = 'all':U                              or ( r-cnf-db <> 'all':U and cnf.db-num = f-db-num )                            )                           " + " " + where-phrase-21) <> ""
          then substitute( 'cnf.notused = false                                         and ( &2                                               or ( &3 and cnf.conf-type = &1к&1 )                                               or ( &4 and cnf.conf-type = &1п&1 )                                               or ( &5 and cnf.conf-type = &1о&1 )                                               or ( &6 and cnf.conf-type = &1&1   )                                             )                                         and                                          (  &1&7&1                                            or ( not &7 and cnf.db-num = &1&8&1 )                                          )'                                         ,chr(34)                                         ,r-cnf-encoded = 'all':U                                         ,t-cnf-type-k = true                                         ,t-cnf-type-s = true                                         ,t-cnf-type-o = true                                         ,t-cnf-type-notenc = true                                         ,r-cnf-db ='all':U                                         ,f-db-num                                      )                            + " " + where-phrase-21
          else "true"
        )
      parameter-5-21 = (" " + "" + " " + substitute(', first cnf-struct no-lock where cnf-struct.param-code = cnf.param-code' ))
      parameter-6-21 = if sort-phrase-21 = ''
                           then
        (
        " " + " " +
          " " + v-sort-column-phrase +
        " " + " "
        )
                           else
        (
        " " + " " +
          " " + v-sort-column-phrase +
        " " + sort-phrase-21
        )
      parameter-7-21 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-21 =
          ("cnf.notused = false                            and                            ( r-cnf-encoded = 'all':U                              or ( t-cnf-type-k = true      and cnf.conf-type = 'к':U )                              or ( t-cnf-type-s = true      and cnf.conf-type = 'п':U )                              or ( t-cnf-type-o = true      and cnf.conf-type = 'о':U )                              or ( t-cnf-type-notenc = true and cnf.conf-type = '':U       )                            )                            and
                           ( r-cnf-db = 'all':U                              or ( r-cnf-db <> 'all':U and cnf.db-num = f-db-num )                            )                           " + " " + where-phrase-21 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-config :handle
                          ,input parameter-3-21
                          ,input parameter-4-21
                          ,input parameter-5-21
                          ,input parameter-6-21
                          ,input parameter-7-21
                          )
      .
      assign
        l-filter-open-21 = true
      .
    end.
    if l-filter-open-21 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
        assign
          l-query-was-opened = true
        .
    end.
  end.
  if l-filter-open-21 = false then do:
    OPEN QUERY br-config FOR EACH cnf
      where cnf.notused = false                            and                            ( r-cnf-encoded = 'all':U                              or ( t-cnf-type-k = true      and cnf.conf-type = 'к':U )                              or ( t-cnf-type-s = true      and cnf.conf-type = 'п':U )                              or ( t-cnf-type-o = true      and cnf.conf-type = 'о':U )                              or ( t-cnf-type-notenc = true and cnf.conf-type = '':U       )                            )                            and
                           ( r-cnf-db = 'all':U                              or ( r-cnf-db <> 'all':U and cnf.db-num = f-db-num )                            )
    , first cnf-struct no-lock where cnf-struct.param-code = cnf.param-code
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-cnf-rec = recid( cnf )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-config :handle:get-buffer-handle(1) = (buffer cnf:handle) then do:
      assign
      parameter-2-21 = (if p-find-next then "true":u else "false":u )
      parameter-4-21 =
        "where ":u + substitute( 'cnf.notused = false                                         and ( &2                                               or ( &3 and cnf.conf-type = &1к&1 )                                               or ( &4 and cnf.conf-type = &1п&1 )                                               or ( &5 and cnf.conf-type = &1о&1 )                                               or ( &6 and cnf.conf-type = &1&1   )                                             )                                         and                                          (  &1&7&1                                            or ( not &7 and cnf.db-num = &1&8&1 )                                          )'                                         ,chr(34)                                         ,r-cnf-encoded = 'all':U                                         ,t-cnf-type-k = true                                         ,t-cnf-type-s = true                                         ,t-cnf-type-o = true                                         ,t-cnf-type-notenc = true                                         ,r-cnf-db ='all':U                                         ,f-db-num                                      )                            + " ":u + where-phrase-21 + " ":u + p-find-condition + " " + ""
      parameter-5-21 = " "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-config :handle
                          ,input rowid(cnf)
                          ,input logical(parameter-2-21)
                          ,input no-lock
                          ,input (buffer cnf:handle)
                          ,input parameter-4-21
                          ,input parameter-5-21
                          ) no-error.
      .
      assign
        v-cnf-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-21 = (if p-find-next then "true":u else "false":u )
      parameter-3-21 =  "FOR EACH cnf"
      parameter-4-21 =
        (
          if ("cnf.notused = false                            and                            ( r-cnf-encoded = 'all':U                              or ( t-cnf-type-k = true      and cnf.conf-type = 'к':U )                              or ( t-cnf-type-s = true      and cnf.conf-type = 'п':U )                              or ( t-cnf-type-o = true      and cnf.conf-type = 'о':U )                              or ( t-cnf-type-notenc = true and cnf.conf-type = '':U       )                            )                            and
                           ( r-cnf-db = 'all':U                              or ( r-cnf-db <> 'all':U and cnf.db-num = f-db-num )                            )                           " + " " + where-phrase-21) <> ""
          then substitute( 'cnf.notused = false                                         and ( &2                                               or ( &3 and cnf.conf-type = &1к&1 )                                               or ( &4 and cnf.conf-type = &1п&1 )                                               or ( &5 and cnf.conf-type = &1о&1 )                                               or ( &6 and cnf.conf-type = &1&1   )                                             )                                         and                                          (  &1&7&1                                            or ( not &7 and cnf.db-num = &1&8&1 )                                          )'                                         ,chr(34)                                         ,r-cnf-encoded = 'all':U                                         ,t-cnf-type-k = true                                         ,t-cnf-type-s = true                                         ,t-cnf-type-o = true                                         ,t-cnf-type-notenc = true                                         ,r-cnf-db ='all':U                                         ,f-db-num                                      )                            + " " + where-phrase-21
          else "true"
        )
      parameter-5-21 = (" " + "" + " " + substitute(', first cnf-struct no-lock where cnf-struct.param-code = cnf.param-code' ) + " " + p-find-condition)
      parameter-6-21 = if sort-phrase-21 = ''
                           then
        (
        " " + " " +
          " " + v-sort-column-phrase +
        " " + " "
        )
                           else
        (
        " " + " " +
          " " + v-sort-column-phrase +
        " " + sort-phrase-21
        )
      parameter-7-21 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-config :handle
                          ,input logical(parameter-2-21)
                          ,input no-lock
                          ,input parameter-3-21
                          ,input parameter-4-21
                          ,input parameter-5-21
                          ,input parameter-6-21
                          ,input parameter-7-21
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      v-cnf-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
    end.
    when "notused":U then do:
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-23  as logical   no-undo .
define variable  l-filter-open-23    as logical   .
define variable  flt-rec-23       as recid     no-undo .
define variable  filter-name-23      as character no-undo .
define variable  where-phrase-23     as character no-undo .
define variable  sort-phrase-23      as character no-undo .
define variable  where-phrase-rus-23 as character no-undo .
define variable  sort-phrase-rus-23  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input v-filter-point
  ,output flt-rec-23
  ,output filter-name-23
  ,output where-phrase-23
  ,output sort-phrase-23
  ,output where-phrase-rus-23
  ,output sort-phrase-rus-23
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-23
      ) no-error .
  assign
    l-filter-open-23 = false
  .
  if flt-rec-23 <> ?
    or v-sort-column-phrase > ""
  then do:
    define variable  parameter-2-23 as character no-undo .
    define variable  parameter-3-23 as character no-undo .
    define variable  parameter-4-23 as character no-undo .
    define variable  parameter-5-23 as character no-undo .
    define variable  parameter-6-23 as character no-undo .
    define variable  parameter-7-23 as character no-undo .
      assign
      parameter-3-23 =
                              "FOR EACH cnf"
      parameter-4-23 =
        (
          if ("cnf.notused = true                            and                            ( r-cnf-encoded = 'all':U                              or ( t-cnf-type-k = true      and cnf.conf-type = 'к':U )                              or ( t-cnf-type-s = true      and cnf.conf-type = 'п':U )                              or ( t-cnf-type-o = true      and cnf.conf-type = 'о':U )                              or ( t-cnf-type-notenc = true and cnf.conf-type = '':U       )                            )                            and
                           ( r-cnf-db = 'all':U                              or ( r-cnf-db <> 'all':U and cnf.db-num = f-db-num )                            )                           " + " " + where-phrase-23) <> ""
          then substitute( 'cnf.notused = true                                         and ( &2                                               or ( &3 and cnf.conf-type = &1к&1 )                                               or ( &4 and cnf.conf-type = &1п&1 )                                               or ( &5 and cnf.conf-type = &1о&1 )                                               or ( &6 and cnf.conf-type = &1&1   )                                             )                                         and                                          (  &1&7&1                                            or ( not &7 and cnf.db-num = &1&8&1 )                                          )'                                         ,chr(34)                                         ,r-cnf-encoded = 'all':U                                         ,t-cnf-type-k = true                                         ,t-cnf-type-s = true                                         ,t-cnf-type-o = true                                         ,t-cnf-type-notenc = true                                         ,r-cnf-db ='all':U                                         ,f-db-num                                      )                            + " " + where-phrase-23
          else "true"
        )
      parameter-5-23 = (" " + "" + " " + substitute(', first cnf-struct no-lock where cnf-struct.param-code = cnf.param-code' ))
      parameter-6-23 = if sort-phrase-23 = ''
                           then
        (
        " " + " " +
          " " + v-sort-column-phrase +
        " " + " "
        )
                           else
        (
        " " + " " +
          " " + v-sort-column-phrase +
        " " + sort-phrase-23
        )
      parameter-7-23 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-23 =
          ("cnf.notused = true                            and                            ( r-cnf-encoded = 'all':U                              or ( t-cnf-type-k = true      and cnf.conf-type = 'к':U )                              or ( t-cnf-type-s = true      and cnf.conf-type = 'п':U )                              or ( t-cnf-type-o = true      and cnf.conf-type = 'о':U )                              or ( t-cnf-type-notenc = true and cnf.conf-type = '':U       )                            )                            and
                           ( r-cnf-db = 'all':U                              or ( r-cnf-db <> 'all':U and cnf.db-num = f-db-num )                            )                           " + " " + where-phrase-23 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-config :handle
                          ,input parameter-3-23
                          ,input parameter-4-23
                          ,input parameter-5-23
                          ,input parameter-6-23
                          ,input parameter-7-23
                          )
      .
      assign
        l-filter-open-23 = true
      .
    end.
    if l-filter-open-23 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
        assign
          l-query-was-opened = true
        .
    end.
  end.
  if l-filter-open-23 = false then do:
    OPEN QUERY br-config FOR EACH cnf
      where cnf.notused = true                            and                            ( r-cnf-encoded = 'all':U                              or ( t-cnf-type-k = true      and cnf.conf-type = 'к':U )                              or ( t-cnf-type-s = true      and cnf.conf-type = 'п':U )                              or ( t-cnf-type-o = true      and cnf.conf-type = 'о':U )                              or ( t-cnf-type-notenc = true and cnf.conf-type = '':U       )                            )                            and
                           ( r-cnf-db = 'all':U                              or ( r-cnf-db <> 'all':U and cnf.db-num = f-db-num )                            )
    , first cnf-struct no-lock where cnf-struct.param-code = cnf.param-code
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-cnf-rec = recid( cnf )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-config :handle:get-buffer-handle(1) = (buffer cnf:handle) then do:
      assign
      parameter-2-23 = (if p-find-next then "true":u else "false":u )
      parameter-4-23 =
        "where ":u + substitute( 'cnf.notused = true                                         and ( &2                                               or ( &3 and cnf.conf-type = &1к&1 )                                               or ( &4 and cnf.conf-type = &1п&1 )                                               or ( &5 and cnf.conf-type = &1о&1 )                                               or ( &6 and cnf.conf-type = &1&1   )                                             )                                         and                                          (  &1&7&1                                            or ( not &7 and cnf.db-num = &1&8&1 )                                          )'                                         ,chr(34)                                         ,r-cnf-encoded = 'all':U                                         ,t-cnf-type-k = true                                         ,t-cnf-type-s = true                                         ,t-cnf-type-o = true                                         ,t-cnf-type-notenc = true                                         ,r-cnf-db ='all':U                                         ,f-db-num                                      )                            + " ":u + where-phrase-23 + " ":u + p-find-condition + " " + ""
      parameter-5-23 = " "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-config :handle
                          ,input rowid(cnf)
                          ,input logical(parameter-2-23)
                          ,input no-lock
                          ,input (buffer cnf:handle)
                          ,input parameter-4-23
                          ,input parameter-5-23
                          ) no-error.
      .
      assign
        v-cnf-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-23 = (if p-find-next then "true":u else "false":u )
      parameter-3-23 =  "FOR EACH cnf"
      parameter-4-23 =
        (
          if ("cnf.notused = true                            and                            ( r-cnf-encoded = 'all':U                              or ( t-cnf-type-k = true      and cnf.conf-type = 'к':U )                              or ( t-cnf-type-s = true      and cnf.conf-type = 'п':U )                              or ( t-cnf-type-o = true      and cnf.conf-type = 'о':U )                              or ( t-cnf-type-notenc = true and cnf.conf-type = '':U       )                            )                            and
                           ( r-cnf-db = 'all':U                              or ( r-cnf-db <> 'all':U and cnf.db-num = f-db-num )                            )                           " + " " + where-phrase-23) <> ""
          then substitute( 'cnf.notused = true                                         and ( &2                                               or ( &3 and cnf.conf-type = &1к&1 )                                               or ( &4 and cnf.conf-type = &1п&1 )                                               or ( &5 and cnf.conf-type = &1о&1 )                                               or ( &6 and cnf.conf-type = &1&1   )                                             )                                         and                                          (  &1&7&1                                            or ( not &7 and cnf.db-num = &1&8&1 )                                          )'                                         ,chr(34)                                         ,r-cnf-encoded = 'all':U                                         ,t-cnf-type-k = true                                         ,t-cnf-type-s = true                                         ,t-cnf-type-o = true                                         ,t-cnf-type-notenc = true                                         ,r-cnf-db ='all':U                                         ,f-db-num                                      )                            + " " + where-phrase-23
          else "true"
        )
      parameter-5-23 = (" " + "" + " " + substitute(', first cnf-struct no-lock where cnf-struct.param-code = cnf.param-code' ) + " " + p-find-condition)
      parameter-6-23 = if sort-phrase-23 = ''
                           then
        (
        " " + " " +
          " " + v-sort-column-phrase +
        " " + " "
        )
                           else
        (
        " " + " " +
          " " + v-sort-column-phrase +
        " " + sort-phrase-23
        )
      parameter-7-23 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-config :handle
                          ,input logical(parameter-2-23)
                          ,input no-lock
                          ,input parameter-3-23
                          ,input parameter-4-23
                          ,input parameter-5-23
                          ,input parameter-6-23
                          ,input parameter-7-23
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      v-cnf-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
    end.
    when "onlyerror":U then do:
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-25  as logical   no-undo .
define variable  l-filter-open-25    as logical   .
define variable  flt-rec-25       as recid     no-undo .
define variable  filter-name-25      as character no-undo .
define variable  where-phrase-25     as character no-undo .
define variable  sort-phrase-25      as character no-undo .
define variable  where-phrase-rus-25 as character no-undo .
define variable  sort-phrase-rus-25  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input v-filter-point
  ,output flt-rec-25
  ,output filter-name-25
  ,output where-phrase-25
  ,output sort-phrase-25
  ,output where-phrase-rus-25
  ,output sort-phrase-rus-25
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-25
      ) no-error .
  assign
    l-filter-open-25 = false
  .
  if flt-rec-25 <> ?
    or v-sort-column-phrase > ""
  then do:
    define variable  parameter-2-25 as character no-undo .
    define variable  parameter-3-25 as character no-undo .
    define variable  parameter-4-25 as character no-undo .
    define variable  parameter-5-25 as character no-undo .
    define variable  parameter-6-25 as character no-undo .
    define variable  parameter-7-25 as character no-undo .
      assign
      parameter-3-25 =
                              "FOR EACH cnf"
      parameter-4-25 =
        (
          if ("cnf.errorexist <> 0                            and                            ( r-cnf-encoded = 'all':U                              or ( t-cnf-type-k = true      and cnf.conf-type = 'к':U )                              or ( t-cnf-type-s = true      and cnf.conf-type = 'п':U )                              or ( t-cnf-type-o = true      and cnf.conf-type = 'о':U )                              or ( t-cnf-type-notenc = true and cnf.conf-type = '':U       )                            )                            and
                           ( r-cnf-db = 'all':U                              or ( r-cnf-db <> 'all':U and cnf.db-num = f-db-num )                            )                           " + " " + where-phrase-25) <> ""
          then substitute( 'cnf.errorexist <> 0                                         and ( &2                                               or ( &3 and cnf.conf-type = &1к&1 )                                               or ( &4 and cnf.conf-type = &1п&1 )                                               or ( &5 and cnf.conf-type = &1о&1 )                                               or ( &6 and cnf.conf-type = &1&1   )                                             )                                         and                                          (  &1&7&1                                            or ( not &7 and cnf.db-num = &1&8&1 )                                          )'                                         ,chr(34)                                         ,r-cnf-encoded = 'all':U                                         ,t-cnf-type-k = true                                         ,t-cnf-type-s = true                                         ,t-cnf-type-o = true                                         ,t-cnf-type-notenc = true                                         ,r-cnf-db ='all':U                                         ,f-db-num                                      )                            + " " + where-phrase-25
          else "true"
        )
      parameter-5-25 = (" " + "" + " " + substitute(', first cnf-struct no-lock where cnf-struct.param-code = cnf.param-code' ))
      parameter-6-25 = if sort-phrase-25 = ''
                           then
        (
        " " + " " +
          " " + v-sort-column-phrase +
        " " + " "
        )
                           else
        (
        " " + " " +
          " " + v-sort-column-phrase +
        " " + sort-phrase-25
        )
      parameter-7-25 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-25 =
          ("cnf.errorexist <> 0                            and                            ( r-cnf-encoded = 'all':U                              or ( t-cnf-type-k = true      and cnf.conf-type = 'к':U )                              or ( t-cnf-type-s = true      and cnf.conf-type = 'п':U )                              or ( t-cnf-type-o = true      and cnf.conf-type = 'о':U )                              or ( t-cnf-type-notenc = true and cnf.conf-type = '':U       )                            )                            and
                           ( r-cnf-db = 'all':U                              or ( r-cnf-db <> 'all':U and cnf.db-num = f-db-num )                            )                           " + " " + where-phrase-25 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-config :handle
                          ,input parameter-3-25
                          ,input parameter-4-25
                          ,input parameter-5-25
                          ,input parameter-6-25
                          ,input parameter-7-25
                          )
      .
      assign
        l-filter-open-25 = true
      .
    end.
    if l-filter-open-25 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
        assign
          l-query-was-opened = true
        .
    end.
  end.
  if l-filter-open-25 = false then do:
    OPEN QUERY br-config FOR EACH cnf
      where cnf.errorexist <> 0                            and                            ( r-cnf-encoded = 'all':U                              or ( t-cnf-type-k = true      and cnf.conf-type = 'к':U )                              or ( t-cnf-type-s = true      and cnf.conf-type = 'п':U )                              or ( t-cnf-type-o = true      and cnf.conf-type = 'о':U )                              or ( t-cnf-type-notenc = true and cnf.conf-type = '':U       )                            )                            and
                           ( r-cnf-db = 'all':U                              or ( r-cnf-db <> 'all':U and cnf.db-num = f-db-num )                            )
    , first cnf-struct no-lock where cnf-struct.param-code = cnf.param-code
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-cnf-rec = recid( cnf )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-config :handle:get-buffer-handle(1) = (buffer cnf:handle) then do:
      assign
      parameter-2-25 = (if p-find-next then "true":u else "false":u )
      parameter-4-25 =
        "where ":u + substitute( 'cnf.errorexist <> 0                                         and ( &2                                               or ( &3 and cnf.conf-type = &1к&1 )                                               or ( &4 and cnf.conf-type = &1п&1 )                                               or ( &5 and cnf.conf-type = &1о&1 )                                               or ( &6 and cnf.conf-type = &1&1   )                                             )                                         and                                          (  &1&7&1                                            or ( not &7 and cnf.db-num = &1&8&1 )                                          )'                                         ,chr(34)                                         ,r-cnf-encoded = 'all':U                                         ,t-cnf-type-k = true                                         ,t-cnf-type-s = true                                         ,t-cnf-type-o = true                                         ,t-cnf-type-notenc = true                                         ,r-cnf-db ='all':U                                         ,f-db-num                                      )                            + " ":u + where-phrase-25 + " ":u + p-find-condition + " " + ""
      parameter-5-25 = " "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-config :handle
                          ,input rowid(cnf)
                          ,input logical(parameter-2-25)
                          ,input no-lock
                          ,input (buffer cnf:handle)
                          ,input parameter-4-25
                          ,input parameter-5-25
                          ) no-error.
      .
      assign
        v-cnf-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-25 = (if p-find-next then "true":u else "false":u )
      parameter-3-25 =  "FOR EACH cnf"
      parameter-4-25 =
        (
          if ("cnf.errorexist <> 0                            and                            ( r-cnf-encoded = 'all':U                              or ( t-cnf-type-k = true      and cnf.conf-type = 'к':U )                              or ( t-cnf-type-s = true      and cnf.conf-type = 'п':U )                              or ( t-cnf-type-o = true      and cnf.conf-type = 'о':U )                              or ( t-cnf-type-notenc = true and cnf.conf-type = '':U       )                            )                            and
                           ( r-cnf-db = 'all':U                              or ( r-cnf-db <> 'all':U and cnf.db-num = f-db-num )                            )                           " + " " + where-phrase-25) <> ""
          then substitute( 'cnf.errorexist <> 0                                         and ( &2                                               or ( &3 and cnf.conf-type = &1к&1 )                                               or ( &4 and cnf.conf-type = &1п&1 )                                               or ( &5 and cnf.conf-type = &1о&1 )                                               or ( &6 and cnf.conf-type = &1&1   )                                             )                                         and                                          (  &1&7&1                                            or ( not &7 and cnf.db-num = &1&8&1 )                                          )'                                         ,chr(34)                                         ,r-cnf-encoded = 'all':U                                         ,t-cnf-type-k = true                                         ,t-cnf-type-s = true                                         ,t-cnf-type-o = true                                         ,t-cnf-type-notenc = true                                         ,r-cnf-db ='all':U                                         ,f-db-num                                      )                            + " " + where-phrase-25
          else "true"
        )
      parameter-5-25 = (" " + "" + " " + substitute(', first cnf-struct no-lock where cnf-struct.param-code = cnf.param-code' ) + " " + p-find-condition)
      parameter-6-25 = if sort-phrase-25 = ''
                           then
        (
        " " + " " +
          " " + v-sort-column-phrase +
        " " + " "
        )
                           else
        (
        " " + " " +
          " " + v-sort-column-phrase +
        " " + sort-phrase-25
        )
      parameter-7-25 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-config :handle
                          ,input logical(parameter-2-25)
                          ,input no-lock
                          ,input parameter-3-25
                          ,input parameter-4-25
                          ,input parameter-5-25
                          ,input parameter-6-25
                          ,input parameter-7-25
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      v-cnf-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
    end.
  end case.
  if p-open-query = false
  then do:
    if v-cnf-rec <> ? then do:
      reposition br-config to recid v-cnf-rec no-error .
    end.
    else do:
      message
        substitute("Параметр по данному запросу не найден!") skip
        view-as alert-box information .
    end.
    if v-fltopend-rowid[1] <> ? then do:
      query br-config:handle:reposition-to-rowid(v-fltopend-rowid) no-error.
    end.
  end.
  apply "value-changed" to br-config in frame fr-config.
  apply "entry" to br-config in frame fr-config.
  run waitfram-hide in this-procedure .
END PROCEDURE.
FUNCTION attach-ext RETURNS CHARACTER
  () :
  define variable ret-value as character initial "":U no-undo .
  if cnf-struct.attach-type <> 'Нет':U then do:
    assign
      ret-value = substr (cnf-struct.attach-type, 1, 3) + " "
    .
    case cnf-struct.attach-type:
      when 'Фирма':U
      or when 'Объект':U
      then do:
        if cnf.host-code <> 0 then do:
          assign
            ret-value = ret-value + 'Фирма':U + " " + string(cnf.host-code)
          .
        end.
        if cnf.obj-code  <> 0 then do:
          assign
            ret-value = ret-value + ", " + cnf.obj-type + " " + string(cnf.obj-code)
          .
        end.
      end.
    end case.
  end.
  return ret-value.
END FUNCTION.
FUNCTION attach-short RETURNS CHARACTER
  ():
  define variable ret-value as character initial "":U no-undo .
  if cnf.host-code <> 0 then do:
    if cnf.obj-code =  0 then do:
      assign
        ret-value = substr('Фирма':U, 1, 1)
      .
    end.
    else do:
      assign
        ret-value = substr('Объект':U, 1, 1)
      .
    end.
  end.
  return ret-value.
END FUNCTION.
FUNCTION can-process RETURNS LOGICAL
  ( input mes as character, input param-type as character):
  if not available cnf then do:
    message
      substitute("Не выбран параметр!") skip
      view-as alert-box error .
    return false.
  end.
  if not available cnf-struct then do:
    message
      substitute("Нет описания параметра!") skip
      view-as alert-box error .
    return false.
  end.
    if lookup (cnf.conf-type, param-type) > 0 then do:
      message
        substitute( "&1", mes ) skip
        view-as alert-box error .
      return false.
    end.
  return true.
END FUNCTION.
