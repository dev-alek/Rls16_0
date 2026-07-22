block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: rcs-day.p $
$Archive: rcs/rcs-day.p $

Выгрузка свёртки по объектам по датам для внешней системы

Автор: Гюнтнер Виктор Арнольдович
Дата создания: 09/09/05
Author: Victor Guntner
Creation date: 09/09/05

Input:

Output:

*/

define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter p-xml-file-name      as character        no-undo.
define input parameter p-date               as date             no-undo.     /* день экспорта */
define input parameter p-range              as integer          no-undo. /* Диапазон: 1 - глобально, 2 - по тек. фирме, 3 - список объектов */
define input parameter p-obj-list           as character        no-undo. /* Список объектов для p-range = 3 */
define input parameter hedt                 as handle           no-undo.
define input parameter hcnt                 as handle           no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: rcs-day.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rcs/rcs-day.p $":U .
define variable vss-description as character no-undo init "Выгрузка свёртки по объектам по датам для внешней системы".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/temphost.i }
{ rcs/rcs-xml.i  }
{ rcs/rcsfunc.i  }
{ gbl/getcntxt.i def }
{ gbl/cur-time.i }

    define temp-table temp_good no-undo
        field id                    as character
        field gds-code              like goods.gds-code
        field artic                 like goods.artic
        field prod-type             like goods.prod-type
        field prod-code             like goods.prod-code
        field gds-name              like goods.gds-name
        field qnty-first            like stk-line.fact-qnty
        field qnty-last             like stk-line.fact-qnty
        index pi is primary unique gds-code
    .
    define temp-table temp_good-sum no-undo
        field tag-name              as character               /* base, rubl или doc */
        field first-rubl            like stk-line.sum-rubl
        field first-base            like stk-line.sum-base
        field last-rubl             like stk-line.sum-rubl
        field last-base             like stk-line.sum-base
        field write-result          as logical
        index pi is primary unique tag-name
    .
    define temp-table temp_turn-over no-undo
        field ext-doc-type          like ot-tot.ext-doc-type
        field qnty                  like ot-tot.fact-qnty
        field sum-rubl              like ot-tot.sum-rubl
        field sum-rubl-cost         like ot-tot.sum-rubl
        field sum-base              like ot-tot.sum-base
        field sum-base-cost         like ot-tot.sum-base
        field write-result          as logical
        index pi is primary unique ext-doc-type
    .
    define variable sHomeDir            as character            no-undo.
    define variable sOutFile            as character            no-undo. /* имя файла вывода */
    define variable sLogFile            as character            no-undo. /* имя LOG-файла */
    define variable bLocked             as logical    init no   no-undo. /* флаг блокировки */
    define variable iRep                as integer    init 0    no-undo. /* счетчик для цикла */
    define variable ErrorLevel          as integer              no-undo. /* номер ошибки */

    define variable v-counter           as integer           no-undo.
    define variable v-obj-counter       as integer           no-undo.
    define variable v-log-file-name     as character         no-undo.
    define variable v-fact-order-from   like stk-tot.fact-order no-undo.
    define variable v-fact-order-to     like stk-tot.fact-order no-undo.
    define variable v-docs-exists       as logical              no-undo.
    define variable v-object-state      as character            no-undo.
    define variable v-rcs-object-id     as character         no-undo.
    define variable v-log-string        as character         no-undo.
    define variable v-write-good        as logical           no-undo.
    define variable v-destination-rowid as character         no-undo.
    define variable v-today             as date         no-undo.
    define variable v-time              as integer      no-undo.
    define variable v-archive-ok        as logical      no-undo.
    define variable v-comment           as character    no-undo.


    define buffer buf_rcs-shops     for rcs-shops.
