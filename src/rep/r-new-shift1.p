block-level on error undo, throw.
/*

$Revision: 6c8522455825, 2012, rls $
$Author: EShklyar $
$Date: Wed Sep 18 21:04:41 2019 +0300 $
$Workfile: r-new-shift1.p $
$Archive: rep/r-new-shift1.p $

печать сменного отчета часть 1

Автор: Уханов Дмитрий Юрьевич
Дата создания: 08/06/07
Author: Dmitry Ukhanov
Creation date: 08/06/07

*/

define input parameter parparentproc              as handle    no-undo.
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
define input parameter p-weight                   as logical   no-undo.
define input parameter p-param-shft-qty           as character no-undo .
define input parameter p-obj-type                 as character no-undo .
define input parameter p-obj-code                 as integer   no-undo .
define input parameter p-z-number-list            as character no-undo.
define input parameter p-tog-1-pump-one           as logical   no-undo .
define input parameter p-tog-1-whole-gds          as logical   no-undo .
define input parameter p-tog-1-out-pump-with-icnt as logical   no-undo .

define variable vss-revision    as character no-undo init "$Revision: 6c8522455825, 2012, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Wed Sep 18 21:04:41 2019 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-new-shift1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-new-shift1.p $":U .
define variable vss-description as character no-undo init "$Печать сменного отчета - лист 1 $":U.
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i }
{ cmp/r-pril.i }
{ rep/r-sym.i }
{ rep/r-gl.i }
{ rep/rshiftd1.i t "shared" }
{ rul/ruleset_.i }
{ ref/gds-attr.i }
{ str/is-gas.i }
{ str/placelib.i }
{ str/lib-calc.i }

  define variable v-stfactpl  as character no-undo initial "":U .
  define variable v-data-type as character no-undo initial "":U .
  define variable v-update    as logical   no-undo initial yes  .
  define variable v-revision  as logical   no-undo initial no   .
  define variable v-percrev   as decimal   no-undo initial ?    .
  define variable v-auto-tank as logical   no-undo initial no   .
  define variable v-percauto  as decimal   no-undo initial ?    .
  define variable v-inv       as logical   no-undo initial no   .
  define variable v-percinv   as decimal   no-undo initial ?    .
  define variable v-inv-set   as logical   no-undo initial no   .
  define variable stfactplvalue as character no-undo .
  define variable stfactpltype  as character no-undo .

define shared stream Prnlibstream.

define variable pol1 as character no-undo .
define variable pol2 as decimal no-undo .
define variable pol2-l-state as decimal no-undo .
define variable pol2-kg-state as decimal no-undo .
define variable pol2-l-system as decimal no-undo .
define variable pol2-kg-system as decimal no-undo .
define variable pol3 as decimal no-undo .
define variable pol4 as decimal no-undo .
define variable pol5 as decimal no-undo .
define variable pol5-el as decimal no-undo .
define variable pol6 as decimal no-undo .
define variable pol6-el as decimal no-undo .
define variable pol7 as decimal no-undo .
define variable pol8 as character no-undo.
define variable pol9 as decimal no-undo .
define variable pol10 as decimal no-undo .
define variable pol11 as decimal no-undo .
define variable pol12 as decimal no-undo .
define variable pol13 as decimal no-undo .
define variable pol14 as decimal no-undo .
define variable pol15 as decimal no-undo .
define variable pol151 as decimal no-undo .
define variable pol152 as decimal no-undo .
define variable pol153 as decimal no-undo .
define variable pol16 as decimal no-undo .
define variable pol16-l as decimal no-undo .
define variable pol16-kg as decimal no-undo .
define variable pol17 as decimal no-undo .
define variable pol18 as decimal no-undo .

&scop All-sym sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10 sym11 sym12 sym13 sym14 sym15 sym16 sym17 sym18 sym19 sym20
&scop All-Pol pol1 pol2 pol3 pol4 pol5 pol6 pol7 pol8 pol9 pol10 pol11 pol12 pol13 pol14 pol15 pol151 pol152 pol153 pol16 pol17 pol18
&scop All-pol16 pol1 pol2 pol3 pol4 pol5 pol6 pol7 pol8 pol9 pol10 pol11 pol12 pol13 pol14 pol15 pol151 pol152 pol153 pol16

{ rep/r-shfth.i proc-def }

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

&scop par-system         "system":U
&scop par-state          "state":U
&scop par-state-all-per  "state-all-per":U

define variable last-gds-code            as integer   no-undo initial 0.
define variable accum-by-pl-code-pol3-l  as decimal   no-undo.
define variable accum-by-pl-code-pol3-kg as decimal   no-undo.
define variable accum-pol3-l             as decimal   no-undo.
define variable accum-pol3-kg            as decimal   no-undo.
define variable accum-pol7               as decimal   no-undo.
define variable accum-by-pl-code-pol7 as decimal   no-undo.
define variable v-gds-print             as logical   no-undo.
define variable v-bc-print            as logical   no-undo .

define variable pobj-type    like  ub.stk-tot.obj-type   no-undo .
define variable pobj-code    like  ub.stk-tot.obj-code   no-undo .
define variable pshift-date  like  ub.stk-tot.shift-date no-undo .
define variable pshift-num   like  ub.stk-tot.shift-num  no-undo .
define variable pshift-date1 like  ub.stk-tot.shift-date no-undo .
define variable pshift-num1  like  ub.stk-tot.shift-num  no-undo .

define buffer previous-rvs-doc for ub.rvs-doc.
define buffer previous-rvs-line for ub.rvs-line.
define buffer previous-rvs-line-pump for ub.rvs-line-pump.

define buffer last-rvs-doc for ub.rvs-doc.
define buffer last-rvs-line for ub.rvs-line.
define buffer last-rvs-line-pump for ub.rvs-line-pump.

define buffer control-rvs-doc for ub.rvs-doc.
define buffer control-rvs-line-pump for ub.rvs-line-pump.
define buffer buf_shift-pgds for shift-pgdst.

define buffer buf_rvs-line-attr for ub.rvs-line-attr. /* Для газа */
define buffer buf_prev-rvs-line-attr for ub.rvs-line-attr. /* Для газа */
define buffer buf_control-rvs-doc for ub.rvs-doc. /* Для контрольной сверки, если нет сменной */
define variable i-rvs-code as character no-undo. /* Для контроьной или сменной сверки */

define variable p-host-code       as integer   no-undo.
define variable v-sign            as decimal   no-undo .

define temp-table tt-pump-nozzle no-undo
  field gds-code    like ub.rvs-line.gds-code
  field pump-code   like ub.rvs-line-pump.pump-code
  field nozzle-code like ub.rvs-line-pump.nozzle-code
  index pi as unique primary
    gds-code
    pump-code
    nozzle-code
.

define temp-table temp-line-pump no-undo /*временная таблица по резервуарам*/
  field gds-code      like ub.rvs-line.gds-code
  field pump-code     like ub.rvs-line-pump.pump-code
  field nozzle-code   like ub.rvs-line-pump.nozzle-code
  field state-mh-cnt  like ub.rvs-line-pump.state-mh-cnt
  field state-el-cnt  like ub.rvs-line-pump.state-el-cnt
  field previous-state-mh-cnt  like previous-rvs-line-pump.state-mh-cnt
  field previous-state-el-cnt  like previous-rvs-line-pump.state-el-cnt
  field pol6          like ub.rvs-line-pump.state-mh-cnt format '>>9.99'
  field pol7          like ub.rvs-line-pump.state-mh-cnt
  field pl-code       like ub.rvs-line-pump.pl-code
  field error-l       like ub.rvs-line-pump.state-el-cnt
  field error-kg      like ub.rvs-line-pump.state-el-cnt
  field error-19      like ub.rvs-line-pump.state-el-cnt 

  
  
  index pi as unique primary
    gds-code
    pl-code
    pump-code
    nozzle-code
