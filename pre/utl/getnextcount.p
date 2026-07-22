block-level on error undo, throw.
define input  parameter iFileName as character no-undo.
define input  parameter ikey      as character no-undo.
define input  parameter icode     as character no-undo.
define input  parameter iParam    as character no-undo.
define output parameter oCount    as int64 no-undo.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
 define stream sReadfile.
procedure GetAsuncNextcount:
   define input  parameter iFileName as character no-undo.
   define input  parameter ikey      as character no-undo.
   define input  parameter iCode     as character no-undo.
   define input  parameter iParam     as character no-undo.
   define output parameter oCount    as int64     no-undo init ?.
      define variable vAsyncHelper as class ibs.th.file.AsyncHelperth no-undo.
      define variable vText as character no-undo.
      define variable vlogfile as character no-undo.
      define variable vError as logical no-undo.
      if trans
      then do:
         vAsyncHelper = new ibs.th.file.AsyncHelperth().
         vAsyncHelper:setCurrentUserPasswd().
         vAsyncHelper:myTimeOut = 300.
         vAsyncHelper:AsyncProc("utl/proc-getnextcount", substitute("&1":U  +  chr(4)  + "&2":U + chr(4) + "&3":U , iFileName ,ikey, icode ),1).
         run ibs\th\file\waithelper.p (vAsyncHelper,"proc-getnextcount", 1,"Получаем значение счетчика.").
         vlogfile = vAsyncHelper:getlog(?).
         if vAsyncHelper:FileExists(vlogfile)
         then do:
            input stream sReadfile FROM  VALUE(vlogfile).
            repeat:
               import stream sReadfile unformatted vText.
               if vtext begins "error" then vError = yes.
               else do:
                  Ocount = int64(vText) no-error.
                  if error-status:error
                  then
                     vError = yes.
               end.
            end.
            input stream sReadfile close  .
            os-delete value(vlogfile).
          end.
          else
             vError = yes.
          vAsyncHelper:delworkdir().
          delete object vAsyncHelper.
       end.
       else
          vError = yes.
       if    vError
          or Ocount eq ?
          then do:
             define variable vCounterStor as class ibs.th.ref.counter.counterstorage.
             vCounterStor = new ibs.th.ref.counter.counterstorage().
             Ocount = vCounterStor:GetNextcount(iFileName , iKey,icode, iparam ).
             delete object vCounterStor.
          end.
   end.
 run GetAsuncNextcount(iFileName, ikey, icode,iParam, output oCount ).
