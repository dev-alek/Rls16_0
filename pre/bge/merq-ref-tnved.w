DEFINE TEMP-TABLE tt-tnved-item NO-UNDO
       field mark as character
       field tnved-code as integer
       field tnved-item-code as character
       field tnved-item-name as character
       field whole-send-news as integer
       field parent-code as character
       field tnved-code-list as character
       field disp-order as integer
       field disp-order-str as character
       field typp-code as character
       field typp-name as character
       field prod-code as character
       field kind-code as character
       index pi is primary unique tnved-code tnved-item-code
       index i1 tnved-item-code whole-send-news.
define input parameter parparentproc as handle no-undo .
define input parameter p-mode as character no-undo .
define input parameter p-selected-uuid as character no-undo .
define variable vss-revision               as character no-undo init "$Revision$":U .
define variable vss-author                 as character no-undo init "$Author$":U .
define variable vss-date                   as character no-undo init "$Date$":U .
define variable vss-workfile               as character no-undo init "$Workfile$":U .
define variable vss-archive                as character no-undo init "$Archive$":U .
define variable vss-description            as character no-undo init "Справочник типов продукции".
define temp-table tt-imp
  field fl01       as character
  field typp-name  as character
  field typp-code  as character
  field prod-name  as character
  field prod-tnved as character
  field prod-code  as character
  field kind-name  as character
  field kind-tnved as character
  field kind-code  as character
.
define stream f-imp .
define temp-table tt-tnved-item-imp      no-undo like ub.tnved-item .
define temp-table tt-tnved-item-attr-imp no-undo like ub.tnved-item-attr .
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
DEFINE BUTTON Btn_Cancel AUTO-END-KEY
     LABEL "Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON btn_import
     LABEL "Импорт"
     SIZE 10 BY 1.
DEFINE BUTTON Btn_mark
     LABEL "*"
     SIZE 3 BY 1.
DEFINE BUTTON btn_search
     LABEL "Поиск"
     SIZE 10 BY 1.
DEFINE BUTTON b-sel AUTO-GO
     LABEL "Выбор"
     SIZE 10 BY 1.
DEFINE VARIABLE fi-search AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 30 BY 1
     FGCOLOR 1  NO-UNDO.
DEFINE QUERY BROWSE-2 FOR
      tt-tnved-item SCROLLING.
DEFINE BROWSE BROWSE-2
  QUERY BROWSE-2 NO-LOCK DISPLAY
      tt-tnved-item.mark format "x(1)" no-label
      tt-tnved-item.tnved-item-name format "x(80)" column-label "Наименование продукции и вида продукции"
      tt-tnved-item.tnved-code-list format "x(19)" column-label "Коды ТН ВЭД"
      tt-tnved-item.typp-name format "x(20)" column-label "Тип продукции"
    WITH SEPARATORS SIZE 130 BY 20 FIT-LAST-COLUMN.
DEFINE FRAME Dialog-Frame
     Btn_Cancel AT ROW 1 COL 1
     Btn_mark AT ROW 1 COL 12
     b-sel AT ROW 1 COL 16
     btn_import AT ROW 1 COL 27
     btn_search AT ROW 1 COL 38
     fi-search AT ROW 1 COL 49 NO-LABEL
     BROWSE-2 AT ROW 2.91 COL 2 WIDGET-ID 200
     SPACE(1.24) SKIP(2.93)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Справочник типов продукции"
         CANCEL-BUTTON Btn_Cancel WIDGET-ID 100.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       BROWSE-2:NUM-LOCKED-COLUMNS         = 1
       BROWSE-2:COLUMN-RESIZABLE IN FRAME Dialog-Frame       = TRUE.
ON window-close OF FRAME Dialog-Frame
do:
    apply "END-ERROR":U to self.