.

define VARIABLE num-pol8-l  as decimal no-undo . 
define VARIABLE num-pol8-kg as decimal no-undo .
define VARIABLE num-pol20-l  as decimal no-undo . 
define VARIABLE num-pol20-kg as decimal no-undo .

define temp-table temp-rvs-line no-undo like ub.rvs-line
  field gds-name   like ub.goods.gds-name
  field place_loc1 like ub.place.loc1         initial "??"
  field shift-date like ub.rvs-doc.shift-date
  field shift-num  like ub.rvs-doc.shift-num
  field v-bar-code like ub.bar-code.b-code
  field artic      like ub.goods.artic
  field prod-type  like ub.goods.prod-type
  field prod-code  like ub.goods.prod-code
  field num-trk    as integer initial 0
  field pol2-l-state   as decimal
  field pol2-kg-state  as decimal
  field pol2-l-system  as decimal
  field pol2-kg-system as decimal
  field accum-pol3-l   as decimal
  field accum-pol3-kg  as decimal
  field accum-by-pl-code-pol3-l   as decimal
  field accum-by-pl-code-pol3-kg  as decimal  
  field accum-pol8-l   as decimal format '>>9.99'
  field accum-pol8-kg  as decimal format '>>9.99'
  field pol8-l         as decimal format '>>9.99'
  field pol8-kg        as decimal format '>>9.99'
  field pol14          as decimal
  field pol15-l        as decimal
  field pol15-kg       as decimal
  field pol16-l        as decimal
  field pol16-kg       as decimal
  field pol17-l        as decimal
  field pol17-kg       as decimal
  field pol18-l        as decimal
  field pol18-kg       as decimal
  field accum-pol20-l  as decimal
  field accum-pol20-kg as decimal
  field fact-pl        as decimal
.

define variable v-count    as integer   no-undo .
define variable v-count2   as integer   no-undo .
define variable v-tot-cnt  as integer   no-undo .

define buffer buf_rvs-line-pump for ub.rvs-line-pump .
define buffer buf_temp-rvs-line for temp-rvs-line .

define stream Out-Stream.
define stream OutStr-html.

assign
  pobj-type    = p-obj-type
  pobj-code    = p-obj-code
  pshift-date  = x-date-Start
  pshift-num   = x-shift-Start
  pshift-date1 = x-date-End
  pshift-num1  = x-shift-End
.

{ rep/r-shftfo.i }

{ gbl/hostcode.i p-obj-type p-obj-code p-host-code }

/* сверка данной смены*/
find first last-rvs-doc no-lock
  where last-rvs-doc.obj-type   = p-obj-type
    and last-rvs-doc.obj-code   = p-obj-code
    and last-rvs-doc.shift-date = x-date-end
    and last-rvs-doc.shift-num  = x-shift-end
    and last-rvs-doc.status_    = {&fact}
    and last-rvs-doc.rvs-type   = {&rvs-shift}
  no-error.
if not available last-rvs-doc then do:
  &scop my-message substitute("&1 &2 &3&4Не найдена сменная сверка&4объект &5&6 смена &7 &8"  ~
                               ,vss-workfile  ~
                               ,vss-revision  ~
                               ,vss-description ~
                               ,~{&new-line~} ~
                               ,p-obj-type  ~
                               ,p-obj-code  ~
                               ,string(x-date-End, "99/99/9999") ~
                               ,x-shift-end )
  {&display-message}.
  if valid-handle(p-parent-handle)
  and lookup("cb_write-report-error", p-parent-handle:internal-entries) > 0
  and valid-handle(p-rebh) then do:
    run cb_write-report-error in p-parent-handle ( input p-rebh
                                                  ,input v-report-name-html
                                                  ,input ?
                                                  ,input {&severity-high}
                                                  ,input {&my-message}).
  end.
  return error.
END.
/*нам надо еще знать сверку за предыдущую смену*/
/*предыдущая смена по объекту найдена в r-shftfo.i previous-shift-obj*/
if available previous-shift-obj then do:
  find first previous-rvs-doc no-lock
    where previous-rvs-doc.obj-type   = p-obj-type
      and previous-rvs-doc.obj-code   = p-obj-code
      and previous-rvs-doc.shift-date = previous-shift-obj.shift-date
      and previous-rvs-doc.shift-num  = previous-shift-obj.shift-num
      and previous-rvs-doc.status_    = {&fact}
      and previous-rvs-doc.rvs-type   = {&rvs-shift}
    no-error.
end.

/*Печать шапки отчета*/
    output stream OutStr-html to value(v-report-name-html) append convert target 'UTF-8' /*no-convert*/.
        put stream OutStr-html unformatted
            substitute (
          '<tbody> <!-- Здесь начинается таблица отчета -->
                <tr> <!-- Первые строки – шапка таблицы с тэгами tr -->
                <th rowspan="3" style="text-align: center;">Наименование нефтепродукта</th>
                <th rowspan="2" style="text-align: center;">Фактич. остаток на нач. смены</th>
                <th rowspan="2" style="text-align: center;">Посту-пило за смену (в том числе проверка ТРК)</th>
                <th colspan="4" style="text-align: center;">Показания счетных механизмов</th>
                <th colspan="12" style="text-align: center;"></th>
                <th colspan="2" style="text-align: center;">Результаты</th>
            </tr>
            <tr>
                <th rowspan="2" style="text-align: center;">№ ТРК</th>
                <th style="text-align: center;">на конец смены</th>
                <th style="text-align: center;">на начало смены</th>
                <th style="text-align: center;">расход</th>
                <th rowspan="2" style="text-align: center;">№ резервуара</th>
                <th style="text-align: center;">общий уровень, включая воду</th>
                <th style="text-align: center;">воды уровень</th>
                <th style="text-align: center;">общий объем, включая воду</th>
                <th style="text-align: center;">воды объем</th>
                <th style="text-align: center;">факт объем в тррубопроводе</th>
                <th style="text-align: center;">факт объем в резервуаре</th>
                <th style="text-align: center;">факт объем всего</th>
                <th style="text-align: center;">факт объем всего</th>
                <th style="text-align: center;">факт пл-ть</th>
                <th style="text-align: center;">факт темп.</th>
                <th style="text-align: center;">расчетный</th>
                <th style="text-align: center;">излишки</th>
                <th style="text-align: center;">недостач</th>
            </tr>
            '

            , chr(123), chr(125)
        ).
    output stream OutStr-html close.

