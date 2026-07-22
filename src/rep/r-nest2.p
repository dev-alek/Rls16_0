block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-nest2.p $
$Archive: rep/r-nest2.p $

Акт несоответствия с округлением

Автор: Демин Алексей Сергеевич
Дата создания: 09/15/05
Author: Alexey Demin
Creation date: 09/15/05

Input:

Output:

*/

define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter rec_id               as recid            no-undo.
define input parameter Discnt_Type          as integer          no-undo.
define input parameter PriceType            as character        no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-nest2.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-nest2.p $":U .
define variable vss-description as character no-undo init "Акт несоответствия с округлением".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/cur-time.i }
{ cmp/r-pril.i   }
{ gbl/getcntxt.i def }

define variable     s1               as      character             no-undo.
define variable     s2               as      character             no-undo.
define variable     s3               as      character             no-undo.
define variable     Isp_name   as      character             no-undo.

define variable     Line            as      character             no-undo.
define variable     upper          as      integer                 no-undo.

/* излишки */
define variable     UpSub_Price-Base  like    ub.gds-dtl.price-base  no-undo.
define variable     UpSub_Price-Rubl  like    ub.gds-dtl.price-rubl  no-undo.
define variable     UpSub_Qnty           like    ub.gds-dtl.doc-qnty     no-undo.
/* недостача */
define variable     DownSub_Price-Base  like    ub.gds-dtl.price-base  no-undo.
define variable     DownSub_Price-Rubl  like    ub.gds-dtl.price-rubl  no-undo.
define variable     DownSub_Qnty            like    ub.gds-dtl.doc-qnty     no-undo.
/* всего */
define variable     Sub_Price-Base  like    ub.gds-dtl.price-base  no-undo.
define variable     Sub_Price-Rubl   like    ub.gds-dtl.price-rubl  no-undo.
define variable     Sub_Qnty            like    ub.gds-dtl.doc-qnty     no-undo.

define variable     Gds_Name    like    ub.goods.gds-name  no-undo.
define variable     tprice-base     like    ub.gds-dtl.price-base  no-undo.
define variable     tprice-rubl     like    ub.gds-dtl.price-rubl  no-undo.

def buffer Our_Object for ub.clients.

define variable     tsum_base    as decimal     no-undo.
define variable     tsum_rubl    as decimal     no-undo.
define variable     tqnty_    as decimal    no-undo.

define variable sym1 as char init ":"   no-undo.
define variable sym2 as char init ":"   no-undo.

define variable g#report-num    as integer      no-undo.
define variable g#quest-print   as logical      no-undo.
define variable g#log           as logical      no-undo.
define variable v-base-code     as integer      no-undo.

DEFINE FRAME x1
        sym1 column-label ":!:" format "X(1)" space(0)
        ub.bar-code.b-code COLUMN-LABEL "Код     ! " format ">>>>>>>>>9"
        ub.goods.artic COLUMN-LABEL "Артикул! " format "X(16)"
        Gds_Name COLUMN-LABEL "Наименование! " format "X(33)"
        tprice-base COLUMN-LABEL "Цена за ед.!(Б.вал.) " format ">>>,>>>,>>9.99"
        ub.gds-dtl.doc-qnty COLUMN-LABEL "Количество  !по док-ту" format "->>>>>>9.<<<"
        ub.gds-dtl.fact-qnty COLUMN-LABEL "Количество   !фактически" format "->>>>>>>9.<<<"
        Sub_Qnty COLUMN-LABEL "Разница кол-во! " format "->>,>>>,>>9.<<"
        Sub_Price-Base COLUMN-LABEL "Разница сумма!(Б.вал.) " format "->>>,>>>,>>9.99" space(0)
        sym2 column-label ":!:" format "X(1)"
    HEADER
        cur-time-print() AT 5 format "X(35)"
        string( "Страница " + string( PAGE-NUMBER, ">>9") ) AT 110 format "X(13)" SKIP
        Line no-label format "X(136)" AT 1
    with width {&DOS_CW} down stream-io use-text .

