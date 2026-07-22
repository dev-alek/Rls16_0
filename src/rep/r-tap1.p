block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-tap1.p $
$Archive: rep/r-tap1.p $

Акт переоценки ТАП-1-ДО

Автор: Белоусов Илья Александрович
Дата создания: 01/14/09
Author: Ilia Belousov
Creation date: 01/14/09

*/
define input parameter parparentproc     as handle           no-undo.
define input parameter rec_id            as recid            no-undo.
define input parameter p-price-celection as integer          no-undo.
define input parameter p-print-null-qnty as logical          no-undo.
define input parameter p-sort-by-group   as logical          no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-tap1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-tap1.p $":U .
define variable vss-description as character no-undo init "Акт переоценки ТАП-1-ДО".

&global-define frame-width  168

define variable g#report-num    as integer      no-undo.
define variable g#quest-print   as logical      no-undo.
define variable g#log           as logical      no-undo.

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ gbl/getcntxt.i def }
{ cmp/r-pril.i   new }
{ str/hvrdtax.i  }
{ gbl/paramls.i  }
{ rep/r-tap1.i   def }
{ rep/r-tap1xl.i }
{ cmp/r-page0.i new }
{ gbl/tax-name.i    }



define stream outstream . /* name - tap-str !!! */

define buffer obj_clients     for ub.clients .
define buffer firm_clients    for ub.clients .
define buffer buf_trn-doc     for ub.trn-doc .
define buffer buf_price-doc   for ub.price-doc .
define buffer buf_bar-code    for ub.bar-code .
define buffer buf_gds-prt     for ub.gds-prt .
define buffer buf_price-list  for ub.price-list .
define buffer buf_gds-obj     for ub.gds-obj .
define buffer buf_goods    for ub.goods .
define buffer buf_parts    for ub.parts .

define variable v-single-line       as character    no-undo .
define variable v-rb-is-base        as logical      no-undo .
define variable v-ok                as logical      no-undo .
define variable v-b-code            as character    no-undo .

define variable v-old-sum           as decimal      no-undo .
define variable v-new-sum           as decimal      no-undo .
define variable v-up-fact           as decimal      no-undo .

define variable propis              as character    no-undo .
define variable v-summ-all-before   as decimal      no-undo.
define variable v-qnty-all          as decimal      no-undo.
define variable abbr                as character    no-undo .
define variable v-line-counter      as integer      no-undo .
define variable v-empty             as character    no-undo .

define variable sym1                as character init "|"   no-undo .
define variable sym2                as character init "|"   no-undo .
define variable sym3                as character init "|"   no-undo .
define variable sym4                as character init "|"   no-undo .
define variable sym5                as character init "|"   no-undo .
define variable sym6                as character init "|"   no-undo .
define variable sym7                as character init "|"   no-undo .
define variable sym8                as character init "|"   no-undo .
define variable sym9                as character init "|"   no-undo .
define variable sym10               as character init "|"   no-undo .
define variable sym11               as character init "|"   no-undo .
define variable sym12               as character init "|"   no-undo .

define variable v-delta             as decimal      no-undo .

/* !!! frame */
  define frame f-tap
    sym1                         no-label format "X(1)"              space(0)
    v-line-counter               no-label format ">>>>9"             space(0)
    sym2                         no-label format "X(1)"              space(0)
    buf_price-list.artic         no-label format "X(16)"             space(0)
    sym3                         no-label format "X(1)"              space(0)
    buf_goods.gds-name           no-label format "X(35)"             space(0)
    sym4                         no-label format "X(1)"              space(0)
    v-empty                      no-label format "x(9)"              space(0)
    sym5                         no-label format "X(1)"              space(0)
    buf_goods.unit-base          no-label format "X(10)"             space(0)
    sym6                         no-label format "X(1)"              space(0)
    buf_price-list.doc-qnty      no-label format "->>>>>9.999"       space(0)
    sym7                         no-label format "X(1)"              space(0)
    v-price-list-price-sale_old  no-label format "->>>>>>>9.99"      space(0)
    sym8                         no-label format "X(1)"              space(0)
    v-old-sum                    no-label format "->>>>>>>>>>9.99"   space(0)
    sym9                         no-label format "X(1)"              space(0)
    buf_price-list.price-sale    no-label format "->>>>>>>9.99"      space(0)
    sym10                        no-label format "X(1)"              space(0)
    v-new-sum                    no-label format "->>>>>>>>>>9.99"   space(0)
    sym11                        no-label format "X(1)"              space(0)
    v-delta                      no-label format "->>>>>>>>>>9.99"   space(0)
    sym12                        no-label format "X(1)"              space(0)
    skip
  header
    "+-----+----------------+-----------------------------------+---------+----------+-----------+------------+---------------+------------+---------------+---------------+" skip
    "|  №  |      Код       |          Наименование ТМЦ         |Характер-|    Ед.   |  Кол-во   |       До переоценки        |      После переоценки      |     Сумма     |" skip
    "| п/п |   (номенклат.  |                                   | истика  |  измер.  |  (масса)  |                            |                            |   разницы от  |" skip
    "|     |     номер.)    |                                   |  ТМЦ    |          |           +------------+---------------+------------+---------------+   переоценки  |" skip
    "|     |                |                                   |         |          |           |    Цена    |     Сумма     |    Цена    |     Сумма     |   дооценки(+) |" skip
    "|     |                |                                   |         |          |           |            |               |            |               |   уценки(-)   |" skip
    "+-----+----------------+-----------------------------------+---------+----------+-----------+------------+---------------+------------+---------------+---------------+" skip
    "|  1  |       2        |                 3                 |    4    |     5    |     6     |      7     |       8       |      9     |       10      |       11      |" skip
    /*
    "+-----+----------------+-----------------------------------+---------+----------+----------+------------+---------------+-----------+---------------+---------------+" skip
    */
  with width {&frame-width} down stream-io no-labels no-box.

