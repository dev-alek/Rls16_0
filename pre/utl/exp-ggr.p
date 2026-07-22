block-level on error undo, throw.
define variable p-install as logical   no-undo init false .
define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: exp-ggr.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: utl/exp-ggr.p $":U .
define variable vss-description as character no-undo initial "Экспорт групп товаров".
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
define variable vss-include-info1 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define temp-table temp_grplib_grp no-undo
    field sel           as character
    field nabor         as character
    field full-name     as character
    field print-code    as character
    field sort-name     as character
    field node-code     as integer
    field upper-code    as integer
    field calc-method   as character
    field round-method  as character
    field increase-pc   as decimal
    field min-marg      as character
    field max-marg      as character
    field cli-type      as character
    field cli-code      as integer
    field notcorr      as character
    field name          as character
    field level         as integer
    field mark          as character
    index pi is primary unique sort-name
    index fn full-name
    index nc is unique node-code
    index sl sel
    index uc upper-code
.
define temp-table temp_grplib_found-grp no-undo
    field full-name   as character
    field sort-name   as character
    field node-code   as integer
    field level       as integer
    field is-terminal as logical
    index pi is primary unique sort-name
    index fn full-name
    index lv level
    index it is-terminal
.
define temp-table temp_found-result-nodelist no-undo
    field node-code     as recid
    field processed     as logical
    field sort-name     as character
    field full-name     as character
    index pi is primary unique node-code
    index ps processed
.
define variable v-grplib-not-fill-extra-info        as logical      no-undo.
define variable v-grplib-no-warning-grp-amount      as logical      no-undo.
define variable v-grplib-grp-amount-for-load        as integer      no-undo.
procedure grplib-get-parameters :
define input parameter p-store-type     as character        no-undo.
define input parameter p-store-code     as integer          no-undo.
do
on error undo, return error
:
    assign
        v-grplib-not-fill-extra-info = no
    .
end.
end procedure.
procedure grplib-get-sort-name :
do
on error undo, return error
:
define input parameter p-node-code  as integer      no-undo.
define output parameter p-sort-name as character    no-undo.
    define variable v-upper-code    as integer           no-undo.
    define buffer buf_gds-grp       for ub.gds-grp.
    define buffer buf_upper_gds-grp for ub.gds-grp.
    find first buf_gds-grp no-lock
         where buf_gds-grp.node-code = p-node-code
    no-error.
    if not available buf_gds-grp
    then do:
        undo, return error "grplib-get-sort-name: Не найдена группа товаров с кодом " + string( p-node-code ).
    end.
    assign
        p-sort-name  = ""
        v-upper-code = 1
    .
    do while buf_gds-grp.upper-code <> 0
    on error undo, return error "grplib-get-sort-name: Ошибка составления полного имени группы"
    :
        assign
            p-sort-name  = buf_gds-grp.node-name
                         + (if p-sort-name <> "" then chr(2) else "")
                         + p-sort-name
            v-upper-code = buf_gds-grp.upper-code
        .
        find first buf_gds-grp no-lock
             where buf_gds-grp.node-code = v-upper-code
        no-error.
        if not available buf_gds-grp
        then do:
            undo, return error "grplib-get-sort-name: Не найдена группа товаров с кодом "
                                + string( v-upper-code )
                                + ". Ошибка ссылки в дереве товаров для узла p-node-code".
        end.
    end.
end.
end procedure.
define variable vss-include-info2 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
procedure grplib-get-full-name :
   define input parameter p-node-code  as integer      no-undo.
   define output parameter p-full-name as character    no-undo.
   do
on error undo, return error
:
    define variable v-upper-code    as integer           no-undo.
    define buffer buf_gds-grp       for ub.gds-grp.
    define buffer buf_upper_gds-grp for ub.gds-grp.
    find first buf_gds-grp no-lock
         where buf_gds-grp.node-code = p-node-code
    no-error.
    if not available buf_gds-grp
    then do:
        undo, return error "grplib-get-full-name: Не найдена группа товаров с кодом " + string( p-node-code ).
    end.
    assign
        p-full-name  = ""
        v-upper-code = 1
    .
    do while buf_gds-grp.upper-code <> 0
    on error undo, return error "grplib-get-full-name: Ошибка составления полного имени группы"
    :
        assign
            p-full-name  = buf_gds-grp.node-name
                         + (if p-full-name <> "" then chr(47) else "")
                         + p-full-name
            v-upper-code = buf_gds-grp.upper-code
        .
        find first buf_gds-grp no-lock
             where buf_gds-grp.node-code = v-upper-code
        no-error.
        if not available buf_gds-grp
        then do:
            undo, return error "grplib-get-full-name: Не найдена группа товаров с кодом "
                                + string( v-upper-code )
                                + ". Ошибка ссылки в дереве товаров для узла p-node-code".
        end.
    end.
    assign
    p-full-name = p-full-name + (if p-full-name = "":U then "":U else chr(47))
    .