if p-weight = true then do:

  /*килограммы*/
    output stream OutStr-html to value(v-report-name-html) append convert target 'UTF-8' /*no-convert*/.
        put stream OutStr-html unformatted
            substitute (
          '<tr>
                <th style="text-align: center;">кг</th>
                <th style="text-align: center;">кг</th>
                <th style="text-align: center;">л</th>
                <th style="text-align: center;">л</th>
                <th style="text-align: center;">л</th>
                <th style="text-align: center;">см</th>
                <th style="text-align: center;">см</th>
                <th style="text-align: center;">л</th>
                <th style="text-align: center;">л</th>
                <th style="text-align: center;">л</th>
                <th style="text-align: center;">л</th>
                <th style="text-align: center;">л</th>
                <th style="text-align: center;">кг</th>
                <th style="text-align: center;">кг/л</th>
                <th style="text-align: center;">С</th>
                <th style="text-align: center;">кг</th>
                <th style="text-align: center;">кг</th>
                <th style="text-align: center;">кг</th>
            </tr>
            <tr>
                <th style="text-align: center;">1.1</th>
                <th style="text-align: center;">1.2</th>
                <th style="text-align: center;">1.3</th>
                <th style="text-align: center;">1.4</th>
                <th style="text-align: center;">1.5</th>
                <th style="text-align: center;">1.6</th>
                <th style="text-align: center;">1.7</th>
                <th style="text-align: center;">1.8</th>
                <th style="text-align: center;">1.9</th>
                <th style="text-align: center;">1.10</th>
                <th style="text-align: center;">1.11</th>
                <th style="text-align: center;">1.12</th>
                <th style="text-align: center;">1.13</th>
                <th style="text-align: center;">1.14</th>
                <th style="text-align: center;">1.15</th>
                <th style="text-align: center;">1.15.1</th>
                <th style="text-align: center;">1.15.2</th>
                <th style="text-align: center;">1.15.3</th>
                <th style="text-align: center;">1.16</th>
                <th style="text-align: center;">1.17</th>
                <th style="text-align: center;">1.18</th>
            </tr>
            '

            , chr(123), chr(125)
        ).
    output stream OutStr-html close.

end.
else do:

  /*литры*/
      output stream OutStr-html to value(v-report-name-html) append convert target 'UTF-8' /*no-convert*/.
        put stream OutStr-html unformatted
            substitute (
          '<tr>
                <th style="text-align: center;">л</th>
                <th style="text-align: center;">л</th>
                <th style="text-align: center;">л</th>
                <th style="text-align: center;">л</th>
                <th style="text-align: center;">л</th>
                <th style="text-align: center;">см</th>
                <th style="text-align: center;">см</th>
                <th style="text-align: center;">л</th>
                <th style="text-align: center;">л</th>
                <th style="text-align: center;">л</th>
                <th style="text-align: center;">л</th>
                <th style="text-align: center;">л</th>
                <th style="text-align: center;">кг</th>
                <th style="text-align: center;">кг/л</th>
                <th style="text-align: center;">С</th>
                <th style="text-align: center;">л</th>
                <th style="text-align: center;">л</th>
                <th style="text-align: center;">л</th>
            </tr>
            <tr>
                <th style="text-align: center;">1.1</th>
                <th style="text-align: center;">1.2</th>
                <th style="text-align: center;">1.3</th>
                <th style="text-align: center;">1.4</th>
                <th style="text-align: center;">1.5</th>
                <th style="text-align: center;">1.6</th>
                <th style="text-align: center;">1.7</th>
                <th style="text-align: center;">1.8</th>
                <th style="text-align: center;">1.9</th>
                <th style="text-align: center;">1.10</th>
                <th style="text-align: center;">1.11</th>
                <th style="text-align: center;">1.12</th>
                <th style="text-align: center;">1.13</th>
                <th style="text-align: center;">1.14</th>
                <th style="text-align: center;">1.15</th>
                <th style="text-align: center;">1.16</th>
                <th style="text-align: center;">1.17</th>
                <th style="text-align: center;">1.18</th>
                <th style="text-align: center;">1.19</th>
                <th style="text-align: center;">1.20</th>
                <th style="text-align: center;">1.21</th>
            </tr>
            '

            , chr(123), chr(125)
        ).
    output stream OutStr-html close.
end.

for each ub.rvs-doc no-lock
  where ub.rvs-doc.obj-type   = p-obj-type
    and ub.rvs-doc.obj-code   = p-obj-code
    and ub.rvs-doc.shift-date >= x-date-Start
    and ub.rvs-doc.shift-date <= x-date-End
    and ub.rvs-doc.status_    = {&fact}
    and ub.rvs-doc.rvs-type   = {&rvs-shift}
on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
:
  if ub.rvs-doc.shift-date = x-date-Start and ub.rvs-doc.shift-num < x-Shift-Start then next .
  if ub.rvs-doc.shift-date = x-date-End   and ub.rvs-doc.shift-num > x-Shift-End then next .

  for each ub.rvs-line no-lock
    where ub.rvs-line.rvs-code = ub.rvs-doc.rvs-code
  on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
  :
    find first temp-rvs-line
      where temp-rvs-line.pl-code  = ub.rvs-line.pl-code
        and temp-rvs-line.gds-code = ub.rvs-line.gds-code
      no-error .
    if not available temp-rvs-line then do:
      create temp-rvs-line .
      buffer-copy ub.rvs-line to temp-rvs-line .
      find first ub.goods no-lock
        where ub.goods.gds-code = ub.rvs-line.gds-code
        no-error.
      assign
        temp-rvs-line.gds-name   = ub.goods.gds-name
        temp-rvs-line.artic      = ub.goods.artic
        temp-rvs-line.prod-type  = ub.goods.prod-type
        temp-rvs-line.prod-code  = ub.goods.prod-code
        temp-rvs-line.shift-date = ub.rvs-doc.shift-date
        temp-rvs-line.shift-num  = ub.rvs-doc.shift-num
      .
      { gbl/gdsbcode.i
        ub.goods.gds-code
        ?
        temp-rvs-line.v-bar-code
      }
      find first ub.place no-lock
        where ub.place.obj-code = p-obj-code
          and ub.place.obj-type = p-obj-type
          and ub.place.pl-code  = ub.rvs-line.pl-code
        no-error.
      if available ub.place then do:
        assign
          temp-rvs-line.place_loc1 = ub.place.loc1
        .
      end.
    end.
    else do:
      if temp-rvs-line.shift-date < ub.rvs-doc.shift-date
        or ( temp-rvs-line.shift-date = ub.rvs-doc.shift-date
              and temp-rvs-line.shift-num  < ub.rvs-doc.shift-num
            )
      then do:
        buffer-copy ub.rvs-line to temp-rvs-line .
      end.
    end.
  end.
end.

for each temp-rvs-line
  break by temp-rvs-line.gds-code by temp-rvs-line.pl-code
