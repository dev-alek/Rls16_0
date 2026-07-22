block-level on error undo, throw.
define input parameter par-fill-method as character no-undo .
define input parameter par-groups as character no-undo .
define input parameter par-values as character no-undo .
define input parameter par-rid-list as character no-undo .
  define shared temp-table  tt-tax no-undo
field tax-code    like ub.tax.tax-code
FIELD individual  like ub.tax.individual
FIELD tax-name    like ub.tax.tax-name format "X(12)" column-label "Налог"
field rate-code   like ub.tax-rate.rate-code
FIELD rate-name   like ub.tax-rate.rate-name FORMAT "X(12)"
FIELD tax-type    like ub.tax.tax-type
field rate-value  like ub.tax-rate-value.rate-value
FIELD tax-rate-gds-rc  as recid
FIELD to-cashdesk like ub.tax.to-cashdesk
index tax-code is unique primary tax-code.
  define temp-table  loc-tt-tax no-undo
field tax-code    like ub.tax.tax-code
FIELD individual  like ub.tax.individual
FIELD tax-name    like ub.tax.tax-name format "X(12)" column-label "Налог"
field rate-code   like ub.tax-rate.rate-code
FIELD rate-name   like ub.tax-rate.rate-name FORMAT "X(12)"
FIELD tax-type    like ub.tax.tax-type
field rate-value  like ub.tax-rate-value.rate-value
FIELD tax-rate-gds-rc  as recid
FIELD to-cashdesk like ub.tax.to-cashdesk
index tax-code is unique primary tax-code.
  define temp-table  v-tt-tax no-undo
