block-level on error undo, throw.
define input  parameter p-parent-handle     as handle no-undo .
define input  parameter p-fin-doc-type      like ub.fin-doc.fin-doc-type     no-undo .
define input  parameter p-fin-ext-doc-type  like ub.fin-doc.fin-ext-doc-type no-undo .
define input  parameter p-status-current    like ub.fin-doc.status_          no-undo .
define input  parameter p-mode              as   character                   no-undo .
define input  parameter p-author            as   character                   no-undo .
define input  parameter p-status-date       like ub.fin-doc.fact-date        no-undo .
define output parameter p-status_           like ub.fin-doc.status_          no-undo .
define output parameter p-ask-date          as logical                       no-undo .
define output parameter p-ask-message       as character                     no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Стандартный граф переходов финансовых документов по параметрам".
procedure vss-get-info :
  define output parameter p-vss-revision    like vss-revision    no-undo .
  define output parameter p-vss-author      like vss-author      no-undo .
  define output parameter p-vss-date        like vss-date        no-undo .
  define output parameter p-vss-workfile    like vss-workfile    no-undo .
  define output parameter p-vss-archive     like vss-archive     no-undo .
  define output parameter p-vss-description like vss-description no-undo .
  assign
    p-vss-revision    = vss-revision
    p-vss-author      = vss-author
    p-vss-date        = vss-date
    p-vss-workfile    = vss-workfile
    p-vss-archive     = vss-archive
    p-vss-description = vss-description
  .
end procedure.
procedure vss-get-parameters :
  define output parameter p-vss-parameters as character no-undo .
end procedure.
define new global shared variable g#vssrevis-logger as handle    no-undo .
define variable v-vssrevis-logevent                 as logical   no-undo init false .
define variable v-vssrevis-logger                   as handle    no-undo .
procedure vss-logevent :
  define input  parameter p-extra-paramters as character no-undo .
  define variable v-vssrevis-parameters as character no-undo .
  do
  on error undo, return error return-value
  :
    if  valid-handle(v-vssrevis-logger)
    and v-vssrevis-logger :get-signature("logevent") <> ""
    then do:
      run vss-get-parameters in this-procedure
        (output v-vssrevis-parameters
        ).
      run logevent in v-vssrevis-logger
        (input vss-workfile
        ,input vss-revision
        ,input v-vssrevis-parameters
        ,input p-extra-paramters
        ).
    end.
  end.
end procedure.
assign
  v-vssrevis-logger = g#vssrevis-logger
.
if  valid-handle(v-vssrevis-logger)
and v-vssrevis-logger :get-signature("logevent") <> ""
then do:
  assign
    v-vssrevis-logevent = true
  .
  run vss-logevent in this-procedure (input vss-description) .
end.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do on error undo, return error return-value :
  CASE p-fin-doc-type:
    when 'пко':U then do:
      CASE P-status-current:
        when 'новый':U then do:
           run income-cash-new             .
        end.
        when 'разрешен':U then do:
           run income-cash-permitted       .
        end.
        when 'банк':U then do:
           return error substitute ("Недопустимый тип-статус &1-&2.", p-fin-doc-type, p-status-current).
        end.
      END CASE.
    end.
    when 'ппп':U then do:
      CASE P-status-current:
        when 'новый':U then do:
           run income-cashless-new             .
        end.
        when 'разрешен':U then do:
           run income-cashless-permitted       .
        end.
        when 'банк':U then do:
           run income-cashless-bank       .
        end.
      END CASE.
    end.
    when 'апп':U then do:
      CASE P-status-current:
        when 'новый':U then do:
           run income-payoff-new             .
        end.
        when 'разрешен':U then do:
           run income-payoff-permitted       .
        end.
        when 'банк':U then do:
           return error substitute ("Недопустимый тип-статус &1-&2.", p-fin-doc-type, p-status-current).
        end.
      END CASE.
    end.
    when 'рко':U then do:
      CASE P-status-current:
        when 'новый':U then do:
           run expense-cash-new             .
        end.
        when 'разрешен':U then do:
           run expense-cash-permitted       .
        end.
        when 'банк':U then do:
           return error substitute ("Недопустимый тип-статус &1-&2.", p-fin-doc-type, p-status-current).
        end.
      END CASE.
    end.
    when 'рпп':U then do:
      CASE P-status-current:
        when 'новый':U then do:
           run expense-cashless-new             .
        end.
        when 'разрешен':U then do:
           run expense-cashless-permitted       .
        end.
        when 'банк':U then do:
            run expense-cashless-bank       .
        end.
        when 'отказ':U then do:
            run expense-cashless-rejected       .
        end.
      END CASE.
    end.
    when 'апр':U then do:
      CASE P-status-current:
        when 'новый':U then do:
           run expense-payoff-new             .
        end.
        when 'разрешен':U then do:
           run expense-payoff-permitted       .
        end.
        when 'банк':U then do:
           return error substitute ("Недопустимый тип-статус &1-&2.", p-fin-doc-type, p-status-current).
        end.
      END CASE.
    end.
  END CASE.