do
for buf_rcs-shops
on error undo, return error
:
    run cur-time in this-procedure (
          output v-today
        , output v-time
    ).
    { gbl/getcntxt.i get " " p-mainmenu-handle }
    RUN init-temphost.
    assign
        v-log-string = ", по всем фирмам"
    .
    case p-range:
    when 2      /* Экспорт по текущей фирме */
    then do:
        for each temp-obj
        where temp-obj.host-code <> v-cntxt-host-code-obj
        :
            delete temp-obj.
        end.
        assign
            v-log-string = ", по фирме (код фирмы " + string( v-cntxt-host-code-obj ) + ")"
        .
    end.
    when 3      /* Экспорт по списку объектов */
    then do:
        for each temp-obj
        :
            delete temp-obj.
        end.
        do v-obj-counter = 1 to num-entries ( p-obj-list ) / 2
        :
            create temp-obj.
            assign
                temp-obj.obj-type = entry( v-obj-counter * 2 - 1, p-obj-list )
                temp-obj.obj-code = integer( entry( v-obj-counter * 2, p-obj-list ) )
            no-error .
            if error-status :error
            then do:
                message
                vss-workfile vss-revision vss-description
                skip "Ошибка чтения списка объектов"
                skip return-value
                skip trim(error-status :get-message(1))
                    trim(error-status :get-message(2))
                    trim(error-status :get-message(3))
                    trim(error-status :get-message(4))
                    trim(error-status :get-message(5))
                view-as alert-box error.
                undo, return error .
            end.
            { gbl/hostcode.i temp-obj.obj-type temp-obj.obj-code temp-obj.host-code no-error }
            if error-status :error
            then do:
                message
                vss-workfile vss-revision vss-description
                skip "Не найдена фирма для объекта" temp-obj.obj-type temp-obj.obj-code
                skip return-value
                skip trim(error-status :get-message(1))
                    trim(error-status :get-message(2))
                    trim(error-status :get-message(3))
                    trim(error-status :get-message(4))
                    trim(error-status :get-message(5))
                view-as alert-box error.
                undo, return error .
            end.
        end.
        assign
            v-log-string = ", по объектам: " + p-obj-list
        .

    end.
    end case.

    ASSIGN v-log-file-name = p-xml-file-name + ".log".

/*Шапка XML*/
    run get-destination-id in this-procedure (
          input "RETAIL1_CONVOLUTION"
        , output v-destination-rowid
    ) no-error.
    if error-status :error
    or v-destination-rowid = ""
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Не удалось получить DESTINATION-ROWID для RETAIL1_CONVOLUTION."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
               trim(error-status :get-message(4))
               trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return error .
    end.

    run rcs-xml-write-header in this-procedure (
              input 1
            , input p-xml-file-name
            , input v-destination-rowid
            , input ""
            , input ""
    ) no-error .
    if error-status :error
    then do:
        undo, return error "rcs-docs: Ошибка записи заголовка файла." + {&new-line} + return-value.
    end.

/* Экспорт из архивов */

object-of-list:
for each temp-obj
:
    for each temp_good
    :
        delete temp_good.
    end.
    find first buf_rcs-shops no-lock
         where buf_rcs-shops.obj-type = temp-obj.obj-type
           and buf_rcs-shops.obj-code = temp-obj.obj-code
    no-error.
    if not available buf_rcs-shops
    then do:
        message
            "В настройках не определено соответствие объекта " temp-obj.obj-type temp-obj.obj-code
            skip "объекту RCS. Сведения о товарах по этому объекту не могут быть экспортированы."
        view-as alert-box information.
        next object-of-list.
    end.

    run wp-XMLWriteEDT( hEDT, 1, string(temp-obj.obj-type) + " " + string(temp-obj.obj-code) ).
    /*---S-------- Расчет архивов на объекте ------------------*/
    run wp-XMLWriteEDT( hEDT, 4,  "Расчет архивов").
    process events.

    run bge/bge-ahz.p (
          input p-mainmenu-handle
        , input temp-obj.obj-type
        , input temp-obj.obj-code
        , input yes
        , input no
        , input no
        , input v-today
        , input v-today
        , output v-archive-ok
        , output v-comment
    ) no-error.
    if error-status :error
    then do:
        message
        vss-workfile vss-revision vss-description
        skip "Ошибка проверки архивов на объекте."
        skip "Тип объекта:" temp-obj.obj-type
        skip "Код объекта:" temp-obj.obj-code
        skip return-value
        skip trim(error-status :get-message(1))
            trim(error-status :get-message(2))
            trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
    run wp-XMLWriteEDT( hEDT, 4,  "Расчет архивов завершен. Идет выгрузка данных по объекту").
    process events.
    /*---E-------- Расчет архивов на объекте ------------------*/
    /*---S----- Границы fact-order для даты p-date --------*/
    run rep/get-fo.p (
                  input  temp-obj.obj-type
                , input  temp-obj.obj-code
                , input  p-date
                , input  p-date
                , output v-fact-order-from
                , output v-fact-order-to
                , output v-docs-exists
                ).
    if v-docs-exists = no
    then do:
        run wp-XMLWriteEDT( hEDT, 4, "Нет закрытых документов за дату " + string( p-date ) ).
        process events.
        next object-of-list .
    end.

    run wp-XMLShowCNT(hCNT).
    /*---E----- Границы fact-order для даты p-date --------*/

    run calc-conv in this-procedure (
                      input buf_rcs-shops.id
                    , input temp-obj.obj-type
                    , input temp-obj.obj-code
                    , input p-date
                    , input v-fact-order-from
                    , input v-fact-order-to
                    , input p-xml-file-name
                    , input v-log-file-name
                    , input hEDT
                    , input hCNT
                                    ) no-error.
    if error-status :error
    then do:
        message
            "Ошибка при выгрузке данных свертки."
        view-as alert-box.
        run wp-XMLWriteEDT( hEDT, 1, string( return-value ) ).
        process events.
    end.
    run wp-XMLHideCNT(hCNT).
    process events.
