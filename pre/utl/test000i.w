define input parameter parparentproc as widget-handle no-undo .
define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "тест корректности отчета о продаже - накладные- чеки" .
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#trdcalib as handle no-undo.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION set-inkas-PS returns character(    input p-ps as character,
                                            input p-chk-amount as integer,
                                            input p-gds-amount as integer,
                                            input p-line-out as integer,
                                            input p-dtl-out as integer,
                                            input p-line-ret as integer,
                                            input p-dtl-ret as integer,
                                            input p-nf-chk-amount as integer,
                                            input p-nf-gds-amount as integer,
                                            input p-ps-where-rus as character
                                            ):
define variable v-ps as character no-undo .
define variable v-other as character no-undo .
v-other = p-ps.
entry(1, v-other, "@") = ''.
v-other = trim(v-other, "@").
v-PS = substitute('Кол-во_чеков &2&1строк_чеков &3&1товаров_расход &4&1признаков_расход &5&1товаров_возврат &6&1признаков_возврат &7&1'
                    , chr(4)
                    , p-chk-amount
                    , p-gds-amount
                    , p-line-out
                    , p-dtl-out
                    , p-line-ret
                    , p-dtl-ret).
v-ps = v-ps +  substitute("без_докум_чеков &1&2без_докум_строк_чеков &3&2&4@&5"
                            , p-nf-chk-amount
                            , chr(4)
                            , p-nf-gds-amount
                            , p-ps-where-rus
                            , v-other)
                    .
return v-ps.
END FUNCTION.
FUNCTION set-inkas-PS-simple returns character(
                                            input p-chk-amount as integer,
                                            input p-gds-amount as integer,
                                            input p-line-out as integer,
                                            input p-dtl-out as integer,
                                            input p-line-ret as integer,
                                            input p-dtl-ret as integer,
                                            input p-nf-chk-amount as integer,
                                            input p-nf-gds-amount as integer
                                            ):
define variable v-ps as character no-undo .
define variable v-str1 as character no-undo .
assign
  v-ps = fill( chr(32) +  chr(4), 9).
  v-str1 = ENTRY(1, v-PS, chr(4)).
  entry(2, v-str1, chr(32))  = string(p-chk-amount).
  ENTRY(1, v-PS, chr(4)) = v-str1.
  v-str1 = ENTRY(2, v-PS, chr(4)).
  entry(2, v-str1, chr(32))  = string(p-gds-amount).
  ENTRY(2, v-PS, chr(4)) = v-str1.
  v-str1 = ENTRY(3, v-PS, chr(4)).
  entry(2, v-str1, chr(32))  = string(p-line-out).
  ENTRY(3, v-PS, chr(4)) = v-str1.
  v-str1 = ENTRY(4, v-PS, chr(4)).
  entry(2, v-str1, chr(32))  = string(p-dtl-out).
  ENTRY(4, v-PS, chr(4)) = v-str1.
  v-str1 = ENTRY(5, v-PS, chr(4)).
  entry(2, v-str1, chr(32))  = string(p-line-ret).
  ENTRY(5, v-PS, chr(4)) = v-str1.
  v-str1 = ENTRY(6, v-PS, chr(4)).
  entry(2, v-str1, chr(32))  = string(p-dtl-ret).
  ENTRY(5, v-PS, chr(4)) = v-str1.
  v-str1 = ENTRY(7, v-PS, chr(4)).
  entry(2, v-str1, chr(32))  = string(p-nf-chk-amount).
  ENTRY(5, v-PS, chr(4)) = v-str1.
  v-str1 = ENTRY(8, v-PS, chr(4)).
  entry(2, v-str1, chr(32))  = string(p-nf-gds-amount).
  ENTRY(5, v-PS, chr(4)) = v-str1.
return v-ps.
END FUNCTION.
FUNCTION get-inkas-nf-PS-simple returns logical (
                                             input p-ps as character
                                            ,output p-gds-amount as integer
                                            ,output p-nf-gds-amount as integer
                                            ):
if num-entries(p-ps, chr(4)) >= 8 then do:
  assign
  p-gds-amount = integer(entry(2, ENTRY(2, p-PS, chr(4)), chr(32)))
  p-nf-gds-amount = integer(entry(2, ENTRY(8, p-PS, chr(4)), chr(32)))
  no-error .
end.
return not error-status:error .
END FUNCTION.
PROCEDURE get-inkas-PS:
define parameter buffer buf_inkas for ub.inkas.
define output parameter p-chk-amount as integer no-undo .
define output parameter p-gds-amount as integer no-undo .
define output parameter p-line-out as integer no-undo .
define output parameter p-dtl-out as integer no-undo .
define output parameter p-line-ret as integer no-undo .
define output parameter p-dtl-ret as integer no-undo .
define output parameter p-nf-chk-amount as integer no-undo .
define output parameter p-nf-gds-amount as integer no-undo .
define output parameter p-ps-where-rus as character no-undo .
define variable v-gds-amount as integer no-undo .
define variable v-nf-gds-amount as integer no-undo .
define buffer buf_sale-doc for ub.sale-doc.
for each buf_sale-doc no-lock where
        buf_sale-doc.inkas-code = buf_inkas.inkas-code
    and buf_sale-doc.order > 0:
  assign
  p-gds-amount = p-gds-amount + (if buf_sale-doc.in-inkas = yes
                                 or buf_sale-doc.doc-kind = 'trf':U
                                 then buf_sale-doc.gds-amount
                                 else 0)
  p-line-out = p-line-out  + (if buf_sale-doc.in-inkas = yes
                              and buf_sale-doc.dir = 1
                              then buf_sale-doc.tot-lines
                              else 0)
  p-dtl-out = p-dtl-out + (if buf_sale-doc.in-inkas = yes
                          and buf_sale-doc.dir = 1
                          then buf_sale-doc.tot-dtl
                          else 0)
  p-line-ret = p-line-ret  + (if buf_sale-doc.in-inkas = yes
                              and buf_sale-doc.dir = -1
                              then buf_sale-doc.tot-lines
                              else 0)
  p-dtl-ret = p-dtl-ret + (if buf_sale-doc.in-inkas = yes
                           and buf_sale-doc.dir = -1
                          then buf_sale-doc.tot-dtl
                          else 0)
  .
end.
if get-inkas-nf-PS-simple( input buf_inkas.ps
                          ,output v-gds-amount
                          ,output v-nf-gds-amount) then do:
  assign
  p-gds-amount = v-gds-amount
  p-nf-gds-amount = v-nf-gds-amount
  .
