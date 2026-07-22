define input        parameter parparentproc as widget-handle no-undo.
define input        parameter p-bttns       as character     no-undo.
define input        parameter p-mode        as character     no-undo.
define input        parameter p-obj-type    as character     no-undo.
define input        parameter p-obj-code    as integer       no-undo.
define input        parameter p-doc-code    as character     no-undo.
define input        parameter p-artic       as character     no-undo.
define input        parameter p-prod-type   as character     no-undo.
define input        parameter p-prod-code   as integer       no-undo.
define input-output parameter p-rid-list    as character     no-undo.
define variable vss-revision    as character no-undo initial "$Revision$":U.
define variable vss-author      as character no-undo initial "$Author$":U.
define variable vss-date        as character no-undo initial "$Date$":U.
define variable vss-workfile    as character no-undo initial "$Workfile$":U.
define variable vss-archive     as character no-undo initial "$Archive$":U.
define variable vss-description as character no-undo initial "История строк накладных (весовой учет топлива)":U.
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
FUNCTION Int2Char RETURNS CHARACTER ( INPUT i-num AS INTEGER ) :   DEFINE VARIABLE v-str AS CHARACTER NO-UNDO.   RUN conv-int-to-char IN THIS-PROCEDURE ( INPUT i-num, OUTPUT v-str ) NO-ERROR.   RETURN ( IF ERROR-STATUS :ERROR THEN ? ELSE v-str ). END FUNCTION.      PROCEDURE conv-int-to-char :   DEFINE  INPUT PARAMETER p-num AS INTEGER   NO-UNDO.   DEFINE OUTPUT PARAMETER p-str AS CHARACTER NO-UNDO.   DO ON ERROR UNDO, RETURN ERROR :     ASSIGN p-str = TRIM( STRING( p-num, "->>>>>>>>>>>>":U ) ).   END.  END PROCEDURE.
FUNCTION Rec2Char RETURNS CHARACTER ( INPUT i-rec AS RECID ) :
  DEFINE VARIABLE v-str AS CHARACTER NO-UNDO.
  RUN conv-rec-to-char IN THIS-PROCEDURE ( INPUT i-rec, OUTPUT v-str ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN ? ELSE v-str ).
END FUNCTION.
PROCEDURE conv-rec-to-char :
  DEFINE  INPUT PARAMETER p-rec AS RECID     NO-UNDO.
  DEFINE OUTPUT PARAMETER p-res AS CHARACTER NO-UNDO.
  DO ON ERROR UNDO, RETURN ERROR :
    ASSIGN p-res = TRIM( STRING( p-rec, "->>>>>>>>>>>9":U ) ).
  END.
END PROCEDURE.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define NEW SHARED temp-table temp-changes no-undo
field f_name as character
field l_name as character
field v_old as character
field v_new as character
field t_name as character
field num_ as integer
field uniq-key-rec as character
field action as integer
field fNotChange as logical
index pi is unique primary
num_
t_name
f_name
index
Chan
fnotChange
t_name
f_name
index imain uniq-key-rec
.
FUNCTION get-all-fields returns character (p-file-name as character ):
define variable v-dop as character no-undo .
  find first _file no-lock where _file._file-name = p-file-name no-error .
  if not available _file then return "":U.
  for each _field no-lock where
           _field._file-recid = recid(_file) :
    assign
    v-dop = v-dop + _field._field-name + chr(44)
    .
  end.
  return trim(v-dop).
END FUNCTION.
PROCEDURE proc-full-temp-changes :
  define input  parameter p-hst-handle as handle    no-undo .
  define input  parameter p-main-table as character no-undo .
  define input  parameter p-field-list as character no-undo .
  define input  parameter p-label-form as character no-undo .
  define variable h-new-buf         as handle    no-undo .
  define variable h-main-buf        as handle    no-undo .
  define variable h-for-comp        as handle    no-undo .
  define variable v-inform          as character no-undo .
  define variable v-ind             as integer   no-undo .
  define variable v-idx-field-qnty  as integer   no-undo .
  define variable v-num-entries     as integer   no-undo .
  define variable fh                as handle    no-undo .
  define variable fh-main           as handle    no-undo .
  define variable fh-old            as handle    no-undo .
  define variable fh-new            as handle    no-undo .
  define variable v-field-name      as character no-undo .
  define variable v-field-lvl       as character no-undo .
  define variable v-field-form      as character no-undo .
  define variable v-search-exp      as character no-undo .
  define variable v-srch-main       as character no-undo .
  define variable v-word-link       as character no-undo .
  define variable v-av-chip-num     as logical   no-undo .
  define variable v-main-pi-fld-lst as character no-undo .
  define variable v-main-fld-lst    as character no-undo .
  define variable v-delim-list      as character no-undo .
  define variable v-label           as character no-undo .
  define variable v-old-value       as character no-undo case-sensitive.
  define variable v-new-value       as character no-undo case-sensitive.
  define variable v-chg-fields as character no-undo.
  for each temp-changes:
    delete temp-changes.
  end.
  if not p-hst-handle:available then do:
    return .
  end.
  create buffer h-new-buf  for table p-hst-handle .
  create buffer h-main-buf for table p-main-table .
  assign
    v-inform = h-main-buf:index-information(1)
    v-ind    = 2
  .
  do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
  on error undo, return error
  :
    assign
      v-inform = h-main-buf:index-information( v-ind )
      v-ind    = v-ind + 1
    .
  end.
  if v-inform = ?
    or LC( entry( 1, v-inform, ",":U ) ) = "default":U
    or entry( 3, v-inform, ",":U ) <> "1":U
  then do:
    return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-workfile, h-main-buf:name ).
  end.
  assign
    v-idx-field-qnty = num-entries( v-inform ) - 4
  .
  if v-idx-field-qnty < 2 then do:
    return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-workfile, v-inform, h-main-buf:name ).
  end.
  assign
    v-srch-main   = "where":U
    v-word-link   = "":U
    v-av-chip-num = false
    v-delim-list  = "":U
  .
  do v-ind = 1 to v-idx-field-qnty by 2
  on error undo, return error
  :
    assign
      v-field-name      = entry( 4 + v-ind, v-inform, ",":U )
      fh                = p-hst-handle:buffer-field( v-field-name )
      fh-main           = h-main-buf:buffer-field( v-field-name )
      v-srch-main       = substitute( "&1 &2 &3.&4 =", v-srch-main, v-word-link, fh-main:table, v-field-name )
      v-main-pi-fld-lst = v-main-pi-fld-lst + v-delim-list + v-field-name
    .
    if fh:data-type ="character":U then do:
      assign
        v-srch-main = substitute( '&1 "&2"', v-srch-main, replace( replace( fh:buffer-value(), '"':U, '""':U ), '~~':U, '~~~~':U ) )
      .
    end.
    else do:
      assign
        v-srch-main = substitute( "&1 &2", v-srch-main, fh:buffer-value() )
      .
    end.
    if v-delim-list = "":U then do:
      assign
        v-delim-list = ",":U
      .
    end.
    if v-word-link = "":U then do:
      assign
        v-word-link = "and":U
      .
    end.
  end.
  assign
    v-delim-list  = "":U
  .
  do v-ind = 1 to h-main-buf:num-fields
  on error undo, return error
  :
    assign
      fh-main      = h-main-buf:buffer-field( v-ind )
      v-field-name = fh-main:name
    .
      assign
        v-main-fld-lst = v-main-fld-lst + v-delim-list + v-field-name
      .
      if v-delim-list = "":U then do:
        assign
          v-delim-list = ",":U
        .
      end.
  end.
  assign
    v-inform = p-hst-handle:index-information(1)
    v-ind    = 2
  .
  do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
  on error undo, return error
  :
    assign
      v-inform = p-hst-handle:index-information( v-ind )
      v-ind    = v-ind + 1
    .
  end.
  if v-inform = ?
    or LC( entry( 1, v-inform, ",":U ) ) = "default":U
    or entry( 3, v-inform, ",":U ) <> "1":U
  then do:
    return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-workfile, p-hst-handle:name ).
  end.
  assign
    v-idx-field-qnty = num-entries( v-inform ) - 4
  .
  if v-idx-field-qnty < 2 then do:
    return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-workfile, v-inform, p-hst-handle:name ).
  end.
  assign
    v-search-exp  = "where":U
    v-word-link   = "":U
    v-av-chip-num = false
  .
  do v-ind = 1 to v-idx-field-qnty by 2
  on error undo, return error
  :
    assign
      v-field-name = entry( 4 + v-ind, v-inform, ",":U )
      fh           = p-hst-handle:buffer-field( v-field-name )
      v-search-exp = substitute( "&1 &2 &3.&4", v-search-exp, v-word-link, fh:table, v-field-name )
    .
    if v-field-name = "chip-num":U then do:
      assign
        v-search-exp  = substitute( "&1 >", v-search-exp )
        v-av-chip-num = true
      .
    end.
    else do:
      assign
        v-search-exp = substitute( "&1 =", v-search-exp )
      .
    end.
    if fh:data-type ="character":U then do:
      assign
        v-search-exp = substitute( '&1 "&2"', v-search-exp, replace( replace( fh:buffer-value(), '"':U, '""':U ), '~~':U, '~~~~':U ) )
      .
    end.
    else do:
      assign
        v-search-exp = substitute( '&1 &2', v-search-exp, fh:buffer-value() )
      .
    end.
    if v-word-link = "":U then do:
      assign
        v-word-link = "and":U
      .
    end.
  end.
  if v-av-chip-num = false then do:
    message
      vss-workfile vss-revision vss-description skip
      substitute( "Таблица &2 не содержит поля chip-num.", vss-workfile, p-hst-handle:name ) skip
      "Использование данной процедуры невозможно!" skip
      view-as alert-box error .
    return error .
  end.
  h-new-buf:find-first( v-search-exp, no-lock ) no-error .
  if not h-new-buf:available then do:
    h-main-buf:find-first( v-srch-main, no-lock ) no-error .
    if not h-main-buf:available then do:
      assign
        h-for-comp = ?
      .
    end.
    else do:
      assign
        h-for-comp = h-main-buf
      .
    end.
  end.
  else do:
    assign
      h-for-comp = h-new-buf
    .
  end.
  assign
    v-num-entries = num-entries( v-main-fld-lst, ",":U )
  .
  do v-ind = 1 to v-num-entries
  on error undo, return error return-value
  :
    assign
      v-field-name = entry( v-ind, v-main-fld-lst )
      fh-old       = p-hst-handle:buffer-field( v-field-name )
      v-old-value  = fh-old:buffer-value()
      v-label      = trim( fh-old:label )
    .
    if ( trim( p-field-list ) <> "":U
         and lookup( v-field-name, p-field-list ) > 0
       )
       or trim( p-field-list ) = "":U
    then do:
      if h-for-comp <> ? then do:
        assign
          fh-new      = h-for-comp:buffer-field( v-field-name )
          v-new-value = fh-new:buffer-value()
        .
      end.
      else do:
        assign
          v-new-value = "":U
        .
      end.
      if v-old-value <> v-new-value
      then do:
        create temp-changes.
        assign
          temp-changes.t_name = p-main-table
          temp-changes.f_name = v-field-name
          temp-changes.l_name = replace( v-label, "&":U, "":U )
          temp-changes.v_old  = trim( v-old-value )
          temp-changes.v_new  = trim( v-new-value )
          temp-changes.num_   = 0
          temp-changes.fNotChange = v-old-value eq v-new-value
        .
      end.
    end.
  end.
  assign
    v-num-entries = num-entries( p-label-form, chr(8) )
  .
  do v-ind = 1 to v-num-entries
  on error undo, return error return-value
  :
    if num-entries( entry( v-ind, p-label-form, chr(8) ), chr(4) ) = 3 then do:
      assign
        v-field-name = entry( 1, entry( v-ind, p-label-form, chr(8) ), chr(4) )
        v-field-lvl  = entry( 2, entry( v-ind, p-label-form, chr(8) ), chr(4) )
        v-field-form = entry( 3, entry( v-ind, p-label-form, chr(8) ), chr(4) )
      .
      find first temp-changes
        where temp-changes.f_name = v-field-name
        no-error .
      if available temp-changes then do:
        if trim( v-field-lvl ) <> "":U then do:
          assign
            temp-changes.l_name = v-field-lvl
          .
        end.
        if trim( v-field-form ) <> "":U then do:
          assign
            temp-changes.v_old = dynamic-function( v-field-form, temp-changes.v_old )
          .
          if h-for-comp <> ? then do:
            assign
              temp-changes.v_new = dynamic-function( v-field-form, temp-changes.v_new )
            .
          end.
        end.
      end.
    end.
    else do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка! Список должен содержать три поля с разделителем delim-par!" skip
        substitute( "список для поля '&1': '&2'"
                    ,entry( 1, entry( v-ind, p-label-form, chr(8) ), chr(4) )
                    ,entry( v-ind, p-label-form, chr(8) )
                  ) skip
        substitute( "полный список: &2", p-label-form ) skip
        view-as alert-box error .
    end.
  end.
  delete object h-new-buf .
  delete object h-main-buf .
END PROCEDURE.
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-fltopend-rowid as rowid extent 18 no-undo .
procedure fltopend_fltopend :
define input parameter p-parent-handle as handle no-undo .
define input parameter p-qh as handle no-undo .
define input parameter p-flt-open-open-query  as character no-undo .
define input parameter p-where-cond as character no-undo .
define input parameter p-use-indFIRST-query-tail as character no-undo .
define input parameter p-use-ind-sort-clmn-by as character no-undo .
define input parameter p-indexed-reposition as character no-undo .
  do
  on error undo, return error
  :
define variable v-prepare-string as character no-undo .
define variable glog as logical no-undo .
assign
v-prepare-string = p-flt-open-open-query + " where " + chr(32) +
                   p-where-cond + chr(32)  +
                   p-use-indFIRST-query-tail + chr(32) +
                   p-use-ind-sort-clmn-by + chr(32) +
                   p-indexed-reposition
