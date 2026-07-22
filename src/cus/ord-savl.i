/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/24/10
Author: Bakhtadze Natalya
Creation date: 08/24/10

*/


&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

{ gbl/cur-time.i }
{ ref/grp-attr.i }
{ cus/str-edi.i  }

procedure ord-savl_process-line :
define parameter buffer buf_ord-doc for ub.ord-doc.
define parameter buffer buf_ord-line for ub.ord-line.


define variable v-root-node like ub.gds-prt.node-code no-undo .
/* ведется независимый учет товара по единице измерения клиента */
define variable l-goods-twounit as logical no-undo .
define variable rsrv-code       as character no-undo .

define variable v-today as date      no-undo.
define variable v-time  as integer   no-undo.

define variable return-AssMin   as logical   no-undo .
define variable return-igt      as character no-undo .
define variable gdop-min-stock  as decimal   no-undo .
define variable grop-max-stock  as decimal   no-undo .
define variable grop-level-always-presence  as decimal   no-undo .
define variable grop-min-order as decimal   no-undo .
define variable num_rec as integer no-undo .
define variable var-ok-assort-pol as logical   no-undo .
define variable var-mess-assort-pol as character no-undo .
define variable t-sum like ub.ord-line.qnty no-undo .
define variable v-str-ps as character no-undo .
define variable v-event-code as character no-undo .
define variable v-nabor       as logical   no-undo .
define variable is-edi-doc as logical no-undo .
define variable v-dm-edi  as integer no-undo .

define buffer buf_goods for ub.goods.
define buffer buf_ord-dtl for ub.ord-dtl.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:



  /* обновить информацию о текущей закрываемой строке */
  assign
  num_rec   = num_rec + 1
  .

  if num_rec mod 10 = 0 then do:
    run display-line-process in this-procedure ( input num_rec , buffer buf_ord-line).
  end.


  find first buf_goods no-lock
    where buf_goods.artic     = buf_ord-line.artic
      and buf_goods.prod-type = buf_ord-line.prod-type
      and buf_goods.prod-code = buf_ord-line.prod-code
    no-error .
  if not available buf_goods then do:
    undo main-block, return error substitute("&1 &2 &3&4Не найден товар&4"  +
                                             "Заказ &5&4 Артикул &6 &7&8&4 gds-code &9&4"
                                              ,vss-workfile
                                              ,vss-revision
                                              ,vss-description
                                              ,{&new-line}
                                              ,buf_ord-line.doc-code
                                              ,buf_ord-line.artic
                                              ,buf_ord-line.prod-type
                                              ,buf_ord-line.prod-code
                                              ,buf_ord-line.gds-code ) +
                                  substitute("&1"
                                              ,(if g#db-num = 0
                                              then "Если товар был переименован, необходимо принять новости в УБД и переформировать пакеты"
                                              else "")).
   end.
  /* Запрет на товары с ИЖТ - На вывод из ассортимента все кроме ПОКУПАТЕЛЯ */
  if buf_ord-doc.status_ = {&g___new}
  and buf_ord-doc.doc-type <> {&p-o}
  and buf_ord-doc.doc-type <> {&f-p}  then do:
     var-ok-assort-pol = true .
    { gbl/goassizt.i
      buf_ord-doc.doc-type
      buf_ord-line.gds-code
      buf_ord-doc.obj-type
      buf_ord-doc.obj-code
      "if g#news then false else true"
      var-ok-assort-pol
      var-mess-assort-pol
      }
    assign
    is-edi-doc = status-is-edi ( input yes  /*p-ies-edi*/
                        , input buf_ord-doc.cli-type
                        , input buf_ord-doc.cli-code
                        , input buf_ord-doc.obj-type
                        , input buf_ord-doc.obj-code
                        , output v-dm-edi
                        ) no-error.
    if var-ok-assort-pol = false and not g#news and not is-edi-doc then do:
      run ord-savl_del-str-info in this-procedure (  input buf_ord-doc.PS
                                                    , input var-mess-assort-pol
                                                    , output v-str-ps ) .
      buf_ord-doc.PS = v-str-ps .
      delete buf_ord-line .
      return .
    end.
    if buf_ord-doc.cli-type = {&shop} or
      buf_ord-doc.cli-type = {&stock} then do:
      var-ok-assort-pol = true .
      v-event-code = "cli_" + buf_ord-doc.doc-type .
      { gbl/goassizt.i
        v-event-code
        buf_ord-line.gds-code
        buf_ord-doc.cli-type
        buf_ord-doc.cli-code
        "if g#news then false else true"
        var-ok-assort-pol
        var-mess-assort-pol
        }
       if var-ok-assort-pol = false and not g#news then do:
          run ord-savl_del-str-info in this-procedure ( input buf_ord-doc.PS
                                             , input var-mess-assort-pol
                                             , output v-str-ps ) .
          buf_ord-doc.PS = v-str-ps .
          delete buf_ord-line .
          return .
       end.
     end.
   end.

   if buf_ord-doc.status_ = {&g___new}
   and buf_ord-doc.doc-type = {&P-O}  then do:
     var-ok-assort-pol = true .
     { gbl/goassmat.i
      buf_ord-line.gds-code
      buf_ord-doc.obj-type
      buf_ord-doc.obj-code
      "if g#news then false else true"
      var-ok-assort-pol
      var-mess-assort-pol
     }
     if var-ok-assort-pol = false and not g#news then do:
       run ord-savl_del-str-info in this-procedure ( input buf_ord-doc.PS
                                          , input var-mess-assort-pol
                                          , output v-str-ps ) .
        buf_ord-doc.PS = v-str-ps .
        delete buf_ord-line .
        return .
      end.
    end.
 /* проверка на букет */
    run ord-savl_ver-gds-flor in this-procedure ( input buf_goods.gds-code
                                        , output v-nabor ) no-error .
    if v-nabor = true then do:
      undo main-block, return error substitute("&1 &2 &3&4"  +
                                              "Заказ &5&4 Артикул &6 &7&8&4 &9&4"  +
                                              "является набором (букет) !!!&4" +
                                              "Удалите его из списка товаров !"
                                              ,vss-workfile
                                              ,vss-revision
                                              ,vss-description
                                              ,{&new-line}
                                              ,buf_ord-line.doc-code
                                              ,buf_ord-line.artic
                                              ,buf_ord-line.prod-type
                                              ,buf_ord-line.prod-code
                                              ,buf_goods.gds-name ).
    end.
    /* проверка услуги */
    if buf_goods.gds-type =  {&gds-office}  then do:
      undo main-block, return error substitute("&1 &2 &3&4"  +
                                              "Заказ &5&4 Артикул &6 &7&8&4 &9&4"  +
                                              "является услугой !!!&4" +
                                              "Удалите его из списка товаров !"
                                              ,vss-workfile
                                              ,vss-revision
                                              ,vss-description
                                              ,{&new-line}
                                              ,buf_ord-line.doc-code
                                              ,buf_ord-line.artic
                                              ,buf_ord-line.prod-type
                                              ,buf_ord-line.prod-code
                                              ,buf_goods.gds-name ).
    end.
    /* перенесение полей из шапки */
    assign
    buf_ord-line.obj-type = buf_ord-doc.obj-type
    buf_ord-line.obj-code = buf_ord-doc.obj-code
    buf_ord-line.status_  = buf_ord-doc.status_
    .

    if buf_ord-line.cli-base-rate = ?
    or buf_ord-line.cli-base-rate = 0 then do:
      assign
      buf_ord-line.cli-base-rate = buf_goods.cli-base-rate
     .
    end.
    if buf_ord-line.unit-cli = ?
    or buf_ord-line.unit-cli = "" then do:
      assign
      buf_ord-line.unit-cli = buf_goods.unit-cli
      .
    end.
