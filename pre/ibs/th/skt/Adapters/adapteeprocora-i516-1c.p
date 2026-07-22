block-level on error undo, throw.
using ibs.th.skt.*.
using ibs.th.skt.Adapters.*.
define variable vss-revision    as character no-undo init "$Revision: 315b966a6a9b, 3487, rls $":U .
define variable vss-author      as character no-undo init "$Author: BelovaMM $":U .
define variable vss-date        as character no-undo init "$Date: 2023/10/16 15:13:36 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: AdapteeProcOra-i516-1c.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ibs/th/skt/Adapters/AdapteeProcOra-i516-1c.p $":U .
define variable vss-description as character no-undo init "Импорт накладных из временной таблицы".
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
field doc-id as character
field out-code as character
index pi line-num doc-code .
define temp-table temp_doc-line no-undo
  field line-num      as integer
  field doc-code      as character
  field gds-code      as integer
  field artic         as character
  field prod-type     as character
  field prod-code     as integer
  field cli-qnty      as decimal
  field doc-qnty      as decimal
  field fact-qnty     as decimal
  field doc-density   as decimal
  field fact-density  as decimal
  field price-rubl    as decimal
  field price-cli     as decimal
  field vat-pc        as decimal
  field cons-vat-pc   as decimal
  field refA          as character
  field refB          as character
  field alc-code      as character
  field alc-type-code as character
  field vsd-uuid      as character
  field part-id       as character
  field importer-th   as character
  field line-num-str  as character
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
define temp-table temp_doc-mark no-undo
  field gtin          as character
  field gtin_qnt      as integer
  field upd_id        as character
  field part-id       as character
  field mark          as character
  field gds-code      as integer
  index pi mark.
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#trdcalib as handle no-undo.
define shared variable g#auto-user-id as character no-undo .
define input  parameter table for  TempTrnDoc.
define input  parameter table for  TempDocLine.
define input  parameter table for  TempDocPart.
define input  parameter table for  TempDocMark.
define input  parameter userId_ as character no-undo.
define variable iDbNum as integer no-undo.
MAIN-BLOCK:
do:
  define variable num-rec-ok as logical no-undo.
  define variable ii         as integer no-undo.
  define variable logWrite   as class   LogWrite no-undo.
  define variable v-doc-code as character no-undo.
  logWrite = new LogWrite().
  empty temp-table temp_trn-doc.
  empty temp-table temp_doc-line.
  empty temp-table temp_doc-mark.
  for each TempTrnDoc no-lock:
    ii = ii + 1.
    if TempTrnDoc.ext-doc-code = ? or TempTrnDoc.ext-doc-code = ""
    then do:
      run doc-code in this-procedure
        ( input  "main":U,
          input  TempTrnDoc.obj-type,
          input  TempTrnDoc.obj-code,
          input  ? ,
          output TempTrnDoc.ext-doc-code ) no-error.
    end.
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
      temp_trn-doc.contract-code = if TempTrnDoc.dog-code <> ? then integer (TempTrnDoc.dog-code) else 0
      temp_trn-doc.price-type    = if TempTrnDoc.ext-doc-type = 'ee':U then "TSFTSD" else ""
      temp_trn-doc.doc-code      = TempTrnDoc.ext-doc-code
      temp_trn-doc.doc-id        = TempTrnDoc.doc-id
      .
    if TempTrnDoc.source-doc ne ? and TempTrnDoc.source-doc ne ""
    then do:
      find first ub.doc-attr no-lock where ub.doc-attr.attr-code = 'nids':U and ub.doc-attr.attr-value = TempTrnDoc.source-doc no-error.
      find first ub.trn-doc no-lock where ub.trn-doc.doc-code = ub.doc-attr.doc-code no-error.
      if available (ub.doc-attr) and available (ub.trn-doc)
      then do:
        assign
          temp_trn-doc.cli-type = ub.trn-doc.cli-type
          temp_trn-doc.cli-code = ub.trn-doc.cli-code
          temp_trn-doc.out-code = ub.doc-attr.doc-code
          temp_trn-doc.contract-code = ub.trn-doc.contract-code.
      end.
      else do:
        if error-status:error
          then return error "Не найдена накладная-источник внешней системы с ИД  - " + TempTrnDoc.source-doc .
      end.
    end.
  end.
  for each TempDocLine no-lock:
    create temp_doc-line.
    assign
      temp_doc-line.line-num     = TempDocLine.line-num
      temp_doc-line.gds-code     = TempDocLine.gds-code
      temp_doc-line.fact-qnty    = TempDocLine.fact-qnty
      temp_doc-line.doc-qnty     = TempDocLine.doc-qnty
      temp_doc-line.price-cli    = TempDocLine.price-rubl
      temp_doc-line.price-rubl   = TempDocLine.price-rubl
      temp_doc-line.doc-code     = temp_trn-doc.doc-code
      temp_doc-line.doc-density  = TempDocLine.fact-dnsty
      temp_doc-line.fact-density = TempDocLine.fact-dnsty
      temp_doc-line.cli-qnty     = TempDocLine.cli-qnty
      temp_doc-line.part-id      = TempDocLine.part-id
      temp_doc-line.vsd-uuid     = TempDocLine.vsd-uuid
      temp_doc-line.vat-pc       = TempDocLine.vat-pc
      .
  end.
  for each TempDocMark no-lock:
    create temp_doc-mark.
    assign
      temp_doc-mark.part-id  = TempDocMark.prt-id
      temp_doc-mark.mark     = TempDocMark.mark
      temp_doc-mark.gds-code = TempDocMark.gds-code
      temp_doc-mark.gtin     = TempDocMark.gtin
      temp_doc-mark.gtin_qnt = TempDocMark.gtin_qnt
      temp_doc-mark.upd_id   = TempDocMark.upd_id
    .
  end.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output iDbNum
  )  .
  find first temp_doc-line where temp_doc-line.fact-density > 0 no-error.
  if available (temp_doc-line)
  then do:
    run utl/ora-i517.p (
      input this-procedure ,
      input this-procedure ,
      input table temp_trn-doc ,
      input table temp_doc-line ,
      output v-doc-code,
      output num-rec-ok
      ) no-error .
    if error-status:error
      then return error return-value.
  end.
  else do:
    find first TempTrnDoc .
    if TempTrnDoc.ext-doc-type = 'iv':U
    or TempTrnDoc.ext-doc-type = 'rv':U
    then do :
      run utl/trndocmv-1c.p (
        input this-procedure ,
        input table TempTrnDoc ,
        input table TempDocLine ,
        input table TempDocPart ,
        input table TempDocMark
        ) no-error .
      if error-status:error
        then return error return-value.
      return .
    end .
    else do :
      run utl/ora-i516-1c.p (
        input this-procedure ,
        input this-procedure ,
        input table temp_trn-doc ,
        input table temp_doc-line ,
        input table temp_doc-mark ,
        output v-doc-code,
        output num-rec-ok
        ) no-error .
      if error-status:error
        then return error return-value.
    end .
  end.
  find first ub.trn-doc no-lock where ub.trn-doc.doc-code  = v-doc-code no-error.
  case ub.trn-doc.ext-doc-type:
    when 'ie':U then do:
      if ub.trn-doc.cli-type = 'маг'
      then do:
        disable triggers for load of ub.trn-doc.
        find current ub.trn-doc exclusive-lock .
        ub.trn-doc.ext-doc-type = 'iv':U.
        ub.trn-doc.internal = true.
        ub.trn-doc.discnt-type = 'процент':U.
      end.
    end.
    when 're':U then do:
      if ub.trn-doc.cli-type = 'маг'
      then do:
        disable triggers for load of ub.trn-doc.
        find current ub.trn-doc exclusive-lock .
        ub.trn-doc.ext-doc-type = 'rv':U.
        ub.trn-doc.internal = true.
        ub.trn-doc.discnt-type = 'процент':U.
      end.
    end.
  end case.
  if ub.trn-doc.ext-doc-type = 'iv':U
  then do:
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-wrt in g#trdcalib ( input ub.trn-doc.doc-code ,
                       input 'othermoves':U ,
                       input yes ) no-error .
     if error-status:error
        then return error return-value.
  end.
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdbnum in g#library
  (input  temp_trn-doc.obj-type
  ,input  temp_trn-doc.obj-code
  ,output p-cntxt-db-num-obj
  )  .
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
