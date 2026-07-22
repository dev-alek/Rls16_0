/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Инклудник, который должен позволить работать со спецификацией
подчиненным договорам

Автор: Носко Игорь Александрович
Дата создания: 22/02/2011
Author: Nosko Igor
Creation date: 22/02/2011

	Last change:  NIA  24 Feb 2011    3:44 pm
*/

&SCOPED-DEFINE vssseq {&sequence}
DEFINE VARIABLE vss-include-info{&vssseq} AS CHARACTER FORMAT "x(65)" NO-UNDO INITIAL "@(#)$Workfile$ $Revision$".
{ gbl/thbjattr.i}
{ str/cont-ms-def.i}


  /* Для снятия глобальных настроек fo-mc-mode  */
DEFINE VARIABLE v-gl-Character   AS CHARACTER  NO-UNDO .
DEFINE VARIABLE v-gl-Date        AS DATE       NO-UNDO .
DEFINE VARIABLE v-gl-Decimal     AS DECIMAL    NO-UNDO .
DEFINE VARIABLE v-gl-iMcMode     AS INTEGER    NO-UNDO . /* параметр fin-global/fo-mc-mode */
DEFINE VARIABLE v-gl-Logical     AS LOGICAL    NO-UNDO .
DEFINE VARIABLE v-gl-Param-Type  AS CHARACTER  NO-UNDO .
DEFINE VARIABLE v-gl-Error       AS CHARACTER  NO-UNDO  INITIAL "".
/*  */
DEFINE VARIABLE iTmpHost-code        AS INTEGER INITIAL 0 NO-UNDO.
DEFINE VARIABLE iTmpContract-code    AS INTEGER INITIAL 0 NO-UNDO.
DEFINE VARIABLE i-Cont-Ret           AS INTEGER INITIAL 0 NO-UNDO EXTENT 3.

/* Снимаем глобальные настройки fo-mc-mode  */
RUN adm/shattri.p (
      INPUT  "get":U,
      INPUT  "",            /* тип объекта  */
      INPUT  0,             /* код объекта  */
      INPUT  "fin-global",  /* название секции   */
      INPUT  "fo-mc-mode",  /* название параметра   */
      OUTPUT v-gl-Character,
      OUTPUT v-gl-Date,
      OUTPUT v-gl-Decimal,
      OUTPUT v-gl-iMcMode,     /* Здесь возвращается параметр fo-mc-mode 0 - старая схема  */
      OUTPUT v-gl-Logical,
      OUTPUT v-gl-Param-Type,
      INPUT-OUTPUT TABLE thbjattr_thbj-attr
    ) NO-ERROR.
IF ERROR-STATUS:ERROR THEN DO:
   ASSIGN
      v-gl-Error = "Ошибка определения глобального параметра fin-global/fo-mc-mode".
   MESSAGE
      v-gl-Error SKIP
      PROGRAM-NAME(1) ERROR-STATUS:GET-MESSAGE(1) RETURN-VALUE
      VIEW-AS ALERT-BOX.
END.

/* Если работаем с мастер договорами   */
IF (v-gl-iMcMode = 1 OR v-gl-iMcMode = 2) AND v-gl-Error = "" THEN DO:
   /* Сохраняем первоначальные значения Host-code и Contract-code    */
   ASSIGN
      iTmpHost-code      = {&P_HOST_CODE}
      iTmpContract-code  = {&P_CONTRACT_CODE}
      .
   /* Проверяем договор !!!  */
   RUN MS-Contract-EXTENT-3 IN THIS-PROCEDURE(
       INPUT  {&P_HOST_CODE},
       INPUT  {&P_CONTRACT_CODE},
       OUTPUT i-Cont-Ret
      ).
   /* Если у договора есть мастер договор -
      переназначаем Host-code и Contract-code,\
      чтобы спецификация бралась из мастер договора
   */
   IF i-Cont-Ret[1] = 2 THEN DO: /* подчиненный договор  */
      ASSIGN
         {&P_HOST_CODE}       = i-Cont-Ret[2]
         {&P_CONTRACT_CODE}   = i-Cont-Ret[3]
         .
   END.
END.

/* $Workfile$ e n d */

