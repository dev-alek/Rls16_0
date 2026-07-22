/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Структура данных gds накладной из 1С ERPRN

Автор: Александр Морозов
Дата создания: 26/09/17
Author: Morozov Alexandr
Creation date: 26/09/17

*/

using Progress.Lang.*.
block-level on error undo, throw.


class ibs.th.bge.1crn.subjects.trn-gd-fuel inherits ibs.th.bge.1crn.subjects.asubject: 
  define override public property vss-revision    as character no-undo init "$Revision:$":U get .
  define override public property vss-author      as character no-undo init "$Author:$":U get.
  define override public property vss-date        as character no-undo init "$Date:$":U get.
  define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
  define override public property vss-archive     as character no-undo init "$Archive:$":U get.
  
  define property line-num as character no-undo
    get. 
    private set.
  define property gd-code as integer no-undo 
    get. 
    private set.
  define property cap-ttn as decimal no-undo 
    get. 
    private set.
  define property wght-ttn as decimal no-undo 
    get. 
    private set.
  define property dnsty-ttn as decimal no-undo 
    get. 
    private set.
  define property sum as decimal no-undo 
    get. 
    private set.
  define property cap-fact as decimal no-undo 
    get. 
    private set.

  define property wght-fact as decimal no-undo 
    get. 
    private set.

  define property dnsty-fact as decimal no-undo 
    get. 
    private set.
    
  define override property InitTag as character no-undo init "gd"
    get. 
    
  method override protected void SetPropProtected (inTag as char, inValue as char):
    case inTag:
      when "line-num" then do:
        assign line-num = inValue.
      end.
      when "gd-code" then do:
        assign gd-code = integer (inValue).
      end.
      when "cap-ttn" then do:
        assign cap-ttn = decimal (inValue).
      end.
      when "wght-ttn" then do:
        assign wght-ttn = decimal (inValue) .
      end.
      when "dnsty-ttn" then do:
        assign dnsty-ttn = decimal (inValue).
      end.
      when "cap-fact" then do:
        assign cap-fact = decimal (inValue).
      end.
      when "wght-fact" then do:
        assign wght-fact = decimal (inValue).
      end.
      when "dnsty-fact" then do:
        assign dnsty-fact = decimal (inValue).
      end.
      when "sum" then do:
        assign sum = decimal (inValue).
      end.
    end case.
  end.

  method override protected void CheckData ():

    def var v-str as char no-undo.
    
    assign
      /* v-str = "line-num" when line-num = ? */
      v-str = v-str + ",gd-code" when gd-code = ?
      /* v-str = v-str + ",cap-fact" when cap-fact = ? */
      /* v-str = v-str + ",wght-fact" when wght-fact = ? */
      /* v-str = v-str + ",sum" when sum = ? */
    .
    v-str = trim (v-str, ",").
    if v-str > ''
    then 
      undo, throw new Progress.Lang.AppError( substitute ("Теги &1 не могут иметь неопределное значение", v-str)).

  end.
  
  method override protected void ClearSub():
    assign 
      line-num  = ?
      gd-code   = ?
      cap-ttn   = ?
      wght-ttn  = ?
      dnsty-ttn = ?
      cap-fact  = ?
      wght-fact = ?
      dnsty-fact = ?
      sum = ?  
    .
  end.

  
end class.