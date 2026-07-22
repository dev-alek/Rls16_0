/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Функция получающая № смены по буферу (для показа в справочниках)

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/17/06
Author: Bakhtadze Natalya
Creation date: 01/17/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

{ str/lib-trn.i }

function shift-name-no-err return char (
                                        &if "{3}" = "temp"
                                        &then
                                        buffer loc-{1} for {1}
                                        &else
                                        buffer loc-{1} for ub.{1}
                                        &endif
&if "{2}" = "shift-name" or "{2}" = "shift-num" &then

&else
                                       ,input {2} as character
 &endif
 ).
define variable varshift-name as character no-undo.
define variable varshift-name-num as character no-undo.
&if "{2}" = "shift-name" &then
  varshift-name = loc-{1}.shift-name.
&else
  &if "{2}" = "shift-num" &then
    varshift-name = string(loc-{1}.shift-num).
  &else
    varshift-name = {2}.
  &endif
&endif

  { str/shiftnme.i
    loc-{1}.obj-type
    loc-{1}.obj-code
    loc-{1}.shift-date
    loc-{1}.shift-num
    varshift-name
    varshift-name-num
    no-error
  }
  if error-status:error then do:
    return "":u.
  end.
  return varshift-name-num.
end function.

/* $Workfile$ e n d */