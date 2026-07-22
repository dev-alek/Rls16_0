{&CommentStartNoClass}
method public character  GetDocumforid
{utl\comment.i} "Изврат для eclipse" */ {&CommentStartClass}
function GetDocumforid returns character
{utl\comment.i} */
(input  iorg as character ,
 input  idoc-id as character ,
 output oDocument      as component-handle
  ):
   define variable vOrganization  as component-handle no-undo.
   define variable vDocument      as component-handle no-undo.
   define buffer utd           for ub.utd.
   
   if     
          iorg  ne ?
      and iorg  ne ""
      and idoc-id ne ?
      and idoc-id ne ""
   then do:
      vOrganization = mDiadocConnection:GetOrganizationById(iorg) no-error.
      if vOrganization ne ?
      then do:
         oDocument = vOrganization:GetDocumentById(idoc-id,false) no-error.
         if oDocument eq ?
         then
            PutErr(substitute("Error Нет доступа к документу &2 по организации &1. ", iorg,idoc-id)).
      end.
      else do:
         PutErr(substitute("Error Нет доступа к организации &1 по документу &2. ", iorg,idoc-id)).
         return "Нет доступа к организации " + iorg.
      end.
   end.
   else
      return "Нет доступа к организации не ЭДО".
   
   release object vOrganization no-error.
   return "". 
end.

{&CommentStartNoClass}
method public character  GetDocum
{utl\comment.i} "Изврат для eclipse" */ {&CommentStartClass}
function GetDocum returns character
{utl\comment.i} */
(input  idb-num as integer,
 input  idoc-id as integer,
 output oDocument      as component-handle
  ):
   define variable vOrganization  as component-handle no-undo.
   define variable vDocument      as component-handle no-undo.
   define buffer utd           for ub.utd.
   find first utd where utd.db-num eq idb-num
                    and utd.doc-id eq idoc-id
   no-lock no-error.
   if     available utd
      and utd.OrganizationExt ne ?
      and utd.OrganizationExt ne ""
      and utd.DocumentExt ne ?
      and utd.DocumentExt ne ""
   then do:
      vOrganization = mDiadocConnection:GetOrganizationById(utd.OrganizationExt) no-error.
      if vOrganization ne ?
      then do:
         oDocument = vOrganization:GetDocumentById(utd.DocumentExt,false) no-error.
         if oDocument eq ?
         then
            PutErr(substitute("Error Нет доступа к документу &2 по организации &1. ", utd.OrganizationExt,utd.DocumentExt)).

         release object vOrganization no-error.
      end.
      else do:
         PutErr(substitute("Error Нет доступа к организации &1 по документу &2. ", utd.OrganizationExt,utd.DocumentNumber)).
         return "Нет доступа к организации " + utd.OrganizationExt.
      end.
   end.
   else
      return "Нет доступа к организации не ЭДО".
   
   
   return "". 
end.

{&CommentStartNoClass}
method public logical GetFirstUTDinPack
{utl\comment.i} "Изврат для eclipse" */ {&CommentStartClass}
function GetFirstUTDinPack returns logical 
{utl\comment.i} */
(input idb-num as integer, 
 input idoc-id as integer,
 output odb-num as integer,
 output odoc-id as integer ):
   define buffer buf_utd for utd.
   define buffer     utd for utd.
   find first utd where utd.db-num eq idb-num
                    and utd.doc-id eq idoc-id
   no-lock no-error.
   if available utd
   then do:
      if utd.PackageId eq ""
      then do:
         assign
            odb-num = utd.db-num
            odoc-id = utd.doc-id
         .
         return yes.
      end.
      else do:
         find first buf_utd where Buf_utd.PackageId eq utd.PackageId
                              and Buf_utd.EDocType  eq objSrv:Env:Utd:EDocType:UTD:KeyIntDB
                              
         no-lock.
         assign
            odb-num = buf_utd.db-num
            odoc-id = buf_utd.doc-id
         .
         
         return if available buf_utd then (recid(utd) eq recid(buf_utd)) else no.
      end.  
   end.
   return ?.
end.
{str/edo-mark.i}