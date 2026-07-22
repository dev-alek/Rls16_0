block-level on error undo, throw.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
DEFINE INPUT     PARAMETER parParentProc  AS WIDGET-HANDLE NO-UNDO.
define input     parameter attr-option_   as character no-undo .
define input     parameter show-as        as character no-undo .
define input     parameter JoinType       as character no-undo .
define input     parameter Cli-Types      as character no-undo .
define input     parameter Curr-grp-name  as character no-undo .
define input     parameter NameOrCode     as character no-undo .
define input     parameter SupGds         as logical no-undo .
define input     parameter SupCOns        as logical no-undo .
define input     parameter SupServ        as logical no-undo .
define input     parameter BuyGds         as logical no-undo .
define input     parameter BuyCons        as logical no-undo .
define input     parameter BuyServ        as logical no-undo .
define input     parameter Wlim-Kr        as logical no-undo .
define input     parameter v-list-b       as logical   no-undo .
define input-output param  p-rid-list     as  character no-undo .
define input parameter filter-point as character no-undo .
define input parameter filter-point0 as character no-undo .
define input parameter sort-column-name as character no-undo .
define output parameter p-filter-name   as character  no-undo .
define input-output parameter v-doc-rec as recid no-undo .
def var vss-revision    as character no-undo init "$Revision$":U .
def var vss-author      as character no-undo init "$Author$":U .
def var vss-date        as character no-undo init "$Date$":U .
def var vss-workfile    as character no-undo init "$Workfile$":U .
def var vss-archive     as character no-undo init "$Archive$":U .
def var vss-description as character no-undo init "Список клиентов  - открытие запроса".
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
 define shared temp-table temp-list-buyer no-undo ~
field obj-type as character ~
field obj-code as integer   ~
index pi is primary unique  ~
obj-type ~
obj-code.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
DEFINE SHARED BUFFER X_clients FOR ub.clients.
DEFINE SHARED BUFFER x_temp-list-buyer FOR temp-list-buyer.
DEFINE SHARED QUERY CLi-ListB FOR X_clients
, x_temp-list-buyer
SCROLLING.
define variable v-list-cond as character no-undo.
def var l-query-was-opened as logical no-undo .
def var sort-column-phrase as character no-undo .
PROCEDURE Set-filter-name :
define input parameter v-filter-name as character no-undo .
  assign
  p-filter-name = v-filter-name
  .
END PROCEDURE.
run proc-main in this-procedure .
procedure proc-main :
  do
  on error undo, return error
  :
case sort-column-name :
  when "" then do:
    assign
      sort-column-phrase = ""
    .
  end.
  otherwise do:
    assign
      sort-column-phrase = "by " + sort-column-name
    .
  end.
