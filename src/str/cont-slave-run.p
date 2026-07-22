block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: cont-slave-run.p $
$Archive: str/cont-slave-run.p $

Запуск процедуры привязки подчиненных договоров 

Автор: Носко Игорь Александрович
Дата создания: 09/02/2011
Author: Nosko Igor
Creation date: 09/02/2011

	Last change:  NIA   1 Mar 2011    1:44 pm
*/

/* Define VSS  */
DEFINE VARIABLE vss-revision    AS CHARACTER NO-UNDO INIT "$Revision: aea5316774be, 0, rls $":U .
DEFINE VARIABLE vss-author      AS CHARACTER NO-UNDO INIT "$Author: expertek $":U .
DEFINE VARIABLE vss-date        AS CHARACTER NO-UNDO INIT "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
DEFINE VARIABLE vss-workfile    AS CHARACTER NO-UNDO INIT "$Workfile: cont-slave-run.p $":U .
DEFINE VARIABLE vss-archive     AS CHARACTER NO-UNDO INIT "$Archive: str/cont-slave-run.p $":U .
DEFINE VARIABLE vss-description AS CHARACTER NO-UNDO INIT "Создает или удаляет подчиненный договор".

/* Инклуды  */ 
{cmp/vssrevis.i}
{cmp/str-glbl.i}
{cmp/showinf.i}
{cmp/library.i}
{trg/new-bcod.i}
{gbl/getcntxt.i def}
{gbl/key-rec.i}
{str/cont-ms.i}


/*  */
FUNCTION PutStr RETURN LOGICAL (INPUT v-cStr AS CHARACTER, INPUT v-lSkip AS LOGICAL) FORWARD.
FUNCTION Get-Name-Org RETURN CHARACTER (INPUT cObj-type AS CHARACTER, INPUT iObj-code AS INTEGER) FORWARD.

/* Чтобы не мешалось  */ 
&SCOPED-DEFINE ERROR_UNDO_RETRY  ~
   IF ERROR-STATUS:ERROR THEN    ~
      UNDO Tran, RETRY Tran.     ~   


/* Параметры  */
DEFINE INPUT PARAMETER   parParentProc     AS WIDGET-HANDLE NO-UNDO. /* Главное окно, всегда передавать  */
DEFINE INPUT parameter   p-CallBack-Handle AS HANDLE        NO-UNDO. /* p-CallBack-Handle */
DEFINE PARAMETER BUFFER  buf_M-Contract    FOR ub.Contract.          /* мастер контракт  */
DEFINE PARAMETER BUFFER  buf_S-Contract    FOR ub.Contract.          /* подчиненный  контракт  */
DEFINE INPUT  PARAMETER  p-cMode           AS CHARACTER NO-UNDO.     /* "add" или "del"*/
DEFINE INPUT  PARAMETER  p-cList-Host      AS CHARACTER NO-UNDO.     /* список фирм  */
DEFINE OUTPUT PARAMETER  p-cError          AS CHARACTER NO-UNDO.     /* возврат ошибки   */
/* Получить контекст ???  */
{gbl/getcntxt.i get}

/*  */
DEFINE STREAM s_Log.

/* */ 
DEFINE BUFFER buf_Contract    FOR ub.Contract.  /* */ 
DEFINE BUFFER buf_Slave       FOR ub.Contract.  /* для ручного выбора договора из интерфейса */

/*  */
DEFINE VARIABLE v-user-action    AS CHARACTER  NO-UNDO.
DEFINE VARIABLE v-printed        AS LOGICAL    NO-UNDO.
DEFINE VARIABLE v-proc-name-err  AS CHARACTER  NO-UNDO.
/* */ 
DEFINE VARIABLE i                   AS INTEGER   NO-UNDO INITIAL 0.
DEFINE VARIABLE v-iNewHost          AS INTEGER   NO-UNDO INITIAL 0.
DEFINE VARIABLE v-iCountCr          AS INTEGER   NO-UNDO INITIAL 0. /* количество созданных договоров */
DEFINE VARIABLE v-iCountRef         AS INTEGER   NO-UNDO INITIAL 0. /* количество привязанных договоров  */
DEFINE VARIABLE v-iCountDel         AS INTEGER   NO-UNDO INITIAL 0. /* количество отвязанных (закрытых договоров ) */
DEFINE VARIABLE v-iMS-Contract      AS INTEGER   NO-UNDO INITIAL 0. /* признак договора 0,1,2 */
DEFINE VARIABLE v-lIs-Host-Cli      AS LOGICAL   NO-UNDO INITIAL FALSE. /* признак присутствия по фирме договора заданного контрагента */
DEFINE VARIABLE lChoice             AS LOGICAL   NO-UNDO INITIAL FALSE.
DEFINE VARIABLE cTmp                AS CHARACTER NO-UNDO INITIAL "".
DEFINE VARIABLE v-Rid-List          AS CHARACTER NO-UNDO INITIAL "".
DEFINE VARIABLE v-IsOk              AS LOGICAL   NO-UNDO INITIAL FALSE.

