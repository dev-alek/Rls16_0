/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

kass-book:payment-agent - Секция с параметрами платежного агента из 1С
c 21/V-2019 самостоятельная сущность Платежные агента/Банковские платежные агенты

Автор: Рубан Дмитрий
Дата создания: 13/02/19
Author: Ruban Dmitriy
Creation date: 13/02/19

*/
block-level on error undo, throw.
 

class ibs.th.bge.1crn.subjects.oks inherits ibs.th.bge.1crn.subjects.asubject:
  define override public property vss-revision    as character no-undo init "$Revision:$":U get .
  define override public property vss-author      as character no-undo init "$Author:$":U get.
  define override public property vss-date        as character no-undo init "$Date:$":U get.
  define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
  define override public property vss-archive     as character no-undo init "$Archive:$":U get.
    
  define property Code_ok       as character    no-undo get. private set.
  define property Code_ei_kkt   as character    no-undo get. private set.
  define property Code_pf_kkt   as character    no-undo get. private set.
  define property notation      as character    no-undo get. private set.
  
  define property del-l         as integer      no-undo get. private set.
  define property del-f         as integer      no-undo get. private set.

  
  define override property InitTag as character no-undo init "OK"
    get.
  
  constructor public oks ():
  end constructor.

  &scoped-define attr-str      if inValue >= "" then inValue else ""
  &scoped-define attr-integer  if inValue >= "" then integer (inValue) else 0
  &scoped-define attr-dec      if inValue >= "" then decimal (inValue) else 0.0
  &scoped-define attr-date     if inValue >= "" then date-mth (inValue) else ?
  method override protected void SetPropProtected (inTag as char, inValue as char):
    case inTag:
      when "del-l"        then del-l            = {&attr-integer} .
      when "del-f"        then del-f            = {&attr-integer} .
      when "Code_ok"     or when "Code-ok"      then Code_ok          = string({&attr-integer}) .
      when "Code_ei_kkt" or when "Code-ei-kkt"  then Code_ei_kkt      = {&attr-str} .
      when "Code_pf_kkt" or when "Code-pf-kkt"  then Code_pf_kkt      = {&attr-str} .
      when "notation"     then notation         = {&attr-str} .
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
   end method.

  method override protected void CheckData ():
    def var v-str as char no-undo.
    
    assign
      v-str = v-str + ",Code_ok"          when Code_ok         = ? 
      v-str = v-str + ",Code_ei_kkt"      when Code_ei_kkt     = ?
      v-str = v-str + ",Code_pf_kkt"      when Code_pf_kkt     = ?
    .
   
    v-str = substring(v-str, 2).
    if v-str > "" then undo, throw new Progress.Lang.AppError(
      substitute("Теги [&1] отсутствуют в сообщении [&2]", v-str, InitTag)
    ) .
  end method.
  
  method override protected void ClearSub():
    assign
      Code_ok            = ?
      del-l              = ?
      del-f              = ?
      Code_ei_kkt        = ?
      Code_pf_kkt        = ?
      notation           = ?
    .
    
    
  end method.
      
end class.