block-level on error undo, throw.
/*
File        : r-lmsts.p
$Revision:$
$Author:$
$Date:$
$Workfile:$
$Archive:$
Отчет о состоянии локального модуля Честный знак
Автор: Белова Марина Михайловна 
Дата создания: 24 сентября 2024 г.
Author:  Belova Marina 
Creation date: 24 september 2024 г.

*/
USING ibs.th.skt.ControlledClients.GisMtOffline.

DEFINE INPUT PARAMETER parparentproc    AS WIDGET-HANDLE NO-UNDO .
DEFINE INPUT PARAMETER p-parent-handle  AS WIDGET-HANDLE NO-UNDO .
DEFINE INPUT PARAMETER p-log-handle  AS HANDLE NO-UNDO .
DEFINE INPUT PARAMETER p-cre-db-num     AS INTEGER      NO-UNDO .
DEFINE INPUT PARAMETER p-task-type      AS CHARACTER    NO-UNDO.
DEFINE INPUT PARAMETER p-task-num       AS INTEGER      NO-UNDO.
DEFINE INPUT PARAMETER p-db-num         AS INTEGER      NO-UNDO .
 
DEFINE VARIABLE vss-revision    AS CHARACTER NO-UNDO INIT "$Revision:$":U .
DEFINE VARIABLE vss-author      AS CHARACTER NO-UNDO INIT "$Author:$":U .
DEFINE VARIABLE vss-date        AS CHARACTER NO-UNDO INIT "$Date:$":U .
DEFINE VARIABLE vss-workfile    AS CHARACTER NO-UNDO INIT "$Workfile:$":U .
DEFINE VARIABLE vss-archive     AS CHARACTER NO-UNDO INIT "$Archive:$":U .
DEFINE VARIABLE vss-description AS CHARACTER NO-UNDO INIT "Отчет о состоянии ЛМ ЧЗ - вызов по расписанию".
DEFINE VARIABLE mError AS LOGICAL NO-UNDO.
{ cmp/vssrevis.i }
{ utl/proc-async.i proc_def}
{ utl/search.i }
{ gbl/db-attr.i }   
{ cmp/trg-def.i }
{ adm/auto-def.i    }
{ ref/shd-attr.i    }
{ gbl/cur-time.i }

DEFINE VARIABLE v-dir-name  AS CHARACTER NO-UNDO .
DEFINE VARIABLE v-dir-type  AS CHARACTER NO-UNDO .
DEFINE VARIABLE v-can-read  AS LOGICAL   NO-UNDO .
DEFINE VARIABLE v-param-list    AS CHARACTER     NO-UNDO.
DEFINE VARIABLE v-param-type    AS CHARACTER     NO-UNDO.
DEFINE VARIABLE v-computer-tcp-name    AS CHARACTER NO-UNDO .
DEFINE VARIABLE v-computer-ip-addr     AS CHARACTER NO-UNDO .
DEFINE VARIABLE v-target    AS CHARACTER NO-UNDO .

DEFINE VARIABLE thGisMtOff AS CLASS GisMtOffline NO-UNDO .

DEFINE TEMP-TABLE ttreport-header NO-UNDO    
   XML-NODE-NAME "report-header"
   FIELD reqid        AS RECID SERIALIZE-HIDDEN
   FIELD f_datetime-tz     AS DATETIME-TZ XML-NODE-NAME "datetime-tz"
   FIELD report-name     AS CHAR
   FIELD report-label AS CHAR 
   FIELD report-db-num AS INT
   FIELD report-db-name AS CHAR
   FIELD report-db-hist AS CHAR
   INDEX reqidpar reqid 
   .   
  
 DEFINE TEMP-TABLE ttreplicationStatus NO-UNDO    
   XML-NODE-NAME "replicationStatus"
   FIELD reqid      AS RECID     SERIALIZE-HIDDEN           
   FIELD f_status   AS CHARACTER XML-NODE-NAME "status"
   FIELD f_version  AS CHARACTER XML-NODE-NAME "version"   
   FIELD lastUpdate AS CHARACTER 
   FIELD lastSync   AS CHARACTER 
   FIELD inst       AS CHARACTER 
   FIELD vers       AS CHARACTER XML-NODE-NAME "dbVersion"
   FIELD timeLag    AS CHARACTER
   FIELD onlineTime AS CHARACTER
   INDEX reqidpar reqid 
   .
   
 DEFINE DATASET gismt-report-body  XML-NODE-NAME "report-lmchzsts" FOR ttreport-header, ttreplicationStatus.         
     
  define temp-table ttfiles-inf  no-undo serialize-name  "files" 
   field md5            as char
   field name           as char
   field timestamp      as char 
   index timestamp timestamp.
       
  define dataset data-files-adr SERIALIZE-HIDDEN  for ttfiles-inf .

  define stream out_data.
  define variable vImpArchSts as logical no-undo.
  