on error undo, return error return-value
:

  /* Если природный газ */
  if is-gas(temp-rvs-line.gds-code) then do:

      /* Найдём атрибуты сверки за текущую и предыдущую смены */
      
      find first buf_rvs-line-attr where buf_rvs-line-attr.obj-code = temp-rvs-line.obj-code
                                   and buf_rvs-line-attr.obj-type = temp-rvs-line.obj-type
                                   and buf_rvs-line-attr.gds-code = temp-rvs-line.gds-code
                                   and buf_rvs-line-attr.pl-code = temp-rvs-line.pl-code
                                   and buf_rvs-line-attr.rvs-code = temp-rvs-line.rvs-code
                                   and buf_rvs-line-attr.attr-code = "mask" no-lock no-error.
      
      /* На previous-rvs-doc мы уже стоим (строка 261) */
      
      /* Если не было сменной - берем контрольную */
      if not available previous-rvs-doc then do:
          
          find first buf_control-rvs-doc where buf_control-rvs-doc.obj-type = temp-rvs-line.obj-type
                                           and buf_control-rvs-doc.obj-code = temp-rvs-line.obj-code
                                           and buf_control-rvs-doc.shift-date = temp-rvs-line.shift-date
                                           and buf_control-rvs-doc.shift-num = temp-rvs-line.shift-num
                                           and buf_control-rvs-doc.status_ = {&fact}
                                           and buf_control-rvs-doc.rvs-type = {&rvs-control} no-lock no-error.
            
            i-rvs-code = buf_control-rvs-doc.rvs-code.
            
      end. /* if not available previous-rvs-doc */
      
      else i-rvs-code = previous-rvs-doc.rvs-code.
      
      find first previous-rvs-line where previous-rvs-line.rvs-code = i-rvs-code
                                     and previous-rvs-line.gds-code = temp-rvs-line.gds-code
                                     and previous-rvs-line.obj-code = temp-rvs-line.obj-code
                                     and previous-rvs-line.obj-type = temp-rvs-line.obj-type
                                     and previous-rvs-line.pl-code = temp-rvs-line.pl-code no-lock no-error.
      
      find first buf_prev-rvs-line-attr where buf_prev-rvs-line-attr.obj-code = temp-rvs-line.obj-code
                                        and buf_prev-rvs-line-attr.obj-type = temp-rvs-line.obj-type
                                        and buf_prev-rvs-line-attr.gds-code = temp-rvs-line.gds-code
                                        and buf_prev-rvs-line-attr.pl-code = temp-rvs-line.pl-code
                                        and buf_prev-rvs-line-attr.rvs-code = i-rvs-code
                                        and buf_prev-rvs-line-attr.attr-code = "mask" no-lock no-error.      


      
      /* Первая строчка для газа */
      
      assign
      pol1 = "Метан (КПГ)" .
      
      if available (previous-rvs-line) then pol2 = previous-rvs-line.state-level-total. else pol2 = 0 .  
      pol5 = temp-rvs-line.state-level-petrol .
      
      if available (previous-rvs-line) then pol6 = previous-rvs-line.state-level-petrol. else pol6 = 0 .
      assign
      pol7 = pol5 - pol6
      pol9 = temp-rvs-line.state-level-total.

       output stream OutStr-html to value(v-report-name-html) append convert target 'UTF-8' /*no-convert*/.
        put stream OutStr-html unformatted
            substitute (
          '<tr>
                <td>&1</td>
                <td style="text-align: right;">$2</td>
                <td style="text-align: center;"></td>
                <td style="text-align: center;"></td>
                <td style="text-align: center;">&3</td>
                <td style="text-align: right;">&4</td>
                <td style="text-align: right;">&5</td>
                <td style="text-align: center;"></td>
                <td style="text-align: right;">&6</td>
                <td style="text-align: center;"></td>
                <td style="text-align: center;"></td>
                <td style="text-align: center;"></td>
                <td style="text-align: center;"></td>
                <td style="text-align: center;"></td>
                <td style="text-align: center;"></td>
                <td style="text-align: center;"></td>
                <td style="text-align: center;"></td>
                <td style="text-align: center;"></td>
                <td style="text-align: center;"></td>
                <td style="text-align: center;"></td>
                <td style="text-align: center;"></td>
            </tr>
            ',
            pol1,
            string(pol2,"->>>>>>>>>>>9.99"),
            string(pol5,"->>>>>>>>>>>9.99"),
            string(pol6,"->>>>>>>>>>>9.99"),
            string(pol7,"->>>>>>>>>>>9.99"),
            string(pol9,"->>>>>>>>>>>9.99")
        ).
    output stream OutStr-html close. 
      
      /* Вторая строчка для газа */
      
      assign
      pol1 = "CH4 м3" .
      if available (buf_rvs-line-attr) then pol5 = integer(entry(1,buf_rvs-line-attr.attr-value, ";")) . else pol5 = 0 .
      if available (buf_prev-rvs-line-attr) then pol6 = integer(entry(1,buf_prev-rvs-line-attr.attr-value, ";")) . else pol6 = 0 .
      pol7 = pol5 - pol6.
      
       output stream OutStr-html to value(v-report-name-html) append convert target 'UTF-8' /*no-convert*/.
        put stream OutStr-html unformatted
            substitute (
          '<tr>
                <td>&1</td>
                <td style="text-align: right;"></td>
                <td style="text-align: center;"></td>
                <td style="text-align: center;"></td>
                <td style="text-align: center;">&2</td>
                <td style="text-align: right;">&3</td>
                <td style="text-align: right;">&4</td>
                <td style="text-align: center;"></td>
                <td style="text-align: right;"></td>
                <td style="text-align: center;"></td>
                <td style="text-align: center;"></td>
                <td style="text-align: center;"></td>
                <td style="text-align: center;"></td>
                <td style="text-align: center;"></td>
                <td style="text-align: center;"></td>
                <td style="text-align: center;"></td>
                <td style="text-align: center;"></td>
                <td style="text-align: center;"></td>
                <td style="text-align: center;"></td>
                <td style="text-align: center;"></td>
                <td style="text-align: center;"></td>
            </tr>
            ',
            pol1,
            string(pol5,"->>>>>>>>>>>9.99"),
            string(pol6,"->>>>>>>>>>>9.99"),
            string(pol7,"->>>>>>>>>>>9.99")
            
        ).
    output stream OutStr-html close.       
      /* Третья строчка для газа */
      assign
      pol1 = "Pвх-CH4 кгс/см2" .
      if available (buf_prev-rvs-line-attr) then pol2 = integer(entry(2,buf_prev-rvs-line-attr.attr-value, ";")). else pol2 = 0 .  
      if available (buf_rvs-line-attr) then pol15 = integer(entry(2,buf_rvs-line-attr.attr-value, ";")). else pol15 = 0 .
      
       output stream OutStr-html to value(v-report-name-html) append convert target 'UTF-8' /*no-convert*/.
        put stream OutStr-html unformatted
            substitute (
          '<tr>
                <td>&1</td>
                <td style="text-align: right;">&2</td>
                <td style="text-align: center;"></td>
                <td style="text-align: center;"></td>
                <td style="text-align: center;"></td>
                <td style="text-align: right;"></td>
                <td style="text-align: right;"></td>
                <td style="text-align: center;"></td>
                <td style="text-align: right;"></td>
                <td style="text-align: center;"></td>
                <td style="text-align: center;"></td>
                <td style="text-align: center;"></td>
                <td style="text-align: center;"></td>
                <td style="text-align: center;"></td>
                <td style="text-align: right;">&3</td>
                <td style="text-align: center;"></td>
                <td style="text-align: center;"></td>
                <td style="text-align: center;"></td>
                <td style="text-align: center;"></td>
                <td style="text-align: center;"></td>
                <td style="text-align: center;"></td>
            </tr>
            ',
            pol1,
            string(pol2,"->>>>>>>>>>>9.99"),
            string(pol15,"->>>>>>>>>>>9.99")
            
        ).
    output stream OutStr-html close.     
      /* Четвертая строчка для газа */

      assign
      pol1 = "Tвх - CH4 °C" .
      if available (buf_prev-rvs-line-attr) then pol2 = integer(entry(3,buf_prev-rvs-line-attr.attr-value, ";")). else pol2 = 0 .  
      if available (buf_rvs-line-attr) then pol15 = integer(entry(3,buf_rvs-line-attr.attr-value, ";")). else pol15 = 0 .
      
       output stream OutStr-html to value(v-report-name-html) append convert target 'UTF-8' /*no-convert*/.
        put stream OutStr-html unformatted
            substitute (
          '<tr>
                <td>&1</td>
                <td style="text-align: right;">&2</td>
                <td style="text-align: center;"></td>
                <td style="text-align: center;"></td>
                <td style="text-align: center;"></td>
                <td style="text-align: right;"></td>
                <td style="text-align: right;"></td>
                <td style="text-align: center;"></td>
                <td style="text-align: right;"></td>
                <td style="text-align: center;"></td>
                <td style="text-align: center;"></td>
                <td style="text-align: center;"></td>
                <td style="text-align: center;"></td>
                <td style="text-align: center;"></td>
                <td style="text-align: right;">&3</td>
                <td style="text-align: center;"></td>
                <td style="text-align: center;"></td>
                <td style="text-align: center;"></td>
                <td style="text-align: center;"></td>
                <td style="text-align: center;"></td>
                <td style="text-align: center;"></td>
            </tr>
            ',
            pol1,
            string(pol2,"->>>>>>>>>>>9.99"),
            string(pol15,"->>>>>>>>>>>9.99")
            
        ).
    output stream OutStr-html close.     
      
      /* Подчеркнем */
      
       output stream OutStr-html to value(v-report-name-html) append convert target 'UTF-8' /*no-convert*/.
        put stream OutStr-html unformatted
            substitute (
          '<tr>
                <td colspan="21"></td>
            </tr>
            '
            , chr(123), chr(125)
        ).
    output stream OutStr-html close. 
  end.

  assign
    accum-by-pl-code-pol3-l = 0
    accum-by-pl-code-pol3-kg = 0
    accum-by-pl-code-pol7 = 0
  .

    for each tt-pump-nozzle
      on error undo, return error return-value
      :
      delete tt-pump-nozzle.
    end. /*for each tt-pump-nozzle*/
  
  
    if p-tog-1-whole-gds = true then 
    do:
      assign
        v-count   = 0
        v-tot-cnt = 0
        .
   
      for each buf_temp-rvs-line
        where buf_temp-rvs-line.gds-code = temp-rvs-line.gds-code
        break by buf_temp-rvs-line.pl-code
        on error undo, return error return-value
        :
        if first-of( buf_temp-rvs-line.pl-code ) then 
        do:
          assign
            v-count2 = 2 /*две потому что на кажый резервуар надо "итого по рез" и подчеркивание этого "итого" */
            .
            
          for each buf_rvs-line-pump no-lock
            where buf_rvs-line-pump.rvs-code = buf_temp-rvs-line.rvs-code
            and buf_rvs-line-pump.obj-code = buf_temp-rvs-line.obj-code
            and buf_rvs-line-pump.obj-type = buf_temp-rvs-line.obj-type
            and buf_rvs-line-pump.pl-code  = buf_temp-rvs-line.pl-code
            and buf_rvs-line-pump.gds-code = buf_temp-rvs-line.gds-code
            break by buf_rvs-line-pump.pl-code
            on error undo, return error return-value
            :
            assign
              v-count2 = v-count2 + 1
              .
          end. /*for each buf_rvs-line-pump no-lock*/
          if v-count = 0
            and v-count2 < 4
            then 
          do:
            assign
              v-count2 = 4
              .
          end. /*if v-count = 0*/
          assign
            v-count   = v-count + v-count2
            v-tot-cnt = v-tot-cnt + 1
            .
        end. /*if first-of( buf_temp-rvs-line.pl-code )*/
      end. /*for each buf_temp-rvs-line*/
        
      if v-tot-cnt > 1 then 
      do:
        assign
          v-count = v-count + 2
          .
      end. /*if v-tot-cnt > 1 */

    end. /*if p-tog-1-whole-gds = true*/

  
    if available previous-rvs-doc then 
    do:
      find first previous-rvs-line  no-lock
        where previous-rvs-line.rvs-code = previous-rvs-doc.rvs-code
        and previous-rvs-line.gds-code = temp-rvs-line.gds-code
        and previous-rvs-line.obj-code = temp-rvs-line.obj-code
        and previous-rvs-line.obj-type = temp-rvs-line.obj-type
        and previous-rvs-line.pl-code  = temp-rvs-line.pl-code
        no-error .
    end. /*if available previous-rvs-doc */
    
    for each ub.rvs-line-pump no-lock
      where ub.rvs-line-pump.rvs-code = temp-rvs-line.rvs-code
      and ub.rvs-line-pump.gds-code = temp-rvs-line.gds-code
      and ub.rvs-line-pump.obj-code = temp-rvs-line.obj-code
      and ub.rvs-line-pump.obj-type = temp-rvs-line.obj-type
      and ub.rvs-line-pump.pl-code  = temp-rvs-line.pl-code
      break by ub.rvs-line-pump.pump-code
      by ub.rvs-line-pump.nozzle-code
      :
      create temp-line-pump .
      buffer-copy ub.rvs-line-pump to temp-line-pump .
      assign
        temp-rvs-line.num-trk       = temp-rvs-line.num-trk + 1
        temp-line-pump.pump-code    = ub.rvs-line-pump.pump-code
        temp-line-pump.nozzle-code  = ub.rvs-line-pump.nozzle-code
        temp-line-pump.state-mh-cnt = ub.rvs-line-pump.state-mh-cnt
        temp-line-pump.state-el-cnt = ub.rvs-line-pump.state-el-cnt
        temp-line-pump.pol6         = temp-line-pump.state-mh-cnt
        
        .
      /*найдем показания счетного механизма по пистолету в сменной сверке за пред. смену*/
  
      if available previous-rvs-doc then 
      do:
        Find FIRST previous-rvs-line-pump  No-LOCK WHERE
          previous-rvs-line-pump.rvs-code = previous-rvs-doc.rvs-code AND
          /*previous-rvs-line-pump.gds-code = temp-rvs-line.gds-code  and  Между сменами могло смениться топливо, но счетчик все равно берем, т.к. это правильно*/
          previous-rvs-line-pump.obj-code = temp-rvs-line.obj-code  and
          previous-rvs-line-pump.obj-type = temp-rvs-line.obj-type  and
          previous-rvs-line-pump.pl-code  = temp-rvs-line.pl-code AND
          previous-rvs-line-pump.pump-code = ub.rvs-line-pump.pump-code AND
          previous-rvs-line-pump.nozzle-code = ub.rvs-line-pump.nozzle-code No-ERROR.
        IF available previous-rvs-line-pump then 
        do:
          assign
            temp-line-pump.previous-state-mh-cnt = temp-line-pump.previous-state-mh-cnt + previous-rvs-line-pump.state-mh-cnt
            temp-line-pump.previous-state-el-cnt = temp-line-pump.previous-state-el-cnt + previous-rvs-line-pump.state-el-cnt
            temp-line-pump.pol7                  = temp-line-pump.previous-state-mh-cnt
            temp-line-pump.error-l               = temp-line-pump.previous-state-el-cnt - temp-line-pump.previous-state-mh-cnt
            temp-line-pump.error-kg              = (temp-line-pump.previous-state-el-cnt - temp-line-pump.previous-state-mh-cnt) * temp-rvs-line.state-density
            temp-line-pump.error-19              = temp-line-pump.error-l * 100 / temp-line-pump.previous-state-mh-cnt * temp-rvs-line.state-density
            .
        end. /*IF available previous-rvs-line-pump*/
      end. /*if available previous-rvs-doc*/
      if not available previous-rvs-doc
        or not available previous-rvs-line-pump
        then 
      do:
        /*должны найти первую контрольную сверку по текущей смене,  в которой есть эта ТРК, бензин, и пистолет и взять оттуда*/
        for each control-rvs-doc no-lock
          where control-rvs-doc.obj-type   = p-obj-type
          and control-rvs-doc.obj-code   = p-obj-code
          and control-rvs-doc.shift-date = x-date-start
          and control-rvs-doc.shift-num  = x-shift-start
          and control-rvs-doc.status_    = {&fact}
          and control-rvs-doc.rvs-type   = {&rvs-control}
          ,first control-rvs-line-pump no-lock
          where control-rvs-line-pump.rvs-code = control-rvs-doc.rvs-code
          and control-rvs-line-pump.gds-code = temp-rvs-line.gds-code
          and control-rvs-line-pump.obj-code = temp-rvs-line.obj-code
          and control-rvs-line-pump.obj-type = temp-rvs-line.obj-type
          and control-rvs-line-pump.pl-code  = temp-rvs-line.pl-code
          and control-rvs-line-pump.pump-code = ub.rvs-line-pump.pump-code
          and control-rvs-line-pump.nozzle-code = ub.rvs-line-pump.nozzle-code
          by control-rvs-doc.fact-order
          :
          assign
            temp-line-pump.previous-state-mh-cnt = temp-line-pump.previous-state-mh-cnt + control-rvs-line-pump.state-mh-cnt
            temp-line-pump.previous-state-el-cnt = temp-line-pump.previous-state-el-cnt + control-rvs-line-pump.state-el-cnt
            temp-line-pump.pol7                  = temp-line-pump.previous-state-mh-cnt
            temp-line-pump.error-l               = (temp-line-pump.previous-state-el-cnt - temp-line-pump.previous-state-mh-cnt)
            temp-line-pump.error-kg              = ((temp-line-pump.previous-state-el-cnt - temp-line-pump.previous-state-mh-cnt))* temp-rvs-line.state-density
            temp-line-pump.error-19              = temp-line-pump.error-l * 100 / (temp-line-pump.previous-state-mh-cnt)
            .
          leave.
        end. /* for each control-rvs-doc no-lock where */
      end. /*if not available previous-rvs-doc*/
      
    END. /* FOR EACH ub.rvs-line-pump*/
  /* Итого по резервуару --------------------------------------------------------------------------------------------------*/

  if last-of(temp-rvs-line.pl-code ) then 
  do:
    /* Все приходы */
    for each ub.trn-doc no-lock
      where ub.trn-doc.obj-type   = temp-rvs-line.obj-type
      and ub.trn-doc.obj-code   = temp-rvs-line.obj-code
      and ub.trn-doc.shift-date >= x-date-Start
      and ub.trn-doc.shift-date <= x-date-End
      and ub.trn-doc.status_    = {&fact}
      and ub.trn-doc.doc-type   = {&income}
      on error undo, return error return-value
      :
      if ub.trn-doc.shift-date = x-date-Start and ub.trn-doc.shift-num < x-Shift-Start then next .
      if ub.trn-doc.shift-date = x-date-End   and ub.trn-doc.shift-num > x-Shift-End then next .

      for each ub.doc-pl no-lock
        where ub.doc-pl.gds-code = temp-rvs-line.gds-code
        and ub.doc-pl.obj-code = temp-rvs-line.obj-code
        and ub.doc-pl.obj-type = temp-rvs-line.obj-type
        and ub.doc-pl.out-code = ub.trn-doc.doc-code
        and ub.doc-pl.pl-code  = temp-rvs-line.pl-code
        on error undo, return error return-value
        :

        assign
          temp-rvs-line.accum-by-pl-code-pol3-l  = temp-rvs-line.accum-by-pl-code-pol3-l + ub.doc-pl.fact-qnty
          temp-rvs-line.accum-by-pl-code-pol3-kg = temp-rvs-line.accum-by-pl-code-pol3-kg + ub.doc-pl.cli-fact-qnty
          .
      end. /*  for each ub.doc-pl  */
    end. /* for each ub.trn-doc where  */

    assign
      temp-rvs-line.pol2-l-state   = 0
      temp-rvs-line.pol2-kg-state  = 0
      temp-rvs-line.pol2-l-system  = 0
      temp-rvs-line.pol2-kg-system = 0
      .
    if available previous-rvs-line then 
    do:
      assign
        temp-rvs-line.pol2-l-state   = previous-rvs-line.state-measure-qnty + previous-rvs-line.state-add-qnty
        temp-rvs-line.pol2-kg-state  = previous-rvs-line.state-measure-cli-qnty + previous-rvs-line.state-add-qnty * previous-rvs-line.state-density
        temp-rvs-line.pol2-l-system  = previous-rvs-line.system-qnty
        temp-rvs-line.pol2-kg-system = previous-rvs-line.system-cli-qnty
        .
    end. /*if available previous-rvs-line */

    Assign
      temp-rvs-line.pol2-l-system  = (if p-param-shft-qty = {&par-system} then temp-rvs-line.pol2-l-system else temp-rvs-line.pol2-l-state)
      temp-rvs-line.pol2-kg-system = (if p-param-shft-qty = {&par-system} then temp-rvs-line.pol2-kg-system else  temp-rvs-line.pol2-kg-state)


      .
    find first last-rvs-line no-lock
      where last-rvs-line.rvs-code = last-rvs-doc.rvs-code
      and last-rvs-line.gds-code = temp-rvs-line.gds-code
      and last-rvs-line.obj-code = temp-rvs-line.obj-code
      and last-rvs-line.obj-type = temp-rvs-line.obj-type
      and last-rvs-line.pl-code  = temp-rvs-line.pl-code
      no-error .

    if available last-rvs-line
      and ( p-param-shft-qty = {&par-system}
      or p-param-shft-qty = {&par-state-all-per}
      )
      then 
    do:
      assign
        temp-rvs-line.pol16-l  = last-rvs-line.system-qnty
        temp-rvs-line.pol16-kg = last-rvs-line.system-cli-qnty
        .
    end. /*if available last-rvs-line*/
    
    else 
    do:
      /* установим начальные значения остатков */
      if p-param-shft-qty = {&par-state} then 
      do:
        /* на выходе получим РАСЧЕТНЫЙ остаток. Излишки/недостача будут только за период отчета */
        assign
          temp-rvs-line.pol16-l  = temp-rvs-line.pol2-l-state
          temp-rvs-line.pol16-kg = temp-rvs-line.pol2-kg-state
          .
      end. /*if p-param-shft-qty = {&par-state} */
      else 
      do:
        /* на выходе получим РАСЧЕТНО-КНИЖНЫЙ остаток. Излишки/недостача будут от царя-гороха */
        assign
          temp-rvs-line.pol16-l  = temp-rvs-line.pol2-l-system
          temp-rvs-line.pol16-kg = temp-rvs-line.pol2-kg-system
          .
      end. /*else do:*/
      /* а теперь по документам пройдемся... */
      for each ub.trn-doc no-lock
        where ub.trn-doc.obj-type   = temp-rvs-line.obj-type
        and ub.trn-doc.obj-code   = temp-rvs-line.obj-code
        and ub.trn-doc.shift-date >= x-date-Start
        and ub.trn-doc.shift-date <= x-date-End
        and ub.trn-doc.status_    = {&fact}
        on error undo, return error return-value
        :
        if ub.trn-doc.shift-date = x-date-Start and ub.trn-doc.shift-num < x-Shift-Start then next .
        if ub.trn-doc.shift-date = x-date-End   and ub.trn-doc.shift-num > x-Shift-End then next .

        for each ub.doc-pl no-lock
          where ub.doc-pl.gds-code = temp-rvs-line.gds-code
          and ub.doc-pl.obj-code = temp-rvs-line.obj-code
          and ub.doc-pl.obj-type = temp-rvs-line.obj-type
          and ub.doc-pl.out-code = ub.trn-doc.doc-code
          and ub.doc-pl.pl-code  = temp-rvs-line.pl-code
          on error undo, return error return-value
          :
          if lookup( ub.trn-doc.ext-doc-type, {&TDEDT_out_list} ) > 0 then 
          do:
            assign
              v-sign = -1.0
              .
          end. /*if lookup( ub.trn-doc.ext-doc-type, {&TDEDT_out_list} ) > 0 then do:*/
          else 
          do:
            /* оставляем все как есть */
            assign
              v-sign = 1.0
              .
            if lookup( ub.trn-doc.ext-doc-type, {&TDEDT_in_list} ) = 0 then 
            do:
              undo, return error substitute( '&1. Тип "&2" не внесен в списки документов уменьшающих(увеличивающих) остатки!', vss-workfile, ub.trn-doc.ext-doc-type).
            end.
          end.

          if ( p-param-shft-qty = {&par-state}
            and ub.trn-doc.doc-type <> {&inventory}
            )
            or p-param-shft-qty = {&par-system}
            or p-param-shft-qty = {&par-state-all-per}
            then 
          do:
            assign
              temp-rvs-line.pol16-l  = temp-rvs-line.pol16-l + ub.doc-pl.fact-qnty * v-sign
              temp-rvs-line.pol16-kg = temp-rvs-line.pol16-kg + ub.doc-pl.cli-fact-qnty * v-sign
              .
          end.
        end.
      end. /* for each ub.trn-doc */
    end.
    
    define variable is-vir  as logical   no-undo.
    define variable v-value as character no-undo.
    define variable v-ok    as logical   no-undo.

    run placelib_get-attr(input {&place-virtual}
      ,input temp-rvs-line.obj-code
      ,input temp-rvs-line.obj-type
      ,input temp-rvs-line.pl-code
      ,output v-value
      ,output v-ok) no-error.

    is-vir = if (v-ok and logical(v-value)) then true else false.

    if is-vir then 
    do:
      temp-rvs-line.pol2-kg-state = pol2-kg-system.
      temp-rvs-line.pol2-l-state = pol2-l-system.
        
      if available last-rvs-line then 
      do:
        temp-rvs-line.pol16-l = last-rvs-line.system-qnty.
        temp-rvs-line.pol16-kg = last-rvs-line.system-cli-qnty.
      end.
    end.
    
    assign
      temp-rvs-line.pol14    = temp-rvs-line.state-density
      temp-rvs-line.pol15-l  = temp-rvs-line.state-measure-qnty + temp-rvs-line.state-add-qnty
      temp-rvs-line.pol15-kg = temp-rvs-line.state-measure-cli-qnty + temp-rvs-line.state-add-qnty * temp-rvs-line.state-density
      temp-rvs-line.pol17-l  = temp-rvs-line.pol15-l - temp-rvs-line.pol16-l
      temp-rvs-line.pol17-kg = temp-rvs-line.pol15-kg - temp-rvs-line.pol16-kg
      temp-rvs-line.pol18-l  = temp-rvs-line.pol16-l - temp-rvs-line.pol15-l
      temp-rvs-line.pol18-kg = temp-rvs-line.pol16-kg - temp-rvs-line.pol15-kg
      .
      if temp-rvs-line.pol17-l < 0 then temp-rvs-line.pol17-l = 0 .
      if temp-rvs-line.pol17-kg < 0 then temp-rvs-line.pol17-kg = 0 .
      if temp-rvs-line.pol18-l < 0 then temp-rvs-line.pol18-l = 0 .
      if temp-rvs-line.pol18-kg < 0 then temp-rvs-line.pol18-kg = 0 .
         
  End. /*if last-of(temp-rvs-line.pl-code )  */