/*  */
/* Контроль режимов  */
IF NOT CAN-DO("add,del":U, p-cMode) THEN DO:
   p-cError = PROGRAM-NAME(1) + " Неверно задан режим p-cMode = " + p-cMode.      
   RETURN. 
END.
/* Контроль списка фирм  */ 
IF p-cMode = "add":U AND ( p-cList-Host = "" OR p-cList-Host = ? )THEN DO:
   p-cError = PROGRAM-NAME(1) + " Не задан список фирм p-cList-Host".      
   RETURN. 
END.
/*
  Определение файла протокола работы процедуры
  session:Temporary-Directory
*/
v-proc-name-err = STRING(SESSION:TEMP-DIRECTORY) + "ContractSlave.log":U.  /* протокол работы  */
IF SEARCH(v-proc-name-err) <> ? THEN DO:
   OS-DELETE VALUE(v-proc-name-err).
END.
/* OUTPUT - открываем поток протокола работы   */
OUTPUT STREAM s_Log TO VALUE(v-Proc-Name-Err).

CASE p-cMode:
   WHEN "add":U THEN DO: /* Добавить (привязать договор) */
      /* Перебор списка фирм для привязики и загрузка
         если нужно tt-Host-Contr */
      Label-do:
      DO i = 1 TO NUM-ENTRIES(p-cList-Host):
         /*  */
         ASSIGN
            v-iNewHost     = INTEGER(ENTRY(i, p-cList-Host))
            v-lIs-Host-Cli = FALSE   /* просто сброс признака при смене фирмы  */
            NO-ERROR.
         IF ERROR-STATUS:ERROR THEN DO:
            MESSAGE "Такого быть не может !" SKIP
              PROGRAM-NAME(1) SKIP
              ERROR-STATUS:GET-MESSAGE(1)
              VIEW-AS ALERT-BOX INFO BUTTONS OK.
              NEXT Label-do.
         END.
         /*  */
         /* Обходим на всякий случай фирму мастер договора  */
         IF INTEGER(ENTRY(i, p-cList-Host)) = buf_M-Contract.Host-code THEN DO:
            NEXT Label-do.
         END.

         /* Проверяем наличие у мастер договора, подчиненного договора с этой фирмой.
            Если у мастер договора есть подчиненный договор с этой фирмой -
            такую фирму ПРОСТО ОБХОДИМ !!!
         */
         ASSIGN
            cTmp = Get-Num-Slave-Contract(BUFFER buf_M-Contract, v-iNewHost).

         /* Такого быть не должно, но на всякий случай !!! */
         IF cTmp BEGINS "ERROR" THEN DO:
            ASSIGN
               p-cError = cTmp.
            PutStr(p-cError, TRUE).
            LEAVE Label-do.
         END.

         IF cTmp <> "" THEN DO:
            /* У этой фирмы к мастер договору есть подчиненный договор !!!
               Такую фирму ОБХОДИМ !!!
            */
            NEXT Label-do.
         END.

         /* Добавляем проверку права добавления подчиненного договора по этой фирме
            Если права нет - такую фирму обходим !!!!  */
         { gbl/chk-actg.i
               v-cntxt-db-num
               v-cntxt-userid
              {&action-head-code-main}
              'actn_fo-mc_slave-add-del':U
              {&cntxt-firm}
              v-iNewHost
              ''
              0
              0
              0
              0
              true
              v-IsOk
              no-error
         }
         /* */
         IF ERROR-STATUS:ERROR THEN DO:
            ASSIGN
               v-IsOk = FALSE.
         END.
         /* */
         IF NOT v-IsOk THEN DO:
            ASSIGN
               p-cError = RETURN-VALUE.
            PutStr(p-cError, TRUE).
            LEAVE Label-do.
            /* NEXT Label-do. */
         END.
         /* По каждой фирме пробуем найти один договор по заданному контрагенту
            Договор должен быть не Master и не Slave
            1 - Если договор не найден - его создаем
            2 - если такой договор найден - запрашиваем ( Создать новый или привязать существующий? )
            3 - если по фирме уже привязан договор - пишем об этом в лог
         */
         /* Перебор незакрытых договоров по новой фирме заданного контрагента  */
         Label-for:
         REPEAT
         PRESELECT /* FOR */  EACH buf_Contract WHERE
                  buf_Contract.Host-Code = v-iNewHost
              AND buf_Contract.Cli-type  = buf_M-Contract.Cli-type
              AND buf_Contract.Cli-code  = buf_M-Contract.Cli-code
              AND buf_Contract.Status_   <> {&close-contr}
              NO-LOCK:

              /* Через REPEAT PRESELECT !!! */
              FIND NEXT buf_Contract.

              /* Определяем признак Master/Slave Contract */
              ASSIGN
                 v-iMS-Contract = Is-MS-Contract-Int(BUFFER buf_Contract).
              /*  */
              CASE v-iMS-Contract:
                   WHEN 0 THEN DO:  /* существующий свободный договор */
                        /*  */
                        MESSAGE
                           "У фирмы " v-iNewHost Get-Name-Org({&cmp}, v-iNewHost ) SKIP
                           "существует текущий договор с контрагентом  " SKIP
                           buf_M-Contract.Cli-type buf_M-Contract.Cli-code buf_M-Contract.Cli-name
                           /* Get-Name-Org(buf_M-Contract.Cli-type, buf_M-Contract.Cli-code) */  SKIP
                           " " SKIP
                           "Создать новый или привязать существующий ? " SKIP
                           "" SKIP
                           "Да  - Создать новый договор" SKIP
                           "Нет - Привязать существующий" SKIP
                           "Отмена - Ничего не делать по этой фирме" SKIP
                           VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO-CANCEL
                           TITLE "Что делать?"
                           UPDATE lChoice.
                        /*  */
                        CASE lChoice:
                             WHEN ? THEN DO:
                                  NEXT Label-do.   /* Ничего не делаем по этой фирме */
                             END.
                             WHEN TRUE THEN DO:    /* создать новый договор  */
                                  /* Создание нового договора  */
                                  RUN Create-New-Contract IN THIS-PROCEDURE(
                                      BUFFER buf_M-Contract,
                                      INPUT v-iNewHost,
                                      INPUT-OUTPUT v-iCountCr,
                                      OUTPUT p-cError
                                      ).
                                  IF p-cError <> "" THEN DO:
                                     LEAVE Label-do.   /* Ошибка - выход в протокол  */
                                  END. ELSE DO:
                                     NEXT Label-do.    /* Нормальное завершение -  переход к следующий фирме */
                                  END.
                             END.
                             WHEN FALSE THEN DO:   /* привязать существующий */
                                  /* Выбор существующего договора из стандартного интерфейса !!! */

                                  RUN str/cont-all.w (
                                      INPUT parParentProc
                                     ,INPUT v-iNewHost                 /* фирма */
                                     ,INPUT "b-sel"                    /* кнопки для нажатия  */
                                     ,INPUT {&company} + "|0"          /* p-Mode, 0 - свободный договор */
                                     ,INPUT buf_M-Contract.cli-type
                                     ,INPUT buf_M-Contract.Cli-code
                                     ,INPUT ?
                                     ,INPUT ?
                                     ,INPUT "current"
                                     ,INPUT {&income}
                                     ,INPUT-OUTPUT v-rid-list)         /* Из интерфейса может передаваться только один rid  */
                                     .

                                  /* В случае отказа - переход на следующую фирму  */
                                  IF v-rid-list = "" OR v-rid-list = ? THEN DO:
                                      PutStr("Отказ от выбора подчиненного договора в интерфейсе str/cont-all.w", TRUE).
                                      NEXT Label-do.
                                  END.
                                  /*  */
                                  FIND FIRST buf_Slave WHERE
                                             RECID(buf_Slave) = INTEGER(v-Rid-List)
                                       NO-LOCK NO-ERROR.
                                  IF NOT AVAILABLE buf_Slave THEN DO:
                                     /* Такого быть не должно, но на всякий случай  */
                                     PutStr("NOT AVAILABLE buf_Slave RECID(buf_Slave)=" + STRING(v-Rid-List) , TRUE).
                                     LEAVE Label-do.
                                  END.

                                  /* Проверки закончены, делаем связку  */
                                  RUN Ref-New-Contract IN THIS-PROCEDURE(
                                      BUFFER buf_M-Contract,
                                      BUFFER buf_Slave,
                                      INPUT-OUTPUT v-iCountRef,
                                      OUTPUT p-cError
                                      ).
                                  IF p-cError <> "" THEN DO:
                                     LEAVE Label-do.   /* Ошибка - выход в протокол  */
                                  END. ELSE DO:
                                     NEXT Label-do.    /* Нормальное завершение -  переход к следующий фирме */
                                  END.
                             END.
                        END CASE.
                        /*  */
                   END.
                   /*  */
                   WHEN 1 THEN DO:  /* Мастер договор - обходим */
                        NEXT Label-for.
                   END.
                   /*  */
                   WHEN 2 THEN DO:  /* Подчиненный договор - обходим */
                        NEXT Label-for.
                   END.
                   /*  */
                   OTHERWISE DO:        /* А такого быть не должно !!! - обходим */
                        NEXT Label-for.
                   END.
                   /*  */
              END CASE.
              /* Установка признака присутствия  контракта ??? */
              ASSIGN
                 v-lIs-Host-Cli = TRUE.

         END.

         /* Если по фирме контракта по заданному контрагенту не обнаружено - просто его создаем   */
         /* Создание нового договора  */
         IF NOT v-lIs-Host-Cli THEN DO:
            RUN Create-New-Contract IN THIS-PROCEDURE(
                BUFFER buf_M-Contract,
                INPUT v-iNewHost,
                INPUT-OUTPUT v-iCountCr,
                OUTPUT p-cError
                ).
            IF p-cError <> "" THEN DO:
               LEAVE Label-do.   /* Ошибка - выход в протокол  */
            END. ELSE DO:
               NEXT Label-do.    /* Нормальное завершение -  переход к следующий фирме */
            END.
         END.

      END. /* Do - перебора списка фирм  */
   END.
   /*  */
   WHEN "del":U THEN DO: /* закрытие (удаление договора)  */
      /* Пока так !!!  */
      RUN Close-Slave-Contract IN THIS-PROCEDURE (
             BUFFER buf_M-Contract, /*  */
             BUFFER buf_S-Contract, /*  */
             INPUT-OUTPUT v-iCountDel,
             OUTPUT p-cError
             ).
   END.