.
assign
glog = p-qh:query-prepare(v-prepare-string) no-error .
if not glog
or error-status:error then do:
  message error-status:get-message(1) view-as alert-box .
  undo, return error .
end.
assign
glog = p-qh:query-open no-error .
if not glog
or error-status:error then do:
  message error-status:get-message(1) view-as alert-box .
  undo, return error .
end.
  end.
end procedure.
procedure fltopend_fltfindd :
define input parameter p-parent-handle as handle no-undo .
define input parameter p-qh as handle no-undo .
define input parameter p-rowid as rowid no-undo .
define input parameter p-next as logical no-undo .
define input parameter p-lock as integer no-undo .
define input parameter p-bh as handle no-undo .
define input parameter p-where-cond as character no-undo .
define input parameter p-use-index-phrase as character no-undo .
define variable glog as logical no-undo .
define variable v-qh as handle no-undo .
define variable v-bh as handle no-undo .
define variable v-recid as recid no-undo .
define variable v-prepare-string as character no-undo .
do
on error undo, return error
on stop undo, return error
:
  glog = p-bh:find-by-rowid( p-rowid, p-lock) no-error.
  create buffer v-bh for table p-bh buffer-name p-bh:name.
  create query v-qh.
  v-qh:set-buffers(v-bh).
  v-prepare-string = substitute("for each &1 &2 &3"
                                  ,v-bh:name
                                  ,p-where-cond
                                  ,p-use-index-phrase).
  glog = v-qh:query-prepare(v-prepare-string) no-error.
  if not glog then do:
    delete object v-qh.
    delete object v-bh.
    undo, return error .
  end.
  glog = v-qh:query-open no-error .
  if not glog then do:
    delete object v-qh.
    delete object v-bh.
    undo, return error .
  end.
  if p-next then do:
    v-qh:reposition-to-rowid(p-rowid) no-error .
    glog = v-qh:get-next( p-lock) no-error .
    glog = v-qh:get-next( p-lock) no-error .
    if not glog or v-qh:query-off-end = yes then do:
      glog = v-qh:get-first( p-lock) no-error .
    end.
  end.
  else do:
    glog = v-qh:get-first( p-lock) no-error .
  end.
  v-recid = v-bh:recid no-error .
  delete object v-qh.
  delete object v-bh.
  return string(v-recid) .
end.
end procedure.
procedure fltopend_fltfindq :
define input parameter p-parent-handle as handle no-undo .
define input parameter p-qh as handle no-undo .
define input parameter p-next as logical no-undo .
define input parameter p-lock as integer no-undo .
define input parameter p-flt-open-open-query  as character no-undo .
define input parameter p-where-cond as character no-undo .
define input parameter p-use-indFIRST-query-tail as character no-undo .
define input parameter p-use-ind-sort-clmn-by as character no-undo .
define input parameter p-indexed-reposition as character no-undo .
define output parameter p-fltopend-rowid as rowid extent 18 no-undo .
define variable glog as logical no-undo .
define variable v-qh as handle no-undo .
define variable v-bh as handle no-undo extent 18.
define variable v-rowid as rowid no-undo extent 18.
define variable v-ii as integer no-undo .
define variable v-prepare-string as character no-undo .
do
on error undo, return error
on stop undo, return error
:
  create query v-qh.
  do v-ii = 1 to p-qh:num-buffers:
    create buffer v-bh[v-ii] for table p-qh:get-buffer-handle(v-ii) buffer-name p-qh:get-buffer-handle(v-ii):name .
    assign
    v-rowid[v-ii] = p-qh:get-buffer-handle(v-ii):rowid
    no-error.
    v-qh:add-buffer(v-bh[v-ii]).
  end.
  assign
  v-prepare-string = p-flt-open-open-query + " where " + chr(32) +
                    p-where-cond + chr(32)  +
                    p-use-indFIRST-query-tail + chr(32) +
                    p-use-ind-sort-clmn-by + chr(32) +
                    p-indexed-reposition
  .
  glog = v-qh:query-prepare( v-prepare-string) no-error .
  if not glog then do:
    delete object v-qh.
    do v-ii = 1 to p-qh:num-buffers:
      delete object v-bh[v-ii].
    end.
    undo, return error .
  end.
  glog = v-qh:query-open no-error .
  if not glog then do:
    delete object v-qh.
    do v-ii = 1 to p-qh:num-buffers:
      delete object v-bh[v-ii].
    end.
    undo, return error .
  end.
  if p-next then do:
    glog = v-qh:reposition-to-rowid(v-rowid) no-error .
    glog = v-qh:get-next( p-lock) no-error .
    glog = v-qh:get-next( p-lock) no-error .
    if not glog or v-qh:query-off-end = yes then do:
      glog = v-qh:get-first( p-lock) no-error .
    end.
  end.
  else do:
    glog = v-qh:get-first( p-lock) no-error .
  end.
  do v-ii = 1 to p-qh:num-buffers:
    assign
    p-fltopend-rowid[v-ii] = v-bh[v-ii]:rowid
    no-error.
  end.
  delete object v-qh.
  do v-ii = 1 to p-qh:num-buffers:
    delete object v-bh[v-ii].
  end.
end.
end procedure.
define new shared buffer buf_changes  for temp-changes.
define new shared buffer buf_history  for ub.c-inv-line.
define            buffer buf_sch_hist for ub.c-inv-line.
define            buffer buf_source   for ub.inv-line.
define            buffer buf_object   for ub.clients.
define variable filter-point     as character no-undo initial 'История строк накладных (весовой учет топлива)':U.
define variable filter-point0    as character no-undo initial 'История строк накладных (весовой учет топлива)':U.
define variable sort-change-name as character no-undo.
define variable sort-column-name as character no-undo.
define variable sch-field        as character no-undo.
define variable FoundRec         as recid     no-undo.
define variable p-act-codes      as character no-undo initial '99,1,2,3,4,9,51,79':U.
define variable p-act-names      as character no-undo initial 'Удаление,Создание,Изменение,Коррекция,Восстановление,Смена_кода,Смена_артик,Выключ.':U.
define variable doc-rec          as recid     no-undo.
define variable p-host-code      as integer   no-undo.
function mark-string returns character ( buffer loc-buf for ub.c-inv-line ) :
  define variable v_mark-sign as character no-undo.
  run get-mark-string in this-procedure ( buffer loc-buf, output v_mark-sign ).
  return ( v_mark-sign ).
end function.
function ShowAction returns character ( input i-act as integer ) :
  define variable v_act as character no-undo.
  run get-action-name in this-procedure ( input i-act, output v_act ).
  return ( v_act ).
end function.
function obj-short returns character ( input i-type as character, input i-code as integer ) :
  define variable v_obj-name as character no-undo.
  run get-obj-short-name in this-procedure ( input i-type, input i-code, output v_obj-name ).
  return ( v_obj-name ).
end function.
function obj-name returns character ( input i-type as character, input i-code as integer ) :
  define variable v_obj-name as character no-undo.
  run get-obj-full-name in this-procedure ( input i-type, input i-code, output v_obj-name ).
  return ( v_obj-name ).
end function.
function ext-type returns character ( input i-type as character ) :
  define variable v_ext-type as character no-undo.
  run get-ext-type in this-procedure ( input i-type, output v_ext-type ).
  return ( v_ext-type ).
end function.
function gds-name returns character ( input i-artic     as character,
                                      input i-prod-type as character,
                                      input i-prod-code as integer    ) :
  define variable v_gds-name as character no-undo.
  run get-goods-name in this-procedure ( input i-artic, input i-prod-type, input i-prod-code, output v_gds-name ).
  return ( v_gds-name ).
end function.
function is-petrol returns logical ( input i-artic     as character,
                                     input i-prod-type as character,
                                     input i-prod-code as integer    ) :
  define variable v_is-petrol as logical no-undo.
  run is-petrolium-goods in this-procedure ( input i-artic, input i-prod-type, input i-prod-code, output v_is-petrol ).
  return ( v_is-petrol ).
end function.
define button b-help label "Помо&щь"   size-chars 10.00 by 1.00 default.
define button b-mark label "&*"        size-chars  3.00 by 1.00 default.
define button b-quit label "Вы&ход"    size-chars 10.00 by 1.00 default auto-end-key.
define button b-sch  label "&Фильтр"   size-chars 10.00 by 1.00 default.
define button b-sel  label "Вы&бор"    size-chars 10.00 by 1.00 default auto-go.
define variable mark-num as integer   no-undo view-as fill-in size-chars  8.00 by 1.00 format "->>>,>>>":U.
define variable sch-code as character no-undo view-as fill-in size-chars 17.50 by 1.00 format "x(16)":U.
define variable sch-num  as integer   no-undo view-as fill-in size-chars  4.50 by 1.00 format ">>>":U.
define new shared query br-inv-lines for buf_history scrolling.
define new shared query br-changes for buf_changes scrolling.
define browse br-inv-lines query br-inv-lines display
  mark-string( buffer buf_history )  column-label '*'  format 'x(1)':U
  buf_history.doc-code  column-label 'Номер документа'  format "x(16)":U
  buf_history.artic  column-label 'Артикул'  format "x(16)":U
  obj-short( buf_history.prod-type, buf_history.prod-code )  column-label 'Производитель'  format "x(13)":U
  buf_history.wast-cli-qnty  column-label 'Факт кол-во, кг'  format "->>,>>>,>>9.<<<":U
  buf_history.after-cli-qnty  column-label 'Итого стало, кг'  format "->>,>>>,>>9.<<<":U
  buf_history.wast-rubl  column-label 'Цена продаж / кг (руб.)'  format "->>,>>>,>>>,>>>,>>9.99":U
  buf_history.unus-wast-rubl  column-label 'Учет. цена / кг (руб.)'  format "->>,>>>,>>>,>>>,>>9.99":U
  buf_history.wast-base  column-label 'Цена продаж / кг (б.в.)'  format "->>,>>>,>>>,>>>,>>9.99":U
  buf_history.unus-wast-base column-label 'Учет. цена / кг (б.в.)' format "->>,>>>,>>>,>>>,>>9.99":U
  buf_history.density column-label 'Плотность' format ">>9.999":U
  buf_history.before-cli-qnty column-label 'Кол-во до (инв.), кг' format "->>,>>>,>>9.<<<":U
  obj-name( buf_history.prod-type, buf_history.prod-code ) column-label 'Название производителя' format "x(40)":U
  gds-name( buf_history.artic, buf_history.prod-type, buf_history.prod-code ) column-label 'Название товара' format "x(48)":U
  buf_history.host-code column-label 'Код фирмы' format ">>>>>>>>9":U
  ext-type( buf_history.ext-doc-type ) column-label 'Расширенный тип документа' format "x(25)":U
  buf_history.fact-order column-label 'Факт ордер' format "->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>9.<<<<<<<<<<":U
  buf_history.status_ column-label 'Статус' format "x(8)":U
  obj-short( buf_history.obj-type, buf_history.obj-code ) column-label 'Объект' format "x(13)":U
  obj-name(  buf_history.obj-type, buf_history.obj-code ) column-label 'Наименование объекта' format "x(40)":U
  buf_history.corr-user-name column-label 'Изменил' format "x(8)":U
  ShowAction( buf_history.action ) column-label 'Действие' format "x(10)":U
  buf_history.corr-date column-label 'Дата корр.' format "99/99/9999":U
  STRING( buf_history.corr-time, 'HH:MM:SS':U ) column-label 'Время' format "x(8)":U
  buf_history.chip-num column-label 'Щепка' format "->,>>>,>>>,>>9":U
  enable
  buf_history.density
with no-row-markers separators size-chars 98.25 by 13.13.
define browse br-changes query br-changes display
  buf_changes.l_name  column-label 'Изменилось'  format 'x(15)':U
  buf_changes.v_old  column-label 'Было'  format 'x(48)':U
  buf_changes.v_new  column-label 'Стало'  format 'x(48)':U
  enable
  buf_changes.l_name
with no-row-markers separators size-chars 98.25 by 4.75.
define frame fr-D-inv-line-0
    b-quit    at row  1 col  1
    b-mark    at row  1 col 11
    mark-num  at row  1 col 14  no-label                              fgcolor 4
    b-sel     at row  1 col 21
    b-sch     at row  1 col 31
    b-help    at row  1 col 81
  br-inv-lines at row  2.50 col  1.50
  "          ":U at row 16 col  1.62 view-as text size-chars 98.00 by 1.00
  "ПОИСК ПО:"    at row 16 col  2.00 view-as text size-chars  9.00 by 1.00 bgcolor 3 fgcolor 15
  sch-code       at row 16 col 11.50    label "&Артикулу"
  sch-num        at row 16 col 94.75 no-label                              fgcolor 4
  br-changes   at row 17.50 col  1.50
with view-as dialog-box keep-tab-order side-labels no-underline three-d scrollable
     title 'История строк накладных (весовой учет топлива)':U
     default-button b-quit cancel-button b-quit.
assign frame fr-D-inv-line-0 :scrollable = no.
assign br-inv-lines         :num-locked-columns in frame  fr-D-inv-line-0  = 1
       buf_history.density :read-only          in browse br-inv-lines = yes
       buf_changes.l_name :read-only          in browse   br-changes   = yes.
assign b-mark    :tooltip in frame fr-D-inv-line-0 = "Поставить/снять отметку записи"
       b-quit     :tooltip in frame fr-D-inv-line-0 = "Вернуться в окно вызова"
       b-sch  :tooltip in frame fr-D-inv-line-0 = "Установить/снять фильтр"
       b-help    :tooltip in frame fr-D-inv-line-0 = "Интерактивная помощь в формате *.html"
       b-sel  :tooltip in frame fr-D-inv-line-0 = "Выбрать текущую(ие) запись(и)"
       br-inv-lines :tooltip in frame fr-D-inv-line-0 = "Список действий над строками"
        br-changes   :tooltip in frame fr-D-inv-line-0 = "Список изменений строки"
        sch-code     :tooltip in frame fr-D-inv-line-0 = "Артикул" + " для поиска. Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>"
        sch-num      :tooltip in frame fr-D-inv-line-0 = "Количество найденных записей"
        mark-num     :tooltip in frame fr-D-inv-line-0 = "Отмеченные записи".
