DEFINE TEMP-TABLE x_add-doc NO-UNDO LIKE add-doc.
DEFINE BUFFER x_add-line FOR add-line.
DEFINE BUFFER x_add-trn FOR add-trn.
DEFINE BUFFER x_gds-add-charges FOR gds-add-charges.
DEFINE BUFFER x_goods FOR goods.
DEFINE BUFFER x_trn-doc FOR trn-doc.
define input parameter        parparentproc  as widget-handle no-undo.
define input-output parameter p-recid        as recid     no-undo .
define input parameter        p-mode         as character no-undo .
define input parameter        p-doc-code     as character no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Документ Дополнительных расходов".
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
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure doc-code:
define input  parameter parmode          as   character           no-undo.
define input  parameter parobj-type      like ub.clients.obj-type no-undo.
define input  parameter parobj-code      like ub.clients.obj-code no-undo.
define input  parameter parroot-doc-code like ub.trn-doc.doc-code no-undo.
define output parameter pardoc-code      like ub.trn-doc.doc-code no-undo.
define buffer buf_sys-ctrl for ub.sys-ctrl  .
define variable vardb-remote     as   logical             no-undo.
define variable vartemp-doc-code like ub.trn-doc.doc-code no-undo.
define variable v-delimiter as character no-undo .
do
on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
:
find first buf_sys-ctrl no-lock .
vardb-remote = buf_sys-ctrl.db-num <> 0 .
  CASE parmode:
    when "main":u then do:
      if vardb-remote then do:
        assign
          pardoc-code = trim (string (next-value (s-trn-doc, ub), ">>>>>>>>>9")) + "-" + trim (string (parobj-code, ">>>>9")) + substring (parobj-type, (if g#language = "RUS" then 1 else 2), 1).
      end.
      else do:
        assign
          pardoc-code = trim (string (next-value (s-trn-doc, ub), ">>>>>>>>>9")) + "-".
      end.
    end.
    when "trio" then do:
      assign
        pardoc-code = replace (parroot-doc-code, "=", "*").
    end.
    otherwise do:
      assign
      v-delimiter = entry(lookup(entry(1, parmode), "main,chip,pair,flora,trio-m,quadro,stock-up,stock-down,stock-fix," +                          "main_s,chip_s,pair_s,trio-m_s,quadro_s,stock-up_s,stock-down_s,stock-fix_s":U), ("-,-,=,#,*,^,+,`,":U + chr(126) + ",у-,у-,у=,у*,у^,у+,у`,у" + chr(126)))
      no-error
      .
      if error-status:error  then do:
        undo, return error substitute("Ошибка при генерации номера документа&1Неверное значение параметра parmode &2"
                                      ,chr(10)
                                      ,parmode
                                      ).
      end.
      if num-entries(parmode) = 1
      and parmode <> "chip":U
      and parmode <> "chip_s":U
      then do:
        assign
        pardoc-code = replace (parroot-doc-code, "-", v-delimiter).
      end.
      else if (lookup("chip":U, parmode) > 0
               or
               lookup("chip_s":U, parmode) > 0) then do:
        assign
          vartemp-doc-code = parroot-doc-code.
        do while true:
          if index (vartemp-doc-code , ".") = 0 then
            vartemp-doc-code  = replace (vartemp-doc-code , v-delimiter, v-delimiter + "1.").
          else
            vartemp-doc-code  =
            substring (vartemp-doc-code , 1, index (vartemp-doc-code, v-delimiter)) +
            string (integer (substring (vartemp-doc-code, index (vartemp-doc-code, v-delimiter) + 1, index (vartemp-doc-code, ".") - index (vartemp-doc-code, v-delimiter) - 1)) + 1) +
            substring (vartemp-doc-code, index (vartemp-doc-code, ".")).
          if not can-find (ub.trn-doc where ub.trn-doc.doc-code = vartemp-doc-code no-lock) then leave.
        end.
        assign
          pardoc-code = vartemp-doc-code.
      end.
    end.
  end CASE.
  if pardoc-code = '':U
  or (parroot-doc-code <> '':U
  and pardoc-code = parroot-doc-code) then do:
    undo, return error substitute("Ошибка при генерации номера документа&1"
                                  ,chr(10)).
  end.
end.
end. // procedure/method
function get-doc-code-int64 returns int64
  ( input p-doc-code as character ) :
  define variable v-ind              as integer   no-undo .
  define variable v-num-entries      as integer   no-undo .
  define variable v-doc-code-int64   as int64     no-undo .
  define variable v-canonic-doc-code as character no-undo .
  assign
    v-num-entries      = num-entries( ("-,-,=,#,*,^,+,`,":U + chr(126) + ",у-,у-,у=,у*,у^,у+,у`,у" + chr(126)) )
    v-canonic-doc-code = p-doc-code
  .
  do v-ind = 1 to v-num-entries
  :
    assign
      v-canonic-doc-code = entry(1, v-canonic-doc-code, entry( v-ind, ("-,-,=,#,*,^,+,`,":U + chr(126) + ",у-,у-,у=,у*,у^,у+,у`,у" + chr(126)) ) )
    .
  end.
  assign
    v-doc-code-int64 = int64(v-canonic-doc-code) no-error
  .
  return v-doc-code-int64 .
end. // function/method
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION alg-name RETURNS CHARACTER
  ( buffer loc-table for ub.gds-add-charges ) :
if not available  loc-table  then return "678" .
if loc-table.cost-include = no then return "".
case loc-table.algoritm :
  when "1" then do:
    return "сумме приходных цен".
  end.
  when "2" then do:
    return "количеству(в баз. ед.изм.)".
  end.
  when "3" then do:
    return "количеству(в пост. ед.изм.)" .
  end.
  when "4" then do:
    return "весу".
  end.
end case.
END FUNCTION.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
define variable par-type          as character no-undo.
define variable v-value-character as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .
define variable v-value-logical   as logical   no-undo .
define variable v-doc-code as character no-undo .
define variable v-curr-abbr as character no-undo .
define variable ref-rec as recid no-undo.
define variable varvat-type  as integer   no-undo .
define variable varvat-type-type            as   character initial ?    no-undo.
define variable varvat-type-def             as   character              no-undo.
define variable v-recid as recid no-undo .
define variable v-mode-exit  as character no-undo .
DEFINE TEMP-TABLE old_add-line NO-UNDO LIKE ub.add-line.
empty temp-table old_add-line.
DEFINE BUTTON B-add
     LABEL "&Добавить"
     SIZE 10 BY 1 TOOLTIP "Добавить Дополнительный расход"
     BGCOLOR 8 .
DEFINE BUTTON B-chg
     LABEL "&Изменить"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-del
     LABEL "&Удалить"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-Help
     LABEL "&Help"
     SIZE 3 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-lkp
     LABEL "&Просмотр"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-print
     LABEL "&p"
     SIZE 3 BY 1 TOOLTIP "Печать документа"
     BGCOLOR 8 .
DEFINE BUTTON B-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-trn
     LABEL "&+ПН"
     SIZE 5.5 BY 1 TOOLTIP "Добавить Приходные накладные в список"
     BGCOLOR 8 .
DEFINE BUTTON B-trn-del
     LABEL "&-ПН"
     SIZE 5.5 BY 1 TOOLTIP "Удалить приходные накладные из списка"
     BGCOLOR 8 .
DEFINE BUTTON B-trn-sel
     LABEL "Просмотр ПН"
     SIZE 13.5 BY 1 TOOLTIP "Просмотр приходной накладной"
     BGCOLOR 8 .
DEFINE BUTTON r-acc
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON r-currency
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON r-sht
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY .88.
DEFINE VARIABLE f-summa AS CHARACTER FORMAT "X(256)":U INITIAL " Сумма"
      VIEW-AS TEXT
     SIZE 7.5 BY .79
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE f-vat AS CHARACTER FORMAT "X(256)":U INITIAL " НДС"
      VIEW-AS TEXT
     SIZE 5 BY .79
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE scr-curr-abbr AS CHARACTER FORMAT "X(3)":U
      VIEW-AS TEXT
     SIZE 4 BY .79
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE v-obj-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 26 BY .79
     FGCOLOR 1  NO-UNDO.
DEFINE QUERY BR-docsa FOR
      x_add-line,
      x_goods,
      x_gds-add-charges SCROLLING.
DEFINE QUERY BROWSE-7 FOR
      x_add-trn,
      x_trn-doc SCROLLING.
DEFINE QUERY Dialog-Frame FOR
      x_add-doc SCROLLING.
DEFINE BROWSE BR-docsa
  QUERY BR-docsa NO-LOCK DISPLAY
      x_goods.artic FORMAT "X(16)":U
      x_add-line.gds-code FORMAT "999999999":U
      x_goods.gds-name FORMAT "X(48)":U
      x_add-line.cli-type + string(x_add-line.cli-code) FORMAT "X(11)":U
      x_add-line.contract-code FORMAT ">>>>>>>>>>":U  label "Договор"
      x_add-line.sum-base FORMAT "->>>,>>>,>>9.99":U
      x_add-line.sum-rubl FORMAT "->>>,>>>,>>9.99":U
      x_add-line.vat-pc FORMAT "->>,>>9.99":U
      alg-name( buffer x_gds-add-charges) label "Алгоритм" format "x(30)":u
    WITH NO-ROW-MARKERS SEPARATORS SIZE 95.5 BY 10 FIT-LAST-COLUMN.
DEFINE BROWSE BROWSE-7
  QUERY BROWSE-7 NO-LOCK DISPLAY
      x_add-trn.trn-doc-code FORMAT "X(14)"
      (SUBSTRING(x_trn-doc.status_,1,4) + STRING(x_trn-doc.flag_,"+/-")) FORMAT "X(5)":U COLUMN-LABEL "Статус"
      x_trn-doc.doc-date FORMAT "99/99/99":U
      x_trn-doc.cli-name FORMAT "X(40)":U
    WITH NO-ROW-MARKERS SEPARATORS SIZE 43 BY 9 FIT-LAST-COLUMN.
DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     B-quit AT ROW 1 COL 11
     B-print AT ROW 1 COL 91.38 WIDGET-ID 72
     B-Help AT ROW 1 COL 94.5
     x_add-doc.exch-rate AT ROW 3 COL 32.5 COLON-ALIGNED WIDGET-ID 14
          VIEW-AS FILL-IN
          SIZE 10 BY 1 TOOLTIP "Курс валюты документа"
          FGCOLOR 4
     x_add-doc.exch-scale AT ROW 3 COL 42.63 COLON-ALIGNED NO-LABEL WIDGET-ID 16
          VIEW-AS FILL-IN
          SIZE 5 BY 1
          FGCOLOR 4
     r-acc AT ROW 3 COL 49.63 WIDGET-ID 54
     B-trn AT ROW 3 COL 54 WIDGET-ID 50
     B-trn-del AT ROW 3 COL 59.5 WIDGET-ID 66
     B-trn-sel AT ROW 3 COL 65 WIDGET-ID 68
     x_add-doc.exch-code AT ROW 3.25 COL 8.5 COLON-ALIGNED WIDGET-ID 10
          LABEL "Валюта"
          VIEW-AS FILL-IN
          SIZE 4 BY 1 TOOLTIP "Валюта документа"
          FGCOLOR 4
     r-currency AT ROW 3.25 COL 14.5 WIDGET-ID 52
     x_add-doc.exch-date AT ROW 3.25 COL 19.5 COLON-ALIGNED NO-LABEL WIDGET-ID 12
          VIEW-AS FILL-IN
          SIZE 9 BY 1 TOOLTIP "Дата курса"
     BROWSE-7 AT ROW 4.21 COL 53.75 WIDGET-ID 300
     x_add-doc.base-rate AT ROW 4.33 COL 8.5 COLON-ALIGNED WIDGET-ID 2
          LABEL "Баз.вал"
          VIEW-AS FILL-IN
          SIZE 10 BY 1
     x_add-doc.base-scale AT ROW 4.33 COL 18.63 COLON-ALIGNED NO-LABEL WIDGET-ID 4
          VIEW-AS FILL-IN
          SIZE 5 BY 1
     x_add-doc.doc-date AT ROW 5.38 COL 8.5 COLON-ALIGNED WIDGET-ID 8
          VIEW-AS FILL-IN
          SIZE 9 BY 1
     x_add-doc.fact-date AT ROW 6.42 COL 8.38 COLON-ALIGNED WIDGET-ID 18
          VIEW-AS FILL-IN
          SIZE 9 BY 1
     x_add-doc.shift-date AT ROW 6.42 COL 25.88 COLON-ALIGNED WIDGET-ID 26
          LABEL "Смена"
          VIEW-AS FILL-IN
          SIZE 9 BY 1
     x_add-doc.shift-name AT ROW 6.42 COL 38.13 COLON-ALIGNED WIDGET-ID 28
          LABEL "№"
          VIEW-AS FILL-IN
          SIZE 3 BY 1
     x_add-doc.shift-num AT ROW 6.42 COL 44.38 COLON-ALIGNED WIDGET-ID 30
          LABEL "П"
          VIEW-AS FILL-IN
          SIZE 3 BY 1
     r-sht AT ROW 6.42 COL 49.88 WIDGET-ID 56
     x_add-doc.VAT-type AT ROW 11 COL 30 COLON-ALIGNED WIDGET-ID 70
          LABEL "НДС" FORMAT "X(8)"
          VIEW-AS COMBO-BOX INNER-LINES 5
          LIST-ITEMS "Item 1"
          DROP-DOWN-LIST
          SIZE 13.5 BY 1
     B-add AT ROW 12.13 COL 1.75 WIDGET-ID 42
     B-lkp AT ROW 12.13 COL 11.75 WIDGET-ID 44
     B-chg AT ROW 12.13 COL 21.75 WIDGET-ID 46
     B-del AT ROW 12.13 COL 31.75 WIDGET-ID 48
     BR-docsa AT ROW 13.25 COL 1.5 WIDGET-ID 200
     x_add-doc.obj-type AT ROW 2.13 COL 7.25 COLON-ALIGNED WIDGET-ID 22
          LABEL "Объект" FORMAT "X(3)"
           VIEW-AS TEXT
          SIZE 4 BY .79
          FGCOLOR 1
     x_add-doc.obj-code AT ROW 2.13 COL 11.88 COLON-ALIGNED NO-LABEL WIDGET-ID 20 FORMAT ">>>>9"
           VIEW-AS TEXT
          SIZE 6 BY .79
          FGCOLOR 1
     v-obj-name AT ROW 2.13 COL 18.75 COLON-ALIGNED NO-LABEL WIDGET-ID 58
     x_add-doc.doc-code AT ROW 2.13 COL 49.13 COLON-ALIGNED WIDGET-ID 6
          LABEL "№" FORMAT "X(14)"
           VIEW-AS TEXT
          SIZE 15 BY .79
     scr-curr-abbr AT ROW 3.29 COL 15.5 COLON-ALIGNED NO-LABEL WIDGET-ID 60
     f-summa AT ROW 8.42 COL 8.5 COLON-ALIGNED NO-LABEL WIDGET-ID 62
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         DEFAULT-BUTTON B-exit CANCEL-BUTTON B-quit WIDGET-ID 100.
DEFINE FRAME Dialog-Frame
     f-vat AT ROW 8.42 COL 30 COLON-ALIGNED NO-LABEL WIDGET-ID 64
     x_add-doc.sum-base AT ROW 9.33 COL 10 COLON-ALIGNED WIDGET-ID 32
          LABEL "Сумма"
           VIEW-AS TEXT
          SIZE 21 BY .67
     x_add-doc.VAT-base AT ROW 9.33 COL 30 COLON-ALIGNED NO-LABEL WIDGET-ID 36
           VIEW-AS TEXT
          SIZE 20.5 BY .67
     x_add-doc.sum-rubl AT ROW 10.33 COL 10 COLON-ALIGNED WIDGET-ID 34
           VIEW-AS TEXT
          SIZE 20.5 BY .67
     x_add-doc.VAT-rubl AT ROW 10.33 COL 30 COLON-ALIGNED NO-LABEL WIDGET-ID 38
           VIEW-AS TEXT
          SIZE 20.5 BY .67
     SPACE(45.12) SKIP(12.41)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Документ Дополнительных расходов"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON B-quit WIDGET-ID 100.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       x_add-doc.exch-code:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       x_add-doc.exch-date:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       x_add-doc.exch-rate:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       x_add-doc.exch-scale:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       r-acc:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       r-currency:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       scr-curr-abbr:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ON GO OF FRAME Dialog-Frame
DO:
  if  p-mode <> 'ПРОСМОТР':U then do:
      run proc-save in this-procedure no-error.
      if error-status :error then return no-apply .
  end.
END.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "choose":U TO b-quit.
END.
ON CHOOSE OF B-add IN FRAME Dialog-Frame
DO:
define variable v-rid-list as character no-undo .
define variable v-cnt      as integer   no-undo .
define variable v-vat-pc   as decimal   no-undo .
define variable v-mode as character no-undo .
define buffer buf_goods for ub.goods  .
define buffer buf_add-line for ub.add-line  .
  run ref/addchls.w
    ( input parParentProc ,
      input 'b-mark,b-sel',
      output v-rid-list
    ) no-error .
    if error-status :error then return .
  do while v-cnt <= num-entries (v-rid-list):
    assign
      v-cnt = v-cnt + 1
      .
    find first buf_goods no-lock where recid(buf_goods) = integer (entry (v-cnt, v-rid-list)) no-error .
    if error-status :error then do:
    next.
    end.
     run str/add-dlu.w
     (  input parParentProc ,
        input this-procedure  ,
        input 'ДОБАВЛЕНИЕ':U ,
        input  x_add-doc.doc-code ,
        input  buf_goods.gds-code ,
        input-output v-recid ,
        output       v-mode-exit )
        no-error .
        if error-status :error then do:
          message
            vss-workfile vss-revision vss-description skip
            error-status :get-message(1) skip
            return-value skip
            "Ошибка"
            view-as alert-box error
          .
          undo, return .
        end.
        if v-mode-exit <> "" then do:
              find first buf_add-line exclusive-lock where recid ( buf_add-line ) = v-recid no-error .
              if available buf_add-line then do:
                if v-mode-exit = "stop-cycle" then do:
                    leave.
                end.
                if v-mode-exit = "cancel" then do:
                    next.
                end.
              end.
        end.
  end.
  OPEN QUERY BR-docsa FOR EACH x_add-line OF x_add-doc NO-LOCK,              EACH x_goods OF x_add-line NO-LOCK,              EACH x_gds-add-charges OF x_add-line NO-LOCK INDEXED-REPOSITION. .
  reposition BR-docsa to recid v-recid no-error .
  apply "entry" to BR-docsa  in frame Dialog-Frame .
  run redisp.
END.
ON CHOOSE OF B-chg IN FRAME Dialog-Frame
DO:
  IF NOT AVAILABLE  x_add-line THEN RETURN NO-APPLY.
  v-recid = recid (x_add-line) .
     run str/add-dlu.w
     (  input parParentProc ,
        input this-procedure  ,
        input 'ИЗМЕНЕНИЕ':U ,
        input  x_add-doc.doc-code ,
        input  x_add-line.gds-code ,
        input-output v-recid ,
        output       v-mode-exit )
        no-error .
        if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          error-status :get-message(1) skip
          return-value skip
          ""
          view-as alert-box error
        .
          undo, return .
        end.
  OPEN QUERY BR-docsa FOR EACH x_add-line OF x_add-doc NO-LOCK,              EACH x_goods OF x_add-line NO-LOCK,              EACH x_gds-add-charges OF x_add-line NO-LOCK INDEXED-REPOSITION. .
  reposition BR-docsa to recid v-recid no-error .
  apply "entry" to BR-docsa  in frame Dialog-Frame .
    run redisp.
END.
ON CHOOSE OF B-del IN FRAME Dialog-Frame
DO:
  IF NOT AVAILABLE  x_add-line THEN RETURN NO-APPLY.
   message "Удалить запись ?"
      view-as alert-box question
      buttons yes-no
      update g-log as log.
  if g-log = false then return no-apply.
  find current x_add-line exclusive-lock   .
  delete x_add-line.
  OPEN QUERY BR-docsa FOR EACH x_add-line OF x_add-doc NO-LOCK,              EACH x_goods OF x_add-line NO-LOCK,              EACH x_gds-add-charges OF x_add-line NO-LOCK INDEXED-REPOSITION.
  OPEN QUERY BROWSE-7 FOR EACH x_add-trn OF x_add-doc NO-LOCK,              EACH x_trn-doc WHERE x_trn-doc.doc-code = x_add-trn.trn-doc-code NO-LOCK INDEXED-REPOSITION.
  apply "entry" to BR-docsa  in frame Dialog-Frame .
   run redisp.
END.
ON CHOOSE OF B-lkp IN FRAME Dialog-Frame
DO:
find current x_add-line no-lock no-error .
IF NOT AVAILABLE  x_add-line THEN RETURN NO-APPLY.
  v-recid = recid (x_add-line) .
  run str/add-dlu.w
     (  input parParentProc ,
        input this-procedure  ,
        input 'ПРОСМОТР':U ,
        input  x_add-doc.doc-code ,
        input  x_add-line.gds-code ,
        input-output v-recid ,
        output       v-mode-exit )
        no-error .
        if error-status :error then do:
          undo, return .
        end.
  reposition BR-docsa to recid v-recid no-error .
  apply "entry" to BR-docsa  in frame Dialog-Frame .
END.
ON CHOOSE OF B-print IN FRAME Dialog-Frame
DO:
  if not available x_add-doc then return .
  run rep/r-addu.p ( parparentproc, x_add-doc.doc-code ) .
END.
ON CHOOSE OF B-quit IN FRAME Dialog-Frame
DO:
if p-mode = 'ПРОСМОТР':U then return .
define variable v-k as integer   no-undo .
  message "Вы действительно хотите отменить все изменения ?"
  view-as alert-box question
  button yes-no
  update v-ok as log
  .
  if v-ok = false then return no-apply.
  if p-mode = 'ИЗМЕНЕНИЕ':U then do:
      for each ub.add-line exclusive-lock where
              ub.add-line.doc-code  = v-doc-code :
          delete ub.add-line .
      end.
      for each old_add-line where
            old_add-line.doc-code  = v-doc-code :
            create  ub.add-line .
            buffer-copy old_add-line to ub.add-line .
      end.
      p-recid = ?.
  end.
  if p-mode = 'ДОБАВЛЕНИЕ':U then do:
      for each ub.add-line exclusive-lock where
              ub.add-line.doc-code  = v-doc-code :
          delete ub.add-line .
      end.
      for each ub.add-doc exclusive-lock where
              ub.add-doc.doc-code  = v-doc-code :
          delete ub.add-doc .
      end.
  end.
APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-trn IN FRAME Dialog-Frame
DO:
  define buffer buf_trn-doc for ub.trn-doc  .
  define variable loc-ref-list as character no-undo .
  run str/all-docs.w
 ( input  parparentproc
 ,input   x_add-doc.host-code
 ,input   x_add-doc.obj-type
 ,input   x_add-doc.obj-code
 ,input  "status-all":U
 ,input  'накл':U
 ,input  'при':U
 ,input  ?
 ,input  no
 ,input  "b-sel":U
 ,input  'ie':U
 ,input  false
 ,input  ?
 ,output loc-ref-list
 ).
if loc-ref-list = ?  or loc-ref-list = '' then return.
  find first   buf_trn-doc no-lock where recid(buf_trn-doc) = int(loc-ref-list) no-error .
  if error-status :error then return .
  define buffer buf_add-trn for ub.add-trn  .
  find first buf_add-trn where
    buf_add-trn.trn-doc-code = buf_trn-doc.doc-code
    no-error .
    if available buf_add-trn then do:
    message substitute(" Накладная &1 уже привязана к документу доп.расхода &2" , buf_trn-doc.doc-code , buf_add-trn.doc-code ) .
       return no-apply.
    end.
  find first x_add-trn where
    x_add-trn.trn-doc-code = buf_trn-doc.doc-code and
    x_add-trn.doc-code     = v-doc-code  no-error .
  if not available x_add-trn then do:
    create x_add-trn .
    assign
      x_add-trn.trn-doc-code = buf_trn-doc.doc-code
      x_add-trn.doc-code     = v-doc-code
    .
    release x_add-trn.
  end.
  else do:
   message substitute(" Накладная &1 уже привязана к документу доп.расхода" , buf_trn-doc.doc-code ) .
  end.
  OPEN QUERY BR-docsa FOR EACH x_add-line OF x_add-doc NO-LOCK,              EACH x_goods OF x_add-line NO-LOCK,              EACH x_gds-add-charges OF x_add-line NO-LOCK INDEXED-REPOSITION. .
  OPEN QUERY BROWSE-7 FOR EACH x_add-trn OF x_add-doc NO-LOCK,              EACH x_trn-doc WHERE x_trn-doc.doc-code = x_add-trn.trn-doc-code NO-LOCK INDEXED-REPOSITION.
END.
ON CHOOSE OF B-trn-del IN FRAME Dialog-Frame
DO:
  if not available x_add-trn then return .
  find current x_add-trn exclusive-lock no-error .
  delete x_add-trn.
  OPEN QUERY BR-docsa FOR EACH x_add-line OF x_add-doc NO-LOCK,              EACH x_goods OF x_add-line NO-LOCK,              EACH x_gds-add-charges OF x_add-line NO-LOCK INDEXED-REPOSITION. .
  OPEN QUERY BROWSE-7 FOR EACH x_add-trn OF x_add-doc NO-LOCK,              EACH x_trn-doc WHERE x_trn-doc.doc-code = x_add-trn.trn-doc-code NO-LOCK INDEXED-REPOSITION.
END.
ON CHOOSE OF B-trn-sel IN FRAME Dialog-Frame
DO:
    IF NOT AVAILABLE  x_add-trn THEN RETURN NO-APPLY.
    run str/showdoc.p
    ( input parparentproc
     ,input x_add-trn.trn-doc-code
     ,input ?
     ,input ?
     ,input ?
     ,input true
    ) .
END.
on leave of x_add-doc.base-rate  in frame Dialog-Frame or
   leave of x_add-doc.base-scale in frame Dialog-Frame do:
  if input frame Dialog-Frame x_add-doc.base-rate  <> x_add-doc.base-rate  or
     input frame Dialog-Frame x_add-doc.base-scale <> x_add-doc.base-scale then do:
    run check-rate no-error.
    if error-status :error then do:
       message
        "Ошибка при проверке курса" skip
        return-value
        view-as alert-box error.
       return no-apply.
    end.
  end.
end.
on choose of r-acc in frame Dialog-Frame
do:
  run choose-r-acc no-error.
  if error-status :error then return no-apply.
end.
ON LEAVE OF x_add-doc.exch-code IN FRAME Dialog-Frame
or return of x_add-doc.exch-code in frame Dialog-Frame
do:
  if input frame Dialog-Frame  x_add-doc.exch-code <> x_add-doc.exch-code then do:
    run choice-currency in this-procedure no-error.
    if error-status :error then do: return no-apply. end.
    run update-rate-doc in this-procedure no-error.
  end.
end.
ON LEAVE OF x_add-doc.exch-rate IN FRAME Dialog-Frame
or return of x_add-doc.exch-rate in frame Dialog-Frame
or leave, return of x_add-doc.exch-scale in frame Dialog-Frame
or leave, return of x_add-doc.base-rate  in frame Dialog-Frame
or leave, return of x_add-doc.base-scale in frame Dialog-Frame
do:
  run update-rate-doc in this-procedure no-error.
  if error-status :error then do:
    run disp-exch in this-procedure.
    return no-apply.
  end.
end.
ON LEAVE OF x_add-doc.fact-date IN FRAME Dialog-Frame
DO:
  run chk-upd-date in this-procedure .
END.
ON CHOOSE OF r-currency IN FRAME Dialog-Frame
DO:
  run r-proc-currency in this-procedure.
END.
ON LEAVE OF x_add-doc.shift-date IN FRAME Dialog-Frame
do:
  if input frame Dialog-Frame x_add-doc.shift-date <> x_add-doc.shift-date then do:
    assign
      x_add-doc.shift-name = ""
      x_add-doc.shift-num  = 0.
    display x_add-doc.shift-name x_add-doc.shift-num with frame Dialog-Frame.
    apply "entry" to x_add-doc.shift-name in frame Dialog-Frame.
    return no-apply.
  end.
end.
on return of x_add-doc.shift-date in frame Dialog-Frame do:
  apply "entry" to x_add-doc.shift-name in frame Dialog-Frame.
  return no-apply.
end.
on return of x_add-doc.shift-name in frame Dialog-Frame do:
  apply "entry" to b-add in frame Dialog-Frame.
  return no-apply.
end.
on return of x_add-doc.shift-num in frame Dialog-Frame do:
  apply "entry" to b-add in frame Dialog-Frame.
  return no-apply.
end.
on choose of r-sht in frame Dialog-Frame do:
  run proc-sht.
end.
on leave of x_add-doc.shift-num  in frame Dialog-Frame do:
  run proc-shift-num no-error.
  if error-status:error then do:
    return no-apply.
  end.
end.
on leave of x_add-doc.shift-name in frame Dialog-Frame do:
  run proc-shift-name no-error.
  if error-status:error then do:
    return no-apply.
  end.
end.
ON VALUE-CHANGED OF x_add-doc.VAT-type IN FRAME Dialog-Frame
DO:
  assign x_add-doc.VAT-type.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of x_add-doc.doc-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on delete-character of x_add-doc.doc-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on ctrl-d of x_add-doc.doc-date in frame Dialog-Frame
do:
  define variable v-curr-sv-date as date no-undo .
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    run gbl/getcurdt.p
      (output v-curr-sv-date
      ) .
    assign
      self :screen-value = string(v-curr-sv-date) .
    .
  end.
  return no-apply.
end.
on ctrl-b of x_add-doc.doc-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      assign
        v-new-sv-date = date( month(v-curr-sv-date), 1, year(v-curr-sv-date))
      .
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-e of x_add-doc.doc-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/lastdate.p
        (input  v-curr-sv-date
        ,output v-new-sv-date
        ).
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-f of x_add-doc.doc-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-ok            as logical   no-undo .
    define variable v-curr-sv-date  as date      no-undo .
    define variable v-description   as character no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/d-inpday.w
        (input ?
        ,input "Выбор даты"
        ,input v-description
        ,input ""
        ,input-output v-curr-sv-date
        ,output v-ok
        ).
      if v-ok = true
      then do:
        assign
          self :screen-value = string(v-curr-sv-date) .
        .
      end.
    end.
  end.
  return no-apply .
end.
  define MENU m-ed-date8
    MENU-ITEM m-ed-date8-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date8-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date8-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date8-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if x_add-doc.doc-date :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      x_add-doc.doc-date :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date8 :HANDLE
      x_add-doc.doc-date :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle8 as handle no-undo .
  assign
    v-label-handle8 = x_add-doc.doc-date :side-label-handle in frame Dialog-Frame
  .
  if valid-handle (v-label-handle8)
  then do:
    if v-label-handle8 :tooltip = ""
    or v-label-handle8 :tooltip = ?
    then do:
      assign
        v-label-handle8 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date8-1 in menu m-ed-date8 DO:
    apply "ctrl-b":U to x_add-doc.doc-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date8-2 in menu m-ed-date8 DO:
    apply "ctrl-d":U to x_add-doc.doc-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date8-3 in menu m-ed-date8 DO:
    apply "ctrl-e":U to x_add-doc.doc-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date8-4 in menu m-ed-date8 DO:
    apply "ctrl-f":U to x_add-doc.doc-date in frame Dialog-Frame .
  END.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of x_add-doc.fact-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on delete-character of x_add-doc.fact-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on ctrl-d of x_add-doc.fact-date in frame Dialog-Frame
do:
  define variable v-curr-sv-date as date no-undo .
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    run gbl/getcurdt.p
      (output v-curr-sv-date
      ) .
    assign
      self :screen-value = string(v-curr-sv-date) .
    .
  end.
  return no-apply.
end.
on ctrl-b of x_add-doc.fact-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      assign
        v-new-sv-date = date( month(v-curr-sv-date), 1, year(v-curr-sv-date))
      .
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-e of x_add-doc.fact-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/lastdate.p
        (input  v-curr-sv-date
        ,output v-new-sv-date
        ).
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-f of x_add-doc.fact-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-ok            as logical   no-undo .
    define variable v-curr-sv-date  as date      no-undo .
    define variable v-description   as character no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/d-inpday.w
        (input ?
        ,input "Выбор даты"
        ,input v-description
        ,input ""
        ,input-output v-curr-sv-date
        ,output v-ok
        ).
      if v-ok = true
      then do:
        assign
          self :screen-value = string(v-curr-sv-date) .
        .
      end.
    end.
  end.
  return no-apply .
end.
  define MENU m-ed-date10
    MENU-ITEM m-ed-date10-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date10-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date10-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date10-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if x_add-doc.fact-date :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      x_add-doc.fact-date :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date10 :HANDLE
      x_add-doc.fact-date :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle10 as handle no-undo .
  assign
    v-label-handle10 = x_add-doc.fact-date :side-label-handle in frame Dialog-Frame
  .
  if valid-handle (v-label-handle10)
  then do:
    if v-label-handle10 :tooltip = ""
    or v-label-handle10 :tooltip = ?
    then do:
      assign
        v-label-handle10 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date10-1 in menu m-ed-date10 DO:
    apply "ctrl-b":U to x_add-doc.fact-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date10-2 in menu m-ed-date10 DO:
    apply "ctrl-d":U to x_add-doc.fact-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date10-3 in menu m-ed-date10 DO:
    apply "ctrl-e":U to x_add-doc.fact-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date10-4 in menu m-ed-date10 DO:
    apply "ctrl-f":U to x_add-doc.fact-date in frame Dialog-Frame .
  END.
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of x_add-doc.shift-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on delete-character of x_add-doc.shift-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on ctrl-d of x_add-doc.shift-date in frame Dialog-Frame
do:
  define variable v-curr-sv-date as date no-undo .
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    run gbl/getcurdt.p
      (output v-curr-sv-date
      ) .
    assign
      self :screen-value = string(v-curr-sv-date) .
    .
  end.
  return no-apply.
end.
on ctrl-b of x_add-doc.shift-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      assign
        v-new-sv-date = date( month(v-curr-sv-date), 1, year(v-curr-sv-date))
      .
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-e of x_add-doc.shift-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/lastdate.p
        (input  v-curr-sv-date
        ,output v-new-sv-date
        ).
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-f of x_add-doc.shift-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-ok            as logical   no-undo .
    define variable v-curr-sv-date  as date      no-undo .
    define variable v-description   as character no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/d-inpday.w
        (input ?
        ,input "Выбор даты"
        ,input v-description
        ,input ""
        ,input-output v-curr-sv-date
        ,output v-ok
        ).
      if v-ok = true
      then do:
        assign
          self :screen-value = string(v-curr-sv-date) .
        .
      end.
    end.
  end.
  return no-apply .
end.
  define MENU m-ed-date12
    MENU-ITEM m-ed-date12-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date12-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date12-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date12-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if x_add-doc.shift-date :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      x_add-doc.shift-date :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date12 :HANDLE
      x_add-doc.shift-date :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle12 as handle no-undo .
  assign
    v-label-handle12 = x_add-doc.shift-date :side-label-handle in frame Dialog-Frame
  .
  if valid-handle (v-label-handle12)
  then do:
    if v-label-handle12 :tooltip = ""
    or v-label-handle12 :tooltip = ?
    then do:
      assign
        v-label-handle12 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date12-1 in menu m-ed-date12 DO:
    apply "ctrl-b":U to x_add-doc.shift-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date12-2 in menu m-ed-date12 DO:
    apply "ctrl-d":U to x_add-doc.shift-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date12-3 in menu m-ed-date12 DO:
    apply "ctrl-e":U to x_add-doc.shift-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date12-4 in menu m-ed-date12 DO:
    apply "ctrl-f":U to x_add-doc.shift-date in frame Dialog-Frame .
  END.
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
        v-diasize-browse-handle     = browse BR-docsa :handle
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
define variable curclivalue      as character no-undo .
define variable curclitype       as character no-undo .
define variable base-abbr as character no-undo .
define variable exch-abbr as character no-undo .
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
empty temp-table thbjattr_thbj-attr.
run adm/shattri.p (
   input "get":U
  ,input v-cntxt-obj-type
  ,input v-cntxt-obj-code
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
    if thbjattr_thbj-attr.prop-code = 'curcli'   then curclivalue   = string (thbjattr_thbj-attr.property-value-logical) .
end.
x_goods.gds-name:resizable in browse BR-docsa   = true .
x_goods.gds-name:width     in browse BR-docsa   = 15 .
define variable varbase-code as integer no-undo.
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  v-cntxt-host-code-obj
  ,output varbase-code
  )  .
run init-proc in this-procedure .
run  get-var-2 in this-procedure
    ( output base-abbr
       ) .
x_add-doc.sum-base:label in frame Dialog-Frame  = "Сумма,"  + base-abbr .
x_add-doc.sum-rubl:label in frame Dialog-Frame  = "Сумма,руб"  .
  if p-mode = 'ПРОСМОТР':U
     then run enable_lkp in this-procedure .
     else run enable_my  in this-procedure .
  disable x_add-doc.VAT-type
  r-currency
  x_add-doc.exch-code
  with frame Dialog-Frame .
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
run disable_ui in this-procedure .
PROCEDURE check-exch :
    x_add-doc.exch-date  = today .
    x_add-doc.exch-code = 0 .
  find currency where currency.curr-code = x_add-doc.exch-code  no-lock no-error.
  if not available currency then do:
    message "Неправильная валюта  - такой валюты нет.".
    apply "entry" to x_add-doc.exch-code in frame Dialog-Frame.
    return error.
  end.
  if x_add-doc.exch-code <> currency.curr-code then do:
    if currency.curr-code = 0 then do:
      if (x_add-doc.exch-rate <> ? and x_add-doc.exch-scale <> ? and
          (x_add-doc.exch-rate <> 1 or x_add-doc.exch-scale <> 1)) then do:
      end.
      assign
        x_add-doc.exch-rate = 1
        x_add-doc.exch-scale = 1.
      disable x_add-doc.exch-rate x_add-doc.exch-scale r-acc with frame Dialog-Frame.
    end.
    else do:
      find last curr-accnt where curr-accnt.curr-code = currency.curr-code
                             and curr-accnt.exch-date <= input x_add-doc.exch-date use-index pi no-lock no-error.
      if available curr-accnt then do:
        assign
          x_add-doc.exch-rate = curr-accnt.exch-rate
          x_add-doc.exch-scale = curr-accnt.exch-scale.
      end.
      else do:
        assign
          x_add-doc.exch-rate = ?
          x_add-doc.exch-scale = ?.
      end.
      if x_add-doc.exch-code = 0 and
        (x_add-doc.exch-rate  <> ? and
         x_add-doc.exch-scale <> ? and
         (x_add-doc.exch-rate <> 1 or x_add-doc.exch-scale <> 1)
        ) then do:
      end.
      enable x_add-doc.exch-rate x_add-doc.exch-scale r-acc with frame Dialog-Frame.
    end.
    assign
      x_add-doc.exch-code = currency.curr-code.
  end.
END PROCEDURE.
PROCEDURE check-rate :
define variable flag-recount as logical initial no no-undo.
if
   input frame Dialog-Frame x_add-doc.base-rate  <> x_add-doc.base-rate  or
   input frame Dialog-Frame x_add-doc.base-scale <> x_add-doc.base-scale then flag-recount = yes.
if input frame Dialog-Frame x_add-doc.base-rate = ? or
   input frame Dialog-Frame x_add-doc.base-rate = 0 then do:
  message "Не задан курс базовой валюты.".
  apply "entry" to x_add-doc.base-rate in frame Dialog-Frame.
  return error.
end.
if input frame Dialog-Frame x_add-doc.base-scale = ? or
   input frame Dialog-Frame x_add-doc.base-scale = 0 then do:
  message "Не задан масштаб базовой валюты.".
  apply "entry" to x_add-doc.base-scale in frame Dialog-Frame.
  return error.
end.
assign frame Dialog-Frame
  x_add-doc.base-rate
  x_add-doc.base-scale.
run waitfram-show in this-procedure  ("ЖДИТЕ.  Пересчет документа ...").
if flag-recount then do:
   run full-recount.
end.
run waitfram-hide in this-procedure  .
END PROCEDURE.
PROCEDURE check-update :
END PROCEDURE.
PROCEDURE chk-upd-date :
END PROCEDURE.
PROCEDURE choice-currency :
find currency where currency.curr-code = input frame Dialog-Frame x_add-doc.exch-code no-error.
if not available currency then do:
  run ref/currency.w ( input parparentproc, input "b-sel", input-output ref-rec ).
  if ref-rec = ? then do: return error. end.
  find currency where recid ( currency ) = ref-rec.
end.
RUN exch-rate in this-procedure.
END PROCEDURE.
PROCEDURE choose-r-acc :
define variable v-today      as date    no-undo.
run check-update no-error.
if error-status :error then return error.
run check-exch no-error.
if error-status :error then return error.
define variable varlog as logical   no-undo .
varlog = yes.
message "Подставить БИРЖЕВЫЕ курсы базовой валюты и валюты документа :"
        currency.curr-abbr "на дату растаможивания ?"
view-as alert-box question buttons OK-Cancel update varlog.
if varlog <> true then do:
  return error.
end.
find last curr-accnt where curr-accnt.curr-code = varbase-code and
                         curr-accnt.exch-date <= input frame Dialog-Frame x_add-doc.exch-date use-index pi no-lock no-error.
if not available curr-accnt then do:
  message "На эту дату неизвестен курс базовой валюты.".
  apply "entry" to x_add-doc.base-rate in frame Dialog-Frame.
  return error.
end.
disp curr-accnt.exch-rate  @ x_add-doc.base-rate
     curr-accnt.exch-scale @ x_add-doc.base-scale with frame Dialog-Frame.
run check-rate.
find last curr-accnt where curr-accnt.curr-code = input x_add-doc.exch-code
          and curr-accnt.exch-date <= input x_add-doc.exch-date use-index pi no-lock no-error.
if not available curr-accnt then do:
  message "На дату " + input x_add-doc.exch-date + " неизвестен курс валюты поставщика.".
  apply "entry" to x_add-doc.exch-rate.
  return error.
end.
display curr-accnt.exch-rate  @ x_add-doc.exch-rate
        curr-accnt.exch-scale @ x_add-doc.exch-scale with frame Dialog-Frame.
run check-rate.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE disp-exch :
END PROCEDURE.
PROCEDURE enable_lkp :
  OPEN QUERY Dialog-Frame FOR EACH x_add-doc SHARE-LOCK.
  GET FIRST Dialog-Frame.
  DISPLAY v-obj-name  f-summa f-vat
      WITH FRAME Dialog-Frame.
  IF AVAILABLE x_add-doc THEN
    DISPLAY x_add-doc.base-rate x_add-doc.base-scale
          x_add-doc.doc-date x_add-doc.fact-date x_add-doc.shift-date
          x_add-doc.shift-name x_add-doc.shift-num x_add-doc.VAT-type
          x_add-doc.obj-type x_add-doc.obj-code x_add-doc.doc-code
          x_add-doc.sum-base x_add-doc.VAT-base x_add-doc.sum-rubl
          x_add-doc.VAT-rubl
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  hide B-exit in frame Dialog-Frame .
  enable B-trn-sel B-quit B-lkp BROWSE-7 BR-docsa b-help B-print with frame Dialog-Frame .
  B-quit:label = "Выход" .
  B-quit:column = 1 .
  OPEN QUERY BR-docsa FOR EACH x_add-line OF x_add-doc NO-LOCK,              EACH x_goods OF x_add-line NO-LOCK,              EACH x_gds-add-charges OF x_add-line NO-LOCK INDEXED-REPOSITION.    OPEN QUERY BROWSE-7 FOR EACH x_add-trn OF x_add-doc NO-LOCK,              EACH x_trn-doc WHERE x_trn-doc.doc-code = x_add-trn.trn-doc-code NO-LOCK INDEXED-REPOSITION.
END PROCEDURE.
PROCEDURE enable_my :
  OPEN QUERY Dialog-Frame FOR EACH x_add-doc SHARE-LOCK.
  GET FIRST Dialog-Frame.
  DISPLAY v-obj-name  f-summa f-vat
      WITH FRAME Dialog-Frame.
  IF AVAILABLE x_add-doc THEN
    DISPLAY
          x_add-doc.base-rate x_add-doc.base-scale
          x_add-doc.doc-date x_add-doc.fact-date x_add-doc.shift-date
          x_add-doc.shift-name x_add-doc.shift-num x_add-doc.VAT-type
          x_add-doc.obj-type x_add-doc.obj-code x_add-doc.doc-code
          x_add-doc.sum-base x_add-doc.VAT-base x_add-doc.sum-rubl
          x_add-doc.VAT-rubl
      WITH FRAME Dialog-Frame.
  ENABLE B-exit B-quit B-Help B-trn B-trn-del B-trn-sel
 BROWSE-7
         x_add-doc.base-rate x_add-doc.base-scale
         x_add-doc.doc-date x_add-doc.VAT-type
         B-add B-lkp B-chg B-del BR-docsa  f-summa f-vat
         B-print
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  OPEN QUERY BR-docsa FOR EACH x_add-line OF x_add-doc NO-LOCK,              EACH x_goods OF x_add-line NO-LOCK,              EACH x_gds-add-charges OF x_add-line NO-LOCK INDEXED-REPOSITION.    OPEN QUERY BROWSE-7 FOR EACH x_add-trn OF x_add-doc NO-LOCK,              EACH x_trn-doc WHERE x_trn-doc.doc-code = x_add-trn.trn-doc-code NO-LOCK INDEXED-REPOSITION.
  if curclivalue <> "no" then do:
      if  x_add-doc.exch-code <> 0 then do:
        enable r-acc x_add-doc.exch-rate x_add-doc.exch-scale with frame Dialog-Frame.
      end.
  end.
  else do:
    hide r-acc r-currency in frame Dialog-Frame.
  end.
  if x_add-doc.exch-rate = 1 and  x_add-doc.exch-scale = 1 then
     disable x_add-doc.exch-rate x_add-doc.exch-scale r-acc with frame Dialog-Frame.
  define variable l-shift-on as logical no-undo .
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,input  'shift-on=request'
  ,output l-shift-on
  )  .
  if l-shift-on = false then hide
     x_add-doc.shift-date
     x_add-doc.shift-num
     x_add-doc.shift-name
     r-sht in frame Dialog-Frame .
   if varbase-code = 0 then disable x_add-doc.base-rate x_add-doc.base-scale with frame Dialog-Frame .
END PROCEDURE.
PROCEDURE enable_UI :
  OPEN QUERY Dialog-Frame FOR EACH x_add-doc SHARE-LOCK.
  GET FIRST Dialog-Frame.
  DISPLAY v-obj-name f-summa f-vat
      WITH FRAME Dialog-Frame.
  IF AVAILABLE x_add-doc THEN
    DISPLAY x_add-doc.base-rate x_add-doc.base-scale x_add-doc.doc-date
          x_add-doc.fact-date x_add-doc.shift-date x_add-doc.shift-name
          x_add-doc.shift-num x_add-doc.VAT-type x_add-doc.obj-type
          x_add-doc.obj-code x_add-doc.doc-code x_add-doc.sum-base
          x_add-doc.VAT-base x_add-doc.sum-rubl x_add-doc.VAT-rubl
      WITH FRAME Dialog-Frame.
  ENABLE B-exit B-quit B-print B-Help B-trn B-trn-del B-trn-sel BROWSE-7
         x_add-doc.base-rate x_add-doc.base-scale x_add-doc.doc-date
         x_add-doc.fact-date x_add-doc.shift-date x_add-doc.shift-name
         x_add-doc.shift-num r-sht x_add-doc.VAT-type B-add B-lkp B-chg B-del
         BR-docsa x_add-doc.obj-type f-summa f-vat
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  OPEN QUERY BR-docsa FOR EACH x_add-line OF x_add-doc NO-LOCK,              EACH x_goods OF x_add-line NO-LOCK,              EACH x_gds-add-charges OF x_add-line NO-LOCK INDEXED-REPOSITION.    OPEN QUERY BROWSE-7 FOR EACH x_add-trn OF x_add-doc NO-LOCK,              EACH x_trn-doc WHERE x_trn-doc.doc-code = x_add-trn.trn-doc-code NO-LOCK INDEXED-REPOSITION.
END PROCEDURE.
PROCEDURE exch-rate :
display currency.curr-code @ x_add-doc.exch-code with frame Dialog-Frame.
do transaction on error   undo, return error :
   run check-exch   in this-procedure.
   run check-rate   in this-procedure.
   run full-recount in this-procedure.
end.
END PROCEDURE.
PROCEDURE f-curr :
  define variable   vdoc-date   as date no-undo .
  define variable vexch-rate  as decimal   no-undo .
  define variable vexch-scale as decimal   no-undo .
  assign
  vdoc-date    =    x_add-doc.doc-date
  vexch-rate   =    x_add-doc.exch-rate
  vexch-scale  =    x_add-doc.exch-scale
  .
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run exchrate in g#library
  (input  x_add-doc.exch-code
  ,input  vdoc-date
  ,output vexch-rate
  ,output vexch-scale
  ,output scr-curr-abbr
  )  .
END PROCEDURE.
PROCEDURE full-recount :
for each x_add-line exclusive-lock  where
           x_add-line.doc-code = x_add-doc.doc-code
           :
           x_add-line.sum-base = x_add-line.sum-rubl / x_add-doc.base-rate * x_add-doc.base-scale.
           x_add-line.vat-base = x_add-line.vat-rubl / x_add-doc.base-rate * x_add-doc.base-scale.
  end.
END PROCEDURE.
PROCEDURE get-var :
define output parameter pbase-rate  as decimal   no-undo .
define output parameter pbase-scale as decimal   no-undo .
define output parameter pvat-type   as character no-undo .
find first  x_add-doc.
assign frame Dialog-Frame
x_add-doc.base-rate x_add-doc.base-scale x_add-doc.doc-date x_add-doc.fact-date x_add-doc.shift-date x_add-doc.shift-name x_add-doc.shift-num x_add-doc.VAT-type x_add-doc.obj-type
.
assign
pbase-rate  = x_add-doc.base-rate
pbase-scale = x_add-doc.base-scale
pvat-type   = x_add-doc.vat-type
.
END PROCEDURE.
PROCEDURE get-var-2 :
define output parameter base-code-abbr as character no-undo .
define variable v-base-code    as integer   no-undo .
define variable vv-exch-rate   as decimal   no-undo .
define variable vv-exch-scale  as integer   no-undo .
find first  x_add-doc .
assign frame Dialog-Frame
x_add-doc.base-rate x_add-doc.base-scale x_add-doc.doc-date x_add-doc.fact-date x_add-doc.shift-date x_add-doc.shift-name x_add-doc.shift-num x_add-doc.VAT-type x_add-doc.obj-type
.
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  x_add-doc.host-code
  ,output v-base-code
  )  .
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run exchrate in g#library
  (input  v-base-code
  ,input  today
  ,output vv-exch-rate
  ,output vv-exch-scale
  ,output base-code-abbr
  )  .
