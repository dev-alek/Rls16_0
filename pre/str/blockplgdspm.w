define temp-table tt_marking no-undo
   field marking-string as character label "*"
   field obj-type       as character
   field obj-code       as integer
   field pl-code        as integer   label "Код резервуара"
   field gds-code       as integer   label "Код товара"
   field pump-code      as integer   label "Номер ТРК"
   field nozzle-code    as integer   label "Номер пистолета"
   field artic          as character label "Артикул"
   field gds-name       as character label "Название"
   field loc1           as character label "Резервуар"
   field status_        as character label "Статус"
   field pl-name        as character label "Название резервуара"
   field prod-code      as integer   label "Производитель"
   field prod-type      as character label "товара"
   field search-log     as logical
   index pi as UNIQUE pl-code gds-code pump-code nozzle-code.
DEFINE BUFFER X_goods          FOR goods.
DEFINE BUFFER X_pl-gds-pump    FOR pl-gds-pump.
DEFINE BUFFER X_pl-pump-nozzle FOR pl-pump-nozzle.
DEFINE BUFFER X_place          FOR place.
define buffer X_marking        for tt_marking .
define input parameter parparentproc as widget-handle no-undo .
define input parameter parobj-type like ub.clients.obj-type no-undo.
define input parameter parobj-code like ub.clients.obj-code no-undo.
define input parameter parbutton   as   character           no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Блокировка пистолетов".
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
define variable c-point  as character no-undo .
define variable tbl      as character no-undo .
define variable join-tbl as character no-undo .
define variable fld      as character no-undo .
define variable lab      as character no-undo .
define variable spr      as character no-undo .
define variable dim      as character no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function nzpl-spl returns logical
(input p-obj-type as character
                                , input p-obj-code as integer):
define variable v-dopi    as integer no-undo .
define variable v-param-type as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as integer no-undo .
define variable v-value-logical as logical no-undo .
define variable v-tth as handle no-undo .
define variable dflt-cd as character no-undo .
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-param-type3 as character no-undo .
define variable v-value-date3 as date no-undo .
define variable v-value-decimal3 as decimal no-undo .
define variable v-value-integer3 as INTEGER no-undo .
define variable v-value-logical3 AS LOGICAL no-undo .
define variable v-tth3 as handle no-undo .
run adm/shattri.p (
    input "get":U
    ,input  p-obj-type
    ,input  p-obj-code
    ,input  'cd-sending':U
    ,input  'dflt-cd':U
    ,output dflt-cd
    ,output v-value-date3
    ,output v-value-decimal3
    ,output v-value-integer3
    ,output v-value-logical3
    ,output v-param-type3
    ,INPUT-OUTPUT table-handle v-tth3
    ) no-error .
delete object v-tth3 no-error.
if dflt-cd <> 'IBM':U
and dflt-cd <> 'IBM-XML':U then return no.
if dflt-cd = 'IBM-XML':U then return yes.
run adm/shattri.p (
    input "get":U
    ,input  p-obj-type
    ,input  p-obj-code
    ,input  'cd-type-ibm':U
    ,input  'ibmspool':U
    ,output v-value-character
    ,output v-value-date
    ,output v-value-decimal
    ,output v-value-integer
    ,output v-value-logical
    ,output v-param-type
    ,INPUT-OUTPUT table-handle v-tth
    ) no-error .
if error-status:error then do:
  delete object v-tth.
  return no.
end.
delete object v-tth.
assign
v-dopi = v-value-integer no-error .
if v-dopi >= 6 then return yes.
end. // FUNCTION/method
FUNCTION nzpl-two returns logical
                                 (input p-obj-type as character
                                  , input p-obj-code as integer):
  define variable v-nzpl-two as logical no-undo.
  run
  nzpl-two-proc (input p-obj-type, input p-obj-code, output v-nzpl-two).
  return v-nzpl-two.
end. // FUNCTION/method
procedure nzpl-two-proc :
define input  parameter p-obj-type   as character no-undo.
define input  parameter p-obj-code   as integer   no-undo.
define output parameter varge-two-pl as logical   no-undo.
define buffer bf_pl-gds-pump       for ub.pl-gds-pump.
define buffer bf-other_pl-gds-pump for ub.pl-gds-pump.
//do on error undo, return error return-value :
assign
  varge-two-pl = no.
for each bf_pl-gds-pump where bf_pl-gds-pump.obj-type = p-obj-type        and
                              bf_pl-gds-pump.obj-code = p-obj-code        and
                              bf_pl-gds-pump.status_  = 'тек':U no-lock on error undo, return error return-value :
  find first bf-other_pl-gds-pump where bf-other_pl-gds-pump.obj-type  =  bf_pl-gds-pump.obj-type  and
                                        bf-other_pl-gds-pump.obj-code  =  bf_pl-gds-pump.obj-code  and
                                        bf-other_pl-gds-pump.pump-code =  bf_pl-gds-pump.pump-code and
                                        bf-other_pl-gds-pump.gds-code  =  bf_pl-gds-pump.gds-code  and
                                        bf-other_pl-gds-pump.status_   =  'тек':U        and
                                        bf-other_pl-gds-pump.pl-code   <> bf_pl-gds-pump.pl-code   no-lock no-error.
  if available bf-other_pl-gds-pump then do:
    assign
      varge-two-pl = yes.
    leave.
  end.
