block-level on error undo, throw.
define input parameter parparentproc   as widget-handle no-undo .
define input parameter p-curr-obj-type like ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code like ub.clients.obj-code no-undo .
define input parameter p-mode          as character no-undo .
define input parameter v-silent        as character no-undo .
define input parameter p-shift-mode    as character no-undo .
define input-output parameter p-inkas-code    like ub.inkas.inkas-code no-undo .
define input parameter p-create-status like ub.trn-doc.status_ no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: cre-sale.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/cre-sale.p $":U .
define variable vss-description as character no-undo init "Создание продажи".
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#trdcalib as handle no-undo.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
procedure cre-docs.
define input parameter p-auto          as integer no-undo .
define input parameter p-curr-obj-type like ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code like ub.clients.obj-code no-undo .
define input parameter p-shift-date    like ub.inkas.shift-date no-undo .
define input parameter p-shift-num     like ub.inkas.shift-num  no-undo .
define input parameter p-filter-name   as character             no-undo .
define input parameter p-filter-str    as character             no-undo .
define input parameter p-filter-str-rus as character            no-undo .
define input parameter p-doc-mode      as character no-undo .
define output parameter p-doc-rec      as recid no-undo.
DEFINE VARIABLE sys-today as date no-undo .
define variable vardoc-code like ub.trn-doc.doc-code no-undo.
define variable varret-code like ub.trn-doc.doc-code no-undo.
define variable v-curr-r-b as character no-undo .
define variable v-chk-pay     like ub.shop.chk-pay no-undo .
define variable v-dead-doc   as character initial no no-undo.
define variable v-type       as character initial ? no-undo.
define variable conf-attr as char no-undo.
define variable conf-par as char no-undo.
define variable par-type as char no-undo.
define variable cas-shft as logical no-undo init no.
define variable l-shift-on as logical no-undo init no.
define variable v-shift-date like ub.shift-obj.shift-date no-undo.
define variable v-shift-num  like ub.shift-obj.shift-num no-undo.
define variable v-shift-name  like ub.shift-obj.shift-name no-undo.
define variable sale-filter as logical no-undo init no.
define variable one-sale-per-day as logical no-undo .
define variable v-index as integer no-undo .
define variable v-wrkr as integer no-undo .
define variable v-agnt as integer no-undo .
define variable v-boss as integer no-undo .
define buffer buf_ret-doc     for ub.trn-doc.
define buffer buf_trn-doc     for ub.trn-doc.
define buffer buf_inkas       for ub.inkas.
define buffer buf_curr-shop   for ub.curr-shop.
define buffer buf_shift-obj for ub.shift-obj.
define variable v-mes as character no-undo .
define variable v-ps as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-tth as handle no-undo .
assign
v-tth = buffer thbjattr_thbj-attr:table-handle .
define buffer buf_shop for ub.shop.
define buffer buf_sysconf for ub.sysconf.
define buffer buf_clients for ub.clients .
define buffer real_clients for ub.clients .
define buffer buf_sale-doc for ub.sale-doc.
do
on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
:
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output v-curr-r-b
  )  .
  find first buf_clients no-lock where
            buf_Clients.obj-type = p-curr-obj-type
        AND buf_Clients.obj-code = p-curr-obj-code no-error .
  if not available buf_clients then do:
    v-mes = substitute("Не найден объект &1&2"
                ,p-curr-obj-type
                ,p-curr-obj-code)
    .
    undo, return error v-mes.
  end.
  find first buf_shop no-lock where
            buf_shop.obj-code = p-curr-obj-code no-error .
  if not available buf_clients then do:
    v-mes = substitute("Не найден  магазин &1"
                ,p-curr-obj-code).
    undo, return error v-mes.
  end.
  assign
  v-chk-pay = buf_shop.chk-pay
  .
  find first buf_sysconf no-lock where
          buf_sysconf.host-code = buf_clients.host-code no-error .
  if not available buf_sysconf then do:
    v-mes =  substitute("Не найдена фирма &1 для объекта&2&3"
                ,buf_clients.host-code
                ,p-curr-obj-type
                ,p-curr-obj-code).
    undo, return error v-mes.
  end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'dead-doc'
  ,input  ''
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output v-dead-doc
  ,output v-type
  ) no-error .
  if  error-status :error  = false then do:
    if v-dead-doc = "yes"  then  do:
      v-mes = "В системе установлен запрет на ввод документов - параметр dead-doc".
      undo, return error v-mes.
    end.
  end.
  for each thbjattr_thbj-attr:
    delete thbjattr_thbj-attr.
  end.
  run adm/shattri.p (
      input "get":U
      ,input  p-curr-obj-type
      ,input  p-curr-obj-code
      ,input  'autosale':U
      ,input  '':U
      ,output  v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-value-logical
      ,output par-type
      ,INPUT-OUTPUT table-handle v-tth
      ) no-error .
  if error-status:error then do:
     v-mes = substitute("Ошибка при получении опций работы с продажей НА ОБЪЕКТЕ &1&2:&3&4 &5"
                        , p-curr-obj-type
                        , p-curr-obj-code
                        , chr(10)
                        , error-status:get-message(1)
                        , return-value ).
      return error v-mes.
  end.
  find first thbjattr_thbj-attr where
            thbjattr_thbj-attr.obj-type = p-curr-obj-type
        and thbjattr_thbj-attr.obj-code = p-curr-obj-code
        and thbjattr_thbj-attr.upper-prop-code = 'autosale':U
        and thbjattr_thbj-attr.prop-code = 'sale-filter':U no-error.
  if available thbjattr_thbj-attr then do:
    assign
    sale-filter = thbjattr_thbj-attr.property-value-logical
    .
  end.
  find first thbjattr_thbj-attr where
            thbjattr_thbj-attr.obj-type = p-curr-obj-type
        and thbjattr_thbj-attr.obj-code = p-curr-obj-code
        and thbjattr_thbj-attr.upper-prop-code = 'autosale':U
        and thbjattr_thbj-attr.prop-code = 'one-sale-per-day':U no-error.
  if available thbjattr_thbj-attr then do:
    assign
    one-sale-per-day = thbjattr_thbj-attr.property-value-logical
    .
  end.
  run adm/shattri.p (
      input "get":U
      ,input  p-curr-obj-type
      ,input  p-curr-obj-code
      ,input  'get-chk':U
      ,input  'cas-shft':U
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-value-logical
      ,output par-type
      ,INPUT-OUTPUT table-handle v-tth
      ) no-error .
  if error-status:error then do:
     v-mes = substitute("Ошибка при получении опций закачки чеков НА ОБЪЕКТЕ &1&2:&3&4 &5"
                        , p-curr-obj-type
                        , p-curr-obj-code
                        , chr(10)
                        , error-status:get-message(1)
                        , return-value ).
      return error v-mes.
  end.
  assign
  cas-shft = v-value-logical.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  p-curr-obj-type
  ,input  p-curr-obj-code
  ,input  'shift-on=request'
  ,output l-shift-on
  )  .
  if l-shift-on and not cas-shft then do:
    v-mes = substitute("Внимание! На текущем объекте &1&2 требуется использование смен,&3" +
                        "а настройка СМЕНЫ НА КАССЕ ( cas-shft ) выключена - это недопустимо."
                       , p-curr-obj-type
                       , p-curr-obj-code
                       , chr(10)).
    return ERROR v-mes.
  end.
  if l-shift-on then do:
    if p-auto > 0 then do:
      assign
      p-shift-date = ?
      p-shift-num = ?
      .
    end.
    if p-shift-date <> ?
    and p-shift-num <> ?
    and p-auto = 0
    then do:
      find first buf_shift-obj no-lock where
                buf_shift-obj.obj-type = p-curr-obj-type
            and buf_shift-obj.obj-code = p-curr-obj-code
            and buf_shift-obj.shift-date = p-shift-date
            and buf_shift-obj.shift-num = p-shift-num
            and buf_shift-obj.status_ = 'зкр':U no-error.
     if not available buf_shift-obj then do:
        v-mes = substitute("Не найдена закрытая смена от &1 c пор. &2 для &3&4, по которой предлагалось создать продажу"
                          , string(p-shift-date, "99/99/9999")
                          , p-shift-num
                          , p-curr-obj-type
                          , p-curr-obj-code
                           ).
        return error v-mes.
      end.
      assign
      v-shift-date = p-shift-date
      v-shift-num = p-shift-num
      v-shift-name = buf_shift-obj.shift-name
      .
    end.
    else do:
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curshift in g#library
  (input  p-curr-obj-type
  ,input  p-curr-obj-code
  ,output v-shift-date
  ,output v-shift-num
  ,output v-shift-name
  ) no-error .
      if error-status:error then do:
        v-mes = substitute("Ошибка при получении признака СМЕНЫ НА ОБЪЕКТЕ &1&2:&3&4 &5"
                          , p-curr-obj-type
                          , p-curr-obj-code
                          , chr(10)
                          , error-status:get-message(1)
                          , return-value ).
        return error v-mes.
      end.
      find first buf_shift-obj where
              buf_shift-obj.obj-type = p-curr-obj-type
          AND buf_shift-obj.obj-code = p-curr-obj-code
          AND buf_shift-obj.shift-date = v-shift-date
          AND buf_shift-obj.shift-num = v-shift-num.
      assign
      v-shift-name = buf_shift-obj.shift-name.
    end.
  end.
    FIND LAST buf_curr-shop WHERE
              buf_curr-shop.curr-code = buf_sysconf.base-code AND
              buf_curr-shop.obj-type = p-curr-obj-type AND
              buf_curr-shop.obj-code = p-curr-obj-code AND
              buf_curr-shop.exch-date <= (if l-shift-on then v-shift-date else sys-today)
                                              use-index pi NO-ERROR.
    if NOT available buf_curr-shop then do:
      v-mes = substitute("На &1&2 на дату &3 неизвестен магазинный курс базовой валюты."
                        , p-curr-obj-type
                        , p-curr-obj-code
                        ,(if l-shift-on then v-shift-date else sys-today)).
      undo, return error v-mes.
    end.
    FIND real_clients WHERE
         real_clients.obj-type = buf_sysconf.sale-type AND
         real_clients.obj-code = buf_sysconf.sale-code NO-LOCK NO-ERROR .
    if NOT available real_clients then do:
      v-mes = substitute("Неправильные настройки системы !&1" +
                         "КОНТРАГЕНТ &2&3, указанный в настройках фирмы &4 как КОНТРАГЕНТ для РЕАЛИЗАЦИИ,&1" +
                          "отсутствует в справочнике !&1"  +
                          "Обратитесь к администратору."
                          , chr(10)
                          , buf_sysconf.sale-type
                          , buf_sysconf.sale-code
                          , buf_sysconf.host-code
                          ).
      undo, return error v-mes.
    end.
  if p-shift-date = ? then do:
    if p-auto = 4  then do:
      DEFINE VARIABLE v-time as integer no-undo .
      run cur-time in this-procedure ( output sys-today, output v-time).
    end.
    else do:
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  p-curr-obj-type
  ,input  p-curr-obj-code
  ,output sys-today
  ) no-error .
    end.
    if error-status:error then return error return-value .
  end.
  else do:
    assign
    sys-today = p-shift-date
    v-shift-num = p-shift-num
    .
  end.
  find first thbjattr_thbj-attr where
            thbjattr_thbj-attr.upper-prop-code = 'autosale':U
        and thbjattr_thbj-attr.prop-code = 'wrkr':U.
  assign
  v-wrkr = thbjattr_thbj-attr.property-value-integer
  .
  find first thbjattr_thbj-attr where
            thbjattr_thbj-attr.upper-prop-code = 'autosale':U
        and thbjattr_thbj-attr.prop-code = 'agnt':U.
  v-agnt = thbjattr_thbj-attr.property-value-integer.
  find first thbjattr_thbj-attr where
            thbjattr_thbj-attr.upper-prop-code = 'autosale':U
        and thbjattr_thbj-attr.prop-code = 'boss':U.
  v-boss = thbjattr_thbj-attr.property-value-integer
  no-error.
  assign
  v-wrkr  = (if v-wrkr = 0 then ? else v-wrkr)
  v-agnt  = (if v-agnt = 0 then ? else v-agnt)
  v-boss  = (if v-boss = 0 then ? else v-boss)
  .
  if one-sale-per-day then do:
    if l-shift-on
    or cas-shft
    then do:
      find first buf_inkas no-lock where
                buf_inkas.obj-type =  p-curr-obj-type
            and buf_inkas.obj-code =  p-curr-obj-code
            and buf_inkas.shift-date = v-shift-date
            and buf_inkas.shift-num = (if l-shift-on
                                      then v-shift-num
                                      else (if p-auto > 0
                                          then v-shift-num
                                          else 1)
                                      )
            no-error.
      if available buf_inkas then do:
        v-mes = substitute("Нельзя создать вторую продажу за смену &1 П. &2 - запрещено параметрами"
                          , string(v-shift-date, "99/99/9999")
                          , (if l-shift-on
                            then v-shift-num
                            else (if p-auto > 0
                                then v-shift-num
                                else 1)
                            )).
        undo, return error v-mes.
      end.
    end.
    else do:
      find first buf_inkas no-lock where
                buf_inkas.obj-type =  p-curr-obj-type
            and buf_inkas.obj-code =  p-curr-obj-code
            and buf_inkas.doc-date = sys-today no-error.
      if available buf_inkas then do:
        v-mes = substitute("Нельзя создать вторую продажу за день &1 - запрещено параметрами"
                          , string(sys-today, "99/99/9999")
                          ).
        undo, return error v-mes.
      end.
    end.
  end.
    run doc-code in this-procedure
     (input "main",
      input p-curr-obj-type,
      input p-curr-obj-code,
      input ?,
      output vardoc-code ) no-error.
    if error-status:error then do:
      v-mes = substitute("Ошибка при генерации номера документа продажи:&1&2 &3"
                        , chr(10)
                        , error-status:get-message(1)
                        , return-value).
      undo, return error v-mes.
    end.
