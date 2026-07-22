/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Получение порядкого номера смены по кассовому

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/19/06
Author: Bakhtadze Natalya
Creation date: 01/19/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

FUNCTION {1}get-ranged-shift-num returns integer (input p-shift-num-list as character
                                              ,input p-status-list as character):
 if num-entries(p-shift-num-list) = 1 then return integer(p-shift-num-list).
 if index(p-status-list, '3') > 0 then return integer(entry(lookup('3', p-status-list) ,p-shift-num-list )).
 if index(p-status-list, '2') > 0 then return integer(entry(lookup('2', p-status-list) ,p-shift-num-list )).
 if index(p-status-list, '1') > 0 then return integer(entry(lookup('1', p-status-list) ,p-shift-num-list )).
 if index(p-status-list, '0') > 0 then return integer(entry(lookup('0', p-status-list) ,p-shift-num-list )).
END FUNCTION.

procedure {1}get-shift-num :
define input parameter p-obj-type like ub.chk-doc.obj-type no-undo .
define input parameter p-obj-code like ub.chk-doc.obj-code no-undo .
define input parameter p-shift-date like ub.chk-doc.shift-date no-undo .
define input parameter p-shift-name as character no-undo .
define output parameter p-shift-num as integer no-undo .

define variable v-shift-num-list as character no-undo .
define variable v-status-list as character no-undo .
define buffer buf_shift-obj for ub.shift-obj .

  do
  on error undo, return error
  :
    for each  buf_shift-obj no-lock  where
            buf_shift-obj.obj-type    = p-obj-type
        AND  buf_shift-obj.obj-code   = p-obj-code
        AND  buf_shift-obj.shift-date = p-shift-date
        and  buf_shift-obj.shift-name = p-shift-name
        on error undo, return error return-value :
      /*пишем слева для обеспечения обратной сортировки*/
      assign
      v-shift-num-list = string(buf_shift-obj.shift-num) +
                        (if v-shift-num-list = '':U then '':U else {&comma-char}) + v-shift-num-list
      v-status-list    = entry(lookup(buf_shift-obj.status_, {&sht-stts}), {&sht-stts-rank}) +
                        (if v-status-list = '':U then '':U else {&comma-char}) + v-status-list
      .
    end. /*          for each  buf_shift-obj no-lock  where*/
    if v-shift-num-list = '':U then do:
      p-shift-num = 0.
    end.
    else do:
      assign
      p-shift-num = {1}get-ranged-shift-num(v-shift-num-list, v-status-list).
    end.
  end. /*doe*/

end procedure. /* get-shift-num */

/* $Workfile$ e n d */