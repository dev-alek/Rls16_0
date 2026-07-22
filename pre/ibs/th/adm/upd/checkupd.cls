using Progress.Lang.*.
using ibs.th.adm.upd.*.
block-level on error undo, throw.
class ibs.th.adm.upd.CheckUpd:
   constructor public CheckUpd (  ):
      this-object (yes).
   end constructor.
   define variable obsrvdbObj as class observupd no-undo.
   define property TargetDBShm as integer no-undo
      get.
      private set.
   define property CurrDBShm as integer  no-undo
      get.
      private set.
   define property isNeedUpd as logical no-undo
   get:
      return updChceck().
   end.
   define property isRcode as logical init ? no-undo
   get:
      if isRcode eq ?
      then do:
         def var loadDFProcFile as char no-undo.
         loadDFProcFile = search ("ibs/th/adm/upd/loaddf.r").
         isRcode = loadDFProcFile ne ?.
      end.
      return isRcode.
   end.
   set.
   define variable IQS as logical no-undo.
   constructor public CheckUpd (IQS as logical):
      this-object:IQS = IQS.
   end constructor.
   define variable mupd as logical no-undo init yes.
   method public logical updChceck ():
      define variable isNeedUpd as logical no-undo.
      obsrvdbObj = new observupd ().
      isNeedUpd = obsrvdbObj:isneedupg(yes).
      CurrDBShm   = obsrvdbObj:CurrDBShm.
      TargetDBShm = obsrvdbObj:TargetDBShm.
      if not isNeedUpd
      then
         run utl\chekupd.p (yes,TargetDBShm, output isNeedUpd).
      if  not session:batch-mode and IQS and not isRcode and isNeedUpd
      then do:
         if(mupd) then do:
         message "Необходимо обновить базу с версии " CurrDBShm  " до " TargetDBShm " до запуска процесса. Остновить выполнение?" view-as alert-box question
             buttons yes-no title "[ ВНИМАНИЕ! ]" update isNeedUpd.
         mupd = false.
         end.
         else
            isNeedUpd = false.
      end.
      delete object obsrvdbObj.
      return isNeedUpd.
   end.
         define property isStopWork as logical no-undo
   get:
      return search("cmp/UpdWorkStop.txt") ne ?.
   end.
   define stream sOut.
   method public void workStop ():
      define variable vFile as character no-undo.
      define variable vPName as integer no-undo.
      vFile = search("cmp/update.bmp").
      if vfile eq ?
      then
         vFile = "cmp/UpdWorkStop.txt".
      else
         vFile = replace(vFile,"cmp/update.bmp","cmp/UpdWorkStop.txt" ).
      output stream sOut to vFile.
      put stream sOut unformatted "Stop update " now skip.
      do vPName = 1 to 100:
         if  program-name(vPName) = ? then  leave .
         put stream sOut (if  vPName ne 1 then  "" else  "->")  program-name (vPName) .
      end.
      output stream sOut close.
   end.
   method public void workStart ():
      define variable vFile as character no-undo.
      vFile = search("cmp/UpdWorkStop.txt").
      os-delete value(vFile).
   end.
   destructor public CheckUpd ( ):
   end destructor.
end class.