v-ps = set-sale-doc-PS ( buffer buf_sale-doc ).
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_crtrndoc in g#lib-trn
(input ?
,input ?
,input buf_curr-shop.exch-rate
,input buf_curr-shop.exch-scale
,input buf_sysconf.sale-code
,input buf_sysconf.sale-type
,input real_clients.obj-name
,input g#db-num
,input g#userid
,input 'касс':U
,input vardoc-code
,input (if l-shift-on then v-shift-date else sys-today)
,input 'рас':U
,input no
,input buf_sysconf.host-code
,input no
,input p-curr-obj-code
,input p-curr-obj-type
,input no
,input v-chk-pay
,input v-ps
,input no
,input ?
,input p-doc-mode
,input ?
,input 'es':U
,input ?
) no-error
.
    if error-status:error then do:
      v-mes = substitute("Ошибка при генерации  расходной накладной по продаже &4:&1&2 &3"
                        , chr(10)
                        , error-status:get-message(1)
                        , return-value
                        , vardoc-code
                        ).
      undo, return error v-mes.
    end.
    find buf_trn-doc where buf_trn-doc.doc-code = vardoc-code.
    assign
    buf_trn-doc.fact-date  = if l-shift-on then v-shift-date else sys-today
    buf_trn-doc.shift-date = if l-shift-on then v-shift-date else sys-today
    buf_trn-doc.shift-num  = if l-shift-on
                              then v-shift-num
                              else (IF cas-shft
                                    then (if p-auto > 0
                                          then v-shift-num
                                          else 1)
                                    else 0)
    buf_trn-doc.shift-name  = if l-shift-on then v-shift-name  else (IF cas-shft then string(1) else '')
    buf_trn-doc.wrkr = v-wrkr
    buf_trn-doc.agnt = v-agnt
    buf_trn-doc.boss = v-boss
        .
    CREATE buf_inkas.
    assign
    buf_inkas.inkas-code = buf_trn-doc.doc-code
    buf_inkas.obj-type = p-curr-obj-type
    buf_inkas.obj-code = p-curr-obj-code
    buf_inkas.host-code = buf_sysconf.host-code
    buf_inkas.status_ = 'новый':U
    buf_inkas.acc-date = ?
    buf_inkas.doc-date = if l-shift-on then v-shift-date else sys-today
    buf_inkas.shift-date = if l-shift-on then v-shift-date else sys-today
    buf_inkas.fact-date = if l-shift-on then v-shift-date else sys-today
    buf_inkas.office = no
    buf_inkas.shift-num = if l-shift-on
                              then v-shift-num
                              else (IF cas-shft
                                    then (if p-auto > 0
                                          then v-shift-num
                                          else 1)
                                    else 0)
    buf_inkas.shift-name = if l-shift-on then v-shift-name else (IF cas-shft then string(1) else '')
    buf_inkas.is-mand-sale-filter = sale-filter
    buf_Inkas.is-auto-born = (p-auto>= 2)
    p-doc-rec         = recid(buf_inkas)
    .
    if v-curr-r-b = 'rubl':U then do:
      assign
      buf_trn-doc.exch-code = 0
      buf_trn-doc.exch-rate = 1
      buf_trn-doc.exch-scale = 1
      buf_trn-doc.print-rubl = yes
      .
    end.
    else do:
      assign
      buf_trn-doc.exch-code = base-code
      buf_trn-doc.exch-rate = buf_trn-doc.base-rate
      buf_trn-doc.exch-scale = buf_trn-doc.base-scale
      buf_trn-doc.print-rubl = no
      .
   end.
    if p-filter-str <> "":U then do:
      assign
      buf_Inkas.sale-filter = p-filter-str
      buf_Inkas.sale-filter-name = p-filter-name
      buf_Inkas.sale-filter-rus = p-filter-str-rus
      .
    end.
    run saledoc-create  in this-procedure (
                                            input buf_trn-doc.doc-code
                                            ,input buf_trn-doc.host-code
                                            ,input buf_trn-doc.obj-type
                                            ,input buf_trn-doc.obj-code
                                            ,input 'es':U
                                            ,input 'т':U
                                            ,input no
                                            ,input '':U
                                            ,input '':U
                                            ,input 0
                                            ,buffer buf_trn-doc
                                            ) no-error .
    if error-status:error then do:
      v-mes = substitute("Ошибка при генерации записи связанного документа для расходной накладной по продаже &4:&1&2 &3"
                        , chr(10)
                        , error-status:get-message(1)
                        , return-value
                        , vardoc-code
                        ).
      undo, return error v-mes.
    end.