on delete-character of br-inv-lines in frame fr-D-inv-line-0 do:
  if b-mark :sensitive in frame fr-D-inv-line-0 then do: apply "CHOOSE":U to b-mark in frame fr-D-inv-line-0. end.
end.
on insert-mode of br-inv-lines in frame fr-D-inv-line-0 do:
  if           b-mark   :sensitive in frame fr-D-inv-line-0 then do:
    apply "CHOOSE":U to b-mark     in frame fr-D-inv-line-0.
  end. else if b-sel :sensitive in frame fr-D-inv-line-0 then do:
    apply "CHOOSE":U to b-sel   in frame fr-D-inv-line-0.
  end.
end.
on choose of b-mark in frame fr-D-inv-line-0 do:
  if available buf_history then do:
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-str-recid9 as character no-undo .
define variable v-num-entry9 as integer   no-undo .
assign
  v-str-recid9 = trim( string( recid( buf_history ) , "->>>>>>>>>>>9":U ) )
  v-num-entry9 = lookup( v-str-recid9 , p-rid-list )
.
if v-num-entry9 > 0 then do:
  assign
    entry( v-num-entry9, p-rid-list ) = "":U
    p-rid-list = trim( replace( p-rid-list , chr(44) + chr(44) , chr(44) ) , chr(44) )
  .
end.
else do:
  assign
    p-rid-list = p-rid-list + ( if p-rid-list = "":U then "":U else chr(44) ) + v-str-recid9
  .
end.
    br-inv-lines :refresh( ) in frame fr-D-inv-line-0.
    if last-event :function <> "MOUSE-SELECT-DBLCLICK" then do:
      br-inv-lines :select-next-row( ) in frame fr-D-inv-line-0.
    end.
    apply "VALUE-CHANGED":U to br-inv-lines in frame fr-D-inv-line-0.
    if num-entries( p-rid-list ) = 0 then do: hide                                mark-num   in frame fr-D-inv-line-0. end.
                                     else do: display num-entries( p-rid-list ) @ mark-num with frame fr-D-inv-line-0. end.
  END.
  apply "ENTRY":U to br-inv-lines in frame fr-D-inv-line-0.
end.
on choose of b-quit in frame fr-D-inv-line-0 do:
  run gbl/markqwa.p ( input b-mark :sensitive, input p-rid-list ) no-error.
  if error-status :error then do: return no-apply. end.
end.
on choose of b-sch in frame fr-D-inv-line-0 do:
  run proc-filter in this-procedure no-error.
  if error-status :error then do: return no-apply. end.
end.
on choose of b-sel in frame fr-D-inv-line-0 do:
  if not available buf_history then do: return no-apply. end.
  if p-rid-list = "":U or b-mark :sensitive = no then do: assign p-rid-list = string( recid( buf_history ) ). end.
end.
on return                of br-inv-lines in frame fr-D-inv-line-0 or
   mouse-select-dblclick of br-inv-lines in frame fr-D-inv-line-0 do:
  if           b-mark   :sensitive in frame fr-D-inv-line-0 then do:
      apply "CHOOSE":U to b-mark   in frame fr-D-inv-line-0.
  end. else IF b-sel :sensitive in frame fr-D-inv-line-0 then do:
      apply "CHOOSE":U to b-sel in frame fr-D-inv-line-0.
  end.
end.
on value-changed of br-inv-lines in frame fr-D-inv-line-0 do:
  run proc-view-changes in this-procedure no-error.
end.
on entry of sch-code in frame fr-D-inv-line-0 do:
  if sch-field <> self :name then do:
    assign sch-num   = 0
           sch-field = self :name
           FoundRec  = ?.
  end.
  display sch-code  with frame fr-D-inv-line-0.
end.
on leave of sch-code in frame fr-D-inv-line-0 do:
  if lookup( last-event :function, "MOUSE-SELECT-DBLCLICK,RETURN" ) = 0 and last-event :label <> "CTRL-J" then do:
    assign FoundRec = ?
           sch-num  = 0.
  end.
  hide sch-num in frame fr-D-inv-line-0.
end.
on CTRL-J of sch-code in frame fr-D-inv-line-0 do:
  if input frame fr-D-inv-line-0 sch-code <> sch-code then do:
    assign sch-code.
    assign FoundRec = ?
           sch-num  = 0.
    hide   sch-num  in frame fr-D-inv-line-0.
  end.
  run proc-find-code in this-procedure ( input yes, input sch-code ) no-error.
  if error-status :error then do: return no-apply. end.
end.
on return of sch-code in frame fr-D-inv-line-0 do:
  assign sch-code.
  assign FoundRec = ?
         sch-num  = 0.
  hide   sch-num  in frame fr-D-inv-line-0.
  run proc-find-code in this-procedure ( input no,  input sch-code ) no-error.
  if error-status :error then do: return no-apply. end.
end.
on mouse-select-dblclick of sch-code in frame fr-D-inv-line-0 do:
  if input frame fr-D-inv-line-0 sch-code <> sch-code then do:
    assign sch-code.
    assign FoundRec = ?
           sch-num  = 0.
    hide   sch-num  in frame fr-D-inv-line-0.
  end.
  run proc-find-code in this-procedure ( input yes, input sch-code ) no-error.
  if error-status :error then do: return no-apply. end.
end.
define variable vss-include-info10 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F1 of frame fr-D-inv-line-0 anywhere do:
  if b-help :sensitive then DO: apply "CHOOSE":U to b-help in frame fr-D-inv-line-0. END.
  return no-apply.
end.
define variable vss-include-info11 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on INS of frame fr-D-inv-line-0 anywhere do:
  if b-mark :sensitive then DO: apply "CHOOSE":U to b-mark in frame fr-D-inv-line-0. END.
  return no-apply.
end.
define variable vss-include-info12 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F2 of frame fr-D-inv-line-0 anywhere do:
  if b-sel :sensitive then DO: apply "CHOOSE":U to b-sel in frame fr-D-inv-line-0. END.
  return no-apply.
end.
if valid-handle( active-window ) and frame fr-D-inv-line-0 :parent = ? then frame fr-D-inv-line-0 :parent = active-window.
if current-window :window-state = window-minimized then do: current-window :window-state = window-normal. end.
on window-close of frame fr-D-inv-line-0 do: apply "END-ERROR":U to self. end.
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame fr-D-inv-line-0
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
on choose of b-help in frame fr-D-inv-line-0
do:
  apply "help":u to frame fr-D-inv-line-0 .
