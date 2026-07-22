/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедуры и функции для работы с АМ (для задачи "Процент отклонения матрицы от шаблона")
Инклудник подключать после gbl/thbjattr.i, или после gbl/thbj-def.i
да и вообще, лучше всего после всего !!!

Автор: Носко Игорь Александрович
Дата создания: 04/05/2011
Author: Nosko Igor
Creation date: 04/05/2011

*/

&SCOPED-DEFINE vssseq {&sequence}
DEFINE VARIABLE vss-include-info{&vssseq} AS CHARACTER FORMAT "x(65)" NO-UNDO INITIAL "@(#)$Workfile$ $Revision$".


/* Кусочек для подсчета количества добавленных товаров по буферу  */
&IF DEFINED(DEF_CALC_DELTA_BUF) <> 0 &THEN
FOR EACH {&BUF_LIST} NO-LOCK:
    IF NOT CAN-FIND(FIRST ub.Assortment-matrix-goods WHERE
                          ub.Assortment-matrix-goods.Asmt-id      = {&VAR_ASMT-ID}
                      AND ub.Assortment-matrix-goods.Db-num       = {&VAR_DB-NUM}
                      AND ub.Assortment-matrix-goods.gds-code     = {&BUF_LIST}.gds-code
                      AND ub.Assortment-matrix-goods.asmg-status  = INTEGER({&current-status-int})
                      NO-LOCK) THEN DO:
       ASSIGN
          {&VAR_DELTA} = {&VAR_DELTA} + 1.
    END.
END.
&ENDIF



/* Общие процедуры и перемнные  */
&IF DEFINED(DEF_PROC) <> 0 &THEN

&SCOPED-DEFINE N_EXTENT 2

FUNCTION indicator-life-gds-n RETURNS CHARACTER ( input p-rec as recid ) FORWARD.

/* Допустимый процент отклонения матрицы от шаблона (из настроек) !!!  */
DEFINE VARIABLE v-gl-iProc-Otkl AS DECIMAL NO-UNDO INITIAL 0.
/* Это все устанавливается по одной матрице  */
DEFINE VARIABLE v-gl-lAM-Is-Obj         AS LOGICAL NO-UNDO INITIAL FALSE.  /*  Матрица является объектной  */
DEFINE VARIABLE v-gl-iAM-Gds-All        AS INTEGER NO-UNDO INITIAL 0.      /* всего в АМ (в статусе тек 0) */
DEFINE VARIABLE v-gl-iAM-Sbl-Gds-All    AS INTEGER NO-UNDO INITIAL 0.      /* это в соответствующем шаблоне  */
DEFINE VARIABLE v-gl-iAM-Gds-Vyv        AS INTEGER NO-UNDO INITIAL 0.      /* количество в АМ на вывод из асортимента */
DEFINE VARIABLE v-gl-lAM-Ref-Shablon    AS LOGICAL NO-UNDO INITIAL FALSE.  /*  AM связана с шаблоном */
DEFINE VARIABLE v-gl-dAM-Proc-Otkl      AS DECIMAL NO-UNDO INITIAL 0.      /* % отклонения АМ от шаблона  */
DEFINE VARIABLE v-gl-dAM-Proc-Otkl-Ras  AS DECIMAL NO-UNDO INITIAL 0.      /* % отклонения АМ от шаблон, будущий расчетный   */


/***********
    Функция проверки вхождения товара в АМ
***********/
FUNCTION Is-Gds-In-AssMatr RETURN LOGICAL(
   p-Gds-code AS INTEGER,
   p-Asmt-id  AS INTEGER,
   p-Db-num   AS INTEGER):
   /*  */
   DEFINE BUFFER buf_Gds FOR Ub.Assortment-matrix-goods.
   /*  */
   RETURN CAN-FIND(FIRST buf_Gds WHERE
                         buf_Gds.Asmt-id     = p-Asmt-id
                     AND buf_Gds.Db-num      = p-Db-num
                     AND buf_Gds.Gds-code    = p-Gds-code
                     AND buf_Gds.Asmg-status = INTEGER({&current-status-int})
                   NO-LOCK).
   /*  */
