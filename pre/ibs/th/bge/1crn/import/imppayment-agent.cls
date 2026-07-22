using ibs.th.bge.1crn.subjects.subjects.
using ibs.th.bge.1crn.subjects.payment-agent.
block-level on error undo, throw.
class ibs.th.bge.1crn.import.imppayment-agent implements ibs.th.bge.1crn.import.iimpsubject:
  define private temp-table tt-gds no-undo
    field gds-code as integer
  .
  define private temp-table tt-operserv no-undo like ub.OperServ .
  define property Msg as character no-undo
    get.
    set.
  method public logical Excute( subjectObj as class ibs.th.bge.1crn.subjects.isubject ):
    define variable objImp    as class payment-agent no-undo.
    define variable v-retfl   as logical no-undo .
    define variable v-mode    as character no-undo.
    define variable v-pay-agent as class ibs.th.bge.1crn.subjects.payment-agent no-undo .
    define variable v-code      as character no-undo .
    define variable v-name      as character no-undo .
    define variable v-operservid as int64 no-undo .
    define variable v-commentrytype as integer no-undo .
    define variable v-objlist   as class ibs.th.bge.1crn.subjects.subjects no-undo . // imp:kb-gds[]
    define variable v-i-counter as integer no-undo .
    define variable v-i-num     as integer no-undo .
    define variable v-stub      as integer no-undo .
    define variable v-gds-gd    as class ibs.th.bge.1crn.subjects.kass-book-gd no-undo .
    define variable v-gds-code  as integer no-undo .
    define variable v-str-ossid as character no-undo .
    define buffer buf_OperServ   for ub.OperServ .
    define buffer buf_goods      for ub.goods .
    define buffer buf_goods-attr for ub.goods-attr .
    Msg        = "":U .
    objImp = cast (subjectObj, payment-agent).
    v-pay-agent = objImp .
    v-code = v-pay-agent:code_ .
    v-name = v-pay-agent:name_ .
  do :
    if (v-pay-agent:sign-pa = 1) or (v-pay-agent:sign-pa = 2) or
       (v-pay-agent:sign-pa = 4) or (v-pay-agent:sign-pa = 8) or
       (v-pay-agent:sign-pa = 16) or (v-pay-agent:sign-pa = 32) or
       (v-pay-agent:sign-pa = 64) then .
    else undo, throw new Progress.Lang.AppError( substitute(
        "Признак агента [&1] для платёжного агента [&2 &3] может принимать только значения значения: " +
        "1-Банковский платежный агент, 2-Банковский платежный субагент, 4-Платежный агент, " +
        "8-Платежный субагент, 16-Поверенный пользователь, 32-Комиссионер, 64-Агент, не явл. никем из перечисленных"
        , v-pay-agent:sign-pa, v-code, v-name
    ) ) .
    if (v-pay-agent:sign-pa-subj = 1) or (v-pay-agent:sign-pa-subj = 2) or
       (v-pay-agent:sign-pa-subj = 4) or (v-pay-agent:sign-pa-subj = 8) or
       (v-pay-agent:sign-pa-subj = 16) or (v-pay-agent:sign-pa-subj = 32) or
       (v-pay-agent:sign-pa-subj = 64) then .
    else undo, throw new Progress.Lang.AppError( substitute(
        "Признак агента по предмету расчета [&1] для платёжного агента [&2 &3] может принимать только значения значения: " +
        "1-Банковский платежный агент, 2-Банковский платежный субагент, 4-Платежный агент, " +
        "8-Платежный субагент, 16-Поверенный пользователь, 32-Комиссионер, 64-Агент, не явл. никем из перечисленных"
        , v-pay-agent:sign-pa-subj, v-code, v-name
    ) ) .
    if (v-pay-agent:type-calc-repl = 1) or (v-pay-agent:type-calc-repl = 4) or
       (v-pay-agent:type-calc-repl = 5) then .
    else undo, throw new Progress.Lang.AppError( substitute(
        "Тип расчета с опер.пополн. [&1] для платёжного агента [&2 &3] может принимать только значения: " +
        "1-Оплата Сотовой связи, 4-Начисление на карту, 5-Платежный агент"
        , v-pay-agent:type-calc-repl, v-code, v-name
    ) ) .
    v-commentrytype = integer(v-pay-agent:comm-entry-type) no-error .
    if v-commentrytype > 0 then do :
      if (v-commentrytype = 1) then .
      else undo, throw new Progress.Lang.AppError( substitute(
          "Тип ввода комиссии [&1] для платёжного агента [&2 &3] может принимать только значения: " +
          "0–процент, 1–сумма"
        , v-pay-agent:comm-entry-type, v-code, v-name
      ) ) .
    end .
  end .
    empty temp-table tt-operserv .
    find first buf_OperServ exclusive-lock
         where buf_OperServ.ext-code = v-code no-error .
    if available buf_OperServ then do :
      v-mode = 'ИЗМЕНЕНИЕ':U .
      create tt-operserv .
      buffer-copy buf_OperServ to tt-operserv .
    end .
    else do :
      create tt-operserv .
      assign
        v-mode = 'ДОБАВЛЕНИЕ':U
        tt-operserv.id       = next-value (s-operserv-id)
        tt-operserv.ext-code = v-code
      .
    end .
    assign
      v-operservid = tt-operserv.id
 tt-operserv.OSname    = v-name
 tt-operserv.SummMin   = v-pay-agent:min-sum     when v-pay-agent:min-sum <> ?
 tt-operserv.SummMax   = v-pay-agent:max-sum
 tt-operserv.SummAtent = v-pay-agent:warning-sum when v-pay-agent:warning-sum <> ?
    .
    if v-commentrytype <> ? then do :
      case v-commentrytype:
        when 0 then tt-operserv.CommType = 5 .
        when 1 then tt-operserv.CommType = 4 .
        otherwise .
      end case .
      if v-pay-agent:value-comm <> ? then case v-commentrytype :
        when 0 then assign
 tt-operserv.CommPerc  = v-pay-agent:value-comm
        .
        when 1 then assign
 tt-operserv.CommSumm  = v-pay-agent:value-comm
        .
        otherwise .
      end case .
    end .
    assign
 tt-operserv.gds-code  = v-pay-agent:gds-comm when v-pay-agent:gds-comm <> ?
 tt-operserv.PreAAvt   = (v-pay-agent:auth-req > 0)    when v-pay-agent:auth-req <> ?
 tt-operserv.PreSlip   = (v-pay-agent:prt-slp-req > 0) when v-pay-agent:prt-slp-req <> ?
 tt-operserv.SlipName  = v-pay-agent:name-slp          when v-pay-agent:name-slp <> ?
 tt-operserv.CalcType  = v-pay-agent:type-calc-repl
 tt-operserv.OperAddr  = v-pay-agent:adr-trans-op
 tt-operserv.OperInn   = v-pay-agent:inn-trans-op
 tt-operserv.OperName  = v-pay-agent:name-trans-op
 tt-operserv.AgentFlag = v-pay-agent:sign-pa
 tt-operserv.AgentTel  = v-pay-agent:tel-pa
 tt-operserv.OperTel   = v-pay-agent:tel-acceptor
 tt-operserv.AgentFlagRasch = v-pay-agent:sign-pa-subj
 tt-operserv.InnSupp   = v-pay-agent:inn-prov    when v-pay-agent:inn-prov <> ?
 tt-operserv.OperTelTran    = v-pay-agent:tel-trans-op
 tt-operserv.AgentOpere     = v-pay-agent:oper-pa
 tt-operserv.SuppTel   = v-pay-agent:tel-prov    when v-pay-agent:tel-prov <> ?
 tt-operserv.SuppName  = v-pay-agent:name-prov   when v-pay-agent:name-prov <> ?
 tt-operserv.QuantMax  = v-pay-agent:max-num     when v-pay-agent:max-num <> ?
 tt-operserv.QuantMin  = v-pay-agent:min-num     when v-pay-agent:min-num <> ?
 tt-operserv.OsType    = v-pay-agent:oper-type   when v-pay-agent:oper-type <> ?
    .
      if tt-operserv.CalcType eq 1
      then
         tt-operserv.OsType = 1.
      else if tt-operserv.CalcType eq 4
      then
         tt-operserv.OsType = 3.
    if available buf_OperServ then do :
      buffer-copy tt-operserv to buf_OperServ .
    end .
    else do :
      create buf_OperServ .
      buffer-copy tt-operserv to buf_OperServ .
    end .
        empty temp-table tt-gds .
    v-objlist = objImp:kb-gds .
    if valid-object(v-objlist) then do :
      v-i-counter = v-objlist:iCounter .
      do v-i-num = 1 to v-i-counter :
        v-stub = v-objlist:Get(v-i-num) . // возвращает кол-во элементов и переключает currItem
        v-gds-gd = cast(v-objlist:SubjectObjCurr, ibs.th.bge.1crn.subjects.kass-book-gd) .
        v-gds-code = integer(v-gds-gd:gd-code) .
        if not can-find (first buf_goods where buf_goods.gds-code = v-gds-code) then
          undo, throw new Progress.Lang.AppError( substitute(
            "Код товара [&1] платёжного агента [&2 &3] отсутствует в справочнике товаров."
            , v-gds-code, v-code, v-name
        ) ) .
        create tt-gds.
        tt-gds.gds-code = v-gds-code .
      end . // end_of_objImp:gds[]
      v-str-ossid = string(v-operservid) no-error .
      if v-mode = 'ИЗМЕНЕНИЕ':U then do :
        for each buf_goods-attr exclusive-lock
           where buf_goods-attr.attr-code  = 'oper-serv-idd':U
             and buf_goods-attr.attr-value = v-str-ossid :
          if not can-find (first tt-gds where tt-gds.gds-code = buf_goods-attr.gds-code) then
            delete buf_goods-attr.
        end .
      end .
      for each tt-gds :
        find first buf_goods-attr exclusive-lock
             where buf_goods-attr.gds-code  = tt-gds.gds-code
               and buf_goods-attr.attr-code = 'oper-serv-idd':U no-error .
        if available buf_goods-attr then assign
          buf_goods-attr.attr-value = v-str-ossid when (buf_goods-attr.attr-value <> v-str-ossid)
        .
        else do:
          create buf_goods-attr .
          assign
            buf_goods-attr.gds-code   = tt-gds.gds-code
            buf_goods-attr.attr-code  = 'oper-serv-idd':U
            buf_goods-attr.attr-value = v-str-ossid
          .
        end.
      end .
    end. // end_of_gds
    v-retfl = true.
    define variable i as integer no-undo .
    catch exAppErrors as class Progress.Lang.AppError :
      Msg = exAppErrors:ReturnValue .
      if Msg > "" then . else do :
        do i = 1 to exAppErrors:NumMessages :
          Msg = Msg + chr(10) + exAppErrors:GetMessage(i) .
        end .
        if Msg > "" then . else Msg = "AppError в платёжных агентах" .
      end .
      v-retfl = false .
      undo, throw exAppErrors .
    end catch .
    catch exProErrors as class Progress.Lang.ProError :
      do i = 1 to exProErrors:NumMessages :
        Msg = Msg + chr(10) + exProErrors:GetMessage(i) .
      end .
      if Msg > "" then . else Msg = "ProError в платёжных агентах" .
      v-retfl = false.
      undo, throw exProErrors .
    end catch .
    catch exAnyErrors as class Progress.Lang.Error:
      Msg = "Unexpected error в платёжных агентах" .
      v-retfl = false .
      undo, throw exAnyErrors .
    end catch .
    finally :
      return v-retfl .
    end finally .
  end method.
end class.
