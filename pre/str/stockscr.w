define input parameter paruser-name as character no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Экран продавца".
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
define temp-table tt-usrstko no-undo
field user-name     as   character
field obj-type      like ub.clients.obj-type
field obj-code      like ub.clients.obj-code
field obj-name      like ub.clients.obj-name
field main-obj-type like ub.clients.obj-type
field main-obj-code like ub.clients.obj-code
field main-obj-name like ub.clients.obj-name
field level         as   integer
field host-code     like ub.clients.obj-code
field host-name     like ub.clients.obj-name
field db-num        like ub.db.db-num
index pi is unique primary user-name obj-type obj-code
index level is unique user-name level.
PROCEDURE loadusr-tt :
define input parameter paruser-name as character no-undo.
define buffer bf_clients      for ub.clients.
define buffer bf_main-clients for ub.clients.
define buffer bf_usr-flt      for ubflt.usr-flt.
define buffer bf_shop         for ub.shop.
define buffer bf_store        for ub.store.
define buffer bf_host-clients for ub.clients.
define buffer bf_db           for ub.db.
for each tt-usrstko:
  delete tt-usrstko.
end.
for each bf_usr-flt where bf_usr-flt.user-name  = paruser-name     and
                          bf_usr-flt.call-point begins "stockscr"   :
  create tt-usrstko.
  assign
    tt-usrstko.user-name    = paruser-name
    tt-usrstko.obj-type      = substring(bf_usr-flt.call-point, 9, 3)
    tt-usrstko.obj-code      = integer(substring(bf_usr-flt.call-point, 12))
    tt-usrstko.level         = integer(entry(1, bf_usr-flt.naim))
    tt-usrstko.main-obj-type = substring(bf_usr-flt.list_, 1, 3)
    tt-usrstko.main-obj-code = integer(substring(bf_usr-flt.list_, 4)).
  if tt-usrstko.main-obj-code <> ? then do:
    find first bf_main-clients where bf_main-clients.obj-type = tt-usrstko.main-obj-type and
                                     bf_main-clients.obj-code = tt-usrstko.main-obj-code no-lock.
    assign
      tt-usrstko.main-obj-name = bf_main-clients.obj-name.
  end.
  if tt-usrstko.obj-type = 'маг':U then do:
    find first bf_shop where bf_shop.obj-code = tt-usrstko.obj-code no-lock.
    find first bf_host-clients where bf_host-clients.obj-type = 'орг':U and
                                     bf_host-clients.obj-code =  bf_shop.host-code no-lock.
  end.
  else do:
    find first bf_store where bf_store.obj-code = tt-usrstko.obj-code no-lock.
    find first bf_host-clients where bf_host-clients.obj-type = 'орг':U             and
                                     bf_host-clients.obj-code = bf_store.host-code no-lock.
  end.
  assign
    tt-usrstko.host-code = bf_host-clients.obj-code
    tt-usrstko.host-name = bf_host-clients.obj-name.
  find first bf_clients where bf_clients.obj-type = tt-usrstko.obj-type and
                              bf_clients.obj-code = tt-usrstko.obj-code no-lock.
  find first bf_db where bf_db.db-num = bf_clients.db-num no-lock.
  assign
    tt-usrstko.obj-name = bf_clients.obj-name
    tt-usrstko.db-num   = bf_db.db-num.
end.
END PROCEDURE.
define new global shared variable g#libbcrcn as handle no-undo .
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
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
define temp-table tt-goods no-undo
field artic     like ub.goods.artic
field prod-type like ub.goods.prod-type
field prod-code like ub.goods.prod-code
field prt-code  like ub.prt-obj.prt-code
field ford-num  as   character
field gds-name  like ub.goods.gds-name
field prt-name  like ub.gds-prt.f-name
field prod-name like ub.clients.obj-name
field grp-name  like ub.gds-grp.node-name
field unit-base like ub.goods.unit-base
field fact-qnty like ub.prt-obj.fact-qnty
field free-qnty like ub.prt-obj.free-qnty
field ford-num-0 like ub.gds-prt.prt-num
field ford-num-1 like ub.gds-prt.prt-num
field ford-num-2 like ub.gds-prt.prt-num
field prt-root like ub.gds-prt.prt-root
index pi is unique primary  artic prod-type prod-code prt-code
index ford-num artic prod-type prod-code ford-num-0 ford-num-1 ford-num-2 prt-code
index gds-name gds-name
index prt-name prt-root prt-name
index artic artic.
define temp-table tt-cont-goods no-undo like ub.goods.
define temp-table tt-stock no-undo
field obj-type   like ub.clients.obj-type
field obj-code   like ub.clients.obj-code
field host-code  like ub.clients.obj-code
field host-name  like ub.clients.obj-name
field artic      like ub.goods.artic
field prod-type  like ub.goods.prod-type
field prod-code  like ub.goods.prod-code
field prt-code   like ub.prt-obj.prt-code
field fact-qnty  like ub.prt-obj.fact-qnty
field free-qnty  like ub.prt-obj.free-qnty
field data-date  as   date
field data-time  as   integer
field price-sale like ub.price-list.price-sale
field level as integer
index pi is unique primary obj-type obj-code artic prod-type prod-code prt-code
index level level
index goods artic prod-type prod-code prt-code.
define variable varchg as logical no-undo.
define variable is-slscrvalue as character no-undo.
define variable is-slscrtype  as character no-undo.
define variable numslscrvalue as character no-undo.
define variable numslscrtype  as character no-undo.
define variable numslscrvalue_int as integer no-undo.
define buffer buf_batchprocess for ub.batchprocess.
function string-time returns character (input parint-time as integer) :
 return string(parint-time, "hh:mm:ss").
