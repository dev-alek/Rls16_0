block-level on error undo, throw.
/*
$Revision:$
$Author:$
$Date:$
$Workfile:$
$Archive:$

Автор: Рубан Дмитрий Андреевич 
Дата создания: 8 окт. 2019 г.
Author:  Ruban Dmitriy Andreevich
Creation date: 8 окт. 2019 г.

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
{ gbl/getcntxt.i def    }
{ gbl/getcntxt.i get    }

define buffer buf_db for ub.db.
find first buf_db no-lock where buf_db.db-num = v-cntxt-db-num no-error.
define variable updschmObj      as class ibs.th.adm.upd.CheckUpd no-undo.
updschmObj = new ibs.th.adm.upd.CheckUpd (no).
updschmObj:updChceck().
if     buf_db.reserve1-char begins "updto:"
    or updschmObj:CurrDBShm ne int(buf_db.reserve1-char)
then do trans:
   find first buf_db exclusive-lock where buf_db.db-num = v-cntxt-db-num no-error.
   buf_db.reserve1-char = string(updschmObj:CurrDBShm).   
end.
delete object updschmObj no-error.

define variable mfile as character no-undo.
define variable mfilemd5 as character no-undo.
define variable v-md5-signature  as character no-undo.
define variable vimport as class ibs.th.bge.xmlimpexp no-undo.
define variable mTxt as character no-undo.
define variable mfilever as char no-undo init ?.
define variable m-type as character no-undo.
define variable mdbver as integer no-undo.
define variable mdbver_old as integer no-undo.
define variable f_load as logical no-undo init no.
define variable mRunTransaction as logical no-undo.
define stream md5in.

run db-attr-value in this-procedure 
           (input ibs.th.gbl.gbl-var:g#db-num
           ,input {&attr-ver-met}
           ,output mTxt
           ,output m-type 
           ) no-error .
mdbver_old = int(mtxt) no-error.
if mdbver_old eq ?
then
   mdbver_old = 0.
subscribe "RunProcXmlImp" anywhere run-procedure "RunProcAny". 
subscribe "NotSendNwsForTable" anywhere run-procedure "DisableNws". 
subscribe "DisableNwsTable" anywhere run-procedure "SetNwsTable".
vimport= new ibs.th.bge.xmlimpexp().
block-upd:
do mdbver = mdbver_old + 1 to 999999999:
   mfile    = search(substitute("upd/&1.xml",string(mdbver,"999999999"))).
   mfilemd5 = search(substitute("upd/&1.md5",string(mdbver,"999999999"))).
   if    mfile    eq ? 
      or mfilemd5 eq ?
   then 
      leave block-upd.
   input  stream md5in from value (mfilemd5).
   import stream md5in mtxt no-error.
   input  stream md5in close.
   run gbl/md5.p (
          input  mfile
         ,output v-md5-signature /* p-md5-signature */
         ) .


   if mtxt eq {utl/chekmd5.i v-md5-signature } 
   then do:
      vimport:xmldom-load-ver  ( mfile,? ) no-error.
      mRunTransaction = vimport:mTransaction.

      if error-status:error
      then
         return error return-value.

      /* BTS-1871 03.02.2026 Чтобы не открывать транзакцию при изменения/удаления больших данных    */
      /* нужно задать тег NoTransaction внутри File-info с любым значением                          */
      /* <File-info>                                                                                */       
      /*    <NoTransaction>Yes</NoTransaction>                                                      */
      /* </File-info>                                                                               */
      /* В этом случае при возникновении ошибки загрузки восстановление данных необходимо выполнять */
      /* программным путем или делать копию БД перед накатом обновлений                             */
      if mRunTransaction then
      do:
        UPD_TBL:
        do transaction on error undo UPD_TBL, leave UPD_TBL:
          vimport:updatetablefordb(this-procedure) no-error.
          if error-status:error
            then return error return-value.
        end.
      end.
      else do:
         vimport:updatetablefordb(this-procedure) no-error.
         if error-status:error
           then return error return-value.
      end.

       CODE_UPD:
       do transaction on error undo CODE_UPD, leave CODE_UPD:

       create code  no-error.
         assign 
         code.parent    = substitute("XML_UPD&1 &2",{&delim-par},string(ibs.th.gbl.gbl-var:g#db-num))
         code.code      = string(now)
         code.CodeValue = entry(num-entries(mfile, "\") , mfile, "\")
         code.misc1     = v-md5-signature
         code.misc2     = string(mdbver)
         code.misc3     = string(ibs.th.gbl.gbl-var:g#db-num)
         code.nwsgbd    = yes.
         code.nwsubd    = yes.
         .
       f_load = yes.
       end.      
      return-value = "".
      vimport:xmldom-clear().
   end.
   else
      return error substitute("Файл &1 имеет не правильную сигнатуру md5.", mfile).
    
   
end.
mdbver = mdbver - 1.
if mdbver gt mdbver_old
then
   run db-attr-write in this-procedure ( input ibs.th.gbl.gbl-var:g#db-num
                                       , input {&attr-ver-met}
                                       , input string (mdbver)
                                       )  .   
mfile    = search("upd/code.xml").
mfilemd5 = search("upd/code.md5").
  /*проверим md5*/
if mfile ne ? and mfilemd5 ne ? 
then do:
   input  stream md5in from value (mfilemd5).
   import stream md5in mtxt no-error.
   input  stream md5in close.
   run gbl/md5.p (
          input  mfile
         ,output v-md5-signature /* p-md5-signature */
         ) .
   if mtxt ne {utl/chekmd5.i v-md5-signature }  
   then 
      return error substitute("Файл &1 имеет не правильную сигнатуру md5.", mfile).
   mfilever = vimport:xmldom-load-ver  ( mfile,? ) no-error.
   if error-status:error
   then
      return error return-value.

   IMP_CODE:
   do transaction on error undo IMP_CODE, leave IMP_CODE:
       vimport:updatetablefordb(this-procedure) no-error.

       if error-status:error
       then
          return error return-value + " " + error-status:get-message(1).
       else 
          run db-attr-write in this-procedure ( input ibs.th.gbl.gbl-var:g#db-num
                                              , input {&attr-ver-code}
                                              , input mfilever
                                              ) no-error .

   end.

   CODE_UPD2:
   do transaction on error undo CODE_UPD2, leave CODE_UPD2:

   find last code no-lock where code.CodeValue = "code.xml" no-error.
   if available code and code.misc1 <> v-md5-signature
         then do:
         create code no-error.
            assign 
            code.parent    = substitute("XML_UPD&1 &2",{&delim-par},string(ibs.th.gbl.gbl-var:g#db-num))
            code.code      = string(now)
            code.CodeValue = entry(num-entries(mfile, "\") , mfile, "\")
            code.misc1     = v-md5-signature
            code.misc2     = string(mdbver)
            code.misc3     = string(ibs.th.gbl.gbl-var:g#db-num)
            code.nwsgbd    = yes.
            code.nwsubd    = yes.
            .
   f_load = yes.
   end.

   if not available code 
         then do:
         create code  no-error.
            assign 
            code.parent    = substitute("XML_UPD&1 &2",{&delim-par},string(ibs.th.gbl.gbl-var:g#db-num))
            code.code      = string(now)
            code.CodeValue = entry(num-entries(mfile, "\") , mfile, "\")
            code.misc1     = v-md5-signature
            code.misc2     = string(mdbver)
            code.misc3     = string(ibs.th.gbl.gbl-var:g#db-num)
            code.nwsgbd    = yes.
            code.nwsubd    = yes.
            .
   f_load = yes.
   end.

   end.      

   return-value = "".
   vimport:xmldom-clear().
end.

if f_load = no
        then do:

   CODE_UPD3:
   do transaction on error undo CODE_UPD3, leave CODE_UPD3:

/*	find last code no-lock where code.parent = "XML_UPD" no-error. */
        find last code no-lock where code.parent BEGINS "XML_UPD" no-error.
        mfile    = search(substitute("upd/&1.xml", string(mdbver_old, "999999999"))).
        mfilemd5 = search(substitute("upd/&1.md5", string(mdbver_old, "999999999"))).
        if mfile ne ? and mfilemd5 ne ? then do:
	        input stream md5in from value(mfilemd5).
	        import stream md5in mTxt no-error.
	        input stream md5in close.
	        run gbl/md5.p (input  mfile, output v-md5-signature) no-error.
	        if available code and code.misc1 ne v-md5-signature then do:
		        create code no-error.
		        assign
                        code.parent    = substitute("XML_UPD&1 &2",{&delim-par},string(ibs.th.gbl.gbl-var:g#db-num))
		        code.code      = string(now)
		        code.CodeValue = entry(num-entries(mfile, "\") , mfile, "\")
		        code.misc1     = v-md5-signature
		        code.misc2     = string(mdbver)
		        code.misc3     = string(ibs.th.gbl.gbl-var:g#db-num)
                        code.nwsgbd    = yes.                              
                        code.nwsubd    = yes.
		        .
	        end.
	end.
   end.
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
