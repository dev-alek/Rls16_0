/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Проверка возможности создания строки с данным бар-кодом

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/24/07
Author: Bakhtadze Natalya
Creation date: 12/24/07

*/

&scoped-define vssseq {&sequence}
def var vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

{ cmp/str-glbl.i }

procedure check-use-bar-code :
  define input  parameter p-b-code    like ub.bar-code.b-code no-undo .

  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-include-info{&vssseq} )
  on endkey undo, return error substitute( "&1. endkey", vss-include-info{&vssseq} )
  :
    define buffer buf_bar-code for ub.bar-code .
    find first buf_bar-code no-lock
      where buf_bar-code.b-code     = p-b-code
      no-error .
    if not available buf_bar-code then do:
      return error substitute( "&1 (check-use-bar-code). Не найден бар-код &2", vss-include-info{&vssseq}, p-b-code ) .
    end.

    if buf_bar-code.stts = integer({&hn-delete}) then do:
      return error substitute( "&1 (check-use-bar-code). Нельзя использовать бар-код &2&3"
                              + "Выполняется удаление бар-кода"
                              ,vss-include-info{&vssseq}
                              ,p-b-code
                              ,{&new-line}
                            ) .
    end.
    if buf_bar-code.stts = integer({&hn-switch-off}) then do:
      return error substitute( "&1 (check-use-bar-code). Нельзя использовать бар-код &2&3"
                              + "Бар-код выключен"
                              ,vss-include-info{&vssseq}
                              ,p-b-code
                              ,{&new-line}
                            ) .
    end.
    return .
  end.

end procedure. /* check-use-bar-code */

/* $Workfile$ e n d */