block-level on error undo, throw.
define input parameter par-calc-method like ub.gds-grp.calc-method no-undo .
define input parameter par-increase-pc like ub.gds-grp.increase-pc no-undo .
define input parameter par-min like ub.gds-grp.increase-pc no-undo .
define input parameter par-max like ub.gds-grp.increase-pc no-undo .
define input parameter par-round-method as character no-undo .
define input parameter par-base as decimal no-undo .
define input parameter par-cli-type as character no-undo .
define input parameter par-cli-code as integer no-undo .
define input parameter par-fill-method as character no-undo .
define input parameter par-groups as character no-undo .
define input parameter par-values as character no-undo .
define input parameter par-fields as integer no-undo .
define input parameter par-region as integer no-undo .
define input parameter par-rid-list as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: ini-grpc.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/ini-grpc.p $":U .
define variable vss-description as character no-undo init "Инициализация поля СПОСОБ РАСЧЕТА в gds-grp".
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION CIntBinS RETURNS CHARACTER(input vl_int as integer):
def var vl_bin as char no-undo init "".
if vl_int < 0 OR vl_int = ? then return ?.
do while vl_int > 0:
  assign
  vl_bin = (if vl_int modulo 2 = 0
              then "0":U
              else "1":U) + vl_bin
  vl_int = truncate(vl_int / 2,0).
end.
return fill( "0":U, 32 - length(vl_bin)) + vl_bin .
END FUNCTION.
FUNCTION BinMask RETURNS LOGICAL(input vl_int as integer,
                                 input vl_binm as character):
DEFINE VARIABLE vl_bin as character no-undo.
DEFINE VARIABLE ii as integer no-undo.
DEFINE VARIABLE ii-len as integer no-undo.
DEFINE VARIABLE ii-lenm as integer no-undo.
DEFINE VARIABLE mchar as character no-undo.
DEFINE VARIABLE ichar as character no-undo.
if vl_binm = ? then return ?.
vl_bin = CIntBinS(vl_int).
if vl_bin = ? then return ?.
assign
vl_binm = LEFT-TRIM(vl_binm, "X":U)
ii-lenm = LENGTH(vl_binm)
ii-len = LENGTH(vl_bin) - ii-lenm
.
if II-LENM > 32 THEN RETURN ?.
DO II = 1 to II-LENm:
  assign
  mchar = SUBSTR(vl_binm, ii, 1)
  ichar = SUBSTR(vl_bin, ii + ii-len, 1)
  .
  IF not (MCHAR = "0":u or MCHAR = "1":u or MCHAR = "X":u) then return ?.
  IF ichar <> mchar AND mchar <> "X":U then return no.
END.
return yes.
END FUNCTION.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure grp-obj-write :
do
on error undo, return error
:
define input parameter p-node-code  like ub.gds-grp-obj.node-code      no-undo.
define input parameter p-host-code  as integer                          no-undo.
define input parameter p-obj-type   like ub.clients.obj-type            no-undo.
define input parameter p-obj-code   like ub.clients.obj-code            no-undo.
define input parameter p-min-increase like ub.gds-grp-obj.min-increase  no-undo.
define input parameter p-max-increase like ub.gds-grp-obj.max-increase  no-undo.
define input parameter p-increase-pc like ub.gds-grp-obj.increase-pc  no-undo.
define input parameter p-calc-method like ub.gds-grp-obj.calc-method no-undo .
define input parameter p-round-method like ub.gds-grp-obj.round-method no-undo .
define input parameter p-round-coef like ub.gds-grp-obj.round-coef no-undo .
define input parameter p-cli-type   like ub.clients.obj-type            no-undo.
define input parameter p-cli-code   like ub.clients.obj-code            no-undo.
define buffer buf_gds-grp-obj for ub.gds-grp-obj.
    find first buf_gds-grp-obj exclusive-lock
         where buf_gds-grp-obj.node-code  = p-node-code
           and buf_gds-grp-obj.host-code  = p-host-code
           and buf_gds-grp-obj.obj-type   = p-obj-type
           and buf_gds-grp-obj.obj-code   = p-obj-code
    no-error.
    if not available buf_gds-grp-obj
    then do:
        create buf_gds-grp-obj.
        assign
                buf_gds-grp-obj.node-code  = p-node-code
                buf_gds-grp-obj.host-code  = p-host-code
                buf_gds-grp-obj.obj-type   = p-obj-type
                buf_gds-grp-obj.obj-code   = p-obj-code
        .
    end.
    assign
    buf_gds-grp-obj.min-increase = p-min-increase
    buf_gds-grp-obj.max-increase = p-max-increase
    buf_gds-grp-obj.increase-pc = p-increase-pc
    buf_gds-grp-obj.calc-method = p-calc-method
    buf_gds-grp-obj.round-method = p-round-method
    buf_gds-grp-obj.round-coef = p-round-coef
    buf_gds-grp-obj.cli-type   = p-cli-type
    buf_gds-grp-obj.cli-code   = p-cli-code
    .