END PROCEDURE.
PROCEDURE init-proc :
x_add-doc.VAT-type:LIST-ITEMS in frame Dialog-Frame =  'нет':U + "," + 'в т. ч.':U + "," + 'без':U .
if p-mode = 'ДОБАВЛЕНИЕ':U then do:
   run doc-code in this-procedure (
     input   "main":u
    ,input   v-cntxt-obj-type
    ,input   v-cntxt-obj-code
    ,input   ""
    ,output  v-doc-code ) .
   if p-doc-code <> "" then do:
      message "Из накладной" view-as alert-box information .
        create x_add-trn .
        assign
          x_add-trn.trn-doc-code = p-doc-code
          x_add-trn.doc-code     = v-doc-code
        .
      release x_add-trn.
   end.
   create x_add-doc.
   assign
     x_add-doc.doc-code   = v-doc-code
     x_add-doc.doc-date   = today
     x_add-doc.exch-code  = 0
     x_add-doc.exch-date  = x_add-doc.doc-date
     x_add-doc.host-code  = v-cntxt-host-code-obj
     x_add-doc.obj-code   = v-cntxt-obj-code
     x_add-doc.obj-type   = v-cntxt-obj-type
     x_add-doc.status_    = 'новый':U
     x_add-doc.cr-db-num  = v-cntxt-db-num
     x_add-doc.creid      = v-cntxt-userid
     x_add-doc.doc-type   = 'при':U
   .
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run baserate in g#library
  (input  x_add-doc.host-code
  ,input  x_add-doc.doc-date
  ,output x_add-doc.base-rate
  ,output x_add-doc.base-scale
  )  .
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run exchrate in g#library
  (input  x_add-doc.exch-code
  ,input  x_add-doc.doc-date
  ,output x_add-doc.exch-rate
  ,output x_add-doc.exch-scale
  ,output v-curr-abbr
  )  .
  define variable l-shift-on as logical no-undo .
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,input  'shift-on=request'
  ,output l-shift-on
  )  .
  if l-shift-on = true then do:
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curshift in g#library
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output x_add-doc.shift-date
  ,output x_add-doc.shift-num
  ,output x_add-doc.shift-name
  )  .
  end.
  run adm/shattri.p (
      input "get":U
      ,input v-cntxt-obj-type
      ,input v-cntxt-obj-code
      ,input 'nakl_par':U
      ,input  "type-vat"
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output varvat-type
      ,output v-value-logical
      ,output varvat-type-type
      ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
      ) no-error .
      if error-status :error then varvat-type = 1 .
    case varvat-type:
    when 1 or when ? then do:
      assign
        x_add-doc.vat-type = 'в т. ч.':U.
    end.
    when 2 then do:
      assign
        x_add-doc.vat-type = 'нет':U.
    end.
    when 3 then do:
       assign
        x_add-doc.vat-type = 'без':U.
    end.
    otherwise do:
      message "Не верно задан атрибут 'Тип заведения НДС' (type-vat)."
              "Задано значение: " varvat-type
              "Допустимые значения: 1,2,3."
      view-as alert-box error.
      return error.
    end.
    end case.