END CASE.

/* Перед закрытием потока добавляем общее общее количество совершенных операций !!! */
IF v-iCountCr <> 0 THEN DO:
   PutStr("Всего созданных договоров: " + STRING(v-iCountCr), TRUE).
END.
IF v-iCountRef <> 0 THEN DO:
   PutStr("Всего привязанных договоров: " + STRING(v-iCountRef), TRUE).
END.
IF v-iCountDel <> 0 THEN DO:
   PutStr("Всего удаленных (закрытых договоров) : " + STRING(v-iCountDel), TRUE).
END.
/* Закрыть поток протокола   */
OUTPUT STREAM s_Log CLOSE.


IF p-cError = "" THEN DO:
   IF p-cMode = "add":U THEN DO:
      MESSAGE
         "Всего созданных договоров   : " v-iCountCr    SKIP
         "Всего привязанных договоров : " v-iCountRef   SKIP
          VIEW-AS ALERT-BOX INFO BUTTONS OK.
   END. ELSE DO:
      MESSAGE
         "Всего удаленных (закрытых договоров) : " v-iCountDel   SKIP
          VIEW-AS ALERT-BOX INFO BUTTONS OK.
   END.
END. ELSE DO:
   /* В протокол пишем все, но показать его только после ошибки !!! */
   IF SEARCH (v-proc-name-err) <> ? THEN DO:
      RUN gbl/prnfilen.w (
          input  "Протокол работы процедуры:":U + vss-workfile
         ,input  0
         ,input  v-proc-name-err
         ,input  7
         ,output v-user-action
         ,output v-printed
         ).
   END.
