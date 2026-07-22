block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision:$":U .
define variable vss-author      as character no-undo init "$Author:$":U .
define variable vss-date        as character no-undo init "$Date:$":U .
define variable vss-workfile    as character no-undo init "$Workfile:$":U .
define variable vss-archive     as character no-undo init "$Archive:$":U .
define variable vss-description as character no-undo init "agent asi".
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
define temp-table tt-place no-undo
  field loc1          as character  label "№ резервуара"
  field locint        as integer    label "№ резервуара"           init ?
  field pl-code       as integer    label "Код резервуара"
  field gds-code      as integer    label "Код продукта"
  field gds-name      as character  label "НАИМЕНОВАНИЕ ПРОДУКТА"
  field level-total   as decimal    label "Общий уровень (см)"
  field level-water   as decimal    label "Уровень воды (см)"
  field total-vol     as decimal    label "Общий объем (л)"
  field avrg-temp     as decimal    label "Средняя Т"
  field t1            as decimal    label "T1"
  field t2            as decimal    label "T2"
  field t3            as decimal    label "T3"
  field density       as decimal    label "Плотность (кг/л)"
  field mass          as decimal    label "Масса (кг)"
  field vapor-density as decimal    label "Плотность СУГ (кг/л)"
  field vapor-pressure as decimal   label "Давление СУГ (мПа)"
  field volume_water  as decimal
  field is-error      as logical
  field error-message as character
  index pi as unique
    loc1
  index locint as primary locint loc1
.
define input parameter p-loclist as character no-undo .
define input parameter p-no-waitfram as logical no-undo .
define output parameter table for tt-place bind.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  define new global shared variable g#lib-rvs as handle no-undo.
  define temp-table tt-param no-undo
    field strfrfile as character
    field strasi    as character
    field flddb     as character
    index pi        as primary   unique strfrfile
    index asi strasi.
  define temp-table tt-param-pump no-undo
    field strfrfile as character
    field meaning   as character
    index pi        as primary   unique strfrfile.
  define temp-table tt-meas no-undo like ub.place
    field measure-qnty like ub.rvs-line.measure-qnty
    field brutto-qnty like ub.rvs-line.brutto-qnty
    field measure-cli-qnty like ub.rvs-line.measure-cli-qnty
    field brutto-cli-qnty like ub.rvs-line.brutto-cli-qnty
    field density like ub.rvs-line.density
    field temperature like ub.rvs-line.temperature
    field level-total like ub.rvs-line.level-total
    field level-petrol like ub.rvs-line.level-petrol
    field level-water like ub.rvs-line.level-water
    field temp-layer1 like ub.rvs-line.temp-layer1
    field temp-layer2 like ub.rvs-line.temp-layer2
    field temp-layer3 like ub.rvs-line.temp-layer3
    field measure-tc-qnty like ub.rvs-line.measure-tc-qnty
    field brutto-tc-qnty like ub.rvs-line.brutto-tc-qnty
    field meas-vol-oil   as logical initial no
    field meas-vol-water as logical initial no
    field water-qnty     like ub.rvs-line.measure-qnty
    field vapor-density like ub.rvs-line.density
    field vapor-pressure as decimal format ">>9.9<":U
    field log-brutto as logical
    field temp-not-null as logical
    field t1-not-null as logical
    field t2-not-null as logical
    field t3-not-null as logical
    field is-error    as logical
    index pi        as primary   loc1.
  define temp-table tt-meas-file no-undo like tt-meas.
  define temp-table tt-pump-nozzle no-undo like ub.pump-nozzle
    field gds-code    like ub.goods.gds-code
    field meas-el-cnt like ub.rvs-line-pump.meas-el-cnt
    field meas-am-cnt like ub.rvs-line-pump.meas-am-cnt
    field grade       as   character
    field meas-cf-cnt like ub.rvs-line-pump.meas-cf-cnt.
  define temp-table tt-pump-nozzle-file no-undo like tt-pump-nozzle.
define variable vss-revision1    as character no-undo init "$Revision:$":U .
define variable vss-author1      as character no-undo init "$Author:$":U .
define variable vss-date1        as character no-undo init "$Date:$":U .
define variable vss-workfile1    as character no-undo init "$Workfile:$":U .
define variable vss-archive1     as character no-undo init "$Archive:$":U .
define variable vss-description1 as character no-undo init "Работа С сокетом".
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
procedure PutMesAsunc:
    define input  parameter Itext as character no-undo.
    define variable vflag as logical no-undo.
    Publish "WriteLogAsunc" (Itext, yes)  .
end.
procedure PutMesAsuncNoTime:
    define input  parameter Itext as character no-undo.
    define variable vflag as logical no-undo.
    Publish "WriteLogAsunc" (Itext,no)  .
end.
procedure PutStatAsunc:
    define input  parameter Itext as character no-undo.
    Publish "PutStatAsunc" (Itext,no) .
     run
    PutMesAsunc (itext).
end.
procedure PutStatAsuncNoTime:
    define input  parameter Itext as character no-undo.
    Publish "PutStatAsunc" (Itext,no)  .
     run
    PutMesAsuncNoTime (itext).
end.
procedure PutStatAsuncAdd:
    define input  parameter Itext as character no-undo.
    Publish "PutStatAsunc" (Itext,yes)  .
end.
procedure PutFileLogAsunc:
    define input  parameter IFile as character no-undo.
    Publish "PutFileLogAsunc" (ifile)  .
