block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-akt.p $
$Archive: rep/r-akt.p $

Печать акта и протокола переоценки

Автор: Демин Алексей Сергеевич
Дата создания: 09/09/05
Author: Alexey Demin
Creation date: 09/09/05

Input:

Output:

*/

define input parameter parparentproc     as handle           no-undo.
define input parameter rec_id            as recid            no-undo.
define input parameter p-doc-type        as character        no-undo.    /* akt - акт, prik - приказ,                    */
define input parameter p-price-celection as integer          no-undo.
define input parameter p-print-null-qnty as logical          no-undo.
define input parameter p-sort-by-group   as logical          no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-akt.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-akt.p $":U .
define variable vss-description as character no-undo init "Печать акта и протокола переоценки".
{ cmp/vssrevis.i    }
{ cmp/str-glbl.i    }
{ cmp/library.i     }
{ gbl/cur-time.i    }
{ cmp/r-pril.i new  }
{ cmp/croslist.i    }
{ str/hvrdtax.i     }
{ gbl/tax-name.i    }
{ gbl/dtm.i         }
{ str/writelog.i def "'r-akt.log'" }
{ rep/r-akt.i def   }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }

do
on error undo, return error
:

def buffer old-list for price-list.
def buffer buf_clients for clients.

def shared var sort-gr      as logical no-undo.

def var v-old-sum           as decimal no-undo.
def var v-new-sum           as decimal no-undo.
def var v-del-sum           as decimal no-undo.
def var v-up-fact           as decimal no-undo.

def var propis              as char    no-undo.
def var abbr                as char    no-undo.
def var v-single-line       as char    no-undo.
def var v-b-code            as char    no-undo.

def var v-line-counter      as int     no-undo.
def var v-good-line-counter as int     no-undo.

def var sym1  as char init ":"   no-undo.
def var sym2  as char init ":"   no-undo.
def var sym3  as char init ":"   no-undo.
def var sym4  as char init ":"   no-undo.
def var sym5  as char init ":"   no-undo.
def var sym6  as char init ":"   no-undo.
def var sym7  as char init ":"   no-undo.
def var sym8  as char init ":"   no-undo.
def var sym9  as char init ":"   no-undo.
def var sym10 as char init ":"   no-undo.


def var Log-Res1                as logical          no-undo.
def var v-print-cost-price      as logical          no-undo.

def var v-shift-down            as logical init yes no-undo.
def var v-print-group           as logical init yes no-undo.


def var v-price-doc-doc-num          like price-doc.doc-num     no-undo.
def var v-price-doc-doc-date         like price-doc.doc-date    no-undo.


def var v-main-price-sale            like price-list.price-sale  no-undo.

define variable g#report-num    as integer      no-undo.
define variable g#quest-print   as logical      no-undo.
define variable g#log           as logical      no-undo.

define variable v-rb-is-base        as logical      no-undo.

def stream AktStr .

define frame Prik
        sym1                        column-label ":!:"    format "X(1)"
        v-good-line-counter         column-label "N!п/п"  format ">>>9"
        sym2                        column-label ":!:"    format "X(1)"
        v-b-code                     column-label "Код! "  format "X({&BarCode_Length})"
        sym3                        column-label ":!:"    format "X(1)"
        price-list.artic            column-label "Артикул! " format "X(16)"
        sym4                        column-label ":!:"    format "X(1)"
        goods.gds-name              column-label "Название товара! " format "X(33)"
        sym5                        column-label ":!:"    format "X(1)"
        price-list.doc-qnty         column-label "Количество  ! "
                                                          format "->>>>>>>9.<<"
        v-price-list-price-sale_old column-label "Старая прод.!цена"
                                                          format "->>>,>>>,>>9.99"
        price-list.price-sale       column-label "Новая прод.!цена"
                                                          format "->>>,>>>,>>9.99"
        v-up-fact                   column-label "Процент!разницы"
                                                          format "->>>>>>>9.9%"
        sym7                        column-label ":!:"    format "X(1)"
    header
        cur-time-print() at 5 format "X(35)"
        string( "Приказ на переоценку " ) at 47 format "X(25)" v-price-doc-doc-num format "X(10)" " от " v-price-doc-doc-date format "99/99/9999"
        string( "Страница " + string( PAGE-NUMBER( AktStr ), ">>9" ) ) at 120 format "X(13)" skip
        v-single-line format "X({&A4_CW0})" at 1
    with width {&A4_CW} down stream-io use-text .

