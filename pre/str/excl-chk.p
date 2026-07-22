block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-curr-r-b as character no-undo .
define parameter buffer X_chk-doc for ub.chk-doc.
define variable vss-revision    as character no-undo init "$Revision: 18022dc3b171, 1949, rls $":U .
define variable vss-author      as character no-undo init "$Author: SSlivenko $":U .
define variable vss-date        as character no-undo init "$Date: Fri Jul 26 11:38:58 2019 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: excl-chk.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/excl-chk.p $":U .
define variable vss-description as character no-undo init "Исключение чека из незакрытой продажи".
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
FUNCTION calc-excise RETURNS DECIMAL(input  parprice-sale as decimal,
                                     input  parroad-tax   as decimal,
                                     input  parvat-pc     as decimal,
                                     input  parfactorrd   as decimal,
                                     output parexcise     as decimal):
ASSIGN parexcise = (parprice-sale - parroad-tax) * parvat-pc / (100 + parvat-pc) -
                   1 / parfactorrd * parroad-tax.
RETURN parexcise.
END FUNCTION.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure findtank:
  define input  parameter p-obj-type     as character no-undo.
  define input  parameter p-obj-code     as integer   no-undo.
  define input  parameter p-pump-code    as integer   no-undo.
  define input  parameter p-nozzle-code  as integer   no-undo .
  define input  parameter p-from-pl-code as integer   no-undo .
  define input  parameter p-gds-code     as integer   no-undo.
  define output parameter p-pl-code      as integer   no-undo .
  define variable v-pl-code            like ub.place.pl-code no-undo .
  define variable v-dopstr             as character no-undo .
  define buffer buf_place for ub.place.
  define buffer buf_pl-gds-pump for ub.pl-gds-pump.
  define buffer buf_pl-pump-nozzle for ub.pl-pump-nozzle.
  define buffer buf_pl-gds for ub.pl-gds.
  do
  on error undo, return error return-value
  :
    assign
      v-pl-code = 0
      p-pl-code = ?
    .
    if p-from-pl-code <> ?
      and p-from-pl-code <> 0
    then do:
      find first buf_pl-gds no-lock
        where buf_pl-gds.obj-type  = p-obj-type
          and buf_pl-gds.obj-code  = p-obj-code
          and buf_pl-gds.pl-code   = p-from-pl-code
          and buf_pl-gds.gds-code  = p-gds-code
        no-error.
      if available buf_pl-gds then do:
        assign
          v-pl-code = buf_pl-gds.pl-code
        .
      end.
    end.
    if v-pl-code <> 0
      and p-nozzle-code <> ?
      and p-nozzle-code <> 0
    then do:
      find first buf_pl-pump-nozzle no-lock
        where buf_pl-pump-nozzle.obj-type    = p-obj-type
          and buf_pl-pump-nozzle.obj-code    = p-obj-code
          and buf_pl-pump-nozzle.pl-code     = v-pl-code
          and buf_pl-pump-nozzle.pump-code   = p-pump-code
          and buf_pl-pump-nozzle.nozzle-code = p-nozzle-code
        no-error .
      if not available buf_pl-pump-nozzle then do:
        return.
      end.
    end.
    if v-pl-code = 0 then do:
      if p-nozzle-code = 0 then do:
        find first buf_pl-gds-pump no-lock
          where buf_pl-gds-pump.obj-type  = p-obj-type
            and buf_pl-gds-pump.obj-code  = p-obj-code
            and buf_pl-gds-pump.pump-code = p-pump-code
            and buf_pl-gds-pump.gds-code  = p-gds-code
            and buf_pl-gds-pump.status_   = 'тек':U
          no-error.
        if available buf_pl-gds-pump then do:
          assign
            v-pl-code = buf_pl-gds-pump.pl-code
          .
        end.
      end.
      else do:
        _ppnz:
        for each buf_pl-pump-nozzle no-lock
          where buf_pl-pump-nozzle.obj-type = p-obj-type
            and buf_pl-pump-nozzle.obj-code = p-obj-code
            and buf_pl-pump-nozzle.pump-code = p-pump-code
            and buf_pl-pump-nozzle.nozzle-code = p-nozzle-code
          ,first buf_pl-gds-pump no-lock
          where buf_pl-gds-pump.obj-type  = p-obj-type
            and buf_pl-gds-pump.obj-code  = p-obj-code
            and buf_pl-gds-pump.pump-code = p-pump-code
            and buf_pl-gds-pump.gds-code  = p-gds-code
            and buf_pl-gds-pump.status_   = 'тек':U
            and buf_pl-gds-pump.pl-code   = buf_pl-pump-nozzle.pl-code
        on error undo, return error return-value
        :
          assign
            v-pl-code = buf_pl-pump-nozzle.pl-code
          .
          leave _ppnz.
        end.
      end.
    end.
    if v-pl-code <> 0 then do:
      assign
        p-pl-code = v-pl-code
      .
    end.
  end.
end procedure.
procedure find-nzl:
define input  parameter p-obj-type   as character no-undo.
define input  parameter p-obj-code   as integer   no-undo.
define input  parameter p-pump-code  as integer   no-undo.
define input  parameter p-gds-code   as integer   no-undo.
define input  parameter p-pl-code    as integer no-undo .
define output parameter p-nozzle-code    as integer   no-undo.
define variable v-nozzle-code        like ub.nozzle.nozzle-code no-undo .
define variable v-pl-code            like ub.place.pl-code no-undo .
define variable v-pump-code          like ub.pump.pump-code no-undo .
define variable v-loc1-code          like ub.place.loc1 no-undo .
define variable v-dopstr             as character no-undo .
define buffer buf_place for ub.place.
define buffer buf_pl-gds-pump for ub.pl-gds-pump.
define buffer buf_pl-pump-nozzle for ub.pl-pump-nozzle.
define buffer buf_pl-gds for ub.pl-gds.
do on error undo, return error return-value :
  v-pump-code = p-pump-code.
  find first buf_pl-pump-nozzle no-lock where
                buf_pl-pump-nozzle.obj-type = p-obj-type
            and buf_pl-pump-nozzle.obj-code = p-obj-code
            and buf_pl-pump-nozzle.pump-code = p-pump-code
            and buf_pl-pump-nozzle.pl-code = p-pl-code no-error.
  if not available buf_pl-pump-nozzle then do:
    assign
    p-nozzle-code = ?.
    return .
  end.
  assign
  p-nozzle-code = buf_pl-pump-nozzle.nozzle-code.
  return.
  .
end.
end procedure.
procedure find-nzl-without-pl:
define input  parameter p-obj-type   as character no-undo.
define input  parameter p-obj-code   as integer   no-undo.
define input  parameter p-pump-code  as integer   no-undo.
define input  parameter p-gds-code   as integer   no-undo.
define output parameter p-nozzle-code    as integer   no-undo.
define buffer buf_pl-gds-pump for ub.pl-gds-pump.
define buffer buf_pl-gds for ub.pl-gds.
define buffer buf_pl-pump-nozzle for ub.pl-pump-nozzle.
do on error undo, return error return-value :
  for each buf_pl-gds-pump no-lock where
            buf_pl-gds-pump.obj-type  = p-obj-type
        and buf_pl-gds-pump.obj-code  = p-obj-code
        and buf_pl-gds-pump.pump-code = p-pump-code
        and buf_pl-gds-pump.gds-code  = p-gds-code
        and buf_pl-gds-pump.status_   = 'тек':U,
      first buf_pl-gds no-lock where
                buf_pl-gds.obj-type = p-obj-type
            AND buf_pl-gds.obj-code = p-obj-code
            AND buf_pl-gds.pl-code = buf_pl-gds-pump.pl-code
            AND buf_pl-gds.gds-code = p-gds-code
            AND buf_pl-gds.status_ = 'тек':U,
     first buf_pl-pump-nozzle no-lock where
              buf_pl-pump-nozzle.obj-type = p-obj-type
          and buf_pl-pump-nozzle.obj-code = p-obj-code
          and buf_pl-pump-nozzle.pl-code = buf_pl-gds.pl-code
          and buf_pl-pump-nozzle.pump-code = p-pump-code:
    assign
    p-nozzle-code = buf_pl-pump-nozzle.nozzle-code.
    return .
  end.
  assign
  p-nozzle-code = ?.
  return.
  .
end.
end procedure.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def var cr as integer no-undo.
DEFINE  TEMP-TABLE t-gds No-UNDO
FIELD b-code like ub.chk-gds.b-code
FIELD gds-code like ub.goods.gds-code
FIELD artic like ub.goods.artic
FIELD prod-type like ub.goods.prod-type
FIELD prod-code like ub.goods.prod-code
FIELD doc-qnty like ub.chk-gds.doc-qnty
FIELD price-base like ub.chk-gds.price-base
FIELD price-sum like ub.chk-gds.price-base
FIELD discnt like ub.chk-gds.discnt
FIELD discnt-sum like ub.chk-gds.discnt
FIELD price-service like ub.chk-gds.price-service
FIELD road-tax like ub.chk-gds.road-tax
FIELD road-sum like ub.chk-gds.road-tax
FIELD new-price like ub.chk-gds.price-base
FIELD cashparts as logical
FIELD cashplace as logical
FIELD pl-code like ub.doc-pl.pl-code
field density as decimal
FIELD rdoc-line as recid
FIELD rgds-dtl as recid
FIELD unit-base like ub.goods.unit-base
FIELD node-code like ub.bar-code.node-code
FIELD num-lines as integer
FIELD pump like ub.chk-gds.pump
FIELD fbr-obj-type like ub.clients.obj-type
FIELD fbr-obj-code like ub.clients.obj-code
FIELD type like ub.units.type
FIELD grc as recid
FIELD is-modificator as logical
FIELD is-null-price as logical
FIELD doc-code like ub.trn-doc.doc-code
FIELD marks as character
index pi is PRIMARY doc-code gds-code b-code artic prod-type prod-code node-code pl-code pump grc
index ifbr b-code fbr-obj-type fbr-obj-code
.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table lib-trn_ret-doc       no-undo like ub.trn-doc.
define temp-table lib-trn_ret-line      no-undo like ub.doc-line
  field cst-code                like ub.trn-doc.cst-code
  field part-code               like ub.parts.part-code
  .
define temp-table lib-trn_ret-line-attr no-undo like ub.doc-line-attr.
define temp-table lib-trn_ret-dtl       no-undo like ub.gds-dtl.
define temp-table lib-trn_ret-parts     no-undo like ub.parts.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#trdcalib as handle no-undo.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define shared temp-table tt0-info no-undo
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
define shared temp-table tt0-doc-line no-undo like lib-trn_ret-line.
define shared temp-table tt0-gds-dtl  no-undo like ub.gds-dtl.
define shared temp-table tt0-parts    no-undo like ub.parts.
define shared temp-table temp-tpsi-clients  no-undo like ub.clients.
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
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION set-sale-doc-PS returns character( buffer buf_sale-doc for ub.sale-doc):
define variable v-ps as character no-undo .
if available buf_sale-doc then
assign
v-PS = substitute('&1&2 &1&3&1Кол-во_чеков &4&1строк_чеков &5&1товаров &6&1признаков &7&1'
                    , chr(4)
                    , (if buf_sale-doc.chr-office = 'у':U then "УСЛУГИ." else "ТОВАРЫ." )
                    , entry (lookup (buf_sale-doc.doc-kind, 'es,rs,rwo,trf,swo,ngs,rgs,vir':U + ',' + 'itr':U) + 1, ',' + 'касса продажа,касса возврат,Списание-по-Возврату,ТехПролив,Списание,Приход-Природный-Газ,Возврат-Природный-Газ,Перемещение-Вирт-Рез':U + ',' + 'ПриТехПрол':U )
                    , buf_sale-doc.chk-amount
                    , buf_sale-doc.gds-amount
                    , buf_sale-doc.tot-lines
                    , buf_sale-doc.tot-dtl
                    ).
else  do:
assign
v-PS = substitute('&1&2 &1&3&1Кол-во_чеков &4&1строк_чеков &5&1товаров &6&1признаков &7&1'
                    , chr(4)
                    , '':U
                    , entry (lookup ('es':U, 'es,rs,rwo,trf,swo,ngs,rgs,vir':U + ',' + 'itr':U) + 1, ',' + 'касса продажа,касса возврат,Списание-по-Возврату,ТехПролив,Списание,Приход-Природный-Газ,Возврат-Природный-Газ,Перемещение-Вирт-Рез':U + ',' + 'ПриТехПрол':U )
                    , 0
                    , 0
                    , 0
                    , 0
                    ).
end.
return v-ps.
END FUNCTION.
FUNCTION get-sale-doc-kind returns character (
                                             input p-doc-kind as character
                                           , input p-ext-doc-type as character
                                           , output p-order as integer
                                           , output p-msign as integer
                                           , output p-main as logical
                                           , output p-in-inkas as logical
                                           , output p-dir_ as integer
                                           ):
define variable v-doc-kind as character no-undo.
define variable v-type as character no-undo .
define variable v-value as character no-undo .
CASE p-doc-kind:
  when 'es':U then do:
    assign
    p-order = 100
    p-msign = 1
    p-main = yes
    p-in-inkas = yes
    p-dir_ = 1
    .
    return p-ext-doc-type.
  end.
  when  'rs':U then do:
    assign
    p-order = 200
    p-msign = - 1
    p-main = no
    p-in-inkas = yes
    p-dir_ = - 1
    .
    return p-ext-doc-type.
  end.
  when 'rwo':U then do:
    assign
    p-msign = - 1
    p-main = no
    p-in-inkas = no
    p-order = 300
    p-dir_ = 1
    .
    return 'rwo':U.
  end.
  when 'trf':U then do:
    assign
    p-msign = 1
    p-main = no
    p-in-inkas = no
    p-order = 400
    p-dir_ = 1
    .
    return 'trf':U.
  end.
  when 'swo':U then do:
   assign
   p-msign = 1
   p-main = no
   p-in-inkas = no
   p-order =  500
   p-dir_ = 1
   .
   return 'swo':U.
 end.
 when 'vir':U then do:
   assign
   p-msign = 1
   p-main = no
   p-in-inkas = no
   p-order = 600
   p-dir_ = 1
   .
   return 'vir':U.
 end.
 when 'itr':U then do:
   assign
   p-msign = 1
   p-main = no
   p-in-inkas = no
   p-order = -1
   p-dir_ = -1
   .
  return 'itr':U.
 end.
 when 'ngs':U then do:
   assign
   p-msign = 1
   p-main = no
   p-in-inkas = no
   p-order = 700
   p-dir_ = 1
   .
   return 'ngs':U.
 end.
 when 'rgs':U then do:
   assign
   p-msign = -1
   p-main = no
   p-in-inkas = no
   p-order = 701
   p-dir_ = -1
   .
   return 'rgs':U.
 end.
 otherwise do:
    assign
    p-msign = 1
    p-main = no
    p-in-inkas = no
    p-order = -1.
    return p-ext-doc-type.
  end.
END CASE.
END FUNCTION.
procedure saledoc-create :
define input parameter p-inkas-code like ub.inkas.inkas-code no-undo .
define input parameter p-host-code like ub.sysconf.host-code no-undo .
define input parameter p-obj-type  like ub.clients.obj-type no-undo .
define input parameter p-obj-code  like ub.clients.obj-code no-undo .
define input parameter p-doc-kind as character no-undo .
define input parameter p-office as character no-undo .
define input parameter p-tpsidoc as logical no-undo .
define input parameter p-alias-type-price as character no-undo .
define input parameter p-price-obj-type as character no-undo .
define input parameter p-price-obj-code as integer no-undo .
define parameter buffer buf_trn-doc for ub.trn-doc.
define variable v-order as integer no-undo.
define variable v-main as logical no-undo .
define variable v-in-inkas as logical no-undo .
define variable v-msign as integer no-undo .
define variable v-dir_ as integer no-undo .
define variable v-trn-doc-code as character no-undo .
define buffer buf_sale-doc for ub.sale-doc.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
   if available buf_trn-doc then do:
     v-trn-doc-code = buf_trn-doc.doc-code.
   end.
   find first buf_sale-doc where
            buf_sale-doc.inkas-code = p-inkas-code
        and buf_sale-doc.doc-kind = p-doc-kind
        and buf_sale-doc.chr-office = p-office
        and (v-trn-doc-code = '' or buf_sale-doc.doc-code = v-trn-doc-code)
        no-error .
   if not available buf_sale-doc  then do:
      create buf_sale-doc.
      assign
      buf_sale-doc.inkas-code = p-inkas-code
      buf_sale-doc.storage =  'trn-doc':U
      buf_sale-doc.host-code = p-host-code
      buf_sale-doc.obj-type = p-obj-type
      buf_sale-doc.obj-code = p-obj-code
      buf_sale-doc.doc-kind  = p-doc-kind
      buf_sale-doc.order = lookup(p-doc-kind, 'es,rs,rwo,trf,swo,ngs,rgs,vir':U) * 100 + (if p-office = 'у':U then 5 else 0)
      buf_sale-doc.chr-office = p-office
      buf_sale-doc.doc-code = v-trn-doc-code
      .
   end.
   if available buf_trn-doc then
   buffer-copy buf_trn-doc
   to buf_sale-doc
   .
  assign
  buf_sale-doc.doc-kind = get-sale-doc-kind (
                                             input p-doc-kind
                                            ,input buf_sale-doc.ext-doc-type
                                            ,output v-order
                                            ,output v-msign
                                            ,output v-main
                                            ,output v-in-inkas
                                            ,output v-dir_).
  assign
  buf_sale-doc.order = v-order + (if p-office = 'у':U then 5 else 0)
  buf_sale-doc.main-doc = v-main
  buf_sale-doc.in-inkas = v-in-inkas
  buf_sale-doc.msign = v-msign
  buf_sale-doc.dir = v-dir_
  buf_sale-doc.fbrsale = lookup(buf_sale-doc.doc-kind, 'es,swo':U) > 0
  buf_sale-doc.main-receipt-type = integer(entry (lookup (buf_sale-doc.doc-kind, 'es,rs,rwo,trf,swo,ngs,rgs,vir':U) + 1, '0,1,6,96,17,69,17,17':U))
  buf_sale-doc.poss-wro-codes = '':U
  buf_sale-doc.chr-office = p-office
  buf_sale-doc.tpsidoc = p-tpsidoc
  buf_sale-doc.alias-type-price = p-alias-type-price
  buf_sale-doc.price-obj-type = (if p-tpsidoc
                                 then p-price-obj-type
                                 else '':U)
  buf_sale-doc.price-obj-code = (if p-tpsidoc
                                 then p-price-obj-code
                                 else 0)
  .
  assign
  buf_sale-doc.poss-wro-codes = (if (v-order > 0 and buf_sale-doc.doc-kind <> 'vir':U) then entry (lookup (buf_sale-doc.doc-kind, 'es,rs,rwo,trf,swo,ngs,rgs,vir':U) + 1, '0,2,-2,-6;-3;-9;-4,17,1;3':U) else '':U)
  no-error.