end.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable mHSocket       as handle      no-undo.
define variable mWebRespHead   as longchar    no-undo.
define variable mWebResp       as longchar    no-undo.
define variable mWebRespMptr   as memptr      no-undo.
define variable OerrMsg        as character   no-undo.
define variable mFileLogSocet  as character   no-undo.
define variable mReturnHttp    as logical     no-undo.
define variable mAddTimeOut    as logical     no-undo init yes.
define variable mSocetBegTime  as datetime-tz no-undo.
define variable mSocetEndTime  as dec         no-undo.
define variable mWriteRespFile as character   no-undo.
define variable mTypeResponse  as character   no-undo init "POST".
publish "getSocetLog" (output mFileLogSocet).
if
   (   mFileLogSocet eq ""
    or mFileLogSocet eq ?)
   and session:debug-alert
then
   mFileLogSocet = "socet.log".
procedure ConectSocet:
   define input  parameter iHost       as character no-undo.
   define input  parameter iPort       as character no-undo.
   define input  parameter iUrl        as character no-undo.
   define input  parameter iPostData   as longchar  no-undo.
   define input  parameter iReturnType as character no-undo.
   define input  parameter iTimeOut    as decimal   no-undo.
   define input  parameter iSilent     as logical   no-undo.
   define input  parameter iTextWait   as character no-undo.
   mWaitFramTextBeg = iTextWait.
   run SendReqSocet (iHost, iPort, iUrl, iPostData, iReturnType, 'getResponse').
   if OerrMsg eq ""
   then
      run waitrespsocet (iTimeOut, iSilent, iTextWait).
   mSocetEndTime = (now - mSocetBegTime) / 1000.
end.
procedure SendReqSocet:
   define input  parameter iHost            as character no-undo.
   define input  parameter iPort            as character no-undo.
   define input  parameter iUrl             as character no-undo.
   define input  parameter iPostData        as longchar  no-undo.
   define input  parameter iReturnType      as character no-undo.
   define input  parameter iProcGetResponse as character no-undo.
   mSocetBegTime = now.
   run writeLogSocet in this-procedure (substitute("Подключаемся к адресу &1 по порту &2",iHost,iPort )).
   assign
      mWebResp         = ""
      mWebResphead     = ""
      OerrMsg          = ""
      mReturnHttp      = iReturnType eq "xml" or iReturnType eq "http" or iReturnType eq "yes"
      iProcGetResponse = "getResponse"  when iProcGetResponse eq ? or iProcGetResponse eq ""
   .
   define variable vPostData as longchar                       no-undo.
   if    iHost eq ""
      or iHost eq ?
   then do:
      oErrMsg = substitute("Не задан host &1 или port &2.", ihost ,iport).
      run writeLogSocet in this-procedure (oErrMsg).
      return oErrMsg.
   end.
   run waitfram-show (substitute("Подключаемся к адресу &1 по порту &2",iHost,iPort )).
   create socket mHSocket.
   mHSocket:connect('-H ' + iHost + ' -S ' + iPort) no-error.
   if mHSocket:connected() = false
   then do:
      run waitfram-hide .
      oErrMsg = substitute( "Не удалось установить соединение: &1" , error-status:get-message(1)).
      run writeLogSocet in this-procedure (oErrMsg).
      delete object mHSocket.
      return oErrMsg.
   end.
   run waitfram-show ("Отправка данных").
   mHSocket:set-read-response-procedure(iProcGetResponse).
   run PostRequest (
    input iUrl,
    input iHost + ":" + iPort,
    input iPostData
    ).
    run waitfram-hide .
end.
procedure WaitRespSocet:
   define input  parameter iTimeOut   as decimal   no-undo.
   define input  parameter iSilent    as logical   no-undo.
   define input  parameter iTextWait  as character no-undo.
   if    not valid-handle (mHSocket )
   then do:
      run writeLogSocet in this-procedure (substitute("Потерян объект соединения")).
      return "End connected".
   end.
   if mHSocket:connected() = false
   then do:
      run writeLogSocet in this-procedure (substitute("Соединение было разорвано другой стороной WaitRespSocet")).
      oErrMsg = "Not connected".
      return oErrMsg.
   end.
   mWaitFramView = if iSilent ne yes then yes else no.
   mWaitFramTextBeg = iTextWait.
   mWaitFramTimeOut = iTimeOut.
   mWaitFramTextEnd = "".
   mWaitFramStop = no.
   if mAddTimeOut
   then do:
      mWaitFramTimeOut = 300.
      run writeLogSocet in this-procedure (substitute ("Таймаут увеличен до &1 при уcтановке соодинения",mWaitFramTimeOut)).
   end.
   run writeLogSocet in this-procedure (substitute("Ожидаем ответ TimeOut &1 сек.",iTimeOut )).
   subscribe   to "WaitFramStop" anywhere run-procedure "WaitRespTestStop".
   run WaitFramWaitFor(1).
   unsubscribe "WaitFramStop".
   if mWaitFramStopUser
   then do:
      OerrMsg = substitute("Операция прервана пользователем." ).
      run writeLogSocet in this-procedure (OerrMsg).
   end.
   else if mWaitFramStopTimeOut
   then do:
      OerrMsg = substitute("Привышено время ожидания &1 сек. Ответ не получен.",iTimeOut ).
      run writeLogSocet in this-procedure (OerrMsg).
   end.
   run waitfram-hide .
   mHSocket:disconnect() no-error.
   delete object mHSocket.