END FUNCTION.
 



/***********
   Процедура определения количественной разницы товаров между двумя матрицами.
************/
PROCEDURE Get-Delta-Gds-2-Matrix:
   DEFINE PARAMETER BUFFER buf_AM-1 FOR ub.Assortment-matrix.
   DEFINE PARAMETER BUFFER buf_AM-2 FOR ub.Assortment-matrix.
   DEFINE OUTPUT PARAMETER iDelta AS INTEGER NO-UNDO INITIAL 0.
   /*  */
   DEFINE BUFFER buf_Gds-1 FOR ub.Assortment-matrix-goods.
   DEFINE BUFFER buf_Gds-2 FOR ub.Assortment-matrix-goods.
   /*  */
   FOR EACH buf_Gds-1 WHERE
            buf_Gds-1.Asmt-id = buf_AM-1.Asmt-id
        AND buf_Gds-1.Db-num  = buf_AM-1.Db-num
        AND buf_Gds-1.Asmg-status = INTEGER({&current-status-int}) /* Считаем только в статусе тек */
       NO-LOCK:
       IF NOT CAN-FIND(FIRST buf_Gds-2 WHERE
                             buf_Gds-2.Asmt-id     = buf_AM-2.Asmt-id
                         AND buf_Gds-2.Db-num      = buf_AM-2.Db-num
                         AND buf_Gds-2.Gds-code    = buf_Gds-1.Gds-code
                         AND buf_Gds-2.Asmg-status = INTEGER({&current-status-int})
                         NO-LOCK) THEN DO:
          ASSIGN
             iDelta = iDelta + 1.
       END.
   END.
   RETURN.
END PROCEDURE.

/***********
   Процедура контроля добавления товара в матрицу 1
************/
PROCEDURE Cntrl-AM-Add-1:
   DEFINE INPUT PARAMETER iDelta  AS INTEGER   NO-UNDO.
   DEFINE OUTPUT PARAMETER cError AS CHARACTER NO-UNDO INITIAL "".
   /*  */
   IF v-gl-iProc-Otkl = 0      THEN RETURN. /* Не установлен в настройках % отклонения  */
   IF NOT v-gl-lAM-Is-Obj      THEN RETURN. /* это шаблон  */
   IF NOT v-gl-lAM-Ref-Shablon THEN RETURN. /* матрица не связана с шаблоном   */

   /* Вроде все проверки пройдены - толкнем расчет  */
   RUN Calc-Proc-Otkl IN THIS-PROCEDURE(iDelta). /* */

   IF iDelta = 0 THEN DO:        /* работаем с текущим % отклонения  */
      IF v-gl-dAM-Proc-Otkl >= v-gl-iProc-Otkl THEN DO:   /* и реальный % отклонения в матрице >= установленному % отклонения  */
         cError = "В данной матрице процент отклонения товаров от шаблона (=" + STRING(v-gl-dAM-Proc-Otkl) + ")" + {&new-line} +
                  " больше допустимого (=" + STRING( v-gl-iProc-Otkl) +  ")." + {&new-line} +
                  "Добавление товаров невозможно !".
      END.
   END. ELSE DO:                 /* работаем с расчетным  % отклонения  */
      IF v-gl-dAM-Proc-Otkl-Ras >= v-gl-iProc-Otkl THEN DO:   /* расчетный % отклонения в матрице >= установленному % отклонения  */
         cError = "В данной матрице будущий расчетный процент отклонения товаров от шаблона (=" + STRING(v-gl-dAM-Proc-Otkl-Ras) + ")" + {&new-line} +
                  " больше допустимого (=" + STRING( v-gl-iProc-Otkl ) +  ")." + {&new-line} +
                  " Добавление товаров невозможно !".
      END.
   END.
   /*  */
   RETURN.
END PROCEDURE.