end.
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
                v-frame-width = frame fr-D-inv-line-0:width - 0.3
                fh            = frame fr-D-inv-line-0:first-child
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
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
    if frame fr-D-inv-line-0 :height + p-change-value
        > decimal(session :work-area-height-pixels) / session :pixels-per-row
    then do:
      assign
        p-change-value = decimal(session :work-area-height-pixels) / session :pixels-per-row
                        - (frame fr-D-inv-line-0 :height-chars)
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
    if frame fr-D-inv-line-0 :height + p-change-value < v-diasize-orig-frame-height
    then do:
      assign
        p-change-value = v-diasize-orig-frame-height
                       - (frame fr-D-inv-line-0 :height-chars)
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
            frame fr-D-inv-line-0 :height = v-frame-height
          .
          if frame fr-D-inv-line-0 :scrollable = true
          then do:
            assign
              frame fr-D-inv-line-0 :virtual-height = v-frame-virtual-height
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame fr-D-inv-line-0 :scrollable = true
          then do:
            assign
              frame fr-D-inv-line-0 :virtual-height = v-frame-virtual-height
            .
          end.
          assign
            frame fr-D-inv-line-0 :height = v-frame-height
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
      v-frame-height = frame fr-D-inv-line-0 :height
      v-frame-virtual-height = frame fr-D-inv-line-0 :virtual-height
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
      v-field-group-handle = frame fr-D-inv-line-0 :first-child
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
    do with frame fr-D-inv-line-0
    :
      hide v-diasize-resize-button .
      assign
        v-diasize-resize-button :row    = 1
        v-diasize-resize-button :column = 1
      .
    end.
    if p-change-value > 0
    then do:
      if frame fr-D-inv-line-0 :scrollable = true
      then do:
        assign
          frame fr-D-inv-line-0 :virtual-height = frame fr-D-inv-line-0 :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame fr-D-inv-line-0 :height = frame fr-D-inv-line-0 :height + p-change-value
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
        frame fr-D-inv-line-0 :height = frame fr-D-inv-line-0 :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      if frame fr-D-inv-line-0 :scrollable = true
      then do:
        assign
          frame fr-D-inv-line-0 :virtual-height = frame fr-D-inv-line-0 :virtual-height + p-change-value
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
          ,input  string(frame fr-D-inv-line-0 :height - v-diasize-orig-frame-height)
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
      (input  (p-new-height - frame fr-D-inv-line-0 :height)
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
    if frame fr-D-inv-line-0 :width + p-change-value >
        session :width-chars
    then do:
      assign
        p-change-value = session :width-chars - frame fr-D-inv-line-0 :width
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
    if frame fr-D-inv-line-0 :width + p-change-value < v-diasize-orig-frame-width
    then do:
      assign
        p-change-value = v-diasize-orig-frame-width
                       - frame fr-D-inv-line-0 :width
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
            frame fr-D-inv-line-0 :width = v-frame-width
          .
          if frame fr-D-inv-line-0 :scrollable = true
          then do:
            assign
              frame fr-D-inv-line-0 :virtual-width = v-frame-virtual-width
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame fr-D-inv-line-0 :scrollable = true
          then do:
            assign
              frame fr-D-inv-line-0 :virtual-width = v-frame-virtual-width
            .
          end.
          assign
            frame fr-D-inv-line-0 :width = v-frame-width
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
      v-frame-width = frame fr-D-inv-line-0 :width
      v-frame-virtual-width = frame fr-D-inv-line-0 :virtual-width
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
      v-field-group-handle = frame fr-D-inv-line-0 :first-child
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
    do with frame fr-D-inv-line-0
    :
      hide v-diasize-resize-button .
      v-diasize-resize-button :row = 1.
      v-diasize-resize-button :column = 1.
    end.
    if p-change-value > 0
    then do:
      if frame fr-D-inv-line-0 :scrollable = true
      then do:
        assign
          frame fr-D-inv-line-0 :virtual-width = frame fr-D-inv-line-0 :virtual-width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
      assign
        frame fr-D-inv-line-0 :width = v-frame-width + p-change-value
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
        frame fr-D-inv-line-0 :width = frame fr-D-inv-line-0 :width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      if frame fr-D-inv-line-0 :scrollable = true
      then do:
        assign
          frame fr-D-inv-line-0 :virtual-width = frame fr-D-inv-line-0 :virtual-width + p-change-value
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
          ,input  string(frame fr-D-inv-line-0 :width - v-diasize-orig-frame-width)
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
      (input  (p-new-width - frame fr-D-inv-line-0 :width)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_position-resize-button :
  do with frame fr-D-inv-line-0
  :
    hide v-diasize-resize-button .
    assign
      v-diasize-resize-button :row = frame fr-D-inv-line-0 :height - v-diasize-resize-button :height
                  - 1
                  - (frame fr-D-inv-line-0 :border-bottom-pixels / session :pixels-per-row)
      v-diasize-resize-button :col = frame fr-D-inv-line-0 :width - v-diasize-resize-button :width
                  - 1
                  - (frame fr-D-inv-line-0 :border-right-pixels / session :pixels-per-column)
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
on alt-enter of frame fr-D-inv-line-0
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
      v-row-delta = v-new-row - frame fr-D-inv-line-0 :height
      v-col-delta = v-new-col - frame fr-D-inv-line-0 :width
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
            - frame fr-D-inv-line-0 :height-chars
        ,input true
        ) .
      run diasize_change-width in this-procedure
        (input session :width-chars
            - frame fr-D-inv-line-0 :width-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = false
      .
    end.
    else do:
      run diasize_change-width in this-procedure
        (input v-diasize-orig-frame-width
            - frame fr-D-inv-line-0 :width-chars
        ,input true
        ) .
      run diasize_change-height in this-procedure
        (input v-diasize-orig-frame-height
            - frame fr-D-inv-line-0 :height-chars
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
      v-diasize-current-frame-width  = frame fr-D-inv-line-0 :width
      v-diasize-current-frame-height = frame fr-D-inv-line-0 :height
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
    do with frame fr-D-inv-line-0
    :
      assign
        v-diasize-orig-frame-height = frame fr-D-inv-line-0 :height
        v-diasize-orig-frame-width  = frame fr-D-inv-line-0 :width
        v-diasize-browse-handle     = browse br-inv-lines :handle
      .
      create button v-diasize-resize-button
      assign
        parent        = frame fr-D-inv-line-0 :first-child
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
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEF VAR cur-clmn-numbr-inv-lines as INT EXTENT 25 no-undo.
DEF VAR varmvibr-inv-lines       as INT no-undo.
DEF VAR varmvjbr-inv-lines       as INT no-undo.
DEF VAR varmvkbr-inv-lines       as INT no-undo.
DEF VAR varmvlbr-inv-lines       as INT no-undo.
DEF VAR move-elementbr-inv-lines as INT no-undo.
def var jjbr-inv-lines           as int no-undo.
do varmvibr-inv-lines = 1 to EXTENT(cur-clmn-numbr-inv-lines):
  ASSIGN cur-clmn-numbr-inv-lines[varmvibr-inv-lines] = varmvibr-inv-lines.
END.
RUN start-mv-clmnbr-inv-lines.
PROCEDURE start-mv-clmnbr-inv-lines:
def var old-session as logical no-undo.
   old-session = SESSION:IMMEDIATE-DISPLAY.
   IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
   SESSION:IMMEDIATE-DISPLAY = old-session.
END.
ON ctrl-cursor-right OF BROWSE br-inv-lines do:
  RUN re-move-clmnbr-inv-lines ( 2, 25).
END.
ON ctrl-cursor-left OF BROWSE br-inv-lines do:
  RUN re-move-clmnbr-inv-lines (25, 2).
END.
PROCEDURE re-move-clmnbr-inv-lines:
  DEFINE INPUT PARAMETER source-column as INTEGER NO-UNDO.
  DEFINE INPUT PARAMETER target-column as INTEGER NO-UNDO.
  DO varmvibr-inv-lines = 1 TO EXTENT(cur-clmn-numbr-inv-lines):
    if cur-clmn-numbr-inv-lines[varmvibr-inv-lines] = source-column THEN cur-clmn-numbr-inv-lines[varmvibr-inv-lines] = -1.
  END.
  if br-inv-lines:MOVE-COLUMN(source-column, target-column) IN FRAME fr-D-inv-line-0 then.
  if source-column > target-column THEN
  DO varmvjbr-inv-lines = source-column - 1 to target-column BY -1:
    DO varmvibr-inv-lines = 1 TO EXTENT(cur-clmn-numbr-inv-lines):
        if cur-clmn-numbr-inv-lines[varmvibr-inv-lines] = varmvjbr-inv-lines THEN DO:
          cur-clmn-numbr-inv-lines[varmvibr-inv-lines] = cur-clmn-numbr-inv-lines[varmvibr-inv-lines] + 1.
        END.
    END.
  END.
  ELSE
  DO varmvjbr-inv-lines = source-column + 1 to target-column:
    DO varmvibr-inv-lines = 1 TO EXTENT(cur-clmn-numbr-inv-lines):
      if cur-clmn-numbr-inv-lines[varmvibr-inv-lines] = varmvjbr-inv-lines THEN DO:
        cur-clmn-numbr-inv-lines[varmvibr-inv-lines] = cur-clmn-numbr-inv-lines[varmvibr-inv-lines] - 1.
      END.
    END.
  END.
  DO varmvibr-inv-lines = 1 TO EXTENT(cur-clmn-numbr-inv-lines):
    if cur-clmn-numbr-inv-lines[varmvibr-inv-lines] = -1 THEN cur-clmn-numbr-inv-lines[varmvibr-inv-lines] = target-column.
  END.
END PROCEDURE.
PROCEDURE ch-clmnbr-inv-lines:
  DEFINE INPUT PARAMETER cur-clmn-loc as INTEGER NO-UNDO.
  if cur-clmn-loc <= 2 then do:
    return .
  end.
  DO varmvibr-inv-lines = 1 TO EXTENT(cur-clmn-numbr-inv-lines):
    if cur-clmn-numbr-inv-lines[varmvibr-inv-lines] = cur-clmn-loc THEN move-elementbr-inv-lines = varmvibr-inv-lines.
  END.
  RUN re-move-clmnbr-inv-lines (cur-clmn-loc, 2).
END PROCEDURE.
PROCEDURE mv-brw-defaultbr-inv-lines:
def var old-session as logical no-undo.
  old-session = SESSION:IMMEDIATE-DISPLAY.
  IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
  do varmvlbr-inv-lines = 2 to EXTENT(cur-clmn-numbr-inv-lines):
    RUN re-move-clmnbr-inv-lines (cur-clmn-numbr-inv-lines[varmvlbr-inv-lines], varmvlbr-inv-lines).
  END.
  RUN start-mv-clmnbr-inv-lines.
  SESSION:IMMEDIATE-DISPLAY = old-session.
END PROCEDURE.
.
def var sort-labelbr-inv-lines   as character no-undo .
def var sort-clmnbr-inv-lines    as handle    no-undo .
def var cur-clmnbr-inv-lines     as handle    no-undo .
def var cur-clmn-locbr-inv-lines as integer   no-undo .
def var re-querybr-inv-lines     as logical   initial no no-undo .
on start-search, ctrl-o of br-inv-lines in frame fr-D-inv-line-0 do:
   run sort-brbr-inv-lines
     (input (if available buf_history
             then recid(buf_history)
             else ?
            )
     ).
end.
PROCEDURE sort-brbr-inv-lines :
  define input parameter p-recid as recid no-undo .
  if re-querybr-inv-lines = no then do:
    assign
       cur-clmnbr-inv-lines = br-inv-lines:current-column in frame fr-D-inv-line-0
    .
    if sort-clmnbr-inv-lines <> ? then sort-clmnbr-inv-lines:column-fgcolor = 0.
    if cur-clmnbr-inv-lines = sort-clmnbr-inv-lines then do:
      assign
         sort-labelbr-inv-lines = ""
         sort-clmnbr-inv-lines = ?
      .
     end.
     else do:
       assign
         sort-labelbr-inv-lines = cur-clmnbr-inv-lines:label
         sort-clmnbr-inv-lines  = cur-clmnbr-inv-lines
         sort-clmnbr-inv-lines:column-fgcolor = 4
       .
     end.
   end.
  assign
    cur-clmn-locbr-inv-lines = 1
  .
  def var column-handle as handle no-undo .
  column-handle = br-inv-lines:first-column.
  do while valid-handle(column-handle) :
    if column-handle = cur-clmnbr-inv-lines then do:
      leave .
    end.
    column-handle = column-handle:NEXT-COLUMN.
    assign
      cur-clmn-locbr-inv-lines = cur-clmn-locbr-inv-lines + 1
    .
  end.
  case sort-labelbr-inv-lines:
        when '*'  then DO:    assign       sort-column-name = "mark-string( buffer buf_history )"     .     run OpenBr in this-procedure ( input yes, input no, input '':U ).   . END.
        when 'Номер документа'  then DO:    assign       sort-column-name = "buf_history.doc-code"     .     run OpenBr in this-procedure ( input yes, input no, input '':U ).   . END.
        when 'Артикул'  then DO:    assign       sort-column-name = "buf_history.artic"     .     run OpenBr in this-procedure ( input yes, input no, input '':U ).   . END.
        when 'Производитель'  then DO:   assign       sort-column-name = substitute('dynamic-function(&1obj-short&1, &1&2&1, &1&3&1)', chr(34), buf_history.prod-type, buf_history.prod-code )     .     run OpenBr in this-procedure ( input yes, input no, input '':U ).   . END.
        when 'Факт кол-во, кг'  then DO:    assign       sort-column-name = "buf_history.wast-cli-qnty"     .     run OpenBr in this-procedure ( input yes, input no, input '':U ).   . END.
        when 'Итого стало, кг'  then DO:    assign       sort-column-name = "buf_history.after-cli-qnty"     .     run OpenBr in this-procedure ( input yes, input no, input '':U ).   . END.
        when 'Цена продаж / кг (руб.)'  then DO:    assign       sort-column-name = "buf_history.wast-rubl"     .     run OpenBr in this-procedure ( input yes, input no, input '':U ).   . END.
        when 'Учет. цена / кг (руб.)'  then DO:    assign       sort-column-name = "buf_history.unus-wast-rubl"     .     run OpenBr in this-procedure ( input yes, input no, input '':U ).   . END.
        when 'Цена продаж / кг (б.в.)'  then DO:    assign       sort-column-name = "buf_history.wast-base"     .     run OpenBr in this-procedure ( input yes, input no, input '':U ).   . END.
        when 'Учет. цена / кг (б.в.)'  then DO:    assign       sort-column-name = "buf_history.unus-wast-base"     .     run OpenBr in this-procedure ( input yes, input no, input '':U ).   . END.
        when 'Плотность'  then DO:    assign       sort-column-name = "buf_history.density"     .     run OpenBr in this-procedure ( input yes, input no, input '':U ).   . END.
        when 'Кол-во до (инв.), кг'  then DO:    assign       sort-column-name = "buf_history.before-cli-qnty"     .     run OpenBr in this-procedure ( input yes, input no, input '':U ).   . END.
        when 'Название производителя'  then DO:   assign       sort-column-name = substitute('dynamic-function(&1obj-name&1, &1&2&1, &1&3&1)', chr(34), buf_history.prod-type, buf_history.prod-code )     .     run OpenBr in this-procedure ( input yes, input no, input '':U ).   . END.
        when 'Название товара'  then DO:   assign       sort-column-name = substitute('dynamic-function(&1gds-name&1, &1&2&1, &1&3&1, &1&4&1)', chr(34), buf_history.artic, buf_history.prod-type, buf_history.prod-code )     .     run OpenBr in this-procedure ( input yes, input no, input '':U ).   . END.
        when 'Код фирмы'  then DO:    assign       sort-column-name = "buf_history.host-code"     .     run OpenBr in this-procedure ( input yes, input no, input '':U ).   . END.
        when 'Расширенный тип документа'  then DO:   assign       sort-column-name = substitute('dynamic-function(&1ext-type&1, &1&2&1)', chr(34), buf_history.ext-doc-type )     .     run OpenBr in this-procedure ( input yes, input no, input '':U ).   . END.
        when 'Факт ордер'  then DO:    assign       sort-column-name = "buf_history.fact-order"     .     run OpenBr in this-procedure ( input yes, input no, input '':U ).   . END.
        when 'Статус'  then DO:    assign       sort-column-name = "buf_history.status_"     .     run OpenBr in this-procedure ( input yes, input no, input '':U ).   . END.
        when 'Объект'  then DO:   assign       sort-column-name = substitute('dynamic-function(&1obj-short&1, &1&2&1, &1&3&1)', chr(34), buf_history.obj-type, buf_history.obj-code )     .     run OpenBr in this-procedure ( input yes, input no, input '':U ).   . END.
        when 'Наименование объекта'  then DO:   assign       sort-column-name = substitute('dynamic-function(&1obj-name&1, &1&2&1, &1&3&1)', chr(34), buf_history.obj-type, buf_history.obj-code )     .     run OpenBr in this-procedure ( input yes, input no, input '':U ).   . END.
        when 'Изменил'  then DO:    assign       sort-column-name = "buf_history.corr-user-name"     .     run OpenBr in this-procedure ( input yes, input no, input '':U ).   . END.
        when 'Действие'  then DO:   assign       sort-column-name = substitute('dynamic-function(&1ShowAction&1, &1&2&1)', chr(34), buf_history.action )     .     run OpenBr in this-procedure ( input yes, input no, input '':U ).   . END.
        when 'Дата корр.'  then DO:    assign       sort-column-name = "buf_history.corr-date"     .     run OpenBr in this-procedure ( input yes, input no, input '':U ).   . END.
        when 'Время'  then DO:    assign       sort-column-name = "STRING( buf_history.corr-time, 'HH:MM:SS':U )"     .     run OpenBr in this-procedure ( input yes, input no, input '':U ).   . END.
        when 'Щепка'  then DO:    assign       sort-column-name = "buf_history.chip-num"     .     run OpenBr in this-procedure ( input yes, input no, input '':U ).   . END.
    otherwise do:
      assign
        sort-column-name = ""
      .
      run OpenBr in this-procedure ( input yes, input no, input '':U ).
        if can-do( this-procedure:internal-entries, 'mv-brw-defaultbr-inv-lines') then do:
          run mv-brw-defaultbr-inv-lines.
        end.
      if sort-labelbr-inv-lines <> "" then do:
        assign
          cur-clmnbr-inv-lines:column-fgcolor = 0
        .
      end.
      assign
        cur-clmn-locbr-inv-lines = ?
      .
    end.
  end case.
  if p-recid <> ? then do:
    reposition br-inv-lines to recid p-recid no-error.
    apply "value-changed" to br-inv-lines in frame fr-D-inv-line-0.
  end.
  apply "entry" to br-inv-lines in frame fr-D-inv-line-0.
END PROCEDURE.
procedure re-open-query-srt-clmnbr-inv-lines:
if cur-clmnbr-inv-lines = ? then do:
   run OpenBr in this-procedure ( input yes, input no, input '':U ).
end.
else do:
   assign re-querybr-inv-lines = yes.
   run sort-brbr-inv-lines
     (input (if available buf_history
             then recid(buf_history)
             else ?
            )
     ).
   assign re-querybr-inv-lines = no.
end.
end.
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEF VAR cur-clmn-numbr-changes as INT EXTENT 3 no-undo.
DEF VAR varmvibr-changes       as INT no-undo.
DEF VAR varmvjbr-changes       as INT no-undo.
DEF VAR varmvkbr-changes       as INT no-undo.
DEF VAR varmvlbr-changes       as INT no-undo.
DEF VAR move-elementbr-changes as INT no-undo.
def var jjbr-changes           as int no-undo.
do varmvibr-changes = 1 to EXTENT(cur-clmn-numbr-changes):
  ASSIGN cur-clmn-numbr-changes[varmvibr-changes] = varmvibr-changes.
END.
RUN start-mv-clmnbr-changes.
PROCEDURE start-mv-clmnbr-changes:
def var old-session as logical no-undo.
   old-session = SESSION:IMMEDIATE-DISPLAY.
   IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
   SESSION:IMMEDIATE-DISPLAY = old-session.
END.
ON ctrl-cursor-right OF BROWSE br-changes do:
  RUN re-move-clmnbr-changes ( 1, 3).
END.
ON ctrl-cursor-left OF BROWSE br-changes do:
  RUN re-move-clmnbr-changes (3, 1).
END.
PROCEDURE re-move-clmnbr-changes:
  DEFINE INPUT PARAMETER source-column as INTEGER NO-UNDO.
  DEFINE INPUT PARAMETER target-column as INTEGER NO-UNDO.
  DO varmvibr-changes = 1 TO EXTENT(cur-clmn-numbr-changes):
    if cur-clmn-numbr-changes[varmvibr-changes] = source-column THEN cur-clmn-numbr-changes[varmvibr-changes] = -1.
  END.
  if br-changes:MOVE-COLUMN(source-column, target-column) IN FRAME fr-D-inv-line-0 then.
  if source-column > target-column THEN
  DO varmvjbr-changes = source-column - 1 to target-column BY -1:
    DO varmvibr-changes = 1 TO EXTENT(cur-clmn-numbr-changes):
        if cur-clmn-numbr-changes[varmvibr-changes] = varmvjbr-changes THEN DO:
          cur-clmn-numbr-changes[varmvibr-changes] = cur-clmn-numbr-changes[varmvibr-changes] + 1.
        END.
    END.
  END.
  ELSE
  DO varmvjbr-changes = source-column + 1 to target-column:
    DO varmvibr-changes = 1 TO EXTENT(cur-clmn-numbr-changes):
      if cur-clmn-numbr-changes[varmvibr-changes] = varmvjbr-changes THEN DO:
        cur-clmn-numbr-changes[varmvibr-changes] = cur-clmn-numbr-changes[varmvibr-changes] - 1.
      END.
    END.
  END.
  DO varmvibr-changes = 1 TO EXTENT(cur-clmn-numbr-changes):
    if cur-clmn-numbr-changes[varmvibr-changes] = -1 THEN cur-clmn-numbr-changes[varmvibr-changes] = target-column.
  END.
END PROCEDURE.
PROCEDURE ch-clmnbr-changes:
  DEFINE INPUT PARAMETER cur-clmn-loc as INTEGER NO-UNDO.
  if cur-clmn-loc <= 1 then do:
    return .
  end.
  DO varmvibr-changes = 1 TO EXTENT(cur-clmn-numbr-changes):
    if cur-clmn-numbr-changes[varmvibr-changes] = cur-clmn-loc THEN move-elementbr-changes = varmvibr-changes.
  END.
  RUN re-move-clmnbr-changes (cur-clmn-loc, 1).
END PROCEDURE.
PROCEDURE mv-brw-defaultbr-changes:
def var old-session as logical no-undo.
  old-session = SESSION:IMMEDIATE-DISPLAY.
  IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
  do varmvlbr-changes = 1 to EXTENT(cur-clmn-numbr-changes):
    RUN re-move-clmnbr-changes (cur-clmn-numbr-changes[varmvlbr-changes], varmvlbr-changes).
  END.
  RUN start-mv-clmnbr-changes.
  SESSION:IMMEDIATE-DISPLAY = old-session.
END PROCEDURE.
.
def var sort-labelbr-changes   as character no-undo .
def var sort-clmnbr-changes    as handle    no-undo .
def var cur-clmnbr-changes     as handle    no-undo .
def var cur-clmn-locbr-changes as integer   no-undo .
def var re-querybr-changes     as logical   initial no no-undo .
on start-search, ctrl-o of br-changes in frame fr-D-inv-line-0 do:
   run sort-brbr-changes
     (input (if available buf_changes
             then recid(buf_changes)
             else ?
            )
     ).
end.
PROCEDURE sort-brbr-changes :
  define input parameter p-recid as recid no-undo .
  if re-querybr-changes = no then do:
    assign
       cur-clmnbr-changes = br-changes:current-column in frame fr-D-inv-line-0
    .
    if sort-clmnbr-changes <> ? then sort-clmnbr-changes:column-fgcolor = 0.
    if cur-clmnbr-changes = sort-clmnbr-changes then do:
      assign
         sort-labelbr-changes = ""
         sort-clmnbr-changes = ?
      .
     end.
     else do:
       assign
         sort-labelbr-changes = cur-clmnbr-changes:label
         sort-clmnbr-changes  = cur-clmnbr-changes
         sort-clmnbr-changes:column-fgcolor = 4
       .
     end.
   end.
  assign
    cur-clmn-locbr-changes = 1
  .
  def var column-handle as handle no-undo .
  column-handle = br-changes:first-column.
  do while valid-handle(column-handle) :
    if column-handle = cur-clmnbr-changes then do:
      leave .
    end.
    column-handle = column-handle:NEXT-COLUMN.
    assign
      cur-clmn-locbr-changes = cur-clmn-locbr-changes + 1
    .
  end.
  case sort-labelbr-changes:
        when 'Изменилось'  then DO:    assign       sort-change-name = "buf_changes.l_name"     .     run OpenChanges in this-procedure ( input yes, input no, input '':U ).   . END.
        when 'Было'  then DO:    assign       sort-change-name = "buf_changes.v_old"     .     run OpenChanges in this-procedure ( input yes, input no, input '':U ).   . END.
        when 'Стало'  then DO:    assign       sort-change-name = "buf_changes.v_new"     .     run OpenChanges in this-procedure ( input yes, input no, input '':U ).   . END.
    otherwise do:
      assign
        sort-change-name = ""
      .
      run OpenChanges in this-procedure ( input yes, input no, input '':U ).
        if can-do( this-procedure:internal-entries, 'mv-brw-defaultbr-changes') then do:
          run mv-brw-defaultbr-changes.
        end.
      if sort-labelbr-changes <> "" then do:
        assign
          cur-clmnbr-changes:column-fgcolor = 0
        .
      end.
      assign
        cur-clmn-locbr-changes = ?
      .
    end.
  end case.
  if p-recid <> ? then do:
    reposition br-changes to recid p-recid no-error.
    apply "value-changed" to br-changes in frame fr-D-inv-line-0.
  end.
  apply "entry" to br-changes in frame fr-D-inv-line-0.
END PROCEDURE.
procedure re-open-query-srt-clmnbr-changes:
if cur-clmnbr-changes = ? then do:
   run OpenChanges in this-procedure ( input yes, input no, input '':U ).
end.
else do:
   assign re-querybr-changes = yes.
   run sort-brbr-changes
     (input (if available buf_changes
             then recid(buf_changes)
             else ?
            )
     ).
   assign re-querybr-changes = no.
end.
end.
Main-Block:
do on error   undo Main-Block, leave Main-Block
   on end-key undo Main-Block, leave Main-Block :
   p-host-code = v-cntxt-host-code-obj.
  if lookup( p-mode, 'все,obj,doc,gds,one':U ) = 0 then do:
    message vss-workfile skip vss-revision skip vss-date skip( 1 ) vss-description skip( 1 )
            "Неверное значение параметра вызова p-mode:" p-mode
    view-as alert-box error.
  end.
  if p-mode = 'obj':U or
     p-mode = 'gds':U then do:
    find first buf_sch_hist no-lock where
               buf_sch_hist.obj-type = p-obj-type and
               buf_sch_hist.obj-code = p-obj-code no-error.
    if not available buf_sch_hist then do:
      message
              'Нет истории по - '
              '"' + p-obj-type + '"' p-obj-code '.'
      view-as alert-box information.
    end.
  end.
  if p-mode = 'doc':U then do:
    find first buf_sch_hist no-lock where buf_sch_hist.doc-code = p-doc-code no-error.
    if not available buf_sch_hist then do:
      message
              'Нет истории по' p-doc-code
      view-as alert-box information.
    end.
  end.
  if p-mode = 'gds':U then do:
    find first buf_sch_hist no-lock where
               buf_sch_hist.obj-type  = p-obj-type  and
               buf_sch_hist.obj-code  = p-obj-code  and
               buf_sch_hist.artic     = p-artic     and
               buf_sch_hist.prod-type = p-prod-type and
               buf_sch_hist.prod-code = p-prod-code no-error.
    if not available buf_sch_hist then do:
      message
              'Нет истории по:'
              p-artic ', ' p-prod-type ' и ' p-prod-code '.'
      view-as alert-box information.
    end.
  end.
  if p-mode = 'one':U then do:
    find first buf_sch_hist no-lock where
               buf_sch_hist.doc-code  = p-doc-code  and
               buf_sch_hist.artic     = p-artic     and
               buf_sch_hist.prod-type = p-prod-type and
               buf_sch_hist.prod-code = p-prod-code no-error.
    if not available buf_sch_hist then do:
      message
              'Нет истории по :'
              p-artic ', ' p-prod-type ' и ' p-prod-code '.'
      view-as alert-box information .
    end.
  end.
  if p-rid-list <> "":U then do:
    find first buf_sch_hist no-lock where recid( buf_sch_hist ) = integer( entry( 1, p-rid-list ) ) no-error.
    if not available buf_sch_hist then do:
    end.
    else do:
      assign doc-rec = recid( buf_sch_hist ).
    end.
  end.
  enable  b-mark   when lookup( "b-mark":U,   p-bttns ) > 0 or p-bttns = "*"
          b-sel when lookup( "b-sel":U, p-bttns ) > 0 or p-bttns = "*"
          b-sch b-help b-quit br-inv-lines br-changes sch-code
  with frame fr-D-inv-line-0.
  run OpenBr in this-procedure ( input yes, input no, input '':U ).
  hide mark-num in frame fr-D-inv-line-0.
  hide  sch-num in frame fr-D-inv-line-0.
  if p-rid-list <> "":U then do: reposition br-inv-lines to recid doc-rec no-error. end.
  br-inv-lines :set-repositioned-row( 5, "CONDITIONAL" ).
  wait-for go of frame fr-D-inv-line-0.
end.
hide frame fr-D-inv-line-0 no-pause.
procedure OpenBr :
  define input parameter p-open-query     as logical   no-undo.
  define input parameter p-find-next      as logical   no-undo.
  define input parameter p-find-condition as character no-undo.
  define variable l-query-was-opened as logical   no-undo.
  define variable title0             as character no-undo.
  define variable sort-column-phrase as character no-undo.
  define variable p-proc-hand as handle no-undo.
  run WaitFram-Show in this-procedure ( input "Ждите..." ).
  assign title0 = "История" + chr(32).
  assign p-proc-hand = this-procedure :handle.
  case sort-column-name :
    when "":U then do: assign sort-column-phrase = "":U. end.
    otherwise      do: assign sort-column-phrase = "by " + sort-column-name. end.
  end case.
  define variable l-open-query as logical no-undo.
  assign filter-point = filter-point0 + " - " + p-mode.
  case p-mode :
    when 'все':U  then do:
      assign frame fr-D-inv-line-0 :title = title0 + "топливных строк (весовой учет)".
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-19  as logical   no-undo .
define variable  l-filter-open-19    as logical   .
define variable  flt-rec-19       as recid     no-undo .
define variable  filter-name-19      as character no-undo .
define variable  where-phrase-19     as character no-undo .
define variable  sort-phrase-19      as character no-undo .
define variable  where-phrase-rus-19 as character no-undo .
define variable  sort-phrase-rus-19  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-19
  ,output filter-name-19
  ,output where-phrase-19
  ,output sort-phrase-19
  ,output where-phrase-rus-19
  ,output sort-phrase-rus-19
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-19
      ) no-error .
  assign
    l-filter-open-19 = false
  .
  if flt-rec-19 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-19 as character no-undo .
    define variable  parameter-3-19 as character no-undo .
    define variable  parameter-4-19 as character no-undo .
    define variable  parameter-5-19 as character no-undo .
    define variable  parameter-6-19 as character no-undo .
    define variable  parameter-7-19 as character no-undo .
      assign
      parameter-3-19 =
                              "for each buf_history"
      parameter-4-19 =
        (
          if (" yes " + " " + where-phrase-19) <> ""
          then  substitute('&1', yes) + " " + where-phrase-19
          else "true"
        )
      parameter-5-19 = (" " + "" + " " + "")
      parameter-6-19 = if sort-phrase-19 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-19
        )
      parameter-7-19 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-19 =
          (" yes " + " " + where-phrase-19 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-inv-lines:handle
                          ,input parameter-3-19
                          ,input parameter-4-19
                          ,input parameter-5-19
                          ,input parameter-6-19
                          ,input parameter-7-19
                          )
      .
      assign
        l-filter-open-19 = true
      .
    end.
    if l-filter-open-19 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
        assign
          l-query-was-opened = true
        .
    end.
  end.
  if l-filter-open-19 = false then do:
    open query br-inv-lines for each buf_history
      where  yes
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    doc-rec = recid( buf_history )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-inv-lines:handle:get-buffer-handle(1) = (buffer buf_history:handle) then do:
      assign
      parameter-2-19 = (if p-find-next then "true":u else "false":u )
      parameter-4-19 =
        "where ":u +  substitute('&1', yes) + " ":u + where-phrase-19 + " ":u + p-find-condition + " " + ""
      parameter-5-19 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-inv-lines:handle
                          ,input rowid(buf_history)
                          ,input logical(parameter-2-19)
                          ,input no-lock
                          ,input (buffer buf_history:handle)
                          ,input parameter-4-19
                          ,input parameter-5-19
                          ) no-error.
      .
      assign
        doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-19 = (if p-find-next then "true":u else "false":u )
      parameter-3-19 =  "for each buf_history"
      parameter-4-19 =
        (
          if (" yes " + " " + where-phrase-19) <> ""
          then  substitute('&1', yes) + " " + where-phrase-19
          else "true"
        )
      parameter-5-19 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-19 = if sort-phrase-19 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-19
        )
      parameter-7-19 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-inv-lines:handle
                          ,input logical(parameter-2-19)
                          ,input no-lock
                          ,input parameter-3-19
                          ,input parameter-4-19
                          ,input parameter-5-19
                          ,input parameter-6-19
                          ,input parameter-7-19
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
    end.
    when 'obj':U then do:
      find first buf_object no-lock where
                 buf_object.obj-type = p-obj-type and
                 buf_object.obj-code = p-obj-code no-error.
      assign frame fr-D-inv-line-0 :title = title0 +
        substitute( 'топливных строк (весовой учет) по объекту "&1"', trim( substring( buf_object.obj-name, 1, 40 ) ) ).
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-21  as logical   no-undo .
define variable  l-filter-open-21    as logical   .
define variable  flt-rec-21       as recid     no-undo .
define variable  filter-name-21      as character no-undo .
define variable  where-phrase-21     as character no-undo .
define variable  sort-phrase-21      as character no-undo .
define variable  where-phrase-rus-21 as character no-undo .
define variable  sort-phrase-rus-21  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-21
  ,output filter-name-21
  ,output where-phrase-21
  ,output sort-phrase-21
  ,output where-phrase-rus-21
  ,output sort-phrase-rus-21
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-21
      ) no-error .
  assign
    l-filter-open-21 = false
  .
  if flt-rec-21 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-21 as character no-undo .
    define variable  parameter-3-21 as character no-undo .
    define variable  parameter-4-21 as character no-undo .
    define variable  parameter-5-21 as character no-undo .
    define variable  parameter-6-21 as character no-undo .
    define variable  parameter-7-21 as character no-undo .
      assign
      parameter-3-21 =
                              "for each buf_history"
      parameter-4-21 =
        (
          if ("                           buf_history.obj-type = p-obj-type and                           buf_history.obj-code = p-obj-code                         " + " " + where-phrase-21) <> ""
          then  substitute('buf_history.obj-type = &1&2&1 and buf_history.obj-code = &3', chr(34), p-obj-type, p-obj-code ) + " " + where-phrase-21
          else "true"
        )
      parameter-5-21 = (" " + "" + " " + "")
      parameter-6-21 = if sort-phrase-21 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-21
        )
      parameter-7-21 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-21 =
          ("                           buf_history.obj-type = p-obj-type and                           buf_history.obj-code = p-obj-code                         " + " " + where-phrase-21 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-inv-lines:handle
                          ,input parameter-3-21
                          ,input parameter-4-21
                          ,input parameter-5-21
                          ,input parameter-6-21
                          ,input parameter-7-21
                          )
      .
      assign
        l-filter-open-21 = true
      .
    end.
    if l-filter-open-21 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
        assign
          l-query-was-opened = true
        .
    end.
  end.
  if l-filter-open-21 = false then do:
    open query br-inv-lines for each buf_history
      where                            buf_history.obj-type = p-obj-type and                           buf_history.obj-code = p-obj-code
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    doc-rec = recid( buf_history )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-inv-lines:handle:get-buffer-handle(1) = (buffer buf_history:handle) then do:
      assign
      parameter-2-21 = (if p-find-next then "true":u else "false":u )
      parameter-4-21 =
        "where ":u +  substitute('buf_history.obj-type = &1&2&1 and buf_history.obj-code = &3', chr(34), p-obj-type, p-obj-code ) + " ":u + where-phrase-21 + " ":u + p-find-condition + " " + ""
      parameter-5-21 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-inv-lines:handle
                          ,input rowid(buf_history)
                          ,input logical(parameter-2-21)
                          ,input no-lock
                          ,input (buffer buf_history:handle)
                          ,input parameter-4-21
                          ,input parameter-5-21
                          ) no-error.
      .
      assign
        doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-21 = (if p-find-next then "true":u else "false":u )
      parameter-3-21 =  "for each buf_history"
      parameter-4-21 =
        (
          if ("                           buf_history.obj-type = p-obj-type and                           buf_history.obj-code = p-obj-code                         " + " " + where-phrase-21) <> ""
          then  substitute('buf_history.obj-type = &1&2&1 and buf_history.obj-code = &3', chr(34), p-obj-type, p-obj-code ) + " " + where-phrase-21
          else "true"
        )
      parameter-5-21 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-21 = if sort-phrase-21 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-21
        )
      parameter-7-21 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-inv-lines:handle
                          ,input logical(parameter-2-21)
                          ,input no-lock
                          ,input parameter-3-21
                          ,input parameter-4-21
                          ,input parameter-5-21
                          ,input parameter-6-21
                          ,input parameter-7-21
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
    end.
    when 'doc':U then do:
      assign frame fr-D-inv-line-0 :title = title0 +
        substitute( 'топливных строк (весовой учет) по документу "&1"', p-doc-code ).
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-23  as logical   no-undo .
define variable  l-filter-open-23    as logical   .
define variable  flt-rec-23       as recid     no-undo .
define variable  filter-name-23      as character no-undo .
define variable  where-phrase-23     as character no-undo .
define variable  sort-phrase-23      as character no-undo .
define variable  where-phrase-rus-23 as character no-undo .
define variable  sort-phrase-rus-23  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-23
  ,output filter-name-23
  ,output where-phrase-23
  ,output sort-phrase-23
  ,output where-phrase-rus-23
  ,output sort-phrase-rus-23
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-23
      ) no-error .
  assign
    l-filter-open-23 = false
  .
  if flt-rec-23 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-23 as character no-undo .
    define variable  parameter-3-23 as character no-undo .
    define variable  parameter-4-23 as character no-undo .
    define variable  parameter-5-23 as character no-undo .
    define variable  parameter-6-23 as character no-undo .
    define variable  parameter-7-23 as character no-undo .
      assign
      parameter-3-23 =
                              "for each buf_history"
      parameter-4-23 =
        (
          if ("                           buf_history.doc-code = p-doc-code                         " + " " + where-phrase-23) <> ""
          then  substitute('buf_history.doc-code = &1&2&1', chr(34), p-doc-code ) + " " + where-phrase-23
          else "true"
        )
      parameter-5-23 = (" " + "" + " " + "")
      parameter-6-23 = if sort-phrase-23 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-23
        )
      parameter-7-23 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-23 =
          ("                           buf_history.doc-code = p-doc-code                         " + " " + where-phrase-23 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-inv-lines:handle
                          ,input parameter-3-23
                          ,input parameter-4-23
                          ,input parameter-5-23
                          ,input parameter-6-23
                          ,input parameter-7-23
                          )
      .
      assign
        l-filter-open-23 = true
      .
    end.
    if l-filter-open-23 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
        assign
          l-query-was-opened = true
        .
    end.
  end.
  if l-filter-open-23 = false then do:
    open query br-inv-lines for each buf_history
      where                            buf_history.doc-code = p-doc-code
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    doc-rec = recid( buf_history )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-inv-lines:handle:get-buffer-handle(1) = (buffer buf_history:handle) then do:
      assign
      parameter-2-23 = (if p-find-next then "true":u else "false":u )
      parameter-4-23 =
        "where ":u +  substitute('buf_history.doc-code = &1&2&1', chr(34), p-doc-code ) + " ":u + where-phrase-23 + " ":u + p-find-condition + " " + ""
      parameter-5-23 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-inv-lines:handle
                          ,input rowid(buf_history)
                          ,input logical(parameter-2-23)
                          ,input no-lock
                          ,input (buffer buf_history:handle)
                          ,input parameter-4-23
                          ,input parameter-5-23
                          ) no-error.
      .
      assign
        doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-23 = (if p-find-next then "true":u else "false":u )
      parameter-3-23 =  "for each buf_history"
      parameter-4-23 =
        (
          if ("                           buf_history.doc-code = p-doc-code                         " + " " + where-phrase-23) <> ""
          then  substitute('buf_history.doc-code = &1&2&1', chr(34), p-doc-code ) + " " + where-phrase-23
          else "true"
        )
      parameter-5-23 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-23 = if sort-phrase-23 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-23
        )
      parameter-7-23 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-inv-lines:handle
                          ,input logical(parameter-2-23)
                          ,input no-lock
                          ,input parameter-3-23
                          ,input parameter-4-23
                          ,input parameter-5-23
                          ,input parameter-6-23
                          ,input parameter-7-23
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
    end.
    when 'gds':U then do:
      find first buf_object no-lock where
                 buf_object.obj-type = p-obj-type and
                 buf_object.obj-code = p-obj-code no-error.
      assign frame fr-D-inv-line-0 :title = title0 +
        substitute( 'строк (весовой учет) топлива &1 (&2 &3) по объекту "&4"',
                    p-artic, p-prod-type, p-prod-code, trim( substring( buf_object.obj-name, 1, 30 ) ) ).
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-25  as logical   no-undo .
define variable  l-filter-open-25    as logical   .
define variable  flt-rec-25       as recid     no-undo .
define variable  filter-name-25      as character no-undo .
define variable  where-phrase-25     as character no-undo .
define variable  sort-phrase-25      as character no-undo .
define variable  where-phrase-rus-25 as character no-undo .
define variable  sort-phrase-rus-25  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-25
  ,output filter-name-25
  ,output where-phrase-25
  ,output sort-phrase-25
  ,output where-phrase-rus-25
  ,output sort-phrase-rus-25
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-25
      ) no-error .
  assign
    l-filter-open-25 = false
  .
  if flt-rec-25 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-25 as character no-undo .
    define variable  parameter-3-25 as character no-undo .
    define variable  parameter-4-25 as character no-undo .
    define variable  parameter-5-25 as character no-undo .
    define variable  parameter-6-25 as character no-undo .
    define variable  parameter-7-25 as character no-undo .
      assign
      parameter-3-25 =
                              "for each buf_history"
      parameter-4-25 =
        (
          if ("                           buf_history.obj-type  = p-obj-type  and                           buf_history.obj-code  = p-obj-code  and                           buf_history.artic     = p-artic     and                           buf_history.prod-type = p-prod-type and                           buf_history.prod-code = p-prod-code                         " + " " + where-phrase-25) <> ""
          then  substitute('                          buf_history.obj-type  = &1&2&1  and                           buf_history.obj-code  = &3  and                           buf_history.artic     = &1&4&1  and                           buf_history.prod-type = &1&5&1  and                           buf_history.prod-code = &6'                           , chr(34), p-obj-type, p-obj-code, p-artic, p-prod-type, p-prod-code ) + " " + where-phrase-25
          else "true"
        )
      parameter-5-25 = (" " + "" + " " + "")
      parameter-6-25 = if sort-phrase-25 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-25
        )
      parameter-7-25 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-25 =
          ("                           buf_history.obj-type  = p-obj-type  and                           buf_history.obj-code  = p-obj-code  and                           buf_history.artic     = p-artic     and                           buf_history.prod-type = p-prod-type and                           buf_history.prod-code = p-prod-code                         " + " " + where-phrase-25 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-inv-lines:handle
                          ,input parameter-3-25
                          ,input parameter-4-25
                          ,input parameter-5-25
                          ,input parameter-6-25
                          ,input parameter-7-25
                          )
      .
      assign
        l-filter-open-25 = true
      .
    end.
    if l-filter-open-25 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
        assign
          l-query-was-opened = true
        .
    end.
  end.
  if l-filter-open-25 = false then do:
    open query br-inv-lines for each buf_history
      where                            buf_history.obj-type  = p-obj-type  and                           buf_history.obj-code  = p-obj-code  and                           buf_history.artic     = p-artic     and                           buf_history.prod-type = p-prod-type and                           buf_history.prod-code = p-prod-code
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    doc-rec = recid( buf_history )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-inv-lines:handle:get-buffer-handle(1) = (buffer buf_history:handle) then do:
      assign
      parameter-2-25 = (if p-find-next then "true":u else "false":u )
      parameter-4-25 =
        "where ":u +  substitute('                          buf_history.obj-type  = &1&2&1  and                           buf_history.obj-code  = &3  and                           buf_history.artic     = &1&4&1  and                           buf_history.prod-type = &1&5&1  and                           buf_history.prod-code = &6'                           , chr(34), p-obj-type, p-obj-code, p-artic, p-prod-type, p-prod-code ) + " ":u + where-phrase-25 + " ":u + p-find-condition + " " + ""
      parameter-5-25 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-inv-lines:handle
                          ,input rowid(buf_history)
                          ,input logical(parameter-2-25)
                          ,input no-lock
                          ,input (buffer buf_history:handle)
                          ,input parameter-4-25
                          ,input parameter-5-25
                          ) no-error.
      .
      assign
        doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-25 = (if p-find-next then "true":u else "false":u )
      parameter-3-25 =  "for each buf_history"
      parameter-4-25 =
        (
          if ("                           buf_history.obj-type  = p-obj-type  and                           buf_history.obj-code  = p-obj-code  and                           buf_history.artic     = p-artic     and                           buf_history.prod-type = p-prod-type and                           buf_history.prod-code = p-prod-code                         " + " " + where-phrase-25) <> ""
          then  substitute('                          buf_history.obj-type  = &1&2&1  and                           buf_history.obj-code  = &3  and                           buf_history.artic     = &1&4&1  and                           buf_history.prod-type = &1&5&1  and                           buf_history.prod-code = &6'                           , chr(34), p-obj-type, p-obj-code, p-artic, p-prod-type, p-prod-code ) + " " + where-phrase-25
          else "true"
        )
      parameter-5-25 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-25 = if sort-phrase-25 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-25
        )
      parameter-7-25 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-inv-lines:handle
                          ,input logical(parameter-2-25)
                          ,input no-lock
                          ,input parameter-3-25
                          ,input parameter-4-25
                          ,input parameter-5-25
                          ,input parameter-6-25
                          ,input parameter-7-25
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
    end.
    when 'one':U then do:
      assign frame fr-D-inv-line-0 :title = title0 +
        substitute( 'строки (весовой учет) топлива &1 (&2 &3) по документу "&4"',
                    p-artic, p-prod-type, p-prod-code, p-doc-code ).
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-27  as logical   no-undo .
define variable  l-filter-open-27    as logical   .
define variable  flt-rec-27       as recid     no-undo .
define variable  filter-name-27      as character no-undo .
define variable  where-phrase-27     as character no-undo .
define variable  sort-phrase-27      as character no-undo .
define variable  where-phrase-rus-27 as character no-undo .
define variable  sort-phrase-rus-27  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-27
  ,output filter-name-27
  ,output where-phrase-27
  ,output sort-phrase-27
  ,output where-phrase-rus-27
  ,output sort-phrase-rus-27
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-27
      ) no-error .
  assign
    l-filter-open-27 = false
  .
  if flt-rec-27 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-27 as character no-undo .
    define variable  parameter-3-27 as character no-undo .
    define variable  parameter-4-27 as character no-undo .
    define variable  parameter-5-27 as character no-undo .
    define variable  parameter-6-27 as character no-undo .
    define variable  parameter-7-27 as character no-undo .
      assign
      parameter-3-27 =
                              "for each buf_history"
      parameter-4-27 =
        (
          if ("                           buf_history.doc-code  = p-doc-code  and                           buf_history.artic     = p-artic     and                           buf_history.prod-type = p-prod-type and                           buf_history.prod-code = p-prod-code                         " + " " + where-phrase-27) <> ""
          then  substitute('                          buf_history.doc-code  = &1&2&1 and                           buf_history.artic     = &1&3&1 and                           buf_history.prod-type = &1&4&1 and                           buf_history.prod-code = &5'                           , chr(34), p-doc-code, p-artic, p-prod-type, p-prod-code)  + " " + where-phrase-27
          else "true"
        )
      parameter-5-27 = (" " + "" + " " + "")
      parameter-6-27 = if sort-phrase-27 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-27
        )
      parameter-7-27 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-27 =
          ("                           buf_history.doc-code  = p-doc-code  and                           buf_history.artic     = p-artic     and                           buf_history.prod-type = p-prod-type and                           buf_history.prod-code = p-prod-code                         " + " " + where-phrase-27 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-inv-lines:handle
                          ,input parameter-3-27
                          ,input parameter-4-27
                          ,input parameter-5-27
                          ,input parameter-6-27
                          ,input parameter-7-27
                          )
      .
      assign
        l-filter-open-27 = true
      .
    end.
    if l-filter-open-27 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
        assign
          l-query-was-opened = true
        .
    end.
  end.
  if l-filter-open-27 = false then do:
    open query br-inv-lines for each buf_history
      where                            buf_history.doc-code  = p-doc-code  and                           buf_history.artic     = p-artic     and                           buf_history.prod-type = p-prod-type and                           buf_history.prod-code = p-prod-code
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    doc-rec = recid( buf_history )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-inv-lines:handle:get-buffer-handle(1) = (buffer buf_history:handle) then do:
      assign
      parameter-2-27 = (if p-find-next then "true":u else "false":u )
      parameter-4-27 =
        "where ":u +  substitute('                          buf_history.doc-code  = &1&2&1 and                           buf_history.artic     = &1&3&1 and                           buf_history.prod-type = &1&4&1 and                           buf_history.prod-code = &5'                           , chr(34), p-doc-code, p-artic, p-prod-type, p-prod-code)  + " ":u + where-phrase-27 + " ":u + p-find-condition + " " + ""
      parameter-5-27 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-inv-lines:handle
                          ,input rowid(buf_history)
                          ,input logical(parameter-2-27)
                          ,input no-lock
                          ,input (buffer buf_history:handle)
                          ,input parameter-4-27
                          ,input parameter-5-27
                          ) no-error.
      .
      assign
        doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-27 = (if p-find-next then "true":u else "false":u )
      parameter-3-27 =  "for each buf_history"
      parameter-4-27 =
        (
          if ("                           buf_history.doc-code  = p-doc-code  and                           buf_history.artic     = p-artic     and                           buf_history.prod-type = p-prod-type and                           buf_history.prod-code = p-prod-code                         " + " " + where-phrase-27) <> ""
          then  substitute('                          buf_history.doc-code  = &1&2&1 and                           buf_history.artic     = &1&3&1 and                           buf_history.prod-type = &1&4&1 and                           buf_history.prod-code = &5'                           , chr(34), p-doc-code, p-artic, p-prod-type, p-prod-code)  + " " + where-phrase-27
          else "true"
        )
      parameter-5-27 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-27 = if sort-phrase-27 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-27
        )
      parameter-7-27 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-inv-lines:handle
                          ,input logical(parameter-2-27)
                          ,input no-lock
                          ,input parameter-3-27
                          ,input parameter-4-27
                          ,input parameter-5-27
                          ,input parameter-6-27
                          ,input parameter-7-27
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
    end.
  end case.
  if p-open-query <> yes then do: reposition br-inv-lines to recid doc-rec no-error. end.
  run WaitFram-Hide in this-procedure.
  apply "VALUE-CHANGED":U to br-inv-lines in frame fr-D-inv-line-0.
  apply "ENTRY":U         to br-inv-lines in frame fr-D-inv-line-0.