end.
else do:
   if p-mode = 'ПРОСМОТР':U then find first ub.add-doc no-lock where recid(ub.add-doc) = p-recid no-error .
      else  find first ub.add-doc exclusive-lock where recid(ub.add-doc) = p-recid no-error .
   if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        error-status :get-message(1) skip
        return-value skip
        "Ошибка"
        view-as alert-box error
      .
      return .
   end.
   create x_add-doc.
   buffer-copy ub.add-doc to x_add-doc .
   v-doc-code = ub.add-doc.doc-code .
end.
if p-mode = 'ИЗМЕНЕНИЕ':U then do:
 for each ub.add-line where
          ub.add-line.doc-code  = v-doc-code :
  create  old_add-line .
  buffer-copy ub.add-line to old_add-line .
 end.
end.
define buffer obj_clients for ub.clients  .
find first obj_clients no-lock where
           obj_clients.obj-code = v-cntxt-obj-code and
           obj_clients.obj-type = v-cntxt-obj-type  .
v-obj-name = obj_clients.obj-name .
display v-obj-name with frame Dialog-Frame .
run f-curr in this-procedure .
OPEN QUERY BROWSE-7 FOR EACH x_add-trn OF x_add-doc NO-LOCK,              EACH x_trn-doc WHERE x_trn-doc.doc-code = x_add-trn.trn-doc-code NO-LOCK INDEXED-REPOSITION.
END PROCEDURE.
PROCEDURE proc-save :
define variable v-sum-rubl as decimal   no-undo .
define variable v-sum-base as decimal   no-undo .
define variable v-vat-rubl as decimal   no-undo .
define variable v-vat-base as decimal   no-undo .
  assign frame Dialog-Frame
    x_add-doc.base-rate x_add-doc.base-scale x_add-doc.doc-date x_add-doc.fact-date x_add-doc.shift-date x_add-doc.shift-name x_add-doc.shift-num x_add-doc.VAT-type x_add-doc.obj-type
  .
  assign
    v-sum-rubl = 0
    v-sum-base = 0
    v-vat-rubl = 0
    v-vat-base = 0
  .