/*{ gbl/conf-rd.i "'stfactpl'" 0 "''" 0 "''" "''" "''" no  stfactplvalue stfactpltype no-error }*/                                                                                              
{ gbl/conf-rd.i "'stfactpl'" 0 "''" 0 "''" "''" "''" no  stfactplvalue stfactpltype no-error }

                                                                                              
     if stfactplvalue <> ""  then do:                                                         
       
       { str/chkqtpl.i
            stfactplvalue
            v-update
            v-revision
            v-percrev
            v-auto-tank
            v-percauto
            v-inv
            v-percinv
            v-inv-set
            no-error
        }
          
                                                                                                             
       if error-status :error then do:                                                        
        message                                                                               
          vss-workfile vss-revision vss-description skip                                      
          "Разборе строки параметра stfactpl" skip                                            
          error-status :get-message(1) skip                                                   
          return-value skip                                                                   
          view-as alert-box error .                                                           
        return error .                                                                        
       end.
     end.                                                                                    
     
     if v-percauto <> ? then do:
          assign                                           
             temp-rvs-line.fact-pl = v-percauto             
          .
     end.
     else 
           assign                                           
             temp-rvs-line.fact-pl = 0.65             
          .
 
  /* Всего по товару ------------------------------------------------------------------------------------------------------*/

   end. /*for each temp-rvs-line*/ 