end.


/* Закрыть тэги шапки*/

    run rcs-xml-write-footer in this-procedure (
              input 1
            , input p-xml-file-name
            , input ""
    ) no-error .
    if error-status :error
    then do:
        undo, return error "rcs-docs: Ошибка окончания записи файла." + {&new-line} + return-value.
    end.

end.

/*==========================================================================*/
procedure calc-conv :

    define buffer buf_gds-obj       for gds-obj.
do
for buf_gds-obj
on error undo, return error
:
define input parameter p-object-id          as character    no-undo.
define input parameter p-obj-type           as character    no-undo.
define input parameter p-obj-code           as integer      no-undo.
define input parameter p-date               as date         no-undo.
define input parameter p-fact-order-from    as integer      no-undo.
define input parameter p-fact-order-to      as integer      no-undo.
define input parameter p-xml-file-name      as character    no-undo.
define input parameter p-log-file-name      as character    no-undo.
define input parameter p-ed                 as handle       no-undo.
define input parameter p-fi                 as handle       no-undo.

define variable v-good-counter  as integer        no-undo.
define variable v-qnty          as integer        no-undo.
define variable v-current-price as decimal        no-undo.

define buffer buf_goods                 for goods.
define buffer buf_rcs-retail1product    for rcs-retail1product.

/*def temp-table temp_good no-undo*/
/*    field gds-code              like goods.gds-code*/
/*    field price                 like price-sale*/
/*    field count-sale            like stk-line.fact-qnty*/
/*    field sum-sale              like stk-line.sum-rubl*/
/*    field count-rest            like stk-line.fact-qnty*/
/*    index pi is primary unique gds-code*/
/*.*/

output stream stmXMLHead to value( p-xml-file-name + ".xm1") convert target "1251" append.

create temp_good.

good-on-object:
for each buf_gds-obj no-lock
   where buf_gds-obj.obj-type   = p-obj-type
     and buf_gds-obj.obj-code   = p-obj-code
:
/*---START--------- Не было движения в этот день на этом объекте ---------------------*/
    if buf_gds-obj.first-doc > p-date
        or ( buf_gds-obj.last-doc < p-date
            and buf_gds-obj.fact-qnty = 0
            and buf_gds-obj.avrg-qnty = 0
           )
    then do:
        next good-on-object.
    end.
