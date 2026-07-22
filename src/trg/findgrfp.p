block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Стандартный граф переходов финансовых документов по параметрам

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/18/03
Author: Bakhtadze Natalya
Creation date: 11/18/03

ГРАФ ПЕРЕХОДОВ ОПИСАН В ФАЙЛЕ findgraf.p
*/

define input  parameter p-parent-handle     as handle no-undo .
define input  parameter p-fin-doc-type      like ub.fin-doc.fin-doc-type     no-undo . /*тип документа*/
define input  parameter p-fin-ext-doc-type  like ub.fin-doc.fin-ext-doc-type no-undo . /*расширенный тип документа*/
define input  parameter p-status-current    like ub.fin-doc.status_          no-undo . /*статус документа*/
define input  parameter p-mode              as   character                   no-undo . /*режим обработки документа*/
define input  parameter p-author            as   character                   no-undo .
define input  parameter p-status-date       like ub.fin-doc.fact-date        no-undo . /*дата перевода статуса*/
define output parameter p-status_           like ub.fin-doc.status_          no-undo . /*статус в который документ перейдет*/
define output parameter p-ask-date          as logical                       no-undo . /*выдавать запрос даты смены статуса*/
define output parameter p-ask-message       as character                     no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Стандартный граф переходов финансовых документов по параметрам".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }


{ trg/findgrfp.i
&income-cash-new  = " run income-cash-new             . "
&income-cash-permitted  = " run income-cash-permitted       . "
&expense-cash-new  = " run expense-cash-new             . "
&expense-cash-permitted  = " run expense-cash-permitted       . "
&income-cashless-new  = " run income-cashless-new             . "
&income-cashless-permitted  = " run income-cashless-permitted       . "
&income-cashless-bank  = " run income-cashless-bank       . "
&expense-cashless-new  = " run expense-cashless-new             . "
&expense-cashless-permitted  = " run expense-cashless-permitted       . "
&expense-cashless-bank  = " run expense-cashless-bank       . "
&expense-cashless-rejected  = " run expense-cashless-rejected       . "
&income-payoff-new  = " run income-payoff-new             . "
&income-payoff-permitted  = " run income-payoff-permitted       . "
&expense-payoff-new  = " run expense-payoff-new             . "
&expense-payoff-permitted  = " run expense-payoff-permitted       . "
}

procedure income-cash-new :
/*приход наличные новый*/
case p-mode:
  when {&open-doc} then do:
    return error substitute ('Платеж открыт.').
  end.
  when {&close-doc} then do:
     assign
     p-status_ = {&fin-permitted}
     p-ask-message = "Закрыть платеж(и)" + {&new-line} +
                     "(закончить редактирование ПРИХОДНОГО КАССОВОГО ОРДЕРА и разрешить прием наличных средств)?"
     .
  end.
  otherwise do:
    return error substitute ('Недопустима операция &1 для платежа с атрибутами тип-статус &2-&3.', p-mode, p-fin-doc-type, p-status-current).
  end.
end case.
end procedure.

procedure income-cash-permitted:
/*приход наличные разр*/
case p-mode:
  when {&open-doc} then do:
    assign
    p-status_ = {&fin-new}
    p-ask-message = "Открыть платеж(и)" + {&new-line} +
                    "(отменить разрешение на прием наличных средств  и разрешить редактирование ПРИХОДНОГО КАССОВОГО ОРДЕРА)?"
    .
  end.
  when {&close-doc} then do:
    assign
    p-status_ = {&fin-fact}
    p-ask-message = "Закрыть платеж(и)" + {&new-line} +
                    "(подтвердить факт приема наличных средств)?"
    .
  end.
  otherwise do:
    return error substitute ('Недопустима операция &1 для платежа с атрибутами тип-статус &2-&3.', p-mode, p-fin-doc-type, p-status-current).
  end.
end case.
end procedure.

