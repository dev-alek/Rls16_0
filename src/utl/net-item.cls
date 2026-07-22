/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Класс для работы с визуальными компонентами .Net 

Автор: Сергей Палагин
Дата создания: 21/10/18
Author: Sergey Palagin
Creation date: 21/10/18

*/
 
using Progress.Lang.*.

block-level on error undo, throw.

class utl.net-item inherits System.Object: 
   
   define public property DisplayName as character no-undo 
   get.
   set. 

   define public property Value as character no-undo 
   get.
   set. 

   define public property Desctiption as character no-undo 
   get.
   set. 

   constructor public net-item ():
      
   end constructor.

   constructor public net-item (iDisplayName as char, iValue as char):
      
      assign
         this-object:DisplayName = iDisplayName
         this-object:Value = iValue
      .
     
   end constructor.

   constructor public net-item (iDisplayName as char, iValue as char, iDesc as char):
      
      assign
         this-object:DisplayName = iDisplayName
         this-object:Value = iValue
         this-object:Desctiption = iDesc
      .
     
   end constructor.

end class.