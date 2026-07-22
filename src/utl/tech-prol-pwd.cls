/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Entity для таблицы tesh-prol-pwd 

Автор: Сергей Палагин
Дата создания: 21/10/18
Author: Sergey Palagin
Creation date: 21/10/18

*/
 
using Progress.Lang.*.
using Utl.*.

block-level on error undo, throw.

/* ORM отражение записи в таблице tech-prol-pwd */
class utl.tech-prol-pwd:

   define public property id as int64 no-undo 
      get.
      set. 

    
   define public property f-date as date no-undo 
      get.
      set. 

   define public property f-time as datetime no-undo 
      get.
      set. 

   define public property f-user as character no-undo 
      get.
      set. 

   define public property f-host as character no-undo 
      get.
      set. 

  define public property region-surr as character no-undo 
      get.
      set. 

   define public property shop-surr as character no-undo 
      get.
      set. 

   define public property cash-desk-surr as character no-undo 
      get.
      set. 

   define public property f-pwd-type as character no-undo 
      get.
      set. 

   define public property f-pwd as character no-undo 
      get.
      set. 

   define public property f-fio as character no-undo 
      get.
      set. 

   define public property f-beg-time as character no-undo 
      get.
      set.
       
   define public property f-end-time as character no-undo 
      get.
      set. 
   
end class.