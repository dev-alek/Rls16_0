block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: finfcont.p $
$Archive: ref/finfcont.p $

Заполнение временной таблицы согласно заданному контракту

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/21/04
Author: Bakhtadze Natalya
Creation date: 01/21/04

*/

DEFINE TEMP-TABLE tt0-fin-doc NO-UNDO LIKE ub.fin-doc.
define temp-table tt-fin-doc no-undo like ub.fin-doc.

define input parameter parparentproc      as widget-handle no-undo .
define input parameter p-host-code        like ub.contract.host-code no-undo .
define input parameter p-mode as character no-undo.
/*может быть {&add-def} {&add-copy} {&update} {&lookup} close-doc open-doc*/

define input parameter p-fin-doc-code     like ub.fin-doc.fin-doc-code no-undo .
define input parameter p-fin-doc-type     like ub.fin-doc.fin-doc-type no-undo .
define input parameter p-fin-ext-doc-type like ub.fin-doc.fin-ext-doc-type no-undo .
define input parameter p-contract-code    like ub.fin-doc.contract-code no-undo .
define INPUT-OUTPUT parameter table for tt0-fin-doc.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: finfcont.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/finfcont.p $":U .
define variable vss-description as character no-undo init "".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/library.i }

define variable v-buttons as character no-undo .
define variable v-desc as character no-undo .
define variable v-t as character no-undo .
define variable v-num as integer no-undo .
define variable v-bank-name like ub.fin-bank.bank-name no-undo .
define variable v-bank-city like ub.fin-bank.bank-city no-undo .
define variable v-dop1     like ub.fin-schet.dop1     no-undo .
define variable v-dop2     like ub.fin-schet.dop2     no-undo .
define variable v-bik like ub.fin-bank.bik no-undo .
define variable v-c-schet like ub.fin-bank.cor-acc no-undo .
define variable v-r-schet like ub.fin-schet.r-schet no-undo .
define variable v-code-schet like ub.fin-schet.code-schet no-undo .
define variable v-payer-schet-curr-code like ub.fin-schet.curr-code no-undo .
define variable v-receiver-schet-curr-code like ub.fin-schet.curr-code no-undo .
define variable v-payer-schet-curr-abbr like ub.currency.curr-abbr no-undo .
define variable v-receiver-schet-curr-abbr like ub.currency.curr-abbr no-undo .
define variable v-base-code like ub.sysconf.base-code no-undo .
define variable v-base-curr-abbr like ub.currency.curr-abbr no-undo .
define variable v-curr-abbr-contr like ub.currency.curr-abbr no-undo .
define variable v-sel-curr as character no-undo .



define buffer buf_contract for ub.contract.
define buffer buf_tt-fin-doc for tt-fin-doc.
define buffer buf_currency for ub.currency.

find first buf_contract no-lock where
         buf_contract.contract-code = p-contract-code
     and buf_contract.host-code     = p-host-code   no-error .
if error-status :error then do:
   return error substitute("Не найден контракт с кодом &1 по фирме &2", p-contract-code, p-host-code).
end.

if p-fin-doc-type = {&income-cash}
or  p-fin-doc-type = {&income-cashless}
or  p-fin-doc-type = {&income-payoff}
then assign
  v-t = "Плательщика"
.

else assign
  v-t = "Получателя"
.
v-num = 1.
if not( buf_contract.posr-name = ""
and     buf_contract.agnt-name = "")
and p-mode = {&add-def} then do:
    assign
    v-buttons  = "Контрагент" + "|" +
                (if buf_contract.posr-name <> "" then "Посредник" else "Посредник^disable") + "|" +
                (if buf_contract.agnt-name <> "" then "Агент"     else "Агент^disable" )    + "|" +
                "Отмена"
    v-desc     = buf_contract.cli-name + "|" +
                buf_contract.posr-name + "|" +
                buf_contract.agnt-name + "|" +
                "Отказ от создания платежа"
    .

    run gbl/d-askw.w
      (input "Внимание!" /* Заголовок окна */
      ,input "Выберите " + v-t + " по платежу"  /* Общее сообщение */
      ,input "|^" /* Символы разделители для кодирования двух следующих параметров */
      ,input v-buttons /* список названий кнопок  */
      ,input v-desc    /* список описаний кнопок */
      ,input 1 /* значение возвращаемое при нажатии enter */
      ,input 4 /* значение возвращаемое при нажатии escape */
      ,output v-num /* выбор пользователя */
      ).
