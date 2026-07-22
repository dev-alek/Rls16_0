block-level on error undo, throw.
using ibs.th.gbl.gbl-hndllib from propath.
define variable vss-revision    as character no-undo initial "$Revision: f29df1d5f130, 3104, rls $":U .
define variable vss-author      as character no-undo initial "$Author: DRuban $":U .
define variable vss-date        as character no-undo initial "$Date: 2022/08/09 06:15:01 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: lib-trn4.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: str/lib-trn4.p $":U .
define variable vss-description as character no-undo initial "библиотека процедур для работы со складскими документами (4)":U .
define temp-table tt-techLoss
field temperatura as decimal
field masdol as decimal
field coef as decimal
.
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
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function usrfulnf returns character ( input p-user-id as character):
define variable v-user-name as character no-undo .
define variable vss-include-info1 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run usrfulnm in g#library
  (input  p-user-id
  ,output v-user-name
  ) no-error .
if error-status:error
or v-user-name = ""
then do:
  return p-user-id.
end.
else do:
  return v-user-name.
end.
end function.
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
define temp-table lib-trn_ret-doc       no-undo like ub.trn-doc.
define temp-table lib-trn_ret-line      no-undo like ub.doc-line
  field cst-code                like ub.trn-doc.cst-code
  field part-code               like ub.parts.part-code
  .
define temp-table lib-trn_ret-line-attr no-undo like ub.doc-line-attr.
define temp-table lib-trn_ret-dtl       no-undo like ub.gds-dtl.
define temp-table lib-trn_ret-parts     no-undo like ub.parts.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  temp-table gds-list no-undo like ub.goods
  field qnty   as decimal
  field to-del as logical
  field order-num as integer
  field to-sel as logical
  field promo-code as character
  field ActionId  as int64
  field db-num as integer
  index art  is primary unique artic prod-type prod-code
  index code is         unique gds-code
  index oi order-num
  index isel to-sel
  .
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define    temp-table gds-list-hist no-undo
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
define variable par-type          as character no-undo.
define variable v-value-character as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .
define variable v-value-logical   as logical   no-undo .
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE VARIABLE v-S_CONTRACT               AS CHARACTER NO-UNDO INITIAL "".
DEFINE VARIABLE v-S_CODE_LAST_MASTER_NUM   AS CHARACTER NO-UNDO INITIAL "".
DEFINE VARIABLE v-DELIM_CHR_3              AS CHARACTER NO-UNDO INITIAL "".
ASSIGN
   v-S_CONTRACT                = "Contract":U
   v-S_CODE_LAST_MASTER_NUM    = "LastMasterNum":U
   v-DELIM_CHR_3               = ","
   .
DEFINE VARIABLE i-gl-Host-Code      AS INTEGER NO-UNDO INITIAL 0.
DEFINE VARIABLE i-gl-Contract-Code  AS INTEGER NO-UNDO INITIAL 0.
DEFINE VARIABLE i-gl-Extent3        AS INTEGER NO-UNDO INITIAL 0 EXTENT 3.
FUNCTION Can-Find-Spec RETURN LOGICAL (
   INPUT iHost-Code    AS INTEGER,
   INPUT iContract-Num AS INTEGER,
   INPUT iGds-Code     AS INTEGER ):
   DEFINE BUFFER buf_Spec FOR ub.Contract-Specif.
   DEFINE VARIABLE iTmp-Host-Code     AS INTEGER NO-UNDO INITIAL 0.
   DEFINE VARIABLE iTmp-Contract-Num  AS INTEGER NO-UNDO INITIAL 0.
   DEFINE VARIABLE iTmp-Extent3       AS INTEGER NO-UNDO INITIAL 0 EXTENT 3.
   DEFINE VARIABLE lRet               AS LOGICAL NO-UNDO INITIAL FALSE.
   RUN MS-Contract-EXTENT-3 IN THIS-PROCEDURE(
       INPUT  iHost-Code,
       INPUT  iContract-Num,
       OUTPUT iTmp-Extent3
       ).
   IF iTmp-Extent3[1] = 2 THEN DO:
      ASSIGN
         iTmp-Host-Code      = iTmp-Extent3[2]
         iTmp-Contract-Num   = iTmp-Extent3[3]
         .
   END. ELSE DO:
      ASSIGN
         iTmp-Host-Code      = iHost-Code
         iTmp-Contract-Num   = iContract-Num
         .
   END.
   IF iGds-Code = ? THEN DO:
      ASSIGN
         lRet = CAN-FIND(FIRST buf_Spec NO-LOCK WHERE
                               buf_Spec.Host-Code     = iTmp-Host-Code
                           AND buf_Spec.Contract-Num  = iTmp-Contract-Num
                        ).
   END. ELSE DO:
         lRet = CAN-FIND(FIRST buf_Spec NO-LOCK WHERE
                               buf_Spec.Host-Code     = iTmp-Host-Code
                           AND buf_Spec.Contract-Num  = iTmp-Contract-Num
                           AND buf_Spec.Gds-Code      = iGds-Code
                         ).
   END.
   RETURN (lRet).
END FUNCTION.
PROCEDURE MS-Contract-EXTENT-3:
   DEFINE INPUT  PARAMETER i-Host-Code     AS INTEGER NO-UNDO.
   DEFINE INPUT  PARAMETER i-Contract-Code AS INTEGER NO-UNDO.
   DEFINE OUTPUT PARAMETER i-Ret           AS INTEGER NO-UNDO EXTENT 3 INITIAL 0.
   DEFINE BUFFER buf_Ext-Classif FOR ub.Ext-Classif.
   DEFINE BUFFER buf_Cont        FOR ub.Contract.
   DEFINE BUFFER buf_Cont-2      FOR ub.Contract.
   FIND FIRST buf_Cont-2 WHERE
              buf_Cont-2.Host-Code      = i-Host-Code
          AND buf_Cont-2.Contract-Code  = i-Contract-Code
        NO-LOCK NO-ERROR.
   IF NOT AVAILABLE buf_Cont-2 THEN DO:
      RETURN.
   END.
   FOR FIRST buf_Ext-Classif WHERE
             buf_Ext-Classif.Classif-name = v-S_CONTRACT
        AND  buf_Ext-Classif.CharKey_One  = STRING(i-Host-code) + v-DELIM_CHR_3 +
                                            STRING(i-Contract-code)
        AND  buf_Ext-classif.db-num       = buf_Cont-2.Db-num
       NO-LOCK,
       EACH buf_Cont WHERE
            buf_Cont.Host-code     = INTEGER(ENTRY(1, buf_Ext-classif.charKey_Two, v-DELIM_CHR_3 ))
        AND buf_Cont.Contract-code = INTEGER(ENTRY(2, buf_Ext-classif.charKey_Two, v-DELIM_CHR_3))
       NO-LOCK:
       ASSIGN
          i-Ret[1] = 1
          i-Ret[2] = buf_Cont.Host-code
          i-Ret[3] = buf_Cont.Contract-code
          .
       LEAVE.
   END.
   IF i-Ret[1] <> 1 THEN DO:
      FOR FIRST buf_Ext-Classif WHERE
                buf_Ext-Classif.Classif-name = v-S_CONTRACT
           AND  buf_Ext-Classif.CharKey_Two  = STRING(i-Host-code) + v-DELIM_CHR_3 +
                                               STRING(i-Contract-code)
           AND  buf_Ext-classif.db-num       = buf_Cont-2.Db-num
          NO-LOCK,
          EACH buf_Cont WHERE
               buf_Cont.Host-code     = INTEGER(ENTRY(1, buf_Ext-classif.charKey_One, v-DELIM_CHR_3))
           AND buf_Cont.Contract-code = INTEGER(ENTRY(2, buf_Ext-classif.charKey_One, v-DELIM_CHR_3))
          NO-LOCK:
          ASSIGN
             i-Ret[1] = 2
             i-Ret[2] = buf_Cont.Host-code
             i-Ret[3] = buf_Cont.Contract-code
             .
          LEAVE.
      END.
   END.
   RETURN.
END PROCEDURE.
function is-mes returns logical
        (input doc-code as character):
define variable result as logical no-undo init no.
find first ub.inv-doc-attr no-lock where
ub.inv-doc-attr.doc-code = doc-code and
ub.inv-doc-attr.attr-code = "notMes" and
ub.inv-doc-attr.attr-value = string(true) no-error .
if available (ub.inv-doc-attr) then result = true.
return result.
end function.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#trdcalib as handle no-undo.
procedure placelib_write-attr:
define input  parameter p-code     like ub.place-attr.attr-code .
define input  parameter p-obj-code like ub.place-attr.obj-code .
define input  parameter p-obj-type like ub.place-attr.obj-type .
define input  parameter p-pl-code  like ub.place-attr.pl-code .
define input  parameter p-value    like ub.place-attr.attr-value .
define output parameter p-ok       as logical.
define buffer buf_place-attr for ub.place-attr .
  do on error undo, return error return-value :
     p-ok = false.
     find first buf_place-attr exclusive-lock where buf_place-attr.attr-code   = p-code
                                                and buf_place-attr.obj-code    = p-obj-code
                                                and buf_place-attr.obj-type    = p-obj-type
                                                and buf_place-attr.pl-code     = p-pl-code no-error.
     if not available buf_place-attr then do :
        create buf_place-attr.
        assign
          buf_place-attr.attr-code   = p-code
          buf_place-attr.attr-value  = p-value
          buf_place-attr.obj-code    = p-obj-code
          buf_place-attr.obj-type    = p-obj-type
          buf_place-attr.pl-code     = p-pl-code
        .
        p-ok = true.
     end.
     else do:
        buf_place-attr.attr-value  = p-value .
        p-ok = true.
     end.
  end.
end.
procedure placelib_get-attr:
define input  parameter  p-code     like ub.place-attr.attr-code .
define input  parameter  p-obj-code like ub.place-attr.obj-code .
define input  parameter  p-obj-type like ub.place-attr.obj-type .
define input  parameter  p-pl-code  like ub.place-attr.pl-code .
define output parameter  p-value    like ub.place-attr.attr-value .
define output parameter  p-ok       as logical.
define buffer buf_place-attr for ub.place-attr .
  do on error undo, return error return-value :
     p-ok = false.
     find first buf_place-attr no-lock where buf_place-attr.attr-code   = p-code
                                                and buf_place-attr.obj-code    = p-obj-code
                                                and buf_place-attr.obj-type    = p-obj-type
                                                and buf_place-attr.pl-code     = p-pl-code no-error.
     if available buf_place-attr then do :
       p-value = buf_place-attr.attr-value.
       p-ok = true.
     end.
     else do :
       p-ok = false.
     end.
  end.
end.
procedure placelib_del-attr:
define input parameter  p-code     like ub.place-attr.attr-code .
define input parameter  p-obj-code like ub.place-attr.obj-code .
define input parameter  p-obj-type like ub.place-attr.obj-type .
define input parameter  p-pl-code  like ub.place-attr.pl-code .
define input parameter  p-value    like ub.place-attr.attr-value .
define output parameter p-ok       as logical.
define buffer buf_place-attr for ub.place-attr .
  do on error undo, return error return-value :
     p-ok = false.
     find first buf_place-attr exclusive-lock where buf_place-attr.attr-code   = p-code
                                                and buf_place-attr.obj-code    = p-obj-code
                                                and buf_place-attr.obj-type    = p-obj-type
                                                and buf_place-attr.pl-code     = p-pl-code no-error.
     if available buf_place-attr then do :
        delete buf_place-attr.
        p-ok = true.
     end.
  end.
end.
FUNCTION get-input-type RETURNS CHARACTER
  ( p-rec as recid ) :
  def    buffer loc-rvs-doc       for ub.rvs-doc  .
  define buffer loc-rvs-line      for ub.rvs-line .
  define buffer loc-rvs-line-attr for ub.rvs-line-attr .
  define variable v-doc-input-type  as character no-undo .
  define variable v-input-type-list as character no-undo .
  find first loc-rvs-doc no-lock where  recid ( loc-rvs-doc ) = p-rec no-error  .
  for each loc-rvs-line no-lock where loc-rvs-line.rvs-code = loc-rvs-doc.rvs-code :
    find first loc-rvs-line-attr no-lock
      where loc-rvs-line-attr.obj-code  = loc-rvs-line.obj-code
      and loc-rvs-line-attr.obj-type  = loc-rvs-line.obj-type
      and loc-rvs-line-attr.gds-code  = loc-rvs-line.gds-code
      and loc-rvs-line-attr.pl-code   = loc-rvs-line.pl-code
      and loc-rvs-line-attr.rvs-code  = loc-rvs-line.rvs-code
      and loc-rvs-line-attr.attr-code = 'input-type'
      no-error.
    if available loc-rvs-line-attr
      then
    do :
      v-input-type-list = v-input-type-list + ',' + loc-rvs-line-attr.attr-value .
    end.
  end.
  if trim(v-input-type-list) = ""
    then
  do :
    for each loc-rvs-line no-lock where loc-rvs-line.rvs-code = loc-rvs-doc.rvs-code :
      find first loc-rvs-line-attr no-lock
        where loc-rvs-line-attr.obj-code  = loc-rvs-line.obj-code
        and loc-rvs-line-attr.obj-type  = loc-rvs-line.obj-type
        and loc-rvs-line-attr.gds-code  = loc-rvs-line.gds-code
        and loc-rvs-line-attr.pl-code   = loc-rvs-line.pl-code
        and loc-rvs-line-attr.rvs-code  = loc-rvs-line.rvs-code
        and loc-rvs-line-attr.attr-code = 'input-type-p'
        no-error.
      if available loc-rvs-line-attr
        then
      do :
        v-input-type-list = v-input-type-list + ',' + loc-rvs-line-attr.attr-value .
      end.
      find first loc-rvs-line-attr no-lock
        where loc-rvs-line-attr.obj-code  = loc-rvs-line.obj-code
        and loc-rvs-line-attr.obj-type  = loc-rvs-line.obj-type
        and loc-rvs-line-attr.gds-code  = loc-rvs-line.gds-code
        and loc-rvs-line-attr.pl-code   = loc-rvs-line.pl-code
        and loc-rvs-line-attr.rvs-code  = loc-rvs-line.rvs-code
        and loc-rvs-line-attr.attr-code = 'input-type-t'
        no-error.
      if available loc-rvs-line-attr
        then
      do :
        v-input-type-list = v-input-type-list + ',' + loc-rvs-line-attr.attr-value .
      end.
      find first loc-rvs-line-attr no-lock
        where loc-rvs-line-attr.obj-code  = loc-rvs-line.obj-code
        and loc-rvs-line-attr.obj-type  = loc-rvs-line.obj-type
        and loc-rvs-line-attr.gds-code  = loc-rvs-line.gds-code
        and loc-rvs-line-attr.pl-code   = loc-rvs-line.pl-code
        and loc-rvs-line-attr.rvs-code  = loc-rvs-line.rvs-code
        and loc-rvs-line-attr.attr-code = 'input-type-l'
        no-error.
      if available loc-rvs-line-attr
        then
      do :
        v-input-type-list = v-input-type-list + ',' + loc-rvs-line-attr.attr-value .
      end.
    end.
  end .
  if can-do(v-input-type-list, 'а')
    and not can-do(v-input-type-list, 'ф')
    and not can-do(v-input-type-list, 'ак')
    and not can-do(v-input-type-list, 'фк')
    and not can-do(v-input-type-list, 'п')
    then v-doc-input-type = 'а'.
  if can-do(v-input-type-list, 'ф')
    and not can-do(v-input-type-list, 'а')
    and not can-do(v-input-type-list, 'ак')
    and not can-do(v-input-type-list, 'фк')
    and not can-do(v-input-type-list, 'п')
    then v-doc-input-type = 'ф'.
  if  not can-do(v-input-type-list, 'ф')
    and can-do(v-input-type-list, 'ак')
    and not can-do(v-input-type-list, 'п')
    then v-doc-input-type = 'ак'.
  if ((can-do(v-input-type-list, 'ф')
    or can-do(v-input-type-list, 'п'))
    and can-do(v-input-type-list, 'а'))
    or can-do(v-input-type-list, 'фк')
    then v-doc-input-type = 'фк'.
  if can-do(v-input-type-list, 'р')
    and not can-do(v-input-type-list, 'а')
    and not can-do(v-input-type-list, 'ф')
    and not can-do(v-input-type-list, 'к')
    and not can-do(v-input-type-list, 'п')
    then v-doc-input-type = 'р'.
  if v-doc-input-type = 'а'
    and can-do(v-input-type-list, 'р')
    then v-doc-input-type = 'ак'.
  if v-doc-input-type = 'ф'
    and can-do(v-input-type-list, 'р')
    then v-doc-input-type = 'фк'.
  if v-doc-input-type = ? then v-doc-input-type = '' .
  return v-doc-input-type .
END FUNCTION.
FUNCTION getNunHoses RETURNS integer
  (p-doc-code as character) :
  define variable vGateValve as character no-undo.
  define variable vOk        as logical   no-undo.
  define variable vNumHoses  as integer   no-undo init 0.
  define buffer buf_doc-pl        for ub.doc-pl.
  define buffer buf_place         for ub.place.
  define buffer buf_doc-line      for ub.doc-line.
  define buffer buf_goods         for ub.goods.
  define buffer buf_doc-line-attr for ub.doc-line-attr.
  find first buf_doc-pl where
    buf_doc-pl.out-code = p-doc-code
    no-lock no-error.
  if avail buf_doc-pl then
    find first buf_place where
      buf_place.obj-type = buf_doc-pl.obj-type
      and buf_place.obj-code = buf_doc-pl.obj-code
      and buf_place.pl-code  = buf_doc-pl.pl-code
      no-lock no-error.
  if avail buf_place then
  do:
    run placelib_get-attr  (
      input "place-gate-valve"
      ,input buf_place.obj-code
      ,input buf_place.obj-type
      ,input buf_place.pl-code
      ,output vGateValve
      ,output vOk
      ) no-error.
    if not vOk or not logical(vGateValve) then
      vNumHoses = 1.
    else
    do:
      for first buf_doc-line where
        buf_doc-line.doc-code = p-doc-code
        no-lock,
        first buf_goods where
        buf_goods.artic     =  buf_doc-line.artic
        and buf_goods.prod-code =  buf_doc-line.prod-code
        and buf_goods.prod-type =  buf_doc-line.prod-type
        no-lock,
        first buf_doc-line-attr where
        buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = buf_goods.gds-code
        and buf_doc-line-attr.attr-code = "connect-hoses"
        no-lock:
        vNumHoses = if buf_doc-line-attr.attr-value = "yes" then 1 else 0.
      end.
    end.
  end.
  RETURN vNumHoses.
END FUNCTION.
function tempRas RETURNS decimal
  (doc-code as character,
  gds-code as integer):
  define variable v-temp as decimal   no-undo .
  define variable ii     as integer   no-undo .
  define variable is-rvd as character no-undo .
  define buffer buf_rvs-line for ub.rvs-line .
  define buffer buf_rvs-doc  for ub.rvs-doc .
  for each buf_rvs-doc no-lock where buf_rvs-doc.out-code = doc-code and
    buf_rvs-doc.rvs-type = 'после_док':U :
    is-rvd = get-input-type(recid(buf_rvs-doc)) .
    for each buf_rvs-line no-lock where buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code and
      buf_rvs-line.gds-code = gds-code:
      ii = ii + 1 .
      v-temp = v-temp + if is-rvd = 'а' then buf_rvs-line.temperature else buf_rvs-line.state-temperature .
    end.
    return v-temp / ii.
  end.
  return 0 .
end function.
function masRas RETURNS decimal
  (doc-code as character,
  gds-code as integer):
  define variable v-masDol as decimal no-undo .
  define buffer buf_doc-line-attr for ub.doc-line-attr .
  for first buf_doc-line-attr exclusive-lock where buf_doc-line-attr.doc-code = doc-code
    and buf_doc-line-attr.gds-code = gds-code
    and buf_doc-line-attr.attr-code = "propan-perc":
    v-masDol = decimal (buf_doc-line-attr.attr-value) .
  end.
  return v-masDol .
end function.
function autoAttr RETURNS character
  (doc-code as character,
  attr-code as character):
  define buffer buf_doc-attr       for ub.doc-attr .
  define buffer buf_auto-tank-attr for ub.auto-tank-attr .
  find first buf_doc-attr no-lock where buf_doc-attr.attr-code = 'car-num':U
    and buf_doc-attr.doc-code = doc-code no-error .
  if available (buf_doc-attr) then
  do:
    find first buf_auto-tank-attr no-lock where
      buf_auto-tank-attr.attr-code = attr-code and
      buf_auto-tank-attr.auto-num = buf_doc-attr.attr-value no-error .
    if available (buf_auto-tank-attr) then return buf_auto-tank-attr.attr-value .
  end.
  return "" .
end function.
function volumeGF RETURNS decimal
  (doc-code as character,
  gds-code as integer):
  define buffer buf_goods    for ub.goods .
  define buffer buf_rvs-doc  for ub.rvs-doc .
  define buffer buf_rvs-line for ub.rvs-line .
  define variable volue     as decimal no-undo .
  define variable beforeVol as decimal no-undo .
  define variable afterVol  as decimal no-undo .
  find first buf_goods no-lock where buf_goods.gds-code = gds-code no-error .
  if available (buf_goods) then
  do:
    find first buf_rvs-doc no-lock where buf_rvs-doc.out-code = doc-code and
      buf_rvs-doc.rvs-type = 'перед_док':U no-error .
    if available (buf_rvs-doc) then
    do:
      for each buf_rvs-line no-lock where buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code and
        buf_rvs-line.gds-code = buf_goods.gds-code:
        beforeVol = beforeVol + buf_rvs-line.state-measure-qnty .
      end.
    end.
    find first buf_rvs-doc no-lock where buf_rvs-doc.out-code = doc-code and
      buf_rvs-doc.rvs-type = 'после_док':U no-error .
    if available (buf_rvs-doc) then
    do:
      for each buf_rvs-line no-lock where buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code and
        buf_rvs-line.gds-code = buf_goods.gds-code :
        if buf_rvs-line.state-measure-qnty = ? then
        afterVol = afterVol + buf_rvs-line.state-brutto-qnty .
        else
        afterVol = afterVol + buf_rvs-line.state-measure-qnty .
      end.
    end.
  end.
  volue = (afterVol - beforeVol) / 1000 .
  return volue .
end function.
procedure tp-rtr:
  DEFINE INPUT  PARAMETER sug-temp  AS INTEGER NO-UNDO .
  DEFINE INPUT  PARAMETER mass-prop AS INTEGER NO-UNDO .
  DEFINE OUTPUT PARAMETER ktp       AS DECIMAL NO-UNDO .
  DO:
    if     sug-temp >  -40 and sug-temp <= -20
      and mass-prop >   0 and mass-prop <= 50
      then ktp = 0.040 .
    if     sug-temp >  -40 and sug-temp <= -20
      and mass-prop >  50 and mass-prop <= 60
      then ktp = 0.050  .
    if     sug-temp >  -40 and sug-temp <= -20
      and mass-prop >  60
      then ktp = 0.060  .
    if      sug-temp  > -20 and sug-temp  <=  0
      and mass-prop >   0 and mass-prop <= 50
      then ktp = 0.070  .
    if      sug-temp  > -20 and sug-temp  <=  0
      and mass-prop >  50 and mass-prop <= 60
      then ktp = 0.080 .
    if      sug-temp > -20 and sug-temp <=  0
      and mass-prop > 60
      then ktp = 0.110 .
    if      sug-temp >    0 and sug-temp <=  20
      and mass-prop >   0 and mass-prop <= 50
      then ktp = 0.130    .
    if      sug-temp >    0 and sug-temp <=  20
      and mass-prop >  50 and mass-prop <= 60
      then ktp = 0.150        .
    if      sug-temp >   0  and sug-temp <= 20
      and mass-prop > 60
      then ktp = 0.2 .
    if      sug-temp >   20
      and mass-prop >   0 and mass-prop <= 50
      then ktp = 0.210  .
    if      sug-temp >   20
      and mass-prop >  50 and mass-prop <= 60
      then ktp = 0.240   .
    if  sug-temp >      20
      and mass-prop > 60
      then ktp = 0.310  .
  END.
END PROCEDURE.
procedure tp-arm:
  DEFINE INPUT  PARAMETER  sug-temp  AS INTEGER NO-UNDO .
  DEFINE INPUT  PARAMETER  mass-prop AS INTEGER NO-UNDO .
  DEFINE OUTPUT PARAMETER  ktp       AS DECIMAL NO-UNDO .
  DO:
    if     sug-temp  >  -40 and sug-temp <= -20
      and mass-prop >   0 and mass-prop <= 50
      then ktp = 0.040   .
    if     sug-temp >  -40 and sug-temp <= -20
      and mass-prop >  50 and mass-prop <= 60
      then ktp = 0.040   .
    if     sug-temp >  -40 and sug-temp <= -20
      and mass-prop >  60
      then ktp = 0.050       .
    if      sug-temp  > -20 and sug-temp  <=  0
      and mass-prop >   0 and mass-prop <= 50
      then ktp = 0.070       .
    if      sug-temp  > -20 and sug-temp  <=  0
      and mass-prop >  50 and mass-prop <= 60
      then ktp = 0.070  .
    if      sug-temp > -20 and sug-temp <=  0
      and mass-prop > 60
      then ktp = 0.100  .
    if      sug-temp  >   0 and sug-temp <=  20
      and mass-prop >   0 and mass-prop <= 50
      then ktp = 0.120    .
    if      sug-temp >    0 and sug-temp <=  20
      and mass-prop >  50 and mass-prop <= 60
      then ktp = 0.190    .
    if      sug-temp >    0  and sug-temp <=  20
      and mass-prop >  60
      then ktp = 0.220   .
    if      sug-temp >   20 and mass-prop >   0
      and mass-prop <= 50
      then ktp = 0.210   .
    if      sug-temp >   20
      and mass-prop >  50 and mass-prop <= 60
      then ktp = 0.240   .
    if      sug-temp >   20 and mass-prop >  60
      then ktp = 0.280   .
  END.
END PROCEDURE.
procedure tp-emp:
  DEFINE INPUT  PARAMETER  sug-temp  AS INTEGER NO-UNDO .
  DEFINE INPUT  PARAMETER  mass-prop AS INTEGER NO-UNDO .
  DEFINE INPUT  PARAMETER  length    AS INTEGER NO-UNDO .
  DEFINE OUTPUT PARAMETER  ktp       AS DECIMAL NO-UNDO .
  DO:
    if     sug-temp  > -40 AND sug-temp  <= -20
      and mass-prop >   0 and mass-prop <=  50
      and length    >=   0 and length    <=   7
      then ktp = 7.081    .
    if     sug-temp  >  -40 AND sug-temp  <= -20
      and mass-prop >    0 and mass-prop <=  50
      and length    >    7
      then ktp = 9.441   .
    if     sug-temp  >  -40 AND sug-temp  <= -20
      and mass-prop >   50 and mass-prop <=  60
      and length    >=    0 and length    <=   7
      then ktp = 7.087   .
    if     sug-temp  >  -40 AND sug-temp  <= -20
      and mass-prop >   50 and mass-prop <=  60
      and length    >    7
      then ktp = 9.449  .
    if     sug-temp  >  -40 AND sug-temp  <= -20
      and mass-prop >   60
      and length    >=    0 and length    <=   7
      then ktp = 7.099          .
    if     sug-temp  >  -40 AND sug-temp  <= -20
      and mass-prop >   60
      and length    >    7
      then ktp = 9.466    .
    if     sug-temp  >  -20 AND sug-temp  <=   0
      and mass-prop >    0 and mass-prop <=  50
      and length    >=    0 and length    <=   7
      then ktp = 6.793   .
    if     sug-temp  >  -20 AND sug-temp  <=   0
      and mass-prop >    0 and mass-prop <=  50
      and length    >    7
      then ktp = 9.057  .
    if     sug-temp  >  -20 AND sug-temp  <=   0
      and mass-prop >   50 and mass-prop <=  60
      and length    >=    0 and length    <=   7
      then ktp = 6.801   .
    if     sug-temp  >  -20 AND sug-temp  <=   0
      and mass-prop >   50 and mass-prop <=  60
      and length    >    7
      then ktp = 9.068  .
    if     sug-temp  >  -20 AND sug-temp  <=   0
      and mass-prop >   60
      and length    >=    0 and length    <=   7
      then ktp = 6.822   .
    if     sug-temp  >  -20 AND sug-temp  <=   0
      and mass-prop >   60
      and length    >    7
      then ktp = 9.095    .
    if     sug-temp  >    0 AND sug-temp  <=  20
      and mass-prop >    0 and mass-prop <=  50
      and length    >=    0 and length    <=   7
      then ktp = 6.550    .
    if     sug-temp  >    0 AND sug-temp  <=  20
      and mass-prop >    0 and mass-prop <=  50
      and length    >    7
      then ktp = 8.734   .
    if     sug-temp  >   0 AND sug-temp  <=  20
      and mass-prop >   50 and mass-prop <=  60
      and length    >=    0 and length    <=   7
      then ktp = 6.566 .
    if     sug-temp  >    0 AND sug-temp  <=  20
      and mass-prop >   50 and mass-prop <=  60
      and length    >    7
      then ktp = 8.755  .
    if    sug-temp  >     0 AND sug-temp  <=  20
      and mass-prop >   60
      and length    >=    0 and length    <=   7
      then ktp = 6.605 .
    if    sug-temp   >    0 AND sug-temp  <=  20
      and mass-prop >   60
      and length    >    7
      then ktp = 8.807  .
    if    sug-temp   >   20
      and mass-prop >    0 and mass-prop <=  50
      and length    >=    0 and length    <=   7
      then ktp = 6.294  .
    if    sug-temp   >   20
      and mass-prop >   50 and mass-prop <=  60
      and length    >=    0 and length    <=   7
      then ktp = 6.317  .
    if    sug-temp   >   20
      and mass-prop >   50 and mass-prop <=  60
      and length    >    7
      then ktp = 8.423   .
    if    sug-temp   >   20
      and mass-prop >   60
      and length    >=    0 and length    <=   7
      then ktp = 6.377    .
    if    sug-temp   >   20
      and mass-prop <=  60
      and length    >=    0 and length    >    7
      then ktp = 8.502   .
  END.
END PROCEDURE.
procedure tp-ret:
  DEFINE INPUT  PARAMETER  sug-temp  AS INTEGER NO-UNDO .
  DEFINE OUTPUT PARAMETER  ktp       AS DECIMAL NO-UNDO .
  DO:
    if sug-temp > -40 and sug-temp <= -20 then ktp = 3.630 .
    if sug-temp > -20 and sug-temp <=   0 then ktp = 3.350 .
    if sug-temp >   0 and sug-temp <=  20 then ktp = 3.110 .
    if sug-temp >  20                     then ktp = 2.910 .
  END.
