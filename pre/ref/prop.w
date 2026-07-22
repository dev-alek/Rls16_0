def input  param mode as char no-undo.
def input  param n-c  like ub.gds-prt.node-code no-undo.
def output param rid  as recid init ? no-undo.
define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Редактирование шкалы признаков".
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
DEF VAR BLACK_COLOR        AS INTEGER NO-UNDO INIT  0.
DEF VAR DARK_BLUE_COLOR    AS INTEGER NO-UNDO INIT  1.
DEF VAR DARK_GREEN_COLOR   AS INTEGER NO-UNDO INIT  2.
DEF VAR CYAN_COLOR         AS INTEGER NO-UNDO INIT  3.
DEF VAR BROWN_COLOR        AS INTEGER NO-UNDO INIT  4.
DEF VAR DARK_GRAY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR DARK_GREY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR VERY_GRAY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR VERY_GREY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR GRAY_COLOR         AS INTEGER NO-UNDO INIT  8.
DEF VAR GREY_COLOR         AS INTEGER NO-UNDO INIT  8.
DEF VAR BLUE_COLOR         AS INTEGER NO-UNDO INIT  9.
DEF VAR GREEN_COLOR        AS INTEGER NO-UNDO INIT 10.
DEF VAR RED_COLOR          AS INTEGER NO-UNDO INIT 12.
DEF VAR LIGHT_RED_COLOR    AS INTEGER NO-UNDO INIT 13.
DEF VAR YELLOW_COLOR       AS INTEGER NO-UNDO INIT 14.
DEF VAR WHITE_COLOR        AS INTEGER NO-UNDO INIT 15.
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
def var sc-name like ub.gds-prt.node-name format "x(40)" label "Название шкалы" no-undo.
def var ld-n     as int no-undo.
def var prt_root as int no-undo.
def var v-ind    as integer no-undo .
define variable v-ok as logical   no-undo .
def temp-table ld no-undo
    field num  as integer
    field ord  as integer
    field name like ub.gds-prt.node-name
    index num is primary unique num .
def temp-table nd no-undo
    field num  as integer
    field ord  as integer
    field name format "x(16)" like ub.gds-prt.node-name
    field new_ as logical init yes
    index num  is primary unique num ord.
def query ld for ld .
def browse ld query ld
       disp ld.name
       with size 13 by 10 no-labels title "Уровни" separators .
def query nd for nd .
def browse nd query nd
       disp nd.name
       with size 19 by 10 no-labels title "Признаки" separators .
def button b-ok auto-go default
     LABEL "&Ввод"
     SIZE 10 BY 1.
def button b-cancel  auto-endkey
    label "&Отмена"
     SIZE 10 BY 1.
def button b-help
    label "Помо&щь"
     SIZE 10 BY 1.
def button b-add-ld
    label "Добав"
     SIZE 8 BY 1.
def button b-upd-ld
    label "Изм"
     SIZE 8 BY 1.
def button b-del-ld
    label "Удал"
     SIZE 8 BY 1.
def button b-ld-up
    label "Перест"
     SIZE 8 BY 1.
def button b-add-nd
    label "Добав"
     SIZE 8 BY 1.
def button b-upd-nd
    label "Изм"
     SIZE 8 BY 1.
def button b-del-nd
    label "Удал"
     SIZE 8 BY 1.
def button b-nd-up
    label "Перест"
     SIZE 8 BY 1.
def frame td
b-ok at row 1 col 1
b-cancel at row 1 col 11
b-help at row 1 col 21
sc-name at row 2.5 col 5
ld at row 4 col 11
nd at row 4 col 47
b-add-ld at row 14.5 col 2
b-upd-ld at row 14.5 col 10
b-del-ld at row 14.5 col 18
b-ld-up at row 14.5 col 26
b-add-nd at row 14.5 col 38
b-upd-nd at row 14.5 col 46
b-del-nd at row 14.5 col 54
b-nd-up at row 14.5 col 62
with view-as dialog-box scrollable side-labels three-d default-button b-ok
title "".
on row-display of nd do:
  if available nd
  and nd.new_ then do:
    assign
      name :fgcolor in browse nd = RED_COLOR .
    .
  end.
  else do:
    assign
      name :fgcolor in browse nd = BLACK_COLOR .
    .
  end.
