block-level on error undo, throw.
define input parameter parparentproc as handle no-undo .
define variable vss-revision    as character no-undo init "$Revision: 1eba0946c2d7, 3078, rls $":U .
define variable vss-author      as character no-undo init "$Author: DRuban $":U .
define variable vss-date        as character no-undo init "$Date: Пт авг 05 19:16:25 2022 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: imp-gtin.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/imp-gtin.p $":U .
define variable vss-description as character no-undo init "Импорт gtin".
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure thbjattr_code :
   define input  parameter p-upper-code     as character no-undo .
   define input  parameter p-code           as character no-undo .
   define output parameter p-label          as character no-undo .
   define output parameter p-user-can-edit  as logical   no-undo .
   define output parameter p-output-display as logical   no-undo .
   define output parameter p-other          as character no-undo .
   define output parameter p-prop-list      as character no-undo .
   define output parameter p-prop-type-list as character no-undo .
   define output parameter p-prop-label-list as character no-undo .
   define output parameter p-global          as logical no-undo .
   define output parameter p-host           as logical no-undo .
   define output parameter p-shop           as logical no-undo .
   define output parameter p-store          as logical no-undo .
   define output parameter p-db             as logical no-undo .
   define variable p-region as logical no-undo.
   run thbjattr_code_reg in this-procedure (
                                            p-upper-code,
                                            p-code,
                                            output p-label,
                                            output p-user-can-edit,
                                            output p-output-display,
                                            output p-other,
                                            output p-prop-list,
                                            output p-prop-type-list,
                                            output p-prop-label-list,
                                            output p-global,
                                            output p-host,
                                            output p-shop,
                                            output p-store,
                                            output p-db,
                                            output p-region
                                            ).
end procedure.
procedure thbjattr_code_reg :
define input  parameter p-upper-code     as character no-undo .
define input  parameter p-code           as character no-undo .
define output parameter p-label          as character no-undo .
define output parameter p-user-can-edit  as logical   no-undo .
define output parameter p-output-display as logical   no-undo .
define output parameter p-other          as character no-undo .
define output parameter p-prop-list      as character no-undo .
define output parameter p-prop-type-list as character no-undo .
define output parameter p-prop-label-list as character no-undo .
define output parameter p-global          as logical no-undo .
define output parameter p-host           as logical no-undo .
define output parameter p-shop           as logical no-undo .
define output parameter p-store          as logical no-undo .
define output parameter p-db             as logical no-undo .
define output parameter p-region         as logical no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_code in g#attr-lib
    (input  p-upper-code
    ,input  p-code
    ,output p-label
    ,output p-user-can-edit
    ,output p-output-display
    ,output p-other
    ,output p-prop-list
    ,output p-prop-type-list
    ,output p-prop-label-list
    ,output p-global
    ,output p-host
    ,output p-shop
    ,output p-store
    ,output p-db
    ,output p-region
    ) no-error .
  if error-status :error
  then do:
    undo, return error substitute( "&1. &2&3&4", vss-include-info2, return-value, chr(10), error-status :get-message (1)).
  end.
