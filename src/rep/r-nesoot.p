block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-nesoot.p $
$Archive: rep/r-nesoot.p $

Акт несоответствия.

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

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$date: 30.10.03 13:52 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-nesoot.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-nesoot.p $":U .
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

define shared variable CostPrice as logical no-undo .

    define temp-table temp_line-by-parts no-undo
        field gds-code          as integer
        field price-base        as decimal
        field price-rubl        as decimal
        field doc-qnty          as decimal
        field fact-qnty         as decimal
        field delta-qnty        as decimal
        field delta-sum-base    as decimal
        field delta-sum-rubl    as decimal

        index pi is primary unique
            gds-code
            price-base
            price-rubl
    .

    define variable s1              as character             no-undo.
    define variable s2              as character             no-undo.
    define variable s3              as character             no-undo.
    define variable Isp_name        as character             no-undo.

    define variable Line            as character             no-undo.
    define variable upper           as integer               no-undo.

    /* излишки */
    define variable UpSub_Price-Base    as decimal      no-undo.
    define variable UpSub_Price-Rubl    as decimal      no-undo.
    define variable UpSub_Qnty          as decimal      no-undo.
    /* недостача */
    define variable downSub_Price-Base  as decimal      no-undo.
    define variable downSub_Price-Rubl  as decimal      no-undo.
    define variable downSub_Qnty        as decimal      no-undo.
    /* всего */
    define variable Sub_Price-Base      as decimal      no-undo.
    define variable Sub_Price-Rubl      as decimal      no-undo.
    define variable Sub_Qnty            as decimal      no-undo.

    define variable v-gds-name            as character    no-undo.
    define variable tprice-base         as decimal      no-undo.
    define variable tprice-rubl         as decimal      no-undo.

    define variable tsum_base   as decimal     no-undo.
    define variable tsum_rubl   as decimal     no-undo.
    define variable tqnty_      as decimal     no-undo.

    define variable sym1 as char init ":"   no-undo.
    define variable sym2 as char init ":"   no-undo.

    define variable v-exists-ord-num            as logical        no-undo.
    define variable v-same-goods-in-parts       as logical      no-undo.
    define variable v-attr-type                 as character      no-undo.
    define variable v-attr-value                as character      no-undo.
    define variable v-ord-num                   as character      no-undo.
    define variable v-b-code                    as integer      no-undo.

    define variable v-tot-fact-qnty             as decimal      no-undo.
    define variable v-tot-doc-qnty              as decimal      no-undo.
    define variable v-tot-doc-qnty-base         as decimal      no-undo.
    define variable v-tot-doc-qnty-rubl         as decimal      no-undo.
    define variable v-tot-fact-qnty-base        as decimal      no-undo.
    define variable v-tot-fact-qnty-rubl        as decimal      no-undo.
    define variable v-tot-dsc-doc-qnty-base     as decimal      no-undo.
    define variable v-tot-dsc-doc-qnty-rubl     as decimal      no-undo.
    define variable v-tot-dsc-fact-qnty-base    as decimal      no-undo.
    define variable v-tot-dsc-fact-qnty-rubl    as decimal      no-undo.

    define variable v-tot-Sub_Qnty              as decimal      no-undo.
    define variable v-tot-Sub_Price-Base        as decimal      no-undo.
    define variable v-tot-Sub_Price-Rubl        as decimal      no-undo.
    define variable v-tot-UpSub_Qnty            as decimal      no-undo.
    define variable v-tot-UpSub_Price-Base      as decimal      no-undo.
    define variable v-tot-UpSub_Price-Rubl      as decimal      no-undo.
    define variable v-tot-downSub_Qnty          as decimal      no-undo.
    define variable v-tot-downSub_Price-Base    as decimal      no-undo.
    define variable v-tot-downSub_Price-Rubl    as decimal      no-undo.

    define variable v-sys-key                   as character    no-undo.
    define variable g#report-num    as integer      no-undo.
    define variable g#quest-print   as logical      no-undo.
    define variable g#log           as logical      no-undo.
    define variable v-base-code     as integer      no-undo.


    define buffer buf_our_clients           for ub.clients.
    define buffer buf_clients               for ub.clients.
    define buffer buf_trn-doc               for ub.trn-doc.
    define buffer buf_doc-line              for ub.doc-line.
    define buffer buf_gds-dtl               for ub.gds-dtl.
    define buffer buf_goods                 for ub.goods.
    define buffer buf_parts                 for ub.parts.
    define buffer buf_temp_line-by-parts    for temp_line-by-parts.