define variable v-kol-l as integer   no-undo .
 v-kol-l = 0 .
  for each x_add-line no-lock  where
           x_add-line.doc-code = x_add-doc.doc-code
           :
      assign
        v-sum-rubl = v-sum-rubl + x_add-line.sum-rubl
        v-sum-base = v-sum-base + x_add-line.sum-base
        v-vat-rubl = v-vat-rubl + x_add-line.vat-rubl
        v-vat-base = v-vat-base + x_add-line.vat-base
        v-kol-l = v-kol-l + 1
        .
  end.
  for EACH x_trn-doc no-lock  WHERE x_trn-doc.doc-code = x_add-trn.trn-doc-code :
        v-kol-l = v-kol-l + 1 .
  end.
  if v-kol-l = 0 then do:
     p-recid = ? .
     message  "Документ не содержит ни одной строки и ни одной связки с ПН , ДопРасход будет удален !"  view-as alert-box information .
     delete x_add-doc .
     return.
  end.
  assign
    x_add-doc.sum-rubl = v-sum-rubl
    x_add-doc.sum-base = v-sum-base
    x_add-doc.vat-rubl = v-vat-rubl
    x_add-doc.vat-base = v-vat-base
  .
  if p-mode = 'ДОБАВЛЕНИЕ':U then do:
    create ub.add-doc.
  end.
  buffer-copy x_add-doc to ub.add-doc .
  p-recid = recid (ub.add-doc) .
