 
 /*------------------------------------------------------------------------
    File        : AsyncHelper
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : druban
    Created     : Fri Aug 24 08:22:40 MSK 2018
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
block-level on error undo, throw.



class ibs.th.file.AsyncHelperth: 
   { cmp/str-glbl.i class}
   {utl/ttprocdef.i}
   {utl/ttfileList.i  ttfile  }
   define public property hpApi as handle no-undo 
   get.
   private set.
   { gbl/runrepid.i }


define temp-table ttfileList no-undo like ttfile.

      

   define stream sReadDir.
   define stream sReadfile.
   define stream sWriteFile.
   
define variable v-path-tls-dir-delim as character no-undo init "\":u.

define variable mRunProc as integer no-undo.

define public variable maxproc       as integer no-undo init 10.

   
define public variable mShowFrame   as logical    no-undo.
define public variable SaveFile     as logical    no-undo.

define public variable paramSession as character  no-undo init " -clientlog  mylog.lg -logginglevel 1".
define public variable WaitFile     as character  no-undo.

define public variable DbConnect    as logical    no-undo init yes.
define public variable SetGblPar    as logical    no-undo init ?.
define public variable PrintAll     as logical    no-undo.
define public variable ChangProPath     as logical    no-undo.
define variable WAIT-FOR-RUN as logical no-undo.
define variable mAsyncProc as class ibs.th.file.asyncproc no-undo.

define public property mProcPublish as handle     no-undo
get.
set(arg as handle):
   mAsyncProc:mProcPublish = arg.
   mProcPublish = arg.
end. 

   define public property MyParamStart as character  no-undo
   get.
    set (arg as char):
      if arg eq ""
      then
         MyParamStart = " -ininame "  + GetStartupParam("-ininame") +  GetStartupParamAndCode("-pf").
      
      else if arg ne ?
      then
         MyParamStart = arg.
    end.
    
    define public property WritelogInter as decimal no-undo
    get:
       return mAsyncProc:WritelogInter.
    end.
    set(arg as decimal):
       mAsyncProc:WritelogInter = arg.
    end.

define public property ConPar as character  no-undo init ?
get:
   define variable vconpar as character no-undo.
   if ConPar ne ?
   then 
      return ConPar.
   else do:
      get-key-value section "REP-SETS" key "ConPar" value vConPar.
      return vConPar.
   end.
end.
    set .

define public property InAsyncProc as logical  no-undo 
get:
   return mAsyncProc:myProcInfo().
end.
   
define public variable MyBachMode as logical no-undo init yes.
/*method private void GetOSErrorText (input iSourseDir as char,input iTargetDir as char,input cleadir as logical ):


end.*/
   define public property m-prowin32FileName as character no-undo
   get.
   set (arg as char):
      if arg eq ""
      then
         arg = "bin/prowin32.exe".
      arg = search(arg).
      if arg ne ?
      then
         m-prowin32FileName = arg.
   end.
    
   define variable myPID      as int64     no-undo.
   define variable myCompName as character no-undo.
   define variable myCompUser as character no-undo.
   define variable preWorkDir as character no-undo.
   
   define public property MyWorkDir as character no-undo
   get():
      return (if MyWorkDir  ne "" then( MyWorkDir + v-path-tls-dir-delim ) else "").
   end.    
   set (arg as char):
      if arg ne ?
      then do:
         define variable vi   as integer no-undo.
         if  arg eq "pid_"
         then do:
            if     myPID ne 0 
               and myPID ne ?
            then do:
               block-cr: 
               do vi = 1 to 1:
                  MyWorkDir = substitute("&1&2_&3" , preWorkDir, string(mypid), string(random(1,9999999))).
                  if objExists( MyWorkDir)
                  then
                     next block-cr.
                  os-create-dir VALUE(MyWorkDir).
                  MyWorkDir = objExists( MyWorkDir,"D").
                  if MyWorkDir ne ?
                  then
                     leave block-cr.
               end.
            end.
            else
               MyWorkDir = ?. 
         end.
         else
            MyWorkDir = objExists( arg,"D").
         if MyWorkDir ne ? 
         then
            Writefile(MyWorkDir + "parentPid.txt", string(mypid) + {&new-line}).
       end.
    end.
    
    define public property myTimeOut as int no-undo
    get.
    set.
    
    method public datetime-tz getnow():
       return mAsyncProc:getnow().
    end.
    
    method public datetime-tz getnowday():
       return mAsyncProc:getnowday().
    end.
    
    define public property myUser as character initial ? no-undo 
    get:
       if myUser eq ?
       then do:
          if connected ("ub":U) 
          then do:
             define variable vSystemUser as ibs.th.file.asyncparam no-undo.
             define variable vSystemPass as ibs.th.file.asyncparam no-undo.
             vSystemUser = mAsyncProc:getParamObj("SystemUser").
             vSystemPass = mAsyncProc:getParamObj("SystemPass").
             
             run utl/syspwd.p(input vSystemUser, input vSystemPass)no-error.
             myUser = vSystemUser:valueParam.
          end.  
       end.
       return myUser.
    end.
    set.
    
    define public property myPass as character initial ? no-undo 
    get:
       if myPass eq ?
       then do:
          if connected ("ub":U) 
          then do:
             define variable vSystemUser as ibs.th.file.asyncparam no-undo.
             define variable vSystemPass as ibs.th.file.asyncparam no-undo.
             vSystemUser = mAsyncProc:getParamObj("SystemUser").
             vSystemPass = mAsyncProc:getParamObj("SystemPass").
             
             run utl/syspwd.p(input vSystemUser, input vSystemPass)no-error.
             myPass = substitute("nocrypt:&1",vSystemPass:valueParam).
          end.  
       end.
       return myPass.
    end.
    set.
    
    method public void  setCurrentUserPasswd ():
       define variable vSystemUser as ibs.th.file.asyncparam no-undo.
       define variable vSystemPass as ibs.th.file.asyncparam no-undo.
       vSystemUser = mAsyncProc:getParamObj("SystemUser").
       vSystemPass = mAsyncProc:getParamObj("SystemPass").
       run utl/getuserpwdauto.p(input vSystemUser, input vSystemPass) no-error.
       if error-status:error
       then do:
          run utl/getuserpwd.p( input vSystemUser, input vSystemPass) no-error.
          if error-status:error
          then do:
             vSystemUser:valueParam = GetStartupParam("-U").
             vSystemPass:valueParam = GetStartupParam("-P").
          end.
       end.
       myUser = vSystemUser:valueParam.
       myPass = vSystemPass:valueParam.
    end.
    
    define public property TaskName as character no-undo
    get.
    set.
    
  define variable MSaveArhive as logical no-undo.
   
   constructor AsyncHelperth ( ):
   
      super ().
      define variable vi   as integer   no-undo.
      define variable vrep as character no-undo initial '/,\,:,*,",<,>,|'.
      run gbl\getwindows.p(output hpApi).
      m-prowin32FileName =  search ("bin/prowin32.exe").
      mAsyncProc = new ibs.th.file.asyncproc().
      run utl/getpid.p (output myPID,
                        output myCompName,
                        output myCompUser).
      do vi = 1 to num-entries (vrep):
         assign
            myCompName = replace(myCompName,entry(vi,vrep),"_")
            myCompUser = replace(myCompUser,entry(vi,vrep),"_")
         .
      end.
      preWorkDir = substitute("pid_&1_&2_&3" , myCompName, myCompUser).                  
      DelDontWorkProc().