do
on error undo, return error
:
   RUN fill-tt         IN THIS-PROCEDURE .

   run open-stream     IN THIS-PROCEDURE .

   run print-header    in this-procedure .

   run print-body      in this-procedure .

   run print-footer    in this-procedure .

   run close-stream    IN THIS-PROCEDURE .

end.

/*==========================================================================*/
procedure fill-tt :

do
on error undo, return error
:
   { gbl/getcntxt.i get }
   { gbl/working.i }

   run get-report-num in parparentproc (
      output g#report-num
   ).
   run get-quest-print in parparentproc (
      output g#quest-print
   ).
   { gbl/rbisbase.i
      v-rb-is-base
   }

   find first buf_price-doc
        where recid(buf_price-doc) = rec_id
        no-lock
        .
   if not available buf_price-doc
   then do:
      bell.
      message 'Порушена табличка "price-doc"(r-tap1.p).'.
      return error.
   end.

   if  buf_price-doc.status_ <> {&act-overvalue}
   then do:
      bell.
      message 'Документ не акт переоценки (r-tap1.p).'.
      return error.
   end.


   /* !!!
   assign
      v-price-doc-doc-num  = buf_price-doc.doc-num
      v-price-doc-doc-date = buf_price-doc.doc-date
   .
   */

   find     obj_clients
      where obj_clients.obj-code = buf_price-doc.obj-code
      and   obj_clients.obj-type = buf_price-doc.obj-type
      no-lock
      .
   if not available obj_clients
   then do:
      bell.
      message 'Порушена табличка "clients" (r-tap1.p).'.
      return error.
   end.

   { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      'actn_overvalue-cast_print':U
      {&cntxt-firm}
      v-cntxt-host-code-obj
      '':U
      0
      0
      0
      0
      false
      v-ok
   }

   /* ???
   if  p-price-celection = 2
   then do:
      assign v-print-cost-price = TRUE .
   end.
   else do:
      assign v-print-cost-price = FALSE .
   end.
   */

   find     buf_trn-doc
      where buf_trn-doc.doc-code = buf_price-doc.doc-num
      no-lock
      no-error
      .

   find     firm_clients
      where firm_clients.obj-type = {&cmp}
      and   firm_clients.obj-code = buf_price-doc.host-code
      no-lock
   .

   assign
      v-single-line = fill("-", {&frame-width})
   .


end. /* do on error */
end procedure. /* fill-tt */



/*==========================================================================*/
procedure open-stream :

do
on error undo, return error
:

   { cmp/open-out.i stream outstream}

   run tap1-init in this-procedure.

end. /* do on error */
end procedure. /* open-stream */




/*==========================================================================*/
procedure print-header :