end.
end procedure.
DEFINE new SHARED BUFFER    ink-doc FOR ub.inkas.
DEFINE new SHARED BUFFER    X_trn-doc FOR ub.trn-doc.
DEFINE new SHARED QUERY     br-docs FOR ink-doc SCROLLING.
define variable v-doc-rec  as recid no-undo .
define variable v-host-code   like ub.sysconf.host-code no-undo .
define variable glog as logical no-undo .
define variable v-mes as character no-undo .
DEFINE VARiable v-handle as handle no-undo.
define variable next-prev as character no-undo .
define variable v-rid-list as character no-undo .
define buffer buf_shift-obj for ub.shift-obj.
do
on error undo, return error return-value
:
  if p-mode = 'ПРОСМОТР':U then do:
    FIND FIRST ink-doc WHERE ink-doc.inkas-code = p-inkas-code  NO-LOCK NO-ERROR.
    if not available ink-doc then do:
      v-mes = substitute("Для &1&2 НЕТ незакрытого отчета о продаже &3"
                         ,p-curr-obj-type
                         ,p-curr-obj-code
                         ,p-inkas-code).
      return v-mes.
    end.
    v-doc-rec = recid (ink-doc).
  end.
  else
      do on stop undo, return error
          on end-key undo, return error :
        if p-mode = 'ДОБАВЛЕНИЕ':U then do:
          FIND FIRST ink-doc WHERE
                      ink-doc.status_ = 'новый':U
                  and ink-doc.obj-type = p-curr-obj-type
                  and ink-doc.obj-code = p-curr-obj-code no-lock NO-ERROR.
          if available ink-doc then do:
            if v-silent <> "silent":U then do:
              glog = no.
              message
              substitute("Уже есть один незакрытый отчет на объекте &1&2&3" +
                        "дата &4 дата факт.(ожидается)&5,&3Вы уверены что хотите создать еще один?"
                        , p-curr-obj-type
                        , p-curr-obj-code
                        , chr(10)
                        , string(ink-doc.doc-date, "99/99/9999")
                        , string(ink-doc.fact-date, "99/99/9999")
                        )
              view-as alert-box QUESTION buttons yes-no update glog.
              if not glog then undo, return error "cancell".
            end.
          end.
          if p-shift-mode = 'ВЫБОР':U
          and v-silent = '':U
          and p-mode = 'ДОБАВЛЕНИЕ':U
          then do:
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-curr-obj-type
  ,input  p-curr-obj-code
  ,output v-host-code
  )  .
