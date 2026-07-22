block-level on error undo, throw.
define input parameter p-host-code like ub.sysconf.host-code no-undo .
DEFINE INPUT PARAMETER DcardMode as char no-undo.
DEFINE INPUT PARAMETER FixDCard as char no-undo.
DEFINE INPUT PARAMETER current-gcode like ub.cli-grp.node-code.
DEFINE INPUT PARAMETER cli-str as char no-undo.
DEFINE INPUT PARAMETER filter-name as char no-undo.
DEFINE INPUT PARAMETER TotalOnly as logical no-undo.
define input parameter t-legacy as logical no-undo .
define input parameter t-subsid as logical no-undo .
define input parameter p-curr-type as character no-undo .
define input parameter p-sort-mode as character no-undo .
define input parameter p-group-mode as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":u .
define variable vss-author      as character no-undo init "$Author: expertek $":u .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":u .
define variable vss-workfile    as character no-undo init "$Workfile: e-xldbj.p $":u .
define variable vss-archive     as character no-undo init "$Archive: rep/e-xldbj.p $":u .
define variable vss-description as character no-undo init "Заполнение полей временной таблицы для отчета итоги по дисконтным картам" .
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
define SHARED temp-table sj-cards  no-undo
field d-card        like ub.dis-card.d-card
field cli-type      like ub.clients.obj-type
field cli-code      like ub.clients.obj-code
field cli-name      like ub.clients.obj-name
field global-card   as logical
field credit-card   like ub.dis-card.credit-card
field g-code        like ub.cli-grp.node-code
field d-pcnt        like ub.dis-card.d-pcnt
field d-pcntchr     as character
field must-pay      as decimal
field saldo         as decimal
field pay           as decimal
field tot           as decimal
field disc          as decimal
field netto         as decimal
field instant-pay   as decimal
field credit-pay    as decimal
field num-chk       as integer
field obj-qnty      as integer
field card-num-chr  as character
field is-sum        as logical
field last-card     like ub.dis-card.d-card
field main-card     like ub.dis-card.main-card
field first-card    like ub.dis-card.first-card
field first-main-card  like ub.dis-card.first-main-card
INDEX pi            IS PRIMARY UNIQUE
d-card is-sum
INDEX ipay
pay
INDEX grp-code
d-card
g-code
index pi2
last-card
index p3 card-num-chr is-sum
.
def SHARED temp-table sj-groups  no-undo
field g-code       like ub.cli-grp.node-code
field g-name       like ub.cli-grp.node-name
field obj-code      like ub.dis-obj.obj-code
field tot             as decimal
field disc          as decimal
field netto         as decimal
field pay           as decimal
field credit-pay    as decimal
field instant-pay    as decimal
field num-chk    as integer
field cards-qnty as integer
field must-pay   as decimal
field saldo      as decimal
field obj-qnty   as integer
INDEX igroup  is primary
      g-code
      obj-code
.
DEFINE SHARED TEMP-TABLE legacy NO-UNDO
field root-card     like ub.dis-card.d-card
field d-card        like ub.dis-card.d-card
field card-num      like ub.dis-card.card-num
field sourced-card  like ub.dis-card.sourced-card
field last-card     like ub.dis-card.d-card
field d-pcntchr as character
field d-pcnt like ub.dis-card.d-pcnt
field leg-num       as integer
index pi is primary
card-num
leg-num   descending
index p1 d-card
index p2
card-num
sourced-card.
DEFINE SHARED TEMP-TABLE legacy-obj NO-UNDO
field d-card        like ub.dis-card.d-card
field first-card    like ub.dis-card.first-card
field main-card    like ub.dis-card.first-card
field first-main-card    like ub.dis-card.first-main-card
field card-num-chr  as character
field obj-type      like ub.dis-obj.obj-type
field obj-code      like ub.dis-obj.obj-code
field gds-tot-rubl as decimal
field pay-tot-rubl as decimal
field gds-dis-rubl as decimal
field gds-tot-base as decimal
field pay-tot-base as decimal
field gds-dis-base as decimal
field d-pcnt as decimal
field d-pcntchr as character
field num-chk    as integer
index pi is primary unique
obj-type
obj-code
card-num-chr
index pi2
obj-type
obj-code
d-card
index pi3
d-card
obj-type
obj-code
.
def SHARED var dis-obj-found as logical no-undo init NO.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def
 shared
temp-table  obj-list no-undo
  field obj-type like ub.clients.obj-type
  field obj-code like ub.clients.obj-code
  field obj-name like ub.clients.obj-name
  field obj-id   as integer
  field db-num   as integer
  index pi is primary unique obj-id
  index ie1 obj-type obj-code
  index ie2 obj-name