END PROCEDURE.
PROCEDURE proc-shift-num :
define buffer bf_shift-obj   for ub.shift-obj.
  if input frame Dialog-Frame x_add-doc.shift-num <> x_add-doc.shift-num then do:
    if input frame Dialog-Frame x_add-doc.shift-date <> ? then do:
      find first bf_shift-obj where bf_shift-obj.obj-type   = x_add-doc.obj-type                             and
                                    bf_shift-obj.obj-code   = x_add-doc.obj-code                             and
                                    bf_shift-obj.shift-date = input frame Dialog-Frame x_add-doc.shift-date and
                                    bf_shift-obj.shift-num  = input frame Dialog-Frame x_add-doc.shift-num  no-lock no-error.
      if not available bf_shift-obj then do:
        message "Не найдена смена: " x_add-doc.obj-type " " x_add-doc.obj-code
                " Дата " input frame Dialog-Frame x_add-doc.shift-date " Порядок смены " input frame Dialog-Frame x_add-doc.shift-num " ."
        view-as alert-box error.
        display x_add-doc.shift-num with frame Dialog-Frame.
        run proc-sht no-error.
        if error-status:error then do:
          return error.
        end.
      end.
      else do:
        assign
          x_add-doc.shift-date = bf_shift-obj.shift-date
          x_add-doc.shift-num  = bf_shift-obj.shift-num
          x_add-doc.shift-name = bf_shift-obj.shift-name.
        display x_add-doc.shift-date x_add-doc.shift-num x_add-doc.shift-name with frame Dialog-Frame.
        if x_add-doc.fact-date = ? then do:
          assign
            x_add-doc.fact-date = x_add-doc.shift-date
            x_add-doc.fact-time = (24 * 60 * 60).
          display x_add-doc.fact-date with frame Dialog-Frame.
        end.
      end.
    end.
  end.