end.
end .
procedure grplib-get-node-from-full-name :
define input parameter p-full-name as character no-undo .
define output parameter p-node-code as integer no-undo .
define variable v-ii as integer no-undo .
define variable v-upper-code as integer no-undo .
define variable v-root-code as integer no-undo .
define variable v-entry as character no-undo .
define buffer buf_gds-grp       for ub.gds-grp.
do
on error undo, return error
:
  find first buf_gds-grp no-lock
      where buf_gds-grp.upper-code = 0
  no-error .
  if not available buf_gds-grp
  then do:
      undo, return error substitute("Не найдена корневая группа товаров (upper-code = 0)").
  end.
  else do:
    assign
    v-root-code = buf_gds-grp.node-code
    .
  end.
  v-upper-code = v-root-code.
  do v-ii = 1 to num-entries(p-full-name, chr(47)):
    assign
    v-entry = entry(v-ii, p-full-name, chr(47)).
    if v-entry = '' then leave.
    find first buf_gds-grp no-lock where
              buf_gds-grp.node-name = v-entry
          and buf_gds-grp.upper-code = v-upper-code
          no-error.
    if not available buf_gds-grp then do:
      undo, return error substitute("Не найдена подгруппа &1 в группе с вн. кодом &2", v-entry, v-upper-code).
    end.
    else do:
      p-node-code = buf_gds-grp.node-code.
      v-upper-code = buf_gds-grp.node-code.
    end.
  end.
end.
end .
procedure grplib-get-root-code :
do
on error undo, return error
:
define output parameter p-root-code as integer      no-undo.
    define buffer buf_gds-grp       for ub.gds-grp.
    find first buf_gds-grp no-lock
        where buf_gds-grp.upper-code = 0
    no-error .
    if not available buf_gds-grp
    then do:
        undo, return error .
    end.
    else do:
        assign
            p-root-code = buf_gds-grp.node-code
        .
    end.
end.
end procedure.
procedure grplib-find-grp-by-full-name :
do
on error undo, return error
:
define input parameter p-search-name  as character    no-undo.
define input parameter p-fill-path    as logical      no-undo.
define output parameter p-found       as logical      no-undo.
    define variable v-upper-code    as integer          no-undo.
    define variable v-counter       as integer           no-undo.
    define variable v-level         as integer           no-undo.
    define variable v-full-name     as character         no-undo.
    define variable v-sort-name     as character         no-undo.
    define buffer buf_gds-grp       for ub.gds-grp.
    assign
        p-search-name = replace( p-search-name, chr(47), chr(2) )
    .
    run grplib-get-root-code ( output v-upper-code ) no-error .
    if error-status :error
    then do:
        undo, return error "grplib-expand-name: Ошибка при поиске корневого узла".
    end.
    assign
        v-full-name  = ""
        v-level      = num-entries( p-search-name, chr(2) )
    .
    for each temp_grplib_found-grp
    :
        delete temp_grplib_found-grp.
    end.
    start-name-analyze:
    do v-counter = 1 to v-level
    :
        if v-counter < v-level
        then do:
            find first buf_gds-grp no-lock
                 where buf_gds-grp.upper-code = v-upper-code
                   and buf_gds-grp.node-name  = entry( v-counter, p-search-name, chr(2) )
            no-error .
            if not available buf_gds-grp
            then do:
                assign
                    v-full-name  = p-search-name
                    v-sort-name  = p-search-name
                .
                return error "grplib-expand-name: не найдена группа " + entry( v-level, p-search-name, chr(2) ).
            end.
            else do:
                assign
                    v-full-name = v-full-name + ( if v-full-name = "" then "" else chr(47) )        + buf_gds-grp.node-name
                    v-sort-name = v-sort-name + ( if v-sort-name = "" then "" else chr(2) ) + buf_gds-grp.node-name
                    v-upper-code = buf_gds-grp.node-code
                .
                if p-fill-path = yes
                then do:
                    create temp_grplib_found-grp.
                    assign
                        temp_grplib_found-grp.full-name = v-full-name + chr(47)
                        temp_grplib_found-grp.sort-name = v-sort-name
                        temp_grplib_found-grp.node-code = v-upper-code
                        temp_grplib_found-grp.level     = v-counter
                    .
                end.
            end.
        end.
        else do:
            for each buf_gds-grp no-lock
               where buf_gds-grp.upper-code = v-upper-code
                 and buf_gds-grp.node-name begins entry( v-counter, p-search-name, chr(2) )
            :
                assign
                    p-found = yes
                .
                create temp_grplib_found-grp.
                assign
                    temp_grplib_found-grp.full-name = v-full-name
                                                        + (if v-full-name = "" then "" else chr(47) )
                                                        + buf_gds-grp.node-name + chr(47)
                    temp_grplib_found-grp.sort-name = v-sort-name
                                                        + ( if v-sort-name = "" then "" else chr(2) )
                                                        + buf_gds-grp.node-name
                    temp_grplib_found-grp.node-code = buf_gds-grp.node-code
                    temp_grplib_found-grp.level     = v-level
                .
            end.
            if p-found = no
            then do:
                assign
                    v-full-name  = p-search-name
                    v-sort-name  = p-search-name
                .
                for each temp_grplib_found-grp
                :
                    delete temp_grplib_found-grp.
                end.
                assign
                    p-found = no
                .
            end.
        end.
    end.
