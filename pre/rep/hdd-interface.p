using ibs.th.str.*.
block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: 968516208b7e, 2374, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Ср июн 10 21:13:42 2020 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: hdd-interface.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/hdd-interface.p $":U .
define variable vss-description as character no-undo init "Результаты проверки HDD".
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
define input parameter parparentproc    as widget-handle           no-undo.
define input parameter p-namePk as character no-undo .
define input parameter p-ModelDisk as character no-undo .
define input parameter p-status as integer no-undo .
define input parameter p-ProcDisk as integer no-undo .
define input parameter p-UserDisk as integer no-undo .
define input parameter p-Date     as date no-undo .
define input parameter p-Time     as integer no-undo .
define input parameter p-Time-end as integer no-undo .
define input parameter p-db-list  as character no-undo .
define input parameter p-ValueDisk  as decimal no-undo .
define input parameter p-TreshDisk  as decimal no-undo .
define input parameter p-Delta    as decimal no-undo .
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define  shared variable RepPathName        as character no-undo .
define  shared variable PrintRubl          as logical   no-undo .
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxp-doc-prt         like ub.store.doc-prt         no-undo.
  define variable v-cntxp-price-calc      like ub.store.price-calc      no-undo.
  define variable v-cntxp-inout-price     like ub.store.inout-price     no-undo.
  define variable v-cntxp-unit-cli-perm   like ub.store.unit-cli-perm   no-undo.
  define variable v-cntxp-out-rate        like ub.store.out-rate        no-undo.
  define variable v-cntxp-out-line-discnt like ub.store.out-line-discnt no-undo.
  define variable v-cntxp-in-ov           like ub.store.in-ov           no-undo.
  define variable v-cntxp-in-perm         like ub.store.in-perm         no-undo.
  define variable v-cntxp-no-eq           like ub.store.no-eq           no-undo.
  define variable v-cntxp-rsrv-time       like ub.store.rsrv-time       no-undo.
  define variable v-cntxp-load-time       like ub.store.load-time       no-undo.
  define variable v-cntxp-holidays        like ub.store.holidays        no-undo.
  define variable v-cntxp-in-pay          like ub.store.in-pay          no-undo.
  define variable v-cntxp-out-pay         like ub.store.out-pay         no-undo.
  define variable v-cntxp-ret-pay         like ub.store.ret-pay         no-undo.
  define variable v-cntxp-ret-sup-pay     like ub.store.ret-sup-pay     no-undo.
  define variable v-cntxp-down-pay        like ub.store.down-pay        no-undo.
  define variable v-cntxp-inv-pay         like ub.store.inv-pay         no-undo.
  define variable v-cntxp-chk-pay         like ub.store.chk-pay         no-undo.
  define variable v-cntxp-retail          like ub.sysconf.ord-prt       no-undo.
  define variable v-cntxp-osn-base        like ub.sysconf.osn-base      no-undo.
  define variable v-cntxp-conf-par        as   character                no-undo.
  define variable v-cntxp-par-type        as   character                no-undo.
  define variable v-cntxp-curr-host-code  like ub.store.host-code       no-undo.
  define variable v-cntxp-obj-type        like ub.clients.obj-type      no-undo.
  define variable v-cntxp-obj-code        like ub.clients.obj-code      no-undo.
  define variable v-cntxp-db-num          as integer   no-undo .
  define variable v-cntxp-userid          as character no-undo .
  define variable v-cntxp-level           as character no-undo .
  define variable v-cntxp-db-num-obj      as integer   no-undo .
  define variable v-cntxp-is-admin        as logical   no-undo .
  define buffer bf-cntxp_store for ub.store.
  define buffer bf-cntxp_shop  for ub.shop.
  define buffer bf-cntxp_sysconf for ub.sysconf.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in parparentproc
    (output v-cntxp-db-num
    ,output v-cntxp-userid
    ,output v-cntxp-level
    ,output v-cntxp-curr-host-code
    ,output v-cntxp-obj-type
    ,output v-cntxp-obj-code
    ,output v-cntxp-db-num-obj
    ,output v-cntxp-is-admin
    ) .
  if (v-cntxp-obj-type = 'маг':U or v-cntxp-obj-type = 'скл':U) and
     v-cntxp-obj-code <> 0 then do:
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-prt'
  ,input  0
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  yes
  ,output v-cntxp-conf-par
  ,output v-cntxp-par-type
  ) no-error .
    case v-cntxp-obj-type :
      when 'скл':U then do:
        find first bf-cntxp_store where bf-cntxp_store.obj-code = v-cntxp-obj-code no-lock.
        find first bf-cntxp_sysconf where bf-cntxp_sysconf.host-code = bf-cntxp_store.host-code no-lock.
        assign
          v-cntxp-doc-prt         = (v-cntxp-conf-par = "yes") and bf-cntxp_store.doc-prt
          v-cntxp-price-calc      = bf-cntxp_store.price-calc
          v-cntxp-inout-price     = bf-cntxp_store.inout-price
          v-cntxp-unit-cli-perm   = bf-cntxp_store.unit-cli-perm
          v-cntxp-out-rate        = bf-cntxp_store.out-rate
          v-cntxp-out-line-discnt = bf-cntxp_store.out-line-discnt
          v-cntxp-in-ov           = bf-cntxp_store.in-ov
          v-cntxp-in-perm         = bf-cntxp_store.in-perm
          v-cntxp-no-eq           = bf-cntxp_store.no-eq
          v-cntxp-rsrv-time       = bf-cntxp_store.rsrv-time
          v-cntxp-load-time       = bf-cntxp_store.load-time
          v-cntxp-holidays        = bf-cntxp_store.holidays
          v-cntxp-in-pay          = bf-cntxp_store.in-pay
          v-cntxp-out-pay         = bf-cntxp_store.out-pay
          v-cntxp-ret-pay         = bf-cntxp_store.ret-pay
          v-cntxp-ret-sup-pay     = bf-cntxp_store.ret-sup-pay
          v-cntxp-down-pay        = bf-cntxp_store.down-pay
          v-cntxp-inv-pay         = bf-cntxp_store.inv-pay
          v-cntxp-chk-pay         = bf-cntxp_store.chk-pay
          v-cntxp-retail          = bf-cntxp_sysconf.ord-prt
          v-cntxp-osn-base        = bf-cntxp_sysconf.osn-base
          .
      end.
      when 'маг':U then do:
        find first bf-cntxp_shop where bf-cntxp_shop.obj-code = v-cntxp-obj-code no-lock.
        find first bf-cntxp_sysconf where bf-cntxp_sysconf.host-code = bf-cntxp_shop.host-code no-lock.
        assign
          v-cntxp-doc-prt         = (v-cntxp-conf-par = "yes") and bf-cntxp_shop.doc-prt
          v-cntxp-price-calc      = bf-cntxp_shop.price-calc
          v-cntxp-inout-price     = bf-cntxp_shop.inout-price
          v-cntxp-unit-cli-perm   = bf-cntxp_shop.unit-cli-perm
          v-cntxp-out-rate        = bf-cntxp_shop.out-rate
          v-cntxp-out-line-discnt = bf-cntxp_shop.out-line-discnt
          v-cntxp-in-ov           = bf-cntxp_shop.in-ov
          v-cntxp-in-perm         = bf-cntxp_shop.in-perm
          v-cntxp-no-eq           = bf-cntxp_shop.no-eq
          v-cntxp-rsrv-time       = bf-cntxp_shop.rsrv-time
          v-cntxp-load-time       = bf-cntxp_shop.load-time
          v-cntxp-holidays        = bf-cntxp_shop.holidays
          v-cntxp-in-pay          = bf-cntxp_shop.in-pay
          v-cntxp-out-pay         = bf-cntxp_shop.out-pay
          v-cntxp-ret-pay         = bf-cntxp_shop.ret-pay
          v-cntxp-ret-sup-pay     = bf-cntxp_shop.ret-sup-pay
          v-cntxp-down-pay        = bf-cntxp_shop.down-pay
          v-cntxp-inv-pay         = bf-cntxp_shop.inv-pay
          v-cntxp-chk-pay         = bf-cntxp_shop.chk-pay
          v-cntxp-retail          = bf-cntxp_sysconf.ord-prt
          v-cntxp-osn-base        = bf-cntxp_sysconf.osn-base
          .
      end.
    end case.
  end.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  stream PrnLibStream.
