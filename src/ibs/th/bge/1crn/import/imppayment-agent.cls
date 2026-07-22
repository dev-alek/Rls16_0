/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Класс ипорта данных payment-agent (Информация по типам кассовых книг) из 1С

Автор: Молотков Сергей
Дата создания: 21/05/19
Author: Molotkov Sergey
Creation date: 21/05/19

*/
&scoped-define impclass payment-agent
using ibs.th.bge.1crn.subjects.subjects.
using ibs.th.bge.1crn.subjects.{&impclass}.

block-level on error undo, throw.

class ibs.th.bge.1crn.import.imp{&impclass} implements ibs.th.bge.1crn.import.iimpsubject: 

  { cmp/str-glbl.i class } /* &add-def, &update, &deletion, &shop, &attr-cash-book-id, &attr-oper-serv-id */

  define private temp-table tt-gds no-undo
    field gds-code as integer
  .
  
  define private temp-table tt-operserv no-undo like ub.OperServ .

  define property Msg as character no-undo
    get. 
    set.

  method public logical Excute( subjectObj as class ibs.th.bge.1crn.subjects.isubject ):
    define variable objImp    as class {&impclass} no-undo.
    define variable v-retfl   as logical no-undo .
    define variable v-mode    as character no-undo. /* create/update */
  
    define variable v-pay-agent as class ibs.th.bge.1crn.subjects.{&impclass} no-undo .
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
    /* платёжный агент (до 21/V-2019):
      - ext-code платёжного агента совпадает с ext-code кассовой книги, к которой он относится в 1с;
      - новый платёжный агент добавляется, старый - обновляется;
      - при удалении Status_ у платёжного агента изменяется как Status_ у кассовой книги.
      Ид. платёжного агента далее используется вместе с ид.кассовой книги для привязки товара к кассовой книге.
    */
    objImp = cast (subjectObj, {&impclass}).
    v-pay-agent = objImp .
    v-code = v-pay-agent:code_ . /* обязательность 1-1 */
    v-name = v-pay-agent:name_ . /* обязательность 1-1 */

  do : /* проверки перечислимых значений */
  
    /* 29/III-2019  обязательность 1-1 для полей sign-pa, sign-pa-subj, type-calc-repl,
                    тип полей сменился с Строка на Число (N,0) */
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

    /* 07/III-2019 Допустимые значения: 0 - пусто, 1 - "Автопомощь" */
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
    
  end . /* ...end_of проверки перечислимых значений */
  
    empty temp-table tt-operserv .
    find first buf_OperServ exclusive-lock
         where buf_OperServ.ext-code = v-code no-error .
    if available buf_OperServ then do :
      v-mode = {&update} .
      create tt-operserv .
      buffer-copy buf_OperServ to tt-operserv .
    end .
    else do :
      create tt-operserv .
      assign
        v-mode = {&add-def}
        tt-operserv.id       = next-value (s-operserv-id)
        tt-operserv.ext-code = v-code
      .
    end .
    assign
      v-operservid = tt-operserv.id
/* char   */ tt-operserv.OSname    = v-name 
/* char      tt-operserv.OsNameAbbr = отсутствует в формате импорта */ 
/* deci-2 */ tt-operserv.SummMin   = v-pay-agent:min-sum     when v-pay-agent:min-sum <> ?
/* deci-2 */ tt-operserv.SummMax   = v-pay-agent:max-sum     /* обязательность 1-1 */
/* deci-2 */ tt-operserv.SummAtent = v-pay-agent:warning-sum when v-pay-agent:warning-sum <> ?
    .

    /* 03/IV-2019  в импорте приходит 1 или 0, в БД сохраняется 4 или 5: 4=сумма,5=процент */
    if v-commentrytype <> ? then do :
      case v-commentrytype:
        when 0 then tt-operserv.CommType = 5 .
        when 1 then tt-operserv.CommType = 4 .
        otherwise .
      end case .
      if v-pay-agent:value-comm <> ? then case v-commentrytype :
        when 0 then assign 
/* deci-2 */ tt-operserv.CommPerc  = v-pay-agent:value-comm
        .
        when 1 then assign
/* deci-2 */ tt-operserv.CommSumm  = v-pay-agent:value-comm
        .
        otherwise .
      end case .
    end .

    assign