END PROCEDURE.
procedure tp-chklv:
  DEFINE INPUT  PARAMETER  sug-temp  AS INTEGER NO-UNDO .
  DEFINE INPUT  PARAMETER  mass-prop AS INTEGER NO-UNDO .
  DEFINE OUTPUT PARAMETER  ktp       AS DECIMAL NO-UNDO .
  DO:
    if     sug-temp >  -40 and sug-temp <= -20
      and mass-prop >   0 and mass-prop <= 50
      then ktp = 0.940   .
    if  sug-temp >  -40 and sug-temp <= -20
      and mass-prop >  50 and mass-prop <= 60
      then ktp = 1.050   .
    if  sug-temp >  -40 and sug-temp <= -20
      and mass-prop >  60
      then ktp = 1.280   .
    if  sug-temp >  -20 and sug-temp <=   0
      and mass-prop >   0 and mass-prop <= 50
      then ktp = 1.510         .
    if  sug-temp >  -20 and sug-temp <=   0
      and mass-prop >  50 and mass-prop <= 60
      then ktp = 1.660   .
    if  sug-temp >  -20 and sug-temp <=   0
      and mass-prop >  60
      then ktp = 2.040  .
    if  sug-temp >   0 and sug-temp <=  20
      and mass-prop >  0 and mass-prop <= 50
      then ktp = 2.500    .
    if  sug-temp >    0 and sug-temp <=  20
      and mass-prop >  50 and mass-prop <= 60
      then ktp = 2.780   .
    if  sug-temp >    0 and sug-temp <=  20
      and mass-prop >  60
      then ktp = 3.450   .
    if  sug-temp >   20
      and mass-prop >   0 and mass-prop <= 50
      then ktp = 3.760 .
    if  sug-temp >   20
      and mass-prop >  50 and mass-prop <= 60
      then ktp = 4.160  .
    if  sug-temp  > 20
      and mass-prop > 60
      then ktp = 5.160  .
  END.
END PROCEDURE.
procedure doc-line-write:
  define input parameter doc-code as character no-undo .
  define input parameter attr-code as character no-undo .
  define input parameter gds-code as integer no-undo .
  define input parameter attr-value as character no-undo .
  find first ub.doc-line-attr exclusive-lock where ub.doc-line-attr.attr-code = attr-code
    and ub.doc-line-attr.doc-code = doc-code
    and ub.doc-line-attr.gds-code = gds-code no-error .
  if not available (ub.doc-line-attr) then
  do:
    create ub.doc-line-attr .
    assign
      ub.doc-line-attr.attr-code = attr-code
      ub.doc-line-attr.doc-code  = doc-code
      ub.doc-line-attr.gds-code  = gds-code
      .
  end.
  ub.doc-line-attr.attr-value = attr-value .
end procedure .
procedure doc-line-value:
  define input parameter doc-code as character no-undo .
  define input parameter attr-code as character no-undo .
  define input parameter gds-code as integer no-undo .
  define output parameter attr-value as character no-undo .
  find first ub.doc-line-attr exclusive-lock where ub.doc-line-attr.attr-code = attr-code
    and ub.doc-line-attr.doc-code = doc-code
    and ub.doc-line-attr.gds-code = gds-code no-error .
  if available (ub.doc-line-attr) then
  do:
    if ub.doc-line-attr.attr-value <> ? then attr-value = ub.doc-line-attr.attr-value .
  end.
end procedure .
procedure spr-sug:
  define input parameter doc-code as character no-undo .
  define input parameter reason-code as integer no-undo .
  define buffer buf_doc-pl   for ub.doc-pl .
  define buffer buf_doc-line for ub.doc-line .
  define buffer buf_doc-attr for ub.doc-attr .
  define buffer buf_trn-doc  for ub.trn-doc .
  define buffer buf_clients-attr for ub.clients-attr .
  define variable numHoses    as integer   no-undo .
  define variable vBlowdown   as decimal   no-undo .
  define variable vFittings   as decimal   no-undo .
  define variable vEmptying   as decimal   no-undo .
  define variable vRefund     as decimal   no-undo .
  define variable vCtrlvalve  as decimal   no-undo .
  define variable vTemp       as decimal   no-undo .
  define variable vMasDol     as decimal   no-undo .
  define variable vVolue      as decimal   no-undo .
  define variable is-rvd      as logical   no-undo .
  define variable lengthRukav as decimal   no-undo .
  define variable ktp         as decimal   no-undo .
  define variable valve       as logical   no-undo .
  define variable clear-ac    as logical   no-undo .
  define variable GNS         as character no-undo .
  define variable own-supp    as logical   no-undo .
  numHoses = getNunHoses(doc-code) .
  lengthRukav = decimal (autoAttr(doc-code,"con-sleeve")) .
  valve = if autoAttr(doc-code, "valve") = "" then false else logical(autoAttr(doc-code, "valve")) .
  find first buf_doc-attr no-lock where buf_doc-attr.attr-code = 'clear-ac':U and
    buf_doc-attr.doc-code = doc-code no-error .
  if available (buf_doc-attr) then clear-ac = logical (buf_doc-attr.attr-value) .
  find first buf_doc-attr no-lock where buf_doc-attr.attr-code = 'ptbobj':U and
    buf_doc-attr.doc-code = doc-code no-error .
  if available (buf_doc-attr) then GNS = buf_doc-attr.attr-value .
  for each buf_doc-line no-lock where buf_doc-line.doc-code = doc-code:
    find first ub.goods no-lock where ub.goods.artic = buf_doc-line.artic and
      ub.goods.prod-code = buf_doc-line.prod-code and
      ub.goods.prod-type = buf_doc-line.prod-type no-error .
    find first buf_trn-doc no-lock where buf_trn-doc.doc-code = doc-code no-error .
    if available (buf_trn-doc) then
    do:
      find first buf_clients-attr where buf_clients-attr.obj-type = buf_trn-doc.cli-type
        and buf_clients-attr.obj-code = buf_trn-doc.cli-code
        and buf_clients-attr.attr-code = 'own-supp':U no-lock no-error .
      if available (buf_clients-attr) then
        own-supp = logical(buf_clients-attr.attr-value).
      else own-supp = false .
    end.
    for first buf_doc-pl no-lock where buf_doc-pl.out-code = buf_doc-line.doc-code and
      buf_doc-pl.gds-code = ub.goods.gds-code:
      vTemp = tempRas(doc-code, ub.goods.gds-code) .
      vMasDol = masRas(doc-code, ub.goods.gds-code) .
      vVolue = volumeGF(doc-code, ub.goods.gds-code) .
      run tp-rtr(vTemp, vMasDol, output ktp) .
      vBlowdown = ktp * numHoses .
      run tp-arm(vTemp, vMasDol, output ktp) .
      vFittings = ktp * numHoses .
      run tp-emp(vTemp, vMasDol, lengthRukav, output ktp) .
      vEmptying = ktp * numHoses .
      run tp-ret(vTemp, output ktp) .
      vRefund = ktp * vVolue .
      run tp-chklv(vTemp, vMasDol, output ktp) .
      if reason-code = 99 and valve then vCtrlvalve = ktp .
      else vCtrlvalve = 0 .
      run doc-line-write(doc-code, "blowdown", ub.goods.gds-code, string (vBlowdown)) .
      run doc-line-write(doc-code, "fittings", ub.goods.gds-code, string (vFittings)) .
      run doc-line-write(doc-code, "emptying", ub.goods.gds-code, string (vEmptying)) .
      run doc-line-write(doc-code, "refund", ub.goods.gds-code, string (vRefund)) .
      run doc-line-write(doc-code, "ctrlvalve", ub.goods.gds-code, string (vCtrlvalve)) .
    end.
  end.
end procedure .
function check-RVD returns logical
  (p-obj-code as integer,
  p-obj-type as character,
  p-pl-code as integer):
  define buffer buf_place       for ub.place .
  define buffer buf_place-attr  for ub.place-attr .
  define buffer buf_place-attr2 for ub.place-attr .
  find first buf_place-attr no-lock where buf_place-attr.obj-type = p-obj-type
    and buf_place-attr.obj-code = p-obj-code
    and buf_place-attr.attr-code = "place-need-RVD-rvs"
    and buf_place-attr.pl-code = p-pl-code
    and logical(buf_place-attr.attr-value) = yes
    no-error .
  if available buf_place-attr then return true .
  for first buf_place-attr2 no-lock where buf_place-attr2.obj-type = p-obj-type
    and buf_place-attr2.obj-code = p-obj-code
    and buf_place-attr2.pl-code  = p-pl-code
    and buf_place-attr2.attr-code = "place-rvd-dnsty"
    and logical(buf_place-attr2.attr-value) = yes
    :
    return true .
  end .
  for first buf_place-attr2 no-lock where buf_place-attr2.obj-type = p-obj-type
    and buf_place-attr2.obj-code = p-obj-code
    and buf_place-attr2.pl-code  = p-pl-code
    and buf_place-attr2.attr-code = "place-rvd-tmp"
    and logical(buf_place-attr2.attr-value) = yes
    :
    return true .
  end .
  for first buf_place-attr2 no-lock where buf_place-attr2.obj-type = p-obj-type
    and buf_place-attr2.obj-code = p-obj-code
    and buf_place-attr2.pl-code  = p-pl-code
    and buf_place-attr2.attr-code = "place-rvd-lvl"
    and logical(buf_place-attr2.attr-value) = yes
    :
    return true .
  end .
  return false .
end function .
def var vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info11 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
procedure xmlchar-test :
define input parameter p-in-string          as character        no-undo.
define output parameter p-out-string-enc    as character        no-undo.
define output parameter p-out-string-dec    as character        no-undo.
do
on error undo, return error
:
       run xmlchar-encode in this-procedure
    (
          input p-in-string
        , output p-out-string-enc
    ).
       run xmlchar-decode in this-procedure
    (
          input p-out-string-enc
        , output p-out-string-dec
    ).
end.
end .
procedure xmlchar-encode :
define input parameter p-in-string      as character        no-undo.
define output parameter p-out-string    as character        no-undo.
    define variable v-position      as integer      no-undo.
    define variable v-current-char  as character    no-undo.
do
on error undo, return error
:
    assign
        p-out-string = "":U
    .
    case p-in-string
    :
        when ?
        then do:
            assign
                p-out-string = "?":U
            .
        end.
        when "?":U
        then do:
            assign
                p-out-string = "&#63;":U
            .
        end.
        otherwise do:
            do v-position = 1 to length( p-in-string )
            :
                assign
                    v-current-char = substring( p-in-string, v-position, 1 )
                .
                case v-current-char
                :
                    when "&":U
                    then do:
                        assign
                            p-out-string = p-out-string + "&amp;":U
                        .
                    end.
                    when ">":U
                    then do:
                        assign
                            p-out-string = p-out-string + "&gt;":U
                        .
                    end.
                    when "<":U
                    then do:
                        assign
                            p-out-string = p-out-string + "&lt;":U
                        .
                    end.
                    when "'":U
                    then do:
                        assign
                            p-out-string = p-out-string + "&apos;":U
                        .
                    end.
                    when '"':U
                    then do:
                        assign
                            p-out-string = p-out-string + "&quot;":U
                        .
                    end.
                    when chr(1)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(2)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(3)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(4)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(5)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(6)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(7)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(8)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(9)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(29)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(10)
                    then do:
                        assign
                            p-out-string = p-out-string + "&#10;":U
                        .
                    end.
                    when chr(13)
                    then do:
                        assign
                            p-out-string = p-out-string + "&#13;":U
                        .
                    end.
                    otherwise do:
                        assign
                            p-out-string = p-out-string + v-current-char
                        .
                    end.
                end case.
            end.
        end.
    end case.
end.
end .
procedure xmlchar-encode-1c :
define input parameter p-in-string      as character        no-undo.
define output parameter p-out-string    as character        no-undo.
    define variable v-position      as integer      no-undo.
    define variable v-current-char  as character    no-undo.
do
on error undo, return error
:
    assign
        p-out-string = "":U
    .
    case p-in-string
    :
        when ?
        then do:
            assign
                p-out-string = "?":U
            .
        end.
        otherwise do:
            do v-position = 1 to length( p-in-string )
            :
                assign
                    v-current-char = substring( p-in-string, v-position, 1 )
                .
                case v-current-char
                :
                    when chr(1)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(2)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(3)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(4)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(5)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(6)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(7)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(8)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(9)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(29)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(10)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(13)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    otherwise do:
                        assign
                            p-out-string = p-out-string + v-current-char
                        .
                    end.
                end case.
            end.
        end.
    end case.
end.
end .
procedure xmlchar-decode :
define input parameter p-in-string      as character        no-undo.
define output parameter p-out-string    as character        no-undo.
    define variable v-position      as integer      no-undo.
    define variable v-last-position as integer      no-undo.
    define variable v-temp-integer  as integer      no-undo.
    define variable v-current-char  as character    no-undo.
    define variable v-next-char     as character    no-undo.
    define variable v-success       as logical      no-undo.
do
on error undo, return error
:
    assign
        p-out-string = "":U
        v-position   = 0
    .
    replace-cycle:
    do while yes
    on error undo, return error
    :
        assign
            v-last-position = index( p-in-string, "&":U, v-position + 1 )
        .
        if v-last-position <= v-position
        then do:
            if v-position = 0
            then do:
                assign
                    p-out-string = p-in-string
                .
            end.
            else do:
                assign
                    p-out-string = p-out-string + substring( p-in-string, v-position + 1 )
                .
            end.
            leave replace-cycle.
        end.
        else do:
            assign
                p-out-string    = p-out-string + substring( p-in-string, v-position + 1, v-last-position - v-position - 1 )
                v-position      = v-last-position
                v-current-char  = substring( p-in-string, v-position + 1, 1 )
            .
            if v-current-char = "#":U
            then do:
                assign
                    v-last-position = index( p-in-string, ";":U, v-position + 2 )
                .
                if v-last-position > 0
                then do:
                    run xmlchar-read-integer in this-procedure
                     (
                          input substring( p-in-string, v-position + 2, v-last-position - v-position - 2 )
                        , output v-temp-integer
                        , output v-success
                    ).
                    if v-success = yes
                    and v-temp-integer >= 1
                    and v-temp-integer <= 255
                    then do:
                        assign
                            p-out-string = p-out-string + chr( v-temp-integer )
                            v-position   = v-last-position + 1
                        .
                    end.
                    else do:
                        assign
                            p-out-string = p-out-string + "&":U
                            v-position   = v-position   + 1
                        .
                    end.
                end.
                else do:
                    assign
                        p-out-string = p-out-string + "&":U
                        v-position   = v-position   + 1
                    .
                end.
            end.
            else do:
                case substring( p-in-string, v-position + 1, 3 )
                :
                    when "lt;":U
                    then do:
                        assign
                            p-out-string = p-out-string + "<":U
                            v-position   = v-position   + 3
                        .
                    end.
                    when "gt;":U
                    then do:
                        assign
                            p-out-string = p-out-string + ">":U
                            v-position   = v-position   + 3
                        .
                    end.
                    otherwise do:
                        if substring( p-in-string, v-position + 1, 4 ) = "amp;":U
                        then do:
                            assign
                                p-out-string = p-out-string + "&":U
                                v-position   = v-position   + 4
                            .
                        end.
                        else do:
                            case substring( p-in-string, v-position + 1, 5 )
                            :
                                when "quot;":U
                                then do:
                                    assign
                                        p-out-string = p-out-string + '"':U
                                        v-position   = v-position   + 5
                                    .
                                end.
                                when "apos;":U
                                then do:
                                    assign
                                        p-out-string = p-out-string + "'":U
                                        v-position   = v-position   + 5
                                    .
                                end.
                                otherwise do:
                                    assign
                                        p-out-string = p-out-string + "&":U
                                    .
                                end.
                            end case.
                        end.
                    end.
                end case.
            end.
        end.
    end.
end.
end .
procedure xmlchar-read-integer :
define input parameter p-input-string      as character        no-undo.
define output parameter p-output-integer   as integer          no-undo.
define output parameter p-success       as logical          no-undo.
do
on error undo, return error
:
    assign
        p-output-integer = integer( p-input-string )
    no-error.
    if error-status :error
    then do:
        assign
            p-success           = no
            p-output-integer    = 0
        .
    end.
    else do:
        assign
            p-success           = yes
        .
    end.
end.
end.
def var objSrv as class ibs.th.gbl.sys.objsrv no-undo.
run gbl/getobjsrvhndl.p (input-output ObjSrv).
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
define variable mMRCCode  as logical    no-undo.
define variable mTypeMark as character  no-undo.
function IS-NeedMark returns logical
( input ib-code as integer  ,
  input ib-str as character ):
   define buffer buf_prod-bc-attr for ub.prod-bc-attr.
   find first buf_prod-bc-attr where buf_prod-bc-attr.b-code eq ib-code
                                 and buf_prod-bc-attr.b-str  eq ib-str
                                 and buf_prod-bc-attr.attr-code eq 'mark':U
     no-lock no-error.
   return if available buf_prod-bc-attr then logical(buf_prod-bc-attr.attr-value) else no .
end.
function repTegforDm return char
(iDM as char ):
    define variable vTeglist as character no-undo init "01,02,11,13,17,21,8005,37".
    define variable vteg as character no-undo.
    define variable oDM as character no-undo.
    define variable vi as integer no-undo.
    oDM = iDm.
    do vi = 1 to num-entries(vTeglist):
       vTeg = entry(vi,vTeglist).
       oDM = replace(oDM,"(" + vTeg + ")",vTeg).
    end.
    return oDM.
end.
function repSpecSimbforDm return char
(iDM as char ):
    define variable oDM as character no-undo.
  run
    xmlchar-decode(iDM, output oDM).
  return repTegforDm (oDM).
end.
function CheckGtin return logical
(iGtin as char):
   define variable bar_code as character no-undo.
   define variable vGtin as logical no-undo init "yes".
   if length(iGtin) eq 14
   then do:
      bar_code = substr (iGtin, 1, length (iGtin) - 1).
      run str/chk-sum.p
       (input-output bar_code ) no-error .
      if iGtin ne  bar_code
      then
         vGtin = no.
   end.
   else
      vGtin = no.
   return vgtin.
end.
function repSpecSimbforXlm return char
(iDM as char ):
    iDM = replace(iDM,chr(29),"").
    return iDM.
end.
function getGtinByDM return char
(IDM as char):
   define variable VTXT as char no-undo.
   define variable vGtin as char no-undo.
   vTXt = IdM.
   vGtin = IDM.
   if    length(vtxt) > 14
   then do:
      if   vtxt begins "(01)"
             or vtxt begins "(02)"
      then
         vGtin = substring(vtxt,5,14).
      else if   (vtxt begins "01"
             or vtxt begins "02" )
             and (   (    substring(iDm,17,2) eq "21"
                      and length(vtxt) >= 21)
                  or substring(iDm,17,2) eq "37"
                  or substring(iDm,17,4) eq "(37)" )
      then do:
         vGtin = substring(vtxt,3,14).
         if not checkGtin(vGtin)
         then
            vGtin = substring(vtxt,1,14).
      end.
      else if     length(vtxt) eq 14 + 7 + 4 + 4
          or length(vtxt) eq 14 + 7 + 4
          or length(vtxt) eq 14 + 7
      then
         vGtin = substring(vtxt,1,14).
   end.
   if not checkGtin(vGtin)
   then
      vGtin = "".
   return vgtin.
end.
function getGdsCodeByGtin return int
(iGtin as char):
   define buffer prod-bc  for ub.prod-bc.
   define buffer bar-code for ub.bar-code.
   find first prod-bc where prod-bc.b-str eq iGtin  and prod-bc.bc-on no-lock no-error.
   find first bar-code where bar-code.b-code eq prod-bc.b-code no-lock no-error.
   return if avail bar-code then bar-code.gds-code else ?.
end.
function getQntyCodeByGtin return decimal
(iGtin as char):
   define buffer prod-bc  for ub.prod-bc.
   define buffer bar-code for ub.bar-code.
   find first prod-bc where prod-bc.b-str eq iGtin no-lock no-error.
   find first bar-code where bar-code.b-code eq prod-bc.b-code no-lock no-error.
   return if avail bar-code then bar-code.cli-base-rate else ?.
end.
function getGdsCodeByDM return int
(iDm as char):
   define variable vGtin as char no-undo.
   define buffer prod-bc for ub.prod-bc.
   vGtin  = getGtinByDM (IDM ).
   return getGdsCodeByGtin (vGtin).
end.
function ChekTypeMarkByGds return logical
(iGds-code as integer ):
   define buffer goods-attr for ub.goods-attr.
   find first goods-attr where goods-attr.gds-code   = iGds-code
                           and goods-attr.attr-code  = 'mark-type':U
   no-lock no-error.
   if available goods-attr
   then do:
      mTypeMark = goods-attr.attr-value.
      return goods-attr.attr-value = objsrv:Env:Marking:Types:tabak:NameProp
        .
   end.
   else
      return no.
end.
function ChekTypeMarkByDm return logical
(iDM as char ):
   return ChekTypeMarkByGds(getGdsCodeByDM(idm)).
end.
function ChekTypeMarkByGtin return logical
(iGtin as char ):
   return ChekTypeMarkByGds(getGdsCodeByGtin(iGtin)).
end.
function GetNextElement return character
  (input iAllTeg        as logical
  ,output oteg          as character
  ,output otegval       as character
  ,input-output pstr    as character
   ):
     define variable vlistElem   as character no-undo init "00,01,02,21,17,11,13,(01),(02),(21),(17),(11),(13)".
     define variable vlistleng   as character no-undo init "27,14,14,13,06,06,06,0014,0014,0013,0006,0006,0006".
     define variable vlistElemDop   as character no-undo init ",37,(37),(8005),8005,93,(93)".
     define variable vlistlengDop   as character no-undo init ",08,0008,000006,0006,04,0004".
     define variable vTeg as character no-undo.
     define variable vLength as integer no-undo.
     define variable vi as integer no-undo.
     define variable vj as integer no-undo.
     define buffer code for ub.code.
     find first code where Code.parent eq "MarkType"
                       and Code.CodeValue   eq mTypeMark
                       no-lock no-error.
     if     available code
        and Code.misc1 ne ""
        and Code.misc1 ne ?
     then do:
        integer (Code.misc1) no-error.
        if not error-status:error
        then
          entry (4,vlistleng) = Code.misc1.
     end.
     if iAllTeg
     then
        assign
           vlistElem     = vlistElem    + vlistElemDop
           vlistleng     = vlistleng    + vlistlengDop
        .
     else if mMRCCode
     then
        assign
           vlistElem     = vlistElem    + ",(8005),8005"
           vlistleng     = vlistleng    + ",000006,0006"
        .
    block-elem:
    do vi = 1 to num-entries(vlistElem):
       vTeg = entry(vi,vlistElem).
       if pstr begins vTeg
       then do:
          if    vTeg eq "21"
          then
             vLength = index(pstr,chr(29)) - 2 no-error.
          if vLength  <= 0
          then
             vLength = int(entry(vi,vlistleng)).
          otegval = substring (pstr,length(vteg) + 1, vLength).
          oteg = replace(replace(vteg,")",""),"(","").
          vTeg = vteg + otegval.
          otegval = replace(otegval,chr(29),"").
          oteg = replace(replace(oteg,")",""),"(","").
          pstr = substring (pstr,length(vTeg)+ 1).
          vTeg = replace(vTeg,chr(29),"").
          leave block-elem.
       end.
       else
          vTeg = "".
    end.
    return vteg.
end.
function GetCodeIdent return character
(iDm as char):
   define variable Velement   as character no-undo init "first".
   define variable oCodeIdent as character no-undo.
   define variable vteg as character no-undo.
   define variable vtegval as character no-undo.
   define variable vGtin as character no-undo.
   define buffer marking for ub.marking.
   for first marking no-lock where
             marking.mark eq iDm
         and marking.unit-ext = "LEVEL2"
   :
     return iDm.
   end.
   vGtin  = getGtinByDM (iDm ).
   ChekTypeMarkByDm(idm).
   if iDm begins 'tech_':U
   then
      oCodeIdent = iDm.
   else if length(iDm) < 21
   then do:
      find first marking where marking.mark eq idm
      no-lock no-error.
      oCodeIdent = if available marking then marking.mark else  ?.
   end.
   else if     length(iDm) eq 29
      and not iDm begins "01"
      and not iDm begins "02"
   then
      oCodeIdent = substring(iDm,1,if mMRCCode then 25 else 21 ).
   else  if     length(iDm) >= 24
            and (  iDm begins "01"
                or iDm begins "02")
            and  substring(iDm,17,2) ne "21"
   then do:
      if checkGtin(substring(iDm,1,14)) and ( (length(idm) eq 25 and substring(iDm,22,1) eq "A")
                                                or (length(idm) eq 29 and substring(iDm,22,1) eq "A"))
      then
         oCodeIdent = substring(iDm,1,if mMRCCode then 25 else 21).
      else
         oCodeIdent = iDM.
   end.
   else  if     (   length(iDm) eq 25
                 or length(iDm) eq 21)
            and (not iDm begins "01"
            and  not iDm begins "02")
   then
      oCodeIdent = substring(iDm,1,21).
   else if vGtin = substring(iDm,1,14) and checkGtin(substring(iDm,1,14)) and ( length(idm) eq 21 or (length(idm) eq 25 and substring(iDm,22,1) eq "A"))
   then
      oCodeIdent = substring(iDm,1,21).
   else do while Velement ne "" and idm ne "":
      Velement = GetNextElement(no,output vteg, output vtegval, input-output idm).
      oCodeIdent = oCodeIdent + Velement.
   end.
   return oCodeIdent.
end.
function GetTegCod return character
(icodeIdent as char, iTeg as char):
   define variable Velement   as character no-undo init "first".
   define variable oTeg as character no-undo init ?.
   define variable vteg as character no-undo.
   define variable vtegval as character no-undo.
   if     ((length(icodeIdent) eq 21
      and not icodeIdent begins "01"
      and not icodeIdent begins "02")
      or
          ( length(icodeIdent) eq 25
            and not icodeIdent begins "01"
            and not icodeIdent begins "02"))
   then do:
      if iTeg eq "01" or iTeg eq "02"
      then
         oTeg = substring(icodeIdent,1,21).
      else  if  iTeg eq "21"
      then
         oTeg = substring(icodeIdent,15,7).
   end.
   else do:
      ChekTypeMarkByDm(icodeIdent).
      block-teg:
         do while Velement ne "" and icodeIdent ne "":
         Velement = GetNextElement(yes,output vteg, output vtegval, input-output icodeIdent).
         if    Velement begins iTeg
            or Velement begins "(" + iTeg + ")"
         then do:
            oTeg = vtegval.
            leave block-teg.
         end.
      end.
   end.
   return oTeg.
end.
function isOAD return logical
(icodeIdent as character):
   return length(icodeIdent) > 18 and GetTegCod(icodeIdent,"37") ne ? and GetTegCod(icodeIdent,"02") ne ?.
end.
function isMark return logical
(icodeIdent as character):
   define buffer buf_marking for ub.marking.
   return can-find(first buf_marking where buf_marking.mark begins icodeIdent) or
          (length(icodeIdent) > 20 and not isOAD(icodeIdent)).
end.
function addBracketForCode return character
(icodeIdent as char):
   define variable Velement   as character no-undo init "first".
   define variable oTeg as character no-undo.
   define variable vteg as character no-undo.
   define variable vtegval as character no-undo.
   define buffer marking for ub.marking.
   find first marking no-lock where
              marking.mark begins icodeIdent no-error.
   if    not ChekTypeMarkByDm(icodeIdent)
      or length(icodeIdent) le 24
      or (avail marking and marking.unit-ext = "LEVEL2")
   then
      oTeg = icodeIdent.
   else do:
      if (  icodeIdent begins "01"
         or icodeIdent begins "02"
         ) and CheckGtin(substring (icodeIdent,3,14))
         and substring (icodeIdent,17,2) eq "21"
      then do:
         mMRCCode = yes.
         ChekTypeMarkByDm(icodeIdent).
         block-teg:
         do while Velement ne "" and icodeIdent ne "":
            Velement = GetNextElement(no,output vteg, output vtegval, input-output icodeIdent).
            if vteg ne ""
            then
               oTeg = oTeg + "(" + vteg + ")" + vtegval .
         end.
         mMRCCode = no.
      end.
      else do:
         oTeg = icodeIdent.
      end.
   end.
   return oTeg.
end.
function getlevelByCodId return int
(iCode as char):
   define variable vLength as int no-undo.
   define variable vLevel  as int no-undo.
   if not ChekTypeMarkByDM (icode) then return ?.
   vLength = length(iCode).
   if    vLength eq 18
      or vLength eq 20
   then
      Vlevel = 4.
   else if vLength eq 21
   then
      Vlevel = 1.
   else if vLength eq 25
   then do:
      if  iCode begins "01"
      then
         Vlevel = 3.
      else
         Vlevel = 1.
   end.
   else if     vLength >= 26
           and vLength <= 46
   then do:
      if    substring(iCode,17,2) eq "11"
         or substring(iCode,17,2) eq "13"
         or (    substring(iCode,17,2) eq "21"
             and vLength >= 33
             and substring(iCode,26,4) ne "8005")
      then
         Vlevel = 4.
      else if    vLength eq 31
              or vLength eq 38
              or vLength eq 39
              or vLength eq 45
      then
         Vlevel = 1.
      else if    vLength eq 35
              or vLength eq 43
      then
         Vlevel = 3.
      else
         Vlevel = ?.
   end.
   else
      Vlevel = ?.
   return Vlevel.
end.
function getLevelMotpBycodid return character
(iDm as char):
   define variable vLevel as integer no-undo.
   define variable vList as character no-undo init "Unit,kin,Level1,Level2,Level3,Level4,Level5".
   vLevel = getlevelByCodId(iDm).
   if    vLevel eq ?
      or vLevel < 1
      or vLevel > 6
   then
      return ?.
   else
      return entry(vlevel,vList).
end.
function getLevelUTDByLevelMotp return character
(iUnit as char):
   define variable vLevel as integer no-undo.
   define variable vListMOTP    as character no-undo init "Unit,kin,Level1,Level2,Level3,Level4,Level5".
   define variable vListutd as character no-undo init "КИ,КИН,КИГУ,КИТУ".
   vLevel = lookup(iUnit,vListMOTP).
   if    vLevel eq ?
      or vLevel < 1
      or vLevel > 4
   then
      return ?.
   else
      return entry(vlevel,vListutd).
end.
function getLevelMotpByDM return character
(iDm as char):
   return getLevelMotpByCodId(GetCodeIdent(iDm)).
end.
function getLevelUTDByCodId return character
(iDm as char):
   define variable vLevel as integer no-undo.
   define variable vList as character no-undo init "КИ,КИН,КИГУ,КИТУ".
   vLevel = getlevelByCodId(iDm).
   if    vLevel eq ?
      or vLevel < 1
      or vLevel > 4
   then
      return ?.
   else
      return entry(vlevel,vList).
end.
function getLevelUTDByDM return character
(iDm as char):
   return getLevelUTDByCodId(GetCodeIdent(iDm)).
end.
define variable mNotMarkQnty as logical no-undo.
function getQntyUTDByCodId return decimal
(iDM as char):
   define variable vLevel as integer no-undo.
   define variable vList as character no-undo init "1,5,10,500".
   define variable vGtin as character no-undo.
   define variable vqnty as decimal no-undo init ?.
   vqnty = dec(GetTegCod(iDM,"37")) no-error.
   if vqnty eq ?
   then do:
      if not mNotMarkQnty
      then do:
         define buffer marking for ub.marking.
         define variable vCodident as character no-undo.
         vCodident = GetCodeIdent(idm).
         find first marking where marking.mark begins vCodident no-lock no-error.
         if     available marking
            and marking.box-qnty ne ?
         then
            return marking.box-qnty.
      end.
      vGtin = getGtinByDm(iDM).
      if ChekTypeMarkByGtin (vGtin)
      then do:
         vLevel = getlevelByCodId(iDM).
         if     vLevel >= 1
            and vLevel <= 4
         then
            vqnty = int(entry(vlevel,vList)).
      end.
      else
         vqnty = getQntyCodeByGtin(vgtin).
   end.
   return vqnty.
