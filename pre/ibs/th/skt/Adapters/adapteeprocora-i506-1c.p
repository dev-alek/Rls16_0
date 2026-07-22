block-level on error undo, throw.
using ibs.th.skt.*.
using ibs.th.skt.Adapters.*.
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
index pi line-num doc-code .
define temp-table temp_gds-line no-undo
field line-num    as integer
field doc-code    as character
field gds-code    as integer
field line-qnty        as integer
index pi
doc-code
line-num
gds-code
.
define temp-table temp_grp-line no-undo
field line-num    as integer
field doc-code    as character
field depart-code   as integer
field class-code    as integer
field subclass-code as integer
index pi
doc-code
line-num
depart-code
class-code
subclass-code
.
  define temp-table TempTrnDoc no-undo
    field line-num      as integer
    field ext-doc-code  as character
    field doc-date      as date
    field ext-doc-type  as character
    field cli-type      as character
    field cli-code      as integer
    field obj-type      as character
    field obj-code      as integer
    field ps            as character
    field doc-id        as character
    field dog-code      as character
    field source-doc    as character
    field out-code      as character
    index pi line-num ext-doc-code
  .
  define temp-table TempDocLine no-undo
    field line-num     as integer
    field gds-code     as integer
    field doc-qnty     as decimal
    field fact-qnty    as decimal
    field price-rubl   as decimal
    field RowSum       as decimal
    field vat-pc       as decimal
    field fact-dnsty   as decimal
    field cli-qnty     as decimal
    field koef         as decimal
    field unit-code    as character
    field b-code       as character
    field is-tsd-qnty  as logical init no
    field vsd-uuid     as character
    field part-id      as character
    field aclMarksList as character
    field PartIDTH     as character
    index pi
    line-num
    gds-code
  .
  define temp-table TempDocPart no-undo
    field gds-code     as integer
    field doc-qnty     as decimal
    field fact-qnty    as decimal
    field price-rubl   as decimal
    field vat-pc       as decimal
    field fact-dnsty   as decimal
    field vsd-uuid     as character
    field part-id      as character
    field in-doc-id    as character
    field edoc-id      as character
    index pi
    in-doc-id
    part-id
    gds-code
  .
  define temp-table TempDocMark no-undo
    field gtin as character
    field gtin_qnt as integer
    field upd_id as character
    field prt-id as character
    field in-doc-id as character
    field mark as character
    field gds-code as integer
    index pi mark
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
      temp_trn-doc.ext-doc-type  = TempTrnDoc.ext-doc-type
      temp_trn-doc.doc-code      = TempTrnDoc.ext-doc-code
      temp_trn-doc.cli-type      = TempTrnDoc.cli-type
      temp_trn-doc.cli-code      = TempTrnDoc.cli-code
      temp_trn-doc.obj-type      = TempTrnDoc.obj-type
      temp_trn-doc.obj-code      = TempTrnDoc.obj-code
      temp_trn-doc.contract-code = ?
      .
    for each TempDocLine no-lock:
      create temp_gds-line.
      assign
        temp_gds-line.doc-code   = TempTrnDoc.ext-doc-code
        temp_gds-line.line-num   = TempDocLine.line-num
        temp_gds-line.gds-code   = TempDocLine.gds-code
        temp_gds-line.line-qnty  = TempDocLine.fact-qnty
        .
    end.
  end.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output iDbNum
  )  .
  run utl/ora-i506-1c.p (
    input this-procedure ,
    input this-procedure ,
    input table temp_trn-doc ,
    input table temp_gds-line ,
    input table temp_grp-line ,
    output num-rec-ok
    ) no-error .
  if error-status:error
    then return error return-value.
end.
procedure pcall-log-file:
  define input parameter msg as character no-undo.
  assign
    LogWrite:LogStr = msg
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
