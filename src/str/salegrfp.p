block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: salegrfp.p $
$Archive: str/salegrfp.p $
Стандартный граф переходов продаж по параметрам

ГРАФ ПЕРЕХОДОВ ОПИСАН В ФАЙЛЕ salegraf.p

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/18/03
Author: Bakhtadze Natalya
Creation date: 11/18/03

*/

define input  parameter p-status-current    like ub.inkas.status_            no-undo . /*статус документа*/
define input  parameter p-flag-current      like ub.inkas.flag_              no-undo . /*статус документа*/
define input  parameter p-doc-status-current like ub.trn-doc.status_          no-undo . /*статус документа*/
define input  parameter p-mode              as   character                   no-undo . /*режим обработки документа*/
define output parameter p-status_           like ub.inkas.status_            no-undo . /*статус в который документ перейдет*/
define output parameter p-flag_             like ub.inkas.flag_              no-undo . /*статус в который документ перейдет*/
define output parameter p-ask-message       as character                     no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: salegrfp.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/salegrfp.p $":U .
define variable vss-description as character no-undo init "Стандартный граф переходов продаж по параметрам".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }



do on error undo, return error return-value :
CASE P-status-current:
  when {&g___new} then do:
    CASE p-flag-current:
      when no then do:
        run new-minus.
      end.
      when yes then do:
        run new-plus.
      end.
    END CASE.
  end.
  when {&doc-froze} then do:
    run doc-froze.
  end.
  when {&fact} then do:
      return error substitute ("Недопустимый статус &1", p-status-current).
  end.
  when {&inquiry} then do:
      return error substitute ("Недопустимый статус &1", p-status-current).
  end.
END CASE.

END.

procedure new-minus :
/*новый-*/
case p-mode:
  when {&open-doc} then do:
    return error substitute ('Продажа открыта для закачки чеков.').
  end.
  when {&close-doc} then do:
     assign
     p-status_ = {&g___new}
     p-flag_   = yes
     p-ask-message = "Запрет на добавление чеков в продажу в режиме автом. работы с продажей по расписанию"
     .
  end.
  when {&close-fact} then do:
     assign
     p-status_ = (if p-doc-status-current = {&inquiry} then {&inquiry} else {&fact})
     p-flag_   = no
     p-ask-message = if p-doc-status-current = {&inquiry}
                     then "Закрытие продажи до статуса <запрос>?"
                     else "Закрытие продажи на факт?"

     .
  end.
  otherwise do:
    return error substitute ('Недопустима операция &1 для продажи статус &2&3.', p-mode, p-status-current, p-flag-current).
  end.
end case.
end procedure.


procedure new-plus :
/*новый+*/
case p-mode:
  when {&open-doc} then do:
    assign
    p-status_ = {&g___new}
    p-flag_   = no
    p-ask-message = "Разрешить добавление чеков в продажу в режиме автом. работы с продажей по расписанию"
    .
  end.
  when {&close-doc} then do:
    if p-doc-status-current = {&inquiry} then do:
       return error substitute ('Недопустима операция &1 для продажи статус &2&3.', p-mode, p-status-current, p-flag-current).
    end.
    else do:
     assign
     p-status_ = {&doc-froze}
     p-flag_   = no
     p-ask-message = "Запретить резервирование в режиме авто. работы с продажей по расписанию"
     .
    end.
  end.
  when {&close-fact} then do:
     assign
     p-status_ = (if p-doc-status-current = {&inquiry} then {&inquiry} else {&fact})
     p-flag_   = no
     p-ask-message = if p-doc-status-current = {&inquiry}
                     then "Закрытие продажи до статуса <запрос>?"
                     else "Закрытие продажи на факт?"

     .
  end.
  otherwise do:
    return error substitute ('Недопустима операция &1 для продажи статус &2&3.', p-mode, p-status-current, p-flag-current).
  end.
end case.
end procedure.


procedure doc-froze :
/*нередакт-*/
case p-mode:
  when {&open-doc} then do:
    if p-doc-status-current = {&inquiry} then do:
      return error substitute ('Недопустима операция &1 для продажи статус &2&3.', p-mode, p-status-current, p-flag-current).
    end.
    else do:
      assign
      p-status_ = {&g___new}
      p-flag_   = yes
      p-ask-message = "Разрешить резервирование в режиме автом. работы с продажей по расписанию"
      .
    end.
  end.
  when {&close-doc} then do:
     assign
     p-status_ = (if p-doc-status-current = {&inquiry} then {&inquiry} else {&fact})
     p-flag_   = no
     p-ask-message = if p-doc-status-current = {&inquiry}
                     then "Закрытие продажи до статуса <запрос>?"
                     else "Закрытие продажи на факт?"
     .
  end.
  when {&close-fact} then do:
     assign
     p-status_ = (if p-doc-status-current = {&inquiry} then {&inquiry} else {&fact})
     p-flag_   = no
     p-ask-message = if p-doc-status-current = {&inquiry}
                     then "Закрытие продажи до статуса <запрос>?"
                     else "Закрытие продажи на факт?"
     .
  end.
  otherwise do:
    return error substitute ('Недопустима операция &1 для продажи статус &2&3.', p-mode, p-status-current, p-flag-current).
  end.
end case.
end procedure.