end procedure.
procedure proc-shift-name :
  define buffer bf_shift-obj   for ub.shift-obj.
  define variable varfind-shift as integer initial 0.
  define variable varshift-date like ub.shift-obj.shift-date no-undo.
  define variable varshift-num  like ub.shift-obj.shift-num  no-undo.
  if input frame Dialog-Frame x_add-doc.shift-name <> x_add-doc.shift-name then do:
    if input frame Dialog-Frame x_add-doc.shift-date <> ? then do:
      for each  bf_shift-obj where bf_shift-obj.obj-type   = x_add-doc.obj-type                             and
                                   bf_shift-obj.obj-code   = x_add-doc.obj-code                             and
                                   bf_shift-obj.shift-date = input frame Dialog-Frame x_add-doc.shift-date and
                                   bf_shift-obj.shift-name = input frame Dialog-Frame x_add-doc.shift-name no-lock on error undo, return error return-value :
        assign
          varfind-shift = varfind-shift + 1
          varshift-date = bf_shift-obj.shift-date
          varshift-num  = bf_shift-obj.shift-num.
      end.
      if varfind-shift = 0 or varfind-shift > 1 then do:
        if varfind-shift = 0 then do:
          message "Не найдена смена: " x_add-doc.obj-type " " x_add-doc.obj-code
                  " Дата " input frame Dialog-Frame x_add-doc.shift-date " Номер смены " input frame Dialog-Frame x_add-doc.shift-name " ."
          view-as alert-box error.
        end.
        else do:
          message "Найдено более одной смены с одним номером в сменном дне. Объект: " x_add-doc.obj-type " " x_add-doc.obj-code
                  " Дата " input frame Dialog-Frame x_add-doc.shift-date " Номер смены " input frame Dialog-Frame x_add-doc.shift-name " ."
          view-as alert-box error.
        end.
        display x_add-doc.shift-name with frame Dialog-Frame.
        run proc-sht no-error.
        if error-status:error then do: return error. end.
      end.
      else do:
        assign frame Dialog-Frame
          x_add-doc.shift-name.
        assign
          x_add-doc.shift-date = varshift-date
          x_add-doc.shift-num  = varshift-num.
        display x_add-doc.shift-date x_add-doc.shift-num x_add-doc.shift-name with frame Dialog-Frame.
        if x_add-doc.fact-date = ? then do: assign x_add-doc.fact-date = x_add-doc.shift-date x_add-doc.fact-time = (24 * 60 * 60). display x_add-doc.fact-date with frame Dialog-Frame. end.
      end.
    end.
  end.
