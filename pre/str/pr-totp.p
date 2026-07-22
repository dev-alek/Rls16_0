block-level on error undo, throw.
define input parameter d-num like ub.price-doc.doc-num.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: pr-totp.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/pr-totp.p $":U .
define variable vss-description as character no-undo init "Расчет сумм по документу переоценки".
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
procedure create-price-list-attr :
 do
 on error undo, return error return-value
 :
define input parameter p-attr-code    like ub.price-list-attr.attr-code  no-undo .
define input parameter p-attr-value   like ub.price-list-attr.attr-value no-undo .
define input parameter p-b-code       like ub.price-list-attr.b-code     no-undo .
define input parameter p-doc-num      like ub.price-list-attr.doc-num    no-undo .
define input parameter p-price-type   like ub.price-list-attr.price-type no-undo .
define buffer buf_price-list-attr for ub.price-list-attr.
find first buf_price-list-attr  exclusive-lock  where
  buf_price-list-attr.attr-code    = p-attr-code    and
  buf_price-list-attr.b-code       = p-b-code       and
  buf_price-list-attr.doc-num      = p-doc-num      and
  buf_price-list-attr.price-type   = p-price-type  no-error .
  if not available  buf_price-list-attr then do:
      create buf_price-list-attr.
      assign
        buf_price-list-attr.attr-code    = p-attr-code
        buf_price-list-attr.attr-value   = p-attr-value
        buf_price-list-attr.b-code       = p-b-code
        buf_price-list-attr.doc-num      = p-doc-num
        buf_price-list-attr.price-type   = p-price-type
      .
  end.
  else do:
        buf_price-list-attr.attr-value   = p-attr-value .
  end.
 end.
end procedure.
procedure view-price-list-attr :
 do
 on error undo, return error return-value
 :
define input  parameter p-attr-code    like ub.price-list-attr.attr-code  no-undo .
define input  parameter p-b-code       like ub.price-list-attr.b-code     no-undo .
define input  parameter p-doc-num      like ub.price-list-attr.doc-num    no-undo .
define input  parameter p-price-type   like ub.price-list-attr.price-type no-undo .
define output parameter p-attr-value   like ub.price-list-attr.attr-value no-undo .
define buffer buf_price-list-attr for ub.price-list-attr.
find first buf_price-list-attr no-lock where
  buf_price-list-attr.attr-code    = p-attr-code    and
  buf_price-list-attr.b-code       = p-b-code       and
  buf_price-list-attr.doc-num      = p-doc-num      and
  buf_price-list-attr.price-type   = p-price-type  no-error .
  if available  buf_price-list-attr then do:
      assign
        p-attr-value = buf_price-list-attr.attr-value
      .
  end.
  else do:
        p-attr-value = ? .
  end.
 end.
end procedure.
procedure pdoc-forming-attr :
define input  parameter p-plt-id       as integer   no-undo .
define input  parameter p-plt-db-num   as integer   no-undo .
define input  parameter p-pdf-id       as integer   no-undo .
define input  parameter p-pdf-db       as integer   no-undo .
define input  parameter p-attr-code    as character no-undo .
define input  parameter p-val          as character no-undo .
  do
  on error undo, return error return-value
  :
  find first  ub.price-doc-forming-attr exclusive-lock where
              ub.price-doc-forming-attr.plt-id       = p-plt-id       and
              ub.price-doc-forming-attr.plt-db-num   = p-plt-db-num   and
              ub.price-doc-forming-attr.pdf-id       = p-pdf-id       and
              ub.price-doc-forming-attr.pdf-db       = p-pdf-db       and
              ub.price-doc-forming-attr.attr-code    = p-attr-code
              no-error .
    if not available  ub.price-doc-forming-attr then create ub.price-doc-forming-attr.
    assign
      ub.price-doc-forming-attr.plt-id       = p-plt-id
      ub.price-doc-forming-attr.plt-db-num   = p-plt-db-num
      ub.price-doc-forming-attr.pdf-id       = p-pdf-id
      ub.price-doc-forming-attr.pdf-db       = p-pdf-db
      ub.price-doc-forming-attr.attr-code    = p-attr-code
      ub.price-doc-forming-attr.attr-value   = p-val
    .
  end.
end procedure.
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
define buffer  sub-list for ub.price-list.
define buffer  sub-code for ub.bar-code.
define buffer  buf_price-list for ub.price-list.
define buffer  buf_bar-code for  ub.bar-code.
define buffer  buf_goods for ub.goods.
define buffer  buf_gds-obj for ub.gds-obj.
define buffer  Buf_prt-obj for ub.prt-obj.
define variable var-pr-r-b as character no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output var-pr-r-b
  )  .