end procedure.
procedure proc-filter :
  assign tbl      = 'c-inv-line'
         join-tbl = 'buf_history'
         fld      = '':U
         lab      = '':U
         spr      = '':U
         dim      = '0'.
  run fltfield-add in this-procedure ( input 'doc-code',         input 'Номер документа',                 input '':U,    input-output fld, input-output lab, input-output spr, input-output dim ) no-error.
  run fltfield-add in this-procedure ( input 'artic',            input 'Артикул',                         input '':U,    input-output fld, input-output lab, input-output spr, input-output dim ) no-error.
  run fltfield-add in this-procedure ( input 'prod-type',        input 'Тип производителя',               input '':U,    input-output fld, input-output lab, input-output spr, input-output dim ) no-error.
  run fltfield-add in this-procedure ( input 'prod-code',        input 'Код производителя',               input '':U,    input-output fld, input-output lab, input-output spr, input-output dim ) no-error.
  run fltfield-add in this-procedure ( input 'prod-type*prod-code',           input 'Производитель',                   input 'cli':U, input-output fld, input-output lab, input-output spr, input-output dim ) no-error.
  run fltfield-add in this-procedure ( input 'wast-cli-qnty',    input 'Факт количество',                 input '':U,    input-output fld, input-output lab, input-output spr, input-output dim ) no-error.
  run fltfield-add in this-procedure ( input 'wast-rubl',        input 'Цена продаж / кг (руб.)', input '':U,    input-output fld, input-output lab, input-output spr, input-output dim ) no-error.
  run fltfield-add in this-procedure ( input 'unus-wast-rubl',   input 'Учет. цена / кг (руб.)',  input '':U,    input-output fld, input-output lab, input-output spr, input-output dim ) no-error.
  run fltfield-add in this-procedure ( input 'wast-base',        input 'Цена продаж / кг (б.в.)',         input '':U,    input-output fld, input-output lab, input-output spr, input-output dim ) no-error.
  run fltfield-add in this-procedure ( input 'unus-wast-base',   input 'Учет. цена / кг (б.в.)',          input '':U,    input-output fld, input-output lab, input-output spr, input-output dim ) no-error.
  run fltfield-add in this-procedure ( input 'after-cli-qnty',   input 'Итого стало / кг',                input '':U,    input-output fld, input-output lab, input-output spr, input-output dim ) no-error.
  run fltfield-add in this-procedure ( input 'before-cli-qnty',  input 'Количество до инвентаризации',    input '':U,    input-output fld, input-output lab, input-output spr, input-output dim ) no-error.
  run fltfield-add in this-procedure ( input 'density',          input 'Плотность',                       input '':U,    input-output fld, input-output lab, input-output spr, input-output dim ) no-error.
  run fltfield-add in this-procedure ( input 'host-code',        input 'Код фирмы',                       input '':U,    input-output fld, input-output lab, input-output spr, input-output dim ) no-error.
  run fltfield-add in this-procedure ( input 'ext-doc-type',     input 'Расширенный тип документа',       input '':U,    input-output fld, input-output lab, input-output spr, input-output dim ) no-error.
  run fltfield-add in this-procedure ( input 'fact-order',       input 'Факт ордер',                      input '':U,    input-output fld, input-output lab, input-output spr, input-output dim ) no-error.
  run fltfield-add in this-procedure ( input 'status_',          input 'Статус',                          input '':U,    input-output fld, input-output lab, input-output spr, input-output dim ) no-error.
  run fltfield-add in this-procedure ( input 'obj-type',         input 'Тип объекта',                     input '':U,    input-output fld, input-output lab, input-output spr, input-output dim ) no-error.
  run fltfield-add in this-procedure ( input 'obj-code',         input 'Код объекта',                     input '':U,    input-output fld, input-output lab, input-output spr, input-output dim ) no-error.
  run fltfield-add in this-procedure ( input 'obj-type*obj-code',           input 'Объект',                          input 'cli':U, input-output fld, input-output lab, input-output spr, input-output dim ) no-error.
  run fltfield-add in this-procedure ( input 'chip-num',         input 'Щепка',                           input '':U,    input-output fld, input-output lab, input-output spr, input-output dim ) no-error.
  run fltfield-add in this-procedure ( input 'corr-user-db-num', input 'Номер БД',                        input '':U,    input-output fld, input-output lab, input-output spr, input-output dim ) no-error.
  run fltfield-add in this-procedure ( input 'corr-user-name',   input 'Имя',                             input '':U,    input-output fld, input-output lab, input-output spr, input-output dim ) no-error.
  run fltfield-add in this-procedure ( input 'corr-date',        input 'Дата коррекции',                  input '':U,    input-output fld, input-output lab, input-output spr, input-output dim ) no-error.
  run fltfield-add in this-procedure ( input 'corr-time',        input 'Время в секундах',                input '':U,    input-output fld, input-output lab, input-output spr, input-output dim ) no-error.
  run fltfield-add in this-procedure ( input 'action',           input 'Описание действия',               input '':U,    input-output fld, input-output lab, input-output spr, input-output dim ) no-error.
  if num-entries( fld ) <> num-entries( lab ) or num-entries( lab ) <> integer( dim ) or
     num-entries( fld ) <> num-entries( spr ) or num-entries( spr ) <> integer( dim ) or
     num-entries( lab ) <> num-entries( spr ) or num-entries( fld ) <> integer( dim ) then do:
    message "Неверная настройка на фильтры!" view-as alert-box error.
    return no-apply.
  end.
  Filter-Block:
  do on error   undo Filter-Block, leave Filter-Block
     on end-key undo Filter-Block, leave Filter-Block :
    run gbl/filter.w ( input parparentproc,
                   input filter-point,
                   input tbl,
                   input join-tbl,
                   input fld,
                   input lab,
                   input spr,
                   input dim            ).
    if return-value = 'undo':U then do:
      apply "ENTRY":U to browse br-inv-lines.
      return no-apply.
    end.
    assign mark-num = 0
           sch-num  = 0.
    hide   mark-num in frame fr-D-inv-line-0.
    hide   sch-num  in frame fr-D-inv-line-0.
    run OpenBr in this-procedure ( input yes, input no, input '':U ).
    assign b-sch :tooltip in frame fr-D-inv-line-0 = "Установить/снять фильтр".
  end.
