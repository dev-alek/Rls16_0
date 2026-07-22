
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Структура данных transport_section в 1С

Автор: Александр Ростовцев
Дата создания: 26/04/2024
Author: Aleksandr Rostovtsev
Creation date: 26/04/2024

*/

using Progress.Lang.*.
using ibs.th.bge.1crn.subjects.subjects from propath.
using ibs.th.bge.1crn.subjects.tank-imp_cal-tbl from propath.
block-level on error undo, throw.

class ibs.th.bge.1crn.subjects.tank-imp_belt-tbl inherits ibs.th.bge.1crn.subjects.asubject:
  define override public property vss-revision    as character no-undo init "$Revision:$":U get .
  define override public property vss-author      as character no-undo init "$Author:$":U get.
  define override public property vss-date        as character no-undo init "$Date:$":U get.
  define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
  define override public property vss-archive     as character no-undo init "$Archive:$":U get.
  
   define property num-belt as int64 no-undo get. 
      private set.
   define property low-lvl as int64 no-undo get. 
      private set.
   define property up-lvl as int64 no-undo get. 
      private set.
   define property tbl-lvl as int64 no-undo get. 
      private set.
   define property belt-capacity as decimal no-undo get. 
      private set.
    
   define override property InitTag as character no-undo init "belt-tbl-line"
      get. 
    
   method override protected void SetPropProtected (inTag as char, inValue as char):
      case inTag:
         when "num-belt" then 
            do:
               assign 
                  num-belt = int64(inValue) .
            end.
         when "low-lvl" then 
            do:
               assign 
                  low-lvl = int64(inValue) .
            end.
         when "up-lvl" then 
            do:
               assign 
                  up-lvl = int64(inValue) .
            end.
         when "tbl-lvl" then 
            do:
               assign 
                  tbl-lvl = int64(inValue) .
            end.
         when "belt-capacity" then 
            do:
               assign 
                  belt-capacity = decimal(inValue) .
            end.
      end case.
   end.

 
   method override protected void CheckData ():

      def var v-str as char no-undo.
    
      assign
         v-str = v-str + ",num-belt" 
         when num-belt = ?
         v-str = v-str + ",low-lvl" 
         when low-lvl = ?
         v-str = v-str + ",up-lvl"
         when up-lvl = ?
         v-str = v-str + ",tbl-lvl"
         when tbl-lvl = ?
         v-str = v-str + ",belt-capacity"
         when belt-capacity = ?
         .
      v-str = trim (v-str, ",").
      if v-str > ''
         then 
         undo, throw new Progress.Lang.AppError( substitute ("Теги &1 не могут иметь неопределное значение", v-str)).

   end.
  
   method override protected void ClearSub():
      assign 
         num-belt      = ?
         low-lvl       = ?
         up-lvl        = ?
         tbl-lvl       = ?
         belt-capacity = ?
         .
   end.

end class.