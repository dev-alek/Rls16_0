/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

закрытие потока и сопутствующие операции для кассы OMRON-NEW

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/08/03
Author: Bakhtadze Natalya
Creation date: 12/08/03

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&if "{&subject}" = "good" &then
  output close.
  output to value(out  + 'plu.adr') convert target "ibm866".
  if v-versiond >= 33.0 then do:
    put unformatted "OK" skip.
  end.
  output close.
  run str/waitp.w (out + 'plu.adr',
                        (if action = 'U'
                          then 'Ждите - идет добавление товаров на кассу '
                          else 'Ждите - идет удаление товаров с кассы ' ) + out,
                        ' Подождите 15 сек ',
                        'Касса не ответила. Если Вы уверены, что с ней нет связи нажмите кнопку!',
                        15 ) no-error.
  if error-status:error then return error.

&endif
&if "{&subject}" = "dis-card" &then
  output close.
  output to value(out  + 'client.adr') convert target "ibm866".
  if v-versiond >= 33.0 then do:
    put unformatted "OK" skip.
  end.
  output close.
  run str/waitp.w (out + 'client.adr',
                        ( if action = 'U'
                          then 'Ждите - идет добавление клиентов на кассу '
                          else 'Ждите - идет удаление клиентов с кассы ' ) + out,
                        ' Подождите 15 сек ',
                        'Касса не ответила. Если Вы уверены, что с ней нет связи нажмите кнопку!',
                        15 ) no-error.
  if error-status:error then return error.
&endif

&if "{&subject}" = "currency" &then
      output close.
      output to value( out  + fname + '.adr' ) convert target "ibm866".
      put unformatted "OK" skip.
      output close.
      run str/waitp.w (out  + fname + '.adr'
                , ( 'Ждите - идет добавление курсов валют на кассу ' + out)
                , ' Подождите 15 сек '
                ,  'Касса не ответила. Если Вы уверены, что с ней нет связи нажмите кнопку!',
                            15 ) no-error.
      if error-status:error then return error.
&endif


/* $Workfile$ e n d */