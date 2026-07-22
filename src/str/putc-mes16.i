/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Отсылка сообщения на кассу 

Автор: Шкляр Елена
Дата создания: 02/19/06
Author: Shklyar Elena
Creation date: 02/19/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
&glob xml-cd-doc-name 'control'

    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute("Пересылка cообщения - касса &1", for-cash-desk.cash-num)
                                                      ).
    /*открываем поток*/
    { str/outc-gen.i
      &cd-buffer=for-cash-desk
      &subject=pay
      &data-by=object
      &out-title="'отправка сообщения'"
      &cdt-ibm=no
      &cdt-ibm-xml=yes
      &cdt-maria=no
      }
      /*сформируем вывод для кассы определенного типа*/

run bgelib-tag-open in this-procedure ( input 2, input "Command":U,"ctrl='ADD'").
run bgelib-tag-put in this-procedure ( input 3, input "CommType":U, input "message", input 1 ).
run bgelib-tag-put in this-procedure ( input 3, input "CommValue":U, input "Внимание!!! Перезагрузите кассу, для обновления промоакций!", input 1 ).                                  
run bgelib-tag-close in this-procedure ( input 2, input "Command":U).

      /*закрываем поток*/
    { str/cloc-gen.i
      &cd-buffer=for-cash-desk
      &subject=pay
      &data-by=object
      &out-title-add="'отправка сообщения '"
      &out-title-del="''"
      &cdt-ibm=no
      &cdt-ibm-xml=yes
      &cdt-maria=no
      }


/* $Workfile$ e n d */



