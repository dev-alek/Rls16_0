/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Завершение работы с кассой типа NCR

Автор: Бахтадзе Наталья Викторовна
Дата создания: 06/23/03
Author: Bakhtadze Natalya
Creation date: 06/23/03

подчистки сообщения и т.д.
Для различных subject

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&if "{&subject}" = "good" or  "{&subject}" = "dis-card" or  "{&subject}" = "gds-obj-attr" &then
  /*надо положить на сервер*/
  /*сначала заблокируем процесс*/

  _lock-gds:
  DO while ind < 100 :

    run gbl/lock-prc.p (
         input {&lock-prc-put-ncr-gm}
        ,input i-obj-code
        ,input 0
        ,input 0
        ,input {&shop}
        ,input "":U
        ,input "":U
        ,input ("Код объекта" + ",,,":U +
                "Тип объекта" +  ",,,":U + {&out-title})
        ,input no
        ,buffer lock-batchprocess
        ) no-error .
    if not error-status:error then do:
      leave _lock-gds.
    end.
    run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute( "Объект &1: Файл для выгрузки данных ЗАНЯТ - Ждите", i-obj-code
                        )
                                        ).
    pause 1.
  end. /*DO while ind < 100 :*/

  /*скопируем в файл загрузки на сервер*/
  &if  "{&subject}" <> "gds-obj-attr" &then
    OS-append
    value( out + fname + '.dat':U )
    value( out + "gmrecmnt.dat":U).
    if search(out + 'debug.flg') = ? then do:
      OS-delete value( out + fname + '.dat':U ).
    end.
    if {&cd-buffer}.pos-type = {&cd-type-ncr-as-r} then do:
      output stream ibmstream to value( out + "gmrecmnt.ctl":U).
      put unformatted skip.
      output stream ibmstream close.

    &if  "{&subject}" = "good" &then

       v-found-good = no .

          { gbl/hostcode.i
         {&shop}
         i-obj-code
         i-host-code
        }

       for each cash-gds no-lock,
           first ub.bar-code no-lock where ub.bar-code.b-code = cash-gds.b-code :
          if can-find(first ub.dis-gds-rule-attr where
                            ub.dis-gds-rule-attr.gds-code = ub.bar-code.gds-code
                        and ub.dis-gds-rule-attr.obj-type = ""
                        and ub.dis-gds-rule-attr.obj-code = 0
                        and ub.dis-gds-rule-attr.pos-type = {&cd-type-ncr-as-r}) then
          do:
             v-found-good = yes.
             leave.
          end.
          if can-find(first ub.dis-gds-rule-attr where
                            ub.dis-gds-rule-attr.gds-code = ub.bar-code.gds-code
                        and ub.dis-gds-rule-attr.obj-type = {&cmp}
                        and ub.dis-gds-rule-attr.obj-code = i-host-code
                        and ub.dis-gds-rule-attr.pos-type = {&cd-type-ncr-as-r}) then
          do:
             v-found-good = yes.
             leave.
          end.
          if can-find(first ub.dis-gds-rule-attr where
                            ub.dis-gds-rule-attr.gds-code = ub.bar-code.gds-code
                        and ub.dis-gds-rule-attr.obj-type = {&shop}
                        and ub.dis-gds-rule-attr.obj-code = i-obj-code
                        and ub.dis-gds-rule-attr.pos-type = {&cd-type-ncr-as-r}) then
          do:
             v-found-good = yes.
             leave.
          end.

       end.
       if v-found-good then
       do:
         run output-ncr-bonus in this-procedure ( input i-host-code,
                                                      input i-obj-code,
                                                      input out,
                                                      output fname) .
         OS-append
           value( out + fname + '.dat':U )
           value( out + fname + ".pmt":U).
        if search(out + 'debug.flg') = ? then do:
          OS-delete value( out + fname + '.dat':U ).
        end.
        output stream ibmstream to value( out +  "pmt.ctl":U).
        put unformatted skip.
        output stream ibmstream close.
       end.
    &endif

    end.
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute( "Данные выгружены в файл &1"
                            ,( out + "gmrecmnt.dat":U)
                          )
                                         ).
    if g#news
    or g#auto
    or g#esys
    then do:
      run str/waitpn.w (
                   input (out + "gmrecmnt.dat":U)
                  ,input ( if action = 'U'
                            then ('Ждите - ' + {&out-title-add})
                            else ('Ждите - ' + {&out-title-del}) )
                  ,input ' Подождите 15 сек '
                  ,input 15
                  ) no-error.
    end.
    else do:
      run str/waitp.w (
                   input (out + "gmrecmnt.dat":U)
                  ,input ( if action = 'U'
                            then ('Ждите - ' + {&out-title-add})
                            else ('Ждите - ' + {&out-title-del}) )
                  ,input ' Подождите 15 сек '
                  ,input 'Касса не ответила. Если Вы уверены, что с ней нет связи нажмите кнопку!'
                  ,input 15
                  )
                  no-error.
    end.
    if error-status:error then do:
        run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute( "!!!Прерван обмен информацией с кассой, на кассе осталась устаревшая информация"
                              )
                                              ).
        os-delete value( out + "gmrecmnt.dat":U).
        assign
        v-view-log = yes
        .
        return "error":U.
    end.  /*if error-status:error then do:*/

&endif

  /*&if  "{&subject}" <> "gds-obj-attr" &then     1111 */

&endif