.
procedure create_obj-list :
   define input parameter p-obj-type like ub.clients.obj-type no-undo .
   define input parameter p-obj-code like ub.clients.obj-code no-undo .
   do
   on error undo, return error return-value
   :
      define buffer cli-obj for ub.clients .
      define variable p-var as integer no-undo .
      define buffer buf_obj-list for obj-list .
      find last buf_obj-list  use-index pi no-error .
      if available buf_obj-list
      then
         p-var = buf_obj-list.obj-id + 1.
      else
         p-var = 1.
      find first cli-obj where
                cli-obj.obj-type = p-obj-type
            and cli-obj.obj-code = p-obj-code
      no-lock no-error.
      if available cli-obj
      then do:
         create buf_obj-list.
         assign
            buf_obj-list.obj-id   = p-var
            buf_obj-list.obj-code = cli-obj.obj-code
            buf_obj-list.obj-type = cli-obj.obj-type
            buf_obj-list.obj-name = cli-obj.obj-name
            buf_obj-list.db-num   = cli-obj.db-num
         .
      end.
   end.
end.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define shared temp-table dc-list no-undo like ub.dis-card
  field to-del as logical
  field order-num as integer
  field fdec as decimal
  field fint as integer
  field flog as logical
  field fchar as character
  index pi  is primary unique d-card
  index cn      card-num
  index cli cli-type cli-code
  index host-dscnt  emitent-host-code status_ d-pcnt
  index host-type  emitent-host-code type d-pcnt
  index oi order-num
  .
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  shared  temp-table dc-list-hist no-undo
field list-table as character
field id as integer
field line as integer
field hist-mode as character
field des as character
field num-recs as integer
field option_ as character
field item_ as character
field status_ as character
field num-add as integer
field num-ignored as integer
field done as logical
field err_ as logical
field err-mes as character
index pi is primary
id
line
index isdone
done
.
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION get-d-pcntdc-list RETURNS CHARACTER
  ( buffer loc-dis-card for dc-list,
    input parhost-code as integer,
    input parobj-type as character,
    input parobj-code as integer,
    input p-discnt-role as character,
    output loc-d-v as decimal) :
define variable v-node-code as integer no-undo .
define buffer buf_dis-card-type for ub.dis-card-type.
define buffer buf_dis-card-property for ub.dis-card-property.
find first buf_dis-card-type no-lock where
          buf_dis-card-type.type = loc-dis-card.type
      and buf_dis-card-type.emitent-host-code = loc-dis-card.emitent-host-code
      and buf_dis-card-type.host-code = 0
      and buf_dis-card-type.obj-type = '':U
      and buf_dis-card-type.obj-code = 0 no-error.
if available buf_dis-card-type then do:
  case p-discnt-role:
    when 'def-pcnt':U  then do:
      assign
      v-node-code = 1.
    end.
    when 'def-cash-pcnt':U then do:
      assign
      v-node-code = 2.
    end.
    when 'def-categ':U then do:
      assign
      v-node-code = 3.
    end.
  end.
  if buf_dis-card-type.d-pcnt-byshop then do:
   find first buf_dis-card-property no-lock where
             buf_dis-card-property.d-card = loc-dis-card.d-card
         and buf_dis-card-property.dtm-code = 26
         and buf_dis-card-property.host-code = parhost-code
         and buf_dis-card-property.obj-type = parobj-type
         and buf_dis-card-property.obj-code = parobj-code
         and buf_dis-card-property.node-code = v-node-code no-error.
   if available buf_dis-card-property then do:
     if p-discnt-role = 'def-categ':U then do:
       assign
       loc-d-v = buf_dis-card-property.property-value-integer.
     end.
     else do:
       assign
       loc-d-v = buf_dis-card-property.property-value-decimal.
     end.
   end.
    if loc-d-v = ? then do:
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdpcnt in g#library
  (
   input  loc-dis-card.type
  ,input  loC-dis-card.emitent-host-code
  ,input  parhost-code
  ,input  parobj-type
  ,input  parobj-code
  ,input  p-discnt-role
  ,output loc-d-v
  ) no-error .
    end.
    if loc-d-v = ? then do:
      find first buf_dis-card-property no-lock where
                buf_dis-card-property.d-card = loc-dis-card.d-card
            and buf_dis-card-property.dtm-code = 26
            and buf_dis-card-property.host-code = parhost-code
            and buf_dis-card-property.obj-type = ''
            and buf_dis-card-property.obj-code = 0
            and buf_dis-card-property.node-code = v-node-code no-error.
      if available buf_dis-card-property then do:
        if p-discnt-role = 'def-categ':U then do:
          assign
          loc-d-v = buf_dis-card-property.property-value-integer.
        end.
        else do:
          assign
          loc-d-v = buf_dis-card-property.property-value-decimal.
        end.
      end.
    end.
    if loc-d-v = ? then do:
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdpcnt in g#library
  (
   input  loc-dis-card.type
  ,input  loC-dis-card.emitent-host-code
  ,input  parhost-code
  ,input  ''
  ,input  0
  ,input  p-discnt-role
  ,output loc-d-v
  ) no-error .
    end.
    if loc-d-v = ? then do:
      case p-discnt-role:
        when 'def-categ':U then do:
          loc-d-v = loc-dis-card.category.
        end.
        when 'def-pcnt':U then do:
          loc-d-v = loc-dis-card.d-pcnt.
        end.
        when 'def-cash-pcnt':U then do:
          loc-d-v = loc-dis-card.cash-d-pcnt.
        end.
      end case.
    end.
    if p-discnt-role = 'def-categ':U then do:
      return substitute("(i) &1", string(loc-d-v, ">>>9")).
    end.
    else do:
      return substitute("(i) &1", string(loc-d-v, "->9.99%")).
    end.
  end.
