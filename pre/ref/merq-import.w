using ibs.th.str.gds.*.
using ibs.th.str.mercury.*.
using ibs.th.gbl.storage.*.
using ibs.th.bge.mercury.*.
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
DEFINE OUTPUT PARAMETER p-list AS character NO-UNDO.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Импорт товаров".
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define temp-table tt-gds-merq no-undo
  field ID             as integer
  field merc-name      like ub.goods.gds-name label "Полное наименование" format "X(100)"
  field UUID           as character label "UUID"
  field GUID_          as character label "GUID"
  field units          as character label "Ед.измерения"
  field units_th       as character label "Ед.измерения в ТН"
  field status_        as integer   label "Статус"
  field crDate         as date      label "Дата создания" format "99.99.9999"
  field update_Date    as date      label "Дата изменени" format "99.99.9999"
  field prod-type      as integer   label "Тип продукции" format ">>>>9"
  field prod-type-name as character label "Тип продукции"
  field GUID-type      as character label "GUID-type"
  field GUID-subtype   as character label "GUID-subtype"
  index pi as primary
  ID
  index name_ as word-index
  merc-name
  index merq
  GUID_
  .
PROCEDURE checkguid :
  define INPUT-output parameter guid_ as CHARACTER NO-UNDO .
  define OUTPUT parameter Msg as CHARACTER  NO-UNDO .
  def var ii      as int       no-undo.
  def var err     as logical   no-undo.
  def var str     as character no-undo.
  def var numentr as integer   no-undo.
  numentr = num-entries (guid_, "-") no-error.
  if numentr = 8
    then
  do:
    do ii = 1 to numentr:
      if length (trim (entry (ii, guid_, "-"))) <> 4
        then err = true.
      str = str + trim (entry (ii, guid_, "-")).
      if ii = 2 or ii = 3 or ii = 4 or ii = 5
        then
      do:
        str = str + "-".
      end.
    end.
    guid_ = str.
  end.
  numentr = num-entries (guid_, "-") no-error.
  do ii = 1 to numentr:
    case ii:
      when 1 then
        do:
          if length (trim (entry (ii, guid_, "-"))) <> 8
            then err = true.
        end.
      when 2 or
      when 3 or
      when 4 then
        do:
          if length (entry (ii, guid_, "-")) <> 4
            then err = true.
        end.
      when 5 then
        do:
          if length (entry (ii, guid_, "-")) <> 12
            then err = true.
        end.
    end case.
  end.
  if ii <> 6
    then err = true.
  if err then Msg = "Неверный формат GUID".
END PROCEDURE.
define variable gdsMercsubsObj as class gdsmercsubs.
define variable gdsmercstrObj  as class gdsmercstr.
define stream imp.
define stream err.
define variable v_file      as char    no-undo.
DEFINE variable text-string as char    no-undo.
DEFINE variable impc        as integer No-UNDO.
DEFINE variable imp-save    as integer No-UNDO.
DEFINE variable N-param     AS DEC     NO-UNDO.
DEFINE variable log-save    as log     no-undo.
define BUFFER buf_goods      for ub.goods .
define buffer buf_goods-attr for ub.goods-attr .
define temp-table tt-gds-answer no-undo like tt-gds-merq .
DEFINE BUTTON B-exit AUTO-GO
  LABEL "&Выполнить"
  SIZE 10 BY 1
  BGCOLOR 8 .
DEFINE BUTTON B-file
  IMAGE-UP FILE "btn-down-arrow":U
  IMAGE-DOWN FILE "btn-down-arrow":U
  IMAGE-INSENSITIVE FILE "btn-down-arrow":U
  LABEL ""
  SIZE 3 BY 1.
DEFINE BUTTON B-Help
  LABEL "Помо&щь"
  SIZE 3 BY 1
  BGCOLOR 8 .
DEFINE BUTTON b-quit AUTO-END-KEY
  LABEL "&Отмена"
  SIZE 10 BY 1
  BGCOLOR 8 .