define frame Prik-Cost
        sym1 column-label ":!:" format "X(1)"
        v-b-code column-label "Код! " format "X({&BarCode_Length})"
        price-list.artic column-label "Артикул! " format "X(16)"
        sym4 column-label ":!:" format "X(1)"
        goods.gds-name column-label "Название товара! " format "X(42)"
        sym5 column-label ":!:" format "X(1)"
        price-list.doc-qnty column-label "Количество  ! " format "->>>>>>>9.<<"
        v-gds-obj-last-price column-label "Последняя учет.!цена"
            format "->>>,>>>,>>9.99"
        price-list.price-sale column-label "Новая прод.!цена"
            format "->>>,>>>,>>9.99"
        v-up-fact
        column-label "Процент!разницы" format "->>>>>>>9.9%"
        sym7 column-label ":!:" format "X(1)"
    header
        cur-time-print() at 5 format "X(35)"
        string( "Приказ на переоценку " ) at 47 format "X(25)" v-price-doc-doc-num format "X(10)" " от " v-price-doc-doc-date format "99/99/9999"
        string( "Страница " + string( PAGE-NUMBER( AktStr ), ">>9" ) ) at 120 format "X(13)" skip
        v-single-line format "X({&A4_CW0})" at 1
    with width {&A4_CW} down stream-io use-text .

define frame Akt
        sym1 column-label ":!:" format "X(1)"
        v-b-code column-label "Код! " format "X({&BarCode_Length})"
        price-list.artic column-label "Артикул! " format "X(16)"
        goods.gds-name column-label "Название товара! " format "X(21)"
        price-list.doc-qnty column-label "Количество! " format "->>>>>9.<<"
        v-price-list-price-sale_old column-label "Старая прод.!цена" format "->>>>>>>9.99"
        v-old-sum column-label "Старая сумма!прод. цен"
            format "->>>>>>>>>>>9.99"
        price-list.price-sale column-label "Новая прод.!цена"
            format "->>>>>>>9.99"
        v-new-sum column-label "Новая сумма!прод. цен"
            format "->>>>>>>>>>9.99"
        v-up-fact
        column-label "Процент!разницы" format "->>>>>>>9.9%"
        sym7 column-label ":!:" format "X(1)"
    header
        cur-time-print() at 5 format "X(35)"
        string( "Акт переоценки " ) at 50 format "X(20)" v-price-doc-doc-num format "X(10)" " от " v-price-doc-doc-date format "99/99/9999"
        string( "Страница " + string( PAGE-NUMBER( AktStr ), ">>9" ) ) at 120 format "X(13)" skip
        v-single-line format "X({&A4_CW0})" at 1
    with width {&A4_CW} down stream-io use-text .

define frame Akt-Cost
        sym1 column-label ":!:" format "X(1)"
        v-b-code column-label "Код! " format "x({&BarCode_Length})"
        price-list.artic column-label "Артикул! " format "X(16)"
        goods.gds-name column-label "Название товара! " format "X(22)"
        price-list.doc-qnty column-label "Количество! " format "->>>>>9.<<"
        v-gds-obj-last-price column-label "Последняя уч.!цена"
            format "->>>>>>>>9.99"
        v-old-sum column-label "Сумма учет.!цен"
            format "->>>>>>>>>9.99"
        price-list.price-sale column-label "Новая прод.!цена"
            format "->>>>>>>>9.99"
        v-new-sum column-label "Новая сумма!пр. цен"
            format "->>>>>>>>>9.99"
        v-up-fact
        column-label "Процент!разницы" format "->>>>>>>9.9%"
        sym7 column-label ":!:" format "X(1)"
    header
        cur-time-print() at 5 format "X(35)"
        string( "Акт переоценки " ) at 50 format "X(20)" v-price-doc-doc-num format "X(10)" " от " v-price-doc-doc-date format "99/99/9999"
        string( "Страница " + string( PAGE-NUMBER( AktStr ), ">>9" ) ) at 120 format "X(13)" skip
        v-single-line format "X({&A4_CW0})" at 1
    with width {&A4_CW} down stream-io use-text .


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

find first price-doc no-lock
      where recid(price-doc) = rec_id .
if not available price-doc
then do:
    bell.
    message 'Порушена табличка "price-doc"(r-akt.p).'.
    return error.