DEFINE FRAME x1-rubl
        sym1 column-label ":!:" format "X(1)" space(0)
        ub.bar-code.b-code COLUMN-LABEL "Код! " format ">>>>>>>>>9"
        ub.goods.artic COLUMN-LABEL "Артикул! " format "X(16)"
        Gds_Name COLUMN-LABEL "Наименование! " format "X(33)"
        tprice-rubl COLUMN-LABEL "Цена за ед.!({&abbr_rub_allshift})" format ">>>,>>>,>>9.99"
        ub.gds-dtl.doc-qnty COLUMN-LABEL "Количество  !по док-ту" format "->>>>>>9.<<<"
        ub.gds-dtl.fact-qnty COLUMN-LABEL "Количество   !фактически" format "->>>>>>>9.<<<"
        Sub_Qnty COLUMN-LABEL "Разница кол-во! " format "->>,>>>,>>9.<<"
        Sub_Price-Rubl COLUMN-LABEL "Разница сумма!({&abbr_rub_allshift})" format "->>>,>>>,>>9.99" space(0)
        sym2 column-label ":!:" format "X(1)"
    HEADER
        cur-time-print() AT 5 format "X(35)"
        string( "Страница " + string( PAGE-NUMBER, ">>9") ) AT 110 format "X(13)" SKIP
        Line no-label format "X(136)" AT 1
    with width {&DOS_CW} down stream-io use-text .

DEFINE FRAME x2
    s1 no-label format "X(20)"
    s2 column-label "Дата" format "99/99/9999"
    tqnty_ column-label "Количество" format "->>>>,>>9.<<<"
    tsum_base  column-label "Сумма (Б.вал.)" format "->>,>>>,>>>,>>9.99"
    with /* centered */ width {&DOS_CW} down stream-io use-text .

DEFINE FRAME x2-rubl
    s1 no-label format "X(20)"
    s2 column-label "Дата" format "99/99/9999"
    tqnty_ column-label "Количество" format "->>>>,>>9.<<<"
    tsum_rubl  column-label "Сумма ({&abbr_rub_allshift})" format "->>>>>>,>>>,>>9.99"
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
FIND ub.trn-doc WHERE recid( ub.trn-doc ) = rec_id  NO-LOCK .
if NOT ub.trn-doc.print-rubl then
    message "Документ печатать в {&abbr_rublyah_allshift} ?"
            VIEW-AS ALERT-BOX QUESTION BUTTONS yes-no TITLE "" UPDATE PrintRubl.
else
    assign PrintRubl = yes .

Line = fill("-", 140).
FIND ub.clients WHERE ub.clients.obj-type = ub.trn-doc.cli-type and
                                   ub.clients.obj-code = ub.trn-doc.cli-code NO-LOCK .

FIND ub.pay-type WHERE ub.pay-type.obj-code = ub.trn-doc.pay-code NO-LOCK NO-ERROR.
s1 = if available ub.pay-type then ub.pay-type.obj-name else "" .

FIND Our_Object WHERE Our_Object .obj-type = ub.trn-doc.obj-type AND
                                          Our_Object .obj-code = ub.trn-doc.obj-code NO-LOCK .
run rep/get-psn.p ( input trn-doc.boss, output s2 ).
run rep/get-psn.p ( input trn-doc.wrkr, output s3 ).
run rep/get-psn.p ( input trn-doc.agnt, output Isp_name ) .

{ cmp/open-out.i }

