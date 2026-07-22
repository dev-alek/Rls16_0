 
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


class ibs.th.skt.Commands.CashSend inherits ICommand: 
   { cmp/str-glbl.i class}
   { gbl/cur-time.i}
   define override public property vss-revision    as character no-undo init "$Revision:$":U get .
  define override public property vss-author      as character no-undo init "$Author:$":U get.
  define override public property vss-date        as character no-undo init "$Date:$":U get.
  define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
  define override public property vss-archive     as character no-undo init "$Archive:$":U get.
  define override public property vss-description as character no-undo init "премер отложеных запросов в сокет" get.

   /*------------------------------------------------------------------------------
    Purpose:
    Notes:
   ------------------------------------------------------------------------------*/
   define variable mAsyncHelper as class ibs.th.file.AsyncHelperth  no-undo.
      
   constructor public CashSend (ilogh as handle  ):
      super ().
      mAsyncHelper = new ibs.th.file.AsyncHelperth().
      mAsyncHelper:mProcPublish = ilogh.
      mAsyncHelper:setCurrentUserPasswd().
      mAsyncHelper:MyBachMode = yes.
/*      mAsyncHelper:WritelogInter = 5.*/
/*      mAsyncHelper:MyBachMode = yes. */
      mAsyncHelper:maxproc    = 1.
  
   end constructor.
   
   method override public void ContinueExecution(input req as IRequest, input resp as IResponse ):
/*      createfile().*/
      define variable vParam as longchar no-undo.
      define variable vTask as character no-undo.
      vTask = resp:ParamWait:getParamValue("task").
      if EndProcShed(vTask)
      then do:
         define variable vlogfile as longchar no-undo.
         vlogfile = Putlog(vTask).
         
         resp:condition = resp:STSlist:WriteResponse:NameProp.
         if vlogfile eq ""
         then
            resp:setContent("ok").
         else
            resp:setContent(vlogfile).
      end.
   end method.

   define variable ShedCount as integer no-undo.
   method override public void Execute_( input req as IRequest, input resp as IResponse ):
      define variable vTask as character no-undo.
      resp:condition = resp:STSlist:WaitResult:NameProp.
      ShedCount = ShedCount + 1.
      vTask = "CashSend" + string(ShedCount).
      define variable vadr as character no-undo.
      vadr = replace(req:queryadr, "\", "/").
      vadr = if num-entries (req:queryAdr, "/") > 1
              then entry(2,req:queryAdr,"/")
              else "".
      if vadr ne ""
      then do:         
         addtask(vTask, "utl/proc-cashsend.p",substitute ("cashsend.txt&1&2&1&3&1&4&1&5",
                                                          {&delim-par},
                                                          vadr,
                                                          req:getQueryParam("shop-num"),
                                                          req:getQueryParam("cash"),
                                                          req:getQueryParam("max-count")  )
                ) .
         resp:ParamWait:setParam("task",vTask).
      end.
      else do:
         resp:condition = resp:STSlist:WriteResponse:NameProp.
         resp:setContent("Не уазано, что нужно отправить").
      end.
      
   end method.
   
   define variable mLableText as character no-undo.
   define variable mStartTime as datetime-tz no-undo init ?.

   method public void addtask(ITask  as character, 
                              iProc  as character, 
                              iParam as character):
/*      subscribe "PutFileLogAsunc" anywhere run-procedure "WriteLogAsync".*/
      if mStartTime ne ?
      then
         mAsyncHelper:AddTask (ITask,iProc,iParam,mStartTime).
      else
         mAsyncHelper:AddTask (ITask,iProc,iParam).
      mAsyncHelper:AsyncRun().
/*      unsubscribe "PutFileLogAsunc".*/
   end.   
   
   method public void  addTask(ITask  as character, 
                              iProc  as character, 
                              iParam as character,
                              iStartTime as datetime-tz
                              ):
/*   subscribe "PutFileLogAsunc" anywhere run-procedure "WriteLogAsync".*/
      mAsyncHelper:AddTask (ITask,iProc,iParam,iStartTime).
      mAsyncHelper:AsyncRun().
/*   unsubscribe "PutFileLogAsunc".*/
end.  

   method public void  waitproc(itext  as character):
/*      subscribe "PutFileLogAsunc" anywhere run-procedure "WriteLogAsync".*/
      run ibs\th\file\waithelper.p (mAsyncHelper,?,1,itext + " " + mLableText).
/*      unsubscribe "PutFileLogAsunc".*/
   end.  
   method public void  waitProcLable(itext  as character):
      mLableText = itext.
   end. 

   method public void  waitProcShed(iSched as character,
                                    itext  as character):
/*      subscribe "PutFileLogAsunc" anywhere run-procedure "WriteLogAsync".*/
      run ibs\th\file\waithelper.p (mAsyncHelper,iSched,1,itext).
/*      unsubscribe "PutFileLogAsunc".*/
   end.
   define stream sReadfile.
   
   method public longchar  putlog (iSched as character):
/*      run gbl\inidebug.p.                    */
      define variable vlogfile   as character no-undo.
      define variable vText      as character no-undo.
      define variable vErrorText as longchar no-undo.
      mAsyncHelper:DelShedDirEndProc(iSched).
      vlogfile = mAsyncHelper:getLog(iSched).
      
      if mAsyncHelper:FileExists(vlogfile)
      then do:
         input stream sReadfile FROM  VALUE(vlogfile).
         repeat:
            import stream sReadfile unformatted vText.
            if    vtext begins "error"
               or entry(3,vtext," ") eq "error"  
            then
               vErrorText = vErrorText + " " +  vtext.
            logWrite:WriteFileToLog(vtext). 
         end.
         input stream sReadfile close  .
         os-delete value(vlogfile).
      end.
      mAsyncHelper:DelShedDirEndProc(iSched).
      if vErrorText ne ""
      then
         logWrite:LogStr = "Возникла ошибка при отправке данных на кассу". 
      return vErrorText.
   end.  
   
   method public logical  EndProcShed(iSched as character):
/*      subscribe "PutFileLogAsunc" anywhere run-procedure "WriteLogAsync".*/
      mAsyncHelper:WaitForOne(iSched).
      return not mAsyncHelper:isWorkShed(iSched).
/*      unsubscribe "PutFileLogAsunc".*/
   end.
    
	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	destructor public CashSend ( ):
      delete object mAsyncHelper no-error.
	end destructor.


end class.