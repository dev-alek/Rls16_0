/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Собраны процедуры работы с договорами  Master\Slave

Автор: Носко Игорь Александрович
Дата создания: 08/02/2011
Author: Nosko Igor
Creation date: 08/02/2011

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

{str/cont-ms-def.i}
{str/contattr.i}

/*  */
FUNCTION Is-MS-Contract RETURN LOGICAL(BUFFER buf_Master FOR ub.Contract, BUFFER buf_Slave  FOR ub.Contract) FORWARD.
FUNCTION Is-Master-Slave-Contract RETURN CHARACTER( BUFFER buf_Contract FOR ub.Contract) FORWARD.
FUNCTION Is-MS-Contract-Int RETURN INTEGER (BUFFER buf_Contract FOR ub.Contract) FORWARD.

/* Поля подчиненного договора не подежащие модификации от мастер договора  */
&SCOPED-DEFINE FIELD_NOT_COPY_CONTRACT  ~
Host-code                               ~
Contract-code                           ~
Own-name                                ~
an-uchet-code-out                       ~
cel-nazn-code-out                       ~
cor-acc-out                             ~
cor-acc1-out                            ~
an-uchet-code-in                        ~
cel-nazn-code-in                        ~
cor-acc-in                              ~
cor-acc1-in                             ~
an-uchet-code-out-cash                  ~
cel-nazn-code-out-cash                  ~
cor-acc-out-cash                        ~
cor-acc1-out-cash                       ~
an-uchet-code-in-cash                   ~
cel-nazn-code-in-cash                   ~
cor-acc-in-cash                         ~
cor-acc1-in-cash                        ~
an-uchet-code-out-payoff                ~
cel-nazn-code-out-payoff                ~
cor-acc-out-payoff                      ~
cor-acc1-out-payoff                     ~
an-uchet-code-in-payoff                 ~
cel-nazn-code-in-payoff                 ~
cor-acc-in-payoff                       ~
cor-acc1-in-payoff                      ~
transport-cli-type                      ~
transport-cli-code                      ~
transport-host                          ~
transport-contract                      ~
transport-uslov                         ~
transport-value                         ~
own-code-schet-start                    ~
own-sign-post                           ~
own-sign                                ~
contract-city                           ~
fin-VAT-pc                              ~
srok-opl                                ~
gen-factur-srok                         ~
own-addres                              ~
own-inn                                 ~
own-kpp                                 ~
/*  */

/* Чтобы не мешалось  */
&SCOPED-DEFINE ERROR_UNDO_RETRY  ~
   IF ERROR-STATUS:ERROR THEN    ~
      UNDO Tran, RETRY Tran.     ~   

&SCOPED-DEFINE IF_RETRY_THEN_DO ~
   IF RETRY THEN DO: ~
      cError = "Ошибка транзакции ":U + PROGRAM-NAME(1) + ERROR-STATUS:GET-MESSAGE(1) + " " + RETURN-VALUE. ~
       UNDO Tran, LEAVE Tran. ~
   END. ~


/*************
               Процедура удаления спецификации договора
               На входе буфер договора
               Выход: cError - возможно какая либо ошибка
*************/
PROCEDURE Delete-Contract-Specif:
   DEFINE PARAMETER BUFFER buf_Contract FOR ub.Contract.
   DEFINE OUTPUT PARAMETER cError AS CHARACTER NO-UNDO INITIAL "".
   /*  */
   DEFINE BUFFER buf_Specif      FOR ub.Contract-Specif.
   DEFINE BUFFER buf_Specif-Attr FOR ub.Contract-Specif-Attr.
   /*  */
   Tran:
   DO TRANSACTION
      ON ENDKEY UNDO Tran, RETRY Tran
      ON ERROR  UNDO Tran, RETRY Tran
      ON QUIT   UNDO Tran, RETRY Tran
      ON STOP   UNDO Tran, RETRY Tran:
      {&IF_RETRY_THEN_DO}
      /* Вначале удаляем аттрибуты спецификации по всему договору  */
      FOR EACH buf_Specif-Attr WHERE
               buf_Specif-Attr.Host-code     = buf_Contract.Host-code
           AND buf_Specif-Attr.Contract-Num  = buf_Contract.Contract-code
          EXCLUSIVE-LOCK:
          DELETE buf_Specif-Attr NO-ERROR.
          {&ERROR_UNDO_RETRY}
      END.
      /*  */
      /* Удаление самой спецификации  */
      FOR EACH buf_Specif WHERE
               buf_Specif.Host-code     = buf_Contract.Host-code
           AND buf_Specif.Contract-Num  = buf_Contract.Contract-code
          EXCLUSIVE-LOCK:
          DELETE buf_Specif NO-ERROR.
         {&ERROR_UNDO_RETRY}
      END.
   END. /* Tran */
   /*  */
   RETURN.
