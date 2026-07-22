
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Структура данных FuelCodeInfo в 1С

Автор: Елена Шкляр
Дата создания: 26/09/17
Author: Shklyar Elena
Creation date: 26/09/17

*/

using Progress.Lang.*.
block-level on error undo, throw.


class ibs.th.bge.1crn.subjects.fuelcodeinfo inherits ibs.th.bge.1crn.subjects.asubject:
  define override public property vss-revision    as character no-undo init "$Revision:$":U get .
  define override public property vss-author      as character no-undo init "$Author:$":U get.
  define override public property vss-date        as character no-undo init "$Date:$":U get.
  define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
  define override public property vss-archive     as character no-undo init "$Archive:$":U get.
   
   define property ExtCode  as character    no-undo get. 
      private set.
   define property del-l as integer no-undo 
      get. 
      private set.
   define property del-f as integer no-undo 
      get. 
      private set.
   define property ExtId    as integer    no-undo get. 
      private set.
   define property ExtName  as character    no-undo get.
      private set.
   define property IntCode  as character    no-undo get.
      private set.

   define override property InitTag as character no-undo init "FuelCodeInfo"
      get. 
    
   method OVERRIDE PROTECTED void SetPropProtected (inTag as char, inValue as char):
      case inTag:
         when "ExtCode" then 
            do:
               assign 
                  ExtCode = inValue .
            end.
         when "del-l"     then 
            del-l     = if inValue >= "" then integer (inValue) else 0 .
         when "del-f"     then 
            del-f     = if inValue >= "" then integer (inValue) else 0 .
         when "ExtId" then 
            do:
               assign 
                  ExtId = integer (inValue) .
            end.
         when "ExtName" then
            do:
               assign
                  ExtName = inValue .
            end.
         when "IntCode" then
            do:
               assign
                  IntCode = inValue .
            end.
      end case.
   end.

   method override protected void CheckData ():

      def var v-str as char no-undo.
    
      assign
         v-str = "ExtCode" 
         when ExtCode = ?
         v-str = v-str + ",IntCode"
         when IntCode = ?
         .
      v-str = trim (v-str, ",").
      if v-str > ''
         then 
         undo, throw new Progress.Lang.AppError( substitute ("Теги &1 не могут иметь неопределное значение", v-str)).

   end.

   method override protected void ClearSub():
      assign 
         ExtCode = ?
         del-l   = ?
         del-f   = ?
         ExtId   = ?
         ExtName = ?
         IntCode = ?
         .
   end.
  
end class.