end.
ON CHOOSE OF b-sel IN FRAME Dialog-Frame
DO:
define buffer buf_tt-tnved-typp-name for tt-tnved-item .
  p-selected-uuid = "" .
  for each tt-tnved-item
     where tt-tnved-item.mark = "*"
    while length(p-selected-uuid) < 15000
  :
    find first buf_tt-tnved-typp-name where buf_tt-tnved-typp-name.tnved-item-code = tt-tnved-item.parent-code no-error .
    if available buf_tt-tnved-typp-name then
      p-selected-uuid = substitute("&1,&2,&3,&4"
      , buf_tt-tnved-typp-name.typp-code
      , buf_tt-tnved-typp-name.typp-name
      , tt-tnved-item.parent-code
      , tt-tnved-item.tnved-item-code
    ) . else
      p-selected-uuid = substitute(",,&1,&2"
      , tt-tnved-item.parent-code
      , tt-tnved-item.tnved-item-code
    ) .
    leave .
  end .
  apply "GO" to FRAME Dialog-Frame .
END.
ON GO OF FRAME Dialog-Frame
DO:
END.
ON CHOOSE OF btn_import IN FRAME Dialog-Frame
DO:
define variable v-imp-fname as character no-undo .
define variable v-ok        as logical no-undo .
  system-dialog get-file v-imp-fname
    filters "Файлы импорта справочника (*.csv)" "*.csv",
            "Все файлы (*.*)" "*.*"
    title "Выберите файл для импорта справочника"
    update v-ok
  .
  if v-ok then do:
    run import-file in this-procedure (v-imp-fname) .
    run load-tt-tnved in this-procedure.
    run refresh-view.
  end .
END.
ON choose OF Btn_mark IN FRAME Dialog-Frame
do:
  define variable varlog as logical no-undo .
  if available tt-tnved-item then do :
    if tt-tnved-item.mark = "*" then tt-tnved-item.mark = "" .
                                else tt-tnved-item.mark = "*" .
    if can-find (first tt-tnved-item where tt-tnved-item.mark > "") then do:
      ENABLE b-sel WITH FRAME Dialog-Frame.
    end .
    else do:
      DISABLE b-sel WITH FRAME Dialog-Frame.
    end.
    varlog = BROWSE-2:refresh () .
    varlog = BROWSE-2:select-next-row () .
    apply "entry" to BROWSE-2 in frame Dialog-Frame.
  end .
end.
ON CHOOSE OF btn_search IN FRAME Dialog-Frame
DO:
    run find-in-browse in this-procedure (
        input fi-search :screen-value
    ) no-error.
    if error-status :error then do:
        message
          vss-workfile vss-revision vss-description
          skip "Ошибка поиска."
          skip return-value
          skip error-status :get-message(1)
          skip error-status :get-message(2)
          skip error-status :get-message(3)
          skip error-status :get-message(4)
          skip error-status :get-message(5)
        view-as alert-box error.
        undo, return no-apply.
    end.
END.
ON RETURN OF fi-search IN FRAME Dialog-Frame
DO:
    if fi-search :screen-value > "" then apply "choose" to btn_search in frame Dialog-Frame .
END.
ON VALUE-CHANGED OF BROWSE-2 IN FRAME Dialog-Frame
DO:
  define variable v-is-active as logical no-undo .
  if p-mode = 'ПРОСМОТР':U then do :
    v-is-active = false .
    if available tt-tnved-item then do:
      v-is-active = (tt-tnved-item.kind-code > "") .
    end .
    Btn_mark:SENSITIVE = v-is-active .
  end .
END.
if valid-handle(active-window) and frame Dialog-Frame:PARENT eq ?
  then frame Dialog-Frame:PARENT = active-window.
MAIN-BLOCK:
do on error undo MAIN-BLOCK, leave MAIN-BLOCK
   on end-key undo MAIN-BLOCK, leave MAIN-BLOCK:
  run enable_UI.
  case p-mode:
    when 'ПРОСМОТР':U then do:
      DISABLE btn_import WITH FRAME Dialog-Frame.
    end .
    when 'ИЗМЕНЕНИЕ':U then do:
      DISABLE Btn_mark b-sel WITH FRAME Dialog-Frame.
    end .
  end case .
  run load-tt-tnved in this-procedure.
  if p-selected-uuid > "" then do:
    define variable v-selected-uuid as character no-undo .
    v-selected-uuid = entry(1, p-selected-uuid) .
    find first tt-tnved-item where tt-tnved-item.tnved-item-code = v-selected-uuid no-error.
    if available tt-tnved-item then tt-tnved-item.mark = "*" .
    else do:
      DISABLE b-sel WITH FRAME Dialog-Frame.
    end .
  end .
  else do:
    DISABLE b-sel WITH FRAME Dialog-Frame.
  end .
  run refresh-view.
  wait-for go of frame Dialog-Frame.
