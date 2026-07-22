block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-pinp.p $
$Archive: rep/r-pinp.p $

Топливо: приходы, расходы, остатки на конец месяца

Автор: Уханов Дмитрий Юрьевич
Дата создания: 01/30/09
Author: Dmitry Ukhanov
Creation date: 01/30/09

Автор1: Перваков Михаил Сергеевич
Дата создания1: 04/11/06

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-curr-obj-type like ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code like ub.clients.obj-code no-undo .

def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: r-pinp.p $":U .
def var vss-archive     as character no-undo init "$Archive: rep/r-pinp.p $":U .
def var vss-description as character no-undo init "Топливо: приходы, расходы, остатки на конец месяца".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/r-pril.i new  }
{ gbl/prn-lib.i  }
{ gbl/lastdate.i }
{ gbl/getcntxt.i def }
{ cmp/obj-list.i new }
{ rep/ostatok.i  }
{ rep/ost-line.i }
{ gbl/cur-time.i }
{ gbl/waitfram.i }


/* параметры отчета */
def var v-month  as integer no-undo format "99"   .
def var v-year   as integer no-undo format "9999" .
def var l-ok     as logical no-undo .

def var v-first-date as date no-undo .
def var v-last-date  as date no-undo .

define variable var-x-p-curr-obj-code  like ub.clients.obj-code    no-undo.
define variable var-x-p-curr-obj-type  like ub.clients.obj-type    no-undo.
define variable var-x-date-start  like ub.stk-tot.Fact-date   no-undo.
define variable var-x-date-endt   like ub.stk-tot.Fact-date   no-undo.
define variable var-x-sum-type    like ub.stk-tot.sum-type    no-undo.
define variable var-x-cat-id      like ub.stk-tot.cat-id      no-undo.
define variable var-xTog-obj      as   log                 no-undo.

define variable var-Quantity      like ub.stk-tot.fact-qnty   initial ? no-undo.
define variable var-Coast_R       like ub.stk-tot.sum-rubl    no-undo.
define variable var-Coast_V       like ub.stk-tot.sum-rubl    no-undo.
define variable var-VAT_R         like ub.stk-tot.sum-rubl    no-undo.
define variable var-VAT_V         like ub.stk-tot.sum-rubl    no-undo.
define variable var-Fact-order    like ub.stk-tot.Fact-order  no-undo.

define variable var-x-artic       like ub.stk-line.artic        no-undo.
define variable var-x-prod-code   like ub.stk-line.prod-code    no-undo.
define variable var-x-prod-type   like ub.stk-line.prod-type    no-undo.

define variable var-SLT_R         like ub.stk-tot.sum-rubl    no-undo.
define variable var-SLT_V         like ub.stk-tot.sum-rubl    no-undo.

define variable v-today      as date      no-undo .
define variable v-archive-ok as logical   no-undo .
define variable v-comment    as character no-undo .
define variable v-can-print  as logical   no-undo .

{ cmp/gds-list.i gds-list def "new shared" }

{ gbl/getcntxt.i get }

define buffer buf_goods for ub.goods .
define buffer buf_trn-doc for ub.trn-doc .
define buffer buf_doc-line for ub.doc-line .
define buffer buf_parts for ub.parts .
define buffer buf_units for ub.units .