end.
on choose of b-ld-up do:
    def var h1 as int no-undo.
    def var h2 as int no-undo.
    def var r as recid no-undo.
    if not available ld then do:
      return no-apply.
    end.
    assign
      r = recid(ld)
      h1 = ld.num
    .
    get prev  ld.
    if not available ld then do:
      return no-apply.
    end.
    assign
      h2 = ld.num
      ld.num = -2
    .
    find ld where recid( ld ) = r.
    assign
      ld.num  = h2
    .
    find ld where ld.num = -2 .
    assign
      ld.num  = h1
    .
    for each nd
      where nd.num = h2
    :
      assign
        nd.num = -2
      .
    end.
    for each nd
    where nd.num = h1
    :
      assign
        nd.num = h2
      .
    end.
    for each nd
      where nd.num = - 2
    :
      assign
        nd.num = h1
      .
    end.
    open query ld for each ld.
    reposition ld to recid r.
    define variable v-ok as logical   no-undo .
    assign
      v-ok = ld:select-focused-row( )
    .
    apply "value-changed":U to ld.
end.
on choose of b-nd-up do:
  def var r1    as recid     no-undo .
  def var h1    as integer   no-undo .
  def var name1 as character no-undo .
  def var r2    as recid     no-undo .
  def var h2    as integer   no-undo .
  def var name2 as character no-undo .
  if not available nd then do:
    return no-apply .
  end.
  if nd.new_ <> true then do:
    message
      "Нельзя менять порядок уже созданных признаков" skip
      view-as alert-box information .
    return no-apply .
  end.
  assign
    r1    = recid(nd)
    h1    = nd.ord
    name1 = nd.name
  .
  get prev  nd.
  if not available nd then do:
    return no-apply.
  end.
  if nd.new_ <> true then do:
    message
      "Нельзя менять порядок уже созданных признаков" skip
      "Нельзя поменять местами признаки" name1 "и" nd.name skip
      view-as alert-box information .
    find nd where recid( nd ) = r1.
    return no-apply .
  end.
  assign
    r2    = recid(nd)
    h2    = nd.ord
    name2 = nd.name
  .
  find nd where recid( nd ) = r1.
  assign
    nd.ord = ?
  .
  find nd where recid( nd ) = r2.
  assign
    nd.ord = h1
  .
  find nd where recid( nd ) = r1.
  assign
    nd.ord = h2
  .
  open query nd for each nd where nd.num = ld.num.
  reposition nd to recid r1.
  define variable v-ok as logical   no-undo .
  assign
    v-ok = nd :select-focused-row( )
  .
end.
on go of frame td do:
  def var ind  as integer no-undo init 0 .
  def var max_ as integer no-undo init 0 .
  def var j    as integer no-undo .
  if sc-name :screen-value = "" then do:
    message
      "Введите название шкалы."
      view-as alert-box error.
    apply "ENTRY":U to sc-name.
    return no-apply.
  end.
  if can-find (ub.gds-prt where
              ub.gds-prt.root = yes AND
              ub.gds-prt.node-name = sc-name:screen-value no-lock) and
    (mode = 'ДОБАВЛЕНИЕ':U or
      mode = 'КОПИРОВАНИЕ':U) then do:
    message
      "Шкала с таким названием уже есть."
      view-as alert-box error.
    apply "ENTRY":U to sc-name.
    return no-apply.
  end.
  for each ld
  :
    accumulate ld (count).
    if not can-find (first nd where nd.num = ld.num) then do:
      message
        "На уровне" ld.name skip
        "нет признаков."
        view-as alert-box error.
      return no-apply.
    end.
  end.
  if (accum count ld) = 0 then do:
    message
      "В шкале не задан ни один из уровней." skip
      "В системе может быть только одна пустая шкала." skip
      view-as alert-box error.
    return no-apply.
  end.
  for each ld
  :
    for each nd
      where nd.num = ld.num
    :
      assign
        nd.num = ind
      .
    end.
    assign
      ld.num = ind
      ind    = ind + 1
    .
  end.
  if mode = 'ИЗМЕНЕНИЕ':U then do:
    find ub.gds-prt
      where ub.gds-prt.node-code = n-c
      .
    for each ld
    :
      find last nd
        where nd.num = ld.num
        use-index num .
      assign
        max_ = nd.ord
        j = 0
      .
      for each nd
        where nd.num = ld.num
          and nd.ord <= max_
        by nd.ord
      :
        assign
          j = j + 1
          nd.ord = max_ + j
        .
      end.
    end.
  end.
  run create-scale no-error.
  if error-status :error then do:
    return no-apply.
  end.
