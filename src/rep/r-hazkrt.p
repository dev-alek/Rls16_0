block-level on error undo, throw.
/*
$Revision: 03db1cb6171b, 2763, rls $
$Author: EShklyar $
$Date: Сб фев 20 15:59:21 2021 +0300 $
$Workfile: r-hazkrt.p $
$Archive: rep/r-hazkrt.p $

Отчет "Почасовая реализация на АЗК"

Автор: Хныкин Павел Андреевич
Дата создания: 07/04/07
Author: Pavel Khnykin
Creation date: 07/04/07

*/
define input  parameter p-date-start      as date      no-undo .
define input  parameter p-time-start-sec  as integer   no-undo .
define input  parameter p-date-end        as date      no-undo .
define input  parameter p-time-end-sec    as integer   no-undo .

define variable vss-revision    as character no-undo init "$Revision: 03db1cb6171b, 2763, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Сб фев 20 15:59:21 2021 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-hazkrt.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-hazkrt.p $":U .
define variable vss-description as character no-undo init "Отчет Почасовая реализация на АЗК".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i  }
{ cmp/r-pril.i   }
{ rep/r-sym.i    }
{ gbl/waitfram.i }
{ rep/lkp-font.i }

define variable g#report-num  as integer no-undo .
run get-report-num in my-handle (output g#report-num).

{ gbl/paramls.i    }
{ rep/hazkrtxl.i   }

define temp-table tt-fuel-goods no-undo like ub.goods
  field gds-order as integer
  field b-code    like ub.bar-code.b-code
index pi is primary unique gds-order gds-code
index bc b-code
.

define temp-table tt-fuel-density no-undo
  field obj-type like obj-list.obj-type
  field obj-code like obj-list.obj-code
  field den-date as date
  field b-code   like ub.bar-code.b-code
  field density  as decimal
index pi is primary unique obj-type obj-code den-date b-code
.

define temp-table tt-host-list no-undo
  field host-code as integer
  field host-name as character
index pi host-code
.

define temp-table tt-fuel-chk no-undo like ub.chk-gds
  field db-num   like obj-list.db-num
  field obj-type like obj-list.obj-type
  field obj-code like obj-list.obj-code
index pi is primary unique obj-type obj-code b-code doc-code line-num
index db db-num b-code price-base
.

define temp-table tt-gds-sale no-undo
  field db-num   like obj-list.db-num
  field obj-type like obj-list.obj-type
  field obj-code like obj-list.obj-code
  field sale-sum as decimal
  field db-name  as character
index pi is primary unique db-num
index db db-num
.

define temp-table tt-price no-undo
  field db-num    like obj-list.db-num
  field b-code    like ub.bar-code.b-code
  field gds-code  like ub.goods.gds-code
  field price     as decimal
  field is-unique as logical
index pi is primary unique db-num b-code
.

define temp-table tt-report no-undo
  field db-num      like obj-list.db-num
  field db-name     as character
  field gds-order   as integer
  field gds-name    as character
  field vol-rtl     as decimal
  field price-rtl   as decimal
  field sale-sum    as decimal
index pi is primary unique db-num gds-order
.

define variable v-hosts as character no-undo .

define frame hazkrt
        sym1 column-label ":!:" format "X(1)" space(0)
        tt-report.db-name column-label "№ АЗС ! " format "X(10)" space(0)
        sym2 column-label ":!:" format "X(1)" space(0)
        tt-report.gds-name column-label "Топливо ! " format "X(20)" space(0)
        sym3 column-label ":!:" format "X(1)" space(0)
        tt-report.vol-rtl column-label "Реализация за сутки ! (тонн)" format ">>>>>>>>>9.99" space(0)
        sym4 column-label ":!:" format "X(1)" space(0)
        tt-report.price-rtl column-label "Цена реализации! " format ">>>>>>>>>9.99" space(0)
        sym5 column-label ":!:" format "X(1)" space(0)
        tt-report.sale-sum column-label "Выручка от реализации сопутствующих ! товаров за сутки " format "->>>>>>>>>>>>9.99" space(0)
        sym6 column-label ":!:" format "X(1)" space(0)
header
  v-hosts skip(1)
  "C:  " string(p-date-start , "99/99/9999") format "X(12)" string(p-time-start-sec, "hh:mm")  skip
  "По: " string(p-date-end , "99/99/9999") format "X(12)" string(p-time-end-sec, "hh:mm")  skip
  fill('-',106) format "X(106)"
with width {&DOS_CW} down stream-io.

function is-correct-name return logical ( input p-name as character) forward.

do on error undo , return error return-value :
  { gbl/working.i }
  run hazkrtxl-init in this-procedure .
  run waitfram-show in this-procedure ("Проверка топливных товаров...").
  run load-param-ptrl-gds in this-procedure .
  /* грузим чеки по бензину и собираем продажи по сопутствующим товарам */
  run load-chk in this-procedure .
  /* считаем чеки */
  run calc-chk in this-procedure .
  run print-header in this-procedure .

  define stream out-stream.
  { cmp/open-out.i stream out-stream " " {&CS_PS} }
  put stream out-stream "1" skip.
  output stream out-stream close.
  /* очищаем все за собой */
  run waitfram-show in this-procedure ("Удаление временных данных...").
  run clear-tt in this-procedure .
  run hazkrtxl-close in this-procedure .
  run waitfram-hide in this-procedure .
  { gbl/stopwork.i }
  os-delete value( string( session:temp-directory ) + {&DF_Name} + string( g#report-num ) + ".txl" )  .
  os-rename
    value( string( session:temp-directory ) + "$" + string( g#report-num ) + ".txl" )
    value( string( session:temp-directory ) + {&DF_Name} + string( g#report-num ) + ".txl" )
  .
  define variable v-user-action   as character no-undo .
  define variable v-printed       as logical   no-undo .
  define variable DisabledOptions as integer   no-undo .
  define variable v-orient-page as character no-undo .
  run How-name in this-procedure (
      input ReportPageHeight,
      input ReportPageWidth,
      output v-orient-page )
      .
  if v-orient-page = "A4-lans":U then DisabledOptions = 20 .
                                else DisabledOptions = 0 .

  run gbl/prnfilen.w
      (input  ""
      ,input  DisabledOptions
      ,input  string(session :temp-directory) + {&DF_Name} + string( g#report-num )
      ,input  ReportFontNum
      ,output v-user-action
      ,output v-printed
      ) .

  os-delete value( string( session:temp-directory ) + {&DF_Name} + string( g#report-num ) ) .
  os-delete value( string( session:temp-directory ) + {&DF_Name} + string( g#report-num ) + ".txl" ) .
end.


/*================================================================================*/
procedure load-param-ptrl-gds :
  /*
    Проверяем наличие параметра ptrlrep, его валидность
    и заполняем временную табличку tt-fuel-goods топливом в порядке определенном данным параметром
  */
do
on error undo, return error return-value
:
  &scop par-name "rep-sort":U

  define buffer buf_bar-code      for ub.bar-code.
  define buffer buf_goods         for ub.goods.
  define buffer buf_tt-fuel-goods for tt-fuel-goods.
  define buffer buf_gds-prt       for ub.gds-prt.

  define variable v-par-val       as character no-undo .
  define variable v-par-type      as character no-undo .
  define variable v-value-date    as date      no-undo .
  define variable v-value-decimal as decimal   no-undo .
  define variable v-value-integer as integer   no-undo .
  define variable v-value-logical as logical   no-undo .
  
  define variable v-tth           as handle               no-undo .
  define variable v-num           as integer              no-undo .
  define variable v-i             as integer              no-undo .
  define variable v-bc            like ub.bar-code.b-code no-undo .
  define variable v-gds-code      like ub.goods.gds-code  no-undo .
  define variable v-gds-code-str  as character            no-undo .


  run adm/shattri.p (
      input "get":U
      ,input  '' /*p-obj-type*/
      ,input  0 /*p-obj-code*/
      ,input  {&attr-report-glob}
      ,input  {&attr-report-glob_rep-sort} /*p-param-code*/
      ,output v-par-val
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-value-logical
      ,output v-par-type
      ,INPUT-OUTPUT table-handle v-tth
                    ) no-error.  

  if error-status :error
     or v-par-val = "":U
  then do:
    delete object v-tth.
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка чтения конфигурационного параметра " + {&attr-report-glob_rep-sort} + "." skip
      "Отчет не может быть сформирован"
      view-as alert-box error.
    undo, return error.
  end.
  else do:
  assign
/*  v-par-val = "1519510,1519511,1519512,1519513,105108,1513629,1517544,1519593,1513665,1520800":U непонятно почему тут это раньше было */
    v-num = num-entries(v-par-val).

  end.
  delete object v-tth.
/*  if v-num < 10 then do:                                                             */
/*    message                                                                          */
/*      vss-workfile vss-revision vss-description skip                                 */
/*      "Параметр " + {&par-name} + " содержит неверное количество кодов топлива." skip*/
/*      "В параметре должно быть задано 10 видов топлива." skip                        */
/*      "Отчет не может быть сформирован."                                             */
/*      view-as alert-box error.                                                       */
/*    undo, return error.                                                              */
/*  end.                                                                               */

  do v-i = 1 to v-num:
    assign
      v-gds-code =  integer( entry( v-i , v-par-val ) )
    .
    find first buf_goods no-lock
      where   buf_goods.gds-code = v-gds-code
    no-error .
    if not available buf_goods then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найден товар с кодом " + string(v-gds-code) + "." skip
        "Отчет не может быть сформирован."
        view-as alert-box error.
      undo, return error.
    end.

    find first buf_gds-prt no-lock
      where buf_gds-prt.upper-code = buf_goods.prt-root
    .

    find first buf_bar-code no-lock
      where buf_bar-code.gds-code   = buf_goods.gds-code
        and buf_bar-code.unit-cli   = buf_goods.unit-base
        and buf_bar-code.node-code  = buf_gds-prt.node-code
        and buf_bar-code.part-code  = ""
        and buf_bar-code.in-code    = ""
    no-error .
    if not available buf_bar-code then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найден бар-код для товара " + string(buf_goods.gds-code)+ " заданый в параметре " + {&par-name} + "." skip
        "Отчет не может быть сформирован."
        view-as alert-box error.
      undo, return error.
    end.
    else do:
      find first buf_tt-fuel-goods
        where buf_tt-fuel-goods.gds-code = buf_goods.gds-code
      no-error .
      if available buf_tt-fuel-goods then do:
        message
          vss-workfile vss-revision vss-description skip
          "В параметре " + {&par-name} + " заданы повторяющиеся коды " + string(v-gds-code)  skip
          "Отчет не может быть сформирован."
          view-as alert-box error.
        undo, return error.
      end.

      create buf_tt-fuel-goods.
      buffer-copy buf_goods to buf_tt-fuel-goods
      assign
        buf_tt-fuel-goods.gds-order = v-i
        buf_tt-fuel-goods.b-code    = buf_bar-code.b-code
      .
    end.
  end. /* do v-i = 1 to v-num: */

end. /* main do */
end procedure. /* load-param-ptrl-gds */


/*================================================================================*/
procedure load-firms :
do
on error undo, return error return-value
:
  define variable v-host-code as integer    no-undo .
  define variable v-host-name as character  no-undo .

  empty temp-table tt-host-list.
  for each obj-list no-lock
  :
    { gbl/hostname.i  obj-list.obj-type
                      obj-list.obj-code
                      v-host-code
                      v-host-name
    }
    find first tt-host-list
      where tt-host-list.host-code = v-host-code
    no-error .
    if not available tt-host-list then do:
      create tt-host-list.
      assign
        tt-host-list.host-code = v-host-code
        tt-host-list.host-name = v-host-name
      .
    end.
  end.
end.

end procedure. /* load-firms */


/*================================================================================*/
procedure load-chk :

define buffer buf_chk-doc         for ub.chk-doc.
define buffer buf_chk-pay         for ub.chk-pay.
define buffer buf_chk-gds         for ub.chk-gds.
define buffer buf_inkas           for ub.inkas.
define buffer buf_goods           for ub.goods.
define buffer buf_tt-fuel-goods   for tt-fuel-goods.
define buffer buf_tt-fuel-density for tt-fuel-density.
define buffer buf_tt-gds-sale     for tt-gds-sale.
define buffer buf_tt-fuel-chk     for tt-fuel-chk.


define variable v-ptrl-volume   as decimal   no-undo .
define variable v-gds-sale-sum  as decimal   no-undo .
define variable v-days-num      as integer   no-undo .
define variable v-day           as integer   no-undo .

&scop azk-word "АЗС":U

do
on error undo, return error return-value
:
  assign
    v-days-num = p-date-end - p-date-start
  .

  for each obj-list no-lock
  :
    /* обнуляем сумму продаж для текущего объекта */
    assign
      v-gds-sale-sum = 0
    .
    run waitfram-show in this-procedure ("Обработка чеков по объекту " + obj-list.obj-name + " ..." ).
    _chk-doc:
    for each buf_chk-doc no-lock
        where buf_chk-doc.obj-type  = obj-list.obj-type
          and buf_chk-doc.obj-code  = obj-list.obj-code
          and buf_chk-doc.chk-date >= p-date-start
          and buf_chk-doc.chk-date <= p-date-end ,
        /* проверяем наличие документа продажи */
        first buf_inkas no-lock
        where buf_inkas.inkas-code = buf_chk-doc.out-code
          and buf_inkas.status_    = {&fact}
    :
      /* отсекаем по времени */
      if      buf_chk-doc.chk-date = p-date-start
          and buf_chk-doc.chk-time < p-time-start-sec
      then do:
        next _chk-doc.
      end.
      if      buf_chk-doc.chk-date = p-date-end
          and buf_chk-doc.chk-time > ( p-time-end-sec + 60 ) /* включаем  60 секунд последней минуты :) */
      then do:
        next _chk-doc.
      end.
      /* отсекаем по типам */
      if lookup( string(buf_chk-doc.chk-type) , {&no-sale-receipt-codes} ) > 0 then do :
        next _chk-doc.
      end.
      /* по всем товарам из чека */
      for each buf_chk-gds no-lock
        where buf_chk-gds.doc-code = buf_chk-doc.doc-code
      :
        /*
          проверяем топливный товар или нет по нашему temp-table топлив
        */
        find first buf_tt-fuel-goods no-lock
          where buf_tt-fuel-goods.b-code = buf_chk-gds.b-code
        no-error .
        if available buf_tt-fuel-goods then do:
          /*
            надо посчитать объем

            Из чеков берется объем и умножается на плотность из приходных документов за данные календарные сутки,
            вне зависимости от времени. Далее делится на тысячу и округляется до второго знака.

          */
          /*
            PI -> obj-type obj-code b-code doc-code line-num
          */
          find first buf_tt-fuel-chk
            where buf_tt-fuel-chk.obj-type = buf_chk-doc.obj-type
              and buf_tt-fuel-chk.obj-code = buf_chk-doc.obj-code
              and buf_tt-fuel-chk.b-code   = buf_chk-gds.b-code
              and buf_tt-fuel-chk.doc-code = buf_chk-gds.doc-code
              and buf_tt-fuel-chk.line-num = buf_chk-gds.line-num
          no-error .
          if not available buf_tt-fuel-chk then do:
            create buf_tt-fuel-chk.
            buffer-copy buf_chk-gds to buf_tt-fuel-chk
            assign
              buf_tt-fuel-chk.obj-type    = buf_chk-doc.obj-type
              buf_tt-fuel-chk.obj-code    = buf_chk-doc.obj-code
              buf_tt-fuel-chk.db-num      = obj-list.db-num
              buf_tt-fuel-chk.price-base  = ( buf_chk-gds.price-base - buf_chk-gds.discnt)
            .
          end.
        end.
        else do:
        /* чек по сопутствующим товарам */
        assign
          v-gds-sale-sum = v-gds-sale-sum + ( buf_chk-gds.doc-qnty * ( buf_chk-gds.price-base - buf_chk-gds.discnt) )
        .
        end.
      end. /* for each buf_chk-gds no-lock */
    end. /* for each buf_chk-doc no-lock */

    /* собираем продажи сопутствующих товаров по всем объектам базы */
    find first buf_tt-gds-sale
      where buf_tt-gds-sale.db-num = obj-list.db-num
    no-error .
    if not available buf_tt-gds-sale then do:
      create buf_tt-gds-sale.
    end.
    assign
      buf_tt-gds-sale.db-num   = obj-list.db-num
      buf_tt-gds-sale.sale-sum = buf_tt-gds-sale.sale-sum + v-gds-sale-sum
    .
  end. /* for each obj-list no-lock  */

end.
end procedure. /* load */


/*================================================================================*/
procedure calc-chk :

define buffer buf_tt-fuel-chk     for tt-fuel-chk.
define buffer sch_tt-fuel-chk     for tt-fuel-chk.
define buffer buf_tt-price        for tt-price.
define buffer buf_tt-fuel-density for tt-fuel-density.
define buffer bf_tt-fuel-density  for tt-fuel-density.
define buffer buf_tt-report       for tt-report.
define buffer buf_tt-gds-sale     for tt-gds-sale .
define buffer buf_tt-fuel-goods   for tt-fuel-goods.

define variable v-density       like ub.doc-line.fact-density.
define variable v-unique-price  as logical   no-undo .
define variable v-sum1          as decimal   no-undo .
define variable v-sum2          as decimal   no-undo .
define variable v-gds-sale-sum  as decimal   no-undo .
define variable v-db-name       as character no-undo .

do
on error undo, return error return-value
:

   for each buf_tt-fuel-chk
      break by buf_tt-fuel-chk.db-num
      by buf_tt-fuel-chk.b-code
      :
      if first-of(buf_tt-fuel-chk.db-num) or first-of(buf_tt-fuel-chk.b-code) then 
      do:
         run waitfram-show in this-procedure ("Расчет по базе " + string( buf_tt-fuel-chk.db-num ) + " ..." ).
         /* были ли разные продажные цены? */
         find first sch_tt-fuel-chk no-lock
            where sch_tt-fuel-chk.db-num      = buf_tt-fuel-chk.db-num
            and sch_tt-fuel-chk.b-code      = buf_tt-fuel-chk.b-code
            and sch_tt-fuel-chk.price-base <> buf_tt-fuel-chk.price-base
            no-error .
         create buf_tt-price.
         assign
            buf_tt-price.db-num    = buf_tt-fuel-chk.db-num
            buf_tt-price.b-code    = buf_tt-fuel-chk.b-code
            buf_tt-price.price     = buf_tt-fuel-chk.price-base
            buf_tt-price.is-unique = if available sch_tt-fuel-chk then no else yes
            v-unique-price         = if available sch_tt-fuel-chk then no else yes
            .
      end. /* if first-of(buf_tt-fuel-chk.db-num) or first-of(buf_tt-fuel-chk.gds-code) */

      if not v-unique-price then 
      do :
         assign
            v-sum1 = v-sum1 + ( buf_tt-fuel-chk.price-base * buf_tt-fuel-chk.doc-qnty )
            v-sum2 = v-sum2 + buf_tt-fuel-chk.doc-qnty
            .
      end.

      if last-of(buf_tt-fuel-chk.db-num) or last-of(buf_tt-fuel-chk.b-code) then 
      do:
         if not v-unique-price then 
         do :
            find first buf_tt-price
               where buf_tt-price.db-num    = buf_tt-fuel-chk.db-num
               and buf_tt-price.b-code  = buf_tt-fuel-chk.b-code
               no-error .
            if available buf_tt-price then 
            do:
               assign
                  buf_tt-price.price = if v-sum2 > 0 then ( v-sum1 / v-sum2 ) else 0
                  .
            end.
         end.
         assign
            v-sum1 = 0
            v-sum2 = 0
            .
      end.
      /* считаем плотности по объектам топливам и датам */
      find first buf_tt-fuel-density
         where buf_tt-fuel-density.obj-type  = buf_tt-fuel-chk.obj-type
         and buf_tt-fuel-density.obj-code  = buf_tt-fuel-chk.obj-code
         and buf_tt-fuel-density.den-date  = buf_tt-fuel-chk.chk-date
         and buf_tt-fuel-density.b-code    = buf_tt-fuel-chk.b-code
         no-error .
      if not available buf_tt-fuel-density then 
      do:
         run find-density in this-procedure ( input buf_tt-fuel-chk.obj-type
            , input buf_tt-fuel-chk.obj-code
            , input buf_tt-fuel-chk.chk-date
            , input buf_tt-fuel-chk.b-code
            , output v-density
            ) .
         if v-density <> 0 then 
         do:
            create buf_tt-fuel-density .
            assign
               buf_tt-fuel-density.obj-type = buf_tt-fuel-chk.obj-type
               buf_tt-fuel-density.obj-code = buf_tt-fuel-chk.obj-code
               buf_tt-fuel-density.den-date = buf_tt-fuel-chk.chk-date
               buf_tt-fuel-density.b-code   = buf_tt-fuel-chk.b-code
               buf_tt-fuel-density.density  = v-density
               .
         end. /*if v-density <> 0 then do:*/
         else 
         do: /*Если по чекам за дату не найдена плотность и по накладной, тогда ищем за другую дату по чекам*/
            find first bf_tt-fuel-density
               where bf_tt-fuel-density.obj-type  = buf_tt-fuel-chk.obj-type
               and bf_tt-fuel-density.obj-code  = buf_tt-fuel-chk.obj-code
               and bf_tt-fuel-density.b-code    = buf_tt-fuel-chk.b-code
               no-error .
            if available (bf_tt-fuel-density) then 
            do:
               create buf_tt-fuel-density .
               assign
                  buf_tt-fuel-density.obj-type = buf_tt-fuel-chk.obj-type
                  buf_tt-fuel-density.obj-code = buf_tt-fuel-chk.obj-code
                  buf_tt-fuel-density.den-date = buf_tt-fuel-chk.chk-date
                  buf_tt-fuel-density.b-code   = buf_tt-fuel-chk.b-code
                  buf_tt-fuel-density.density  = bf_tt-fuel-density.density
                  .       
            end.
            else 
            do: /*Нет информации по плотности. Берем ее равной нулю*/
               for first ub.bar-code no-lock where ub.bar-code.b-code = buf_tt-fuel-density.b-code,
                  first ub.goods no-lock where ub.goods.gds-code = ub.bar-code.gds-code:
                  message
                     substitute( "Для объекта &5 &6 не найден ни один документ &4 для товара артикул: &2 , наименование: &3 . &4 Плотность для товара будет равно 0 ."
                     , ""
                     , ub.goods.artic
                     , ub.goods.gds-name
                     , {&new-line}
                     , buf_tt-fuel-chk.obj-type
                     , buf_tt-fuel-chk.obj-code
                     )
                     view-as alert-box information.
               end.
               create buf_tt-fuel-density .
               assign
                  buf_tt-fuel-density.obj-type = buf_tt-fuel-chk.obj-type
                  buf_tt-fuel-density.obj-code = buf_tt-fuel-chk.obj-code
                  buf_tt-fuel-density.den-date = buf_tt-fuel-chk.chk-date
                  buf_tt-fuel-density.b-code   = buf_tt-fuel-chk.b-code
                  buf_tt-fuel-density.density  = v-density
                  .
            end.      
         end.   
      end. /* if not available buf_tt-fuel-density then do: */
   end. /* for each buf_tt-fuel-chk no-lock */

  for each buf_tt-fuel-chk
  break by buf_tt-fuel-chk.db-num
        by buf_tt-fuel-chk.b-code
  :
    if first-of(buf_tt-fuel-chk.db-num) or first-of (buf_tt-fuel-chk.b-code) then do:
      find first buf_tt-gds-sale
        where buf_tt-gds-sale.db-num = buf_tt-fuel-chk.db-num
      no-error .
      find first tt-fuel-goods
        where tt-fuel-goods.b-code = buf_tt-fuel-chk.b-code
      no-error .
      find first buf_tt-price
        where buf_tt-price.db-num = buf_tt-fuel-chk.db-num
          and buf_tt-price.b-code = buf_tt-fuel-chk.b-code
      no-error .
      create buf_tt-report.
      assign
        buf_tt-report.db-num    = buf_tt-fuel-chk.db-num
        buf_tt-report.db-name   = buf_tt-gds-sale.db-name
        buf_tt-report.gds-order = tt-fuel-goods.gds-order
        buf_tt-report.gds-name  = tt-fuel-goods.gds-name
        buf_tt-report.sale-sum  = buf_tt-gds-sale.sale-sum
        buf_tt-report.price-rtl = buf_tt-price.price
      .
    end.
    find first buf_tt-fuel-density
      where buf_tt-fuel-density.obj-type = buf_tt-fuel-chk.obj-type
        and buf_tt-fuel-density.obj-code = buf_tt-fuel-chk.obj-code
        and buf_tt-fuel-density.den-date = buf_tt-fuel-chk.chk-date
        and buf_tt-fuel-density.b-code   = buf_tt-fuel-chk.b-code
    no-error .
    if not available buf_tt-fuel-density then do:
      message
        substitute ( "Не найдено значение плотности для топлива с бар-кодом: &1&5 на  объекте &2 &3 за &4"
                   , buf_tt-fuel-chk.b-code
                   , buf_tt-fuel-chk.obj-type
                   , buf_tt-fuel-chk.obj-code
                   , buf_tt-fuel-chk.chk-date
                   , {&new-line}
                   )
      view-as alert-box error.
      undo, return error.
    end.
    assign
      buf_tt-report.vol-rtl = buf_tt-report.vol-rtl + ( buf_tt-fuel-chk.doc-qnty * buf_tt-fuel-density.density )
    .
  end.

  define variable v-gds-name  as character no-undo .
  define variable v-vol-rtl   as character no-undo .
  define variable v-price-rtl as character no-undo .
/*
  field db-num      like obj-list.db-num
  field db-name     as character
  field gds-order   as integer
  field gds-name    as character
  field vol-rtl     as decimal
  field price-rtl   as decimal
  field sale-sum    as decimal

*/


  for each buf_tt-report
  break by buf_tt-report.db-num
        by buf_tt-report.gds-order
  :
    assign
      buf_tt-report.vol-rtl   = round( ( buf_tt-report.vol-rtl / 1000 ) , 2 )
      buf_tt-report.sale-sum  = round( ( buf_tt-report.sale-sum / 1000 ) , 2 )
    .
  end.

  for each obj-list no-lock
    break by obj-list.db-num
  :
    if first-of(obj-list.db-num) then do:
      assign
        v-db-name = ""
      .
      for each buf_tt-fuel-goods no-lock
      :
        find first buf_tt-report
          where buf_tt-report.db-num    = obj-list.db-num
            and buf_tt-report.gds-order = buf_tt-fuel-goods.gds-order
        no-error .
        if not available buf_tt-report then do:
          find first buf_tt-gds-sale
            where buf_tt-gds-sale.db-num = obj-list.db-num
          no-error .
          create buf_tt-report.
          assign
            buf_tt-report.db-num    = obj-list.db-num
            buf_tt-report.gds-order = buf_tt-fuel-goods.gds-order
            buf_tt-report.gds-name  = buf_tt-fuel-goods.gds-name
            buf_tt-report.vol-rtl   = 0
            buf_tt-report.price-rtl = 0
            buf_tt-report.sale-sum  = if available buf_tt-gds-sale then
                                        round( ( buf_tt-gds-sale.sale-sum / 1000 ) , 2 )
                                      else
                                        0
          .
        end.
      end.
    end. /* if first-of(obj-list.db-num) */
    if is-correct-name( input obj-list.obj-name ) then do:
      assign
        v-db-name = obj-list.obj-name
      .
    end.
    if last-of(obj-list.db-num) then do:
      if v-db-name = "" then do:
        assign
          v-db-name = "БД " + string(obj-list.db-num)
        .
      end.
      assign
        buf_tt-report.db-name = v-db-name
      .
    end. /* if last-of(obj-list.db-num) */

  end.

  for each buf_tt-report
  break by buf_tt-report.db-num
        by buf_tt-report.gds-order
  :
    assign
      v-gds-name   = v-gds-name   + {&hazkrtxl-row-delim} + buf_tt-report.gds-name
      v-vol-rtl    = v-vol-rtl    + {&hazkrtxl-row-delim} + string(buf_tt-report.vol-rtl)
      v-price-rtl  = v-price-rtl  + {&hazkrtxl-row-delim} + string( buf_tt-report.price-rtl , ">>>>>>9.99" )
    .

    if last-of (buf_tt-report.db-num) then do:
      assign
        v-gds-name   = trim( v-gds-name  , {&hazkrtxl-row-delim} )
        v-vol-rtl    = trim( v-vol-rtl   , {&hazkrtxl-row-delim} )
        v-price-rtl  = trim( v-price-rtl , {&hazkrtxl-row-delim} )
      .
      run hazkrtxl-write-line-data in this-procedure ( input buf_tt-report.db-name
                                                     , input v-gds-name
                                                     , input v-vol-rtl
                                                     , input v-price-rtl
                                                     , input buf_tt-report.sale-sum
                                                     ) .
      assign
        v-gds-name  = "":U
        v-vol-rtl   = "":U
        v-price-rtl = "":U
      .
    end.
  end. /* for each buf_tt-report  */
end.

end procedure. /* calc-checks */


/*================================================================================*/
procedure find-density :
/*
  Плотность = Сумма (фактический объем прихода * плотность прихода) / Сумма (Фактический объем прихода)
  Если приходов этого топлива за данный день не было, то плотность берется из последнего прихода.
*/
define input  parameter p-obj-type  like obj-list.obj-type    no-undo .
define input  parameter p-obj-code  like obj-list.obj-code    no-undo .
define input  parameter p-date      as date                   no-undo .
define input  parameter p-b-code    like ub.bar-code.b-code   no-undo .
define output parameter p-density   like ub.doc-line.fact-density  no-undo .

define buffer buf_trn-doc       for ub.trn-doc.
define buffer buf_doc-line      for ub.doc-line.
define buffer buf_goods         for ub.goods.
define buffer buf_tt-fuel-goods for tt-fuel-goods.

define variable v-i     as integer   no-undo .
define variable v-sum1  as decimal   no-undo .
define variable v-sum2  as decimal   no-undo .

do
on error undo, return error return-value
:
  find first buf_tt-fuel-goods
    where buf_tt-fuel-goods.b-code = p-b-code
  no-error .
  if not available buf_tt-fuel-goods then return.
  find first buf_goods no-lock
    where buf_goods.gds-code = buf_tt-fuel-goods.gds-code
  no-error .
  if not available buf_goods then do :
    message
      "Не найден товар с бар-кодом " + string( p-b-code )
    view-as alert-box error.
    undo, return error.
  end.

  for each buf_trn-doc no-lock
        where buf_trn-doc.obj-type     = p-obj-type
          and buf_trn-doc.obj-code     = p-obj-code
          and buf_trn-doc.status_      = {&fact}
          and buf_trn-doc.fact-date    = p-date
          and buf_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh},
      each buf_doc-line no-lock
        where buf_doc-line.doc-code   = buf_trn-doc.doc-code
          and buf_doc-line.artic      = buf_goods.artic
          and buf_doc-line.prod-type  = buf_goods.prod-type
          and buf_doc-line.prod-code  = buf_goods.prod-code
  :
    assign
      v-sum1 = v-sum1 + (buf_doc-line.fact-qnty * buf_doc-line.fact-density)
      v-sum2 = v-sum2 + buf_doc-line.fact-qnty
    .
  end.
  if v-sum2 > 0 then do:
    /* приходы за период были, считаем плотность */
    assign
      p-density = v-sum1 / v-sum2
    .
    return .
  end.
  /* Если приходов этого топлива за данный день не было, то плотность берется из последнего прихода.  */
  _find-last-doc:
  for each buf_trn-doc no-lock
        where buf_trn-doc.obj-type     = p-obj-type
          and buf_trn-doc.obj-code     = p-obj-code
          and buf_trn-doc.status_      = {&fact}
          and buf_trn-doc.fact-date    < p-date
          and buf_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh}
  by fact-date descending
  :
    find first buf_doc-line no-lock
      where buf_doc-line.doc-code   = buf_trn-doc.doc-code
        and buf_doc-line.artic      = buf_goods.artic
        and buf_doc-line.prod-type  = buf_goods.prod-type
        and buf_doc-line.prod-code  = buf_goods.prod-code
    no-error .
    if available buf_doc-line then do:
      assign
        v-sum1 = buf_doc-line.fact-density
      .
      leave _find-last-doc .
    end.
  end.
  if v-sum1 > 0 then do:
    assign
      p-density = v-sum1
    .
  end.
  else do:
    assign
      p-density = 0
    .
  end.
end.

end procedure. /* find-density */


/*================================================================================*/
procedure get-hosts :
define output parameter p-host-list as character no-undo .

define buffer buf_tt-host-list for tt-host-list.

do
on error undo, return error return-value
:
  run load-firms in this-procedure .

  for each buf_tt-host-list :
    assign
      p-host-list = p-host-list + buf_tt-host-list.host-name + "\n"
    .
  end.
  assign
    p-host-list = trim( p-host-list , "\n" )
  .
end.

end procedure. /* get-hosts */


/*================================================================================*/
procedure print-header :

do
on error undo, return error return-value
:
  run get-hosts in this-procedure ( output v-hosts ).
  run hazkrtxl-write-cell-data in this-procedure ( input {&hazkrtxl-h_hostName}
                                                 , input v-hosts
                                                 ).
  run hazkrtxl-write-cell-data in this-procedure ( input {&hazkrtxl-h_dateDayStart}
                                                 , input day(p-date-start)
                                                 ).
  run hazkrtxl-write-cell-data in this-procedure ( input {&hazkrtxl-h_dateMonthStart}
                                                 , input month(p-date-start)
                                                 ).
  run hazkrtxl-write-cell-data in this-procedure ( input {&hazkrtxl-h_dateYearStart}
                                                 , input year(p-date-start)
                                                 ).
  run hazkrtxl-write-cell-data in this-procedure ( input {&hazkrtxl-h_dateTimeStart}
                                                 , input string( p-time-start-sec , "HH:MM")
                                                 ).
  run hazkrtxl-write-cell-data in this-procedure ( input {&hazkrtxl-h_dateDayEnd}
                                                 , input day(p-date-end)
                                                 ).
  run hazkrtxl-write-cell-data in this-procedure ( input {&hazkrtxl-h_dateMonthEnd}
                                                 , input month(p-date-end)
                                                 ).
  run hazkrtxl-write-cell-data in this-procedure ( input {&hazkrtxl-h_dateYearEnd}
                                                 , input year(p-date-end)
                                                 ).
  run hazkrtxl-write-cell-data in this-procedure ( input {&hazkrtxl-h_dateTimeEnd}
                                                 , input string( p-time-end-sec , "HH:MM")
                                                 ).


end.

end procedure. /* print-header */

/*================================================================================*/
procedure clear-tt :

do
on error undo, return error return-value
:

  empty temp-table tt-fuel-goods .
  empty temp-table tt-fuel-density .
  empty temp-table tt-host-list .
  empty temp-table tt-fuel-chk .
  empty temp-table tt-gds-sale .
  empty temp-table tt-price .
  empty temp-table tt-report .

end.

end procedure. /* clear-tt */


/*================================================================================*/
function is-correct-name return logical ( input p-name as character) :

&scoped-define azk-words "АЗС,АЗК":U

define variable v-word  as character  no-undo.
define variable v-num   as integer    no-undo.
define variable v-i     as integer    no-undo.

v-num = num-entries({&azk-words}).

_find-cycle:
do v-i = 1 to v-num :
    v-word = entry( v-i , {&azk-words} ) .
    if ( index( caps(p-name) , v-word ) > 0 ) then do :
        return yes. /* --->>>--- */
    end.
end.
return no.
end function.