END.
/* */
RETURN. 
/* end of main block */

/*************
*            Процедура закрытия подчиненного договора
*************/
PROCEDURE Close-Slave-Contract:
   DEFINE PARAMETER BUFFER  buf_Master    FOR ub.Contract.                   /*  */
   DEFINE PARAMETER BUFFER  buf_Slave     FOR ub.Contract.                   /*  */
   DEFINE INPUT-OUTPUT PARAMETER v-iCount AS INTEGER NO-UNDO.
   DEFINE OUTPUT PARAMETER  p-cError      AS CHARACTER NO-UNDO INITIAL "".   /*  */
   /*  */
   DEFINE BUFFER buf_Mod-Slave FOR ub.Contract.
   /*  */
   DEFINE VARIABLE lChoice AS LOGICAL NO-UNDO INITIAL FALSE.
   /*  */
   DEFINE VARIABLE v-iUser-Db-Num AS INTEGER   NO-UNDO INITIAL 0.
   DEFINE VARIABLE v-cUser-Name   AS CHARACTER NO-UNDO INITIAL "".
   DEFINE VARIABLE v-Sys-Date     AS DATE      NO-UNDO INITIAL ?.
   DEFINE VARIABLE v-Sys-Time     AS CHARACTER NO-UNDO INITIAL "".
   DEFINE VARIABLE v-Sys-Time-Int AS INTEGER   NO-UNDO INITIAL 0.
   /* Проверка, хотя вряд ли ....  */
   IF NOT AVAILABLE buf_Master THEN DO:
      ASSIGN
         p-cError = PROGRAM-NAME(1) + ":NOT AVAILABLE buf_Master".
      RETURN.
   END.
   IF NOT AVAILABLE buf_Slave THEN DO:
      ASSIGN
         p-cError = PROGRAM-NAME(1) + ":NOT AVAILABLE buf_Slave".
      RETURN.
   END.
   /*  */
   MESSAGE
      "Закрыть договор №" buf_Slave.Contract-prn-code
      "от" buf_Slave.contract-date "?"
      VIEW-AS ALERT-BOX INFO BUTTONS YES-NO
      UPDATE lChoice.
   IF lChoice <> TRUE THEN DO:
      RETURN.
   END.

   /* Какие-то проверки */
   { gbl/chk-actg.i
     v-cntxt-db-num
     v-cntxt-userid
     {&action-head-code-main}
     'actn_fin-contract_deletion':U
     {&cntxt-firm}
     buf_Slave.Host-code
     '':U
     0
     0
     0
     0
     true
     lChoice
   }
   IF lChoice <> TRUE THEN DO:
      RETURN.
   END.

   Tran:
   DO TRANSACTION
      ON ENDKEY UNDO Tran, RETRY Tran
      ON ERROR  UNDO Tran, RETRY Tran
      ON QUIT   UNDO Tran, RETRY Tran
      ON STOP   UNDO Tran, RETRY Tran:
      /* */
      IF RETRY  THEN DO:
         p-cError = p-cError + (IF p-cError = "" THEN "" ELSE "~n") +
                    " Ошибка транзакции " + PROGRAM-NAME(1) + ERROR-STATUS:GET-MESSAGE(1) + " " + RETURN-VALUE.
         PutStr(p-cError, TRUE).  /* Ошибки транзакции вначале пишем в протокол  */
         UNDO Tran, LEAVE Tran.
      END.
      /*  */
      FIND FIRST buf_Mod-Slave WHERE
                 RECID(buf_Mod-Slave) = RECID(buf_Slave)
           EXCLUSIVE-LOCK NO-WAIT NO-ERROR.
      {&ERROR_UNDO_RETRY}
 
      /* Снимаем переменные  */
      {gbl/curdburt.i
       v-iUser-Db-Num
       v-cUser-Name
       v-Sys-Date
       v-Sys-Time
       v-Sys-Time-Int 
      }
      /* Модификация статуса и т.п. ...  */
      ASSIGN
         buf_Mod-Slave.user-db-num = v-iUser-Db-Num
         buf_Mod-Slave.user-name   = v-cUser-Name
         buf_Mod-Slave.Status_     = {&close-contr}
         NO-ERROR.
      {&ERROR_UNDO_RETRY}

      /* Пишем атрибут */
      RUN Create-Contract-Attr IN THIS-PROCEDURE(
          buf_Slave.Host-code,
          buf_Slave.Contract-code,
          v-S_CODE_LAST_MASTER_NUM,
          STRING(buf_Master.Host-code) + v-DELIM_CHR_3 + STRING(buf_Master.Contract-code),
          OUTPUT p-cError
          ).
      IF p-cError <> "" THEN DO:
         {&ERROR_UNDO_RETRY}
      END.

      /* Удаляем связь */
      RUN Delete-Ref-Master-Slave IN THIS-PROCEDURE (
          BUFFER buf_Master,
          BUFFER buf_Slave,
          OUTPUT p-cError
          ).
      IF p-cError <> "" THEN DO:
         {&ERROR_UNDO_RETRY}
      END.

      PutStr("Закрыт " +
             STRING(buf_Slave.Host-code) + "," +
             STRING(buf_Slave.Contract-code) + "," +
             "-" +
             "Ok!",
             TRUE). /*  */

      /* Подсчет количества закрытых договоров  */
      ASSIGN
         v-iCount = v-iCount + 1.
   END. /* Tran */
   /*  */
   RETURN.
