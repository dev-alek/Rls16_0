block-level on error undo, throw.
using ibs.th.gbl.sys.objsrv.
define variable vss-revision    as character no-undo init "$Revision: 1eba0946c2d7, 3078, rls $":U .
define variable vss-author      as character no-undo init "$Author: DRuban $":U .
define variable vss-date        as character no-undo init "$Date: Пт авг 05 19:16:25 2022 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: create-LK_RECEIPT.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/create-LK_RECEIPT.p $":U .
define variable vss-description as character no-undo init "Список УПД".
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
def var objSrv as class ibs.th.gbl.sys.objsrv no-undo.
run gbl/getobjsrvhndl.p (input-output ObjSrv).
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
def var vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function getattrUtdex returns char
(idb-num   as integer,
 idoc-id   as integer,
 iattrcode as character,
 iExValue  as character  ):
   define buffer utd-attr for utd-attr.
   find first utd-attr where utd-attr.db-num eq idb-num
                         and utd-attr.doc-id eq idoc-id
                         and utd-attr.attr-code eq iattrcode
   no-lock no-error.
   return if not available utd-attr  then iExValue    else  utd-attr.attr-value.
end.
function getattrUtd returns char
(idb-num   as integer,
 idoc-id   as integer,
 iattrcode as character ):
  return getattrUtdex(idb-num,idoc-id,iattrcode,?).
end.
function setattrUtd returns logical
(idb-num   as integer,
 idoc-id   as integer,
 iattrcode as character,
 iattrval  as character ):
   define buffer utd-attr for utd-attr.
   find first utd-attr where utd-attr.db-num eq idb-num
                         and utd-attr.doc-id eq idoc-id
                         and utd-attr.attr-code eq iattrcode
   no-lock no-error.
   if not available utd-attr
   then do:
      create utd-attr.
      assign
         utd-attr.db-num    = idb-num
         utd-attr.doc-id    = idoc-id
         utd-attr.attr-code = iattrcode
         utd-attr.attr-value = iattrval
      .
   end.
   else do:
      if utd-attr.attr-value ne iattrval
      then do:
         find current utd-attr exclusive-lock no-error.
         if available utd-attr
         then
            utd-attr.attr-value = iattrval.
      end.
   end.
   release utd-attr.
end.
function GetAttrUtdlinesEx returns char
(idb-num   as integer,
 idoc-id   as integer,
 ilinenum  as integer,
 iattrcode as character,
 iExValue  as character  ):
   define buffer utd-lines-attr for utd-lines-attr.
   find first utd-lines-attr where utd-lines-attr.db-num    eq idb-num
                               and utd-lines-attr.doc-id    eq idoc-id
                               and utd-lines-attr.lineNum   eq ilineNum
                               and utd-lines-attr.attr-code eq iattrcode
   no-lock no-error.
   return if not available utd-lines-attr  then iExValue    else  utd-lines-attr.attr-value.
end.
function GetAttrUtdlines returns char
(idb-num   as integer,
 idoc-id   as integer,
 ilinenum  as integer,
 iattrcode as character ):
   return GetAttrUtdlinesex (idb-num,idoc-id,ilinenum,iattrcode,?).
end.
function setattrUtdlines returns logical
(idb-num   as integer,
 idoc-id   as integer,
 ilinenum  as integer,
 iattrcode as character,
 iattrval  as character ):
   define buffer utd-lines-attr for utd-lines-attr.
   find first utd-lines-attr where utd-lines-attr.db-num    eq idb-num
                               and utd-lines-attr.doc-id    eq idoc-id
                               and utd-lines-attr.lineNum   eq ilineNum
                               and utd-lines-attr.attr-code eq iattrcode
   no-lock no-error.
   if not available utd-lines-attr
   then do:
      if iattrval ne ?
         and iattrval ne ""
      then do:
         create utd-lines-attr.
         assign
            utd-lines-attr.db-num    = idb-num
            utd-lines-attr.doc-id    = idoc-id
            utd-lines-attr.lineNum   = ilineNum
            utd-lines-attr.attr-code = iattrcode
            utd-lines-attr.attr-value = iattrval
         .
      end.
   end.
   else do:
      if utd-lines-attr.attr-value ne iattrval
      then do:
         find current utd-lines-attr exclusive-lock no-error.
         if available utd-lines-attr
         then do:
            if    iattrval eq ?
               or iattrval eq ""
            then do:
               delete utd-lines-attr.
            end.
            else do:
               utd-lines-attr.attr-value = iattrval.
            end.
         end.
      end.
   end.
   release utd-lines-attr.