end.
end procedure.
procedure grplib-find-all-subgroup :
do
on error undo, return error
:
define input parameter p-start-node-code    as integer      no-undo.
define input parameter p-terminal-only      as logical      no-undo.
    define variable v-start-full-name   as character     no-undo.
    define variable v-start-sort-name   as character     no-undo.
    define variable v-not-found         as logical       no-undo.
    define variable v-is-terminal       as logical       no-undo.
    define buffer buf_gds-grp           for ub.gds-grp.
    create temp_found-result-nodelist.
    assign
        temp_found-result-nodelist.node-code = p-start-node-code
        temp_found-result-nodelist.processed = no
    .
    run grplib-get-full-name in this-procedure (
          input p-start-node-code
        , output v-start-full-name
    ).
    run grplib-get-full-name in this-procedure (
          input p-start-node-code
        , output v-start-sort-name
    ).
    process-nodes:
    do while yes
    :
        find first temp_found-result-nodelist
             where temp_found-result-nodelist.node-code = p-start-node-code
        .
        assign
            temp_found-result-nodelist.processed = yes
        .
        for each buf_gds-grp no-lock
           where buf_gds-grp.upper-code = p-start-node-code
        on error undo, return error
        :
            run grplib-is-terminal in this-procedure (
                  input buf_gds-grp.node-code
                , output v-is-terminal
            ).
            if v-is-terminal = yes
            then do:
                create temp_grplib_found-grp.
                assign
                    temp_grplib_found-grp.full-name   = right-trim(v-start-full-name, chr(47)) +
                                                        chr(47) + buf_gds-grp.node-name + chr(47)
                    temp_grplib_found-grp.sort-name   = right-trim(v-start-sort-name, chr(2)) +
                                                        chr(2) + buf_gds-grp.node-name + chr(2)
                    temp_grplib_found-grp.node-code   = buf_gds-grp.node-code
                    temp_grplib_found-grp.is-terminal = yes
                .
            end.
            else do:
                create temp_found-result-nodelist.
                assign
                    temp_found-result-nodelist.node-code = buf_gds-grp.node-code
                    temp_found-result-nodelist.full-name = right-trim(v-start-full-name, chr(47)) +
                                                           chr(47) + buf_gds-grp.node-name + chr(47)
                    temp_found-result-nodelist.sort-name = right-trim(v-start-sort-name, chr(2)) +
                                                           chr(2) + buf_gds-grp.node-name + chr(2)
                    temp_found-result-nodelist.processed = no
                .
                if p-terminal-only = no
                then do:
                    create temp_grplib_found-grp.
                    assign
                        temp_grplib_found-grp.full-name   = right-trim(v-start-full-name, chr(47)) +
                                                            chr(47) + buf_gds-grp.node-name + chr(47)
                        temp_grplib_found-grp.sort-name   = right-trim(v-start-sort-name, chr(2)) +
                                                            chr(2) + buf_gds-grp.node-name + chr(2)
                        temp_grplib_found-grp.node-code   = buf_gds-grp.node-code
                        temp_grplib_found-grp.is-terminal = no
                    .
                end.
            end.
        end.
        find first temp_found-result-nodelist
             where temp_found-result-nodelist.processed = no
        no-error.
        if not available temp_found-result-nodelist
        then do:
            leave process-nodes.
        end.
        else do:
            assign
                p-start-node-code = temp_found-result-nodelist.node-code
                v-start-full-name = temp_found-result-nodelist.full-name
                v-start-sort-name = temp_found-result-nodelist.sort-name
            .
        end.
    end.
