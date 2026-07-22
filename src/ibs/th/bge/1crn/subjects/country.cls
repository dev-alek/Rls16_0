/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Структура данных countries из 1С ERPRN

Автор: Александр Морозов
Дата создания: 26/09/17
Author: Morozov Alexandr
Creation date: 26/09/17

*/

using Progress.Lang.*.
block-level on error undo, throw.


class ibs.th.bge.1crn.subjects.country inherits ibs.th.bge.1crn.subjects.asubject: 
  define override public property vss-revision    as character no-undo init "$Revision:$":U get .
  define override public property vss-author      as character no-undo init "$Author:$":U get.
  define override public property vss-date        as character no-undo init "$Date:$":U get.
  define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
  define override public property vss-archive     as character no-undo init "$Archive:$":U get.

  define property code_ as character no-undo
    get. 
    private set.
  define property del-l as integer no-undo 
    get. 
    private set.
  define property del-f as integer no-undo 
    get. 
    private set.
  define property name_ as character no-undo 
    get. 
    private set.
  define property full-name as character no-undo 
    get. 
    private set.
  define property alfa2 as character no-undo 
    get. 
    private set.
  define property alfa3 as character no-undo 
    get. 
    private set.
    
  define override property InitTag as character no-undo init "country"
    get. 
    
  method override protected void SetPropProtected (inTag as char, inValue as char):
    case inTag:
      when "code" then do:
        assign code_ = inValue.
      end.
      when "del-l" then do:
        assign del-l = integer (inValue).
      end.
      when "del-f" then do:
        assign del-f = integer (inValue).
      end.
      when "name" then do:
        assign name_ = inValue .
      end.
      when "full-name" then do:
        assign full-name = inValue .
      end.
      when "alfa2" then do:
        assign alfa2 = inValue .
      end.
      when "alfa3" then do:
        assign alfa3 = inValue .
      end.
    end case.
  end.

  method override protected void CheckData ():

    def var v-str as char no-undo.
    
    assign
      v-str = "code" when code_ = ?
    /*  v-str = v-str + ",name" when name_ = ?
      v-str = v-str + ",full-name" when full-name = ?
      v-str = v-str + ",alfa2" when alfa2 = ?
      v-str = v-str + ",alfa3" when alfa3 = ?*/
    .
    v-str = trim (v-str, ",").
    if v-str > ''
    then 
      undo, throw new Progress.Lang.AppError( substitute ("Теги &1 не могут иметь неопределное значение", v-str)).

  end.
  
  method override protected void ClearSub():
    assign 
      code_     = ?
      del-l     = ?
      del-f     = ?
      name_     = ?
      full-name = ?
      alfa2     = ?
      alfa3     = ? 
    .
  end.

  
end class.