DO
ON ERROR UNDO, RETURN ERROR RETURN-VALUE
:   
   &scop display-message    run write-log-and-file in p-log-handle (  ~
        input 1                                                      ~
      , input log-file-name                                          ~
      , input 1                                                      ~
      , input ~{&my-message~})


    ASSIGN
    log-file-name = "shd-free.log".

    RUN gbl/set-gbl.p
      (INPUT  TRUE
      ,INPUT  g#auto-user-id
      ,INPUT  g#auto-user-password
      ) NO-ERROR.
    IF ERROR-STATUS :ERROR
    THEN DO:
      DEF VAR v-err-str AS CHARACTER NO-UNDO.
      v-err-str = ERROR-STATUS:GET-MESSAGE(ERROR-STATUS:NUM-MESSAGES) + {&new-line} + RETURN-VALUE.
       
&scop my-message   substitute("!!!Ошибка при инициализации переменных g#... &1&2" ~
                                     , v-err-str ~
                                     , ~{&new-line~})

       {&display-message}.
                        
        RETURN.
    END.
    
    RUN schedule-attr-value IN this-procedure (
          INPUT p-cre-db-num
        , INPUT p-task-type
        , INPUT p-task-num
        , INPUT {&attr-schedule-param-list-h}
        , OUTPUT v-param-list
        , OUTPUT v-param-type
    ).
    IF v-param-list = "":U THEN DO:

&scop my-message   substitute("!!!Не заданы параметры отчета о состоянии ЛМ ЧЗ &1&2" ~
                                     , p-task-num        ~
                                     , ~{&new-line~})

       {&display-message}.
       RETURN.
    END.
    
    v-dir-name = v-param-list NO-ERROR.
    

    ASSIGN
    FILE-INFO:FILE-NAME = v-dir-name
    v-dir-type = FILE-INFO:FILE-TYPE
    .
    IF INDEX( v-dir-type, "D" ) = 0 THEN DO:
&scop my-message   substitute("!!!Выбранный для формирования отчета каталог &1 - недоступен&2" ~
                                     , v-dir-name ~
                                     , ~{&new-line~})

      {&display-message}.
      RETURN .
    END.
    /*
    run gbl/tcp-info.p
      (output v-computer-tcp-name
      ,output v-computer-ip-addr
      ) .
    */
    RUN CalcStatus (v-dir-name) NO-ERROR .
    IF ERROR-STATUS:ERROR THEN DO:
&scop my-message   substitute("!!!Ошибка при формировании отчета&3&1&3&2&3" ~
                                     , return-value ~
                                     , error-status:get-message(1) ~
                                     , ~{&new-line~})

      {&display-message}.
    END.
    ELSE DO:
&scop my-message   substitute("!!!Формирование отчета о состоянии ЛМ ЧЗ завершено.&1" ~
                                     , ~{&new-line~})

      {&display-message}.
    END.
    RUN GetArchFromKassa (OUTPUT vImpArchSts) NO-ERROR.
    IF ERROR-STATUS:ERROR THEN DO:
&scop my-message   substitute("!!!Ошибка при загрузке архива с кассы &3&1&3&2&3" ~
                                     , return-value ~
                                     , error-status:get-message(1) ~
                                     , ~{&new-line~})

      {&display-message}.
    END.    
    ELSE IF vImpArchSts THEN DO:
&scop my-message   substitute("!!!Архивы с касс загружены.&1" ~
                                     , ~{&new-line~})

      {&display-message}.
    END.
    ELSE DO:
&scop my-message   substitute("!!!Архивы для загрузки с касс отсутствуют.&1" ~
                                     , ~{&new-line~})

      {&display-message}.        
        
    END.    
    
END.

DELETE OBJECT thGisMtOff NO-ERROR.  
{ utl/proc-async.i proc_end}

PROCEDURE CalcStatus:
    DEFINE INPUT PARAM iDirName AS CHARACTER NO-UNDO.
    
    DEFINE VARIABLE vStatus   AS CHARACTER NO-UNDO.
    DEFINE VARIABLE v-version AS CHARACTER NO-UNDO.
    DEFINE VARIABLE vTimeLag  AS CHARACTER NO-UNDO.
    DEFINE VARIABLE vOnlineTimeD AS DECIMAL NO-UNDO.
    DEFINE VARIABLE vOnlineTime AS INT64    NO-UNDO.
    DEFINE VARIABLE vTimeBegErr AS DATETIME-TZ NO-UNDO.
    DEFINE VARIABLE vlastUpdate AS CHARACTER NO-UNDO.
    DEFINE VARIABLE vLastSync   AS CHARACTER NO-UNDO.
    DEFINE VARIABLE vInst       AS CHARACTER NO-UNDO.
    DEFINE VARIABLE vdbVersion  AS CHARACTER NO-UNDO.
    
    DEFINE BUFFER buf_code FOR ub.code.

    thGisMtOff =  NEW GisMtOffline() NO-ERROR.           
    vStatus = thGisMtOff:GetChkStsOffline(OUTPUT v-version, 
                                          OUTPUT vTimeLag, 
                                          OUTPUT vlastUpdate, 
                                          OUTPUT vLastSync, 
                                          OUTPUT vInst, 
                                          OUTPUT vdbVersion) NO-ERROR.
    
    /* Проверяем, зафиксирован ли сбой онлайн-проверки */    
    FIND FIRST buf_code WHERE buf_code.parent EQ "GisMt"
           AND buf_code.code   EQ "GisMtErr"
       NO-LOCK NO-WAIT NO-ERROR.
    /* если ошибка уже была, смотрим сколько прошло времени */   
    IF AVAILABLE buf_code            
       AND buf_code.codevalue > "" 
    THEN DO:
       vTimeBegErr = DATETIME-TZ(buf_code.codevalue) NO-ERROR.
       IF vTimeBegErr <> ? THEN DO:
          vOnlineTimeD = (NOW - vTimeBegErr) / 3600000.
          vOnlineTime = ROUND(vOnlineTimeD,0).
          if vOnlineTime < vOnlineTimeD then vOnlineTime = vOnlineTime + 1.
       END.   
       ELSE vOnlineTime = 0.    
    END.
    ELSE vOnlineTime = 0.
       
    RUN Put2Xml (iDirName, 
                 vStatus, 
                 v-version, 
                 vTimeLag, 
                 STRING(vOnlineTime),
                 vlastUpdate, 
                 vLastSync, 
                 vInst, 
                 vdbVersion) NO-ERROR.  
      
END PROCEDURE.