end.
function getQntyUTDByDM return decimal
(iDm as char):
   define variable vDM as character no-undo.
   if     length (iDm) ne 25
      and length (iDm) ne 29
      and substring (iDm,length (iDm) - 6 + 1, 2 ) eq "93"
   then
      vDM = substring (iDm,1,length (iDm) - 6 ).
   else
      vDM = substring (iDm,1,length (iDm) - 4 ).
   return getQntyUTDByCodId(vDM).
end.
function getMRC4 return decimal
(iMRC as char):
   define variable oMrc     as decimal no-undo init ?.
   define variable vAlphabet as character no-undo init "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!~"%&'*+-./_,:;=<>?".
   define variable vi       as integer no-undo.
   define variable vfound   as integer no-undo.
   define variable vposStart   as integer no-undo.
   do:
   OMRc = 0.
   do vi = 1 to 4:
      define variable vsimb as character no-undo.
      vsimb = substring(iMRC,vi,1).
      vposStart = if keycode("Z") < keycode(vsimb) then 27 else 1.
      vfound = index(vAlphabet,vsimb,vposStart) - 1.
      if vfound > 0
      then
         OMRc = OMRc + exp (80,(4 - vi) ) * vfound  .
      end.
      OMRc = OMRc / 100.
   end.
   return OMRc.
end.
function getMRCByDM return decimal
(iDm as char):
   define variable vMRC     as character no-undo.
   define variable oMrc     as decimal no-undo init ?.
   define variable Velement as character no-undo init "empty".
   define variable vteg as character no-undo.
   define variable vtegval as character no-undo.
   if    length(idm) eq 14 + 7 + 4 + 4
      or length(idm) eq 14 + 7 + 4
   then do:
      vMRC = substring(idm,22,4).
      omrc = getMRC4(vMRC).
   end.
   else do:
       ChekTypeMarkByDm(iDm).
       block-mrc:
       do while Velement ne "" and idm ne "":
          Velement = GetNextElement(yes,output vteg, output vtegval, input-output idm).
          if Velement begins "8005"
          then do:
             vMRC = substring(Velement,5,6).
             leave block-mrc.
          end.
          else if Velement begins "(8005)"
          then do:
             vMRC = substring(Velement,7,6).
             leave block-mrc.
          end.
       end.
       if vMRC ne ""
       then
          OMRc = dec(vmrc) / 100 no-error.
   end.
   return OMRc.
end.
function MoveDate return Date
(idate as date,
 iMonth as int64):
   define variable vMonth   as int64 no-undo.
   define variable vYear    as int64 no-undo.
   define variable vDateNew as date  no-undo.
    define variable vDay     as int64 no-undo.
    vMonth = month(iDate) + iMonth.
    vYear =  year(iDate).
    if vMonth <= 0
    then assign
       vMonth = vMonth + 12
        vYear  = vYear - 1
    .
    else if vMonth > 12
    then assign
       vMonth = vMonth - 12
        vYear  = vYear + 1
    .
    vDateNew = date(vMonth,day(iDate),vYear) no-error.
    do while error-status:error eq yes:
       VDay = vDay + 1.
       vDateNew = date(vMonth,day(iDate) - vDay,vYear) no-error.
    end.
    if VDay > 0
    then
       vDateNew + 1.
    return vDateNew.
end.
procedure checkEMRC:
define input  parameter iDm as character no-undo.
define output parameter vok as logical   no-undo init yes.
   define variable v-value-emrc as character no-undo.
   define variable v-type-emrc  as character no-undo.
   define variable vDateIso     as character no-undo.
   define variable vMRC         as decimal no-undo.
   define variable vqnty        as decimal no-undo.
   define variable vPrice       as decimal no-undo.
   define variable vparent      as character no-undo.
   define variable vgds-code    as integer no-undo.
   define buffer code for ub.code.
   vMRC = getMRCByDM(iDm).
   if vMRC > 0
   then do:
      vgds-code = getGdsCodeByDM(iDm).
      vqnty     = getQntyUTDByDM(iDm).
            if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
         (
          input   vgds-code
         ,input   'emrc-type':U
         ,output   v-value-emrc
         ,output   v-type-emrc
       ) no-error.
       if     v-value-emrc ne ""
          and v-value-emrc ne ?
       then do:
          vDateIso = iso-date(today).
          vPrice = vMRC / vqnty.
          vparent ="emc" + chr(4) + v-value-emrc.
          find last code where Code.parent      eq vparent
                           and Code.code        le vDateIso
                           and code.status_  eq 0
          no-lock no-error.
          if not available code or ( vPrice  >= dec(Code.CodeValue))
          then
             vOk = true .
          else do:
              define variable vText      as character no-undo.
              define variable vDate      as date no-undo.
              define variable vDateLast  as character no-undo.
              define variable vDateFirst as character no-undo.
              define variable vDate3     as date no-undo.
              vdate = date(code.misc1).
              vDateLast = code.misc1.
              vDate3 = MoveDate(today, - 3 ).
              vText =  substitute ("ТОВАР ИМЕЕТ ОГРАНИЧЕННЫЙ СРОК РЕАЛИЗАЦИИ. Если товар произведен после &2, то его приемка и продажа запрещена.",
                                   string(vDate3  , "99/99/9999"),
                                   string(vDate   , "99/99/9999")
                                   ).
              vdateIso = iso-date(vdate3).
              find last code  where Code.parent      eq vparent
                                and Code.code        le vDateIso
                                and code.status_  eq 0 no-lock no-error.
              if available code
              then
                 vDateIso = code.code.
              vDateFirst = vDateIso.
              vDateLast = iso-date(vdate).
              define variable vGood as logical no-undo.
              define variable vDateSale as date no-undo.
              define buffer bcode for code.
              for last code where Code.parent   eq vparent
                              and code.status_  eq 0
                              and code.code     < vDateLast
                              and code.code     >= vDateFirst
              no-lock:
                 find first bcode where bCode.parent   eq vparent
                                    and bcode.status_  eq 0
                                    and bcode.code     > code.code no-lock no-error.
                 if available bcode
                 then do:
                    if vPrice < dec(Code.CodeValue)
                    then
                       vText = vtext + substitute ("&1Если товар произведен с &2 до &3, ТО ЕГО ПРИЕМКА И ПРОДАЖА ЗАПРЕЩЕНА",
                                                  chr(10),
                                                  string(    date( code.misc1)       ,"99/99/9999"),
                                                  string(    date(bcode.misc1)       ,"99/99/9999")
                                                  ).
                    else do:
                       vGood = yes.
                       vDateSale = MoveDate(date(bcode.misc1), 3) - 1.
                       vText = vtext + substitute ("&1Если товар произведен до &3, то продажа разрешена до &4.~Осталось &5 дней.",
                                                  chr(10),
                                                  string(    date( code.misc1)         ,"99/99/9999"),
                                                  string(    date(bcode.misc1)         ,"99/99/9999"),
                                                  string(         vDateSale            ,"99/99/9999"),
                                                  string(vDateSale - today)
                                                  ).
                    end.
                 end.
              end.
              if vgood
              then do:
                 define variable choice as integer no-undo .
                 run gbl/d-askw.w (input "Уточнение"
                        ,input  vText
                        ,input "|"
                        ,input "Принять|Вернуть"
                        ,input "Принять данный товар|Вернуть товар постащику"
                        ,input 1
                        ,input 2
                        ,output choice) no-error.
                 vok = choice eq 1.
              end.
              else
                 vok =false.
          end.
       end.
   end.
end.
function addGs2Mark return character
(iMark as char):
   define variable vDM   as character no-undo.
   define variable vIdx  as integer   no-undo.
   if index(iMark,chr(29),1) > 0
   then return iMark.
   if substring(iMark,26,4) = "8005" then
   do:
     vIdx = index(iMark,"93",26 + 4 + 5).
     if vIdx > 1 then do:
       vDM = substitute("&1&4&2&4&3",
                        substring(iMark,1,25),
                        substring(iMark,26,vIdx - 25 - 1),
                        substring(iMark,vIdx),
                        chr(29)) no-error.
       vIdx = index(vDm,"240",vIdx + 4).
       if vIdx > 0 then
       do:
         vDM = substitute("&1&3&2",
                          substring(vDm,1,vIdx - 1),
                          substring(vDm,vIdx),
                          chr(29)) no-error.
       end.
     end.
     else
       vDM = substitute("&1&3&2",
                        substring(iMark,1,25),
                        substring(iMark,26),
                        chr(29)) no-error.
   end.
   else if substring(iMark,32,2) = "91" then
   do:
     vIdx = index(iMark,"92",32).
     if vIdx > 1 then
       vDM = substitute("&1&4&2&4&3",
                        substring(iMark,1,31),
                        substring(iMark,32,vIdx - 31 - 1),
                        substring(iMark,vIdx),
                        chr(29)) no-error.
     else
       vDM = substitute("&1&3&2",
                        substring(iMark,1,31),
                        substring(iMark,32),
                        chr(29)) no-error.
   end.
   else if substring(iMark,39,2) = "91" then
   do:
     vIdx = index(iMark,"92",38).
     if vIdx > 1 then
       vDM = substitute("&1&4&2&4&3",
                        substring(iMark,1,38),
                        substring(iMark,39,vIdx - 38 - 1),
                        substring(iMark,vIdx),
                        chr(29)) no-error.
     else
       vDM = substitute("&1&3&2",
                        substring(iMark,1,38),
                        substring(iMark,39),
                        chr(29)) no-error.
   end.
   else if substring(iMark,25,2) = "93" then
   do:
     vIdx = index(iMark,"92",25).
     if vIdx > 1 then
       vDM = substitute("&1&4&2&4&3",
                        substring(iMark,1,24),
                        substring(iMark,25,vIdx - 24 - 1),
                        substring(iMark,vIdx),
                        chr(29)) no-error.
     else
       vIdx = index(iMark,"3103",25).
       if vIdx > 0 then
       vDM = substitute("&1&4&2&4&3",
                        substring(iMark,1,24),
                        substring(iMark,25,vIdx - 24 - 1),
                        substring(iMark,vIdx),
                        chr(29)) no-error.
       else
         vDM = substitute("&1&3&2",
                          substring(iMark,1,24),
                          substring(iMark,25),
                          chr(29)) no-error.
   end.
   else if substring(iMark,32,2) = "93" then
   do:
     vDM = substitute("&1&3&2",
           substring(iMark,1,31),
           substring(iMark,32),
           chr(29)) no-error.
   end.
   return if vDM <> "" then vDm else iMark.
end.
def var vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function getattrUtdex returns char
(idb-num   as integer,
 idoc-id   as integer,
 iattrcode as character,
 iExValue  as character  ):
   define buffer utd-attr for utd-attr.
   find first utd-attr where utd-attr.db-num eq idb-num
                         and utd-attr.doc-id eq idoc-id
                         and utd-attr.attr-code eq iattrcode
   no-lock no-error.
   return if not available utd-attr  then iExValue    else  utd-attr.attr-value.
end.
function getattrUtd returns char
(idb-num   as integer,
 idoc-id   as integer,
 iattrcode as character ):
  return getattrUtdex(idb-num,idoc-id,iattrcode,?).
end.
function setattrUtd returns logical
(idb-num   as integer,
 idoc-id   as integer,
 iattrcode as character,
 iattrval  as character ):
   define buffer utd-attr for utd-attr.
   find first utd-attr where utd-attr.db-num eq idb-num
                         and utd-attr.doc-id eq idoc-id
                         and utd-attr.attr-code eq iattrcode
   no-lock no-error.
   if not available utd-attr
   then do:
      create utd-attr.
      assign
         utd-attr.db-num    = idb-num
         utd-attr.doc-id    = idoc-id
         utd-attr.attr-code = iattrcode
         utd-attr.attr-value = iattrval
      .
   end.
   else do:
      if utd-attr.attr-value ne iattrval
      then do:
         find current utd-attr exclusive-lock no-error.
         if available utd-attr
         then
            utd-attr.attr-value = iattrval.
      end.
   end.
   release utd-attr.
end.
function GetAttrUtdlinesEx returns char
(idb-num   as integer,
 idoc-id   as integer,
 ilinenum  as integer,
 iattrcode as character,
 iExValue  as character  ):
   define buffer utd-lines-attr for utd-lines-attr.
   find first utd-lines-attr where utd-lines-attr.db-num    eq idb-num
                               and utd-lines-attr.doc-id    eq idoc-id
                               and utd-lines-attr.lineNum   eq ilineNum
                               and utd-lines-attr.attr-code eq iattrcode
   no-lock no-error.
   return if not available utd-lines-attr  then iExValue    else  utd-lines-attr.attr-value.
end.
function GetAttrUtdlines returns char
(idb-num   as integer,
 idoc-id   as integer,
 ilinenum  as integer,
 iattrcode as character ):
   return GetAttrUtdlinesex (idb-num,idoc-id,ilinenum,iattrcode,?).
end.
function setattrUtdlines returns logical
(idb-num   as integer,
 idoc-id   as integer,
 ilinenum  as integer,
 iattrcode as character,
 iattrval  as character ):
   define buffer utd-lines-attr for utd-lines-attr.
   find first utd-lines-attr where utd-lines-attr.db-num    eq idb-num
                               and utd-lines-attr.doc-id    eq idoc-id
                               and utd-lines-attr.lineNum   eq ilineNum
                               and utd-lines-attr.attr-code eq iattrcode
   no-lock no-error.
   if not available utd-lines-attr
   then do:
      if iattrval ne ?
         and iattrval ne ""
      then do:
         create utd-lines-attr.
         assign
            utd-lines-attr.db-num    = idb-num
            utd-lines-attr.doc-id    = idoc-id
            utd-lines-attr.lineNum   = ilineNum
            utd-lines-attr.attr-code = iattrcode
            utd-lines-attr.attr-value = iattrval
         .
      end.
   end.
   else do:
      if utd-lines-attr.attr-value ne iattrval
      then do:
         find current utd-lines-attr exclusive-lock no-error.
         if available utd-lines-attr
         then do:
            if    iattrval eq ?
               or iattrval eq ""
            then do:
               delete utd-lines-attr.
            end.
            else do:
               utd-lines-attr.attr-value = iattrval.
            end.
         end.
      end.
   end.
   release utd-lines-attr.
end.
function GetAttrUtdMarkingLinesEx returns char
(idb-num   as integer,
 idoc-id   as integer,
 ilinenum  as integer,
 imark     as character,
 iattrcode as character,
 iExValue  as character  ):
   define buffer utd-marking-lines-attr for utd-marking-lines-attr.
   find first utd-marking-lines-attr where utd-marking-lines-attr.db-num    eq idb-num
                                       and utd-marking-lines-attr.doc-id    eq idoc-id
                                       and utd-marking-lines-attr.lineNum   eq ilineNum
                                       and utd-marking-lines-attr.mark      eq imark
                                       and utd-marking-lines-attr.attr-code eq iattrcode
   no-lock no-error.
   return if not available utd-marking-lines-attr  then iExValue    else  utd-marking-lines-attr.attr-value.
end.
function GetAttrUtdMarkingLines returns char
(idb-num   as integer,
 idoc-id   as integer,
 ilinenum  as integer,
 imark     as character,
 iattrcode as character ):
   return GetAttrUtdMarkingLinesEx (idb-num,idoc-id,ilinenum,imark,iattrcode,?).
end.
function setattrUtdMarkingLines returns logical
(idb-num   as integer,
 idoc-id   as integer,
 ilinenum  as integer,
 imark     as character,
 iattrcode as character,
 iattrval  as character ):
   define buffer utd-marking-lines-attr for utd-marking-lines-attr.
   find first utd-marking-lines-attr where utd-marking-lines-attr.db-num    eq idb-num
                                       and utd-marking-lines-attr.doc-id    eq idoc-id
                                       and utd-marking-lines-attr.lineNum   eq ilineNum
                                       and utd-marking-lines-attr.mark      eq imark
                                       and utd-marking-lines-attr.attr-code eq iattrcode
   no-lock no-error.
   if not available utd-marking-lines-attr
   then do:
      if iattrval ne ?
         and iattrval ne ""
      then do:
         create utd-marking-lines-attr.
         assign
            utd-marking-lines-attr.db-num     = idb-num
            utd-marking-lines-attr.doc-id     = idoc-id
            utd-marking-lines-attr.lineNum    = ilineNum
            utd-marking-lines-attr.mark       = imark
            utd-marking-lines-attr.attr-code  = iattrcode
            utd-marking-lines-attr.attr-value = iattrval
         .
      end.
   end.
   else do:
      if utd-marking-lines-attr.attr-value ne iattrval
      then do:
         find current utd-marking-lines-attr exclusive-lock no-error.
         if available utd-marking-lines-attr
         then do:
            if    iattrval eq ?
               or iattrval eq ""
            then do:
               delete utd-marking-lines-attr.
            end.
            else do:
               utd-marking-lines-attr.attr-value = iattrval.
            end.
         end.
      end.
   end.
   release utd-marking-lines-attr.
end.
def var vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def var vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def var vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure gen-key-rec :
  define input  parameter p-tbl-name    as character no-undo.
  define input  parameter p-bh_tbl-name as handle    no-undo.
  define output parameter p-key-rec     as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-key-rec). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-rec). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-rec). endkey", vss-workfile )
  :
    define variable fh               as handle    no-undo .
    define variable v-ok             as logical   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    if p-tbl-name = ?
      or p-tbl-name = "":U
    then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Не задано имя таблицы.", vss-include-info15 ).
    end.
    if not p-bh_tbl-name:available then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Переданый буфер таблицы &2 не доступен", vss-include-info15, p-tbl-name ).
    end.
    assign
      p-key-rec = p-tbl-name
      v-inform  = p-bh_tbl-name:index-information(1)
      v-ind     = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = p-bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info15, p-tbl-name ).
    end.
    else do:
      assign
        v-idx-field-qnty = num-entries( v-inform ) - 4
      .
      if v-idx-field-qnty < 2 then do:
        return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info15, v-inform, p-tbl-name ).
      end.
      do v-ind = 1 to v-idx-field-qnty by 2
      on error undo, return error
      :
        assign
          fh = p-bh_tbl-name:buffer-field( entry( 4 + v-ind, v-inform, ",":U ) ).
          p-key-rec = p-key-rec + chr(3) + substitute("&1", replace(fh:buffer-value(),chr(3),chr(2) + chr(9) + chr (2)))
        .
      end.
    end.
    if p-key-rec = ? then do:
      assign
        p-key-rec = "":U
      .
      return error substitute( "&1. Поле(поля) первичного ключа таблицы &2 имеет(ют) неопределенное значение", vss-include-info15, p-tbl-name ).
    end.
  end.
  return.
end procedure.
procedure gen-where-keyr-tab :
  define input  parameter i-tableSerach as character no-undo.
  define input  parameter i-tablekey   as character  no-undo.
  define input  parameter p-key-rec    as character  no-undo.
  define input  parameter p-key-handle as handle     no-undo .
  define input  parameter p-db-name    as character  no-undo .
  define input  parameter p-tt-handle  as handle     no-undo .
  define output parameter o-Where      as character  no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-row-keyr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-row-keyr). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-row-keyr). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable fh_key           as handle    no-undo .
    define variable fh_search        as handle    no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-field-name     as character no-undo .
    define variable v-field-val      as character no-undo .
    define variable v-word-link      as character no-undo .
    define variable vTable           as character no-undo.
    define variable bh_tbl-key       as handle    no-undo .
    assign
      p-key-rec = trim( p-key-rec )
    .
    if p-key-handle <> ? then do:
      if not valid-handle(p-key-handle)
         or p-key-handle:type <> "buffer"
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Задан невалидный буфер для поиска.", vss-include-info15 ).
      end.
      if num-entries( p-key-rec, chr(3) ) > 1
        or p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. При поиске по буферу вместо ключа (&2) должено быть 'имя таблицы'.", vss-include-info15, p-key-rec ).
      end.
    end.
    else do:
      if p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info15 ).
      end.
    end.
    assign
      vTable = entry( 1 , p-key-rec, chr(3) )
    .
    if p-tt-handle <> ?
      and ( not valid-handle(p-tt-handle)
            or p-tt-handle:type <> "buffer"
          )
    then do:
      return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. &2&3Передан невалидный handle для поиска или handle не типа BUFFER", vss-include-info15, vTable, chr(10) ).
    end.
    if p-tt-handle = ? then do:
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, vTable )
      .
      create buffer bh_tbl-name for table v-full-tbl-name .
    end.
    else do:
      create buffer bh_tbl-name for table p-tt-handle:table-handle .
    end.
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Таблица &2 не имеет первичного ключа", vss-include-info15, vTable ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info15, v-inform, vTable ).
    end.
    assign
      o-where     = "where":U
      v-word-link = "":U
      v-field-num = num-entries( p-key-rec, chr(3) ) - 1
      v-count-fld = 0
    .
    if i-tablekey ne "" and i-tablekey ne ?
    then do:
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tablekey )
      .
      create buffer bh_tbl-key for table v-full-tbl-name .
    end.
    if i-tableSerach ne "" and i-tableSerach ne ?
    then do:
      delete object bh_tbl-name no-error.
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tableSerach )
      .
      create buffer bh_tbl-name for table v-full-tbl-name .
    end.
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      if p-key-handle = ?
        and v-count-fld > v-field-num
      then do:
        leave block_where.
      end.
      define variable VfieldKeyTable as handle no-undo.
      assign
        v-field-name = entry( 4 + v-ind, v-inform, ",":U )
        fh_search    = bh_tbl-name:buffer-field( v-field-name )
      .
      if     bh_tbl-key ne ?
      then do:
         VfieldKeyTable = bh_tbl-key:buffer-field( v-field-name ) no-error.
         if VfieldKeyTable eq ?
         then next block_where.
      end.
      if v-full-tbl-name ne "" and v-full-tbl-name ne ?
      then
         o-where = substitute( "&1 &2 &3.&4 =", o-where, v-word-link,v-full-tbl-name, v-field-name ).
      else
         o-where = substitute( "&1 &2 &3 =", o-where, v-word-link, v-field-name ).
      if p-key-handle = ? then do:
        assign
          v-field-val = replace (entry( v-count-fld + 1 , p-key-rec, chr(3) ),chr(2) + chr(9) + chr (2),chr(3))
        .
      end.
      else do:
        assign
          fh_key = p-key-handle:buffer-field( v-field-name )
        .
        if fh_key = ?
          or not valid-handle( fh_key )
        then do:
          delete object bh_tbl-name.
          if     bh_tbl-key ne ?
          then
             delete object bh_tbl-key.
          return error substitute( "&1. Буфер &2 не содержит поля &3 необходимого для поиска.", vss-include-info15, p-key-handle:name, v-field-name ).
        end.
        assign
          v-field-val = fh_key:buffer-value
        .
      end.
      if fh_search:data-type ="character":U then do:
        assign
          v-field-val = replace( v-field-val, '~~':U, '~~~~':U )
          v-field-val = replace( v-field-val, '"':U, '~~"':U )
          v-field-val = replace( v-field-val, "'":U, "~~'":U )
          v-field-val = replace( v-field-val, '~{':U, '~~~{':U )
          v-field-val = replace( v-field-val, '~}':U, '~~~}':U )
          v-field-val = replace( v-field-val, '~\':U, '~~~\':U )
          v-field-val = replace( v-field-val, chr(10), '~~n':U )
          v-field-val = replace( v-field-val, chr(9), '~~t':U )
          v-field-val = replace( v-field-val, chr(13), '~~r':U )
          v-field-val = replace( v-field-val, chr(27), '~~E':U )
          v-field-val = replace( v-field-val, chr(8), '~~b':U )
          v-field-val = replace( v-field-val, chr(12), '~~f':U )
          v-field-val = substitute( '"&1"', v-field-val )
        .
      end.
      assign
        o-where = substitute( "&1 &2", o-where, v-field-val )
      .
      if v-word-link = "":U then do:
        assign
          v-word-link = "and":U
        .
      end.
    end.
    delete object bh_tbl-name.
    if     bh_tbl-key ne ?
    then
       delete object bh_tbl-key.
    if p-key-handle = ?
      and v-count-fld <> v-field-num
    then do:
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2", vss-include-info15, vTable ).
    end.
  end.
end procedure.
procedure gen-hn-keyr-tab :
  define input  parameter i-tableSerach as character no-undo.
  define input  parameter i-tablekey   as character no-undo.
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter o-hn         as handle    no-undo.
  define variable v-full-tbl-name as character no-undo.
  define variable v-where         as character no-undo.
  define variable bh_tbl-name     as handle    no-undo.
  define variable vTable          as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-row-keyr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-row-keyr). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-row-keyr). endkey", vss-workfile ):
      run gen-where-keyr-tab(i-tableSerach,
                             i-tablekey,
                             p-key-rec,
                             p-key-handle,
                             p-db-name,
                             p-tt-handle,
                             output v-where).
      if i-tableSerach ne "" and i-tableSerach ne ?
      then do:
         v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tableSerach ).
         create buffer bh_tbl-name for table v-full-tbl-name .
      end.
      else do:
         if p-tt-handle = ? then do:
            assign
               vTable = entry( 1 , p-key-rec, chr(3) )
            .
            v-full-tbl-name = substitute( "&1.&2":U, p-db-name, vTable ).
            create buffer bh_tbl-name for table v-full-tbl-name .
         end.
         else do:
            create buffer bh_tbl-name for table p-tt-handle:table-handle .
         end.
      end.
      if p-tt-handle = ? then do:
         bh_tbl-name:find-first( v-where, p-stts-lock ) no-error .
      end.
      else do:
         bh_tbl-name:find-first( v-where ) no-error .
      end.
      o-hn = bh_tbl-name.
   end.
end procedure.
procedure gen-hn-keyr :
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter o-hn         as handle    no-undo.
  run gen-hn-keyr-tab(?,?,p-key-rec,p-key-handle,p-db-name,p-tt-handle,p-stts-lock,output o-hn).
end.
procedure gen-row-keyr :
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter p-tbl-row    as rowid     no-undo.
  define output parameter p-tbl-name   as character no-undo.
  define variable vHn as handle no-undo.
    run gen-hn-keyr-tab(?,?,p-key-rec,p-key-handle,p-db-name,p-tt-handle,p-stts-lock,output vHn).
    p-tbl-row = if vHn:available then vHn:rowid else ?.
    p-tbl-name =  vHn:table.
    delete object vHn no-error.
  if p-tbl-row = ? then do:
    return substitute( "Не найдена запись таблицы &2 по ключу &3", vss-include-info15, p-tbl-name, p-key-rec ).
  end.
  else do:
    return.
  end.
end procedure.
procedure gen-key-fv :
  define input  parameter p-key-rec    as character no-undo .
  define output parameter p-field-list as character no-undo .
  define output parameter p-value-list as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-key-fv). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-fv). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-fv). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable v-tbl-name       as character no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-delim-key      as character no-undo .
    if p-key-rec = ?
      or p-key-rec = "":U
    then do:
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info15 ).
    end.
    assign
      v-tbl-name      = entry( 1 , p-key-rec, chr(3) )
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверный уникальный ключ.", vss-include-info15 ).
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info15, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info15, v-inform, v-tbl-name ).
    end.
    assign
      p-field-list = "":U
      p-value-list = "":U
      v-delim-key  = "":U
      v-field-num  = num-entries( p-key-rec, chr(3) ) - 1
      v-count-fld  = 0
    .
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      if v-count-fld > v-field-num then do:
        leave block_where.
      end.
      assign
        p-field-list = p-field-list + v-delim-key + entry( 4 + v-ind, v-inform, ",":U )
        p-value-list = p-value-list + v-delim-key + entry( v-count-fld + 1 , p-key-rec, chr(3) )
      .
      if v-ind = 1 then do:
        assign
          v-delim-key = chr(3)
        .
      end.
    end.
    delete object bh_tbl-name.
    if v-count-fld <> v-field-num then do:
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2 в БД", vss-include-info15, v-tbl-name ).
    end.
  end.
end procedure.
procedure gen-key-field :
  define input  parameter p-table      as character no-undo .
  define output parameter p-field-list as character no-undo .
  do
  on error  undo, return error substitute( "&1 (gen-key-fv). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-fv). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-fv). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable v-tbl-name       as character no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-delim-key      as character no-undo .
    if p-table = ?
      or p-table = "":U
    then do:
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан таблица.", vss-include-info15 ).
    end.
    assign
      v-tbl-name      = p-table
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверная таблица.", vss-include-info15 ).
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info15, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info15, v-inform, v-tbl-name ).
    end.
    assign
      p-field-list = "":U
      v-delim-key  = "":U
      v-count-fld  = 0
    .
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      p-field-list = p-field-list + v-delim-key + entry( 4 + v-ind, v-inform, ",":U ).
      if v-ind = 1 then do:
        assign
          v-delim-key = chr(3)
        .
      end.
    end.
    delete object bh_tbl-name.
  end.
end procedure.
function AddUtdErrForTab returns logical
(idb-num         as integer ,
 idoc-id         as integer ,
 iTab            as character,
 iObj            as handle ,
 iCheckType      as character,
 iCodeErr        as character,
 iCheckObj       as character ):
   define buffer utd-err for utd-err.
   define buffer utd for utd.
   find first utd where utd.db-num     eq idb-num
                    and utd.doc-id     eq idoc-id
                    and utd.Direction  eq 'Outbound'
   no-lock no-error.
   if available utd
   then
      return no.
   define variable vRecKey as character no-undo.
         run gen-key-rec (input iTab,
                          input  iObj,
                          output vRecKey).
   find first utd-err where utd-err.db-num     eq idb-num
                        and utd-err.doc-id     eq idoc-id
                        and utd-err.CheckType  eq iCheckType
                        and utd-err.CodeErr    eq iCodeErr
                        and utd-err.CheckObj   eq iCheckObj
   exclusive-lock no-error.
   if not available utd-err
   then do:
      create utd-err.
      assign
         utd-err.db-num         = idb-num
         utd-err.doc-id         = idoc-id
         utd-err.CheckType      = iCheckType
         utd-err.CodeErr        = iCodeErr
         utd-err.CheckObj       = if iCheckObj eq ? then "?" else iCheckObj
         utd-err.reckey         = vRecKey
         utd-err.qnty           = 1
      .
   end.
   else
      utd-err.qnty = utd-err.qnty + 1.
   return utd-err.qnty eq 1.
end.
function AddUtdErr returns logical
(idb-num         as integer ,
 idoc-id         as integer ,
 iObj            as handle ,
 iCheckType      as character,
 iCodeErr        as character,
 iCheckObj       as character ):
   AddUtdErrForTab
      (idb-num,
       idoc-id,
       iObj:table,
       iObj,
       iCheckType,
       iCodeErr,
       iCheckObj).