define frame x1
        sym1                column-label ":!:"                      format "X(1)" space(0)
        ub.bar-code.b-code     column-label "Код     ! "               format ">>>>>>>>>9"
        buf_goods.artic         column-label "Артикул! "                format "X(16)"
        v-gds-name            column-label "Наименование! "           format "X(33)"
        tprice-base         column-label "Цена за ед.!(Б.вал.) "    format ">>>,>>>,>>9.99"
        buf_gds-dtl.doc-qnty    column-label "Количество  !по док-ту"   format "->>>>>>9.<<<"
        buf_gds-dtl.fact-qnty   column-label "Количество   !фактически" format "->>>>>>>9.<<<"
        Sub_Qnty            column-label "Разница кол-во! "         format "->>,>>>,>>9.<<"
        Sub_Price-Base      column-label "Разница сумма!(Б.вал.) "  format "->>>,>>>,>>9.99" space(0)
        sym2                column-label ":!:"                      format "X(1)"
    header
        cur-time-print() at 5 format "X(35)"
        string( "Страница " + string( PAGE-NUMBER, ">>9") ) at 110 format "X(13)" skip
        Line no-label format "X(136)" at 1
    with width {&doS_CW} down stream-io use-text .

define frame x1-rubl
        sym1                column-label ":!:"                      format "X(1)" space(0)
        ub.bar-code.b-code     column-label "Код! "                    format ">>>>>>>>>9"
        buf_goods.artic         column-label "Артикул! "                format "X(16)"
        v-gds-name            column-label "Наименование! "           format "X(33)"
        tprice-rubl         column-label "Цена за ед.!({&abbr_rub_allshift})"        format ">>>,>>>,>>9.99"
        buf_gds-dtl.doc-qnty    column-label "Количество  !по док-ту"   format "->>>>>>9.<<<"
        buf_gds-dtl.fact-qnty   column-label "Количество   !фактически" format "->>>>>>>9.<<<"
        Sub_Qnty            column-label "Разница кол-во! "         format "->>,>>>,>>9.<<"
        Sub_Price-Rubl      column-label "Разница сумма!({&abbr_rub_allshift})"      format "->>>,>>>,>>9.99" space(0)
        sym2                column-label ":!:"                      format "X(1)"
    header
        cur-time-print() at 5 format "X(35)"
        string( "Страница " + string( PAGE-NUMBER, ">>9") ) at 110 format "X(13)" skip
        Line no-label format "X(136)" at 1
    with width {&doS_CW} down stream-io use-text .

    define frame x2
        s1          no-label                        format "X(20)"
        s2          column-label "Дата"             format "99/99/9999"
        tqnty_      column-label "Количество"       format "->>>>,>>9.<<<"
        tsum_base   column-label "Сумма (Б.вал.)"   format "->>,>>>,>>>,>>9.99"
    with /* centered */ width {&DOS_CW} down stream-io use-text .

    define frame x2-rubl
        s1          no-label                        format "X(20)"
        s2          column-label "Дата"             format "99/99/9999"
        tqnty_      column-label "Количество"       format "->>>>,>>9.<<<"
        tsum_rubl   column-label "Сумма ({&abbr_rub_allshift})"      format "->>>>>>,>>>,>>9.99"
    with width {&DOS_CW} down stream-io use-text .

do
for buf_our_clients
  , buf_clients
  , buf_trn-doc
  , buf_doc-line
  , buf_gds-dtl
  , buf_goods
  , buf_parts
  , buf_temp_line-by-parts
on error undo, return error
:
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
    { gbl/currsysk.i
      v-sys-key
      no-error
    }

    find first buf_trn-doc no-lock
         where recid( buf_trn-doc ) = rec_id
    .
    if not buf_trn-doc.print-rubl
    then do:
        message "Документ печатать в {&abbr_rublyah_allshift} ?"
        view-as ALERT-BOX QUESTIon BUTtonS yes-no TITLE "" UPdate PrintRubl.
    end.
    else do:
        assign PrintRubl = yes .
    end.

Line = fill("-", 140).
find first buf_clients no-lock
     where buf_clients.obj-type = buf_trn-doc.cli-type
       and buf_clients.obj-code = buf_trn-doc.cli-code
.
find first ub.pay-type no-lock
     where ub.pay-type.obj-code = buf_trn-doc.pay-code
no-error.
assign
    s1 = ( if available ub.pay-type then ub.pay-type.obj-name else "" )
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
case buf_trn-doc.doc-type :
    when {&income}
    then do:
        put
            "приходной накладной N " format "X(22)"
        .
    end.
    when {&expense}
    then do:
        if buf_trn-doc.internal
        then do:
            put
                "требованию N " format "X(13)"
            .
        end.
        else do:
            put
                "расходной накладной N " format "X(22)"
            .
        end.
    end.
    when {&return}
    then do:
        put
            "возвратной накладной N " format "X(24)"
        .
    end.
    when {&inventory}
    then do:
        case buf_trn-doc.ext-doc-type
        :
            when {&TDEDT_inv}
            then do:
                put
                    "инвентаризационной описи N " format "X(30)"
                .
            end.        /* when {&TDEDT_inv} */
            when {&TDEDT_Peresort}
            then do:
                put
                    "пересортицы N " format "X(30)"
                .
            end.        /* when {&TDEDT_Peresort} */
            when {&TDEDT_Corr_Acc_Price}
            then do:
                put
                    "документа коррекции учетных цен N " format "X(34)"
                .
            end.        /* when {&TDEDT_Corr_Acc_Price} */
            when {&TDEDT_Chg_Purch_Code}
            then do:
                put
                    "документа смены типа приобретения N " format "x(36)"
                .
            end.        /* when {&TDEDT_Chg_Purch_Code} */
        end case.       /* case buf_trn-doc.ext-doc-type */
    end.
