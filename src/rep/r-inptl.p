block-level on error undo, throw.
/*

$Revision: 0ec5d11e52eb, 2015, rls $
$Author: EShklyar $
$Date: Wed Sep 18 21:05:06 2019 +0300 $
$Workfile: r-inptl.p $
$Archive: rep/r-inptl.p $

Журнал поступивших нефтепродуктов за период

Автор: Уханов Дмитрий Юрьевич
Дата создания: 01/30/09
Author: Dmitry Ukhanov
Creation date: 01/30/09

*/

define variable vss-revision    as character no-undo initial "$Revision: 0ec5d11e52eb, 2015, rls $":U .
define variable vss-author      as character no-undo initial "$Author: EShklyar $":U .
define variable vss-date        as character no-undo initial "$Date: Wed Sep 18 21:05:06 2019 +0300 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: r-inptl.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: rep/r-inptl.p $":U .
define variable vss-description as character no-undo initial "Журнал поступивших нефтепродуктов за период":U .

{ cmp/vssrevis.i     }
{ cmp/str-glbl.i     }
{ cmp/library.i      }
{ cmp/r-pril.i   new }
{ gbl/prn-lib.i      }
{ cmp/r-page1.i      }
{ gbl/cur-time.i     }
{ gbl/clntattr.i     }
{ str/lib-calc.i     }
{ gbl/waitfram.i     }
{ gbl/ptrlprop.i def }

&scop report-width 196
&scop frame-width  198
&scop tt-l "                        Ж У Р Н А Л   П О С Т У П И В Ш И Х   Н Е Ф Т Е П Р О Д У К Т О В   З А   П Е Р И О Д"

define buffer bef-rvs-doc  for ub.rvs-doc       .
define buffer aft-rvs-doc  for ub.rvs-doc       .
define buffer bef-rvs-line for ub.rvs-line      .
define buffer aft-rvs-line for ub.rvs-line      .
define buffer car-num-attr for ub.doc-attr .
define buffer car-vol-attr for ub.doc-line-attr .
define buffer tests-attr   for ub.doc-line-attr .

define variable varshift-id   as   character                      no-undo .
define variable v-doc-qnty    like ub.doc-pl.cli-doc-qnty         no-undo .
define variable v-fact-qnty   like ub.doc-pl.cli-fact-qnty        no-undo .
define variable varinaccuracy like ub.rvs-line.state-measure-qnty no-undo .
define variable vardifference like ub.rvs-line.state-measure-qnty no-undo .
define variable varmeasure    like ub.rvs-line.state-measure-qnty no-undo .
define variable v-host-name   as   character                      no-undo . /* название фирмы */
define variable v-host-city   as   character                      no-undo . /* адрес */
define variable v-obj-name    as   character                      no-undo . /* АЗС */
define variable v-header-name as   character                      no-undo .
define variable v-print-time  as   character                      no-undo .
define variable varhost-code  like ub.trn-doc.host-code           no-undo .
define variable varTemp       as   character                      no-undo .
define variable varvol-attr   as   decimal                        no-undo .
define variable v-ind         as   integer                        no-undo .
define variable v-num-sections as integer no-undo .
define variable v-n-section    as integer no-undo .
define variable v-temperature  as decimal no-undo .

define variable v-tot-doc-qnty   like ub.doc-pl.cli-doc-qnty         no-undo .
define variable v-tot-fact-qnty  like ub.doc-pl.cli-fact-qnty        no-undo .
define variable v-tot-difference like ub.rvs-line.state-measure-qnty no-undo .
define variable v-tot-measure    like ub.rvs-line.state-measure-qnty no-undo .

define variable v-pogresh     as   decimal                        no-undo initial 0 .

define variable parupdate     as   logical                        no-undo initial yes .
define variable parrevision   as   logical                        no-undo initial no .
define variable parpercrev    as   decimal                        no-undo initial ? .
define variable parauto-tank  as   logical                        no-undo initial no .
define variable parpercauto   as   decimal                        no-undo initial ? .
define variable parinv        as   logical                        no-undo initial no .
define variable parpercinv    as   decimal                        no-undo initial ? .
define variable parinv-set    as   logical                        no-undo initial no.

define variable v_stfactpl    as   character                      no-undo .
define variable v_data-type   as   character                      no-undo .

