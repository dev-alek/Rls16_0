/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

библиотека работы с атрибутами типов кассовых платежей

Автор: Бахтадзе Наталья Викторовна
Дата создания: 05/24/05
Author: Bakhtadze Natalya
Creation date: 05/24/05

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&if defined(cp-attr_i) = 0 &then

&glob cp-attr_i


/*----------------------------ВНИМАНИЕ!!!------------------------------------------------- */
/*значения атрибутов имеющих логический тип должны записываться в базу чисто как yes или no*/
/*все форматирование осуществлять на верхнем уровне                                        */

/* префиксы платежных крат для выгрузки в XML */
&scop bef-cp-attr-paycard-export-prefix paycard-export-prefix
&glob cp-attr-paycard-export-prefix '{&bef-cp-attr-paycard-export-prefix}':U
&scop type-cp-attr-paycard-export-prefix {&type-char}
&scop format-cp-attr-paycard-export-prefix "X(19)"
&scop label-cp-attr-paycard-export-prefix "Префиксы платежных карт (для выгрузки в XML)"
&scop tooltip-cp-attr-paycard-export-prefix "Префиксы платежных карт (для выгрузки в XML)"
/*область действия  - глобально или фирма или объект*/
&scop range-cp-attr-paycard-export-prefix  ~{&bef-global-int~}
&scop user-can-edit-cp-attr-paycard-export-prefix true
&scop output-display-cp-attr-paycard-export-prefix true
&scop other-cp-attr-paycard-export-prefix 'spr=paycard-prefix':u
&scop news-cp-attr-paycard-export-prefix true
&scop hist-cp-attr-paycard-export-prefix true
&scop manual-edit-cp-attr-paycard-export-prefix 1
&scop batch-edit-cp-attr-paycard-export-prefix  0


/* номер группы кассового платежа */
&scop bef-cp-attr-grp-code grp-code
&glob cp-attr-grp-code '{&bef-cp-attr-grp-code}':U
&scop type-cp-attr-grp-code {&type-char}
&scop format-cp-attr-grp-code "X(45)"
&scop label-cp-attr-grp-code "Группа платежа"
&scop tooltip-cp-attr-grp-code "Группа платежа"
/*область действия  - глобально или фирма или объект*/
&scop range-cp-attr-grp-code  ~{&bef-global-int~}
&scop user-can-edit-cp-attr-grp-code true
&scop output-display-cp-attr-grp-code true
&scop other-cp-attr-grp-code 'spr=grp-code':u
&scop news-cp-attr-grp-code true
&scop hist-cp-attr-grp-code true
&scop manual-edit-cp-attr-grp-code 1
&scop batch-edit-cp-attr-grp-code  0


/* используется */
&scop bef-cp-attr-is-use is-use
&glob cp-attr-is-use '{&bef-cp-attr-is-use}':U
&scop type-cp-attr-is-use {&type-char}
&scop format-cp-attr-is-use "X(255)"
&scop label-cp-attr-is-use "Используется"
&scop tooltip-cp-attr-is-use "Используется"
/*область действия  - глобально или фирма или объект*/
&scop range-cp-attr-is-use  ~{&bef-global-host-object-int~}
&scop user-can-edit-cp-attr-is-use true
&scop output-display-cp-attr-is-use true
&scop other-cp-attr-is-use 'spr=is-use':u
&scop news-cp-attr-is-use true
&scop hist-cp-attr-is-use true
&scop manual-edit-cp-attr-is-use 1
&scop batch-edit-cp-attr-is-use  0


/* префиксы платежных карт  */
&scop bef-cp-attr-paycard-all-prefix paycard-all-prefix
&glob cp-attr-paycard-all-prefix '{&bef-cp-attr-paycard-all-prefix}':U
&scop type-cp-attr-paycard-all-prefix {&type-char}
&scop format-cp-attr-paycard-all-prefix "X(19)"
&scop label-cp-attr-paycard-all-prefix "Префиксы платежных карт (для разбора чеков и т.д.)"
&scop tooltip-cp-attr-paycard-all-prefix "Префиксы платежных карт (для разбора чеков и т.д.)"
/*область действия  - глобально или фирма или объект*/
&scop range-cp-attr-paycard-all-prefix  ~{&bef-global-int~}
&scop user-can-edit-cp-attr-paycard-all-prefix true
&scop output-display-cp-attr-paycard-all-prefix true
&scop other-cp-attr-paycard-all-prefix 'spr=paycard-prefix':u
&scop news-cp-attr-paycard-all-prefix true
&scop hist-cp-attr-paycard-all-prefix true
&scop manual-edit-cp-attr-paycard-all-prefix 1
&scop batch-edit-cp-attr-paycard-all-prefix  0


