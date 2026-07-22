/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/06/10
Author: Bakhtadze Natalya
Creation date: 07/06/10


*/

{ adm/pswd-enc.i
  &proc-name=dctpass_pswd-enc
}

FUNCTION dctpass_set-pswd returns character ( input p-date as date
                                           ,input p-emitent-host-code-chr as character
                                           ,input p-dc-type as character):
define variable v-password as decimal no-undo .
define variable v-password2 as character no-undo .
define variable v-dop as character no-undo .
define variable v-kk as integer no-undo .
  ASSIGN
  v-dop = string(p-date, "99/99/9999") +  p-emitent-host-code-chr +  p-dc-type
  .
  do v-kk = 1 to length(v-dop):
    v-password = v-password + asc(substring(v-dop, v-kk, 1)).
  end.
  run dctpass_pswd-enc in this-procedure ( input v-password, output v-password2).
  return v-password2.
end FUNCTION.