/*---END----------- Не было движения в этот день на этом объекте ---------------------*/
    find first buf_goods no-lock
         where buf_goods.artic      = buf_gds-obj.artic
           and buf_goods.prod-type  = buf_gds-obj.prod-type
           and buf_goods.prod-code  = buf_gds-obj.prod-code
    no-error .
    if not available buf_goods
    then do:
        undo, return error "calc-conv: Не найдена карточка товара. "
            + {&new-line} + "Артикул:       " + buf_gds-obj.artic
            + {&new-line} + "Производитель: " + buf_gds-obj.prod-type + " " + string( buf_gds-obj.prod-code )
        .
    end.
    else do:
        assign
            temp_good.gds-code              = buf_goods.gds-code
        .
        find first buf_rcs-retail1product no-lock
             where buf_rcs-retail1product.gds-code = buf_goods.gds-code
        no-error .
        if not available buf_rcs-retail1product
        then do:
            run wp-XMLWriteEDT( hEDT, 1, "Не найден PRODUCT для товара с кодом " + string( buf_goods.gds-code )  ).
            assign
                temp_good.id = "0"
            .
        end.
        else do:
            assign
                temp_good.id = buf_rcs-retail1product.id
            .
        end.
    end.
    assign
        temp_good.artic                 = buf_gds-obj.artic
        temp_good.prod-type             = buf_gds-obj.prod-type
        temp_good.prod-code             = buf_gds-obj.prod-code
        temp_good.gds-name              = ""
        temp_good.qnty-first            = 0
        temp_good.qnty-last             = 0
        v-write-good                    = no
    .
    run form-turn-over in this-procedure ( input rowid( buf_gds-obj ), input {&TDEDT_Ras_Vnesh_Kass} ).
    run form-turn-over in this-procedure ( input rowid( buf_gds-obj ), input {&TDEDT_Vozvrat_Vnesh_Kass} ).

    run form-stk in this-procedure ( input rowid( buf_gds-obj ), input {&arh-cost}, input "cost", output temp_good.qnty-first, output temp_good.qnty-last ).
    run form-stk in this-procedure ( input rowid( buf_gds-obj ), input {&arh-crsa}, input "sale", output v-qnty, output v-qnty ).
    if v-write-good = yes
    then do:

/*        { str/get-pr.i calc p-obj-type p-obj-code temp_good.gds-code ? }*/
        run get-current-price in this-procedure (
              input p-obj-type
            , input p-obj-code
            , input temp_good.artic
            , input temp_good.prod-type
            , input temp_good.prod-code
            , output v-current-price
        ) no-error .
        if error-status :error
        then do:
            undo, return error "calc-conv: Не удалось вычислить текущую продажную цену для товара на объекте."
                                + {&new-line} + "Артикул товара:    " + temp_good.artic
                                + {&new-line} + "Наименование товара: " + temp_good.gds-name
                                + return-value.
        end.

        run process-result in this-procedure (
              input p-object-id
            , input string( v-current-price )
            , input string( year( p-date ) ) + string( month( p-date ), "99" ) + string( day( p-date ), "99" ) + string( "000000" )
            , input buf_gds-obj.obj-type
            , input buf_gds-obj.obj-code
        ).
    end.
end.

output stream stmXMLHead close.

end.
end procedure. /* calc-conv */



/*==========================================================================*/
procedure form-turn-over :
define input parameter p-gds-obj-rowid  as rowid            no-undo.
define input parameter p-ext-doc-type   like ot-tot.ext-doc-type    no-undo.

    define buffer buf_gds-obj       for gds-obj.
    define buffer buf_sale_stk-line      for stk-line.
    define buffer buf_cost_stk-line      for stk-line.
do
for buf_gds-obj
  , buf_sale_stk-line
  , buf_cost_stk-line
on error undo, return error
:
find first buf_gds-obj no-lock
     where rowid( buf_gds-obj ) = p-gds-obj-rowid
.
find first temp_turn-over
     where temp_turn-over.ext-doc-type  = p-ext-doc-type
no-error.
if not available temp_turn-over
then do:
    create temp_turn-over.
    assign
        temp_turn-over.ext-doc-type = p-ext-doc-type
    .
end.
assign
    temp_turn-over.qnty             = 0
    temp_turn-over.sum-rubl         = 0
    temp_turn-over.sum-rubl-cost    = 0
    temp_turn-over.sum-base         = 0
    temp_turn-over.sum-base-cost    = 0
.
run fill-turn-over in this-procedure (
        input buf_gds-obj.obj-type
      , input buf_gds-obj.obj-code
      , input buf_gds-obj.artic
      , input buf_gds-obj.prod-type
      , input buf_gds-obj.prod-code
      , input {&arh-sadt} + p-ext-doc-type
      , input v-fact-order-from
      , input v-fact-order-to
      , input yes
) no-error.
if error-status :error
then do:
    undo, return error "Ошибка вычисления оборотов по товару." + {&new-line} + return-value.
end.
run fill-turn-over in this-procedure (
        input buf_gds-obj.obj-type
      , input buf_gds-obj.obj-code
      , input buf_gds-obj.artic
      , input buf_gds-obj.prod-type
      , input buf_gds-obj.prod-code
      , input {&arh-csdt} + p-ext-doc-type
      , input v-fact-order-from
      , input v-fact-order-to
      , input no
) no-error.
if error-status :error
then do:
    undo, return error "Ошибка вычисления оборотов по товару." + {&new-line} + return-value.
