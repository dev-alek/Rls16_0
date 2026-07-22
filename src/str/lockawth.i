 /*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Блокирование формаирования автоматических документов МЦ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/24/06
Author: Bakhtadze Natalya
Creation date: 03/24/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

run gbl/lock-prc.p
    (input {&lock-prc-auto-wth-doc}
    ,input parobj-code
    ,input 0
    ,input 0
    ,input parobj-type
    ,input ""
    ,input ""
    ,input (
             "Код объекта" + ",,," +
             "Тип объекта" +  ",,,Формирование автоматических документов МЦ"
           )
    ,input true
    ,buffer auto-wth-doc-lock_batchprocess
    ) no-error .

  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "В данный момент уже производится формирование автоматических документов МЦ" skip
      view-as alert-box error .
    undo, return error . /* --->>>--- */
  end.


  /* $Workfile$ e n d */