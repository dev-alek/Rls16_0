DEFINE BUFFER X_c-config FOR c-config.
define  shared temp-table cnf no-undo
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
def  shared temp-table log-table no-undo
    field stroka       as character format "x(256)".
def  shared variable err-level as integer no-undo.
define input parameter parparentproc as widget-handle no-undo .
define parameter buffer buf_cnf      for cnf .
def var vss-revision    as character no-undo init "$Revision$":U .
def var vss-author      as character no-undo init "$Author$":U .
def var vss-date        as character no-undo init "$Date$":U .
def var vss-workfile    as character no-undo init "$Workfile$":U .
def var vss-archive     as character no-undo init "$Archive$":U .
def var vss-description as character no-undo init "Просмотр истории изменения конфигурационных параметров".
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function usrfulnf returns character ( input p-user-id as character):
define variable v-user-name as character no-undo .
define variable vss-include-info2 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run usrfulnm in g#library
  (input  p-user-id
  ,output v-user-name
  ) no-error .
if error-status:error
or v-user-name = ""
then do:
  return p-user-id.
end.
else do:
  return v-user-name.
end.
end function.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define   temp-table temp-changes no-undo
field f_name as character
field l_name as character
field v_old as character
field v_new as character
field t_name as character
field num_ as integer
field uniq-key-rec as character
field action as integer
field fNotChange as logical
index pi is unique primary
num_
t_name
f_name
index
Chan
fnotChange
t_name
f_name
index imain uniq-key-rec
.
FUNCTION get-all-fields returns character (p-file-name as character ):
define variable v-dop as character no-undo .
  find first _file no-lock where _file._file-name = p-file-name no-error .
  if not available _file then return "":U.
  for each _field no-lock where
           _field._file-recid = recid(_file) :
    assign
    v-dop = v-dop + _field._field-name + chr(44)
    .
  end.
  return trim(v-dop).