end.
end procedure.
procedure grplib-expand-name :
define input parameter p-start-name as character        no-undo.
define output parameter p-end-name  as character        no-undo.
    define variable v-is-terminal   as logical      no-undo.
    define variable v-found         as character    no-undo.
    define buffer buf_temp_grplib_found-grp     for temp_grplib_found-grp.
do
for buf_temp_grplib_found-grp
on error undo, return error
:
    run grplib-find-grp-by-full-name in this-procedure (
          input p-start-name
        , input no
        , output v-found
    ) no-error.
    run grplib-get-max-substring in this-procedure (
                input length( p-start-name )
              , output p-end-name
    ) no-error .
    if error-status :error
    then do:
        assign
            p-end-name = ""
        .
    end.
    else do:
        find first temp_grplib_found-grp
            where temp_grplib_found-grp.full-name = p-end-name
        no-error.
        if available temp_grplib_found-grp
        then do:
            find first buf_temp_grplib_found-grp
                where buf_temp_grplib_found-grp.full-name begins p-end-name
                and recid( buf_temp_grplib_found-grp ) <> recid( temp_grplib_found-grp )
            no-error.
            if not available buf_temp_grplib_found-grp
            then do:
                run grplib-is-terminal in this-procedure (
                    input temp_grplib_found-grp.node-code
                    , output v-is-terminal
                ).
            end.
        end.
    end.
end.
end procedure.
procedure grplib-get-max-substring :
do
on error undo, return error
:
define input parameter p-min-substring-length   as integer      no-undo.
define output parameter p-substring             as character    no-undo.
        define variable v-char-counter  as integer           no-undo.
        define variable v-current-char  as character         no-undo.
        define variable v-names-counter  as integer           no-undo.
        define variable v-base-string   as character         no-undo.
        assign
            v-char-counter  = p-min-substring-length
        .
        find first temp_grplib_found-grp no-error.
        if not available temp_grplib_found-grp
        then do:
            undo, return error "grplib-get-max-substring: Нет строк для вычисления общей подстроки".
        end.
        else do:
            assign
                v-base-string  = temp_grplib_found-grp.full-name
                v-char-counter = 0
            .
            counter-block:
            do while yes
            on error undo, return error "grplib-get-max-substring: Ошибка вычисления продолжения имени группы."
            :
                assign
                    v-char-counter  = v-char-counter + 1
                    v-current-char  = substring( v-base-string, v-char-counter, 1 )
                    v-names-counter = 0
                .
                compare-block:
                for each temp_grplib_found-grp
                :
                    assign
                        v-names-counter = v-names-counter + 1
                    .
                    if v-names-counter = 1
                    then do:
                        next compare-block.
                    end.
                    if substring( temp_grplib_found-grp.full-name, v-char-counter, 1 ) <> v-current-char
                    then do:
                        leave counter-block.
                    end.
                end.
                if v-names-counter = 1
                then do:
                    assign
                        p-substring = v-base-string
                    .
                    return.
                end.
            end.
            assign
                p-substring = substring( v-base-string, 1, v-char-counter - 1 )
            .
        end.
end.
end procedure.
procedure grplib-is-terminal :
do
on error undo, return error "Ошибка процедуры grplib-is-terminal"
:
define input parameter p-node-code      as integer      no-undo.
define output parameter p-is-terminal   as logical      no-undo.
    define buffer buf_gds-grp       for ub.gds-grp.
    find first buf_gds-grp no-lock
        where buf_gds-grp.upper-code = p-node-code
    no-error .
    if not available buf_gds-grp
    then do:
        assign
            p-is-terminal = yes
        .
    end.
    else do:
        assign
            p-is-terminal = no
        .
    end.
end.
end procedure.
procedure grplib-have-goods :
do
on error undo, return error
:
define input parameter p-node-code      as integer      no-undo.
define output parameter p-have-goods   as logical      no-undo.
    define buffer buf_goods         for ub.goods.
    find first buf_goods no-lock
         where buf_goods.grp-code = p-node-code
    no-error .
    if available buf_goods
    then do:
        assign
            p-have-goods = yes
        .
    end.
    else do:
        assign
            p-have-goods = no
        .
    end.