end.
else do:
  assign
  v-num = 1
  .
end.

if v-num = 4 then do:
   return error "exit":U.
end.

do
on error undo, return error
:
  for each tt0-fin-doc no-lock where
              tt0-fin-doc.host-code = p-host-code
        AND tt0-fin-doc.fin-doc-code = p-fin-doc-code:
    create buf_tt-fin-doc.
    buffer-copy tt0-fin-doc to buf_tt-fin-doc.
  END.
  find first tt-fin-doc no-error .
  if not avail tt-fin-doc then do:
    return error "":U.
  end.

  case p-fin-doc-type :
      when {&income-cash}
      or
      when {&income-cashless}
      or
      when {&income-payoff}
      then do:
        case v-num :
          when 1 then do:
            assign
            error-status:error = no
            .
            if buf_contract.cli-code-schet > 0
            then do:
              assign
              v-code-schet = buf_contract.cli-code-schet
              .
              run get-bank-requisite in this-procedure (
                                                        input buf_contract.host-code
                                                        ,input v-code-schet
                                                        ,output v-bank-name
                                                        ,output v-bank-city
                                                        ,output v-dop1
                                                        ,output v-dop2
                                                        ,output v-bik
                                                        ,output v-c-schet
                                                        ,output v-r-schet
                                                        ,output v-payer-schet-curr-code
                                                        ,output v-payer-schet-curr-abbr
                                                          ) no-error .
            end.
            if buf_contract.cli-code-schet = 0
            or error-status:error then do:
              assign
              v-code-schet = buf_contract.cli-code-schet-start
              .
              run get-bank-requisite in this-procedure (
                                                        input buf_contract.host-code
                                                        ,input v-code-schet
                                                        ,output v-bank-name
                                                        ,output v-bank-city
                                                        ,output v-dop1
                                                        ,output v-dop2
                                                        ,output v-bik
                                                        ,output v-c-schet
                                                        ,output v-r-schet
                                                        ,output v-payer-schet-curr-code
                                                        ,output v-payer-schet-curr-abbr
                                                          ) no-error .


            end.
            assign
            tt-fin-doc.payer-code       =  buf_contract.cli-code
            tt-fin-doc.payer-type       =  buf_contract.cli-type
            tt-fin-doc.payer-name       =  buf_contract.cli-name
            tt-fin-doc.payer-inn        =  buf_contract.cli-inn
            tt-fin-doc.payer-kpp        =  buf_contract.cli-kpp
            tt-fin-doc.payer-sign1      =  if p-fin-doc-type = {&income-payoff}
                                           or p-fin-doc-type = {&income-cashless}
                                           then buf_contract.cli-sign
                                           else tt-fin-doc.payer-sign1
        /*  tt-fin-doc.payer-okpo       =  buf_contract.cli-okpo */
            .
        end.
        when 2 then do:
          assign
          error-status:error = no.
          if buf_contract.posr-code-schet > 0
          then do:
            assign
            v-code-schet = buf_contract.posr-code-schet
            .
            run get-bank-requisite in this-procedure (
                                                      input buf_contract.host-code
                                                      ,input v-code-schet
                                                      ,output v-bank-name
                                                      ,output v-bank-city
                                                      ,output v-dop1
                                                      ,output v-dop2
                                                      ,output v-bik
                                                      ,output v-c-schet
                                                      ,output v-r-schet
                                                      ,output v-payer-schet-curr-code
                                                      ,output v-payer-schet-curr-abbr
                                                        ) no-error .
          end.
          if buf_contract.posr-code-schet = 0
          or error-status:error then do:
            assign
            v-code-schet = buf_contract.posr-code-schet-start
            .

            run get-bank-requisite in this-procedure (
                                                      input buf_contract.host-code
                                                      ,input v-code-schet
                                                      ,output v-bank-name
                                                      ,output v-bank-city
                                                      ,output v-dop1
                                                      ,output v-dop2
                                                      ,output v-bik
                                                      ,output v-c-schet
                                                      ,output v-r-schet
                                                      ,output v-payer-schet-curr-code
                                                      ,output v-payer-schet-curr-abbr
                                                        ) no-error .
          end.
          assign
          tt-fin-doc.payer-code       =  buf_contract.posr-code
          tt-fin-doc.payer-type       =  buf_contract.posr-type
          tt-fin-doc.payer-name       =  buf_contract.posr-name
          tt-fin-doc.payer-inn        =  buf_contract.posr-inn
          tt-fin-doc.payer-kpp        =  buf_contract.posr-kpp
          tt-fin-doc.payer-sign1      =  if p-fin-doc-type = {&income-payoff}
                                         or p-fin-doc-type = {&income-cashless}
                                         then buf_contract.posr-sign
                                         else tt-fin-doc.payer-sign1
      /*  tt-fin-doc.payer-okpo       =  buf_contract.posr-okpo */
          .
        end.
        when 3 then do:
          assign
          error-status:error = no.
          if buf_contract.agnt-code-schet > 0
          then do:
            assign
            v-code-schet = buf_contract.agnt-code-schet
            .
            run get-bank-requisite in this-procedure (
                                                      input buf_contract.host-code
                                                      ,input v-code-schet
                                                      ,output v-bank-name
                                                      ,output v-bank-city
                                                      ,output v-dop1
                                                      ,output v-dop2
                                                      ,output v-bik
                                                      ,output v-c-schet
                                                      ,output v-r-schet
                                                      ,output v-payer-schet-curr-code
                                                      ,output v-payer-schet-curr-abbr
                                                        ) no-error .
          end.
          if buf_contract.agnt-code-schet = 0
          or error-status:error then do:
            assign
            v-code-schet = buf_contract.agnt-code-schet-start
            .
            run get-bank-requisite in this-procedure (
                                                      input buf_contract.host-code
                                                      ,input v-code-schet
                                                      ,output v-bank-name
                                                      ,output v-bank-city
                                                      ,output v-dop1
                                                      ,output v-dop2
                                                      ,output v-bik
                                                      ,output v-c-schet
                                                      ,output v-r-schet
                                                      ,output v-payer-schet-curr-code
                                                      ,output v-payer-schet-curr-abbr
                                                        ) no-error .
          end.
          assign
          tt-fin-doc.payer-code       =  buf_contract.agnt-code
          tt-fin-doc.payer-type       =  buf_contract.agnt-type
          tt-fin-doc.payer-name       =  buf_contract.agnt-name
          tt-fin-doc.payer-inn        =  buf_contract.agnt-inn
          tt-fin-doc.payer-kpp        =  buf_contract.agnt-kpp
          tt-fin-doc.payer-sign1      =  if p-fin-doc-type = {&income-payoff}
                                         or p-fin-doc-type = {&income-cashless}
                                         then buf_contract.agnt-sign
                                         else tt-fin-doc.payer-sign1
          .
        end.
      end case.
      assign
      tt-fin-doc.payer-bank-name  =  v-bank-name
      tt-fin-doc.payer-bank-city  =  v-bank-city
      tt-fin-doc.payer-dop1       =  v-dop1
      tt-fin-doc.payer-dop2       =  v-dop2
      tt-fin-doc.payer-bik        =  v-bik
      tt-fin-doc.payer-code-schet =  (if p-fin-doc-type = {&income-cashless}
                                     or p-fin-doc-type = {&expense-cashless}
                                     then v-code-schet
                                     else 0)
      tt-fin-doc.payer-c-schet    =  v-c-schet
      tt-fin-doc.payer-r-schet    =  v-r-schet
      .
      assign
      error-status:error = no.
      if buf_contract.own-code-schet > 0
      then do:
        assign
        v-code-schet = buf_contract.own-code-schet
        .
        run get-bank-requisite in this-procedure (
                                                  input buf_contract.host-code
                                                  ,input v-code-schet
                                                  ,output v-bank-name
                                                  ,output v-bank-city
                                                  ,output v-dop1
                                                  ,output v-dop2
                                                  ,output v-bik
                                                  ,output v-c-schet
                                                  ,output v-r-schet
                                                  ,output v-receiver-schet-curr-code
                                                  ,output v-receiver-schet-curr-abbr
                                                    ) no-error .
      end.
      if buf_contract.own-code-schet = 0
      or error-status:error then do:
        assign
        v-code-schet = buf_contract.own-code-schet-start
        .
        run get-bank-requisite in this-procedure (
                                                  input buf_contract.host-code
                                                  ,input v-code-schet
                                                  ,output v-bank-name
                                                  ,output v-bank-city
                                                  ,output v-dop1
                                                  ,output v-dop2
                                                  ,output v-bik
                                                  ,output v-c-schet
                                                  ,output v-r-schet
                                                  ,output v-receiver-schet-curr-code
                                                  ,output v-receiver-schet-curr-abbr
                                                    ) no-error .

      end.
      assign
      tt-fin-doc.receiver-code       =  p-host-code
      tt-fin-doc.receiver-type       =  {&cmp}
      tt-fin-doc.receiver-name       =  buf_contract.own-name
      tt-fin-doc.receiver-inn        =  buf_contract.own-inn
      tt-fin-doc.receiver-kpp        =  buf_contract.own-kpp
    /* tt-fin-doc.receiver-okpo       =  buf_contract.own-okpo */
      tt-fin-doc.receiver-bank-name  =  v-bank-name
      tt-fin-doc.receiver-bank-city  =  v-bank-city
      tt-fin-doc.receiver-dop1       =  v-dop1
      tt-fin-doc.receiver-dop2       =  v-dop2
      tt-fin-doc.receiver-bik        =  v-bik
      tt-fin-doc.receiver-code-schet =  (if p-fin-doc-type = {&income-cashless}
                                        or p-fin-doc-type = {&expense-cashless}
                                        then v-code-schet
                                        else 0)
      tt-fin-doc.receiver-c-schet    =  v-c-schet
      tt-fin-doc.receiver-r-schet    =  v-r-schet
      tt-fin-doc.receiver-sign1      =  if p-fin-doc-type = {&income-payoff}
                                        then  (buf_contract.own-sign-post + {&delim-par} + buf_contract.own-sign)
                                        else tt-fin-doc.receiver-sign1
      .
    end.
    when {&expense-cash}
    or
    when {&expense-cashless}
    or
    when {&expense-payoff}
    then do:
      case v-num :
         when 1 then do:
          assign
          error-status:error = no.
          if buf_contract.cli-code-schet > 0
          then do:
            assign
            v-code-schet = buf_contract.cli-code-schet
            .
            run get-bank-requisite in this-procedure (
                                                      input buf_contract.host-code
                                                      ,input v-code-schet
                                                      ,output v-bank-name
                                                      ,output v-bank-city
                                                      ,output v-dop1
                                                      ,output v-dop2
                                                      ,output v-bik
                                                      ,output v-c-schet
                                                      ,output v-r-schet
                                                      ,output v-receiver-schet-curr-code
                                                      ,output v-receiver-schet-curr-abbr
                                                        ) no-error .
          end.
          if buf_contract.cli-code-schet = 0
          or error-status:error then do:
            assign
            v-code-schet = buf_contract.cli-code-schet-start
            .
            run get-bank-requisite in this-procedure (
                                                      input buf_contract.host-code
                                                      ,input v-code-schet
                                                      ,output v-bank-name
                                                      ,output v-bank-city
                                                      ,output v-dop1
                                                      ,output v-dop2
                                                      ,output v-bik
                                                      ,output v-c-schet
                                                      ,output v-r-schet
                                                      ,output v-receiver-schet-curr-code
                                                      ,output v-receiver-schet-curr-abbr
                                                        ) no-error .

          end.
          assign
          tt-fin-doc.receiver-code       =  buf_contract.cli-code
          tt-fin-doc.receiver-type       =  buf_contract.cli-type
          tt-fin-doc.receiver-name       =  buf_contract.cli-name
          tt-fin-doc.receiver-inn        =  buf_contract.cli-inn
          tt-fin-doc.receiver-kpp        =  buf_contract.cli-kpp
      /*  tt-fin-doc.receiver-okpo       =  buf_contract.cli-okpo */
          tt-fin-doc.receiver-sign1      =  if p-fin-doc-type = {&expense-payoff}
                                            then buf_contract.cli-sign
                                            else tt-fin-doc.receiver-sign1
          .
     end.
     when 2 then do:
        assign
        error-status:error = no.
        if buf_contract.posr-code-schet > 0
        then do:
          assign
          v-code-schet = buf_contract.posr-code-schet
          .
          run get-bank-requisite in this-procedure (
                                                    input buf_contract.host-code
                                                    ,input v-code-schet
                                                    ,output v-bank-name
                                                    ,output v-bank-city
                                                    ,output v-dop1
                                                    ,output v-dop2
                                                    ,output v-bik
                                                    ,output v-c-schet
                                                    ,output v-r-schet
                                                    ,output v-receiver-schet-curr-code
                                                    ,output v-receiver-schet-curr-abbr
                                                      ) no-error .
        end.
        if buf_contract.posr-code-schet = 0
        or error-status:error then do:
          assign
          v-code-schet = buf_contract.posr-code-schet-start
          .
          run get-bank-requisite in this-procedure (
                                                    input buf_contract.host-code
                                                    ,input v-code-schet
                                                    ,output v-bank-name
                                                    ,output v-bank-city
                                                    ,output v-dop1
                                                    ,output v-dop2
                                                    ,output v-bik
                                                    ,output v-c-schet
                                                    ,output v-r-schet
                                                    ,output v-receiver-schet-curr-code
                                                    ,output v-receiver-schet-curr-abbr
                                                      ) no-error .
        end.
        assign
        tt-fin-doc.receiver-code       =  buf_contract.posr-code
        tt-fin-doc.receiver-type       =  buf_contract.posr-type
        tt-fin-doc.receiver-name       =  buf_contract.posr-name
        tt-fin-doc.receiver-inn        =  buf_contract.posr-inn
        tt-fin-doc.receiver-kpp        =  buf_contract.posr-kpp
    /*  tt-fin-doc.receiver-okpo       =  buf_contract.posr-okpo */
        tt-fin-doc.receiver-sign1      =  if p-fin-doc-type = {&expense-payoff}
                                          then buf_contract.posr-sign
                                          else tt-fin-doc.receiver-sign1
        .
     end.
     when 3 then do:
        assign
        error-status:error = no.
        if buf_contract.agnt-code-schet > 0
        then do:
          assign
          v-code-schet = buf_contract.agnt-code-schet
          .
          run get-bank-requisite in this-procedure (
                                                    input buf_contract.host-code
                                                    ,input v-code-schet
                                                    ,output v-bank-name
                                                    ,output v-bank-city
                                                    ,output v-dop1
                                                    ,output v-dop2
                                                    ,output v-bik
                                                    ,output v-c-schet
                                                    ,output v-r-schet
                                                    ,output v-receiver-schet-curr-code
                                                    ,output v-receiver-schet-curr-abbr
                                                      ) no-error .
        end.
        if buf_contract.agnt-code-schet = 0
        or error-status:error then do:
          assign
          v-code-schet = buf_contract.agnt-code-schet-start
          .
          run get-bank-requisite in this-procedure (
                                                    input buf_contract.host-code
                                                    ,input v-code-schet
                                                    ,output v-bank-name
                                                    ,output v-bank-city
                                                    ,output v-dop1
                                                    ,output v-dop2
                                                    ,output v-bik
                                                    ,output v-c-schet
                                                    ,output v-r-schet
                                                    ,output v-receiver-schet-curr-code
                                                    ,output v-receiver-schet-curr-abbr
                                                      ) no-error .
        end.
        assign
        tt-fin-doc.receiver-code       =  buf_contract.agnt-code
        tt-fin-doc.receiver-type       =  buf_contract.agnt-type
        tt-fin-doc.receiver-name       =  buf_contract.agnt-name
        tt-fin-doc.receiver-inn        =  buf_contract.agnt-inn
        tt-fin-doc.receiver-kpp        =  buf_contract.agnt-kpp
    /*  tt-fin-doc.receiver-okpo       =  buf_contract.agnt-okpo */
        tt-fin-doc.receiver-sign1      =  if p-fin-doc-type = {&expense-payoff}
                                          then  buf_contract.agnt-sign
                                          else tt-fin-doc.receiver-sign1
        .
     end.
   end case.
   assign
    tt-fin-doc.receiver-bank-name  =  v-bank-name
    tt-fin-doc.receiver-bank-city  =  v-bank-city
    tt-fin-doc.receiver-dop1       =  v-dop1
    tt-fin-doc.receiver-dop2       =  v-dop2
    tt-fin-doc.receiver-bik        =  v-bik
    tt-fin-doc.receiver-code-schet =  (if p-fin-doc-type = {&income-cashless}
                                       or p-fin-doc-type = {&expense-cashless}
                                      then v-code-schet
                                      else 0)
    tt-fin-doc.receiver-c-schet    =  v-c-schet
    tt-fin-doc.receiver-r-schet    =  v-r-schet
    .

    assign
    error-status:error = no
    .
    ASSIGN
    v-code-schet = 0
    v-bank-name  = '':U
    v-dop1 = '':U
    v-dop2 = '':u
    v-bik = '':U
    V-c-schet = '':U
    v-r-schet = '':U
    .
    if buf_contract.own-code-schet > 0
    then do:
      ASSIGN
      v-code-schet = buf_contract.own-code-schet.
      run get-bank-requisite in this-procedure (
                                                 input buf_contract.host-code
                                                ,input v-code-schet
                                                ,output v-bank-name
                                                ,output v-bank-city
                                                ,output v-dop1
                                                ,output v-dop2
                                                ,output v-bik
                                                ,output v-c-schet
                                                ,output v-r-schet
                                                ,output v-payer-schet-curr-code
                                                ,output v-payer-schet-curr-abbr
                                                  ) no-error .
    end.
    if buf_contract.own-code-schet = 0
    or error-status:error then do:
      ASSIGN
      v-code-schet = buf_contract.own-code-schet-start.
      run get-bank-requisite in this-procedure (
                                                 input buf_contract.host-code
                                                ,input v-code-schet
                                                ,output v-bank-name
                                                ,output v-bank-city
                                                ,output v-dop1
                                                ,output v-dop2
                                                ,output v-bik
                                                ,output v-c-schet
                                                ,output v-r-schet
                                                ,output v-payer-schet-curr-code
                                                ,output v-payer-schet-curr-abbr
                                                  ) no-error .

    end.
    assign
    tt-fin-doc.payer-code       =  p-host-code
    tt-fin-doc.payer-type       =  {&cmp}
    tt-fin-doc.payer-name       =  buf_contract.own-name
    tt-fin-doc.payer-inn        =  buf_contract.own-inn
    tt-fin-doc.payer-kpp        =  buf_contract.own-kpp
  /* tt-fin-doc.payer-okpo       =  buf_contract.own-okpo */
    tt-fin-doc.payer-bank-name  =  v-bank-name
    tt-fin-doc.payer-bank-city  =  v-bank-city
    tt-fin-doc.payer-dop1       =  v-dop1
    tt-fin-doc.payer-dop2       =  v-dop2
    tt-fin-doc.payer-bik        =  v-bik
    tt-fin-doc.payer-code-schet =  (if p-fin-doc-type = {&income-cashless}
                                   or p-fin-doc-type = {&expense-cashless}
                                   then v-code-schet
                                   else 0)
    tt-fin-doc.payer-c-schet    =  v-c-schet
    tt-fin-doc.payer-r-schet    =  v-r-schet
    tt-fin-doc.payer-sign1     =  if p-fin-doc-type = {&expense-payoff} or p-fin-doc-type = {&expense-cash}
                                   then (buf_contract.own-sign-post + {&delim-par} + buf_contract.own-sign)
                                   else (if p-fin-doc-type = {&expense-cashless}
                                         then buf_contract.own-sign
                                         else tt-fin-doc.payer-sign1)
    .
  end.
  end case.

  assign
  tt-fin-doc.contract-curr      =  buf_contract.curr-code
  .
  if (p-fin-doc-type = {&income-cashless}
  or p-fin-doc-type = {&expense-cashless})
  AND
  (tt-fin-doc.curr-code <> v-payer-schet-curr-code
  or tt-fin-doc.curr-code <> v-receiver-schet-curr-code) then do:
    if v-payer-schet-curr-code = v-receiver-schet-curr-code then do:
      assign
      v-sel-curr = string(v-payer-schet-curr-code)
      .
    end.
    else do:
      { gbl/basecode.i p-host-code v-base-code }

      find first buf_currency no-lock where
                buf_currency.curr-code = v-base-code.
      assign
      v-base-curr-abbr = buf_currency.curr-abbr.
      find first buf_currency no-lock where
                buf_currency.curr-code = tt-fin-doc.contract-curr.
      assign
      v-curr-abbr-contr = buf_currency.curr-abbr.
      assign
      v-desc     = substitute(("Валюта контракта - &1|" +
                              "Валюта текущего счета контракта для &2 - &3|" +
                              "Валюта текущего счета контракта для &4 - &5|" +
                              "{&abbr_rubli_firstshift}|" +
                              "Базовая валюта фирмы &6 - &7|" +
                              "Отказ от создания платежа"),
                                v-curr-abbr-contr,
                                tt-fin-doc.receiver-name, v-receiver-schet-curr-abbr,
                                tt-fin-doc.payer-name, v-payer-schet-curr-abbr,
                                (if p-fin-doc-type = {&income-cash}
                                or p-fin-doc-type = {&income-cashless}
                                or p-fin-doc-type = {&income-payoff}
                                then tt-fin-doc.receiver-name
                                else tt-fin-doc.payer-name), v-base-curr-abbr)
      v-buttons  = substitute("&1|&2|&3|0|&4|?",
                                buf_contract.curr-code,
                                v-receiver-schet-curr-code,
                                v-payer-schet-curr-code,
                                v-base-code)
      .
      run gbl/d-list.w (
                    input "b-sel"
                  , input "Выберите валюту платежа"
                  , input v-buttons
                  , input v-desc
                  , input "|":U
                  , input "":U /* ppresel-codes */
                  , output v-sel-curr) no-error .
     if error-status:error then undo, return error "exit".
      if v-sel-curr = {&question-mark} or v-sel-curr = "":U then do:
        message
        "Не выбрана валюта платежа"
        view-as alert-box error .
        return error "exit":U.
      end.
    end.
  end.
  assign
  tt-fin-doc.curr-code = integer(v-sel-curr)
  .
  if v-payer-schet-curr-code <>  tt-fin-doc.curr-code then do:
    assign
    tt-fin-doc.payer-bank-name  =  "":U
    tt-fin-doc.payer-bank-city  =  "":U
    tt-fin-doc.payer-dop1       =  "":U
    tt-fin-doc.payer-dop2       =  "":U
    tt-fin-doc.payer-bik        =  "":U
    tt-fin-doc.payer-code-schet =  0
    tt-fin-doc.payer-c-schet    =  "":U
    tt-fin-doc.payer-r-schet    =  "":U
    .
  end.
  if v-receiver-schet-curr-code <>  tt-fin-doc.curr-code then do:
    assign
    tt-fin-doc.receiver-bank-name  =  "":U
    tt-fin-doc.receiver-bank-city  =  "":U
    tt-fin-doc.receiver-dop1       =  "":U
    tt-fin-doc.receiver-dop2       =  "":U
    tt-fin-doc.receiver-code-schet =  0
    tt-fin-doc.receiver-c-schet    =  "":U
    tt-fin-doc.receiver-r-schet    =  "":U
    .
  end.
  CASE p-fin-doc-type :
    when {&income-cash} then do:
      assign
      tt-fin-doc.cel-nazn-code = buf_contract.cel-nazn-code-in-cash
      tt-fin-doc.an-uchet-code = buf_contract.an-uchet-code-in-cash
      tt-fin-doc.cor-acc       = buf_contract.cor-acc-in-cash
      tt-fin-doc.cor-acc1      = buf_contract.cor-acc1-in-cash
      .
    end.
    when {&expense-cash} then do:
      assign
      tt-fin-doc.cel-nazn-code = buf_contract.cel-nazn-code-out-cash
      tt-fin-doc.an-uchet-code = buf_contract.an-uchet-code-out-cash
      tt-fin-doc.cor-acc       = buf_contract.cor-acc-out-cash
      tt-fin-doc.cor-acc1      = buf_contract.cor-acc1-out-cash
      .
    end.
    when {&income-cashless} then do:
      assign
      tt-fin-doc.cel-nazn-code = buf_contract.cel-nazn-code-in
      tt-fin-doc.an-uchet-code = buf_contract.an-uchet-code-in
      tt-fin-doc.cor-acc       = buf_contract.cor-acc-in
      tt-fin-doc.cor-acc1      = buf_contract.cor-acc1-in
      .
    end.
    when {&expense-cashless} then do:
      assign
      tt-fin-doc.cel-nazn-code = buf_contract.cel-nazn-code-out
      tt-fin-doc.an-uchet-code = buf_contract.an-uchet-code-out
      tt-fin-doc.cor-acc       = buf_contract.cor-acc-out
      tt-fin-doc.cor-acc1      = buf_contract.cor-acc1-out
      .
    end.
    when {&income-payoff} then do:
      assign
      tt-fin-doc.cel-nazn-code = buf_contract.cel-nazn-code-in-payoff
      tt-fin-doc.an-uchet-code = buf_contract.an-uchet-code-in-payoff
      tt-fin-doc.cor-acc       = buf_contract.cor-acc-in-payoff
      tt-fin-doc.cor-acc1      = buf_contract.cor-acc1-in-payoff
      .
    end.
    when {&expense-payoff} then do:
      assign
      tt-fin-doc.cel-nazn-code = buf_contract.cel-nazn-code-out-payoff
      tt-fin-doc.an-uchet-code = buf_contract.an-uchet-code-out-payoff
      tt-fin-doc.cor-acc       = buf_contract.cor-acc-out-payoff
      tt-fin-doc.cor-acc1      = buf_contract.cor-acc1-out-payoff
      .
    end.

  END CASE.
  find first tt0-fin-doc.
  buffer-copy tt-fin-doc to tt0-fin-doc.
  return "":U.
