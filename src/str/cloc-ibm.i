/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

закрытие потока и сопутствующие операции для кассы IBM

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/08/03
Author: Bakhtadze Natalya
Creation date: 12/08/03

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

output stream IBMStream close.
output stream IBMStream
to value( (if {&cd-buffer}.remote = 1
            then (v-dir-remote-tmp + {&slash-char} + "fl":U)
            else out) + fname + '.ad0' ) convert target "ibm866".
put stream IBMStream ' ' skip(1). /* две пустые строки */

&if "{&subject}" = "currency" &then
  if Cash-OS2
  then
  put stream IbmStream unformatted  '  ' {&cd-buffer}.addr-path  ' plu':U skip .
  else
  put stream IbmStream unformatted  '  ' {&cd-buffer}.addr-path  ' currency':U skip .
&else
 put stream IBMStream unformatted '  ' {&cd-buffer}.addr-path ' plu' skip.
&endif
output stream IBMStream close.
OS-RENAME
VALUE((if {&cd-buffer}.remote = 1
        then (v-dir-remote-tmp + {&slash-char} + "fl":U)
        else out) + fname + '.ad0')
VALUE((if {&cd-buffer}.remote = 1
        then (v-dir-remote + {&slash-char} + "fl":U)
        else out) + fname + '.adr').
os-er = OS-ERROR.
run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute( "Данные выгружены в файл &1, файл адреса &2"
                        , ((if {&cd-buffer}.remote = 1
                            then (v-dir-remote + {&slash-char} + "fl":U)
                            else out) + fname + '.dat')
                        , ((if {&cd-buffer}.remote = 1
                            then (v-dir-remote + {&slash-char} + "fl":U)
                            else out) + fname + '.adr')

                        )
                                       ).

if os-er <> 0 then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute( "!!!Ошибки в работе локальной сети или нарушение прав доступа при обмене информацией с кассой &1",
                            {&cd-buffer}.cash-num
                        )
                                        ).
      assign
      v-view-log = yes
      .
      return "error":U.
end.
if {&cd-buffer}.remote = 1 then do:
  OS-RENAME
  VALUE(v-dir-remote-tmp + {&slash-char} + "fl":U + fname + '.dat')
  VALUE(v-dir-remote  + {&slash-char} + "fl":U + fname + '.dat').
  os-er = OS-ERROR.
  if os-er <> 0 then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute( "!!!Ошибки в работе локальной сети или нарушение прав доступа при обмене информацией с кассой &1",
                                {&cd-buffer}.cash-num
                            )
                                            ).
      assign
      v-view-log = yes
      .
      return "error":U.
  end.
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute( "Данные выгружены в файл &1",
                            (v-dir-remote  + {&slash-char} + "fl":U + fname + '.dat')
                        )
                                        ).
end.
else do:
/*not remote*/
  if not g#news
  and not g#auto
  and not g#esys
  then do:
    &if "{&called}" = "in-ov"
    or "{&called}"  = "pdf"
    or "{&subject}" = "dis-card"
    or "{&subject}" = "seller"
    or "{&subject}" = "pay"
    or "{&subject}" = "cashier"
    or "{&subject}" = "gds-obj-attr"
    or "{&subject}" = "sum-grp"
    or "{&subject}" = "tot-discnt"
    or "{&subject}" = "tax"
    &then
      run str/waitp.w ( out + fname + '.dat',
                  ( if action = 'U'
                    then ('Ждите - ' + {&out-title-add})
                    else ('Ждите - ' + {&out-title-del}) ) +
                    {&cd-buffer}.addr-path,
                    ' Подождите 15 сек ',
                    'Касса не ответила. Если Вы уверены, что с ней нет связи нажмите кнопку!',
                    15 ) no-error.
    if error-status:error then do:
      os-delete value( out + fname + '.adr' ) .
      os-delete value( out + fname + '.ad0' ) .
      os-delete value( out + fname + '.dat' ) .
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute( "!!!Прерван обмен информацией с кассой &1, на кассе осталась устаревшая информация",
                                {&cd-buffer}.cash-num
                            )
                                            ).
      assign
      v-view-log = yes
      .
      return "error":U.
    end.
    &endif
  end.
end.
/* not remote*/

/* $Workfile$ e n d */