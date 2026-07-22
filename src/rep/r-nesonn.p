block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-nesonn.p $
$Archive: rep/r-nesonn.p $

Акт несоответствия поставке.

Автор: Белоусов Илья Александрович
Дата создания: 06/26/09
Author: Ilia Belousov
Creation date: 06/26/09


для Нижнего Новгорода
Свяэка Поставка + ПН
Если нет то сравниваем в накладной
*/
define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter rec_id               as recid            no-undo.


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$date: 30.10.03 13:52 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-nesonn.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-nesonn.p $":U .
define variable vss-description as character no-undo init "Акт несоответствия.".
{ cmp/vssrevis.i     }
{ cmp/str-glbl.i     }
{ cmp/library.i      }
{ gbl/cur-time.i     }
{ cmp/r-pril.i       }
{ str/trdcalib.i     }
{ str/clcprtsl.i     }
{ str/out-vatp.i def }
{ gbl/getcntxt.i def }
{ gbl/lineattr.i     }
define shared  variable CostPrice as logical   no-undo .

define temp-table temp_line-by-parts no-undo
    field gds-code          as integer
    field gds-name          as character
    field artic             as character
    field prod-type         as character
    field reason            as character
    field prod-code         as integer
    field price-base        as decimal
    field price-rubl        as decimal
    field doc-qnty          as decimal
    field fact-qnty         as decimal
    field delta-qnty        as decimal
    field delta-sum-base    as decimal
    field delta-sum-rubl    as decimal
    field delta-qnty-2      as decimal
    field delta-sum-base-2  as decimal
    field delta-sum-rubl-2  as decimal

    index pi is primary unique
        gds-code
        price-base
        price-rubl
.

define variable s1                          as character            no-undo.
define variable s2                          as character            no-undo.
define variable s3                          as character            no-undo.
define variable Isp_name                    as character            no-undo.

define variable Line                        as character            no-undo.
define variable upper                       as integer              no-undo.

/* излишки */
define variable UpSub_Price-Base            as decimal              no-undo.
define variable UpSub_Price-Rubl            as decimal              no-undo.
define variable UpSub_Qnty                  as decimal              no-undo.
/* недостача */
define variable downSub_Price-Base          as decimal              no-undo.
define variable downSub_Price-Rubl          as decimal              no-undo.
define variable downSub_Qnty                as decimal              no-undo.
/* всего */
define variable Sub_Price-Base              as decimal              no-undo.
define variable Sub_Price-Rubl              as decimal              no-undo.
define variable Sub_Qnty                    as decimal              no-undo.

define variable v-gds-name                  as character            no-undo.
define variable v-reason                    as character            no-undo.
define variable tprice-base                 as decimal              no-undo.
define variable tprice-rubl                 as decimal              no-undo.

define variable tsum_base                   as decimal              no-undo.
define variable tsum_rubl                   as decimal              no-undo.
define variable tqnty_                      as decimal              no-undo.

define variable sym1                        as character init ":"   no-undo.
define variable sym2                        as character init ":"   no-undo.

define variable v-exists-ord-num            as logical              no-undo.
define variable v-attr-type                 as character            no-undo.
define variable v-attr-value                as character            no-undo.
define variable v-ord-num                   as character            no-undo.
define variable v-b-code                    as integer              no-undo.

define variable v-tot-fact-qnty             as decimal              no-undo.
define variable v-tot-doc-qnty              as decimal              no-undo.
define variable v-tot-doc-qnty-base         as decimal              no-undo.
define variable v-tot-doc-qnty-rubl         as decimal              no-undo.
define variable v-tot-fact-qnty-base        as decimal              no-undo.
define variable v-tot-fact-qnty-rubl        as decimal              no-undo.
define variable v-tot-dsc-doc-qnty-base     as decimal              no-undo.
define variable v-tot-dsc-doc-qnty-rubl     as decimal              no-undo.
define variable v-tot-dsc-fact-qnty-base    as decimal              no-undo.
define variable v-tot-dsc-fact-qnty-rubl    as decimal              no-undo.