END PROCEDURE.

/*************
               Процедура модификации подчиненных договоров.
               На входе
                  1) BUFFER мастер договора
               Выход: cError - возможно какая либо ошибка
************/
PROCEDURE Modify-Slave-Contract:
   DEFINE PARAMETER BUFFER buf_Master FOR ub.Contract.
   DEFINE OUTPUT PARAMETER cError AS CHARACTER NO-UNDO INITIAL "".
   /*  */
   DEFINE BUFFER buf_Ext-Classif FOR ub.Ext-classif.
   DEFINE BUFFER buf_Slave FOR ub.Contract.
   /*  */
   Tran:
   DO TRANSACTION
      ON ENDKEY UNDO Tran, RETRY Tran
      ON ERROR  UNDO Tran, RETRY Tran
      ON QUIT   UNDO Tran, RETRY Tran
      ON STOP   UNDO Tran, RETRY Tran:
      {&IF_RETRY_THEN_DO}
      FOR EACH buf_Ext-Classif WHERE
               buf_Ext-Classif.Classif-name = v-S_CONTRACT
           AND buf_Ext-Classif.CharKey_One  = STRING(buf_Master.Host-Code) + v-DELIM_CHR_3 + STRING(buf_Master.Contract-code)
           AND buf_Ext-Classif.DB-num       = buf_Master.Db-num  /*  */
          NO-LOCK,
          FIRST buf_Slave WHERE
                buf_Slave.Host-Code     = INTEGER(ENTRY(1, buf_Ext-classif.charKey_Two, v-DELIM_CHR_3))
            AND buf_Slave.Contract-code = INTEGER(ENTRY(2, buf_Ext-classif.charKey_Two, v-DELIM_CHR_3))
          EXCLUSIVE-LOCK:
          /*  */
          BUFFER-COPY
            buf_Master
          EXCEPT
            {&FIELD_NOT_COPY_CONTRACT}
          TO buf_Slave
          NO-ERROR.
          {&ERROR_UNDO_RETRY}
          RELEASE buf_Slave NO-ERROR.
          {&ERROR_UNDO_RETRY}
      END.
   END. /* Tran */
   /*  */
   RETURN.
   /*  */
END PROCEDURE.


/*************
               Процедура изменения статуса подчиненных договоров
               На входе
                  1) BUFFER мастер договора
                  2) статус договора
               Выход: cError - возможно какая либо ошибка
************/
PROCEDURE Change-Stat-Slave-Contract:
   DEFINE PARAMETER BUFFER buf_Master FOR ub.Contract.
   DEFINE INPUT PARAMETER cStatus  AS CHARACTER NO-UNDO.
   DEFINE OUTPUT PARAMETER cError AS CHARACTER NO-UNDO INITIAL "".
   /*  */
   DEFINE BUFFER buf_Ext-Classif FOR ub.Ext-classif.
   DEFINE BUFFER buf_Slave FOR ub.Contract.
   /*  */
   Tran:
   DO TRANSACTION
      ON ENDKEY UNDO Tran, RETRY Tran
      ON ERROR  UNDO Tran, RETRY Tran
      ON QUIT   UNDO Tran, RETRY Tran
      ON STOP   UNDO Tran, RETRY Tran:
      {&IF_RETRY_THEN_DO}
      FOR EACH buf_Ext-Classif WHERE
               buf_Ext-Classif.Classif-name = v-S_CONTRACT
           AND buf_Ext-Classif.CharKey_One  = STRING(buf_Master.Host-Code) + v-DELIM_CHR_3 + STRING(buf_Master.Contract-code)
           AND buf_Ext-Classif.DB-num       = buf_Master.Db-num  /* считаем что связь может быть только внутри одной БД  */
          NO-LOCK,
          FIRST buf_Slave WHERE
                buf_Slave.Host-Code     = INTEGER(ENTRY(1, buf_Ext-classif.charKey_Two, v-DELIM_CHR_3))
            AND buf_Slave.Contract-code = INTEGER(ENTRY(2, buf_Ext-classif.charKey_Two, v-DELIM_CHR_3))
          EXCLUSIVE-LOCK:
          ASSIGN
             buf_Slave.Status_ = cStatus
             NO-ERROR.
          {&ERROR_UNDO_RETRY}
          RELEASE buf_Slave NO-ERROR.
          {&ERROR_UNDO_RETRY}
      END.
   END. /* Tran */
   /*  */
   RETURN.
   /*  */