PUT SKIP SPACE(35) "АКТ НЕСООТВЕТСТВИЯ по " format "X(22)".
CASE trn-doc.doc-type :
    WHEN {&income} then
        PUT "приходной накладной N " format "X(22)".
    WHEN {&expense} then
        do:
            if  trn-doc.internal then
                PUT "требованию N " format "X(13)".
            else
                PUT "расходной накладной N " format "X(22)".
        end.
    WHEN {&return} then
        PUT "возвратной накладной N " format "X(24)".
    WHEN {&inventory} then do:
      if trn-doc.ext-doc-type = {&TDEDT_Inv} then do:
        PUT "инвентаризационной описи N " format "X(30)".
      end.
      if trn-doc.ext-doc-type = {&TDEDT_Peresort} then do:
        PUT "пересортицы N " format "X(18)".
      end.
      if trn-doc.ext-doc-type = {&TDEDT_Corr_Acc_Price} then do:
        put "документа коррекции учетных цен N " format "X(34)".
      end.
      if trn-doc.ext-doc-type = {&TDEDT_Chg_Purch_Code} then do:
        put "документа смены типа приобретения N " format "x(36)".
      end.
    end.
END CASE.
PUT trn-doc.doc-code + "  от  " + string(day(trn-doc.doc-date)) + {&slash-char} +
        string(month(trn-doc.doc-date)) + {&slash-char} +
        string(year(trn-doc.doc-date)) format "X(100)" SKIP(1).
if can-do( {&income_return} , trn-doc.doc-type ) then
    PUT SPACE(10) "От кого : " clients.obj-name format "x(40)" SKIP
            SPACE(10) "Кому    : " Our_Object .obj-type format "x(4)"
            Our_Object .obj-name format "x(40)" SKIP(1).
else    /* "pac" */
    if can-do( {&inventory} , trn-doc.doc-type ) then
        PUT SPACE(10) "От кого : " Our_Object.obj-name format "x(40)" SKIP
                SPACE(10) "Кому    : " Our_Object.obj-name format "x(40)" SKIP(1).
    else
        PUT SPACE(10) "От кого : " Our_Object.obj-name format "x(40)" SKIP
                SPACE(10) "Кому    : " clients.obj-name format "x(40)" SKIP(1).

PUT SPACE(10) "Торговый представитель : " + s2 format "X(60)" space(5)
        "Кладовщик              : " + s3 format "X(60)" SKIP
        SPACE(10) "Исполнитель            : " + Isp_name format "X(60)" space(5)
        "Вид оплаты             : " + s1 format "X(60)" SKIP .
PUT SPACE(75)
        "Курс                   : " + string( trn-doc.base-rate / trn-doc.base-scale, ">>>,>>9.9999" )
        format "X(60)" SKIP(1) .

if can-do( "Учетные", PriceType ) then
    PUT SPACE(40) "Указаны  У Ч Е Т Н Ы Е  цены." format "X(60)" SKIP .
else
    PUT SPACE(40) "Указаны  П Р О Д А Ж Н Ы Е  цены." format "X(60)" SKIP .

/* doc-line.unit-cli - ед. измер-я поставщика ,
doc-line.cli-base-rate - коэфф-т пересчета в свои ед. измер-я */

if PrintRubl then FORM with frame x1-rubl .
else FORM with frame x1 .

FORM HEADER
        Line format "X(136)" AT 1 SKIP
        "Продолжение - на следующей странице" AT 30 SKIP
        with FRAME BottomFrame width {&A4_CW} PAGE-BOTTOM NO-LABELS NO-BOX .
VIEW FRAME BottomFrame .

{ gbl/working.i }
FOR EACH ub.doc-line where ub.doc-line.doc-code = ub.trn-doc.doc-code NO-LOCK ,
        EACH ub.goods WHERE ub.goods.prod-type = ub.doc-line.prod-type AND
                                      ub.goods.prod-code = ub.doc-line.prod-code AND
                                      ub.goods.artic = ub.doc-line.artic NO-LOCK ,
        EACH ub.gds-dtl where ub.gds-dtl.prod-type = ub.doc-line.prod-type
                            and ub.gds-dtl.prod-code = ub.doc-line.prod-code
                            and ub.gds-dtl.artic = ub.doc-line.artic
                            and ub.gds-dtl.doc-code = ub.doc-line.doc-code NO-LOCK
                            BREAK BY ub.doc-line.artic :