end.
procedure full-grp:
def input param n-code like ub.gds-grp.node-code no-undo.
def input-output param name like ub.goods.grp-name no-undo.
def var uc like ub.gds-grp.upper-code no-undo.
name = ''.
find ub.gds-grp where ub.gds-grp.node-code = n-code.
do while ub.gds-grp.upper-code <> 0:
  assign
    name = if name = '' then ub.gds-grp.node-name
                 else ub.gds-grp.node-name + '/' + name
    uc = ub.gds-grp.upper-code.
  find ub.gds-grp where ub.gds-grp.node-code = uc.
end.
end procedure.
DEFINE BUTTON b-admin
     LABEL "Настройка"
     SIZE 10 BY 1.
DEFINE BUTTON b-exit AUTO-GO
     LABEL "Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-help
     LABEL "&Помощь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-requery
     LABEL "Обновить все"
     SIZE 13.5 BY 1.
DEFINE BUTTON b-requery-prt
     LABEL "Обновить признак"
     SIZE 17 BY 1.
DEFINE VARIABLE varartic AS CHARACTER FORMAT "X(19)":U
     LABEL "Артикул"
     VIEW-AS FILL-IN
     SIZE 20 BY 1 NO-UNDO.
DEFINE VARIABLE varb-c AS CHARACTER FORMAT "X(256)":U
     LABEL "Бар-код"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE vargds-cnt AS CHARACTER FORMAT "X(256)":U
     LABEL "Начало слова"
     VIEW-AS FILL-IN
     SIZE 27.63 BY 1 NO-UNDO.
DEFINE VARIABLE vargds-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Начало названия"
     VIEW-AS FILL-IN
     SIZE 27.63 BY 1 NO-UNDO.
DEFINE QUERY b-goods FOR
      tt-goods,
      tt-cont-goods SCROLLING.
DEFINE QUERY b-stock FOR
      tt-stock SCROLLING.
DEFINE BROWSE b-goods
  QUERY b-goods DISPLAY
      tt-goods.artic                              column-label "Артикул"
  tt-goods.gds-name  format "x(20)"  column-label "Название товара"
  tt-goods.prt-name  format "x(20)"  column-label "Признак"
  tt-goods.unit-base  format "x(3)"               column-label "Изм"
  tt-goods.fact-qnty                              column-label "Факт"
  tt-goods.free-qnty                              column-label "Свободно"
  tt-goods.prod-name  format "x(50)"              column-label "Производитель"
  tt-goods.grp-name  format "x(50)"              column-label "Группа"
enable tt-goods.grp-name
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97.75 BY 10.63.
DEFINE BROWSE b-stock
  QUERY b-stock DISPLAY
      tt-stock.obj-code
tt-stock.obj-type
tt-stock.fact-qnty
tt-stock.free-qnty
tt-stock.price-sale
tt-stock.data-date column-label "Дата актуальности"
string-time(tt-stock.data-time) column-label "Время         "
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97.75 BY 7.38.
DEFINE FRAME Dialog-Frame
     b-goods AT ROW 5.5 COL 1.5
     b-exit AT ROW 1 COL 1
     b-requery AT ROW 1 COL 11
     b-requery-prt AT ROW 1 COL 24.5
     b-admin AT ROW 1 COL 41.5
     b-help AT ROW 1 COL 51.5
     varartic AT ROW 2.5 COL 16 COLON-ALIGNED
     vargds-name AT ROW 4 COL 16 COLON-ALIGNED
     varb-c AT ROW 2.5 COL 63.5 COLON-ALIGNED
     b-stock AT ROW 16.25 COL 1.5
     vargds-cnt AT ROW 4 COL 63.5 COLON-ALIGNED
     SPACE(6.12) SKIP(18.63)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Остатки товаров"
         DEFAULT-BUTTON b-exit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON END-ERROR OF FRAME Dialog-Frame
DO:
  return no-apply.
END.
ON return OF FRAME Dialog-Frame
DO:
  return no-apply.
END.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-admin IN FRAME Dialog-Frame
DO:
define variable varlog as logical no-undo.
  run str/stkscrad.w (input paruser-name, output varchg) no-error.
  if error-status:error then do:
      message "Ошибка при настройке объектов." view-as alert-box.
      return no-apply.
    end.
    if varchg = yes then do:
      for each tt-usrstko :
        delete tt-usrstko.
      end.
      run loadusr-tt in this-procedure (input paruser-name) no-error.
      if error-status:error then do:
        message "Ошибка при работе с объектами пользователя." view-as alert-box.
        return no-apply.
      end.
      message "Набор объектов был изменен."
      "Будем обновлять данные?" view-as alert-box question buttons yes-no update varlog.
      if varlog = yes then do:
        run change-brw in this-procedure no-error.
        if error-status:error then do:
          message "Ошибка при обновлении информации." view-as alert-box error.
          return no-apply.
        end.
      end.
    end.
END.
ON ANY-PRINTABLE OF b-goods IN FRAME Dialog-Frame
DO:
    apply "any-printable" to varartic in frame Dialog-Frame.
END.
ON BACKSPACE OF b-goods IN FRAME Dialog-Frame
DO:
  apply "any-printable" to varartic in frame Dialog-Frame.
  return no-apply.
END.
ON GO OF b-goods IN FRAME Dialog-Frame
DO:
  return no-apply.
END.
ON return OF b-goods IN FRAME Dialog-Frame
DO:
  return no-apply.
