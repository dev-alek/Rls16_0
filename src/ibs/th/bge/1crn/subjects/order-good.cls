/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Класс строки заказа из 1С ERPRN order

Автор: Ростовцев Александр Михайлович
Дата создания: 07/04/25
Author: Rostovtsev Aleksandr
Creation date: 07/04/25

*/


using Progress.Lang.*.
block-level on error undo, throw.


class ibs.th.bge.1crn.subjects.order-good inherits ibs.th.bge.1crn.subjects.asubject: 
  define override public property vss-revision    as character no-undo init "$Revision:$":U get .
  define override public property vss-author      as character no-undo init "$Author:$":U get.
  define override public property vss-date        as character no-undo init "$Date:$":U get.
  define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
  define override public property vss-archive     as character no-undo init "$Archive:$":U get.

  define property gd-code   as integer no-undo 
    get. 
    private set.
  define property amount    as integer no-undo 
    get. 
    private set.
/*  define property unit-code as character no-undo*/
/*    get.                                        */
/*    private set.                                */
    
  define override property InitTag as character no-undo init "order-good"
    get. 
    
  method override protected void SetPropProtected (inTag as char, inValue as char):
    case inTag:
      when "gd-code" then
        gd-code = integer(inValue).
      when "amount" then
        amount  = integer(inValue) .
/*      when "unit-code" then  */
/*        unit-code = inValue .*/
    end case.
  end.

  method override protected void CheckData ():

    def var v-str as char no-undo.
    
    assign
      v-str = "gd-code" when gd-code = ?
      v-str = v-str + ",amount" when amount = ?
/*      v-str = v-str + ",unit-code" when unit-code = ?*/
    .
    v-str = trim (v-str, ",").
    if v-str > ''
    then 
      undo, throw new Progress.Lang.AppError( substitute ("Теги &1 не могут иметь неопределенное значение", v-str)).

  end.
  
  method override protected void ClearSub():
    assign 
      gd-code   = ?
      amount    = ?
/*      unit-code = ?*/
    .
  end.
  
end class.