end.
end procedure.
procedure thbjattr_tooltip :
define input  parameter p-upper-code  as character no-undo .
define input  parameter p-code      as character no-undo .
define output parameter p-tooltip   as character no-undo .
define output parameter p-label     as character no-undo .
define output parameter p-tooltip-code as character no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_tooltip in g#attr-lib
    (input  p-upper-code
    ,input  p-code
    ,output p-tooltip
    ,output p-label
    ,output p-tooltip-code
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_legacy :
define input  parameter p-upper-code     as character no-undo .
define output parameter p-level-way      as character no-undo .
define output parameter p-up-way         as character no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_legacy in g#attr-lib
    (input  p-upper-code
    ,output p-level-way
    ,output p-up-way
    ) no-error .
  if error-status :error
  then do:
    undo, return error substitute( "&1. &2&3&4", vss-include-info2, return-value, chr(10), error-status :get-message (1)).
  end.
end.
end procedure.
procedure thbjattr_value :
define input  parameter p-obj-type like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter p-code     like ub.thbj-attr.prop-code  no-undo .
define output parameter p-value-character like ub.thbj-attr.property-value-character no-undo .
define output parameter p-value-date    like ub.thbj-attr.property-value-date no-undo .
define output parameter p-value-decimal like ub.thbj-attr.property-value-decimal no-undo .
define output parameter p-value-integer like ub.thbj-attr.property-value-integer no-undo .
define output parameter p-value-logical like ub.thbj-attr.property-value-logical no-undo .
define output parameter p-type     as character no-undo .
define output parameter p-found as decimal no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_value in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ,input  p-code
    ,output p-value-character
    ,output p-value-date
    ,output p-value-decimal
    ,output p-value-integer
    ,output p-value-logical
    ,output p-type
    ,output p-found
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_get-section :
define input  parameter p-obj-type like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-param-code  like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter p-mode as character no-undo .
define input-output parameter table-handle p-tth.
define output parameter p-all-found as decimal no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_get-section in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-param-code
    ,input  p-mode
    ,input-output table-handle p-tth
    ,output p-all-found
    ) no-error .
  if error-status :error
  then do:
    delete object p-tth.
    undo, return error return-value .
  end.
  delete object p-tth.
end.
end procedure.
procedure thbjattr_write :
define input  parameter p-obj-type like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code  like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter p-code     like ub.thbj-attr.prop-code  no-undo .
define input  parameter p-value-character like ub.thbj-attr.property-value-character no-undo .
define input  parameter p-value-date like ub.thbj-attr.property-value-date no-undo .
define input  parameter p-value-decimal like ub.thbj-attr.property-value-decimal no-undo .
define input  parameter p-value-integer like ub.thbj-attr.property-value-integer no-undo .
define input  parameter p-value-logical like ub.thbj-attr.property-value-logical no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_write in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ,input  p-code
    ,input  p-value-character
    ,input  p-value-date
    ,input  p-value-decimal
    ,input  p-value-integer
    ,input  p-value-logical
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_set-section :
define input  parameter p-obj-type like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code  like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter table-handle p-tth.
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_set-section in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ,input  table-handle p-tth
    ) no-error .
  if error-status :error
  then do:
    delete object p-tth.
    undo, return error return-value .
  end.
  delete object p-tth.