end.
assign
    v-price-doc-doc-num  = price-doc.doc-num
    v-price-doc-doc-date = price-doc.doc-date
.

find    clients no-lock
  where clients.obj-code = price-doc.obj-code
    and clients.obj-type = price-doc.obj-type
.
if not available clients then
do:
    bell.
    message 'Порушена табличка "clients" (r-akt.p).'.
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
  Log-Res1
}

if ( price-doc.status_ = {&act-overvalue} )
  or Log-Res1
then do:
    if  p-price-celection = 2
    then do:
        assign v-print-cost-price = TRUE .
    end.
    else do:
        assign v-print-cost-price = FALSE .
    end.
end.

find    trn-doc no-lock
  where trn-doc.doc-code = price-doc.doc-num
no-error.

assign
    v-single-line = fill("-", {&A4_CW0})
.

{ cmp/open-out.i stream AktStr}

find    buf_clients no-lock
  where buf_clients.obj-type = {&cmp}
    and buf_clients.obj-code = price-doc.host-code
.

put stream AktStr
  space(50) buf_clients.obj-name format "x(70)"
  skip(2)
.

os-delete log-file-name.
run writelog in this-procedure (log-file-name, 0, "&Line").

if price-doc.status_ = {&act-overvalue}
then do:
    put stream AktStr
      space(25) string( "А К Т  переоценки  по  остаткам  " +
      ( if available trn-doc then string( "документу N " + trn-doc.doc-code + "  по  " )
                              else " " ) + clients.obj-name )
                format "x(90)"
      skip(1)
    .
    run writelog in this-procedure (log-file-name, 1, "Печать акта № " + string(price-doc.doc-num)
                                            + " по док-ту № " + "  от  " + string(price-doc.doc-date, "99.99.9999")
                                            + "  по  " + clients.obj-name
                      ).
end.
else do:
    put stream AktStr
      space(20) string( "П Р И К А З   о  переоценке  товаров  " +
      ( if available trn-doc then string( "по документу N " + trn-doc.doc-code )
                              else " " ) + "  в  " + clients.obj-name )
                format "X(110)"
      skip(1)
    .
    run writelog in this-procedure (log-file-name, 1, "Печать приказа № " + string(price-doc.doc-num)
                                            + " по док-ту № " + "  от  " + string(price-doc.doc-date, "99.99.9999")
                                            + "  в  " + clients.obj-name
                      ).
end.

put stream AktStr
  "Номер " price-doc.doc-num
  "  от  " price-doc.doc-date format "99.99.9999"
  skip(1)
.

form header
            v-single-line format "X({&A4_CW0})" at 1 skip
            "Продолжение - на следующей странице" at 30 skip
            with frame Bottomframe width {&A4_CW} page-bottom no-labels no-box .
view stream aktstr frame bottomframe .


/*======================== Шапка сформирована ==========================*/