end.
assign
p-ps-where-rus = buf_inkas.sale-filter-rus
p-nf-chk-amount = buf_inkas.num-chk-nf
p-chk-amount = buf_inkas.num-chk
.
END PROCEDURE.
DEFINE NEW SHARED STREAM test.
define variable filter-name as char no-undo.
define variable where-phrase as char no-undo.
define variable MY-where-phrase as char no-undo.
define variable sort-phrase as char no-undo.
def NEW SHARED var ff as decimal.
def NEW SHARED var gg as decimal.
DEF NEW SHARED VAR accum1 as decimal.
DEF NEW SHARED VAR accum2 as decimal.
define variable test-number as integer no-undo.
define buffer c-doc for ub.chk-doc.
define var r-bar-code like ub.bar-code.b-code no-undo.
define variable v-curr-r-b as character no-undo .
define temp-table temp-sale-gds no-undo
field price-r-b like ub.gds-dtl.price-rubl
field sum-r-b-check   like ub.gds-dtl.price-rubl
field sum-r-b-trn    like ub.gds-dtl.price-rubl
field doc-type as character
field doc-kind as character
field doc-label as character
field qnty-check like ub.gds-dtl.fact-qnty
field qnty-trn  like ub.gds-dtl.fact-qnty
index pi is unique primary
doc-kind.
define temp-table temp-sale-delta no-undo
field sum-r-b-delta  like ub.gds-dtl.price-rubl
field doc-kind as character
field doc-label as character
field qnty-delta like ub.gds-dtl.fact-qnty
index pi is unique primary
doc-kind.
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON BUTTON-1
     LABEL "Отчет по продаже - чеки : общие суммы"
     SIZE 56.38 BY 1.08.
DEFINE BUTTON BUTTON-2
     LABEL "Оплаты по продаже - оплаты по чекам"
     SIZE 56.38 BY 1.08.
DEFINE BUTTON BUTTON-3
     LABEL "Товарные суммы: отчет о продаже - накладные"
     SIZE 56.38 BY 1.08.
DEFINE BUTTON BUTTON-4
     LABEL "Товарные суммы: чеки - накладные"
     SIZE 56.38 BY 1.08.
DEFINE BUTTON BUTTON-5
     LABEL "Некорректные строки накладных"
     SIZE 56.38 BY 1.08.
DEFINE BUTTON BUTTON-6
     LABEL "Оплаты по кассам - Оплаты всего"
     SIZE 56.38 BY 1.08.
DEFINE BUTTON BUTTON-7
     LABEL "Количества строк и чеков - Примечание к продаже"
     SIZE 56.38 BY 1.08.
DEFINE BUTTON r-sale
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE VARIABLE my-inkas AS CHARACTER FORMAT "X(256)":U
     LABEL "Номер продажи"
     VIEW-AS FILL-IN
     SIZE 14.63 BY .92 TOOLTIP "HAHA" NO-UNDO.
DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-Help AT ROW 1 COL 54.88
     r-sale AT ROW 3.46 COL 39
     my-inkas AT ROW 3.5 COL 21.63 COLON-ALIGNED
     BUTTON-1 AT ROW 4.79 COL 1.75
     BUTTON-2 AT ROW 6.29 COL 1.75
     BUTTON-3 AT ROW 7.79 COL 1.75
     BUTTON-4 AT ROW 9.21 COL 1.75
     BUTTON-5 AT ROW 10.79 COL 1.75
     BUTTON-6 AT ROW 12.29 COL 1.75
     BUTTON-7 AT ROW 13.79 COL 1.75
     "testi7.txt" VIEW-AS TEXT
          SIZE 17.25 BY 1 AT ROW 13.79 COL 59.13
          FGCOLOR 4
     "testi3.txt" VIEW-AS TEXT
          SIZE 17.25 BY 1 AT ROW 7.79 COL 59.25
          FGCOLOR 4
     "testi2.txt" VIEW-AS TEXT
          SIZE 17.25 BY 1 AT ROW 6.29 COL 59.25
          FGCOLOR 4
     "testi1.txt" VIEW-AS TEXT
          SIZE 17.25 BY 1 AT ROW 4.79 COL 59.25
          FGCOLOR 4
     "testi5.txt" VIEW-AS TEXT
          SIZE 17.25 BY 1 AT ROW 10.79 COL 59
          FGCOLOR 4
     "testi6.txt" VIEW-AS TEXT
          SIZE 17.25 BY 1 AT ROW 12.21 COL 59.13
          FGCOLOR 4
     "testi4.txt" VIEW-AS TEXT
          SIZE 17.25 BY 1 AT ROW 9.21 COL 59
          FGCOLOR 4
     "Результаты ищите в файле:" VIEW-AS TEXT
          SIZE 25.25 BY 1 AT ROW 3.38 COL 51.63
          FGCOLOR 4
     SPACE(2.61) SKIP(10.65)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Тесты корректности отчета о продаже"
         CANCEL-BUTTON b-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF BUTTON-1 IN FRAME Dialog-Frame
DO:
  assign my-inkas.
  assign test-number = 1.
  run test0 in this-procedure no-error.
  if NOT error-status:error then
  message "Тест работу завершил" view-as alert-box.
END.
ON CHOOSE OF BUTTON-2 IN FRAME Dialog-Frame
DO:
  assign my-inkas.
  assign test-number = 2.
  run test0 in this-procedure no-error.
  if NOT error-status:error then
  message "Тест работу завершил" view-as alert-box.
END.
ON CHOOSE OF BUTTON-3 IN FRAME Dialog-Frame
DO:
  assign my-inkas.
  assign test-number = 3.
  run test0 in this-procedure no-error.
  if NOT error-status:error then
  message "Тест работу завершил" view-as alert-box.
END.
ON CHOOSE OF BUTTON-4 IN FRAME Dialog-Frame
DO:
  assign my-inkas.
  assign test-number = 4.
  run test0 in this-procedure no-error.
  if NOT error-status:error then
  message "Тест работу завершил" view-as alert-box.
END.
ON CHOOSE OF BUTTON-5 IN FRAME Dialog-Frame
DO:
  assign my-inkas.
  assign test-number = 5.
  run test0 in this-procedure no-error.
  if NOT error-status:error then
  message "Тест работу завершил" view-as alert-box.
END.
ON CHOOSE OF BUTTON-6 IN FRAME Dialog-Frame
DO:
  assign my-inkas.
  assign test-number = 6.
  run test0 in this-procedure no-error.
  if NOT error-status:error then
  message "Тест работу завершил" view-as alert-box.
END.
ON CHOOSE OF BUTTON-7 IN FRAME Dialog-Frame
DO:
  assign my-inkas.
  assign test-number = 7.
  run test0 in this-procedure no-error.
  if NOT error-status:error then
  message "Тест работу завершил" view-as alert-box.
END.
ON LEAVE OF my-inkas IN FRAME Dialog-Frame
DO:
  assign my-inkas.
END.
ON CHOOSE OF r-sale IN FRAME Dialog-Frame
DO:
  DEFINE VARIABLE rid-list as character no-undo .
    if v-cntxt-obj-type = 'маг':U then
    run str/salelist.w (
                        input parparentproc
                      ,input "b-sel":U
                      ,input "object-all"
                      ,input v-cntxt-host-code-obj
                      ,input v-cntxt-obj-type
                      ,input v-cntxt-obj-code
                      ,input-output rid-list) no-error.
    else do:
      BELL.
      message "Не могу вызвать справочник отчетов о продаж, если текущий объект не МАГАЗИН!"
      view-as alert-box ERROR.
      return no-apply.
    end.
    if rid-list  <> '':U then do:
        find first ub.inkas NO-LOCK WHERE recid(ub.inkas) = integer(rid-list) NO-ERROR.
        assign
        my-inkas = ub.inkas.inkas-code.
        display
        my-inkas
        WITH FRAME Dialog-Frame.
    end.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output v-curr-r-b
  )  .
   RUN enable_UI in this-procedure .
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI in this-procedure .
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY my-inkas
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-Help r-sale my-inkas BUTTON-1 BUTTON-2 BUTTON-3 BUTTON-4
         BUTTON-5 BUTTON-6 BUTTON-7
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE test0 :
FIND FIRST ub.inkas no-lock where ub.inkas.inkas-code = my-inkas NO-ERROR.
if not avail ub.inkas then do:
    message "Нет такой продажи!" view-as alert-box ERROR.
    return error.