/**************
   Ну и совсем общая процедура
**************/
PROCEDURE Get-Gl-Param-Proc-Otkl:
   DEFINE INPUT PARAMETER   p-Asmt-Id AS INTEGER    NO-UNDO.
   DEFINE INPUT PARAMETER   p-Db-num  AS INTEGER    NO-UNDO.
   DEFINE OUTPUT PARAMETER  cError    AS CHARACTER  NO-UNDO INITIAL "".
   /*  */
   DEFINE BUFFER buf_AM   FOR ub.Assortment-Matrix.
   /*  */
   FIND FIRST buf_AM WHERE
              buf_AM.asmt-id = p-Asmt-id
          AND buf_AM.db-num  = p-Db-num
        NO-LOCK NO-ERROR.
   IF NOT AVAILABLE buf_AM THEN DO:
      /* Ну не может такого быть !!!   */
      cError = PROGRAM-NAME(1) +  ":Не найдена АМ id=" + STRING(p-Asmt-id) + " db-num=" + STRING(p-Db-num).
      RETURN.
   END.

   /* Снимаем допустимый процент отклонения из настроек  */
   RUN Get-Gl-Set-Proc-Otkl IN THIS-PROCEDURE(
       buf_AM.obj-type,
       buf_AM.obj-code
       ).

   /* Cнимаем параметры по АМ */
   RUN Get-Gl-Param-AM-All in THIS-PROCEDURE(
       buf_AM.Asmt-id,
       buf_AM.db-num
       ).
   /*  */
   RETURN.
END PROCEDURE.


/****************
   Процедура установки глобальных параметров матрицы.
*****************/
PROCEDURE Get-Gl-Param-AM-All:
   DEFINE INPUT PARAMETER   p-Asmt-Id AS INTEGER    NO-UNDO.
   DEFINE INPUT PARAMETER   p-Db-num  AS INTEGER    NO-UNDO.
   /*  */
   DEFINE VARIABLE lIsAmObj    AS LOGICAL    NO-UNDO INITIAL FALSE.
   DEFINE VARIABLE iSh-Asmt-id AS INTEGER    NO-UNDO INITIAL 0.
   DEFINE VARIABLE iSh-Db-num  AS INTEGER    NO-UNDO INITIAL 0.
   DEFINE VARIABLE cSh-Type    AS CHARACTER  NO-UNDO INITIAL "".
   DEFINE VARIABLE cError      AS CHARACTER  NO-UNDO INITIAL "".
   DEFINE VARIABLE dAmt        AS DECIMAL    EXTENT {&N_EXTENT}  NO-UNDO INITIAL 0.
   DEFINE VARIABLE cMode       AS CHARACTER  NO-UNDO INITIAL "".
   /*  */
   /* Первоначальный сброс gl параметров  */
   ASSIGN
      v-gl-iAM-Gds-All     = 0
      v-gl-iAM-Sbl-Gds-All = 0
      v-gl-iAM-Gds-Vyv     = 0
      v-gl-dAM-Proc-Otkl   = 0
      v-gl-lAM-Ref-Shablon = FALSE
      .

   /* Выходим на шаблон, если он есть  */
   RUN Get-Param-AM IN THIS-PROCEDURE (
       p-Asmt-id,
       p-Db-num,
       OUTPUT lIsAmObj,
       OUTPUT iSh-Asmt-id,
       OUTPUT iSh-Db-num,
       OUTPUT cSh-Type,
       OUTPUT cError
       ).

   IF cError <> "" THEN DO:
      MESSAGE
         PROGRAM-NAME(1) ":" SKIP
         "Такого быть не должно !!!" SKIP
         cError SKIP
         VIEW-AS ALERT-BOX INFO BUTTONS OK.
      RETURN.
   END.
   /* Установка режима подсчета, и связи с шаблоном   */
   ASSIGN
      cMode                 = (IF lIsAmObj THEN "IL_GDS":U ELSE "")
      v-gl-lAM-Ref-Shablon  = (IF iSh-Asmt-id = 0 THEN FALSE ELSE TRUE)
      .

   /* Подсчет количественных показателей товаров по матрице  */
   RUN Get-Param-AM-Gds IN THIS-PROCEDURE(
       p-Asmt-Id,
       p-Db-num,
       {&current-status-int},
       cMode,
       OUTPUT dAmt
       ).

   /* Устанавливаем gl переменные  */
   ASSIGN
      v-gl-iAM-Gds-All = dAmt[1]  /* Всего по матрице, и если матрица шаблон - тоже самое  */
      v-gl-iAM-Gds-Vyv = (IF lIsAmObj THEN dAmt[2] ELSE 0) /* Если матрица по объекту - устанавливаем количество на вывод  */
      .

    /* Если нет связи с шаблоном - на этом заканчиваем !!!   */
    IF NOT v-gl-lAM-Ref-Shablon THEN DO:
       RETURN.
    END.

   /* Подсчет по шаблону  */
   RUN Get-Param-AM-Gds IN THIS-PROCEDURE(
       iSh-Asmt-id,
       iSh-Db-num, 
       {&current-status-int},
       "",
       OUTPUT dAmt
       ).

   ASSIGN
      v-gl-iAM-Sbl-Gds-All = dAmt[1].

   /* Расчитываем % отклонения  */
   RUN Calc-Proc-Otkl IN THIS-PROCEDURE(0). /* Расчетный здесь пока не нужен */

   RETURN.
