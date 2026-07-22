block-level on error undo, throw.
/*

$Revision: 59ca1604305e, 148, rls $
$Author: EShklyar $
$Date: Mon Feb 16 20:50:15 2015 +0400 $
$Workfile: r-new-shift5.p $
$Archive: rep/r-new-shift5.p $

печать сменного отчета лист 5

Автор: Уханов Дмитрий Юрьевич
Дата создания: 08/06/07
Author: Dmitry Ukhanov
Creation date: 08/06/07

Автор: Булгаков Андрей Николаевич
Дата создания: 04/12/06
Author: Andrew Bulgakoff
Creation date: 04/12/06

*/

define input parameter parparentproc as   widget-handle       no-undo .
define input parameter p-parent-handle            as handle    no-undo .
define input parameter p-log-handle               as handle    no-undo .
define input parameter p-cont-handle              as handle    no-undo .
define input parameter p-rebh                     as handle    no-undo .
define input parameter v-report-name-html         as character no-undo .
define input parameter p-xsd-file                 as character no-undo .
define input parameter p-log-file-name            as character no-undo .
define input parameter p-batch                    as integer   no-undo .
define input parameter p-codex-id                 as integer   no-undo .
define input parameter p-ruleset-id               as integer   no-undo .
define input parameter p-obj-type    like ub.clients.obj-type no-undo .
define input parameter p-obj-code    like ub.clients.obj-code no-undo .

define variable vss-revision    as character no-undo initial "$Revision: 59ca1604305e, 148, rls $":U .
define variable vss-author      as character no-undo initial "$Author: EShklyar $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Feb 16 20:50:15 2015 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: r-new-shift5.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: rep/r-new-shift5.p $":U .
define variable vss-description as character no-undo initial "печать сменного отчета (ЮКОС лист 4)":U .

{ cmp/trg-def.i              }
{ cmp/r-page1.i              }
{ cmp/r-pril.i               }
{ rep/r-sym.i                }
{ rep/icm-5df.i "new shared" }


define shared stream PrnLibstream .

define variable pol1 as character no-undo .
define variable pol2 as decimal   no-undo .
define variable pol3 as decimal   no-undo .
define variable pol4 as decimal   no-undo .
define variable pol5 as decimal   no-undo .
define variable pol6 as decimal   no-undo .
define variable pol7 as decimal   no-undo .
define variable line as character no-undo .
define variable ii   as integer   no-undo .

/*переменные для вывода отчета в HTML*/
define stream Out-Stream.
define stream OutStr-html.
{ rep/r-shfth.i proc-def }
{ rep/r-shfth.i r-shift5 }

&scop display-message ~
   if p-batch > 0 then do: ~
     run write-log-and-file in p-log-handle ( ~
                input 1                            ~
              , input p-log-file-name                ~
              , input 1                            ~
              , input ~{&my-message}~). ~
   end. ~
   else do: ~
      run write-to-log in p-log-handle ( input ~{&my-message~}). ~
   end


&scop All-sym6 sym1 sym2 sym3 sym4 sym5 sym6


/* строки отчета */

run rep/r-shft5r.p
  ( input p-obj-type
  , input p-obj-code
  , input X-date-Start
  , input X-Shift-Start
  , input X-date-End
  , input X-Shift-End
  ) no-error .

/*шапка таблицы HTML*/
         
output stream OutStr-html to value(v-report-name-html) append convert target 'UTF-8' /*no-convert*/.
put stream OutStr-html unformatted
  substitute (
  '<tbody> <!-- Здесь начинается таблица отчета -->
            <tr> <!-- Первые строки – шапка таблицы с тэгами tr -->
                <th colspan="7" style="text-align: center;">Движение материальных ценностей</th>
            </tr>
            <tr>
                <th rowspan="2" style="text-align: center;">Наименование материальных ценностей</th>
                <th rowspan="2" style="text-align: center;">Остаток на начало смены</th>
                <th colspan="2" style="text-align: center;">Получено</th>
                <th colspan="2" style="text-align: center;">Инкассировано</th>
                <th rowspan="2" style="text-align: center;">Остаток на конец смены</th>
            </tr>
            <tr>
                <th style="text-align: center;">Выручка за смену</th>
                <th style="text-align: center;">Прочие источники</th>
                <th style="text-align: center;">В банк</th>
                <th style="text-align: center;">Прочие контрагенты</th>
            </tr>
            <tr>
                <th style="text-align: center;">5.1</th>
                <th style="text-align: center;">5.2</th>
                <th style="text-align: center;">5.3</th>
                <th style="text-align: center;">5.4</th>
                <th style="text-align: center;">5.5</th>
                <th style="text-align: center;">5.6</th>
                <th style="text-align: center;">5.7</th>                
            </tr>
            '
  , chr(123), chr(125)
  ).

for each t-5 no-lock use-index namei
:
  assign
    pol1 = t-5.wth-name
    pol2 = t-5.stock-before
    pol3 = t-5.income-cassa - t-5.incass-cassa
    pol4 = t-5.income-other
    pol5 = t-5.incass-bank
    pol6 = t-5.incass-other
    pol7 = t-5.stock-after
  .
    put stream OutStr-html unformatted
      substitute (
      '<tr>
                <td text_wrap="true" style="text-align: left;">&1</td>
                <td style="text-align: right;">&2</td>
                <td style="text-align: right;">&3</td>
                <td style="text-align: right;">&4</td>
                <td style="text-align: right;">&5</td>
                <td style="text-align: right;">&6</td>
                <td style="text-align: right;">&7</td>
            </tr>    
                '
      ,
      pol1,
      string(pol2,"->>>>>>>>>>>9.99"),
      string(pol3,"->>>>>>>>>>>9.99"),
      string(pol4,"->>>>>>>>>>>9.99"),
      string(pol5,"->>>>>>>>>>>9.99"),
      string(pol6,"->>>>>>>>>>>9.99"),
      string(pol7,"->>>>>>>>>>>9.99")
      ).

end. /* for each t-5 */
     output stream OutStr-html close.
     output stream OutStr-html to value(v-report-name-html) append convert target 'UTF-8' /*no-convert*/.
     put stream OutStr-html unformatted                                                                     
        substitute (
        '
        </tbody>
        '                                                                                      
            , chr(123), chr(125)                                                                                                 
       ).                                                                                                    
      output stream OutStr-html close.