define variable vss-include-info12 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  g#db-num
    ,input  g#userid
    ,input  0
    ,input  'actn_sale_create-back-shift':U
    ,input  'object':U
    ,input  v-host-code
    ,input  p-curr-obj-type
    ,input  p-curr-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output glog
    )  .
end.
            if not glog then do:
              return error "cancell".
            end.
            run str/sht-all.w (
                          input parparentproc
                        , INPUT p-curr-obj-type
                        , input p-curr-obj-code
                        , input 'b-sel'
                        , input 'obj'
                        , INPUT p-curr-obj-type
                        , input p-curr-obj-code
                        , input '':u
                        , input-output v-rid-list) no-error.
             if v-rid-list = '':U then do:
                return error "cancell".
             end.
             find first buf_shift-obj no-lock where
                      recid(buf_shift-obj) = integer(v-rid-list) .
             if not (buf_shift-obj.obj-type = p-curr-obj-type
                     and
                     buf_shift-obj.obj-code = p-curr-obj-code
                     )
             or not (buf_shift-obj.status_ = 'зкр':U) then do:
               message
               substitute("Вы должны Выбрать ЗАКРЫТУЮ смену по &1&2"
                          , p-curr-obj-type
                          , p-curr-obj-code)
               view-as alert-box error .
               return error "cancell".
             end.
          end.
          run waitfram-show in this-procedure ("Создание нового отчета о продаже ...").
          RUN cre-docs in this-procedure  (
                                          input (if v-silent = "silent" then 4 else 0)
                                        , input p-curr-obj-type
                                        , input p-curr-obj-code
                                        , input (if available buf_shift-obj
                                                 then buf_shift-obj.shift-date
                                                 else ?)
                                        , input (if available buf_shift-obj
                                                 then buf_shift-obj.shift-num
                                                 else ?)
                                        , input "":U
                                        , input "":U
                                        , input "":U
                                        , input p-create-status
                                        , output v-doc-rec
                                        ) NO-ERROR.
          if error-status:error then do:
            run waitfram-hide in this-procedure .
            undo, return error return-value .
          end.
          run waitfram-hide in this-procedure .
        end.
        else do:
          if p-inkas-code = "":U then do:
            find ink-doc where
                ink-doc.obj-type = p-curr-obj-type
            AND ink-doc.obj-code = p-curr-obj-code
            AND ink-doc.status_ = 'новый':U no-error .
            if AMBIGUOUS ink-doc then do:
              if v-silent <> "silent":U then do:
                message
                substitute("На объекте &1&2 несколько открытых продаж&3" +
                          "воспользуйтесь меню ПРОДАЖА-Список незакрытых продаж"
                          , p-curr-obj-type
                          , p-curr-obj-code
                          , chr(10))
                view-as alert-box .
                return.
              end.
            end.
            if available ink-doc then do:
              p-inkas-code = ink-doc.inkas-code.
            end.
          end.
          FIND FIRST ink-doc WHERE
                      ink-doc.inkas-code = p-inkas-code NO-ERROR.
          if not available ink-doc then do:
            v-mes = substitute("Не найден незакрытый отчет на объекте &1&2 с номером &3"
                       , p-curr-obj-type
                       , p-curr-obj-code
                       , p-inkas-code).
            return error v-mes.
          end.
          v-doc-rec = recid (ink-doc).
        end.
        DO TRANSACTION:
          FIND FIRST ink-doc WHERE
                      recid(ink-doc) = v-doc-rec EXCLUSIVE-LOCK.
          if p-inkas-code = ?
          or p-inkas-code = '' then do:
            p-inkas-code = ink-doc.inkas-code.
          end.
          if ink-doc.status_ = 'факт':U then do:
            v-mes = substitute("Продажа с номером &1 закрыта -изменения невозможны"
                       , p-inkas-code).
            undo, return error v-mes.
          end.
          if ink-doc.status_ = 'запрос':U
          then do:
            v-mes = substitute("Продажа-запрос с номером &1 закрыта -изменения невозможны"
                       , p-inkas-code).
            undo, return error v-mes.
          end.
        END.
      end.
  if v-silent = "silent" then return ''.
  if p-mode = 'ПРОСМОТР':U then do:
    p-mode = 'ПРОСМОТР':U.
  end.
  else do:
    p-mode = 'ИЗМЕНЕНИЕ':U.
  end.
  assign
  v-handle = ?
  next-prev = ?.
  run str/sale.w (
                input parparentproc
              , input p-mode
              , input-output v-doc-rec
              , input-output v-handle
              , input-output next-prev
              , buffer ink-doc
              )  NO-ERROR .
end.