END.
ON VALUE-CHANGED OF b-goods IN FRAME Dialog-Frame
DO:
  OPEN QUERY b-stock FOR EACH tt-stock where tt-stock.artic     = tt-goods.artic         and                                                 tt-stock.prod-type = tt-goods.prod-type and                                                 tt-stock.prod-code = tt-goods.prod-code and                                                 tt-stock.prt-code  = tt-goods.prt-code  use-index level indexed-reposition.
  assign
     varartic    = ""
     varb-c      = ""
     vargds-name = ""
     .
     display varartic varb-c vargds-name with frame Dialog-Frame.
END.
ON CHOOSE OF b-requery IN FRAME Dialog-Frame
DO:
  run change-brw in this-procedure.
END.
ON CHOOSE OF b-requery-prt IN FRAME Dialog-Frame
DO:
define variable varobj-type like ub.clients.obj-type no-undo.
define variable varobj-code like ub.clients.obj-code no-undo.
define variable varrec-id as recid no-undo.
define variable parfact-qnty like ub.prt-obj.fact-qnty no-undo.
define variable parfree-qnty like ub.prt-obj.free-qnty no-undo.
define variable varartic like tt-goods.artic no-undo.
define variable varprod-type like tt-goods.prod-type no-undo.
define variable varprod-code like tt-goods.prod-code no-undo.
define variable varprt-code like tt-goods.prt-code no-undo.
define variable varprt-root like tt-goods.prt-root no-undo.
define variable varprt-name like tt-goods.prt-name no-undo.
define buffer bf_tt-goods for tt-goods.
define buffer bf_prt-obj  for ub.prt-obj.
define buffer bf_gds-prt  for ub.gds-prt.
define variable parrec-id as recid no-undo.
if available tt-goods then do:
 assign
    varartic     = tt-goods.artic
    varprod-type = tt-goods.prod-type
    varprod-code = tt-goods.prod-code
    varprt-code  = tt-goods.prt-code
    varprt-root  = tt-goods.prt-root
    varprt-name  = tt-goods.prt-name.
 if available tt-stock then do:
  assign
   varobj-type = tt-stock.obj-type
   varobj-code = tt-stock.obj-code.
 end.
 run waitfram-show in this-procedure
   (input "Подготовка остатков товаров для просмотра"
   ).
 for each bf_tt-goods where bf_tt-goods.artic     = tt-goods.artic     and
                            bf_tt-goods.prod-type = tt-goods.prod-type and
                            bf_tt-goods.prod-code = tt-goods.prod-code and
                            bf_tt-goods.prt-root  = tt-goods.prt-root  and
                            bf_tt-goods.prt-name  begins tt-goods.prt-name :
   for each tt-stock where tt-stock.artic     = bf_tt-goods.artic and
                           tt-stock.prod-type = bf_tt-goods.prod-type and
                           tt-stock.prod-code = bf_tt-goods.prod-code and
                           tt-stock.prt-code  = bf_tt-goods.prt-code :
      delete tt-stock.
   end.
   delete bf_tt-goods.
end.
 for each tt-usrstko no-lock,
   each bf_prt-obj where bf_prt-obj.obj-type  = tt-usrstko.obj-type and
                         bf_prt-obj.obj-code  = tt-usrstko.obj-code and
                         bf_prt-obj.artic     = varartic and
                         bf_prt-obj.prod-type = varprod-type and
                         bf_prt-obj.prod-code = varprod-code no-lock,
       first bf_gds-prt where  bf_gds-prt.node-code = bf_prt-obj.prt-code and
                               bf_gds-prt.prt-root = varprt-root and
                               bf_gds-prt.f-name begins varprt-name no-lock
                      :
   if bf_prt-obj.fact-qnty = 0 and
      bf_prt-obj.free-qnty = 0 then next.
   run create-tt-goods (input bf_prt-obj.artic,
                       input bf_prt-obj.prod-type,
                       input bf_prt-obj.prod-code,
                       input bf_prt-obj.prt-code,
                       output parrec-id) no-error.
   if error-status:error then do:
     message "Ошибка при создании товарной записи." view-as alert-box.
     return no-apply.
   end.
   find first bf_tt-goods where recid(bf_tt-goods) = parrec-id.
   assign
     bf_tt-goods.fact-qnty = bf_tt-goods.fact-qnty + bf_prt-obj.fact-qnty
     bf_tt-goods.free-qnty = bf_tt-goods.free-qnty + bf_prt-obj.free-qnty.
   run calc-stock in this-procedure
      (input tt-usrstko.obj-type,
       input tt-usrstko.obj-code,
       input tt-usrstko.db-num,
       input tt-usrstko.main-obj-type,
       input tt-usrstko.main-obj-code,
       input tt-usrstko.host-code,
       input tt-usrstko.host-name,
       input tt-usrstko.level,
       input bf_tt-goods.artic,
       input bf_tt-goods.prod-type,
       input bf_tt-goods.prod-code,
       input bf_tt-goods.prt-code,
       input bf_prt-obj.price-sale,
       input bf_prt-obj.fact-qnty,
       input bf_prt-obj.free-qnty) no-error.
     if error-status:error then do:
        message "Ошибка при подсчете остатков." view-as alert-box error.
        return no-apply.
     end.
 end.
 OPEN QUERY b-goods FOR EACH tt-goods use-index ford-num,        FIRST tt-cont-goods OUTER-JOIN WHERE TRUE.
 find first tt-goods where tt-goods.artic = varartic and
                                      tt-goods.prod-type = varprod-type and
                                      tt-goods.prod-code = varprod-code and
                                      tt-goods.prt-code = varprt-code  no-error.
 if available tt-goods then do:
   reposition b-goods to recid recid(tt-goods) no-error.
 end.
 else do:
   message "Данного признака(товара) больше нет в наличии." view-as alert-box.
 end.
 OPEN QUERY b-stock FOR EACH tt-stock where tt-stock.artic     = tt-goods.artic         and                                                 tt-stock.prod-type = tt-goods.prod-type and                                                 tt-stock.prod-code = tt-goods.prod-code and                                                 tt-stock.prt-code  = tt-goods.prt-code  use-index level indexed-reposition.
 find first   tt-stock where tt-stock.obj-type   = varobj-type        and
                             tt-stock.obj-code   = varobj-code        and
                             tt-stock.artic      = tt-goods.artic     and
                             tt-stock.prod-type  = tt-goods.prod-type and
                             tt-stock.prod-code  = tt-goods.prod-code and
                             tt-stock.prt-code   = tt-goods.prt-code  no-error.
 if available tt-stock then do:
   reposition b-stock to recid recid(tt-stock) no-error.
 end.
 run waitfram-hide in this-procedure .