END FUNCTION.
PROCEDURE proc-full-temp-changes :
  define input  parameter p-act-create as logical   no-undo .
  define input  parameter p-act-delete as logical   no-undo .
  define input  parameter p-hst-handle as handle    no-undo .
  define input  parameter p-main-table as character no-undo .
  define input  parameter p-field-list as character no-undo .
  define input  parameter p-label-form as character no-undo .
  define variable h-new-buf         as handle    no-undo .
  define variable h-main-buf        as handle    no-undo .
  define variable h-for-comp        as handle    no-undo .
  define variable v-inform          as character no-undo .
  define variable v-ind             as integer   no-undo .
  define variable v-idx-field-qnty  as integer   no-undo .
  define variable v-num-entries     as integer   no-undo .
  define variable fh                as handle    no-undo .
  define variable fh-main           as handle    no-undo .
  define variable fh-old            as handle    no-undo .
  define variable fh-new            as handle    no-undo .
  define variable v-field-name      as character no-undo .
  define variable v-field-lvl       as character no-undo .
  define variable v-field-form      as character no-undo .
  define variable v-search-exp      as character no-undo .
  define variable v-srch-main       as character no-undo .
  define variable v-word-link       as character no-undo .
  define variable v-av-chip-num     as logical   no-undo .
  define variable v-main-pi-fld-lst as character no-undo .
  define variable v-main-fld-lst    as character no-undo .
  define variable v-delim-list      as character no-undo .
  define variable v-label           as character no-undo .
  define variable v-old-value       as character no-undo case-sensitive.
  define variable v-new-value       as character no-undo case-sensitive.
  define variable v-chg-fields as character no-undo.
  for each temp-changes:
    delete temp-changes.
  end.
  if not p-hst-handle:available then do:
    return .
  end.
  create buffer h-new-buf  for table p-hst-handle .
  create buffer h-main-buf for table p-main-table .
  assign
    v-inform = h-main-buf:index-information(1)
    v-ind    = 2
  .
  do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
  on error undo, return error
  :
    assign
      v-inform = h-main-buf:index-information( v-ind )
      v-ind    = v-ind + 1
    .
  end.
  if v-inform = ?
    or LC( entry( 1, v-inform, ",":U ) ) = "default":U
    or entry( 3, v-inform, ",":U ) <> "1":U
  then do:
    return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-workfile, h-main-buf:name ).
  end.
  assign
    v-idx-field-qnty = num-entries( v-inform ) - 4
  .
  if v-idx-field-qnty < 2 then do:
    return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-workfile, v-inform, h-main-buf:name ).
  end.
  assign
    v-srch-main   = "where":U
    v-word-link   = "":U
    v-av-chip-num = false
    v-delim-list  = "":U
  .
  do v-ind = 1 to v-idx-field-qnty by 2
  on error undo, return error
  :
    assign
      v-field-name      = entry( 4 + v-ind, v-inform, ",":U )
      fh                = p-hst-handle:buffer-field( v-field-name )
      fh-main           = h-main-buf:buffer-field( v-field-name )
      v-srch-main       = substitute( "&1 &2 &3.&4 =", v-srch-main, v-word-link, fh-main:table, v-field-name )
      v-main-pi-fld-lst = v-main-pi-fld-lst + v-delim-list + v-field-name
    .
    if fh:data-type ="character":U then do:
      assign
        v-srch-main = substitute( '&1 "&2"', v-srch-main, replace( replace( fh:buffer-value(), '"':U, '""':U ), '~~':U, '~~~~':U ) )
      .
    end.
    else do:
      assign
        v-srch-main = substitute( "&1 &2", v-srch-main, fh:buffer-value() )
      .
    end.
    if v-delim-list = "":U then do:
      assign
        v-delim-list = ",":U
      .
    end.
    if v-word-link = "":U then do:
      assign
        v-word-link = "and":U
      .
    end.
  end.
  assign
    v-delim-list  = "":U
  .
  do v-ind = 1 to h-main-buf:num-fields
  on error undo, return error
  :
    assign
      fh-main      = h-main-buf:buffer-field( v-ind )
      v-field-name = fh-main:name
    .
      assign
        v-main-fld-lst = v-main-fld-lst + v-delim-list + v-field-name
      .
      if v-delim-list = "":U then do:
        assign
          v-delim-list = ",":U
        .
      end.
  end.
  assign
    v-inform = p-hst-handle:index-information(1)
    v-ind    = 2
  .
  do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
  on error undo, return error
  :
    assign
      v-inform = p-hst-handle:index-information( v-ind )
      v-ind    = v-ind + 1
    .
  end.
  if v-inform = ?
    or LC( entry( 1, v-inform, ",":U ) ) = "default":U
    or entry( 3, v-inform, ",":U ) <> "1":U
  then do:
    return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-workfile, p-hst-handle:name ).
  end.
  assign
    v-idx-field-qnty = num-entries( v-inform ) - 4
  .
  if v-idx-field-qnty < 2 then do:
    return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-workfile, v-inform, p-hst-handle:name ).
  end.
  assign
    v-search-exp  = "where":U
    v-word-link   = "":U
    v-av-chip-num = false
  .
  do v-ind = 1 to v-idx-field-qnty by 2
  on error undo, return error
  :
    assign
      v-field-name = entry( 4 + v-ind, v-inform, ",":U )
      fh           = p-hst-handle:buffer-field( v-field-name )
      v-search-exp = substitute( "&1 &2 &3.&4", v-search-exp, v-word-link, fh:table, v-field-name )
    .
    if v-field-name = "chip-num":U then do:
      assign
        v-search-exp  = substitute( "&1 >", v-search-exp )
        v-av-chip-num = true
      .
    end.
    else do:
      assign
        v-search-exp = substitute( "&1 =", v-search-exp )
      .
    end.
    if fh:data-type ="character":U then do:
      assign
        v-search-exp = substitute( '&1 "&2"', v-search-exp, replace( replace( fh:buffer-value(), '"':U, '""':U ), '~~':U, '~~~~':U ) )
      .
    end.
    else do:
      assign
        v-search-exp = substitute( '&1 &2', v-search-exp, fh:buffer-value() )
      .
    end.
    if v-word-link = "":U then do:
      assign
        v-word-link = "and":U
      .
    end.
  end.
  if v-av-chip-num = false then do:
    message
      vss-workfile vss-revision vss-description skip
      substitute( "Таблица &2 не содержит поля chip-num.", vss-workfile, p-hst-handle:name ) skip
      "Использование данной процедуры невозможно!" skip
      view-as alert-box error .
    return error .
  end.
  h-new-buf:find-first( v-search-exp, no-lock ) no-error .
  if not h-new-buf:available then do:
    h-main-buf:find-first( v-srch-main, no-lock ) no-error .
    if not h-main-buf:available then do:
      assign
        h-for-comp = ?
      .
    end.
    else do:
      assign
        h-for-comp = h-main-buf
      .
    end.
  end.
  else do:
    assign
      h-for-comp = h-new-buf
    .
  end.
  assign
    v-num-entries = num-entries( v-main-fld-lst, ",":U )
  .
  do v-ind = 1 to v-num-entries
  on error undo, return error return-value
  :
    assign
      v-field-name = entry( v-ind, v-main-fld-lst )
      fh-old       = p-hst-handle:buffer-field( v-field-name )
      v-old-value  = fh-old:buffer-value()
      v-label      = trim( fh-old:label )
    .
    if ( trim( p-field-list ) <> "":U
         and lookup( v-field-name, p-field-list ) > 0
       )
       or trim( p-field-list ) = "":U
    then do:
      if h-for-comp <> ? then do:
        assign
          fh-new      = h-for-comp:buffer-field( v-field-name )
          v-new-value = fh-new:buffer-value()
        .
      end.
      else do:
        assign
          v-new-value = "":U
        .
      end.
        if p-act-create = true then do:
          assign
            v-old-value = "":U
          .
        end.
        if p-act-delete = true then do:
          assign
            v-new-value = "":U
          .
        end.
      if v-old-value <> v-new-value
      then do:
        create temp-changes.
        assign
          temp-changes.t_name = p-main-table
          temp-changes.f_name = v-field-name
          temp-changes.l_name = replace( v-label, "&":U, "":U )
          temp-changes.v_old  = trim( v-old-value )
          temp-changes.v_new  = trim( v-new-value )
          temp-changes.num_   = 0
          temp-changes.fNotChange = v-old-value eq v-new-value
        .
      end.
    end.
  end.
  assign
    v-num-entries = num-entries( p-label-form, chr(8) )
  .
  do v-ind = 1 to v-num-entries
  on error undo, return error return-value
  :
    if num-entries( entry( v-ind, p-label-form, chr(8) ), chr(4) ) = 3 then do:
      assign
        v-field-name = entry( 1, entry( v-ind, p-label-form, chr(8) ), chr(4) )
        v-field-lvl  = entry( 2, entry( v-ind, p-label-form, chr(8) ), chr(4) )
        v-field-form = entry( 3, entry( v-ind, p-label-form, chr(8) ), chr(4) )
      .
      find first temp-changes
        where temp-changes.f_name = v-field-name
        no-error .
      if available temp-changes then do:
        if trim( v-field-lvl ) <> "":U then do:
          assign
            temp-changes.l_name = v-field-lvl
          .
        end.
        if trim( v-field-form ) <> "":U then do:
          assign
            temp-changes.v_old = dynamic-function( v-field-form, temp-changes.v_old )
          .
          if h-for-comp <> ? then do:
            assign
              temp-changes.v_new = dynamic-function( v-field-form, temp-changes.v_new )
            .
          end.
        end.
      end.
    end.
    else do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка! Список должен содержать три поля с разделителем delim-par!" skip
        substitute( "список для поля '&1': '&2'"
                    ,entry( 1, entry( v-ind, p-label-form, chr(8) ), chr(4) )
                    ,entry( v-ind, p-label-form, chr(8) )
                  ) skip
        substitute( "полный список: &2", p-label-form ) skip
        view-as alert-box error .
    end.
  end.
  delete object h-new-buf .
  delete object h-main-buf .
END PROCEDURE.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable c-point  as character no-undo .
define variable tbl      as character no-undo .
define variable join-tbl as character no-undo .
define variable fld      as character no-undo .
define variable lab      as character no-undo .
define variable spr      as character no-undo .
define variable dim      as character no-undo .
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable v-hist-rec         as recid no-undo.
define variable v-sort-column-name as character no-undo .
define variable v-filter-pointr as character no-undo init "Просмотр истории изменения конфигурационных параметров" .
define variable v-filter-point0 as character no-undo init "cfg-hist" .
define variable v-filter-point as character no-undo .
FUNCTION get-action RETURNS CHARACTER
    ( p-action as integer )  FORWARD.
DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-quit AUTO-END-KEY DEFAULT
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-sch
     LABEL "&Фильтр"
     SIZE 3 BY 1.
DEFINE QUERY br-cfg-hist FOR
X_c-config.
DEFINE QUERY BR-changes FOR
      temp-changes SCROLLING.
