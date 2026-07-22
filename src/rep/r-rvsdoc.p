block-level on error undo, throw.
/*

$Revision: 31d98d0f4d05, 3289, rls $
$Author: SSlivenko $
$Date: 2023/03/29 08:47:58 $
$Workfile: r-rvsdoc.p $
$Archive: rep/r-rvsdoc.p $

Протокол снятия показаний уровнемера

Автор: Уханов Дмитрий Юрьевич
Дата создания: 08/23/07
Author: Dmitry Ukhanov
Creation date: 08/23/07

*/

define input parameter parparentproc as handle no-undo.
define input parameter p-recid       as recid  no-undo.

define variable vss-revision    as character no-undo initial "$Revision: 31d98d0f4d05, 3289, rls $":U .
define variable vss-author      as character no-undo initial "$Author: SSlivenko $":U .
define variable vss-date        as character no-undo initial "$Date: 2023/03/29 08:47:58 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: r-rvsdoc.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: rep/r-rvsdoc.p $":U .
define variable vss-description as character no-undo initial "Протокол снятия показаний уровнемера".

{ cmp/vssrevis.i     }
{ cmp/str-glbl.i     }
{ cmp/library.i      }
{ cmp/r-pril.i   new }
{ gbl/prn-lib.i      }
{ gbl/waitfram.i     }


/* ширина отчета */
&scop report-width        179
&scop report-width-frame  183

define variable v-line  as character no-undo format "X({&report-width})" .

define variable v-line1 as character no-undo format "X({&report-width})" .
define variable sym1  as character no-undo format "x(1)":u label ':':u init ":":u.
define variable sym2  as character no-undo format "x(1)":u label ':':u init ":":u.
define variable sym3  as character no-undo format "x(1)":u label ':':u init ":":u.
define variable sym4  as character no-undo format "x(1)":u label ':':u init ":":u.
define variable sym5  as character no-undo format "x(1)":u label ':':u init ":":u.
define variable sym6  as character no-undo format "x(1)":u label ':':u init ":":u.
define variable sym7  as character no-undo format "x(1)":u label ':':u init ":":u.
define variable sym8  as character no-undo format "x(1)":u label ':':u init ":":u.
define variable sym9  as character no-undo format "x(1)":u label ':':u init ":":u.
define variable sym10 as character no-undo format "x(1)":u label ':':u init ":":u.
define variable sym11 as character no-undo format "x(1)":u label ':':u init ":":u.
define variable sym12 as character no-undo format "x(1)":u label ':':u init ":":u.
define variable sym13 as character no-undo format "x(1)":u label ':':u init ":":u.

define variable v-header-name  as character no-undo.
define variable v-obj-name     as character no-undo.
define variable v-host-code    like ub.clients.obj-code no-undo.
define variable v-host-name    as character no-undo.
define variable v-water-qnty   like ub.rvs-line.measure-qnty no-undo.
define variable v-delta-el-cnt like ub.rvs-line-pump.state-el-cnt no-undo.

define buffer buf_clients        for ub.clients .
define buffer prev_shift-obj     for ub.shift-obj .
define buffer buf_rvs-doc        for ub.rvs-doc .
define buffer prev_rvs-doc       for ub.rvs-doc .
define buffer buf_rvs-line       for ub.rvs-line .
define buffer buf_rvs-line-pump  for ub.rvs-line-pump .
define buffer prev_rvs-line-pump for ub.rvs-line-pump .
define buffer buf_goods          for ub.goods .

&global-define rvs-title ~
"Наименование предприятия:" space(2) v-host-name format "x(120)" skip ~
"АЗС          :" space(2) v-obj-name format "x(120)" skip ~
"Дата смены   :" space(2) buf_rvs-doc.shift-date format "99/99/9999" space(26) v-header-name format "x(120)" skip ~
"Номер смены  :" space(2) buf_rvs-doc.shift-name skip ~
"Порядок смены:" space(2) buf_rvs-doc.shift-num skip ~
"Тип замера   :" space(2) buf_rvs-doc.rvs-type format "x(20)" skip