PROCEDURE Put2Xml:
    DEFINE INPUT PARAM iDirName AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER iStatus AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER iVersion AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER iTimeLag AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER iOnlineTime AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER vlastUpdate AS CHARACTER NO-UNDO. 
    DEFINE INPUT PARAMETER vLastSync AS CHARACTER NO-UNDO. 
    DEFINE INPUT PARAMETER vInst AS CHARACTER NO-UNDO. 
    DEFINE INPUT PARAMETER vdbVersion AS CHARACTER NO-UNDO.
    
    DEFINE VARIABLE vFileResult AS CHARACTER NO-UNDO.
    DEFINE VARIABLE vFileName AS CHARACTER NO-UNDO.
    DEFINE VARIABLE vRetOk AS LOGICAL NO-UNDO.       
    DEFINE VARIABLE vWorkDir AS CHARACTER NO-UNDO.
    DEFINE VARIABLE v-obj-name AS CHARACTER NO-UNDO.
    DEFINE VARIABLE v-db-num AS INTEGER NO-UNDO.
        
    DEFINE VARIABLE v-par-type  AS CHARACTER NO-UNDO.
    DEFINE VARIABLE v-hist-code AS CHARACTER NO-UNDO.
    DEFINE VARIABLE v-hist-name AS CHARACTER NO-UNDO.
                    
    DEFINE BUFFER buf_sys-ctrl FOR ub.sys-ctrl .
    DEFINE BUFFER buf_clients FOR ub.clients .
     
     FIND FIRST buf_sys-ctrl NO-LOCK NO-ERROR.
     IF AVAILABLE buf_sys-ctrl AND buf_sys-ctrl.db-num <> 0 
     THEN DO:
         FIND FIRST buf_clients NO-LOCK WHERE 
                   buf_clients.db-num = buf_sys-ctrl.db-num NO-ERROR.
         IF AVAIL buf_clients 
         THEN ASSIGN
                v-obj-name = buf_clients.obj-name 
                v-db-num  = buf_sys-ctrl.db-num
                .
     END.    
    RUN db-attr-value(INPUT v-db-num,INPUT {&attr-hist-code},OUTPUT v-hist-code ,OUTPUT v-par-type) .  
    RUN db-attr-value(INPUT v-db-num,INPUT {&attr-hist-name},OUTPUT v-hist-name ,OUTPUT v-par-type) .              

    vWorkDir = iDirName.
    vFileName = "LmChz-" + string(TODAY,"99-99-9999") 
                  + "_" + string(v-db-num). 
           
    RUN GenFileName (vWorkDir, vFileName, OUTPUT vfileresult).        
    
    if vfileresult = "" then return error "Не удалось инициализировать имя файла.".
                      
    CREATE ttreport-header.
    ASSIGN
       ttreport-header.reqid = 1
       ttreport-header.f_datetime-tz  = NOW
       ttreport-header.report-name    = "lmchzsts"
       ttreport-header.report-label   = "Отчет о состоянии ЛМЧЗ"
       ttreport-header.report-db-num  = v-db-num
       ttreport-header.report-db-name = v-obj-name /*if v-hist-name = "" then v-obj-name else v-hist-name*/
       ttreport-header.report-db-hist = v-hist-code
       .
        
    CREATE ttreplicationStatus.
    ASSIGN 
       ttreplicationStatus.reqid      = 1
       ttreplicationStatus.f_status   = iStatus 
       ttreplicationStatus.f_version  = iVersion
       ttreplicationStatus.timeLag    = iTimeLag
       ttreplicationStatus.onlineTime = iOnlineTime
       ttreplicationStatus.lastUpdate = vlastUpdate    
       ttreplicationStatus.lastSync   = vLastSync
       ttreplicationStatus.inst       = vInst                
       ttreplicationStatus.vers       = vdbVersion      
       .
    vRetOk = DATASET gismt-report-body:WRITE-XML("FILE":U, vfileresult, TRUE, "windows-1251", ?, FALSE, TRUE ,FALSE,TRUE ) no-error.
    
END PROCEDURE.    