define variable v-tot-Sub_Qnty              as decimal              no-undo.
define variable v-tot-Sub_Price-Base        as decimal              no-undo.
define variable v-tot-Sub_Price-Rubl        as decimal              no-undo.
define variable v-tot-UpSub_Qnty            as decimal              no-undo.
define variable v-tot-UpSub_Price-Base      as decimal              no-undo.
define variable v-tot-UpSub_Price-Rubl      as decimal              no-undo.
define variable v-tot-downSub_Qnty          as decimal              no-undo.
define variable v-tot-downSub_Price-Base    as decimal              no-undo.
define variable v-tot-downSub_Price-Rubl    as decimal              no-undo.

define variable v-par-type                  as character            no-undo.
define variable g#report-num                as integer              no-undo.
define variable g#quest-print               as logical              no-undo.
define variable g#log                       as logical              no-undo.
define variable v-base-code                 as integer              no-undo.
define variable v-found                     as logical              no-undo.
define variable v-rcv-code                  as character            no-undo.
define variable v-rcv-doc-code              as character            no-undo.


define buffer buf_our_clients         for ub.clients.
define buffer buf_clients             for ub.clients.
define buffer buf_trn-doc             for ub.trn-doc.
define buffer buf_doc-line            for ub.doc-line.
define buffer buf_goods               for ub.goods.
define buffer buf_parts               for ub.parts.
define buffer buf_ord-doc             for ub.ord-doc .
define buffer buf_ord-doc-rcv         for ub.ord-doc-rcv .
define buffer buf_ord-line-rcv        for ub.ord-line-rcv .

define buffer buf_temp_line-by-parts  for temp_line-by-parts.

define frame x1
        sym1                  column-label ":!:"                                    format "X(1)" space(0)
        bar-code.b-code       column-label "Код     ! "                             format ">>>>>>>>>9"
        buf_goods.artic       column-label "Артикул! "                              format "X(16)"
        v-gds-name            column-label "Наименование! "                         format "X(33)"
        tprice-base           column-label "Цена за ед.!(Б.вал.) "                  format ">>>,>>>,>>9.99"
        BuF_doc-line.doc-qnty  column-label "Количество  !в поставке"                format "->>>>>>9.<<<"
        BuF_doc-line.fact-qnty column-label "Количество   !фактически"                format "->>>>>>>9.<<<"
        Sub_Qnty              column-label "Разница кол-во! "                       format "->>,>>>,>>9.<<"
        Sub_Price-Base        column-label "Разница сумма!(Б.вал.) "                format "->>>,>>>,>>9.99"
        v-reason              column-label "Причина! "                              format "X(20)"        space(0)
        sym2                  column-label ":!:"                                    format "X(1)"
    header
        cur-time-print() at 5 format "X(35)"
        string( "Страница " + string( PAGE-NUMBER, ">>9") ) at 110                  format "X(13)" skip
        Line no-label format "X(156)" at 1
    with width {&doS_CW} down stream-io use-text .

define frame x1-rubl
        sym1                  column-label ":!:"                                    format "X(1)" space(0)
        bar-code.b-code       column-label "Код! "                                  format ">>>>>>>>>9"
        buf_goods.artic       column-label "Артикул! "                              format "X(16)"
        v-gds-name            column-label "Наименование! "                         format "X(33)"
        tprice-rubl           column-label "Цена за ед.!({&abbr_rub_allshift})"     format ">>>,>>>,>>9.99"
        BuF_doc-line.doc-qnty  column-label "Количество  !в поставке"                format "->>>>>>9.<<<"
        BuF_doc-line.fact-qnty column-label "Количество   !фактически"               format "->>>>>>>9.<<<"
        Sub_Qnty              column-label "Разница кол-во! "                       format "->>,>>>,>>9.<<"
        Sub_Price-Rubl        column-label "Разница сумма!({&abbr_rub_allshift})"   format "->>>,>>>,>>9.99"
        v-reason              column-label "Причина! "                              format "X(20)"           space(0)
        sym2                  column-label ":!:"                                    format "X(1)"
    header
        cur-time-print() at 5 format "X(35)"
        string( "Страница " + string( PAGE-NUMBER, ">>9") ) at 110                  format "X(13)" skip
        Line no-label format "X(156)" at 1
    with width {&doS_CW} down stream-io use-text .

    define frame x2
        s1                    no-label                                              format "X(20)"
        s2                    column-label "Дата"                                   format "99/99/9999"
        tqnty_                column-label "Количество"                             format "->>>>,>>9.<<<"
        tsum_base             column-label "Сумма (Б.вал.)"                         format "->>,>>>,>>>,>>9.99"
    with /* centered */ width {&DOS_CW} down stream-io use-text .

    define frame x2-rubl
        s1                    no-label                                              format "X(20)"
        s2                    column-label "Дата"                                   format "99/99/9999"
        tqnty_                column-label "Количество"                             format "->>>>,>>9.<<<"
        tsum_rubl             column-label "Сумма ({&abbr_rub_allshift})"           format "->>>>>>,>>>,>>9.99"
    with width {&DOS_CW} down stream-io use-text .



    { gbl/getcntxt.i get " " p-mainmenu-handle }
    run get-report-num in p-mainmenu-handle (
        output g#report-num
    ).
    run get-quest-print in p-mainmenu-handle (
        output g#quest-print
    ).
    { gbl/basecode.i
        v-cntxt-host-code-obj
        v-base-code
    }



 find first buf_trn-doc no-lock    where recid( buf_trn-doc ) = rec_id  .