end.
else do:
 return "ОШИБКА-НЕТ ТИПА".
end.
case p-discnt-role:
  when 'def-categ':U then do:
     loc-d-v = loc-dis-card.category.
     return string(loc-d-v, ">>>9").
  end.
  when 'def-pcnt':U then do:
    loc-d-v = loc-dis-card.d-pcnt.
    return string(loc-d-v, "->9.99%").
  end.
  when 'def-cash-pcnt':U then do:
    loc-d-v = loc-dis-card.cash-d-pcnt.
    return string(loc-d-v, "->9.99%").
  end.
end case.
END FUNCTION.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION get-d-pcnt RETURNS CHARACTER
  ( buffer loc-dis-card for ub.dis-card,
    input parhost-code as integer,
    input parobj-type as character,
    input parobj-code as integer,
    input p-discnt-role as character,
    output loc-d-v as decimal) :
define variable v-node-code as integer no-undo .
define buffer buf_dis-card-type for ub.dis-card-type.
define buffer buf_dis-card-property for ub.dis-card-property.
find first buf_dis-card-type no-lock where
          buf_dis-card-type.type = loc-dis-card.type
      and buf_dis-card-type.emitent-host-code = loc-dis-card.emitent-host-code
      and buf_dis-card-type.host-code = 0
      and buf_dis-card-type.obj-type = '':U
      and buf_dis-card-type.obj-code = 0 no-error.
if available buf_dis-card-type then do:
  case p-discnt-role:
    when 'def-pcnt':U  then do:
      assign
      v-node-code = 1.
    end.
    when 'def-cash-pcnt':U then do:
      assign
      v-node-code = 2.
    end.
    when 'def-categ':U then do:
      assign
      v-node-code = 3.
    end.
  end.
  if buf_dis-card-type.d-pcnt-byshop then do:
   find first buf_dis-card-property no-lock where
             buf_dis-card-property.d-card = loc-dis-card.d-card
         and buf_dis-card-property.dtm-code = 26
         and buf_dis-card-property.host-code = parhost-code
         and buf_dis-card-property.obj-type = parobj-type
         and buf_dis-card-property.obj-code = parobj-code
         and buf_dis-card-property.node-code = v-node-code no-error.
   if available buf_dis-card-property then do:
     if p-discnt-role = 'def-categ':U then do:
       assign
       loc-d-v = buf_dis-card-property.property-value-integer.
     end.
     else do:
       assign
       loc-d-v = buf_dis-card-property.property-value-decimal.
     end.
   end.
    if loc-d-v = ? then do:
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdpcnt in g#library
  (
   input  loc-dis-card.type
  ,input  loC-dis-card.emitent-host-code
  ,input  parhost-code
  ,input  parobj-type
  ,input  parobj-code
  ,input  p-discnt-role
  ,output loc-d-v
  ) no-error .
    end.
    if loc-d-v = ? then do:
      find first buf_dis-card-property no-lock where
                buf_dis-card-property.d-card = loc-dis-card.d-card
            and buf_dis-card-property.dtm-code = 26
            and buf_dis-card-property.host-code = parhost-code
            and buf_dis-card-property.obj-type = ''
            and buf_dis-card-property.obj-code = 0
            and buf_dis-card-property.node-code = v-node-code no-error.
      if available buf_dis-card-property then do:
        if p-discnt-role = 'def-categ':U then do:
          assign
          loc-d-v = buf_dis-card-property.property-value-integer.
        end.
        else do:
          assign
          loc-d-v = buf_dis-card-property.property-value-decimal.
        end.
      end.
    end.
    if loc-d-v = ? then do:
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdpcnt in g#library
  (
   input  loc-dis-card.type
  ,input  loC-dis-card.emitent-host-code
  ,input  parhost-code
  ,input  ''
  ,input  0
  ,input  p-discnt-role
  ,output loc-d-v
  ) no-error .
    end.
    if loc-d-v = ? then do:
      case p-discnt-role:
        when 'def-categ':U then do:
          loc-d-v = loc-dis-card.category.
        end.
        when 'def-pcnt':U then do:
          loc-d-v = loc-dis-card.d-pcnt.
        end.
        when 'def-cash-pcnt':U then do:
          loc-d-v = loc-dis-card.cash-d-pcnt.
        end.
      end case.
    end.
    if p-discnt-role = 'def-categ':U then do:
      return substitute("(i) &1", string(loc-d-v, ">>>9")).
    end.
    else do:
      return substitute("(i) &1", string(loc-d-v, "->9.99%")).
    end.
  end.
