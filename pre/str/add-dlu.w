DEFINE TEMP-TABLE tt_add-line NO-UNDO LIKE add-line
       field sum-cli as decimal
       field vat-cli as decimal
       .
DEFINE BUFFER X_add-line FOR add-line.
DEFINE BUFFER X_contract FOR contract.
DEFINE BUFFER X_gds-add-charges FOR gds-add-charges.
DEFINE BUFFER X_goods FOR goods.
define input  parameter parParentProc as handle no-undo .
define input  parameter p-upper-h     as handle no-undo .
define input  parameter p-mode        as character no-undo .
define input  parameter p-doc-code    as character no-undo .
define input  parameter p-gds-code    as integer   no-undo .
define input-output parameter p-recid as recid no-undo .
define output parameter p-mode-exit   as character no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Строка дополнительных расходов в ПН".
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
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION alg-name RETURNS CHARACTER
  ( buffer loc-table for ub.gds-add-charges ) :
if not available  loc-table  then return "678" .
if loc-table.cost-include = no then return "".
case loc-table.algoritm :
  when "1" then do:
    return "сумме приходных цен".
  end.
  when "2" then do:
    return "количеству(в баз. ед.изм.)".
  end.
  when "3" then do:
    return "количеству(в пост. ед.изм.)" .
  end.
  when "4" then do:
    return "весу".
  end.
