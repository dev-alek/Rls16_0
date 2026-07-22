/*
$Revision:$
$Author:$
$Date:$
$Workfile:$
$Archive:$

Автор: Рубан Дмитрий Андреевич 
Дата создания: 16 мая 2022 г.
Author:  Ruban Dmitriy Andreevich
Creation date: 16 мая 2022 г.
Modified: Rostovtsev Aleksandr 03/07/2023
Modified: Belova Marina 25/10/2023

*/

USING Progress.Lang.*.
USING ibs.th.skt.Commands.*.
USING ibs.th.skt.ControlledClients.marking.sts.cash.
USING ibs.th.skt.Adapters.LogWrite.
USING ibs.th.gbl.propmap.
USING ibs.th.gbl.sys.objsrv.
USING ibs.th.gbl.sys.objth.
block-level on error undo, throw.
/*using ibs.th.skt.ControlledClients.GisMtCDN.*/

CLASS ibs.th.skt.ControlledClients.marking INHERITS ICommandProc: 
  DEFINE OVERRIDE PUBLIC PROPERTY vss-revision    AS CHARACTER NO-UNDO INIT "$Revision:$":U GET .
  DEFINE OVERRIDE PUBLIC PROPERTY vss-author      AS CHARACTER NO-UNDO INIT "$Author:$":U GET.
  DEFINE OVERRIDE PUBLIC PROPERTY vss-date        AS CHARACTER NO-UNDO INIT "$Date:$":U GET.
  DEFINE OVERRIDE PUBLIC PROPERTY vss-workfile    AS CHARACTER NO-UNDO INIT "$Workfile:$":U GET.
  DEFINE OVERRIDE PUBLIC PROPERTY vss-archive     AS CHARACTER NO-UNDO INIT "$Archive:$":U GET.
  DEFINE OVERRIDE PUBLIC PROPERTY vss-description AS CHARACTER NO-UNDO INIT "Обработчик запросов по маркам с кассы" GET.

  {cmp\str-glbl.i class}
  { cmp\library.i class}
  &scop CRLF chr(13) + chr(10)
  &scop HdEnd chr(13) + chr(10)  + chr(13) + chr(10)  
  DEFINE PRIVATE VARIABLE cashSts    AS CLASS cash     NO-UNDO.
  DEFINE PRIVATE VARIABLE answerFlag AS LOGICAL        NO-UNDO INIT FALSE.
  DEFINE PRIVATE VARIABLE thMarkSts  AS CLASS ibs.th.str.marking.sts.mark NO-UNDO.
  DEFINE PRIVATE VARIABLE EDOParSec AS CLASS ibs.th.gbl.env.prmtrs.edo .
  /*define private variable thGisMtCdn as class GisMtCDN no-undo .*/
  DEFINE VARIABLE mAsyncHelper AS CLASS ibs.th.file.AsyncHelperth  NO-UNDO.

  DEFINE PRIVATE VARIABLE cash      AS CHARACTER NO-UNDO.
  DEFINE PRIVATE VARIABLE shift_id  AS CHARACTER NO-UNDO.
  DEFINE PRIVATE VARIABLE chk_id    AS CHARACTER NO-UNDO.
  DEFINE PRIVATE VARIABLE cntx_id   AS CHARACTER NO-UNDO.
  DEFINE PRIVATE VARIABLE mark      AS CHARACTER NO-UNDO.
  DEFINE PRIVATE VARIABLE action    AS CHARACTER NO-UNDO.
  DEFINE PRIVATE VARIABLE shift_tbeg AS DATE NO-UNDO.
  DEFINE PRIVATE VARIABLE shift_num  AS INTEGER NO-UNDO.
  DEFINE PRIVATE VARIABLE statusPOS  AS INTEGER NO-UNDO.
  DEFINE PRIVATE VARIABLE isCheckedOffline  AS LOGICAL NO-UNDO.
  
  DEFINE PRIVATE VARIABLE mMarkOrig     AS CHARACTER NO-UNDO.
  DEFINE PRIVATE VARIABLE mCheckSts     AS INTEGER   NO-UNDO.
  DEFINE PRIVATE VARIABLE mCheckStsOff  AS INTEGER   NO-UNDO.
  DEFINE PRIVATE VARIABLE mCheckStsSave AS INTEGER   NO-UNDO.
  DEFINE PRIVATE VARIABLE mReqId        AS CHARACTER NO-UNDO. 
  DEFINE PRIVATE VARIABLE mReqTimestamp AS CHARACTER NO-UNDO.
  DEFINE PRIVATE VARIABLE mInst         AS CHARACTER NO-UNDO. 
  DEFINE PRIVATE VARIABLE mVersion      AS CHARACTER NO-UNDO.
  DEFINE PRIVATE VARIABLE mCheckGisMT   AS INTEGER NO-UNDO. /* 0 - проверки не было, 1 - проверка была, 2 - аварийная ситуация */  
  DEFINE PRIVATE VARIABLE mSaveOnlineResult AS LOGICAL NO-UNDO.
  
    
  DEF STREAM out_s.
  DEF STREAM out_data.
  
  DEFINE TEMP-TABLE ttmark-body NO-UNDO    
     XML-NODE-NAME "body"
     FIELD code            AS INT
     FIELD error-1         AS CHAR XML-NODE-NAME "error"
     FIELD requestid       AS CHAR
     FIELD status-1        AS CHAR XML-NODE-NAME "status"
     FIELD reqid           AS CHAR
     FIELD reqtimestamp    AS INT64
     FIELD timestamp       AS CHAR
     .
  DEFINE TEMP-TABLE ttmark-check NO-UNDO    
     XML-NODE-NAME "codes"
     FIELD cis             AS CHAR
     FIELD printView       AS CHAR
     FIELD gtin            AS CHAR
     FIELD verified        AS LOGICAL
     FIELD found           AS LOGICAL
     FIELD realizable      AS LOGICAL
     FIELD utilised        AS LOGICAL 
     FIELD isBlocked       AS LOGICAL 
     FIELD productionDate  AS CHAR
     FIELD isOwner         AS LOGICAL 
     FIELD errorCode       AS INT 
     FIELD isTracking      AS LOGICAL 
     FIELD sold            AS LOGICAL
     FIELD packageType     AS CHAR
     FIELD producerInn     AS CHAR
     FIELD grayZone        AS LOGICAL
     FIELD mrp             AS INT
     FIELD expireDate      AS DATETIME-TZ
     .
  /* таблица имен временных файлов, которые нужно почистить */
  DEFINE TEMP-TABLE tt-file-name NO-UNDO
     FIELD tmpFileName AS CHAR
     FIELD ofline AS LOG INIT NO
     INDEX tmpFileName tmpFileName
     INDEX ofline ofline.
     
  /* ответ от ЛМ ЧЗ */   
  DEFINE TEMP-TABLE ttlocal-mark  no-undo serialize-name  "results"    
   FIELD reqId        AS CHAR
   FIELD reqTimestamp AS INT64   
   FIELD inst         AS CHAR
   FIELD version      AS CHAR
   FIELD description  AS CHAR
   FIELD code         AS INT64 
   FIELD errorCode    AS INT64
   FIELD reason       AS CHAR
   .
  DEFINE TEMP-TABLE ttlocal-mark-code  no-undo serialize-name  "codes"    
   FIELD code-reqid   AS RECID   
   FIELD isBlocked    AS LOG INIT NO
   FIELD sold         AS LOG INIT NO
   FIELD gtin         AS CHAR 
   FIELD cis          AS CHAR
   FIELD mrp          AS CHAR
   INDEX reqidpar code-reqid 
   .  
         
  DEFINE DATASET gismt-mark-body  XML-NODE-NAME "bodys" FOR ttmark-body.
  DEFINE DATASET gismt-mark-codes XML-NODE-NAME "body"  FOR ttmark-check.
  DEFINE DATASET gismt-local-mark SERIALIZE-HIDDEN  for ttlocal-mark, ttlocal-mark-code 
     PARENT-ID-RELATION FOR ttlocal-mark, ttlocal-mark-code PARENT-ID-FIELD code-reqid .

  DEFINE PUBLIC PROPERTY SomeStr AS LONGCHAR NO-UNDO /* сюда писать если что-то отправить*/
    GET.
    SET.

  {utl/gtin.i class}
  { utl/search.i  class }
  { ibs/th/skt/controlledclients/gismtprop.i def}

  CONSTRUCTOR PUBLIC marking (  ):
    SUPER ().    
    
    /* определяем настройки подключения к ГИС МТ */
    DEFINE BUFFER buf_sys-ctrl FOR ub.sys-ctrl .
    DEFINE VARIABLE vRetProp AS CHARACTER NO-UNDO.
    DEFINE VARIABLE vCdnAdr AS CHARACTER NO-UNDO.
    
    FIND FIRST buf_sys-ctrl NO-LOCK NO-ERROR.
    IF AVAILABLE buf_sys-ctrl AND buf_sys-ctrl.db-num <> 0 
    THEN DO:
       dbgPrint("marking.log", SUBSTITUTE("База &1 номер: &2", "{&db}", buf_sys-ctrl.db-num)).
       vRetProp = get-gismt-prop ({&db},
                                  buf_sys-ctrl.db-num) NO-ERROR.                            
    END.
    ELSE DO:
       dbgPrint("marking.log", "Не определена БД").
    END.
    cashSts =  NEW cash().
  END.

  METHOD PUBLIC VOID hndler (req AS CLASS ibs.th.skt.Commands.iRequest):
    DEFINE VARIABLE vLC       AS LONGCHAR  NO-UNDO.
    DEFINE VARIABLE ii        AS INTEGER   NO-UNDO.
    DEFINE VARIABLE n         AS INTEGER   NO-UNDO.
    DEFINE VARIABLE mark-short AS CHARACTER NO-UNDO.
    DEFINE VARIABLE par       AS CHARACTER NO-UNDO.
    DEFINE VARIABLE val       AS CHARACTER NO-UNDO.
    DEFINE VARIABLE km        AS CHARACTER NO-UNDO.

    DEFINE BUFFER buf_marking FOR ub.marking.
    DEFINE BUFFER buf_marking-l FOR ub.marking-lines.

    DEFINE VARIABLE newSts    AS INTEGER   NO-UNDO.
    DEFINE VARIABLE obj-code  AS INTEGER NO-UNDO. 
    DEFINE VARIABLE gdsCode   AS INTEGER NO-UNDO. 
    DEFINE VARIABLE canSaleReturnedGoods AS LOGICAL NO-UNDO INIT FALSE.
    
    DEFINE VARIABLE listActions           AS CHARACTER NO-UNDO.
    DEFINE VARIABLE listActionsByMark     AS CHARACTER NO-UNDO.
    DEFINE VARIABLE listActionsUnlock     AS CHARACTER NO-UNDO.
    DEFINE VARIABLE listStatusesForSale   AS CHARACTER NO-UNDO.
    DEFINE VARIABLE listStatusesForSaleWithReturn AS CHARACTER NO-UNDO.
    DEFINE VARIABLE listStatusesForReturn AS CHARACTER NO-UNDO.    
    DEFINE VARIABLE vAccMarkCheck AS CHARACTER NO-UNDO.
    DEFINE VARIABLE vAccMarkCheckOff AS CHARACTER NO-UNDO.  
    DEFINE VARIABLE vCheckLocalMark  AS LOGICAl NO-UNDO INIT FALSE. /* признак запуска offline-проверки */

    ASSIGN
      mCheckSts = 1
      mReqId        = ""
      mReqTimeStamp = ""
      mInst         = ""
      mVersion      = ""
      answerFlag = FALSE
      cash       = ""      
      shift_id   = ""
      chk_id     = ""
      cntx_id    = ""
      mark       = ""
      action     = ""
      shift_tbeg = ?
      shift_num  = 0 
      gismt-WaitTimePlus = 0
      statusPOS = ?
      mSaveOnlineResult = no
    .
    
    

    thMarkSts = ObjSrv:Env:Marking:Sts:Mark.

    fix-codepage(vLC) = "UTF-8".

    LogWrite:LogStr = SUBSTITUTE("Авторизация маркированной продукции &1",
      req:QueryPar).

    ASSIGN
      listActionsByMark = SUBSTITUTE("&1,&2", 
        cashSts:SaleLock:NameProp, 
        cashSts:ReturnLock:NameProp 
      )
      listActionsUnlock = cashSts:Unlock:NameProp
      listActions = SUBSTITUTE("&1,&2,&3,&4", 
        listActionsByMark, 
        listActionsUnlock,
        cashSts:UnlockAll:NameProp,
        cashSts:Commit:NameProp
      )
    .

    n = NUM-ENTRIES (req:QueryPar, "&").