&global-define rvs-line-frm ~
"-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------" skip ~
":              :                :                              :              :              :    Объем     :              :              :         :   Уровень    :              :" skip ~
":    Номер     :    Артикул     :      Название товара         :    Объем     :    Объем     : нефтепродукта:    Объем     :   Плотность  :t нефте- :   жидкости   :   Уровень    :" skip ~
":  резервуара  :                :                              :    общий     : подтоварной  :     факт     : нефтепродукта: нефтепродукта:продукта : в резервуаре : нефтепродукта:" skip ~
":              :                :                              :     л.       :     воды     :  по приборам : факт. остаток:    г/куб.см  :    С    :    общий     : в резервуаре :" skip ~
":              :                :                              :              :      л.      :      л.      :      л.      :              :         :      см.     :     см.      :" skip ~
"-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"

define frame rvs-line-frm
  sym1 space(0)  buf_rvs-line.pl-code            format "99999999999":C14   column-label "1":C14  space(0)
  sym2 space(0)  buf_goods.artic                 format "x(16)"             column-label "2":C16  space(0)
  sym3 space(0)  buf_goods.gds-name              format "x(30)"             column-label "3":C30  space(0)
  sym4 space(0)  buf_rvs-line.brutto-qnty        format ">>,>>>,>>9.999"    column-label "4":C14  space(0)
  sym5 space(0)  v-water-qnty                    format ">>,>>>,>>9.999"    column-label "5":C14  space(0)
  sym6 space(0)  buf_rvs-line.measure-qnty       format ">>,>>>,>>9.999"    column-label "6":C14  space(0)
  sym7 space(0)  buf_rvs-line.state-measure-qnty format ">>,>>>,>>9.999"    column-label "7":C14  space(0)
  sym8 space(0)  buf_rvs-line.density            format ">>>>,>>>,>>9.9<<<" column-label "8":C14  space(0)
  sym9 space(0)  buf_rvs-line.temperature        format "->>>>>>9.<<<"      column-label "9":C9   space(0)
  sym10 space(0) buf_rvs-line.level-total        format ">>,>>>,>>9.999"    column-label "10":C14 space(0)
  sym11 space(0) buf_rvs-line.level-petrol       format ">>,>>>,>>9.999"    column-label "11":C14 space(0)
  sym12 space(0)
  with width {&DOS_CW_2} down stream-io use-text no-box.

&global-define rvs-line-pump-frm ~
"------------------------------------------------------------------------------------------------------" skip ~
":   Номер   :   Номер   :      Название товара         :      Показания       :        Оборот        :" skip ~
":    ТРК    : пистолета :                              :     электронного     :       за смену       :" skip ~
":           :           :                              :       счетчика       :                      :" skip ~
"------------------------------------------------------------------------------------------------------"

define frame rvs-line-pump-frm
  sym1 space(0)  buf_rvs-line-pump.pump-code     format ">9":C11                 column-label "1":C11  space(0)
  sym2 space(0)  buf_rvs-line-pump.nozzle-code   format ">9":C11                 column-label "2":C11  space(0)
  sym3 space(0)  buf_goods.gds-name              format "x(30)"                  column-label "3":C30  space(0)
  sym4 space(0)  buf_rvs-line-pump.state-el-cnt  format "->,>>>,>>>,>>>,>>9.999" column-label "4":C22  space(0)
  sym5 space(0)  v-delta-el-cnt                  format "->,>>>,>>>,>>>,>>9.999" column-label "5":C22  space(0)
  sym6 space(0)
  with width {&DOS_CW_2} down stream-io use-text no-box.

assign
  v-line  = fill("-", {&report-width} )
  v-line1 = v-line
.

form header
  v-line skip
  "Продолжение на следующей странице" at 60 skip
  with frame bottomframe
  width {&report-width-frame} page-bottom no-labels no-box .

run waitfram-show in this-procedure
  ( input {&MyWaitMess}
  ) .

find first buf_rvs-doc no-lock
  where recid(buf_rvs-doc) = p-recid .