end case.
END FUNCTION.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure lineattr-value :
  do
  on error undo, return error return-value
  :
    define input  parameter p-doc-code like ub.doc-line-attr.doc-code   no-undo .
    define input  parameter p-gds-code like ub.doc-line-attr.gds-code   no-undo .
    define input  parameter p-code     like ub.doc-line-attr.attr-code  no-undo .
    define output parameter p-value    like ub.doc-line-attr.attr-value no-undo .
    define output parameter p-type     as character no-undo .
    define buffer buf_doc-line-attr for ub.doc-line-attr .
    def var v-format         as character no-undo .
    def var v-fillin_width   as integer   no-undo .
    def var v-fillin_height  as integer   no-undo .
    def var v-label          as character no-undo .
    def var v-user-can-edit  as logical   no-undo .
    def var v-output-display as logical   no-undo .
    def var v-other          as character no-undo .
    run lineattr-code in this-procedure
      (input  p-code
      ,output p-type
      ,output v-format
      ,output v-fillin_width
      ,output v-fillin_height
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_doc-line-attr no-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code = p-code
      no-error .
    if avail buf_doc-line-attr then do:
      assign
        p-value =  buf_doc-line-attr.attr-value
      .
    end.
    else do:
      assign
        p-value = if p-type = 'L':U then "no":U else ""
      .
    end.
  end.
end procedure.
procedure lineattr-write :
  do
  on error undo, return error return-value
  :
    define input parameter p-doc-code like ub.doc-line-attr.doc-code   no-undo .
    define input parameter p-gds-code like ub.doc-line-attr.gds-code   no-undo .
    define input parameter p-code     like ub.doc-line-attr.attr-code  no-undo .
    define input parameter p-value    like ub.doc-line-attr.attr-value no-undo .
    define buffer buf_doc-line-attr for ub.doc-line-attr .
    def var v-type           as character no-undo .
    def var v-format         as character no-undo .
    def var v-fillin_width   as integer   no-undo .
    def var v-fillin_height  as integer   no-undo .
    def var v-label          as character no-undo .
    def var v-user-can-edit  as logical   no-undo .
    def var v-output-display as logical   no-undo .
    def var v-other          as character no-undo .
    run lineattr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-fillin_width
      ,output v-fillin_height
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_doc-line-attr exclusive-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code = p-code
      no-error .
    if not available buf_doc-line-attr then do:
      create buf_doc-line-attr .
      assign
        buf_doc-line-attr.doc-code  = p-doc-code
        buf_doc-line-attr.gds-code = p-gds-code
        buf_doc-line-attr.attr-code = p-code
      .
    end.
    assign
      buf_doc-line-attr.attr-value = p-value
    .
     release buf_doc-line-attr.
  end.
end procedure.
procedure lineattr-exist :
  do
  on error undo, return error return-value
  :
    define input parameter p-doc-code like ub.doc-line-attr.doc-code   no-undo .
    define input parameter p-gds-code like ub.doc-line-attr.gds-code   no-undo .
    define input parameter p-code     like ub.doc-line-attr.attr-code  no-undo .
    define output parameter p-exist   as logical  no-undo .
    define buffer buf_doc-line-attr for ub.doc-line-attr .
    def var v-type           as character no-undo .
    def var v-format         as character no-undo .
    def var v-fillin_width   as integer   no-undo .
    def var v-fillin_height  as integer   no-undo .
    def var v-label          as character no-undo .
    def var v-user-can-edit  as logical   no-undo .
    def var v-output-display as logical   no-undo .
    def var v-other          as character no-undo .
    run lineattr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-fillin_width
      ,output v-fillin_height
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_doc-line-attr no-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code = p-gds-code
        and buf_doc-line-attr.attr-code = p-code
      no-error .
    if  available buf_doc-line-attr then do:
      p-exist = yes.
    end.
  end.
end procedure.
procedure lineattr-delete :
  do
  on error undo, return error return-value
  :
    define input parameter p-doc-code like ub.doc-line-attr.doc-code   no-undo .
    define input parameter p-gds-code like ub.doc-line-attr.gds-code   no-undo .
    define input parameter p-code     like ub.doc-line-attr.attr-code  no-undo .
    define output parameter p-deleted  as logical no-undo.
    define buffer buf_doc-line-attr for ub.doc-line-attr .
    def var v-type           as character no-undo .
    def var v-format         as character no-undo .
    def var v-fillin_width   as integer   no-undo .
    def var v-fillin_height  as integer   no-undo .
    def var v-label          as character no-undo .
    def var v-user-can-edit  as logical   no-undo .
    def var v-output-display as logical   no-undo .
    def var v-other          as character no-undo .
    run lineattr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-fillin_width
      ,output v-fillin_height
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_doc-line-attr exclusive-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code = p-code
      no-error NO-WAIT.
    if not available buf_doc-line-attr then do:
      p-deleted = no.
    end.
    else do:
      delete buf_doc-line-attr.
      p-deleted = yes.
    end.
  end.
end procedure.
procedure lineattr-code :
  do on error undo, return error return-value
  :
    define input  parameter p-code           as character no-undo .
    define output parameter p-type           as character no-undo .
    define output parameter p-format         as character no-undo .
    define output parameter p-fillin_width   as integer   no-undo .
    define output parameter p-fillin_height  as integer   no-undo .
    define output parameter p-label          as character no-undo .
    define output parameter p-user-can-edit  as logical   no-undo .
    define output parameter p-output-display as logical   no-undo .
    define output parameter p-other          as character no-undo .
    case p-code :
            when 'parts_price-sale':U then do:     assign     p-label          = "Продажная цена партии"     p-type           = 'C':U      p-format         = "x(70)"     p-fillin_width   = 12     p-fillin_height  = 1     p-label          = "Продажная цена партии"     p-user-can-edit  = false     p-output-display = false     p-other          = '':u      .   end.
            when 'fl_gds-code':U then do:     assign     p-label          = "Количество по букету"     p-type           = 'C':U      p-format         = "x(70)"     p-fillin_width   = 12     p-fillin_height  = 1     p-label          = "Количество по букету"     p-user-can-edit  = false     p-output-display = false     p-other          = '':u      .   end.
            when 'old_other-ras':U then do:     assign     p-label          = " Первым способом из ПН Сумма дополнительных расходов по строке rubl base"     p-type           = 'C':U      p-format         = "x(100)"     p-fillin_width   = 12     p-fillin_height  = 1     p-label          = " Первым способом из ПН Сумма дополнительных расходов по строке rubl base"     p-user-can-edit  = false     p-output-display = false     p-other          = '':u      .   end.
            when 'new_other-ras':U then do:     assign     p-label          = " Способом из ДопРасх Сумма дополнительных расходов по строке rubl base"     p-type           = 'C':U      p-format         = "x(100)"     p-fillin_width   = 12     p-fillin_height  = 1     p-label          = " Способом из ДопРасх Сумма дополнительных расходов по строке rubl base"     p-user-can-edit  = false     p-output-display = false     p-other          = '':u      .   end.
            when 'flora_ps':U then do:     assign     p-label          = "Описание не товарной позиции"     p-type           = 'C':U      p-format         = "x(70)"     p-fillin_width   = 12     p-fillin_height  = 1     p-label          = "Описание не товарной позиции"     p-user-can-edit  = true     p-output-display = true     p-other          = '':u      .   end.
            when 'country-code':U then do:     assign     p-label          = "Страна"     p-type           = 'I':U      p-format         = "->>>>>>>>9"     p-fillin_width   = 10     p-fillin_height  = 1     p-label          = "Страна"     p-user-can-edit  = false     p-output-display = false     p-other          = '':u      .   end.
            when 'add-line-cli':U then do:     assign     p-label          = "Курс . шкала . сумма . НДС "     p-type           = 'C':U      p-format         = "x(100)"     p-fillin_width   = 12     p-fillin_height  = 1     p-label          = "Курс . шкала . сумма . НДС "     p-user-can-edit  = false     p-output-display = false     p-other          = '':u      .   end.
            when 'corr-price-sale':U then do:     assign     p-label          = "Продажная цена в строке ПН"     p-type           = 'C':U      p-format         = "x(100)"     p-fillin_width   = 10     p-fillin_height  = 1     p-label          = "Продажная цена в строке ПН"     p-user-can-edit  = false     p-output-display = false     p-other          = '':u      .   end.
            when 'reason-code':U then do:     assign     p-label          = "Причина отклонения"     p-type           = 'I':U      p-format         = "->>>>>>>>9"     p-fillin_width   = 10     p-fillin_height  = 1     p-label          = "Причина отклонения"     p-user-can-edit  = true     p-output-display = true     p-other          = '':u      .   end.
            when 'price-prod':U then do:     assign     p-label          = "Цена производителя Без НДС"     p-type           = 'D':U      p-format         = ">>>>>>>>9.99"     p-fillin_width   = 10     p-fillin_height  = 1     p-label          = "Цена производителя Без НДС"     p-user-can-edit  = true     p-output-display = true     p-other          = '':u      .   end.
            when 'price-prodvat':U then do:     assign     p-label          = "Цена производителя c НДС"     p-type           = 'D':U      p-format         = ">>>>>>>>9.99"     p-fillin_width   = 10     p-fillin_height  = 1     p-label          = "Цена производителя c НДС"     p-user-can-edit  = true     p-output-display = true     p-other          = '':u      .   end.
      otherwise do:
        undo, return error "неизвестный атрибут строки документа" + " " + p-code .
      end.
    end.
  end.
end procedure.
procedure lineattr-value-flora-gds :
  do
  on error undo, return error return-value
  :
    define input  parameter p-doc-code    like  ub.doc-line-attr.doc-code   no-undo .
    define input  parameter p-gds-code    like  ub.doc-line-attr.gds-code   no-undo .
    define input  parameter p-prt-code    as integer   no-undo .
    define input  parameter p-bk-gds-code like  ub.doc-line-attr.gds-code   no-undo .
    define input  parameter p-code        like  ub.doc-line-attr.attr-code  no-undo .
    define output parameter p-value       as    decimal   no-undo .
    define buffer buf_doc-line-attr for ub.doc-line-attr .
    find first buf_doc-line-attr no-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code = p-code  + chr(44) + string(p-prt-code)  + chr(44) + string(p-bk-gds-code)
      no-error .
    if avail buf_doc-line-attr then do:
      assign
        p-value = decimal( buf_doc-line-attr.attr-value)
      .
    end.
    else do:
      assign
        p-value = 0
      .
    end.
  end.
end procedure.
procedure lineattr-write-flora-gds :
  do
  on error undo, return error return-value
  :
    define input parameter p-doc-code like ub.doc-line-attr.doc-code   no-undo .
    define input parameter p-gds-code like ub.doc-line-attr.gds-code   no-undo .
    define input parameter p-prt-code    as integer   no-undo .
    define input parameter p-bk-gds-code like ub.doc-line-attr.gds-code   no-undo .
    define input parameter p-code     like ub.doc-line-attr.attr-code  no-undo .
    define input parameter p-value    as decimal   no-undo .
    define buffer buf_doc-line-attr for ub.doc-line-attr .
    find first buf_doc-line-attr exclusive-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code = p-code + chr(44)  + string(p-prt-code)  + chr(44) + string(p-bk-gds-code)
      no-error .
    if not available buf_doc-line-attr then do:
      create buf_doc-line-attr .
      assign
        buf_doc-line-attr.doc-code  = p-doc-code
        buf_doc-line-attr.gds-code  = p-gds-code
        buf_doc-line-attr.attr-code = p-code  + chr(44)  + string(p-prt-code)  + chr(44) + string(p-bk-gds-code)
      .
    end.
    assign
      buf_doc-line-attr.attr-value = string( p-value )
    .
  end.
end procedure.
procedure lineattr-delete-flora-gds :
  do
  on error undo, return error return-value
  :
    define input parameter p-doc-code like ub.doc-line-attr.doc-code   no-undo .
    define input parameter p-gds-code like ub.doc-line-attr.gds-code   no-undo .
    define input  parameter p-prt-code    as integer   no-undo .
    define input parameter p-bk-gds-code like ub.doc-line-attr.gds-code   no-undo .
    define input parameter p-code     like ub.doc-line-attr.attr-code  no-undo .
    define output parameter p-deleted  as logical no-undo.
    define buffer buf_doc-line-attr for ub.doc-line-attr .
    find first buf_doc-line-attr exclusive-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code = p-code + chr(44) + string(p-prt-code)  + chr(44) + string(p-bk-gds-code)
      no-error NO-WAIT.
    if not available buf_doc-line-attr then do:
      p-deleted = no.
    end.
    else do:
      delete buf_doc-line-attr.
      p-deleted = yes.
    end.
  end.
end procedure.
procedure lineattr-delete-flora-all :
  do
  on error undo, return error return-value
  :
    define input  parameter p-doc-code like ub.doc-line-attr.doc-code   no-undo .
    define input  parameter p-gds-code like ub.doc-line-attr.gds-code   no-undo .
    define input  parameter p-prt-code    as integer   no-undo .
    define buffer buf_doc-line-attr for ub.doc-line-attr .
    for each buf_doc-line-attr exclusive-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code begins 'fl_gds-code':U + chr(44) + string(p-prt-code)  + chr(44)
     :
      delete buf_doc-line-attr.
    end.
 end.
end procedure.
procedure lineattr-exist-flora-gds :
  do
  on error undo, return error return-value
  :
    define input  parameter p-doc-code    like  ub.doc-line-attr.doc-code   no-undo .
    define input  parameter p-gds-code    like  ub.doc-line-attr.gds-code   no-undo .
    define input  parameter p-prt-code    as integer   no-undo .
    define input  parameter p-bk-gds-code like  ub.doc-line-attr.gds-code   no-undo .
    define output parameter p-exist as logical   no-undo .
    define buffer buf_doc-line-attr for ub.doc-line-attr .
    p-exist = false .
    find first buf_doc-line-attr no-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code = 'fl_gds-code':U  + chr(44) + string(p-prt-code)  + chr(44) + string(p-bk-gds-code)
      no-error .
    if avail buf_doc-line-attr then do:
      assign
       p-exist = true
      .
    end.
  end.
end procedure.
procedure lineattr-write-add-line-cli :
define input  parameter p-doc-code      like  ub.doc-line-attr.doc-code   no-undo .
define input  parameter p-gds-code      like  ub.doc-line-attr.gds-code   no-undo .
define input  parameter p-cli-type      as character no-undo .
define input  parameter p-cli-code      as integer   no-undo .
define input  parameter p-contract-code as integer   no-undo .
define input  parameter p-host-code     as integer   no-undo .
define input  parameter p-exch-code     as integer   no-undo .
define input  parameter p-exch-rate     as decimal   no-undo .
define input  parameter p-exch-scale    as integer   no-undo .
define input  parameter p-sum-cli       as decimal   no-undo .
define input  parameter p-sum-vat       as decimal   no-undo .
define buffer buf_doc-line-attr for ub.doc-line-attr .
  do
  on error undo, return error return-value
  :
    find first buf_doc-line-attr exclusive-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code = 'add-line-cli':U +
                                          chr(4) + p-cli-type +
                                          chr(4) + string(p-cli-code) +
                                          chr(4) + string(p-contract-code) +
                                          chr(4) + string(p-host-code)
      no-error .
    if not available buf_doc-line-attr then do:
      create buf_doc-line-attr .
      assign
        buf_doc-line-attr.doc-code  = p-doc-code
        buf_doc-line-attr.gds-code  = p-gds-code
        buf_doc-line-attr.attr-code = 'add-line-cli':U  +
                                      chr(4) + p-cli-type +
                                      chr(4) + string(p-cli-code) +
                                      chr(4) + string(p-contract-code) +
                                      chr(4) + string(p-host-code)
      .
    end.
    assign
      buf_doc-line-attr.attr-value =
      string(p-exch-code)  + chr(4) +
      string(p-exch-rate)  + chr(4) +
      string(p-exch-scale) + chr(4) +
      string(p-sum-cli)    + chr(4) +
      string(p-sum-vat)
      .
  end.
end procedure.
procedure lineattr-value-add-line-cli :
define input   parameter p-doc-code      like  ub.doc-line-attr.doc-code   no-undo .
define input   parameter p-gds-code      like  ub.doc-line-attr.gds-code   no-undo .
define input   parameter p-cli-type      as character no-undo .
define input   parameter p-cli-code      as integer   no-undo .
define input   parameter p-contract-code as integer   no-undo .
define input   parameter p-host-code     as integer   no-undo .
define output  parameter p-exch-code     as integer   no-undo .
define output  parameter p-exch-rate     as decimal   no-undo .
define output  parameter p-exch-scale    as integer   no-undo .
define output  parameter p-sum-cli       as decimal   no-undo .
define output  parameter p-sum-vat       as decimal   no-undo .
define buffer buf_doc-line-attr for ub.doc-line-attr .
  do
  on error undo, return error return-value
  :
    find first buf_doc-line-attr exclusive-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code = 'add-line-cli':U +
                                          chr(4) + p-cli-type +
                                          chr(4) + string(p-cli-code) +
                                          chr(4) + string(p-contract-code) +
                                          chr(4) + string(p-host-code)
      no-error .
    if available buf_doc-line-attr then do:
     assign
        p-exch-code  = integer ( entry (1 , buf_doc-line-attr.attr-value,  chr(4) ))
        p-exch-rate  = decimal ( entry (2 , buf_doc-line-attr.attr-value, chr(4) ))
        p-exch-scale = integer ( entry (3 , buf_doc-line-attr.attr-value, chr(4) ))
        p-sum-cli    = decimal ( entry (4 , buf_doc-line-attr.attr-value, chr(4) ))
        p-sum-vat    = decimal ( entry (5 , buf_doc-line-attr.attr-value, chr(4) ))
       .
     end.
  end.
end procedure.
function lineattr-get-reason returns character ( buffer local-doc-line for ub.doc-line ) :
  define variable v-code as character no-undo .
  define variable v-type as character no-undo .
  define variable v-gds-code as integer   no-undo .
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-code in g#library
  (input  local-doc-line.artic
  ,input  local-doc-line.prod-type
  ,input  local-doc-line.prod-code
  ,output v-gds-code
  )  .
  run lineattr-value (
      input   local-doc-line.doc-code ,
      input   v-gds-code              ,
      input   'reason-code':U ,
      output  v-code                  ,
      output  v-type ) .
  find first ub.trn-reason no-lock where
             ub.trn-reason.reason-code = integer ( v-code ) no-error.
  if not available ub.trn-reason then do:
     return "" .
  end.
  else do:
     return ub.trn-reason.reason-name .
  end.
end function.
procedure lineattr-value-parts :
  do
  on error undo, return error return-value
  :
    define input  parameter p-doc-code    like  ub.doc-line-attr.doc-code   no-undo .
    define input  parameter p-gds-code    like  ub.doc-line-attr.gds-code   no-undo .
    define input  parameter p-part-code   as character no-undo .
    define input  parameter p_in-code     as character no-undo .
    define input  parameter p-code        like  ub.doc-line-attr.attr-code  no-undo .
    define output parameter p-value       as    decimal   no-undo .
    define buffer buf_doc-line-attr for ub.doc-line-attr .
    find first buf_doc-line-attr no-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code = p-code  + chr(4) + trim(p-part-code)  + chr(4) + trim(p_in-code)
      no-error .
    if avail buf_doc-line-attr then do:
      assign
        p-value = decimal( buf_doc-line-attr.attr-value)
      .
    end.
    else do:
      assign
        p-value = 0
      .
    end.
  end.
end procedure.
procedure lineattr-write-parts :
  do
  on error undo, return error return-value
  :
    define input parameter p-doc-code like ub.doc-line-attr.doc-code   no-undo .
    define input parameter p-gds-code like ub.doc-line-attr.gds-code   no-undo .
    define input parameter p-part-code  as character no-undo .
    define input parameter p_in-code    as character no-undo .
    define input parameter p-code       like ub.doc-line-attr.attr-code  no-undo .
    define input parameter p-value      as decimal   no-undo .
    define buffer buf_doc-line-attr for ub.doc-line-attr .
    find first buf_doc-line-attr exclusive-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code = p-code + chr(4)  + trim(p-part-code)  + chr(4) + trim(p_in-code)
      no-error .
    if not available buf_doc-line-attr then do:
      create buf_doc-line-attr .
      assign
        buf_doc-line-attr.doc-code  = p-doc-code
        buf_doc-line-attr.gds-code  = p-gds-code
        buf_doc-line-attr.attr-code = p-code  + chr(4)  + trim(p-part-code)  + chr(4) + trim(p_in-code)
      .
    end.
    assign
      buf_doc-line-attr.attr-value = string( p-value )
    .
  end.
end procedure.
define buffer buf_add-line for ub.add-line  .
define variable ref-rec as recid no-undo.
define variable  exch-date as date no-undo.
DEFINE BUTTON B-cli
     IMAGE-UP FILE "cmp/btn-fnd.bmp":U
     IMAGE-DOWN FILE "cmp/btn-fnd.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/btn-fnd.bmp":U NO-CONVERT-3D-COLORS
     LABEL ""
     SIZE 3.5 BY 1.13 TOOLTIP "Посмотреть Поставщика".
DEFINE BUTTON B-contract
     IMAGE-UP FILE "cmp/btn-fnd.bmp":U
     IMAGE-DOWN FILE "cmp/btn-fnd.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/btn-fnd.bmp":U NO-CONVERT-3D-COLORS
     LABEL ""
     SIZE 3.5 BY 1.13 TOOLTIP "Посмотреть Договор".
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-Help
     LABEL "&Help"
     SIZE 3 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-History
     LABEL "&История"
     SIZE 3 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-quit-cycle AUTO-END-KEY
     LABEL "&Стоп-цикл"
     SIZE 11.5 BY 1
     BGCOLOR 8 .
DEFINE BUTTON r-cli
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY .88.
DEFINE BUTTON r-contract
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY .88.
DEFINE BUTTON r-currency
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE VARIABLE exch-code AS INTEGER FORMAT ">>9":U INITIAL 0
     LABEL "Валюта"
     VIEW-AS FILL-IN
     SIZE 4 BY 1 NO-UNDO.
DEFINE VARIABLE exch-rate AS DECIMAL FORMAT "->>,>>9.9999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 10 BY 1 NO-UNDO.
DEFINE VARIABLE exch-scale AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 3.5 BY 1 NO-UNDO.
DEFINE VARIABLE scr-cli-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 52.13 BY .67
     FGCOLOR 0  NO-UNDO.
DEFINE VARIABLE scr-contract-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 50.5 BY .67 NO-UNDO.
DEFINE VARIABLE scr-curr-abbr AS CHARACTER FORMAT "X(3)":U
      VIEW-AS TEXT
     SIZE 4 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE sum-cli AS DECIMAL FORMAT ">,>>>,>>>,>>9.99":U INITIAL 0
     LABEL "Сумма (в док.)"
     VIEW-AS FILL-IN
     SIZE 24.5 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE QUERY Dialog-Frame FOR
      TT_add-line,
      X_goods,
      X_gds-add-charges SCROLLING.
DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     B-quit AT ROW 1 COL 11
     B-quit-cycle AT ROW 1 COL 21 WIDGET-ID 4
     B-History AT ROW 1 COL 93.5 WIDGET-ID 2
     B-Help AT ROW 1 COL 96.5
     tt_add-line.cli-code AT ROW 5.54 COL 20 COLON-ALIGNED WIDGET-ID 8
          LABEL "Поставшик услуги"
          VIEW-AS FILL-IN NATIVE
          SIZE 10 BY 1
     tt_add-line.cli-type AT ROW 5.54 COL 31.13 COLON-ALIGNED NO-LABEL WIDGET-ID 74 FORMAT "X(3)"
          VIEW-AS COMBO-BOX INNER-LINES 2
          LIST-ITEMS "орг,чел"
          DROP-DOWN-LIST
          SIZE 5.88 BY 1
     B-cli AT ROW 5.54 COL 41.88 WIDGET-ID 62
     r-cli AT ROW 5.58 COL 39.13 WIDGET-ID 56
     B-contract AT ROW 7.5 COL 40.13 WIDGET-ID 60
     tt_add-line.contract-code AT ROW 7.54 COL 20 COLON-ALIGNED WIDGET-ID 12
          LABEL "Договор" FORMAT ">>>>>>>>>>9"
          VIEW-AS FILL-IN NATIVE
          SIZE 14 BY 1
     r-contract AT ROW 7.54 COL 37.38 WIDGET-ID 58
     exch-code AT ROW 8.75 COL 20 COLON-ALIGNED WIDGET-ID 80
     r-currency AT ROW 8.75 COL 26.38 WIDGET-ID 52
     exch-rate AT ROW 8.75 COL 31.88 COLON-ALIGNED NO-LABEL WIDGET-ID 82
     exch-scale AT ROW 8.75 COL 42.25 COLON-ALIGNED NO-LABEL WIDGET-ID 84
     tt_add-line.vat-pc AT ROW 10.17 COL 20 COLON-ALIGNED WIDGET-ID 24
          VIEW-AS FILL-IN
          SIZE 11 BY 1
     sum-cli AT ROW 11.67 COL 20 COLON-ALIGNED WIDGET-ID 76
     X_goods.gds-name AT ROW 2.83 COL 30.5 COLON-ALIGNED NO-LABEL WIDGET-ID 64
           VIEW-AS TEXT
          SIZE 64.5 BY 1
          BGCOLOR 3 FGCOLOR 15
     tt_add-line.gds-code AT ROW 3 COL 20.13 COLON-ALIGNED WIDGET-ID 14
          LABEL "Код доп.расхода"
           VIEW-AS TEXT
          SIZE 10 BY .67
     X_gds-add-charges.algoritm AT ROW 4.25 COL 46 COLON-ALIGNED WIDGET-ID 66
          LABEL "Алгоритм включения в цену пропорционально" FORMAT "x(40)"
           VIEW-AS TEXT
          SIZE 40 BY .67
          FGCOLOR 4
     scr-cli-name AT ROW 5.71 COL 43.38 COLON-ALIGNED NO-LABEL WIDGET-ID 70
     tt_add-line.host-code AT ROW 6.71 COL 31 COLON-ALIGNED WIDGET-ID 16
          LABEL "Фирма" FORMAT ">>>>9"
           VIEW-AS TEXT
          SIZE 6 BY .67
     scr-contract-name AT ROW 7.71 COL 41.63 COLON-ALIGNED NO-LABEL WIDGET-ID 72
     scr-curr-abbr AT ROW 8.75 COL 27.5 COLON-ALIGNED NO-LABEL WIDGET-ID 78
     tt_add-line.sum-base AT ROW 13.17 COL 20 COLON-ALIGNED WIDGET-ID 18
           VIEW-AS TEXT
          SIZE 16 BY .67
     tt_add-line.sum-rubl AT ROW 14.04 COL 20 COLON-ALIGNED WIDGET-ID 20
          LABEL "Сумма rubl"
           VIEW-AS TEXT
          SIZE 16 BY .67
     tt_add-line.vat-base AT ROW 16.13 COL 20 COLON-ALIGNED WIDGET-ID 22
          LABEL "НДС (баз.вал.)"
           VIEW-AS TEXT
          SIZE 22 BY .67
     tt_add-line.vat-rubl AT ROW 17.13 COL 20 COLON-ALIGNED WIDGET-ID 26
          LABEL "НДС rubl"
           VIEW-AS TEXT
          SIZE 22 BY .67
     SPACE(55.74) SKIP(2.90)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Строка дополнительных расходов"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON B-quit WIDGET-ID 100.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       X_gds-add-charges.algoritm:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       X_goods.gds-name:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       tt_add-line.host-code:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       r-currency:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       scr-cli-name:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       scr-contract-name:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       scr-curr-abbr:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       tt_add-line.sum-base:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ON GO OF FRAME Dialog-Frame
DO:
  run save-proc in this-procedure no-error .
    if error-status :error  then do:
        message
          error-status :get-message(1) skip
          return-value skip
          "Ошибка ввода"
          view-as alert-box error
        .
        return no-apply .
    end.
END.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-cli IN FRAME Dialog-Frame
DO:
assign TT_add-line.cli-code TT_add-line.cli-type .
define buffer buf_clients for ub.clients  .
find first buf_clients no-lock where
           buf_clients.obj-type = TT_add-line.cli-type and
           buf_clients.obj-code = TT_add-line.cli-code no-error .
if not available buf_clients then return .
  run ref/showcli.p (
     input parParentProc
    ,input TT_add-line.cli-type
    ,input TT_add-line.cli-code
    ).
END.
ON CHOOSE OF B-contract IN FRAME Dialog-Frame
DO:
assign TT_add-line.contract-code .
define buffer b_contract for ub.contract.
find first b_contract no-lock  where b_contract.contract-code     = TT_add-line.contract-code and
                                     b_contract.host-code         = TT_add-line.host-code
                                     no-error .
if error-status :error then return .
run str/sh-contr.p (
    input parParentProc ,
    input recid (b_contract))
    .
END.
ON CHOOSE OF B-exit IN FRAME Dialog-Frame
DO:
define variable vss-include-info6 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
  assign
  frame Dialog-Frame
  tt_add-line.cli-code tt_add-line.cli-type tt_add-line.contract-code tt_add-line.vat-pc tt_add-line.host-code tt_add-line.sum-rubl
.
  p-mode-exit= "".
END.
ON CHOOSE OF B-Help IN FRAME Dialog-Frame
OR HELP OF FRAME Dialog-Frame
DO:
END.
ON CHOOSE OF B-History IN FRAME Dialog-Frame
DO:
END.
ON CHOOSE OF B-quit IN FRAME Dialog-Frame
DO:
   p-mode-exit= "cancel".
END.
ON CHOOSE OF B-quit-cycle IN FRAME Dialog-Frame
DO:
   p-mode-exit= "stop-cycle".
END.
ON LEAVE OF tt_add-line.cli-code IN FRAME Dialog-Frame
DO:
  run f-cli in this-procedure .
END.
ON VALUE-CHANGED OF tt_add-line.cli-type IN FRAME Dialog-Frame
DO:
  assign TT_add-line.cli-type.
END.
ON LEAVE OF tt_add-line.contract-code IN FRAME Dialog-Frame
DO:
run f-con in this-procedure .
run f-spec in this-procedure .
run exch-rate in this-procedure.
END.
ON LEAVE OF exch-code IN FRAME Dialog-Frame
or return of exch-code in frame Dialog-Frame
do:
  assign exch-code  .
  find ub.currency no-lock where ub.currency.curr-code  = exch-code no-error.
  if not available ub.currency then do:
     return no-apply.
  end.
  display ub.currency.curr-code @ exch-code with frame Dialog-Frame .
  RUN exch-rate    in this-procedure.
END.
ON VALUE-CHANGED OF exch-code IN FRAME Dialog-Frame
DO:
    assign exch-code  .
  find ub.currency no-lock where ub.currency.curr-code  = exch-code no-error.
  if not available ub.currency then do:
     return no-apply.
  end.
  display ub.currency.curr-code @ exch-code with frame Dialog-Frame .
  RUN exch-rate    in this-procedure.
END.
ON LEAVE OF exch-rate IN FRAME Dialog-Frame
DO:
  assign exch-rate .
  run recalc(2).
END.
ON LEAVE OF exch-scale IN FRAME Dialog-Frame
DO:
  assign exch-scale.
  run recalc(2).
END.
ON CHOOSE OF r-cli IN FRAME Dialog-Frame
DO:
  define variable rid-list as character no-undo.
  define buffer buf_clients for ub.clients.
TT_add-line.cli-code   = 0 .
TT_add-line.cli-type   = "" .
scr-cli-name = "".
  run ref/cli-all.w
      ( input parParentProc,
        input "b-sel",
        input 'орг':U,
        input 'все':U,
        input 'текущие':U,
        input ?,
        input ",,,,,,NO,,":U,
        input "without-obj",
        output rid-list ) .
find first buf_clients no-lock where
     recid (buf_clients) = integer(rid-list) no-error .
    if available buf_clients then do:
        TT_add-line.cli-code  = buf_clients.obj-code .
        TT_add-line.cli-type  = buf_clients.obj-type .
        scr-cli-name = buf_clients.obj-name .
    end.
display TT_add-line.cli-code
        scr-cli-name
        TT_add-line.cli-type
        with frame Dialog-Frame.
END.
ON CHOOSE OF r-contract IN FRAME Dialog-Frame
DO:
IF TT_add-line.cli-code = 0  THEN DO:
   message "Не выбран Поставщик услуги !"  view-as alert-box information .
   return no-apply .
END.
define variable   rid-list   as character no-undo .
define buffer buf_contract for ub.contract.
ASSIGN
TT_add-line.cli-code
TT_add-line.contract-code = 0
scr-contract-name     = "" .
run str/cont-all.w (
      input   parParentProc   ,
      input   TT_add-line.host-code  ,
      input   "b-sel"         ,
      input   "contract-type=" + 'о Дополнительных расходах':U ,
      input   TT_add-line.cli-type ,
      input   TT_add-line.cli-code ,
      input   ?               ,
      input   ?               ,
      input   "current"       ,
      input   'при':U       ,
      input-output rid-list )
      .
find first buf_contract no-lock where recid (buf_contract) =  integer(rid-list) no-error .
if available buf_contract then do:
  TT_add-line.contract-code = buf_contract.contract-code .
  scr-contract-name     = buf_contract.contract-prn-code.
  end.
DISPLAY TT_add-line.contract-code
        scr-contract-name
        WITH FRAME Dialog-Frame.
run f-con in this-procedure .
run f-spec in this-procedure .
run exch-rate in this-procedure.
END.
ON CHOOSE OF r-currency IN FRAME Dialog-Frame
DO:
  run r-proc-currency in this-procedure.
  end.
ON LEAVE OF sum-cli IN FRAME Dialog-Frame
DO:
  assign sum-cli .
  TT_add-line.sum-cli = sum-cli .
  run recalc(2).
END.
ON LEAVE OF tt_add-line.vat-pc IN FRAME Dialog-Frame
DO:
  run recalc(1).
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  TT_add-line.cli-type:LIST-ITEMS = "орг,чел" .
  TT_add-line.sum-rubl:label      = "Сумма, руб"    .
  TT_add-line.vat-rubl:label      = "НДС, руб"      .
  run init-proc in this-procedure .
  if p-mode = 'ПРОСМОТР':U then run enable_lkp in this-procedure .
  else run enable_my in this-procedure .
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE check-exch :
find currency where currency.curr-code = exch-code  no-lock no-error.
  if not available currency then do:
    message "Неправильная валюта  - такой валюты нет.".
    apply "entry" to exch-code in frame Dialog-Frame.
    return error.
  end.
    if currency.curr-code = 0 then do:
      if (exch-rate <> ? and exch-scale <> ? and
          (exch-rate <> 1 or exch-scale <> 1)) then do:
      end.
      assign
        exch-rate = 1
        exch-scale = 1.
      disable exch-rate exch-scale with frame Dialog-Frame.
    end.
    else do:
      find last curr-accnt where curr-accnt.curr-code = currency.curr-code
                             and curr-accnt.exch-date <= today use-index pi no-lock no-error.
      if available curr-accnt then do:
        assign
          exch-rate = curr-accnt.exch-rate
          exch-scale = curr-accnt.exch-scale.
      end.
      else do:
        assign
          exch-rate = ?
          exch-scale = ?.
      end.
      if exch-code = 0 and
        (exch-rate  <> ? and
         exch-scale <> ? and
         (exch-rate <> 1 or exch-scale <> 1)
        ) then do:
      end.
      enable exch-rate exch-scale  with frame Dialog-Frame.
    end.
    assign
      exch-code = currency.curr-code
      .
    display exch-code currency.curr-abbr @ scr-curr-abbr
            exch-rate
            exch-scale with frame Dialog-Frame.
define variable v-exch-rate   as decimal   no-undo .
define variable v-exch-scale as decimal   no-undo .
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run exchrate in g#library
  (input  exch-code
  ,input  today
  ,output v-exch-rate
  ,output v-exch-scale
  ,output scr-curr-abbr
  )  .
     sum-cli:label in frame Dialog-Frame = "Сумма, " + scr-curr-abbr .
END PROCEDURE.
PROCEDURE check-rate :
define variable varbase-code as integer no-undo.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  v-cntxt-host-code-obj
  ,output varbase-code
  )  .
