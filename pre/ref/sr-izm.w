block-level on error undo, throw.
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
DEFINE INPUT PARAMETER bttns AS character NO-UNDO.
DEFINE INPUT PARAMETER p-mode AS character NO-UNDO.
DEFINE INPUT PARAMETER p-type-izm-list AS character NO-UNDO.
DEFINE INPUT PARAMETER p-izm-par AS character NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER p-node-code AS INTEGER NO-UNDO.
define output parameter p-sr-type as character no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Справочник средств измерений".
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile: sr-izm.i $ $Revision: 0425b3e124f6, 2861, rls $".
define temp-table dop-sr-izm no-undo
field sr-model as character column-label "Модель"
format "X(35)" label "Модель"
view-as fill-in size 35 by 1
field sr-type-id as integer column-label "Тип"
format ">9" label "Тип"
view-as combo-box list-item-pairs "Ареометр, отградуирован при 15°С",1,
                                  "Ареометр, отградуирован при 20°С",2,
                                  "Поточный плотномер",3,
                                  "Погружной плотномер",4,
                                  "Канал измерения плотности (с поточным плотномером)",5,
                                  "Канал измерения плотности (без поточного плотномера)",6   inner-lines 5 drop-down-list size-chars 55 by 1
field sr-level as logical column-label "Уровень"
field sr-Density as logical column-label "Плотность"
field sr-Temperature as logical column-label "Температура"
field sr-Weight as logical column-label "Масса"
field sr-type-level-measuring as decimal  column-label "Способ расчета предела абс. погрешности уровня"
format ">9" label "Способ расчета предела абс. погрешности уровня" init ?
field sr-temp-line as decimal column-label "Температурный коэффициент линейного! расширения материала средства! измерения уровня, 1/°С "
format "-9.9999999" label "Температурный коэффициент линейного расширения материала средства измерения уровня, 1/°С "
field sr-abs-err-neft-water as decimal column-label "Абсолютная погрешность!измерений уровня, мм"
format "9.99" initial ? label "Абс. погрешность измерений уровня"
view-as fill-in size 15  by 1
field sr-Relative-err-neft-water as decimal column-label "Относительная погрешность измерений уровня нефтепродукта и подтоварной воды, %"
format "9.999" initial ? label "Относительная погрешность измерений уровня нефтепродукта и подтоварной воды, %"
view-as fill-in size 15  by 1
field sr-abs-err-water as decimal column-label "Абсолютная погрешность измерений! уровня подтоварной воды, мм"
format "9.99" initial 0 label "Абсолютная погрешность измерений уровня подтоварной воды, мм"
view-as fill-in size 15  by 1
field sr-Relative-err-water as decimal column-label "Относительная погрешность измерений уровня подтоварной воды, %"
format "9.999" initial 0 label "Относительная погрешность измерений уровня подтоварной воды, %"
view-as fill-in size 15  by 1
field sr-abs-err-temp-vol as decimal column-label "Абсолютная погрешность измерений температуры нефтепродукта при измерении его объема, °С"
format "9.9999" initial 0 label "Абсолютная погрешность измерений температуры нефтепродукта при измерении его объема, °С"
view-as fill-in size 15  by 1
field sr-abs-err-temp-dens as decimal column-label "Абсолютная погрешность измерений температуры нефтепродукта при измерении его плотности, °С"
format "9.9999" initial 0 label "Абсолютная погрешность измерений температуры нефтепродукта при измерении его плотности, °С"
view-as fill-in size 15  by 1
field sr-type-density-measuring as integer column-label "Тип средства измерения плотности"
format "9" label "Тип средства измерения плотности"
view-as combo-box list-item-pairs "Ареометр, отградуирован при 15°С",1,
                                  "Ареометр, отградуирован при 20°С",2,
                                  "Поточный плотномер",3,
                                  "Погружной плотномер",4,
                                  "Канал измерения плотности (с поточным плотномером)",5,
                                  "ПКанал измерения плотности (без поточного плотномера).",6
                                  inner-lines 3 drop-down-list size-chars 55 by 1
