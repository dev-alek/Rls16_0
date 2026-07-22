block-level on error undo, throw.
/*
$Revision:$
$Author:$
$Date:$
$Workfile:$
$Archive:$

Автор: Ростовцев А.М. 
Дата создания: 26 фев. 2026 г.
Author:  Rostovtsev A.M.
Creation date: 26 фев. 2026 г.

*/ 
define input  parameter parparentproc as handle  no-undo.

define variable vss-revision    as character no-undo init "$Revision:$":U .
define variable vss-author      as character no-undo init "$Author:$":U .
define variable vss-date        as character no-undo init "$Date:$":U .
define variable vss-workfile    as character no-undo init "$Workfile:$":U .
define variable vss-archive     as character no-undo init "$Archive:$":U .
define variable vss-description as character no-undo init "".


{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/db-attr.i  }
{ cmp/trg-def.i }
{ ibs/th/bge/xmlimpexp.i }
{ utl/search.i }

define temp-table ttUpd 
  field fName     as character
  field fNamePath as character
  field fMd5      as character
  index fName fName
. 

define variable mDirUpdCk as character no-undo.
define variable mfile as character no-undo.
define variable mfilemd5 as character no-undo.
define variable v-md5-signature  as character no-undo.
define variable vimport as class ibs.th.bge.xmlimpexp no-undo.
define variable mTxt as character no-undo.
define variable mfilever as char no-undo init ?.
define variable m-type as character no-undo.
define variable mdbver as integer no-undo.
define variable f_load as logical no-undo init no.
/*define variable mRunTransaction as logical no-undo.*/
define variable v-filename as character no-undo.
define variable v-fullfilename as character no-undo.
define stream md5in.
define stream dir-stream.

subscribe "RunProcXmlImp" anywhere run-procedure "RunProcAny". 
subscribe "NotSendNwsForTable" anywhere run-procedure "DisableNws". 
subscribe "DisableNwsTable" anywhere run-procedure "SetNwsTable".
vimport= new ibs.th.bge.xmlimpexp().

mDirUpdCk = objExists("updck","D").
/*run waitfram-show in parparentproc (substitute("DEBUGER: mDirUpdCk:&1.", mDirUpdCk)). */
if mDirUpdCk = ? then return.
input stream dir-stream from os-dir( mDirUpdCk ) no-attr-list no-echo .

block-upd:
repeat:
   /* выгружаем во временную таблицу xml-файлы из updck      */
   /* вдруг понадобиться их выполнять в определенном порядке */
   /* тогда их надо нумеровать */

   import stream dir-stream v-filename v-fullfilename .
/* run waitfram-show in parparentproc (substitute("DEBUGER: v-fullfilename:&1.", v-fullfilename)). */

   file-info :file-name = v-fullfilename.
   if caps( file-info :file-type ) begins "F":U and
      entry(2, file-info:file-name, ".") = "xml" then 
   do:
       create ttUpd.
       assign
         ttUpd.fName     = v-filename
         ttUpd.fNamePath = v-fullfilename
         ttUpd.fMd5      = entry(1, v-fullfilename, ".") + ".md5"
       .
/* run waitfram-show in parparentproc (substitute("DEBUGER: ttUpd.fMd5:&1.", ttUpd.fMd5)). */
   end.
end.
input stream dir-stream close.

block-for:
for each ttUpd by ttUpd.fName:
      mfile    = ttUpd.fNamePath.
      mfilemd5 = ttUpd.fMd5.
      if    mfile    eq ? 
         or mfilemd5 eq ?
      then 
         leave block-for.
      
/*      run waitfram-show in parparentproc ("Обработка " + mFile ) no-error.  */
/*      message "Обработка "  mFile  view-as alert-box.*/
      if search(mfilemd5) = ? then
      do:
        return error substitute("Не найден файл сигнатуры &1.", mfilemd5).  
      end.

      input  stream md5in from value (mfilemd5).
      import stream md5in mtxt no-error.
      input  stream md5in close.
      run gbl/md5.p (
          input  mfile
         ,output v-md5-signature /* p-md5-signature */
         ) .

      if mtxt eq {utl/chekmd5ck.i v-md5-signature }
      then do:
         vimport:xmldom-load-ver  ( mfile,? ) no-error.