end.
function ClearUtdErrTypeCode returns logical
(idb-num         as integer,
 idoc-id         as integer ,
 iCheckType      as character,
 iCodeErr        as character
 ):
   define buffer utd-err for utd-err.
   if    iCheckType eq "*"
      or iCheckType eq ?
   then do:
      if     iCodeErr ne ?
         and iCodeErr ne "*"
      then
         message "Задан код ошибки " iCodeErr " для удаления, но не задан тип"
         view-as alert-box.
      else
      for each utd-err where utd-err.db-num  eq idb-num
                         and utd-err.doc-id  eq idoc-id
      exclusive-lock:
         delete utd-err.
      end.
   end.
   else do:
      if    iCodeErr eq ?
         or iCodeErr eq "*"
      then do:
         for each utd-err where utd-err.db-num     eq idb-num
                            and utd-err.doc-id     eq idoc-id
                            and utd-err.CheckType  eq iCheckType
         exclusive-lock:
            delete utd-err.
         end.
      end.
      else do:
         for each utd-err where utd-err.db-num     eq idb-num
                            and utd-err.doc-id     eq idoc-id
                            and utd-err.CheckType  eq iCheckType
                            and ub.utd-err.CodeErr eq iCodeErr
         exclusive-lock:
            delete utd-err.
         end.
      end.
   end.
end.
function ClearUtdErr returns logical
(idb-num         as integer,
 idoc-id         as integer ,
 iCheckType      as character
 ):
   ClearUtdErrTypeCode(idb-num,idoc-id,iCheckType,?).
end.
function GetMesError returns character
(itxt as character,
 iobj as character ):
 define variable vi as integer no-undo.
 do vi = num-entries(iobj ,chr(4) ) to 1 by -1 :
    itxt = replace(itxt,"&" + string(vi),entry(vi,iobj,chr(4))).
 end.
 return itxt.
end.
function GetTextErrorType returns character
(iCheckType as character,
 iCodeErr   as character,
 iChechObj  as character,
 iType      as character  ):
   define buffer code    for code.
   define variable vError as character no-undo.
   find first code where code.parent eq "CodeError" +  chr(4)  + "UTD" +  chr(4) + iCheckType
                     and code.code   eq iCodeErr
   no-lock no-error.
   if available code
   then do:
      define variable vType as integer no-undo.
      if code.misc3 eq "error"
      then
         vType = 0.
      else if code.misc3 eq "warning"
      then
         vType = 1.
      else if code.misc3 eq "Hiden"
      then
         vType = 2.
      else
         vtype = int(code.misc3) no-error.
      case itype:
         when "error"
         then do:
            if vtype eq 0
            then
               vError = GetMesError(Code.CodeValue,iChechObj).
         end.
         when "warning"
         then do:
            if vtype <= 1
            then
               vError = GetMesError(Code.CodeValue,iChechObj).
         end.
         otherwise do:
            vError = GetMesError(Code.CodeValue,iChechObj).
         end.
      end.
   end.
   else
      vError =  iCodeErr + ":" + replace (iChechObj,chr(4),"|").
   return vError.
end.
function GetTypeError returns integer
(iCheckType as character,
 iCodeErr   as character):
   define buffer code    for code.
   define variable vType as integer no-undo.
   find first code where code.parent eq "CodeError" +  chr(4)  + "UTD" +  chr(4) + iCheckType
                     and code.code   eq iCodeErr
   no-lock no-error.
   if     not available code
      and code.misc3 eq "error"
   then
      vType = 0.
   else if code.misc3 eq "warning"
   then
      vType = 1.
   else if code.misc3 eq "Hiden"
   then
      vType = 2.
   else
      vtype = int(code.misc3) no-error.
   return vtype.
end.
function GetTextError returns character
(iCheckType as character,
 iCodeErr   as character,
 iChechObj  as character ):
   return GetTextErrortype(iCheckType,iCodeErr,iChechObj,"warning").
end.
function GetErrForUtdStr returns character
(idb-num     as integer ,
 idoc-id     as integer ,
 iCheckType  as character
 ):
   define buffer utd-err for utd-err.
   define buffer code    for code.
   define variable vHQry as handle no-undo.
   define variable vError as longchar no-undo.
   define variable vErrorOne as longchar  no-undo.
   define variable oError as character no-undo.
   create query vHQry.
   vHQry:set-buffers(buffer utd-err:handle).
   vHQry:query-prepare("for each utd-err where utd-err.db-num         eq " + QUOTER(idb-num)
                            +            " and utd-err.doc-id         eq " + QUOTER(idoc-id)
                            + if    iCheckType eq "*"
                                 or iCheckType eq ?
                              then       ""
                              else       " and utd-err.CheckType      eq " + QUOTER(iCheckType)).
   vHQry:query-open().
   vHQry:get-first().
   QRY-BLOCK:
   repeat while not vHQry:query-off-end:
      vErrorOne = GetTextErrorType(utd-err.CheckType,utd-err.CodeErr,utd-err.CheckObj,"error").
      if     vErrorOne ne ""
         and vErrorOne ne ?
      then
         vError = vError + ", " + vErrorOne.
      vHQry:get-next().
   end.
   oError = substring(vError,3,4002).
   return oError.
end.
function GetErrJsonForUtd returns character
(idb-num         as integer ,
 idoc-id         as integer ,
 iCheckType      as character
 ):
   define buffer utd-err for utd-err.
   define variable vHQry as handle no-undo.
   define variable vError as longchar no-undo.
   define variable oError as character no-undo.
   create query vHQry.
   define variable vi as integer no-undo.
   vHQry:set-buffers(buffer utd-err:handle).
   vHQry:query-prepare("for each utd-err where utd-err.db-num         eq " + QUOTER(idb-num)
                            +            " and utd-err.doc-id         eq " + QUOTER(idoc-id)
                            + if    iCheckType eq "*"
                                 or iCheckType eq ?
                              then       ""
                              else       " and utd-err.CheckType      eq " + QUOTER(iCheckType)).
   vHQry:query-open().
   vHQry:get-first().
   QRY-BLOCK:
   repeat while not vHQry:query-off-end:
      define variable vErrorOne as character no-undo.
      vErrorOne = GetTextErrorType(utd-err.CheckType,utd-err.CodeErr,utd-err.CheckObj,"error").
      if     vErrorOne ne ?
         and vErrorOne ne ""
      then do:
         vi = vi + 1.
         vError = vError + ',"Ошибка_' + string(vi) +  '":~{"КодОш":"'    + utd-err.CheckType + "_" + utd-err.CodeErr
                         + '","ОбъектОш":"' + replace(utd-err.CheckObj,chr(4),"|")
                         + '","ТекстОш":"' + vErrorOne + '"}'.
      end.
      vHQry:get-next().
   end.
   for first utd where utd.db-num eq idb-num
                   and utd.doc-id eq idoc-id
                   and utd.sts    eq ObjSrv:Env:Utd:Sts:th:DeliveryCodeMismatch:KeyIntDB
   no-lock,
      each utd-marking-lines where utd-marking-lines.db-num eq idb-num
                               and utd-marking-lines.doc-id eq idoc-id
                               and utd-marking-lines.doc-level eq 1
   no-lock,
      first marking where marking.mark eq utd-marking-lines.mark
                      and marking.sts  eq ObjSrv:Env:Marking:Sts:Mark:NotAvailable:KeyIntDB
   no-lock:
      vErrorOne = GetTextErrortype("CheckShip","NotMark",marking.mark,"error").
      if     vErrorOne ne ?
         and vErrorOne ne ""
      then do:
         vError = vError + ',"Ошибка_' + string(vi) +  '":~{"КодОш":"'    + "CheckShip" + "_" + "NotMark"
                         + '","ОбъектОш":"' + marking.mark
                         + '","ТекстОш":"' + vErrorOne + '"}'.
      end.
   end.
   if vError ne ""
   then
      oError = '"Ошибки":~{' + substring(vError,2,31002) + "}".
   return oError.
end.
function GetErrJsonForUtdReturn returns character
(idb-num         as integer ,
 idoc-id         as integer ,
 iCheckType      as character
 ):
   define buffer utd-err for utd-err.
   define variable vHQry as handle no-undo.
   define variable vError as longchar no-undo.
   define variable oError as character no-undo.
   define variable vi as integer no-undo.
   create query vHQry.
   vHQry:set-buffers(buffer utd-err:handle).
   vHQry:query-prepare("for each utd-err where utd-err.db-num         eq " + QUOTER(idb-num)
                            +            " and utd-err.doc-id         eq " + QUOTER(idoc-id)
                            + if    iCheckType eq "*"
                                 or iCheckType eq ?
                              then       ""
                              else       " and utd-err.CheckType      eq " + QUOTER(iCheckType)).
   vHQry:query-open().
   vHQry:get-first().
   QRY-BLOCK:
   repeat while not vHQry:query-off-end:
      define variable vErrorOne as character no-undo.
      vErrorOne = GetTextErrorType(utd-err.CheckType,utd-err.CodeErr,utd-err.CheckObj,"error").
      if     vErrorOne ne ?
         and vErrorOne ne ""
      then do:
         vi = vi + 1.
         vError = vError + ',"Возврат_' + string(vi) +  '":~{"КодВозр":"'    + utd-err.CheckType + "_" + utd-err.CodeErr
                         + '","ОбъектВозр":"' + replace(utd-err.CheckObj,chr(4),"|")
                         + '","ТекстВозр":"' + GetTextError(utd-err.CheckType,utd-err.CodeErr,utd-err.CheckObj) + '"}'.
      end.
      vHQry:get-next().
   end.
   if vError ne ""
   then
      oError = '"Возвраты":~{' + substring(vError,2,31002) + "}".
   return oError.
end.
function GetCodeTextError returns character
(iCheckType as character,
 iCodeErr   as character,
 iChechObj  as character,
 output oCode as character,
 output ovalue as character ):
   define buffer code    for code.
   find first code where code.parent eq "CodeError" +  chr(4)  + "UTD" +  chr(4) + iCheckType
                     and code.code   eq iCodeErr
   no-lock no-error.
   if     available code
   then do:
      define variable vi as integer no-undo init ?.
      vi = int(Code.misc3) no-error.
      if    code.misc3 ne "error"
         and vi ne 0
      then
         oCode = ?.
      else if     Code.misc1 ne ?
              and Code.misc1 ne ""
      then
         assign
            oCode  = GetMesError(Code.misc1,iChechObj)
            ovalue = GetMesError(Code.misc2,iChechObj)
         .
   end.
   return if oCode eq ""
          then ""
          else (oCode + "_" + ovalue).
end.
define temp-table TT-err no-undo
  field code_ as character
  field text_ as character
index code_ code_.
function GetErrTxtForUtd returns character
(idb-num         as integer ,
 idoc-id         as integer ,
 iCheckType      as character
 ):
   define buffer utd-err for utd-err.
   define variable vHQry as handle no-undo.
   define variable oError as character no-undo.
   create query vHQry.
   define variable vi as integer no-undo.
   for each tt-err :
      delete tt-err.
   end.
   vHQry:set-buffers(buffer utd-err:handle).
   vHQry:query-prepare("for each utd-err where utd-err.db-num         eq " + QUOTER(idb-num)
                            +            " and utd-err.doc-id         eq " + QUOTER(idoc-id)
                            + if    iCheckType eq "*"
                                 or iCheckType eq ?
                              then       ""
                              else       " and utd-err.CheckType      eq " + QUOTER(iCheckType)).
   vHQry:query-open().
   vHQry:get-first().
   define variable vcode as character no-undo.
   define variable vvalue as character no-undo.
   QRY-BLOCK:
   repeat while not vHQry:query-off-end:
      vi = vi + 1.
      GetCodeTextError (utd-err.CheckType, utd-err.CodeErr, utd-err.CheckObj, output vcode, output vvalue).
      if vcode ne ?
      then do:
         find first tt-err where tt-err.code eq vcode
         no-error.
         if not available tt-err
         then do:
            create tt-err.
            assign
               tt-err.code_ = vcode
               tt-err.text_ = vvalue
            .
         end.
         else
            tt-err.text_ = tt-err.text_ + "||" + vvalue.
      end.
      vHQry:get-next().
   end.
  find first utd where utd.db-num eq idb-num
                      and utd.doc-id eq idoc-id
      no-lock.
   define buffer cancel_utd-lines for utd-lines.
   for each cancel_utd-lines where cancel_utd-lines.db-num eq idb-num
                               and cancel_utd-lines.doc-id eq idoc-id
   no-lock:
      if logical(getattrutdlinesex  (idb-num,idoc-id,cancel_utd-lines.LineNum,"MarkUtdLine"        ,"no"))
      then do:
         for   each utd-marking-lines where utd-marking-lines.db-num eq idb-num
                                     and utd-marking-lines.doc-id eq idoc-id
                                     and utd-marking-lines.LineNum eq cancel_utd-lines.LineNum
         no-lock,
            first marking where marking.mark eq utd-marking-lines.mark
                            and marking.sts  eq ObjSrv:Env:Marking:Sts:Mark:NotAvailable:KeyIntDB
         no-lock:
            GetCodeTextError ("CheckShip", "MARKDECLINED", utd-marking-lines.mark + chr(4) + string(utd-marking-lines.LineNum), output vcode, output vvalue).
            find first tt-err where tt-err.code eq vcode
            no-error.
            if not available tt-err
            then do:
               create tt-err.
               assign
                  tt-err.code_ = vcode
                  tt-err.text_ = vvalue
               .
            end.
            else
               tt-err.text_ = tt-err.text_ + "||" + vvalue.
         end.
      end.
      else do:
         define variable vqnty as decimal no-undo.
         vqnty = decimal(GetAttrUtdlines(cancel_utd-lines.db-num,cancel_utd-lines.doc-id,cancel_utd-lines.linenum,"QuantityBarCode")).
         if vqnty eq ? then vqnty = 0.
         if vqnty ne cancel_utd-lines.Quantity
         then do:
            GetCodeTextError ("CheckShip", "NotAcceptQuantity", string(cancel_utd-lines.LineNum) + chr(4) + string(cancel_utd-lines.Quantity - vqnty), output vcode, output vvalue).
            find first tt-err where tt-err.code eq vcode
            no-error.
            if not available tt-err
            then do:
               create tt-err.
               assign
                  tt-err.code_ = vcode
                  tt-err.text_ = vvalue
               .
            end.
            else
               tt-err.text_ = tt-err.text_ + "||" + vvalue.
         end.
      end.
   end.
   for each tt-err:
      oError = oError + substitute("&1|&2|",tt-err.code_ , tt-err.text_ ) + chr(13) + chr(10) .
   end.
   return oError.
end.
define variable mFormatErr as character no-undo init "text".
function GetErrForUtd returns character
(idb-num         as integer ,
 idoc-id         as integer ,
 iType           as character
 ):
   if mFormatErr eq "text"
   then
      return GetErrTxtForUtd(idb-num,idoc-id,iType).
   else do:
      if itype eq "return"
      then return GetErrJsonForUtdReturn (idb-num,idoc-id,iType).
      else return GetErrJsonForUtd(idb-num,idoc-id,iType).
   end.
end.
function GetErrComText returns longchar
(icomment as character,
 itext    as longchar ):
    define variable vText as longchar no-undo.
   if mFormatErr eq "text"
   then do:
      if icomment ne ""
      then
         icomment = substitute("comment:|&1|",icomment).
      vText = icomment + itext.
   end.
   else do:
      icomment = if icomment begins  '"'
                 then icomment
                 else  if icomment eq "" then "" else ( '"Коментрии":~{"Коментарий":"' + icomment  + '"}') .
      vText = icomment + "," + itext.
      vText = "~{" + trim(vText,",") + "~}".
   end.
   return vText.
end.
function CheckTypeForMarkLineType returns logical
(iObj            as handle,
 iCheckType      as character,
 iCodeErr        as character ,
 iTypeErr        as character ):
   define variable vRecKey-markLine as character no-undo.
   define variable vGoodMark        as logical no-undo.
   define variable vdb-num          as integer no-undo.
   define variable vdoc-id          as integer no-undo.
   define variable vlinenum         as integer no-undo.
   define variable vErrorOne as character no-undo.
   define buffer buf_utd-err for utd-err.
   run gen-key-rec (input "utd-marking-lines",
                    input  iObj,
                    output vRecKey-markLine).
   vGoodMark = yes.
   vdb-num = iObj::db-num.
   vdoc-id = iObj::doc-id.
   vlinenum = iObj::linenum.
   block-mark-err:
   for each buf_utd-err  where  buf_utd-err.doc-id = vdoc-id
                            and buf_utd-err.db-num = vdb-num
                            and buf_utd-err.reckey = vRecKey-markLine
                            and if iCheckType  eq "*" or iCheckType eq ? then yes else buf_utd-err.CheckType = iCheckType
                            and if iCodeErr    eq "*" or iCodeErr   eq ? then yes else buf_utd-err.CodeErr   = iCodeErr
   no-lock:
      vErrorOne = GetTextErrorType(buf_utd-err.CheckType,buf_utd-err.CodeErr,buf_utd-err.CheckObj,iTypeErr).
      if     vErrorOne ne ?
         and vErrorOne ne ""
      then do:
         vGoodMark = no.
         leave block-mark-err.
      end.
   end.
   return not vGoodMark.
end.
function CheckErrForMarkLineType returns logical
(iObj            as handle,
 iType           as character  ):
   return CheckTypeForMarkLineType (iObj,iType,"*","error").
end.
function CheckErrForMarkLine returns logical
(iObj            as handle):
   return CheckErrForMarkLineType(iObj,"*").
end.
function CheckErrForLineTypeCode returns logical
(iObj                 as handle,
 iCheckType           as character,
 iCodeErr             as character,
 iTypeErr             as character,
 iOneErr              as logical):
   define variable vRecKey-line     as character no-undo.
   define buffer buf_utd-err for utd-err.
   define variable vUtdlineError as logical no-undo.
   define variable vErrorOne as character no-undo.
         run gen-key-rec (input "utd-lines",
                          input  iObj,
                          output vRecKey-line).
      define variable vdb-num as integer no-undo.
      define variable vdoc-id as integer no-undo.
      define variable vlinenum as integer no-undo.
      vdb-num = iObj::db-num.
      vdoc-id = iObj::doc-id.
      vlinenum = iObj::linenum.
      block-err:
      for each buf_utd-err  where  buf_utd-err.doc-id = vdoc-id
                               and buf_utd-err.db-num = vdb-num
                               and buf_utd-err.reckey = vRecKey-line
                               and if iCheckType eq "*" or iCheckType eq ? then yes else buf_utd-err.CheckType = iCheckType
                               and if iCodeErr   eq "*" or iCodeErr   eq ? then yes else buf_utd-err.CodeErr   = iCodeErr
      no-lock:
         vErrorOne = GetTextErrorType(buf_utd-err.CheckType,buf_utd-err.CodeErr,buf_utd-err.CheckObj,iTypeErr).
         if     vErrorOne ne ?
            and vErrorOne ne ""
         then do:
            vUtdlineError = yes.
            leave block-err.
         end.
      end.
      if  not vUtdlineError
      then do:
         define variable vGoodMark as logical no-undo.
         vGoodMark = yes.
         block-line-err:
         for each utd-marking-lines where utd-marking-lines.db-num  eq vdb-num
                                      and utd-marking-lines.doc-id  eq vdoc-id
                                      and utd-marking-lines.LineNum eq vLineNum
         no-lock:
            vGoodMark = not CheckTypeForMarkLineType(buffer utd-marking-lines:handle,iCheckType,iCodeErr,iTypeErr).
            if     vGoodMark
               and iOneErr eq no
            then
               leave block-line-err.
            if     iOneErr = yes
               and not vGoodMark
            then
               leave block-line-err.
         end.
         vUtdlineError = not vGoodMark.
      end.
   return vUtdlineError.
end.
function getErrForLineType returns character
(iObj            as handle,
 iType           as character  ):
   define variable vRecKey-line     as character no-undo.
   define buffer buf_utd-err for utd-err.
   define variable vUtdlineError as logical no-undo.
   define variable vErrorOne as character no-undo.
   define variable oError as character no-undo.
         run gen-key-rec (input "utd-lines",
                          input  iObj,
                          output vRecKey-line).
      define variable vdb-num as integer no-undo.
      define variable vdoc-id as integer no-undo.
      define variable vlinenum as integer no-undo.
      vdb-num = iObj::db-num.
      vdoc-id = iObj::doc-id.
      vlinenum = iObj::linenum.
      block-err:
      for each buf_utd-err  where  buf_utd-err.doc-id = vdoc-id
                               and buf_utd-err.db-num = vdb-num
                               and buf_utd-err.reckey = vRecKey-line
                               and if iType eq "*" or iType eq ? then yes else buf_utd-err.CheckType = iType
      no-lock:
         vErrorOne = GetTextErrorType(buf_utd-err.CheckType,buf_utd-err.CodeErr,buf_utd-err.CheckObj,"error").
         if     vErrorOne ne ?
            and vErrorOne ne ""
         then do:
            oError = oError + vErrorOne + " ".
         end.
      end.
   return oError.
end.
function CheckErrForLineType returns logical
(iObj            as handle,
 iType           as character  ):
    return CheckErrForLineTypeCode (iObj,itype,"*","error",no).
end.
function CheckErrForLine returns logical
(iObj            as handle):
   return CheckErrForLineType(iobj,"*").
end.
function CheckErrForUtd returns logical
(idb-num         as integer ,
 idoc-id         as integer ):
   for each utd-lines where utd-lines.db-num eq idb-num
                        and utd-lines.doc-id eq idoc-id
   no-lock :
      if not CheckErrForLine (buffer ub.utd-lines:handle)
      then
         return no.
   end.
   return yes.
end.
function CheckMarkUtd-28rel return logical
 (input idb-num as integer,
 input idoc-id as integer):
 define buffer utd                   for utd.
 define buffer utd-lines             for utd-lines.
 define buffer utd-marking-lines     for utd-marking-lines.
 define variable v-par-type as character no-undo.
 define variable vgdsNoMark as logical no-undo.
 define variable EDOParSec as class ibs.th.gbl.env.prmtrs.edo .
   define variable v-par-val  as character no-undo.
   find first utd where utd.db-num eq idb-num
                    and utd.doc-id eq idoc-id
   no-lock no-error.
   if available utd
   then do:
      if     utd.obj-code ne ?
         and utd.obj-type ne ?
      then do:
         EDOParSec = ObjSrv:Env:ParametrsOfSection:GetSectionEDO(utd.obj-type, utd.obj-code).
         Block-utd-lines:
         for each utd-lines where utd-lines.db-num eq idb-num
                              and utd-lines.doc-id eq idoc-id
         no-lock:
            if     utd-lines.gds-code ne ?
               and utd-lines.gds-code ne 0
            then do:
                               if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
                    ( utd-lines.gds-code,
                      'mark-type':U,
                       output v-par-val,
                       output v-par-type
                    ).
               if     EDOParSec:IsEdo
                  and EDOParSec:GetIsEDOForType(v-par-val)
               then do:
                  find first utd-marking-lines where utd-marking-lines.db-num  eq utd-lines.db-num
                                                 and utd-marking-lines.doc-id  eq utd-lines.doc-id
                                                 and utd-marking-lines.LineNum eq utd-lines.LineNum
                                                 and length(utd-marking-lines.mark) > 13
                  no-lock no-error.
                  if     avail utd-marking-lines
                     and not CheckErrForLine(buffer utd-lines:handle)
                  then
                     leave Block-utd-lines.
               end.
               else
                  vgdsNoMark = yes.
            end.
         end.
         setattrutd (utd.db-num,utd.doc-id,"MarkUtd",if vgdsNoMark then string(available utd-lines) else "yes").
         if vgdsNoMark then return available utd-lines . else return yes .
      end.
   end.
   return yes.
end.
function CheckMarkUtd return logical
 (input idb-num  as integer,
  input idoc-id  as integer):
  define buffer utd-lines             for ub.utd-lines.
  block-line:
  for each utd-lines where utd-lines.db-num eq idb-num
                       and utd-lines.doc-id eq idoc-id
  no-lock:
     if logical(getAttrUtdLinesEx (utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,"MarkUtdLine","yes"))
     then
        leave block-line.
  end.
  setattrutd (idb-num, idoc-id,"MarkUtd",string(available utd-lines)).
  return available utd-lines.
end.
function CheckNotMarkUtd return logical
 (input idb-num  as integer,
  input idoc-id  as integer):
  define buffer utd-lines             for ub.utd-lines.
  for each utd-lines where utd-lines.db-num eq idb-num
                       and utd-lines.doc-id eq idoc-id
  no-lock:
     if not logical(getAttrUtdLinesEx (utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,"MarkUtdLine","no"))
     then
        return yes.
  end.
  return no.
end.
function CheckMarkUtdLine return logical
 (input idb-num  as integer,
  input idoc-id  as integer,
  input iLineNum as integer):
 define buffer utd                   for utd.
 define buffer utd-lines             for utd-lines.
 define buffer utd-marking-lines     for utd-marking-lines.
 define variable v-par-type as character no-undo.
 define variable vMarking        as logical no-undo.
 define variable vArtic          as logical no-undo.
 define variable vTransitional   as logical no-undo.
 define variable EDOParSec as class ibs.th.gbl.env.prmtrs.edo .
   define variable v-par-val  as character no-undo.
   find first utd where utd.db-num eq idb-num
                    and utd.doc-id eq idoc-id
   no-lock no-error.
   if available utd
   then do:
      if     utd.obj-code ne ?
         and utd.obj-type ne ?
      then do:
         EDOParSec = ObjSrv:Env:ParametrsOfSection:GetSectionEDO(utd.obj-type, utd.obj-code).
         Block-utd-lines:
         for each utd-lines where utd-lines.db-num   eq idb-num
                              and utd-lines.doc-id   eq idoc-id
                              and utd-lines.LineNum  eq iLineNum
         no-lock:
            if     utd-lines.gds-code ne ?
               and utd-lines.gds-code ne 0
            then do:
                               if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
                    ( utd-lines.gds-code,
                      'mark-type':U,
                       output v-par-val,
                       output v-par-type
                    ).
               vMarking = EDOParSec:GetIsEDOForType(v-par-val).
               vArtic = not vMarking and EDOParSec:GetIsArticForType(v-par-val).
               if vMarking
               then do:
                  block-marking:
                  for each   utd-marking-lines where utd-marking-lines.db-num   eq idb-num
                                                 and utd-marking-lines.doc-id   eq idoc-id
                                                 and utd-marking-lines.LineNum  eq iLineNum
                                                 and length(utd-marking-lines.mark) > 13
                  no-lock:
                     if isOAD(utd-marking-lines.mark)
                     then do:
                        assign
                           vArtic   = yes
                           vMarking = no
                        .
                        leave block-marking.
                     end.
                  end.
               end.
               if vArtic
               then do:
                  block-artic:
                  for each   utd-marking-lines where utd-marking-lines.db-num   eq idb-num
                                                 and utd-marking-lines.doc-id   eq idoc-id
                                                 and utd-marking-lines.LineNum  eq iLineNum
                                                 and length(utd-marking-lines.mark) > 13
                  no-lock:
                     if isMark(utd-marking-lines.mark)
                     then do:
                        assign
                           vArtic   = no
                           vMarking = yes
                        .
                        leave block-artic.
                     end.
                  end.
               end.
               vTransitional = (vMarking or vArtic) and EDOParSec:GetIsTransitionalForType(v-par-val).
               if vTransitional
               then do:
                  find first utd-marking-lines where utd-marking-lines.db-num   eq idb-num
                                                 and utd-marking-lines.doc-id   eq idoc-id
                                                 and utd-marking-lines.LineNum  eq iLineNum
                                                 and length(utd-marking-lines.mark) > 13
                  no-lock no-error.
                  if not available utd-marking-lines
                  then assign
                     vMarking = no
                     vArtic   = no
                  .
               end.
            end.
            else
               assign
                  vMarking      = yes
                  vArtic        = no
                  vTransitional = no
               .
            setattrutdlines  (utd.db-num,utd.doc-id,iLineNum,"MarkUtdLine"         ,if vMarking      then "yes" else "").
            setattrutdlines  (utd.db-num,utd.doc-id,iLineNum,"ArticUtdLine"        ,if vArtic        then "yes" else "").
            setattrutdlines  (utd.db-num,utd.doc-id,iLineNum,"TransitionalUtdLine" ,if vTransitional then "yes" else "").
         end.
      end.
   end.
   return vMarking or vArtic.
end.
function getMarkUtdLine return logical
 (input  idb-num  as integer,
  input  idoc-id  as integer,
  input  iLineNum as integer,
  output oMarking        as logical,
  output oArtic          as logical,
  output oTransitional   as logical):
  oMarking = logical(getattrutdlinesex  (idb-num,idoc-id,iLineNum,"MarkUtdLine"        ,"no")).
  oArtic        = not oMarking
         and logical(getattrutdlinesex  (idb-num,idoc-id,iLineNum,"ArticUtdLine"       ,"no")).
  oTransitional = (oMarking or oArtic)
         and logical(getattrutdlinesex  (idb-num,idoc-id,iLineNum,"TransitionalUtdLine","no")).
end.
function CheckMarking return logical
 (input idb-num as integer,
 input idoc-id as integer,
 input iTypeErr as character ):
  define variable vMarkutd as logical no-undo.
  define variable vCrErr   as logical no-undo.
  define buffer utd-lines         for utd-lines.
  define buffer utd-marking-lines for utd-marking-lines.
  define buffer marking           for marking.
  ClearUtdErrTypeCode(idb-num,idoc-id,iTypeErr,"NotMark").
   block-line:
   for each utd-lines where utd-lines.db-num eq idb-num
                        and utd-lines.doc-id eq idoc-id
   no-lock:
      if logical (getAttrUtdLinesEx(utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,"MarkUtdLine","no"))
      then do:
         for each utd-marking-lines
                  where utd-marking-lines.db-num  = utd-lines.db-num
                    and utd-marking-lines.doc-id  = utd-lines.doc-id
                    and utd-marking-lines.LineNum = utd-lines.LineNum
         no-lock:
            if isMark(utd-marking-lines.mark)
            then do:
               find first marking where marking.mark eq utd-marking-lines.mark
               no-lock no-error.
               if not available marking
               then do:
                  AddUtdErr(utd-lines.db-num,utd-lines.doc-id,buffer utd-lines:handle,iTypeErr,"NotMark",string(utd-lines.LineNum)).
                  vCrErr = yes.
                  next block-line.
               end.
            end.
         end.
      end.
   end.
   return vCrErr.
end.
function CheckMarkForType return logical
 (input idb-num   as integer,
  input idoc-id   as integer):
   define variable vMarking        as logical no-undo.
   define variable vArtic          as logical no-undo.
   define variable vTransitional   as logical no-undo.
   define buffer utd-lines         for utd-lines.
   define buffer utd-marking-lines for utd-marking-lines.
   block-line:
   for each utd-lines where utd-lines.db-num eq idb-num
                        and utd-lines.doc-id eq idoc-id
   no-lock:
      getMarkUtdLine  (input  utd-lines.db-num , input  utd-lines.doc-id, input  utd-lines.LineNum,
                       output vMarking         , output vArtic          , output vTransitional).
      for each utd-marking-lines
                  where utd-marking-lines.db-num  = utd-lines.db-num
                    and utd-marking-lines.doc-id  = utd-lines.doc-id
                    and utd-marking-lines.LineNum = utd-lines.LineNum
      no-lock:
         if length(utd-marking-lines.mark) < 14
         then do:
            if (vMarking or vArtic) and not vTransitional
            then
               AddUtdErr(utd.db-num,utd.doc-id,buffer utd-marking-lines:handle,"loadUtd","NotMark",utd-marking-lines.mark).
         end.
         else if not isMark(utd-marking-lines.mark)
         then do:
            if vMarking
            then
               AddUtdErr(utd.db-num,utd.doc-id,buffer utd-marking-lines:handle,"loadUtd","NotMark",utd-marking-lines.mark).
         end.
         else do:
         end.
      end.
   end.
