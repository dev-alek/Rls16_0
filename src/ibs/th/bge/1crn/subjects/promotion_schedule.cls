/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Структура данных promotion:schedule в 1С

Автор: Молотков Сергей
Дата создания: 13/07/18
Author: Molotkov Sergey
Creation date: 13/07/18

*/
block-level on error undo, throw.
using Progress.Lang.*.
using ibs.th.bge.1crn.subjects.subjects from propath.


class ibs.th.bge.1crn.subjects.promotion_schedule inherits ibs.th.bge.1crn.subjects.asubject: 
  define override public property vss-revision    as character no-undo init "$Revision:$":U get .
  define override public property vss-author      as character no-undo init "$Author:$":U get.
  define override public property vss-date        as character no-undo init "$Date:$":U get.
  define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
  define override public property vss-archive     as character no-undo init "$Archive:$":U get.
  
  define property sch-code as character no-undo get. private set. // строка 1-1 Код расписания внешней системы
  define property sch-name as character no-undo get. private set. // строка 1-1 Название акции
  define property Sch-type as character no-undo get. private set. // строка 1-1 Тип расписания  0 - Простое \1 - детальное
    
  define property schedule-lines as subjects no-undo
    get. 
    private set.
    
  define override property InitTag as character no-undo init "schedule"
    get.
    
  constructor public promotion_schedule ():
    InitListTag = "schedule-lines".
  end constructor.
    
  &scoped-define attr-str      if inValue >= "" then inValue else ""
  &scoped-define attr-integer  if inValue >= "" then integer (inValue) else 0
  &scoped-define attr-dec      if inValue >= "" then decimal (inValue) else 0.0
  &scoped-define attr-date     if inValue >= "" then date-mth (inValue) else ?
  method override protected void SetPropProtected (inTag as char, inValue as char):
    case inTag:
      when "sch-code" then sch-code = {&attr-str} .
      when "sch-name" then sch-name = {&attr-str} .
      when "Sch-type" then Sch-type = {&attr-str} .
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
  
  method override protected void SetPropProtected (SubsObj as subjects):
    case SubsObj:InitTag:
      when "schedule-lines" then schedule-lines = SubsObj.            
    end case.
  end method.
  
  method override protected void CheckData ():
    def var v-str as char no-undo.
    assign
      v-str = ",sch-code" when sch-code = ?
      v-str = v-str + ",sch-name" when sch-name = ?
      v-str = v-str + ",Sch-type" when Sch-type = ?
      v-str = v-str + ",schedule-lines" when not valid-object(schedule-lines)
    .
    v-str = substring(v-str, 2).
    if v-str > "" then undo, throw new Progress.Lang.AppError(
      substitute("Теги [&1] отсутствуют в сообщении [&2]", v-str, InitTag)
    ) .
  end method .
      
  method override protected void ClearSub():
    assign
      sch-code = ?
      sch-name = ?
      Sch-type = ?
    .
    if valid-object(schedule-lines) then delete object schedule-lines .
  end method .   

end class.