/*---S-------  Строки для закрытого документа --------------*/
if price-doc.status_ = {&act-overvalue}
then do:
    run writelog in this-procedure (log-file-name, 1, "Документ закрыт до факта").

    if v-print-cost-price = yes
    then do:
        form with frame Akt-Cost .
    end.
    else do:
        form with frame Akt .
    end.

    if p-sort-by-group = yes       /*Кому сортировку по группам?*/
    then do:
        run writelog in this-procedure (log-file-name, 1, "Включена сортировка по группам").

        for each price-list no-lock
           where price-list.doc-num = price-doc.doc-num
          , each goods no-lock
           where goods.artic     = price-list.artic
             and goods.prod-type = price-list.prod-type
             and goods.prod-code = price-list.prod-code
        break by goods.grp-name by goods.artic descending
        :
            assign
                v-print-group = (if first-of (goods.grp-name) then yes else no)
            .
            { rep/r-akt.i calc}
            if v-code-is-main = yes
            then do:
                run writelog in this-procedure (log-file-name, 2, "Основной код. Собираем количества и суммы").
                accumulate ( ( price-list.price-sale - v-price-list-price-sale_old ) * price-list.doc-qnty ) (total)
                                        ( price-list.doc-qnty ) (total)
                                        ( price-list.doc-qnty * v-price-list-price-sale_old ) (total)
                                        ( price-list.doc-qnty * price-list.price-sale ) (total)
                                        ( price-list.doc-qnty * v-gds-obj-last-price ) (total) .

                run print-line-fact in this-procedure.

                if     last-of (goods.grp-name) /*Если конец группы, но эта группа не последняя,*/
                and not last (goods.grp-name) /*то выводим линию*/
                then do:
                    put stream aktstr
                        v-single-line format "X({&A4_CW0})" at 1
                    .
                end.
            end.                /* if v-code-is-main */
        end.                  /* for each price-list where ... */
    end.            /*if sort-gr = yes */
    else do:
        run writelog in this-procedure (log-file-name, 1, "Сортировка по группам выключена").
        for each price-list no-lock
           where price-list.doc-num = price-doc.doc-num
          , each goods no-lock
           where goods.artic     = price-list.artic
             and goods.prod-type = price-list.prod-type
             and goods.prod-code = price-list.prod-code
        break by goods.artic descending
        :
            { rep/r-akt.i calc}
            if v-code-is-main = yes
            then do:
                    run writelog in this-procedure (log-file-name, 2, "Основной код. Собираем количества и суммы").
                    accumulate ( ( price-list.price-sale - v-price-list-price-sale_old ) * price-list.doc-qnty ) (total)
                                            ( price-list.doc-qnty ) (total)
                                            ( price-list.doc-qnty * v-price-list-price-sale_old ) (total)
                                            ( price-list.doc-qnty * price-list.price-sale ) (total)
                                            ( price-list.doc-qnty * v-gds-obj-last-price ) (total) .

                    run print-line-fact in this-procedure.
            end.                /* if v-code-is-main */
        end.                  /* for each price-list where ... */
    end.

    /*---S------- Выводим Итого для таблицы ---------------*/
    put stream aktstr v-single-line format "X({&A4_CW0})" skip.
    if v-print-cost-price
    then do:
        display stream aktstr
            "Итого" format "X(8)" @ goods.gds-name
            accum total ( price-list.doc-qnty )                @ price-list.doc-qnty
            accum total ( price-list.doc-qnty * v-gds-obj-last-price )   @ v-old-sum
            accum total ( price-list.doc-qnty * price-list.price-sale )  @ v-new-sum
            ( 100 * (
            ( accum total ( price-list.doc-qnty * price-list.price-sale ) )
            / ( accum total ( price-list.doc-qnty * v-gds-obj-last-price ) )
            ) - 100 )
            when round(
            accum total ( price-list.doc-qnty * v-gds-obj-last-price ), 2
                      ) <> 0
                                                                          @ v-up-fact
        with frame Akt-Cost .

        underline stream AktStr
          price-list.doc-qnty
          v-old-sum
          v-new-sum
          v-up-fact
        with frame Akt-Cost .
    end.
    else do:
        display stream AktStr
          "Итого" format "X(8)" @ goods.gds-name
          accum total ( price-list.doc-qnty ) @ price-list.doc-qnty
          accum total ( price-list.doc-qnty * v-price-list-price-sale_old ) @ v-old-sum
          accum total ( price-list.doc-qnty * price-list.price-sale ) @ v-new-sum
          ( 100 * (
          ( accum total ( price-list.doc-qnty * price-list.price-sale ) )
          / ( accum total ( price-list.doc-qnty * v-price-list-price-sale_old ) )
          ) - 100 )
          when round(
            accum total ( price-list.doc-qnty * v-price-list-price-sale_old ), 2
                    ) <> 0
                                                                      @ v-up-fact
          with frame Akt
        .
          underline stream AktStr price-list.doc-qnty v-old-sum v-new-sum
          v-up-fact with frame Akt
        .
    end.

    /*---E------- Выводим Итого для таблицы ---------------*/
    hide stream AktStr frame Bottomframe .

    if not v-print-cost-price
    then do:
        if v-rb-is-base = yes
        then do:
            run rep/wp.p (
                  input parparentproc
                , input absolute( accum total ( ( price-list.price-sale - v-price-list-price-sale_old) * price-list.doc-qnty) )
                , output propis
                , output abbr
            ) .
        end.        /* if v-rb-is-base = yes */
        else do:
            run rep/wp-rub.p (
                  input absolute( accum total ( ( price-list.price-sale - v-price-list-price-sale_old) * price-list.doc-qnty) )
                , output propis
                , output abbr
            ) .
        end.        /* NOT ( if v-rb-is-base = yes ) */
            if line-counter( AktStr ) + 9 > page-size( AktStr ) then
                page stream AktStr .
            put stream AktStr skip
                    space(10) "Cумма переоценки: " format "X(18)"
                    ( accum total ( ( price-list.price-sale - v-price-list-price-sale_old) * price-list.doc-qnty) ) format "->>>>>>>>9.99"
                    space(1)
                    ( if v-rb-is-base = yes then "баз.вал" else "{&abbr_rub}" )         format "X(3)"
                    " (" format "X(2)"
                    .
            if ( accum total ( ( price-list.price-sale - v-price-list-price-sale_old) * price-list.doc-qnty) ) < 0 then
                put stream AktStr "Минус " format "X(6)".
            put stream AktStr
                    ( if trim( propis ) begins abbr then string( "0 " + propis + ")" ) else string( propis + ")" ) )
                        format "X(95)"
                    .
        end.
    put stream AktStr skip(2)
                space(10)
                    "Председатель комиссии : _____________________________"
                    "Члены комиссии : _____________________________"  at 80
                skip .