end.
procedure WaitRespTestStop:
   if mWaitFramStopTimeOut
   then
      return.
   if     (mWebResp ne ""
       and mWebResp ne ?)
   then do:
      mWaitFramStop = yes.
      return.
   end.
   else if mHSocket:connected() = false
   then do:
      mWaitFramStop = yes.
      run writeLogSocet in this-procedure (substitute("Соединение было разорвано другой стороной WaitRespTestStop")).
      oErrMsg = "Not connected".
      return oErrMsg.
   end.
   wait-for read-response of mHSocket pause 0.001.
end.
procedure PostRequest:
   define input parameter iPostUrl  as char.
   define input parameter iPostHost as char.
   define input parameter iPostData as longchar.
   define variable vCRequest      as longchar.
   define variable vMRequest       as memptr.
   if iPostUrl ne ?
   then do:
      vCRequest =substitute(
      '&5 /&2 HTTP/1.1&1'                                   +
      'Host: &4&1'                                           +
      'User-Agent: Apache-HttpClient/4.1.1 (java 1.5)&1'    +
      'Accept: */*&1' +
      'Content-Type: text/xml&1'               +
      'Content-Length: &3&1'                                  +
      '&1'
      ,
      chr(13) + chr(10),
      iPostUrl,
      length(iPostData),
      iPostHost,
      mTypeResponse) + iPostData.
   end.
   else
      vCRequest = iPostData.
   run writeLogSocet in this-procedure (substitute("Отправляем запрос &1.",chr(13) + chr(10) )).
   run writeLogSocet in this-procedure (vCRequest).
   SET-SIZE(vMRequest)            = 0.
   SET-SIZE(vMRequest)            = length(vCRequest) + 1.
   SET-BYTE-ORDER(vMRequest)      = big-endian.
   PUT-STRING(vMRequest,1)        = vCRequest .
   if mHSocket:connected() = false then
   do:
      run writeLogSocet in this-procedure ("Соединение было разорвано другой стороной getResponse").
      oErrMsg = "Not connected".
      delete object mHSocket no-error.
      return oErrMsg.
   end.
   mHSocket:write(vMRequest, 1, length(vCRequest)).
   run writeLogSocet in this-procedure ("Запрос отправлен.").
end procedure.
function hex-to-int returns integer (
  input p-hex-code  as character  ).
  define variable v-int-code as integer   no-undo .
  define variable v-ind      as integer   no-undo .
  define variable v-digit    as integer   no-undo .
  define variable v-letter   as character no-undo .
  do v-ind = 1 to length(p-hex-code)
  :
    assign
      v-letter = caps(substring(p-hex-code, v-ind, 1))
    .
    assign
      v-digit = index('123456789ABCDEF':u, v-letter)
    .
    assign
      v-int-code = v-int-code * 16 + v-digit
    .
  end.
  return v-int-code .
