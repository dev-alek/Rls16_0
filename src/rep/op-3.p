block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: op-3.p $
$Archive: rep/op-3.p $

Требование в кладовую

Автор: Демин Алексей Сергеевич
Дата создания: 09/09/05
Author: Alexey Demin
Creation date: 09/09/05

Input:

Output:

*/
define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter p-fbr-pln-recid      as recid            no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: op-3.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/op-3.p $":U .
define variable vss-description as character no-undo init "Требование в кладовую".
{ cmp/vssrevis.i    }
{ cmp/str-glbl.i    }
{ cmp/library.i     }
{ gbl/cur-time.i    }
{ cmp/library.i     }
{ trg/partslib.i    }
{ str/fbrrest.i     }
{ rep/fbrrep.i      }
{ cmp/r-pril.i new  }

do
on error undo, return error return-value
:

&scoped-define r-fbr-form-width-not-rb 127

    define temp-table temp_fbr-objects no-undo
        field obj-type  as character
        field obj-code  as integer

        index pi is primary unique obj-type obj-code
    .
    define variable v-doc-code                  as character        no-undo.
    define variable v-doc-date                  as date             no-undo.
    define variable v-counter                   as integer          no-undo.
    define variable v-line-string               as character        no-undo.
    define variable v-base-code                 as integer          no-undo.
    define variable v-units-okei                as integer          no-undo.

    define variable v-sum-qnty                  as decimal          no-undo.
    define variable v-free-qnty                 as decimal        no-undo.
    define variable v-need-qnty                 as decimal        no-undo.


    define variable v-prim                      as character     no-undo.
    define variable v-artic                     as character     no-undo.
    define variable v-gds-name                  as character     no-undo.
    define variable v-unit-base                 as character     no-undo.
    define variable v-barcode                   as character     no-undo.
    define variable v-have-goods-for-inquiry    as logical        no-undo.
    define variable v-first-page                as logical        no-undo.
    define variable v-store-obj-type            as character      no-undo.
    define variable v-store-obj-code            as integer        no-undo.

    define variable sym1 as character init ":"   no-undo.
    define variable sym2 as character init ":"   no-undo.
    define variable sym3 as character init ":"   no-undo.
    define variable sym4 as character init ":"   no-undo.
    define variable sym5 as character init ":"   no-undo.
    define variable sym6 as character init ":"   no-undo.
    define variable sym7 as character init ":"   no-undo.
    define variable sym8 as character init ":"   no-undo.

    define variable g#report-num    as integer      no-undo.
    define variable g#quest-print   as logical      no-undo.
    define variable g#log           as logical      no-undo.

    define buffer buf_fbr-pln       for fbr-pln.
    define buffer buf_fbr-pln-line  for fbr-pln-line.
    define buffer buf_fbr-doc       for fbr-doc.
    define buffer buf_fbr-line      for fbr-line.
    define buffer buf_goods         for goods.
    define buffer buf_units         for units.
    define buffer buf_store_clients for clients.

    define stream Outstream.

    define frame fbr-not-in-rb
        sym1                    column-label "|!|!|!|!|!|"                                format "X(1)"           space(0)
        v-counter               column-label "!п/п  ! ! !------!1  !"                        format ">>9"            space(0)
        sym2                    column-label "|!|!|!|!|!|"                                format "X(1)"           space(0)
        v-gds-name              column-label "                   Продукты        и !-----------------------------------------!           Наименование!-----------------------------------------!              2" format "X(41)"          space(0)
        sym3                    column-label "!|!|!|!"                                 format "X(1)"           space(0)
        v-barcode               column-label "товары    !-----------!    Код!-----------!   3  "                 format "X(10)" space(0)
        sym4                    column-label "|!|!|!|!|!|"                                format "X(1)"           space(0)
        v-unit-base             column-label "   Единица!-------------!    Наиме-!   нование!-------------!      4"                   format "X(3)"           space(0)
        sym5                    column-label "!|!|!|!|"                                format "X(1)"           space(0)
        v-units-okei            column-label "измерения  !-------------!Код по  ! ОКЕИ   !-------------!5      "       format ">>>"          space(0)
        sym6                    column-label "|!|!|!|!|!|"                                format "X(1)"           space(0)
        v-sum-qnty              column-label " !Количество !--------------!6       "                   format ">>,>>9.999"     space(0)
        sym7                    column-label "|!|!|!|!|!|"                                format "X(1)"          space(0)
        v-prim                  column-label " !    Примечание!---------------------!        7"                   format "X(4)"          space(0)
        sym8                    column-label "|!|!|!|!|!|"                                format "X(1)"          space(0)

    HEADER
    skip v-line-string format  "X({&r-fbr-form-width-not-rb})" AT 1
    with width {&A4_CW0} down stream-io NO-BOX.


    run get-report-num in p-mainmenu-handle (
        output g#report-num
    ).
    run get-quest-print in p-mainmenu-handle (
        output g#quest-print
    ).
    find first buf_fbr-pln no-lock
         where recid( buf_fbr-pln ) = p-fbr-pln-recid
    no-error.
    if not available buf_fbr-pln
    then do:
        message
            "Не найден документ для печати."
        view-as alert-box error.
        undo, return error.
    end.
    assign
        v-line-string = fill( "-", {&r-fbr-form-width-not-rb} )
    .
    { cmp/open-out.i stream Outstream " " {&CS_PS} }

    { gbl/working.i }

    for each buf_fbr-pln-line no-lock
       where buf_fbr-pln-line.doc-code     = buf_fbr-pln.doc-code
    on error undo, return error
    :
        if buf_fbr-pln-line.recipe-code <> ""
        and buf_fbr-pln-line.recipe-code <> ?
        then do:
            if buf_fbr-pln-line.fbr-obj-type <> {&shop}
            then do:
                find first buf_goods no-lock
                     where buf_goods.gds-code = buf_fbr-pln-line.gds-code
                .
                message
                         "Для производства товара указан объект"
                    skip "недопустимого типа. Производство"
                    skip "может быть только на объекте типа магазин."
                    skip(1)
                    skip "Товар:" buf_goods.artic buf_goods.gds-name
                    skip "Объект:" buf_fbr-pln-line.fbr-obj-type buf_fbr-pln-line.fbr-obj-code
                    skip(1)
                    skip "Измените данные плана-меню."
                view-as alert-box error.
                undo, return error.
            end.
            find first temp_fbr-objects
                 where temp_fbr-objects.obj-type = buf_fbr-pln-line.fbr-obj-type
                   and temp_fbr-objects.obj-code = buf_fbr-pln-line.fbr-obj-code
            no-error.
            if not available temp_fbr-objects
            then do:
                create temp_fbr-objects.
                assign
                    temp_fbr-objects.obj-type = buf_fbr-pln-line.fbr-obj-type
                    temp_fbr-objects.obj-code = buf_fbr-pln-line.fbr-obj-code
                .
            end.
        end.        /* if buf_fbr-pln-line.recipe-code <> 0 */
    end.        /* for each buf_fbr-pln-line */
    assign
        v-first-page = yes
    .
    print-for-object:
    for each temp_fbr-objects
    on error undo, return error
    :
        for each temp_fbrrep-goods
        on error undo, return error
        :
            delete temp_fbrrep-goods.
        end.
        if v-first-page = no
        then do:
            page stream Outstream .
        end.
        else do:
            assign
                v-first-page = no
            .
        end.
        run fbrrest-get-catering-object in this-procedure (
              input temp_fbr-objects.obj-code
            , output v-store-obj-type
            , output v-store-obj-code
        ).
        find first buf_fbr-doc no-lock
             where buf_fbr-doc.out-code = buf_fbr-pln.doc-code
               and buf_fbr-doc.obj-type = temp_fbr-objects.obj-type
               and buf_fbr-doc.obj-code = temp_fbr-objects.obj-code
        .
        run fbrrep-fill-qnty-and-prices in this-procedure (
            input buf_fbr-doc.doc-code
        ).
        assign
            v-have-goods-for-inquiry = no
        .
        for each temp_fbrrep-goods
        on error undo, return error
        :
            if temp_fbrrep-goods.is-not-office = yes
            and temp_fbrrep-goods.is-waste     = no
            and temp_fbrrep-goods.write-off-qnty > temp_fbrrep-goods.income-qnty
            then do:
                run fbrrest-get-free-qnty in this-procedure (
                      input buf_fbr-doc.obj-type
                    , input buf_fbr-doc.obj-code
                    , input temp_fbrrep-goods.gds-code
                    , input yes
                    , output v-free-qnty
                ).
                assign
                    v-need-qnty = temp_fbrrep-goods.write-off-qnty - temp_fbrrep-goods.income-qnty - v-free-qnty
                .
                if v-need-qnty > 0
                then do:
                    assign
                        v-have-goods-for-inquiry = yes
                    .
                end.
            end.
        end.
        if v-have-goods-for-inquiry = no
        then do:
            undo print-for-object, next print-for-object.
        end.
        assign
            v-doc-code      = buf_fbr-doc.doc-code
            v-doc-date      = buf_fbr-doc.doc-date
        .
        find first clients no-lock
             where clients.obj-type = buf_fbr-doc.obj-type
               and clients.obj-code = buf_fbr-doc.obj-code
        .
        find first buf_store_clients no-lock
             where buf_store_clients.obj-type = v-store-obj-type
               and buf_store_clients.obj-code = v-store-obj-code
        .
        put stream Outstream
            "Унифицированная форма №ОП-3"
            skip
            "Утверждена постановлением Госкомстата" space (63) "_ _ _ _ _ _ _ _ _ _ _ _"
            skip
            "России от 25.12.98 № 132" space (75)  "|_ _ _ _ _ Код _ _ _ _ _|"
            skip
                                "Форма по ОКУД|_ _ _ _ _0330503_ _ _ _|" at 87
            skip
                                                            "|_ _ _ _ _ _ _ _ _ _ _ _|" at 100

            skip
            string(  '"' + trim(buf_store_clients.obj-name) + '"' ) format "X(40)"  at 35    "по ОКПО |_ _ _ _ _ _ _ _ _ _ _ _|" at 92
            skip
                "____________________________________"   at 29   "|_ _ _ _ _ _ _ _ _ _ _ _|" at 100
            skip
                "предприятие (организация)" at 31       "Вид деятельности по ОКДП|_ _ _ _ _ _ _ _ _ _ _ _|" at 76
            skip
            string( buf_store_clients.obj-type + " " + string( buf_store_clients.obj-code ) ) format "X(40)" at 10   "|_ _ _ _ _ _ _ _ _ _ _ _|" at 100
            skip
            "____________________________________"    "Вид операции|_ _ _ _ _ _ _ _ _ _ _ _|" at 88
            skip
            "подразделение"
            skip
            string(  string(clients.obj-name) ) format "X(40)"  at 10
            skip
                        "___________________________"
            skip
                "подразделение получатель "
            skip
            "_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _"   at 90
            skip
            "|           Номер |Дата             |" at 89
            skip
            "|_ _ _ _документа |составления _ _ _|"   at 89
            skip
                    "Требование в кладовую" at 50 space(18) "|_ _ _ _ _" (string(v-doc-code)) format "X(8)" at 99 "|_"   string( v-doc-date, "99/99/9999" ) format "x(10)"  at 110 "_ _ _|"
            skip(1)
            "Через кого___________________________________________________________" at 55
            skip
            "фамилия, имя, отчество" at 80
        .
        form with frame fbr-not-in-rb.

        for each temp_fbrrep-goods
        on error undo, return error
        :
            if temp_fbrrep-goods.is-not-office = yes
            and temp_fbrrep-goods.is-waste     = no
            and temp_fbrrep-goods.write-off-qnty > temp_fbrrep-goods.income-qnty
            then do:
                run fbrrest-get-free-qnty in this-procedure (
                      input buf_fbr-doc.obj-type
                    , input buf_fbr-doc.obj-code
                    , input temp_fbrrep-goods.gds-code
                    , input yes
                    , output v-free-qnty
                ).
                assign
                    v-need-qnty = temp_fbrrep-goods.write-off-qnty - temp_fbrrep-goods.income-qnty - v-free-qnty
                .
                if v-need-qnty > 0
                then do:
                    assign
                        v-counter = v-counter + 1
                    .
                    run print-line in this-procedure (
                          input v-counter
                        , input temp_fbrrep-goods.gds-code
                        , input v-need-qnty
                        , input v-prim
                    ).

                end.        /* if v-need-qnty > 0 */
            end.        /* if temp_fbrrep-goods.is-not-office = yes */
        end.        /* for each temp_fbrrep-goods */
        put stream outstream
            v-line-string format "X({&r-fbr-form-width-not-rb})"
            skip (2)
            "Затребовал заведующий производством:                ____________________                   //_________________"
            skip
            "подпись" at 60 "расшифровка подписи" at 95
            skip(1)
            "Отпуск разрешил:                                    ____________________ "
                    skip(1)
            "Руководитель организации:         _____________              _________                    //_________________ "
            skip
            "должность" at 36  "подпись" at 64     "расшифровка подписи"  at 95
            skip(1)
            .

        hide stream Outstream frame Bottomframe .
    end.        /* for each temp_fbr-objects */
    output stream Outstream close.

    { gbl/stopwork.i  }

    { rep/q-print.i 4 }

  end.