end.
END.
procedure fbr-saledoc-create :
define input parameter p-inkas-code as character no-undo .
define variable v-pri-prvo-doc-qnty like ub.trn-doc.doc-qnty no-undo .
define variable v-pri-prvo-fact-qnty like ub.trn-doc.doc-qnty no-undo .
define variable v-pri-prvo-tot-lines like ub.trn-doc.tot-lines no-undo .
define buffer buf_fbr-doc for ub.fbr-doc.
define buffer buf_trn-doc for ub.trn-doc.
define buffer buf_sale-doc for ub.sale-doc.
define buffer buf2_sale-doc for ub.sale-doc.
define buffer buf2_trn-doc for ub.trn-doc.
define buffer buf_doc-line for ub.doc-line.
define buffer buf_gds-dtl for ub.gds-dtl.
define buffer buf_chk-gds for ub.chk-gds.
define buffer buf_chk-doc for ub.chk-doc.
do
on error undo, return error
:
  for each buf_fbr-doc no-lock where
        buf_fbr-doc.out-code = p-inkas-code:
    for each buf_trn-doc no-lock where
          buf_trn-doc.out-code = buf_fbr-doc.doc-code
    by buf_trn-doc.fact-order
    on error undo, return error:
      if buf_trn-doc.ext-doc-type = 'em':U
      or buf_trn-doc.ext-doc-type = 'im':U
      or buf_trn-doc.ext-doc-type = 'wm':U
      or buf_trn-doc.ext-doc-type = 'ev':U
      or buf_trn-doc.ext-doc-type = 'iv':U
      then do:
        find first buf_sale-doc where
                buf_sale-doc.inkas-code = p-inkas-code
            and buf_sale-doc.doc-code = buf_trn-doc.doc-code
            AND buf_sale-doc.storage  = 'trn-doc':U
                no-error .
        if not available buf_sale-doc then do:
        create buf_sale-doc.                                                                                             buffer-copy buf_trn-doc                                                                                             to buf_sale-doc.                                                                                                assign                                                                                                                  buf_sale-doc.storage  =  'trn-doc':U                                                                          buf_sale-doc.doc-kind = buf_trn-doc.ext-doc-type                                                                buf_sale-doc.order =  - 1                                                                                          buf_sale-doc.main-doc = no                                                                                             buf_sale-doc.in-inkas = no                                                                                         buf_sale-doc.fbrsale = yes                                                                                         buf_sale-doc.msign = 1                                                                                             buf_sale-doc.filled   = buf_sale-doc.fact-qnty <> 0 or buf_sale-doc.tot-lines <> 0                       buf_sale-doc.doc-qnty = (if buf_sale-doc.ext-doc-type = 'pc':U                                                           then ?                                                                                                                  else buf_sale-doc.doc-qnty)                                                          buf_sale-doc.fact-qnty = (if buf_sale-doc.ext-doc-type = 'pc':U                                                          then ?                                                                                                                  else buf_sale-doc.fact-qnty)                                                        buf_sale-doc.inkas-code = p-inkas-code.
        end.
        if buf_trn-doc.ext-doc-type = 'im':U then do:
          assign
          v-pri-prvo-doc-qnty = buf_trn-doc.doc-qnty
          v-pri-prvo-fact-qnty = buf_trn-doc.fact-qnty
          v-pri-prvo-tot-lines = buf_trn-doc.tot-lines
          .
        end.
        for each buf2_trn-doc no-lock where
                buf2_trn-doc.out-code = buf_sale-doc.doc-code:
          find first buf2_sale-doc where
                  buf2_sale-doc.inkas-code = p-inkas-code
              and buf2_sale-doc.doc-code = buf2_trn-doc.doc-code
              AND buf2_sale-doc.storage = 'trn-doc':U no-error .
          if not available buf2_sale-doc then do:
            create buf2_sale-doc.                                                                                             buffer-copy buf2_trn-doc                                                                                             to buf2_sale-doc.                                                                                                assign                                                                                                                  buf2_sale-doc.storage  =  'trn-doc':U                                                                          buf2_sale-doc.doc-kind = buf2_trn-doc.ext-doc-type                                                                buf2_sale-doc.order =  - 1                                                                                          buf2_sale-doc.main-doc = no                                                                                             buf2_sale-doc.in-inkas = no                                                                                         buf2_sale-doc.fbrsale = yes                                                                                         buf2_sale-doc.msign = 1                                                                                             buf2_sale-doc.filled   = buf2_sale-doc.fact-qnty <> 0 or buf2_sale-doc.tot-lines <> 0                       buf2_sale-doc.doc-qnty = (if buf2_sale-doc.ext-doc-type = 'pc':U                                                           then ?                                                                                                                  else buf2_sale-doc.doc-qnty)                                                          buf2_sale-doc.fact-qnty = (if buf2_sale-doc.ext-doc-type = 'pc':U                                                          then ?                                                                                                                  else buf2_sale-doc.fact-qnty)                                                        buf2_sale-doc.inkas-code = p-inkas-code.
          end.
        end.
      end.
    end.
    find first buf_sale-doc where
              buf_sale-doc.inkas-code = p-inkas-code
          AND buf_sale-doc.storage = 'fbr-doc':U
          AND buf_sale-doc.doc-code = buf_fbr-doc.doc-code no-error .
    if not available buf_sale-doc then do:
      create buf_sale-doc.
      assign
      buf_sale-doc.storage       =  'fbr-doc':U
      buf_sale-doc.doc-type      = 'производство':U
      buf_sale-doc.doc-code      = buf_fbr-doc.doc-code
      buf_sale-doc.ext-doc-type  = 'производство':U
      buf_sale-doc.doc-kind      = 'производство':U
      buf_sale-doc.obj-type      = buf_fbr-doc.obj-type
      buf_sale-doc.obj-code      = buf_fbr-doc.obj-code
      buf_sale-doc.cli-type      = buf_fbr-doc.obj-type
      buf_sale-doc.cli-code      = buf_fbr-doc.obj-code
      buf_sale-doc.doc-qnty      = v-pri-prvo-doc-qnty
      buf_sale-doc.fact-qnty     = v-pri-prvo-fact-qnty
      buf_sale-doc.tot-lines     = v-pri-prvo-tot-lines
      buf_sale-doc.tot-dtl       = v-pri-prvo-tot-lines
      buf_sale-doc.fbrsale       = yes
      buf_sale-doc.inkas-code    = p-inkas-code
      .
    end.
  end.