find last prev_shift-obj no-lock
  where prev_shift-obj.obj-type = buf_rvs-doc.obj-type
    and prev_shift-obj.obj-code = buf_rvs-doc.obj-code
    and prev_shift-obj.status_  = {&sht-closed}
    and ( prev_shift-obj.shift-date < buf_rvs-doc.shift-date
          or ( prev_shift-obj.shift-date = buf_rvs-doc.shift-date
                and prev_shift-obj.shift-num  < buf_rvs-doc.shift-num
              )
        )
  use-index stts
  no-error.
if available prev_shift-obj then do:
  find first prev_rvs-doc no-lock
    where prev_rvs-doc.obj-type   = prev_shift-obj.obj-type
      and prev_rvs-doc.obj-code   = prev_shift-obj.obj-code
      and prev_rvs-doc.shift-date = prev_shift-obj.shift-date
      and prev_rvs-doc.shift-num  = prev_shift-obj.shift-num
      and prev_rvs-doc.status_    = {&fact}
      and prev_rvs-doc.rvs-type   = {&rvs-shift}
    no-error.
end.

/*АЗС*/
find first buf_clients no-lock
  where buf_clients.obj-type = buf_rvs-doc.obj-type
    and buf_clients.obj-code = buf_rvs-doc.obj-code
  .
assign
  v-obj-name = buf_clients.obj-name
.
{ gbl/hostcode.i
  buf_rvs-doc.obj-type
  buf_rvs-doc.obj-code
  v-host-code
}
/*Своя фирма*/
find first buf_clients no-lock
  where buf_clients.obj-type = {&cmp}
    and buf_clients.obj-code = v-host-code
  .
assign
  v-host-name = buf_clients.obj-name

.

run prn-lib-open-stream in this-procedure
  ( input parparentproc
   ,input 45
   ,input yes
   ,input no
  ).

view stream PrnLibStream frame bottomframe .

assign
  v-header-name = substitute( "П Р О Т О К О Л  С Н Я Т И Я  П О К А З А Н И Й  У Р О В Н Е М Е Р А  № &1", buf_rvs-doc.rvs-code )
.

form header
  {&rvs-title}
  "Стр." at 160 string( page-number(PrnLibStream), ">>>9" )  skip
  {&rvs-line-frm}
  with frame topframe1
  width {&report-width-frame} page-top no-labels no-box .

form with frame rvs-line-frm .
view stream PrnLibStream frame topframe1 .

for each buf_rvs-line no-lock
  where buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code
:
  find first buf_goods no-lock
    where buf_goods.gds-code = buf_rvs-line.gds-code
  .
  assign
    v-water-qnty = buf_rvs-line.brutto-qnty - buf_rvs-line.measure-qnty
  .
  for first rvs-line-attr no-lock
        where rvs-line-attr.obj-code  = buf_rvs-line.obj-code
          and rvs-line-attr.obj-type  = buf_rvs-line.obj-type
          and rvs-line-attr.gds-code  = buf_rvs-line.gds-code
          and rvs-line-attr.pl-code   = buf_rvs-line.pl-code
          and rvs-line-attr.rvs-code  = buf_rvs-line.rvs-code
          and rvs-line-attr.attr-code = "pokmi-water-qnty"
  :
    v-water-qnty = decimal(rvs-line-attr.attr-value) .
  end .
  if v-water-qnty = ? then v-water-qnty = 0 .
  
  if line-counter( PrnLibStream ) + 1 > page-size( PrnLibStream ) then do:
    put stream PrnLibStream v-line1 .
    page stream PrnLibStream .
  end.
  display stream PrnLibStream
    sym1  buf_rvs-line.pl-code
    sym2  buf_goods.artic
    sym3  buf_goods.gds-name
    sym4  buf_rvs-line.brutto-qnty
    sym5  v-water-qnty
    sym6  buf_rvs-line.measure-qnty
    sym7  buf_rvs-line.state-measure-qnty
    sym8  buf_rvs-line.density
    sym9  buf_rvs-line.temperature
    sym10 buf_rvs-line.level-total
    sym11 buf_rvs-line.level-petrol
    sym12
    with frame rvs-line-frm.
  down stream PrnLibStream 1 with frame rvs-line-frm .