field sr-abs-err-dens as decimal column-label "Абсолютная погрешность измерений плотности нефтепродукта, кг/м3"
format "9.9999" initial 0 label "Абсолютная погрешность измерений плотности нефтепродукта, кг/м3"
view-as fill-in size 15  by 1
field sr-Relative-err-dens as decimal column-label " Относительная погрешность измерений плотности нефтепродукт, %"
format "9.999" initial 0 label " Относительная погрешность измерений плотности нефтепродукт, %"
view-as fill-in size 15  by 1
field sr-abs-err-dens-lgas-liquid as decimal column-label "Абсолютная погрешность измерений плотности ЖФ продукта, кг/м3"
format "9.9999" initial 0 label "Абсолютная погрешность измерений плотности ЖФ продукта, кг/м3"
view-as fill-in size 15  by 1
field sr-relative-err-dens-lgas-liquid as decimal column-label "Относительная погрешность измерений плотности ЖФ продукта, %"
format "9.999" label "Относительная погрешность измерений плотности ЖФ продукта, %"
view-as fill-in size 15  by 1
field sr-abs-err-dens-lgas-vapor as decimal column-label " Абсолютная погрешность измерений плотности ПГФ продукта, кг/м3"
format "9.999" initial 0 label "Абсолютная погрешность измерений плотности ПГФ продукта, кг/м3"
view-as fill-in size 15  by 1
field sr-otnos as decimal column-label "относительная погрешность измерения массы, %"
format "9.999999" initial 0 label "относительная погрешность измерения массы, %"
view-as fill-in size 15  by 1
field node-code as integer  column-label "Код"
format ">>>9" label "Код"
fgcolor RED_COLOR
index pi is unique primary
node-code
.
define shared variable g#db-num as integer no-undo .
DEFINE VARIABLE v-max-node-code AS INTEGER NO-UNDO.
DEFINE VARIABLE v-node-code AS INTEGER NO-UNDO.
define variable v-edit-mode as logical no-undo .
define variable v-action-mode as character no-undo .
define variable mNotUsedStr as character no-undo fgcolor 12.
define buffer buf_clob-bind for ub.clob-bind.
define variable cb-sr-type-id as integer column-label "Тип"
  format ">9" label "Тип"
  view-as combo-box list-item-pairs
    "Ареометр, отградуирован при 15°С",1,
    "Ареометр, отградуирован при 20°С",2,
    "Поточный плотномер",3,
    "Погружной плотномер",4,
    "Канал измерения плотности (с поточным плотномером)",5,
    "Канал измерения плотности (без поточного плотномера)",6
  inner-lines 5 drop-down-list size-chars 55 by 1
.
DEFINE BUTTON b-add
     LABEL "&Добавить"
     SIZE 10 BY 1.
DEFINE BUTTON b-look
     LABEL "&Просмотр"
     SIZE 10 BY 1.
DEFINE BUTTON b-cancel
     LABEL "Отмена"
     SIZE 10 BY 1.
DEFINE BUTTON b-cng
     LABEL "&Изменить"
     SIZE 10 BY 1.
DEFINE BUTTON b-del
     LABEL "&Удалить"
     SIZE 10 BY 1.
DEFINE BUTTON b-sel
     LABEL "&Выбор"
     SIZE 10 BY 1.
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-hist
     LABEL "Ис&тория"
     SIZE 3 BY 1.
DEFINE BUTTON b-quit AUTO-GO
     LABEL "&Закрыть"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE QUERY BR-sr-izm FOR
      sr-izmerenia SCROLLING.
