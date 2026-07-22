block-level on error undo, throw.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
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
define new global shared variable g#libofarh as handle no-undo .
define new global shared variable g#lib-farh as handle no-undo .
define input parameter parhost-code like ub.sysconf.host-code no-undo.
define input parameter parrecalc-fo as   logical              no-undo.
define input parameter parlist-arh  as   character            no-undo.
on delete of arh-fin-doc-an                override do: end.
on delete of arh-fin-doc-an-nal            override do: end.
on delete of arh-fin-doc-an-nal-obj        override do: end.
on delete of arh-fin-doc-an-obj            override do: end.
on delete of arh-fin-doc-c-s-tax-nal-obj   override do: end.
on delete of arh-fin-doc-c-schet-tax-nal   override do: end.
on delete of arh-fin-doc-contr-s-nal-obj   override do: end.
on delete of arh-fin-doc-contr-s-tax-obj   override do: end.
on delete of arh-fin-doc-contr-schet       override do: end.
on delete of arh-fin-doc-contr-schet-nal   override do: end.
on delete of arh-fin-doc-contr-schet-obj   override do: end.
on delete of arh-fin-doc-contr-schet-tax   override do: end.
on delete of arh-fin-doc-s-tax-nal-obj     override do: end.
on delete of arh-fin-doc-schet             override do: end.
on delete of arh-fin-doc-schet-nal         override do: end.
on delete of arh-fin-doc-schet-nal-obj     override do: end.
on delete of arh-fin-doc-schet-obj         override do: end.
on delete of arh-fin-doc-schet-tax         override do: end.
on delete of arh-fin-doc-schet-tax-nal     override do: end.
on delete of arh-fin-doc-schet-tax-obj     override do: end.
on delete of arh-fin-ob-contr              override do: end.
on delete of arh-fin-ob-contr-obj          override do: end.
on write  of arh-fin-doc-an                override do: end.
on write  of arh-fin-doc-an-nal            override do: end.
on write  of arh-fin-doc-an-nal-obj        override do: end.
on write  of arh-fin-doc-an-obj            override do: end.
on write  of arh-fin-doc-c-s-tax-nal-obj   override do: end.
on write  of arh-fin-doc-c-schet-tax-nal   override do: end.
on write  of arh-fin-doc-contr-s-nal-obj   override do: end.
on write  of arh-fin-doc-contr-s-tax-obj   override do: end.
on write  of arh-fin-doc-contr-schet       override do: end.
on write  of arh-fin-doc-contr-schet-nal   override do: end.
on write  of arh-fin-doc-contr-schet-obj   override do: end.
on write  of arh-fin-doc-contr-schet-tax   override do: end.
on write  of arh-fin-doc-s-tax-nal-obj     override do: end.
on write  of arh-fin-doc-schet             override do: end.
on write  of arh-fin-doc-schet-nal         override do: end.
on write  of arh-fin-doc-schet-nal-obj     override do: end.
on write  of arh-fin-doc-schet-obj         override do: end.
on write  of arh-fin-doc-schet-tax         override do: end.
on write  of arh-fin-doc-schet-tax-nal     override do: end.
on write  of arh-fin-doc-schet-tax-obj     override do: end.
on write  of arh-fin-ob-contr              override do: end.
on write  of arh-fin-ob-contr-obj          override do: end.
if parlist-arh = "" then parlist-arh = "all" .
run del-for-one-firm  (input parhost-code, input parlist-arh) no-error.
if error-status:error then do:
  message return-value error-status:get-message(1) error-status:get-message(2) view-as alert-box error.
  return error.
end.
run calc-for-one-firm (input parhost-code, input parlist-arh) no-error.
if error-status:error then do:
  message return-value error-status:get-message(1) error-status:get-message(2) view-as alert-box error.
  return error.