procedure expense-cash-new :
/*расход наличные новый*/
case p-mode:
  when {&open-doc} then do:
    return error substitute ('Платеж открыт.').
  end.
  when {&close-doc} then do:
     assign
     p-status_ = {&fin-permitted}
     p-ask-message = "Закрыть платеж(и)" + {&new-line} +
                     "(закончить редактирование РАСХОДНОГО КАССОВОГО ОРДЕРА и разрешить выдачу наличных средств)?"
     .
  end.
  otherwise do:
    return error substitute ('Недопустима операция &1 для платежа с атрибутами тип-статус &2-&3.', p-mode, p-fin-doc-type, p-status-current).
  end.
end case.
end procedure.

procedure expense-cash-permitted:
/*расход наличные разр*/
case p-mode:
  when {&open-doc} then do:
    assign
    p-status_ = {&fin-new}
    p-ask-message = "Открыть платеж(и)" + {&new-line} +
                    "(отменить разрешение на расход наличных средств  и разрешить редактирование РАСХОДНОГО КАССОВОГО ОРДЕРА)?"
    .
  end.
  when {&close-doc} then do:
    assign
    p-status_ = {&fin-fact}
    p-ask-message = "Закрыть платеж(и)" + {&new-line} +
                    "(подтвердить факт расхода наличных средств)?"
    .
  end.
  otherwise do:
    return error substitute ('Недопустима операция &1 для платежа с атрибутами тип-статус &2-&3.', p-mode, p-fin-doc-type, p-status-current).
  end.
end case.
end procedure.



procedure income-cashless-new :
/*приход безнал новый*/
case p-mode:
  when {&open-doc} then do:
    return error substitute ('Платеж открыт.').
  end.
  when {&close-doc} then do:
    CASE p-fin-ext-doc-type:
      when {&FDEDT_Income_Cashless} then do:
        assign
        p-status_ = {&fin-permitted}
        p-ask-message = "Закрыть платеж(и)" + {&new-line} +
                        "(закончить редактирование ПРИХОДНОГО ПЛАТЕЖНОГО ПОРУЧЕНИЯ и разрешить принять безналичные средства)?"
        p-ask-date = yes
        .
      end.
      otherwise do:
        return error substitute ('Недопустима операция &1 для платежа с атрибутами тип-статус-расш.тип &2-&3-&4.', p-mode, p-fin-doc-type, p-status-current, p-fin-ext-doc-type).
      end.
    END CASE.
  end.
  otherwise do:
    return error substitute ('Недопустима операция &1 для платежа с атрибутами тип-статус &2-&3.', p-mode, p-fin-doc-type, p-status-current).
  end.
end case.
end procedure.

procedure income-cashless-permitted:
/*приход безнал разр*/
case p-mode:
  when {&open-doc} then do:
    assign
    p-status_ = {&fin-new}
    p-ask-message = "Открыть платеж(и)" + {&new-line} +
                    "(отменить разрешение на прием безналичных средств  и разрешить редактирование ПРИХОДНОГО ПЛАТЕЖНОГО ПОРУЧЕНИЯ)?"
    .
  end.
  when {&close-doc} then do:
    CASE p-fin-ext-doc-type:
      when {&FDEDT_Income_Cashless} then do:
        assign
        p-status_ = {&fin-bank}
        p-ask-message = "Закрыть платеж(и)" + {&new-line} +
                        "(подтвердить дату поступления безналичных средств в банк)?"
        p-ask-date = yes
        .
      end.
      otherwise do:
        return error substitute ('Недопустима операция &1 для платежа с атрибутами тип-статус-расш.тип &2-&3-&4.', p-mode, p-fin-doc-type, p-status-current, p-fin-ext-doc-type).
      end.
    END CASE.
  end.
  otherwise do:
    return error substitute ('Недопустима операция &1 для платежа с атрибутами тип-статус &2-&3.', p-mode, p-fin-doc-type, p-status-current).
  end.
end case.
end procedure.