DEFINE BROWSE BR-sr-izm
   QUERY BR-sr-izm NO-LOCK DISPLAY
      sr-izmerenia.node-code
      sr-izmerenia.sr-model
      sr-izmerenia.sr-type-id
      sr-izmerenia.sr-abs-err-neft-water
      sr-izmerenia.sr-abs-err-water
      sr-izmerenia.sr-abs-err-dens
      sr-izmerenia.sr-abs-err-temp-vol
      sr-izmerenia.sr-abs-err-temp-dens
      sr-izmerenia.sr-otnos
      sr-izmerenia.sr-temp-line
    WITH NO-ROW-MARKERS SEPARATORS SIZE 142 BY 13 FIT-LAST-COLUMN.
DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 11 WIDGET-ID 6
     b-sel at row 1 col 26  WIDGET-ID 10
     b-add AT ROW 1 COL 45 WIDGET-ID 14
     b-cng AT ROW 1 COL 55 WIDGET-ID 4
     b-del AT ROW 1 COL 65 WIDGET-ID 22
     b-look AT ROW 1 COL 75 WIDGET-ID 22
     B-hist AT ROW 1 COL 137
     B-Help AT ROW 1 COL 140.5
     BR-sr-izm AT ROW 4.25 COL 1.5 WIDGET-ID 200
     b-cancel AT ROW 18 COL 88 WIDGET-ID 26
     SPACE(45.87) SKIP(8.74)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Справочник средств измерений" WIDGET-ID 100.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       b-cancel:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-add IN FRAME Dialog-Frame
DO:
  v-action-mode = 'ДОБАВЛЕНИЕ':U .
  RUN ref\sr-izm-frm.w ('ДОБАВЛЕНИЕ':U, ?) no-error.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
  OPEN QUERY BR-sr-izm FOR EACH sr-izmerenia NO-LOCK .
    APPLY "value-changed" TO BROWSE br-sr-izm.
END.
ON CHOOSE OF b-cancel IN FRAME Dialog-Frame
DO:
  RUN proc-undo-record IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN do:
    enable
    b-add when v-edit-mode
    b-cng when v-edit-mode
    b-del when v-edit-mode
    with frame Dialog-Frame .
    RETURN NO-APPLY.
  end.
  v-action-mode= "":U.
  enable
  b-add when v-edit-mode
  b-cng when v-edit-mode
  b-del when v-edit-mode
  with frame Dialog-Frame .
END.
ON CHOOSE OF b-cng IN FRAME Dialog-Frame
DO:
  define variable vnode-code as integer  no-undo.
  IF NOT AVAILABLE sr-izmerenia THEN RETURN NO-APPLY.
  vnode-code = sr-izmerenia.node-code.
  RUN ref\sr-izm-frm.w ('ИЗМЕНЕНИЕ':U, sr-izmerenia.node-code) no-error.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
  run reopen-query .
  find first sr-izmerenia where sr-izmerenia.node-code eq  vnode-code no-lock.
  reposition BR-sr-izm to rowid rowid(sr-izmerenia) no-error .
    APPLY "value-changed" TO BROWSE br-sr-izm.
END.
ON CHOOSE OF b-del IN FRAME Dialog-Frame
DO:
  IF NOT AVAILABLE sr-izmerenia  THEN RETURN NO-APPLY.
  RUN proc-b-del IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
  run reopen-query .
    APPLY "value-changed" TO BROWSE br-sr-izm.
END.
ON CHOOSE OF b-look IN FRAME Dialog-Frame
DO:
  define variable vnode-code as integer  no-undo.
  IF NOT AVAILABLE sr-izmerenia THEN RETURN NO-APPLY.
  vnode-code = sr-izmerenia.node-code.
  RUN ref\sr-izm-frm.w ('ПРОСМОТР':U, sr-izmerenia.node-code) .
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
  run reopen-query .
  find first sr-izmerenia where sr-izmerenia.node-code eq  vnode-code no-lock.
  reposition BR-sr-izm to rowid rowid(sr-izmerenia) no-error .
  APPLY "value-changed" TO BROWSE br-sr-izm.