END PROCEDURE.




/*************
               Процедура удаления связи ext-classif между мастер и подчиненным договором
               На входе два буфера договора
               Выход: cError - возможно какая либо ошибка
*************/
PROCEDURE Delete-Ref-Master-Slave:
   DEFINE PARAMETER BUFFER buf_Master FOR ub.Contract.
   DEFINE PARAMETER BUFFER buf_Slave  FOR ub.Contract.
   DEFINE OUTPUT PARAMETER cError AS CHARACTER NO-UNDO INITIAL "".
   /*  */
   DEFINE BUFFER buf_Ext-Classif FOR ub.Ext-classif.
   /*  */
   IF NOT Is-MS-Contract(BUFFER buf_Master, BUFFER buf_Slave) THEN DO:
      cError = PROGRAM-NAME(1) + ":" + "Между договорами нет связи Master->Slave".
      RETURN.
   END.
   /*  */
   Tran:
   FOR FIRST buf_Ext-Classif WHERE
             buf_Ext-Classif.Classif-name = v-S_CONTRACT
         AND buf_Ext-Classif.CharKey_One  = STRING(buf_Master.Host-Code) + v-DELIM_CHR_3 + STRING(buf_Master.Contract-code)
         AND buf_Ext-Classif.CharKey_Two  = STRING(buf_Slave.Host-Code)  + v-DELIM_CHR_3 + STRING(buf_Slave.Contract-code)
         AND buf_Ext-Classif.DB-num       = buf_Master.Db-num  /* считаем что связь может быть только внутри одной БД  */
       EXCLUSIVE-LOCK
       TRANSACTION
       ON ENDKEY UNDO Tran, RETRY Tran
       ON ERROR  UNDO Tran, RETRY Tran
       ON QUIT   UNDO Tran, RETRY Tran
       ON STOP   UNDO Tran, RETRY Tran:
       /* */
       {&IF_RETRY_THEN_DO}
       /*  */
       DELETE buf_Ext-Classif NO-ERROR.
       {&ERROR_UNDO_RETRY}
   END. /* Tran  */
   /*  */
   RETURN.
   /*  */
END PROCEDURE.