END.
if ub.inkas.status_ = 'запрос':U then do:
  disable
  button-2
  button-3
  with frame Dialog-Frame.
end.
else do:
  enable
  button-2
  button-3
  with frame Dialog-Frame .
end.
run value("test" + string(test-number)) IN THIS-PROCEDURE ( INPUT my-inkas) no-error.
run waitfram-hide in this-procedure .
OUTPUT STREAM test close.
END PROCEDURE.
PROCEDURE test1 :
DEFINE INPUT PARAMETER my-inkas LIKE ub.inkas.inkas-code no-undo.
define variable for-num-chk-nf as integer no-undo .
define variable accumq as decimal no-undo.                                  define variable accumc as decimal no-undo.                                  define variable accumall as decimal no-undo.                                define variable accumall1 as decimal no-undo.                               define variable for-netto as decimal no-undo.                               define variable for-discnt as decimal no-undo.                              define variable for-sub-disc as decimal no-undo.                            define variable for-num-chk as integer no-undo.                             define variable for-brutto as decimal no-undo.                              define variable for-netto-r as decimal no-undo.                             define variable for-discnt-r as decimal no-undo.                            define variable for-brutto-r as decimal no-undo.                            define variable for-netto-v as decimal no-undo.                             define variable for-discnt-v as decimal no-undo.                            define variable for-brutto-v as decimal no-undo.                            define variable for-sum as decimal no-undo.                                 define variable for-base as decimal no-undo.                                define variable for-rubl as decimal no-undo.                                define variable newprice as decimal no-undo.                                define variable flag as logical.                                            define variable current-netto as  decimal no-undo.                          define variable current-brutto as  decimal no-undo.                         define variable current-discnt as  decimal no-undo.                         define variable current-write-off as  decimal no-undo.                      define variable for-write-off as  decimal no-undo.                                                                                                      def buffer ret-doc for ub.trn-doc.                                             define buffer buf_sale-doc for ub.sale-doc.                          define buffer locked_trn-doc for ub.trn-doc.
OUTPUT STREAM TEST TO testi1.txt.
_chk-doc:
FOR EACH ub.chk-doc NO-LOCK where ub.chk-doc.out-code = my-inkas :
  run waitfram-show in this-procedure ( input "Ждите - идет обработка -  чек " + chk-doc.doc-code).
    if lookup(string(chk-doc.chk-type), '14,15,16,36,8,101,106,108,11,12,13,40,169,196,114,115,116,117,111,112,136,113,201,206,208,301,306,2,3,4,5,7,43,44':U) > 0 then do:
      for-num-chk-nf = for-num-chk-nf + 1.
      for-num-chk = for-num-chk + 1.
      NEXT _chk-doc.
    end.
    assign
    for-brutto = for-brutto + chk-doc.tot-doc
    for-netto = for-netto + chk-doc.netto
    for-discnt = for-discnt + chk-doc.discnt
    for-sub-disc = for-sub-disc + chk-doc.sub-discnt
    for-num-chk = for-num-chk + 1
    .
END.
PUT stream TEST UNFORMATTED
("СРАВНЕНИЕ ОБЩИХ СУММ ПО ОТЧЕТУ ПРОДАЖЕ " + my-inkas + " И ЧЕКАМ") skip(1)
"Брутто" format "X(22)" space(1)
"Нетто" format "X(22)" space(1)
"Скидка" format "X(22)" space(1)
"Сумма списанного" format "X(22)" space(1)
"Кол-во чеков Общее" format "X(18)" space(1)
"из них вне док-тов" format "X(18)" space(1)
skip
"ОТЧЕТ ПО ПРОДАЖЕ"
skip
ub.inkas.tot-doc format "-999,999,999.999999999" space(1)
ub.inkas.netto format "-999,999,999.999999999" space(1)
ub.inkas.discnt format "-999,999,999.999999999" space(1)
ub.inkas.sub-discnt format "-999,999,999.999999999" space(1)
ub.inkas.num-chk FORMAT "-999,999" space(10)
ub.inkas.num-chk-nf FORMAT "-999,999" space(1)
skip
"ЧЕКИ"
skip
for-brutto format "-999,999,999.999999999" space(1)
for-netto format "-999,999,999.999999999" space(1)
for-discnt format "-999,999,999.999999999" space(1)
for-sub-disc format "-999,999,999.999999999" space(1)
for-num-chk format "-999,999" space(10)
for-num-chk-nf format "-999,999" space(1)
skip
.
run waitfram-hide in this-procedure .
END PROCEDURE.
PROCEDURE test2 :
DEFINE INPUT PARAMETER my-inkas LIKE ub.inkas.inkas-code no-undo.
define variable accumq as decimal no-undo.                                  define variable accumc as decimal no-undo.                                  define variable accumall as decimal no-undo.                                define variable accumall1 as decimal no-undo.                               define variable for-netto as decimal no-undo.                               define variable for-discnt as decimal no-undo.                              define variable for-sub-disc as decimal no-undo.                            define variable for-num-chk as integer no-undo.                             define variable for-brutto as decimal no-undo.                              define variable for-netto-r as decimal no-undo.                             define variable for-discnt-r as decimal no-undo.                            define variable for-brutto-r as decimal no-undo.                            define variable for-netto-v as decimal no-undo.                             define variable for-discnt-v as decimal no-undo.                            define variable for-brutto-v as decimal no-undo.                            define variable for-sum as decimal no-undo.                                 define variable for-base as decimal no-undo.                                define variable for-rubl as decimal no-undo.                                define variable newprice as decimal no-undo.                                define variable flag as logical.                                            define variable current-netto as  decimal no-undo.                          define variable current-brutto as  decimal no-undo.                         define variable current-discnt as  decimal no-undo.                         define variable current-write-off as  decimal no-undo.                      define variable for-write-off as  decimal no-undo.                                                                                                      def buffer ret-doc for ub.trn-doc.                                             define buffer buf_sale-doc for ub.sale-doc.                          define buffer locked_trn-doc for ub.trn-doc.
OUTPUT STREAM TEST TO testi2.txt.
PUT stream TEST UNFORMATTED
("СРАВНЕНИЕ СУММ ПЛАТЕЖЕЙ ПО ОТЧЕТУ ПО ПРОДАЖЕ " + my-inkas + " И ЧЕКАМ") skip(1)
space(16)
"Код платежа" format "X(11)" space(1)
"Код валюты " format "X(11)" space(1)
"Баз.вал." format "X(15)" space(1)
"Рубли" format "X(15)" space(1)
"Валюта платежа" format "X(15)" space(1)
"Ошибка кода оплаты" format "X(20)"
skip
.
_chk-pay:
FOR EACH ub.chk-pay No-LOCK WHERE
        ub.chk-pay.out-code = my-inkas use-index out-sale,
    first ub.chk-doc no-lock where
         ub.chk-doc.doc-code = ub.chk-pay.doc-code
