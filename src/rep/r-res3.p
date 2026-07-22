block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-res3.p $
$Archive: rep/r-res3.p $

Нехватка продуктов

Автор: Демин Алексей Сергеевич
Дата создания: 09/21/07
Author: Alexey Demin
Creation date: 09/21/07

Input:

Output:

*/
define temp-table temp_fbr-objects no-undo
    field obj-type  as character
    field obj-code  as integer

    index pi is primary unique obj-type obj-code
.

define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter p-fbr-pln-recid      as recid            no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-res3.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-res3.p $":U .
define variable vss-description as character no-undo init "Нехватка продуктов".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/cur-time.i    }
{ cmp/library.i     }
{ trg/partslib.i    }
{ str/fbrrest.i     }
{ rep/fbrrep.i      }
{ cmp/r-pril.i new  }
{ gbl/getcntxt.i def }

&scoped-define r-fbr-form-width-not-rb 126

    define variable v-doc-code                  as character        no-undo.
    define variable v-doc-date                  as date             no-undo.
    define variable v-counter                   as integer          no-undo.
    define variable v-line-string               as character        no-undo.
    define variable v-base-code                 as integer          no-undo.
    define variable v-units-okei                as integer          no-undo.

    define variable v-sum-plan                   as decimal          no-undo.
    define variable v-sum-free                   as decimal        no-undo.
    define variable v-sum-fact                   as decimal        no-undo.
    define variable v-sum-need                   as decimal        no-undo.
    define variable v-free-qnty                  as decimal no-undo .
    define variable v-need-qnty                   as decimal no-undo .

    define variable v-artic                     as character     no-undo.
    define variable v-gds-name                  as character     no-undo.
    define variable v-unit-base                 as character     no-undo.
    define variable v-barcode                   as character     no-undo.
    define variable v-have-goods-for-inquiry    as logical        no-undo.
    define variable v-first-page                as logical        no-undo.
    define variable v-store-obj-type            as character      no-undo.
    define variable v-store-obj-code            as integer        no-undo.
    define variable v-store-is-same-as-kitchen  as logical      no-undo.

    define variable sym1 as character init ":"   no-undo.
    define variable sym2 as character init ":"   no-undo.
    define variable sym3 as character init ":"   no-undo.
    define variable sym4 as character init ":"   no-undo.
    define variable sym5 as character init ":"   no-undo.
    define variable sym6 as character init ":"   no-undo.
    define variable sym7 as character init ":"   no-undo.
    define variable sym8 as character init ":"   no-undo.
    define variable sym9 as character init ":"   no-undo.

    define variable g#report-num    as integer      no-undo.
    define variable g#quest-print   as logical      no-undo.
    define variable g#log           as logical      no-undo.
    define variable v-pln-mn-doc-code as character no-undo .
    define variable v-pln-mn-doc-date as date no-undo .
    define variable v-pln-mn-obj-name as character no-undo .
    define variable v-pln-mn-obj-type as character no-undo .
    define variable v-pln-mn-obj-code as integer no-undo .
    define variable v-kh-qnty as decimal no-undo .

    define buffer buf_fbr-pln       for fbr-pln.
    define buffer buf_fbr-pln-line  for fbr-pln-line.
    define buffer buf_fbr-doc       for fbr-doc.
    define buffer buf_fbr-line      for fbr-line.
    define buffer buf_goods         for goods.
    define buffer buf_units         for units.
    define buffer buf_store_clients for clients.
    define buffer buf_pln_clients   for clients.

    define stream Outstream.

    define frame fbr-not-in-rb
        sym1                    column-label "|!|!|!|!|!|"                                format "X(1)"           space(0)
        v-counter               column-label "!п/п  ! ! !------!1  !"                        format ">>9"            space(0)
        sym2                    column-label "|!|!|!|!|!|"                                format "X(1)"           space(0)
        v-gds-name              column-label "            Продукты        и !------------------------------------!           Наименование!-----------------------------------!              2" format "X(35)"          space(0)
        sym3                    column-label "!|!|!|!"                                 format "X(1)"           space(0)
        v-barcode               column-label "товары    !-----------!    Код!-----------!   3  "                 format "X(10)" space(0)
        sym4                    column-label "|!|!|!|!|!|"                                format "X(1)"           space(0)
        v-unit-base             column-label "Единица!----------!  Наиме-! нование!----------!   4"                   format "X(3)"           space(0)
        sym5                    column-label "!|!|!|!|"                                format "X(1)"           space(0)
        v-units-okei            column-label "измерения  !-------------!Код по  ! ОКЕИ   !-------------!5      "       format ">>>"          space(0)
        sym6                    column-label "|!|!|!|!|!|"                                format "X(1)"           space(0)
        v-sum-plan              column-label " !  Необходимо  ! !--------------!6       "                   format "->>>>9.999"     space(0)
        sym7                    column-label "|!|!|!|!|!|"                                format "X(1)"          space(0)
        v-sum-fact              column-label "  Свободно    !  ( кухня +   ! склад кухни) ! !--------------!7       "                   format "->>>>9.999"     space(0)
        sym8                    column-label "|!|!|!|!|!|"                                format "X(1)"          space(0)
        v-sum-need              column-label " !   Закупить   ! !--------------!8       "                   format "->>>>9.999"     space(0)
        sym9                    column-label "|!|!|!|!|!|"                                format "X(1)"          space(0)
    HEADER
    skip v-line-string format  "X({&r-fbr-form-width-not-rb})" AT 1
    with width {&A4_CW0} down stream-io NO-BOX.