end.
run disable_UI.
return p-selected-uuid .
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  ENABLE Btn_Cancel Btn_mark b-sel btn_import btn_search fi-search BROWSE-2
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  OPEN QUERY BROWSE-2 FOR EACH tt-tnved-item NO-LOCK     by tt-tnved-item.disp-order-str INDEXED-REPOSITION.
END PROCEDURE.
PROCEDURE load-arr-typp private :
define output parameter p-typp-names as character extent .
define buffer buf_typp_tnved-item        for ub.tnved-item .
define query q1 for buf_typp_tnved-item .
define variable v-size as integer no-undo .
define variable v-ind  as integer no-undo .
  extent(p-typp-names) = ? .
  if can-find (first tnved-item where tnved-item.whole-send-news = 1) then do:
    open query q1 preselect each buf_typp_tnved-item no-lock
                           where buf_typp_tnved-item.whole-send-news = 1
                              by integer(buf_typp_tnved-item.tnved-item-code) .
    get last q1.
    v-size = integer(buf_typp_tnved-item.tnved-item-code).
    extent(p-typp-names) = v-size.
    v-ind = v-size .
    do while available buf_typp_tnved-item :
      v-ind = integer(buf_typp_tnved-item.tnved-item-code) .
      p-typp-names[v-ind] = buf_typp_tnved-item.tnved-item-name .
      get prev q1.
    end .
    close query q1.
  end.
  else do:
    extent(p-typp-names) = 1.
    p-typp-names[1] = "" .
  end.
end procedure.
PROCEDURE load-tt-tnved :
define variable v-num-order as integer no-undo .
define buffer buf2_tnved-item        for ub.tnved-item .
define buffer buf2_tnved-item-attr-a for ub.tnved-item-attr .
define buffer buf2_tnved-item-attr-b for ub.tnved-item-attr .
define buffer buf2_tnved-item-attr-c for ub.tnved-item-attr .
define variable v-wait-msg   as character no-undo .
define variable v-ln-prev    as integer no-undo .
define variable v-tm-prev    as integer no-undo .
define variable v-tm-curr    as integer no-undo .
define variable v-lines      as integer no-undo .
define variable v-typp-names as character extent .
define variable v-name-ind   as integer no-undo .
define variable v-item-level as integer no-undo .
  assign
    v-wait-msg = "Чтение справочника типов продукции. Строк прочитано: &1"
    v-num-order = 0
    v-lines    = 0
    v-ln-prev  = v-num-order + 100
    v-tm-prev  = time + 1
  .
  run waitfram-show in this-procedure ("Чтение справочника типов продукции.") .
  empty temp-table tt-tnved-item .
  run load-arr-typp in this-procedure (output v-typp-names) .
  for each buf2_tnved-item-attr-a no-lock
     where buf2_tnved-item-attr-a.tnved-code = 0
  break by buf2_tnved-item-attr-a.tnved-code
        by buf2_tnved-item-attr-a.tnved-item-code :
    v-lines = v-lines + 1 .
    if v-lines > v-ln-prev then do:
      v-ln-prev = v-lines + 100.
      v-tm-curr = time.
      if v-tm-prev < v-tm-curr then do:
        v-tm-prev  = v-tm-curr + 1 .
        run waitfram-show in this-procedure (substitute(v-wait-msg, v-lines)) .
      end .
    end.
    if first-of (buf2_tnved-item-attr-a.tnved-item-code) then do :
      find first buf2_tnved-item no-lock
           where buf2_tnved-item.tnved-code      = buf2_tnved-item-attr-a.tnved-code
             and buf2_tnved-item.tnved-item-code = buf2_tnved-item-attr-a.tnved-item-code
             and buf2_tnved-item.whole-send-news > 1 no-error .
      if available buf2_tnved-item then do:
        create tt-tnved-item .
        assign
          tt-tnved-item.mark            = ""
          tt-tnved-item.disp-order      = 0
          tt-tnved-item.tnved-code      = buf2_tnved-item.tnved-code
          tt-tnved-item.tnved-item-code = buf2_tnved-item.tnved-item-code
          tt-tnved-item.whole-send-news = buf2_tnved-item.whole-send-news
          tt-tnved-item.tnved-item-name =
            if buf2_tnved-item.whole-send-news = 2
                                   then                      buf2_tnved-item.tnved-item-name
                                   else substitute("    &1", buf2_tnved-item.tnved-item-name)
          v-item-level = buf2_tnved-item.whole-send-news
        .
      end .
      else v-item-level = 1 .
    end .
    if v-item-level > 1 then do:
      case buf2_tnved-item-attr-a.attr-code :
        when "parent-code" then do:
          tt-tnved-item.parent-code = buf2_tnved-item-attr-a.attr-value .
          case v-item-level :
            when 2 then do:
              assign
                tt-tnved-item.typp-code       = tt-tnved-item.parent-code
                tt-tnved-item.prod-code       = tt-tnved-item.tnved-item-code
                tt-tnved-item.kind-code       = ""
              .
              v-name-ind = integer(tt-tnved-item.parent-code) no-error.
              tt-tnved-item.typp-name = if v-name-ind > 0 then v-typp-names[v-name-ind] else "" .
            end .
            when 3 then do:
              assign
                tt-tnved-item.typp-code       = ""
                tt-tnved-item.prod-code       = tt-tnved-item.parent-code
                tt-tnved-item.kind-code       = tt-tnved-item.tnved-item-code
              .
            end .
            otherwise .
          end case .
        end .
        when "tnved-code" then tt-tnved-item.tnved-code-list = buf2_tnved-item-attr-a.attr-value .
        when "order-str" then tt-tnved-item.disp-order-str  = buf2_tnved-item-attr-a.attr-value .
        otherwise .
      end case.
    end .
  end .
  extent(v-typp-names) = ?.
  run waitfram-hide in this-procedure.