END.
ON CHOOSE OF B-sel IN FRAME Dialog-Frame
DO:
  if available sr-izmerenia then do :
    if sr-izmerenia.sr-not-used then do:
      message "Средство измерения отмечено как неиспользуемое. Выбор запрещен."
      view-as alert-box warning.
      return no-apply.
    end.
    p-node-code = sr-izmerenia.node-code.
    p-sr-type = string(sr-izmerenia.sr-type-id).
  end.
  else p-node-code = ? .
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
  apply "choose" to b-quit .
END.
ON CHOOSE OF B-hist IN FRAME Dialog-Frame
DO:
  DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
  IF AVAILABLE sr-izmerenia THEN DO:
  run ref/csr-izm.w (
                    INPUT parParentProc
                   ,input '':U
                   ,input 'one':U
                   ,input  ''
                   ,input  0
                   ,INPUT sr-izmerenia.node-code
                   ,INPUT-OUTPUT v-rid-list) NO-ERROR.
  END.
END.
ON VALUE-CHANGED OF BR-sr-izm IN FRAME Dialog-Frame
DO:
  define variable vNotUsedStr as character no-undo.
  if b-cancel:visible in frame Dialog-Frame  then do:
    return no-apply.
  end.
  IF AVAILABLE sr-izmerenia THEN do:
    assign
      cb-sr-type-id   = sr-izmerenia.sr-type-id
      vNotUsedStr     = if sr-izmerenia.sr-not-used then "!!! СРЕДСТВО ИЗМЕРЕНИЯ НЕ ИСПОЛЬЗУЕТСЯ !!!"  else ""
    .
    DISPLAY
      sr-izmerenia.node-code @ dop-sr-izm.node-code AT ROW 18 COL 5 LEFT-ALIGNED  SKIP
      vNotUsedStr @ mNotUsedStr  AT ROW 18 COL 45 LEFT-ALIGNED format "x(42)" no-label SKIP
      sr-izmerenia.sr-model  @ dop-sr-izm.sr-model  AT ROW 19 COL 5 LEFT-ALIGNED  SKIP
      cb-sr-type-id    AT ROW 20 COL 5 LEFT-ALIGNED  SKIP
      sr-izmerenia.sr-abs-err-neft-water @ dop-sr-izm.sr-abs-err-neft-water AT ROW 21 COL 5 LEFT-ALIGNED  SKIP
      sr-izmerenia.sr-abs-err-water      @ dop-sr-izm.sr-abs-err-water      AT ROW 22 COL 5 LEFT-ALIGNED  SKIP
      sr-izmerenia.sr-abs-err-dens       @ dop-sr-izm.sr-abs-err-dens       AT ROW 23 COL 5 LEFT-ALIGNED  SKIP
      sr-izmerenia.sr-abs-err-temp-vol   @ dop-sr-izm.sr-abs-err-temp-vol   AT ROW 24 COL 5 LEFT-ALIGNED  SKIP
      sr-izmerenia.sr-abs-err-temp-dens  @ dop-sr-izm.sr-abs-err-temp-dens  AT ROW 25 COL 5 LEFT-ALIGNED  SKIP
      sr-izmerenia.sr-otnos              @ dop-sr-izm.sr-otnos              AT ROW 26 COL 5 LEFT-ALIGNED  SKIP
    with FRAME Dialog-Frame .
  END.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
        v-diasize-browse-handle     = browse BR-sr-izm :handle
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
    run diasize_init in this-procedure .
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
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
  IF LOOKUP(p-mode, 'ИЗМЕНЕНИЕ':U + chr(44) + 'ПРОСМОТР':U) = 0  THEN DO:
    MESSAGE
    substitute("Неверное значение параметров p-mode = &1"
    , p-mode)
    VIEW-AS alert-box.
    UNDO, RETURN ERROR.
  END.
  IF p-mode = 'ИЗМЕНЕНИЕ':U
  AND LOOKUP("b-sel", bttns) > 0   THEN DO:
    MESSAGE
    substitute("Неверное значение параметров bttns = &1 и/или p-mode = &2"
               , bttns
               , p-mode)
    VIEW-AS alert-box.
    UNDO, RETURN ERROR.
  END.
  v-node-code = p-node-code.
  RUN Myenable.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  ENABLE b-quit b-sel b-add b-cng b-del B-hist B-Help
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE MyEnable :
assign
  FRAME Dialog-Frame:visible = true