end function .
procedure getResponse:
   define variable vFlagTag     as logical          no-undo init no.
   define variable vResponse    as memptr           no-undo.
   define variable vCnt         as int64            no-undo.
   define variable vMessage     as longchar         no-undo.
   define variable v-cont-length as int64 no-undo.
   define variable vi           as integer no-undo.
   define variable v-hd-line    as character no-undo.
   define variable level        as integer no-undo initial 2.
   repeat while program-name(level) <> ?:
     if program-name(level) = program-name(1) then do:
       run writeLogSocet in this-procedure (substitute("Повторный вызов getResponse.")).
       return "".
     end.
     level = level + 1.
   end.
   if mHSocket:connected() = false then
   do:
      run writeLogSocet in this-procedure (substitute("Соединение было разорвано другой стороной getResponse")).
      oErrMsg = "Not connected".
      return oErrMsg.
   end.
   if mAddTimeOut
   then do:
      mWaitFramTimeOut = 1000.
      run writeLogSocet in this-procedure (substitute ("Таймаут увеличен до &1 при получении ответа",mWaitFramTimeOut)).
   end.
   run writeLogSocet in this-procedure (substitute("Получаем ответ")).
   mWaitFramTextEnd = "Получаем ответ".
   define variable vWaitProcEvent as logical no-undo.
   vWaitProcEvent = mWaitProcEvent.
   mWaitProcEvent = no.
   run WaitFramRunPause (?).
   define variable vByte as int64 no-undo.
   define variable vNextMese as int64 no-undo init 100000.
   define variable VFlag as logical no-undo init ? .
   mWaitFramStop = no.
   mWaitFramStopTimeOut = no.
   block-wait:
   do while mHSocket:get-bytes-available() > 0:
      VFlag = no.
      define variable vNumByte as integer no-undo.
      vNumByte =   mHSocket:get-bytes-available().
      if vNumByte > 30000 then vNumByte = 30000.
      SET-SIZE(vResponse) = vNumByte + 1.
      SET-BYTE-ORDER(vResponse) = big-endian.
      mHSocket:read(vResponse,1,vNumByte).
      vMessage = vMessage + GET-STRING(vResponse,1).
      if  mReturnHTTp
      then do:
         vCnt = index(vMessage,chr(13) + chr(10) + chr(13) + chr(10)).
         if vCnt > 0
         then do:
            mReturnHttp = no.
            mWebResphead = substring (vMessage,1,vCnt).
            vMessage     = substring (vMessage,vCnt + 4).
            mWebResphead = replace (mWebResphead,";",chr(13) + chr(10)).
            do vi = 1 to num-entries(mWebResphead,chr(13) + chr(10)):
               v-hd-line = trim(entry(vi,mWebResphead,chr(13) + chr(10))).
               if  v-hd-line  begins "Content-Length"  then  do:
                  v-cont-length = INT(trim(substring(v-hd-line,16,length(v-hd-line)))).
               end.
               else if v-hd-line  begins "Transfer-Encoding"
               then do :
                  define variable vChunked as logical no-undo.
                  vchunked = index(v-hd-line,"chunked",19) > 0.
               end.
            end.
         end.
      end.
      vByte = vByte + vNumByte.
      SET-SIZE(vResponse) = 0.
      if v-cont-length > 0 and length (vMessage) >= v-cont-length
      then
         leave block-wait.
      if not mHSocket:get-bytes-available() > 0
      then do:
         VFlag = yes.
         run WaitFramRunPause (?).
         run gbl/pause.p (1000) .
      end.
      else if vByte > vNextMese
      then do:
         vNextMese = vNextMese + 100000.
         mWaitFramTextEnd = substitute ("Получаем ответ прочитано &1 байт ",vByte) .
         run WaitFramRunPause (?).
      end.
      if mWaitFramStopTimeOut
      then do:
         mWebResp = "".
         leave block-wait.
      end.
   end.
   if VFlag ne false
   then
      run writeLogSocet in this-procedure (substitute ("Завершена обработка &1",If VFlag eq  yes then " 0 байт за последнию секунду" else " пустой ответ(((")).
   mWaitFramStop = yes.
   run writeLogSocet         in this-procedure ("Получен ответ").
   run writeLogSocetOnlyText in this-procedure (mWebResphead).
   run writeLogSocetOnlyText in this-procedure (substitute("&1&2&1&2",chr(13) , chr(10) )).
   run writeLogSocetOnlyText in this-procedure (vMessage).
   run writeLogSocetOnlyText in this-procedure (substitute("&1&2",chr(13) , chr(10) )).
   mHSocket:disconnect() no-error.
   if v-cont-length > 0
   then
      mWebResp = substring (vMessage,1,v-cont-length).
   else if vChunked
   then do:
      define variable vByteCopy as int64 no-undo init 1.
      Block-Copy:
      do while length(vMessage) > 0:
         vByteCopy = 1.
         vCnt = index (vMessage,chr(13) + chr(10)) - 1.
         vByteCopy = vByteCopy +  vCnt + 2.
         v-cont-length = hex-to-int(string(substring (vMessage,1,vCnt))).
         if v-cont-length eq 0
         then
            leave Block-copy.
         mWebResp = mWebResp + substring (vMessage,vByteCopy,  v-cont-length).
         vByteCopy = vByteCopy + v-cont-length + 2.
         vMessage = substring  (vMessage,vByteCopy).
      end.
      run writeLogSocet         in this-procedure ("Заголовок").
      run writeLogSocetOnlyText in this-procedure (mWebResphead).
      run writeLogSocet         in this-procedure ("Тело ответа").
      run writeLogSocetOnlyText in this-procedure (mWebResp).
     run writeLogSocetOnlyText in this-procedure (substitute("&1&2",chr(13) , chr(10) )).
   end.
   else
      mWebResp = vMessage.
   mWaitProcEvent = vWaitProcEvent.
   mSocetEndTime = (now - mSocetBegTime) / 1000.
   copy-lob mWebResp to mWebRespMptr.
   if     mWriteRespFile ne ""
      and mWriteRespFile ne ?
   then
        run gbl/fileapnd.p
             ( mWriteRespFile
             , mWebResp + chr(13) + chr(10)
             ,input 10
             ) no-error .
end procedure.
procedure writeLogSocet:
   define input  parameter itext as longchar no-undo.
   if mFileLogSocet eq "Async"
   then
      run PutMesAsunc(itext).
   else if     mFileLogSocet ne ?
           and mFileLogSocet ne ""
   then do:
      run gbl/fileapnd.p
          ( mFileLogSocet
          , substitute("&1 &2 ", string(today), string(time, "HH:MM:SS"))
          ,input 10
          ) no-error .
      run writeLogSocetOnlyText(itext).
      run gbl/fileapnd.p
          ( mFileLogSocet
          , substitute(" &1&2", chr(13) , chr(10))
          ,input 10
          ) no-error .
   end.
end.
procedure writeLogSocetOnlyText:
   define input  parameter itext as longchar no-undo.
   if mFileLogSocet eq "Async"
   then
      run PutMesAsunc(itext).
   else if     mFileLogSocet ne ?
           and mFileLogSocet ne ""
   then do:
      if length(itext) > 32000
      then
         copy-lob
   from object itext
   to file mFileLogSocet append
   no-error
   .
      else
      run gbl/fileapnd.p
          ( mFileLogSocet
          , string(itext)
          ,input 10
          ) no-error .
   end.
end.
procedure Disconect:
   mHSocket:disconnect() no-error.
   delete object mHSocket no-error.
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
define stream str-file.
procedure readfiletxt:
   define input  parameter i_File-Name   as character no-undo.
   define output parameter Otext as longchar no-undo.
   define variable v_string-tmp as character no-undo.
   if searchfile(i_File-Name) eq ?
   then
      return.
   input  stream str-file from  value (i_File-Name)   .
   repeat :
      import stream str-file unformatted v_string-tmp.
      Otext = Otext + v_string-tmp + chr(10).
   end.
   input  stream str-file close.