/*
Инв:    doc-line:                doc-qnty - СТАЛО                fact-qnty - разница
            gds-dtl :                doc-qnty - разница                fact-qnty - СТАЛО
*/
    assign
        tprice-base = ( if can-do( "Учетные", PriceType )     /* только для инв-ции */
                                then round(ub.doc-line.price-base, 2)    else round(ub.gds-dtl.price-base, 2) )
        tprice-rubl = ( if can-do( "Учетные", PriceType )     /* только для инв-ции */
                              then round(ub.doc-line.price-rubl, 2)   else round(ub.gds-dtl.price-rubl, 2) )
        .
    ACCUMULATE
                    doc-line.artic ( COUNT )

                    gds-dtl.fact-qnty ( TOTAL )
                    gds-dtl.doc-qnty ( TOTAL )
                    ( gds-dtl.fact-qnty - gds-dtl.doc-qnty ) ( TOTAL )

                    ( gds-dtl.fact-qnty - gds-dtl.doc-qnty ) * tprice-base ( TOTAL )
                    ( gds-dtl.fact-qnty - gds-dtl.doc-qnty ) * tprice-rubl ( TOTAL )

                    gds-dtl.doc-qnty * tprice-base ( TOTAL )
                    gds-dtl.fact-qnty * tprice-base ( TOTAL )
                    gds-dtl.doc-qnty * tprice-rubl ( TOTAL )
                    gds-dtl.fact-qnty * tprice-rubl ( TOTAL )

                    gds-dtl.doc-qnty * ( tprice-base - round(gds-dtl.discnt-base, 2) ) ( TOTAL )
                    gds-dtl.fact-qnty * ( tprice-base - round(gds-dtl.discnt-base, 2) ) ( TOTAL )
                    gds-dtl.doc-qnty * ( tprice-rubl - round(gds-dtl.discnt-rubl, 2) ) ( TOTAL )
                    gds-dtl.fact-qnty * ( tprice-rubl - round(gds-dtl.discnt-rubl, 2) ) ( TOTAL ) .

    if ( NOT trn-doc.doc-type = {&inventory} AND ( gds-dtl.doc-qnty <> gds-dtl.fact-qnty ) ) OR
       ( trn-doc.doc-type = {&inventory} AND
            gds-dtl.doc-qnty <> 0 AND gds-dtl.doc-qnty <> ? )    then
        do:
            assign
                upper = gds-dtl.prt-code
                Gds_Name = goods.gds-name
                Sub_Qnty = ( if trn-doc.doc-type = {&inventory}
                                      then gds-dtl.doc-qnty
                                      else ( gds-dtl.doc-qnty - gds-dtl.fact-qnty ) )
                .

            if trn-doc.doc-type = {&inventory}  then
                do:
                    assign
                        Sub_Price-Base = Sub_Qnty * tprice-base
                        Sub_Price-Rubl = Sub_Qnty * tprice-rubl .
                    if Sub_Qnty > 0 then
                        assign
                            UpSub_Qnty = Sub_Qnty
                            UpSub_Price-Base = Sub_Price-Base
                            UpSub_Price-Rubl = Sub_Price-Rubl
                            DownSub_Qnty = 0
                            DownSub_Price-Base = 0
                            DownSub_Price-Rubl = 0 .
                    else
                        assign
                            UpSub_Qnty = 0
                            UpSub_Price-Base = 0
                            UpSub_Price-Rubl = 0
                            DownSub_Qnty = Sub_Qnty
                            DownSub_Price-Base = Sub_Price-Base
                            DownSub_Price-Rubl = Sub_Price-Rubl .
                end.
            else
                do:
                    assign
                        Sub_Price-Base = ( if Discnt_Type = 1 /* скидку - показать ! */
                                                        then Sub_Qnty * ( tprice-base - round(gds-dtl.discnt-base, 2) )
                                                        else Sub_Qnty * tprice-base )
                        Sub_Price-Rubl = ( if Discnt_Type = 1 /* скидку - показать ! */
                                                       then Sub_Qnty * ( tprice-rubl - round(gds-dtl.discnt-rubl, 2) )
                                                       else Sub_Qnty * tprice-rubl ) .
                    if gds-dtl.doc-qnty > gds-dtl.fact-qnty then
                        assign
                            UpSub_Qnty = 0
                            UpSub_Price-Base = 0
                            UpSub_Price-Rubl = 0
                            DownSub_Qnty = Sub_Qnty
                            DownSub_Price-Base = Sub_Price-Base
                            DownSub_Price-Rubl = Sub_Price-Rubl .
                    else
                        assign
                            UpSub_Qnty = - Sub_Qnty
                            UpSub_Price-Base = - Sub_Price-Base
                            UpSub_Price-Rubl = - Sub_Price-Rubl
                            DownSub_Qnty = 0
                            DownSub_Price-Base = 0
                            DownSub_Price-Rubl = 0 .
                end.
            ACCUMULATE
                Sub_Qnty (TOTAL)
                Sub_Price-Base (TOTAL)
                Sub_Price-Rubl (TOTAL)
                UpSub_Qnty (TOTAL)
                UpSub_Price-Base (TOTAL)
                UpSub_Price-Rubl (TOTAL)
                DownSub_Qnty (TOTAL)
                DownSub_Price-Base (TOTAL)
                DownSub_Price-Rubl (TOTAL) .
            FIND ub.bar-code WHERE ub.bar-code.gds-code = ub.goods.gds-code AND
                                                  ub.bar-code.unit-cli = ub.goods.unit-base AND
                                                  ub.bar-code.node-code = ub.gds-dtl.prt-code AND
                                                  ub.bar-code.part-code = "" AND
                                                  ub.bar-code.in-code = "" NO-LOCK .
            REPEAT :
                FIND ub.gds-prt where ub.gds-prt.node-code = upper AND
                                                NOT ub.gds-prt.root NO-LOCK NO-ERROR .
                if not available ub.gds-prt then
                    leave.
                assign
                    Gds_Name = Gds_Name + {&slash-char} + ub.gds-prt.node-name
                    upper = ub.gds-prt.upper-code .
            END.
            if PrintRubl then
                do:
                    DISPLAY sym1 bar-code.b-code
                                    goods.artic
                                    Gds_Name
                                    ( if Discnt_Type = 1 /* скидку - показать ! */
                                      then ( tprice-rubl - round(gds-dtl.discnt-rubl, 2) )
                                      else tprice-rubl ) @ tprice-rubl
                                    ( if trn-doc.doc-type = {&inventory}
                                      then ( gds-dtl.fact-qnty - gds-dtl.doc-qnty )
                                      else gds-dtl.doc-qnty ) @ gds-dtl.doc-qnty
                                    gds-dtl.fact-qnty       when gds-dtl.fact-qnty  <> 0
                                    Sub_Qnty
                                    Sub_Price-Rubl
                                    sym2    with frame x1-rubl.
                    DOWN 1 with frame x1-rubl.
                end .
            else
                do:
                    DISPLAY sym1 bar-code.b-code
                                    goods.artic
                                    Gds_Name
                                    ( if Discnt_Type = 1 /* скидку - показать ! */
                                      then ( tprice-base - round(gds-dtl.discnt-base, 2) )
                                      else tprice-base ) @ tprice-base
                                    ( if trn-doc.doc-type = {&inventory}
                                      then ( gds-dtl.fact-qnty - gds-dtl.doc-qnty )
                                      else gds-dtl.doc-qnty ) @ gds-dtl.doc-qnty
                                    gds-dtl.fact-qnty       when gds-dtl.fact-qnty  <> 0
                                    Sub_Qnty
                                    Sub_Price-Base
                                    sym2    with frame x1.
                    DOWN 1 with frame x1 .
                end .
        end .

    if last( doc-line.artic ) then
        do:
            PUT Line format "X(136)" SKIP.
            if PrintRubl then
                do:
                    DISPLAY "ИТОГО" @ Gds_Name
                                    ACCUM TOTAL Sub_Qnty @ Sub_Qnty
                                    ACCUM TOTAL Sub_Price-Rubl @ Sub_Price-Rubl
                                    with frame x1-rubl.
                    UNDERLINE Gds_Name Sub_Qnty Sub_Price-Rubl with frame x1-rubl.
                    DOWN 2 with frame x1-rubl.
                end .
            else
                do:
                    DISPLAY "ИТОГО" @ Gds_Name
                                    ACCUM TOTAL Sub_Qnty @ Sub_Qnty
                                    ACCUM TOTAL Sub_Price-Base @ Sub_Price-Base
                                    with frame x1 .
                    UNDERLINE Gds_Name Sub_Qnty Sub_Price-Base with frame x1 .
                    DOWN 2 with frame x1 .
                end .
        end.