DEFINE BROWSE br-cfg-hist
  QUERY br-cfg-hist NO-LOCK DISPLAY
      X_c-config.corr-user-name column-label "Изменил" FORMAT "x(8)":U
      usrfulnf(X_c-config.corr-user-name) column-label "Изменил" FORMAT "x(15)":U
      X_c-config.corr-user-db-num COLUMN-LABEL "БД изм." FORMAT ">>>>9":U
      X_c-config.corr-date FORMAT "99/99/9999":U
      string(X_c-config.corr-time,"HH:MM:SS") COLUMN-LABEL "Время изм." FORMAT "x(8)":U
      get-action(X_c-config.action) COLUMN-LABEL "Действие" FORMAT "x(10)":U
      X_c-config.db-num FORMAT ">>>>9":U
      X_c-config.param-code COLUMN-LABEL "Параметр" FORMAT "X(8)":U
      X_c-config.host-code COLUMN-LABEL "Код фирмы" FORMAT "99999":U
      substitute("&1 &2",X_c-config.obj-type,X_c-config.obj-code) COLUMN-LABEL "Объект" FORMAT "x(9)":U
      (if X_c-config.beg-date = 01/01/1900 then "не ограничен" else string( X_c-config.beg-date, "99/99/9999")) COLUMN-LABEL "Действует с" FORMAT "x(12)":U
      (if X_c-config.end-date = 01/01/9999 then "не ограничен" else string( X_c-config.end-date, "99/99/9999")) COLUMN-LABEL "Действует по" FORMAT "x(12)":U
    WITH SEPARATORS SIZE 97 BY 11 ROW-HEIGHT-CHARS .58 FIT-LAST-COLUMN.
DEFINE BROWSE BR-changes
  QUERY BR-changes DISPLAY
      temp-changes.l_name COLUMn-LABEL "Изменилось" format "X(40)"
temp-changes.v_old COLUMn-LABEL "Было" format "X(70)"
temp-changes.v_new COLUMn-LABEL "Стало" format "X(70)"
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97 BY 8.25.
DEFINE FRAME d-cfg-hist
     b-quit AT ROW 1 COL 2
     b-sch AT ROW 1 COL 93 WIDGET-ID 2
     b-help AT ROW 1 COL 96
     br-cfg-hist AT ROW 2.25 COL 2
     BR-changes AT ROW 14.25 COL 2
     SPACE(0.87) SKIP(0.37)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "История изменения параметров конфигурации"
         CANCEL-BUTTON b-quit.
ASSIGN
       FRAME d-cfg-hist:SCROLLABLE       = FALSE.
ASSIGN
       br-cfg-hist:COLUMN-RESIZABLE IN FRAME d-cfg-hist       = TRUE.
ON WINDOW-CLOSE OF FRAME d-cfg-hist
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-quit IN FRAME d-cfg-hist
DO:
  define variable v-ok as logical   no-undo .
END.
ON CHOOSE OF b-sch IN FRAME d-cfg-hist
DO:
  RUN proc-b-sch IN this-procedure NO-ERROR.
END.
ON VALUE-CHANGED OF br-cfg-hist IN FRAME d-cfg-hist
DO:
  if available X_c-config then do:
    run proc-full-temp-changes in this-procedure
      ( input (X_c-config.action = 1 )
       ,input (X_c-config.action = 99 )
       ,input (buffer X_c-config:handle)
       ,input 'config':U
       ,input "beg-date,conf-type,db-num,end-date,host-code,obj-code,obj-type,param-code,param-encoded,param-type,param-value":U
       ,input "":U
      ) no-error.
  end.
  else do:
    for each temp-changes
    :
      delete temp-changes .
    end.
  end.
  OPEN QUERY BR-changes FOR EACH temp-changes.
END.
if VALID-HANDLE(ACTIVE-WINDOW) AND FRAME d-cfg-hist:PARENT eq ?
THEN FRAME d-cfg-hist:PARENT = ACTIVE-WINDOW.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame d-cfg-hist
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
on choose of b-help in frame d-cfg-hist
do:
  apply "help":u to frame d-cfg-hist .
