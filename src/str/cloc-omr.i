/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Закрытие потока и сопутствующие операции для кассы OMRON

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/08/03
Author: Bakhtadze Natalya
Creation date: 12/08/03

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&if "{&subject}" = "good" or "{&subject}" = "currency" &then
if action  = "U" then do:
  output close.
  output to value( out + fname + '.adr' ) convert target "ibm866".
  put ' ' skip(1). /* две пустые строки */
  &if "{&subject}" = "good" &then
  put unformatted '  ' {&cd-buffer}.addr-path ' plu' skip.
  &endif
  &if "{&subject}" = "currency" &then
  put unformatted '  ' {&cd-buffer}.addr-path ' currency' skip.
  &endif
  output close.
  run str/wait.w ( out + fname + '.dat', "{&out-title-add}" ) NO-ERROR.
  if error-status:error then return .

  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute( "&1 Касса &2: Данные выгружены в файл &3"
                          , "{&out-title-add}"
                          , {&cd-buffer}.addr-path
                          , (out + fname + '.dat')
                                                   )
                                        ).
end.   /*action = U*/
&endif
/* $Workfile$ e n d */