end case.
define variable l-open-query as logical   no-undo .
CASE show-as :
  when ('орг':U + "-" + 'название':U + "-" + 'все':U + "-" + 'текущие':U) OR
  when ('чел':U + "-" + 'название':U + "-" + 'все':U + "-" + 'текущие':U) OR
  when ('скл':U + "-" + 'название':U + "-" + 'все':U + "-" + 'текущие':U) OR
  when ('маг':U + "-" + 'название':U + "-" + 'все':U + "-" + 'текущие':U) then do:
    CASE JoinType :
      when "Или" then do:
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-5  as logical   no-undo .
define variable  l-filter-open-5    as logical   .
define variable  flt-rec-5       as recid     no-undo .
define variable  filter-name-5      as character no-undo .
define variable  where-phrase-5     as character no-undo .
define variable  sort-phrase-5      as character no-undo .
define variable  where-phrase-rus-5 as character no-undo .
define variable  sort-phrase-rus-5  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-5
  ,output filter-name-5
  ,output where-phrase-5
  ,output sort-phrase-5
  ,output where-phrase-rus-5
  ,output sort-phrase-rus-5
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-5
      ) no-error .
  assign
    l-filter-open-5 = false
  .
  if flt-rec-5 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-5 as character no-undo .
    define variable  parameter-3-5 as character no-undo .
    define variable  parameter-4-5 as character no-undo .
    define variable  parameter-5-5 as character no-undo .
    define variable  parameter-6-5 as character no-undo .
    define variable  parameter-7-5 as character no-undo .
      assign
      parameter-3-5 =
                              "FOR EACH X_clients"
      parameter-4-5 =
        (
          if (" X_clients.obj-name contains NameOrCode                             AND X_clients.obj-type = Cli-Types                             AND X_clients.stts = 0                             AND (  ( SupGds = no and SupCons = no and BuyGds  = no and BuyCons = no and BuyServ = no and WLim-kr = no ) OR   ( if SupGds = yes AND X_clients.sup-gds = yes then yes else no ) OR     ( if SupCons = yes AND X_clients.sup-cons = yes then yes else no ) OR   ( if BuyGds = yes AND X_clients.buy-gds = yes  then yes else no ) OR     ( if BuyCons = yes AND X_clients.buy-cons = yes then yes else no ) OR   ( if BuyServ = yes AND X_clients.buy-serv = yes then yes else no ) OR   ( if WLim-kr = yes AND X_clients.lim-kr <> 0 then yes else no ) ) " + " " + where-phrase-5) <> ""
          then  (substitute('X_clients.obj-name contains &1&2&1                             AND X_clients.obj-type = &1&3&1                            AND X_clients.stts = 0                             AND ', chr(34), NameOrCode, Cli-Types) +  substitute('(  ( &1 = no and &2 = no and &3  = no and &4 = no and &5 = no and &6 = no ) OR   ( if &1 = yes AND X_clients.sup-gds = yes then yes else no ) OR     ( if &2 = yes AND X_clients.sup-cons = yes then yes else no ) OR   ( if &3 = yes AND X_clients.buy-gds = yes  then yes else no ) OR     ( if &4 = yes AND X_clients.buy-cons = yes then yes else no ) OR   ( if &5 = yes AND X_clients.buy-serv = yes then yes else no ) OR   ( if &6 = yes AND X_clients.lim-kr <> 0 then yes else no ) )',  SupGds,  SupCons, BuyGds, BuyCons, BuyServ, WLim-kr))  + " " + where-phrase-5
          else "true"
        )
      parameter-5-5 = (" " + "" + " " + substitute(', first x_temp-list-buyer NO-LOCK WHERE (&1 = NO OR (x_temp-list-buyer.obj-type =   X_clients.obj-type AND              x_temp-list-buyer.obj-code =   X_clients.obj-code))'                                              ,v-list-b))
      parameter-6-5 = if sort-phrase-5 = ''
                           then
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + " BY X_clients.obj-name  "
        )
                           else
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + sort-phrase-5
        )
      parameter-7-5 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-5 =
          (" X_clients.obj-name contains NameOrCode                             AND X_clients.obj-type = Cli-Types                             AND X_clients.stts = 0                             AND (  ( SupGds = no and SupCons = no and BuyGds  = no and BuyCons = no and BuyServ = no and WLim-kr = no ) OR   ( if SupGds = yes AND X_clients.sup-gds = yes then yes else no ) OR     ( if SupCons = yes AND X_clients.sup-cons = yes then yes else no ) OR   ( if BuyGds = yes AND X_clients.buy-gds = yes  then yes else no ) OR     ( if BuyCons = yes AND X_clients.buy-cons = yes then yes else no ) OR   ( if BuyServ = yes AND X_clients.buy-serv = yes then yes else no ) OR   ( if WLim-kr = yes AND X_clients.lim-kr <> 0 then yes else no ) ) " + " " + where-phrase-5 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query cli-listB:handle
                          ,input parameter-3-5
                          ,input parameter-4-5
                          ,input parameter-5-5
                          ,input parameter-6-5
                          ,input parameter-7-5
                          )
      .
      assign
        l-filter-open-5 = true
      .
    end.
    if l-filter-open-5 = false then do:
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
  if l-filter-open-5 = false then do:
    OPEN QUERY CLi-ListB FOR EACH X_clients no-lock
      where  X_clients.obj-name contains NameOrCode                             AND X_clients.obj-type = Cli-Types                             AND X_clients.stts = 0                             AND (  ( SupGds = no and SupCons = no and BuyGds  = no and BuyCons = no and BuyServ = no and WLim-kr = no ) OR   ( if SupGds = yes AND X_clients.sup-gds = yes then yes else no ) OR     ( if SupCons = yes AND X_clients.sup-cons = yes then yes else no ) OR   ( if BuyGds = yes AND X_clients.buy-gds = yes  then yes else no ) OR     ( if BuyCons = yes AND X_clients.buy-cons = yes then yes else no ) OR   ( if BuyServ = yes AND X_clients.buy-serv = yes then yes else no ) OR   ( if WLim-kr = yes AND X_clients.lim-kr <> 0 then yes else no ) )
    , first x_temp-list-buyer NO-LOCK WHERE (v-list-b = NO OR (x_temp-list-buyer.obj-type =   X_clients.obj-type AND              x_temp-list-buyer.obj-code =   X_clients.obj-code))
       BY X_clients.obj-name
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( ub.clients )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query cli-listB:handle:get-buffer-handle(1) = (buffer X_clients:handle) then do:
      assign
      parameter-2-5 = (if p-find-next then "true":u else "false":u )
      parameter-4-5 =
        "where ":u +  (substitute('X_clients.obj-name contains &1&2&1                             AND X_clients.obj-type = &1&3&1                            AND X_clients.stts = 0                             AND ', chr(34), NameOrCode, Cli-Types) +  substitute('(  ( &1 = no and &2 = no and &3  = no and &4 = no and &5 = no and &6 = no ) OR   ( if &1 = yes AND X_clients.sup-gds = yes then yes else no ) OR     ( if &2 = yes AND X_clients.sup-cons = yes then yes else no ) OR   ( if &3 = yes AND X_clients.buy-gds = yes  then yes else no ) OR     ( if &4 = yes AND X_clients.buy-cons = yes then yes else no ) OR   ( if &5 = yes AND X_clients.buy-serv = yes then yes else no ) OR   ( if &6 = yes AND X_clients.lim-kr <> 0 then yes else no ) )',  SupGds,  SupCons, BuyGds, BuyCons, BuyServ, WLim-kr))  + " ":u + where-phrase-5 + " ":u + p-find-condition + " " + ""
      parameter-5-5 = " "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query cli-listB:handle
                          ,input rowid(ub.clients)
                          ,input logical(parameter-2-5)
                          ,input no-lock
                          ,input (buffer ub.clients:handle)
                          ,input parameter-4-5
                          ,input parameter-5-5
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-5 = (if p-find-next then "true":u else "false":u )
      parameter-3-5 =  "FOR EACH X_clients"
      parameter-4-5 =
        (
          if (" X_clients.obj-name contains NameOrCode                             AND X_clients.obj-type = Cli-Types                             AND X_clients.stts = 0                             AND (  ( SupGds = no and SupCons = no and BuyGds  = no and BuyCons = no and BuyServ = no and WLim-kr = no ) OR   ( if SupGds = yes AND X_clients.sup-gds = yes then yes else no ) OR     ( if SupCons = yes AND X_clients.sup-cons = yes then yes else no ) OR   ( if BuyGds = yes AND X_clients.buy-gds = yes  then yes else no ) OR     ( if BuyCons = yes AND X_clients.buy-cons = yes then yes else no ) OR   ( if BuyServ = yes AND X_clients.buy-serv = yes then yes else no ) OR   ( if WLim-kr = yes AND X_clients.lim-kr <> 0 then yes else no ) ) " + " " + where-phrase-5) <> ""
          then  (substitute('X_clients.obj-name contains &1&2&1                             AND X_clients.obj-type = &1&3&1                            AND X_clients.stts = 0                             AND ', chr(34), NameOrCode, Cli-Types) +  substitute('(  ( &1 = no and &2 = no and &3  = no and &4 = no and &5 = no and &6 = no ) OR   ( if &1 = yes AND X_clients.sup-gds = yes then yes else no ) OR     ( if &2 = yes AND X_clients.sup-cons = yes then yes else no ) OR   ( if &3 = yes AND X_clients.buy-gds = yes  then yes else no ) OR     ( if &4 = yes AND X_clients.buy-cons = yes then yes else no ) OR   ( if &5 = yes AND X_clients.buy-serv = yes then yes else no ) OR   ( if &6 = yes AND X_clients.lim-kr <> 0 then yes else no ) )',  SupGds,  SupCons, BuyGds, BuyCons, BuyServ, WLim-kr))  + " " + where-phrase-5
          else "true"
        )
      parameter-5-5 = (" " + "" + " " + substitute(', first x_temp-list-buyer NO-LOCK WHERE (&1 = NO OR (x_temp-list-buyer.obj-type =   X_clients.obj-type AND              x_temp-list-buyer.obj-code =   X_clients.obj-code))'                                              ,v-list-b) + " " + p-find-condition)
      parameter-6-5 = if sort-phrase-5 = ''
                           then
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + " BY X_clients.obj-name  "
        )
                           else
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + sort-phrase-5
        )
      parameter-7-5 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query cli-listB:handle
                          ,input logical(parameter-2-5)
                          ,input no-lock
                          ,input parameter-3-5
                          ,input parameter-4-5
                          ,input parameter-5-5
                          ,input parameter-6-5
                          ,input parameter-7-5
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      v-doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
      end.
      when "NO" then  do:
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-7  as logical   no-undo .
define variable  l-filter-open-7    as logical   .
define variable  flt-rec-7       as recid     no-undo .
define variable  filter-name-7      as character no-undo .
define variable  where-phrase-7     as character no-undo .
define variable  sort-phrase-7      as character no-undo .
define variable  where-phrase-rus-7 as character no-undo .
define variable  sort-phrase-rus-7  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-7
  ,output filter-name-7
  ,output where-phrase-7
  ,output sort-phrase-7
  ,output where-phrase-rus-7
  ,output sort-phrase-rus-7
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-7
      ) no-error .
  assign
    l-filter-open-7 = false
  .
  if flt-rec-7 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-7 as character no-undo .
    define variable  parameter-3-7 as character no-undo .
    define variable  parameter-4-7 as character no-undo .
    define variable  parameter-5-7 as character no-undo .
    define variable  parameter-6-7 as character no-undo .
    define variable  parameter-7-7 as character no-undo .
      assign
      parameter-3-7 =
                              "FOR EACH X_clients"
      parameter-4-7 =
        (
          if (" X_clients.obj-name contains NameOrCode                             AND X_clients.obj-type = Cli-Types                             AND X_clients.stts = 0 " + " " + where-phrase-7) <> ""
          then  substitute('X_clients.obj-name contains &1&2&1                             AND X_clients.obj-type = &1&3&1                             AND X_clients.stts = 0 ', chr(34), NameOrCode, Cli-Types) + " " + where-phrase-7
          else "true"
        )
      parameter-5-7 = (" " + "" + " " + substitute(', first x_temp-list-buyer NO-LOCK WHERE (&1 = NO OR (x_temp-list-buyer.obj-type =   X_clients.obj-type AND              x_temp-list-buyer.obj-code =   X_clients.obj-code))'                                              ,v-list-b))
      parameter-6-7 = if sort-phrase-7 = ''
                           then
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + " BY X_clients.obj-name  "
        )
                           else
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + sort-phrase-7
        )
      parameter-7-7 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-7 =
          (" X_clients.obj-name contains NameOrCode                             AND X_clients.obj-type = Cli-Types                             AND X_clients.stts = 0 " + " " + where-phrase-7 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query cli-listB:handle
                          ,input parameter-3-7
                          ,input parameter-4-7
                          ,input parameter-5-7
                          ,input parameter-6-7
                          ,input parameter-7-7
                          )
      .
      assign
        l-filter-open-7 = true
      .
    end.
    if l-filter-open-7 = false then do:
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
  if l-filter-open-7 = false then do:
    OPEN QUERY CLi-ListB FOR EACH X_clients no-lock
      where  X_clients.obj-name contains NameOrCode                             AND X_clients.obj-type = Cli-Types                             AND X_clients.stts = 0
    , first x_temp-list-buyer NO-LOCK WHERE (v-list-b = NO OR (x_temp-list-buyer.obj-type =   X_clients.obj-type AND              x_temp-list-buyer.obj-code =   X_clients.obj-code))
       BY X_clients.obj-name
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( ub.clients )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query cli-listB:handle:get-buffer-handle(1) = (buffer X_clients:handle) then do:
      assign
      parameter-2-7 = (if p-find-next then "true":u else "false":u )
      parameter-4-7 =
        "where ":u +  substitute('X_clients.obj-name contains &1&2&1                             AND X_clients.obj-type = &1&3&1                             AND X_clients.stts = 0 ', chr(34), NameOrCode, Cli-Types) + " ":u + where-phrase-7 + " ":u + p-find-condition + " " + ""
      parameter-5-7 = " "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query cli-listB:handle
                          ,input rowid(ub.clients)
                          ,input logical(parameter-2-7)
                          ,input no-lock
                          ,input (buffer ub.clients:handle)
                          ,input parameter-4-7
                          ,input parameter-5-7
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-7 = (if p-find-next then "true":u else "false":u )
      parameter-3-7 =  "FOR EACH X_clients"
      parameter-4-7 =
        (
          if (" X_clients.obj-name contains NameOrCode                             AND X_clients.obj-type = Cli-Types                             AND X_clients.stts = 0 " + " " + where-phrase-7) <> ""
          then  substitute('X_clients.obj-name contains &1&2&1                             AND X_clients.obj-type = &1&3&1                             AND X_clients.stts = 0 ', chr(34), NameOrCode, Cli-Types) + " " + where-phrase-7
          else "true"
        )
      parameter-5-7 = (" " + "" + " " + substitute(', first x_temp-list-buyer NO-LOCK WHERE (&1 = NO OR (x_temp-list-buyer.obj-type =   X_clients.obj-type AND              x_temp-list-buyer.obj-code =   X_clients.obj-code))'                                              ,v-list-b) + " " + p-find-condition)
      parameter-6-7 = if sort-phrase-7 = ''
                           then
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + " BY X_clients.obj-name  "
        )
                           else
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + sort-phrase-7
        )
      parameter-7-7 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query cli-listB:handle
                          ,input logical(parameter-2-7)
                          ,input no-lock
                          ,input parameter-3-7
                          ,input parameter-4-7
                          ,input parameter-5-7
                          ,input parameter-6-7
                          ,input parameter-7-7
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      v-doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
      end.
    END CASE .
  end.
  when ('орг':U + "-" + 'название':U + "-" + 'все':U + "-" + 'все':U) OR
  when ('чел':U + "-" + 'название':U + "-" + 'все':U + "-" + 'все':U) OR
  when ('скл':U + "-" + 'название':U + "-" + 'все':U + "-" + 'все':U) OR
  when ('маг':U + "-" + 'название':U + "-" + 'все':U + "-" + 'все':U) then do:
    CASE JoinType :
      when "Или" then do:
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-9  as logical   no-undo .
define variable  l-filter-open-9    as logical   .
define variable  flt-rec-9       as recid     no-undo .
define variable  filter-name-9      as character no-undo .
define variable  where-phrase-9     as character no-undo .
define variable  sort-phrase-9      as character no-undo .
define variable  where-phrase-rus-9 as character no-undo .
define variable  sort-phrase-rus-9  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-9
  ,output filter-name-9
  ,output where-phrase-9
  ,output sort-phrase-9
  ,output where-phrase-rus-9
  ,output sort-phrase-rus-9
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-9
      ) no-error .
  assign
    l-filter-open-9 = false
  .
  if flt-rec-9 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-9 as character no-undo .
    define variable  parameter-3-9 as character no-undo .
    define variable  parameter-4-9 as character no-undo .
    define variable  parameter-5-9 as character no-undo .
    define variable  parameter-6-9 as character no-undo .
    define variable  parameter-7-9 as character no-undo .
      assign
      parameter-3-9 =
                              "FOR EACH X_clients"
      parameter-4-9 =
        (
          if (" X_clients.obj-name contains NameOrCode                             AND X_clients.obj-type = Cli-Types                             AND (  ( SupGds = no and SupCons = no and BuyGds  = no and BuyCons = no and BuyServ = no and WLim-kr = no ) OR   ( if SupGds = yes AND X_clients.sup-gds = yes then yes else no ) OR     ( if SupCons = yes AND X_clients.sup-cons = yes then yes else no ) OR   ( if BuyGds = yes AND X_clients.buy-gds = yes  then yes else no ) OR     ( if BuyCons = yes AND X_clients.buy-cons = yes then yes else no ) OR   ( if BuyServ = yes AND X_clients.buy-serv = yes then yes else no ) OR   ( if WLim-kr = yes AND X_clients.lim-kr <> 0 then yes else no ) ) " + " " + where-phrase-9) <> ""
          then  (substitute('X_clients.obj-name contains &1&2&1                             AND X_clients.obj-type = &1&3&1                             AND ', chr(34), NameOrCode, Cli-Types) +  substitute('(  ( &1 = no and &2 = no and &3  = no and &4 = no and &5 = no and &6 = no ) OR   ( if &1 = yes AND X_clients.sup-gds = yes then yes else no ) OR     ( if &2 = yes AND X_clients.sup-cons = yes then yes else no ) OR   ( if &3 = yes AND X_clients.buy-gds = yes  then yes else no ) OR     ( if &4 = yes AND X_clients.buy-cons = yes then yes else no ) OR   ( if &5 = yes AND X_clients.buy-serv = yes then yes else no ) OR   ( if &6 = yes AND X_clients.lim-kr <> 0 then yes else no ) )',  SupGds,  SupCons, BuyGds, BuyCons, BuyServ, WLim-kr))  + " " + where-phrase-9
          else "true"
        )
      parameter-5-9 = (" " + "" + " " + substitute(', first x_temp-list-buyer NO-LOCK WHERE (&1 = NO OR (x_temp-list-buyer.obj-type =   X_clients.obj-type AND              x_temp-list-buyer.obj-code =   X_clients.obj-code))'                                              ,v-list-b))
      parameter-6-9 = if sort-phrase-9 = ''
                           then
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + " BY X_clients.obj-name  "
        )
                           else
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + sort-phrase-9
        )
      parameter-7-9 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-9 =
          (" X_clients.obj-name contains NameOrCode                             AND X_clients.obj-type = Cli-Types                             AND (  ( SupGds = no and SupCons = no and BuyGds  = no and BuyCons = no and BuyServ = no and WLim-kr = no ) OR   ( if SupGds = yes AND X_clients.sup-gds = yes then yes else no ) OR     ( if SupCons = yes AND X_clients.sup-cons = yes then yes else no ) OR   ( if BuyGds = yes AND X_clients.buy-gds = yes  then yes else no ) OR     ( if BuyCons = yes AND X_clients.buy-cons = yes then yes else no ) OR   ( if BuyServ = yes AND X_clients.buy-serv = yes then yes else no ) OR   ( if WLim-kr = yes AND X_clients.lim-kr <> 0 then yes else no ) ) " + " " + where-phrase-9 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query cli-listB:handle
                          ,input parameter-3-9
                          ,input parameter-4-9
                          ,input parameter-5-9
                          ,input parameter-6-9
                          ,input parameter-7-9
                          )
      .
      assign
        l-filter-open-9 = true
      .
    end.
    if l-filter-open-9 = false then do:
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
  if l-filter-open-9 = false then do:
    OPEN QUERY CLi-ListB FOR EACH X_clients no-lock
      where  X_clients.obj-name contains NameOrCode                             AND X_clients.obj-type = Cli-Types                             AND (  ( SupGds = no and SupCons = no and BuyGds  = no and BuyCons = no and BuyServ = no and WLim-kr = no ) OR   ( if SupGds = yes AND X_clients.sup-gds = yes then yes else no ) OR     ( if SupCons = yes AND X_clients.sup-cons = yes then yes else no ) OR   ( if BuyGds = yes AND X_clients.buy-gds = yes  then yes else no ) OR     ( if BuyCons = yes AND X_clients.buy-cons = yes then yes else no ) OR   ( if BuyServ = yes AND X_clients.buy-serv = yes then yes else no ) OR   ( if WLim-kr = yes AND X_clients.lim-kr <> 0 then yes else no ) )
    , first x_temp-list-buyer NO-LOCK WHERE (v-list-b = NO OR (x_temp-list-buyer.obj-type =   X_clients.obj-type AND              x_temp-list-buyer.obj-code =   X_clients.obj-code))
       BY X_clients.obj-name
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( ub.clients )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query cli-listB:handle:get-buffer-handle(1) = (buffer X_clients:handle) then do:
      assign
      parameter-2-9 = (if p-find-next then "true":u else "false":u )
      parameter-4-9 =
        "where ":u +  (substitute('X_clients.obj-name contains &1&2&1                             AND X_clients.obj-type = &1&3&1                             AND ', chr(34), NameOrCode, Cli-Types) +  substitute('(  ( &1 = no and &2 = no and &3  = no and &4 = no and &5 = no and &6 = no ) OR   ( if &1 = yes AND X_clients.sup-gds = yes then yes else no ) OR     ( if &2 = yes AND X_clients.sup-cons = yes then yes else no ) OR   ( if &3 = yes AND X_clients.buy-gds = yes  then yes else no ) OR     ( if &4 = yes AND X_clients.buy-cons = yes then yes else no ) OR   ( if &5 = yes AND X_clients.buy-serv = yes then yes else no ) OR   ( if &6 = yes AND X_clients.lim-kr <> 0 then yes else no ) )',  SupGds,  SupCons, BuyGds, BuyCons, BuyServ, WLim-kr))  + " ":u + where-phrase-9 + " ":u + p-find-condition + " " + ""
      parameter-5-9 = " "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query cli-listB:handle
                          ,input rowid(ub.clients)
                          ,input logical(parameter-2-9)
                          ,input no-lock
                          ,input (buffer ub.clients:handle)
                          ,input parameter-4-9
                          ,input parameter-5-9
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-9 = (if p-find-next then "true":u else "false":u )
      parameter-3-9 =  "FOR EACH X_clients"
      parameter-4-9 =
        (
          if (" X_clients.obj-name contains NameOrCode                             AND X_clients.obj-type = Cli-Types                             AND (  ( SupGds = no and SupCons = no and BuyGds  = no and BuyCons = no and BuyServ = no and WLim-kr = no ) OR   ( if SupGds = yes AND X_clients.sup-gds = yes then yes else no ) OR     ( if SupCons = yes AND X_clients.sup-cons = yes then yes else no ) OR   ( if BuyGds = yes AND X_clients.buy-gds = yes  then yes else no ) OR     ( if BuyCons = yes AND X_clients.buy-cons = yes then yes else no ) OR   ( if BuyServ = yes AND X_clients.buy-serv = yes then yes else no ) OR   ( if WLim-kr = yes AND X_clients.lim-kr <> 0 then yes else no ) ) " + " " + where-phrase-9) <> ""
          then  (substitute('X_clients.obj-name contains &1&2&1                             AND X_clients.obj-type = &1&3&1                             AND ', chr(34), NameOrCode, Cli-Types) +  substitute('(  ( &1 = no and &2 = no and &3  = no and &4 = no and &5 = no and &6 = no ) OR   ( if &1 = yes AND X_clients.sup-gds = yes then yes else no ) OR     ( if &2 = yes AND X_clients.sup-cons = yes then yes else no ) OR   ( if &3 = yes AND X_clients.buy-gds = yes  then yes else no ) OR     ( if &4 = yes AND X_clients.buy-cons = yes then yes else no ) OR   ( if &5 = yes AND X_clients.buy-serv = yes then yes else no ) OR   ( if &6 = yes AND X_clients.lim-kr <> 0 then yes else no ) )',  SupGds,  SupCons, BuyGds, BuyCons, BuyServ, WLim-kr))  + " " + where-phrase-9
          else "true"
        )
      parameter-5-9 = (" " + "" + " " + substitute(', first x_temp-list-buyer NO-LOCK WHERE (&1 = NO OR (x_temp-list-buyer.obj-type =   X_clients.obj-type AND              x_temp-list-buyer.obj-code =   X_clients.obj-code))'                                              ,v-list-b) + " " + p-find-condition)
      parameter-6-9 = if sort-phrase-9 = ''
                           then
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + " BY X_clients.obj-name  "
        )
                           else
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + sort-phrase-9
        )
      parameter-7-9 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query cli-listB:handle
                          ,input logical(parameter-2-9)
                          ,input no-lock
                          ,input parameter-3-9
                          ,input parameter-4-9
                          ,input parameter-5-9
                          ,input parameter-6-9
                          ,input parameter-7-9
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      v-doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
      end.
      when "NO" then  do:
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-11  as logical   no-undo .
define variable  l-filter-open-11    as logical   .
define variable  flt-rec-11       as recid     no-undo .
define variable  filter-name-11      as character no-undo .
define variable  where-phrase-11     as character no-undo .
define variable  sort-phrase-11      as character no-undo .
define variable  where-phrase-rus-11 as character no-undo .
define variable  sort-phrase-rus-11  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-11
  ,output filter-name-11
  ,output where-phrase-11
  ,output sort-phrase-11
  ,output where-phrase-rus-11
  ,output sort-phrase-rus-11
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-11
      ) no-error .
  assign
    l-filter-open-11 = false
  .
  if flt-rec-11 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-11 as character no-undo .
    define variable  parameter-3-11 as character no-undo .
    define variable  parameter-4-11 as character no-undo .
    define variable  parameter-5-11 as character no-undo .
    define variable  parameter-6-11 as character no-undo .
    define variable  parameter-7-11 as character no-undo .
      assign
      parameter-3-11 =
                              "FOR EACH X_clients"
      parameter-4-11 =
        (
          if (" X_clients.obj-name contains NameOrCode                             AND X_clients.obj-type = Cli-Types " + " " + where-phrase-11) <> ""
          then  substitute('X_clients.obj-name contains &1&2&1                             AND X_clients.obj-type = &1&3&1 ', chr(34), NameOrCode, Cli-Types) + " " + where-phrase-11
          else "true"
        )
      parameter-5-11 = (" " + "" + " " + substitute(', first x_temp-list-buyer NO-LOCK WHERE (&1 = NO OR (x_temp-list-buyer.obj-type =   X_clients.obj-type AND              x_temp-list-buyer.obj-code =   X_clients.obj-code))'                                              ,v-list-b))
      parameter-6-11 = if sort-phrase-11 = ''
                           then
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + " BY X_clients.obj-name  "
        )
                           else
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + sort-phrase-11
        )
      parameter-7-11 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-11 =
          (" X_clients.obj-name contains NameOrCode                             AND X_clients.obj-type = Cli-Types " + " " + where-phrase-11 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query cli-listB:handle
                          ,input parameter-3-11
                          ,input parameter-4-11
                          ,input parameter-5-11
                          ,input parameter-6-11
                          ,input parameter-7-11
                          )
      .
      assign
        l-filter-open-11 = true
      .
    end.
    if l-filter-open-11 = false then do:
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
  if l-filter-open-11 = false then do:
    OPEN QUERY CLi-ListB FOR EACH X_clients no-lock
      where  X_clients.obj-name contains NameOrCode                             AND X_clients.obj-type = Cli-Types
    , first x_temp-list-buyer NO-LOCK WHERE (v-list-b = NO OR (x_temp-list-buyer.obj-type =   X_clients.obj-type AND              x_temp-list-buyer.obj-code =   X_clients.obj-code))
       BY X_clients.obj-name
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( ub.clients )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query cli-listB:handle:get-buffer-handle(1) = (buffer X_clients:handle) then do:
      assign
      parameter-2-11 = (if p-find-next then "true":u else "false":u )
      parameter-4-11 =
        "where ":u +  substitute('X_clients.obj-name contains &1&2&1                             AND X_clients.obj-type = &1&3&1 ', chr(34), NameOrCode, Cli-Types) + " ":u + where-phrase-11 + " ":u + p-find-condition + " " + ""
      parameter-5-11 = " "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query cli-listB:handle
                          ,input rowid(ub.clients)
                          ,input logical(parameter-2-11)
                          ,input no-lock
                          ,input (buffer ub.clients:handle)
                          ,input parameter-4-11
                          ,input parameter-5-11
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-11 = (if p-find-next then "true":u else "false":u )
      parameter-3-11 =  "FOR EACH X_clients"
      parameter-4-11 =
        (
          if (" X_clients.obj-name contains NameOrCode                             AND X_clients.obj-type = Cli-Types " + " " + where-phrase-11) <> ""
          then  substitute('X_clients.obj-name contains &1&2&1                             AND X_clients.obj-type = &1&3&1 ', chr(34), NameOrCode, Cli-Types) + " " + where-phrase-11
          else "true"
        )
      parameter-5-11 = (" " + "" + " " + substitute(', first x_temp-list-buyer NO-LOCK WHERE (&1 = NO OR (x_temp-list-buyer.obj-type =   X_clients.obj-type AND              x_temp-list-buyer.obj-code =   X_clients.obj-code))'                                              ,v-list-b) + " " + p-find-condition)
      parameter-6-11 = if sort-phrase-11 = ''
                           then
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + " BY X_clients.obj-name  "
        )
                           else
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + sort-phrase-11
        )
      parameter-7-11 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query cli-listB:handle
                          ,input logical(parameter-2-11)
                          ,input no-lock
                          ,input parameter-3-11
                          ,input parameter-4-11
                          ,input parameter-5-11
                          ,input parameter-6-11
                          ,input parameter-7-11
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      v-doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
      end.
    END CASE .
  end.
  when ('орг':U + "-" + 'название':U + "-" + 'все':U + "-" + 'удаленные':U) OR
  when ('чел':U + "-" + 'название':U + "-" + 'все':U + "-" + 'удаленные':U) OR
  when ('скл':U + "-" + 'название':U + "-" + 'все':U + "-" + 'удаленные':U) OR
  when ('маг':U + "-" + 'название':U + "-" + 'все':U + "-" + 'удаленные':U) then do:
    CASE JoinType :
      when "Или" then  do:
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-13  as logical   no-undo .
define variable  l-filter-open-13    as logical   .
define variable  flt-rec-13       as recid     no-undo .
define variable  filter-name-13      as character no-undo .
define variable  where-phrase-13     as character no-undo .
define variable  sort-phrase-13      as character no-undo .
define variable  where-phrase-rus-13 as character no-undo .
define variable  sort-phrase-rus-13  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-13
  ,output filter-name-13
  ,output where-phrase-13
  ,output sort-phrase-13
  ,output where-phrase-rus-13
  ,output sort-phrase-rus-13
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-13
      ) no-error .
  assign
    l-filter-open-13 = false
  .
  if flt-rec-13 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-13 as character no-undo .
    define variable  parameter-3-13 as character no-undo .
    define variable  parameter-4-13 as character no-undo .
    define variable  parameter-5-13 as character no-undo .
    define variable  parameter-6-13 as character no-undo .
    define variable  parameter-7-13 as character no-undo .
      assign
      parameter-3-13 =
                              "FOR EACH X_clients"
      parameter-4-13 =
        (
          if (" X_clients.obj-name contains NameOrCode                             AND X_clients.obj-type = Cli-Types                             AND X_clients.stts <> 0                             AND (  ( SupGds = no and SupCons = no and BuyGds  = no and BuyCons = no and BuyServ = no and WLim-kr = no ) OR   ( if SupGds = yes AND X_clients.sup-gds = yes then yes else no ) OR     ( if SupCons = yes AND X_clients.sup-cons = yes then yes else no ) OR   ( if BuyGds = yes AND X_clients.buy-gds = yes  then yes else no ) OR     ( if BuyCons = yes AND X_clients.buy-cons = yes then yes else no ) OR   ( if BuyServ = yes AND X_clients.buy-serv = yes then yes else no ) OR   ( if WLim-kr = yes AND X_clients.lim-kr <> 0 then yes else no ) ) " + " " + where-phrase-13) <> ""
          then  (substitute('X_clients.obj-name contains &1&2&1                             AND X_clients.obj-type = &1&3&1                             AND X_clients.stts <> 0                             AND ', chr(34), NameOrCode, Cli-Types) +  substitute('(  ( &1 = no and &2 = no and &3  = no and &4 = no and &5 = no and &6 = no ) OR   ( if &1 = yes AND X_clients.sup-gds = yes then yes else no ) OR     ( if &2 = yes AND X_clients.sup-cons = yes then yes else no ) OR   ( if &3 = yes AND X_clients.buy-gds = yes  then yes else no ) OR     ( if &4 = yes AND X_clients.buy-cons = yes then yes else no ) OR   ( if &5 = yes AND X_clients.buy-serv = yes then yes else no ) OR   ( if &6 = yes AND X_clients.lim-kr <> 0 then yes else no ) )',  SupGds,  SupCons, BuyGds, BuyCons, BuyServ, WLim-kr))  + " " + where-phrase-13
          else "true"
        )
      parameter-5-13 = (" " + "" + " " + substitute(', first x_temp-list-buyer NO-LOCK WHERE (&1 = NO OR (x_temp-list-buyer.obj-type =   X_clients.obj-type AND              x_temp-list-buyer.obj-code =   X_clients.obj-code))'                                              ,v-list-b))
      parameter-6-13 = if sort-phrase-13 = ''
                           then
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + " BY X_clients.obj-name  "
        )
                           else
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + sort-phrase-13
        )
      parameter-7-13 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-13 =
          (" X_clients.obj-name contains NameOrCode                             AND X_clients.obj-type = Cli-Types                             AND X_clients.stts <> 0                             AND (  ( SupGds = no and SupCons = no and BuyGds  = no and BuyCons = no and BuyServ = no and WLim-kr = no ) OR   ( if SupGds = yes AND X_clients.sup-gds = yes then yes else no ) OR     ( if SupCons = yes AND X_clients.sup-cons = yes then yes else no ) OR   ( if BuyGds = yes AND X_clients.buy-gds = yes  then yes else no ) OR     ( if BuyCons = yes AND X_clients.buy-cons = yes then yes else no ) OR   ( if BuyServ = yes AND X_clients.buy-serv = yes then yes else no ) OR   ( if WLim-kr = yes AND X_clients.lim-kr <> 0 then yes else no ) ) " + " " + where-phrase-13 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query cli-listB:handle
                          ,input parameter-3-13
                          ,input parameter-4-13
                          ,input parameter-5-13
                          ,input parameter-6-13
                          ,input parameter-7-13
                          )
      .
      assign
        l-filter-open-13 = true
      .
    end.
    if l-filter-open-13 = false then do:
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
  if l-filter-open-13 = false then do:
    OPEN QUERY CLi-ListB FOR EACH X_clients no-lock
      where  X_clients.obj-name contains NameOrCode                             AND X_clients.obj-type = Cli-Types                             AND X_clients.stts <> 0                             AND (  ( SupGds = no and SupCons = no and BuyGds  = no and BuyCons = no and BuyServ = no and WLim-kr = no ) OR   ( if SupGds = yes AND X_clients.sup-gds = yes then yes else no ) OR     ( if SupCons = yes AND X_clients.sup-cons = yes then yes else no ) OR   ( if BuyGds = yes AND X_clients.buy-gds = yes  then yes else no ) OR     ( if BuyCons = yes AND X_clients.buy-cons = yes then yes else no ) OR   ( if BuyServ = yes AND X_clients.buy-serv = yes then yes else no ) OR   ( if WLim-kr = yes AND X_clients.lim-kr <> 0 then yes else no ) )
    , first x_temp-list-buyer NO-LOCK WHERE (v-list-b = NO OR (x_temp-list-buyer.obj-type =   X_clients.obj-type AND              x_temp-list-buyer.obj-code =   X_clients.obj-code))
       BY X_clients.obj-name
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( ub.clients )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query cli-listB:handle:get-buffer-handle(1) = (buffer X_clients:handle) then do:
      assign
      parameter-2-13 = (if p-find-next then "true":u else "false":u )
      parameter-4-13 =
        "where ":u +  (substitute('X_clients.obj-name contains &1&2&1                             AND X_clients.obj-type = &1&3&1                             AND X_clients.stts <> 0                             AND ', chr(34), NameOrCode, Cli-Types) +  substitute('(  ( &1 = no and &2 = no and &3  = no and &4 = no and &5 = no and &6 = no ) OR   ( if &1 = yes AND X_clients.sup-gds = yes then yes else no ) OR     ( if &2 = yes AND X_clients.sup-cons = yes then yes else no ) OR   ( if &3 = yes AND X_clients.buy-gds = yes  then yes else no ) OR     ( if &4 = yes AND X_clients.buy-cons = yes then yes else no ) OR   ( if &5 = yes AND X_clients.buy-serv = yes then yes else no ) OR   ( if &6 = yes AND X_clients.lim-kr <> 0 then yes else no ) )',  SupGds,  SupCons, BuyGds, BuyCons, BuyServ, WLim-kr))  + " ":u + where-phrase-13 + " ":u + p-find-condition + " " + ""
      parameter-5-13 = " "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query cli-listB:handle
                          ,input rowid(ub.clients)
                          ,input logical(parameter-2-13)
                          ,input no-lock
                          ,input (buffer ub.clients:handle)
                          ,input parameter-4-13
                          ,input parameter-5-13
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-13 = (if p-find-next then "true":u else "false":u )
      parameter-3-13 =  "FOR EACH X_clients"
      parameter-4-13 =
        (
          if (" X_clients.obj-name contains NameOrCode                             AND X_clients.obj-type = Cli-Types                             AND X_clients.stts <> 0                             AND (  ( SupGds = no and SupCons = no and BuyGds  = no and BuyCons = no and BuyServ = no and WLim-kr = no ) OR   ( if SupGds = yes AND X_clients.sup-gds = yes then yes else no ) OR     ( if SupCons = yes AND X_clients.sup-cons = yes then yes else no ) OR   ( if BuyGds = yes AND X_clients.buy-gds = yes  then yes else no ) OR     ( if BuyCons = yes AND X_clients.buy-cons = yes then yes else no ) OR   ( if BuyServ = yes AND X_clients.buy-serv = yes then yes else no ) OR   ( if WLim-kr = yes AND X_clients.lim-kr <> 0 then yes else no ) ) " + " " + where-phrase-13) <> ""
          then  (substitute('X_clients.obj-name contains &1&2&1                             AND X_clients.obj-type = &1&3&1                             AND X_clients.stts <> 0                             AND ', chr(34), NameOrCode, Cli-Types) +  substitute('(  ( &1 = no and &2 = no and &3  = no and &4 = no and &5 = no and &6 = no ) OR   ( if &1 = yes AND X_clients.sup-gds = yes then yes else no ) OR     ( if &2 = yes AND X_clients.sup-cons = yes then yes else no ) OR   ( if &3 = yes AND X_clients.buy-gds = yes  then yes else no ) OR     ( if &4 = yes AND X_clients.buy-cons = yes then yes else no ) OR   ( if &5 = yes AND X_clients.buy-serv = yes then yes else no ) OR   ( if &6 = yes AND X_clients.lim-kr <> 0 then yes else no ) )',  SupGds,  SupCons, BuyGds, BuyCons, BuyServ, WLim-kr))  + " " + where-phrase-13
          else "true"
        )
      parameter-5-13 = (" " + "" + " " + substitute(', first x_temp-list-buyer NO-LOCK WHERE (&1 = NO OR (x_temp-list-buyer.obj-type =   X_clients.obj-type AND              x_temp-list-buyer.obj-code =   X_clients.obj-code))'                                              ,v-list-b) + " " + p-find-condition)
      parameter-6-13 = if sort-phrase-13 = ''
                           then
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + " BY X_clients.obj-name  "
        )
                           else
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + sort-phrase-13
        )
      parameter-7-13 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query cli-listB:handle
                          ,input logical(parameter-2-13)
                          ,input no-lock
                          ,input parameter-3-13
                          ,input parameter-4-13
                          ,input parameter-5-13
                          ,input parameter-6-13
                          ,input parameter-7-13
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      v-doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
      end.
      when "NO" then do:
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-15  as logical   no-undo .
define variable  l-filter-open-15    as logical   .
define variable  flt-rec-15       as recid     no-undo .
define variable  filter-name-15      as character no-undo .
define variable  where-phrase-15     as character no-undo .
define variable  sort-phrase-15      as character no-undo .
define variable  where-phrase-rus-15 as character no-undo .
define variable  sort-phrase-rus-15  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-15
  ,output filter-name-15
  ,output where-phrase-15
  ,output sort-phrase-15
  ,output where-phrase-rus-15
  ,output sort-phrase-rus-15
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-15
      ) no-error .
  assign
    l-filter-open-15 = false
  .
  if flt-rec-15 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-15 as character no-undo .
    define variable  parameter-3-15 as character no-undo .
    define variable  parameter-4-15 as character no-undo .
    define variable  parameter-5-15 as character no-undo .
    define variable  parameter-6-15 as character no-undo .
    define variable  parameter-7-15 as character no-undo .
      assign
      parameter-3-15 =
                              "FOR EACH X_clients"
      parameter-4-15 =
        (
          if (" X_clients.obj-name contains NameOrCode                             AND X_clients.obj-type = Cli-Types                             AND X_clients.stts <> 0 " + " " + where-phrase-15) <> ""
          then  substitute('X_clients.obj-name contains &1&2&1                             AND X_clients.obj-type = &1&3&1                             AND X_clients.stts <> 0 ', chr(34), NameOrCode, Cli-Types) + " " + where-phrase-15
          else "true"
        )
      parameter-5-15 = (" " + "" + " " + substitute(', first x_temp-list-buyer NO-LOCK WHERE (&1 = NO OR (x_temp-list-buyer.obj-type =   X_clients.obj-type AND              x_temp-list-buyer.obj-code =   X_clients.obj-code))'                                              ,v-list-b))
      parameter-6-15 = if sort-phrase-15 = ''
                           then
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + " BY X_clients.obj-name  "
        )
                           else
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + sort-phrase-15
        )
      parameter-7-15 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-15 =
          (" X_clients.obj-name contains NameOrCode                             AND X_clients.obj-type = Cli-Types                             AND X_clients.stts <> 0 " + " " + where-phrase-15 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query cli-listB:handle
                          ,input parameter-3-15
                          ,input parameter-4-15
                          ,input parameter-5-15
                          ,input parameter-6-15
                          ,input parameter-7-15
                          )
      .
      assign
        l-filter-open-15 = true
      .
    end.
    if l-filter-open-15 = false then do:
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
  if l-filter-open-15 = false then do:
    OPEN QUERY CLi-ListB FOR EACH X_clients no-lock
      where  X_clients.obj-name contains NameOrCode                             AND X_clients.obj-type = Cli-Types                             AND X_clients.stts <> 0
    , first x_temp-list-buyer NO-LOCK WHERE (v-list-b = NO OR (x_temp-list-buyer.obj-type =   X_clients.obj-type AND              x_temp-list-buyer.obj-code =   X_clients.obj-code))
       BY X_clients.obj-name
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( ub.clients )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query cli-listB:handle:get-buffer-handle(1) = (buffer X_clients:handle) then do:
      assign
      parameter-2-15 = (if p-find-next then "true":u else "false":u )
      parameter-4-15 =
        "where ":u +  substitute('X_clients.obj-name contains &1&2&1                             AND X_clients.obj-type = &1&3&1                             AND X_clients.stts <> 0 ', chr(34), NameOrCode, Cli-Types) + " ":u + where-phrase-15 + " ":u + p-find-condition + " " + ""
      parameter-5-15 = " "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query cli-listB:handle
                          ,input rowid(ub.clients)
                          ,input logical(parameter-2-15)
                          ,input no-lock
                          ,input (buffer ub.clients:handle)
                          ,input parameter-4-15
                          ,input parameter-5-15
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-15 = (if p-find-next then "true":u else "false":u )
      parameter-3-15 =  "FOR EACH X_clients"
      parameter-4-15 =
        (
          if (" X_clients.obj-name contains NameOrCode                             AND X_clients.obj-type = Cli-Types                             AND X_clients.stts <> 0 " + " " + where-phrase-15) <> ""
          then  substitute('X_clients.obj-name contains &1&2&1                             AND X_clients.obj-type = &1&3&1                             AND X_clients.stts <> 0 ', chr(34), NameOrCode, Cli-Types) + " " + where-phrase-15
          else "true"
        )
      parameter-5-15 = (" " + "" + " " + substitute(', first x_temp-list-buyer NO-LOCK WHERE (&1 = NO OR (x_temp-list-buyer.obj-type =   X_clients.obj-type AND              x_temp-list-buyer.obj-code =   X_clients.obj-code))'                                              ,v-list-b) + " " + p-find-condition)
      parameter-6-15 = if sort-phrase-15 = ''
                           then
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + " BY X_clients.obj-name  "
        )
                           else
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + sort-phrase-15
        )
      parameter-7-15 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query cli-listB:handle
                          ,input logical(parameter-2-15)
                          ,input no-lock
                          ,input parameter-3-15
                          ,input parameter-4-15
                          ,input parameter-5-15
                          ,input parameter-6-15
                          ,input parameter-7-15
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      v-doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
      end.
    END CASE .
  end.
  when ('орг':U + "-" + 'название':U + "-" + 'группа':U + "-" + 'текущие':U) OR
  when ('чел':U + "-" + 'название':U + "-" + 'группа':U + "-" + 'текущие':U) OR
  when ('скл':U + "-" + 'название':U + "-" + 'группа':U + "-" + 'текущие':U) OR
  when ('маг':U + "-" + 'название':U + "-" + 'группа':U + "-" + 'текущие':U) then do:
    CASE JoinType :
      when "Или" then do:
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-17  as logical   no-undo .
define variable  l-filter-open-17    as logical   .
define variable  flt-rec-17       as recid     no-undo .
define variable  filter-name-17      as character no-undo .
define variable  where-phrase-17     as character no-undo .
define variable  sort-phrase-17      as character no-undo .
define variable  where-phrase-rus-17 as character no-undo .
define variable  sort-phrase-rus-17  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-17
  ,output filter-name-17
  ,output where-phrase-17
  ,output sort-phrase-17
  ,output where-phrase-rus-17
  ,output sort-phrase-rus-17
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-17
      ) no-error .
  assign
    l-filter-open-17 = false
  .
  if flt-rec-17 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-17 as character no-undo .
    define variable  parameter-3-17 as character no-undo .
    define variable  parameter-4-17 as character no-undo .
    define variable  parameter-5-17 as character no-undo .
    define variable  parameter-6-17 as character no-undo .
    define variable  parameter-7-17 as character no-undo .
      assign
      parameter-3-17 =
                              "FOR EACH X_clients"
      parameter-4-17 =
        (
          if (" X_clients.obj-name contains NameOrCode                             AND X_clients.obj-type = Cli-Types                             AND X_clients.grp-name begins Curr-Grp-Name                             AND X_clients.stts = 0                             AND (  ( SupGds = no and SupCons = no and BuyGds  = no and BuyCons = no and BuyServ = no and WLim-kr = no ) OR   ( if SupGds = yes AND X_clients.sup-gds = yes then yes else no ) OR     ( if SupCons = yes AND X_clients.sup-cons = yes then yes else no ) OR   ( if BuyGds = yes AND X_clients.buy-gds = yes  then yes else no ) OR     ( if BuyCons = yes AND X_clients.buy-cons = yes then yes else no ) OR   ( if BuyServ = yes AND X_clients.buy-serv = yes then yes else no ) OR   ( if WLim-kr = yes AND X_clients.lim-kr <> 0 then yes else no ) ) " + " " + where-phrase-17) <> ""
          then  (substitute('X_clients.obj-name contains &1&2&1                             AND X_clients.obj-type = &1&3&1                             AND X_clients.grp-name begins &1&4&1                             AND X_clients.stts = 0                             AND ', chr(34), NameOrCode, Cli-Types, Curr-Grp-Name) + substitute('(  ( &1 = no and &2 = no and &3  = no and &4 = no and &5 = no and &6 = no ) OR   ( if &1 = yes AND X_clients.sup-gds = yes then yes else no ) OR     ( if &2 = yes AND X_clients.sup-cons = yes then yes else no ) OR   ( if &3 = yes AND X_clients.buy-gds = yes  then yes else no ) OR     ( if &4 = yes AND X_clients.buy-cons = yes then yes else no ) OR   ( if &5 = yes AND X_clients.buy-serv = yes then yes else no ) OR   ( if &6 = yes AND X_clients.lim-kr <> 0 then yes else no ) )',  SupGds,  SupCons, BuyGds, BuyCons, BuyServ, WLim-kr))  + " " + where-phrase-17
          else "true"
        )
      parameter-5-17 = (" " + "" + " " + substitute(', first x_temp-list-buyer NO-LOCK WHERE (&1 = NO OR (x_temp-list-buyer.obj-type =   X_clients.obj-type AND              x_temp-list-buyer.obj-code =   X_clients.obj-code))'                                              ,v-list-b))
      parameter-6-17 = if sort-phrase-17 = ''
                           then
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + " BY X_clients.obj-name  "
        )
                           else
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + sort-phrase-17
        )
      parameter-7-17 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-17 =
          (" X_clients.obj-name contains NameOrCode                             AND X_clients.obj-type = Cli-Types                             AND X_clients.grp-name begins Curr-Grp-Name                             AND X_clients.stts = 0                             AND (  ( SupGds = no and SupCons = no and BuyGds  = no and BuyCons = no and BuyServ = no and WLim-kr = no ) OR   ( if SupGds = yes AND X_clients.sup-gds = yes then yes else no ) OR     ( if SupCons = yes AND X_clients.sup-cons = yes then yes else no ) OR   ( if BuyGds = yes AND X_clients.buy-gds = yes  then yes else no ) OR     ( if BuyCons = yes AND X_clients.buy-cons = yes then yes else no ) OR   ( if BuyServ = yes AND X_clients.buy-serv = yes then yes else no ) OR   ( if WLim-kr = yes AND X_clients.lim-kr <> 0 then yes else no ) ) " + " " + where-phrase-17 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query cli-listB:handle
                          ,input parameter-3-17
                          ,input parameter-4-17
                          ,input parameter-5-17
                          ,input parameter-6-17
                          ,input parameter-7-17
                          )
      .
      assign
        l-filter-open-17 = true
      .
    end.
    if l-filter-open-17 = false then do:
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
  if l-filter-open-17 = false then do:
    OPEN QUERY CLi-ListB FOR EACH X_clients no-lock
      where  X_clients.obj-name contains NameOrCode                             AND X_clients.obj-type = Cli-Types                             AND X_clients.grp-name begins Curr-Grp-Name                             AND X_clients.stts = 0                             AND (  ( SupGds = no and SupCons = no and BuyGds  = no and BuyCons = no and BuyServ = no and WLim-kr = no ) OR   ( if SupGds = yes AND X_clients.sup-gds = yes then yes else no ) OR     ( if SupCons = yes AND X_clients.sup-cons = yes then yes else no ) OR   ( if BuyGds = yes AND X_clients.buy-gds = yes  then yes else no ) OR     ( if BuyCons = yes AND X_clients.buy-cons = yes then yes else no ) OR   ( if BuyServ = yes AND X_clients.buy-serv = yes then yes else no ) OR   ( if WLim-kr = yes AND X_clients.lim-kr <> 0 then yes else no ) )
    , first x_temp-list-buyer NO-LOCK WHERE (v-list-b = NO OR (x_temp-list-buyer.obj-type =   X_clients.obj-type AND              x_temp-list-buyer.obj-code =   X_clients.obj-code))
       BY X_clients.obj-name
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( ub.clients )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query cli-listB:handle:get-buffer-handle(1) = (buffer X_clients:handle) then do:
      assign
      parameter-2-17 = (if p-find-next then "true":u else "false":u )
      parameter-4-17 =
        "where ":u +  (substitute('X_clients.obj-name contains &1&2&1                             AND X_clients.obj-type = &1&3&1                             AND X_clients.grp-name begins &1&4&1                             AND X_clients.stts = 0                             AND ', chr(34), NameOrCode, Cli-Types, Curr-Grp-Name) + substitute('(  ( &1 = no and &2 = no and &3  = no and &4 = no and &5 = no and &6 = no ) OR   ( if &1 = yes AND X_clients.sup-gds = yes then yes else no ) OR     ( if &2 = yes AND X_clients.sup-cons = yes then yes else no ) OR   ( if &3 = yes AND X_clients.buy-gds = yes  then yes else no ) OR     ( if &4 = yes AND X_clients.buy-cons = yes then yes else no ) OR   ( if &5 = yes AND X_clients.buy-serv = yes then yes else no ) OR   ( if &6 = yes AND X_clients.lim-kr <> 0 then yes else no ) )',  SupGds,  SupCons, BuyGds, BuyCons, BuyServ, WLim-kr))  + " ":u + where-phrase-17 + " ":u + p-find-condition + " " + ""
      parameter-5-17 = " "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query cli-listB:handle
                          ,input rowid(ub.clients)
                          ,input logical(parameter-2-17)
                          ,input no-lock
                          ,input (buffer ub.clients:handle)
                          ,input parameter-4-17
                          ,input parameter-5-17
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-17 = (if p-find-next then "true":u else "false":u )
      parameter-3-17 =  "FOR EACH X_clients"
      parameter-4-17 =
        (
          if (" X_clients.obj-name contains NameOrCode                             AND X_clients.obj-type = Cli-Types                             AND X_clients.grp-name begins Curr-Grp-Name                             AND X_clients.stts = 0                             AND (  ( SupGds = no and SupCons = no and BuyGds  = no and BuyCons = no and BuyServ = no and WLim-kr = no ) OR   ( if SupGds = yes AND X_clients.sup-gds = yes then yes else no ) OR     ( if SupCons = yes AND X_clients.sup-cons = yes then yes else no ) OR   ( if BuyGds = yes AND X_clients.buy-gds = yes  then yes else no ) OR     ( if BuyCons = yes AND X_clients.buy-cons = yes then yes else no ) OR   ( if BuyServ = yes AND X_clients.buy-serv = yes then yes else no ) OR   ( if WLim-kr = yes AND X_clients.lim-kr <> 0 then yes else no ) ) " + " " + where-phrase-17) <> ""
          then  (substitute('X_clients.obj-name contains &1&2&1                             AND X_clients.obj-type = &1&3&1                             AND X_clients.grp-name begins &1&4&1                             AND X_clients.stts = 0                             AND ', chr(34), NameOrCode, Cli-Types, Curr-Grp-Name) + substitute('(  ( &1 = no and &2 = no and &3  = no and &4 = no and &5 = no and &6 = no ) OR   ( if &1 = yes AND X_clients.sup-gds = yes then yes else no ) OR     ( if &2 = yes AND X_clients.sup-cons = yes then yes else no ) OR   ( if &3 = yes AND X_clients.buy-gds = yes  then yes else no ) OR     ( if &4 = yes AND X_clients.buy-cons = yes then yes else no ) OR   ( if &5 = yes AND X_clients.buy-serv = yes then yes else no ) OR   ( if &6 = yes AND X_clients.lim-kr <> 0 then yes else no ) )',  SupGds,  SupCons, BuyGds, BuyCons, BuyServ, WLim-kr))  + " " + where-phrase-17
          else "true"
        )
      parameter-5-17 = (" " + "" + " " + substitute(', first x_temp-list-buyer NO-LOCK WHERE (&1 = NO OR (x_temp-list-buyer.obj-type =   X_clients.obj-type AND              x_temp-list-buyer.obj-code =   X_clients.obj-code))'                                              ,v-list-b) + " " + p-find-condition)
      parameter-6-17 = if sort-phrase-17 = ''
                           then
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + " BY X_clients.obj-name  "
        )
                           else
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + sort-phrase-17
        )
      parameter-7-17 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query cli-listB:handle
                          ,input logical(parameter-2-17)
                          ,input no-lock
                          ,input parameter-3-17
                          ,input parameter-4-17
                          ,input parameter-5-17
                          ,input parameter-6-17
                          ,input parameter-7-17
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      v-doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
      end.
      when "NO" then  do:
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
  (input filter-point
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
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-19 as character no-undo .
    define variable  parameter-3-19 as character no-undo .
    define variable  parameter-4-19 as character no-undo .
    define variable  parameter-5-19 as character no-undo .
    define variable  parameter-6-19 as character no-undo .
    define variable  parameter-7-19 as character no-undo .
      assign
      parameter-3-19 =
                              "FOR EACH X_clients"
      parameter-4-19 =
        (
          if (" X_clients.obj-name contains NameOrCode                             AND X_clients.obj-type = Cli-Types                             AND X_clients.grp-name begins Curr-Grp-Name                             AND X_clients.stts = 0 " + " " + where-phrase-19) <> ""
          then  substitute('X_clients.obj-name contains &1&2&1                             AND X_clients.obj-type = &1&3&1                             AND X_clients.grp-name begins &1&4&1                             AND X_clients.stts = 0 ', chr(34), NameOrCode, Cli-Types, Curr-Grp-Name) + " " + where-phrase-19
          else "true"
        )
      parameter-5-19 = (" " + "" + " " + substitute(', first x_temp-list-buyer NO-LOCK WHERE (&1 = NO OR (x_temp-list-buyer.obj-type =   X_clients.obj-type AND              x_temp-list-buyer.obj-code =   X_clients.obj-code))'                                              ,v-list-b))
      parameter-6-19 = if sort-phrase-19 = ''
                           then
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + " BY X_clients.obj-name  "
        )
                           else
        (
        " " + " " +
          " " + sort-column-phrase +
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
          (" X_clients.obj-name contains NameOrCode                             AND X_clients.obj-type = Cli-Types                             AND X_clients.grp-name begins Curr-Grp-Name                             AND X_clients.stts = 0 " + " " + where-phrase-19 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query cli-listB:handle
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
    OPEN QUERY CLi-ListB FOR EACH X_clients no-lock
      where  X_clients.obj-name contains NameOrCode                             AND X_clients.obj-type = Cli-Types                             AND X_clients.grp-name begins Curr-Grp-Name                             AND X_clients.stts = 0
    , first x_temp-list-buyer NO-LOCK WHERE (v-list-b = NO OR (x_temp-list-buyer.obj-type =   X_clients.obj-type AND              x_temp-list-buyer.obj-code =   X_clients.obj-code))
       BY X_clients.obj-name
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( ub.clients )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query cli-listB:handle:get-buffer-handle(1) = (buffer X_clients:handle) then do:
      assign
      parameter-2-19 = (if p-find-next then "true":u else "false":u )
      parameter-4-19 =
        "where ":u +  substitute('X_clients.obj-name contains &1&2&1                             AND X_clients.obj-type = &1&3&1                             AND X_clients.grp-name begins &1&4&1                             AND X_clients.stts = 0 ', chr(34), NameOrCode, Cli-Types, Curr-Grp-Name) + " ":u + where-phrase-19 + " ":u + p-find-condition + " " + ""
      parameter-5-19 = " "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query cli-listB:handle
                          ,input rowid(ub.clients)
                          ,input logical(parameter-2-19)
                          ,input no-lock
                          ,input (buffer ub.clients:handle)
                          ,input parameter-4-19
                          ,input parameter-5-19
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-19 = (if p-find-next then "true":u else "false":u )
      parameter-3-19 =  "FOR EACH X_clients"
      parameter-4-19 =
        (
          if (" X_clients.obj-name contains NameOrCode                             AND X_clients.obj-type = Cli-Types                             AND X_clients.grp-name begins Curr-Grp-Name                             AND X_clients.stts = 0 " + " " + where-phrase-19) <> ""
          then  substitute('X_clients.obj-name contains &1&2&1                             AND X_clients.obj-type = &1&3&1                             AND X_clients.grp-name begins &1&4&1                             AND X_clients.stts = 0 ', chr(34), NameOrCode, Cli-Types, Curr-Grp-Name) + " " + where-phrase-19
          else "true"
        )
      parameter-5-19 = (" " + "" + " " + substitute(', first x_temp-list-buyer NO-LOCK WHERE (&1 = NO OR (x_temp-list-buyer.obj-type =   X_clients.obj-type AND              x_temp-list-buyer.obj-code =   X_clients.obj-code))'                                              ,v-list-b) + " " + p-find-condition)
      parameter-6-19 = if sort-phrase-19 = ''
                           then
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + " BY X_clients.obj-name  "
        )
                           else
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + sort-phrase-19
        )
      parameter-7-19 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query cli-listB:handle
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
      v-doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
      end.
    END CASE .
  end.
  when ('орг':U + "-" + 'название':U + "-" + 'группа':U + "-" + 'все':U) OR
  when ('чел':U + "-" + 'название':U + "-" + 'группа':U + "-" + 'все':U) OR
  when ('скл':U + "-" + 'название':U + "-" + 'группа':U + "-" + 'все':U) OR
  when ('маг':U + "-" + 'название':U + "-" + 'группа':U + "-" + 'все':U) then do:
    CASE JoinType :
      when "Или" then do:
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
  (input filter-point
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
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-21 as character no-undo .
    define variable  parameter-3-21 as character no-undo .
    define variable  parameter-4-21 as character no-undo .
    define variable  parameter-5-21 as character no-undo .
    define variable  parameter-6-21 as character no-undo .
    define variable  parameter-7-21 as character no-undo .
      assign
      parameter-3-21 =
                              "FOR EACH X_clients"
      parameter-4-21 =
        (
          if (" X_clients.obj-name contains NameOrCode                             AND X_clients.obj-type = Cli-Types                             AND X_clients.grp-name begins Curr-Grp-Name                             AND (  ( SupGds = no and SupCons = no and BuyGds  = no and BuyCons = no and BuyServ = no and WLim-kr = no ) OR   ( if SupGds = yes AND X_clients.sup-gds = yes then yes else no ) OR     ( if SupCons = yes AND X_clients.sup-cons = yes then yes else no ) OR   ( if BuyGds = yes AND X_clients.buy-gds = yes  then yes else no ) OR     ( if BuyCons = yes AND X_clients.buy-cons = yes then yes else no ) OR   ( if BuyServ = yes AND X_clients.buy-serv = yes then yes else no ) OR   ( if WLim-kr = yes AND X_clients.lim-kr <> 0 then yes else no ) ) " + " " + where-phrase-21) <> ""
          then  (substitute('X_clients.obj-name contains &1&2&1                             AND X_clients.obj-type = &1&3&1                             AND X_clients.grp-name begins &1&4&1                             AND ', chr(34), NameOrCode, Cli-Types, Curr-Grp-Name) + substitute('(  ( &1 = no and &2 = no and &3  = no and &4 = no and &5 = no and &6 = no ) OR   ( if &1 = yes AND X_clients.sup-gds = yes then yes else no ) OR     ( if &2 = yes AND X_clients.sup-cons = yes then yes else no ) OR   ( if &3 = yes AND X_clients.buy-gds = yes  then yes else no ) OR     ( if &4 = yes AND X_clients.buy-cons = yes then yes else no ) OR   ( if &5 = yes AND X_clients.buy-serv = yes then yes else no ) OR   ( if &6 = yes AND X_clients.lim-kr <> 0 then yes else no ) )',  SupGds,  SupCons, BuyGds, BuyCons, BuyServ, WLim-kr))  + " " + where-phrase-21
          else "true"
        )
      parameter-5-21 = (" " + "" + " " + substitute(', first x_temp-list-buyer NO-LOCK WHERE (&1 = NO OR (x_temp-list-buyer.obj-type =   X_clients.obj-type AND              x_temp-list-buyer.obj-code =   X_clients.obj-code))'                                              ,v-list-b))
      parameter-6-21 = if sort-phrase-21 = ''
                           then
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + " BY X_clients.obj-name  "
        )
                           else
        (
        " " + " " +
          " " + sort-column-phrase +
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
          (" X_clients.obj-name contains NameOrCode                             AND X_clients.obj-type = Cli-Types                             AND X_clients.grp-name begins Curr-Grp-Name                             AND (  ( SupGds = no and SupCons = no and BuyGds  = no and BuyCons = no and BuyServ = no and WLim-kr = no ) OR   ( if SupGds = yes AND X_clients.sup-gds = yes then yes else no ) OR     ( if SupCons = yes AND X_clients.sup-cons = yes then yes else no ) OR   ( if BuyGds = yes AND X_clients.buy-gds = yes  then yes else no ) OR     ( if BuyCons = yes AND X_clients.buy-cons = yes then yes else no ) OR   ( if BuyServ = yes AND X_clients.buy-serv = yes then yes else no ) OR   ( if WLim-kr = yes AND X_clients.lim-kr <> 0 then yes else no ) ) " + " " + where-phrase-21 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query cli-listB:handle
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
    OPEN QUERY CLi-ListB FOR EACH X_clients no-lock
      where  X_clients.obj-name contains NameOrCode                             AND X_clients.obj-type = Cli-Types                             AND X_clients.grp-name begins Curr-Grp-Name                             AND (  ( SupGds = no and SupCons = no and BuyGds  = no and BuyCons = no and BuyServ = no and WLim-kr = no ) OR   ( if SupGds = yes AND X_clients.sup-gds = yes then yes else no ) OR     ( if SupCons = yes AND X_clients.sup-cons = yes then yes else no ) OR   ( if BuyGds = yes AND X_clients.buy-gds = yes  then yes else no ) OR     ( if BuyCons = yes AND X_clients.buy-cons = yes then yes else no ) OR   ( if BuyServ = yes AND X_clients.buy-serv = yes then yes else no ) OR   ( if WLim-kr = yes AND X_clients.lim-kr <> 0 then yes else no ) )
    , first x_temp-list-buyer NO-LOCK WHERE (v-list-b = NO OR (x_temp-list-buyer.obj-type =   X_clients.obj-type AND              x_temp-list-buyer.obj-code =   X_clients.obj-code))
       BY X_clients.obj-name
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( ub.clients )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query cli-listB:handle:get-buffer-handle(1) = (buffer X_clients:handle) then do:
      assign
      parameter-2-21 = (if p-find-next then "true":u else "false":u )
      parameter-4-21 =
        "where ":u +  (substitute('X_clients.obj-name contains &1&2&1                             AND X_clients.obj-type = &1&3&1                             AND X_clients.grp-name begins &1&4&1                             AND ', chr(34), NameOrCode, Cli-Types, Curr-Grp-Name) + substitute('(  ( &1 = no and &2 = no and &3  = no and &4 = no and &5 = no and &6 = no ) OR   ( if &1 = yes AND X_clients.sup-gds = yes then yes else no ) OR     ( if &2 = yes AND X_clients.sup-cons = yes then yes else no ) OR   ( if &3 = yes AND X_clients.buy-gds = yes  then yes else no ) OR     ( if &4 = yes AND X_clients.buy-cons = yes then yes else no ) OR   ( if &5 = yes AND X_clients.buy-serv = yes then yes else no ) OR   ( if &6 = yes AND X_clients.lim-kr <> 0 then yes else no ) )',  SupGds,  SupCons, BuyGds, BuyCons, BuyServ, WLim-kr))  + " ":u + where-phrase-21 + " ":u + p-find-condition + " " + ""
      parameter-5-21 = " "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query cli-listB:handle
                          ,input rowid(ub.clients)
                          ,input logical(parameter-2-21)
                          ,input no-lock
                          ,input (buffer ub.clients:handle)
                          ,input parameter-4-21
                          ,input parameter-5-21
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-21 = (if p-find-next then "true":u else "false":u )
      parameter-3-21 =  "FOR EACH X_clients"
      parameter-4-21 =
        (
          if (" X_clients.obj-name contains NameOrCode                             AND X_clients.obj-type = Cli-Types                             AND X_clients.grp-name begins Curr-Grp-Name                             AND (  ( SupGds = no and SupCons = no and BuyGds  = no and BuyCons = no and BuyServ = no and WLim-kr = no ) OR   ( if SupGds = yes AND X_clients.sup-gds = yes then yes else no ) OR     ( if SupCons = yes AND X_clients.sup-cons = yes then yes else no ) OR   ( if BuyGds = yes AND X_clients.buy-gds = yes  then yes else no ) OR     ( if BuyCons = yes AND X_clients.buy-cons = yes then yes else no ) OR   ( if BuyServ = yes AND X_clients.buy-serv = yes then yes else no ) OR   ( if WLim-kr = yes AND X_clients.lim-kr <> 0 then yes else no ) ) " + " " + where-phrase-21) <> ""
          then  (substitute('X_clients.obj-name contains &1&2&1                             AND X_clients.obj-type = &1&3&1                             AND X_clients.grp-name begins &1&4&1                             AND ', chr(34), NameOrCode, Cli-Types, Curr-Grp-Name) + substitute('(  ( &1 = no and &2 = no and &3  = no and &4 = no and &5 = no and &6 = no ) OR   ( if &1 = yes AND X_clients.sup-gds = yes then yes else no ) OR     ( if &2 = yes AND X_clients.sup-cons = yes then yes else no ) OR   ( if &3 = yes AND X_clients.buy-gds = yes  then yes else no ) OR     ( if &4 = yes AND X_clients.buy-cons = yes then yes else no ) OR   ( if &5 = yes AND X_clients.buy-serv = yes then yes else no ) OR   ( if &6 = yes AND X_clients.lim-kr <> 0 then yes else no ) )',  SupGds,  SupCons, BuyGds, BuyCons, BuyServ, WLim-kr))  + " " + where-phrase-21
          else "true"
        )
      parameter-5-21 = (" " + "" + " " + substitute(', first x_temp-list-buyer NO-LOCK WHERE (&1 = NO OR (x_temp-list-buyer.obj-type =   X_clients.obj-type AND              x_temp-list-buyer.obj-code =   X_clients.obj-code))'                                              ,v-list-b) + " " + p-find-condition)
      parameter-6-21 = if sort-phrase-21 = ''
                           then
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + " BY X_clients.obj-name  "
        )
                           else
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + sort-phrase-21
        )
      parameter-7-21 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query cli-listB:handle
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
      v-doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
      end.
      when "NO" then do:
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
  (input filter-point
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
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-23 as character no-undo .
    define variable  parameter-3-23 as character no-undo .
    define variable  parameter-4-23 as character no-undo .
    define variable  parameter-5-23 as character no-undo .
    define variable  parameter-6-23 as character no-undo .
    define variable  parameter-7-23 as character no-undo .
      assign
      parameter-3-23 =
                              "FOR EACH X_clients"
      parameter-4-23 =
        (
          if (" X_clients.obj-name contains NameOrCode                             AND X_clients.obj-type = Cli-Types                             AND X_clients.grp-name begins Curr-Grp-Name " + " " + where-phrase-23) <> ""
          then  substitute('X_clients.obj-name contains &1&2&1                             AND X_clients.obj-type = &1&3&1                             AND X_clients.grp-name begins &1&4&1 ', chr(34), NameOrCode, Cli-Types, Curr-Grp-Name) + " " + where-phrase-23
          else "true"
        )
      parameter-5-23 = (" " + "" + " " + substitute(', first x_temp-list-buyer NO-LOCK WHERE (&1 = NO OR (x_temp-list-buyer.obj-type =   X_clients.obj-type AND              x_temp-list-buyer.obj-code =   X_clients.obj-code))'                                              ,v-list-b))
      parameter-6-23 = if sort-phrase-23 = ''
                           then
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + " BY X_clients.obj-name  "
        )
                           else
        (
        " " + " " +
          " " + sort-column-phrase +
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
          (" X_clients.obj-name contains NameOrCode                             AND X_clients.obj-type = Cli-Types                             AND X_clients.grp-name begins Curr-Grp-Name " + " " + where-phrase-23 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query cli-listB:handle
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
    OPEN QUERY CLi-ListB FOR EACH X_clients no-lock
      where  X_clients.obj-name contains NameOrCode                             AND X_clients.obj-type = Cli-Types                             AND X_clients.grp-name begins Curr-Grp-Name
    , first x_temp-list-buyer NO-LOCK WHERE (v-list-b = NO OR (x_temp-list-buyer.obj-type =   X_clients.obj-type AND              x_temp-list-buyer.obj-code =   X_clients.obj-code))
       BY X_clients.obj-name
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( ub.clients )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query cli-listB:handle:get-buffer-handle(1) = (buffer X_clients:handle) then do:
      assign
      parameter-2-23 = (if p-find-next then "true":u else "false":u )
      parameter-4-23 =
        "where ":u +  substitute('X_clients.obj-name contains &1&2&1                             AND X_clients.obj-type = &1&3&1                             AND X_clients.grp-name begins &1&4&1 ', chr(34), NameOrCode, Cli-Types, Curr-Grp-Name) + " ":u + where-phrase-23 + " ":u + p-find-condition + " " + ""
      parameter-5-23 = " "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query cli-listB:handle
                          ,input rowid(ub.clients)
                          ,input logical(parameter-2-23)
                          ,input no-lock
                          ,input (buffer ub.clients:handle)
                          ,input parameter-4-23
                          ,input parameter-5-23
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-23 = (if p-find-next then "true":u else "false":u )
      parameter-3-23 =  "FOR EACH X_clients"
      parameter-4-23 =
        (
          if (" X_clients.obj-name contains NameOrCode                             AND X_clients.obj-type = Cli-Types                             AND X_clients.grp-name begins Curr-Grp-Name " + " " + where-phrase-23) <> ""
          then  substitute('X_clients.obj-name contains &1&2&1                             AND X_clients.obj-type = &1&3&1                             AND X_clients.grp-name begins &1&4&1 ', chr(34), NameOrCode, Cli-Types, Curr-Grp-Name) + " " + where-phrase-23
          else "true"
        )
      parameter-5-23 = (" " + "" + " " + substitute(', first x_temp-list-buyer NO-LOCK WHERE (&1 = NO OR (x_temp-list-buyer.obj-type =   X_clients.obj-type AND              x_temp-list-buyer.obj-code =   X_clients.obj-code))'                                              ,v-list-b) + " " + p-find-condition)
      parameter-6-23 = if sort-phrase-23 = ''
                           then
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + " BY X_clients.obj-name  "
        )
                           else
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + sort-phrase-23
        )
      parameter-7-23 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query cli-listB:handle
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
      v-doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
      end.
    END CASE .
  end.
  when ('орг':U + "-" + 'название':U + "-" + 'группа':U + "-" + 'удаленные':U) OR
  when ('чел':U + "-" + 'название':U + "-" + 'группа':U + "-" + 'удаленные':U) OR
  when ('скл':U + "-" + 'название':U + "-" + 'группа':U + "-" + 'удаленные':U) OR
  when ('маг':U + "-" + 'название':U + "-" + 'группа':U + "-" + 'удаленные':U) then do:
    CASE JoinType :
      when "Или" then do:
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
  (input filter-point
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
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-25 as character no-undo .
    define variable  parameter-3-25 as character no-undo .
    define variable  parameter-4-25 as character no-undo .
    define variable  parameter-5-25 as character no-undo .
    define variable  parameter-6-25 as character no-undo .
    define variable  parameter-7-25 as character no-undo .
      assign
      parameter-3-25 =
                              "FOR EACH X_clients"
      parameter-4-25 =
        (
          if (" X_clients.obj-name contains NameOrCode                             AND X_clients.obj-type = Cli-Types                             AND X_clients.grp-name begins Curr-Grp-Name                             AND X_clients.stts <> 0                             AND (  ( SupGds = no and SupCons = no and BuyGds  = no and BuyCons = no and BuyServ = no and WLim-kr = no ) OR   ( if SupGds = yes AND X_clients.sup-gds = yes then yes else no ) OR     ( if SupCons = yes AND X_clients.sup-cons = yes then yes else no ) OR   ( if BuyGds = yes AND X_clients.buy-gds = yes  then yes else no ) OR     ( if BuyCons = yes AND X_clients.buy-cons = yes then yes else no ) OR   ( if BuyServ = yes AND X_clients.buy-serv = yes then yes else no ) OR   ( if WLim-kr = yes AND X_clients.lim-kr <> 0 then yes else no ) ) " + " " + where-phrase-25) <> ""
          then  (substitute('X_clients.obj-name contains &1&2&1                             AND X_clients.obj-type = &1&3&1                             AND X_clients.grp-name begins &1&4&1                             AND X_clients.stts <> 0                             AND ', chr(34), NameOrCode, Cli-Types, Curr-Grp-Name) + substitute('(  ( &1 = no and &2 = no and &3  = no and &4 = no and &5 = no and &6 = no ) OR   ( if &1 = yes AND X_clients.sup-gds = yes then yes else no ) OR     ( if &2 = yes AND X_clients.sup-cons = yes then yes else no ) OR   ( if &3 = yes AND X_clients.buy-gds = yes  then yes else no ) OR     ( if &4 = yes AND X_clients.buy-cons = yes then yes else no ) OR   ( if &5 = yes AND X_clients.buy-serv = yes then yes else no ) OR   ( if &6 = yes AND X_clients.lim-kr <> 0 then yes else no ) )',  SupGds,  SupCons, BuyGds, BuyCons, BuyServ, WLim-kr))  + " " + where-phrase-25
          else "true"
        )
      parameter-5-25 = (" " + "" + " " + substitute(', first x_temp-list-buyer NO-LOCK WHERE (&1 = NO OR (x_temp-list-buyer.obj-type =   X_clients.obj-type AND              x_temp-list-buyer.obj-code =   X_clients.obj-code))'                                              ,v-list-b))
      parameter-6-25 = if sort-phrase-25 = ''
                           then
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + " BY X_clients.obj-name  "
        )
                           else
        (
        " " + " " +
          " " + sort-column-phrase +
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
          (" X_clients.obj-name contains NameOrCode                             AND X_clients.obj-type = Cli-Types                             AND X_clients.grp-name begins Curr-Grp-Name                             AND X_clients.stts <> 0                             AND (  ( SupGds = no and SupCons = no and BuyGds  = no and BuyCons = no and BuyServ = no and WLim-kr = no ) OR   ( if SupGds = yes AND X_clients.sup-gds = yes then yes else no ) OR     ( if SupCons = yes AND X_clients.sup-cons = yes then yes else no ) OR   ( if BuyGds = yes AND X_clients.buy-gds = yes  then yes else no ) OR     ( if BuyCons = yes AND X_clients.buy-cons = yes then yes else no ) OR   ( if BuyServ = yes AND X_clients.buy-serv = yes then yes else no ) OR   ( if WLim-kr = yes AND X_clients.lim-kr <> 0 then yes else no ) ) " + " " + where-phrase-25 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query cli-listB:handle
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
    OPEN QUERY CLi-ListB FOR EACH X_clients no-lock
      where  X_clients.obj-name contains NameOrCode                             AND X_clients.obj-type = Cli-Types                             AND X_clients.grp-name begins Curr-Grp-Name                             AND X_clients.stts <> 0                             AND (  ( SupGds = no and SupCons = no and BuyGds  = no and BuyCons = no and BuyServ = no and WLim-kr = no ) OR   ( if SupGds = yes AND X_clients.sup-gds = yes then yes else no ) OR     ( if SupCons = yes AND X_clients.sup-cons = yes then yes else no ) OR   ( if BuyGds = yes AND X_clients.buy-gds = yes  then yes else no ) OR     ( if BuyCons = yes AND X_clients.buy-cons = yes then yes else no ) OR   ( if BuyServ = yes AND X_clients.buy-serv = yes then yes else no ) OR   ( if WLim-kr = yes AND X_clients.lim-kr <> 0 then yes else no ) )
    , first x_temp-list-buyer NO-LOCK WHERE (v-list-b = NO OR (x_temp-list-buyer.obj-type =   X_clients.obj-type AND              x_temp-list-buyer.obj-code =   X_clients.obj-code))
       BY X_clients.obj-name
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( ub.clients )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query cli-listB:handle:get-buffer-handle(1) = (buffer X_clients:handle) then do:
      assign
      parameter-2-25 = (if p-find-next then "true":u else "false":u )
      parameter-4-25 =
        "where ":u +  (substitute('X_clients.obj-name contains &1&2&1                             AND X_clients.obj-type = &1&3&1                             AND X_clients.grp-name begins &1&4&1                             AND X_clients.stts <> 0                             AND ', chr(34), NameOrCode, Cli-Types, Curr-Grp-Name) + substitute('(  ( &1 = no and &2 = no and &3  = no and &4 = no and &5 = no and &6 = no ) OR   ( if &1 = yes AND X_clients.sup-gds = yes then yes else no ) OR     ( if &2 = yes AND X_clients.sup-cons = yes then yes else no ) OR   ( if &3 = yes AND X_clients.buy-gds = yes  then yes else no ) OR     ( if &4 = yes AND X_clients.buy-cons = yes then yes else no ) OR   ( if &5 = yes AND X_clients.buy-serv = yes then yes else no ) OR   ( if &6 = yes AND X_clients.lim-kr <> 0 then yes else no ) )',  SupGds,  SupCons, BuyGds, BuyCons, BuyServ, WLim-kr))  + " ":u + where-phrase-25 + " ":u + p-find-condition + " " + ""
      parameter-5-25 = " "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query cli-listB:handle
                          ,input rowid(ub.clients)
                          ,input logical(parameter-2-25)
                          ,input no-lock
                          ,input (buffer ub.clients:handle)
                          ,input parameter-4-25
                          ,input parameter-5-25
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-25 = (if p-find-next then "true":u else "false":u )
      parameter-3-25 =  "FOR EACH X_clients"
      parameter-4-25 =
        (
          if (" X_clients.obj-name contains NameOrCode                             AND X_clients.obj-type = Cli-Types                             AND X_clients.grp-name begins Curr-Grp-Name                             AND X_clients.stts <> 0                             AND (  ( SupGds = no and SupCons = no and BuyGds  = no and BuyCons = no and BuyServ = no and WLim-kr = no ) OR   ( if SupGds = yes AND X_clients.sup-gds = yes then yes else no ) OR     ( if SupCons = yes AND X_clients.sup-cons = yes then yes else no ) OR   ( if BuyGds = yes AND X_clients.buy-gds = yes  then yes else no ) OR     ( if BuyCons = yes AND X_clients.buy-cons = yes then yes else no ) OR   ( if BuyServ = yes AND X_clients.buy-serv = yes then yes else no ) OR   ( if WLim-kr = yes AND X_clients.lim-kr <> 0 then yes else no ) ) " + " " + where-phrase-25) <> ""
          then  (substitute('X_clients.obj-name contains &1&2&1                             AND X_clients.obj-type = &1&3&1                             AND X_clients.grp-name begins &1&4&1                             AND X_clients.stts <> 0                             AND ', chr(34), NameOrCode, Cli-Types, Curr-Grp-Name) + substitute('(  ( &1 = no and &2 = no and &3  = no and &4 = no and &5 = no and &6 = no ) OR   ( if &1 = yes AND X_clients.sup-gds = yes then yes else no ) OR     ( if &2 = yes AND X_clients.sup-cons = yes then yes else no ) OR   ( if &3 = yes AND X_clients.buy-gds = yes  then yes else no ) OR     ( if &4 = yes AND X_clients.buy-cons = yes then yes else no ) OR   ( if &5 = yes AND X_clients.buy-serv = yes then yes else no ) OR   ( if &6 = yes AND X_clients.lim-kr <> 0 then yes else no ) )',  SupGds,  SupCons, BuyGds, BuyCons, BuyServ, WLim-kr))  + " " + where-phrase-25
          else "true"
        )
      parameter-5-25 = (" " + "" + " " + substitute(', first x_temp-list-buyer NO-LOCK WHERE (&1 = NO OR (x_temp-list-buyer.obj-type =   X_clients.obj-type AND              x_temp-list-buyer.obj-code =   X_clients.obj-code))'                                              ,v-list-b) + " " + p-find-condition)
      parameter-6-25 = if sort-phrase-25 = ''
                           then
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + " BY X_clients.obj-name  "
        )
                           else
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + sort-phrase-25
        )
      parameter-7-25 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query cli-listB:handle
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
      v-doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
     end.
     when "NO" then  do:
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-27  as logical   no-undo .
define variable  l-filter-open-27    as logical   .
define variable  flt-rec-27       as recid     no-undo .
define variable  filter-name-27      as character no-undo .
define variable  where-phrase-27     as character no-undo .
define variable  sort-phrase-27      as character no-undo .
define variable  where-phrase-rus-27 as character no-undo .
define variable  sort-phrase-rus-27  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-27
  ,output filter-name-27
  ,output where-phrase-27
  ,output sort-phrase-27
  ,output where-phrase-rus-27
  ,output sort-phrase-rus-27
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-27
      ) no-error .
  assign
    l-filter-open-27 = false
  .
  if flt-rec-27 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-27 as character no-undo .
    define variable  parameter-3-27 as character no-undo .
    define variable  parameter-4-27 as character no-undo .
    define variable  parameter-5-27 as character no-undo .
    define variable  parameter-6-27 as character no-undo .
    define variable  parameter-7-27 as character no-undo .
      assign
      parameter-3-27 =
                              "FOR EACH X_clients"
      parameter-4-27 =
        (
          if (" X_clients.obj-name contains NameOrCode                             AND X_clients.obj-type = Cli-Types                             AND X_clients.grp-name begins Curr-Grp-Name                             AND X_clients.stts <> 0 " + " " + where-phrase-27) <> ""
          then  substitute('X_clients.obj-name contains &1&2&1                             AND X_clients.obj-type = &1&3&1                             AND X_clients.grp-name begins &1&4&1                             AND X_clients.stts <> 0 ', chr(34), NameOrCode, Cli-Types, Curr-Grp-Name) + " " + where-phrase-27
          else "true"
        )
      parameter-5-27 = (" " + "" + " " + substitute(', first x_temp-list-buyer NO-LOCK WHERE (&1 = NO OR (x_temp-list-buyer.obj-type =   X_clients.obj-type AND              x_temp-list-buyer.obj-code =   X_clients.obj-code))'                                              ,v-list-b))
      parameter-6-27 = if sort-phrase-27 = ''
                           then
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + " BY X_clients.obj-name  "
        )
                           else
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + sort-phrase-27
        )
      parameter-7-27 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-27 =
          (" X_clients.obj-name contains NameOrCode                             AND X_clients.obj-type = Cli-Types                             AND X_clients.grp-name begins Curr-Grp-Name                             AND X_clients.stts <> 0 " + " " + where-phrase-27 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query cli-listB:handle
                          ,input parameter-3-27
                          ,input parameter-4-27
                          ,input parameter-5-27
                          ,input parameter-6-27
                          ,input parameter-7-27
                          )
      .
      assign
        l-filter-open-27 = true
      .
    end.
    if l-filter-open-27 = false then do:
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
  if l-filter-open-27 = false then do:
    OPEN QUERY CLi-ListB FOR EACH X_clients no-lock
      where  X_clients.obj-name contains NameOrCode                             AND X_clients.obj-type = Cli-Types                             AND X_clients.grp-name begins Curr-Grp-Name                             AND X_clients.stts <> 0
    , first x_temp-list-buyer NO-LOCK WHERE (v-list-b = NO OR (x_temp-list-buyer.obj-type =   X_clients.obj-type AND              x_temp-list-buyer.obj-code =   X_clients.obj-code))
       BY X_clients.obj-name
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( ub.clients )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query cli-listB:handle:get-buffer-handle(1) = (buffer X_clients:handle) then do:
      assign
      parameter-2-27 = (if p-find-next then "true":u else "false":u )
      parameter-4-27 =
        "where ":u +  substitute('X_clients.obj-name contains &1&2&1                             AND X_clients.obj-type = &1&3&1                             AND X_clients.grp-name begins &1&4&1                             AND X_clients.stts <> 0 ', chr(34), NameOrCode, Cli-Types, Curr-Grp-Name) + " ":u + where-phrase-27 + " ":u + p-find-condition + " " + ""
      parameter-5-27 = " "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query cli-listB:handle
                          ,input rowid(ub.clients)
                          ,input logical(parameter-2-27)
                          ,input no-lock
                          ,input (buffer ub.clients:handle)
                          ,input parameter-4-27
                          ,input parameter-5-27
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-27 = (if p-find-next then "true":u else "false":u )
      parameter-3-27 =  "FOR EACH X_clients"
      parameter-4-27 =
        (
          if (" X_clients.obj-name contains NameOrCode                             AND X_clients.obj-type = Cli-Types                             AND X_clients.grp-name begins Curr-Grp-Name                             AND X_clients.stts <> 0 " + " " + where-phrase-27) <> ""
          then  substitute('X_clients.obj-name contains &1&2&1                             AND X_clients.obj-type = &1&3&1                             AND X_clients.grp-name begins &1&4&1                             AND X_clients.stts <> 0 ', chr(34), NameOrCode, Cli-Types, Curr-Grp-Name) + " " + where-phrase-27
          else "true"
        )
      parameter-5-27 = (" " + "" + " " + substitute(', first x_temp-list-buyer NO-LOCK WHERE (&1 = NO OR (x_temp-list-buyer.obj-type =   X_clients.obj-type AND              x_temp-list-buyer.obj-code =   X_clients.obj-code))'                                              ,v-list-b) + " " + p-find-condition)
      parameter-6-27 = if sort-phrase-27 = ''
                           then
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + " BY X_clients.obj-name  "
        )
                           else
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + sort-phrase-27
        )
      parameter-7-27 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query cli-listB:handle
                          ,input logical(parameter-2-27)
                          ,input no-lock
                          ,input parameter-3-27
                          ,input parameter-4-27
                          ,input parameter-5-27
                          ,input parameter-6-27
                          ,input parameter-7-27
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      v-doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
      end.
    END CASE .
  end.
END CASE.
  end.
end procedure.