field tax-code    like ub.tax.tax-code
FIELD individual  like ub.tax.individual
FIELD tax-name    like ub.tax.tax-name format "X(12)" column-label "Налог"
field rate-code   like ub.tax-rate.rate-code
FIELD rate-name   like ub.tax-rate.rate-name FORMAT "X(12)"
FIELD tax-type    like ub.tax.tax-type
field rate-value  like ub.tax-rate-value.rate-value
FIELD tax-rate-gds-rc  as recid
FIELD to-cashdesk like ub.tax.to-cashdesk
index tax-code is unique primary tax-code.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: in-grptx.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/in-grptx.p $":U .
define variable vss-description as character no-undo init "Инициализация налогов в группах товаров".
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
DEFINE VARIABLE ii as integer no-undo .
DEFINE VARIABLE jj as integer no-undo .
DEFINE VARIABLE kk as integer no-undo .
define variable v-process as logical no-undo .
define variable v-contin as logical no-undo .
define variable v-node-code like ub.gds-grp.node-code no-undo .
define variable v-lvl-num as integer no-undo .
define variable glog as logical no-undo .
define buffer upper_gds-grp for ub.gds-grp.
if ( g#db-num > 0 ) then do:
  message vss-workfile vss-revision vss-description skip
  "Утилиту можно запустить только в ГБД"
  view-as alert-box error .
  return error .
end.
message
"Инициализация налогов в ГРУППАХ ТОВАРОВ ?   Вы уверены ?"
view-as alert-box question buttons OK-Cancel update glog.
if glog <> true then return.
for each tt-tax no-lock:
  find first loc-tt-tax where
            loc-tt-tax.tax-code = tt-tax.tax-code no-error .
  if not available loc-tt-tax then do:
    create loc-tt-tax.
    buffer-copy tt-tax to loc-tt-tax.
  end.
end.
CASE par-values:
  when "default":U then do:
    _group:
    for each ub.gds-grp
    on error undo, next:
      CASE par-groups:
        when "select":U then do:
           if lookup(string(recid(ub.gds-grp)), par-rid-list) = 0 then NEXT _group.
        end.
        when "select-tree" then do:
          assign
          v-contin = yes
          v-node-code = ub.gds-grp.node-code
          .
          do while v-contin:
            run tree-up in this-procedure (input-output v-node-code, output v-contin, output v-process).
          end.
          if not v-process then NEXT _group.
        end.
      END CASE.
      ii = ii + 1.
      run proc-assign in this-procedure
                      (buffer ub.gds-grp
                        ) no-error .
      if not error-status:error and return-value <> "error":U then
      jj = jj + 1.
      run waitfram-show in this-procedure ("Обработано" + chr(32) +
                     string(ii) + chr(32) +
                     "записей - успешно" + chr(32) +
                     string(jj)).
    END.
  end.
  when "group":U then do:
    CASE par-groups:
      when "all":U or when "select-tree":U then do:
        find first upper_gds-grp No-LOCK where upper_gds-grp.upper-code = 0.
        assign
        v-lvl-num = upper_gds-grp.lvl-num
        v-node-code= upper_gds-grp.node-code
        .
        do while available upper_gds-grp:
          if upper_gds-grp.upper-code <> 0 then
          run ini-tree in this-procedure
                          (
                          input upper_gds-grp.node-code
                          ,input (upper_gds-grp.lvl-num + 1)
                      ).
          find first upper_gds-grp NO-LOCK where
                     upper_gds-grp.lvl-num = v-lvl-num
                 AND upper_gds-grp.node-code > v-node-code no-error .
          if not avail upper_gds-grp then do:
            assign
            v-lvl-num = v-lvl-num + 1
            v-node-code = 0
            .
          end.
          find first upper_gds-grp NO-LOCK where
                     upper_gds-grp.lvl-num = v-lvl-num
                 AND upper_gds-grp.node-code > v-node-code no-error .
          if avail upper_gds-grp then do:
            assign
            v-lvl-num = upper_gds-grp.lvl-num
            v-node-code = upper_gds-grp.node-code
            .
          end.
        end.
      end.
      when "select":U then do:
        do kk = 1 to num-entries(par-rid-list):
          find first ub.gds-grp where
                    recid(ub.gds-grp) = integer(entry(kk, par-rid-list)) no-error .
          if avail ub.gds-grp then do:
            find first upper_gds-grp where
                       upper_gds-grp.node-code = ub.gds-grp.upper-code no-error .
             if avail upper_gds-grp then
              run ini-tree  in this-procedure
                            (
                            input upper_gds-grp.node-code
                            ,input (upper_gds-grp.lvl-num + 1)
                        ).
          end.
        end.
      end.
    END CASE.
  end.
END CASE.
run waitfram-hide in this-procedure .
message
"Работа утилиты завершена" skip
"Обработано" ii "записей"  skip
"успешно" jj
view-as alert-box .
procedure proc-assign :
define parameter buffer buf_gds-grp for ub.gds-grp.
define variable v-value as integer no-undo .
define variable v-type as character no-undo .
define variable ll as integer no-undo .
define variable v-error as logical no-undo .
define buffer buf_tax-rate-gds-grp for ub.tax-rate-gds-grp .
define buffer buf_tax-rate for ub.tax-rate.
  do
  on error undo, return error
  :
    for each loc-tt-tax no-lock:
      find first buf_tax-rate-gds-grp where
                 buf_tax-rate-gds-grp.node-code = buf_gds-grp.node-code
            AND buf_tax-rate-gds-grp.tax-code = loc-tt-tax.tax-code
            AND buf_tax-rate-gds-grp.host-code = 0
            AND buf_tax-rate-gds-grp.obj-type = "":U
            AND buf_tax-rate-gds-grp.obj-code = 0 no-error .
      if available buf_tax-rate-gds-grp then do:
        find first buf_tax-rate no-lock where
                   buf_tax-rate.tax-code = buf_tax-rate-gds-grp.tax-code
               AND buf_tax-rate.rate-code = buf_tax-rate-gds-grp.rate-code no-error .
        if not available buf_tax-rate then do:
          v-value = ?
          .
        end.
        else do:
          assign
          v-value = buf_tax-rate-gds-grp.rate-code
          .
        end.
      end.
      else do:
        assign
        v-value = ?
        .
      end.
      find first v-tt-tax where
                v-tt-tax.tax-code = loc-tt-tax.tax-code no-error .
      if not available v-tt-tax then
      create v-tt-tax.
      buffer-copy loc-tt-tax except rate-code to v-tt-tax
      assign
      v-tt-tax.rate-code = v-value
      .
      CASE par-fill-method:
        when "all":U then do:
          assign
          v-tt-tax.rate-code = loc-tt-tax.rate-code
          .
        end.
        when "error-or-space":U then do:
          if v-tt-tax.rate-code = ? then do:
            assign
            v-tt-tax.rate-code = loc-tt-tax.rate-code
            .
          end.
        end.
      END CASE.
      if not available buf_tax-rate-gds-grp
      or buf_tax-rate-gds-grp.rate-code <> v-tt-tax.rate-code then do:
        if not available buf_tax-rate-gds-grp then do:
          create buf_tax-rate-gds-grp.
          assign
          buf_tax-rate-gds-grp.node-code = buf_gds-grp.node-code
          buf_tax-rate-gds-grp.host-code = 0
          buf_tax-rate-gds-grp.obj-type = "":U
          buf_tax-rate-gds-grp.obj-code = 0
          .
        end.
        assign
        buf_tax-rate-gds-grp.tax-code = v-tt-tax.tax-code
        buf_tax-rate-gds-grp.rate-code = v-tt-tax.rate-code
        .
      end.
    end.
  end.
end procedure.
procedure ini-tree :
define input parameter par-node-code like ub.gds-grp.node-code no-undo .
define input parameter par-lvl-num   like ub.gds-grp.lvl-num no-undo .
define variable v-value as character no-undo .
define variable v-type as character no-undo .
define variable v-rid as recid no-undo .
DEFINE VARIABLE v-contin as logical no-undo .
define variable v-process as logical no-undo .
define variable v-nc like ub.gds-grp.node-code no-undo .
define buffer buf_gds-grp for ub.gds-grp.
define buffer new_gds-grp for ub.gds-grp.
define buffer buf_tax-rate-gds-grp for ub.tax-rate-gds-grp.
define buffer buf_tax-rate for ub.tax-rate.
  do
  on error undo, return error
  :
    for each tt-tax no-lock
      , first loc-tt-tax where loc-tt-tax.tax-code = tt-tax.tax-code
    :
      find first buf_tax-rate-gds-grp no-lock where
                buf_tax-rate-gds-grp.node-code = par-node-code
            AND buf_tax-rate-gds-grp.tax-code = tt-tax.tax-code
            AND buf_tax-rate-gds-grp.host-code = 0
            AND buf_tax-rate-gds-grp.obj-type = "":U
            AND buf_tax-rate-gds-grp.obj-code = 0 no-error .
      if available buf_tax-rate-gds-grp then do:
        find first buf_tax-rate no-lock where
                   buf_tax-rate.tax-code = buf_tax-rate-gds-grp.tax-code
               AND buf_tax-rate.rate-code = buf_tax-rate-gds-grp.rate-code no-error .
        if not available buf_tax-rate then do:
          assign
          loc-tt-tax.rate-code =tt-tax.rate-code
          .
        end.
        else do:
          assign
          loc-tt-tax.rate-code = buf_tax-rate-gds-grp.rate-code
          .
        end.
      end.
      else do:
        assign
        loc-tt-tax.rate-code = tt-tax.rate-code
        .
      end.
    end.
    _buf_gds-grp:
    for each  buf_gds-grp where
              buf_gds-grp.upper-code = par-node-code AND
              buf_gds-grp.lvl-num = par-lvl-num:
      if par-groups = "select-tree":U then do:
        assign
        v-contin = yes
        v-nc = buf_gds-grp.node-code
        .
        do while v-contin:
          run tree-up in this-procedure (input-output v-nc, output v-contin, output v-process).
        end.
      end.
      else v-process = yes
      .
      if not v-process then do:
        next _buf_gds-grp.
      end.
      assign
      ii = ii + 1
      .
      run proc-assign in this-procedure (
                                          buffer buf_gds-grp
                                          ) no-error .
      if not error-status:error and return-value <> "error":U then
      jj = jj + 1.
      release buf_gds-grp no-error .
      run waitfram-show in this-procedure ("Обработано" + chr(32) +
                    string(jj) + chr(32) +
                    "записей - успешно" + chr(32) +
                    string(ii)).
    end.
  end.
end procedure.
procedure tree-up :
define input-output parameter p-node-code like ub.gds-grp.node-code no-undo .
define output parameter p-contin as logical no-undo init yes.
define output parameter p-process as logical no-undo init yes.
define buffer buf_gds-grp for ub.gds-grp.
  do
  on error undo, return error
  :
    find first buf_gds-grp no-lock where
               buf_gds-grp.node-code = p-node-code no-error .
    if not avail buf_gds-grp then do:
      assign
      p-process = no
      p-contin = no
      .
      return.
    end.
    if lookup(string(recid(buf_gds-grp)), par-rid-list) > 0 then do:
      assign
      p-process = yes
      p-contin = no
      .
      return.
    end.
    else do:
      assign
      p-process = no
      p-contin = yes
      p-node-code = buf_gds-grp.upper-code
      .
      return.
    end.
  end.
end procedure.
