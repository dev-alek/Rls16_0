/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Закрытие потока и сопутствующие операции для кассы IPC-SERVIS+

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/08/03
Author: Bakhtadze Natalya
Creation date: 12/08/03

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&if "{&subject}" = "good" &then
  output stream plucash close.
  output stream bar close.
  assign
  out-list = out-list + (if out-list = '':U then '':U else {&comma-char}) + out
  fname-list = fname-list + (if fname-list = '':U then '':U else {&comma-char}) + fname
  .
&if "{&called}" = "del-gds" &then
  os-copy
  value( string( session:temp-directory + "plu" + string( var-report-num ) ) + '.plu' )
  value( out + fname +
              (if ModeType then '.cpc' else '.upc')).
  os-copy
  value( string( session:temp-directory + "bar" + string( var-report-num ) ) + '.bar' )
  value( out + fname +
              (if ModeType then '.cbr' else '.ubr')).
  if LAST-OF({&cd-buffer}.cash-on) then do:
    /*примочка для ЦУМа чтобы не ждать пока кассир нажмет кнопку на кассе при числе касс больше 1 в секции*/
    DO var-file-num = 1 to num-entries(fname-list):
      run str/waitp.w (
                    INPUT (entry(var-file-num, out-list) + entry(var-file-num, fname-list) + (if ModeType then '.cbr' else '.ubr'))
                  ,INPUT ('Передача товаров на кассу ' + entry(var-file-num, out-list))
                  ,INPUT (' Подождите 15 сек ')
                  ,INPUT ('Касса не ответила. Если Вы уверены, что с ней нет связи нажмите кнопку!')
                  ,INPUT 15 ) no-error.
      if error-status:error then do:
      /*файлы не стираются - СЕНИН ЭТОГО ХОТЕЛ - ПУСТЬ ПЕНЯЕТ НА СЕБЯ!!!!*/
      /*
          os-delete value( out + fname + (if ModeType then '.cpc' else '.upc') ) .
          os-delete value( out + fname + (if ModeType then '.cbr' else '.ubr') ).
      */
          return error.
      end.
    END .
  end.
&else
  os-copy
  value( string( session:temp-directory + "plu" + string( var-report-num ) ) + '.plu' )
  value( out + fname + '.upc').
  os-copy
  value( string( session:temp-directory + "bar" + string( var-report-num ) ) + '.bar' )
  value( out + fname + '.ubr').
  if not g#news
  and not g#auto
  then do:
    if LAST-OF({&cd-buffer}.cash-on) then do:
      DO var-file-num = 1 to num-entries(fname-list):
        run str/waitp.w (
                      INPUT (entry(var-file-num, out-list) + entry(var-file-num, fname-list) +  '.ubr')
                    ,INPUT ('Передача товаров на кассу ' + entry(var-file-num, out-list))
                    ,INPUT (' Подождите 15 сек ')
                    ,INPUT ('Касса не ответила. Если Вы уверены, что с ней нет связи нажмите кнопку!')
                    ,INPUT 15

                      ) no-error .
        if error-status:error then do:
      /*файлы не стираются - СЕНИН ЭТОГО ХОТЕЛ - ПУСТЬ ПЕНЯЕТ НА СЕБЯ!!!!*/
        /*
            os-delete value( out + fname + '.upc' ) .
            os-delete value( out + fname + '.ubr' ).
        */
            return error.
        end.
      END.
    END .
  end.
&endif
&endif
/*subject = good*/

&if "{&subject}" = "dis-card" &then
  output close.
  assign
  out-list = out-list + (if out-list = '':U then '':U else {&comma-char}) + out
  fname-list = fname-list + (if fname-list = '':U then '':U else {&comma-char}) + fname.
  os-append
  value( string( session:temp-directory + "cli" + string( var-report-num ) ) + '.cli' )
  value( out + fname + (if action = "U" then '.udc' else 'cdc')).
  /*  ждем отзывов с мест   !!!!! */
  /*
  if not g#news
  and not g#auto
  then do:
    if LAST-OF({&cd-buffer}.cash-on) then do:
      if not run-from = "S":U then do:
        /*примочка для ЦУМа чтобы не ждать пока кассир нажмет кнопку на кассе при числе касс больше 1 в секции*/
        DO var-file-num = 1 to num-entries(fname-list):
          run str/waitp.w ( INPUT (entry(var-file-num, out-list) + entry(var-file-num, fname-list) + (if action = "U" then '.udc' else 'cdc'))
                              ,INPUT ('Передача клиентов на кассу ' + entry(var-file-num, out-list))
                              ,INPUT (' Подождите 15 сек ')
                              ,INPUT ('Касса не ответила. Если Вы уверены, что с ней нет связи нажмите кнопку!')
                              ,INPUT 15
                            )  no-error.
        END .
      end.
    end.
    if error-status:error then do:
      return error.
    end.

  end.
  */
&endif

&if "{&subject}" = "seller" &then
  output stream IbmStream close.
  assign
  out-list = out-list + (if out-list = '':U then '':U else {&comma-char}) + out
  fname-list = fname-list + (if fname-list = '':U then '':U else {&comma-char}) + fname.
  os-append
  value( string( session:temp-directory + "depart" + string( var-report-num ) ) + '.dep' )
  value( out + fname + (if action = "U" then '.udp' else 'cdp')).
  /*  ждем отзывов с мест   !!!!! */
  if not g#news
  and not g#auto
  then do:
    if LAST-OF({&cd-buffer}.cash-on) then do:
      /*примочка для ЦУМа чтобы не ждать пока кассир нажмет кнопку на кассе при числе касс больше 1 в секции*/
      DO var-file-num = 1 to num-entries(fname-list):
        run str/waitp.w ( INPUT (entry(var-file-num, out-list) + entry(var-file-num, fname-list) + (if action = "U" then '.udp' else 'cdp'))
                            ,INPUT ('Передача продавцов на кассу ' + entry(var-file-num, out-list))
                            ,INPUT (' Подождите 15 сек ')
                            ,INPUT ('Касса не ответила. Если Вы уверены, что с ней нет связи нажмите кнопку!')
                            ,INPUT 15
                          )  no-error.
      END .
    end.
    if error-status:error then do:
      return error.
    end.
  end.
&endif
&if "{&subject}" = "currency" &then
  output stream ibmstream close.
  os-rename value( out + fname + '.cur' ) value( out + fname + '.urr' ) .
  run str/wait.w ( out + fname + '.urr',
            'Передача курсов на кассу ' + out ) NO-ERROR.
  if error-status:error then return error.
&endif


/* $Workfile$ e n d */