/* префиксы платежных карт для редактирования ( в чеке)  */
&scop bef-cp-attr-paycard-edit-prefix paycard-edit-prefix
&glob cp-attr-paycard-edit-prefix '{&bef-cp-attr-paycard-edit-prefix}':U
&scop type-cp-attr-paycard-edit-prefix {&type-char}
&scop format-cp-attr-paycard-edit-prefix "X(19)"
&scop label-cp-attr-paycard-edit-prefix "Префиксы платежных карт, разрешенных для редактирования"
&scop tooltip-cp-attr-paycard-edit-prefix "Префиксы платежных карт, разрешенных для редактировани"
/*область действия  - глобально или фирма или объект*/
&scop range-cp-attr-paycard-edit-prefix  ~{&bef-global-int~}
&scop user-can-edit-cp-attr-paycard-edit-prefix true
&scop output-display-cp-attr-paycard-edit-prefix true
&scop other-cp-attr-paycard-edit-prefix 'spr=paycard-prefix':u
&scop news-cp-attr-paycard-edit-prefix true
&scop hist-cp-attr-paycard-edit-prefix true
&scop manual-edit-cp-attr-paycard-edit-prefix 1
&scop batch-edit-cp-attr-paycard-edit-prefix  0


/* Формировать КМ-3 по чекам возврата  */
&scop bef-cp-attr-form_km3 form_km3
&glob cp-attr-form_km3 '{&bef-cp-attr-form_km3}':U
&scop type-cp-attr-form_km3 {&type-log}
&scop format-cp-attr-form_km3 "+/-"
&scop label-cp-attr-form_km3 "Формировать КМ-3 по чекам возврата"
&scop tooltip-cp-attr-form_km3 "Формировать КМ-3 по чекам возврата"
/*область действия  - глобально или фирма или объект*/
&scop range-cp-attr-form_km3  ~{&bef-global-int~}
&scop user-can-edit-cp-attr-form_km3 true
&scop output-display-cp-attr-form_km3 true
&scop other-cp-attr-form_km3 '':u
&scop news-cp-attr-form_km3 false
&scop hist-cp-attr-form_km3 true
&scop manual-edit-cp-attr-form_km3 1
&scop batch-edit-cp-attr-form_km3  0

/* Оплата баллами Малина  */
&scop bef-cp-attr-bal_malina bal_malina
&glob cp-attr-bal_malina '{&bef-cp-attr-bal_malina}':U
&scop type-cp-attr-bal_malina {&type-log}
&scop format-cp-attr-bal_malina "+/-"
&scop label-cp-attr-bal_malina "Оплата баллами Малина"
&scop tooltip-cp-attr-bal_malina "Оплата баллами Малина"
/*область действия  - глобально или фирма или объект*/
&scop range-cp-attr-bal_malina  ~{&bef-global-int~}
&scop user-can-edit-cp-attr-bal_malina true
&scop output-display-cp-attr-bal_malina true
&scop other-cp-attr-bal_malina '':u
&scop news-cp-attr-bal_malina false
&scop hist-cp-attr-bal_malina true
&scop manual-edit-cp-attr-bal_malina 1
&scop batch-edit-cp-attr-bal_malina  0

/* Максимальный % порог от суммы  */
&scop bef-cp-attr-max_proc_sum max_proc_sum
&glob cp-attr-max_proc_sum '{&bef-cp-attr-max_proc_sum}':U
&scop type-cp-attr-max_proc_sum {&type-dec}
&scop format-cp-attr-max_proc_sum ">>9.99"
&scop label-cp-attr-max_proc_sum "Максимальный % порог от суммы"
&scop tooltip-cp-attr-max_proc_sum "Максимальный % порог от суммы"
/*область действия  - глобально или фирма или объект*/
&scop range-cp-attr-max_proc_sum  ~{&bef-global-int~}
&scop user-can-edit-cp-attr-max_proc_sum true
&scop output-display-cp-attr-max_proc_sum true
&scop other-cp-attr-max_proc_sum '':u
&scop news-cp-attr-max_proc_sum true
&scop hist-cp-attr-max_proc_sum true
&scop manual-edit-cp-attr-max_proc_sum 1
&scop batch-edit-cp-attr-max_proc_sum  0

