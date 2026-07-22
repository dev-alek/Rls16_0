block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: sb-lib.p $
$Archive: gbl/sb-lib.p $

Библионтека для обслуживания банковских карт (Сбербанк)

Автор: Белоусов Илья Александрович
Дата создания: 09/24/08
Author: Ilia Belousov
Creation date: 09/24/08

Input:

Output:

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: sb-lib.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/sb-lib.p $":U .
define variable vss-description as character no-undo init "Библионтека для обслуживания банковских карт (Сбербанк)".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ gbl/sb-lib.i   }


if valid-handle (g#sb-lib)
and g#sb-lib <> this-procedure :handle
and g#sb-lib :get-signature('library_testproc':u) <> ""
then do:
  message
    vss-workfile vss-revision vss-description skip
    "Попытка повторной загрузки библиотеки" skip
    g#sb-lib skip
    g#sb-lib :type skip
    g#sb-lib :file-name skip
    valid-handle(g#sb-lib) skip
    this-procedure :handle skip
    this-procedure :type skip
    this-procedure :file-name skip
    valid-handle(this-procedure) skip
    view-as alert-box error .
  undo, return error return-value .
end.
else do:
  assign
    g#sb-lib = this-procedure :handle
  .
end.

if this-procedure :persistent <> true
then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка запуска библиотеки" program-name(1) skip
    "Попытка запустить ее как обычную процедуру" skip
    view-as alert-box error .
end.

on delete of this-procedure do:
  assign
    g#sb-lib = ?
  .
end.


&scop sberbank  100


DEFINE VARIABLE v-sb         AS COM-HANDLE   NO-UNDO . /* Ссылка на драйвер */
define variable v-sb-type    as integer      no-undo.  /* Тип */


/*==========================================================================*/
procedure sb-init :
/*------------------------------------------------------------------------------
  Purpose: Инициализация драйвера
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter  p-cashless-system as character        no-undo.
define output parameter p-message as character        no-undo.
define output parameter p-ok      as logical          no-undo.

define variable v-output    as character    no-undo.
bl:
do
on error undo, return error
:
   RELEASE OBJECT v-sb NO-ERROR.
   v-sb = ?.

   IF  p-cashless-system = {&cd-cashless-systems}
   THEN DO:
      CREATE "SBRFSRV.server":U v-sb NO-ERROR.

      IF ERROR-STATUS:ERROR
      OR NOT VALID-HANDLE(v-sb)
      THEN DO:
         ASSIGN
            p-message = "Не найден COM-сервер для Сбербанка"
         .
         RETURN.
      END.
      assign
         v-sb-type = {&sberbank}
      .

      v-sb:CONNECT() NO-ERROR.
      IF ERROR-STATUS:ERROR
      THEN DO:
         ASSIGN
            p-message = RETURN-VALUE
            p-ok      = FALSE
         .
         RETURN.
      END.
   END.
   assign
      p-ok = TRUE
   .



end. /* do on error */
end procedure. /* sb-init */




&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE sb-cardinfo Include
PROCEDURE sb-cardinfo :
/*------------------------------------------------------------------------------
  Purpose: Информация о карте
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define output parameter p-card-num as character        no-undo.
define output parameter p-card-type as character        no-undo.
define output parameter p-message as character        no-undo.
define output parameter p-ok          as logical          no-undo.

define variable v-clientcard    as character    no-undo.
define variable v-output    as character    no-undo.

IF VALID-HANDLE(v-sb)
THEN DO
ON ERROR UNDO, RETURN ERROR
:
   CASE v-sb-type :
      WHEN {&sberbank} THEN DO:

         p-message = v-sb:Clear() NO-ERROR.
         IF ERROR-STATUS:ERROR
         OR (p-message <> ? AND p-message <> "":U AND p-message <> "0":U)
         THEN DO:
            ASSIGN
               p-ok = FALSE
            .
            RETURN.
         END.

         v-sb:sParam(INPUT "CardType", INPUT 0).
         v-sb:sParam(INPUT "Amount",   INPUT 0).
         v-sb:sParam(INPUT "Track2",  INPUT "").

         p-message = v-sb:NFun (INPUT 5000) NO-ERROR.
         IF ERROR-STATUS:ERROR
         OR (p-message <> ? AND p-message <> "":U AND p-message <> "0":U)
         THEN DO:
            ASSIGN
               p-ok = FALSE
            .
            RETURN.
         END.
         ASSIGN
            p-card-num  = v-sb:gParamString(INPUT "CardName")
            p-card-type = v-sb:gParamString(INPUT "CardType")
         .

         p-message = v-sb:Clear() NO-ERROR.
         IF ERROR-STATUS:ERROR
         OR (p-message <> ? AND p-message <> "":U AND p-message <> "0":U)
         THEN DO:
            ASSIGN
               p-ok = FALSE
            .
            RETURN.
         END.
         ASSIGN
            p-ok = TRUE
         .
      END.
      OTHERWISE DO:
      END.
   END CASE.
   ASSIGN
      p-ok = TRUE
   .
END.  /* do on error */
ELSE DO:
   ASSIGN
      p-ok = TRUE
   .
END.
END PROCEDURE. /* sb-cardinfo */
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE sb-sale Include
PROCEDURE sb-sale :
/*------------------------------------------------------------------------------
  Purpose: Оплата продажи
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter  p-summ     as decimal          no-undo.
define output parameter p-slip     as character        no-undo.
define output parameter p-card-num as character        no-undo.
define output parameter p-message  as character        no-undo.
define output parameter p-ok       as logical          no-undo.

IF VALID-HANDLE(v-sb)
THEN DO
ON ERROR UNDO, RETURN ERROR
:
   CASE v-sb-type :
      WHEN {&sberbank} THEN DO:

         p-message = v-sb:Clear() NO-ERROR.
         IF ERROR-STATUS:ERROR
         OR (    p-message <> ?
             AND p-message <> "":U
             AND p-message <> "0":U
             )
         THEN DO:
            ASSIGN
               p-ok = FALSE
            .
            RETURN.
         END.

         v-sb:sParam(INPUT "CardType", INPUT 0).
         v-sb:sParam(INPUT "Amount",   INPUT TRUNCATE((p-summ * 100), 0)).
         v-sb:sParam(INPUT "Track2",  INPUT "").

         p-message = v-sb:NFun (INPUT 4000) NO-ERROR.
         IF ERROR-STATUS:ERROR
         OR (p-message <> ? AND p-message <> "":U AND p-message <> "0":U)
         THEN DO:
            /*
            message
               "X"  ERROR-STATUS:ERROR
               skip SUBSTITUTE("|&1|",p-message)
            view-as alert-box information.
            */
            ASSIGN
               p-ok = FALSE
            .
            RETURN.
         END.
         assign
            p-slip      = v-sb:gParamString(INPUT "Cheque")
            p-card-num  = v-sb:gParamString(INPUT "ClientCard")
         .

         p-message = v-sb:Clear() NO-ERROR.
         IF ERROR-STATUS:ERROR
         OR (p-message <> ? AND p-message <> "":U AND p-message <> "0":U)
         THEN DO:
            ASSIGN
               p-ok = FALSE
            .
            RETURN.
         END.
         ASSIGN
            p-ok = TRUE
         .
      END.
      OTHERWISE DO:
      END.
   END CASE.
END.  /* do on error */
ELSE DO:
   ASSIGN
      p-ok = TRUE
   .
END.
END PROCEDURE. /* sb-sale */
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE sb-ret Include
PROCEDURE sb-ret :
/*------------------------------------------------------------------------------
  Purpose: Выплата по возврату
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter  p-summ      as decimal          no-undo .
define input parameter  p-card-num  as character        no-undo .
define output parameter p-slip      as character        no-undo .
define output parameter p-message   as character        no-undo .
define output parameter p-ok        as logical          no-undo .

IF VALID-HANDLE(v-sb)
THEN DO
ON ERROR UNDO, RETURN ERROR
:
   CASE v-sb-type :
      WHEN {&sberbank} THEN DO:
         p-message = v-sb:Clear() NO-ERROR.
         IF ERROR-STATUS:ERROR
         OR (p-message <> ? AND p-message <> "":U AND p-message <> "0":U)
         THEN DO:
            ASSIGN
               p-ok = FALSE
            .
            RETURN.
         END.

         v-sb:sParam(INPUT "CardType", INPUT 0).
         v-sb:sParam(INPUT "Amount",   INPUT TRUNCATE((ABS(p-summ) * 100), 0)).
         v-sb:sParam(INPUT "Track2",  INPUT "").


         p-message = v-sb:NFun (INPUT 4002) NO-ERROR.
         IF ERROR-STATUS:ERROR
         OR (p-message <> ? AND p-message <> "":U AND p-message <> "0":U)
         THEN DO:
            ASSIGN
               p-ok = FALSE
            .
            RETURN.
         END.
         assign
            p-slip      = v-sb:gParamString(INPUT "Cheque")
            p-card-num  = v-sb:gParamString(INPUT "ClientCard")
         .

         p-message = v-sb:Clear() NO-ERROR.
         IF ERROR-STATUS:ERROR
         OR (p-message <> ? AND p-message <> "":U AND p-message <> "0":U)
         THEN DO:
            ASSIGN
               p-ok = FALSE
            .
            RETURN.
         END.

         ASSIGN
            p-ok = TRUE
         .
      END.
      OTHERWISE DO:
      END.
   END CASE.
END.  /* do on error */
ELSE DO:
   ASSIGN
      p-ok = TRUE
   .
END.
END PROCEDURE. /* sb-ret */
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE sb-revert Include
PROCEDURE sb-revert :
/*------------------------------------------------------------------------------
  Purpose:  Откат операции
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter  p-summ    as decimal          no-undo.
define output parameter p-slip    as character          no-undo.
define output parameter p-card-num  as character        no-undo .
define output parameter p-message as character        no-undo.
define output parameter p-ok      as logical          no-undo.

IF VALID-HANDLE(v-sb)
THEN DO
ON ERROR UNDO, RETURN ERROR
:
   CASE v-sb-type :
      WHEN {&sberbank} THEN DO:

         p-message = v-sb:Clear() NO-ERROR.
         IF ERROR-STATUS:ERROR
         OR (p-message <> ? AND p-message <> "":U AND p-message <> "0":U)
         THEN DO:
            ASSIGN
               p-ok = FALSE
            .
            RETURN.
         END.

         v-sb:sParam(INPUT "CardType", INPUT 0).
         v-sb:sParam(INPUT "Amount",   INPUT TRUNCATE((p-summ * 100), 0)).
         v-sb:sParam(INPUT "Track2",  INPUT "").

         p-message = v-sb:NFun (INPUT 4003) NO-ERROR.
         IF ERROR-STATUS:ERROR
         OR (p-message <> ? AND p-message <> "":U AND p-message <> "0":U)
         THEN DO:
            ASSIGN
               p-ok = FALSE
            .
            RETURN.
         END.
         assign
            p-slip = v-sb:gParamString(INPUT "Cheque")
            p-card-num  = v-sb:gParamString(INPUT "ClientCard")
         .

         p-message = v-sb:Clear() NO-ERROR.
         IF ERROR-STATUS:ERROR
         OR (p-message <> ? AND p-message <> "":U AND p-message <> "0":U)
         THEN DO:
            ASSIGN
               p-ok = FALSE
            .
            RETURN.
         END.
         ASSIGN
            p-ok = TRUE
         .
      END.
      OTHERWISE DO:
      END.
   END CASE.
END.  /* do on error */
ELSE DO:
   ASSIGN
      p-ok = TRUE
   .
END.
END PROCEDURE. /* sb-revert */
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




PROCEDURE sb-day :
/*------------------------------------------------------------------------------
  Purpose:   Итоги за день
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define output parameter p-message as character        no-undo.
define output parameter p-ok      as logical          no-undo.

IF VALID-HANDLE(v-sb)
THEN DO
ON ERROR UNDO, RETURN ERROR
:
   CASE v-sb-type :
      WHEN {&sberbank} THEN DO:

         p-message = v-sb:Clear() NO-ERROR.
         IF ERROR-STATUS:ERROR
         OR (p-message <> ? AND p-message <> "":U AND p-message <> "0":U)
         THEN DO:
            ASSIGN
               p-ok = FALSE
            .
            RETURN.
         END.

         p-message = v-sb:NFun (INPUT 6000) NO-ERROR.
         IF ERROR-STATUS:ERROR
         OR (p-message <> ? AND p-message <> "":U AND p-message <> "0":U)
         THEN DO:
            ASSIGN
               p-ok = FALSE
            .
            RETURN.
         END.

         p-message = v-sb:Clear() NO-ERROR.
         IF ERROR-STATUS:ERROR
         OR (p-message <> ? AND p-message <> "":U AND p-message <> "0":U)
         THEN DO:
            ASSIGN
               p-ok = FALSE
            .
            RETURN.
         END.
         ASSIGN
            p-ok = TRUE
         .
      END.
      OTHERWISE DO:
      END.
   END CASE.
END.  /* do on error */
ELSE DO:
   ASSIGN
      p-ok = TRUE
   .
END.
END PROCEDURE. /* sb-day */
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/* шаблон
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE sb-chkcl Include
PROCEDURE sb-chkcl :
/*------------------------------------------------------------------------------
  Purpose: Открыть чек
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define output parameter p-message as character        no-undo.
define output parameter p-ok          as logical          no-undo.
IF VALID-HANDLE(v-sb)
THEN DO
ON ERROR UNDO, RETURN ERROR
:
   CASE v-sb-type :
      WHEN {&sberbank} THEN DO:
         p-message = v-sb:Clear() NO-ERROR.
         IF ERROR-STATUS:ERROR
         OR (p-message <> ? AND p-message <> "":U AND p-message <> "0":U)
         THEN DO:
            ASSIGN
               p-ok = FALSE
            .
            RETURN.
         END.

         p-message = v-sb:NFun (INPUT 0) NO-ERROR.
         IF ERROR-STATUS:ERROR
         OR (p-message <> ? AND p-message <> "":U AND p-message <> "0":U)
         THEN DO:
            ASSIGN
               p-ok = FALSE
            .
            RETURN.
         END.

         p-message = v-sb:Clear() NO-ERROR.
         IF ERROR-STATUS:ERROR
         OR (p-message <> ? AND p-message <> "":U AND p-message <> "0":U)
         THEN DO:
            ASSIGN
               p-ok = FALSE
            .
            RETURN.
         END.
         ASSIGN
            p-ok = TRUE
         .
      END.
      OTHERWISE DO:
      END.
   END CASE.
END.  /* do on error */
ELSE DO:
   ASSIGN
      p-ok = TRUE
   .
END.
END PROCEDURE. /* sb-chkcl */
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
*/