do
on error undo, return error
:
   put stream outstream
   skip(1)
   .
   put stream outstream skip(2)
      space(150)  "Форма ТАП-1-ДО"                                                            SKIP
         "Организация:"   firm_clients.obj-name "Утверждаю:  _____________________________" AT 108                SKIP
                                                   "должность"                AT 130                SKIP
         "структурное подразделение:"   obj_clients.obj-name  "_____________________________________" AT 120                SKIP
                                                            "  подпись      расшифровка подписи"  AT 120     SKIP
                                                            "«______» ____________ 200__г."AT 120  SKIP
      space(57)   "АКТ"                      "+-----------------+------------+" AT 101        SKIP
      space(50)   "О ПЕРЕОЦЕНКЕ ТОВАРОВ"     "|      Номер      |     от     |" AT 101        SKIP
                                             "+-----------------+------------+" AT 101        SKIP
                                             "|" AT 101       buf_price-doc.doc-num AT 102 "|" AT 119 buf_price-doc.doc-date format "99.99.9999" AT 121  "|" AT 132 SKIP
                                             "+----------------------+-------+-----------------+------------+"  AT 70       SKIP
                        "Основание составления акта" AT 30    "| Приказ, распоряжение | Номер |                 |" AT 70 SKIP
                                                              "+----------------------+-------+-----------------+" AT 70 SKIP
                                                              "| Ненужное зачеркнуть  |  от   |                 |" AT 70 SKIP
                                                              "+----------------------+-------+-----------------+" AT 70 SKIP
                  "Комиссия в составе: Председатель комиссии : _____________________________"            SKIP
      space(27)   "Члены комиссии : ____________________________________________________________________________________________________________________"          SKIP
                  "произвела переоценку товаров. Переоцененные товары перемаркированы."                  SKIP
      skip .

   form header
               /*v-single-line format "X({&frame-width})" at 1 skip*/
               "Продолжение - на следующей странице" at 30 skip
               with frame Bottomframe width {&A4_CW} page-bottom no-labels no-box .
   view stream outstream frame bottomframe .

   RUN tap1-write-cell-data IN THIS-PROCEDURE
       ( INPUT {&tap1-firm}
       , INPUT firm_clients.obj-name
       ) .
   RUN tap1-write-cell-data IN THIS-PROCEDURE
       ( INPUT {&tap1-object}
       , INPUT obj_clients.obj-name
       ) .
   RUN tap1-write-cell-data IN THIS-PROCEDURE
       ( INPUT {&tap1-doc_num}
       , INPUT buf_price-doc.doc-num
       ) .
   RUN tap1-write-cell-data IN THIS-PROCEDURE
       ( INPUT {&tap1-doc_date}
       , INPUT buf_price-doc.doc-date
       ) .


end. /* do on error */
end procedure. /* print-header */




/*==========================================================================*/
procedure print-body :

do
on error undo, return error
:
   form with frame f-tap .

   for each buf_price-list
      no-lock
      where buf_price-list.doc-num = buf_price-doc.doc-num
      ,
      each buf_goods
      no-lock
      where buf_goods.artic     = buf_price-list.artic
        and buf_goods.prod-type = buf_price-list.prod-type
        and buf_goods.prod-code = buf_price-list.prod-code
      break by buf_goods.artic descending
      :

      { rep/r-tap1.i calc}
      if v-code-is-main = yes
      then do:
         accumulate ( ( buf_price-list.price-sale - v-price-list-price-sale_old ) * buf_price-list.doc-qnty ) (total)
                      ( buf_price-list.doc-qnty ) (total)
                      ( buf_price-list.doc-qnty * v-price-list-price-sale_old ) (total)
                      ( buf_price-list.doc-qnty * buf_price-list.price-sale ) (total)
                      ( buf_price-list.doc-qnty * v-gds-obj-last-price ) (total) .

         run print-line-fact in this-procedure.
      end.                /* if v-code-is-main */
      if line-counter( outstream ) + 9 > page-size( outstream ) then /* !!! 9 */
            page stream outstream .

   end.                  /* for each price-list where ... */

   /*---S------- Сохраняем Итого для таблицы ---------------*/
   ASSIGN
      v-delta     = accum total ( ( buf_price-list.price-sale - v-price-list-price-sale_old) * buf_price-list.doc-qnty)
      v-new-sum   = accum total ( buf_price-list.doc-qnty * buf_price-list.price-sale )
      v-old-sum   = accum total ( buf_price-list.doc-qnty * v-price-list-price-sale_old )
      v-qnty-all  = accum total ( buf_price-list.doc-qnty )
   .


end. /* do on error */
end procedure. /* print-body */



/*==========================================================================*/
procedure print-footer :