end.
end procedure.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
procedure gdsoattr-name :
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-name in g#attr-lib
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
end.
procedure gdsoattr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-tooltip in g#attr-lib
      (input  p-code
      ,output p-tooltip
      ,output p-label
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-value :
  define input  parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define input  parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  define input  parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define output parameter p-value    like ub.gds-obj-attr.attr-value no-undo .
  define output parameter p-type     as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-value in g#attr-lib
      (input  p-code
      ,input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,output p-value
      ,output p-type
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-gds-code :
  define input  parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define input  parameter p-value    like ub.gds-obj-attr.attr-value no-undo .
  define input  parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define output parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-gds-code in g#attr-lib
      (input  p-code
      ,input  p-value
      ,input  p-obj-type
      ,input  p-obj-code
      ,output p-gds-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-write :
  define input parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  define input parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define input parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define input parameter p-value    like ub.gds-obj-attr.attr-value no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-write in g#attr-lib
      (input p-gds-code
      ,input p-obj-type
      ,input p-obj-code
      ,input p-code
      ,input p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-exist :
  define input  parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  define input  parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define output parameter p-exist    as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-exist in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-delete :
  define input  parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  define input  parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-delete in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-obj-doc-tickets :
  define input  parameter p-gds-code    like ub.gds-obj-attr.gds-code no-undo .
  define input  parameter p-obj-type    like ub.gds-obj-attr.obj-type no-undo .
  define input  parameter p-obj-code    like ub.gds-obj-attr.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-obj-doc-tickets in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-obj-dop-alt-name :
  define input  parameter p-gds-code    like ub.gds-obj-attr.gds-code no-undo .
  define input  parameter p-obj-type    like ub.gds-obj-attr.obj-type no-undo .
  define input  parameter p-obj-code    like ub.gds-obj-attr.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-obj-dop-alt-name in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-obj-gds-margins :
  define input  parameter p-gds-code    like ub.gds-obj-attr.gds-code no-undo .
  define input  parameter p-obj-type    like ub.gds-obj-attr.obj-type no-undo .
  define input  parameter p-obj-code    like ub.gds-obj-attr.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-obj-gds-margins in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-obj-normal-wastage :
  define input  parameter p-gds-code    like ub.gds-obj-attr.gds-code no-undo .
  define input  parameter p-obj-type    like ub.gds-obj-attr.obj-type no-undo .
  define input  parameter p-obj-code    like ub.gds-obj-attr.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-obj-normal-wastage in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-attr-margin-value :
  define input  parameter p-gds-code         as integer   no-undo .
  define input  parameter p-obj-type         as character no-undo .
  define input  parameter p-obj-code         as integer   no-undo .
  define output parameter p-min-value        as decimal   no-undo initial ? .
  define output parameter p-max-value        as decimal   no-undo initial ? .
  define output parameter p-increase-pc      as decimal   no-undo initial ? .
  define output parameter p-rmethod          as character no-undo initial '':U .
  define output parameter p-base             as decimal   no-undo initial ? .
  define output parameter p-range-margin     as integer   no-undo .
  define output parameter p-exists-margin    as logical   no-undo .
  define output parameter p-range-increase   as integer   no-undo .
  define output parameter p-exists-increase  as logical   no-undo .
  define output parameter p-range-rmethod    as integer   no-undo .
  define output parameter p-exists-rmethod   as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-margin-value in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,output p-min-value
      ,output p-max-value
      ,output p-increase-pc
      ,output p-rmethod
      ,output p-base
      ,output p-range-margin
      ,output p-exists-margin
      ,output p-range-increase
      ,output p-exists-increase
      ,output p-range-rmethod
      ,output p-exists-rmethod
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-o-normal-wastage-value :
  define input-output parameter objNormWast as class ibs.th.ref.normwastsub no-undo.
do
on error undo, return error
:
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-o-normal-wastage-value in g#attr-lib
      (input-output objNormWast
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-copy :
  define input  parameter p-code as character no-undo .
  define output parameter p-copy as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-copy in g#attr-lib
      (input  p-code
      ,output p-copy
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-attr_check-code-dt-seasons :
  define input  parameter p-code     like ub.goods.gds-code   no-undo .
  define input  parameter p-obj-type like ub.clients.obj-type no-undo .
  define input  parameter p-obj-code like ub.clients.obj-code no-undo .
  define output parameter p-gds-code like ub.goods.gds-code   no-undo .
  define output parameter p-dt-code  as   integer             no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-code-dt-seasons in g#attr-lib
      (input p-code
      ,input p-obj-type
      ,input p-obj-code
      ,output p-gds-code
      ,output p-dt-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure tpsi-gds-fill-tpsi-obj-table :
define input parameter p-db-num like ub.db.db-num no-undo .
define variable v-is-tpsi-obj as logical no-undo .
define buffer buf_clients for ub.clients.
  do
  on error undo, return error return-value
  :
    for each temp-tpsi-clients :
      delete temp-tpsi-clients.
    end.
    _clients:
    for each buf_clients no-lock where
          buf_clients.db-num = p-db-num:
      assign
      v-is-tpsi-obj = no.
      run gbl/tpsi-obj.p (
                      input buf_clients.obj-type
                    ,input buf_clients.obj-code
                    ,output v-is-tpsi-obj) .
      if not v-is-tpsi-obj then NEXT _clients.
      create temp-tpsi-clients.
      buffer-copy
      buf_clients to
      temp-tpsi-clients.
    end.
  end.
end procedure.
procedure tpsi-gds-proprietor :
define input parameter p-gds-code like ub.goods.gds-code no-undo .
define input parameter p-db-num   like ub.db.db-num      no-undo .
define output parameter p-proprietor-host-code like ub.clients.host-code no-undo .
define output parameter p-proprietor-obj-type like ub.clients.obj-type no-undo .
define output parameter p-proprietor-obj-code like ub.clients.obj-code no-undo .
define variable v-is-tpsi-obj as logical no-undo .
do
on error undo, return error return-value
:
    define buffer buf_clients for ub.clients.
    define buffer buf_gds-obj-attr for ub.gds-obj-attr.
    assign
    p-proprietor-obj-type = "":U
    p-proprietor-obj-code = ?
    p-proprietor-host-code = ?
    .
    _gds-obj-attr:
    for each buf_clients no-lock where
            buf_clients.db-num = p-db-num,
      each buf_gds-obj-attr no-lock where
          buf_gds-obj-attr.obj-type = buf_Clients.obj-type
      AND buf_gds-obj-attr.obj-code = buf_clients.obj-code
      AND buf_gds-obj-attr.gds-code = p-gds-code
      AND buf_gds-obj-attr.attr-code = 'proprietor':U:
      if logical(buf_gds-obj-attr.attr-value) = yes then do:
        assign
        v-is-tpsi-obj = no.
        run gbl/tpsi-obj.p (
                        input buf_gds-obj-attr.obj-type
                      ,input buf_gds-obj-attr.obj-code
                      ,output v-is-tpsi-obj) .
        if not v-is-tpsi-obj then NEXT _gds-obj-attr.
        assign
        p-proprietor-obj-type = buf_gds-obj-attr.obj-type
        p-proprietor-obj-code = buf_gds-obj-attr.obj-code
        p-proprietor-host-code = buf_clients.host-code
        .
        LEAVE.
      end.
    end.
end.
end procedure.
procedure tpsi-preselect-gds-proprietor :
define input parameter p-gds-code like ub.goods.gds-code no-undo .
define input parameter p-db-num   like ub.db.db-num      no-undo .
define output parameter p-proprietor-host-code like ub.clients.host-code no-undo .
define output parameter p-proprietor-obj-type like ub.clients.obj-type no-undo .
define output parameter p-proprietor-obj-code like ub.clients.obj-code no-undo .
do
on error undo, return error return-value
:
    define buffer buf_clients for ub.clients.
    define buffer buf_gds-obj-attr for ub.gds-obj-attr.
    assign
    p-proprietor-obj-type = "":U
    p-proprietor-obj-code = ?
    p-proprietor-host-code = ?
    .
    _gds-obj-attr:
    for each temp-tpsi-clients no-lock where
            temp-tpsi-clients.db-num = p-db-num,
      each buf_gds-obj-attr no-lock where
          buf_gds-obj-attr.obj-type = temp-tpsi-clients.obj-type
      AND buf_gds-obj-attr.obj-code = temp-tpsi-clients.obj-code
      AND buf_gds-obj-attr.gds-code = p-gds-code
      AND buf_gds-obj-attr.attr-code = 'proprietor':U:
      if logical(buf_gds-obj-attr.attr-value) = yes then do:
        assign
        p-proprietor-obj-type = buf_gds-obj-attr.obj-type
        p-proprietor-obj-code = buf_gds-obj-attr.obj-code
        p-proprietor-host-code = temp-tpsi-clients.host-code
        .
        LEAVE.
      end.
    end.
end.
end procedure.
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION get-inc-sal returns integer(input p-chk-type as character
                                   , input p-netto as decimal
                                   , input p-chk-doc as logical
                                   , input p-office as character
                                   , input p-write-off-code  as character
                                   , output p-add as logical
                                   , output p-office-to-reserv as character
                                   , output p-kind-to-reserv as character
                                   , output p-add-nf-amount as integer
                                   ):
define variable v-docs-to-reserv as integer no-undo.
if lookup(p-chk-type , '14,15,16,36,8,101,106,108,11,12,13,40,169,196,114,115,116,117,111,112,136,113,201,206,208,301,306,2,3,4,5,7,43,44':U) > 0
then do:
    assign
    v-docS-to-reserv = 0
    p-kind-to-reserv = '':U
    p-add-nf-amount = 1
    .
    return v-docs-to-reserv.
end.
p-add = no.
if p-chk-doc then do:
  if p-chk-type = ? then do:
    if p-netto >= 0 then do:
      assign
      p-chk-type = '1':U.
    end.
    if p-netto < 0 then do:
      assign
      p-chk-type = '6':U.
    end.
  end.
  CASE p-chk-type:
    when '1':U then do:
      assign
      p-kind-to-reserv = 'es':U
      v-docs-to-reserv = 1
      .
    end.
    when '6':U then do:
      assign
      p-kind-to-reserv = 'rs':U
      v-docs-to-reserv = 1
      .
    end.
    when '17':U then do:
      assign
      p-kind-to-reserv = 'trf':U
      v-docs-to-reserv = 1
      .
    end.
    when '96':U then do:
      assign
      p-kind-to-reserv = 'rs':U + chr(44) + 'rwo':U
      v-docs-to-reserv = 2
      .
    end.
    when '69':U then do:
      assign
      p-kind-to-reserv = 'swo':U
      v-docs-to-reserv = 1
      .
    end.
    otherwise do:
      assign
      p-kind-to-reserv = '':U
      v-docs-to-reserv = 0
      .
    End.
  END CASE.
  ASSIGN
  p-add-nf-amount = 0.
  if p-office = 'т':U
  or p-office = 'у':U then do:
    p-office-to-reserv = (if v-docs-to-reserv = 0
                          then '':U
                          else trim(fill((p-office + chr(44)), v-docs-to-reserv), chr(44))).
  end.
  else do:
    assign
    p-office-to-reserv  = (if v-docs-to-reserv = 0
                           then '':U
                           else (trim(fill(entry(1, p-office) + chr(44), v-docs-to-reserv), chr(44)) +
                                chr(44) +
                                 trim(fill(entry(2, p-office) + chr(44), v-docs-to-reserv), chr(44))))
    v-docs-to-reserv = v-docs-to-reserv * 2
    p-kind-to-reserv = (if p-kind-to-reserv = '':U
                        then  '':U
                        else (p-kind-to-reserv + chr(44) + p-kind-to-reserv)) .
  end.
  return v-docs-to-reserv.
end.
else do:
  ASSIGN
  P-kind-to-reserv = '':U
  p-add-nf-amount = 0
  p-add = yes
  p-office-to-reserv = '':U
  .
  if p-write-off-code = '0':U
  or p-write-off-code = ? then do:
    return 0.
  end.
  CASE p-chk-type:
    when '1':U
    then do:
       if p-write-off-code = '1':U
       or p-write-off-code = '3':U
       then do:
          assign
          p-kind-to-reserv = 'swo':U
          v-docs-to-reserv = 1
          p-add = no
          p-office-to-reserv = p-office
          .
       end.
    end.
    when '6':U then do:
       if p-write-off-code = '-6':U
       or p-write-off-code = '-3':U
       then do:
          assign
          p-kind-to-reserv = 'rwo':U
          v-docs-to-reserv = 1
          p-add = no
          p-office-to-reserv = p-office
          .
       end.
    end.
  END CASE.
  return v-docs-to-reserv.
end.
END FUNCTION.
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure gds-attr-name :
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-name in g#attr-lib
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
procedure gds-attr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-tooltip in g#attr-lib
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
procedure gds-attr-value :
  define input  parameter p-gds-code as integer   no-undo .
  define input  parameter p-code     as character no-undo .
  define output parameter p-value    as character no-undo .
  define output parameter p-type     as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
      (input  p-gds-code
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
procedure gds-attr-write :
  define input parameter p-gds-code like ub.goods-attr.gds-code   no-undo .
  define input parameter p-code     like ub.goods-attr.attr-code  no-undo .
  define input parameter p-value    like ub.goods-attr.attr-value no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-write in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-exist :
  define input  parameter p-gds-code like ub.goods-attr.gds-code   no-undo .
  define input  parameter p-code     like ub.goods-attr.attr-code  no-undo .
  define output parameter p-exist    as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-exist in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-delete :
  define input  parameter p-gds-code like ub.goods-attr.gds-code   no-undo .
  define input  parameter p-code     like ub.goods-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-delete in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-news :
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-news in g#attr-lib
      (input  p-code
      ,output p-news
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-copy-to :
  define input  parameter p-gds-code as integer   no-undo .
  define input  parameter p-code     as character no-undo .
  define input  parameter p-bh       as handle no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-copy-to in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-bh
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-copy :
  define input  parameter p-code as character no-undo .
  define output parameter p-copy as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-copy in g#attr-lib
      (input  p-code
      ,output p-copy
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-ptrl-divis :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-ptrl-divis in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-glob-sum-grps :
  define input  parameter p-mode        as character no-undo .
  define input  parameter p-gds-code like ub.gds-obj-attr.gds-code no-undo .
  define input-output parameter p-value as integer no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-glob-sum-grps in g#attr-lib
      (input p-mode
      ,input p-gds-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_gds-ptrl-densities :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input-output  parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_gds-ptrl-densities in g#attr-lib
      (input  p-gds-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_gds-CommodityCode :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input-output  parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_gds-CommodityCode in g#attr-lib
      (input  p-gds-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-office-type :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-office-type in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-mark-type :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-mark-type in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-emrc-type :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-emrc-type in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-group-np :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-group-np in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-item-matter-mark :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-item-matter-mark in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-type-method-calc :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-type-method-calc in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-is-loyalty-payment :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-is-loyalty-payment in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_init-15x80 :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-attr-value  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_init-15x80 in g#attr-lib
      (input  p-gds-code
      ,output p-attr-value
      ) no-error .
    if error-status :error
    then do:
      message error-status:get-message(1) skip return-value view-as alert-box .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_init-8x50 :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-attr-value  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_init-8x50 in g#attr-lib
      (input  p-gds-code
      ,output p-attr-value
      ) no-error .
    if error-status :error
    then do:
      message error-status:get-message(1) skip return-value view-as alert-box .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_init-6x50 :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-attr-value  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_init-6x50 in g#attr-lib
      (input  p-gds-code
      ,output p-attr-value
      ) no-error .
    if error-status :error
    then do:
      message error-status:get-message(1) skip return-value view-as alert-box .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-manual-edit :
  define input  parameter p-code        as character no-undo .
  define output parameter p-section-num as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-manual-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-batch-edit :
  define input  parameter p-code        as character no-undo .
  define output parameter p-section-num as integer   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-batch-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-can-energy-value :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-can-energy-value in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-can-set-dt-seasons :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-can-set  as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-can-set-dt-seasons in g#attr-lib
      (input  p-gds-code
      ,output p-can-set
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure isExemplarGoods :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-gds-code as   integer                    no-undo .
  define output parameter o-result   as   logical                    no-undo.
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run isExemplarGoods in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input p-gds-code
      ,output o-result
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure isVolumArticGoods :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-gds-code as   integer                    no-undo .
  define output parameter o-result   as   logical                    no-undo.
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run isVolumArticGoods in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input p-gds-code
      ,output o-result
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
define buffer for-gds for ub.chk-gds.
define buffer for2-gds for ub.chk-gds.
define buffer for-doc for ub.chk-doc.
define buffer buf-bar for ub.bar-code.
define variable temp-qnty like ub.gds-dtl.fact-qnty no-undo .
define variable chk-amount as integer.
define variable gds-amount as integer.
define variable line-out as integer.
define variable dtl-out as integer.
define variable line-ret as integer.
define variable dtl-ret as integer.
define variable nf-chk-amount as integer.
define variable nff-chk-amount as integer.
define variable nf-gds-amount as integer.
define variable add-nf-amount as integer   no-undo .
define variable add-NF-gds-amount as integer   no-undo .
define variable num_resv as integer no-undo.
define variable num_resv_res as integer no-undo.
define variable KIND-TO-RESERV as character no-undo .
define variable KIND-TO-RESERV-GDS as character no-undo .
define variable office-TO-RESERV as character no-undo .
define variable office-TO-RESERV-GDS as character no-undo .
define variable docs-to-reserv as integer no-undo .
define variable docs-to-reserv-gds as integer no-undo .
define variable v-add as logical no-undo .
define variable dtrg as integer no-undo .
define variable posit as logical no-undo.
define variable negat as logical no-undo.
define variable v-curr-r-b as character no-undo .
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable rsrv-title                  as character no-undo .
define variable rgds-dtl                    as recid no-undo .
define variable cashplace                   as logical no-undo .
define variable cashparts                   as logical no-undo .
define variable cashfbr                     as logical no-undo .
define variable btltaxcd                    as INTEGER                  no-undo.
define variable btltaxunittypes             as char no-undo.
DEFINE VARIABLE bottle as logical no-undo .
define variable num_rec                     as integer no-undo .
define variable num_rec_res                 as integer no-undo.
define variable num_rec_other                as integer no-undo .
define variable num_rec_other_res            as integer no-undo.
define variable cost-base                    as decimal no-undo .
define variable cost-rubl                    as decimal no-undo .
define variable r-qnty                      as decimal no-undo .
define variable r-pl-code                   as integer no-undo .
define variable r-b-code                    as integer no-undo .
define variable r-doc-prts-qnty             as decimal no-undo .
define variable r-artic                     like ub.doc-line.artic no-undo .
define variable r-prod-type                 like ub.doc-line.prod-type no-undo .
define variable r-prod-code                 like ub.doc-line.prod-code no-undo .
define variable r-prt-code                  like ub.gds-dtl.prt-code no-undo .
function cross-list returns logical (
  input parfirst-stream  as character,
  input parsecond-stream as character,
  input pardelim         as character).
  if pardelim = ""
  or pardelim = ?
  then do:
    assign
      pardelim = ","
    .
  end.
  define variable vari            as integer no-undo .
  define variable varresult-cross as logical no-undo .
  assign
    varresult-cross = no
  .
  def var v-num-parfirst-stream as integer no-undo .
  assign
    v-num-parfirst-stream = num-entries(parfirst-stream, pardelim)
  .
  do vari = 1 to v-num-parfirst-stream
  :
    if lookup(entry(vari, parfirst-stream, pardelim)
             ,parsecond-stream
             ,pardelim
             ) > 0 then do:
      assign
        varresult-cross = yes
      .
      leave.
    end.
  end.
  return varresult-cross .
end function.
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function octal-to-char return character
( p-string as character ) :
  def var v-asc     as integer no-undo .
  def var v-new-asc as integer no-undo .
  def var ind       as integer no-undo .
  if length(p-string) <> 3 then do:
    return ? .
  end.
  assign
    v-asc = 0
  .
  do ind = 1 to length(p-string)
  :
    assign
      v-new-asc = asc(substring(p-string, ind, 1)) - asc('0')
    .
    if v-new-asc < 0 or v-new-asc >= 8 then do:
      return ? .
    end.
    assign
      v-asc = v-asc * 8 + v-new-asc
    .
  end.
  return chr(v-asc) .
end function .
function char-to-octal return character
( p-chr as character ) :
  def var v-asc    as integer   no-undo .
  def var ind      as integer   no-undo .
  def var v-string as character no-undo .
  if length(p-chr) <> 1 then do:
    return ? .
  end.
  assign
    v-asc    = asc(p-chr)
    v-string = ""
  .
  do ind = 1 to 3
  :
    assign
      v-string = chr( v-asc mod 8 + asc('0')) + v-string
    .
    assign
      v-asc = truncate(v-asc / 8, 0)
    .
  end.
  return v-string .
end.
function str-encode return character
(   p-init-string       as character
  , p-encode-char       as character
  , p-special-char-list as character
) :
  def var p-encode-string as character no-undo .
  def var ind                as integer no-undo .
  def var v-num-special-char as integer no-undo .
  def var v-special-char     as character no-undo .
  if p-encode-char = ?
  or p-encode-char = "" then do:
    assign
      p-encode-char = "~~"
    .
  end.
  if p-init-string = ? then do:
    return "?" .
  end.
  if p-init-string = "?" then do:
    return p-encode-char + char-to-octal("?") .
  end.
  assign
    v-num-special-char = length(p-special-char-list)
    p-encode-string    = replace(p-init-string
                                ,p-encode-char
                                ,p-encode-char + char-to-octal(p-encode-char)
                                )
  .
  do ind = 1 to v-num-special-char
  :
    assign
      v-special-char = substring(p-special-char-list, ind, 1)
    .
    if v-special-char <> p-encode-char then do:
      assign
        p-encode-string = replace (p-encode-string
                                  ,v-special-char
                                  ,p-encode-char + char-to-octal(v-special-char)
                                  )
      .
    end.
  end.
  return p-encode-string .
end.
function str-decode returns character
  (p-init-string   as character
  ,p-encode-char   as character
  ) :
  def var p-decode-string as character no-undo .
  def var ind                       as integer no-undo .
  def var v-num-entries-init-string as integer no-undo .
  def var v-sub-phrase              as character no-undo .
  def var v-special-char            as character no-undo .
  if p-encode-char = ?
  or p-encode-char = "" then do:
    assign
      p-encode-char = "~~"
    .
  end.
  if p-init-string = "?" then do:
    return ? .
  end.
  assign
    v-num-entries-init-string = num-entries(p-init-string, p-encode-char)
  .
  if v-num-entries-init-string > 1 then do:
    assign
      p-decode-string = entry(1, p-init-string, p-encode-char)
    .
    do ind = 2 to v-num-entries-init-string
    :
      assign
        v-sub-phrase = entry(ind, p-init-string, p-encode-char)
      .
      assign
        v-special-char = octal-to-char(substring(v-sub-phrase, 1, 3))
      .
      if v-special-char <> ? then do:
        assign
          p-decode-string = p-decode-string
                          + v-special-char
                          + substring(v-sub-phrase, 4)
        .
      end.
      else do:
        assign
          p-decode-string = p-decode-string
                          + p-encode-char
                          + v-sub-phrase
        .
      end.
    end.
  end.
  else do:
    assign
      p-decode-string = p-init-string
    .
  end.
  return p-decode-string .
end.
function is-gas returns logical
        (input p-gds-code as integer):
define variable result as logical no-undo.
define variable c-value as character no-undo.
define variable c-type as character no-undo.
do on error undo, return error:
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
      (input  p-gds-code
      ,input  'fuel-type':U
      ,output c-value
      ,output c-type) no-error.
end.
result = logical(c-value = 'metan':U) no-error.
return result.
end function.
define variable two-units-parts as logical no-undo .
define variable deleted-d as logical no-undo.
define variable deleted-g as logical no-undo.
define variable zero-gds-dtl as logical no-undo.
define variable found as logical no-undo.
define variable prcl-spl as logical no-undo init no.
define variable factorrt as decimal no-undo.
define variable conf-attr as char no-undo.
define variable conf-par as char no-undo.
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-tth as handle no-undo .
define variable par-type as char no-undo.
define variable for-price as decimal no-undo.
define variable for-excise as decimal no-undo.
define variable autofbr as logical no-undo .
define variable rdoc-line as recid no-undo.
define variable r-or-v as character no-undo.
define variable plcode like ub.doc-pl.pl-code no-undo.
define variable pumpcode like ub.doc-pl-pump.pump-code no-undo.
define variable dopf as decimal no-undo.
DEFINE VARIABLE var-doc-type like ub.inkas-pay-desk.doc-type no-undo .
define variable v-discnt-r-b like ub.gds-dtl.discnt-rubl no-undo .
define variable v-price-r-b like ub.gds-dtl.price-rubl no-undo .
define variable v-is-tpsi-obj as logical no-undo .
define variable v-run-tpsi    as logical no-undo .
define variable v-real-qnty like ub.inkas.qnty no-undo .
define variable v-base-rate like ub.trn-doc.base-rate no-undo .
define variable v-base-scale like ub.trn-doc.base-scale no-undo .
define variable v-cash-pay-attr as character no-undo.
define variable cli-type-to-reserv as character no-undo.
define variable cli-code-to-reserv as integer no-undo.
define variable par-alcohol as character no-undo .
define variable v-mark as character no-undo .
define variable v-mark-list as character no-undo .
define variable mark-ii as integer  no-undo .
define variable v-host-code like ub.sysconf.host-code no-undo .
define variable p-filter-rus as character no-undo .
define buffer buf_chk-gds for ub.chk-gds.
define buffer buf_chk-discnt for ub.chk-discnt.
define buffer buf_chk-pay for ub.chk-pay.
define buffer buf_chk-doc-attr for ub.chk-doc-attr.
define buffer buf_chk-gds-pay for ub.chk-gds-pay.
define buffer buf_cash-pay-attr for ub.cash-pay-attr.
define buffer buf_c-chk-doc for ub.c-chk-doc.
define buffer buf_c-chk-gds for ub.c-chk-gds.
define buffer buf_c-chk-pay for ub.c-chk-pay.
define buffer buf_c-chk-discnt for ub.c-chk-discnt.
define buffer buf_c-chk-doc-attr for ub.c-chk-doc-attr.
define buffer buf_sale-doc for ub.sale-doc.
define buffer tpsi_sale-doc for ub.sale-doc.
define buffer dop_trn-doc for ub.trn-doc.
define buffer buf_trn-doc for ub.trn-doc.
define buffer buf0_trn-doc for ub.trn-doc.
define buffer buf_doc-line for ub.doc-line.
define buffer buf_gds-dtl for ub.gds-dtl.
define buffer buf_inkas-pay for ub.inkas-pay.
define buffer buf_inkas-pay-desk for ub.inkas-pay-desk.
define buffer buf_inkas-pay-wth for ub.inkas-pay-wth.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE RSRv-line:
define input parameter p-r-v                as integer no-undo .
define input parameter p-auto-fbr           as logical no-undo .
define input parameter p-rsrv-prop-goods    as logical no-undo .
define input parameter p-auto-fbr-on        as logical no-undo .
define variable p-rest-dish                 as logical no-undo .
define variable p-fbr-income-doc-code       like ub.trn-doc.doc-code no-undo.
define input parameter p-tpsi-obj           as logical no-undo .
define input parameter p-rest-tpsi          as logical no-undo .
DEFINE INPUT PARAMETER rz                   as logical no-undo.
DEFINE INPUT PARAMETER gdscode              like ub.goods.gds-code.
DEFINE INPUT PARAMETER nodecode             like ub.gds-prt.node-code.
define output parameter p-run-tpsi          as logical no-undo .
DEFINE parameter buffer b-doc-line for ub.doc-line.
DEFINE parameter buffer b-trn-doc for ub.trn-doc.
define parameter buffer buf_sale-doc for ub.sale-doc.
define buffer loc-doc-prts for ub.doc-prts.
define buffer loc-doc-pl for ub.doc-pl.
define buffer loc-doc-fbr-gds for ub.doc-fbr-gds.
DEFINE BUFFER loc-gds-dtl for ub.gds-dtl.
define buffer buf_parts for ub.parts .
define buffer other_doc-line for ub.doc-line.
define buffer other_gds-dtl  for ub.gds-dtl.
define buffer buf_doc-fbr-gds for ub.doc-fbr-gds .
define variable res-qnty                    as decimal no-undo.
define variable gds-dtl-res-qnty            as decimal no-undo.
define variable no-partion-qnty             as decimal no-undo.
define variable no-place-qnty               as decimal no-undo.
define variable res-parts                   as decimal no-undo.
define variable ser-chg-qnty                as decimal no-undo.
define variable pl-chg-qnty                 as decimal no-undo.
define variable pl-chg-cli-qnty             as decimal no-undo.
define variable old-pl-qnty                 as decimal no-undo.
define variable new-pl-qnty                 as decimal no-undo.
define variable chg-qnty                    as decimal no-undo.
define variable fbr-qnty                    as decimal no-undo .
define variable fbr-chg-qnty                as decimal no-undo .
define variable parts-OK                    as logical no-undo init yes.
define variable place-OK                    as logical no-undo init yes.
define variable rsrv-option                 as character no-undo.
define variable rsrv-option-place           as character no-undo.
define variable v-proprietor-host-code      like ub.clients.host-code no-undo .
define variable v-proprietor-obj-type       like ub.clients.obj-type no-undo .
define variable v-proprietor-obj-code       like ub.clients.obj-code no-undo .
define variable v-is-own                    as logical no-undo .
define variable v-to-reserv                 as logical no-undo .
define variable v-ext-doc-type              like ub.trn-doc.ext-doc-type no-undo .
define variable v-gds-dtl-fact-qnty         like ub.gds-dtl.fact-qnty no-undo .
define variable v-was-gds-dtl-doc-qnty      like ub.gds-dtl.fact-qnty no-undo .
define variable v-return-st-fl              as logical no-undo .
define variable v-return-status             like ub.trn-doc.status_ no-undo .
define variable v-return-flag               like ub.trn-doc.flag    no-undo .
define variable v-dop-sale-negative-check   as character no-undo .
define variable v-nc-option                 as character no-undo .
define variable current-rgds-dtl            as recid no-undo .
define variable v-qnty                      as decimal no-undo .
define variable v-cli-qnty                  as decimal no-undo .
define variable v-err-msg                   as character no-undo .
define buffer tpsi_sale-doc for ub.sale-doc.
define buffer buf_tt0-gds-dtl for tt0-gds-dtl.
    define buffer   in-vatp-trn-doc  for ub.trn-doc .
    define buffer   in-vatp-parts    for ub.parts   .
    define buffer   in-vatp-doc      for ub.trn-doc .
    define buffer   in-vatp-goods    for ub.goods   .
    define buffer   in-vatp-sysconf  for ub.sysconf .
    define buffer   in-vatp_doc-attr for ub.doc-attr.
    define variable in-vatp-have-vat-slt       as   logical initial yes    no-undo.
    define variable vat-pc-loc                 like ub.doc-line.vat-pc     no-undo.
    define variable varinvprb                  as   character              no-undo.
    define variable slt-pc-loc                 like ub.doc-line.slt-pc     no-undo.
    define variable cli-base-rate              as   decimal                no-undo.
    define variable price-rubl-with-tax-loc    like ub.doc-line.price-rubl no-undo.
    define variable price-base-with-tax-loc    like ub.doc-line.price-base no-undo.
    define variable price-cli-with-tax-loc     like ub.doc-line.price-cli  no-undo.
    define variable price-rubl-without-tax-loc like ub.doc-line.price-rubl no-undo.
    define variable price-base-without-tax-loc like ub.doc-line.price-base no-undo.
    define variable price-cli-without-tax-loc  like ub.doc-line.price-base no-undo.
    define variable vat-base-loc               like ub.doc-line.price-base no-undo.
    define variable vat-rubl-loc               like ub.doc-line.price-rubl no-undo.
    define variable vat-cli-loc                like ub.doc-line.price-rubl no-undo.
    define variable slt-base-loc               like ub.doc-line.price-base no-undo.
    define variable slt-rubl-loc               like ub.doc-line.price-rubl no-undo.
    define variable slt-cli-loc                like ub.doc-line.price-rubl no-undo.
    define variable road-tax-base-loc          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-rubl-loc          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-cli-loc           like ub.doc-line.road-tax   no-undo.
    define variable transport-base-loc         like ub.doc-line.price-base no-undo.
    define variable transport-rubl-loc         like ub.doc-line.price-rubl no-undo.
    define variable transport-cli-loc          like ub.doc-line.price-rubl no-undo.
    define variable other-base-loc             like ub.doc-line.price-base no-undo.
    define variable other-rubl-loc             like ub.doc-line.price-rubl no-undo.
    define variable other-cli-loc              like ub.doc-line.price-rubl no-undo.
    define variable exch-rate-cli-loc          like ub.trn-doc.exch-rate   no-undo.
    define variable varinvatp-envd             as   character              no-undo.
    define variable varinvatp-type             as   character              no-undo.
  if not rz and v-dop-sale-negative-check = '':U then v-dop-sale-negative-check = ',' + 'negative-check':U + "=1".
if not p-rsrv-prop-goods
AND (p-tpsi-obj
and p-r-v = 1
and not cashplace
and not cashparts
and not b-trn-doc.office)
then do:
  run tpsi-gds-proprietor in this-procedure (
                                              input gdscode
                                             ,input g#db-num
                                             ,output v-proprietor-host-code
                                             ,output v-proprietor-obj-type
                                             ,output v-proprietor-obj-code ) no-error .
  if error-status:error then do:
    num_rec = num_rec + 1.
    undo, return error substitute("Ошибки при проверке атрибута товара на объекте ПРИНАДЛЕЖНОСТЬ ТОВАРА для товара с кодом &1 на БД &2:&3&4 &5"
                                  ,gdscode
                                  ,g#db-num
                                  , chr(10)
                                  , error-status:get-message(1)
                                  , return-value
                                  ).
  end.
  if (v-proprietor-obj-type = "":U
      and
      v-proprietor-obj-code = 0)
  or v-proprietor-obj-code = ?
      then do:
    num_rec = num_rec + 1.
    undo, return error substitute("Не установлен атрибут товара на объекте ПРИНАДЛЕЖНОСТЬ ТОВАРА для товара с кодом &1 ни для одного объекта БД &2"
                                  ,gdscode
                                  ,g#db-num
                                  ).
  end.
  if (v-proprietor-obj-type = b-trn-doc.obj-type
  and v-proprietor-obj-code = b-trn-doc.obj-code)
  then do:
    assign
    v-is-own = yes
    .
  end.
  else do:
    assign
    p-run-tpsi = yes.
    if v-proprietor-host-code = v-host-code then do:
      assign
      v-ext-doc-type = 'ev':U .
    end.
    else do:
      assign
      v-ext-doc-type =  'ee':U .
    end.
    find first tpsi_sale-doc no-lock where
              tpsi_sale-doc.inkas-code = buf_sale-doc.inkas-code
          and tpsi_sale-doc.tpsidoc = yes
          and tpsi_sale-doc.obj-type = v-proprietor-obj-type
          AND tpsi_sale-doc.obj-code = v-proprietor-obj-code
          AND tpsi_sale-doc.ext-doc-type = v-ext-doc-type  no-error .
   end.
end.
else v-is-own = yes.
if v-is-own then do:
  assign
  v-to-reserv = yes
  rsrv-option = (if (rgds-dtl = ?) and not p-auto-fbr
                  then 'reserv':U  + ',' + 'no-message':U
                  else 'reserv':U
                  )
  + v-dop-sale-negative-check
  .
  if cashfbr and p-auto-fbr-on and rz and not p-auto-fbr then return.
end.
else do:
  assign
  cashfbr = no.
  if p-rest-tpsi or rz = no then do:
    assign
    v-nc-option = "=2":U.
    assign
    v-to-reserv = yes
    rsrv-option = (if (rgds-dtl = ?) and not p-auto-fbr
                    then 'reserv':U  + ',' + 'no-message':U + ',' + 'negative-check':U + v-nc-option
                    else 'reserv':U  + ',' + 'negative-check':U + v-nc-option
                    )
    .
    if p-rest-tpsi then do:
      assign
      rsrv-option = rsrv-option + ',' + 'sale-negative-check-on':u
      .
    end.
  end.
end.
if cashfbr
and (not p-rest-dish)
and p-auto-fbr-on and rz
and p-fbr-income-doc-code <> "":U
then do:
  _parts:
  for each buf_parts no-lock
      where buf_parts.obj-type  = b-trn-doc.obj-type
        and buf_parts.obj-code  = b-trn-doc.obj-code
        and buf_parts.prod-type = b-doc-line.prod-type
        and buf_parts.prod-code = b-doc-line.prod-code
        and buf_parts.artic     = b-doc-line.artic
        and buf_parts.status_   = yes
        and buf_parts.out-code  = p-fbr-income-doc-code
  on error undo, return error return-value
    :
    assign
    rsrv-option = 'reserv':U
                    + "," + 'rsrv-single-part':U
                    + "," + 'rsrv-in-code':U   + "=":u + str-encode ( buf_parts.in-code  ,  "", ",=":u )
                    + "," + 'rsrv-part-code':U + "=":u + str-encode ( buf_parts.part-code,  "", ",=":u )
    .
    leave _parts.
  end.
end.
if cashplace then do:
  FIND FIRST loc-gds-dtl WHERE
          loc-gds-dtl.doc-code = b-trn-doc.doc-code AND
          loc-gds-dtl.artic = b-doc-line.artic AND
          loc-gds-dtl.prod-type = b-doc-line.prod-type AND
          loc-gds-dtl.prod-code = b-doc-line.prod-code AND
          loc-gds-dtl.prt-code = nodecode
          EXCLUSIVE-LOCK NO-ERROR.
  IF rz  and loc-gds-dtl.fact-qnty <= loc-gds-dtl.doc-qnty then LEAVE.
  IF NOT rz and loc-gds-dtl.doc-qnty = 0 then LEAVE.
  IF NOT (rgds-dtl = ?) AND NOT recid(loc-gds-dtl) = rgds-dtl THEN LEAVE.
  if ( num_rec modulo 10 ) = 0 then
run waitfram-show in this-procedure (input substitute("&1 - обработано &2, из них успешно - &3"                                                         , rsrv-title                                                                 , num_rec                                                                    , num_rec_res) ).
  if rz then
  find first buf_tt0-gds-dtl no-lock where
            buf_tt0-gds-dtl.artic = loc-gds-dtl.artic
       AND  buf_tt0-gds-dtl.prod-type = loc-gds-dtl.prod-type
       AND  buf_tt0-gds-dtl.prod-code = loc-gds-dtl.prod-code
       AND  buf_tt0-gds-dtl.prt-code  = loc-gds-dtl.prt-code no-error .
  assign
  chg-qnty   = 0.0
  res-qnty   = 0.0
  cost-base  = 0.0
  cost-rubl  = 0.0
  v-qnty     = 0.0
  v-cli-qnty = 0.0
  gds-dtl-res-qnty = if rz
                    then ((loc-gds-dtl.fact-qnty - loc-gds-dtl.doc-qnty) + (if available buf_tt0-gds-dtl
                                                                            then (buf_tt0-gds-dtl.fact-qnty - buf_tt0-gds-dtl.doc-qnty)
                                                                            else 0))
                    else (if r-qnty = ?
                          then (- loc-gds-dtl.doc-qnty)
                          else r-qnty)
  .
  _docpl:
  FOR EACH loc-doc-pl where
            loc-doc-pl.gds-code = gdscode AND
            loc-doc-pl.out-code = b-doc-line.doc-code ON ERROR UNDO, NEXT:
    assign
    v-qnty                  = v-qnty + loc-doc-pl.doc-qnty
    v-cli-qnty              = v-cli-qnty + loc-doc-pl.cli-doc-qnty
    .
    if rz and loc-doc-pl.fact-qnty <= loc-doc-pl.doc-qnty then NEXT.
    if not rz and loc-doc-pl.doc-qnty = 0 then NEXT.
    if NOT r-pl-code = ? AND r-pl-code <> loc-doc-pl.pl-code then NEXT.
    assign
    v-err-msg       = "":U
    pl-chg-qnty     = (if rz then loc-doc-pl.fact-qnty     else 0.0 ) - loc-doc-pl.doc-qnty
    pl-chg-cli-qnty = (if rz then loc-doc-pl.cli-fact-qnty else 0.0 ) - loc-doc-pl.cli-doc-qnty
    res-qnty = res-qnty + pl-chg-qnty
    no-partion-qnty = gds-dtl-res-qnty - res-qnty
    cost-base = 0
    cost-rubl = 0
    rsrv-option-place = rsrv-option + "," + 'plcode':U + "=" + string(loc-doc-pl.pl-code)
    .
    if b-trn-doc.status_ = 'нередакт':U
    or b-trn-doc.flag <> no
    then do:
      assign
      v-return-status =  b-trn-doc.status_
      v-return-flag = b-trn-doc.flag
      b-trn-doc.status_ = 'накл':U
      b-trn-doc.flag = no
      v-return-st-fl = yes
      .
    end.
    if not (is-gas(gdscode) and buf_sale-doc.doc-kind <> 'rs':U)
    then do :
      if recid(loc-gds-dtl) <> current-rgds-dtl then assign num_rec = num_rec + 1 current-rgds-dtl = recid(loc-gds-dtl).
    end.
    assign
      old-pl-qnty = (- loc-doc-pl.doc-qnty)
    .
    if old-pl-qnty <> 0.0 then do:
      run trg/rsrv-dtl.p (
                      input parparentproc
                      ,input rsrv-option-place
                      ,buffer loc-gds-dtl
                      ,input-output old-pl-qnty
                      ,input-output cost-base
                      ,input-output cost-rubl
                      ,-1, "" ) no-error.
      if error-status :error then do:
        assign
        v-err-msg = substitute( "Ошибка при разрезервировании.&1&2"
                               , chr(10)
                               , return-value
                              )
        .
      end.
      else do:
        if old-pl-qnty <> (- loc-doc-pl.doc-qnty) then do:
          assign
          v-err-msg = substitute( "Не удалось снять резервы по ранее зарезервированному количеству.&1Запрошено: &2&1Удалось разрезервировать: &3&1"
                                , chr(10)
                                , (- loc-doc-pl.doc-qnty)
                                , old-pl-qnty
                                )
          .
        end.
      end.
      if v-err-msg <> "":U then do:
        v-return-st-fl = no.
        undo _docpl, return error v-err-msg .
      end.
    end.
    assign
    loc-doc-pl.doc-qnty     = loc-doc-pl.doc-qnty     + pl-chg-qnty
    loc-doc-pl.cli-doc-qnty = loc-doc-pl.cli-doc-qnty + pl-chg-cli-qnty
    loc-doc-pl.cli-qnty     = loc-doc-pl.cli-doc-qnty
    new-pl-qnty             = loc-doc-pl.doc-qnty
    v-qnty                  = v-qnty + pl-chg-qnty
    v-cli-qnty              = v-cli-qnty + pl-chg-cli-qnty
    .
    if new-pl-qnty <> 0.0 then do:
      run trg/rsrv-dtl.p (
                      input parparentproc
                      ,input rsrv-option-place
                      ,buffer loc-gds-dtl
                      ,input-output new-pl-qnty
                      ,input-output cost-base
                      ,input-output cost-rubl
                      ,-1
                      ,"") no-error.
      if error-status :error then do:
        assign
        v-err-msg = substitute( "Ошибка при резервировании.&1&2"
                              , chr(10)
                              , return-value
                              )
        .
      end.
      else do:
        if new-pl-qnty <> loc-doc-pl.doc-qnty then do:
          assign
          v-err-msg = substitute( "Не удалось зарезервировать все запрошенное количество.&1Запрошено: &2&1Удалось разрезервировать: &3&1"
                                , chr(10)
                                , loc-doc-pl.doc-qnty - old-pl-qnty
                                , new-pl-qnty - old-pl-qnty
                                )
          .
        end.
      end.
      if v-err-msg <> "":U then do:
        v-return-st-fl = no.
        undo _docpl, return error v-err-msg .
      end.
    end.
    if v-return-st-fl then do:
      assign
      b-trn-doc.status_ = v-return-status
      b-trn-doc.flag = v-return-flag
      v-return-st-fl = no
      .
    end.
    assign
    chg-qnty = chg-qnty + pl-chg-qnty
    .
  END.
  if v-qnty <> 0.0
    and v-cli-qnty <> 0.0
  then do:
    assign
    b-doc-line.doc-density = v-cli-qnty / v-qnty
    .
  end.
  if chg-qnty <> 0 then  do:
      assign
      loc-gds-dtl.doc-qnty = loc-gds-dtl.doc-qnty + chg-qnty
      b-doc-line.doc-qnty = b-doc-line.doc-qnty + chg-qnty
      buf_sale-doc.doc-qnty = buf_sale-doc.doc-qnty  + chg-qnty
      b-trn-doc.doc-qnty = b-trn-doc.doc-qnty  + chg-qnty
      b-doc-line.cli-qnty = v-cli-qnty
      .
      if (loc-gds-dtl.doc-qnty = loc-gds-dtl.fact-qnty and rz) or                           (loc-gds-dtl.doc-qnty = 0 and not  rz)  then do: assign num_rec_res = num_rec_res + 1. end.
      if bottle then do:
assign
  price-rubl-with-tax-loc = b-doc-line.price-rubl
  price-base-with-tax-loc = b-doc-line.price-base
.
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprb
  )  .
   find first in-vatp_doc-attr no-lock
    where in-vatp_doc-attr.doc-code  = b-trn-doc.doc-code
      and in-vatp_doc-attr.attr-code = 'envd':U
    no-error .
    if available in-vatp_doc-attr
       then do:
       assign
         in-vatp-have-vat-slt = no.
   end.
   else do:
     assign
       in-vatp-have-vat-slt = yes.
   end.
   find first in-vatp-goods where in-vatp-goods.artic     = b-doc-line.artic     and
                                     in-vatp-goods.prod-type = b-doc-line.prod-type and
                                     in-vatp-goods.prod-code = b-doc-line.prod-code no-lock.
   if (not b-trn-doc.internal and
           b-trn-doc.doc-type = 'при':U) or
      in-vatp-goods.gds-type = 'у':U then do:
      if varinvprb = "base":u then do:
        assign
          road-tax-base-loc = b-doc-line.road-tax
          road-tax-rubl-loc = b-doc-line.road-tax * b-trn-doc.base-rate / b-trn-doc.base-scale.
      end.
      else do:
        ASSIGN
          road-tax-rubl-loc = b-doc-line.road-tax
          road-tax-base-loc = b-doc-line.road-tax / b-trn-doc.base-rate * b-trn-doc.base-scale.
      end.
      if road-tax-base-loc = ? then road-tax-base-loc = 0.
      if road-tax-rubl-loc = ? then road-tax-rubl-loc = 0.
      assign
        road-tax-cli-loc = ?.
      ASSIGN
        transport-base-loc = (if b-doc-line.transport-base = ? then 0 else b-doc-line.transport-base)
        transport-rubl-loc = (if b-doc-line.transport-rubl = ? then 0 else b-doc-line.transport-rubl)
        transport-cli-loc  = 0
        other-base-loc     = (if b-doc-line.other-base     = ? then 0 else b-doc-line.other-base)
        other-rubl-loc     = (if b-doc-line.other-rubl     = ? then 0 else b-doc-line.other-rubl)
        other-cli-loc      = 0
        vat-pc-loc         = (if b-doc-line.vat-pc         = ? then 0 else b-doc-line.vat-pc)
        slt-pc-loc         = (if b-doc-line.slt-pc         = ? then 0 else b-doc-line.slt-pc).
                              ASSIGN   slt-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
            ASSIGN   slt-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
      assign
        vat-cli-loc            = ?
        slt-cli-loc            = ?
        price-cli-with-tax-loc = ?.
   end.
   else do:
                                                for each in-vatp-parts where in-vatp-parts.out-code  = b-doc-line.doc-code  and
                                      in-vatp-parts.obj-type  = b-doc-line.obj-type  and
                                      in-vatp-parts.obj-code  = b-doc-line.obj-code  and
                                      in-vatp-parts.artic     = b-doc-line.artic     and
                                      in-vatp-parts.prod-type = b-doc-line.prod-type and
                                      in-vatp-parts.prod-code = b-doc-line.prod-code
                         use-index out-code no-lock:
          accumulate  in-vatp-parts.road-tax-base  * in-vatp-parts.fact-qnty (total)
                      in-vatp-parts.road-tax-rubl  * in-vatp-parts.fact-qnty (total)
                      in-vatp-parts.transport-base * in-vatp-parts.fact-qnty (total)
                      in-vatp-parts.transport-rubl * in-vatp-parts.fact-qnty (total)
                      in-vatp-parts.other-base     * in-vatp-parts.fact-qnty (total)
                      in-vatp-parts.other-rubl     * in-vatp-parts.fact-qnty (total)
                                                                                                              (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty                      / (100 + in-vatp-parts.slt-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))  / (100 + in-vatp-parts.vat-pc))  (total)
                                            (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                      / (100 + in-vatp-parts.slt-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))  / (100 + in-vatp-parts.vat-pc))  (total)
                      .
      end.
      ASSIGN
        road-tax-base-loc   = if b-doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.road-tax-base  * in-vatp-parts.fact-qnty) / b-doc-line.fact-qnty  else 0
        road-tax-rubl-loc   = if b-doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.road-tax-rubl  * in-vatp-parts.fact-qnty) / b-doc-line.fact-qnty  else 0
        transport-base-loc  = if b-doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.transport-base * in-vatp-parts.fact-qnty) / b-doc-line.fact-qnty  else 0
        transport-rubl-loc  = if b-doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.transport-rubl * in-vatp-parts.fact-qnty) / b-doc-line.fact-qnty  else 0
        other-base-loc      = if b-doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.other-base     * in-vatp-parts.fact-qnty) / b-doc-line.fact-qnty  else 0
        other-rubl-loc      = if b-doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.other-rubl     * in-vatp-parts.fact-qnty) / b-doc-line.fact-qnty  else 0
                                        vat-base-loc        = if b-doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))) / b-doc-line.fact-qnty   else 0
        slt-base-loc        = if b-doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))) / b-doc-line.fact-qnty   else 0
                vat-rubl-loc        = if b-doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))) / b-doc-line.fact-qnty   else 0
        slt-rubl-loc        = if b-doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))) / b-doc-line.fact-qnty   else 0
        vat-pc-loc          = (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))) / (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))  / (100 + in-vatp-parts.vat-pc)))
        slt-pc-loc          = (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))) / (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                      / (100 + in-vatp-parts.slt-pc))).
      if road-tax-base-loc  = ? then road-tax-base-loc  = 0.
      if road-tax-rubl-loc  = ? then road-tax-rubl-loc  = 0.
      if transport-base-loc = ? then transport-base-loc = 0.
      if transport-rubl-loc = ? then transport-rubl-loc = 0.
      if other-base-loc     = ? then other-base-loc     = 0.
      if other-rubl-loc     = ? then other-rubl-loc     = 0.
      assign
        transport-cli-loc      = 0
        other-cli-loc          = 0
        road-tax-cli-loc       = ?
        vat-cli-loc            = ?
        slt-cli-loc            = ?
        price-cli-with-tax-loc = ?.
   end.
