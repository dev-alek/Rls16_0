/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Структура данных trn-gd-doc из 1С ERPRN

Автор: Александр Морозов
Дата создания: 26/09/17
Author: Morozov Alexandr
Creation date: 26/09/17

*/

using Progress.Lang.*.
using ibs.th.bge.1crn.subjects.subjects from propath.
using ibs.th.bge.1crn.subjects.trn-gd-doc from propath.
block-level on error undo, throw.


class ibs.th.bge.1crn.subjects.trn-fuel-doc-in inherits ibs.th.bge.1crn.subjects.asubject: 
  define override public property vss-revision    as character no-undo init "$Revision:$":U get .
  define override public property vss-author      as character no-undo init "$Author:$":U get.
  define override public property vss-date        as character no-undo init "$Date:$":U get.
  define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
  define override public property vss-archive     as character no-undo init "$Archive:$":U get.
  
  define property doc-code as character no-undo
    get. 
    private set.
  define property doc-num as character no-undo 
    get. 
    private set.
  define property del-f as integer no-undo 
    get. 
    private set.
  define property doc-date as date no-undo 
    get. 
    private set.
  define property doc-type as character no-undo 
    get. 
    private set.
  define property shift-date as date no-undo 
    get. 
    private set.
  define property shift-num as integer no-undo 
    get. 
    private set.

  define property ttn-num as character no-undo 
    get. 
    private set.

  define property ttn-date as date no-undo 
    get. 
    private set.

  define property contr-code as character no-undo 
    get. 
    private set.

  define property dog-code as character no-undo 
    get. 
    private set.

  define property fuel-st-code as character no-undo 
    get. 
    private set.

  define property doc-id as character no-undo 
    get. 
    private set.

  define property GDS as subjects no-undo 
    get. 
    private set.
    
  define override property InitTag as character no-undo init "trn-fuel-doc"
    get. 


  constructor public trn-fuel-doc-in ():
    InitListTag = "gds".
  end constructor.
    
  method override protected void SetPropProtected(SubsObj as subjects):

    case SubsObj:InitTag:   
      when "gds" then
        do:
          gds = SubsObj.            
        end.
    end case.

  end.
    
  method override protected void SetPropProtected (inTag as char, inValue as char):
    case inTag:
      when "doc-code" then do:
        assign doc-code = inValue.
      end.
      when "doc-num" then do:
        assign doc-num = inValue.
      end.
      when "del-f" then do:
        assign del-f = integer (inValue).
      end.
      when "doc-date" then do:
        assign doc-date = date-mth (inValue) .
      end.
      when "doc-type" then do:
        assign doc-type = inValue .
      end.
      when "shift-date" then do:
        assign shift-date = date-mth (inValue) .
      end.
      when "shift-num" then do:
        assign shift-num = integer (inValue) .
      end.
      when "ttn-num" then do:
        assign ttn-num = inValue .
      end.
      when "ttn-date" then do:
        assign ttn-date = date-mth (inValue) .
      end.
      when "contr-code" then do:
        assign contr-code = inValue .
      end.
      when "dog-code" then do:
        assign dog-code = inValue .
      end.
      when "fuel-st-code" then do:
        assign fuel-st-code = inValue .
      end.
      when "doc-id" then do:
        assign doc-id = inValue .
      end.
    end case.
  end.

  method override protected void CheckData ():

    def var v-str as char no-undo.
    
    assign
      /* v-str = "doc-code" when doc-code = ? */
      /* v-str = v-str + ",doc-num" when doc-num = ? */
      /* v-str = v-str + ",doc-date" when doc-date = ? */
      v-str = v-str + ",doc-type" when doc-type = ?
      /* v-str = v-str + ",shift-date" when shift-date = ?*/
      /* v-str = v-str + ",shift-num" when shift-num = ?*/
    .
    v-str = trim (v-str, ",").
    if v-str > ''
    then 
      undo, throw new Progress.Lang.AppError( substitute ("Теги &1 не могут иметь неопределное значение", v-str)).

  end.
  
  method override protected void ClearSub():
    assign
      doc-code     = ? 
      doc-num      = ? 
      del-f        = ? 
      doc-date     = ? 
      doc-type     = ? 
      shift-date   = ? 
      shift-num    = ? 
      ttn-num      = ? 
      ttn-date     = ? 
      contr-code   = ? 
      dog-code     = ? 
      fuel-st-code = ? 
    .
    delete object gds no-error.
    
  end.
  
  method private date date-mth (inValue as character):
    
    inValue = entry (1, inValue, "T").
    return date (integer (entry (2, Invalue, "-")), integer (entry (3, Invalue, "-")), integer (entry (1, Invalue, "-")) ). 
    
  end.

  
end class.