Line = fill("-", 160).
find first buf_clients no-lock
     where buf_clients.obj-type = buf_trn-doc.cli-type
       and buf_clients.obj-code = buf_trn-doc.cli-code
.
find first pay-type no-lock
     where pay-type.obj-code = buf_trn-doc.pay-code
no-error.
assign
    s1 = ( if available pay-type then pay-type.obj-name else "" )
.
find first buf_our_clients no-lock
     where buf_our_clients.obj-type = buf_trn-doc.obj-type
       and buf_our_clients.obj-code = buf_trn-doc.obj-code
.
run rep/get-psn.p ( input buf_trn-doc.boss, output s2 ).
run rep/get-psn.p ( input buf_trn-doc.wrkr, output s3 ).
run rep/get-psn.p ( input buf_trn-doc.agnt, output Isp_name ) .

{ cmp/open-out.i }

put
    skip
    space(35) "АКТ НЕСООТВЕТСТВИЯ по " format "X(22)"
.
  put
      "приходной накладной N " format "X(22)"
  .

  RUN find-other-doc-in-rcv in THIS-PROCEDURE ( INPUT buf_trn-doc.doc-code
                                              , OUTPUT v-found
                                              , OUTPUT v-rcv-code
                                              , OUTPUT v-rcv-doc-code
                                              ) .
  IF v-rcv-code = "":U
  OR v-rcv-code = ?
  OR ERROR-STATUS:ERROR
  THEN DO:
      ASSIGN
          v-found = TRUE
      NO-ERROR.
  END.
  /* Обрабатываем строки поставки которых нет в накладной */
  IF NOT v-found  THEN DO:
      FOR EACH buf_ord-line-rcv
          WHERE  buf_ord-line-rcv.doc-code  = v-rcv-doc-code
            AND buf_ord-line-rcv.rcv-code  = v-rcv-code
          NO-LOCK
          :
          IF CAN-FIND( FIRST buf_doc-line
                      WHERE buf_doc-line.artic     = buf_ord-line-rcv.artic
                        AND buf_doc-line.prod-type = buf_ord-line-rcv.prod-type
                        AND buf_doc-line.prod-code = buf_ord-line-rcv.PROD-CODE
                        AND buf_doc-line.doc-code  = buf_trn-doc.doc-code
                      NO-LOCK )
          THEN NEXT.
          find first buf_goods no-lock
              where buf_goods.prod-type  = buf_ord-line-rcv.prod-type
                and buf_goods.prod-code    = buf_ord-line-rcv.prod-code
                and buf_goods.artic        = buf_ord-line-rcv.artic
          .

          create buf_temp_line-by-parts.
          assign
            buf_temp_line-by-parts.prod-type = buf_goods.prod-type
            buf_temp_line-by-parts.prod-code = buf_goods.prod-code
            buf_temp_line-by-parts.artic     = buf_goods.artic
            buf_temp_line-by-parts.reason    = "Нет в накладной"

            buf_temp_line-by-parts.gds-name        = buf_goods.gds-name
            buf_temp_line-by-parts.gds-code        = buf_goods.gds-code
            buf_temp_line-by-parts.doc-qnty        = buf_ord-line-rcv.qnty
            buf_temp_line-by-parts.delta-qnty      = buf_ord-line-rcv.qnty

            buf_temp_line-by-parts.price-base      = buf_ord-line-rcv.price-base
            buf_temp_line-by-parts.price-rubl      = buf_ord-line-rcv.price-rubl
            buf_temp_line-by-parts.fact-qnty       = 0
            buf_temp_line-by-parts.delta-sum-base  = ( buf_ord-line-rcv.qnty ) * buf_ord-line-rcv.price-base
            buf_temp_line-by-parts.delta-sum-rubl  = ( buf_ord-line-rcv.qnty ) * buf_ord-line-rcv.price-rubl

            v-tot-Sub_Qnty                         = buf_temp_line-by-parts.delta-qnty
            v-tot-Sub_Price-Base                   = buf_temp_line-by-parts.delta-sum-base
            v-tot-Sub_Price-Rubl                   = buf_temp_line-by-parts.delta-sum-rubl
            v-tot-UpSub_Qnty                       = ( if buf_temp_line-by-parts.delta-qnty < 0 then buf_temp_line-by-parts.delta-qnty else 0 )
            v-tot-UpSub_Price-Base                 = ( if buf_temp_line-by-parts.delta-qnty < 0 then buf_temp_line-by-parts.delta-sum-base else 0 )
            v-tot-UpSub_Price-Rubl                 = ( if buf_temp_line-by-parts.delta-qnty < 0 then buf_temp_line-by-parts.delta-sum-rubl else 0 )

            v-tot-downSub_Qnty                     = ( if buf_temp_line-by-parts.delta-qnty > 0 then buf_temp_line-by-parts.delta-qnty else 0 )
            v-tot-downSub_Price-Base               = ( if buf_temp_line-by-parts.delta-qnty > 0 then buf_temp_line-by-parts.delta-sum-base else 0 )
            v-tot-downSub_Price-Rubl               = ( if buf_temp_line-by-parts.delta-qnty > 0 then buf_temp_line-by-parts.delta-sum-rubl else 0 )

            v-tot-doc-qnty                         = v-tot-doc-qnty           + buf_ord-line-rcv.qnty
            v-tot-doc-qnty-base                    = v-tot-doc-qnty-base      + buf_ord-line-rcv.qnty * buf_ord-line-rcv.price-base
            v-tot-doc-qnty-rubl                    = v-tot-doc-qnty-rubl      + buf_ord-line-rcv.qnty * buf_ord-line-rcv.price-rubl
          .
      END.
  END.