end case.
put
    substitute( "&1 от &2/&3/&4"
                , buf_trn-doc.doc-code
                , day( buf_trn-doc.doc-date )
                , month( buf_trn-doc.doc-date )
                , year( buf_trn-doc.doc-date ) )
                                                    format "X(100)"
    skip(1)
.
if lookup( buf_trn-doc.doc-type, {&income_return} ) <> 0
then do:
  if v-sys-key begins "Repin" then do:
    define buffer b_host for ub.clients .
    find first b_host no-lock where b_host.obj-type = {&cmp} and b_host.obj-code = buf_trn-doc.host-code .
    put space(10) "Поставщик  : "  buf_clients.obj-name format "x(40)"  skip
        space(10) "Покупатель : "  b_host.obj-name format "x(40)"  skip
        space(10) "Получатель : "  buf_our_clients.obj-type format "x(4)" buf_our_clients.obj-name format "x(40)"  skip(1)
    .
  end.
  else do:
    put
        space(10)
        "От кого : "
        buf_clients.obj-name format "x(40)"
        skip
    .
    { str/tdat-xst.i
        buf_trn-doc.doc-code
        {&trdcattr-nids}
        v-exists-ord-num
    }
    if v-exists-ord-num = yes
    then do:
        { str/tdat-val.i
            buf_trn-doc.doc-code
            {&trdcattr-nids}
            v-attr-value
            v-attr-type
        }
        assign
            v-ord-num = v-attr-value
        .
        { str/tdat-val.i
            buf_trn-doc.doc-code
            {&trdcattr-dids}
            v-attr-value
            v-attr-type
        }
        assign
            v-ord-num = v-ord-num + " от " + v-attr-value
        .
        put space(10)
            "Заказ   : "
            v-ord-num  format "x(40)"
            skip
        .
    end.
    put space(10)
        "Кому    : " buf_our_clients.obj-type format "x(4)"
        buf_our_clients.obj-name format "x(40)"
        skip(1)
    .
  end.
end.
else do:        /* "pac" */
    if buf_trn-doc.doc-type = {&inventory}
    then do:
        put
                space(10) "От кого : "
                buf_our_clients.obj-name format "x(40)"
            skip
                space(10) "Кому    : "
                buf_our_clients.obj-name format "x(40)"
            skip(1)
        .
    end.
    else do:
        put
                space(10) "От кого : "
                buf_our_clients.obj-name format "x(40)"
            skip
                space(10) "Кому    : "
                buf_clients.obj-name format "x(40)"
            skip(1)
        .
    end.
end.
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
if CostPrice = yes
then do:
    put
        space(40) "Указаны учетные цены." format "X(60)"
        skip
    .
end.
else do:
    put
        space(40) "Указаны  цены  документа." format "X(60)"
        skip
    .
end.

/* buf_doc-line.unit-cli - ед. измер-я поставщика ,
buf_doc-line.cli-base-rate - коэфф-т пересчета в свои ед. измер-я */

if PrintRubl
then do:
    form with frame x1-rubl.
end.
else do:
    form with frame x1.
end.
form header
        Line format "X(136)" at 1
        skip "Продолжение - на следующей странице" at 30
        skip
with frame Bottomframe width {&A4_CW} page-bottom no-labels no-box .
view frame Bottomframe .

{ gbl/working.i }
for each buf_doc-line no-lock
   where buf_doc-line.doc-code = buf_trn-doc.doc-code
break by buf_doc-line.artic
:
    find first buf_goods no-lock
         where buf_goods.prod-type = buf_doc-line.prod-type
           and buf_goods.prod-code = buf_doc-line.prod-code
           and buf_goods.artic     = buf_doc-line.artic
    .