define variable flag-recount as logical initial no no-undo.
if input frame Dialog-Frame exch-rate  <> exch-rate  or
   input frame Dialog-Frame exch-scale <> exch-scale then flag-recount = yes.
if input frame Dialog-Frame exch-rate = ? or
   input frame Dialog-Frame exch-rate = 0 then do:
  message "Не задан курс валюты поставщика.".
  apply "entry" to exch-rate in frame Dialog-Frame.
  return error.
end.
if input frame Dialog-Frame exch-scale = ? or
   input frame Dialog-Frame exch-scale = 0 then do:
  message "Не задан масштаб валюты поставщика.".
  apply "entry" to exch-scale in frame Dialog-Frame.
  return error.
end.
assign
  frame Dialog-Frame
  exch-rate
  exch-scale.
run waitfram-show in this-procedure  ("ЖДИТЕ.  Пересчет документа ...").
if flag-recount then do:
   run full-recount.
end.
run waitfram-hide in this-procedure  .
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_lkp :
  OPEN QUERY Dialog-Frame FOR EACH TT_add-line SHARE-LOCK,       EACH X_goods WHERE X_goods.gds-code = TT_add-line.gds-code SHARE-LOCK,       EACH X_gds-add-charges WHERE X_gds-add-charges.gds-code = TT_add-line.gds-code SHARE-LOCK.
  GET FIRST Dialog-Frame.
  DISPLAY scr-cli-name scr-contract-name exch-code exch-rate exch-scale scr-curr-abbr
      WITH FRAME Dialog-Frame.
  IF AVAILABLE TT_add-line THEN
    DISPLAY TT_add-line.cli-code TT_add-line.cli-type TT_add-line.contract-code
          TT_add-line.sum-base TT_add-line.sum-rubl TT_add-line.vat-pc
          TT_add-line.gds-code TT_add-line.host-code TT_add-line.vat-base
          TT_add-line.vat-rubl sum-cli
      WITH FRAME Dialog-Frame.
  IF AVAILABLE X_goods THEN
    DISPLAY X_goods.gds-name
      WITH FRAME Dialog-Frame.
  ENABLE B-exit B-quit  B-History B-Help B-cli
         B-contract
      WITH FRAME Dialog-Frame.
  hide B-exit B-quit-cycle in frame Dialog-Frame .
  B-quit:label = "Выход" .
  B-quit:column = 1 .
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_my :
  OPEN QUERY Dialog-Frame FOR EACH TT_add-line SHARE-LOCK,       EACH X_goods WHERE X_goods.gds-code = TT_add-line.gds-code SHARE-LOCK,       EACH X_gds-add-charges WHERE X_gds-add-charges.gds-code = TT_add-line.gds-code SHARE-LOCK.
  GET FIRST Dialog-Frame.
  DISPLAY scr-cli-name scr-contract-name exch-code exch-rate exch-scale r-currency scr-curr-abbr
      WITH FRAME Dialog-Frame.
  IF AVAILABLE TT_add-line THEN
    DISPLAY TT_add-line.cli-code TT_add-line.cli-type TT_add-line.contract-code
          TT_add-line.sum-base TT_add-line.sum-rubl TT_add-line.vat-pc
          TT_add-line.gds-code TT_add-line.host-code TT_add-line.vat-base
          TT_add-line.vat-rubl sum-cli
      WITH FRAME Dialog-Frame.
  IF AVAILABLE X_goods THEN
    DISPLAY X_goods.gds-name
      WITH FRAME Dialog-Frame.
  ENABLE B-exit B-quit B-quit-cycle B-History B-Help B-cli TT_add-line.cli-code r-currency
         TT_add-line.cli-type r-cli B-contract TT_add-line.contract-code
         r-contract  sum-cli exch-code exch-rate exch-scale
         TT_add-line.vat-pc TT_add-line.host-code
      WITH FRAME Dialog-Frame.
  if p-mode = 'ИЗМЕНЕНИЕ':U then hide B-quit-cycle in frame Dialog-Frame .
  if exch-code = 0 then disable exch-rate exch-scale with frame Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  OPEN QUERY Dialog-Frame FOR EACH TT_add-line SHARE-LOCK,       EACH X_goods WHERE X_goods.gds-code = TT_add-line.gds-code SHARE-LOCK,       EACH X_gds-add-charges WHERE X_gds-add-charges.gds-code = TT_add-line.gds-code SHARE-LOCK.
  GET FIRST Dialog-Frame.
  DISPLAY exch-code exch-rate exch-scale sum-cli scr-cli-name scr-contract-name
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt_add-line THEN
    DISPLAY tt_add-line.cli-code tt_add-line.cli-type tt_add-line.contract-code
          tt_add-line.vat-pc tt_add-line.gds-code tt_add-line.host-code
          tt_add-line.sum-base tt_add-line.sum-rubl tt_add-line.vat-base
          tt_add-line.vat-rubl
      WITH FRAME Dialog-Frame.
  IF AVAILABLE X_gds-add-charges THEN
    DISPLAY X_gds-add-charges.algoritm
      WITH FRAME Dialog-Frame.
  IF AVAILABLE X_goods THEN
    DISPLAY X_goods.gds-name
      WITH FRAME Dialog-Frame.
  ENABLE B-exit B-quit B-quit-cycle B-History B-Help tt_add-line.cli-code
         tt_add-line.cli-type B-cli r-cli B-contract tt_add-line.contract-code
         r-contract exch-code exch-rate exch-scale tt_add-line.vat-pc sum-cli
         tt_add-line.host-code tt_add-line.sum-rubl
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE exch-rate :
display currency.curr-code @ exch-code with frame Dialog-Frame.
do transaction on error   undo, return error :
   run check-exch   in this-procedure.
   run check-rate   in this-procedure.
   run full-recount in this-procedure.
   run recalc(2).
