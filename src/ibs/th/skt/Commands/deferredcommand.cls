 
 /*------------------------------------------------------------------------
    File        : DeferredCommand
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : Daru
    Created     : Wed Sep 13 20:12:17 MSK 2023
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using ibs.th.skt.Commands.*.
block-level on error undo, throw.


class ibs.th.skt.Commands.DeferredCommand inherits ICommand: 
   { cmp/str-glbl.i class}
   { gbl/cur-time.i}
   define override public property vss-revision    as character no-undo init "$Revision:$":U get .
  define override public property vss-author      as character no-undo init "$Author:$":U get.
  define override public property vss-date        as character no-undo init "$Date:$":U get.
  define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
  define override public property vss-archive     as character no-undo init "$Archive:$":U get.
  define override public property vss-description as character no-undo init "премер отложеных запросов в сокет" get.
   define temp-table tt-filetime
       field ffile as character 
       field ftime as decimal
       field fsec  as int 
       index ffile ffile
       index ftime ftime
       .
   
   method override public void ContinueExecution(input req as IRequest, input resp as IResponse ):
      createfile().
      define variable vParam as longchar no-undo.
      define variable vFile as character no-undo.
      vFile = resp:ParamWait:getParamValue("file").
      if search(vFile) ne ?
      then do:
         resp:condition = resp:STSlist:WriteResponse:NameProp.
         resp:setContent(vFile).
         os-delete value(vFile).
      end.
      
      
   end method.

   method override public void Execute_( input req as IRequest, input resp as IResponse ):
      
      resp:condition = resp:STSlist:WaitResult:NameProp.
      define variable sss as integer no-undo.
      sss = random(100000,999999).
      define variable vfile as character no-undo.
      vfile = "d:\11\test_soc\" + string(sss) + ".txt".
      os-delete value(vfile).
      find first tt-filetime where tt-filetime.ffile eq vfile no-error.
      if not available tt-filetime
      then do:
        create tt-filetime.
        assign
           tt-filetime.ffile = vfile
           tt-filetime.fsec  = random(1,50)
        .
        tt-filetime.ftime = cur-time-mjd() + tt-filetime.fsec / 86400 .
      end.
      /*define variable www as integer no-undo.
      www = random(10,50).
      
/* как-то это не особо хорошо работает, в плане создания файлов */
      output to "aaa.bat".
      put unformatted "powershell start-sleep -seconds  " + string(www) skip " echo " + string(www) + " > " + vfile skip " exit" skip.
      output close.
      os-command value("start aaa.bat & exit").
      */
      resp:ParamWait:setParam("file",vfile).
   end method.
   
   method private void createfile():
      define variable vtime as decimal no-undo.
      vtime = cur-time-mjd().
      for each tt-filetime where tt-filetime.ftime <= vtime:
         output to value(tt-filetime.ffile).
         put unformatted string(tt-filetime.fsec)skip.
         output close.
         delete tt-filetime.
      end.
   end.
end class.