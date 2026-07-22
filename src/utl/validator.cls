/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Класс проверки Entity 

Автор: Сергей Палагин
Дата создания: 21/10/18
Author: Sergey Palagin
Creation date: 21/10/18

*/

using utl.*.

block-level on error undo, throw.

class utl.validator: 

   /*------------------------------------------------------------------------------
    Purpose:
    Notes:
   ------------------------------------------------------------------------------*/

   method public void Validate(iPwd as class tech-prol-pwd ):
      
      if iPwd:f-date = ? then 
         undo, throw new ValidateError("Не заполнена дата").
        
      if iPwd:f-time = ? then 
         undo, throw new ValidateError("Не заполнено время").
            
      if not {utl/assigned iPwd:f-host} then 
         undo, throw new ValidateError("Не заполнен хост").
            
      if not {utl/assigned iPwd:f-user} then 
         undo, throw new ValidateError("Не заполнен пользователь").
        
      if not {utl/assigned iPwd:shop-surr} then 
         undo, throw new ValidateError("Не указан магазин").

      if not {utl/assigned iPwd:cash-desk-surr} then 
         undo, throw new ValidateError("Не указана касса").
      
      if not can-do("И,Р",iPwd:f-pwd-type) then
         undo, throw new ValidateError(substitute("Неправильный тип пароля - []",iPwd:f-pwd-type)).
      
         
      return.

   end method.

end class.