put
    substitute( "&1 от &2"
                , buf_trn-doc.doc-code
                , string( buf_trn-doc.doc-date , "99/99/9999" ) )
                format "X(100)"
    skip(1)
.

    put
        space(10)
        "От кого : "
        buf_clients.obj-name format "x(40)"
        skip
    .


    put space(10)
        "Кому    : " buf_our_clients.obj-type format "x(4)"
        buf_our_clients.obj-name format "x(40)"
        skip(1)
    .


put
        space(10) "Торговый представитель : " + s2          format "X(60)"
        space(5)  "Кладовщик              : " + s3          format "X(60)"
    skip
        space(10) "Исполнитель            : " + Isp_name    format "X(60)"
        space(5)  "Вид оплаты             : " + s1          format "X(60)"
    skip
.
    put
        space(75)
        "Курс                   : " + string( buf_trn-doc.base-rate / buf_trn-doc.base-scale, ">>>,>>9.9999" ) format "X(60)"
        skip(1)
    .

if CostPrice then do:
put
    space(40) "В учетных ценах." format "X(60)"
    skip
.

end.
else do:
put
    space(40) "В ценах поставщика." format "X(60)"
    skip
.
end.


if PrintRubl
then do:
    form with frame x1-rubl.
end.
else do:
    form with frame x1.
end.
form header
        Line format "X(156)" at 1
        skip "Продолжение - на следующей странице" at 30
        skip
with frame Bottomframe width {&A4_CW} page-bottom no-labels no-box .
view frame Bottomframe .