end.
function WeighedProd return logical
   ( input p-gds-code as integer) :
   define variable v-par-val  as character no-undo.
   define variable v-par-type as character no-undo.
           if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
            ( p-gds-code,
              'weighed-gds':U,
               output v-par-val,
               output v-par-type
            ).
   return logical(v-par-val).
end.
function WghProdVariable return logical
    (input p-obj-type as char,
     input p-obj-code as integer,
     input p-gds-code as integer) :
   define variable v-wgh-val  as character no-undo.
   define variable v-par-val  as character no-undo.
   define variable v-par-type as character no-undo.
   define variable vMarking        as logical no-undo.
   define variable vArtic          as logical no-undo.
   define variable vTransitional   as logical no-undo.
   define variable EDOParSec as class ibs.th.gbl.env.prmtrs.edo .
      if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
        ( p-gds-code,
          'weighed-gds':U,
           output v-wgh-val,
           output v-par-type
        ).
    if logical(v-wgh-val) = yes then do:
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
            ( p-gds-code,
              'mark-type':U,
               output v-par-val,
               output v-par-type
            ).
        if v-par-val <> "" then do:
            EDOParSec = ObjSrv:Env:ParametrsOfSection:GetSectionEDO(p-obj-type, p-obj-code).
            assign
               vMarking = EDOParSec:GetIsEDOForType(v-par-val)
               vArtic = not vMarking and EDOParSec:GetIsArticForType(v-par-val)
               .
        end.
   end.
   if v-wgh-val > "" and (vMarking or vArtic)
   then return yes.
   else return no.
end.
function MarkWeight return decimal
   ( input p-mark as character) :
   define buffer  buf_marking-attr for  ub.marking-attr.
   define variable vMarkWeight as decimal no-undo.
   vMarkWeight = 0.
   if p-mark <> "" and p-mark <> ?
   then do:
       find first buf_marking-attr where buf_marking-attr.mark      eq p-mark
                                     and buf_marking-attr.attr-code eq "weight"
          no-lock no-error.
       if not available buf_marking-attr
       then do :
         find first buf_marking-attr where buf_marking-attr.mark  begins p-mark
                                       and buf_marking-attr.attr-code eq "weight"
            no-lock no-error.
       end .
       if avail buf_marking-attr
       then vMarkWeight = dec(buf_marking-attr.attr-value).
   end.
   return vMarkWeight.
end.
if valid-handle( g#lib-trn4 ) = yes and
   g#lib-trn4 <> this-procedure :handle and
   g#lib-trn4 :get-signature( 'lib-trn4_gdnorsrv':U ) <> "":U
then do:
  message vss-workfile skip( 0 ) vss-date skip( 0 ) vss-revision skip( 1 ) vss-description skip( 1 )
          "Попытка повторной загрузки библиотеки для работы со складскими документами (4)" skip( 0 )
          g#lib-trn4                      skip( 0 )
          g#lib-trn4 :type                skip( 0 )
          g#lib-trn4 :file-name           skip( 0 )
          valid-handle( g#lib-trn4     )  skip( 0 )
          this-procedure :handle          skip( 0 )
          this-procedure :type            skip( 0 )
          this-procedure :file-name       skip( 0 )
          valid-handle( this-procedure )  skip( 1 )
  view-as alert-box error .
  undo, return error .
end.
else do:
  assign
    g#lib-trn4 = this-procedure :handle
  .
  def var gbl-hndllibObj as class gbl-hndllib no-undo.
  gbl-hndllibObj = new gbl-hndllib ().
  gbl-hndllibObj:InitHndl("g#lib-trn4", g#lib-trn4).
  delete object gbl-hndllibObj.
end.
on delete of this-procedure do:
  assign
    g#lib-trn4 = ?
  .
  def var gbl-hndllibObj as class gbl-hndllib no-undo.
  gbl-hndllibObj = new gbl-hndllib ().
  gbl-hndllibObj:InitHndl("g#lib-trn4", g#lib-trn4).
  delete object gbl-hndllibObj.
end.
define stream str-err .
define variable v-mess as character no-undo.
procedure lib-trn4_gdnorsrv :
  define  input parameter p-artic     like ub.goods.artic      no-undo .
  define  input parameter p-prod-type like ub.goods.prod-type  no-undo .
  define  input parameter p-prod-code like ub.goods.prod-code  no-undo .
  define  input parameter p-doc-code  like ub.trn-doc.doc-code no-undo .
  define output parameter p-process   as   logical             no-undo initial no .
  define variable is-petrol as logical no-undo .
  define variable is-pieces as logical no-undo .
  define variable is-hold   as logical no-undo .
  define buffer bf_trn-doc for ub.trn-doc .
  do
  on error undo, return error return-value
  :
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input p-artic
  ,  input p-prod-type
  ,  input p-prod-code
  , output is-petrol
  , output is-pieces
  ) no-error.
    if error-status :error or
       is-petrol = ?       or
       is-pieces = ?
    then do:
      return error substitute( 'Не могу определить признак топлива для товара &1 &2 &3.&4&5&4&6'
                             , p-artic
                             , p-prod-type
                             , p-prod-code
                             , chr(10)
                             , return-value
                             , error-status :get-message( 1 )
                             ) .
    end.
    if is-petrol <> yes or
       is-pieces <> no
    then do:
      return .
    end.
    find bf_trn-doc no-lock where
         bf_trn-doc.doc-code = p-doc-code no-error .
    if not available bf_trn-doc
    then do:
      return error substitute( 'Не найден документ № "&1".'
                             , p-doc-code
                             ) .
    end.
    if lookup( bf_trn-doc.ext-doc-type, 'ie,ee,re':U ) > 0
    then do:
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hold-doc in g#library
  (input  bf_trn-doc.doc-code
  ,output is-hold
  ) no-error .
      if error-status :error or
        is-hold = ?
      then do:
        assign
          is-hold = no
        .
        return error substitute( 'Не могу определить признак межфирменности для документа № "&1".&2&3&2&4'
                               , p-doc-code
                               , chr(10)
                               , return-value
                               , error-status :get-message( 1 )
                               ) .
      end.
      assign
        p-process = is-hold
      .
    end.
    else do:
      assign
        p-process = lookup( bf_trn-doc.ext-doc-type, 'iv,ev,eo,rv':U ) > 0
      .
    end.
  end.
end procedure.
procedure lib-trn4_chk4rsrv :
  define  input parameter p-ext-doc-type like ub.trn-doc.ext-doc-type no-undo .
  define  input parameter p-is-hold-doc  as   logical                 no-undo .
  define output parameter p-can-process  as   logical                 no-undo initial no .
  do
  on error undo, return error return-value
  :
    if lookup( p-ext-doc-type, 'ie,ee,re':U ) > 0 or
       lookup( p-ext-doc-type, 'iv,ev,io,eo,rv':U ) > 0 and
       p-is-hold-doc = yes
    then do:
      assign
        p-can-process = yes
      .
    end.
  end.
end procedure.
define temp-table tt-ci_ret-doc        no-undo like lib-trn_ret-doc.
define temp-table tt-ci_ret-line       no-undo like lib-trn_ret-line.
define temp-table tt-ci_ret-line-attr  no-undo like lib-trn_ret-line-attr.
define temp-table tt-ci_ret-dtl        no-undo like lib-trn_ret-dtl.
define temp-table tt-ci_ret-parts      no-undo like lib-trn_ret-parts.
define temp-table tt-loc_ret-line      no-undo like lib-trn_ret-line.
define temp-table tt-loc_ret-line-attr no-undo like lib-trn_ret-line-attr.
define temp-table tt-loc_ret-dtl       no-undo like lib-trn_ret-dtl.
define temp-table tt-loc_ret-parts     no-undo like lib-trn_ret-parts.
procedure lib-trn4_copy-in :
define input parameter parparentproc    AS WIDGET-HANDLE           NO-UNDO.
define input parameter parrec-doc       as recid                   no-undo.
define input parameter table for tt-ci_ret-doc.
define input parameter table for tt-ci_ret-line.
define input parameter table for tt-ci_ret-line-attr.
define input parameter table for tt-ci_ret-dtl.
define input parameter table for tt-ci_ret-parts.
define input parameter parquestions       as logical                no-undo.
define input parameter parwait-on         as logical                no-undo.
define input parameter parrigid-rsrv      as logical                no-undo.
define input parameter parrsrv-fact-qnty  as logical                no-undo.
define input parameter parhandle-waitfram as handle                 no-undo.
define variable mode-create             as   logical               no-undo.
define variable rec-old                 as   recid                 no-undo.
define variable delta-line-vat          like ub.trn-doc.vat-base      no-undo.
define variable delta-line-slt          like ub.trn-doc.vat-base      no-undo.
define variable price-vat               like ub.trn-doc.vat-base      no-undo.
define variable line-rec                as   integer               no-undo.
define variable g-log                   as   logical               no-undo.
define variable varprice-cli-old        like ub.doc-line.price-cli no-undo.
define variable varprice-rubl-old       like ub.doc-line.price-cli no-undo.
define variable varprice-base-old       like ub.doc-line.price-cli no-undo.
define variable varcli-qnty-old         like ub.doc-line.cli-qnty  no-undo.
define variable varcli-base-rate-old    like ub.doc-line.cli-qnty  no-undo.
define variable varfact-qnty-old        like ub.doc-line.cli-qnty  no-undo.
define variable vardoc-qnty-old         like ub.doc-line.cli-qnty  no-undo.
define variable varvat-pc-old           like ub.doc-line.vat-pc    no-undo.
define variable varslt-pc-old           like ub.doc-line.vat-pc    no-undo.
define variable varroad-tax-old         like ub.doc-line.price-cli no-undo.
define variable varexcise-old           like ub.doc-line.price-cli no-undo.
define variable vartransport-rubl-old   like ub.doc-line.price-cli no-undo.
define variable varother-rubl-old       like ub.doc-line.price-cli no-undo.
define variable varlns-cnt              as   integer               no-undo.
define buffer ci_trn-doc  for ub.trn-doc.
define buffer ci_doc-line for ub.doc-line.
define buffer ci_goods    for ub.goods.
c-i:
do transaction on error undo c-i, return error return-value :
find first ci_trn-doc where recid(ci_trn-doc) = parrec-doc.
find tt-ci_ret-doc.
if ci_trn-doc.exch-code <> tt-ci_ret-doc.exch-code then do:
  if parquestions = no then do:
    return error "Валюта документа - источника не совпадает с валютой заполняемого документа.".
  end.
  else do:
    assign
    g-log = no.
    message "Валюта документа - источника не совпадает с валютой заполняемого документа !" skip
            "Цены по ТТН в добавленых строках будут неправильными !!!  Продолжать ?"
             view-as alert-box question buttons OK-Cancel update g-log.
    if not g-log then return error.
  end.
end.
if tt-ci_ret-doc.doc-type = 'при':U and
   not tt-ci_ret-doc.internal then do:
  if ci_trn-doc.inv-num = ? then ci_trn-doc.inv-num = tt-ci_ret-doc.inv-num.
  if ci_trn-doc.ord-num = ? or
     ci_trn-doc.ord-num = "" then do:
    if ci_trn-doc.status_ = 'накл':U and
       tt-ci_ret-doc.status_ = 'запрос':U then do:
      ci_trn-doc.ord-num = tt-ci_ret-doc.doc-code.
    end.
    else do:
      assign
      ci_trn-doc.ord-num = tt-ci_ret-doc.ord-num.
    end.
  end.
  if ci_trn-doc.ship-date  = ?  then ci_trn-doc.ship-date  = tt-ci_ret-doc.ship-date.
  if ci_trn-doc.ship-num   = ?  then ci_trn-doc.ship-num   = tt-ci_ret-doc.ship-num.
  if ci_trn-doc.exch-date  = ?  then ci_trn-doc.exch-date  = tt-ci_ret-doc.exch-date.
  if ci_trn-doc.exch-rate  = ?  then ci_trn-doc.exch-rate  = tt-ci_ret-doc.exch-rate.
  if ci_trn-doc.exch-scale = ?  then ci_trn-doc.exch-scale = tt-ci_ret-doc.exch-scale.
end.
if ci_trn-doc.agnt       = ? then ci_trn-doc.agnt       = tt-ci_ret-doc.agnt.
if ci_trn-doc.boss       = ? then ci_trn-doc.boss       = tt-ci_ret-doc.boss.
if ci_trn-doc.wrkr       = ? then ci_trn-doc.wrkr       = tt-ci_ret-doc.wrkr.
if ci_trn-doc.base-rate  = ? then ci_trn-doc.base-rate  = tt-ci_ret-doc.base-rate.
if ci_trn-doc.base-scale = ? then ci_trn-doc.base-scale = tt-ci_ret-doc.base-scale.
if ci_trn-doc.exch-code  = ? then ci_trn-doc.exch-code  = tt-ci_ret-doc.exch-code.
assign
varlns-cnt = 0.
if parwait-on then do:
  run waitfram-show in parhandle-waitfram ("Добавление строк из документа - источника. ЖДИТЕ ...") no-error.
end.
for each tt-ci_ret-line use-index line-num on error undo, return error return-value :
   find first ci_goods where ci_goods.artic     = tt-ci_ret-line.artic         and
                             ci_goods.prod-type = tt-ci_ret-line.prod-type and
                             ci_goods.prod-code = tt-ci_ret-line.prod-code no-lock.
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_goods-tr in g#lib-trn3
(input recid(ci_trn-doc)
,input recid(ci_goods)
) no-error
.
   if error-status :error then do:
     if parrigid-rsrv then do:
       undo, return error substitute ("&1 &2", error-status :get-message(1), return-value).
     end.
     else do:
       message
       error-status :get-message(1) skip
       return-value
       view-as alert-box.
       undo, next.
     end.
   end.
   find first ci_doc-line where ci_doc-line.doc-code  = ci_trn-doc.doc-code     and
                                ci_doc-line.artic     = ci_goods.artic      and
                                ci_doc-line.prod-type = ci_goods.prod-type  and
                                ci_doc-line.prod-code = ci_goods.prod-code  no-error.
   if available ci_doc-line then do:
      assign
      mode-create = no
      varprice-cli-old       = ci_doc-line.price-cli
      varprice-rubl-old      = ci_doc-line.price-rubl
      varprice-base-old      = ci_doc-line.price-base
      varcli-qnty-old        = ci_doc-line.cli-qnty
      varcli-base-rate-old   = ci_doc-line.cli-base-rate
      varfact-qnty-old       = ci_doc-line.fact-qnty
      vardoc-qnty-old        = ci_doc-line.doc-qnty
      varvat-pc-old          = ci_doc-line.vat-pc
      varslt-pc-old          = ci_doc-line.slt-pc
      varroad-tax-old        = ci_doc-line.road-tax
      varexcise-old          = ci_doc-line.excise
      vartransport-rubl-old  = ci_doc-line.transport-rubl
      varother-rubl-old      = ci_doc-line.other-rubl.
   end.
   else mode-create = yes.
   line-rec = ?.
   for each tt-loc_ret-line on error undo, return error return-value :
     delete tt-loc_ret-line.
   end.
   for each tt-loc_ret-line-attr on error undo, return error return-value :
     delete tt-loc_ret-line-attr.
   end.
   for each tt-loc_ret-dtl on error undo, return error return-value :
     delete tt-loc_ret-dtl.
   end.
   for each tt-loc_ret-parts on error undo, return error return-value :
     delete tt-loc_ret-parts.
   end.
   create tt-loc_ret-line.
   buffer-copy tt-ci_ret-line to tt-loc_ret-line.
   for each tt-ci_ret-line-attr where tt-ci_ret-line-attr.doc-code  = tt-loc_ret-line.doc-code  and
                                      tt-ci_ret-line-attr.gds-code  = ci_goods.gds-code on error undo, return error return-value     :
      create tt-loc_ret-line-attr.
      buffer-copy tt-ci_ret-line-attr to tt-loc_ret-line-attr.
   end.
   for each tt-ci_ret-dtl where tt-ci_ret-dtl.doc-code  = tt-loc_ret-line.doc-code  and
                                tt-ci_ret-dtl.artic     = tt-loc_ret-line.artic     and
                                tt-ci_ret-dtl.prod-type = tt-loc_ret-line.prod-type and
                                tt-ci_ret-dtl.prod-code = tt-loc_ret-line.prod-code on error undo, return error return-value :
     create tt-loc_ret-dtl.
     buffer-copy tt-ci_ret-dtl to tt-loc_ret-dtl.
   end.
   for each tt-ci_ret-parts where tt-ci_ret-parts.out-code  = tt-loc_ret-line.doc-code  and
                                  tt-ci_ret-parts.obj-type  = tt-ci_ret-doc.obj-type    and
                                  tt-ci_ret-parts.obj-code  = tt-ci_ret-doc.obj-code    and
                                  tt-ci_ret-parts.artic     = tt-loc_ret-line.artic     and
                                  tt-ci_ret-parts.prod-type = tt-loc_ret-line.prod-type and
                                  tt-ci_ret-parts.prod-code = tt-loc_ret-line.prod-code on error undo, return error return-value :
     create tt-loc_ret-parts.
     buffer-copy tt-ci_ret-parts to tt-loc_ret-parts.
   end.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_copy-inh in g#lib-trn
( input parparentproc
 ,input recid(ci_trn-doc)
 ,input 'copy':U
 ,input yes
 ,input parrsrv-fact-qnty
 ,input table tt-ci_ret-doc
 ,input table tt-loc_ret-line
 ,input table tt-loc_ret-line-attr
 ,input table tt-loc_ret-dtl
 ,input table tt-loc_ret-parts
  ) no-error .
   if error-status :error then do:
      if parrigid-rsrv then do:
        undo c-i, return error return-value.
      end.
      else do:
        if parquestions then do:
          assign g-log = no.
          message "Ошибка при копировании в документ." skip
                  return-value skip
                  "Будем обрабатывать другие строки документа?"
                  view-as alert-box question buttons yes-no update g-log.
          if g-log = yes then do:
            next.
          end.
          else do:
            run waitfram-hide in parhandle-waitfram no-error.
            undo, return error return-value .
          end.
        end.
        else do:
          next.
        end.
      end.
   end.
   find first ci_doc-line where ci_doc-line.doc-code  = ci_trn-doc.doc-code and
                                ci_doc-line.artic     = ci_goods.artic      and
                                ci_doc-line.prod-type = ci_goods.prod-type  and
                                ci_doc-line.prod-code = ci_goods.prod-code  no-error.
  if available ci_doc-line then do:
    if ci_doc-line.unit-cli = ? OR ci_doc-line.unit-cli = "" then do:
        ci_doc-line.unit-cli = ci_goods.unit-cli.
    end.
    if mode-create then do:
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_clcintrn in g#lib-trn
  (
   input parparentproc
  ,input recid(ci_doc-line)
  ,input ci_doc-line.doc-code
  ,input ci_doc-line.artic
  ,input ci_doc-line.prod-type
  ,input ci_doc-line.prod-code
  ,input 0
  ,input 0
  ,input 0
  ,input 0
  ,input 0
  ,input 0
  ,input 0
  ,input 0
  ,input 0
  ,input 0
  ,input 0
  ,input 0
  ,input 0
  ,input 'create'
  ,input ''
  ) no-error.
     if error-status :error then undo c-i, return error return-value.
    end.
    else do:
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_clcintrn in g#lib-trn
  (
   input parparentproc
  ,input recid(ci_doc-line)
  ,input ci_doc-line.doc-code
  ,input ci_doc-line.artic
  ,input ci_doc-line.prod-type
  ,input ci_doc-line.prod-code
  ,input varprice-cli-old
  ,input varprice-rubl-old
  ,input varprice-base-old
  ,input varcli-qnty-old
  ,input varcli-base-rate-old
  ,input varfact-qnty-old
  ,input vardoc-qnty-old
  ,input varvat-pc-old
  ,input varslt-pc-old
  ,input varroad-tax-old
  ,input varexcise-old
  ,input vartransport-rubl-old
  ,input varother-rubl-old
  ,input 'update'
  ,input ''
  ) no-error.
      if error-status :error then undo c-i, return error return-value.
    end.
    run str/chk-prt.p (recid(ci_doc-line), no, buffer ci_trn-doc).
  end.
  varlns-cnt = varlns-cnt + 1.
  if parwait-on then do:
    run waitfram-show in parhandle-waitfram ("Добавление из документа - источника. Обработано : " + string (varlns-cnt)) no-error.
  end.
end.
if parwait-on then do:
  run waitfram-hide in parhandle-waitfram no-error.
end.
end.
end procedure.
procedure lib-trn4_int-clos :
  define input  parameter parparentproc as widget-handle no-undo.
  define input  parameter p-doc-code    as character no-undo .
  define output parameter table for gds-list .
  define variable varmode            as   character           no-undo.
  define variable varstatus          like ub.trn-doc.status_  no-undo.
  define variable varflag            like ub.trn-doc.flag_    no-undo.
  define variable varcopystatus      like ub.trn-doc.status_  no-undo.
  define variable varcopyflag        like ub.trn-doc.flag_    no-undo.
  define variable varpercent-expense as decimal   no-undo .
  define variable varperc-expvalue   as character no-undo .
  define variable varperc-exptype    as character no-undo .
  define variable varchg-inv         as logical   no-undo .
  define variable varvalue           as character no-undo .
  DEFINE VARIABLE varvalue_massa-sug as character no-undo .
  DEFINE VARIABLE varvalue_teh-loss  as character no-undo .
  DEFINE VARIABLE varvalue_err-allow as character no-undo .
  define variable vartype            as character no-undo .
  define variable skip-all           as logical   no-undo initial no .
  define variable skip-zero          as logical   no-undo initial no .
  define variable v-num              as integer   no-undo initial ? .
  define variable l_can-close_ee-ep  as logical   no-undo .
  define variable l_is-hold-doc      as logical   no-undo .
  define variable vardb-num          like ub.clients.db-num   no-undo.
  define variable varfact-date       as date      no-undo .
  define variable varshift-date      as date      no-undo .
  define variable varshift-num       as integer   no-undo .
  define variable varshift-name      as character no-undo .
  define variable varlog             as logical   no-undo .
  define variable varcheck-return    as logical   no-undo .
  define variable v-error            as logical   no-undo .
  define variable v-user-action      as character no-undo .
  define variable v-printed          as logical   no-undo .
  define variable v-event-code       as character no-undo .
  define variable v-close-type       as integer   no-undo .
  define variable v-not-eq-count     as int       no-undo .
  define variable v-is-petrl         as logical   no-undo .
  define variable v-is-pieces        as logical   no-undo .
  define variable v-pay-agent-gd1    as integer no-undo .
  define variable v-pay-agent-nm1    as character no-undo .
  define variable v-pay-agent-ar1    as character no-undo .
  define variable v-pay-agent-fl1    as logical no-undo .
  define variable v-pay-agent-gd2    as integer no-undo .
  define variable v-pay-agent-nm2    as character no-undo .
  define variable v-pay-agent-ar2    as character no-undo .
  define variable v-pay-agent-fl2    as logical no-undo .
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxp-doc-prt         like ub.store.doc-prt         no-undo.
  define variable v-cntxp-price-calc      like ub.store.price-calc      no-undo.
  define variable v-cntxp-inout-price     like ub.store.inout-price     no-undo.
  define variable v-cntxp-unit-cli-perm   like ub.store.unit-cli-perm   no-undo.
  define variable v-cntxp-out-rate        like ub.store.out-rate        no-undo.
  define variable v-cntxp-out-line-discnt like ub.store.out-line-discnt no-undo.
  define variable v-cntxp-in-ov           like ub.store.in-ov           no-undo.
  define variable v-cntxp-in-perm         like ub.store.in-perm         no-undo.
  define variable v-cntxp-no-eq           like ub.store.no-eq           no-undo.
  define variable v-cntxp-rsrv-time       like ub.store.rsrv-time       no-undo.
  define variable v-cntxp-load-time       like ub.store.load-time       no-undo.
  define variable v-cntxp-holidays        like ub.store.holidays        no-undo.
  define variable v-cntxp-in-pay          like ub.store.in-pay          no-undo.
  define variable v-cntxp-out-pay         like ub.store.out-pay         no-undo.
  define variable v-cntxp-ret-pay         like ub.store.ret-pay         no-undo.
  define variable v-cntxp-ret-sup-pay     like ub.store.ret-sup-pay     no-undo.
  define variable v-cntxp-down-pay        like ub.store.down-pay        no-undo.
  define variable v-cntxp-inv-pay         like ub.store.inv-pay         no-undo.
  define variable v-cntxp-chk-pay         like ub.store.chk-pay         no-undo.
  define variable v-cntxp-retail          like ub.sysconf.ord-prt       no-undo.
  define variable v-cntxp-osn-base        like ub.sysconf.osn-base      no-undo.
  define variable v-cntxp-conf-par        as   character                no-undo.
  define variable v-cntxp-par-type        as   character                no-undo.
  define variable v-cntxp-curr-host-code  like ub.store.host-code       no-undo.
  define variable v-cntxp-obj-type        like ub.clients.obj-type      no-undo.
  define variable v-cntxp-obj-code        like ub.clients.obj-code      no-undo.
  define variable v-cntxp-db-num          as integer   no-undo .
  define variable v-cntxp-userid          as character no-undo .
  define variable v-cntxp-level           as character no-undo .
  define variable v-cntxp-db-num-obj      as integer   no-undo .
  define variable v-cntxp-is-admin        as logical   no-undo .
  define buffer bf-cntxp_store for ub.store.
  define buffer bf-cntxp_shop  for ub.shop.
  define buffer bf-cntxp_sysconf for ub.sysconf.
define buffer bf-db_clients for ub.clients.
define buffer buf_trn-doc   for ub.trn-doc .
define buffer exp_trn-doc   for ub.trn-doc .
define buffer buf_parts     for ub.parts  .
define buffer buf_doc-line for ub.doc-line .
define buffer buf_gds-dtl   for ub.gds-dtl .
define buffer buf_goods for ub.goods .
define buffer buf_marking-lines for ub.marking-lines .
define buffer buf_marking for ub.marking .
define variable var-ok-assort-pol   as logical   no-undo .
define variable var-mess-assort-pol as character no-undo .
define variable v-file-n as character no-undo .
define variable v-ischg-ext-type as logical no-undo .
define variable v-is-exemplar-goods as logical   no-undo .
define variable v-mark-weight as decimal   no-undo .
define variable v-isweighed as logical   no-undo .
define variable v-message           as character no-undo .
define variable v-scan-qnty as  integer   no-undo.
define variable v-GTIN     as character no-undo .
define variable v-codident as character no-undo.
  do
  on error undo, return error return-value
  :
    find first buf_trn-doc exclusive-lock
      where buf_trn-doc.doc-code = p-doc-code
      no-error .
    if not available buf_trn-doc then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Не найден документ" skip
        "Номер документа" p-doc-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if buf_trn-doc.ext-doc-type = 'iv':U
    then do:
      buf_trn-doc.ext-doc-type = 'ie':U.
      buf_trn-doc.internal = false.
      buf_trn-doc.discnt-type = "".
      v-ischg-ext-type = true.
      buf_trn-doc.tot-cli = buf_trn-doc.tot-calc.
      buf_trn-doc.fact-date = today.
      for first buf_parts no-lock where buf_parts.out-code = buf_trn-doc.doc-code :
        buf_trn-doc.slt-type = buf_parts.slt-type .
      end .
    end.
    v-file-n = replace( buf_trn-doc.doc-code, "*", "$" ) .
    v-file-n = replace( v-file-n , ".", "$" ) .
    v-file-n = replace( v-file-n , "/", "$" ) .
    v-file-n = replace( v-file-n, "\", "$" ) .
    v-file-n = replace( v-file-n, "=", "$" ) .
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in parparentproc
    (output v-cntxp-db-num
    ,output v-cntxp-userid
    ,output v-cntxp-level
    ,output v-cntxp-curr-host-code
    ,output v-cntxp-obj-type
    ,output v-cntxp-obj-code
    ,output v-cntxp-db-num-obj
    ,output v-cntxp-is-admin
    ) .
  if (v-cntxp-obj-type = 'маг':U or v-cntxp-obj-type = 'скл':U) and
     v-cntxp-obj-code <> 0 then do:
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-prt'
  ,input  0
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  yes
  ,output v-cntxp-conf-par
  ,output v-cntxp-par-type
  ) no-error .
    case v-cntxp-obj-type :
      when 'скл':U then do:
        find first bf-cntxp_store where bf-cntxp_store.obj-code = v-cntxp-obj-code no-lock.
        find first bf-cntxp_sysconf where bf-cntxp_sysconf.host-code = bf-cntxp_store.host-code no-lock.
        assign
          v-cntxp-doc-prt         = (v-cntxp-conf-par = "yes") and bf-cntxp_store.doc-prt
          v-cntxp-price-calc      = bf-cntxp_store.price-calc
          v-cntxp-inout-price     = bf-cntxp_store.inout-price
          v-cntxp-unit-cli-perm   = bf-cntxp_store.unit-cli-perm
          v-cntxp-out-rate        = bf-cntxp_store.out-rate
          v-cntxp-out-line-discnt = bf-cntxp_store.out-line-discnt
          v-cntxp-in-ov           = bf-cntxp_store.in-ov
          v-cntxp-in-perm         = bf-cntxp_store.in-perm
          v-cntxp-no-eq           = bf-cntxp_store.no-eq
          v-cntxp-rsrv-time       = bf-cntxp_store.rsrv-time
          v-cntxp-load-time       = bf-cntxp_store.load-time
          v-cntxp-holidays        = bf-cntxp_store.holidays
          v-cntxp-in-pay          = bf-cntxp_store.in-pay
          v-cntxp-out-pay         = bf-cntxp_store.out-pay
          v-cntxp-ret-pay         = bf-cntxp_store.ret-pay
          v-cntxp-ret-sup-pay     = bf-cntxp_store.ret-sup-pay
          v-cntxp-down-pay        = bf-cntxp_store.down-pay
          v-cntxp-inv-pay         = bf-cntxp_store.inv-pay
          v-cntxp-chk-pay         = bf-cntxp_store.chk-pay
          v-cntxp-retail          = bf-cntxp_sysconf.ord-prt
          v-cntxp-osn-base        = bf-cntxp_sysconf.osn-base
          .
      end.
      when 'маг':U then do:
        find first bf-cntxp_shop where bf-cntxp_shop.obj-code = v-cntxp-obj-code no-lock.
        find first bf-cntxp_sysconf where bf-cntxp_sysconf.host-code = bf-cntxp_shop.host-code no-lock.
        assign
          v-cntxp-doc-prt         = (v-cntxp-conf-par = "yes") and bf-cntxp_shop.doc-prt
          v-cntxp-price-calc      = bf-cntxp_shop.price-calc
          v-cntxp-inout-price     = bf-cntxp_shop.inout-price
          v-cntxp-unit-cli-perm   = bf-cntxp_shop.unit-cli-perm
          v-cntxp-out-rate        = bf-cntxp_shop.out-rate
          v-cntxp-out-line-discnt = bf-cntxp_shop.out-line-discnt
          v-cntxp-in-ov           = bf-cntxp_shop.in-ov
          v-cntxp-in-perm         = bf-cntxp_shop.in-perm
          v-cntxp-no-eq           = bf-cntxp_shop.no-eq
          v-cntxp-rsrv-time       = bf-cntxp_shop.rsrv-time
          v-cntxp-load-time       = bf-cntxp_shop.load-time
          v-cntxp-holidays        = bf-cntxp_shop.holidays
          v-cntxp-in-pay          = bf-cntxp_shop.in-pay
          v-cntxp-out-pay         = bf-cntxp_shop.out-pay
          v-cntxp-ret-pay         = bf-cntxp_shop.ret-pay
          v-cntxp-ret-sup-pay     = bf-cntxp_shop.ret-sup-pay
          v-cntxp-down-pay        = bf-cntxp_shop.down-pay
          v-cntxp-inv-pay         = bf-cntxp_shop.inv-pay
          v-cntxp-chk-pay         = bf-cntxp_shop.chk-pay
          v-cntxp-retail          = bf-cntxp_sysconf.ord-prt
          v-cntxp-osn-base        = bf-cntxp_sysconf.osn-base
          .
      end.
    end case.
  end.
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hold-doc in g#library
  (input  buf_trn-doc.doc-code
  ,output l_is-hold-doc
  ) no-error .
    if error-status :error or l_is-hold-doc = ? then do:
       assign l_is-hold-doc = no
       .
    end.
    if  buf_trn-doc.doc-type = 'рас':U
    and not buf_trn-doc.flag_
    and buf_trn-doc.status_ <> 'разрешен':U
    then do:
      define buffer buf_user-login for ub.user-login .
      find buf_user-login no-lock
        where buf_user-login.db-num  = v-cntxt-db-num
          and buf_user-login.user-id = v-cntxt-userid
        .
      if  buf_trn-doc.discnt-pc > buf_user-login.max-discnt
      and lookup(buf_trn-doc.discnt-type, 'касс,карта,группа':U) = 0
      then do:
          message "Скидка по документу " buf_trn-doc.discnt-pc skip
                  " превышает максимально допустимую величину для данного пользователя (" buf_user-login.max-discnt "%).".
          return error.
      end.
    end.
    find first bf-db_clients where bf-db_clients.obj-type = buf_trn-doc.obj-type and
                                  bf-db_clients.obj-code = buf_trn-doc.obj-code no-lock.
    if buf_trn-doc.doc-type = 'при':U and
       buf_trn-doc.status_  = 'накл':U   and
       buf_trn-doc.internal = yes       and
       buf_trn-doc.ext-doc-type <> 'io':U then do:
      find first exp_trn-doc where exp_trn-doc.doc-code = buf_trn-doc.doc-code no-lock no-error.
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdtget in g#library
  (input  buf_trn-doc.obj-type
  ,input  buf_trn-doc.obj-code
  ,output varfact-date
  ) no-error .
      if error-status:error then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при получении текущей даты объекта" skip
          return-value skip
          trim(error-status :get-message(1))
          trim(error-status :get-message(2))
          trim(error-status :get-message(3))
          trim(error-status :get-message(4))
          trim(error-status :get-message(5)) skip
          view-as alert-box error.
          return error .
      end.
      define variable l-shift-on as logical no-undo .
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  buf_trn-doc.obj-type
  ,input  buf_trn-doc.obj-code
  ,input  'shift-on=request'
  ,output l-shift-on
  )  .
      if l-shift-on then do:
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curshift in g#library
  (input  buf_trn-doc.obj-type
  ,input  buf_trn-doc.obj-code
  ,output varshift-date
  ,output varshift-num
  ,output varshift-name
  ) no-error .
        if error-status:error then do:
          message
          vss-workfile vss-revision vss-description skip
          "Ошибка при получении текущей сменной даты объекта" skip
          return-value skip
          trim(error-status :get-message(1))
          trim(error-status :get-message(2))
          trim(error-status :get-message(3))
          trim(error-status :get-message(4))
          trim(error-status :get-message(5)) skip
          view-as alert-box error.
          return error .
        end.
      end.
      if available exp_trn-doc and
        exp_trn-doc.fact-date < varfact-date then do:
        assign varlog = no.
        message "Внутренний приход " buf_trn-doc.doc-code " будет закрыт с фактической календарной датой: " varfact-date skip
                "Внутренний расход " exp_trn-doc.doc-code " с объекта " exp_trn-doc.obj-type " " exp_trn-doc.doc-code " был календарной датой " exp_trn-doc.fact-date skip
                "Дата расхода меньше даты прихода. Продолжить?" view-as alert-box question update varlog.
        if not varlog then  return error.
      end.
      if available exp_trn-doc and
        (exp_trn-doc.shift-date < varshift-date or
          exp_trn-doc.shift-date = varshift-date and exp_trn-doc.shift-num < varshift-num) then do:
        assign varlog = no.
        message "Внутренний приход " buf_trn-doc.doc-code " будет закрыт с фактической сменой: " varshift-date " " varshift-num skip
                "Внутренний расход " exp_trn-doc.doc-code " с объекта " exp_trn-doc.obj-type " " exp_trn-doc.doc-code " был сменной датой " exp_trn-doc.shift-date " " exp_trn-doc.shift-num skip
                "Смена расхода меньше смены прихода. Продолжить?" view-as alert-box question update varlog.
        if not varlog then  return error.
      end.
    end.
    if  buf_trn-doc.doc-type = 'при':U
    and not buf_trn-doc.internal
    and not buf_trn-doc.flag_
    and buf_trn-doc.status_ = 'накл':U
    then do:
      if v-cntxt-db-num  = bf-db_clients.db-num then do:
        run gbl/d-askw.w
          (input "Вопрос"
          ,input "Закрытие приходной накладной" + chr(10)
            + substitute("ПН        &1", buf_trn-doc.doc-code) + chr(10)
            + substitute("Дата      &1", string(buf_trn-doc.doc-date, '99/99/9999':u)) + chr(10)
            + (if buf_trn-doc.fact-date <> ? then substitute("Факт дата &1", string(buf_trn-doc.fact-date, '99/99/9999':u)) else "") + chr(10)
            + substitute("Оператор  &1 (&2)", usrfulnf( buf_trn-doc.user-name) , buf_trn-doc.user-name )
          ,input "|^"
          ,input "Накл+" + '|':u
              + "Факт+" + '|':u
              + "Отмена"
          ,input "С редактированием фактически принятого количества (накл+)|"
              + "Без редактирования (факт+)|"
              + "Отмена закрытия приходной накладной"
          ,input 1
          ,input 3
          ,output v-close-type
          ).
        case v-close-type
        :
          when 1
          then do:
            define buffer buf_utd for ub.utd .
            if can-find(first buf_utd no-lock where buf_utd.doc-code = buf_trn-doc.doc-code)
            then do :
              message "Для накладных созданных на основе электронных документов возможно только закрытие на Факт!" view-as alert-box .
              return error .
            end .
define variable vss-include-info26 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_income_preparation':U
    ,input  'object':U
    ,input  buf_trn-doc.host-code
    ,input  buf_trn-doc.obj-type
    ,input  buf_trn-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output varlog
    )  .
end.
            if not varlog then  return error.
            assign
              varmode = '<закрытие документа>':U
            .
          end.
          when 2
          then do:
define variable vss-include-info27 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_income_fact':U
    ,input  'object':U
    ,input  buf_trn-doc.host-code
    ,input  buf_trn-doc.obj-type
    ,input  buf_trn-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output varlog
    )  .