end procedure.
procedure proc-view-changes :
  define buffer new_hist for ub.c-inv-line.
  define buffer buf_srch for ub.inv-line.
  define variable v-chg-fields as character no-undo.
  define variable v-old-fields as character no-undo.
  define variable v-new-fields as character no-undo.
  define variable jj           as integer   no-undo.
  for each temp-changes :
    delete temp-changes.
  end.
  if not available buf_history then do:
    run OpenChanges in this-procedure ( input yes, input no, input '':U ).
    return.
  end.
  find first new_hist no-lock where
             new_hist.doc-code  = buf_history.doc-code  and
             new_hist.artic     = buf_history.artic     and
             new_hist.prod-type = buf_history.prod-type and
             new_hist.prod-code = buf_history.prod-code and
             new_hist.chip-num  > buf_history.chip-num  no-error.
  if not available new_hist then do:
    find buf_srch no-lock where
         buf_srch.doc-code  = buf_history.doc-code  and
         buf_srch.artic     = buf_history.artic     and
         buf_srch.prod-type = buf_history.prod-type and
         buf_srch.prod-code = buf_history.prod-code no-error.
    if not available buf_srch then do: return error. end.
    buffer-compare buf_srch to buf_history save result in v-chg-fields.
  end.
  else do:
    buffer-compare new_hist    except chip-num corr-date corr-time corr-user-name corr-user-db-num action
                to buf_history save result in v-chg-fields.
  end.
  do jj = 1 to num-entries( v-chg-fields ) :
    case entry( jj, v-chg-fields ) :
                  when "prod-type":U then do:     create temp-changes.     assign temp-changes.f_name = "prod-type":U            temp-changes.l_name = "Тип произв."            temp-changes.v_old  = string( buf_history.prod-type )            temp-changes.v_new  = ( if available new_hist then string( new_hist.prod-type )                                                          else string( buf_srch.prod-type ) ).   end.
                  when "prod-code":U then do:     create temp-changes.     assign temp-changes.f_name = "prod-code":U            temp-changes.l_name = "Код произв."            temp-changes.v_old  = string( buf_history.prod-code )            temp-changes.v_new  = ( if available new_hist then string( new_hist.prod-code )                                                          else string( buf_srch.prod-code ) ).   end.
                  when "artic":U then do:     create temp-changes.     assign temp-changes.f_name = "artic":U            temp-changes.l_name = "Артикул"            temp-changes.v_old  = string( buf_history.artic )            temp-changes.v_new  = ( if available new_hist then string( new_hist.artic )                                                          else string( buf_srch.artic ) ).   end.
                  when "doc-code":U then do:     create temp-changes.     assign temp-changes.f_name = "doc-code":U            temp-changes.l_name = "Номер документа"            temp-changes.v_old  = string( buf_history.doc-code )            temp-changes.v_new  = ( if available new_hist then string( new_hist.doc-code )                                                          else string( buf_srch.doc-code ) ).   end.
                  when "before-cli-qnty":U then do:     create temp-changes.     assign temp-changes.f_name = "before-cli-qnty":U            temp-changes.l_name = "Кол-во до инв."            temp-changes.v_old  = string( buf_history.before-cli-qnty )            temp-changes.v_new  = ( if available new_hist then string( new_hist.before-cli-qnty )                                                          else string( buf_srch.before-cli-qnty ) ).   end.
                  when "wast-base":U then do:     create temp-changes.     assign temp-changes.f_name = "wast-base":U            temp-changes.l_name = "Учет (б.в.)"            temp-changes.v_old  = string( buf_history.wast-base )            temp-changes.v_new  = ( if available new_hist then string( new_hist.wast-base )                                                          else string( buf_srch.wast-base ) ).   end.
                  when "wast-rubl":U then do:     create temp-changes.     assign temp-changes.f_name = "wast-rubl":U            temp-changes.l_name = "Учет (руб.)"            temp-changes.v_old  = string( buf_history.wast-rubl )            temp-changes.v_new  = ( if available new_hist then string( new_hist.wast-rubl )                                                          else string( buf_srch.wast-rubl ) ).   end.
                  when "unus-wast-base":U then do:     create temp-changes.     assign temp-changes.f_name = "unus-wast-base":U            temp-changes.l_name = "Учет (б.в.)"            temp-changes.v_old  = string( buf_history.unus-wast-base )            temp-changes.v_new  = ( if available new_hist then string( new_hist.unus-wast-base )                                                          else string( buf_srch.unus-wast-base ) ).   end.
                  when "unus-wast-rubl":U then do:     create temp-changes.     assign temp-changes.f_name = "unus-wast-rubl":U            temp-changes.l_name = "Учет (руб.)"            temp-changes.v_old  = string( buf_history.unus-wast-rubl )            temp-changes.v_new  = ( if available new_hist then string( new_hist.unus-wast-rubl )                                                          else string( buf_srch.unus-wast-rubl ) ).   end.
                  when "after-cli-qnty":U then do:     create temp-changes.     assign temp-changes.f_name = "after-cli-qnty":U            temp-changes.l_name = "Кол-во итого"            temp-changes.v_old  = string( buf_history.after-cli-qnty )            temp-changes.v_new  = ( if available new_hist then string( new_hist.after-cli-qnty )                                                          else string( buf_srch.after-cli-qnty ) ).   end.
                  when "wast-cli-qnty":U then do:     create temp-changes.     assign temp-changes.f_name = "wast-cli-qnty":U            temp-changes.l_name = "Факт кол-во"            temp-changes.v_old  = string( buf_history.wast-cli-qnty )            temp-changes.v_new  = ( if available new_hist then string( new_hist.wast-cli-qnty )                                                          else string( buf_srch.wast-cli-qnty ) ).   end.
                  when "obj-type":U then do:     create temp-changes.     assign temp-changes.f_name = "obj-type":U            temp-changes.l_name = "Тип объекта"            temp-changes.v_old  = string( buf_history.obj-type )            temp-changes.v_new  = ( if available new_hist then string( new_hist.obj-type )                                                          else string( buf_srch.obj-type ) ).   end.
                  when "obj-code":U then do:     create temp-changes.     assign temp-changes.f_name = "obj-code":U            temp-changes.l_name = "Код объекта"            temp-changes.v_old  = string( buf_history.obj-code )            temp-changes.v_new  = ( if available new_hist then string( new_hist.obj-code )                                                          else string( buf_srch.obj-code ) ).   end.
                  when "status_":U then do:     create temp-changes.     assign temp-changes.f_name = "status_":U            temp-changes.l_name = "Статус"            temp-changes.v_old  = string( buf_history.status_ )            temp-changes.v_new  = ( if available new_hist then string( new_hist.status_ )                                                          else string( buf_srch.status_ ) ).   end.
                  when "fact-order":U then do:     create temp-changes.     assign temp-changes.f_name = "fact-order":U            temp-changes.l_name = "Факт ордер"            temp-changes.v_old  = string( buf_history.fact-order )            temp-changes.v_new  = ( if available new_hist then string( new_hist.fact-order )                                                          else string( buf_srch.fact-order ) ).   end.
                  when "host-code":U then do:     create temp-changes.     assign temp-changes.f_name = "host-code":U            temp-changes.l_name = "Своя фирма"            temp-changes.v_old  = string( buf_history.host-code )            temp-changes.v_new  = ( if available new_hist then string( new_hist.host-code )                                                          else string( buf_srch.host-code ) ).   end.
                  when "ext-doc-type":U then do:     create temp-changes.     assign temp-changes.f_name = "ext-doc-type":U            temp-changes.l_name = "Расширенный тип"            temp-changes.v_old  = string( buf_history.ext-doc-type )            temp-changes.v_new  = ( if available new_hist then string( new_hist.ext-doc-type )                                                          else string( buf_srch.ext-doc-type ) ).   end.
                  when "density":U then do:     create temp-changes.     assign temp-changes.f_name = "density":U            temp-changes.l_name = "Плотность"            temp-changes.v_old  = string( buf_history.density )            temp-changes.v_new  = ( if available new_hist then string( new_hist.density )                                                          else string( buf_srch.density ) ).   end.
    end case.
  end.
  run OpenChanges in this-procedure ( input yes, input no, input '':U ).