/*
Инв:    buf_doc-line:                doc-qnty - СТАЛО                fact-qnty - разница
        buf_gds-dtl :                doc-qnty - разница                fact-qnty - СТАЛО
*/
    if ( not buf_trn-doc.doc-type = {&inventory}
         and ( buf_doc-line.doc-qnty <> buf_doc-line.fact-qnty ) )
    or ( buf_trn-doc.doc-type = {&inventory}
         and buf_doc-line.doc-qnty <> 0
         and buf_doc-line.doc-qnty <> ?  )
    then do:
        if buf_trn-doc.doc-type = {&income}
        or CostPrice = yes
        then do:        /* Для приходных документов печать в ценах документа -  тоже по партиям */
            for each buf_temp_line-by-parts
            on error undo, return error
            :
                delete buf_temp_line-by-parts.
            end.        /* for each buf_temp_line-by-parts */
            for each tt-clcparts
            on error undo, return error
            :
                delete tt-clcparts.
            end.        /* for each tt-clcparts */
            for each buf_parts no-lock
               where buf_parts.out-code   = buf_trn-doc.doc-code
                 and buf_parts.obj-type   = buf_trn-doc.obj-type
                 and buf_parts.obj-code   = buf_trn-doc.obj-code
                 and buf_parts.prod-type  = buf_doc-line.prod-type
                 and buf_parts.prod-code  = buf_doc-line.prod-code
                 and buf_parts.artic      = buf_doc-line.artic
            on error undo, return error return-value
            :
                find first buf_temp_line-by-parts
                     where buf_temp_line-by-parts.gds-code   = buf_goods.gds-code
                       and buf_temp_line-by-parts.price-base = buf_parts.price-base
                       and buf_temp_line-by-parts.price-rubl = buf_parts.price-rubl
                no-error.
                if not available buf_temp_line-by-parts
                then do:
                    create buf_temp_line-by-parts.
                    assign
                        v-same-goods-in-parts                   = no
                        buf_temp_line-by-parts.gds-code         = buf_goods.gds-code
                        buf_temp_line-by-parts.price-base       = buf_parts.price-base
                        buf_temp_line-by-parts.price-rubl       = buf_parts.price-rubl
                        buf_temp_line-by-parts.doc-qnty         = 0
                        buf_temp_line-by-parts.fact-qnty        = 0
                        buf_temp_line-by-parts.delta-qnty       = 0
                        buf_temp_line-by-parts.delta-sum-base   = 0
                        buf_temp_line-by-parts.delta-sum-rubl   = 0
                    .
                end.
                else do:
                    assign
                        v-same-goods-in-parts                   = yes

                    .
                end.
                assign
                    buf_temp_line-by-parts.doc-qnty         = buf_temp_line-by-parts.doc-qnty       + buf_parts.qnty
                    buf_temp_line-by-parts.fact-qnty        = buf_temp_line-by-parts.fact-qnty      + buf_parts.fact-qnty
                    buf_temp_line-by-parts.delta-qnty       = buf_temp_line-by-parts.delta-qnty     + buf_parts.qnty - buf_parts.fact-qnty
                .
                create tt-clcparts.
                buffer-copy buf_parts to tt-clcparts.
                run clcprtsl_calc-parts in this-procedure (
                      input recid( tt-clcparts )
                    , input no
                    , input no
                    , input 0
                    , input 0
                    , input 0
                    , input 0
                    , input 0
                    , input 0
                    , input 0
                    , input "":U
                    , input 0
                    , input 0
                    , input 0
                    , input 0
                    , input 0
                    , input 0
                ).
                find first tt-allsum
                     where tt-allsum.sum-type = {&sum-general}
                .
                if tt-allsum.fact-qnty = 0
                then do:
                    { str/out-vatp.i doc-line buf_doc-line. buf_trn-doc. " " }
                    assign
                        buf_temp_line-by-parts.delta-sum-base   = buf_temp_line-by-parts.delta-sum-base + ( buf_parts.qnty - buf_parts.fact-qnty ) * price-base-with-tax-sale
                        buf_temp_line-by-parts.delta-sum-rubl   = buf_temp_line-by-parts.delta-sum-rubl + ( buf_parts.qnty - buf_parts.fact-qnty ) * price-rubl-with-tax-sale
                        v-tot-doc-qnty-base                     = v-tot-doc-qnty-base                   + buf_parts.qnty * price-base-with-tax-sale
                        v-tot-doc-qnty-rubl                     = v-tot-doc-qnty-rubl                   + buf_parts.qnty * price-rubl-with-tax-sale
                    .
                end.
                else do:
                    assign
                        buf_temp_line-by-parts.delta-sum-base   = buf_temp_line-by-parts.delta-sum-base + ( buf_parts.qnty - buf_parts.fact-qnty ) * ( ( if tt-allsum.fact-qnty = 0 then 0 else tt-allsum.sum-dsc-base-acc / tt-allsum.fact-qnty ) )
                        buf_temp_line-by-parts.delta-sum-rubl   = buf_temp_line-by-parts.delta-sum-rubl + ( buf_parts.qnty - buf_parts.fact-qnty ) * ( ( if tt-allsum.fact-qnty = 0 then 0 else tt-allsum.sum-dsc-rubl-acc / tt-allsum.fact-qnty ) )
                        v-tot-doc-qnty-base                     = v-tot-doc-qnty-base                   + buf_parts.qnty * ( tt-allsum.sum-dsc-base-acc / tt-allsum.fact-qnty )
                        v-tot-doc-qnty-rubl                     = v-tot-doc-qnty-rubl                   + buf_parts.qnty * ( tt-allsum.sum-dsc-rubl-acc / tt-allsum.fact-qnty )
                    .
                end.
                if v-same-goods-in-parts = no
                then do:
                    assign
                        v-tot-Sub_Qnty           = v-tot-Sub_Qnty           + buf_temp_line-by-parts.delta-qnty
                        v-tot-Sub_Price-Base     = v-tot-Sub_Price-Base     + buf_temp_line-by-parts.delta-sum-base
                        v-tot-Sub_Price-Rubl     = v-tot-Sub_Price-Rubl     + buf_temp_line-by-parts.delta-sum-rubl
                        v-tot-UpSub_Qnty         = v-tot-UpSub_Qnty         + ( if buf_temp_line-by-parts.delta-qnty < 0 then buf_temp_line-by-parts.delta-qnty else 0 )
                        v-tot-UpSub_Price-Base   = v-tot-UpSub_Price-Base   + ( if buf_temp_line-by-parts.delta-qnty < 0 then buf_temp_line-by-parts.delta-sum-base else 0 )
                        v-tot-UpSub_Price-Rubl   = v-tot-UpSub_Price-Rubl   + ( if buf_temp_line-by-parts.delta-qnty < 0 then buf_temp_line-by-parts.delta-sum-rubl else 0 )
                        v-tot-downSub_Qnty       = v-tot-downSub_Qnty       + ( if buf_temp_line-by-parts.delta-qnty > 0 then buf_temp_line-by-parts.delta-qnty else 0 )
                        v-tot-downSub_Price-Base = v-tot-downSub_Price-Base + ( if buf_temp_line-by-parts.delta-qnty > 0 then buf_temp_line-by-parts.delta-sum-base else 0 )
                        v-tot-downSub_Price-Rubl = v-tot-downSub_Price-Rubl + ( if buf_temp_line-by-parts.delta-qnty > 0 then buf_temp_line-by-parts.delta-sum-rubl else 0 )
                    .
                end.
                else do:
                    assign
                        v-tot-Sub_Qnty           = buf_temp_line-by-parts.delta-qnty
                        v-tot-Sub_Price-Base     = buf_temp_line-by-parts.delta-sum-base
                        v-tot-Sub_Price-Rubl     = buf_temp_line-by-parts.delta-sum-rubl
                        v-tot-UpSub_Qnty         = ( if buf_temp_line-by-parts.delta-qnty < 0 then buf_temp_line-by-parts.delta-qnty else 0 )
                        v-tot-UpSub_Price-Base   = ( if buf_temp_line-by-parts.delta-qnty < 0 then buf_temp_line-by-parts.delta-sum-base else 0 )
                        v-tot-UpSub_Price-Rubl   = ( if buf_temp_line-by-parts.delta-qnty < 0 then buf_temp_line-by-parts.delta-sum-rubl else 0 )
                        v-tot-downSub_Qnty       = ( if buf_temp_line-by-parts.delta-qnty > 0 then buf_temp_line-by-parts.delta-qnty else 0 )
                        v-tot-downSub_Price-Base = ( if buf_temp_line-by-parts.delta-qnty > 0 then buf_temp_line-by-parts.delta-sum-base else 0 )
                        v-tot-downSub_Price-Rubl = ( if buf_temp_line-by-parts.delta-qnty > 0 then buf_temp_line-by-parts.delta-sum-rubl else 0 )
                    .
                end.
                assign
                    v-tot-fact-qnty          = v-tot-fact-qnty          + buf_parts.fact-qnty
                    v-tot-doc-qnty           = v-tot-doc-qnty           + buf_parts.qnty
                    v-tot-fact-qnty-base     = v-tot-fact-qnty-base     + tt-allsum.sum-dsc-base-acc
                    v-tot-fact-qnty-rubl     = v-tot-fact-qnty-rubl     + tt-allsum.sum-dsc-rubl-acc
                    v-tot-dsc-doc-qnty-base  = 0
                    v-tot-dsc-doc-qnty-rubl  = 0
                    v-tot-dsc-fact-qnty-base = 0
                    v-tot-dsc-fact-qnty-rubl = 0
                .
            end.        /* for each buf_parts */
            for each buf_temp_line-by-parts
            on error undo, return error
            :
                { gbl/gdsbcode.i
                    buf_goods.gds-code
                    ?
                    v-b-code
                }
                if PrintRubl
                then do:
                    display
                        sym1
                        v-b-code                                                                    @ ub.bar-code.b-code
                        buf_goods.artic
                        buf_goods.gds-name                                                          @ v-gds-name
                        buf_temp_line-by-parts.delta-sum-rubl / buf_temp_line-by-parts.delta-qnty   @ tprice-rubl
                        buf_temp_line-by-parts.doc-qnty                                             @ buf_gds-dtl.doc-qnty
                        buf_temp_line-by-parts.fact-qnty                                            @ buf_gds-dtl.fact-qnty
                        buf_temp_line-by-parts.delta-qnty                                           @ Sub_Qnty
                        buf_temp_line-by-parts.delta-sum-rubl                                       @ Sub_Price-Rubl
                        sym2
                    with frame x1-rubl.
                    down 1 with frame x1-rubl.
                end.
                else do:
                    display
                        sym1
                        v-b-code                                                                    @ ub.bar-code.b-code
                        buf_goods.artic
                        buf_goods.gds-name                                                          @ v-gds-name
                        buf_temp_line-by-parts.delta-sum-base / buf_temp_line-by-parts.delta-qnty   @ tprice-base
                        buf_temp_line-by-parts.doc-qnty                                             @ buf_gds-dtl.doc-qnty
                        buf_temp_line-by-parts.fact-qnty                                            @ buf_gds-dtl.fact-qnty
                        buf_temp_line-by-parts.delta-qnty                                           @ Sub_Qnty
                        buf_temp_line-by-parts.delta-sum-base                                       @ Sub_Price-Base
                        sym2
                    with frame x1.
                    down 1 with frame x1.
                end.
            end.        /* for each buf_temp_line-by-parts */
        end.        /* if buf_trn-doc.doc-type = {&income} */
        else do:        /* печать в ценах документа не для приходной накладной */
            for each buf_gds-dtl no-lock
               where buf_gds-dtl.prod-type = buf_doc-line.prod-type
                 and buf_gds-dtl.prod-code = buf_doc-line.prod-code
                 and buf_gds-dtl.artic = buf_doc-line.artic
                 and buf_gds-dtl.doc-code = buf_doc-line.doc-code
            :
                assign
                    tprice-base = buf_gds-dtl.price-base
                    tprice-rubl = buf_gds-dtl.price-rubl
                .
                assign
                    v-tot-fact-qnty           = v-tot-fact-qnty           + buf_gds-dtl.fact-qnty
                    v-tot-doc-qnty            = v-tot-doc-qnty            + buf_gds-dtl.doc-qnty

                    v-tot-doc-qnty-base   = v-tot-doc-qnty-base   + ( buf_gds-dtl.doc-qnty  * tprice-base )
                    v-tot-doc-qnty-rubl   = v-tot-doc-qnty-rubl   + ( buf_gds-dtl.doc-qnty  * tprice-rubl )
                    v-tot-fact-qnty-base  = v-tot-fact-qnty-base  + ( buf_gds-dtl.fact-qnty * tprice-base )
                    v-tot-fact-qnty-rubl  = v-tot-fact-qnty-rubl  + ( buf_gds-dtl.fact-qnty * tprice-rubl )

                    v-tot-dsc-doc-qnty-base   = v-tot-dsc-doc-qnty-base   + ( buf_gds-dtl.doc-qnty  * buf_gds-dtl.discnt-base )
                    v-tot-dsc-doc-qnty-rubl   = v-tot-dsc-doc-qnty-rubl   + ( buf_gds-dtl.doc-qnty  * buf_gds-dtl.discnt-rubl )
                    v-tot-dsc-fact-qnty-base  = v-tot-dsc-fact-qnty-base  + ( buf_gds-dtl.fact-qnty * buf_gds-dtl.discnt-base )
                    v-tot-dsc-fact-qnty-rubl  = v-tot-dsc-fact-qnty-rubl  + ( buf_gds-dtl.fact-qnty * buf_gds-dtl.discnt-rubl )
                .
                assign
                    upper       = buf_gds-dtl.prt-code
                    v-gds-name    = buf_goods.gds-name
                    Sub_Qnty    = ( if buf_trn-doc.doc-type = {&inventory}
                                    then buf_gds-dtl.doc-qnty
                                    else ( buf_gds-dtl.doc-qnty - buf_gds-dtl.fact-qnty ) )
                .
                if buf_trn-doc.doc-type = {&inventory}
                then do:
                    assign
                        Sub_Price-Base = Sub_Qnty * tprice-base
                        Sub_Price-Rubl = Sub_Qnty * tprice-rubl
                    .
                    if Sub_Qnty > 0
                    then do:
                        assign
                            UpSub_Qnty          = Sub_Qnty
                            UpSub_Price-Base    = Sub_Price-Base
                            UpSub_Price-Rubl    = Sub_Price-Rubl
                            downSub_Qnty        = 0
                            downSub_Price-Base  = 0
                            downSub_Price-Rubl  = 0
                        .
                    end.
                    else do:
                        assign
                            UpSub_Qnty          = 0
                            UpSub_Price-Base    = 0
                            UpSub_Price-Rubl    = 0
                            downSub_Qnty        = Sub_Qnty
                            downSub_Price-Base  = Sub_Price-Base
                            downSub_Price-Rubl  = Sub_Price-Rubl
                        .
                    end.
                end.
                else do:
                    assign      /* скидку - показать ! */
                        Sub_Price-Base = ( if Discnt_Type = 1
                                        then Sub_Qnty * ( tprice-base - buf_gds-dtl.discnt-base )
                                        else Sub_Qnty * tprice-base )
                        Sub_Price-Rubl = ( if Discnt_Type = 1 /* скидку - показать ! */
                                        then Sub_Qnty * ( tprice-rubl - buf_gds-dtl.discnt-rubl )
                                        else Sub_Qnty * tprice-rubl )
                    .
                    if buf_gds-dtl.doc-qnty > buf_gds-dtl.fact-qnty
                    then do:
                        assign
                            UpSub_Qnty = 0
                            UpSub_Price-Base = 0
                            UpSub_Price-Rubl = 0
                            downSub_Qnty = Sub_Qnty
                            downSub_Price-Base = Sub_Price-Base
                            downSub_Price-Rubl = Sub_Price-Rubl
                        .
                    end.
                    else do:
                        assign
                            UpSub_Qnty = - Sub_Qnty
                            UpSub_Price-Base = - Sub_Price-Base
                            UpSub_Price-Rubl = - Sub_Price-Rubl
                            downSub_Qnty = 0
                            downSub_Price-Base = 0
                            downSub_Price-Rubl = 0
                        .
                    end.
                end.
                assign
                    v-tot-Sub_Qnty           = v-tot-Sub_Qnty           + Sub_Qnty
                    v-tot-Sub_Price-Base     = v-tot-Sub_Price-Base     + Sub_Price-Base
                    v-tot-Sub_Price-Rubl     = v-tot-Sub_Price-Rubl     + Sub_Price-Rubl
                    v-tot-UpSub_Qnty         = v-tot-UpSub_Qnty         + UpSub_Qnty
                    v-tot-UpSub_Price-Base   = v-tot-UpSub_Price-Base   + UpSub_Price-Base
                    v-tot-UpSub_Price-Rubl   = v-tot-UpSub_Price-Rubl   + UpSub_Price-Rubl
                    v-tot-downSub_Qnty       = v-tot-downSub_Qnty       + downSub_Qnty
                    v-tot-downSub_Price-Base = v-tot-downSub_Price-Base + downSub_Price-Base
                    v-tot-downSub_Price-Rubl = v-tot-downSub_Price-Rubl + downSub_Price-Rubl
                .
        /*        accumulate*/
        /*            Sub_Qnty            (total)*/
        /*            Sub_Price-Base      (total)*/
        /*            Sub_Price-Rubl      (total)*/
        /*            UpSub_Qnty          (total)*/
        /*            UpSub_Price-Base    (total)*/
        /*            UpSub_Price-Rubl    (total)*/
        /*            downSub_Qnty        (total)*/
        /*            downSub_Price-Base  (total)*/
        /*            downSub_Price-Rubl  (total)*/
        /*        .*/
                find first ub.bar-code no-lock
                     where ub.bar-code.gds-code = buf_goods.gds-code
                       and ub.bar-code.unit-cli = buf_goods.unit-base
                       and ub.bar-code.node-code = buf_gds-dtl.prt-code
                       and ub.bar-code.part-code = ""
                       and ub.bar-code.in-code = ""
                .
                repeat :
                    find first ub.gds-prt no-lock
                         where ub.gds-prt.node-code = upper
                           and not ub.gds-prt.root
                    no-error .
                    if not available ub.gds-prt
                    then do:
                        leave.
                    end.
                    assign
                        v-gds-name   = v-gds-name + {&slash-char} + ub.gds-prt.node-name
                        upper        = ub.gds-prt.upper-code
                    .
                end.
                if PrintRubl
                then do:
                    display
                        sym1
                        ub.bar-code.b-code
                        buf_goods.artic
                        v-gds-name
                        ( if Discnt_Type = 1 /* скидку - показать ! */
                        then ( tprice-rubl - buf_gds-dtl.discnt-rubl )
                        else tprice-rubl ) @ tprice-rubl
                        ( if buf_trn-doc.doc-type = {&inventory}
                        then ( buf_gds-dtl.fact-qnty - buf_gds-dtl.doc-qnty )
                        else buf_gds-dtl.doc-qnty ) @ buf_gds-dtl.doc-qnty
                        buf_gds-dtl.fact-qnty       when buf_gds-dtl.fact-qnty  <> 0
                        Sub_Qnty
                        Sub_Price-Rubl
                        sym2
                    with frame x1-rubl.
                    down 1 with frame x1-rubl.
                end .       /* if PrintRubl */
                else do:
                    display
                        sym1
                        ub.bar-code.b-code
                        buf_goods.artic
                        v-gds-name
                        ( if Discnt_Type = 1 /* скидку - показать ! */
                        then ( tprice-base - buf_gds-dtl.discnt-base )
                        else tprice-base ) @ tprice-base
                        ( if buf_trn-doc.doc-type = {&inventory}
                        then ( buf_gds-dtl.fact-qnty - buf_gds-dtl.doc-qnty )
                        else buf_gds-dtl.doc-qnty ) @ buf_gds-dtl.doc-qnty
                        buf_gds-dtl.fact-qnty       when buf_gds-dtl.fact-qnty  <> 0
                        Sub_Qnty
                        Sub_Price-Base
                        sym2
                    with frame x1.
                    down 1 with frame x1 .
                end .       /* if NOT( PrintRubl ) */
            end.        /* for each buf_gds-dtl no-lock */
        end.        /* NOT ( if buf_trn-doc.doc-type = {&income} ) */
    end.        /* Печать если есть расхождения по строке документа */
    if last( buf_doc-line.artic )
    then do:
        put
            Line format "X(136)"
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
    /*
        Инв:    buf_doc-line:                doc-qnty - СТАЛО                fact-qnty - разница
                buf_gds-dtl:                doc-qnty - разница              fact-qnty - СТАЛО
    */
    repeat
    with frame x2-rubl
    :
        display
            "По документу" @ s1
            buf_trn-doc.doc-date @ s2
            ( if buf_trn-doc.doc-type = {&inventory}
                  then ( v-tot-fact-qnty - v-tot-doc-qnty )
                  else ( v-tot-doc-qnty ) )                                 @ tqnty_
            ( if buf_trn-doc.doc-type = {&inventory}
            then ( v-tot-fact-qnty-rubl  - v-tot-doc-qnty-rubl )
            else ( if Discnt_Type = 1 /* скидку - показать ! */
                   then v-tot-doc-qnty-rubl - v-tot-dsc-doc-qnty-rubl
                   else v-tot-doc-qnty-rubl ) )                         @ tsum_rubl
        .
        down 2.
        display
            "Фактически" @ s1
            buf_trn-doc.fact-date                                                   @ s2
            v-tot-fact-qnty                                                 @ tqnty_
            ( if buf_trn-doc.doc-type = {&inventory}
            then v-tot-fact-qnty-rubl
            else ( if Discnt_Type = 1 /* скидку - показать ! */
                 then v-tot-fact-qnty-rubl - v-tot-dsc-fact-qnty-rubl
                 else v-tot-fact-qnty-rubl ) )                          @ tsum_rubl
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
            v-tot-UpSub_Qnty            @ tqnty_
            v-tot-UpSub_Price-Rubl      @ tsum_rubl
        .
        down 3.
        leave.
    end .
