block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle     as handle no-undo .
define input parameter p-parameter      as character        no-undo.
define variable parinkas-code like ub.inkas.inkas-code no-undo .
define variable vss-revision    as character no-undo initial "$Revision: 6ae23366fafd, 1264, rls $":U .
define variable vss-author      as character no-undo initial "$Author: SMMolotkov $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Mar 19 13:02:46 2018 +0300 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: delfsale.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: str/delfsale.p $":U .
define variable vss-description as character no-undo initial "Удаление продажи закрытой на факт".
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
    assign
      p-vss-parameters = substitute('&1':u,parinkas-code)
    .
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
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#trdcalib as handle no-undo.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table lib-trn_ret-doc       no-undo like ub.trn-doc.
define temp-table lib-trn_ret-line      no-undo like ub.doc-line
  field cst-code                like ub.trn-doc.cst-code
  field part-code               like ub.parts.part-code
  .
define temp-table lib-trn_ret-line-attr no-undo like ub.doc-line-attr.
define temp-table lib-trn_ret-dtl       no-undo like ub.gds-dtl.
define temp-table lib-trn_ret-parts     no-undo like ub.parts.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define   temp-table tt0-info no-undo
field doc-code   like ub.trn-doc.doc-code
field artic      like ub.doc-line.artic
field prod-type  like ub.doc-line.prod-type
field prod-code  like ub.doc-line.prod-code
field prt-code  like ub.gds-dtl.prt-code
field obj-type   like ub.doc-line.obj-type
field obj-code   like ub.doc-line.obj-code
field error-message as character
field a-to-res as decimal
field was-res as decimal
field to-res as decimal
field is-res as decimal
field o-was-res as decimal
field o-to-res as decimal
field o-is-res as decimal
index pi is unique primary
obj-type
obj-code
artic
prod-type
prod-code
index iartic
artic
prod-type
prod-code
.
define   temp-table tt0-doc-line no-undo like lib-trn_ret-line.
define   temp-table tt0-gds-dtl  no-undo like ub.gds-dtl.
define   temp-table tt0-parts    no-undo like ub.parts.
define   temp-table temp-tpsi-clients  no-undo like ub.clients.
FUNCTION set-tpsi-doc-PS returns character( buffer buf_sale-doc for ub.sale-doc):
define variable v-ps as character no-undo .
assign
v-PS = substitute('@&1 для закрытия продажи &2 на &3&4&5товаров &6&5признаков &7'
                  , entry (lookup (buf_sale-doc.ext-doc-type, 'ee,ev,ie,es,iv':U), 'Межфирм.расход по ТПСИ,Внутр.расход по ТПСИ,Межфирм.приход по ТПСИ,Внутр.приход по ТПСИ':U)
                  , buf_sale-doc.out-code
                  , buf_sale-doc.obj-type
                  , buf_sale-doc.obj-code
                  , chr(4)
                  , buf_sale-doc.tot-lines
                  , buf_sale-doc.tot-dtl
                  ).
return v-Ps.
END FUNCTION.
procedure create-tt0-doc-line-gds-dtl :
define input parameter p-proprietor-obj-type like ub.trn-doc.obj-type no-undo .
define input parameter p-proprietor-obj-code like ub.trn-doc.obj-code no-undo .
define input parameter p-ext-doc-type        as character no-undo .
define input parameter p-doc-code            like ub.trn-doc.doc-code no-undo .
define input parameter p-artic               like ub.gds-dtl.artic no-undo .
define input parameter p-prod-type           like ub.gds-dtl.prod-type no-undo .
define input parameter p-prod-code           like ub.gds-dtl.prod-code no-undo .
define input parameter p-prt-code            like ub.gds-dtl.prt-code  no-undo .
define input parameter p-fact-qnty           like ub.gds-dtl.fact-qnty no-undo .
define output parameter p-was-gds-dtl-doc-qnty  like ub.gds-dtl.fact-qnty no-undo .
define output parameter p-gds-dtl-fact-qnty  like ub.gds-dtl.fact-qnty no-undo .
define parameter buffer b-doc-line           for ub.doc-line.
define parameter buffer b-gds-dtl            for ub.gds-dtl.
define parameter buffer buf_sale-doc for ub.sale-doc.
define variable old-qnty like ub.doc-line.fact-qnty no-undo .
define buffer other_doc-line for ub.doc-line.
define buffer other_gds-dtl for ub.gds-dtl.
  do
  on error undo, return error return-value
  :
    find first tt0-doc-line where
              tt0-doc-line.obj-type = p-proprietor-obj-type
          AND tt0-doc-line.obj-code = p-proprietor-obj-code
          AND tt0-doc-line.prod-type = p-prod-type
          AND tt0-doc-line.prod-code = p-prod-code
          AND tt0-doc-line.artic     = p-artic
          AND tt0-doc-line.ext-doc-type = p-ext-doc-type
          AND tt0-doc-line.status_      = 'нередакт':U no-error .
    if not available tt0-doc-line then do:
      create tt0-doc-line.
      buffer-copy b-doc-line
      except
      obj-type obj-code doc-code status_ ext-doc-type doc-qnty fact-qnty
      to tt0-doc-line
      assign
      tt0-doc-line.status_ = 'нередакт':U
      tt0-doc-line.ext-doc-type = p-ext-doc-type
      tt0-doc-line.obj-type = p-proprietor-obj-type
      tt0-doc-line.obj-code = p-proprietor-obj-code
      tt0-doc-line.doc-code = p-doc-code
      .
    end.
    if p-doc-code <> "":U then do:
      find first other_doc-line no-lock where
              other_doc-line.doc-code = p-doc-code
          AND  other_doc-line.artic    = p-artic
          AND  other_doc-line.prod-type = p-prod-type
          AND  other_doc-line.prod-code = p-prod-code no-error .
      if available other_doc-line then do:
        find first buf_sale-doc where buf_sale-doc.doc-code = other_doc-line.doc-code.
        assign
        tt0-doc-line.doc-qnty = other_doc-line.doc-qnty
        .
      end.
      else do:
        assign
        tt0-doc-line.doc-code = '':U
        .
      end.
    end.
    find first tt0-gds-dtl where
            tt0-gds-dtl.obj-type = p-proprietor-obj-type
        AND tt0-gds-dtl.obj-code = p-proprietor-obj-code
        AND tt0-gds-dtl.prod-type = p-prod-type
        AND tt0-gds-dtl.prod-code = p-prod-code
        AND tt0-gds-dtl.artic     = p-artic
        AND tt0-gds-dtl.prt-code  = p-prt-code  no-error .
    if not available tt0-gds-dtl then do:
      create tt0-gds-dtl.
      buffer-copy b-gds-dtl
      except
      obj-type obj-code doc-code doc-qnty fact-qnty
      to tt0-gds-dtl
      assign
      tt0-gds-dtl.obj-type = p-proprietor-obj-type
      tt0-gds-dtl.obj-code = p-proprietor-obj-code
      tt0-gds-dtl.doc-code = p-doc-code
      .
    end.
    if p-doc-code <> "":U then do:
        find first other_gds-dtl no-lock where
                other_gds-dtl.doc-code = p-doc-code
            AND  other_gds-dtl.artic    = p-artic
            AND  other_gds-dtl.prod-type    = p-prod-type
            AND  other_gds-dtl.prod-code    = p-prod-code
            AND  other_gds-dtl.prt-code    = p-prt-code no-error .
        if available other_gds-dtl then do:
          assign
          tt0-gds-dtl.doc-qnty = other_gds-dtl.doc-qnty
          .
        end.
        else do:
          assign
          tt0-gds-dtl.doc-code = '':U
          .
        end.
    end.
    assign
    old-qnty = tt0-gds-dtl.doc-qnty
    tt0-gds-dtl.fact-qnty = (if p-fact-qnty = ? then (- old-qnty) else (p-fact-qnty - tt0-gds-dtl.doc-qnty))
    tt0-doc-line.fact-qnty = tt0-doc-line.fact-qnty + (if p-fact-qnty = ? then (- old-qnty) else p-fact-qnty)
    p-gds-dtl-fact-qnty = tt0-gds-dtl.fact-qnty
    p-was-gds-dtl-doc-qnty = tt0-gds-dtl.doc-qnty
    .
  end.