/* inte   */ tt-operserv.gds-code  = v-pay-agent:gds-comm when v-pay-agent:gds-comm <> ?
/* logi   */ tt-operserv.PreAAvt   = (v-pay-agent:auth-req > 0)    when v-pay-agent:auth-req <> ?
/* logi   */ tt-operserv.PreSlip   = (v-pay-agent:prt-slp-req > 0) when v-pay-agent:prt-slp-req <> ?
/* char   */ tt-operserv.SlipName  = v-pay-agent:name-slp          when v-pay-agent:name-slp <> ?
/* inte   */ tt-operserv.CalcType  = v-pay-agent:type-calc-repl    /* обязательность 1-1 */
/* char   */ tt-operserv.OperAddr  = v-pay-agent:adr-trans-op  /* обязательность 1-1 */
/* char   */ tt-operserv.OperInn   = v-pay-agent:inn-trans-op  /* обязательность 1-1 */
/* char   */ tt-operserv.OperName  = v-pay-agent:name-trans-op /* обязательность 1-1 */
/* inte   */ tt-operserv.AgentFlag = v-pay-agent:sign-pa       /* обязательность 1-1 */
/* char   */ tt-operserv.AgentTel  = v-pay-agent:tel-pa        /* обязательность 1-1 */
/* char   */ tt-operserv.OperTel   = v-pay-agent:tel-acceptor  /* обязательность 1-1 */
/* inte   */ tt-operserv.AgentFlagRasch = v-pay-agent:sign-pa-subj /* обязательность 1-1 */
/* char   */ tt-operserv.InnSupp   = v-pay-agent:inn-prov    when v-pay-agent:inn-prov <> ?
/* char   */ tt-operserv.OperTelTran    = v-pay-agent:tel-trans-op /* обязательность 1-1 */
/* char   */ tt-operserv.AgentOpere     = v-pay-agent:oper-pa      /* обязательность 1-1 */
/* char   */ tt-operserv.SuppTel   = v-pay-agent:tel-prov    when v-pay-agent:tel-prov <> ?
/* char   */ tt-operserv.SuppName  = v-pay-agent:name-prov   when v-pay-agent:name-prov <> ?
/* inte   */ tt-operserv.QuantMax  = v-pay-agent:max-num     when v-pay-agent:max-num <> ?
/* inte   */ tt-operserv.QuantMin  = v-pay-agent:min-num     when v-pay-agent:min-num <> ?
/* inte   */ tt-operserv.OsType    = v-pay-agent:oper-type   when v-pay-agent:oper-type <> ?
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
  


    /* товары платёжного агента (аналогично товарам кассовой книги) на выходе:
       - привязаны к пришедшей кассовой книге,
       - других товаров к ней не привязано,
       - от других книг товары отвязаны
    */
    &scop proc-name gds-attr-write
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
      
      /* Отвязать от других платёжных. Скопировано из attr-lib:gds-attr-DELETE() */
      if v-mode = {&update} then do :
        for each buf_goods-attr exclusive-lock
           where buf_goods-attr.attr-code  = {&attr-oper-serv-id}
             and buf_goods-attr.attr-value = v-str-ossid :
          if not can-find (first tt-gds where tt-gds.gds-code = buf_goods-attr.gds-code) then
            delete buf_goods-attr.
        end .
      end .
      
      /* Перепривязать к пришедшему платёжному агенту. Скопировано из attr-lib:gds-attr-write() */
      for each tt-gds :
        find first buf_goods-attr exclusive-lock
             where buf_goods-attr.gds-code  = tt-gds.gds-code
               and buf_goods-attr.attr-code = {&attr-oper-serv-id} no-error .
        if available buf_goods-attr then assign
          buf_goods-attr.attr-value = v-str-ossid when (buf_goods-attr.attr-value <> v-str-ossid)
        .
        else do:
          create buf_goods-attr .
          assign
            buf_goods-attr.gds-code   = tt-gds.gds-code
            buf_goods-attr.attr-code  = {&attr-oper-serv-id}
            buf_goods-attr.attr-value = v-str-ossid
          .
        end.
      end .
      /* образец вызова из attr-lib.p
        {&run_proc_attr-lib}
        (input  v-gds-code
        ,input  {&attr-cash-book-id}
        ,input  v-str-kb-id
        ) no-error .
      */
    end. // end_of_gds


    v-retfl = true.
    
    define variable i as integer no-undo .
    catch exAppErrors as class Progress.Lang.AppError :
      Msg = exAppErrors:ReturnValue .
      if Msg > "" then . else do :
        do i = 1 to exAppErrors:NumMessages :
          Msg = Msg + {&new-line} + exAppErrors:GetMessage(i) .
        end .
        if Msg > "" then . else Msg = "AppError в платёжных агентах" .
      end .
      v-retfl = false .
      undo, throw exAppErrors .
    end catch .
    catch exProErrors as class Progress.Lang.ProError :
      do i = 1 to exProErrors:NumMessages :
        Msg = Msg + {&new-line} + exProErrors:GetMessage(i) .
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
  end method. /* end_of Excute */

