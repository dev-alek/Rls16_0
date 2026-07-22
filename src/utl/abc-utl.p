block-level on error undo, throw.
/*
$Revision: d47c064bc860, 1107, rls $
$Author: SMMolotkov $
$Date: Thu Dec 14 02:13:53 2017 +0300 $
$Workfile: abc-utl.p $
$Archive: utl/abc-utl.p $

Начальное формирование справочника критериев анализа

Автор: Чернова Светлана Александровна
Дата создания: 04/22/09
Author: Svetlana Chernova
Creation date: 04/22/09

*/
/* define input parameter parParentProc as handle           no-undo.
29/IX-2017 из kick-db.p вызывается без параметров; из menuloa2.p вызывается через препроцессоры, отследить трудно
*/
define variable p-install as logical no-undo init true  .



define variable vss-revision    as character no-undo init "$Revision: d47c064bc860, 1107, rls $":U .
define variable vss-author      as character no-undo init "$Author: SMMolotkov $":U .
define variable vss-date        as character no-undo init "$Date: Thu Dec 14 02:13:53 2017 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: abc-utl.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/abc-utl.p $":U .
define variable vss-description as character no-undo init "".

def var start-time     as integer   no-undo .
def var current-time   as integer   no-undo .
def var v-ind          as integer no-undo .
def var v-err-count    as integer no-undo .
def var v-file-name    as char no-undo init "03091801.txt".

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }

def frame a
  "Создание справочника Критерии анализа"
  v-ind        format "->>>>>>>>9" label "Количество записей" skip
  current-time format "->>>>>>>>9" label "Время" skip
  with view-as dialog-box side-labels three-d
  title "Закачка данных"
  .

if p-install = false then do:
  def var lok as logical no-undo .
  message
    vss-description
    "Заменить Справочник Критериев анализа на стандартный " skip
    "Продолжить?"
    view-as alert-box question buttons yes-no update lok .
  if lok <> true then do:
    return .
  end.
end.


do
on error undo, return error
:

  assign
    start-time = time
    v-ind        = 15
  .
  view frame a .
  display v-ind  with frame a .

  run proc-in .

  if p-install = false then do:
    message
      vss-description skip
      "Утилита завершила работу" skip
      view-as alert-box information .
  end.
  return "Создано" + string(v-ind)  + " ошибок " + string(v-err-count).


END. /*doe*/