end procedure.
procedure fill-tt-tpsi-table :
define input parameter p-doc-code  like ub.trn-doc.doc-code  no-undo .
define input parameter p-host-code like ub.trn-doc.host-code no-undo .
define input parameter p-obj-type  like ub.trn-doc.obj-type  no-undo .
define input parameter p-obj-code  like ub.trn-doc.obj-code  no-undo .
define variable v-proprietor-host-code      like ub.clients.host-code no-undo .
define variable v-proprietor-obj-type       like ub.clients.obj-type no-undo .
define variable v-proprietor-obj-code       like ub.clients.obj-code no-undo .
define variable v-ext-doc-type              like ub.trn-doc.ext-doc-type no-undo .
define variable v-gds-dtl-fact-qnty         like ub.gds-dtl.fact-qnty no-undo .
define variable v-was-gds-dtl-fact-qnty     like ub.gds-dtl.fact-qnty no-undo .
define buffer buf_goods for ub.goods.
define buffer buf_doc-line for ub.doc-line.
define buffer buf_gds-dtl for ub.gds-dtl.
define buffer buf_sale-doc for ub.sale-doc.
  do
  on error undo, return error
  :
    _doc-line:
    for each buf_Doc-line no-lock where
          buf_doc-line.doc-code = p-doc-code,
      first buf_goods no-lock where
          buf_goods.artic = buf_doc-line.artic
     AND  buf_goods.prod-type  = buf_doc-line.prod-type
     AND  buf_goods.prod-code  = buf_doc-line.prod-code,
        each buf_gds-dtl no-lock where
          buf_gds-dtl.doc-code = buf_doc-line.doc-code
      AND  buf_gds-dtl.artic    = buf_doc-line.artic
      AND  buf_gds-dtl.prod-type = buf_doc-line.prod-type
      AND  buf_gds-dtl.prod-code = buf_doc-line.prod-code:
      assign
      v-ext-doc-type = "":U.
      run tpsi-preselect-gds-proprietor in this-procedure (
                                                  input buf_goods.gds-code
                                                ,input g#db-num
                                                ,output v-proprietor-host-code
                                                ,output v-proprietor-obj-type
                                                ,output v-proprietor-obj-code ) no-error .
      if v-proprietor-host-code = p-host-code then do:
        assign
        v-ext-doc-type = 'ev':U .
      end.
      else do:
        assign
        v-ext-doc-type =  'ee':U .
      end.
      if  (v-proprietor-obj-type = p-obj-type
      AND v-proprietor-obj-code = p-obj-code)
      OR (v-proprietor-obj-type = "":U
      AND v-proprietor-obj-code = 0)
      OR v-proprietor-obj-code = ?
      then next _doc-line.
      find first buf_sale-doc no-lock where
                buf_sale-doc.inkas-code = p-doc-code
           AND buf_sale-doc.obj-type = v-proprietor-obj-type
           AND buf_sale-doc.obj-code = v-proprietor-obj-code
           AND buf_sale-doc.ext-doc-type = v-ext-doc-type
           no-error .
      run create-tt0-doc-line-gds-dtl  in this-procedure (
                                                           input v-proprietor-obj-type
                                                          ,input v-proprietor-obj-code
                                                          ,input v-ext-doc-type
                                                          ,input (if available buf_sale-doc then buf_sale-doc.doc-code else "":U)
                                                          ,input buf_doc-line.artic
                                                          ,input buf_Doc-line.prod-type
                                                          ,input buf_doc-line.prod-code
                                                          ,input buf_gds-dtl.prt-code
                                                          ,input 0
                                                          ,output v-was-gds-dtl-fact-qnty
                                                          ,output v-gds-dtl-fact-qnty
                                                          ,buffer buf_doc-line
                                                          ,buffer buf_gds-dtl
                                                          ,buffer buf_sale-doc
                                                        ).
    end.
  end.
end procedure.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
procedure get-alias-type-price-obj :
define input parameter p-host-code like ub.sysconf.host-code no-undo .
define input parameter p-obj-type  like ub.clients.obj-type no-undo .
define input parameter p-obj-code  like ub.clients.obj-code no-undo .
define input parameter p-prop-host-code like ub.sysconf.host-code no-undo .
define input parameter p-prop-obj-type  like ub.clients.obj-type no-undo .
define input parameter p-prop-obj-code  like ub.clients.obj-code no-undo .
define output parameter p-ext-doc-type like ub.trn-doc.ext-doc-type no-undo .
define output parameter p-alias-type-price as character no-undo .
define output parameter p-price-obj-type like ub.clients.obj-type no-undo .
define output parameter p-price-obj-code like ub.clients.obj-code no-undo .
define variable v-mediat-obj-type           like ub.trn-doc.obj-type no-undo .
define variable v-mediat-obj-code           like ub.trn-doc.obj-code no-undo .
define variable v-mediat-objf               as character no-undo .
define variable v-param-type as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-tth as handle no-undo .
assign
v-tth = buffer thbjattr_thbj-attr:table-handle .
define buffer buf_trn-doc for ub.trn-doc.
  _main:
  do
  on error undo, return error return-value
  :
    run adm/shattri.p (
      input "get":U
      ,input  p-prop-obj-type
      ,input  p-prop-obj-code
      ,input  'alias-tpsi':U
      ,input  '':U
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-value-logical
      ,output v-param-type
      ,INPUT-OUTPUT table-handle v-tth
      ) no-error .
    if error-status:error
    then do:
      undo _main, return error substitute("Не удалось определить настройки МЕЖФИРМЕННОГО ИЛИ ВНУТРЕННЕГО ПЕРЕМЕЩЕНИЯ ЧУЖИХ ТОВАРОВ для &1&2"
                              , p-prop-obj-type
                              , p-prop-obj-code).
    end.
    find first thbjattr_thbj-attr where
              thbjattr_thbj-attr.obj-type = p-prop-obj-type
          and thbjattr_thbj-attr.obj-code = p-prop-obj-code
          and thbjattr_thbj-attr.upper-prop-code = 'alias-tpsi':U
          and thbjattr_thbj-attr.prop-code = 'alias-type-price':U no-error.
    if not available thbjattr_thbj-attr
    or thbjattr_thbj-attr.property-value-integer = 0 then do:
      undo _main, return error substitute("Не задано значение атрибута ТИП ЦЕНЫ МЕЖФИРМЕННОГО ИЛИ ВНУТРЕННЕГО ПЕРЕМЕЩЕНИЯ ЧУЖИХ ТОВАРОВ для &1&2"
                              , p-prop-obj-type
                              , p-prop-obj-code).
    end.
    assign
    p-alias-type-price = string(thbjattr_thbj-attr.property-value-integer).
    if p-prop-host-code = p-host-code
    and (p-alias-type-price = '':U
    or   p-alias-type-price <> '5':U)
    then  do:
      assign
      p-ext-doc-type = 'ev':U
      p-price-obj-type = p-obj-type
      p-price-obj-code = p-obj-code
      p-alias-type-price = '3':U
      .
    end.
    else do:
      if p-prop-host-code = p-host-code  then do:
        assign
        p-ext-doc-type = 'ev':U
        p-price-obj-type = p-obj-type
        p-price-obj-code = p-obj-code
        .
      end.
      else do:
        assign
        p-ext-doc-type = 'ee':U.
        assign
        v-mediat-obj-type = "":U
        v-mediat-obj-code = 0
        v-mediat-objf = "":U
        .
        if p-alias-type-price = '4':U then do:
          find first thbjattr_thbj-attr where
                    thbjattr_thbj-attr.obj-type = p-prop-obj-type
                and thbjattr_thbj-attr.obj-code = p-prop-obj-code
                and thbjattr_thbj-attr.upper-prop-code = 'alias-tpsi':U
                and thbjattr_thbj-attr.prop-code = 'alias-object-price':U no-error.
          if not available thbjattr_thbj-attr
          or thbjattr_thbj-attr.property-value-character = "":U then do:
            undo _main, return error substitute("Не найден объект-посредник для межфирменного перемещения ЧУЖИХ товаров с &1&2"
                                    , p-prop-obj-type
                                    , p-prop-obj-code).
          end.
          assign
          v-mediat-objf     = thbjattr_thbj-attr.property-value-character
          v-mediat-obj-type = entry(1, v-mediat-objf)
          v-mediat-obj-code = integer(entry(2, v-mediat-objf))
          no-error
          .
          if error-status:error then do:
            undo _main, return error substitute("Неверный формат атрибута ОБЪЕКТ-ПОСРЕДНИК для межфирменного перемещения ЧУЖИХ товаров для &1&2"
                                    , p-prop-obj-type
                                    , p-prop-obj-code).
          end.
        end.
        CASE p-alias-type-price:
          when '1':U then do:
            assign
            p-price-obj-type = p-prop-obj-type
            p-price-obj-code = p-prop-obj-code
            .
          end.
          when '2':U then do:
            assign
            p-price-obj-type = p-prop-obj-type
            p-price-obj-code = p-prop-obj-code
            .
          end.
          when '3':U
          or
          when '5':U
          then do:
            assign
            p-price-obj-type = p-obj-type
            p-price-obj-code = p-obj-code
            .
          end.
          when '4':U then do:
            assign
            p-price-obj-type = v-mediat-obj-type
            p-price-obj-code = v-mediat-obj-code
            .
          end.
        END CASE.
      end.
    end.
  end.