end procedure.
PROCEDURE proc-sht :
define buffer bf_shift-obj   for ub.shift-obj.
  define variable varrid-list as character no-undo.
  define variable varrecid    as recid     no-undo.
  assign
    varrid-list = "".
  run str/sht-all.w (parparentproc, v-cntxt-obj-type, v-cntxt-obj-code, 'b-sel', 'obj', x_add-doc.obj-type, x_add-doc.obj-code ,'':u, input-output varrid-list) no-error.
  if error-status:error or varrid-list = "":u then do:
    return error.
  end.
  else do:
    assign
      varrecid = integer (entry(1, varrid-list)).
    find first bf_shift-obj where recid(bf_shift-obj) = varrecid no-lock no-error.
    if available bf_shift-obj then do:
      assign
        x_add-doc.shift-date = bf_shift-obj.shift-date
        x_add-doc.shift-num  = bf_shift-obj.shift-num
        x_add-doc.shift-name = bf_shift-obj.shift-name.
      display x_add-doc.shift-date x_add-doc.shift-num x_add-doc.shift-name with frame Dialog-Frame.
      if x_add-doc.fact-date = ? then do:
        assign
          x_add-doc.fact-date = x_add-doc.shift-date
          x_add-doc.fact-time = (24 * 60 * 60).
        display x_add-doc.fact-date with frame Dialog-Frame.
      end.
    end.
  end.
