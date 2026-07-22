block-level on error undo, throw.
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
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
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
END.
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
end procedure.