procedure prn-lib-prn-file :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-DIsabledoptions as integer no-undo .
  define variable v-report-name as character no-undo .
  define variable v-user-action as character no-undo .
  define variable v-printed     as logical   no-undo .
  define variable v-exist       as logical   no-undo .
  do
    on error undo, return error
    :
    run prn-lib-get-report-name  in this-procedure (
      input parParentProc
      ,output v-report-name
      ).
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run filenmln in g#library
  (input  v-report-name
  ,input  2
  ,output v-exist
  )  .
    if NOT v-exist then
    DO:
      Message
        "Нет заданий на печать ! "
        view-as alert-box .
      Return  .
    End.
    run gbl/prnfilen.w
      (input  ""
      ,input  p-DisabledOptions
      ,input  string(v-report-name )
      ,input  7
      ,output v-user-action
      ,output v-printed
      ) .
    if v-printed then
    do:
      return "YES" .
    end.
    else
    do:
      return "NO" .
    end.
  end.
end procedure.
procedure prn-lib-open-stream :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-page-size    as integer no-undo .
  define input parameter p-is-stream    as logical no-undo .
  define input parameter p-append       as logical no-undo .
  define variable v-report-name as character no-undo .
  do
    on error undo, return error
    :
    run prn-lib-get-report-name  in this-procedure (
      input parParentProc
      ,output v-report-name
      ).
    if p-is-stream then
    do:
      if p-append then
      do:
        output stream PrnLibStream to value( v-report-name )
          page-size value(p-page-size) append .
      end.
      if not p-append then
      do:
        output stream PrnLibStream to value( v-report-name )
          page-size value(p-page-size) .
      end.
    end.
    if not p-is-stream then
    do:
      if p-append then
      do:
        output to value( v-report-name )
          page-size value(p-page-size) append .
      end.
      if not p-append then
      do:
        output to value( v-report-name )
          page-size value(p-page-size) .
      end.
    end.
  end.