end.
//end.
end. // procedure/method .
procedure cplgdspm :
  define input parameter parobj-type  like ub.pl-gds-pump.obj-type  no-undo.
  define input parameter parobj-code  like ub.pl-gds-pump.obj-code  no-undo.
  define input parameter parpl-code   like ub.pl-gds-pump.pl-code   no-undo.
  define input parameter pargds-code  like ub.pl-gds-pump.gds-code  no-undo.
  define input parameter parpump-code like ub.pl-gds-pump.pump-code no-undo.
  define input parameter parstatus    like ub.pl-gds-pump.status_   no-undo.
    define buffer bf_pl-gds-pump          for ub.pl-gds-pump.
    define buffer bf_pl-pump-nozzle       for ub.pl-pump-nozzle.
    define buffer bf-other_pl-pump-nozzle for ub.pl-pump-nozzle.
    define buffer bf-place                for ub.place.
    if parstatus = 'тек':U then do:
      for each bf_pl-gds-pump no-lock
        where bf_pl-gds-pump.obj-type  =  parobj-type
          and bf_pl-gds-pump.obj-code  =  parobj-code
          and bf_pl-gds-pump.gds-code  =  pargds-code
          and bf_pl-gds-pump.pump-code =  parpump-code
          and bf_pl-gds-pump.pl-code   <> parpl-code
          and bf_pl-gds-pump.status_   =  'тек':U
      on error undo, return error
      :
        find first place where
                   place.obj-type = parobj-type
               and place.obj-code = parobj-code
               and place.pl-code  = parpl-code
             no-lock no-error.
        find first bf-place where
                   bf-place.obj-type = parobj-type
               and bf-place.obj-code = parobj-code
               and bf-place.pl-code = bf_pl-gds-pump.pl-code
             no-lock no-error.
        if nzpl-spl(parobj-type, parobj-code) <> yes then do:
          return error substitute( "Попытка создать запись на объекте &1 &2 резервуар &3 товар с внутренним кодом &4 ТРК &5 статус &6.&7"
                                     ,parobj-type
                                     ,parobj-code
                                     ,if available place then place.loc1 else string(parpl-code)
                                     ,pargds-code
                                     ,parpump-code
                                     ,parstatus
                                     ,chr(10)
                                    )
                      + substitute( "КАССА не возвращает номер пистолета в чеке, а на объекте уже есть резервуар &1 с тем же товаром и связан он с этой же ТРК."
                                    ,if available bf-place then bf-place.loc1 else string(bf_pl-gds-pump.pl-code)
                                  ).
        end.
        else do:
          find first bf_pl-pump-nozzle no-lock
            where bf_pl-pump-nozzle.obj-type  = parobj-type
              and bf_pl-pump-nozzle.obj-code  = parobj-code
              and bf_pl-pump-nozzle.pump-code = parpump-code
              and bf_pl-pump-nozzle.pl-code   = parpl-code
            no-error.
          if available bf_pl-pump-nozzle then do:
            find first bf-other_pl-pump-nozzle no-lock
              where bf-other_pl-pump-nozzle.obj-type  = bf_pl-gds-pump.obj-type
                and bf-other_pl-pump-nozzle.obj-code  = bf_pl-gds-pump.obj-code
                and bf-other_pl-pump-nozzle.pump-code = bf_pl-gds-pump.pump-code
                and bf-other_pl-pump-nozzle.pl-code   = bf_pl-gds-pump.pl-code
              no-error.
            if available bf-other_pl-pump-nozzle
              and bf-other_pl-pump-nozzle.nozzle-code = bf_pl-pump-nozzle.nozzle-code
            then do:
              return error substitute( "Попытка создать запись на объекте &1 &2 резервуар &3 товар с внутренним кодом &4 ТРК &5 статус &6.&7"
                                       ,parobj-type
                                       ,parobj-code
                                       ,if available place then place.loc1 else string(parpl-code)
                                       ,pargds-code
                                       ,parpump-code
                                       ,parstatus
                                       ,chr(10)
                                     )
                          + substitute( "На объекте &1 &2 уже есть запись резервуар &3 в статусе &4, в котором находится этот же товар и он связан с этой же ТРК через этот же пистолет."
                                        ,bf_pl-gds-pump.obj-type
                                        ,bf_pl-gds-pump.obj-code
                                        ,if available bf-place then bf-place.loc1 else string(bf_pl-gds-pump.pl-code)
                                        ,bf_pl-gds-pump.status_
                                      ).
            end.
          end.
        end.
      end.
    end.
end . // procedure/method
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable varlog            as logical   no-undo.
define variable gds-rec           as recid     no-undo .
define variable v-doc-rec         as recid     no-undo .
define variable pl-list           as character no-undo .
define variable v-tth             as handle    no-undo.
define variable v-Param-Type      as character no-undo.
define variable glog              as logical   no-undo.
define variable v-value-character as character no-undo.
define variable v-value-date      as date      no-undo.
define variable v-value-decimal   as decimal   no-undo.
define variable v-value-integer   as integer   no-undo.
define variable v-value-logical   as logical   no-undo.
define variable filter-label      as character no-undo init "Блокировка пистолетов" .
define variable filter-label0     as character no-undo init "Блокировка пистолетов" .
define variable filter-point      as character no-undo init "blockplgdspm".
define variable filter-point0     as character no-undo init "blockplgdspm".
define variable v-ok              as logical   no-undo .
define variable v-title           as character no-undo .
DEFINE BUTTON b-block
   LABEL "&Блок в МП"
   SIZE 10 BY 1 TOOLTIP "Установить статут <Блокированный>".
