block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-pexcis.p $
$Archive: rep/r-pexcis.p $

Топливо: расчет акциза

Автор: Перваков Михаил Сергеевич
Дата создания: 04/11/06
Author: Mikhail Pervakov
Creation date: 04/11/06

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-curr-obj-type like ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code like ub.clients.obj-code no-undo .

def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: r-pexcis.p $":U .
def var vss-archive     as character no-undo init "$Archive: rep/r-pexcis.p $":U .
def var vss-description as character no-undo init "Топливо: расчет акциза".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/r-pril.i new }
{ gbl/prn-lib.i  }
{ gbl/lastdate.i }
{ gbl/cur-time.i }
{ gbl/waitfram.i }

/* параметры отчета */
define variable v-month         as integer  no-undo format "99" .
define variable v-year          as integer  no-undo format "9999" .
define variable l-ok            as logical  no-undo .
define variable v-first-date    as date     no-undo .
define variable v-last-date     as date     no-undo .
define variable v-today         as date     no-undo.

{ cmp/gds-list.i gds-list def "new shared" }
/* собираем данные, необходимые для печати отчета */
define temp-table temp-parts no-undo
    field artic                   like ub.parts.artic
    field prod-type               like ub.parts.prod-type
    field prod-code               like ub.parts.prod-code
    field in-code                 like ub.parts.in-code
    field part-code               like ub.parts.part-code
    field income-qnty             like ub.parts.fact-qnty /* приход в базовых единицах измерения */
    field fact-date               like ub.parts.fact-date /* дата фактического прихода */
    field this-month-sell-qnty    like ub.parts.fact-qnty /* расход в базовых единицах измерения */
    field this-month-kg-sell-qnty like ub.parts.fact-qnty /* расход в килограммах */
    field this-month-excise       as decimal
    field before-sell-qnty        like ub.parts.fact-qnty /* остаток в базовых единицах измерения */
    field free-qnty               like ub.parts.fact-qnty
    field cli-base-rate           like ub.parts.cli-base-rate
    field density                 like ub.doc-line.doc-density

    index xpk in-code part-code
  .