end.
END.
ON GO OF b-stock IN FRAME Dialog-Frame
DO:
    return no-apply.
END.
ON return OF b-stock IN FRAME Dialog-Frame
DO:
  return no-apply.
END.
ON ANY-PRINTABLE OF varartic IN FRAME Dialog-Frame
DO:
  define variable varrec-id as recid no-undo.
  display "" @ vargds-name "" @ varb-c with frame Dialog-Frame.
  assign frame Dialog-Frame varartic.
  if last-event:label = "backspace" then do:
      assign varartic = substring (varartic, 1, length(varartic) - 1).
    end.
    else do:
    if last-event:label <> "enter" then do:
      assign varartic = varartic + last-event:label.
    end.
  end.
  display varartic with frame Dialog-Frame.
  find first tt-goods where tt-goods.artic begins varartic no-error.
  if available tt-goods then do:
    assign
      varrec-id = recid(tt-goods).
      reposition b-goods to recid varrec-id no-error.
    OPEN QUERY b-stock FOR EACH tt-stock where tt-stock.artic     = tt-goods.artic         and                                                 tt-stock.prod-type = tt-goods.prod-type and                                                 tt-stock.prod-code = tt-goods.prod-code and                                                 tt-stock.prt-code  = tt-goods.prt-code  use-index level indexed-reposition.
    find first   tt-stock where tt-stock.artic      = tt-goods.artic     and
                                tt-stock.prod-type  = tt-goods.prod-type and
                                tt-stock.prod-code  = tt-goods.prod-code and
                                tt-stock.prt-code   = tt-goods.prt-code  no-error.
    if available tt-stock then do:
      varrec-id = recid(tt-stock).
      reposition b-stock to recid varrec-id no-error.
    end.
  end.
  return no-apply.
END.
ON return OF varartic IN FRAME Dialog-Frame
DO:
  apply "any-printable" to varartic in frame Dialog-Frame.
  return no-apply.
END.
ON GO OF varb-c IN FRAME Dialog-Frame
DO:
    return no-apply.
END.
ON return OF varb-c IN FRAME Dialog-Frame
DO:
define buffer bf_bar-code for ub.bar-code.
define buffer bf_prod-bc  for ub.prod-bc.
define buffer bf_place    for ub.place.
define buffer bf_goods    for ub.goods.
define buffer bf_tt-goods for tt-goods.
define variable par-type as character no-undo.
define variable varresult  as character no-undo.
define variable vartype-bc as character no-undo.
define variable varweigth  as decimal   no-undo.
assign frame Dialog-Frame varb-c.
display "" @ vargds-name "" @ varartic with frame Dialog-Frame.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable varscales-pref as character no-undo .
define variable varpgscales-pref as character no-undo .
define variable varscales-pref-type1 as character no-undo.
varscales-pref  = ?.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'sclspref':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  no
  ,output varscales-pref
  ,output varscales-pref-type1
  ) no-error .
if varscales-pref = ? then do:
  assign
  varscales-pref = '21,23,25':U.
end.
define variable varpgscales-pref-type1 as character no-undo.
varpgscales-pref  = ?.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'scpgpref':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  no
  ,output varpgscales-pref
  ,output varpgscales-pref-type1
  ) no-error .
if varpgscales-pref = ? then do:
  assign
  varpgscales-pref = '24IIIIIQQ000C,28IIIIIQQQ00C':U.