end.
/*---E-------  Строки для закрытого документа --------------*/
/*---S-------  Строки для не закрытого документа -----------*/
else do:
    run writelog in this-procedure (log-file-name, 1, "Документ не закрыт до акта").
    if v-print-cost-price = yes
    then do:
        form with frame Prik-Cost .
    end.
    else do:
        form with frame Prik .
    end.

    if p-sort-by-group = yes       /*Кому сортировку по группам?*/
    then do:
        for each price-list no-lock
          where price-list.doc-num = price-doc.doc-num
              , each goods no-lock
              where goods.artic     = price-list.artic
                and goods.prod-type = price-list.prod-type
                and goods.prod-code = price-list.prod-code
            break by goods.grp-name by goods.artic descending by goods.gds-code descending
        :
            { rep/r-akt.i calc }
            if v-code-is-main
            then do:
                run print-line-no-fact in this-procedure.
            end.
        end.                  /* for each price-list where ... */
    end.
    else do:
        for each price-list no-lock
          where price-list.doc-num = price-doc.doc-num
              , each goods no-lock
              where goods.artic     = price-list.artic
                and goods.prod-type = price-list.prod-type
                and goods.prod-code = price-list.prod-code
            break by goods.artic descending by goods.gds-code descending
        :
            { rep/r-akt.i calc }
            if v-code-is-main
            then do:
                run print-line-no-fact in this-procedure.
            end.
        end.                  /* for each price-list where ... */
    end.

    hide stream AktStr frame Bottomframe .

    if line-counter( AktStr ) + 6 > page-size( AktStr ) then
        page stream AktStr .
    put stream AktStr v-single-line format "X({&A4_CW0})" skip(2)
            space(10) "Всего  " v-good-line-counter format ">>>>9"  /* accum COUNT bar-code.b-code*/
                " наименований." format "X(15)" skip(2)
            space(10) "Директор :  " format "X(60)"
                "Главный бухгалтер :  " format "X(70)" skip .
end.
/*---E-------  Строки для не закрытого документа -----------*/

output stream AktStr close.

{ gbl/stopwork.i }

{ rep/q-print.i 4}
/* { d o c - p r n . i } */

end.