.
if p-mode = 'ИЗМЕНЕНИЕ':U then do:
  v-edit-mode = yes.
end.
v-action-mode = "":U .
enable
br-sr-izm
b-add WHEN v-edit-mode and g#db-num = 0
b-cng WHEN v-edit-mode and g#db-num = 0
b-del WHEN v-edit-mode and g#db-num = 0
b-look
b-hist
b-help
b-quit
b-sel when not v-edit-mode
WITH FRAME Dialog-Frame
.
IF p-mode <> 'ИЗМЕНЕНИЕ':U THEN DO:
  b-quit:COLUMN  = 1.
  b-quit:label in frame Dialog-Frame = "&Выход".
END.
run reopen-query .
APPLY "value-changed" TO BROWSE br-sr-izm.
END PROCEDURE.
PROCEDURE proc-b-del :
DEFINE BUFFER buf_sr-izm FOR sr-izmerenia.
define variable v-del-confirm as logical no-undo.
define variable Msg as character no-undo.
define variable v-retfl as logical no-undo.
Msg = "".
v-retfl = false.
  v-del-confirm = false.
  message substitute("Удалить запись о средстве измерения &1 &2?", sr-izmerenia.node-code, sr-izmerenia.sr-model)
    view-as alert-box question buttons yes-no update v-del-confirm .
  if v-del-confirm then do transaction:
    run ref/sr-izm03.p
    (input sr-izmerenia.node-code
    ) .
    OPEN QUERY BR-sr-izm FOR EACH sr-izmerenia NO-LOCK .
    APPLY "value-changed" TO BROWSE br-sr-izm.
    v-retfl = true.
    catch exAppErrors as class Progress.Lang.AppError :
      Msg = exAppErrors:ReturnValue .
      if Msg > "" then . else do :
        Msg = exAppErrors:GetMessage(1) .
        if Msg > "" then . else Msg = "AppError при удалении в sr-izmerenia" .
      end .
    end catch .
    catch exProErrors as class Progress.Lang.ProError :
      Msg = exProErrors:GetMessage(1) .
      if Msg > "" then . else Msg = "ProError при удалении в sr-izmerenia" .
    end catch .
    catch exAnyErrors as class Progress.Lang.Error:
      Msg = "Unexpected error при удалении в sr-izmerenia" .
    end catch .
    finally :
      if v-retfl then .
      else do:
        message Msg view-as alert-box error.
        return error.
      end.
    end finally .
  end.
  else return error.
END PROCEDURE.
PROCEDURE reopen-query :
  if p-type-izm-list = ""
  then do :
    if p-izm-par = ""
    then do :
      OPEN QUERY BR-sr-izm FOR EACH sr-izmerenia NO-LOCK .
    end .
    else do :
      open query BR-sr-izm for each sr-izmerenia no-lock where (sr-izmerenia.sr-level and p-izm-par = "lvl")
                                                            or (sr-izmerenia.sr-density and p-izm-par = "dnst")
                                                            or (sr-izmerenia.sr-temperature and p-izm-par = "tmp")
                                                            .
    end .
  end .
  else do :
    if p-izm-par = ""
    then do :
      open query BR-sr-izm for each sr-izmerenia no-lock where can-do(p-type-izm-list, string(sr-izmerenia.sr-type-izm)) .
    end .
    else do :
      open query BR-sr-izm for each sr-izmerenia no-lock where can-do(p-type-izm-list, string(sr-izmerenia.sr-type-izm))
                                                           and ((sr-izmerenia.sr-level and p-izm-par = "lvl")
                                                            or (sr-izmerenia.sr-density and p-izm-par = "dnst")
                                                            or (sr-izmerenia.sr-temperature and p-izm-par = "tmp"))
                                                            .
    end .
  end .