/*==========================================================================*/
procedure print-line :
do
on error undo, return error
:
define input parameter p-counter    as integer      no-undo.
define input parameter p-gds-code   as integer      no-undo.
define input parameter p-fact-qnty  as decimal      no-undo.
define input parameter p-prim       as character    no-undo.

define variable v-bar-code          as character        no-undo.

define buffer buf_doc-line  for doc-line.
define buffer buf_goods     for goods.

    find first buf_goods no-lock
         where buf_goods.gds-code = p-gds-code
    .
    { gbl/gdsbcode.i buf_goods.gds-code ? v-bar-code no-error }.

/*
find first buf_units no-lock
     where buf_units.unit-name = buf_goods.unit-base     no-error
.
*/
    display stream OutStream
    sym1 p-counter                                                  @ v-counter
    sym2 buf_goods.gds-name                                         @ v-gds-name
    sym3 string( v-bar-code )                                       @ v-barcode
    sym4 buf_goods.unit-base                                        @ v-unit-base
    sym5 /*string(buf_units.okei)                                     @ v-units-okei*/
    sym6 p-fact-qnty                                                @ v-sum-qnty
    sym7 p-prim                                                     @ v-prim
    sym8
    with frame fbr-not-in-rb.
    down stream OutStream 1 with frame fbr-not-in-rb.

    if line-counter( Outstream ) + 2 > page-size( Outstream )
    then do:
        page stream Outstream .
    end.

end.
end procedure. /* print-line */