/*===================================================================*/
procedure print-line-fact :
do
on error undo, return error
:
  run writelog in this-procedure (log-file-name, 1, "Вызов программы печати строки АКТА").
  if not can-find( first gds-prt where gds-prt.upper-code = v-gds-prt-node-code )
  then do:                                                                              /* Т.е. пустая шкала */
    run writelog in this-procedure (log-file-name, 2, "Пустая шкала").
    if ( price-list.doc-qnty <> 0 ) or ( p-print-null-qnty = yes )
    then do:
        run writelog in this-procedure (log-file-name, 3, "Количество по документу > 0 ( = "
                                                               + string(price-list.doc-qnty)
                                                               + " ) или включена печать нулевого количества ( "
                                                               + string( p-print-null-qnty ) + " )"
                                            ).
        if v-print-cost-price
        then do:
            run writelog in this-procedure (log-file-name, 4, "Включена печать по учетным ценам").
            if p-sort-by-group = yes       /*Кому сортировку по группам?*/
            then do:
                { rep/r-akt.i group cost}
            end.
            display stream AktStr
                sym1 trim( string( bar-code.b-code ) )  @ v-b-code
                price-list.artic
                v-gds-prt-node-name                     @ goods.gds-name
                price-list.doc-qnty                     when price-list.doc-qnty <> ?
                price-list.price-sale
                ( price-list.doc-qnty * price-list.price-sale )         @ v-new-sum
                v-gds-obj-last-price
                ( price-list.doc-qnty * v-gds-obj-last-price )          @ v-old-sum
                ( price-list.price-sale - v-gds-obj-last-price ) / v-gds-obj-last-price * 100
                                                                        when v-gds-obj-last-price <> 0
                                                                        @ v-up-fact
                sym7 with frame Akt-Cost .
            down stream AktStr 1 with frame Akt-Cost .

            { rep/r-akt.i third-tax fact cost}

        end.
        else do:
            run writelog in this-procedure (log-file-name, 4, "Печать по учетным ценам выключена").
            if p-sort-by-group = yes       /*Кому сортировку по группам?*/
            then do:
                { rep/r-akt.i group}
            end.
            display stream AktStr
                sym1 trim (string ( bar-code.b-code ))                @ v-b-code
                price-list.artic
                v-gds-prt-node-name                     @ goods.gds-name
                price-list.doc-qnty                     when price-list.doc-qnty <> ?
                v-price-list-price-sale_old
                ( price-list.doc-qnty * v-price-list-price-sale_old )   @ v-old-sum
                price-list.price-sale
                ( price-list.doc-qnty * price-list.price-sale )         @ v-new-sum
                ( price-list.price-sale - v-price-list-price-sale_old ) / v-price-list-price-sale_old * 100
                                                                        when v-price-list-price-sale_old <> 0
                                                                        @ v-up-fact
                sym7 with frame Akt .
            down stream AktStr 1 with frame Akt .
            { rep/r-akt.i third-tax fact sale}
            end.
     end.
  end.
  else do:
    run writelog in this-procedure (log-file-name, 2, "Не пустая шкала").
    if ( price-list.doc-qnty <> 0 ) or ( p-print-null-qnty )
    then do:
        run writelog in this-procedure (log-file-name, 3, "Количество по документу > 0 ( = " + string(price-list.doc-qnty)
                                                                  + " ) или включена печать нулевого количества ( "
                                                                  + string( p-print-null-qnty ) + " )"
                                            ).
        if v-print-cost-price = yes
        then do:
            run writelog in this-procedure (log-file-name, 4, "Включена печать по учетным ценам").
            display stream AktStr
                sym1 trim( string( bar-code.b-code ) ) @ v-b-code
                price-list.artic
                v-gds-prt-node-name                     @ goods.gds-name
/*                          goods.gds-name*/
                price-list.doc-qnty                     when price-list.doc-qnty <> ?
                v-gds-obj-last-price
                ( price-list.doc-qnty * v-gds-obj-last-price )      @ v-old-sum
                price-list.price-sale
                ( price-list.doc-qnty * price-list.price-sale )     @ v-new-sum
                ( price-list.price-sale - v-gds-obj-last-price ) / v-gds-obj-last-price * 100
                                                                    when v-gds-obj-last-price <> 0
                                                                    @ v-up-fact
                sym7
                with frame Akt-Cost .
            down stream AktStr 1 with frame Akt-Cost .
            { rep/r-akt.i third-tax fact cost}
        end.
        else do:
            run writelog in this-procedure (log-file-name, 4, "Печать по учетным ценам выключена").
            display stream AktStr
                sym1 trim( string( bar-code.b-code ) ) @ v-b-code
                price-list.artic
                v-gds-prt-node-name                     @ goods.gds-name
/*                          goods.gds-name*/
                price-list.doc-qnty                     when price-list.doc-qnty <> ?
                v-price-list-price-sale_old
                ( price-list.doc-qnty * v-price-list-price-sale_old )   @ v-old-sum
                price-list.price-sale
                ( price-list.doc-qnty * price-list.price-sale )         @ v-new-sum
                ( price-list.price-sale - v-price-list-price-sale_old ) / v-price-list-price-sale_old * 100
                                                                        when v-price-list-price-sale_old <> 0
                                                                        @ v-up-fact
                sym7   with frame Akt .
            down stream AktStr 1 with frame Akt .
            { rep/r-akt.i third-tax fact sale}
        end.
    end.
  end.

end.
end procedure. /* print-line-fact */










