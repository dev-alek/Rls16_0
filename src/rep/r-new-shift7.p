block-level on error undo, throw.
/*

$Revision: 59ca1604305e, 148, rls $
$Author: EShklyar $
$Date: Mon Feb 16 20:50:15 2015 +0400 $
$Workfile: r-new-shift7.p $
$Archive: rep/r-new-shift7.p $

печать сменного отчета лист 7

Автор: Уханов Дмитрий Юрьевич
Дата создания: 07/27/07
Author: Dmitry Ukhanov
Creation date: 07/27/07

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
define input parameter p-previous-shift-date as date      no-undo.

define variable vss-revision    as char no-undo init "$revision: 2 $":u.
define variable vss-author      as char no-undo init "$author: mkochetkov $":u.
define variable vss-date        as char no-undo init "$date: 7.03.07 10:38 $":u.
define variable vss-workfile    as char no-undo init "$workfile: r-shift5.p $":u.
define variable vss-archive     as char no-undo init "$archive: /ver14_0/rep/r-shift5.p $":u.
define variable vss-description as char no-undo init "$Печать сменного отчета - лист 5 $":u.


{ cmp/str-glbl.i             }
{ cmp/r-page1.i              }
{ cmp/r-pril.i               }
{ rep/r-sym.i                }
{ rep/icm-7df.i "new shared" }


define   shared stream  PrnLibStream.

define variable pol1 as integer   no-undo .
define variable pol2 as integer   no-undo .
define variable pol3 as character no-undo .
define variable pol4 as integer   no-undo .
define variable pol5 as decimal   no-undo .

define variable line as character no-undo .
/*define variable ii as integer no-undo.*/

/*переменные для вывода отчета в HTML*/
define stream Out-Stream.
define stream OutStr-html.

{ rep/r-shfth.i proc-def }
{ rep/r-shfth.i r-shift7 }

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

/* строки отчета  */

run rep/r-shft7r.p
  ( input p-obj-type
   ,input p-obj-code
   ,input X-date-Start
   ,input X-Shift-Start
   ,input X-date-End
   ,input X-Shift-End
   ,input p-previous-shift-date
  ) no-error.

/*шапка таблицы HTML*/
         
output stream OutStr-html to value(v-report-name-html) append convert target 'UTF-8' /*no-convert*/.
put stream OutStr-html unformatted
  substitute (
  '<tbody> <!-- Здесь начинается таблица отчета -->
            <tr> <!-- Первые строки – шапка таблицы с тэгами tr -->
                <th colspan="5" style="text-align: center;">Погрешности объемомеров ТРК</th>
            </tr>
            <tr>
                <th rowspan="2" style="text-align: center;">№ ТРК</th>
                <th rowspan="2" style="text-align: center;">№ Пистолета</th>                
                <th rowspan="2" style="text-align: center;">Наименование топлива</th>
                <th colspan="2" style="text-align: center;">Величина погрешности ТРК "+" недолив "-" перелив</th>
            </tr>
            <tr>
                <th style="text-align: center;">мл</th>
                <th style="text-align: center;">%</th>                
            </tr>
            <tr>
                <th style="text-align: center;">7.1</th>
                <th style="text-align: center;">7.2</th>
                <th style="text-align: center;">7.3</th>
                <th style="text-align: center;">7.4</th>
                <th style="text-align: center;">7.5</th>
            </tr>
            '
  , chr(123), chr(125)
  ).


for each t-7 no-lock
  use-index pi
on error undo, return error return-value
:
  assign
    pol1 = t-7.pump-code
    pol2 = t-7.nozzle-code
    pol3 = t-7.gds-name
    pol4 = ( t-7.state-el-cnt - t-7.state-mh-cnt ) * 1000
    pol5 = ( t-7.state-el-cnt - t-7.state-mh-cnt ) * 100 * 1000 / ( t-7.state-mh-cnt * 1000 )  /* для большей точности вычисления % считаем от миллилитров */
  .

    put stream OutStr-html unformatted
      substitute (
      '<tr>
                <td text_wrap="true" style="text-align: right;">&1</td>
                <td text_wrap="true" style="text-align: right;">&2</td>
                <td text_wrap="true" style="text-align: left;">&3</td>
                <td style="text-align: right;">&4</td>
                <td style="text-align: right;">&5</td>
            </tr>    
                '
      ,
      pol1,
      pol2,
      pol3,
      string(pol4,"->>>>>>>>>>>9.99"),
      string(pol5,"->>>>>>>>>>>9")
      ).
END.
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