END PROCEDURE.
PROCEDURE proc-save-record :
define input parameter p-action as character no-undo.
define variable v-node-code as integer no-undo .
define variable v-rec       as recid no-undo .
define variable Msg         as character no-undo.
define variable v-retfl     as logical no-undo.
define variable v-err-field as character no-undo .
DEFINE BUFFER buf_sr-izm FOR sr-izmerenia.
ASSIGN
FRAME Dialog-Frame
dop-sr-izm.sr-model
cb-sr-type-id
dop-sr-izm.sr-abs-err-neft-water
dop-sr-izm.sr-abs-err-water
dop-sr-izm.sr-abs-err-dens
dop-sr-izm.sr-abs-err-temp-vol
dop-sr-izm.sr-abs-err-temp-dens
dop-sr-izm.sr-otnos
.
define variable v-msg2  as character no-undo .
define variable v-delta as decimal decimals 2 no-undo .
  if dop-sr-izm.sr-model > "" then .
  else do:
    message "Пожалуйста заполните наименование модели средства измерения"
    view-as alert-box.
    apply "entry" to dop-sr-izm.sr-model in frame Dialog-Frame .
    return error .
  end .
  assign
    v-msg2 = "выходит за границы допустимого диапазона"
    v-delta = 3
  .
  if dop-sr-izm.sr-abs-err-neft-water > v-delta or dop-sr-izm.sr-abs-err-neft-water < (-1) * v-delta then do :
    message substitute("&1 &2&3(+/-)&4 мм",
                 dop-sr-izm.sr-abs-err-neft-water:label in frame Dialog-Frame, v-msg2, chr(10), string(v-delta, "9") )
    view-as alert-box.
    apply "entry" to dop-sr-izm.sr-abs-err-neft-water in frame Dialog-Frame .
    return error .
  end.
  if dop-sr-izm.sr-abs-err-water > v-delta or dop-sr-izm.sr-abs-err-water < (-1) * v-delta then do :
    message substitute("&1 &2&3(+/-)&4 мм",
                 dop-sr-izm.sr-abs-err-water:label in frame Dialog-Frame, v-msg2, chr(10), string(v-delta, "9") )
    view-as alert-box.
    apply "entry" to dop-sr-izm.sr-abs-err-water in frame Dialog-Frame .
    return error .
  end.
  v-delta = 0.5 .
  if dop-sr-izm.sr-abs-err-dens > v-delta or dop-sr-izm.sr-abs-err-dens < (-1) * v-delta then do :
    message substitute("&1 &2&3(+/-)&4 кг/м3",
                 dop-sr-izm.sr-abs-err-dens:label in frame Dialog-Frame, v-msg2, chr(10), string(v-delta, "9.9") )
    view-as alert-box.
    apply "entry" to dop-sr-izm.sr-abs-err-dens in frame Dialog-Frame .
    return error .
  end.
  if dop-sr-izm.sr-abs-err-temp-vol > v-delta or dop-sr-izm.sr-abs-err-temp-vol < (-1) * v-delta then do :
    message substitute("&1 &2&3(+/-)&4 °С",
                 dop-sr-izm.sr-abs-err-temp-vol:label in frame Dialog-Frame, v-msg2, chr(10), string(v-delta, "9.9") )
    view-as alert-box.
    apply "entry" to dop-sr-izm.sr-abs-err-temp-vol in frame Dialog-Frame .
    return error .
  end.
  if dop-sr-izm.sr-abs-err-temp-dens > v-delta or dop-sr-izm.sr-abs-err-temp-dens < (-1) * v-delta then do :
    message substitute("&1 &2&3(+/-)&4 °С",
                 dop-sr-izm.sr-abs-err-temp-dens:label in frame Dialog-Frame, v-msg2, chr(10), string(v-delta, "9.9") )
    view-as alert-box.
    apply "entry" to dop-sr-izm.sr-abs-err-temp-dens in frame Dialog-Frame .
    return error .
  end.
  v-delta = 0.05 .
  if dop-sr-izm.sr-otnos > v-delta or dop-sr-izm.sr-otnos < (-1) * v-delta then do :
    message substitute("&1 &2&3(+/-)&4 %",
                 dop-sr-izm.sr-otnos:label in frame Dialog-Frame, v-msg2, chr(10), string(v-delta, "9.99") )
    view-as alert-box.
    apply "entry" to dop-sr-izm.sr-otnos in frame Dialog-Frame .
    return error .
  end.
  assign
    dop-sr-izm.sr-type-id   = cb-sr-type-id
    v-node-code = if p-action = 'ДОБАВЛЕНИЕ':U then next-value (s-sr-izmerenia, ub) else dop-sr-izm.node-code
    Msg = "":U
    v-retfl = false
  .
  do transaction :
    run ref/sr-izm01.p
    (input v-node-code
    ,input dop-sr-izm.sr-model
    ,input dop-sr-izm.sr-type-id
    ,input dop-sr-izm.sr-abs-err-neft-water
    ,input dop-sr-izm.sr-abs-err-water
    ,input dop-sr-izm.sr-abs-err-dens
    ,input dop-sr-izm.sr-abs-err-temp-vol
    ,input dop-sr-izm.sr-abs-err-temp-dens
    ,input dop-sr-izm.sr-otnos
    ,input dop-sr-izm.sr-temp-line
    ) .
    DELETE dop-sr-izm.
    find first buf_sr-izm no-lock where buf_sr-izm.node-code = v-node-code no-error .
    v-rec = if available buf_sr-izm then RECID(buf_sr-izm) else ?.
    v-retfl = true.
    catch exAppErrors as class Progress.Lang.AppError :
      Msg = exAppErrors:ReturnValue .
      if Msg > "" then . else do :
        Msg = exAppErrors:GetMessage(1) .
        if Msg > "" then . else Msg = "AppError при добавлении в sr-izmerenia" .
      end .
    end catch .
    catch exProErrors as class Progress.Lang.ProError :
      Msg = exProErrors:GetMessage(1) .
      if Msg > "" then . else Msg = "ProError при добавлении в sr-izmerenia" .
    end catch .
    catch exAnyErrors as class Progress.Lang.Error:
      Msg = "Unexpected error при добавлении в sr-izmerenia" .
    end catch .
    finally :
      if v-retfl then .
      else do:
        message Msg view-as alert-box error.
        return error.
      end.
    end finally .
  end .