/* Проверка количеств */

  t-sum = 0.
  for each buf_ord-dtl no-lock where
      buf_ord-dtl.doc-code  = buf_ord-line.doc-code and
      buf_ord-dtl.artic     = buf_ord-line.artic and
      buf_ord-dtl.prod-type = buf_ord-line.prod-type and
      buf_ord-dtl.prod-code = buf_ord-line.prod-code  :
    t-sum = t-sum + buf_ord-dtl.qnty.
  end.
  if t-sum > buf_ord-line.qnty then do:
    undo main-block, return error substitute("&1 &2 &3&4Количество по признакам больше чем по строке товара&4" +
                                            "Заказ &5&4 Артикул &6 &7&8&4 &9&4"  +
                                            "является услугой !!!&4" +
                                            "Удалите его из списка товаров !"
                                            ,vss-workfile
                                            ,vss-revision
                                            ,vss-description
                                            ,{&new-line}
                                            ,buf_ord-line.doc-code
                                            ,buf_ord-line.artic
                                            ,buf_ord-line.prod-type
                                            ,buf_ord-line.prod-code
                                            ,buf_goods.gds-name ).
  end.
end. /*doe */

end procedure . /* ord-savl_process-line */


procedure ord-savl_ver-gds-flor :
define input  parameter  p-gds-code as integer   no-undo .
define output parameter  p-nabor   as logical   no-undo .

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  p-nabor = false .
  run ver-gds-grp-nabor in this-procedure ( input p-gds-code, output p-nabor) .
end.
end procedure. /* ord-savl_ver-gds-flor  */


procedure ord-savl_del-str-info :
define input   parameter p-str1    as character no-undo .
define input   parameter p-str-dop as character no-undo .
define output  parameter p-str2    as character no-undo .
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  p-str1     = trim  (p-str1   ) .
  p-str-dop  = trim  (p-str-dop) .

  p-str1     = trim  (p-str1   ,{&new-line} ) .
  p-str-dop  = trim  (p-str-dop,{&new-line} ) .

  if length (p-str1) + length (p-str-dop )     >=  2000  then do:
    p-str2 = substitute ("&1 вся информация не умещается...." , p-str1 ) .
    return .
  end.
  p-str2  = substitute ("&1&3&2" , p-str1, p-str-dop ,{&new-line} ) .
end.
end procedure. /* ord-savl_del-str-info */