END PROCEDURE.




/*************
*            Процедура привязки существующего договора с удалением спецификации
*************/
PROCEDURE Ref-New-Contract:
   DEFINE PARAMETER BUFFER  buf_Master FOR ub.Contract.                   /* мастер контракт  */
   DEFINE PARAMETER BUFFER  buf_Slave  FOR ub.Contract.                   /* подчиненный контракт  */
   DEFINE INPUT-OUTPUT PARAMETER v-iCount AS INTEGER NO-UNDO.
   DEFINE OUTPUT PARAMETER  p-cError      AS CHARACTER NO-UNDO INITIAL "".   /* */
   /*  */
   PutStr(
          "Фирма " + STRING(buf_Slave.Host-code) + " " +
          "Привязка договора с контрагентом " +
           buf_Master.Cli-type + " " + STRING(buf_Master.Cli-code) +
           "...",
           FALSE
           ).

   Tran:
   DO TRANSACTION
      ON ENDKEY UNDO Tran, RETRY Tran
      ON ERROR  UNDO Tran, RETRY Tran
      ON QUIT   UNDO Tran, RETRY Tran
      ON STOP   UNDO Tran, RETRY Tran:
      /* */
      IF RETRY  THEN DO:
         p-cError = p-cError + (IF p-cError = "" THEN "" ELSE "~n") +
                    " Ошибка транзакции " + PROGRAM-NAME(1) + ERROR-STATUS:GET-MESSAGE(1) + " " + RETURN-VALUE.
         PutStr(p-cError, TRUE).  /* Ошибки транзакции вначале пишем в протокол  */
         UNDO Tran, LEAVE Tran.
      END.
      /* здесь создаем связку Master->Slave  */
      RUN Create-Ref-Master-Slave IN THIS-PROCEDURE(
          BUFFER buf_Master,
          BUFFER buf_Slave,
          OUTPUT p-cError).
      IF p-cError <> "" THEN DO:
         UNDO Tran, RETRY Tran.
      END.
      /* Удаляем спецификацию подчиненного договора   */
      RUN Delete-Contract-Specif IN THIS-PROCEDURE(
          BUFFER buf_Slave,
          OUTPUT p-cError).
      IF p-cError <> "" THEN DO:
         UNDO Tran, RETRY Tran.
      END.

   END. /* Tran */
   IF p-cError = "" THEN DO:
      PutStr("Ok!", TRUE). /*  */
      /* Подсчет количества связанных договоров  */
      ASSIGN
         v-iCount = v-iCount + 1.
   END. ELSE DO:
      PutStr("Error!" + " " + p-cError, TRUE). /*  */
   END.
   /*  */
   RETURN.
