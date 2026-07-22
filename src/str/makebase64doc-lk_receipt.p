block-level on error undo, throw.

/*------------------------------------------------------------------------
    File        : makeBase64doc-LK_RECEIPT.p
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : SSlivenko
    Created     : Thu Jun 23 19:45:25 AST 2022
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
using ibs.th.gbl.sys.objsrv.


define variable vss-revision    as character no-undo init "$Revision: 1eba0946c2d7, 3078, rls $":U .
define variable vss-author      as character no-undo init "$Author: DRuban $":U .
define variable vss-date        as character no-undo init "$Date: Пт авг 05 19:16:25 2022 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: makeBase64doc-LK_RECEIPT.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/makeBase64doc-LK_RECEIPT.p $":U .
define variable vss-description as character no-undo init "Список УПД".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ str/utd-attr.i }

define input parameter p-db-num as integer no-undo .
define input parameter p-doc-id as integer no-undo .
define output parameter p-Base64doc as longchar no-undo .

define buffer buf_utd for ub.utd .
define buffer buf_utd-lines for ub.utd-lines .

define variable v-tmp-filename as character no-undo .
define variable vData as longchar no-undo .
define variable vMemptr as memptr no-undo .
define variable vAction as character no-undo .
define variable vBaseDocCustomName as character no-undo .
define variable vINN as character no-undo .

function writeTag returns character
  (input pTag as character,
   input pValue as character)
:
  return quoter(pTag) + ":" + quoter(pValue).
end function .

function putDate returns character
  (input pDate as date)
:
  define variable vDateStr as character no-undo .
  vDateStr = string(year(pDate)) + "-" + string(month(pDate), "99") + "-" + string(day(pDate), "99") .
  return vDateStr .  
end function .

/* ***************************  Main Block  *************************** */

find first buf_utd no-lock where buf_utd.db-num = p-db-num
                             and buf_utd.doc-id = p-doc-id
                             no-error .
if not available buf_utd
then do :
  return error "Документ не найден!".
end .

vAction = getattrUtd(input buf_utd.db-num, input buf_utd.doc-id, input "LK_RECEIPT_Action") .

if vAction = ?     
or trim(vAction) = ""
then do :
  return error "В документе не заполненен атрибут LK_RECEIPT_Action (Причина выбытия)!".
end .  

vINN = trim(buf_utd.obj-inn) .

if vINN = ""
then do :
  for first firm no-lock where firm.firm-code = buf_utd.host-code :
    vINN = trim(firm.inn) .
  end .
end .

if vINN = ""
then do :
  return error "В документе не заполненен ИНН".
end .

case vAction :
  when "PRODUCTION_USE" then vBaseDocCustomName = "Production" .
  when "LOSS" then vBaseDocCustomName = "Inventory" .
  when "DESTRUCTION" then vBaseDocCustomName = "Write-off" .
  otherwise do :
    return error ("В документе недопустимое значение атрибута LK_RECEIPT_Action (Причина выбытия) - " + vAction) .
  end .
end case .

vData = "" . 
vData = vData + "~{" .
vData = vData + writeTag("inn", vINN) + "," .
vData = vData + writeTag("action", vAction) + "," . 
vData = vData + writeTag("action_date", putDate(buf_utd.DocumentDate)) + "," .
vData = vData + writeTag("document_type", "OTHER") + "," .
vData = vData + writeTag("document_number", replace(buf_utd.doc-code, "м", "m")) + "," .
vData = vData + writeTag("document_date", putDate(buf_utd.DocumentDate)) + "," . 
vData = vData + writeTag("primary_document_custom_name", vBaseDocCustomName) + "," .   

vData = vData + quoter("products") + ":" + "~[" .
for each buf_utd-lines no-lock where buf_utd-lines.db-num = buf_utd.db-num
                                 and buf_utd-lines.doc-id = buf_utd.doc-id
                                 break by buf_utd-lines.LineNum
:
  vData = vData + "~{" .
  vData = vData + writeTag("gtin", buf_utd-lines.ProductCode) + "," .
  vData = vData + quoter("gtin_quantity")  + ":" + string(integer(buf_utd-lines.Quantity)) .
  vData = vData + "~}" .
  if not last(buf_utd-lines.LineNum) then vData = vData + "," .
end .
vData = vData + "~]" .
vData = vData + "~}" .

copy-lob from vData to vMemptr .

p-Base64doc = base64-encode(vMemptr) .