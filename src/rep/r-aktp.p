block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-aktp.p $
$Archive: rep/r-aktp.p $

Протокол согласования отпускных цен

Автор: Демин Алексей Сергеевич
Дата создания: 09/09/05
Author: Alexey Demin
Creation date: 09/09/05

Input:

Output:

*/

define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter rec_id               as recid            no-undo.
define input parameter p-price-celection    as integer          no-undo.
define input parameter p-print-null-qnty    as logical          no-undo.
define input parameter p-sort-by-group      as logical          no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-aktp.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-aktp.p $":U .
define variable vss-description as character no-undo init "Протокол согласования отпускных цен".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/r-pril.i new  }
{ gbl/dtm.i         }
{ gbl/cur-time.i    }
{ str/writelog.i def "'r-akt.log'" }
{ rep/r-akt.i def   }
{ gbl/getcntxt.i def }

do
on error undo, return error
:

define variable v-single-line       as char    no-undo.

define variable v-line-counter      as integer no-undo.
define variable v-good-line-counter as integer no-undo.

define variable v-price-doc-doc-num          like price-doc.doc-num     no-undo.

define variable v-b-code            as char    no-undo.

define variable v-rb-is-base        as logical      no-undo.

define variable sym1  as char init ":"   no-undo.
define variable sym2  as char init ":"   no-undo.
define variable sym3  as char init ":"   no-undo.
define variable sym4  as char init ":"   no-undo.
define variable sym5  as char init ":"   no-undo.
define variable sym6  as char init ":"   no-undo.
define variable sym10 as char init ":"   no-undo.

define variable g#report-num    as integer      no-undo.
define variable g#quest-print   as logical      no-undo.
define variable g#log           as logical      no-undo.

def stream Prtcl .

define frame Protocol
        sym1 column-label ":!:" format "X(1)"
        v-good-line-counter column-label "N!п/п" format ">>>9"
        sym2 column-label ":!:" format "X(1)"
        v-b-code column-label "Код! " format "x({&BarCode_Length})"
        sym3 column-label ":!:" format "X(1)"
        price-list.artic column-label "Артикул! " format "X(20)"
        sym4 column-label ":!:" format "X(1)"
        goods.gds-name column-label "Название товара! " format "X(55)"
        sym5 column-label ":!:" format "X(1)"
        units.long-name column-label "Единица!измерения" format "X(10)"
        sym6 column-label ":!:" format "X(1)"
        price-list.price-sale column-label "Цена за единицу!"
            format ">>>,>>>,>>>,>>9.99"
        sym10 column-label ":!:" format "X(1)"
    header
        v-price-doc-doc-num at 70 format "X(10)"
        string( "Страница " + string( PAGE-NUMBER( Prtcl ), ">>9" ) ) at 120 format "X(13)" skip
        v-single-line format "X({&A4_CW0})" at 1
    with width {&A4_CW} down stream-io use-text .

    { gbl/working.i }
    { gbl/getcntxt.i get " " p-mainmenu-handle }
    run get-report-num in p-mainmenu-handle (
        output g#report-num
    ).
    run get-quest-print in p-mainmenu-handle (
        output g#quest-print
    ).
    { gbl/rbisbase.i
        v-rb-is-base
    }
    assign
        v-single-line = fill("-", {&A4_CW0})
        v-line-counter = 1
        v-good-line-counter = 1
    .

    find first price-doc no-lock
        where recid(price-doc) = rec_id .
    if not available price-doc
    then do:
        bell.
        message vss-workfile + '. Порушена табличка price-doc'.
        return error.
    end.
    assign
        v-price-doc-doc-num  = price-doc.doc-num
    .
    output stream Prtcl to value( string( session:temp-directory +
                                {&DF_Name} + string( g#report-num ) ) ) page-size {&CS_PS} .
    put stream Prtcl space(20)
                "П Р О Т О К О Л   СОГЛАСОВАНИЯ  СВОБОДНЫХ  ОТПУСКНЫХ  ЦЕН"
                format "X(100)" skip(1)
            space(40) string( caps( price-doc.status_ ) + "  N " + v-price-doc-doc-num )
                format "X(60)" skip(1)
    .

    if price-doc.status_ = {&act-overvalue}
    then do:
        put stream Prtcl
            space(100) "Цены введены с " format "X(20)"
            price-doc.doc-date format "99.99.9999"
            skip(1)
        .
    end.
    else do:
        put stream Prtcl
/*                space(50) "Цены будут введены с момента проведения документа переоценки"*/
            skip(1)
        .
    end.

    form header
        v-single-line format "X({&A4_CW0})" at 1 skip
        "Продолжение - на следующей странице" at 30 skip
            with frame Bttmframe width {&A4_CW} page-bottom no-labels no-box .
    view stream Prtcl frame Bttmframe .

    for each price-list no-lock
       where price-list.doc-num = price-doc.doc-num
      , each goods no-lock
       where goods.artic     = price-list.artic
         and goods.prod-type = price-list.prod-type
         and goods.prod-code = price-list.prod-code
    break by price-list.artic with frame Protocol
    :
        { rep/r-akt.i calc}
        if v-code-is-main
        then do:
          find first units no-lock
               where units.unit-name = goods.unit-base
          no-error.

          display stream Prtcl sym1 v-good-line-counter
                          sym2 trim (string ( bar-code.b-code ))        @ v-b-code
                          sym3 price-list.artic
                          sym4 /*goods.gds-name*/ v-gds-prt-node-name   @ goods.gds-name
                          sym5 units.long-name
                          sym6 price-list.price-sale
                          sym10
          .
          if not LAST( price-list.artic )
          then do:
            assign
                v-line-counter = v-line-counter  + 1
                v-good-line-counter = v-good-line-counter  + 1
            .
          end.
        end.
    end.                  /* for each price-list where ... */

    hide stream Prtcl frame Bttmframe .
    if line-counter( Prtcl ) + 13 > page-size( Prtcl ) then
        page stream Prtcl .
    put stream Prtcl v-single-line      format "X({&A4_CW0})" skip(1) space(5) "Всего "
                    v-good-line-counter format ">,>>>,>>9" space(2)
                    "наименований"      format "x(13)" skip(1)
    .

    define variable v-user-name as character no-undo .
    { gbl/usrfulnm.i
      v-cntxt-userid
      v-user-name
    }
    put stream Prtcl skip(1) space(10) "Подписи сторон" format "x(100)" skip(1)
                    space(10) "Генеральный директор        : " format "x(70)" skip(1)
                    space(10) "Планово-экономический отдел : " format "x(70)" skip(1)
                    space(10) "Управляющий  магазином      : " format "x(70)" skip(3)
                    space(20) string( "Исполнитель : " + v-user-name ) format "x(70)" skip
    .
    output stream Prtcl close.

    { gbl/stopwork.i }

    { rep/q-print.i 4}

end.