break
by ub.chk-pay.pay-code
by ub.chk-pay.curr-code:
  run waitfram-show in this-procedure ( input "Ждите - идет обработка -  чек " + chk-pay.doc-code).
  if first-of(chk-pay.curr-code) then do:
    assign
    for-base = 0
    for-rubl = 0
    for-sum = 0
    flag = no
    .
    FIND FIRST ub.inkas-pay NO-LOCK WHERE
              ub.inkas-pay.inkas-code = my-inkas
         AND  ub.inkas-pay.pay-code = chk-pay.pay-code
         AND  ub.inkas-pay.curr-code = chk-pay.curr-code No-ERROR.
    if not avail ub.inkas-pay then flag = yes.
    else flag = no.
  end.
  if lookup(string(ub.chk-doc.chk-type), '14,15,16,36,8,101,106,108,11,12,13,40,169,196,114,115,116,117,111,112,136,113,201,206,208,301,306,2,3,4,5,7,43,44':U) > 0 then NEXT _chk-pay.
  assign
  for-base = for-base + ub.chk-pay.tot-base
  for-rubl = for-rubl + ub.chk-pay.tot-rubl
  for-sum = for-sum + ub.chk-pay.tot-sum
  .
  if last-of(ub.chk-pay.curr-code) then do:
      PUT stream TEST UNFORMATTED
      space(16)
      chk-pay.pay-code format "9999" space(8)
      chk-pay.curr-code format "99999" space(7)
      skip(0)
      "ОПЛАТЫ ПО ПРОДАЖЕ" format "X(15)" space(1)
      space(12)
      space(10)
      (if avail inkas-pay then inkas-pay.tot-base else 0) format "-999,999,999.99" space(1)
      (if avail inkas-pay then inkas-pay.tot-rubl else 0) format "-999,999,999.99" space(1)
      (if avail inkas-pay then inkas-pay.tot-sum else 0) format "-999,999,999.99" space(1)
      string(flag, "yes/no") format "X(20)"
      skip
      "ОПЛАТЫ ПО ЧЕКАМ" format "X(15)" space(1)
      space(12)
      space(10)
      for-base format "-999,999,999.99" space(1)
      for-rubl format "-999,999,999.99" space(1)
      for-sum format "-999,999,999.99" space(1)
      skip
      .
  end.
end.
FOR EACH inkas-pay NO-LOCK WHERE inkas-pay.inkas-code = my-inkas :
  IF not can-find(FIRST chk-pay NO-LOCK WHERE
                       chk-pay.out-code = my-inkas
                 AND   chk-pay.pay-code = inkas-pay.pay-code
                 AND   chk-pay.curr-code = inkas-pay.curr-code) then do:
    PUT stream TEST UNFORMATTED
    space(16)
    inkas-pay.pay-code  format "X(20)" space(1)
    inkas-pay.curr-code  format "99999" space(1)
    "ОПЛАТЫ ПО ПРОДАЖЕ" format "X(15)" space(1)
    space(12)
    space(10)
    inkas-pay.tot-base format "-999,999,999.99" space(1)
    inkas-pay.tot-rubl format "-999,999,999.99" space(1)
    inkas-pay.tot-sum format "-999,999,999.99" space(1)
    string(yes, "yes/no") format "X(20)"
    skip
    "ОПЛАТЫ ПО ЧЕКАМ" format "X(15)" space(1)
    space(12)
    space(10)
    0 format "-999,999,999.99" space(1)
    0 format "-999,999,999.99" space(1)
    0 format "-999,999,999.99" space(1)
    skip
    .
  end.
END.
run waitfram-hide in this-procedure .
END PROCEDURE.
PROCEDURE test3 :
DEFINE INPUT PARAMETER my-inkas LIKE ub.inkas.inkas-code no-undo.
define variable accumq as decimal no-undo.                                  define variable accumc as decimal no-undo.                                  define variable accumall as decimal no-undo.                                define variable accumall1 as decimal no-undo.                               define variable for-netto as decimal no-undo.                               define variable for-discnt as decimal no-undo.                              define variable for-sub-disc as decimal no-undo.                            define variable for-num-chk as integer no-undo.                             define variable for-brutto as decimal no-undo.                              define variable for-netto-r as decimal no-undo.                             define variable for-discnt-r as decimal no-undo.                            define variable for-brutto-r as decimal no-undo.                            define variable for-netto-v as decimal no-undo.                             define variable for-discnt-v as decimal no-undo.                            define variable for-brutto-v as decimal no-undo.                            define variable for-sum as decimal no-undo.                                 define variable for-base as decimal no-undo.                                define variable for-rubl as decimal no-undo.                                define variable newprice as decimal no-undo.                                define variable flag as logical.                                            define variable current-netto as  decimal no-undo.                          define variable current-brutto as  decimal no-undo.                         define variable current-discnt as  decimal no-undo.                         define variable current-write-off as  decimal no-undo.                      define variable for-write-off as  decimal no-undo.                                                                                                      def buffer ret-doc for ub.trn-doc.                                             define buffer buf_sale-doc for ub.sale-doc.                          define buffer locked_trn-doc for ub.trn-doc.
define variable delta as decimal no-undo .
define buffer dop_trn-doc for ub.trn-doc.
OUTPUT STREAM TEST TO testi3.txt.
run waitfram-show in this-procedure ( input "Ждите ...").
PUT STREAM test unformatted
"СРАВНЕНИЕ ТОВАРНЫХ СУММ ПО ДОКУМЕНТАМ ПРОДАЖИ И ПРОДАЖЕ В ЦЕЛОМ" SKIP(0)
"ПРОДАЖА"  chr(32) my-inkas skip(1)
string('':U, "X(25)")  chr(32)
string('':U, "X(16)") +  chr(32)
string('Брутто', "X(19)")  chr(32)
string('Скидка товарная', "X(19)")  chr(32)
string('Нетто', "X(19)")  chr(32)
skip(0)
.
for each buf_sale-doc where
       buf_sale-doc.inkas-code = my-inkas
    and buf_sale-doc.order > 0:
  if lookup(buf_sale-doc.doc-kind, 'es,rs,rwo,trf,swo,ngs,rgs,vir':U) = 0 then NEXT.
  if ub.inkas.status_ <> 'факт':U then do:
    find first dop_trn-doc no-lock where
              dop_trn-doc.doc-code = buf_sale-doc.doc-code.
    run gbl/calc-trn.p ( input parparentproc
                       , input recid(dop_trn-doc)).
  end.
  find first locked_trn-doc where locked_trn-doc.doc-code = buf_sale-doc.doc-code.
  if buf_sale-doc.doc-kind = 'trf':U then do:
  end.
  else do:
    assign
    current-brutto = if v-curr-r-b = 'rubl':U
                      then locked_trn-doc.tot-sale
                      else locked_trn-doc.tot-fact
    current-netto = if v-curr-r-b = 'rubl':U
                then locked_trn-doc.tot-sale - (if locked_trn-doc.discnt-rubl = ? then 0 else locked_trn-doc.discnt-rubl)
                else locked_trn-doc.tot-fact - (if locked_trn-doc.tot-calc = ? then 0 else locked_trn-doc.tot-calc)
    current-discnt = if v-curr-r-b = 'rubl':U
                    then locked_trn-doc.discnt-rubl
                    else locked_trn-doc.tot-calc
    .
    if buf_sale-doc.in-inkas then
    assign
    for-netto = for-netto + current-netto * buf_sale-doc.dir
    for-brutto = for-brutto + current-brutto * buf_sale-doc.dir
    for-discnt = for-discnt + (if current-discnt = ? then 0 else current-discnt) * buf_sale-doc.dir
    .
    if buf_sale-doc.doc-type = 'спи':U then
    assign
    current-write-off = if v-curr-r-b = 'rubl':U
                then locked_trn-doc.tot-sale - locked_trn-doc.discnt-rubl
                else locked_trn-doc.tot-fact - locked_trn-doc.tot-calc
    for-write-off = for-write-off + current-write-off
    .
    PUT STREAM test unformatted
    string(entry (lookup (buf_sale-doc.doc-kind, 'es,rs,rwo,trf,swo,ngs,rgs,vir':U + ',' + 'itr':U) + 1, ',' + 'касса продажа,касса возврат,Списание-по-Возврату,ТехПролив,Списание,Приход-Природный-Газ,Возврат-Природный-Газ,Перемещение-Вирт-Рез':U + ',' + 'ПриТехПрол':U ), "X(25)")  chr(32)
    string(buf_sale-doc.doc-code, "X(16)") +  chr(32)
    string(current-brutto * buf_sale-doc.dir, "-999,999,999.99999")  chr(32)
    (if current-discnt = ?
    then string(chr(63), "X(18)")
    else
    string(current-discnt * buf_sale-doc.dir, "-999,999,999.99999")
    )                                                    chr(32)
    string(current-netto * buf_sale-doc.dir, "-999,999,999.99999")  chr(32)
    skip(0).
  end.