for each buf_temp_line-by-parts
on error undo, return error
:
   { gbl/gdsbcode.i
      buf_temp_line-by-parts.gds-code
      ?
      v-b-code
   }
   if PrintRubl
   then do:
      display
            sym1
            v-b-code                                                                    @ bar-code.b-code
            buf_temp_line-by-parts.artic
            buf_temp_line-by-parts.gds-name                                             @ v-gds-name
            buf_temp_line-by-parts.delta-sum-rubl / buf_temp_line-by-parts.delta-qnty   @ tprice-rubl
            buf_temp_line-by-parts.doc-qnty                                             @ BuF_doc-line.doc-qnty
            buf_temp_line-by-parts.fact-qnty                                            @ BuF_doc-line.fact-qnty
            buf_temp_line-by-parts.delta-qnty                                           @ Sub_Qnty
            buf_temp_line-by-parts.delta-sum-rubl                                       @ Sub_Price-Rubl
            buf_temp_line-by-parts.reason                                               @ v-reason
            sym2
      with frame x1-rubl.
      down 1 with frame x1-rubl.
   end.
   else do:
      display
            sym1
            v-b-code                                                                    @ bar-code.b-code
            buf_temp_line-by-parts.artic
            buf_temp_line-by-parts.gds-name                                             @ v-gds-name
            buf_temp_line-by-parts.delta-sum-base / buf_temp_line-by-parts.delta-qnty   @ tprice-base
            buf_temp_line-by-parts.doc-qnty                                             @ BuF_doc-line.doc-qnty
            buf_temp_line-by-parts.fact-qnty                                            @ BuF_doc-line.fact-qnty
            buf_temp_line-by-parts.delta-qnty                                           @ Sub_Qnty
            buf_temp_line-by-parts.delta-sum-base                                       @ Sub_Price-Base
            buf_temp_line-by-parts.reason                                               @ v-reason
            sym2
      with frame x1.
      down 1 with frame x1.
   end.
end.        /* for each buf_temp_line-by-parts */

for each buf_doc-line no-lock
   where buf_doc-line.doc-code = buf_trn-doc.doc-code
break by buf_doc-line.artic
      by buf_doc-line.prod-type
      by buf_doc-line.prod-code