do
on error undo, return error return-value
:
    { gbl/getcntxt.i get " " p-mainmenu-handle }
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


    assign
    v-pln-mn-doc-code = buf_fbr-pln.doc-code
    v-pln-mn-doc-date = buf_fbr-pln.doc-date
    v-pln-mn-obj-type = buf_fbr-pln.obj-type
    v-pln-mn-obj-code = buf_fbr-pln.obj-code
    .
    find first buf_pln_clients no-lock
         where buf_pln_clients.obj-type = buf_fbr-pln.obj-type
           and buf_pln_clients.obj-code = buf_fbr-pln.obj-code
    .
    assign
        v-pln-mn-obj-name = buf_pln_clients.obj-name
    .
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
        end.         /* if buf_fbr-pln-line.recipe-code <> 0 */
    end.             /* for each buf_fbr-pln-line */
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
        if buf_fbr-doc.obj-type = v-store-obj-type
        and buf_fbr-doc.obj-code = v-store-obj-code
        then do:
            assign
                v-store-is-same-as-kitchen = yes
            .
        end.
        else do:
            assign
                v-store-is-same-as-kitchen = no
            .
        end.

        run fbrrep-fill-qnty-and-prices in this-procedure (
            input buf_fbr-doc.doc-code
        ).
        assign
            v-have-goods-for-inquiry = no
        .
        check-have-lines:
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
                if v-store-is-same-as-kitchen = yes
                then do:
                    assign
                        v-kh-qnty = 0
                    .
                end.
                else do:
                    run fbrrest-get-free-qnty in this-procedure (
                          input v-store-obj-type
                        , input v-store-obj-code
                        , input temp_fbrrep-goods.gds-code
                        , input yes
                        , output v-kh-qnty
                    ).
                end.
                assign
                    v-need-qnty = temp_fbrrep-goods.write-off-qnty
                                - temp_fbrrep-goods.income-qnty
                                - v-free-qnty
                                - v-kh-qnty
                .
                if v-need-qnty > 0
                then do:
                    assign
                        v-have-goods-for-inquiry = yes
                    .
                    leave check-have-lines.
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
        find first buf_pln_clients no-lock
             where buf_pln_clients.obj-type = buf_fbr-doc.obj-type
               and buf_pln_clients.obj-code = buf_fbr-doc.obj-code
        .
        find first buf_store_clients no-lock
             where buf_store_clients.obj-type = v-store-obj-type
               and buf_store_clients.obj-code = v-store-obj-code
        .
        define variable v-host-code    as integer      no-undo.
        define variable v-host-name    as character    no-undo.
        { gbl/hostname.i
            v-cntxt-obj-type
            v-cntxt-obj-code
            v-host-code
            v-host-name
        }
        put stream Outstream
            string( v-host-name  ) format "X(40)"  at 35 skip
            string( v-pln-mn-obj-name  + " (" + v-pln-mn-obj-type + " " + string( v-pln-mn-obj-code ) + ")"  ) format "X(60)"  at 35
            skip  fill("_",60) format "X(60)"  at 35
            skip "предприятие (организация)" at 35
            skip  string(buf_store_clients.obj-name + " (" + buf_store_clients.obj-type + " " + string( buf_store_clients.obj-code ) + ")" ) format "X(60)"   "+------------------+----------+"                                         format "X(31)" at 90
            skip fill("_",60) format "X(60)"                                                                                                                  "|Номер плана-меню  |" + string(v-pln-mn-doc-code, "X(10)")         + "|" format "X(31)" at 90
            skip "подразделение"                                                                                                                              "|Дата составления  |"  + string( v-pln-mn-doc-date, "99/99/9999" ) + "|" format "X(31)" at 90
            skip  string(buf_pln_clients.obj-name + " (" + buf_pln_clients.obj-type + " " + string( buf_pln_clients.obj-code ) + ")" ) format "X(60)"                                 "|Номер документа   |" + string( v-doc-code, "X(10)")               + "|" format "X(31)" at 90
            skip  fill("_",60) format "X(60)"                                                                                                                 "|Дата документа    |"  + string( v-doc-date, "99/99/9999" )        + "|" format "X(31)" at 90
            skip "подразделение получатель "                                                                                                                  "+------------------+----------+"                                         format "X(31)" at 90
            skip " "
            skip  CAPS("Н е х в а т к а   п р о д у к т о в")                        format "X(60)" at 50 space(18)
            skip
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
                if v-store-is-same-as-kitchen = yes
                then do:
                    assign
                        v-kh-qnty = 0
                    .
                end.
                else do:
                    run fbrrest-get-free-qnty in this-procedure (
                          input v-store-obj-type
                        , input v-store-obj-code
                        , input temp_fbrrep-goods.gds-code
                        , input yes
                        , output v-kh-qnty
                    ).
                end.
                /*
                message temp_fbrrep-goods.gds-code skip
                buf_fbr-doc.obj-type
                buf_fbr-doc.obj-code skip
                v-free-qnty skip

                v-store-obj-type
                v-store-obj-code skip
                v-kh-qnty
                .

                */
                assign
                    v-need-qnty = temp_fbrrep-goods.write-off-qnty
                                - temp_fbrrep-goods.income-qnty
                                - v-free-qnty
                                - v-kh-qnty
                .
                assign
                    v-counter = v-counter + 1
                .
                run print-line in this-procedure (
                      input v-counter
                    , input temp_fbrrep-goods.gds-code
                    , input temp_fbrrep-goods.write-off-qnty - temp_fbrrep-goods.income-qnty
                    , input v-free-qnty + v-kh-qnty
                    , input v-need-qnty
                ).
            end.        /* if temp_fbrrep-goods.is-not-office = yes */
        end.        /* for each temp_fbrrep-goods */
        put stream outstream
            v-line-string format "X({&r-fbr-form-width-not-rb})"
            skip (2)
            "Затребовал заведующий производством:                ____________________                   /_________________ /"
            skip
            "подпись" at 60 "расшифровка подписи" at 95
            skip(1)
            "Отпуск разрешил:                                    ____________________ "
                    skip(1)
            "Руководитель организации:         _____________              _________                    /_________________/ "
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
define input parameter p-fact-plan  as decimal      no-undo.
define input parameter p-fact-fact  as decimal      no-undo.
define input parameter p-fact-need  as decimal      no-undo.