/*      MyWorkDir = "pid_".*/
    /*  creatTTForDir("c:\11").
      updateFolder("c:\22", input table ttfile).
      message "ok"
         view-as alert-box.*/
         
   end constructor.
   
   destructor public AsyncHelperth ( ):
      if     SaveFile
         and not MSaveArhive
      then
         SaveArh().
      delworkdir().
      delete object mAsyncProc.
   end destructor.
   method public character  SaveArh ():
      return SaveArh("").
   end.
   method public character  SaveArh (itext as character ):
      define variable mDir as character no-undo.
      define variable marh as character no-undo.
      MSaveArhive = yes.
      mdir = trim(MyWorkDir,v-path-tls-dir-delim).
      marh = mdir + itext + ".zip".
      run utl\arh7z.p(marh,mdir).
      marh =objExists(marh,"F").
      return marh .
   end.
   
   define variable mIniFile as character no-undo.
   define variable mFirstrun as logical no-undo init yes.
   
   method public int64 AsyncProc (
      iProc    as character,
      iParam   as character,
      iCount as int64):
      define variable vprocname as character no-undo.
      
      iProc = right-trim(iProc,".r").
      iProc = right-trim(iProc,".p").
      vprocname = replace (iProc ,"/",v-path-tls-dir-delim).
      vprocname =   entry(num-entries(vprocname,v-path-tls-dir-delim),vprocname,v-path-tls-dir-delim).
      return AsyncProc(vprocname,iProc,iParam,iCount).
   end.
   define variable mrunnum as int64 no-undo.
   
   method public logical firstrun():
      
      if mFirstrun
      or not FolderExists(MyWorkDir)
      then do: /*создадим рабочуюю директорию */ 
         MyWorkDir = "pid_".
         if MyWorkDir eq ?
         then do:
            publish "PutFileLogAsunc" from mProcPublish ("Не удалось создать рабочий каталог, задание прервано." ).
            return no.
         end.
         mIniFile = " -ininame "  + GetStartupParam("-ininame") +  GetStartupParamAndCode("-pf")  .
         ConPar = substitute(ConPar, substitute ("-U &1 -P &2 ",myUser,myPass)).
         Writefile(MyWorkDir + "prof.pf", substitute('-DESCRIPTION "&2"&1 -LISTINGS .&1 -FILENAME prof.out&1 ',{&new-line},TaskName)).
         
         mFirstrun = no.
      end.
      return true.
   end.
   
   method public void AddTask (ITask    as character,
                                iProc    as character,
                                iParam   as character):
      AddTask(ITask,iProc,iParam, getnowDay()).                             
                                  
   end.
   define variable mTaskNum as int64 no-undo.
   method public void AddTask (ITask    as character,
                                iProc    as character,
                                iParam   as character,
                                iStartTimeAfter as datetime-tz):
      
      if not firstrun()
      then
         return.
      find last ttrun where ttrun.task eq itask
      no-lock no-error.
      if not available ttrun
      then do:
         if not FileExists  (MyWorkDir + itask + ".txt" )
         then do:
            if FolderExists(MyWorkDir) then do:                  
               Writefile(MyWorkDir + itask + ".txt", "InitProc " + string(getnow())).
               Writefile( getLog(itask),"").           
            end.
            else do:
               run utl\proc-msg.p ("Не удалось запустить процедуру " + iProc +  " Не найден рабочий каталог: " + MyWorkDir) no-error.
               return error.
            end.    
         end.
         else do:
            Writefile (getLog(itask),"Процедура " + iProc + "уже запущена в паралельном режиме." ).
            if valid-handle(mProcPublish)
            then
               publish "PutFileLogAsunc" from mProcPublish (MyWorkDir + itask + ".txt" ).
            
            run utl\proc-msg.p ("Процедура " + iProc +  "уже запущена в паралельном режиме." + MyWorkDir + itask) no-error.
            return error.
         end.
      end.
      
      
      mTaskNum = mTaskNum + 1 .
      writeStatusProces ("add WaitRun",itask, mtasknum, string(iStartTimeAfter) + " param " + iParam ). 
      
      iProc = right-trim(iProc,".r").
      iProc = right-trim(iProc,".p").
      define variable mProcFile as character no-undo.
      mProcFile = search (iProc + ".r").
      if mProcFile eq ?
      then 
         mProcFile = search (iProc + ".p").
      
      
      create ttrun.
      assign
         mrunnum = mrunnum + 1
         ttrun.runnum      = mrunnum
         ttrun.task        = itask
         ttrun.proc        = iproc
         ttrun.runproc     = mProcFile
         ttrun.num         = mTaskNum
         ttrun.fparam      = iParam
/*         ttrun.UserDB      = UserDB*/
         ttrun.fstatusItem = "WaitRun"
         ttrun.StartAfter  = iStartTimeAfter
      .
      assign
            ttrun.fuser = myUser
            ttrun.fpasw = myPass
         no-error.
      ttrun.cmd         = CreateComamnd(ttrun.task,ttrun.num,ttrun.Proc).
      
      for each ttrun where ttrun.task eq itask:
         ttrun.fmaxitem = mTaskNum.
      end.
      
         
   end.
   
   method private void writeStatusProces(iType as char,
                                         iTask as char,
                                         inum  as int64,
                                         iText as char):
      Writefile(MyWorkDir + itask + ".txt", substitute ( "&1 &2  task &3  Num &4 dop &5",iType,getnow(),itask,inum, iText)).                                      
   end.
   
   method public int64 AsyncProc (
      ITask    as character,
      iProc    as character,
      iParam   as character,
      iCount as int64):
      taskname = ITask.
      define variable vi as integer no-undo.

      do vi = 1 to iCount:
         AddTask (itask,iproc,iparam).
      end.
      AsyncRun().
      
            
         
   end.
   define public variable WAIT-FOR-COMPLETE as logical no-undo.
   define public variable vCountend as integer   no-undo.
  
   method public logical  WaitForfile ( input ifile as character):
      return WaitForfile(ifile,3).
   end.
   
   method public logical  WaitForfile ( input ifile as character,ipause as integer ):
      define variable mfilesize    as integer   no-undo.
      if ifile eq ? 
      then return yes.
      ifile = objExists(ifile,"F").
      if ifile ne ? 
      then do:
         file-information:file-name = ifile.
         mfilesize = file-info:file-size.
         if ipause > 0
         then
            pause ipause no-message.
         file-information:file-name = ifile.
         return mfilesize eq file-info:file-size.
      end.
      else
         return no.
   end.
      
   method public integer  WaitForOne ( input iSched as character):
     
     define variable vFile as character no-undo.
     define variable vCount as character  no-undo. 
     define variable oCount as integer no-undo. 
     define variable vtime as int  no-undo.
     AsyncRun().
     block-ttrun:
     for each ttrun where    (    iSched             ne ?
                              and ttrun.task         eq iSched
                              and ttrun.fstatusItem  eq "run")
                          or (    iSched             eq ? 
                              and ttrun.fstatusItem  eq "run")
                          or (    iSched             ne ?
                              and ttrun.task         eq iSched
                              and ttrun.fstatusItem  eq "WaitReadLog")
                          or (    iSched             eq ? 
                              and ttrun.fstatusItem  eq "WaitReadLog") 
     no-lock:

        vFile = MyWorkDir + ttrun.task + string(ttrun.num) + "/procinfo.txt".
        vtime =  (getnow() - ttrun.runtime) / 1000.
       /* message vtime view-as alert-box. */
         /* ждем 2 минуты если процес не создал файл  считаем что произошла ошибка запуска */ 
        /*vvv = vvv and not FileExists(vFile).*/
        if FileExists(vFile)
        then do:
           input STREAM sReadfile FROM  VALUE(vFile). 
           repeat:
              import stream sReadfile unformatted vCount.
              if vCount ne ""
              then do:
                 assign
                    ttrun.fpid = int(entry(1,vCount, "~001"))
                    ttrun.fmaxitem  =  int(entry(2,vCount, "~001")) 
                    ttRun.num       =  int(entry(3,vCount, "~001"))
                    ttrun.fmax      = int(entry(4,vCount, "~001"))
                    
                 no-error.
              end.
           end.
           input STREAM sReadfile close.
        end.
        else if    vtime > 120
        then do:
           vFile = MyWorkDir + ttrun.task + string(ttrun.num) + "/endproc.txt".
           if FolderExists (MyWorkDir + ttrun.task + string(ttrun.num))
           then 
              Writefile(vFile, "").
        end.
        
        PubFileLog (ttrun.task, ttrun.num, no).
          
        vFile = MyWorkDir + ttrun.task + string(ttrun.num) + "/endproc.txt".
        if FileExists(vFile)
        then do:
/*           run gbl\inidebug.p.*/
           PubFileLog (ttrun.task, ttrun.num, yes).
           define variable vFlfileWait as logical no-undo.
           define variable vi as integer no-undo.
           define variable vfileWait as character no-undo.
           
           vFile = MyWorkDir + ttrun.task + string(ttrun.num) + "/procrec.txt".
           if FileExists(vFile)
           then do:
              input STREAM sReadfile FROM  VALUE(vFile). 
              block-conut-end:
              repeat:
                 import stream sReadfile unformatted vCount.
                 if vCount ne ""
                 then do:
                    oCount = oCount +  int(vCount) no-error.
                    if not error-status:error
                    then
                       leave block-conut-end.
                 end.
              end.
              input STREAM sReadfile close.
           end.
           else do:
              vFile = MyWorkDir + ttrun.task + string(ttrun.num) + "/procrec.txt".
              if FileExists(vFile)
              then do:
                 input STREAM sReadfile FROM  VALUE(vFile).
                 block-conut: 
                 repeat:
                    import stream sReadfile unformatted vCount.
                    if vCount ne ""
                    then do:
                       oCount = oCount +  int(vCount) no-error.
                       if not error-status:error
                       then
                          leave block-conut.
                    end.
                 end.
                 input STREAM sReadfile close.
              end.
           end.
           do vi = 1 to num-entries(WaitFile):
              vfileWait = MyWorkDir + ttrun.task + string(ttrun.num) + "/" + entry(vi,waitFile).
              vFlfileWait = WaitForfile(vfileWait).
              if not vFlfileWait
              then 
                 next block-ttrun.
           end.
           vCountEnd = vCountend +   int(vCount) no-error.
           copylog(ttrun.task ,ttrun.num, ttrun.filelog).
          /* os-delete value(vFile).*/
          writeStatusProces("Change status", ttrun.task, ttrun.num, ttrun.fstatusItem + " -> " + "WorkEnd").
          if     ttrun.fstatusItem ne "WaitReadLog"
             and ttrun.fstatusItem ne "WorkEnd"
          then
             mRunProc = mRunProc - 1.
          ttrun.fstatusItem = "WorkEnd".
          
          
          
        end. 
        else do:
           vFile = MyWorkDir + ttrun.task + string(ttrun.num) + "/procstatus.txt".
           if FileExists(vFile)
           then do:
              define variable vtext as longchar no-undo.
              copy-lob from file vFile to vtext no-error.
              if error-status:error
              then do:
/*                  run write-to-log (substitute ("Не удалось прочесть файл &1",iFile)).*/
              end.
              else do:
                 vtext = replace (vtext,{&carriage-return} + {&new-line},{&new-line}).
                 if length(vtext) < 32000
                 then
                    ttrun.fstatus = vtext.
                 else
                    ttrun.fstatus = substring (vtext,1,32000).
              end.
            end.
        end.       
     end.
     
     AsyncRun().
     define variable vnow as datetime-tz no-undo.
     vnow = getnow().
     find first ttrun where    (ttrun.task eq iSched
                             or iSched eq ? )
                             and ttrun.fstatusItem ne "WorkEnd"
                             and ttrun.fstatusItem ne "WorkEndAvailDir"
                             and ttRun.StartAfter <= vnow 
     no-lock no-error.
     WAIT-FOR-COMPLETE = not available ttrun.
     
     find first ttrun where    (ttrun.task eq iSched
                             or iSched eq ? )
                             and ttrun.fstatusItem eq "WaitRun"
     
     no-lock no-error.
     WAIT-FOR-RUN = available ttrun.
       
     define buffer buf_run for ttrun.
        
     find first buf_run where buf_run.task > "" no-lock no-error.
     do while available buf_run:
       define variable vtask as character no-undo.
       vtask = buf_run.task.
       find first ttrun where ttrun.task        eq vtask
                          and ttrun.fstatusItem ne "WorkEnd"
                          and ttrun.fstatusItem ne "WorkEndAvailDir"
       no-lock no-error.
       if not available ttrun
       then do:
          find first ttrun where ttrun.task        eq vtask
                             and ttrun.fstatusItem eq "WorkEnd"
          no-error.
          do while available ttrun:
             if not SaveFile
             then do:
/*                os-delete value (MyWorkDir + vtask + string(ttrun.num)) recursive.*/
                os-delete value (MyWorkDir + vtask + string(ttrun.num) + ".bat").
             end.
             writeStatusProces("Delete", ttrun.task, ttrun.num,  "WorkEnd").
             ttrun.fstatusItem = "WorkEndAvailDir".