end.
else do:
 return "ОШИБКА-НЕТ ТИПА".
end.
case p-discnt-role:
  when 'def-categ':U then do:
     loc-d-v = loc-dis-card.category.
     return string(loc-d-v, ">>>9").
  end.
  when 'def-pcnt':U then do:
    loc-d-v = loc-dis-card.d-pcnt.
    return string(loc-d-v, "->9.99%").
  end.
  when 'def-cash-pcnt':U then do:
    loc-d-v = loc-dis-card.cash-d-pcnt.
    return string(loc-d-v, "->9.99%").
  end.
end case.
END FUNCTION.
define variable new-card as logical no-undo.
DEFINE VARIABLE vwait as character no-undo .
DEFINE VARIABLE vproc-arch-disc-cards as character no-undo .
DEFINE VARIABLE loc-d-pcnt like ub.dis-card.d-pcnt no-undo .
define buffer card-clients for ub.clients.
define buffer bsj-groups for sj-groups.
define buffer bsj-cards for sj-cards.
define buffer buf_dis-card for ub.dis-card.
define buffer osn_dis-card for ub.dis-card.
define buffer cli-obj for ub.clients.
define variable v-count as integer   no-undo .
run waitfram-show in this-procedure  ( input "Ждите... Обработано архивов по ДК").
define temp-table temp-dis-card no-undo like ub.dis-card.
create bsj-cards.
assign
bsj-cards.d-card = ?
.
create temp-dis-card.
FOR EACH obj-list no-lock ,
    FIRST cli-obj no-lock where
         cli-obj.obj-type = obj-list.obj-type
    AND  cli-obj.obj-code = obj-list.obj-code:
  case dcardmode:
    when "LIST"
    or
    when "ONE" then do:
      FOR EACH dc-list no-lock,
         first ub.dis-obj no-lock WHERE
            ub.dis-obj.dt-code = 0
        and ub.dis-obj.d-card = dc-list.d-card
        and ub.dis-obj.obj-type = obj-list.obj-type
        AND ub.dis-obj.obj-code = obj-list.obj-code,
         FIRST card-clients NO-LOCK WHERE
              card-clients.obj-type = dc-list.cli-type
          AND card-clients.obj-code = dc-list.cli-code:
        if p-group-mode =  "ONE":U
        and  card-clients.grp-code <> current-gcode then next.
        PROCESS EVENTS .
        dis-obj-found = yes.
        buffer-copy dc-list to temp-dis-card.
        run process-dis-obj in this-procedure .
      end.
    end.
    otherwise do:
      FOR EACH ub.dis-obj no-lock WHERE
            ub.dis-obj.dt-code = 0
        and obj-list.obj-type = ub.dis-obj.obj-type
        AND obj-list.obj-code = ub.dis-obj.obj-code
        AND ub.dis-obj.host-code = cli-obj.host-code,
        FIRST ub.dis-card No-LOCK WHERE
            ub.dis-card.d-card = ub.dis-obj.d-card,
       FIRST card-clients NO-LOCK WHERE
            card-clients.obj-type = ub.dis-card.cli-type
        AND card-clients.obj-code = ub.dis-card.cli-code:
        if p-group-mode =  "ONE":U
        and  card-clients.grp-code <> current-gcode then next.
        PROCESS EVENTS .
        dis-obj-found = yes.
        buffer-copy dis-card to temp-dis-card.
        run process-dis-obj in this-procedure .
      end.
    end.
  end case.