do
on error undo, return error
:
   put stream outstream v-single-line format "X({&frame-width})" skip.
   display stream outstream
      "Всего" format "X(8)" @ buf_goods.gds-name
      v-qnty-all @ buf_price-list.doc-qnty
      v-old-sum
      v-new-sum
      v-delta
      with frame f-tap
   .
   /*
   underline stream outstream
            buf_goods.gds-name
            buf_price-list.doc-qnty
            v-old-sum
            v-new-sum
            v-delta
   with frame f-tap
   .
   */
   hide stream outstream frame Bottomframe .

   RUN tap1-write-cell-data IN THIS-PROCEDURE
       ( INPUT {&tap1-it_qnty}
       , INPUT v-qnty-all
       ) .

   RUN tap1-write-cell-data IN THIS-PROCEDURE
       ( INPUT {&tap1-it_summ_before}
       , INPUT v-old-sum
       ) .

   RUN tap1-write-cell-data IN THIS-PROCEDURE
       ( INPUT {&tap1-it_summ_after}
       , INPUT v-new-sum
       ) .

   RUN tap1-write-cell-data IN THIS-PROCEDURE
       ( INPUT {&tap1-it_delta}
       , INPUT v-delta
       ) .



   IF v-line-counter > 0
   THEN DO:
      run rep/wp-qnty.p (
            input absolute( 1 )
            , output propis
      ) .
      RUN tap1-write-cell-data IN THIS-PROCEDURE
         ( INPUT {&tap1-number_begin}
         , INPUT propis
         ) .
      define variable v-out-str    as character    no-undo.
      assign
         v-out-str = "Количество порядковых номеров: с № " + propis
      .

      run rep/wp-qnty.p (
            input absolute( v-line-counter )
            , output propis
      ) .
      RUN tap1-write-cell-data IN THIS-PROCEDURE
         ( INPUT {&tap1-number_end}
         , INPUT propis
         ) .
      assign
         v-out-str = v-out-str + " по № " + propis
      .
      put stream outstream
         v-out-str FORMAT "x({&frame-width})"
      .
   END.
   ELSE DO:
      ASSIGN
         propis = "Ноль"
      .
      RUN tap1-write-cell-data IN THIS-PROCEDURE
         ( INPUT {&tap1-number_begin}
         , INPUT propis
         ) .
      RUN tap1-write-cell-data IN THIS-PROCEDURE
         ( INPUT {&tap1-number_end}
         , INPUT propis
         ) .
      assign
         v-out-str = "Количество порядковых номеров: с № " + propis + " по № " + propis
      .
      put stream outstream
         v-out-str FORMAT "x({&frame-width})"
      .
   END.



   run rep/wp-qnty.p (
           input absolute( v-qnty-all )
         , output propis
   ) .
   IF propis = "":U
   OR TRUNCATE( v-qnty-all, 0) = 0
   THEN DO:
      ASSIGN
         propis = "Ноль " + propis
      .
   END.
   IF v-qnty-all < 0
   THEN DO:
      ASSIGN
         propis = "Минус " + propis
      .
   END.
   assign
      v-out-str = "Количество в натуральных показателях " + propis
   .
   put stream outstream skip
      v-out-str FORMAT "x({&frame-width})"
   .
   RUN tap1-write-cell-data IN THIS-PROCEDURE
       ( INPUT {&tap1-qnty_prop}
       , INPUT propis
       ) .



   if v-rb-is-base = yes
   then do:
      run rep/wp.p (
            input parparentproc
            , input absolute( v-delta )
            , output propis
            , output abbr
      ) .
   end.        /* if v-rb-is-base = yes */
   else do:
      run rep/wp-rub.p (
            input absolute( v-delta )
            , output propis
            , output abbr
      ) .
   end.        /* NOT ( if v-rb-is-base = yes ) */
   put stream outstream skip
            "Cумма переоценки: " format "X(18)"
            ( v-delta ) format "->>>>>>>>9.99"
            space(1)
            ( if v-rb-is-base = yes then "баз.вал" else "{&abbr_rub}" )         format "X(3)"
            " (" format "X(2)"
            .
   /*
   if TRUNCATE( v-delta, 0 ) = 0
   then dO:
      ASSIGN
         propis = "Ноль " + propis
      .
   END.
   */

   IF v-delta < 0
   THEN DO:
      ASSIGN
         propis = "Минус " + propis
      .
   END.

   put stream outstream
            string( propis + ")" )
               format "X(95)"
            .
   RUN tap1-write-cell-data IN THIS-PROCEDURE
       ( INPUT {&tap1-summ_prop}
       , INPUT propis
       ) .


   put stream outstream skip
      "Все члены комиссии предупреждены об ответственности за подписание акта, содержащего данные, несоответствующие действительности." SKIP(1)
      "          Председатель комиссии : _____________________  __________________  __________________________________" SKIP
      "                                        должность              подпись               расшифровка подписи       " SKIP(1)
      "                 Члены комиссии : _____________________  __________________  __________________________________" SKIP
      "                                        должность              подпись               расшифровка подписи       " SKIP(1)
      "                                : _____________________  __________________  __________________________________" SKIP
      "                                        должность              подпись               расшифровка подписи       " SKIP
   .


   if v-rb-is-base = yes
   then do:
      run rep/wp.p (
            input parparentproc
            , input absolute( v-new-sum )
            , output propis
            , output abbr
      ) .
   end.        /* if v-rb-is-base = yes */
   else do:
      run rep/wp-rub.p (
            input absolute( v-new-sum )
            , output propis
            , output abbr
      ) .
   end.
   /*
   if TRUNCATE( v-new-sum, 0 ) = 0
   then dO:
      ASSIGN
         propis = "Ноль " + propis
      .
   END.
   */

   IF v-new-sum < 0
   THEN DO:
      ASSIGN
         propis = "Минус " + propis
      .
   END.
   RUN tap1-write-cell-data IN THIS-PROCEDURE
       ( INPUT {&tap1-summ_after_prop}
       , INPUT propis
       ) .
   put stream outstream UNFORMATTED skip
      "Товарные ценности, перечисленные на общую сумму после переоценки " propis SKIP
      "находятся на моем (нашем) ответственном хранении. Материально-ответственное (ые) лицо (а)_____________________  __________________  __________________________________" SKIP
      "                должность              подпись               расшифровка подписи       " AT 77
   .




