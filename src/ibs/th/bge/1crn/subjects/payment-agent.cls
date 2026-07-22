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
 

class ibs.th.bge.1crn.subjects.payment-agent inherits ibs.th.bge.1crn.subjects.asubject:
  define override public property vss-revision    as character no-undo init "$Revision:$":U get .
  define override public property vss-author      as character no-undo init "$Author:$":U get.
  define override public property vss-date        as character no-undo init "$Date:$":U get.
  define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
  define override public property vss-archive     as character no-undo init "$Archive:$":U get.
  
  define property code_         as character    no-undo get. private set.
  define property name_         as character    no-undo get. private set.
  
  define property adr-trans-op    as character    no-undo get. private set.
  define property inn-trans-op    as character    no-undo get. private set.
  define property name-trans-op   as character    no-undo get. private set.
  define property oper-pa         as character    no-undo get. private set.
  define property sign-pa         as integer      no-undo get. private set.
  define property tel-pa          as character    no-undo get. private set.
  define property tel-acceptor    as character    no-undo get. private set.
  define property tel-trans-op    as character    no-undo get. private set.
  define property sign-pa-subj    as integer      no-undo get. private set.
  define property name-prov       as character    no-undo get. private set.
  define property inn-prov        as character    no-undo get. private set.
  define property tel-prov        as character    no-undo get. private set.
  define property type-calc-repl  as integer      no-undo get. private set.
  define property min-sum         as decimal      no-undo get. private set.
  define property max-sum         as decimal      no-undo get. private set.
  define property warning-sum     as decimal      no-undo get. private set.
  define property comm-entry-type as integer      no-undo get. private set.
  define property value-comm      as decimal      no-undo get. private set.
  define property gds-comm        as integer      no-undo get. private set.
/*  define property pct-comm        as decimal      no-undo get. private set. 29/III-2019 - пропало из ТР */
/*  define property sum-comm        as decimal      no-undo get. private set. 29/III-2019 - пропало из ТР */
  define property auth-req        as integer      no-undo get. private set.
/*  define property code-req        as integer      no-undo get. private set. 29/III-2019 - пропало из ТР */
  define property prt-slp-req     as integer      no-undo get. private set.
  define property name-slp        as character    no-undo get. private set.
  define property max-num         as integer      no-undo get. private set.
  define property min-num         as integer      no-undo get. private set.
  define property oper-type       as integer      no-undo get. private set.

  define property del-l         as integer      no-undo get. private set.
  define property del-f         as integer      no-undo get. private set.


  define property kb-gds            as ibs.th.bge.1crn.subjects.subjects no-undo
    get. 
    private set.

  define override property InitTag as character no-undo init "payment-agent"
    get.
  
  constructor public payment-agent ():
    InitListTag = "kb-gds".
  end constructor.
  
  &scoped-define attr-str      if inValue >= "" then inValue else ""
  &scoped-define attr-integer  if inValue >= "" then integer (inValue) else 0
  &scoped-define attr-dec      if inValue >= "" then decimal (inValue) else 0.0
  &scoped-define attr-date     if inValue >= "" then date-mth (inValue) else ?
  method override protected void SetPropProtected (inTag as char, inValue as char):
    case inTag:
      when "code"         then code_        = {&attr-str} .
      when "del-l"        then del-l        = {&attr-integer} .
      when "del-f"        then del-f        = {&attr-integer} .
      when "name"         then name_        = {&attr-str} .
      when "adr-trans-op"    then adr-trans-op    = {&attr-str} .
      when "inn-trans-op"    then inn-trans-op    = {&attr-str} .
      when "name-trans-op"   then name-trans-op   = {&attr-str} .
      when "oper-pa"         then oper-pa         = {&attr-str} .
      when "sign-pa"         then sign-pa         = {&attr-integer} .
      when "tel-pa"          then tel-pa          = {&attr-str} .
      when "tel-acceptor"    then tel-acceptor    = {&attr-str} .
      when "tel-trans-op"    then tel-trans-op    = {&attr-str} .
      when "sign-pa-subj"    then sign-pa-subj    = {&attr-integer} .
      when "name-prov"       then name-prov       = {&attr-str} .
      when "inn-prov"        then inn-prov        = {&attr-str} .
      when "tel-prov"        then tel-prov        = {&attr-str} .
      when "type-calc-repl"  then type-calc-repl  = {&attr-integer} .
      when "min-sum"         then min-sum         = {&attr-dec} .
      when "max-sum"         then max-sum         = {&attr-dec} .
      when "warning-sum"     then warning-sum     = {&attr-dec} .
      when "comm-entry-type" then comm-entry-type = {&attr-integer} .
      when "value-comm"      then value-comm      = {&attr-dec} .
      when "gds-comm"        then gds-comm        = {&attr-integer} .
      when "auth-req"        then auth-req        = {&attr-integer} .
      when "prt-slp-req"     then prt-slp-req     = {&attr-integer} .
      when "name-slp"        then name-slp        = {&attr-str} .
      when "max-num"         then max-num         = {&attr-integer} .
      when "min-num"         then min-num         = {&attr-integer} .
      when "oper-type"       then oper-type       = {&attr-integer} .
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
      when "kb-gds"   then kb-gds   = SubsObj.            
    end case.
  end method.

  method override protected void CheckData ():
    def var v-str as char no-undo.
    
    assign
      v-str =         ",code"           when code_          = ?
      v-str = v-str + ",name"           when name_          = ?
      v-str = v-str + ",adr-trans-op"   when adr-trans-op   = ? and type-calc-repl ne 1
      v-str = v-str + ",inn-trans-op"   when inn-trans-op   = ? and type-calc-repl ne 1
      v-str = v-str + ",name-trans-op"  when name-trans-op  = ? and type-calc-repl ne 1
      v-str = v-str + ",oper-pa"        when oper-pa        = ? and type-calc-repl ne 1
      v-str = v-str + ",sign-pa"        when sign-pa        = ?
      v-str = v-str + ",sign-pa-subj"   when sign-pa-subj   = ?
      v-str = v-str + ",type-calc-repl" when type-calc-repl = ?
      v-str = v-str + ",max-sum"        when max-sum        = ?
    .
    v-str = substring(v-str, 2).
    if v-str > "" then undo, throw new Progress.Lang.AppError(
      substitute("Теги [&1] отсутствуют в сообщении [&2]", v-str, InitTag)
    ) .
  end method.
  
  method override protected void ClearSub():
    assign
      code_           = ?
      del-l = ?
      del-f = ?
      name_           = ?
      adr-trans-op    = ?
      inn-trans-op    = ?
      name-trans-op   = ?
      oper-pa         = ?
      sign-pa         = ?
      tel-pa          = ?
      tel-acceptor    = ?
      tel-trans-op    = ?
      sign-pa-subj    = ?
      name-prov       = ?
      inn-prov        = ?
      tel-prov        = ?
      type-calc-repl  = ?
      min-sum         = ?
      max-sum         = ?
      warning-sum     = ?
      comm-entry-type = ?
      value-comm      = ?
      gds-comm        = ?
      auth-req        = ?
      prt-slp-req     = ?
      name-slp        = ?
      max-num         = ?
      min-num         = ?
      oper-type       = ?
    .
    if valid-object(kb-gds)        then delete object kb-gds .
  end method.
      
end class.