define variable v-price-list-total             as integer no-undo .
define variable v-avrg-r-b                     as decimal no-undo .
define variable v-last-r-b                     as decimal no-undo .
define variable v-doc-qnty                     as decimal no-undo .
define variable v-price-sale                   as decimal no-undo .
define variable v-rest-sale                    as decimal no-undo .
define buffer Buf_parts-free for ub.parts  .
define variable v-cur-dn as character no-undo .
define variable v-parts-price-sale  as decimal   no-undo .
define variable v-cur-rt  as decimal   no-undo .
define variable v-cur-ex as decimal   no-undo .
  v-price-list-total       = 0.
  run waitfram-show in this-procedure  ("Расчет строк по документу переоценки. Ждите ...").
  find price-doc exclusive-lock where
       price-doc.doc-num = d-num.
  chk-prices :
  for each  Buf_price-list where
            Buf_price-list.doc-num = d-num,
      first Buf_bar-code no-lock where
            Buf_bar-code.b-code = Buf_price-list.b-code,
      first Buf_goods no-lock where
            Buf_goods.gds-code = Buf_bar-code.gds-code
      on error undo chk-prices, return error:
    if Buf_price-list.price-sale <= 0 or
       Buf_price-list.price-sale = ? then do:
      message
        "Цена не должна быть меньше или равна 0, или равна ?." skip
        "Артикул: " Buf_goods.artic Buf_goods.gds-name
        view-as alert-box error.
      run waitfram-hide in this-procedure .
      undo chk-prices, return error.
    end.
      run create-price-list-attr in this-procedure
      ( "full-price-sale":U ,
        Buf_price-list.price-sale    ,
        Buf_price-list.b-code ,
        Buf_price-list.doc-num ,
        Buf_price-list.price-type  ).
    if Buf_goods.unit-base = Buf_bar-code.unit-cli then
      Buf_price-list.doc-qnty = 0.
      v-price-list-total = v-price-list-total + 1.
  end.
  if price-doc.status_ = 'новый':U and
     substr ( price-doc.PS, 1, 1 ) = "@" then
    price-doc.PS = "@  Строк в приказе: " + string ( v-price-list-total, ">>>>>9").
  assign
    v-price-list-total       = 0
    v-avrg-r-b               = 0
    v-last-r-b               = 0
    v-doc-qnty               = 0
    v-price-sale             = 0
    v-rest-sale              = 0
    .
  run waitfram-show in this-procedure ("Расчет итогов по документу переоценки. Ждите ...") .
  clc-tot :
  for each  Buf_price-list where
            Buf_price-list.doc-num = d-num and
            Buf_price-list.main-price = yes,
      first Buf_bar-code no-lock where
            Buf_bar-code.b-code = Buf_price-list.b-code,
      first Buf_gds-obj where
            Buf_gds-obj.gds-code = Buf_bar-code.gds-code and
            Buf_gds-obj.obj-type = Buf_price-list.obj-type and
            Buf_gds-obj.obj-code = Buf_price-list.obj-code,
      first Buf_goods no-lock where
            Buf_goods.gds-code = Buf_bar-code.gds-code
      on error undo clc-tot, return error
      :
        v-price-list-total = v-price-list-total + 1.
        if v-price-list-total modulo 100 = 0 then
          run waitfram-show in this-procedure ("Расчет итогов. Главных цен: " +
                          string (v-price-list-total)).
        Buf_price-list.doc-qnty = Buf_gds-obj.fact-qnty.
        for each  sub-list where
                  sub-list.doc-num    = d-num and
                  sub-list.main-price = no and
                  sub-list.artic      = Buf_price-list.artic and
                  sub-list.prod-type  = Buf_price-list.prod-type and
                  sub-list.prod-code  = Buf_price-list.prod-code,
            each  sub-code no-lock where
                  sub-code.b-code = sub-list.b-code,
            each  Buf_parts-free no-lock where
                  Buf_parts-free.artic     = Buf_price-list.artic and
                  Buf_parts-free.prod-type = Buf_price-list.prod-type and
                  Buf_parts-free.prod-code = Buf_price-list.prod-code and
                  Buf_parts-free.part-code = sub-code.part-code and
                  Buf_parts-free.in-code   = sub-code.in-code and
                  Buf_parts-free.out-code  = 'free-zone':U and
                  Buf_parts-free.obj-type  = Buf_price-list.obj-type and
                  Buf_parts-free.obj-code  = Buf_price-list.obj-code
        on error undo clc-tot, return error
        on stop undo clc-tot, return error:
          if sub-code.unit-cli <> Buf_goods.unit-base then
            next.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  Buf_price-list.obj-type
  ,input  Buf_price-list.obj-code
  ,input  sub-code.b-code
  ,input  0
  ,input  0
  ,output v-cur-dn
  ,output v-parts-price-sale
  ,output v-cur-rt
  ,output v-cur-ex
  ) no-error .
              if error-status :error then .
              if v-parts-price-sale = ? then v-parts-price-sale = 0 .
          assign
            sub-list.doc-qnty = Buf_parts-free.fact-qnty
            Buf_price-list.doc-qnty = Buf_price-list.doc-qnty - sub-list.doc-qnty
            v-price-sale = v-price-sale
                        + ( sub-list.price-sale - v-parts-price-sale) * sub-list.doc-qnty
            .
        end.
    assign
      v-avrg-r-b   = v-avrg-r-b
                   +  ( if var-pr-r-b = "rubl" then Buf_gds-obj.fact-rubl else Buf_gds-obj.fact-base )
      v-doc-qnty   = v-doc-qnty
                   + Buf_gds-obj.fact-qnty
      v-price-sale = v-price-sale
                   + ( buf_price-list.price-sale - Buf_gds-obj.price-sale) * Buf_price-list.doc-qnty
      v-rest-sale  = v-rest-sale
                   + Buf_gds-obj.fact-sale
      .
    if Buf_goods.gds-type = 'т':U then
       if var-pr-r-b = "rubl" then
           v-last-r-b   = v-last-r-b
                        + Buf_gds-obj.last-rubl * Buf_gds-obj.fact-qnty.
          else
           v-last-r-b   = v-last-r-b
                        + Buf_gds-obj.last-base * Buf_gds-obj.fact-qnty.
  end.
  assign
    price-doc.rest-last     = v-last-r-b
    price-doc.rest-base     = v-avrg-r-b
    price-doc.rest-sale     = v-rest-sale
    price-doc.sale-base     = v-price-sale
    price-doc.rest-qnty     = v-doc-qnty
    .
  release price-doc.
  run waitfram-hide in this-procedure .