/* Маска карты\купона  */
&scop bef-cp-attr-mask_card_kup mask_card_kup
&glob cp-attr-mask_card_kup '{&bef-cp-attr-mask_card_kup}':U
&scop type-cp-attr-mask_card_kup {&type-char}
&scop format-cp-attr-mask_card_kup "x(129)"
&scop label-cp-attr-mask_card_kup "Маска карты\купона"
&scop tooltip-cp-attr-mask_card_kup "Маска карты\купона"
/*область действия  - глобально или фирма или объект*/
&scop range-cp-attr-mask_card_kup  ~{&bef-global-int~}
&scop user-can-edit-cp-attr-mask_card_kup true
&scop output-display-cp-attr-mask_card_kup true
&scop other-cp-attr-mask_card_kup '':u
&scop news-cp-attr-mask_card_kup true
&scop hist-cp-attr-mask_card_kup true
&scop manual-edit-cp-attr-mask_card_kup 1
&scop batch-edit-cp-attr-mask_card_kup  0
/* Создание дополнительного документа */
&scop bef-cp-attr-dop-doc dop-doc
&glob cp-attr-dop-doc '{&bef-cp-attr-dop-doc}':U
&scop type-cp-attr-dop-doc {&type-char}
&scop format-cp-attr-dop-doc "X(255)"
&scop label-cp-attr-dop-doc "Дополнительный документ"
&scop tooltip-cp-attr-dop-doc "Дополнительный документ"
/*область действия  - глобально или фирма или объект*/
&scop range-cp-attr-dop-doc ~{&bef-global-int~}
&scop user-can-edit-cp-attr-dop-doc true
&scop output-display-cp-attr-dop-doc true
&scop other-cp-attr-dop-doc 'spr=dop-doc':u
&scop news-cp-attr-dop-doc true
&scop hist-cp-attr-dop-doc true
&scop manual-edit-cp-attr-dop-doc 1
&scop batch-edit-cp-attr-dop-doc 0


/* сюда добавлять новые параметры */
&glob cp-attr-list '{&bef-cp-attr-paycard-export-prefix}~
,{&bef-cp-attr-grp-code}~
,{&bef-cp-attr-is-use}~
,{&bef-cp-attr-dop-doc}~
,{&bef-cp-attr-paycard-all-prefix}~
,{&bef-cp-attr-paycard-edit-prefix}~
,{&bef-cp-attr-form_km3}~
,{&bef-cp-attr-bal_malina}~
,{&bef-cp-attr-max_proc_sum}~
,{&bef-cp-attr-mask_card_kup}~
':u

/* ------------------------------------------------------------------- */
&scop attr-temp-code ~
  when ~{&~{&attr-code~}~} then do: ~
    assign ~
    p-tooltip = ~{&tooltip-~{&attr-code~}~} ~
    p-label = ~{&label-~{&attr-code~}~} . ~
  end.

&scop attr-temp-full-code ~
  when ~{&~{&attr-code~}~} then do: ~
    assign ~
    p-label = ~{&label-~{&attr-code~}~} ~
    p-type = ~{&type-~{&attr-code~}~}  ~
    p-format = ~{&format-~{&attr-code~}~} ~
    p-label = ~{&label-~{&attr-code~}~} ~
    p-range = ~{&range-~{&attr-code~}~} ~
    p-user-can-edit  = ~{&user-can-edit-~{&attr-code~}~} ~
    p-output-display = ~{&output-display-~{&attr-code~}~} ~
    p-other = ~{&other-~{&attr-code~}~}  ~
    . ~
  end.

&scop attr-news-code ~
  when ~{&~{&attr-code~}~} then do: ~
    assign ~
    p-news = ~{&news-~{&attr-code~}~}. ~
  end.

&scop attr-hist-code ~
  when ~{&~{&attr-code~}~} then do: ~
    assign ~
    p-hist = ~{&hist-~{&attr-code~}~}. ~
  end.