end.
end procedure.
procedure grp-obj-margin-value :
do
on error undo, return error
:
define input parameter p-node-code as integer      no-undo.
define input parameter p-obj-type  as character    no-undo.
define input parameter p-obj-code  as integer      no-undo.
define output parameter p-min-value as decimal      no-undo init ?.
define output parameter p-max-value as decimal      no-undo init ?.
define output parameter p-increase-pc as decimal      no-undo init ?.
define output parameter p-round-method as character no-undo init "":U.
define output parameter p-base as decimal no-undo init ?.
define output parameter p-range-margin     as integer      no-undo.
define output parameter p-exists-margin    as logical      no-undo.
define output parameter p-range-increase     as integer      no-undo.
define output parameter p-exists-increase    as logical      no-undo.
define output parameter p-range-rmethod     as integer no-undo .
define output parameter p-exists-rmethod    as logical no-undo .
define variable v-host-code as integer      no-undo.
DEFINE VARIABLE v-found as logical no-undo .
DEFINE VARIABLE v-exists as logical no-undo .
DEFINE VARIABLE v-range as integer no-undo .
DEFINE VARIABLE jj as integer no-undo .
DEFINE VARIABLE v-margin-found as logical no-undo .
DEFINE VARIABLE v-increase-found as logical no-undo .
DEFINE VARIABLE v-min-value as decimal      no-undo.
DEFINE VARIABLE v-max-value as decimal      no-undo.
DEFINE VARIABLE v-increase-pc as decimal      no-undo.
define variable v-round-method as character no-undo .
define variable v-base as decimal no-undo .
define variable v-print-code as character no-undo .
define buffer buf_gds-grp for ub.gds-grp.
find first buf_gds-grp no-lock where
           buf_gds-grp.node-code = p-node-code no-error .
if not avail buf_gds-grp and p-node-code <> 0 then do:
  message
    vss-workfile vss-revision vss-description
    skip "Не удалось найти группу товаров с кодом" p-node-code
    view-as alert-box error .
  undo, return error .
end.
if p-obj-type <> '' then do:
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  ) no-error .
  if error-status :error
  then do:
      message
        vss-workfile vss-revision vss-description
        skip "Не удалось найти фирму объекта"
        skip p-obj-type p-obj-code
        skip return-value
        skip trim(error-status :get-message(1))
            trim(error-status :get-message(2))
            trim(error-status :get-message(3))
            trim(error-status :get-message(4))
            trim(error-status :get-message(5))
      view-as alert-box error.
      undo, return error .
  end.