DEFINE BUTTON b-cur
   LABEL "&Текущий"
   SIZE 10 BY 1 TOOLTIP "Установить статут <Текущий>".
DEFINE BUTTON b-exit AUTO-GO
   LABEL "&Выход"
   SIZE 10 BY 1
   BGCOLOR 8 .
DEFINE BUTTON b-help
   LABEL "&Помощь"
   SIZE 3 BY 1
   BGCOLOR 8 .
DEFINE BUTTON B-hist
   LABEL "Ис&тория"
   SIZE 3 BY 1.
DEFINE BUTTON b-mark
   LABEL "&*"
   SIZE 3 BY 1.
DEFINE BUTTON b-repeate-block
   LABEL "b-repeate-block"
   SIZE 10 BY 1.
DEFINE BUTTON b-repeate-unblock
   LABEL "b-repeate-unblock"
   SIZE 10 BY 1.
DEFINE BUTTON b-unblock
   LABEL "&Разблок"
   SIZE 10 BY 1.
DEFINE BUTTON bt-not-sel-all
   LABEL "+"
   SIZE 3 BY 1 TOOLTIP "Выбрать все".
DEFINE BUTTON bt-not-sel-desel-all
   LABEL "-"
   SIZE 3 BY 1 TOOLTIP "Отменить выбор".
DEFINE VARIABLE c-nozzle-code AS INTEGER   FORMAT ">>9":U INITIAL 0
   LABEL "Номер пистолета"
   VIEW-AS COMBO-BOX INNER-LINES 5
   LIST-ITEMS "0","1","2","3","4"
   DROP-DOWN-LIST
   SIZE 15.5 BY 1 NO-UNDO.
DEFINE VARIABLE c-pump-code   AS INTEGER   FORMAT ">>9":U INITIAL 0
   LABEL "Номер ТРК"
   VIEW-AS COMBO-BOX INNER-LINES 5
   LIST-ITEMS "0","1","2","3","4"
   DROP-DOWN-LIST
   SIZE 15.5 BY 1 NO-UNDO.
DEFINE VARIABLE search-goods  AS CHARACTER FORMAT "X(256)":U
   LABEL "Фильтр по товару"
   VIEW-AS FILL-IN
   SIZE 60 BY 1 TOOLTIP "Введите начало любого слова в названии товара и нажать Enter" NO-UNDO.
DEFINE QUERY b-plgdspm FOR
   X_marking
   SCROLLING.
if parbutton = "un-block" then v-title = "Разблокировка пистолетов" .
else v-title = "Блокировка пистолетов" .
DEFINE BROWSE b-plgdspm
   QUERY b-plgdspm NO-LOCK DISPLAY
   X_marking.marking-string column-label "*" format "X(3)":U
   X_marking.pump-code FORMAT ">9":U
   X_marking.nozzle-code FORMAT ">9":U
   X_marking.artic FORMAT "X(16)":U
   X_marking.gds-code FORMAT "999999999":U
   X_marking.gds-name FORMAT "X(10)":U
   X_marking.loc1 COLUMN-LABEL "Резервуар" FORMAT "X(8)":U
   X_marking.status_ FORMAT "X(8)":U
   X_marking.pl-code COLUMN-LABEL "Код резервуара" FORMAT ">>>>>>>>>>>>9":U
   X_marking.pl-name COLUMN-LABEL "Название резервуара"
   X_marking.prod-code FORMAT ">>>>>>>>9":U
   X_marking.prod-type COLUMN-LABEL "товара" FORMAT "X(3)":U
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 15.42.
DEFINE FRAME Dialog-Frame
   b-exit AT ROW 1 COL 1.25
   b-cur AT ROW 1 COL 11.25
   b-unblock AT ROW 1 COL 21.25
   b-block AT ROW 1 COL 22
   b-repeate-block AT ROW 1 COL 22
   b-repeate-unblock AT ROW 1 COL 22
   B-hist AT ROW 1 COL 92.88
   b-help AT ROW 1 COL 95.88
   search-goods AT ROW 2.25 COL 18 COLON-ALIGNED WIDGET-ID 2
   c-pump-code AT ROW 3.38 COL 29 COLON-ALIGNED WIDGET-ID 16
   c-nozzle-code AT ROW 3.38 COL 62.38 COLON-ALIGNED WIDGET-ID 18
   b-mark AT ROW 3.75 COL 1.13 WIDGET-ID 4
   bt-not-sel-all AT ROW 3.75 COL 4 WIDGET-ID 10 NO-TAB-STOP
   bt-not-sel-desel-all AT ROW 3.75 COL 6.88 WIDGET-ID 12 NO-TAB-STOP
   b-plgdspm AT ROW 4.67 COL 1
   SPACE(0.24) SKIP(0.44)
   WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
   SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
   TITLE v-title
   DEFAULT-BUTTON b-exit.
ASSIGN
   FRAME Dialog-Frame:SCROLLABLE = FALSE
   FRAME Dialog-Frame:HIDDEN     = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
   DO:
      APPLY "END-ERROR":U TO SELF.
   END.
ON return OF search-goods IN FRAME dialog-frame
   DO:
      define variable ii as integer no-undo .
      assign search-goods .
      run sort_ .
   END.
ON leave OF search-goods IN FRAME dialog-frame
   DO:
      assign search-goods .
      run sort_ .
   END.