&scop attr-manual-edit-code ~
  when ~{&~{&attr-code~}~} then do: ~
    assign ~
    p-section-num = ~{&manual-edit-~{&attr-code~}~}. ~
  end.


&scop attr-batch-edit-code ~
  when ~{&~{&attr-code~}~} then do: ~
    assign ~
    p-section-num = ~{&batch-edit-~{&attr-code~}~}. ~
  end.


{ gbl/cur-time.i }
procedure cp-attr-code :

  do
  on error undo, return error
  :
    define input  parameter p-code           as character no-undo . /* код атрибута */
    define output parameter p-type           as character no-undo . /* тип атрибута */
    define output parameter p-format         as character no-undo . /* формат атрибута */
    define output parameter p-label          as character no-undo . /* лабел атрибута */
    define output parameter p-range          as integer   no-undo . /*области действия атрибута*/
    define output parameter p-user-can-edit  as logical   no-undo . /* пользователь может изменять в броусе */
    define output parameter p-output-display as logical   no-undo . /* виден в броусе */
    define output parameter p-other          as character no-undo . /* еще чего - нибудь */

    case p-code :
      &scop attr-code cp-attr-paycard-export-prefix
      {&attr-temp-full-code}
      &scop attr-code cp-attr-grp-code
      {&attr-temp-full-code}
      &scop attr-code cp-attr-is-use
      {&attr-temp-full-code}
      &scop attr-code cp-attr-dop-doc
      {&attr-temp-full-code}
      &scop attr-code cp-attr-paycard-all-prefix
      {&attr-temp-full-code}
      &scop attr-code cp-attr-paycard-edit-prefix
      {&attr-temp-full-code}
      &scop attr-code cp-attr-form_km3
      {&attr-temp-full-code}
      &scop attr-code cp-attr-bal_malina
      {&attr-temp-full-code}
      &scop attr-code cp-attr-max_proc_sum
      {&attr-temp-full-code}
      &scop attr-code cp-attr-mask_card_kup
      {&attr-temp-full-code}
      /* сюда добавлять новые параметры */
      otherwise do:
        undo, return error substitute("неизвестный атрибут типа кассового платежа &1", p-code ).
      end.
    end.
  end.
end procedure.

procedure cp-attr-tooltip :

  do
  on error undo, return error
  :

    define input  parameter p-code    as character no-undo .
    define output parameter p-tooltip as character no-undo .
    define output parameter p-label   as character no-undo .

    case p-code :
      &scop attr-code cp-attr-paycard-export-prefix
      {&attr-temp-code}
      &scop attr-code cp-attr-grp-code
      {&attr-temp-code}
      &scop attr-code cp-attr-is-use
      {&attr-temp-code}
      &scop attr-code cp-attr-dop-doc
      {&attr-temp-code}
      &scop attr-code cp-attr-paycard-all-prefix
      {&attr-temp-code}
      &scop attr-code cp-attr-paycard-edit-prefix
      {&attr-temp-code}
      &scop attr-code cp-attr-form_km3
      {&attr-temp-code}
      &scop attr-code cp-attr-bal_malina
      {&attr-temp-code}
      &scop attr-code cp-attr-max_proc_sum
      {&attr-temp-code}
      &scop attr-code cp-attr-mask_card_kup
      {&attr-temp-code}


      /* сюда добавлять новые параметры */
      otherwise do:
        undo, return error substitute("неизвестный атрибут типа кассового платежа &1", p-code) .
      end.
    end.
  end.

end procedure.


