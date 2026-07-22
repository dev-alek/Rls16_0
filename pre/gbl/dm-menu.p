block-level on error undo, throw.
define input  parameter parparentproc     as widget-handle no-undo .
define input  parameter p-menu-handle     as widget-handle no-undo .
define input  parameter p-menu-code       as integer   no-undo .
define input  parameter p-menu-group-code as integer   no-undo .
define output parameter p-menu-control-number as character no-undo .
define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Создание динамического меню":U .
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
    assign
      p-vss-parameters = substitute('&1|&2|&3':u,parparentproc,p-menu-handle,p-menu-code,p-menu-group-code)
    .
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
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function octal-to-char return character
( p-string as character ) :
  def var v-asc     as integer no-undo .
  def var v-new-asc as integer no-undo .
  def var ind       as integer no-undo .
  if length(p-string) <> 3 then do:
    return ? .
  end.
  assign
    v-asc = 0
  .
  do ind = 1 to length(p-string)
  :
    assign
      v-new-asc = asc(substring(p-string, ind, 1)) - asc('0')
    .
    if v-new-asc < 0 or v-new-asc >= 8 then do:
      return ? .
    end.
    assign
      v-asc = v-asc * 8 + v-new-asc
    .
  end.
  return chr(v-asc) .
end function .
function char-to-octal return character
( p-chr as character ) :
  def var v-asc    as integer   no-undo .
  def var ind      as integer   no-undo .
  def var v-string as character no-undo .
  if length(p-chr) <> 1 then do:
    return ? .
  end.
  assign
    v-asc    = asc(p-chr)
    v-string = ""
  .
  do ind = 1 to 3
  :
    assign
      v-string = chr( v-asc mod 8 + asc('0')) + v-string
    .
    assign
      v-asc = truncate(v-asc / 8, 0)
    .
  end.
  return v-string .
end.
function str-encode return character
(   p-init-string       as character
  , p-encode-char       as character
  , p-special-char-list as character
) :
  def var p-encode-string as character no-undo .
  def var ind                as integer no-undo .
  def var v-num-special-char as integer no-undo .
  def var v-special-char     as character no-undo .
  if p-encode-char = ?
  or p-encode-char = "" then do:
    assign
      p-encode-char = "~~"
    .
  end.
  if p-init-string = ? then do:
    return "?" .
  end.
  if p-init-string = "?" then do:
    return p-encode-char + char-to-octal("?") .
  end.
  assign
    v-num-special-char = length(p-special-char-list)
    p-encode-string    = replace(p-init-string
                                ,p-encode-char
                                ,p-encode-char + char-to-octal(p-encode-char)
                                )
  .
  do ind = 1 to v-num-special-char
  :
    assign
      v-special-char = substring(p-special-char-list, ind, 1)
    .
    if v-special-char <> p-encode-char then do:
      assign
        p-encode-string = replace (p-encode-string
                                  ,v-special-char
                                  ,p-encode-char + char-to-octal(v-special-char)
                                  )
      .
    end.
  end.
  return p-encode-string .
end.
function str-decode returns character
  (p-init-string   as character
  ,p-encode-char   as character
  ) :
  def var p-decode-string as character no-undo .
  def var ind                       as integer no-undo .
  def var v-num-entries-init-string as integer no-undo .
  def var v-sub-phrase              as character no-undo .
  def var v-special-char            as character no-undo .
  if p-encode-char = ?
  or p-encode-char = "" then do:
    assign
      p-encode-char = "~~"
    .
  end.
  if p-init-string = "?" then do:
    return ? .
  end.
  assign
    v-num-entries-init-string = num-entries(p-init-string, p-encode-char)
  .
  if v-num-entries-init-string > 1 then do:
    assign
      p-decode-string = entry(1, p-init-string, p-encode-char)
    .
    do ind = 2 to v-num-entries-init-string
    :
      assign
        v-sub-phrase = entry(ind, p-init-string, p-encode-char)
      .
      assign
        v-special-char = octal-to-char(substring(v-sub-phrase, 1, 3))
      .
      if v-special-char <> ? then do:
        assign
          p-decode-string = p-decode-string
                          + v-special-char
                          + substring(v-sub-phrase, 4)
        .
      end.
      else do:
        assign
          p-decode-string = p-decode-string
                          + p-encode-char
                          + v-sub-phrase
        .
      end.
    end.
  end.
  else do:
    assign
      p-decode-string = p-init-string
    .
  end.
  return p-decode-string .
end.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
procedure thbjattr_code :
   define input  parameter p-upper-code     as character no-undo .
   define input  parameter p-code           as character no-undo .
   define output parameter p-label          as character no-undo .
   define output parameter p-user-can-edit  as logical   no-undo .
   define output parameter p-output-display as logical   no-undo .
   define output parameter p-other          as character no-undo .
   define output parameter p-prop-list      as character no-undo .
   define output parameter p-prop-type-list as character no-undo .
   define output parameter p-prop-label-list as character no-undo .
   define output parameter p-global          as logical no-undo .
   define output parameter p-host           as logical no-undo .
   define output parameter p-shop           as logical no-undo .
   define output parameter p-store          as logical no-undo .
   define output parameter p-db             as logical no-undo .
   define variable p-region as logical no-undo.
   run thbjattr_code_reg in this-procedure (
                                            p-upper-code,
                                            p-code,
                                            output p-label,
                                            output p-user-can-edit,
                                            output p-output-display,
                                            output p-other,
                                            output p-prop-list,
                                            output p-prop-type-list,
                                            output p-prop-label-list,
                                            output p-global,
                                            output p-host,
                                            output p-shop,
                                            output p-store,
                                            output p-db,
                                            output p-region
                                            ).
end procedure.
procedure thbjattr_code_reg :
define input  parameter p-upper-code     as character no-undo .
define input  parameter p-code           as character no-undo .
define output parameter p-label          as character no-undo .
define output parameter p-user-can-edit  as logical   no-undo .
define output parameter p-output-display as logical   no-undo .
define output parameter p-other          as character no-undo .
define output parameter p-prop-list      as character no-undo .
define output parameter p-prop-type-list as character no-undo .
define output parameter p-prop-label-list as character no-undo .
define output parameter p-global          as logical no-undo .
define output parameter p-host           as logical no-undo .
define output parameter p-shop           as logical no-undo .
define output parameter p-store          as logical no-undo .
define output parameter p-db             as logical no-undo .
define output parameter p-region         as logical no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_code in g#attr-lib
    (input  p-upper-code
    ,input  p-code
    ,output p-label
    ,output p-user-can-edit
    ,output p-output-display
    ,output p-other
    ,output p-prop-list
    ,output p-prop-type-list
    ,output p-prop-label-list
    ,output p-global
    ,output p-host
    ,output p-shop
    ,output p-store
    ,output p-db
    ,output p-region
    ) no-error .
  if error-status :error
  then do:
    undo, return error substitute( "&1. &2&3&4", vss-include-info3, return-value, chr(10), error-status :get-message (1)).
  end.
end.
end procedure.
procedure thbjattr_tooltip :
define input  parameter p-upper-code  as character no-undo .
define input  parameter p-code      as character no-undo .
define output parameter p-tooltip   as character no-undo .
define output parameter p-label     as character no-undo .
define output parameter p-tooltip-code as character no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_tooltip in g#attr-lib
    (input  p-upper-code
    ,input  p-code
    ,output p-tooltip
    ,output p-label
    ,output p-tooltip-code
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_legacy :
define input  parameter p-upper-code     as character no-undo .
define output parameter p-level-way      as character no-undo .
define output parameter p-up-way         as character no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_legacy in g#attr-lib
    (input  p-upper-code
    ,output p-level-way
    ,output p-up-way
    ) no-error .
  if error-status :error
  then do:
    undo, return error substitute( "&1. &2&3&4", vss-include-info3, return-value, chr(10), error-status :get-message (1)).
  end.
end.
end procedure.
procedure thbjattr_value :
define input  parameter p-obj-type like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter p-code     like ub.thbj-attr.prop-code  no-undo .
define output parameter p-value-character like ub.thbj-attr.property-value-character no-undo .
define output parameter p-value-date    like ub.thbj-attr.property-value-date no-undo .
define output parameter p-value-decimal like ub.thbj-attr.property-value-decimal no-undo .
define output parameter p-value-integer like ub.thbj-attr.property-value-integer no-undo .
define output parameter p-value-logical like ub.thbj-attr.property-value-logical no-undo .
define output parameter p-type     as character no-undo .
define output parameter p-found as decimal no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_value in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ,input  p-code
    ,output p-value-character
    ,output p-value-date
    ,output p-value-decimal
    ,output p-value-integer
    ,output p-value-logical
    ,output p-type
    ,output p-found
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_get-section :
define input  parameter p-obj-type like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-param-code  like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter p-mode as character no-undo .
define input-output parameter table-handle p-tth.
define output parameter p-all-found as decimal no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_get-section in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-param-code
    ,input  p-mode
    ,input-output table-handle p-tth
    ,output p-all-found
    ) no-error .
  if error-status :error
  then do:
    delete object p-tth.
    undo, return error return-value .
  end.
  delete object p-tth.
end.
end procedure.
procedure thbjattr_write :
define input  parameter p-obj-type like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code  like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter p-code     like ub.thbj-attr.prop-code  no-undo .
define input  parameter p-value-character like ub.thbj-attr.property-value-character no-undo .
define input  parameter p-value-date like ub.thbj-attr.property-value-date no-undo .
define input  parameter p-value-decimal like ub.thbj-attr.property-value-decimal no-undo .
define input  parameter p-value-integer like ub.thbj-attr.property-value-integer no-undo .
define input  parameter p-value-logical like ub.thbj-attr.property-value-logical no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_write in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ,input  p-code
    ,input  p-value-character
    ,input  p-value-date
    ,input  p-value-decimal
    ,input  p-value-integer
    ,input  p-value-logical
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_set-section :
define input  parameter p-obj-type like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code  like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter table-handle p-tth.
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_set-section in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ,input  table-handle p-tth
    ) no-error .
  if error-status :error
  then do:
    delete object p-tth.
    undo, return error return-value .
  end.
  delete object p-tth.
end.
end procedure.
procedure thbjattr_delete :
define input  parameter p-obj-type   like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code   like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter p-code       like ub.thbj-attr.prop-code  no-undo .
define output parameter p-deleted  as logical no-undo.
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_delete in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ,input  p-code
    ,output p-deleted
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_delete-section :
define input  parameter p-obj-type   like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code   like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code like ub.thbj-attr.upper-prop-code  no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_delete-section in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_manual-edit :
define input  parameter p-ucode          as character no-undo .
define input  parameter p-code           as character no-undo .
define output parameter p-section-num    as integer no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_manual-edit in g#attr-lib
    (input  p-ucode
    ,input  p-code
    ,output  p-section-num
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure cur-time :
   define output parameter p-today as date      no-undo .
   define output parameter p-time  as integer   no-undo .
  do
  on error undo, return error
  :
    define variable v-date1 as date      no-undo .
    define variable v-date2 as date      no-undo .
    define variable v-time  as integer   no-undo .
    assign
      v-date1 = today
      v-time  = time
      v-date2 = today
    .
    if v-date1 <> v-date2
    then do:
      assign
        v-date1 = today
        v-time  = v-time
      .
    end.
    assign
      p-today = v-date1
      p-time  = v-time
    .
  end.
end.
function cur-time-date returns character
:
  return string(today, '99/99/9999':U) .
end.
function cur-time-mjd returns decimal
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return integer(v-date) - 2400002 + (v-time / 86400) .
end.
function cur-time-get-ending-index returns integer
(input p-number as integer
)
:
  if p-number < 0
  or p-number = ?
  then do:
    return 1 .
  end.
  define variable v-rest as integer   no-undo .
  assign
    p-number = p-number modulo 100
  .
  if p-number < 20
  then do:
    assign
      v-rest = p-number
    .
  end.
  else do:
    assign
      v-rest = p-number modulo 10
    .
  end.
  case v-rest :
    when 1
    then do:
      return 2 .
    end.
    when 2 or
    when 3 or
    when 4
    then do:
      return 3 .
    end.
    otherwise do:
      return 1 .
    end.
  end case .
end.
procedure cur-time-mjd-to-date :
   define input  parameter i-mjd-diff as decimal no-undo.
   define output parameter o-Date     as date    no-undo.
   define output parameter o-Time     as integer no-undo.
   define variable v-day-number as integer   no-undo .
   if    i-mjd-diff < 0
      or i-mjd-diff = ?
   then do:
      return "?" .
   end.
   assign
      v-day-number = truncate(i-mjd-diff,0).
      o-Date = date(v-day-number + 2400002).
      o-Time = truncate((i-mjd-diff - v-day-number) * 86400, 0)
  .
end.
function cur-time-mjd-to-string returns character
(input p-mjd-diff as decimal
)
:
  define variable v-day-number as integer   no-undo .
  define variable v-seconds    as integer   no-undo .
  define variable v-hour       as integer   no-undo .
  define variable v-min        as integer   no-undo .
  define variable v-day-name    as character no-undo extent 3 initial [   "дней",    "день",     "дня" ] .
  define variable v-hour-name   as character no-undo extent 3 initial [  "часов",     "час",    "часа" ] .
  define variable v-min-name    as character no-undo extent 3 initial [  "минут",  "минута",  "минуты" ] .
  define variable v-second-name as character no-undo extent 3 initial [ "секунд", "секунда", "секунды" ] .
  if p-mjd-diff < 0
  or p-mjd-diff = ?
  then do:
    return "?" .
  end.
  assign
    v-day-number = integer(truncate(p-mjd-diff,0))
    v-seconds    = truncate((p-mjd-diff - v-day-number) * 86400, 0)
  .
  if v-seconds > 86400
  then do:
    assign
      v-seconds = 86400 - 1
    .
  end.
  if v-seconds < 0
  then do:
    assign
      v-seconds = 0
    .
  end.
  assign
    v-hour = truncate(v-seconds / 3600, 0)
  .
  assign
    v-seconds = v-seconds modulo 3600
  .
  assign
    v-min = truncate(v-seconds / 60, 0)
  .
  assign
    v-seconds = v-seconds modulo 60
  .
  return
      (if v-day-number <> 0
        then string(v-day-number) + " " + v-day-name[cur-time-get-ending-index(v-day-number)] + " "
        else ""
      )
    + (if v-day-number <> 0 or v-hour <> 0
        then string(v-hour) + " " + v-hour-name[cur-time-get-ending-index(v-hour)] + " "
        else ""
      )
    + (if v-day-number <> 0 or v-hour <> 0 or v-min <> 0
        then string(v-min) + " " + v-min-name[cur-time-get-ending-index(v-min)] + " "
        else ""
      )
    + string(v-seconds) + " " + v-second-name[cur-time-get-ending-index(v-seconds)]
    .
end.
function cur-time-string returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return string(v-date, '99/99/9999':U) + ' ':u + string(v-time, 'HH:MM':U) .
end.
function cur-time-string-sec returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return string(v-date, '99/99/9999':U) + ' ':u + string(v-time, 'HH:MM:SS':U) .
end.
function cur-time-custom  returns character
(input p-prefix as character
,input p-date-format as character
,input p-delimiter as character
,input p-time-format as character
,input p-suffix as character
)
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return
    p-prefix
    + string(v-date, p-date-format)
    + p-delimiter
    + string(v-time, p-time-format)
    + p-suffix
    .
end.
function cur-time-print  returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return "Дата печати : " + string(v-date, '99.99.9999':U) + ' , ':U + string(v-time, 'HH:MM':U) .
end.
function cur-time-datetime returns datetime
:
  define variable v-char as character no-undo .
  define variable v-datetime as datetime no-undo .
  v-char = cur-time-string().
  v-datetime = datetime(v-char).
  return  v-datetime.
end.
function cur-time-string-msec returns character
:
  define variable v-date as datetime  no-undo .
  v-date = now.
  return string(v-date) .
end.
define new global shared variable g#lib-farh as handle no-undo .
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure cd-attr-code :
  define input  parameter p-ucode          as character no-undo .
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  define output parameter p-prop-list      as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-code in g#attr-lib
      (input  p-ucode
      ,input  p-code
      ,output p-type
      ,output p-format
      ,output p-label
      ,output p-user-can-edit
      ,output p-output-display
      ,output p-other
      ,output p-prop-list
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-tooltip :
  define input  parameter p-ucode   as character no-undo .
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-tooltip in g#attr-lib
      (input  p-ucode
      ,input  p-code
      ,output p-tooltip
      ,output p-label
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-value :
  define input  parameter p-db-num    like ub.cash-desk-attr.db-num        no-undo .
  define input  parameter p-obj-code  like ub.cash-desk-attr.obj-code      no-undo .
  define input  parameter p-pos-type  like ub.cash-desk-attr.pos-type      no-undo .
  define input  parameter p-cash-num  like ub.cash-desk-attr.cash-num      no-undo .
  define input  parameter p-ucode     like ub.cash-desk-attr.upper-attr-code      no-undo .
  define input  parameter p-code      like ub.cash-desk-attr.attr-code      no-undo .
  define output parameter p-character like ub.cash-desk-attr.attr-value-character    no-undo .
  define output parameter p-date      like ub.cash-desk-attr.attr-value-date         no-undo .
  define output parameter p-decimal   like ub.cash-desk-attr.attr-value-decimal      no-undo .
  define output parameter p-integer   like ub.cash-desk-attr.attr-value-integer      no-undo .
  define output parameter p-logical   like ub.cash-desk-attr.attr-value-logical      no-undo .
  define output parameter p-type      as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-value in g#attr-lib
      (input  p-db-num
      ,input  p-obj-code
      ,input  p-pos-type
      ,input  p-cash-num
      ,input  p-ucode
      ,input  p-code
      ,output p-character
      ,output p-date
      ,output p-decimal
      ,output p-integer
      ,output p-logical
      ,output p-type
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-write :
  define input parameter p-db-num    like ub.cash-desk-attr.db-num     no-undo .
  define input parameter p-obj-code  like ub.cash-desk-attr.obj-code   no-undo .
  define input parameter p-pos-type  like ub.cash-desk-attr.pos-type   no-undo .
  define input parameter p-cash-num  like ub.cash-desk-attr.cash-num   no-undo .
  define input parameter p-ucode     like ub.cash-desk-attr.upper-attr-code  no-undo .
  define input parameter p-code      like ub.cash-desk-attr.attr-code  no-undo .
  define input parameter p-character like ub.cash-desk-attr.attr-value-character no-undo .
  define input parameter p-date      like ub.cash-desk-attr.attr-value-date      no-undo .
  define input parameter p-decimal   like ub.cash-desk-attr.attr-value-decimal   no-undo .
  define input parameter p-integer   like ub.cash-desk-attr.attr-value-integer   no-undo .
  define input parameter p-logical   like ub.cash-desk-attr.attr-value-logical   no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-write in g#attr-lib
      (input p-db-num
      ,input p-obj-code
      ,input p-pos-type
      ,input p-cash-num
      ,input p-ucode
      ,input p-code
      ,input p-character
      ,input p-date
      ,input p-decimal
      ,input p-integer
      ,input p-logical
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-exist :
  define input  parameter p-db-num   like ub.cash-desk-attr.db-num     no-undo .
  define input  parameter p-obj-code like ub.cash-desk-attr.obj-code   no-undo .
  define input  parameter p-pos-type like ub.cash-desk-attr.pos-type   no-undo .
  define input  parameter p-cash-num like ub.cash-desk-attr.cash-num   no-undo .
  define input  parameter p-ucode    like ub.cash-desk-attr.upper-attr-code  no-undo .
  define input  parameter p-code     like ub.cash-desk-attr.attr-code  no-undo .
  define output parameter p-exist    as logical  no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-exist in g#attr-lib
      (input  p-db-num
      ,input  p-obj-code
      ,input  p-pos-type
      ,input  p-cash-num
      ,input  p-ucode
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-delete :
  define input parameter  p-db-num   like ub.cash-desk-attr.db-num     no-undo .
  define input parameter  p-obj-code like ub.cash-desk-attr.obj-code   no-undo .
  define input parameter  p-pos-type like ub.cash-desk-attr.pos-type   no-undo .
  define input parameter  p-cash-num like ub.cash-desk-attr.cash-num   no-undo .
  define input parameter  p-ucode     like ub.cash-desk-attr.upper-attr-code  no-undo .
  define input parameter  p-code     like ub.cash-desk-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo.
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-delete in g#attr-lib
      (input  p-db-num
      ,input  p-obj-code
      ,input  p-pos-type
      ,input  p-cash-num
      ,input  p-ucode
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-news :
  define input  parameter p-ucode          as character no-undo .
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  define output parameter p-from-gbd       as logical   no-undo .
  define output parameter p-from-ubd       as logical   no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-news in g#attr-lib
      (
       input  p-ucode
      ,input  p-code
      ,output p-news
      ,output p-from-gbd
      ,output p-from-ubd
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-hist :
  define input  parameter p-ucode          as character no-undo .
  define input  parameter p-code           as character no-undo .
  define output parameter p-hist           as logical   no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-hist in g#attr-lib
      (input  p-ucode
      ,input  p-code
      ,output p-hist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
function cd-attr-parse-date-time returns date
(input  p-string as character
,output p-time   as integer
):
  define variable v-return-value as date      no-undo .
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-parse-date-time-proc in g#attr-lib
    (input  p-string
    ,output p-time
    ,output v-return-value
    ) no-error .
  if error-status :error
  then do:
    return ? .
  end.
  return v-return-value .
end function.
procedure last-check-date-time :
  define input parameter parparentproc as widget-handle no-undo .
  define input parameter p-db-num like ub.cash-desk-attr.db-num no-undo .
  define input parameter p-obj-code like ub.cash-desk-attr.obj-code no-undo .
  define input parameter p-pos-type like ub.cash-desk-attr.pos-type no-undo .
  define input parameter p-cash-num like ub.cash-desk-attr.cash-num no-undo .
  define input-output parameter p-character as character no-undo .
  define input-output parameter p-date      as date      no-undo .
  define input-output parameter p-decimal   as decimal   no-undo .
  define input-output parameter p-integer   as integer   no-undo .
  define input-output parameter p-logical   as logical   no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run last-check-date-time in g#attr-lib
      (input  p-db-num
      ,input  p-obj-code
      ,input  p-pos-type
      ,input  p-cash-num
      ,input-output p-character
      ,input-output p-date
      ,input-output p-decimal
      ,input-output p-integer
      ,input-output p-logical
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
function cd-attr-cd-datetostring returns character
(input  p-date as date
):
  define variable v-return-value as character no-undo .
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-cd-datetostring-proc in g#attr-lib
    (input  p-date
    ,output v-return-value
    ) no-error .
  if error-status :error
  then do:
    return ? .
  end.
  return v-return-value .
end function.
procedure cd-attr-last-report-params :
  define input parameter parparentproc as widget-handle no-undo .
  define input parameter p-db-num like ub.cash-desk-attr.db-num no-undo .
  define input parameter p-obj-code like ub.cash-desk-attr.obj-code no-undo .
  define input parameter p-pos-type like ub.cash-desk-attr.pos-type no-undo .
  define input parameter p-cash-num like ub.cash-desk-attr.cash-num no-undo .
  define input-output parameter p-character as character no-undo .
  define input-output parameter p-date      as date      no-undo .
  define input-output parameter p-decimal   as decimal   no-undo .
  define input-output parameter p-integer   as integer   no-undo .
  define input-output parameter p-logical   as logical   no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-last-report-params in g#attr-lib
      (input  p-db-num
      ,input  p-obj-code
      ,input  p-pos-type
      ,input  p-cash-num
      ,input-output p-character
      ,input-output p-date
      ,input-output p-decimal
      ,input-output p-integer
      ,input-output p-logical
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-last-check-params :
  define input parameter parparentproc as widget-handle no-undo .
  define input parameter p-db-num like ub.cash-desk-attr.db-num no-undo .
  define input parameter p-obj-code like ub.cash-desk-attr.obj-code no-undo .
  define input parameter p-pos-type like ub.cash-desk-attr.pos-type no-undo .
  define input parameter p-cash-num like ub.cash-desk-attr.cash-num no-undo .
  define input-output parameter p-character as character no-undo .
  define input-output parameter p-date      as date      no-undo .
  define input-output parameter p-decimal   as decimal   no-undo .
  define input-output parameter p-integer   as integer   no-undo .
  define input-output parameter p-logical   as logical   no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-last-check-params in g#attr-lib
      (input  p-db-num
      ,input  p-obj-code
      ,input  p-pos-type
      ,input  p-cash-num
      ,input-output p-character
      ,input-output p-date
      ,input-output p-decimal
      ,input-output p-integer
      ,input-output p-logical
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-last-check-date-time :
  define input parameter parparentproc as widget-handle no-undo .
  define input  parameter p-db-num like ub.cash-desk-attr.db-num no-undo .
  define input  parameter p-obj-code like ub.cash-desk-attr.obj-code no-undo .
  define input  parameter p-pos-type like ub.cash-desk-attr.pos-type no-undo .
  define input  parameter p-cash-num like ub.cash-desk-attr.cash-num no-undo .
  define input-output parameter p-character as character no-undo .
  define input-output parameter p-date      as date      no-undo .
  define input-output parameter p-decimal   as decimal   no-undo .
  define input-output parameter p-integer   as integer   no-undo .
  define input-output parameter p-logical   as logical   no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-last-check-maria in g#attr-lib
      (input  p-db-num
      ,input  p-obj-code
      ,input  p-pos-type
      ,input  p-cash-num
      ,input-output p-character
      ,input-output p-date
      ,input-output p-decimal
      ,input-output p-integer
      ,input-output p-logical
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-periodic-tasks :
define input  parameter p-db-num like ub.cash-desk-attr.db-num no-undo .
define input  parameter p-obj-code like ub.cash-desk-attr.obj-code no-undo .
define input  parameter p-pos-type like ub.cash-desk-attr.pos-type no-undo .
define input  parameter p-cash-num like ub.cash-desk-attr.cash-num no-undo .
define input-output parameter p-value as character no-undo .
define output parameter p-setted as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-periodic-tasks in g#attr-lib
      (input  p-db-num
      ,input  p-obj-code
      ,input  p-pos-type
      ,input  p-cash-num
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
function cd-attr_get-attr-int returns integer
(buffer buf_cash-desk for ub.cash-desk
,input p-upper-attr-code as character
,input p-attr-code as character
,output p-mes as character
):
  define variable v-return-value as integer   no-undo .
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr_get-attr-int-proc in g#attr-lib
    (buffer buf_cash-desk
    ,input  p-upper-attr-code
    ,input  p-attr-code
    ,output p-mes
    ,output v-return-value
    ) no-error .
  if error-status :error
  then do:
    assign
      p-mes = substitute("Неизвестная ошибка при вызове процедуры cd-attr_get-attr-int-proc &1 &2"
                        ,error-status :get-message(1)
                        ,return-value
                        )
    .
    return ? .
  end.
  return v-return-value .
end function.
function cd-attr_get-attr-log returns logical
(buffer buf_cash-desk for ub.cash-desk
,input p-upper-attr-code as character
,input p-attr-code as character
,output p-mes as character
):
  define variable v-return-value as logical   no-undo .
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr_get-attr-log-proc in g#attr-lib
    (buffer buf_cash-desk
    ,input  p-upper-attr-code
    ,input  p-attr-code
    ,output p-mes
    ,output v-return-value
    ) no-error .
  if error-status :error
  then do:
    assign
      p-mes = substitute("Неизвестная ошибка при вызове процедуры cd-attr_get-attr-log-proc &1 &2"
                        ,error-status :get-message(1)
                        ,return-value
                        )
    .
    return ? .
  end.
  return v-return-value .
end function.
procedure cd-attr_check-marketer :
  define input parameter p-db-num   like ub.cash-desk-attr.db-num     no-undo .
  define input parameter p-obj-code like ub.cash-desk-attr.obj-code   no-undo .
  define input parameter p-pos-type like ub.cash-desk-attr.pos-type   no-undo .
  define input parameter p-cash-num like ub.cash-desk-attr.cash-num   no-undo .
  define input parameter p-ucode     like ub.cash-desk-attr.upper-attr-code  no-undo .
  define input parameter p-code     like ub.cash-desk-attr.attr-code  no-undo .
  define input parameter p-value as character no-undo .
  define input parameter p-mode  as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr_check-marketer in g#attr-lib
      (input  p-db-num
      ,input  p-obj-code
      ,input  p-pos-type
      ,input  p-cash-num
      ,input  p-ucode
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-manual-edit :
  define input  parameter p-ucode          as character no-undo .
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-manual-edit in g#attr-lib
      (input  p-ucode
      ,input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-batch-edit :
  define input  parameter p-ucode          as character no-undo .
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-batch-edit in g#attr-lib
      (input  p-ucode
      ,input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-send-param :
  define input  parameter p-ucode          as character no-undo .
  define input  parameter p-code           as character no-undo .
  define output parameter p-send-param     as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-send-param in g#attr-lib
      (input  p-ucode
      ,input  p-code
      ,output p-send-param
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
define temp-table temp-menu-toggle no-undo
  field item-code      as integer
  field item-handle    as widget-handle
  index xpk is primary unique item-code
  .
define buffer buf_menu-head      for ub.menu-head .
define variable v-context-list    as character no-undo .
do
on error undo, return error return-value
:
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  case v-cntxt-level
  :
    when 'global':U
    then do:
      assign
        v-context-list = 'global':U
      .
    end.
    when 'firm':U
    then do:
      assign
        v-context-list = 'global':U + chr(44) + 'firm':U
      .
    end.
    when 'object':U
    then do:
      assign
        v-context-list = 'global':U + chr(44) + 'firm':U + chr(44) + 'object':U
      .
    end.
    otherwise do:
      message
        vss-workfile vss-revision vss-description skip
        "Неизвестное значение контекста" skip
        "Контекст" v-cntxt-level skip
        view-as alert-box error .
      undo, return error return-value .
    end.
  end case .
   define variable v-value    as character no-undo .
   define variable v-type     as character no-undo .
   define variable isERPRN as logical no-undo.
    run gbl/conf-rd.p ("is-erpRN", "", "", 0, "", "", "", no, output v-value, output v-type) no-error.
    isERPRN = v-value eq "yes".
  define stream sinp .
  define stream sout .
  create widget-pool .
  run mainmenu-menu-item-clear in parparentproc .
    find first buf_menu-head
       where buf_menu-head.menu-code = p-menu-code
       no-lock
       .
  assign
      p-menu-control-number = buf_menu-head.control-number
  .
  release buf_menu-head.
  run proc-create-menu-item in this-procedure
    (input  0
    ,input  p-menu-handle
    ,input  true
    ,input  true
    ) .
  run mainmenu-menu-item-open in parparentproc
    (input  0
    ) .
end.
procedure proc-create-menu-item :
  define input  parameter p-parent-code   as integer   no-undo .
  define input  parameter p-parent-handle as widget-handle no-undo .
  define input  parameter p-create-menu   as logical   no-undo .
  define input  parameter p-create-browse as logical   no-undo .
  define buffer buf_menu-item for ub.menu-item .
  define buffer buf_temp-menu-toggle for temp-menu-toggle .
  define buffer buf_menu-item-group for ub.menu-item-group .
  define variable v-object-handle         as widget-handle no-undo .
  define variable v-enable-procedure-list as character no-undo .
  define variable v-enable-item           as logical   no-undo .
  define variable v-procedure-enable-item as logical   no-undo .
  define variable v-enable-index          as integer   no-undo .
  define variable v-enable-num-proc       as integer   no-undo .
  define variable v-item-exist            as logical   no-undo .
  define variable v-create-line           as logical   no-undo .
  do
  on error undo, return error return-value
  :
    assign
      v-item-exist  = false
      v-create-line = false
    .
    IF p-menu-code <> 0
    AND NOT CAN-FIND( FIRST buf_menu-item
                      WHERE buf_menu-item.menu-code = p-menu-code
                        AND buf_menu-item.item-code = p-parent-code
                      SHARE-LOCK NO-WAIT
                    ) THEN DO:
       message "Другой пользователь изменил состав меню." SKIP
               "Перезайдите в TradeHouse или повторно выберите группу меню."
       VIEW-AS ALERT-BOX.
       RETURN.
    END.
    create-menu-item :
    for each buf_menu-item no-lock
      where buf_menu-item.menu-code   = p-menu-code
        and buf_menu-item.parent-code = p-parent-code
    by buf_menu-item.item-code
    on error undo create-menu-item, next create-menu-item
    :
      assign
        v-enable-item = true
      .
      assign
        v-enable-procedure-list = '':u
      .
      if buf_menu-item.item-type = 's-m':u
      then do:
        find first buf_menu-item-group no-lock
          where buf_menu-item-group.menu-code       = p-menu-code
            and buf_menu-item-group.item-code       = buf_menu-item.item-code
            and buf_menu-item-group.item-context    = v-cntxt-level
            and buf_menu-item-group.menu-group-code = p-menu-group-code
          no-error .
        if available buf_menu-item-group
        then do:
          assign
            v-enable-procedure-list = buf_menu-item-group.item-condition
          .
        end.
        else do:
          assign
            v-enable-item = false
          .
        end.
      end.
      else do:
        if lookup(string(p-menu-group-code), buf_menu-item.item-group-id) > 0
        then do:
          assign
            v-enable-procedure-list = buf_menu-item.item-condition
          .
        end.
        else do:
          assign
            v-enable-item = false
          .
        end.
      end.
      if  (buf_menu-item.item-type = 'm-i':U
           or
           buf_menu-item.item-type = 'm-t':U
          )
      and v-enable-item = true
      then do:
        if lookup(buf_menu-item.item-context, v-context-list) > 0
        then do:
        end.
        else do:
          assign
            v-enable-item = false
          .
        end.
      end.
      if v-enable-item = true
      then do:
        if  buf_menu-item.item-condition <> ""
        and buf_menu-item.item-condition <> ?
        then do:
          assign
            v-enable-num-proc = num-entries(v-enable-procedure-list, chr(44))
          .
          check_condition:
          do v-enable-index = 1 to v-enable-num-proc
          :
            run value(entry(v-enable-index,v-enable-procedure-list,chr(44))) in this-procedure
              (output v-procedure-enable-item
              ) .
            if v-procedure-enable-item <> true
            then do:
              assign
                v-enable-item = false
              .
              leave check_condition .
            end.
          end.
        end.
      end.
      if v-enable-item = true
      then do:
        if p-create-menu = true
        then do:
          if buf_menu-item.item-type = 'r-l':U
          then do:
            assign
              v-create-line = true
            .
          end.
          else do:
            if  v-item-exist  = true
            and v-create-line = true
            then do:
              create menu-item v-object-handle
              assign
                subtype = "rule"
                parent  = p-parent-handle
              .
            end.
            assign
              v-item-exist  = true
              v-create-line = false
            .
          end.
          case buf_menu-item.item-type
          :
            when 's-m':u
            then do:
              create sub-menu v-object-handle
              assign
                label = buf_menu-item.item-name
                triggers:
                  on menu-drop
                  persistent run run-menu-drop-procedure in this-procedure
                    (input v-object-handle
                    ).
                  end triggers.
              .
              assign
                v-object-handle :private-data = 's-m':u
                                              + chr(44) + string(buf_menu-item.item-code)
              .
            end.
            when 'r-l':u
            then do:
            end.
            when 'm-i':u
            then do:
              create menu-item v-object-handle
              assign
                label = buf_menu-item.item-name
                triggers:
                  on choose
                  persistent run run-menu-item-procedure in this-procedure
                    (input v-object-handle
                    ).
                  end triggers.
              assign
                v-object-handle :private-data = 'm-i':u
                                              + chr(44) + string(buf_menu-item.item-code)
                                              + chr(44) + buf_menu-item.item-procedure
              .
            end.
            when 'm-t':u
            then do:
              create menu-item v-object-handle
              assign
                label        = buf_menu-item.item-name
                toggle-box   = yes
                triggers:
                  on value-changed
                  persistent run run-menu-item-procedure in this-procedure
                    (input v-object-handle
                    ).
                  end triggers.
              assign
                v-object-handle :private-data = 'm-t':u
                                              + chr(44) + string(buf_menu-item.item-code)
                                              + chr(44) + buf_menu-item.item-procedure
              .
              create buf_temp-menu-toggle .
              assign
                buf_temp-menu-toggle.item-code   = buf_menu-item.item-code
                buf_temp-menu-toggle.item-handle = v-object-handle
              .
              define variable v-object-value as logical   no-undo .
              case entry(1, buf_menu-item.item-procedure, chr(44))
              :
                when 'int':u
                then do:
                  run value(entry(2, buf_menu-item.item-procedure, chr(44))) in this-procedure
                    (input 'get':u
                    ,input-output v-object-value
                    ) .
                end.
                when 'ext':u
                then do:
                  run value(entry(2, buf_menu-item.item-procedure, chr(44)))
                    (input 'get':u
                    ,input-output v-object-value
                    ) .
                end.
                otherwise do:
                  message
                    vss-workfile vss-revision vss-description skip
                    "Внутренняя ошибка" skip
                    "Неизвестный тип процедуры в пункте меню" skip
                    buf_menu-item.item-procedure skip
                    view-as alert-box error .
                  undo create-menu-item, next create-menu-item .
                end.
              end case .
              assign
                v-object-handle :checked = v-object-value
              .
            end.
            otherwise do:
              message
                vss-workfile vss-revision vss-description skip
                "Внутренняя ошибка" skip
                "Неизвестный тип пункта меню" buf_menu-item.item-type skip
                view-as alert-box error .
              undo create-menu-item, next create-menu-item .
            end.
          end case .
          if buf_menu-item.item-type <> 'r-l':U
          then do:
            assign
              v-object-handle :parent = p-parent-handle
            .
          end.
        end.
        if  p-create-browse         = true
        and buf_menu-item.item-type <> 'r-l':u
        then do:
          run mainmenu-menu-item-create in parparentproc
            (input buf_menu-item.item-code
            ,input buf_menu-item.item-type
            ,input buf_menu-item.item-name
            ,input buf_menu-item.item-id
            ,input buf_menu-item.item-procedure
            ,input buf_menu-item.parent-code
            ,input true
            ) .
        end.
      end.
    end.
  end.
end procedure.
procedure run-menu-drop-procedure :
  define input  parameter p-item-handle as widget-handle no-undo .
  define variable v-object-handle  as widget-handle no-undo .
  define variable v-item-data      as character no-undo .
  define variable v-item-type      as character no-undo .
  define variable v-procedure-type as character no-undo .
  define variable v-item-procedure as character no-undo .
  do
  on error undo, return error return-value
  :
    assign
      v-item-data = p-item-handle :private-data
    .
    if v-item-data <> 's-m':u
    then do:
      run proc-create-menu-item in this-procedure
        (input  entry(2, v-item-data, chr(44))
        ,input  p-item-handle
        ,input  true
        ,input  false
        ) .
      assign
        p-item-handle :private-data = 's-m':u
      .
    end.
  end.
end procedure.
procedure run-menu-item-procedure :
  define input  parameter p-item-handle as widget-handle no-undo .
  define variable v-item-data           as character no-undo .
  define variable v-item-type           as character no-undo .
  define variable v-item-code           as integer   no-undo .
  define variable v-procedure-type      as character no-undo .
  define variable v-item-procedure      as character no-undo .
  define variable v-procedure-parameter as character no-undo .
  define variable v-cur-date-error-code as integer      no-undo.
  do
  on error undo, return error return-value
  :
    assign
      v-item-data = p-item-handle :private-data
    .
    if num-entries(v-item-data, chr(44)) < 4
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Внутренняя ошибка" skip
        "Ошибка при доступе к внутренним данным пункта меню" skip
        "Количество полей менее четырех" skip
        p-item-handle skip
        p-item-handle :private-data skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    assign
      v-item-type      = entry(1, v-item-data, chr(44))
      v-item-code      = integer(entry(2, v-item-data, chr(44)))
      v-procedure-type = entry(3, v-item-data, chr(44))
      v-item-procedure = entry(4, v-item-data, chr(44))
    .
    if num-entries(v-item-data, chr(44)) > 4
    then do:
      assign
        v-procedure-parameter = entry(5, v-item-data, chr(44))
      .
    end.
    else do:
      assign
        v-procedure-parameter = '':u
      .
    end.
    run mainmenu-show-item in parparentproc
      (input  v-item-code
      ) .
    run dm-menu-choose-item in this-procedure
      (input  v-item-type
      ,input  v-item-code
      ,input  v-procedure-type
      ,input  v-item-procedure
      ,input  v-procedure-parameter
      ) .
    run mainmenu-menu-item-open in parparentproc
      (input v-item-code
      ) .
    if v-item-procedure <> 'm_exit-exe':u
    then do:
      run mainmenu-disp-mutable in parparentproc (
            output v-cur-date-error-code
      ).
    end.
  end.
end procedure.
procedure dm-menu-choose-item :
  define input  parameter p-item-type           as character no-undo .
  define input  parameter p-item-code           as integer   no-undo .
  define input  parameter p-procedure-type      as character no-undo .
  define input  parameter p-item-procedure      as character no-undo .
  define input  parameter p-procedure-parameter as character no-undo .
  define buffer buf_temp-menu-toggle for temp-menu-toggle .
  do
  on error undo, return error return-value
  :
    if transaction = true
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Внутренняя ошибка" skip
        "Активна транзакция при запуске пункта меню" skip
        "Работа будет продолжена" skip
        "В случае отката транзакция пропадет вся работа," skip
        "сделанная в пункте меню" skip
        view-as alert-box error .
    end.
    if p-item-procedure <> 'm_exit-exe':u
    then do:
      run mainmenu-start-item in parparentproc
        (input  p-item-code
        ) .
    end.
    define variable v-message as character no-undo .
    case p-item-type :
      when 'm-i':u
      then do:
        run choose-menu-item in parparentproc .
        do
        on error   undo, leave
        on end-key undo, leave
        on stop    undo, leave
        :
          case p-procedure-type :
            when 'int':u
            then do:
              run run-procedure-int in this-procedure
                (input p-item-procedure
                ) no-error .
              if error-status :error
              then do:
                run menu-item-get-error-message in this-procedure
                  (input  p-menu-code
                  ,input  p-item-code
                  ,input  p-item-procedure
                  ,input  error-status :get-message(1)
                  ,input  return-value
                  ,output v-message
                  ) .
                message
                  "Ошибка при вызове пункта меню" skip
                  v-message skip
                  view-as alert-box error .
              end.
            end.
            when 'ext':u
            then do:
              run run-procedure-ext in this-procedure
                (input p-item-procedure
                ) no-error .
              if error-status :error
              then do:
                run menu-item-get-error-message in this-procedure
                  (input  p-menu-code
                  ,input  p-item-code
                  ,input  p-item-procedure
                  ,input  error-status :get-message(1)
                  ,input  return-value
                  ,output v-message
                  ) .
                message
                  "Ошибка при вызове пункта меню" skip
                  v-message skip
                  view-as alert-box error .
              end.
            end.
            when 'par':u
            then do:
              run run-procedure-par in this-procedure
                (input  p-item-procedure
                ) no-error .
              if error-status :error
              then do:
                run menu-item-get-error-message in this-procedure
                  (input  p-menu-code
                  ,input  p-item-code
                  ,input  p-item-procedure
                  ,input  error-status :get-message(1)
                  ,input  return-value
                  ,output v-message
                  ) .
                message
                  "Ошибка при вызове пункта меню" skip
                  v-message skip
                  view-as alert-box error .
              end.
            end.
            when 'str':u
            then do:
              run run-procedure-str in this-procedure
                (input  p-item-procedure
                ,input  str-decode(p-procedure-parameter, '':u)
                ) no-error .
              if error-status :error
              then do:
                run menu-item-get-error-message in this-procedure
                  (input  p-menu-code
                  ,input  p-item-code
                  ,input  p-item-procedure
                  ,input  error-status :get-message(1)
                  ,input  return-value
                  ,output v-message
                  ) .
                message
                  "Ошибка при вызове пункта меню" skip
                  v-message skip
                  view-as alert-box error .
              end.
            end.
            when 'pst':u
            then do:
              run run-procedure-pst in this-procedure
                (input  p-item-procedure
                ,input  str-decode(p-procedure-parameter, '':u)
                ) no-error .
              if error-status :error
              then do:
                run menu-item-get-error-message in this-procedure
                  (input  p-menu-code
                  ,input  p-item-code
                  ,input  p-item-procedure
                  ,input  error-status :get-message(1)
                  ,input  return-value
                  ,output v-message
                  ) .
                message
                  "Ошибка при вызове пункта меню" skip
                  v-message skip
                  view-as alert-box error .
              end.
            end.
            otherwise do:
              message
                vss-workfile vss-revision vss-description skip
                "Внутренняя ошибка" skip
                "Тип пункта" p-item-type skip
                "Код пункта меню" p-item-code skip
                "Неизвестный тип процедуры" p-procedure-type skip
                "Процедура" p-item-procedure skip
                view-as alert-box error .
            end.
          end case .
        end.
        run deselect-menu-item in parparentproc .
      end.
      when 'm-t':u
      then do:
        define variable v-item-value       as logical   no-undo .
        define variable v-menu-item-handle as widget-handle no-undo .
        case p-procedure-type
        :
          when 'int':u
          then do:
            run value(p-item-procedure) in this-procedure
              (input  'get':u
              ,input-output v-item-value
              ) .
          end.
          otherwise do:
            message
              vss-workfile vss-revision vss-description skip
              "Внутренняя ошибка" skip
              "Код пункта меню" p-item-code skip
              "Неизвестный тип процедуры" p-procedure-type skip
              "Процедура" p-item-procedure skip
              view-as alert-box error .
          end.
        end case .
        assign
          v-item-value = not v-item-value
        .
        case p-procedure-type
        :
          when 'int':u
          then do:
            run value(p-item-procedure) in this-procedure
              (input  'set':u
              ,input-output v-item-value
              ) .
          end.
          otherwise do:
            message
              vss-workfile vss-revision vss-description skip
              "Внутренняя ошибка" skip
              "Код пункта меню" p-item-code skip
              "Неизвестный тип процедуры" p-procedure-type skip
              "Процедура" p-item-procedure skip
              view-as alert-box error .
          end.
        end case .
        find first buf_temp-menu-toggle
          where buf_temp-menu-toggle.item-code = p-item-code
          no-error .
        if available buf_temp-menu-toggle
        then do:
          assign
            v-menu-item-handle = buf_temp-menu-toggle.item-handle
          .
          assign
            v-menu-item-handle :checked = v-item-value
          .
        end.
        run mainmenu-set-menu-toggle in parparentproc
          (input  p-item-code
          ,input  v-item-value
          ) .
      end.
      otherwise do:
        message
          vss-workfile vss-revision vss-description skip
          "Внутренняя ошибка" skip
          "Неизвестный тип пункта меню" p-item-type skip
          "Код пункта меню" p-item-code skip
          "Тип процедуры" p-procedure-type skip
          "Процедура" p-item-procedure skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end.
    if p-item-procedure <> 'm_exit-exe':u
    then do:
      run mainmenu-stop-item in parparentproc .
    end.
  end.
end procedure.
procedure run-procedure-clear-return-value :
  do
  on error undo, return error return-value
  :
    return '':U .
  end.
end procedure.
procedure run-procedure-int :
  define input  parameter p-item-procedure as character no-undo .
  do
  on error undo, retry
  on end-key undo, retry
  on stop undo, retry
  :
    if retry then do:
      message
        "Ошибка при вызове внутренней процедуры" skip
        "Процедура" p-item-procedure skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    run run-procedure-clear-return-value in this-procedure .
    run value(p-item-procedure) in this-procedure .
  end.
end procedure.
procedure run-procedure-ext :
  define input  parameter p-item-procedure as character no-undo .
  do
  on error undo, retry
  on end-key undo, retry
  on stop undo, retry
  :
    if retry then do:
      message
        "Ошибка при вызове внешней процедуры" skip
        "Процедура" p-item-procedure skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    run run-procedure-clear-return-value in this-procedure .
    run value(p-item-procedure) .
  end.
end procedure.
procedure run-procedure-par :
  define input  parameter p-item-procedure as character no-undo .
  do
  on error undo, retry
  on end-key undo, retry
  on stop undo, retry
  :
    if retry then do:
      message
        "Ошибка при вызове внешней процедуры с параметром parparentproc" skip
        "Процедура" p-item-procedure skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    run run-procedure-clear-return-value in this-procedure .
    run value(p-item-procedure)
      (input  parparentproc
      ) .
  end.
end procedure.
procedure run-procedure-str :
  define input  parameter p-item-procedure      as character no-undo .
  define input  parameter p-procedure-parameter as character no-undo .
  do
  on error undo, retry
  on end-key undo, retry
  on stop undo, retry
  :
    if retry then do:
      message
        "Ошибка при вызове внешней процедуры с параметром строка" skip
        "Процедура" p-item-procedure skip
        "Параметр" p-procedure-parameter skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    run run-procedure-clear-return-value in this-procedure .
    run value(p-item-procedure)
      (input p-procedure-parameter
      ) .
  end.
end procedure.
procedure run-procedure-pst :
  define input  parameter p-item-procedure      as character no-undo .
  define input  parameter p-procedure-parameter as character no-undo .
  do
  on error undo, retry
  on end-key undo, retry
  on stop undo, retry
  :
    if retry then do:
      message
        "Ошибка при вызове внешней процедуры с параметрами parparentproc, строка" skip
        "Процедура" p-item-procedure skip
        "Параметр" p-procedure-parameter skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    run run-procedure-clear-return-value in this-procedure .
    run value(p-item-procedure)
      (input  parparentproc
      ,input  p-procedure-parameter
      ) .
  end.
end procedure.
procedure menu-item-get-error-message :
  define input  parameter p-menu-code      as integer   no-undo .
  define input  parameter p-item-code      as integer   no-undo .
  define input  parameter p-item-procedure as character no-undo .
  define input  parameter p-error-message  as character no-undo .
  define input  parameter p-return-value   as character no-undo .
  define output parameter v-message        as character no-undo .
  define buffer buf_menu-item for ub.menu-item .
  define variable v-item-id as character no-undo .
  do
  on error undo, return error return-value
  :
    find first buf_menu-item no-lock
      where buf_menu-item.menu-code = p-menu-code
        and buf_menu-item.item-code = p-item-code
      no-error .
    if available buf_menu-item
    then do:
      assign
        v-item-id = buf_menu-item.item-id
      .
    end.
    else do:
      assign
        v-item-id = substitute('код &1':U, p-item-code)
      .
    end.
    assign
      v-message = substitute('Пункт меню &2&1Процедура &3&1&4&1&5  '
                            ,chr(10)
                            ,v-item-id
                            ,p-item-procedure
                            ,p-error-message
                            ,p-return-value
                            )
    .
  end.
end procedure.
procedure m_sf-new-exe :
  define variable rid# as recid no-undo.
  do on error undo, return error return-value :
    run str/s-f-docs.w ( input parparentproc, input v-cntxt-host-code-obj, "", ?, ?, ?, ?, ?, ?,  input "new", input-output rid# ).
  end.
end procedure.
procedure m_sf-fact-exe :
  define variable rid# as recid no-undo.
  do on error undo, return error return-value :
    run str/s-f-docs.w ( input parparentproc, input v-cntxt-host-code-obj, "", ?, ?, ?, ?, ?, ?,  input "fact", input-output rid# ).
  end.
end procedure.
procedure m_sf-all-exe :
  define variable rid# as recid no-undo.
  do on error undo, return error return-value :
    run str/s-f-docs.w ( input parparentproc, input v-cntxt-host-code-obj, "", ?, ?, ?, ?, ?, ?, input "all", input-output rid# ).
  end.
end procedure.
procedure m_c-fin-doc-del-exe :
define variable p-fin-doc-type like ub.fin-doc.fin-doc-type initial "":U no-undo .
define variable p-status_ like ub.fin-doc.status_ initial "":U no-undo .
define variable v-rid-list as character no-undo .
define variable v-mode as character no-undo .
define variable v-obj-type as character no-undo .
define variable v-obj-code as integer no-undo .
if num-entries(p-fin-doc-type, chr(4)) > 1
and entry(2, p-fin-doc-type, chr(4)) =  'объект':U
then do:
  v-obj-type = v-cntxt-obj-type.
  v-obj-code = v-cntxt-obj-code.
  assign v-mode =  (if p-fin-doc-type = "":U
                     then 'объект':U
                     else (if p-status_ = "":U
                           then "type-object":U
                           else "type-stat-object":U))
  p-fin-doc-type = entry(1, p-fin-doc-type, chr(4))
  .
end.
else do:
  assign v-mode =  (if p-fin-doc-type = "":U
                     then 'фирма':U
                     else (if p-status_ = "":U
                           then "type":U
                           else "type-stat":U))
  .
end.
  do on error undo, return error return-value :
    run str/fincdocdel.w
              (input parparentproc
              ,input v-cntxt-host-code-obj
              ,input v-mode
              ,input 'все':U
              ,input v-cntxt-host-code-obj
              ,input v-obj-type
              ,input v-obj-code
              ,input p-status_
              ,input p-fin-doc-type
              ,input "":U
              ,input ?
              ,input ?
              ,input "":U
              ,input "":U
              ,input 0
              ,input "":U
              ,input "":U
              ,input 0
              ,input "":U
              ,input ?
              ,input 0
              ,input 0
              ,input 0
              ,input 0
              ,input 0
              ,input 0
              ,input 0
    ).
  end.
end procedure.
procedure m_par-obj-auto-exp-exe :
  do
  on error undo, return error return-value
  :
    run wth-docs-exe in this-procedure ('ext-doc-type':U,'рас':U,'ce':U,'':U).
  end.
end procedure.
procedure m_par-obj-auto-inc-exe :
  do
  on error undo, return error return-value
  :
    run wth-docs-exe in this-procedure ('ext-doc-type':U,'при':U,'ci':U,'':U).
  end.
end procedure.
procedure m_par-obj-wrt-new-exe :
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type':U,'спи':U,'we':U,'накл':U) .
  end.
end procedure.
procedure m_par-obj-wrt-fact-exe :
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type':U,'спи':U,'we':U,'факт':U) .
  end.
end procedure.
 procedure m_par-obj-wrt-all-exe :
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type':U,'спи':U,'we':U,'':U) .
  end.
end procedure.
procedure m_par-obj-all-exe :
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('объект':U,'':U,'':U ,'':U) .
  end.
end procedure.
procedure m_par-cmp-all-exe :
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('фирма':U,'':U,'':U, '':U) .
  end.
end procedure.
procedure m_par-all-all-exe :
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('все':U,'':U,'':U,'':U) .
  end.
end procedure.
procedure m_wth-obj-ext-in-new-exe :
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type','при':U,'ie':U,'накл':U) .
  end.
end procedure.
procedure m_wth-obj-ext-in-fact-exe :
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type','при':U,'ie':U,'факт':U) .
  end.
end procedure.
procedure m_wth-obj-ext-in-all-exe :
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type','при':U,'ie':U,'':U) .
  end.
end procedure.
procedure m_wth-obj-inc-in-zp-new-exe
 :
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type','при':U,'ip':U,'накл':U) .
  end.
end procedure.
procedure m_wth-obj-inc-in-zp-fact-exe :
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type','при':U,'ip':U,'факт':U) .
  end.
end procedure.
procedure m_wth-obj-inc-in-zp-all-exe:
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type','при':U,'ip':U,'':U) .
  end.
end procedure.
procedure m_wth-obj-inc-in-fr-new-exe
 :
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type','при':U,'ff':U,'накл':U) .
  end.
end procedure.
procedure m_wth-obj-inc-in-fr-fact-exe :
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type','при':U,'ff':U,'факт':U) .
  end.
end procedure.
procedure m_wth-obj-inc-in-fr-all-exe:
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type','при':U,'ff':U,'':U) .
  end.
end procedure.
procedure m_wth-obj-inc-in-new-exe
 :
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type','при':U,'ii':U,'накл':U) .
  end.
end procedure.
procedure m_wth-obj-inc-in-fact-exe :
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type','при':U,'ii':U,'факт':U) .
  end.
end procedure.
procedure m_wth-obj-inc-in-all-exe:
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type','при':U,'ii':U,'':U) .
  end.
end procedure.
procedure m_wth-obj-ext-out-new-exe
 :
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type','рас':U,'ee':U,'накл':U) .
  end.
end procedure.
procedure m_wth-obj-ext-out-fact-exe :
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type','рас':U,'ee':U,'факт':U) .
  end.
end procedure.
procedure m_wth-obj-ext-out-all-exe:
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type','рас':U,'ee':U,'все':U) .
  end.
end procedure.
procedure m_wth-obj-inc-out-zp-new-exe
 :
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type','рас':U,'ep':U,'накл':U) .
  end.
end procedure.
procedure m_wth-obj-inc-out-zp-fact-exe :
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type','рас':U,'ep':U,'факт':U) .
  end.
end procedure.
procedure m_wth-obj-inc-out-zp-all-exe:
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type','рас':U,'ep':U,'все':U) .
  end.
end procedure.
procedure m_wth-obj-inc-out-fr-new-exe
 :
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type','рас':U,'ef':U,'накл':U) .
  end.
end procedure.
procedure m_wth-obj-inc-out-fr-fact-exe :
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type','рас':U,'ef':U,'факт':U) .
  end.
end procedure.
procedure m_wth-obj-inc-out-fr-all-exe:
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type','рас':U,'ef':U,'все':U) .
  end.
end procedure.
procedure m_wth-obj-inc-out-new-exe
 :
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type','рас':U,'ei':U,'накл':U) .
  end.
end procedure.
procedure m_wth-obj-inc-out-fact-exe :
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type','рас':U,'ei':U,'факт':U) .
  end.
end procedure.
procedure m_wth-obj-inc-out-all-exe:
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type','рас':U,'ei':U,'все':U) .
  end.
end procedure.
procedure m_wth-obj-inj-out-new-exe
 :
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type','рас':U,'ej':U,'накл':U) .
  end.
end procedure.
procedure m_wth-obj-inj-out-fact-exe :
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type','рас':U,'ej':U,'факт':U) .
  end.
end procedure.
procedure m_wth-obj-inj-out-all-exe:
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type','рас':U,'ej':U,'все':U) .
  end.
end procedure.
procedure m_wth-obj-inj-in-new-exe
 :
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type','при':U,'ij':U,'накл':U) .
  end.
end procedure.
procedure m_wth-obj-inj-in-fact-exe :
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type','при':U,'ij':U,'факт':U) .
  end.
end procedure.
procedure m_wth-obj-inj-in-all-exe:
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type','при':U,'ij':U,'все':U) .
  end.
end procedure.
procedure m_wth-obj-inj-out-free-new-exe
 :
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type','рас':U,'jj':U,'накл':U) .
  end.
end procedure.
procedure m_wth-obj-inj-out-free-fact-exe :
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type','рас':U,'jj':U,'факт':U) .
  end.
end procedure.
procedure m_wth-obj-inj-out-free-all-exe:
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type','рас':U,'jj':U,'все':U) .
  end.
end procedure.
procedure m_wth-obj-inj-in-free-new-exe
 :
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type','при':U,'fj':U,'накл':U) .
  end.
end procedure.
procedure m_wth-obj-inj-in-free-fact-exe :
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type','при':U,'fj':U,'факт':U) .
  end.
end procedure.
procedure m_wth-obj-inj-in-free-all-exe:
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type','при':U,'fj':U,'все':U) .
  end.
end procedure.
procedure m_wth-obj-inj-out-put-new-exe
 :
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type','рас':U,'oj':U,'накл':U) .
  end.
end procedure.
procedure m_wth-obj-inj-out-Put-fact-exe :
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type','рас':U,'oj':U,'факт':U) .
  end.
end procedure.
procedure m_wth-obj-inj-out-Put-all-exe:
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type','рас':U,'oj':U,'все':U) .
  end.
end procedure.
procedure m_wth-obj-inj-in-Put-new-exe
 :
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type','при':U,'pj':U,'накл':U) .
  end.
end procedure.
procedure m_wth-obj-inj-in-Put-fact-exe :
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type','при':U,'pj':U,'факт':U) .
  end.
end procedure.
procedure m_wth-obj-inj-in-Put-all-exe:
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type','при':U,'pj':U,'все':U) .
  end.
end procedure.
procedure m_wth-obj-inc-ret-zp-new-exe
 :
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type','возврат':U,'rp':U,'накл':U) .
  end.
end procedure.
procedure m_wth-obj-inc-ret-zp-fact-exe :
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type','возврат':U,'rp':U,'факт':U) .
  end.
end procedure.
procedure m_wth-obj-inc-ret-zp-all-exe:
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type','возврат':U,'rp':U,'все':U) .
  end.
end procedure.
procedure m_wth-obj-inc-ret-fr-new-exe
 :
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type','возврат':U,'rf':U,'накл':U) .
  end.
end procedure.
procedure m_wth-obj-inc-ret-fr-fact-exe :
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type','возврат':U,'rf':U,'факт':U) .
  end.
end procedure.
procedure m_wth-obj-inc-ret-fr-all-exe:
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type','возврат':U,'rf':U,'все':U) .
  end.
end procedure.
procedure m_wth-obj-inc-ret-new-exe
 :
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type','возврат':U,'rj':U,'накл':U) .
  end.
end procedure.
procedure m_wth-obj-inc-ret-fact-exe :
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type','возврат':U,'rj':U,'факт':U) .
  end.
end procedure.
procedure m_wth-obj-inc-ret-all-exe:
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type','возврат':U,'rj':U,'все':U) .
  end.
end procedure.
procedure m_wth-obj-put-ch-all-exe:
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type','при':U,'pc':U,'все':U) .
  end.
end procedure.
procedure m_wth-obj-put-sl-new-exe
 :
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type','при':U,'ps':U,'накл':U) .
  end.
end procedure.
procedure m_wth-obj-put-sl-fact-exe :
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type','при':U,'ps':U,'факт':U) .
  end.
end procedure.
procedure m_wth-obj-put-sl-all-exe:
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type','при':U,'ps':U,'все':U) .
  end.
end procedure.
procedure m_wth-obj-put-zc-new-exe
 :
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type','при':U,'pz':U,'накл':U) .
  end.
end procedure.
procedure m_wth-obj-put-zc-fact-exe :
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type','при':U,'pz':U,'факт':U) .
  end.
end procedure.
procedure m_wth-obj-put-zc-all-exe:
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type','при':U,'pz':U,'все':U) .
  end.
end procedure.
procedure m_wth-obj-ex-new-exe
 :
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type','обмен':U,'xc':U,'накл':U) .
  end.
end procedure.
procedure m_wth-obj-ex-fact-exe :
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type','обмен':U,'xc':U,'факт':U) .
  end.
end procedure.
procedure m_wth-obj-ex-all-exe:
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type','обмен':U,'xc':U,'все':U) .
  end.
end procedure.
procedure m_wth-obj-dst-zf-new-exe
 :
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type','спи':U,'df':U,'накл':U) .
  end.
end procedure.
procedure m_wth-obj-dst-zf-fact-exe :
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type','спи':U,'df':U,'факт':U) .
  end.
end procedure.
procedure m_wth-obj-dst-zf-all-exe:
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type','спи':U,'df':U,'все':U) .
  end.
end procedure.
procedure m_wth-obj-dst-zp-new-exe
 :
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type','спи':U,'dp':U,'накл':U) .
  end.
end procedure.
procedure m_wth-obj-dst-zp-fact-exe :
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type','спи':U,'dp':U,'факт':U) .
  end.
end procedure.
procedure m_wth-obj-dst-zp-all-exe:
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type','спи':U,'dp':U,'все':U) .
  end.
end procedure.
procedure m_wth-obj-dst-zc-new-exe
 :
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type','спи':U,'dc':U,'накл':U) .
  end.
end procedure.
procedure m_wth-obj-dst-zc-fact-exe :
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type','спи':U,'dc':U,'факт':U) .
  end.
end procedure.
procedure m_wth-obj-dst-zc-all-exe:
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type','спи':U,'dc':U,'все':U) .
  end.
end procedure.
procedure m_par-obj-inv-exe :
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type':U,'инв':U,'iy':U,'':U) .
  end.
end procedure.
procedure m_par-obj-dec-exe :
  do
  on error undo, return error return-value
  :
    run wth-docs-exe('ext-doc-type':U,'декл':U,'de':U,'':U) .
  end.
end procedure.
procedure m_c-wth-doc-obj-all-exe :
  do
  on error undo, return error return-value
  :
    run c-wth-doc-exe('объект':U, '':U) .
  end.
end procedure.
procedure m_c-wth-doc-cmp-all-exe :
  do
  on error undo, return error return-value
  :
    run c-wth-doc-exe('фирма':U, '':U) .
  end.
end procedure.
procedure m_c-wth-doc-all-all-exe :
  do
  on error undo, return error return-value
  :
    run c-wth-doc-exe('все':U, '':U) .
  end.
end procedure.
procedure c-obj-ext-in-exe :
  do
  on error undo, return error return-value
  :
    run dm-c-doc-exe in this-procedure (INPUT 'УД_ТИП':U, INPUT ?, INPUT '?', INPUT 'при':U, INPUT no, INPUT 'ie':U, input ? ) .
  end.
end procedure.
procedure c-obj-ext-in-ho-exe :
  do
  on error undo, return error return-value
  :
    run dm-c-doc-exe in this-procedure (INPUT 'УД_ТИП':U, INPUT ?, INPUT '?', INPUT 'при':U, INPUT no, INPUT 'ie':U, input no) .
  end.
end procedure.
procedure c-obj-ext-out-exe :
  do
  on error undo, return error return-value
  :
    run dm-c-doc-exe in this-procedure (INPUT 'УД_ТИП':U, INPUT ?, INPUT '?', INPUT 'рас':U, INPUT no, INPUT 'ee':U, input ? ) .
  end.
end procedure.
procedure c-obj-ext-out-ho-exe :
  do
  on error undo, return error return-value
  :
    run dm-c-doc-exe in this-procedure (INPUT 'УД_ТИП':U, INPUT ?, INPUT '?', INPUT 'рас':U, INPUT no, INPUT 'ee':U, input no) .
  end.
end procedure.
procedure c-obj-ext-out-kass-all-exe :
  do
  on error undo, return error return-value
  :
    run dm-c-doc-exe in this-procedure (INPUT 'УД_ТИП':U, INPUT ?, INPUT '?', INPUT 'рас':U, INPUT no, INPUT 'es':U, input ? ) .
  end.
end procedure.
procedure c-obj-ext-sup-exe :
  do
  on error undo, return error return-value
  :
    run dm-c-doc-exe in this-procedure (INPUT 'УД_ТИП':U, INPUT ?, INPUT '?', INPUT 'рас':U, INPUT no, INPUT 'ep':U, input ? ) .
  end.
end procedure.
procedure c-obj-ext-sup-ho-exe :
  do on error undo, return error return-value :
    run dm-c-doc-exe in this-procedure ( input 'УД_ТИП':U,
                                         input ?,
                                         input '?',
                                         input 'рас':U,
                                         input no,
                                         input 'ep':U,
                                         input no ).
  end.
end procedure.
procedure c-obj-ext-ret-exe :
  do
  on error undo, return error return-value
  :
    run dm-c-doc-exe in this-procedure (INPUT 'УД_ТИП':U, INPUT ?, INPUT '?', INPUT 'возврат':U, INPUT no, INPUT 're':U, input ? ) .
  end.
end procedure.
procedure c-obj-ext-ret-ho-exe :
  do on error undo, return error return-value :
    run dm-c-doc-exe in this-procedure ( input 'УД_ТИП':U,
                                         input ?,
                                         input '?',
                                         input 'возврат':U,
                                         input no,
                                         input 're':U,
                                         input no ).
  end.
end procedure.
procedure c-obj-ext-retc-all-exe :
  do
  on error undo, return error return-value
  :
    run dm-c-doc-exe in this-procedure (INPUT 'УД_ТИП':U, INPUT ?, INPUT '?', INPUT 'возврат':U, INPUT no, INPUT 'rs':U, input ? ) .
  end.
end procedure.
procedure c-obj-aw-exe :
  do
  on error undo, return error return-value
  :
    run dm-c-doc-exe in this-procedure (INPUT 'УД_ТИП':U, INPUT ?, INPUT '?', INPUT 'спи':U, INPUT no, INPUT 'we':U, input ? ) .
  end.
end procedure.
procedure c-obj-cpc-exe :
  do
  on error undo, return error return-value
  :
  run dm-c-doc-exe in this-procedure (INPUT 'УД_ТИП':U, INPUT ?, INPUT '?', INPUT 'инв':U, INPUT no,  INPUT 'pc':U, INPUT ? ).
  end.
end procedure.
procedure c-obj-cmp-exe :
  do
  on error undo, return error return-value
  :
  run dm-c-doc-exe in this-procedure (INPUT 'УД_ТИП':U, INPUT ?, INPUT '?', INPUT 'инв':U, INPUT no,  INPUT 'mp':U, INPUT ? ).
  end.
end procedure.
procedure c-obj-in-in-exe :
  do
  on error undo, return error return-value
  :
    run dm-c-doc-exe in this-procedure (INPUT 'УД_ТИП':U, INPUT ?, INPUT '?', INPUT 'при':U, INPUT yes, INPUT 'iv':U, input ? ) .
  end.
end procedure.
procedure c-obj-in-out-exe :
  do
  on error undo, return error return-value
  :
    run dm-c-doc-exe in this-procedure (INPUT 'УД_ТИП':U, INPUT ?, INPUT '?', INPUT 'рас':U, INPUT yes, INPUT 'ev':U, input ? ) .
  end.
end procedure.
procedure c-obj-in-ret-exe :
  do
  on error undo, return error return-value
  :
    run dm-c-doc-exe in this-procedure (INPUT 'УД_ТИП':U, INPUT ?, INPUT '?', INPUT 'возврат':U, INPUT yes, INPUT 'rv':U, input ? ) .
  end.
end procedure.
procedure c-obj-in-prvo-exe :
  do
  on error undo, return error return-value
  :
    run dm-c-doc-exe in this-procedure (INPUT 'УД_ТИП':U, INPUT ?, INPUT '?', INPUT 'при':U, INPUT yes, INPUT 'im':U, input ? ) .
  end.
end procedure.
procedure c-obj-spis-prv-exe :
  do
  on error undo, return error return-value
  :
    run dm-c-doc-exe in this-procedure (INPUT 'УД_ТИП':U, INPUT ?, INPUT '?', INPUT 'спи':U, INPUT yes, INPUT 'wm':U, input ? ) .
  end.
end procedure.
procedure c-obj-all-exe :
  do
  on error undo, return error return-value
  :
    run dm-c-doc-exe in this-procedure (INPUT 'уд_объект':U, INPUT ?, INPUT '?', INPUT '?', INPUT ?, INPUT 'rv':U, input ? ) .
  end.
end procedure.
procedure c-m-host-exe :
  do
  on error undo, return error return-value
  :
    run dm-c-doc-exe in this-procedure (INPUT 'уд_фирма':U, INPUT ?, INPUT '?', INPUT '?', INPUT ?, INPUT 'rv':U, input ? ) .
  end.
end procedure.
procedure m-a-f-n1-exe :
  do
  on error undo, return error return-value
  :
    run cus/ord-pos.p (parparentproc, 'obj':U , 'ОФ':U , 'новый':U ) .
  end.
end procedure.
procedure m-all-of-u-exe :
  do
  on error undo, return error return-value
  :
    run cus/ord-pos.p (parparentproc, 'firm':U,'ОФ':U,'согласование':U) .
  end.
end procedure.
procedure m-all-of-o-exe :
  do
  on error undo, return error return-value
  :
    run cus/ord-pos.p (parparentproc, 'firm':U,'ОФ':U,'отказ':U) .
  end.
end procedure.
procedure m-all-of-u1-exe :
  do
  on error undo, return error return-value
  :
    run cus/ord-pos.p (parparentproc, 'firm':U,'ОФ':U,'поставка':U) .
  end.
end procedure.
procedure m-all-of-u2-exe :
  do
  on error undo, return error return-value
  :
    run cus/ord-pos.p (parparentproc, 'firm':U,'ОФ':U,'закрыто':U) .
  end.
end procedure.
procedure m-all-of-fact-exe :
  do
  on error undo, return error return-value
  :
    run cus/ord-pos.p (parparentproc, 'firm':U,'ОФ':U,'факт':U) .
  end.
end procedure.
procedure m-all-of-all-exe :
  do
  on error undo, return error return-value
  :
    run cus/ord-pos.p (parparentproc, 'firm':U,'ОФ':U,'all':U) .
  end.
end procedure.
procedure m-allsupp1-of-new-exe :
  do
  on error undo, return error return-value
  :
    run cus/ord-pos.p (parparentproc, 'obj':U,'ОФ':U,'новый':U) .
  end.
end procedure.
procedure m-allsupp1-of-u-exe :
  do
  on error undo, return error return-value
  :
    run cus/ord-pos.p (parparentproc, 'obj':U,'ОФ':U,'согласование':U) .
  end.
end procedure.
procedure m-allsupp1-of-o1-exe :
  do
  on error undo, return error return-value
  :
    run cus/ord-pos.p (parparentproc, 'obj':U,'ОФ':U,'отказ':U) .
  end.
end procedure.
procedure m-allsupp1-of-o2-exe :
  do
  on error undo, return error return-value
  :
    run cus/ord-pos.p (parparentproc, 'obj':U,'ОФ':U,'поставка':U) .
  end.
end procedure.
procedure m-allsupp1-of-o3-exe :
  do
  on error undo, return error return-value
  :
    run cus/ord-pos.p (parparentproc, 'obj':U,'ОФ':U,'закрыто':U) .
  end.
end procedure.
procedure m-allsupp1-of-fact-exe :
  do
  on error undo, return error return-value
  :
    run cus/ord-pos.p (parparentproc, 'obj':U,'ОФ':U,'факт':U) .
  end.
end procedure.
procedure m-allsupp1-of-all-exe :
  do
  on error undo, return error return-value
  :
    run cus/ord-pos.p (parparentproc, 'obj':U,'ОФ':U,'all':U) .
  end.
end procedure.
procedure m-all-suppfp-new-exe :
  do
  on error undo, return error return-value
  :
    run cus/ord-pos.p (parparentproc, 'obj':U,'ОП':U,'новый':U) .
  end.
end procedure.
procedure m-all-suppfp-razr1-exe :
  do
  on error undo, return error return-value
  :
    run cus/ord-pos.p (parparentproc, 'obj':U,'ОП':U,'согласование':U) .
  end.
end procedure.
procedure m-all-suppfp-razr2-exe :
  do
  on error undo, return error return-value
  :
    run cus/ord-pos.p (parparentproc, 'obj':U,'ОП':U,'отказ':U) .
  end.
end procedure.
procedure m-all-suppfp-razr3-exe :
  do
  on error undo, return error return-value
  :
    run cus/ord-pos.p (parparentproc, 'obj':U,'ОП':U,'поставка':U) .
  end.
end procedure.
procedure m-all-suppfp-razr4-exe :
  do
  on error undo, return error return-value
  :
    run cus/ord-pos.p (parparentproc, 'obj':U,'ОП':U,'закрыто':U) .
  end.
end procedure.
procedure m-all-suppfp-fact-exe :
  do
  on error undo, return error return-value
  :
    run cus/ord-pos.p (parparentproc, 'obj':U,'ОП':U,'факт':U) .
  end.
end procedure.
procedure m-all-suppfp-all-exe :
  do
  on error undo, return error return-value
  :
    run cus/ord-pos.p (parparentproc, 'obj':U,'ОП':U,'all':U) .
  end.
end procedure.
procedure m-all-suppfp-new-f-exe :
  do
  on error undo, return error return-value
  :
    run cus/ord-pos.p (parparentproc, 'firm':U,'ОП':U,'новый':U) .
  end.
end procedure.
procedure m-all-suppfp-razr-f1-exe :
  do
  on error undo, return error return-value
  :
    run cus/ord-pos.p (parparentproc, 'firm':U,'ОП':U,'согласование':U) .
  end.
end procedure.
procedure m-all-suppfp-razr-f2-exe :
  do
  on error undo, return error return-value
  :
    run cus/ord-pos.p (parparentproc, 'firm':U,'ОП':U,'отказ':U) .
  end.
end procedure.
procedure m-all-suppfp-razr-f3-exe :
  do
  on error undo, return error return-value
  :
    run cus/ord-pos.p (parparentproc, 'firm':U,'ОП':U,'поставка':U) .
  end.
end procedure.
procedure m-all-suppfp-razr-f4-exe :
  do
  on error undo, return error return-value
  :
    run cus/ord-pos.p (parparentproc, 'firm':U,'ОП':U,'закрыто':U) .
  end.
end procedure.
procedure m-all-suppfp-fact-f5-exe :
  do
  on error undo, return error return-value
  :
    run cus/ord-pos.p (parparentproc, 'firm':U,'ОП':U,'факт':U) .
  end.
end procedure.
procedure m-all-oo-new-exe :
  do
  on error undo, return error return-value
  :
    run cus/ord-pos.p (parparentproc, 'obj':U,'ОО':U,'новый':U) .
  end.
end procedure.
procedure m-all-oo-razr-exe :
  do
  on error undo, return error return-value
  :
    run cus/ord-pos.p (parparentproc, 'obj':U,'ОО':U,'запрос':U) .
  end.
end procedure.
procedure m-all-oo-fact-exe :
  do
  on error undo, return error return-value
  :
    run cus/ord-pos.p (parparentproc, 'obj':U,'ОО':U,'факт':U) .
  end.
end procedure.
procedure m-all-oo-all-exe :
  do
  on error undo, return error return-value
  :
    run cus/ord-pos.p (parparentproc, 'obj':U,'ОО':U,'all':U) .
  end.
end procedure.
procedure m-all-suppfp-all-f-exe :
  do
  on error undo, return error return-value
  :
    run cus/ord-pos.p (parparentproc, 'firm':U,'ОП':U,'all':U) .
  end.
end procedure.
procedure m-all-fp-new-exe :
  do
  on error undo, return error return-value
  :
    run cus/ord-pos.p (parparentproc, 'firm':U,'ФП':U,'новый':U) .
  end.
end procedure.
procedure m-all-fp-razr-exe :
  do
  on error undo, return error return-value
  :
    run cus/ord-pos.p (parparentproc, 'firm':U,'ФП':U,'поставка':U) .
  end.
end procedure.
procedure m-all-fp-cl-exe :
  do
  on error undo, return error return-value
  :
    run cus/ord-pos.p (parparentproc, 'firm':U,'ФП':U,'закрыто':U) .
  end.
end procedure.
procedure m-all-fp-fact-exe :
  do
  on error undo, return error return-value
  :
    run cus/ord-pos.p (parparentproc, 'firm':U,'ФП':U,'факт':U) .
  end.
end procedure.
procedure m-all-fp-all-exe :
  do
  on error undo, return error return-value
  :
    run cus/ord-pos.p (parparentproc, 'firm':U,'ФП':U,'all':U) .
  end.
end procedure.
procedure ord-supp-all-exe :
  do
  on error undo, return error return-value
  :
    run cus/ord-pos.p (parparentproc, 'obj':U,'all':U,'all':U) .
  end.
end procedure.
procedure m-all-af-exe :
  do
  on error undo, return error return-value
  :
    run cus/ord-pos.p (parparentproc, 'firm':U,'all':U,'all':U) .
  end.
end procedure.
procedure m-all-recive1-conso1-exe :
  do
  on error undo, return error return-value
  :
    run cus/ord-cons.w (parparentproc , 'новый':U , "obj":U ) .
  end.
end procedure.
procedure m-all-recive1-conso2-exe :
  do
  on error undo, return error return-value
  :
    run cus/ord-cons.w (parparentproc , 'распределение':U , "obj":U ) .
  end.
end procedure.
procedure m-all-recive1-conso3-exe :
  do
  on error undo, return error return-value
  :
    run cus/ord-cons.w (parparentproc , 'закрыто':U , "obj":U ) .
  end.
end procedure.
procedure m-all-recive1-conso4-exe :
  do
  on error undo, return error return-value
  :
    run cus/ord-cons.w (parparentproc , 'факт':U , "obj":U ) .
  end.
end procedure.
procedure m-all-recive1-conso5-exe :
  do
  on error undo, return error return-value
  :
    run cus/ord-cons.w (parparentproc , "all":U , "obj":U ) .
  end.
end procedure.
procedure m-all-recive1-cons1-exe :
  do
  on error undo, return error return-value
  :
    run cus/ord-cons.w (parparentproc , 'новый':U , "firm":U ) .
  end.
end procedure.
procedure m-all-recive1-cons2-exe :
  do
  on error undo, return error return-value
  :
    run cus/ord-cons.w (parparentproc , 'распределение':U , "firm":U ) .
  end.
end procedure.
procedure m-all-recive1-cons3-exe :
  do
  on error undo, return error return-value
  :
    run cus/ord-cons.w (parparentproc , 'закрыто':U , "firm":U ) .
  end.
end procedure.
procedure m-all-recive1-cons4-exe :
  do
  on error undo, return error return-value
  :
    run cus/ord-cons.w (parparentproc , 'факт':U , "firm":U ) .
  end.
end procedure.
procedure m-all-recive1-cons5-exe :
  do
  on error undo, return error return-value
  :
    run cus/ord-cons.w (parparentproc , 'all':U , "firm":U ) .
  end.
end procedure.
procedure m-all-recive1-4-exe :
  do
  on error undo, return error return-value
  :
    run cus/ord-rcv.p (parparentproc , 'obj':U,'out':U,'поставка':U) .
  end.
end procedure.
procedure m-all-recive1-2-exe :
  do
  on error undo, return error return-value
  :
    run cus/ord-rcv.p ( parparentproc , 'obj':U,'out':U,'факт':U) .
  end.
end procedure.
procedure m-all-recive1-3-exe :
  do
  on error undo, return error return-value
  :
    run cus/ord-rcv.p (parparentproc , 'obj':U,'out':U,'all':U) .
  end.
end procedure.
procedure m-all-recive2-2-exe :
  do
  on error undo, return error return-value
  :
    run cus/ord-rcv.p (parparentproc , 'obj':U,'in':U,'поставка':U) .
  end.
end procedure.
procedure m-all-recive2-4-exe :
  do
  on error undo, return error return-value
  :
    run cus/ord-rcv.p (parparentproc , 'obj':U,'in':U,'факт':U) .
  end.
end procedure.
procedure m-all-recive2-3-exe :
  do
  on error undo, return error return-value
  :
    run cus/ord-rcv.p (parparentproc , 'obj':U,'in':U,'all':U) .
  end.
end procedure.
procedure m-all-recive1-1-2-exe :
  do
  on error undo, return error return-value
  :
    run cus/ord-rcv.p (parparentproc , 'firm':U,'out':U,'новый':U) .
  end.
end procedure.
procedure m-all-recive1-4-2-exe :
  do
  on error undo, return error return-value
  :
    run cus/ord-rcv.p (parparentproc , 'firm':U,'out':U,'поставка':U) .
  end.
end procedure.
procedure m-all-recive1-2-2-exe :
  do
  on error undo, return error return-value
  :
    run cus/ord-rcv.p (parparentproc , 'firm':U,'out':U,'факт':U) .
  end.
end procedure.
procedure m-all-recive1-3-2-exe :
  do
  on error undo, return error return-value
  :
    run cus/ord-rcv.p (parparentproc , 'firm':U,'out':U,'all':U) .
  end.
end procedure.
procedure m-all-recive2-1-2-exe :
  do
  on error undo, return error return-value
  :
    run cus/ord-rcv.p (parparentproc , 'firm':U,'in':U,'новый':U) .
  end.
end procedure.
procedure m-all-recive2-2-2-exe :
  do
  on error undo, return error return-value
  :
    run cus/ord-rcv.p (parparentproc , 'firm':U,'in':U,'поставка':U) .
  end.
end procedure.
procedure m-all-recive2-4-2-exe :
  do
  on error undo, return error return-value
  :
    run cus/ord-rcv.p (parparentproc , 'firm':U,'in':U,'факт':U) .
  end.
end procedure.
procedure m-all-recive2-3-2-exe :
  do
  on error undo, return error return-value
  :
    run cus/ord-rcv.p (parparentproc , 'firm':U,'in':U,'all':U) .
  end.
end procedure.
procedure m-all-recive02-2-exe :
  do
  on error undo, return error return-value
  :
    run cus/ord-rcv.p (parparentproc , 'cli':U,'in':U,'поставка':U) .
  end.
end procedure.
procedure m-all-recive02-4-exe :
  do
  on error undo, return error return-value
  :
    run cus/ord-rcv.p (parparentproc , 'cli':U,'in':U,'факт':U) .
  end.
end procedure.
procedure m-all-recive02-3-exe :
  do
  on error undo, return error return-value
  :
    run cus/ord-rcv.p (parparentproc , 'cli':U,'in':U,'all':U) .
  end.
end procedure.
procedure m-all-recive3-exe :
  do
  on error undo, return error return-value
  :
    run cus/ord-rcv.p (parparentproc , 'obj':U,'all':U,'all':U) .
  end.
end procedure.
procedure m-all-recive4-exe :
  do
  on error undo, return error return-value
  :
    run cus/ord-rcv.p ( parparentproc , 'firm':U,'all':U,'all':U) .
  end.
end procedure.
procedure obj-pln-new-exe :
  do
  on error undo, return error return-value
  :
    run str/fbr-plns.w
      (input  parparentproc
      ,input  'новый':U
      ,input  v-cntxt-obj-type
      ,input  v-cntxt-obj-code
      ,input  v-cntxt-userid
      ) .
  end.
end procedure.
procedure obj-pln-permitted-exe :
  do
  on error undo, return error return-value
  :
    run str/fbr-plns.w
      (input  parparentproc
      ,input  'разрешен':U
      ,input  v-cntxt-obj-type
      ,input  v-cntxt-obj-code
      ,input  v-cntxt-userid
      ) .
  end.
end procedure.
procedure obj-pln-closed-exe :
  do
  on error undo, return error return-value
  :
    run str/fbr-plns.w
      (input  parparentproc
      ,input  'факт':U
      ,input  v-cntxt-obj-type
      ,input  v-cntxt-obj-code
      ,input  v-cntxt-userid
      ) .
  end.
end procedure.
procedure proc-fbr-doc :
define input parameter p-status as character no-undo .
define input parameter p-list-mode as character no-undo .
define variable v-rid-list as character no-undo .
  do
  on error undo, return error
  :
    run str/fbr-docs.w
      (input  parparentproc
      ,input  p-status
      ,input  p-list-mode
      ,input-output v-rid-list
      ) .
  end.
end procedure.
procedure obj-fbr-new-exe :
    run proc-fbr-doc in this-procedure (
          input 'новый':U
        , input 'статус':U
    ).
end procedure.
procedure obj-fbr-perm-exe :
    run proc-fbr-doc in this-procedure (
          input 'разрешен':U
        , input 'статус':U
    ).
end procedure.
procedure obj-fbr-close-exe :
    run proc-fbr-doc in this-procedure (
          input 'факт':U
        , input 'статус':U
    ).
end procedure.
procedure obj-fbr-froze-exe :
    run proc-fbr-doc in this-procedure (
          input 'статус':U
        , input 'нередакт':U
    ).
end procedure.
procedure obj-fbr-exe :
    run proc-fbr-doc in this-procedure (
          input "":U
        , input 'объект':U
    ).
end procedure.
procedure firm-fbr-exe :
    run proc-fbr-doc in this-procedure (
          input "":U
        , input 'фирма':U
    ).
end procedure.
procedure proc-cash-gds :
define input parameter p-mode as character no-undo .
  define variable v-host-code as integer no-undo .
  do
  on error undo, return error return-value
  :
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-host-code
  )  .
    run str/gds-cash.p (
                     input parparentproc
                   , input v-host-code
                   , input v-cntxt-obj-type
                   , input v-cntxt-obj-code
                   , p-mode) .
  end.
end procedure.
procedure m-cash-gds-exe :
run proc-cash-gds in this-procedure ('cash').
end procedure.
procedure m-infokiosk-exe :
run proc-cash-gds in this-procedure ('InfoKiosk':U).
end procedure.
procedure m_lst-inv-exe :
run proc-cash-gds in this-procedure ('qnty').
end procedure.
procedure m-cash-KKT-with-exe :
   run str/diallog.w (
      input parparentproc
      , input this-procedure
      , input "str/sendkkt.p":U
      , input ( v-cntxt-obj-type + chr(4) + string(v-cntxt-obj-code) + chr(4) + 'U':U + chr(4) + "0")
      , input no
      , input "":U
      , input substitute("Отсылка схемы интеграции ККТ ")
      ) no-error.
   if error-status:error then
   do:
      message "Не удалось отправить схему интеграции ККТ на кассу"
         view-as alert-box.
   end.
end procedure.
procedure m-cash-KKT-without-exe :
   run str/diallog.w (
      input parparentproc
      , input this-procedure
      , input "str/sendkkt.p":U
      , input ( v-cntxt-obj-type + chr(4) + string(v-cntxt-obj-code) + chr(4) + 'U':U + chr(4) + "1")
      , input no
      , input "":U
      , input substitute("Отсылка схемы интеграции ККТ ")
      ) no-error.
   if error-status:error then
   do:
      message "Не удалось отправить схему интеграции ККТ на кассу"
         view-as alert-box.
   end.
end procedure.
procedure m-cash-pay-exe :
  do
  on error undo, return error return-value
  :
    run run-2cashpay in this-procedure ('IBM':U, 'U':U) .
  end.
end procedure.
procedure m-cash-pay-curr-exe :
  do
  on error undo, return error return-value
  :
    run run-2cashpay in this-procedure ('MAGIA-XML':U, 'U':U) .
  end.
end procedure.
procedure m-cashiers-exe :
  do
  on error undo, return error return-value
  :
    run str/sndcash.p (parparentproc, input v-cntxt-obj-code, 'U' ) .
  end.
end procedure.
procedure m-sellers-exe :
  do
  on error undo, return error return-value
  :
    run str/sndsell.p (parparentproc, input v-cntxt-obj-code, 'U' ) .
  end.
end procedure.
procedure m-staff-exe :
  do
  on error undo, return error return-value
  :
    run str/sndstaf.p
      (input  parparentproc
      ,input  v-cntxt-obj-type
      ,input  v-cntxt-obj-code
      ,input  'U'
      ) .
  end.
end procedure.
procedure m-fgrp-exe :
  do
  on error undo, return error return-value
  :
    run str/sndfgrp.p (parparentproc, v-cntxt-obj-code, 'U' ) .
  end.
end procedure.
procedure m-cash-dc-mask-exe :
  do
  on error undo, return error return-value
  :
    run str/diallog.w (parparentproc, this-procedure, 'str/senddcty.p':U, (v-cntxt-obj-type + chr(4) + string(v-cntxt-obj-code) + chr(4) + 'U'), no, '', 'Отправка информации по типам-маскам карт') .
  end.
end procedure.
procedure m-cash-cli-exe :
  define variable v-obj-db-num  as integer   no-undo initial ? .
  do
  on error undo, return error return-value
  :
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdbnum in g#library
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-obj-db-num
  )  .
    run str/diallog.w
      (input  parparentproc
      ,input  this-procedure
      ,input  'str/cash-cli.p':U
      ,input  (string(v-obj-db-num) + chr(4) + v-cntxt-obj-type + chr(4) + string(v-cntxt-obj-code) + chr(4) + 'U')
      ,input  no
      ,input  ''
      ,input  'Отправка информации по диск.картам'
      ) .
  end.
end procedure.
procedure m-tot-d-u-exe :
  do
  on error undo, return error return-value
  :
    run str/diallog.w (parparentproc, this-procedure, 'str/sendtotd.p':U, (string(v-cntxt-obj-code) + chr(4) + 'U' + chr(4) + 'all':U), no, '', 'Отправка информации по скидкам на итог чека') .
  end.
end procedure.
procedure m-tax-n-u-shop-exe :
  do
  on error undo, return error return-value
  :
    run str/send-tax.p (parparentproc, 'IBM':U, v-cntxt-obj-type, v-cntxt-obj-code, 'U') .
  end.
end procedure.
procedure m-cash-db-objs-exe :
  define variable v-obj-db-num  as integer   no-undo initial ? .
  do
  on error undo, return error return-value
  :
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdbnum in g#library
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-obj-db-num
  )  .
    run str/diallog.w
      (input  parparentproc
      ,input  this-procedure
      ,input  'str/sendobjs.p':U
      ,input  (string(v-obj-db-num) + chr(4) + string(v-cntxt-obj-code) + chr(4) + 'U')
      ,input  no
      ,input  ''
      ,input  'Отправка информации по объектам БД'
      ) .
  end.
end procedure.
procedure m-cash-db-objs-del-exe :
  define variable v-obj-db-num  as integer   no-undo initial ? .
  do
  on error undo, return error return-value
  :
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdbnum in g#library
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-obj-db-num
  )  .
    run str/diallog.w
      (input  parparentproc
      ,input  this-procedure
      ,input  'str/sendobjs.p':U
      ,input  (string(v-obj-db-num) + chr(4) + string(v-cntxt-obj-code) + chr(4) + 'D')
      ,input  no
      ,input  ''
      ,input  'Удаление информации по объектам БД'
      ) .
  end.
end procedure.
procedure m-cash-pet-exe :
  do
  on error undo, return error return-value
  :
    run str/diallog.w
      (input  parparentproc
      ,input  this-procedure
      ,input  'str/send-pet.p':U
      ,input  (v-cntxt-obj-type + chr(4) + string(v-cntxt-obj-code) + chr(4) + 'U')
      ,input  no
      ,input  ''
      ,input  'Отправка конфигурации АЗК'
      ) no-error .
  end.
end procedure.
procedure m-cash-pet-del-exe :
  do
  on error undo, return error return-value
  :
    run str/diallog.w
      (input  parparentproc
      ,input  this-procedure
      ,input  'str/send-pet.p':U
      ,input  (v-cntxt-obj-type + chr(4) + string(v-cntxt-obj-code) + chr(4) + 'D')
      ,input  no
      ,input  ''
      ,input  'Очистка конфигурации АЗК'
      ) no-error .
  end.
end procedure.
procedure m-del-all-gds-exe :
  do
  on error undo, return error return-value
  :
    run str/diallog.w (parparentproc, this-procedure, 'str/del-gds.p':U, string(v-cntxt-obj-code), no, 'Прервать', 'Удаление товаров с касс') .
  end.
end procedure.
procedure m-cash-pay-del-exe :
  do
  on error undo, return error return-value
  :
    run run-2cashpay in this-procedure ('IBM':U, 'D':U) .
  end.
end procedure.
procedure m-cash-pay-curr-del-exe :
  do
  on error undo, return error return-value
  :
    run run-2cashpay in this-procedure ('MAGIA-XML':U, 'D':U) .
  end.
end procedure.
procedure m-cashiers-del-exe :
  do
  on error undo, return error return-value
  :
    run str/sndcash.p (parparentproc, input v-cntxt-obj-code, 'D' ) .
  end.
end procedure.
procedure m-sellers-del-exe :
  do
  on error undo, return error return-value
  :
    run str/sndsell.p (parparentproc, input v-cntxt-obj-code, 'D' ) .
  end.
end procedure.
procedure m-staff-del-exe :
  do
  on error undo, return error return-value
  :
    run str/sndstaf.p
      (input  parparentproc
      ,input  v-cntxt-obj-type
      ,input  v-cntxt-obj-code
      ,input  'D'
      ) .
  end.
end procedure.
procedure m-fgrp-del-exe :
  do
  on error undo, return error return-value
  :
    run str/sndfgrp.p (parparentproc, v-cntxt-obj-code, 'D' ) .
  end.
end procedure.
procedure m-cash-dc-mask-del-exe :
  do
  on error undo, return error return-value
  :
    run str/diallog.w (parparentproc, this-procedure, 'str/senddcty.p':U, (v-cntxt-obj-type + chr(4) + string(v-cntxt-obj-code) + chr(4) + 'D'), no, '', 'Удаление информации по типам-маскам карт') .
  end.
end procedure.
procedure m-cash-cli-del-exe :
  define variable v-obj-db-num  as integer   no-undo initial ? .
  do
  on error undo, return error return-value
  :
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdbnum in g#library
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-obj-db-num
  )  .
    run str/diallog.w
      (input  parparentproc
      ,input  this-procedure
      ,input  'str/cash-cli.p':U
      ,input  (string(v-obj-db-num) + chr(4) + v-cntxt-obj-type + chr(4) + string(v-cntxt-obj-code) + chr(4) + 'D')
      ,input  no
      ,input  ''
      ,input  'Удаление информации по диск.картам'
      ) .
  end.
end procedure.
procedure m-tot-d-d-exe :
  do
  on error undo, return error return-value
  :
    run str/diallog.w (parparentproc, this-procedure, 'str/sendtotd.p':U, (string(v-cntxt-obj-code) + chr(4) + 'D' + chr(4) + 'all':U), no, '', 'Удаление информации по скидкам на итог чека') .
  end.
end procedure.
procedure m-tax-n-d-shop-exe :
  do
  on error undo, return error return-value
  :
    run str/send-tax.p (parparentproc, 'IBM':U, v-cntxt-obj-type, v-cntxt-obj-code, 'D') .
  end.
end procedure.
procedure m-cash-inf-exe :
  do
  on error undo, return error return-value
  :
    run str/cd-inf.p (parparentproc, yes, no) .
  end.
end procedure.
procedure m-cash-chk-exe :
  do
  on error undo, return error return-value
  :
    run str/diallog.w (parparentproc, this-procedure, 'str/get-chkf.p':U, (v-cntxt-obj-type + chr(4) + string(v-cntxt-obj-code) + chr(4) + string(0)), no, '', 'Прием чеков с касс') .
  end.
end procedure.
procedure m-cash-report-exe :
  do
  on error undo, return error return-value
  :
    run str/diallog.w (parparentproc, this-procedure, 'str/get-repf.p':U, (v-cntxt-obj-type + chr(4) + string(v-cntxt-obj-code) + chr(4) + string(0)), no, '', 'Прием отчетов с касс') .
  end.
end procedure.
procedure m-cash-chk-remote-exe :
  do
  on error undo, return error return-value
  :
    run str/diallog.w (parparentproc, this-procedure, 'str/get-chkf.p':U, (v-cntxt-obj-type + chr(4) + string(v-cntxt-obj-code) + chr(4) + string(1)), no, '', 'Запрос на удаленные кассы') .
  end.
end procedure.
procedure m_sysconf-list-exe :
  define variable v-host-code as integer   no-undo .
  define variable ri-list     as character no-undo .
  do
  on error undo, return error return-value
  :
    run adm/sconfs.w
      (input  parparentproc
      ,input  'b-add,b-attr-copy,b-attr-update':U
      ,input  no
      ,input  v-cntxt-host-code-obj
      ,output v-host-code
      ,input-output ri-list
      ) .
  end.
end procedure.
procedure m_action-role :
  define variable v-action-role-code as integer   no-undo .
  define variable v-rid-list         as character no-undo .
  define variable v-context          as character no-undo .
  do
  on error undo, return error return-value
  :
    ASSIGN
      v-context = 'All':U
    .
    run str/actnrole.w ( input  parparentproc
                       , input  'b-add,rs-scope':U
                       , input-output v-context
                       , output v-action-role-code
                       , input-output v-rid-list
                       , input v-cntxt-db-num
                       ) .
  end.
end procedure.
procedure m-smart-ref :
  do
  on error undo, return error
  :
  run ref/codelay.p (parparentproc, "", "", "SpravAttrSmart", "Справочник атрибутов SMART") no-error.
  end.
end procedure.
procedure m-hdd-ref :
  do
  on error undo, return error
  :
  run ref/hdd.p ( input parparentproc, input v-cntxt-db-num) no-error.
  end.
end procedure.
procedure m-cashp-ref :
  do
  on error undo, return error
  :
  define buffer code for ub.code.
  find first code where code.parent eq ""
                    and code.code eq "cash-param"
  no-lock no-error.
  if not avail code
  then do:
     message "Справочник не найден." view-as alert-box.
     return.
  end.
  run ref/cashpargroup.w ( input  parparentproc
                     ,input  if isERPRN then 'ПРОСМОТР':U else 'ИЗМЕНЕНИЕ':U
                     ,input  ""
                     ,input "cash-param"
                     ,input ?
                    ) .
  end.
end procedure.
procedure m-code-ref :
  do
  on error undo, return error
  :
  define buffer code for ub.code.
  run ref/codelay.p ( input  parparentproc
                      ,input  'ПРОСМОТР':U
                      ,input  ""
                      ,input  ""
                      ,input  "Дополнительные справочники системы"
                        ) .
  end.
end procedure.
procedure m-cashp-rep :
  do
  on error undo, return error
  :
  run rep/g-cash-param.p(input  parparentproc).
  end.
end procedure.
procedure m_action-item :
  define variable v-rid-list         as character no-undo .
  do
  on error undo, return error return-value
  :
    run adm/actnitem.w ( input  parparentproc
                       , input  '':U
                       , input-output v-rid-list
                       ) .
  end.
end procedure.
procedure m_sysconf-exe :
  define variable v-host-code as integer   no-undo .
  do
  on error undo, return error return-value
  :
    if lookup(v-cntxt-level, 'firm':U + chr(44) + 'object':U) > 0
    then do:
      run adm/config.w
        (input  parparentproc
        ,input  v-cntxt-host-code-obj
        ,input (if v-cntxt-db-num <> 0 then 'ПРОСМОТР':U else 'ИЗМЕНЕНИЕ':U)
        ,input no
        ) .
    end.
    else do:
      message
        "Не выбрана текущая фирма" skip
        view-as alert-box error .
    end.
  end.
end procedure.
procedure m_newhost-exe :
  do
  on error undo, return error return-value
  :
    run adm/config.w (input parparentproc, 0, 'ДОБАВЛЕНИЕ':U, no ) .
  end.
end procedure.
procedure m_chk-senreq-exe :
  do
  on error undo, return error return-value
  :
    run utl/g-sndreq.p (parparentproc) .
  end.
end procedure.
procedure m_util-version-exe :
  do
  on error undo, return error return-value
  :
    run gbl/menubrws.w (parparentproc, 'version':U, 'Коррекция при смене версии') .
  end.
end procedure.
procedure m_util-function-exe :
  do
  on error undo, return error return-value
  :
    run gbl/menubrws.w (parparentproc, 'function':U, 'Функции администратора') .
  end.
end procedure.
procedure m_util-check-exe :
  do
  on error undo, return error return-value
  :
    run gbl/menubrws.w (parparentproc, 'check':U, 'Проверки') .
  end.
end procedure.
procedure m_view-history-exe :
  do
  on error undo, return error return-value
  :
    run str/history.w (parparentproc) .
  end.
end procedure.
procedure m_util-archive-exe :
  do
  on error undo, return error return-value
  :
    run gbl/menubrws.w (parparentproc, 'archive':U, 'Работа с архивами') .
  end.
end procedure.
procedure m_util-impexp-exe :
  define variable glog as logical no-undo.
  do
  on error undo, return error return-value
  :
define variable vss-include-info13 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_impexp_proc':U
    ,input  'global':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output glog
    )  .
end.
    if glog then do :
      run gbl/menubrws.w (parparentproc, 'impexp':U, 'Импорт/Экспорт') .
    end.
  end.
end procedure.
procedure m-gds-show-exe :
  define variable ri-list as character no-undo .
  do
  on error undo, return error return-value
  :
    run ref/gds-ref.p (parparentproc, 'b-add', ?, ?, ?, ?, ?, ?, ?, v-cntxt-obj-type, v-cntxt-obj-code, ?, output ri-list) .
  end.
end procedure.
procedure m-gds-grp-off-exe :
  define variable ri-list as character no-undo .
  do
  on error undo, return error return-value
  :
    run ref/gds-grp.w (parparentproc, input 'buttons-for-admin', input v-cntxt-obj-type, input v-cntxt-obj-code, input-output ri-list) .
  end.
end procedure.
procedure m-gds-grp-stsh-exe :
  define variable ri-list as character no-undo .
  do
  on error undo, return error return-value
  :
    run ref/gds-grp.w (parparentproc, input '', input v-cntxt-obj-type, input v-cntxt-obj-code, input-output ri-list) .
  end.
end procedure.
procedure m-fbr-gds-grp-exe :
  define variable ri-list as character no-undo .
  do
  on error undo, return error return-value
  :
    run ref/fbrggrp.w ( input parparentproc, input v-cntxt-obj-type, input v-cntxt-obj-code, input 'buttons-for-admin', input-output ri-list ) .
  end.
end procedure.
procedure m-gds-prt-exe :
  define variable rid# as recid    no-undo .
  do
  on error undo, return error return-value
  :
    run ref/gdsprts.w
      (input  parparentproc
      ,input  v-cntxt-db-num <> 0
      ,output rid#
      ) .
  end.
end procedure.
procedure m-rcps-exe :
  define variable ri-list as character no-undo .
  do
  on error undo, return error return-value
  :
      run ref/rcp-all.w (
            input parparentproc
          , input 'b-add'
          , input 'все':U
          , input ?
          , input v-cntxt-obj-type
          , input v-cntxt-obj-code
          , output ri-list
      ).
  end.
end procedure.
procedure m-units-exe :
  define variable rid#          as recid     no-undo .
  do
  on error undo, return error return-value
  :
    run ref/units.w
      (input  parparentproc
      ,input  v-cntxt-db-num <> 0
      ,output rid#
      ) .
  end.
end procedure.
procedure m-units-merc-exe :
  define variable rid#          as recid     no-undo .
  do
  on error undo, return error return-value
  :
    run bge/units-merc.w
      (input  parparentproc
      ,input  no
      ,output rid#
      ) .
  end.
end procedure.
procedure m-okei-kkt-exe:
  define variable rid#          as recid     no-undo .
  do
  on error undo, return error return-value
  :
    run ref/codelay.p
      (input  parparentproc
      ,input  'ИЗМЕНЕНИЕ':U
      ,input  ""
      ,input  "okei-kkt"
      ,input  ?
      ) .
  end.
end procedure.
procedure m-dt-seasons-exe:
  define variable rid#          as recid     no-undo .
  do
  on error undo, return error return-value
  :
    run ref/codelay.p
      (input  parparentproc
      ,input  ( if v-cntxt-db-num = 0 then 'ИЗМЕНЕНИЕ':U else 'ПРОСМОТР':U)
      ,input  ""
      ,input  "DTSeasons"
      ,input  ?
      ) .
  end.
end procedure.
procedure m-emrc-exe:
  define variable rid#          as char     no-undo .
  do
  on error undo, return error return-value
  :
run ref/codelay.p(input  parparentproc
      ,input  'ИЗМЕНЕНИЕ':U
      ,input  ""
      ,input  "EMC"
      ,input  ? ).
  end.
end procedure.
procedure m-tares-exe :
  define variable v-rid-list as character no-undo .
  define variable v-stts as integer no-undo .
  do
  on error undo, return error return-value
  :
    run ref/tares.w
      (input  parparentproc
      ,input  (if v-cntxt-db-num = 0 then "b-add" else '')
      ,input 'все':U
      ,input-output v-stts
      ,input-output v-rid-list
      ) .
  end.
end procedure.
procedure m-tmp-exe :
  define variable rid#          as   recid             no-undo.
  do
  on error undo, return error return-value
  :
    run ref/tmp-sale.w (input parparentproc, input 'b-add', output  rid# ) .
  end.
end procedure.
procedure m-season-exe :
  define variable rid#          as   recid             no-undo.
  do
  on error undo, return error return-value
  :
    run ref/season.w (input parparentproc, input 'b-add' , output  rid#) .
  end.
end procedure.
procedure m-alc-type :
  define variable rid-list as recid   no-undo.
  define variable v-ok     as logical no-undo.
  do
  on error undo, return error return-value
  :
    run ref/alc-type.w ( input parparentproc
                       , input 'b-add'
                       , input-output  rid-list
                       , output v-ok
                       ) .
  end.
end procedure.
procedure m-lic-supp :
  do
  on error undo, return error return-value
  :
    run ref/licsupp.w ( input parparentproc
                      , input ?
                      , input ?
                      ) .
  end.
end procedure.
procedure m-lic-sale :
  do
  on error undo, return error return-value
  :
    run ref/licsale.w ( input parparentproc ) .
  end.
end procedure.
procedure m-collection-exe :
  define variable rid#          as   recid             no-undo.
  do
  on error undo, return error return-value
  :
    run ref/collec.w (input parparentproc, input 'b-add' , output  rid#) .
  end.
end procedure.
procedure m-marking-exe :
  do
  on error undo, return error return-value
  :
    run str/mark_hist.w (input parparentproc , input "", input "") .
  end.
end procedure.
procedure m-assmatr-exe :
  define variable rid#          as   recid             no-undo.
  do
  on error undo, return error return-value
  :
    run ref/assmatr.w (input parparentproc , input 'b-add',v-cntxt-obj-type,v-cntxt-obj-code , ? ,  ?, input-output  rid#) .
  end.
end procedure.
procedure m-addcharges-exe :
define variable v-spis as character no-undo .
  do
  on error undo, return error return-value
  :
    run ref/addchls.w (input parparentproc , input '' , output v-spis) .
  end.
end procedure.
procedure m-exmark-exe :
  define variable rid#          as   recid             no-undo.
  do
  on error undo, return error return-value
  :
    run ref/exmark.w (input parparentproc , input 'b-add', input-output  rid#) .
  end.
end procedure.
procedure m-cli-show-exe :
  define variable ri-list as character no-undo .
  do
  on error undo, return error return-value
  :
    run ref/cli-all.w (input parparentproc, 'b-bank,b-add', ?, ?, ?, ?, ?, ?, output ri-list) .
  end.
end procedure.
procedure m-cli-grp-off-exe :
  define variable ri-list as character no-undo .
  do
  on error undo, return error return-value
  :
    run ref/cli-grps.w (input parparentproc, 'buttons-for-admin', input-output ri-list) .
  end.
end procedure.
procedure m-cli-grp-stsh-exe :
  define variable ri-list as character no-undo .
  do
  on error undo, return error return-value
  :
    run ref/cli-grps.w (input parparentproc, '', input-output ri-list) .
  end.
end procedure.
procedure m-dc-type-exe :
  define variable v-host-code as integer   no-undo .
  define variable ri-list     as character no-undo .
  do
  on error undo, return error return-value
  :
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-host-code
  )  .
    run ref/dc-types.w
      (input  parparentproc
      ,input  '':U
      ,input  'b-add':U
      ,input  v-host-code
      ,input  v-host-code
      ,input  v-cntxt-obj-type
      ,input  v-cntxt-obj-code
      ,input-output ri-list
      ) .
  end.
end procedure.
procedure m-dc-masks-exe :
define variable v-host-code as integer   no-undo .
define variable v-rid-list AS CHARACTER NO-UNDO.
do
on error undo, return error return-value
:
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-host-code
  )  .
    run ref/dc-masks.w (
                    INPUT parparentproc
                   ,INPUT v-cntxt-host-code-obj
                   ,INPUT v-cntxt-obj-type
                   ,INPUT v-cntxt-obj-code
                   ,input (if v-cntxt-db-num = 0 then "b-add" else '':U)
                   ,INPUT 'все':U
                   ,INPUT '':U
                   ,INPUT 0
                   ,INPUT ?
                   ,input-output v-rid-list
                    ) NO-ERROR.
end.
end procedure.
procedure m-discards-exe :
  define variable ri-list as character no-undo .
  define variable v-host-code like ub.sysconf.host-code no-undo .
  do
  on error undo, return error return-value
  :
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-host-code
  )  .
    run ref/discards.w (
                     input parparentproc
                   , input (if v-cntxt-db-num = 0 then 'b-add' else '':U)
                   , input 'все':U
                   , input v-host-code
                   , input v-cntxt-obj-type
                   , input v-cntxt-obj-code
                   , input '':U
                   , input ?
                   , output ri-list ) .
  end.
end procedure.
procedure m-dc-prop-head-exe :
  define variable v-rid-list as character no-undo .
  do
  on error undo, return error return-value
  :
   run rul/prop-head-s.w (
                          input parparentproc
                        , input 'b-storage'
                        , input "general-view"
                        , input 'Loyalty2':U
                        , input-output v-rid-list ) .
  end.
end procedure.
procedure m-dc-rule-profile-exe :
  define variable v-rid-list as character no-undo .
  do
  on error undo, return error return-value
  :
   run rul/rule-profile-s.w (
                          input parparentproc
                        , input ''
                        , input "general-view"
                        , input 'dis-card-type':U
                        , input-output v-rid-list ) .
  end.
end procedure.
procedure m-dc-ruleset-exe :
  define variable v-rid-list as character no-undo .
  do
  on error undo, return error return-value
  :
   run rul/ruleset-s.w (
                          input parparentproc
                        , input ''
                        , input "profile-type" + chr(4) + 'dis-card-type':U + chr(4) + "ruleset"
                        , input 0
                        , input-output v-rid-list ) .
  end.
end procedure.
procedure m-dc-codex-exe :
  define variable v-rid-list as character no-undo .
  do
  on error undo, return error return-value
  :
   run rul/ruleset-s.w (
                          input parparentproc
                        , input ''
                        , input "profile-type" + chr(4) + 'dis-card-type':U + chr(4) + "codex"
                        , input 0
                        , input-output v-rid-list ) .
  end.
end procedure.
procedure m-lo-prop-ref-exe :
  define variable v-rid-list as character no-undo .
  do
  on error undo, return error return-value
  :
   run ref/proprefs.w (
                          input parparentproc
                        , input (if v-cntxt-db-num = 0 then 'b-add'else '')
                        , input 'все':U
                        , input 0
                        , input '':U
                        , input '':U
                        , input-output v-rid-list ) .
  end.
end procedure.
procedure m-stop-ls-exe :
define variable v-rid-list as character no-undo .
  do
  on error undo, return error
  :
    run ref/stop-ls.w (
                        input parparentproc
                       ,input (if v-cntxt-db-num  = 0 then 'b-add':U else '')
                       ,input 'все':U
                       ,input-output v-rid-list) no-error.
  end.
end procedure.
procedure m-rum-cds-rep-exe :
do
on error undo, return error return-value
:
  run ref/rum-cds.w ( input parparentproc
                    ,input 'rep':U
                    ,input 'rep':U
                    ,input (if v-cntxt-db-num  = 0 then 'ИЗМЕНЕНИЕ':U else 'ПРОСМОТР':U)
                    ,input 'все':U
                    ,input ''
                    ,input 0
                    ) no-error .
  end.
end procedure.
procedure m-rum-cds-chk-exe :
define variable v-ok as logical no-undo .
  do
  on error undo, return error return-value
  :
define variable vss-include-info17 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_rum_chk-doc-work':U
    ,input  'global':U
    ,input  0
    ,input  ''
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output v-ok
    )  .
end.
   run ref/rum-cds.w (
                          input parparentproc
                         ,input 'chk-doc_ibs-th':U
                         ,input 'chk-doc_ibs-th':U
                         ,input (if v-cntxt-db-num  = 0 and v-ok then 'ИЗМЕНЕНИЕ':U else 'ПРОСМОТР':U)
                        , input 'все':U
                        , input ''
                        , input 0) no-error.
  end.
end procedure.
procedure m-chk-doc-rule-profile-exe :
  define variable v-rid-list as character no-undo .
  do
  on error undo, return error return-value
  :
   run rul/rule-profile-s.w (
                          input parparentproc
                        , input ''
                        , input "general-view"
                        , input 'chk-doc':U
                        , input-output v-rid-list ) .
  end.
end procedure.
procedure m-taxes-exe :
  define variable v-host-code as integer   no-undo .
  define variable ri-list     as character no-undo .
  do
  on error undo, return error return-value
  :
    case v-cntxt-level:
      WHEN 'object':U
      THEN DO:
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-host-code
  )  .
         run ref/tax-tree.w
            (input  parparentproc
            ,input  ''
            ,input  'ALL':U
            ,input  v-host-code
            ,input  v-cntxt-obj-type
            ,input  v-cntxt-obj-code
            ,input  ?
            ,input-output ri-list
            ) .
      END.
      WHEN 'firm':U
      THEN DO:
         run ref/tax-tree.w
            (input  parparentproc
            ,input  ''
            ,input  'ALL':U
            ,input  v-cntxt-host-code-obj
            ,input  "":U
            ,input  0
            ,input  ?
            ,input-output ri-list
            ) .
      END.
      OTHERWISE DO:
         run ref/tax-tree.w
            (input  parparentproc
            ,input  ''
            ,input  'ALL':U
            ,input  0
            ,input  ''
            ,input  0
            ,input  ?
            ,input-output ri-list
            ) .
      END.
    END CASE.
  end.
end procedure.
procedure m-countries-exe :
  define variable v-rid-list as character  no-undo .
  do
  on error undo, return error return-value
  :
    if v-cntxt-db-num = 0
    then do:
      run ref/countris.w
        (input parparentproc
        ,input  'b-add,b-chg'
        ,input-output v-rid-list
        ) .
    end.
    else do:
      run ref/countris.w
        (input parparentproc
        ,input  ''
        ,input-output v-rid-list
        ) .
    end.
  end.
end procedure.
procedure m-currency-exe :
  define variable rid#          as recid     no-undo .
  do
  on error undo, return error return-value
  :
    if v-cntxt-db-num = 0
    then do:
      run ref/currency.w
        (input  parparentproc
        ,input  'b-add,b-add-acc,b-add-bank'
        ,input-output  rid#
        ) .
    end.
    else do:
      run ref/currency.w
        (input  parparentproc
        ,input  ''
        ,input-output  rid#
        ) .
    end.
  end.
end procedure.
procedure m-pay-type-exe :
  define variable rid#             as character no-undo .
  do
  on error undo, return error return-value
  :
    if v-cntxt-db-num = 0
    then do:
      run ref/paytype.w
        (input  parparentproc
        ,input  'b-add,b-upd,b-del,b-doc,b-print'
        ,output rid#
        ) .
    end.
    else do:
      run ref/paytype.w
        (input  parparentproc
        ,input  'b-doc'
        ,output  rid#
        ) .
    end.
  end.
end procedure.
procedure m-rvd-reason-exe :
  define variable rid#             as character no-undo .
  define variable v-value    as character no-undo .
  define variable v-type     as character no-undo .
  do
  on error undo, return error return-value
  :
    run gbl/conf-rd.p ("is-erpRN", "", "", 0, "", "", "", no, output v-value, output v-type) no-error.
    if v-value = "no"
    then do:
      if v-cntxt-db-num = 0
      then do:
        run ref/rvd-reason.w
          (input  parparentproc
          ,input  'b-add,b-upd,b-del'
          ,input 'все':U
          ,input -1
          ,output rid#
          ) .
      end.
      else do:
        run ref/rvd-reason.w
          (input  parparentproc
          ,input  ''
          ,input 'все':U
          ,input -1
          ,output  rid#
          ) .
      end.
    end .
    else do :
      run ref/rvd-reason.w
        (input  parparentproc
        ,input  ''
        ,input 'все':U
        ,input -1
        ,output  rid#
        ) .
    end .
  end.
end procedure.
procedure m-reason-check-exe :
  define variable rid#             as character no-undo .
  do
  on error undo, return error return-value
  :
      run ref/reasonSuspCheck.w
        (input  parparentproc
        ,input  ''
        ,output  rid#
        ) .
    end .
end procedure.
procedure m-cashpay-exe :
  define variable ri-list          as character no-undo .
  do
  on error undo, return error return-value
  :
    if v-cntxt-db-num = 0
    then do:
      run ref/cashpays.w
        (input  parparentproc
        ,input  'b-add'
        ,input 'все':U
        ,input  v-cntxt-host-code-obj
        ,input  v-cntxt-obj-type
        ,input  v-cntxt-obj-code
        ,output ri-list
        ) .
    end.
    else do:
      run ref/cashpays.w
        (input  parparentproc
        ,input  ''
        ,input 'все':U
        ,input  v-cntxt-host-code-obj
        ,input  v-cntxt-obj-type
        ,input  v-cntxt-obj-code
        ,output ri-list
        ) .
    end.
  end.
end procedure.
procedure m-cashdesk-exe :
  define variable ri-list     as character no-undo .
  do
  on error undo, return error return-value
  :
    run ref/cashlist.w
      (input  parparentproc
      ,input  'b-add,b-on':U
      ,input  'db':U
      ,input  v-cntxt-db-num
      ,input  v-cntxt-host-code-obj
      ,input  v-cntxt-obj-type
      ,input  v-cntxt-obj-code
      ,input  ?
      ,output ri-list
      ) .
  end.
end procedure.
procedure m-cashdesk-all-exe :
  define variable ri-list as character no-undo .
  do
  on error undo, return error return-value
  :
    run ref/cashlist.w
      (input  parparentproc
      ,input  '':U
      ,input  'все':U
      ,input  v-cntxt-db-num
      ,input  v-cntxt-host-code-obj
      ,input  v-cntxt-obj-type
      ,input  v-cntxt-obj-code
      ,input  ?
      ,output ri-list
      ) .
  end.
end procedure.
procedure m-scales-all-exe :
  define variable ri-list as character no-undo .
  do
  on error undo, return error return-value
  :
    run ref/scales.w (parparentproc, v-cntxt-obj-type, v-cntxt-obj-code, '':U, 'все':U, output  ri-list ) .
  end.
end procedure.
procedure m-scales-exe :
  define variable ri-list as character no-undo .
  do
  on error undo, return error return-value
  :
    run ref/scales.w (parparentproc, v-cntxt-obj-type, v-cntxt-obj-code, 'b-add', 'db':U, output ri-list) .
  end.
end procedure.
procedure m-grp-scales-exe :
  define variable ri-list as character no-undo .
  do
  on error undo, return error return-value
  :
    run ref/gds-grp.w (parparentproc, 'терм':U + ',b-scales', input v-cntxt-obj-type, input v-cntxt-obj-code, input-output ri-list) .
  end.
end procedure.
procedure m-store-ref-exe :
  define variable ri-list as character no-undo .
  do
  on error undo, return error return-value
  :
    run adm/stores.w
      (input parparentproc
      ,input 'b-add'
      ,input-output ri-list
      ,input no
      ) .
  end.
end procedure.
procedure m-shop-ref-exe :
  define variable ri-list as character no-undo .
  do
  on error undo, return error return-value
  :
    run adm/shops.w
      (input parparentproc
      ,input 'b-add'
      ,input-output ri-list
      ,no
      ) .
  end.
end procedure.
procedure m-dis-rules-exe :
  do
  on error undo, return error
  :
    define variable v-sts as integer no-undo init 0.
    define variable v-rid-list as character no-undo .
    run ref/dis-ruls.w ( INPUT parparentproc
                       , input v-cntxt-host-code-obj
                       , input v-cntxt-obj-type
                       , input v-cntxt-obj-code
                       , input "b-add"
                       , input "template"
                       , input 0
                       , input ?
                       , input 0
                       , input-output v-sts
                       , input-output v-rid-list).
  end.
end procedure.
procedure m-obj-init-exe :
define variable v-host-code like ub.sysconf.host-code no-undo .
  do
  on error undo, return error return-value
  :
    run adm/obj-init.w ( input parparentproc, input v-cntxt-host-code-obj) .
  end.
end procedure.
procedure m-db-ref-exe :
  define variable rid#          as   recid             no-undo.
  do
  on error undo, return error return-value
  :
    run adm/dbs.w ( input parparentproc
                  ,input 'ИЗМЕНЕНИЕ':U
                  ,output rid# ) .
  end.
end procedure.
procedure m-obj-sht-open-exe :
  do
  on error undo, return error return-value
  :
    run gbl/sht-open.p ( input parparentproc, input v-cntxt-obj-type, input v-cntxt-obj-code ) no-error .
  end.
end procedure.
procedure m-obj-sht-close-exe :
  do
  on error undo, return error return-value
  :
    run gbl/sht-clos.p ( input parparentproc, input v-cntxt-obj-type, input v-cntxt-obj-code, input yes, input no ) no-error.
  end.
end procedure.
procedure m-obj-sht-undo-exe :
  do
  on error undo, return error return-value
  :
    run str/sht-undo.p ( input parparentproc, input v-cntxt-obj-type, input v-cntxt-obj-code ) .
  end.
end procedure.
procedure obj-pr-new-exe :
  do
  on error undo, return error return-value
  :
    run gbl/prdoclst.p
      (input  parparentproc
      ,input  'статус':U
      ,input  'новый':U
      ) .
  end.
end procedure.
procedure obj-pr-doc-exe :
  do
  on error undo, return error return-value
  :
    run gbl/prdoclst.p
      (input  parparentproc
      ,input  'статус':U
      ,input  'приказ':U
      ) .
  end.
end procedure.
procedure obj-pr-perm-exe :
  do
  on error undo, return error return-value
  :
    run gbl/prdoclst.p
      (input  parparentproc
      ,input  'статус':U
      ,input  'разрешен':U
      ) .
  end.
end procedure .
procedure obj-pr-akt-exe :
  do
  on error undo, return error return-value
  :
    run gbl/prdoclst.p
      (input  parparentproc
      ,input  'статус':U
      ,input  'акт':U
      ) .
  end.
end procedure.
procedure obj-pr-exe :
  do
  on error undo, return error return-value
  :
    run gbl/prdoclst.p
      (input  parparentproc
      ,input  'объект':U
      ,input  ""
      )  .
  end.
end procedure.
procedure m-host-pr-exe :
  define variable v-ok   as logical   no-undo.
  do
  on error undo, return error return-value
  :
define variable vss-include-info19 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_documents_company':U
    ,input  'firm':U
    ,input  v-cntxt-host-code-obj
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output v-ok
    )  .
end.
    if v-ok then do:
      run gbl/prdoclst.p
        (input  parparentproc
        ,input  'фирма':U
        ,input  ""
        ) .
    end.
  end.
end procedure.
procedure m-all-pr-exe :
  define variable v-ok as logical   no-undo .
  do
  on error undo, return error return-value
  :
define variable vss-include-info20 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_documents_all':U
    ,input  'global':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output v-ok
    )  .
end.
    if v-ok = true
    then do:
      run gbl/prdoclst.p
        (input  parparentproc
        ,input  'работа':U
        ,input  ""
        ) .
    end.
  end.
end procedure.
procedure m-all-pr-del :
  define variable v-ok as logical   no-undo .
  do
  on error undo, return error return-value
  :
define variable vss-include-info21 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_documents_all':U
    ,input  'global':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output v-ok
    )  .
end.
    if v-ok = true
    then do:
      run str/pr-cdocs.w
        ( parparentproc ,
          v-cntxt-host-code-obj   ) .
    end.
  end.
end procedure.
procedure obj-fbr-pln-exe :
  do
  on error undo, return error return-value
  :
    run str/fbr-plns.w
      (input  parparentproc
      ,input  ""
      ,input  v-cntxt-obj-type
      ,input  v-cntxt-obj-code
      ,input  v-cntxt-userid
      ) .
  end.
end procedure.
procedure m-cash-rate-exe :
  define variable v-host-code as integer   no-undo .
  define variable v-base-code as integer   no-undo .
  define variable v-r-b       as character no-undo.
  do
  on error undo, return error return-value
  :
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output v-r-b
  )  .
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-host-code
  )  .
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  v-host-code
  ,output v-base-code
  )  .
    if  v-r-b = 'rubl':u
    and v-base-code = 0
    then do:
      run str/diallog.w
        (input  parparentproc
        ,input  this-procedure
        ,input  "str/send-cur.p":U
        ,input  (v-cntxt-obj-type + chr(4) + string(v-cntxt-obj-code) + chr(4) + "U")
        ,input  no
        ,input  "":U
        ,input  substitute("Отсылка данных по курсам валют на кассы")
        ) no-error.
    end.
    else do:
      run ref/currshop.w (input parparentproc, input v-cntxt-obj-type, input v-cntxt-obj-code).
    end.
  end.
END PROCEDURE.
procedure bpasend :
define input parameter p-pos-type as character no-undo .
define input parameter p-action as character no-undo .
 run str/diallog.w (
        input parparentproc
      , input this-procedure
      , input "str/bpasend.p":U
      , input (p-pos-type + chr(4) + v-cntxt-obj-type + chr(4) + string(v-cntxt-obj-code) + chr(4) + p-action)
      , input no
      , input "":U
      , input substitute("Отсылка справочника ОСС на кассы &1", p-pos-type, 'IBM-XML':U)
  ) no-error.
end procedure.
procedure run-2cashpay :
define input parameter p-pos-type as character no-undo .
define input parameter p-action as character no-undo .
 run str/diallog.w (
        input parparentproc
      , input this-procedure
      , input "str/2cashpay.p":U
      , input (p-pos-type + chr(4) + v-cntxt-obj-type + chr(4) + string(v-cntxt-obj-code) + chr(4) + p-action)
      , input no
      , input "":U
      , input substitute("Отсылка данных по типам кассовых платежей на кассы &1 &2", p-pos-type, (if p-pos-type = 'IBM':U then 'IBM-XML':U else "":U))
  ) no-error.
end procedure.
procedure m-cash-wthser-exe :
 run str/diallog.w (
        input parparentproc
      , input this-procedure
      , input "str/sendwths.p":U
      , input ( v-cntxt-obj-type + chr(4) + string(v-cntxt-obj-code) + chr(4) + 'U':U)
      , input no
      , input "":U
      , input substitute("Отсылка данных по маскам серийных МЦ на кассы ")
  ) no-error.
end procedure.
procedure m-promo-u-exe :
  do
  on error undo, return error return-value
  :
    run promosend in this-procedure ('IBM-XML':U, 'U':U) .
  end.
end procedure.
procedure m-catalog-corr-exe :
 run str/diallog.w (
        input parparentproc
      , input this-procedure
      , input "str/sendcorr.p":U
      , input ( v-cntxt-obj-type + chr(4) + string(v-cntxt-obj-code) + chr(4) + 'U':U)
      , input no
      , input "":U
      , input substitute("Отсылка данных по справочнику ОСС ")
  ) no-error.
end procedure.
procedure m-cash-emrc-exe :
 run str/diallog.w (
        input parparentproc
      , input this-procedure
      , input "str/send-all.p":U
      , input ( v-cntxt-obj-type + chr(4) + string(v-cntxt-obj-code) + chr(4) + 'D':U + chr(4) + 'emrc':U + chr(4) + 'Удаление справочника ЕМЦ':U)
      , input ?
      , input "":U
      , input substitute("Отсылка очистки справочника ЕМЦ")
  ) no-error.
 run str/diallog.w (
        input parparentproc
      , input this-procedure
      , input "str/send-all.p":U
      , input ( v-cntxt-obj-type + chr(4) + string(v-cntxt-obj-code) + chr(4) + 'U':U + chr(4) + 'emrc':U + chr(4) + 'Передача справочника ЕМЦ':U)
      , input ?
      , input "":U
      , input substitute("Отсылка справочника ЕМЦ")
  ) no-error.
end procedure.
procedure m-cash-marktype-exe :
 run str/diallog.w (
        input parparentproc
      , input this-procedure
      , input "str/send-all.p":U
      , input ( v-cntxt-obj-type + chr(4) + string(v-cntxt-obj-code) + chr(4) + 'U':U + chr(4) + 'MarkType':U + chr(4) + 'Передача справочника Типы Марок':U)
      , input ?
      , input "":U
      , input substitute("Отсылка справочника MarkType")
  ) no-error.
end procedure.
procedure m-cash-gismt-exe :
 run str/diallog.w (
        input parparentproc
      , input this-procedure
      , input "str/sendgismt.p":U
      , input ( v-cntxt-obj-type + chr(4) + string(v-cntxt-obj-code) + chr(4) + 'U':U + chr(4) + 'gismt':U + chr(4) + 'Передача настроек для проверки КМ':U)
      , input ?
      , input "":U
      , input substitute("Отсылка настроек для проверки КМ")
  ) no-error.
end procedure.
FUNCTION BinaryXOR RETURNS INT64(INPUT intOperand1 AS INT64,
                                 INPUT intOperand2 AS INT64)
                                 forward .
FUNCTION ShiftRight RETURNS INT64(INPUT in_Operand_A AS INT64,
                                  INPUT in_Operand_B AS INTEGER)
                                  forward .
FUNCTION BinaryAND RETURNS INTEGER (INPUT in_Operand_A AS INT64,
                                    INPUT in_Operand_B AS INT64)
                                    forward .
FUNCTION intToHex RETURNS CHARACTER (i_iint AS INT64) forward .
FUNCTION crc32Table RETURNS INT64 EXTENT 256  () forward .
FUNCTION CRC32 RETURNS INT64 (INPUT mpData AS MEMPTR) forward .
FUNCTION BinaryXOR RETURNS INT64
(INPUT intOperand1 AS INT64,
 INPUT intOperand2 AS INT64):
    DEFINE VARIABLE iByteLoop  AS INTEGER NO-UNDO.
    DEFINE VARIABLE iXOResult  AS INT64 NO-UNDO.
    DEFINE VARIABLE lFirstBit  AS LOGICAL NO-UNDO.
    DEFINE VARIABLE lSecondBit AS LOGICAL NO-UNDO.
    iXOResult = 0.
    DO iByteLoop = 1 TO 64:
        ASSIGN
        lFirstBit  = LOGICAL(GET-BITS(intOperand1,iByteLoop  ,1))
        lSecondBit = LOGICAL(GET-BITS(intOperand2,iByteLoop , 1)).
        IF (lFirstBit  AND NOT lSecondBit) OR
           (lSecondBit AND NOT lFirstBit) THEN
            iXOResult = iXOResult + EXP(2, iByteLoop - 1).
    END.
    RETURN iXOResult.
END .
FUNCTION ShiftRight RETURNS INT64
(INPUT in_Operand_A AS INT64,
 INPUT in_Operand_B AS INTEGER):
   RETURN INT64( TRUNCATE( in_Operand_A / EXP(2,in_Operand_B), 0 ) ).
END .
FUNCTION BinaryAND RETURNS INTEGER
(INPUT in_Operand_A AS INT64,
 INPUT in_Operand_B AS INT64):
   DEFINE VARIABLE in_cbit     AS INTEGER     NO-UNDO.
   DEFINE VARIABLE in_result   AS INT64     NO-UNDO.
   DO in_cbit = 1 TO 64:
      IF LOGICAL( GET-BITS( in_Operand_A, in_cbit, 1 ) ) AND
         LOGICAL( GET-BITS( in_Operand_B, in_cbit, 1 ) )
      THEN
         PUT-BITS( in_result, in_cbit, 1 ) = 1.
  END.
  RETURN in_result.
END .
FUNCTION intToHex RETURNS CHARACTER
(i_iint AS INT64):
   DEF VAR chex  AS CHAR NO-UNDO.
   DEF VAR rbyte AS RAW  NO-UNDO.
   DO WHILE i_iint > 0:
      PUT-BYTE( rbyte, 1 ) = i_iint MODULO 256.
      chex = STRING( HEX-ENCODE( rbyte ) ) + chex.
      i_iint = TRUNCATE( i_iint / 256, 0 ).
   END.
   RETURN chex.
END .
FUNCTION crc32Table RETURNS INT64 EXTENT 256
():
    DEFINE VARIABLE crc32_tab       AS INT64     NO-UNDO EXTENT 256 INITIAL
        [0x00000000, 0x77073096, 0xEE0E612C, 0x990951BA, 0x076DC419, 0x706AF48F,
        0xE963A535, 0x9E6495A3, 0x0EDB8832, 0x79DCB8A4, 0xE0D5E91E, 0x97D2D988,
        0x09B64C2B, 0x7EB17CBD, 0xE7B82D07, 0x90BF1D91, 0x1DB71064, 0x6AB020F2,
        0xF3B97148, 0x84BE41DE, 0x1ADAD47D, 0x6DDDE4EB, 0xF4D4B551, 0x83D385C7,
        0x136C9856, 0x646BA8C0, 0xFD62F97A, 0x8A65C9EC, 0x14015C4F, 0x63066CD9,
        0xFA0F3D63, 0x8D080DF5, 0x3B6E20C8, 0x4C69105E, 0xD56041E4, 0xA2677172,
        0x3C03E4D1, 0x4B04D447, 0xD20D85FD, 0xA50AB56B, 0x35B5A8FA, 0x42B2986C,
        0xDBBBC9D6, 0xACBCF940, 0x32D86CE3, 0x45DF5C75, 0xDCD60DCF, 0xABD13D59,
        0x26D930AC, 0x51DE003A, 0xC8D75180, 0xBFD06116, 0x21B4F4B5, 0x56B3C423,
        0xCFBA9599, 0xB8BDA50F, 0x2802B89E, 0x5F058808, 0xC60CD9B2, 0xB10BE924,
        0x2F6F7C87, 0x58684C11, 0xC1611DAB, 0xB6662D3D, 0x76DC4190, 0x01DB7106,
        0x98D220BC, 0xEFD5102A, 0x71B18589, 0x06B6B51F, 0x9FBFE4A5, 0xE8B8D433,
        0x7807C9A2, 0x0F00F934, 0x9609A88E, 0xE10E9818, 0x7F6A0DBB, 0x086D3D2D,
        0x91646C97, 0xE6635C01, 0x6B6B51F4, 0x1C6C6162, 0x856530D8, 0xF262004E,
        0x6C0695ED, 0x1B01A57B, 0x8208F4C1, 0xF50FC457, 0x65B0D9C6, 0x12B7E950,
        0x8BBEB8EA, 0xFCB9887C, 0x62DD1DDF, 0x15DA2D49, 0x8CD37CF3, 0xFBD44C65,
        0x4DB26158, 0x3AB551CE, 0xA3BC0074, 0xD4BB30E2, 0x4ADFA541, 0x3DD895D7,
        0xA4D1C46D, 0xD3D6F4FB, 0x4369E96A, 0x346ED9FC, 0xAD678846, 0xDA60B8D0,
        0x44042D73, 0x33031DE5, 0xAA0A4C5F, 0xDD0D7CC9, 0x5005713C, 0x270241AA,
        0xBE0B1010, 0xC90C2086, 0x5768B525, 0x206F85B3, 0xB966D409, 0xCE61E49F,
        0x5EDEF90E, 0x29D9C998, 0xB0D09822, 0xC7D7A8B4, 0x59B33D17, 0x2EB40D81,
        0xB7BD5C3B, 0xC0BA6CAD, 0xEDB88320, 0x9ABFB3B6, 0x03B6E20C, 0x74B1D29A,
        0xEAD54739, 0x9DD277AF, 0x04DB2615, 0x73DC1683, 0xE3630B12, 0x94643B84,
        0x0D6D6A3E, 0x7A6A5AA8, 0xE40ECF0B, 0x9309FF9D, 0x0A00AE27, 0x7D079EB1,
        0xF00F9344, 0x8708A3D2, 0x1E01F268, 0x6906C2FE, 0xF762575D, 0x806567CB,
        0x196C3671, 0x6E6B06E7, 0xFED41B76, 0x89D32BE0, 0x10DA7A5A, 0x67DD4ACC,
        0xF9B9DF6F, 0x8EBEEFF9, 0x17B7BE43, 0x60B08ED5, 0xD6D6A3E8, 0xA1D1937E,
        0x38D8C2C4, 0x4FDFF252, 0xD1BB67F1, 0xA6BC5767, 0x3FB506DD, 0x48B2364B,
        0xD80D2BDA, 0xAF0A1B4C, 0x36034AF6, 0x41047A60, 0xDF60EFC3, 0xA867DF55,
        0x316E8EEF, 0x4669BE79, 0xCB61B38C, 0xBC66831A, 0x256FD2A0, 0x5268E236,
        0xCC0C7795, 0xBB0B4703, 0x220216B9, 0x5505262F, 0xC5BA3BBE, 0xB2BD0B28,
        0x2BB45A92, 0x5CB36A04, 0xC2D7FFA7, 0xB5D0CF31, 0x2CD99E8B, 0x5BDEAE1D,
        0x9B64C2B0, 0xEC63F226, 0x756AA39C, 0x026D930A, 0x9C0906A9, 0xEB0E363F,
        0x72076785, 0x05005713, 0x95BF4A82, 0xE2B87A14, 0x7BB12BAE, 0x0CB61B38,
        0x92D28E9B, 0xE5D5BE0D, 0x7CDCEFB7, 0x0BDBDF21, 0x86D3D2D4, 0xF1D4E242,
        0x68DDB3F8, 0x1FDA836E, 0x81BE16CD, 0xF6B9265B, 0x6FB077E1, 0x18B74777,
        0x88085AE6, 0xFF0F6A70, 0x66063BCA, 0x11010B5C, 0x8F659EFF, 0xF862AE69,
        0x616BFFD3, 0x166CCF45, 0xA00AE278, 0xD70DD2EE, 0x4E048354, 0x3903B3C2,
        0xA7672661, 0xD06016F7, 0x4969474D, 0x3E6E77DB, 0xAED16A4A, 0xD9D65ADC,
        0x40DF0B66, 0x37D83BF0, 0xA9BCAE53, 0xDEBB9EC5, 0x47B2CF7F, 0x30B5FFE9,
        0xBDBDF21C, 0xCABAC28A, 0x53B39330, 0x24B4A3A6, 0xBAD03605, 0xCDD70693,
        0x54DE5729, 0x23D967BF, 0xB3667A2E, 0xC4614AB8, 0x5D681B02, 0x2A6F2B94,
        0xB40BBE37, 0xC30C8EA1, 0x5A05DF1B, 0x2D02EF8D].
    RETURN crc32_tab.
END .
FUNCTION CRC32 RETURNS INT64
(INPUT mpData AS MEMPTR):
    DEFINE VARIABLE IN_BYtes_Size   AS INTEGER   NO-UNDO.
    DEFINE VARIABLE in_byte         AS INTEGER   NO-UNDO.
    DEFINE VARIABLE crc_value       AS INT64     NO-UNDO.
    DEFINE VARIABLE tmp             AS INT64     NO-UNDO.
    DEFINE VARIABLE crc32_tab       AS INT64     NO-UNDO EXTENT 256.
    DEFINE VARIABLE in_loop         AS INTEGER     NO-UNDO.
    crc32_tab = crc32Table().
    crc_value = 0xffffffff.
    In_Bytes_Size = GET-SIZE(mpData).
    DO in_loop = 1 TO In_Bytes_Size:
        tmp = BinaryXOR(crc_value, GET-BYTE(mpData,in_loop )).
        crc_value = BinaryXOR( ShiftRight(crc_value, 8), crc32_tab[BinaryAND(tmp,0x00ff) + 1 ] ).
    END.
    crc_value = BinaryXOR(crc_value, 0xffffffff).
    RETURN crc_value.
END .
define temp-table tt-code like code.
function getCashparamHash returns character ():
    define variable exp as ibs.th.bge.xmlimpexp no-undo.
    define variable hQuery   as handle  no-undo .
    define buffer Buf_code for tt-code.
    define buffer     code for    code.
    FOR EACH code where code.parent begins 'cash-param'
                    and num-entries(code.parent,chr(4)) eq 4
    no-lock:
       create Buf_code.
       buffer-copy code except export_ nwsgbd procview procedit to Buf_code.
    end.
    create query hQuery.
    hQuery:set-buffers(buffer Buf_code :HANDLE).
    hQuery:query-prepare("FOR EACH Buf_code").
    hQuery:query-open ().
    exp = new ibs.th.bge.xmlimpexp ().
    exp:updatetableforxml(hQuery).
    delete object hQuery.
    FOR EACH buf_code:
       delete buf_code.
    end.
    define variable vxmlCode as character  no-undo.
    define variable v-md5-signature as character no-undo.
    exp:xmldom-save  ( "cashparammd5.xml" ).
    vxmlCode = search("cashparammd5.xml").
    run gbl/md5.p (
          input  vxmlCode
         ,output v-md5-signature
         ) .
    os-delete value (vxmlCode).
    delete object exp.
    return encode(v-md5-signature + "sysadm" ) + string(index(encode(string(v-md5-signature)), "k"))
  .
end.
function getCashParamHashDb returns character (idb as int):
   define buffer code for ub.code.
   find first code where code.parent eq "CashParamHash"
                     and code.code   eq  string(idb)
   no-lock no-error.
   return if available code then Code.CodeValue else ?.
end.
procedure saveCashParHash:
   define input  parameter iDb as integer no-undo.
   define buffer code for ub.code.
   find first code where code.parent eq ""
                     and code.code   eq "CashParamHash"
   no-lock no-error.
   if not available code
   then do:
      create code.
      assign
         Code.parent   = ""
         Code.code     = "CashParamHash"
         Code.CodeName = "Конрольная сумма Эталонных параметров для кассы"
      .
   end.
   find first code where code.parent eq "CashParamHash"
                     and code.code   eq  string(idb)
   exclusive-lock no-error.
   if not available code
   then do:
      create Code.
      assign
         code.parent = "CashParamHash"
         code.code   =  string(idb)
         Code.nwsubd = yes
      .
   end.
   Code.CodeName  = string(now).
   Code.CodeValue = getCashparamHash().
end.
procedure m-cash-param-exe :
   define variable v-current-db-num as integer   no-undo .
   def var vlist as char no-undo.
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output v-current-db-num
  )  .
   if v-current-db-num ne 0
   then
      run saveCashParHash(v-current-db-num).
   vList = "cashp1,cashp2".
   if vList ne ""
   then do:
      run str/diallog.w (
        input parparentproc
      , input this-procedure
      , input "str/send-all.p":U
      , input ( v-cntxt-obj-type + chr(4) + string(v-cntxt-obj-code) + chr(4) + 'U':U + chr(4) + vList + chr(4) + 'Получение параметров кассы':U + chr(4) + "cash-send=all,SocetLog=cashparam.log")
      , input ?
      , input "":U
      , input substitute("Получение параметров кассы")
      ) no-error.
      run bge\send1cerp.p (?,
                      this-procedure,
                      this-procedure,
                      "CashParamControl",
                      ?,
                      ?,
                      ?).
      run bge\send1cerp.p (?,
                      this-procedure,
                      this-procedure,
                      "CashParamHist",
                      ?,
                      ?,
                      ?).
   end.
end procedure.
procedure m-catalog-petrol-exe :
 run str/diallog.w (
        input parparentproc
      , input this-procedure
      , input "str/sendpetrol.p":U
      , input ( v-cntxt-obj-type + chr(4) + string(v-cntxt-obj-code) + chr(4) + 'U':U)
      , input no
      , input "":U
      , input substitute("Отсылка данных по соответствию товаров/кошельков ")
  ) no-error.
end procedure.
procedure m-cash-petrol-del-exe :
 run str/diallog.w (
        input parparentproc
      , input this-procedure
      , input "str/sendpetrol.p":U
      , input ( v-cntxt-obj-type + chr(4) + string(v-cntxt-obj-code) + chr(4) + 'D':U)
      , input no
      , input "":U
      , input substitute("Удаление данных по соответствию товаров/кошельков ")
  ) no-error.
end procedure.
procedure m-promo-d-exe :
  do
  on error undo, return error return-value
  :
    run promosend in this-procedure ('IBM-XML':U, 'D':U) .
  end.
end procedure.
procedure m-catalog-block-nozzle :
  define variable v-current-db-num as integer   no-undo .
  define variable v-obj-db-num     as integer   no-undo .
  do
  on error undo, return error return-value
  :
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output v-current-db-num
  )  .
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdbnum in g#library
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-obj-db-num
  )  .
    if v-current-db-num = v-obj-db-num
    then do:
      run str/blockplgdspm.w
        (input parparentproc
        ,input v-cntxt-obj-type
        ,input v-cntxt-obj-code
        ,input 'block'
        ) .
    end.
    else do:
      run str/blockplgdspm.w (input parparentproc,
                      input v-cntxt-obj-type,
                      input v-cntxt-obj-code,
                      input '').
    end.
  end.
end procedure.
procedure m-catalog-unblock-nozzle :
  define variable v-current-db-num as integer   no-undo .
  define variable v-obj-db-num     as integer   no-undo .
  do
  on error undo, return error return-value
  :
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output v-current-db-num
  )  .
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdbnum in g#library
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-obj-db-num
  )  .
    if v-current-db-num = v-obj-db-num
    then do:
      run str/blockplgdspm.w
        (input parparentproc
        ,input v-cntxt-obj-type
        ,input v-cntxt-obj-code
        ,input 'un-block'
        ) .
    end.
    else do:
      run str/blockplgdspm.w (input parparentproc,
                      input v-cntxt-obj-type,
                      input v-cntxt-obj-code,
                      input '').
    end.
  end.
end procedure.
procedure m-bpa-u-exe :
  do
  on error undo, return error return-value
  :
    run bpasend in this-procedure ('IBM-XML':U, 'U':U) .
  end.
end procedure.
procedure m-bpa-d-exe :
  do
  on error undo, return error return-value
  :
    run bpasend in this-procedure ('IBM-XML':U, 'D':U) .
  end.
end procedure.
procedure m-gds-ef-exe :
define variable v-rid-list as character no-undo .
  do
  on error undo, return error
  :
      define variable v-row as rowid no-undo .
      define buffer buf_PromoAction for ub.PromoAction .
      define variable v-PromoName as character no-undo .
    if v-cntxt-db-num = 0 then
    do:
      for each buf_PromoAction exclusive-lock where buf_PromoAction.Status_ = 1 and
        (buf_PromoAction.end-date < today or (buf_PromoAction.changeDate < today and
        buf_PromoAction.changeDate <> 01/01/1970)):
        buf_PromoAction.Status_ = 2 .
        v-PromoName = v-PromoName + chr(10) + buf_PromoAction.nameAction .
      end.
      if v-PromoName <> "" then
      do:
        message "Статус был изменен на Заблокирован для акций:" skip
          skip
          v-PromoName
          view-as alert-box.
      end.
    end.
    run ref/promo.p ( input parparentproc, input false, output v-rid-list) no-error.
  end.
end procedure.
procedure m-platsys-exe :
define variable v-rid-list as character no-undo .
  do
  on error undo, return error
  :
    run ref/codelay.p (parparentproc, "", "", "platsys", "Платежные системы") no-error.
  end.
end procedure.
procedure m-corrsys-exe :
define variable v-rid-list as character no-undo .
  do
  on error undo, return error
  :
    run ref/codelay.p (parparentproc, "", "", "OsnovCorr", "Основание коррекции") no-error.
  end.
end procedure.
procedure m-device-ref :
define variable v-rid-list as character no-undo .
  do
  on error undo, return error
  :
    run ref/codelay.p (parparentproc, "", "", "SpravDevice", "Справочник устройств") no-error.
  end.
end procedure.
procedure m-cash-wthser-del-exe :
 run str/diallog.w (
        input parparentproc
      , input this-procedure
      , input "str/sendwths.p":U
      , input ( v-cntxt-obj-type + chr(4) + string(v-cntxt-obj-code) + chr(4) + 'D':U)
      , input no
      , input "":U
      , input substitute("Отсылка данных по маскам серийных МЦ на кассы ")
  ) no-error.
end procedure.
procedure m-cash-dept-exe :
  define variable v-obj-db-num  as integer   no-undo initial ? .
  do
  on error undo, return error return-value
  :
define variable vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdbnum in g#library
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-obj-db-num
  )  .
    run str/diallog.w
      (input parparentproc
      ,input this-procedure
      ,input "str/senddept.p":U
      ,input (string(v-obj-db-num) + chr(4) + v-cntxt-obj-type + chr(4) + string(v-cntxt-obj-code) + chr(4) + 'U':U)
      ,input no
      ,input "":U
      ,input substitute("Отсылка данных по подразделениям на кассы БД &1", v-obj-db-num)
      ) no-error.
  end.
end procedure.
procedure proc-chk-docs :
define input parameter p-bttns as character no-undo .
define input parameter p-mode as character no-undo .
DEFINE VARIABLE varrid-list as character no-undo .
  do
  on error undo, return error
  :
    run str/chk-docs.w (
                    input parparentproc
                    ,input p-bttns
                    ,input p-mode
                    ,input ?
                    ,input v-cntxt-obj-type
                    ,input v-cntxt-obj-code
                    ,input '':U
                    ,input '':U
                    ,input 0
                    ,input ?
                    ,input ?
                    ,input 0
                    ,output varrid-list) no-error.
  end.
end procedure.
PROCEDURE m-chk-free-exe :
run proc-chk-docs in this-procedure (input 'b-del', input 'free':U).
END PROCEDURE.
PROCEDURE m-chk-del-exe :
define variable v-rid-list as character no-undo .
 run str/cchkdocs.w (
                        input parparentproc
                       , "b-restore":U
                       , 'удаление':U
                       , "":U
                       , v-cntxt-obj-type
                       , v-cntxt-obj-code
                       , input-output v-rid-list
                    ).
END PROCEDURE.
PROCEDURE m-chk-add-exe :
define variable v-rid-list as character no-undo .
 run str/cchkdocs.w (
                        input parparentproc
                       , "":U
                       , 'ДОБАВЛЕНИЕ':U
                       , "":U
                       , v-cntxt-obj-type
                       , v-cntxt-obj-code
                       , input-output v-rid-list
                    ).
END PROCEDURE.
PROCEDURE m-chk-off-del-exe :
define variable v-rid-list as character no-undo .
 run str/cchkdocs.w (
                        input parparentproc
                       , "":U
                       , 'удаление':U
                       , "":U
                       , v-cntxt-obj-type
                       , v-cntxt-obj-code
                       , input-output v-rid-list
                    ).
END PROCEDURE.
PROCEDURE m-chk-off-add-exe :
define variable v-rid-list as character no-undo .
 run str/cchkdocs.w (
                        input parparentproc
                       , "":U
                       , 'ДОБАВЛЕНИЕ':U
                       , "":U
                       , v-cntxt-obj-type
                       , v-cntxt-obj-code
                       , input-output v-rid-list
                    ).
END PROCEDURE.
PROCEDURE m-chk-list-off-exe :
run proc-chk-docs in this-procedure (input '', input 'объект':U).
END PROCEDURE.
PROCEDURE m-chk-list-all-off-exe :
DEFINE VARIABLE varrid-list as character no-undo .
define variable v-base-code as integer no-undo init ?.
define variable v-not-show  as logical no-undo .
define buffer buf_shop for ub.shop.
define buffer buf_sysconf for ub.sysconf.
_shop:
for each buf_shop no-lock,
    first buf_sysconf no-lock where
          buf_sysconf.host-code = buf_shop.host-code :
  if v-base-code <> ?
  AND buf_sysconf.base-code <> v-base-code then do:
    assign
    v-not-show = yes
    .
    leave _shop.
  end.
  assign
  v-base-code = buf_sysconf.base-code
  .
end.
if v-not-show then do:
  message
  "В Вашей системе имеются магазины, принадлежащие фирмам с разными базовыми валютами" skip
  "Просмотр ВСЕХ чеков невозможен"
  view-as alert-box error .
end.
else do:
  run proc-chk-docs in this-procedure (input '', input 'все':U).
end.
END PROCEDURE.
procedure m-mrkt-petrol-exe :
  run run-mrkt-gds in this-procedure (input yes).
END procedure.
procedure m-mrkt-gds-exe :
  run run-mrkt-gds in this-procedure (input no).
END procedure.
procedure run-mrkt-gds:
define input parameter p-is-petrolium as logical no-undo .
define variable ri-list as character no-undo .
define variable v-plu-type as character no-undo .
define variable dflt-cd as character no-undo .
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-param-type31 as character no-undo .
define variable v-value-date31 as date no-undo .
define variable v-value-decimal31 as decimal no-undo .
define variable v-value-integer31 as INTEGER no-undo .
define variable v-value-logical31 AS LOGICAL no-undo .
define variable v-tth31 as handle no-undo .
run adm/shattri.p (
    input "get":U
    ,input  v-cntxt-obj-type
    ,input  v-cntxt-obj-code
    ,input  'cd-sending':U
    ,input  'dflt-cd':U
    ,output dflt-cd
    ,output v-value-date31
    ,output v-value-decimal31
    ,output v-value-integer31
    ,output v-value-logical31
    ,output v-param-type31
    ,INPUT-OUTPUT table-handle v-tth31
    )  .
delete object v-tth31 no-error.
IF dflt-cd = 'MARIA':U then do:
  assign
  v-plu-type = (if p-is-petrolium
                   then 'топ':U
                   else '':U).
  run str/mrkt-gds.w (
                 input parparentproc
                ,input '':U
                ,input 'объект':U
                ,input v-cntxt-obj-type
                ,input v-cntxt-obj-code
                ,input dflt-cd
                ,input v-plu-type
                ,input-output ri-list) no-error .
end.
else do:
  message
  substitute("Кассы типа &1 на данном объекте не работают", 'MARIA':U)
  view-as alert-box  ERROR.
end.
end procedure.
procedure m-mar-cli-exe :
DEFINE VARIABLE rid-list as character no-undo .
define variable v-delim as character no-undo .
  run str/mar-cli.w (
                 input parparentproc
                ,input '':U
                ,input 'объект':U
                ,input v-cntxt-obj-type
                ,input v-cntxt-obj-code
                ,input 'MARIA':U
                ,input-output rid-list) no-error .
end procedure.
procedure m-rkep-gds-exe :
define variable ri-list as character no-undo .
run str/rkep-gds.w (
                parparentproc
              , '':U
              , 'все':U
              , ('no' + chr(4) + 'no' + chr(4) + 'no' + chr(4) + 'no')
              , v-cntxt-obj-type
              , v-cntxt-obj-code
              , input-output ri-list) no-error .
end procedure.
procedure m-rkep-grp-exe :
define variable ri-list as character no-undo .
run str/rkep-grp.w (
                parparentproc
              , '':U
              , 'все':U
              , ('no' + chr(4) + 'no')
              , v-cntxt-obj-type
              , v-cntxt-obj-code
              , input-output ri-list) no-error .
end procedure.
procedure m-rkep-cli-exe :
define variable ri-list as character no-undo .
run str/rkep-cli.w (
                parparentproc
              , '':U
              , 'все':U
              , ('no' + chr(4) + 'no')
              , v-cntxt-obj-type
              , v-cntxt-obj-code
              , input-output ri-list) no-error .
end procedure.
PROCEDURE obj-sale-exe :
  define variable rid-list    as character no-undo .
  define variable v-host-code as integer   no-undo .
  do
  on error undo, return error return-value
  :
    if v-cntxt-obj-type = 'маг':U
    then do:
define variable vss-include-info32 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-host-code
  )  .
      run str/salelist.w
        (input  parparentproc
        ,input  "b-export":U
        ,input  'объект':U
        ,input  v-host-code
        ,input  v-cntxt-obj-type
        ,input  v-cntxt-obj-code
        ,input-output rid-list
        ) no-error.
    end.
  end.
END PROCEDURE.
PROCEDURE del-sale-exe :
define variable rid-list    as character no-undo .
define variable v-host-code as integer   no-undo .
define variable v-obj-type as character no-undo .
define variable v-obj-code as integer no-undo .
define variable v-mode as character no-undo .
do
on error undo, return error return-value
:
  if v-cntxt-obj-type = 'маг':U
  and v-cntxt-level = 'object':U
  then do:
define variable vss-include-info33 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-host-code
  )  .
    assign
    v-mode = 'удаленные':U + chr(44) + 'объект':U
    v-obj-type = v-cntxt-obj-type
    v-obj-code = v-cntxt-obj-code
    .
  end.
  if v-cntxt-level = 'firm':U
  then do:
    assign
    v-mode = 'удаленные':U + chr(44) + 'фирма':U
    v-host-code = v-cntxt-host-code-obj
    v-obj-type = '':U
    v-obj-code = 0
    .
  end.
  if v-cntxt-level = 'global':U
  then do:
    assign
    v-mode = 'удаленные':U
    v-host-code = 0
    v-obj-type = '':U
    v-obj-code = 0
    .
  end.
  run str/salclist.w
    (input  parparentproc
    ,input  "":U
    ,input  v-mode
    ,input '':U
    ,input  v-host-code
    ,input  v-obj-type
    ,input  v-obj-code
    ,input-output rid-list
    ) no-error.
end.
END PROCEDURE.
PROCEDURE host-sale-exe :
  define variable rid-list    as character no-undo .
  define variable v-host-code as integer   no-undo .
  do
  on error undo, return error return-value
  :
define variable vss-include-info34 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-host-code
  )  .
    run str/salelist.w
      (input  parparentproc
      ,input  "b-export":U
      ,input  'фирма':U
      ,input  v-host-code
      ,input  v-cntxt-obj-type
      ,input  v-cntxt-obj-code
      ,input-output rid-list
      ) no-error.
  end.
END PROCEDURE.
PROCEDURE all-sale-exe :
  define variable rid-list    as character no-undo .
  define variable v-host-code as integer   no-undo .
  define variable v-ok        as logical   no-undo .
  do
  on error undo, return error return-value
  :
define variable vss-include-info35 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_documents_all':U
    ,input  'global':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output v-ok
    )  .
end.
    if v-ok = true
    then do:
define variable vss-include-info36 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-host-code
  )  .
      run str/salelist.w
        (input  parparentproc
        ,input  'b-export':U
        ,input  'все':U
        ,input  v-host-code
        ,input  v-cntxt-obj-type
        ,input  v-cntxt-obj-code
        ,input-output rid-list
        ) no-error.
    end.
  end.
END PROCEDURE.
PROCEDURE m-chk-sl-exe :
  define variable rid-list    as character no-undo .
  define variable v-host-code as integer   no-undo .
  do
  on error undo, return error return-value
  :
define variable vss-include-info37 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-host-code
  )  .
    run str/salelist.w
      (input  parparentproc
      ,input  "":U
      ,input  'объект':U
      ,input  v-host-code
      ,input  v-cntxt-obj-type
      ,input  v-cntxt-obj-code
      ,input-output rid-list
      ) no-error.
  end.
END PROCEDURE.
PROCEDURE m-sale-lkp-exe :
  define variable rid-list    as character no-undo .
  define variable v-host-code as integer   no-undo .
  do
  on error undo, return error return-value
  :
define variable vss-include-info38 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-host-code
  )  .
    run str/salelist.w
      (input  parparentproc
      ,input  "b-add":U
      ,input  'новый':U
      ,input  v-host-code
      ,input  v-cntxt-obj-type
      ,input  v-cntxt-obj-code
      ,input-output rid-list
      ) no-error.
  end.
END PROCEDURE.
PROCEDURE m-chk-sale-exe :
define variable v-inkas-code as character no-undo .
run str/cre-sale.p ( input parparentproc
                   , input v-cntxt-obj-type
                   , input v-cntxt-obj-code
                   , input 'ИЗМЕНЕНИЕ':U
                   , input 0
                   , input '':U
                   , input-output v-inkas-code
                   , input 'касс':U).
END PROCEDURE.
PROCEDURE m-sale-inf-exe :
  define variable not-all-saled-chk    as logical   no-undo initial no .
  define variable not-all-normal-chk       as logical   no-undo initial no .
  define variable not-all-inkas-closed as logical   no-undo initial no .
  define variable v-host-code              as integer   no-undo .
  define variable v-notes                  as character no-undo .
  do
  on error undo, return error return-value
  :
define variable vss-include-info39 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-host-code
  )  .
    run str/chk-inf.p
      (input  parparentproc
      ,input  v-host-code
      ,input  v-cntxt-obj-type
      ,input  v-cntxt-obj-code
      ,input  yes
      ,input  no
      ,input  ?
      ,output v-notes
      ,output not-all-saled-chk
      ,output not-all-normal-chk
      ,output not-all-inkas-closed
      ) no-error.
  end.
END PROCEDURE.
PROCEDURE m-chk-wth-r-exe :
  define variable v-host-code as integer   no-undo .
  do
  on error undo, return error return-value
  :
define variable vss-include-info40 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-host-code
  )  .
    run str/inc-wth.w
      (input parparentproc
      ,input  v-host-code
      ,input  v-cntxt-obj-type
      ,input  v-cntxt-obj-code
      ).
  end.
END PROCEDURE.
PROCEDURE m-chk-wth-inf-exe :
  define variable not-all-doced  as logical   no-undo init no .
  define variable not-all-normal as logical   no-undo init no .
  define variable not-all-closed as logical   no-undo init no .
  define variable v-host-code    as integer   no-undo .
  define variable v-notes        as character no-undo .
  do
  on error undo, return error return-value
  :
define variable vss-include-info41 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-host-code
  )  .
    run str/chk-winf.p
      (input  parparentproc
      ,input  v-host-code
      ,input  v-cntxt-obj-type
      ,input  v-cntxt-obj-code
      ,input  yes
      ,input  no
      ,input  ?
      ,output v-notes
      ,output not-all-doced
      ,output not-all-normal
      ,output not-all-closed
      ).
  end.
END.
PROCEDURE m_scgdsobj-exe :
  run ref/scgdsobj.w
    (input  parparentproc
    ,input  'объект':U
    ,input  v-cntxt-obj-type
    ,input  v-cntxt-obj-code
    ) .
END PROCEDURE.
PROCEDURE m_loc-ss-code-exe :
  define variable loc-ref-list as character no-undo .
  define variable v-host-code as integer no-undo .
  do
  on error undo, return error return-value
  :
define variable vss-include-info42 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-host-code
  )  .
    run ref/locsscds.w
      (input  parparentproc
      ,input  "":U
      ,input  "":U
      ,input  v-host-code
      ,input  v-cntxt-obj-type
      ,input  v-cntxt-obj-code
      ,output loc-ref-list
      ).
  end.
END PROCEDURE.
PROCEDURE m_pl-list :
  define variable ri-list          as character no-undo .
  do
  on error undo, return error return-value
  :
    if v-cntxt-db-num = v-cntxt-db-num-obj
    then do:
      run ref/pl-list.w
        (input  parparentproc
        ,input  'b-add'
        ,input  v-cntxt-obj-type
        ,input  v-cntxt-obj-code
        ,input  'объект':U
        ,input-output ri-list
        ).
    end.
    else do:
      run ref/pl-list.w
        (input  parparentproc
        ,input  ''
        ,input  v-cntxt-obj-type
        ,input  v-cntxt-obj-code
        ,input  'объект':U
        ,input-output ri-list
        ).
    end.
  end.
END PROCEDURE.
PROCEDURE m_sr-izmeren :
  define variable v-node-code as integer no-undo.
  define variable v-sr-type as character no-undo.
  do
  on error undo, return error return-value
  :
   v-node-code = 0 .
   run ref/sr-izm.w (input parparentproc
                    ,input "b-add"
                    ,input 'ИЗМЕНЕНИЕ':U
                    ,input ""
                    ,input ""
                    ,input-output v-node-code
                    ,output v-sr-type
                    ).
  end.
END PROCEDURE.
PROCEDURE m_place-io-exe :
  define variable ri-list          as character no-undo .
  do
  on error undo, return error return-value
  :
    if v-cntxt-db-num = v-cntxt-db-num-obj
    then do:
      run ref/place-io.w
        (input  parparentproc
        ,input  'b-add'
        ,input  v-cntxt-obj-type
        ,input  v-cntxt-obj-code
        ,input  'объект':U
        ,input  'all'
        ,input-output ri-list
        ).
    end.
    else do:
      run ref/place-io.w
        (input  parparentproc
        ,input  ''
        ,input  v-cntxt-obj-type
        ,input  v-cntxt-obj-code
        ,input  'объект':U
        ,input  'all'
        ,input-output ri-list
        ).
    end.
  end.
END PROCEDURE.
PROCEDURE m_point-io-exe  :
  define variable ri-list          as character no-undo .
  do
  on error undo, return error return-value
  :
    run ref/point-io.w
        (input  parparentproc
        ,input  'b-add'
        ,input  v-cntxt-db-num
        ,input  ''
        ,input  0
        ,input  'объект':U
        ,input  'all'
        ,input-output ri-list
        ).
  end.
END PROCEDURE.
PROCEDURE m_pl-pump-nozzle :
  define variable rid#             as recid     no-undo .
  do
  on error undo, return error return-value
  :
    if v-cntxt-db-num = v-cntxt-db-num-obj
    then do:
      run str/plpumpnz.w
        (input  parparentproc
        ,input  'b-add|b-del':U
        ,output rid#
        ).
    end.
    else do:
      run str/plpumpnz.w
        (input  parparentproc
        ,input  'b-help':U
        ,output rid#
        ).
    end.
  end.
END PROCEDURE.
procedure m_auto-tank :
  define variable varrec-tank      as recid no-undo.
  define variable varrec-meas      as recid no-undo.
  do
  on error undo, return error return-value
  :
    if v-cntxt-db-num = 0
    then do:
      run str/auto-tn.w
        (input parparentproc
        ,input  'b-add,b-chg,b-del':u
        ,input ""
        ,input 0
        ,output varrec-tank
        ,output varrec-meas
        ) .
    end.
    else do:
      run str/auto-tn.w
        (input parparentproc
        ,input  '':u
        ,input ""
        ,input 0
        ,output varrec-tank
        ,output varrec-meas
        ) .
    end.
  end.
end procedure.
procedure m_pl-all-list :
  define variable ri-list as character no-undo .
  do
  on error undo, return error return-value
  :
    run ref/pl-list.w
      (input  parparentproc
      ,input  ''
      ,input  v-cntxt-obj-type
      ,input  v-cntxt-obj-code
      ,input  'все':U
      ,input-output ri-list
      ).
  end.
end procedure.
PROCEDURE m_wth-ref :
  define variable ri-list          as character no-undo .
  do
  on error undo, return error return-value
  :
    if v-cntxt-db-num = 0
    then do:
      run ref/wth-ref.w
        (input parparentproc
        ,input 'b-add':u
        ,input v-cntxt-host-code-obj
        ,input v-cntxt-obj-type
        ,input v-cntxt-obj-code
        ,input 'все':U
        ,input-output ri-list
        ).
    end.
    else do:
      run ref/wth-ref.w
        (input parparentproc
        ,input '':U
        ,input v-cntxt-host-code-obj
        ,input v-cntxt-obj-type
        ,input v-cntxt-obj-code
        ,input 'все':U
        ,input-output ri-list
        ).
    end.
  end.
END PROCEDURE.
PROCEDURE m_wthp-ref :
  define variable ri-list          as character no-undo .
  do
  on error undo, return error return-value
  :
    if v-cntxt-db-num = 0
    then do:
      run ref/wthp-ref.w
        (input parparentproc
        ,input 'b-add':u
        ,input v-cntxt-host-code-obj
        ,input v-cntxt-obj-type
        ,input v-cntxt-obj-code
        ,input 'все':U
        ,input 0
        ,input-output ri-list
        ) .
    end.
    else do:
      run ref/wthp-ref.w
        (input parparentproc
        ,input '':U
        ,input v-cntxt-host-code-obj
        ,input v-cntxt-obj-type
        ,input v-cntxt-obj-code
        ,input 'все':U
        ,input 0
        ,input-output ri-list
        ) .
    end.
  end.
END PROCEDURE.
PROCEDURE m_wths-ref :
  define variable rid-list          as character no-undo .
  do
  on error undo, return error return-value
  :
      run ref/wths-ref.w
        (input parparentproc
        ,input 'b-add,b-chg,b-del':u
        ,input v-cntxt-host-code-obj
        ,input v-cntxt-obj-type
        ,input v-cntxt-obj-code
        ,input 'все':U
        ,input 0
        ,input 0
        ,input-output rid-list
        ) .
  end.
END PROCEDURE.
PROCEDURE m_wth-pl-list :
  define variable ri-list          as character no-undo .
  do
  on error undo, return error return-value
  :
    if v-cntxt-db-num = v-cntxt-db-num-obj
    then do:
      run ref/wthplref.w
        (input parparentproc
        ,input 'b-add':u
        ,input v-cntxt-host-code-obj
        ,input v-cntxt-obj-type
        ,input v-cntxt-obj-code
        ,input 'объект':U
        ,input-output ri-list
        ).
    end.
    else do:
      run ref/wthplref.w
        (input parparentproc
        ,input '':u
        ,input v-cntxt-host-code-obj
        ,input v-cntxt-obj-type
        ,input v-cntxt-obj-code
        ,input 'объект':U
        ,input-output ri-list
        ).
    end.
  end.
END PROCEDURE.
PROCEDURE m_wth-pl-host-list :
  define variable ri-list as character no-undo .
  do
  on error undo, return error return-value
  :
    run ref/wthplref.w
      (input parparentproc
      ,input ''
      ,input v-cntxt-host-code-obj
      ,input v-cntxt-obj-type
      ,input v-cntxt-obj-code
      ,input 'фирма':U
      ,input-output ri-list
      ).
  end.
END PROCEDURE.
PROCEDURE m_wth-pl-all-list :
  define variable ri-list as character no-undo .
  do
  on error undo, return error return-value
  :
    run ref/wthplref.w
      (input parparentproc
      ,input ''
      ,input v-cntxt-host-code-obj
      ,input v-cntxt-obj-type
      ,input v-cntxt-obj-code
      ,input 'все':U
      ,input-output ri-list
      ).
  end.
END PROCEDURE.
procedure wth-docs-exe :
  define input parameter p-mode as character no-undo .
  define input parameter p-doc-type as character no-undo .
  define input parameter p-ext-type as character no-undo.
  define input parameter p-status as character no-undo.
  define variable ri-list as character no-undo .
  do
  on error undo, return error return-value
  :
    run str/wth-docs.w
      (input  parparentproc
      ,input  'b-add'
      ,input  p-mode
      ,input  v-cntxt-host-code-obj
      ,input  v-cntxt-obj-type
      ,input  v-cntxt-obj-code
      ,input  '':u
      ,input  0
      ,input  p-ext-type
      ,input  p-status
      ,input  p-doc-type
      ,input-output ri-list
      ).
  end.
end PROCEDURE.
procedure c-wth-doc-exe :
  define input parameter p-mode     as character no-undo .
  define input parameter p-doc-type as character no-undo .
  define variable ri-list as character no-undo .
  do
  on error undo, return error return-value
  :
    run str/wthcdocs.w
      (input  parparentproc
      ,input  'b-add'
      ,input  p-mode
      ,input  v-cntxt-host-code-obj
      ,input  v-cntxt-obj-type
      ,input  v-cntxt-obj-code
      ,input  '':U
      ,input  0
      ,input  p-doc-type
      ,input '':U
      ,output ri-list
      ).
  end.
end PROCEDURE.
PROCEDURE m__all-exe :
  do
  on error undo, return error return-value
  :
    run sel-cur-menu-grp in parparentproc
      (input 'all':u
      ) no-error .
    if error-status :error
    then do:
      return error.
    end.
  end.
END PROCEDURE.
PROCEDURE m_help-exe :
  do
  on error undo, return error return-value
  :
    run run-help in parparentproc no-error .
  end.
END PROCEDURE.
PROCEDURE m_exit-exe :
  do
  on error undo, return error return-value
  :
    apply 'close' to parparentproc.
  end.
END PROCEDURE.
PROCEDURE new-all-rvs :
define variable v-rvs-rid as recid no-undo.
run str/all-rvs.w (input parparentproc, input 'статус':U, input 'новый':U, output v-rvs-rid).
END PROCEDURE.
PROCEDURE prm-all-rvs :
define variable v-rvs-rid as recid no-undo.
run str/all-rvs.w (input parparentproc, input 'статус':U, input 'разрешен':U, output v-rvs-rid).
END PROCEDURE.
PROCEDURE fact-all-rvs :
define variable v-rvs-rid as recid no-undo.
run str/all-rvs.w (input parparentproc, input 'статус':U, input 'факт':U, output v-rvs-rid).
END PROCEDURE.
PROCEDURE obj-all-rvs :
define variable v-rvs-rid as recid no-undo.
run str/all-rvs.w (input parparentproc, input 'объект':U, input ?, output v-rvs-rid).
END PROCEDURE.
PROCEDURE c-obj-rvs-exe :
define variable v-rvs-rid as recid no-undo.
run str/rvsalldocws-c.w (input parparentproc, input 'объект':U, input ?, output v-rvs-rid).
END PROCEDURE.
PROCEDURE firm-all-rvs :
define variable v-rvs-rid as recid no-undo.
run str/all-rvs.w (input parparentproc, input 'фирма':U, input ?, output v-rvs-rid).
END PROCEDURE.
PROCEDURE all-all-rvs :
  define variable v-rvs-rid as recid no-undo.
  define variable v-ok as logical   no-undo .
define variable vss-include-info43 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_documents_all':U
    ,input  'global':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output v-ok
    )  .
end.
  if v-ok then do:
    run str/all-rvs.w (input parparentproc, input 'работа':U, input ?, output v-rvs-rid).
  end.
END PROCEDURE.
PROCEDURE new-all-test-asi :
define variable v-rvs-rid as recid no-undo.
run str/all-test-asi.w (input parparentproc, input 'статус':U, input 'новый':U, output v-rvs-rid).
END PROCEDURE.
PROCEDURE fact-all-test-asi :
define variable v-rvs-rid as recid no-undo.
run str/all-test-asi.w (input parparentproc, input 'статус':U, input 'факт':U, output v-rvs-rid).
END PROCEDURE.
PROCEDURE obj-all-test-asi :
define variable v-rvs-rid as recid no-undo.
run str/all-test-asi.w (input parparentproc, input 'объект':U, input ?, output v-rvs-rid).
END PROCEDURE.
PROCEDURE c-obj-test-asi :
define variable v-rvs-rid as recid no-undo.
run str/test-asi_alldocws-c.w (input parparentproc, input 'объект':U, input ?, output v-rvs-rid).
END PROCEDURE.
PROCEDURE firm-all-test-asi :
define variable v-rvs-rid as recid no-undo.
run str/all-test-asi.w (input parparentproc, input 'фирма':U, input ?, output v-rvs-rid).
END PROCEDURE.
PROCEDURE all-all-test-asi :
  define variable v-rvs-rid as recid no-undo.
  define variable v-ok as logical   no-undo .
define variable vss-include-info44 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_documents_all':U
    ,input  'global':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output v-ok
    )  .
end.
  if v-ok then do:
    run str/all-test-asi.w (input parparentproc, input 'работа':U, input ?, output v-rvs-rid).
  end.
END PROCEDURE.
PROCEDURE new-all-icnt :
define variable v-rid-list as character no-undo .
run ref/icntdocs.w ( input parparentproc
                   , input 'b-add':U
                   , input 'статус':U
                   , input 'новый':U
                   , input 'инв-сч-трк':U
                   , input v-cntxt-host-code-obj
                   , input v-cntxt-obj-type
                   , input v-cntxt-obj-code
                   , input-output v-rid-list
                   ) no-error .
END PROCEDURE.
PROCEDURE fact-all-icnt :
define variable v-rid-list as character no-undo .
run ref/icntdocs.w ( input parparentproc
                   , input '':U
                   , input 'статус':U
                   , input 'факт':U
                   , input 'инв-сч-трк':U
                   , input v-cntxt-host-code-obj
                   , input v-cntxt-obj-type
                   , input v-cntxt-obj-code
                   , input-output v-rid-list
                   ) no-error .
END PROCEDURE.
PROCEDURE obj-all-icnt :
define variable v-rid-list as character no-undo .
run ref/icntdocs.w ( input parparentproc
                   , input 'b-add':U
                   , input 'объект':U
                   , input ?
                   , input 'инв-сч-трк':U
                   , input v-cntxt-host-code-obj
                   , input v-cntxt-obj-type
                   , input v-cntxt-obj-code
                   , input-output v-rid-list
                   ) no-error .
END PROCEDURE.
PROCEDURE firm-all-icnt :
define variable v-rid-list as character no-undo .
run ref/icntdocs.w ( input parparentproc
                   , input '':U
                   , input 'фирма':U
                   , input ?
                   , input 'инв-сч-трк':U
                   , input v-cntxt-host-code-obj
                   , input v-cntxt-obj-type
                   , input v-cntxt-obj-code
                   , input-output v-rid-list
                   ) no-error .
END PROCEDURE.
PROCEDURE all-all-icnt :
  define variable v-ok as logical   no-undo .
define variable vss-include-info45 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_documents_all':U
    ,input  'global':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output v-ok
    )  .
end.
  if v-ok
  then do:
    define variable v-rid-list as character no-undo .
    run ref/icntdocs.w ( input parparentproc
                      , input '':U
                      , input 'все':U
                      , input ?
                      , input 'инв-сч-трк':U
                      , input v-cntxt-host-code-obj
                      , input v-cntxt-obj-type
                      , input v-cntxt-obj-code
                      , input-output v-rid-list
                      ) no-error .
  end.
END PROCEDURE.
PROCEDURE new-all-eicnt :
define variable v-rid-list as character no-undo .
run ref/icntdocs.w ( input parparentproc
                   , input 'b-add':U
                   , input 'статус':U
                   , input 'новый':U
                   , input 'сч-трк-погр':U
                   , input v-cntxt-host-code-obj
                   , input v-cntxt-obj-type
                   , input v-cntxt-obj-code
                   , input-output v-rid-list
                   ) no-error .
END PROCEDURE.
PROCEDURE fact-all-eicnt :
define variable v-rid-list as character no-undo .
run ref/icntdocs.w ( input parparentproc
                   , input '':U
                   , input 'статус':U
                   , input 'факт':U
                   , input 'сч-трк-погр':U
                   , input v-cntxt-host-code-obj
                   , input v-cntxt-obj-type
                   , input v-cntxt-obj-code
                   , input-output v-rid-list
                   ) no-error .
END PROCEDURE.
PROCEDURE obj-all-eicnt :
define variable v-rid-list as character no-undo .
run ref/icntdocs.w ( input parparentproc
                   , input 'b-add':U
                   , input 'объект':U
                   , input ?
                   , input 'сч-трк-погр':U
                   , input v-cntxt-host-code-obj
                   , input v-cntxt-obj-type
                   , input v-cntxt-obj-code
                   , input-output v-rid-list
                   ) no-error .
END PROCEDURE.
PROCEDURE firm-all-eicnt :
define variable v-rid-list as character no-undo .
run ref/icntdocs.w ( input parparentproc
                   , input '':U
                   , input 'фирма':U
                   , input ?
                   , input 'сч-трк-погр':U
                   , input v-cntxt-host-code-obj
                   , input v-cntxt-obj-type
                   , input v-cntxt-obj-code
                   , input-output v-rid-list
                   ) no-error .
END PROCEDURE.
PROCEDURE all-all-eicnt :
  define variable v-ok as logical   no-undo .
define variable vss-include-info46 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_documents_all':U
    ,input  'global':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output v-ok
    )  .
end.
  if v-ok
  then do:
    define variable v-rid-list as character no-undo .
    run ref/icntdocs.w ( input parparentproc
                      , input '':U
                      , input 'все':U
                      , input ?
                      , input 'сч-трк-погр':U
                      , input v-cntxt-host-code-obj
                      , input v-cntxt-obj-type
                      , input v-cntxt-obj-code
                      , input-output v-rid-list
                      ) no-error .
  end.
END PROCEDURE.
procedure c-m-all-exe :
  run c-trn-doc-all-exe in this-procedure ( input ? ).
end procedure.
procedure dm-c-doc-exe :
  define input parameter parlistmode     as character no-undo.
  define input parameter parflag         as logical   no-undo.
  define input parameter parstat         as character no-undo.
  define input parameter partype         as character no-undo.
  define input parameter parinternal     as logical   no-undo.
  define input parameter parext-doc-type as character no-undo.
  define input parameter paris-hold      as logical   no-undo.
  define variable loc-ref-list as character no-undo.
  run str/calldocs.w (  input parparentproc,
                    input ( if parlistmode = "?" then ? else parlistmode ),
                    input ( if parstat     = "?" then ? else parstat     ),
                    input ( if partype     = "?" then ? else partype     ),
                    input ?,
                    input parinternal,
                    input "":U,
                    input parext-doc-type,
                    input paris-hold,
                    input ?,
                    input v-cntxt-obj-type,
                    input v-cntxt-obj-code,
                   output loc-ref-list ).
end procedure.
PROCEDURE m_pl-gds-pump:
  define variable v-current-db-num as integer   no-undo .
  define variable v-obj-db-num     as integer   no-undo .
  do
  on error undo, return error return-value
  :
define variable vss-include-info47 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output v-current-db-num
  )  .
define variable vss-include-info48 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdbnum in g#library
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-obj-db-num
  )  .
    if v-current-db-num = v-obj-db-num
    then do:
      run str/wplgdspm.w
        (input parparentproc
        ,input v-cntxt-obj-type
        ,input v-cntxt-obj-code
        ,input 'b-cur|b-block'
        ) .
    end.
    else do:
      run str/wplgdspm.w (input parparentproc,
                      input v-cntxt-obj-type,
                      input v-cntxt-obj-code,
                      input '').
    end.
  end.
END PROCEDURE.
PROCEDURE m_banks-exe:
  define variable v-rid-list as character no-undo .
  define variable v-status_ like ub.fin-bank.status_ no-undo init 'тек':U.
  do
  on error undo, return error return-value
  :
    run ref/finbanks.w
      (input parparentproc
      ,input v-cntxt-host-code-obj
      ,input "b-add,b-mark":U
      ,input 'фирма':U
      ,input v-cntxt-host-code-obj
      ,input-output v-status_
      ,input-output v-rid-list
      ).
  end.
END PROCEDURE.
PROCEDURE m_schets-exe:
  define variable v-rid-list as character no-undo .
  define variable v-status_ like ub.fin-bank.status_ no-undo init 'тек':U.
  do
  on error undo, return error return-value
  :
    run ref/finschts.w
      (input parparentproc
      ,input v-cntxt-host-code-obj
      ,input "b-add,b-mark":U
      ,input 'фирма':U
      ,input "":U
      ,input 0
      ,input ?
      ,input v-cntxt-host-code-obj
      ,input 0
      ,input-output v-status_
      ,input-output v-rid-list
      ).
  end.
END PROCEDURE.
PROCEDURE m-condkeep-ref-exe :
  define variable v-sts as integer no-undo.
  define variable v-rid-list as character no-undo .
  do
  on error undo, return error return-value
  :
    run ref/cndkeeps.w
      (input  parparentproc
      ,input  v-cntxt-obj-type
      ,input  v-cntxt-obj-code
      ,input  "b-add":U
      ,input  'все':U
      ,input-output v-sts
      ,input-output v-rid-list
      ) no-error .
  end.
end PROCEDURE.
PROCEDURE m-all-exe :
DEFINE VARIABLE loc-ref-list as character no-undo.
define variable v-ok as logical   no-undo .
define variable vss-include-info49 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_documents_all':U
    ,input  'global':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output v-ok
    )  .
end.
if v-ok then do:
  run str/all-docs.w (input parparentproc, ?,?,?, input 'работа':U, input ?, input ?, input ?, input ?, input "b-mark", input ?, input ?, input ?, output loc-ref-list).
end.
END PROCEDURE.
PROCEDURE m-load-exe :
DEFINE VARIABLE loc-ref-list as character no-undo.
run str/all-docs.w (input parparentproc, ?,?,?,  input 'отгрузка':U, input ?, input ?, input ?, input ?, input "":u, input ?, input ?, input ?, output loc-ref-list).
END PROCEDURE.
PROCEDURE m-rep-book-exe :
define variable varcli-type   like ub.clients.obj-type no-undo.
define variable varcli-code   like ub.clients.obj-code no-undo.
define variable vartnved      as   character           no-undo format "x(10)":u.
define variable varcst-units  as   character           no-undo.
define variable varis-ok      as   logical             no-undo initial no.
define variable from-date as date no-undo .
define variable to-date as date no-undo .
run rep/get-cst.w ( input parparentproc
                   ,input-output from-date
                   ,input-output to-date
                   ,input v-cntxt-host-code-obj
                   ,INPUT 'скл':U
                   ,OUTPUT varcli-type
                   ,OUTPUT varcli-code
                   ,OUTPUT vartnved
                   ,OUTPUT varcst-units
                   ,OUTPUT varis-ok) no-error.
IF ERROR-STATUS:ERROR OR
   NOT varis-ok THEN
  RETURN ERROR.
  run rep/v-cst.w
    (input parparentproc,
    input varcli-type,
    input varcli-code,
    input from-date,
    input to-date,
    input vartnved,
    input varcst-units,
    input 'OUT'
    ).
END PROCEDURE.
PROCEDURE m-rep-sm-exe :
define variable varcli-type   like ub.clients.obj-type no-undo.
define variable varcli-code   like ub.clients.obj-code no-undo.
define variable vartnved      as   character           no-undo format "x(10)":u.
define variable varcst-units  as   character           no-undo.
define variable varis-ok      as   logical             no-undo initial no.
define variable v-host-code   like ub.sysconf.host-code no-undo .
define variable from-date as date no-undo .
define variable to-date as date no-undo .
define variable vss-include-info50 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-host-code
  )  .
run rep/get-cst.w (
                    input parparentproc
                  , input-output from-date
                  , input-output to-date
                  , input v-host-code
                  , INPUT ''
                  , OUTPUT varcli-type
                  , OUTPUT varcli-code
                  , OUTPUT vartnved
                  , OUTPUT varcst-units
                  , OUTPUT varis-ok) no-error.
IF ERROR-STATUS:ERROR OR
   NOT varis-ok THEN
  RETURN ERROR.
run rep/v-cst.w (input parparentproc, INPUT varcli-type, INPUT varcli-code, input from-date, input to-date, INPUT vartnved, INPUT varcst-units, INPUT 'IN').
END PROCEDURE.
PROCEDURE m-rep-stsm-exe  :
define variable varcli-type   like ub.clients.obj-type no-undo.
define variable varcli-code   like ub.clients.obj-code no-undo.
define variable vartnved      as   character           no-undo format "x(10)":u.
define variable varcst-units  as   character           no-undo.
define variable varis-ok      as   logical             no-undo initial no.
define variable v-host-code   like ub.sysconf.host-code no-undo .
define variable from-date as date no-undo .
define variable to-date as date no-undo .
define variable vss-include-info51 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-host-code
  )  .
run rep/get-cst.w ( input parparentproc
                  , input-output from-date
                  , input-output to-date
                  , input v-host-code
                  , INPUT 'all'
                  , OUTPUT varcli-type
                  , OUTPUT varcli-code
                  , OUTPUT vartnved
                  , OUTPUT varcst-units
                  , OUTPUT varis-ok) no-error.
IF ERROR-STATUS:ERROR OR
   NOT varis-ok THEN
  RETURN ERROR.
    run rep/v-cst.w (
      input parparentproc,
      INPUT 'all',
      INPUT 0,
      input from-date,
      input to-date,
      INPUT vartnved,
      INPUT varcst-units,
      INPUT 'IN')
      .
END PROCEDURE.
PROCEDURE m-rep-gtd-exe :
  DEFINE VARIABLE varcst-units  AS   CHARACTER           NO-UNDO.
  DEFINE VARIABLE varis-ok      AS   LOGICAL             NO-UNDO INITIAL NO.
  DEFINE VARIABLE varcst-code   LIKE ub.parts.cst-code   NO-UNDO.
  DEFINE VARIABLE vardate       AS   DATE                NO-UNDO.
  run rep/get-code.w ( OUTPUT varcst-code, OUTPUT vardate, OUTPUT varcst-units, OUTPUT varis-ok ) NO-ERROR.
  IF ERROR-STATUS :ERROR OR
     varis-ok <> YES THEN DO:
    RETURN ERROR.
  END.
  run rep/v-gtd.w ( INPUT parparentproc, INPUT varcst-code, INPUT vardate, INPUT varcst-units ) NO-ERROR.
END PROCEDURE.
PROCEDURE m_superchk :
define variable v-doc-rec as recid no-undo .
  run str/rsperchk.p (parparentproc, 'ДОБАВЛЕНИЕ':U, v-cntxt-obj-type,  v-cntxt-obj-code).
END.
PROCEDURE m_search-ser-exe :
define variable v-gds-rec as recid no-undo .
  run str/ser-sale.w (
                  input parparentproc
                 ,input v-cntxt-obj-type
                 ,input v-cntxt-obj-code
                 ,input v-gds-rec
                  )no-error.
END PROCEDURE.
PROCEDURE m_checkwth-exe :
  run str/chckwthr.p
    (input parparentproc
    ,input 'ДОБАВЛЕНИЕ':U
    ,input v-cntxt-obj-type
    ,input v-cntxt-obj-code
    ) no-error.
END PROCEDURE.
PROCEDURE m_twogoods-exe :
  run ref/twogoods.w (
                  input parparentproc
                 ,input 'объект':U
                 ,input v-cntxt-obj-type
                 ,input v-cntxt-obj-code
                 )
               no-error.
END PROCEDURE.
PROCEDURE m_calendar-exe :
  define variable v-disp-date as date      no-undo .
  define variable v-ok        as logical   no-undo .
  assign
    v-disp-date = today
  .
        run gbl/d-inpday.w
          (input ?
          ,input "Календарь"
          ,input ""
          ,input "holyday"
          ,input-output v-disp-date
          ,output v-ok
          ) no-error.
END PROCEDURE.
PROCEDURE m_disable-online-check :
  define buffer buf_thbj-attr for ub.thbj-attr .
  define variable p-enable-item as logical   no-undo .
  run chk-goods_add(output p-enable-item)no-error .
  if not p-enable-item then return .
  define variable v-current-db-num as integer   no-undo .
  define variable v-obj-db-num     as integer   no-undo .
  define variable v-CrashCh        as logical   no-undo .
  define variable v-ok             as logical   no-undo .
  message
   "Внимание! При включении аварии продажа маркированной продукции на кассе происходит без проверки в Честном Знаке! Включить аварию?"
    view-as alert-box question buttons yes-no update v-ok .
  if v-ok <> true then do:
      return.
  end.
define variable vss-include-info52 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output v-current-db-num
  )  .
  v-CrashCh = no.
  if v-current-db-num <> 0 then do:
      run chgCrashSituat (v-current-db-num, 'БД':U, yes, yes, output v-CrashCh).
  end.
  else do:
      for each ub.db no-lock :
        run chgCrashSituat (ub.db.db-num, 'БД':U, yes, no, output v-CrashCh).
      end.
      run chgCrashSituat (0, "", yes, no, output v-CrashCh).
  end.
  if v-CrashCh = yes then
  message "Параметр «Аварийная ситуация в ГИС МТ» - включен"
    view-as alert-box.
END PROCEDURE.
PROCEDURE m_enable-online-check :
  define buffer buf_thbj-attr for ub.thbj-attr .
  define variable p-enable-item as logical   no-undo .
  run chk-goods_add(output p-enable-item)no-error .
  if not p-enable-item then return .
  define variable v-current-db-num as integer   no-undo .
  define variable v-obj-db-num     as integer   no-undo .
  define variable v-CrashCh        as logical   no-undo .
define variable vss-include-info53 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output v-current-db-num
  )  .
  v-CrashCh = no.
  if v-current-db-num <> 0 then do:
    run chgCrashSituat (v-current-db-num, 'БД':U, no, yes, output v-CrashCh).
  end.
  else do:
      for each ub.db no-lock :
        run chgCrashSituat (ub.db.db-num, 'БД':U, no, no, output v-CrashCh).
      end.
      run chgCrashSituat (0, "", no, no, output v-CrashCh).
  end.
  if v-CrashCh = yes then
  message "Параметр «Аварийная ситуация в ГИС МТ» - выключен"
    view-as alert-box.
END PROCEDURE.
PROCEDURE chgCrashSituat:
   define input  parameter iObjCode as integer no-undo.
   define input  parameter iObjType as character no-undo.
   define input  parameter iValue   as logical no-undo.
   define input  parameter iCreateLocal as logical no-undo.
   define output parameter oChgVal  as logical no-undo.
   define buffer buf_thbj-attr for ub.thbj-attr .
   do transaction
       on error undo, return error:
       oChgVal = no.
       find first buf_thbj-attr exclusive-lock where
                  buf_thbj-attr.obj-code = iObjCode and
                  buf_thbj-attr.obj-type = iObjType and
                  buf_thbj-attr.upper-prop-code = 'gisMT':U and
                  buf_thbj-attr.prop-code = 'crashSituat':U
              no-wait no-error.
       if not avail buf_thbj-attr and
          iCreateLocal = yes
       then do:
           run crLocalCrashSit (iObjCode,
                                iObjType,
                                iValue,
                                output oChgVal ) no-error.
       end.
       else if avail buf_thbj-attr
       then do:
          buf_thbj-attr.property-value-logical = iValue .
          oChgVal = yes.
       end.
   end.
END PROCEDURE.
PROCEDURE crLocalCrashSit:
    define input  parameter iObjCode as integer no-undo.
    define input  parameter iObjType as character no-undo.
    define input  parameter iValue   as logical no-undo.
    define output parameter oChgVal  as logical no-undo.
    define variable v-param-type      as character  no-undo .
    define variable v-value-character as character  no-undo .
    define variable v-value-date      as date       no-undo .
    define variable v-value-decimal   as decimal    no-undo .
    define variable v-value-integer   as integer    no-undo .
    define variable v-value-logical   as logical    no-undo .
    define variable v-tth             as handle     no-undo .
    for each thbjattr_thbj-attr:
      delete thbjattr_thbj-attr.
    end.
    run adm/shattri.p (
      input "init":U
      ,input  iObjType
      ,input  iObjCode
      ,input  'gisMT':U
      ,input  "":U
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-value-logical
      ,output v-param-type
      ,INPUT-OUTPUT table thbjattr_thbj-attr
      )  no-error.
    for each thbjattr_thbj-attr
    on error undo, return error return-value
    :
      if thbjattr_thbj-attr.prop-code = 'crashSituat':U
      then do:
          thbjattr_thbj-attr.property-value-logical = iValue.
      end .
      else delete thbjattr_thbj-attr.
    end.
    RUN thbjattr_set-section IN THIS-PROCEDURE (
             input iObjType
            ,input iObjCode
            ,input 'gisMT':U
            ,INPUT table thbjattr_thbj-attr
        ) NO-ERROR.
    if error-status:error then do:
        message "Не удалось сохранить настройки"
        view-as alert-box.
        undo, return error.
    end.
    else oChgVal = yes .
END PROCEDURE.
PROCEDURE m_obj-sht-all-exe :
  define variable varrid-list   as   character           no-undo.
  run str/sht-all.w (parparentproc, v-cntxt-obj-type, v-cntxt-obj-code, 'b-add', 'obj', v-cntxt-obj-type, v-cntxt-obj-code, '':U,  input-OUTPUT varrid-list) no-error.
END PROCEDURE.
procedure obj-ext-in-new-no-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'ФЛАГ':U, INPUT no, INPUT 'накл':U, INPUT 'при':U, INPUT no, INPUT 'ie':U, input no) .
  end.
end procedure.
procedure obj-ext-in-new-ok-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'ФЛАГ':U, INPUT yes, INPUT 'накл':U, INPUT 'при':U, INPUT no, INPUT 'ie':U, input no) .
  end.
end procedure.
procedure obj-ext-in-new-all-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'статус':U, INPUT ?, INPUT 'накл':U, INPUT 'при':U, INPUT no, INPUT 'ie':U, input no) .
  end.
end procedure.
procedure obj-ext-in-fact-no-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'ФЛАГ':U, INPUT no, INPUT 'факт':U, INPUT 'при':U, INPUT no, INPUT 'ie':U, input no) .
  end.
end procedure.
procedure obj-ext-in-fact-ok-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'ФЛАГ':U, INPUT yes, INPUT 'факт':U, INPUT 'при':U, INPUT no, INPUT 'ie':U, input no) .
  end.
end procedure.
procedure obj-ext-in-fact-all-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'статус':U, INPUT ?, INPUT 'факт':U, INPUT 'при':U, INPUT no, INPUT 'ie':U, input no) .
  end.
end procedure.
procedure obj-ext-in-req-no-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'ФЛАГ':U, INPUT no, INPUT 'запрос':U, INPUT 'при':U, INPUT no, INPUT 'ie':U, input no) .
  end.
end procedure.
procedure obj-ext-in-req-ok-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'ФЛАГ':U, INPUT yes, INPUT 'запрос':U, INPUT 'при':U, INPUT no, INPUT 'ie':U, input no) .
  end.
end procedure.
procedure obj-ext-in-req-all-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'статус':U, INPUT ?, INPUT 'запрос':U, INPUT 'при':U, INPUT no, INPUT 'ie':U, input no) .
  end.
end procedure.
procedure obj-ext-in-all-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'ТИП':U, INPUT ?, INPUT '?', INPUT 'при':U, INPUT no, INPUT 'ie':U, input no) .
  end.
end procedure.
procedure obj-cor-part-all :
  do
  on error undo, return error return-value
  :
   run dm-doc-exe (INPUT 'ТИП':U, INPUT ?, INPUT '?', INPUT 'инв':U, INPUT no, INPUT 'mp':U, input no).
  end.
end procedure.
procedure obj-ext-out-new-no-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'ФЛАГ':U, INPUT no, INPUT 'накл':U, INPUT 'рас':U, INPUT no, INPUT 'ee':U, input no) .
  end.
end procedure.
procedure obj-ext-out-new-ok-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'ФЛАГ':U, INPUT yes, INPUT 'накл':U, INPUT 'рас':U, INPUT no, INPUT 'ee':U, input no) .
  end.
end procedure.
procedure obj-ext-out-new-all-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'статус':U, INPUT ?, INPUT 'накл':U, INPUT 'рас':U, INPUT no, INPUT 'ee':U, input no) .
  end.
end procedure.
procedure obj-ext-out-perm-no-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'ФЛАГ':U, INPUT no, INPUT 'разрешен':U, INPUT 'рас':U, INPUT no, INPUT 'ee':U, input no) .
  end.
end procedure.
procedure obj-ext-out-perm-ok-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'ФЛАГ':U, INPUT yes, INPUT 'разрешен':U, INPUT 'рас':U, INPUT no, INPUT 'ee':U, input no) .
  end.
end procedure.
procedure obj-ext-out-perm-all-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'статус':U, INPUT ?, INPUT 'разрешен':U, INPUT 'рас':U, INPUT no, INPUT 'ee':U, input no) .
  end.
end procedure.
procedure obj-ext-out-fact-no-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'ФЛАГ':U, INPUT no, INPUT 'факт':U, INPUT 'рас':U, INPUT no, INPUT 'ee':U, input no) .
  end.
end procedure.
procedure obj-ext-out-fact-ok-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'ФЛАГ':U, INPUT yes, INPUT 'факт':U, INPUT 'рас':U, INPUT no, INPUT 'ee':U, input no) .
  end.
end procedure.
procedure obj-ext-out-fact-all-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'статус':U, INPUT ?, INPUT 'факт':U, INPUT 'рас':U, INPUT no, INPUT 'ee':U, input no) .
  end.
end procedure.
procedure obj-ext-out-req-no-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'ФЛАГ':U, INPUT no, INPUT 'запрос':U  , INPUT 'рас':U, INPUT no, INPUT 'ee':U, input no) .
  end.
end procedure.
procedure obj-ext-out-req-ok-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'ФЛАГ':U, INPUT yes, INPUT 'запрос':U , INPUT 'рас':U, INPUT no, INPUT 'ee':U, input no) .
  end.
end procedure.
procedure obj-ext-out-req-all-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'статус':U, INPUT ?, INPUT 'запрос':U, INPUT 'рас':U, INPUT no, INPUT 'ee':U, input no) .
  end.
end procedure.
procedure obj-ext-out-req-z-exe :
  do
  on error undo, return error return-value
  :
    run dm-fl-exe  (INPUT 'is-flor':U + 'статус':U, INPUT ?, INPUT 'запрос':U) .
  end.
end procedure.
procedure obj-ext-out-req-w-exe :
  do
  on error undo, return error return-value
  :
    run dm-fl-exe  (INPUT 'is-flor':U + 'статус':U, INPUT ?, INPUT 'накл':U) .
  end.
end procedure.
procedure obj-ext-out-req-per-exe :
  do
  on error undo, return error return-value
  :
    run dm-fl-exe  (INPUT 'is-flor':U + 'статус':U, INPUT ?, INPUT 'разрешен':U) .
  end.
end procedure.
procedure obj-ext-out-req-f-exe :
  do
  on error undo, return error return-value
  :
    run dm-fl-exe  (INPUT 'is-flor':U + 'статус':U, INPUT ?, INPUT 'факт':U) .
  end.
end procedure.
procedure obj-ext-out-req-nakl-all-exe :
  do
  on error undo, return error return-value
  :
    run dm-fl-exe  (INPUT 'is-flor':U + 'объект':U, INPUT ?, INPUT ?) .
  end.
end procedure.
procedure obj-ext-out-req-redy-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'ФЛАГ':U, INPUT yes, INPUT 'готов':U, INPUT 'рас':U, INPUT no, INPUT 'ee':U, input no) .
  end.
end procedure.
procedure obj-ext-out-req-reject-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'ФЛАГ':U, INPUT yes, INPUT 'отказ':U, INPUT 'рас':U, INPUT no, INPUT 'ee':U, input no) .
  end.
end procedure.
procedure obj-ext-out-all-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'ТИП':U, INPUT ?, INPUT '?', INPUT 'рас':U, INPUT no, INPUT 'ee':U, input no) .
  end.
end procedure.
procedure obj-ext-out-kass-all-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'ТИП':U, INPUT ?, INPUT '?', INPUT 'рас':U, INPUT no, INPUT 'es':U, input no) .
  end.
end procedure.
procedure obj-ext-sup-new-no-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'ФЛАГ':U, INPUT no, INPUT 'накл':U, INPUT 'рас':U, INPUT no, INPUT 'ep':U, input no) .
  end.
end procedure.
procedure obj-ext-sup-new-ok-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'ФЛАГ':U, INPUT yes, INPUT 'накл':U, INPUT 'рас':U, INPUT no, INPUT 'ep':U, input no) .
  end.
end procedure.
procedure obj-ext-sup-new-all-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'статус':U, INPUT ?, INPUT 'накл':U, INPUT 'рас':U, INPUT no, INPUT 'ep':U, input no) .
  end.
end procedure.
procedure obj-ext-sup-perm-no-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'ФЛАГ':U, INPUT no, INPUT 'разрешен':U, INPUT 'рас':U, INPUT no, INPUT 'ep':U, input no) .
  end.
end procedure.
procedure obj-ext-sup-perm-ok-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'ФЛАГ':U, INPUT yes, INPUT 'разрешен':U, INPUT 'рас':U, INPUT no, INPUT 'ep':U, input no) .
  end.
end procedure.
procedure obj-ext-sup-perm-all-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'статус':U, INPUT ?, INPUT 'разрешен':U, INPUT 'рас':U, INPUT no, INPUT 'ep':U, input no) .
  end.
end procedure.
procedure obj-ext-sup-fact-no-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'ФЛАГ':U, INPUT no, INPUT 'факт':U, INPUT 'рас':U, INPUT no, INPUT 'ep':U, input no) .
  end.
end procedure.
procedure obj-ext-sup-fact-ok-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'ФЛАГ':U, INPUT yes, INPUT 'факт':U, INPUT 'рас':U, INPUT no, INPUT 'ep':U, input no) .
  end.
end procedure.
procedure obj-ext-sup-fact-all-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'статус':U, INPUT ?, INPUT 'факт':U, INPUT 'рас':U, INPUT no, INPUT 'ep':U, input no) .
  end.
end procedure.
procedure obj-ext-sup-all-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'ТИП':U, INPUT ?, INPUT '?', INPUT 'рас':U, INPUT no, INPUT 'ep':U, input no) .
  end.
end procedure.
procedure obj-ext-ret-new-no-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'ФЛАГ':U, INPUT no, INPUT 'накл':U, INPUT 'возврат':U, INPUT no, INPUT 're':U, input no) .
  end.
end procedure.
procedure obj-ext-ret-new-ok-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'ФЛАГ':U, INPUT yes, INPUT 'накл':U, INPUT 'возврат':U, INPUT no, INPUT 're':U, input no) .
  end.
end procedure.
procedure obj-ext-ret-new-all-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'статус':U, INPUT ?, INPUT 'накл':U, INPUT 'возврат':U, INPUT no, INPUT 're':U, input no) .
  end.
end procedure.
procedure obj-ext-ret-perm-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'статус':U, INPUT ?, INPUT 'разрешен':U, INPUT 'возврат':U, INPUT no, INPUT 're':U, input no) .
  end.
end procedure.
procedure obj-ext-ret-fact-no-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'ФЛАГ':U, INPUT no, INPUT 'факт':U, INPUT 'возврат':U, INPUT no, INPUT 're':U, input no) .
  end.
end procedure.
procedure obj-ext-ret-fact-ok-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'ФЛАГ':U, INPUT yes, INPUT 'факт':U, INPUT 'возврат':U, INPUT no, INPUT 're':U, input no) .
  end.
end procedure.
procedure obj-ext-ret-fact-all-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'статус':U, INPUT ?, INPUT 'факт':U, INPUT 'возврат':U, INPUT no, INPUT 're':U, input no) .
  end.
end procedure.
procedure obj-ext-ret-req-no-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'ФЛАГ':U, INPUT no, INPUT 'запрос':U, INPUT 'возврат':U, INPUT no, INPUT 're':U, input no) .
  end.
end procedure.
procedure obj-ext-ret-req-ok-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'ФЛАГ':U, INPUT yes, INPUT 'запрос':U, INPUT 'возврат':U, INPUT no, INPUT 're':U, input no) .
  end.
end procedure.
procedure obj-ext-ret-req-all-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'статус':U, INPUT ?, INPUT 'запрос':U, INPUT 'возврат':U, INPUT no, INPUT 're':U, input no) .
  end.
end procedure.
procedure obj-ext-ret-all-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'ТИП':U, INPUT ?, INPUT '?', INPUT 'возврат':U, INPUT no, INPUT 're':U, input no) .
  end.
end procedure.
procedure obj-ext-retc-all-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'ТИП':U, INPUT ?, INPUT '?', INPUT 'возврат':U, INPUT no, INPUT 'rs':U, input no) .
  end.
end procedure.
procedure obj-aw-new-no-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'ФЛАГ':U, INPUT no, INPUT 'накл':U, INPUT 'спи':U, INPUT no, INPUT 'we':U, input no) .
  end.
end procedure.
procedure obj-aw-new-ok-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'ФЛАГ':U, INPUT yes, INPUT 'накл':U, INPUT 'спи':U, INPUT no, INPUT 'we':U, input no) .
  end.
end procedure.
procedure obj-aw-new-all-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'статус':U, INPUT ?, INPUT 'накл':U, INPUT 'спи':U, INPUT no, INPUT 'we':U, input no) .
  end.
end procedure.
procedure obj-aw-perm-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'статус':U, INPUT ?, INPUT 'разрешен':U, INPUT 'спи':U, INPUT no, INPUT 'we':U, input no) .
  end.
end procedure.
procedure obj-aw-fact-no-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'ФЛАГ':U, INPUT no, INPUT 'факт':U, INPUT 'спи':U, INPUT no, INPUT 'we':U, input no) .
  end.
end procedure.
procedure obj-aw-fact-ok-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'ФЛАГ':U, INPUT yes, INPUT 'факт':U, INPUT 'спи':U, INPUT no, INPUT 'we':U, input no) .
  end.
end procedure.
procedure obj-aw-fact-all-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'статус':U, INPUT ?, INPUT 'факт':U, INPUT 'спи':U, INPUT no, INPUT 'we':U, input no) .
  end.
end procedure.
procedure obj-aw-req-no-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'ФЛАГ':U, INPUT no, INPUT 'запрос':U, INPUT 'спи':U, INPUT no, INPUT 'we':U, input no) .
  end.
end procedure.
procedure obj-aw-req-ok-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'ФЛАГ':U, INPUT yes, INPUT 'запрос':U, INPUT 'спи':U, INPUT no, INPUT 'we':U, input no) .
  end.
end procedure.
procedure obj-aw-req-all-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'статус':U, INPUT ?, INPUT 'запрос':U, INPUT 'спи':U, INPUT no, INPUT 'we':U, input no) .
  end.
end procedure.
procedure obj-aw-all-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'ТИП':U, INPUT ?, INPUT '?', INPUT 'спи':U, INPUT no, INPUT 'we':U, input no) .
  end.
end procedure.
procedure obj-inv-new-no-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'ФЛАГ':U, INPUT no, INPUT 'накл':U, INPUT 'инв':U, INPUT no, INPUT 'vt':U, input no) .
  end.
end procedure.
procedure obj-inv-new-ok-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'ФЛАГ':U, INPUT yes, INPUT 'накл':U, INPUT 'инв':U, INPUT no, INPUT 'vt':U, input no) .
  end.
end procedure.
procedure obj-inv-new-all-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'статус':U, INPUT ?, INPUT 'накл':U, INPUT 'инв':U, INPUT no, INPUT 'vt':U, input no) .
  end.
end procedure.
procedure obj-pst-new-all-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'статус':U, INPUT ?, INPUT 'накл':U, INPUT 'инв':U, INPUT no, INPUT 'vp':U, input no) .
  end.
end procedure.
procedure obj-inv-perm-no-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'ФЛАГ':U, INPUT no, INPUT 'разрешен':U, INPUT 'инв':U, INPUT no, INPUT 'vt':U, input no) .
  end.
end procedure.
procedure obj-inv-perm-ok-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'ФЛАГ':U, INPUT yes, INPUT 'разрешен':U, INPUT 'инв':U, INPUT no, INPUT 'vt':U, input no) .
  end.
end procedure.
procedure obj-inv-perm-all-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'статус':U, INPUT ?, INPUT 'разрешен':U, INPUT 'инв':U, INPUT no, INPUT 'vt':U, input no) .
  end.
end procedure.
procedure obj-inv-fact-no-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'ФЛАГ':U, INPUT no, INPUT 'факт':U, INPUT 'инв':U, INPUT no, INPUT 'vt':U, input no) .
  end.
end procedure.
procedure obj-inv-fact-ok-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'ФЛАГ':U, INPUT yes, INPUT 'факт':U, INPUT 'инв':U, INPUT no, INPUT 'vt':U, input no) .
  end.
end procedure.
procedure obj-inv-fact-all-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'статус':U, INPUT ?, INPUT 'факт':U, INPUT 'инв':U, INPUT no, INPUT 'vt':U, input no) .
  end.
end procedure.
procedure obj-pst-fact-all-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'статус':U, INPUT ?, INPUT 'факт':U, INPUT 'инв':U, INPUT no, INPUT 'vp':U, input no) .
  end.
end procedure.
procedure obj-inv-all-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'ТИП':U, INPUT ?, INPUT '?', INPUT 'инв':U, INPUT no, INPUT 'vt':U, input no) .
  end.
end procedure.
procedure obj-pst-all-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'ТИП':U, INPUT ?, INPUT '?', INPUT 'инв':U, INPUT no, INPUT 'vp':U, input no) .
  end.
end procedure.
procedure obj-ext-in-new-all-hi-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'статус':U, INPUT ?, INPUT 'накл':U, INPUT 'при':U, INPUT no, INPUT 'ie':U, input yes) .
  end.
end procedure.
procedure obj-ext-in-fact-no-hi-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'ФЛАГ':U, INPUT no, INPUT 'факт':U, INPUT 'при':U, INPUT no, INPUT 'ie':U, input yes) .
  end.
end procedure.
procedure obj-ext-in-fact-ok-hi-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'ФЛАГ':U, INPUT yes, INPUT 'факт':U, INPUT 'при':U, INPUT no, INPUT 'ie':U, input yes) .
  end.
end procedure.
procedure obj-ext-in-fact-all-hi-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'статус':U, INPUT ?, INPUT 'факт':U, INPUT 'при':U, INPUT no, INPUT 'ie':U, input yes) .
  end.
end procedure.
procedure obj-ext-in-all-hi-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'ТИП':U, INPUT ?, INPUT '?', INPUT 'при':U, INPUT no, INPUT 'ie':U, input yes) .
  end.
end procedure.
procedure obj-ext-out-new-no-hi-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'ФЛАГ':U, INPUT no, INPUT 'накл':U, INPUT 'рас':U, INPUT no, INPUT 'ee':U, input yes) .
  end.
end procedure.
procedure obj-ext-out-new-ok-hi-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'ФЛАГ':U, INPUT yes, INPUT 'накл':U, INPUT 'рас':U, INPUT no, INPUT 'ee':U, input yes) .
  end.
end procedure.
procedure obj-ext-out-new-all-hi-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'статус':U, INPUT ?, INPUT 'накл':U, INPUT 'рас':U, INPUT no, INPUT 'ee':U, input yes) .
  end.
end procedure.
procedure obj-ext-out-perm-no-hi-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'ФЛАГ':U, INPUT no, INPUT 'разрешен':U, INPUT 'рас':U, INPUT no, INPUT 'ee':U, input yes) .
  end.
end procedure.
procedure obj-ext-out-perm-ok-hi-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'ФЛАГ':U, INPUT yes, INPUT 'разрешен':U, INPUT 'рас':U, INPUT no, INPUT 'ee':U, input yes) .
  end.
end procedure.
procedure obj-ext-out-perm-all-hi-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'статус':U, INPUT ?, INPUT 'разрешен':U, INPUT 'рас':U, INPUT no, INPUT 'ee':U, input yes) .
  end.
end procedure.
procedure obj-ext-out-fact-no-hi-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'ФЛАГ':U, INPUT no, INPUT 'факт':U, INPUT 'рас':U, INPUT no, INPUT 'ee':U, input yes) .
  end.
end procedure.
procedure obj-ext-out-fact-ok-hi-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'ФЛАГ':U, INPUT yes, INPUT 'факт':U, INPUT 'рас':U, INPUT no, INPUT 'ee':U, input yes) .
  end.
end procedure.
procedure obj-ext-out-fact-all-hi-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'статус':U, INPUT ?, INPUT 'факт':U, INPUT 'рас':U, INPUT no, INPUT 'ee':U, input yes) .
  end.
end procedure.
procedure obj-ext-out-all-hi-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'ТИП':U, INPUT ?, INPUT '?', INPUT 'рас':U, INPUT no, INPUT 'ee':U, input yes) .
  end.
end procedure.
procedure obj-ext-sup-new-no-ho-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'ФЛАГ':U, INPUT no, INPUT 'накл':U, INPUT 'рас':U, INPUT no, INPUT 'ep':U, input yes) .
  end.
end procedure.
procedure obj-ext-sup-new-ok-ho-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'ФЛАГ':U, INPUT yes, INPUT 'накл':U, INPUT 'рас':U, INPUT no, INPUT 'ep':U, input yes) .
  end.
end procedure.
procedure obj-ext-sup-new-all-ho-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'статус':U, INPUT ?, INPUT 'накл':U, INPUT 'рас':U, INPUT no, INPUT 'ep':U, input yes) .
  end.
end procedure.
procedure obj-ext-sup-perm-no-ho-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'ФЛАГ':U, INPUT no, INPUT 'разрешен':U, INPUT 'рас':U, INPUT no, INPUT 'ep':U, input yes) .
  end.
end procedure.
procedure obj-ext-sup-perm-ok-ho-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'ФЛАГ':U, INPUT yes, INPUT 'разрешен':U, INPUT 'рас':U, INPUT no, INPUT 'ep':U, input yes) .
  end.
end procedure.
procedure obj-ext-sup-perm-all-ho-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'статус':U, INPUT ?, INPUT 'разрешен':U, INPUT 'рас':U, INPUT no, INPUT 'ep':U, input yes) .
  end.
end procedure.
procedure obj-ext-sup-fact-no-ho-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'ФЛАГ':U, INPUT no, INPUT 'факт':U, INPUT 'рас':U, INPUT no, INPUT 'ep':U, input yes) .
  end.
end procedure.
procedure obj-ext-sup-fact-ok-ho-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'ФЛАГ':U, INPUT yes, INPUT 'факт':U, INPUT 'рас':U, INPUT no, INPUT 'ep':U, input yes) .
  end.
end procedure.
procedure obj-ext-sup-fact-all-ho-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'статус':U, INPUT ?, INPUT 'факт':U, INPUT 'рас':U, INPUT no, INPUT 'ep':U, input yes) .
  end.
end procedure.
procedure obj-ext-sup-all-ho-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'ТИП':U, INPUT ?, INPUT '?', INPUT 'рас':U, INPUT no, INPUT 'ep':U, input yes) .
  end.
end procedure.
procedure obj-ext-ret-new-all-ho-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'статус':U, INPUT ?, INPUT 'накл':U, INPUT 'возврат':U, INPUT no, INPUT 're':U, input yes) .
  end.
end procedure.
procedure obj-ext-ret-fact-all-ho-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'статус':U, INPUT ?, INPUT 'факт':U, INPUT 'возврат':U, INPUT no, INPUT 're':U, input yes) .
  end.
end procedure.
procedure obj-ext-ret-all-ho-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'ТИП':U, INPUT ?, INPUT '?', INPUT 'возврат':U, INPUT no, INPUT 're':U, input yes) .
  end.
end procedure.
procedure obj-cor-prt-new-all-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'статус':U, INPUT ?, INPUT 'накл':U, INPUT 'инв':U, INPUT no, INPUT 'ap':U, input no) .
  end.
end procedure.
procedure obj-cor-prt-fact-ok-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'ФЛАГ':U, INPUT yes, INPUT 'факт':U, INPUT 'инв':U, INPUT no, INPUT 'ap':U, input no) .
  end.
end procedure.
procedure obj-cor-prt-all-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'ТИП':U, INPUT ?, INPUT '?', INPUT 'инв':U, INPUT no, INPUT 'ap':U, input no) .
  end.
end procedure.
procedure obj-chg-pcode-all-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'ТИП':U, INPUT ?, INPUT '?', INPUT 'инв':U, INPUT no, INPUT 'pc':U, input no) .
  end.
end procedure.
procedure obj-ext-all-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'ВНУ':U, INPUT ?, INPUT '?', INPUT '?', INPUT no, INPUT ?, input no) .
  end.
end procedure.
procedure obj-int-in-new-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'статус':U, INPUT ?, INPUT 'накл':U, INPUT 'при':U, INPUT yes, INPUT 'iv':U, input no) .
  end.
end procedure.
procedure obj-int-in-fact-no-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'ФЛАГ':U, INPUT no, INPUT 'факт':U, INPUT 'при':U, INPUT yes, INPUT 'iv':U, input no) .
  end.
end procedure.
procedure obj-int-in-fact-ok-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'ФЛАГ':U, INPUT yes, INPUT 'факт':U, INPUT 'при':U, INPUT yes, INPUT 'iv':U, input no) .
  end.
end procedure.
procedure obj-int-in-fact-all-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'статус':U, INPUT ?, INPUT 'факт':U, INPUT 'при':U, INPUT yes, INPUT 'iv':U, input no) .
  end.
end procedure.
procedure obj-int-in-req-no-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'ФЛАГ':U, INPUT no, INPUT 'запрос':U, INPUT 'при':U, INPUT yes, INPUT 'iv':U, input no) .
  end.
end procedure.
procedure obj-int-in-req-ok-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'ФЛАГ':U, INPUT yes, INPUT 'запрос':U, INPUT 'при':U, INPUT yes, INPUT 'iv':U, input no) .
  end.
end procedure.
procedure obj-int-in-req-all-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'статус':U, INPUT ?, INPUT 'запрос':U, INPUT 'при':U, INPUT yes, INPUT 'iv':U, input no) .
  end.
end procedure.
procedure obj-int-in-all-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'ТИП':U, INPUT ?, INPUT '?', INPUT 'при':U, INPUT yes, INPUT 'iv':U, input no) .
  end.
end procedure.
procedure obj-int-in-invert-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'invert':u, INPUT yes, INPUT 'запрос':U, INPUT 'при':U, INPUT yes, INPUT 'iv':U, input no) .
  end.
end procedure.
procedure obj-int-out-new-no-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'ФЛАГ':U, INPUT no, INPUT 'накл':U, INPUT 'рас':U, INPUT yes, INPUT 'ev':U, input no) .
  end.
end procedure.
procedure obj-int-out-new-ok-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'ФЛАГ':U, INPUT yes, INPUT 'накл':U, INPUT 'рас':U, INPUT yes, INPUT 'ev':U, input no) .
  end.
end procedure.
procedure obj-int-out-new-all-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'статус':U, INPUT ?, INPUT 'накл':U, INPUT 'рас':U, INPUT yes, INPUT 'ev':U, input no) .
  end.
end procedure.
procedure obj-int-out-perm-no-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'ФЛАГ':U, INPUT no, INPUT 'разрешен':U, INPUT 'рас':U, INPUT yes, INPUT 'ev':U, input no) .
  end.
end procedure.
procedure obj-int-out-perm-ok-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'ФЛАГ':U, INPUT yes, INPUT 'разрешен':U, INPUT 'рас':U, INPUT yes, INPUT 'ev':U, input no) .
  end.
end procedure.
procedure obj-int-out-perm-all-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'статус':U, INPUT ?, INPUT 'разрешен':U, INPUT 'рас':U, INPUT yes, INPUT 'ev':U, input no) .
  end.
end procedure.
procedure obj-int-out-fact-no-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'ФЛАГ':U, INPUT no, INPUT 'факт':U, INPUT 'рас':U, INPUT yes, INPUT 'ev':U, input no) .
  end.
end procedure.
procedure obj-int-out-fact-ok-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'ФЛАГ':U, INPUT yes, INPUT 'факт':U, INPUT 'рас':U, INPUT yes, INPUT 'ev':U, input no) .
  end.
end procedure.
procedure obj-int-out-fact-all-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'статус':U, INPUT ?, INPUT 'факт':U, INPUT 'рас':U, INPUT yes, INPUT 'ev':U, input no) .
  end.
end procedure.
procedure obj-int-out-req-no-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'ФЛАГ':U, INPUT no, INPUT 'запрос':U, INPUT 'рас':U, INPUT yes, INPUT 'ev':U, input no) .
  end.
end procedure.
procedure obj-int-out-req-ok-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'ФЛАГ':U, INPUT yes, INPUT 'запрос':U, INPUT 'рас':U, INPUT yes, INPUT 'ev':U, input no) .
  end.
end procedure.
procedure obj-int-out-req-all-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'статус':U, INPUT ?, INPUT 'запрос':U, INPUT 'рас':U, INPUT yes, INPUT 'ev':U, input no) .
  end.
end procedure.
procedure obj-int-out-all-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'ТИП':U, INPUT ?, INPUT '?', INPUT 'рас':U, INPUT yes, INPUT 'ev':U, input no) .
  end.
end procedure.
procedure obj-int-ret-new-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'статус':U, INPUT ?, INPUT 'накл':U,      INPUT 'возврат':U, INPUT yes, INPUT 'rv':U, input no) .
  end.
end procedure.
procedure obj-int-ret-perm-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'статус':U, INPUT ?, INPUT 'разрешен':U, INPUT 'возврат':U, INPUT yes, INPUT 'rv':U, input no) .
  end.
end procedure.
procedure obj-int-ret-fact-no-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'ФЛАГ':U, INPUT no, INPUT 'факт':U, INPUT 'возврат':U, INPUT yes, INPUT 'rv':U, input no) .
  end.
end procedure.
procedure obj-int-ret-fact-ok-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'ФЛАГ':U, INPUT yes, INPUT 'факт':U, INPUT 'возврат':U, INPUT yes, INPUT 'rv':U, input no) .
  end.
end procedure.
procedure obj-int-ret-fact-all-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'статус':U, INPUT ?, INPUT 'факт':U, INPUT 'возврат':U, INPUT yes, INPUT 'rv':U, input no) .
  end.
end procedure.
procedure obj-int-ret-all-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'ТИП':U, INPUT ?, INPUT '?', INPUT 'возврат':U, INPUT yes, INPUT 'rv':U, input no) .
  end.
end procedure.
procedure obj-int-in-prvo-all-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'ТИП':U, INPUT ?, INPUT '?', INPUT 'при':U, INPUT yes, INPUT 'im':U, input no) .
  end.
end procedure.
procedure obj-int-ret-mn-pr-all-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'статус':U, INPUT ?, INPUT 'прво':U, INPUT 'спи':U, INPUT yes, INPUT 'wm':U, input no) .
  end.
end procedure.
procedure obj-int-ret-f-pr-all-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'статус':U, INPUT ?, INPUT 'факт':U, INPUT 'спи':U, INPUT yes, INPUT 'wm':U, input no) .
  end.
end procedure.
procedure obj-int-all-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'ВНУ':U, INPUT ?, INPUT '?', INPUT '?', INPUT yes, INPUT 'ev':U, input no) .
  end.
end procedure.
procedure out-int-obj-new-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'статус':U, INPUT ?, INPUT 'накл':U, INPUT 'рас':U, INPUT yes, INPUT 'eo':U, input no) .
  end.
end procedure.
procedure out-int-obj-fact-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'статус':U, INPUT ?, INPUT 'факт':U, INPUT 'рас':U, INPUT yes, INPUT 'eo':U, input no) .
  end.
end procedure.
procedure out-int-obj-all-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'ТИП':U, INPUT ?, INPUT '?', INPUT 'рас':U, INPUT yes, INPUT 'eo':U, input no) .
  end.
end procedure.
procedure in-int-obj-all-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'ТИП':U, INPUT ?, INPUT '?', INPUT 'при':U, INPUT yes, INPUT 'io':U, input no) .
  end.
end procedure.
procedure obj-all-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'объект':U, INPUT ?, INPUT '?', INPUT '?', INPUT ?, INPUT 'rv':U, input no) .
  end.
end procedure.
procedure m-host-exe :
  do
  on error undo, return error return-value
  :
    run dm-doc-exe (INPUT 'фирма':U, INPUT ?, INPUT '?', INPUT '?', INPUT ?, INPUT 'rv':U, input no) .
  end.
end procedure.
procedure m-rsrvPlan-exe :
  do
  on error undo, return error return-value
  :
    run rep/g-rsrvPlan.p (input parparentproc, input no) no-error .
  end.
end procedure.
procedure m-fbrpr-exe :
  do
  on error undo, return error return-value
  :
    run rep/g-fbrpr.p ( input parparentproc, input v-cntxt-obj-type, input v-cntxt-obj-code ) .
  end.
end procedure.
procedure m-rep-shift4-exe :
  do
  on error undo, return error return-value
  :
    run rep/g-new-shift.p (input parparentproc, input '') .
  end.
end procedure.
procedure m-rep-shiftOld-exe :
  do
  on error undo, return error return-value
  :
    run rep/g-new-shift.p (input parparentproc, input '') .
  end.
end procedure.
procedure m-rep-shift4-ukr-exe :
  do on error undo, return error return-value :
    run rep/g-zmzvit.p ( input parparentproc ).
  end.
end procedure.
procedure m-sz-fin-exe :
  do
  on error undo, return error return-value
  :
    run rep/g-czbdp.p
      (input  parparentproc
      ,input  v-cntxt-host-code-obj
      ) .
  end.
end procedure.
procedure m_300-exe :
  do
  on error undo, return error return-value
  :
    run bge/bge.p (input parparentproc, 'flat','REF') .
  end.
end procedure.
procedure m_301-exe :
  do
  on error undo, return error return-value
  :
    run bge/bge.p (input parparentproc, 'flat','DOC') .
  end.
end procedure.
procedure m_310-exe :
  do
  on error undo, return error return-value
  :
    run bge/bge.p (input parparentproc, 'flat','FINDOC') .
  end.
end procedure.
procedure m_310_1-exe :
  do
  on error undo, return error return-value
  :
    run bge/bge.p (input parparentproc, 'flat','FIN-OB') .
  end.
end procedure.
procedure m_310_2-exe :
  do
  on error undo, return error return-value
  :
    run bge/bge.p (input parparentproc, 'flat','CONTRACT') .
  end.
end procedure.
procedure m_311-exe :
  do
  on error undo, return error return-value
  :
    run bge/bge.p (input parparentproc, 'flat','STD') .
  end.
end procedure.
procedure m_312-exe :
  do
  on error undo, return error return-value
  :
    run bge/bge.p (input parparentproc, 'flat','STT') .
  end.
end procedure.
procedure m_313-exe :
  do
  on error undo, return error return-value
  :
    run bge/bgerddoc.w ( input parparentproc, 'flat', 'DOC' ) .
  end.
end procedure.
procedure m_314-exe :
  do
  on error undo, return error return-value
  :
    run bge/bge.p ( input parparentproc, 'flat', 'PRC' ) .
  end.
end procedure.
procedure m_315-exe :
  do
  on error undo, return error return-value
  :
    run bge/bge.p (input parparentproc, 'tree','SHIFT') .
  end.
end procedure.
procedure m_316-exe :
  do
  on error undo, return error return-value
  :
    run bge/bge.p (input parparentproc, 'flat','SCHET-FACTUR') .
  end.
end procedure.
procedure m__bge_ref-exe :
  do
  on error undo, return error return-value
  :
    run bge/bge.p (input parparentproc, 'tree','REF') .
  end.
end procedure.
procedure m_282-exe :
  do
  on error undo, return error return-value
  :
    run bge/bge.p (input parparentproc, 'tree','DOC') .
  end.
end procedure.
procedure m_28c-exe :
  do
  on error undo, return error return-value
  :
    run bge/bge.p (input parparentproc, 'tree','STK') .
  end.
end procedure.
procedure m_28d-exe :
  do
  on error undo, return error return-value
  :
    run bge/bge.p (input parparentproc, 'tree','DAY') .
  end.
end procedure.
procedure m_28e-exe :
  do
  on error undo, return error return-value
  :
    run bge/bge.p (input parparentproc, 'tree','WAY') .
  end.
end procedure.
procedure m_28f-exe :
  do
  on error undo, return error return-value
  :
    run bge/bge.p (input parparentproc, 'tree','CARD') .
  end.
end procedure.
procedure m_28a-exe :
  do
  on error undo, return error return-value
  :
    run bge/bge.p (input parparentproc, 'tree','ALL-DOC-REF') .
  end.
end procedure.
procedure m_28z-exe :
  do
  on error undo, return error return-value
  :
    run bge/bge.p (input parparentproc, 'tree','ALL-DAY-WAY') .
  end.
end procedure.
procedure m_28g-exe :
  do
  on error undo, return error return-value
  :
    run bge/bgerddoc.w ( input parparentproc, 'tree', 'DOC' ) .
  end.
end procedure.
procedure m_41-exe :
  do
  on error undo, return error return-value
  :
    run bge/oxmlext.w
      (input  parparentproc
      ,input  "b-add"
      ,input  'все':U
      ,input  v-cntxt-db-num
      ,input  v-cntxt-db-num
      ,input  ''
      ,input  ?
      ) .
  end.
end procedure.
procedure m_45-exe :
  do
  on error undo, return error return-value
  :
    run bge/oxmlext.w
      (input  parparentproc
      ,input  "b-add"
      ,input  "special"
      ,input  v-cntxt-db-num
      ,input  v-cntxt-db-num
      ,input  ''
      ,input  integer('1':U)
      ) .
  end.
end procedure.
procedure m_43-exe :
  do
  on error undo, return error return-value
  :
    message
      "Процедура импорта находится в разработке"
      view-as alert-box error .
  end.
end procedure.
procedure m__rfr-exe :
  define variable v-cur-date-error-code as integer      no-undo.
  do
  on error undo, return error return-value
  :
    run mainmenu-disp-mutable in parparentproc (
        output v-cur-date-error-code
    ) no-error.
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры mainmenu-disp-mutable" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure m__st-exe :
  do
  on error undo, return error return-value
  :
    run trigger-select-context in parparentproc no-error.
    if error-status :error
    then do:
      if error-status :get-message(1) <> '':U
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при смене объекта процедура trigger-select-context" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end.
  end.
end procedure.
procedure obj-sht-ch-date-exe :
    define variable v-error-code    as integer      no-undo.
  do
  on error undo, return error return-value
  :
    run adm/cur-date.w
      (input  parparentproc
      ,input  v-cntxt-obj-type
      ,input  v-cntxt-obj-code
      ,input  'change-date':u
      ,output v-error-code
      ) no-error .
    if error-status :error
    then do:
      if error-status :get-message(1) <> '':U
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при вызове процедуры" 'adm/cur-date.w':U skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end.
  end.
end procedure.
procedure m-gds-list-exe :
  define variable v-host-code as integer no-undo .
  do
  on error undo, return error return-value
  :
define variable vss-include-info54 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-host-code
  )  .
    run str/gdslistr.p (parparentproc, v-host-code, v-cntxt-obj-type, v-cntxt-obj-code) .
  end.
end procedure.
procedure m-scn-list-exe :
  define variable v-host-code as integer no-undo .
  do
  on error undo, return error return-value
  :
define variable vss-include-info55 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-host-code
  )  .
    run str/scnlistr.p (parparentproc, v-host-code, v-cntxt-obj-type, v-cntxt-obj-code) .
  end.
end procedure.
procedure m-cli-list-exe :
  define variable v-host-code as integer no-undo .
  do
  on error undo, return error return-value
  :
define variable vss-include-info56 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-host-code
  )  .
    run str/clilistr.p (parparentproc, v-host-code, v-cntxt-obj-type, v-cntxt-obj-code) .
  end.
end procedure.
procedure m-doc-list-exe :
  define variable v-host-code as integer no-undo .
  do
  on error undo, return error return-value
  :
define variable vss-include-info57 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-host-code
  )  .
    run str/doclistr.p (parparentproc, v-host-code, v-cntxt-obj-type, v-cntxt-obj-code) .
  end.
end procedure.
procedure m-dc-list-exe :
  define variable v-host-code as integer no-undo .
  do
  on error undo, return error return-value
  :
define variable vss-include-info58 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-host-code
  )  .
    run str/dclistr.p (parparentproc, v-host-code, v-cntxt-obj-type, v-cntxt-obj-code) .
  end.
end procedure.
procedure m-chk-list-all-exe :
run proc-chk-docs in this-procedure (input 'b-del', input 'объект':U).
end procedure.
procedure m-chk-list-per-exe :
DEFINE VARIABLE p-list as character no-undo .
run str/tab-peresm.w (
                    input parparentproc
                    ,input 'b-restore'
                    ,input if v-cntxt-db-num <> 0 then 'объект':U else 'все':U
                    ,input ?
                    ,input v-cntxt-obj-type
                    ,input v-cntxt-obj-code
                    ,input '':U
                    ,input '':U
                    ,input ?
                    ,input ?
                    ,output p-list) no-error.
end procedure.
procedure m-chk-list-exe :
  define variable v-host-code as integer no-undo .
  do
  on error undo, return error return-value
  :
define variable vss-include-info59 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-host-code
  )  .
    run str/chklistr.p (parparentproc, v-cntxt-obj-type, v-cntxt-obj-code, v-host-code) .
  end.
end procedure.
procedure m-bb-list-exe :
  do
  on error undo, return error return-value
  :
    run str/bblistr.p ( parparentproc, v-cntxt-obj-type, v-cntxt-obj-code) .
  end.
end procedure.
procedure m-scnblist-exe :
  do
  on error undo, return error return-value
  :
    run str/scnblstr.p ( parparentproc, v-cntxt-obj-type, v-cntxt-obj-code) .
  end.
end procedure.
procedure m_bc-ab-exe :
  define variable varb-c        like ub.bar-code.b-code  no-undo.
  do
  on error undo, return error return-value
  :
    run str/bc-ab.p (input parparentproc, input v-cntxt-obj-type, input v-cntxt-obj-code, ?, output varb-c) .
  end.
end procedure.
procedure inv-lui-local:
  do
  on error undo, return error return-value
  :
    run str/inv-lui.w
      (input  parparentproc
      ,input  v-cntxt-obj-type
      ,input  v-cntxt-obj-code
      ).
  end.
end procedure.
procedure m_clobbnds_rep-xml-exe :
  do
  on error undo, return error
  :
    define variable v-rid-list as character no-undo .
    run ref/clobbnds.w ( input parparentproc
                        ,input ?
                        ,input ''
                        ,input 'все':U
                        ,input ""
                        ,input 'report-xml':U
                        ,input ''
                        ,input v-cntxt-db-num
                        ,input-output v-rid-list) no-error.
  end.
end procedure.
procedure m_clobbnds_list-exe :
define variable v-rid-list as character no-undo .
run ref/clobbnds.w ( input parparentproc
                    ,input this-procedure:handle
                    ,input 'b-sel,b-add,managed'
                    ,input 'все':U
                    ,input ""
                    ,input 'list':U
                    ,input ''
                    ,input -1
                    ,input-output v-rid-list) no-error.
end.
procedure m__inp-jewel-set-val :
  define input  parameter p-action as character no-undo .
  define input-output parameter p-value as logical   no-undo .
  do
  on error undo, return error return-value
  :
    case p-action :
      when 'set':u
      then do:
        run set-inp-jewel in parparentproc
          (input  p-value
          ) .
      end.
      when 'get':u
      then do:
        run get-inp-jewel in parparentproc
          (output p-value
          ) .
      end.
    end.
  end.
end procedure.
procedure m__gds-engl-set-val :
  define input  parameter p-action as character no-undo .
  define input-output parameter p-value as logical   no-undo .
  do
  on error undo, return error return-value
  :
    case p-action :
      when 'set':u
      then do:
        run set-gds-engl in parparentproc
          (input  p-value
          ) .
      end.
      when 'get':u
      then do:
        run get-gds-engl in parparentproc
          (output p-value
          ) .
      end.
    end.
  end.
end procedure.
procedure m__quest-print-set-val :
  define input  parameter p-action as character no-undo .
  define input-output parameter p-value as logical   no-undo .
  define variable v-checked as logical   no-undo .
  do
  on error undo, return error return-value
  :
    case p-action :
      when 'set':u
      then do:
        run set-quest-print in parparentproc
          (input  p-value
          ) .
      end.
      when 'get':u
      then do:
        run get-quest-print in parparentproc
          (output p-value
          ) .
      end.
    end.
  end.
end procedure.
procedure m_cshprtob-exe :
define variable v-host-code like ub.sysconf.host-code no-undo .
  do
  on error undo, return error
  :
define variable vss-include-info60 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-host-code
  )  .
    run str/cshprtob.p (parparentproc, v-host-code, v-cntxt-obj-type, v-cntxt-obj-code).
  end.
end procedure.
procedure m_insaleob-exe :
define variable v-host-code like ub.sysconf.host-code no-undo .
  do
  on error undo, return error
  :
define variable vss-include-info61 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-host-code
  )  .
    run str/insaleob.p (parparentproc, v-host-code, v-cntxt-obj-type, v-cntxt-obj-code).
  end.
end procedure.
procedure m_bc-price-set-val :
  define input  parameter p-action as character no-undo .
  define input-output parameter p-value as logical   no-undo .
  define variable v-checked as logical   no-undo .
  do
  on error undo, return error return-value
  :
    case p-action :
      when 'set':u
      then do:
        run set-bc-price in parparentproc
          (input  p-value
          ) .
      end.
      when 'get':u
      then do:
        run get-bc-price in parparentproc
          (output p-value
          ) .
      end.
    end.
  end.
end procedure.
procedure m_disgdsrule-exe :
  define variable v-host-code as integer no-undo .
  do
  on error undo, return error return-value
  :
    run ref/dgrbylst.w ( input parparentproc
                        ,input 'dis-gds-rule':U
                        ,input v-cntxt-obj-type
                        ,input v-cntxt-obj-code) .
  end.
end procedure.
procedure m_disdcrule-exe :
  do
  on error undo, return error return-value
  :
    run ref/ddcrbyls.w ( input parparentproc
                        ,input 'dis-dc-rule':U
                        ,input v-cntxt-host-code-obj
                        ,input v-cntxt-obj-type
                        ,input v-cntxt-obj-code) .
  end.
end procedure.
procedure m_discprule-exe :
  do
  on error undo, return error return-value
  :
    run ref/cshbylst.w ( input parparentproc
                        ,input 'dis-cp-rule':U
                        ,input v-cntxt-host-code-obj
                        ,input v-cntxt-obj-type
                        ,input v-cntxt-obj-code) .
  end.
end procedure.
procedure m_gdsoattr-exe :
  define variable v-host-code as integer no-undo .
  do
  on error undo, return error return-value
  :
define variable vss-include-info62 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-host-code
  )  .
    run ref/atrbylst.w (parparentproc, 'gds-obj-attr':U, v-host-code, v-cntxt-obj-type, v-cntxt-obj-code) .
  end.
end procedure.
procedure m_gdshattr-exe :
  define variable v-host-code as integer no-undo .
  do
  on error undo, return error return-value
  :
define variable vss-include-info63 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-host-code
  )  .
    run ref/atrbylst.w (parparentproc, 'gds-host-attr':U, v-host-code, v-cntxt-obj-type, v-cntxt-obj-code) .
  end.
end procedure.
procedure m_clntattr-exe :
  define variable v-host-code as integer no-undo .
  do
  on error undo, return error return-value
  :
define variable vss-include-info64 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-host-code
  )  .
    run ref/atrbylst.w (parparentproc, 'clients-attr':U, v-host-code, v-cntxt-obj-type, v-cntxt-obj-code) .
  end.
end procedure.
procedure m_goods-attr-exe :
  define variable v-host-code as integer no-undo .
  do
  on error undo, return error return-value
  :
define variable vss-include-info65 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-host-code
  )  .
    run ref/atrbylst.w (parparentproc, 'goods-attr':U, v-host-code, v-cntxt-obj-type, v-cntxt-obj-code) .
  end.
end procedure.
procedure m-fbr-gds-grp-attr-exe :
  do
  on error undo, return error return-value
  :
    run ref/fbrgdsat.w ( input parparentproc, input v-cntxt-obj-type, input v-cntxt-obj-code ) .
  end.
end procedure.
procedure m_clients-parus-exe :
define variable v-rid-list as character no-undo .
  do
  on error undo, return error
  :
    run ref/par-clis.w ( input parparentproc
                        ,input (if v-cntxt-db-num > 0 then '':U else "b-add")
                        ,input '':U
                        ,input-output v-rid-list) no-error.
  end.
end procedure.
procedure m_clients-parus-2-exe :
define variable v-rid-list as character no-undo .
  do
  on error undo, return error
  :
    run ref/par2clis.w ( input parparentproc
                        ,input (if v-cntxt-db-num > 0 then '':U else "b-add")
                        ,input '':U
                        ,input-output v-rid-list) no-error.
  end.
end procedure.
procedure m_clients-esys-exe :
define variable v-rid-list as character no-undo .
  do
  on error undo, return error
  :
    run ref/esysclis.w ( input parparentproc
                        ,input (if v-cntxt-db-num > 0 then '':U else "b-add")
                        ,input 'все':U
                        ,input 0
                        ,input-output v-rid-list) no-error.
  end.
end procedure.
procedure m_goods-esys-exe :
define variable v-rid-list as character no-undo .
  do
  on error undo, return error
  :
    run ref/codelay.p
      (input  parparentproc
      ,input  'ПРОСМОТР':U
      ,input  ""
      ,input  "FuelCodeInfo"
      ,input  ?
      ) .
  end.
end procedure.
procedure m_gds-grp-esys-exe :
define variable v-rid-list as character no-undo .
  do
  on error undo, return error
  :
    run ref/esys-grp.w ( input parparentproc
                        ,input (if v-cntxt-db-num > 0 then '':U else "b-add")
                        ,input 'все':U
                        ,input 0
                        ,input-output v-rid-list) no-error.
  end.
end procedure.
procedure m_gds-ef-exe :
define variable v-rid-list as character no-undo .
  do
  on error undo, return error
  :
    run ref/gds-ef.w ( input parparentproc
                      ,input (if v-cntxt-db-num > 0 then '':U else "b-add")
                      ,input '':U
                      ,output v-rid-list) no-error.
  end.
end procedure.
procedure m-obj-unrv-exe :
  do
  on error undo, return error return-value
  :
    run str/chck-rv.p (input parparentproc, input 'срок':U) no-error .
  end.
end procedure.
procedure m-obj-req-exe :
  do
  on error undo, return error return-value
  :
    run str/chck-rv.p (input parparentproc, input 'запрос':U) no-error .
  end.
end procedure.
procedure m-obj-uninv-exe :
  do
  on error undo, return error return-value
  :
    run str/chck-rv.p (input parparentproc, input 'инв-снять') no-error .
  end.
end procedure.
procedure m-obj-rvinv-exe :
  do
  on error undo, return error return-value
  :
    run str/chck-rv.p (input parparentproc, input 'инв-рез') no-error  .
  end.
end procedure.
procedure m-bpa-ref :
define variable v-rid-list as character no-undo .
define variable v-mode     as character no-undo .
define variable v-value    as character no-undo .
define variable v-type     as character no-undo .
  do
  on error undo, return error
  :
    run gbl/conf-rd.p ("is-erpRN", "", "", 0, "", "", "", no, output v-value, output v-type) no-error.
    if v-value = "no" then do:
    if v-cntxt-db-num > 0 then v-mode = 'ПРОСМОТР':U. else v-mode = 'ИЗМЕНЕНИЕ':U .
    end.
    else v-mode = 'ПРОСМОТР':U .
    run ref/bpa.p ( input parparentproc, input v-mode, output v-rid-list) no-error.
  end.
end procedure.
procedure m-cashbook-ref :
define variable v-rid-list as character no-undo .
define variable v-mode     as character no-undo .
define variable v-value    as character no-undo .
define variable v-type     as character no-undo .
  do
  on error undo, return error
  :
    run gbl/conf-rd.p ("is-erpRN", "", "", 0, "", "", "", no, output v-value, output v-type) no-error.
    if v-value = "no"
    then v-mode = 'ИЗМЕНЕНИЕ':U .
    else v-mode = 'ПРОСМОТР':U .
    run ref/cashbook.p ( input parparentproc, input v-mode ) no-error.
  end.
end procedure.
procedure m_autopush-exe :
  define variable varrid-list   as   character           no-undo.
  define variable v-host-code as integer no-undo .
  do
  on error undo, return error return-value
  :
define variable vss-include-info66 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-host-code
  )  .
    run adm/autopush.w
      (input  parparentproc
      ,input  v-cntxt-obj-type
      ,input  v-cntxt-obj-code
      ,input  v-host-code
      ) .
  end.
end procedure.
procedure m_nwsdistrcmd-exe :
  define variable varrid-list   as   character           no-undo.
  do
  on error undo, return error return-value
  :
    run str/dbracmds.w (parparentproc, '':U, 'все':U, ?, '':U, '':U, input-output varrid-list) .
  end.
end procedure.
procedure m-impexp-exe :
  define variable glog as logical no-undo.
  do
  on error undo, return error return-value
  :
define variable vss-include-info67 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_impexp_proc':U
    ,input  'global':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output glog
    )  .
end.
    if glog then do :
      run gbl/menubrws.w (parparentproc, 'service_impexp':U,  'Импорт/Экспорт') .
    end.
  end.
end procedure.
procedure m-impexp-fin-exe :
  define variable glog as logical no-undo.
  do
  on error undo, return error return-value
  :
define variable vss-include-info68 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_impexp_proc':U
    ,input  'global':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output glog
    )  .
end.
    if glog then do :
      run gbl/menubrws.w (parparentproc, 'service_fin_impexp':U,  'Импорт/Экспорт') .
    end.
  end.
end procedure.
procedure m-customs-exe :
  do
  on error undo, return error return-value
  :
    run gbl/menubrws.w (parparentproc, 'service_customs':U, 'Заказные программы') .
  end.
end procedure.
procedure m-utility-exe :
  do
  on error undo, return error return-value
  :
    run gbl/menubrws.w (parparentproc, 'service_utility':U, 'Служебные программы') .
  end.
end procedure.
procedure m-check-exe :
  do
  on error undo, return error return-value
  :
    run gbl/menubrws.w (parparentproc, 'service_check':U,   'Программы проверки') .
  end.
end procedure.
procedure m__fin_cli-grp-exe :
  define variable varrid-list   as   character           no-undo.
  do
  on error undo, return error return-value
  :
    run ref/cli-grps.w (input parparentproc, '', input-output varrid-list) .
  end.
end procedure.
procedure m__fin_code-corr-exe :
  do
  on error undo, return error return-value
  :
    run ref/f-code-c.p
      (input  parparentproc
      ,input  1
      ,input  v-cntxt-host-code-obj
      ) .
  end.
end procedure.
procedure m__fin_code-gol-exe :
  do
  on error undo, return error return-value
  :
    run ref/f-code-c.p
      (input  parparentproc
      ,input  2
      ,input  v-cntxt-host-code-obj
      ) .
  end.
end procedure.
procedure m__fin_code-analit-exe :
  do
  on error undo, return error return-value
  :
    run ref/f-code-c.p
      (input  parparentproc
      ,input  3
      ,input  v-cntxt-host-code-obj
      ) .
  end.
end procedure.
procedure m__fi-taxes-exe :
  define variable varrid-list   as   character           no-undo.
  do
  on error undo, return error return-value
  :
    run ref/tax-tree.w
      (input  parparentproc
      ,input  ''
      ,input  'ALL':U
      ,input  v-cntxt-host-code-obj
      ,input  '':U
      ,input  0
      ,input  ?
      ,input-output varrid-list
      ) .
  end.
end procedure.
procedure m__fin_countries-exe :
  define variable v-rid-list  as   character   no-undo.
  do
  on error undo, return error return-value
  :
    run ref/countris.w (input parparentproc
                 , input ''
                 , input-output  v-rid-list ) .
  end.
end procedure.
procedure m__fin_currency-exe :
  define variable varrid        as   recid               no-undo.
  do
  on error undo, return error return-value
  :
    run ref/currency.w (parparentproc, 'b-add-bank':U, input-output  varrid ) .
  end.
end procedure.
procedure m__fin-pay-type-exe :
  define variable varrid           as character no-undo .
  define variable v-current-db-num as integer   no-undo .
  do
  on error undo, return error return-value
  :
define variable vss-include-info69 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output v-current-db-num
  )  .
    run ref/paytype.w
      (input  parparentproc
      ,input  (if v-current-db-num = 0
               then 'b-add,b-upd,b-del,b-doc,b-print'
               else 'b-doc'
              )
      ,output varrid
      ) .
  end.
end procedure.
procedure m__fin_plan-attr-exe :
  do
  on error undo, return error return-value
  :
    run ref/fiatrobj.w
      (input  parparentproc
      ,input  v-cntxt-host-code-obj
      ) .
  end.
end procedure.
procedure m__fin_ove_rs_n-exe :
  do
  on error undo, return error return-value
  :
    run str/fi-liab1.p (input parparentproc ,21,v-cntxt-host-code-obj) .
  end.
end procedure.
procedure m__fin_ove_rs_g-exe :
  do
  on error undo, return error return-value
  :
    run str/fi-liab1.p (input parparentproc ,210,v-cntxt-host-code-obj) .
  end.
end procedure.
procedure m__fin_ove_rs_f-exe :
  do
  on error undo, return error return-value
  :
    run str/fi-liab1.p (input parparentproc ,22,v-cntxt-host-code-obj) .
  end.
end procedure.
procedure m__fin_ove_rs_a-exe :
  do
  on error undo, return error return-value
  :
    run str/fi-liab1.p (input parparentproc ,2,v-cntxt-host-code-obj) .
  end.
end procedure.
procedure m__fin_ove_rs_bef-exe :
  do
  on error undo, return error return-value
  :
    run str/fi-liab1.p (input parparentproc ,3,v-cntxt-host-code-obj) .
  end.
end procedure.
procedure m__fin_ove_in_n-exe :
  do
  on error undo, return error return-value
  :
     run str/fi-liab1.p (input parparentproc , input 11 , v-cntxt-host-code-obj) .
  end.
end procedure.
procedure m__fin_ove_in_g-exe :
  do
  on error undo, return error return-value
  :
     run str/fi-liab1.p (input parparentproc , input 13 , v-cntxt-host-code-obj) .
  end.
end procedure.
procedure m__fin_ove_in_f-exe :
  do
  on error undo, return error return-value
  :
     run str/fi-liab1.p (input parparentproc , input 12 , v-cntxt-host-code-obj) .
  end.
end procedure.
procedure m__fin_ove_in_a-exe :
  do
  on error undo, return error return-value
  :
     run str/fi-liab1.p (input parparentproc , input 1 , v-cntxt-host-code-obj) .
  end.
end procedure.
procedure m__fin_ob-inf-exe :
  do
  on error undo, return error return-value
  :
    run str/fo-inf.w (input parparentproc ,v-cntxt-host-code-obj) .
  end.
end procedure.
procedure m__fd_pr_cash-new-exe :
  do
  on error undo, return error return-value
  :
    run m__fd_exe('пко':U, 'новый':U) .
  end.
end procedure.
procedure m__fd_pr_cash-perm-exe :
  do
  on error undo, return error return-value
  :
    run m__fd_exe('пко':U, 'разрешен':U) .
  end.
end procedure.
procedure m__fd_pr_cash-fact-exe :
  do
  on error undo, return error return-value
  :
    run m__fd_exe('пко':U, 'факт':U) .
  end.
end procedure.
procedure m__fd_pr_cash-all-exe :
  do
  on error undo, return error return-value
  :
    run m__fd_exe('пко':U, '':U) .
  end.
end procedure.
procedure m__fd_pr_casho-new-exe :
  do
  on error undo, return error return-value
  :
    run m__fd_exe( input ('пко':U + chr(4) + 'объект':U), 'новый':U) .
  end.
end procedure.
procedure m__fd_pr_casho-perm-exe :
  do
  on error undo, return error return-value
  :
    run m__fd_exe( input ('пко':U + chr(4) + 'объект':U), 'разрешен':U) .
  end.
end procedure.
procedure m__fd_pr_casho-fact-exe :
  do
  on error undo, return error return-value
  :
    run m__fd_exe( input ('пко':U + chr(4) + 'объект':U) , 'факт':U) .
  end.
end procedure.
procedure m__fd_pr_casho-all-exe :
  do
  on error undo, return error return-value
  :
    run m__fd_exe( input ('пко':U + chr(4) + 'объект':U), '':U) .
  end.
end procedure.
procedure m__fd_pr_cashless-new-exe :
  do
  on error undo, return error return-value
  :
    run m__fd_exe('ппп':U, 'новый':U) .
  end.
end procedure.
procedure m__fd_pr_cashless-perm-exe :
  do
  on error undo, return error return-value
  :
    run m__fd_exe('ппп':U, 'разрешен':U) .
  end.
end procedure.
procedure m__fd_pr_cashless-bank-exe :
  do
  on error undo, return error return-value
  :
    run m__fd_exe('ппп':U, 'банк':U) .
  end.
end procedure.
procedure m__fd_pr_cashless-fact-exe :
  do
  on error undo, return error return-value
  :
    run m__fd_exe('ппп':U, 'факт':U) .
  end.
end procedure.
procedure m__fd_pr_cashless-all-exe :
  do
  on error undo, return error return-value
  :
    run m__fd_exe('ппп':U, '':U) .
  end.
end procedure.
procedure m__fd_pr_payoff-new-exe :
  do
  on error undo, return error return-value
  :
    run m__fd_exe('апп':U, 'новый':U) .
  end.
end procedure.
procedure m__fd_pr_payoff-perm-exe :
  do
  on error undo, return error return-value
  :
    run m__fd_exe('апп':U, 'разрешен':U) .
  end.
end procedure.
procedure m__fd_pr_payoff-fact-exe :
  do
  on error undo, return error return-value
  :
    run m__fd_exe('апп':U, 'факт':U) .
  end.
end procedure.
procedure m__fd_pr_payoff-all-exe :
  do
  on error undo, return error return-value
  :
    run m__fd_exe('апп':U, '':U) .
  end.
end procedure.
procedure m__fd_ra_cash-new-exe :
  do
  on error undo, return error return-value
  :
    run m__fd_exe('рко':U, 'новый':U) .
  end.
end procedure.
procedure m__fd_ra_cash-perm-exe :
  do
  on error undo, return error return-value
  :
    run m__fd_exe('рко':U, 'разрешен':U) .
  end.
end procedure.
procedure m__fd_ra_cash-fact-exe :
  do
  on error undo, return error return-value
  :
    run m__fd_exe('рко':U, 'факт':U) .
  end.
end procedure.
procedure m__fd_ra_cash-all-exe :
  do
  on error undo, return error return-value
  :
    run m__fd_exe('рко':U, '':U) .
  end.
end procedure.
procedure m__fd_ra_casho-new-exe :
  do
  on error undo, return error return-value
  :
    run m__fd_exe( input ('рко':U + chr(4) + 'объект':U), 'новый':U) .
  end.
end procedure.
procedure m__fd_ra_casho-perm-exe :
  do
  on error undo, return error return-value
  :
    run m__fd_exe( input ('рко':U + chr(4) + 'объект':U), 'разрешен':U) .
  end.
end procedure.
procedure m__fd_ra_casho-fact-exe :
  do
  on error undo, return error return-value
  :
    run m__fd_exe( input ('рко':U + chr(4) + 'объект':U), 'факт':U) .
  end.
end procedure.
procedure m__fd_ra_casho-all-exe :
  do
  on error undo, return error return-value
  :
    run m__fd_exe( input ('рко':U + chr(4) + 'объект':U), '':U) .
  end.
end procedure.
procedure m__fd_casho-all-exe :
  do
  on error undo, return error return-value
  :
    run m__fd_exe( input ("cash" + chr(4) + 'объект':U), '':U) .
  end.
end procedure.
procedure m__fd_casha-all-exe :
  do
  on error undo, return error return-value
  :
    run m__fd_exe( input "cash", input '':U) .
  end.
end procedure.
procedure m__fd_ra_cashless-new-exe :
  do
  on error undo, return error return-value
  :
    run m__fd_exe('рпп':U, 'новый':U) .
  end.
end procedure.
procedure m__fd_ra_cashless-perm-exe :
  do
  on error undo, return error return-value
  :
    run m__fd_exe('рпп':U, 'разрешен':U) .
  end.
end procedure.
procedure m__fd_ra_cashless-bank-exe :
  do
  on error undo, return error return-value
  :
    run m__fd_exe('рпп':U, 'банк':U) .
  end.
end procedure.
procedure m__fd_ra_cashless-fact-exe :
  do
  on error undo, return error return-value
  :
    run m__fd_exe('рпп':U, 'факт':U) .
  end.
end procedure.
procedure m__fd_ra_cashless-all-exe :
  do
  on error undo, return error return-value
  :
    run m__fd_exe('рпп':U, '':U) .
  end.
end procedure.
procedure m__fd_ra_payoff-new-exe :
  do
  on error undo, return error return-value
  :
    run m__fd_exe('апр':U, 'новый':U) .
  end.
end procedure.
procedure m__fd_ra_payoff-perm-exe :
  do
  on error undo, return error return-value
  :
    run m__fd_exe('апр':U, 'разрешен':U) .
  end.
end procedure.
procedure m__fd_ra_payoff-fact-exe :
  do
  on error undo, return error return-value
  :
    run m__fd_exe('апр':U, 'факт':U) .
  end.
end procedure.
procedure m__fd_ra_payoff-all-exe :
  do
  on error undo, return error return-value
  :
    run m__fd_exe('апр':U, '':U) .
  end.
end procedure.
procedure m__fd_all-all-exe :
  do
  on error undo, return error return-value
  :
    run m__fd_exe('':U, '':U) .
  end.
end procedure.
procedure m__fs_all-all-exe :
  do
  on error undo, return error return-value
  :
    run m__fs_exe('фирма':U, '':U, '':U, '':U) .
  end.
end procedure.
procedure m_212-exe :
  do
  on error undo, return error return-value
  :
    run m_21-exe ( INPUT 'руб' ) .
  end.
end procedure.
procedure m_211-exe :
  do
  on error undo, return error return-value
  :
    run m_21-exe ( INPUT 'вал' ) .
  end.
end procedure.
procedure m_221-exe :
  do
  on error undo, return error return-value
  :
    run m_22-exe ( INPUT 'руб' ) .
  end.
end procedure.
procedure m_222-exe :
  do
  on error undo, return error return-value
  :
    run m_22-exe ( INPUT 'вал' ) .
  end.
end procedure.
procedure m_223-F2r-exe :
  do
  on error undo, return error return-value
  :
    run m_223-F2-exe ( INPUT 'руб' ) .
  end.
end procedure.
procedure m_223-F2b-exe :
  do
  on error undo, return error return-value
  :
    run m_223-F2-exe ( INPUT 'вал' ) .
  end.
end procedure.
procedure m_223-F3r-exe :
  do
  on error undo, return error return-value
  :
    run m_223-F3-exe ( INPUT 'руб' ) .
  end.
end procedure.
procedure m_223-F3b-exe :
  do
  on error undo, return error return-value
  :
    run m_223-F3-exe ( INPUT 'вал' ) .
  end.
end procedure.
procedure m_223-F4r-exe :
  do
  on error undo, return error return-value
  :
    run m_223-F4-exe ( INPUT 'руб' ) .
  end.
end procedure.
procedure m_223-F4b-exe :
  do
  on error undo, return error return-value
  :
    run m_223-F4-exe ( INPUT 'вал' ) .
  end.
end procedure.
procedure m_223-F5r-exe :
  do
  on error undo, return error return-value
  :
    run m_223-F5-exe ( INPUT 'руб' ) .
  end.
end procedure.
procedure m_223-F5b-exe :
  do
  on error undo, return error return-value
  :
    run m_223-F5-exe ( INPUT 'вал' ) .
  end.
end procedure.
procedure m_223-F6r-exe :
  do
  on error undo, return error return-value
  :
    run m_223-F6-exe ( INPUT 'руб' ) .
  end.
end procedure.
procedure m_223-F6b-exe :
  do
  on error undo, return error return-value
  :
    run m_223-F6-exe ( INPUT 'вал' ) .
  end.
end procedure.
procedure m_223-FSr-exe :
  do
  on error undo, return error return-value
  :
    run m_223-FS-exe ( INPUT 'руб' ) .
  end.
end procedure.
procedure m_223-FSb-exe :
  do
  on error undo, return error return-value
  :
    run m_223-FS-exe ( INPUT 'вал' ) .
  end.
end procedure.
procedure m_223-FVr-exe :
  do
  on error undo, return error return-value
  :
    run m_223-FV-exe ( INPUT 'руб' ) .
  end.
end procedure.
procedure m_223-FVb-exe :
  do
  on error undo, return error return-value
  :
    run m_223-FV-exe ( INPUT 'вал' ) .
  end.
end procedure.
procedure m_2231r-exe :
  do
  on error undo, return error return-value
  :
    run m_2231-exe ( INPUT 'руб' ) .
  end.
end procedure.
procedure m_2231b-exe :
  do
  on error undo, return error return-value
  :
    run m_2231-exe ( INPUT 'вал' ) .
  end.
end procedure.
procedure m_2232r-exe :
  do
  on error undo, return error return-value
  :
    run m_2232-exe ( INPUT 'руб' ) .
  end.
end procedure.
procedure m_2232b-exe :
  do
  on error undo, return error return-value
  :
    run m_2232-exe ( INPUT 'вал' ) .
  end.
end procedure.
procedure m_2233r-exe :
  do
  on error undo, return error return-value
  :
    run m_2233-exe ( INPUT 'руб' ) .
  end.
end procedure.
procedure m_2233b-exe :
  do on error undo, return error return-value :
    run m_2233-exe ( input 'вал' ).
  end.
end procedure.
procedure m__fin_trn1-exe :
  do
  on error undo, return error return-value
  :
    run str/fialltrn.p (input parparentproc ,1,v-cntxt-host-code-obj) .
  end.
end procedure.
procedure m__fin_trn2-exe :
  do
  on error undo, return error return-value
  :
    run str/fialltrn.p (input parparentproc ,2,v-cntxt-host-code-obj) .
  end.
end procedure.
procedure m__fin_trn3-exe :
  do
  on error undo, return error return-value
  :
    run str/fialltrn.p (input parparentproc ,4,v-cntxt-host-code-obj) .
  end.
end procedure.
procedure m__fin_trn4-exe :
  do
  on error undo, return error return-value
  :
    run str/fialltrn.p (input parparentproc ,3,v-cntxt-host-code-obj) .
  end.
end procedure.
procedure m__fin_trn6-exe :
  do
  on error undo, return error return-value
  :
    run str/fialltrn.p (input parparentproc ,11,v-cntxt-host-code-obj) .
  end.
end procedure.
procedure m__fin_trn7-exe :
  do
  on error undo, return error return-value
  :
    run str/fialltrn.p (input parparentproc ,12,v-cntxt-host-code-obj) .
  end.
end procedure.
procedure m__fin_trn8-exe :
  do
  on error undo, return error return-value
  :
    run str/fialltrn.p (input parparentproc ,13,v-cntxt-host-code-obj) .
  end.
end procedure.
procedure m__fin_trn9-exe :
  do
  on error undo, return error return-value
  :
    run str/fialltrn.p (input parparentproc ,0,v-cntxt-host-code-obj) .
  end.
end procedure.
procedure m-fin-trn-del-exe :
  do
  on error undo, return error return-value
  :
    run dm-c-doc-exe (INPUT 'уд_фирма':U, INPUT ?, INPUT '?', INPUT '?', INPUT ?, INPUT 'rv':U, input ? ) .
  end.
end procedure.
procedure m-assort-amin-exe :
  do
  on error undo, return error return-value
  :
    run ref/gds-amin.w (parparentproc,v-cntxt-obj-type,v-cntxt-obj-code,?) .
  end.
end procedure.
procedure m-assort-polit-izt-exe :
  do
  on error undo, return error return-value
  :
    run ref/u-ind.p ( input parparentproc, v-cntxt-obj-type , v-cntxt-obj-code ) .
  end.
end procedure.
procedure m-assort-krit-anal-exe :
  define variable varrid-list   as   character           no-undo.
  do
  on error undo, return error return-value
  :
    run ref/critanal.w (parparentproc, '','', output varrid-list) .
  end.
end procedure.
procedure m-copyamin :
  do
  on error undo, return error return-value
  :
    run ref/copyamin.p (input  parparentproc, input v-cntxt-obj-type, input v-cntxt-obj-code) .
  end.
end procedure.
procedure m-assort-abc-anal-exe :
  do
  on error undo, return error return-value
  :
  define variable p-rez as character no-undo .
    run ref/abcanal.w (input parparentproc ,  "b-add,b-del" , output p-rez) .
  end.
end procedure.
procedure m-assort-abcxyzc :
  do
  on error undo, return error return-value
  :
    define variable p-rez as character no-undo .
    run ref/abcxyzv.w (input parparentproc ,  "b-add,b-del" , output p-rez ) .
  end.
end procedure.
procedure m-assort-xyz-anal-exe :
  do
  on error undo, return error return-value
  :
    define variable p-rez as character no-undo .
    run ref/xyzanal.w (parparentproc ,  "b-add,b-del" , output p-rez) .
  end.
end procedure.
procedure dm-doc-exe :
define input parameter parlistmode     as character no-undo.
define input parameter parflag         as logical   no-undo.
define input parameter parstat         as character no-undo.
define input parameter partype         as character no-undo.
define input parameter parinternal     as logical   no-undo.
define input parameter parext-doc-type as character no-undo.
define input parameter paris-hold      as logical   no-undo.
define variable loc-ref-list           as character no-undo.
define variable v-ok                   as logical   no-undo.
assign v-ok = yes.
if parlistmode = 'фирма':U then do:
define variable vss-include-info70 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_documents_company':U
    ,input  'firm':U
    ,input  v-cntxt-host-code-obj
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output v-ok
    )  .
end.
end.
if v-ok then do:
  run str/all-docs.w (input  parparentproc,
                      input  v-cntxt-host-code-obj ,
                      input  v-cntxt-obj-type      ,
                      input  v-cntxt-obj-code      ,
                      input  parlistmode,
                      input  parstat,
                      input  partype,
                      input  parflag,
                      input  parinternal,
                      input  "b-mark",
                      input  parext-doc-type,
                      input  paris-hold,
                      input  ?,
                      output loc-ref-list).
end.
end procedure.
procedure dm-fl-exe :
define input parameter parlistmode     as character no-undo.
define input parameter parflag         as logical   no-undo.
define input parameter parstat         as character no-undo.
define variable loc-ref-list as character no-undo.
run str/all-docf.w (input parparentproc,
               input ""   ,
               input parlistmode ,
               input parflag ,
               input parstat ,
               output loc-ref-list).
end procedure.
PROCEDURE m_scn-flt-exe :
define variable vartempchar   as   character           no-undo.
get-key-value section 'mob_scan' key 'scan_com' value varTempChar.
if varTempChar = ? then do:
  message 'Отсутствует секция mob_scan в progress.ini'.
end.
else do:
  os-command value (varTempChar).
end.
end.
procedure proc-hour-proc :
define input parameter p-proc-name as character no-undo .
define input parameter p-proc-title  as character no-undo .
define variable varis-ok      as   logical             no-undo initial no.
define variable vss-include-info71 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_cur-obj-proceeds_print':U
    ,input  'firm':U
    ,input  v-cntxt-host-code-obj
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output varis-ok
    )  .
end.
if not varis-ok then return error.
run rep/d-report.w ( input parparentproc ,input p-proc-name, input p-proc-title, 2, '', '*', '', '', 'shop,', no).
end procedure.
PROCEDURE m-chkhr-exe :
run proc-hour-proc in this-procedure (input 'rep/e-chkhr.w', input 'Почасовая статистика розничных продаж по КОЛИЧЕСТВУ ПОКУПОК').
END PROCEDURE.
PROCEDURE m-grphr-exe :
run rep/g-grphr.p ( input parparentproc) no-error.
END PROCEDURE.
PROCEDURE m-sumhr-exe :
run proc-hour-proc in this-procedure (input 'rep/e-sumhr.w', input 'Почасовая статистика розничных продаж по СУММЕ ПРОДАЖ').
END PROCEDURE.
PROCEDURE m-svhr-exe :
run proc-hour-proc in this-procedure (input 'rep/e-svhr.w', input 'Почасовая статистика розничных продаж  ПО ВЕЛИЧИНЕ СУММ ПРОДАЖ').
END PROCEDURE.
PROCEDURE m-buyers-exe :
define variable v-host-code like ub.sysconf.host-code no-undo .
define variable vss-include-info72 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-host-code
  )  .
 run rep/buyers.w (input parparentproc, input v-host-code).
END PROCEDURE.
PROCEDURE m-sj-exe :
  run rep/g-sj.p (input parparentproc, input "").
END PROCEDURE.
PROCEDURE m-sjjwl-exe :
  run rep/g-sj.p (input parparentproc, input '2ед':U).
END PROCEDURE.
PROCEDURE m-benefi-exe :
  run rep/g-benefi.p (input parparentproc, "rep/e-benefi.w").
END PROCEDURE.
procedure m-sale-rom-exe :
 do on error undo, return error return-value  :
   run rep/sale-rom.w (input parparentproc, input v-cntxt-obj-type, input v-cntxt-obj-code ) .
  end.
 end procedure.
PROCEDURE m-srvsal-exe :
run rep/d-report.w (
                            input parparentproc
                           ,input 'rep/e-srvsl1.w'
                           ,input ('Реализация услуг')
                           ,input 2
                           ,input "1,3,4"
                           ,input "*"
                           ,input ""
                           ,input ""
                           ,input "shop"
                           ,input no).
END PROCEDURE.
PROCEDURE m_fin_cli-all-exe :
define variable v-rid-list as character no-undo .
run ref/cli-all.w (input parparentproc, "b-add,b-bank":U, 'орг':U, ?, ?, ?, ?, "without-obj":U, output v-rid-list) .
END PROCEDURE.
PROCEDURE m_finbanks-exe :
define variable v-rid-list as character no-undo .
define variable v-status_ like ub.fin-bank.status_ no-undo init 'тек':U.
run ref/finbanks.w (input parparentproc
             , input v-cntxt-host-code-obj
             , input "b-add,b-mark,b-copy":U
             , input 'фирма':U
             , input v-cntxt-host-code-obj
             , input-output v-status_
             , input-output v-rid-list).
END PROCEDURE.
PROCEDURE m_finschets-exe :
define variable v-rid-list as character no-undo .
define variable v-status_ like ub.fin-bank.status_ no-undo init 'тек':U.
run ref/finschts.w (input parparentproc
             , input v-cntxt-host-code-obj
             , input "b-add,b-mark,b-copy":U
             , input 'фирма':U
             , input "":U
             , input 0
             , input ?
             , input v-cntxt-host-code-obj
             , input 0
             , input-output v-status_
             , input-output v-rid-list).
END PROCEDURE.
procedure m__fd_exe :
define input parameter p-fin-doc-type like ub.fin-doc.fin-doc-type no-undo .
define input parameter p-status_ like ub.fin-doc.status_ no-undo .
define variable v-rid-list as character no-undo .
define variable v-mode as character no-undo .
define variable v-obj-type as character no-undo .
define variable v-obj-code as integer no-undo .
if num-entries(p-fin-doc-type, chr(4)) > 1
and entry(2, p-fin-doc-type, chr(4)) =  'объект':U
then do:
  v-obj-type = v-cntxt-obj-type.
  v-obj-code = v-cntxt-obj-code.
  assign v-mode =  (if p-fin-doc-type = "":U
                     then 'объект':U
                     else (if p-status_ = "":U
                           then "type-object":U
                           else "type-stat-object":U))
  p-fin-doc-type = entry(1, p-fin-doc-type, chr(4))
  .
end.
else do:
  assign v-mode =  (if p-fin-doc-type = "":U
                     then 'фирма':U
                     else (if p-status_ = "":U
                           then "type":U
                           else "type-stat":U))
  .
end.
run ref/findocs.w (input parparentproc, input v-cntxt-host-code-obj, input "":U
              ,input v-mode
              ,input 'все':U
              ,input v-cntxt-host-code-obj
              ,input v-obj-type
              ,input v-obj-code
              ,input p-status_
              ,input p-fin-doc-type
              ,input "":U
              ,input ?
              ,input ?
              ,input "":U
              ,input "":U
              ,input 0
              ,input "":U
              ,input "":U
              ,input 0
              ,input "":U
              ,input ?
              ,input 0
              ,input 0
              ,input 0
              ,input 0
              ,input 0
              ,input 0
              ,input 0
              ,input-output v-rid-list).
end procedure.
procedure m__fd_casho-encashment-exe :
define variable v-doc-rec as recid no-undo .
run ref/finencsh.p  (
                      input parparentproc
                     ,input v-cntxt-host-code-obj
                     ,input v-cntxt-obj-type
                     ,input v-cntxt-obj-code
                     ,input no
                     ,input yes
                     ) no-error.
end procedure.
procedure m__cfd_exe :
define variable v-rid-list as character no-undo .
run ref/fincdocs.w (
               input parparentproc
              ,input v-cntxt-host-code-obj
              ,input ''
              ,input 'удаление':U
              ,input v-cntxt-host-code-obj
              ,input ''
              ,input 0
              ,input 0
              ,input-output v-rid-list).
end procedure.
procedure m__cfdo_exe :
define variable v-rid-list as character no-undo .
run ref/fincdocs.w (
               input parparentproc
              ,input v-cntxt-host-code-obj
              ,input ''
              ,input 'объект':U
              ,input v-cntxt-host-code-obj
              ,input v-cntxt-obj-type
              ,input v-cntxt-obj-code
              ,input 0
              ,input-output v-rid-list).
end procedure.
procedure m__fs_exe :
define input parameter p-mode as character no-undo .
define input parameter p-status_ like ub.fin-statement.status_ no-undo .
define input parameter p-fins-doc-type like ub.fin-statement.fins-doc-type no-undo .
define input parameter p-fins-ext-doc-type like ub.fin-statement.fins-doc-type no-undo .
define variable v-rid-list as character no-undo .
run ref/finsttms.w (
               input parparentproc
              ,input v-cntxt-host-code-obj
              ,input "":U
              ,input p-mode
              ,input v-cntxt-host-code-obj
              ,input p-status_
              ,input p-fins-doc-type
              ,input p-fins-ext-doc-type
              ,input ?
              ,input ?
              ,input 0
              ,input 0
              ,input ?
              ,input-output v-rid-list).
end procedure.
procedure m_EGAIS-all-awo_exe :
define variable v-RegID as character no-undo .
run bge/egais-all-act-writeOff.w (input parparentproc, input no, output v-RegID ) .
end procedure .
procedure m_EGAIS-all-awoS_exe :
define variable v-RegID as character no-undo .
run bge/egais-all-act-writeOff_shop.w (input parparentproc, input no, output v-RegID ) .
end procedure .
procedure chk-goods_add :
  define output parameter p-enable-item as logical   no-undo .
  do
  on error undo, return error return-value
  :
    IF not p-enable-item then do:
define variable vss-include-info73 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_cashdesk-goods_add-def':U
    ,input  'object':U
    ,input  v-cntxt-host-code-obj
    ,input  v-cntxt-obj-type
    ,input  v-cntxt-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output p-enable-item
    )  .
end.
    end.
  end.
end procedure.
procedure chk-user-adm :
  define output parameter p-enable-item as logical   no-undo .
  do
  on error undo, return error return-value
  :
define variable vss-include-info74 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run user-adm in g#library2
  (input  v-cntxt-db-num
  ,input  v-cntxt-userid
  ,output p-enable-item
  )  .
    IF not p-enable-item then do:
define variable vss-include-info75 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_admin':U
    ,input  'global':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output p-enable-item
    )  .
end.
    end.
  end.
end procedure.
procedure chk-is-wth :
  define output parameter p-enable-item as logical   no-undo .
  define variable v-is-wth as character no-undo .
  define variable par-type as character no-undo .
  do
  on error undo, return error return-value
  :
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-wth':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  no
  ,output v-is-wth
  ,output par-type
  ) no-error .
    if error-status :error
    or par-type <> 'L':U
    or v-is-wth <> 'yes':u
    then do:
      assign
        v-is-wth = 'no':u
      .
    end.
    if v-is-wth = 'yes':u
    then do:
      assign
        p-enable-item = true
      .
    end.
    else do:
      assign
        p-enable-item = false
      .
    end.
  end.
end procedure.
procedure chk-ser-wth :
  define output parameter p-enable-item as logical   no-undo .
  define variable v-ser-wth as character no-undo .
  define variable par-type as character no-undo .
  do
  on error undo, return error return-value
  :
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'ser-wth':u
  ,input  0
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  no
  ,output v-ser-wth
  ,output par-type
  ) no-error .
    if error-status :error
    or par-type <> 'L':U
    or v-ser-wth <> 'yes':u
    then do:
      assign
        v-ser-wth = 'no':u
      .
    end.
    if v-ser-wth = 'yes':u
    then do:
      assign
        p-enable-item = true
      .
    end.
    else do:
      assign
        p-enable-item = false
      .
    end.
  end.
end procedure.
procedure chk-is-jwlr :
  define output parameter p-enable-item as logical   no-undo .
  define variable v-is-jwlr as character no-undo .
  define variable par-type  as character no-undo .
  do
  on error undo, return error return-value
  :
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-jwlr':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  no
  ,output v-is-jwlr
  ,output par-type
  ) no-error .
    if error-status :error
    or par-type  <> 'L':U
    or v-is-jwlr <> 'yes':u
    then do:
      assign
        v-is-jwlr = 'no':u
      .
    end.
    if v-is-jwlr = 'yes':u
    then do:
      assign
        p-enable-item = true
      .
    end.
    else do:
      assign
        p-enable-item = false
      .
    end.
  end.
end procedure.
procedure chk-is-ptrl :
  define output parameter p-enable-item as logical   no-undo .
  define variable v-is-ptrl as character no-undo .
  define variable par-type  as character no-undo .
  do
  on error undo, return error return-value
  :
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-ptrl':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  no
  ,output v-is-ptrl
  ,output par-type
  ) no-error .
    if error-status :error
    or par-type  <> 'L':U
    or v-is-ptrl <> 'yes':u
    then do:
      assign
        v-is-ptrl = 'no':u
      .
    end.
    if v-is-ptrl = 'yes':u
    then do:
      assign
        p-enable-item = true
      .
    end.
    else do:
      assign
        p-enable-item = false
      .
    end.
  end.
end procedure.
procedure chk-is-cdinv :
  define output parameter p-enable-item as logical   no-undo .
  define variable v-is-cdinv as character no-undo .
  define variable par-type   as character no-undo .
  do
  on error undo, return error return-value
  :
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-cdinv':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  no
  ,output v-is-cdinv
  ,output par-type
  ) no-error .
    if error-status :error
    or v-is-cdinv  <> 'yes':u
    then do:
      assign
        v-is-cdinv = 'no':u
      .
    end.
    if v-is-cdinv = 'yes':u
    then do:
      assign
        p-enable-item = true
      .
    end.
    else do:
      assign
        p-enable-item = false
      .
    end.
  end.
end procedure.
procedure chk-is-custm :
  define output parameter p-enable-item as logical   no-undo .
  define variable v-is-custm as character no-undo .
  define variable par-type   as character no-undo .
  do
  on error undo, return error return-value
  :
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-custm':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  no
  ,output v-is-custm
  ,output par-type
  ) no-error .
    if v-is-custm = 'yes':u
    then do:
      assign
        p-enable-item = true
      .
    end.
    else do:
      assign
        p-enable-item = false
      .
    end.
  end.
end procedure.
procedure chk-alcohol :
  define output parameter p-enable-item as logical   no-undo .
  define variable v-alcohol as character no-undo .
  define variable par-type  as character no-undo .
  do
  on error undo, return error return-value
  :
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'alcohol':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  no
  ,output v-alcohol
  ,output par-type
  ) no-error .
    if v-alcohol = 'yes':u
    then do:
      assign
        p-enable-item = true
      .
    end.
    else do:
      assign
        p-enable-item = false
      .
    end.
  end.
end procedure.
procedure chk-mercuri :
  define output parameter p-enable-item as logical   no-undo .
  define variable v-mercuri as character no-undo .
  define variable par-type  as character no-undo .
  do
  on error undo, return error return-value
  :
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'mercuri':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  no
  ,output v-mercuri
  ,output par-type
  ) no-error .
    if v-mercuri = 'no':u or v-mercuri = ""
    then do:
      assign
        p-enable-item = false
      .
    end.
    else do:
      assign
        p-enable-item = true
      .
    end.
  end.
end procedure.
procedure chk-holding :
  define output parameter p-enable-item as logical   no-undo .
  define variable v-holding as character no-undo .
  define variable par-type  as character no-undo .
  do
  on error undo, return error return-value
  :
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'holding':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  no
  ,output v-holding
  ,output par-type
  ) no-error .
    if v-holding = 'yes':u
    then do:
      assign
        p-enable-item = true
      .
    end.
    else do:
      assign
        p-enable-item = false
      .
    end.
  end.
end procedure.
procedure chk-holding-no :
  define output parameter p-enable-item as logical   no-undo .
  define variable v-holding as character no-undo .
  define variable par-type  as character no-undo .
  do
  on error undo, return error return-value
  :
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'holding':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  no
  ,output v-holding
  ,output par-type
  ) no-error .
    if v-holding = 'no':u
    then do:
      assign
        p-enable-item = true
      .
    end.
    else do:
      assign
        p-enable-item = false
      .
    end.
  end.
end procedure.
procedure chk-shuttle-yes :
  define output parameter p-enable-item as logical   no-undo .
  define variable v-shuttle as character no-undo .
  define variable par-type  as character no-undo .
  do
  on error undo, return error return-value
  :
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'shuttlsp':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  no
  ,output v-shuttle
  ,output par-type
  ) no-error .
    if v-shuttle = 'yes':u
    then do:
      assign
        p-enable-item = true
      .
    end.
    else do:
      assign
        p-enable-item = false
      .
    end.
  end.
end procedure.
procedure chk-db-num-0 :
  define output parameter p-enable-item as logical   no-undo .
  define variable v-current-db-num as integer   no-undo .
  do
  on error undo, return error return-value
  :
define variable vss-include-info76 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output v-current-db-num
  )  .
    if v-current-db-num = 0
    then do:
      assign
        p-enable-item = true
      .
    end.
    else do:
      assign
        p-enable-item = false
      .
    end.
  end.
end procedure.
procedure chk-firm-db-num :
  define output parameter p-enable-item as logical   no-undo .
  define variable v-current-db-num as integer   no-undo .
  define variable v-firm-db-num as integer   no-undo .
  do
  on error undo, return error return-value
  :
define variable vss-include-info77 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output v-current-db-num
  )  .
define variable vss-include-info78 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run frmdbnum in g#library2
  (input  v-cntxt-host-code-obj
  ,output v-firm-db-num
  )  .
    if v-current-db-num = v-firm-db-num
    then do:
      assign
        p-enable-item = true
      .
    end.
    else do:
      assign
        p-enable-item = false
      .
    end.
  end.
end procedure.
procedure chk-is-dc :
  define output parameter p-enable-item as logical   no-undo .
  define variable v-is-dc  as character no-undo .
  define variable par-type as character no-undo .
  do
  on error undo, return error return-value
  :
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-dc':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  no
  ,output v-is-dc
  ,output par-type
  ) no-error .
    if error-status :error
    or par-type <> 'L':U
    or v-is-dc  <> 'yes':u
    then do:
      assign
        v-is-dc = 'no':u
      .
    end.
    if v-is-dc = 'yes':u
    then do:
      assign
        p-enable-item = true
      .
    end.
    else do:
      assign
        p-enable-item = false
      .
    end.
  end.
end procedure.
procedure chk-is-ef :
  define output parameter p-enable-item as logical   no-undo .
  define variable v-is-ef  as character no-undo .
  define variable par-type as character no-undo .
  do
  on error undo, return error return-value
  :
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-ef':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  no
  ,output v-is-ef
  ,output par-type
  ) no-error .
    if error-status :error
    or par-type <> 'L':U
    or v-is-ef  <> 'yes':u
    then do:
      assign
        v-is-ef = 'no':u
      .
    end.
    if v-is-ef = 'yes':u
    then do:
      assign
        p-enable-item = true
      .
    end.
    else do:
      assign
        p-enable-item = false
      .
    end.
  end.
end procedure.
procedure chk-is-flora :
  define output parameter p-enable-item as logical   no-undo .
  define variable v-is-flora as character no-undo .
  define variable par-type as character no-undo .
  do
  on error undo, return error return-value
  :
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-flora':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  no
  ,output v-is-flora
  ,output par-type
  ) no-error .
    if error-status :error
    or par-type <> 'L':U
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Неправильный тип конфигурационного параметра is-flora" skip
        view-as alert-box error .
      return error.
    end.
    if v-is-flora = 'yes':u
    then do:
      assign
        p-enable-item = true
      .
    end.
    else do:
      assign
      p-enable-item = false
      .
    end.
  end.
end procedure.
procedure chk-is-abc :
  define output parameter p-enable-item as logical   no-undo .
  define variable v-is-abc  as character no-undo .
  define variable par-type   as character no-undo .
  do
  on error undo, return error return-value
  :
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-abc'
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  no
  ,output v-is-abc
  ,output par-type
  ) no-error .
    if lookup( v-is-abc, "yes,no" ) = 0
    or v-is-abc = ?
    or par-type <> 'L':U
    or error-status :error
    then do:
      assign
        v-is-abc = "no"
      .
    end.
    if v-is-abc = 'no':u
    then do:
      assign
        p-enable-item = false
      .
    end.
    else do:
      assign
        p-enable-item = true
      .
    end.
  end.
end procedure.
procedure chk-is-edi :
  define output parameter p-enable-item as logical   no-undo .
  define variable v-is-edi as character no-undo .
  define variable par-type  as character no-undo .
  do
  on error undo, return error return-value
  :
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-edi':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  no
  ,output v-is-edi
  ,output par-type
  ) no-error .
    if error-status :error
    or par-type  <> 'L':U
    or v-is-edi <> 'yes':u
    then do:
      assign
        v-is-edi = 'no':u
      .
    end.
    if v-is-edi = 'yes':u
    then do:
      assign
        p-enable-item = true
      .
    end.
    else do:
      assign
        p-enable-item = false
      .
    end.
  end.
end procedure.
procedure chk-bgefmt-is-analythic :
  define output parameter p-enable-item as logical   no-undo .
  define variable v-bgefmt      as character    no-undo.
  define variable v-param-type      as character  no-undo .
  define variable v-value-character as character  no-undo .
  define variable v-value-date      as date       no-undo .
  define variable v-value-decimal   as decimal    no-undo .
  define variable v-value-integer   as integer    no-undo .
  define variable v-value-logical   as logical    no-undo .
  define variable v-tth             as handle     no-undo .
  do
  on error undo, return error return-value
  :
    run adm/shattri.p ( input "get":U
                      , input  '':u
                      , input  0
                      , input  'bge-export':U
                      , input  'bgefmt':U
                      , output v-value-character
                      , output v-value-date
                      , output v-value-decimal
                      , output v-value-integer
                      , output v-value-logical
                      , output v-param-type
                      , input-output table-handle v-tth
                      ) no-error .
    if error-status :error
    then do:
      assign
        p-enable-item = false
      .
    end.
    else do:
      assign
        v-bgefmt = v-value-character
      .
      if v-bgefmt = 'analythic':u
      then do:
          assign
              p-enable-item = true
          .
      end.
      else do:
          assign
              p-enable-item = false
          .
      end.
    end.
    delete object v-tth.
  end.
end procedure.
procedure chk-bgefmt-is-not-analythic :
  define output parameter p-enable-item as logical   no-undo .
  do
  on error undo, return error return-value
  :
    run chk-bgefmt-is-analythic in this-procedure (
        output p-enable-item
    ) no-error.
    if error-status :error
    then do:
        assign
            p-enable-item = false
        .
    end.
    else do:
        assign
            p-enable-item = not p-enable-item
        .
    end.
  end.
end procedure.
procedure chk-orders :
  define output parameter p-enable-item as logical   no-undo .
  define variable v-orders as character no-undo .
  define variable par-type as character no-undo .
  do
  on error undo, return error return-value
  :
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'orders':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  no
  ,output v-orders
  ,output par-type
  ) no-error .
    if error-status :error
    or par-type <> 'L':U
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Неправильный тип конфигурационного параметра orders" skip
        view-as alert-box error .
      return error.
    end.
    if v-orders = 'yes':u
    then do:
      assign
        p-enable-item = true
      .
    end.
    else do:
      assign
        p-enable-item = false
      .
    end.
  end.
end procedure.
procedure chk-orders-fby :
  define output parameter p-enable-item as logical   no-undo .
  define variable v-orders as character no-undo .
  define variable par-type as character no-undo .
  do
  on error undo, return error return-value
  :
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'orders':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  no
  ,output v-orders
  ,output par-type
  ) no-error .
    if error-status :error
    or par-type <> 'L':U
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Неправильный тип конфигурационного параметра orders" skip
        view-as alert-box error .
      return error.
    end.
    if v-orders = 'yes':u
    then do:
      assign
        p-enable-item = true
      .
    end.
    else do:
      assign
        p-enable-item = false
      .
      return .
    end.
    v-orders = ''.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-finby':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  no
  ,output v-orders
  ,output par-type
  ) no-error .
    if v-orders <> '':U
    and (error-status :error
    or par-type <> 'L':U)
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Неправильный тип конфигурационного параметра is-finby" skip
        view-as alert-box error .
      return error.
    end.
    p-enable-item = true .
    if v-cntxt-db-num > 0 and v-orders <> 'yes' then do:
       assign
         p-enable-item = false
       .
    end.
  end.
end procedure.
procedure chk-is-thpos :
  define output parameter p-enable-item as logical   no-undo .
  define variable v-is-thpos  as character no-undo .
  define variable par-type as character no-undo .
  do
  on error undo, return error return-value
  :
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-thpos':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  no
  ,output v-is-thpos
  ,output par-type
  ) no-error .
    if error-status :error
    or par-type <> 'L':U
    or v-is-thpos  <> 'yes':u
    then do:
      assign
        v-is-thpos = 'no':u
      .
    end.
    if v-is-thpos = 'yes':u
    then do:
      assign
        p-enable-item = true
      .
    end.
    else do:
      assign
        p-enable-item = false
      .
    end.
  end.
end procedure.
procedure chk-is-addcharges :
  define output parameter p-enable-item as logical   no-undo .
  define variable v-is-add as character no-undo .
  define variable par-type   as character no-undo .
  do
  on error undo, return error return-value
  :
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-addch':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  no
  ,output v-is-add
  ,output par-type
  ) no-error .
    if v-is-add = 'yes'
    then do:
      assign
        p-enable-item = true
      .
    end.
    else do:
      assign
        p-enable-item = false
      .
    end.
  end.
end procedure.
procedure chk-is-not-addcharges :
  define output parameter p-enable-item as logical   no-undo .
  define variable v-is-add as character no-undo .
  define variable par-type   as character no-undo .
  do
  on error undo, return error return-value
  :
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-addch':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  no
  ,output v-is-add
  ,output par-type
  ) no-error .
    if v-is-add = 'yes'
    then do:
      assign
        p-enable-item = false
      .
    end.
    else do:
      assign
        p-enable-item = true
      .
    end.
  end.
end procedure.
procedure chk-ord-op :
  define output parameter p-enable-item as logical   no-undo .
  define variable v-ord-op as logical   no-undo .
  define variable v-value-character  as character no-undo .
  define variable v-value-date       as date      no-undo .
  define variable v-value-decimal    as decimal   no-undo .
  define variable v-value-integer    as integer   no-undo .
  define variable par-type as character no-undo .
  do
  on error undo, return error return-value
  :
    run adm/shattri.p (
      input "get":U
      ,input ""
      ,input 0
      ,input 'ord-global':U
      ,input  'ord-op':U
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-ord-op
      ,output par-type
      ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
      ) no-error .
    if error-status :error
    or v-ord-op  <> yes then do:
      assign
        v-ord-op = no
      .
    end.
    if v-ord-op = yes
    then do:
      assign
        p-enable-item = true
      .
    end.
    else do:
      assign
        p-enable-item = false
      .
    end.
  end.
end procedure.
procedure chk-ord-ofof :
  define output parameter p-enable-item as logical   no-undo .
  define variable v-ord-ofof as logical   no-undo .
  define variable v-value-character  as character no-undo .
  define variable v-value-date       as date      no-undo .
  define variable v-value-decimal    as decimal   no-undo .
  define variable v-value-integer    as integer   no-undo .
  define variable par-type as character no-undo .
  define variable v-act as logical   no-undo .
  do
  on error undo, return error return-value
  :
  run chk-obj-active (output v-act) .
  if v-act then do:
     p-enable-item = true.
     return .
  end.
    run adm/shattri.p (
      input "get":U
      ,input ""
      ,input 0
      ,input 'ord-global':U
      ,input  'ord-ofof':U
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-ord-ofof
      ,output par-type
      ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
      ) no-error .
    if error-status :error
    or v-ord-ofof  <> yes then do:
      assign
        v-ord-ofof = no
      .
    end.
    if v-ord-ofof = yes
    then do:
      assign
        p-enable-item = true
      .
    end.
    else do:
      assign
        p-enable-item = false
      .
    end.
  end.
end procedure.
procedure chk-is-fbr :
  define output parameter p-enable-item as logical   no-undo .
  define variable v-is-fbr as character no-undo .
  define variable par-type   as character no-undo .
  do
  on error undo, return error return-value
  :
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-fbr':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  no
  ,output v-is-fbr
  ,output par-type
  ) no-error .
    if error-status :error
    or par-type <> 'L':U
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Неправильный тип конфигурационного параметра is-fbr" skip
        view-as alert-box error .
      return error.
    end.
    if v-is-fbr = 'yes':u
    then do:
      assign
        p-enable-item = true
      .
    end.
    else do:
      assign
        p-enable-item = false
      .
    end.
  end.
end procedure.
procedure chk-oxmlthon :
  define output parameter p-enable-item as logical   no-undo .
  define variable v-oxmlthon as character no-undo .
  define variable par-type   as character no-undo .
  do
  on error undo, return error return-value
  :
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'oxmlthon':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  no
  ,output v-oxmlthon
  ,output par-type
  ) no-error .
    if error-status :error
    or par-type   <> 'L':U
    or v-oxmlthon <> 'yes':u
    then do:
      assign
        v-oxmlthon = 'no':u
      .
    end.
    if v-oxmlthon = 'yes':u
    then do:
      assign
        p-enable-item = true
      .
    end.
    else do:
      assign
        p-enable-item = false
      .
    end.
  end.
end procedure.
procedure chk-r-b-base :
  define output parameter p-enable-item as logical   no-undo .
  define variable v-r-b    as character no-undo .
  define variable par-type as character no-undo .
  do
  on error undo, return error return-value
  :
define variable vss-include-info79 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output v-r-b
  ) no-error .
    if error-status :error
    or lookup( v-r-b, 'rubl,base':u ) = 0
    then do:
      assign
        v-r-b = ?
      .
    end.
    if v-r-b = 'base':u
    then do:
      assign
        p-enable-item = true
      .
    end.
    else do:
      assign
        p-enable-item = false
      .
    end.
  end.
end procedure.
procedure chk-obj-active :
  define output parameter p-enable-item as logical   no-undo .
  define variable v-obj-active as logical   no-undo .
  do
  on error undo, return error return-value
  :
    if  v-cntxt-obj-code <> ?
    and v-cntxt-obj-code <> 0
    then do:
define variable vss-include-info80 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,input  'active=request'
  ,output v-obj-active
  )  .
    end.
    else do:
      assign
        v-obj-active = ?
      .
    end.
    if v-obj-active = true
    then do:
      assign
        p-enable-item = true
      .
    end.
    else do:
      assign
        p-enable-item = false
      .
    end.
  end.
end procedure.
procedure chk-obj-active-or-db-num-0 :
  define output parameter p-enable-item as logical   no-undo .
  define variable v-obj-active as logical   no-undo .
  define variable v-current-db-num as integer   no-undo .
  do
  on error undo, return error return-value
  :
define variable vss-include-info81 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output v-current-db-num
  )  .
    if  v-cntxt-obj-code <> ?
    and v-cntxt-obj-code <> 0
    then do:
define variable vss-include-info82 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,input  'active=request'
  ,output v-obj-active
  )  .
    end.
    else do:
      assign
        v-obj-active = ?
      .
    end.
    if v-obj-active = true
    or v-current-db-num = 0
    then do:
      assign
        p-enable-item = true
      .
    end.
    else do:
      assign
        p-enable-item = false
      .
    end.
  end.
end procedure.
procedure chk-obj-type-shop :
  define output parameter p-enable-item as logical   no-undo .
  do
  on error undo, return error return-value
  :
    if v-cntxt-obj-type = 'маг':U
    then do:
      assign
        p-enable-item = true
      .
    end.
    else do:
      assign
        p-enable-item = false
      .
    end.
  end.
end procedure.
procedure chk-shift :
  define output parameter p-enable-item as logical   no-undo .
  define variable v-shift-obj-on as logical   no-undo .
  do
  on error undo, return error return-value
  :
    if  v-cntxt-obj-code <> ?
    and v-cntxt-obj-code <> 0
    then do:
define variable vss-include-info83 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,input  'shift-on=request':u
  ,output v-shift-obj-on
  ) no-error .
    end.
    else do:
      assign
        v-shift-obj-on = ?
      .
    end.
    if v-shift-obj-on = true
    then do:
      assign
        p-enable-item = true
      .
    end.
    else do:
      assign
        p-enable-item = false
      .
    end.
  end.
end procedure.
PROCEDURE chk-is-finby :
  define output parameter p-enable-item as logical   no-undo .
  define variable v-is-finby as character no-undo .
  define variable par-type as character no-undo .
  do
  on error undo, return error return-value
  :
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-finby':U
  ,input  '':U
  ,input  '':U
  ,input  0
  ,input  '':U
  ,input  '':U
  ,input  '':U
  ,input  no
  ,output v-is-finby
  ,output par-type
  ) no-error .
    if error-status :error
    then do:
      v-is-finby = 'no':U .
    end.
    if  v-is-finby = 'yes':U
    then do:
      assign
        p-enable-item = true
      .
    end.
    else do:
      assign
        p-enable-item = false
      .
    end.
  end.
END PROCEDURE.
procedure chk-menu-group-all :
  define output parameter p-enable-item as logical   no-undo .
  do
  on error undo, return error return-value
  :
    run chk-menu-group-valid in parparentproc
      (input  'all':u
      ,output p-enable-item
      ) .
  end.
end procedure.
procedure chk-menu-group-off :
  define output parameter p-enable-item as logical   no-undo .
  do
  on error undo, return error return-value
  :
    run chk-menu-group-valid in parparentproc
      (input  'off':u
      ,output p-enable-item
      ) .
  end.
end procedure.
procedure chk-menu-group-str :
  define output parameter p-enable-item as logical   no-undo .
  do
  on error undo, return error return-value
  :
    run chk-menu-group-valid in parparentproc
      (input  'str':u
      ,output p-enable-item
      ) .
  end.
end procedure.
procedure chk-menu-group-shp :
  define output parameter p-enable-item as logical   no-undo .
  do
  on error undo, return error return-value
  :
    run chk-menu-group-valid in parparentproc
      (input  'shp':u
      ,output p-enable-item
      ) .
  end.
end procedure.
procedure chk-menu-group-res :
  define output parameter p-enable-item as logical   no-undo .
  do
  on error undo, return error return-value
  :
    run chk-menu-group-valid in parparentproc
      (input  'res':u
      ,output p-enable-item
      ) .
  end.
end procedure.
procedure chk-menu-group-fin :
  define output parameter p-enable-item as logical   no-undo .
  do
  on error undo, return error return-value
  :
    run chk-menu-group-valid in parparentproc
      (input  'fin':u
      ,output p-enable-item
      ) .
  end.
end procedure.
procedure chk-menu-group-bge :
  define output parameter p-enable-item as logical   no-undo .
  do
  on error undo, return error return-value
  :
    run chk-menu-group-valid in parparentproc
      (input  'bge':u
      ,output p-enable-item
      ) .
  end.
end procedure.
procedure chk-menu-group-adm :
  define output parameter p-enable-item as logical   no-undo .
  do
  on error undo, return error return-value
  :
    run chk-menu-group-valid in parparentproc
      (input  'adm':U
      ,output p-enable-item
      ) .
  end.
end procedure.
procedure chk-menu-group-mmr :
  define output parameter p-enable-item as logical   no-undo .
  do
  on error undo, return error return-value
  :
    run chk-menu-group-valid in parparentproc
      (input  'mmr':U
      ,output p-enable-item
      ) .
  end.
end procedure.
procedure clear-menu :
  define variable v-menu-item-handle as widget-handle no-undo .
  assign
    v-menu-item-handle = p-menu-handle :first-child
  .
  do while valid-handle(v-menu-item-handle)
  :
    delete widget v-menu-item-handle .
    assign
      v-menu-item-handle = p-menu-handle :first-child
    .
  end.
end procedure.
procedure m-pinp :
  do on error undo, return error return-value  :
    run rep/r-pinp.p (input parparentproc, input v-cntxt-obj-type, input v-cntxt-obj-code ) .
  end.
end procedure.
procedure m-pexcis :
  do on error undo, return error return-value  :
    run rep/r-pexcis.p (input parparentproc, input v-cntxt-obj-type, input v-cntxt-obj-code ) .
  end.
end procedure.
procedure m-is_PM-rep :
  do on error undo, return error return-value  :
    run rep/g-is_PM-rep.w ( input parparentproc ) .
  end.
end procedure.
procedure m-shift-periods :
  do on error undo, return error return-value  :
    run rep/g-shift-periods.w (input parparentproc, input v-cntxt-obj-type, input v-cntxt-obj-code ) .
  end.
end procedure.
procedure m-reason-exe :
  define variable j_reason-code like ub.trn-reason.reason-code no-undo.
  do on error undo, return error return-value :
    run str/trn-reas.w ( input parparentproc, input 'справочник':U, input-output j_reason-code ).
  end.
end procedure.
procedure m-rfin-allord-exe  :
  do
  on error undo, return error return-value
  :
    run cus/ord-rcv.p (parparentproc , 'firm-fin':U,'out':U, 'факт':U ) .
  end.
end procedure.
procedure m-rfin-without-fo-exe   :
  do
  on error undo, return error return-value
  :
    run cus/ord-rcv.p (parparentproc , 'without-fo':U,'out':U, 'факт':U ) .
  end.
end procedure.
procedure m-rfin-with-fo-exe     :
  do
  on error undo, return error return-value
  :
    run cus/ord-rcv.p (parparentproc , 'with-fo':U,'out':U, 'факт':U ) .
  end.
end procedure.
procedure m-fin-allord-exe :
  do
  on error undo, return error return-value
  :
    run cus/ord-pos.p (parparentproc, 'firm-fin':U,"all":U ,'факт':U) .
  end.
end procedure.
procedure m-fin-without-fo-exe  :
  do
  on error undo, return error return-value
  :
    run cus/ord-pos.p (parparentproc, 'without-fo':U,"all":U ,'факт':U) .
  end.
end procedure.
procedure m-fin-with-fo-exe      :
  do
  on error undo, return error return-value
  :
    run cus/ord-pos.p (parparentproc, 'with-fo':U,"all":U ,'факт':U) .
  end.
end procedure.
procedure m_pricing-exe :
  define variable v-current-db-num as integer   no-undo .
  do
  on error undo, return error return-value
  :
define variable vss-include-info84 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output v-current-db-num
  )  .
   run str/pricing.w (parparentproc , v-current-db-num ) .
  end.
end procedure.
procedure m-type-pricelists-exe :
  do
  on error undo, return error return-value
  :
  define variable v-rec-list as character no-undo .
    run ref/typepric.w (parparentproc , "b-add,b-del,b-chg", input-output v-rec-list) .
  end.
end procedure.
procedure m-group-obj-price-exe :
  do
  on error undo, return error return-value
  :
  define variable v-rec-list as character no-undo .
   run ref/gr-objpr.w (parparentproc ,"b-add,b-del,b-chg" , input-output v-rec-list) .
  end.
end procedure.
procedure m-group-buyer-pr-exe :
define variable v-rec-list as character no-undo .
  do
  on error undo, return error return-value
  :
  run ref/gr-bupr.w (parparentproc ,"b-add,b-del,b-chg", input-output v-rec-list ) .
  end.
end procedure.
procedure m-oborot-buyer-pr-exe :
define variable v-rec-list as character no-undo .
  do
  on error undo, return error return-value
  :
  run ref/gr-obupr.w (parparentproc, "b-add,b-del,b-chg", input-output v-rec-list) .
  end.
end procedure.
procedure m-group-summ-pr-exe :
define variable v-rec-list as character no-undo .
  do
  on error undo, return error return-value
  :
  run ref/gr-supr.w (parparentproc ,"b-add,b-del,b-chg", input-output v-rec-list) .
  end.
end procedure.
procedure m-group-qnty-pr-exe :
  do
  on error undo, return error return-value
  :
  define variable v-rec-list as character no-undo .
  run ref/gr-qupr.w (parparentproc,"b-add,b-del,b-chg", input-output v-rec-list) .
  end.
end procedure.
procedure m-utd-exe :
  do
  on error undo, return error return-value
  :
    define variable v-rec-list as character no-undo .
    define variable vconnect as com-handle no-undo.
    run str/UPD.w ( parparentproc, "", 0, ?, input-output vconnect , output v-rec-list) .
    release object vconnect no-error.
  end.
end procedure.
procedure m-mark_collect-exe :
  do
  on error undo, return error return-value
  :
    define variable v-rec-list as character no-undo .
    run str/Mark_Collect-docs.w ( parparentproc, "", output v-rec-list) .
  end.
end procedure.
procedure m-zakaz-exe :
  do
  on error undo, return error return-value
  :
    define variable v-rec-list as character no-undo .
    run str/all-orders.w ( parparentproc, "", output v-rec-list) .
  end.
end procedure.
procedure m-docs-pricelists-exe :
define variable v-ok as logical   no-undo .
  do
  on error undo, return error return-value
  :
  define variable v-rec-list as character no-undo .
define variable vss-include-info85 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_documents_all':U
    ,input  'global':U
    ,input  0
    ,input  ''
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output v-ok
    )  .
end.
    if v-ok then do:
      run str/docsprls.w ( parparentproc , "all" , ? , ? , "b-add,b-del,b-chg" , input-output v-rec-list) .
    end.
  end.
end procedure.
procedure m-docs-pricelists-obj :
  do
  on error undo, return error return-value
  :
  define variable v-rec-list as character no-undo .
  run str/pdfobj.w ( parparentproc , "all" , v-cntxt-obj-type, v-cntxt-obj-code , ? , ? , "b-add,b-del,b-chg" , input-output v-rec-list) .
  end.
end procedure.
procedure m-docs-pricelists-onew :
  do
  on error undo, return error return-value
  :
  define variable v-rec-list as character no-undo .
  run str/pdfnew.w ( parparentproc , "all" , v-cntxt-obj-type, v-cntxt-obj-code , ? , ? , "b-add,b-del,b-chg" , input-output v-rec-list) .
  end.
end procedure.
procedure c-obj-ext-inv-exe :
  do on error undo, return error return-value :
    run dm-c-doc-exe in this-procedure ( input 'УД_ТИП':U,
                                         input ?,
                                         input '?',
                                         input 'инв':U,
                                         input no,
                                         input 'vt':U,
                                         input ? ).
  end.
end procedure.
procedure c-obj-all-ho-exe :
  do on error undo, return error return-value :
    run dm-c-doc-exe in this-procedure ( input 'уд_объект':U,
                                         input ?,
                                         input '?',
                                         input '?',
                                         input ?,
                                         input ?,
                                         input no ).
  end.
end procedure.
procedure c-obj-all-hi-exe :
  do on error undo, return error return-value :
    run dm-c-doc-exe in this-procedure ( input 'уд_объект':U,
                                         input ?,
                                         input '?',
                                         input '?',
                                         input ?,
                                         input ?,
                                         input yes ).
  end.
end procedure.
procedure c-host-all-ho-exe :
  do on error undo, return error return-value :
    run dm-c-doc-exe in this-procedure ( input 'уд_фирма':U,
                                         input ?,
                                         input '?',
                                         input '?',
                                         input ?,
                                         input ?,
                                         input no ).
  end.
end procedure.
procedure c-host-all-hi-exe :
  do on error undo, return error return-value :
    run dm-c-doc-exe in this-procedure ( input 'уд_фирма':U,
                                         input ?,
                                         input '?',
                                         input '?',
                                         input ?,
                                         input ?,
                                         input yes ).
  end.
end procedure.
procedure c-m-all-ho-exe :
  run c-trn-doc-all-exe in this-procedure ( input no ).
end procedure.
procedure c-m-all-hi-exe :
  run c-trn-doc-all-exe in this-procedure ( input yes ).
end procedure.
procedure c-obj-ext-in-hi-exe :
  do on error undo, return error return-value :
    run dm-c-doc-exe in this-procedure ( input 'УД_ТИП':U,
                                         input ?,
                                         input '?',
                                         input 'при':U,
                                         input no,
                                         input 'ie':U,
                                         input yes ).
  end.
end procedure.
procedure c-obj-ext-out-hi-exe :
  do on error undo, return error return-value :
    run dm-c-doc-exe in this-procedure ( input 'УД_ТИП':U,
                                         input ?,
                                         input '?',
                                         input 'рас':U,
                                         input no,
                                         input 'ee':U,
                                         input yes ).
  end.
end procedure.
procedure c-obj-ext-sup-hi-exe :
  do on error undo, return error return-value :
    run dm-c-doc-exe in this-procedure ( input 'УД_ТИП':U,
                                         input ?,
                                         input '?',
                                         input 'рас':U,
                                         input no,
                                         input 'ep':U,
                                         input yes ).
  end.
end procedure.
procedure c-obj-ext-ret-hi-exe :
  do on error undo, return error return-value :
    run dm-c-doc-exe in this-procedure ( input 'УД_ТИП':U,
                                         input ?,
                                         input '?',
                                         input 'возврат':U,
                                         input no,
                                         input 're':U,
                                         input yes ).
  end.
end procedure.
procedure c-trn-doc-all-exe :
  define input parameter p-is-hold as logical no-undo.
  define variable loc-ref-list as character no-undo.
  do on error undo, return error return-value :
    run str/calldocs.w
      (input parparentproc
      ,input 'уд_работа':U
      ,input ?
      ,input ?
      ,input ?
      ,input ?
      ,input "":U
      ,input ?
      ,input p-is-hold
      ,input ?
      ,input v-cntxt-obj-type
      ,input v-cntxt-obj-code
      ,output loc-ref-list
      ).
  end.
end procedure.
procedure chk-group-buyer-price :
  define output parameter p-enable-item as logical   no-undo .
  define buffer buf_global-state for ub.global-state  .
  do
  on error undo, return error return-value
  :
    assign
      p-enable-item = false
    .
    find last buf_global-state no-lock  no-error .
    if error-status :error
    then do:
      return .
    end.
    if buf_global-state.pl-use-grp-buy  = true
    then do:
      assign
        p-enable-item = true
      .
    end.
  end.
end procedure.
procedure chk-oborot-buyer-price :
define output parameter p-enable-item as logical   no-undo .
define buffer buf_global-state for ub.global-state  .
  do
  on error undo, return error return-value
  :
     p-enable-item = false  .
    find last buf_global-state no-lock  no-error .
    if error-status :error then do:
       return .
    end.
    if buf_global-state.pl-use-oborot-buy  = true  then do:
       p-enable-item = true .
    end.
  end.
end procedure.
procedure chk-group-summ-price  :
define output parameter p-enable-item as logical   no-undo .
define buffer buf_global-state for ub.global-state  .
  do
  on error undo, return error return-value
  :
     p-enable-item = false  .
    find last buf_global-state no-lock  no-error .
    if error-status :error then do:
       return .
    end.
    if buf_global-state.pl-use-sum-group  = true  then do:
       p-enable-item = true .
    end.
  end.
end procedure.
procedure chk-group-qnty-price  :
define output parameter p-enable-item as logical   no-undo .
define buffer buf_global-state for ub.global-state  .
  do
  on error undo, return error return-value
  :
     p-enable-item = false  .
    find last buf_global-state no-lock  no-error .
    if error-status :error then do:
       return .
    end.
    if buf_global-state.pl-use-qnty-group  = true  then do:
       p-enable-item = true .
    end.
  end.
end procedure.
procedure chk-ukr-ptrl :
  define output parameter p-enable-item as logical no-undo initial no.
  define variable is_OK      as logical   no-undo.
  do on error undo, return error return-value :
    run chk-is-ptrl in this-procedure ( output is_OK ) no-error.
    if error-status :error or is_OK <> yes then do: undo, return error return-value. end.
    if "RUS":U = "UKR":U  then do: assign p-enable-item = yes. end.
  end.
end procedure.
procedure m__menu-select-context-exe :
  do
  on error undo, return error return-value
  :
    run trigger-select-context in parparentproc
      no-error .
  end.
end procedure.
procedure m__menu-all-exe :
  define buffer buf_menu-group for ub.menu-group .
  do
  on error undo, return error return-value
  :
    find first buf_menu-group no-lock
      where buf_menu-group.menu-code     = p-menu-code
        and buf_menu-group.menu-group-id = 'all':U
      no-error .
    if not available buf_menu-group
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найдена группа пунктов меню" skip
        "Код меню" p-menu-code skip
        "Идентификатор группы пунктов меню" 'all':U skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    run select-menu-group in parparentproc
      (input  buf_menu-group.menu-group-code
      ).
  end.
end procedure.
procedure m__menu-off-exe :
  define buffer buf_menu-group for ub.menu-group .
  do
  on error undo, return error return-value
  :
    find first buf_menu-group no-lock
      where buf_menu-group.menu-code     = p-menu-code
        and buf_menu-group.menu-group-id = 'off':U
      no-error .
    if not available buf_menu-group
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найдена группа пунктов меню" skip
        "Код меню" p-menu-code skip
        "Идентификатор группы пунктов меню" 'off':U skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    run select-menu-group in parparentproc
      (input  buf_menu-group.menu-group-code
      ).
  end.
end procedure.
procedure m__menu-mmr-exe :
  define buffer buf_menu-group for ub.menu-group .
  do
  on error undo, return error return-value
  :
    find first buf_menu-group no-lock
      where buf_menu-group.menu-code     = p-menu-code
        and buf_menu-group.menu-group-id = 'mmr':U
      no-error .
    if not available buf_menu-group
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найдена группа пунктов меню" skip
        "Код меню" p-menu-code skip
        "Идентификатор группы пунктов меню" 'mmr':U skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    run select-menu-group in parparentproc
      (input  buf_menu-group.menu-group-code
      ).
  end.
end procedure.
procedure m__menu-str-exe :
  define buffer buf_menu-group for ub.menu-group .
  do
  on error undo, return error return-value
  :
    find first buf_menu-group no-lock
      where buf_menu-group.menu-code     = p-menu-code
        and buf_menu-group.menu-group-id = 'str':U
      no-error .
    if not available buf_menu-group
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найдена группа пунктов меню" skip
        "Код меню" p-menu-code skip
        "Идентификатор группы пунктов меню" 'str':U skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    run select-menu-group in parparentproc
      (input  buf_menu-group.menu-group-code
      ).
  end.
end procedure.
procedure m__menu-shp-exe :
  define buffer buf_menu-group for ub.menu-group .
  do
  on error undo, return error return-value
  :
    find first buf_menu-group no-lock
      where buf_menu-group.menu-code     = p-menu-code
        and buf_menu-group.menu-group-id = 'shp':U
      no-error .
    if not available buf_menu-group
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найдена группа пунктов меню" skip
        "Код меню" p-menu-code skip
        "Идентификатор группы пунктов меню" 'shp':U skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    run select-menu-group in parparentproc
      (input  buf_menu-group.menu-group-code
      ).
  end.
end procedure.
procedure m__menu-res-exe :
  define buffer buf_menu-group for ub.menu-group .
  do
  on error undo, return error return-value
  :
    find first buf_menu-group no-lock
      where buf_menu-group.menu-code     = p-menu-code
        and buf_menu-group.menu-group-id = 'res':U
      no-error .
    if not available buf_menu-group
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найдена группа пунктов меню" skip
        "Код меню" p-menu-code skip
        "Идентификатор группы пунктов меню" 'res':U skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    run select-menu-group in parparentproc
      (input  buf_menu-group.menu-group-code
      ).
  end.
end procedure.
procedure m__menu-fin-exe :
  define buffer buf_menu-group for ub.menu-group .
  do
  on error undo, return error return-value
  :
    find first buf_menu-group no-lock
      where buf_menu-group.menu-code     = p-menu-code
        and buf_menu-group.menu-group-id = 'fin':U
      no-error .
    if not available buf_menu-group
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найдена группа пунктов меню" skip
        "Код меню" p-menu-code skip
        "Идентификатор группы пунктов меню" 'fin':U skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    run select-menu-group in parparentproc
      (input  buf_menu-group.menu-group-code
      ).
  end.
end procedure.
procedure m__menu-bge-exe :
  define buffer buf_menu-group for ub.menu-group .
  do
  on error undo, return error return-value
  :
    find first buf_menu-group no-lock
      where buf_menu-group.menu-code     = p-menu-code
        and buf_menu-group.menu-group-id = 'bge':U
      no-error .
    if not available buf_menu-group
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найдена группа пунктов меню" skip
        "Код меню" p-menu-code skip
        "Идентификатор группы пунктов меню" 'bge':U skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    run select-menu-group in parparentproc
      (input  buf_menu-group.menu-group-code
      ).
  end.
end procedure.
procedure m__menu-buh-exe :
  define buffer buf_menu-group for ub.menu-group .
  do
  on error undo, return error return-value
  :
    find first buf_menu-group no-lock
      where buf_menu-group.menu-code     = p-menu-code
        and buf_menu-group.menu-group-id = 'buh':U
      no-error .
    if not available buf_menu-group
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найдена группа пунктов меню" skip
        "Код меню" p-menu-code skip
        "Идентификатор группы пунктов меню" 'buh':U skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    run select-menu-group in parparentproc
      (input  buf_menu-group.menu-group-code
      ).
  end.
end procedure.
procedure m__menu-fas-exe :
  define buffer buf_menu-group for ub.menu-group .
  do
  on error undo, return error return-value
  :
    find first buf_menu-group no-lock
      where buf_menu-group.menu-code     = p-menu-code
        and buf_menu-group.menu-group-id = 'fas':U
      no-error .
    if not available buf_menu-group
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найдена группа пунктов меню" skip
        "Код меню" p-menu-code skip
        "Идентификатор группы пунктов меню" 'fas':U skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    run select-menu-group in parparentproc
      (input  buf_menu-group.menu-group-code
      ).
  end.
end procedure.
PROCEDURE journal-vsd :
     DEFINE VARIABLE v-vsd-dialog AS  CLASS  ibs.th.ref.journal_vsd_abl  .
     v-vsd-dialog = NEW ibs.th.ref.journal_vsd_abl (  parparentproc  ) .
     v-vsd-dialog:ShowModalDialog().
     finally:
         DELETE  OBJECT v-vsd-dialog no-error.
     end finally.
END PROCEDURE.
procedure m__menu-adm-exe :
  define buffer buf_menu-group for ub.menu-group .
  do
  on error undo, return error return-value
  :
    find first buf_menu-group no-lock
      where buf_menu-group.menu-code     = p-menu-code
        and buf_menu-group.menu-group-id = 'adm':U
      no-error .
    if not available buf_menu-group
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найдена группа пунктов меню" skip
        "Код меню" p-menu-code skip
        "Идентификатор группы пунктов меню" 'adm':U skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    run select-menu-group in parparentproc
      (input  buf_menu-group.menu-group-code
      ).
  end.
end procedure.
procedure m__menu-bck-exe :
  do
  on error undo, return error return-value
  :
    run select-previous-menu-group-id in parparentproc .
  end.
end procedure.
procedure m__fo-dels-exe :
define variable varrid-list as character no-undo .
  do
  on error undo, return error return-value
  :
  run str/fin-dels.w
  (input parParentProc,
   input 'b-lkp',
   input 'фирма':U,
   input ?,
   input v-cntxt-host-code-obj,
   input ?,
   input ?,
   input '',
   output varrid-list ).
  end.
end procedure.
procedure m-all-or-new-exe  :
  do on error undo, return error return-value :
    run cus/ord-pos.p (parparentproc,'obj':U,'ОР':U,'новый':U) .
  end.
end procedure.
procedure m-all-or-req-exe  :
  do on error undo, return error return-value :
     run cus/ord-pos.p (parparentproc,'obj':U,'ОР':U,'запрос':U) .
  end.
end procedure.
procedure m-all-or-per-exe  :
  do on error undo, return error return-value :
    run cus/ord-pos.p (parparentproc,'obj':U,'ОР':U,'разрешено':U) .
  end.
end procedure.
procedure m-all-or-rej-exe  :
  do on error undo, return error return-value :
    run cus/ord-pos.p (parparentproc,'obj':U,'ОР':U,'отказ':U) .
  end.
end procedure.
procedure m-all-or-ship-exe :
  do on error undo, return error return-value :
    run cus/ord-pos.p (parparentproc,'obj':U,'ОР':U,'отгружено':U).
  end.
end procedure.
procedure m-all-or-fact-exe :
  do on error undo, return error return-value :
     run cus/ord-pos.p (parparentproc,'obj':U,'ОР':U,'факт':U)    .
  end.
end procedure.
procedure m-all-or-all-exe  :
  do on error undo, return error return-value :
     run cus/ord-pos.p (parparentproc,'obj':U,'ОР':U,'all':U)    .
  end.
end procedure.
procedure m-all-rc-req-exe  :
  do on error undo, return error return-value :
     run cus/ord-pos.p (parparentproc,'rc':U,'ОР':U,'запрос':U)  .
  end.
end procedure.
procedure m-all-rc-per-exe  :
  do on error undo, return error return-value :
    run cus/ord-pos.p (parparentproc,'rc':U,'ОР':U,'разрешено':U)  .
  end.
end procedure.
procedure m-all-rc-rej-exe  :
  do on error undo, return error return-value :
    run cus/ord-pos.p (parparentproc,'rc':U,'ОР':U,'отказ':U)  .
  end.
end procedure.
procedure m-all-rc-ship-exe :
  do on error undo, return error return-value :
    run cus/ord-pos.p (parparentproc,'rc':U,'ОР':U,'отгружено':U) .
  end.
end procedure.
procedure m-all-rc-fact-exe :
  do on error undo, return error return-value :
    run cus/ord-pos.p (parparentproc,'rc':U,'ОР':U,'факт':U)     .
  end.
end procedure.
procedure m-all-rc-all-exe  :
  do on error undo, return error return-value :
    run cus/ord-pos.p (parparentproc,'rc':U,'ОР':U,'all':U)     .
  end.
end procedure.
procedure m-po-new-exe  :
  do on error undo, return error return-value :
     run cus/ord-buy.p (parparentproc,'ПО':U,'новый':U)  .
  end.
end procedure.
procedure m-po-reject-exe  :
  do on error undo, return error return-value :
     run cus/ord-buy.p (parparentproc,'ПО':U,'отказ':U)  .
  end.
end procedure.
procedure m-po-rcv-exe  :
  do on error undo, return error return-value :
     run cus/ord-buy.p (parparentproc,'ПО':U,'поставка':U)  .
  end.
end procedure.
procedure m-po-fact-exe :
  do on error undo, return error return-value :
     run cus/ord-buy.p (parparentproc,'ПО':U,'факт':U)  .
  end.
end procedure.
procedure m-po-all-exe :
  do on error undo, return error return-value :
     run cus/ord-buy.p (parparentproc,'ПО':U,'all':U )  .
  end.
end procedure.
procedure m_util-upgrade-exe :
define variable ri-list as character no-undo .
  do
  on error undo, return error
  :
    run adm/ipckwork.w ( input parparentproc, input 1, input ?, input ?, input '':U, input '', input-output ri-list).
  end.
end procedure.
procedure m_util-filework-exe :
define variable ri-list as character no-undo .
  do
  on error undo, return error
  :
    run adm/ipckwork.w ( input parparentproc, input 0, input ?, input ?, input '':U, input '', input-output ri-list).
  end.
end procedure.
procedure m_util-xibmfilework-exe :
define variable ri-list as character no-undo .
  do
  on error undo, return error
  :
    run adm/ipckxibm.w ( input parparentproc
                       , input-output ri-list).
  end.
end procedure.
procedure m_util-transfer-exe :
define variable ri-list as character no-undo .
  do
  on error undo, return error
  :
    run nws/sndfnws.w ( input parparentproc, input '':U, input ?, input ?, input '':U).
  end.
end procedure.
procedure c-obj-pst-exe :
  do
  on error undo, return error return-value
  :
  run dm-c-doc-exe in this-procedure (INPUT 'УД_ТИП':U, INPUT ?, INPUT '?', INPUT 'инв':U, INPUT no,  INPUT 'vp':U, INPUT ? ).
  end.
end procedure.
procedure c-obj-inv-exe :
  do
  on error undo, return error return-value
  :
  run dm-c-doc-exe in this-procedure (INPUT 'УД_ТИП':U, INPUT ?, INPUT '?', INPUT 'инв':U, INPUT no,  INPUT 'vt':U, INPUT ? ).
  end.
end procedure.
PROCEDURE image-procedure-in-ov :
  do
  on error undo, return error return-value
  :
    message
      "Переоценка после прихода. Функция вызывается через меню."
      view-as alert-box.
  end.
END PROCEDURE.
PROCEDURE image-procedure-cd :
  do
  on error undo, return error return-value
  :
    run str/cd-inf.p
      (input parparentproc
      ,input no
      ,input yes
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры" 'str/cd-inf.p':U skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
    end.
    run image-display-cd in parparentproc .
  end.
END PROCEDURE.
PROCEDURE image-procedure-scales :
  do
  on error undo, return error return-value
  :
    run str/diallog.w
      ( input parparentproc
      , input this-procedure
      , input "ref/sendscal.p":U
      , input (v-cntxt-obj-type + chr(4) + string(v-cntxt-obj-code) + chr(4) + chr(63) + chr(4) +
               "changed":U + chr(4) + '':U + chr(4) + "current":U + chr(4) +
               string(0))
      , input no
      , input "":U
      , input substitute("Отсылка изменений на весы")
      ) no-error.
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры" 'ref/sendscal.p':U skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
    end.
    run image-display-scales in parparentproc .
  end.
END PROCEDURE.
PROCEDURE image-procedure-curses :
  do
  on error undo, return error return-value
  :
    run str/diallog.w
      ( input parparentproc
      , input this-procedure
      , input "str/send-cur.p":U
      , input (v-cntxt-obj-type + chr(4) + string(v-cntxt-obj-code) + chr(4) + "U")
      , input no
      , input "":U
      , input substitute("Отсылка данных по курсам валют на кассы")
      ) no-error.
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры" 'str/send-cur.p':U skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
    end.
    run image-display-curses in parparentproc .
  end.
END PROCEDURE.
PROCEDURE image-procedure-ck-gds :
  do
  on error undo, return error return-value
  :
  end.
END PROCEDURE.
PROCEDURE image-procedure-fls-ck :
  do
  on error undo, return error return-value
  :
    run m-chk-free-exe in this-procedure  .
    run image-display-sales in parparentproc.
  end.
END PROCEDURE.
PROCEDURE image-procedure-gds-sl :
  do
  on error undo, return error return-value
  :
    run m-chk-sale-exe in this-procedure .
    run image-display-sales in parparentproc.
  end.
END PROCEDURE.
PROCEDURE image-procedure-ord-do :
  do
  on error undo, return error return-value
  :
  define variable v-kol-ord as integer no-undo .
    run cus/ord-cyc.p
      (input v-cntxt-obj-type ,
       input v-cntxt-obj-code ,
       input this-procedure ,
       output v-kol-ord
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры" 'cus/ord-cyc.p':U skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
    end.
    run image-display-ord-do in parparentproc .
  end.
END PROCEDURE.
PROCEDURE image-procedure-ck-wth :
  do
  on error undo, return error return-value
  :
  end.
END PROCEDURE.
PROCEDURE image-procedure-awth :
  do
  on error undo, return error return-value
  :
    run m-chk-wth-r-exe in this-procedure .
  end.
END PROCEDURE.
PROCEDURE image-procedure-nwsc :
  do
  on error undo, return error return-value
  :
define variable v-rid-list as character no-undo .
 run gbl/nwscolls.w (
                   input parparentproc
                  ,input '':U
                  ,input 'все':U
                  ,input - 1
                  ,input '':U
                  ,input '':U
                  ,input-output v-rid-list
                  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры" 'gbl/nwscolls.w':U skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
    end.
  run image-display-nwsc in parparentproc .
  end.
END PROCEDURE.
PROCEDURE image-procedure-priper :
  do
  on error undo, return error return-value
  :
    define variable loc-ref-list as character no-undo .
    run str/all-docs.w
      (input  parparentproc
      ,input  v-cntxt-host-code-obj
      ,input  v-cntxt-obj-type
      ,input  v-cntxt-obj-code
      ,input  'ФЛАГ':U
      ,input  'накл':U
      ,input  'при':U
      ,input  yes
      ,input  yes
      ,input  "b-close"
      ,input  'iv':U
      ,input  no
      ,input  ?
      ,output loc-ref-list
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры" 'str/all-docs.w':U skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
    end.
    run image-display-priper in parparentproc .
    run image-display-ovrorc in parparentproc .
    run image-display-qntorc in parparentproc .
  end.
END PROCEDURE.
PROCEDURE image-procedure-vozper :
  do
  on error undo, return error return-value
  :
    define variable loc-ref-list as character no-undo .
    run str/all-docs.w
      (input  parparentproc
      ,input  v-cntxt-host-code-obj
      ,input  v-cntxt-obj-type
      ,input  v-cntxt-obj-code
      ,input  'ТИП':U
      ,input  ?
      ,input  'возврат':U
      ,input  yes
      ,input  yes
      ,input  ""
      ,input  'rv':U
      ,input  no
      ,input  ?
      ,output loc-ref-list
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры" 'str/all-docs.w':U skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
    end.
  run image-display-vozper in parparentproc .
  end.
END PROCEDURE.
PROCEDURE image-procedure-ovrval :
  do
  on error undo, return error return-value
  :
    define variable loc-ref-list as character no-undo .
    run str/pr-docs.w
      (input  parparentproc
      ,input  "b-mark"
      ,input  'статус':U
      ,input  'приказ':U
      ,input  v-cntxt-obj-type
      ,input  v-cntxt-obj-code
      ,input  ""
      ,output loc-ref-list
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры" 'str/pr-docs.w':U skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
    end.
    run image-display-ovrval in parparentproc .
  end.
END PROCEDURE.
PROCEDURE image-procedure-ovrorc :
  do
  on error undo, return error return-value
  :
    define variable loc-ref-list as character no-undo .
    run str/pr-docs.w
      (input  parparentproc
      ,input  "b-mark"
      ,input  'статус':U
      ,input  'акт':U
      ,input  v-cntxt-obj-type
      ,input  v-cntxt-obj-code
      ,input  ""
      ,output loc-ref-list
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры" 'str/pr-docs.w':U skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
    end.
    run image-display-ovrorc in parparentproc .
  end.
END PROCEDURE.
PROCEDURE image-procedure-qntorc :
  do
  on error undo, return error return-value
  :
    message "Необходимое количество товара по запросу ИМЕЕТСЯ !" view-as alert-box information .
    run image-display-qntorc in parparentproc .
  end.
END PROCEDURE.
PROCEDURE image-procedure-ass-min :
  do
  on error undo, return error return-value
  :
    run ref/gds-amin.w ( parparentproc , v-cntxt-obj-type, v-cntxt-obj-code, "min") no-error .
    run image-display-as-min in parparentproc .
  end.
END PROCEDURE.
PROCEDURE image-procedure-twotpl :
  do
  on error undo, return error return-value
  :
define variable v-rec-list as character no-undo .
define variable l-exist-twotpl as logical   no-undo .
define variable v-str as character no-undo .
define buffer buf1_price-list-type for ub.price-list-type  .
define buffer buf2_price-list-type for ub.price-list-type  .
define buffer buf_BatchProcess  for ub.BatchProcess  .
define buffer exec_batchprocess for ub.BatchProcess  .
   find first buf_BatchProcess no-lock
        where buf_BatchProcess.bp_type       = 'twotpl':U
          and buf_BatchProcess.bp_status     = 'N':U
              no-error   .
    if available buf_BatchProcess
    then do:
         find first buf1_price-list-type no-lock where
              recid(buf1_price-list-type) = int(buf_BatchProcess.CharKey_One) no-error .
         find first buf2_price-list-type no-lock where
              recid(buf2_price-list-type) = int(buf_BatchProcess.CharKey_Two) no-error .
        if available buf2_price-list-type and available buf1_price-list-type then
           v-str = substitute("ТПЛ &1(&2) &3  и  ТПЛ &4(&5) &6 с приоритетом &7" ,
                    buf1_price-list-type.plt-id ,
                    buf1_price-list-type.plt-db-num,
                    buf1_price-list-type.name ,
                    buf2_price-list-type.plt-id ,
                    buf2_price-list-type.plt-db-num,
                    buf2_price-list-type.name ,
                    buf2_price-list-type.priority ) .
           else v-str = "" .
        v-rec-list = buf_BatchProcess.CharKey_One + ',' + buf_BatchProcess.CharKey_Two .
        run ref/typepric.w (parparentproc , "b-add,b-del,b-chg,mode=twotpl" , input-output v-rec-list ) no-error .
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при вызове процедуры" 'ref/typepric.w':U skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
        end.
      message
        "Сообщать о двойниках в дальнейшем " skip
         v-str
         '?'
        view-as alert-box question
        buttons yes-no
        update v-ok as log
        .
        if v-ok = false then do:
  find first exec_batchprocess exclusive-lock
    where rowid(exec_batchprocess) = rowid(buf_batchprocess)
    no-error .
  if not available exec_batchprocess then do:
    message
      vss-workfile vss-revision vss-description skip
      "Не найдена запись пересчета архива" skip
      view-as alert-box error .
    undo, return error .
  end.
  if exec_batchprocess.bp_status <> 'N':U then do:
    message
      vss-workfile vss-revision vss-description skip
      "Запись пересчета архива имеет статус, отличный от" 'N':U skip
      "BP_Type"       exec_batchprocess.BP_Type       skip
      "BP_Status"     exec_batchprocess.BP_Status     skip
      "Key#_One"      exec_batchprocess.Key#_One      skip
      "Key#_Two"      exec_batchprocess.Key#_Two      skip
      "Key#_Three"    exec_batchprocess.Key#_Three    skip
      "CharKey_One"   exec_batchprocess.CharKey_One   skip
      "CharKey_Two"   exec_batchprocess.CharKey_Two   skip
      "CharKey_Three" exec_batchprocess.CharKey_Three skip
      view-as alert-box error .
    undo, return error .
  end.
    define variable v-btpr_upd-today-86 as date      no-undo.
  define variable v-btpr_upd-time-86  as integer   no-undo.
  run cur-time in this-procedure ( output v-btpr_upd-today-86
                                 , output v-btpr_upd-time-86
                                 ).
  assign
    exec_batchprocess.bp_status         = 'D':U
    exec_batchprocess.bp_execcounttries = exec_batchprocess.bp_execcounttries + 1
    exec_batchprocess.bp_execuser_id    = v-cntxt-userid
    exec_batchprocess.bp_execsysdate    = v-btpr_upd-today-86
    exec_batchprocess.bp_execsystime    = string(v-btpr_upd-time-86, 'hh:mm')
    exec_batchprocess.bp_execsystimeint = v-btpr_upd-time-86
  .
      end.
    end.
    else do:
         message 'НОВЫЕ Двойники по приоритету в ТПЛ не обнаружены !' view-as alert-box information .
    end.
  run image-display-twotpl in parparentproc .
  end.
END PROCEDURE.
procedure chk-is-adoc-nn :
  define output parameter p-enable-item as logical   no-undo .
  define variable v-edoc-nn as character no-undo .
  define variable par-type as character no-undo .
  do
  on error undo, return error return-value
  :
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'edoc-nn':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  no
  ,output v-edoc-nn
  ,output par-type
  ) no-error .
    if error-status :error
    then do:
        assign
          p-enable-item = false
        .
      return .
    end.
    if v-edoc-nn = 'yes':u
    then do:
      assign
        p-enable-item = true
      .
    end.
    else do:
        assign
          p-enable-item = false
        .
    end.
  end.
end procedure.
procedure m_clients-edoc-exe :
define variable v-rid-list as character no-undo .
  do
  on error undo, return error
  :
    run cus/edoc-cli.w ( input parparentproc
                        ,input (if v-cntxt-db-num > 0 then '':U else "b-add")
                        ,input 'все':U
                        ,input '':U
                        ,input-output v-rid-list) no-error.
  end.
end procedure.
procedure m_clients-enum-exe :
define variable v-rid-list as character no-undo .
  do
  on error undo, return error
  :
    run cus/enum-cli.w ( input parparentproc
                        ,input (if v-cntxt-db-num > 0 then '':U else "b-add")
                        ,input 'все':U
                        ,input '':U
                        ,input-output v-rid-list) no-error.
  end.
end procedure.
procedure m_clients-contr-exe :
define variable v-rid-list as character no-undo .
  do
  on error undo, return error
  :
    run cus/eorg-cli.w ( input parparentproc
                        ,input (if v-cntxt-db-num > 0 then '':U else "b-add")
                        ,input 'все':U
                        ,input '':U
                        ,input-output v-rid-list) no-error.
  end.
end procedure.
procedure m_clients-diadok-exe :
define variable v-rid-list as character no-undo .
  do
  on error undo, return error
  :
    run cus/diadok-cli.w ( input parparentproc
                        ,input (if v-cntxt-db-num > 0 then '':U else "b-add")
                        ,input 'все':U
                        ,input '':U
                        ,input-output v-rid-list) no-error.
  end.
end procedure.
procedure m_clients-gln-exe :
define variable v-rid-list as character no-undo .
  do
  on error undo, return error
  :
    run ref/gln-clis.w ( input parparentproc
                        ,input (if v-cntxt-db-num > 0 then '':U else "b-add")
                        ,input '':U
                        ,input-output v-rid-list) no-error.
  end.
end procedure.
procedure m_clients-exite-exe :
define variable v-rid-list as character no-undo .
  do
  on error undo, return error
  :
    run cus/exiteedi.w ( input parparentproc
                        ,input (if v-cntxt-db-num > 0 then '':U else "b-add")
                        ,input 'все':U
                        ,input ''
                        ,input-output v-rid-list) no-error.
  end.
end procedure.
procedure m_layouts_screen_exe :
run m_layouts_exe in this-procedure ( input 'th-pos-screen':U).
end procedure.
procedure m_layouts_keyboard_exe :
run m_layouts_exe in this-procedure ( input 'th-pos-keyboard':U).
end procedure.
procedure m_layouts_exe :
define input parameter p-layout-type as character no-undo .
define variable v-rid-list as character no-undo .
  do
  on error undo, return error
  :
    run adm/layoutss.w ( input parparentproc
                        ,input "b-add"
                        ,input "layout-type"
                        ,input p-layout-type
                        ,input-output v-rid-list ) no-error.
  end.
END PROCEDURE.
procedure m_tsheets-all-exe:
    run str/travel-sheets.w(parparentproc).
end.
PROCEDURE image-procedure-srgdn :
define variable v-ok as logical   no-undo .
  do
  on error undo, return error return-value
  :
    define variable v-tth     as handle no-undo .
    run str/defctpar.w ( parparentproc , this-procedure, v-cntxt-obj-type, v-cntxt-obj-code, "srok" , 0, output TABLE-HANDLE v-tth) no-error .
    run image-display-srgdn in parparentproc .
  end.
END PROCEDURE.
PROCEDURE image-procedure-defec :
define variable v-ok as logical   no-undo .
  do
  on error undo, return error return-value
  :
    define variable v-tth     as handle no-undo .
    run str/defctpar.w ( parparentproc , this-procedure, v-cntxt-obj-type, v-cntxt-obj-code, "defect" , 0 , output TABLE-HANDLE v-tth ) no-error .
    run image-display-defec in parparentproc .
  end.
END PROCEDURE.
PROCEDURE image-procedure-srgdn1 :
define variable v-ok as logical   no-undo .
  do
  on error undo, return error return-value
  :
    define variable v-tth     as handle no-undo .
    run str/defctpar.w ( parparentproc , this-procedure, v-cntxt-obj-type, v-cntxt-obj-code, "srok" , 1, output TABLE-HANDLE v-tth) no-error .
    run image-display-srgdn in parparentproc .
  end.
END PROCEDURE.
PROCEDURE image-procedure-defec1 :
define variable v-ok as logical   no-undo .
  do
  on error undo, return error return-value
  :
    define variable v-tth     as handle no-undo .
    run str/defctpar.w ( parparentproc , this-procedure, v-cntxt-obj-type, v-cntxt-obj-code, "defect" , 1 , output TABLE-HANDLE v-tth ) no-error .
    run image-display-defec in parparentproc .
  end.
END PROCEDURE.
procedure chk-is-pharm :
  define output parameter p-enable-item as logical   no-undo .
  define variable v-is-pharm  as character no-undo .
  define variable par-type   as character no-undo .
  do
  on error undo, return error return-value
  :
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-pharm'
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  no
  ,output v-is-pharm
  ,output par-type
  ) no-error .
    if lookup( v-is-pharm, "yes,no" ) = 0
    or v-is-pharm = ?
    or par-type <> 'L':U
    or error-status :error
    then do:
      assign
        v-is-pharm = "no"
      .
    end.
    if v-is-pharm = 'no':u
    then do:
      assign
        p-enable-item = false
      .
    end.
    else do:
      assign
        p-enable-item = true
      .
    end.
  end.
end procedure.
PROCEDURE image-procedure-pharm :
END PROCEDURE.
PROCEDURE image-procedure-petrol :
END PROCEDURE.
PROCEDURE image-procedure-pr-fin :
  do
  on error undo, return error return-value:
     run str/fi-liab1.p (input parparentproc , input 14 , v-cntxt-host-code-obj) .
  end.
END PROCEDURE.
procedure promosend :
define input parameter p-pos-type as character no-undo .
define input parameter p-action as character no-undo .
 run str/diallog.w (
        input parparentproc
      , input this-procedure
      , input "str/promosend.p":U
      , input (p-pos-type + chr(4) + v-cntxt-obj-type + chr(4) + string(v-cntxt-obj-code) + chr(4) + p-action + chr(4) + "")
      , input no
      , input "":U
      , input substitute("Отсылка промоакций на кассы &1", p-pos-type, 'IBM-XML':U)
  ) no-error.
end procedure.