DEFINE VARIABLE file-name AS CHARACTER FORMAT "X(256)":U
  LABEL "Файл для импорта"
  VIEW-AS FILL-IN
  SIZE 35.88 BY 1 NO-UNDO.
DEFINE FRAME Dialog-Frame
  B-exit AT ROW 1 COL 1
  b-quit AT ROW 1 COL 11
  B-Help AT ROW 1 COL 58
  file-name AT ROW 3.42 COL 1.38 WIDGET-ID 16
  B-file AT ROW 3.42 COL 55.75 WIDGET-ID 20
  SPACE(2.99) SKIP(2.36)
  WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
  SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
  TITLE "Импорт товаров"
  DEFAULT-BUTTON B-exit.
ASSIGN
  FRAME Dialog-Frame:SCROLLABLE = FALSE
  FRAME Dialog-Frame:HIDDEN     = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
  DO:
    APPLY "END-ERROR":U TO SELF.
  END.
ON CHOOSE OF B-exit IN FRAME Dialog-Frame
  DO:
    if  trim(file-name) = "" then
    do:
      message "Не задан файл для импорта "
        view-as alert-box ERROR.
      return no-apply.
    end.
    RUN proc-save IN THIS-PROCEDURE NO-ERROR.
    IF ERROR-STATUS:error THEN RETURN NO-APPLY.
  END.
ON CHOOSE OF B-file IN FRAME Dialog-Frame
  DO:
    DEF VAR ll_commit AS LOG NO-UNDO INIT NO.
    SYSTEM-DIALOG GET-FILE v_file
      TITLE "Выберите файл для импорта"
      FILTERS "Текстовый файл (*.txt)" "*.txt"
      MUST-EXIST
      USE-FILENAME
      .
    ASSIGN
      file-name = ( IF SEARCH( v_file ) = ? THEN v_file ELSE SEARCH( v_file ) ).
    DISP file-name WITH FRAME Dialog-Frame.
  END.
