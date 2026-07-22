block-level on error undo, throw.
using ibs.th.skt.*.
using ibs.th.skt.Adapters.*.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table temp_trn-doc no-undo
field line-num as integer
field doc-code as character
field doc-date as date
field ext-doc-type as character
field cli-type as character
field cli-code as integer
field obj-type as character
field obj-code as integer
field wrkr as integer
field agnt as integer
field boss as integer
field creid as character
field ps as character
field host-code as integer
field contract-code as integer
field pay-code   as integer
field reason-code   as integer
field exch-code  as integer
field exch-rate  as decimal
field exch-scale as integer
field vat-type as character
field price-type as character
field cargo-from as character
field stts as character
field hold-obj-type as character
field hold-obj-code as integer
field ship-num as character
field ship-date as date
index pi line-num doc-code .
define temp-table temp_doc-line no-undo
field line-num    as integer
field doc-code    as character
field gds-code    as integer
field artic       as character
field prod-type   as character
field prod-code   as integer
field cli-qnty    as decimal
field doc-qnty    as decimal
field fact-qnty   as decimal
field price-rubl  as decimal
field price-cli   as decimal
field vat-pc      as decimal
field cons-vat-pc as decimal
field refA        as character
field refB        as character
field beforRefB   as character
field alc-code    as character
field alc-type-code as character
field importer-th as character
field line-num-str as character
index pi
doc-code
line-num
gds-code
index qntyIndex
doc-code
gds-code
alc-code
doc-qnty
.
  define temp-table TempTrnDoc no-undo
    field SuppInDocNo   as character
    field stts          as character
    field ext-doc-type  as character
    field doc-date      as date
    field cli-type      as character
    field cli-code      as integer
    field obj-type      as character
    field obj-code      as integer
    field ContractID    as integer
    field ContractNum   as character
    field vat-type      as character
    field tot-transp    as decimal
    field tot-other     as decimal
    field wrkr          as integer
    field agnt          as integer
    field boss          as integer
    field pay-code      as integer
    field discnt-type   as character
    field discnt-pc     as decimal
    field user-id       as character
    field reason-code   as integer
    field ps            as character
    field hold-obj-type as character
    field hold-obj-code as integer
    field ship-num      as character
    field ship-date     as date
    index pi SuppInDocNo .
  define temp-table TempDocLine no-undo
    field SuppInDocNo  as character
    field line-num     as integer
    field gds-code     as integer
    field doc-qnty     as decimal
    field fact-qnty    as decimal
    field price-rubl   as decimal
    field vat-pc       as decimal
    field b-code       as character
    index pi
    SuppInDocNo
    line-num
    gds-code
    .
  define temp-table TempGdsDtl no-undo
    field SuppInDocNo  as character
    field line-num     as integer
    field gds-code     as integer
    field prt-code     as integer
    field b-code       as integer
    field doc-qnty     as decimal
    field price-rubl   as decimal
    index pi
    SuppInDocNo
    line-num
    gds-code
    prt-code
    .
  define temp-table TempParts no-undo
    field SuppInDocNo  as character
    field line-num     as integer
    field gds-code     as integer
    field part-code    as character
    field out-code     as character
    index pi
    SuppInDocNo
    line-num
    gds-code
    part-code
    .
  define temp-table TempDocAttr no-undo
    field SuppInDocNo  as character
    field attr-code    as character
    field attr-value   as character
    index pi
    SuppInDocNo
    attr-code
    .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define shared variable g#auto-user-id as character no-undo .