ASSIGN
          price-base-without-tax-loc = price-base-with-tax-loc - vat-base-loc - slt-base-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))
    price-rubl-without-tax-loc = price-rubl-with-tax-loc - vat-rubl-loc - slt-rubl-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))
.
        assign
        b-doc-line.road-tax = (if v-curr-r-b = 'rubl':U then road-tax-rubl-loc else road-tax-base-loc).
      end.
      if rz then do:
        if b-trn-doc.print-rubl then
        assign
        loc-gds-dtl.price-base = loc-gds-dtl.price-rubl / b-trn-doc.base-rate * b-trn-doc.base-scale
        loc-gds-dtl.discnt-base = loc-gds-dtl.discnt-rubl / b-trn-doc.base-rate * b-trn-doc.base-scale
        loc-gds-dtl.discnt-pc = (if loc-gds-dtl.price-rubl = 0
                                 then 0
                                 else loc-gds-dtl.discnt-rubl * 100 / loc-gds-dtl.price-rubl) .
        else
        assign
        loc-gds-dtl.price-rubl = loc-gds-dtl.price-base * b-trn-doc.base-rate / b-trn-doc.base-scale
        loc-gds-dtl.discnt-rubl = loc-gds-dtl.discnt-base * b-trn-doc.base-rate / b-trn-doc.base-scale
        loc-gds-dtl.discnt-pc = (if loc-gds-dtl.price-base = 0
                                 then 0
                                 else loc-gds-dtl.discnt-base * 100 / loc-gds-dtl.price-base) .
      end.
    end.
    if chg-qnty = res-qnty then place-ok = yes.
    else place-ok = no.
    release loc-gds-dtl.
    if no-place-qnty = 0 then return.
  end.
  if NOT cashplace AND cashparts then do:
    FIND FIRST loc-gds-dtl WHERE
              loc-gds-dtl.doc-code = b-trn-doc.doc-code AND
              loc-gds-dtl.artic = b-doc-line.artic AND
              loc-gds-dtl.prod-type = b-doc-line.prod-type AND
              loc-gds-dtl.prod-code = b-doc-line.prod-code AND
              loc-gds-dtl.prt-code = nodecode
              EXCLUSIVE-LOCK NO-ERROR.
    IF rz  and loc-gds-dtl.fact-qnty <= loc-gds-dtl.doc-qnty then LEAVE.
    IF NOT rz and loc-gds-dtl.doc-qnty = 0 then LEAVE.
    IF NOT (rgds-dtl = ?) AND NOT recid(loc-gds-dtl) = rgds-dtl THEN LEAVE.
  if ( num_rec modulo 10 ) = 0 then