procedure proc-in :

  do
  on error undo, return error return-value
  :

  for each criterion-analysis exclusive-lock :
    delete criterion-analysis .
  end.


  create criterion-analysis.
        assign
          criterion-analysis.cral-id     = 1
          criterion-analysis.cral-name   = "Оборот в количестве"
          criterion-analysis.cral-des    = "Общее количество в базовых единицах"
          criterion-analysis.cral-status = 0
          .
  create criterion-analysis.
        assign
          criterion-analysis.cral-id     = 2
          criterion-analysis.cral-name   = "Оборот в учетных ценах в нац.валюте"
          criterion-analysis.cral-des    = "Реализовано по ценам из партий в нац.валюте"
          criterion-analysis.cral-status = 0
          .

  create criterion-analysis.
        assign
          criterion-analysis.cral-id     = 3
          criterion-analysis.cral-name   = "Оборот в ценах документа в нац.валюте"
          criterion-analysis.cral-des    = "Реализовано товара по ценам документа в нац.валюте"
          criterion-analysis.cral-status = 0
          .

  create criterion-analysis.
        assign
          criterion-analysis.cral-id     = 4
          criterion-analysis.cral-name   = "Оборот в текущих продажных ценах в нац.валюте     "
          criterion-analysis.cral-des    = "Реализовано в текущих продажных ценах в нац.валюте "
          criterion-analysis.cral-status = 0
          .

  create criterion-analysis.
        assign
          criterion-analysis.cral-id     = 5
          criterion-analysis.cral-name   = "Оборот в учетных ценах в баз.валюте        "
          criterion-analysis.cral-des    = "Реализовано по ценам из партий в базовой валюте "
          criterion-analysis.cral-status = 0
          .

  create criterion-analysis.
        assign
          criterion-analysis.cral-id     = 6
          criterion-analysis.cral-name   = "Оборот в ценах документа в баз.валюте"
          criterion-analysis.cral-des    = "Реализовано по ценам из документа в базовой валюте"
          criterion-analysis.cral-status = 0
          .

  create criterion-analysis.
        assign
          criterion-analysis.cral-id     = 7
          criterion-analysis.cral-name   = "Оборот в текущих продажных ценах в баз.валюте"
          criterion-analysis.cral-des    = "Реализовано в текущих продажных ценах в базовой валюте"
          criterion-analysis.cral-status = 0
          .

  create criterion-analysis.
        assign
          criterion-analysis.cral-id     = 8
          criterion-analysis.cral-name   = "Прибыль в нац.валюте"
          criterion-analysis.cral-des    = "Сумма реализ. товара в  ценах док. без налогов минус сумма в учетных ценах без налогов (нац.валюта)"
          criterion-analysis.cral-status = 0
          .

  create criterion-analysis.
        assign
          criterion-analysis.cral-id     = 9
          criterion-analysis.cral-name   = "Прибыль в баз.валюте"
          criterion-analysis.cral-des    = "Сумма реализ. товара в  ценах док. без налогов минус сумма в учетных ценах без налогов (баз. вал.)"
          criterion-analysis.cral-status = 0
          .

  create criterion-analysis.
        assign
          criterion-analysis.cral-id     = 10
          criterion-analysis.cral-name   = "Прибыль с учетом налогов в нац.валюте"
          criterion-analysis.cral-des    = "Сумма реализ. в  ценах док. минус сумма в учетных ценах (нац.валюта)"
          criterion-analysis.cral-status = 0
          .

  create criterion-analysis.
        assign
          criterion-analysis.cral-id     = 11
          criterion-analysis.cral-name   = "Прибыль с учетом налогов в баз.валюте"
          criterion-analysis.cral-des    = "Сумма реализ. в  ценах док. минус сумма в учетных ценах (баз. вал.)"
          criterion-analysis.cral-status = 0
          .

  create criterion-analysis.
        assign
          criterion-analysis.cral-id     = 12
          criterion-analysis.cral-name   = "Потенциальная прибыль в нац.валюте"
          criterion-analysis.cral-des    = "Сумма реализ. в  тек. прод ценах без налогов минус сумма в учетных ценах без налогов (нац.валюта)"
          criterion-analysis.cral-status = 0
          .

  create criterion-analysis.
        assign
          criterion-analysis.cral-id     = 13
          criterion-analysis.cral-name   = "Потенциальная прибыль в баз.валюте"
          criterion-analysis.cral-des    = "Сумма реализ. в  тек. прод. ценах  без налогов минус сумма в учетных ценах без налогов (баз. вал.)"
          criterion-analysis.cral-status = 0
          .

  create criterion-analysis.
        assign
          criterion-analysis.cral-id     = 14
          criterion-analysis.cral-name   = "Потенциальная прибыль с учетом налогов в нац.валюте"
          criterion-analysis.cral-des    = "Сумма реализ. товара в тек. прод. ценах  минус сумма в учетных ценах (нац.валюта)"
          criterion-analysis.cral-status = 0
          .

  create criterion-analysis.
        assign
          criterion-analysis.cral-id     = 15
          criterion-analysis.cral-name   = "Потенциальная прибыль с учетом налогов в баз.валюте"
          criterion-analysis.cral-des    = "Сумма реализ. товара в тек. прод. ценах  минус сумма в учетных ценах (баз. вал.)"
          criterion-analysis.cral-status = 0
          .


  end.

end procedure. /* proc-in */