end.
            if not varlog then  return error.
            assign
              varmode = '<закрытие документа на факт>':U
            .
          end.
          when 3
          then do:
            return error.
          end.
          otherwise do:
            message
              vss-workfile vss-revision vss-description skip
              "Способ закрытия накладной" skip
              "Неизвестное значение" v-num skip
              view-as alert-box error .
            undo, return error return-value .
          end.
        end case .
      end.
      else do:
        assign varmode = '<закрытие документа>':U.
      end.
    end.
    else if  buf_trn-doc.doc-type = 'рас':U
    and not buf_trn-doc.internal
    and not buf_trn-doc.flag_
    and buf_trn-doc.status_ = 'накл':U
    and not buf_trn-doc.is-flora
    then do:
      if v-cntxt-db-num  = bf-db_clients.db-num then do:
        run gbl/d-askw.w
          (input "Вопрос"
          ,input "Закрытие расходной накладной" + chr(10)
            + substitute("РН        &1", buf_trn-doc.doc-code) + chr(10)
            + substitute("Дата      &1", string(buf_trn-doc.doc-date, '99/99/9999':u)) + chr(10)
            + (if buf_trn-doc.fact-date <> ? then substitute("Факт дата &1", string(buf_trn-doc.fact-date, '99/99/9999':u)) else "") + chr(10)
            + substitute("Оператор  &1 (&2)", usrfulnf( buf_trn-doc.user-name) , buf_trn-doc.user-name )
          ,input "|^"
          ,input "Накл+" + '|':u
               + "Факт+" + '|':u
               + "Отмена"
          ,input "Без редактирования фактического количества (накл+)|"
               + "Без редактирования (факт+)|"
               + "Отмена закрытия расходной накладной"
          ,input 1
          ,input 3
          ,output v-close-type
          ).
        case v-close-type
        :
          when 1
          then do:
define variable vss-include-info28 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_expense_preparation':U
    ,input  'object':U
    ,input  buf_trn-doc.host-code
    ,input  buf_trn-doc.obj-type
    ,input  buf_trn-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output varlog
    )  .
end.
            if not varlog then  return error.
            assign
              varmode = '<закрытие документа>':U
            .
          end.
          when 2
          then do:
define variable vss-include-info29 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_expense_fact':U
    ,input  'object':U
    ,input  buf_trn-doc.host-code
    ,input  buf_trn-doc.obj-type
    ,input  buf_trn-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output varlog
    )  .
end.
            if not varlog then  return error.
            assign
              varmode = '<закрытие документа на факт>':U
            .
          end.
          when 3
          then do:
            return error.
          end.
          otherwise do:
            message
              vss-workfile vss-revision vss-description skip
              "Способ закрытия накладной" skip
              "Неизвестное значение" v-num skip
              view-as alert-box error .
            undo, return error return-value .
          end.
        end case .
      end.
      else do:
        assign varmode = '<закрытие документа>':U.
      end.
    end.
    else do:
        assign varmode = '<закрытие документа>':U.
    end.
    run str/trn-graf.p (input  buf_trn-doc.doc-code,
                    input  v-cntxt-db-num,
                    input  varmode,
                    output varstatus,
                    output varflag,
                    output varcopystatus,
                    output varcopyflag
                    ) no-error.
    if error-status:error then do:
      if error-status :get-message(1) <> "" or
          return-value = ""                  then do:
        message "Ошибка при вызове trn-graf.p." skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error.
      end.
      else do:
        message return-value
        view-as alert-box error.
      end.
      return error.
    end.
    if buf_trn-doc.fact-date <> ?
    then do:
      if varstatus = 'факт':U
      then do:
        run str/chk-back.p
          (input buf_trn-doc.doc-code
          ,input buf_trn-doc.fact-date
          ) no-error .
        if error-status :error
        then do:
          if error-status :get-message(1) <> ""
          or return-value = ""
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при вызове процедуры chk-back.p" skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
          end.
          else do:
            message
              return-value skip
              view-as alert-box error .
          end.
          return error .
        end.
      end.
    end.
    if buf_trn-doc.doc-type = 'инв':U then do :
      assign
        v-pay-agent-fl1 = false
        v-pay-agent-fl2 = false
      .
      for each ub.doc-line where ub.doc-line.doc-code = buf_trn-doc.doc-code:
        find first ub.goods no-lock
             where ub.goods.artic     = ub.doc-line.artic
               and ub.goods.prod-type = ub.doc-line.prod-type
               and ub.goods.prod-code = ub.doc-line.prod-code no-error.
        if available ub.goods then do :
          if can-find (first ub.goods-attr
                       where ub.goods-attr.gds-code   = ub.goods.gds-code
                         and ub.goods-attr.attr-code  = 'oper-serv-idd':U)
          then do :
            assign
              v-pay-agent-gd1 = ub.goods.gds-code
              v-pay-agent-nm1 = ub.goods.gds-name
              v-pay-agent-ar1 = ub.doc-line.artic
              v-pay-agent-fl1 = true
            .
            if v-pay-agent-fl2 then leave .
          end .
          else do :
            assign
              v-pay-agent-gd2 = ub.goods.gds-code
              v-pay-agent-nm2 = ub.goods.gds-name
              v-pay-agent-ar2 = ub.doc-line.artic
              v-pay-agent-fl2 = true
            .
            if v-pay-agent-fl1 then leave .
          end .
        end .
      end.
      if v-pay-agent-fl1 and v-pay-agent-fl2 then do :
        message
          substitute("Ошибка закрытия документа &1", buf_trn-doc.doc-code) skip
          substitute("Товар платёжного агента &1 &2 (арт. &3) " +
                     "должен проводиться отдельным документом от обычного товара &4 &5 (арт. &6)",
            v-pay-agent-gd1, v-pay-agent-nm1, v-pay-agent-ar1,
            v-pay-agent-gd2, v-pay-agent-nm2, v-pay-agent-ar2
                    )
        view-as alert-box .
        return error.
      end .
    end .
    if varstatus = 'факт':U and (buf_trn-doc.ext-doc-type = 'ep':U or buf_trn-doc.ext-doc-type = 'ev':U or buf_trn-doc.ext-doc-type = 'ee':U)
    then do:
      if can-find (ub.doc-attr where ub.doc-attr.doc-code = buf_trn-doc.doc-code and ub.doc-attr.attr-code = 'negais':U)
      then do:
define variable vss-include-info30 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_egais-chg-sts-doc':U
    ,input  'object':U
    ,input  buf_trn-doc.host-code
    ,input  buf_trn-doc.obj-type
    ,input  buf_trn-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output varlog
    )  .
end.
        if not varlog
        then do:
          if not can-find (ub.doc-attr where ub.doc-attr.doc-code = buf_trn-doc.doc-code and ub.doc-attr.attr-code = 'egais':U and ub.doc-attr.attr-value = "Accepted" )
          then do:
            message 'Для закрытия накладной на факт, которая отправлена в ЕГАИС и отсутствует акт подтверждения от контрагента, требуется право "Изменение статуса документа ЕГАИС".'
            view-as alert-box error.
            return error.
          end.
        end.
        else do:
          varlog = false.
          message "Вы уверены что хотите закрыть накладную, которая отправлена в ЕГАИС и отсутствует акт подтверждения от контрагента?"
                "Вы уверены ?" view-as alert-box question buttons OK-Cancel update varlog.
          if not varlog
            then return error.
        end.
      end.
    end.
    if buf_trn-doc.flag_                and
      buf_trn-doc.status_ = 'запрос':U then do:
    varlog = no.
    message "Создание накладной по запросу №" buf_trn-doc.doc-code skip (2)
            (if buf_trn-doc.doc-type  = 'при':U and
                buf_trn-doc.internal = no then "В новую ПН будет скопировано из запроса все, что еще не включено в другие ПН по этому запросу."
              else "При недостатке товара запрос по некоторым товарам (признакам) может быть удовлетворен ЧАСТИЧНО.")
            "Вы уверены ?" view-as alert-box question buttons OK-Cancel update varlog.
    if not varlog then  return error.
      case buf_trn-doc.doc-type
      :
        when 'при':U
        then do:
define variable vss-include-info31 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_income_preparation':U
    ,input  'object':U
    ,input  buf_trn-doc.host-code
    ,input  buf_trn-doc.obj-type
    ,input  buf_trn-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output varlog
    )  .
end.
        end.
        when 'рас':U
        then do:
define variable vss-include-info32 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_expense_preparation':U
    ,input  'object':U
    ,input  buf_trn-doc.host-code
    ,input  buf_trn-doc.obj-type
    ,input  buf_trn-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output varlog
    )  .
end.
        end.
        when 'спи':U
        then do:
define variable vss-include-info33 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_write-off_preparation':U
    ,input  'object':U
    ,input  buf_trn-doc.host-code
    ,input  buf_trn-doc.obj-type
    ,input  buf_trn-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output varlog
    )  .
end.
        end.
        when 'инв':U
        then do:
define variable vss-include-info34 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_inventory_preparation':U
    ,input  'object':U
    ,input  buf_trn-doc.host-code
    ,input  buf_trn-doc.obj-type
    ,input  buf_trn-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output varlog
    )  .
end.
        end.
        when 'возврат':U
        then do:
define variable vss-include-info35 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_return_preparation':U
    ,input  'object':U
    ,input  buf_trn-doc.host-code
    ,input  buf_trn-doc.obj-type
    ,input  buf_trn-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output varlog
    )  .
end.
        end.
        otherwise do:
          message
            vss-workfile vss-revision vss-description skip
            "Неизвестный тип документа" skip
            "Тип документа" buf_trn-doc.doc-type skip
            "Код документа" buf_trn-doc.doc-code skip
            view-as alert-box error .
          undo, return error return-value .
        end.
      end case .
    if not varlog then  return error.
    end.
    else do:
      if varstatus = 'факт':U then do:
        if v-cntxt-db-num <> bf-db_clients.db-num then do:
          message "Накладную можно закрыть на факт только на базе данных объекта"
          view-as alert-box error.
          return error.
        end.
        varlog = no.
        if buf_trn-doc.ext-doc-type = 'io':U then do :
            varlog = yes.
        end.
        else do :
          if is-mes(buf_trn-doc.doc-code) then do:
            varlog = false .
          end.
          else do:
          if buf_trn-doc.reason-code = 99 then
          do:
          varvalue = "" .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input buf_trn-doc.doc-code ,
                        input 'sugtpattr-massa-sug':U ,
                       output varvalue_massa-sug ,
                       output vartype ) no-error .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input buf_trn-doc.doc-code ,
                        input 'sugtpattr-teh-loss':U ,
                       output varvalue_teh-loss ,
                       output vartype ) no-error .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input buf_trn-doc.doc-code ,
                        input 'sugtpattr-err-allow':U ,
                       output varvalue_err-allow ,
                       output vartype ) no-error .
            if varvalue_err-allow = '' or varvalue_teh-loss = '' or varvalue_massa-sug = '' then
            varvalue = "Не заполнены данные для расчета технологических потерь.~n" .
              else varvalue = "".
          end.
          message varvalue
                  "Закрыть накладную № " buf_trn-doc.doc-code " до статуса ФАКТ?" skip (2)
                  view-as alert-box question buttons OK-Cancel title "Вопрос" update varlog.
        end.
        if not varlog then  return error.
        case buf_trn-doc.doc-type
        :
          when 'при':U
          then do:
define variable vss-include-info36 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_income_fact':U
    ,input  'object':U
    ,input  buf_trn-doc.host-code
    ,input  buf_trn-doc.obj-type
    ,input  buf_trn-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output varlog
    )  .
end.
          end.
          when 'рас':U
          then do:
define variable vss-include-info37 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_expense_fact':U
    ,input  'object':U
    ,input  buf_trn-doc.host-code
    ,input  buf_trn-doc.obj-type
    ,input  buf_trn-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output varlog
    )  .
end.
          end.
          when 'спи':U
          then do:
define variable vss-include-info38 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_write-off_fact':U
    ,input  'object':U
    ,input  buf_trn-doc.host-code
    ,input  buf_trn-doc.obj-type
    ,input  buf_trn-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output varlog
    )  .
end.
          end.
          when 'инв':U
          then do:
define variable vss-include-info39 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_inventory_fact':U
    ,input  'object':U
    ,input  buf_trn-doc.host-code
    ,input  buf_trn-doc.obj-type
    ,input  buf_trn-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output varlog
    )  .
end.
          end.
          when 'возврат':U
          then do:
define variable vss-include-info40 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_return_fact':U
    ,input  'object':U
    ,input  buf_trn-doc.host-code
    ,input  buf_trn-doc.obj-type
    ,input  buf_trn-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output varlog
    )  .
end.
          end.
          otherwise do:
            message
              vss-workfile vss-revision vss-description skip
              "Неизвестный тип документа" skip
              "Тип документа" buf_trn-doc.doc-type skip
              "Код документа" buf_trn-doc.doc-code skip
              view-as alert-box error .
            undo, return error return-value .
          end.
        end case .
        if not varlog then  return error.
       end.
       end.
      else do:
        if can-do ('рас,спи,возврат':U, buf_trn-doc.doc-type) and
                  buf_trn-doc.status_   = 'накл':U                     and
                  buf_trn-doc.flag_                                   then do:
            message "Разрешение по накладной № " buf_trn-doc.doc-code skip (2)
                    "Вы уверены ?"
                    view-as alert-box question buttons OK-Cancel update varlog.
            if not varlog then  return error.
            case buf_trn-doc.doc-type
            :
              when 'при':U
              then do:
define variable vss-include-info41 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_income_permission':U
    ,input  'object':U
    ,input  buf_trn-doc.host-code
    ,input  buf_trn-doc.obj-type
    ,input  buf_trn-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output varlog
    )  .
end.
              end.
              when 'рас':U
              then do:
define variable vss-include-info42 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_expense_permission':U
    ,input  'object':U
    ,input  buf_trn-doc.host-code
    ,input  buf_trn-doc.obj-type
    ,input  buf_trn-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output varlog
    )  .
end.
              end.
              when 'спи':U
              then do:
define variable vss-include-info43 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_write-off_permission':U
    ,input  'object':U
    ,input  buf_trn-doc.host-code
    ,input  buf_trn-doc.obj-type
    ,input  buf_trn-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output varlog
    )  .
end.
              end.
              when 'инв':U
              then do:
define variable vss-include-info44 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_inventory_permission':U
    ,input  'object':U
    ,input  buf_trn-doc.host-code
    ,input  buf_trn-doc.obj-type
    ,input  buf_trn-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output varlog
    )  .
end.
              end.
              when 'возврат':U
              then do:
define variable vss-include-info45 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_return_permission':U
    ,input  'object':U
    ,input  buf_trn-doc.host-code
    ,input  buf_trn-doc.obj-type
    ,input  buf_trn-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output varlog
    )  .
end.
              end.
              otherwise do:
                message
                  vss-workfile vss-revision vss-description skip
                  "Неизвестный тип документа" skip
                  "Тип документа" buf_trn-doc.doc-type skip
                  "Код документа" buf_trn-doc.doc-code skip
                  view-as alert-box error .
                undo, return error return-value .
              end.
            end case .
            if not varlog then  return error.
        end.
        else do:
          if buf_trn-doc.ext-doc-type = 'vt':U then do:
            if buf_trn-doc.status_ = 'накл':U then do:
              if buf_trn-doc.flag_   = no      then do:
                  case buf_trn-doc.doc-type
                  :
                    when 'при':U
                    then do:
define variable vss-include-info46 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_income_preparation':U
    ,input  'object':U
    ,input  buf_trn-doc.host-code
    ,input  buf_trn-doc.obj-type
    ,input  buf_trn-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output varlog
    )  .
end.
                    end.
                    when 'рас':U
                    then do:
define variable vss-include-info47 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_expense_preparation':U
    ,input  'object':U
    ,input  buf_trn-doc.host-code
    ,input  buf_trn-doc.obj-type
    ,input  buf_trn-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output varlog
    )  .
end.
                    end.
                    when 'спи':U
                    then do:
define variable vss-include-info48 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_write-off_preparation':U
    ,input  'object':U
    ,input  buf_trn-doc.host-code
    ,input  buf_trn-doc.obj-type
    ,input  buf_trn-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output varlog
    )  .
end.
                    end.
                    when 'инв':U
                    then do:
define variable vss-include-info49 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_inventory_preparation':U
    ,input  'object':U
    ,input  buf_trn-doc.host-code
    ,input  buf_trn-doc.obj-type
    ,input  buf_trn-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output varlog
    )  .
end.
                    end.
                    when 'возврат':U
                    then do:
define variable vss-include-info50 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_return_preparation':U
    ,input  'object':U
    ,input  buf_trn-doc.host-code
    ,input  buf_trn-doc.obj-type
    ,input  buf_trn-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output varlog
    )  .
end.
                    end.
                    otherwise do:
                      message
                        vss-workfile vss-revision vss-description skip
                        "Неизвестный тип документа" skip
                        "Тип документа" buf_trn-doc.doc-type skip
                        "Код документа" buf_trn-doc.doc-code skip
                        view-as alert-box error .
                      undo, return error return-value .
                    end.
                  end case .
                if not varlog then return error .
                varlog = no.
                if not is-mes(buf_trn-doc.doc-code) then do:
                message
                  "Документ №" buf_trn-doc.doc-code skip (2)
                  "Закрыть ОПИСЬ инвентаризации?" skip
                  "Вы уверены?"
                  view-as alert-box question buttons OK-Cancel update varlog.
                  if not varlog then return error .
                                end.
              end.
              else do:
                  case buf_trn-doc.doc-type
                  :
                    when 'при':U
                    then do:
define variable vss-include-info51 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_income_permission':U
    ,input  'object':U
    ,input  buf_trn-doc.host-code
    ,input  buf_trn-doc.obj-type
    ,input  buf_trn-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output varlog
    )  .
end.
                    end.
                    when 'рас':U
                    then do:
define variable vss-include-info52 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_expense_permission':U
    ,input  'object':U
    ,input  buf_trn-doc.host-code
    ,input  buf_trn-doc.obj-type
    ,input  buf_trn-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output varlog
    )  .
end.
                    end.
                    when 'спи':U
                    then do:
define variable vss-include-info53 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_write-off_permission':U
    ,input  'object':U
    ,input  buf_trn-doc.host-code
    ,input  buf_trn-doc.obj-type
    ,input  buf_trn-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output varlog
    )  .
end.
                    end.
                    when 'инв':U
                    then do:
define variable vss-include-info54 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_inventory_permission':U
    ,input  'object':U
    ,input  buf_trn-doc.host-code
    ,input  buf_trn-doc.obj-type
    ,input  buf_trn-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output varlog
    )  .
end.
                    end.
                    when 'возврат':U
                    then do:
define variable vss-include-info55 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_return_permission':U
    ,input  'object':U
    ,input  buf_trn-doc.host-code
    ,input  buf_trn-doc.obj-type
    ,input  buf_trn-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output varlog
    )  .
end.
                    end.
                    otherwise do:
                      message
                        vss-workfile vss-revision vss-description skip
                        "Неизвестный тип документа" skip
                        "Тип документа" buf_trn-doc.doc-type skip
                        "Код документа" buf_trn-doc.doc-code skip
                        view-as alert-box error .
                      undo, return error return-value .
                    end.
                  end case .
                if not varlog then return error .
                varlog = no.
                if not is-mes(buf_trn-doc.doc-code) then do:
                message
                  "Документ №" buf_trn-doc.doc-code skip (2)
                  "Начать инвентаризацию по документу?" skip
                  "Вы уверены?" skip
                  view-as alert-box question buttons OK-Cancel update varlog.
                if not varlog then return error.
                                end.
              end.
            end.
            else do:
                message "Ошибка при закрытии инвентаризации."
                        "Инвентаризация должна закрываться на факт."
                        view-as alert-box error.
                return error.
            end.
          end.
          else do:
            varlog = no.
            message "Документ :" buf_trn-doc.status_ "№" buf_trn-doc.doc-code skip
                    "Вы уверены, что хотите завершить ввод и редактирование ?"
                    view-as alert-box question buttons OK-Cancel update varlog.
            if not varlog then  return error.
            case buf_trn-doc.doc-type
            :
              when 'при':U
              then do:
define variable vss-include-info56 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_income_preparation':U
    ,input  'object':U
    ,input  buf_trn-doc.host-code
    ,input  buf_trn-doc.obj-type
    ,input  buf_trn-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output varlog
    )  .
end.
              end.
              when 'рас':U
              then do:
define variable vss-include-info57 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_expense_preparation':U
    ,input  'object':U
    ,input  buf_trn-doc.host-code
    ,input  buf_trn-doc.obj-type
    ,input  buf_trn-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output varlog
    )  .
end.
              end.
              when 'спи':U
              then do:
define variable vss-include-info58 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_write-off_preparation':U
    ,input  'object':U
    ,input  buf_trn-doc.host-code
    ,input  buf_trn-doc.obj-type
    ,input  buf_trn-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output varlog
    )  .
end.
              end.
              when 'инв':U
              then do:
define variable vss-include-info59 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_inventory_preparation':U
    ,input  'object':U
    ,input  buf_trn-doc.host-code
    ,input  buf_trn-doc.obj-type
    ,input  buf_trn-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output varlog
    )  .
end.
              end.
              when 'возврат':U
              then do:
define variable vss-include-info60 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_return_preparation':U
    ,input  'object':U
    ,input  buf_trn-doc.host-code
    ,input  buf_trn-doc.obj-type
    ,input  buf_trn-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output varlog
    )  .
