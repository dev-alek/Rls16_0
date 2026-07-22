block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: wth-exch.p $
$Archive: rep/wth-exch.p $

обмен талонов на нефтепродукты

Автор: Белоусов Илья Александрович
Дата создания: 10/10/07
Author: Ilia Belousov
Creation date: 10/10/07

Input:

Output:

*/
define input parameter parparentproc      as widget-handle no-undo .
define input parameter p-doc-code         as character FORMAT "x(14)"       no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: wth-exch.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/wth-exch.p $":U .
define variable vss-description as character no-undo init "обмен талонов на нефтепродукты".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ cmp/r-pril.i       }
{ gbl/waitfram.i noprocess  }

define stream Out-Stream.


define variable sym1  as character initial "|"   no-undo.
define variable sym2  as character initial "|"   no-undo.
define variable sym3  as character initial "|"   no-undo.
define variable sym4  as character initial "|"   no-undo.
define variable sym5  as character initial "|"   no-undo.
define variable sym6  as character initial "|"   no-undo.
define variable v-range       as character    no-undo.
define variable v-doc-date    as date         no-undo .
define variable v-firm-name   as character FORMAT "x(40)"    no-undo.
define variable g#quest-print as logical   no-undo .
define variable g#log         as logical   no-undo .
define variable g#report-num as integer   no-undo .
define variable v-counter    as integer      no-undo.

define buffer buf_goods        for ub.goods .
define buffer buf_wth-doc      for ub.wth-doc .
define buffer buf_clients      for ub.clients .
define buffer This_Object      for ub.clients .

  DEFINE FRAME frm-exch-1
      sym1                 no-label  format "X(1)"  space(0)
      ub.goods.gds-name       no-label  format "x(33)" space(0)

      sym3                 no-label  format "X(1)"  space(0)
      ub.wealth.wth-name      no-label  format "X(33)" space(0)

      sym2                 no-label  format "X(1)"  space(0)
      ub.wth-ser.series       no-label  format "X(18)" space(0)

      Sym4                 no-label  format "X(1)"  space(0)
      v-range              no-label  format "x(32)" space(0)

      sym5                 no-label  format "X(1)"  space(0)
      ub.wth-parts.fact-qnty  no-label  format "->>>,>>>,>>9"  space(0)

      sym6                 no-label  format "X(1)"  space(0)


     HEADER
         "+---------------------------------+---------------------------------+------------------+--------------------------------+------------+" skip
         "|                                 |                                 |                  |                                |            |" skip
         "|   Наименование нефтепродуктов   |             купюры              |       серия      |           № талона             | количество |" skip
         "|                                 |                                 |                  |                                |  талонов   |" skip
         "|                                 |                                 |                  |                                |            |" skip
         "+---------------------------------+---------------------------------+------------------+--------------------------------+------------+" skip
         "|                 1               |               2                 |         3        |                4               |      5     |" skip
      with width {&A4_CW0} down stream-io use-text no-label NO-BOX.


  DEFINE FRAME frm-exch-2
      sym1                 no-label  format "X(1)"  space(0)
      ub.goods.gds-name       no-label  format "x(33)" space(0)

      sym3                 no-label  format "X(1)"  space(0)
      ub.wealth.wth-name      no-label  format "X(33)" space(0)

      sym2                 no-label  format "X(1)"  space(0)
      ub.wth-ser.series       no-label  format "X(18)" space(0)

      Sym4                 no-label  format "X(1)"  space(0)
      v-range              no-label  format "x(32)" space(0)

      sym5                 no-label  format "X(1)"  space(0)
      ub.wth-parts.fact-qnty  no-label  format "->>>,>>>,>>9"  space(0)

      sym6                 no-label  format "X(1)"  space(0)


     HEADER
         "+---------------------------------+---------------------------------+------------------+--------------------------------+------------+" skip
         "|                                 |                                 |                  |                                |            |" skip
         "|   Наименование нефтепродуктов   |             купюры              |       серия      |           № талона             | количество |" skip
         "|                                 |                                 |                  |                                |  талонов   |" skip
         "|                                 |                                 |                  |                                |            |" skip
         "+---------------------------------+---------------------------------+------------------+--------------------------------+------------+" skip
         "|                 1               |               2                 |         3        |                4               |      5     |" skip
      with width {&A4_CW0} down stream-io use-text no-label NO-BOX.


