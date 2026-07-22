using Progress.Lang.*.
using ibs.th.skt.Commands.*.
block-level on error undo, throw.
class ibs.th.skt.Commands.ICommandProc inherits ICommand  abstract:
   define public property hpApi as handle no-undo
   get.
   private set.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
method public integer IsProcessRunning
  (PID AS INTEGER) :
  DEFINE VARIABLE IsRunning   AS LOGICAL NO-UNDO INITIAL NO.
  DEFINE VARIABLE hProcess    AS INTEGER NO-UNDO.
  DEFINE VARIABLE ExitCode    AS INTEGER NO-UNDO.
  DEFINE VARIABLE ReturnValue AS INTEGER NO-UNDO.
  define variable rv          as integer no-undo .
  RUN OpenProcess in hpapi
                  ( 1024,
                    0,
                    PID,
                    OUTPUT hProcess).
  IF hProcess NE 0 THEN DO:
     RUN GetExitcodeProcess in hpapi
                  ( hProcess,
                    OUTPUT ExitCode,
                    OUTPUT ReturnValue).
     rv = (if (ExitCode=259) AND (ReturnValue NE 0)
          then  - 1
          else ReturnValue).
     RUN CloseHandle in hpapi (hProcess, OUTPUT ReturnValue).
  END.
  RETURN rv.
end.
   method public int64 runProc (icmd as character):
      return runProc(?, icmd).
   end.
   method public int64 runProc (idir as char, icmd as character):
     define variable bat-file as character no-undo.
     define variable v-pid as int64 no-undo.
     run gbl/_tmpfile.p (
                        input ""
                      , input "bat"
                      , output bat-file) .
     v-pid = runProcFile(idir,icmd, bat-file).
     return v-pid.
  end.
  method public int64 runProcFile (icmd as character, iFileName as character):
      return runProcFile(?, icmd,iFileName).
  end.
  method public int64 runProcFile (idir as char,icmd as character, iFileName as character):
     define variable v-pid as int64 no-undo.
     output to value(iFileName) convert target "ibm866".
     if idir ne ?
     then
        put  unformatted "cd " idir skip.
     put  unformatted icmd skip.
     output close.
     run gbl/run-gpid.p (input iFileName
                        ,input '':U
                        ,output v-pid).
     return v-pid.
  end.
   constructor public ICommandProc (  ):
      super ().
      run gbl\getwindows.p(output hpApi).
   end constructor.
   destructor public ICommandProc ( ):
   end destructor.
end class.
