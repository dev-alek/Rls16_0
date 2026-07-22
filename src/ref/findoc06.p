block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: findoc06.p $
$Archive: ref/findoc06.p $

Проверка платежа  типа expense-payoff

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/17/03
Author: Bakhtadze Natalya
Creation date: 11/17/03

*/

{ ref/fndocip.i }

define input parameter p-mode as character no-undo .
define input parameter p-close-mode as character no-undo .
{&all-fin-doc-params-doc-status-define}
{&all-fin-doc-params-doc-status-define-2}
define input parameter p-status_ like ub.fin-doc.status_ no-undo .
define input parameter p-status-date like ub.fin-doc.doc-date no-undo .
define output parameter p-correct as logical no-undo .
define output parameter p-err-mess as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: findoc06.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/findoc06.p $":U .
define variable vss-description as character no-undo init "Проверка платежа типа expense-payoff".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
{ ref/findoc0o.i def }

do
on error undo, return error
  :

  run income-expense-gen in this-procedure(input p-close-mode, output p-correct) no-error .
  if error-status:error then do:
    return "Ошибка в процедуре проверки валидности платежа".
  end.
  else do:
    if p-correct = no then return return-value.
  end.

  /*здесь может быть еще что-то*/


  assign
  p-correct = yes
  .

end. /*doe*/