END PROCEDURE.
PROCEDURE find-in-browse :
define input parameter p-search-str as character no-undo .
define variable v-search-str  as character no-undo .
define variable v-is-found    as logical no-undo .
define variable v-focused-row as integer no-undo .
define buffer buf_tt-tnved-item for tt-tnved-item .
define query q_brw-2 for buf_tt-tnved-item .
  if not available tt-tnved-item then return .
  assign
    v-is-found   = false
    v-search-str = substitute("*&1*", p-search-str)
    v-focused-row = BROWSE-2 :focused-row in frame Dialog-Frame
  .
  open query q_brw-2
    FOR EACH buf_tt-tnved-item
       where buf_tt-tnved-item.tnved-item-name matches v-search-str
          by buf_tt-tnved-item.disp-order-str .
  repeat :
    get next q_brw-2 .
    if not available buf_tt-tnved-item then leave .
    if buf_tt-tnved-item.disp-order-str > tt-tnved-item.disp-order-str then do:
      BROWSE-2 :set-repositioned-row(v-focused-row, "ALWAYS") in frame Dialog-Frame.
      reposition BROWSE-2 to rowid rowid ( buf_tt-tnved-item ).
      v-is-found = true .
      leave .
    end .
  end .
  if not v-is-found then do :
    get first q_brw-2 .
    if available buf_tt-tnved-item then do:
      BROWSE-2 :set-repositioned-row(v-focused-row, "ALWAYS") in frame Dialog-Frame.
      reposition BROWSE-2 to rowid rowid ( buf_tt-tnved-item ).
      v-is-found = true .
    end .
  end .
  close query q_brw-2 .
  if not v-is-found then do:
    message substitute("Запись не найдена.") view-as alert-box .
  end .
end procedure.
PROCEDURE proc-row-disp :
end.
PROCEDURE refresh-view :
    OPEN QUERY BROWSE-2 FOR EACH tt-tnved-item NO-LOCK     by tt-tnved-item.disp-order-str INDEXED-REPOSITION.
end.
PROCEDURE reopen-browse :
  run refresh-view.