/*         mRunTransaction = vimport:mTransaction.*/
         if error-status:error
         then
            return error return-value.


/*         if mRunTransaction then*/
/*         do:                    */
            UPD_TBL:
            do transaction on error undo UPD_TBL, leave UPD_TBL:
               vimport:updatetablefordb(this-procedure) no-error.
               if error-status:error
                  then return error return-value.
            end.

         CODE_UPD:                                                                                           
         do transaction on error undo CODE_UPD, leave CODE_UPD:  
         define variable lcXML as longchar no-undo.
         copy-lob from file mfile to lcXML.
            create code  no-error.
            assign
               code.parent    = substitute("XML_BACKUP")
               code.code      = substitute("&1 &2",string(now), entry(num-entries(mfile, "\"),mfile, "\"))
               code.CodeValue = entry(num-entries(mfile, "\") , mfile, "\")
               code.misc1     = v-md5-signature
               code.misc2     = string(mdbver)
               code.misc3     = lcXML
               code.procview  = "ibs\th\ref\code\xmlbackup.p"
               /*code.nwsgbd    = yes.*/
               /*code.nwsubd    = yes. */
            .
         end.


/*         end.                                                 */
/*         else do:                                             */
/*            vimport:updatetablefordb(this-procedure) no-error.*/
/*            if error-status:error                             */
/*               then return error return-value.                */
/*         end.                                                 */

/*         CODE_UPD:                                                                                           */
/*         do transaction on error undo CODE_UPD, leave CODE_UPD:                                              */
/*                                                                                                             */
/*            create code  no-error.                                                                           */
/*            assign                                                                                           */
/*               code.parent    = substitute("XML_UPDCK&1 &2",{&delim-par},string(ibs.th.gbl.gbl-var:g#db-num))*/
/*               code.code      = string(now)                                                                  */
/*               code.CodeValue = entry(num-entries(mfile, "\") , mfile, "\")                                  */
/*               code.misc1     = v-md5-signature                                                              */
/*               code.misc2     = string(mdbver)                                                               */
/*               code.misc3     = string(ibs.th.gbl.gbl-var:g#db-num)                                          */
/*               code.nwsgbd    = yes.                                                                         */
/*               code.nwsubd    = yes.                                                                         */
/*            .                                                                                                */
/*            f_load = yes.                                                                                    */
/*         end.                                                                                                */
         return-value = "".
         vimport:xmldom-clear().
      end.
      else
         return error substitute("Файл &1 имеет не правильную сигнатуру md5.", mfile).
end.

define variable v-err-msg as character no-undo .  
catch exAppErrors as class Progress.Lang.AppError :
    v-err-msg = exAppErrors:ReturnValue .
    if v-err-msg > "" then . else do :
       v-err-msg = exAppErrors:GetMessage(1) .
      if v-err-msg > "" 
      then v-err-msg = "AppError в модуле {&FILE-NAME}" + v-err-msg. 
      else v-err-msg = "AppError в модуле {&FILE-NAME}" .
    end .
  end catch .
  catch exProErrors as class Progress.Lang.ProError :
    v-err-msg = exProErrors:GetMessage(1) . 
    if v-err-msg > "" 
    then v-err-msg = "ProError в модуле {&FILE-NAME}" + v-err-msg. 
    else v-err-msg = "ProError в модуле {&FILE-NAME}" .
    return error v-err-msg.
  end catch .
  catch exAnyErrors as class Progress.Lang.Error:
    v-err-msg = "Unexpected error в модуле {&FILE-NAME} " + exAnyErrors:GetMessage(1).
    return error v-err-msg.
end catch .

finally:
   if valid-object(vimport)
   then
      delete object vimport.
   unsubscribe "NotSendNwsForTable". 
   unsubscribe "DisableNwsTable".
   unsubscribe "RunProcXmlImp".
end finally.