run waitfram-show in this-procedure (input substitute("&1 - обработано &2, из них успешно - &3"                                                         , rsrv-title                                                                 , num_rec                                                                    , num_rec_res) ).
    assign
    chg-qnty = 0
    res-qnty = 0
    cost-base = 0
    cost-rubl = 0
    gds-dtl-res-qnty = if rz
                        then (loc-gds-dtl.fact-qnty - loc-gds-dtl.doc-qnty)
                        else (if r-qnty = ?
                              then (- loc-gds-dtl.doc-qnty)
                              else r-qnty)
    .
    _docprts:
    FOR EACH loc-doc-prts where
            loc-doc-prts.gds-code = gdscode AND
            loc-doc-prts.out-code = b-doc-line.doc-code ON ERROR UNDO, NEXT:
      if rz and loc-doc-prts.fact-qnty <= loc-doc-prts.doc-qnty then NEXT.
      if not rz and loc-doc-prts.doc-qnty = 0 then NEXT.
      if NOT r-b-code = ? AND r-b-code <> loc-doc-prts.b-code then NEXT.
      if NOT r-doc-prts-qnty = ? AND r-doc-prts-qnty <> loc-doc-prts.fact-qnty then NEXT.
      assign
      res-parts = if rz
                  then loc-doc-prts.doc-qnty
                  else (if r-qnty = ?
                        then (- loc-doc-prts.doc-qnty)
                        else r-qnty)
      ser-chg-qnty = if rz
                      then loc-doc-prts.fact-qnty - res-parts
                      else (if r-qnty = ?
                            then (- loc-doc-prts.doc-qnty)
                            else r-qnty)
      res-qnty = res-qnty + ser-chg-qnty
      no-partion-qnty = gds-dtl-res-qnty - res-qnty
      cost-base = 0
      cost-rubl = 0
      .
      if b-trn-doc.status_ = 'нередакт':U
      or b-trn-doc.flag <> no
      then do:
        assign
        v-return-status =  b-trn-doc.status_
        v-return-flag = b-trn-doc.flag
        b-trn-doc.status_ = 'накл':U
        b-trn-doc.flag = no
        v-return-st-fl = yes
        .
      end.
      if not (is-gas(gdscode) and buf_sale-doc.doc-kind <> 'rs':U)
      then do :
        if recid(loc-gds-dtl) <> current-rgds-dtl then assign num_rec = num_rec + 1 current-rgds-dtl = recid(loc-gds-dtl).
      end.
      run trg/rsrv-dtl.p (
                         input parparentproc
                        ,input rsrv-option
                        ,buffer loc-gds-dtl
                        ,input-output ser-chg-qnty
                        ,input-output cost-base
                        ,input-output cost-rubl
                        ,input (if loc-doc-prts.b-code < 0 then ? else loc-doc-prts.b-code)
                        , "" ) no-error.
      if error-status:error then  do:
        v-return-st-fl = no.
        undo _docprts, return error.
      end.
      if v-return-st-fl then do:
        assign
        b-trn-doc.status_ = v-return-status
        b-trn-doc.flag = v-return-flag
        v-return-st-fl = no
        .
      end.
      assign
      chg-qnty = chg-qnty + ser-chg-qnty
      loc-doc-prts.doc-qnty = loc-doc-prts.doc-qnty + ser-chg-qnty
      .
      if r-doc-prts-qnty <> ? and r-b-code = ? then LEAVE.
    END.
    if chg-qnty <> 0 then  do:
      assign
      loc-gds-dtl.doc-qnty = loc-gds-dtl.doc-qnty + chg-qnty
      b-doc-line.doc-qnty = b-doc-line.doc-qnty + chg-qnty
      buf_sale-doc.doc-qnty = buf_sale-doc.doc-qnty  + chg-qnty
      b-trn-doc.doc-qnty = b-trn-doc.doc-qnty  + chg-qnty
      .
      if (loc-gds-dtl.doc-qnty = loc-gds-dtl.fact-qnty and rz) or                           (loc-gds-dtl.doc-qnty = 0 and not  rz)  then do: assign num_rec_res = num_rec_res + 1. end.
      if bottle then do:
assign
  price-rubl-with-tax-loc = b-doc-line.price-rubl
  price-base-with-tax-loc = b-doc-line.price-base
.
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprb
  )  .
   find first in-vatp_doc-attr no-lock
    where in-vatp_doc-attr.doc-code  = b-trn-doc.doc-code
      and in-vatp_doc-attr.attr-code = 'envd':U
    no-error .
    if available in-vatp_doc-attr
       then do:
       assign
         in-vatp-have-vat-slt = no.
   end.
   else do:
     assign
       in-vatp-have-vat-slt = yes.
   end.
   find first in-vatp-goods where in-vatp-goods.artic     = b-doc-line.artic     and
                                     in-vatp-goods.prod-type = b-doc-line.prod-type and
                                     in-vatp-goods.prod-code = b-doc-line.prod-code no-lock.
   if (not b-trn-doc.internal and
           b-trn-doc.doc-type = 'при':U) or
      in-vatp-goods.gds-type = 'у':U then do:
      if varinvprb = "base":u then do:
        assign
          road-tax-base-loc = b-doc-line.road-tax
          road-tax-rubl-loc = b-doc-line.road-tax * b-trn-doc.base-rate / b-trn-doc.base-scale.
      end.
      else do:
        ASSIGN
          road-tax-rubl-loc = b-doc-line.road-tax
          road-tax-base-loc = b-doc-line.road-tax / b-trn-doc.base-rate * b-trn-doc.base-scale.
      end.
      if road-tax-base-loc = ? then road-tax-base-loc = 0.
      if road-tax-rubl-loc = ? then road-tax-rubl-loc = 0.
      assign
        road-tax-cli-loc = ?.
      ASSIGN
        transport-base-loc = (if b-doc-line.transport-base = ? then 0 else b-doc-line.transport-base)
        transport-rubl-loc = (if b-doc-line.transport-rubl = ? then 0 else b-doc-line.transport-rubl)
        transport-cli-loc  = 0
        other-base-loc     = (if b-doc-line.other-base     = ? then 0 else b-doc-line.other-base)
        other-rubl-loc     = (if b-doc-line.other-rubl     = ? then 0 else b-doc-line.other-rubl)
        other-cli-loc      = 0
        vat-pc-loc         = (if b-doc-line.vat-pc         = ? then 0 else b-doc-line.vat-pc)
        slt-pc-loc         = (if b-doc-line.slt-pc         = ? then 0 else b-doc-line.slt-pc).
                              ASSIGN   slt-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
            ASSIGN   slt-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
      assign
        vat-cli-loc            = ?
        slt-cli-loc            = ?
        price-cli-with-tax-loc = ?.
   end.
   else do:
                                                for each in-vatp-parts where in-vatp-parts.out-code  = b-doc-line.doc-code  and
                                      in-vatp-parts.obj-type  = b-doc-line.obj-type  and
                                      in-vatp-parts.obj-code  = b-doc-line.obj-code  and
                                      in-vatp-parts.artic     = b-doc-line.artic     and
                                      in-vatp-parts.prod-type = b-doc-line.prod-type and
                                      in-vatp-parts.prod-code = b-doc-line.prod-code
                         use-index out-code no-lock:
          accumulate  in-vatp-parts.road-tax-base  * in-vatp-parts.fact-qnty (total)
                      in-vatp-parts.road-tax-rubl  * in-vatp-parts.fact-qnty (total)
                      in-vatp-parts.transport-base * in-vatp-parts.fact-qnty (total)
                      in-vatp-parts.transport-rubl * in-vatp-parts.fact-qnty (total)
                      in-vatp-parts.other-base     * in-vatp-parts.fact-qnty (total)
                      in-vatp-parts.other-rubl     * in-vatp-parts.fact-qnty (total)
                                                                                                              (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty                      / (100 + in-vatp-parts.slt-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))  / (100 + in-vatp-parts.vat-pc))  (total)
                                            (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                      / (100 + in-vatp-parts.slt-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))  / (100 + in-vatp-parts.vat-pc))  (total)
                      .
      end.
      ASSIGN
        road-tax-base-loc   = if b-doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.road-tax-base  * in-vatp-parts.fact-qnty) / b-doc-line.fact-qnty  else 0
        road-tax-rubl-loc   = if b-doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.road-tax-rubl  * in-vatp-parts.fact-qnty) / b-doc-line.fact-qnty  else 0
        transport-base-loc  = if b-doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.transport-base * in-vatp-parts.fact-qnty) / b-doc-line.fact-qnty  else 0
        transport-rubl-loc  = if b-doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.transport-rubl * in-vatp-parts.fact-qnty) / b-doc-line.fact-qnty  else 0
        other-base-loc      = if b-doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.other-base     * in-vatp-parts.fact-qnty) / b-doc-line.fact-qnty  else 0
        other-rubl-loc      = if b-doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.other-rubl     * in-vatp-parts.fact-qnty) / b-doc-line.fact-qnty  else 0
                                        vat-base-loc        = if b-doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))) / b-doc-line.fact-qnty   else 0
        slt-base-loc        = if b-doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))) / b-doc-line.fact-qnty   else 0
                vat-rubl-loc        = if b-doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))) / b-doc-line.fact-qnty   else 0
        slt-rubl-loc        = if b-doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))) / b-doc-line.fact-qnty   else 0
        vat-pc-loc          = (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))) / (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))  / (100 + in-vatp-parts.vat-pc)))
        slt-pc-loc          = (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))) / (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                      / (100 + in-vatp-parts.slt-pc))).
      if road-tax-base-loc  = ? then road-tax-base-loc  = 0.
      if road-tax-rubl-loc  = ? then road-tax-rubl-loc  = 0.
      if transport-base-loc = ? then transport-base-loc = 0.
      if transport-rubl-loc = ? then transport-rubl-loc = 0.
      if other-base-loc     = ? then other-base-loc     = 0.
      if other-rubl-loc     = ? then other-rubl-loc     = 0.
      assign
        transport-cli-loc      = 0
        other-cli-loc          = 0
        road-tax-cli-loc       = ?
        vat-cli-loc            = ?
        slt-cli-loc            = ?
        price-cli-with-tax-loc = ?.
   end.
ASSIGN
          price-base-without-tax-loc = price-base-with-tax-loc - vat-base-loc - slt-base-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))
    price-rubl-without-tax-loc = price-rubl-with-tax-loc - vat-rubl-loc - slt-rubl-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))
.
        assign
        b-doc-line.road-tax = (if v-curr-r-b = 'rubl':U then road-tax-rubl-loc else road-tax-base-loc).
      end.
      if rz then do:
        if b-trn-doc.print-rubl
        then assign
          loc-gds-dtl.price-base = loc-gds-dtl.price-rubl / b-trn-doc.base-rate * b-trn-doc.base-scale
          loc-gds-dtl.discnt-base = loc-gds-dtl.discnt-rubl / b-trn-doc.base-rate * b-trn-doc.base-scale
          loc-gds-dtl.discnt-pc = (if loc-gds-dtl.price-rubl = 0
                                   then 0
                                   else loc-gds-dtl.discnt-rubl * 100 / loc-gds-dtl.price-rubl) .
        else
        assign
        loc-gds-dtl.price-rubl = loc-gds-dtl.price-base * b-trn-doc.base-rate / b-trn-doc.base-scale
        loc-gds-dtl.discnt-rubl = loc-gds-dtl.discnt-base * b-trn-doc.base-rate / b-trn-doc.base-scale
        loc-gds-dtl.discnt-pc = (if loc-gds-dtl.price-base = 0
                                 then 0
                                 else loc-gds-dtl.discnt-base * 100 / loc-gds-dtl.price-base ).
      end.
    end.
    if chg-qnty = res-qnty
    then parts-ok = yes.
    else parts-ok = no.
    release loc-gds-dtl.
    if no-partion-qnty = 0 then return.
  end.
  if not cashparts or no-partion-qnty <> 0 or NOT cashplace OR no-place-qnty <> 0 then do:
  if cashplace then no-partion-qnty = no-place-qnty.
  _gdsdtl:
  FOR EACH loc-gds-dtl WHERE
          loc-gds-dtl.doc-code = b-trn-doc.doc-code AND
          loc-gds-dtl.artic = b-doc-line.artic AND
          loc-gds-dtl.prod-type = b-doc-line.prod-type AND
          loc-gds-dtl.prod-code = b-doc-line.prod-code
          EXCLUSIVE-LOCK ON ERROR UNDO, NEXT:
    IF rz AND loc-gds-dtl.fact-qnty <= loc-gds-dtl.doc-qnty then NEXT.
    IF not rz AND loc-gds-dtl.doc-qnty = 0 AND v-is-own then NEXT.
    IF NOT (rgds-dtl = ?) then do:
      if NOT recid(loc-gds-dtl) = rgds-dtl THEN NEXT.
      assign
      r-prt-code = loc-gds-dtl.prt-code.
    end.
if ( num_rec modulo 10 ) = 0 then
run waitfram-show in this-procedure (input substitute("&1 - обработано &2, из них успешно - &3"                                                         , rsrv-title                                                                 , num_rec                                                                    , num_rec_res) ).
    assign
    res-qnty = if cashparts
                then (if rz
                      then no-partion-qnty
                      else (if r-qnty = ?
                            then (- loc-gds-dtl.doc-qnty)
                            else no-partion-qnty)
                      )
                else (if rz
                      then (loc-gds-dtl.fact-qnty - loc-gds-dtl.doc-qnty)
                      else (if r-qnty = ?
                            then (- loc-gds-dtl.doc-qnty)
                            else r-qnty
                            )
                      )
    chg-qnty = res-qnty
    cost-base = 0
    cost-rubl = 0 .
    if not v-is-own and rz then do:
      find first buf_tt0-gds-dtl no-lock where
                buf_tt0-gds-dtl.artic     = loc-gds-dtl.artic
            AND buf_tt0-gds-dtl.prod-type = loc-gds-dtl.prod-type
            AND buf_tt0-gds-dtl.prod-code = loc-gds-dtl.prod-code
            AND buf_tt0-gds-dtl.prt-code = loc-gds-dtl.prt-code no-error .
      if available buf_tt0-gds-dtl then do:
        assign
        chg-qnty = chg-qnty - buf_tt0-gds-dtl.doc-qnty.
      end.
    end.
    if not v-is-own and not rz and chg-qnty = 0 then
    assign
    v-to-reserv = no
    .
    if not v-is-own
    and rz
    and (available buf_tt0-gds-dtl and (buf_tt0-gds-dtl.doc-qnty + loc-gds-dtl.doc-qnty) = loc-gds-dtl.fact-qnty)
    then
    assign
    v-to-reserv = no
    .
    if p-auto-fbr-on
    then do :
      find first goods no-lock where goods.artic = loc-gds-dtl.artic
                                 and goods.prod-type = loc-gds-dtl.prod-type
                                 and goods.prod-code = loc-gds-dtl.prod-code
                                 .
      if b-trn-doc.ext-doc-type =  'rs':U
      then do :
        find first buf_doc-fbr-gds no-lock where buf_doc-fbr-gds.out-code = replace(loc-gds-dtl.doc-code, "=", "-")
                                             and buf_doc-fbr-gds.gds-code = goods.gds-code
                                             no-error .
        if available buf_doc-fbr-gds
        then do :
          if buf_doc-fbr-gds.fact-qnty > 0
          then do :
            assign
              v-to-reserv = no
            .
          end.
          else do :
            chg-qnty = if res-qnty >= 0 then abs(buf_doc-fbr-gds.fact-qnty) else buf_doc-fbr-gds.fact-qnty.
          end.
        end.
      end.
      if b-trn-doc.ext-doc-type =  'es':U
      then do :
        find first buf_doc-fbr-gds no-lock where buf_doc-fbr-gds.out-code = loc-gds-dtl.doc-code
                                             and buf_doc-fbr-gds.gds-code = goods.gds-code
                                             no-error .
        if available buf_doc-fbr-gds
        then do :
          if buf_doc-fbr-gds.fact-qnty >= 0
          then do :
            chg-qnty = if res-qnty >= 0 then buf_doc-fbr-gds.fact-qnty else - buf_doc-fbr-gds.fact-qnty .
          end.
          else do :
            assign
              v-to-reserv = no
            .
          end.
        end.
      end.
    end.
    if v-to-reserv and chg-qnty <> 0 then do:
      if b-trn-doc.status_ = 'нередакт':U
      or b-trn-doc.flag <> no
      then do:
        assign
        v-return-status =  b-trn-doc.status_
        v-return-flag = b-trn-doc.flag
        b-trn-doc.status_ = 'накл':U
        b-trn-doc.flag = no
        v-return-st-fl = yes
        .
      end.
      if not (is-gas(gdscode) and buf_sale-doc.doc-kind <> 'rs':U)
      then do :
        if recid(loc-gds-dtl) <> current-rgds-dtl then assign num_rec = num_rec + 1 current-rgds-dtl = recid(loc-gds-dtl).
      end.
      run trg/rsrv-dtl.p (
                       input parparentproc
                      ,input rsrv-option
                      ,buffer loc-gds-dtl
                      ,input-output chg-qnty
                      ,input-output cost-base
                      ,input-output cost-rubl
                      , -1
                      , "" ) no-error.
      if error-status:error then  do:
        v-return-st-fl = no.
        undo _gdsdtl, return error.
      end.
    if v-return-st-fl then do:
      assign
      b-trn-doc.status_ = v-return-status
      b-trn-doc.flag = v-return-flag
      v-return-st-fl = no
      .
    end.
      if cashfbr then do:
        assign
        fbr-qnty = chg-qnty
        .
        _fbr:
        for each loc-doc-fbr-gds where
                loc-doc-fbr-gds.gds-code = gdscode:
          assign
          fbr-chg-qnty = min(loc-doc-fbr-gds.fact-qnty - loc-doc-fbr-gds.doc-qnty, fbr-qnty)
          fbr-qnty = fbr-qnty - fbr-chg-qnty
          loc-doc-fbr-gds.doc-qnty = loc-doc-fbr-gds.doc-qnty + fbr-chg-qnty
          .
          if fbr-qnty = 0 then do:
              leave _fbR.
          end.
        end.
      end.
      assign
      loc-gds-dtl.doc-qnty = loc-gds-dtl.doc-qnty + chg-qnty
      b-doc-line.doc-qnty = b-doc-line.doc-qnty + chg-qnty
      buf_sale-doc.doc-qnty = buf_sale-doc.doc-qnty  + chg-qnty
      b-trn-doc.doc-qnty = b-trn-doc.doc-qnty  + chg-qnty
      .
      if available buf_doc-fbr-gds
      then do :
        if rz then do :
          if buf_doc-fbr-gds.fact-qnty > 0
          then do :
            if loc-gds-dtl.doc-qnty = buf_doc-fbr-gds.fact-qnty then assign num_rec_res = num_rec_res + 1 .
          end.
          else
          if buf_doc-fbr-gds.fact-qnty < 0
          then do :
            if loc-gds-dtl.doc-qnty = - buf_doc-fbr-gds.fact-qnty then assign num_rec_res = num_rec_res + 1 .
          end.
          else do :
            if (loc-gds-dtl.doc-qnty = loc-gds-dtl.fact-qnty and rz) or                           (loc-gds-dtl.doc-qnty = 0 and not  rz)  then do: assign num_rec_res = num_rec_res + 1. end.
          end.
        end.
        else do :
          if loc-gds-dtl.doc-qnty = 0 then assign num_rec_res = num_rec_res + 1 .
        end.
      end.
      else do :
        if (loc-gds-dtl.doc-qnty = loc-gds-dtl.fact-qnty and rz) or                           (loc-gds-dtl.doc-qnty = 0 and not  rz)  then do: assign num_rec_res = num_rec_res + 1. end.
      end.
      if bottle then do:
assign
  price-rubl-with-tax-loc = b-doc-line.price-rubl
  price-base-with-tax-loc = b-doc-line.price-base
.
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprb
  )  .
   find first in-vatp_doc-attr no-lock
    where in-vatp_doc-attr.doc-code  = b-trn-doc.doc-code
      and in-vatp_doc-attr.attr-code = 'envd':U
    no-error .
    if available in-vatp_doc-attr
       then do:
       assign
         in-vatp-have-vat-slt = no.
   end.
   else do:
     assign
       in-vatp-have-vat-slt = yes.
   end.
   find first in-vatp-goods where in-vatp-goods.artic     = b-doc-line.artic     and
                                     in-vatp-goods.prod-type = b-doc-line.prod-type and
                                     in-vatp-goods.prod-code = b-doc-line.prod-code no-lock.
   if (not b-trn-doc.internal and
           b-trn-doc.doc-type = 'при':U) or
      in-vatp-goods.gds-type = 'у':U then do:
      if varinvprb = "base":u then do:
        assign
          road-tax-base-loc = b-doc-line.road-tax
          road-tax-rubl-loc = b-doc-line.road-tax * b-trn-doc.base-rate / b-trn-doc.base-scale.
      end.
      else do:
        ASSIGN
          road-tax-rubl-loc = b-doc-line.road-tax
          road-tax-base-loc = b-doc-line.road-tax / b-trn-doc.base-rate * b-trn-doc.base-scale.
      end.
      if road-tax-base-loc = ? then road-tax-base-loc = 0.
      if road-tax-rubl-loc = ? then road-tax-rubl-loc = 0.
      assign
        road-tax-cli-loc = ?.
      ASSIGN
        transport-base-loc = (if b-doc-line.transport-base = ? then 0 else b-doc-line.transport-base)
        transport-rubl-loc = (if b-doc-line.transport-rubl = ? then 0 else b-doc-line.transport-rubl)
        transport-cli-loc  = 0
        other-base-loc     = (if b-doc-line.other-base     = ? then 0 else b-doc-line.other-base)
        other-rubl-loc     = (if b-doc-line.other-rubl     = ? then 0 else b-doc-line.other-rubl)
        other-cli-loc      = 0
        vat-pc-loc         = (if b-doc-line.vat-pc         = ? then 0 else b-doc-line.vat-pc)
        slt-pc-loc         = (if b-doc-line.slt-pc         = ? then 0 else b-doc-line.slt-pc).
                              ASSIGN   slt-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
            ASSIGN   slt-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
      assign
        vat-cli-loc            = ?
        slt-cli-loc            = ?
        price-cli-with-tax-loc = ?.
   end.
   else do:
                                                for each in-vatp-parts where in-vatp-parts.out-code  = b-doc-line.doc-code  and
                                      in-vatp-parts.obj-type  = b-doc-line.obj-type  and
                                      in-vatp-parts.obj-code  = b-doc-line.obj-code  and
                                      in-vatp-parts.artic     = b-doc-line.artic     and
                                      in-vatp-parts.prod-type = b-doc-line.prod-type and
                                      in-vatp-parts.prod-code = b-doc-line.prod-code
                         use-index out-code no-lock:
          accumulate  in-vatp-parts.road-tax-base  * in-vatp-parts.fact-qnty (total)
                      in-vatp-parts.road-tax-rubl  * in-vatp-parts.fact-qnty (total)
                      in-vatp-parts.transport-base * in-vatp-parts.fact-qnty (total)
                      in-vatp-parts.transport-rubl * in-vatp-parts.fact-qnty (total)
                      in-vatp-parts.other-base     * in-vatp-parts.fact-qnty (total)
                      in-vatp-parts.other-rubl     * in-vatp-parts.fact-qnty (total)
                                                                                                              (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty                      / (100 + in-vatp-parts.slt-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))  / (100 + in-vatp-parts.vat-pc))  (total)
                                            (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                      / (100 + in-vatp-parts.slt-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))  / (100 + in-vatp-parts.vat-pc))  (total)
                      .
      end.
      ASSIGN
        road-tax-base-loc   = if b-doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.road-tax-base  * in-vatp-parts.fact-qnty) / b-doc-line.fact-qnty  else 0
        road-tax-rubl-loc   = if b-doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.road-tax-rubl  * in-vatp-parts.fact-qnty) / b-doc-line.fact-qnty  else 0
        transport-base-loc  = if b-doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.transport-base * in-vatp-parts.fact-qnty) / b-doc-line.fact-qnty  else 0
        transport-rubl-loc  = if b-doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.transport-rubl * in-vatp-parts.fact-qnty) / b-doc-line.fact-qnty  else 0
        other-base-loc      = if b-doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.other-base     * in-vatp-parts.fact-qnty) / b-doc-line.fact-qnty  else 0
        other-rubl-loc      = if b-doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.other-rubl     * in-vatp-parts.fact-qnty) / b-doc-line.fact-qnty  else 0
                                        vat-base-loc        = if b-doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))) / b-doc-line.fact-qnty   else 0
        slt-base-loc        = if b-doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))) / b-doc-line.fact-qnty   else 0
                vat-rubl-loc        = if b-doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))) / b-doc-line.fact-qnty   else 0
        slt-rubl-loc        = if b-doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))) / b-doc-line.fact-qnty   else 0
        vat-pc-loc          = (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))) / (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))  / (100 + in-vatp-parts.vat-pc)))
        slt-pc-loc          = (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))) / (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                      / (100 + in-vatp-parts.slt-pc))).
      if road-tax-base-loc  = ? then road-tax-base-loc  = 0.
      if road-tax-rubl-loc  = ? then road-tax-rubl-loc  = 0.
      if transport-base-loc = ? then transport-base-loc = 0.
      if transport-rubl-loc = ? then transport-rubl-loc = 0.
      if other-base-loc     = ? then other-base-loc     = 0.
      if other-rubl-loc     = ? then other-rubl-loc     = 0.
      assign
        transport-cli-loc      = 0
        other-cli-loc          = 0
        road-tax-cli-loc       = ?
        vat-cli-loc            = ?
        slt-cli-loc            = ?
        price-cli-with-tax-loc = ?.
   end.
ASSIGN
          price-base-without-tax-loc = price-base-with-tax-loc - vat-base-loc - slt-base-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))
    price-rubl-without-tax-loc = price-rubl-with-tax-loc - vat-rubl-loc - slt-rubl-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))
.
        assign
        b-doc-line.road-tax = (if v-curr-r-b = 'rubl':U
                                then road-tax-rubl-loc
                                else road-tax-base-loc).
      end.
      if rz then do:
        if b-trn-doc.print-rubl
        then assign
              loc-gds-dtl.price-base = loc-gds-dtl.price-rubl / b-trn-doc.base-rate * b-trn-doc.base-scale
              loc-gds-dtl.discnt-base = loc-gds-dtl.discnt-rubl / b-trn-doc.base-rate * b-trn-doc.base-scale
              loc-gds-dtl.discnt-pc = (if loc-gds-dtl.price-rubl = 0
                                       then 0
                                       else loc-gds-dtl.discnt-rubl * 100 / loc-gds-dtl.price-rubl) .
        else assign
            loc-gds-dtl.price-rubl = loc-gds-dtl.price-base * b-trn-doc.base-rate / b-trn-doc.base-scale
            loc-gds-dtl.discnt-rubl = loc-gds-dtl.discnt-base * b-trn-doc.base-rate / b-trn-doc.base-scale
            loc-gds-dtl.discnt-pc = (if loc-gds-dtl.price-base = 0
                                    then 0
                                    else loc-gds-dtl.discnt-base * 100 / loc-gds-dtl.price-base) .
      end.
      if (not v-is-own and res-qnty = 0)
      or (not rz and (loc-gds-dtl.doc-qnty = 0  and res-qnty = 0) and p-tpsi-obj)
        then do:
      end.
      if chg-qnty = res-qnty and chg-qnty <> 0
      AND parts-OK
      AND (v-is-own
          OR ((not v-is-own)
              and v-to-reserv
              and (
                   ((loc-gds-dtl.doc-qnty = loc-gds-dtl.fact-qnty) and (rz))
                   OR
                   (not rz  and (loc-gds-dtl.doc-qnty = 0))
                  )
             )
          )
      then .
    end.
    if not v-is-own then do:
      if cashparts
      or cashplace
      or (chg-qnty = res-qnty
        and  ((loc-gds-dtl.doc-qnty = loc-gds-dtl.fact-qnty) and (rz))
          )
      then do:
        p-run-tpsi = no.
      end.
      else do:
        run create-tt0-doc-line-gds-dtl(
                                         input v-proprietor-obj-type
                                        ,input v-proprietor-obj-code
                                        ,input v-ext-doc-type
                                        ,input (if available tpsi_sale-doc then tpsi_sale-doc.doc-code else "":U)
                                        ,input  b-doc-line.artic
                                        ,input  b-doc-line.prod-type
                                        ,input  b-doc-line.prod-code
                                        ,input  loc-gds-dtl.prt-code
                                        ,input  (if rz
                                                  then (loc-gds-dtl.fact-qnty - loc-gds-dtl.doc-qnty)
                                                  else
                                                  (if r-qnty = ?
                                                  then ?
                                                  else r-qnty
                                                  )
                                                 )
                                        ,output v-was-gds-dtl-doc-qnty
                                        ,output v-gds-dtl-fact-qnty
                                        ,buffer b-doc-line
                                        ,buffer loc-gds-dtl
                                        ,buffer tpsi_sale-doc
                                        ).
        if not v-is-own and p-r-v > 0 and v-gds-dtl-fact-qnty <> 0 then do:
          if not (is-gas(gdscode) and buf_sale-doc.doc-kind <> 'rs':U)
          then do :
            if recid(loc-gds-dtl) <> current-rgds-dtl then assign num_rec = num_rec + 1 current-rgds-dtl = recid(loc-gds-dtl).
          end.
          run write-tt0-info in this-procedure (
                                                input b-doc-line.artic
                                              ,input b-doc-line.prod-type
                                              ,input b-doc-line.prod-code
                                              ,input loc-gds-dtl.prt-code
                                              ,input v-proprietor-obj-type
                                              ,input v-proprietor-obj-code
                                              ,input (if available tpsi_sale-doc then tpsi_sale-doc.doc-code else "":U)
                                              ,input no
                                              ,input loc-gds-dtl.fact-qnty
                                              ,input loc-gds-dtl.doc-qnty
                                              ,input ?
                                              ,input loc-gds-dtl.fact-qnty
                                              ,input v-was-gds-dtl-doc-qnty
                                              ,input v-gds-dtl-fact-qnty
                                              ,input v-was-gds-dtl-doc-qnty
                                              ,input '':u).
        end.
        if v-gds-dtl-fact-qnty = 0 then do:
            p-run-tpsi = no.
        end.
      end.
    end.
  END.