:


    find first buf_goods no-lock
         where buf_goods.prod-type = buf_doc-line.prod-type
           and buf_goods.prod-code = buf_doc-line.prod-code
           and buf_goods.artic     = buf_doc-line.artic
    .

          FIND FIRST buf_ord-line-rcv
              WHERE  buf_ord-line-rcv.doc-code   = v-rcv-doc-code
                  AND buf_ord-line-rcv.rcv-code  = v-rcv-code
                  AND buf_ord-line-rcv.artic     = buf_doc-line.artic
                  AND buf_ord-line-rcv.prod-type = buf_doc-line.prod-type
                  and buf_ord-line-rcv.prod-code = buf_doc-line.prod-code
                NO-LOCK
                NO-ERROR
                .


               create buf_temp_line-by-parts.
               assign
                  buf_temp_line-by-parts.prod-type = buf_goods.prod-type
                  buf_temp_line-by-parts.prod-code = buf_goods.prod-code
                  buf_temp_line-by-parts.artic     = buf_goods.artic
                  buf_temp_line-by-parts.reason    = lineattr-get-reason (buffer buf_doc-line )
                  buf_temp_line-by-parts.gds-code        = buf_goods.gds-code
                  buf_temp_line-by-parts.price-rubl      = if CostPrice then buf_doc-line.price-rubl else ( buf_doc-line.price-cli / buf_doc-line.cli-base-rate ) * buf_trn-doc.exch-rate / buf_trn-doc.exch-scale
                  buf_temp_line-by-parts.price-base      = if CostPrice then buf_doc-line.price-base else  buf_temp_line-by-parts.price-rubl / ( buf_doc-line.price-rubl / buf_doc-line.price-base )

                  buf_temp_line-by-parts.doc-qnty        = if available buf_ord-line-rcv then buf_ord-line-rcv.qnty else  buf_doc-line.doc-qnty
                  buf_temp_line-by-parts.fact-qnty       = buf_doc-line.fact-qnty
                  buf_temp_line-by-parts.delta-qnty      = buf_temp_line-by-parts.doc-qnty - buf_temp_line-by-parts.fact-qnty

                  buf_temp_line-by-parts.delta-sum-base  = ( buf_temp_line-by-parts.delta-qnty ) * buf_temp_line-by-parts.price-base
                  buf_temp_line-by-parts.delta-sum-rubl  = ( buf_temp_line-by-parts.delta-qnty ) * buf_temp_line-by-parts.price-rubl

                  v-tot-Sub_Qnty                         = v-tot-Sub_Qnty           + buf_temp_line-by-parts.delta-qnty
                  v-tot-Sub_Price-Base                   = v-tot-Sub_Price-Base     + buf_temp_line-by-parts.delta-sum-base
                  v-tot-Sub_Price-Rubl                   = v-tot-Sub_Price-Rubl     + buf_temp_line-by-parts.delta-sum-rubl

                  v-tot-UpSub_Qnty                       = v-tot-UpSub_Qnty         + ( if buf_temp_line-by-parts.delta-qnty < 0 then buf_temp_line-by-parts.delta-qnty else 0 )
                  v-tot-UpSub_Price-Base                 = v-tot-UpSub_Price-Base   + ( if buf_temp_line-by-parts.delta-qnty < 0 then buf_temp_line-by-parts.delta-sum-base else 0 )
                  v-tot-UpSub_Price-Rubl                 = v-tot-UpSub_Price-Rubl   + ( if buf_temp_line-by-parts.delta-qnty < 0 then buf_temp_line-by-parts.delta-sum-rubl else 0 )

                  v-tot-downSub_Qnty                     = v-tot-downSub_Qnty       + ( if buf_temp_line-by-parts.delta-qnty > 0 then buf_temp_line-by-parts.delta-qnty else 0 )
                  v-tot-downSub_Price-Base               = v-tot-downSub_Price-Base + ( if buf_temp_line-by-parts.delta-qnty > 0 then buf_temp_line-by-parts.delta-sum-base else 0 )
                  v-tot-downSub_Price-Rubl               = v-tot-downSub_Price-Rubl + ( if buf_temp_line-by-parts.delta-qnty > 0 then buf_temp_line-by-parts.delta-sum-rubl else 0 )

                  v-tot-fact-qnty                        = v-tot-fact-qnty          + buf_doc-line.fact-qnty
                  v-tot-doc-qnty                         = v-tot-doc-qnty           + buf_temp_line-by-parts.doc-qnty
                  v-tot-doc-qnty-base                    = v-tot-doc-qnty-base      + buf_temp_line-by-parts.doc-qnty * buf_temp_line-by-parts.price-base
                  v-tot-doc-qnty-rubl                    = v-tot-doc-qnty-rubl      + buf_temp_line-by-parts.doc-qnty * buf_temp_line-by-parts.price-rubl
                  v-tot-fact-qnty-base                   = v-tot-fact-qnty-base     + buf_doc-line.fact-qnty * buf_temp_line-by-parts.price-base
                  v-tot-fact-qnty-rubl                   = v-tot-fact-qnty-rubl     + buf_doc-line.fact-qnty * buf_temp_line-by-parts.price-rubl

               .

            for each buf_temp_line-by-parts where
               buf_temp_line-by-parts.prod-type = buf_doc-line.prod-type
           and buf_temp_line-by-parts.prod-code = buf_doc-line.prod-code
           and buf_temp_line-by-parts.artic     = buf_doc-line.artic

            on error undo, return error
            :
               { gbl/gdsbcode.i
                  buf_goods.gds-code
                  ?
                  v-b-code
               }

               if buf_temp_line-by-parts.delta-qnty = 0 then next.

               if PrintRubl
               then do:
                  display
                        sym1
                        v-b-code                                                                    @ bar-code.b-code
                        buf_goods.artic
                        buf_goods.gds-name                                                          @ v-gds-name
                        buf_temp_line-by-parts.delta-sum-rubl / buf_temp_line-by-parts.delta-qnty   @ tprice-rubl
                        buf_temp_line-by-parts.doc-qnty                                             @ BuF_doc-line.doc-qnty
                        buf_temp_line-by-parts.fact-qnty                                            @ BuF_doc-line.fact-qnty
                        buf_temp_line-by-parts.delta-qnty                                           @ Sub_Qnty
                        buf_temp_line-by-parts.delta-sum-rubl                                       @ Sub_Price-Rubl
                        buf_temp_line-by-parts.reason                                               @ v-reason
                        sym2
                  with frame x1-rubl.
                  down 1 with frame x1-rubl.
               end.
               else do:
                  display
                        sym1
                        v-b-code                                                                    @ bar-code.b-code
                        buf_goods.artic
                        buf_goods.gds-name                                                          @ v-gds-name
                        buf_temp_line-by-parts.delta-sum-base / buf_temp_line-by-parts.delta-qnty   @ tprice-base
                        buf_temp_line-by-parts.doc-qnty                                             @ BuF_doc-line.doc-qnty
                        buf_temp_line-by-parts.fact-qnty                                            @ BuF_doc-line.fact-qnty
                        buf_temp_line-by-parts.delta-qnty                                           @ Sub_Qnty
                        buf_temp_line-by-parts.delta-sum-base                                       @ Sub_Price-Base
                        buf_temp_line-by-parts.reason                                               @ v-reason
                        sym2
                  with frame x1.
                  down 1 with frame x1.
               end.
            end.        /* for each buf_temp_line-by-parts */


    if last ( buf_doc-line.artic )
    then do:
        put
            Line format "X(156)"
            skip
        .
        if PrintRubl
        then do:
            display
                "ИТОГО" @ v-gds-name
                v-tot-Sub_Qnty          @ Sub_Qnty
                v-tot-Sub_Price-Rubl    @ Sub_Price-Rubl
            with frame x1-rubl.
            underline
                v-gds-name
                Sub_Qnty
                Sub_Price-Rubl
            with frame x1-rubl.
            down 2 with frame x1-rubl.
        end .
        else do:
            display
                "ИТОГО" @ v-gds-name
                v-tot-Sub_Qnty          @ Sub_Qnty
                v-tot-Sub_Price-Base    @ Sub_Price-Base
            with frame x1 .
            underline
                v-gds-name
                Sub_Qnty
                Sub_Price-Base
            with frame x1 .
            down 2 with frame x1 .
        end .
    end.