MAIN-BLOCK:
do
on error undo, return error
:

   run waitfram-show in this-procedure ( input "Заполнение формы. Ждите..." ).

   find first buf_wth-doc
        where buf_wth-doc.doc-code = p-doc-code
        no-lock
        .
   assign
      v-doc-date = buf_wth-doc.fact-date
   .
   FIND FIRST This_Object
        WHERE This_Object.obj-type  = buf_wth-doc.obj-type
          AND This_Object.obj-code  = buf_wth-doc.obj-code
        NO-LOCK
        .
   FIND FIRST buf_clients
        WHERE buf_clients.obj-type  = {&cmp}
          AND buf_clients.obj-code  = buf_wth-doc.host-code
        NO-LOCK
        .
   assign
      v-firm-name = buf_clients.obj-name
   .
   release buf_wth-doc .

   run get-report-num  in parParentProc ( output g#report-num ).
   run get-quest-print in parParentProc ( output g#quest-print ).

   { cmp/open-out.i STREAM Out-Stream " "  {&CS_PS}  }

   assign
      v-counter = 0
   .
   /* лист 1 принято */
   run print-header-1 in this-procedure .
   run print-body-1   in this-procedure .
   run print-footer-1 in this-procedure .

   assign
      v-counter = 0
   .
   /* лист 2 выдано !!!  или не лист ? */
   run print-header-2 in this-procedure .
   run print-body-2   in this-procedure .
   run print-footer-2 in this-procedure .

   run waitfram-hide in this-procedure .
   output stream Out-Stream CLOSE .

   { rep/q-print.i 0}

end.



/*==========================================================================*/
procedure print-header-1 :

do
on error undo, return error
:

   PUT  STREAM Out-Stream
      SPACE(60) "Форма НН-3-ДО" SKIP
      SPACE(5) v-firm-name    FORMAT "x(40)"  SKIP
      SPACE(5) "_______________________________________" SKIP
      SPACE(5) "(наименование предприятия, организации)" SKIP
      SPACE(50) "+----------------+--------+" SKIP
      SPACE(50) "|   Вид операции | Склад  |" SKIP
      SPACE(50) "+----------------+--------+" SKIP
      SPACE(50) "|                |        |" SKIP
      SPACE(50) "+----------------+--------+" SKIP
      SPACE(21) "НАКЛАДНАЯ No." p-doc-code FORMAT "x(14)"  SKIP
      SPACE(15) "НА ОБМЕН ТАЛОНОВ НА НЕФТЕПРОДУКТЫ" SKIP
      SPACE(25) "(литровые)" SKIP
      SPACE(25) v-doc-date FORMAT "99/99/9999" "г." SKIP(1)
      SPACE(5) "Основание ____________________________________________________________" SKIP(1)
      SPACE(5) "Кому ________________________________ через кого _____________________" SKIP(1)
      SPACE(5) "доверенность No. ____________" SKIP(2)
      SPACE(11) "РАСШИФРОВКА ПРИНЯТЫХ ТАЛОНОВ НА НЕФТЕПРОДУКТЫ ПО"    SKIP
      SPACE(10) "КУПЮРАМ, СЕРИЯМ И НОМЕРАМ (ЕДИНЫХ, РЫНОЧНОГО ФОНДА)" SKIP(1)
   .




end. /* do on error */
end procedure. /* print-header-1 */




/*==========================================================================*/
procedure print-header-2 :

do
on error undo, return error
:
   PUT  STREAM Out-Stream
      SPACE(11) "РАСШИФРОВКА ВЫДАННЫХ ТАЛОНОВ НА НЕФТЕПРОДУКТЫ ПО" SKIP
      SPACE(10) "КУПЮРАМ, СЕРИЯМ И НОМЕРАМ (ЕДИНЫХ, РЫНОЧНОГО ФОНДА)" SKIP
   .
end. /* do on error */
end procedure. /* print-header-2 */




/*==========================================================================*/
procedure print-body-1 :
define buffer buf_wth-parts   for ub.wth-parts .
define buffer buf_wealth      for ub.wealth .
define buffer buf_goods       for ub.goods .
define buffer buf_wth-ser     for ub.wth-ser.

do
on error undo, return error
:
   for each buf_wth-parts
      where buf_wth-parts.out-code  = p-doc-code
      and buf_wth-parts.type      = {&income}  /* принято */
      no-lock
      ,
      first buf_wealth /* Мат. Цен. */
      where buf_wealth.wth-code     = buf_wth-parts.wth-code
      no-lock
      ,
      first buf_goods
      where buf_goods.gds-code      = buf_wth-parts.gds-code
      no-lock
      ,
      first buf_wth-ser  /* серия МЦ */
      where buf_wth-ser.ser-code    = buf_wth-parts.ser-code
      and buf_wth-ser.db-num      = buf_wth-parts.db-num
      no-lock
      :
         assign
            v-counter = v-counter + 1
         .
         display stream Out-Stream
            buf_goods.gds-name  @ ub.goods.gds-name
            buf_wealth.wth-name @ ub.wealth.wth-name
            buf_wth-ser.series  @ ub.wth-ser.series
            SUBSTITUTE("&1 - &2", buf_wth-parts.fact-rangeFrom, buf_wth-parts.fact-rangeTo) @ v-range
            buf_wth-parts.fact-qnty @ ub.wth-parts.fact-qnty
            sym1
            sym2
            sym3
            sym4
            sym5
            sym6
         with FRAME frm-exch-1.
         /*
         DOWN stream Out-Stream 1 with FRAME frm-exch.
         */
   end. /* each buf_wth-parts */
   /*
   if v-counter = 0 then do:
      DOWN stream Out-Stream 1 with FRAME frm-exch.
   end.
   */
end. /* do on error */
end procedure. /* print-body-1 */




/*==========================================================================*/
procedure print-body-2 :
define buffer buf_wth-parts   for ub.wth-parts .
define buffer buf_wealth      for ub.wealth .
define buffer buf_goods       for ub.goods .
define buffer buf_wth-ser     for ub.wth-ser.

do
on error undo, return error
:
   for each buf_wth-parts
      where buf_wth-parts.out-code  = p-doc-code
      and buf_wth-parts.type      = {&expense}   /* выдано */
      no-lock
      ,
      first buf_wealth /* Мат. Цен. */
      where buf_wealth.wth-code     = buf_wth-parts.wth-code
      no-lock
      ,
      first buf_goods
      where buf_goods.gds-code      = buf_wth-parts.gds-code
      no-lock
      ,
      first buf_wth-ser  /* серия МЦ */
      where buf_wth-ser.ser-code    = buf_wth-parts.ser-code
      and buf_wth-ser.db-num      = buf_wth-parts.db-num
      no-lock
      :
         assign
            v-counter = v-counter + 1
         .
         display stream Out-Stream
            buf_goods.gds-name  @ ub.goods.gds-name
            buf_wealth.wth-name @ ub.wealth.wth-name
            buf_wth-ser.series  @ ub.wth-ser.series
            SUBSTITUTE("&1 - &2", buf_wth-parts.fact-rangeFrom, buf_wth-parts.fact-rangeTo) @ v-range
            buf_wth-parts.fact-qnty @ ub.wth-parts.fact-qnty
            sym1
            sym2
            sym3
            sym4
            sym5
            sym6
         with FRAME frm-exch-2.
         /*
         DOWN stream Out-Stream 1 with FRAME frm-exch.
         */
   end. /* each buf_wth-parts */
   /*
   if v-counter = 0 then do:
      DOWN stream Out-Stream 2 with FRAME frm-exch.
   end.
   */
end. /* do on error */
end procedure. /* print-body-2 */



/*==========================================================================*/
procedure print-footer-1 :

do
on error undo, return error
:
   PUT  STREAM Out-Stream
   "+---------------------------------+---------------------------------+------------------+--------------------------------+------------+" skip
   .
   PUT  STREAM Out-Stream
      SKIP(2)
      SPACE(5) "Сдал    _____________________________  Принял _______________________" SKIP(4)
   .
end.  /* do on error */
end procedure. /* print-footer-1 */




/*==========================================================================*/
procedure print-footer-2 :

do
on error undo, return error
:
   PUT  STREAM Out-Stream
   "+---------------------------------+---------------------------------+------------------+--------------------------------+------------+" skip
   .
   PUT  STREAM Out-Stream
      SKIP(2)
      SPACE(5) "Сдал    _____________________________  Принял _______________________"
   .

end. /* do on error */
end procedure. /* print-footer-2 */