END.        /*FOR  EACH doc-line ...*/

{ gbl/stopwork.i }
if PrintRubl then
            /*
                Инв:    doc-line:                doc-qnty - СТАЛО                fact-qnty - разница
                            gds-dtl :                doc-qnty - разница                fact-qnty - СТАЛО
            */
    REPEAT with FRAME x2-rubl:
        DISPLAY  "По документу" @ s1
            ub.trn-doc.doc-date @ s2
            ( if ub.trn-doc.doc-type = {&inventory}
                  then ( ACCUM TOTAL ( ub.gds-dtl.fact-qnty - ub.gds-dtl.doc-qnty ) )
                  else ( ACCUM TOTAL ub.gds-dtl.doc-qnty ) ) @ tqnty_
            ( if ub.trn-doc.doc-type = {&inventory} then
                  ACCUM TOTAL ( ub.gds-dtl.fact-qnty - ub.gds-dtl.doc-qnty ) * tprice-rubl
              else
                  if Discnt_Type = 1 /* скидку - показать ! */
                      then ACCUM TOTAL ub.gds-dtl.doc-qnty * ( tprice-rubl - round(ub.gds-dtl.discnt-rubl, 2) )
                      else ACCUM TOTAL ub.gds-dtl.doc-qnty * tprice-rubl ) @ tsum_rubl .

        down 2.
        DISPLAY "Фактически" @ s1
            ub.trn-doc.fact-date @ s2
            ( ACCUM TOTAL ub.gds-dtl.fact-qnty ) @ tqnty_
            ( if ub.trn-doc.doc-type = {&inventory} then
                  ACCUM TOTAL ub.gds-dtl.fact-qnty * tprice-rubl
              else
                  if Discnt_Type = 1 /* скидку - показать ! */
                      then ACCUM TOTAL ub.gds-dtl.fact-qnty * ( tprice-rubl - round(ub.gds-dtl.discnt-rubl, 2) )
                      else ACCUM TOTAL ub.gds-dtl.fact-qnty * tprice-rubl ) @ tsum_rubl .
        down 2.
        DISPLAY "Разница" @ s1
                " " @ s2
                ACCUM TOTAL Sub_Qnty @ tqnty_
                ACCUM TOTAL Sub_Price-Rubl @ tsum_rubl .
        down 2.
        DISPLAY  "   в т.ч. недостача" @ s1
                " " @ s2
                ACCUM TOTAL DownSub_Qnty @ tqnty_
                ACCUM TOTAL DownSub_Price-Rubl @ tsum_rubl .
        down 2.
        DISPLAY "          излишки " @ s1
                " " @ s2
                ACCUM TOTAL UpSub_Qnty @ tqnty_
                ACCUM TOTAL UpSub_Price-Rubl @ tsum_rubl .
        down 3.
        LEAVE.
    END .