end.
end procedure.
procedure grplib-find-by-substring :
do
on error undo, return error
:
define input parameter p-start-code         as integer      no-undo.
define input parameter p-full-search-string as character    no-undo.
define output parameter p-found-code        as integer      no-undo.
define output parameter p-full-name         as character    no-undo.
    define variable v-start-code     as integer           no-undo.
    define variable v-found          as logical  init no  no-undo.
    define buffer buf_gds-grp       for ub.gds-grp.
    search-grp:
    for each buf_gds-grp no-lock
        where buf_gds-grp.node-code > p-start-code
    :
        if index( buf_gds-grp.node-name, p-full-search-string ) <> 0
        then do:
            assign
                p-found-code = buf_gds-grp.node-code
                v-found      = yes
            .
            run grplib-get-full-name in this-procedure (
                  input p-found-code
                , output p-full-name
            ) no-error .
            if error-status :error
            then do:
                undo, return error "grplib-find-by-substring: Ошибка вычисления полного имени группы." + chr(10) + return-value.
            end.
            leave search-grp.
        end.
    end.
    if v-found = yes
    then do:
    end.
    else do:
        assign
            p-full-name  = ""
            p-found-code = 0
        .
    end.
end.
end procedure.
procedure grplib-analyze-grp-name :
do
on error undo, return error
:
define input parameter p-grp-name       as character            no-undo.
define input parameter p-upper-code     as integer              no-undo.
define output parameter p-error-message as character init ""    no-undo.
    define variable v-char-list     as character    no-undo.
    define variable v-char-counter  as integer      no-undo.
    define variable v-full-name     as character    no-undo.
    if p-grp-name = "" then do:
        assign
            p-error-message = "Название группы не может быть пустым.".
        .
    end.
    else do:
        assign
            v-char-list = "47,92,58,63,34,60,62,171,187,183"
        .
        do v-char-counter = 1 to num-entries( v-char-list )
        :
            if index( p-grp-name, chr( integer( entry( v-char-counter, v-char-list ) ) ) ) <> 0
            then do:
                assign
                    p-error-message = 'Название группы не может содержать символы /\:*?"<>|«»·'
                .
                return.
            end.
        end.
        if p-upper-code > 0
        then do:
            run grplib-get-full-name in this-procedure (
                  input p-upper-code
                , output v-full-name
            ) no-error .
            if error-status :error
            then do:
                undo, return error "grplib-analyze-grp-name: Не удалось вычислить полное имя группы." + chr(10) + return-value.
            end.
            if length( v-full-name ) + 1 + length( p-grp-name ) > 350
            then do:
                assign
                    p-error-message = 'Полное название группы не может содержать более 350 символов.'
                .
            end.
        end.
    end.
end.
end procedure.
procedure grplib-get-lvl-num :
define input parameter p-node-code  as integer      no-undo.
define output parameter p-lvl-num   as integer      no-undo.
    define variable v-full-name    as character    no-undo.
do
on error undo, return error
:
    run grplib-get-full-name in this-procedure (
          input p-node-code
        , output v-full-name
    ).
    assign
        p-lvl-num = num-entries( v-full-name, chr(47) ) - 1
    .
    if p-lvl-num = -1
    then do:
        assign
            p-lvl-num = 0
        .
    end.
end.
end procedure.
define stream sexp .
define variable f-name     as character no-undo .
define variable v-ok       as logical   no-undo .
define variable v-ind      as integer   no-undo .
define variable v-grp-name as character no-undo .
if p-install = false then do:
  assign
    v-ok = false
  .
  message
    "Экспорт групп товаров." skip
    "Продолжить?" skip
    view-as alert-box question buttons ok-cancel update v-ok.
  if v-ok <> true then do:
    return .
  end.
end.
assign
  f-name = 'gds-grp.ggr'
.
if p-install = false then do:
  system-dialog get-file f-name
    filters "Файл групп товаров *.ggr" "*.ggr"
    ask-overwrite
    save-as
    use-filename
    update v-ok
    default-extension "ggr".
  if v-ok <> true then do:
    return .
  end.
end.
output stream sexp to value (f-name) .
export stream sexp "GOODS_GRP_1_0" .
output stream sexp close .
run waitfram-show in this-procedure
  (input "Ждите..."
  ).
for each gds-grp no-lock
  where gds-grp.upper-code <> 0
:
  assign
    v-ind = v-ind + 1
  .
  run grplib-get-full-name in this-procedure (
                                                 input  gds-grp.node-code
                                              ,output v-grp-name
                                              ) .
  run waitfram-show in this-procedure
    (input "Ждите..."
    ).
  output stream sexp to value (f-name) append .
  export stream sexp v-grp-name .
  output stream sexp close .
  run waitfram-hide in this-procedure .
end.
if p-install = false then do:
  message
    "Экспорт групп товаров закончен" skip
    "Экспортировано групп" v-ind skip
    view-as alert-box information .
end.