end.
define buffer buf_gds-grp-obj      for ub.gds-grp-obj.
do while v-found = no and jj < 2:
  if v-range <> 3 then do:
    find first buf_gds-grp-obj no-lock
        where buf_gds-grp-obj.node-code = p-node-code
          and buf_gds-grp-obj.host-code = v-host-code
          and buf_gds-grp-obj.obj-type  = p-obj-type
          and buf_gds-grp-obj.obj-code  = p-obj-code
    no-error .
  end.
  if v-range = 3 or not available buf_gds-grp-obj
  then do:
     if v-range <> 2 then do:
        find first buf_gds-grp-obj no-lock
            where buf_gds-grp-obj.node-code = p-node-code
              and buf_gds-grp-obj.host-code = v-host-code
              and buf_gds-grp-obj.obj-type  = ""
              and buf_gds-grp-obj.obj-code  = 0
        no-error .
      end.
      if v-range = 2 or not available buf_gds-grp-obj
      then do:
          if v-range <> 1 then do:
            find first buf_gds-grp-obj no-lock
                where buf_gds-grp-obj.node-code = p-node-code
                and buf_gds-grp-obj.host-code = 0
                and buf_gds-grp-obj.obj-type  = ""
                and buf_gds-grp-obj.obj-code  = 0
            no-error .
          end.
          if v-range = 1 or not available buf_gds-grp-obj
          then do:
              assign
                  v-exists = no
              .
          end.
          else do:
              assign
                  v-exists = yes
                  v-range = 1
              .
          end.
      end.
      else do:
          assign
              v-exists = yes
              v-range  = 2
          .
      end.
  end.
  else do:
      assign
          v-exists = yes
          v-range  = 3
      .
  end.
  if available buf_gds-grp-obj
  then do:
    assign
    v-min-value    = buf_gds-grp-obj.min-increase
    v-max-value    = buf_gds-grp-obj.max-increase
    v-increase-pc  = buf_gds-grp-obj.increase-pc
    v-round-method = buf_gds-grp-obj.round-method
    v-base         = buf_gds-grp-obj.round-coef
    .
    assign
    p-exists-margin = (if v-min-value <> ? and v-max-value <> ? and p-min-value = ?
                        then yes
                        else p-exists-margin)
    p-range-margin = if p-exists-margin and p-min-value = ?
                      then v-range
                      else p-range-margin
    p-min-value   =  if p-exists-margin and  p-min-value = ?
                      then v-min-value
                      else p-min-value
    p-max-value   =  if p-exists-margin and  p-max-value = ?
                      then v-max-value
                      else p-max-value
    p-exists-increase = (if v-increase-pc <> ? and p-increase-pc = ?
                        then yes
                        else p-exists-increase)
    p-range-increase = if p-exists-increase and p-increase-pc = ?
                      then v-range
                      else p-range-increase
    p-increase-pc = (if p-exists-increase and p-increase-pc = ?
                      then v-increase-pc
                      else p-increase-pc)
    p-exists-rmethod = if v-round-method <> "":U and p-round-method = "":U
                        then yes
                        else p-exists-rmethod
    p-range-rmethod = (if p-exists-rmethod and p-round-method = "":U
                        then v-range
                        else p-range-rmethod)
    p-round-method  = (if p-exists-rmethod and p-round-method = "":U
                        then v-round-method
                        else p-round-method)
    p-base          = (if p-exists-rmethod and p-base = ?
                        then v-base
                        else p-base)
    v-found =  (p-exists-margin and p-exists-increase and p-exists-rmethod) or (v-range <= 1)
    jj = jj + 1
    .
  end.
  else do:
    assign
    v-found =  (p-exists-margin and p-exists-increase and p-exists-rmethod ) or (v-range <= 1)
    jj = jj + 1
    .
  end.
end.
end.
end procedure.
procedure grp-obj-income-cli-value :
do
on error undo, return error
:
define input parameter p-node-code as integer      no-undo.
define input parameter p-obj-type  as character    no-undo.
define input parameter p-obj-code  as integer      no-undo.
define output parameter p-cli-type as character    no-undo init ?.
define output parameter p-cli-code as integer      no-undo init ?.
define output parameter p-range-income-cli     as integer      no-undo.
define output parameter p-exists-income-cli    as logical      no-undo.
define variable v-host-code as integer      no-undo.
DEFINE VARIABLE v-found as logical no-undo .
DEFINE VARIABLE v-exists as logical no-undo .
DEFINE VARIABLE v-range as integer no-undo .
DEFINE VARIABLE jj as integer no-undo .
DEFINE VARIABLE v-income-cli-found as logical no-undo .
DEFINE VARIABLE v-cli-type-value as char      no-undo.
DEFINE VARIABLE v-cli-code-value as int      no-undo.
define buffer buf_gds-grp for ub.gds-grp.
find first buf_gds-grp no-lock where
           buf_gds-grp.node-code = p-node-code no-error .
if not avail buf_gds-grp and p-node-code <> 0 then do:
  message
    vss-workfile vss-revision vss-description
    skip "Не удалось найти группу товаров с кодом" p-node-code
    view-as alert-box error .
  undo, return error .
end.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  ) no-error .
if error-status :error
then do:
    message
      vss-workfile vss-revision vss-description
      skip "Не удалось найти фирму объекта"
      skip p-obj-type p-obj-code
      skip return-value
      skip trim(error-status :get-message(1))
           trim(error-status :get-message(2))
           trim(error-status :get-message(3))
           trim(error-status :get-message(4))
           trim(error-status :get-message(5))
    view-as alert-box error.
    undo, return error .