end.
PROCEDURE import-file :
define input parameter p-imp-file-name as character no-undo .
define buffer buf1_tnved-item      for tt-tnved-item-imp .
define buffer buf1_tnved-item-attr for tt-tnved-item-attr-imp .
define buffer buf2_tnved-item      for tt-tnved-item-imp .
define buffer buf2_tnved-item-attr for tt-tnved-item-attr-imp .
define buffer buf3_tnved-item      for tt-tnved-item-imp .
define buffer buf3_tnved-item-attr for tt-tnved-item-attr-imp .
define variable v-imp-row   as character no-undo .
define variable v-str-typp-code as character no-undo .
define variable v-str-prod-code as character no-undo .
define variable v-str-kind-code as character no-undo .
define variable v-srt-prod-code as character no-undo .
define variable v-srt-kind-code as character no-undo .
define variable v-wait-msg   as character no-undo .
define variable v-lines      as integer no-undo .
define variable v-ln-prev    as integer no-undo .
define variable v-tm-prev    as integer no-undo .
define variable v-tm-curr    as integer no-undo .
  empty temp-table tt-tnved-item-imp  .
  empty temp-table tt-tnved-item-attr-imp .
  do transaction on error undo, return error string(os-error):
    input stream f-imp from value(p-imp-file-name) .
  end .
  assign
    v-wait-msg = "Импорт справочника типов продукции. Строк прочитано: &1"
    v-lines    = 0
    v-ln-prev  = v-lines + 100
    v-tm-prev  = time + 1
  .
  run waitfram-show in this-procedure ("Импорт справочника типов продукции.") .
  import stream f-imp unformatted v-imp-row .
  repeat on endkey undo, leave
         on error undo, leave :
    v-lines = v-lines + 1 .
    if v-lines > v-ln-prev then do:
      v-ln-prev = v-lines + 100.
      v-tm-curr = time.
      if v-tm-prev < v-tm-curr then do:
        v-tm-prev  = v-tm-curr + 1 .
        run waitfram-show in this-procedure (substitute(v-wait-msg, v-lines)) .
      end .
    end.
    empty temp-table tt-imp .
    create tt-imp .
    import stream f-imp DELIMITER ';' tt-imp .
    v-str-typp-code = trim(tt-imp.typp-code) .
    if not can-find (first buf1_tnved-item where buf1_tnved-item.tnved-item-code = v-str-typp-code
                                          and buf1_tnved-item.whole-send-news = 1) then do:
      create buf1_tnved-item .
      assign
        buf1_tnved-item.tnved-code      = 0
        buf1_tnved-item.whole-send-news = 1
        buf1_tnved-item.tnved-item-code = v-str-typp-code
        buf1_tnved-item.tnved-item-name = trim(tt-imp.typp-name)
      .
    end .
    v-str-prod-code = trim(tt-imp.prod-code) .
    if not can-find (first buf2_tnved-item where buf2_tnved-item.tnved-item-code = v-str-prod-code
                                          and buf2_tnved-item.whole-send-news = 2) then do:
      v-srt-prod-code = string(v-lines, "999999999") .
      create buf2_tnved-item .
      assign
        buf2_tnved-item.tnved-code      = 0
        buf2_tnved-item.whole-send-news = 2
        buf2_tnved-item.tnved-item-code = v-str-prod-code
        buf2_tnved-item.tnved-item-name = trim(tt-imp.prod-name)
      .
      create buf2_tnved-item-attr .
      assign
        buf2_tnved-item-attr.tnved-code      = buf2_tnved-item.tnved-code
        buf2_tnved-item-attr.tnved-item-code = buf2_tnved-item.tnved-item-code
        buf2_tnved-item-attr.attr-code       = "tnved-code"
        buf2_tnved-item-attr.attr-value      = trim(tt-imp.prod-tnved)
      .
      create buf2_tnved-item-attr .
      assign
        buf2_tnved-item-attr.tnved-code      = buf2_tnved-item.tnved-code
        buf2_tnved-item-attr.tnved-item-code = buf2_tnved-item.tnved-item-code
        buf2_tnved-item-attr.attr-code       = "parent-code"
        buf2_tnved-item-attr.attr-value      = v-str-typp-code
      .
      create buf2_tnved-item-attr .
      assign
        buf2_tnved-item-attr.tnved-code      = buf2_tnved-item.tnved-code
        buf2_tnved-item-attr.tnved-item-code = buf2_tnved-item.tnved-item-code
        buf2_tnved-item-attr.attr-code       = "order-str"
        buf2_tnved-item-attr.attr-value      = substitute("&1,&2,&3", v-str-typp-code, v-srt-prod-code, "")
      .
    end .
    v-str-kind-code = trim(tt-imp.kind-code) .
    if not can-find (first buf3_tnved-item where buf3_tnved-item.tnved-item-code = v-str-kind-code
                                          and buf3_tnved-item.whole-send-news = 3) then do:
      v-srt-kind-code = string(v-lines, "999999999") .
      create buf3_tnved-item .
      assign
        buf3_tnved-item.tnved-code      = 0
        buf3_tnved-item.whole-send-news = 3
        buf3_tnved-item.tnved-item-code = v-str-kind-code
        buf3_tnved-item.tnved-item-name = trim(tt-imp.kind-name)
      .
      create buf3_tnved-item-attr .
      assign
        buf3_tnved-item-attr.tnved-code      = buf3_tnved-item.tnved-code
        buf3_tnved-item-attr.tnved-item-code = buf3_tnved-item.tnved-item-code
        buf3_tnved-item-attr.attr-code       = "tnved-code"
        buf3_tnved-item-attr.attr-value      = trim(tt-imp.kind-tnved)
      .
      create buf3_tnved-item-attr .
      assign
        buf3_tnved-item-attr.tnved-code      = buf3_tnved-item.tnved-code
        buf3_tnved-item-attr.tnved-item-code = buf3_tnved-item.tnved-item-code
        buf3_tnved-item-attr.attr-code       = "parent-code"
        buf3_tnved-item-attr.attr-value      = v-str-prod-code
      .
      create buf3_tnved-item-attr .
      assign
        buf3_tnved-item-attr.tnved-code      = buf3_tnved-item.tnved-code
        buf3_tnved-item-attr.tnved-item-code = buf3_tnved-item.tnved-item-code
        buf3_tnved-item-attr.attr-code       = "order-str"
        buf3_tnved-item-attr.attr-value      = substitute("&1,&2,&3", v-str-typp-code, v-srt-prod-code, v-srt-kind-code)
      .
    end .
  end.
  input stream f-imp close .
  assign
    v-wait-msg = "Импорт справочника типов продукции. Строк записано: &1"
    v-lines    = 0
    v-ln-prev  = v-lines + 100
  .
  run waitfram-show in this-procedure ("Импорт справочника типов продукции. Удаление строк.") .
  define buffer buf_tnved-item      for ub.tnved-item .
  define buffer buf_tnved-item-attr for ub.tnved-item-attr .
  define buffer buf_tt-tnved-item-imp      for tt-tnved-item-imp .
  define buffer buf_tt-tnved-item-attr-imp for tt-tnved-item-attr-imp .
  do transaction on error undo, leave:
    for each buf_tnved-item-attr exclusive-lock : delete buf_tnved-item-attr . end .
    for each buf_tnved-item      exclusive-lock : delete buf_tnved-item .      end .
  end .
  for each buf_tt-tnved-item-imp :
    v-lines = v-lines + 1 .
    if v-lines > v-ln-prev then do:
      v-ln-prev = v-lines + 100.
      v-tm-curr = time.
      if v-tm-prev < v-tm-curr then do:
        v-tm-prev  = v-tm-curr + 1 .
        run waitfram-show in this-procedure (substitute(v-wait-msg, v-lines)) .
      end .
    end.
    do transaction on error undo, leave:
      create buf_tnved-item .
      buffer-copy buf_tt-tnved-item-imp to buf_tnved-item .
    end .
  end .
  for each buf_tt-tnved-item-attr-imp :
    v-lines = v-lines + 1 .
    if v-lines > v-ln-prev then do:
      v-ln-prev = v-lines + 100.
      v-tm-curr = time.
      if v-tm-prev < v-tm-curr then do:
        v-tm-prev  = v-tm-curr + 1 .
        run waitfram-show in this-procedure (substitute(v-wait-msg, v-lines)) .
      end .
    end.
    do transaction on error undo, leave:
      create buf_tnved-item-attr .
      buffer-copy buf_tt-tnved-item-attr-imp to buf_tnved-item-attr .
    end .
  end .
  define variable vMsg as character no-undo .
  run waitfram-hide in this-procedure.
end.