end.
if   temp_turn-over.qnty     = 0
 and temp_turn-over.sum-rubl = 0
 and temp_turn-over.sum-base = 0
then do:
    assign
        temp_turn-over.write-result = no
    .
end.
else do:
    assign
        temp_turn-over.write-result = yes
        v-write-good                = yes
    .
end.
end.
end procedure. /* form-turn-over */


/*==========================================================================*/
procedure fill-turn-over :
do
on error undo, return error
:
define input parameter p-obj-type           as character    no-undo.
define input parameter p-obj-code           as integer      no-undo.
define input parameter p-artic              as character    no-undo.
define input parameter p-prod-type          as character    no-undo.
define input parameter p-prod-code          as integer      no-undo.
define input parameter p-sum-type           as character    no-undo.
define input parameter p-fact-order-from    as integer      no-undo.
define input parameter p-fact-order-to      as integer      no-undo.
define input parameter p-calc-qnty          as logical      no-undo.

    define buffer buf_stk-line      for stk-line.

    find last buf_stk-line no-lock
        where buf_stk-line.obj-type   = p-obj-type
          and buf_stk-line.obj-code   = p-obj-code
          and buf_stk-line.artic      = p-artic
          and buf_stk-line.prod-type  = p-prod-type
          and buf_stk-line.prod-code  = p-prod-code
          and buf_stk-line.sum-type   = p-sum-type
          and buf_stk-line.cat-id     = {&root-cat-id}
          and buf_stk-line.fact-order <= p-fact-order-to
    use-index category
    no-error.
    if available buf_stk-line
    then do:
        if p-calc-qnty = yes
        then do:
            assign
                temp_turn-over.qnty         = temp_turn-over.qnty     + buf_stk-line.fact-qnty
                temp_turn-over.sum-rubl     = temp_turn-over.sum-rubl + buf_stk-line.sum-rubl
                temp_turn-over.sum-base     = temp_turn-over.sum-base + buf_stk-line.sum-base
            .
        end.
        else do:
            assign
                temp_turn-over.sum-rubl-cost    = temp_turn-over.sum-rubl-cost + buf_stk-line.sum-rubl
                temp_turn-over.sum-base-cost    = temp_turn-over.sum-base-cost + buf_stk-line.sum-base
            .
        end.
        find last buf_stk-line no-lock
          where buf_stk-line.obj-type     = p-obj-type
            and buf_stk-line.obj-code     = p-obj-code
            and buf_stk-line.artic        = p-artic
            and buf_stk-line.prod-type    = p-prod-type
            and buf_stk-line.prod-code    = p-prod-code
            and buf_stk-line.sum-type     = p-sum-type
            and buf_stk-line.cat-id       = {&root-cat-id}
            and buf_stk-line.fact-order  <= p-fact-order-from
        use-index category
        no-error.
        if available buf_stk-line
        then do:
            if p-calc-qnty = yes
            then do:
                assign
                    temp_turn-over.qnty       = temp_turn-over.qnty     - buf_stk-line.fact-qnty
                    temp_turn-over.sum-rubl   = temp_turn-over.sum-rubl - buf_stk-line.sum-rubl
                    temp_turn-over.sum-base   = temp_turn-over.sum-base - buf_stk-line.sum-base
                .
            end.
            else do:
                assign
                    temp_turn-over.sum-rubl-cost  = temp_turn-over.sum-rubl-cost - buf_stk-line.sum-rubl
                    temp_turn-over.sum-base-cost  = temp_turn-over.sum-base-cost - buf_stk-line.sum-base
                .
            end.
        end.
    end.
end.
end procedure. /* fill-turn-over */


/*==========================================================================*/
procedure form-stk :
define input parameter p-gds-obj-rowid  as rowid            no-undo.
define input parameter p-sum-type    like stk-tot.sum-type            no-undo.
define input parameter p-tag-name    as character                     no-undo.
define output parameter p-qnty-first like stk-tot.fact-qnty  init 0   no-undo.
define output parameter p-qnty-last  like stk-tot.fact-qnty  init 0   no-undo.

    define buffer buf_gds-obj       for gds-obj.