procedure income-cashless-bank:
/*приход безнал банк*/
case p-mode:
  when {&open-doc} then do:
    assign
    p-status_ = {&fin-permitted}
    p-ask-message = "Открыть платеж(и)" + {&new-line} +
                    "(снять отметку о дате поступления безналичных средств в банк)?"
    .
  end.
  when {&close-doc} then do:
    CASE p-fin-ext-doc-type:
      when {&FDEDT_Income_Cashless} then do:
        run check-cl-bank in p-parent-handle no-error .
        if error-status:error then do:
          return error return-value .
        end.
        assign
        p-status_ = {&fin-fact}
        p-ask-message = "Закрыть платеж(и)" + {&new-line} +
                        "(подтвердить факт поступления безналичных средств на счет)?"
        p-ask-date = yes
        .
      end.
      otherwise do:
        return error substitute ('Недопустима операция &1 для платежа с атрибутами тип-статус-расш.тип &2-&3-&4.', p-mode, p-fin-doc-type, p-status-current, p-fin-ext-doc-type).
      end.
    END CASE.
  end.
  otherwise do:
    return error substitute ('Недопустима операция &1 для платежа с атрибутами тип-статус &2-&3.', p-mode, p-fin-doc-type, p-status-current).
  end.
end case.
end procedure.


procedure expense-cashless-new :
/*расход безнал новый*/
case p-mode:
  when {&open-doc} then do:
    return error substitute ('Платеж открыт.').
  end.
  when {&close-doc} then do:
    assign
    p-status_ = {&fin-permitted}
    p-ask-message = "Закрыть платеж(и)" + {&new-line} +
                    "(закончить редактирование РАСХОДНОГО ПЛАТЕЖНОГО ПОРУЧЕНИЯ и разрешить переслать платеж в банк)?"
    p-ask-date = yes
    .
  end.
  otherwise do:
    return error substitute ('Недопустима операция &1 для платежа с атрибутами тип-статус &2-&3.', p-mode, p-fin-doc-type, p-status-current).
  end.
end case.
end procedure.

procedure expense-cashless-permitted:
/*расход безнал разр*/
case p-mode:
  when {&open-doc} then do:
    assign
    p-status_ = {&fin-new}
    p-ask-message = "Открыть платеж(и)" + {&new-line} +
                    "(отменить разрешение на перечисление безналичных средств  и разрешить редактирование РАСХОДНОГО ПЛАТЕЖНОГО ПОРУЧЕНИЯ)?"
    .
  end.
  when {&close-doc} then do:
    assign
    p-status_ = {&fin-bank}
    p-ask-message = "Закрыть платеж(и)" + {&new-line} +
                    "(подтвердить дату поступления платежного документа в банк)?"
    p-ask-date = yes
    .
  end.
  otherwise do:
    return error substitute ('Недопустима операция &1 для платежа с атрибутами тип-статус &2-&3.', p-mode, p-fin-doc-type, p-status-current).
  end.
end case.
end procedure.


procedure expense-cashless-bank:
/*расход безнал банк*/
case p-mode:
  when {&open-doc} then do:
    assign
    p-status_ = {&fin-permitted}
    p-ask-message = "Открыть платеж(и)" + {&new-line} +
                    "(отозвать РАСХОДНОЕ ПЛАТЕЖНОЕ ПОРУЧЕНИЕ из банка)?"
    .
  end.
  when {&close-doc} then do:
    assign
    p-status_ = {&fin-fact}
    p-ask-message = "Закрыть платеж(и)" + {&new-line} +
                    "(подтвердить факт списания банк безналичных средств со счета)?"
    p-ask-date = yes
    .
    run check-cl-bank in p-parent-handle no-error .
    if error-status:error then do:
      return error return-value .
    end.
  end.
  when {&reject-doc} then do:
    assign
    p-status_ = {&fin-rejected}
    p-ask-message = "Отказ от платежа(ей)" + {&new-line} +
                    "(подтвердить отказ банка на списание безналичных средств со счета)?"
    p-ask-date = yes
    .
  end.
  otherwise do:
    return error substitute ('Недопустима операция &1 для платежа с атрибутами тип-статус &2-&3.', p-mode, p-fin-doc-type, p-status-current).
  end.