do while true :
  for each temp-parts:
      delete temp-parts.
  end.

  /* определение параметров отчета */
  /*  shared gds-list*/
  { gbl/curobjdt.i p-curr-obj-type p-curr-obj-code v-today }
  assign
    v-year  = year( v-today )
    v-month = month( v-today )
  .

  run rep/d-pinp.w
    (input  parparentproc
    ,input  "Расчет акциза" /* p-title */
    ,input-output v-month         /* p-month */
    ,input-output v-year          /* p-year  */
    ,output l-ok                  /* p-ok    */
    ).

  /* пользователь отказался от выполнения отчета */
  if l-ok <> true then do:
    return . /* --->>>--- */
  end.

  def var v-month-name as character no-undo format "x(12)".

  run gbl/monthnam.p
    (input  v-month
    ,output v-month-name
    ).

  assign
    v-first-date = date(v-month, 1, v-year)
  .
  run lastdate in this-procedure
    (input  v-first-date
    ,output v-last-date
    ).


  run fill-temp-parts in this-procedure .


  /* ширина отчета */
  &scop report-width    {&a4_cw0}
  &scop report-width-25 111

  def var v-ind         as integer   no-undo .
  def var v-line        as character no-undo format "X({&report-width})" .
  assign
    v-line = fill("-", {&report-width} )
  .
  def var v-line1        as character no-undo format "X({&report-width})" .
  def var v-line2        as character no-undo format "X({&report-width})" .
  def var v-line3        as character no-undo format "X({&report-width})" .
  assign
    v-line1 = v-line
    v-line2 = v-line
    v-line3 = v-line
  .

  /* определяем символы разделители */
  &scop sym format "x(1)":u label '!':u init ":":u

  def var sym1          as character no-undo {&sym} .
  def var sym2          as character no-undo {&sym} .
  def var sym3          as character no-undo {&sym} .
  def var sym4          as character no-undo {&sym} .
  def var sym5          as character no-undo {&sym} .
  def var sym6          as character no-undo {&sym} .
  def var sym7          as character no-undo {&sym} .
  def var sym8          as character no-undo {&sym} .
  def var sym9          as character no-undo {&sym} .
  def var sym10         as character no-undo {&sym} .
  def var sym11         as character no-undo {&sym} .
  def var sym12         as character no-undo {&sym} .
  def var sym13         as character no-undo {&sym} .
  def var sym14         as character no-undo {&sym} .
  def var sym15         as character no-undo {&sym} .


  run waitfram-show in this-procedure
    (input {&MyWaitMess}
    ) .

  run prn-lib-open-stream  in this-procedure (
                                             input parParentProc
                                            ,input {&CS_PS}
                                            ,input yes /*p-is-stream*/
                                            ,input no /*p-append*/
                                            ).


  /* выводим заголовок отчета, */
  /* который будет печататься только на первой странице */
  /*put stream PrnLibStream*/
  /*  space(25) "РЫБА для отчета без интерфейсной части. Список товаров."*/
  /*  /* format "x(90)" */ SKIP(1)*/
  /*  v-line skip*/
  /*  .*/

  find first clients no-lock
    where clients.obj-type = p-curr-obj-type
      and clients.obj-code = p-curr-obj-code
    .


  def var v-header-name as character no-undo .
  def var v-print-time  as character no-undo .

  assign
    v-header-name = "РАСЧЕТ АКЦИЗА - основан на алгоритме FIFO"
    v-print-time  = cur-time-string()
  .

  /* определяем header: заголовок, */
  /* который будет выводиться на каждой странице */
  form header
    v-line1 at 1 skip
    v-header-name + ": " + v-month-name + " " + string(v-year) format "x(50)" at 1
      "Дата печати :" at 60
      v-print-time format "x(20)"
      "Стр." at {&report-width-25} string( page-number(PrnLibStream), ">>>9" )  skip
    "ОБЪЕКТ:" at 1 clients.obj-type + " " + string(clients.obj-code) format "x(15)"
    clients.obj-name skip
    v-line2 at 1 skip
    with frame topframe
    width {&a4_cw} page-top no-labels no-box .
  view stream PrnLibStream frame topframe .


  /* определяем footer: нижнюю часть страницы, */
  /* которая будет выводиться на каждой странице */
  form header
    v-line at 1 skip
    "Продолжение на следующей странице" at 30 skip
    with frame bottomframe
    width {&a4_cw} page-bottom no-labels no-box .
  view stream PrnLibStream frame bottomframe .


  /**********************************************************************/
  /* Расчет акциза                                                      */
  /**********************************************************************/

  def var v-decrement-sell-qnty like ub.parts.fact-qnty no-undo .

  /* определяем фрейм в котором будут выводиться данные */
  define frame excise-frm
    goods.gds-name                     format "x(40)" column-label "ПРИХОД"
    temp-parts.fact-date               column-label "ДАТА ПРИХОДА"
    temp-parts.this-month-kg-sell-qnty column-label "КОЛ-ВО (КГ)"
    temp-parts.density                 column-label "ПЛ-ТЬ"
    temp-parts.this-month-sell-qnty    column-label "КОЛ-ВО"
    units.long-name                    format "x(20)" column-label "ЕД.ИЗМ."
    v-decrement-sell-qnty              column-label ""
    with width {&a4_cw} down stream-io use-text .

  form with frame excise-frm .

  /* выводим информацию об акцизах */
  for each gds-list no-lock
  ,first goods no-lock
    where goods.artic     = gds-list.artic
      and goods.prod-type = gds-list.prod-type
      and goods.prod-code = gds-list.prod-code
  :

    find first units no-lock
      where units.unit-name = goods.unit-base
      .

    /* считаем количество обработанных строк */
    assign
      v-ind = v-ind + 1
    .
    process events .

    run waitfram-show in this-procedure
      (input "Печать отчета. Обработано линий: " + string(v-ind)
      ) .

    def var v-total-month-sell-qnty    like ub.parts.fact-qnty .
    def var v-total-month-kg-sell-qnty as decimal no-undo .
    def var v-total-month-excise-qnty  as decimal no-undo .

    assign
      v-total-month-sell-qnty    = 0
      v-total-month-excise-qnty  = 0
      v-total-month-kg-sell-qnty = 0
    .

    for each temp-parts no-lock
      where temp-parts.artic                = goods.artic
        and temp-parts.prod-type            = goods.prod-type
        and temp-parts.prod-code            = goods.prod-code
    :
      assign
        v-total-month-sell-qnty    = v-total-month-sell-qnty
                                   + temp-parts.this-month-sell-qnty
        v-total-month-excise-qnty  = v-total-month-excise-qnty
                                   + temp-parts.this-month-excise
        v-total-month-kg-sell-qnty = v-total-month-kg-sell-qnty
                                   + temp-parts.this-month-kg-sell-qnty
      .
      assign
        temp-parts.free-qnty       = temp-parts.income-qnty
                                   - ( temp-parts.before-sell-qnty
                                     + temp-parts.this-month-sell-qnty
                                     )
      .

    end.

    /* выводим название товара */
    run on-same-page in this-procedure (input 3) .
    put stream PrnLibStream
      goods.gds-name at 1 skip
      .
    put stream PrnLibStream
      /* QUANTITY TO BE DISCHARGED */
      "КОЛИЧЕСТВО "
      fill("-", 89) + ">" format "x(90)"
      v-total-month-sell-qnty  skip
      .

    assign
      v-decrement-sell-qnty = v-total-month-sell-qnty
    .


    for each temp-parts no-lock
      where temp-parts.artic                = goods.artic
        and temp-parts.prod-type            = goods.prod-type
        and temp-parts.prod-code            = goods.prod-code
        and temp-parts.this-month-sell-qnty > 0
    :

      assign
        v-decrement-sell-qnty = v-decrement-sell-qnty
                              - temp-parts.this-month-sell-qnty
      .

      /* выводим очередную строку отчета */
      display stream PrnLibStream
        "ПРИХОД " + temp-parts.in-code +
          (if temp-parts.free-qnty > 0 then ".1" else "") @ goods.gds-name
        temp-parts.fact-date
        temp-parts.this-month-kg-sell-qnty
        temp-parts.density
        temp-parts.this-month-sell-qnty
        units.long-name
        v-decrement-sell-qnty
        with frame excise-frm .
      down stream PrnLibStream 1 with frame excise-frm .
    end.

    if v-total-month-kg-sell-qnty <> 0
    or v-total-month-sell-qnty    <> 0 then do:
      run on-same-page in this-procedure (input 3) .
      put stream PrnLibStream
        v-line  skip
        .
      display stream PrnLibStream
        "ПРОДАЖИ ЗА МЕСЯЦ"           @ goods.gds-name
        v-total-month-kg-sell-qnty @ temp-parts.this-month-kg-sell-qnty
        v-total-month-sell-qnty    @ temp-parts.this-month-sell-qnty
        units.long-name
        with frame excise-frm .
      down stream PrnLibStream 1 with frame excise-frm .
      put stream PrnLibStream
        v-line  skip
        .
    end.

    /* выводим информацию о непроданных остатках партий, */
    /* которые продавались в этом месяце */
    for each temp-parts no-lock
      where temp-parts.artic     = goods.artic
        and temp-parts.prod-type = goods.prod-type
        and temp-parts.prod-code = goods.prod-code
        and temp-parts.free-qnty > 0
    :
      /* выводим очередную строку отчета */
      display stream PrnLibStream
        "ПРИХОД " + temp-parts.in-code +
          (if temp-parts.free-qnty > 0 then ".2" else "") @ goods.gds-name
        temp-parts.fact-date
        (temp-parts.free-qnty / temp-parts.cli-base-rate ) @ temp-parts.this-month-kg-sell-qnty
        temp-parts.density
        temp-parts.free-qnty @ temp-parts.this-month-sell-qnty
        units.long-name
        with frame excise-frm .
      down stream PrnLibStream 1 with frame excise-frm .
    end.


    if v-total-month-kg-sell-qnty <> 0
    or v-total-month-sell-qnty    <> 0 then do:
      run on-same-page in this-procedure (input 6) .
      put stream PrnLibStream
        v-line skip
        goods.gds-name at 1 skip
        .
      put stream PrnLibStream
        "Итог"      at 1
          units.long-name format "x(20)" at 40
          "Кг"            at 70
          "Тонны"         at 90
        skip
        "продано за месяц"       at 1
          v-total-month-sell-qnty             at 40
          v-total-month-kg-sell-qnty          at 70
          (v-total-month-kg-sell-qnty / 1000) format "->>>,>>>,>>9.999999" at 90
        skip
        "акциз за месяц на тонну" at 1
          ( v-total-month-excise-qnty * 1000
          / v-total-month-kg-sell-qnty ) format "->>>,>>>,>>9.999999" at 90
        skip
        "акциз к оплате" at 1
          v-total-month-excise-qnty format "->>>,>>>,>>9.99" at 90
        skip
        .
    end.

    put stream PrnLibStream
      SKIP(2)
      .
  end.

  hide frame input-frm .


  /* выводим завершающую информацию, свидетельствующую о том, что отчет завершен */
  run on-same-page in this-procedure (input 2) .
  put stream PrnLibStream
    v-line  skip
    space(10) "Всего страниц в отчете" page-number(PrnLibStream) skip
    .

  /* делаем footer невидимым, чтобы он не напечатался на последней странице */
  hide stream PrnLibStream frame bottomframe .

  output stream PrnLibStream close.
  run waitfram-hide in this-procedure .


  /* вывести */
  run prn-lib-prn-file in this-procedure (
                                          input parParentProc
                                          ,input 0
                                          ).