PROCEDURE GenFileName:
  DEFINE INPUT PARAM iWorkDir      AS CHAR NO-UNDO.
  DEFINE INPUT PARAM iFileNameBase AS CHAR NO-UNDO.  
  DEFINE OUTPUT PARAM oFileNameGen AS CHAR NO-UNDO.  
    
  DEFINE VARIABLE v-name        AS CHARACTER NO-UNDO .
  DEFINE VARIABLE v-check-name  AS CHARACTER NO-UNDO .
  DEFINE VARIABLE vNum AS INTEGER NO-UNDO.  
  DEFINE VARIABLE vExtension  AS CHARACTER NO-UNDO.
  DEFINE VARIABLE vDirDelim   AS CHARACTER NO-UNDO INIT "\":u.
    
  ASSIGN
    vNum = 0         
    vExtension = '.':u + "xml"
    oFileNameGen = ""
    .
  
  v-check-name = "something". 

  DO WHILE v-check-name <> ? and vNum < 99:
    /* число из не более чем 2 цифр */
    ASSIGN
      vNum = vNum + 1
    .
            
    ASSIGN
      v-name = iWorkDir + vDirDelim + iFileNameBase + "-" + string(vNum,"99":U) + vExtension
    .
    
    ASSIGN
      v-check-name = SEARCH(v-name)
    .
  END.
  if v-check-name = ? 
  then oFileNameGen = v-name.
  
END PROCEDURE.    

/* перебор по всем кассам */
procedure GetArchFromKassa:   
   define output param oImpSts as logical no-undo.
   
   define buffer for-cash-desk for ub.cash-desk.
   
   define variable vOneImpSts as logical no-undo.
   define variable vFolder as character no-undo.
   define variable vDirDelim    as character no-undo init "\":u.
      
   vFolder   = "Архивы взаимодействия с ГИС МТ" .
   
   if objExists(vFolder,"D") eq ?  
       then os-create-dir VALUE(vFolder).   
              
   oImpSts = no.
   for each for-cash-desk no-lock where
            for-cash-desk.db-num   eq g#db-num                                   
        and for-cash-desk.cash-on  eq yes
        :
        if num-entries(for-cash-desk.addr-path, {&delim-par}) >= 2 then
        do:
           run write-log-and-file in p-log-handle ( input 1                              
                                          , input log-file-name                  
                                          , input 1                              
                                          , input substitute("Запрос архивов кассы номер &1", for-cash-desk.cash-num)). 
           run GetArchFromOneKassa (entry(1, for-cash-desk.addr-path, {&delim-par}) 
                                    + '://' + entry(1,entry(2, for-cash-desk.addr-path, {&delim-par}),":"),
                                    substitute("&1&3&2",vFolder,for-cash-desk.cash-num,vDirDelim),
                                    for-cash-desk.cash-num,
                                    output vOneImpSts ).
           if vOneImpSts then
           run write-log-and-file in p-log-handle ( input 1                              
                                          , input log-file-name                  
                                          , input 1                              
                                          , input substitute("Архивы с кассы номер &1 загружены", for-cash-desk.cash-num)).                          
        end.
        else 
           run write-log-and-file in p-log-handle ( input 1                              
                                          , input log-file-name                  
                                          , input 1                              
                                          , input substitute("!!!В справочнике для кассы номер &1 некорректно задан адрес и порт кассы", for-cash-desk.cash-num)).                            
        oImpSts = oImpSts or vOneImpSts.                              
   end.        

end procedure. 