end.
define buffer buf_gds-grp-obj      for ub.gds-grp-obj.
do while v-found = no and jj < 2:
  if v-range <> 3 then do:
    find first buf_gds-grp-obj no-lock
        where buf_gds-grp-obj.node-code = p-node-code
          and buf_gds-grp-obj.host-code = v-host-code
          and buf_gds-grp-obj.obj-type  = p-obj-type
          and buf_gds-grp-obj.obj-code  = p-obj-code
    no-error .
  end.
  if v-range = 3 or not available buf_gds-grp-obj
  then do:
     if v-range <> 2 then do:
        find first buf_gds-grp-obj no-lock
            where buf_gds-grp-obj.node-code = p-node-code
              and buf_gds-grp-obj.host-code = v-host-code
              and buf_gds-grp-obj.obj-type  = ""
              and buf_gds-grp-obj.obj-code  = 0
        no-error .
      end.
      if v-range = 2 or not available buf_gds-grp-obj
      then do:
          if v-range <> 1 then do:
            find first buf_gds-grp-obj no-lock
                where buf_gds-grp-obj.node-code = p-node-code
                and buf_gds-grp-obj.host-code = 0
                and buf_gds-grp-obj.obj-type  = ""
                and buf_gds-grp-obj.obj-code  = 0
            no-error .
          end.
          if v-range = 1 or not available buf_gds-grp-obj
          then do:
              assign
                  v-exists = no
              .
          end.
          else do:
              assign
                  v-exists = yes
                  v-range = 1
              .
          end.
      end.
      else do:
          assign
              v-exists = yes
              v-range  = 2
          .
      end.
  end.
  else do:
      assign
          v-exists = yes
          v-range  = 3
      .
  end.
  if available buf_gds-grp-obj
  then do:
    assign
    v-cli-type-value    = buf_gds-grp-obj.cli-type
    v-cli-code-value    = buf_gds-grp-obj.cli-code
    .
    assign
    p-exists-income-cli = (if v-cli-type-value <> ? and v-cli-code-value <> ? and p-cli-type = ?
                        then yes
                        else p-exists-income-cli)
    p-range-income-cli = if p-exists-income-cli and p-cli-type = ?
                      then v-range
                      else p-range-income-cli
    p-cli-type   =  if p-exists-income-cli and  p-cli-type = ?
                      then v-cli-type-value
                      else p-cli-type
    p-cli-code   =  if p-exists-income-cli and  p-cli-code = ?
                      then v-cli-code-value
                      else p-cli-code
    v-found =  (p-exists-income-cli ) or (v-range <= 1)
    jj = jj + 1
    .
  end.
  else do:
    assign
    v-found =  (p-exists-income-cli  ) or (v-range <= 1)
    jj = jj + 1
    .
  end.
end.
end.
end procedure.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable kk as integer no-undo .
define variable v-process as logical no-undo .
define variable v-contin as logical no-undo .
define variable v-lvl-num as integer no-undo .
define variable v-node-code like ub.gds-grp.node-code no-undo .
define variable glog as logical no-undo .
define variable v-curr-db-num like ub.db.db-num no-undo .
define buffer upper_gds-grp for ub.gds-grp.
glog = no.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output v-curr-db-num
  )  .
if BinMask(par-fields, "XXXX1":U) then do:
  if par-values = "default":U AND
    (par-calc-method = ? or
    par-calc-method = "":U or
    lookup(par-calc-method, 'Учетная,Учет-резерв,Накладная,Накл-безНДС,Учет-безНДС,Учет+накл,Уч+накл-НДС,Не-считать,Производит,Произв-НДС,ПорогПр-НДС,ПорогПр+НДС,Спецификация':U) = 0) then do:
      message
      vss-workfile vss-revision vss-description skip
      "Неверное значение параметра" par-calc-method
      view-as alert-box .
      return error .
  end.
end.
if BinMask(par-fields, "XX1XX":U) then do:
  if par-values = "default":U AND
    (par-round-method = ? or
    par-round-method = "":U or
    lookup(par-round-method, '9-окончание,9-99окончание,Без-дробных,Произвольно,Вверх,Коэффициент,Отключено':U) = 0) then do:
      message
      vss-workfile vss-revision vss-description skip
      "Неверное значение параметра" par-round-method
      view-as alert-box .
      return error .
  end.
  if par-values = "default":U AND
  lookup(par-round-method,  ('Произвольно,Вверх,Коэффициент,9-99окончание':U)) > 0 and
  par-base = 0 then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение коэффициента 0 для метода округления" par-round-method
    view-as alert-box error .
    return error .
  end.
