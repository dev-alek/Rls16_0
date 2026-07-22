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
  define override property InitTag as character no-undo init "kass-book"
    get.
  constructor public kass-book ():
    InitListTag = "kb-gds".
  end constructor.
          method override protected void SetPropProtected (inTag as char, inValue as char):
    case inTag:
      when "code"         then
        code_        = if inValue >= "" then inValue else "" .
      when "del-l"        then
        del-l        = if inValue >= "" then integer (inValue) else 0 .
      when "del-f"        then
        del-f        = if inValue >= "" then integer (inValue) else 0 .
      when "name"         then
        name_        = if inValue >= "" then inValue else "" .
      when "basic-kb"         then
        basic-kb         = if inValue >= "" then integer (inValue) else 0 .
      when "rule-reason"      then
        rule-reason      = if inValue >= "" then inValue else "" .
      when "rule-reason-nonop-inc"      then
        rule-reason-nonop-inc      = if inValue >= "" then inValue else "" .
      when "rule-reason-prepayment"      then
        rule-reason-prepayment      = if inValue >= "" then inValue else "" .
      when "Rule-Osn-Rko"       then
        Rule-Osn-Rko       = if inValue >= "" then inValue else "" .
      when "code-payer"       then
        code-payer       = if inValue >= "" then integer (inValue) else 0 .
      when "code-payer-nonop-inc"       then
        code-payer-nonop-inc       = if inValue >= "" then integer (inValue) else 0 .
      when "code-payer-prepayment"       then
        code-payer-prepayment       = if inValue >= "" then integer (inValue) else 0 .
      when "rule-payer"       then
        rule-payer       = if inValue >= "" then inValue else "" .
      when "rule-payer-nonop-inc"       then
        rule-payer-nonop-inc       = if inValue >= "" then inValue else "" .
      when "rule-payer-prepayment"       then
        rule-payer-prepayment       = if inValue >= "" then inValue else "" .
      when "rule-att"         then
        rule-att         = if inValue >= "" then integer (inValue) else 0 .
      when "ind-kass-pko"     then
        ind-kass-pko     = if inValue >= "" then integer (inValue) else 0 .
      when "apart-np-tnp"     then
        apart-np-tnp     = if inValue >= "" then integer (inValue) else 0 .
      when "kredit"           then
        kredit           = if inValue >= "" then inValue else "" .
      when "kredit-nonop-inc"           then
        kredit-nonop-inc           = if inValue >= "" then inValue else "" .
      when "credit-prepayment"           then
        credit-prepayment           = if inValue >= "" then inValue else "" .
      when "debit"            then
        debit            = if inValue >= "" then inValue else "" .
      when "Corr-Rko"          then
        Corr-Rko            = if inValue >= "" then inValue else "" .
      when "post-chief"       then
        post-chief       = if inValue >= "" then inValue else "" .
      when "fio-chief"        then
        fio-chief        = if inValue >= "" then inValue else "" .
      when "fio-booker"       then
        fio-booker       = if inValue >= "" then inValue else "" .
      when "acc-shift"        then
        acc-shift        = if inValue >= "" then integer (inValue) else 0 .
      when "pko-prefix"       then
        pko-prefix       = if inValue >= "" then inValue else "" .
      when "rko-prefix"       then
        rko-prefix       = if inValue >= "" then inValue else "" .
      when "struct-unit"      then
        struct-unit      = if inValue >= "" then integer (inValue) else 0 .
      when "struct-unit-name" then
        struct-unit-name = if inValue >= "" then inValue else "" .
      when "struct-unit-type" then
        struct-unit-type = if inValue >= "" then inValue else "" .
      when "struct-unit-code" then
        struct-unit-code = if inValue >= "" then integer (inValue) else 0 .
      when "code-symbol" then
        code-symbol = if inValue >= "" then integer (inValue) else 0 .
      when "pin" then
        pin = if inValue >= "" then inValue else "" .
      when "bank-resive" then
        bank-resive = if inValue >= "" then inValue else "" .
      when "bank-deposit" then
        bank-deposit = if inValue >= "" then inValue else "" .
      when "cont-inkass" then
        cont-inkass = if inValue >= "" then integer (inValue) else 0 .
      when "contr-code-rko" then
        contr-code-rko = if inValue >= "" then integer (inValue) else 0 .
      when "Corr-transf" then
        Corr-transf = if inValue >= "" then inValue else "" .
      when "rule-osn-transf" then
        rule-osn-transf = if inValue >= "" then inValue else "" .
      when "contr-code-transf" then
        contr-code-transf = if inValue >= "" then integer (inValue) else 0 .
      when "rule-payer-transf" then
        rule-payer-transf = if inValue >= "" then inValue else "" .
      when "rule-payer-rko" then
        rule-payer-rko = if inValue >= "" then inValue else "" .
      when "rule-payer-inkass" then
        rule-payer-inkass = if inValue >= "" then inValue else "" .
      when "bank-resive-acc" then
        bank-resive-acc = if inValue >= "" then inValue else "" .
      when "rule-osn-incass" then
        rule-osn-incass = if inValue >= "" then inValue else "" .
      when "Corr-inkass" then
        Corr-inkass = if inValue >= "" then inValue else "" .
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
  method override protected void SetPropProtected (SubsObj as ibs.th.bge.1crn.subjects.subjects):
    case SubsObj:InitTag:
      when "kb-gds"   then
        kb-gds   = SubsObj.
    end case.
  end method.
  method override protected void CheckData ():
    def var v-str as char no-undo.
    assign
      v-str = ",code"
      when code_ = ?
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