end.
END PROCEDURE.
PROCEDURE f-cli :
assign
  frame Dialog-Frame
  TT_add-line.cli-type
  TT_add-line.cli-code
.
define buffer buf_clients for ub.clients  .
scr-cli-name = "" .
find first buf_clients no-lock where
     buf_clients.obj-type = TT_add-line.cli-type and
     buf_clients.obj-code = TT_add-line.cli-code
     no-error .
    if available buf_clients then do:
        scr-cli-name = buf_clients.obj-name .
    end.
display
scr-cli-name
with frame Dialog-Frame .
END PROCEDURE.
PROCEDURE f-con :
assign frame Dialog-Frame  TT_add-line.contract-code  .
define buffer buf_contract         for ub.contract  .
define buffer buf_contract-specif for ub.contract-specif  .
define buffer buf1_contract-specif for ub.contract-specif  .
scr-contract-name = "".
find first buf_contract no-lock where
           buf_contract.contract-code = TT_add-line.contract-code   and
           buf_contract.host-code     = TT_add-line.host-code
           no-error .
if available buf_contract then do:
scr-contract-name =   buf_contract.contract-prn-code .
exch-code         =   buf_contract.curr-code         .
end.
if exch-code <> 0 and  p-mode <> 'ПРОСМОТР':U then enable exch-rate exch-scale with frame Dialog-Frame.
if p-mode <> 'ПРОСМОТР':U then do:
   run check-exch .