ON LEAVE OF file-name IN FRAME Dialog-Frame
  DO:
    ASSIGN file-name.
    IF SEARCH( file-name ) <> ? AND SEARCH( file-name ) <> "":U THEN
    DO:
      ASSIGN
        FILE-INFO:FILE-NAME = file-name.
      IF FILE-INFO:FULL-PATHNAME <> ? THEN ASSIGN file-name = FILE-INFO:FULL-PATHNAME.
      DISP file-name WITH FRAME Dialog-Frame.
    END.
  END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
  THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  RUN enable_UI IN THIS-PROCEDURE.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY file-name
    WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Help file-name B-file
    WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE proc-save :
  define variable gdsMercsubsObj as class     gdsmercsubs.
  define variable gdsMercObj     as class     gdsmercsub.
  define variable gdsmercstrObj  as class     gdsmercstr.
  define variable ii             as integer   no-undo .
  DEFINE VARIABLE V-GUID         AS CHARACTER NO-UNDO .
  define VARIABLE Msg            as character no-undo .
  empty TEMP-TABLE tt-gds-answer .
  gdsMercsubsObj = new gdsmercsubs ().
  gdsmercstrObj = new gdsmercstr ().
  gdsMercObj = new gdsmercsub().
  input stream imp from value (file-name) .
  repeat:
    IMPORT stream imp UNFORMATTED text-string .
    if trim(text-string) = "" then   leave.
    impc = impc + 1.
    if num-entries (text-string, ";") < 3 then
    do:
      N-param = num-entries (text-string, ";").
      OUTPUT stream Err TO value ("Imp_mercur.err") append.
      put stream Err unformatted
        string(today, "99/99/9999") " "
        string(time, "HH:MM")
        " Неправильное число параметров в строке, должно быть 3 "  N-param skip.
      export stream  Err text-string .
      output stream Err close.
      next.
    end.
    find first buf_goods NO-LOCK where buf_goods.gds-code = INTEGER (ENTRY( 1, text-string, ";")) no-error .
    if not AVAILABLE (buf_goods) then
    do:
      find FIRST buf_goods  NO-LOCK where buf_goods.artic = ENTRY( 2, text-string, ";") no-error .
      if not AVAILABLE (buf_goods) then
      do:
        OUTPUT stream Err TO value ("Imp_mercur.err") append.
        put stream Err unformatted
          string(today, "99/99/9999") " "
          string(time, "HH:MM")
          " Нет товара с таким кодом и артикулом"  skip.
        export stream  Err text-string .
        output stream Err close.
        next.
      end.
    end.
    else
    do:
      find first buf_goods-attr no-lock where buf_goods-attr.gds-code = buf_goods.gds-code and buf_goods-attr.attr-code = 'mercur_FGIS':U
        and buf_goods-attr.attr-value = "yes" no-error .
      if not AVAILABLE (buf_goods-attr) then
      do:
        OUTPUT stream Err TO value ("Imp_mercur.err") append.
        put stream Err unformatted
          string(today, "99/99/9999") " "
          string(time, "HH:MM")
          " У товара нет атрибута - не загружен"  skip.
        export stream  Err text-string .
        output stream Err close.
        next.
      end.
      else
      do:
        V-GUID = ENTRY( 3, text-string, ";") .
        run checkguid(INPUT-OUTPUT V-GUID,OUTPUT Msg) no-error .
        if Msg <> "" then
        do:
          OUTPUT stream Err TO value ("Imp_mercur.err") append.
          put stream Err unformatted
            string(today, "99/99/9999") " "
            string(time, "HH:MM")
            " Неверный формат поля GUID - не загружен" skip.
          export stream  Err text-string .
          output stream Err close.
          next.
        end.
        p-list = p-list + "," + STRING (buf_goods-attr.gds-code) .
        gdsMercsubsObj = gdsmercstrObj:getgdsmercs(buf_goods-attr.gds-code).
        if VALID-OBJECT (gdsMercsubsObj:GdsMercsubsCurr) then
        do:
          do ii = 1 to gdsMercsubsObj:GetItem (ii):
            gdsMercObj = gdsMercsubsObj:GdsMercsubsCurr.
          end.
          gdsMercObj:GUID_       = V-GUID .
          gdsmercstrObj:updateDB(gdsMercObj).
          OUTPUT stream Err TO value ("Imp_mercur.err") append.
          put stream Err unformatted
            string(today, "99/99/9999") " "
            string(time, "HH:MM")
            " Изменили GUID у товара" skip.
          export stream  Err text-string .
          output stream Err close.
          next.
        end.
        else
        do:
          gdsMercObj = new gdsmercsub().
          gdsMercObj:GUID_       = V-GUID .
          gdsMercObj:GdsCode     = buf_goods-attr.gds-code .
          gdsmercstrObj:insertDB(gdsMercObj).
        end.
      end.
      display
        impc  label "Прочитано"
        text-string format "x(40)" label "Строка файла"
        with frame ff view-as dialog-box
        title ": Импорт справочника товаров из файла".
      pause 0.
    end.
  end.
  input stream imp close.
  p-list = TRIM (p-list) .
  message ("Импорт из файла " + file-name + " закончен, прочитано " + string(impc) +
    ",  " ) skip
    "Все строки из файла которые не удалось импортировать можно посмотреть в файле Imp_goods.err "
    view-as alert-box  .
  delete object gdsMercObj no-error .
  delete object gdsmercstrObj no-error .
  delete object gdsMercsubsObj no-error .
END PROCEDURE.
PROCEDURE send-news :
  for each ub.gds-mercury EXCLUSIVE-LOCK:
    run str/callnews.p
      (input 'gds-mercury':U
      ,input (buffer ub.gds-mercury:handle)
      ) no-error .
    if error-status :error then
    do:
      message
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box.
      return error.
    end.
  end.
END PROCEDURE.