do
for buf_gds-obj
on error undo, return error
:
    find first buf_gds-obj no-lock
         where rowid( buf_gds-obj ) = p-gds-obj-rowid
    .
    find first temp_good-sum
         where temp_good-sum.tag-name = p-tag-name
    no-error.
    if not available temp_good-sum
    then do:
        create temp_good-sum.
        assign
            temp_good-sum.tag-name          = p-tag-name
        .
    end.
    assign
        temp_good-sum.first-rubl        = 0
        temp_good-sum.first-base        = 0
        temp_good-sum.last-rubl         = 0
        temp_good-sum.last-base         = 0
    .
    find last stk-line no-lock
        where stk-line.obj-type  = buf_gds-obj.obj-type
          and stk-line.obj-code  = buf_gds-obj.obj-code
          and stk-line.artic     = buf_gds-obj.artic
          and stk-line.prod-type = buf_gds-obj.prod-type
          and stk-line.prod-code = buf_gds-obj.prod-code
          and stk-line.sum-type  = p-sum-type
          and stk-line.cat-id    = {&root-cat-id}
          and stk-line.fact-order <= v-fact-order-to
    use-index category
    no-error.
    if available stk-line /* нет остатков на конечную дату */
    then do:
        assign
            p-qnty-last             = stk-line.fact-qnty
            temp_good-sum.last-rubl = temp_good-sum.last-rubl + stk-line.sum-rubl
            temp_good-sum.last-base = temp_good-sum.last-base + stk-line.sum-base
        .
    end.

    if  buf_gds-obj.last-doc < p-date
    then do:
        /*---START--------- Движения не было, но на начало остатки были ---------------------*/
        assign
            p-qnty-first                = p-qnty-last
            temp_good-sum.first-rubl    = temp_good-sum.last-rubl
            temp_good-sum.first-base    = temp_good-sum.last-base
        .
        /*---END----------- Движения не было, но на начало остатки были ---------------------*/
    end.
    else do:
        find last stk-line no-lock
            where stk-line.obj-type  = buf_gds-obj.obj-type
              and stk-line.obj-code  = buf_gds-obj.obj-code
              and stk-line.artic     = buf_gds-obj.artic
              and stk-line.prod-type = buf_gds-obj.prod-type
              and stk-line.prod-code = buf_gds-obj.prod-code
              and stk-line.sum-type  = p-sum-type
              and stk-line.cat-id    = {&root-cat-id}
              and stk-line.fact-order <= v-fact-order-from
        use-index category
        no-error.
        if available stk-line
        then do:
            assign
                p-qnty-first                = p-qnty-first             + stk-line.fact-qnty
                temp_good-sum.first-rubl    = temp_good-sum.first-rubl + stk-line.sum-rubl
                temp_good-sum.first-base    = temp_good-sum.first-base + stk-line.sum-base
            .
        end.
    end.
    if   p-qnty-first             = 0
     and temp_good-sum.first-rubl = 0
     and temp_good-sum.first-base = 0
    then do:
        assign
            temp_good-sum.write-result = no
        .
    end.
    else do:
        assign
            temp_good-sum.write-result = yes
            v-write-good               = yes
        .
    end.
end.
end procedure. /* form-stk */






/*==========================================================================*/
procedure process-result :
do
on error undo, return error
:
define input parameter p-object-id              as character        no-undo.
define input parameter p-current-price-string   as character        no-undo.
define input parameter p-date-string            as character        no-undo.
define input parameter p-obj-type               as character        no-undo.
define input parameter p-obj-code               as integer          no-undo.

    define variable v-good-counter      as integer           no-undo.
    define variable v-sum-all           as decimal           no-undo.
    define variable v-sum-all-cost      as decimal           no-undo.
    define variable v-qnty-all          as decimal           no-undo.

    process events.
    assign
        v-good-counter = v-good-counter + 1
    .
    run wp-xmltagopen( 1, 1, "ROW","").
    run wp-xmltagput( 1, 2, "SITE_ID"    , string( p-object-id )         , 0 ).
    run wp-xmltagput( 1, 2, "DOCDATE"    , p-date-string                 , 0 ).
    run wp-xmltagput( 1, 2, "TOV"        , string( temp_good.id )        , 0 ).
    run wp-xmltagput( 1, 2, "gdsCode"    , string( temp_good.gds-code )  , 0 ).