end procedure.
procedure write-tt0-info:
define input parameter p-artic as character no-undo .
define input parameter p-prod-type as character no-undo .
define input parameter p-prod-code as integer no-undo .
define input parameter p-prt-code as integer no-undo .
define input parameter p-obj-type as character no-undo .
define input parameter p-obj-code as integer no-undo .
define input parameter p-doc-code as character no-undo .
define input parameter p-from-tpsi as logical no-undo .
define input parameter p-all-qnty as decimal no-undo .
define input parameter p-was-res as decimal no-undo .
define input parameter p-to-res as decimal no-undo .
define input parameter p-is-res as decimal no-undo .
define input parameter p-o-was-res as decimal no-undo .
define input parameter p-o-to-res as decimal no-undo .
define input parameter p-o-is-res as decimal no-undo .
define input parameter p-mess   as character no-undo .
define buffer buf_tt0-info for tt0-info.
  do
  on error undo, return error return-value
  :
    find first buf_tt0-info where
             buf_tt0-info.artic = p-artic
         and buf_tt0-info.prod-type = p-prod-type
         and buf_tt0-info.prod-code = p-prod-code
         and buf_tt0-info.prt-code = p-prt-code
         no-error .
    if not available buf_tt0-info then do:
      create buf_tt0-info.
      assign
      buf_tt0-info.artic = p-artic
      buf_tt0-info.prod-type = p-prod-type
      buf_tt0-info.prod-code = p-prod-code
      buf_tt0-info.prt-code  = p-prt-code
      buf_tt0-info.obj-type  = p-obj-type
      buf_tt0-info.obj-code  = p-obj-code
      buf_tt0-info.a-to-res  = ?
      buf_tt0-info.to-res    = ?
      buf_tt0-info.was-res   = ?
      buf_tt0-info.o-was-res = ?
      buf_tt0-info.o-to-res  = ?
      buf_tt0-info.o-is-res  = ?
      buf_tt0-info.is-res    = ?
      .
    end.
    assign
    buf_tt0-info.a-to-res  =
                              (if buf_tt0-info.a-to-res <> ?
                              and p-all-qnty = ?
                              then buf_tt0-info.a-to-res
                              else p-all-qnty)
    buf_tt0-info.was-res   = (if buf_tt0-info.was-res <> ?
                              and p-was-res = ?
                              then buf_tt0-info.was-res
                              else p-was-res)
    buf_tt0-info.to-res    = (if buf_tt0-info.to-res <> ?
                              and p-to-res = ?
                              then buf_tt0-info.to-res
                              else p-to-res)
    buf_tt0-info.is-res    = (if buf_tt0-info.is-res <> ?
                              and p-is-res = ?
                              then buf_tt0-info.is-res
                              else p-is-res)
    buf_tt0-info.o-was-res   = (if buf_tt0-info.o-was-res <> ?
                              and p-o-was-res = ?
                              then buf_tt0-info.o-was-res
                              else p-o-was-res)
    buf_tt0-info.o-to-res    = (if buf_tt0-info.o-to-res <> ?
                              and p-o-to-res = ?
                              then buf_tt0-info.o-to-res
                              else p-o-to-res)
    buf_tt0-info.o-is-res    = (if buf_tt0-info.o-is-res <> ?
                              and p-o-is-res = ?
                              then buf_tt0-info.o-is-res
                              else p-o-is-res)
    .
    assign
    buf_tt0-info.doc-code  = p-doc-code
    buf_tt0-info.error-message   = p-mess
    .
  end.
end procedure.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure cur-time :
   define output parameter p-today as date      no-undo .
   define output parameter p-time  as integer   no-undo .
  do
  on error undo, return error
  :
    define variable v-date1 as date      no-undo .
    define variable v-date2 as date      no-undo .
    define variable v-time  as integer   no-undo .
    assign
      v-date1 = today
      v-time  = time
      v-date2 = today
    .
    if v-date1 <> v-date2
    then do:
      assign
        v-date1 = today
        v-time  = v-time
      .
    end.
    assign
      p-today = v-date1
      p-time  = v-time
    .
  end.
end.
function cur-time-date returns character
:
  return string(today, '99/99/9999':U) .
end.
function cur-time-mjd returns decimal
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return integer(v-date) - 2400002 + (v-time / 86400) .
end.
function cur-time-get-ending-index returns integer
(input p-number as integer
)
:
  if p-number < 0
  or p-number = ?
  then do:
    return 1 .
  end.
  define variable v-rest as integer   no-undo .
  assign
    p-number = p-number modulo 100
  .
  if p-number < 20
  then do:
    assign
      v-rest = p-number
    .
  end.
  else do:
    assign
      v-rest = p-number modulo 10
    .
  end.
  case v-rest :
    when 1
    then do:
      return 2 .
    end.
    when 2 or
    when 3 or
    when 4
    then do:
      return 3 .
    end.
    otherwise do:
      return 1 .
    end.
  end case .
end.
procedure cur-time-mjd-to-date :
   define input  parameter i-mjd-diff as decimal no-undo.
   define output parameter o-Date     as date    no-undo.
   define output parameter o-Time     as integer no-undo.
   define variable v-day-number as integer   no-undo .
   if    i-mjd-diff < 0
      or i-mjd-diff = ?
   then do:
      return "?" .
   end.
   assign
      v-day-number = truncate(i-mjd-diff,0).
      o-Date = date(v-day-number + 2400002).
      o-Time = truncate((i-mjd-diff - v-day-number) * 86400, 0)
  .
end.
function cur-time-mjd-to-string returns character
(input p-mjd-diff as decimal
)
:
  define variable v-day-number as integer   no-undo .
  define variable v-seconds    as integer   no-undo .
  define variable v-hour       as integer   no-undo .
  define variable v-min        as integer   no-undo .
  define variable v-day-name    as character no-undo extent 3 initial [   "дней",    "день",     "дня" ] .
  define variable v-hour-name   as character no-undo extent 3 initial [  "часов",     "час",    "часа" ] .
  define variable v-min-name    as character no-undo extent 3 initial [  "минут",  "минута",  "минуты" ] .
  define variable v-second-name as character no-undo extent 3 initial [ "секунд", "секунда", "секунды" ] .
  if p-mjd-diff < 0
  or p-mjd-diff = ?
  then do:
    return "?" .
  end.
  assign
    v-day-number = integer(truncate(p-mjd-diff,0))
    v-seconds    = truncate((p-mjd-diff - v-day-number) * 86400, 0)
  .
  if v-seconds > 86400
  then do:
    assign
      v-seconds = 86400 - 1
    .
  end.
  if v-seconds < 0
  then do:
    assign
      v-seconds = 0
    .
  end.
  assign
    v-hour = truncate(v-seconds / 3600, 0)
  .
  assign
    v-seconds = v-seconds modulo 3600
  .
  assign
    v-min = truncate(v-seconds / 60, 0)
  .
  assign
    v-seconds = v-seconds modulo 60
  .
  return
      (if v-day-number <> 0
        then string(v-day-number) + " " + v-day-name[cur-time-get-ending-index(v-day-number)] + " "
        else ""
      )
    + (if v-day-number <> 0 or v-hour <> 0
        then string(v-hour) + " " + v-hour-name[cur-time-get-ending-index(v-hour)] + " "
        else ""
      )
    + (if v-day-number <> 0 or v-hour <> 0 or v-min <> 0
        then string(v-min) + " " + v-min-name[cur-time-get-ending-index(v-min)] + " "
        else ""
      )
    + string(v-seconds) + " " + v-second-name[cur-time-get-ending-index(v-seconds)]
    .
end.
function cur-time-string returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return string(v-date, '99/99/9999':U) + ' ':u + string(v-time, 'HH:MM':U) .
end.
function cur-time-string-sec returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return string(v-date, '99/99/9999':U) + ' ':u + string(v-time, 'HH:MM:SS':U) .
end.
function cur-time-custom  returns character
(input p-prefix as character
,input p-date-format as character
,input p-delimiter as character
,input p-time-format as character
,input p-suffix as character
)
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return
    p-prefix
    + string(v-date, p-date-format)
    + p-delimiter
    + string(v-time, p-time-format)
    + p-suffix
    .
end.
function cur-time-print  returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return "Дата печати : " + string(v-date, '99.99.9999':U) + ' , ':U + string(v-time, 'HH:MM':U) .
end.
function cur-time-datetime returns datetime
:
  define variable v-char as character no-undo .
  define variable v-datetime as datetime no-undo .
  v-char = cur-time-string().
  v-datetime = datetime(v-char).
  return  v-datetime.
end.
function cur-time-string-msec returns character
:
  define variable v-date as datetime  no-undo .
  v-date = now.
  return string(v-date) .