end.
delta = inkas.netto - (for-netto  - (inkas.sub-discnt - for-write-off)).
PUT STREAM test unformatted
skip(1)
string("Итого по документам", "X(25)")  chr(32)
string('':U, "X(16)")  chr(32)
string(for-brutto, "-999,999,999.99999")  chr(32)
string(for-discnt, "-999,999,999.99999")   chr(32)
string(for-netto, "-999,999,999.99999")  skip(0)
string("Сумма списаний", "X(25)") chr(32)
string('':U, "X(16)")  chr(32)
string(for-write-off, "-999,999,999.99999")  chr(32)
string(0, "-999,999,999.99999")  chr(32)
string(0, "-999,999,999.99999") skip.
PUT STREAM test unformatted
skip(1)
string("Продажа в общем", "X(25)")  chr(32)
string('':U, "X(16)") +  chr(32)
string(inkas.tot-doc, "-999,999,999.99999")  chr(32)
string(inkas.discnt, "-999,999,999.99999")   chr(32)
string(inkas.netto, "-999,999,999.99999")  chr(32)
skip(0)
string("Сумма списаний", "X(25)") chr(32)
string('':U, "X(16)")  chr(32)
string(inkas.sub-discnt, "-999,999,999.99999")  chr(32)
string(0, "-999,999,999.99999")  chr(32)
string(0, "-999,999,999.99999") skip(0).
PUT STREAM test unformatted
skip(1)
string("Нетто по продаже", "X(25)")  chr(32)
string(inkas.netto, "-999,999,999.99999")  chr(32)
skip(0)
string(" - (", "X(25)") skip(0)
string("    нетто по документам", "X(25)")  chr(32)
string(for-netto, "-999,999,999.99999")  chr(32)
skip(0)
string("     - (", "X(25)") skip(0)
string("        спис. по продаже", "X(25)")  chr(32)
string(inkas.sub-discnt, "-999,999,999.99999")  chr(32)
skip(0)
string("     - ", "X(25)") skip(0)
string("        спис. по документ", "X(25)")  chr(32)
string(for-write-off, "-999,999,999.99999")  chr(32)
skip(0)
string("     - )", "X(25)")  chr(32)
skip(0)
string(" - )", "X(25)")  chr(32)
skip(0)
string(" = ", "X(25)")  chr(32)
string(delta, "-999,999,999.99999")  chr(32)
skip(0)
string("Погрешность=", "X(25)") chr(32)
string(abs(delta), "-999,999,999.99999") skip(0)
(if abs(delta) < 0.015
then "В пределах нормы"
else "Больше допустимой")
skip(0).
run waitfram-hide in this-procedure .
END PROCEDURE.
PROCEDURE test4 :
DEFINE INPUT PARAMETER my-inkas LIKE ub.inkas.inkas-code no-undo.
define variable accumq as decimal no-undo.                                  define variable accumc as decimal no-undo.                                  define variable accumall as decimal no-undo.                                define variable accumall1 as decimal no-undo.                               define variable for-netto as decimal no-undo.                               define variable for-discnt as decimal no-undo.                              define variable for-sub-disc as decimal no-undo.                            define variable for-num-chk as integer no-undo.                             define variable for-brutto as decimal no-undo.                              define variable for-netto-r as decimal no-undo.                             define variable for-discnt-r as decimal no-undo.                            define variable for-brutto-r as decimal no-undo.                            define variable for-netto-v as decimal no-undo.                             define variable for-discnt-v as decimal no-undo.                            define variable for-brutto-v as decimal no-undo.                            define variable for-sum as decimal no-undo.                                 define variable for-base as decimal no-undo.                                define variable for-rubl as decimal no-undo.                                define variable newprice as decimal no-undo.                                define variable flag as logical.                                            define variable current-netto as  decimal no-undo.                          define variable current-brutto as  decimal no-undo.                         define variable current-discnt as  decimal no-undo.                         define variable current-write-off as  decimal no-undo.                      define variable for-write-off as  decimal no-undo.                                                                                                      def buffer ret-doc for ub.trn-doc.                                             define buffer buf_sale-doc for ub.sale-doc.                          define buffer locked_trn-doc for ub.trn-doc.
define buffer buf_temp-sale-gds for temp-sale-gds.
define buffer buf_temp-sale-delta for temp-sale-delta.
define variable v-doc-kinds as character no-undo .
define variable ii as integer no-undo .
define variable v-dopi as integer no-undo .
define buffer buf_chk-doc for ub.chk-doc.
for each buf_temp-sale-delta:
  delete buf_temp-sale-delta.
end.
OUTPUT STREAM TEST TO testi4.txt.
run waitfram-show in this-procedure ( input "Ждите ...").
PUT STREAM TEST UNFORMATTED
substitute("РАЗЛИЧИЕ ТОВАРНЫХ СУММ ПО СТРОКАМ НАКЛАДНЫХ ПО ПРОДАЖЕ И ЧЕКАМ&1" +
             "ПО ПРОДАЖЕ &2&1&3"
             ,chr(10)
             ,my-inkas
             ,(if index(ub.inkas.PS, "компенс")  > 0 then "БЫЛА ПРОВЕДЕНА КОМПЕНСАЦИЯ" else "")
             ) skip(1)