end procedure.
procedure prn-lib-open-exp :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-is-stream    as logical no-undo .
  define input parameter p-is-append    as logical no-undo .
  define output parameter p-ReportFileName as char init "report" no-undo.
  define output parameter p-process as logical no-undo .
  define variable glog as logical no-undo .
  do
    on error undo, return error
    :
    SYSTEM-DIALOG GET-FILE p-ReportFileName
      TITLE      "Укажите путь"
      FILTERS "Текстовый файл (*.txt)"   "*.txt"
      ASK-OVERWRITE
      CREATE-TEST-FILE
      SAVE-AS
      USE-FILENAME
      DEFAULT-EXTENSION "txt"
      UPDATE glog
      .
    if not glog then  return.
    p-ReportFileName = trim( string( p-ReportFileName ) ) .
    if p-is-stream then
    do:
      if p-is-append then
      do:
        OUTPUT stream PrnLibStream TO value ( p-ReportFileName ) PAGE-SIZE 0 append.
      end.
      else
      do:
        OUTPUT stream PrnLibStream TO value ( p-ReportFileName ) PAGE-SIZE 0.
      end.
    end.
    else
    do:
      if p-is-append then
      do:
        OUTPUT TO value ( p-ReportFileName ) PAGE-SIZE 0 append.
      end.
      else
      do:
        OUTPUT TO value ( p-ReportFileName ) PAGE-SIZE 0.
      end.
    end.
    p-process = yes.
  end.
end procedure.
procedure prn-lib-get-report-name :
  define input parameter parParentProc  as widget-handle no-undo.
  define output parameter p-report-name as character no-undo .
  p-report-name = ibs.th.gbl.gbl-inipar:prn-lib-get-report-name("rpt").
