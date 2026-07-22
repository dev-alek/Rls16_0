/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Исключение для проверки локировки 

Автор: Сергей Палагин
Дата создания: 21/10/18
Author: Sergey Palagin
Creation date: 21/10/18

*/

USING Progress.Lang.*.
USING Progress.Lang.AppError.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS utl.LockedError INHERITS AppError: 
    /* Для отлова ситуаций с залоченными другим пользователем записями */
    
   CONSTRUCTOR PUBLIC lockederror (  ):
      SUPER ().
      
   END CONSTRUCTOR.

   CONSTRUCTOR PUBLIC lockederror (INPUT ReturnValue AS CHARACTER):
      SUPER (ReturnValue).
      
   END CONSTRUCTOR.
   
   CONSTRUCTOR PUBLIC lockederror (
      INPUT ErrorMessage   AS CHARACTER, 
      INPUT MessageNumber AS INTEGER):
      SUPER (ErrorMessage,MessageNumber).
      
   END CONSTRUCTOR.

END CLASS.