end case.
end procedure.

procedure expense-cashless-rejected:
/*расход безнал отказ*/
case p-mode:
  when {&open-doc} then do:
    assign
    p-status_ = {&fin-bank}
    p-ask-message = "Открыть платеж(и)" + {&new-line} +
                    "(снять ошибочно поставленную отметку об отказе банка в перечислениие средств по РАСХОДНОМУ ПЛАТЕЖНОМУ ПОРУЧЕНИЮ)?"
    .
  end.
  otherwise do:
    return error substitute ('Недопустима операция &1 для платежа с атрибутами тип-статус &2-&3.', p-mode, p-fin-doc-type, p-status-current).
  end.
end case.
end procedure.

procedure income-payoff-new :
/*приход погашение новый*/
case p-mode:
  when {&open-doc} then do:
    return error substitute ('Платеж открыт.').
  end.
  when {&close-doc} then do:
     assign
     p-status_ = {&fin-permitted}
     p-ask-message = "Закрыть платеж(и)" + {&new-line} +
                     "(закончить редактирование ПРИХОДНОГО АПЗ и разрешить погашение средств)?"
     .
  end.
  otherwise do:
    return error substitute ('Недопустима операция &1 для платежа с атрибутами тип-статус &2-&3.', p-mode, p-fin-doc-type, p-status-current).
  end.
end case.
end procedure.

procedure income-payoff-permitted:
/*приход погашение разр*/
case p-mode:
  when {&open-doc} then do:
    assign
    p-status_ = {&fin-new}
    p-ask-message = "Открыть платеж(и)" + {&new-line} +
                    "(отменить разрешение на погашение средств  и разрешить редактирование ПРИХОДНОГО АПЗ)?"
    .
  end.
  when {&close-doc} then do:
    assign
    p-status_ = {&fin-fact}
    p-ask-message = "Закрыть платеж(и)" + {&new-line} +
                    "(подтвердить факт погашения)?"
    .
  end.
  otherwise do:
    return error substitute ('Недопустима операция &1 для платежа с атрибутами тип-статус &2-&3.', p-mode, p-fin-doc-type, p-status-current).
  end.
end case.
end procedure.

procedure expense-payoff-new :
/*расход погашение новый*/
case p-mode:
  when {&open-doc} then do:
    return error substitute ('Платеж открыт.').
  end.
  when {&close-doc} then do:
     assign
     p-status_ = {&fin-permitted}
     p-ask-message = "Закрыть платеж(и)" + {&new-line} +
                     "(закончить редактирование РАСХОДНОГО АПЗ и разрешить погашение средств)?"
     .
  end.
  otherwise do:
    return error substitute ('Недопустима операция &1 для платежа с атрибутами тип-статус &2-&3.', p-mode, p-fin-doc-type, p-status-current).
  end.
end case.
end procedure.

procedure expense-payoff-permitted:
/*расход погашение разр*/
case p-mode:
  when {&open-doc} then do:
    assign
    p-status_ = {&fin-new}
    p-ask-message = "Открыть платеж(и)" + {&new-line} +
                    "(отменить разрешение на погашение  и разрешить редактирование РАСХОДНОГО АПЗ)?"
    .
  end.
  when {&close-doc} then do:
    assign
    p-status_ = {&fin-fact}
    p-ask-message = "Закрыть платеж(и)" + {&new-line} +
                    "(подтвердить факт погашения средств)?"
    .
  end.
  otherwise do:
    return error substitute ('Недопустима операция &1 для платежа с атрибутами тип-статус &2-&3.', p-mode, p-fin-doc-type, p-status-current).
  end.
end case.
end procedure.