end procedure.
procedure readrevisetxt:
   define input  parameter i_Str         as Longchar no-undo.
   define input  parameter i_StartString as character no-undo.
   define input  parameter i_comment     as character no-undo.
   define variable v_string-tmp          as character no-undo.
   define variable v-bh                  as handle  no-undo .
   define variable v-fh                  as handle  no-undo .
   define variable vi                    as integer no-undo.
   for each tt-place:
      tt-place.is-error       = yes.
   end.
   rpt:
   do vi = 1 to num-entries(i_Str,chr(10)) :
      v_string-tmp = entry(vi, i_Str,chr(10)).
      if index( v_string-tmp, i_comment ) > 0
      then do:
         v_string-tmp = substring( v_string-tmp, 1, index( v_string-tmp, i_comment ) - 1 ).
      end.
      if v_string-tmp = '':U
      then
         next rpt .
      if index( v_string-tmp, i_StartString ) > 0
      then do:
         find first tt-place where tt-place.loc1 = trim( entry( 2, v_string-tmp, '=' ) ) no-error .
         if not available tt-place
         then do :
           create tt-place .
           assign tt-place.loc1 = trim( entry( 2, v_string-tmp, '=' ) )
                  tt-place.locint   = int(tt-place.loc1)
           no-error .
         end.
         assign
             tt-place.t1             = ?
             tt-place.t2             = ?
             tt-place.t3             = ?
             tt-place.level-total    = ?
             tt-place.level-water    = ?
             tt-place.total-vol      = ?
             tt-place.avrg-temp      = ?
             tt-place.density        = ?
             tt-place.mass           = ?
             tt-place.vapor-density  = ?
             tt-place.vapor-pressure = ?
             tt-place.volume_water   = ?
             tt-place.is-error       = no
             tt-place.error-message  = ?
         .
      end.
      else do:
         if not available tt-place
         then
            next rpt .
         find first tt-param where tt-param.strfrfile = trim( entry( 1, v_string-tmp, '=' ) ) no-error.
         if available tt-param
         then do:
            v-bh = buffer tt-place:handle.
            assign
               v-fh                = v-bh:buffer-field( tt-param.strasi )
               v-fh:buffer-value() = decimal( trim( entry( 2, v_string-tmp, '=' ) ) )
            no-error.
            if (tt-param.flddb = "temperature"
             or tt-param.flddb = "water-qnty")
            and trim( entry( 2, v_string-tmp, '=' ) ) = "-"
            then do :
              assign
                 v-fh:buffer-value() = ?
              no-error.
            end .
         end.
         else do:
            run gbl/fileapnd.p
                  ( 'revis.err'
                  ,
               if trim( entry( 1, v_string-tmp, '=' ) ) = "ERROR"
               then
                  substitute("&1 &2  Ошибка: &3 &4", string(today),string(time, "HH:MM:SS"),  trim( entry( 2, v_string-tmp, '=' ) ), chr(13) + chr(10))
               else
                  substitute("&1 &2  Неизвестный параметр: &3 &4", string(today),string(time, "HH:MM:SS"), trim( entry( 1, v_string-tmp, '=' ) ), chr(13) + chr(10))
               ,input 10
             ) no-error .
         end.
      end.
   end.
   for each tt-place:
      tt-place.vapor-pressure = tt-place.vapor-pressure / 1000.
   end.
end procedure.
procedure get-from-struna :
  define input  parameter i-log-file-name as character no-undo.
  define input  parameter i-obj-code as integer no-undo.
  define variable v-comstring as character no-undo .
  define variable v_File-Name as character no-undo .
  define variable v_command as character no-undo .
  define variable v-comment     as character no-undo.
  define variable v-StartString as character no-undo.
  define variable Vrevis        as longchar no-undo.
  define variable vi as integer no-undo.