string("Бар-код", "X(9)") chr(32)
string("Артикул", "X(16)") chr(32)
string("Про", "X(3)") chr(32)
string("изводитель", "X(9)") chr(32)
string("Вид документа", "X(20)") chr(32)
string("Кол-во док-ты", "X(12)") chr(32)
string("Сумма док-ты", "X(18)")
skip(0)
fill( chr(32) , 9 ) chr(32)
fill( chr(32) , 16 ) chr(32)
fill( chr(32) , 3 ) chr(32)
fill( chr(32) , 9 ) chr(32)
fill( chr(32) , 20 ) chr(32)
string("Кол-во чеки", "X(12)") chr(32)
string("Сумма чеки", "X(18)")
skip.
FOR EACH ub.chk-gds No-LOCK WHERE ub.chk-gds.out-code = my-inkas,
    FIRST ub.chk-doc NO-LOCK where ub.chk-doc.doc-code = ub.chk-gds.doc-code,
    FIRST ub.bar-code No-LOCK WHERE ub.bar-code.b-code = ub.chk-gds.b-code,
    FIRST ub.goods NO-LOCK WHERE ub.goods.gds-code = ub.bar-code.gds-code
BREAK
BY ub.goods.gds-code:
  run waitfram-show in this-procedure ( input substitute("Ждите ... Обработка баркода &1", chk-gds.b-code)).
  IF FIRST-OF(ub.goods.gds-code) then do:
    for each buf_temp-sale-gds:
      delete buf_temp-sale-gds.
    end.
    for each buf_sale-doc where
            buf_sale-doc.inkas-code = my-inkas
        and buf_sale-doc.order > 0 :
      FOR EACH ub.gds-dtl No-LOCK WHERE
            ub.gds-dtl.doc-code = buf_sale-doc.doc-code
        AND ub.gds-dtl.artic = ub.goods.artic
        AND ub.gds-dtl.prod-type = ub.goods.prod-type
        AND ub.gds-dtl.prod-code = ub.goods.prod-code
        AND ub.gds-dtl.prt-code = ub.bar-code.node-code:
        create buf_temp-sale-gds.
        assign
        buf_temp-sale-gds.doc-type = buf_sale-doc.doc-type
        buf_temp-sale-gds.doc-kind = buf_sale-doc.doc-kind
        buf_temp-sale-gds.doc-label = entry (lookup (buf_sale-doc.doc-kind, 'es,rs,rwo,trf,swo,ngs,rgs,vir':U + ',' + 'itr':U) + 1, ',' + 'касса продажа,касса возврат,Списание-по-Возврату,ТехПролив,Списание,Приход-Природный-Газ,Возврат-Природный-Газ,Перемещение-Вирт-Рез':U + ',' + 'ПриТехПрол':U )
        buf_temp-sale-gds.qnty-trn = gds-dtl.fact-qnty * buf_sale-doc.msign
        buf_temp-sale-gds.sum-r-b-trn = gds-dtl.fact-qnty *
                                        (if v-curr-r-b = 'rubl':U
                                        then (gds-dtl.price-rubl - gds-dtl.discnt-rubl)
                                        else (gds-dtl.price-base - gds-dtl.discnt-base)
                                        ) * buf_sale-doc.msign
        .
      END.
    end.
  END.
  if lookup(string(chk-doc.chk-type), '14,15,16,36,8,101,106,108,11,12,13,40,169,196,114,115,116,117,111,112,136,113,201,206,208,301,306,2,3,4,5,7,43,44':U) = 0 then do:
    assign
    v-dopi = num-entries(chk-gds.line-type, chr(4))
    no-error .
    if not error-status:error
    and v-dopi > 1 then do:
      v-doc-kinds = entry(2, chk-gds.line-type, chr(4)).
    end.
    else do:
      if chk-gds.doc-qnty = 0 then v-doc-kinds = '':U.
      else do:
        find first buf_chk-doc no-lock where
                buf_chk-doc.doc-code = chk-gds.doc-code .
        v-doc-kinds = (if buf_chk-doc.netto >= 0
                            then 'es':U
                            else 'rs':U)
        .
      end.
    end.
    do ii = 1 to num-entries(v-doc-kinds):
      find first buf_temp-sale-gds where
              buf_temp-sale-gds.doc-kind = entry(ii, v-doc-kinds) no-error .
      if not available buf_temp-sale-gds then do:
        create buf_temp-sale-gds.
        assign
        buf_temp-sale-gds.doc-kind = entry(ii, v-doc-kinds)
        .
      end.
      assign
      buf_temp-sale-gds.qnty-check = buf_temp-sale-gds.qnty-check + chk-gds.doc-qnty
      buf_temp-sale-gds.sum-r-b-check = buf_temp-sale-gds.sum-r-b-check +
                                        chk-gds.doc-qnty * (chk-gds.price-base -
                                                           (if buf_temp-sale-gds.doc-type = 'спи':U
                                                           then 0
                                                           else chk-gds.discnt))
      .
    end.
  end.
  IF LAST-OF(goods.gds-code) then do:
    for each buf_temp-sale-gds:
      if buf_temp-sale-gds.qnty-trn <> buf_temp-sale-gds.qnty-check
      or abs(buf_temp-sale-gds.sum-r-b-trn - buf_temp-sale-gds.sum-r-b-check) > 0.0001
      then do:
        find first buf_temp-sale-delta where
                  buf_temp-sale-delta.doc-kind = buf_temp-sale-gds.doc-kind no-error .
        if not available buf_temp-sale-delta then do:
          CREATE BUF_TEMP-SALE-DELTA.
          ASSIGN
          buf_temp-sale-delta.doc-kind = buf_temp-sale-gds.doc-kind
          buf_temp-sale-delta.doc-label = buf_temp-sale-gds.doc-label
          .
        end.
        assign
        buf_temp-sale-delta.qnty-delta = buf_temp-sale-delta.qnty-delta + (buf_temp-sale-gds.qnty-trn - buf_temp-sale-gds.qnty-check)
        buf_temp-sale-delta.sum-r-b-delta = buf_temp-sale-delta.sum-r-b-delta + (buf_temp-sale-gds.sum-r-b-trn - buf_temp-sale-gds.sum-r-b-check)
        .
        PUT STREAM TEST UNFORMATTED
        chk-gds.b-code format ">>>>>>>>9" chr(32)
        goods.artic format "X(16)" chr(32)
        goods.prod-type format "X(3)" chr(32)
        goods.prod-code format "999999999" chr(32)
        buf_temp-sale-gds.doc-label format "X(20)" chr(32)
        buf_temp-sale-gds.qnty-trn  format "-99,999.999" chr(32)
        buf_temp-sale-gds.sum-r-b-trn format   "-99,999.999999999"
        skip(0)
        fill( chr(32) , 9 ) chr(32)
        fill( chr(32) , 16 ) chr(32)
        fill( chr(32) , 3 ) chr(32)
        fill( chr(32) , 9 ) chr(32)
        fill( chr(32) , 20 ) chr(32)
        buf_temp-sale-gds.qnty-check  format "-99,999.999" chr(32)
        buf_temp-sale-gds.sum-r-b-check format "-99,999.999999999"
        skip.
      end.
    end.
  END.