end procedure.
procedure prn-lib-reportviewer-report-name :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-report-name-html as character no-undo .
  ibs.th.gbl.gbl-inipar:prn-lib-reportviewer-report-name(p-report-name-html) no-error.
end procedure.
procedure prn-lib-reportviewer :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-report-name-html as character no-undo .
  define input parameter p-param        as character no-undo .
  define variable v-excel           as character no-undo init 'TRUE' .
  define variable v-value-character as character no-undo .
  define variable v-value-integer   as character no-undo .
  define variable v-value-date      as date      no-undo .
  define variable v-value-decimal   as decimal   no-undo .
  define variable rep-excel         as logical   no-undo .
  define variable excel-string      as character no-undo .
  define variable v-param-type      as character no-undo .
  define variable v-tth             as handle    no-undo .
  run adm/shattri.p (
    input "get":U
    ,input  ""
    ,input  0
    ,input  'report-glob':U
    ,input  'rep-excel':U
    ,output v-value-character
    ,output v-value-date
    ,output v-value-decimal
    ,output v-value-integer
    ,output rep-excel
    ,output v-param-type
    ,INPUT-OUTPUT table-handle v-tth
    )  .
  if rep-excel then v-excel = "TRUE" .
  else v-excel = "FALSE" .
  if p-param eq ""
  then
     p-param = "EXCEL:" + v-excel.
  else
     p-param = p-param + chr(4) + "EXCEL:" + v-excel .
  ibs.th.gbl.gbl-inipar:prn-lib-reportviewer(p-report-name-html, p-param).
end procedure.
function fnc-convert-dot-to-colon returns character
    (input p-data as decimal, input p-accur as character, input p-num as integer) forward.
function fnc-convert-dot-to-colon returns character
(input p-data as decimal, input p-accur as character, input p-num as integer):
    define variable result as character no-undo.
    define variable v-str-result as character no-undo.
    if p-data = ? then p-data = 0 .
    p-data = round(p-data, p-num).
    v-str-result = trim(replace(string(p-data, p-accur), ".", ",")).
    return v-str-result.
END FUNCTION.
define temp-table tt-devicePC no-undo
  field id          as integer
  field modeldevice like ub.devisPC.modeldevice
  field ModelPC     like ub.devisPC.ModelPC
  field namepc      like ub.devisPC.namepc
  field date_       as date
  field time_       as character
  field time_int    as integer
  field ProcDisk    as decimal
  field UserProc    as decimal
  field status_     as character
  field db-num      as integer
  index pi id date_ time_int db-num.
define temp-table tt-devicePCAttr no-undo
  field id        as integer
  field name_     as character
  field value_    as decimal
  field tresh     as decimal
  field type_     as character
  field raw_value as character
  field date_     as date
  field time_     as integer
  field db-num    as integer
  index pi id db-num date_ time_
  .