disable dop-sr-izm.sr-model              cb-sr-type-id               dop-sr-izm.sr-abs-err-neft-water dop-sr-izm.sr-abs-err-water      dop-sr-izm.sr-abs-err-dens       dop-sr-izm.sr-abs-err-temp-vol   dop-sr-izm.sr-abs-err-temp-dens  dop-sr-izm.sr-otnos              with FRAME Dialog-Frame.
HIDE b-cancel IN FRAME Dialog-Frame.
OPEN QUERY BR-sr-izm FOR EACH sr-izmerenia NO-LOCK .
REPOSITION br-sr-izm TO RECID v-rec.
APPLY "value-changed" TO br-sr-izm.
END PROCEDURE.
PROCEDURE proc-undo-record :
delete dop-sr-izm.
disable dop-sr-izm.sr-model              cb-sr-type-id               dop-sr-izm.sr-abs-err-neft-water dop-sr-izm.sr-abs-err-water      dop-sr-izm.sr-abs-err-dens       dop-sr-izm.sr-abs-err-temp-vol   dop-sr-izm.sr-abs-err-temp-dens  dop-sr-izm.sr-otnos              with FRAME Dialog-Frame.
HIDE b-cancel IN FRAME Dialog-Frame.
APPLY "VALUE-CHANGED" TO br-sr-izm IN FRAME Dialog-Frame.
END PROCEDURE.