end.
def var vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
procedure clntattr-code :
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-code in g#attr-lib
      (input  p-code
      ,output p-type
      ,output p-format
      ,output p-label
      ,output p-user-can-edit
      ,output p-output-display
      ,output p-other
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-tooltip in g#attr-lib
      (input  p-code
      ,output p-tooltip
      ,output p-label
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-value :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define output parameter p-value    like ub.clients-attr.attr-value no-undo .
  define output parameter p-type     as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-value in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-value
      ,output p-type
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-write :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define input  parameter p-value    like ub.clients-attr.attr-value no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-write in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,input  p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-exist :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define output parameter p-exist    as logical  no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-exist in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-delete :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo.
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-delete in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-copy-to :
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .
  define input  parameter p-code     as character no-undo .
  define input  parameter p-bh       as handle no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-copy-to in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,input  p-bh
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-news :
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-news in g#attr-lib
      (input  p-code
      ,output p-news
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-get-archive-attr :
  define output parameter p-archive-attr-list as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-get-archive-attr in g#attr-lib
      (output  p-archive-attr-list
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-get-auto-author-attr :
  define output parameter p-archive-attr-list as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-get-auto-author-attr in g#attr-lib
      (output  p-archive-attr-list
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-get-archive-by-type :
  define input  parameter p-archive-type      as character no-undo .
  define output parameter p-archive-attr-list as character no-undo .
  define variable vss-description as character no-undo initial "clntattr-get-archive-by-type-01: возвращает список атрибутов для складского архива".
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-get-archive-by-type in g#attr-lib
      (input  p-archive-type
      ,output p-archive-attr-list
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-vat-register :
  define input parameter p-obj-type like ub.clients.obj-type no-undo .
  define input parameter p-obj-code like ub.clients.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-vat-register in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-requisite-alc-decl :
  define input parameter p-obj-type like ub.clients.obj-type no-undo .
  define input parameter p-obj-code like ub.clients.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-requisite-alc-decl in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-manual-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-manual-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-batch-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-batch-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable v-view-log        as logical   no-undo .
define variable v-esm             as character no-undo .
define variable v-input-error     as logical   no-undo .
define variable v-user-action     as character no-undo .
define variable v-printed         as logical   no-undo .
define variable v-deleted         as logical   no-undo .
define variable jj                as integer   no-undo .
define variable cre-pay           like ub.cash-pay.cdpay-code no-undo .
define variable varobj-date       as date      no-undo .
define variable varshift-date     like ub.shift-obj.shift-date no-undo .
define variable varshift-num      like ub.shift-obj.shift-num  no-undo .
define variable varshift-name     as character no-undo.
define variable l-shift-on        as logical   no-undo .
define variable varmin-fact-order as decimal   no-undo .
define variable v-err-mes         as character no-undo .
define variable conf-par          as character no-undo .
define variable par-type          as character no-undo .
define variable varchip-code      as integer   no-undo .
define variable varchip-code2     as integer   no-undo .
define variable wth-ii            as integer   no-undo .
define variable v-can-del-fbr-doc as logical   no-undo.
define variable v-supp-doc-code   as character no-undo initial '0'.
define variable log-file-name     as character no-undo initial 'delfsale.log'.
define variable v-need-saledc     as logical no-undo .
define buffer buf_inkas for ub.inkas .
define buffer buf_obj for ub.clients.
define buffer sale_trn-doc for ub.trn-doc .
define buffer buf_wth-doc for ub.wth-doc .
define buffer buf_cash-pay for ub.cash-pay.
define buffer bf-pri_trn-doc for ub.trn-doc.
define buffer bf_clients for ub.clients.
define buffer supp_trn-doc for ub.trn-doc .
define buffer neg_trn-doc for ub.trn-doc .
define buffer buf_sale-doc for ub.sale-doc.
define buffer buf_trn-doc for ub.trn-doc.
define buffer locked_trn-doc for ub.trn-doc.
define buffer tpsi_sale-doc for ub.sale-doc.
define stream LogStream.
_main:
do transaction
on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
:
  if not g#news then do:
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  end.
  else do:
    run get-db-num in parparentproc ( output v-cntxt-db-num).
    run get-userid in parparentproc ( output v-cntxt-userid).
  end.
  if search ("del-doc.err") <> ?
  then do:
    os-delete "del-doc.err".
  end.
  assign
  parinkas-code = p-parameter
  .
  find first buf_inkas exclusive-lock
    where buf_inkas.inkas-code = parinkas-code
    no-error .
  if not available buf_inkas
  then do:
     if g#news                                                                                                             then .                          else run write-log-and-file in p-log-handle (                                                                                    input 1                                                                                                             , input log-file-name                                                                                                 , input 1                                                                                                             , input substitute("&1 &2 &3&4!!!Ошибка задания входных параметров: не найдена продажа &5"                  ,vss-workfile                                                                             ,vss-revision                                                                             ,vss-description                                                                          , chr(10)                                                                           , parinkas-code)).
    undo _main, return error.
  end.
  if buf_inkas.status_ <> 'факт':U
  then do:
    if g#news                                                                                                             then .                          else run write-log-and-file in p-log-handle (                                                                                    input 1                                                                                                             , input log-file-name                                                                                                 , input 1                                                                                                             , input substitute("&1 &2 &3&4!!!Ошибка задания входных параметров: продажа &5 статус &6"                   ,vss-workfile                                                                             ,vss-revision                                                                             ,vss-description                                                                          , chr(10)                                                                           , parinkas-code                                                                           , buf_inkas.status_                                                                       )).
    undo _main, return error.
  end.
  find first ub.sys-ctrl no-lock.
  find first buf_obj  no-lock where
             buf_obj.obj-type = buf_inkas.obj-type
        AND  buf_obj.obj-code = buf_inkas.obj-code .
  if ub.sys-ctrl.db-num <> buf_obj.db-num and not g#news
  then do:
    if g#news                                                                                                             then .                          else run write-log-and-file in p-log-handle (                                                                                    input 1                                                                                                             , input log-file-name                                                                                                 , input 1                                                                                                             , input substitute("&1 &2 &3&4Нельзя удалить продажу &5, принадлежащую объекту другой БД &6"                  ,vss-workfile                                                                                            ,vss-revision                                                                                            ,vss-description                                                                                         , chr(10)                                                                                          , parinkas-code                                                                                          , buf_obj.db-num                                                                                         )).
    undo _main, return error.
  end.
  find first ub.sysconf no-lock
    where ub.sysconf.host-code = buf_inkas.host-code
    no-error .
  if not available ub.sysconf
  then do:
   if g#news                                                                                                             then .                          else run write-log-and-file in p-log-handle (                                                                                    input 1                                                                                                             , input log-file-name                                                                                                 , input 1                                                                                                             , input substitute("&1 &2 &3&4Не найдена запись о фирме &5"                         ,vss-workfile                                                                 ,vss-revision                                                                 ,vss-description                                                              , chr(10)                                                               , buf_inkas.host-code                                                         )).
   undo _main, return error.
  end.
  find first buf_Cash-pay no-lock where
           buf_cash-pay.cdpay-code = sysconf.credit-pay no-error.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'iscredit'
  ,input  0
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output conf-par
  ,output par-type
  ) no-error .
  if error-status:error
  or not available buf_cash-pay
  or buf_cash-pay.is-credit = no
  or conf-par <> "yes"
  then do:
     assign
     cre-pay = 0
     .
  end.
  else do:
    assign
    cre-pay = sysconf.credit-pay
    .
  end.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdtget in g#library
  (input  buf_inkas.obj-type
  ,input  buf_inkas.obj-code
  ,output varobj-date
  ) no-error .
  if error-status :error
  or varobj-date = ?
  then do:
    if g#news                                                                                                             then .                          else run write-log-and-file in p-log-handle (                                                                                    input 1                                                                                                             , input log-file-name                                                                                                 , input 1                                                                                                             , input substitute("Нет текущей даты на объекте продажи &1 &2&3&4&5 &6"                  , buf_inkas.inkas-code                                                              , buf_inkas.obj-type                                                                , buf_inkas.obj-code                                                                , chr(10)                                                                     , error-status:get-message(1)                                                       , return-value                                                                      )).
    undo _main, return error.
  end.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  buf_inkas.obj-type
  ,input  buf_inkas.obj-code
  ,input  'shift-on=request'
  ,output l-shift-on
  )  .
  if l-shift-on
  then do:
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curshift in g#library
  (input  buf_inkas.obj-type
  ,input  buf_inkas.obj-code
  ,output varshift-date
  ,output varshift-num
  ,output varshift-name
  ) no-error .
    if error-status :error
    then do:
      if g#news                                                                                                             then .                          else run write-log-and-file in p-log-handle (                                                                                    input 1                                                                                                             , input log-file-name                                                                                                 , input 1                                                                                                             , input substitute("!!!Ошибка при поиске текущей смены на объекте продажи &1 &2&3&4&5 &6"                  , buf_inkas.inkas-code                                                                             , buf_inkas.obj-type                                                                               , buf_inkas.obj-code                                                                               , chr(10)                                                                                    , error-status:get-message(1)                                                                      , return-value                                                                                     )).
      undo _main, return error.
    end.
  end.
  else do:
    assign
      varshift-date = ?
      varshift-num  = ?
    .
  end.
  find first sale_trn-doc exclusive-lock
    where sale_trn-doc.doc-code = parinkas-code
    no-error .
  if not available sale_trn-doc
  then do:
    if g#news                                                                                                             then .                          else run write-log-and-file in p-log-handle (                                                                                    input 1                                                                                                             , input log-file-name                                                                                                 , input 1                                                                                                             , input substitute("&1 &2 &3&4Не найден или занят складской документ расхода через кассу для продажи &5"                  ,vss-workfile                                                                                             ,vss-revision                                                                                             ,vss-description                                                                                          , chr(10)                                                                                           , buf_inkas.inkas-code                                                                                    )).
    undo _main, return error.
  end.
  for each buf_sale-doc where
          buf_sale-doc.inkas-code = buf_inkas.inkas-code
      and  buf_sale-doc.order > 0,
      first locked_trn-doc exclusive-lock where
          locked_trn-doc.doc-code = buf_sale-doc.doc-code
  on error undo _main, return error
  on stop undo _main, return error :
  end.
  find first neg_trn-doc exclusive-lock
    where neg_trn-doc.out-code = sale_trn-doc.doc-code
      AND neg_trn-doc.obj-type = sale_trn-doc.obj-type
      AND neg_trn-doc.obj-code = sale_trn-doc.obj-code
      AND neg_trn-doc.ext-doc-type = 'mp':U
      AND neg_trn-doc.internal = yes
      AND neg_trn-doc.doc-type = 'инв':U
      AND neg_trn-doc.doc-date = sale_trn-doc.doc-date no-error .
  find first supp_trn-doc exclusive-lock
    where supp_trn-doc.out-code = sale_trn-doc.doc-code
      AND supp_trn-doc.obj-type = sale_trn-doc.obj-type
      AND supp_trn-doc.obj-code = sale_trn-doc.obj-code
      AND supp_trn-doc.ext-doc-type = 'pc':U
      AND supp_trn-doc.internal = no
      AND supp_trn-doc.doc-type = 'инв':U
      AND supp_trn-doc.doc-date = sale_trn-doc.doc-date no-error .
  if not g#news
  then do:
    if can-find( first ub.chk-doc NO-LOCK WHERE
                    ub.chk-doc.out-code = buf_inkas.inkas-code
                AND ub.chk-doc.d-card <> "" ) then do:
      if g#news                                                                                                             then .                          else run write-log-and-file in p-log-handle (                                                                                    input 1                                                                                                             , input log-file-name                                                                                                 , input 1                                                                                                             , input substitute("Подсчет итогов продаж по дисконтным картам...")).
      run str/saledc.p
        (input parparentproc
        ,input this-procedure:handle
        ,input p-log-handle
        ,input 'sale-delete':U
        ,input ?
        ,input ""
        ,input 0
        ,input 0
        ,input 0
        ,input g#db-num
        ,input buf_inkas.inkas-code
        ,input buf_inkas.doc-date
        ,input buf_inkas.fact-date
        ,input cre-pay
        ,input (-1)
        ,input ?
        ,input yes
        ) no-error .
      if error-status :error
      then do:
          if g#news                                                                                                             then .                          else run write-log-and-file in p-log-handle (                                                                                    input 1                                                                                                             , input log-file-name                                                                                                 , input 1                                                                                                             , input substitute("&1 &2 &3&4!!!Ошибка при пересчете итогов по дисконтным картам для продажи &5:&4&6 &7"                   ,vss-workfile                                                                                                      ,vss-revision                                                                                                      ,vss-description                                                                                                   , chr(10)                                                                                                    , buf_inkas.inkas-code                                                                                             , error-status:get-message(1)                                                                                      , return-value                                                                                                     )).
        undo _main, return error.
      end.
    end.
    if g#news
    and can-find( first ub.chk-doc NO-LOCK WHERE
                    ub.chk-doc.out-code = buf_inkas.inkas-code
                AND ub.chk-doc.d-card <> "" ) then do:
      assign
      v-need-saledc = yes.
    end.
  end.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if g#news                                                                                                             then .                          else run write-log-and-file in p-log-handle (                                                                                    input 1                                                                                                             , input log-file-name                                                                                                 , input 1                                                                                                             , input "Отвязывание чеков от документа -        ").
FOR EACH ub.chk-doc WHERE
          ub.chk-doc.obj-type = buf_inkas.obj-type AND
          ub.chk-doc.obj-code = buf_inkas.obj-code AND
          ub.chk-doc.out-code = buf_inkas.inkas-code
on error undo _main, return error substitute("Ошибка при удалении/отвязывании чеков при удалении документа &1", buf_inkas.inkas-code)
          :
    FOR EACH ub.chk-gds WHERE
              ub.chk-gds.doc-code = ub.chk-doc.doc-code :
      if g#news then do:
        delete ub.chk-gds.
      end.
      else do:
        ub.chk-gds.out-code = ? .
        for each ub.marking-chk where ub.marking-chk.doc-code = ub.chk-gds.doc-code
                                  and ub.marking-chk.line-num = ub.chk-gds.line-num :
          ub.marking-chk.sts = 0 .
        end .
      end.
    END .
    FOR EACH ub.chk-pay WHERE
              ub.chk-pay.doc-code = ub.chk-doc.doc-code :
      if g#news then do:
        delete ub.chk-pay.
      end.
      else do:
        ub.chk-pay.out-code = ? .
      end.
    END .
    FOR EACH ub.chk-discnt WHERE
              ub.chk-discnt.doc-code = ub.chk-doc.doc-code :
      if g#news then do:
        delete ub.chk-discnt.
      end.
      else do:
        ub.chk-discnt.out-code = ? .
      end.
    END .
    FOR EACH ub.chk-doc-attr WHERE
              ub.chk-doc-attr.doc-code = ub.chk-doc.doc-code :
      if g#news then do:
        delete ub.chk-doc-attr.
      end.
      else do:
         ub.chk-doc-attr.out-code = ?.
      end.
    END .
    FOR EACH ub.chk-gds-pay WHERE
             ub.chk-gds-pay.doc-code = ub.chk-doc.doc-code :
      delete ub.chk-gds-pay.
    END .
    FOR EACH ub.c-chk-gds WHERE
              ub.c-chk-gds.doc-code = ub.chk-doc.doc-code :
      if g#news then do:
        delete ub.c-chk-gds.
      end.
      else do:
        ub.c-chk-gds.out-code = ? .
      end.
    END .
    FOR EACH ub.c-chk-pay WHERE
              ub.c-chk-pay.doc-code = ub.chk-doc.doc-code :
      if g#news then do:
        delete ub.c-chk-pay.
      end.
      else do:
        ub.c-chk-pay.out-code = ? .
      end.
    END .
    FOR EACH ub.c-chk-discnt WHERE
              ub.c-chk-discnt.doc-code = ub.chk-doc.doc-code :
      if g#news then do:
        delete ub.c-chk-discnt.
      end.
      else do:
        ub.c-chk-discnt.out-code = ? .
      end.
    END .
    FOR EACH ub.c-chk-doc-attr WHERE
              ub.c-chk-doc-attr.doc-code = ub.chk-doc.doc-code :
      if g#news then do:
        delete ub.c-chk-doc-attr.
      end.
    END .
    FOR EACH ub.c-chk-doc WHERE
              ub.c-chk-doc.doc-code = ub.chk-doc.doc-code :
      if g#news then do:
        delete ub.c-chk-doc.
      end.
      else do:
        ub.c-chk-doc.out-code = ? .
      end.
    END .
    if ub.chk-doc.d-card <> "":u
    and lookup(string(ub.chk-doc.chk-type), '14,15,16,36,17,8,11,12,13,40,69,101,106,108,169,196,114,115,116,117,111,112,136,113,101,106,108,208,2,3,4,5,7,43,44':U) = 0
    then do:
      run str/trnsupds.p (
                      input ub.chk-doc.doc-code
                      ,input false) no-error .
      if error-status:error then do:
        assign
        v-err-mes = substitute("Ошибка при пересчете товарного архива по покупателю: чек &1", chk-doc.doc-code)
        .
        undo _main, return error v-err-mes.
      end.
    end.
    if g#news then do:
      delete ub.chk-doc.
    end.
    else do:
      assign
      ub.chk-doc.out-code = ?
      jj = jj + 1
      .
    end.
        if g#news                                                                                                                  then .                               else run write-counter in p-log-handle (input substitute("Отвязывание чеков от документа -       &1", string(jj, "99999"))).
END .
if g#news                                                                                                             then .                          else run write-log-and-file in p-log-handle (                                                                                    input 1                                                                                                             , input log-file-name                                                                                                 , input 1                                                                                                             , input "Удаление записей о выручке ...").
      buf_inkas.is-del = yes.
      if not g#news then do:
        run hstc-inkas in this-procedure (
                                             input recid(buf_inkas)
                                            ,input varobj-date
                                            ,input varshift-date
                                            ,input varshift-num
                                            ,input varshift-name
                                            ,input g#userid
                                            ,output varchip-code
                                            )
                                            no-error .
        if error-status:error then do:
if g#news                                                                                                                  then .                               else run write-log-and-file in p-log-handle (                                                                                            input 1                                                                                                                  , input log-file-name                                                                                                      , input 1                                                                                                                  , input substitute("Ошибка при копировании удаляемой шапки продажи &1:&2&3 &4"                          , buf_inkas.inkas-code                                                                              , chr(10)                                                                      , error-status:get-message(1)                                                        , return-value )).
           .
          undo _main, return error.
        end.
     end.
FOR EACH ub.inkas-pay WHERE
          ub.inkas-pay.inkas-code = buf_inkas.inkas-code :
    delete ub.inkas-pay.
END .
FOR EACH ub.inkas-pay-desk WHERE
          ub.inkas-pay-desk.inkas-code = buf_inkas.inkas-code :
    delete ub.inkas-pay-desk.
END .
FOR EACH ub.inkas-pay-wth WHERE
          ub.inkas-pay-wth.inkas-code = buf_inkas.inkas-code :
    delete ub.inkas-pay-wth.
END .
  if g#news                                                              then .                                                                 else run hide-counter in p-log-handle.
  define variable v-obj-type as character no-undo .
  define variable v-obj-code as integer   no-undo .
  define variable v-host-code as integer no-undo .
  define variable v-auto-fbr as logical no-undo .
  define variable v-inkas-shift-date as date no-undo .
  define variable v-inkas-shift-num as integer no-undo .
  assign
  v-host-code = buf_inkas.host-code
  v-obj-type = buf_inkas.obj-type
  v-obj-code = buf_inkas.obj-code
  v-auto-fbr = buf_inkas.auto-fbr
  v-inkas-shift-date = buf_inkas.shift-date
  v-inkas-shift-num = buf_inkas.shift-num
  .
  delete buf_inkas .
  define variable v-old-shift-obj as handle no-undo  .
  define variable v-new-shift-obj as handle no-undo  .
  define buffer buf_shift-obj for ub.shift-obj .
  if l-shift-on then do:
    find first buf_shift-obj no-lock
         where buf_shift-obj.obj-type = v-obj-type
           and buf_shift-obj.obj-code = v-obj-code
           and buf_shift-obj.shift-date = v-inkas-shift-date
           and buf_shift-obj.shift-num  = v-inkas-shift-num
           and buf_shift-obj.status_  = 'зкр':U
               no-error .
    if available buf_shift-obj then do:
      assign
        v-old-shift-obj = buffer buf_shift-obj:handle
        v-new-shift-obj = v-old-shift-obj
      .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rum-runa in g#library
  (input ?
  ,input this-procedure:handle
  ,input ?
  ,input 'event_shift':U
  ,input v-old-shift-obj
  ,input v-new-shift-obj
  ,input ''
  ,input ''
  ) no-error .
      if error-status :error then do:
        if g#news                                                                                                             then .                          else run write-log-and-file in p-log-handle (                                                                                    input 1                                                                                                             , input log-file-name                                                                                                 , input 1                                                                                                             , input substitute("&2&1Ошибка маршрутизации записи в машину правил&1&3&1&4"              , chr(10)             , vss-workfile             , return-value             , error-status :get-message ( 1 )         )).
        undo _main, return error.
      end.
    end.
  end.
  if not g#news
  then do:
    for each buf_wth-doc exclusive-lock
      where buf_wth-doc.source-type = 'касса':U
        and buf_wth-doc.source-ref  = parinkas-code
    on error undo _main, return error
    :
      assign
        varmin-fact-order = min(buf_wth-doc.fact-order, varmin-fact-order).
        wth-ii = wth-ii + 1
      .
  if g#news                                                                                                             then .                          else run write-log-and-file in p-log-handle (                                                                                    input 1                                                                                                             , input log-file-name                                                                                                 , input 1                                                                                                             , input substitute("Удаление документа МЦ &1, связанного с продажей &2", buf_wth-doc.doc-code, parinkas-code)).
      run trg/wthdocdl.p
        (input buf_wth-doc.doc-code
         ,input varchip-code
         ,'':U
         ,output varchip-code2
        ) no-error .
      if error-status :error
      then do:
        if g#news                                                                                                             then .                          else run write-log-and-file in p-log-handle (                                                                                    input 1                                                                                                             , input log-file-name                                                                                                 , input 1                                                                                                             , input substitute("&1 &2 &3&4!!!Ошибка при удалении документа МЦ &5 для продажи &6:&4&7 &8"                      ,vss-workfile                                                                                        ,vss-revision                                                                                        ,vss-description                                                                                     , chr(10)                                                                                      , parinkas-code                                                                               , buf_wth-doc.doc-code                                                                               , error-status:get-message(1)                                                                        , return-value                                                                                       )).
        undo _main, return error .
      end.
    end.
  if g#news                                                                                                             then .                          else run write-log-and-file in p-log-handle (                                                                                    input 1                                                                                                             , input log-file-name                                                                                                 , input 1                                                                                                             , input substitute("Удаление складских документов, связанных с продажей &1", parinkas-code)).
    if available neg_trn-doc
    then do:
  if g#news                                                                                                             then .                          else run write-log-and-file in p-log-handle (                                                                                    input 1                                                                                                             , input log-file-name                                                                                                 , input 1                                                                                                             , input substitute("Удаление документа автоматической коррекции отрицательных партий &1", neg_trn-doc.doc-code)).
      find first buf_sale-doc where
                buf_sale-doc.inkas-code = parinkas-code
            and buf_sale-doc.storage = 'trn-doc':U
            and buf_sale-doc.doc-code = neg_trn-doc.doc-code no-error.
      run str/del-doc.p (
        input  parparentproc,
        input  neg_trn-doc.doc-code,
        input  g#db-num,
        input  "del-doc.err",
        input  parinkas-code,
        input  ?,
        input  g#userid,
        input  0,
        input  varchip-code,
        output varchip-code2)
        no-error.
      if error-status :error
      then do:
        if search ("del-doc.err") <> ?
        then do:
          if g#news                                                                                                             then .                          else run write-log-and-file in p-log-handle (                                                                                    input 1                                                                                                             , input log-file-name                                                                                                 , input 1                                                                                                             , input substitute("!!!Продажу &1 нельзя удалить&2Документ автоматической коррекции отрицательных партий &3 не удален:&2"                               ,parinkas-code                                                                                              , chr(10)                                                                                               ,neg_trn-doc.doc-code)).
          run read-write-log in this-procedure .
          undo _main, return error .
        end.
        else do:
          if g#news                                                                                                             then .                          else run write-log-and-file in p-log-handle (                                                                                    input 1                                                                                                             , input log-file-name                                                                                                 , input 1                                                                                                             , input substitute("&1 &2 &3&4!!!Ошибка при удалении документа &5&4&6&4&7"                           ,vss-workfile                                                                         ,vss-revision                                                                         ,vss-description                                                                      , chr(10)                                                                       , neg_trn-doc.doc-code                                                               , error-status:get-message(1)                                                         , return-value                                                                        )).
          undo _main, return error.
        end.
      end.
      if available  buf_sale-doc then do:
        delete buf_sale-doc.
      end.
    end.
  _sale-doc:
  for each buf_sale-doc where
          buf_sale-doc.inkas-code = parinkas-code
      and ( buf_sale-doc.order    > 0
         or buf_sale-doc.doc-kind = 'itr':U
         )
  by buf_sale-doc.order descending
  on error undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1)):
  if g#news                                                                                                             then .                          else run write-log-and-file in p-log-handle (                                                                                    input 1                                                                                                             , input log-file-name                                                                                                 , input 1                                                                                                             , input substitute("Удаление документа &1 &2", entry (lookup (buf_sale-doc.doc-kind, 'es,rs,rwo,trf,swo,ngs,rgs,vir':U + ',' + 'itr':U) + 1, ',' + 'касса продажа,касса возврат,Списание-по-Возврату,ТехПролив,Списание,Приход-Природный-Газ,Возврат-Природный-Газ,Перемещение-Вирт-Рез':U + ',' + 'ПриТехПрол':U ), buf_sale-doc.doc-code)).
    define variable v-doc-code as character no-undo .
    define variable v-doc-kind as character no-undo .
    v-doc-code = buf_sale-doc.doc-code.
    v-doc-kind = buf_sale-doc.doc-kind.
    if buf_sale-doc.doc-kind = 'itr':U then do:
      find first buf_trn-doc exclusive-lock where
                buf_trn-doc.doc-code = buf_sale-doc.doc-code no-error.
      if available buf_trn-doc then do:
        if buf_trn-doc.status_ <> 'факт':U then do:
                        if g#news                                                                                                             then .                          else run write-log-and-file in p-log-handle (                                                                                    input 1                                                                                                             , input log-file-name                                                                                                 , input 1                                                                                                             , input substitute("&1 &2 &3&4!!!До удаления продажи необходимо удалить документ прихода по техпроливу &5"                           ,vss-workfile                                                                         ,vss-revision                                                                         ,vss-description                                                                      , chr(10)                                                                       , buf_trn-doc.doc-code                                                               )).
            undo, return error.
          end.
        end.
      else do:
        delete buf_sale-doc.
        next _sale-doc.
      end.
    end.
    delete buf_sale-doc.
    run str/del-doc.p (
      input  parparentproc,
      input  v-doc-code,
      input  g#db-num,
      input  "del-doc.err",
      input  parinkas-code,
      input  ?,
      input  g#userid,
      input  (if available supp_trn-doc then supp_trn-doc.doc-code else '0'),
      input  varchip-code,
      output varchip-code2)
      no-error.
    if error-status :error
    then do:
      if search ("del-doc.err") <> ?
      then do:
        if g#news                                                                                                             then .                          else run write-log-and-file in p-log-handle (                                                                                    input 1                                                                                                             , input log-file-name                                                                                                 , input 1                                                                                                             , input substitute("!!!Продажу &1 нельзя удалить&2&3 &4 не удален:&2"                               ,parinkas-code                                                                                           , chr(10)                                                                                          ,entry (lookup (v-doc-kind, 'es,rs,rwo,trf,swo,ngs,rgs,vir':U + ',' + 'itr':U) + 1, ',' + 'касса продажа,касса возврат,Списание-по-Возврату,ТехПролив,Списание,Приход-Природный-Газ,Возврат-Природный-Газ,Перемещение-Вирт-Рез':U + ',' + 'ПриТехПрол':U )                                                                                      ,v-doc-code)).
          message substitute("!!!Продажу &1 нельзя удалить&2&3 &4 не удален:&2"
                            ,parinkas-code
                            ,chr(10)
                            ,entry (lookup (v-doc-kind, 'es,rs,rwo,trf,swo,ngs,rgs,vir':U + ',' + 'itr':U) + 1, ',' + 'касса продажа,касса возврат,Списание-по-Возврату,ТехПролив,Списание,Приход-Природный-Газ,Возврат-Природный-Газ,Перемещение-Вирт-Рез':U + ',' + 'ПриТехПрол':U )
                            ,v-doc-code)
        return-value
        view-as alert-box information .
        run read-write-log in this-procedure .
        undo _main, return error .
      end.
      else do:
        if g#news                                                                                                             then .                          else run write-log-and-file in p-log-handle (                                                                                    input 1                                                                                                             , input log-file-name                                                                                                 , input 1                                                                                                             , input substitute("&1 &2 &3&4!!!Ошибка при удалении документа &5&4&6&4&7"                                  ,vss-workfile                                                                         ,vss-revision                                                                         ,vss-description                                                                      , chr(10)                                                                       , v-doc-code                                                          , error-status:get-message(1)                                                         , return-value                                                                        )).
        undo _main, return error.
      end.
    end.
  end.
  for each buf_sale-doc where buf_sale-doc.inkas-code = parinkas-code
                          and buf_sale-doc.order = 0:
      delete buf_sale-doc.
  end.
  if available supp_trn-doc
  then do:
      assign
      v-supp-doc-code = supp_trn-doc.doc-code.
  if g#news                                                                                                             then .                          else run write-log-and-file in p-log-handle (                                                                                    input 1                                                                                                             , input log-file-name                                                                                                 , input 1                                                                                                             , input substitute("Удаление документа смены типа приобретения &1", supp_trn-doc.doc-code)).
      find first buf_sale-doc where
                buf_sale-doc.inkas-code = parinkas-code
            and buf_sale-doc.storage = 'trn-doc':U
            and buf_sale-doc.doc-code = supp_trn-doc.doc-code no-error.
      run str/del-doc.p (
        input  parparentproc,
        input  supp_trn-doc.doc-code,
        input  g#db-num,
        input  "del-doc.err",
        input  parinkas-code,
        input  ?,
        input  g#userid,
        input  0,
        input  varchip-code,
        output varchip-code2)
        no-error.
      if error-status :error
      then do:
        if search ("del-doc.err") <> ?
        then do:
          if g#news                                                                                                             then .                          else run write-log-and-file in p-log-handle (                                                                                    input 1                                                                                                             , input log-file-name                                                                                                 , input 1                                                                                                             , input substitute("!!!Продажу &1 нельзя удалить&2Документ смены типа приобретения &3 не удален:&2"                               ,parinkas-code                                                                                              , chr(10)                                                                                               ,supp_trn-doc.doc-code)).
          run read-write-log in this-procedure .
          undo _main, return error .
        end.
        else do:
          if g#news                                                                                                             then .                          else run write-log-and-file in p-log-handle (                                                                                    input 1                                                                                                             , input log-file-name                                                                                                 , input 1                                                                                                             , input substitute("&1 &2 &3&4!!!Ошибка при удалении документа &5&4&6&4&7"                           ,vss-workfile                                                                         ,vss-revision                                                                         ,vss-description                                                                      , chr(10)                                                                       , supp_trn-doc.doc-code                                                               , error-status:get-message(1)                                                         , return-value                                                                        )).
          undo _main, return error.
        end.
      end.
      if available  buf_sale-doc then do:
        delete buf_sale-doc.
      end.
    end.
    for each tpsi_sale-doc where
          tpsi_sale-doc.inkas-code = parinkas-code
      and tpsi_sale-doc.tpsidoc = yes
      and tpsi_sale-doc.ext-doc-type = 'ee':U
    on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
    :
if g#news                                                                                                             then .                          else run write-log-and-file in p-log-handle (                                                                                    input 1                                                                                                             , input log-file-name                                                                                                 , input 1                                                                                                             , input substitute("Удаление документа межфирменного перемещения ЧУЖИХ ТОВАРОВ &1", tpsi_sale-doc.doc-code)).
      find first bf_clients where
              bf_clients.obj-type = tpsi_sale-doc.obj-type
          and bf_clients.obj-code = tpsi_sale-doc.obj-code no-lock.
      if bf_clients.db-num <> buf_obj.db-num
      then do:
        if g#news                                                                                                             then .                          else run write-log-and-file in p-log-handle (                                                                                    input 1                                                                                                             , input log-file-name                                                                                                 , input 1                                                                                                             , input substitute("В документе межфирменного перемещения ЧУЖИХ ТОВАРОВ &1 перемещение проводилось с объекта &2, который сейчас принадлежит базе данных &3.&4" +                           " Нельзя удалять межфирменные документы относящиеся к разным базам данных."                             ,tpsi_sale-doc.doc-code                                                                               ,tpsi_sale-doc.obj-type + string(tpsi_sale-doc.obj-code)                                              ,bf_clients.db-num                                                                                     , chr(10))).
        undo _main, return error.
      end.
      find first bf-pri_trn-doc where
                bf-pri_trn-doc.out-code = tpsi_sale-doc.doc-code
          and  bf-pri_trn-doc.ext-doc-type = 'ie':U exclusive-lock.
      run str/del-doc.p (
        input  parparentproc,
        input  bf-pri_trn-doc.doc-code,
        input  g#db-num,
        input  "del-doc.err",
        input  parinkas-code,
        input  ?,
        input  g#userid,
        input  v-supp-doc-code,
        input  varchip-code,
        output varchip-code2)
        no-error.
      if error-status :error
      then do:
        if search ("del-doc.err") <> ?
        then do:
          if g#news                                                                                                             then .                          else run write-log-and-file in p-log-handle (                                                                                    input 1                                                                                                             , input log-file-name                                                                                                 , input 1                                                                                                             , input substitute("!!!Продажу &1 нельзя удалить&2Документ межфирменного перемещения ЧУЖИХ ТОВАРОВ &3 (приходный) не удален:&2"                           ,parinkas-code                                                                                                        , chr(10)                                                                                                         ,bf-pri_trn-doc.doc-code)).
          run read-write-log in this-procedure .
          undo _main, return error .
        end.
        else do:
          if g#news                                                                                                             then .                          else run write-log-and-file in p-log-handle (                                                                                    input 1                                                                                                             , input log-file-name                                                                                                 , input 1                                                                                                             , input substitute("&1 &2 &3&4!!!Ошибка при удалении документа &5&4&6&4&7"                           ,vss-workfile                                                                       ,vss-revision                                                                       ,vss-description                                                                    , chr(10)                                                                     , bf-pri_trn-doc.doc-code                                                            , error-status:get-message(1)                                                       , return-value                                                                      )).
          undo _main, return error.
        end.
      end.
      run str/del-doc.p (
        input  parparentproc,
        input  tpsi_sale-doc.doc-code,
        input  g#db-num,
        input  "del-doc.err",
        input  parinkas-code,
        input  ?,
        input  g#userid,
        input  v-supp-doc-code,
        input  varchip-code,
        output varchip-code2)
        no-error.
      if error-status :error
      then do:
        if search ("del-doc.err") <> ?
        then do:
          if g#news                                                                                                             then .                          else run write-log-and-file in p-log-handle (                                                                                    input 1                                                                                                             , input log-file-name                                                                                                 , input 1                                                                                                             , input substitute("!!!Продажу &1 нельзя удалить&2Документ межфирменного перемещения ЧУЖИХ ТОВАРОВ &3 не удален:&2"                            ,parinkas-code                                                                                                           , chr(10)                                                                                                            ,tpsi_sale-doc.doc-code)).
          run read-write-log in this-procedure .
          undo _main, return error .
        end.
        else do:
          substitute("&1 &2 &3&4!!!Ошибка при удалении документа &5&4&6&4&7"                           ,vss-workfile                                                                        ,vss-revision                                                                        ,vss-description                                                                     , chr(10)                                                                      , tpsi_sale-doc.doc-code                                                             , error-status:get-message(1)                                                        , return-value                                                                       ).
          undo _main, return error.
        end.
      end.
      delete tpsi_sale-doc.
    end.
    for each tpsi_sale-doc where
            tpsi_sale-doc.inkas-code = parinkas-code
        and tpsi_sale-doc.tpsidoc = yes
        and tpsi_sale-doc.ext-doc-type = 'ev':U
    on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
    :
if g#news                                                                                                             then .                          else run write-log-and-file in p-log-handle (                                                                                    input 1                                                                                                             , input log-file-name                                                                                                 , input 1                                                                                                             , input substitute("Удаление документа внутреннего перемещения ЧУЖИХ ТОВАРОВ &1", tpsi_sale-doc.doc-code)).
      find first bf_clients where
              bf_clients.obj-type = tpsi_sale-doc.obj-type
          and bf_clients.obj-code = tpsi_sale-doc.obj-code no-lock.
      if bf_clients.db-num <> buf_obj.db-num
      then do:
        if g#news                                                                                                             then .                          else run write-log-and-file in p-log-handle (                                                                                    input 1                                                                                                             , input log-file-name                                                                                                 , input 1                                                                                                             , input substitute("В документе внутреннего перемещения ЧУЖИХ ТОВАРОВ &1 перемещение проводилось с объекта &2, который сейчас принадлежит базе данных &3.&4" +                           " Нельзя удалять внутренние документы относящиеся к разным базам данных."                              ,tpsi_sale-doc.doc-code                                                                              ,tpsi_sale-doc.obj-type + string(tpsi_sale-doc.obj-code)                                             ,bf_clients.db-num                                                                                   , chr(10))).
        undo _main, return error.
      end.
      find first bf-pri_trn-doc where
                bf-pri_trn-doc.out-code = tpsi_sale-doc.doc-code
          and  bf-pri_trn-doc.ext-doc-type = 'iv':U exclusive-lock.
      define buffer dop_sale-doc for ub.sale-doc.
      find first dop_sale-doc where
                dop_sale-doc.inkas-code = parinkas-code
            and dop_sale-doc.storage = 'trn-doc':U
            and dop_sale-doc.doc-code = bf-pri_trn-doc.doc-code no-error.
      run str/del-doc.p (
        input  parparentproc,
        input  bf-pri_trn-doc.doc-code,
        input  g#db-num,
        input  "del-doc.err",
        input  parinkas-code,
        input  ?,
        input  g#userid,
        input  v-supp-doc-code,
        input  varchip-code,
        output varchip-code2)
        no-error.
      if error-status :error
      then do:
        if search ("del-doc.err") <> ?
        then do:
          if g#news                                                                                                             then .                          else run write-log-and-file in p-log-handle (                                                                                    input 1                                                                                                             , input log-file-name                                                                                                 , input 1                                                                                                             , input substitute("!!!Продажу &1 нельзя удалить&2Документ внутреннего перемещения ЧУЖИХ ТОВАРОВ &3 (приходный) не удален:&2"                           ,parinkas-code                                                                                                        , chr(10)                                                                                                         ,bf-pri_trn-doc.doc-code)).
          run read-write-log in this-procedure .
          undo _main, return error .
        end.
        else do:
          if g#news                                                                                                             then .                          else run write-log-and-file in p-log-handle (                                                                                    input 1                                                                                                             , input log-file-name                                                                                                 , input 1                                                                                                             , input substitute("&1 &2 &3&4!!!Ошибка при удалении документа &5&4&6&4&7"                           ,vss-workfile                                                                       ,vss-revision                                                                       ,vss-description                                                                    , chr(10)                                                                     , bf-pri_trn-doc.doc-code                                                            , error-status:get-message(1)                                                       , return-value                                                                      )).
          undo _main, return error.
        end.
      end.
      if available dop_sale-doc then delete dop_sale-doc.
      run str/del-doc.p (
        input  parparentproc,
        input  tpsi_sale-doc.doc-code,
        input  g#db-num,
        input  "del-doc.err",
        input  parinkas-code,
        input  ?,
        input  g#userid,
        input  v-supp-doc-code,
        input  varchip-code,
        output varchip-code2)
        no-error.
      if error-status :error
      then do:
        if search ("del-doc.err") <> ?
        then do:
          if g#news                                                                                                             then .                          else run write-log-and-file in p-log-handle (                                                                                    input 1                                                                                                             , input log-file-name                                                                                                 , input 1                                                                                                             , input substitute("!!!Продажу &1 нельзя удалить&2Документ внутреннего перемещения ЧУЖИХ ТОВАРОВ &3 (расходный) не удален:&2"                           ,parinkas-code                                                                                                        , chr(10)                                                                                                         ,tpsi_sale-doc.doc-code)).
          run read-write-log in this-procedure .
          undo _main, return error .
        end.
        else do:
          if g#news                                                                                                             then .                          else run write-log-and-file in p-log-handle (                                                                                    input 1                                                                                                             , input log-file-name                                                                                                 , input 1                                                                                                             , input substitute("&1 &2 &3&4!!!Ошибка при удалении документа &5&4&6&4&7"                           ,vss-workfile                                                                       ,vss-revision                                                                       ,vss-description                                                                    , chr(10)                                                                     , tpsi_sale-doc.doc-code                                                            , error-status:get-message(1)                                                       , return-value                                                                      )).
          undo _main, return error.
        end.
      end.
      delete tpsi_sale-doc.
    end.
    if (v-auto-fbr = yes
    or v-auto-fbr = ? )
    and not g#news
    then do:
define variable vss-include-info13 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_manufacturing_del-manuf-fact':U
    ,input  'object':U
    ,input  v-host-code
    ,input  v-obj-type
    ,input  v-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output v-can-del-fbr-doc
    ) no-error .
end.
      if error-status :error
      then do:
                if g#news                                                                                                             then .                          else run write-log-and-file in p-log-handle (                                                                                    input 1                                                                                                             , input log-file-name                                                                                                 , input 1                                                                                                             , input substitute("&1 &2 &3&4!!!Ошибка проверки права на удаление документа производства закрытого на факт"                                ,vss-workfile                                                                                                         ,vss-revision                                                                                                         ,vss-description                                                                                                      ,chr(10)                                                                                                        ,error-status:get-message(1)                                                                                          , return-value                                                                                                        )).
              run read-write-log in this-procedure .
          undo _main, return error .
      end.
      if v-can-del-fbr-doc = no
      then do:
          if g#news                                                                                                             then .                          else run write-log-and-file in p-log-handle (                                                                                    input 1                                                                                                             , input log-file-name                                                                                                 , input 1                                                                                                             , input "Нет права на удаление документа производства, закрытого на факт.").
        undo _main, return error .
      end.
      if g#news                                                                                                             then .                          else run write-log-and-file in p-log-handle (                                                                                    input 1                                                                                                             , input log-file-name                                                                                                 , input 1                                                                                                             , input substitute("Удаление порожденных документов производства по продаже &1", parinkas-code)).
      run str/fbrdel.p (
            input parparentproc
          , input parinkas-code
          , input varchip-code
      ) no-error .
      if error-status:error
      then do:
          if g#news                                                                                                             then .                          else run write-log-and-file in p-log-handle (                                                                                    input 1                                                                                                             , input log-file-name                                                                                                 , input 1                                                                                                             , input substitute("&1 &2 &3&4!!!Ошибка при удалении порожденных документов производства по продаже &5&4&6&4&7"                      ,vss-workfile                                                                                                             ,vss-revision                                                                                                             ,vss-description                                                                                                          , chr(10)                                                                                                           , parinkas-code                                                                                                           , error-status:get-message(1)                                                                                             , return-value                                                                                                            )).
        undo _main, return error.
      end.
    end.
  end.
 if g#news
 and g#db-num = 0
 and v-need-saledc
 then do:
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-del in g#trdcalib (  input parinkas-code ,
                        input 'need-saledc':U ,
                       output v-deleted ) no-error .
  end.
    if g#news                                                                                                             then .                          else run write-log-and-file in p-log-handle (                                                                                    input 1                                                                                                             , input log-file-name                                                                                                 , input 1                                                                                                             , input substitute("Документ продажи &1 удален", parinkas-code)).