end.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
                v-frame-width = frame d-cfg-hist:width - 0.3
                fh            = frame d-cfg-hist:first-child
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
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
    if frame d-cfg-hist :height + p-change-value
        > decimal(session :work-area-height-pixels) / session :pixels-per-row
    then do:
      assign
        p-change-value = decimal(session :work-area-height-pixels) / session :pixels-per-row
                        - (frame d-cfg-hist :height-chars)
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
    if frame d-cfg-hist :height + p-change-value < v-diasize-orig-frame-height
    then do:
      assign
        p-change-value = v-diasize-orig-frame-height
                       - (frame d-cfg-hist :height-chars)
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
            frame d-cfg-hist :height = v-frame-height
          .
          if frame d-cfg-hist :scrollable = true
          then do:
            assign
              frame d-cfg-hist :virtual-height = v-frame-virtual-height
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame d-cfg-hist :scrollable = true
          then do:
            assign
              frame d-cfg-hist :virtual-height = v-frame-virtual-height
            .
          end.
          assign
            frame d-cfg-hist :height = v-frame-height
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
      v-frame-height = frame d-cfg-hist :height
      v-frame-virtual-height = frame d-cfg-hist :virtual-height
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
      v-field-group-handle = frame d-cfg-hist :first-child
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
    do with frame d-cfg-hist
    :
      hide v-diasize-resize-button .
      assign
        v-diasize-resize-button :row    = 1
        v-diasize-resize-button :column = 1
      .
    end.
    if p-change-value > 0
    then do:
      if frame d-cfg-hist :scrollable = true
      then do:
        assign
          frame d-cfg-hist :virtual-height = frame d-cfg-hist :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame d-cfg-hist :height = frame d-cfg-hist :height + p-change-value
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
        frame d-cfg-hist :height = frame d-cfg-hist :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      if frame d-cfg-hist :scrollable = true
      then do:
        assign
          frame d-cfg-hist :virtual-height = frame d-cfg-hist :virtual-height + p-change-value
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
          ,input  string(frame d-cfg-hist :height - v-diasize-orig-frame-height)
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
      (input  (p-new-height - frame d-cfg-hist :height)
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
    if frame d-cfg-hist :width + p-change-value >
        session :width-chars
    then do:
      assign
        p-change-value = session :width-chars - frame d-cfg-hist :width
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
    if frame d-cfg-hist :width + p-change-value < v-diasize-orig-frame-width
    then do:
      assign
        p-change-value = v-diasize-orig-frame-width
                       - frame d-cfg-hist :width
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
            frame d-cfg-hist :width = v-frame-width
          .
          if frame d-cfg-hist :scrollable = true
          then do:
            assign
              frame d-cfg-hist :virtual-width = v-frame-virtual-width
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame d-cfg-hist :scrollable = true
          then do:
            assign
              frame d-cfg-hist :virtual-width = v-frame-virtual-width
            .
          end.
          assign
            frame d-cfg-hist :width = v-frame-width
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
      v-frame-width = frame d-cfg-hist :width
      v-frame-virtual-width = frame d-cfg-hist :virtual-width
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
      v-field-group-handle = frame d-cfg-hist :first-child
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
    do with frame d-cfg-hist
    :
      hide v-diasize-resize-button .
      v-diasize-resize-button :row = 1.
      v-diasize-resize-button :column = 1.
    end.
    if p-change-value > 0
    then do:
      if frame d-cfg-hist :scrollable = true
      then do:
        assign
          frame d-cfg-hist :virtual-width = frame d-cfg-hist :virtual-width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
      assign
        frame d-cfg-hist :width = v-frame-width + p-change-value
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
        frame d-cfg-hist :width = frame d-cfg-hist :width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      if frame d-cfg-hist :scrollable = true
      then do:
        assign
          frame d-cfg-hist :virtual-width = frame d-cfg-hist :virtual-width + p-change-value
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
          ,input  string(frame d-cfg-hist :width - v-diasize-orig-frame-width)
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
      (input  (p-new-width - frame d-cfg-hist :width)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_position-resize-button :
  do with frame d-cfg-hist
  :
    hide v-diasize-resize-button .
    assign
      v-diasize-resize-button :row = frame d-cfg-hist :height - v-diasize-resize-button :height
                  - 1
                  - (frame d-cfg-hist :border-bottom-pixels / session :pixels-per-row)
      v-diasize-resize-button :col = frame d-cfg-hist :width - v-diasize-resize-button :width
                  - 1
                  - (frame d-cfg-hist :border-right-pixels / session :pixels-per-column)
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
on alt-enter of frame d-cfg-hist
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
      v-row-delta = v-new-row - frame d-cfg-hist :height
      v-col-delta = v-new-col - frame d-cfg-hist :width
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
            - frame d-cfg-hist :height-chars
        ,input true
        ) .
      run diasize_change-width in this-procedure
        (input session :width-chars
            - frame d-cfg-hist :width-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = false
      .
    end.
    else do:
      run diasize_change-width in this-procedure
        (input v-diasize-orig-frame-width
            - frame d-cfg-hist :width-chars
        ,input true
        ) .
      run diasize_change-height in this-procedure
        (input v-diasize-orig-frame-height
            - frame d-cfg-hist :height-chars
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
      v-diasize-current-frame-width  = frame d-cfg-hist :width
      v-diasize-current-frame-height = frame d-cfg-hist :height
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
    do with frame d-cfg-hist
    :
      assign
        v-diasize-orig-frame-height = frame d-cfg-hist :height
        v-diasize-orig-frame-width  = frame d-cfg-hist :width
        v-diasize-browse-handle     = browse br-cfg-hist :handle
      .
      create button v-diasize-resize-button
      assign
        parent        = frame d-cfg-hist :first-child
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
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  br-cfg-hist :SET-REPOSITIONED-ROW(8, "CONDITIONAL") .
end.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on f5 of frame d-cfg-hist anywhere
do:
  run my-open-query in this-procedure ( input yes, input no, input no ) .
    apply "VALUE-CHANGED" to br-cfg-hist.
end.
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEF VAR cur-clmn-numbr-cfg-hist as INT EXTENT 11 no-undo.
DEF VAR varmvibr-cfg-hist       as INT no-undo.
DEF VAR varmvjbr-cfg-hist       as INT no-undo.
DEF VAR varmvkbr-cfg-hist       as INT no-undo.
DEF VAR varmvlbr-cfg-hist       as INT no-undo.
DEF VAR move-elementbr-cfg-hist as INT no-undo.
def var jjbr-cfg-hist           as int no-undo.
do varmvibr-cfg-hist = 1 to EXTENT(cur-clmn-numbr-cfg-hist):
  ASSIGN cur-clmn-numbr-cfg-hist[varmvibr-cfg-hist] = varmvibr-cfg-hist.
END.
RUN start-mv-clmnbr-cfg-hist.
PROCEDURE start-mv-clmnbr-cfg-hist:
def var old-session as logical no-undo.
   old-session = SESSION:IMMEDIATE-DISPLAY.
   IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
   SESSION:IMMEDIATE-DISPLAY = old-session.
END.
ON ctrl-cursor-right OF BROWSE br-cfg-hist do:
  RUN re-move-clmnbr-cfg-hist ( 1, 11).
END.
ON ctrl-cursor-left OF BROWSE br-cfg-hist do:
  RUN re-move-clmnbr-cfg-hist (11, 1).
END.
PROCEDURE re-move-clmnbr-cfg-hist:
  DEFINE INPUT PARAMETER source-column as INTEGER NO-UNDO.
  DEFINE INPUT PARAMETER target-column as INTEGER NO-UNDO.
  DO varmvibr-cfg-hist = 1 TO EXTENT(cur-clmn-numbr-cfg-hist):
    if cur-clmn-numbr-cfg-hist[varmvibr-cfg-hist] = source-column THEN cur-clmn-numbr-cfg-hist[varmvibr-cfg-hist] = -1.
  END.
  if br-cfg-hist:MOVE-COLUMN(source-column, target-column) IN FRAME d-cfg-hist then.
  if source-column > target-column THEN
  DO varmvjbr-cfg-hist = source-column - 1 to target-column BY -1:
    DO varmvibr-cfg-hist = 1 TO EXTENT(cur-clmn-numbr-cfg-hist):
        if cur-clmn-numbr-cfg-hist[varmvibr-cfg-hist] = varmvjbr-cfg-hist THEN DO:
          cur-clmn-numbr-cfg-hist[varmvibr-cfg-hist] = cur-clmn-numbr-cfg-hist[varmvibr-cfg-hist] + 1.
        END.
    END.
  END.
  ELSE
  DO varmvjbr-cfg-hist = source-column + 1 to target-column:
    DO varmvibr-cfg-hist = 1 TO EXTENT(cur-clmn-numbr-cfg-hist):
      if cur-clmn-numbr-cfg-hist[varmvibr-cfg-hist] = varmvjbr-cfg-hist THEN DO:
        cur-clmn-numbr-cfg-hist[varmvibr-cfg-hist] = cur-clmn-numbr-cfg-hist[varmvibr-cfg-hist] - 1.
      END.
    END.
  END.
  DO varmvibr-cfg-hist = 1 TO EXTENT(cur-clmn-numbr-cfg-hist):
    if cur-clmn-numbr-cfg-hist[varmvibr-cfg-hist] = -1 THEN cur-clmn-numbr-cfg-hist[varmvibr-cfg-hist] = target-column.
  END.
END PROCEDURE.
PROCEDURE ch-clmnbr-cfg-hist:
  DEFINE INPUT PARAMETER cur-clmn-loc as INTEGER NO-UNDO.
  if cur-clmn-loc <= 1 then do:
    return .
  end.
  DO varmvibr-cfg-hist = 1 TO EXTENT(cur-clmn-numbr-cfg-hist):
    if cur-clmn-numbr-cfg-hist[varmvibr-cfg-hist] = cur-clmn-loc THEN move-elementbr-cfg-hist = varmvibr-cfg-hist.
  END.
  RUN re-move-clmnbr-cfg-hist (cur-clmn-loc, 1).
END PROCEDURE.
PROCEDURE mv-brw-defaultbr-cfg-hist:
def var old-session as logical no-undo.
  old-session = SESSION:IMMEDIATE-DISPLAY.
  IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
  do varmvlbr-cfg-hist = 1 to EXTENT(cur-clmn-numbr-cfg-hist):
    RUN re-move-clmnbr-cfg-hist (cur-clmn-numbr-cfg-hist[varmvlbr-cfg-hist], varmvlbr-cfg-hist).
  END.
  RUN start-mv-clmnbr-cfg-hist.
  SESSION:IMMEDIATE-DISPLAY = old-session.
END PROCEDURE.
.
def var sort-labelbr-cfg-hist   as character no-undo .
def var sort-clmnbr-cfg-hist    as handle    no-undo .
def var cur-clmnbr-cfg-hist     as handle    no-undo .
def var cur-clmn-locbr-cfg-hist as integer   no-undo .
def var re-querybr-cfg-hist     as logical   initial no no-undo .
on start-search, ctrl-o of br-cfg-hist in frame d-cfg-hist do:
   run sort-brbr-cfg-hist
     (input (if available X_c-config
             then recid(X_c-config)
             else ?
            )
     ).
end.
PROCEDURE sort-brbr-cfg-hist :
  define input parameter p-recid as recid no-undo .
  if re-querybr-cfg-hist = no then do:
    assign
       cur-clmnbr-cfg-hist = br-cfg-hist:current-column in frame d-cfg-hist
    .
    if sort-clmnbr-cfg-hist <> ? then sort-clmnbr-cfg-hist:column-fgcolor = 0.
    if cur-clmnbr-cfg-hist = sort-clmnbr-cfg-hist then do:
      assign
         sort-labelbr-cfg-hist = ""
         sort-clmnbr-cfg-hist = ?
      .
     end.
     else do:
       assign
         sort-labelbr-cfg-hist = cur-clmnbr-cfg-hist:label
         sort-clmnbr-cfg-hist  = cur-clmnbr-cfg-hist
         sort-clmnbr-cfg-hist:column-fgcolor = 4
       .
     end.
   end.
  assign
    cur-clmn-locbr-cfg-hist = 1
  .
  def var column-handle as handle no-undo .
  column-handle = br-cfg-hist:first-column.
  do while valid-handle(column-handle) :
    if column-handle = cur-clmnbr-cfg-hist then do:
      leave .
    end.
    column-handle = column-handle:NEXT-COLUMN.
    assign
      cur-clmn-locbr-cfg-hist = cur-clmn-locbr-cfg-hist + 1
    .
  end.
  case sort-labelbr-cfg-hist:
        when X_c-config.corr-user-db-num:label in browse br-cfg-hist then DO:    assign       v-sort-column-name = "X_c-config.corr-user-db-num"     .     run my-open-query in this-procedure ( input yes, input no, input no ) .   . END.
        when X_c-config.corr-date:label in browse br-cfg-hist then DO:    assign       v-sort-column-name = "X_c-config.corr-date"     .     run my-open-query in this-procedure ( input yes, input no, input no ) .   . END.
        when X_c-config.param-code:label in browse br-cfg-hist then DO:    assign       v-sort-column-name = "X_c-config.param-code"     .     run my-open-query in this-procedure ( input yes, input no, input no ) .   . END.
    otherwise do:
      assign
        v-sort-column-name = ""
      .
      run my-open-query in this-procedure ( input yes, input no, input no ) .
        if can-do( this-procedure:internal-entries, 'mv-brw-defaultbr-cfg-hist') then do:
          run mv-brw-defaultbr-cfg-hist.
        end.
      if sort-labelbr-cfg-hist <> "" then do:
        assign
          cur-clmnbr-cfg-hist:column-fgcolor = 0
        .
      end.
      assign
        cur-clmn-locbr-cfg-hist = ?
      .
    end.
  end case.
    if cur-clmn-locbr-cfg-hist <> ? then do:
      if can-do( this-procedure:internal-entries, 'ch-clmnbr-cfg-hist') then do:
        run ch-clmnbr-cfg-hist in this-procedure (cur-clmn-locbr-cfg-hist).
      end.
    end.
  if p-recid <> ? then do:
    reposition br-cfg-hist to recid p-recid no-error.
    apply "value-changed" to br-cfg-hist in frame d-cfg-hist.
  end.
  apply "entry" to br-cfg-hist in frame d-cfg-hist.
END PROCEDURE.
procedure re-open-query-srt-clmnbr-cfg-hist:
if cur-clmnbr-cfg-hist = ? then do:
   run my-open-query in this-procedure ( input yes, input no, input no ) .
end.
else do:
   assign re-querybr-cfg-hist = yes.
   run sort-brbr-cfg-hist
     (input (if available X_c-config
             then recid(X_c-config)
             else ?
            )
     ).
   assign re-querybr-cfg-hist = no.
end.
end.
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure set-filter-name :
define input parameter p-filter-name as character no-undo .
  do with frame d-cfg-hist:
    if p-filter-name > "" then do:
      assign
        frame d-cfg-hist:title
          = frame d-cfg-hist:title + "   ФИЛЬТР: " + p-filter-name.
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
MAIN-BLOCK:
DO
ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
:
  RUN enable_UI.
  assign
    temp-changes.l_name:resizable in browse br-changes = true
    temp-changes.v_old:resizable in browse br-changes = true
    temp-changes.v_new:resizable in browse br-changes = true
    temp-changes.l_name:width in browse br-changes = 33
    temp-changes.v_old:width in browse br-changes = 30
    temp-changes.v_new:width in browse br-changes = 30
  .
  run my-open-query in this-procedure ( input yes, input no, input no) .
  wait-for go of frame d-cfg-hist.
end.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME d-cfg-hist.
END PROCEDURE.
PROCEDURE enable_UI :
  ENABLE b-quit b-sch b-help br-cfg-hist BR-changes
      WITH FRAME d-cfg-hist.
END PROCEDURE.
PROCEDURE my-open-query :
  define input  parameter p-open-query     as logical   no-undo .
  define input  parameter p-find-next      as logical   no-undo .
  define input  parameter p-find-condition as character no-undo .
  define variable l-query-was-opened as logical no-undo .
  define variable v-sort-column-phrase as character no-undo .
  if available X_c-config then do:
    assign
      v-hist-rec = recid( X_c-config )
    .
  end.
  run waitfram-show in this-procedure ( input "Ждите...").
  case v-sort-column-name :
    when "" then do:
      assign
        v-sort-column-phrase = "by X_c-config.corr-date by X_c-config.corr-time by X_c-config.corr-user-db-num by X_c-config.chip-num":U
      .
    end.
    otherwise do:
      assign
        v-sort-column-phrase = substitute( "by &1", v-sort-column-name )
      .
    end.
  end case.
  if available buf_cnf then do:
    if buf_cnf.NotUsed = true then do:
      assign
        v-filter-point = v-filter-point0 + "cnf-not-used":U + chr(4) + v-filter-pointr
        frame d-cfg-hist:title = substitute( "История изменения выключенного параметра &1 по БД &2 ", buf_cnf.param-code, buf_cnf.db-num )
      .
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-16  as logical   no-undo .
define variable  l-filter-open-16    as logical   .
define variable  flt-rec-16       as recid     no-undo .
define variable  filter-name-16      as character no-undo .
define variable  where-phrase-16     as character no-undo .
define variable  sort-phrase-16      as character no-undo .
define variable  where-phrase-rus-16 as character no-undo .
define variable  sort-phrase-rus-16  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input v-filter-point
  ,output flt-rec-16
  ,output filter-name-16
  ,output where-phrase-16
  ,output sort-phrase-16
  ,output where-phrase-rus-16
  ,output sort-phrase-rus-16
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-16
      ) no-error .
  assign
    l-filter-open-16 = false
  .
  if flt-rec-16 <> ?
    or v-sort-column-phrase > ""
  then do:
    define variable  parameter-2-16 as character no-undo .
    define variable  parameter-3-16 as character no-undo .
    define variable  parameter-4-16 as character no-undo .
    define variable  parameter-5-16 as character no-undo .
    define variable  parameter-6-16 as character no-undo .
    define variable  parameter-7-16 as character no-undo .
      assign
      parameter-3-16 =
                              "FOR EACH X_c-config"
      parameter-4-16 =
        (
          if ("X_c-config.conf-type = buf_cnf.conf-type and X_c-config.param-code = buf_cnf.param-code and X_c-config.db-num = buf_cnf.db-num" + " " + where-phrase-16) <> ""
          then substitute('X_c-config.conf-type = &1&2&1 and X_c-config.param-code = &1&3&1 and X_c-config.db-num = &4'                                       ,chr(34), buf_cnf.conf-type, buf_cnf.param-code, buf_cnf.db-num                                      )                            + " " + where-phrase-16
          else "true"
        )
      parameter-5-16 = (" " + "" + " " + "")
      parameter-6-16 = if sort-phrase-16 = ''
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
        " " + sort-phrase-16
        )
      parameter-7-16 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-16 =
          ("X_c-config.conf-type = buf_cnf.conf-type and X_c-config.param-code = buf_cnf.param-code and X_c-config.db-num = buf_cnf.db-num" + " " + where-phrase-16 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-cfg-hist :handle
                          ,input parameter-3-16
                          ,input parameter-4-16
                          ,input parameter-5-16
                          ,input parameter-6-16
                          ,input parameter-7-16
                          )
      .
      assign
        l-filter-open-16 = true
      .
    end.
    if l-filter-open-16 = false then do:
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
  if l-filter-open-16 = false then do:
    OPEN QUERY br-cfg-hist FOR EACH X_c-config
      where X_c-config.conf-type = buf_cnf.conf-type and X_c-config.param-code = buf_cnf.param-code and X_c-config.db-num = buf_cnf.db-num
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-hist-rec = recid( X_c-config )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-cfg-hist :handle:get-buffer-handle(1) = (buffer X_c-config:handle) then do:
      assign
      parameter-2-16 = (if p-find-next then "true":u else "false":u )
      parameter-4-16 =
        "where ":u + substitute('X_c-config.conf-type = &1&2&1 and X_c-config.param-code = &1&3&1 and X_c-config.db-num = &4'                                       ,chr(34), buf_cnf.conf-type, buf_cnf.param-code, buf_cnf.db-num                                      )                            + " ":u + where-phrase-16 + " ":u + p-find-condition + " " + ""
      parameter-5-16 = " "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-cfg-hist :handle
                          ,input rowid(X_c-config)
                          ,input logical(parameter-2-16)
                          ,input no-lock
                          ,input (buffer X_c-config:handle)
                          ,input parameter-4-16
                          ,input parameter-5-16
                          ) no-error.
      .
      assign
        v-hist-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-16 = (if p-find-next then "true":u else "false":u )
      parameter-3-16 =  "FOR EACH X_c-config"
      parameter-4-16 =
        (
          if ("X_c-config.conf-type = buf_cnf.conf-type and X_c-config.param-code = buf_cnf.param-code and X_c-config.db-num = buf_cnf.db-num" + " " + where-phrase-16) <> ""
          then substitute('X_c-config.conf-type = &1&2&1 and X_c-config.param-code = &1&3&1 and X_c-config.db-num = &4'                                       ,chr(34), buf_cnf.conf-type, buf_cnf.param-code, buf_cnf.db-num                                      )                            + " " + where-phrase-16
          else "true"
        )
      parameter-5-16 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-16 = if sort-phrase-16 = ''
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
        " " + sort-phrase-16
        )
      parameter-7-16 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-cfg-hist :handle
                          ,input logical(parameter-2-16)
                          ,input no-lock
                          ,input parameter-3-16
                          ,input parameter-4-16
                          ,input parameter-5-16
                          ,input parameter-6-16
                          ,input parameter-7-16
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      v-hist-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
    end.
    else do:
      assign
        v-filter-point = v-filter-point0 + "one-cnf":U + chr(4) + v-filter-pointr
        frame d-cfg-hist:title = substitute( "История изменения параметра &1 по БД &2 ", buf_cnf.param-code, buf_cnf.db-num )
      .
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-18  as logical   no-undo .
define variable  l-filter-open-18    as logical   .
define variable  flt-rec-18       as recid     no-undo .
define variable  filter-name-18      as character no-undo .
define variable  where-phrase-18     as character no-undo .
define variable  sort-phrase-18      as character no-undo .
define variable  where-phrase-rus-18 as character no-undo .
define variable  sort-phrase-rus-18  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input v-filter-point
  ,output flt-rec-18
  ,output filter-name-18
  ,output where-phrase-18
  ,output sort-phrase-18
  ,output where-phrase-rus-18
  ,output sort-phrase-rus-18
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-18
      ) no-error .
  assign
    l-filter-open-18 = false
  .
  if flt-rec-18 <> ?
    or v-sort-column-phrase > ""
  then do:
    define variable  parameter-2-18 as character no-undo .
    define variable  parameter-3-18 as character no-undo .
    define variable  parameter-4-18 as character no-undo .
    define variable  parameter-5-18 as character no-undo .
    define variable  parameter-6-18 as character no-undo .
    define variable  parameter-7-18 as character no-undo .
      assign
      parameter-3-18 =
                              "FOR EACH X_c-config"
      parameter-4-18 =
        (
          if ("X_c-config.param-code = buf_cnf.param-code                        and X_c-config.host-code = buf_cnf.host-code                        and X_c-config.obj-type = buf_cnf.obj-type and X_c-config.obj-code = buf_cnf.obj-code                        and X_c-config.beg-date = buf_cnf.beg-date and X_c-config.end-date = buf_cnf.end-date                        and X_c-config.db-num = buf_cnf.db-num                       " + " " + where-phrase-18) <> ""
          then substitute('                                        X_c-config.param-code = &1&2&1                                        and X_c-config.host-code = &3                                        and X_c-config.obj-type = &1&4&1                                        and X_c-config.obj-code = &5                                        and X_c-config.beg-date = &6                                        and X_c-config.end-date = &7                                        and X_c-config.db-num = &8                                      '                                       ,chr(34)                                       , buf_cnf.param-code                                       , buf_cnf.host-code                                       , buf_cnf.obj-type                                       , buf_cnf.obj-code                                       , buf_cnf.beg-date                                       , buf_cnf.end-date                                       , buf_cnf.db-num                                      )                            + " " + where-phrase-18
          else "true"
        )
      parameter-5-18 = (" " + "" + " " + "")
      parameter-6-18 = if sort-phrase-18 = ''
                           then
        (
        " " + "  " +
          " " + v-sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + "  " +
          " " + v-sort-column-phrase +
        " " + sort-phrase-18
        )
      parameter-7-18 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-18 =
          ("X_c-config.param-code = buf_cnf.param-code                        and X_c-config.host-code = buf_cnf.host-code                        and X_c-config.obj-type = buf_cnf.obj-type and X_c-config.obj-code = buf_cnf.obj-code                        and X_c-config.beg-date = buf_cnf.beg-date and X_c-config.end-date = buf_cnf.end-date                        and X_c-config.db-num = buf_cnf.db-num                       " + " " + where-phrase-18 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-cfg-hist :handle
                          ,input parameter-3-18
                          ,input parameter-4-18
                          ,input parameter-5-18
                          ,input parameter-6-18
                          ,input parameter-7-18
                          )
      .
      assign
        l-filter-open-18 = true
      .
    end.
    if l-filter-open-18 = false then do:
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
  if l-filter-open-18 = false then do:
    OPEN QUERY br-cfg-hist FOR EACH X_c-config
      where X_c-config.param-code = buf_cnf.param-code                        and X_c-config.host-code = buf_cnf.host-code                        and X_c-config.obj-type = buf_cnf.obj-type and X_c-config.obj-code = buf_cnf.obj-code                        and X_c-config.beg-date = buf_cnf.beg-date and X_c-config.end-date = buf_cnf.end-date                        and X_c-config.db-num = buf_cnf.db-num
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-hist-rec = recid( X_c-config )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-cfg-hist :handle:get-buffer-handle(1) = (buffer X_c-config:handle) then do:
      assign
      parameter-2-18 = (if p-find-next then "true":u else "false":u )
      parameter-4-18 =
        "where ":u + substitute('                                        X_c-config.param-code = &1&2&1                                        and X_c-config.host-code = &3                                        and X_c-config.obj-type = &1&4&1                                        and X_c-config.obj-code = &5                                        and X_c-config.beg-date = &6                                        and X_c-config.end-date = &7                                        and X_c-config.db-num = &8                                      '                                       ,chr(34)                                       , buf_cnf.param-code                                       , buf_cnf.host-code                                       , buf_cnf.obj-type                                       , buf_cnf.obj-code                                       , buf_cnf.beg-date                                       , buf_cnf.end-date                                       , buf_cnf.db-num                                      )                            + " ":u + where-phrase-18 + " ":u + p-find-condition + " " + ""
      parameter-5-18 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-cfg-hist :handle
                          ,input rowid(X_c-config)
                          ,input logical(parameter-2-18)
                          ,input no-lock
                          ,input (buffer X_c-config:handle)
                          ,input parameter-4-18
                          ,input parameter-5-18
                          ) no-error.
      .
      assign
        v-hist-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-18 = (if p-find-next then "true":u else "false":u )
      parameter-3-18 =  "FOR EACH X_c-config"
      parameter-4-18 =
        (
          if ("X_c-config.param-code = buf_cnf.param-code                        and X_c-config.host-code = buf_cnf.host-code                        and X_c-config.obj-type = buf_cnf.obj-type and X_c-config.obj-code = buf_cnf.obj-code                        and X_c-config.beg-date = buf_cnf.beg-date and X_c-config.end-date = buf_cnf.end-date                        and X_c-config.db-num = buf_cnf.db-num                       " + " " + where-phrase-18) <> ""
          then substitute('                                        X_c-config.param-code = &1&2&1                                        and X_c-config.host-code = &3                                        and X_c-config.obj-type = &1&4&1                                        and X_c-config.obj-code = &5                                        and X_c-config.beg-date = &6                                        and X_c-config.end-date = &7                                        and X_c-config.db-num = &8                                      '                                       ,chr(34)                                       , buf_cnf.param-code                                       , buf_cnf.host-code                                       , buf_cnf.obj-type                                       , buf_cnf.obj-code                                       , buf_cnf.beg-date                                       , buf_cnf.end-date                                       , buf_cnf.db-num                                      )                            + " " + where-phrase-18
          else "true"
        )
      parameter-5-18 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-18 = if sort-phrase-18 = ''
                           then
        (
        " " + "  " +
          " " + v-sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + "  " +
          " " + v-sort-column-phrase +
        " " + sort-phrase-18
        )
      parameter-7-18 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-cfg-hist :handle
                          ,input logical(parameter-2-18)
                          ,input no-lock
                          ,input parameter-3-18
                          ,input parameter-4-18
                          ,input parameter-5-18
                          ,input parameter-6-18
                          ,input parameter-7-18
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      v-hist-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
    end.
  end.
  else do:
    assign
      v-filter-point = v-filter-point0 + "all":U + chr(4) + v-filter-pointr
      frame d-cfg-hist:title = "История изменения параметров конфигурации" + chr(32)
    .
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-20  as logical   no-undo .
define variable  l-filter-open-20    as logical   .
define variable  flt-rec-20       as recid     no-undo .
define variable  filter-name-20      as character no-undo .
define variable  where-phrase-20     as character no-undo .
define variable  sort-phrase-20      as character no-undo .
define variable  where-phrase-rus-20 as character no-undo .
define variable  sort-phrase-rus-20  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input v-filter-point
  ,output flt-rec-20
  ,output filter-name-20
  ,output where-phrase-20
  ,output sort-phrase-20
  ,output where-phrase-rus-20
  ,output sort-phrase-rus-20
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-20
      ) no-error .
  assign
    l-filter-open-20 = false
  .
  if flt-rec-20 <> ?
    or v-sort-column-phrase > ""
  then do:
    define variable  parameter-2-20 as character no-undo .
    define variable  parameter-3-20 as character no-undo .
    define variable  parameter-4-20 as character no-undo .
    define variable  parameter-5-20 as character no-undo .
    define variable  parameter-6-20 as character no-undo .
    define variable  parameter-7-20 as character no-undo .
      assign
      parameter-3-20 =
                              "FOR EACH X_c-config"
      parameter-4-20 =
        (
          if ("true" + " " + where-phrase-20) <> ""
          then "true" + " " + where-phrase-20
          else "true"
        )
      parameter-5-20 = (" " + "" + " " + "")
      parameter-6-20 = if sort-phrase-20 = ''
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
        " " + sort-phrase-20
        )
      parameter-7-20 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-20 =
          ("true" + " " + where-phrase-20 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-cfg-hist :handle
                          ,input parameter-3-20
                          ,input parameter-4-20
                          ,input parameter-5-20
                          ,input parameter-6-20
                          ,input parameter-7-20
                          )
      .
      assign
        l-filter-open-20 = true
      .
    end.
    if l-filter-open-20 = false then do:
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
  if l-filter-open-20 = false then do:
    OPEN QUERY br-cfg-hist FOR EACH X_c-config
      where true
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-hist-rec = recid( X_c-config )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-cfg-hist :handle:get-buffer-handle(1) = (buffer X_c-config:handle) then do:
      assign
      parameter-2-20 = (if p-find-next then "true":u else "false":u )
      parameter-4-20 =
        "where ":u + "true" + " ":u + where-phrase-20 + " ":u + p-find-condition + " " + ""
      parameter-5-20 = " "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-cfg-hist :handle
                          ,input rowid(X_c-config)
                          ,input logical(parameter-2-20)
                          ,input no-lock
                          ,input (buffer X_c-config:handle)
                          ,input parameter-4-20
                          ,input parameter-5-20
                          ) no-error.
      .
      assign
        v-hist-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-20 = (if p-find-next then "true":u else "false":u )
      parameter-3-20 =  "FOR EACH X_c-config"
      parameter-4-20 =
        (
          if ("true" + " " + where-phrase-20) <> ""
          then "true" + " " + where-phrase-20
          else "true"
        )
      parameter-5-20 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-20 = if sort-phrase-20 = ''
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
        " " + sort-phrase-20
        )
      parameter-7-20 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-cfg-hist :handle
                          ,input logical(parameter-2-20)
                          ,input no-lock
                          ,input parameter-3-20
                          ,input parameter-4-20
                          ,input parameter-5-20
                          ,input parameter-6-20
                          ,input parameter-7-20
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      v-hist-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
  end.
  if not p-open-query then do:
    reposition br-cfg-hist to recid v-hist-rec no-error.
  end.
  if not p-open-query and v-fltopend-rowid[1] <> ? then do:
    query br-cfg-hist:handle:reposition-to-rowid(v-fltopend-rowid) No-ERROR.
  end.
  run waitfram-hide in this-procedure.
  apply "value-changed" to br-cfg-hist in frame d-cfg-hist .
  apply "entry" to br-cfg-hist .