/* получение данных с одной кассы */    
procedure GetArchFromOneKassa:
    define input param iAddrPath   as char no-undo.
    define input param iCashFolder as char no-undo.
    define input param iCashNum    as char no-undo.
    define output param oOneImpSts as logical no-undo.
    
    define buffer buf_code for code.
    define variable vTimeStart      as int64 no-undo.
    define variable vCmd            as character no-undo.
    define variable vFileResult     as character no-undo.
    define variable vFileResultErr  as character no-undo.
    define variable vFileResArch    as character no-undo.
    define variable vFileResArchErr as character no-undo.
    define variable vConnectTime    as decimal no-undo.
    define variable vlongJson       as longchar no-undo.
    define variable hDS             as handle no-undo.
    define variable vRetOk          as logical no-undo.    
    define variable v-chk-sum-signature as char no-undo.
    define variable vFileListCmd    as character no-undo.
    define variable vFileArhCmd     as character no-undo.
    define variable vFileReqPath    as character no-undo.    
    define variable vMyWorkDir      as character no-undo. /* Путь к каталогу */
    define variable vFolder         as character no-undo. /* Каталог с архивом */
    define variable vFolderPath     as character no-undo.
    define variable vDirDelim       as character no-undo init "\":u.
    define variable vFileArh        as character no-undo. /* имя файла архива */
    define variable vFileReqErrPath as character no-undo.
    
    /* ищем временную метку */
    FIND FIRST buf_code WHERE buf_code.parent EQ "GisMt"
                          AND buf_code.code   EQ substitute("ArchDate:&1",iCashNum)
         NO-LOCK NO-ERROR.
    if avail buf_code then 
       vTimeStart = int64(buf_code.CodeValue) no-error.
    else vTimeStart = 0.   
    if vTimeStart = ? then vTimeStart = 0.
    
    vConnectTime = 30.
    empty temp-table ttfiles-inf.
     
    RUN gbl/_tmpfile.p ( "PiotLogList", ".txt", OUTPUT vFileResult ) .              
    RUN gbl/_tmpfile.p ( "PiotLogListErr", ".txt", OUTPUT vFileResultErr ) .          
    if session:debug-alert then run gbl/_tmpfile.p ("PiotLogListCmd", ".bat", output vFileListCmd) .
           
    /*--location --request GET "http://127.0.0.1:1501/PiotLogList?archDate=0" --header "Accept: application/json"*/
    vCmd = SUBSTITUTE ('&1  --connect-timeout &6 --max-time &6 --location --request GET "&2:1501/PiotLogList?archDate=&3" --header "Accept: application/json" >&4 --stderr &5',
                      SEARCH ("exe/curl.exe"), /*1*/
                      iAddrPath,             /*2*/   
                      vTimeStart,   /*3*/
                      vFileResult, /*4*/                      
                      vFileResultErr, /*5*/
                      vConnectTime /*6*/
                      ).                                 
    if session:debug-alert then 
     do:
         OUTPUT STREAM out_data TO value(vFileListCmd).        
         PUT STREAM out_data UNFORMATTED  
          vCmd .
         OUTPUT STREAM out_data CLOSE.
     end.             
    os-command silent value(vCmd).
        
    IF searchFile(vFileResult) <> ?
    THEN DO :                             
       if objExists(iCashFolder,"D") eq ?  
       then os-create-dir VALUE(iCashFolder).
       
       copy-lob from file vFileResult to vlongJson no-error.          
       hDS = dataset data-files-adr:handle.                         
       vRetOk  = hDS:read-json("longchar":U, vlongJson) no-error.
              
       for each ttfiles-inf:
           oOneImpSts = yes .           
           vFileResArch = ttfiles-inf.name.
           vFileResArchErr = "Err" + entry(1,ttfiles-inf.name,".") + ".txt".           
           vCmd = SUBSTITUTE ('&1  --connect-timeout &6 --max-time &6 --location --request GET "&2:1501/PiotLogArch?archName=&3" --header "Accept: application/octet-stream" --output &4 --stderr &5',
                              SEARCH ("exe/curl.exe"), /*1*/
                              iAddrPath,             /*2*/                      
                              ttfiles-inf.name,   /*3*/
                              vFileResArch, /*4*/                      
                              vFileResArchErr, /*5*/
                              vConnectTime  /*6*/
                              ).                                 
            if session:debug-alert then run gbl/_tmpfile.p ("PiotLogArhCmd", ".bat", output vFileArhCmd) .
            if session:debug-alert then 
             do:
                 OUTPUT STREAM out_data TO value(vFileArhCmd).        
                 PUT STREAM out_data UNFORMATTED  
                  vCmd .
                 OUTPUT STREAM out_data CLOSE.
             end.
            os-command silent value(vCmd).
                                   
            if searchFile(vFileResArch) = ? then do:                
                run DelTmpFiles (substitute("&2&1&3&1&4",
                                            {&delim-par},vFileResult,vFileResultErr,vFileResArchErr)). 
                return error substitute("Не удалось загрузить архив &1", 
                                        vFileResArch).
            end.    
            run gbl/md5.p
                (input  searchFile(vFileResArch)
                ,output v-chk-sum-signature
                ) .                                   
            /* не совпал кэш */
            if v-chk-sum-signature <> ttfiles-inf.md5 
            then do:                                
                run DelTmpFiles (substitute("&2&1&3&1&4&1&5",
                                            {&delim-par},vFileResult,vFileResultErr,vFileResArchErr,vFileResArch)). 
                return error substitute("Не совпадает проверочная сумма архива: Проверочная контрольная сумма: &1 сумма архива: &2", 
                                        ttfiles-inf.md5, v-chk-sum-signature).
            end.
            /* архив успешно скачен, сохраняем время и переходим к следующему */    
            else do 
            transaction:
               assign
                   vFileReqPath = searchFile(vFileResArch) 
                   vFileReqErrPath = searchFile(vFileResArchErr)
                   vMyWorkDir = substring(vFileReqPath,1,index(vFileReqPath,vFileResArch) - 1)
                   vFolderPath  = vMyWorkDir + iCashFolder   
                   vFileArh = vFolderPath + vDirDelim + vFileResArch              
                   .
               
               /* перекладываем файл в папку архивов */                         
               copy-lob from file(vFileReqPath) to file(vFileArh) no-error.   
               if error-status:error then do:
                   return error "Ошибка записи файла в папку архивов".
               end.                        
               /* Сохраняем время */
               run SaveArchDate (iCashNum, ttfiles-inf.timestamp).
               /* удаляем временные файлы */                 
               run DelTmpFiles (substitute("&2&1&3",
                                           {&delim-par},vFileReqErrPath,vFileReqPath)).                                    
            end.    
       end.            
    END. 
    /* удаляем временные файлы */
    run DelTmpFiles (substitute("&2&1&3",
                                {&delim-par},vFileResult,vFileResultErr)).                 