end.


procedure on-same-page :
  /* позволяет перейти к следующей странице (если это необходимо)  */
  /* необходимо применять, перед выводом блок из нескольких строк, */
  /* который должен быть размещен в предлах одной страницы         */
  define input parameter p-line-number as integer no-undo .

  if p-line-number > page-size( PrnLibStream ) then do:
    /* запрошенное количество строк - превышает размер страницы */
    /* не переходим на следующую страницу */
    return .
  end.

  if line-counter( PrnLibStream ) + p-line-number > page-size( PrnLibStream ) then do:
    page stream PrnLibStream .
  end.

end procedure. /* on-same-page */

procedure next-page :
  page stream PrnLibStream .
end procedure. /* next-page */


procedure fill-temp-parts :

  run waitfram-show in this-procedure
    (input "Сбор данных..."
    ) .

  def var v-lookup-ind as integer no-undo .

  for each gds-list no-lock
  ,first goods no-lock
    where goods.artic     = gds-list.artic
      and goods.prod-type = gds-list.prod-type
      and goods.prod-code = gds-list.prod-code
  :

    find first units no-lock
      where units.unit-name = goods.unit-base
      .

    /* считаем количество обработанных строк */
    assign
      v-lookup-ind = v-lookup-ind + 1
    .

    run waitfram-show in this-procedure
      (input "Сбор данных. Обработано строк: " + string(v-lookup-ind)
      ) .

    for each doc-line no-lock
      where doc-line.obj-type  = p-curr-obj-type
        and doc-line.obj-code  = p-curr-obj-code
        and doc-line.artic     = goods.artic
        and doc-line.prod-type = goods.prod-type
        and doc-line.prod-code = goods.prod-code
        and doc-line.status_   = {&fact}
    , first trn-doc no-lock
      where trn-doc.doc-code = doc-line.doc-code
        and trn-doc.doc-type = {&expense}
        and trn-doc.internal = false
        and trn-doc.fact-date >= v-first-date
        and trn-doc.fact-date <= v-last-date

    :
      for each parts no-lock
        where parts.out-code  = doc-line.doc-code
          and parts.obj-type  = doc-line.obj-type
          and parts.obj-code  = doc-line.obj-code
          and parts.artic     = doc-line.artic
          and parts.prod-type = doc-line.prod-type
          and parts.prod-code = doc-line.prod-code
      :
        run create-temp-parts
          (buffer temp-parts
          ,buffer parts
          ).

        assign
          temp-parts.this-month-sell-qnty    = temp-parts.this-month-sell-qnty
                                             + parts.fact-qnty
          temp-parts.this-month-kg-sell-qnty = temp-parts.this-month-sell-qnty
                                             / temp-parts.cli-base-rate
          temp-parts.density                 = 1 / temp-parts.cli-base-rate
          temp-parts.this-month-excise       = temp-parts.this-month-excise
                                             + parts.fact-qnty * doc-line.excise
        .
      end.
    end.
  end.

  run waitfram-hide in this-procedure .