end.
on choose of b-add-ld do:
    def var rr as recid no-undo.
    run add-ld( output rr ).
    if rr <> ? then do:
       open query ld for each ld.
       reposition ld to recid rr.
       apply "value-changed":U to ld.
       define variable v-ok as logical   no-undo .
       assign
         v-ok = ld :select-focused-row( )
       .
    end.
end.
on choose of b-add-nd do:
    def var rr as recid no-undo.
    if not available ld THEN return no-apply.
    run add-nd( output rr ).
    if rr <> ? then do:
       open query nd for each nd where nd.num = ld.num.       if available nd then do:        assign           v-ok = nd:select-focused-row ()         .       end.
    end.
end.
on choose of b-ok do:
    message "Закончить ввод шкалы?" view-as alert-box question buttons yes-no
                     set OK as log .
    if not OK THEN return no-apply.
end.
on choose of b-del-nd do:
    def var  r as recid no-undo.
    def var  rr as recid no-undo.
    if not available nd THEN return.
    if nd.new_ <> true then do:
      message
        "Нельзя удалять уже созданный признак" skip
        view-as alert-box information .
      return .
    end.
     message "Удалить признак?" view-as alert-box question buttons yes-no
                      set OK as log .
     if not OK THEN return no-apply.
     r = recid( nd ).
     get prev nd.
     rr = recid( nd ).
     find nd where recid( nd )  = r.
     delete nd .
     open query nd for each nd where nd.num = ld.num.
     reposition nd to recid rr no-error.
     define variable v-ok as logical   no-undo .
     if available nd then do:
       assign
         v-ok = nd :select-focused-row() .
       .
     end.
end.
on choose of b-del-ld do:
     def var  r as recid no-undo.
     def var  rr as recid no-undo.
     if not available ld THEN return no-apply.
     message "Удалить признак?" view-as alert-box question buttons yes-no
                      set OK as log .
     if not OK THEN return no-apply.
     r = recid( ld ).
     get prev ld.
     rr = recid( ld ).
     find ld where recid( ld )  = r.
     for each nd where nd.num = ld.num:
         delete nd.
     end.
     delete ld .
     open query ld for each ld.
     reposition ld to recid rr no-error.
     define variable v-ok as logical   no-undo .
     if available ld then do:
       assign
         v-ok = ld:select-focused-row()
       .
     end.
     apply "value-changed":U to ld.
end.
on choose of b-upd-ld do:
    run upd-ld.
end.
on choose of b-upd-nd do:
    if not available nd THEN return.
    run upd-nd.
end.
ON WINDOW-CLOSE OF FRAME td APPLY "END-ERROR":U TO SELF.
on value-changed of ld in frame td do:
     open query nd for each nd where nd.num = ld.num.       if available nd then do:        assign           v-ok = nd:select-focused-row ()         .       end.