/*define variable str-12        as   character                      no-undo .*/
define variable v-line        as   character                      no-undo format "x({&report-width})":U .
define variable sym1          as   character                      no-undo format "x(1)":U label ":" initial ":":U .
define variable sym2          as   character                      no-undo format "x(1)":U label ":" initial ":":U .
define variable sym3          as   character                      no-undo format "x(1)":U label ":" initial ":":U .
define variable sym4          as   character                      no-undo format "x(1)":U label ":" initial ":":U .
define variable sym5          as   character                      no-undo format "x(1)":U label ":" initial ":":U .
define variable sym6          as   character                      no-undo format "x(1)":U label ":" initial ":":U .
define variable sym7          as   character                      no-undo format "x(1)":U label ":" initial ":":U .
define variable sym8          as   character                      no-undo format "x(1)":U label ":" initial ":":U .
define variable sym9          as   character                      no-undo format "x(1)":U label ":" initial ":":U .
define variable sym10         as   character                      no-undo format "x(1)":U label ":" initial ":":U .
define variable sym11         as   character                      no-undo format "x(1)":U label ":" initial ":":U .
define variable sym12         as   character                      no-undo format "x(1)":U label ":" initial ":":U .
define variable sym13         as   character                      no-undo format "x(1)":U label ":" initial ":":U .
define variable sym14         as   character                      no-undo format "x(1)":U label ":" initial ":":U .
define variable sym15         as   character                      no-undo format "x(1)":U label ":" initial ":":U .
define variable sym16         as   character                      no-undo format "x(1)":U label ":" initial ":":U .
define variable sym17         as   character                      no-undo format "x(1)":U label ":" initial ":":U .
define variable sym18         as   character                      no-undo format "x(1)":U label ":" initial ":":U .

define variable v-oper-name   as character    no-undo.

/* определяем footer: нижнюю часть страницы, которая будет выводиться на каждой странице */
form header
  v-line                                 at  1 skip
  "Продолжение на следующей странице..." at 30 skip
with frame bottomframe width {&frame-width} page-bottom no-labels no-box
.

/* определяем фрейм в котором будут выводиться данные */
define frame doc-line-frm-cli
  sym1  space( 0 ) varshift-id                     format "x(11)":U          column-label "1":C11          space( 0 )
  sym2  space( 0 ) v-oper-name                     format "x(9)":U           column-label "2":C9           space( 0 )
  sym3  space( 0 ) ub.trn-doc.doc-code             format "x(14)":U          column-label "3":C14          space( 0 )
  sym4  space( 0 ) car-num-attr.attr-value         format "x(8)":U           column-label "4":C8           space( 0 )
  sym5  space( 0 ) varvol-attr                     format ">>,>>>,>>9.<<<":U column-label "5":C11          space( 0 )
  sym6  space( 0 ) v-doc-qnty                      format ">>,>>>,>>9.<<<":U column-label "6":C11          space( 0 )
  sym7  space( 0 ) ub.doc-pl.pl-code               format " 99999999999":U     column-label "7":C10          space( 0 )
  sym8  space( 0 ) bef-rvs-line.state-level-petrol format ">>,>>>,>>9.<<<":U column-label "8":C11          space( 0 )
  sym9  space( 0 ) aft-rvs-line.state-level-petrol format ">>,>>>,>>9.<<<":U column-label "9":C11          space( 0 )
  sym10 space( 0 ) v-fact-qnty                     format ">>,>>>,>>9.<<<":U column-label "10":C11         space( 0 )
  sym11 space( 0 ) varmeasure                      format ">>,>>>,>>9.<<<":U column-label "11":C11         space( 0 )
  sym12 space( 0 ) varinaccuracy                   format ">>>,>>9.<<<":U    column-label "12=6*0.005":C11 space( 0 )
  sym13 space( 0 ) vardifference                   format "->>,>>9.<<<":U    column-label "13=6-11":C11    space( 0 )
  sym14 space( 0 ) tests-attr.attr-value           format "x(8)":U           column-label "14":C8          space( 0 )
  sym15 space( 0 ) ub.doc-line.fact-density        format "    9.9999":U     column-label "15":C10         space( 0 )
  sym16 space( 0 ) ub.doc-line.temperature         format "     ->9.99":U    column-label "16":C11         space( 0 )
  sym17 space( 0 ) varTemp                         format "x(7)":U           column-label "17":C7          space( 0 )
  sym18 space( 0 )