/*------------------------------------------------------------------------------------------------------------------------------------*/

/*выводим на печать отчет*/

/*Заполняем строчки*/
define VARIABLE v-first as logical no-undo .

    for each temp-rvs-line break by temp-rvs-line.gds-code by temp-rvs-line.place_loc1:
      if first-of(temp-rvs-line.place_loc1) then v-first = yes.
      if temp-rvs-line.num-trk <> 0 then do:
      for each temp-line-pump where temp-rvs-line.gds-code = temp-line-pump.gds-code
      and temp-line-pump.pl-code = temp-rvs-line.pl-code :
        assign
            temp-rvs-line.pol8-l = (temp-line-pump.pol6 - temp-line-pump.pol7)
            temp-rvs-line.pol8-kg = temp-rvs-line.pol8-l * temp-rvs-line.state-density
        .      
        if v-first then 
        do:
          output stream OutStr-html to value(v-report-name-html) append convert target 'UTF-8' /*no-convert*/.
          put stream OutStr-html unformatted
            substitute (
            '
                <tr> <!-- Затем идёт наполнение таблицы -->
                <td rowspan="&1" style="text-align: center;">&2</td>
                <td rowspan="&1" style="text-align: center;"></td>
                <td rowspan="&1" ></td>
                <td style="text-align: center;">&3</td>
                <td style="text-align: right;">&4</td>
                <td style="text-align: right;">&5</td>
                <td style="text-align: right;">&6</td>
                <td rowspan="&1" style="text-align: center;">&7</td>
                <td rowspan="&1" ></td>
                <td rowspan="&1" ></td>
                <td rowspan="&1" ></td>
                <td rowspan="&1" ></td>
                <td rowspan="&1" ></td>
                <td rowspan="&1" ></td>
                <td rowspan="&1" ></td>
                <td rowspan="&1" ></td>
                <td rowspan="&1" ></td>
                <td rowspan="&1" ></td>
                <td rowspan="&1" ></td>
                <td rowspan="&1" ></td>
                <td rowspan="&1" ></td>
                </tr>'
            ,
            temp-rvs-line.num-trk,
            string(temp-rvs-line.gds-name) + ' код:' + string(temp-rvs-line.gds-code),
            string(temp-line-pump.pump-code) + ',' + string(temp-line-pump.nozzle-code),
            string(temp-line-pump.pol6,"->>>>>>>>>>>9.99"), 
            string(temp-line-pump.pol7,"->>>>>>>>>>>9.99"),
            string(temp-rvs-line.pol8-l,"->>>>>>>>>>>9.99"),
            temp-rvs-line.place_loc1
            ).
          
          output stream OutStr-html close.    
        end. /*if v-first then */
            
        else 
        do:
          output stream OutStr-html to value(v-report-name-html) append convert target 'UTF-8' /*no-convert*/.
          put stream OutStr-html unformatted
            substitute ('
            <tr> 
                <td style="text-align: center;">&1</td>
                <td style="text-align: right;">&2</td>
                <td style="text-align: right;">&3</td>
                <td style="text-align: right;">&4</td>
            </tr>
            '
            ,
            string(temp-line-pump.pump-code) + ',' + string(temp-line-pump.nozzle-code),
            string(temp-line-pump.pol6,"->>>>>>>>>>>9.99"),
            string(temp-line-pump.pol7,"->>>>>>>>>>>9.99"),
            string(temp-rvs-line.pol8-l,"->>>>>>>>>>>9.99")
            ).
          output stream OutStr-html close.    

        end. /*        else  do:*/
          assign
                num-pol8-l  = temp-rvs-line.pol8-l + num-pol8-l
                num-pol8-kg = temp-rvs-line.pol8-kg + num-pol8-kg
                temp-rvs-line.accum-pol8-l   = num-pol8-l
                temp-rvs-line.accum-pol8-kg  = num-pol8-kg
                num-pol20-l = temp-line-pump.error-l + num-pol20-l
                num-pol20-kg = temp-line-pump.error-kg + num-pol20-kg
                temp-rvs-line.accum-pol20-l = num-pol20-l
                temp-rvs-line.accum-pol20-kg = num-pol20-kg
                v-first     = no
          .           
        end. /*for each temp-line-pump*/
        end. /*if temp-rvs-line.num-trk <> 0 then do:*/
        if temp-rvs-line.num-trk = 0 then do:
                    output stream OutStr-html to value(v-report-name-html) append convert target 'UTF-8' /*no-convert*/.
          put stream OutStr-html unformatted
            substitute (
            '
                <tr> <!-- Затем идёт наполнение таблицы -->
                <td style="text-align: center;">&1</td>
                <td style="text-align: center;"></td>
                <td ></td>
                <td style="text-align: center;"></td>
                <td style="text-align: right;"></td>
                <td style="text-align: right;"></td>
                <td style="text-align: right;"></td>
                <td style="text-align: center;">&2</td>
                <td ></td>
                <td ></td>
                <td ></td>
                <td ></td>
                <td ></td>
                <td ></td>
                <td ></td>
                <td ></td>
                <td ></td>
                <td ></td>
                <td ></td>
                <td ></td>
                <td ></td>
                </tr>'
            ,
            string(temp-rvs-line.gds-name) + ' код:' + string(temp-rvs-line.gds-code),
            temp-rvs-line.place_loc1
            ).
          
          output stream OutStr-html close.    
          end. /*if temp-rvs-line.num-trk = 0 then do:*/

      
      output stream OutStr-html to value(v-report-name-html) append convert target 'UTF-8' /*no-convert*/.
      put stream OutStr-html unformatted
        substitute (
               '<tr> <!-- Затем идёт наполнение таблицы -->
                <td>Всего по резервуару:</td>
                <td style="text-align: right;">&1</td>
                <td style="text-align: right;">&2</td>
                <td style="text-align: center;"></td>
                <td style="text-align: right;"></td>
                <td style="text-align: right;"></td>
                <td style="text-align: right;">&3</td>
                <td style="text-align: center;">&4</td>
                <td style="text-align: right;">&5</td>
                <td style="text-align: right;">&6</td>
                <td style="text-align: right;">&7</td>
                <td style="text-align: right;">&8</td>
                <td style="text-align: right;">&9</td>'
        ,
        if p-weight = true then string(temp-rvs-line.pol2-kg-system,"->>>>>>>>>>>9.99") else string(temp-rvs-line.pol2-l-system,"->>>>>>>>>>>9.99"),
        if p-weight = true then string(temp-rvs-line.accum-by-pl-code-pol3-kg,"->>>>>>>>>>>9.99") else string(temp-rvs-line.accum-by-pl-code-pol3-l,"->>>>>>>>>>>9.99"),
        string(temp-rvs-line.accum-pol8-l,"->>>>>>>>>>>9.99"),
        temp-rvs-line.place_loc1,
        string(temp-rvs-line.state-level-total,"->>>>>>>>>>>9"),
        string(temp-rvs-line.state-level-water,"->>>>>>>>>>>9"),
        string(temp-rvs-line.state-brutto-qnty,"->>>>>>>>>>>9"),
        string(temp-rvs-line.state-brutto-qnty - temp-rvs-line.state-measure-qnty,"->>>>>>>>>>>9"),
        string(temp-rvs-line.state-add-qnty,"->>>>>>>>>>>9")
        ).
      output stream OutStr-html close.   
          
      output stream OutStr-html to value(v-report-name-html) append convert target 'UTF-8' /*no-convert*/.
      put stream OutStr-html unformatted
        substitute ('
                <td style="text-align: right;">&1</td>
                <td style="text-align: right;">&2</td>
                <td style="text-align: right;">&3</td>
                <td style="text-align: right;">&4</td>
                <td style="text-align: right;">&5</td>
                <td style="text-align: right;">&6</td>
                <td style="text-align: right;">&7</td>
                <td style="text-align: right;">&8</td>
                </tr>
                  '
        ,
        string(temp-rvs-line.state-measure-qnty,"->>>>>>>>>>>9"),
        string(temp-rvs-line.state-measure-qnty + temp-rvs-line.state-add-qnty,"->>>>>>>>>>>9"),
        string(temp-rvs-line.state-measure-cli-qnty + temp-rvs-line.state-add-qnty * temp-rvs-line.state-density,"->>>>>>>>>>>9"),
        string(temp-rvs-line.pol14,"->>>>>>>>>>>9.9999"),
        string(temp-rvs-line.state-temperature,"->>>>>>>>>>>9"),
        if p-weight = true then string(temp-rvs-line.pol16-kg,"->>>>>>>>>>>9.99") else string(temp-rvs-line.pol16-l,"->>>>>>>>>>>9.99"),
        if p-weight = true then string(temp-rvs-line.pol17-kg,"->>>>>>>>>>>9.99") else string(temp-rvs-line.pol17-l,"->>>>>>>>>>>9.99"),
        if p-weight = true then string(temp-rvs-line.pol18-kg,"->>>>>>>>>>>9.99") else string(temp-rvs-line.pol18-l,"->>>>>>>>>>>9.99")
        ).
      output stream OutStr-html close.  
           assign 
            num-pol8-l = 0
            num-pol8-kg = 0
            .
    end.
     output stream OutStr-html to value(v-report-name-html) append convert target 'UTF-8' /*no-convert*/.
     put stream OutStr-html unformatted                                                                     
        substitute (
        '
        </tbody>
        '                                                                                      
            , chr(123), chr(125)                                                                                                 
       ).                                                                                                    
      output stream OutStr-html close.