end.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame td
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
on choose of b-help in frame td
do:
  apply "help":u to frame td .
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
                v-frame-width = frame td:width - 0.3
                fh            = frame td:first-child
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
frame td :title = "Шкала.                              " + mode.
if mode = 'КОПИРОВАНИЕ':U or
   mode = 'ИЗМЕНЕНИЕ':U then do:
  find gds-prt where gds-prt.node-code = n-c.
  if gds-prt.node-name = '_Пустая шкала':U then do:
    message "Изменение пустой шкалы невозможно."
            view-as alert-box error.
    return.
  end.
  assign
    sc-name = gds-prt.node-name
    prt_root = gds-prt.upper-code
    .
  for each ub.lvl-name where ub.lvl-name.upper-code = ub.gds-prt.upper-code:
    create ld.
    assign
      ld.num = lvl-name.level
      ld.name = lvl-name.lvl-name
      .
  end.
  run prt-tree (n-c).
  disp sc-name with frame td.
end.
if mode = 'КОПИРОВАНИЕ':U or
   mode = 'ДОБАВЛЕНИЕ':U then
  enable b-add-ld b-del-ld b-upd-ld b-ld-up with frame td.
open query ld for each ld.
ld :SET-REPOSITIONED-ROW(5, "CONDITIONAL") .
nd :SET-REPOSITIONED-ROW(5, "CONDITIONAL") .
enable sc-name ld nd b-ok b-cancel b-help
       b-add-nd b-del-nd b-upd-nd b-nd-up
       with frame td.
if available ld then do:
    v-ok = ld :select-focused-row() .
    apply "value-changed":U to ld.
end.
wait-for go of frame td.
procedure prt-tree:
def input param uc like ub.gds-prt.upper-code no-undo.
def buffer b-g-p for ub.gds-prt.
def var nc         as int no-undo.
def var next-level as log no-undo.
find first b-g-p where b-g-p.upper-code = uc.
find ld where ld.num = b-g-p.lvl-num.
assign
  ld.ord = 0
  nc = b-g-p.node-code
  .
if can-find (first b-g-p where b-g-p.upper-code = nc) then
  next-level = yes.
else
  next-level = no.
for each b-g-p where b-g-p.upper-code = uc:
  if b-g-p.prt-num > ld.ord then
    ld.ord = b-g-p.prt-num.
  create nd.
  assign
    nd.num  = b-g-p.lvl-num
    nd.ord  = b-g-p.prt-num
    nd.name = b-g-p.node-name
    .
  if mode = 'ИЗМЕНЕНИЕ':U then
    nd.new_ = no.
end.
if next-level then
  run prt-tree (nc).
end procedure.
PROCEDURE create-nodes :
  define input parameter p-curr-level     like nd.num              no-undo .
  define input parameter p-upper-code     like ub.gds-prt.upper-code  no-undo .
  define input parameter p-prt-root       like ub.gds-prt.prt-root no-undo .
  define input parameter p-parent-f-name  like ub.gds-prt.f-name      no-undo .
  define input parameter p-max-level      as integer  no-undo .
  define input parameter p-subtree-create as logical  no-undo .
  define buffer buf_gds-prt  for ub.gds-prt .
  define buffer buf_goods    for ub.goods .
  define buffer buf_bar-code for ub.bar-code .
  define buffer cur-node     for nd .
  def var v-curr-f-name  as character no-undo.
  def var v-b-code like ub.bar-code.b-code no-undo .
  do
  on error undo, return error
  :
    for each cur-node
      where cur-node.num = p-curr-level
    on error undo, return error
    :
      if p-parent-f-name = "" then do:
        assign
          v-curr-f-name = cur-node.name
        .
      end.
      else do:
        assign
          v-curr-f-name = p-parent-f-name + "/" + cur-node.name
        .
      end.
      if cur-node.new_
      or p-subtree-create then do:
        assign
          v-ind = v-ind + 1
        .
        if p-curr-level = p-max-level
        and (v-ind mod 10 = 0)
        then do:
          run waitfram-show in this-procedure
            (input "Создаем узел шкалы: " + v-curr-f-name
            ).
        end.
        do transaction
        on error undo, return error
        :
          create buf_gds-prt.
          assign
            buf_gds-prt.lvl-num    = p-curr-level
            buf_gds-prt.upper-code = p-upper-code
            buf_gds-prt.node-code  = next-value (s-gds-prt, ub)
            buf_gds-prt.node-name  = cur-node.name
            buf_gds-prt.f-name     = v-curr-f-name
            buf_gds-prt.prt-num    = cur-node.ord
            buf_gds-prt.root       = false
            buf_gds-prt.prt-root   = p-prt-root
            buf_gds-prt.is-term    = (p-curr-level = p-max-level )
          .
        end.
      end.
      else do:
        if p-curr-level < p-max-level  then do:
          find first buf_gds-prt no-lock
            where buf_gds-prt.upper-code = p-upper-code
              and buf_gds-prt.node-name  = cur-node.name
            .
        end.
      end.
      if p-curr-level < p-max-level then do:
        run create-nodes in this-procedure
          (input cur-node.num + 1
          ,input buf_gds-prt.node-code
          ,input p-prt-root
          ,input v-curr-f-name
          ,input p-max-level
          ,input cur-node.new_ or p-subtree-create
          ) no-error.
        if error-status :error then do:
          undo, return error.
        end.
      end.
    end.
  end.
