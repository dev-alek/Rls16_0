/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Структура данных good:unit-add-codes:unit-add-code в 1С

Автор: Молотков Сергей
Дата создания: 21/09/18
Author: Molotkov Sergey
Creation date: 21/09/18

*/
block-level on error undo, throw.

using Progress.Lang.*.


class ibs.th.bge.1crn.subjects.unit-add-code inherits ibs.th.bge.1crn.subjects.asubject:
  define override public property vss-revision    as character no-undo init "$Revision:$":U get .
  define override public property vss-author      as character no-undo init "$Author:$":U get.
  define override public property vss-date        as character no-undo init "$Date:$":U get.
  define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
  define override public property vss-archive     as character no-undo init "$Archive:$":U get.
   
  define property unit-code as character  no-undo get. private set. // 1-1 код дополнительной ЕИ соответствует units.unit-name
  define property unit-k    as decimal    no-undo get. private set. // 1-1 коэффициент пересчёта к базовой ЕИ товара
  
  define override property InitTag as character no-undo init "unit-add-code"
    get.
    
  &scoped-define attr-str      if inValue >= "" then inValue else ""
  &scoped-define attr-integer  if inValue >= "" then integer (inValue) else 0
  &scoped-define attr-dec      if inValue >= "" then decimal (inValue) else 0.0
  &scoped-define attr-date     if inValue >= "" then date-mth (inValue) else ?
  method override protected void SetPropProtected (inTag as char, inValue as char):
    case inTag:
      when "unit-code" then unit-code = {&attr-str} .
      when "unit-k"    then unit-k    = {&attr-dec} .
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
  
  method override protected void CheckData ():
    def var v-str as char no-undo.
    assign
      v-str = ",unit-code" when unit-code = ?
      v-str = v-str + ",unit-k" when unit-k = ?
    .
    v-str = substring(v-str, 2).
    if v-str > "" then undo, throw new Progress.Lang.AppError(
      substitute("Теги [&1] отсутствуют в сообщении [&2]", v-str, InitTag)
    ) .
  end method .
      
  method override protected void ClearSub():
    assign
      unit-code = ?
      unit-k    = ?
    .
  end method .   

end class.