/*
  method private character getMgrPositionName (input p-post-chief as integer) :
    /* Должность рук-ля
• 0 – должность рук-ля фирмы
• 1 – «директор»
• 2 – «управляющий»
    */
    define variable v-name as character no-undo .
    case p-post-chief :
      when 1 then v-name = "директор" .
      when 2 then v-name = "управляющий" .
      otherwise do :
        // как найти должность руководителя фирмы?
      end .
    end case .
    return v-name .
  end method . /* end_of getMgrPositionName */

  method private character getMgrFioName (input p-fio-chief as integer) :
    /* ФИО рук-ля
• 0 - "ФИО руководителя фирмы"
• 1 - "ФИО руководителя магазина"
    */
    define variable v-name as character no-undo .
    case p-fio-chief :
      when 1 then v-name = "ФИО руководителя магазина" .
        otherwise v-name = "ФИО руководителя фирмы" .
    end case .
    return v-name .
  end method . /* end_of getMgrFioName */

  method private character getBuhFioName (input p-fio-booker as integer) :
    /* ФИО бухг-ра
• 0 - "ФИО гл. бухгалтера фирмы"
• 1 - "ФИО бухгалтера магазина"
    */
    define variable v-name as character no-undo .
    case p-fio-booker :
      when 1 then v-name = "ФИО бухгалтера магазина" .
        otherwise v-name = "ФИО гл. бухгалтера фирмы" .
    end case .
    return v-name .
  end method . /* end_of getBuhFioName */

  method private character getStructName (input p-struct-unit as integer) :
    /* Поле «Структурн.подразд»
• 0 – заполняет оператор
• 1 – из настроек объекта
• 2 – свободный текст
       В экранной форме реализован выбор:
arrayvar5[1] = "Заполняет оператор".
arrayvar5[2] = "Взять из объекта".
arrayvar5[3] = "Значение по умолчанию".
    */
    define variable v-name as character no-undo .
    case p-struct-unit :
      when 1 then v-name = "Взять из объекта" .
      when 2 then v-name = "Значение по умолчанию" .
        otherwise v-name = "Заполняет оператор" .
    end case .
    return v-name .
  end method . /* end_of getStructName */
  
  method private character getRuleOsnName (input p-rule-reason as integer) :
    /* Правило заполнения графы "Основание"
• 0 - "Выручка от реализации"
• 1 - "Номера Z-отчетов"
• 2 - "Не заполнять"
20/V-2019 не используется
    */
    define variable v-name as character no-undo .
    case p-rule-reason :
      when 1 then v-name = "Номера Z-отчетов" .
      when 2 then v-name = "Не заполнять" .
        otherwise v-name = "Выручка от реализации" .
    end case .
    return v-name .
  end method . /* end_of getRuleOsnName */
    
  method private character getRulePrilName (input p-rule-att as integer) :
    /* Правило заполнения графы "Приложение"
• 0 - "Номера Z-отчетов"
• 1 - "Не заполнять"
    */
    define variable v-name as character no-undo .
    case p-rule-att :
      when 1 then v-name = "Не заполнять" .
        otherwise v-name = "Номера Z-отчетов" .
    end case .
    return v-name .
  end method . /* end_of getRulePrilName */

  method private character getUchetName (input p-acc-shift as integer) :
    /* Учет ведется по:
• 0 –календарным датам
• 1 –по сменам
       В экранной форме реализован выбор:
arrayvar6[1] = "по сменным датам".
arrayvar6[2] = "по календарным датам".
    */
    define variable v-name as character no-undo .
    case p-acc-shift :
      when 1 then v-name = "по сменным датам" .
        otherwise v-name = "по календарным датам" .
    end case .
    return v-name .
  end method . /* end_of getUchetName */
*/    
end class.
