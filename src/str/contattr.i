/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедуры чтения и записи таблицы contract-attr

Автор: Носко Игорь Александрович
Дата создания: 16/05/2011
Author: Nosko Igor
Creation date: 15/05/2011

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

/* Чтобы не мешалось  */
&SCOPED-DEFINE ERROR_UNDO_RETRY  ~
   IF ERROR-STATUS:ERROR THEN    ~
      UNDO Tran, RETRY Tran.     ~   

&SCOPED-DEFINE IF_RETRY_THEN_DO ~
   IF RETRY THEN DO: ~
      cError = "Ошибка транзакции:":U + PROGRAM-NAME(1) + ERROR-STATUS:GET-MESSAGE(1) + " " + RETURN-VALUE. ~
       UNDO Tran, LEAVE Tran. ~
   END. ~

/* Уведомление  */
DEFINE VARIABLE v-gl-UVEDOMLENIE as CHARACTER NO-UNDO INITIAL "Uvedomlenie":U.



/*************
            Прочитать аттрибут Contract-Attr.
*************/
FUNCTION Get-Contract-Attr RETURN CHARACTER(
         INPUT iHost-Code AS INTEGER,
         INPUT iContract-Code  AS INTEGER,
         INPUT cAttr-code      AS CHARACTER):
   DEFINE BUFFER buf_Contract-Attr FOR ub.Contract-Attr.
   FIND FIRST buf_Contract-Attr WHERE
              buf_Contract-Attr.Host-code     = iHost-Code
          AND buf_Contract-Attr.Contract-code = iContract-Code
          AND buf_Contract-Attr.Attr-code     = cAttr-code
        NO-LOCK NO-ERROR.
   RETURN (IF AVAILABLE buf_Contract-Attr THEN buf_Contract-Attr.Attr-value ELSE ?).
END FUNCTION.



/*************
            Модификация атрибутов
*************/
PROCEDURE Modify-Contract-Attr:
   DEFINE INPUT  PARAMETER iHost-Code      AS INTEGER   NO-UNDO.
   DEFINE INPUT  PARAMETER iContract-Code  AS INTEGER   NO-UNDO.
   DEFINE INPUT  PARAMETER cAttr-code      AS CHARACTER NO-UNDO.
   DEFINE INPUT  PARAMETER cAttr-value     AS CHARACTER NO-UNDO.
   DEFINE OUTPUT PARAMETER cError          AS CHARACTER NO-UNDO INITIAL "".
   /*  */
   DEFINE BUFFER buf_Contract-Attr FOR  ub.Contract-Attr.
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
      FIND FIRST buf_Contract-Attr WHERE
                 buf_Contract-Attr.Host-Code      = iHost-Code
             AND buf_Contract-Attr.Contract-Code  = iContract-Code
             AND buf_Contract-Attr.Attr-code      = cAttr-code
           NO-LOCK NO-ERROR.
      IF NOT AVAILABLE buf_Contract-Attr THEN DO:
         CREATE buf_Contract-Attr NO-ERROR.
         {&ERROR_UNDO_RETRY}
      END. ELSE DO:
         FIND CURRENT buf_Contract-Attr EXCLUSIVE-LOCK NO-ERROR.
         {&ERROR_UNDO_RETRY}
      END.
      ASSIGN
         buf_Contract-Attr.Host-Code      = iHost-Code
         buf_Contract-Attr.Contract-Code  = iContract-Code
         buf_Contract-Attr.Attr-code      = cAttr-code
         buf_Contract-Attr.Attr-value     = cAttr-value    
         NO-ERROR.
      {&ERROR_UNDO_RETRY}
      RELEASE buf_Contract-Attr NO-ERROR.
      {&ERROR_UNDO_RETRY}
   END. /* Tran  */
   /*  */
   RETURN.
END PROCEDURE.

/*************
               Процедура сооздания Аттрибутов таблицы Contract
               На входе
                  1) Host-code
                  2) Contract-code
                  2) Attr-code
                  3) Attr-value
               Выход: cError - возможно какая либо ошибка
*************/
PROCEDURE Create-Contract-Attr:
   DEFINE INPUT  PARAMETER iHost-Code      AS INTEGER   NO-UNDO.
   DEFINE INPUT  PARAMETER iContract-Code  AS INTEGER   NO-UNDO.
   DEFINE INPUT  PARAMETER cAttr-code      AS CHARACTER NO-UNDO.
   DEFINE INPUT  PARAMETER cAttr-value     AS CHARACTER NO-UNDO.
   DEFINE OUTPUT PARAMETER cError          AS CHARACTER NO-UNDO INITIAL "".
   /*  */
   DEFINE BUFFER buf_Contract-Attr FOR  ub.Contract-Attr.
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
      CREATE buf_Contract-Attr NO-ERROR.
      {&ERROR_UNDO_RETRY}
      ASSIGN
         buf_Contract-Attr.Host-Code      = iHost-Code
         buf_Contract-Attr.Contract-Code  = iContract-Code
         buf_Contract-Attr.Attr-code      = cAttr-code
         buf_Contract-Attr.Attr-value     = cAttr-value    
         NO-ERROR.
      {&ERROR_UNDO_RETRY}
      RELEASE buf_Contract-Attr NO-ERROR.
      {&ERROR_UNDO_RETRY}
   END. /* Tran  */
   /*  */
   RETURN.
END PROCEDURE.



&UNDEFINE ERROR_UNDO_RETRY
&UNDEFINE IF_RETRY_THEN_DO



/* $Workfile$ e n d */

