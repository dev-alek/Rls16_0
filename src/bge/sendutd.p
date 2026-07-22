block-level on error undo, throw.
/*
$Revision:$
$Author:$
$Date:$
$Workfile:$
$Archive:$

Автор: Рубан Дмитрий Андреевич 
Дата создания: 24 сент. 2022 г.
Author:  Ruban Dmitriy Andreevich
Creation date: 24 сент. 2022 г.

*/
define input parameter parparentproc as handle no-undo.
define input  parameter iThump as character no-undo.
define input  parameter idb-num as integer no-undo.
define input  parameter idoc-id as integer no-undo.
define variable vss-revision    as character no-undo init "$Revision:$":U .
define variable vss-author      as character no-undo init "$Author:$":U .
define variable vss-date        as character no-undo init "$Date:$":U .
define variable vss-workfile    as character no-undo init "$Workfile:$":U .
define variable vss-archive     as character no-undo init "$Archive:$":U .
define variable vss-description as character no-undo init "".
{ cmp/vssrevis.i }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ utl/search.i }

{ str\edo.i }
define variable mTypeUtd as character no-undo.
mTypeUtd = getattrutd (idb-num,idoc-id,"TypeUTD").
if mTypeUtd eq ?
then
   return.
                     
ConectByCertif(iThump).
define variable vfile as character no-undo.
define buffer buf_utd for utd.
if mDiadocConnection eq ?
then do:
   message "Нет подключения к Диадоку." 
   view-as alert-box.
   return error  "Нет подключения к Диадоку.".
end. 
else do:
   find first buf_utd no-lock where buf_utd.db-num eq idb-num and buf_utd.doc-id = idoc-id no-error .
 
   run bge\utdxml.p(parparentproc,
                    mDiadocConnection,
                    buf_utd.OrganizationExt,
                    buf_utd.CounteragentId,
                    mTypeUtd,
                    idb-num, 
                    idoc-id) no-error.
   if error-status:error
   then 
      return.
   
   
   
   vfile = searchfile("UPD_" + string (idb-num) + "_" + string (idoc-id) + ".xml").
   CRnewDocum(buf_utd.OrganizationExt,
              buf_utd.CounteragentId,
              mTypeUtd,
              vfile)no-error.
   if error-status:error
   then do:
      release object mDiadocApi no-error.
      release object mDiadocConnection no-error.
      return error  return-value. 
   end.
end.              
release object mDiadocApi no-error.
release object mDiadocConnection no-error.