end.
if (valid-handle(g#libbcrcn) <> true) then do:   run str/libbcrcn.p persistent no-error .   if error-status :error or (valid-handle(g#libbcrcn) <> true) then do:     message       "Error starting libbcrcn.p" skip       g#libbcrcn skip       g#libbcrcn :type skip       g#libbcrcn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libbcrcn_bc-rcnz in g#libbcrcn
(
 input  ?
,input  varb-c
,input  ?
,input  ?
,input  ?
,input  no
,input  no
,input  varscales-pref
,input  varpgscales-pref
,output varresult
,output vartype-bc
,output varweigth
,buffer bf_bar-code
,buffer bf_prod-bc
,buffer bf_place
) .
if available bf_bar-code then do:
  find first bf_goods where bf_goods.gds-code = bf_bar-code.gds-code no-lock.
  find first bf_tt-goods where bf_tt-goods.artic     = bf_goods.artic        and
                               bf_tt-goods.prod-type = bf_goods.prod-type    and
                               bf_tt-goods.prod-code = bf_goods.prod-code    and
                               bf_tt-goods.prt-code  = bf_bar-code.node-code no-error.
  reposition b-goods to recid recid(bf_tt-goods) no-error.
  OPEN QUERY b-stock FOR EACH tt-stock where tt-stock.artic     = tt-goods.artic         and                                                 tt-stock.prod-type = tt-goods.prod-type and                                                 tt-stock.prod-code = tt-goods.prod-code and                                                 tt-stock.prt-code  = tt-goods.prt-code  use-index level indexed-reposition.
  find first   tt-stock where tt-stock.artic      = bf_tt-goods.artic     and
                              tt-stock.prod-type  = bf_tt-goods.prod-type and
                              tt-stock.prod-code  = bf_tt-goods.prod-code and
                              tt-stock.prt-code   = bf_tt-goods.prt-code  no-error.
  if available tt-stock then do:
    reposition b-stock to recid recid(tt-stock) no-error.
  end.
end.
return no-apply.
END.
ON GO OF vargds-cnt IN FRAME Dialog-Frame
DO:
    return no-apply.
END.
ON return OF vargds-cnt IN FRAME Dialog-Frame
DO:
  define buffer bf_goods for ub.goods.
  assign frame Dialog-Frame vargds-cnt.
  if vargds-cnt <> "":u then do:
    display "" @ varartic "" @ varb-c "" @ vargds-name with frame Dialog-Frame.
    for each tt-cont-goods :
      delete tt-cont-goods.
    end.
    for each bf_goods where bf_goods.gds-name contains vargds-cnt no-lock:
      create tt-cont-goods.
      buffer-copy bf_goods to tt-cont-goods.
    end.
    OPEN QUERY b-goods FOR EACH tt-goods, FIRST tt-cont-goods where tt-cont-goods.artic     = tt-goods.artic     AND
                                                                    tt-cont-goods.prod-type = tt-goods.prod-type AND
                                                                    tt-cont-goods.prod-code = tt-goods.prod-code.
    GET FIRST b-goods.
    IF not available tt-goods THEN DO:
     FIND first tt-cont-goods NO-ERROR.
     IF AVAILABLE tt-cont-goods THEN DO:
       MESSAGE "Товары имеющие в начале слова <" vargds-cnt "> есть в базе данных. Но по ним нет остатка товара."
       VIEW-AS ALERT-BOX.
     END.
    END.
    OPEN QUERY b-stock FOR EACH tt-stock where tt-stock.artic     = tt-goods.artic         and                                                 tt-stock.prod-type = tt-goods.prod-type and                                                 tt-stock.prod-code = tt-goods.prod-code and                                                 tt-stock.prt-code  = tt-goods.prt-code  use-index level indexed-reposition.
  end.
  else do:
    OPEN QUERY b-goods FOR EACH tt-goods use-index ford-num,        FIRST tt-cont-goods OUTER-JOIN WHERE TRUE.
    OPEN QUERY b-stock FOR EACH tt-stock where tt-stock.artic     = tt-goods.artic         and                                                 tt-stock.prod-type = tt-goods.prod-type and                                                 tt-stock.prod-code = tt-goods.prod-code and                                                 tt-stock.prt-code  = tt-goods.prt-code  use-index level indexed-reposition.
  end.
  return no-apply.
END.
ON CTRL-J OF vargds-name IN FRAME Dialog-Frame
DO:
  define variable varrec-id as recid no-undo.
  display "" @ varartic "" @ varb-c with frame Dialog-Frame.
  assign frame Dialog-Frame vargds-name.
  find next tt-goods where tt-goods.gds-name begins vargds-name use-index gds-name no-error.
   if available tt-goods then do:
      assign
         varrec-id = recid(tt-goods).
      reposition b-goods to recid varrec-id no-error.
      OPEN QUERY b-stock FOR EACH tt-stock where tt-stock.artic     = tt-goods.artic         and                                                 tt-stock.prod-type = tt-goods.prod-type and                                                 tt-stock.prod-code = tt-goods.prod-code and                                                 tt-stock.prt-code  = tt-goods.prt-code  use-index level indexed-reposition.
      find first tt-stock where   tt-stock.artic      = tt-goods.artic     and
                                  tt-stock.prod-type  = tt-goods.prod-type and
                                  tt-stock.prod-code  = tt-goods.prod-code and
                                  tt-stock.prt-code   = tt-goods.prt-code  no-error.
      if available tt-stock then do:
        varrec-id = recid(tt-stock).
        reposition b-stock to recid varrec-id no-error.
      end.
   end.
return no-apply.
END.
ON GO OF vargds-name IN FRAME Dialog-Frame
DO:
    return no-apply.
END.
ON return OF vargds-name IN FRAME Dialog-Frame
DO:
  define variable varrec-id as recid no-undo.
  display "" @ varartic "" @ varb-c with frame Dialog-Frame.
  assign frame Dialog-Frame vargds-name.
  find first tt-goods where tt-goods.gds-name begins vargds-name no-error.
   if available tt-goods then do:
      assign
         varrec-id = recid(tt-goods).
      reposition b-goods to recid varrec-id no-error.
      OPEN QUERY b-stock FOR EACH tt-stock where tt-stock.artic     = tt-goods.artic         and                                                 tt-stock.prod-type = tt-goods.prod-type and                                                 tt-stock.prod-code = tt-goods.prod-code and                                                 tt-stock.prt-code  = tt-goods.prt-code  use-index level indexed-reposition.
      find first tt-stock where   tt-stock.artic      = tt-goods.artic     and
                                  tt-stock.prod-type  = tt-goods.prod-type and
                                  tt-stock.prod-code  = tt-goods.prod-code and
                                  tt-stock.prt-code   = tt-goods.prt-code  no-error.
      if available tt-stock then do:
        varrec-id = recid(tt-stock).
        reposition b-stock to recid varrec-id no-error.
      end.
   end.
return no-apply.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
        v-diasize-browse-handle     = browse b-goods :handle
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
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
   run gbl/conf-rd.p ("is-slscr", ?, "", 0, "", "", "", no,  output is-slscrvalue, output is-slscrtype) no-error.
   if is-slscrvalue <> "yes" then do:
     message "У Вас нет лицензии на работу с АРМом <Экран продавца>"
     view-as alert-box.
     return error.
   end.
   run gbl/conf-rd.p ("numslscr", ?, "", 0, "", "", "", no,  output numslscrvalue, output numslscrtype) no-error.
   if numslscrvalue = "" then do:
     assign
       numslscrvalue_int = 0.
   end.
   else do:
     assign
       numslscrvalue_int = integer (numslscrvalue).
   end.
   run gbl/lock-usr.p
    (input "test"
    ,input "sal"
    ,input true
    ,input "Достигнуто максимальное количество пользователей &1"
    ,input numslscrvalue_int
    ,buffer buf_batchprocess
    ) no-error.
  if error-status:error then do:
    return error.
  end.
  find first ubflt.usr-flt where ubflt.usr-flt.user-name  = paruser-name and
                           ubflt.usr-flt.call-point begins "stockscr"   no-lock no-error.
   if not available ubflt.usr-flt then do:
    message "У Вас нет ни одного настроенного объекта для получения остатков."
    view-as alert-box.
    run str/stkscrad.w (input paruser-name, output varchg) no-error.
  end.
  run loadusr-tt (input paruser-name) no-error.
  if error-status :error then do:
    message "Ошибка при чтении настроек пользователя." view-as alert-box error.
    return error.
  end.
  run load-tt no-error.
  if error-status:error then do:
    message "Ошибка при чтении остатков из БД." view-as alert-box error.
    return error.
  end.
  RUN enable_UI.
  assign tt-goods.grp-name:read-only in browse b-goods = yes.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE calc-stock :
define input parameter parobj-type      like tt-usrstko.obj-type      no-undo.
define input parameter parobj-code      like tt-usrstko.obj-code      no-undo.
define input parameter pardb-num        like tt-usrstko.db-num        no-undo.
define input parameter parmain-obj-type like tt-usrstko.main-obj-type no-undo.
define input parameter parmain-obj-code like tt-usrstko.main-obj-code no-undo.
define input parameter parhost-code     like tt-usrstko.host-code     no-undo.
define input parameter parhost-name     like tt-usrstko.host-name     no-undo.
define input parameter parlevel         like tt-usrstko.level         no-undo.
define input parameter parartic         like tt-goods.artic           no-undo.
define input parameter parprod-type     like tt-goods.prod-type       no-undo.
define input parameter parprod-code     like tt-goods.prod-code       no-undo.
define input parameter parprt-code      like tt-goods.prt-code        no-undo.
define input parameter parprice-sale    like ub.prt-obj.price-sale    no-undo.
define input parameter parfact-qnty     like ub.prt-obj.fact-qnty     no-undo.
define input parameter parfree-qnty     like ub.prt-obj.free-qnty     no-undo.
define buffer bf_db-status    for ub.db-status.
define buffer bf_tt-usrstko   for tt-usrstko.
define buffer bf_sys-ctrl     for ub.sys-ctrl.
  find first bf_db-status where bf_db-status.db-num = pardb-num no-lock no-error.
  find first bf_sys-ctrl no-lock.
  if parmain-obj-code <> ? then do:
    find first tt-stock where tt-stock.obj-type  = parmain-obj-type and
                              tt-stock.obj-code  = parmain-obj-code and
                              tt-stock.artic     = parartic         and
                              tt-stock.prod-type = parprod-type     and
                              tt-stock.prod-code = parprod-code     and
                              tt-stock.prt-code  = parprt-code      no-error.
    if not available tt-stock then do:
      find first bf_tt-usrstko where bf_tt-usrstko.user-name = paruser-name     and
                                     bf_tt-usrstko.main-obj-type  = parmain-obj-type and
                                     bf_tt-usrstko.main-obj-code  = parmain-obj-code no-error.
      create tt-stock.
      assign
        tt-stock.obj-type   = parmain-obj-type
        tt-stock.obj-code   = parmain-obj-code
        tt-stock.host-code  = bf_tt-usrstko.host-code
        tt-stock.host-name  = bf_tt-usrstko.host-name
        tt-stock.artic      = parartic
        tt-stock.prod-type  = parprod-type
        tt-stock.prod-code  = parprod-code
        tt-stock.prt-code   = parprt-code.
      assign
        tt-stock.data-date  = (if available bf_db-status then (if bf_sys-ctrl.db-num = bf_db-status.db-num then today else bf_db-status.stock-date) else ?)
        tt-stock.data-time  = (if available bf_db-status then (if bf_sys-ctrl.db-num = bf_db-status.db-num then time  else bf_db-status.stock-time) else ?)
        tt-stock.price-sale = ?
        tt-stock.level      = bf_tt-usrstko.level.
      assign
        tt-stock.fact-qnty  = parfact-qnty
        tt-stock.free-qnty  = parfree-qnty.
    end.
    else do:
      assign
        tt-stock.price-sale = parprice-sale
        tt-stock.fact-qnty  = tt-stock.fact-qnty + parfact-qnty
        tt-stock.free-qnty  = tt-stock.free-qnty + parfree-qnty.
      if not available bf_db-status or
         tt-stock.data-date = ? then do:
        assign
          tt-stock.data-date = ?
          tt-stock.data-time = ?.
      end.
      else do:
         if bf_sys-ctrl.db-num <> bf_db-status.db-num then do:
           if integer(bf_db-status.stock-date) * 86400 + bf_db-status.stock-time <
              integer(tt-stock.data-date) * 86400 + tt-stock.data-time then do:
              assign
                tt-stock.data-date = bf_db-status.stock-date
                tt-stock.data-time = bf_db-status.stock-time.
            end.
         end.
      end.
    end.
  end.
  else do:
    find first tt-stock where tt-stock.obj-type   = parobj-type  and
                              tt-stock.obj-code   = parobj-code  and
                              tt-stock.artic      = parartic     and
                              tt-stock.prod-type  = parprod-type and
                              tt-stock.prod-code  = parprod-code and
                              tt-stock.prt-code   = parprt-code  no-error.
    if not available tt-stock then do:
      create tt-stock.
      assign
        tt-stock.obj-type   = parobj-type
        tt-stock.obj-code   = parobj-code
        tt-stock.host-code  = parhost-code
        tt-stock.host-name  = parhost-name
        tt-stock.artic      = parartic
        tt-stock.prod-type  = parprod-type
        tt-stock.prod-code  = parprod-code
        tt-stock.prt-code   = parprt-code
        tt-stock.level      = parlevel.
      assign
        tt-stock.data-date  = (if available bf_db-status then (if bf_sys-ctrl.db-num = bf_db-status.db-num then today else bf_db-status.stock-date) else ?)
        tt-stock.data-time  = (if available bf_db-status then (if bf_sys-ctrl.db-num = bf_db-status.db-num then time  else bf_db-status.stock-time) else ?)
        tt-stock.price-sale = parprice-sale.
    end.
    else do:
      if bf_sys-ctrl.db-num <> bf_db-status.db-num then do:
        if integer(bf_db-status.stock-date) * 86400 + bf_db-status.stock-time <
           integer(tt-stock.data-date) * 86400 + tt-stock.data-time then do:
           assign
             tt-stock.data-date = bf_db-status.stock-date
             tt-stock.data-time = bf_db-status.stock-time.
         end.
      end.
    end.
    assign
      tt-stock.fact-qnty  = tt-stock.fact-qnty + parfact-qnty
      tt-stock.free-qnty  = tt-stock.free-qnty + parfree-qnty.
  end.
end procedure.
PROCEDURE change-brw :
define variable varartic     like ub.goods.artic no-undo.
define variable varprod-type like ub.goods.prod-type no-undo.
define variable varprod-code like ub.goods.prod-code no-undo.
define variable varprt-code  like ub.prt-obj.prt-code no-undo.
define variable varobj-type  like ub.clients.obj-type no-undo.
define variable varobj-code  like ub.clients.obj-code no-undo.
define variable varrec-id as recid no-undo.
if available tt-goods then do:
  assign
    varartic = tt-goods.artic
    varprod-type = tt-goods.prod-type
    varprod-code = tt-goods.prod-code
    varprt-code = tt-goods.prt-code.
  if available tt-stock then do:
    assign
      varobj-type = tt-stock.obj-type
      varobj-code = tt-stock.obj-code.
  end.
end.
run clear-tt in this-procedure no-error.
if error-status:error then do:
  message "Ошибка при очистке временных таблиц." view-as alert-box error.
  return no-apply.
end.
run load-tt in this-procedure no-error.
if error-status:error then do:
  message "Ошибка при создании временных таблиц." view-as alert-box error.
  return no-apply.
end.
OPEN QUERY b-goods FOR EACH tt-goods use-index ford-num,        FIRST tt-cont-goods OUTER-JOIN WHERE TRUE.
OPEN QUERY b-stock FOR EACH tt-stock where tt-stock.artic     = tt-goods.artic         and                                                 tt-stock.prod-type = tt-goods.prod-type and                                                 tt-stock.prod-code = tt-goods.prod-code and                                                 tt-stock.prt-code  = tt-goods.prt-code  use-index level indexed-reposition.
find first tt-goods where tt-goods.artic     = varartic     and
                          tt-goods.prod-type = varprod-type and
                          tt-goods.prod-code = varprod-code and
                          tt-goods.prt-code  = varprt-code  no-error.
if available tt-goods then do:
  assign
    varrec-id = recid(tt-goods).
  reposition b-goods to recid varrec-id no-error.
  apply "value-changed" to browse b-goods.
  find first tt-stock where tt-stock.obj-type  = varobj-type  and
                            tt-stock.obj-code  = varobj-code  and
                            tt-stock.artic     = varartic     and
                            tt-stock.prod-type = varprod-type and
                            tt-stock.prod-code = varprod-code and
                            tt-stock.prt-code  = varprt-code  no-error.
  if available tt-stock then do:
    assign
      varrec-id = recid(tt-stock).
    reposition b-stock to recid varrec-id no-error.
  end.
end.
END PROCEDURE.
PROCEDURE clear-tt :
for each tt-goods:
  delete tt-goods.
end.
for each tt-stock:
  delete tt-stock.
end.
END PROCEDURE.
PROCEDURE create-tt-goods :
define input parameter parartic like  ub.prt-obj.artic  no-undo.
define input parameter parprod-type like ub.prt-obj.prod-type no-undo.
define input parameter parprod-code like ub.prt-obj.prod-code no-undo.
define input parameter parprt-code  like ub.prt-obj.prt-code no-undo.
define output parameter parrec-id as recid no-undo.
define buffer bf_client       for ub.clients.
define buffer bf_gds-grp      for ub.gds-grp.
define buffer bf_gds-prt      for ub.gds-prt.
define buffer bf_goods        for ub.goods.
define buffer bf_prod-clients for ub.clients.
define variable varupper-code like ub.gds-prt.node-code no-undo.
define variable vargrp-name as   character           no-undo.
find first tt-goods where tt-goods.artic     = parartic     and
                          tt-goods.prod-type = parprod-type and
                          tt-goods.prod-code = parprod-code and
                          tt-goods.prt-code  = parprt-code  no-error.
if not available tt-goods then do:
  create tt-goods.
  assign
  tt-goods.artic     = parartic
  tt-goods.prod-type = parprod-type
  tt-goods.prod-code = parprod-code
  tt-goods.prt-code  = parprt-code .
  find first bf_goods where bf_goods.artic     = tt-goods.artic     and
                            bf_goods.prod-type = tt-goods.prod-type and
                            bf_goods.prod-code = tt-goods.prod-code no-lock.
  find first bf_gds-prt where bf_gds-prt.node-code = parprt-code no-lock.
  assign
     tt-goods.gds-name  = bf_goods.gds-name
     tt-goods.prt-name  = bf_gds-prt.f-name
     tt-goods.unit-base = bf_goods.unit-base
     tt-goods.unit-base = bf_goods.unit-base.
  find first bf_prod-clients where bf_prod-clients.obj-type = bf_goods.prod-type and
                                   bf_prod-clients.obj-code = bf_goods.prod-code no-lock.
  assign
    tt-goods.prod-name = bf_prod-clients.obj-name.
  if bf_gds-prt.node-name <> '_Пустая шкала':U then do:
    assign
      tt-goods.prt-name = bf_gds-prt.f-name.
    if length(tt-goods.prt-name) > 20 then do:
      assign tt-goods.prt-name = "..." + substring(tt-goods.prt-name, 4 + (length(tt-goods.prt-name) - 20)).
    end.
  end.
  assign
    tt-goods.prt-root = bf_gds-prt.prt-root.
  repeat :
    case bf_gds-prt.lvl-num:
      when 0 then do:
        assign tt-goods.ford-num-0 = bf_gds-prt.prt-num.
      end.
      when 1 then do:
        assign tt-goods.ford-num-1 = bf_gds-prt.prt-num.
      end.
      when 2 then do:
        assign tt-goods.ford-num-2 = bf_gds-prt.prt-num.
      end.
    end.
    if bf_gds-prt.lvl-num = 0 then do:
      leave.
    end.
    else do:
      assign varupper-code = bf_gds-prt.upper-code.
      find first bf_gds-prt where bf_gds-prt.node-code  = varupper-code.
    end.
  end.
  find first bf_gds-grp where bf_gds-grp.node-code = bf_goods.grp-code no-lock.
  run full-grp in this-procedure (input bf_gds-grp.node-code, input-output vargrp-name) no-error.
  if error-status :error then do:
    assign
      tt-goods.grp-name = "Ошибка!!!.".
  end.
  assign
    tt-goods.grp-name = vargrp-name.
end.
assign
  parrec-id = recid(tt-goods).
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY varartic vargds-name varb-c vargds-cnt
      WITH FRAME Dialog-Frame.
  ENABLE b-goods b-exit b-requery b-requery-prt b-admin b-help vargds-name
         varb-c b-stock vargds-cnt
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  OPEN QUERY b-goods FOR EACH tt-goods use-index ford-num,        FIRST tt-cont-goods OUTER-JOIN WHERE TRUE.    OPEN QUERY b-stock FOR EACH tt-stock where tt-stock.artic     = tt-goods.artic         and                                                 tt-stock.prod-type = tt-goods.prod-type and                                                 tt-stock.prod-code = tt-goods.prod-code and                                                 tt-stock.prt-code  = tt-goods.prt-code  use-index level indexed-reposition.
END PROCEDURE.
PROCEDURE load-tt :
define variable varobj-type like ub.clients.obj-type no-undo.
define variable varobj-code like ub.clients.obj-code no-undo.
define variable parrec-id as recid no-undo.
define buffer bf_prt-obj      for ub.prt-obj.
run waitfram-show in this-procedure
  (input "Подготовка остатков товаров для просмотра"
  ).
for each tt-usrstko no-lock,
   each bf_prt-obj where bf_prt-obj.obj-type = tt-usrstko.obj-type and
                         bf_prt-obj.obj-code = tt-usrstko.obj-code no-lock :
   if bf_prt-obj.fact-qnty = 0 and
      bf_prt-obj.free-qnty = 0 then next.
  run create-tt-goods (input bf_prt-obj.artic,
                                  input bf_prt-obj.prod-type,
                                  input bf_prt-obj.prod-code,
                                  input bf_prt-obj.prt-code,
                                  output parrec-id) no-error.
    if error-status:error then do:
      message "Ошибка при создании товарной записи." view-as alert-box.
      return no-apply.
    end.
  find first tt-goods where recid(tt-goods) = parrec-id.
   assign
     tt-goods.fact-qnty = tt-goods.fact-qnty + bf_prt-obj.fact-qnty
     tt-goods.free-qnty = tt-goods.free-qnty + bf_prt-obj.free-qnty.
  run calc-stock in this-procedure
  (input tt-usrstko.obj-type,
   input tt-usrstko.obj-code,
   input tt-usrstko.db-num,
   input tt-usrstko.main-obj-type,
   input tt-usrstko.main-obj-code,
   input tt-usrstko.host-code,
   input tt-usrstko.host-name,
   input tt-usrstko.level,
   input tt-goods.artic,
   input tt-goods.prod-type,
   input tt-goods.prod-code,
   input tt-goods.prt-code,
   input bf_prt-obj.price-sale,
   input bf_prt-obj.fact-qnty,
   input bf_prt-obj.free-qnty) no-error.
  if error-status:error then do:
    message "Ошибка при подсчете остатков." view-as alert-box error.
    return error.
  end.
end.
run waitfram-hide in this-procedure .
END PROCEDURE.
