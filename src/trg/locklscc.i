/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Блокирование процесса вкл/выкл лок весовых кодов

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define buffer locK-batchprocess{&vssseq} for ub.batchprocess.

run gbl/lock-prc.p
    (input {&lock-prc-loc-sc-code}
    ,input 0
    ,input 0
    ,input 0
    ,input ""
    ,input ""
    ,input ""
    ,input (
            ",,,Вкл/выкл лок. вес. кодов"
           )
    ,input true
    ,buffer lock-batchprocess{&vssseq}
    ) no-error .
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "В данный момент идет процесс вкл/выкл лок. вес. кодов" skip
      view-as alert-box error .
    undo, return error . /* --->>>--- */
  end.





/* $Workfile$ e n d */