/*             delete ttrun.*/
             find first ttrun where ttrun.task        eq vtask
                                and ttrun.fstatusItem eq "WorkEnd"
             no-lock no-error.
          end.
          os-delete  value( MyWorkDir + vtask + "/stop.txt") .
          os-delete  value( MyWorkDir + vtask + ".txt") .
          if not FileExists (MyWorkDir + vtask + ".txt")
          then
             publish "EndTaskAsunc" from mProcPublish (vtask ).
           
        end.
        find first buf_run where buf_run.task > vtask no-lock no-error.
     end.
     return oCount.     
   end.
     
   method public void PubFileLog (iproc as character , iprocnum as integer, iendProc as logical):
      define variable vfile as character no-undo.
      define variable vStr as character no-undo.
      define buffer ttrun for ttrun.
      
      find first ttrun where ttrun.task eq iproc
                         and ttrun.num eq iprocnum
      no-error.
      if available ttrun
      then do:
         if WritelogInter > 0
            or iendProc
         then do:
      
            vFile = MyWorkDir + ttrun.task + string(ttrun.num) + "/meslogasync.log" + string(ttrun.Filelog + 1).
            do while FileExists(vFile):
                 if valid-handle(mProcPublish)
                 then
                    publish "PutFileLogAsunc" from mProcPublish (vFile ).
                 ttrun.Filelog = ttrun.Filelog + 1.
                 vFile = MyWorkDir + ttrun.task + string(ttrun.num) + "/meslogasync.log" + string(ttrun.Filelog + 1).
            end.
         end.
         if iendProc
         then do:
            if FileExists(MyWorkDir + ttrun.task + string(ttrun.num) + "/errorasync.log")
            then do:
               output stream sWriteFile to value (MyWorkDir + ttrun.task + string(ttrun.num) + "/errorasynctime.log").
               input STREAM sReadfile FROM  VALUE(MyWorkDir + ttrun.task + string(ttrun.num) + "/errorasync.log").
               repeat:
                  import stream sReadfile unformatted vStr.
                  if     vStr ne ""
                     and (   PrintAll
                          or not can-do(
"arj*,~
Registered*,~
Long filename*,~
Creating archive*,Adding  *,~
     1 file(s)*,~
Processing archive*,~
Archive created*,~
Extracting*,~
7-Zip*,~
Everything is Ok,~
Files:*,~
Size:*,~
Compressed:*,~
Scanning,~
Compressing *,~
*Load Data Definitions,~
*Loading Definitions.  Press CTRL-BREAK to terminate load process.,~
      DatTable:*,~
         Index:*,~
      Sequence:*,~
Phase 1 of Load completed.  Working.  Please wait ...~
",vStr)
                          )
                          
                  then 
                     put stream sWriteFile unformatted substitute ("&1 &2",mAsyncProc:getnow(), vStr) skip.
               end.
               input stream sReadfile close.
               output stream sWriteFile close.
               publish "PutFileLogAsunc" from mProcPublish (MyWorkDir + ttrun.task + string(ttrun.num) + "/errorasynctime.log" ).
            end.
            
         end.
      end.
   end.
   
   method public character  getLog (iSched as character):
      if iSched eq ?
      then 
         iSched = taskname.
       return MyWorkDir + iSched + "meslogasync.log".
   end.
   
   method public character  getProcDir (iSched as character):
      if iSched eq ?
      then 
         iSched = taskname.
       return MyWorkDir + iSched .
   end.
   
   method public logical copylog ( input iSched as character,input iItem as integer, input ilogFile as integer  ):
      if iSched eq ?
      then 
         iSched = taskname.
      define variable vStr as character no-undo.
      define variable vlogMan as character no-undo.
      output stream sWriteFile to value (getLog(iSched)) append.
      define variable vi as integer no-undo.
      do vi = 1 to ilogFile:
         vlogMan = "".
         if FileExists(MyWorkDir + iSched + string (iItem) + "/meslogasync.log" + string(vi))
            then 
         do:
            input STREAM sReadfile FROM  VALUE(MyWorkDir + iSched + string (iItem) + "/meslogasync.log" + string(vi)).
            repeat:
               import stream sReadfile unformatted vStr.
               put stream sWriteFile unformatted vStr skip.
            end.
            input stream sReadfile close.
         end.
         
      end.
      define variable vindex as integer no-undo.
      if FileExists(MyWorkDir + iSched + string (iItem) + "/errorasynctime.log")
         then 
      do:
         input STREAM sReadfile FROM  VALUE(MyWorkDir + iSched + string (iItem) + "/errorasynctime.log").
         repeat:
            import stream sReadfile unformatted vStr.
            vindex = index (vstr,"{&errstoptext}").
            if vindex > 0 
            then do:
               vlogMan = substring(vstr,vindex + length ("{&errstoptext}") ).
            end. 
            put stream sWriteFile unformatted vStr skip.
         end.
         input stream sReadfile close.
         if FileExists(vlogMan)
            then 
         do:
            publish "PutFileLogAsunc" from mProcPublish (vlogMan).
            input STREAM sReadfile FROM  VALUE(vlogMan).
            repeat:
               import stream sReadfile unformatted vStr.
               put stream sWriteFile unformatted vStr skip.
            end.
            input stream sReadfile close.
         end.
      end.
      output stream sWriteFile close.
   end. 
   define public variable mStop as logical no-undo. 
   
  /* method public logical WaitFor ( input ipInterval as int64):
      for each ttrun
         breack by ttrun.task:
         if frist-of(ttrun.task)
         then do:
            WaitFor()
   */
    
   method public logical WaitFor ( input iSched as character, input ipInterval as int64):
      /* if iSched eq ?
      then 
         iSched = taskname. */
       define variable vCountOld as integer init -1 no-undo.
       define variable vCount as integer no-undo.
       define variable vOK as logical no-undo initial true.
       
/*      output stream sWriteFile to value (getLog(iSched) ).*/
      define variable vStart  as datetime-tz no-undo.
      vStart = getnow().
/*      output stream sWriteFile close.*/
       vCountend = 0. 
       WAIT-FOR-COMPLETE = false.      /* на всякий случай */
       mstop = no.
       
       if FolderExists(MyWorkDir) then       
          Writefile(MyWorkDir + "Stop.txt", "").
       
       do while not WAIT-FOR-COMPLETE:
          
          WAIT-FOR-COMPLETE = true.
          vCount = vCountEnd + WaitForOne(iSched) .
          if (not WAIT-FOR-COMPLETE 
           and not FileExists(MyWorkDir + "Stop.txt")
           or (    myTimeOut    ne 0
               and myTimeOut    ne ?
               and iSched       ne ?
               and vCountOld    = vCount
               and dec(getnow() - vStart) / 1000 > myTimeOut
              )) or mstop
          then do:
             if WaitForStop (iSched)
             then do:
                mstop = no.
                vOK = false.
                WAIT-FOR-COMPLETE = true. /* процес завис */
             end.
          end.   
          else
             vCountOld = vCount.
          if not WAIT-FOR-COMPLETE
          then
             AsyncRunpause(ipInterval).
       end. 
       return vOK.
   end method.
   
   method public logical SendStop ( input iSched as character):
      for each ttrun where    ttrun.task eq iSched
                              or iSched eq ? 
      no-lock:
         os-delete value (MyWorkDir + ttrun.task + string(ttrun.num) + "/stop.txt") recursive. /* Пытаемся остановить процес*/ 
         
      end.
   end.
   
   method public logical DelShedDirEndProc ( input iSched as character):
      find first ttrun where    ttrun.fstatusItem eq "WorkEndAvailDir"
                               and (   ttrun.task eq iSched
                                    or iSched eq ?) 
      no-lock no-error.
      do while available ttrun:
         os-delete value (MyWorkDir + ttrun.task + string(ttrun.num)) recursive.
         delete ttrun.
         find first ttrun where    ttrun.fstatusItem eq "WorkEndAvailDir"
                               and (   ttrun.task eq iSched
                                    or iSched eq ?) 
         no-lock no-error.
      end.
   end.
   
   method public logical WaitStopEnd ( input iSched as character):
      return WaitStopEnd(iSched,3).
   end.
   
   method public logical WaitStopEnd ( input iSched as character,ipause as integer ):
      define variable vfile as character no-undo.
      define variable vi as integer no-undo.
      define variable vfileWait as character no-undo.
      define variable vFlfileWait as logical no-undo.
      define variable vOk as logical no-undo init true.
      for each ttrun where    ttrun.task eq iSched
                           or iSched eq ? 
      no-lock:
         vFile = MyWorkDir + ttrun.task + string(ttrun.num) + "/endproc.txt".
         if FileExists(vFile)
         then do:
/*            do vi = 1 to num-entries(WaitFile):                                                                   */
/*              vfileWait = MyWorkDir + ttrun.task + string(ttrun.num) + "/" + entry(vi,waitFile).                  */
/*              vFlfileWait = WaitForfile(vfileWait,ipause).                                                        */
/*              if not vFlfileWait                                                                                  */
/*              then                                                                                                */
/*                 return no.                                                                                       */
/*            end.                                                                                                  */
            writeStatusProces("Change status", ttrun.task, ttrun.num, ttrun.fstatusItem + " -> " + "WaitReadLog").
            if     ttrun.fstatusItem ne "WaitReadLog"
               and ttrun.fstatusItem ne "WorkEnd"
            then
               mRunProc = mRunProc - 1.
            ttrun.fstatusItem = "WaitReadLog".
            
         end.
         else do:
            vOk = no.
         end.
      end.
      return vOk.
   end.
   
   method public logical EndStopEnd ( input iSched as character):
      define variable vtask as character no-undo.
      define variable vFile as character no-undo.
      for each ttrun where    ttrun.task eq iSched
                           or iSched eq ? 
      no-lock break by ttrun.task:
         vFile = MyWorkDir + ttrun.task + string(ttrun.num) + "/endproc.txt".
         if not FileExists(vFile)
         then do:
            if termprc(MyWorkDir,ttrun.task , ttrun.num, ttRun.fpid)
            then do:
               writeStatusProces("Change status", ttrun.task, ttrun.num, ttrun.fstatusItem + " -> " + "WaitReadLog").
               if     ttrun.fstatusItem ne "WaitReadLog"
                  and ttrun.fstatusItem ne "WorkEnd"
               then
                  mRunProc = mRunProc - 1.
               ttrun.fstatusItem = "WaitReadLog".
               
            end.
         end.
         PubFileLog(ttrun.task, ttrun.num, yes).
               
         if not SaveFile
         then
            os-delete value (MyWorkDir + ttrun.task + string(ttrun.num)) recursive. /* удаляем директории процесов */ 
         os-delete   value(MyWorkDir + ttrun.task + string(ttrun.num) + ".bat").
         vtask = if last-of(ttrun.task) then ttrun.task else "".
         delete ttrun.
         if vtask ne ""
         then do:
            os-delete value (MyWorkDir + vtask + ".txt") recursive.
            if not FileExists (MyWorkDir + vtask + ".txt")
            then
               publish "EndTaskAsunc" from mProcPublish (vtask ).
            
         end.
      end.
      os-delete value (MyWorkDir + iSched + ".txt") recursive.
   end.
   
   method public logical WaitForStop ( input iSched as character):
     /* if iSched eq ?
      then 
         iSched = taskname. */
      
      sendStop (iSched).
      
      /*message "Процес " iSched "подвис. Процесы будут прерваны."
      view-as alert-box.*/
      /* ждем чтобы процесы успели остановиться*/
      pause 3 no-message.
      
      WaitStopEnd(iSched).
      
      EndStopEnd (iSched).
      
      return yes.
end.

/*define public event MyPause   /*10 прогрес не поддерживает публикацию событий */
    signature void ( input pcInterval as int64 ).*/ 
   method public void AsyncRunpause (input iInterval as int64):
     define variable vStart  as datetime-tz no-undo.
     define variable vend    as datetime-tz no-undo.
     define variable vint as int64 no-undo.
     
     vStart = getnow().
     vend   = vStart.
     if valid-handle(mProcPublish)
     then
        publish "MyPause" from mProcPublish (iInterval ).
    /* MyPause:PUBLISH .*/
     vend   =  getnow().
     vint = vend - vStart.
     vint = iInterval - vint / 1000.
     if not mStop
        and vint > 0
     then
        pause vint no-message. 
         
    /* do while vint / 1000   < iInterval:
        
       vend   =  now.
       vint = vend - vStart.
       
     end. */
     
   end.
   method private character  CreateComamnd (
      iSched     as character,
      iSchedNum  as integer ,
      iProc      as character
     ):
      define variable v-cmd-comm  as character no-undo.
      define variable isRcode  as logical no-undo.
      define variable mProcFile as character no-undo.
      define variable mAsuncProc as character no-undo.
      mProcFile = search (iProc + ".r").
      if mProcFile <> ?
      then 
         isRcode = true.
      else 
         mProcFile = search (iProc + ".p").
      
      mAsuncProc = "utl\proc-async".
      if ChangProPath
      then
         mAsuncProc = mAsuncProc + "-propath".
      if isRcode
      then
         mAsuncProc = mAsuncProc + ".r".
      else
         mAsuncProc = mAsuncProc + ".p".
      mAsuncProc = search(mAsuncProc).
      if MyParamStart ne ""
      then 
         mIniFile = MyParamStart.
      define variable vSesPar as character no-undo.
     /* define variable vUserPas as character no-undo.
      vUserPas = user-passwd. /* получем пользователя так как в этт момент может переопределиться парамтр подключения */
      if    UserDB 
         or vUserPas eq ""
         or vUserPas eq ""
      then
         vSesPar =  substitute(" &1 ",                mProcFile, paramSession).
      else */
         if lookup("-debugalert", paramSession, " ") eq 0
         then
            paramSession = paramSession + " " + GetStartupParamEx("-debugalert").
         vSesPar =  substitute(" &1",paramSession).
      /* if UserDB
      then
         v-cmd-comm = substitute ("&1 &2  &3  -p &4 &5 &6", m-prowin32FileName, if MyBachMode then "-b" else "", mIniFile, mAsuncProc,vSesPar, conpar).
      else */ 
         v-cmd-comm = substitute ("&1 &2  &3  -p &4 &5",    m-prowin32FileName, if MyBachMode then "-b" else "", mIniFile, mAsuncProc,vsespar).
      return v-cmd-comm.
   end.
   
   method public int64 AsyncRun ():
      define buffer ttrun for ttrun.
      define variable vFile as character no-undo.
      
      for each ttrun where ttrun.fstatusItem eq "Run":
         vFile = MyWorkDir + ttrun.task + string(ttrun.num) + "/endproc.txt".
         if FileExists(vFile)
         then do:
            writeStatusProces("Change status", ttrun.task, ttrun.num, ttrun.fstatusItem + " -> " + "WaitReadLog").
            if     ttrun.fstatusItem ne "WaitReadLog"
               and ttrun.fstatusItem ne "WorkEnd"
            then
               mRunProc = mRunProc - 1.
            
            ttrun.fstatusItem = "WaitReadLog".
            
         end. 
      end.
      block-run:
      for each ttrun where ttrun.fstatusItem eq "WaitRun":
         if mRunProc >= maxproc
         then
            leave block-run.
         AsyncRun(ttrun.task, ttrun.num).
      end.
   end.
   
   method private void AsyncRun (
      iSched     as character,
      iSchedNum  as integer
     ):
      define variable vtask as character no-undo.
      define variable vi as integer no-undo.
      define buffer ttrun for ttrun.
      define variable vnow as datetime-tz no-undo.
      vnow = getnow().
      find first ttrun where ttrun.task eq iSched 
                         and ttrun.num  eq iSchednum
                         and ttrun.StartAfter <= vnow
      no-lock no-error.
      if available ttrun
      then do:
         vtask = iSched + string (iSchednum).
         os-delete value (MyWorkDir + vTask) recursive.
         if not  FolderExists  ( MyWorkDir + vTask) 
         then do:
            os-create-dir VALUE(MyWorkDir + vTask ).
            if not  FolderExists  ( MyWorkDir + vTask)
            then
               return.
         end.
         os-copy value(MyWorkDir + "assemblies.xml" )
                 value(MyWorkDir + vTask + v-path-tls-dir-delim + "assemblies.xml").  
            mAsyncProc:SavePARAM(?,?).
            mAsyncProc:SavePARAM("numSession",string(ttrun.num)).
            mAsyncProc:SavePARAM("countSession",string(ttrun.fmaxitem)).
            mAsyncProc:SavePARAM("procedure",ttrun.runproc).
               
/*            SavePARAM("UserDB",string(ttrun.UserDB)).*/
            mAsyncProc:SavePARAM("WritelogInter",string(WritelogInter)).
            /*if not ttrun.UserDB
            then do:*/
               mAsyncProc:SavePARAM("user",ttrun.fuser).
               mAsyncProc:SavePARAM("password",ttrun.fpasw).
               mAsyncProc:SavePARAM("DbConnect",string(DbConnect)).
               if SetGblPar ne ?
               then
                  mAsyncProc:SavePARAM("SetGblPar",string(SetGblPar)).
               
               
               
               
/*            end.*/
            do vi = 1 to num-entries(ttrun.fParam, {&delim-par} ):
               mAsyncProc:SavePARAM("ParamProc_" + string(vi),entry(vi,ttrun.fParam, {&delim-par} )).
            end.
            mAsyncProc:SavefilePARAM(MyWorkDir + vTask + v-path-tls-dir-delim + "param.txt").
            Writefile(MyWorkDir + vTask + v-path-tls-dir-delim + "propath.txt", propath).
            os-delete value(MyWorkDir + vTask + v-path-tls-dir-delim +  "meslogasync.log").
            Writefile(MyWorkDir + vTask + v-path-tls-dir-delim +  "meslogasync.log", "error Ошибка запуска сессии.").
            if FolderExists(MyWorkDir + vTask) then            
               Writefile(MyWorkDir + vTask + v-path-tls-dir-delim + "stop.txt","").       
            else return.
               
         define variable vruncomand as character no-undo.
         vruncomand =  vtask + " & " + ttrun.cmd + " & copy /y param.txt endproc.txt & del /F stop.txt & exit".
         define variable isRcode as logical no-undo.
         isRcode = search ("cmp\vertag.enc") ne ?.
         if ( not isRcode or session:debug-alert ) 
   /*       and not UserDB */
         then do:
            Writefile(MyWorkDir + vtask + ".bat", "cd " + replace (vruncomand,"&","~n":U)).
         end.
         vruncomand =  "cd " + MyWorkDir + vruncomand.
         os-command no-wait value (vruncomand  ).
         writeStatusProces("Change status", ttrun.task, ttrun.num, ttrun.fstatusItem + " -> " + "Run").
         ttrun.fstatusItem = "Run".
         ttrun.runtime     = getnow().
         mRunProc = mRunProc + 1.
      end.
   end.
   
   method public void delworkdir():
      if MyWorkDir ne ""
      then
      os-delete   value(trim(MyWorkDir,v-path-tls-dir-delim )) RECURSIVE.
     
   end method.    
   
   method public character GetStartupParamAndCode (input iParam as character  ):
      def var vText as char no-undo.
      vText = GetStartupParam ( iParam).
      if vText eq ?
      then
         return "".
      else
         return " " + iParam + " " + vText.
   end.
   
   method public character GetStartupParamEx (input iParam as character  ):
      define variable vText as character no-undo.
      vtext = GetStartupParam(iParam).
      if vtext ne ?
      then
         return iParam + " " + vtext.
      else
         return "".
   end.
   
   method public character GetStartupParam (input iParam as character  ):
      
   define variable vStartupParameters as character no-undo.
   vStartupParameters = session:startup-parameters.
   define variable vNumStartupParameters as integer no-undo.
   define variable vList as character no-undo init ?.
         
   vNumStartupParameters = num-entries( vStartupParameters ).

   define variable i as integer no-undo.
      block-par:
   do i = 1 to vNumStartupParameters:
      define variable vParameter as character no-undo.
      vParameter = entry( i, vStartupParameters ).
      if vParameter begins iParam then
      do:
         vList  = "".
         vList  = entry(2,vParameter,' ') no-error.
        /* vList  = vList + " " +  vParameter.*/
        /* leave block-par.*/
      end.
   end.
      return vList.
   end method. 
    
                                            
     
   
/*********************************************** beg procView *********************************************************/
   
  method public void  creatTTForProc (input iDir as char ):
   define var vPureName  as char    no-undo.
   define var vFullPath  as char    no-undo.
   define var vFileType  as char    no-undo.
   
   repeat preselect each ttfile:
       find next ttfile.
         delete ttfile.
      end.   
   repeat preselect each ttfilelist:
       find next ttfilelist.
         delete ttfilelist.
   end.
  for each ttrun:
      ttrun.favail = no. 
  end.    
   iDir = trim(idir,v-path-tls-dir-delim).
   
   input STREAM sReadDir FROM os-dir(iDir).
   repeat:
      import stream sReadDir vPureName vFullPath vFileType.
      if vPureName begins  "."   then next.
      if vFileType =  "d" then do:
         
         create ttfile.
         assign
            ttfile.fnAME       = vPureName
            ttfile.fullpach    = iDir
            
            ttfile.fulllocalpach = trim(ttfile.localPach + v-path-tls-dir-delim + ttfile.fnAME,v-path-tls-dir-delim)
            ttfile.fLevel      = num-entries(ttfile.fulllocalpach,v-path-tls-dir-delim) 
            .
      end.
      else if     vFileType =  "F"
              and can-do ("txt",entry(num-entries(vPureName,"."),vPureName,"."))
      then do:
         create ttfilelist.
         assign
         ttfilelist.fnAME         = vPureName
         ttfilelist.fullpach      = iDir
         ttfilelist.fulllocalpach = trim(ttfilelist.localPach + v-path-tls-dir-delim + ttfilelist.fnAME,v-path-tls-dir-delim)
         ttfilelist.fLevel        = num-entries(ttfilelist.fulllocalpach,v-path-tls-dir-delim) 
            .
      end.   
   end.   
   
    
   input STREAM sReadfile close.
   define variable vProc   as character no-undo.
   define variable vLength as integer no-undo.
   define variable vDir    as character no-undo.
   define variable vFile   as character no-undo.
   define variable vCount  as character no-undo.
   for each ttfilelist:
      assign
         vProc = entry(1,ttfilelist.fnAME,".")
         vLength = length (vProc)
      .
      for each ttfile where ttfile.fnAME  begins vProc:
         vdir = ttfile.fullpach + v-path-tls-dir-delim + ttfile.fnAME + v-path-tls-dir-delim.
         find first ttrun where ttrun.task = vProc
                            and ttRun.num  = int(substring(ttfile.fnAME,vLength + 1 ))
                            no-error.
         vFile = vdir + "endproc.txt".
         if not FileExists(vFile)
         then do:
            if not available ttrun
            then do:
                create ttRun.
                assign
                   ttrun.task = vProc
                   ttRun.num  = int(substring(ttfile.fnAME,vLength + 1)) 
                 no-error.
            end.
            ttRun.favail = yes.
            vFile = vdir + "procinfo.txt".
            if FileExists(vFile)
            then do:
               input STREAM sReadfile FROM  VALUE(vFile). 
               repeat:
                  import stream sReadfile unformatted vCount.
                  if vCount ne ""
                  then do:
                     assign
                        ttrun.fpid = int(entry(1,vCount, "~001"))
                        ttrun.fmaxitem  =  int(entry(2,vCount, "~001")) 
                        ttRun.num       =  int(entry(3,vCount, "~001"))
                        ttrun.fmax      = int(entry(4,vCount, "~001"))
                     no-error.
                  end.
               end.
               input STREAM sReadfile close. 
            end.
         
             vFile = vdir + "procrec.txt".
             if FileExists(vFile)
             then do:
               input STREAM sReadfile FROM  VALUE(vFile). 
               repeat:
                  import stream sReadfile unformatted vCount.
                  if vCount ne ""
                  then do:
                     assign
                        ttrun.olditem = ttrun.item
                        ttrun.item =  int(vCount) 
                     no-error.
                  end.
               end.
               input STREAM sReadfile close.
            end.
            vFile = vdir + "procstatus.txt".
             if FileExists(vFile)
             then do:
               define variable vtext as longchar no-undo.
               copy-lob from file vFile to vtext no-error.
               if error-status:error
               then do:
/*                  run write-to-log (substitute ("Не удалось прочесть файл &1",iFile)).*/
               end.
               else do:
                  vtext = replace (vtext,{&carriage-return} + {&new-line},{&new-line}).
                  if length(vtext) < 32000
                  then
                     ttrun.fstatus = vtext.
                  else
                     ttrun.fstatus = substring (vtext,1,32000).
               end.
            end.
            
         end.
         else do:
             if available ttrun
             then 
                delete ttrun.
         end.
      end.     
   end.    
   repeat preselect each ttrun where ttrun.favail = no:
       find next ttrun .
         delete ttrun .
   end.  
end method.

method public handle  getqueryttrun():
    define variable hQuery   as handle  no-undo .
              
    create query hQuery.    
    
    hQuery:set-buffers(buffer ttrun:HANDLE). 
    hQuery:query-prepare("FOR EACH ttrun").
       
    hQuery:query-open.
    return hQuery.
end.

method public void  Stopprc(input iDir as char ):
    if avail ttrun
    then
       Stopprc(iDir,ttrun.task,ttrun.num).
end.

method public void  Stopprc(input iDir as character,iProc as character,iNum as integer ):
   os-delete value(substitute("&1\&2&3\stop.txt",iDir,iProc,if iNum  ne 0 then string(iNum) else "")) .
end.    
    
method public void  termprc(input iDir as char ):
   if avail ttrun
   then 
      termprc(iDir,ttrun.task,ttrun.num).
end.
    
method public void  termprc(input iDir as character,iProc as character,iNum as integer ):
   if avail ttrun
   then do:
      termprc(iDir, iProc, iNum, ttrun.fpid).
   end.       
end.    

method public logical  termprc(input iDir as character,iProc as character,iNum as integer, iPid as integer ):
   define variable vOk as logical no-undo.
   define variable vdir as character no-undo.
   vdir = substitute("&1\&2&3",iDir,iProc,if iNum  ne 0 then string(iNum) else "").
   if termprc(iPid)
   then do:
      vOk = true.
      if FolderExists (vdir)
      then do:
         Writefile(substitute("&1\endproc.txt",vdir ), "").
      end.
   end.
   if iPid eq 0
   then
   do:
      if FolderExists (vdir)
      then do:
         Writefile(substitute("&1\endproc.txt",vdir ), "").
      end.
   end.
   return vOk.       
end.    
 
method public logical  termprc(iPid as integer):
   define variable vOk as logical no-undo.
   if iPid > 0 then do:
      run gbl/termprc.p
          ( input iPid
          ) no-error .
      if error-status :error 
      then do:
         message
            substitute( "Ошибка при остановке сессии : &1", iPid ) skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          
      end.
      else
         vok = true.
   end.
   return vOk.    
end. 
/*********************************************** End procView *********************************************************/
   
   
   method public logical isWorkShed():
      return isWorkShed(?).
   end.
   
   method public logical isWorkShed(iSched as character ):
      define variable vnow as datetime-tz no-undo.
      vnow = getnow().
      find first ttRun where ttrun.fstatusItem ne "WorkEnd"
                         and ttrun.fstatusItem ne "WorkEndAvailDir"
                         and ttRun.StartAfter  <= vnow
                         and (   ttRun.task        eq iSched
                              or iSched            eq ?)
      no-lock no-error.
      return available ttRun.
   end.
   
   method public character getListWorkShed():
      return getListWorkShed(?).
   end.
   
   method public character getListWorkShed(iSched as character ):
      define variable vnow as datetime-tz no-undo.
      define variable vList as character no-undo.
      vnow = getnow().
      for each ttRun where ttrun.fstatusItem ne "WorkEnd"
                       and ttrun.fstatusItem ne "WorkEndAvailDir"
                       and ttRun.StartAfter  <= vnow
                       and (   ttRun.task        eq iSched
                            or iSched            eq ?)
      no-lock:
         vList = vList + "," + string(ttrun.num) + ". " + ttrun.task.
      end.
      if vList ne ""
      then
         vList = substring (vList,2). 
      return vList.
   end.
   
   method public character getListTask ():
      define variable vList as character no-undo.
      define variable vTask as character no-undo.
      find first ttRun where ttRun.task > ""
      no-lock no-error.
      do while available ttRun:
         vtask = ttRun.task.
         vlist = vlist + "," + vtask.
         find first ttRun where ttRun.task > vtask
         no-lock no-error.
      end.
      if vlist ne ""
      then
         vlist = substring (vList,2).
      return vList.
   end.
   
   method public char getStatus (iSched as character  ):
      define buffer ttrun for ttrun.
      define buffer buf_ttrun for ttrun.
      if iSched eq ?
      then do:
         find first ttrun no-error.
         find first buf_ttrun where buf_ttrun.task ne ttrun.task no-error.
         define variable vmanyproc as logical no-undo.
         vmanyproc = available buf_ttrun.
      end.
         
      define variable vStat as character no-undo.
      define variable vAvialTask as logical no-undo.
      for each ttrun where    (    iSched            ne ?
                              and ttrun.task         eq iSched
                              and ttrun.fstatusItem  eq "run")
                          or (    iSched             eq ? 
                              and ttrun.fstatusItem  eq "run") 
      no-lock:
     
         vAvialTask = yes.
         if ttrun.fstatus ne "" and ttrun.fstatus ne ?
         then
            vStat = vStat + " "
                          + (if vmanyproc       then ttrun.task + (if ttrun.fmax ne 1 then "_" else ": ") else "")   
                          + (if ttrun.fmax ne 1 then string(ttrun.num) + ": " else "") 
                          + ttrun.fstatus no-error.
      end.
      if not vAvialTask
      then do:
         if iSched ne ?
         then do:
            find first buf_ttrun where    buf_ttrun.task        eq iSched 
                                      and buf_ttrun.fstatusItem eq "waitrun"
            no-error.
            
            vStat = if available buf_ttrun then "Процесс ожидает запуска." else "Процесс был завершен." + iSched.
            define variable vi as integer no-undo.
            for each ttrun where ttrun.fstatusItem eq "run"
            no-lock:
               vi = vi + 1.
            end.
            vStat = substitute (" &1 Выполняется &2 процессов.",vStat,vi).
            
            vi = 0.
            for each ttrun where ttrun.fstatusItem eq "WaitRun"
                             and ttrun.runnum < buf_ttrun.runnum
            no-lock:
               vi = vi + 1.
            end.
            vStat = substitute (" &1 Ожидает выполнения &2 до этого процесса.",vStat,vi).
         end.
      end.
      return vStat.
   end method.
   
    
   
   

   /*method public logical NextLog():
      nextLog(no).
   end.
   method public logical NextLog(iFlagInter as logical):
      mAsyncProc:NextLog(iFlagInter).
   end.
   
   method public logical NextLog(iFile as char):
      mAsyncProc:NextLog(iFlagInter).
   end.
   
   method public logical EndRec():
      output stream sLogMes close.
      mWriteLogNum = mWriteLogNum + 1.
      os-delete             value ("meslogasync.log" + string(mWriteLogNum)).
      define variable vfile as character no-undo.
      vfile = search ("meslogasync.log").
/*      os-command value (substitute ("rename &1 &1&2",vfile,  string(mWriteLogNum))).*/
      os-rename value(vfile) value ("meslogasync.log" + string(mWriteLogNum)).
      if     ErrorProc 
         and log-manager:logfile-name ne ?
      then do:
      
      mWriteLogNum = mWriteLogNum + 1.
      os-delete             value ("meslogasync.log" + string(mWriteLogNum)).
      vfile = search (log-manager:logfile-name).
/*      os-command value (substitute ("rename &1 &1&2",vfile,  string(mWriteLogNum))).*/
      os-command value (substitute ("copy &1 meslogasync.log&2 > copy.log &3 Exit",vFile,string(mWriteLogNum),{&ampersand}) ).
      end.
   end.
   
   method public logical CheckStop ():
      NextLog().
      return not FileExists("stop.txt").
   end. 
   
   method public logical CheckParam ():
      return FileExists("param.txt").
   end. 
   
*/
/*************************************************/

define variable v-waitfram-action01         as character no-undo .
define variable v-waitfram-action02         as character no-undo .
define variable v-waitfram-action03         as character no-undo .
define variable v-waitfram-prev-left-margin as integer   no-undo init 0 .
define variable mText                       as character no-undo.
define button B-stop auto-end-key
     label "Стоп"
     size 10 by 1 tooltip "Остоновить процесс".
define button B-viewProcInfo
     label "Информация"
     size 15 by 1 tooltip "Информация о процесс".


define frame waitfram
  v-waitfram-action01 format "x(72)" no-label skip
  v-waitfram-action02 format "x(72)" no-label skip
  v-waitfram-action03 format "x(72)" no-label skip
  B-viewProcInfo 
  B-stop at row 4 col 30
  with view-as dialog-box side-labels three-d cancel-button b-stop
  .
on choose of B-stop in frame waitfram /* Добавить в АМ */
do:
  mStop = yes.
  
end.

on choose of B-viewProcInfo in frame waitfram /* Добавить в АМ */
do:
  run ref/runprocview.p (MyWorkDir,MyWorkDir).
end.
  
method private void waitfram-hide () :

  do
  on error undo, return error return-value
  :
    pause 0 before-hide .
    hide frame waitfram .

/*&if "{1}" = "" &then
    process events .
&endif*/
  end.

end method. /* waitfram-hide */
define public variable MstarstProc as datetime-tz no-undo.
method public void waitfram-show (input iInterval as int64  ):
   define variable vtime as int64 no-undo.
   vtime = ( getnow() - MstarstProc ) / 1000 .
   waitfram-show(substitute("&1 Прошло: &2 сек" ,mText , string( vtime)), iInterval).
   
end method.
   
method private void waitfram-show (input p-message as character,input iInterval as int64  ):

  

  define variable v-left-margin as integer   no-undo .

  do
  on error undo, return error return-value
  :
    if length(p-message) <= 70 then do:
      assign
        v-left-margin = integer((70 - length(p-message)) / 2)
      .
      assign
        v-left-margin = max(0, v-left-margin - (v-left-margin mod 5))
      .
      if abs(v-left-margin - v-waitfram-prev-left-margin) > 5 then do:
        assign
          v-waitfram-prev-left-margin = v-left-margin
        .
      end.

      assign
        v-waitfram-action01 = " "
        v-waitfram-action02 = " "
                                 + fill(" ", v-waitfram-prev-left-margin)
                                 + p-message
        v-waitfram-action03 = " "
      .
    end.
    else do:
      if length(p-message) <= 140 then do:
        assign
          v-waitfram-action01 = " "
          v-waitfram-action02 = " " + substring(p-message,   1, 70)
          v-waitfram-action03 = " " + substring(p-message,  71, 70)
        .
      end.
      else do:
        assign
          v-waitfram-action01 = " " + substring(p-message,   1, 70)
          v-waitfram-action02 = " " + substring(p-message,  71, 70)
          v-waitfram-action03 = " " + substring(p-message, 141, 70)
        .
      end.
    end.
    B-viewProcInfo:visible in frame waitfram = session:debug-alert.
    B-viewProcInfo:sensitive in frame waitfram = session:debug-alert.
    display
      v-waitfram-action01 skip
      v-waitfram-action02 skip
      v-waitfram-action03 skip
      with frame waitfram .
      
      
    B-stop:sensitive   in frame waitfram = yes.   
/*&if "{1}" = "" &then
    process events .
&endif
*/
     wait-for go of frame waitfram pause iInterval.
  end.

end method. /* waitfram-show */

method public logical WaitFor ( input iSched as character, input ipInterval as int64,input itext as character ):
 define variable vFlag as logical no-undo.
  mText = itext.
  MstarstProc = getnow().
  /*if not session:batch-mode
     this-object:MyPause:Subscribe(this-object:waitfram-show).*/
     mShowFrame = yes.
  vFlag = WaitFor(iSched,ipInterval).
  return vFlag.
    
  finally:
     mtext = "".
     waitfram-hide().
     mShowFrame = no.
     /*if not session:batch-mode
     then
        this-object:MyPause:Unsubscribe(this-object:waitfram-show).*/
  end finally.
  end.
  
  method public void setTimeOutTask(iTask as character, iTimeOut as integer ):
     find first ttTimeOutProc where ttTimeOutProc.task eq iTask no-error.
     if not available ttTimeOutProc
     then do:
        create ttTimeOutProc.
        ttTimeOutProc.task = iTask.
     end.
     ttTimeOutProc.timeOut = iTimeOut.
  end.
  
  method public void delTimeOutTask(iTask as character):
     find first ttTimeOutProc where ttTimeOutProc.task eq iTask no-error.
     if available ttTimeOutProc
     then do:
        delete ttTimeOutProc.
     end.
  end.
  
  method public integer getTimeOutTask(iTask as character):
     find first ttTimeOutProc where ttTimeOutProc.task eq iTask no-error.
     return if available ttTimeOutProc then ttTimeOutProc.timeOut else ?. 
  end.
  
  method public logical isAvailWorkShed(iSched as character ):
      define variable vnow as datetime-tz no-undo.
      vnow = getnow().
      for each ttRun where       ttRun.task        eq iSched
                              or iSched            eq ?
      no-lock:
         if      ttrun.fstatusItem ne "WaitRun"
            or (     ttrun.fstatusItem eq "WaitRun"
                 and ttRun.StartAfter  <= vnow)
         then
            return yes.
      end.
      return no.
   end.
   
   {utl/search.i class} 
   method public logical FolderExists  (input  ifolder as character ):
      return objExists(ifolder,"D") ne ?.
   end. 
   method public logical FileExists  (input  ifolder as character ):
      return objExists(ifolder,"F") ne ?.
   end.
   method public logical  objExists  (input  ifile as character):
      return    (objExists(ifile,"D") ne ?) or ( objExists(ifile,"F") ne ?) .                                  
   end.
   
   define stream sReadDir.
   method public logical  DelDontWorkProc  ():
      define variable vPureName as character no-undo.
      define variable vFileType as character no-undo.
      define variable vFullPath as character no-undo.
      define variable vFile     as character no-undo.
      define variable vPid      as integer no-undo.
      input STREAM sReadDir FROM os-dir(".").
      repeat:
         import stream sReadDir vPureName vFullPath vFileType.
         if     vFileType =  "d"
            and vPureName begins  preWorkDir  
         then do:
            
            file-info:file-name = vFullPath.
            if file-info:full-pathname <> ?
            and ( ( file-info:file-create-date = today
                 and file-info:file-create-time < time + 120
               )
               or (    file-info:file-create-date < today
                   and time > 120)
             )
            then do:
               vFile = vFullPath + "/parentPid.txt".
               if FileExists(vFile)
               then do:
                  input STREAM sReadfile FROM  VALUE(vFile). 
                  repeat:
                     import stream sReadfile vPid.
                  end.
                  input STREAM sReadfile close.
                  if IsProcessRunning( vpid ) <> -1 
                  then do:
                     os-delete value(vFullPath) recursive.
                  end.
               end.
               else if vPureName begins  "pid_"
               then
                  os-delete value(vFullPath) recursive.
            end.
         end.
      end.   
      input STREAM sReadDir close.                                  
   end.
   
   method public char Writefile (ifile as char,itext as char):
      define variable verror as character no-undo.
      verror = mAsyncProc:Writefile(ifile, itext).
   end.
   
end class.