end. /* do on error */
end procedure. /* print-footer */




/*==========================================================================*/
procedure close-stream :

do
on error undo, return error
:

   output stream outstream close.

   { gbl/stopwork.i }

   run tap1-close in this-procedure .

   /* передаем управление пользователю */
   os-delete value( string( session:temp-directory ) + {&DF_Name} + string( g#report-num ) + ".txl" )  .
   os-rename
      value( string( session:temp-directory ) + "$" + string( g#report-num ) + ".txl" )
      value( string( session:temp-directory ) + {&DF_Name} + string( g#report-num ) + ".txl" )
   .

   { rep/q-print.i 8 }
   /*
   os-delete value( string( session:temp-directory ) + {&DF_Name} + string( g#report-num ) + ".txl" )  .
   */

end. /* do on error */
end procedure. /* close-stream */


procedure print-line-fact :
do
on error undo, return error
:
   if ( ( buf_price-list.price-sale - v-price-list-price-sale_old ) * buf_price-list.doc-qnty  <> 0 ) or ( p-print-null-qnty = yes )
   then do:
      assign
         v-line-counter = v-line-counter + 1
      .
      display stream outstream
         v-line-counter
         buf_price-list.artic
         v-gds-prt-node-name                                         @ buf_goods.gds-name
         buf_goods.unit-base
         buf_price-list.doc-qnty       when buf_price-list.doc-qnty <> ?
         v-price-list-price-sale_old
         ( buf_price-list.doc-qnty * v-price-list-price-sale_old )   @ v-old-sum
         buf_price-list.price-sale
         ( buf_price-list.doc-qnty * buf_price-list.price-sale )     @ v-new-sum
         (( buf_price-list.price-sale - v-price-list-price-sale_old ) * buf_price-list.doc-qnty )  @ v-delta
         sym1
         sym2
         sym3
         sym4
         sym5
         sym6
         sym7
         sym8
         sym9
         sym10
         sym11
         sym12
      with frame f-tap .
      down stream outstream 1 with frame f-tap .
      { rep/r-tap1.i third-tax fact sale}
      RUN tap1-sheet1-write-line-data IN THIS-PROCEDURE
         ( INPUT v-line-counter
         , INPUT buf_price-list.artic
         , INPUT v-gds-prt-node-name
         , INPUT "":U
         , INPUT buf_goods.unit-base
         , INPUT buf_price-list.doc-qnty
         , INPUT v-price-list-price-sale_old
         , INPUT ( buf_price-list.doc-qnty * v-price-list-price-sale_old )
         , INPUT buf_price-list.price-sale
         , INPUT ( buf_price-list.doc-qnty * buf_price-list.price-sale )
         , INPUT (( buf_price-list.price-sale - v-price-list-price-sale_old ) * buf_price-list.doc-qnty )
         ) .
   end.
end.
end procedure. /* print-line-fact */