/*=======================================================================*/
procedure print-line-no-fact :
do
on error undo, return error
:
    run writelog in this-procedure (log-file-name, 1, "Вызов программы печати строки НЕ АКТА").
    if not can-find( first gds-prt where gds-prt.upper-code = v-gds-prt-node-code)
    then do:                                          /* Пустая шкала */
        if v-print-cost-price
        then do:
            if p-sort-by-group = yes     /*Кому сортировку по группам?*/
            then do:
                { rep/r-akt.i group cost}
            end.
            assign
                v-line-counter = v-line-counter + 1
                v-good-line-counter = v-good-line-counter + 1
            .
            display stream AktStr
                sym1 trim (string ( bar-code.b-code )) @ v-b-code
                price-list.artic
                sym4
                v-gds-prt-node-name                    @ goods.gds-name
                sym5 price-list.doc-qnty               when price-list.doc-qnty <> ?
                v-gds-obj-last-price
                price-list.price-sale
                ( 100 * ( price-list.price-sale - v-gds-obj-last-price )
                / v-gds-obj-last-price )
                                                        @ v-up-fact
                sym7 with frame Prik-Cost .
            down stream AktStr 1 with frame Prik-Cost .
            { rep/r-akt.i third-tax no-fact cost}
        end.
        else do:
            if p-sort-by-group = yes       /*Кому сортировку по группам?*/
            then do:
                { rep/r-akt.i group}
            end.
            assign
                v-line-counter = v-line-counter + 1
                v-good-line-counter = v-good-line-counter + 1
            .
            display stream AktStr
                        sym1 v-good-line-counter
                        sym2 trim (string ( bar-code.b-code ))  @ v-b-code
                        sym3 price-list.artic
                        sym4 v-gds-prt-node-name                @ goods.gds-name
                        sym5 price-list.doc-qnty                when price-list.doc-qnty <> ?
                        v-price-list-price-sale_old
                        price-list.price-sale
                        ( price-list.price-sale - v-price-list-price-sale_old )  / v-price-list-price-sale_old * 100
                                                                when v-price-list-price-sale_old <> 0
                                                                @ v-up-fact
                        sym7    with frame Prik .
            down stream AktStr 1 with frame Prik .
            { rep/r-akt.i third-tax no-fact sale}
        end.
    end.
    else do:                                          /* Не пустая шкала */
        if v-print-cost-price
        then do:
            if p-sort-by-group = yes       /*Кому сортировку по группам?*/
            then do:
                { rep/r-akt.i group cost}
            end.
            assign
                v-line-counter = v-line-counter + 1
                v-good-line-counter = v-good-line-counter + 1
            .
            display stream AktStr
                sym1
                trim (string ( bar-code.b-code ))   @ v-b-code
                price-list.artic
                sym4
                v-gds-prt-node-name                 @ goods.gds-name
                sym5
                price-list.doc-qnty                 when price-list.doc-qnty <> ?
                v-gds-obj-last-price
                price-list.price-sale
                ( price-list.price-sale - v-gds-obj-last-price ) / v-gds-obj-last-price * 100
                                                    when v-gds-obj-last-price <> 0
                                                    @ v-up-fact
                sym7     with frame Prik-Cost .
            down stream AktStr 1 with frame Prik-Cost .
            { rep/r-akt.i third-tax no-fact cost}
        end.
        else do:
            if p-sort-by-group = yes       /*Кому сортировку по группам?*/
            then do:
                { rep/r-akt.i group}
            end.
            assign
                v-line-counter = v-line-counter + 1
                v-good-line-counter = v-good-line-counter + 1
            .
            display stream AktStr
                    sym1 v-good-line-counter
                    sym2 trim (string ( bar-code.b-code ))  @ v-b-code
                    sym3 price-list.artic
                    sym4 v-gds-prt-node-name                @ goods.gds-name
                    sym5 price-list.doc-qnty                when price-list.doc-qnty <> ?
                    /* sym6 */ v-price-list-price-sale_old
                        price-list.price-sale
                    ( price-list.price-sale - v-price-list-price-sale_old ) / v-price-list-price-sale_old * 100
                                                            when v-price-list-price-sale_old <> 0
                                                            @ v-up-fact
                    sym7           with frame Prik
            .
            down stream AktStr 1 with frame Prik .
            { rep/r-akt.i third-tax no-fact sale}
        end.
    end.
end.
end procedure. /* print-line-no-fact */