end procedure. /* fill-temp-parts */


procedure create-temp-parts :

  define parameter buffer buf_temp-parts for temp-parts .
  define parameter buffer buf_parts      for parts .

  find first buf_temp-parts no-lock
    where buf_temp-parts.artic     = buf_parts.artic
      and buf_temp-parts.prod-type = buf_parts.prod-type
      and buf_temp-parts.prod-code = buf_parts.prod-code
      and buf_temp-parts.in-code   = buf_parts.in-code
      and buf_temp-parts.part-code = buf_parts.part-code
    no-error .
  if not available buf_temp-parts then do:
    create buf_temp-parts .
    assign
      buf_temp-parts.artic     = buf_parts.artic
      buf_temp-parts.prod-type = buf_parts.prod-type
      buf_temp-parts.prod-code = buf_parts.prod-code
      buf_temp-parts.in-code   = buf_parts.in-code
      buf_temp-parts.part-code = buf_parts.part-code
    .

    assign
      buf_temp-parts.cli-base-rate = buf_parts.cli-base-rate
    .

    define buffer buf_income-trn-doc for ub.trn-doc .
    find first buf_income-trn-doc no-lock
      where buf_income-trn-doc.doc-code = buf_parts.in-code
      no-error .

    /* партия пришла по внешнему приходу */
    if  available buf_income-trn-doc
    and buf_income-trn-doc.doc-type = {&income}
    and buf_income-trn-doc.internal = false
    then do:
      define buffer buf_income-parts for ub.parts .
      find first buf_income-parts no-lock
        where buf_income-parts.obj-type  = buf_income-trn-doc.obj-type
          and buf_income-parts.obj-code  = buf_income-trn-doc.obj-code
          and buf_income-parts.artic     = buf_parts.artic
          and buf_income-parts.prod-type = buf_parts.prod-type
          and buf_income-parts.prod-code = buf_parts.prod-code
          and buf_income-parts.in-code   = buf_income-trn-doc.doc-code
          and buf_income-parts.out-code  = buf_income-trn-doc.doc-code
          and buf_income-parts.part-code = buf_parts.part-code
        no-error .

      if available buf_income-parts then do:
        assign
          buf_temp-parts.income-qnty = buf_income-parts.fact-qnty
          buf_temp-parts.fact-date   = buf_income-parts.fact-date
        .
      end.
    end.

    /* определяем все продажи партии продизошедшии ранее */
    define buffer buf_sell-trn-doc for ub.trn-doc .
    define buffer buf_sell-parts   for ub.parts .

    for each buf_sell-parts no-lock
      where buf_sell-parts.artic      = buf_parts.artic
        and buf_sell-parts.prod-type  = buf_parts.prod-type
        and buf_sell-parts.prod-code  = buf_parts.prod-code
        and buf_sell-parts.in-code    = buf_parts.in-code
        and buf_sell-parts.part-code  = buf_parts.part-code
        and buf_sell-parts.status_    = yes
        and buf_sell-parts.rsrv-free  = ?
        and buf_sell-parts.fact-date  < v-first-date
    ,first buf_sell-trn-doc no-lock
      where buf_sell-trn-doc.doc-code = buf_sell-parts.out-code
        and buf_sell-trn-doc.status_  = {&fact}
        and trn-doc.doc-type          = {&expense}
        and trn-doc.internal          = false
    :
      assign
        buf_temp-parts.before-sell-qnty = buf_temp-parts.before-sell-qnty
                                        + buf_sell-parts.fact-qnty
      .
    end.
  end.

end procedure. /* create-temp-parts */