define variable v-bar-code          as character        no-undo.

define buffer buf_doc-line  for doc-line.
define buffer buf_goods     for goods.

    find first buf_goods no-lock
         where buf_goods.gds-code = p-gds-code
    .
    { gbl/gdsbcode.i buf_goods.gds-code ? v-bar-code no-error }.

    find first buf_units no-lock
         where buf_units.unit-name = buf_goods.unit-base
    no-error.
    assign
        v-sum-need   = p-fact-need
        v-units-okei = buf_units.okei
    .
    display stream OutStream
    sym1 p-counter                     @ v-counter
    sym2 buf_goods.gds-name            @ v-gds-name
    sym3 string( v-bar-code )          @ v-barcode
    sym4 buf_goods.unit-base           @ v-unit-base
    sym5 v-units-okei                  when integer(v-units-okei) > 0
    sym6 p-fact-plan                   @ v-sum-plan
    sym7 p-fact-fact                   @ v-sum-fact
    sym8 v-sum-need                    when round(v-sum-need,3) > 0
    sym9
    with frame fbr-not-in-rb.
    down stream OutStream 1 with frame fbr-not-in-rb.

    if line-counter( Outstream ) + 2 > page-size( Outstream )
    then do:
        page stream Outstream .
    end.

end.
end procedure. /* print-line */