end.        /*for  each buf_doc-line ...*/
if PrintRubl
then do:
    repeat
    with frame x2-rubl
    :
        display
            "По документу" @ s1
            buf_trn-doc.doc-date @ s2
            v-tot-doc-qnty       @ tqnty_
            v-tot-doc-qnty-rubl  @ tsum_rubl
        .
        down 2.
        display
            "Фактически" @ s1
            buf_trn-doc.fact-date  @ s2
            v-tot-fact-qnty        @ tqnty_
            v-tot-fact-qnty-rubl   @ tsum_rubl
        .
        down 2.
        display
            "Разница" @ s1
            " " @ s2
            v-tot-Sub_Qnty          @ tqnty_
            v-tot-Sub_Price-Rubl    @ tsum_rubl
        .
        down 2.
        display
            "   в т.ч. недостача" @ s1
            " " @ s2
            v-tot-downSub_Qnty          @ tqnty_
            v-tot-downSub_Price-Rubl    @ tsum_rubl
        .
        down 2.
        display
            "          излишки " @ s1
            " " @ s2
           abs( v-tot-UpSub_Qnty )           @ tqnty_
           abs( v-tot-UpSub_Price-Rubl )     @ tsum_rubl
        .
        down 3.
        leave.
    end .
end.        /* if PrintRubl */
else do:
    repeat
    with frame x2
    :
        display  "По документу"  @ s1
            buf_trn-doc.doc-date @ s2
             v-tot-doc-qnty      @ tqnty_
             v-tot-doc-qnty-base @ tsum_base
        .
        down 2.
        display
            "Фактически" @ s1
            buf_trn-doc.fact-date @ s2
            v-tot-fact-qnty       @ tqnty_
            v-tot-fact-qnty-base  @ tsum_base
        .
        down 2.
        display
            "Разница"               @ s1
            " "                     @ s2
            v-tot-Sub_Qnty          @ tqnty_
            v-tot-Sub_Price-Base        @ tsum_base
        .
        down 2.
        display
            "   в т.ч. недостача"   @ s1
            " "                     @ s2
            v-tot-downSub_Qnty          @ tqnty_
            v-tot-downSub_Price-Base    @ tsum_base
        .
        down 2.
        display
            "          излишки "    @ s1
            " "                     @ s2
            abs(v-tot-UpSub_Qnty        )    @ tqnty_
            abs(v-tot-UpSub_Price-Base  )    @ tsum_base
        .
        down 3.
        leave.
    end .
end.        /* if NOT PrintRubl */

hide frame Bottomframe .