END PROCEDURE.



/****************
   Процедура подсчета количественных показателей товаров по АМ
*****************/
PROCEDURE Get-Param-AM-Gds:
   DEFINE INPUT PARAMETER   p-Asmt-Id AS INTEGER    NO-UNDO.
   DEFINE INPUT PARAMETER   p-Db-num  AS INTEGER    NO-UNDO.
   DEFINE INPUT PARAMETER   p-Stat    AS INTEGER    NO-UNDO.
   DEFINE INPUT PARAMETER   p-Mode    AS CHARACTER  NO-UNDO.
   DEFINE OUTPUT PARAMETER  o-dAmt    AS DECIMAL    EXTENT {&N_EXTENT} NO-UNDO INITIAL 0.
   /*  */
   DEFINE BUFFER buf_AM-goods FOR ub.Assortment-matrix-goods.
   /*  */
   FOR EACH buf_AM-goods WHERE
            buf_AM-goods.Asmt-id      = p-Asmt-Id
        AND buf_AM-goods.Db-num       = p-Db-num
        AND buf_AM-goods.asmg-status  = p-Stat
       NO-LOCK:
       /* В первый элемент массива считаем просто количество товаров */
       ASSIGN
          o-dAmt[1] = o-dAmt[1] + 1.
       /* теперь от режима (сейчас только indicator-life-gds ) */
       IF CAN-DO("IL_GDS":U, p-Mode) THEN DO:
          /* Считаем сколько на вывод из асортимента  */
          IF Indicator-life-gds-n(recid(buf_AM-goods)) = {&ass-izd-del} THEN DO:
             ASSIGN
                o-dAmt[2] = o-dAmt[2] + 1.
          END.
       END.
   END.
   /*  */
   RETURN.
END PROCEDURE.