end. /*doe*/


procedure get-bank-requisite :
define input parameter p-host-code like ub.fin-schet.host-code no-undo .
define input parameter p-code-schet like ub.fin-schet.code-schet no-undo .
define output parameter p-bank-name like ub.fin-bank.bank-name no-undo .
define output parameter p-bank-city like ub.fin-bank.bank-city no-undo .
define output parameter p-dop1      like ub.fin-schet.dop1 no-undo .
define output parameter p-dop2      like ub.fin-schet.dop2 no-undo .
define output parameter p-bik like ub.fin-bank.bik no-undo .
define output parameter p-c-schet like ub.fin-bank.cor-acc no-undo .
define output parameter p-r-schet like ub.fin-schet.r-schet no-undo .
define output parameter p-curr-code like ub.fin-schet.curr-code no-undo .
define output parameter p-curr-abbr  like ub.currency.curr-abbr no-undo .

define buffer buf_fin-schet for ub.fin-schet.
define buffer buf_fin-bank for ub.fin-bank.
define buffer buf_currency for ub.currency.

  do
  on error undo, return error
  :
      if p-fin-doc-type <> {&income-cashless}
      AND p-fin-doc-type <> {&expense-cashless} then return.
      find first buf_fin-schet no-lock where
                buf_fin-schet.code-schet = p-code-schet
            AND buf_fin-schet.host-code  = p-host-code no-error .
      if available buf_fin-schet then do:
        find first buf_fin-bank no-lock where
                  buf_fin-bank.host-code = p-host-code
               AND buf_fin-bank.code-bank = buf_fin-schet.code-bank no-error .
        if available buf_fin-bank then do:
          assign
          p-bank-name = buf_fin-bank.bank-name
          p-bank-city = buf_fin-bank.bank-city
          p-dop1     = buf_fin-schet.dop1
          p-dop2     = buf_fin-schet.dop2
          p-bik = buf_fin-bank.bik
          p-c-schet = buf_fin-bank.cor-acc
          p-r-schet = buf_fin-schet.r-schet
          p-curr-code = buf_fin-schet.curr-code
          .
          find first buf_currency no-lock where
                    buf_currency.curr-code = p-curr-code.
          assign
          p-curr-abbr = buf_currency.curr-abbr
          .
        end.
        else return error.
      end.
      else return error.
  end.

end procedure. /* get-bank-requisites */