end.
              end.
              otherwise do:
                message
                  vss-workfile vss-revision vss-description skip
                  "Неизвестный тип документа" skip
                  "Тип документа" buf_trn-doc.doc-type skip
                  "Код документа" buf_trn-doc.doc-code skip
                  view-as alert-box error .
                undo, return error return-value .
              end.
            end case .
            if not varlog then  return error.
          end.
        end.
      end.
    end.
    if buf_trn-doc.doc-type <> 'инв':U then do:
      for each buf_doc-line where buf_doc-line.doc-code = buf_trn-doc.doc-code:
        find first buf_goods where buf_goods.artic     = buf_doc-line.artic     and
                                buf_goods.prod-type = buf_doc-line.prod-type and
                                buf_goods.prod-code = buf_doc-line.prod-code no-lock.
        if varstatus         =  'факт':U            and
          buf_doc-line.doc-qnty <> buf_doc-line.fact-qnty then do:
          if buf_doc-line.fact-qnty = 0  and  l_is-hold-doc and buf_trn-doc.ext-doc-type = 'ee':U then do:
          message "Артикул: " buf_doc-line.artic " " buf_goods.gds-name skip
                  "Фактическое количество по строке: " buf_doc-line.fact-qnty " " buf_goods.unit-base skip(2)
                  "Для межфирменного перемещения это запрещено"
                  view-as alert-box error  .
             return error.
          end.
          if (v-not-eq-count <> 2) then do:
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input buf_doc-line.artic
  ,  input buf_doc-line.prod-type
  ,  input buf_doc-line.prod-code
  , output v-is-petrl
  , output v-is-pieces
  ) .
              if v-is-petrl = true
                and v-is-pieces = false
              then do:
                  v-not-eq-count = 2.
                end.
                else do:
                  run gbl/d-askw.w(
                      input "Накладная"
                      ,"Артикул: " + string(buf_doc-line.artic) + " " + buf_goods.gds-name + chr(10) +
                                    "Количество по строке накладной: " + string(buf_doc-line.doc-qnty) + " " + string(buf_goods.unit-base) + chr(10) +
                                    "Фактическое количество по строке: " + string(buf_doc-line.fact-qnty) + " " + string(buf_goods.unit-base) + chr(10) +
                                    "Подтвердить количество в накладной?"
                    ,input "|^"
                    ,input "Да|Да (для всех)|Нет"
                    ,input "подтвердить для текущей позиции|подтвердить для всех позиций|отменить переход документа в статус факт"
                    ,input 1
                    ,input 3
                    ,output v-not-eq-count
                    ).
                end.
                if (v-not-eq-count = 3) then return error.
            end.
        end.
      end.
    end.
    if buf_trn-doc.doc-type = 'при':U and
      buf_trn-doc.internal = no        then do:
      for each buf_doc-line where buf_doc-line.doc-code = buf_trn-doc.doc-code:
        find first buf_goods where buf_goods.artic     = buf_doc-line.artic     and
                                buf_goods.prod-type = buf_doc-line.prod-type and
                                buf_goods.prod-code = buf_doc-line.prod-code no-lock.
          run str/chk-prt.p (recid(buf_doc-line), yes , buffer buf_trn-doc).
          if (not buf_trn-doc.flag_ and buf_doc-line.doc-qnty = 0) or
              (buf_trn-doc.flag_     and buf_doc-line.fact-qnty = 0) then do:
              varlog = no.
              message "Артикул : " buf_doc-line.artic buf_goods.gds-name ". Ед. изм. :" buf_goods.unit-base
                      skip
                      "По этой строке НУЛЕВОЕ количество !"
                      skip (2)
                      "Будем закрывать документ?"
                      view-as alert-box question buttons yes-no update varlog.
              if not varlog then  return error.
            end.
            if varstatus <> 'факт':U and buf_doc-line.prt-OK = ? then do:
              varlog = yes.
              message "Артикул : " buf_doc-line.artic buf_goods.gds-name skip
                      "Не указаны количества по шкале." skip (2)
                      "Вы хотите, чтобы это было сделано на складе при ФАКТ закрытии ?" skip (2)
                      "Будем закрывать документ?"
                      view-as alert-box question buttons yes-no update varlog.
              if not varlog then  return error.
            end.
      end.
define variable vss-include-info61 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
empty temp-table thbjattr_thbj-attr.
run adm/shattri.p (
   input "get":U
  ,input ''
  ,input 0
  ,input 'nakl-glob':U
  ,input  ""
  ,output v-value-character
  ,output v-value-date
  ,output v-value-decimal
  ,output v-value-integer
  ,output v-value-logical
  ,output par-type
  ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
  ) no-error .
      for each thbjattr_thbj-attr :
          if thbjattr_thbj-attr.prop-code = 'prc-exp':U then varperc-expvalue = string(thbjattr_thbj-attr.property-value-decimal) .
      end.
      empty temp-table thbjattr_thbj-attr.
      if varperc-expvalue = ? then varpercent-expense = 5.
                              else varpercent-expense = decimal(varperc-expvalue).
      if buf_trn-doc.tot-transp / buf_trn-doc.tot-cli * 100 > varpercent-expense then do:
          varlog = no.
          message "Транспортные расходы больше " varpercent-expense "% от суммы документа." skip
                  "Продолжить?"
          view-as alert-box question buttons yes-no update varlog.
          if not varlog then return error.
      end.
      if buf_trn-doc.tot-other / buf_trn-doc.tot-cli * 100 > varpercent-expense then do:
          varlog = no.
          message "Прочие расходы больше " varpercent-expense "% от суммы документа." skip
                  "Продолжить?"
          view-as alert-box question buttons yes-no update varlog.
          if not varlog then return error.
      end.
    end.
    if buf_trn-doc.doc-type = 'спи':U then
    do:
      v-message = "".
      for each buf_doc-line where
               buf_doc-line.doc-code = buf_trn-doc.doc-code no-lock,
          each buf_gds-dtl where
               buf_gds-dtl.doc-code  = buf_trn-doc.doc-code
           and buf_gds-dtl.artic     = buf_doc-line.artic
           and buf_gds-dtl.prod-code = buf_doc-line.prod-code
           and buf_gds-dtl.prod-type = buf_doc-line.prod-type no-lock,
          first buf_goods where
               buf_goods.artic = buf_gds-dtl.artic
           and buf_goods.prod-code = buf_gds-dtl.prod-code
           and buf_goods.prod-type = buf_gds-dtl.prod-type no-lock:
        run isExemplarGoods in g#attr-lib
          (buf_trn-doc.obj-type, buf_trn-doc.obj-code, buf_goods.gds-code, output v-is-exemplar-goods).
        v-isweighed = WghProdVariable(buf_trn-doc.obj-type, buf_trn-doc.obj-code, buf_goods.gds-code) .
        if v-isweighed
        then do :
          v-mark-weight = 0 .
          for each buf_marking-lines no-lock where buf_marking-lines.obj-type = buf_trn-doc.obj-type
                                               and buf_marking-lines.obj-code = buf_trn-doc.obj-code
                                               and buf_marking-lines.gds-code = buf_goods.gds-code
                                               and buf_marking-lines.out-code = buf_trn-doc.doc-code
                                               and buf_marking-lines.doc-level = 1,
            first buf_marking no-lock where
                  buf_marking.mark = buf_marking-lines.mark
          :
            v-mark-weight = v-mark-weight + MarkWeight(buf_marking.mark).
          end .
          if buf_gds-dtl.doc-qnty <> v-mark-weight then
          do:
define variable vss-include-info62 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_write-off_add-no-mark':U
    ,input  'object':U
    ,input  buf_trn-doc.host-code
    ,input  buf_trn-doc.obj-type
    ,input  buf_trn-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output varlog
    )  .
end.
            if not varlog then do :
              message "В документе присутствуют товары с помарочной прослеживаемостью в Честном Знаке. Для закрытия списания добавьте марки" view-as alert-box .
              return error.
            end .
            v-message = substitute(
                "&1~nПо товару &2 &3 списывается &4 просканировано &5",
                v-message, buf_goods.artic, buf_goods.gds-name, buf_gds-dtl.doc-qnty, v-mark-weight).
          end.
        end .
        else
        if v-is-exemplar-goods then do:
          v-scan-qnty = 0.
          for each buf_marking-lines no-lock where buf_marking-lines.obj-type = buf_trn-doc.obj-type
                                               and buf_marking-lines.obj-code = buf_trn-doc.obj-code
                                               and buf_marking-lines.gds-code = buf_goods.gds-code
                                               and buf_marking-lines.out-code = buf_trn-doc.doc-code
                                               and buf_marking-lines.doc-level = 1
          :
            v-codident = GetCodeIdent(buf_marking-lines.mark).
            v-GTIN = getGtinByDM(if v-codident <> ? and v-codident <> "" then v-codident else buf_marking-lines.mark) .
            v-scan-qnty = v-scan-qnty +  getQntyCodeByGtin(v-GTIN) .
          end .
          if buf_gds-dtl.doc-qnty <> v-scan-qnty then
          do:
define variable vss-include-info63 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_write-off_add-no-mark':U
    ,input  'object':U
    ,input  buf_trn-doc.host-code
    ,input  buf_trn-doc.obj-type
    ,input  buf_trn-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output varlog
    )  .
end.
            if not varlog then do :
              message "В документе присутствуют товары с помарочной прослеживаемостью в Честном Знаке. Для закрытия списания добавьте марки" view-as alert-box .
              return error.
            end .
            v-message = substitute(
                "&1~nПо товару &2 &3 списывается &4 просканировано &5",
                v-message, buf_goods.artic, buf_goods.gds-name, buf_gds-dtl.doc-qnty, v-scan-qnty).
          end.
        end.
      end.
      if v-message <> "" then
      do:
        varlog = no.
        message v-message skip
          "Продолжить?"
          view-as alert-box question buttons yes-no update varlog.
        if not varlog then return error.
      end.
    end.
    if  not buf_trn-doc.flag_               and
        buf_trn-doc.status_   = 'накл':U     and
        buf_trn-doc.doc-type  = 'возврат':U   and
        buf_trn-doc.internal  = no          and
        buf_trn-doc.out-code <> ?
    then do:
      varlog = no.
      message "Документ :" buf_trn-doc.status_ "№" buf_trn-doc.doc-code skip (2)
              "Указан документ - источник №" buf_trn-doc.out-code skip (2)
              "Проверить по нему суммарный возврат ?" skip
              "Внимание !!!  Проверка суммарного возврата по РН -"
              "ОЧЕНЬ долгая операция." skip (2)
              view-as alert-box question buttons YES-NO update varlog.
      if varlog = yes then do:
        assign varcheck-return = yes.
      end.
      else do:
        assign varcheck-return = no.
      end.
    end.
      if buf_trn-doc.creid <> v-cntxt-userid or true  then do:
        run str/trn-hist.p
           ( buffer buf_trn-doc ,
            input  v-cntxt-obj-type ,
            input  v-cntxt-obj-code ,
            input  "Закрытие документа"
            ) .
      end.
      if ( buf_trn-doc.ext-doc-type =  'ee':U      or
          buf_trn-doc.ext-doc-type =  'ep':U ) and
          buf_trn-doc.status_      <> 'запрос':U              then do:
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_canclsee in g#lib-trn3 (  input buf_trn-doc.doc-code ,
                       output l_can-close_ee-ep ) no-error .
        if error-status :error or l_can-close_ee-ep <> yes then do:
          message substitute( 'Ошибка при закрытии документа "&1", тип "&2", статус "&3":',
                              buf_trn-doc.doc-code,
                              entry( lookup( buf_trn-doc.ext-doc-type, 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U ), 'приход внешний,расход внешний,возврат пост.,касса продажа,возврат внешний,касса возврат,списание,инвентаризация,пересортица,приход внутренний,расход внутренний,возврат внутренний,расход  произв.,списан. произв.,приход  произв.,переоценка,коррекция учетных цен,корректировка отрицательных партий,смена типа приобретения,приход внутриобъектный,расход внутриобъектный':U ),
                              string( string( buf_trn-doc.status_ ) + string( buf_trn-doc.flag_, "+/-":U ) ) ) skip( 0 )
                  'Не заведены номер доверенности и/или дата доверенности.' skip( 0 )
                  error-status :get-message( 1 ) skip( 0 )
                  return-value skip( 0 )
          view-as alert-box error.
          undo, return error.
        end.
      end.
      if ( varmode            = '<закрытие документа>':U    or
          varmode            = '<закрытие документа на факт>':U ) and
          varstatus          = 'факт':U         and
          buf_trn-doc.ext-doc-type = 'vt':U    then do:
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_invdnull in g#lib-trn3 ( input buf_trn-doc.doc-code
                     , input yes ) no-error .
        if error-status :error then do:
          message vss-workfile skip( 0 ) vss-date skip( 0 ) vss-revision skip( 1 ) vss-description     skip( 1 )
                  substitute( 'Ошибка проверки нулевых строк в инвентаризации "&1".', buf_trn-doc.doc-code ) skip( 0 )
                  error-status :get-message( 1 )                                                       skip( 0 )
                  return-value                                                                         skip( 1 )
          view-as alert-box error.
          undo, return error.
        end.
      end.
define variable vss-include-info64 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hold-doc in g#library
  (input  buf_trn-doc.doc-code
  ,output l_is-hold-doc
  ) no-error .
      if error-status :error or l_is-hold-doc = ? then do: assign l_is-hold-doc = no. end.
      if ( varmode            = '<закрытие документа>':U             or
           varmode            = '<закрытие документа на факт>':U )
           and
          buf_trn-doc.ext-doc-type = 'ep':U  and
          l_is-hold-doc      = yes then do:
            define variable v-cut-date as date   no-undo init ?.
            define variable v-cut-fin-date as date   no-undo .
            define variable v-status       as integer   no-undo .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cutd-obj in g#library
  (input  buf_trn-doc.obj-type
  ,input  buf_trn-doc.obj-code
  ,output v-status
  ,output v-cut-date
  ,output v-cut-fin-date
  ) no-error .
              if not error-status :error then do:
                if v-cut-date <> ? then do:
                   for each buf_parts no-lock where buf_parts.out-code  = buf_trn-doc.doc-code :
                       if buf_parts.hold-date  = ? or buf_parts.hold-date < v-cut-date then do:
                          message substitute("Невозможно оформить межфирменный Возврат поставщику, так как было обрезание БД &1 " , string(v-cut-date,"99/99/99") )
                          view-as alert-box information
                          .
                          return error .
                       end.
                   end.
                end.
              end.
          end.
      if buf_trn-doc.doc-type = 'при':U and v-ischg-ext-type then do:
          for each ub.doc-line where ub.doc-line.doc-code = buf_trn-doc.doc-code no-lock:
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input ub.doc-line.artic
  ,  input ub.doc-line.prod-type
  ,  input ub.doc-line.prod-code
  , output v-is-petrl
  , output v-is-pieces
  ) .
              if error-status:error then do:
                  message return-value
                        view-as alert-box.
                  undo, return error.
              end.
              if v-is-petrl and not v-is-pieces and ub.doc-line.doc-qnty <> ub.doc-line.fact-qnty then do:
                  message "Для внутреннего прихода запрещено закрытие с разными факт. и док. количествами топливного товара"
                        view-as alert-box.
                  undo, return error.
              end.
          end.
      end.
      v-error = false .
      output stream str-err to value( v-file-n + ".err" ) .
      put    stream str-err unformatted ''.
      output stream str-err close.
      if ( varmode            = '<закрытие документа>':U             or
           varmode            = '<закрытие документа на факт>':U )          and
           varstatus          = 'факт':U                  and
           lookup (buf_trn-doc.ext-doc-type ,
              'vt':U + "," +
              'vp':U + "," +
              'we':U + "," +
              'wm':U + ","  +
              'es':U + ","+
              're':U + "," +
              'ep':U + ","  +
              'pc':U + ","  +
              'mp':U + ","  +
              'ap':U   + "," +
              'rv':U + ","  +
              'io':U   + "," +
              'eo':U ) = 0
           then do:
           for each buf_doc-line no-lock where buf_doc-line.doc-code =  buf_trn-doc.doc-code  and
                    buf_doc-line.fact-qnty > 0 :
                find first buf_goods where buf_goods.artic     = buf_doc-line.artic     and
                                           buf_goods.prod-type = buf_doc-line.prod-type and
                                           buf_goods.prod-code = buf_doc-line.prod-code no-lock.
                var-ok-assort-pol = true .
                if l_is-hold-doc      = yes then do:
                    v-event-code = substitute("mf_&1-" ,buf_trn-doc.ext-doc-type ) .
                end.
                else do:
                   v-event-code = substitute("&1-" ,buf_trn-doc.ext-doc-type ) .
                end.
define variable vss-include-info65 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run goassizt in g#library2
  (input  v-event-code
  ,input  buf_goods.gds-code
  ,input  buf_trn-doc.obj-type
  ,input  buf_trn-doc.obj-code
  ,input  true
  ,output var-ok-assort-pol
  ,output var-mess-assort-pol
  ) .
                if var-ok-assort-pol = false then do:
                      v-error = true .
                      output stream str-err to value( v-file-n + ".err" ) append.
                      put    stream str-err unformatted var-mess-assort-pol skip.
                      output stream str-err close.
                end.
            end.
       end.
      if ( varmode            = '<закрытие документа>':U             or
           varmode            = '<закрытие документа на факт>':U )          and
           varstatus          = 'факт':U                  and
           buf_trn-doc.ext-doc-type = 'ee':U and
           l_is-hold-doc      = yes
           then do:
           for each buf_doc-line no-lock where buf_doc-line.doc-code =  buf_trn-doc.doc-code  and
                    buf_doc-line.fact-qnty > 0 :
                find first buf_goods where buf_goods.artic     = buf_doc-line.artic     and
                                           buf_goods.prod-type = buf_doc-line.prod-type and
                                           buf_goods.prod-code = buf_doc-line.prod-code no-lock.
                var-ok-assort-pol = true .
                v-event-code = substitute("cli_mf_&1-" ,buf_trn-doc.ext-doc-type ) .
define variable vss-include-info66 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run goassizt in g#library2
  (input  v-event-code
  ,input  buf_goods.gds-code
  ,input  buf_trn-doc.hold-obj-type
  ,input  buf_trn-doc.hold-obj-code
  ,input  true
  ,output var-ok-assort-pol
  ,output var-mess-assort-pol
  ) .
                if var-ok-assort-pol = false then do:
                     v-error = true .
                      output stream str-err to value(  v-file-n + ".err" ) append.
                      put    stream str-err unformatted 'МФ: ' + var-mess-assort-pol skip.
                      output stream str-err close.
                end.
            end.
       end.
      if v-error = true
      then do:
          run gbl/prnfilen.w
            (input  "Ошибки по соответствию товаров в накладной и Ассортиментной политике"
            ,input  0
            ,input  v-file-n  + ".err"
            ,input  7
            ,output v-user-action
            ,output v-printed
            ).
        return error substitute( 'Ошибки по соответствию товаров в накладной и Ассортиментной политике. ' +
                                 'Смотри файл "&1.err"'
                                , v-file-n  ).
      end.
      run str/trn-stat.p (
            input   parparentproc,
            input   this-procedure ,
            input   varmode,
            input   buf_trn-doc.doc-code,
            input   varcheck-return,
            input   v-cntxt-db-num,
            input   v-cntxp-in-ov,
            input   v-cntxp-rsrv-time,
            input   v-cntxp-load-time,
            input   v-cntxp-holidays,
            input   yes,
            output  varchg-inv,
            output  table gds-list )
            no-error.
      if error-status :error then do:
        v-mess =
          "Ошибка при закрытии документа " + buf_trn-doc.doc-code + chr(10) +
          return-value + chr(10) .
        run userlogingerr in this-procedure ( buffer buf_trn-doc, 57, v-mess, v-cntxt-db-num) no-error.
        message
          v-mess
        view-as alert-box error.
        return error v-mess.
      end.
      if varchg-inv = yes then do:
        assign varlog = no.
        message "За время пребывания в статусе разр- было движение товаров, участвующих в инвентаризации." skip
                "Показать список товаров по которым было движение?"
        view-as alert-box question buttons yes-no update varlog .
        if varlog then run str/gds-list.w (input parparentproc, input buf_trn-doc.host-code, input buf_trn-doc.obj-type, input buf_trn-doc.obj-code).
      end.
      define buffer bf_doc-line       for ub.doc-line.
      define buffer bf_gds-dtl        for ub.gds-dtl.
      def var v-attr-value as character no-undo.
      def var v-attr-type as character no-undo.
      def var v-is-introduce  as logical no-undo.
      def var v-is-return     as logical no-undo.
      def var v-is-wroff-tech-m as logical no-undo.
      def var v-prev-sts        as integer no-undo.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input buf_trn-doc.doc-code ,
                        input 'trdcattr-inv-introduce':U ,
                       output v-attr-value ,
                       output v-attr-type ) no-error .
      if not error-status:error and v-attr-value = "yes" then do:
        v-is-introduce = true.
      end.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input buf_trn-doc.doc-code ,
                        input 'is-return':U ,
                       output v-attr-value ,
                       output v-attr-type ) no-error .
      if not error-status:error and v-attr-value = "yes" then do:
        v-is-return = true.
      end.
        if not v-is-introduce and
          ((ObjSrv:Env:ParametrsOfSection:GetSectionEDO(buf_trn-doc.obj-type, buf_trn-doc.obj-code):GetIsMarkingForType("tabak")
            or can-find (first ub.marking-attr where ub.marking-attr.attr-code = "inv-doc" and ub.marking-attr.attr-value = buf_trn-doc.doc-code))
          and buf_trn-doc.ext-doc-type = 'vt':U and varstatus = 'разрешен':U)
        then do:
          def var chg-qnty as int no-undo.
          v-is-wroff-tech-m = true.
        for each bf_doc-line where bf_doc-line.doc-code = buf_trn-doc.doc-code:
          find first ub.goods no-lock where
            bf_doc-line.artic = ub.goods.artic
            and bf_doc-line.prod-type = ub.goods.prod-type
            and bf_doc-line.prod-code = ub.goods.prod-code.
          define variable n-c like ub.gds-prt.node-code          no-undo.
          find first bf_gds-dtl where
                     bf_gds-dtl.doc-code  = bf_doc-line.doc-code  and
                     bf_gds-dtl.artic     = bf_doc-line.artic     and
                     bf_gds-dtl.prod-code = bf_doc-line.prod-code and
                     bf_gds-dtl.prod-type = bf_doc-line.prod-type no-error.
          if not available bf_gds-dtl then do:
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run termnode in g#library
  (input  ub.goods.prt-root
  ,output n-c
  )  .
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_crgdsdtl in g#lib-trn
  ( input bf_doc-line.obj-code
   ,input bf_doc-line.obj-type
   ,input buf_trn-doc.doc-code
   ,input bf_doc-line.artic
   ,input bf_doc-line.prod-code
   ,input bf_doc-line.prod-type
   ,input n-c
   ,input yes
  )  .
            find first bf_gds-dtl where
                       bf_gds-dtl.doc-code  = bf_doc-line.doc-code  and
                       bf_gds-dtl.artic     = bf_doc-line.artic     and
                       bf_gds-dtl.prod-code = bf_doc-line.prod-code and
                       bf_gds-dtl.prod-type = bf_doc-line.prod-type and
                       bf_gds-dtl.prt-code  = n-c.
            assign
              bf_gds-dtl.fact-qnty = bf_doc-line.doc-qnty
              bf_gds-dtl.doc-qnty  = 0
            .
          end.
          define variable old-val        like ub.gds-dtl.fact-qnty no-undo.
          old-val = bf_gds-dtl.fact-qnty.
          chg-qnty = (bf_doc-line.fact-qnty - bf_doc-line.doc-qnty).
          run trg/rsrv-dtl.p
            ( input        parparentproc
             ,input        'reserv':U
             ,buffer       bf_gds-dtl
             ,input-output chg-qnty
             ,input-output bf_doc-line.price-base
             ,input-output bf_doc-line.price-rubl
             ,input        -1
             ,input        ""
            ) no-error.
          if error-status:error
          then do:
            undo, return error return-value.
          end.
          assign bf_gds-dtl.fact-qnty  = bf_gds-dtl.fact-qnty  + chg-qnty
                bf_gds-dtl.doc-qnty   = bf_gds-dtl.fact-qnty  - old-val
                bf_doc-line.doc-qnty  = bf_doc-line.doc-qnty  + chg-qnty
                bf_doc-line.fact-qnty = bf_doc-line.fact-qnty + chg-qnty.
          for each buf_marking-lines where
            buf_marking-lines.gds-code = ub.goods.gds-code
            and buf_marking-lines.out-code = buf_trn-doc.doc-code
            and buf_marking-lines.obj-type = buf_trn-doc.obj-type
            and buf_marking-lines.obj-code = buf_trn-doc.obj-code
            :
            for each ub.marking exclusive-lock where ub.marking.mark = buf_marking-lines.mark and not ub.marking.sts = ObjSrv:Env:Marking:Sts:Mark:Ungrouped:KeyIntDB
              and not ub.marking.sts = ObjSrv:Env:Marking:Sts:Mark:MarkError:KeyIntDB:
              ub.marking.sts = ObjSrv:Env:Marking:Sts:Mark:Reserved:KeyIntDB.
            end.
          end.
          f_ml:
          for each buf_marking-lines where
            buf_marking-lines.gds-code = ub.goods.gds-code
            and buf_marking-lines.out-code = buf_trn-doc.doc-code
            and buf_marking-lines.obj-type = buf_trn-doc.obj-type
            and buf_marking-lines.obj-code = buf_trn-doc.obj-code
            :
            find first ub.marking-attr where ub.marking-attr.mark = buf_marking-lines.mark
              and ub.marking-attr.attr-code = "inv-doc-scan"
              and ub.marking-attr.attr-value = buf_trn-doc.doc-code no-error.
            if available (ub.marking-attr)
              then do:
                find first ub.marking where ub.marking.mark = ub.marking-attr.mark no-error.
                if not available ( ub.marking )
                then do:
                  next f_ml.
                end.
                if not ub.marking.sts = ObjSrv:Env:Marking:Sts:Mark:Reserved:KeyIntDB
                  then do:
                    v-prev-sts = ub.marking.sts.
                    ub.marking.sts = ObjSrv:Env:Marking:Sts:Mark:Reserved:KeyIntDB.
                  end.
                  else v-prev-sts = ?.
              end.
              else next f_ml.
            create ub.gen-attr.
              ub.gen-attr.table-name = "inv-doc-mark".
              ub.gen-attr.attr-code = bf_doc-line.doc-code.
              ub.gen-attr.p-key = ub.marking.mark.
              ub.gen-attr.attr-value = string(ub.marking.gds-code).
            chg-qnty = ub.marking.box-qnty.
                        run trg/rsrv-dtl.p
              ( input        parparentproc
               ,input        'reserv':U
               ,buffer       bf_gds-dtl
               ,input-output chg-qnty
               ,input-output bf_doc-line.price-base
               ,input-output bf_doc-line.price-rubl
               ,input        -1
               ,input        buf_marking-lines.mark
              ) no-error.
            if error-status:error
            then do:
              undo, return error return-value.
            end.
            assign bf_gds-dtl.fact-qnty  = bf_gds-dtl.fact-qnty  + chg-qnty
                  bf_gds-dtl.doc-qnty   = bf_gds-dtl.fact-qnty  - old-val
                  bf_doc-line.doc-qnty  = bf_doc-line.doc-qnty  + chg-qnty
                  bf_doc-line.fact-qnty = bf_doc-line.fact-qnty + chg-qnty.
            if v-prev-sts ne ?
            then do:
              ub.marking.sts = v-prev-sts.
              v-prev-sts = ?.
            end.
            release ub.marking.
          end.
          if v-is-wroff-tech-m
          then do:
            f_ml2:
            for each buf_marking-lines where
              buf_marking-lines.gds-code = ub.goods.gds-code
              and buf_marking-lines.out-code = buf_trn-doc.doc-code
              and buf_marking-lines.obj-type = buf_trn-doc.obj-type
              and buf_marking-lines.obj-code = buf_trn-doc.obj-code
              and buf_marking-lines.mark begins 'tech_':U
              :
              find first ub.marking where ub.marking.mark = ub.buf_marking-lines.mark no-error.
              if not available ( ub.marking )
              then do:
                if not ub.marking.sts = ObjSrv:Env:Marking:Sts:Mark:Reserved:KeyIntDB
                  then do:
                    v-prev-sts = ub.marking.sts.
                    ub.marking.sts = ObjSrv:Env:Marking:Sts:Mark:Reserved:KeyIntDB.
                  end.
                  else v-prev-sts = ?.
                next f_ml2.
              end.
              create ub.gen-attr.
                ub.gen-attr.table-name = "inv-doc-mark".
                ub.gen-attr.attr-code = bf_doc-line.doc-code.
                ub.gen-attr.p-key = ub.marking.mark.
                ub.gen-attr.attr-value = string(ub.marking.gds-code).
              chg-qnty = ub.marking.box-qnty.
              run trg/rsrv-dtl.p
                ( input        parparentproc
                 ,input        'reserv':U
                 ,buffer       bf_gds-dtl
                 ,input-output chg-qnty
                 ,input-output bf_doc-line.price-base
                 ,input-output bf_doc-line.price-rubl
                 ,input        -1
                 ,input        buf_marking-lines.mark
                ) no-error.
              if error-status:error
              then do:
                undo, return error return-value.
              end.
              assign bf_gds-dtl.fact-qnty  = bf_gds-dtl.fact-qnty  + chg-qnty
                    bf_gds-dtl.doc-qnty   = bf_gds-dtl.fact-qnty  - old-val
                    bf_doc-line.doc-qnty  = bf_doc-line.doc-qnty  + chg-qnty
                    bf_doc-line.fact-qnty = bf_doc-line.fact-qnty + chg-qnty.
              if v-prev-sts ne ?
              then do:
                ub.marking.sts = v-prev-sts.
                v-prev-sts = ?.
              end.
              release ub.marking.
            end.
          end.
        end.
        run gbl/calc-trn.p ( input parparentproc, input recid( buf_trn-doc ) ).
        run str/clcsumga.p ( input buf_trn-doc.doc-code ).
      end.
      if buf_trn-doc.ext-doc-type = 'eo':U and buf_trn-doc.status_ = 'факт':U then do :
          define variable v-income-doc-code as character no-undo .
          v-income-doc-code = replace(buf_trn-doc.doc-code, '-', '=' ).
define variable vss-include-info67 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn4) <> true) then do:   run str/lib-trn4.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn4) <> true) then do:     message       "Error starting lib-trn4.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn4 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn4 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn4 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn4_int-clos in g#lib-trn4
  (input  parparentproc
  ,input  v-income-doc-code
  ,output table gds-list
  ) no-error .
      end.
      if buf_trn-doc.ext-doc-type = 'we':U and buf_trn-doc.status_ = 'факт':U then
      do :
        run change_mark_sts_trn-doc in this-procedure
          (buf_trn-doc.doc-code, buf_trn-doc.obj-type, buf_trn-doc.obj-code,
           string(ObjSrv:Env:Marking:Sts:Mark:WrittenOff:KeyIntDB)).
      end.
      if buf_trn-doc.ext-doc-type = 'ev':U and buf_trn-doc.status_ = 'факт':U then
      do :
        run change_mark_sts_trn-doc in this-procedure
          (buf_trn-doc.doc-code, buf_trn-doc.obj-type, buf_trn-doc.obj-code,
           string(ObjSrv:Env:Marking:Sts:Mark:Moved:KeyIntDB)).
      end.
      if v-is-return and buf_trn-doc.status_ = 'факт':U then
      do :
        run change_mark_sts_trn-doc in this-procedure
          (buf_trn-doc.doc-code, buf_trn-doc.obj-type, buf_trn-doc.obj-code,
           string(ObjSrv:Env:Marking:Sts:Mark:Returned:KeyIntDB)).
      end.
      if buf_trn-doc.ext-doc-type = 'ie':U and v-ischg-ext-type and buf_trn-doc.status_ = 'факт':U then
      do :
        run change_mark_sts_trn-doc in this-procedure
          (buf_trn-doc.doc-code, buf_trn-doc.obj-type, buf_trn-doc.obj-code,
           substitute("&1:&2,&3:&4",
                      ObjSrv:Env:Marking:Sts:Mark:Checked_:KeyIntDB,
                      ObjSrv:Env:Marking:Sts:Mark:FreeZone:KeyIntDB,
                      ObjSrv:Env:Marking:Sts:Mark:DeliveryControl:KeyIntDB,
                      ObjSrv:Env:Marking:Sts:Mark:NotAvailable:KeyIntDB)
          ).
      end.
      if buf_trn-doc.ext-doc-type = 'rv':U and buf_trn-doc.status_ = 'факт':U then
      do :
        run change_mark_sts_trn-doc in this-procedure
          (buf_trn-doc.doc-code, buf_trn-doc.obj-type, buf_trn-doc.obj-code,
           string(ObjSrv:Env:Marking:Sts:Mark:FreeZone:KeyIntDB)).
      end.
    if v-ischg-ext-type
    then do:
      buf_trn-doc.ext-doc-type = 'iv':U.
      buf_trn-doc.internal = true.
      buf_trn-doc.discnt-type = 'процент':U.
      v-ischg-ext-type = false.
    end.
  end.