procedure cp-attr-value :

  do
  on error undo, return error
  :
    define input parameter p-cdpay-code   like ub.cash-pay-attr.cdpay-code     no-undo .
    define input parameter p-curr-code    like ub.cash-pay-attr.curr-code      no-undo .
    define input parameter p-host-code    like ub.cash-pay-attr.host-code      no-undo .
    define input parameter p-obj-type     like ub.cash-pay-attr.obj-type       no-undo .
    define input parameter p-obj-code     like ub.cash-pay-attr.obj-code       no-undo .
    define input  parameter p-code        like ub.cash-pay-attr.attr-code      no-undo .
    define output parameter p-value       like ub.cash-pay-attr.attr-value    no-undo .
    define output parameter p-type        as character no-undo .

    define buffer buf_cash-pay-attr for ub.cash-pay-attr .

    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-range          as integer   no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .

    run cp-attr-code in this-procedure
      (input  p-code           /* p-code           */
      ,output p-type           /* p-type           */
      ,output v-format         /* p-format         */
      ,output v-label          /* p-label          */
      ,output v-range          /* p-range          */
      ,output v-user-can-edit  /* p-user-can-edit  */
      ,output v-output-display /* p-output-display */
      ,output v-other          /* p-other          */
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.

    find first buf_cash-pay-attr no-lock
      where buf_cash-pay-attr.cdpay-code = p-cdpay-code
        and buf_cash-pay-attr.curr-code  = p-curr-code
        and buf_cash-pay-attr.host-code  = p-host-code
        and buf_cash-pay-attr.obj-type   = p-obj-type
        and buf_cash-pay-attr.obj-code   = p-obj-code
        and buf_cash-pay-attr.attr-code  = p-code
      no-error .
    if avail buf_cash-pay-attr then do:
      assign
        p-value =  buf_cash-pay-attr.attr-value
      .
    end.
    else do:
      assign
        p-value = if p-type = {&type-log} then "no":U else ""
      .
    end.
  end.

end procedure.


procedure cp-attr-write :

  do
  on error undo, return error
  :
    define input parameter p-cdpay-code   like ub.cash-pay-attr.cdpay-code     no-undo .
    define input parameter p-curr-code    like ub.cash-pay-attr.curr-code      no-undo .
    define input parameter p-host-code    like ub.cash-pay-attr.host-code      no-undo .
    define input parameter p-obj-type     like ub.cash-pay-attr.obj-type       no-undo .
    define input parameter p-obj-code     like ub.cash-pay-attr.obj-code       no-undo .
    define input parameter p-code     like ub.cash-pay-attr.attr-code  no-undo .
    define input parameter p-value    like ub.cash-pay-attr.attr-value no-undo .

    define buffer buf_cash-pay-attr for ub.cash-pay-attr .
    define buffer last_cash-pay-attr for ub.cash-pay-attr .

    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-range          as integer   no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .

    run cp-attr-code in this-procedure
      (input  p-code           /* p-code           */
      ,output v-type           /* p-type           */
      ,output v-format         /* p-format         */
      ,output v-label          /* p-label          */
      ,output v-range          /* p-range          */
      ,output v-user-can-edit  /* p-user-can-edit  */
      ,output v-output-display /* p-output-display */
      ,output v-other          /* p-other          */
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.

    find first buf_cash-pay-attr exclusive-lock
      where buf_cash-pay-attr.cdpay-code = p-cdpay-code
        and buf_cash-pay-attr.curr-code  = p-curr-code
        and buf_cash-pay-attr.host-code  = p-host-code
        and buf_cash-pay-attr.obj-type   = p-obj-type
        and buf_cash-pay-attr.obj-code   = p-obj-code
        and buf_cash-pay-attr.attr-code = p-code
      no-error .
    if not available buf_cash-pay-attr then do:
      create buf_cash-pay-attr .
      assign
      buf_cash-pay-attr.cdpay-code = p-cdpay-code
      buf_cash-pay-attr.curr-code  = p-curr-code
      buf_cash-pay-attr.host-code  = p-host-code
      buf_cash-pay-attr.obj-type   = p-obj-type
      buf_cash-pay-attr.obj-code   = p-obj-code
      buf_cash-pay-attr.attr-code = p-code
      .
    end.
    assign
      buf_cash-pay-attr.attr-value = p-value
    .
    release buf_cash-pay-attr no-error .
    if error-status:error then do:
      undo, return error return-value .
    end.
  end.

end procedure.


procedure cp-attr-exist :

  do
  on error undo, return error
  :
    define input parameter p-cdpay-code   like ub.cash-pay-attr.cdpay-code     no-undo .
    define input parameter p-curr-code    like ub.cash-pay-attr.curr-code      no-undo .
    define input parameter p-host-code    like ub.cash-pay-attr.host-code      no-undo .
    define input parameter p-obj-type     like ub.cash-pay-attr.obj-type       no-undo .
    define input parameter p-obj-code     like ub.cash-pay-attr.obj-code       no-undo .

    define input parameter p-code     like ub.cash-pay-attr.attr-code  no-undo .
    define output parameter p-exist   as logical  no-undo .

    define buffer buf_cash-pay-attr for ub.cash-pay-attr .

    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-range          as integer   no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .

    run cp-attr-code in this-procedure
      (input  p-code           /* p-code           */
      ,output v-type           /* p-type           */
      ,output v-format         /* p-format         */
      ,output v-label          /* p-label          */
      ,output v-range          /* p-range          */
      ,output v-user-can-edit  /* p-user-can-edit  */
      ,output v-output-display /* p-output-display */
      ,output v-other          /* p-other          */
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.

    find first buf_cash-pay-attr exclusive-lock
      where buf_cash-pay-attr.cdpay-code = p-cdpay-code
        and buf_cash-pay-attr.curr-code  = p-curr-code
        and buf_cash-pay-attr.host-code  = p-host-code
        and buf_cash-pay-attr.obj-type   = p-obj-type
        and buf_cash-pay-attr.obj-code   = p-obj-code
        and buf_cash-pay-attr.attr-code = p-code
      no-error .

    if  available buf_cash-pay-attr then do:
      p-exist = yes.
    end.
  end.

end procedure.

procedure cp-attr-delete :
  do
  on error undo, return error
  :
    define input parameter p-cdpay-code   like ub.cash-pay-attr.cdpay-code     no-undo .
    define input parameter p-curr-code    like ub.cash-pay-attr.curr-code      no-undo .
    define input parameter p-host-code    like ub.cash-pay-attr.host-code      no-undo .
    define input parameter p-obj-type     like ub.cash-pay-attr.obj-type       no-undo .
    define input parameter p-obj-code     like ub.cash-pay-attr.obj-code       no-undo .

    define input parameter p-code     like ub.cash-pay-attr.attr-code  no-undo .
    define output parameter p-deleted  as logical no-undo.

    define buffer buf_cash-pay-attr for ub.cash-pay-attr .

    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-range          as integer   no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .

    run cp-attr-code in this-procedure
      (input  p-code           /* p-code           */
      ,output v-type           /* p-type           */
      ,output v-format         /* p-format         */
      ,output v-label          /* p-label          */
      ,output v-range          /* p-range          */
      ,output v-user-can-edit  /* p-user-can-edit  */
      ,output v-output-display /* p-output-display */
      ,output v-other          /* p-other          */
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_cash-pay-attr exclusive-lock
      where buf_cash-pay-attr.cdpay-code = p-cdpay-code
        and buf_cash-pay-attr.curr-code  = p-curr-code
        and buf_cash-pay-attr.host-code  = p-host-code
        and buf_cash-pay-attr.obj-type   = p-obj-type
        and buf_cash-pay-attr.obj-code   = p-obj-code
        and buf_cash-pay-attr.attr-code = p-code
      no-error NO-WAIT.
    if not available buf_cash-pay-attr then do:
      p-deleted = no.
    end.
    else do:
      delete buf_cash-pay-attr no-error .
      if error-status:error then do:
        undo, return error return-value .
      end.
      p-deleted = yes.
    end.
  end.

end procedure.


procedure cp-attr-news :

  do
  on error undo, return error
  :
    define input  parameter p-code           as character no-undo . /* код атрибута */
    define output parameter p-news           as logical   no-undo . /* ходит в новости */

    case p-code :
      &scop attr-code cp-attr-paycard-export-prefix
      {&attr-news-code}
      &scop attr-code cp-attr-grp-code
      {&attr-news-code}
      &scop attr-code cp-attr-is-use
      {&attr-news-code}
      &scop attr-code cp-attr-dop-doc
      {&attr-news-code}
      &scop attr-code cp-attr-paycard-all-prefix
      {&attr-news-code}
      &scop attr-code cp-attr-paycard-edit-prefix
      {&attr-news-code}
      &scop attr-code cp-attr-form_km3
      {&attr-news-code}
      &scop attr-code cp-attr-bal_malina
      {&attr-news-code}
      &scop attr-code cp-attr-max_proc_sum
      {&attr-news-code}
      &scop attr-code cp-attr-mask_card_kup
      {&attr-news-code}


      /* сюда добавлять новые параметры */

      otherwise do:
        p-news = no.
      end.
    end.
  end.
end procedure.


procedure cp-attr-hist :

  do
  on error undo, return error
  :
    define input  parameter p-code           as character no-undo . /* код атрибута */
    define output parameter p-hist           as logical   no-undo . /* ходит в историю */

    case p-code :
      &scop attr-code cp-attr-paycard-export-prefix
      {&attr-hist-code}
      &scop attr-code cp-attr-paycard-all-prefix
      {&attr-hist-code}
      &scop attr-code cp-attr-paycard-edit-prefix
      {&attr-hist-code}
      &scop attr-code cp-attr-form_km3
      {&attr-hist-code}
      &scop attr-code cp-attr-bal_malina
      {&attr-hist-code}
      &scop attr-code cp-attr-max_proc_sum
      {&attr-hist-code}
      &scop attr-code cp-attr-mask_card_kup
      {&attr-hist-code}


      /* сюда добавлять новые параметры */


      otherwise do:
        p-hist = no.
      end.
    end.
  end.
end procedure.

&if "{1}" = "interface" &then

procedure paycard-prefix :
define input parameter p-cdpay-code like ub.cash-pay-attr.cdpay-code no-undo .
define input parameter p-curr-code like ub.cash-pay-attr.curr-code no-undo .
define input parameter p-host-code like ub.cash-pay-attr.host-code no-undo .
define input parameter p-obj-type like ub.cash-pay-attr.obj-type no-undo .
define input parameter p-obj-code like ub.cash-pay-attr.obj-code no-undo .
define input-output parameter p-value as character no-undo .
define output parameter p-setted as logical no-undo .
DEFINE VARIABLE v-value as character no-undo .
define variable v-codes as character no-undo .
define variable v-labels as character no-undo .
define variable v-ok as logical no-undo .


  do
  on error undo, return error
  :

    assign
    v-value = p-value
    .

    run ref/cpa-pcep.w (
                   input parparentproc
                  ,input p-cdpay-code
                  ,input p-curr-code
                  ,input p-host-code
                  ,input p-obj-type
                  ,input p-obj-code
                  ,input-output v-value
                  ,output v-ok
                   ) no-error .

    if
    v-ok and
    p-value <> v-value and v-value <> ? and not error-status:error then do:
      assign
      p-setted = yes
      p-value = v-value
      .
    end.
  end.

end procedure. /* paycard-export-prefix */

procedure is-use :
define input parameter p-cdpay-code like ub.cash-pay-attr.cdpay-code no-undo .
define input parameter p-curr-code like ub.cash-pay-attr.curr-code no-undo .
define input parameter p-host-code like ub.cash-pay-attr.host-code no-undo .
define input parameter p-obj-type like ub.cash-pay-attr.obj-type no-undo .
define input parameter p-obj-code like ub.cash-pay-attr.obj-code no-undo .
define input-output parameter p-value as character no-undo .
define output parameter p-setted as logical no-undo .
DEFINE VARIABLE v-value as character no-undo .
define variable v-codes as character no-undo .
define variable v-labels as character no-undo .
define variable v-ok as logical no-undo .


  do
  on error undo, return error
  :

    assign
    v-value = p-value
    .
    if p-obj-type = {&stock} then do:
      message
      substitute("Нельзя задать атрибут для объекта типа &1", p-obj-type)
      view-as alert-box error .
      return error.
    end.
    run ref/cpa-isus.w (
                   input parparentproc
                  ,input p-cdpay-code
                  ,input p-curr-code
                  ,input p-host-code
                  ,input p-obj-type
                  ,input p-obj-code
                  ,input-output v-value
                  ,output v-ok
                   ) no-error .

    if
    v-ok and
    p-value <> v-value and v-value <> ? and not error-status:error then do:
      assign
      p-setted = yes
      p-value = v-value
      .
    end.
  end.

end procedure. /* is-use */


procedure grp-code :
define input parameter p-cdpay-code like ub.cash-pay-attr.cdpay-code no-undo .
define input parameter p-curr-code like ub.cash-pay-attr.curr-code no-undo .
define input parameter p-host-code like ub.cash-pay-attr.host-code no-undo .
define input parameter p-obj-type like ub.cash-pay-attr.obj-type no-undo .
define input parameter p-obj-code like ub.cash-pay-attr.obj-code no-undo .
define input-output parameter p-value as character no-undo .
define output parameter p-setted as logical no-undo .
DEFINE VARIABLE v-value as character no-undo .
define variable v-codes as character no-undo .
define variable v-labels as character no-undo .
define variable v-ok as logical no-undo .


  do
  on error undo, return error
  :

    assign
    v-value = p-value
    .

    run ref/cpa-grp.w (
                   input parparentproc
                  ,input p-cdpay-code
                  ,input p-curr-code
                  ,input p-host-code
                  ,input p-obj-type
                  ,input p-obj-code
                  ,input-output v-value
                  ,output v-ok
                   ) no-error .

    if
    v-ok and
    p-value <> v-value and v-value <> ? and not error-status:error then do:
      assign
      p-setted = yes
      p-value = v-value
      .
    end.
  end.

end procedure. /* is-use */

/*секция pop-up меню при ручном редактировании */

procedure cp-attr-manual-edit :

do on error undo, return error return-value
  :

  define input  parameter p-code           as character no-undo . /* код атрибута */
  define output parameter p-section-num    as integer no-undo .

    case p-code :
      &scop attr-code cp-attr-paycard-export-prefix
      {&attr-manual-edit-code}
      &scop attr-code cp-attr-grp-code
      {&attr-manual-edit-code}
      &scop attr-code cp-attr-is-use
      {&attr-manual-edit-code}
      &scop attr-code cp-attr-dop-doc
      {&attr-manual-edit-code}
      &scop attr-code cp-attr-paycard-all-prefix
      {&attr-manual-edit-code}
      &scop attr-code cp-attr-form_km3
      {&attr-manual-edit-code}
      &scop attr-code cp-attr-bal_malina
      {&attr-manual-edit-code}
      &scop attr-code cp-attr-max_proc_sum
      {&attr-manual-edit-code}
      &scop attr-code cp-attr-mask_card_kup
      {&attr-manual-edit-code}



      /* сюда добавлять новые параметры */
      otherwise do:
        undo, return error substitute("неизвестный атрибут типа кассового платежа &1", p-code ).
      end.
    end.
  end.
end procedure.


procedure cp-attr-batch-edit :

do
  on error undo, return error
  :

  define input  parameter p-code           as character no-undo . /* код атрибута */
  define output parameter p-section-num    as integer no-undo .

    case p-code :
      &scop attr-code cp-attr-paycard-export-prefix
      {&attr-batch-edit-code}
      &scop attr-code cp-attr-grp-code
      {&attr-batch-edit-code}
      &scop attr-code cp-attr-is-use
      {&attr-batch-edit-code}
      &scop attr-code cp-attr-dop-doc
      {&attr-batch-edit-code}
      &scop attr-code cp-attr-form_km3
      {&attr-batch-edit-code}
      &scop attr-code cp-attr-bal_malina
      {&attr-batch-edit-code}
      &scop attr-code cp-attr-max_proc_sum
      {&attr-batch-edit-code}
      &scop attr-code cp-attr-mask_card_kup
      {&attr-batch-edit-code}


      /* сюда добавлять новые параметры */
      otherwise do:
        undo, return error substitute("неизвестный атрибут типа кассового платежа &1", p-code ).
      end.
    end.
  end.
end procedure.


procedure dop-doc :
define input parameter p-cdpay-code like ub.cash-pay-attr.cdpay-code no-undo .
define input parameter p-curr-code like ub.cash-pay-attr.curr-code no-undo .
define input parameter p-host-code like ub.cash-pay-attr.host-code no-undo .
define input parameter p-obj-type like ub.cash-pay-attr.obj-type no-undo .
define input parameter p-obj-code like ub.cash-pay-attr.obj-code no-undo .
define input-output parameter p-value as character no-undo .
define output parameter p-setted as logical no-undo .
DEFINE VARIABLE v-value as character no-undo .
define variable v-codes as character no-undo .
define variable v-labels as character no-undo .
define variable v-ok as logical no-undo .


  do on error undo, return error:
        
    assign
    v-value = p-value.
    
    run ref/cpa-dop-doc.w (
                   input parparentproc
                  ,input p-cdpay-code
                  ,input p-curr-code
                  ,input p-host-code
                  ,input p-obj-type
                  ,input p-obj-code
                  ,input-output v-value
                  ,output v-ok
                   ) no-error .

    if
    v-ok and
    p-value <> v-value and v-value <> ? and not error-status:error then do:
      assign
      p-setted = yes
      p-value = v-value
      .
    end.
  end.

end procedure. /* dop-doc */

&endif
/*of interface*/
&endif

/* $Workfile$ e n d */