&if "{&subject}" = "good"
or  "{&subject}" = "gds-obj-attr"
or  "{&subject}" = "tot-discnt"
or  "{&subject}" = "sum-grp"
or  "{&subject}" = "parameters"
&then
  for each temp-dis-kat-file where
            temp-dis-kat-file.to-send = yes:
    OS-copy
    value(temp-dis-kat-file.temp-file)
    value(temp-dis-kat-file.send-file).
    if search(out + 'debug.flg') = ? then do:
      OS-delete value(temp-dis-kat-file.temp-file).
    end.
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
&if "{&subject}" = "parameters" &then
        , input substitute( "Параметры выгружены в файл &1"
&else
        , input substitute( "Данные по скидкам выгружены в файл &1"
&endif
                            , temp-dis-kat-file.send-file
                          )
                                          ).
  end.
&endif

&if "{&subject}" = "tot-discnt"  &then  /* ncr   бонусы фишки марки */
def var v_found as log no-undo .
   /* проверим на наличие бонусов для ncr */
   assign
     v_found = no
     .
   for each ub.dis-gds-rule no-lock where ub.dis-gds-rule.pos-type = {&cd-type-ncr-as-r}
                                      and  ub.dis-gds-rule.templ-rl-root = 91 :     /* бонусы по товару на кол-во    */
     if ub.dis-gds-rule.obj-type = "" and ub.dis-gds-rule.obj-code = 0 then      /* глобально   */
     do:
        v_found = yes.
        leave.
     end.
     if ub.dis-gds-rule.obj-type = {&cmp} and ub.dis-gds-rule.obj-code = v-host-code then      /* фирма   */
     do:
        v_found = yes.
        leave.
     end.
     if ub.dis-gds-rule.obj-type = {&shop} and ub.dis-gds-rule.obj-code = i-obj-code then      /* магазин   */
     do:
        v_found = yes.
        leave.
     end.

   end.
   if v_found = no then
   do:
    for each ub.dis-thbj-rule no-lock where ub.dis-thbj-rule.pos-type = {&cd-type-ncr-as-r} :  /* бонусы на итог и правило для подсчета бонусов*/
     if (ub.dis-thbj-rule.templ-rl-root = 90 or
        ub.dis-thbj-rule.templ-rl-root = 92 ) and
        ub.dis-thbj-rule.obj-type = "" and
        ub.dis-thbj-rule.obj-code = 0 then      /* глобально   */
     do:
        v_found = yes.
        leave.
     end.
     if (ub.dis-thbj-rule.templ-rl-root = 90 or
        ub.dis-thbj-rule.templ-rl-root = 92 ) and
        ub.dis-thbj-rule.obj-type = {&cmp} and
        ub.dis-thbj-rule.obj-code = v-host-code then      /* фирма   */
     do:
        v_found = yes.
        leave.
     end.
     if (ub.dis-thbj-rule.templ-rl-root = 90 or
        ub.dis-thbj-rule.templ-rl-root = 92 ) and
        ub.dis-thbj-rule.obj-type = {&shop} and
        ub.dis-thbj-rule.obj-code = i-obj-code then      /* магазин   */
     do:
        v_found = yes.
        leave.
     end.

    end.

   end.

   if v_found then
   do:
     def var ind as int no-undo .
     run output-ncr-bonus in this-procedure ( input v-host-code,
                                              input i-obj-code,
                                              input out,
                                              output fname) .

     _lock-bonus :
     DO while ind < 100 :

       run gbl/lock-prc.p (
         input {&lock-prc-put-ncr-gm}
        ,input i-obj-code
        ,input 0
        ,input 0
        ,input {&shop}
        ,input "":U
        ,input "":U
        ,input ("Код объекта" + ",,,":U +
                "Тип объекта" +  ",,,":U + {&out-title})
        ,input no
        ,buffer lock-batchprocess
        ) no-error .
       if not error-status:error then do:
         leave _lock-bonus.
       end.
       run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute( "Объект &1: Файл для выгрузки бонусов ЗАНЯТ - Ждите", i-obj-code
                        )
                                        ).
       pause 1.
     end. /*DO while ind < 100 :*/

    OS-append
    value( out + fname + '.dat':U )
    value( out + fname + ".pmt":U).
    if search(out + 'debug.flg') = ? then do:
      OS-delete value( out + fname + '.dat':U ).
    end.
    if {&cd-buffer}.pos-type = {&cd-type-ncr-as-r} then do:
      output stream ibmstream to value( out +  "pmt.ctl":U).
      put unformatted skip.
      output stream ibmstream close.
    end.
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute( "Бонусы выгружены в файл &1"
                            ,( out + fname + ".pmt":U)
                          )
                                         ).
    if g#news
    or g#auto
    or g#esys
    then do:
      run str/waitpn.w (
                   input (out + fname + ".pmt":U)
                  ,input ( if action = 'U'
                            then ('Ждите - ' + {&out-title-add})
                            else ('Ждите - ' + {&out-title-del}) )
                  ,input ' Подождите 15 сек '
                  ,input 15
                  ) no-error.
    end.
    else do:
      run str/waitp.w (
                   input (out + fname + ".pmt":U)
                  ,input ( if action = 'U'
                            then ('Ждите - ' + {&out-title-add})
                            else ('Ждите - ' + {&out-title-del}) )
                  ,input ' Подождите 15 сек '
                  ,input 'Касса не ответила. Если Вы уверены, что с ней нет связи нажмите кнопку!'
                  ,input 15
                  )
                  no-error.
    end.
    if error-status:error then do:
        run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute( "!!!Прерван обмен информацией с кассой, на кассе осталась устаревшая информация"
                              )
                                              ).
        os-delete value( out + fname + ".pmt":U).
        assign
        v-view-log = yes
        .
        return "error":U.
    end.  /*if error-status:error then do:*/

   end.


&endif


/* $Workfile$ e n d */