end.
run waitfram-hide in this-procedure  .
procedure process-dis-obj :
do
on error undo, return error return-value
:
    v-count = v-count + 1.
    if v-count modulo 10  = 0
    AND v-count  >= 10 then do:
      run waitfram-show in this-procedure ( input substitute("&1&2 Обработано архивов по ДК: &3"
                                                            ,obj-list.obj-type
                                                            ,obj-list.obj-code
                                                            ,v-count )
                                           ).
    end.
    assign
    new-card = no.
    if p-sort-mode = "group":U then do:
      FIND  FIRST  bsj-groups WHERE
                    bsj-groups.g-code = card-clients.grp-code AND
                    bsj-groups.obj-code = 0
                    NO-ERROR.
      if p-group-mode = "LIST":U then do:
        if NOT avail bsj-groups then do:
            NEXT.
        end.
      end.
      IF NOT AVAIL bsj-groups then do:
        FIND FIRST ub.cli-grp No-LOCK WHERE
                  ub.cli-grp.node-code = card-clients.grp-code NO-ERROR.
        create bsj-groups.
        assign
        bsj-groups.g-code = card-clients.grp-code
        bsj-groups.g-name = (if avail ub.cli-grp then ub.cli-grp.node-name else "")
        bsj-groups.obj-code = 0
        .
      end.
      FIND FIRST sj-groups WHERE
                sj-groups.g-code = card-clients.grp-code AND
                sj-groups.obj-code = ub.dis-obj.obj-code No-ERROR.
      IF NOT AVAIL sj-groups then do:
        FIND FIRST ub.cli-grp No-LOCK WHERE
                  ub.cli-grp.node-code = card-clients.grp-code NO-ERROR.
        create sj-groups.
        assign
        sj-groups.g-code = card-clients.grp-code
        sj-groups.g-name = (if avail cli-grp then cli-grp.node-name else "")
        sj-groups.obj-code = dis-obj.obj-code
        .
      end.
    end.
    FIND FIRST sj-cards No-LOCK WHERE
               sj-cards.d-card = dis-obj.d-card NO-ERROR.
    IF NOT AVAIL sj-cards then do:
      FIND FIRST ub.dis-host No-LOCK WHERE
                 ub.dis-host.d-card = ub.dis-obj.d-card
             AND ub.dis-host.host-code = p-host-code
             and ub.dis-host.dt-code = 0  No-ERROR.
      create
      sj-cards.
      assign
      new-card = yes
      sj-cards.d-card = ub.dis-obj.d-card
      sj-cards.g-code = card-clients.grp-code
      sj-cards.global-card = (temp-dis-card.emitent-host-code = 0)
      sj-cards.credit-card = temp-dis-card.credit-card
      sj-cards.cli-type = temp-dis-card.cli-type
      sj-cards.cli-code = temp-dis-card.cli-code
      sj-cards.cli-name =  card-clients.obj-name
      sj-cards.d-pcnt = temp-dis-card.d-pcnt
      sj-cards.saldo = (if p-curr-type = 'rubl':U
                        then temp-dis-card.saldo-rubl
                        else temp-dis-card.saldo-base
                        )
      sj-cards.must-pay = if sj-cards.saldo < 0 then (- sj-cards.saldo) else 0
      sj-cards.pay = (if avail dis-host
                      then (if p-curr-type = 'rubl':U
                            then dis-host.pay-tot-rubl
                            else dis-host.pay-tot-base )
                      else 0)
      sj-cards.obj-qnty = 0
      sj-cards.first-main-card = dis-obj.first-main-card
      sj-cards.main-card = dis-obj.main-card
      sj-cards.first-card = dis-obj.first-card
      sj-cards.card-num-chr = (if t-legacy or t-subsid
                               then (if t-legacy
                                     and t-subsid
                                     then dis-obj.first-main-card
                                     else (if t-legacy
                                           then dis-obj.first-card
                                           else dis-obj.main-card)
                                     )
                               else  dis-obj.d-card)
      bsj-cards.saldo = bsj-cards.saldo +
                        (if p-curr-type = 'rubl':U
                         then temp-dis-card.saldo-rubl
                         else temp-dis-card.saldo-base
                        )
      bsj-cards.must-pay = bsj-cards.must-pay + (if sj-cards.saldo < 0 then (- sj-cards.saldo) else 0)
      bsj-cards.pay = bsj-cards.pay + (if avail dis-host
                                       then (if p-curr-type = 'rubl':U
                                             then dis-host.pay-tot-rubl
                                             else dis-host.pay-tot-base)
                                       else 0)
      bsj-cards.obj-qnty = bsj-cards.obj-qnty + 1
      .
      if dcardmode = "LIST"
      or dcardmode = "ONE" then do:
        assign
        sj-cards.d-pcntchr = get-d-pcntdc-list ( buffer dc-list
                                      ,input p-host-code
                                      ,input obj-list.obj-type
                                      ,input obj-list.obj-code
                                      ,input 'def-pcnt':U
                                      ,output loc-d-pcnt).
      end.
      else do:
        assign
        sj-cards.d-pcntchr = get-d-pcnt ( buffer ub.dis-card
                                      ,input p-host-code
                                      ,input obj-list.obj-type
                                      ,input obj-list.obj-code
                                      ,input 'def-pcnt':U
                                      ,output loc-d-pcnt).
      end.
    end.
    if p-curr-type = 'rubl':U then do:
      assign
      sj-cards.tot = sj-cards.tot + dis-obj.gds-tot-rubl + dis-obj.sum-tot-rubl
      sj-cards.disc = sj-cards.disc + dis-obj.gds-dis-rubl +  dis-obj.sum-dis-rubl
      sj-cards.netto = sj-cards.netto + (dis-obj.gds-tot-rubl + dis-obj.sum-tot-rubl) -
                                        (dis-obj.gds-dis-rubl +  dis-obj.sum-dis-rubl)
      sj-cards.instant-pay = sj-cards.instant-pay + dis-obj.pay-tot-rubl
      sj-cards.credit-pay = sj-cards.credit-pay + (dis-obj.gds-tot-rubl + dis-obj.sum-tot-rubl) -
                                                  (dis-obj.gds-dis-rubl +  dis-obj.sum-dis-rubl) -
                                                  dis-obj.pay-tot-rubl
      sj-cards.num-chk = sj-cards.num-chk + dis-obj.num-chk
      sj-cards.obj-qnty = if sj-cards.obj-qnty = 0
                          then dis-obj.obj-code
                          else (- 1)
      .
    end.
    else do:
      assign
      sj-cards.tot = sj-cards.tot + dis-obj.gds-tot-base + dis-obj.sum-tot-base
      sj-cards.disc = sj-cards.disc + dis-obj.gds-dis-base +  dis-obj.sum-dis-base
      sj-cards.netto = sj-cards.netto + (dis-obj.gds-tot-base + dis-obj.sum-tot-base) -
                                        (dis-obj.gds-dis-base +  dis-obj.sum-dis-base)
      sj-cards.instant-pay = sj-cards.instant-pay + dis-obj.pay-tot-base
      sj-cards.credit-pay = sj-cards.credit-pay + (dis-obj.gds-tot-base + dis-obj.sum-tot-base) -
                                                  (dis-obj.gds-dis-base +  dis-obj.sum-dis-base) -
                                                  dis-obj.pay-tot-base
      sj-cards.num-chk = sj-cards.num-chk + dis-obj.num-chk
      sj-cards.obj-qnty = if sj-cards.obj-qnty = 0
                          then dis-obj.obj-code
                          else (- 1)
      .
    end.
    if (t-legacy or t-subsid)
    then do:
      if t-legacy and not t-subsid then do:
        find first legacy-obj no-lock where
                  legacy-obj.obj-type = dis-obj.obj-type
              AND legacy-obj.obj-code = dis-obj.obj-code
          AND legacy-obj.card-num-chr = temp-dis-card.first-card
          no-error .
        if not available legacy-obj then do:
          create legacy-obj.
          assign
          legacy-obj.obj-type = dis-obj.obj-type
          legacy-obj.obj-code = dis-obj.obj-code
          legacy-obj.card-num-chr = temp-dis-card.first-card
          legacy-obj.first-card = temp-dis-card.first-card
          legacy-obj.first-main-card = temp-dis-card.first-main-card
          legacy-obj.main-card = temp-dis-card.main-card
          .
          find last osn_dis-card no-lock where
          osn_dis-card.first-card = legacy-obj.first-card use-index isourced no-error.
          if not available osn_dis-card then do:
            message
            substitute("Не найдена текущая карта цепочки карт с ПЕРВОЙ КАРТОЙ = &1 для карты &2"
                       ,legacy-obj.first-card
                       ,dis-obj.d-card
                       )
            view-as alert-box .
            assign
            legacy-obj.d-card = dis-obj.d-card
            legacy-obj.d-pcnt = 0
            legacy-obj.d-pcntchr = "?"
            .
          end.
          else do:
            assign
            legacy-obj.d-card = osn_dis-card.d-card
            legacy-obj.d-pcnt = osn_dis-card.d-pcnt
            .
            assign
            legacy-obj.d-pcntchr = get-d-pcnt(buffer osn_dis-card
                                            ,input p-host-code
                                            ,input obj-list.obj-type
                                            ,input obj-list.obj-code
                                            ,input 'def-pcnt':U
                                            ,output loc-d-pcnt).
            .
          end.
        end.
      end.
      if not t-legacy and t-subsid then do:
        find first legacy-obj no-lock where
                  legacy-obj.obj-type = dis-obj.obj-type
              AND legacy-obj.obj-code = dis-obj.obj-code
              AND legacy-obj.card-num-chr = temp-dis-card.main-card
              no-error .
        if not available legacy-obj then do:
          create legacy-obj.
          assign
          legacy-obj.obj-type = dis-obj.obj-type
          legacy-obj.obj-code = dis-obj.obj-code
          legacy-obj.card-num-chr = temp-dis-card.main-card
          legacy-obj.main-card = temp-dis-card.main-card
          legacy-obj.first-card = temp-dis-card.first-card
          legacy-obj.first-main-card = temp-dis-card.first-main-card
          .
          find first osn_dis-card no-lock where
          osn_dis-card.d-card = legacy-obj.main-card use-index isourced no-error .
          if not available osn_Dis-card then do:
            message
            substitute("Не найдена ОСНОВНАЯ карта &1 для карты &2"
                       ,temp-dis-card.main-card
                       ,dis-obj.d-card )
            view-as alert-box .
            assign
            legacy-obj.d-card = dis-obj.main-card
            legacy-obj.d-pcnt = 0
            legacy-obj.d-pcntchr = "?"
            .
          end.
          else do:
            assign
            legacy-obj.d-card = osn_dis-card.d-card
            legacy-obj.d-pcnt = osn_dis-card.d-pcnt
            .
            legacy-obj.d-pcntchr = get-d-pcnt(buffer osn_dis-card
                                            ,input p-host-code
                                            ,input obj-list.obj-type
                                            ,input obj-list.obj-code
                                            ,input 'def-pcnt':U
                                            ,output loc-d-pcnt)
            .
          end.
        end.
      end.
      if t-legacy and t-subsid then do:
        find first legacy-obj no-lock where
                  legacy-obj.obj-type = dis-obj.obj-type
              AND legacy-obj.obj-code = dis-obj.obj-code
              AND legacy-obj.card-num-chr = temp-dis-card.first-main-card
              no-error .
        if not available legacy-obj then do:
          create legacy-obj.
          assign
          legacy-obj.obj-type = dis-obj.obj-type
          legacy-obj.obj-code = dis-obj.obj-code
          legacy-obj.card-num-chr = temp-dis-card.first-main-card
          legacy-obj.first-main-card = temp-dis-card.first-main-card
          legacy-obj.first-card = temp-dis-card.first-card
          legacy-obj.main-card = temp-dis-card.main-card
          .
          find last osn_dis-card no-lock where
          osn_dis-card.first-card = legacy-obj.first-card
          and osn_dis-card.is-subsid = no
          use-index isourced no-error .
          if not available osn_dis-card then do:
            message
            substitute("Не найдена текущая ПЕРВАЯ ОСНОВНАЯ карта &1 для карты &2"
                       ,temp-dis-card.first-card
                       ,dis-obj.d-card )
            view-as alert-box .
            assign
            legacy-obj.d-card = dis-obj.first-card
            legacy-obj.d-pcnt = 0
            legacy-obj.d-pcntchr = "?"
            .
          end.
          else do:
            assign
            legacy-obj.d-card = osn_dis-card.d-card
            legacy-obj.d-pcnt = osn_dis-card.d-pcnt
            .
            legacy-obj.d-pcntchr = get-d-pcnt(buffer osn_dis-card
                                            ,input p-host-code
                                            ,input obj-list.obj-type
                                            ,input obj-list.obj-code
                                            ,input 'def-pcnt':U
                                            ,output loc-d-pcnt)
            .
          end.
        end.
      end.
      assign
      legacy-obj.gds-tot-rubl = legacy-obj.gds-tot-rubl + dis-obj.gds-tot-rubl + dis-obj.sum-tot-rubl
      legacy-obj.gds-dis-rubl = legacy-obj.gds-dis-rubl + dis-obj.gds-dis-rubl + dis-obj.sum-dis-rubl
      legacy-obj.pay-tot-rubl = legacy-obj.pay-tot-rubl + dis-obj.pay-tot-rubl
      legacy-obj.gds-tot-base = legacy-obj.gds-tot-base + dis-obj.gds-tot-base + dis-obj.sum-tot-base
      legacy-obj.pay-tot-base = legacy-obj.pay-tot-base + dis-obj.pay-tot-base
      legacy-obj.gds-dis-base = legacy-obj.gds-dis-base + dis-obj.gds-dis-base + dis-obj.sum-dis-base
      legacy-obj.num-chk      = legacy-obj.num-chk      + dis-obj.num-chk
      .
      assign
      sj-cards.last-card = legacy-obj.d-card
      .
    end.
    if p-sort-mode = "group":U then do:
      if p-curr-type = 'rubl':U then do:
          assign                                                                                                                                  sj-groups.tot = sj-groups.tot + dis-obj.gds-tot-rubl + dis-obj.sum-tot-rubl                                         sj-groups.disc = sj-groups.disc + dis-obj.gds-dis-rubl +  dis-obj.sum-dis-rubl                                      sj-groups.netto = sj-groups.netto + (dis-obj.gds-tot-rubl + dis-obj.sum-tot-rubl) -                                                                   (dis-obj.gds-dis-rubl +  dis-obj.sum-dis-rubl)                                    sj-groups.instant-pay = sj-groups.instant-pay + dis-obj.pay-tot-rubl                                               sj-groups.credit-pay = sj-groups.credit-pay + (dis-obj.gds-tot-rubl + dis-obj.sum-tot-rubl) -                                                                   (dis-obj.gds-dis-rubl +  dis-obj.sum-dis-rubl) -                                                                    dis-obj.pay-tot-rubl                                                   sj-groups.num-chk = sj-groups.num-chk + dis-obj.num-chk                                                           sj-groups.cards-qnty = sj-groups.cards-qnty + 1                                                                   sj-groups.pay = 0                                                                                                 sj-groups.must-pay = 0                                                                                            sj-groups.saldo = 0                                                                                               sj-groups.obj-qnty = (if sj-groups.obj-qnty = 0 then dis-obj.obj-code else (- 1))                                 bsj-groups.tot = bsj-groups.tot + dis-obj.gds-tot-rubl + dis-obj.sum-tot-rubl                                       bsj-groups.disc = bsj-groups.disc + dis-obj.gds-dis-rubl +  dis-obj.sum-dis-rubl                                    bsj-groups.netto = bsj-groups.netto + (dis-obj.gds-tot-rubl + dis-obj.sum-tot-rubl) -                                                                 (dis-obj.gds-dis-rubl +  dis-obj.sum-dis-rubl)                                    bsj-groups.instant-pay = bsj-groups.instant-pay +  dis-obj.pay-tot-rubl                                            bsj-groups.credit-pay = bsj-groups.credit-pay + (dis-obj.gds-tot-rubl + dis-obj.sum-tot-rubl) -                                                                 (dis-obj.gds-dis-rubl +  dis-obj.sum-dis-rubl) -                                                                    dis-obj.pay-tot-rubl                                                   bsj-groups.num-chk = bsj-groups.num-chk + dis-obj.num-chk                                                         bsj-groups.cards-qnty = bsj-groups.cards-qnty + (if new-card then 1 else 0)                                       bsj-groups.saldo = bsj-groups.saldo + (if new-card then sj-cards.saldo else 0)                                    bsj-groups.must-pay = bsj-groups.must-pay + (if new-card then sj-cards.must-pay else 0)                           bsj-groups.pay = bsj-groups.pay +  (if new-card then sj-cards.pay else 0)                                         bsj-groups.obj-qnty = (if bsj-groups.obj-qnty = 0 then dis-obj.obj-code else (- 1)).
      end.
      else do:
          assign                                                                                                                                  sj-groups.tot = sj-groups.tot + dis-obj.gds-tot-base + dis-obj.sum-tot-base                                         sj-groups.disc = sj-groups.disc + dis-obj.gds-dis-base +  dis-obj.sum-dis-base                                      sj-groups.netto = sj-groups.netto + (dis-obj.gds-tot-base + dis-obj.sum-tot-base) -                                                                   (dis-obj.gds-dis-base +  dis-obj.sum-dis-base)                                    sj-groups.instant-pay = sj-groups.instant-pay + dis-obj.pay-tot-base                                               sj-groups.credit-pay = sj-groups.credit-pay + (dis-obj.gds-tot-base + dis-obj.sum-tot-base) -                                                                   (dis-obj.gds-dis-base +  dis-obj.sum-dis-base) -                                                                    dis-obj.pay-tot-base                                                   sj-groups.num-chk = sj-groups.num-chk + dis-obj.num-chk                                                           sj-groups.cards-qnty = sj-groups.cards-qnty + 1                                                                   sj-groups.pay = 0                                                                                                 sj-groups.must-pay = 0                                                                                            sj-groups.saldo = 0                                                                                               sj-groups.obj-qnty = (if sj-groups.obj-qnty = 0 then dis-obj.obj-code else (- 1))                                 bsj-groups.tot = bsj-groups.tot + dis-obj.gds-tot-base + dis-obj.sum-tot-base                                       bsj-groups.disc = bsj-groups.disc + dis-obj.gds-dis-base +  dis-obj.sum-dis-base                                    bsj-groups.netto = bsj-groups.netto + (dis-obj.gds-tot-base + dis-obj.sum-tot-base) -                                                                 (dis-obj.gds-dis-base +  dis-obj.sum-dis-base)                                    bsj-groups.instant-pay = bsj-groups.instant-pay +  dis-obj.pay-tot-base                                            bsj-groups.credit-pay = bsj-groups.credit-pay + (dis-obj.gds-tot-base + dis-obj.sum-tot-base) -                                                                 (dis-obj.gds-dis-base +  dis-obj.sum-dis-base) -                                                                    dis-obj.pay-tot-base                                                   bsj-groups.num-chk = bsj-groups.num-chk + dis-obj.num-chk                                                         bsj-groups.cards-qnty = bsj-groups.cards-qnty + (if new-card then 1 else 0)                                       bsj-groups.saldo = bsj-groups.saldo + (if new-card then sj-cards.saldo else 0)                                    bsj-groups.must-pay = bsj-groups.must-pay + (if new-card then sj-cards.must-pay else 0)                           bsj-groups.pay = bsj-groups.pay +  (if new-card then sj-cards.pay else 0)                                         bsj-groups.obj-qnty = (if bsj-groups.obj-qnty = 0 then dis-obj.obj-code else (- 1)).
      end.
  end.
end.
end procedure.