/************
           Определение параметров АМ
           Параметры определяем для АМ объекта.
           Шаблон нас пока не интересует.
************/
PROCEDURE Get-Param-AM:
   DEFINE INPUT  PARAMETER  p-Asmt-id   AS INTEGER   NO-UNDO.
   DEFINE INPUT  PARAMETER  p-Db-num    AS INTEGER   NO-UNDO.
   DEFINE OUTPUT PARAMETER  lIsObj      AS LOGICAL   NO-UNDO INITIAL FALSE.
   /* Выходные параметры шаблона  */
   DEFINE OUTPUT PARAMETER  o-Asmt-id   AS INTEGER   NO-UNDO INITIAL 0.
   DEFINE OUTPUT PARAMETER  o-Db-Num    AS INTEGER   NO-UNDO INITIAL 0.
   DEFINE OUTPUT PARAMETER  v-Type      AS CHARACTER NO-UNDO INITIAL "".
   /*  */
   DEFINE OUTPUT PARAMETER  cError      AS CHARACTER NO-UNDO INITIAL "".
   /*  */
   DEFINE VARIABLE v-value AS  CHARACTER NO-UNDO INITIAL "".
   /*  */
   DEFINE BUFFER buf_AM   FOR ub.Assortment-Matrix.
   DEFINE BUFFER buf_AM-2 FOR ub.Assortment-Matrix.

   ASSIGN 
      v-gl-lAM-Is-Obj = FALSE.

   /*  */
   FIND FIRST buf_AM WHERE
              buf_AM.asmt-id = p-Asmt-id
          AND buf_AM.db-num  = p-Db-num
        NO-LOCK NO-ERROR.
   IF NOT AVAILABLE buf_AM THEN DO:
      /* Хотя это врядли !!!  */
      cError = "Не найдена АМ id=" + STRING(p-Asmt-id) + " db-num=" + STRING(p-Db-num).
      RETURN.
   END.
   /*  */
   IF buf_AM.asmt-type <> {&type-assmatr-obj} THEN DO:
      /* Никаких ошибок, нас шаблоны пока не интересуют */
      RETURN.
   END. ELSE DO:
      ASSIGN
         lIsObj           = TRUE
         v-gl-lAM-Is-Obj  = TRUE /* и глобальный - матрица является объектной  */
         .
   END.

   /* Определяем связь между матрицей и шаблоном   */
   run assmatat-value (
       input buf_AM.asmt-id
      ,input buf_AM.db-num
      ,input {&assmatat-RootShablon}
      ,output v-value
      ,output v-type
      ) .

   IF v-value = "" OR v-value = ? THEN DO:
      /* Связи с шаблоном нет - ошибок не выдаем !!!  */
      RETURN.
   END.

   /* Разложим  v-value */
   ASSIGN
      o-Asmt-id = INTEGER(ENTRY(1, v-value, {&delim-par}))
      o-Db-num  = INTEGER(ENTRY(2, v-value, {&delim-par}))
      NO-ERROR.
   IF ERROR-STATUS:ERROR THEN DO:
      /* Такого вроде тоже быть не должно  */
      cError = PROGRAM-NAME(1) + ":" + ERROR-STATUS:GET-MESSAGE(1).
      RETURN.
   END.
   /* Ну и проверим еше раз  */
   FIND FIRST buf_AM-2 WHERE
              buf_AM-2.asmt-id = o-Asmt-id
          AND buf_AM-2.db-num  = o-Db-num
        NO-LOCK NO-ERROR.
   IF NOT AVAILABLE buf_AM-2 THEN DO:
      /* Хотя это тоже врядли !!!  */
      cError = "Не найден шаблон АМ id=" + STRING(o-Asmt-id) + " db-num=" + STRING(o-Db-num).
      RETURN.
   END.
   /*  */
   RETURN.
END PROCEDURE.


