block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: finstm01.p $
$Archive: ref/finstm01.p $

Проверка выписки типа standard-sttm

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/19/06
Author: Bakhtadze Natalya
Creation date: 11/19/06

*/

{ ref/fnstmip.i }

define input parameter p-mode as character no-undo .
define input parameter p-close-mode as character no-undo .
{&all-fin-statement-params-doc-status-define}
define input parameter p-status_ like ub.fin-statement.status_ no-undo .
define input parameter p-status-date like ub.fin-statement.doc-date no-undo .
define output parameter p-correct as logical no-undo .
define output parameter p-err-mess as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: finstm01.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/finstm01.p $":U .
define variable vss-description as character no-undo init "Проверка выписки типа standard-sttm".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ ref/finstm0.i def }

do
on error undo, return error
:

  assign
  v-author = (if num-entries(p-mode, {&delim-par}) > 1
            then entry(2, p-mode, {&delim-par})
            else '':U)
  p-mode = entry(1, p-mode, {&delim-par})
  .


  run standard-sttm-gen in this-procedure ( input p-close-mode, output p-correct) no-error .
  if error-status:error then do:
    return "Ошибка в процедуре проверки валидности выписки".
  end.
  else do:
    if p-correct = no then return return-value.
  end.

  /*здесь может быть еще что-то*/

  assign
  p-correct = yes
  .
end. /*doe*/