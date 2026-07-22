block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: am-igt-a.p $
$Archive: ref/am-igt-a.p $

Процедура, запускаемая в автоматическом режиме,
производит удаление и ввод товара в АМ

Автор: Носко Игорь Александрович
Дата создания: 24/03/2011
Author: Igor Nosko
Creation date: 24/03/2011

*/

/* VSS  Definitions --- */
DEFINE VARIABLE vss-revision    AS CHARACTER NO-UNDO INITIAL "$Revision: aea5316774be, 0, rls $":U.
DEFINE VARIABLE vss-author      AS CHARACTER NO-UNDO INITIAL "$Author: expertek $":U.
DEFINE VARIABLE vss-date        AS CHARACTER NO-UNDO INITIAL "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U.
DEFINE VARIABLE vss-workfile    AS CHARACTER NO-UNDO INITIAL "$Workfile: am-igt-a.p $":U.
DEFINE VARIABLE vss-archive     AS CHARACTER NO-UNDO INITIAL "$Archive: ref/am-igt-a.p $":U.
DEFINE VARIABLE vss-description AS CHARACTER NO-UNDO INITIAL "$Ввод и вывод товара в АМ":U.

/* Parameters Definitions --- */
DEFINE INPUT PARAMETER parParentProc   AS WIDGET-HANDLE NO-UNDO.
DEFINE INPUT PARAMETER p-Parent-handle AS widget-handle NO-UNDO.
DEFINE INPUT PARAMETER p-Log-handle    AS handle        NO-UNDO.
DEFINE INPUT PARAMETER p-Cre-db-num    AS integer       NO-UNDO.
DEFINE INPUT PARAMETER p-Task-type     AS character     NO-UNDO.
DEFINE INPUT PARAMETER p-Task-num      AS integer       NO-UNDO.
DEFINE INPUT PARAMETER p-Db-num        AS integer       NO-UNDO.

/* */
{cmp/vssrevis.i}
{cmp/str-glbl.i}
{cmp/library.i}
{gbl/thbjattr.i}
{gbl/cur-time.i}
{ref/gds-matl.i}
{ref/gds-ind1.i}

/*  */
FUNCTION Get-Date-Attr RETURN DATE (BUFFER buf_Gds-OP FOR ub.gds-obj-prop) FORWARD.

/* Buffers  Definitions --- */
DEFINE BUFFER buf_AM            FOR ub.Assortment-Matrix.
DEFINE BUFFER buf_AM-goods      FOR ub.Assortment-Matrix-Goods.
DEFINE BUFFER buf_Gds-OP        FOR ub.Gds-obj-prop.
DEFINE BUFFER buf_Gds-OP-Attr   FOR ub.Gds-obj-prop-attr.
DEFINE BUFFER buf_Goods         FOR ub.Goods.
DEFINE BUFFER buf_Clients       FOR ub.Clients.

/* Local Variable Definitions --- */
DEFINE VARIABLE v-Character   AS CHARACTER  NO-UNDO .
DEFINE VARIABLE v-Date        AS DATE       NO-UNDO .
DEFINE VARIABLE v-Decimal     AS DECIMAL    NO-UNDO .
DEFINE VARIABLE v-iInteger    AS INTEGER    NO-UNDO . /*  */
DEFINE VARIABLE v-Logical     AS LOGICAL    NO-UNDO .
DEFINE VARIABLE v-Param-Type  AS CHARACTER  NO-UNDO .
/* Количество дней для перевода из Новинки в Основную группу  */
DEFINE VARIABLE v-iSrokNewToOsn    AS INTEGER     NO-UNDO INITIAL 0.
/* Количество дней в статусе На вывод для удаления из ассортиментных матриц  */
DEFINE VARIABLE v-iSrokNaVyvToDel  AS INTEGER     NO-UNDO INITIAL 0.
/*  */
DEFINE VARIABLE iCountToOsn   AS INTEGER    NO-UNDO INITIAL 0.    /* количество товара переведенных из новинки в основную группу   */
DEFINE VARIABLE iCountToDel   AS INTEGER    NO-UNDO INITIAL 0.   /* количество товара удаленного из Ассортиментных матриц    */
DEFINE VARIABLE cListIgt      AS CHARACTER  NO-UNDO INITIAL "".
DEFINE VARIABLE dtDateAttr    AS DATE       NO-UNDO INITIAL ?.
DEFINE VARIABLE i             AS INTEGER    NO-UNDO INITIAL 0.
DEFINE VARIABLE v-Sts         AS INTEGER    NO-UNDO INITIAL 0.
DEFINE VARIABLE iTmpRecId     AS RECID      NO-UNDO INITIAL ?.
DEFINE VARIABLE iTimeBeg      AS INTEGER    NO-UNDO INITIAL 0.
DEFINE VARIABLE iTimeEnd      AS INTEGER    NO-UNDO INITIAL 0.