define buffer buf_devisPC      for ub.devisPC .
define buffer buf_devisPCAttr  for ub.devisPC-attr .
define buffer bf_devisPCAttr   for ub.devisPC-attr .
define buffer bt_devisPCAttr   for ub.devisPC-attr .
define buffer buf_devisPC-attr for ub.devisPC-attr .
define variable v-ProcDisk   as decimal   no-undo .
define variable v-UserDisk   as decimal   no-undo .
define variable v-TestStatus as character no-undo .
define variable v-Date       as decimal   no-undo .
define stream Out-Stream.
define stream OutStr-html.
define VARIABLE p-report-id         as character no-undo .
define variable v-file-name-rep-htm as character no-undo .
define variable ii                  as integer   no-undo .
define variable v-TimeST            as character no-undo .
define variable v-TimeST1           as character no-undo .
define variable v-TimeST-attr       as character no-undo .
define variable v-TimeST1-attr      as character no-undo .
define variable v-titul             as character no-undo .
define variable v-color             as character no-undo .
do
  on error undo, return error return-value
  :
  if p-db-list = "" then p-db-list = string(v-cntxp-db-num) .
  do ii = 1 to num-entries (p-db-list, chr(44)):
    for each buf_devisPC no-lock where buf_devisPC.DB-num = integer(entry(ii, p-db-list, chr(44))):
      if buf_devisPC.namepc begins p-namePk and buf_devisPC.modeldevice begins p-ModelDisk then
      do:
        next_:
        for each buf_devisPCAttr no-lock where buf_devisPCAttr.id = buf_devisPC.id and buf_devisPCAttr.db-num = buf_devisPC.db-num and buf_devisPCAttr.date >= p-Date:
          if buf_devisPCAttr.time_ < p-Time then next next_.
          if buf_devisPCAttr.time_ > p-Time-end then next next_.
          if buf_devisPCattr.attr-code ="ProcDisk" or buf_devisPCattr.attr-code = "UserProc" or buf_devisPCattr.attr-code = "testStatus" then
          do:
            v-ProcDisk = 0 .
            v-UserDisk = 0 .
            v-TestStatus = "" .
            if buf_devisPCAttr.attr-code = "ProcDisk" then
            do:
              v-ProcDisk = decimal(entry(1,buf_devisPCAttr.attr-value,"%")) .
            end.
            if buf_devisPCAttr.attr-code = "UserProc" then
            do:
              v-UserDisk = decimal(entry(1,buf_devisPCAttr.attr-value,"%")) .
            end.
            if buf_devisPCAttr.attr-code = "TestStatus" then
            do:
              v-TestStatus = buf_devisPCAttr.attr-value .
            end.
            find first tt-devicePC exclusive-lock where tt-devicePC.id = buf_devisPC.id and tt-devicePC.modeldevice = buf_devisPC.modeldevice
              and tt-devicePC.ModelPC     = buf_devisPC.ModelPC and
              tt-devicePC.namepc      = buf_devisPC.namepc and
              tt-devicePC.date_       = buf_devisPCAttr.date and
              tt-devicePC.db-num      = buf_devisPC.DB-num and
              tt-devicePC.time_int  = buf_devisPCAttr.time_
              no-error .
            if not available (tt-devicePC) then
            do:
              create tt-devicePC .
              assign
                tt-devicePC.id          = buf_devisPC.id
                tt-devicePC.modeldevice = buf_devisPC.modeldevice
                tt-devicePC.ModelPC     = buf_devisPC.ModelPC
                tt-devicePC.namepc      = buf_devisPC.namepc
                tt-devicePC.date_       = buf_devisPCAttr.date
                tt-devicePC.time_int    = buf_devisPCAttr.time_
                tt-devicePC.db-num      = buf_devisPC.DB-num
                tt-devicePC.time_       = string(truncate (buf_devisPCattr.time_ / 3600, 0)) + ":" + string((buf_devisPCattr.time_ modulo 3600) / 60,"99") + ":" + string((buf_devisPCattr.time_ modulo 3600) / 360,"99")
                .
            end.
            if v-ProcDisk <> 0 then tt-devicePC.ProcDisk    = v-ProcDisk .
            if v-UserDisk <> 0 then tt-devicePC.UserProc    = v-UserDisk .
            if v-TestStatus <> "" then tt-devicePC.status_  = v-TestStatus .
          end.
          else
          do:
            find first tt-devicePCAttr where           tt-devicePCAttr.id        = buf_devisPCattr.id and
              tt-devicePCAttr.name_     = buf_devisPCattr.attr-code and
              tt-devicePCAttr.raw_value = buf_devisPCattr.attr-Raw-value and
              tt-devicePCAttr.tresh     = decimal(buf_devisPCattr.tresh) and
              tt-devicePCAttr.value_    = decimal(buf_devisPCattr.attr-value) and
              tt-devicePCAttr.type_     = buf_devisPCattr.type and
              tt-devicePCAttr.date_     = buf_devisPCattr.date and
              tt-devicePCAttr.db-num    = buf_devisPC.DB-num and
              tt-devicePCAttr.time_     = buf_devisPCattr.time_ no-error .
            if not available (tt-devicePCAttr) then
            do:
              create tt-devicePCAttr .
              assign
                tt-devicePCAttr.id        = buf_devisPCattr.id
                tt-devicePCAttr.name_     = buf_devisPCattr.attr-code
                tt-devicePCAttr.raw_value = buf_devisPCattr.attr-Raw-value
                tt-devicePCAttr.tresh     = decimal(buf_devisPCattr.tresh)
                tt-devicePCAttr.value_    = decimal(buf_devisPCattr.attr-value)
                tt-devicePCAttr.type_     = buf_devisPCattr.type
                tt-devicePCAttr.db-num    = buf_devisPC.DB-num
                tt-devicePCAttr.date_     = buf_devisPCattr.date
                tt-devicePCAttr.time_     = buf_devisPCattr.time_
                .
            end.
          end.
        end.
      end.
    end.
  end.
  if p-ProcDisk > 0 then
  do:
    for each tt-devicePC exclusive-lock where tt-devicePC.ProcDisk < p-ProcDisk:
      delete tt-devicePC .
    end.
  end.
  if p-UserDisk > 0 then
  do:
    for each tt-devicePC exclusive-lock where tt-devicePC.UserProc < p-UserDisk:
      delete tt-devicePC .
    end.
  end.
    case p-status:
    when 0 then
    do:
        for each tt-devicePC exclusive-lock where tt-devicePC.status_ <> "Пройдена":
          delete tt-devicePC .
        end.
    end.
    when 1 then
      do:
        for each tt-devicePC exclusive-lock where tt-devicePC.status_ <> "Не пройдена":
          delete tt-devicePC .
        end.
    end.
    when 2 then do:
        for each tt-devicePC exclusive-lock where tt-devicePC.status_ = "Пройдена" or tt-devicePC.status_ = "Не пройдена":
          delete tt-devicePC .
        end.
      end.
    end case .
  if p-ValueDisk > 0 then
  do:
    for each tt-devicePCAttr where tt-devicePCAttr.value_ < p-ValueDisk:
      delete tt-devicePCAttr .
    end.
  end.
  if p-TreshDisk > 0 then
  do:
    for each tt-devicePCAttr where tt-devicePCAttr.tresh < p-TreshDisk:
      delete tt-devicePCAttr .
    end.
  end.
  if p-Delta > 0 then
  do:
    for each tt-devicePCAttr where abs(tt-devicePCAttr.value_ - tt-devicePCAttr.tresh) > p-Delta:
      delete tt-devicePCAttr .
    end.
  end.
  for each tt-devicePC:
    find first tt-devicePCAttr where tt-devicePCAttr.id = tt-devicePC.id and tt-devicePCAttr.db-num = tt-devicePC.db-num and tt-devicePCAttr.date_ = tt-devicePC.date_ and tt-devicePCAttr.time_ = tt-devicePC.time_int no-error .
    if not available (tt-devicePCAttr) then
    do:
      if tt-devicePC.status_ = "не закончена" then do:
        create tt-devicePCAttr.
        assign
        tt-devicePCAttr.date_ = tt-devicePC.date_
        tt-devicePCAttr.time_ = tt-devicePC.time_int
        tt-devicePCAttr.db-num  = tt-devicePC.db-num
        tt-devicePCAttr.id = tt-devicePC.id
        .
      end.
      else do:
      delete tt-devicePC .
      end.
    end.
  end.
  run get-report-num (output p-report-id).
  v-file-name-rep-htm = session:temp-directory + string(p-report-id) + ".html".
  output stream OutStr-html to value(v-file-name-rep-htm) convert target 'UTF-8'.
  put stream OutStr-html unformatted
    "<!DOCTYPE HTML>" skip
    ' <html>' skip
    '  <head>' skip
    '   <meta charset="utf-8">' skip
    '    <style type="text/css">' skip
    '      table ' + chr(123) + ' border-collapse: collapse; ' + chr(125) skip
    '      .class1 ' + chr(123) + ' border-collapse: collapse; ' + chr(125) skip
    '      tbody td, th ' + chr(123) + ' border-collapse: collapse; border: 1px solid black; height: 14px;' + chr(125) skip
    '   </style>' skip
    '  </head>' skip
    .
  put stream OutStr-html unformatted
    '<body>' skip
    '<TABLE name="1"  fit_to_page="true" orientation="portrait" CELLSPACING="0" BORDER="0">'skip
    '<thead>' skip
    .
  put stream OutStr-html unformatted
    '<tr>' skip
    '<td style="width: 50px;"></td>' skip
    '<td style="width: 70px;"></td>' skip
    '<td style="width: 70px;"></td>' skip
    '<td style="width: 70px;"></td>' skip
    '<td style="width: 70px;"></td>' skip
    '<td style="width: 70px;"></td>' skip
    '<td style="width: 60px;"></td>' skip
    '<td style="width: 60px;"></td>' skip
    '<td style="width: 80px;"></td>' skip
    '<td style="width: 170px;"></td>' skip
    '<td style="width: 50px;"></td>' skip
    '<td style="width: 50px;"></td>' skip
    '<td style="width: 70px;"></td>' skip
    '<td style="width: 70px;"></td>' skip
    '</tr>' skip
    '<tr><td colspan="14" style="text-align: center;">Результаты проверки HDD</td></tr>'
    .
  put stream OutStr-html unformatted
    '<TR><TD colspan="14"></TD></TR>' skip
    '</thead>' skip
    '<tbody>' skip
    .
  put stream OutStr-html unformatted
    '<TR>' skip
    '<TD text_wrap="true" rowspan="2" style="text-align: center;">АЗК</TD>' skip
    '<TD text_wrap="true" rowspan="2" style="text-align: center;">Дата теста</TD>' skip
    '<TD text_wrap="true" rowspan="2" style="text-align: center;">Время теста</TD>' skip
    '<TD text_wrap="true" rowspan="2" style="text-align: center;">Имя ПК</TD>' skip
    '<TD text_wrap="true" rowspan="2" style="text-align: center;">Модель ПК</TD>' skip
    '<TD text_wrap="true" rowspan="2" style="text-align: center;">Модель диска</TD>' skip
    '<TD text_wrap="true" rowspan="2" style="text-align: center;">Процент заполнения</TD>' skip
    '<TD text_wrap="true" rowspan="2" style="text-align: center;">Использование системного раздела</TD>' skip
    '<TD text_wrap="true" rowspan="2" style="text-align: center;">Статус проверки</TD>' skip
    '<TD text_wrap="true" colspan="5" style="text-align: center;">Атрибуты диска</TD>' skip
    '</TR>' skip .
  put stream OutStr-html unformatted
    '<TR>' skip
    '<TD text_wrap="true" style="text-align: center;">Название</TD>' skip
    '<TD text_wrap="true" style="text-align: center;">Value</TD>' skip
    '<TD text_wrap="true" style="text-align: center;">Thresh</TD>' skip
    '<TD text_wrap="true" style="text-align: center;">Тип</TD>' skip
    '<TD text_wrap="true" style="text-align: center;">Raw_value</TD>' skip
    '</TR>'skip
    .
  for each tt-devicePC:
    if tt-devicePC.ProcDisk = 100 or tt-devicePC.UserProc = 100 or tt-devicePC.status_ <> "Пройдена" then v-color = "red" .
    else v-color = "white" .
    put stream OutStr-html unformatted
      '<TR>' skip
      '<TD text_wrap="true" style="text-align: center; background-color:' + v-color + ';">' + string(tt-devicePC.db-num) + '</TD>' skip
      '<TD text_wrap="true" style="text-align: center; background-color:' + v-color + ';">' + string(tt-devicePC.date_) + '</TD>' skip
      '<TD text_wrap="true" style="text-align: center; background-color:' + v-color + ';">' + string(tt-devicePC.time_) + '</TD>' skip
      '<TD text_wrap="true" style="text-align: center; background-color:' + v-color + ';">' + string (tt-devicePC.namepc) + '</TD>' skip
      '<TD text_wrap="true" style="text-align: center; background-color:' + v-color + ';">' + string (tt-devicePC.ModelPC) + '</TD>' skip
      '<TD text_wrap="true" style="text-align: center; background-color:' + v-color + ';">' + string (tt-devicePC.modeldevice) + '</TD>' skip
      '<TD text_wrap="true" style="text-align: center; background-color:' + v-color + ';">' + string (tt-devicePC.ProcDisk) + '</TD>' skip
      '<TD text_wrap="true" style="text-align: center; background-color:' + v-color + ';">' + string (tt-devicePC.UserProc) + '</TD>' skip
      '<TD text_wrap="true" style="text-align: center; background-color:' + v-color + ';">' + string (tt-devicePC.status_) + '</TD>' skip
      .
    for each tt-devicePCAttr no-lock where tt-devicePCAttr.id = tt-devicePC.id and tt-devicePCAttr.db-num = tt-devicePC.db-num and tt-devicePCAttr.date_ = tt-devicePC.date_
    and tt-devicePCAttr.time_ = tt-devicePC.time_int break by tt-devicePCAttr.id :
      if tt-devicePCAttr.value_ <= tt-devicePCAttr.tresh then v-color = "red" .
      else v-color = "white" .
      if first-of (tt-devicePCAttr.id ) then
      do:
        put stream OutStr-html unformatted
          '<TD text_wrap="true" style="text-align: center; background-color:' + v-color + ';">' + string (tt-devicePCAttr.name_) + '</TD>' skip
          '<TD text_wrap="true" style="text-align: center; background-color:' + v-color + ';">' + string (tt-devicePCAttr.value_) + '</TD>' skip
          '<TD text_wrap="true" style="text-align: center; background-color:' + v-color + ';">' + string (tt-devicePCAttr.tresh) + '</TD>' skip
          '<TD text_wrap="true" style="text-align: center; background-color:' + v-color + ';">' + string (tt-devicePCAttr.type_) + '</TD>' skip
          '<TD text_wrap="true" style="text-align: center; background-color:' + v-color + ';">' + string (tt-devicePCAttr.raw_value) + '</TD>' skip
          '</tr>'
          .
      end.
      else
      do:
        put stream OutStr-html unformatted
          '<TR>' skip
          '<TD text_wrap="true" colspan="9" style="text-align: center;"></TD>' skip
          '<TD text_wrap="true" style="text-align: center; background-color:' + v-color + ';">' + string (tt-devicePCAttr.name_) + '</TD>' skip
          '<TD text_wrap="true" style="text-align: center; background-color:' + v-color + ';">' + string (tt-devicePCAttr.value_) + '</TD>' skip
          '<TD text_wrap="true" style="text-align: center; background-color:' + v-color + ';">' + string (tt-devicePCAttr.tresh) + '</TD>' skip
          '<TD text_wrap="true" style="text-align: center; background-color:' + v-color + ';">' + string (tt-devicePCAttr.type_) + '</TD>' skip
          '<TD text_wrap="true" style="text-align: center; background-color:' + v-color + ';">' + string (tt-devicePCAttr.raw_value) + '</TD>' skip
          '</tr>'
          .
      end.
    end.
  end.
  put stream OutStr-html unformatted
    '</tbody>' skip
    '<tfoot>' skip.
  put stream OutStr-html unformatted
    '</tfoot>' skip
    '</table>' skip
    '</body>' skip
    '</html>' skip
    .
  output stream OutStr-html close.
  run prn-lib-reportviewer-report-name in this-procedure (
    input THIS-PROCEDURE
    ,input v-file-name-rep-htm
    ).
end.
PROCEDURE get-report-num :
  define output parameter p-report-num as integer no-undo .
  do
    on error undo, return error return-value
    :
    run gbl/getrpnum.p (output p-report-num).
  end.
END PROCEDURE.