if valid-handle( g#lib-rvs ) <> yes then do:       run str/lib-rvs.p persistent no-error.       if error-status :error or valid-handle( g#lib-rvs ) <> yes then do:         message "Error starting lib-rvs.p" skip( 0 )           g#lib-rvs                        skip( 0 )           g#lib-rvs    :type               skip( 0 )           g#lib-rvs    :file-name          skip( 0 )           error-status :get-message( 1 )   skip( 0 )           return-value                     skip( 0 )         view-as alert-box error.         stop.       end.      end.     run lib-rvs_crtt-rvs in g#lib-rvs ( input-output table tt-param ,
                            output       v-comstring ,
                            output       v-comment ,
                            output       v-StartString ) no-error .
    if error-status :error then do:
      return error substitute( 'Ошибка при установке параметров для считывания данных с резервуаров.&1&2&1&3'
                            , chr(10)
                            , error-status :get-message( 1 )
                            , return-value ) .
    end.
   v_File-Name = searchfile('revis.txt').
   if v_File-Name ne ?
   then do:
      block-del-file:
      do vi = 1 to 5:
         os-delete value( v_File-Name ) .
         v_File-Name = searchfile('revis.txt').
         if v_File-Name eq ?
         then
            leave block-del-file.
     end.
   end.
   if v_File-Name ne ?
   then
      return error 'Файл revis.txt заблокирован удалите файл и попробуйте еще раз. ' + v_File-Name .
   if    v-comstring = '':U
      or v-comstring = ?
   then do:
      return error 'Не задан парам. comstr в секции revision ini файла.' .
   end.
   v_File-Name = "wrevis" + string(random(1000000,9999999)) + ".tmp".
   if searchfile(v_File-Name) ne ?
   then do :
      v_File-Name = "wrevis" + string(random(1000000,9999999)) + ".tmp".
      if searchfile(v_File-Name) ne ?
      then do :
        os-delete value(searchfile(v_File-Name)) no-error .
      end.
      if searchfile(v_File-Name) ne ?
      then
        return error "Удалите все файлы wrevis*.tmp".
   end.
   assign
      v_command = substitute( "&1 &2 &3 &4", v-comstring, string(0), v_File-Name, i-obj-code)
   .
   os-command silent value( v_command ) .
   if searchfile(v_File-Name) ne ?
   then
      run readfiletxt (v_File-Name, output Vrevis).
   run gbl/fileapnd.p
          ( i-log-file-name
          ,substitute("&1 &2  Запрос &3&4", string(today),string(time, "HH:MM:SS"), v_command, chr(13) + chr(10))
          ,input 10
          ) no-error .
   if searchfile( v_File-Name ) = ? then do:
      run gbl/fileapnd.p
          ( i-log-file-name
          ,substitute("Файл с прибора не получен. &1",  chr(13) + chr(10))
          ,input 10
          ) no-error .
      return error 'Файл с прибора не получен.' .
  end.
  else do:
      v_File-Name  = searchfile( v_File-Name ) .
  end.
  run gbl/fileapnd.p
          ( i-log-file-name
          ,substitute("&1 &2  Данные &3", string(today),string(time, "HH:MM:SS"), chr(13) + chr(10))
          ,input 10
          ) no-error .
  os-append value(v_File-Name) value(i-log-file-name).
  os-rename value( v_File-Name ) 'revis.txt'.
  os-delete value( v_File-Name ) .
  run gbl/fileapnd.p
          ( i-log-file-name
          , chr(13) + chr(10)
          ,input 10
          ) no-error .
  run readrevisetxt (Vrevis,v-StartString,v-comment).
end procedure .
procedure get-from-ifsf :
   define input  parameter i-log-file-name as character no-undo.
   define input  parameter i-asi-ip        as character no-undo.
   define input  parameter i-asi-port      as character no-undo.
  define variable v_command     as   character     no-undo.
  define variable v-log     as logical no-undo .
  define variable v-bytes   as integer no-undo .
  define variable v-out-data as character no-undo .
  define variable v-line-str as character no-undo .
  define variable ii        as integer no-undo .
  define variable str       as character no-undo .
  define variable str1      as character no-undo .
  define variable str2      as character no-undo .
  define variable hSocket   as handle no-undo .
  define variable mDataIn   as memptr no-undo .
  define variable mDataout  as memptr no-undo .
  define variable cmd       as character no-undo .
  define variable connStr   as character no-undo .
  define variable v-attr-type   as character no-undo.
  define variable v-comstring   as character no-undo.
  define variable v-comment     as character no-undo.
  define variable v-StartString as character no-undo.
  define variable Vrevis        as longchar no-undo.
  define variable vi as integer no-undo.
