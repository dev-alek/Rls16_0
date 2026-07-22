block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: ubdingbd.p $
$Archive: utl/ubdingbd.p $

Перевод УБД в ГБД запуск

Автор: Чернова Светлана Александровна
Дата создания: 08/27/08
Author: Svetlana Chernova
Creation date: 08/27/08

*/
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: ubdingbd.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/ubdingbd.p $":U .
define variable vss-description as character no-undo init "Перевод УБД в ГБД запуск".
{ cmp/vssrevis.i }
{ cmp/trg-def.i new }
  g#auto = true .


define variable curr-db-num as integer   no-undo .
find first ub.sys-ctrl no-lock no-error .
if error-status :error then do:
   message
     vss-workfile vss-revision vss-description skip
     error-status :get-message(1) skip
     return-value skip
     "Ошибка"
     view-as alert-box error
   .
   return .
end.

assign
  curr-db-num = ub.sys-ctrl.db-num
.

/*
if curr-db-num = 0  then do:
   message "Утилита только для УБД !!! "  view-as alert-box error .
   return .
end.
*/
message " ПРОВЕРЬТЕ НАЛИЧИЕ РЕЗЕРВНОЙ КОПИИ БД !!!" skip (2)
         "ЗАПУСКАТЬ утилиту трансформации УБД" curr-db-num "в ГБД ? "
         view-as alert-box question
         buttons yes-no
         title "Вопрос"
         update v-ok as log
         .
if not v-ok then return .

message "Для перевода внутрифирменных перемещений в одну БД необходимо создать ОРГ в справочнике клиента , на которого будут переведены документы других БД"  skip (2)
  "Продолжать ?"
  view-as alert-box information
  buttons yes-no
  update v-ok.
if not v-ok then return.

  define variable passwd as character no-undo.

  run gbl/d-prompt.w (
      'title=':u + "Выбор фиктивного контрагена " + '\':u
    + 'text1=':u + "Выбор фиктивного контрагена для внутренних перемещений" + '\':u
    + 'text2=':u + "ВВЕДИТЕ код контрагента" + '\':u
    + 'type=integer\':u
    + 'format=>>>>>>>>>>>>>>9\':u
    + 'fillin_row=4\':u
    + 'fillin_col=4\':u
    + 'fillin_width=20\':u
    ,input-output passwd
    ).
  if return-value = 'false':u
  then do:
    return .
  end.

find first ub.clients no-lock where
           ub.clients.obj-code = int(passwd)  and
           ub.clients.obj-type = {&cmp}
           no-error .
if error-status :error then do:
  message
    vss-workfile vss-revision vss-description skip
    error-status :get-message(1) skip
    return-value skip
    "Ошибка"
    view-as alert-box error
  .
  return .
end.

if not ( ub.clients.obj-type = {&cmp}  )then do:
   message "Выбран неправильный Контрагент !" view-as alert-box error .
   return .
end.
message   ub.clients.obj-type ub.clients.obj-code ub.clients.obj-name skip
  "Будет фиктивным контрагентом для внутренних перемещений с другими БД" skip (2)
  "Продолжать ?"
  view-as alert-box information
  buttons yes-no
  title "Внимание"
  update v-ok
  .
if not v-ok then return .

  run str/diallog.w (
       input this-procedure
      ,input this-procedure
      ,input "utl/ubd-gbd1.p" + {&delim-par} + "1" + {&delim-par} + "1"+ {&delim-par} + "1"+ {&delim-par} + "1"
      ,input string(curr-db-num) + {&delim-par} + string(ub.clients.obj-code)
      ,input yes
      ,input ?
      ,input substitute('Трансформация УБД &1 в ГБД', curr-db-num)
      ) no-error .
if error-status:error then do:
    message
    "Ошибка при Трансформации УБД в ГБД" skip
    error-status:get-message(1) skip
    return-value
    view-as alert-box error.
    undo, return error.
end.

message 'Все' view-as alert-box information .