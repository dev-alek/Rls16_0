/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Для работы Master\Slave

Автор: Носко Игорь Александрович
Дата создания: 08/02/2011
Author: Nosko Igor
Creation date: 08/02/2011

	Last change:  NIA  25 Feb 2011    2:33 pm
*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

/* Это для find и for  */
/* Вначале определяем параметры договора !!!
   Эти переменные должны бытьф обязательно определены
P_HOST_CODE
P_CONTRACT_NUM
*/
ASSIGN
   i-gl-Host-Code      = 0
   i-gl-Contract-Code  = 0
   i-gl-Extent3        = 0
   .
/* Проверяем договор !!!  */
RUN MS-Contract-EXTENT-3 IN THIS-PROCEDURE(
    INPUT  {&P_HOST_CODE},
    INPUT  {&P_CONTRACT_NUM},
    OUTPUT i-gl-Extent3
   ).
IF i-gl-Extent3[1] = 2 THEN DO: /* подчиненный договор  */
   ASSIGN
      i-gl-Host-Code      = i-gl-Extent3[2]
      i-gl-Contract-Code  = i-gl-Extent3[3]
      .
END. ELSE DO:
   ASSIGN
      i-gl-Host-Code      = {&P_HOST_CODE}
      i-gl-Contract-Code  = {&P_CONTRACT_NUM}
      .
END.

&IF DEFINED(FIND_FIRST) <> 0  &THEN
    FIND FIRST {&BUFFER_SPECIF}
           &IF DEFINED(NO_LOCK) <> 0 &THEN
           NO-LOCK
           &ENDIF
           &IF DEFINED(EXCLUSIVE_LOCK) <> 0 &THEN
           EXCLUSIVE-LOCK
           &ENDIF
           WHERE
               {&BUFFER_SPECIF}.Host-code    = i-gl-Host-Code
           AND {&BUFFER_SPECIF}.Contract-num = i-gl-Contract-Code
           &IF DEFINED(P_GDS_CODE) <> 0 &THEN
           AND {&BUFFER_SPECIF}.Gds-code     = {&P_GDS_CODE}
           &ENDIF
           &IF DEFINED(P_ATTR_CODE) <> 0 &THEN
           AND {&BUFFER_SPECIF}.Attr-code    = {&P_ATTR_CODE}
           &ENDIF
           &IF DEFINED(NO_ERROR) <> 0 &THEN
           NO-ERROR
           &ENDIF
           &IF DEFINED(NO_END) = 0 &THEN
           .
           &ENDIF



&ENDIF
/*  */
&IF DEFINED(FOR_) <> 0  &THEN FOR &IF DEFINED(EACH_) <> 0  &THEN EACH &ENDIF
    {&BUFFER_SPECIF}
     &IF DEFINED(NO_LOCK) <> 0 &THEN
     NO-LOCK
     &ENDIF
     &IF DEFINED(EXCLUSIVE_LOCK) <> 0 &THEN
     EXCLUSIVE-LOCK
     &ENDIF
     WHERE
         {&BUFFER_SPECIF}.Host-code    = i-gl-Host-Code
     AND {&BUFFER_SPECIF}.Contract-num = i-gl-Contract-Code
     &IF DEFINED(P_GDS_CODE) <> 0 &THEN
     AND {&BUFFER_SPECIF}.Gds-code     = {&P_GDS_CODE}
     &ENDIF
     &IF DEFINED(P_ATTR_CODE) <> 0 &THEN
     AND {&BUFFER_SPECIF}.Attr-code    = {&P_ATTR_CODE}
     &ENDIF
     &IF DEFINED(NO_END) = 0 &THEN
     :
     &ENDIF

&ENDIF


/* $Workfile$ e n d */

