/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Вывод метода из БД в читаемом виде

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/26/06
Author: Bakhtadze Natalya
Creation date: 10/26/06

*/

{ rul/tempstrn.i }

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

procedure display-prop-script :
define parameter buffer buf_prop-script for ub.prop-script.

  do
  on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  :
    if buf_prop-script.script-type = {&prop-script-type-ifunction} then do:
      run temp-string_write in this-procedure ( input buf_prop-script.script-body ).
    end.
    else do:
      if lookup(buf_prop-script.proc-type, {&script-class-child-list}) > 0 then do:
      end.
      else do:
        run temp-string_write in this-procedure ( input buf_prop-script.script-head ).
        run temp-string_write in this-procedure ( input buf_prop-script.script-body ).
        run temp-string_write in this-procedure ( input buf_prop-script.script-foot ).
      end.
    end.
  end.

end procedure. /* display-prop-script */