/*************
               Процедура сооздания связи ext-classif между мастер и подчиненным договором
               На входе два буфера договора
               Выход: cError - возможно какая либо ошибка
*************/
PROCEDURE Create-Ref-Master-Slave:
   DEFINE PARAMETER BUFFER buf_Master FOR ub.Contract.
   DEFINE PARAMETER BUFFER buf_Slave  FOR ub.Contract.
   DEFINE OUTPUT PARAMETER cError AS CHARACTER NO-UNDO INITIAL "".
   /*  */
   DEFINE BUFFER buf_Ext-Classif FOR ub.Ext-classif.
   /*  */
   DEFINE VARIABLE cKeyRec AS CHARACTER NO-UNDO INITIAL "".
   /*  */
   IF Is-MS-Contract(BUFFER buf_Master, BUFFER buf_Slave) THEN DO:
      cError = PROGRAM-NAME(1) + ":" + "Между договорами  уже есть связь Master->Slave".
      RETURN.
   END.

   RUN gen-key-rec IN THIS-PROCEDURE(
       INPUT  v-S_CONTRACT,
       INPUT  BUFFER buf_Master:HANDLE,
       OUTPUT cKeyRec
       ) NO-ERROR.
   IF ERROR-STATUS:ERROR THEN DO:
      cError = PROGRAM-NAME(1) + ":" + ERROR-STATUS:GET-MESSAGE(1) + " " + RETURN-VALUE.
      RETURN.
   END.
   /*  */
   Tran:
   DO TRANSACTION
      ON ENDKEY UNDO Tran, RETRY Tran
      ON ERROR  UNDO Tran, RETRY Tran
      ON QUIT   UNDO Tran, RETRY Tran
      ON STOP   UNDO Tran, RETRY Tran:
      /* */
      {&IF_RETRY_THEN_DO}
      /*  */
      CREATE buf_Ext-Classif NO-ERROR.
      {&ERROR_UNDO_RETRY}
      ASSIGN
         buf_Ext-Classif.Classif-name    = v-S_CONTRACT
         buf_Ext-Classif.Classif-subject = v-S_CONTRACT
         buf_Ext-Classif.CharKey_One     = STRING(buf_Master.Host-Code) + v-DELIM_CHR_3 + STRING(buf_Master.Contract-code)
         buf_Ext-Classif.CharKey_Two     = STRING(buf_Slave.Host-Code)  + v-DELIM_CHR_3 + STRING(buf_Slave.Contract-code)
         buf_Ext-Classif.DB-num          = buf_Master.Db-num  /* считаем что связь может быть только внутри одной БД  */
         buf_Ext-Classif.Uniq-key-rec    = cKeyRec
         NO-ERROR.
      {&ERROR_UNDO_RETRY}
      RELEASE buf_Ext-Classif NO-ERROR.
      {&ERROR_UNDO_RETRY}
   END. /* Tran  */
   /*  */
   RETURN.
   /*  */
END PROCEDURE.


/*************
  Функция определяющая признак Мастер или Подчиненного договора
  Для удобства - цифровая
  Возвращает:
    0 -  нет никакой связки (ни Master и ни Slave )
    1 - Master договор
    2 - Slave договор
*************/
FUNCTION Is-MS-Contract-Int-2 RETURN INTEGER (
                              i-Host-Code AS INTEGER,
                              i-Contract-Code AS INTEGER):
   /*  */
   DEFINE BUFFER buf_Contract FOR ub.Contract.
   DEFINE VARIABLE iRet AS INTEGER NO-UNDO INITIAL 0.
   FIND FIRST buf_Contract WHERE
              buf_Contract.Host-Code      = i-Host-Code
          AND buf_Contract.Contract-code  = i-Contract-Code
        NO-LOCK NO-ERROR.
   IF AVAILABLE buf_Contract THEN DO:
      ASSIGN
         iRet = Is-MS-Contract-Int(BUFFER buf_Contract).
   END.
   /*  */
   RETURN (iRet).
END FUNCTION.