if not PrintRubl
then do:        /* оплата - в базовой валюте */
    run rep/wp.p (
          input p-mainmenu-handle
        , input absolute( v-tot-Sub_Price-Base )
        , output s1
        , output s2
    ) .
end.
else do:
    run rep/wp-rub.p (
          input absolute( v-tot-Sub_Price-Rubl )
        , output s1
        , output s2
    ) .
end.
put
    space(5) "Разница составила     :  " + caps(s1) format "X(128)"
    skip(1)
.
if v-base-code <> 0
and not PrintRubl
then do:        /* оплата - в базовой валюте */
    run rep/wp-rub.p (
          input absolute( v-tot-Sub_Price-Rubl )
        , output s1
        , output s2
    ) .
    put
        space(5)
        "( {&abbr_rublevy_firstshift} эквивалент :  " + trim( caps(s1) ) + " )" format "X(128)"
        skip(1)
    .
end.
put
"Подписи лиц, участвующих в составлении акта:"
skip(2)
"___________________               _________________________     ______________________________"
skip(0)
"   (должность)                           (подпись)                         (фамилия)"
skip(1)
"___________________               _________________________     ______________________________"
skip(0)
"   (должность)                           (подпись)                         (фамилия)"
skip(1)
"___________________               _________________________     ______________________________"
skip(0)
"   (должность)                           (подпись)                         (фамилия)"
skip(1)
.
output close.
define variable Log-Res as logical no-undo .
    { gbl/chk-actg.i
        v-cntxt-db-num
        v-cntxt-userid
        {&action-head-code-main}
        'actn_waybills-to-file_print':U
        {&cntxt-firm}
        v-cntxt-host-code-obj
        '':U
        0
        0
        0
        0
        no
        Log-Res
    }
    if Log-Res
    then do:
        { rep/q-print.i 0}
    end.
    else  do:
        { rep/q-print.i 4}
    end.


/*==========================================================================*/
PROCEDURE find-other-doc-in-rcv :
define input  parameter p-doc-code  as character     no-undo.
define output parameter p-found     as logical       no-undo.
define output parameter p-rcv-code  as character     no-undo.
define output parameter p-rcv-doc-code  as character no-undo.

define variable v-count-ord-chain    as integer      no-undo.
define variable v-count-trn-doc      as integer      no-undo.

define buffer buf_ord-chain      for ub.ord-chain .
define buffer buf2_ord-chain     for ub.ord-chain .
define buffer buf_ord-doc-rcv    for ub.ord-doc-rcv .

DO
ON ERROR UNDO, RETURN ERROR
:

   FOR EACH  buf_ord-chain
       WHERE buf_ord-chain.rel-doc-type = 'trn'
       AND   buf_ord-chain.rel-doc-code = p-doc-code
       AND   buf_ord-chain.doc-type     = 'rcv'
       NO-LOCK
       :
       ASSIGN
         v-count-ord-chain = v-count-ord-chain + 1
         p-rcv-code        = buf_ord-chain.doc-code
       .
       IF v-count-ord-chain > 1
       THEN DO:
          ASSIGN
            p-found     = TRUE
            p-rcv-code  = "":U
            p-rcv-doc-code = "":U
          .
          RETURN.
       END.

       FIND FIRST buf_ord-doc-rcv
            WHERE buf_ord-doc-rcv.rcv-code = buf_ord-chain.doc-code
            no-lock
            NO-ERROR
            .
       IF NOT AVAILABLE buf_ord-doc-rcv
       THEN DO:
          ASSIGN
            p-found = TRUE
            p-rcv-code  = "":U
            p-rcv-doc-code = "":U
          .
          RETURN.
       END.
       ASSIGN
         p-rcv-doc-code    = buf_ord-doc-rcv.doc-code
       .

       FOR EACH  buf2_ord-chain
           WHERE buf2_ord-chain.doc-code     = buf_ord-doc-rcv.rcv-code
           AND   buf2_ord-chain.doc-type     = 'rcv'
           AND   buf2_ord-chain.rel-doc-type = 'trn'
           AND   buf2_ord-chain.rel-doc-code <> p-doc-code
           NO-LOCK
           :

            ASSIGN
               p-found = TRUE
               p-rcv-code  = "":U
               p-rcv-doc-code = "":U
            .
            RETURN.
       END.
   END.
END. /* do on error */
END PROCEDURE. /* find-other-doc-in-rcv */