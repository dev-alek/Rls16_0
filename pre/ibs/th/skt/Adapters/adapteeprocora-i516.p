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
  field line-num     as integer
  field ext-doc-code as character
  field doc-date     as date
  field ext-doc-type as character
  field cli-type     as character
  field cli-code     as integer
  field obj-type     as character
  field obj-code     as integer
  field ps           as character
  field Status_      as character
  field Flags_       as integer
  index pi line-num ext-doc-code .
define temp-table TempDocLine no-undo
  field line-num     as integer
  field gds-code     as integer
  field doc-qnty     as decimal
  field fact-qnty    as decimal
  field price-rubl   as decimal
  field RowSum       as decimal
  field vat-pc       as decimal
  field b-code       as character
  field is-tsd-qnty  as logical   init no
  field aclMarksList as character
  field PartIDTH     as character
  field Flags_       as integer
  field NotDict      as logical
  index pi
  line-num
  gds-code
  .
define temp-table TempDocLineIsTSD like TempDocLine.
define temp-table TempDocLineTSD no-undo
  field gds-code     as integer
  field doc-qnty     as decimal
  field fact-qnty    as decimal
  field artic        as character
  field prod-code    as integer
  field prod-type    as character
  field Flags_error  as logical
  field mark-type    as character
  field mark         as character
  field mark-parent  as character
  index pi
  artic
  prod-code
  prod-type
  mark
  .
define temp-table TempMarkLine no-undo
  field DocName    as character
  field MarkCode   as character
  field PartIDTH   as character
  field Sts        as character
  field MarkParent as character
  field QntyBox    as character
  index pi
  DocName
  MarkCode
  .
  define temp-table TempTSDSetting no-undo
  field sn   as character
  field obj-code  as integer
  field obj-type as character
  field version_ as character
  field lastDate as datetime
  index pi
  sn
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
define temp-table tt-excisemarks no-undo
  field excisemarks      as character
  field beforRefB             as character
  index pi
  excisemarks
  .
define shared variable g#auto-user-id as character no-undo .
define input  parameter table for  TempTrnDoc.
define input  parameter table for  TempDocLine.
define input  parameter userId_ as character no-undo.
define variable iDbNum as integer no-undo.
MAIN-BLOCK:
do:
  define variable num-rec-ok as logical no-undo.
  define variable ii         as integer no-undo.
  define variable logWrite   as class   LogWrite no-undo.
  logWrite = new LogWrite().
  for each TempTrnDoc no-lock:
    ii = ii + 1.
    create temp_trn-doc.
    assign
      temp_trn-doc.line-num      = ii
      temp_trn-doc.doc-date      = TempTrnDoc.doc-date
      temp_trn-doc.ps            = TempTrnDoc.ps
      temp_trn-doc.doc-code      = TempTrnDoc.ext-doc-code
      temp_trn-doc.ext-doc-type  = TempTrnDoc.ext-doc-type
      temp_trn-doc.cli-type      = TempTrnDoc.cli-type
      temp_trn-doc.cli-code      = TempTrnDoc.cli-code
      temp_trn-doc.obj-type      = TempTrnDoc.obj-type
      temp_trn-doc.obj-code      = TempTrnDoc.obj-code
      temp_trn-doc.exch-code     = 0
      temp_trn-doc.exch-rate     = 1
      temp_trn-doc.exch-scale    = 1
      temp_trn-doc.contract-code = ?
      temp_trn-doc.price-type    = if TempTrnDoc.ext-doc-type = 'ee':U then "TSFTSD" else ""
      .
  end.
  for each TempDocLine no-lock:
    create temp_doc-line.
    assign
      temp_doc-line.line-num   = TempDocLine.line-num
      temp_doc-line.gds-code   = TempDocLine.gds-code
      temp_doc-line.fact-qnty  = TempDocLine.fact-qnty
      temp_doc-line.doc-qnty   = TempDocLine.doc-qnty
      temp_doc-line.price-cli  = TempDocLine.price-rubl
      temp_doc-line.price-rubl = TempDocLine.price-rubl
      temp_doc-line.doc-code   = temp_trn-doc.doc-code
      .
  end.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output iDbNum
  )  .
  run utl/ora-i516.p (
    input this-procedure ,
    input this-procedure ,
    input table temp_trn-doc ,
    input table temp_doc-line ,
    input table tt-excisemarks,
    output num-rec-ok
    ) no-error .
  if error-status:error
    then return error return-value.
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
  find first ub.user-login where ub.user-login.db-num = iDbNum and ub.user-login.user-id = userId_ no-error.
  if available ub.user-login
  then
  do:
    assign
      pUserId  = userId_
      .
  end.
  else
  do:
    assign
      pUserId = g#auto-user-id
      userId_ = g#auto-user-id
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
    p-cntxt-userid          =  userId_
    p-cntxt-level           =  v-cntxt-level
    p-cntxt-host-code-obj   =  vt-host-code
    p-cntxt-obj-type        =  temp_trn-doc.obj-type
    p-cntxt-obj-code        =  temp_trn-doc.obj-code
    p-cntxt-is-admin        =  v-cntxt-is-admin
  .
  end.
end procedure.