/*************
  Функция определяющая признак Мастер или Подчиненного договора
  Для удобства - цифровая
  Возвращает:
    0 -  нет никакой связки (ни Master и ни Slave )
    1 - Master договор
    2 - Slave договор
*************/
FUNCTION Is-MS-Contract-Int RETURN INTEGER (BUFFER buf_Contract FOR ub.Contract):
   /* */
   DEFINE BUFFER buf_Ext-Classif FOR ub.Ext-Classif.
   DEFINE BUFFER buf_Cont        FOR ub.Contract.
   /* */
   DEFINE VARIABLE iRet AS INTEGER NO-UNDO INITIAL 0.
   /* проверка мастер договора */
   FOR FIRST buf_Ext-Classif WHERE
             buf_Ext-Classif.Classif-name = v-S_CONTRACT
        AND  buf_Ext-Classif.CharKey_One  = STRING(buf_Contract.Host-code) + v-DELIM_CHR_3 +
                                            STRING(buf_Contract.contract-code)
        AND  buf_Ext-classif.db-num       = buf_Contract.db-num
       NO-LOCK,
       EACH buf_Cont WHERE
            buf_Cont.Host-code     = INTEGER(ENTRY(1, buf_Ext-classif.charKey_Two, v-DELIM_CHR_3 ))
        AND buf_Cont.Contract-code = INTEGER(ENTRY(2, buf_Ext-classif.charKey_Two, v-DELIM_CHR_3))
       NO-LOCK:
       /* мастер договор !!! */
       ASSIGN
          iRet = 1.
       LEAVE.
   END.
   /* проверка подчиненного договора   */
   IF iRet <> 1 THEN DO:
      FOR FIRST buf_Ext-Classif WHERE
                buf_Ext-Classif.Classif-name = v-S_CONTRACT
           AND  buf_Ext-Classif.CharKey_Two  = STRING(buf_Contract.Host-code) + v-DELIM_CHR_3 +
                                               STRING(buf_Contract.contract-code)
           AND  buf_Ext-classif.db-num       = buf_Contract.db-num
          NO-LOCK,
          EACH buf_Cont WHERE
               buf_Cont.Host-code     = INTEGER(ENTRY(1, buf_Ext-classif.charKey_One, v-DELIM_CHR_3))
           AND buf_Cont.Contract-code = INTEGER(ENTRY(2, buf_Ext-classif.charKey_One, v-DELIM_CHR_3))
          NO-LOCK:
          /* подчиненный договор !!! */
          ASSIGN
             iRet = 2.
          LEAVE.
      END.
   END.
   /* */
   RETURN (iRet).
   /*  */
END FUNCTION.



/*************
  Функция определяющая признак Мастер или Подчиненного договора
  Возвращает:
    1) "+" если это матер договора
    2) "номер мастер дговора - если договор подчиненный"
    3)  "" - у договора нет никакой связки
*************/
FUNCTION Is-Master-Slave-Contract RETURN CHARACTER( BUFFER buf_Contract FOR ub.Contract):
   /* */
   DEFINE BUFFER buf_Ext-Classif FOR ub.Ext-Classif.
   DEFINE BUFFER buf_Cont        FOR ub.Contract.
   /* */
   DEFINE VARIABLE cRet AS CHARACTER NO-UNDO INITIAL "".
   /* проверка мастер договора */
   FOR FIRST buf_Ext-Classif WHERE
             buf_Ext-Classif.Classif-name = v-S_CONTRACT
        AND  buf_Ext-Classif.CharKey_One  = STRING(buf_Contract.Host-code) + v-DELIM_CHR_3 +
                                            STRING(buf_Contract.contract-code)
        AND  buf_Ext-classif.db-num       = buf_Contract.db-num
       NO-LOCK,
       EACH buf_Cont WHERE
            buf_Cont.Host-code     = INTEGER(ENTRY(1, buf_Ext-classif.charKey_Two, v-DELIM_CHR_3 ))
        AND buf_Cont.Contract-code = INTEGER(ENTRY(2, buf_Ext-classif.charKey_Two, v-DELIM_CHR_3))
       NO-LOCK:
       /* мастер договор !!! */
       ASSIGN
          cRet = "+".
       LEAVE.
   END.
   /* проверка подчиненного договора   */
   IF cRet = "" THEN DO:
      FOR FIRST buf_Ext-Classif WHERE
                buf_Ext-Classif.Classif-name = v-S_CONTRACT
           AND  buf_Ext-Classif.CharKey_Two  = STRING(buf_Contract.Host-code) + v-DELIM_CHR_3 +
                                               STRING(buf_Contract.contract-code)
           AND  buf_Ext-classif.db-num       = buf_Contract.db-num
          NO-LOCK,
          EACH buf_Cont WHERE
               buf_Cont.Host-code     = INTEGER(ENTRY(1, buf_Ext-classif.charKey_One, v-DELIM_CHR_3))
           AND buf_Cont.Contract-code = INTEGER(ENTRY(2, buf_Ext-classif.charKey_One, v-DELIM_CHR_3))
          NO-LOCK:
          /* подчиненный договор !!! */
          ASSIGN
             cRet = (IF buf_Cont.Contract-prn-code = "" THEN  STRING(buf_Cont.Contract-code) ELSE buf_Cont.Contract-prn-code).
          LEAVE.
      END.
   END.
   /* */
   RETURN (cRet).