end.
display
scr-contract-name
exch-code @ exch-code
TT_add-line.vat-pc @  TT_add-line.vat-pc
sum-cli            @  sum-cli
with frame Dialog-Frame .
run recalc(2) .
END PROCEDURE.
PROCEDURE f-spec :
define buffer buf_contract         for ub.contract  .
define buffer buf_contract-specif  for ub.contract-specif  .
define buffer buf1_contract-specif for ub.contract-specif  .
find first buf_contract no-lock where
           buf_contract.contract-code = TT_add-line.contract-code   and
           buf_contract.host-code     = TT_add-line.host-code
           no-error .
if available buf_contract then do:
exch-code = buf_contract.curr-code  .
    find first buf_contract-specif no-lock where
               buf_contract-specif.contract-num  = buf_contract.contract-code  and
               buf_contract-specif.host-code     = buf_contract.host-code
               no-error .
        if available buf_contract-specif then do:
            find first buf1_contract-specif no-lock where
                      buf1_contract-specif.gds-code      = TT_add-line.gds-code  and
                      buf1_contract-specif.contract-num  = buf_contract.contract-code  and
                      buf1_contract-specif.host-code     = buf_contract.host-code
                      no-error .
             if available buf1_contract-specif then do:
                TT_add-line.vat-pc = buf1_contract-specif.vat-pc   .
                TT_add-line.sum-cli = buf1_contract-specif.sum-cli .
                            sum-cli = buf1_contract-specif.sum-cli .
             end.
       end.
      display
        exch-code          @ exch-code
        tt_add-line.vat-pc @  tt_add-line.vat-pc
        sum-cli            @  sum-cli
        with frame Dialog-Frame .
