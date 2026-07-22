define input  parameter mhelper as ibs.th.file.asynchelperTh no-undo.
define input  parameter iSched as character no-undo.
define input  parameter ipInterval as int64 no-undo.
define input  parameter itext as character no-undo.
{gbl\waitfram.i}

procedure WaitFramStop:
   run WaitFramStopMes("Операция прервана пользователем.").
end.

define variable mSched as character no-undo.

procedure WaitFramStopMes:
   define input  parameter iMes as character no-undo.
   define variable vCount as integer no-undo.
   define variable vi as integer no-undo.
   define variable vWaitFramStartProc          as datetime-tz no-undo.

   if    mWaitFramStop
      or mhelper:mStop
      or mWaitFramStopTimeOut
      or not mhelper:FileExists(mhelper:MyWorkDir + "Stop.txt")
   then do:
      mhelper:mStop = yes.
      mWaitFramStop = yes.
      mhelper:SendStop(mSched).
      mWaitFramInterval = ipInterval.
      vWaitFramStartProc = now.

      block-waitshow:
      do vi = 1 to 10:
         define variable vtime as int64 no-undo.
         vtime = ( now - vWaitFramStartProc  ) / 1000 .

         run waitfram-show (substitute("&1 Отправлена команда прерывания. Ожидаем завершения процесса. Прошло: &2 сек. из 10 сек. &3" ,
                            mWaitFramTextBeg , 
                            string( vtime),
                            mWaitFramTextEnd
                                       )
                            ).
         if mhelper:WaitStopEnd(mSched, 0)
         then
            leave block-waitshow.
      end.
      publish "PutFileLogAsunc"  (iMes).
      mhelper:EndStopEnd(mSched).
      mhelper:mStop = no.
      mhelper:WAIT-FOR-COMPLETE = true. /* процес завис */
   end.
   else do:
      mhelper:WAIT-FOR-COMPLETE = true.
      mhelper:WaitForOne(mSched) .
      mWaitFramStop = mhelper:WAIT-FOR-COMPLETE.
   end.
   mWaitFramTextend = mhelper:getStatus(mSched).
end.
procedure waitProc:
   define input  parameter iSched   as character no-undo.
   define input  parameter iTimeOut as integer   no-undo.
   mSched = iSched.
   mWaitFramTextBeg = itext.
   mWaitFramStartProc = now.
   mWaitFramTimeOut = iTimeOut.
   mWaitFramStopTimeOut = no.
   mWaitFramStop        = no.
   mhelper:Writefile(mhelper:MyWorkDir + "Stop.txt","").
   mhelper:vCountend = 0.
   subscribe   to "WaitFramStop" anywhere.
   run WaitFramWaitFor(ipInterval).
   unsubscribe   to "WaitFramStop".
   if mWaitFramStopTimeOut
   then
      run WaitFramStopMes("Операция прервана по таймауту.").
end.

mWaitFramView = not mhelper:InAsyncProc.
mWaitProcEvent = no.
define variable mTaskList    as character no-undo.
define variable mTimeOutTask as integer   no-undo.
define variable vi           as integer   no-undo.
define variable mCheckTask   as character no-undo.
mTaskList = iSched.
if    mTaskList eq ""
   or mTaskList eq ?
then
   mTaskList = mhelper:getListTask().
   
do vi = 1 to num-entries(mTaskList):
   mCheckTask = entry(vi,mTaskList).
   mTimeOutTask = mhelper:getTimeOutTask(mCheckTask).
   if mTimeOutTask ne ?
      and  mhelper:isAvailWorkShed(mCheckTask)
   then
      run waitProc(mCheckTask,mTimeOutTask).
end.   
run waitProc(iSched,mhelper:myTimeOut).
return.
finally:
   mWaitFramTextBeg = "".
   run waitfram-hide.
end finally.
  
  