END.
procedure income-cash-new :
case p-mode:
  when '<открытие документа>':U then do:
    return error substitute ('Платеж открыт.').
  end.
  when '<закрытие документа>':U then do:
     assign
     p-status_ = 'разрешен':U
     p-ask-message = "Закрыть платеж(и)" + chr(10) +
                     "(закончить редактирование ПРИХОДНОГО КАССОВОГО ОРДЕРА и разрешить прием наличных средств)?"
     .
  end.
  otherwise do:
    return error substitute ('Недопустима операция &1 для платежа с атрибутами тип-статус &2-&3.', p-mode, p-fin-doc-type, p-status-current).
  end.
end case.
end procedure.
procedure income-cash-permitted:
case p-mode:
  when '<открытие документа>':U then do:
    assign
    p-status_ = 'новый':U
    p-ask-message = "Открыть платеж(и)" + chr(10) +
                    "(отменить разрешение на прием наличных средств  и разрешить редактирование ПРИХОДНОГО КАССОВОГО ОРДЕРА)?"
    .
  end.
  when '<закрытие документа>':U then do:
    assign
    p-status_ = 'факт':U
    p-ask-message = "Закрыть платеж(и)" + chr(10) +
                    "(подтвердить факт приема наличных средств)?"
    .
  end.
  otherwise do:
    return error substitute ('Недопустима операция &1 для платежа с атрибутами тип-статус &2-&3.', p-mode, p-fin-doc-type, p-status-current).
  end.
end case.
end procedure.
procedure expense-cash-new :
case p-mode:
  when '<открытие документа>':U then do:
    return error substitute ('Платеж открыт.').
  end.
  when '<закрытие документа>':U then do:
     assign
     p-status_ = 'разрешен':U
     p-ask-message = "Закрыть платеж(и)" + chr(10) +
                     "(закончить редактирование РАСХОДНОГО КАССОВОГО ОРДЕРА и разрешить выдачу наличных средств)?"
     .
  end.
  otherwise do:
    return error substitute ('Недопустима операция &1 для платежа с атрибутами тип-статус &2-&3.', p-mode, p-fin-doc-type, p-status-current).
  end.
end case.
end procedure.
procedure expense-cash-permitted:
case p-mode:
  when '<открытие документа>':U then do:
    assign
    p-status_ = 'новый':U
    p-ask-message = "Открыть платеж(и)" + chr(10) +
                    "(отменить разрешение на расход наличных средств  и разрешить редактирование РАСХОДНОГО КАССОВОГО ОРДЕРА)?"
    .
  end.
  when '<закрытие документа>':U then do:
    assign
    p-status_ = 'факт':U
    p-ask-message = "Закрыть платеж(и)" + chr(10) +
                    "(подтвердить факт расхода наличных средств)?"
    .
  end.
  otherwise do:
    return error substitute ('Недопустима операция &1 для платежа с атрибутами тип-статус &2-&3.', p-mode, p-fin-doc-type, p-status-current).
  end.