if valid-handle( g#lib-rvs ) <> yes then do:       run str/lib-rvs.p persistent no-error.       if error-status :error or valid-handle( g#lib-rvs ) <> yes then do:         message "Error starting lib-rvs.p" skip( 0 )           g#lib-rvs                        skip( 0 )           g#lib-rvs    :type               skip( 0 )           g#lib-rvs    :file-name          skip( 0 )           error-status :get-message( 1 )   skip( 0 )           return-value                     skip( 0 )         view-as alert-box error.         stop.       end.      end.     run lib-rvs_crtt-rvs in g#lib-rvs ( input-output table tt-param ,
                            output       v-comstring ,
                            output       v-comment ,
                            output       v-StartString ) no-error .
    if error-status :error then do:
      return error substitute( 'Ошибка при установке параметров для считывания данных с резервуаров.&1&2&1&3'
                            , chr(10)
                            , error-status :get-message( 1 )
                            , return-value ) .
    end.
  cmd = 'KOI8-R 1 0 1' + chr(10) .
  set-size(mDataIn) = 0 .
  set-size(mDataIn) = length(cmd , "RAW":U) + 1 .
  put-string(mDataIn,1) = cmd .
  find first sys-ctrl no-lock.
  if i-asi-ip eq ? or i-asi-ip eq ""
  then
     run db-attr-value(sys-ctrl.db,"AsiIp",output i-asi-ip,output v-attr-type).
  if i-asi-port eq ? or i-asi-port eq ""
  then
     run db-attr-value(sys-ctrl.db,"AsiPort",output i-asi-port,output v-attr-type).
  create socket hSocket .
  connStr = '-H ' + i-asi-ip + ' -S ' + i-asi-port .
  hSocket:connect(connStr) no-error.
  run gbl/fileapnd.p
          ( i-log-file-name
          ,substitute("&1 &2  Запрос  connStr='-H &3  -S &4 '  cmd='KOI8-R 1 0 1'&5", string(today),string(time, "HH:MM:SS"),i-asi-ip,i-asi-port, chr(13) + chr(10))
          ,input 10
          ) no-error .
  if hSocket:connected() = false
  then do :
    run gbl/fileapnd.p
          ( i-log-file-name
          ,substitute("&1 &2 &3 &4", string(today),string(time, "HH:MM:SS"), "Не могу подключиться к IFSF серверу." , chr(13) + chr(10))
          ,input 10
          ) no-error .
    return error "Не могу подключиться к IFSF серверу." .
  end.
  hSocket:set-socket-option('TCP-NODELAY', 'true').
  hSocket:set-socket-option('SO-KEEPALIVE', 'true').
  hSocket:set-socket-option('SO-REUSEADDR', 'true').
  v-log = hSocket:write(mDataIn, 1, get-size(mDataIn)) no-error.
  if v-log = false or error-status:get-message(1) <> ''
  then do:
    hSocket:disconnect() no-error.
    run gbl/fileapnd.p
          ( i-log-file-name
          ,substitute("&1 &2 &3 &4", string(today),string(time, "HH:MM:SS"), "Не могу отправить команду на IFSF сервер.", chr(13) + chr(10))
          ,input 10
          ) no-error .
    return error "Не могу отправить команду на IFSF сервер." .
  end.
  run sleep (1000) .
  set-size(mDataOut) = 0 .
  v-bytes = hSocket:get-bytes-available() .
  set-size(mDataOut) = v-bytes + 1 .
  v-log = hSocket:read(mDataOut, 1, v-bytes, 2) no-error.
  if v-log = false or error-status:get-message(1) <> ''
  then do:
    hSocket:disconnect() no-error.
    run gbl/fileapnd.p
          ( i-log-file-name
          ,substitute("&1 &2 &3 &4", string(today),string(time, "HH:MM:SS"), "Не могу прочитать ответ от IFSF сервера.", chr(13) + chr(10))
          ,input 10
          ) no-error .
    return error "Не могу прочитать ответ от IFSF сервера." .
  end.
  v-out-data = get-string(mDataOut,1) .
  if v-out-data = ""
  then do :
    hSocket:disconnect() no-error.
    run gbl/fileapnd.p
          ( i-log-file-name
          ,substitute("&1 &2 &3 &4", string(today),string(time, "HH:MM:SS"), "Не могу получить данные от IFSF сервера.", chr(13) + chr(10))
          ,input 10
          ) no-error .
    return error "Не могу получить данные от IFSF сервера." .
  end.
  if index(v-out-data, "Bad Request") > 0
  then do :
    hSocket:disconnect() no-error.
    run gbl/fileapnd.p
          ( i-log-file-name
          ,substitute("&1 &2 &3 &4", string(today),string(time, "HH:MM:SS"), "Bad Request", chr(13) + chr(10))
          ,input 10
          ) no-error .
    return error v-out-data .
  end.
  hSocket:disconnect() no-error.
  delete object hSocket.
  set-size(mDataIn) = 0.
  set-size(mDataOut)   = 0.
  run gbl/fileapnd.p
          ( i-log-file-name
          ,substitute("&1 &2  Данные &3", string(today),string(time, "HH:MM:SS"), chr(13) + chr(10))
          ,input 10
          ) no-error .
   run gbl/fileapnd.p
          ( i-log-file-name
          , v-out-data
          ,input 10
          ) no-error .
   run gbl/fileapnd.p
          ( i-log-file-name
          , chr(13) + chr(10)
          ,input 10
          ) no-error .
  output to "revis.ifsf" .
  do vi = 1 to num-entries(v-out-data, chr(10)) :
    put unformatted entry(vi, v-out-data, chr(10)) skip .
  end.
  output close.
  run readrevisetxt (v-out-data,v-StartString,v-comment).
end procedure .
procedure parse-xml :
  define input parameter iStr as longchar .
  define variable hDoc              as handle     no-undo .
  define variable hRoot             as handle     no-undo .
  for each tt-place:
      tt-place.is-error       = yes.
  end.
  CREATE X-DOCUMENT hDoc.
  CREATE X-NODEREF hRoot.
  hDoc:LOAD("longchar",iStr,FALSE).
  hDoc:GET-DOCUMENT-ELEMENT(hRoot).
  RUN GetChildren(hRoot, 1).
  DELETE OBJECT hDoc.
  DELETE OBJECT hRoot.