END PROCEDURE.




/*************
*            Процедура создание нового договора
*************/
PROCEDURE Create-New-Contract:
   DEFINE PARAMETER BUFFER  buf_M-Contract FOR ub.Contract.                   /* мастер контракт  */
   DEFINE INPUT  PARAMETER  p-iNewHost      AS INTEGER NO-UNDO.               /* новая фирма  */
   DEFINE INPUT-OUTPUT PARAMETER v-iCount   AS INTEGER NO-UNDO.
   DEFINE OUTPUT PARAMETER  p-cError        AS CHARACTER NO-UNDO INITIAL "".   /* */
   /*  */
   DEFINE BUFFER buf_Cr-Contract FOR ub.Contract.  /* для создание нового договора  */
   /*  */
   DEFINE VARIABLE f-Code           AS INTEGER    NO-UNDO INITIAL 0.
   DEFINE VARIABLE p-sys-date       AS DATE       NO-UNDO.
   DEFINE VARIABLE p-sys-time       AS CHARACTER  NO-UNDO.
   DEFINE VARIABLE p-sys-time-int   AS INTEGER    NO-UNDO.
   /*  */
   PutStr(
          "Фирма " + STRING(p-iNewHost) + " " +
          "Создание договора с контрагентом " +
           buf_M-Contract.Cli-type + " " + STRING(buf_M-Contract.Cli-code) + "...",
           FALSE
           ).

   Tran:
   DO TRANSACTION
      ON ENDKEY UNDO Tran, RETRY Tran
      ON ERROR  UNDO Tran, RETRY Tran
      ON QUIT   UNDO Tran, RETRY Tran
      ON STOP   UNDO Tran, RETRY Tran:
      /* */
      IF RETRY  THEN DO:
         p-cError = p-cError + (IF p-cError = "" THEN "" ELSE "~n") +
                    " Ошибка транзакции " + PROGRAM-NAME(1) + ERROR-STATUS:GET-MESSAGE(1) + " " + RETURN-VALUE.
         PutStr(p-cError, TRUE).  /* Ошибки транзакции вначале пишем в протокол  */
         UNDO Tran, LEAVE Tran.
      END.
      /* внутренние примочки  */
      RUN gen-b-code IN THIS-PROCEDURE (
         INPUT {&gbl-ct-code}, OUTPUT f-code
         ) NO-ERROR.
      IF ERROR-STATUS:ERROR THEN DO:
         p-cError = "Ошибка при генерации внутреннего № договора".
         MESSAGE p-cError
             VIEW-AS ALERT-BOX INFO BUTTONS OK.
         UNDO Tran, RETRY Tran.
      END.
      /* 1 */
      CREATE buf_Cr-Contract NO-ERROR.
      {&ERROR_UNDO_RETRY}
      /* 2 */
      BUFFER-COPY
            buf_M-Contract
         EXCEPT
            Host-code
            Contract-code
            user-db-num
            user-name
         TO buf_Cr-Contract
         ASSIGN
            buf_Cr-Contract.Host-code      = p-iNewHost /* номер новой фирмы */
            buf_Cr-Contract.Contract-code  = f-Code
         NO-ERROR.
      {&ERROR_UNDO_RETRY}
      /* Это TH  */
      { gbl/curdburt.i
        buf_Cr-contract.user-db-num
        buf_Cr-contract.user-name
        p-sys-date
        p-sys-time
        p-sys-time-int
      }

      /* 3 - Запускаем процедуру установки параметов новой фирмы  */
      RUN Set-Param-New-Firm IN THIS-PROCEDURE (
          BUFFER buf_Cr-Contract,
          INPUT p-iNewHost,
          OUTPUT p-cError
          ).
      IF p-cError <> "" THEN DO:
         UNDO Tran, RETRY Tran.
      END.

      /* 4 - здесь создаем связку Master->Slave  */
      RUN Create-Ref-Master-Slave IN THIS-PROCEDURE(
          BUFFER buf_M-Contract,
          BUFFER buf_Cr-Contract,
          OUTPUT p-cError).
      IF p-cError <> "" THEN DO:
         UNDO Tran, RETRY Tran.
      END.

   END. /* Tran */
   IF p-cError = "" THEN DO:
      PutStr("Ok!", TRUE). /*  */
      /* Подсчет количества созданных договоров  */
      ASSIGN
         v-iCount = v-iCount + 1.
   END. ELSE DO:
      PutStr("Error!" + " " + p-cError, TRUE). /*  */
   END.
   /*  */
   RETURN.