END.
PUT STREAM TEST UNFORMATTED
"ИТОГО ПОГРЕШНОСТИ ПО ВИДАМ ДОКУМЕНТОВ:" skip(0).
for each buf_temp-sale-delta:
  PUT STREAM TEST UNFORMATTED
  buf_temp-sale-delta.doc-label format "X(20)" chr(32)
  buf_temp-sale-delta.qnty-delta  format "-99,999.999" chr(32)
  buf_temp-sale-delta.sum-r-b-delta format "-99,999.999999999"
  skip(0).
end.
END PROCEDURE.
PROCEDURE test5 :
DEFINE INPUT PARAMETER my-inkas LIKE ub.inkas.inkas-code no-undo.
define variable accumq as decimal no-undo.                                  define variable accumc as decimal no-undo.                                  define variable accumall as decimal no-undo.                                define variable accumall1 as decimal no-undo.                               define variable for-netto as decimal no-undo.                               define variable for-discnt as decimal no-undo.                              define variable for-sub-disc as decimal no-undo.                            define variable for-num-chk as integer no-undo.                             define variable for-brutto as decimal no-undo.                              define variable for-netto-r as decimal no-undo.                             define variable for-discnt-r as decimal no-undo.                            define variable for-brutto-r as decimal no-undo.                            define variable for-netto-v as decimal no-undo.                             define variable for-discnt-v as decimal no-undo.                            define variable for-brutto-v as decimal no-undo.                            define variable for-sum as decimal no-undo.                                 define variable for-base as decimal no-undo.                                define variable for-rubl as decimal no-undo.                                define variable newprice as decimal no-undo.                                define variable flag as logical.                                            define variable current-netto as  decimal no-undo.                          define variable current-brutto as  decimal no-undo.                         define variable current-discnt as  decimal no-undo.                         define variable current-write-off as  decimal no-undo.                      define variable for-write-off as  decimal no-undo.                                                                                                      def buffer ret-doc for ub.trn-doc.                                             define buffer buf_sale-doc for ub.sale-doc.                          define buffer locked_trn-doc for ub.trn-doc.
OUTPUT STREAM TEST TO testi5.txt.
run waitfram-show in this-procedure ( input "Ждите ...").
PUT STREAM TEST UNFORMATTED
("НЕКОРРЕКТНЫЕ СТРОКИ НАКЛАДНЫХ ПО ПРОДАЖЕ " + my-inkas) skip(1)
"Артикул" format "X(16)" space(1)
"Про изводитель" format "X(14)" space(1)
"Кол-во-накл" format "X(11)" space(1)
"Скидка" format "X(15)" space(1)
"Вид докум" format "X(20)"
skip
.
IF error-status:ERROR THEN do:
  MESSAGE ERROR-STATUS:GET-MESSAGE(1) RETURN-VALUE.
  return error.
end.
for each buf_sale-doc where
        buf_sale-doc.inkas-code = my-inkas
    and  buf_sale-doc.order > 0
        :
  FOR EACH ub.gds-dtl No-LOCK WHERE
        ub.gds-dtl.doc-code = buf_sale-doc.doc-code,
    FIRST ub.goods No-LOCK WHERE
        ub.goods.artic = ub.gds-dtl.artic AND
        ub.goods.prod-type = ub.gds-dtl.prod-type AND
        ub.goods.prod-code = ub.gds-dtl.prod-code:
  run waitfram-show in this-procedure ( input string("Ждите ... Обработка товара " +
                            string(gds-dtl.artic, "9999999999") + gds-dtl.prod-type + string(gds-dtl.prod-code)
                  )         ).
  IF (gds-dtl.fact-qnty = 0 or (gds-dtl.doc-qnty = 0 and  buf_sale-doc.status_ = 'факт':U)) and
     (gds-dtl.discnt-rubl <> 0 or gds-dtl.discnt-base <>  0)  then
    PUT STREAM TEST UNFORMATTED
    goods.artic format "X(16)" space(1)
    goods.prod-type format "X(3)" space(1)
    goods.prod-code format "9999999999" space(1)
    gds-dtl.fact-qnty  format "-99,999.999" space(1)
    (if v-curr-r-b = 'base':U
    then gds-dtl.discnt-base
    else gds-dtl.discnt-rubl) format "-99,999.999999999" space(1)
    entry (lookup (buf_sale-doc.doc-kind, 'es,rs,rwo,trf,swo,ngs,rgs,vir':U + ',' + 'itr':U) + 1, ',' + 'касса продажа,касса возврат,Списание-по-Возврату,ТехПролив,Списание,Приход-Природный-Газ,Возврат-Природный-Газ,Перемещение-Вирт-Рез':U + ',' + 'ПриТехПрол':U ) format "X(20)"
    skip.
  END.
end.
END PROCEDURE.
PROCEDURE test6 :
DEFINE INPUT PARAMETER my-inkas LIKE ub.inkas.inkas-code no-undo.
define variable accumq as decimal no-undo.                                  define variable accumc as decimal no-undo.                                  define variable accumall as decimal no-undo.                                define variable accumall1 as decimal no-undo.                               define variable for-netto as decimal no-undo.                               define variable for-discnt as decimal no-undo.                              define variable for-sub-disc as decimal no-undo.                            define variable for-num-chk as integer no-undo.                             define variable for-brutto as decimal no-undo.                              define variable for-netto-r as decimal no-undo.                             define variable for-discnt-r as decimal no-undo.                            define variable for-brutto-r as decimal no-undo.                            define variable for-netto-v as decimal no-undo.                             define variable for-discnt-v as decimal no-undo.                            define variable for-brutto-v as decimal no-undo.                            define variable for-sum as decimal no-undo.                                 define variable for-base as decimal no-undo.                                define variable for-rubl as decimal no-undo.                                define variable newprice as decimal no-undo.                                define variable flag as logical.                                            define variable current-netto as  decimal no-undo.                          define variable current-brutto as  decimal no-undo.                         define variable current-discnt as  decimal no-undo.                         define variable current-write-off as  decimal no-undo.                      define variable for-write-off as  decimal no-undo.                                                                                                      def buffer ret-doc for ub.trn-doc.                                             define buffer buf_sale-doc for ub.sale-doc.                          define buffer locked_trn-doc for ub.trn-doc.
OUTPUT STREAM TEST TO testi6.txt.
PUT stream TEST UNFORMATTED
("СРАВНЕНИЕ СУММ ПЛАТЕЖЕЙ ПО ОТЧЕТУ ПО ПРОДАЖЕ В ЦЕЛОМ " + my-inkas + " И ПО КАССАМ") skip(1)
space(16)
"Код платежа" format "X(11)" space(1)
"Код валюты " format "X(11)" space(1)
"Баз.вал." format "X(15)" space(1)
"Рубли" format "X(15)" space(1)
"Валюта платежа" format "X(15)" space(1)
"Ошибка кода оплаты" format "X(20)"
skip
.
FOR EACH ub.inkas-pay-desk No-LOCK WHERE
        ub.inkas-pay-desk.inkas-code = my-inkas