/* Начало времени работы процедуры */
ASSIGN
   iTimeBeg = TIME.

/* Начинаем от Clients по p-db-num */
Label-clietns:
FOR EACH buf_Clients WHERE
         buf_Clients.Db-num = p-Db-num /*  v-cntxt-db-num */
    NO-LOCK:
    /* Снимаем настройки ass-srokiztdel  */
    /*  */
    EMPTY TEMP-TABLE thbjattr_thbj-attr .
    RUN adm/shattri.p (
            INPUT  "get":U,
            INPUT  buf_Clients.Obj-type,             /* тип объекта  */
            INPUT  buf_Clients.Obj-Code,             /* код объекта  */
            INPUT  {&attr-ass-obj},                  /* название секции   */
            INPUT  {&attr-Ass-obj_ass-srokiztdel} ,  /* название параметра   */
            OUTPUT v-Character,
            OUTPUT v-Date,
            OUTPUT v-Decimal,
            OUTPUT v-iSrokNaVyvToDel,                 /* Здесь возвращается параметр */
            OUTPUT v-Logical,
            OUTPUT v-Param-Type,
            INPUT-OUTPUT TABLE thbjattr_thbj-attr
        ) NO-ERROR.
    IF ERROR-STATUS:ERROR THEN DO:
       ASSIGN
          v-iSrokNaVyvToDel = 0.
    END.
    /* Снимаем настройки ass-num-days-igt  */
    /*  */
    EMPTY TEMP-TABLE thbjattr_thbj-attr .
    RUN adm/shattri.p (
            INPUT  "get":U,
            INPUT  buf_Clients.Obj-type,               /* тип объекта  */
            INPUT  buf_Clients.Obj-Code,               /* код объекта  */
            INPUT  {&attr-ass-obj},                    /* название секции   */
            INPUT  {&attr-Ass-obj_ass-num-days-igt} ,  /* название параметра   */
            OUTPUT v-Character,
            OUTPUT v-Date,
            OUTPUT v-Decimal,
            OUTPUT v-iSrokNewToOsn,                    /* Здесь возвращается параметр */
            OUTPUT v-Logical,
            OUTPUT v-Param-Type,
            INPUT-OUTPUT TABLE thbjattr_thbj-attr
        ) NO-ERROR.
    IF ERROR-STATUS:ERROR THEN DO:
       ASSIGN
          v-iSrokNewToOsn = 0.
    END.

    /* Елсли параметры не заданы - переходим к следующему объекту  */
    IF v-iSrokNaVyvToDel = 0 AND v-iSrokNewToOsn = 0 THEN DO:
       NEXT Label-clietns.
    END.

    /* Формируем список статусов ИЖТ для обработки для каждого объекта   */
    ASSIGN
       cListIgt = ""
       cListIgt = cListIgt + (IF v-iSrokNaVyvToDel = 0 THEN "" ELSE {&ass-izd-del})
       cListIgt = cListIgt + (IF cListIgt <> "" AND v-iSrokNewToOsn <> 0  THEN "," ELSE "") +
                             (IF v-iSrokNewToOsn = 0  THEN "" ELSE {&ass-izd-new}).
    /*  */
    Label-do:
    DO i = 1 TO NUM-ENTRIES(cListIgt):
       Label-Gds-Op:
       FOR EACH buf_Gds-OP WHERE
                buf_Gds-OP.Obj-type  = buf_Clients.Obj-type
            AND buf_Gds-OP.Obj-code  = buf_Clients.Obj-code
            AND buf_Gds-OP.Gdop-igt  = ENTRY(i, cListIgt)   /* Попали в индекс */
           NO-LOCK,
           /* проверяем статус товара Текущий  */
           FIRST buf_AM-goods WHERE
                 buf_AM-goods.Obj-type    = buf_Gds-OP.Obj-type
             AND buf_AM-goods.Obj-code    = buf_Gds-OP.Obj-code
             AND buf_AM-goods.Gds-code    = buf_Gds-OP.Gds-code
             AND buf_AM-goods.Asmg-Status = 0               /* Статус текущий  */
           NO-LOCK,
           /* и статус матрицы  */
           FIRST buf_AM WHERE
                 buf_AM.Asmt-id     = buf_Am-goods.Asmt-id
             AND buf_AM.Db-num      = buf_Clients.Db-num
             AND buf_AM.Asmt-Status = 0                    /* Статус текущий  */
             AND buf_AM.Asmt-type   = {&type-assmatr-obj}  /* Матрицы только по объектам !!!  */
           NO-LOCK:

           /* Снимаем дату из Атрибута   */
           ASSIGN
              dtDateAttr = Get-Date-Attr(BUFFER buf_Gds-OP).

           /* Пока делаем так. Если дата не определилась - переход на следующий товар */
           IF dtDateAttr = ? THEN DO:
              NEXT Label-gds-op.
           END.

           /* На вывод из ассортимента  */
           IF ENTRY(i, cListIgt) = {&ass-izd-del} AND (TODAY - dtDateAttr >= v-iSrokNaVyvToDel) THEN DO:
              /* Удаляем из АМ */
              ASSIGN
                 v-sts = ? .
              { ref/gds-mat2.i
                this-procedure
                recid(buf_AM-Goods)
                v-Sts
                false
                no-error
              }

              /* На всякий случай пишем в Log */
              IF ERROR-STATUS:ERROR THEN DO:
                 RUN write-to-log in p-Log-handle(
                    {&new-line} + PROGRAM-NAME(1) + " " + ERROR-STATUS:GET-MESSAGE(1) + " " + RETURN-VALUE
                     ).
                 NEXT Label-gds-op.
              END.
              /* В RETURN-VALUE Без ERROR  может быть сообщение о правиле срабатываниея ИЖТ по событию
                 которое задается в настойках Ассортиментная политика->Правила работы с ИЖТ
                 Это нормальная ситуация - просто переходим на следующий товар   */
              IF (RETURN-VALUE <> ? AND RETURN-VALUE <> "")  THEN DO:
                 NEXT Label-gds-op.
              END.

              /* Подсчет количества выведенных товаров  */
              ASSIGN
                 iCountToDel = iCountToDel + 1.
           END.

           /* На ввод из новинки в основную группу  */
           IF ENTRY(i, cListIgt) = {&ass-izd-new} AND (TODAY - dtDateAttr >= v-iSrokNewToOsn) THEN DO:
              /* Для перехода к процедуре gds-ind1 */
              ASSIGN
                 iTmpRecId = RECID(buf_Gds-OP).
              /*  */
              RUN gds-ind1 (
                  input-output iTmpRecId,
                  buf_Gds-OP.gds-code,
                  buf_Gds-OP.obj-type,
                  buf_Gds-OP.obj-code,
                  {&ass-izd-com},            /* Основная группа !!! */
                  ?,
                  ?,
                  ?,
                  ?,
                  ?
                  ) NO-ERROR.

              /*  */
              /* Подсчет количества переведеных товаров из Новинки в основную группу   */
              IF ERROR-STATUS:ERROR THEN DO:
                 RUN write-to-log in p-Log-handle(
                    {&new-line} + PROGRAM-NAME(1) + " " + ERROR-STATUS:GET-MESSAGE(1) + " " + RETURN-VALUE
                     ).
                 NEXT Label-gds-op.
              END.
              /*  */
              ASSIGN
                 iCountToOsn = iCountToOsn + 1.
           END.
       END.
    END. /* Do */
