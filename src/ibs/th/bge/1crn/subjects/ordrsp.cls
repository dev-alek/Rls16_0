/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Класс ответа по заказами из 1С ERPRN ordrsp

Автор: Ростовцев Александр Михайлович
Дата создания: 07/04/25
Author: Rostovtsev Aleksandr
Creation date: 07/04/25

*/


using Progress.Lang.*.
using ibs.th.bge.1crn.subjects.subjects from propath.
block-level on error undo, throw.


class ibs.th.bge.1crn.subjects.ordrsp inherits ibs.th.bge.1crn.subjects.asubject: 
  define override public property vss-revision    as character no-undo init "$Revision:$":U get .
  define override public property vss-author      as character no-undo init "$Author:$":U get.
  define override public property vss-date        as character no-undo init "$Date:$":U get.
  define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
  define override public property vss-archive     as character no-undo init "$Archive:$":U get.

  define property order-item as character no-undo 
    get. 
    private set.
/*  define property edi-item as character no-undo*/
/*    get.                                       */
/*    private set.                               */
  define property order-date as date no-undo 
    get. 
    private set.
 
  define property order-good as subjects no-undo get. 
    private set.
    
  define override property InitTag as character no-undo init "ordrsp"
    get. 
  
  
  constructor public ordrsp ():
    InitListTag = "order-good".
  end constructor.
  
    
  method override protected void SetPropProtected (inTag as char, inValue as char):
    case inTag:
      when "order-item" then do:
        assign order-item = inValue.
      end.
/*      when "edi-item" then do:    */
/*        assign edi-item = inValue.*/
/*      end.                        */
      when "order-date" then do:
        assign order-date = formatDate(inValue) .
      end.
    end case.
  end.

  method override protected void SetPropProtected(SubsObj as subjects):

      case SubsObj:InitTag:   
         when "order-good" then
           order-good = SubsObj.            
      end case.
  end.
  
  method override protected void CheckData ():

    def var v-str as char no-undo.

    assign
      v-str = "order-item" when order-item = ?
      v-str = v-str + ",order-date" when order-date = ?
/*      v-str = v-str + ",order-good"  when order-good = ?*/
    .
    v-str = trim (v-str, ",").
    if v-str > ''
    then 
      undo, throw new Progress.Lang.AppError( substitute ("Теги &1 не могут иметь неопределное значение", v-str)).

  end.
  
  method override protected void ClearSub():
    assign 
      order-item  = ?
/*      edi-item    = ?*/
      order-date  = ?
      order-good  = ?
    .
  end.
  
  method private datetime formatDateTime (iDateTime as character) :
    define variable vDateTime as datetime no-undo . /* возвратное значение */
    
    if (iDateTime = ? or iDateTime = "") then vDateTime = ? .
    else
       vDateTime =  datetime(iDateTime)
    .
    
    return vDateTime .
  end method .
  
  method private date formatDate (iDate as character) :
    return if (iDate = "" or iDate = "") 
           then ? 
           else date(int(substring(iDate,6,2)),int(substring(iDate,9,2)),int(substring(iDate,1,4))) .
  end method .

  
end class.