ON CHOOSE OF b-block IN FRAME Dialog-Frame
   DO:
      define variable quest-ok as logical   no-undo .
      define variable ii       as integer   no-undo .
      define variable jj       as integer   no-undo .
      define variable list-pl  as character no-undo .
define variable vss-include-info6 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_nozzle-sts_work':U
    ,input  'object':U
    ,input  v-cntxt-host-code-obj
    ,input  v-cntxt-obj-type
    ,input  v-cntxt-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output glog
    )  .
end.
      IF NOT glog THEN RETURN NO-APPLY.
      if available X_marking then
      do:
         message "Блокировать выбранные пистолеты в" skip
            "АСУ 'Заправщик'"
            view-as alert-box question buttons yes-no update quest-ok.
         if quest-ok then
         do:
            pl-list = "".
            for each X_marking where X_marking.marking-string = "*" :
               if pl-list = "" then
               do:
                  pl-list =
                     string(X_marking.nozzle-code) + ":" +
                     string(X_marking.pump-code)
                     .
               end.
               else
               do:
                  pl-list = pl-list + ";" +
                     string(X_marking.nozzle-code) + ":" +
                     string(X_marking.pump-code)
                     .
               end.
            end.
            if pl-list = "" then
            do:
               message "Ни один пистолет не выбран для блокировки"
                  view-as alert-box.
               OPEN QUERY b-plgdspm FOR EACH X_marking OUTER-JOIN BY X_marking.obj-type      BY X_marking.obj-code       BY X_marking.pump-code        BY X_marking.nozzle-code.
               return no-apply .
            end.
            run str/diallog.w ( input parparentproc
               ,input this-procedure
               ,input 'str/get-block-nozzle.p':U
               ,input (v-cntxt-obj-type + chr(4) +
               string(v-cntxt-obj-code) + chr(4) +
               string(0) + chr(4) +
               string(0) + chr(4) +
               chr(4) +
               chr(4) +
               chr(4) +
               substitute("&1,&2"
               ,"block"
               ,pl-list))
               ,input yes
               ,input ''
               ,input 'Блокировка выбранных пистолетов') .
            if not error-status:error then
            do:
               if return-value begins "Для кассы" then
               do:
                  message return-value
                     view-as alert-box question buttons yes-no update v-ok as logical  .
                  if v-ok then apply "choose" to b-repeate-block in frame Dialog-Frame .
                  else                   message "Сообщите в службу поддержки о неуспешной попытке блокировки пистолетов"
                        view-as alert-box.
               end.
               else
               do:
                  message "Блокировка пистолетов прошла успешно"
                     view-as alert-box.
               end.
            end.
            else
            do:
               message return-value
                  view-as alert-box question buttons yes-no update v-ok .
               if v-ok then apply "choose" to b-repeate-block in frame Dialog-Frame .
               else                   message "Сообщите в службу поддержки о неуспешной попытке блокировки пистолетов"
                     view-as alert-box.
            end.
            apply "choose" to b-exit in frame Dialog-Frame.
         end.
      end.
   END.
ON CHOOSE OF B-hist IN FRAME Dialog-Frame
   DO:
      DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
      IF AVAILABLE X_marking  THEN
      DO:
         run ref/cplchist.w (
            INPUT parParentProc
            , input parobj-type
            , input parobj-code
            , input "":U
            , input "subject":U
            , input X_marking.obj-type
            , input X_marking.obj-code
            , input X_marking.pl-code
            , input X_marking.gds-code
            , input X_marking.pump-code
            , input 0
            , input 'pl-gds-pump':U
            , input-output v-rid-list
            ) no-error .
      END.
   END.
ON CHOOSE OF b-mark IN FRAME Dialog-Frame
   DO:
      define variable loc#log     as logical no-undo .
      define variable row-marking as rowid   no-undo .
      if available x_marking then
      do:
         if x_marking.marking-string = "*" then X_marking.marking-string = "" .
         else X_marking.marking-string = "*" .
         row-marking = rowid(X_marking).
         loc#log = b-plgdspm:refresh() .
         reposition b-plgdspm to rowid row-marking.
         loc#log = b-plgdspm:refresh() .
         if last-event:function <> "MOUSE-SELECT-DBLCLICK" then
         do:
            loc#log = b-plgdspm:select-next-row () .
            apply "VALUE-CHANGED" to b-plgdspm in frame Dialog-Frame .
         end.
         apply "entry" to b-plgdspm in frame Dialog-Frame.
      end.
   END.
ON CHOOSE OF b-repeate-block IN FRAME Dialog-Frame
   DO:
      define variable quest-ok as logical   no-undo .
      define variable ii       as integer   no-undo .
      define variable jj       as integer   no-undo .
      define variable list-pl  as character no-undo .
      run str/diallog.w ( input parparentproc
         ,input this-procedure
         ,input 'str/get-block-nozzle.p':U
         ,input (v-cntxt-obj-type + chr(4) +
         string(v-cntxt-obj-code) + chr(4) +
         string(0) + chr(4) +
         string(0) + chr(4) +
         chr(4) +
         chr(4) +
         chr(4) +
         substitute("&1,&2"
         ,"block"
         ,pl-list))
         ,input yes
         ,input ''
         ,input 'Блокировка выбранных пистолетов') .
      if not error-status:error then
      do:
         if return-value begins "Для кассы" then
         do:
            message return-value
               view-as alert-box question buttons yes-no update v-ok as logical  .
            if v-ok then apply "choose" to b-repeate-block in frame Dialog-Frame .
            else message "Сообщите в службу поддержки о неуспешной попытке блокировки пистолетов"
                  view-as alert-box.
         end.
         else
         do:
            message "Блокировка пистолетов прошла успешно"
               view-as alert-box.
         end.
      end.
      else
      do:
         message return-value
            view-as alert-box question buttons yes-no update v-ok .
         if v-ok then apply "choose" to b-repeate-block in frame Dialog-Frame .
         else                   message "Сообщите в службу поддержки о неуспешной попытке блокировки пистолетов"
               view-as alert-box.
      end.
      apply "choose" to b-exit in frame Dialog-Frame.
   END.