end procedure.
procedure OpenChanges :
  define input parameter p-open-query     as logical   no-undo.
  define input parameter p-find-next      as logical   no-undo.
  define input parameter p-find-condition as character no-undo.
  define variable l-query-was-opened as logical   no-undo.
  define variable sort-change-phrase as character no-undo.
  define variable l-open-query       as logical   no-undo.
  define variable p-proc-hand        as handle    no-undo.
  ASSIGN p-proc-hand = this-procedure :handle.
  case sort-change-name :
    when "":U then do: assign sort-change-phrase = "":U. end.
    otherwise      do: assign sort-change-phrase = "by " + sort-change-name. end.
  end case.
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-29  as logical   no-undo .
define variable  l-filter-open-29    as logical   .
define variable  flt-rec-29       as recid     no-undo .
define variable  filter-name-29      as character no-undo .
define variable  where-phrase-29     as character no-undo .
define variable  sort-phrase-29      as character no-undo .
define variable  where-phrase-rus-29 as character no-undo .
define variable  sort-phrase-rus-29  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input c-point
  ,output flt-rec-29
  ,output filter-name-29
  ,output where-phrase-29
  ,output sort-phrase-29
  ,output where-phrase-rus-29
  ,output sort-phrase-rus-29
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-29
      ) no-error .
  assign
    l-filter-open-29 = false
  .
  if flt-rec-29 <> ?
    or sort-change-phrase > ""
  then do:
    define variable  parameter-2-29 as character no-undo .
    define variable  parameter-3-29 as character no-undo .
    define variable  parameter-4-29 as character no-undo .
    define variable  parameter-5-29 as character no-undo .
    define variable  parameter-6-29 as character no-undo .
    define variable  parameter-7-29 as character no-undo .
      assign
      parameter-3-29 =
                              "for each buf_changes"
      parameter-4-29 =
        (
          if (" yes " + " " + where-phrase-29) <> ""
          then  substitute('&1', yes) + " " + where-phrase-29
          else "true"
        )
      parameter-5-29 = (" " + "" + " " + "")
      parameter-6-29 = if sort-phrase-29 = ''
                           then
        (
        " " + "  " +
          " " + sort-change-phrase +
        " " + "  "
        )
                           else
        (
        " " + "  " +
          " " + sort-change-phrase +
        " " + sort-phrase-29
        )
      parameter-7-29 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-29 =
          (" yes " + " " + where-phrase-29 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-changes:handle
                          ,input parameter-3-29
                          ,input parameter-4-29
                          ,input parameter-5-29
                          ,input parameter-6-29
                          ,input parameter-7-29
                          )
      .
      assign
        l-filter-open-29 = true
      .
    end.
    if l-filter-open-29 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
        assign
          l-query-was-opened = true
        .
    end.
  end.
  if l-filter-open-29 = false then do:
    open query br-changes for each buf_changes
      where  yes
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    doc-rec = recid( buf_changes )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-changes:handle:get-buffer-handle(1) = (buffer buf_changes:handle) then do:
      assign
      parameter-2-29 = (if p-find-next then "true":u else "false":u )
      parameter-4-29 =
        "where ":u +  substitute('&1', yes) + " ":u + where-phrase-29 + " ":u + p-find-condition + " " + ""
      parameter-5-29 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-changes:handle
                          ,input rowid(buf_changes)
                          ,input logical(parameter-2-29)
                          ,input no-lock
                          ,input (buffer buf_changes:handle)
                          ,input parameter-4-29
                          ,input parameter-5-29
                          ) no-error.
      .
      assign
        doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-29 = (if p-find-next then "true":u else "false":u )
      parameter-3-29 =  "for each buf_changes"
      parameter-4-29 =
        (
          if (" yes " + " " + where-phrase-29) <> ""
          then  substitute('&1', yes) + " " + where-phrase-29
          else "true"
        )
      parameter-5-29 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-29 = if sort-phrase-29 = ''
                           then
        (
        " " + "  " +
          " " + sort-change-phrase +
        " " + "  "
        )
                           else
        (
        " " + "  " +
          " " + sort-change-phrase +
        " " + sort-phrase-29
        )
      parameter-7-29 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-changes:handle
                          ,input logical(parameter-2-29)
                          ,input no-lock
                          ,input parameter-3-29
                          ,input parameter-4-29
                          ,input parameter-5-29
                          ,input parameter-6-29
                          ,input parameter-7-29
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
  if p-open-query <> yes then do: reposition br-inv-lines to recid doc-rec no-error. end.
  run WaitFram-Hide in this-procedure.