header
  cur-time-string() at 138 format "x(50)":U string( page-number( PrnLibStream ), ">,>>9.":U ) format "x(6)":U skip
  "----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------" skip
  ":   Дата    :         :              :        :           :   Вес     :            :       Уровень         :           :           : Допустимая: Разница   :    №   :          :           :       :" skip
  ":  прихода  : Оператор:    Номер     :  Гос   :  Объем    :  нефте-   :      №     :     нефтепродукта     :   Факт    :   Факт    :погрешность:  между    :отобран-:Измеренная:Измеренная :Подпись:" skip
  ": (№ смены  :         :  приходной   : номер  : автоцист. : продукта  : резервуара :-----------------------:  кол-во   :  кол-во   :     от    :показаниями:   ной  : плотность:температура: опера :" skip
  ": и дата ее :         :  накладной   : авто-  : по табл.  :  по ТТН   :            : до слива  :после слива: принятого :по счетчику: принятого : замера и  :  пробы :  после   :  после    :  тора :" skip
  ":  начала)  :         :              :цистерны: в литрах  :   в кг    :            :   в см.   :   в см.   :    в кг   :    в кг   :   по ТТН  :кол-ом ТТН :        : стабилиз.: стабилиз. :       :" skip
  "----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------" skip
with width {&frame-width} down stream-io use-text
.

define frame doc-line-frm
  sym1  space( 0 ) varshift-id                     format "x(11)":U          column-label "1":C11          space( 0 )
  sym2  space( 0 ) v-oper-name                     format "x(9)":U           column-label "2":C9           space( 0 )
  sym3  space( 0 ) ub.trn-doc.doc-code             format "x(14)":U          column-label "3":C14          space( 0 )
  sym4  space( 0 ) car-num-attr.attr-value         format "x(8)":U           column-label "4":C8           space( 0 )
  sym5  space( 0 ) varvol-attr                     format ">>,>>>,>>9.<<<":U column-label "5":C11          space( 0 )
  sym6  space( 0 ) v-doc-qnty                      format ">>,>>>,>>9.<<<":U column-label "6":C11          space( 0 )
  sym7  space( 0 ) ub.doc-pl.pl-code               format " 99999999999":U     column-label "7":C10          space( 0 )
  sym8  space( 0 ) bef-rvs-line.state-level-petrol format ">>,>>>,>>9.<<<":U column-label "8":C11          space( 0 )
  sym9  space( 0 ) aft-rvs-line.state-level-petrol format ">>,>>>,>>9.<<<":U column-label "9":C11          space( 0 )
  sym10 space( 0 ) v-fact-qnty                     format ">>,>>>,>>9.<<<":U column-label "10":C11         space( 0 )
  sym11 space( 0 ) varmeasure                      format ">>,>>>,>>9.<<<":U column-label "11":C11         space( 0 )
  sym12 space( 0 ) varinaccuracy                   format ">>>,>>9.<<<":U    column-label "12=6*0.005":C11 space( 0 )
  sym13 space( 0 ) vardifference                   format "->>,>>9.<<<":U    column-label "13=6-11":C11    space( 0 )
  sym14 space( 0 ) tests-attr.attr-value           format "x(8)":U           column-label "14":C8          space( 0 )
  sym15 space( 0 ) ub.doc-line.fact-density        format "    9.9999":U     column-label "15":C10         space( 0 )
  sym16 space( 0 ) ub.doc-line.temperature         format "     ->9.99":U    column-label "16":C11         space( 0 )
  sym17 space( 0 ) varTemp                         format "x(7)":U           column-label "17":C7          space( 0 )
  sym18 space( 0 )
header
  cur-time-string() at 138 format "x(50)":U string( page-number( PrnLibStream ), ">,>>9.":U ) format "x(6)":U skip
  "----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------" skip
  ":   Дата    :         :              :        :           :   Вес     :            :       Уровень         :           :           : Допустимая: Разница   :    №   :          :           :       :" skip
  ":  прихода  : Оператор:    Номер     :  Гос   :  Объем    :  нефте-   :     №      :     нефтепродукта     :   Факт    :   Факт    :погрешность:  между    :отобран-:Измеренная:Измеренная :Подпись:" skip
  ": (№ смены  :         :  приходной   : номер  : автоцист. : продукта  : резервуара :-----------------------:  кол-во   :  кол-во   :     от    :показаниями:   ной  : плотность:температура: опера :" skip
  ": и дата ее :         :  накладной   : авто-  : по табл.  :  по ТТН   :            : до слива  :после слива: принятого :по счетчику: принятого : замера и  :  пробы :  после   :  после    :  тора :" skip
  ":  начала)  :         :              :цистерны: в литрах  : в литрах  :            :   в см.   :   в см.   : в литрах  : в литрах  :   по ТТН  :кол-ом ТТН :        : стабилиз.: стабилиз. :       :" skip
  "----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------" skip
with width {&frame-width} down stream-io use-text
.

find first obj-list no-lock .
if not available obj-list then do:
  message "Вы не выбрали объект." view-as alert-box error.
  return.
end.

