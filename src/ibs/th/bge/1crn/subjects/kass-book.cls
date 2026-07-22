/*

$Revision: e01c030e3256, 3600, rls $
$Author: ARostovtsev $
$Date: 2023/12/28 12:56:36 $
$Workfile: kass-book.cls $
$Archive: ibs/th/bge/1crn/subjects/kass-book.cls $

Информация по типам кассовых книг из 1С

Автор: Молотков Сергей
Дата создания: 12/02/19
Author: Molotkov Sergey
Creation date: 12/02/19

*/
block-level on error undo, throw.
 

class ibs.th.bge.1crn.subjects.kass-book inherits ibs.th.bge.1crn.subjects.asubject:
  define override public property vss-revision    as character no-undo init "$Revision:$":U get .
  define override public property vss-author      as character no-undo init "$Author:$":U get.
  define override public property vss-date        as character no-undo init "$Date:$":U get.
  define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
  define override public property vss-archive     as character no-undo init "$Archive:$":U get.
   
  define property code_         as character    no-undo get. 
    private set.
  define property del-l         as integer      no-undo get. 
    private set.
  define property del-f         as integer      no-undo get. 
    private set.
  define property name_         as character    no-undo get. 
    private set.
  
  define property basic-kb      as integer      no-undo get. 
    private set.
  define property rule-reason   as character    no-undo get. 
    private set.
  define property rule-reason-nonop-inc   as character    no-undo get. 
    private set.
  define property rule-reason-prepayment   as character    no-undo get. 
    private set.
  define property Rule-Osn-Rko    as character    no-undo get. 
    private set.
  define property code-payer    as integer      no-undo get. 
    private set.
  define property code-payer-nonop-inc    as integer      no-undo get. 
    private set.
  define property code-payer-prepayment    as integer      no-undo get. 
    private set.
  define property rule-payer    as character    no-undo get. 
    private set.
  define property rule-payer-nonop-inc    as character    no-undo get. 
    private set.
  define property rule-payer-prepayment    as character    no-undo get. 
    private set.
  define property rule-att      as integer      no-undo get. 
    private set.
  define property ind-kass-pko  as integer      no-undo get. 
    private set.
  define property apart-np-tnp  as integer      no-undo get. 
    private set.
  define property kredit        as character    no-undo get. 
    private set.
  define property kredit-nonop-inc        as character    no-undo get. 
    private set.
  define property credit-prepayment        as character    no-undo get. 
    private set.
  define property debit         as character    no-undo get. 
    private set.
  define property Corr-Rko       as character    no-undo get. 
    private set.
  define property post-chief    as character      no-undo get. 
    private set.
  define property fio-chief     as character      no-undo get. 
    private set.
  define property fio-booker    as character      no-undo get. 
    private set.
  define property acc-shift     as integer      no-undo get. 
    private set.
  define property pko-prefix    as character    no-undo get. 
    private set.
  define property rko-prefix    as character    no-undo get. 
    private set.
  define property struct-unit   as integer      no-undo get. 
    private set.
  define property struct-unit-name as character    no-undo get. 
    private set.
  define property struct-unit-type as character    no-undo get. 
    private set.
  define property struct-unit-code as integer      no-undo get. 
    private set.
  define property code-symbol   as integer  no-undo get. 
    private set.
  define property pin   as character  no-undo get. 
    private set.
  define property bank-resive   as character    no-undo get. 
    private set.
  define property bank-deposit   as character    no-undo get. 
    private set.
  define property cont-inkass   as integer   no-undo get. 
    private set.
  define property contr-code-rko   as integer   no-undo get. 
    private set.
  define property Corr-transf       as character    no-undo get.
    private set.
  define property rule-osn-transf       as character    no-undo get.
    private set.
  define property contr-code-transf       as integer    no-undo get.
    private set.
  define property rule-payer-transf       as character    no-undo get.
    private set.
  define property rule-payer-rko          as character     no-undo get.
    private set.
  define property rule-payer-inkass       as character     no-undo get.
    private set.
  define property Corr-inkass       as character    no-undo get.
    private set.
  define property rule-osn-incass       as character    no-undo get.
    private set.
  define property bank-resive-acc      as character    no-undo get.
    private set.
  
  
  
  define property kb-gds            as ibs.th.bge.1crn.subjects.subjects no-undo
    get. 
    private set.
  /* с 21/V-2019 импортируется как отдельная сущность
 define property payment-agent     as ibs.th.bge.1crn.subjects.payment-agent no-undo
   get. 
   private set.
 */
  define override property InitTag as character no-undo init "kass-book"
    get.
  
  constructor public kass-book ():
    InitListTag = "kb-gds".
  end constructor.
  
  &scoped-define attr-str      if inValue >= "" then inValue else ""
  &scoped-define attr-integer  if inValue >= "" then integer (inValue) else 0
  &scoped-define attr-dec      if inValue >= "" then decimal (inValue) else 0.0
  &scoped-define attr-date     if inValue >= "" then date-mth (inValue) else ?
  method override protected void SetPropProtected (inTag as char, inValue as char):
    case inTag:
      when "code"         then 
        code_        = {&attr-str} .
      when "del-l"        then 
        del-l        = {&attr-integer} .
      when "del-f"        then 
        del-f        = {&attr-integer} .
      when "name"         then 
        name_        = {&attr-str} .
      when "basic-kb"         then 
        basic-kb         = {&attr-integer} .
      when "rule-reason"      then 
        rule-reason      = {&attr-str} .
      when "rule-reason-nonop-inc"      then 
        rule-reason-nonop-inc      = {&attr-str} .
      when "rule-reason-prepayment"      then 
        rule-reason-prepayment      = {&attr-str} .
      when "Rule-Osn-Rko"       then 
        Rule-Osn-Rko       = {&attr-str} .
      when "code-payer"       then 
        code-payer       = {&attr-integer} .
      when "code-payer-nonop-inc"       then 
        code-payer-nonop-inc       = {&attr-integer} .
      when "code-payer-prepayment"       then 
        code-payer-prepayment       = {&attr-integer} .
      when "rule-payer"       then 
        rule-payer       = {&attr-str} .
      when "rule-payer-nonop-inc"       then 
        rule-payer-nonop-inc       = {&attr-str} .
      when "rule-payer-prepayment"       then 
        rule-payer-prepayment       = {&attr-str} .
      when "rule-att"         then 
        rule-att         = {&attr-integer} .
      when "ind-kass-pko"     then 
        ind-kass-pko     = {&attr-integer} .
      when "apart-np-tnp"     then 
        apart-np-tnp     = {&attr-integer} .
      when "kredit"           then 
        kredit           = {&attr-str} .
      when "kredit-nonop-inc"           then 
        kredit-nonop-inc           = {&attr-str} .
      when "credit-prepayment"           then 
        credit-prepayment           = {&attr-str} .
      when "debit"            then 
        debit            = {&attr-str} .
      when "Corr-Rko"          then 
        Corr-Rko            = {&attr-str} .
      when "post-chief"       then 
        post-chief       = {&attr-str} .
      when "fio-chief"        then 
        fio-chief        = {&attr-str} .
      when "fio-booker"       then 
        fio-booker       = {&attr-str} .
      when "acc-shift"        then 
        acc-shift        = {&attr-integer} .
      when "pko-prefix"       then 
        pko-prefix       = {&attr-str} .
      when "rko-prefix"       then 
        rko-prefix       = {&attr-str} .
      when "struct-unit"      then 
        struct-unit      = {&attr-integer} .
      when "struct-unit-name" then 
        struct-unit-name = {&attr-str} .
      when "struct-unit-type" then 
        struct-unit-type = {&attr-str} .
      when "struct-unit-code" then 
        struct-unit-code = {&attr-integer} .
      when "code-symbol" then 
        code-symbol = {&attr-integer} .
      when "pin" then 
        pin = {&attr-str} .
      when "bank-resive" then 
        bank-resive = {&attr-str} .
      when "bank-deposit" then 
        bank-deposit = {&attr-str} .
      when "cont-inkass" then 
        cont-inkass = {&attr-integer} .
      when "contr-code-rko" then 
        contr-code-rko = {&attr-integer} .
      when "Corr-transf" then 
        Corr-transf = {&attr-str} .
      when "rule-osn-transf" then 
        rule-osn-transf = {&attr-str} .
      when "contr-code-transf" then 
        contr-code-transf = {&attr-integer} .
      when "rule-payer-transf" then 
        rule-payer-transf = {&attr-str} .
      when "rule-payer-rko" then 
        rule-payer-rko = {&attr-str} .
      when "rule-payer-inkass" then 
        rule-payer-inkass = {&attr-str} .
      when "bank-resive-acc" then 
        bank-resive-acc = {&attr-str} .
      when "rule-osn-incass" then 
        rule-osn-incass = {&attr-str} .
      when "Corr-inkass" then 
        Corr-inkass = {&attr-str} .
        
    end case.
    catch exProErrors as class Progress.Lang.ProError :
      case exProErrors:GetMessageNum(1):
        when 18207 then 
          undo, throw new Progress.Lang.AppError(
            substitute("Поле <&1> содержит ошибочное значение [&2]", inTag, inValue)
            ) .
        otherwise 
        undo, throw new Progress.Lang.AppError(
          substitute("Ошибка значения для поля <&1>: &2", inTag, exProErrors:GetMessage(1))
          ) .
      end case .
    end catch .
  end method.

  /* с 21/V-2019 импортируется как отдельная сущность
  method override protected void SetPropProtected (SubObj as ibs.th.bge.1crn.subjects.isubject):
    case SubObj:InitTag:
      when "payment-agent" then
        payment-agent = cast (SubObj, ibs.th.bge.1crn.subjects.payment-agent) .
    end case .    
  end method.
  */
  
  method override protected void SetPropProtected (SubsObj as ibs.th.bge.1crn.subjects.subjects):
    /* вызывается для переприсваивания коллекции после каждого добавления элемента в коллекцию;
       указатель на объект коллекции приходит с одним и тем же значением */
    case SubsObj:InitTag:
      when "kb-gds"   then 
        kb-gds   = SubsObj.            
    end case.
  end method.

  method override protected void CheckData ():
    def var v-str as char no-undo.
    
    assign
      v-str = ",code" 
      when code_ = ? /* Условно-обязательное поле. Добавлено в ТР вер.2.5 от 07/III-2019 */
      v-str = v-str + ",name" 
      when name_ = ?
      .
    v-str = substring(v-str, 2).
    if v-str > "" then undo, throw new Progress.Lang.AppError(
        substitute("Теги [&1] отсутствуют в сообщении [&2]", v-str, InitTag)
        ) .
  end method.
  
  method override protected void ClearSub():
    assign
      code_                 = ?
      del-l                 = ?
      del-f                 = ?
      name_                 = ?
      basic-kb              = ?
      rule-reason           = "Не заполнять"
      rule-reason-nonop-inc = "Не заполнять"
      rule-reason-prepayment = "Не заполнять"
      code-payer            = ?
      code-payer-nonop-inc  = ?
      code-payer-prepayment = ?
      rule-payer            = ?
      rule-payer-nonop-inc  = ?
      rule-payer-prepayment = ?
      rule-att              = ?
      ind-kass-pko          = ?
      apart-np-tnp          = ?
      kredit                = ?
      kredit-nonop-inc      = ?
      credit-prepayment     = ?
      debit                 = ?
      post-chief            = ?
      fio-chief             = ?
      fio-booker            = ?
      acc-shift             = ?
      pko-prefix            = ?
      rko-prefix            = ?
      struct-unit           = ?
      struct-unit-name      = ?
      struct-unit-type      = ?
      struct-unit-code      = ?
      Rule-Osn-Rko          = ?
      Corr-Rko              = ?
      code-symbol           = ?
      pin                   = ?
      bank-resive           = ?
      bank-deposit          = ?
      cont-inkass           = ?
      contr-code-rko        = ?
      Corr-transf           = ?
      rule-osn-transf       = ?
      contr-code-transf     = ?
      rule-payer-transf     = ?
      rule-payer-rko        = ?
      rule-payer-inkass     = ?
      bank-resive-acc       = ?
      rule-osn-incass       = ?
      Corr-inkass           = ?
      .
    if valid-object(kb-gds)        then delete object kb-gds .
  end method.
      
end class.