end.
function GetAttrUtdMarkingLinesEx returns char
(idb-num   as integer,
 idoc-id   as integer,
 ilinenum  as integer,
 imark     as character,
 iattrcode as character,
 iExValue  as character  ):
   define buffer utd-marking-lines-attr for utd-marking-lines-attr.
   find first utd-marking-lines-attr where utd-marking-lines-attr.db-num    eq idb-num
                                       and utd-marking-lines-attr.doc-id    eq idoc-id
                                       and utd-marking-lines-attr.lineNum   eq ilineNum
                                       and utd-marking-lines-attr.mark      eq imark
                                       and utd-marking-lines-attr.attr-code eq iattrcode
   no-lock no-error.
   return if not available utd-marking-lines-attr  then iExValue    else  utd-marking-lines-attr.attr-value.
end.
function GetAttrUtdMarkingLines returns char
(idb-num   as integer,
 idoc-id   as integer,
 ilinenum  as integer,
 imark     as character,
 iattrcode as character ):
   return GetAttrUtdMarkingLinesEx (idb-num,idoc-id,ilinenum,imark,iattrcode,?).
end.
function setattrUtdMarkingLines returns logical
(idb-num   as integer,
 idoc-id   as integer,
 ilinenum  as integer,
 imark     as character,
 iattrcode as character,
 iattrval  as character ):
   define buffer utd-marking-lines-attr for utd-marking-lines-attr.
   find first utd-marking-lines-attr where utd-marking-lines-attr.db-num    eq idb-num
                                       and utd-marking-lines-attr.doc-id    eq idoc-id
                                       and utd-marking-lines-attr.lineNum   eq ilineNum
                                       and utd-marking-lines-attr.mark      eq imark
                                       and utd-marking-lines-attr.attr-code eq iattrcode
   no-lock no-error.
   if not available utd-marking-lines-attr
   then do:
      if iattrval ne ?
         and iattrval ne ""
      then do:
         create utd-marking-lines-attr.
         assign
            utd-marking-lines-attr.db-num     = idb-num
            utd-marking-lines-attr.doc-id     = idoc-id
            utd-marking-lines-attr.lineNum    = ilineNum
            utd-marking-lines-attr.mark       = imark
            utd-marking-lines-attr.attr-code  = iattrcode
            utd-marking-lines-attr.attr-value = iattrval
         .
      end.
   end.
   else do:
      if utd-marking-lines-attr.attr-value ne iattrval
      then do:
         find current utd-marking-lines-attr exclusive-lock no-error.
         if available utd-marking-lines-attr
         then do:
            if    iattrval eq ?
               or iattrval eq ""
            then do:
               delete utd-marking-lines-attr.
            end.
            else do:
               utd-marking-lines-attr.attr-value = iattrval.
            end.
         end.
      end.
   end.
   release utd-marking-lines-attr.
end.
define input parameter p-doc-code as character no-undo .
define buffer buf_utd for ub.utd .
define buffer buf_utd-lines for ub.utd-lines .
define buffer buf_trn-doc for ub.trn-doc .
define buffer buf_fbr-doc for ub.fbr-doc .
define buffer buf_doc-line for ub.doc-line .
define buffer buf_doc-line-attr for ub.doc-line-attr .
define buffer buf_fbr-line for ub.fbr-line .
define buffer buf_fbr-recipe for ub.fbr-recipe .
define buffer buf_goods for ub.goods .
define variable EdocType  as class ibs.th.str.utd.edoctype no-undo .
define variable create-LK_RECEIPT as logical no-undo init no .
define variable ProductGroups as character no-undo .
define variable v-par-type as character no-undo .
define variable v-par-val  as character no-undo .
define variable vPG as character no-undo .
define variable vPG-ii as integer no-undo .
define variable vAction as character no-undo .
define variable vINN as character no-undo .
find first buf_trn-doc no-lock where buf_trn-doc.doc-code = p-doc-code no-error .
if not available buf_trn-doc
then do :
  undo, return error "Накладная не найдена!" .