END FUNCTION.

/*  */
/*************
             Проверка наличия связи Master -> Slave договором
*************/
FUNCTION Is-MS-Contract RETURN LOGICAL(
         BUFFER buf_Master FOR ub.Contract,
         BUFFER buf_Slave  FOR ub.Contract):
   /*  */
   DEFINE BUFFER buf_Ext-Classif FOR ub.Ext-classif.
   /*  */
   RETURN CAN-FIND ( FIRST buf_Ext-Classif WHERE
                       buf_Ext-Classif.Classif-name = v-S_CONTRACT
                   AND buf_Ext-Classif.CharKey_One  = STRING(buf_Master.Host-Code) + v-DELIM_CHR_3 + STRING(buf_Master.Contract-code)
                   AND buf_Ext-Classif.CharKey_Two  = STRING(buf_Slave.Host-Code)  + v-DELIM_CHR_3 + STRING(buf_Slave.Contract-code)
                   AND buf_Ext-Classif.DB-num       = buf_Master.Db-num  /* считаем что связь может быть только внутри одной БД  */
                 NO-LOCK).
END FUNCTION.


/*************
             Проверка наличия у мастер договора, подчиненного договора
             по заданной фирме. Если есть - возвращаем номер
             подчиненного договора
             Возвращает 1) "" - нет подиненного договора
                        2) "ERROR:" - связь есть а договора нет
                        3) "Contract-code" - есть подчиненный договор у этой фирмы

*************/
FUNCTION Get-Num-Slave-Contract RETURN CHARACTER(
         BUFFER buf_Master FOR ub.Contract,
         INPUT iSlave-Host-Code AS INTEGER
         ):
   /*  */
   DEFINE BUFFER buf_Ext-Classif FOR ub.Ext-classif.
   DEFINE BUFFER buf_Contract    FOR ub.Contract.
   /*  */
   DEFINE VARIABLE cRet AS CHARACTER NO-UNDO INITIAL "".
   /*  */
   FIND FIRST buf_Ext-Classif WHERE
              buf_Ext-Classif.Classif-name = v-S_CONTRACT
          AND buf_Ext-Classif.CharKey_One  = STRING(buf_Master.Host-Code)  + v-DELIM_CHR_3 + STRING(buf_Master.Contract-code)
          AND buf_Ext-Classif.CharKey_Two  BEGINS STRING(iSlave-Host-Code) + v-DELIM_CHR_3
          AND buf_Ext-Classif.DB-num       = buf_Master.Db-num
        NO-LOCK NO-ERROR.
   IF AVAILABLE buf_Ext-Classif THEN DO:
      IF CAN-FIND (FIRST buf_Contract WHERE
                         buf_Contract.Host-Code     = INTEGER(ENTRY(1, buf_Ext-classif.charKey_Two, v-DELIM_CHR_3))
                     AND buf_Contract.Contract-code = INTEGER(ENTRY(2, buf_Ext-classif.charKey_Two, v-DELIM_CHR_3))
                    NO-LOCK) THEN DO:
         ASSIGN
            cRet = ENTRY(2, buf_Ext-classif.charKey_Two, v-DELIM_CHR_3).
      END. ELSE DO:
         ASSIGN
            cRet = "ERROR:" + "Ошибка связи мастер договора " +
                   STRING(buf_Master.Host-Code) + "," + STRING(buf_Master.Contract-code) + " " +
                   "c Host-code=" + STRING(iSlave-Host-Code).
      END.
   END.
   /*  */
   RETURN (cRet).
END FUNCTION.

/*  */
&UNDEFINE ERROR_UNDO_RETRY 
&UNDEFINE IF_RETRY_THEN_DO
&UNDEFINE FIELD_NOT_COPY_CONTRACT



/* $Workfile$ e n d */