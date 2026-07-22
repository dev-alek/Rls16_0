/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Структура данных cli-grps (группы контрагентов) из 1С

Автор: Молотков Сергей
Дата создания: 02/10/17
Author: Molotkov Sergey
Creation date: 02/10/17

*/

using Progress.Lang.*.
block-level on error undo, throw.


class ibs.th.bge.1crn.subjects.cli-grps inherits ibs.th.bge.1crn.subjects.asubject: 
  define override public property vss-revision    as character no-undo init "$Revision:$":U get .
  define override public property vss-author      as character no-undo init "$Author:$":U get.
  define override public property vss-date        as character no-undo init "$Date:$":U get.
  define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
  define override public property vss-archive     as character no-undo init "$Archive:$":U get.

  define property code_ as character no-undo
    get. 
    private set.
  define property upper-code as character no-undo
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

  define override property InitTag as character no-undo init "contractor-group"
    get. 

  method override protected void SetPropProtected (inTag as char, inValue as char):
    case inTag:
      when "code"       then code_      = if inValue >= "" then inValue else "" .
      when "upper-code" then upper-code = if inValue >= "" then inValue else "" .
      when "del-l"      then del-l      = if inValue >= "" then integer (inValue) else 0.
      when "del-f"      then del-f      = if inValue >= "" then integer (inValue) else 0.
      when "name"       then name_      = if inValue >= "" then inValue else "" .
    end case.
  end method .
  
  method override protected void CheckData ():

    def var v-str as char no-undo.
    
    assign
      v-str = ",code" when code_ = ?
      v-str = v-str + ",upper-code" when upper-code = ?
      v-str = v-str + ",name" when name_ = ?
    .
    v-str = substring(v-str, 2).
    if v-str > "" then undo, throw new Progress.Lang.AppError(
      substitute("Теги [&1] отсутствуют в сообщении [&2]", v-str, InitTag)
    ) .

  end method.
  
  method override protected void ClearSub():
    assign 
      code_      = ?
      upper-code = ?
      del-l      = ?
      del-f      = ?
      name_      = ?
    .
  end method.
  

end class.