end.
END.
do
on error undo, return error return-value
:
  assign
  r-qnty = ?.
  rsrv-title = substitute("Снятие резервов со всех товаров чека &1. Строк ", X_chk-doc.doc-code)
  .
  FIND FIRST ub.inkas WHERE ub.inkas.inkas-code = X_chk-doc.out-code NO-LOCK NO-ERROR.
  if not avail ub.inkas then do:
      message
      substitute("Ошибка! Чек &1 привязан к отсутствующему отчету о продаже!", X_chk-doc.doc-code)
      view-as alert-box ERROR.
      return error.
  end.
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  ub.inkas.obj-type
  ,input  ub.inkas.obj-code
  ,output v-host-code
  )  .
  run get-inkas-ps in this-procedure (
                                        buffer inkas
                                      , output chk-amount
                                      , output gds-amount
                                      , output line-out
                                      , output dtl-out
                                      , output line-ret
                                      , output dtl-ret
                                      , output nf-chk-amount
                                      , output nf-gds-amount
                                      , output p-filter-rus
                                      ).
  FIND FIRST buf0_trn-doc exclusive-lock WHERE
           buf0_trn-doc.doc-code = X_chk-doc.out-code no-wait NO-ERROR.
  if not avail buf0_trn-doc then do:
      message
      substitute("Не найдена или не занята накладная &1!", X_chk-doc.out-code)  view-as alert-box ERROR.
      undo, return error.
  end.
  assign
  v-base-rate = buf0_trn-doc.base-rate
  v-base-scale = buf0_trn-doc.base-scale
  .
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output v-curr-r-b
  )  .
  docs-to-reserv = get-inc-sal(string(X_chk-doc.chk-type)
                              , input X_chk-doc.netto
                              , input yes
                              , input X_chk-doc.office
                              , input ?
                              , output v-add
                              , output office-to-reserv
                              , output kind-to-reserv
                              , output add-nf-amount
                              ).
  v-cash-pay-attr = "".
  cli-type-to-reserv = "".
  cli-code-to-reserv = 0.
  if X_chk-doc.chk-type = integer('17':U) then do:
      for each buf_chk-pay where buf_chk-pay.doc-code = X_chk-doc.doc-code no-lock:
          find first buf_cash-pay-attr where buf_cash-pay-attr.cdpay-code = buf_chk-pay.pay-code
                                       and buf_cash-pay-attr.curr-code = buf_chk-pay.curr-code
                                       and buf_cash-pay-attr.attr-code = "dop-doc" no-lock no-error.
          if not available(buf_cash-pay-attr) then next.
          v-cash-pay-attr = buf_cash-pay-attr.attr-value.
          case entry(1, v-cash-pay-attr, ','):
              when 'swo':U then do:
                  v-add = no.
                  docs-to-reserv = 1.
                  office-to-reserv = 'т':U.
                  kind-to-reserv = entry(1, v-cash-pay-attr, ',').
                  cli-type-to-reserv = entry(2, v-cash-pay-attr, ',').
                  cli-code-to-reserv = int(entry(3, v-cash-pay-attr, ',')).
              end.
              when 'trf':U then do:
                  cli-type-to-reserv = entry(2, v-cash-pay-attr, ',').
                  cli-code-to-reserv = int(entry(3, v-cash-pay-attr, ',')).
              end.
              when 'vir':U then do:
                  kind-to-reserv = 'vir':U.
                  cli-type-to-reserv = entry(2, v-cash-pay-attr, ',').
                  cli-code-to-reserv = int(entry(3, v-cash-pay-attr, ',')).
              end.
              when 'none' then do:
                  docs-to-reserv = 0.
                  kind-to-reserv = 'none'.
              end.
          end case.
      end.
  end.
  assign
  v-is-tpsi-obj = can-find(first tpsi_sale-doc no-lock where
                                tpsi_sale-doc.inkas-code = X_chk-doc.out-code
                            and tpsi_sale-doc.tpsidoc = yes).
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
empty temp-table thbjattr_thbj-attr.
run adm/shattri.p (
   input "get":U
  ,input ''
  ,input 0
  ,input 'nakl_par':U
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
      if thbjattr_thbj-attr.prop-code = 'factorrt' then factorrt = thbjattr_thbj-attr.property-value-integer .
  end.
  run adm/shattri.p (
      input "get":U
      ,input  inkas.obj-type
      ,input  inkas.obj-code
      ,input  'autosale':U
      ,input  'prcl-spl':U
      , output v-value-character
      , output v-value-date
      , output v-value-decimal
      , output v-value-integer
      , output v-value-logical
      , output par-type
      , INPUT-OUTPUT table-handle v-tth
      ) no-error .
  IF not error-status:error then
  assign
  prcl-spl = v-value-logical.
  delete object v-tth.
  btltaxcd = integer('3':U).
  for each buf_sale-doc where
          buf_Sale-doc.inkas-code = inkas.inkas-code
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  :
    buf_sale-doc.chk-doc-code = '':U.
  end.
  _chk-gds:
  for each buf_chk-gds NO-LOCK WHERE buf_chk-gds.doc-code = X_chk-doc.doc-code
  on error undo, return error error-status:get-message(1) :
    assign
    docs-to-reserv-gds = 0
    kind-to-reserv-gds = '':U
    office-to-reserv-gds = '':U
    add-nf-gds-amount  = 0
    v-add = no
    .
    if buf_chk-gds.doc-qnty = 0 then do:
      gds-amount = gds-amount  - 1.
      nf-gds-amount = nf-gds-amount + (if lookup(string(X_chk-doc.chk-type) ,'14,15,16,36,8,101,106,108,11,12,13,40,169,196,114,115,116,117,111,112,136,113,201,206,208,301,306,2,3,4,5,7,43,44':U) > 0
                                        then - 1
                                        else 0).
      next _chk-gds.
    end.
    docs-to-reserv-gds = get-inc-sal(string(X_chk-doc.chk-type)
                                , input X_chk-doc.netto
                                , input no
                                , input entry(1, buf_chk-gds.line-type, chr(4))
                                , input string(BUF_CHK-GDS.WRITE-OFF-CODE)
                                , output v-add
                                , output office-to-reserv-gds
                                , output kind-to-reserv-GDS
                                , output add-nf-gds-amount
                                ).
    if X_chk-doc.chk-type = integer('17':U) then do:
        for each buf_chk-pay where buf_chk-pay.doc-code = X_chk-doc.doc-code no-lock:
            find first buf_cash-pay-attr where buf_cash-pay-attr.cdpay-code = buf_chk-pay.pay-code
                                         and buf_cash-pay-attr.curr-code = buf_chk-pay.curr-code
                                         and buf_cash-pay-attr.attr-code = "dop-doc" no-lock no-error.
            if not available(buf_cash-pay-attr) then next.
            v-cash-pay-attr = buf_cash-pay-attr.attr-value.
            case entry(1, v-cash-pay-attr, ','):
                when 'vir':U then do:
                    assign
                    kind-to-reserv-gds = 'vir':U
                    docs-to-reserv-gds = 1
                    v-add = no
                    office-TO-RESERV-GDS = 'т'.
                end.
                when 'none' then do:
                    assign
                    kind-to-reserv-gds = 'none'
                    docs-to-reserv-gds = 0
                    v-add = no
                    office-TO-RESERV-GDS = 'т'.
                end.
             end case.
        end.
    end.
    gds-amount = gds-amount - 1.
    nf-gds-amount = nf-gds-amount  - add-nf-gds-amount.
    assign
    office-to-reserv-gds = (if v-add
                          then (office-to-reserv + (if kind-to-reserv-gds = '':u
                                                  then '':u
                                                  else chr(44)) +
                               office-to-reserv-gds)
                         else  office-to-reserv-gds)
    kind-to-reserv-gds = (if v-add
                          then (kind-to-reserv + (if kind-to-reserv-gds = '':u
                                                  then '':u
                                                  else chr(44)) +
                               kind-to-reserv-gds)
                         else  kind-to-reserv-gds)
    docs-to-reserv-gds = (if v-add
                          then (docs-to-reserv  + docs-to-reserv-gds)
                          else docs-to-reserv-gds)
    .
    if docs-to-reserv-gds <> 0 then dO:
      FIND FIRST ub.bar-code No-LOCK WHERE
                ub.bar-code.b-code = buf_chk-gds.b-code No-ERROR.
      IF NOT AVAIL bar-code then do:
        message
        substitute("Ошибки в строке чека &1 - товар с кодом &2 отсутствует в базе!"
                   , X_chk-doc.doc-code
                   , buf_chk-gds.b-code)
        view-as alert-box ERROR.
        run waitfram-hide in this-procedure .
        undo, return error.
      END.
      FIND FIRST ub.goods NO-LOCK WHERE
                  ub.goods.gds-code = ub.bar-code.gds-code NO-ERROR.
      FIND FIRST ub.units No-LOCK WHERE
                  ub.units.unit-name = ub.goods.unit-base NO-ERROR.
      IF NOT AVAIL(goods) then do:
        message "Не найден товар!" view-as alert-box ERROR.
        run waitfram-hide in this-procedure .
        undo, return error.
      end.
      IF NOT AVAIL(ub.units) then do:
        message "Не найдена единица измерения!" view-as alert-box ERROR.
        run waitfram-hide in this-procedure .
        undo, return error.
      end.
      if can-find(first ub.tax-units where
                        ub.tax-units.tax-code = btltaxcd AND
                        LOOKUP(ub.tax-units.type, units.type) > 0 ) then  do:
        assign
        bottle = yes.
      end.
      else do:
        bottle = no.
      end.
      _dtrg-gds:
      do dtrg = 1 to docs-to-reserv-gds:
        if entry(dtrg, office-to-reserv-gds) <> entry(1, buf_chk-gds.line-type, chr(4)) then next _dtrg-gds.
        find first buf_sale-doc where
                  buf_Sale-doc.inkas-code = inkas.inkas-code
              and buf_sale-doc.doc-kind = entry(dtrg, kind-to-reserv-gds)
              and buf_sale-doc.chr-office = entry(dtrg, office-to-reserv-gds)
              .
        if dtrg <= docs-to-reserv
        and X_chk-doc.doc-code <> buf_sale-doc.chk-doc-code then do:
          assign
          buf_sale-doc.chk-doc-code = X_chk-doc.doc-code
          buf_sale-doc.chk-amount = buf_sale-doc.chk-amount - 1
          .
        end.
        find first buf_doc-line nO-lock where
                  buf_doc-line.doc-code = buf_sale-doc.doc-code
             AND  buf_doc-line.artic = goods.artic
             AND  buf_doc-line.prod-type = goods.prod-type
             AND  buf_doc-line.prod-code = goods.prod-code No-ERROR.
        if not avail buf_doc-line then NEXT.
        FIND FIRST buf_gds-dtl WHERE
                  buf_gds-dtl.doc-code = buf_sale-doc.doc-code
             AND  buf_gds-dtl.artic = goods.artic
             AND  buf_gds-dtl.prod-code = goods.prod-code
             AND  buf_gds-dtl.prod-type = goods.prod-type
             AND  buf_gds-dtl.prt-code = bar-code.node-code NO-ERROR.
        if not avail buf_gds-dtl then NEXT.
        for-price = 0.
        assign
        plcode = ?
        cashplace = no.
        if buf_chk-gds.pump > 0 then do:
          if buf_chk-gds.pl-code <> 0
          and buf_chk-gds.pl-code <> ? then do:
            plcode = buf_chk-gds.pl-code.
          end.
          else do:
            run findtank in this-procedure
                            (input  inkas.obj-type,
                              input  inkas.obj-code,
                              input  buf_chk-gds.pump,
                              input  buf_chk-gds.nozzle-code,
                              input  buf_chk-gds.pl-code,
                              input  goods.gds-code,
                              output plcode         ) no-error.
          end.
          assign
          pumpcode = buf_chk-gds.pump.
          if plcode <> ? then do:
            FIND FIRST ub.doc-pl No-LOCK WHERE
                      ub.doc-pl.gds-code = ub.goods.gds-code
                 AND  ub.doc-pl.out-code = buf_sale-doc.doc-code NO-ERROR.
            IF AVAIL ub.doc-pl
            then
            cashplace = yes .
            else cashplace = no.
          end.
        end.
        else pumpcode = 0.
        if not cashplace then do:
          two-units-parts = no.
          IF lookup('2ед':U, ub.units.type) > 0 then do:
          FIND FIRST ub.doc-prts No-LOCK WHERE
                    ub.doc-prts.gds-code = ub.goods.gds-code
               AND  ub.doc-prts.out-code = buf_sale-doc.doc-code
               AND  ub.doc-prts.fact-qnty = abs(buf_chk-gds.doc-qnty) NO-ERROR.
             assign
             two-units-parts = yes.
          end.
          else do:
          FIND FIRST ub.doc-prts No-LOCK WHERE
                    ub.doc-prts.b-code = buf_chk-gds.b-code
                AND ub.doc-prts.out-code = buf_sale-doc.doc-code NO-ERROR.
          end.
          IF ub.bar-code.in-code <> "" OR AVAIL ub.doc-prts
          then cashparts = yes.
          else cashparts = no.
          release doc-prts.
        end.
        else cashparts = no.
        if NOT two-units-parts then
        find first t-gds WHERE
                  t-gds.doc-code = buf_sale-doc.doc-code
             AND  t-gds.b-code = buf_chk-gds.b-code
             AND  t-gds.artic = ub.goods.artic
             AND  t-gds.prod-type = ub.goods.prod-type
             AND  t-gds.prod-code = ub.goods.prod-code
             AND  t-gds.node-code = ub.bar-code.node-code
             AND  t-gds.pl-code = plcode
             AND  t-gds.pump = pumpcode
             AND  t-gds.fbr-obj-type = buf_chk-gds.depart-type
             AND  t-gds.fbr-obj-code = buf_chk-gds.depart-code NO-ERROR.
        IF NOT AVAIL t-gds oR two-units-parts then do:
          if not prcl-spl then do:
            IF avail buf_gds-dtl
            AND ((p-curr-r-b = 'base':U and buf_gds-dtl.price-base <> buf_chk-gds.price-base )
                OR
                (p-curr-r-b = 'rubl':U and buf_gds-dtl.price-rubl <> buf_chk-gds.price-base )
                )
            then  for-price = (if p-curr-r-b = 'base':U
                              then buf_gds-dtl.price-base
                              else buf_gds-dtl.price-rubl)
                              .
            else do:
              if cashparts then dO:
                FOR EACH buf-bar No-LOCK WHERE
                        buf-bar.gds-code = goods.gds-code,
                    EACH for-gds NO-LOCK where
                        for-gds.b-code = buf-bar.b-code AND
                        for-gds.out-code = X_chk-doc.out-code AND
                        NOT for-gds.doc-code = X_chk-doc.doc-code
                        BY for-gds.doc-code DESCENDING:
                  if (buf_chk-gds.price-base + buf_chk-gds.price-service) > 0 AND
                    (for-gds.price-base + for-gds.price-service) = 0 AND
                    can-find(first for2-gds WHERE
                                    for2-gds.b-code = buf_chk-gds.b-code AND
                                    for2-gds.out-code = buf_chk-gds.out-code AND
                                    for2-gds.doc-code <> buf_chk-gds.doc-code AND
                                    for2-gds.doc-code <> for-gds.doc-code)
                  then NEXT.
                  LEAVE.
                END.
                if avail for-gds then
                for-price = for-gds.price-base.
              end.
              else do:
                FOR each for-gds no-lock where
                                for-gds.out-code = X_chk-doc.out-code and
                                for-gds.b-code = bar-code.b-code AND
                                NOT for-gds.doc-code = X_chk-doc.doc-code
                        BY  for-gds.doc-code DESCENDING:
                            if (buf_chk-gds.price-base + buf_chk-gds.price-service) > 0 AND
                              (for-gds.price-base + for-gds.price-service) = 0 AND
                              can-find(first for2-gds WHERE
                                              for2-gds.b-code = buf_chk-gds.b-code AND
                                              for2-gds.out-code = buf_chk-gds.out-code AND
                                              for2-gds.doc-code <> buf_chk-gds.doc-code AND
                                              for2-gds.doc-code <> for-gds.doc-code)
                              then NEXT.
                  LEAVE.
                END.
                if avail for-gds then
                for-price = for-gds.price-base.
              end.
            end.
          end.
          if not avail t-gds OR (LOOKUP('2ед':U, units.type) > 0 ) then do:
            create t-gds.
            assign
            t-gds.doc-code = buf_sale-doc.doc-code
            t-gds.b-code = buf_chk-gds.b-code
            t-gds.gds-code = goods.gds-code
            t-gds.artic = goods.artic
            t-gds.prod-type = goods.prod-type
            t-gds.prod-code = goods.prod-code
            t-gds.unit-base = goods.unit-base
            t-gds.cashparts = cashparts
            t-gds.cashplace = cashplace
            t-gds.pl-code  = plcode
            t-gds.density = buf_chk-gds.density
            t-gds.pump = pumpcode
            t-gds.fbr-obj-type = buf_chk-gds.depart-type
            t-gds.fbr-obj-code = buf_chk-gds.depart-code
            t-gds.doc-qnty = 0
            t-gds.price-service = buf_chk-gds.price-service
            t-gds.node-code = bar-code.node-code
            t-gds.new-price = for-price
            t-gds.rdoc-line = recid(buf_doc-line)
            t-gds.rgds-dtl = recid(buf_gds-dtl)
            t-gds.type = units.type
            t-gds.grc = (if LOOKUP('2ед':U, units.type) > 0 then recid(buf_chk-gds) else ?)
            t-gds.marks = ''
            .
          end.
          if t-gds.pump > 0
          and (t-gds.density = ? or t-gds.density = 0) then do:
            message substitute("Чек &1 Бар-код &2 ТРК &3&4Не удается определить плотность топлива в танке&4&5&4Чек не будет закачан в продажу"
                            , X_chk-doc.doc-code
                            , t-gds.b-code
                            , t-gds.pump
                            , chr(10)
                            , return-value
                            )
            view-as alert-box error .
            run waitfram-hide in this-procedure .
            undo, return error.
          end.
        end.
        assign
        t-gds.doc-qnty = t-gds.doc-qnty + buf_chk-gds.doc-qnty
        t-gds.num-lines = t-gds.num-lines + 1
        t-gds.price-base = buf_chk-gds.price-base + buf_chk-gds.price-service
        t-gds.discnt = (if buf_sale-doc.doc-type = 'спи':U then 0 else buf_chk-gds.discnt)
        t-gds.price-sum = t-gds.price-sum + (buf_chk-gds.price-base + buf_chk-gds.price-service ) * buf_chk-gds.doc-qnty
        t-gds.discnt-sum  = t-gds.discnt-sum +
                            (if buf_sale-doc.doc-type = 'спи':U
                            then 0
                            else buf_chk-gds.discnt * buf_chk-gds.doc-qnty)
        t-gds.road-sum = t-gds.road-sum + buf_chk-gds.road-tax * buf_chk-gds.doc-qnty
        .
        run gds-attr-value(
                t-gds.gds-code,
                'mark':U,
                output par-alcohol,
                output par-type
          ).
        if par-alcohol = "yes" then do :
            find first chk-gds-attr no-lock where chk-gds-attr.doc-code = buf_chk-gds.doc-code
                                              and chk-gds-attr.line-num = buf_chk-gds.line-num
                                              and chk-gds-attr.attr-code = "mark-code"
                                              no-error .
            if available chk-gds-attr
            then do :
              t-gds.marks = t-gds.marks + (if t-gds.marks = '' then '' else ',') + chk-gds-attr.attr-value .
            end.
            release chk-gds-attr no-error .
        end.
      end.
    end.
    release t-gds.
  END.
  for each tt0-info:
    delete tt0-info.
  end.
  f-del:
  DO on ERROR undo, return error
  on STOP undo, return error :
    if docs-to-reserv > 0 then do:
      run waitfram-show in this-procedure ( substitute("Снимаю резервы со всех товаров чека &1...", X_chk-doc.doc-code)).
    _main:
      FOR EACH t-gds NO-LOCK,
          first buf_sale-doc where
               buf_sale-doc.inkas-code = inkas.inkas-code
           and buf_sale-doc.doc-code = t-gds.doc-code,
          first buf_trn-doc where
               buf_trn-doc.doc-code = buf_sale-doc.doc-code
    on ERROR undo f-del, return error
    on STOP undo f-del, return error :
        if t-gds.doc-qnty = 0 then nEXt.
        assign
        buf_sale-doc.gds-amount = buf_sale-doc.gds-amount - t-gds.num-lines.
        assign
        r-artic =      "":U
        r-prod-type = "":U
        r-prod-code = 0
        r-prt-code = 0
        rdoc-line = t-gds.rdoc-line
        rgds-dtl = t-gds.rgds-dtl
        r-b-code =  ?
        r-doc-prts-qnty = ?
        r-or-v = buf_sale-doc.doc-kind
        cashparts = t-gds.cashparts
        r-qnty = ?
        cashplace = t-gds.cashplace
        r-pl-code = t-gds.pl-code
        .
        FIND FIRST buf_doc-line WHERE recid(buf_doc-line) = t-gds.rdoc-line No-ERROR.
        run gds-attr-value(
                t-gds.gds-code,
                'mark':U,
                output par-alcohol,
                output par-type
            ).
        if t-gds.marks <> '' and par-alcohol = "yes"
        then do :
            find first doc-line-attr exclusive-lock where doc-line-attr.doc-code = buf_doc-line.doc-code
                                                      and doc-line-attr.gds-code = t-gds.gds-code
                                                      and doc-line-attr.attr-code = 'mark-code'
                                                      no-error.
            if available doc-line-attr
            then do :
              do mark-ii = 1 to num-entries(doc-line-attr.attr-value) :
                v-mark = entry(mark-ii, doc-line-attr.attr-value) .
                if not can-do(t-gds.marks, v-mark)
                then v-mark-list = v-mark-list + (if v-mark-list = '' then '' else ',') + v-mark .
              end.
              doc-line-attr.attr-value = v-mark-list .
            end.
        end.
        run  RSRV-line in this-procedure (
                       input buf_sale-doc.dir
                      ,input no
                      ,input no
                      ,input no
                      ,input v-is-tpsi-obj
                      ,input no
                      ,input no
                      ,input t-gds.gds-code
                      ,input t-gds.node-code
                      ,output v-run-tpsi
                      ,buffer buf_doc-line
                      ,buffer buf_trn-doc
                      ,buffer buf_sale-doc
                      ) no-error.
        if error-status:error then do:
          run waitfram-hide in this-procedure .
          undo f-del, return error substitute("Ошибка при снятии резервов товаров чека &1:&2&3 &4"
                                    , X_chk-doc.doc-code
                                    , chr(10)
                                    , error-status:get-message(1)
                                    , return-value ).
        end.
        if v-is-tpsi-obj
        and v-run-tpsi
        and buf_sale-doc.doc-kind = 'es':U
        then do:
          run str/tpsirsrv.p (
                           input parparentproc
                          ,input this-procedure
                          ,input ?
                          ,input 0
                          ,input v-curr-r-b
                          ,input inkas.inkas-code
                          ,input inkas.host-code
                          ,input inkas.obj-type
                          ,input inkas.obj-code
                          ,input r-artic
                          ,input r-prod-type
                          ,input r-prod-code
                          ,input r-prt-code
                          ,input no
                          ,input "Снятие резеров ЧУЖИХ товаров. Расход. Строк "
                          ,input-output num_rec_res
                          ,output num_rec_other
                          ,output num_rec_other_res
                          ,buffer buf_trn-doc
                        ) no-error .
          if error-status:error then do:
            return error substitute("Ошибка при снятии резервов ЧУЖИХ товаров:&1&2 &3"
                                    , chr(10)
                                    , error-status:get-message(1)
                                    , return-value ).
          end.
          assign
          num_resv = num_resv + num_rec
          num_resv_res = num_resv_res + num_rec_res
          num_rec = 0
          num_rec_res = 0
          .
        end.
      END.
      if num_resv > num_resv_res then do:
        run waitfram-hide in this-procedure .
        undo f-del, return error.
      end.
      run waitfram-show in this-procedure ( substitute("Пересчитываю выручку после исключения чека &1...", X_chk-doc.doc-code)).
      var-doc-type = (if X_chk-doc.netto >= 0 then 'при':U else 'рас':U).
      FOR  EACH buf_chk-pay WHERE
                buf_chk-pay.doc-code = X_chk-doc.doc-code
      BREAK
      BY buf_chk-pay.doc-code
      BY buf_chk-pay.pay-code
      BY buf_chk-pay.curr-code :
        ACCUMULATE
        buf_chk-pay.tot-sum ( SUB-TOTAL BY buf_chk-pay.curr-code )
        buf_chk-pay.tot-base ( SUB-TOTAL BY buf_chk-pay.curr-code )
        buf_chk-pay.tot-rubl ( SUB-TOTAL BY buf_chk-pay.curr-code )
        .
        find first buf_inkas-pay-wth where
                  buf_inkas-pay-wth.inkas-code = X_chk-doc.out-code
              and buf_inkas-pay-wth.pay-code = buf_chk-pay.pay-code
              and buf_inkas-pay-wth.curr-code = buf_chk-pay.curr-code
              and buf_inkas-pay-wth.wth-code = buf_chk-pay.wth-code
              and buf_inkas-pay-wth.par-code = buf_chk-pay.par-code
              and buf_inkas-pay-wth.pay-desk = X_chk-doc.pay-desk
              and buf_inkas-pay-wth.cashier = X_chk-doc.cashier
              and buf_inkas-pay-wth.chk-type = X_chk-doc.chk-type no-error.
        if not available  buf_inkas-pay-wth then do:
          create buf_inkas-pay-wth.
          assign
          buf_inkas-pay-wth.inkas-code = X_chk-doc.out-code
          buf_inkas-pay-wth.pay-code = buf_chk-pay.pay-code
          buf_inkas-pay-wth.curr-code = buf_chk-pay.curr-code
          buf_inkas-pay-wth.wth-code = buf_chk-pay.wth-code
          buf_inkas-pay-wth.par-code = buf_chk-pay.par-code
          buf_inkas-pay-wth.pay-desk = X_chk-doc.pay-desk
          buf_inkas-pay-wth.cashier = X_chk-doc.cashier
          buf_inkas-pay-wth.chk-type = X_chk-doc.chk-type
          buf_inkas-pay-wth.par-val = buf_chk-pay.par-val
          .
        end.
        assign
        buf_inkas-pay-wth.tot-sum = buf_inkas-pay-wth.tot-sum - buf_chk-pay.tot-sum
        buf_inkas-pay-wth.tot-base = buf_inkas-pay-wth.tot-base - buf_chk-pay.tot-base
        buf_inkas-pay-wth.tot-rubl = buf_inkas-pay-wth.tot-rubl - buf_chk-pay.tot-rubl
        buf_inkas-pay-wth.doc-qnty = buf_inkas-pay-wth.doc-qnty - buf_chk-pay.doc-qnty
        buf_inkas-pay-wth.tot-lines = buf_inkas-pay-wth.tot-lines - 1
        .
        if buf_inkas-pay-wth.tot-sum = 0 then delete buf_inkas-pay-wth.
        if last-of( buf_chk-pay.curr-code ) then  do:
          FIND buf_inkas-pay WHERE
              buf_inkas-pay.inkas-code = X_chk-doc.out-code AND
              buf_inkas-pay.pay-code = buf_chk-pay.pay-code AND
              buf_inkas-pay.curr-code = buf_chk-pay.curr-code NO-ERROR.
          if NOT available buf_inkas-pay then do:
            CREATE buf_inkas-pay.
            assign
            buf_inkas-pay.inkas-code = X_chk-doc.out-code
            buf_inkas-pay.pay-code = buf_chk-pay.pay-code
            buf_inkas-pay.curr-code = buf_chk-pay.curr-code
            buf_inkas-pay.tot-sum = 0
            buf_inkas-pay.tot-base = 0
            buf_inkas-pay.tot-rubl = 0
            .
          end.
          var-doc-type = (if X_chk-doc.netto >= 0 then 'при':U else 'рас':U).
          FIND FIRST buf_inkas-pay-desk WHERE
                    buf_inkas-pay-desk.inkas-code = X_chk-doc.out-code AND
                    buf_inkas-pay-desk.pay-code = buf_chk-pay.pay-code AND
                    buf_inkas-pay-desk.curr-code = buf_chk-pay.curr-code AND
                    buf_inkas-pay-desk.pay-desk = X_chk-doc.pay-desk AND
                    buf_inkas-pay-desk.doc-type = var-doc-type AND
                    buf_inkas-pay-desk.cashier = X_chk-doc.cashier
                    NO-ERROR.
          if NOT available buf_inkas-pay then do:
            CREATE buf_inkas-pay.
            assign
            buf_inkas-pay.inkas-code = X_chk-doc.out-code
            buf_inkas-pay.pay-code = buf_chk-pay.pay-code
            buf_inkas-pay.curr-code = buf_chk-pay.curr-code
            buf_inkas-pay.tot-sum = 0
            buf_inkas-pay.tot-base = 0
            buf_inkas-pay.tot-rubl = 0
            .
          end.
          if NOT available buf_inkas-pay-desk then do:
            CREATE buf_inkas-pay-desk.
            assign
            buf_inkas-pay-desk.inkas-code = X_chk-doc.out-code
            buf_inkas-pay-desk.pay-code = buf_chk-pay.pay-code
            buf_inkas-pay-desk.curr-code = buf_chk-pay.curr-code
            buf_inkas-pay-desk.pay-desk = X_chk-doc.pay-desk
            buf_inkas-pay-desk.cashier = X_chk-doc.cashier
            buf_inkas-pay-desk.tot-sum = 0
            buf_inkas-pay-desk.tot-base = 0
            buf_inkas-pay-desk.tot-rubl = 0
            buf_inkas-pay-desk.doc-type = var-doc-type
            .
          end.
          assign
              buf_inkas-pay.tot-sum = buf_inkas-pay.tot-sum -
                  ( ACCUM SUB-TOTAL BY buf_chk-pay.curr-code buf_chk-pay.tot-sum )
              buf_inkas-pay.tot-base = buf_inkas-pay.tot-base -
                  ( ACCUM SUB-TOTAL BY buf_chk-pay.curr-code buf_chk-pay.tot-base )
              buf_inkas-pay.tot-rubl = buf_inkas-pay.tot-rubl -
                  ( ACCUM SUB-TOTAL BY buf_chk-pay.curr-code buf_chk-pay.tot-rubl )
              buf_inkas-pay-desk.tot-sum = buf_inkas-pay-desk.tot-sum -
                  ( ACCUM SUB-TOTAL BY buf_chk-pay.curr-code buf_chk-pay.tot-sum )
              buf_inkas-pay-desk.tot-base = buf_inkas-pay-desk.tot-base -
                  ( ACCUM SUB-TOTAL BY buf_chk-pay.curr-code buf_chk-pay.tot-base )
              buf_inkas-pay-desk.tot-rubl = buf_inkas-pay-desk.tot-rubl -
                  ( ACCUM SUB-TOTAL BY buf_chk-pay.curr-code buf_chk-pay.tot-rubl ) .
          if buf_inkas-pay.tot-sum = 0 then delete buf_inkas-pay.
          if buf_inkas-pay-desk.tot-sum = 0 then delete buf_inkas-pay-desk.
        end.
      buf_chk-pay.out-code = ? .
    END.
    run waitfram-show in this-procedure ( substitute("Пересчитываю строки накладных после исключения чека &1...", X_chk-doc.doc-code)).
    FOR EACH t-gds ,
        first buf_sale-doc where
              buf_sale-doc.inkas-code = inkas.inkas-code
          and buf_sale-doc.doc-code = t-gds.doc-code,
        FIRST buf_doc-line WHERE
            buf_doc-line.doc-code = t-gds.doc-code
        AND buf_doc-line.artic = t-gds.artic
        AND buf_doc-line.prod-code = t-gds.prod-code
        AND buf_doc-line.prod-type = t-gds.prod-type
    break
    by t-gds.doc-code
    by t-gds.gds-code
    by t-gds.node-code
    by t-gds.b-code
    by t-gds.pl-code
    by t-gds.pump
    by t-gds.fbr-obj-type
    by t-gds.fbr-obj-code
    on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
    :
      if t-gds.cashplace then do:
        FIND FIRST ub.doc-pl WHERE
                  ub.doc-pl.pl-code = t-gds.pl-code
              AND ub.doc-pl.gds-code = t-gds.gds-code
              AND ub.doc-pl.out-code = buf_sale-doc.doc-code NO-ERROR.
        IF avail ub.doc-pl
        then do:
          assign
          ub.doc-pl.fact-qnty = ub.doc-pl.fact-qnty - abs(t-gds.doc-qnty)
          ub.doc-pl.cli-fact-qnty = ub.doc-pl.cli-fact-qnty - t-gds.density * abs(t-gds.doc-qnty)
          .
          if ub.doc-pl.fact-qnty = 0 then delete doc-pl.
          find first ub.doc-pl-pump where
                    ub.doc-pl-pump.pl-code = ub.doc-pl.pl-code
                AND ub.doc-pl-pump.gds-code = ub.doc-pl.gds-code
                AND ub.doc-pl-pump.pump-code = t-gds.pump
                AND ub.doc-pl-pump.out-code = buf_sale-doc.doc-code No-ERROR.
          IF avail ub.doc-pl-pump then do:
              ub.doc-pl-pump.fact-qnty = ub.doc-pl-pump.fact-qnty - abs(t-gds.doc-qnty).
              if ub.doc-pl-pump.fact-qnty = 0 then delete ub.doc-pl-pump.
          end.
        end.
      end.
      else do:
        if t-gds.cashparts then do:
          IF LOOKUP('2ед':U, t-gds.type) > 0 then
          FIND FIRST ub.doc-prts WHERE
                      ub.doc-prts.gds-code = t-gds.gds-code
                 AND  ub.doc-prts.out-code = buf_sale-doc.doc-code
                 AND  ub.doc-prts.fact-qnty = abs(t-gds.doc-qnty) NO-ERROR.
          else
          FIND FIRST ub.doc-prts WHERE
                     ub.doc-prts.b-code = t-gds.b-code
                 AND ub.doc-prts.out-code = buf_sale-doc.doc-code NO-ERROR.
        END.
        IF avail ub.doc-prts
        then do:
          ub.doc-prts.fact-qnty = ub.doc-prts.fact-qnty - abs(t-gds.doc-qnty).
          if ub.doc-prts.fact-qnty = 0 then delete doc-prts.
        end.
      end.
      if NOT (t-gds.fbr-obj-type = "":U
                    and
                    t-gds.fbr-obj-code = 0) then do:
        find first ub.doc-fbr-gds where
                  ub.doc-fbr-gds.fbr-obj-type = t-gds.fbr-obj-type
              AND ub.doc-fbr-gds.fbr-obj-code= t-gds.fbr-obj-code
              AND ub.doc-fbr-gds.gds-code = t-gds.gds-code
              AND ub.doc-fbr-gds.out-code = (if buf_sale-doc.doc-kind = 'rs':U then replace(buf_sale-doc.doc-code, "=", "-") else buf_sale-doc.doc-code) NO-ERROR.
        IF avail ub.doc-fbr-gds then do:
          ub.doc-fbr-gds.fact-qnty = ub.doc-fbr-gds.fact-qnty - t-gds.doc-qnty.
          if ub.doc-fbr-gds.fact-qnty = 0 then delete ub.doc-fbr-gds.
        end.
      end.
      FIND FIRST buf_gds-dtl WHERE
                  buf_gds-dtl.doc-code = t-gds.doc-code AND
                  buf_gds-dtl.artic = t-gds.artic AND
                  buf_gds-dtl.prod-code = t-gds.prod-code AND
                  buf_gds-dtl.prod-type = t-gds.prod-type AND
                  buf_gds-dtl.prt-code = t-gds.node-code NO-ERROR.
      if t-gds.pump > 0 then do:
        define variable v-qnty as decimal no-undo .
        define variable v-cli-qnty as decimal no-undo .
        if available doc-pl then release doc-pl.
        assign
        v-qnty     = 0.0
        v-cli-qnty = 0.0
        .
        for each ub.doc-pl no-lock where
                ub.doc-pl.out-code = t-gds.doc-code
            and ub.doc-pl.gds-code = t-gds.gds-code:
          assign
          v-qnty     = v-qnty + ub.doc-pl.fact-qnty
          v-cli-qnty = v-cli-qnty + ub.doc-pl.cli-fact-qnty
          .
        end.
        assign
        buf_doc-line.fact-density = v-cli-qnty / v-qnty
        buf_doc-line.doc-density = buf_doc-line.fact-density
        .
      end.
      assign
      buf_doc-line.fact-qnty = buf_doc-line.fact-qnty - abs( t-gds.doc-qnty )
      buf_sale-doc.fact-qnty = buf_sale-doc.fact-qnty  -  abs( t-gds.doc-qnty )
      v-real-qnty = v-real-qnty +
                    (if buf_sale-doc.in-inkas
                    then abs( t-gds.doc-qnty ) *
                    (if lookup(buf_sale-doc.ext-doc-type, 'vt,vp,rs':U) > 0 then - 1 else 1)
                    else 0)
      temp-qnty = buf_gds-dtl.fact-qnty - abs( t-gds.doc-qnty )
      .
      if temp-qnty = 0 then do:
        deleted-g = yes.
        if buf_doc-line.fact-qnty = 0 then deleted-d = yes.
        else deleted-d = no.
      end.
      else assign
      deleted-d = no
      deleted-g = no.
      if prcl-spl then do:
        if available buf_gds-dtl then do:
        for-price = (if p-curr-r-b = 'base':U
                    then buf_gds-dtl.price-base
                    else buf_gds-dtl.price-rubl)
                    .
      end.
      else do:
          for-price = 0.
        end.
      end.
      else do:
        assign
        for-price = t-gds.new-price
        .
      end.
      if not deleted-g then do:
        assign
        v-discnt-r-b =
        (
        for-price *( buf_gds-dtl.fact-qnty -  abs(t-gds.doc-qnty) )
        -
        ((if p-curr-r-b = 'base':U then buf_gds-dtl.price-base else buf_gds-dtl.price-rubl) - (if p-curr-r-b = 'base':U then buf_gds-dtl.discnt-base else buf_gds-dtl.discnt-rubl)) * buf_gds-dtl.fact-qnty
        +
        abs(t-gds.price-sum - t-gds.discnt-sum)
        ) / ( buf_gds-dtl.fact-qnty -  abs(t-gds.doc-qnty ))
        v-price-r-b = for-price
        buf_gds-dtl.fact-qnty = buf_gds-dtl.fact-qnty - abs( t-gds.doc-qnty )
        buf_gds-dtl.price-base = if p-curr-r-b = 'rubl':U
                              then  v-price-r-b / v-base-rate * v-base-scale
                              else v-price-r-b
        buf_gds-dtl.discnt-base = if p-curr-r-b = 'rubl':U
                              then v-discnt-r-b / v-base-rate * v-base-scale
                              else v-discnt-r-b
        buf_gds-dtl.price-rubl = if p-curr-r-b = 'base':U
                              then v-price-r-b * v-base-rate / v-base-scale
                              else v-price-r-b
        buf_gds-dtl.discnt-rubl = if p-curr-r-b = 'base':U
                              then v-discnt-r-b * v-base-rate / v-base-scale
                              else v-discnt-r-b
        buf_doc-line.road-tax = (if buf_doc-line.road-tax > 0 then
                                        (buf_doc-line.road-tax * (buf_doc-line.fact-qnty + abs(t-gds.doc-qnty) ) -
                                        abs(t-gds.road-sum )
                                        ) / (buf_doc-line.fact-qnty )
                                                else 0)
        .
      end.
      if last-of(t-gds.node-code) then do:
        if deleted-g then do:
          if available buf_gds-dtl then do:
          delete buf_gds-dtl no-error.
          if error-status:error then undo f-del, return error.
          buf_sale-doc.tot-dtl = buf_sale-doc.tot-dtl - 1.
        end.
        end.
      end.
      if last-of(t-gds.gds-code) then do:
        if deleted-d then do:
          delete buf_doc-line no-error.
          if error-status:error then undo f-del, return error.
          buf_sale-doc.tot-lines = buf_sale-doc.tot-lines - 1.
        end.
      end.
    END.
  end.
  else do:
    FOR  EACH buf_chk-pay WHERE
              buf_chk-pay.doc-code = X_chk-doc.doc-code:
      buf_chk-pay.out-code = ? .
    end.
  end.
  run waitfram-show in this-procedure ( substitute("Освобождаю чек &1...", X_chk-doc.doc-code)).
  FOR EACH buf_chk-gds where buf_chk-gds.doc-code = X_chk-doc.doc-code
  on error undo, return error error-status:get-message(1)
  :
      assign
      buf_chk-gds.out-code = ?
      buf_chk-gds.line-type = entry(1, buf_chk-gds.line-type, chr(4))
     .
  END.
  FOR EACH buf_chk-discnt where buf_chk-discnt.doc-code = X_chk-doc.doc-code
  on error undo, return error error-status:get-message(1)
  :
      buf_chk-discnt.out-code = ?.
  END.
  FOR EACH buf_chk-doc-attr where buf_chk-doc-attr.doc-code = X_chk-doc.doc-code
  on error undo, return error error-status:get-message(1)
  :
      buf_chk-doc-attr.out-code = ?.
  END.
  FOR EACH buf_chk-gds-pay where buf_chk-gds-pay.doc-code = X_chk-doc.doc-code
  on error undo, return error error-status:get-message(1)
  :
     delete buf_chk-gds-pay.
  END.
  for each buf_c-chk-doc where
          buf_c-chk-doc.doc-code = X_chk-doc.doc-code
   on error undo, return error error-status:get-message(1) :
    assign
    buf_c-chk-doc.out-code = ?
    .
  end.
  for each buf_c-chk-gds where
          buf_c-chk-gds.doc-code = X_chk-doc.doc-code
  on error undo, return error error-status:get-message(1) :
    assign
    buf_c-chk-gds.out-code = ?
    .
  end.
  for each buf_c-chk-discnt where
          buf_c-chk-discnt.doc-code = X_chk-doc.doc-code
   on error undo, return error error-status:get-message(1) :
    assign
    buf_c-chk-discnt.out-code = ?
    .
  end.
  for each buf_c-chk-pay where
          buf_c-chk-pay.doc-code = X_chk-doc.doc-code
   on error undo, return error error-status:get-message(1)
          :
    assign
    buf_c-chk-pay.out-code = ?
    .
  end.
  for each buf_c-chk-doc-attr where
          buf_c-chk-doc-attr.doc-code = X_chk-doc.doc-code
  on error undo, return error error-status:get-message(1)
          :
    assign
    buf_c-chk-doc-attr.out-code = ?
    .
  end.
  run waitfram-show in this-procedure ( substitute("Пересчитываю общие суммы по накладным после исключения чека &1...", X_chk-doc.doc-code)).
  assign
  inkas.tot-doc = inkas.tot-doc - (if docs-to-reserv > 0 then X_chk-doc.tot-doc else 0)
  inkas.discnt = inkas.discnt  -  (if docs-to-reserv > 0 then  X_chk-doc.discnt else 0)
  inkas.netto = inkas.netto -  (if docs-to-reserv > 0 then X_chk-doc.netto else 0)
  inkas.sub-discnt = inkas.sub-discnt -  X_chk-doc.sub-discnt
  inkas.num-chk = inkas.num-chk  - 1
  inkas.num-chk-nf = inkas.num-chk-nf - (if docs-to-reserv > 0 then 0 else 1)
  inkas.qnty = inkas.qnty -  v-real-qnty
  chk-amount = chk-amount - 1
  nf-chk-amount = nf-chk-amount - add-nf-amount
  .
  assign
  dtl-out = 0
  line-out = 0
  dtl-ret = 0
  line-ret = 0
  .
  for each buf_sale-doc where
          buf_sale-doc.inkas-code = inkas.inkas-code,
      first dop_trn-doc where dop_trn-doc.doc-code = buf_sale-doc.doc-code
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1)):
    if buf_sale-doc.doc-kind = 'es':U then do:
      assign
      dtl-out = dtl-out + buf_sale-doc.tot-dtl
      line-out = line-out + buf_sale-doc.tot-lines
      .
    end.
    if buf_sale-doc.doc-kind = 'rs':U then do:
      assign
      dtl-ret = dtl-ret + buf_sale-doc.tot-dtl
      line-ret = line-ret + buf_sale-doc.tot-lines
      .
    end.
    assign
    dop_trn-doc.fact-qnty = buf_sale-doc.fact-qnty
    dop_trn-doc.tot-lines = buf_sale-doc.tot-lines
    buf_sale-doc.filled = buf_sale-doc.fact-qnty <> 0 or buf_sale-doc.tot-lines <> 0
    .
    dop_trn-doc.ps = set-sale-doc-ps(buffer buf_sale-doc)
    .
    if not buf_sale-doc.filled
    and buf_sale-doc.doc-kind <> 'es':U then do:
      if buf_sale-doc.doc-kind = 'rs':U then do:
        assign
        buf0_trn-doc.out-code = '':U.
      end.
      delete dop_trn-doc.
      delete buf_sale-doc.
    end.
  end.
  assign
  inkas.PS = set-inkas-ps(input inkas.ps
                        , input chk-amount
                        , input gds-amount
                        , input line-out
                        , input dtl-out
                        , input line-ret
                        , input dtl-ret
                        , input nf-chk-amount
                        , input nf-gds-amount
                        , input p-filter-rus
                        )
  inkas.num-chk-nff = nff-chk-amount
  .
  X_chk-doc.out-code = ? .
  run waitfram-hide in this-procedure .
END.
end.