else
    REPEAT with FRAME x2:
        DISPLAY  "По документу" @ s1
            ub.trn-doc.doc-date @ s2
            ( if ub.trn-doc.doc-type = {&inventory}
                  then ( ACCUM TOTAL ( ub.gds-dtl.fact-qnty - ub.gds-dtl.doc-qnty ) )
                  else ( ACCUM TOTAL ub.gds-dtl.doc-qnty ) ) @ tqnty_
            ( if ub.trn-doc.doc-type = {&inventory} then
                  ACCUM TOTAL ( ub.gds-dtl.fact-qnty - ub.gds-dtl.doc-qnty ) * tprice-base
              else
                  if Discnt_Type = 1 /* скидку - показать ! */
                      then ACCUM TOTAL ub.gds-dtl.doc-qnty * ( tprice-base - round(ub.gds-dtl.discnt-base, 2) )
                      else ACCUM TOTAL ub.gds-dtl.doc-qnty * tprice-base ) @ tsum_base .
            .

        down 2.
        DISPLAY "Фактически" @ s1
            ub.trn-doc.fact-date @ s2
            ( ACCUM TOTAL ub.gds-dtl.fact-qnty ) @ tqnty_
            ( if ub.trn-doc.doc-type = {&inventory} then
                  ACCUM TOTAL ub.gds-dtl.fact-qnty * tprice-base
              else
                  if Discnt_Type = 1 /* скидку - показать ! */
                      then ACCUM TOTAL ub.gds-dtl.fact-qnty * ( tprice-base - round(ub.gds-dtl.discnt-base, 2) )
                      else ACCUM TOTAL ub.gds-dtl.fact-qnty * tprice-base ) @ tsum_base .
        .

        down 2.
        DISPLAY "Разница" @ s1
                " " @ s2
                ACCUM TOTAL Sub_Qnty @ tqnty_
                ACCUM TOTAL Sub_Price-Base @ tsum_base
                .

        down 2.
        DISPLAY "   в т.ч. недостача" @ s1
                " " @ s2
                ACCUM TOTAL DownSub_Qnty @ tqnty_
                ACCUM TOTAL DownSub_Price-Base @ tsum_base
                .

        down 2.
        DISPLAY "          излишки " @ s1
                " " @ s2
                ACCUM TOTAL UpSub_Qnty @ tqnty_
                ACCUM TOTAL UpSub_Price-Base @ tsum_base
                .

        down 3.
        LEAVE.
    END .

HIDE FRAME BottomFrame .

if NOT PrintRubl then /* оплата - в базовой валюте */
    run rep/wp.p ( input p-mainmenu-handle, input abs( ACCUM TOTAL Sub_Price-Base ), output s1, output s2 ) .
else
    run rep/wp-rub.p ( input abs( ACCUM TOTAL Sub_Price-Rubl ), output s1, output s2 ) .

PUT SPACE(5) "Разница составила     :  " + CAPS(s1) format "X(128)" SKIP(1).

if v-base-code <> 0 and NOT PrintRubl then /* оплата - в базовой валюте */
        do:
            run rep/wp-rub.p ( input abs( ACCUM TOTAL Sub_Price-Rubl ), output s1, output s2 ) .
            PUT SPACE(5)
                "( {&abbr_rublevy_firstshift} эквивалент :  " + trim( CAPS(s1) ) + " )" format "X(128)" SKIP(1).
        end.

output CLOSE.

    define variable Log-Res as log no-undo .
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
    if Log-Res then do:
        { rep/q-print.i 0 }
    end.
    else do:
        { rep/q-print.i 4 }
    end.