define input  parameter table for  TempTrnDoc.
define input  parameter table for  TempDocLine.
define input  parameter table for  TempDocAttr.
define input  parameter table for  TempGdsDtl.
define input  parameter table for  TempParts.
define output parameter ERROR_ as logical no-undo .
define variable iDbNum as integer no-undo.
MAIN-BLOCK:
do:
  define variable num-rec-ok as logical no-undo.
  define variable logWrite   as class   LogWrite no-undo.
  logWrite = new LogWrite().
  for each TempTrnDoc no-lock:
    create temp_trn-doc.
    assign
      temp_trn-doc.doc-date      = TempTrnDoc.doc-date
      temp_trn-doc.ps            = TempTrnDoc.ps
      temp_trn-doc.doc-code      = TempTrnDoc.SuppInDocNo
      temp_trn-doc.ext-doc-type  = TempTrnDoc.ext-doc-type
      temp_trn-doc.cli-type      = TempTrnDoc.cli-type
      temp_trn-doc.cli-code      = TempTrnDoc.cli-code
      temp_trn-doc.obj-type      = TempTrnDoc.obj-type
      temp_trn-doc.obj-code      = TempTrnDoc.obj-code
      temp_trn-doc.exch-code     = 0
      temp_trn-doc.exch-rate     = 1
      temp_trn-doc.exch-scale    = 1
      temp_trn-doc.contract-code = TempTrnDoc.ContractID
      temp_trn-doc.price-type    = ""
      temp_trn-doc.agnt          = TempTrnDoc.agnt
      temp_trn-doc.wrkr          = TempTrnDoc.wrkr
      temp_trn-doc.boss          = TempTrnDoc.boss
      temp_trn-doc.creid         = TempTrnDoc.user-id
      temp_trn-doc.vat-type      = TempTrnDoc.vat-type
      temp_trn-doc.pay-code      = TempTrnDoc.pay-code
      temp_trn-doc.reason-code   = TempTrnDoc.reason-code
      temp_trn-doc.stts          = TempTrnDoc.stts
      temp_trn-doc.hold-obj-type = TempTrnDoc.hold-obj-type
      temp_trn-doc.hold-obj-code = TempTrnDoc.hold-obj-code
      temp_trn-doc.ship-num      = TempTrnDoc.ship-num
      temp_trn-doc.ship-date     = TempTrnDoc.ship-date
      .
      for each TempDocLine no-lock where TempDocLine.SuppInDocNo = TempTrnDoc.SuppInDocNo :
        create temp_doc-line.
        assign
          temp_doc-line.line-num   = TempDocLine.line-num
          temp_doc-line.gds-code   = TempDocLine.gds-code
          temp_doc-line.fact-qnty  = TempDocLine.doc-qnty
          temp_doc-line.doc-qnty   = TempDocLine.doc-qnty
          temp_doc-line.price-cli  = TempDocLine.price-rubl
          temp_doc-line.price-rubl = TempDocLine.price-rubl
          temp_doc-line.vat-pc     = TempDocLine.vat-pc
          temp_doc-line.doc-code   = temp_trn-doc.doc-code
          .
      end.
  end.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output iDbNum
  )  .
  run utl/websrv_trn-doc.p (
    input this-procedure ,
    input this-procedure ,
    input table temp_trn-doc ,
    input table temp_doc-line ,
    input table TempGdsDtl ,
    input table TempParts ,
    input table TempDocAttr ,
    output num-rec-ok,
    output ERROR_
    ) no-error .
end.
procedure pcall-log-file:
  define input parameter msg as character no-undo.
  assign
    LogWrite:LogStr = LogWrite:LogStr + chr(10) + msg
    .
end.
procedure get-db-num:
  define output parameter pDbNum as integer no-undo.
  pDbNum = iDbNum.
end.
procedure get-userid:
  define output parameter pUserId as character no-undo.
  find first ub.user-login where ub.user-login.db-num = iDbNum and ub.user-login.user-id = temp_trn-doc.creid no-error.
  if available ub.user-login
  then
  do:
    assign
      pUserId  = temp_trn-doc.creid
      .
  end.
  else
  do:
    assign
      pUserId = g#auto-user-id
      .
  end.
end.
procedure mainmenu_getcntxt :
define output parameter p-cntxt-db-num                as integer   no-undo .
define output parameter p-cntxt-userid                as character no-undo .
define output parameter p-cntxt-level                 as character no-undo .
define output parameter p-cntxt-host-code-obj         as integer   no-undo .
define output parameter p-cntxt-obj-type              as character no-undo .
define output parameter p-cntxt-obj-code              as integer   no-undo .
define output parameter p-cntxt-db-num-obj            as integer   no-undo .
define output parameter p-cntxt-is-admin              as logical   no-undo .
  do
  on error undo, return error return-value
  :
  define variable vt-host-code as integer   no-undo .
  find first temp_trn-doc no-error.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdbnum in g#library
  (input  temp_trn-doc.obj-type
  ,input  temp_trn-doc.obj-code
  ,output p-cntxt-db-num-obj
  )  .
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  temp_trn-doc.obj-type
  ,input  temp_trn-doc.obj-code
  ,output vt-host-code
  )  .
  assign
    p-cntxt-db-num          =  p-cntxt-db-num-obj
    p-cntxt-userid          =  temp_trn-doc.creid
    p-cntxt-level           =  v-cntxt-level
    p-cntxt-host-code-obj   =  vt-host-code
    p-cntxt-obj-type        =  temp_trn-doc.obj-type
    p-cntxt-obj-code        =  temp_trn-doc.obj-code
    p-cntxt-is-admin        =  v-cntxt-is-admin
  .
  end.
end procedure.
