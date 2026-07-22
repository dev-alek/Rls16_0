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
 

class ibs.th.bge.1crn.subjects.edi-doc inherits ibs.th.bge.1crn.subjects.asubject:
  define override public property vss-revision    as character no-undo init "$Revision:$":U get .
  define override public property vss-author      as character no-undo init "$Author:$":U get.
  define override public property vss-date        as character no-undo init "$Date:$":U get.
  define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
  define override public property vss-archive     as character no-undo init "$Archive:$":U get.
  
  define property edoc-id         as character    no-undo get. private set.
  
  define property edoc-num        as character    no-undo get. private set.
  define property edoc-date       as date         no-undo get. private set.
  define property edoc-type       as character    no-undo get. private set.
  define property edoc-stts       as character    no-undo get. private set.
  define property contr-code      as character    no-undo get. private set.
  define property dog-code        as integer      no-undo get. private set.
  define property orig-edoc-id    as character    no-undo get. private set.
  define property sum             as decimal      no-undo get. private set.
  define property sum-nonds       as decimal      no-undo get. private set.
  define property order-item      as character    no-undo get. private set.
 
  define property comment         as character    no-undo get. private set.

  define property del-l         as integer      no-undo get. private set.
  define property del-f         as integer      no-undo get. private set.

  define property obj-load        as character    no-undo get. 
  set(arg as char):
     obj-load = arg.
     this-object:InitTag = arg.
  end.
  define property gds            as ibs.th.bge.1crn.subjects.subjects no-undo
    get. 
    private set.

  

  define override property InitTag as character no-undo init "edi-doc"
      get.
      private set.
  
  constructor public edi-doc ():
    InitListTag = "gds".
  end constructor.

  method private date date-mth (inValue as character):
    
    inValue = entry (1, inValue, "T").
    return date (integer (entry (2, Invalue, "-")), integer (entry (3, Invalue, "-")), integer (entry (1, Invalue, "-")) ). 
    
  end.
  &scoped-define attr-str      if inValue >= "" then inValue else ""
  &scoped-define attr-integer  if inValue >= "" then integer (inValue) else 0
  &scoped-define attr-dec      if inValue >= "" then decimal (inValue) else 0.0
  &scoped-define attr-date     if inValue >= "" then date-mth (inValue) else ?
  method override protected void SetPropProtected (inTag as char, inValue as char):
 
    case inTag:
      when "edoc-id"      then edoc-id         = {&attr-str} .
      when "edoc-num"     then edoc-num         = {&attr-str} .
      when "del-l"        then del-l            = {&attr-integer} .
      when "del-f"        then del-f            = {&attr-integer} .
      when "edoc-date"    then edoc-date        = {&attr-date} .
      when "edoc-type"    then edoc-type        = {&attr-str} .
      when "edoc-stts"    then edoc-stts        = {&attr-str} .
      when "contr-code"   then contr-code       = {&attr-str} .
      when "dog-code"     then dog-code         = {&attr-integer} .
      when "orig-edoc-id" then orig-edoc-id     = {&attr-str} .
      when "comment"      then comment          = {&attr-str} .
      when "sum"          then sum              = {&attr-dec} .
      when "sum-nonds"    then sum-nonds        = {&attr-dec} .
      when "order-item-external" then order-item = {&attr-str} .
      
      
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
      when "gds"     then gds   = SubsObj.
               
    end case.
  end method.

  method override protected void CheckData ():
    def var v-str as char no-undo.
    
    assign
      v-str =         ",edoc-id"            when edoc-id           = ? 
      v-str =         ",edoc-num"           when edoc-num          = ? and obj-load = "edi-doc"
      v-str = v-str + ",edoc-date"          when edoc-date         = ? and obj-load = "edi-doc"
      v-str = v-str + ",edoc-type"          when edoc-type         = ? and obj-load = "edi-doc"
      v-str = v-str + ",edoc-stts"          when edoc-stts         = ? 
      v-str = v-str + ",del-f"              when edoc-stts         = ? and obj-load = "edi-doc"
      
    .
    v-str = substring(v-str, 2).
    if v-str > "" then undo, throw new Progress.Lang.AppError(
      substitute("Теги [&1] отсутствуют в сообщении [&2]", v-str, InitTag)
    ) .
  end method.
  
  method override protected void ClearSub():
    assign
      edoc-id           = ?
      edoc-num           = ?
      del-l              = ?
      del-f              = ?
      edoc-date          = ?
      edoc-type          = ?
      edoc-stts          = ?
      contr-code         = ?
      dog-code           = ?
      orig-edoc-id       = ?
      comment            = ?
      sum                = ?
      sum-nonds          = ?
      order-item         = ?
    .
    if valid-object(gds)          then delete object gds .
    
  end method.
      
end class.