end procedure.  

/* сохранение времени последней загрузки */
procedure SaveArchDate.
    define input parameter iCashNum   as character no-undo.
    define input parameter iTimeStamp as character no-undo.
    
    def buffer buf_code for ub.code.
    
    do transaction:
       find first buf_code exclusive-lock where 
                  buf_code.parent eq "GisMt"
              and buf_code.code   eq substitute("ArchDate:&1",iCashNum)
         no-wait no-error.
       if avail buf_code then 
          buf_code.CodeValue = ttfiles-inf.timestamp no-error.
       else if not ambiguous buf_code then do:
          /* создаем верхний уровень, если его нет */
          FIND FIRST buf_code WHERE buf_code.parent EQ ""
                                AND buf_code.code   EQ "GisMt"
          NO-LOCK NO-ERROR.
          IF NOT AVAILABLE buf_code THEN DO:
            CREATE buf_code.
            ASSIGN
               buf_code.parent = ""
               buf_code.code = "GisMt"
               buf_code.codename = "Онлайн проверка КМ"
               .
            RELEASE buf_code NO-ERROR.   
          END.
          create buf_code.
          assign
             buf_code.parent = "GisMt"
             buf_code.code = substitute("ArchDate:&1",iCashNum)
             buf_code.codename = substitute("Время последнего загруженного архива с кассы № &1 (unixtime)", iCashNum)
             buf_code.CodeValue = ttfiles-inf.timestamp
          .
          release buf_code no-error.
       end.      
    end.    
end procedure.  

/* Удаление временных файлов */
procedure DelTmpFiles.
   define input param iListFile as char no-undo.
   def var vCount as int no-undo.
   def var vFileName as char no-undo.
   
   if not session:debug-alert then      
   do vCount = 1 to num-entries(iListFile,{&delim-par}):    
      vFileName = entry(vCount,iListFile,{&delim-par}).
      if vFileName <> ""  then vFileName = searchFile(vFileName).               
      if vFileName <> "" and vFileName <> ?
         then os-delete silent value(vFileName)     no-error.                 
   end.
   
end procedure.