ON CHOOSE OF b-repeate-unblock IN FRAME Dialog-Frame
   DO:
      define variable quest-ok as logical   no-undo .
      define variable ii       as integer   no-undo .
      define variable jj       as integer   no-undo .
      define variable list-pl  as character no-undo .
      run str/diallog.w ( input parparentproc
         ,input this-procedure
         ,input 'str/get-block-nozzle.p':U
         ,input (v-cntxt-obj-type + chr(4) +
         string(v-cntxt-obj-code) + chr(4) +
         string(0) + chr(4) +
         string(0) + chr(4) +
         chr(4) +
         chr(4) +
         chr(4) +
         substitute("&1,&2"
         ,"unblock"
         ,pl-list))
         ,input yes
         ,input ''
         ,input 'Разблокировка пистолетов') .
      if not error-status:error then
      do:
         if return-value begins "Для кассы" then
         do:
            message return-value
               view-as alert-box question buttons yes-no update v-ok as logical  .
            if v-ok then apply "choose" to b-repeate-unblock in frame Dialog-Frame .
            else message "Сообщите в службу поддержки о неуспешной попытке разблокировки пистолетов"
                  view-as alert-box.
         end.
         else
         do:
            message "Разблокировка пистолетов прошла успешно"
               view-as alert-box.
         end.
      end.
      else
      do:
         message return-value
            view-as alert-box question buttons yes-no update v-ok .
         if v-ok then apply "choose" to b-repeate-block in frame Dialog-Frame .
         else                   message "Сообщите в службу поддержки о неуспешной попытке разблокировки пистолетов"
               view-as alert-box.
      end.
      apply "choose" to b-exit in frame Dialog-Frame.
   END.
ON CHOOSE OF b-unblock IN FRAME Dialog-Frame
   DO:
      define variable quest-ok as logical no-undo .
define variable vss-include-info7 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_nozzle-sts_work':U
    ,input  'object':U
    ,input  v-cntxt-host-code-obj
    ,input  v-cntxt-obj-type
    ,input  v-cntxt-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output glog
    )  .
end.
      IF NOT glog THEN RETURN NO-APPLY.
      if available X_marking then
      do:
         message "Разблокировать все пистолеты в" skip
            "АСУ 'Заправщик'?"
            view-as alert-box question buttons yes-no update quest-ok.
         if quest-ok then
         do:
            pl-list = "".
            for each X_marking :
               if pl-list = "" then
               do:
                  pl-list =
                     string(X_marking.nozzle-code) + ":" +
                     string(X_marking.pump-code)
                     .
               end.
               else
               do:
                  pl-list = pl-list + ";" +
                     string(X_marking.nozzle-code) + ":" +
                     string(X_marking.pump-code)
                     .
               end.
            end.
            run str/diallog.w ( input parparentproc
               ,input this-procedure
               ,input 'str/get-block-nozzle.p':U
               ,input (v-cntxt-obj-type + chr(4) +
               string(v-cntxt-obj-code) + chr(4) +
               string(1) + chr(4) +
               string(0) + chr(4) +
               chr(4) +
               chr(4) +
               chr(4) +
               substitute("&1,&2"
               ,"unblock"
               ,pl-list))
               ,input yes
               ,input ''
               ,input 'Разблокировка пистолетов') .
            if not error-status:error then
            do:
               if return-value begins "Для кассы" then
               do:
                  message return-value
                     view-as alert-box question buttons yes-no update v-ok as logical  .
                  if v-ok then apply "choose" to b-repeate-unblock in frame Dialog-Frame .
                  else message "Сообщите в службу поддержки о неуспешной попытке разблокировки пистолетов"
                        view-as alert-box.
               end.
               else
               do:
                  message "Разблокировка пистолетов прошла успешно"
                     view-as alert-box.
               end.
            end.
            else
            do:
               message return-value
                  view-as alert-box question buttons yes-no update v-ok .
               if v-ok then apply "choose" to b-repeate-block in frame Dialog-Frame .
               else                   message "Сообщите в службу поддержки о неуспешной попытке разблокировки пистолетов"
                     view-as alert-box.
            end.
            apply "choose" to b-exit in frame Dialog-Frame.
         end.
      end.
   END.
ON CHOOSE OF bt-not-sel-all IN FRAME Dialog-Frame
   DO:
      define variable loc#log as logical no-undo .
      if available X_marking then
      do:
         for each X_marking :
            X_marking.marking-string = "*" .
            loc#log = b-plgdspm:refresh() no-error.
         end.
      end.
      apply "entry" to b-plgdspm in frame Dialog-Frame.
   END.
ON CHOOSE OF bt-not-sel-desel-all IN FRAME Dialog-Frame
   DO:
      define variable loc#log as logical no-undo .
      For each X_marking where X_marking.marking-string = "*":
         X_marking.marking-string = "" .
      end.
      loc#log = b-plgdspm:refresh() no-error.
   END.