END. /* Label-clients */

/* Окончание времени работы  */
ASSIGN
   iTimeEnd = TIME.

/* Переход через полночь  */
IF iTimeEnd < iTimeBeg THEN DO:
   ASSIGN
      iTimeEnd = iTimeEnd + (24 * 60 * 60).
END.


/* Вывод результатов работы процедуры в Log */
RUN write-to-log in p-Log-handle(
    {&new-line} +
    "Количество товаров выведенных из ассортиментных матриц = " + STRING(iCountToDel)   + {&new-line} +
    'Количество товаров переведенных в "Основную группу"    = ' + STRING(iCountToOsn)   + {&new-line} +
    "Время работы процедуры " + PROGRAM-NAME(1) + " = "  + STRING(iTimeEnd - iTimeBeg, "HH:MM:SS" ) + {&new-line} +
    ""
    ).
/*  */
RETURN.
/* end of main block */


FUNCTION Get-Date-Attr RETURN DATE (BUFFER buf_Gds-OP FOR ub.gds-obj-prop):
   DEFINE VARIABLE dtRet AS DATE NO-UNDO INITIAL ?.
   DEFINE BUFFER buf_Gds-OP-attr FOR ub.gds-obj-prop-Attr.
   /*  */
   FIND FIRST buf_Gds-OP-attr WHERE
              buf_gds-OP-attr.gds-code  = buf_gds-OP.gds-code
          AND buf_gds-op-attr.obj-code  = buf_gds-OP.obj-code
          AND buf_gds-op-attr.obj-type  = buf_gds-op.obj-type
          AND buf_gds-op-attr.attr-code = {&gopattr-CorrIztDel}
        NO-LOCK NO-ERROR.
   IF AVAILABLE buf_gds-op-attr THEN DO:
      ASSIGN
         dtRet = DATE(buf_gds-op-attr.Attr-value)
         NO-ERROR.
      IF ERROR-STATUS:ERROR THEN DO:
         ASSIGN dtRet = ?.
      END.
   END.
   /*  */
   RETURN (dtRet).
END FUNCTION.