end procedure .
PROCEDURE GetChildren:
DEFINE INPUT PARAMETER hParent AS HANDLE NO-UNDO.
DEFINE INPUT PARAMETER level AS INTEGER NO-UNDO.
DEFINE VARIABLE i AS INTEGER NO-UNDO.
DEFINE VARIABLE hNoderef AS HANDLE NO-UNDO.
DEFINE VARIABLE hText    AS HANDLE NO-UNDO.
define variable client   as character no-undo.
define variable good                as logical   no-undo .
define variable v-asi-error-code    as integer   no-undo initial 0 .
define variable v-asi-error-message as character no-undo .
CREATE X-NODEREF hNoderef.
CREATE X-NODEREF hText .
REPEAT i = 1 TO hParent:NUM-CHILDREN:
    good = hParent:GET-CHILD(hNoderef,i).
    IF NOT good THEN
        LEAVE.
    IF hNoderef:SUBTYPE <> "element" THEN
        NEXT.
    hNoderef:GET-CHILD(hText, 1) no-error .
    IF hNoderef:NAME = "ErrNum"
    then do :
      v-asi-error-code = integer(hText:node-value) no-error .
    end .
    IF hNoderef:NAME = "ErrMsg"
    then do :
      v-asi-error-message = hText:node-value no-error .
      if     v-asi-error-code > 0
         and v-asi-error-code ne 2
      then do :
        assign
          tt-place.t1             = ?
          tt-place.t2             = ?
          tt-place.t3             = ?
          tt-place.level-total    = ?
          tt-place.level-water    = ?
          tt-place.total-vol      = ?
          tt-place.avrg-temp      = ?
          tt-place.density        = ?
          tt-place.mass           = ?
          tt-place.vapor-density  = ?
          tt-place.vapor-pressure = ?
          tt-place.volume_water   = ?
          tt-place.is-error       = true
          tt-place.error-message  = v-asi-error-message
        .
      end .
    end .
    IF hNoderef:NAME = "Tank"
    then do :
      find first tt-place where tt-place.loc1 = hText:node-value no-error .
      if not available tt-place
      then do :
        create tt-place .
        assign tt-place.loc1     = hText:node-value
               tt-place.locint   = int(tt-place.loc1)
        no-error .
      end.
      assign
          v-asi-error-code        = 0
          tt-place.t1             = ?
          tt-place.t2             = ?
          tt-place.t3             = ?
          tt-place.level-total    = ?
          tt-place.level-water    = ?
          tt-place.total-vol      = ?
          tt-place.avrg-temp      = ?
          tt-place.density        = ?
          tt-place.mass           = ?
          tt-place.vapor-density  = ?
          tt-place.vapor-pressure = ?
          tt-place.volume_water   = ?
          tt-place.is-error       = no
          tt-place.error-message  = ?
      .
    end.
    if    v-asi-error-code = 0
       or v-asi-error-code = 2
    then do :
      IF hNoderef:NAME = "LevelTotal" then assign tt-place.level-total = decimal(hText:node-value) / 10 no-error .
      IF hNoderef:NAME = "LevelWater" then assign tt-place.level-water = decimal(hText:node-value) / 10 no-error .
      IF hNoderef:NAME = "Temperature" then assign tt-place.avrg-temp = decimal(hText:node-value) no-error .
      IF hNoderef:NAME = "Density" then assign tt-place.density = decimal(hText:node-value) no-error .
      IF hNoderef:NAME = "VolumeTotal" then assign tt-place.total-vol = decimal(hText:node-value) no-error .
      IF hNoderef:NAME = "MassTotal" then assign tt-place.mass = decimal(hText:node-value) no-error .
      IF hNoderef:NAME = "VaporDensity" then assign tt-place.vapor-density = decimal(hText:node-value) no-error .
      IF hNoderef:NAME = "VaporPressure" then assign tt-place.vapor-pressure = decimal(hText:node-value) / 1000 no-error .
      IF hNoderef:NAME = "Temperature1" then assign tt-place.t1 = decimal(hText:node-value) no-error .
      IF hNoderef:NAME = "Temperature2" then assign tt-place.t2 = decimal(hText:node-value) no-error .
      IF hNoderef:NAME = "Temperature3" then assign tt-place.t3 = decimal(hText:node-value) no-error .
    end .
    RUN GetChildren(hNoderef, (level + 1)).
END.
DELETE OBJECT hNoderef.
DELETE OBJECT hText.
END PROCEDURE.
define variable v-parsesub        as character  no-undo .
define variable curl-path         as character  no-undo .
define variable v-command         as character  no-undo .
define variable v-addr            as character  no-undo .
define variable v-log-file-name   as character  no-undo .
define variable v-asi-ip  as character no-undo .
define variable v-asi-port as character no-undo .
define variable v-attr-type as character no-undo .
define variable v-asi-error-code as integer no-undo initial 0 .
define variable v-asi-error-message as character no-undo .
define variable old-BM as logical no-undo .
v-log-file-name = substitute('&1rvs.log', ibs.th.gbl.gbl-inipar:logDir) .
if p-loclist = '0':U then p-loclist = "all" .
find first sys-ctrl no-lock.
run db-attr-value(sys-ctrl.db,"AsiIp",output v-asi-ip,output v-attr-type).
run db-attr-value(sys-ctrl.db,"AsiPort",output v-asi-port,output v-attr-type).
mFileLogSocet = v-log-file-name.
def var objSrv as class ibs.th.gbl.sys.objsrv no-undo.
run gbl/getobjsrvhndl.p (input-output ObjSrv).
if     objSrv:SystemSetting:asifile ne ?
     and objSrv:SystemSetting:asifile ne ""
     and search(objSrv:SystemSetting:asifile) ne ?
then do:
   copy-lob from file search(objSrv:SystemSetting:asifile) to mWebResp no-convert no-error.
   output to value (  v-log-file-name  ) append .
   put unformatted string(today) ' ' string(time, "HH:MM:SS") " Прочитан файл  " skip .
   output close .
end.
else do:
   old-BM = mBatchMode .
   if p-no-waitfram
   then do :
     mBatchMode = yes .
   end .
   run ConectSocet (v-asi-ip,
                    v-asi-port,
                    ("getmeas/?loclist=" + p-loclist),
                    "",
                    "xml",
                    180,
                    no,
                    "Получение данных от АСИ. ").
   mBatchMode = old-BM .
end.
empty temp-table tt-place .
if length(mWebResp) >0
then do:
   output to value (  v-log-file-name  ) append .
   put unformatted string(today) ' ' string(time, "HH:MM:SS") " Разбираем полученные данныи  " skip .
   output close .
   copy-lob from mWebResp to file v-log-file-name append no-convert no-error.
   output to value (  v-log-file-name  ) append .
   put unformatted skip .
   output close .
   run parse-xml (input mWebResp) .
end.
else do:
   output to value (  v-log-file-name  ) append .
   put unformatted string(today) ' ' string(time, "HH:MM:SS") "  Неудалось получить ответ  " skip .
   output close .
end.