find first gds-list no-lock no-error .
if not available gds-list then do:
  message "Выберите товар для выполнения отчёта." view-as alert-box error.
  return.
end.

if x-date-start = ? or
   x-date-end   = ? then do:
   message "Не верно заданы даты отчета." view-as alert-box error.
   return.
end.
if (x-radio-task = 3 and (x-shift-start = ? or x-shift-start = 0 or x-shift-end = ? or x-shift-end = 0) )
   or
   (x-radio-task = 4 and (x-shift-start = ? or x-shift-start = 0 ) )
then do:
   message "Неверно заданы номера смен" view-as alert-box error.
   return.
end.

run waitfram-show in this-procedure
  ( input {&MyWaitMess}
  ) .

assign
  v-line        = fill("-", {&report-width} )
  v-header-name = {&tt-l}
.

run prn-lib-open-stream in this-procedure
  ( input my-handle
  , input 45
  , input yes
  , input no
  ) .

if x-radio-task <= 2
then do:
  put stream PrnLibStream unformatted  "                          Начало периода " x-date-start
                                              "                   Конец периода "  x-date-end skip( 1 )
  .
end.
else
if x-radio-task  = 3
then do:
  put stream PrnLibStream unformatted " Начало периода (номер смены и дата ее начала) " string( x-shift-start ) +
                                      ":":U + string( x-date-start ) + "  ":U +
                                      "  Конец периода (номер смены и дата ее начала) " string( x-shift-end   ) +
                                      ":":U + string( x-date-end   ) skip( 1 )
  .
end.
else do:
  put stream PrnLibStream unformatted " Начало периода (номер смены и дата ее начала) " string( x-shift-start ) +
                                      ":":U + string( x-date-start ) + "  ":U +
                                      "  Конец периода (номер смены и дата ее начала) " string( x-shift-end   ) +
                                      ":":U + string( x-date-end   ) skip( 1 )
  .
end.

view stream PrnLibStream frame bottomframe .

for each obj-list
:

  { gbl/ptrlprop.i run obj-list.obj-type obj-list.obj-code }

  { gbl/conf-rd.i
    "'stfactpl'"
    "''"
    "''"
    0
    "''"
    "''"
    "''"
    no
    v_stfactpl
    v_data-type
    no-error
  }
  { str/chkqtpl.i
    v_stfactpl
    parupdate
    parrevision
    parpercrev
    parauto-tank
    parpercauto
    parinv
    parpercinv
    parinv-set
  }
  if parauto-tank = yes then do:
    assign
      v-pogresh = parpercauto * 0.01
    .
  end.
  if parinv = yes then do:
    assign
      v-pogresh = parpercinv * 0.01
    .
  end.

  if ptrlprop-inpptrl = {&calc-petrol-weight} then do:
    form with frame doc-line-frm-cli .
  end.
  else do:
    form with frame doc-line-frm .
  end.

  assign
    varinaccuracy :label in frame doc-line-frm-cli = " 12=6*" + string( v-pogresh, "9.999":U )
  .

  find first ub.clients no-lock
    where ub.clients.obj-type = obj-list.obj-type
      and ub.clients.obj-code = obj-list.obj-code
    .
  assign
    v-obj-name = ub.clients.obj-name
  .

  { gbl/hostcode.i
    obj-list.obj-type
    obj-list.obj-code
    varhost-code
  }
  /* Своя фирма */
  find first ub.clients no-lock
    where ub.clients.obj-type = {&cmp}
      and ub.clients.obj-code = varhost-code
    .
  assign
    v-host-name = ub.clients.obj-name
  .

  for each gds-list
  :
    put stream PrnLibStream unformatted
      "Наименование предприятия: " string( '"' + v-host-name + '"', "x(70)":U ) " АЗС " v-obj-name      skip( 1 )
      {&tt-l} skip( 1 )
      "                                            Нефтепродукт: " gds-list.artic " " gds-list.gds-name skip( 1 )
    .

    if ptrlprop-inpptrl = {&calc-petrol-weight} then do:
      { rep/r-inptl.i &type-prn=weight }
    end.
    else do:
      { rep/r-inptl.i &type-prn=volume }
    end.

  end.

  put  stream PrnLibStream unformatted skip( 2 ) "   Управляющий АЗС___________________________" skip .

end. /* for each obj-list */



/* делаем footer невидимым, чтобы он не напечатался на последней странице */
hide stream PrnLibStream frame bottomframe .

output stream PrnLibStream close .

run waitfram-hide in this-procedure .

run prn-lib-prn-file in this-procedure
  ( input my-handle
  , input 8
  ) .