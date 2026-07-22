block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$
Стандартный граф переходов выписок по параметрам

ГРАФ ПЕРЕХОДОВ ОПИСАН В ФАЙЛЕ finsgraf.p

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/18/03
Author: Bakhtadze Natalya
Creation date: 11/18/03

*/

define input  parameter p-parent-handle     as handle no-undo .
define input  parameter p-fins-doc-type      like ub.fin-statement.fins-doc-type     no-undo . /*тип */
define input  parameter p-fins-ext-doc-type  like ub.fin-statement.fins-ext-doc-type no-undo . /*расширенный тип */
define input  parameter p-status-current     like ub.fin-statement.status_          no-undo . /*статус*/
define input  parameter p-mode               as   character                   no-undo . /*режим обработки*/
define input  parameter p-author             as   character                   no-undo .
define input  parameter p-status-date        like ub.fin-statement.fact-date        no-undo . /*дата перевода статуса*/
define output parameter p-status_            like ub.fin-statement.status_          no-undo . /*статус в который выписка перейдет*/
define output parameter p-ask-date           as logical                       no-undo . /*выдавать запрос даты смены статуса*/
define output parameter p-ask-message        as character                     no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Стандартный граф переходов выписок по параметрам".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }

{ trg/finsgrfp.i
&standard-sttm-new = " run standard-sttm-new          . "
&standard-sttm-bank  = " run standard-sttm-bank       . "
}

procedure standard-sttm-new :
/*стандартная новый*/
case p-mode:
  when {&open-doc} then do:
    return error substitute ('Выписка открыта.').
  end.
  when {&close-doc} then do:
     assign
     p-status_ = {&fin-bank}
     p-ask-message = "Закрыть выписку(и)" + {&new-line} +
                     "(закончить редактирование ВЫПИСКИ и перевести в статус БАНК)?"
     p-ask-date = yes
     .
  end.
  otherwise do:
    return error substitute ('Недопустима операция &1 для выписки с атрибутами тип-статус &2-&3.', p-mode, p-fins-doc-type, p-status-current).
  end.
end case.
end procedure.

procedure standard-sttm-bank:
/*стандартная банк*/
case p-mode:
  when {&open-doc} then do:
    assign
    p-status_ = {&fin-new}
    p-ask-message = "Открыть выписку(и)" + {&new-line} +
                    "(снять отметку о поступления выписки из банка)?"
    .
  end.
  when {&close-doc} then do:
    run check-cl-bank in p-parent-handle no-error .
    if error-status:error then do:
      return error return-value .
    end.
    assign
    p-status_ = {&fin-fact}
    p-ask-message = "Закрыть выписку(и)" + {&new-line} +
                    "(подтвердить факт поступления выписки из банка - дальнейшее редактирование выписки будет невозможно)?"
    p-ask-date = yes
    .
  end.
  otherwise do:
    return error substitute ('Недопустима операция &1 для выписки с атрибутами тип-статус &2-&3.', p-mode, p-fins-doc-type, p-status-current).
  end.
end case.
end procedure.