end.
end procedure.
procedure thbjattr_delete :
define input  parameter p-obj-type   like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code   like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter p-code       like ub.thbj-attr.prop-code  no-undo .
define output parameter p-deleted  as logical no-undo.
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_delete in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ,input  p-code
    ,output p-deleted
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_delete-section :
define input  parameter p-obj-type   like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code   like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code like ub.thbj-attr.upper-prop-code  no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_delete-section in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_manual-edit :
define input  parameter p-ucode          as character no-undo .
define input  parameter p-code           as character no-undo .
define output parameter p-section-num    as integer no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_manual-edit in g#attr-lib
    (input  p-ucode
    ,input  p-code
    ,output  p-section-num
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
def var objSrv as class ibs.th.gbl.sys.objsrv no-undo.
run gbl/getobjsrvhndl.p (input-output ObjSrv).
define variable MarkType as ibs.th.str.marking.Types no-undo.
MarkType = ObjSrv:Env:Marking:Types.
define variable v-imp-file as character no-undo .
define variable v-err-file as character no-undo .
define variable v-log-file as character no-undo .
define variable v-s as character no-undo .
define variable v-log as logical no-undo .
DEFINE VARIABLE mExcelApplication AS COMPONENT-HANDLE NO-UNDO.
DEFINE VARIABLE mWorkBook         AS COMPONENT-HANDLE NO-UNDO.
DEFINE VARIABLE mWorkSheet        AS COMPONENT-HANDLE NO-UNDO.
DEFINE VARIABLE mMaxNoLine        AS INTEGER          INITIAL 10 NO-UNDO.
DEFINE VARIABLE vLine   AS INTEGER   NO-UNDO.
DEFINE VARIABLE vChLine AS CHARACTER NO-UNDO.
DEFINE VARIABLE vCh     AS CHARACTER NO-UNDO.
DEFINE VARIABLE vNoLine AS INTEGER   NO-UNDO.
define variable v-num as character no-undo .
define variable v-b-code as character no-undo .
define variable v-gds-name as character no-undo .
define variable v-pack-gtin as character no-undo .
define variable v-mark-code as character no-undo .
define variable v-blok-b-code as character no-undo .
define variable v-blok-gtin as character no-undo .
define variable v-blok-mark-code as character no-undo .
define variable v-koef as character no-undo .
define variable v-bar-code as integer no-undo .
define variable v-bc-rid as recid no-undo .
define variable v-b-str as character no-undo .
define variable v-lines as integer no-undo .
define variable v-ok-lines as integer no-undo .
define buffer buf_bar-code for ub.bar-code .
define buffer blok_bar-code for ub.bar-code .
define buffer buf_prod-bc  for ub.prod-bc .
define buffer buf_prod-bc-attr for ub.prod-bc-attr.
define buffer buf_units    for ub.units .
define buffer buf_goods    for ub.goods .
define stream s-err .
define stream s-log .
define temp-table tt-gds-gtin
  field b-code as character
  field gds-name as character
  field pack-gtin as character
  field mark-code as character
  field blok-b-code as character
  field blok-gtin as character
  field blok-mark-code as character
  field koef as decimal
.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
find first buf_units no-lock where buf_units.unit-name = "блок" no-error.
if not available buf_units
then do :
  find first buf_units no-lock where buf_units.long-name = "блок" no-error.
end.
if not available buf_units
then do :
  message "В системе не найдена единица измерения 'блок'!" view-as alert-box error .
  return .
end.
do:
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  define variable v-tth as handle no-undo.
  define variable v-chg-bcod as logical no-undo.
  define variable v-value-character as character no-undo.
  define variable v-value-date as date no-undo.
  define variable v-value-decimal as decimal no-undo.
  define variable v-value-integer as INTEGER no-undo.
  define variable v-value-logical AS LOGICAL no-undo.
  define variable v-param-type as character no-undo.
  define buffer buf_goods-attr for goods-attr.
  assign v-tth = buffer thbjattr_thbj-attr:table-handle.
  FOR EACH thbjattr_thbj-attr:
      delete thbjattr_thbj-attr.
  end.
  run adm/shattri.p (
            input "get":U
          , input v-cntxt-obj-type
          , input v-cntxt-obj-code
          , input 'gds-ref_obj':U
          , input 'chg-bcod':U
          , output v-value-character
          , output v-value-date
          , output v-value-decimal
          , output v-value-integer
          , output v-value-logical
          , output v-param-type
          , INPUT-OUTPUT table-handle v-tth
          ) no-error .
   v-chg-bcod = v-value-logical.
   if v-cntxt-db-num = 0 then v-chg-bcod = no .
end.
if v-chg-bcod
then do :
  message "Запрещена работа с доп. БК. Импорт невозможен." view-as alert-box .
  return .
end .
SYSTEM-DIALOG GET-FILE
  v-imp-file
  FILTERS "Файлы Excel *.xlsx,*.xls" "*.xlsx,*.xls",
          "Все файлы"  "*.*"
  MUST-EXIST
  TITLE "Выберите файл для импорта"
  USE-FILENAME
  UPDATE v-log.
if v-log <> true then do:
  return .
end.
run waitfram-show in this-procedure ( "ЖДИТЕ...") .
CREATE "Excel.Application":U mExcelApplication no-error.
    if error-status :error then do:
        message
        "Ошибка при запуске Excel" skip
        error-status :get-message(1) skip
        view-as alert-box error .
        undo, return error .
    end.
ASSIGN
    mExcelApplication:DisplayAlerts = NO
    mWorkbook                       = mExcelApplication:WorkBooks:Add(v-imp-file)
    mWorkSheet                      = mWorkbook:Sheets:Item(1)
.
loopbl:
do vLine = 1 to 1000000:
  ASSIGN
    vChLine = STRING(vLine)
    v-gds-name    = ''
    v-b-code      = ''
    v-pack-gtin   = ''
    v-mark-code   = ''
    v-blok-b-code = ''
    v-blok-gtin   = ''
    v-blok-mark-code  = ''
    v-koef        = ''
  .
  v-num = mWorkSheet:Range("A" + vChLine):FORMULA NO-ERROR.
  if v-num = ? then v-num = mWorkSheet:Range("A" + vChLine):VALUE NO-ERROR.
  integer(v-num) no-error .
  if error-status:error then next loopbl .
  v-gds-name = mWorkSheet:Range("B" + vChLine):FORMULA NO-ERROR.
  if v-gds-name = ? then v-gds-name = mWorkSheet:Range("B" + vChLine):VALUE NO-ERROR.
  v-b-code = mWorkSheet:Range("C" + vChLine):FORMULA NO-ERROR.
  if v-b-code = ? then v-b-code = mWorkSheet:Range("C" + vChLine):VALUE NO-ERROR.
  v-pack-gtin = mWorkSheet:Range("D" + vChLine):FORMULA NO-ERROR.
  if v-pack-gtin = ? then v-pack-gtin = mWorkSheet:Range("D" + vChLine):VALUE NO-ERROR.
  v-mark-code = mWorkSheet:Range("E" + vChLine):FORMULA NO-ERROR.
  if v-mark-code = ? then v-mark-code = mWorkSheet:Range("E" + vChLine):VALUE NO-ERROR.
  v-blok-b-code = mWorkSheet:Range("F" + vChLine):FORMULA NO-ERROR.
  if v-blok-b-code = ? then v-blok-b-code = mWorkSheet:Range("F" + vChLine):VALUE NO-ERROR.
  v-blok-gtin = mWorkSheet:Range("G" + vChLine):FORMULA NO-ERROR.
  if v-blok-gtin = ? then v-blok-gtin = mWorkSheet:Range("G" + vChLine):VALUE NO-ERROR.
  v-blok-mark-code = mWorkSheet:Range("H" + vChLine):FORMULA NO-ERROR.
  if v-blok-mark-code = ? then v-blok-mark-code = mWorkSheet:Range("H" + vChLine):VALUE NO-ERROR.
  v-koef = mWorkSheet:Range("I" + vChLine):FORMULA NO-ERROR.
  if v-koef = ? then v-koef = mWorkSheet:Range("I" + vChLine):VALUE NO-ERROR.
  if length(v-gds-name) > 0
  or length(v-b-code) > 0
  or length(v-pack-gtin) > 0
  or length(v-mark-code) > 0
  or length(v-blok-b-code) > 0
  or length(v-blok-gtin) > 0
  or length(v-blok-mark-code) > 0
  or length(v-koef) > 0
  then do :
    vNoLine = 0 .
  end.
  else do :
    vNoLine = vNoLine + 1.
    IF vNoLine > mMaxNoLine THEN LEAVE loopbl.
    ELSE NEXT loopbl.
  end.
  create tt-gds-gtin .
  tt-gds-gtin.gds-name    = v-gds-name .
  tt-gds-gtin.b-code      = v-b-code no-error .
  tt-gds-gtin.pack-gtin   = v-pack-gtin .
  tt-gds-gtin.mark-code   = v-mark-code .
  tt-gds-gtin.blok-b-code = v-blok-b-code no-error .
  tt-gds-gtin.blok-gtin   = v-blok-gtin .
  tt-gds-gtin.blok-mark-code = v-blok-mark-code .
  tt-gds-gtin.koef        = decimal(v-koef) no-error .
  release tt-gds-gtin .
end.
v-lines = 0 .
v-ok-lines = 0 .
v-err-file = v-imp-file + ".err" .
v-log-file = v-imp-file + ".log" .
output stream s-err to value(v-err-file).
output stream s-log to value(v-log-file).
for each tt-gds-gtin no-lock :
  v-lines = v-lines + 1 .
  do trans :
    find first buf_prod-bc no-lock where buf_prod-bc.b-str = tt-gds-gtin.b-code no-error.
    if not available buf_prod-bc
    then do :
      export stream s-err delimiter ";" tt-gds-gtin .
      put stream s-log unformatted "Не найден доп. код " tt-gds-gtin.b-code skip skip .
      next .
    end.
    find first buf_bar-code no-lock where buf_bar-code.b-code = buf_prod-bc.b-code no-error .
    if not available buf_bar-code
    then do :
      export stream s-err delimiter ";" tt-gds-gtin .
      put stream s-log unformatted "Не найден собственный бар-код для штрих-кода " tt-gds-gtin.b-code skip skip .
      next .
    end.
    find first buf_goods no-lock where buf_goods.gds-code = buf_bar-code.gds-code no-error.
    if not available buf_goods
    then do :
      export stream s-err delimiter ";" tt-gds-gtin .
      put stream s-log unformatted "Не найден товар с бар-кодом " string(buf_bar-code.b-code) " . Штрих-код - " tt-gds-gtin.b-code skip skip .
      next .
    end.
    find first goods-attr exclusive-lock where goods-attr.gds-code = buf_goods.gds-code
                                          and goods-attr.attr-code = 'mark-type':U
                                          no-error.
    if not available goods-attr
    then do :
      create goods-attr .
      assign
        goods-attr.gds-code = buf_goods.gds-code
        goods-attr.attr-code = 'mark-type':U
      .
    end.
    assign goods-attr.attr-value =  MarkType:tabak:nameprop.
    v-bar-code = buf_bar-code.b-code .
    v-b-str = tt-gds-gtin.pack-gtin .
    if trim(v-b-str) > ""
    then do :
      run trg/prod-bc2.p (
                          input parparentproc
                        ,input yes
                        ,input no
                        ,input yes
                        ,input no
                        ,input 'GTIN':U
                        ,input ''
                        ,buffer buf_goods
                        ,input v-bar-code
                        ,input no
                        ,input-output v-b-str
                        ,output v-bc-rid
                    ) no-error .
      if error-status :error
      or v-bc-rid = ?
      then do :
        export stream s-err delimiter ";" tt-gds-gtin .
        put stream s-log unformatted return-value skip skip .
        undo, next .
      end.
    end.
    v-b-str = tt-gds-gtin.mark-code .
    if trim(v-b-str) > ""
    then do :
      find first buf_prod-bc no-lock where buf_prod-bc.b-code = v-bar-code
                                       and buf_prod-bc.b-str = v-b-str
                                       no-error.
      if available buf_prod-bc
      then do :
        if buf_prod-bc.bc-on-type = 'GTIN':U
        then do :
          export stream s-err delimiter ";" tt-gds-gtin .
          put stream s-log unformatted "В системе уже есть код " v-b-str ", который является GTIN'ом. Его нельзя сделать маркированным." skip skip .
          undo, next .
        end.
        find first buf_prod-bc-attr exclusive-lock where buf_prod-bc-attr.b-str = buf_prod-bc.b-str
                                                     and buf_prod-bc-attr.b-code = buf_prod-bc.b-code
                                                     and buf_prod-bc-attr.attr-code = 'mark':U
                                                     no-error .
        if not available buf_prod-bc-attr
        then do :
          create buf_prod-bc-attr.
          assign
            buf_prod-bc-attr.b-str  = buf_prod-bc.b-str
            buf_prod-bc-attr.b-code = buf_prod-bc.b-code
            buf_prod-bc-attr.attr-code = 'mark':U
          .
        end.
        buf_prod-bc-attr.attr-value = "yes" .
      end.
      else do :
        run trg/prod-bc2.p (
                            input parparentproc
                          ,input yes
                          ,input no
                          ,input yes
                          ,input no
                          ,input ''
                          ,input ''
                          ,buffer buf_goods
                          ,input v-bar-code
                          ,input yes
                          ,input-output v-b-str
                          ,output v-bc-rid
                      ) no-error .
        if error-status :error
        or v-bc-rid = ?
        then do :
          export stream s-err delimiter ";" tt-gds-gtin .
          put stream s-log unformatted return-value skip skip .
          undo, next .
        end.
      end.
    end.
    if trim(tt-gds-gtin.blok-b-code) > ""
    or trim(tt-gds-gtin.blok-gtin) > ""
    or trim(tt-gds-gtin.blok-mark-code) > ""
    then do :
      integer(tt-gds-gtin.blok-b-code) no-error .
      if not error-status:error
      then do :
        find first bar-code no-lock where bar-code.b-code = integer(tt-gds-gtin.blok-b-code) no-error.
        if available bar-code
        then do :
          if bar-code.gds-code <> buf_goods.gds-code
          then do :
            export stream s-err delimiter ";" tt-gds-gtin .
            put stream s-log unformatted "Уже есть бар-код " string(tt-gds-gtin.blok-b-code) " для товара с кодом " string(bar-code.gds-code) skip skip .
            undo, next .
          end.
          if  bar-code.unit-cli = buf_units.unit-name
          and bar-code.cli-base-rate = tt-gds-gtin.koef
          then do :
            find first blok_bar-code no-lock where recid(blok_bar-code) = recid(bar-code) no-error .
          end.
        end.
      end.
      if not available blok_bar-code
      then do :
        find first prod-bc no-lock where prod-bc.b-str = tt-gds-gtin.blok-b-code no-error.
        if available prod-bc
        then do :
          find first blok_bar-code no-lock where blok_bar-code.b-code = prod-bc.b-code
                                             and blok_bar-code.gds-code = buf_goods.gds-code
                                             and blok_bar-code.unit-cli = buf_units.unit-name
                                             and blok_bar-code.cli-base-rate = tt-gds-gtin.koef
                                             no-error .
        end.
      end.
      if not available blok_bar-code
      then do :
        find first blok_bar-code no-lock where blok_bar-code.gds-code = buf_goods.gds-code
                                           and blok_bar-code.unit-cli = buf_units.unit-name
                                           and blok_bar-code.cli-base-rate = tt-gds-gtin.koef
                                           no-error .
      end.
      if not available blok_bar-code
      then do :
        find first blok_bar-code no-lock where blok_bar-code.gds-code = buf_goods.gds-code
                                           and blok_bar-code.unit-cli = buf_units.unit-name
                                           no-error .
        if available blok_bar-code and blok_bar-code.cli-base-rate <> tt-gds-gtin.koef
        then do :
          export stream s-err delimiter ";" tt-gds-gtin .
          put stream s-log unformatted "Товар " string(buf_goods.gds-code) "  " buf_goods.gds-name " . Коэффициент для блока в файле не равен коэффициенту в TH." skip skip .
          undo, next .
        end.
      end.
      if not available blok_bar-code
      then do :
        find gds-prt no-lock where gds-prt.node-code = buf_bar-code.node-code .
        run ref/barcode1.p (
                           input 'ДОБАВЛЕНИЕ':U
                          ,input yes
                          ,input 0
                          ,input buf_goods.gds-code
                          ,input gds-prt.node-code
                          ,input buf_bar-code.part-code
                          ,input buf_bar-code.in-code
                          ,input buf_units.unit-name
                          ,input tt-gds-gtin.koef
                          ,output v-bc-rid) no-error.
        if error-status :error
        then do :
          export stream s-err delimiter ";" tt-gds-gtin .
          put stream s-log unformatted return-value skip skip .
          undo, next .
        end.
        find first blok_bar-code no-lock where recid(blok_bar-code) = v-bc-rid no-error .
        if not available blok_bar-code
        then do :
          export stream s-err delimiter ";" tt-gds-gtin .
          put stream s-log unformatted return-value skip skip .
          undo, next .
        end.
      end.
      v-bar-code = blok_bar-code.b-code .
      v-b-str = tt-gds-gtin.blok-b-code .
      if trim(v-b-str) > ""
      then do :
        run trg/prod-bc2.p (
                            input parparentproc
                          ,input yes
                          ,input no
                          ,input yes
                          ,input no
                          ,input ''
                          ,input ''
                          ,buffer buf_goods
                          ,input v-bar-code
                          ,input no
                          ,input-output v-b-str
                          ,output v-bc-rid
                      ) no-error .
        if error-status :error
        or v-bc-rid = ?
        then do :
          export stream s-err delimiter ";" tt-gds-gtin .
          put stream s-log unformatted return-value skip skip .
          undo, next .
        end.
      end.
      v-b-str = tt-gds-gtin.blok-gtin .
      if trim(v-b-str) > ""
      then do :
        find first prod-bc no-lock where prod-bc.b-str = v-b-str no-error .
        if available prod-bc
        then do :
          find first bar-code no-lock where bar-code.b-code = prod-bc.b-code no-error.
          if not available bar-code
          then do :
            export stream s-err delimiter ";" tt-gds-gtin .
            put stream s-log unformatted return-value skip skip .
            undo, next .
          end.
          if bar-code.gds-code <> buf_goods.gds-code
          then do :
            export stream s-err delimiter ";" tt-gds-gtin .
            put stream s-log unformatted "Товар " string(buf_goods.gds-code) "  " buf_goods.gds-name " уже есть доп. код " v-b-str " и он относится к другому товару - " string(bar-code.gds-code) skip skip .
            undo, next .
          end.
          if prod-bc.bc-on-type <> 'GTIN':U
          then do :
            export stream s-err delimiter ";" tt-gds-gtin .
            put stream s-log unformatted "Товар " string(buf_goods.gds-code) "  " buf_goods.gds-name " уже есть доп. код " v-b-str " и его тип не GTIN" skip skip .
            undo, next .
          end.
        end.
        else do :
          run trg/prod-bc2.p (
                              input parparentproc
                            ,input yes
                            ,input no
                            ,input yes
                            ,input no
                            ,input 'GTIN':U
                            ,input ''
                            ,buffer buf_goods
                            ,input v-bar-code
                            ,input no
                            ,input-output v-b-str
                            ,output v-bc-rid
                        ) no-error .
          if error-status :error
          or v-bc-rid = ?
          then do :
            export stream s-err delimiter ";" tt-gds-gtin .
            put stream s-log unformatted return-value skip skip .
            undo, next .
          end.
        end.
      end.
      v-b-str = tt-gds-gtin.blok-mark-code .
      if trim(v-b-str) > ""
      then do :
        find first buf_prod-bc no-lock where buf_prod-bc.b-code = v-bar-code
                                         and buf_prod-bc.b-str = v-b-str
                                         no-error.
        if available buf_prod-bc
        then do :
          find first buf_prod-bc-attr exclusive-lock where buf_prod-bc-attr.b-str = buf_prod-bc.b-str
                                                       and buf_prod-bc-attr.b-code = buf_prod-bc.b-code
                                                       and buf_prod-bc-attr.attr-code = 'mark':U
                                                       no-error .
          if not available buf_prod-bc-attr
          then do :
            create buf_prod-bc-attr.
            assign
              buf_prod-bc-attr.b-str  = buf_prod-bc.b-str
              buf_prod-bc-attr.b-code = buf_prod-bc.b-code
              buf_prod-bc-attr.attr-code = 'mark':U
            .
          end.
          buf_prod-bc-attr.attr-value = "yes" .
        end.
        else do :
          run trg/prod-bc2.p (
                              input parparentproc
                            ,input yes
                            ,input no
                            ,input yes
                            ,input no
                            ,input ''
                            ,input ''
                            ,buffer buf_goods
                            ,input v-bar-code
                            ,input yes
                            ,input-output v-b-str
                            ,output v-bc-rid
                        ) no-error .
          if error-status :error
          or v-bc-rid = ?
          then do :
            export stream s-err delimiter ";" tt-gds-gtin .
            put stream s-log unformatted return-value skip skip .
            undo, next .
          end.
        end.
      end.
    end.
    v-ok-lines = v-ok-lines + 1 .
  end.
end.
output stream s-err close .
output stream s-log close .
run waitfram-hide in this-procedure .
message "Готово. Обработано " string(v-lines) " строк. Загружено " string(v-ok-lines) "." skip
        "Незагруженные коды в файле " v-err-file skip
        "Ошибки в файле " v-log-file view-as alert-box information .