END PROCEDURE.
PROCEDURE create-scale :
  do
  on error undo, return error
  :
    def var v-max-level as integer no-undo .
    assign
      v-max-level = 0
    .
    for each ld
    :
      assign
        v-max-level = v-max-level + 1
      .
    end.
    if mode = 'ДОБАВЛЕНИЕ':U
    or mode = 'КОПИРОВАНИЕ':U
    then do:
      create ub.gds-prt.
      assign
        ub.gds-prt.lvl-num    = 0
        ub.gds-prt.upper-code = next-value (s-gds-prt, ub)
        ub.gds-prt.node-code  = next-value (s-gds-prt, ub)
        ub.gds-prt.node-name  = input frame td sc-name
        ub.gds-prt.prt-num    = 0
        ub.gds-prt.root       = true
        ub.gds-prt.prt-root   = ub.gds-prt.upper-code
        ub.gds-prt.is-term    = (ub.gds-prt.lvl-num = v-max-level)
        rid                = recid (gds-prt)
        prt_root           = ub.gds-prt.upper-code
      .
      for each ld :
        create ub.lvl-name.
        assign
          ub.lvl-name.level      = ld.num
          ub.lvl-name.lvl-name   = ld.name
          ub.lvl-name.upper-code = ub.gds-prt.upper-code
          .
      end.
    end.
    assign
      rid = recid (gds-prt)
      ub.gds-prt.node-name = input frame td sc-name
    .
    run create-nodes
      (input 0
      ,input gds-prt.node-code
      ,input gds-prt.prt-root
      ,input ""
      ,input v-max-level - 1
      ,input false
      ) no-error.
    if error-status :error then do:
      run waitfram-hide in this-procedure .
      undo, return error .
    end.
    run waitfram-hide in this-procedure .
  end.
END PROCEDURE.
PROCEDURE add-ld:
   def output param ri as recid no-undo init ?.
   def button b-ok  auto-go default  size 10 by 1
       label "&Ввод ".
   def button b-cancel  auto-endkey  size 10 by 1
       label "&Отмена".
    form  b-ok   at 1 b-cancel at 11 skip
            ld.name  label "Название"
            space( 0.2 ) skip( 0.2 )
            space( 0.2 )
            with frame add-ld three-d side-labels  view-as dialog-box default-button b-ok
                     title "У Р О В Е Н Ь".
    on window-close of frame add-ld apply "end-error" to self.
    on go of frame add-ld do:
        if input ld.name = "" then do:
            message "Введите название" view-as alert-box.
            return no-apply.
        end.
        if can-find( first ld where ld.name = input frame add-ld  ld.name ) then do:
            message "Уровень" input ld.name "уже есть" view-as alert-box.
            return no-apply.
        end.
        create ld.
        assign ld-n = ld-n + 1
                    ld.num  = ld-n
                    ld.name
                    ri = recid( ld ).
    end.
    enable  ld.name b-ok b-cancel with frame add-ld.
    wait-for go of frame add-ld.