break
by ub.inkas-pay-desk.pay-code
by ub.inkas-pay-desk.curr-code:
  run waitfram-show in this-procedure ( input "Ждите - идет обработка -  оплата по кассе " + string(inkas-pay-desk.pay-desk)).
  if first-of(ub.inkas-pay-desk.curr-code) then do:
      assign
      for-base = 0
      for-rubl = 0
      for-sum = 0
      flag = no
      .
      FIND FIRST ub.inkas-pay NO-LOCK WHERE
                  ub.inkas-pay.inkas-code = my-inkas AND
                  ub.inkas-pay.pay-code = ub.inkas-pay-desk.pay-code AND
                  ub.inkas-pay.curr-code = ub.inkas-pay-desk.curr-code No-ERROR.
      if not avail ub.inkas-pay then flag = yes.
      else flag = no.
  end.
  assign
  for-base = for-base + ub.inkas-pay-desk.tot-base
  for-rubl = for-rubl + ub.inkas-pay-desk.tot-rubl
  for-sum = for-sum + ub.inkas-pay-desk.tot-sum
  .
  if last-of(inkas-pay-desk.curr-code) then do:
    PUT stream TEST UNFORMATTED
    space(16)
    inkas-pay-desk.pay-code format "9999" space(8)
    inkas-pay-desk.curr-code format "99999" space(7)
    skip(0)
    "ОПЛАТЫ ПО ПРОДАЖЕ" format "X(15)" space(1)
    space(12)
    space(10)
    (if avail inkas-pay then inkas-pay.tot-base else 0) format "-999,999,999.99" space(1)
    (if avail inkas-pay then inkas-pay.tot-rubl else 0) format "-999,999,999.99" space(1)
    (if avail inkas-pay then inkas-pay.tot-sum else 0) format "-999,999,999.99" space(1)
    string(flag, "yes/no") format "X(20)"
    skip
    "ОПЛАТЫ ПО КАССАМ" format "X(15)" space(1)
    space(12)
    space(10)
    for-base format "-999,999,999.99" space(1)
    for-rubl format "-999,999,999.99" space(1)
    for-sum format "-999,999,999.99" space(1)
    skip
    .
  end.
end.
FOR EACH inkas-pay NO-LOCK WHERE
        inkas-pay.inkas-code = my-inkas :
  IF not can-find(FIRST inkas-pay-desk NO-LOCK WHERE
                        inkas-pay-desk.inkas-code = my-inkas AND
                      inkas-pay-desk.pay-code = inkas-pay.pay-code AND
                      inkas-pay-desk.curr-code = inkas-pay.curr-code) then do:
    PUT stream TEST UNFORMATTED
    space(16)
    inkas-pay.pay-code  format "X(20)" space(1)
    inkas-pay.curr-code  format "99999" space(1)
    "ОПЛАТЫ ПО ПРОДАЖЕ" format "X(15)" space(1)
    space(12)
    space(10)
    inkas-pay.tot-base format "-999,999,999.99" space(1)
    inkas-pay.tot-rubl format "-999,999,999.99" space(1)
    inkas-pay.tot-sum format "-999,999,999.99" space(1)
    string(yes, "yes/no") format "X(20)"
    skip
    "ОПЛАТЫ ПО КАССАМ" format "X(15)" space(1)
    space(12)
    space(10)
    0 format "-999,999,999.99" space(1)
    0 format "-999,999,999.99" space(1)
    0 format "-999,999,999.99" space(1)
    skip
    .
  end.
END.
run waitfram-hide in this-procedure .
END PROCEDURE.
PROCEDURE test7 :
DEFINE INPUT PARAMETER my-inkas LIKE ub.inkas.inkas-code no-undo.
define VARIABLE chk-amount as integer no-undo .
define VARIABLE gds-amount as integer no-undo .
define VARIABLE line-out as integer no-undo .
define VARIABLE dtl-out as integer no-undo .
define VARIABLE line-ret as integer no-undo .
define VARIABLE dtl-ret as integer no-undo .
define VARIABLE nf-chk-amount as integer no-undo .
define VARIABLE nf-gds-amount as integer no-undo .
define VARIABLE ps-where-rus as character no-undo .
define VARIABLE v-ps as character no-undo .
define buffer buf_inkas for ub.inkas.
OUTPUT STREAM TEST TO testi7.txt.
find first buf_inkas no-lock where buf_inkas.inkas-code = my-inkas.
run get-inkas-ps in this-procedure (
                                    buffer buf_inkas
                                  , output chk-amount
                                  , output gds-amount
                                  , output line-out
                                  , output dtl-out
                                  , output line-ret
                                  , output dtl-ret
                                  , output nf-chk-amount
                                  , output nf-gds-amount
                                  , output ps-where-rus
                                  ).
if ub.inkas.status_ <> 'факт':U then do:
  v-PS = substitute("Кол-во_чеков &1&3строк_чеков &2"
                      , chk-amount
                      , gds-amount
                      , chr(10))
                + chr(10).
end.
v-ps = v-ps +
       SUBSTITUTE("товаров_расход &1&3признаков_расход &2"
                    , line-out
                    , dtl-out
                    , chr(10)
                    )
       + chr(10) +
       SUBSTITUTE("товаров_возврат &1&3признаков_возврат &2"
                    , line-ret
                    , dtl-ret
                    , chr(10)
                    ).
if inkas.status_ <> 'факт':U then do:
  v-ps = v-ps + chr(10) +
               substitute("без_докум_чеков &1&3без_докум_строк_чеков &2"
                         , nf-chk-amount
                         , nf-gds-amount
                         , chr(10)
                         ).
end.
PUT stream TEST UNFORMATTED
substitute("КОЛИЧЕСТВО СТРОК ЧЕКОВ И ЧЕКОВ ПО ПРОДАЖЕ &1", my-inkas)
skip(0)
"По подсчету:" SKIP(1)
v-ps skip(1)
"В примечаниях к продаже" SKIP(1)
replace(inkas.ps, chr(4), chr(10))
SKIP.
END PROCEDURE.
PROCEDURE testi :
DEFINE INPUT PARAMETER test-number as integer.
DEFINE INPUT PARAMETER my-inkas as char.
define variable accumq as decimal no-undo.
define variable accumc as decimal no-undo.
define variable accumall as decimal no-undo.
define variable accumall1 as decimal no-undo.
define variable for-netto as decimal no-undo.
define variable for-discnt as decimal no-undo.
define variable for-sub-disc as decimal no-undo.
define variable for-num-chk as integer no-undo.
define variable for-brutto as decimal no-undo.
define variable for-netto-r as decimal no-undo.
define variable for-discnt-r as decimal no-undo.
define variable for-brutto-r as decimal no-undo.
define variable for-netto-v as decimal no-undo.
define variable for-discnt-v as decimal no-undo.
define variable for-brutto-v as decimal no-undo.
define variable for-sum as decimal no-undo.
define variable for-base as decimal no-undo.
define variable for-rubl as decimal no-undo.
define variable newprice as decimal no-undo.
define variable flag as logical.
define variable current-netto as  decimal no-undo.
define variable current-brutto as  decimal no-undo.
define variable current-discnt as  decimal no-undo.
define variable current-write-off as  decimal no-undo.
define variable for-write-off as  decimal no-undo.
def buffer ret-doc for ub.trn-doc.
define buffer buf_sale-doc for ub.sale-doc.
define buffer locked_trn-doc for ub.trn-doc.
END PROCEDURE.