end.
procedure hstc-inkas :
define input parameter parrec-inkas   as   recid                   no-undo.
define input parameter parobj-date    as   date                    no-undo.
define input parameter parshift-date  like ub.shift-obj.shift-date no-undo.
define input parameter parshift-num   like ub.shift-obj.shift-num  no-undo.
define input parameter parshift-name  like ub.shift-obj.shift-name  no-undo.
define input parameter paruserid      as   character               no-undo.
define output parameter parchip-code    like ub.c-trn-doc.chip-num   no-undo.
DEFINE VARIABLE v-date as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define buffer hstc_inkas          for ub.inkas.
define buffer hstc_inkas-pay      for ub.inkas-pay.
define buffer hstc_inkas-pay-desk for ub.inkas-pay-desk.
define buffer hstc_inkas-pay-wth  for ub.inkas-pay-wth.
define buffer hstc_sale-doc for ub.sale-doc.
define buffer hstc_c-inkas           for ub.c-inkas.
define buffer hstc_c-inkas-pay      for ub.c-inkas-pay.
define buffer hstc_c-inkas-pay-desk for ub.c-inkas-pay-desk.
define buffer hstc_c-inkas-pay-wth for ub.c-inkas-pay-wth.
define buffer hstc_c-sale-doc for ub.c-sale-doc.
do
on error undo, return error return-value
:
find first hstc_inkas where recid (hstc_inkas) = parrec-inkas.
run cur-time in this-procedure(output v-date, output v-time).
create hstc_c-inkas.
buffer-copy hstc_inkas to hstc_c-inkas.
assign
  parchip-code                 = next-value (s-corr-chip, ub)
  hstc_c-inkas.chip-num        = parchip-code
  hstc_c-inkas.CORR-TIME       = v-time
  hstc_c-inkas.real-corr-date  = v-date
  hstc_c-inkas.corr-date       = parobj-date
  hstc_c-inkas.corr-shift-date = parshift-date
  hstc_c-inkas.corr-shift-num  = parshift-num
  hstc_c-inkas.corr-shift-name  = parshift-name
  hstc_c-inkas.corr-user-name        = paruserid
  hstc_c-inkas.corr-user-db-num   = g#db-num
  .