end.        /* if PrintRubl */
else do:
    repeat
    with frame x2
    :
        display  "По документу" @ s1
            buf_trn-doc.doc-date @ s2

            ( if buf_trn-doc.doc-type = {&inventory}
                  then ( v-tot-fact-qnty - v-tot-doc-qnty )
                  else ( v-tot-doc-qnty ) )                                 @ tqnty_
            ( if buf_trn-doc.doc-type = {&inventory}
            then ( v-tot-fact-qnty-base  - v-tot-doc-qnty-base )
            else ( if Discnt_Type = 1 /* скидку - показать ! */
                   then v-tot-doc-qnty-base - v-tot-dsc-doc-qnty-base
                   else v-tot-doc-qnty-base ) )                         @ tsum_base
        .
        down 2.
        display
            "Фактически" @ s1
            buf_trn-doc.fact-date @ s2


            v-tot-fact-qnty                                                 @ tqnty_
            ( if buf_trn-doc.doc-type = {&inventory}
            then v-tot-fact-qnty-base
            else ( if Discnt_Type = 1 /* скидку - показать ! */
                 then v-tot-fact-qnty-base - v-tot-dsc-fact-qnty-base
                 else v-tot-fact-qnty-base ) )                          @ tsum_base
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
            v-tot-UpSub_Qnty            @ tqnty_
            v-tot-UpSub_Price-Base      @ tsum_base
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
if v-sys-key = "WORLD"
then do:
    put
        skip  "" ( if buf_trn-doc.status_ = {&fact}
                 then buf_trn-doc.fact-date
                 else buf_trn-doc.doc-date  )  format "99/99/9999"
        skip "Директор магазина                ___________________________ (                                       )"
        skip "Старший продавец                 ___________________________ (                                       )"
        skip "Поставщик                        ___________________________ (                                       )"
        skip "Представитель отдела закупки     ___________________________ (                                       )"
    .
end.
if v-sys-key begins "Repin" then do:
    put
        skip    "Материально ответственное лицо от поставщика ____________________,__________________/_________________________/"
        skip(1) "Материально ответственное лицо от получателя ____________________,__________________/_________________________/"
    .
end.
if (v-sys-key begins lc("prods")) or (v-sys-key begins lc("spar")) then do:
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
end.
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
end.