end .
for first firm no-lock where firm.firm-code = buf_trn-doc.host-code :
  vINN = firm.inn .
end .
case buf_trn-doc.ext-doc-type :
  when 'wm':U then vAction = "PRODUCTION_USE" .
  when 'vt':U then vAction = "LOSS" .
  when 'we':U then vAction = "DESTRUCTION" .
  otherwise do :
    return .
  end .
end case .
doc-lines-check_ :
for each buf_doc-line no-lock where buf_doc-line.doc-code = buf_trn-doc.doc-code,
first buf_goods no-lock where buf_goods.artic = buf_doc-line.artic
                          and buf_goods.prod-type = buf_doc-line.prod-type
                          and buf_goods.prod-code = buf_doc-line.prod-code
:
  if buf_trn-doc.ext-doc-type = 'vt':U
  and buf_doc-line.fact-qnty >= 0
  then next doc-lines-check_ .
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
  ( buf_goods.gds-code,
    'mark-type':U,
     output v-par-val,
     output v-par-type
  ).
  v-par-val = trim(v-par-val, "-40") .
  if v-par-val <> "milk"
  and v-par-val <> "water"
  then next doc-lines-check_ .
  find first buf_doc-line-attr no-lock where buf_doc-line-attr.doc-code = buf_doc-line.doc-code
                                         and buf_doc-line-attr.gds-code = buf_goods.gds-code
                                         and buf_doc-line-attr.attr-code = "GTIN-qnty"
                                         no-error .
  if not available buf_doc-line-attr
  or (available buf_doc-line-attr and trim(buf_doc-line-attr.attr-value) = "")
  then do :
    next doc-lines-check_ .
  end .
  create-LK_RECEIPT = yes .
  if ProductGroups > ""
  and lookup(v-par-val, ProductGroups) > 0
  then .
  else do :
    ProductGroups = ProductGroups + v-par-val + "," .
  end .
end .
if not create-LK_RECEIPT
then do :
  return .
end .
ProductGroups = trim(ProductGroups, ",") .
EdocType = ObjSrv:Env:Utd:EDocType.
do vPG-ii = 1 to num-entries(ProductGroups) :
  run create-utd (input entry(vPG-ii, ProductGroups)) .