END PROCEDURE.

/*************
*            Процедура установки параметров новой фирмы
*************/
PROCEDURE Set-Param-New-Firm:
   DEFINE PARAMETER BUFFER buf_Contract FOR ub.Contract.
   DEFINE INPUT PARAMETER  iNewHost AS INTEGER   NO-UNDO.
   DEFINE OUTPUT PARAMETER cError   AS CHARACTER NO-UNDO INITIAL "".
   /*  */
   DEFINE BUFFER buf_SysConf  FOR ub.SysConf.
   DEFINE BUFFER buf_Clients  FOR ub.Clients.
   DEFINE BUFFER buf_Firm     FOR ub.Firm.
   /*  */
   /* Первоначальнач установка буферов */
   FIND FIRST buf_SysConf WHERE
              buf_SysConf.Host-code = iNewHost
        NO-LOCK NO-ERROR.
   IF NOT AVAILABLE buf_SysConf THEN DO:
      ASSIGN
         cError =  PROGRAM-NAME(1) + ":NOT AVAILABLE buf_SysConf.Host-code =  " + STRING(iNewHost).
      RETURN.
   END.
   /*  */
   FIND FIRST buf_Clients WHERE
              buf_Clients.Obj-type = {&cmp}
          AND buf_Clients.Obj-code = iNewHost
        NO-LOCK NO-ERROR.
   IF NOT AVAILABLE buf_Clients THEN DO:
      ASSIGN
         cError =  PROGRAM-NAME(1) + ":NOT AVAILABLE buf_Clients.Obj-type = {&cmp} AND AND buf_Clients.Obj-code = iNewHost = " + STRING(iNewHost).
      RETURN.
   END.
   /*  */
   FIND FIRST buf_Firm WHERE
              buf_Firm.Firm-code = iNewHost
        NO-LOCK NO-ERROR.
   IF NOT AVAILABLE buf_Firm THEN DO:
      ASSIGN
         cError =  PROGRAM-NAME(1) + ": NOT AVAILABLE buf_Firm.Firm-code = " + STRING(iNewHost).
      RETURN.
   END.
   /*  */
   ASSIGN
      /* 1 Clients  */
      /* buf_Contract.Host-code  = iNewHost Присваивается ранее  */
      buf_Contract.Own-name                 = buf_Clients.Obj-name  /* Название фирмы */
      /* 2 SysConf */
      buf_contract.an-uchet-code-out        = buf_sysconf.an-uchet-code-out
      buf_contract.cel-nazn-code-out        = buf_sysconf.cel-nazn-code-out
      buf_contract.cor-acc-out              = buf_sysconf.cor-acc-out
      buf_contract.cor-acc1-out             = buf_sysconf.cor-acc1-out
      buf_contract.an-uchet-code-in         = buf_sysconf.an-uchet-code-in
      buf_contract.cel-nazn-code-in         = buf_sysconf.cel-nazn-code-in
      buf_contract.cor-acc-in               = buf_sysconf.cor-acc-in
      buf_contract.cor-acc1-in              = buf_sysconf.cor-acc1-in
      buf_contract.an-uchet-code-out-cash   = buf_sysconf.an-uchet-code-out-cash
      buf_contract.cel-nazn-code-out-cash   = buf_sysconf.cel-nazn-code-out-cash
      buf_contract.cor-acc-out-cash         = buf_sysconf.cor-acc-out-cash
      buf_contract.cor-acc1-out-cash        = buf_sysconf.cor-acc1-out-cash
      buf_contract.an-uchet-code-in-cash    = buf_sysconf.an-uchet-code-in-cash
      buf_contract.cel-nazn-code-in-cash    = buf_sysconf.cel-nazn-code-in-cash
      buf_contract.cor-acc-in-cash          = buf_sysconf.cor-acc-in-cash
      buf_contract.cor-acc1-in-cash         = buf_sysconf.cor-acc1-in-cash
      buf_contract.an-uchet-code-out-payoff = buf_sysconf.an-uchet-code-out-payoff
      buf_contract.cel-nazn-code-out-payoff = buf_sysconf.cel-nazn-code-out-payoff
      buf_contract.cor-acc-out-payoff       = buf_sysconf.cor-acc-out-payoff
      buf_contract.cor-acc1-out-payoff      = buf_sysconf.cor-acc1-out-payoff
      buf_contract.an-uchet-code-in-payoff  = buf_sysconf.an-uchet-code-in-payoff
      buf_contract.cel-nazn-code-in-payoff  = buf_sysconf.cel-nazn-code-in-payoff
      buf_contract.cor-acc-in-payoff        = buf_sysconf.cor-acc-in-payoff
      buf_contract.cor-acc1-in-payoff       = buf_sysconf.cor-acc1-in-payoff         
      buf_contract.transport-cli-type       = buf_sysconf.transport-cli-type
      buf_contract.transport-cli-code       = buf_sysconf.transport-cli-code
      buf_contract.transport-host           = buf_sysconf.transport-host
      buf_contract.transport-contract       = buf_sysconf.transport-contract
      buf_contract.transport-uslov          = buf_sysconf.transport-uslov
      buf_contract.transport-value          = buf_sysconf.transport-value
      buf_contract.own-code-schet-start     = (IF buf_sysconf.pay-code-schet-rubl > 0
                                                  THEN buf_sysconf.pay-code-schet-rubl
                                                  ELSE buf_contract.own-code-schet-start
                                               )
      buf_contract.own-sign-post            = buf_sysconf.pay-sign-post
      buf_contract.own-sign                 = buf_sysconf.pay-sign
      buf_contract.contract-city            = buf_sysconf.contract-city
      buf_Contract.fin-VAT-pc               = buf_sysconf.fin-VAT-pc
      buf_Contract.srok-opl                 = buf_sysconf.srok-opl
      buf_Contract.gen-factur-srok          = buf_sysconf.srok-opl-sf
      /* 3 Firm  */
      buf_contract.own-addres               = buf_firm.addres1
      buf_contract.own-inn                  = buf_firm.inn
      buf_contract.own-kpp                  = buf_firm.kpp
      NO-ERROR.
   /*  */
   IF ERROR-STATUS:ERROR THEN DO:
      ASSIGN
         cError =  PROGRAM-NAME(1) + ":" + ERROR-STATUS:GET-MESSAGE(1) + " " + RETURN-VALUE.
      RETURN.
   END.
   /*  */
   RETURN.
END PROCEDURE.

FUNCTION Get-Name-Org RETURN CHARACTER (INPUT cObj-type AS CHARACTER, INPUT iObj-code AS INTEGER):
   DEFINE BUFFER buf_Clients FOR ub.Clients.
   DEFINE VARIABLE cRet AS CHARACTER NO-UNDO INITIAL "".
   /*  */
   FIND FIRST buf_Clients WHERE
              buf_Clients.Obj-type = cObj-type
          AND buf_Clients.Obj-code = iObj-code
        NO-LOCK NO-ERROR.
   IF AVAILABLE buf_Clients THEN DO:
      ASSIGN
         cRet = buf_Clients.Obj-name
         .
   END.
   /*  */
   RETURN (cRet).
END FUNCTION.
/*  */
FUNCTION PutStr RETURN LOGICAL (INPUT v-cStr AS CHARACTER, INPUT v-lSkip AS LOGICAL):
    PUT STREAM s_Log UNFORMATTED v-cStr.
    IF v-lSkip THEN DO:
       PUT STREAM s_Log UNFORMATTED SKIP.
    END.
    RETURN TRUE.
END FUNCTION.

&UNDEFINE ERROR_UNDO_RETRY