end.
END PROCEDURE.
PROCEDURE full-recount :
END PROCEDURE.
PROCEDURE init-proc :
define variable v-vat-pc         as decimal   no-undo .
define variable loc-base-rate    as decimal   no-undo .
define variable loc-base-scale   as decimal   no-undo .
define variable vat_type         as character no-undo .
define variable slt_type         as character no-undo .
define variable base-abbr    as character no-undo .
define variable v-exch-code  as integer   no-undo .
define variable v-exch-rate  as decimal   no-undo .
define variable v-exch-scale as decimal   no-undo .
define variable v-sum-cli    as decimal   no-undo .
define variable v-sum-vat    as decimal   no-undo .
define buffer buf_goods for ub.goods  .
 run get-var in p-upper-h (
  output loc-base-rate
 ,output loc-base-scale
 ,output vat_type ).
 run get-var-2 in p-upper-h (
  output base-abbr
  ).
  find first x_goods no-lock where x_goods.gds-code = p-gds-code.
  find first buf_goods no-lock where buf_goods.gds-code = p-gds-code.
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  buf_goods.gds-code
  ,input  '1':U
  ,input  ?
  ,input  v-cntxt-host-code-obj
  ,input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-vat-pc
  ) no-error .
  if error-status :error then do:
    message
      error-status :get-message(1) skip
      return-value skip
      "Ошибка при определении НДС"
      view-as alert-box error
    .
    return .
  end.
