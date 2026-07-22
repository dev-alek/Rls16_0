using Progress.Lang.*.
using ibs.th.adm.upd.*.
class ibs.th.adm.upd.updschm:
define variable vss-revision    as character no-undo init "$Revision:$":U .
define variable vss-author      as character no-undo init "$Author:$":U .
define variable vss-date        as character no-undo init "$Date:$":U .
define variable vss-workfile    as character no-undo init "$Workfile:$":U .
define variable vss-archive     as character no-undo init "$Archive:$":U .
define variable vss-description as character no-undo init "Обновление БД.".
  define variable loadDFprocFile as character no-undo.
  define property TargetDBShm as integer no-undo
    get.
    private set.
  define property CurrDBShm as integer  no-undo
    get.
    private set.
  define property NewCurrDBShm as integer  no-undo
    get.
    private set.
  define property CurrDB0Shm as integer  no-undo
    get.
    private set.
  define private property QuestionUpd as logical no-undo  init yes
    get.
    set.
  define private property UpdAllDB as logical no-undo init yes
    get.
    set.
  define private property UpdPart as  logical no-undo init yes
    get.
    set.
  define private property silent as logical no-undo
    get.
    set.
  define private property changPath as logical no-undo
    get.
    set.
  define private property UpdBlank as logical no-undo
    get.
    set.
  define private property ModeUpd as character  no-undo
    get.
    set (iarg as character ):
       modeupd = iarg.
       if lookup("OneDf",iarg) ne 0
       then do:
          QuestionUpd = no.
          UpdAllDB    = yes.
          UpdPart     = no.
          silent      = yes.
       end.
       else do:
          QuestionUpd = lookup("iscomp",iarg) eq 0 and lookup("UpdBlank",iarg) eq 0.
          UpdAllDB    = lookup("iscomp",iarg) eq 0 and lookup("UpdBlank",iarg) eq 0.
          UpdPart     = lookup("iscomp",iarg) eq 0 and lookup("UpdBlank",iarg) eq 0.
          silent      = lookup("updblank",iarg) ne 0.
          changPath   = lookup("iscomp",iarg) ne 0.
          UpdBlank    = lookup("UpdBlank",iarg) ne 0.
       end.
    end.
  define property ConPar as character no-undo
    get.
    set (arg as char):
      if arg begins "iscomp|"
      then do:
         modeupd = "iscomp".
         arg = entry(2,arg,"|").
      end.
      ConPar = replace (arg, "&1", "").
    end.
  define property isUpdShm as logical no-undo init yes
    get.
    private set.
  define property isNeedUpd as logical no-undo
  get.
  private set.
  define property PublisHandle as handle  no-undo
    get.
    private set.
  define property DbNum as integer init ?  no-undo
    get.
    private set.
  define property IsErr as logical no-undo
    get.
    private set.
  define property Msg as character no-undo
    get.
    private set.
  define private variable myUser         as character no-undo .
  define private variable myPasswd       as character no-undo .
  define property m-user-passwd-upd   as character no-undo
  get:
     define variable vpas as character no-undo.
     vpas = myPasswd  no-error.
     if vpas begins "nocrypt:"
     then
        vpas = substring (vpas,9).
     return substitute(' -U &1 -P "&2"':U
                                ,myUser
                                ,vpas
                                ).
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
  define variable obsrvdbObj as class observupd no-undo.
  define variable analisdfObj as class analisdf no-undo.
  define private variable m-prowin32FileName  as character no-undo.
  define private variable m-FileDf            as character no-undo.
  define private variable m-Batch             as logical   no-undo.
  define variable mDfUpdaLL as character no-undo.
  define stream sReadfile.
  constructor public updschm ():
     this-object (yes).
  end constructor.
  constructor public updschm (IQS as logical):
     putStat ("Установка контекста для проверки обновления ... ").
     obsrvdbObj = new observupd ().
     obsrvdbObj:ModeUpd = modeupd.
     obsrvdbObj:PublisHandle = PublisHandle.
     isNeedUpd = obsrvdbObj:isneedupg(yes).
     CurrDBShm   = obsrvdbObj:CurrDBShm.
     CurrDB0Shm  = obsrvdbObj:CurrDB0Shm.
     DbNum       = obsrvdbObj:DbNum.
     TargetDBShm = obsrvdbObj:TargetDBShm.
     if not isNeedUpd
     then
        run utl\chekupd.p (yes,TargetDBShm, output isNeedUpd).
     if IQS and not isRcode and isNeedUpd
     then
        message "Необходимо обновить базу с версии " CurrDBShm  " до " TargetDBShm " до запуска процесса. Остновить выполнение?" view-as alert-box question
             buttons yes-no title "[ ВНИМАНИЕ! ]" update isNeedUpd.
     delete object obsrvdbObj.
     putStat  ("Установка контекста для проверки обновления завершена").
  end constructor.
  constructor public updschm (input inConPar as char,input iMode as character,ipubhan as handle,iDfFile as character ):
    putStat  ("Установка контекста для обновления ...").
    define variable vupd as logical no-undo.
    define variable vok  as logical no-undo.
    modeupd = iMode.
    PublisHandle = iPubHan.
    ConPar      = inConPar.
    obsrvdbObj = new observupd ().
    obsrvdbObj:modeupd = modeupd.
    if iDfFile eq ?
    then do:
       obsrvdbObj:PublisHandle = PublisHandle.
       CurrDBShm   = obsrvdbObj:CurrDBShm.
       CurrDB0Shm  = obsrvdbObj:CurrDB0Shm.
       DbNum       = obsrvdbObj:DbNum.
       TargetDBShm = obsrvdbObj:TargetDBShm.
       m-FileDf    = obsrvdbObj:upd-df.
       isNeedUpd = obsrvdbObj:isneedupg(yes).
       if not isNeedUpd
       then
          run utl\chekupd.p (yes,TargetDBShm, output isNeedUpd).
       if QuestionUpd and not isRcode and isNeedUpd
       then do:
          putStat  ("Предоставлен выбор пользователя обновлять Бд или нет").
          message "Обновить базу с версии " CurrDBShm  " до " TargetDBShm "?" view-as alert-box question
             buttons yes-no title "[ ВНИМАНИЕ! ]" update vupd.
          if not vupd
          then do:
             putStat  ("Пользователя отказался от обновления Бд").
             isNeedUpd = no.
             return.
          end.
          else
             putStat  ("Пользователя согласился на обновление Бд").
       end.
       isNeedUpd = obsrvdbObj:isneedupg().
       if obsrvdbObj:IsErr
       then do:
         Msg = obsrvdbObj:Msg.
         IsErr = true.
       end.
       run utl\chekupd.p (no, TargetDBShm , output vok).
       if not vok
       then do:
          msg = return-value.
          IsErr = true.
       end.
    end.
    else do:
      isNeedUpd = yes.
      CurrDBShm   = -10.
      TargetDBShm = CurrDBShm.
      analisdfObj = new analisdf ().
      analisdfObj:modeupd = modeupd.
      if analisdfObj:readDF(iDfFile)
      then do:
         Msg =
           substitute("Ошибка при обновлении схемы базы данных &1&2",  chr(10) ,
           analisdfObj:msg)
         .
         IsErr = true.
      end.
      else do:
         mDfUpdaLL = replace(iDfFile,".df","_new.df").
         analisdfObj:dumpTable(mDfUpdaLL).
      end.
      delete object analisdfObj.
    end.
    assign
       myUser   = "sysadm".
       myPasswd = substitute("nocrypt:&1":U
                                ,obsrvdbObj:pwd
                                )
    .
    delete object obsrvdbObj.
    loadDFProcFile = search ("ibs/th/adm/upd/loaddf.r").
    if loadDFProcFile eq ?
    then
       loadDFProcFile = search ("ibs/th/adm/upd/loaddf.p").
    m-prowin32FileName =  search ("bin/prowin32.exe").
    putStat  ("Установка контекста для обновления завершена").
  end constructor.
  constructor public updschm (input inConPar as char,input iMode as character,ipubhan as handle):
       this-object(inConPar,input iMode,ipubhan,?).
  end.
  constructor public updschm (input inConPar as char ):
     this-object(input inConPar,"").
  end.
  constructor public updschm (input inConPar as char,input iMode as character):
     this-object(input inConPar,"",?).
  end.
  method public void upddbshm ():
    define variable vI as integer no-undo.
    define variable vdbconect as logical no-undo.
    if  CurrDBShm eq TargetDBShm
    then
       vdbconect = yes.
    putStat  ("Обновление Бд").
    upddbshmall().
    if isUpdShm
       and UpdAllDB
    then do:
         disconnect value ('ub').
      do vi = 1 to num-entries(mDfUpdaLL):
         upddbshm-1(entry(vi,mDfUpdaLL)).
      end.
    end.
    return.
  end.
  method public void upddbshmall():
    Block-UpdOne:
    do while CurrDBShm < TargetDBShm :
      isUpdShm = no.
      upddbshmAllOneDf().
      if isErr
      then
        leave Block-UpdOne.
    end.
    if isErr
    then do:
       if not UpdPart
       then
          putmes("Ошибка обновления БД.").
       else do:
          putmes("Ошибка обновления БД. Попробуем обновить по частям").
          isErr = no.
          Block-UpdOneTry:
          do while CurrDBShm < TargetDBShm :
             isUpdShm = no.
             upddbshmOne().
             if isErr
             then
                leave Block-UpdOneTry.
          end.
       end.
    end.
  end method.
  method public void upddbshmAllOneDf ():
    if not connected ("ub")
    then
       connect value(substitute(ConPar + " &1", m-user-passwd-upd)).
    if CurrDBShm < TargetDBShm
    then do:
      analisdfObj = new analisdf ().
      analisdfObj:modeupd = modeupd.
      analisdfObj:PublisHandle = PublisHandle.
      putstat(substitute ("Получение файла обновления для версии &1",CurrDBShm)).
      if  analisdfObj:createDF(CurrDBShm)
      then do:
         assign
            m-FileDf     = analisdfObj:mFileDf
            NewCurrDBShm = analisdfObj:mUpdateTo
         .
         putstat(substitute ("Получен файла обновления &1 c версии &2 до версии &3",m-FileDf,CurrDBShm,NewCurrDBShm)).
      end.
      else
         isErr = yes.
      if isErr then
      do:
        Msg =
          substitute("Ошибка при обновлении схемы базы данных &1&2",  chr(10) ,
          analisdfObj:msg)
          .
        putstat(Msg).
        IsErr = true.
        return.
      end.
      delete object analisdfObj no-error.
      disconnect value ('ub').
      upddbshm-1(m-FileDf).
      if isErr then
      do:
        Msg =
          substitute("Ошибка при обновлении схемы базы данных &1&2 &1&3",  chr(10) ,
          error-status :get-message(1) ,
          return-value)
          .
        putStat(MSG).
        IsErr = true.
      end.
      connect value(substitute(ConPar + " &1", m-user-passwd-upd)).
    end.
     analisdfObj = new analisdf ().
     analisdfObj:modeupd = modeupd.
     analisdfObj:PublisHandle = PublisHandle.
     def var m-FileDf_new as char no-undo.
     putstat(substitute ("Получение файла проверки с версии &1",CurrDBShm)).
     if analisdfObj:createDF(CurrDBShm)
     then do:
        m-FileDf     = analisdfObj:mFileDf.
        m-FileDf_new = replace (m-FileDf,"~/","~\").
        entry(num-entries (m-FileDf_new,"~\"),m-FileDf_new,"~\") = "new_" + entry(num-entries (m-FileDf_new,"~\"),m-FileDf_new,"~\").
        if not analisdfObj:CheckTable(m-FileDf_new)
        then do:
           IsErr = true.
           delete object analisdfObj no-error.
           putmes (substitute ("Поля не прошедшие проверку выгружены в файл &1",m-FileDf_new)).
           return.
        end.
     end.
     putstat(substitute ("Проверка прошла успешно.")).
     delete object analisdfObj no-error.
     obsrvdbObj = new observupd ().
    obsrvdbObj:ModeUpd = ModeUpd.
    obsrvdbObj:PublisHandle = PublisHandle.
    putstat(substitute ("Сохраняем версию БД.")).
    obsrvdbObj:writeResult(NewCurrDBShm).
    if obsrvdbObj:IsErr
    then do:
      Msg = obsrvdbObj:Msg.
      putstat(substitute ("Ошибка сохранения версии &1",Msg)).
      delete object obsrvdbObj no-error.
      IsErr = true.
      return.
    end.
    putstat(substitute ("Сохранена версия &1 БД.",NewCurrDBShm)).
    delete object obsrvdbObj no-error.
    CurrDBShm = NewCurrDBShm.
    isUpdShm = true.
  end method.
  method public void upddbshmOne ():
    if CurrDBShm < TargetDBShm
    then do:
      analisdfObj = new analisdf ().
      analisdfObj:modeupd = modeupd.
      analisdfObj:PublisHandle = PublisHandle.
      if  analisdfObj:createDF(CurrDBShm,CurrDBShm + 1)
      then do:
         assign
            m-FileDf     = analisdfObj:mFileDf
            NewCurrDBShm = analisdfObj:mUpdateTo
         .
      end.
      else
         isErr = yes.
      if isErr then
      do:
        Msg =
          substitute("Ошибка при обновлении схемы базы данных&1&2",  chr(10) ,
          analisdfObj:msg)
          .
        IsErr = true.
        return.
      end.
      if not m-FileDf begins "proc:"
      then
         m-FileDf = analisdfObj:addDFNumUpd(m-FileDf,CurrDBShm + 1).
      delete object analisdfObj no-error.
      disconnect value ('ub').
      upddbshm-1(m-FileDf).
      if isErr then
      do:
        Msg =
          substitute("Ошибка при обновлении схемы базы данных&1&2&1&3",  chr(10) ,
          error-status :get-message(1) ,
          return-value)
          .
        IsErr = true.
        return.
      end.
      connect value(substitute(ConPar + " &1", m-user-passwd-upd)).
    end.
    NewCurrDBShm = CurrDBShm + 1.
    obsrvdbObj = new observupd ().
    obsrvdbObj:ModeUpd = ModeUpd.
    obsrvdbObj:PublisHandle = PublisHandle.
    obsrvdbObj:writeResult(NewCurrDBShm).
    if obsrvdbObj:IsErr
    then do:
      Msg = obsrvdbObj:Msg.
      delete object obsrvdbObj no-error.
      IsErr = true.
      return.
    end.
    m-FileDf = obsrvdbObj:upd-df.
    delete object obsrvdbObj no-error.
    CurrDBShm = NewCurrDBShm.
    isUpdShm = true.
  end method.
  method private void upddbshm-1 (input iparam as character ):
    define variable vproc  as character no-undo.
    define variable vparam as character no-undo.
    if iparam begins "proc:"
    then do:
       assign
          iparam = substring (iparam,6)
          vproc  = entry(1,iparam,";")
          vparam = entry(2,iparam,";")
       no-error.
       putStat  (substitute ("Выполнение процедуры &1 ...",iparam)).
       if vproc ne ""
       then
          runsession (vproc,vparam).
       putStat  (substitute ("Выполнение процедуры &1 завершено",iparam)).
    end.
    else do:
       putStat  (substitute ("Загрузка данных из файла &1 ...",iparam)).
       loaddf (iparam).
       putStat  (substitute ("Загрузка данных из файла &1 завершена.",iparam)).
    end.
    if IsErr = true
      then return.
  end method.
  method private void loaddf (input inFileDF as char):
    def var v-filedfname as character no-undo.
    v-filedfname = search (inFileDF).
    if v-filedfname = ?
    then do:
      Msg = substitute ( "Файл &1 обновления схемы БД не найден. Работа с ней запрещена!", inFileDF).
      IsErr = true.
      return.
    end.
    runsession(loadDFprocFile,v-filedfname).
  end.
  method private void runsession (input iProc as char,input iParam as char):
     define variable vParamStart as character no-undo.
     if SearchPFile (iProc) eq ?
     then do:
        Msg = substitute ( "Не найден файл &1 !", iProc).
        putmes(msg).
        IsErr = true.
        return.
     end.
     else
        iProc = SearchPFile (iProc).
     if iproc eq loadDFprocFile and isRcode
     then
        vParamStart = vParamStart + " -rx  -clientlog  mylog.lg -logginglevel 1" .
    define variable vAsyncHelper as class ibs.th.file.AsyncHelperth no-undo.
    vAsyncHelper = new ibs.th.file.AsyncHelperth().
    vAsyncHelper:myUser = myUser.
    vAsyncHelper:myPass = myPasswd.
    vAsyncHelper:MyBachMode = no.
    vAsyncHelper:WritelogInter = 5.
    vAsyncHelper:mProcPublish = PublisHandle.
    vAsyncHelper:ChangProPath = changPath.
    vAsyncHelper:paramSession = vParamStart.
    vAsyncHelper:SetGblPar = false.
    if UpdBlank
    then do:
       vAsyncHelper:MyParamStart = " -ininame "  + GetStartupParam("-ininame") + " " + ConPar.
       vAsyncHelper:DbConnect  = no.
    end.
    vAsyncHelper:AsyncProc("utl/proc-anyproc", substitute("&1&3&2":U
                                              , iProc
                                              ,if iParam eq "" then "" else iParam ,
                                               if iParam eq "" then "" else chr(4) ),1).
    run ibs\th\file\waithelper.p (vAsyncHelper,?, 1, substitute ("Обновление БД с &1 версии до &2 версии",CurrDBShm,NewCurrDBShm)).
    define variable vLogFile as character no-undo.
    define variable vSilent as logical no-undo.
    vSilent = silent.
    silent = yes.
    vLogFile = searchfile(vAsyncHelper:getLog(?)).
    if vLogFile ne ?
    then do:
       input STREAM sReadfile FROM  VALUE(vLogFile).
       block-read:
       repeat:
          define variable vstr as character no-undo.
          import stream sReadfile unformatted vStr.
          putmes (vStr).
          define variable vtext1 as character no-undo.
          define variable vtext3 as character no-undo.
          assign
             vtext1 = entry(1,vStr," ")
             vtext3 = entry(3,vStr," ")
          no-error.
          if    vtext1 = "error"
             or vtext3 = "error"
          then do:
             IsErr = yes.
          end.
       end.
       input stream sReadfile close.
    end.
    silent = vSilent.
    delete object vAsyncHelper.
  end method.
   method public character GetStartupParam (input iParam as character  ):
   define variable vStartupParameters as character no-undo.
   vStartupParameters = session:startup-parameters.
   define variable vNumStartupParameters as integer no-undo.
   vNumStartupParameters = num-entries( vStartupParameters ).
   define variable i as integer no-undo.
      block-par:
   do i = 1 to vNumStartupParameters:
      define variable vParameter as character no-undo.
      vParameter = entry( i, vStartupParameters ).
      if vParameter begins iParam then
      do:
         define variable vList as character no-undo.
         vList  = entry(2,vParameter,' ').
      end.
   end.
   return vList.
   end method.
   method public void putmes (input itext as char):
    if not silent
    then do:
       message itext
       view-as alert-box.
    end.
    if valid-handle(PublisHandle)
    then
       publish "WriteLogAsunc" from PublisHandle (itext,yes ).
   end.
   method public void putstat (input itext as char):
      if valid-handle(PublisHandle)
     then
        publish "PutStatAsunc"  from PublisHandle (itext, no ).
   end.
method public character objExists
(input  ifolder as character,
 input  iType   as character  ):
    define variable vFileType as character no-undo init "D,F".
    define variable vi        as integer no-undo.
    define variable vtype as character no-undo.
    if iType ne ?
    then
       vFileType = iType.
    do vi = 1 to num-entries(vFileType):
       file-information:file-name = ".\" + right-trim(replace(ifolder,"/","\"),"\").
       vtype = file-information:file-type.
       if entry(num-entries(file-information:file-name, "\"), file-information:file-name, "\")
          = entry(num-entries(file-information:full-pathname, "\"), file-information:full-pathname ,"\") and
          index(vtype , entry(vi,vFileType )) > 0
       then return file-information:full-pathname .
       file-information:file-name = right-trim(replace(ifolder,"/","\"),"\").
       vtype = file-information:file-type.
       if file-information:file-name <> "" and
          entry(num-entries(file-information:file-name, "\"), file-information:file-name, "\")
          = entry(num-entries(file-information:full-pathname, "\"), file-information:full-pathname ,"\") and
          index( vtype, entry(vi,vFileType )) > 0
       then return file-information:full-pathname .
    end.
    return ? .
end.
method public character SearchFile
(input  ifile as character):
   return objExists(ifile,?).
end.
method public character SearchPFile
(input inFile as char):
     define variable oFile       as character no-undo.
     define variable vFileSearch as character no-undo.
     define variable vNumEntry   as integer no-undo.
     if inFile = "" then return ?.
     vNumEntry = num-entries(inFile,".").
     vFileSearch = inFile.
     if    vNumEntry > 0
        and (   entry(vNumEntry,inFile,".") eq "p"
             or entry(vNumEntry,inFile,".") eq "w")
     then do:
        entry(vNumEntry,vFileSearch, ".") = "r".
        oFile = search(vFileSearch ).
        if oFile eq ?
        then
           oFile = search(inFile).
     end.
     else
        oFile = search(vFileSearch).
     return oFile.
  end.
end class.