ON VALUE-CHANGED OF c-nozzle-code IN FRAME Dialog-Frame
   DO:
      assign c-nozzle-code .
      run sort_ .
   END.
ON VALUE-CHANGED OF c-pump-code IN FRAME Dialog-Frame
   DO:
      assign c-pump-code .
      run sort_ .
   END.
ON leave OF search-goods IN FRAME Dialog-Frame
   DO:
      assign search-goods .
      run sort_ .
   END.
ON return OF search-goods IN FRAME Dialog-Frame
   DO:
      assign search-goods .
      run sort_ .
   END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
   THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame Dialog-Frame
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
on choose of b-help in frame Dialog-Frame
do:
  apply "help":u to frame Dialog-Frame .
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
                v-frame-width = frame Dialog-Frame:width - 0.3
                fh            = frame Dialog-Frame:first-child
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
    if frame Dialog-Frame :height + p-change-value
        > decimal(session :work-area-height-pixels) / session :pixels-per-row
    then do:
      assign
        p-change-value = decimal(session :work-area-height-pixels) / session :pixels-per-row
                        - (frame Dialog-Frame :height-chars)
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
    if frame Dialog-Frame :height + p-change-value < v-diasize-orig-frame-height
    then do:
      assign
        p-change-value = v-diasize-orig-frame-height
                       - (frame Dialog-Frame :height-chars)
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
            frame Dialog-Frame :height = v-frame-height
          .
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-height = v-frame-virtual-height
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-height = v-frame-virtual-height
            .
          end.
          assign
            frame Dialog-Frame :height = v-frame-height
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
      v-frame-height = frame Dialog-Frame :height
      v-frame-virtual-height = frame Dialog-Frame :virtual-height
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
      v-field-group-handle = frame Dialog-Frame :first-child
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
    do with frame Dialog-Frame
    :
      hide v-diasize-resize-button .
      assign
        v-diasize-resize-button :row    = 1
        v-diasize-resize-button :column = 1
      .
    end.
    if p-change-value > 0
    then do:
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-height = frame Dialog-Frame :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame Dialog-Frame :height = frame Dialog-Frame :height + p-change-value
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
        frame Dialog-Frame :height = frame Dialog-Frame :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-height = frame Dialog-Frame :virtual-height + p-change-value
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
          ,input  string(frame Dialog-Frame :height - v-diasize-orig-frame-height)
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
      (input  (p-new-height - frame Dialog-Frame :height)
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
    if frame Dialog-Frame :width + p-change-value >
        session :width-chars
    then do:
      assign
        p-change-value = session :width-chars - frame Dialog-Frame :width
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
    if frame Dialog-Frame :width + p-change-value < v-diasize-orig-frame-width
    then do:
      assign
        p-change-value = v-diasize-orig-frame-width
                       - frame Dialog-Frame :width
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
            frame Dialog-Frame :width = v-frame-width
          .
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-width = v-frame-virtual-width
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-width = v-frame-virtual-width
            .
          end.
          assign
            frame Dialog-Frame :width = v-frame-width
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
      v-frame-width = frame Dialog-Frame :width
      v-frame-virtual-width = frame Dialog-Frame :virtual-width
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
      v-field-group-handle = frame Dialog-Frame :first-child
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
    do with frame Dialog-Frame
    :
      hide v-diasize-resize-button .
      v-diasize-resize-button :row = 1.
      v-diasize-resize-button :column = 1.
    end.
    if p-change-value > 0
    then do:
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-width = frame Dialog-Frame :virtual-width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
      assign
        frame Dialog-Frame :width = v-frame-width + p-change-value
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
        frame Dialog-Frame :width = frame Dialog-Frame :width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-width = frame Dialog-Frame :virtual-width + p-change-value
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
          ,input  string(frame Dialog-Frame :width - v-diasize-orig-frame-width)
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
      (input  (p-new-width - frame Dialog-Frame :width)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_position-resize-button :
  do with frame Dialog-Frame
  :
    hide v-diasize-resize-button .
    assign
      v-diasize-resize-button :row = frame Dialog-Frame :height - v-diasize-resize-button :height
                  - 1
                  - (frame Dialog-Frame :border-bottom-pixels / session :pixels-per-row)
      v-diasize-resize-button :col = frame Dialog-Frame :width - v-diasize-resize-button :width
                  - 1
                  - (frame Dialog-Frame :border-right-pixels / session :pixels-per-column)
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
on alt-enter of frame Dialog-Frame
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
      v-row-delta = v-new-row - frame Dialog-Frame :height
      v-col-delta = v-new-col - frame Dialog-Frame :width
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
            - frame Dialog-Frame :height-chars
        ,input true
        ) .
      run diasize_change-width in this-procedure
        (input session :width-chars
            - frame Dialog-Frame :width-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = false
      .
    end.
    else do:
      run diasize_change-width in this-procedure
        (input v-diasize-orig-frame-width
            - frame Dialog-Frame :width-chars
        ,input true
        ) .
      run diasize_change-height in this-procedure
        (input v-diasize-orig-frame-height
            - frame Dialog-Frame :height-chars
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
      v-diasize-current-frame-width  = frame Dialog-Frame :width
      v-diasize-current-frame-height = frame Dialog-Frame :height
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
    do with frame Dialog-Frame
    :
      assign
        v-diasize-orig-frame-height = frame Dialog-Frame :height
        v-diasize-orig-frame-width  = frame Dialog-Frame :width
        v-diasize-browse-handle     = browse b-plgdspm :handle
      .
      create button v-diasize-resize-button
      assign
        parent        = frame Dialog-Frame :first-child
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
on F9 of frame Dialog-Frame anywhere do:
  if not available ub.goods then
    return no-apply.
  gds-rec = recid (ub.goods).
  run ref/gds-form.w ( input parparentproc
                      ,input 'ПРОСМОТР':U
                      ,input ?
                      ,input ?
                      ,input ?
                      ,input-output gds-rec).
  apply "entry" to b-plgdspm in frame Dialog-Frame.
  return no-apply.
end.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  b-plgdspm :SET-REPOSITIONED-ROW(5, "CONDITIONAL") .
end.
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on f5 of frame Dialog-Frame anywhere
do:
   if available X_marking then v-doc-rec = recid(X_marking). OPEN QUERY b-plgdspm FOR EACH X_marking OUTER-JOIN BY X_marking.obj-type      BY X_marking.obj-code       BY X_marking.pump-code        BY X_marking.nozzle-code.   reposition b-plgdspm to recid v-doc-rec no-error. apply 'ENTRY' to b-plgdspm.
    apply "VALUE-CHANGED" to b-plgdspm.
end.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in parparentproc
    (output v-cntxt-db-num
    ,output v-cntxt-userid
    ,output v-cntxt-level
    ,output v-cntxt-host-code-obj
    ,output v-cntxt-obj-type
    ,output v-cntxt-obj-code
    ,output v-cntxt-db-num-obj
    ,output v-cntxt-is-admin
    ) .
define variable vss-include-info15 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_nozzle-sts_work':U
    ,input  'object':U
    ,input  v-cntxt-host-code-obj
    ,input  v-cntxt-obj-type
    ,input  v-cntxt-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output v-ok
    )  .
end.
   if NOT v-ok then
   do:
      message "Недостаточно прав доступа для выполнения блокировки\разблокировки пистолетов в ручную." skip
         "нет права - 'actn_nozzle-sts_work' "
         view-as alert-box.
      return no-apply .
   end.
   RUN enable_tt.
   RUN enable_UI.
   WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
   HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_tt :
   FOR EACH X_pl-gds-pump       WHERE X_pl-gds-pump.obj-type = parobj-type  AND X_pl-gds-pump.obj-code = parobj-code NO-LOCK, ~
      EACH X_goods WHERE X_goods.gds-code = X_pl-gds-pump.gds-code NO-LOCK, ~
      EACH X_place WHERE X_place.pl-code = X_pl-gds-pump.pl-code NO-LOCK, ~
      EACH X_pl-pump-nozzle WHERE X_pl-pump-nozzle.obj-type = X_pl-gds-pump.obj-type   AND X_pl-pump-nozzle.obj-code = X_pl-gds-pump.obj-code   AND X_pl-pump-nozzle.pl-code = X_pl-gds-pump.pl-code   AND X_pl-pump-nozzle.pump-code = X_pl-gds-pump.pump-code NO-LOCK     BY X_pl-gds-pump.obj-type      BY X_pl-gds-pump.obj-code       BY X_pl-pump-nozzle.pump-code        BY X_pl-pump-nozzle.nozzle-code:
      find first X_marking where X_marking.pl-code = X_pl-gds-pump.pl-code and
         X_marking.pump-code = X_pl-gds-pump.pump-code and
         X_marking.gds-code = X_pl-gds-pump.gds-code and
         X_marking.nozzle-code = X_pl-pump-nozzle.nozzle-code no-error .
      if not available (X_marking) then
      do:
         create X_marking .
         assign
            X_marking.obj-code    = X_pl-gds-pump.obj-code
            X_marking.obj-type    = X_pl-gds-pump.obj-type
            X_marking.pl-code     = X_pl-gds-pump.pl-code
            X_marking.pump-code   = X_pl-gds-pump.pump-code
            X_marking.gds-code    = X_pl-gds-pump.gds-code
            X_marking.nozzle-code = X_pl-pump-nozzle.nozzle-code
            X_marking.artic       = X_goods.artic
            X_marking.gds-code    = X_goods.gds-code
            X_marking.gds-name    = X_goods.gds-name
            X_marking.loc1        = X_place.loc1
            X_marking.status_     = X_pl-gds-pump.status_
            X_marking.pl-name     = X_place.pl-name
            X_marking.prod-code   = X_goods.prod-code
            X_marking.prod-type   = X_goods.prod-type
            X_marking.search-log  = false
            .
      end.
   end.
END PROCEDURE.
PROCEDURE iniTable :
   for each X_marking:
      for first X_pl-pump-nozzle WHERE X_pl-pump-nozzle.obj-type = X_marking.obj-type   AND
         X_pl-pump-nozzle.obj-code = X_marking.obj-code   AND
         X_pl-pump-nozzle.pl-code = X_marking.pl-code   AND
         X_pl-pump-nozzle.pump-code = X_marking.pump-code ,
         first X_place no-lock where X_place.pl-code = X_marking.pl-code,
         first X_pl-gds-pump exclusive-lock where X_pl-gds-pump.gds-code = X_marking.gds-code and
         X_pl-gds-pump.obj-code = X_pl-pump-nozzle.obj-code and
         X_pl-gds-pump.obj-type = X_pl-pump-nozzle.obj-type and
         X_pl-gds-pump.pl-code = X_pl-pump-nozzle.pl-code and
         X_pl-gds-pump.pump-code = X_pl-pump-nozzle.pump-code:
         X_pl-gds-pump.status_ = X_marking.status_ .
      end.
   end.
END PROCEDURE.
PROCEDURE enable_UI :
   define variable ii            as integer   no-undo .
   define variable v-pump-code   as character no-undo .
   define variable v-nozzle-code as character no-undo .
   for each X_marking by X_marking.pump-code by X_marking.nozzle-code:
      if lookup(string(X_marking.pump-code), v-pump-code, ",") = 0 then
         v-pump-code = v-pump-code + "," + string(X_marking.pump-code) .
      if lookup(string(X_marking.nozzle-code), v-nozzle-code, ",") = 0 then
         v-nozzle-code = v-nozzle-code + "," + string(X_marking.nozzle-code) .
   end.
   ASSIGN
      c-pump-code:list-items  in frame Dialog-Frame   = v-pump-code
      c-nozzle-code:list-items  in frame Dialog-Frame = v-nozzle-code .
   DISPLAY search-goods
      WITH FRAME Dialog-Frame.
   if parbutton = "block" then
   do:
      ENABLE b-exit b-block B-hist b-help search-goods b-mark bt-not-sel-all c-nozzle-code c-pump-code
         bt-not-sel-desel-all b-plgdspm
         WITH FRAME Dialog-Frame.
      hide b-unblock in frame Dialog-Frame .
   end.
   if parbutton = "un-block" then
   do:
      ENABLE b-exit b-unblock B-hist b-help search-goods b-plgdspm c-nozzle-code c-pump-code
         WITH FRAME Dialog-Frame.
      hide b-block in frame Dialog-Frame .
   end.
   else
   do:
      ENABLE b-exit B-hist b-help b-plgdspm
         WITH FRAME Dialog-Frame.
   end.
   VIEW FRAME Dialog-Frame.
   hide b-repeate-block b-repeate-unblock in frame Dialog-Frame .
   OPEN QUERY b-plgdspm FOR EACH X_marking OUTER-JOIN BY X_marking.obj-type      BY X_marking.obj-code       BY X_marking.pump-code        BY X_marking.nozzle-code.
END PROCEDURE.
PROCEDURE local-stts :
   define input  parameter p-stts as character no-undo .
   define variable varrecid    as recid   no-undo.
   define variable v-host-code as integer no-undo .
   define buffer buf_pl-gds-pump for ub.pl-gds-pump.
   do transaction
      on error undo, retry
      :
      if retry then
      do:
         message
            vss-workfile vss-revision vss-description skip(1)
            substitute( "Ошибка при приcвоении статуса <&1>!", p-stts ) skip
            return-value skip
            error-status :get-message(1)
            view-as alert-box error.
         undo, return error .
      end.
      find first buf_pl-gds-pump exclusive-lock where
         recid(buf_pl-gds-pump) = recid(X_pl-gds-pump).
      if buf_pl-gds-pump.status_ = p-stts then
      do:
         message
            substitute( "Запись уже имеет статус <&1>.", p-stts )
            view-as alert-box information
            .
         undo, return error .
      end.
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  parobj-type
  ,input  parobj-code
  ,output v-host-code
  )  .
define variable vss-include-info17 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_plgdspm-sts_work':U
    ,input  'object':U
    ,input  v-host-code
    ,input  parobj-type
    ,input  parobj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output varlog
    )  .
