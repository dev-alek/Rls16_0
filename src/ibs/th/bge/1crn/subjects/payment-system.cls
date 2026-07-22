/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

kass-book:payment-agent - Секция с параметрами платежного агента из 1С
c 21/V-2019 самостоятельная сущность Платежные агента/Банковские платежные агенты

Автор: Молотков Сергей
Дата создания: 13/02/19
Author: Molotkov Sergey
Creation date: 13/02/19

*/
block-level on error undo, throw.
 

class ibs.th.bge.1crn.subjects.payment-system inherits ibs.th.bge.1crn.subjects.asubject:
  define override public property vss-revision    as character no-undo init "$Revision:$":U get .
  define override public property vss-author      as character no-undo init "$Author:$":U get.
  define override public property vss-date        as character no-undo init "$Date:$":U get.
  define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
  define override public property vss-archive     as character no-undo init "$Archive:$":U get.
  
  define property code_         as character    no-undo get. private set.
  define property name_         as character    no-undo get. private set.
  define property del-l         as integer      no-undo get. private set.
  define property del-f         as integer      no-undo get. private set.
  
  define public property validateCodeOnly as logical      no-undo get. set.
  
  define property bin-ranges            as ibs.th.bge.1crn.subjects.subjects no-undo
    get. 
    private set.

  define property bins-tokens            as ibs.th.bge.1crn.subjects.subjects no-undo
    get. 
    private set.
 
  define override property InitTag as character no-undo init "payment-system"
    get.
  
  constructor public payment-system ():
    InitListTag = "bin-ranges,bins-tokens".
  end constructor.
  
  &scoped-define attr-str      if inValue >= "" then inValue else ""
  &scoped-define attr-integer  if inValue >= "" then integer (inValue) else 0
  &scoped-define attr-dec      if inValue >= "" then decimal (inValue) else 0.0
  &scoped-define attr-date     if inValue >= "" then date-mth (inValue) else ?
  method override protected void SetPropProtected (inTag as char, inValue as char):
    case inTag:
      when "code"         then code_        = {&attr-str} .
      when "name"         then name_        = {&attr-str} .
      when "del-l"        then del-l        = {&attr-integer} .
      when "del-f"        then del-f        = {&attr-integer} .
      
      
    end case.
    catch exProErrors as class Progress.Lang.ProError :
      case exProErrors:GetMessageNum(1):
        when 18207 then undo, throw new Progress.Lang.AppError(
          substitute("Поле <&1> содержит ошибочное значение [&2]", inTag, inValue)
        ) .
        otherwise undo, throw new Progress.Lang.AppError(
          substitute("Ошибка значения для поля <&1>: &2", inTag, exProErrors:GetMessage(1))
        ) .
      end case .
    end catch .
  end method.

  method override protected void SetPropProtected (SubsObj as ibs.th.bge.1crn.subjects.subjects):
    /* вызывается для переприсваивания коллекции после каждого добавления элемента в коллекцию;
       указатель на объект коллекции приходит с одним и тем же значением */
    case SubsObj:InitTag:
      when "bin-ranges"   then bin-ranges   = SubsObj.
      when "bins-tokens"  then bins-tokens  = subsObj.
                  
    end case.
  end method.

  method override protected void CheckData ():
    def var v-str as char no-undo.
    
    assign
      v-str =         ",code"           when code_          = ?
      v-str = v-str + ",name"           when name_          = ? and not validateCodeOnly
      
    .
    v-str = substring(v-str, 2).
    if v-str > "" then undo, throw new Progress.Lang.AppError(
      substitute("Теги [&1] отсутствуют в сообщении [&2]", v-str, InitTag)
    ) .
  end method.
  
  method override protected void ClearSub():
    assign
      code_           = ?
      name_           = ?
      del-l = ?
      del-f = ?
      validateCodeOnly = no
      
      
    .
    if valid-object(bin-ranges)        then delete object bin-ranges .
  end method.
      
end class.