do while true :
  /* определение параметров отчета */
  /*  shared gds-list*/
  { gbl/curobjdt.i p-curr-obj-type p-curr-obj-code v-today }
  assign
    v-year  = year( v-today )
    v-month = month( v-today )
  .

  run rep/d-pinp.w
    (input        parparentproc
    ,input        "Приходы, расходы, остатки за месяц" /* p-title */
    ,input-output v-month                              /* p-month */
    ,input-output v-year                               /* p-year  */
    ,output       l-ok                                 /* p-ok    */
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

  find first ub.clients no-lock
    where ub.clients.obj-type = p-curr-obj-type
      and ub.clients.obj-code = p-curr-obj-code
    .

  define variable v-check-date as date      no-undo .
  assign
    v-check-date = v-last-date + 1
  .

  run rep/chk-ahz.p
    (input        ub.clients.obj-type /* p-obj-type          */
    ,input        ub.clients.obj-code /* p-obj-code          */
    ,input        no                  /* p-verify-detail     */
    ,input        yes                 /* p-verify-arh        */
    ,input        no                  /* p-verify-ahsp       */
    ,input        no                  /* p-verify-aht        */
    ,input        yes                 /* p-check-act         */
    ,input        v-cntxt-db-num      /* p-check-act-db-num  */
    ,input        v-cntxt-userid      /* p-check-act-user-id */
    ,input-output v-check-date        /* p-date-start        */
    ,input-output v-check-date        /* p-date-end          */
    ,output       v-archive-ok        /* p-archive-ok        */
    ,output       v-comment           /* p-comment           */
    ,output       v-can-print         /* p-can-print         */
    ) .
  if v-archive-ok = false
  then do:
    if v-can-print = true
    then do:
      define variable v-ok as logical   no-undo .
      message
        "ВНИМАНИЕ!" skip
        v-comment skip
        "" skip
        "Продолжить формирование отчета?" skip
        view-as alert-box question buttons yes-no update v-ok .
      if v-ok <> true
      then do:
        return . /* --->>>--- */
      end.
    end.
    else do:
      message
        "ВНИМАНИЕ !!!" skip
        "Отчет не может быть сформирован!" skip
        "На запрошенную дату нет архивов или они сжаты" skip
        v-comment skip
        view-as alert-box information .
      return . /* --->>>--- */
    end.
  end.

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


  run waitfram-show in this-procedure ( {&MyWaitMess} ) .

  run prn-lib-open-stream  in this-procedure (
                                             input parParentProc
                                            ,input {&CS_PS}
                                            ,input yes /*p-is-stream*/
                                            ,input no /*p-append*/
                                            ).



  def var v-header-name as character no-undo .
  def var v-print-time  as character no-undo .

  assign
    v-header-name = "ПРИХОДЫ"
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
  /* Отчет по приходам                                                  */
  /**********************************************************************/

  if v-archive-ok = false
  then do:
    put stream PrnLibStream
      "Расчитать полностью архивы не удалось." +
      "Информация в отчете может быть не корректной !" skip .
  end.


  /* определяем фрейм в котором будут выводиться данные */
  define frame input-frm
    buf_goods.gds-name        format "x(52)" column-label "ТОВАР"
    buf_trn-doc.fact-date                    column-label "ДАТА"
    buf_parts.cli-qnty                       column-label "КОЛ-ВО (КГ)"
    buf_doc-line.fact-density                column-label "ПЛ-ТЬ"
    buf_parts.fact-qnty                      column-label "КОЛ-ВО"
    buf_units.long-name       format "x(20)" column-label "ЕД.ИЗМ."
    with width {&a4_cw} down stream-io use-text .

  form with frame input-frm .

  /* производим выборку данных */
  for each gds-list no-lock
  ,first buf_goods no-lock
    where buf_goods.artic     = gds-list.artic
      and buf_goods.prod-type = gds-list.prod-type
      and buf_goods.prod-code = gds-list.prod-code
  :

    find first buf_units no-lock
      where buf_units.unit-name = buf_goods.unit-base
      .

    /* считаем количество обработанных строк */
    assign
      v-ind = v-ind + 1
    .
    process events .

    run waitfram-show in this-procedure ( "Линий обработано: " + string(v-ind) ) .

    def var v-total-cli-qnty  as decimal no-undo .
    def var v-total-fact-qnty as decimal no-undo .

    assign
      v-total-cli-qnty  = 0
      v-total-fact-qnty = 0
    .

    for each buf_doc-line no-lock
      where buf_doc-line.obj-type  = p-curr-obj-type
        and buf_doc-line.obj-code  = p-curr-obj-code
        and buf_doc-line.artic     = buf_goods.artic
        and buf_doc-line.prod-type = buf_goods.prod-type
        and buf_doc-line.prod-code = buf_goods.prod-code
        and buf_doc-line.status_   = {&fact}
    , first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = buf_doc-line.doc-code
        and buf_trn-doc.doc-type = {&income}
        and buf_trn-doc.internal = false
        and buf_trn-doc.fact-date >= v-first-date
        and buf_trn-doc.fact-date <= v-last-date

    :
      for each buf_parts no-lock
        where buf_parts.out-code  = buf_doc-line.doc-code
          and buf_parts.obj-type  = buf_doc-line.obj-type
          and buf_parts.obj-code  = buf_doc-line.obj-code
          and buf_parts.artic     = buf_doc-line.artic
          and buf_parts.prod-type = buf_doc-line.prod-type
          and buf_parts.prod-code = buf_doc-line.prod-code
      :
        /* выводим очередную строку отчета */
        display stream PrnLibStream
          buf_goods.gds-name
          buf_trn-doc.fact-date
          ( buf_parts.fact-qnty * buf_doc-line.fact-density ) @ buf_parts.cli-qnty
          buf_doc-line.fact-density
          buf_parts.fact-qnty
          buf_units.long-name
          with frame input-frm .
        down stream PrnLibStream 1 with frame input-frm .

        assign
          v-total-cli-qnty  = v-total-cli-qnty  + ( buf_parts.fact-qnty * buf_doc-line.fact-density )
          v-total-fact-qnty = v-total-fact-qnty + buf_parts.fact-qnty
        .
      end.
    end.

    display stream PrnLibStream
      "ВСЕГО " + v-header-name + " " + buf_goods.gds-name  @ buf_goods.gds-name
      v-total-cli-qnty @ buf_parts.cli-qnty
      v-total-fact-qnty @ buf_parts.fact-qnty
      buf_units.long-name
      with frame input-frm .
    down stream PrnLibStream 1 with frame input-frm .

    put stream PrnLibStream
      SKIP(2)
      .
  end.

  hide frame input-frm .

  /**********************************************************************/
  /* Отчет по расходам                                                  */
  /**********************************************************************/

  assign
    v-header-name = "РАСХОДЫ "
  .

  run next-page in this-procedure .


  /* определяем фрейм в котором будут выводиться данные */
  define frame output-frm
    buf_goods.gds-name     format "x(52)" column-label "ТОВАР"
    buf_trn-doc.fact-date                 column-label "ДАТА"
    buf_doc-line.fact-qnty                column-label "КОЛ-ВО"
    buf_units.long-name    format "x(20)" column-label "ЕД.ИЗМ."
    with width {&a4_cw} down stream-io use-text .

  form with frame output-frm .

  /* производим выборку данных */
  for each gds-list no-lock
  ,first buf_goods no-lock
    where buf_goods.artic     = gds-list.artic
      and buf_goods.prod-type = gds-list.prod-type
      and buf_goods.prod-code = gds-list.prod-code
  :

    find first buf_units no-lock
      where buf_units.unit-name = buf_goods.unit-base
      .

    /* считаем количество обработанных строк */
    assign
      v-ind = v-ind + 1
    .
    process events .

    run waitfram-show in this-procedure ( "Линий обработано: " + string(v-ind) ) .

    assign
      v-total-fact-qnty = 0
    .

    for each buf_doc-line no-lock
      where buf_doc-line.obj-type  = p-curr-obj-type
        and buf_doc-line.obj-code  = p-curr-obj-code
        and buf_doc-line.artic     = buf_goods.artic
        and buf_doc-line.prod-type = buf_goods.prod-type
        and buf_doc-line.prod-code = buf_goods.prod-code
        and buf_doc-line.status_   = {&fact}
    , first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = buf_doc-line.doc-code
        and buf_trn-doc.doc-type = {&expense}
        and buf_trn-doc.internal = false
        and buf_trn-doc.fact-date >= v-first-date
        and buf_trn-doc.fact-date <= v-last-date
    :
      /* выводим очередную строку отчета */
      display stream PrnLibStream
        buf_goods.gds-name
        buf_trn-doc.fact-date
        buf_doc-line.fact-qnty
        buf_units.long-name
        with frame output-frm .
      down stream PrnLibStream 1 with frame output-frm .

      assign
        v-total-fact-qnty = v-total-fact-qnty + buf_doc-line.fact-qnty
      .
    end.

    display stream PrnLibStream
      "ВСЕГО " + v-header-name + " " + buf_goods.gds-name  @ buf_goods.gds-name
      v-total-fact-qnty @ buf_doc-line.fact-qnty
      buf_units.long-name
      with frame output-frm .
    down stream PrnLibStream 1 with frame output-frm .

    put stream PrnLibStream
      SKIP(2)
      .
  end.


  hide frame output-frm .


  /**********************************************************************/
  /* Отчет по остаткам на конец месяца                                  */
  /**********************************************************************/
  assign
    v-header-name = "ОСТАТОК НА КОНЕЦ МЕСЯЦА"
  .

  run next-page in this-procedure .

  /* определяем фрейм в котором будут выводиться данные */
  define frame stock-frm
    buf_goods.gds-name      format "x(52)" column-label "ТОВАР"
    var-Quantity        column-label "КОЛ-ВО"
    buf_units.long-name     format "x(20)" column-label "ЕД.ИЗМ."
    with width {&a4_cw} down stream-io use-text .

  form with frame stock-frm .

  /* производим выборку данных */
  for each gds-list no-lock
  ,first buf_goods no-lock
    where buf_goods.artic     = gds-list.artic
      and buf_goods.prod-type = gds-list.prod-type
      and buf_goods.prod-code = gds-list.prod-code
  :

    find first buf_units no-lock
      where buf_units.unit-name = buf_goods.unit-base
      .

    /* считаем количество обработанных строк */
    assign
      v-ind = v-ind + 1
    .
    process events .

    run waitfram-show in this-procedure ( "Линий обработано: " + string(v-ind) ) .

    assign
      v-total-fact-qnty = 0
    .
    for each obj-list:
        delete obj-list.
    end.

    { cmp/cr-objls.i ub.clients.obj-type ub.clients.obj-code }
    assign
      var-x-p-curr-obj-code  = ub.clients.obj-code
      var-x-p-curr-obj-type  = ub.clients.obj-type
      var-x-date-start  = v-last-date
      var-x-date-endt   = ?
      var-x-sum-type    = {&arh-cost}
      var-x-cat-id      = {&root-cat-id}
      var-xTog-obj      = yes
    .

    run ostatok   (input var-x-p-curr-obj-code,
                   input var-x-p-curr-obj-type,
                   input no,
                   input var-x-date-start,
                   input var-x-date-endt ,
                   input ?               ,
                   input ?               ,
                   input var-x-sum-type  ,
                   input var-x-cat-id    ,
                   input var-xTog-obj    ,
                   output var-Quantity   ,
                   output var-Coast_R    ,
                   output var-Coast_V    ,
                   output var-VAT_R      ,
                   output var-VAT_V      ,
                   output var-Fact-order ).

   ASSIGN var-x-artic     = buf_goods.artic
          var-x-prod-code = buf_goods.prod-code
          var-x-prod-type = buf_goods.prod-type.

   RUN ost-line  (
      input   var-x-p-curr-obj-code,
      input   var-x-p-curr-obj-type,
      INPUT   var-x-artic     ,
      INPUT   var-x-prod-code ,
      INPUT   var-x-prod-type ,
      input   no              ,
      INPUT   var-Fact-order  ,
      input   var-x-sum-type  ,
      input   var-x-cat-id    ,
      input   var-xTog-obj    ,
      output  var-Quantity    ,
      output  var-Coast_R     ,
      output  var-Coast_V     ,
      output  var-VAT_R       ,
      output  var-VAT_V       ,
      output  var-SLT_R       ,
      output  var-SLT_V       ).


    /* выводим очередную строку отчета */
    display stream PrnLibStream
      "ОСТАТОК " + buf_goods.gds-name @ buf_goods.gds-name
      var-Quantity
      buf_units.long-name
      with frame stock-frm .
    down stream PrnLibStream 1 with frame stock-frm .

    put stream PrnLibStream
      SKIP(2)
      .
  end.


  hide frame stock-frm .




  /* выводим завершающую информацию, свидетельствующую о том, что отчет завершен */
  run on-same-page in this-procedure (input 2) .
  put stream PrnLibStream
    v-line  skip
    space(10) "Всего страниц" page-number(PrnLibStream) skip
    .

  /* делаем footer невидимым, чтобы он не напечатался на последней странице */
  hide stream PrnLibStream frame bottomframe .

  output stream PrnLibStream close.
  run waitfram-hide in this-procedure .

  /* вывести */

  run prn-lib-prn-file in this-procedure (
                                          input parParentProc
                                          ,input 8
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