END PROCEDURE.
PROCEDURE proc-b-sch :
assign
  tbl = 'c-config'
  join-tbl = 'X_c-config'
  fld = ""
  lab = ""
  spr = ""
  dim = '0'
  .
run fltfield-add in this-procedure('param-code', 'Название параметра', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('host-code', 'Фирма', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ('obj-type*obj-code', 'Объект', 'cli',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('beg-date', 'Начало действия параметра', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('end-date', 'Окончание действия параметра', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('corr-user-db-num', 'БД параметра', 'db',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('param-encoded', 'Кодировка', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('action', 'Действие', 'hist-action',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('corr-user-name', 'Изменил', 'usr',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('corr-date', 'Дата изменения', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('corr-time', 'Время изменения', 'time',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('corr-user-db-num', 'БД Изменения', 'db',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
Filter-Block:
DO ON STOP    UNDO Filter-Block, LEAVE Filter-Block
    ON ERROR   UNDO Filter-Block, LEAVE Filter-Block
    ON END-KEY UNDO Filter-Block, LEAVE Filter-Block :
  run gbl/filter.w ( INPUT parparentproc, INPUT v-filter-point, INPUT tbl, INPUT join-tbl, INPUT fld, INPUT lab, INPUT spr, INPUT dim ).
  run my-open-query in this-procedure ( input yes, input no, input '':U).
END.
END PROCEDURE.
FUNCTION get-action RETURNS CHARACTER
    ( p-action as integer ) :
  define variable dops as character no-undo.
    assign
    dops = entry (lookup (trim(string(p-action)), '99,1,2,3,4,9,51,79':U), 'Удаление,Создание,Изменение,Коррекция,Восстановление,Смена_кода,Смена_артик,Выключ.':U)
    no-error
  .
  return dops.
END FUNCTION.