if p-mode = 'ДОБАВЛЕНИЕ':U then do:
   create tt_add-line.
   assign
      tt_add-line.cli-code         = 0
      tt_add-line.cli-type         = 'орг':U
      tt_add-line.contract-code    = 0
      tt_add-line.doc-code         = p-doc-code
      tt_add-line.gds-code         = p-gds-code
      tt_add-line.host-code        = v-cntxt-host-code-obj
      tt_add-line.sum-cli          = 0
      tt_add-line.sum-base         = 0
      tt_add-line.sum-rubl         = 0
      tt_add-line.vat-pc           = v-vat-pc
      tt_add-line.vat-base         = 0
      tt_add-line.vat-rubl         = 0
   .
      exch-code = 0 .
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run exchrate in g#library
  (input  exch-code
  ,input  today
  ,output exch-rate
  ,output exch-scale
  ,output scr-curr-abbr
  )  .
end.
else do:
   if p-mode = 'ПРОСМОТР':U then
       find first buf_add-line no-lock where recid(buf_add-line) = p-recid no-error .
    else
       find first buf_add-line exclusive-lock where recid(buf_add-line) = p-recid no-error .
     run lineattr-value-add-line-cli (
          input  buf_add-line.doc-code     ,
          input  buf_add-line.gds-code     ,
          input  buf_add-line.cli-type     ,
          input  buf_add-line.cli-code     ,
          input  buf_add-line.contract-code,
          input  buf_add-line.host-code    ,
          output v-exch-code    ,
          output v-exch-rate    ,
          output v-exch-scale   ,
          output v-sum-cli      ,
          output v-sum-vat      ) no-error .
          if error-status :error then
          message
            vss-workfile vss-revision vss-description skip
            error-status :get-message(1) skip
            return-value skip
            ""
            view-as alert-box error
          .
      exch-code  = v-exch-code .
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run exchrate in g#library
  (input  exch-code
  ,input  today
  ,output exch-rate
  ,output exch-scale
  ,output scr-curr-abbr
  )  .
      exch-rate  = v-exch-rate  .
      exch-scale = v-exch-scale .
    create tt_add-line.
    buffer-copy buf_add-line to tt_add-line
    assign
      tt_add-line.sum-cli = v-sum-cli
    .
    assign
      sum-cli     = v-sum-cli
      exch-code   = v-exch-code
      exch-rate   = v-exch-rate
      exch-scale  = v-exch-scale
    .
end.
if not available X_gds-add-charges then
       find first X_gds-add-charges WHERE X_gds-add-charges.gds-code = TT_add-line.gds-code .
TT_add-line.sum-base:label in frame Dialog-Frame  = "Сумма, "  + base-abbr .
TT_add-line.vat-base:label in frame Dialog-Frame = "НДС, " + base-abbr .
sum-cli:label in frame Dialog-Frame = "Сумма, " + scr-curr-abbr .
display
alg-name( buffer X_gds-add-charges )  @ X_gds-add-charges.algoritm
with frame Dialog-Frame .
run f-cli in this-procedure .
run f-con in this-procedure .
run recalc  in this-procedure  (2).
END PROCEDURE.
PROCEDURE r-proc-currency :
run ref/currency.w ( input parparentproc, input "b-sel", input-output ref-rec ).
  if ref-rec = ? then do:
     return no-apply.
  end.
  find ub.currency no-lock where recid( ub.currency ) = ref-rec no-error.
  if not available ub.currency then do:
     return no-apply.
  end.
  if ub.currency.curr-code <> exch-code then do:
   display ub.currency.curr-code @ exch-code with frame Dialog-Frame .
  end.
  assign exch-code  .
  RUN exch-rate    in this-procedure.
END PROCEDURE.
PROCEDURE recalc :
define input  parameter p-type as integer   no-undo .
define variable     loc-base-rate    as decimal   no-undo .
define variable     loc-base-scale   as decimal   no-undo .
define variable     vat_type         as character no-undo .
define variable     slt_type         as character no-undo .
define variable    varprice-cli-dt            as decimal   no-undo .
define variable    varprice-cli-unit-base-dt  as decimal   no-undo .
define variable    varprice-road-tax-dt       as decimal   no-undo .
define variable    varprice-other-exp-dt      as decimal   no-undo .
define variable     varprice-transport-exp-dt as decimal   no-undo .
define variable     varprice-without-abs-dt   as decimal   no-undo .
define variable     varprice-slt-dt           as decimal   no-undo .
define variable     varprice-no-slt-dt        as decimal   no-undo .
define variable     varprice-vat-dt           as decimal   no-undo .
define variable     varprice-no-vat-slt-dt    as decimal   no-undo .
define variable     varprice-rubl-dt                as decimal   no-undo .
define variable     varprice-road-tax-rubl-dt       as decimal   no-undo .
define variable     varprice-other-exp-rubl-dt      as decimal   no-undo .
define variable     varprice-transport-exp-rubl-dt  as decimal   no-undo .
define variable     varprice-without-abs-rubl-dt    as decimal   no-undo .
define variable     varprice-slt-rubl-dt            as decimal   no-undo .
define variable     varprice-no-slt-rubl-dt         as decimal   no-undo .
define variable     varprice-vat-rubl-dt            as decimal   no-undo .
define variable     varprice-no-vat-slt-rubl-dt     as decimal   no-undo .
define variable     varprice-base-dt                as decimal   no-undo .
define variable     varprice-road-tax-base-dt       as decimal   no-undo .
define variable     varprice-other-exp-base-dt      as decimal   no-undo .
define variable     varprice-transport-exp-base-dt  as decimal   no-undo .
define variable     varprice-without-abs-base-dt    as decimal   no-undo .
define variable     varprice-slt-base-dt            as decimal   no-undo .
define variable     varprice-no-slt-base-dt         as decimal   no-undo .
define variable     varprice-vat-base-dt            as decimal   no-undo .
define variable     varprice-no-vat-slt-base-dt     as decimal   no-undo .
assign
  frame Dialog-Frame
  tt_add-line.cli-code tt_add-line.cli-type tt_add-line.contract-code tt_add-line.vat-pc tt_add-line.host-code tt_add-line.sum-rubl
.
 run get-var in p-upper-h (
  output loc-base-rate
 ,output loc-base-scale
 ,output vat_type ).
  if vat_type = 'без':U then tt_add-line.vat-pc = 0.
  slt_type = 'без':U .
    tt_add-line.sum-rubl =  tt_add-line.sum-cli  * exch-rate / exch-scale .
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_in-vat in g#lib-trn
  (
   input   'zakaz':u
  ,input   loc-base-rate
  ,input   loc-base-scale
  ,input   exch-rate
  ,input   exch-scale
  ,input   vat_type
  ,input   slt_type
  ,input   x_goods.artic
  ,input   x_goods.prod-type
  ,input   x_goods.prod-code
  ,input   tt_add-line.sum-cli
  ,input   1
  ,input   tt_add-line.sum-rubl
  ,input   tt_add-line.vat-pc
  ,input   0
  ,input   0
  ,input   0
  ,input   0
  ,output  varprice-cli-dt
  ,output  varprice-cli-unit-base-dt
  ,output  varprice-road-tax-dt
  ,output  varprice-other-exp-dt
  ,output  varprice-transport-exp-dt
  ,output  varprice-without-abs-dt
  ,output  varprice-slt-dt
  ,output  varprice-no-slt-dt
  ,output  varprice-vat-dt
  ,output  varprice-no-vat-slt-dt
  ,output  varprice-rubl-dt
  ,output  varprice-road-tax-rubl-dt
  ,output  varprice-other-exp-rubl-dt
  ,output  varprice-transport-exp-rubl-dt
  ,output  varprice-without-abs-rubl-dt
  ,output  varprice-slt-rubl-dt
  ,output  varprice-no-slt-rubl-dt
  ,output  varprice-vat-rubl-dt
  ,output  varprice-no-vat-slt-rubl-dt
  ,output  varprice-base-dt
  ,output  varprice-road-tax-base-dt
  ,output  varprice-other-exp-base-dt
  ,output  varprice-transport-exp-base-dt
  ,output  varprice-without-abs-base-dt
  ,output  varprice-slt-base-dt
  ,output  varprice-no-slt-base-dt
  ,output  varprice-vat-base-dt
  ,output  varprice-no-vat-slt-base-dt
  ) no-error.
    if error-status:error then do:
      message  "Ошибка при пересчете НДС" return-value error-status :get-message(1) view-as alert-box error .
    end.