end.
if v-curr-db-num <> 0 then do:
  message vss-workfile vss-revision vss-description skip
  "Утилиту можно запустить только в ГБД"
  view-as alert-box error .
  return error .
end.
message
"Инициализация полей СПОСОБ РАСЧЕТА,НАЦЕНКА,ДИАПАЗОНЫ НАЦЕНКИ,МЕТОД ОКРУГЛЕНИЯ в ГРУППАХ ТОВАРОВ ?   Вы уверены ?"
view-as alert-box question buttons OK-Cancel update glog.
if glog <> true then return.
message
"Внимание !  Если работа утилиты закончится ненормально"
"(нормально - это сообщение о завершении - все записи успешно обработаны)," skip
"запустите ее сразу же повторно !"
view-as alert-box .
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
                      (buffer ub.gds-grp,
                      0,
                      "":U,
                      0,
                      par-calc-method,
                      par-increase-pc,
                      par-min,
                      par-max,
                      par-round-method,
                      par-base,
                      par-cli-type ,
                      par-cli-code
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
                          ,input upper_gds-grp.calc-method
                          ,input upper_gds-grp.increase-pc
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
                            ,input upper_gds-grp.calc-method
                            ,input upper_gds-grp.increase-pc
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
define input parameter p-host-code like ub.sysconf.host-code no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define input parameter p-calc-method like ub.gds-grp.calc-method no-undo .
define input parameter p-increase-pc like ub.gds-grp.increase-pc no-undo .
define input parameter p-min like ub.gds-grp.increase-pc no-undo .
define input parameter p-max like ub.gds-grp.increase-pc no-undo .
define input parameter p-round-method as character no-undo .
define input parameter p-base as decimal no-undo .
define input parameter p-cli-type like ub.clients.obj-type no-undo .
define input parameter p-cli-code like ub.clients.obj-code no-undo .
define variable v-value as character no-undo .
define variable v-type as character no-undo .
define variable v-max as decimal no-undo init ?.
define variable v-min as decimal no-undo init ?.
define variable v-incr as decimal no-undo init ? .
define variable v-round-method as character no-undo init ?.
define variable v-base as decimal no-undo init ?.
define variable v-rid as recid no-undo .
define variable v-calc-method as character no-undo .
define variable v-increase-pc as decimal no-undo .
define variable v-cli-type as character no-undo .
define variable v-cli-code as integer no-undo .
define variable x_max as decimal no-undo init ?.
define variable x_min as decimal no-undo init ?.
define variable x_incr as decimal no-undo init ? .
define variable x_round-method as character no-undo init ?.
define variable x_base as decimal no-undo init ?.
define variable x_rid as recid no-undo .
define variable x_calc-method as character no-undo .
define variable x_increase-pc as decimal no-undo .
define variable x_cli-type as character no-undo .
define variable x_cli-code as integer no-undo .
define variable v-delim as character no-undo .
define variable v-entry as character no-undo extent 4.
define variable ll as integer no-undo .
define variable v-error as logical no-undo .
define variable var-fill-method as character no-undo .
define buffer buf_gds-grp-obj for ub.gds-grp-obj.
define buffer buf_root_gds-grp-obj for ub.gds-grp-obj.
  do
  on error undo, return error
  :
    assign
    var-fill-method = par-fill-method
    .
    find first buf_root_gds-grp-obj no-lock where
               buf_root_gds-grp-obj.node-code = buf_gds-grp.node-code
           AND buf_root_gds-grp-obj.host-code = 0
           AND buf_root_gds-grp-obj.obj-type = "":U
           AND buf_root_gds-grp-obj.obj-code = 0 no-error .
    if available buf_root_gds-grp-obj then do:
      assign
      v-min           = buf_root_gds-grp-obj.min-increase
      v-max           = buf_root_gds-grp-obj.max-increase
      v-incr          = buf_root_gds-grp-obj.increase-pc
      v-round-method  = buf_root_gds-grp-obj.round-method
      v-base          = buf_root_gds-grp-obj.round-coef
      v-cli-type      = buf_root_gds-grp-obj.cli-type
      v-cli-code      = buf_root_gds-grp-obj.cli-code
      .
      assign
      v-calc-method = buf_gds-grp.calc-method
      v-increase-pc = buf_gds-grp.increase-pc
      .
      assign
      x_cli-type     = if BinMask(par-fields, "1XXXX":U) then p-cli-type else v-cli-type
      x_cli-code     = if BinMask(par-fields, "1XXXX":U) then p-cli-code else v-cli-code
      x_min          = if BinMask(par-fields, "X1XXX":U) then p-Min else v-min
      x_max          = if BinMask(par-fields, "X1XXX":U) then p-Max else v-max
      x_incr         = if BinMask(par-fields, "XXX1X":U) then p-increase-pc else v-incr
      x_round-method = if BinMask(par-fields, "XX1XX":U) then p-round-method else v-round-method
      x_base         = if BinMask(par-fields, "XX1XX":U) then p-base else v-base
      x_calc-method  = if BinMask(par-fields, "XXXX1":U) then p-calc-method else v-calc-method
      x_increase-pc  = if BinMask(par-fields, "XXX1X":U) then p-increase-pc else v-increase-pc
      .
    end.
    else do:
      assign
      x_cli-type     = p-cli-type
      x_cli-code     = p-cli-code
      x_min          = p-Min
      x_max          = p-Max
      x_incr         = p-increase-pc
      x_round-method = p-round-method
      x_base         = p-base
      x_calc-method  = p-calc-method
      x_increase-pc  = p-increase-pc
      var-fill-method = "space"
      .
    end.
    CASE var-fill-method:
      when "all":U then do:
      end.
      when "error-or-space":U then do:
        assign
        x_cli-type     = if v-cli-type = ?
                         or v-entry[1] = "":U
                         then p-cli-type
                         else v-cli-type
        x_cli-code     = if v-cli-code = ?
                         or v-entry[2] = "":U
                         then p-cli-code
                         else v-cli-code
        x_min          = if v-min = ?
                         or v-entry[1] = "":U
                         then p-Min
                         else v-min
        x_max          = if v-max = ?
                         or v-entry[2] = "":U
                         then p-Max
                         else v-max
        x_increase-pc  = if v-incr = ?
                         or v-entry[3] = "":U
                         or v-incr <> v-increase-pc
                         or v-increase-pc = ?
                         then p-increase-pc
                         else v-incr
        x_round-method = if v-round-method = "":U
                         or v-round-method = ?
                         or lookup(v-round-method, '9-окончание,9-99окончание,Без-дробных,Произвольно,Вверх,Коэффициент,Отключено':U) = 0
                         then p-round-method
                         else v-round-method
        x_base         = if v-base = ?
                         or (lookup(v-round-method, 'Произвольно,Вверх,Коэффициент,9-99окончание':U) > 0 and v-base = 0)
                         then p-base
                         else v-base
        x_calc-method  = if v-calc-method = "":U
                         or v-calc-method = ?
                         or lookup(v-calc-method, 'Учетная,Учет-резерв,Накладная,Накл-безНДС,Учет-безНДС,Учет+накл,Уч+накл-НДС,Не-считать,Производит,Произв-НДС,ПорогПр-НДС,ПорогПр+НДС,Спецификация':U) = 0
                         then p-calc-method
                         else v-calc-method
        .
      end.
      when "error":U then do:
        assign
        x_min          = if v-min = ?
                         then p-Min
                         else v-min
        x_max          = if v-max = ?
                         then p-Max
                         else v-max
        x_cli-type     = if v-cli-type = ?
                         then p-cli-type
                         else v-cli-type
        x_cli-code     = if v-cli-code = ?
                         then p-cli-code
                         else v-cli-code
        x_increase-pc  = if v-incr = ?
                         or v-incr <> v-increase-pc
                         or v-increase-pc = ?
                         then p-increase-pc
                         else v-incr
        x_round-method = if v-round-method = ?
                         or lookup(v-round-method, '9-окончание,9-99окончание,Без-дробных,Произвольно,Вверх,Коэффициент,Отключено':U) = 0
                         then p-round-method
                         else v-round-method
        x_base         = if v-base = ?
                         or (lookup(v-round-method, 'Произвольно,Вверх,Коэффициент,9-99окончание':U) > 0 and v-base = 0)
                         then p-base
                         else v-base
        x_calc-method  = if v-calc-method  = ?
                         or lookup(v-calc-method, 'Учетная,Учет-резерв,Накладная,Накл-безНДС,Учет-безНДС,Учет+накл,Уч+накл-НДС,Не-считать,Производит,Произв-НДС,ПорогПр-НДС,ПорогПр+НДС,Спецификация':U) = 0
                         then p-calc-method
                         else v-calc-method
        .
      end.
      when "space":U then do:
        assign
        x_min          = if v-entry[1] = "":U
                         then p-Min
                         else v-min
        x_max          = if v-entry[2] = "":U
                         then p-Max
                         else v-max
        x_cli-type     = if v-entry[1] = "":U
                         then p-cli-type
                         else v-cli-type
        x_cli-code     = if v-entry[2] = "":U
                         then p-cli-code
                         else v-cli-code
        x_increase-pc  = if v-entry[3] = "":U
                         then p-increase-pc
                         else v-incr
        x_round-method = if v-round-method = "":U
                         then p-round-method
                         else v-round-method
        x_base         = if v-round-method = "":U
                         then p-base
                         else v-base
        x_calc-method  = if v-calc-method = "":U
                         then p-calc-method
                         else v-calc-method
        .
      end.
    END CASE.
    assign
    v-error = if x_min = ? and BinMask(par-fields, "X1XXX":U)
              then yes
              else v-error
    v-error = if x_max = ? and BinMask(par-fields, "X1XXX":U)
              then yes
              else v-error
    v-error = if x_cli-type = ? and BinMask(par-fields, "1XXXX":U)
              then yes
              else v-error
    v-error = if x_cli-code = ? and BinMask(par-fields, "1XXXX":U)
              then yes
              else v-error
    v-error = if x_incr = ? and BinMask(par-fields, "XXX1X":U)
              then yes
              else v-error
    v-error = if (x_round-method = ?
              or lookup(x_round-method, '9-окончание,9-99окончание,Без-дробных,Произвольно,Вверх,Коэффициент,Отключено':U) = 0)
              and BinMask(par-fields, "XX1XX":U)
              then yes
              else v-error
    v-error = if (x_base = ?
              or (lookup(x_round-method, 'Произвольно,Вверх,Коэффициент,9-99окончание':U) > 0 and x_base = 0)
              )
              and BinMask(par-fields, "XX1XX":U)
              then yes
              else v-error
    v-error = if (x_calc-method  = ?
              or lookup(x_calc-method, 'Учетная,Учет-резерв,Накладная,Накл-безНДС,Учет-безНДС,Учет+накл,Уч+накл-НДС,Не-считать,Производит,Произв-НДС,ПорогПр-НДС,ПорогПр+НДС,Спецификация':U) = 0)
              and BinMask(par-fields, "XXXX1":U)
              then yes
              else v-error
    .
    if v-error then return "error".
    if x_calc-method <> v-calc-method
    or x_increase-pc <> v-increase-pc then do:
      run ref/gdsgrp01.p (
                      input 'ИЗМЕНЕНИЕ':U
                    ,input yes
                    ,input no
                    ,input no
                    ,input-output buf_gds-grp.node-code
                    ,input-output buf_gds-grp.upper-code
                    ,input buf_gds-grp.node-name
                    ,input x_calc-method
                    ,input x_increase-pc
                    ,input x_round-method
                    ,input x_base
                    ,output v-rid
                    ) no-error.
    end.
    if  true = true  then do:
      if ( BinMask(par-region, "XX1":U) and p-host-code = 0 ) or
         (( BinMask(par-region, "X1X":U)  or BinMask(par-region, "1XX":U) )  and p-host-code <> 0 )
      then do:
          run grp-obj-write in this-procedure (
                                                input buf_gds-grp.node-code
                                              , input p-host-code
                                              , input p-obj-type
                                              , input p-obj-code
                                              , input x_min
                                              , input x_max
                                              , input x_increase-pc
                                              , input buf_gds-grp.calc-method
                                              , input x_round-method
                                              , input x_base
                                              , input x_cli-type
                                              , input x_cli-code
                                              ) no-error.
          end.
      if (BinMask(par-region, "X1X":U)
      or BinMask(par-region, "1XX":U)
         )
      and  par-fields <> 1
      and p-host-code = 0
      then do:
        if BinMask(par-region, "X1X":U) then do:
              for each buf_gds-grp-obj no-lock where
                      buf_gds-grp-obj.node-code = buf_gds-grp.node-code
                  AND buf_gds-grp-obj.host-code <> 0
                  and buf_gds-grp-obj.obj-type = ""
                  and buf_gds-grp-obj.obj-code = 0
                  :
                assign
                ii = ii + 1
                .
                run proc-assign in this-procedure
                                (buffer ub.gds-grp,
                                buf_gds-grp-obj.host-code,
                                buf_gds-grp-obj.obj-type,
                                buf_gds-grp-obj.obj-code,
                                p-calc-method,
                                p-increase-pc,
                                p-min,
                                p-max,
                                p-round-method,
                                p-base,
                                p-cli-type ,
                                p-cli-code
                                ) no-error .
                if not error-status:error and return-value <> "error":U then
                jj = jj + 1.
                run waitfram-show in this-procedure ("Обработано" + chr(32) +
                              string(ii) + chr(32) +
                              "записей - успешно" + chr(32) +
                              string(jj)).
              end.
        end.
        if BinMask(par-region, "1XX":U) then do:
              for each buf_gds-grp-obj no-lock where
                      buf_gds-grp-obj.node-code = buf_gds-grp.node-code
                  AND buf_gds-grp-obj.host-code <> 0
                  and buf_gds-grp-obj.obj-type <> ""
                  and buf_gds-grp-obj.obj-code <> 0
                  :
                assign
                ii = ii + 1
                .
                run proc-assign in this-procedure
                                (buffer ub.gds-grp,
                                buf_gds-grp-obj.host-code,
                                buf_gds-grp-obj.obj-type,
                                buf_gds-grp-obj.obj-code,
                                p-calc-method,
                                p-increase-pc,
                                p-min,
                                p-max,
                                p-round-method,
                                p-base,
                                p-cli-type ,
                                p-cli-code
                                ) no-error .
                if not error-status:error and return-value <> "error":U then
                jj = jj + 1.
                run waitfram-show in this-procedure ("Обработано" + chr(32) +
                              string(ii) + chr(32) +
                              "записей - успешно" + chr(32) +
                              string(jj)).
              end.
        end.
      end.
    end.
  end.
end procedure.
procedure ini-tree :
define input parameter par-node-code like ub.gds-grp.node-code no-undo .
define input parameter par-lvl-num   like ub.gds-grp.lvl-num no-undo .
define input parameter p_calc-method like ub.gds-grp.calc-method no-undo .
define input parameter p_increase-pc like ub.gds-grp.increase-pc no-undo .
define variable v-value as character no-undo .
define variable v-type as character no-undo .
define variable v-max as decimal no-undo .
define variable v-min as decimal no-undo .
define variable v-incr as decimal no-undo .
define variable v-round-method as character no-undo .
define variable v-base         as decimal no-undo .
define variable v-rid as recid no-undo .
define variable v-calc-method as character no-undo .
define variable v-increase-pc as decimal no-undo .
define variable v-cli-type as character no-undo .
define variable v-cli-code as integer no-undo .
DEFINE VARIABLE v-contin as logical no-undo .
define variable v-process as logical no-undo .
define variable v-nc like ub.gds-grp.node-code no-undo .
define buffer buf_gds-grp for ub.gds-grp.
define buffer new_gds-grp for ub.gds-grp.
define buffer buf_gds-grp-obj for ub.gds-grp-obj.
  do
  on error undo, return error
  :
    find first buf_gds-grp-obj no-lock where
               buf_gds-grp-obj.node-code = par-node-code
           AND buf_gds-grp-obj.host-code = 0
           AND buf_gds-grp-obj.obj-type = "":U
           AND buf_gds-grp-obj.obj-code = 0.
    assign
    v-min          = buf_gds-grp-obj.min-increase
    v-max          = buf_gds-grp-obj.max-increase
    v-incr         = buf_gds-grp-obj.increase-pc
    v-round-method = buf_gds-grp-obj.round-method
    v-base         = buf_gds-grp-obj.round-coef
    v-cli-type     = buf_gds-grp-obj.cli-type
    v-cli-code     = buf_gds-grp-obj.cli-code
    .
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
                                          buffer buf_gds-grp,
                                          0,
                                          "":U,
                                          0,
                                          p_calc-method,
                                          p_increase-pc,
                                          v-min,
                                          v-max,
                                          v-round-method,
                                          v-base,
                                          v-cli-type ,
                                          v-cli-code
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