end case.
end procedure.
procedure income-cashless-new :
case p-mode:
  when '<открытие документа>':U then do:
    return error substitute ('Платеж открыт.').
  end.
  when '<закрытие документа>':U then do:
    CASE p-fin-ext-doc-type:
      when 'ппп':U then do:
        assign
        p-status_ = 'разрешен':U
        p-ask-message = "Закрыть платеж(и)" + chr(10) +
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
case p-mode:
  when '<открытие документа>':U then do:
    assign
    p-status_ = 'новый':U
    p-ask-message = "Открыть платеж(и)" + chr(10) +
                    "(отменить разрешение на прием безналичных средств  и разрешить редактирование ПРИХОДНОГО ПЛАТЕЖНОГО ПОРУЧЕНИЯ)?"
    .
  end.
  when '<закрытие документа>':U then do:
    CASE p-fin-ext-doc-type:
      when 'ппп':U then do:
        assign
        p-status_ = 'банк':U
        p-ask-message = "Закрыть платеж(и)" + chr(10) +
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
case p-mode:
  when '<открытие документа>':U then do:
    assign
    p-status_ = 'разрешен':U
    p-ask-message = "Открыть платеж(и)" + chr(10) +
                    "(снять отметку о дате поступления безналичных средств в банк)?"
    .
  end.
  when '<закрытие документа>':U then do:
    CASE p-fin-ext-doc-type:
      when 'ппп':U then do:
        run check-cl-bank in p-parent-handle no-error .
        if error-status:error then do:
          return error return-value .
        end.
        assign
        p-status_ = 'факт':U
        p-ask-message = "Закрыть платеж(и)" + chr(10) +
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
case p-mode:
  when '<открытие документа>':U then do:
    return error substitute ('Платеж открыт.').
  end.
  when '<закрытие документа>':U then do:
    assign
    p-status_ = 'разрешен':U
    p-ask-message = "Закрыть платеж(и)" + chr(10) +
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
case p-mode:
  when '<открытие документа>':U then do:
    assign
    p-status_ = 'новый':U
    p-ask-message = "Открыть платеж(и)" + chr(10) +
                    "(отменить разрешение на перечисление безналичных средств  и разрешить редактирование РАСХОДНОГО ПЛАТЕЖНОГО ПОРУЧЕНИЯ)?"
    .
  end.
  when '<закрытие документа>':U then do:
    assign
    p-status_ = 'банк':U
    p-ask-message = "Закрыть платеж(и)" + chr(10) +
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
case p-mode:
  when '<открытие документа>':U then do:
    assign
    p-status_ = 'разрешен':U
    p-ask-message = "Открыть платеж(и)" + chr(10) +
                    "(отозвать РАСХОДНОЕ ПЛАТЕЖНОЕ ПОРУЧЕНИЕ из банка)?"
    .
  end.
  when '<закрытие документа>':U then do:
    assign
    p-status_ = 'факт':U
    p-ask-message = "Закрыть платеж(и)" + chr(10) +
                    "(подтвердить факт списания банк безналичных средств со счета)?"
    p-ask-date = yes
    .
    run check-cl-bank in p-parent-handle no-error .
    if error-status:error then do:
      return error return-value .
    end.
  end.
  when '<отказ от документа>':U then do:
    assign
    p-status_ = 'отказ':U
    p-ask-message = "Отказ от платежа(ей)" + chr(10) +
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
case p-mode:
  when '<открытие документа>':U then do:
    assign
    p-status_ = 'банк':U
    p-ask-message = "Открыть платеж(и)" + chr(10) +
                    "(снять ошибочно поставленную отметку об отказе банка в перечислениие средств по РАСХОДНОМУ ПЛАТЕЖНОМУ ПОРУЧЕНИЮ)?"
    .
  end.
  otherwise do:
    return error substitute ('Недопустима операция &1 для платежа с атрибутами тип-статус &2-&3.', p-mode, p-fin-doc-type, p-status-current).
  end.
end case.
end procedure.
procedure income-payoff-new :
case p-mode:
  when '<открытие документа>':U then do:
    return error substitute ('Платеж открыт.').
  end.
  when '<закрытие документа>':U then do:
     assign
     p-status_ = 'разрешен':U
     p-ask-message = "Закрыть платеж(и)" + chr(10) +
                     "(закончить редактирование ПРИХОДНОГО АПЗ и разрешить погашение средств)?"
     .
  end.
  otherwise do:
    return error substitute ('Недопустима операция &1 для платежа с атрибутами тип-статус &2-&3.', p-mode, p-fin-doc-type, p-status-current).
  end.
end case.
end procedure.
procedure income-payoff-permitted:
case p-mode:
  when '<открытие документа>':U then do:
    assign
    p-status_ = 'новый':U
    p-ask-message = "Открыть платеж(и)" + chr(10) +
                    "(отменить разрешение на погашение средств  и разрешить редактирование ПРИХОДНОГО АПЗ)?"
    .
  end.
  when '<закрытие документа>':U then do:
    assign
    p-status_ = 'факт':U
    p-ask-message = "Закрыть платеж(и)" + chr(10) +
                    "(подтвердить факт погашения)?"
    .
  end.
  otherwise do:
    return error substitute ('Недопустима операция &1 для платежа с атрибутами тип-статус &2-&3.', p-mode, p-fin-doc-type, p-status-current).
  end.
end case.
end procedure.
procedure expense-payoff-new :
case p-mode:
  when '<открытие документа>':U then do:
    return error substitute ('Платеж открыт.').
  end.
  when '<закрытие документа>':U then do:
     assign
     p-status_ = 'разрешен':U
     p-ask-message = "Закрыть платеж(и)" + chr(10) +
                     "(закончить редактирование РАСХОДНОГО АПЗ и разрешить погашение средств)?"
     .
  end.
  otherwise do:
    return error substitute ('Недопустима операция &1 для платежа с атрибутами тип-статус &2-&3.', p-mode, p-fin-doc-type, p-status-current).
  end.
end case.
end procedure.
procedure expense-payoff-permitted:
case p-mode:
  when '<открытие документа>':U then do:
    assign
    p-status_ = 'новый':U
    p-ask-message = "Открыть платеж(и)" + chr(10) +
                    "(отменить разрешение на погашение  и разрешить редактирование РАСХОДНОГО АПЗ)?"
    .
  end.
  when '<закрытие документа>':U then do:
    assign
    p-status_ = 'факт':U
    p-ask-message = "Закрыть платеж(и)" + chr(10) +
                    "(подтвердить факт погашения средств)?"
    .
  end.
  otherwise do:
    return error substitute ('Недопустима операция &1 для платежа с атрибутами тип-статус &2-&3.', p-mode, p-fin-doc-type, p-status-current).
  end.
end case.
end procedure.