/************
           Определение допустимого % отклонения матрицы от шаблона
           по объекту из настроек.
************/
PROCEDURE Get-Gl-Set-Proc-Otkl:
   DEFINE INPUT PARAMETER  cObj-type AS CHARACTER NO-UNDO.
   DEFINE INPUT PARAMETER  iObj-code AS INTEGER   NO-UNDO.
   /*  */
   DEFINE VARIABLE v-Character   AS CHARACTER  NO-UNDO .
   DEFINE VARIABLE v-Date        AS DATE       NO-UNDO .
   DEFINE VARIABLE v-Decimal     AS DECIMAL    NO-UNDO .
   DEFINE VARIABLE v-Integer     AS INTEGER    NO-UNDO . /*  */
   DEFINE VARIABLE v-Logical     AS LOGICAL    NO-UNDO .
   DEFINE VARIABLE v-Param-Type  AS CHARACTER  NO-UNDO .
   /*  */
   ASSIGN
      v-gl-iProc-Otkl = 0
      .
   /* Снимаем допустимый процент отклонения из настроек  */
   EMPTY TEMP-TABLE thbjattr_thbj-attr .
   RUN adm/shattri.p (
           INPUT  "get":U,
           INPUT  cObj-type,                             /* тип объекта  */
           INPUT  iObj-code,                             /* код объекта  */
           INPUT  {&attr-ass-obj},                       /* название секции   */
           INPUT  {&attr-Ass-obj_ass-proc-matr-shabl} ,  /* название параметра   */
           OUTPUT v-Character,
           OUTPUT v-Date,
           OUTPUT v-Decimal,                             /* Здесь возвращается параметр */
           OUTPUT v-Integer,
           OUTPUT v-Logical,
           OUTPUT v-Param-Type,
           INPUT-OUTPUT TABLE thbjattr_thbj-attr
       ) NO-ERROR.
   /*  */
   IF ERROR-STATUS:ERROR THEN DO:
      ASSIGN
         v-Integer  = 0
         v-Decimal  = 0.
   END. ELSE DO:
      /* Устанавливаем переменную */
      ASSIGN
         v-gl-iProc-Otkl = v-Integer
         .
   END.
   /*  */
   RETURN.
END PROCEDURE.


/*************
 Расчитать % отклонения матрицы от шаблона !!!
*************/
PROCEDURE Calc-Proc-Otkl:
   DEFINE INPUT PARAMETER iDeltaGds AS INTEGER NO-UNDO.
   /*  */
   DEFINE VARIABLE iTmp AS INTEGER NO-UNDO INITIAL 0.
   /*  */
   ASSIGN
      v-gl-dAM-Proc-Otkl     = 0
      v-gl-dAM-Proc-Otkl-Ras = 0
      .

   IF NOT v-gl-lAM-Ref-Shablon THEN DO:    /* Не связана с шаблоном  */
      RETURN.
   END.

   /* Если в шаблоне 0 - устанавливаем принудительно 99999  */
   IF v-gl-iAM-Sbl-Gds-All = 0 THEN DO:
      ASSIGN
         v-gl-dAM-Proc-Otkl     = 999999
         v-gl-dAM-Proc-Otkl-Ras = 999999
         .
      RETURN.
   END.
   /*  */
   ASSIGN
      iTmp = (v-gl-iAM-Gds-All - v-gl-iAM-Sbl-Gds-All)
      v-gl-dAM-Proc-Otkl     = ROUND(iTmp * 100 / v-gl-iAM-Sbl-Gds-All, 2)
      v-gl-dAM-Proc-Otkl-Ras = ROUND((iTmp + iDeltaGds)  * 100 / v-gl-iAM-Sbl-Gds-All, 2) /* Будущий расчетный с добавлением товаров */
      .
   /*  */
   RETURN.
END PROCEDURE.


/*************
Копия для совместимости
*************/
FUNCTION indicator-life-gds-n RETURNS CHARACTER
( input p-rec as recid ) :
define buffer buf_matrix-goods for ub.assortment-matrix-goods .
define variable v-gdop-min-stock              as decimal   no-undo .
define variable v-grop-max-stock              as decimal   no-undo .
define variable v-grop-level-always-presence  as decimal   no-undo .
define variable v-grop-min-order              as decimal   no-undo .
define variable v-assort-min                  as LOGICAL   NO-UNDO.
DEFINE variable v-indicator-life-gds          as CHARACTER NO-UNDO.

find first buf_matrix-goods no-lock where recid (buf_matrix-goods) = p-rec no-error .
if error-status :error then return '' .
{ gbl/gdsobjpr.i
  buf_Matrix-goods.obj-type
  buf_Matrix-goods.obj-code
  ?
  ?
  ?
  buf_Matrix-goods.gds-code
  v-assort-min
  v-indicator-life-gds
  v-gdop-min-stock
  v-grop-max-stock
  v-grop-level-always-presence
  v-grop-min-order
  }
  return v-indicator-life-gds.
end function.

&UNDEFINE N_EXTENT

&ENDIF


/* end of file ass-mat.i */