for each hstc_inkas-pay where
         hstc_inkas-pay.inkas-code = hstc_inkas.inkas-code
on error undo, return error
:
  create hstc_c-inkas-pay.
  buffer-copy hstc_inkas-pay to hstc_c-inkas-pay.
  assign
    hstc_c-inkas-pay.chip-num = hstc_c-inkas.chip-num
    hstc_c-inkas-pay.corr-user-db-num = hstc_c-inkas.corr-user-db-num.
end.
for each hstc_inkas-pay-desk where
         hstc_inkas-pay-desk.inkas-code = hstc_inkas.inkas-code
on error undo, return error
         :
  create hstc_c-inkas-pay-desk.
  buffer-copy hstc_inkas-pay-desk to hstc_c-inkas-pay-desk.
  assign
    hstc_c-inkas-pay-desk.chip-num = hstc_c-inkas.chip-num
    hstc_c-inkas-pay-desk.corr-user-db-num = hstc_c-inkas.corr-user-db-num
    .
end.
for each hstc_inkas-pay-wth where
         hstc_inkas-pay-wth.inkas-code = hstc_inkas.inkas-code
on error undo, return error
         :
  create hstc_c-inkas-pay-wth.
  buffer-copy hstc_inkas-pay-wth to hstc_c-inkas-pay-wth.
  assign
    hstc_c-inkas-pay-wth.chip-num = hstc_c-inkas.chip-num
    hstc_c-inkas-pay-wth.corr-user-db-num = hstc_c-inkas.corr-user-db-num
    .
end.
for each hstc_sale-doc where
         hstc_sale-doc.inkas-code = hstc_inkas.inkas-code
on error undo, return error
:
  create hstc_c-sale-doc.
  buffer-copy hstc_sale-doc to hstc_c-sale-doc.
  assign
  hstc_c-sale-doc.chip-num = hstc_c-inkas.chip-num
  hstc_c-sale-doc.corr-user-db-num = hstc_c-inkas.corr-user-db-num
  hstc_c-inkas.corr-date       = parobj-date
  hstc_c-inkas.corr-shift-date = parshift-date
  hstc_c-inkas.corr-shift-num  = parshift-num
  hstc_c-inkas.corr-shift-name  = parshift-name
  .
end.
end.
end procedure.
procedure read-write-log :
define variable ss as character no-undo .
  do
  on error undo, return error
  :
    if not g#news
    then do:
      input stream LogStream from value("del-doc.err").
      REPEAT:
        import stream LogStream  unformatted ss.
          if g#news                                                                                                             then .                          else run write-log-and-file in p-log-handle (                                                                                    input 1                                                                                                             , input log-file-name                                                                                                 , input 1                                                                                                             , input ss).
      END.
      input stream LogStream close.
    end.
  end.
end procedure.
