/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/31/06
Author: Bakhtadze Natalya
Creation date: 08/31/06

*/


&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".


FUNCTION check-ip returns logical ( input p-ip-string as character, output p-mess as character):
define variable v-ii as integer no-undo .
define variable v-entry as character no-undo .
define variable v-entry-int as integer no-undo .
IF num-entries(p-ip-string, ".") <> 4 then do:
  p-mess = substitute("Неверный IP-адрес &1&2" +
                      "IP-адрес должен иметь вид NNN.NNN.NNN.NNN"
                      ,p-ip-string
                      ,{&new-line}
                      ).
  return no.
end.
do v-ii = 1 to 4:
  v-entry = entry(v-ii, p-ip-string, '.':U).
  assign
  v-entry-int = integer(v-entry)
  no-error .
  if error-status:error then do:
    p-mess = substitute("Неверный IP-адрес &1&2" +
                        "IP-адрес должен состоять из 4 целых чисел, разделенных точками (NNN.NNN.NNN.NNN)"
                        ,p-ip-string
                        ,{&new-line}
                        ).
    return no.
  end.
  if v-entry-int < 0
  or v-entry-int > 255
  or trim(string(v-entry-int, ">>9")) <> v-entry
  then do:
    p-mess = substitute("Неверный IP-адрес &1&2" +
                        "IP-адрес должен состоять из 4 положительных целых чисел (0-255), разделенных точками (NNN.NNN.NNN.NNN) БЕЗ ЛИДИРУЮЩИХ НУЛЕЙ"
                        ,p-ip-string
                        ,{&new-line}
                        ).
    return no.
  end.
end.
return yes.
END FUNCTION.

/* $Workfile$ e n d */