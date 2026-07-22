 
/*------------------------------------------------------------------------
   File        : LogWrite
   Purpose     : 
   Syntax      : 
   Description : 
   Author(s)   : Admin
   Created     : Mon Apr 20 22:05:32 MSK 2015
   Notes       : 
 ----------------------------------------------------------------------*/

using Progress.Lang.*.
block-level on error undo, throw.


class ibs.th.skt.Adapters.LogWrite: 
  define public static property isDebugMod as logical init yes
  get.
  set. 

  define public property LogStr as character no-undo
    get ():
      def var str as char no-undo.
      run ibs/th/skt/Adapters/GetLogStrProc.p (output str).
      return str.
    end  .
    set (str as char):
      run ibs/th/skt/Adapters/SetLogStrProc.p (input str).
    end.

    method public void WriteDebugLog(ifile as char) :
      if isDebugMod
      then
         WriteFileToLog (ifile).
    end.

    method public void WriteDebugLog(iText as longchar) :
      if isDebugMod
      then
         WriteFileToLog (iText).
    end.

    method public void WriteFileToLog(ifile as char, icodepage as char) :
      run ibs/th/skt/Adapters/WriteFileToLog.p (ifile,icodepage).
    end.
   
    method public void WriteFileToLog(ifile as char) :
      run ibs/th/skt/Adapters/WriteFileToLog.p (ifile,?).
    end.
    
    method public void WriteFileToLog(iText as longchar) :
       if length (iText) < 1000
       then do:
          define variable vTempStr as character no-undo.
          vTempStr = iText.
          WriteFileToLog(vTempStr).
       end.
       else do:
          os-delete "filewrireLog.txt".
          copy-lob iText to
                   file "filewrireLog.txt".
          WriteFileToLog ("filewrireLog.txt").
       end.
    end.

end class.