end.
procedure calc-for-one-firm :
define input parameter parhost-code like ub.sysconf.host-code no-undo.
define input parameter parlist-arh  as   character            no-undo.
define buffer bf_fin-ob  for ub.fin-ob.
define buffer bf_fin-doc for ub.fin-doc.
define variable p-var as logical   no-undo .
do on error undo, return error return-value :
  if parrecalc-fo then do:
    run waitfram-show in this-procedure (substitute ("Расчитываем финансовые архивы финобязательств по фирме &1", parhost-code)).
    for each bf_fin-ob where bf_fin-ob.host-code = parhost-code and
                             bf_fin-ob.status_   = 'факт':U      by bf_fin-ob.host-code by bf_fin-ob.status_ by bf_fin-ob.fact-order on error undo, return error return-value :
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libofarh) <> true) then do:   run str/libofarh.p persistent no-error .   if error-status :error or (valid-handle(g#libofarh) <> true) then do:     message       "Error starting libofarh.p" skip       g#libofarh skip       g#libofarh :type skip       g#libofarh :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libofarh_taskclco in g#libofarh
(input parhost-code
,input bf_fin-ob.doc-code
,input 'Полный пересчет архивов':u
,input 'close':u
,input no
,output p-var
) no-error
.
      if error-status:error then do:
        undo, return error substitute("Ошибка при пересчете архивов по ФО фирма &1 док-т &2:&3&4&3&5"
                                       , bf_fin-ob.host-code
                                       , bf_fin-ob.doc-code
                                       , chr(10)
                                       , error-status:get-message(1)
                                       , return-value ).
      end.
    end.
  end.
  run waitfram-show in this-procedure (substitute ("Расчитываем финансовые архивы финдокументов по фирме &1", parhost-code)).
  for each bf_fin-doc where bf_fin-doc.host-code = parhost-code and
                            bf_fin-doc.status_   = 'факт':U      by bf_fin-doc.host-code by bf_fin-doc.status_ by bf_fin-doc.fact-order on error undo, return error return-value :
if (valid-handle(g#lib-farh) <> true) then do:   run str/lib-farh.p persistent no-error .   if error-status :error or (valid-handle(g#lib-farh) <> true) then do:     message       "Error starting lib-farh.p" skip       g#lib-farh skip       g#lib-farh :type skip       g#lib-farh :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-farh_taskclcd in g#lib-farh
(input parhost-code
,input bf_fin-doc.fin-doc-code
,input parlist-arh
,input 'Полный пересчет архивов':u
,input 'recalc':u
) no-error
.
      if error-status:error then do:
        undo, return error substitute("Ошибка при пересчете архиво по финдок-там фирма &1 вн.№ &2:&3&4&3&5"
                                       , bf_fin-doc.host-code
                                       , bf_fin-doc.fin-doc-code
                                       , chr(10)
                                       , error-status:get-message(1)
                                       , return-value ).
      end.
  end.
end.
end procedure.
procedure del-for-one-firm :
define input parameter parhost-code like ub.sysconf.host-code no-undo.
define input parameter parlist-arh  as   character            no-undo.
define buffer bf_arh-fin-doc-an              for ub.arh-fin-doc-an             .
define buffer bf_arh-fin-doc-an-nal          for ub.arh-fin-doc-an-nal         .
define buffer bf_arh-fin-doc-an-nal-obj      for ub.arh-fin-doc-an-nal-obj     .
define buffer bf_arh-fin-doc-an-obj          for ub.arh-fin-doc-an-obj         .
define buffer bf_arh-fin-doc-c-s-tax-nal-obj for ub.arh-fin-doc-c-s-tax-nal-obj.
define buffer bf_arh-fin-doc-c-schet-tax-nal for ub.arh-fin-doc-c-schet-tax-nal.
define buffer bf_arh-fin-doc-contr-s-nal-obj for ub.arh-fin-doc-contr-s-nal-obj.
define buffer bf_arh-fin-doc-contr-s-tax-obj for ub.arh-fin-doc-contr-s-tax-obj.
define buffer bf_arh-fin-doc-contr-schet     for ub.arh-fin-doc-contr-schet    .
define buffer bf_arh-fin-doc-contr-schet-nal for ub.arh-fin-doc-contr-schet-nal.
define buffer bf_arh-fin-doc-contr-schet-obj for ub.arh-fin-doc-contr-schet-obj.
define buffer bf_arh-fin-doc-contr-schet-tax for ub.arh-fin-doc-contr-schet-tax.
define buffer bf_arh-fin-doc-s-tax-nal-obj   for ub.arh-fin-doc-s-tax-nal-obj  .
define buffer bf_arh-fin-doc-schet           for ub.arh-fin-doc-schet          .
define buffer bf_arh-fin-doc-schet-nal       for ub.arh-fin-doc-schet-nal      .
define buffer bf_arh-fin-doc-schet-nal-obj   for ub.arh-fin-doc-schet-nal-obj  .
define buffer bf_arh-fin-doc-schet-obj       for ub.arh-fin-doc-schet-obj      .
define buffer bf_arh-fin-doc-schet-tax       for ub.arh-fin-doc-schet-tax      .
define buffer bf_arh-fin-doc-schet-tax-nal   for ub.arh-fin-doc-schet-tax-nal  .
define buffer bf_arh-fin-doc-schet-tax-obj   for ub.arh-fin-doc-schet-tax-obj  .
define buffer bf_arh-fin-ob-contr            for ub.arh-fin-ob-contr           .
define buffer bf_arh-fin-ob-contr-obj        for ub.arh-fin-ob-contr-obj       .
do on error undo, return error return-value :
run waitfram-show in this-procedure (substitute ("Удаляем финансовые архивы по фирме &1", parhost-code)).
if parlist-arh = "all":u or lookup ('arh-fin-doc-an':U,              parlist-arh) > 0 then do: for each bf_arh-fin-doc-an              where bf_arh-fin-doc-an             .host-code = parhost-code on error undo, return error return-value : delete bf_arh-fin-doc-an             . end. end.
if parlist-arh = "all":u or lookup ('arh-fin-doc-an-nal':U,          parlist-arh) > 0 then do: for each bf_arh-fin-doc-an-nal          where bf_arh-fin-doc-an-nal         .host-code = parhost-code on error undo, return error return-value : delete bf_arh-fin-doc-an-nal         . end. end.
if parlist-arh = "all":u or lookup ('arh-fin-doc-an-nal-obj':U,      parlist-arh) > 0 then do: for each bf_arh-fin-doc-an-nal-obj      where bf_arh-fin-doc-an-nal-obj     .host-code = parhost-code on error undo, return error return-value : delete bf_arh-fin-doc-an-nal-obj     . end. end.
if parlist-arh = "all":u or lookup ('arh-fin-doc-an-obj':U,          parlist-arh) > 0 then do: for each bf_arh-fin-doc-an-obj          where bf_arh-fin-doc-an-obj         .host-code = parhost-code on error undo, return error return-value : delete bf_arh-fin-doc-an-obj         . end. end.
if parlist-arh = "all":u or lookup ('arh-fin-doc-c-s-tax-nal-obj':U, parlist-arh) > 0 then do: for each bf_arh-fin-doc-c-s-tax-nal-obj where bf_arh-fin-doc-c-s-tax-nal-obj.host-code = parhost-code on error undo, return error return-value : delete bf_arh-fin-doc-c-s-tax-nal-obj. end. end.
if parlist-arh = "all":u or lookup ('arh-fin-doc-c-schet-tax-nal':U, parlist-arh) > 0 then do: for each bf_arh-fin-doc-c-schet-tax-nal where bf_arh-fin-doc-c-schet-tax-nal.host-code = parhost-code on error undo, return error return-value : delete bf_arh-fin-doc-c-schet-tax-nal. end. end.
if parlist-arh = "all":u or lookup ('arh-fin-doc-contr-s-nal-obj':U, parlist-arh) > 0 then do: for each bf_arh-fin-doc-contr-s-nal-obj where bf_arh-fin-doc-contr-s-nal-obj.host-code = parhost-code on error undo, return error return-value : delete bf_arh-fin-doc-contr-s-nal-obj. end. end.
if parlist-arh = "all":u or lookup ('arh-fin-doc-contr-s-tax-obj':U, parlist-arh) > 0 then do: for each bf_arh-fin-doc-contr-s-tax-obj where bf_arh-fin-doc-contr-s-tax-obj.host-code = parhost-code on error undo, return error return-value : delete bf_arh-fin-doc-contr-s-tax-obj. end. end.
if parlist-arh = "all":u or lookup ('arh-fin-doc-contr-schet':U,     parlist-arh) > 0 then do: for each bf_arh-fin-doc-contr-schet     where bf_arh-fin-doc-contr-schet    .host-code = parhost-code on error undo, return error return-value : delete bf_arh-fin-doc-contr-schet    . end. end.
if parlist-arh = "all":u or lookup ('arh-fin-doc-contr-schet-nal':U, parlist-arh) > 0 then do: for each bf_arh-fin-doc-contr-schet-nal where bf_arh-fin-doc-contr-schet-nal.host-code = parhost-code on error undo, return error return-value : delete bf_arh-fin-doc-contr-schet-nal. end. end.
if parlist-arh = "all":u or lookup ('arh-fin-doc-contr-schet-obj':U, parlist-arh) > 0 then do: for each bf_arh-fin-doc-contr-schet-obj where bf_arh-fin-doc-contr-schet-obj.host-code = parhost-code on error undo, return error return-value : delete bf_arh-fin-doc-contr-schet-obj. end. end.
if parlist-arh = "all":u or lookup ('arh-fin-doc-contr-schet-tax':U, parlist-arh) > 0 then do: for each bf_arh-fin-doc-contr-schet-tax where bf_arh-fin-doc-contr-schet-tax.host-code = parhost-code on error undo, return error return-value : delete bf_arh-fin-doc-contr-schet-tax. end. end.
if parlist-arh = "all":u or lookup ('arh-fin-doc-s-tax-nal-obj':U,   parlist-arh) > 0 then do: for each bf_arh-fin-doc-s-tax-nal-obj   where bf_arh-fin-doc-s-tax-nal-obj  .host-code = parhost-code on error undo, return error return-value : delete bf_arh-fin-doc-s-tax-nal-obj  . end. end.
if parlist-arh = "all":u or lookup ('arh-fin-doc-schet':U,           parlist-arh) > 0 then do: for each bf_arh-fin-doc-schet           where bf_arh-fin-doc-schet          .host-code = parhost-code on error undo, return error return-value : delete bf_arh-fin-doc-schet          . end. end.
if parlist-arh = "all":u or lookup ('arh-fin-doc-schet-nal':U,       parlist-arh) > 0 then do: for each bf_arh-fin-doc-schet-nal       where bf_arh-fin-doc-schet-nal      .host-code = parhost-code on error undo, return error return-value : delete bf_arh-fin-doc-schet-nal      . end. end.
if parlist-arh = "all":u or lookup ('arh-fin-doc-schet-nal-obj':U,   parlist-arh) > 0 then do: for each bf_arh-fin-doc-schet-nal-obj   where bf_arh-fin-doc-schet-nal-obj  .host-code = parhost-code on error undo, return error return-value : delete bf_arh-fin-doc-schet-nal-obj  . end. end.
if parlist-arh = "all":u or lookup ('arh-fin-doc-schet-obj':U,       parlist-arh) > 0 then do: for each bf_arh-fin-doc-schet-obj       where bf_arh-fin-doc-schet-obj      .host-code = parhost-code on error undo, return error return-value : delete bf_arh-fin-doc-schet-obj      . end. end.
if parlist-arh = "all":u or lookup ('arh-fin-doc-schet-tax':U,       parlist-arh) > 0 then do: for each bf_arh-fin-doc-schet-tax       where bf_arh-fin-doc-schet-tax      .host-code = parhost-code on error undo, return error return-value : delete bf_arh-fin-doc-schet-tax      . end. end.
if parlist-arh = "all":u or lookup ('arh-fin-doc-schet-tax-nal':U,   parlist-arh) > 0 then do: for each bf_arh-fin-doc-schet-tax-nal   where bf_arh-fin-doc-schet-tax-nal  .host-code = parhost-code on error undo, return error return-value : delete bf_arh-fin-doc-schet-tax-nal  . end. end.
if parlist-arh = "all":u or lookup ('arh-fin-doc-schet-tax-obj':U,   parlist-arh) > 0 then do: for each bf_arh-fin-doc-schet-tax-obj   where bf_arh-fin-doc-schet-tax-obj  .host-code = parhost-code on error undo, return error return-value : delete bf_arh-fin-doc-schet-tax-obj  . end. end.
if parrecalc-fo then do:
  for each bf_arh-fin-ob-contr            where bf_arh-fin-ob-contr           .host-code = parhost-code on error undo, return error return-value : delete bf_arh-fin-ob-contr           . end.
  for each bf_arh-fin-ob-contr-obj        where bf_arh-fin-ob-contr-obj       .host-code = parhost-code on error undo, return error return-value : delete bf_arh-fin-ob-contr-obj       . end.
end.
end.
end procedure.