END PROCEDURE.
PROCEDURE r-proc-currency :
run ref/currency.w ( input parparentproc, input "b-sel", input-output ref-rec ).
  if ref-rec = ? then do:
     return no-apply.
  end.
  find ub.currency no-lock where recid( ub.currency ) = ref-rec no-error.
  if not available ub.currency then do:
     return no-apply.
  end.
  if ub.currency.curr-code <> x_add-doc.exch-code then do:
   display ub.currency.curr-code @ x_add-doc.exch-code with frame Dialog-Frame .
  end.
  RUN exch-rate    in this-procedure.
  RUN full-recount in this-procedure.
END PROCEDURE.
PROCEDURE redisp :
define variable v-sum-rubl as decimal   no-undo .
define variable v-sum-base as decimal   no-undo .
define variable v-vat-rubl as decimal   no-undo .
define variable v-vat-base as decimal   no-undo .
  assign
    v-sum-rubl = 0
    v-sum-base = 0
    v-vat-rubl = 0
    v-vat-base = 0
  .
  for each x_add-line no-lock  where
           x_add-line.doc-code = x_add-doc.doc-code
           :
      assign
        v-sum-rubl = v-sum-rubl + x_add-line.sum-rubl
        v-sum-base = v-sum-base + x_add-line.sum-base
        v-vat-rubl = v-vat-rubl + x_add-line.vat-rubl
        v-vat-base = v-vat-base + x_add-line.vat-base
        .
  end.
 display v-sum-rubl @ x_add-doc.sum-rubl
         v-sum-base @ x_add-doc.sum-base
         v-vat-rubl @ x_add-doc.vat-rubl
         v-vat-base @ x_add-doc.vat-base
         with frame Dialog-Frame .
END PROCEDURE.
PROCEDURE update-rate-doc :
if input frame Dialog-Frame x_add-doc.exch-rate  <> x_add-doc.exch-rate  or
   input frame Dialog-Frame x_add-doc.exch-scale <> x_add-doc.exch-scale or
   input frame Dialog-Frame x_add-doc.base-rate  <> x_add-doc.base-rate  or
   input frame Dialog-Frame x_add-doc.base-scale <> x_add-doc.base-scale then
   do transaction on error undo, return error return-value :
     run check-exch   in this-procedure no-error.
     if error-status :error then do: return error return-value. end.
     run check-update in this-procedure no-error.
     if error-status :error then do: return error return-value. end.
     run check-rate   in this-procedure no-error.
     if error-status :error then do: return error return-value. end.
    end.
END PROCEDURE.