TT_add-line.sum-base = varprice-base-dt      .
TT_add-line.sum-rubl = varprice-rubl-dt      .
TT_add-line.vat-base = varprice-vat-base-dt  .
TT_add-line.vat-rubl = varprice-vat-rubl-dt  .
display TT_add-line.sum-base
        TT_add-line.sum-rubl
        TT_add-line.vat-base
        TT_add-line.vat-rubl
        tt_add-line.vat-pc
        with frame Dialog-Frame .
END PROCEDURE.
PROCEDURE save-proc :
if p-mode = 'ПРОСМОТР':U then do:
   p-recid = recid(buf_add-line) .
  return .
End.
assign
  frame Dialog-Frame
  tt_add-line.cli-code tt_add-line.cli-type tt_add-line.contract-code tt_add-line.vat-pc tt_add-line.host-code tt_add-line.sum-rubl
.
define buffer buf_clients  for ub.clients  .
define buffer buf_contract for ub.contract  .
define buffer buf_contract-specif  for ub.contract-specif  .
define buffer buf1_contract-specif for ub.contract-specif  .
define buffer buf_contract-specif-attr for ub.contract-specif-attr .
find first buf_clients no-lock where
     buf_clients.obj-type = TT_add-line.cli-type and
     buf_clients.obj-code = TT_add-line.cli-code
     no-error .
if error-status :error then return error 'Не верно введен Поставщик услуги' .
if TT_add-line.contract-code <> 0 then do:
    find first buf_contract no-lock where
               buf_contract.contract-code = TT_add-line.contract-code   and
               buf_contract.host-code     = TT_add-line.host-code
              no-error .
    if error-status :error
       then return error substitute(" Нет договора с внутренним номером &1 на фирме &2" ,TT_add-line.contract-code,TT_add-line.host-code ) .
    if exch-code <>  buf_contract.curr-code
       then return error substitute(" У договора с внутренним номером &1 на фирме &2 задан код валюты &3" ,TT_add-line.contract-code , TT_add-line.host-code , buf_contract.curr-code ) .
    if ( TT_add-line.cli-type <> buf_contract.cli-type or
         TT_add-line.cli-code <> buf_contract.cli-code ) then do:
            return error substitute(" У договора с внутренним номером &1 на фирме &2 задан другой контрагент &3 &4" ,TT_add-line.contract-code , TT_add-line.host-code , buf_contract.cli-code , buf_contract.cli-type) .
         end.
    find first buf_contract-specif no-lock where
               buf_contract-specif.contract-num  = buf_contract.contract-code  and
               buf_contract-specif.host-code     = buf_contract.host-code
               no-error .
        if available buf_contract-specif then do:
        find first buf1_contract-specif no-lock where
                   buf1_contract-specif.gds-code      = TT_add-line.gds-code  and
                   buf1_contract-specif.contract-num  = buf_contract.contract-code  and
                   buf1_contract-specif.host-code     = buf_contract.host-code
                   no-error .
        if error-status :error then return error
            substitute(" Спецификация договора &1 не содержит услуги &2" ,
                        buf_contract.contract-code,
                        X_goods.gds-name ) .
            else do:
               if buf1_contract-specif.sum-cli <> 0 then do:
               if (buf1_contract-specif.sum-cli  + (buf1_contract-specif.sum-cli * buf1_contract-specif.prc / 100) ) < TT_add-line.sum-cli then
                  return error  substitute(" Спецификация договора &1 по услуге &2 имеет цену &3 , цена документа &5 выходит за процент отклонения в большую сторону &4% " ,
                        buf_contract.contract-code,
                        X_goods.gds-name              ,
                        buf1_contract-specif.sum-cli  ,
                        buf1_contract-specif.prc ,
                        TT_add-line.sum-cli
                        ) .
               find first buf_contract-specif-attr no-lock where
                          buf_contract-specif-attr.gds-code      = TT_add-line.gds-code  and
                          buf_contract-specif-attr.contract-num  = buf_contract.contract-code  and
                          buf_contract-specif-attr.host-code     = buf_contract.host-code     and
                          buf_contract-specif-attr.attr-code     = 'prc-min':U
                          no-error .
               if (buf1_contract-specif.sum-cli  - (buf1_contract-specif.sum-cli * decimal(buf_contract-specif-attr.attr-value) / 100) ) > TT_add-line.sum-cli then
                  return error  substitute(" Спецификация договора &1 по услуге &2 имеет цену &3 , цена документа &5 выходит за процент отклонения в меньшую сторону &4% " ,
                        buf_contract.contract-code,
                        X_goods.gds-name              ,
                        buf1_contract-specif.sum-cli  ,
                        buf_contract-specif-attr.attr-value ,
                        TT_add-line.sum-cli
                        ) .
               if buf1_contract-specif.VAT-pc <> TT_add-line.vat-pc then
                  return error substitute(" Спецификация договора &1 по услуге &2 имеет НДС &3 % " ,
                              buf_contract.contract-code  ,
                              X_goods.gds-name            ,
                              buf1_contract-specif.vat-pc
                              ) .
               end.
            end.
        end.
end.
if tt_add-line.sum-rubl = 0 or tt_add-line.sum-rubl = ? then return error " Не задана цена услуги".
run recalc  in this-procedure  (2).
if p-mode = 'ДОБАВЛЕНИЕ':U then do:
  create buf_add-line.
end.
buffer-copy tt_add-line to buf_add-line no-error .
if error-status :error then return error substitute(" В документе ДопРасхода &1 &6 уже есть строка расходов по услуге &6 Код &2 &6 Контрагент &4 &3 &6 Вн№.договора &5 &6 &7 " ,
                                                      tt_add-line.doc-code ,
                                                      tt_add-line.gds-code      ,
                                                      tt_add-line.cli-code      ,
                                                      tt_add-line.cli-type      ,
                                                      tt_add-line.contract-code ,
                                                      chr(10)              ,
                                                      return-value
                                                      )  .
    run lineattr-write-add-line-cli (
        tt_add-line.doc-code     ,
        tt_add-line.gds-code     ,
        tt_add-line.cli-type     ,
        tt_add-line.cli-code     ,
        tt_add-line.contract-code,
        tt_add-line.host-code    ,
        exch-code                ,
        exch-rate                ,
        exch-scale               ,
        tt_add-line.sum-cli      ,
        0
        ).
  p-recid = recid(buf_add-line) .
END PROCEDURE.
PROCEDURE update-rate-doc :
if input frame Dialog-Frame exch-rate  <> exch-rate  or
   input frame Dialog-Frame exch-scale <> exch-scale
then
   do transaction on error undo, return error return-value :
     run check-exch   in this-procedure no-error.
     if error-status :error then do: return error return-value. end.
     run check-update in this-procedure no-error.
     if error-status :error then do: return error return-value. end.
     run check-rate   in this-procedure no-error.
     if error-status :error then do: return error return-value. end.
    end.
END PROCEDURE.