end procedure.
define variable vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure set-filter-name :
define input parameter p-filter-name as character no-undo .
  do with frame fr-D-inv-line-0:
    if p-filter-name > "" then do:
      assign
        frame fr-D-inv-line-0:title
          = frame fr-D-inv-line-0:title + "   ФИЛЬТР: " + p-filter-name.
      .
      assign
        b-sch :tooltip = "Установлен фильтр " + p-filter-name
      .
    end.
    else do:
      assign
        b-sch :tooltip = ""
      .
    end.
  end.
end procedure.
procedure get-mark-string :
  define        parameter buffer loc-buf for ub.c-inv-line.
  define output parameter        p-sign  as  character no-undo.
  assign p-sign = ( if lookup( Rec2Char( recid( loc-buf ) ), p-rid-list ) > 0 then chr( 42 ) else chr( 32 ) ).
end procedure.
procedure get-action-name :
  define  input parameter p-code as integer   no-undo.
  define output parameter p-name as character no-undo.
  define variable v_code  as character no-undo.
  define variable j_entry as integer   no-undo.
  if p-code = ? or p-code = 0 then do: assign p-name = "":U. end.
  assign v_code  = Int2Char( p-code ).
  assign j_entry = lookup(   v_code, p-act-codes ).
  assign p-name  = ( if j_entry = 0 then "":U else entry( j_entry, p-act-names ) ).
end procedure.
procedure proc-find-code :
  define input parameter p-next as logical   no-undo.
  define input parameter p-code as character no-undo.
  ASSIGN p-code = REPLACE( p-code, chr(34), chr(34) + chr(34) )
         p-code = REPLACE( p-code, chr(39), chr(39) + chr(39) )
         p-code = chr(34) + p-code + chr(34).
  run OpenBr in this-procedure ( input no, input p-next, input substitute( " and buf_history.artic begins &1 ", p-code ) ).
  if doc-rec <> ? then do:
    if FoundRec = ? then do: assign FoundRec = doc-rec. end.
    if FoundRec = doc-rec then do: assign sch-num = 0. end.
    assign  sch-num = sch-num + 1.
    display sch-num with frame fr-D-inv-line-0.
  end.
  else do:
    assign  sch-num = 0.
    hide    sch-num in frame fr-D-inv-line-0.
  end.
  apply "ENTRY":U to sch-code in frame fr-D-inv-line-0.
end procedure.
procedure get-obj-short-name :
  define  input parameter p-type as character no-undo.
  define  input parameter p-code as integer   no-undo.
  define output parameter p-name as character no-undo.
  assign p-name = ( if p-type = ? or p-code = ? then "":U else ( p-type + " ":U + Int2Char( p-code ) ) ).
end procedure.
procedure get-obj-full-name :
  define  input parameter p-type as character no-undo.
  define  input parameter p-code as integer   no-undo.
  define output parameter p-name as character no-undo.
  define buffer buf_clients for ub.clients.
  find buf_clients no-lock where
       buf_clients.obj-type = p-type and
       buf_clients.obj-code = p-code no-error.
  if available buf_clients then do:
    assign p-name = buf_clients.obj-name.
  end.
  else do:
    assign p-name = ( if p-type = ? or p-code = ? then "":U else ( p-type + " ":U + Int2Char( p-code ) ) ).
  end.
end procedure.
procedure get-ext-type :
  define  input parameter p-type as character no-undo.
  define output parameter p-name as character no-undo.
  define variable jndex as integer no-undo.
  assign jndex  = lookup( p-type, 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U ).
  assign p-name = ( if jndex = 0 then "":U else entry( jndex, 'приход внешний,расход внешний,возврат пост.,касса продажа,возврат внешний,касса возврат,списание,инвентаризация,пересортица,приход внутренний,расход внутренний,возврат внутренний,расход  произв.,списан. произв.,приход  произв.,переоценка,коррекция учетных цен,корректировка отрицательных партий,смена типа приобретения,приход внутриобъектный,расход внутриобъектный':U ) ).
end procedure.
procedure get-goods-name :
  define  input parameter p-artic     as character no-undo.
  define  input parameter p-prod-type as character no-undo.
  define  input parameter p-prod-code as integer   no-undo.
  define output parameter p-gds-name  as character no-undo.
  define buffer buf_goods for ub.goods.
  find first buf_goods no-lock where
             buf_goods.artic     = p-artic     and
             buf_goods.prod-type = p-prod-type and
             buf_goods.prod-code = p-prod-code no-error.
  assign p-gds-name = ( if available buf_goods then buf_goods.gds-name else "":U ).
end procedure.
procedure is-petrolium-goods :
  define  input parameter p-artic     as character no-undo.
  define  input parameter p-prod-type as character no-undo.
  define  input parameter p-prod-code as integer   no-undo.
  define output parameter p-is-petrol as logical   no-undo initial no.
  define variable v_is-petrol as logical no-undo initial no.
  define variable v_is-pieces as logical no-undo initial no.
  define buffer buf_goods for ub.goods.
  define buffer buf_units for ub.units.
  find first buf_goods no-lock where
             buf_goods.artic     = p-artic     and
             buf_goods.prod-type = p-prod-type and
             buf_goods.prod-code = p-prod-code no-error.
  if not available buf_goods then do: return. end.
  find first buf_units no-lock where buf_units.unit-name = buf_goods.unit-base no-error.
  if not available buf_units then do: return. end.
  assign v_is-petrol = ( if lookup( 'топ':U, buf_units.type ) > 0 then yes else no ).
  if lookup( 'шту':U, buf_units.type ) = 0 then do:
    if v_is-petrol = yes and lookup( 'дро':U, buf_units.type ) = 0 then do: return. end.
    assign v_is-pieces = no.
  end.
  else do:
    assign v_is-pieces = yes.
  end.
  assign p-is-petrol = ( ( v_is-petrol = yes ) and ( v_is-pieces = no ) ).
end procedure.
