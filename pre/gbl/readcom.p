DEFINE VARIABLE cCheckString AS CHARACTER NO-UNDO.
DEFINE STREAM StreamName.
define new global shared variable gComPort as integer no-undo init ?.
if gComPort eq ? then do:
   define variable vComPortstr as char no-undo.
   get-key-value section "REP-SETS"
                       key "ComPort"
                     value vComPortstr.
   gComPort = int(vComPortstr) no-error.
   if    error-status:error
      or gComPort < 1
      or vComPortstr eq ?
   then
      gComPort = 1.
end.
INPUT STREAM StreamName FROM value("COM" + string (gComPort)).
ASSIGN cCheckString = "".
REPEAT:
 READKEY STREAM StreamName PAUSE 1.
 IF LASTKEY = -1 THEN
 LEAVE.
 ELSE
 ASSIGN cCheckString = cCheckString + CHR(LASTKEY).
END.
INPUT STREAM StreamName CLOSE.
return cCheckString.
