block-level on error undo, throw.

/*------------------------------------------------------------------------
    File        : create-LK_RECEIPT.p
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : SSlivenko
    Created     : Wed Jun 22 19:03:11 AST 2022
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
using ibs.th.gbl.sys.objsrv.


define variable vss-revision    as character no-undo init "$Revision: 1eba0946c2d7, 3078, rls $":U .
define variable vss-author      as character no-undo init "$Author: DRuban $":U .
define variable vss-date        as character no-undo init "$Date: Пт авг 05 19:16:25 2022 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: create-LK_RECEIPT.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/create-LK_RECEIPT.p $":U .
define variable vss-description as character no-undo init "Список УПД".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/objsrv.i   }
{ gbl/attr-lib.i }
{ str/utd-attr.i }

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

/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */

find first buf_trn-doc no-lock where buf_trn-doc.doc-code = p-doc-code no-error .
if not available buf_trn-doc
then do :
  undo, return error "Накладная не найдена!" .
end .

for first firm no-lock where firm.firm-code = buf_trn-doc.host-code :
  vINN = firm.inn .
end .

case buf_trn-doc.ext-doc-type :
  when {&TDEDT_Spi_Prvo} then vAction = "PRODUCTION_USE" .
  when {&TDEDT_Inv} then vAction = "LOSS" .
  when {&TDEDT_Spi_Vnesh} then vAction = "DESTRUCTION" .
  otherwise do :
    return .
  end .
end case .

/*find first buf_utd no-lock where buf_utd.doc-code = buf_trn-doc.doc-code no-error .       */
/*if available buf_utd                                                                      */
/*and buf_utd.EDocType = EdocType:LK_RECEIPT:KeyIntDB                                       */
/*then do :                                                                                 */
/*  message "По данной накладной уже создан документ Вывода из оборота!" view-as alert-box .*/
/*  undo, return .                                                                          */
/*end .                                                                                     */

doc-lines-check_ :
for each buf_doc-line no-lock where buf_doc-line.doc-code = buf_trn-doc.doc-code,
first buf_goods no-lock where buf_goods.artic = buf_doc-line.artic
                          and buf_goods.prod-type = buf_doc-line.prod-type
                          and buf_goods.prod-code = buf_doc-line.prod-code
:
  if buf_trn-doc.ext-doc-type = {&TDEDT_Inv}
  and buf_doc-line.fact-qnty >= 0
  then next doc-lines-check_ .
  
  &scop proc-name gds-attr-value
  {&run_proc_attr-lib}
  ( buf_goods.gds-code,
    {&attr-mark-type},
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
/*  if buf_trn-doc.ext-doc-type = {&TDEDT_Spi_Prvo}                                           */
/*  then do :                                                                                 */
/*    for first buf_fbr-line no-lock where buf_fbr-line.doc-code = buf_doc-line.doc-code      */
/*                                     and buf_fbr-line.trn-type = {&write-off}               */
/*                                     and buf_fbr-line.artic = buf_doc-line.artic            */
/*                                     and buf_fbr-line.prod-type = buf_doc-line.prod-type    */
/*                                     and buf_fbr-line.prod-code = buf_doc-line.prod-code    */
/*                                     ,                                                      */
/*    first buf_fbr-recipe no-lock where buf_fbr-recipe.doc-code = buf_fbr-line.doc-code      */
/*                                   and buf_fbr-recipe.recipe-code = buf_fbr-line.recipe-code*/
/*    :                                                                                       */
/*      if buf_fbr-recipe.recipe-type <> {&alternative}                                       */
/*      then next doc-lines-check_ .                                                          */
/*    end .                                                                                   */
/*  end .                                                                                     */
  
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
    buf_utd.doc-id = next-value (s-utd-doc-code, {&db-name_schema})
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
    if buf_trn-doc.ext-doc-type = {&TDEDT_Inv}
    and buf_doc-line.fact-qnty >= 0
    then next doc-lines_ .
    
    &scop proc-name gds-attr-value
    {&run_proc_attr-lib}
    ( buf_goods.gds-code,
      {&attr-mark-type},
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
/*    if buf_trn-doc.ext-doc-type = {&TDEDT_Spi_Prvo}                                           */
/*    then do :                                                                                 */
/*      for first buf_fbr-line no-lock where buf_fbr-line.doc-code = buf_doc-line.doc-code      */
/*                                       and buf_fbr-line.trn-type = {&write-off}               */
/*                                       and buf_fbr-line.artic = buf_doc-line.artic            */
/*                                       and buf_fbr-line.prod-type = buf_doc-line.prod-type    */
/*                                       and buf_fbr-line.prod-code = buf_doc-line.prod-code    */
/*                                       ,                                                      */
/*      first buf_fbr-recipe no-lock where buf_fbr-recipe.doc-code = buf_fbr-line.doc-code      */
/*                                     and buf_fbr-recipe.recipe-code = buf_fbr-line.recipe-code*/
/*      :                                                                                       */
/*        if buf_fbr-recipe.recipe-type <> {&alternative}                                       */
/*        then next doc-lines_ .                                                                */
/*      end .                                                                                   */
/*    end .                                                                                     */
    
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