end.

hide frame rvs-line-frm .
hide stream PrnLibStream frame Topframe1 .
hide stream PrnLibStream frame bottomframe .

put stream PrnLibStream v-line1 skip(2).

find first buf_rvs-line-pump no-lock
  where buf_rvs-line-pump.rvs-code = buf_rvs-doc.rvs-code
  no-error .

if available buf_rvs-line-pump then do:
  form header
    {&rvs-title}
    "Стр." at 90 string( page-number(PrnLibStream), ">>>9" )  skip
    {&rvs-line-pump-frm}
    with frame topframe2
    width {&report-width-frame} page-top no-labels no-box .

  form with frame rvs-line-pump-frm .
  view stream PrnLibStream frame topframe2 .
  view stream PrnLibStream frame bottomframe .

  assign
    v-header-name = substitute( "П Р О Т О К О Л  С Н Я Т И Я  П О К А З А Н И Й  С Ч Е Т Ч И К О В  Т Р К  № &1", buf_rvs-doc.rvs-code )
    v-line1 = fill("-", 102 )
  .

  if line-counter( PrnLibStream ) + 10 > page-size( PrnLibStream ) then do:
    page stream PrnLibStream .
  end.
  else do:
    put stream PrnLibStream unformatted
      space (26) v-header-name skip(1)
      {&rvs-line-pump-frm}
      .
  end.


  for each buf_rvs-line-pump no-lock
    where buf_rvs-line-pump.rvs-code = buf_rvs-doc.rvs-code
  :
    find first buf_goods no-lock
      where buf_goods.gds-code = buf_rvs-line-pump.gds-code
    .
    assign
      v-delta-el-cnt = ?
    .

    if available prev_rvs-doc then do:
      find first prev_rvs-line-pump no-lock
        where prev_rvs-line-pump.rvs-code    = prev_rvs-doc.rvs-code
          and prev_rvs-line-pump.obj-type    = buf_rvs-line-pump.obj-type
          and prev_rvs-line-pump.obj-code    = buf_rvs-line-pump.obj-code
          and prev_rvs-line-pump.pl-code     = buf_rvs-line-pump.pl-code
          and prev_rvs-line-pump.gds-code    = buf_rvs-line-pump.gds-code
          and prev_rvs-line-pump.pump-code   = buf_rvs-line-pump.pump-code
          and prev_rvs-line-pump.nozzle-code = buf_rvs-line-pump.nozzle-code
        no-error .
      if available prev_rvs-line-pump then do:
        assign
          v-delta-el-cnt = buf_rvs-line-pump.state-el-cnt - prev_rvs-line-pump.state-el-cnt
        .
      end.
    end.

    if line-counter( PrnLibStream ) + 1 > page-size( PrnLibStream ) then do:
      put stream PrnLibStream v-line1 .
      page stream PrnLibStream .
    end.
    display stream PrnLibStream
      sym1  buf_rvs-line-pump.pump-code
      sym2  buf_rvs-line-pump.nozzle-code
      sym3  buf_goods.gds-name
      sym4  buf_rvs-line-pump.state-el-cnt
      sym5  v-delta-el-cnt
      sym6
      with frame rvs-line-pump-frm.
    down stream PrnLibStream 1 with frame rvs-line-pump-frm .
  end.

  /* делаем footer невидимым, чтобы он не напечатался на последней странице */
  hide stream PrnLibStream frame Topframe2 .
  hide stream PrnLibStream frame bottomframe .

  put stream PrnLibStream v-line1 skip.
  hide frame rvs-line-pump-frm .
end.

put stream PrnLibStream unformatted skip space(3) "Оператор___________________________(подпись)".

output stream PrnLibStream close.

run waitfram-hide in this-procedure  .

/* вывести */
run prn-lib-prn-file in this-procedure
  ( input parparentproc
   ,input 8
  ).