end .
procedure create-utd :
  define input parameter pPG as character no-undo .
  define variable v-LineNum as integer no-undo .
  define variable ii as integer no-undo .
  define variable vGtin as character no-undo .
  define variable vQnty as decimal no-undo .
  create buf_utd.
  assign
    buf_utd.db-num = g#db-num
    buf_utd.doc-id = next-value (s-utd-doc-code, ub)
    buf_utd.LoadDate = date (now)
    buf_utd.LoadTime = time
    buf_utd.ModifyDate = date (now)
    buf_utd.ModifyTime = time
    buf_utd.obj-type = buf_trn-doc.obj-type
    buf_utd.obj-code = buf_trn-doc.obj-code
    buf_utd.host-code = buf_trn-doc.host-code
    buf_utd.DocumentNumber = buf_trn-doc.doc-code
    buf_utd.doc-code = buf_trn-doc.doc-code
    buf_utd.DocumentDate = buf_trn-doc.fact-date
    buf_utd.LoadDate = buf_trn-doc.fact-date
    buf_utd.sts-edi = ObjSrv:Env:Utd:Sts:EDI:RecipientResponseStatusNotAccep:KeyIntDB
    buf_utd.sts = ObjSrv:Env:Utd:Sts:TH:LK_RECEIPT_New:KeyIntDB
    buf_utd.EDocType = EDocType:LK_RECEIPT:KeyIntDB
    buf_utd.obj-inn = vINN
  .
  setattrUtd (input buf_utd.db-num,
              input buf_utd.doc-id,
              input "LK_RECEIPT_PG",
              input pPG)
              .
  setattrUtd (input buf_utd.db-num,
              input buf_utd.doc-id,
              input "LK_RECEIPT_Action",
              input vAction)
              .
  v-LineNum = 1 .
  doc-lines_ :
  for each buf_doc-line no-lock where buf_doc-line.doc-code = buf_trn-doc.doc-code,
  first buf_goods no-lock where buf_goods.artic = buf_doc-line.artic
                            and buf_goods.prod-type = buf_doc-line.prod-type
                            and buf_goods.prod-code = buf_doc-line.prod-code
  :
    if buf_trn-doc.ext-doc-type = 'vt':U
    and buf_doc-line.fact-qnty >= 0
    then next doc-lines_ .
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
    ( buf_goods.gds-code,
      'mark-type':U,
       output v-par-val,
       output v-par-type
    ).
    v-par-val = trim(v-par-val, "-40") .
    if v-par-val <> pPG
    then next doc-lines_ .
    find first buf_doc-line-attr no-lock where buf_doc-line-attr.doc-code = buf_doc-line.doc-code
                                           and buf_doc-line-attr.gds-code = buf_goods.gds-code
                                           and buf_doc-line-attr.attr-code = "GTIN-qnty"
                                           no-error .
    if not available buf_doc-line-attr
    or (available buf_doc-line-attr and trim(buf_doc-line-attr.attr-value) = "")
    then do :
      next doc-lines_ .
    end .
    ii_ :
    do ii = 1 to num-entries(buf_doc-line-attr.attr-value, ";") :
      assign
        vGtin = entry(1, entry(ii, buf_doc-line-attr.attr-value, ";"), "=")
        vQnty = decimal(entry(2, entry(ii, buf_doc-line-attr.attr-value, ";"), "="))
      no-error .
      if error-status:error
      then next ii_ .
      find first buf_utd-lines exclusive-lock where buf_utd-lines.db-num = buf_utd.db-num
                                                and buf_utd-lines.doc-id = buf_utd.doc-id
                                                and buf_utd-lines.ProductCode = vGtin
      no-error .
      if not available buf_utd-lines
      then do :
        create buf_utd-lines .
        assign
          buf_utd-lines.db-num = buf_utd.db-num
          buf_utd-lines.doc-id = buf_utd.doc-id
          buf_utd-lines.LineNum = v-LineNum
          buf_utd-lines.gds-code = buf_goods.gds-code
          buf_utd-lines.GdsName = buf_goods.gds-name
          buf_utd-lines.ProductCode = vGtin
          buf_utd-lines.UnitCode = buf_doc-line.unit-cli
          buf_utd-lines.Quantity = vQnty
          buf_utd-lines.Price = buf_doc-line.price-rubl / ((100 + buf_doc-line.VAT-pc) / 100)
          buf_utd-lines.Total = buf_doc-line.price-rubl * buf_utd-lines.Quantity
          buf_utd-lines.Vat = buf_utd-lines.Total - (buf_utd-lines.Price * buf_utd-lines.Quantity)
          buf_utd-lines.TotalWithVatExcluded = buf_utd-lines.Total - buf_utd-lines.Vat
        .
        v-LineNum = v-LineNum + 1 .
      end .
      else do :
        assign
          buf_utd-lines.Quantity = buf_utd-lines.Quantity + vQnty
          buf_utd-lines.Total = buf_doc-line.price-rubl * buf_utd-lines.Quantity
          buf_utd-lines.Vat = buf_utd-lines.Total - (buf_utd-lines.Price * buf_utd-lines.Quantity)
          buf_utd-lines.TotalWithVatExcluded = buf_utd-lines.Total - buf_utd-lines.Vat
        .
      end .
    end .
  end .
end procedure .