END PROCEDURE.
PROCEDURE add-nd:
   def output param ri as recid no-undo init ?.
   def button b-ok  auto-go default size 10 by 1
       label "&Ввод".
   def button b-cancel  auto-endkey size 10 by 1
       label "&Отмена".
    form b-ok  at 1 b-cancel at 11
            skip
            nd.name label "Название"
            space( 0.2 ) skip( 0.2 )
            space( 0.2 )
            with frame add-nd three-d side-labels  view-as dialog-box default-button b-ok
                   title "П Р И З Н А К".
    on window-close of frame add-nd apply "end-error" to self.
    on go of frame add-nd do:
        if input nd.name = "" then do:
            message "Введите название" view-as alert-box.
            return no-apply.
        end.
        if can-find( first nd where nd.num = ld.num
                                         AND nd.name = input frame add-nd  nd.name ) then do:
            message "Признак" input nd.name "уже есть" view-as alert-box.
            return no-apply.
        end.
        create nd.
        assign ld.ord = ld.ord + 1
                    nd.ord = ld.ord
                    nd.num  = ld.num
                    nd.name
                    ri = recid( nd ).
    end.
    enable  nd.name b-ok b-cancel with frame add-nd.
    wait-for go of frame add-nd.
END PROCEDURE.
PROCEDURE upd-ld:
   def var ri as recid no-undo .
   def button b-ok  auto-go default
       label "&Ввод".
   def button b-cancel  auto-endkey
       label "&Отмена".
    form  b-ok   at 1 b-cancel at 11
            skip
            ld.name  label "Название"
            space( 0.2 ) skip( 0.2 )
            space( 0.2 )
            with frame add-ld three-d side-labels  view-as dialog-box default-button b-ok
                     title "У Р О В Е Н Ь -- изменение".
    on window-close of frame add-ld apply "end-error" to self.
    on go of frame add-ld do:
        if input ld.name = "" then do:
            message "Введите название" view-as alert-box.
            return no-apply.
        end.
        if can-find( first ld where ld.name = input frame add-ld  ld.name
                                        AND recid( ld ) <> ri ) then do:
            message "Уровень" input ld.name "уже есть" view-as alert-box.
            return no-apply.
        end.
        assign ld.name.
        disp ld.name with browse ld.
    end.
    if not available ld THEN return.
    ri = recid( ld ).
    disp ld.name with frame add-ld.
    enable  ld.name b-ok b-cancel with frame add-ld.
    wait-for go of frame add-ld.
END PROCEDURE.
PROCEDURE upd-nd:
   def var ri as recid no-undo .
   if not available nd then do:
     return .
   end.
   if nd.new_ <> true then do:
     message
       "Нельзя менять название уже созданного признака" skip
       view-as alert-box information .
     return .
   end.
   def button b-ok  auto-go default
       label "&Ввод".
   def button b-cancel  auto-endkey
       label "&Отмена".
    form  b-ok at 1 b-cancel at 11
    skip
            nd.name label "Название"
            space( 0.2 ) skip( 0.2 )
            space( 0.2 )
            with frame add-nd three-d side-labels  view-as dialog-box default-button b-ok
                   title "П Р И З Н А К -- изменение".
    on window-close of frame add-nd apply "end-error" to self.
    on go of frame add-nd do:
        if input nd.name = "" then do:
            message "Введите название" view-as alert-box.
            return no-apply.
        end.
        if can-find( first nd where nd.num = ld.num
                                         AND nd.name = input frame add-nd  nd.name
                                         AND recid( nd ) <> ri ) then do:
            message "Признак" input nd.name "уже есть" view-as alert-box.
            apply "entry":U to nd.name.
            return no-apply.
        end.
        assign nd.name.
        disp nd.name with browse nd.
    end.
    if not available nd THEN return.
    ri = recid( nd ).
    disp nd.name with frame add-nd.
    enable nd.name b-ok b-cancel with frame add-nd.
    wait-for go of frame add-nd.
END PROCEDURE.