end.
      if not varlog then
      do:
         undo, return error .
      end.
      assign
         buf_pl-gds-pump.status_ = p-stts
         .
      if p-stts = 'тек':U then
      do:
         run cplgdspm in this-procedure
            ( input buf_pl-gds-pump.obj-type
            ,input buf_pl-gds-pump.obj-code
            ,input buf_pl-gds-pump.pl-code
            ,input buf_pl-gds-pump.gds-code
            ,input buf_pl-gds-pump.pump-code
            ,input p-stts
            ).
      end.
   end.
   assign
      varrecid = recid(X_pl-gds-pump)
      .
   OPEN QUERY b-plgdspm FOR EACH X_marking OUTER-JOIN BY X_marking.obj-type      BY X_marking.obj-code       BY X_marking.pump-code        BY X_marking.nozzle-code.
   reposition b-plgdspm to recid varrecid.
end procedure.
PROCEDURE sort_ :
   define variable ii as integer no-undo .
   empty temp-table X_marking .
   run enable_tt .
   if c-pump-code <> ? and c-pump-code <> 0 then
   do:
      for each X_marking where X_marking.pump-code <> c-pump-code:
         delete X_marking .
      end.
   end.
   if c-nozzle-code <> ? and c-nozzle-code <> 0 then
   do:
      for each X_marking where X_marking.nozzle-code <> c-nozzle-code:
         delete X_marking .
      end.
   end.
   if search-goods <> "" then
   do:
      for each X_marking:
         do ii = 1 to num-entries (X_marking.gds-name," "):
            if entry(ii,X_marking.gds-name," ") begins search-goods then X_marking.search-log = true .
         end.
      end.
      for each X_marking where X_marking.search-log <> true:
         delete X_marking .
      end.
   end.
   OPEN QUERY b-plgdspm FOR EACH X_marking OUTER-JOIN BY X_marking.obj-type      BY X_marking.obj-code       BY X_marking.pump-code        BY X_marking.nozzle-code.
end procedure.