if buf_trn-doc.ext-doc-type = 'ie':U and varstatus = 'факт':U then
do:
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input buf_trn-doc.doc-code ,
                        input 'is-lgas':U ,
                       output varvalue ,
                       output vartype ) no-error .
  if varvalue = "yes" then
  do:
    run spr-sug (buf_trn-doc.doc-code, buf_trn-doc.reason-code) no-error .
    run bge\send1cerp.p (?,
      this-procedure,
      this-procedure,
      "techlosses",
      (buffer buf_trn-doc:handle),
      ?,
      ?) no-error.
    if error-status:error
      then
    do:
      message return-value view-as alert-box.
    end.
  end.
end.
end procedure.
procedure lib-trn4_int-open :
  define input  parameter parparentproc as widget-handle no-undo.
  define input  parameter p-doc-code    as character no-undo .
  define output parameter table for gds-list .
  define variable varmode         as   character            no-undo.
  define variable varchg-inv      as logical              no-undo.
  define variable varstatus       like ub.trn-doc.status_   no-undo.
  define variable varflag         like ub.trn-doc.status_   no-undo.
  define variable varcopystatus   like ub.trn-doc.status_   no-undo.
  define variable varcopyflag     like ub.trn-doc.status_   no-undo.
  define variable varlog          as logical   no-undo .
  define variable varcheck-return as logical   no-undo .
define variable vss-include-info68 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info69 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxp-doc-prt         like ub.store.doc-prt         no-undo.
  define variable v-cntxp-price-calc      like ub.store.price-calc      no-undo.
  define variable v-cntxp-inout-price     like ub.store.inout-price     no-undo.
  define variable v-cntxp-unit-cli-perm   like ub.store.unit-cli-perm   no-undo.
  define variable v-cntxp-out-rate        like ub.store.out-rate        no-undo.
  define variable v-cntxp-out-line-discnt like ub.store.out-line-discnt no-undo.
  define variable v-cntxp-in-ov           like ub.store.in-ov           no-undo.
  define variable v-cntxp-in-perm         like ub.store.in-perm         no-undo.
  define variable v-cntxp-no-eq           like ub.store.no-eq           no-undo.
  define variable v-cntxp-rsrv-time       like ub.store.rsrv-time       no-undo.
  define variable v-cntxp-load-time       like ub.store.load-time       no-undo.
  define variable v-cntxp-holidays        like ub.store.holidays        no-undo.
  define variable v-cntxp-in-pay          like ub.store.in-pay          no-undo.
  define variable v-cntxp-out-pay         like ub.store.out-pay         no-undo.
  define variable v-cntxp-ret-pay         like ub.store.ret-pay         no-undo.
  define variable v-cntxp-ret-sup-pay     like ub.store.ret-sup-pay     no-undo.
  define variable v-cntxp-down-pay        like ub.store.down-pay        no-undo.
  define variable v-cntxp-inv-pay         like ub.store.inv-pay         no-undo.
  define variable v-cntxp-chk-pay         like ub.store.chk-pay         no-undo.
  define variable v-cntxp-retail          like ub.sysconf.ord-prt       no-undo.
  define variable v-cntxp-osn-base        like ub.sysconf.osn-base      no-undo.
  define variable v-cntxp-conf-par        as   character                no-undo.
  define variable v-cntxp-par-type        as   character                no-undo.
  define variable v-cntxp-curr-host-code  like ub.store.host-code       no-undo.
  define variable v-cntxp-obj-type        like ub.clients.obj-type      no-undo.
  define variable v-cntxp-obj-code        like ub.clients.obj-code      no-undo.
  define variable v-cntxp-db-num          as integer   no-undo .
  define variable v-cntxp-userid          as character no-undo .
  define variable v-cntxp-level           as character no-undo .
  define variable v-cntxp-db-num-obj      as integer   no-undo .
  define variable v-cntxp-is-admin        as logical   no-undo .
  define buffer bf-cntxp_store for ub.store.
  define buffer bf-cntxp_shop  for ub.shop.
  define buffer bf-cntxp_sysconf for ub.sysconf.
  define buffer bf_rvs-doc for ub.rvs-doc.
  define buffer buf_trn-doc for ub.trn-doc .
  define buffer buf_doc-line for ub.doc-line  .
  do
  on error undo, return error return-value
  :
    find first buf_trn-doc exclusive-lock
      where buf_trn-doc.doc-code = p-doc-code
      no-error .
    if not available buf_trn-doc
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Не найден документ" skip
        "Номер документа" p-doc-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if buf_trn-doc.rcv-code = "not_delete" then do:
       if not ( buf_trn-doc.ext-doc-type = 'vt':U and
                buf_trn-doc.status_ = 'разрешен':U ) then do:
              message "Этот документ запрещено открывать!" skip
                      "Номер документа" p-doc-code
                      view-as alert-box information .
              undo, return error return-value .
       end.
    end.
define variable vss-include-info70 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info71 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in parparentproc
    (output v-cntxp-db-num
    ,output v-cntxp-userid
    ,output v-cntxp-level
    ,output v-cntxp-curr-host-code
    ,output v-cntxp-obj-type
    ,output v-cntxp-obj-code
    ,output v-cntxp-db-num-obj
    ,output v-cntxp-is-admin
    ) .
  if (v-cntxp-obj-type = 'маг':U or v-cntxp-obj-type = 'скл':U) and
     v-cntxp-obj-code <> 0 then do:
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-prt'
  ,input  0
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  yes
  ,output v-cntxp-conf-par
  ,output v-cntxp-par-type
  ) no-error .
    case v-cntxp-obj-type :
      when 'скл':U then do:
        find first bf-cntxp_store where bf-cntxp_store.obj-code = v-cntxp-obj-code no-lock.
        find first bf-cntxp_sysconf where bf-cntxp_sysconf.host-code = bf-cntxp_store.host-code no-lock.
        assign
          v-cntxp-doc-prt         = (v-cntxp-conf-par = "yes") and bf-cntxp_store.doc-prt
          v-cntxp-price-calc      = bf-cntxp_store.price-calc
          v-cntxp-inout-price     = bf-cntxp_store.inout-price
          v-cntxp-unit-cli-perm   = bf-cntxp_store.unit-cli-perm
          v-cntxp-out-rate        = bf-cntxp_store.out-rate
          v-cntxp-out-line-discnt = bf-cntxp_store.out-line-discnt
          v-cntxp-in-ov           = bf-cntxp_store.in-ov
          v-cntxp-in-perm         = bf-cntxp_store.in-perm
          v-cntxp-no-eq           = bf-cntxp_store.no-eq
          v-cntxp-rsrv-time       = bf-cntxp_store.rsrv-time
          v-cntxp-load-time       = bf-cntxp_store.load-time
          v-cntxp-holidays        = bf-cntxp_store.holidays
          v-cntxp-in-pay          = bf-cntxp_store.in-pay
          v-cntxp-out-pay         = bf-cntxp_store.out-pay
          v-cntxp-ret-pay         = bf-cntxp_store.ret-pay
          v-cntxp-ret-sup-pay     = bf-cntxp_store.ret-sup-pay
          v-cntxp-down-pay        = bf-cntxp_store.down-pay
          v-cntxp-inv-pay         = bf-cntxp_store.inv-pay
          v-cntxp-chk-pay         = bf-cntxp_store.chk-pay
          v-cntxp-retail          = bf-cntxp_sysconf.ord-prt
          v-cntxp-osn-base        = bf-cntxp_sysconf.osn-base
          .
      end.
      when 'маг':U then do:
        find first bf-cntxp_shop where bf-cntxp_shop.obj-code = v-cntxp-obj-code no-lock.
        find first bf-cntxp_sysconf where bf-cntxp_sysconf.host-code = bf-cntxp_shop.host-code no-lock.
        assign
          v-cntxp-doc-prt         = (v-cntxp-conf-par = "yes") and bf-cntxp_shop.doc-prt
          v-cntxp-price-calc      = bf-cntxp_shop.price-calc
          v-cntxp-inout-price     = bf-cntxp_shop.inout-price
          v-cntxp-unit-cli-perm   = bf-cntxp_shop.unit-cli-perm
          v-cntxp-out-rate        = bf-cntxp_shop.out-rate
          v-cntxp-out-line-discnt = bf-cntxp_shop.out-line-discnt
          v-cntxp-in-ov           = bf-cntxp_shop.in-ov
          v-cntxp-in-perm         = bf-cntxp_shop.in-perm
          v-cntxp-no-eq           = bf-cntxp_shop.no-eq
          v-cntxp-rsrv-time       = bf-cntxp_shop.rsrv-time
          v-cntxp-load-time       = bf-cntxp_shop.load-time
          v-cntxp-holidays        = bf-cntxp_shop.holidays
          v-cntxp-in-pay          = bf-cntxp_shop.in-pay
          v-cntxp-out-pay         = bf-cntxp_shop.out-pay
          v-cntxp-ret-pay         = bf-cntxp_shop.ret-pay
          v-cntxp-ret-sup-pay     = bf-cntxp_shop.ret-sup-pay
          v-cntxp-down-pay        = bf-cntxp_shop.down-pay
          v-cntxp-inv-pay         = bf-cntxp_shop.inv-pay
          v-cntxp-chk-pay         = bf-cntxp_shop.chk-pay
          v-cntxp-retail          = bf-cntxp_sysconf.ord-prt
          v-cntxp-osn-base        = bf-cntxp_sysconf.osn-base
          .
      end.
    end case.
  end.
    assign varmode = '<открытие документа>':U.
    run str/trn-graf.p (input  buf_trn-doc.doc-code,
                    input  v-cntxt-db-num,
                    input  varmode,
                    output varstatus,
                    output varflag,
                    output varcopystatus,
                    output varcopyflag) no-error.
    if error-status:error then do:
      message "Ошибка при проверке возможности открытия документа." skip
              return-value
      view-as alert-box error.
      return error.
    end.
    case buf_trn-doc.status_:
    when 'накл':U or
    when 'запрос':U then do:
      varlog = no.
      message "Документ №" buf_trn-doc.doc-code "Открыть ?   Вы уверены ?"
                      view-as alert-box question buttons OK-Cancel update varlog.
      if not varlog then  return error.
      if buf_trn-doc.status_  = 'запрос':U and
        buf_trn-doc.doc-type = 'при':U  and
        buf_trn-doc.internal = no         then do:
define variable vss-include-info72 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_income_opening-inquiry':U
    ,input  'object':U
    ,input  buf_trn-doc.host-code
    ,input  buf_trn-doc.obj-type
    ,input  buf_trn-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output varlog
    )  .
end.
        if not varlog then  return error.
      end.
      else do:
        case buf_trn-doc.doc-type
        :
          when 'при':U
          then do:
define variable vss-include-info73 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_income_opening':U
    ,input  'object':U
    ,input  buf_trn-doc.host-code
    ,input  buf_trn-doc.obj-type
    ,input  buf_trn-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output varlog
    )  .
end.
          end.
          when 'рас':U
          then do:
define variable vss-include-info74 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_expense_opening':U
    ,input  'object':U
    ,input  buf_trn-doc.host-code
    ,input  buf_trn-doc.obj-type
    ,input  buf_trn-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output varlog
    )  .
end.
          end.
          when 'спи':U
          then do:
define variable vss-include-info75 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_write-off_opening':U
    ,input  'object':U
    ,input  buf_trn-doc.host-code
    ,input  buf_trn-doc.obj-type
    ,input  buf_trn-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output varlog
    )  .
end.
          end.
          when 'инв':U
          then do:
define variable vss-include-info76 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_inventory_opening':U
    ,input  'object':U
    ,input  buf_trn-doc.host-code
    ,input  buf_trn-doc.obj-type
    ,input  buf_trn-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output varlog
    )  .
end.
          end.
          when 'возврат':U
          then do:
define variable vss-include-info77 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_return_opening':U
    ,input  'object':U
    ,input  buf_trn-doc.host-code
    ,input  buf_trn-doc.obj-type
    ,input  buf_trn-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output varlog
    )  .
end.
          end.
          otherwise do:
            message
              vss-workfile vss-revision vss-description skip
              "Неизвестный тип документа" skip
              "Тип документа" buf_trn-doc.doc-type skip
              "Код документа" buf_trn-doc.doc-code skip
              view-as alert-box error .
            undo, return error return-value .
          end.
        end case .
        if not varlog then  return error.
      end.
    end.
    when 'разрешен':U then do:
      if  buf_trn-doc.ext-doc-type = 'vt':U then do:
       if not is-mes(buf_trn-doc.doc-code) then do:
        message
          "Документ №" buf_trn-doc.doc-code skip (2)
          "Открыть инвентаризацию?   Будут потеряны все введенные остатки!" skip
          "Если необходимо добавить / удалить строки, используйте пересортицу (кнопка Резерв)." skip
          "Вы уверены, что хотите открыть инвентаризацию?"
          view-as alert-box question buttons OK-Cancel update varlog .
        if not varlog then return error.
        varlog = no.
        message
          "Документ №" buf_trn-doc.doc-code skip (2)
          "Последнее предупреждение! При открытии инвентаризации будут потеряны все введенные остатки!" skip
          "Если Вы не хотите этого, нажмите Cancel (Отмена)!"
          view-as alert-box question buttons OK-Cancel update varlog .
        if not varlog then return error.
define variable vss-include-info78 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_inventory_opening':U
    ,input  'object':U
    ,input  buf_trn-doc.host-code
    ,input  buf_trn-doc.obj-type
    ,input  buf_trn-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output varlog
    )  .
end.
        if not varlog then  return error.
        end.
          for each buf_doc-line exclusive-lock where
                   buf_doc-line.doc-code =  buf_trn-doc.doc-code
                   :
              buf_doc-line.inv-peresort-qnty = 0 .
          end.
      end.
      else do:
        varlog = no.
        message "Документ №" buf_trn-doc.doc-code skip "Снять разрешение ?   Вы уверены ?"
                        view-as alert-box question buttons OK-Cancel update varlog.
        if not varlog then  return error.
        case buf_trn-doc.doc-type
        :
          when 'рас':U
          then do:
define variable vss-include-info79 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_expense_perm-cancellation':U
    ,input  'object':U
    ,input  buf_trn-doc.host-code
    ,input  buf_trn-doc.obj-type
    ,input  buf_trn-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output varlog
    )  .
end.
          end.
          when 'спи':U
          then do:
define variable vss-include-info80 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_write-off_perm-cancellation':U
    ,input  'object':U
    ,input  buf_trn-doc.host-code
    ,input  buf_trn-doc.obj-type
    ,input  buf_trn-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output varlog
    )  .
end.
          end.
          when 'возврат':U
          then do:
define variable vss-include-info81 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_return_perm-cancellation':U
    ,input  'object':U
    ,input  buf_trn-doc.host-code
    ,input  buf_trn-doc.obj-type
    ,input  buf_trn-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output varlog
    )  .
end.
          end.
          otherwise do:
            message
              vss-workfile vss-revision vss-description skip
              "Неизвестный тип документа" skip
              "Тип документа" buf_trn-doc.doc-type skip
              "Код документа" buf_trn-doc.doc-code skip
              view-as alert-box error .
            undo, return error return-value .
          end.
        end case .
        if not varlog then  return error.
      end.
    end.
    otherwise do:
      message "Документ # " buf_trn-doc.doc-code " в статусе " buf_trn-doc.status_ " .Нельзя открыть документ. "
      view-as alert-box error.
      return error.
    end.
    end case.
    if buf_trn-doc.creid <> v-cntxt-userid or true then do:
      run str/trn-hist.p
            (buffer buf_trn-doc ,
            input  v-cntxt-obj-type ,
            input  v-cntxt-obj-code ,
            input  "Открытие документа"
            ) .
    end.
    run str/trn-stat.p (input parparentproc,
                    input this-procedure ,
                    input varmode,
                    input buf_trn-doc.doc-code,
                    input varcheck-return,
                    input v-cntxt-db-num,
                    input v-cntxp-in-ov,
                    input v-cntxp-rsrv-time,
                    input v-cntxp-load-time,
                    input v-cntxp-holidays,
                    input yes,
                    output varchg-inv,
                    output table gds-list) no-error.
    if error-status:error
    then do:
        v-mess =
          vss-workfile + vss-revision + vss-description + chr(10) +
          "Ошибка при открытии документа " + buf_trn-doc.doc-code + chr(10) +
          return-value + chr(10) +
          trim( error-status :get-message( 1 ) ) +
          trim( error-status :get-message( 2 ) ) +
          trim( error-status :get-message( 3 ) ) +
          trim( error-status :get-message( 4 ) ) +
          trim( error-status :get-message( 5 ) ) + chr(10).
        run userlogingerr in this-procedure ( buffer buf_trn-doc, 57, v-mess, v-cntxt-db-num) no-error.
        message v-mess
          view-as alert-box error.
      undo, return error v-mess .
    end.
  end.
end procedure.
procedure lib-trn4_corrsprc :
define input  parameter p-action as character no-undo .
define input  parameter p-doc-code as character no-undo .
define output parameter p-mess as character no-undo .
  do
  on error undo, return error return-value
  :
p-mess = "" .
if not ( p-action = "-" or p-action = "+" ) then return .
define buffer buf_trn-doc  for ub.trn-doc  .
define buffer buf_doc-line for ub.doc-line  .
define buffer buf_contract for ub.contract .
define buffer buf_contract-specif for ub.contract-specif .
define buffer buf_parts for ub.parts  .
find first buf_trn-doc no-lock where
           buf_trn-doc.doc-code = p-doc-code and
           buf_trn-doc.status_  = 'факт':U no-error .
if error-status :error then return .
if buf_trn-doc.ext-doc-type = 'ie':U then do:
    find first buf_contract no-lock where
               buf_contract.host-code     = buf_trn-doc.host-code and
               buf_contract.contract-code = buf_trn-doc.contract-code no-error .
               if error-status :error then return .
      for each buf_doc-line no-lock where
               buf_doc-line.doc-code = buf_trn-doc.doc-code :
define variable vss-include-info82 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
ASSIGN
   i-gl-Host-Code      = 0
   i-gl-Contract-Code  = 0
   i-gl-Extent3        = 0
   .
RUN MS-Contract-EXTENT-3 IN THIS-PROCEDURE(
    INPUT  buf_contract.host-code,
    INPUT  buf_contract.contract-code,
    OUTPUT i-gl-Extent3
   ).
IF i-gl-Extent3[1] = 2 THEN DO:
   ASSIGN
      i-gl-Host-Code      = i-gl-Extent3[2]
      i-gl-Contract-Code  = i-gl-Extent3[3]
      .
END. ELSE DO:
   ASSIGN
      i-gl-Host-Code      = buf_contract.host-code
      i-gl-Contract-Code  = buf_contract.contract-code
      .
END.
FOR EACH
    buf_contract-specif
     EXCLUSIVE-LOCK
     WHERE
         buf_contract-specif.Host-code    = i-gl-Host-Code
     AND buf_contract-specif.Contract-num = i-gl-Contract-Code
            AND buf_contract-specif.artic        = buf_doc-line.artic
            AND buf_contract-specif.prod-type    = buf_doc-line.prod-type
            AND buf_contract-specif.prod-code    = buf_doc-line.prod-code :
           if buf_contract-specif.qnty <> ? then do:
                if p-action = "+" then
                assign
                  buf_contract-specif.income-qnty =
                      ( if  buf_contract-specif.income-qnty = ? then 0 else  buf_contract-specif.income-qnty )
                        + ( buf_doc-line.fact-qnty / buf_contract-specif.cli-base-rate )
                .
                else
                assign
                  buf_contract-specif.income-qnty =
                      (if  buf_contract-specif.income-qnty = ? then 0 else buf_contract-specif.income-qnty ) -
                      ( buf_doc-line.fact-qnty / buf_contract-specif.cli-base-rate )
                .
             if buf_contract-specif.income-qnty > buf_contract-specif.qnty
                      then p-mess = p-mess +
                          buf_contract-specif.artic + " "         + buf_contract-specif.prod-type +
                          string(buf_contract-specif.prod-code)   + " Всего принято:" +
                          string(buf_contract-specif.income-qnty) + " По спецификации:" +
                          string(buf_contract-specif.qnty)        + chr(10) .
           end.
       end.
      end.
end.
if buf_trn-doc.ext-doc-type = 'ep':U then do:
  for each buf_parts no-lock where
           buf_parts.out-code = buf_trn-doc.doc-code ,
      first buf_contract no-lock where
            buf_contract.host-code     = buf_trn-doc.host-code and
            buf_contract.contract-code = buf_parts.contract-code :
define variable vss-include-info83 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
ASSIGN
   i-gl-Host-Code      = 0
   i-gl-Contract-Code  = 0
   i-gl-Extent3        = 0
   .
RUN MS-Contract-EXTENT-3 IN THIS-PROCEDURE(
    INPUT  buf_contract.host-code,
    INPUT  buf_contract.contract-code,
    OUTPUT i-gl-Extent3
   ).
IF i-gl-Extent3[1] = 2 THEN DO:
   ASSIGN
      i-gl-Host-Code      = i-gl-Extent3[2]
      i-gl-Contract-Code  = i-gl-Extent3[3]
      .
END. ELSE DO:
   ASSIGN
      i-gl-Host-Code      = buf_contract.host-code
      i-gl-Contract-Code  = buf_contract.contract-code
      .
END.
FOR EACH
    buf_contract-specif
     EXCLUSIVE-LOCK
     WHERE
         buf_contract-specif.Host-code    = i-gl-Host-Code
     AND buf_contract-specif.Contract-num = i-gl-Contract-Code
            AND buf_contract-specif.artic        = buf_parts.artic
            AND buf_contract-specif.prod-type    = buf_parts.prod-type
            AND buf_contract-specif.prod-code    = buf_parts.prod-code :
           if p-action = "+" then
           assign
             buf_contract-specif.income-qnty =
                 (if  buf_contract-specif.income-qnty = ? then 0 else buf_contract-specif.income-qnty ) -
                 ( buf_parts.qnty / buf_contract-specif.cli-base-rate )
           .
           else
           assign
             buf_contract-specif.income-qnty =
                 (if  buf_contract-specif.income-qnty = ? then 0 else buf_contract-specif.income-qnty ) +
                 ( buf_parts.qnty / buf_contract-specif.cli-base-rate )
           .
       end.
  end.
end.
end.
end procedure.
procedure lib-trn4_linesprc :
define input  parameter p-recid-doc-line as recid no-undo .
define output parameter p-mess as character no-undo .
  do
  on error undo, return error return-value
  :
p-mess = "" .
define buffer buf_trn-doc  for ub.trn-doc  .
define buffer buf_doc-line for ub.doc-line  .
define buffer buf_contract for ub.contract .
define buffer buf_goods    for ub.goods  .
define buffer buf_contract-specif for ub.contract-specif .
define variable v-income-qnty as decimal   no-undo .
find first buf_doc-line no-lock where recid(buf_doc-line) = p-recid-doc-line no-error .
     if error-status :error then return .
find first buf_goods no-lock where
           buf_goods.artic = buf_doc-line.artic and
           buf_goods.prod-type = buf_doc-line.prod-type and
           buf_goods.prod-code = buf_doc-line.prod-code no-error .
if error-status :error then do:
  p-mess =  substitute("Не найден товар  &1 &2&3"  ,buf_doc-line.artic,buf_doc-line.prod-type,buf_doc-line.prod-code  ) .
  return .
end.
if buf_goods.stts <> 0  then do:
   p-mess = substitute("Товар удален : &1 &2&3 &4"  ,buf_doc-line.artic,buf_doc-line.prod-type,buf_doc-line.prod-code , buf_goods.gds-name  ) .
end.
find first buf_trn-doc no-lock where
           buf_trn-doc.doc-code = buf_doc-line.doc-code
           no-error .
     if error-status :error then return .
define variable v-qnty-spec as logical   no-undo .
define variable vss-include-info84 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
empty temp-table thbjattr_thbj-attr.
run adm/shattri.p (
   input "get":U
  ,input buf_trn-doc.obj-type
  ,input buf_trn-doc.obj-code
  ,input 'contr-in':U
  ,input  ""
  ,output v-value-character
  ,output v-value-date
  ,output v-value-decimal
  ,output v-value-integer
  ,output v-value-logical
  ,output par-type
  ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
  ) no-error .
for each thbjattr_thbj-attr :
    if thbjattr_thbj-attr.prop-code = 'contr-qnty-spec':U then v-qnty-spec = thbjattr_thbj-attr.property-value-logical .
end.
if v-qnty-spec = false  then return .
    find first buf_contract no-lock where
               buf_contract.host-code     = buf_trn-doc.host-code and
               buf_contract.contract-code = buf_trn-doc.contract-code no-error .
               if error-status :error then return .
      if available buf_doc-line  then do :
define variable vss-include-info85 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
ASSIGN
   i-gl-Host-Code      = 0
   i-gl-Contract-Code  = 0
   i-gl-Extent3        = 0
   .
RUN MS-Contract-EXTENT-3 IN THIS-PROCEDURE(
    INPUT  buf_contract.host-code,
    INPUT  buf_contract.contract-code,
    OUTPUT i-gl-Extent3
   ).
IF i-gl-Extent3[1] = 2 THEN DO:
   ASSIGN
      i-gl-Host-Code      = i-gl-Extent3[2]
      i-gl-Contract-Code  = i-gl-Extent3[3]
      .
END. ELSE DO:
   ASSIGN
      i-gl-Host-Code      = buf_contract.host-code
      i-gl-Contract-Code  = buf_contract.contract-code
      .
END.
    FIND FIRST buf_contract-specif
           NO-LOCK
           WHERE
               buf_contract-specif.Host-code    = i-gl-Host-Code
           AND buf_contract-specif.Contract-num = i-gl-Contract-Code
              AND buf_contract-specif.artic        = buf_doc-line.artic
              AND buf_contract-specif.prod-type    = buf_doc-line.prod-type
              AND buf_contract-specif.prod-code    = buf_doc-line.prod-code
           NO-ERROR.
                if not available buf_contract-specif then return .
           if buf_contract-specif.qnty <> ?  and buf_contract-specif.qnty <> 0 then do:
                assign
                p-mess = "" .
                 v-income-qnty =
                    ( buf_doc-line.doc-qnty / buf_contract-specif.cli-base-rate )
                    .
                 if v-income-qnty > buf_contract-specif.qnty
                      then do:
                      p-mess =
                          buf_contract-specif.artic + " " + buf_contract-specif.prod-type +
                          string ( buf_contract-specif.prod-code ) +
                          string ( buf_doc-line.doc-qnty ) + " (=" +  string(v-income-qnty) + ")" +
                          " По спецификации:" +
                          string ( if buf_contract-specif.qnty = ? then "неопределено" else string(buf_contract-specif.qnty)) + chr(10) .
                      end.
           end.
       end.
 end.
end procedure.
PROCEDURE userlogingerr :
  define parameter buffer bf_trn-doc for ub.trn-doc .
  define input parameter p-vid-action as integer no-undo.
  define input parameter p-mess as character no-undo.
  define input parameter p-db-num as integer no-undo.
  define buffer bf_clients for ub.clients .
  define variable v-vid-param       as character no-undo .
  define variable v-action          as character no-undo .
  define variable varshift-date as date      no-undo.
  define variable varshift-num  as integer   no-undo.
  define variable varshift-name as character no-undo.
  find first bf_clients no-lock where bf_clients.obj-type = 'чел':U and  bf_clients.obj-code = bf_trn-doc.boss no-error.
define variable vss-include-info86 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curshift in g#library
  (input  c-trn-doc.obj-type
  ,input  c-trn-doc.obj-code
  ,output varshift-date
  ,output varshift-num
  ,output varshift-name
  ) no-error .
  if available (bf_trn-doc)
  then do:
    v-vid-param = "Initiator=" + "User" + chr(4) +
                  "ResponsiblePerson=" + ( if available (bf_clients) then bf_clients.obj-name else "" ) + chr(4) +
                  "SHOP_NUM=" + string(bf_trn-doc.obj-code) + chr(4) +
                  "Contractor=" + bf_trn-doc.cli-name + chr(4) +
                  "DocNum=" + string(bf_trn-doc.doc-code) + chr(4) +
                  "FactDate=" + (if string(bf_trn-doc.fact-date) = ? then '' else string(bf_trn-doc.fact-date)) + chr(4) +
                  "DocType=" + string(bf_trn-doc.doc-type) + chr(4) +
                  "SHIFT_NUM_DOC=" + (if string(bf_trn-doc.shift-num) = ? then '' else string(bf_trn-doc.shift-num)) + (if string(bf_trn-doc.shift-date) = ? then '' else string(bf_trn-doc.shift-date, "99999999")) + chr(4) +
                  "SHIFT_NUM=" + (if string(varshift-num) = ? then '' else string(varshift-num)) + (if string(varshift-date) = ? then '' else string(varshift-date, "99999999")) + chr(4) +
                  "StatusOld=" + "" + chr(4) +
                  "StatusNew=" + string(bf_trn-doc.status_) + (if bf_trn-doc.flag then "+" else "-" ) + chr(4) +
                  "RESULT=" + string( 1 ) + chr(4) +
                  "Description=" + p-mess no-error.
  end.
  run trg/userlog.p (
        input 'update_err':U
      , input 'trn-doc':U
      , input buffer bf_trn-doc:handle
      , input p-vid-action
      , input v-vid-param
  ) no-error.
end procedure.
procedure change_mark_sts_trn-doc:
    define input parameter iDocCode like ub.trn-doc.doc-code no-undo.
    define input parameter iObjType like ub.trn-doc.obj-type no-undo.
    define input parameter iObjCode like ub.trn-doc.obj-code no-undo.
    define input parameter iStatus  as   character           no-undo.
    define variable vCount   as integer   no-undo.
    define variable vElem    as character no-undo.
    define buffer buf_doc-line      for ub.doc-line.
    define buffer buf_goods         for ub.goods.
    define buffer buf_marking-lines for ub.marking-lines.
    define buffer buf_marking       for ub.marking.
    if num-entries(iStatus,":") = 1 then iStatus = substitute("*:&1",iStatus).
    for each buf_doc-line no-lock where buf_doc-line.doc-code = iDocCode:
      find first buf_goods no-lock where
                 buf_goods.artic     = buf_doc-line.artic
             and buf_goods.prod-type = buf_doc-line.prod-type
             and buf_goods.prod-code = buf_doc-line.prod-code.
      for each buf_marking-lines exclusive-lock where
               buf_marking-lines.gds-code = buf_goods.gds-code
           and buf_marking-lines.out-code = iDocCode
           and buf_marking-lines.obj-type = iObjType
           and buf_marking-lines.obj-code = iObjCode
      :
        for first buf_marking exclusive-lock where
                 buf_marking.mark begins buf_marking-lines.mark:
          CHNG:
          do vCount = 1 to num-entries(iStatus):
              vElem = entry(vCount,iStatus).
              if can-do(entry(1,vElem,":"),string(buf_marking.sts)) then
              do:
                  buf_marking.sts = integer(entry(2,vElem,":")).
                  buf_marking-lines.sts = buf_marking.sts.
                  validate buf_marking.
                  leave CHNG.
              end.
          end.
        end.
      end.
    end.
end procedure.