/*    run wp-xmltagput( 1, 2, "artic"      , temp_good.artic                    , 0 ).*/
/*    run wp-xmltagput( 1, 2, "prodType"   , temp_good.prod-type                , 0 ).*/
/*    run wp-xmltagput( 1, 2, "prodCode"   , string( temp_good.prod-code )      , 0 ).*/
/*    run wp-xmltagput( 1, 2, "name"       , temp_good.gds-name                 , 0 ).*/
/*    run wp-xmltagput( 1, 2, "qntyStart"  , string( temp_good.qnty-first )     , 0 ).*/
    run wp-xmltagput( 1, 2, "PRICE_COST" , p-current-price-string               , 0 ).
    run wp-xmltagput( 1, 2, "COUNT_REST" , format-decimal( temp_good.qnty-last ), 0 ).

/*    for each temp_good-sum*/
/*       where temp_good-sum.write-result = yes*/
/*    :*/
/*        run wp-xmltagopen( 5, "restSumType", "" ).*/
/*        run wp-xmltagput( 1, 6, "name"       , string( temp_good-sum.tag-name ) , 0 ).*/
/*        run wp-xmltagput( 1, 6, "sumStartR"  , string( temp_good-sum.first-rubl ) , 0 ).*/
/*        run wp-xmltagput( 1, 6, "sumStartB"  , string( temp_good-sum.first-base ) , 0 ).*/
/*        run wp-xmltagput( 1, 6, "sumEndR"    , string( temp_good-sum.last-rubl )  , 0 ).*/
/*        run wp-xmltagput( 1, 6, "sumEndB"    , string( temp_good-sum.last-base )  , 0 ).*/
/*        run wp-xmltagclose( 5, "restSumType" ).*/
/*    end.*/
    for each temp_turn-over
       where temp_turn-over.write-result = yes
    break by temp_turn-over.ext-doc-type
    :
        assign
            v-sum-all       = v-sum-all      + temp_turn-over.sum-rubl
            v-qnty-all      = v-qnty-all + temp_turn-over.qnty
            v-sum-all-cost  = v-sum-all-cost + temp_turn-over.sum-rubl-cost
        .
    end.
    run wp-xmltagput( 1, 2, "COUNT_SALE", format-decimal(  ( -1 ) * v-qnty-all      ), 0 ).
    run wp-xmltagput( 1, 2, "SUM_SALE"  , format-decimal(  ( -1 ) * v-sum-all       ), 0 ).
    run wp-xmltagput( 1, 2, "SUM_COST"  , format-decimal(  ( -1 ) * v-sum-all-cost  ), 0 ).
    run wp-xmltagclose( 1, 1, "ROW").

    if v-good-counter modulo 25 = 0
    then do:
        run wp-XMLWriteCnt( hcnt, "Товар " + p-obj-type + string( p-obj-code ) + "  " + string( v-good-counter ) ).
        process events.
    end.
/*            { rep/repfrm.i disp v-good-counter}*/
end.
end procedure. /* eval-sum-and-write-result */

/*==========================================================================*/
procedure get-current-price :
do
on error undo, return error
:
define input parameter p-obj-type  as character    no-undo.
define input parameter p-obj-code  as integer      no-undo.
define input parameter p-artic     as character    no-undo.
define input parameter p-prod-type as character    no-undo.
define input parameter p-prod-code as integer      no-undo.
define output parameter p-current-price as decimal      no-undo.

    define buffer buf_price-list    for price-list.
    define buffer buf_goods         for goods.
    define buffer buf_gds-prt       for gds-prt.

    find first buf_goods no-lock
         where buf_goods.artic      = p-artic
           and buf_goods.prod-type  = p-prod-type
           and buf_goods.prod-code  = p-prod-code
    no-error .
    if not available buf_goods
    then do:
        undo, return error "get-current-price: Ошибка поиска товара в базе данных." + {&new-line} + return-value.
    end.
    find first buf_gds-prt no-lock
         where buf_gds-prt.upper-code = buf_goods.prt-root
    .
    if not available buf_gds-prt
    then do:
        undo, return error "get-current-price: Ошибка поиска корневого признака товара в базе данных." + {&new-line} + return-value.
    end.

    find last buf_price-list no-lock
        where buf_price-list.obj-type   = p-obj-type
          and buf_price-list.obj-code   = p-obj-code
          and buf_price-list.b-code     = buf_goods.gds-code
          and buf_price-list.price-type = "":U
    use-index fact-close
    no-error.
    if not available buf_price-list
    then do:
        assign
            p-current-price = 0
        .
    end.
    else do:
        assign
            p-current-price = buf_price-list.price-sale
        .
    end.

end.
end procedure. /* get-current-price */