/*    if n ne 4 and n ne 3                                                         */
/*      then                                                                       */
/*    do:                                                                          */
/*      vLC = chr(123) + '"server_error":"Неверные параметры запроса."' + chr(125).*/
/*      sendContent(vLC).                                                          */
/*      return.                                                                    */
/*    end.                                                                         */
    DO ii = 1 TO n:
      ASSIGN
        par = ENTRY (1, ENTRY (ii, req:QueryPar, "&"), "=")
        val = ENTRY (2, ENTRY (ii, req:QueryPar, "&"), "=")
    no-error.
      IF ERROR-STATUS:ERROR
        THEN 
      DO:
        vLC = CHR(123) + '"server_error":"Неверные параметры запроса."' + chr(125).
        sendContent(vLC).
        RETURN.        
      END.
      CASE par:
        WHEN "cash" THEN 
          DO:
            cash = val.
          END.
        WHEN "shift_id" THEN 
          DO:
            shift_id = val.
          END.
        WHEN "check" THEN 
          DO:
            chk_id = val.
          END.
        WHEN "mark" THEN 
          DO:
            mMarkOrig = val.
            mark = percentDecoding (val).
          END.
        WHEN "context" THEN 
          DO:
            cntx_id = val.
          END.
        WHEN "set" THEN 
          DO:
            IF LOOKUP (val,listActions) = 0
              THEN 
            DO:
              vLC = CHR(123) + substitute('"server_error":"Неверный тип &1 параметра set."', val) + chr(125).
              sendContent(vLC).
              RETURN.
            END. 
            action = val.
          END.
        WHEN "shift_tbeg" THEN 
          DO:
            shift_tbeg = DATE (INTEGER (SUBSTRING (val, 03, 2)), INTEGER (SUBSTRING (val, 01, 2)), INTEGER (SUBSTRING (val, 05, 4))) NO-ERROR.
          END.
        WHEN "shift_num" THEN 
          DO:
            shift_num = int (val) NO-ERROR.
          END.
        WHEN "StatusPos" THEN 
          DO:
            statusPOS = int (val) NO-ERROR.
          END.
        WHEN "isCheckedOffline" THEN 
          DO:
            isCheckedOffline = logical (val) NO-ERROR.
          END.          
      END CASE.
    END.
    IF cash = "" OR action = ""
      THEN 
    DO:
      vLC = CHR(123) + substitute('"server_error":"Неверные параметры запроса."') + chr(125).
      sendContent(vLC).
      RETURN.
    END.

    /* получаем по номеру кассы номер магазина */
    /* TODO: обработать привязку к разным магазинам касс с одинаковым номером */
    obj-code = getObject(INTEGER(cash)).
    IF obj-code = ? THEN
    DO:
      vLC = CHR(123) + substitute('"server_error":"Не удалось определить магазин по кассе &1."', cash) + chr(125).
      sendContent(vLC).
      RETURN.
    END.
    EDOParSec = ObjSrv:Env:ParametrsOfSection:GetSectionEDO({&shop}, obj-code).

    CASE TRUE:
      WHEN CAN-DO(listActionsByMark,action) OR (CAN-DO(listActionsUnlock,action) AND mark <> "") THEN 
      DO:            /* действие по марке */
        IF mark = "" THEN DO:
          vLC = CHR(123) + substitute('"server_error":"Неверные параметры запроса. Не заполнен mark."') + chr(125).
          sendContent(vLC).
          RETURN.
        END.
  
        mark-short = GetCodeIdent(mark).
        IF mark-short = "" OR mark-short = ? THEN DO:
          vLC = CHR(123) + substitute('"server_error":"Неверные параметры запроса. Некорректный код марки."') + chr(125).
          sendContent(vLC).
          RETURN.
        END.
        
        FIND FIRST buf_marking EXCLUSIVE-LOCK WHERE buf_marking.mark BEGINS mark-short NO-WAIT NO-ERROR.
        IF action = cashSts:SaleLock:NameProp THEN 
        DO:
           assign
              mCheckGisMT = 0
              mTypeMark = ""
              .
           ChekTypeMarkByDm(mark).
           
           /* если на кассе уже была проверка онлайн/офлайн */ 
           if statusPOS <> ? then do:
               dbgPrint("marking.log", SUBSTITUTE("Проверка ГИС МТ была на кассе. Статус: &1 Проверка в ЛМЧЗ &2", 
                                                  statusPOS, 
                                                  isCheckedOffline
                                                  )).
               assign
                  vCheckLocalMark = isCheckedOffline 
                  mCheckSts = statusPOS
                  .
               /* была проверка онлайн */
               if not isCheckedOffline
               then do:                   
                   mCheckGisMT = 1.
                   /* проверка онлайн не пройдена */
                   if mCheckSts = 0 then
                      vAccMarkCheck = "Запрет онлайн".   
                   mCheckStsSave = mCheckSts .                          
               end.     
               /* была проверка офлайн */
               else do:               
                   /* проверка офлайн не пройдена */
                   if mCheckSts = 0 then do:
                      /*vAccMarkCheck = vAccMarkCheck + "Снимите с продажи и передайте товар управляющему/старшему смены".*/
                      vLC = getJson(0, vAccMarkCheck, mark).
                      sendContent(vLC).
                      RETURN.
                   end.
                   /* проверка офлайн на кассе пройдена */
                   IF AVAIL buf_marking AND buf_marking.online-result = 0 
                   THEN DO:
                       vAccMarkCheck = "Выполнить текущую онлайн-проверку не удалось. Продажа заблокирована по результату ранее выполненной проверки.".
                       vLC = getJson(0, vAccMarkCheck, mark).
                       sendContent(vLC).
                       RETURN.
                   END.          
               end.
               /* проверяем срок годности */
               if mCheckSts = 1 or mCheckSts = 2 
               then do:
                   /* Проверяем срок годности */
                   vAccMarkCheckOff = ChekExpirationDate({&shop},obj-code,buffer buf_marking).                       
                   vAccMarkCheck = vAccMarkCheckOff. 
               end.
               dbgPrint("marking.log", SUBSTITUTE("Результат после обработки статуса с кассы: Комментарий: &1 Статус: &2 Проверка в ЛМЧЗ &3 mCheckGisMT &4 ", 
                                                  vAccMarkCheck, 
                                                  mCheckSts,
                                                  vCheckLocalMark,
                                                  mCheckGisMT
                                                  )).
           end.    
           else do:
               vAccMarkCheck = ChekAccessMark({&shop},obj-code,mark,mark-short).           
               dbgPrint("marking.log", SUBSTITUTE("Проверка ГИС МТ: &1 Статус: &2 mReqId &3 mReqTimeStamp &4 mCheckGisMT &5", 
                                                  vAccMarkCheck, 
                                                  mCheckSts,
                                                  mReqId,
                                                  mReqTimeStamp,
                                                  mCheckGisMT)).
                                              
               IF mCheckSts = 0 OR 
                  mCheckSts = 3 /* faund = false */
               THEN DO:
                  /* если марки нет в ГИС МТ или не прошла проверку в ГИС МТ, то ее создадим ниже, но продавать нельзя */
                  vAccMarkCheck = vAccMarkCheck + "Снимите с продажи и передайте товар управляющему/старшему смены".
               END.
               /* Если прошло более 72ч с момента аварии ГИС МТ */
               IF mCheckSts = 4 THEN DO:
                  vLC = getJson(0, vAccMarkCheck, mark).
                  sendContent(vLC).
                  RETURN.
               END.     
               /* если марку не удалось проверить онлайн */
               IF (mCheckSts = 2 AND mCheckGisMT <> 1) OR mCheckGisMT = 2 THEN DO:
                  /* проверим значение online-result марки (? - если марки в ТН нет)*/
                  dbgPrint("marking.log", SUBSTITUTE("Считываем online-result: &1.", 
                                                    IF NOT AVAIL buf_marking THEN "marking не найдена"
                                                    ELSE STRING(buf_marking.online-result))).
                  IF AVAIL buf_marking AND buf_marking.online-result = 0 
                  THEN DO:
                      vAccMarkCheck = "Выполнить текущую онлайн-проверку не удалось. Продажа заблокирована по результату ранее выполненной проверки. Снимите с продажи и передайте товар управляющему/старшему смены".
                      vLC = getJson(0, vAccMarkCheck, mark).
                      sendContent(vLC).
                      RETURN.
                  END.
                  ELSE DO:
                      /* Проверяем офлайн */
                      vAccMarkCheckOff = ChekLocalMark(mark-short).
                      vCheckLocalMark = TRUE.
                      /* Проверяем срок годности по дате из 1С */
                      if vAccMarkCheckOff = "" and 
                         mCheckSts = 2 and 
                         available buf_marking 
                      then 
                         vAccMarkCheckOff = ChekExpirationDate({&shop},obj-code,buffer buf_marking).
                         
                      if vAccMarkCheckOff <> "" and vAccMarkCheck begins "Сообщите" 
                      then vAccMarkCheck = vAccMarkCheckOff + " Также с" + substring(vAccMarkCheck,2). 
                      else vAccMarkCheck = vAccMarkCheckOff + vAccMarkCheck.                                    
                  END.
              END.   
           END.                 
        END.
  
        IF NOT AVAILABLE (buf_marking) THEN 
        DO:      /* марка не найдена в БД TH */
          IF LOCKED buf_marking THEN DO:
             vLC = getJson(0, "С маркой " + mark-short + " уже работают. ", mark).
             sendContent(vLC).
             RETURN.
          END.   
          CASE action:
            WHEN cashSts:SaleLock:NameProp THEN
            DO:
              createMark(mark-short, buffer buf_marking).
              IF NOT vCheckLocalMark 
                 AND AVAILABLE buf_marking
              THEN DO:   /* online-result устанавливаем, если offline-проверка не запускалась */
                setOnlineResult(BUFFER buf_marking).
              END.
              IF mCheckSts = 0 OR 
                 mCheckSts = 3 /* faund = false */
              THEN DO:
                 vLC = getJson(0, vAccMarkCheck, mark).
                 sendContent(vLC).
                 RETURN.
              END. 
              IF AVAILABLE buf_marking THEN 
                answerFlag = TRUE.
              vLC = setMarkStatus (
                thMarkSts:SaleWaitLock:KeyIntDB, 
                "cash:" +  cash + ":" + "context:" + cntx_id,
                IF mCheckSts = 2 THEN vAccMarkCheck ELSE cashSts:SaleLock:Label_,
                cashSts:NotAccessible:Label_,
                buffer buf_marking).
            END.
            WHEN cashSts:ReturnLock:NameProp THEN 
            DO:
              createMark(mark-short, buffer buf_marking).
              IF AVAILABLE buf_marking THEN 
                answerFlag = TRUE.
              vLC = setMarkStatus (
                thMarkSts:ReturnWaitLock:KeyIntDB, 
                "cash:" +  cash + ":" + "context:" + cntx_id,
                cashSts:ReturnLock:Label_,
                cashSts:NotAccessibleRet:Label_,
                buffer buf_marking).
            END.
            OTHERWISE 
            DO:
              vLC = getJson(0, "Операция невозможна. Марка не найдена.", mark).
            END.
          END CASE.
        END.
        ELSE 
        DO:      /* марка найдена */
          IF  action = cashSts:SaleLock:NameProp /* если продажа */ 
          AND NOT vCheckLocalMark THEN           /* и offline-проверка не запускалась, то устанавливаем online-result */
            setOnlineResult(BUFFER buf_marking).

          IF action = cashSts:SaleLock:NameProp AND 
             (mCheckSts = 0 OR mCheckSts = 3) 
          THEN DO:
                 vLC = getJson(0, vAccMarkCheck, mark).
                 sendContent(vLC).
                 RETURN.
          END. 
              
          IF (action = cashSts:SaleLock:NameProp OR action = cashSts:ReturnLock:NameProp) 
             AND (buf_marking.sts = thMarkSts:SaleWaitLock:KeyIntDB OR buf_marking.sts = thMarkSts:ReturnWaitLock:KeyIntDB)
             AND buf_marking.loc-key BEGINS "cash"
          THEN DO:
            /* марка уже заблокирована для продажи или возврата */
            vLC = getJson(0, SUBSTITUTE (
              "Операция невозможна. Статус марки - &1 на кассе &2", 
              thMarkSts:GetLabel(buf_marking.sts), 
              TRIM(ENTRY(2, buf_marking.loc-key, ":"))), 
              mark
            ).
            sendContent(vLC).
            RETURN.
          END.

          /* получаем тип марки и определяем значение параметра «Разрешена продажа возвращенных товаров» по типу */
          ChekTypeMarkByDm(mark).
          IF mTypeMark <> "" THEN
            canSaleReturnedGoods = EDOParSec:GetIsSaleReturnForType(mTypeMark).
  
          ASSIGN
            listStatusesForSale = SUBSTITUTE("&1,&2",thMarkSts:Checked_:KeyIntDB,thMarkSts:FreeZone:KeyIntDB)
            listStatusesForSaleWithReturn = SUBSTITUTE("&1,&2",listStatusesForSale,thMarkSts:ReturnLock:KeyIntDB)
            listStatusesForReturn = SUBSTITUTE("&1,&2",listStatusesForSale,thMarkSts:SaleLock:KeyIntDB)
          .
  
          CASE action:
            WHEN cashSts:SaleLock:NameProp THEN 
            DO:
              IF CAN-DO(
                IF canSaleReturnedGoods THEN listStatusesForSaleWithReturn ELSE listStatusesForSale, 
                STRING(buf_marking.sts) 
              ) THEN 
              DO:
                answerFlag = TRUE.
              END.
              vLC = setMarkStatus (
                thMarkSts:SaleWaitLock:KeyIntDB, 
                "cash:" +  cash + ":" + "context:" + cntx_id,
                IF mCheckSts = 2 THEN vAccMarkCheck ELSE cashSts:SaleLock:Label_,
                SUBSTITUTE ("Операция невозможна. Статус марки - &1.", thMarkSts:GetProp(buf_marking.sts):Label_),
                buffer buf_marking).
            END.
            WHEN cashSts:ReturnLock:NameProp THEN 
            DO: 
              IF CAN-DO(listStatusesForReturn, STRING(buf_marking.sts)) THEN 
              DO:
                answerFlag = TRUE.
              END.
              vLC = setMarkStatus (
                thMarkSts:ReturnWaitLock:KeyIntDB, 
                "cash:" +  cash + ":" + "context:" + cntx_id,
                cashSts:ReturnLock:Label_,
                SUBSTITUTE ("Операция невозможна. Статус марки - &1.", thMarkSts:GetProp(buf_marking.sts):Label_),
                buffer buf_marking).
            END.
            WHEN cashSts:Unlock:NameProp THEN 
            DO:
              IF buf_marking.loc-key = "" OR buf_marking.loc-key BEGINS "cash:" + cash
              THEN DO:
                answerFlag = TRUE.
                vLC = setMarkStatus (
                  IF buf_marking.sts = thMarkSts:SaleWaitLock:KeyIntDB THEN thMarkSts:FreeZone:KeyIntDB ELSE thMarkSts:SaleLock:KeyIntDB,
                  "",
                  cashSts:Unlock:Label_,
                  SUBSTITUTE ("Операция невозможна. Статус марки - &1.", thMarkSts:GetProp(buf_marking.sts):Label_),
                  buffer buf_marking).
              END.
              ELSE DO:
                vLC = getJson(0, SUBSTITUTE ("Операция невозможна. Статус марки - &1.", thMarkSts:GetProp(buf_marking.sts):Label_), mark).
              END.
            END.
          END CASE.
        END.             /* марка найдена */
      END.
      WHEN CAN-DO(listActionsUnlock,action) AND mark = "" THEN
      DO:
        answerFlag = TRUE.
        IF cntx_id = "" THEN
          vLC = unlockMarks("cash:" +  cash).
        ELSE
          vLC = unlockMarks("cash:" +  cash + ":" + "context:" + cntx_id).
      END.
      WHEN action = cashSts:Commit:NameProp THEN 
      DO:
        answerFlag = TRUE.
        vLC = commitCheck().
      END.
      WHEN action = cashSts:UnlockAll:NameProp THEN 
      DO:
        answerFlag = TRUE.
        vLC = unlockMarks("cash:" +  cash).
      END.
    END CASE.
    sendContent(vLC).
    RETURN.
  END METHOD.

  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/

  METHOD PUBLIC CHARACTER percentDecoding(encode-str AS CHAR):
    DEF VAR ii         AS INT.
    DEF VAR decode-str AS CHAR.
    DEF VAR entry-str  AS CHAR.
    decode-str = ENTRY (1, encode-str, "%").
    DO ii = 2 TO NUM-ENTRIES (encode-str,"%"):
      entry-str = ENTRY (ii, encode-str, "%").
      decode-str = decode-str + (IF entry-str <> "" THEN STRING (HEX-DECODE (SUBSTRING (entry-str, 1, 2))) + substring (entry-str, 3, LENGTH (entry-str)) ELSE "%").
    END.      
    RETURN decode-str.
  END METHOD.

  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/

  METHOD PRIVATE VOID sendContent(inLC AS LONGCHAR):
    DEFINE VARIABLE v-cont-length AS INTEGER NO-UNDO.
    inLC = inLC + {&CRLF}.
    v-cont-length = LENGTH(inLC,"RAW":U).
    SomeStr = SUBSTITUTE("HTTP/1.1 200 OK&1Server: 4GL&1Content-Type: text/html; charset=UTF-8&1Content-Length: &3&2&4",{&CRLF},{&HdEnd},STRING(v-cont-length),inLC).
    RETURN.
  END METHOD.

  METHOD PRIVATE CHARACTER getJson(stsInt AS INT, msg AS CHAR, mark AS CHAR):
    DEF VAR json-str AS CHAR NO-UNDO.
    mark = REPLACE (mark, '\', '\\').
    mark = REPLACE (mark, '"', '\"').
    
    /* Онлайн-проверка КМ не была выполнена в части срока годности */
    IF stsInt = 1 AND mCheckSts = 2 
    THEN stsInt = 2.
      
    json-str = CHR(123) + substitute ('"status":&1,"comment":"&2","reqid":"&3","reqtimestamp":"&4","inst":"&5","ver":"&6"', 
                                       stsInt, msg, mReqId, mReqTimestamp, mInst, mVersion) 
               + CHR(125).
    RETURN json-str.
  END.

  METHOD PRIVATE CHARACTER setMarkStatus (
    state AS INTEGER, 
    loc-key AS CHARACTER, 
    msgOk   AS CHARACTER, 
    msgError AS CHARACTER, 
    buffer buf_marking FOR ub.marking
  ):
    IF answerFlag THEN 
    DO:
      ASSIGN  
        buf_marking.loc-key = loc-key
        buf_marking.sts = state
        buf_marking.last-change = NOW
      .
      ObjSrv:Lib:MarkingTree:UnGroupMark(buf_marking.mark).
      ObjSrv:Lib:MarkingTree:LockChkChildeMark(buf_marking.mark).
      RETURN getJson(1, msgOk , buf_marking.mark).
    END.
    RETURN getJson(0, msgError, buf_marking.mark).
  END METHOD.

  METHOD PRIVATE VOID createMark (
    mark AS CHARACTER, 
    buffer buf_marking FOR ub.marking
  ):
    CREATE buf_marking.
    ASSIGN 
      buf_marking.mark    = mark
      buf_marking.sts     = thMarkSts:FreeZone:KeyIntDB
    .
  END METHOD.

  METHOD PRIVATE VOID setShift (
    mark AS CHARACTER, 
    shiftBeg AS DATE,
    shiftNum AS INTEGER
  ):
    DEFINE BUFFER buf_marking-attr FOR ub.marking-attr.

    IF shiftBeg NE ?
    THEN DO:
      FIND FIRST buf_marking-attr WHERE buf_marking-attr.mark = mark AND buf_marking-attr.attr-code = "shift-date" NO-ERROR.
      IF NOT AVAILABLE buf_marking-attr
      THEN DO:
        CREATE buf_marking-attr.
        buf_marking-attr.mark = mark.
        buf_marking-attr.attr-code = "shift-date".
      END.
      buf_marking-attr.attr-value = STRING (shiftBeg).
    END.
    IF shiftNum NE ?
    THEN DO:
      FIND FIRST buf_marking-attr WHERE buf_marking-attr.mark = mark AND buf_marking-attr.attr-code = "shift-num" NO-ERROR.
      IF NOT AVAILABLE buf_marking-attr
      THEN DO:
        CREATE buf_marking-attr.
        buf_marking-attr.mark = mark.
        buf_marking-attr.attr-code = "shift-num".
      END.
      buf_marking-attr.attr-value = STRING (shiftNum).
    END.
  END METHOD.

  METHOD PRIVATE INTEGER getObject (
    cash AS INTEGER
  ):
    DEFINE BUFFER buf_cash-desk FOR ub.cash-desk.

    FIND buf_cash-desk WHERE buf_cash-desk.cash-num = cash NO-LOCK NO-ERROR.
    RETURN IF AVAILABLE buf_cash-desk THEN buf_cash-desk.obj-code ELSE ?.
  END METHOD.
 
  METHOD OVERRIDE PUBLIC VOID Execute_(req AS CLASS IRequest, resp AS CLASS IResponse):
      
  END METHOD.

  METHOD PRIVATE CHARACTER unlockMarks (
    loc-key AS CHARACTER
  ):
    DEFINE VARIABLE newSts    AS INTEGER   NO-UNDO.
    DEFINE BUFFER buf_marking FOR ub.marking.
    DEFINE BUFFER buf_marking-l FOR ub.marking-lines.
    
    /* сначала обрабатываем упаковки (блоки) */
    REPEAT PRESELECT EACH buf_marking EXCLUSIVE-LOCK WHERE 
             buf_marking.loc-key BEGINS loc-key
             AND lookup("chk_num",buf_marking.loc-key,":") = 0
             :
      FIND NEXT buf_marking.
             
      IF ObjSrv:Lib:MarkingTree:LevelDown(buf_marking.mark)
      THEN DO:       
          setMarkStatus (
            IF buf_marking.sts = thMarkSts:SaleWaitLock:KeyIntDB THEN thMarkSts:FreeZone:KeyIntDB ELSE thMarkSts:SaleLock:KeyIntDB,
            "",
            "",
            "",
            buffer buf_marking)
          .
          setShift(buf_marking.mark, shift_tbeg, shift_num).
      END.
    END.
    /* обрабатываем все что осталось */
    REPEAT PRESELECT EACH buf_marking EXCLUSIVE-LOCK WHERE 
             buf_marking.loc-key BEGINS loc-key
             AND lookup("chk_num",buf_marking.loc-key,":") = 0
             :
      FIND NEXT buf_marking.
      setMarkStatus (
        IF buf_marking.sts = thMarkSts:SaleWaitLock:KeyIntDB THEN thMarkSts:FreeZone:KeyIntDB ELSE thMarkSts:SaleLock:KeyIntDB,
        "",
        "",
        "",
        buffer buf_marking)
      .
      setShift(buf_marking.mark, shift_tbeg, shift_num).
    END.
    RETURN getJson(1, cashSts:UnlockAll:Label_, mark).
  END METHOD.

  METHOD PRIVATE CHARACTER commitCheck ():
    DEFINE BUFFER buf_marking FOR ub.marking.
    DEFINE VARIABLE vCnt AS INT NO-UNDO.
    
    vCnt = 0. 
    /* сначала обрабатываем упаковки (блоки) */
    REPEAT PRESELECT EACH buf_marking EXCLUSIVE-LOCK WHERE buf_marking.loc-key = "cash:" +  cash + ":" + "context:" + cntx_id:
      FIND NEXT buf_marking.
      IF ObjSrv:Lib:MarkingTree:LevelDown(buf_marking.mark)
      THEN DO: 
         setMarkStatus (
            IF buf_marking.sts = thMarkSts:SaleWaitLock:KeyIntDB THEN thMarkSts:SaleLock:KeyIntDB ELSE thMarkSts:ReturnLock:KeyIntDB, 
            "cash:" +  cash + ":" + "context:" + cntx_id + ":" + "chk_num:" + chk_id,
            "",
            "",
            buffer buf_marking)
         .
         setShift(buf_marking.mark, shift_tbeg, shift_num).
         vCnt = vCnt + 1.
      END.
    END.
    
    /* обрабатываем все что осталось */
    REPEAT PRESELECT EACH buf_marking EXCLUSIVE-LOCK WHERE buf_marking.loc-key = "cash:" +  cash + ":" + "context:" + cntx_id:
      FIND NEXT buf_marking.
      setMarkStatus (
        IF buf_marking.sts = thMarkSts:SaleWaitLock:KeyIntDB THEN thMarkSts:SaleLock:KeyIntDB ELSE thMarkSts:ReturnLock:KeyIntDB, 
        "cash:" +  cash + ":" + "context:" + cntx_id + ":" + "chk_num:" + chk_id,
        "",
        "",
        buffer buf_marking)
      .
      setShift(buf_marking.mark, shift_tbeg, shift_num).
      vCnt = vCnt + 1.
    END.
    
    RETURN IF vCnt = 0
      THEN getJson(0, "По данной кассе не было маркированого товара", mark)
      ELSE getJson(1, cashSts:Commit:Label_ + " Зарезервировано кол-во " + string (vCnt), mark).
  END METHOD.
     
  /* Фиксация времени начала сбоя ГИС МТ */
  METHOD PRIVATE CHARACTER FixErrGisMT ():
     
    DEFINE VARIABLE vErrSts AS CHARACTER NO-UNDO.
    DEFINE VARIABLE vTimeBegErr AS DATETIME-TZ NO-UNDO.
    DEFINE VARIABLE vTimeAvail  AS INTEGER     NO-UNDO.
    
    DEFINE BUFFER buf_code FOR ub.code.
    
    ASSIGN
       mCheckSts = 2  
       vErrSts = ""
       .           
      
    fixerr:
    DO TRANSACTION ON ERROR UNDO, RETRY fixerr:        
       /* Проверяем, зафиксирован ли сбой онлайн-проверки */
       FIND FIRST buf_code WHERE buf_code.parent EQ "GisMt"
                             AND buf_code.code   EQ "GisMtErr"
          NO-LOCK NO-ERROR.
       IF NOT AVAILABLE buf_code 
       THEN DO:
           dbgPrint("marking.log", "Создаем новый справочник для фиксации времени сбоя онлайн-проверки КМ").          
          /* создаем верхний уровень, если его нет */
          FIND FIRST buf_code WHERE buf_code.parent EQ ""
                           AND buf_code.code   EQ "GisMt"
          NO-LOCK NO-ERROR.
          IF NOT AVAILABLE buf_code THEN DO:
            CREATE buf_code.
            ASSIGN
               buf_code.parent = ""
               buf_code.code = "GisMt"
               buf_code.codename = "Cбой онлайн-проверки КМ"
               .
            RELEASE buf_code NO-ERROR.   
          END.
          /* создаем запись с фиксацией времени ошибки */
          CREATE buf_code.
          ASSIGN
            buf_code.parent = "GisMt"
            buf_code.code = "GisMtErr"
            buf_code.codename = "Время сбоя онлайн-проверки КМ"
            buf_code.codevalue = STRING(NOW)
            .
          RELEASE buf_code NO-ERROR.                      
       END.
       ELSE DO:
          dbgPrint("marking.log", "Текущее временя сбоя ГИС МТ: " + buf_code.codevalue).            
          /* если ошибка уже была, смотрим сколько прошло времени */
          IF buf_code.codevalue > "" THEN DO:
             vTimeBegErr = DATETIME-TZ(buf_code.codevalue) NO-ERROR.
             IF gismt-MaxTime <> ? AND
                gismt-TimeFalStart <> ? AND 
                vTimeBegErr <> ?
             THEN DO:
                /* время максимального ожидания вышло */
                IF vTimeBegErr + gismt-MaxTime * 3600000 < NOW
                THEN DO:
                   ASSIGN
                      mCheckSts = 4 
                      vErrSts = "С момента начала сбоя онлайн-проверки прошло более " 
                                + string(gismt-MaxTime) 
                                + " часов, реализация маркированных товаров невозможна. "
                      .
                END.
                /* время максимального ожидания не вышло, но время когда надо начать предупреждать */
                ELSE IF vTimeBegErr + gismt-TimeFalStart * 3600000 <= NOW
                THEN DO:
                   ASSIGN
                      vTimeAvail = ROUND((vTimeBegErr + gismt-MaxTime * 3600000 - NOW) / 3600000,0)
                      vErrSts = "Сообщите управляющему, что до блокировки продаж маркированных товаров из-за недоступности Честного знака осталось: " 
                                + string(vTimeAvail) + " ч. "
                      .                      
                END.   
             END.                    
          END.          
          IF (buf_code.codevalue > "" AND vTimeBegErr = ?) 
           OR buf_code.codevalue = "" THEN 
          DO:
              /* новая фиксация ошибки */
              FIND FIRST buf_code WHERE buf_code.parent EQ "GisMt"
                           AND buf_code.code   EQ "GisMtErr"
              EXCLUSIVE-LOCK NO-WAIT NO-ERROR.
              IF AVAIL buf_code THEN 
              DO: 
                buf_code.codevalue = STRING(NOW).          
                dbgPrint("marking.log", "Фиксация времени сбоя ГИС МТ: " + buf_code.codevalue).
                RELEASE buf_code NO-ERROR.
                IF ERROR-STATUS:ERROR THEN 
                   dbgPrint("marking.log", "Ошибка фиксации времени сбоя ГИС МТ: " + ERROR-STATUS:GET-MESSAGE(1)).
              END.
              ELSE IF LOCKED buf_code THEN   
              DO:                        
                 dbgPrint("marking.log", "Ошибка фиксации времени сбоя ГИС МТ - запись заблокирована").
              END.   
          END.
       END.
    END.
    IF RETRY THEN DO:
        dbgPrint("marking.log", "Ошибка фиксации времени сбоя ГИС МТ").        
    END.
        
    RETURN vErrSts.
    
  END METHOD.   
  /*
  /* Фиксация времени начала сбоя ГИС МТ */
  METHOD PRIVATE CHARACTER CheckErrGisMT ():
     
    DEFINE VARIABLE vErrSts AS CHARACTER NO-UNDO.
    DEFINE VARIABLE vTimeBegErr AS DATETIME-TZ NO-UNDO.
    DEFINE VARIABLE vTimeAvail  AS INTEGER     NO-UNDO.
    
    DEFINE BUFFER buf_code FOR ub.code.
    
    ASSIGN
       mCheckSts = 2  
       vErrSts = ""
       .    
           
    /* Проверяем, зафиксирован ли сбой онлайн-проверки */    
    FIND FIRST buf_code WHERE buf_code.parent EQ "GisMt"
           AND buf_code.code   EQ "GisMtErr"
       EXCLUSIVE-LOCK NO-WAIT NO-ERROR.
    /* если ошибка уже была, смотрим сколько прошло времени */   
    IF AVAILABLE buf_code            
       AND buf_code.codevalue > "" 
    THEN DO:
       vTimeBegErr = DATETIME-TZ(buf_code.codevalue) NO-ERROR.
       IF gismt-MaxTime <> ? AND
          gismt-TimeFalStart <> ? AND 
          vTimeBegErr <> ?
       THEN DO:
          /* время максимального ожидания вышло */
          IF vTimeBegErr + gismt-MaxTime * 3600000 < NOW
          THEN DO:
              ASSIGN
                 mCheckSts = 4 
                 vErrSts = "С момента начала сбоя онлайн-проверки прошло более " 
                    + string(gismt-MaxTime) 
                    + " часов, реализация маркированных товаров невозможна. "
                 .
          END.
          /* время максимального ожидания не вышло, но время когда надо начать предупреждать */
          ELSE IF vTimeBegErr + gismt-TimeFalStart * 3600000 <= NOW
          THEN DO:
             ASSIGN
                vTimeAvail = ROUND((vTimeBegErr + gismt-MaxTime * 3600000 - NOW) / 3600000,0)
                vErrSts = "Сообщите управляющему/старшему смены, что до блокировки продаж маркированных товаров осталось: " 
                          + string(vTimeAvail) + " ч. "
             .
          END.   
       END.    
       ELSE IF vTimeBegErr = ? THEN buf_code.codevalue = STRING(NOW).   
    END.       
    
    RETURN vErrSts.
    
  END METHOD.   
  */
  
  /* Сброс ошибки недоступности ГИС МТ */
  METHOD PRIVATE VOID SetNoErrGisMT ():
     DEF BUFFER buf_code FOR ub.code.
      
      FIND FIRST buf_code WHERE 
                 buf_code.parent EQ "GisMt"
             AND buf_code.code   EQ "GisMtErr"
         NO-LOCK NO-ERROR.
      if avail buf_code and buf_code.codevalue <> "" then 
      do:         
          setnoerr:   
          DO TRANSACTION ON ERROR UNDO, RETRY setnoerr: 
             FIND FIRST buf_code WHERE buf_code.parent EQ "GisMt"
                                   AND buf_code.code   EQ "GisMtErr"
                EXCLUSIVE-LOCK NO-WAIT NO-ERROR.
             IF AVAILABLE buf_code 
             THEN DO:
                buf_code.codevalue = "".
                release buf_code no-error. 
             END.   
             ELSE IF LOCKED buf_code THEN  
                dbgPrint("marking.log", "Запись в справочнике для сброса времени сбоя ГИС МТ заблокирована").
          END.     
          IF RETRY THEN DO:
             dbgPrint("marking.log", "Ошибка сброса времени сбоя ГИС МТ").
          END.    
      end.
    
  END METHOD.
  
  /* Получение настроек из типа маркировки */
  METHOD PRIVATE LOGICAL GetMarkProp (
     p-obj-type  AS CHARACTER, 
     p-obj-code  AS INTEGER,
     p-param-code AS CHARACTER,
     p-type-mark AS CHARACTER
     ):      
      DEFINE VARIABLE v-value-character AS CHARACTER NO-UNDO.
              
      v-value-character = get-thbj-attr-prop(p-obj-type,p-obj-code,{&attr-marking},p-param-code).
      dbgPrint("marking.log", SUBSTITUTE("Тип маркировки: p-param-code &1 v-value-character &2 тип маркировки &3", 
                                         p-param-code, 
                                         v-value-character,
                                         p-type-mark)).
      IF LOOKUP (p-type-mark,v-value-character) > 0
      THEN RETURN YES.        
      ELSE RETURN NO.
  END METHOD.
  
  /* Проверка марки в ГИС МТ */
  METHOD PRIVATE INTEGER GetGisMTCheck (
     p-obj-type  AS CHARACTER, 
     p-obj-code  AS INTEGER,
     mark AS CHARACTER,
     mark-short AS CHARACTER
  ):
    DEFINE VARIABLE vInn           AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE vErrSts        AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE cmd            AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE cmdlog         AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE CmdParamProxy  AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE vFileToken     AS CHARACTER   NO-UNDO. 
    DEFINE VARIABLE vFileBat       AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE vFileResult    AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE vFileResultCnv AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE vFileResultErr AS CHARACTER   NO-UNDO.   
    DEFINE VARIABLE vFileresultXml AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE vFileLog       AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE vlongJson      AS LONGCHAR    NO-UNDO CASE-SENSITIVE.
    DEFINE VARIABLE vlongJsonError AS LONGCHAR    NO-UNDO CASE-SENSITIVE.
    DEFINE VARIABLE vMark          AS CHARACTER   NO-UNDO CASE-SENSITIVE.
    DEFINE VARIABLE vDataMark      AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE vDataMarkLM    AS CHARACTER   NO-UNDO.    
    DEFINE VARIABLE vRetProp       AS CHARACTER   NO-UNDO.
    
    DEFINE VARIABLE v-value-character AS CHARACTER NO-UNDO .
    DEFINE VARIABLE v-value-date      AS DATE      NO-UNDO .
    DEFINE VARIABLE v-value-decimal   AS DECIMAL   NO-UNDO .
    DEFINE VARIABLE v-value-integer   AS INTEGER   NO-UNDO .
    DEFINE VARIABLE v-value-logical   AS LOGICAL   NO-UNDO .
    DEFINE VARIABLE v-param-type      AS CHARACTER NO-UNDO .
    DEFINE VARIABLE v-param-value     AS CHARACTER NO-UNDO .
   
    DEFINE VARIABLE vRetOk   AS LOGICAL     NO-UNDO.
    DEFINE VARIABLE vRetVal  AS INTEGER     NO-UNDO.
    DEFINE VARIABLE vCh      AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE vBefCurl AS DATETIME-TZ NO-UNDO. 
    DEFINE VARIABLE vAftCurl AS DATETIME-TZ NO-UNDO.
    DEFINE VARIABLE vpid     AS INTEGER     NO-UNDO.
    DEFINE VARIABLE vTimePause AS INTEGER   NO-UNDO.
    DEFINE VARIABLE vGisAdress AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE vGisAdrCDN AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE vTimeStart AS DATETIME-TZ NO-UNDO.
    DEFINE VARIABLE vTimeNow   AS DATETIME-TZ NO-UNDO.    
    DEFINE VARIABLE vRetCdn    AS LOGICAL     NO-UNDO.
    DEFINE VARIABLE vNumRep AS INT64 NO-UNDO.
    DEFINE VARIABLE vNumMax AS INT64 NO-UNDO.
    DEFINE VARIABLE vVerLM  AS INT64 NO-UNDO.
    
    DEFINE VARIABLE vMarkShort    AS CHARACTER   NO-UNDO CASE-SENSITIVE.
    DEFINE VARIABLE vFileBatOf    AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE vFileResOf    AS CHARACTER   NO-UNDO.    
    DEFINE VARIABLE vFileResOfErr AS CHARACTER   NO-UNDO. 
        
    DEFINE BUFFER buf_firm FOR ub.firm .
    DEFINE BUFFER buf_shop FOR ub.shop.
    DEFINE BUFFER buf_sys-ctrl FOR ub.sys-ctrl .
    
    /* заменяем 1D в 16-тиричной на \u001d */
    ASSIGN       
       vMark = mark
       vMark = REPLACE(vMark, '\', '\\') 
       vMark = REPLACE(vMark, '/', '\/') 
       vMark = REPLACE(vMark, '"', '\"') 
       vMark = REPLACE(vMark,CHR(29),"\u001d")
       .

    EMPTY TEMP-TABLE ttmark-body.
    EMPTY TEMP-TABLE ttmark-check.
    EMPTY TEMP-TABLE ttlocal-mark.
    EMPTY TEMP-TABLE ttlocal-mark-code.
      
    dbgPrint("marking.log", SUBSTITUTE("Отправка запроса p-obj-type &1 p-obj-code &2 mark &3", 
                                       p-obj-type, 
                                       p-obj-code,
                                       vMark)).
    
    /* определяем по фирме ИНН */
    /*vInn = "".
    find first buf_shop no-lock where buf_shop.obj-code = p-obj-code no-error. 
    if available buf_shop then do:
       find first buf_firm no-lock where buf_firm.firm-code = buf_shop.host-code no-error. 
       if available buf_firm then vInn = buf_firm.inn.
       dbgPrint("marking.log", substitute(" Код фирмы &1", buf_shop.host-code)).
    end.   
    else dbgPrint("marking.log", substitute("Не найден магазин с кодом &1", p-obj-code)).
    dbgPrint("marking.log", substitute(" ИНН &1 ", vInn)).*/
    dbgPrint("marking.log", SUBSTITUTE("Заново считывать настройки подключения к ГИС МТ &1 ", gismt-UpdateRequest)).                              
    /* определяем настройки подключения к ГИС МТ */
    IF gismt-UpdateRequest THEN DO:
        FIND FIRST buf_sys-ctrl NO-LOCK NO-ERROR.
        IF AVAILABLE buf_sys-ctrl AND buf_sys-ctrl.db-num <> 0 
        THEN DO:
            dbgPrint("marking.log", SUBSTITUTE("Cчитываем настройки подключения к ГИС МТ для &1 &2", "{&db}",buf_sys-ctrl.db-num)).
            vRetProp = get-gismt-prop ({&db},
                                       buf_sys-ctrl.db-num) NO-ERROR.
        END.                               
    END.                           
    dbgPrint("marking.log", "gismt-info").
           
    vFileLog = "GisMtReq-" + replace(STRING(TODAY),"/","-") +  ".log".
    vCh = "". /* что бы в новый лог писал с первой строки, а в имеющийся - со следующей */
    IF searchfile(vFileLog) <> ?
    THEN DO:
       FILE-INFO:FILE-NAME = searchfile(vFileLog).
       IF FILE-INFO:FILE-SIZE <> 0 THEN vCh = " ".
    END.
    
    /* формируем лог файл */
    OUTPUT STREAM out_data TO value(vFileLog) APPEND.
    PUT STREAM out_data UNFORMATTED 
      vCh SKIP NOW CHR(9) mMarkOrig CHR(9).
    OUTPUT STREAM out_data CLOSE.     
    
    /* формируем файл запроса к ЛМ ЧЗ с маркой */
    RUN gbl/_tmpfile.p ( "LMChz_data", ".txt", OUTPUT vDataMarkLM ) .
    CREATE tt-file-name.
    ASSIGN tt-file-name.tmpFileName = vDataMarkLM.
    
    dbgPrint("marking.log", SUBSTITUTE("vDataMarkLM &1 ", vDataMarkLM)).
        
    ASSIGN       
       vMarkShort = mark-short
       vMarkShort = REPLACE(vMarkShort, '\', '\\') 
       vMarkShort = REPLACE(vMarkShort, '/', '\/') 
       vMarkShort = REPLACE(vMarkShort, '"', '\"') .
      
    dbgPrint("marking.log", SUBSTITUTE("Сконвертированная КИ: &1 ", vMarkShort)).
    
    IF R-INDEX(gismt-OflineAdress,"/v2") > 0 
    THEN vVerLM = 2. 
    ELSE vVerLM = 1. 
               
    OUTPUT STREAM out_data TO value(vDataMarkLM).
    IF vVerLM = 2 THEN
       PUT STREAM out_data UNFORMATTED  
          '~{"cis_list":[~{"cis":"' vMarkShort '"~}]~}' .
    ELSE               
       PUT STREAM out_data UNFORMATTED  
          '~{"cis_list":["' vMarkShort '"]~}' .
    OUTPUT STREAM out_data CLOSE.
    
    /* если установлен параметр, обозначающий наличие аварии в ГИС МТ, выходим */
    IF gismt-CrashSituat THEN DO:
       dbgPrint("marking.log", "Установлена аварийная ситуация.").
       OUTPUT STREAM out_data TO value(vFileLog) APPEND.            
       PUT STREAM out_data UNFORMATTED  
          "Установлена аварийная ситуация в ГИС МТ" CHR(9).
       OUTPUT STREAM out_data CLOSE.
       /* Запускаем офлайн проверку */
       vRetVal = GetResLocalMark(vDataMarkLM).
       RETURN 1.
    END.
    
    /* формируем файл запроса к ГИС МТ с маркой */
    RUN gbl/_tmpfile.p ( "GisMT_data", ".txt", OUTPUT vDataMark ) .
    CREATE tt-file-name.
    ASSIGN tt-file-name.tmpFileName = vDataMark.
    
    dbgPrint("marking.log", SUBSTITUTE("vDataMark &1 ", vDataMark)).
    
    OUTPUT STREAM out_data TO value(vDataMark).        
    PUT STREAM out_data UNFORMATTED  
      '~{"codes":["' vMark '"]~}' .
    OUTPUT STREAM out_data CLOSE.       
     
    IF gismt-AdressPort <> "" AND gismt-ProxyLogin <> "" AND gismt-ProxyPswd <> "" 
    THEN CmdParamProxy = SUBSTITUTE ('-x &1 -U &2:&3',gismt-AdressPort,gismt-ProxyLogin,gismt-ProxyPswd).
    ELSE IF gismt-AdressPort <> "" THEN CmdParamProxy = SUBSTITUTE ('-x &1',gismt-AdressPort).
    ELSE CmdParamProxy = "".      
        
    IF gismt-cdnTurnOn AND gismt-cdnRepeat
    THEN vNumMax = 2.    
    ELSE vNumMax = 1.
    
    dbgPrint("marking.log", SUBSTITUTE(" Кол-во запросов по одной площадке &1 ", vNumMax)).
    
    vTimeStart = NOW.
    
    /* перебираем площадки (если надо) */
    block_chgcdn:
    DO  WHILE TRUE:
        /* определяем адрес площадки, к которой обращаться */
       IF gismt-cdnTurnOn THEN DO:           
           vGisAdrCDN = GetCDNAdress().
           IF vGisAdrCDN = "" THEN DO:
               /* фиксируем, что больше площадок нет */
              dbgPrint("marking.log", "Нет доступных площадок").    
              OUTPUT STREAM out_data TO value(vFileLog) APPEND.            
              PUT STREAM out_data UNFORMATTED  
                 CHR(9) "Нет доступных площадок для обращения в ГИС МТ" CHR(9).
              OUTPUT STREAM out_data CLOSE.
              /* Запрашиваем офлайн проверку, если еще этого не делали */
              IF vFileResult = "" THEN DO:
                 vRetVal = GetResLocalMark(vDataMarkLM). 
              END.    
              RETURN 2.
           END.   
           vGisAdress = vGisAdrCDN + "/api/v4/true-api/codes/check".
       END.
       ELSE vGisAdress = gismt-GisAdress.
       
       /* обращение несколько раз к одной и той же площадке (если надо) */
       block_repeat:
       DO vNumRep = 1 TO vNumMax:
           IF vNumRep > 1 THEN DO:
               dbgPrint("marking.log", SUBSTITUTE("Повторный запрос на площадку &1 ", vGisAdress)).
           END.
           /* вычисляем и запоминаем имена временных файлов 
           ** (на каждом шаге цикла и для каждой площадки новое имя) */    
           RUN gbl/_tmpfile.p ( "ChkGisMTRes", ".txt", OUTPUT vFileResult ) .
           CREATE tt-file-name.
           ASSIGN tt-file-name.tmpFileName = vFileResult.           
           RUN gbl/_tmpfile.p ( "ChkGisMTResErr", ".txt", OUTPUT vFileResultErr ) .
           CREATE tt-file-name.
           ASSIGN tt-file-name.tmpFileName = vFileResultErr.
           RUN gbl/_tmpfile.p ( "ChkGisMT", ".bat", OUTPUT vFileBat ) .     
           CREATE tt-file-name.
           ASSIGN tt-file-name.tmpFileName = vFileBat.
           
           dbgPrint("marking.log", SUBSTITUTE("vFileResult &1 ", vFileResult)).           
           dbgPrint("marking.log", SUBSTITUTE("vFileResultErr &1 ", vFileResultErr)).
           dbgPrint("marking.log", SUBSTITUTE("vFileBat &1 ", vFileBat)).
           
           IF vNumRep = 1 THEN DO:                                            
               RUN gbl/_tmpfile.p ( "ChkLMRes", ".txt", OUTPUT vFileResOf ) .               
               CREATE tt-file-name.
               ASSIGN tt-file-name.tmpFileName = vFileResOf
                      tt-file-name.ofline = YES.           
               RUN gbl/_tmpfile.p ( "ChkLMResErr", ".txt", OUTPUT vFileResOfErr ) .
               CREATE tt-file-name.
               ASSIGN tt-file-name.tmpFileName = vFileResOfErr.
               RUN gbl/_tmpfile.p ( "ChkLM", ".bat", OUTPUT vFileBatOf ) .     
               CREATE tt-file-name.
               ASSIGN tt-file-name.tmpFileName = vFileBatOf.
               
               dbgPrint("marking.log", SUBSTITUTE("vFileResOf &1 ", vFileResOf)).           
               dbgPrint("marking.log", SUBSTITUTE("vFileResOfErr &1 ", vFileResOfErr)).
               dbgPrint("marking.log", SUBSTITUTE("vFileBatOf &1 ", vFileBatOf)).
           END.    
           ELSE ASSIGN        
                  vFileResOf = "" 
                  vFileResOfErr = ""   
                  vFileBatOf = ""
                  .           
           
           vRetVal = RunCurlGisMT(vGisAdress,     
                                  vDataMark,
                                  vDataMarkLM,
                                  CmdParamProxy,
                                  vFileResult,
                                  vFileResultErr,
                                  vFileBat,                                  
                                  vFileResOf,
                                  vFileResOfErr,
                                  vFileBatOf). 
                                  
           dbgPrint("marking.log", SUBSTITUTE("Файл ответа &1 результат &1 ", searchFile(vFileResult), vRetVal)).                                 
           vTimeNow = NOW.             
                     
           OUTPUT STREAM out_data TO value(vFileLog) APPEND.            
           PUT STREAM out_data UNFORMATTED  
              vGisAdress CHR(9) vTimeNow CHR(9).
           OUTPUT STREAM out_data CLOSE.
           /* есть ли файл ответа проверяем независимо от результата в vRetVal */
           IF searchFile(vfileresult) = ?
           THEN DO :            
               /* формируем лог файл */
               OUTPUT STREAM out_data TO value(vFileLog) APPEND.
               PUT STREAM out_data UNFORMATTED  
                  "Отсутствует ответ ГИС МТ " CHR(9).
               OUTPUT STREAM out_data CLOSE.               
           END .
           ELSE DO:
               FILE-INFO:FILE-NAME = searchFile(vfileresult) .
               IF FILE-INFO:FILE-SIZE = 0
               THEN DO :                  
                   /* формируем лог файл */
                   OUTPUT STREAM out_data TO value(vFileLog) APPEND.
                   PUT STREAM out_data UNFORMATTED  
                      "Отсутствует ответ ГИС МТ " CHR(9).
                   OUTPUT STREAM out_data CLOSE.
               END .
               ELSE DO:
                  dbgPrint("marking.log", SUBSTITUTE("Добавляем в лог ответ из файла &1 ", vFileResult)).
                  vlongJson = "". 
                  COPY-LOB FROM FILE vFileResult TO vlongJson NO-ERROR. 
                  IF vlongJson = "" OR 
                     ERROR-STATUS:ERROR OR 
                     ERROR-STATUS:GET-MESSAGE(1) <> "" THEN DO:
                     dbgPrint("marking.log", SUBSTITUTE("Возникла ошибка при чтении ответа для записи в лог: &1 ", ERROR-STATUS:GET-MESSAGE(1))). 
                  END.  
                  ELSE DO:   
                      /* если думали, что ответа нет, а он оказывается есть, то еще раз определяем, есть ли в ответе ошибки */
                      IF vRetVal = -1 THEN DO:
                         vRetVal = ChkCurlGisMT (vlongJson).
                         dbgPrint("marking.log", SUBSTITUTE("Думали, что ответа нет, а файл есть, новый результат проверки: &1 ", vRetVal)). 
                      END.
                      /* добавляем в лог ответ Гис МТ */
                      COPY-LOB FROM vlongJson TO FILE vFileLog APPEND NO-ERROR.                   
                      IF ERROR-STATUS:ERROR OR 
                         ERROR-STATUS:GET-MESSAGE(1) <> "" 
                      THEN DO:
                          dbgPrint("marking.log", SUBSTITUTE("Возникла ошибка при добавлении ответа в лог: &1 ", ERROR-STATUS:GET-MESSAGE(1))).
                      END.    
                      ELSE dbgPrint("marking.log", SUBSTITUTE("Ответ ГИС МТ успешно добавлен в файл &1 ", vFileLog)).                          
                  END.
               END.              
           END.                     
           
           dbgPrint("marking.log", SUBSTITUTE("Ответ по запросу vRetVal &1", vRetVal)).                      
                                 
           /* проверяем, когда не надо повторный запрос и смену площадки */              
           IF vRetVal = 0 OR 
              vRetVal = 203 OR
              vRetVal = 418
           THEN LEAVE block_chgcdn.
           
           IF vRetVal = 401 THEN DO: 
               /* формируем лог файл */
               OUTPUT STREAM out_data TO value(vFileLog) APPEND.
               PUT STREAM out_data UNFORMATTED  
                  CHR(9) "Ошибка идентификации по API Key ".
               OUTPUT STREAM out_data CLOSE.
               LEAVE block_chgcdn. 
           END.        
           ELSE IF vRetVal > 400 AND 
              vRetVal < 500 AND 
              vRetVal <> 429
           THEN DO:
              /* формируем лог файл */
              OUTPUT STREAM out_data TO value(vFileLog) APPEND.
              PUT STREAM out_data UNFORMATTED  
                  CHR(9) "Ошибка: некорректный запрос ".
              OUTPUT STREAM out_data CLOSE.  
              LEAVE block_chgcdn.
           END.    
           
           /* при 5000 надо повторный запрос, но не надо смены площадки */  
           IF vRetVal = 5000 AND vNumRep = vNumMax 
           THEN DO: 
              OUTPUT STREAM out_data TO value(vFileLog) APPEND.
              PUT STREAM out_data UNFORMATTED  
                  CHR(9) "Ошибка недоступности трансграна ".
              OUTPUT STREAM out_data CLOSE.  
              LEAVE block_chgcdn.
           END.    
                                           
           /* во всех остальных случаях, 
           ** после второго опроса площадки
           ** помечаем площадку плохой */
           IF vNumRep = vNumMax
               AND gismt-cdnTurnOn 
           THEN DO:
              vRetCdn = SetCDNAdressErr(vGisAdrCDN).  
           END.     
           
           /* проверяем, осталось ли время для повторного запроса 
           ** или смены площадки */  
           IF vNumRep <> vNumMax AND 
              gismt-cdnTurnOn AND                
              gismt-cdnRepeat
           THEN DO:             
               /* если второй раз площадку не опрашиваем, то помечаем ее плохой */    
               IF vTimeStart + Int(gismt-WaitTime * 1000) < vTimeNow 
               THEN DO:
                  dbgPrint("marking.log", SUBSTITUTE("Время для повторного запроса не осталось: Начало &1 Время ожидания (с) &2 Сейчас &3  ", vTimeStart, gismt-WaitTime, vTimeNow)).
                  vRetCdn = SetCDNAdressErr(vGisAdrCDN).
                  LEAVE block_chgcdn.
               END.
           END.                          
       END.  
       
       /* меняем площадку, только если включена настройка  работы по площадкам и смены площадки */
       IF gismt-cdnTurnOn AND gismt-cdnChange 
       THEN DO:
           /* проверяем, осталось ли время для смены площадки */
           vTimeNow = NOW.
           IF vTimeStart + Int(gismt-WaitTime * 1000) < vTimeNow 
           THEN DO:
              dbgPrint("marking.log", SUBSTITUTE("Время подбора площадки закончилось: Начало &1 Время ожидания (с) &2 Сейчас &3  ", vTimeStart, gismt-WaitTime, vTimeNow)). 
              LEAVE block_chgcdn.
           END.
       END.
       ELSE LEAVE block_chgcdn.                      
    END.                                              
    
    IF vRetVal <> 0 AND 
       vRetVal <> 203 AND 
       vRetVal <> 418 AND
       vRetVal <> 5000  
    THEN DO:
       dbgPrint("marking.log", SUBSTITUTE("Получена ошибка с кодом &1 ", vRetVal)).          
       RETURN 2.
    END.     
    
    IF vRetVal = 203 OR 
       vRetVal = 418 OR
       vRetVal = 5000
    THEN DO:
        dbgPrint("marking.log", SUBSTITUTE("Получена ошибка с кодом &1 ", vRetVal)).          
       RETURN vRetVal.
    END.  
                           
    IF searchFile(vfileresult) = ?
    THEN DO :
       dbgPrint("marking.log", "Запрос не выполнен! Не могу найти файл ").       
       RETURN 2.
    END .
    FILE-INFO:FILE-NAME = searchFile(vfileresult) .
    IF FILE-INFO:FILE-SIZE = 0
    THEN DO :
       dbgPrint("marking.log", "Запрос не выполнен! Файл-ответ пустой (размер 0 байт). ").          
       RETURN 2.
    END.
    
    COPY-LOB FROM FILE vFileResult TO vlongJson NO-ERROR.
    COPY-LOB FROM FILE vFileresultErr TO vlongJsonError NO-ERROR.        
         
    /* анализируем, есть ли ошибки в ответе */
    IF INDEX(vlongJsonError,"curl:") > 0 OR
       vlongJson BEGINS "<html>" 
    THEN DO:
       dbgPrint("marking.log", "Ошибка ответа от сервиса ").
       /* формируем лог файл */
       OUTPUT STREAM out_data TO value(vFileLog) APPEND.
       PUT STREAM out_data UNFORMATTED  
         CHR(9) "Отсутствует ответ ГИС МТ ".
       OUTPUT STREAM out_data CLOSE.
       RETURN 2.
    END.                        
   
    /* заменяем спец.символы, которые не дадут сконвертировать в xml */
    ASSIGN
       vlongJson = REPLACE(vlongJson, "&lt;", "###lo-then###") 
       vlongJson = REPLACE(vlongJson, "&Lt;", "###LO-then###") 
       vlongJson = REPLACE(vlongJson, "&lT;", "###lo-THEN###") 
       vlongJson = REPLACE(vlongJson, "&LT;", "###LO-THEN###") 
       vlongJson = REPLACE(vlongJson, "&gt;", "###gr-then###") 
       vlongJson = REPLACE(vlongJson, "&Gt;", "###GR-then###") 
       vlongJson = REPLACE(vlongJson, "&gT;", "###gr-THEN###") 
       vlongJson = REPLACE(vlongJson, "&GT;", "###GR-THEN###") 
       vlongJson = REPLACE(vlongJson, "&", "&amp;") 
       vlongJson = REPLACE(vlongJson, "<", "&lt;") 
       vlongJson = REPLACE(vlongJson, ">", "&gt;") 
       vlongJson = REPLACE(vlongJson, ':null', ':""') 
       vlongJson = REPLACE(vlongJson, (':' + CHR(91) + CHR(123) + CHR(125) + CHR(93)), ':""') 
       vlongJson = REPLACE(vlongJson, ':~{~}', ':""')
       vlongJson = REPLACE(vlongJson, '"1":', '"n1":')
       vlongJson = REPLACE(vlongJson, '"2":', '"n2":')
       vlongJson = REPLACE(vlongJson, '"3":', '"n3":')
       vlongJson = REPLACE(vlongJson, '"4":', '"n4":')
       vlongJson = REPLACE(vlongJson, '"5":', '"n5":')
       vlongJson = REPLACE(vlongJson, '"6":', '"n6":')
       vlongJson = REPLACE(vlongJson, '"7":', '"n7":')
       vlongJson = REPLACE(vlongJson, '"8":', '"n8":')
       vlongJson = REPLACE(vlongJson, '"9":', '"n9":')
       vlongJson = REPLACE(vlongJson, '"10":', '"n10":')
       vlongJson = REPLACE(vlongJson, '"11":', '"n11":')
       vlongJson = REPLACE(vlongJson, '"12":', '"n12":')
       vlongJson = REPLACE(vlongJson, '"13":', '"n13":')
       vlongJson = REPLACE(vlongJson, '"14":', '"n14":')
       vlongJson = REPLACE(vlongJson, '"15":', '"n15":')
       vlongJson = REPLACE(vlongJson, '"16":', '"n16":')
       vlongJson = REPLACE(vlongJson, '"17":', '"n17":')
       vlongJson = REPLACE(vlongJson, '"18":', '"n18":')
       vlongJson = REPLACE(vlongJson, '"19":', '"n19":')
       vlongJson = REPLACE(vlongJson, '"20":', '"n20":')
       vlongJson = REPLACE(vlongJson, '"21":', '"n21":')
       .
    RUN gbl/_tmpfile.p ( "ChkGisMTResCnv", ".txt", OUTPUT vFileResultCnv ) .
    CREATE tt-file-name.
    ASSIGN tt-file-name.tmpFileName = vFileResultCnv.
    dbgPrint("marking.log", SUBSTITUTE("vFileResultCnv &1 ", vFileResultCnv)).
    
    COPY-LOB FROM vlongJson TO FILE vFileResultCnv NO-ERROR.
    
    IF vlongJson = "" THEN DO:
       dbgPrint("marking.log", "Не получен ответ от сервиса ").
       /* формируем лог файл */
       OUTPUT STREAM out_data TO value(vFileLog) APPEND.
       PUT STREAM out_data UNFORMATTED  
         CHR(9) "Отсутствует ответ ГИС МТ ".
       OUTPUT STREAM out_data CLOSE.
       RETURN 2.
    END.   
    
    RUN gbl/_tmpfile.p ( "ChkGisMTResXml", ".xml", OUTPUT vFileResultXml ) .
    CREATE tt-file-name.
    ASSIGN tt-file-name.tmpFileName = vFileResultXml. 
    dbgPrint("marking.log", SUBSTITUTE("vFileResultXml &1 ", vFileResultXml)).
            
    cmd = SUBSTITUTE ('&1 -file=&2 >&3',
                      SEARCH("exe/json2xml.exe"),
                      vFileResultCnv,
                      vfileresultxml).
                          
    OS-COMMAND SILENT VALUE (cmd).  
    
    FILE-INFO:FILE-NAME = SEARCH(vfileresultxml) .
    IF FILE-INFO:FILE-SIZE = 0
    THEN DO :
       dbgPrint("marking.log", "Запрос не выполнен! Ошибка при чтении XML <body>. " + ERROR-STATUS:GET-MESSAGE(1)).
       /* формируем лог файл */
       OUTPUT STREAM out_data TO value(vFileLog) APPEND.
       PUT STREAM out_data UNFORMATTED  
         CHR(9) "Отсутствует ответ ГИС МТ ".
       OUTPUT STREAM out_data CLOSE.
       RETURN 2.
    END .
    
    COPY-LOB FROM FILE vfileresultxml TO vlongJson NO-ERROR.
    vlongJson = "<bodys>" +  vlongJson + "</bodys>".
    COPY-LOB FROM vlongJson TO FILE vfileresultxml NO-ERROR.
    vRetOk = DATASET gismt-mark-body:READ-XML("FILE":U, vfileresultxml, "EMPTY":U, ?, ?) NO-ERROR.
    IF NOT vRetOk OR ERROR-STATUS:ERROR THEN DO:
       dbgPrint("marking.log", "Запрос не выполнен! Ошибка при чтении XML <body>. " + ERROR-STATUS:GET-MESSAGE(1)).
       /* формируем лог файл */
       OUTPUT STREAM out_data TO value(vFileLog) APPEND.
       PUT STREAM out_data UNFORMATTED  
         CHR(9) "Отсутствует ответ ГИС МТ ".
       OUTPUT STREAM out_data CLOSE.
       RETURN 2.
    END.   
    vRetOk = DATASET gismt-mark-codes:READ-XML("FILE":U, vfileresultxml, "EMPTY":U, ?, ?) NO-ERROR. 
    IF NOT vRetOk OR ERROR-STATUS:ERROR THEN DO:
       dbgPrint("marking.log", "Запрос не выполнен! Ошибка при чтении XML <codes>.").
       /* формируем лог файл */
       OUTPUT STREAM out_data TO value(vFileLog) APPEND.
       PUT STREAM out_data UNFORMATTED  
         CHR(9) "Отсутствует ответ ГИС МТ ".
       OUTPUT STREAM out_data CLOSE.
       RETURN 2.
    END.         
       
    RETURN 0.
    
  END METHOD.
  
  
  /* Проверка марки в ГИС МТ */
  METHOD PRIVATE CHARACTER ChekAccessMark (
    p-obj-type  AS CHARACTER, 
    p-obj-code  AS INTEGER,
    mark AS CHARACTER,
    mark-short AS CHARACTER 
  ):
    DEFINE VARIABLE vErrSts AS CHARACTER NO-UNDO.
    DEFINE VARIABLE vMark AS CHARACTER NO-UNDO.
    
    DEFINE VARIABLE vGetGisMt AS INT NO-UNDO.
        
    DEFINE VARIABLE vMarkNotNeedCheck AS LOGICAL   NO-UNDO.
    /* настройки по типам маркировки */
    DEFINE VARIABLE vCheckBlock    AS LOGICAL   NO-UNDO.
    DEFINE VARIABLE vCheckDate     AS LOGICAL   NO-UNDO.
    DEFINE VARIABLE vCheckMRC      AS LOGICAL   NO-UNDO.
    DEFINE VARIABLE vCheckOwner    AS LOGICAL   NO-UNDO.
    DEFINE VARIABLE vCheckStatusKM AS LOGICAL   NO-UNDO.
    DEFINE VARIABLE vCheckTracking AS LOGICAL   NO-UNDO.
    DEFINE VARIABLE vCheck         AS LOGICAL   NO-UNDO.
    
    DEFINE VARIABLE vMRC AS DECIMAL NO-UNDO.
    DEFINE VARIABLE vMrp AS DECIMAL NO-UNDO.
    DEFINE VARIABLE vMRC_r AS DECIMAL NO-UNDO.
    DEFINE VARIABLE vMrp_r AS DECIMAL NO-UNDO.
    DEFINE VARIABLE vExpireDMY  AS CHARACTER  NO-UNDO.
    DEFINE VARIABLE vExpireTime AS CHARACTER  NO-UNDO.
    DEFINE VARIABLE vExpireDate AS DATETIME-TZ NO-UNDO.
    DEFINE VARIABLE vExpireTimeMes AS CHARACTER NO-UNDO.
        
    DEFINE BUFFER buf_marking-attr FOR ub.marking-attr.
    DEFINE BUFFER buf_code FOR ub.code.
    
    DelTmpFile(YES).
    DelTmpFile(NO).
    
    IF mark = "" OR mark = "?" 
       THEN RETURN "".
       
    ASSIGN
       vErrSts = ""
       mCheckSts = 1
       mTypeMark = ""
       mCheckGisMT = 0
       .
    
    /* определяем тип марки и МРЦ */
    ChekTypeMarkByDm(mark).
    
    /* если не определен тип марки, это не марка, не проверяем */    
    IF mTypeMark = "" THEN DO:
        mCheckSts = 0.
        RETURN "Не опредлен тип маркировки товара. ".
    END.    
    
    dbgPrint("marking.log", SUBSTITUTE("Проверка марки p-obj-type &1 p-obj-code &2 mark &3 mTypeMark &4 mark-short &5", 
                                        p-obj-type,
                                        p-obj-code,
                                        mark,
                                        mTypeMark,
                                        TRIM(mark-short,CHR(29))
                                        )).  
                                        
    /* Вычисляем, какие проверки нужны для этого типа марки */    
    vCheckBlock = GetMarkProp (p-obj-type, 
                               p-obj-code,
                               {&attr-marking_checkBlock},
                               mTypeMark).
    vCheckDate   = GetMarkProp (p-obj-type, 
                               p-obj-code,
                               {&attr-marking_checkDate},
                               mTypeMark).
    vCheckMRC    = GetMarkProp (p-obj-type, 
                               p-obj-code,
                               {&attr-marking_checkMRC},
                               mTypeMark).
    vCheckOwner  = GetMarkProp (p-obj-type, 
                               p-obj-code,
                               {&attr-marking_checkOwner},
                               mTypeMark).
    vCheckStatusKM = GetMarkProp (p-obj-type, 
                               p-obj-code,
                               {&attr-marking_checkStatusKM},
                               mTypeMark).
    vCheckTracking  = GetMarkProp (p-obj-type, 
                               p-obj-code,
                               {&attr-marking_checkTracking},
                               mTypeMark).                           
       
    IF  vCheckBlock OR vCheckDate OR vCheckMRC OR vCheckOwner OR vCheckStatusKM
       THEN vCheck = YES.
    ELSE vCheck = NO.     
    
    dbgPrint("marking.log", SUBSTITUTE("vCheckBlock &1 vCheckDate &2 vCheckMRC &3 vCheckOwner &4 vCheckStatusKM &5 vCheckTracking &6",
                                       vCheckBlock,
                                       vCheckDate,
                                       vCheckMRC,
                                       vCheckOwner,
                                       vCheckStatusKM,
                                       vCheckTracking)).
                                       
    /* у типа маркировки не отмечен ни один параметр для проверки */
    IF NOT vCheck THEN RETURN "".
    
    /* Определяем, стоит ли игнорировать проверку онлайн по марке */
    FIND FIRST buf_marking-attr NO-LOCK WHERE 
                buf_marking-attr.attr-code = "notOnlineCheck"
            AND buf_marking-attr.mark BEGINS trim(mark-short,CHR(29))
        NO-ERROR.
    IF AVAILABLE buf_marking-attr 
    THEN vMarkNotNeedCheck = LOGICAL(buf_marking-attr.attr-value) NO-ERROR.
    ELSE vMarkNotNeedCheck = NO.
    
    dbgPrint("marking.log", SUBSTITUTE("Игнорировать он-лайн проверку: &1",vMarkNotNeedCheck)). 
    
    IF vMarkNotNeedCheck THEN DO:
       mCheckGisMT = 2. 
       RETURN "".
    END.
    /* вызываем проверку по марке */
    vGetGisMt = GetGisMTCheck(p-obj-type,p-obj-code,mark,mark-short).
    
    /* Чистим временные файлы */    
    DelTmpFile(NO).
    
    /* установлен признак аварии в настройках */
    IF vGetGisMt = 1 THEN DO:
       ASSIGN
          mCheckSts = 2
          mCheckGisMT = 2 /* При аварийной ситуации офлайн проверка не всегда приводит к блокировке */
          .
       RETURN "".
    END.   
 
    /* произошла аварийная ситуация - фиксируем */
    IF vGetGisMt <> 0 THEN DO: 
        IF vGetGisMt = 2 THEN 
        DO:
           vErrSts = FixErrGisMT().           
        END.
        /* если авария самого трансграна 
        ** время аварии не сбрасываем и не выставляем */
        ELSE IF vGetGisMt = 5000 
        THEN DO:
            ASSIGN
               mCheckSts = 2
               vErrSts = ""
               . 
        END.    
        /* если авария в ГИС МТ, наше время аварии скидываем */
        ELSE IF vGetGisMt = 203 OR
                vGetGisMt = 418
        THEN DO:
            SetNoErrGisMT().
            ASSIGN 
                mCheckSts = 2
                vErrSts = ""
                mCheckGisMT = 2
                .
                
        END.
        
        RETURN vErrSts.
    END.
    ELSE SetNoErrGisMT().                
    
    mCheckGisMT = 1. /* Обращение к ГИС МТ прошло без ошибок */
    
    dbgPrint("marking.log", "ttmark-body").
     
    FIND FIRST ttmark-body NO-LOCK NO-ERROR.
    IF AVAIL ttmark-body 
    THEN DO:
        ASSIGN
           mReqId        = ttmark-body.reqid
           mReqTimeStamp = STRING(ttmark-body.reqtimestamp)           
           .
        /* по новому алгоритму сюда теоретически не должны попасть */   
        IF ttmark-body.code <> 0  
        THEN DO:
           ASSIGN 
              mCheckSts = 0
              vErrSts = "Онлайн-проверка завершилась с ошибкой. "
              .
            RETURN vErrSts.  
        END.                       
    END.
    ELSE DO:
        /* Сюда можем попасть, если вылетели из проверки GetGisMTCheck по непредвиденной ошибке
        ** например - ошибка с файлом на экран */
        dbgPrint("marking.log", "Произошло аварийное завершение метода проверки марки в ГИС МТ - нет шапки ответа.").
        ASSIGN 
           mCheckSts = 0
           vErrSts = "Онлайн-проверка завершилась с ошибкой. "
           .
        RETURN vErrSts.
    END.    
    
    vMRC = getMRCByDM(mark) * 100 NO-ERROR.
    IF vMRC = ? THEN vMRC = 0.
    dbgPrint("marking.log", SUBSTITUTE("МРЦ по марке: &1",vMRC)).
    
    dbgPrint("marking.log", "ttmark-check").
     
    FIND FIRST ttmark-check NO-LOCK NO-ERROR.
    IF AVAIL ttmark-check 
    THEN DO:
      IF ttmark-check.errorCode = 0 OR
         ttmark-check.errorCode = 10 
         THEN . 
      ELSE DO:
          ASSIGN 
            vErrSts = "Онлайн-проверка завершилась с ошибкой. "
            mCheckSts = 0.
          RETURN vErrSts.
      END.      

      vMrp = int(ttmark-check.mrp) NO-ERROR.
                 
      IF vCheck THEN DO:
         IF ttmark-check.found = FALSE 
         THEN DO: 
            ASSIGN 
                vErrSts = "Данная марка не зарегистрирована в Честном Знаке. "
                mCheckSts = 3.
            RETURN vErrSts.
         END.
         
         IF  vCheckDate = YES THEN DO:            
            IF ttmark-check.expireDate <> ? 
            THEN DO:                
                /* убираем часовой пояс */
                vExpireTimeMes = ENTRY(1,STRING(ttmark-check.expireDate),"+").
                vExpireDate = DATETIME-TZ(vExpireTimeMes).                                
                IF vExpireDate < NOW + gismt-BanDate * 60 * 1000
                THEN DO:
                  ASSIGN
                     vErrSts = "Срок годности товара истек " + string(vExpireDate,"99/99/9999 HH:MM") + ". "
                     mCheckSts = 0.
                END.   
            END.
            ELSE ASSIGN 
                   vErrSts = ""
                   mCheckSts = 2.
         END.
         IF  vCheckBlock AND ttmark-check.isBlocked = TRUE
         THEN ASSIGN
                 vErrSts = vErrSts + "Реализация товара запрещена контролирующими органами. "
                 mCheckSts = 0.
         
         IF  vCheckStatusKM AND 
                 (ttmark-check.utilised = FALSE OR 
                 (ttmark-check.realizable = FALSE AND ttmark-check.grayZone = FALSE) OR 
                 ttmark-check.sold = TRUE OR 
                 ttmark-check.verified = FALSE)
         THEN ASSIGN 
                 vErrSts = vErrSts + "Марка товара в статусе, запрещающем розничную реализацию. "
                 mCheckSts = 0.
                 
         IF vCheckMRC AND 
            vMrp <> 0 AND 
            vMRC <> vMrp          
         THEN 
              ASSIGN 
                 vMRC_r = IF vMRC <> ? THEN ROUND((vMrc / 100), 2) ELSE 0
                 vMrp_r = ROUND((vMrp / 100), 2)
                 vErrSts = vErrSts + "МРЦ на упаковке " 
                           + (IF vMRC = ? THEN "не определена" ELSE TRIM(STRING(vMrc_r,">>>>>>>>>>9.99"), " ") + "р.") 
                           + " не совпадает с МРЦ в Честном Знаке - " 
                           + trim(STRING(vMrp_r,">>>>>>>>>>9.99"), " ") + "р. "
                 mCheckSts = 0
                 .
         IF  vCheckOwner AND 
             ttmark-check.isOwner = FALSE AND 
             ((vCheckTracking AND ttmark-check.isTracking = TRUE) OR 
              NOT vCheckTracking) AND 
             ttmark-check.grayZone = FALSE
         THEN ASSIGN
                 vErrSts = vErrSts + "Общество не является владельцем товара. "
                 mCheckSts = 0.
      END.     
    END.
    ELSE DO:
        /* Сюда можем попасть, если вылетели из проверки GetGisMTCheck по непредвиденной ошибке
        ** по непонятной причине */
        dbgPrint("marking.log", "Произошло аварийное завершение метода проверки марки в ГИС МТ - нет тела ответа.").
        ASSIGN 
           mCheckSts = 0
           vErrSts = "Онлайн-проверка завершилась с ошибкой. "
           .
        RETURN vErrSts.
    END.    
    dbgPrint("marking.log", SUBSTITUTE("vErrSts &1 mCheckSts &2", vErrSts, mCheckSts)).
    
    RETURN vErrSts.

  END METHOD.
  
  METHOD PRIVATE VOID dbgPrint(
     iLogName AS CHARACTER, 
     iTxt AS CHARACTER
    ):
        DEF VAR vLogName AS CHAR NO-UNDO.
        
    IF SESSION:DEBUG-ALERT
    THEN DO:  
       vLogName = ENTRY(1,iLogName,".") + "-" + replace(STRING(TODAY),"/","-") + "." + entry(2,iLogName,".").           
       OUTPUT stream out_s to value(vLogName) append.
       CASE iTxt:
          WHEN "gismt-info" THEN DO:
             PUT STREAM out_s UNFORMATTED
                   " AdressPort " gismt-AdressPort SKIP
                   " DopParam " gismt-DopParam SKIP
                   " GisAdress " gismt-GisAdress SKIP 
                   " ProxyLogin " gismt-ProxyLogin SKIP  
                   " ProxyPswd " gismt-ProxyPswd SKIP
                   " MaxTime " gismt-MaxTime SKIP
                   " RegKey " gismt-RegKey SKIP
                   " TimeFalStart " gismt-TimeFalStart SKIP
                   " WaitTime " gismt-WaitTime SKIP
                   " CrashSituat " gismt-CrashSituat SKIP
                   " BanDate " gismt-BanDate SKIP
                   " cdnTurnOn " gismt-cdnTurnOn SKIP   
                   " cdnAdress " gismt-cdnAdress SKIP
                   " cdnRepeat " gismt-cdnRepeat SKIP
                   " cdnChange " gismt-cdnChange SKIP
                   " cdnTimeUpd " gismt-cdnTimeUpd SKIP  
                   " UpdateRequest " gismt-UpdateRequest                    
                   " OflineAdress " gismt-OflineAdress SKIP  
                   " OflineAutoriz " gismt-OflineAutoriz SKIP
                   " OflineDate " gismt-OflineDate
                   SKIP.   
          END.   
          WHEN "ttmark-body" THEN DO:
             FOR EACH ttmark-body:
                PUT STREAM out_s UNFORMATTED  
                    NOW " ttmark-body: " SKIP
                    "ttmark-body.code " ttmark-body.code SKIP
                    "ttmark-body.error " ttmark-body.error-1 SKIP
                    "ttmark-body.requestid " ttmark-body.requestid SKIP
                    "ttmark-body.status " ttmark-body.status-1 SKIP
                    "ttmark-body.timestamp " ttmark-body.timestamp SKIP 
                    "ttmark-body.reqid " ttmark-body.reqid SKIP
                    "ttmark-body.reqtimestamp " ttmark-body.reqtimestamp
                    SKIP .
             END.       
          END.
          WHEN "ttmark-check" THEN DO: 
             FOR EACH ttmark-check:
                PUT STREAM out_s UNFORMATTED  
                     NOW " ttmark-check: " SKIP
                     "ttmark-check.cis: " ttmark-check.cis SKIP        
                     "tttmark-check.printView: " ttmark-check.printView SKIP      
                     "ttmark-check.gtin: " ttmark-check.gtin           SKIP
                     "ttmark-check.verified: " ttmark-check.verified   SKIP    
                     "ttmark-check.found: " ttmark-check.found         SKIP 
                     "ttmark-check.realizable: " ttmark-check.realizable  SKIP   
                     "ttmark-check.utilised: " ttmark-check.utilised   SKIP     
                     "ttmark-check.isBlocked: " ttmark-check.isBlocked SKIP      
                     "ttmark-check.productionDate: " ttmark-check.productionDate SKIP 
                     "ttmark-check.isOwner: " ttmark-check.isOwner     SKIP    
                     "ttmark-check.errorCode: " ttmark-check.errorCode SKIP      
                     "ttmark-check.isTracking: " ttmark-check.isTracking   SKIP   
                     "ttmark-check.sold: " ttmark-check.sold           SKIP
                     "ttmark-check.packageType: " ttmark-check.packageType SKIP   
                     "ttmark-check.producerInn: " ttmark-check.producerInn SKIP   
                     "ttmark-check.grayZone: " ttmark-check.grayZone       SKIP
                     "ttmark-check.mrp: " ttmark-check.mrp SKIP
                     "ttmark-check.expireDate: " ttmark-check.expireDate          
                     SKIP.
             END.            
          END.     
          WHEN "ttlocal-mark" THEN DO:
              FOR EACH ttlocal-mark:
                  PUT STREAM out_s UNFORMATTED  
                     NOW " ttlocal-mark: " SKIP
                     "ttlocal-mark.reqId: " ttlocal-mark.reqId     SKIP
                     "ttlocal-mark.reqTimestamp: " ttlocal-mark.reqTimestamp     SKIP                     
                     "ttlocal-mark.inst: " ttlocal-mark.inst SKIP
                     "ttlocal-mark.version: " ttlocal-mark.version SKIP
                     "ttlocal-mark.description: " ttlocal-mark.description       SKIP              
                     "ttlocal-mark.code: " ttlocal-mark.code       SKIP
                     "ttlocal-mark.errorCode " ttlocal-mark.errorCode SKIP                     
                     .                        
              END.    
              FOR EACH ttlocal-mark-code:
                  PUT STREAM out_s UNFORMATTED  
                     NOW " ttlocal-mark-code " SKIP
                     "ttlocal-mark-code.sold: " ttlocal-mark-code.sold     SKIP
                     "ttlocal-mark-code.isBlocked: " ttlocal-mark-code.isBlocked     SKIP                     
                     "ttlocal-mark-code.gtin: " ttlocal-mark-code.gtin     SKIP
                     "ttlocal-mark-code.cis: " ttlocal-mark-code.cis       SKIP
                     "ttlocal-mark-code.mrp: " ttlocal-mark-code.mrp       SKIP                                                          
                     .                        
              END.              
          END.    
          OTHERWISE      
             PUT STREAM out_s UNFORMATTED NOW " " iTxt SKIP.
       END CASE.     
       OUTPUT stream out_s close.
    END.
    RETURN.
  END METHOD.
  
  METHOD PRIVATE CHARACTER GetCDNAdress ():
      DEF BUFFER buf_code FOR ub.code.
      DEF VAR vAddr AS CHAR NO-UNDO.
      DEF VAR vTimeResp AS INT NO-UNDO.
      DEF VAR vTimeNow AS DATETIME-TZ NO-UNDO.
      
      ASSIGN
         vTimeNow = NOW
         vTimeResp = 0
         .
      FOR EACH buf_code NO-LOCK WHERE buf_code.parent = "CDN_GisMt":
          IF buf_code.code <> "CDN_Upd" THEN DO:
              dbgPrint("marking.log", SUBSTITUTE("Площадка &1 Время отклика &2 Время блокировки &3 Текущее время &4 ", 
                                                 buf_code.code,
                                                 buf_code.codeval,
                                                 buf_code.misc2,
                                                 vTimeNow)).
              IF buf_code.misc2 = "" /*OR datetime-tz(buf_code.misc2) < vTimeNow*/ 
              THEN DO:
                  IF vTimeResp = 0 OR 
                     vTimeResp = ? OR 
                     vTimeResp > int(buf_code.codeval) 
                  THEN
                     ASSIGN
                        vAddr = buf_code.code 
                        vTimeResp = int(buf_code.codeval) no-error.               
              END.
          END.   
          ELSE dbgPrint("marking.log", SUBSTITUTE("Идет процесс обновления CDN площадок, время начала &1 ",buf_code.codeval)).                        
      END.
      IF vAddr <> "" THEN    
         dbgPrint("marking.log", SUBSTITUTE("Выбрали площадку &1 время отклика &2 ",vAddr,vTimeResp)).
      ELSE dbgPrint("marking.log", "Не удалось подобрать площадку.").    
      RETURN vAddr.
  END METHOD.    
  
  METHOD PRIVATE LOGICAL SetCDNAdressErr (
      iCdnAdr AS CHARACTER):
          
      DEF BUFFER buf_code FOR ub.code.            
      DEF VAR vTimeNow AS DATETIME NO-UNDO.
      DEF VAR vOk AS LOG NO-UNDO.

      setsdn:
      DO TRANSACTION ON ERROR UNDO, RETRY setsdn:      
          vTimeNow = NOW.
          FIND FIRST buf_code WHERE 
                     buf_code.parent = "CDN_GisMt" 
                 AND buf_code.code = iCdnAdr
                 EXCLUSIVE-LOCK NO-WAIT NO-ERROR.
          IF AVAIL buf_code THEN  DO:
             buf_code.misc2 = STRING(vTimeNow + 15000 * 60).         
             RELEASE buf_code NO-ERROR.
             IF ERROR-STATUS:ERROR THEN vOk = NO.
             ELSE vOk = YES.
          END.   
          ELSE IF LOCKED buf_code THEN 
          DO:
             vOk = NO.
             dbgPrint("marking.log", SUBSTITUTE("Заблокирована запись установки блокировки площадки &1", iCdnAdr)).
          END.     
          ELSE vOk = NO.
          
          dbgPrint("marking.log", SUBSTITUTE("Установка площадке &1 время разблокировки &2 успешно &3 &4",
                                             iCdnAdr, (vTimeNow + 15000 * 60), vOk, ERROR-STATUS:GET-MESSAGE(1))).
      END.
      IF RETRY THEN DO:
          dbgPrint("marking.log", SUBSTITUTE("Ошибка блокировки площадки &1", iCdnAdr)).      
      END.    
      RETURN vOk.      
  END METHOD. 
  
  /* Определяет, нужно ли обновлять площадки
  ** 1 - нужно обновлять все площадки
  ** 2 - нужно обновить только время у площадки */
  METHOD PUBLIC INTEGER CheckCdnNeedUpd ():
      DEF BUFFER buf_code FOR ub.code.
      DEF VAR vAddr AS CHAR NO-UNDO.
      DEF VAR vNeedUpd AS LOG NO-UNDO.
      DEF VAR vNeedTimeUpd AS LOG NO-UNDO.
      DEF VAR vReturnValue AS INTEGER NO-UNDO.       
      DEF VAR vAllBlock AS LOG NO-UNDO.
      DEF VAR vTimeNow AS DATETIME-TZ NO-UNDO.
      DEF VAR vTimeUpd AS DATETIME-TZ NO-UNDO.
      DEF VAR vTimeUnbl AS DATETIME-TZ NO-UNDO.
      
      ASSIGN
         vTimeNow = NOW   
         vTimeUpd = ?      
         .
         
      /* Проверяем все ли площадки заблокированы 
      ** и сколько прошло времени с последнего обновления */   
      vAllBlock = YES.
      block_code:
      FOR EACH buf_code NO-LOCK WHERE buf_code.parent = "CDN_GisMt":
          vTimeUpd = DATETIME-TZ(buf_code.misc1) NO-ERROR.
          IF buf_code.misc2 <> "" THEN DO: 
             vTimeUnbl = DATETIME-TZ(buf_code.misc2) NO-ERROR.
             IF vTimeUnbl < vTimeNow THEN vNeedTimeUpd = YES.   
             dbgPrint("marking.log", SUBSTITUTE("Площадка &1 заблокирована &2, требует обновления &3",
                                                  buf_code.code,
                                                  vTimeUnbl,
                                                  vTimeUnbl < vTimeNow)
                     ).
          END.
          /* ищем незаблокированную площадку */   
          IF buf_code.misc2 = "" /*OR 
             (vTimeUnbl <> ? AND
              vTimeUnbl < vTimeNow)*/
          THEN DO: 
             vAllBlock = NO.
             /*LEAVE block_code.*/
          END.             
      END.      
      
      IF vAllBlock OR
         (vTimeUpd = ? OR          
         (vTimeUpd <> ? AND
          datetime-tz(vTimeUpd) < vTimeNow AND
          (vTimeNow - datetime-tz(vTimeUpd)) >= gismt-cdnTimeUpd * 3600 * 1000))  
      THEN DO:
         /* Проверяем, не идет ли уже обновление */
         FIND FIRST buf_code WHERE 
                  buf_code.parent = "CDN_GisMt" 
              AND buf_code.code = "CDN_Upd"              
           NO-LOCK NO-ERROR.
         IF NOT AVAIL buf_code               
         THEN DO:
            dbgPrint("marking.log", SUBSTITUTE("Обновляем список площадок, все заблокированы &1 время посл обновления &2 Частота обновления (ч) &3 ",
                                              vAllBlock, vTimeUpd, gismt-cdnTimeUpd )). 
            vNeedUpd = YES.
         END.    
         /* если прошло 20 минут с момента обновления, то игнорим флаг (завис) */
         ELSE IF DATETIME-TZ(buf_code.codeval) < (NOW - 20 * 60000) THEN DO:
            dbgPrint("marking.log", SUBSTITUTE("Обновляем список площадок, флаг обновления был установлен &1",
                                                buf_code.codeval )). 
            vNeedUpd = YES.
         END.    
         ELSE dbgPrint("marking.log", SUBSTITUTE("Площадки не обновляем, идет обновление &1 ",  buf_code.codeval)).
      END.
      ELSE IF vNeedTimeUpd THEN DO:
         FIND FIRST buf_code WHERE 
                  buf_code.parent = "CDN_GisMt" 
              AND buf_code.code = "CDN_Upd"              
           NO-LOCK NO-ERROR.
         IF AVAIL buf_code               
         THEN DO:
             vNeedTimeUpd = NO.
             dbgPrint("marking.log", SUBSTITUTE("Заблокированную площадку не обновляем, идет обновление &1 ",  buf_code.codeval)).
         END.    
         ELSE dbgPrint("marking.log", SUBSTITUTE("Обновляем заблокированную площадку, 15 минут блокировки истекли в &1",
                                              vTimeUpd )).             
      END.
      ELSE     
         dbgPrint("marking.log", SUBSTITUTE("Площадки не обновляем. Все заблокированы? &1 Время последнего обновления &2 Частота обновления (ч) &3 Заблокированные площадки &4",
                                              vAllBlock, vTimeUpd, gismt-cdnTimeUpd, vNeedTimeUpd )).
      
                                                  
      IF vNeedUpd THEN vReturnValue = 1.
      ELSE IF vNeedTimeUpd then vReturnValue = 2.
      ELSE vReturnValue = 0.
      
      dbgPrint("marking.log", SUBSTITUTE("Возвращаем значение &1 об обновлении площадок",
                                         vReturnValue )).
                                              
      RETURN vReturnValue.
  END METHOD.
  
 /* Вызывает curl с переданным адресом и возвращает ответ:
 ** -1 - не получен ответ от curl
 ** 0 - нет ошибки
 ** xxx - код ошибки в ответе  */
  METHOD PRIVATE INTEGER RunCurlGisMT (
     vGisAdress AS CHARACTER,     
     vDataMark AS CHARACTER,
     vDataMarkLM AS CHARACTER,
     CmdParamProxy AS CHARACTER,
     vFileResult AS CHARACTER,
     vFileResultErr AS CHARACTER,
     vFileBat AS CHARACTER,     
     vFileResOf AS CHARACTER,
     vFileResOfErr AS CHARACTER,
     vFileBatOf AS CHARACTER
     ):
         
    DEFINE VARIABLE vBefCurl AS DATETIME-TZ NO-UNDO. 
    DEFINE VARIABLE vAftCurl AS DATETIME-TZ NO-UNDO.
    DEFINE VARIABLE vpid     AS INTEGER     NO-UNDO.
    DEFINE VARIABLE vTimePause AS INTEGER   NO-UNDO.
    DEFINE VARIABLE vRetVal AS INTEGER   NO-UNDO.
    DEFINE VARIABLE cmd AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE vlongJson AS LONGCHAR NO-UNDO.
    DEFINE VARIABLE vlongJson2 AS LONGCHAR NO-UNDO.
    DEFINE VARIABLE vCh AS CHARACTER NO-UNDO. 
    DEFINE VARIABLE vNumCode AS INTEGER NO-UNDO.
    DEFINE VARIABLE vNumCode2 AS INTEGER NO-UNDO.
    DEFINE VARIABLE vcmdof AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE vpidof AS INTEGER     NO-UNDO.
        
    vRetVal = -1.    
         
    cmd = SUBSTITUTE ('&1 &8 --connect-timeout &9 --max-time &9 -X POST -H "Content-Type: application/json" -H &5 &6 --data @&4 &3 >&2 --stderr &7',
                      SEARCH ("exe/curl.exe"), /*1*/
                      vFileResult,             /*2*/
                      QUOTER(vGisAdress), /*3*/
                      searchfile(vDataMark),   /*4*/
                      QUOTER("X-api-Key: " + gismt-RegKey), /*5*/
                      CmdParamProxy,           /*6*/
                      vFileResultErr,          /*7*/
                      gismt-DopParam,          /*8*/
                      TRIM(REPLACE(STRING(gismt-WaitTime + gismt-WaitTimePlus, "zzzz9.99999"),".",","),"")).         /*9*/                        
    dbgPrint("marking.log", "cmd: " + cmd).
    
    vBefCurl = NOW.
    /*os-command silent value(cmd).*/    
    /* запуск curl в ассинхронном режиме */ 
    vpid = runProcFile(cmd, vFileBat).
    
    /* запускаем проверку офлайн пока ждем окончания */
    IF vFileBatOf <> "" THEN DO:     
        vcmdof = SUBSTITUTE ('&1 --connect-timeout &6 --max-time &6 -X POST -H "Accept: application/json" -H &2 --data @&7 &3 >&4 --stderr &5',
                          SEARCH ("exe/curl.exe"), /*1*/                                                                  
                          QUOTER("Authorization: Basic " + gismt-OflineAutoriz), /*2*/
                          QUOTER(gismt-OflineAdress + "/cis/outCheck"), /*3*/
                          vFileResOf,             /*4*/                      
                          vFileResOfErr,          /*5*/                      
                          TRIM(REPLACE(STRING(gismt-WaitTime, "zzzz9.99999"),".",","),""), /*6*/
                          searchfile(vDataMarkLM)).         /*7*/
        dbgPrint("marking.log", "vcmdof: " + vcmdof).                  
        vpidof = runProcFile(vcmdof, vFileBatOf).
        /*os-command silent value(vcmdof).*/                         
    END.
    
    /* ждем окончания работы */
    block_wait:
    DO WHILE TRUE:
        /* проверка, работает ли еще процесс */                
        IF searchFile(vfileresult) <> ? THEN DO:
            FILE-INFO:FILE-NAME = searchFile(vfileresult).
            IF FILE-INFO:FILE-SIZE <> 0 THEN DO:
               COPY-LOB FROM FILE vFileResult TO vlongJson NO-ERROR.
               IF (vlongJson BEGINS "<html>" AND 
                   r-index(vlongJson,"</html>") > 0)
                  OR
                  (R-INDEX(vlongJson,"reqTimestamp") > 0 AND
                   r-index(SUBSTRING(vlongJson,R-INDEX(vlongJson,"reqTimestamp")),"}") > 0) 
                  OR r-index(vlongJson,'"codes":[]}') > 0  
               THEN DO:
                   dbgPrint("marking.log", SUBSTITUTE("Сформирован файл-ответ &1", vfileresult)).                   
                   LEAVE block_wait.
               END.               
            END.               
        END.    
        
        /* время ожидания вышло */
        IF vBefCurl + Int((gismt-WaitTime + gismt-WaitTimePlus) * 1000) < NOW THEN DO:         
           dbgPrint("marking.log", "Время ожидания работы curl истекло").
           LEAVE block_wait.
        END.
        /* немного ждем */
        vTimePause = NOW - (vBefCurl + Int((gismt-WaitTime + gismt-WaitTimePlus) * 1000)) + 10. 
        IF vTimePause < -10 THEN       
           RUN gbl/pause.p(10).
        ELSE IF vTimePause < 0 AND vTimePause > -10
        THEN       
           RUN gbl/pause.p(0 - vTimePause).    
    END.
    
    vAftCurl = NOW. 
    dbgPrint("marking.log", SUBSTITUTE("Время работы curl: Начало &1 Окончание &2 Всего (мс) &3  ", vBefCurl, vAftCurl, vAftCurl - vBefCurl)).
    
    vRetVal = ChkCurlGisMT (vlongJson). 
  
    RETURN vRetVal.
    
  END METHOD.    
  
  METHOD PRIVATE INTEGER ChkCurlGisMT (
    ilongJson AS LONGCHAR
    ):
         
    DEFINE VARIABLE vRetVal AS INTEGER   NO-UNDO.
    DEFINE VARIABLE vlongJson2 AS LONGCHAR NO-UNDO.
    DEFINE VARIABLE vCh AS CHARACTER NO-UNDO. 
    DEFINE VARIABLE vNumCode AS INTEGER NO-UNDO.
    DEFINE VARIABLE vNumCode2 AS INTEGER NO-UNDO.
     
    vRetVal = -1.
     /* Проверяем наличие ошибки в ответе */
    IF ilongJson BEGINS "<html>" AND index(ilongJson,"<title>") > 0 THEN 
       vRetVal =  int(SUBSTRING(iLongJson, INDEX(iLongJson,"<title>") + 7,3)) NO-ERROR.
    ELSE IF INDEX(ilongJson,'"code":') > 0 THEN DO:  
       vNumCode = INDEX(iLongJson,'"code":') + 7. 
       vlongJson2 = SUBSTRING(iLongJson, vNumCode).
       vNumCode2 = INDEX(vLongJson2,",") - 1. 
       vCh = STRING(SUBSTRING(iLongJson, vNumCode, vNumCode2)).   
       vRetVal  = int(vCh).
    END.
    
    RETURN vRetVal.
    
  END METHOD.   
    
  
  /* Разбор ответа офлайн проверки марки в ЛМ ЧЗ */
  METHOD PRIVATE CHARACTER ChekLocalMark (    
    mark-short AS CHARACTER 
  ):
     DEFINE VARIABLE vFileResult  AS CHARACTER   NO-UNDO.
     DEFINE VARIABLE vFileLog     AS CHARACTER   NO-UNDO.
     DEFINE VARIABLE vlongJson    AS LONGCHAR NO-UNDO.     
     DEFINE VARIABLE hDS          AS HANDLE NO-UNDO.
     DEFINE VARIABLE vFileResJson AS CHARACTER   NO-UNDO.
     DEFINE VARIABLE vRetOk       AS LOGICAL NO-UNDO.
     DEFINE VARIABLE vErrSts      AS CHARACTER   NO-UNDO.
     DEFINE VARIABLE vChkNotSell  AS LOG       NO-UNDO.
     DEFINE VARIABLE vErrTxt      AS CHARACTER NO-UNDO.
     
     ASSIGN
        vChkNotSell = NO
        vFileLog = "GisMtReq-" + replace(STRING(TODAY),"/","-") +  ".log"
        vErrTxt = "Ошибка при проверке товара в локальном модуле Честный знак. Товар не добавлен в чек. Сообщите управляющему/старшему смены. "
        mCheckStsOff = 0
        . 
                  
     FIND FIRST tt-file-name WHERE tt-file-name.ofline = YES NO-ERROR.     
     
     IF AVAIL tt-file-name
        AND searchFile(tt-file-name.tmpFileName) <> ?   
     THEN  DO:         
        dbgPrint("marking.log", SUBSTITUTE("Файл офлайн-проверки &1 ", tt-file-name.tmpFileName)).
        vFileResult = searchFile(tt-file-name.tmpFileName).
        
        COPY-LOB FROM FILE vFileResult TO vlongJson NO-ERROR.          
                       
        hDS = DATASET gismt-local-mark:HANDLE.
                  
        vRetOk  = hDS:read-json("longchar":U, vlongJson) NO-ERROR.      
        
        DATASET gismt-local-mark:WRITE-JSON("FILE":U, vFileResJson) NO-ERROR.
        
        dbgPrint("marking.log", "ttlocal-mark").                 
           
        FIND FIRST ttlocal-mark NO-ERROR.
        IF AVAIL ttlocal-mark THEN DO:
            FIND FIRST ttlocal-mark-code NO-ERROR.                        
            ASSIGN
               mReqId = STRING(ttlocal-mark.ReqId)
               mReqTimestamp = STRING(ttlocal-mark.ReqTimestamp)
               mInst = ttlocal-mark.inst
               mVersion = ttlocal-mark.version
               . 
           IF ttlocal-mark.errorCode > 0 THEN DO:                             
              ASSIGN
                 mCheckSts = 0
                 mCheckStsOff = 3              
                 vErrSts = vErrTxt.
              dbgPrint("marking.log", SUBSTITUTE("Ошибка проверки КИ в ЛМ ЧЗ. Ошибка errorCode &1 reason &2", ttlocal-mark.errorCode, ttlocal-mark.reason)).
           END.            
           ELSE IF ttlocal-mark.code <> 0 THEN DO:                             
              ASSIGN
                 mCheckSts = 0
                 mCheckStsOff = 3              
                 vErrSts = vErrTxt.
              dbgPrint("marking.log", SUBSTITUTE("Ошибка проверки КИ в ЛМ ЧЗ. Ошибка Code &1 Описание &2", ttlocal-mark.code, ttlocal-mark.description)).
           END.
           IF mReqId = "" OR 
              mReqTimestamp = "" OR 
              mInst = "" OR 
              mVersion = "" 
           THEN DO:
              ASSIGN                              
                 mCheckSts = 0
                 mCheckStsOff = 3              
                 vErrSts = vErrTxt.
              dbgPrint("marking.log", 
                       SUBSTITUTE("Ошибка проверки КИ в ЛМ ЧЗ. Не определился один из обязательных параметров: ReqId &1 ReqTimestamp &2 Inst &3 Version &4 ",
                                  mReqId, mReqTimestamp, mInst, mVersion)).
           END.
           ELSE IF NOT AVAIL ttlocal-mark-code THEN DO:
              ASSIGN                              
                 mCheckSts = 0
                 mCheckStsOff = 3              
                 vErrSts = vErrTxt.
              dbgPrint("marking.log", "Ошибка проверки КИ в ЛМ ЧЗ. Не удалось разобрать секцию codes").
           END.
           ELSE DO:
               IF ttlocal-mark-code.isBlocked THEN 
               DO:
                   ASSIGN
                      vChkNotSell = YES /* получили запрет продажи от ЛМ ЧЗ */
                      mCheckStsOff = 0
                      mCheckSts = 0
                      .
                   dbgPrint("marking.log", "КИ в ЛМ ЧЗ помечена как запрещенная к продаже.").
                   vErrSts = "Реализация товара запрещена контролирующими органами. Снимите с продажи и передайте товар управляющему/старшему смены. ".
               END.     
               ELSE DO:
                  ASSIGN
                     mCheckSts = 2
                     mCheckStsOff = 1
                     vErrSts = "". 
                  dbgPrint("marking.log", "Проверка в ЛМ ЧЗ прошла успешно.").
               END.
           END.       
        END.     
        ELSE DO:
            ASSIGN
               mCheckSts = 0         
               mCheckStsOff = 3   
               vErrSts = vErrTxt.
            dbgPrint("marking.log", "Ошибка проверки КИ в ЛМ ЧЗ.").
        END.      
        
        OUTPUT STREAM out_data TO value(vFileLog) APPEND.            
        PUT STREAM out_data UNFORMATTED  
             NOW CHR(9) .
        OUTPUT STREAM out_data CLOSE.
        /* добавляем в лог ответ ЛМ ЧЗ */
        if vlongJson <> "" then
        COPY-LOB FROM vlongJson TO FILE vFileLog APPEND NO-ERROR.  
        else do:
            OUTPUT STREAM out_data TO value(vFileLog) APPEND.            
            PUT STREAM out_data UNFORMATTED  
                "Отсутствует ответ ЛМ ЧЗ".
            OUTPUT STREAM out_data CLOSE.        
        end.               
     END.
     /* нет файла офлайн проверки */ 
     ELSE DO:
        ASSIGN
           mCheckSts = 0
           mCheckStsOff = 3        
           vErrSts = vErrTxt.
        dbgPrint("marking.log", "Отсутствует файл офлайн проверки в ЛМ ЧЗ.").
        OUTPUT STREAM out_data TO value(vFileLog) APPEND.            
        PUT STREAM out_data UNFORMATTED  
             NOW CHR(9) "Отсутствует ответ ЛМ ЧЗ".
        OUTPUT STREAM out_data CLOSE.
     END.
     
     /* если НП не наступил и нет запрета продажи марки от ЛМ ЧЗ, 
     ** а с модулем что-то не так, то разрешаем продавать */
     IF mCheckSts = 0 AND NOT vChkNotSell 
     AND (TODAY < gismt-OflineDate 
          OR mCheckGisMT = 2)
     THEN  do:
         ASSIGN
            mCheckSts = 2
            mCheckStsOff = 2  
            vErrSts = "".                     
         dbgPrint("marking.log", SUBSTITUTE("Разрешаем продавать при отсутствии ответа от ЛМ ЧЗ. mCheckSts &4 vChkNotSell &1 gismt-OflineDate &2 mCheckGisMT &3 mCheckStsOff &5",
                                            vChkNotSell, gismt-OflineDate, mCheckGisMT, mCheckSts, mCheckStsOff)).   
     end.
     else do:         
         IF mCheckSts = 0 then
            dbgPrint("marking.log", SUBSTITUTE("Не разрешаем продавать. mCheckSts &4 vChkNotSell &1 gismt-OflineDate &2 mCheckGisMT &3 mCheckStsOff &5",
                                               vChkNotSell, gismt-OflineDate, mCheckGisMT, mCheckSts, mCheckStsOff)).
         else
            dbgPrint("marking.log", SUBSTITUTE("Разрешаем продавать. mCheckSts &4 vChkNotSell &1 gismt-OflineDate &2 mCheckGisMT &3 mCheckStsOff &5",
                                               vChkNotSell, gismt-OflineDate, mCheckGisMT, mCheckSts, mCheckStsOff)).                
     end.    
     RETURN vErrSts.        
  END.
  
    /* Запуск офлайн проверка марки в ЛМ ЧЗ */
  METHOD PRIVATE INTEGER GetResLocalMark (    
    vDataMarkLM AS CHARACTER 
  ):
    DEFINE VARIABLE vMarkShort AS CHARACTER NO-UNDO.
    DEFINE VARIABLE vFileResOf AS CHARACTER NO-UNDO.
    DEFINE VARIABLE vFileResOfErr AS CHARACTER NO-UNDO.
    DEFINE VARIABLE vFileBatOf AS CHARACTER NO-UNDO.
     
         
    DEFINE VARIABLE vBefCurl AS DATETIME-TZ NO-UNDO. 
    DEFINE VARIABLE vAftCurl AS DATETIME-TZ NO-UNDO.
    DEFINE VARIABLE vpid     AS INTEGER     NO-UNDO.
    DEFINE VARIABLE vTimePause AS INTEGER   NO-UNDO.
    DEFINE VARIABLE vRetVal AS INTEGER   NO-UNDO.
    DEFINE VARIABLE cmd AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE vlongJson AS LONGCHAR NO-UNDO.
    DEFINE VARIABLE vlongJson2 AS LONGCHAR NO-UNDO.
    DEFINE VARIABLE vCh AS CHARACTER NO-UNDO. 
    DEFINE VARIABLE vNumCode AS INTEGER NO-UNDO.
    DEFINE VARIABLE vNumCode2 AS INTEGER NO-UNDO.
    DEFINE VARIABLE vcmdof AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE vpidof AS INTEGER     NO-UNDO.
               
    /*vMarkShort = percentCoding(mark-short). 
    dbgPrint("marking.log", SUBSTITUTE("Сконвертированная КИ: &1 ", vMarkShort)).*/               
    RUN gbl/_tmpfile.p ( "ChkLMRes", ".txt", OUTPUT vFileResOf ) .
    CREATE tt-file-name.
    ASSIGN tt-file-name.tmpFileName = vFileResOf
           tt-file-name.ofline = YES.           
    RUN gbl/_tmpfile.p ( "ChkLMResErr", ".txt", OUTPUT vFileResOfErr ) .
    CREATE tt-file-name.
    ASSIGN tt-file-name.tmpFileName = vFileResOfErr.
    RUN gbl/_tmpfile.p ( "ChkLM", ".bat", OUTPUT vFileBatOf ) .     
    CREATE tt-file-name.
    ASSIGN tt-file-name.tmpFileName = vFileBatOf.
   
    dbgPrint("marking.log", SUBSTITUTE("vFileResOf &1 ", vFileResOf)).           
    dbgPrint("marking.log", SUBSTITUTE("vFileResOfErr &1 ", vFileResOfErr)).
    dbgPrint("marking.log", SUBSTITUTE("vFileBatOf &1 ", vFileBatOf)).
                     
    vcmdof = SUBSTITUTE ('&1 --connect-timeout &6 --max-time &6 -X POST -H "Accept: application/json" -H &2 --data @&7 &3 >&4 --stderr &5',
                          SEARCH ("exe/curl.exe"), /*1*/                                                                  
                          QUOTER("Authorization: Basic " + gismt-OflineAutoriz), /*2*/
                          QUOTER(gismt-OflineAdress + "/cis/outCheck"), /*3*/
                          vFileResOf,             /*4*/                      
                          vFileResOfErr,          /*5*/                      
                          TRIM(REPLACE(STRING(gismt-WaitTime, "zzzz9.99999"),".",","),""), /*6*/
                          searchfile(vDataMarkLM)).         /*7*/
                          
    dbgPrint("marking.log", "vcmdof: " + vcmdof).         
    vBefCurl = NOW.         
    vpidof = runProcFile(vcmdof, vFileBatOf).
    
    /* ждем окончания работы */
    block_wait:
    DO WHILE TRUE:
        /* проверка, работает ли еще процесс */                
        IF searchFile(vfileresOf) <> ? THEN DO:
            FILE-INFO:FILE-NAME = searchFile(vfileresOf).
            IF FILE-INFO:FILE-SIZE <> 0 THEN DO:
               COPY-LOB FROM FILE vFileResOf TO vlongJson NO-ERROR.
               IF (vlongJson BEGINS "<html>" AND 
                   r-index(vlongJson,"</html>") > 0)
                  OR
                  (R-INDEX(vlongJson,"reqTimestamp") > 0 AND
                   r-index(SUBSTRING(vlongJson,R-INDEX(vlongJson,"reqTimestamp")),"}") > 0) 
                  OR r-index(vlongJson,'"codes":[]}') > 0  
               THEN DO:
                   dbgPrint("marking.log", SUBSTITUTE("Сформирован файл-ответ от ЛМ ЧЗ &1", vfileresOf)).                   
                   LEAVE block_wait.
               END.               
            END.               
        END.    
        
        /* время ожидания вышло */
        IF vBefCurl + Int(gismt-WaitTime * 1000) < NOW THEN DO:         
           dbgPrint("marking.log", "Время ожидания работы curl истекло").
           LEAVE block_wait.
        END.
        /* немного ждем */
        vTimePause = NOW - (vBefCurl + Int(gismt-WaitTime * 1000)) + 10. 
        IF vTimePause < -10 THEN       
           RUN gbl/pause.p(10).
        ELSE IF vTimePause < 0 AND vTimePause > -10
        THEN       
           RUN gbl/pause.p(0 - vTimePause).    
    END.
    vAftCurl = NOW.
    dbgPrint("marking.log", SUBSTITUTE("Время работы curl: Начало &1 Окончание &2 Всего (мс) &3  ", vBefCurl, vAftCurl, vAftCurl - vBefCurl)).
    RETURN 1.
 END.   
  
  METHOD PRIVATE VOID DelTmpFile(
      iOfline AS LOGICAL
      ):
      FOR EACH tt-file-name WHERE tt-file-name.ofline = iOfline:          
          IF NOT SESSION:DEBUG-ALERT
          THEN DO:
             /*dbgPrint("marking.log", substitute("Удаляем временный файл &1  ", tt-file-name.tmpFileName)).*/ 
             IF searchFile(tt-file-name.tmpFileName) <> ? THEN DO:
                 OS-DELETE silent value(tt-file-name.tmpFileName).             
                 /*if searchFile(tt-file-name.tmpFileName) <> ? then 
                 dbgPrint("marking.log", substitute("Ошибка удаления файла &1 ", tt-file-name.tmpFileName)).*/
             END.
             IF searchFile(tt-file-name.tmpFileName) = ? THEN
             DELETE tt-file-name.           
          END. 
          ELSE DELETE tt-file-name.                    
      END. 
  END METHOD.
  
  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
  /* преобразует строку с заменой спецсимволов значениями hex  */
  METHOD PUBLIC CHARACTER percentCoding(decode-str AS CHAR):
    DEFINE VARIABLE ii AS INTEGER NO-UNDO.
    DEFINE VARIABLE encode-str AS CHARACTER NO-UNDO.
    DEFINE VARIABLE vsimb  AS CHARACTER NO-UNDO.            
    DEFINE VARIABLE spec-str  AS CHARACTER INIT "~"!#$%&'()*+,-./:;<=>?@[\]^{}" NO-UNDO.    
    DEFINE VARIABLE vInd AS INTEGER NO-UNDO.
    
    encode-str = "".
    DO ii = 1 TO LENGTH (decode-str):
      vsimb = SUBSTRING(decode-str,ii,1).    
      vInd = INDEX(spec-str,vsimb).                   
      encode-str = encode-str + (IF vInd = 0 THEN vsimb ELSE ("%%" + hexencode(vsimb))).       
    END.      
    RETURN encode-str.
  END METHOD.
      
  /* возвращает значение HEX символа */
  METHOD PUBLIC CHARACTER hexencode(decode-chr AS CHAR):
    DEFINE VARIABLE vRaw       AS RAW NO-UNDO.
    DEFINE VARIABLE encode-chr AS CHARACTER NO-UNDO.
    
    LENGTH(vRaw) = 1.
    put-string(vRaw, 1, 1) = decode-chr.  
    encode-chr  = HEX-ENCODE(vRaw).        
    LENGTH(vRaw) = 0.
    RETURN encode-chr.
  END METHOD.       

  /*------------------------------------------------------------------------------
   Purpose:  Выполняет проверку отсканированной марки при добавлении в документ
   Notes:
  ------------------------------------------------------------------------------*/
  define variable vMsg as character no-undo. 
  define frame fMsg
    vMsg format "x(72)" no-label skip
    with view-as dialog-box side-labels three-d
  .
  
  /* Проверка марки при списании / производстве
  ** возвращает: 0 - проверка отрицательная , 1 - проверка положительная, 2 - нет ответа от ГИС МТ (и офлайн не запускали)*/
  METHOD PUBLIC INTEGER checkScanMark (
    iObjCode AS INTEGER, 
    iMark AS CHARACTER, 
    iMarkShort AS CHARACTER,
    iRunOffLine AS LOGICAL,
    OUTPUT oRunedOffLine AS LOGICAL
  ):
    
    DEFINE VARIABLE vAccMarkCheck AS CHARACTER NO-UNDO. 
    DEFINE VARIABLE vMarkGs       AS CHARACTER NO-UNDO.
    DEFINE VARIABLE vChkScanSts   AS INTEGER   NO-UNDO. 
     
    DEFINE BUFFER buf_marking FOR ub.marking.
    
    dbgPrint("marking.log", SUBSTITUTE("Проверка марки для документа iObjCode &1 iMark &2 iMarkShort &3 iRunOffLine &4", 
                                       iObjCode,
                                       iMark,
                                       iMarkShort,
                                       iRunOffLine)).
                                       
    gismt-WaitTimePlus = 3.     /* Увеличим время ожидания ответа на 3 сек. */
    oRunedOffLine = false.
    IF iMarkShort = ? THEN
    DO:
      iMarkShort = GetCodeIdent(iMark).
      IF iMarkShort = "" OR iMarkShort = ? THEN 
        RETURN 2.
    END.   
      
    assign
      mCheckGisMT = 0 
      vMarkGs     = addGs2Mark(iMark)
      mMarkOrig   = vMarkGs    /* заполним переменную для лога */
    .
    dbgPrint("marking.log", SUBSTITUTE("Отправка марки в ГИС МТ: &1 -> &2.", 
                                       iMark,
                                       replace(vMarkGs,chr(29),"<gs>"))).
    vMsg = "Идет проверка марки, пожалуйста, подождите.".
    frame fMsg:visible = true.
    display vMsg with frame fMsg.
    vAccMarkCheck = ChekAccessMark({&shop},iObjCode,vMarkGs,iMarkShort).
    hide frame fMsg.           
    dbgPrint("marking.log", SUBSTITUTE("Проверка ГИС МТ: &1 Статус: &2 mReqId &3 mReqTimeStamp &4 mCheckGisMT &5", 
                                       vAccMarkCheck, 
                                       mCheckSts,
                                       mReqId,
                                       mReqTimeStamp,
                                       mCheckGisMT)).                                      
    /* если марки нет в ГИС МТ (found = false), то  сразу выходим */
    IF mCheckSts = 3 THEN vChkScanSts = 0.          
    /* Если прошло более 72ч с момента отсутствия ответа ГИС МТ  - для этих проверок не контролируем */
    ELSE IF mCheckSts = 4 THEN vChkScanSts = 2.
    ELSE vChkScanSts = mCheckSts.                       
    
    /* если не проверяем офлайн, то запрещаем продавать при отсутствии ответа, и разрешаем при аварии */
    IF NOT iRunOffLine AND vChkScanSts = 2 THEN DO:                        
        CASE mCheckGisMT:
           /* ответа от ЛМ ЧЗ не получено */
           WHEN 0 THEN 
           DO:
              vChkScanSts = 2.
           END.
           /* проверка онлайн прошла, только срок годности не проверили */
           WHEN 1 THEN 
           DO:
              vChkScanSts = 1.
           END.
           /* при аварии разрешаем продавать */
           WHEN 2 THEN 
           DO:
              vChkScanSts = 1.
           END.          
        END CASE.          
    END.       
       
    /* если надо проверять офлайн  */
    IF iRunOffLine THEN DO:
       /* проверка онлайн прошла, только срок годности не проверили */ 
       IF mCheckGisMT = 1 AND vChkScanSts = 2  THEN vChkScanSts = 1.
       
       /* если аварийная ситуация, или не было ответа от ГИС МТ */ 
       IF (vChkScanSts = 2 AND mCheckGisMT = 0) OR mCheckGisMT = 2
       THEN DO: 
           oRunedOffLine = true.
           /*gismt-OflineDate = today + 2.*/
           vAccMarkCheck = ChekLocalMark(iMarkShort).
           vChkScanSts = mCheckStsOff.            
       END.
    END.                 
    dbgPrint("marking.log", SUBSTITUTE("Результат проверки ГИС МТ и ЛМ ЧЗ: &1 Проверка офлайн &2", 
                                       vChkScanSts, 
                                       oRunedOffLine)).  
    RETURN vChkScanSts.
  END METHOD.
  
  /*------------------------------------------------------------------------------
   Purpose:
   Notes:  Проверка срока годности  
  ------------------------------------------------------------------------------*/
  METHOD PUBLIC CHARACTER ChekExpirationDate (       
      p-obj-type  AS CHARACTER, 
      p-obj-code  AS INTEGER,
      buffer buf_marking for ub.marking):
         
      DEFINE VARIABLE vExpireDate AS DATETIME-TZ NO-UNDO.
      DEFINE VARIABLE vCheckDate  AS LOGICAL     NO-UNDO.
      DEFINE VARIABLE vRetProp    AS CHARACTER   NO-UNDO.
      DEFINE VARIABLE vErrTxt     AS CHARACTER   NO-UNDO.      
      
      DEFINE BUFFER buf_sys-ctrl     FOR ub.sys-ctrl.            
            
      /* Перевычисляем тип, потому что может быть вызов извне - проверка ТОЛЬКО по сроку годности! */             
      IF AVAILABLE buf_marking THEN
      DO:
         mTypeMark = "".
         ChekTypeMarkByDm(buf_marking.mark) .
      END.   
            
      dbgPrint("marking.log", SUBSTITUTE("Проверка срока годности для типа марки &1 марка &2",
                                         mTypeMark,
                                         (IF AVAILABLE buf_marking then buf_marking.mark else mark))). 
                                                  
      if mTypeMark = ""
      then do :
         ASSIGN
           vErrTxt = "Не опредлен тип маркировки товара. "
           mCheckSts = 0
           . 
      end .
                   
      IF mTypeMark > "" THEN
         vCheckDate = GetMarkProp (p-obj-type,
                                   p-obj-code,
                                   {&attr-marking_checkDate},
                                   mTypeMark).
      dbgPrint("marking.log", SUBSTITUTE("Требуется ли проверять срок годности &1", vCheckDate)).                              
      /* если по данному типу марки включена настройка проверять срок годности */                              
      IF vCheckDate THEN DO:
         /* могли еще не считывать настройки подключения к ГИС МТ (когда была проверка в ТС ПИоТ) */            
         /*IF gismt-UpdateRequest AND StatusPOS = ? THEN DO:
            FIND FIRST buf_sys-ctrl NO-LOCK NO-ERROR.
            IF AVAILABLE buf_sys-ctrl AND buf_sys-ctrl.db-num <> 0 
            THEN          
                vRetProp = get-gismt-prop ({&db},
                                           buf_sys-ctrl.db-num) NO-ERROR.                                          
         END.*/                               
         
         IF AVAILABLE buf_marking
             AND buf_marking.expDate <> ?           
         THEN vExpireDate = datetime-tz(ENTRY(1,buf_marking.expDate,".")) NO-ERROR.
     
         /* срок годности не задан на марке */
         IF vExpireDate = ?
         THEN DO:
            /* если была проверка на кассе, то при отсутствии даты меняем статус на 2 */
            IF (StatusPos = 1 OR StatusPos = 2)
               AND mCheckSts = 1 
            THEN mCheckSts = 2 .  
            dbgPrint("marking.log", SUBSTITUTE("Срок годности для марки &1 по данным из 1С отсутствует. Дата &2. Проверить срок годности не удалось.",
                                               (IF AVAILABLE buf_marking then buf_marking.mark ELSE "<не найдена>"),
                                               (IF AVAILABLE buf_marking then buf_marking.expDate ELSE ""))). 
         END.    
         /* срок годности прошел */
         ELSE IF vExpireDate < NOW + gismt-BanDate * 60 * 1000
         THEN DO:
            ASSIGN
               vErrTxt   = substitute("Срок годности товара истек &1.", substring(string(vExpireDate,"99/99/9999 HH:MM+HH:MM"), 1, 16))
               mCheckSts = 0
               .
            LogWrite:WriteFileToLog(SUBSTITUTE("Проверка срока годности не прошла: марка &1 срок годности &2",buf_marking.mark,string(vExpireDate,"99/99/9999 HH:MM"))).   
            dbgPrint("marking.log", SUBSTITUTE("Срок годности по данным из 1С: &1 . Товар просрочен, заблокирован к продаже.",
                                               vExpireDate)). 
         END.
         ELSE DO:
            /* если была проверка на кассе, то при успешной проверке даты меняем статус на 1 */
            IF (StatusPos = 1 OR StatusPos = 2)
               AND mCheckSts = 2 
            THEN mCheckSts = 1 . 
            LogWrite:WriteFileToLog(SUBSTITUTE("Проверка срока годности прошла успешно: марка &1 срок годности &2",buf_marking.mark,string(vExpireDate,"99/99/9999 HH:MM"))). 
            dbgPrint("marking.log", SUBSTITUTE("Срок годности по данным из 1С: &1 . Проверка прошла успешно.",
                                                vExpireDate)).
         END.
                                            
      END.                                         
      /* если была проверка на кассе, то при не нужности проверки даты меняем статус на 1 */
      ELSE IF (StatusPos = 2 AND mCheckSts = 2)
           THEN mCheckSts = 1.               
                                
      RETURN vErrTxt.
  END METHOD.
   
  /*------------------------------------------------------------------------------
   Purpose:
   Notes:  устанавливает online-result 
  ------------------------------------------------------------------------------*/
  METHOD PRIVATE VOID setOnlineResult(buffer buf_marking for ub.marking):
      
    /* если была онлайн проверка на кассе, то сохраняем результат проверки пришедший от кассы
    ** (потом он меняется при проверке срока годности 1С */
    IF statusPOS <> ? AND mCheckGisMT = 1
    THEN ASSIGN
            buf_marking.online-result = mCheckStsSave
            mSaveOnlineResult = yes
            .
    /* иначе старый алгоритм */   
    ELSE DO:   
       IF (mCheckSts = 0 AND mCheckGisMT = 1) OR mCheckSts = 3    /* Оборот запрещен ошибки errorcode (1, …11) */
       THEN
         buf_marking.online-result = 0.  
       ELSE IF mCheckSts = 2 AND mCheckGisMT = 1  /* нет срока годности, а проверка его включена */
       THEN  
         buf_marking.online-result = 2.
       ELSE IF mCheckSts = 1 AND mCheckGisMT = 1  /* Оборот разрешен */
       THEN
         buf_marking.online-result = 1.
    END.  
    dbgprint("marking.log", SUBSTITUTE("Установка марке &1 результата проверки онлайн &2, mCheckSts &3 mCheckGisMT &4 ",
                                       buf_marking.mark, buf_marking.online-result, mCheckSts, mCheckGisMT )). 
  END METHOD.
  
  /* возвращает результат сохраненного ответа онлайн */
  METHOD PUBLIC CHARACTER GetMarkOnlineResult():
    define variable mark-short as character no-undo. 
    
    mark-short = GetCodeIdent(mark).   
    IF mSaveOnlineResult = yes THEN             
       RETURN substitute("&1&2&3",mark-short,chr(9),mCheckStsSave).
    ELSE 
       RETURN "".
    
  END METHOD.
      
	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	DESTRUCTOR PUBLIC marking ( ):
      DELETE OBJECT cashSts.      
	END DESTRUCTOR.
  
  
END CLASS.  

