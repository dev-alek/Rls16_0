block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: checkdoc.p $
$Archive: utl/checkdoc.p $

Утилита проверки и коррекции документа

Автор: Суслов Алексей Юрьевич
Дата создания: 04/12/06
Author: Alexey Suslov
Creation date: 04/12/06

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: checkdoc.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/checkdoc.p $":U .
define variable vss-description as character no-undo init "Утилита проверки и коррекции документа".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }

define variable v-doc-code    as character no-undo .
define variable v-root-node   as integer   no-undo .
define variable l-empty-scale as logical   no-undo .
define variable i-err-count   as integer   no-undo .

assign
  v-doc-code = ""
.

run gbl/d-prompt.w (
    'title=Введите номер документа\'
  + 'text1=Номер документа для коррекции\'
  + 'format=x(14)\'
  + 'type=char\'
/*  + 'boxprog=box-usrs.p\'*/
  ,input-output v-doc-code
  ).

if return-value = "false":u then do:
  undo, return error .
end.

run utl/trnfix.p (
              input v-doc-code,
              output i-err-count) NO-ERROR.

if error-status:error then do:
  message "Ошибка при коррекции документа" v-doc-code
  view-as alert-box ERROR.
end.

if i-err-count <> 0 then do:
  message
    "При проверке документа была произведена коррекция строк" skip
    "Количество исправлений" i-err-count skip
    view-as alert-box information .
end.