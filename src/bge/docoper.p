block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: docoper.p $
$Archive: bge/docoper.p $

Экспорт документов по архивам

Автор: Хныкин Павел Андреевич
Дата создания: 04/05/06
Author: Pavel Khnykin
Creation date: 04/05/06

Input:
    p-host-code         - код фирмы
    p-obj-type          - тип объекта
    p-obj-code          - код объекта
    p-ext-doc-type      - расширенный тип документа
    p-oper-name         - номер операции (неверный номер - запись в лог)
    p-fact-order-from   - начальный fact-order
    p-fact-order-to     - конечный fact-order
    p-pay-code          - надо ли выгружать разбивку по видам оплат
    p-cst               - надо ли выгружать строку ГТД (ГТД из партий одной строкой через ';')
    p-parts             - надо ли выгружать разбивку по партиям
    p-chk-pay-code      - надо ли выгружать разбивку по типам кассовых платежей
    p-pay-desk          - надо ли выгружать разбивку по кассам
    p-pay-desk-cards    - надо ли выгружать разбивку по префиксам карт
    p-xml-file-name            - имя файла .tmp для вывода (вызывающая программа создает и по завершении
                            экспорта переименовывает этот файл в .xml. Сделано для синхронизации с
                            блоком импорта во внешней бухгалтерии.
    p-log-file-name            - полное имя файла для записи событий.
    p-parent-handle     - handle вызывающей процедуры
    hEDT                - handle поля лога (EDITOR) окна вывода
    hCNT                - handle поля счётчика (FILL-IN) окна вывода
*/
define input parameter p-host-code              as character               no-undo.
define input parameter p-obj-type               as character               no-undo.
define input parameter p-obj-code               as integer                 no-undo.
define input parameter p-ext-doc-type           as character               no-undo.
define input parameter p-oper-name              as character               no-undo.
define input parameter p-fact-order-from        like ub.stk-tot.fact-order    no-undo.
define input parameter p-fact-order-to          like ub.stk-tot.fact-order    no-undo.
define input parameter p-pay-code               as logical                 no-undo.
define input parameter p-cst                    as logical                 no-undo.
define input parameter p-parts                  as logical                 no-undo.
define input parameter p-chk-pay-code           as logical                 no-undo.
define input parameter p-pay-desk               as logical                 no-undo.
define input parameter p-pay-desk-cards         as logical                 no-undo.
define input parameter p-obj-list               as character               no-undo.
define input parameter p-doc-type-list          as character               no-undo.
define input parameter p-parameter-list         as character               no-undo.
define input parameter p-xml-file-name          as character               no-undo.
define input parameter p-log-file-name          as character               no-undo.
define input parameter p-list-file-name         as character               no-undo.
define input parameter p-xml-file-number        as integer                 no-undo.
define input parameter p-parent-handle          as handle                  no-undo.
define input parameter hEDT                     as handle                  no-undo.
define input parameter hCNT                     as handle                  no-undo.
define output parameter p-last-xml-file-name    as character               no-undo.
define output parameter p-last-xml-file-number  as integer                 no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: docoper.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/docoper.p $":U .
define variable vss-description as character no-undo init "Экспорт документов по архивам".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ bge/bgelib.i   }
{ str/lib-trn.i  }
{ str/trdcalib.i }
{ str/in-vatp.i def }
{ str/out-vatp.i def }

    define variable v-qnty                      like ub.ot-tot.fact-qnty   no-undo.
    define variable v-doc-date                  like ub.trn-doc.doc-date   no-undo.
    define variable v-fact-date                 like ub.trn-doc.fact-date  no-undo.
    define variable v-pay-code                  like ub.trn-doc.fact-date  no-undo.
    define variable v-reason-code               as integer              no-undo.
    define variable v-doc-PS                    like ub.trn-doc.PS         no-undo.
    define variable v-exists-operation          as logical      no-undo.
    define variable v-exists-sale_ot-supp-tot   as logical      no-undo.
    define variable v-is-petrol                 as logical      no-undo.
    define variable v-is-pieces                 as logical      no-undo.
    define variable v-petrol-weight             as decimal      no-undo.
    define variable v-petrol-density            as decimal      no-undo.
    define variable v-weight-not-specified      as logical      no-undo.
    define variable v-host-code                 as integer       no-undo.
    define variable v-base-code                 as integer       no-undo.
    define variable v-is-out                    as integer       no-undo.
    define variable v-inkas-pay-desk-type       like ub.inkas-pay-desk.doc-type no-undo.
    define variable v-last-file-position        as integer       no-undo.
    define variable v-curr-r-b                  as character      no-undo.

    define temp-table temp_inkas-pay no-undo
        field pay-code  like ub.inkas-pay.pay-code
        field tot-base  like ub.inkas-pay.tot-base
        field tot-rubl  like ub.inkas-pay.tot-rubl
        field tot-sum   like ub.inkas-pay.tot-sum
    index pi is primary unique pay-code
    .

    define temp-table temp_cost_cat-id_ot-supp-tot  no-undo
        field cat-id as character
        index pi is primary unique cat-id
    .
    define temp-table temp_cost_cli_ot-supp-tot     no-undo
        field cat-id            as character
        field cli-type          as character
        field cli-code          as integer
        field sum-rubl          as decimal
        field vat-rubl          as decimal
        field slt-rubl          as decimal
        field road-tax-rubl     as decimal
        field transport-rubl    as decimal
        field other-rubl        as decimal
        field excise-rubl       as decimal
        field sum-base          as decimal
        field vat-base          as decimal
        field slt-base          as decimal
        field road-tax-base     as decimal
        field transport-base    as decimal
        field other-base        as decimal
        field excise-base       as decimal
        field fact-qnty         as decimal
        index pi is primary unique cat-id cli-type cli-code
    .
    define temp-table temp_cost_cat-id_ot-supp-line no-undo
        field artic     as character
        field prod-type as character
        field prod-code as integer
        field cat-id    as character
        index pi is primary unique artic prod-type prod-code cat-id
    .
    define temp-table temp_cost_cli_ot-supp-line    no-undo
        field artic             as character
        field prod-type         as character
        field prod-code         as integer
        field cat-id            as character
        field cli-type          as character
        field cli-code          as integer
        field sum-rubl          as decimal
        field vat-rubl          as decimal
        field slt-rubl          as decimal
        field road-tax-rubl     as decimal
        field transport-rubl    as decimal
        field other-rubl        as decimal
        field excise-rubl       as decimal
        field sum-base          as decimal
        field vat-base          as decimal
        field slt-base          as decimal
        field road-tax-base     as decimal
        field transport-base    as decimal
        field other-base        as decimal
        field excise-base       as decimal
        field fact-qnty         as decimal
        index pi is primary unique artic prod-type prod-code cat-id cli-type cli-code
    .

    /*определение таблиц необходимых для разбивки чеков по платежам*/
    { ref/cp-attr.i }
    { rep/cpapcep.i  "NEW SHARED" }
    { rep/cpapcep.i  "proc" }
    { rep/real-2df.i "NEW SHARED" treal-2 bge }
    { rep/realg3df.i "NEW SHARED" treal-3 bge }
    { rep/real-4df.i "NEW SHARED" treal-4 bge }

do
on error undo, return error
:
    ASSIGN
    v-exists-operation = NO.
    .
    { gbl/hostcode.i p-obj-type p-obj-code v-host-code }
    { gbl/basecode.i v-host-code v-base-code }
    run cpapcep in this-procedure .

    RUN bgelib-write-cnt( hCNT, "" ).
    assign
        p-last-xml-file-name = p-xml-file-name
    .
    { gbl/curr-r-b.i
        v-curr-r-b
    }
    run export-documents in this-procedure (
          input p-obj-list
        , input p-doc-type-list
        , input p-parameter-list
        , input p-xml-file-name
        , input p-log-file-name
        , input p-list-file-name
        , input p-xml-file-number
        , output p-last-xml-file-name
        , output p-last-xml-file-number
    ).
end.

/*==========================================================================*/
procedure export-documents :
do
on error undo, return error
:
define input parameter p-obj-list               as character    no-undo.
define input parameter p-doc-type-list          as character    no-undo.
define input parameter p-parameter-list         as character    no-undo.
define input parameter p-xml-file-name          as character    no-undo.
define input parameter p-log-file-name          as character    no-undo.
define input parameter p-list-file-name         as character    no-undo.
define input parameter p-xml-file-number        as integer      no-undo.
define output parameter p-last-xml-file-name    as character    no-undo.
define output parameter p-last-xml-file-number  as integer      no-undo.

    define variable v-doc-code      as character    no-undo.
    define variable v-good-code     as character      no-undo.
    define variable v-good-type     as character      no-undo.
    define variable v-obj-type      as character    no-undo.
    define variable v-obj-code      as integer      no-undo.
    define variable v-fact-order    as decimal      no-undo.
    define variable v-sys-date      as date         no-undo.
    define variable v-sys-time      as character    no-undo.
    define variable v-exists-before as logical      no-undo.
    define variable v-exists-after  as logical      no-undo.

    define variable v-supp-dog-code     as character    no-undo.
    define variable v-supp-ndog         as character    no-undo.
    define variable v-supp-ddog         as character    no-undo.

    define variable v-need-new-file  as logical     no-undo.
    define variable v-need-disk-spc  as logical     no-undo.
    define variable v-cancel         as logical     no-undo.
    define variable v-prev-filename  as character   no-undo.
    define variable v-void-string    as character   no-undo.
    define variable v-scale-is-empty as logical     no-undo.

    define buffer buf_ot-tot-sale          for ub.ot-tot.
    define buffer buf_ot-tot-cost          for ub.ot-tot.
    define buffer buf_ot-tot-crsa          for ub.ot-tot.
    define buffer buf_ot-tot-crsa-loop     for ub.ot-tot.
    define buffer buf_ot-line-sale         for ub.ot-line.
    define buffer buf_ot-line-cost         for ub.ot-line.
    define buffer buf_ot-line-crsa         for ub.ot-line.
    define buffer buf_ot-line-crsa-loop    for ub.ot-line.
    define buffer buf_cost_ot-supp-line    for ub.ot-supp-line.
    define buffer buf_sale_ot-supp-line    for ub.ot-supp-line.
    define buffer buf_cost_ot-supp-tot     for ub.ot-supp-tot.
    define buffer buf_sale_ot-supp-tot     for ub.ot-supp-tot.
    define buffer buf_doc-line             for ub.doc-line.
    define buffer buf_doc-line-sum         for ub.doc-line-sum.
    define buffer buf_contract             for ub.contract.
    define buffer buf_trn-doc              for ub.trn-doc.
    define buffer buf_price-doc            for ub.price-doc.
    define buffer buf_inkas                for ub.inkas.
    define buffer buf_goods                for ub.goods.
    define buffer buf_units                for ub.units.

    for each temp_cost_cat-id_ot-supp-tot no-lock
    on error undo, return error
    :
        delete temp_cost_cat-id_ot-supp-tot.
    end.
    for each temp_cost_cli_ot-supp-tot no-lock
    on error undo, return error
    :
        delete temp_cost_cli_ot-supp-tot.
    end.

    for each temp_cost_cat-id_ot-supp-line no-lock
    on error undo, return error
    :
        delete temp_cost_cat-id_ot-supp-line.
    end.
    for each temp_cost_cli_ot-supp-line no-lock
    on error undo, return error
    :
        delete temp_cost_cli_ot-supp-line.
    end.

    assign
        p-last-xml-file-name    = p-xml-file-name
        p-last-xml-file-number  = p-xml-file-number
    .
    output stream stmxmlout to value( p-xml-file-name + {&bgelib-temp-extension} ) convert target "1251" append.

    export-documents-arch:
    for each  buf_ot-tot-crsa-loop no-lock
       where buf_ot-tot-crsa-loop.obj-type     = p-obj-type
         and buf_ot-tot-crsa-loop.obj-code     = p-obj-code
         and buf_ot-tot-crsa-loop.ext-doc-type = p-ext-doc-type
         and buf_ot-tot-crsa-loop.fact-order   > p-fact-order-from
         and buf_ot-tot-crsa-loop.fact-order  <= p-fact-order-to
         and buf_ot-tot-crsa-loop.sum-type     = {&arh-crsa}
         and buf_ot-tot-crsa-loop.cat-id       = {&root-cat-id}
    on error undo, return error
    :
        assign
            v-supp-dog-code = "":U
            v-supp-ndog     = "":U
            v-supp-ddog     = "":U
        .
        if v-need-new-file = yes
        then do:
            output stream stmxmlout close.
            assign
                v-prev-filename = p-xml-file-name
            .
            run bgelib-filename in this-procedure (
                  input "doc"
                , output p-xml-file-name
                , output v-void-string
                , output v-void-string
            ).
            run bgelib-write-footer in this-procedure (
                  input no
                , input v-prev-filename
                , input p-list-file-name
                , input yes
                , input p-xml-file-name + "xml":U
            ).
            run bgelib-write-log in this-procedure (
                input p-log-file-name
                , input 1
                , input substitute( "Данные выгружены в файл &1"
                                        , replace( p-xml-file-name, "/", "\" ) + "xml"
                                )
            ).
            assign
                p-last-xml-file-number   = p-xml-file-number + 1
                p-last-xml-file-name     = p-xml-file-name
            .
            run bgelib-write-header in this-procedure (
                  input no
                , input p-last-xml-file-name
                , input p-list-file-name
                , input p-last-xml-file-number
                , input yes
                , input v-prev-filename + "xml":U
                , input p-obj-list
                , input p-doc-type-list
                , input p-parameter-list
            ).
            output stream stmxmlout to value( p-xml-file-name + {&bgelib-temp-extension} ) convert target "1251" append.
            assign
                v-need-new-file = no
            .
        end.        /* if v-need-new-file = yes */
        assign
            v-doc-code      = buf_ot-tot-crsa-loop.doc-code
            v-obj-type      = buf_ot-tot-crsa-loop.obj-type
            v-obj-code      = buf_ot-tot-crsa-loop.obj-code
            v-fact-order    = buf_ot-tot-crsa-loop.fact-order
        .
        case p-ext-doc-type
        :
            when {&TDEDT_Overturn}
            then do:
                find first buf_ot-tot-sale no-lock
                     where buf_ot-tot-sale.doc-code = v-doc-code
                       and buf_ot-tot-sale.sum-type = {&arh-crsa}
                       and buf_ot-tot-sale.cat-id   = buf_ot-tot-crsa-loop.cat-id
                no-error.
                if not available buf_ot-tot-sale
                then do:
                    run bgelib-write-log in this-procedure ( p-log-file-name, 1, "Не найден документ переоценки " + string( v-doc-code ) ).
                    next export-documents-arch.
                end.
            end.
            otherwise do:
                find first buf_ot-tot-sale no-lock
                     where buf_ot-tot-sale.doc-code = v-doc-code
                       and buf_ot-tot-sale.sum-type = {&arh-sale}
                       and buf_ot-tot-sale.cat-id   = buf_ot-tot-crsa-loop.cat-id
                no-error.
                if not available buf_ot-tot-sale
                then do:
                    find first buf_ot-tot-sale no-lock
                         where buf_ot-tot-sale.doc-code = v-doc-code
                           and buf_ot-tot-sale.sum-type = {&arh-sale-service}
                           and buf_ot-tot-sale.cat-id   = buf_ot-tot-crsa-loop.cat-id
                    no-error.
                end.
                if not available buf_ot-tot-sale
                then do:
                    if buf_ot-tot-crsa-loop.fact-qnty <> 0
                    then do:
                        run bgelib-write-log in this-procedure ( p-log-file-name, 1, "В архивах нет записей sum-type = {&arh-sale} или {&arh-sale-service} для документа номер " + string( v-doc-code ) + " ( ext-doc-type = " + p-ext-doc-type + ")" ).
                    end.
/*                    next export-documents-arch.*/
                end.
                else do:
                    if buf_ot-tot-crsa-loop.fact-qnty <> buf_ot-tot-sale.fact-qnty
                    then do:
                        run bgelib-write-log in this-procedure ( p-log-file-name, 1, "Не совпадает фактическое количество для записей архивов sum-type = {&arh-sale} и {&arh-crsa} для документа номер " + string( v-doc-code ) + " ( ext-doc-type = " + p-ext-doc-type + ")" ).
                    end.
                end.
            end.
        end case.
        if not v-exists-operation
        then do:
            run bgelib-write-edt in this-procedure ( hEDT, 4, "Операция " + string( p-oper-name ) ).
            run bgelib-write-log in this-procedure ( p-log-file-name, 0, "&Line" ).
            run bgelib-write-log in this-procedure ( p-log-file-name, 1, "XML - Вывод операции " + string( p-oper-name ) + " (" + p-ext-doc-type + ")" ).
            assign
                v-exists-operation = yes
            .
        end.
        if p-ext-doc-type <> {&TDEDT_Overturn}
        then do:        /* По номеру документа достать даты и примечание. */
            find first buf_trn-doc no-lock
                where buf_trn-doc.doc-code = v-doc-code
            no-error.
            if not available buf_trn-doc
            then do:
                run bgelib-write-log in this-procedure (  p-log-file-name,
                                            1,
                                    "*** ERR: *** Не удалось найти документ N "
                                    + string( v-doc-code )
                ).
                assign
                    v-doc-date      = ?
                    v-fact-date     = ?
                    v-reason-code   = 0
                    v-doc-PS        = ""
                .
            end.
            else do:
                if p-ext-doc-type = {&TDEDT_Pri_Vnesh}
                or p-ext-doc-type = {&TDEDT_Corr_Acc_Price}
                then  do:
                    if buf_trn-doc.contract-code <> 0
                    then do:
                        assign
                            v-supp-dog-code = string( buf_trn-doc.contract-code )
                        .
                        find first buf_contract no-lock
                             where buf_contract.host-code       = buf_trn-doc.host-code
                               and buf_contract.contract-code   = buf_trn-doc.contract-code
                        no-error.
                        if available buf_contract
                        then do:
                            assign
                                v-supp-ndog          = string( buf_contract.contract-prn-code )
                                v-supp-ddog          = string( buf_contract.contract-date, "99.99.9999" )
                            .
                        end.
                    end.
                end.        /* if p-ext-doc-type = {&TDEDT_Pri_Vnesh} */
                assign
                    v-doc-date      = buf_trn-doc.doc-date
                    v-fact-date     = buf_trn-doc.fact-date
                    v-reason-code   = buf_trn-doc.reason-code
                    v-doc-PS        = buf_trn-doc.ps
                    v-sys-date      = buf_trn-doc.sys-date
                    v-sys-time      = buf_trn-doc.sys-time
                .
            end.
        end.      /* if p-ext-doc-type <> {&TDEDT_Overturn} */
        else do:        /* По номеру переоценки достать даты и примечание. */
            find first buf_price-doc no-lock
                 where buf_price-doc.doc-num = v-doc-code
            no-error.
            if not available buf_price-doc
            then do:
                run bgelib-write-log in this-procedure (  p-log-file-name,
                                            1,
                                    "*** ERR: *** Не удалось найти документ переоценки N "
                                    + string( v-doc-code )
                ).
                assign
                    v-doc-date      = ?
                    v-fact-date     = ?
                    v-reason-code   = 0
                    v-doc-PS        = ""
                .
            end.
            else do:
                assign
                    v-doc-date      = buf_price-doc.doc-date
                    v-fact-date     = buf_price-doc.fact-date
                    v-reason-code   = 0
                    v-doc-PS        = buf_price-doc.ps
                    v-sys-date      = buf_price-doc.sys-date
                    v-sys-time      = buf_price-doc.sys-time
                .
            end.
        end.      /* if NOT( p-ext-doc-type <> {&TDEDT_Overturn} ) */
        run bgelib-write-cnt( hcnt, "   " + string( v-doc-code ) + " от " + string( v-fact-date ) ) .
        process events.
        run bgelib-tag-open in this-procedure ( input 0, "doc","" ).
        run bgelib-tag-put in this-procedure ( input 1, input "docID",        input string( v-doc-code                                             ), input 0 ).
        run bgelib-tag-put in this-procedure ( input 1, input "codeOperation",      input string( p-ext-doc-type                                         ), input 0 ).
        run bgelib-tag-put in this-procedure ( input 1, input "host",               input string( p-host-code                                            ), input 0 ).
        run bgelib-tag-put in this-procedure ( input 1, input "store",              input v-obj-type + string( v-obj-code )                               , input 0 ).
        run bgelib-tag-put in this-procedure ( input 1, input "factOrder",          input string( v-fact-order )                   , input 0 ).
        run bgelib-tag-put in this-procedure ( input 1, input "sysDate",            input string( v-sys-date, "99.99.9999" )       , input 0 ).
        run bgelib-tag-put in this-procedure ( input 1, input "sysTime",            input string( v-sys-time )                     , input 0 ).
        run bgelib-tag-put in this-procedure ( input 1, input "dateDoc",            input string( v-doc-date,"99.99.9999"                                ), input 0 ).
        run bgelib-tag-put in this-procedure ( input 1, input "dateFact",           input string( v-fact-date,"99.99.9999"                               ), input 0 ).
        run bgelib-tag-put in this-procedure ( input 1, input "valutCode",          input string( v-base-code                                            ), input 0 ).
        if p-ext-doc-type <> {&TDEDT_Overturn}
        then do:
            run fill_bgelib_clients in this-procedure (
                  input p-parent-handle
                , input buf_trn-doc.cli-type
                , input buf_trn-doc.cli-code
            ).
            run bgelib-tag-put in this-procedure ( input 1, input "firm",                 input buf_trn-doc.cli-type + string( buf_trn-doc.cli-code ), input 0 ).
            run bgelib-tag-put in this-procedure ( input 1, input "extNumber",            input string( buf_trn-doc.ord-num                     ), input 0 ).
            run bgelib-tag-put in this-procedure ( input 1, input "outNumber",            input string( buf_trn-doc.ship-num                    ), input 0 ).
            run bgelib-tag-put in this-procedure ( input 1, input "outDate",              input string( buf_trn-doc.ship-date,  "99.99.9999"    ), input 0 ).
            run bgelib-tag-put in this-procedure ( input 1, input "paymentCode",          input string( buf_trn-doc.pay-code                    ), input 0 ).
            run bgelib-tag-put in this-procedure ( input 1, input "InterFirmDocChild",    input string( buf_trn-doc.hold-doc-code-child         ), input 0 ).
            run bgelib-tag-put in this-procedure ( input 1, input "InterFirmDocParent",   input string( buf_trn-doc.hold-doc-code-parent        ), input 0 ).
            run bgelib-tag-put in this-procedure ( input 1, input "InterFirmObjType",     input string( buf_trn-doc.hold-obj-type               ), input 0 ).
            run bgelib-tag-put in this-procedure ( input 1, input "InterFirmObjCode",     input string( buf_trn-doc.hold-obj-code               ), input 0 ).
        end.      /* p-ext-doc-type <> {&TDEDT_Overturn} */
        run export-attribute in this-procedure (
              input v-doc-code
            , input {&trdcattr-dov}
            , input "authority"
        ).
        run export-attribute in this-procedure (
              input v-doc-code
            , input {&trdcattr-nids}
            , input "suppInDocNo"
        ).
        run export-attribute in this-procedure (
              input v-doc-code
            , input {&trdcattr-dids}
            , input "suppInDocDate"
        ).
        run bgelib-tag-put in this-procedure ( input 1, input "contractSuppCode" , input v-supp-dog-code , input 0 ).
        run bgelib-tag-put in this-procedure ( input 1, input "contractSuppNo"   , input v-supp-ndog     , input 0 ).
        run bgelib-tag-put in this-procedure ( input 1, input "contractSuppDate" , input v-supp-ddog     , input 0 ).
        run export-attribute in this-procedure (
              input v-doc-code
            , input {&trdcattr-ndog}
            , input "contractNo"
        ).
        run export-attribute in this-procedure (
              input v-doc-code
            , input {&trdcattr-ddog}
            , input "contractDate"
        ).
        run export-attribute in this-procedure (
              input v-doc-code
            , input {&trdcattr-nsf}
            , input "sfNo"
        ).
        run export-attribute in this-procedure (
              input v-doc-code
            , input {&trdcattr-dsf}
            , input "sfDate"
        ).
        run bgelib-tag-put in this-procedure ( input 1, input "reasonCode"  ,  input v-reason-code  , input 2 ).
        run bgelib-tag-put in this-procedure ( input 1, input "comment"     ,  input v-doc-PS       , input 0 ).
        run bgelib-tag-close in this-procedure ( input 0, input "doc" ).
        /*---START--------- Суммы по видам кассовых платежей ---------------------*/
        if p-ext-doc-type <> {&TDEDT_Overturn}
        and p-pay-code = yes
        or ( p-chk-pay-code = yes
        and ( p-ext-doc-type = {&TDEDT_Ras_Vnesh_Kass} or p-ext-doc-type = {&TDEDT_Vozvrat_Vnesh_Kass} ) )
        then do:
            find first buf_trn-doc no-lock
                 where buf_trn-doc.doc-code = v-doc-code
            no-error.
            if not available buf_trn-doc
            then do:
                run bgelib-write-log in this-procedure (  p-log-file-name, 1, "*** ERR: *** Не удалось найти документ N " + string( v-doc-code ) ).
            end.        /* not available trn-doc */
            else do:
                case p-ext-doc-type :
                    when {&TDEDT_Ras_Vnesh_Kass}
                    then do:
                        assign
                            v-is-out                = 1
                            v-inkas-pay-desk-type   = {&income}
                        .
                        find first buf_inkas no-lock
                             where buf_inkas.inkas-code = v-doc-code
                        no-error.
                    end.
                    when {&TDEDT_Vozvrat_Vnesh_Kass}
                    then do:
                        assign
                            v-is-out                = -1
                            v-inkas-pay-desk-type   = {&expense}
                        .
                        find first buf_inkas no-lock
                             where buf_inkas.inkas-code = buf_trn-doc.out-code
                        no-error.
                    end.
                end case.
                if available buf_inkas
                then do:
                    run bge/bgepych2.p (
                          input buf_inkas.inkas-code
                        , input p-ext-doc-type
                        , input p-pay-desk
                        , input p-pay-desk-cards
                        , input yes /*p-petrol*/
                        , input yes /*p-goods*/
                        , input yes /*p-services*/
                    ).
                    if p-pay-code = yes
                    then do:
                        run get-inkas-pay-desk in this-procedure (
                              input buf_inkas.inkas-code
                            , input buf_inkas.obj-type
                            , input buf_inkas.obj-code
                            , input v-inkas-pay-desk-type
                        ) no-error .
                        if error-status:error
                        then do:
                            run bgelib-write-log in this-procedure (  p-log-file-name, 1, "*** ERR: *** Не удалось рассчитать разбивку по кодам оплат по документу N "+ string( v-doc-code ) ).
                        end.
                        for each temp_inkas-pay
                        on error undo, return error
                        :
                            run bgelib-tag-open in this-procedure ( input 0, input "docCass", input "" ).
                            run bgelib-tag-put in this-procedure ( input 1, input "docID" , input string( v-doc-code )                        , input 0 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "payCode"     , input string( temp_inkas-pay.pay-code )           , input 0 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "sum"         , input string( v-is-out * temp_inkas-pay.tot-sum ) , input 2 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "sumb"        , input string( v-is-out * temp_inkas-pay.tot-base ), input 2 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "sumr"        , input string( v-is-out * temp_inkas-pay.tot-rubl ), input 2 ).
                            run bgelib-tag-close in this-procedure ( input 0, input "docCass" ).
                        end.
                    end. /*p-pay-code = yes*/
                end.        /* available inkas */
                else do:
                    if p-ext-doc-type = {&TDEDT_Ras_Vnesh_Kass}
                    or p-ext-doc-type = {&TDEDT_Vozvrat_Vnesh_Kass}
                    then do:
                        run bgelib-write-log in this-procedure (  p-log-file-name, 1, "*** ERR: *** Не найден inkas для документа расхода или возврата по кассе N " + string( v-doc-code ) ).
                    end.
                end.        /* NOT available inkas */
            end.        /* available trn-doc */
        end.
        /*---END----------- Суммы по видам кассовых платежей ---------------------*/
        /* Цены документа */
        if available buf_ot-tot-sale
        then do:
            run bgelib-tag-open in this-procedure ( input 0, input "docSum", input "" ).
            run bgelib-tag-put in this-procedure ( input 1, "docID"   , input string( v-doc-code )                           , input 0 ).
            run bgelib-tag-put in this-procedure ( input 1, "sumr"          , input string( abs( buf_ot-tot-sale.sum-rubl       ) ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, "VATr"          , input string( abs( buf_ot-tot-sale.vat-rubl       ) ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, "SLTr"          , input string( abs( buf_ot-tot-sale.slt-rubl       ) ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, "roadTaxr"      , input string( abs( buf_ot-tot-sale.road-tax-rubl  ) ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, "transportr"    , input string( abs( buf_ot-tot-sale.transport-rubl ) ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, "otherr"        , input string( abs( buf_ot-tot-sale.other-rubl     ) ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, "exciser"       , input string( abs( buf_ot-tot-sale.excise-rubl    ) ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, "sumb"          , input string( abs( buf_ot-tot-sale.sum-base       ) ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, "VATb"          , input string( abs( buf_ot-tot-sale.vat-base       ) ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, "SLTb"          , input string( abs( buf_ot-tot-sale.slt-base       ) ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, "roadTaxb"      , input string( abs( buf_ot-tot-sale.road-tax-base  ) ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, "transportb"    , input string( abs( buf_ot-tot-sale.transport-base ) ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, "otherb"        , input string( abs( buf_ot-tot-sale.other-base     ) ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, "exciseb"       , input string( abs( buf_ot-tot-sale.excise-base    ) ), input 2 ).
            run bgelib-tag-close in this-procedure ( input 0, input "docSum" ).
        end.
        /* Учетные цены */
        if p-ext-doc-type <> {&TDEDT_Overturn}
        then do:
            find first buf_ot-tot-cost no-lock
                 where buf_ot-tot-cost.doc-code    = v-doc-code
                   and buf_ot-tot-cost.sum-type    = {&arh-cost}
                   and buf_ot-tot-cost.cat-id      = {&root-cat-id}
            no-error.
            if not available buf_ot-tot-cost
            then do:
                find first buf_ot-tot-cost no-lock
                     where buf_ot-tot-cost.doc-code    = v-doc-code
                       and buf_ot-tot-cost.sum-type    = {&arh-cost-service}
                       and buf_ot-tot-cost.cat-id      = {&root-cat-id}
                no-error.
            end.
            if available buf_ot-tot-cost
            then do:
                run bgelib-tag-open in this-procedure ( input 0, input "docCostSum", input "" ).
                run bgelib-tag-put in this-procedure ( input 1, "docID", input string( v-doc-code )                           , input 0 ).
                run bgelib-tag-put in this-procedure ( input 1, "sumr"       , input string( abs( buf_ot-tot-cost.sum-rubl       ) ), input 2 ).
                run bgelib-tag-put in this-procedure ( input 1, "VATr"       , input string( abs( buf_ot-tot-cost.vat-rubl       ) ), input 2 ).
                run bgelib-tag-put in this-procedure ( input 1, "SLTr"       , input string( abs( buf_ot-tot-cost.slt-rubl       ) ), input 2 ).
                run bgelib-tag-put in this-procedure ( input 1, "roadTaxr"   , input string( abs( buf_ot-tot-cost.road-tax-rubl  ) ), input 2 ).
                run bgelib-tag-put in this-procedure ( input 1, "transportr" , input string( abs( buf_ot-tot-cost.transport-rubl ) ), input 2 ).
                run bgelib-tag-put in this-procedure ( input 1, "otherr"     , input string( abs( buf_ot-tot-cost.other-rubl     ) ), input 2 ).
                run bgelib-tag-put in this-procedure ( input 1, "exciser"    , input string( abs( buf_ot-tot-cost.excise-rubl    ) ), input 2 ).
                run bgelib-tag-put in this-procedure ( input 1, "sumb"       , input string( abs( buf_ot-tot-cost.sum-base       ) ), input 2 ).
                run bgelib-tag-put in this-procedure ( input 1, "VATb"       , input string( abs( buf_ot-tot-cost.vat-base       ) ), input 2 ).
                run bgelib-tag-put in this-procedure ( input 1, "SLTb"       , input string( abs( buf_ot-tot-cost.slt-base       ) ), input 2 ).
                run bgelib-tag-put in this-procedure ( input 1, "roadTaxb"   , input string( abs( buf_ot-tot-cost.road-tax-base  ) ), input 2 ).
                run bgelib-tag-put in this-procedure ( input 1, "transportb" , input string( abs( buf_ot-tot-cost.transport-base ) ), input 2 ).
                run bgelib-tag-put in this-procedure ( input 1, "otherb"     , input string( abs( buf_ot-tot-cost.other-base     ) ), input 2 ).
                run bgelib-tag-put in this-procedure ( input 1, "exciseb"    , input string( abs( buf_ot-tot-cost.excise-base    ) ), input 2 ).
                run bgelib-tag-close in this-procedure ( input 0, input "docCostSum" ).
            end.      /* available buf_ot-tot-cost  */
            else do:
                if available buf_ot-tot-sale
                then do:
                    run bgelib-write-log in this-procedure ( p-log-file-name, 1, "*** ERR: *** В архиве не найдена запись с sum-type = {&arh-cost} или {&arh-cost-service} для документа " + string( v-doc-code ) ).
                end.
            end.      /* NOT available buf_ot-tot-cost  */
            for each temp_cost_cat-id_ot-supp-tot no-lock
            on error undo, return error
            :
                delete temp_cost_cat-id_ot-supp-tot.
            end.
            for each temp_cost_cli_ot-supp-tot no-lock
            on error undo, return error
            :
                delete temp_cost_cli_ot-supp-tot.
            end.
            for each buf_cost_ot-supp-tot no-lock
               where buf_cost_ot-supp-tot.doc-code = v-doc-code
            on error undo, return error
            :
                if buf_cost_ot-supp-tot.sum-type = {&arh-cost} + {&arh-supp}
                then do:
                    find first temp_cost_cat-id_ot-supp-tot
                         where temp_cost_cat-id_ot-supp-tot.cat-id   = buf_cost_ot-supp-tot.cat-id
                    no-error.
                    if not available temp_cost_cat-id_ot-supp-tot
                    then do:
                        create temp_cost_cat-id_ot-supp-tot.
                        assign
                            temp_cost_cat-id_ot-supp-tot.cat-id   = buf_cost_ot-supp-tot.cat-id
                        .
                    end.        /* if not available temp_cost_cat-id_ot-supp-tot */
                    run fill_bgelib_clients in this-procedure (
                          input p-parent-handle
                        , input buf_cost_ot-supp-tot.cli-type
                        , input buf_cost_ot-supp-tot.cli-code
                    ).
                    find first temp_cost_cli_ot-supp-tot
                         where temp_cost_cli_ot-supp-tot.cat-id   = buf_cost_ot-supp-tot.cat-id
                           and temp_cost_cli_ot-supp-tot.cli-type = buf_cost_ot-supp-tot.cli-type
                           and temp_cost_cli_ot-supp-tot.cli-code = buf_cost_ot-supp-tot.cli-code
                    no-error.
                    if not available temp_cost_cli_ot-supp-tot
                    then do:
                        create temp_cost_cli_ot-supp-tot.
                        assign

                            temp_cost_cli_ot-supp-tot.cat-id            = buf_cost_ot-supp-tot.cat-id
                            temp_cost_cli_ot-supp-tot.cli-type          = buf_cost_ot-supp-tot.cli-type
                            temp_cost_cli_ot-supp-tot.cli-code          = buf_cost_ot-supp-tot.cli-code
                            temp_cost_cli_ot-supp-tot.sum-rubl          = buf_cost_ot-supp-tot.sum-rubl
                            temp_cost_cli_ot-supp-tot.vat-rubl          = buf_cost_ot-supp-tot.vat-rubl
                            temp_cost_cli_ot-supp-tot.slt-rubl          = buf_cost_ot-supp-tot.slt-rubl
                            temp_cost_cli_ot-supp-tot.road-tax-rubl     = buf_cost_ot-supp-tot.road-tax-rubl
                            temp_cost_cli_ot-supp-tot.transport-rubl    = buf_cost_ot-supp-tot.transport-rubl
                            temp_cost_cli_ot-supp-tot.other-rubl        = buf_cost_ot-supp-tot.other-rubl
                            temp_cost_cli_ot-supp-tot.excise-rubl       = buf_cost_ot-supp-tot.excise-rubl
                            temp_cost_cli_ot-supp-tot.sum-base          = buf_cost_ot-supp-tot.sum-base
                            temp_cost_cli_ot-supp-tot.vat-base          = buf_cost_ot-supp-tot.vat-base
                            temp_cost_cli_ot-supp-tot.slt-base          = buf_cost_ot-supp-tot.slt-base
                            temp_cost_cli_ot-supp-tot.road-tax-base     = buf_cost_ot-supp-tot.road-tax-base
                            temp_cost_cli_ot-supp-tot.transport-base    = buf_cost_ot-supp-tot.transport-base
                            temp_cost_cli_ot-supp-tot.other-base        = buf_cost_ot-supp-tot.other-base
                            temp_cost_cli_ot-supp-tot.excise-base       = buf_cost_ot-supp-tot.excise-base
                            temp_cost_cli_ot-supp-tot.fact-qnty         = buf_cost_ot-supp-tot.fact-qnty
                        .
                    end.
                end.
            end.      /* for each buf_cost_ot-supp-tot */
            for each temp_cost_cat-id_ot-supp-line no-lock
            on error undo, return error
            :
                delete temp_cost_cat-id_ot-supp-line.
            end.
            for each temp_cost_cli_ot-supp-line no-lock
            on error undo, return error
            :
                delete temp_cost_cli_ot-supp-line.
            end.
            for each buf_cost_ot-supp-line no-lock
               where buf_cost_ot-supp-line.doc-code = v-doc-code
            on error undo, return error
            :
                if buf_cost_ot-supp-line.sum-type = {&arh-cost} + {&arh-supp}
                then do:
                    find first temp_cost_cat-id_ot-supp-line
                         where temp_cost_cat-id_ot-supp-line.artic      = buf_cost_ot-supp-line.artic
                           and temp_cost_cat-id_ot-supp-line.prod-type  = buf_cost_ot-supp-line.prod-type
                           and temp_cost_cat-id_ot-supp-line.prod-code  = buf_cost_ot-supp-line.prod-code
                           and temp_cost_cat-id_ot-supp-line.cat-id     = buf_cost_ot-supp-line.cat-id
                    no-error.
                    if not available temp_cost_cat-id_ot-supp-line
                    then do:
                        create temp_cost_cat-id_ot-supp-line.
                        assign
                            temp_cost_cat-id_ot-supp-line.artic     = buf_cost_ot-supp-line.artic
                            temp_cost_cat-id_ot-supp-line.prod-type = buf_cost_ot-supp-line.prod-type
                            temp_cost_cat-id_ot-supp-line.prod-code = buf_cost_ot-supp-line.prod-code
                            temp_cost_cat-id_ot-supp-line.cat-id    = buf_cost_ot-supp-line.cat-id
                        .
                    end.        /* if not available temp_cost_cat-id_ot-supp-line */
                    run fill_bgelib_clients in this-procedure (
                          input p-parent-handle
                        , input buf_cost_ot-supp-line.cli-type
                        , input buf_cost_ot-supp-line.cli-code
                    ).
                    find first temp_cost_cli_ot-supp-line
                         where temp_cost_cli_ot-supp-line.artic      = buf_cost_ot-supp-line.artic
                           and temp_cost_cli_ot-supp-line.prod-type  = buf_cost_ot-supp-line.prod-type
                           and temp_cost_cli_ot-supp-line.prod-code  = buf_cost_ot-supp-line.prod-code
                           and temp_cost_cli_ot-supp-line.cat-id     = buf_cost_ot-supp-line.cat-id
                           and temp_cost_cli_ot-supp-line.cli-type   = buf_cost_ot-supp-line.cli-type
                           and temp_cost_cli_ot-supp-line.cli-code   = buf_cost_ot-supp-line.cli-code
                    no-error.
                    if not available temp_cost_cli_ot-supp-line
                    then do:
                        create temp_cost_cli_ot-supp-line.
                        assign
                            temp_cost_cli_ot-supp-line.artic             = buf_cost_ot-supp-line.artic
                            temp_cost_cli_ot-supp-line.prod-type         = buf_cost_ot-supp-line.prod-type
                            temp_cost_cli_ot-supp-line.prod-code         = buf_cost_ot-supp-line.prod-code
                            temp_cost_cli_ot-supp-line.cat-id            = buf_cost_ot-supp-line.cat-id
                            temp_cost_cli_ot-supp-line.cli-type          = buf_cost_ot-supp-line.cli-type
                            temp_cost_cli_ot-supp-line.cli-code          = buf_cost_ot-supp-line.cli-code
                            temp_cost_cli_ot-supp-line.sum-rubl          = buf_cost_ot-supp-line.sum-rubl
                            temp_cost_cli_ot-supp-line.vat-rubl          = buf_cost_ot-supp-line.vat-rubl
                            temp_cost_cli_ot-supp-line.slt-rubl          = buf_cost_ot-supp-line.slt-rubl
                            temp_cost_cli_ot-supp-line.road-tax-rubl     = buf_cost_ot-supp-line.road-tax-rubl
                            temp_cost_cli_ot-supp-line.transport-rubl    = buf_cost_ot-supp-line.transport-rubl
                            temp_cost_cli_ot-supp-line.other-rubl        = buf_cost_ot-supp-line.other-rubl
                            temp_cost_cli_ot-supp-line.excise-rubl       = buf_cost_ot-supp-line.excise-rubl
                            temp_cost_cli_ot-supp-line.sum-base          = buf_cost_ot-supp-line.sum-base
                            temp_cost_cli_ot-supp-line.vat-base          = buf_cost_ot-supp-line.vat-base
                            temp_cost_cli_ot-supp-line.slt-base          = buf_cost_ot-supp-line.slt-base
                            temp_cost_cli_ot-supp-line.road-tax-base     = buf_cost_ot-supp-line.road-tax-base
                            temp_cost_cli_ot-supp-line.transport-base    = buf_cost_ot-supp-line.transport-base
                            temp_cost_cli_ot-supp-line.other-base        = buf_cost_ot-supp-line.other-base
                            temp_cost_cli_ot-supp-line.excise-base       = buf_cost_ot-supp-line.excise-base
                            temp_cost_cli_ot-supp-line.fact-qnty         = buf_cost_ot-supp-line.fact-qnty
                        .
                    end.
                    else do:
                        run bgelib-write-log in this-procedure (  p-log-file-name,
                                                    1,
                                            "*** WARN: *** Найдено больше одной записи ot-supp-line для документа "
                                            + string( v-doc-code )
                        ).
                    end.
                end.        /* if buf_cost_ot-supp-line.sum-type = {&arh-cost} + {&arh-supp} */
            end.      /* for each buf_cost_ot-supp-line */
        end.      /* p-ext-doc-type <> {&TDEDT_Overturn}  */
        else do:
            /* Для переоценки не надо искать буфер cost */
        end.      /* NOT ( p-ext-doc-type <> {&TDEDT_Overturn}  ) */
        /* Продажные цены */
        run bgelib-tag-open in this-procedure ( input 0, input "docSaleSum", input "" ).
        run bgelib-tag-put in this-procedure ( input 1, input "docID" , string( v-doc-code )                                 , input 0 ).
        run bgelib-tag-put in this-procedure ( input 1, input "sumr"        , string( abs( buf_ot-tot-crsa-loop.sum-rubl        ) ), input 2 ).
        run bgelib-tag-put in this-procedure ( input 1, input "VATr"        , string( abs( buf_ot-tot-crsa-loop.vat-rubl        ) ), input 2 ).
        run bgelib-tag-put in this-procedure ( input 1, input "SLTr"        , string( abs( buf_ot-tot-crsa-loop.slt-rubl        ) ), input 2 ).
        run bgelib-tag-put in this-procedure ( input 1, input "roadTaxr"    , string( abs( buf_ot-tot-crsa-loop.road-tax-rubl   ) ), input 2 ).
        run bgelib-tag-put in this-procedure ( input 1, input "transportr"  , string( abs( buf_ot-tot-crsa-loop.transport-rubl  ) ), input 2 ).
        run bgelib-tag-put in this-procedure ( input 1, input "otherr"      , string( abs( buf_ot-tot-crsa-loop.other-rubl      ) ), input 2 ).
        run bgelib-tag-put in this-procedure ( input 1, input "exciser"     , string( abs( buf_ot-tot-crsa-loop.excise-rubl     ) ), input 2 ).
        run bgelib-tag-put in this-procedure ( input 1, input "sumb"        , string( abs( buf_ot-tot-crsa-loop.sum-base        ) ), input 2 ).
        run bgelib-tag-put in this-procedure ( input 1, input "VATb"        , string( abs( buf_ot-tot-crsa-loop.vat-base        ) ), input 2 ).
        run bgelib-tag-put in this-procedure ( input 1, input "SLTb"        , string( abs( buf_ot-tot-crsa-loop.slt-base        ) ), input 2 ).
        run bgelib-tag-put in this-procedure ( input 1, input "roadTaxb"    , string( abs( buf_ot-tot-crsa-loop.road-tax-base   ) ), input 2 ).
        run bgelib-tag-put in this-procedure ( input 1, input "transportb"  , string( abs( buf_ot-tot-crsa-loop.transport-base  ) ), input 2 ).
        run bgelib-tag-put in this-procedure ( input 1, input "otherb"      , string( abs( buf_ot-tot-crsa-loop.other-base      ) ), input 2 ).
        run bgelib-tag-put in this-procedure ( input 1, input "exciseb"     , string( abs( buf_ot-tot-crsa-loop.excise-base     ) ), input 2 ).
        run bgelib-tag-close in this-procedure ( input 0, input "docSaleSum" ).
        /* Для инвентаризации */
        if p-ext-doc-type = {&TDEDT_Inv}
        or p-ext-doc-type = {&TDEDT_Peresort}
        or p-ext-doc-type = {&TDEDT_Corr_Acc_Price}
        or p-ext-doc-type = {&TDEDT_Corr_Minus_Parts}
        then do:
            run utl/cuaddsum.p (
                input v-doc-code
            ) no-error.
            if error-status :error
            then do:
                run bgelib-write-log in this-procedure (
                      input p-log-file-name
                    , input 1
                    , input substitute( "*** WARN: *** Не удалось проверить документ инвентаризации N: &1. &2. &3. &4"
                                        , v-doc-code
                                        , return-value
                                        , trim(error-status :get-message(1))
                                        , trim(error-status :get-message(2))
                                    )
                ).
            end.
            run export-before-and-after-inv-trn in this-procedure (
                  input v-doc-code
                , output v-exists-before
                , output v-exists-after
            ).
        end.        /* if p-ext-doc-type = {&TDEDT_Inv} */
        if p-pay-code = yes
        then do:    /* По поставщикам */
            for each temp_cost_cat-id_ot-supp-tot
            on error undo, return error
            :
                for each temp_cost_cli_ot-supp-tot
                where temp_cost_cli_ot-supp-tot.cat-id = temp_cost_cat-id_ot-supp-tot.cat-id
                on error undo, return error
                :
                    run fill_bgelib_clients in this-procedure (
                          input p-parent-handle
                        , input temp_cost_cli_ot-supp-tot.cli-type
                        , input temp_cost_cli_ot-supp-tot.cli-code
                    ).
                    run bgelib-tag-open in this-procedure ( input 0, "docPaySupp", "" ).
                    run bgelib-tag-put in this-procedure ( input 1, input "docID" , input string( v-doc-code )                            , input 0 ).
                    run bgelib-tag-put in this-procedure ( input 1, input "payCode"     , input string( temp_cost_cat-id_ot-supp-tot.cat-id )   , input 0 ).
                    run bgelib-tag-put in this-procedure ( input 1, input "firmType"    , input string( temp_cost_cli_ot-supp-tot.cli-type )    , input 2 ).
                    run bgelib-tag-put in this-procedure ( input 1, input "firmCode"    , input string( temp_cost_cli_ot-supp-tot.cli-code )    , input 2 ).
                    if temp_cost_cli_ot-supp-tot.sum-rubl < 0
                    then do:
                        run bgelib-tag-put in this-procedure ( input 1, input "sign", input "-1", input 0 ).
                    end.
                    run bgelib-tag-put in this-procedure ( input 1, "costSumr"        , input string( abs( temp_cost_cli_ot-supp-tot.sum-rubl         ) ), input 2 ).
                    run bgelib-tag-put in this-procedure ( input 1, "costVatr"        , input string( abs( temp_cost_cli_ot-supp-tot.vat-rubl         ) ), input 2 ).
                    run bgelib-tag-put in this-procedure ( input 1, "costSltr"        , input string( abs( temp_cost_cli_ot-supp-tot.slt-rubl         ) ), input 2 ).
                    run bgelib-tag-put in this-procedure ( input 1, "costRoadtaxr"    , input string( abs( temp_cost_cli_ot-supp-tot.road-tax-rubl    ) ), input 2 ).
                    run bgelib-tag-put in this-procedure ( input 1, "costTransportr"  , input string( abs( temp_cost_cli_ot-supp-tot.transport-rubl   ) ), input 2 ).
                    run bgelib-tag-put in this-procedure ( input 1, "costOtherr"      , input string( abs( temp_cost_cli_ot-supp-tot.other-rubl       ) ), input 2 ).
                    run bgelib-tag-put in this-procedure ( input 1, "costExciser"     , input string( abs( temp_cost_cli_ot-supp-tot.excise-rubl      ) ), input 2 ).
                    run bgelib-tag-put in this-procedure ( input 1, "costSumb"        , input string( abs( temp_cost_cli_ot-supp-tot.sum-base         ) ), input 2 ).
                    run bgelib-tag-put in this-procedure ( input 1, "costVatb"        , input string( abs( temp_cost_cli_ot-supp-tot.vat-base         ) ), input 2 ).
                    run bgelib-tag-put in this-procedure ( input 1, "costSltb"        , input string( abs( temp_cost_cli_ot-supp-tot.slt-base         ) ), input 2 ).
                    run bgelib-tag-put in this-procedure ( input 1, "costRoadtaxb"    , input string( abs( temp_cost_cli_ot-supp-tot.road-tax-base    ) ), input 2 ).
                    run bgelib-tag-put in this-procedure ( input 1, "costTransportb"  , input string( abs( temp_cost_cli_ot-supp-tot.transport-base   ) ), input 2 ).
                    run bgelib-tag-put in this-procedure ( input 1, "costOtherb"      , input string( abs( temp_cost_cli_ot-supp-tot.other-base       ) ), input 2 ).
                    run bgelib-tag-put in this-procedure ( input 1, "costExciseb"     , input string( abs( temp_cost_cli_ot-supp-tot.excise-base      ) ), input 2 ).
                    find first buf_sale_ot-supp-tot no-lock
                        where buf_sale_ot-supp-tot.doc-code = v-doc-code
                        and buf_sale_ot-supp-tot.cli-type = temp_cost_cli_ot-supp-tot.cli-type
                        and buf_sale_ot-supp-tot.cli-code = temp_cost_cli_ot-supp-tot.cli-code
                        and buf_sale_ot-supp-tot.sum-type = {&arh-sale}
                        and buf_sale_ot-supp-tot.cat-id   = {&single-cat-id}
                    no-error.
                    if available buf_sale_ot-supp-tot
                    then do:
                        if buf_sale_ot-supp-tot.sum-rubl < 0
                        then do:
                            run bgelib-tag-put in this-procedure ( input 1, input "sign", input "-1", input 0 ).
                        end.
                        run bgelib-tag-put in this-procedure ( input 1, input "docSumr"      , input string( abs( buf_sale_ot-supp-tot.sum-rubl       ) / buf_sale_ot-supp-tot.fact-qnty  * temp_cost_cli_ot-supp-tot.fact-qnty ), input 2 ).
                        run bgelib-tag-put in this-procedure ( input 1, input "docVatr"      , input string( abs( buf_sale_ot-supp-tot.vat-rubl       ) / buf_sale_ot-supp-tot.fact-qnty  * temp_cost_cli_ot-supp-tot.fact-qnty ), input 2 ).
                        run bgelib-tag-put in this-procedure ( input 1, input "docSltr"      , input string( abs( buf_sale_ot-supp-tot.slt-rubl       ) / buf_sale_ot-supp-tot.fact-qnty  * temp_cost_cli_ot-supp-tot.fact-qnty ), input 2 ).
                        run bgelib-tag-put in this-procedure ( input 1, input "docRoadtaxr"  , input string( abs( buf_sale_ot-supp-tot.road-tax-rubl  ) / buf_sale_ot-supp-tot.fact-qnty  * temp_cost_cli_ot-supp-tot.fact-qnty ), input 2 ).
                        run bgelib-tag-put in this-procedure ( input 1, input "docTransportr", input string( abs( buf_sale_ot-supp-tot.transport-rubl ) / buf_sale_ot-supp-tot.fact-qnty  * temp_cost_cli_ot-supp-tot.fact-qnty ), input 2 ).
                        run bgelib-tag-put in this-procedure ( input 1, input "docOtherr"    , input string( abs( buf_sale_ot-supp-tot.other-rubl     ) / buf_sale_ot-supp-tot.fact-qnty  * temp_cost_cli_ot-supp-tot.fact-qnty ), input 2 ).
                        run bgelib-tag-put in this-procedure ( input 1, input "docExciser"   , input string( abs( buf_sale_ot-supp-tot.excise-rubl    ) / buf_sale_ot-supp-tot.fact-qnty  * temp_cost_cli_ot-supp-tot.fact-qnty ), input 2 ).
                        run bgelib-tag-put in this-procedure ( input 1, input "docSumb"      , input string( abs( buf_sale_ot-supp-tot.sum-base       ) / buf_sale_ot-supp-tot.fact-qnty  * temp_cost_cli_ot-supp-tot.fact-qnty ), input 2 ).
                        run bgelib-tag-put in this-procedure ( input 1, input "docVatb"      , input string( abs( buf_sale_ot-supp-tot.vat-base       ) / buf_sale_ot-supp-tot.fact-qnty  * temp_cost_cli_ot-supp-tot.fact-qnty ), input 2 ).
                        run bgelib-tag-put in this-procedure ( input 1, input "docSltb"      , input string( abs( buf_sale_ot-supp-tot.slt-base       ) / buf_sale_ot-supp-tot.fact-qnty  * temp_cost_cli_ot-supp-tot.fact-qnty ), input 2 ).
                        run bgelib-tag-put in this-procedure ( input 1, input "docRoadtaxb"  , input string( abs( buf_sale_ot-supp-tot.road-tax-base  ) / buf_sale_ot-supp-tot.fact-qnty  * temp_cost_cli_ot-supp-tot.fact-qnty ), input 2 ).
                        run bgelib-tag-put in this-procedure ( input 1, input "docTransportb", input string( abs( buf_sale_ot-supp-tot.transport-base ) / buf_sale_ot-supp-tot.fact-qnty  * temp_cost_cli_ot-supp-tot.fact-qnty ), input 2 ).
                        run bgelib-tag-put in this-procedure ( input 1, input "docOtherb"    , input string( abs( buf_sale_ot-supp-tot.other-base     ) / buf_sale_ot-supp-tot.fact-qnty  * temp_cost_cli_ot-supp-tot.fact-qnty ), input 2 ).
                        run bgelib-tag-put in this-procedure ( input 1, input "docExciseb"   , input string( abs( buf_sale_ot-supp-tot.excise-base    ) / buf_sale_ot-supp-tot.fact-qnty  * temp_cost_cli_ot-supp-tot.fact-qnty ), input 2 ).
                    end.        /* available buf_sale_ot-supp-line */
                    run bgelib-tag-close in this-procedure ( input 0,  input "docPaySupp" ).
                end.        /* for each temp_cost_cli_ot-supp-tot */
            end.      /* for each temp_cost_cat-id_ot-supp-tot */
        end.        /* if p-pay-code = yes */
    /* Обработка строк документа */
        for each buf_ot-line-crsa-loop no-lock
           where buf_ot-line-crsa-loop.doc-code = v-doc-code
             and ( buf_ot-line-crsa-loop.sum-type = {&arh-crsa}
                or buf_ot-line-crsa-loop.sum-type = {&arh-crsa-service} )
        on error undo, return error
        :
/*            for each buf_ot-line-sale no-lock*/
/*               where buf_ot-line-sale.doc-code = v-doc-code*/
/*                 and buf_ot-line-sale.sum-type = buf_ot-tot-sale.sum-type*/
/*            on error undo, return error*/
/*            :*/
            run bgelib-tag-open in this-procedure ( input 0, input "line", input "" ).
            run bgelib-tag-put in this-procedure ( input 1, input "docID",  input v-doc-code, input 0 ).
            find first buf_goods no-lock
                 where buf_goods.artic      = buf_ot-line-crsa-loop.artic
                   and buf_goods.prod-type  = buf_ot-line-crsa-loop.prod-type
                   and buf_goods.prod-code  = buf_ot-line-crsa-loop.prod-code
            no-error.
            if available buf_goods
            then do:
                assign
                    v-good-code = string( buf_goods.gds-code )
                    v-good-type = string( buf_goods.gds-type )
                .
                run fill_bgelib_goods in this-procedure (
                      input p-parent-handle
                    , input buf_goods.gds-code
                ).
            end.      /* available goods  */
            else do:
                assign
                    v-good-code = ""
                    v-good-type = ""
                .
            end.      /* NOT available goods  */
            run bgelib-tag-put in this-procedure ( input 1, input "goodID",    input v-good-code, input 0 ).
            run bgelib-tag-put in this-procedure ( input 1, input "type",    input v-good-type, input 0 ).
            find first buf_units no-lock
                 where buf_units.unit-name  = buf_goods.unit-base
            no-error.
            if available buf_units
            then do:
                run bgelib-tag-put in this-procedure ( input 1, input "unitType",    input string( buf_units.type ), input 0 ).
            end.      /* available units */
            else do:
                    run bgelib-tag-put in this-procedure ( input 1, input "unitType",   input "",   input 0 ).
            end.      /* NOT available units */
            if p-ext-doc-type <> {&TDEDT_Overturn}
            then do:
                { str/is-petrl.i
                        buf_ot-line-crsa-loop.artic
                        buf_ot-line-crsa-loop.prod-type
                        buf_ot-line-crsa-loop.prod-code
                        v-is-petrol
                        v-is-pieces
                }
                find first buf_doc-line no-lock
                    where buf_doc-line.doc-code = v-doc-code
                      and buf_doc-line.artic      = buf_ot-line-crsa-loop.artic
                      and buf_doc-line.prod-type  = buf_ot-line-crsa-loop.prod-type
                      and buf_doc-line.prod-code  = buf_ot-line-crsa-loop.prod-code
                no-error.
                if available buf_doc-line
                then do:
                    run bgelib-tag-put in this-procedure ( input 1, input "wait"        , input string( buf_doc-line.wt-brutto      ), input 0 ).
                    run bgelib-tag-put in this-procedure ( input 1, input "place"       , input string( buf_doc-line.num-place      ), input 0 ).
                    run bgelib-tag-put in this-procedure ( input 1, input "priceCli"    , input string( buf_doc-line.price-cli      ), input 0 ).
                    run bgelib-tag-put in this-procedure ( input 1, input "cliBaseRate" , input string( buf_doc-line.cli-base-rate  ), input 0 ).
                    /*---START--------- Для топлива дополнительно экспортировать вес ---------------------*/
                    if v-is-petrol  = yes
                    and v-is-pieces = no
                    then do:
                        run get-petrol-weight in this-procedure
                        (
                              input p-ext-doc-type
                            , input recid( buf_doc-line )
                            , input buf_trn-doc.out-code
                            , output v-petrol-weight
                            , output v-weight-not-specified
                        ).
                        if v-weight-not-specified = no
                        then do:
                            assign
                                v-petrol-density = ( if buf_ot-line-crsa-loop.fact-qnty = 0
                                                        then 0
                                                        else v-petrol-weight / buf_ot-line-crsa-loop.fact-qnty )
                            .
                            run bgelib-tag-put in this-procedure ( input 1, input "petrolWeight", input string( v-petrol-weight ), input 0 ).
                        end.
                    end.                                   define variable v-before-qnty      as decimal      no-undo.
                    define variable v-after-qnty       as decimal      no-undo.
                    define variable v-diff-qnty        as decimal      no-undo.
                    define variable v-abs-diff-qnty    as decimal      no-undo.
                    { str/getwtqty.i
                        buf_doc-line.doc-code
                        buf_doc-line.artic
                        buf_doc-line.prod-type
                        buf_doc-line.prod-code
                        v-before-qnty
                        v-after-qnty
                        v-diff-qnty
                        v-abs-diff-qnty
                        no-error
                    }
                    if error-status :error
                    then do:
                        run bgelib-write-log in this-procedure (
                              input p-log-file-name
                            , input 1
                            , input substitute( "*** ERR: *** Ошибка вычисления количеств до и после для топлива. Документ &1. Товар &2 &3 &4. &5. &6. &7. &8."
                                                    , buf_doc-line.doc-code
                                                    , buf_doc-line.artic
                                                    , buf_doc-line.prod-type
                                                    , buf_doc-line.prod-code
                                                    , return-value
                                                    , trim(error-status :get-message(1))
                                                    , trim(error-status :get-message(2))
                                                    , trim(error-status :get-message(3)) )
                        ).
                    end.
                    else do:
                        run bgelib-tag-put in this-procedure ( input 4, input "petrolBeforeQnty"  , input string( v-before-qnty     ), input 1 ).
                        run bgelib-tag-put in this-procedure ( input 4, input "petrolAfterQnty"   , input string( v-after-qnty      ), input 1 ).
                        run bgelib-tag-put in this-procedure ( input 4, input "petrolDiffQnty"    , input string( v-diff-qnty       ), input 1 ).
                        run bgelib-tag-put in this-procedure ( input 4, input "petrolAbsDiffQnty" , input string( v-abs-diff-qnty   ), input 1 ).
                    end.
                    /*---END----------- Для топлива дополнительно экспортировать вес ---------------------*/
                end.      /* available buf_doc-line  */
                else do:
                    run bgelib-write-log in this-procedure (
                          input p-log-file-name
                        , input 1
                        , input substitute( "*** ERR: *** Не найдена строка документа &1. Товар &2 &3 &4."
                                            , v-doc-code
                                            , buf_ot-line-crsa-loop.artic
                                            , buf_ot-line-crsa-loop.prod-type
                                            , buf_ot-line-crsa-loop.prod-code
                                           )
                    ).
                end.      /* NOT ( available buf_doc-line  ) */
            end.      /* p-ext-doc-type <> {&TDEDT_Overturn} */
            else do:
                /* Строки переоценки искать не нужно */
            end.      /* NOT ( p-ext-doc-type <> {&TDEDT_Overturn} ) */
            if p-ext-doc-type = {&TDEDT_Inv}
            or p-ext-doc-type = {&TDEDT_Peresort}
            or p-ext-doc-type = {&TDEDT_Corr_Acc_Price}
            or p-ext-doc-type = {&TDEDT_Corr_Minus_Parts}
            then do:
                assign
                    v-qnty = buf_ot-line-crsa-loop.fact-qnty
                .
            end.
            else do:
                assign
                    v-qnty = abs( buf_ot-line-crsa-loop.fact-qnty )
                .
            end.
            run bgelib-tag-put in this-procedure ( input 1, input "qnty", input string( v-qnty )  , input 0 ).
            run bgelib-tag-put in this-procedure ( input 1, input "comment" , input string( buf_goods.ps ), input 0 ).
            run bgelib-tag-close in this-procedure ( input 0, input "line" ).
    /*--S------- Для всех кроме переоценки выводим строку ГТД и количество ----------*/
            if p-ext-doc-type <> {&TDEDT_Overturn}
            then do:
                { gbl/gdsat.i
                    buf_goods.artic
                    buf_goods.prod-type
                    buf_goods.prod-code
                    'empty-scale=request':u
                    v-scale-is-empty
                }
                if v-scale-is-empty = no
                then do:
                    run export-gds-dtl in this-procedure (
                          input p-ext-doc-type
                        , input v-doc-code
                        , input buf_goods.gds-code
                        , input buf_goods.artic
                        , input buf_goods.prod-type
                        , input buf_goods.prod-code
                    ) no-error.
                    if error-status :error
                    then do:
                        run bgelib-write-log in this-procedure (
                              input p-log-file-name
                            , input 1
                            , input substitute( "*** ERR: *** Ошибка выгрузки признаков." )
                        ).
                    end.
                end.
                if p-cst = yes
                or p-parts = yes
                then do:        /* Надо экспортировать номера ГТД или партии */
                    run export-parts in this-procedure (
                          input v-doc-code
                        , input ( if available buf_goods then buf_goods.gds-code else 0 )
                        , input buf_ot-line-crsa-loop.obj-type
                        , input buf_ot-line-crsa-loop.obj-code
                        , input buf_ot-line-crsa-loop.prod-type
                        , input buf_ot-line-crsa-loop.prod-code
                        , input buf_ot-line-crsa-loop.artic
                    ).
                end.        /* if p-ext-doc-type <> {&TDEDT_Overturn} */
                /*---START--------- дополнительно экспортируем разброску по типам кассовых платежей----------*/
                if p-chk-pay-code = yes
                then do:
                    run export-chk-pay-code in this-procedure (
                          input recid( buf_doc-line )
                        , input v-doc-code
                        , input buf_trn-doc.out-code
                        , input v-is-petrol
                        , input v-is-pieces
                        , input buf_goods.gds-code
                        , input buf_goods.gds-type
                    ).
                end. /* p-chk-pay-code = yes*/
            end.        /* p-ext-doc-type <> {&TDEDT_Overturn} */
            else do:
                /* Для переоценки не надо пытыться выгрузить ГТД */
            end.        /* NOT ( p-ext-doc-type <> {&TDEDT_Overturn} ) */
    /*--E------- Для всех кроме переоценки выводим строку ГТД и количество ----------*/
            if available buf_ot-tot-sale
            then do:        /* Цены документа */
                find first buf_ot-line-sale no-lock
                     where buf_ot-line-sale.doc-code    = v-doc-code
                       and buf_ot-line-sale.artic       = buf_ot-line-crsa-loop.artic
                       and buf_ot-line-sale.prod-type   = buf_ot-line-crsa-loop.prod-type
                       and buf_ot-line-sale.prod-code   = buf_ot-line-crsa-loop.prod-code
                       and buf_ot-line-sale.sum-type    = buf_ot-tot-sale.sum-type
                no-error.
                if available buf_ot-line-sale
                then do:
                    run bgelib-tag-open in this-procedure ( input 0, input "lineDocSum", input "" ).
                    run bgelib-tag-put in this-procedure ( input 1, input "docID" , input v-doc-code                                      , input 0 ).
                    run bgelib-tag-put in this-procedure ( input 1, input "goodID"        , input v-good-code                                     , input 0 ).
                    run bgelib-tag-put in this-procedure ( input 1, input "rateVAT"     , input string( entry( 1, buf_ot-line-sale.cat-id ) )   , input 2 ).
                    run bgelib-tag-put in this-procedure ( input 1, input "rateSLT"     , input string( entry( 2, buf_ot-line-sale.cat-id ) )   , input 2 ).
                    if p-ext-doc-type = {&TDEDT_Overturn}
                    then do:
                            run bgelib-tag-put in this-procedure ( input 1, input "sumr"      , input string( buf_ot-line-sale.sum-rubl         ), input 2 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "VATr"      , input string( buf_ot-line-sale.vat-rubl         ), input 2 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "SLTr"      , input string( buf_ot-line-sale.slt-rubl         ), input 2 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "roadTaxr"  , input string( buf_ot-line-sale.road-tax-rubl    ), input 2 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "transportr", input string( buf_ot-line-sale.transport-rubl   ), input 2 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "otherr"    , input string( buf_ot-line-sale.other-rubl       ), input 2 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "exciser"   , input string( buf_ot-line-sale.excise-rubl      ), input 2 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "sumb"      , input string( buf_ot-line-sale.sum-base         ), input 2 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "VATb"      , input string( buf_ot-line-sale.vat-base         ), input 2 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "SLTb"      , input string( buf_ot-line-sale.slt-base         ), input 2 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "roadTaxb"  , input string( buf_ot-line-sale.road-tax-base    ), input 2 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "transportb", input string( buf_ot-line-sale.transport-base   ), input 2 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "otherb"    , input string( buf_ot-line-sale.other-base       ), input 2 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "exciseb"   , input string( buf_ot-line-sale.excise-base      ), input 2 ).
                    end.      /* p-ext-doc-type = {&TDEDT_Overturn}  */
                    else do:
                            run bgelib-tag-put in this-procedure ( input 1, input "sumr"      , input string( abs( buf_ot-line-sale.sum-rubl       ) ), input 2 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "VATr"      , input string( abs( buf_ot-line-sale.vat-rubl       ) ), input 2 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "SLTr"      , input string( abs( buf_ot-line-sale.slt-rubl       ) ), input 2 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "roadTaxr"  , input string( abs( buf_ot-line-sale.road-tax-rubl  ) ), input 2 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "transportr", input string( abs( buf_ot-line-sale.transport-rubl ) ), input 2 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "otherr"    , input string( abs( buf_ot-line-sale.other-rubl     ) ), input 2 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "exciser"   , input string( abs( buf_ot-line-sale.excise-rubl    ) ), input 2 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "sumb"      , input string( abs( buf_ot-line-sale.sum-base       ) ), input 2 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "VATb"      , input string( abs( buf_ot-line-sale.vat-base       ) ), input 2 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "SLTb"      , input string( abs( buf_ot-line-sale.slt-base       ) ), input 2 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "roadTaxb"  , input string( abs( buf_ot-line-sale.road-tax-base  ) ), input 2 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "transportb", input string( abs( buf_ot-line-sale.transport-base ) ), input 2 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "otherb"    , input string( abs( buf_ot-line-sale.other-base     ) ), input 2 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "exciseb"   , input string( abs( buf_ot-line-sale.excise-base    ) ), input 2 ).
                    end.      /* NOT ( p-ext-doc-type = {&TDEDT_Overturn} ) */
                    run bgelib-tag-close in this-procedure ( input 0, input "lineDocSum" ).
                end.        /* if available buf_ot-line-sale */
                else do:
                    /*
                    if p-ext-doc-type <> {&TDEDT_Inv}
                    then do:
                        run bgelib-write-log in this-procedure ( p-log-file-name, 1, "В архиве не найдена cтрока документа с sum-type = {&arh-sale} или {&arh-crsa} для документа номер " + string( v-doc-code ) + " ( ext-doc-type = " + p-ext-doc-type + ")" + ", артикул товара " + buf_ot-line-crsa-loop.artic ).
                    end.
                    */
                end.        /* if NOT( available buf_ot-line-sale ) */
            end.        /* if available buf_ot-tot-sale */
            /* Учетные цены */
            if p-ext-doc-type <> {&TDEDT_Overturn}
            then do:
                if available buf_ot-tot-cost
                then do:
                    find first buf_ot-line-cost no-lock
                            where buf_ot-line-cost.doc-code   = v-doc-code
                            and buf_ot-line-cost.artic      = buf_ot-line-crsa-loop.artic
                            and buf_ot-line-cost.prod-type  = buf_ot-line-crsa-loop.prod-type
                            and buf_ot-line-cost.prod-code  = buf_ot-line-crsa-loop.prod-code
                            and buf_ot-line-cost.sum-type   = buf_ot-tot-cost.sum-type
                    no-error.
                    if available buf_ot-line-cost
                    then do:
                            run bgelib-tag-open in this-procedure ( input 0, input "lineCostSum", input "" ).
                            run bgelib-tag-put in this-procedure ( input 1, input "docID" , input v-doc-code                                      , input 0 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "goodID"        , input v-good-code                                     , input 0 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "sumr"        , input string( abs( buf_ot-line-cost.sum-rubl       ) ), input 2 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "VATr"        , input string( abs( buf_ot-line-cost.vat-rubl       ) ), input 2 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "SLTr"        , input string( abs( buf_ot-line-cost.slt-rubl       ) ), input 2 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "roadTaxr"    , input string( abs( buf_ot-line-cost.road-tax-rubl  ) ), input 2 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "transportr"  , input string( abs( buf_ot-line-cost.transport-rubl ) ), input 2 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "otherr"      , input string( abs( buf_ot-line-cost.other-rubl     ) ), input 2 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "exciser"     , input string( abs( buf_ot-line-cost.excise-rubl    ) ), input 2 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "sumb"        , input string( abs( buf_ot-line-cost.sum-base       ) ), input 2 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "VATb"        , input string( abs( buf_ot-line-cost.vat-base       ) ), input 2 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "SLTb"        , input string( abs( buf_ot-line-cost.slt-base       ) ), input 2 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "roadTaxb"    , input string( abs( buf_ot-line-cost.road-tax-base  ) ), input 2 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "transportb"  , input string( abs( buf_ot-line-cost.transport-base ) ), input 2 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "otherb"      , input string( abs( buf_ot-line-cost.other-base     ) ), input 2 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "exciseb"     , input string( abs( buf_ot-line-cost.excise-base    ) ), input 2 ).
                            run bgelib-tag-close in this-procedure ( input 0, input "lineCostSum" ).
                    end.      /* available buf_ot-line-cost */
                    else do:
/*                        run bgelib-write-log in this-procedure ( p-log-file-name, 1, "Не найден ot-line с sum-type = {&arh-cost} или {&arh-cost-service} для документа " + string( v-doc-code ) + ", артикул товара " + string( buf_ot-line-crsa-loop.artic ) ).*/
                    end.      /* NOT ( available buf_ot-line-cost ) */
                end.        /* available buf_ot-tot-cost  */
                else do:
                    /* Если нет cost для документа, не надо искать и для строк. */
                end.        /* NOT ( available buf_ot-tot-cost  ) */
            end.      /* p-ext-doc-type <> {&TDEDT_Overturn} */
            else do:
                /* Для переоценки не надо искать cost */
            end.      /* NOT ( p-ext-doc-type <> {&TDEDT_Overturn} ) */
            /* Продажные цены */
            run bgelib-tag-open in this-procedure ( input 0, input "lineSaleSum", input "" ).
            run bgelib-tag-put in this-procedure ( input 1, input "docID" , input v-doc-code                                           , input 0 ).
            run bgelib-tag-put in this-procedure ( input 1, input "goodID"        , input v-good-code                                          , input 0 ).
            run bgelib-tag-put in this-procedure ( input 1, input "sumr"        , input string( abs( buf_ot-line-crsa-loop.sum-rubl       ) ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "VATr"        , input string( abs( buf_ot-line-crsa-loop.vat-rubl       ) ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "SLTr"        , input string( abs( buf_ot-line-crsa-loop.slt-rubl       ) ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "roadTaxr"    , input string( abs( buf_ot-line-crsa-loop.road-tax-rubl  ) ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "transportr"  , input string( abs( buf_ot-line-crsa-loop.transport-rubl ) ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "otherr"      , input string( abs( buf_ot-line-crsa-loop.other-rubl     ) ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "exciser"     , input string( abs( buf_ot-line-crsa-loop.excise-rubl    ) ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "sumb"        , input string( abs( buf_ot-line-crsa-loop.sum-base       ) ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "VATb"        , input string( abs( buf_ot-line-crsa-loop.vat-base       ) ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "SLTb"        , input string( abs( buf_ot-line-crsa-loop.slt-base       ) ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "roadTaxb"    , input string( abs( buf_ot-line-crsa-loop.road-tax-base  ) ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "transportb"  , input string( abs( buf_ot-line-crsa-loop.transport-base ) ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "otherb"      , input string( abs( buf_ot-line-crsa-loop.other-base     ) ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "exciseb"     , input string( abs( buf_ot-line-crsa-loop.excise-base    ) ), input 2 ).
            run bgelib-tag-close in this-procedure ( input 0, input "lineSaleSum" ).
            /* Для инвентаризации */
            if p-ext-doc-type = {&TDEDT_Inv}
            or p-ext-doc-type = {&TDEDT_Peresort}
            or p-ext-doc-type = {&TDEDT_Corr_Acc_Price}
            or p-ext-doc-type = {&TDEDT_Corr_Minus_Parts}
            then do:
                run export-before-and-after-inv-line in this-procedure (
                      input v-doc-code
                    , input buf_goods.gds-code
                    , input v-exists-before
                    , input v-exists-after
                    , input ( v-is-petrol = yes and v-is-pieces = no and v-weight-not-specified  = no )
                    , input v-petrol-density
                ).
            end.        /* if p-ext-doc-type = {&TDEDT_Inv} */
            /* По поставщикам */
            if p-ext-doc-type <> {&TDEDT_Overturn}
            then do:
                if p-pay-code = yes
                then do:
                    for each temp_cost_cat-id_ot-supp-line
                        where temp_cost_cat-id_ot-supp-line.artic        = buf_ot-line-crsa-loop.artic
                            and temp_cost_cat-id_ot-supp-line.prod-type    = buf_ot-line-crsa-loop.prod-type
                            and temp_cost_cat-id_ot-supp-line.prod-code    = buf_ot-line-crsa-loop.prod-code
                    on error undo, return error
                    :
                        for each temp_cost_cli_ot-supp-line
                        where temp_cost_cli_ot-supp-line.artic        = temp_cost_cat-id_ot-supp-line.artic
                            and temp_cost_cli_ot-supp-line.prod-type  = temp_cost_cat-id_ot-supp-line.prod-type
                            and temp_cost_cli_ot-supp-line.prod-code  = temp_cost_cat-id_ot-supp-line.prod-code
                            and temp_cost_cli_ot-supp-line.cat-id     = temp_cost_cat-id_ot-supp-line.cat-id
                        on error undo, return error
                        :
                            run fill_bgelib_clients in this-procedure (
                                  input p-parent-handle
                                , input temp_cost_cli_ot-supp-line.cli-type
                                , input temp_cost_cli_ot-supp-line.cli-code
                            ).
                            run bgelib-tag-open in this-procedure ( input 0, input "linePaySupp", input "" ).
                            run bgelib-tag-put in this-procedure ( input 1, input "docID" , input v-doc-code                                    , input 0 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "goodID"        , input v-good-code                                   , input 0 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "payCode"     , input string( temp_cost_cat-id_ot-supp-line.cat-id ), input 0 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "firmType"    , input string( temp_cost_cli_ot-supp-line.cli-type ) , input 2 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "firmCode"    , input string( temp_cost_cli_ot-supp-line.cli-code ) , input 2 ).
                            if temp_cost_cli_ot-supp-line.sum-rubl < 0
                            then do:
                                run bgelib-tag-put in this-procedure ( input 1, input "sign", input "-1", input 0 ).
                            end.
                            run bgelib-tag-put in this-procedure ( input 1, input "costSumr"       , input string( abs( temp_cost_cli_ot-supp-line.sum-rubl         ) ), input 2 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "costVatr"       , input string( abs( temp_cost_cli_ot-supp-line.vat-rubl         ) ), input 2 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "costSltr"       , input string( abs( temp_cost_cli_ot-supp-line.slt-rubl         ) ), input 2 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "costRoadtaxr"   , input string( abs( temp_cost_cli_ot-supp-line.road-tax-rubl    ) ), input 2 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "costTransportr" , input string( abs( temp_cost_cli_ot-supp-line.transport-rubl   ) ), input 2 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "costOtherr"     , input string( abs( temp_cost_cli_ot-supp-line.other-rubl       ) ), input 2 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "costExciser"    , input string( abs( temp_cost_cli_ot-supp-line.excise-rubl      ) ), input 2 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "costSumb"       , input string( abs( temp_cost_cli_ot-supp-line.sum-base         ) ), input 2 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "costVatb"       , input string( abs( temp_cost_cli_ot-supp-line.vat-base         ) ), input 2 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "costSltb"       , input string( abs( temp_cost_cli_ot-supp-line.slt-base         ) ), input 2 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "costRoadtaxb"   , input string( abs( temp_cost_cli_ot-supp-line.road-tax-base    ) ), input 2 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "costTransportb" , input string( abs( temp_cost_cli_ot-supp-line.transport-base   ) ), input 2 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "costOtherb"     , input string( abs( temp_cost_cli_ot-supp-line.other-base       ) ), input 2 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "costExciseb"    , input string( abs( temp_cost_cli_ot-supp-line.excise-base      ) ), input 2 ).
                            find first buf_sale_ot-supp-line no-lock
                                    where buf_sale_ot-supp-line.doc-code    = v-doc-code
                                    and buf_sale_ot-supp-line.cli-type    = temp_cost_cli_ot-supp-line.cli-type
                                    and buf_sale_ot-supp-line.cli-code    = temp_cost_cli_ot-supp-line.cli-code
                                    and buf_sale_ot-supp-line.artic       = temp_cost_cli_ot-supp-line.artic
                                    and buf_sale_ot-supp-line.prod-type   = temp_cost_cli_ot-supp-line.prod-type
                                    and buf_sale_ot-supp-line.prod-code   = temp_cost_cli_ot-supp-line.prod-code
                                    and buf_sale_ot-supp-line.sum-type    = {&arh-sale}
                                    and buf_sale_ot-supp-line.cat-id      = {&single-cat-id}
                            no-error.
                            if available buf_sale_ot-supp-line
                            then do:
                                if buf_sale_ot-supp-line.sum-rubl < 0
                                then do:
                                    run bgelib-tag-put in this-procedure ( input 1, input "sign", input "-1", input 0 ).
                                end.
                                run bgelib-tag-put in this-procedure ( input 1, input "docSumr"      , input string( abs( buf_sale_ot-supp-line.sum-rubl         ) / buf_sale_ot-supp-line.fact-qnty  * temp_cost_cli_ot-supp-line.fact-qnty ), input 2 ).
                                run bgelib-tag-put in this-procedure ( input 1, input "docVatr"      , input string( abs( buf_sale_ot-supp-line.vat-rubl         ) / buf_sale_ot-supp-line.fact-qnty  * temp_cost_cli_ot-supp-line.fact-qnty ), input 2 ).
                                run bgelib-tag-put in this-procedure ( input 1, input "docSltr"      , input string( abs( buf_sale_ot-supp-line.slt-rubl         ) / buf_sale_ot-supp-line.fact-qnty  * temp_cost_cli_ot-supp-line.fact-qnty ), input 2 ).
                                run bgelib-tag-put in this-procedure ( input 1, input "docRoadtaxr"  , input string( abs( buf_sale_ot-supp-line.road-tax-rubl    ) / buf_sale_ot-supp-line.fact-qnty  * temp_cost_cli_ot-supp-line.fact-qnty ), input 2 ).
                                run bgelib-tag-put in this-procedure ( input 1, input "docTransportr", input string( abs( buf_sale_ot-supp-line.transport-rubl   ) / buf_sale_ot-supp-line.fact-qnty  * temp_cost_cli_ot-supp-line.fact-qnty ), input 2 ).
                                run bgelib-tag-put in this-procedure ( input 1, input "docOtherr"    , input string( abs( buf_sale_ot-supp-line.other-rubl       ) / buf_sale_ot-supp-line.fact-qnty  * temp_cost_cli_ot-supp-line.fact-qnty ), input 2 ).
                                run bgelib-tag-put in this-procedure ( input 1, input "docExciser"   , input string( abs( buf_sale_ot-supp-line.excise-rubl      ) / buf_sale_ot-supp-line.fact-qnty  * temp_cost_cli_ot-supp-line.fact-qnty ), input 2 ).
                                run bgelib-tag-put in this-procedure ( input 1, input "docSumb"      , input string( abs( buf_sale_ot-supp-line.sum-base         ) / buf_sale_ot-supp-line.fact-qnty  * temp_cost_cli_ot-supp-line.fact-qnty ), input 2 ).
                                run bgelib-tag-put in this-procedure ( input 1, input "docVatb"      , input string( abs( buf_sale_ot-supp-line.vat-base         ) / buf_sale_ot-supp-line.fact-qnty  * temp_cost_cli_ot-supp-line.fact-qnty ), input 2 ).
                                run bgelib-tag-put in this-procedure ( input 1, input "docSltb"      , input string( abs( buf_sale_ot-supp-line.slt-base         ) / buf_sale_ot-supp-line.fact-qnty  * temp_cost_cli_ot-supp-line.fact-qnty ), input 2 ).
                                run bgelib-tag-put in this-procedure ( input 1, input "docRoadtaxb"  , input string( abs( buf_sale_ot-supp-line.road-tax-base    ) / buf_sale_ot-supp-line.fact-qnty  * temp_cost_cli_ot-supp-line.fact-qnty ), input 2 ).
                                run bgelib-tag-put in this-procedure ( input 1, input "docTransportb", input string( abs( buf_sale_ot-supp-line.transport-base   ) / buf_sale_ot-supp-line.fact-qnty  * temp_cost_cli_ot-supp-line.fact-qnty ), input 2 ).
                                run bgelib-tag-put in this-procedure ( input 1, input "docOtherb"    , input string( abs( buf_sale_ot-supp-line.other-base       ) / buf_sale_ot-supp-line.fact-qnty  * temp_cost_cli_ot-supp-line.fact-qnty ), input 2 ).
                                run bgelib-tag-put in this-procedure ( input 1, input "docExciseb"   , input string( abs( buf_sale_ot-supp-line.excise-base      ) / buf_sale_ot-supp-line.fact-qnty  * temp_cost_cli_ot-supp-line.fact-qnty ), input 2 ).
                            end.        /* available buf_sale_ot-supp-line */
                            run bgelib-tag-close in this-procedure ( input 0, input "linePaySupp" ).
                        end.        /* for each temp_cost_cli_ot-supp-line */
                    end.      /* for each temp_cost_cat-id_ot-supp-line */
                end.        /* if p-pay-code = yes */
            end.      /* p-ext-doc-type <> {&TDEDT_Overturn} */
            else do:
                /* Для переоценки не надо искать pay */
            end.      /* NOT ( p-ext-doc-type <> {&TDEDT_Overturn} ) */
        end.        /* for each buf_ot-line-sale no-lock */
        if v-last-file-position = 0
        or seek( stmxmlout ) - v-last-file-position > {&bgelib-check-freespace-size}
        then do:
            run gbl/chkfree.p (
                input substring( p-xml-file-name, 1, 1 )
                , input {&bgelib_minimum-free-mbytes}
                , output v-need-disk-spc
            ) .
            if v-need-disk-spc = yes
            then do:
                run gbl/waitfrsp.w (
                    input substring( p-xml-file-name, 1, 1 )
                    , input {&bgelib_minimum-free-mbytes}
                    , output v-cancel
                ) .
                if v-cancel = yes
                then do:
                    undo, return error.
                end.
            end.
            assign
                v-last-file-position = seek( stmxmlout )
            .
        end.
        run bgelib-check-file-size in this-procedure (
              input p-xml-file-name + {&bgelib-temp-extension}
            , output v-need-new-file
        ).
    end.        /* for each buf_ot-tot-crsa-loop */
    output stream stmxmlout close.
end.
end procedure. /* export-documents */

/*==========================================================================*/
procedure export-before-and-after-inv-trn :
do
on error undo, return error
:
define input parameter p-doc-code       as character    no-undo.
define output parameter p-exists-before as logical      no-undo.
define output parameter p-exists-after  as logical      no-undo.

    define variable v-attr-value    as character     no-undo.
    define variable v-attr-type     as character     no-undo.

    define buffer buf_trn-doc-sum       for ub.trn-doc-sum.

    { str/tdat-val.i
        p-doc-code
        {&trdcattr-addsum}
        v-attr-value
        v-attr-type
    }
    if lookup( {&sum-before-doc}, v-attr-value ) <> 0
    then do:
        assign
            p-exists-before = yes
        .
        find first buf_trn-doc-sum no-lock
             where buf_trn-doc-sum.doc-code = p-doc-code
               and buf_trn-doc-sum.sum-type = {&sum-before-doc}
        no-error.
        if available buf_trn-doc-sum
        then do:
            run bgelib-tag-open in this-procedure ( input 0, input "docInvBeforeSum", input "" ).
            run bgelib-tag-put in this-procedure ( input 1, input "docID"     , input p-doc-code                                   , input 0 ).
            run bgelib-tag-put in this-procedure ( input 1, input "qnty"            , input string( buf_trn-doc-sum.fact-qnty           ) , 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "saleSumr"        , input string( buf_trn-doc-sum.crsa-sum-rubl       ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "saleVatr"        , input string( buf_trn-doc-sum.crsa-vat-rubl       ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "saleSltr"        , input string( buf_trn-doc-sum.crsa-slt-rubl       ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "saleRoadtaxr"    , input string( buf_trn-doc-sum.crsa-road-tax-rubl  ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "saleTransportr"  , input string( buf_trn-doc-sum.crsa-transport-rubl ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "saleOtherr"      , input string( buf_trn-doc-sum.crsa-other-rubl     ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "saleExciser"     , input string( buf_trn-doc-sum.crsa-excise-rubl    ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "saleSumb"        , input string( buf_trn-doc-sum.crsa-sum-base       ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "saleVatb"        , input string( buf_trn-doc-sum.crsa-vat-base       ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "saleSltb"        , input string( buf_trn-doc-sum.crsa-slt-base       ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "saleRoadtaxb"    , input string( buf_trn-doc-sum.crsa-road-tax-base  ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "saleTransportb"  , input string( buf_trn-doc-sum.crsa-transport-base ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "saleOtherb"      , input string( buf_trn-doc-sum.crsa-other-base     ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "saleExciseb"     , input string( buf_trn-doc-sum.crsa-excise-base    ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "costSumr"        , input string( buf_trn-doc-sum.cost-sum-rubl       ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "costVatr"        , input string( buf_trn-doc-sum.cost-vat-rubl       ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "costSltr"        , input string( buf_trn-doc-sum.cost-slt-rubl       ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "costRoadtaxr"    , input string( buf_trn-doc-sum.cost-road-tax-rubl  ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "costTransportr"  , input string( buf_trn-doc-sum.cost-transport-rubl ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "costOtherr"      , input string( buf_trn-doc-sum.cost-other-rubl     ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "costExciser"     , input string( buf_trn-doc-sum.cost-excise-rubl    ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "costSumb"        , input string( buf_trn-doc-sum.cost-sum-base       ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "costVatb"        , input string( buf_trn-doc-sum.cost-vat-base       ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "costSltb"        , input string( buf_trn-doc-sum.cost-slt-base       ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "costRoadtaxb"    , input string( buf_trn-doc-sum.cost-road-tax-base  ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "costTransportb"  , input string( buf_trn-doc-sum.cost-transport-base ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "costOtherb"      , input string( buf_trn-doc-sum.cost-other-base     ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "costExciseb"     , input string( buf_trn-doc-sum.cost-excise-base    ), input 2 ).
            run bgelib-tag-close in this-procedure ( input 0, input "docInvBeforeSum" ).
        end.        /* available buf_trn-doc-sum */
        else do:
            run bgelib-write-log in this-procedure ( input p-log-file-name, input 1, input "*** ERR: *** Не найдена запись trn-doc-sum с sum-type = {&sum-before-doc} для документа " + string( p-doc-code ) ).
        end.        /* NOT ( available buf_trn-doc-sum ) */
    end.        /* if lookup( {&sum-before-doc}, v-attr-value ) <> 0 */
    if lookup( {&sum-after-doc}, v-attr-value ) <> 0
    then do:
        assign
            p-exists-after  = yes
        .
        find first buf_trn-doc-sum no-lock
             where buf_trn-doc-sum.doc-code = p-doc-code
               and buf_trn-doc-sum.sum-type = {&sum-after-doc}
        no-error.
        if available buf_trn-doc-sum
        then do:
            run bgelib-tag-open in this-procedure ( input 0, input "docInvAfterSum", input "" ).
            run bgelib-tag-put in this-procedure ( input 1, input "docID"    , input p-doc-code                                   , input 0 ).
            run bgelib-tag-put in this-procedure ( input 1, input "qnty"           , input string( buf_trn-doc-sum.fact-qnty           ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "saleSumr"       , input string( buf_trn-doc-sum.crsa-sum-rubl       ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "saleVatr"       , input string( buf_trn-doc-sum.crsa-vat-rubl       ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "saleSltr"       , input string( buf_trn-doc-sum.crsa-slt-rubl       ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "saleRoadtaxr"   , input string( buf_trn-doc-sum.crsa-road-tax-rubl  ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "saleTransportr" , input string( buf_trn-doc-sum.crsa-transport-rubl ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "saleOtherr"     , input string( buf_trn-doc-sum.crsa-other-rubl     ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "saleExciser"    , input string( buf_trn-doc-sum.crsa-excise-rubl    ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "saleSumb"       , input string( buf_trn-doc-sum.crsa-sum-base       ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "saleVatb"       , input string( buf_trn-doc-sum.crsa-vat-base       ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "saleSltb"       , input string( buf_trn-doc-sum.crsa-slt-base       ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "saleRoadtaxb"   , input string( buf_trn-doc-sum.crsa-road-tax-base  ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "saleTransportb" , input string( buf_trn-doc-sum.crsa-transport-base ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "saleOtherb"     , input string( buf_trn-doc-sum.crsa-other-base     ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "saleExciseb"    , input string( buf_trn-doc-sum.crsa-excise-base    ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "costSumr"       , input string( buf_trn-doc-sum.cost-sum-rubl       ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "costVatr"       , input string( buf_trn-doc-sum.cost-vat-rubl       ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "costSltr"       , input string( buf_trn-doc-sum.cost-slt-rubl       ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "costRoadtaxr"   , input string( buf_trn-doc-sum.cost-road-tax-rubl  ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "costTransportr" , input string( buf_trn-doc-sum.cost-transport-rubl ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "costOtherr"     , input string( buf_trn-doc-sum.cost-other-rubl     ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "costExciser"    , input string( buf_trn-doc-sum.cost-excise-rubl    ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "costSumb"       , input string( buf_trn-doc-sum.cost-sum-base       ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "costVatb"       , input string( buf_trn-doc-sum.cost-vat-base       ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "costSltb"       , input string( buf_trn-doc-sum.cost-slt-base       ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "costRoadtaxb"   , input string( buf_trn-doc-sum.cost-road-tax-base  ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "costTransportb" , input string( buf_trn-doc-sum.cost-transport-base ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "costOtherb"     , input string( buf_trn-doc-sum.cost-other-base     ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "costExciseb"    , input string( buf_trn-doc-sum.cost-excise-base    ), input 2 ).
            run bgelib-tag-close in this-procedure ( input 0, input "docInvAfterSum" ).
        end.        /* available buf_trn-doc-sum */
        else do:
            run bgelib-write-log in this-procedure ( input p-log-file-name, input 1, input "*** ERR: *** Не найдена запись trn-doc-sum с sum-type = {&sum-after-doc} для документа " + string( p-doc-code ) ).
        end.        /* NOT ( available buf_trn-doc-sum ) */
    end.        /* if lookup( {&sum-after-doc}, v-attr-value ) <> 0 */
end.
end procedure. /* export-before-and-after-inv-trn */


/*==========================================================================*/
procedure export-before-and-after-inv-line :
do
on error undo, return error
:
define input parameter p-doc-code           as character    no-undo.
define input parameter p-gds-code           as integer      no-undo.
define input parameter p-exists-before      as logical      no-undo.
define input parameter p-exists-after       as logical      no-undo.
define input parameter p-need-petrol-weight as logical      no-undo.
define input parameter p-petrol-density     as decimal      no-undo.

    define buffer buf_doc-line-sum      for ub.doc-line-sum.

    if p-exists-before = yes
    then do:
        find first buf_doc-line-sum no-lock
             where buf_doc-line-sum.doc-code = p-doc-code
               and buf_doc-line-sum.gds-code = p-gds-code
               and buf_doc-line-sum.sum-type = {&sum-before-doc}
        no-error.
        if available buf_doc-line-sum
        then do:
            run bgelib-tag-open in this-procedure ( input 0, input "lineInvBeforeSum", input "" ).
            run bgelib-tag-put in this-procedure ( input 1, input "docID"     , input p-doc-code  , input 0 ).
            run bgelib-tag-put in this-procedure ( input 1, input "goodID"            , input p-gds-code  , input 0 ).
            if p-need-petrol-weight = yes
            then do:
                run bgelib-tag-put in this-procedure ( input 1, input "petrolWeightBefore", input string( buf_doc-line-sum.fact-qnty * p-petrol-density ), input 0 ).
            end.
            run bgelib-tag-put in this-procedure ( input 1, input "qnty"           , input string( buf_doc-line-sum.fact-qnty ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "saleSumr"       , input string( buf_doc-line-sum.crsa-sum-rubl       ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "saleVatr"       , input string( buf_doc-line-sum.crsa-vat-rubl       ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "saleSltr"       , input string( buf_doc-line-sum.crsa-slt-rubl       ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "saleRoadtaxr"   , input string( buf_doc-line-sum.crsa-road-tax-rubl  ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "saleTransportr" , input string( buf_doc-line-sum.crsa-transport-rubl ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "saleOtherr"     , input string( buf_doc-line-sum.crsa-other-rubl     ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "saleExciser"    , input string( buf_doc-line-sum.crsa-excise-rubl    ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "saleSumb"       , input string( buf_doc-line-sum.crsa-sum-base       ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "saleVatb"       , input string( buf_doc-line-sum.crsa-vat-base       ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "saleSltb"       , input string( buf_doc-line-sum.crsa-slt-base       ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "saleRoadtaxb"   , input string( buf_doc-line-sum.crsa-road-tax-base  ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "saleTransportb" , input string( buf_doc-line-sum.crsa-transport-base ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "saleOtherb"     , input string( buf_doc-line-sum.crsa-other-base     ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "saleExciseb"    , input string( buf_doc-line-sum.crsa-excise-base    ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "costSumr"       , input string( buf_doc-line-sum.cost-sum-rubl       ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "costVatr"       , input string( buf_doc-line-sum.cost-vat-rubl       ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "costSltr"       , input string( buf_doc-line-sum.cost-slt-rubl       ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "costRoadtaxr"   , input string( buf_doc-line-sum.cost-road-tax-rubl  ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "costTransportr" , input string( buf_doc-line-sum.cost-transport-rubl ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "costOtherr"     , input string( buf_doc-line-sum.cost-other-rubl     ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "costExciser"    , input string( buf_doc-line-sum.cost-excise-rubl    ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "costSumb"       , input string( buf_doc-line-sum.cost-sum-base       ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "costVatb"       , input string( buf_doc-line-sum.cost-vat-base       ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "costSltb"       , input string( buf_doc-line-sum.cost-slt-base       ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "costRoadtaxb"   , input string( buf_doc-line-sum.cost-road-tax-base  ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "costTransportb" , input string( buf_doc-line-sum.cost-transport-base ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "costOtherb"     , input string( buf_doc-line-sum.cost-other-base     ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "costExciseb"    , input string( buf_doc-line-sum.cost-excise-base    ), input 2 ).
            run bgelib-tag-close in this-procedure ( input 0, input "lineInvBeforeSum" ).
        end.        /* available buf_doc-line-sum */
        else do:
            run bgelib-write-log in this-procedure ( input p-log-file-name, input 1, input "*** ERR: *** Не найдена запись doc-line-sum с sum-type = {&sum-before-doc} для документа " + string( p-doc-code ) ).
        end.        /* NOT ( available buf_doc-line-sum ) */
    end.        /* if p-exists-before = yes */
    if p-exists-after = yes
    then do:
        find first buf_doc-line-sum no-lock
             where buf_doc-line-sum.doc-code = p-doc-code
               and buf_doc-line-sum.gds-code = p-gds-code
               and buf_doc-line-sum.sum-type = {&sum-after-doc}
        no-error.
        if available buf_doc-line-sum
        then do:
            run bgelib-tag-open in this-procedure ( input 0, input "lineInvAfterSum", input "" ).
            run bgelib-tag-put in this-procedure ( input 1, input "docID"     , input p-doc-code  , input 0 ).
            run bgelib-tag-put in this-procedure ( input 1, input "goodID"            , input p-gds-code  , input 0 ).
            if p-need-petrol-weight = yes
            then do:
                run bgelib-tag-put in this-procedure ( input 1, input "petrolWeightAfter",  input string( buf_doc-line-sum.fact-qnty * p-petrol-density ), input 0 ).
            end.
            run bgelib-tag-put in this-procedure ( input 1, input "qnty"           , input string( buf_doc-line-sum.fact-qnty           ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "saleSumr"       , input string( buf_doc-line-sum.crsa-sum-rubl       ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "saleVatr"       , input string( buf_doc-line-sum.crsa-vat-rubl       ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "saleSltr"       , input string( buf_doc-line-sum.crsa-slt-rubl       ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "saleRoadtaxr"   , input string( buf_doc-line-sum.crsa-road-tax-rubl  ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "saleTransportr" , input string( buf_doc-line-sum.crsa-transport-rubl ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "saleOtherr"     , input string( buf_doc-line-sum.crsa-other-rubl     ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "saleExciser"    , input string( buf_doc-line-sum.crsa-excise-rubl    ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "saleSumb"       , input string( buf_doc-line-sum.crsa-sum-base       ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "saleVatb"       , input string( buf_doc-line-sum.crsa-vat-base       ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "saleSltb"       , input string( buf_doc-line-sum.crsa-slt-base       ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "saleRoadtaxb"   , input string( buf_doc-line-sum.crsa-road-tax-base  ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "saleTransportb" , input string( buf_doc-line-sum.crsa-transport-base ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "saleOtherb"     , input string( buf_doc-line-sum.crsa-other-base     ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "saleExciseb"    , input string( buf_doc-line-sum.crsa-excise-base    ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "costSumr"       , input string( buf_doc-line-sum.cost-sum-rubl       ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "costVatr"       , input string( buf_doc-line-sum.cost-vat-rubl       ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "costSltr"       , input string( buf_doc-line-sum.cost-slt-rubl       ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "costRoadtaxr"   , input string( buf_doc-line-sum.cost-road-tax-rubl  ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "costTransportr" , input string( buf_doc-line-sum.cost-transport-rubl ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "costOtherr"     , input string( buf_doc-line-sum.cost-other-rubl     ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "costExciser"    , input string( buf_doc-line-sum.cost-excise-rubl    ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "costSumb"       , input string( buf_doc-line-sum.cost-sum-base       ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "costVatb"       , input string( buf_doc-line-sum.cost-vat-base       ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "costSltb"       , input string( buf_doc-line-sum.cost-slt-base       ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "costRoadtaxb"   , input string( buf_doc-line-sum.cost-road-tax-base  ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "costTransportb" , input string( buf_doc-line-sum.cost-transport-base ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "costOtherb"     , input string( buf_doc-line-sum.cost-other-base     ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "costExciseb"    , input string( buf_doc-line-sum.cost-excise-base    ), input 2 ).
            run bgelib-tag-close in this-procedure ( input 0, input "lineInvAfterSum" ).
        end.        /* available buf_doc-line-sum */
        else do:
            run bgelib-write-log in this-procedure ( input p-log-file-name, input 1, input "*** ERR: *** Не найдена запись doc-line-sum с sum-type = {&sum-after-doc} для документа " + string( p-doc-code ) ).
        end.        /* NOT ( available buf_doc-line-sum ) */
    end.        /* if p-exists-after = yes */
end.
end procedure. /* export-before-and-after-inv-line */

/*==========================================================================*/
procedure get-petrol-weight :
do
on error undo, return error
:
define input parameter p-ext-doc-type           as character    no-undo.
define input parameter p-doc-line-recid         as recid        no-undo.
define input parameter p-trn-doc-out-code       as character    no-undo.
define output parameter p-petrol-weight         as decimal      no-undo.
define output parameter p-weight-not-specified  as logical      no-undo.

    define variable v-rvs-code              as character     no-undo.
    define variable v-found-last-rvs-doc    as logical       no-undo.

    define buffer buf_doc-line      for ub.doc-line.
    define buffer buf_rvs-doc       for ub.rvs-doc.
    define buffer buf_rvs-line      for ub.rvs-line.
    define buffer buf_goods         for ub.goods.
    define buffer buf_doc-pl        for ub.doc-pl.

    find first buf_doc-line no-lock
        where recid( buf_doc-line ) = p-doc-line-recid
    .
    find first buf_goods no-lock
         where buf_goods.artic      = buf_doc-line.artic
           and buf_goods.prod-type  = buf_doc-line.prod-type
           and buf_goods.prod-code  = buf_doc-line.prod-code
    .
    assign
        p-weight-not-specified = yes
    .
    case p-ext-doc-type:
        when {&TDEDT_Pri_Vnesh}
        or when {&TDEDT_Vozvrat_Vnesh}
        or when {&TDEDT_Spi_Vnesh}
        or when {&TDEDT_Pri_Vnesh}
        or when {&TDEDT_Vozvrat_Vnesh_Kass}
        or when {&TDEDT_Ras_Vnesh_VP}
        then do:
            assign
                p-petrol-weight        = buf_doc-line.fact-qnty * buf_doc-line.fact-density
                p-weight-not-specified = no
            .
        end.        /* when {&TDEDT_Pri_Vnesh} */
        when {&TDEDT_Inv}
        or when {&TDEDT_Peresort}
        or when {&TDEDT_Corr_Acc_Price}
        or when {&TDEDT_Corr_Minus_Parts}
        then do:
            find first buf_rvs-doc no-lock
                 where buf_rvs-doc.rvs-code = p-trn-doc-out-code
                   and buf_rvs-doc.status_  = {&fact}
            no-error.
            if available buf_rvs-doc
            then do:
                assign
                    v-rvs-code           = buf_rvs-doc.rvs-code
                .
                for each buf_doc-pl no-lock
                   where buf_doc-pl.out-code = buf_doc-line.doc-code
                     and buf_doc-pl.gds-code = buf_goods.gds-code
                     and buf_doc-pl.obj-type = buf_doc-line.obj-type
                     and buf_doc-pl.obj-code = buf_doc-line.obj-code
                on error undo, return error
                :
                    for each buf_rvs-line no-lock
                       where buf_rvs-line.gds-code  = buf_doc-pl.gds-code
                         and buf_rvs-line.rvs-code  = v-rvs-code
                         and buf_rvs-line.obj-type  = buf_doc-pl.obj-type
                         and buf_rvs-line.obj-code  = buf_doc-pl.obj-code
                         and buf_rvs-line.pl-code   = buf_doc-pl.pl-code
                    on error undo, return error
                    :
                        assign
                            p-petrol-weight         = p-petrol-weight + buf_doc-pl.fact-qnty * buf_rvs-line.state-density
                            p-weight-not-specified  = no
                        .
                    end.
                end.        /* for each buf_doc-pl */
            end.        /* available buf_rvs-doc */
            else do:
                assign
                    v-found-last-rvs-doc = no
                .
                find-last-rvs:
                for each buf_rvs-doc no-lock
                   where buf_rvs-doc.obj-type = buf_doc-line.obj-type
                     and buf_rvs-doc.obj-code = buf_doc-line.obj-code
                     and buf_rvs-doc.status_  = {&fact}
                use-index shift
                on error undo, return error
                :
                    assign
                        v-rvs-code           = buf_rvs-doc.rvs-code
                    .
                    for each buf_doc-pl no-lock
                       where buf_doc-pl.out-code = buf_doc-line.doc-code
                         and buf_doc-pl.gds-code = buf_goods.gds-code
                         and buf_doc-pl.obj-type = buf_doc-line.obj-type
                         and buf_doc-pl.obj-code = buf_doc-line.obj-code
                    on error undo, return error
                    :
                        for each buf_rvs-line no-lock
                           where buf_rvs-line.gds-code  = buf_doc-pl.gds-code
                             and buf_rvs-line.rvs-code  = v-rvs-code
                             and buf_rvs-line.obj-type  = buf_doc-pl.obj-type
                             and buf_rvs-line.obj-code  = buf_doc-pl.obj-code
                             and buf_rvs-line.pl-code   = buf_doc-pl.pl-code
                        on error undo, return error
                        :
                            assign
                                v-found-last-rvs-doc    = yes
                                p-petrol-weight         = p-petrol-weight + buf_doc-pl.fact-qnty * buf_rvs-line.state-density
                                p-weight-not-specified  = no
                            .
                            leave find-last-rvs.
                        end.
                    end.        /* for each buf_doc-pl */
                end.        /* for each buf_rvs-doc no-lock */
            end.        /* not available buf_rvs-doc */
        end.        /* when {&TDEDT_Inv} */
        otherwise do:
            assign
                p-weight-not-specified = yes
            .
        end.        /* otherwise */
    end case.
end.
end procedure. /* get-petrol-weight */

/*==========================================================================*/
procedure get-cash-pay :

  do
  on error undo, return error
  :
  define input parameter p-ext-doc-type           as character    no-undo.
  define input parameter p-doc-line-recid         as recid        no-undo.
  define input parameter p-trn-doc-out-code       as character    no-undo.
  define output parameter p-cash-pay-not-specified  as logical      no-undo.


    define buffer buf_doc-line      for ub.doc-line.
    define buffer buf_goods         for ub.goods.

    find first buf_doc-line no-lock
        where recid( buf_doc-line ) = p-doc-line-recid
    .
    find first buf_goods no-lock
         where buf_goods.artic      = buf_doc-line.artic
           and buf_goods.prod-type  = buf_doc-line.prod-type
           and buf_goods.prod-code  = buf_doc-line.prod-code
    .
    assign
        p-cash-pay-not-specified = yes
    .
    case p-ext-doc-type:
        when {&TDEDT_Ras_Vnesh_Kass}
        then do:
            assign
                p-cash-pay-not-specified = no
            .
        end.        /* when {&TDEDT_Ras_Vnesh_Kass} */
        when {&TDEDT_Vozvrat_Vnesh_Kass}
        then do:
            assign
                p-cash-pay-not-specified = no
            .
        end.        /* when {&TDEDT_Vozvrat_Vnesh_Kass} */
        otherwise do:
            assign
                p-cash-pay-not-specified = yes
            .
        end.        /* otherwise */
      END CASE.
  end. /*doe*/

end procedure. /* get-cash-pay */

/*==========================================================================*/
procedure get-inkas-pay-desk :

  define buffer buf_inkas-pay-desk for ub.inkas-pay-desk.

  do for buf_inkas-pay-desk
  on error undo, return error
  :

  define input parameter p-inkas-code like ub.inkas.inkas-code no-undo .
  define input parameter p-obj-type   like ub.inkas.obj-type no-undo .
  define input parameter p-obj-code   like ub.inkas.obj-code no-undo .
  define input parameter p-inkas-pay-desk-type like ub.inkas-pay-desk.doc-type no-undo .

    /*проверим есть ли для данного inkas подчиненная таблица inkas-pay-desk*/
    /*если это старая продажа до версии 12.2 - может не быть тогда создадим*/
    /*это возможно в офисе т.к. в Орле все чеки ходят*/
    if can-find( first buf_inkas-pay-desk  NO-LOCK WHERE
                       buf_inkas-pay-desk.inkas-code = p-inkas-code ) then.
    else do:
      run trg/inkpdcr.p (
                     p-inkas-code
                    ,p-obj-type
                    ,p-obj-code
      ) no-error .
      if error-status:error then do:
        return error.
      end.
    end.
    for each temp_inkas-pay
    :
        delete temp_inkas-pay.
    end.
    for each buf_inkas-pay-desk no-lock
       where buf_inkas-pay-desk.inkas-code  = p-inkas-code
         and buf_inkas-pay-desk.doc-type    = p-inkas-pay-desk-type
    break by buf_inkas-pay-desk.pay-code
    on error undo, return error
    :
        if first-of( buf_inkas-pay-desk.pay-code )
        then do:
            create temp_inkas-pay.
            assign
                temp_inkas-pay.pay-code  = buf_inkas-pay-desk.pay-code
                temp_inkas-pay.tot-base  = 0
                temp_inkas-pay.tot-rubl  = 0
                temp_inkas-pay.tot-sum   = 0
            .
        end.
        assign
            temp_inkas-pay.tot-base  = temp_inkas-pay.tot-base + buf_inkas-pay-desk.tot-base
            temp_inkas-pay.tot-rubl  = temp_inkas-pay.tot-rubl + buf_inkas-pay-desk.tot-rubl
            temp_inkas-pay.tot-sum   = temp_inkas-pay.tot-sum  + buf_inkas-pay-desk.tot-sum
        .
    end.
  end.

end procedure. /* get-inkas-pay-desk */

/*==========================================================================*/
procedure export-attribute :
do
on error undo, return error
:
define input parameter p-doc-code   as character    no-undo.
define input parameter p-attr-code  as character    no-undo.
define input parameter p-tag-name   as character    no-undo.

    define variable v-attr-exists    as logical        no-undo.
    define variable v-attr-value     as character      no-undo.
    define variable v-attr-type      as character      no-undo.

    { str/tdat-xst.i
        p-doc-code
        p-attr-code
        v-attr-exists
    }
    if v-attr-exists = yes
    then do:
        { str/tdat-val.i
            p-doc-code
            p-attr-code
            v-attr-value
            v-attr-type
            no-error
        }
        if error-status :error
        then do:
            run bgelib-write-log in this-procedure (
                  input p-log-file-name
                , input 1
                , input substitute( "*** ERR: *** Ошибка чтения атрибута &1 для документа N &2", p-attr-code, p-doc-code )
            ).
        end.
        else do:
            run bgelib-tag-put in this-procedure ( input 1, input p-tag-name, input v-attr-value, input 0 ).
        end.
    end.
end.
end procedure. /* export-attribute */

/*==========================================================================*/
procedure export-parts :
do
on error undo, return error
:
define input parameter p-doc-code   as character    no-undo.
define input parameter p-gds-code   as integer      no-undo.
define input parameter p-obj-type   as character    no-undo.
define input parameter p-obj-code   as integer      no-undo.
define input parameter p-prod-type  as character    no-undo.
define input parameter p-prod-code  as integer      no-undo.
define input parameter p-artic      as character    no-undo.

    define variable v-parts-cst-code        as character    no-undo.

    define variable v-fact-qnty             as decimal     no-undo.
    define variable v-sum-rubl              as decimal     no-undo.
    define variable v-vat-rubl              as decimal     no-undo.
    define variable v-slt-rubl              as decimal     no-undo.
    define variable v-road-tax-rubl         as decimal     no-undo.
    define variable v-transport-rubl        as decimal     no-undo.
    define variable v-other-rubl            as decimal     no-undo.
    define variable v-excise-rubl           as decimal     no-undo.
    define variable v-sum-base              as decimal     no-undo.
    define variable v-vat-base              as decimal     no-undo.
    define variable v-slt-base              as decimal     no-undo.
    define variable v-road-tax-base         as decimal     no-undo.
    define variable v-transport-base        as decimal     no-undo.
    define variable v-other-base            as decimal     no-undo.
    define variable v-excise-base           as decimal     no-undo.
    define variable v-parts-host-code       as integer       no-undo.
    define variable v-parts-contract-code   as integer       no-undo.

    define variable v-parts-price-cli       as decimal       no-undo.
    define variable v-parts-cli-base-rate   as decimal       no-undo.
    define variable v-parts-vat-type        as character     no-undo.
    define variable v-parts-exch-code       as integer       no-undo.
    define variable v-parts-attr-exch-rate  as decimal       no-undo.
    define variable v-parts-attr-exch-scale as integer       no-undo.
    define variable v-parts-attr-unit-cli   as character     no-undo.

    define variable v-country-code          as character    no-undo.
    define variable v-supp-type             as character   no-undo.
    define variable v-supp-code             as integer     no-undo.
    define variable v-in-code               as character   no-undo.
    define variable v-cst-code              as character   no-undo.

    define variable v-supp-dog-code         as character    no-undo.
    define variable v-supp-ndog             as character    no-undo.
    define variable v-supp-ddog             as character    no-undo.

    define buffer buf_parts             for ub.parts.
    define buffer buf_parts-attr        for ub.parts-attr.
    define buffer buf_contract          for ub.contract.

    assign
        v-parts-cst-code = "":U
        v-supp-dog-code  = "":U
        v-supp-ndog      = "":U
        v-supp-ddog      = "":U
    .
    for each buf_parts no-lock
        where buf_parts.out-code   = p-doc-code
          and buf_parts.obj-type   = p-obj-type
          and buf_parts.obj-code   = p-obj-code
          and buf_parts.prod-type  = p-prod-type
          and buf_parts.prod-code  = p-prod-code
          and buf_parts.artic      = p-artic
          and buf_parts.status_    = true
    on error undo, return error return-value
    :
        if p-parts = yes
        then do:
            { str/in-vatp.i calc-parts buf_parts. " " loc}
            ASSIGN
                v-fact-qnty           = buf_parts.fact-qnty
                v-sum-rubl            = price-rubl-with-tax-loc * v-fact-qnty
                v-vat-rubl            = vat-rubl-loc            * v-fact-qnty
                v-slt-rubl            = slt-rubl-loc            * v-fact-qnty
                v-road-tax-rubl       = road-tax-rubl-loc       * v-fact-qnty
                v-transport-rubl      = transport-rubl-loc      * v-fact-qnty
                v-other-rubl          = other-rubl-loc          * v-fact-qnty
                v-excise-rubl         = 0
                v-sum-base            = price-base-with-tax-loc * v-fact-qnty
                v-vat-base            = vat-base-loc            * v-fact-qnty
                v-slt-base            = slt-base-loc            * v-fact-qnty
                v-road-tax-base       = road-tax-base-loc       * v-fact-qnty
                v-transport-base      = transport-base-loc      * v-fact-qnty
                v-other-base          = other-base-loc          * v-fact-qnty
                v-excise-base         = 0
                v-parts-host-code     = buf_parts.host-code
                v-parts-contract-code = buf_parts.contract-code
                v-parts-price-cli     = buf_parts.price-cli
                v-parts-cli-base-rate = buf_parts.cli-base-rate
                v-parts-vat-type      = buf_parts.vat-type
                v-parts-exch-code     = buf_parts.exch-code
            .
            if buf_parts.contract-code <> 0
            then do:
                assign
                    v-supp-dog-code = string( buf_parts.contract-code )
                .
                find first buf_contract no-lock
                     where buf_contract.host-code       = v-parts-host-code
                       and buf_contract.contract-code   = v-parts-contract-code
                no-error.
                if available buf_contract
                then do:
                    assign
                        v-supp-ndog          = string( buf_contract.contract-prn-code )
                        v-supp-ddog          = string( buf_contract.contract-date, "99.99.9999" )
                    .
                end.
            end.
            if p-gds-code <> 0
            then do:
                find first buf_parts-attr no-lock
                     where buf_parts-attr.in-code   = buf_parts.in-code
                       and buf_parts-attr.gds-code  = p-gds-code
                       and buf_parts-attr.part-code = buf_parts.part-code
                no-error .
                if available buf_parts-attr
                then do:
                    assign
/*                                        v-is-attr      = yes*/
/*                                        v-parts-VAt-pc = buf_parts-attr.vat-pc*/
/*                                        v-parts-SLT-pc = buf_parts-attr.SLT-pc*/
/*                                        v-purch-code = buf_parts-attr.purch-code*/
/*                                        v-fact-date = buf_parts-attr.fact-date*/
                        v-supp-type                 = buf_parts-attr.supp-type
                        v-supp-code                 = buf_parts-attr.supp-code
                        v-in-code                   = buf_parts-attr.income-in-code
                        v-cst-code                  = buf_parts-attr.cst-code
                        v-country-code              = string( buf_parts-attr.country-code )
                        v-parts-attr-exch-rate      = buf_parts-attr.exch-rate
                        v-parts-attr-exch-scale     = buf_parts-attr.exch-scale
                        v-parts-attr-unit-cli       = buf_parts-attr.unit-cli
                    .
                end.        /* if available buf_parts-attr */
                else do:
                    assign
/*                                    v-is-attr      = no*/
/*                                    v-parts-VAt-pc = buf_parts.vat-pc*/
/*                                    v-parts-SLT-pc = buf_parts.SLT-pc*/
/*                                    v-purch-code = buf_parts.purch-code*/
/*                                    v-fact-date = ?*/
                        v-supp-type                 = buf_parts.supp-type
                        v-supp-code                 = buf_parts.supp-code
                        v-in-code                   = buf_parts.in-code
                        v-cst-code                  = buf_parts.cst-code
                        v-country-code              = "":U
                        v-parts-attr-exch-rate      = 0.0
                        v-parts-attr-exch-scale     = 0
                        v-parts-attr-unit-cli       = "":U
                    .
                end.        /* NOT ( if available buf_parts-attr ) */
            end.        /* if p-gds-code <> 0 */
            else do:
                assign
                    v-supp-type                 = buf_parts.supp-type
                    v-supp-code                 = buf_parts.supp-code
                    v-in-code                   = buf_parts.in-code
                    v-cst-code                  = buf_parts.cst-code
                    v-country-code              = "":U
                    v-parts-attr-exch-rate      = 0.0
                    v-parts-attr-exch-scale     = 0
                    v-parts-attr-unit-cli       = "":U
                .
            end.        /* NOT ( p-gds-code <> 0 ) */
            run bgelib-tag-open in this-procedure ( input 0, input "linePart", input "" ).
            run bgelib-tag-put in this-procedure ( input 1, input "docID"               , input p-doc-code                 , input 0 ).
            run bgelib-tag-put in this-procedure ( input 1, input "goodID"              , input ( if p-gds-code = 0 then "" else string( p-gds-code ) ), input 0 ).
            run bgelib-tag-put in this-procedure ( input 1, input "inputDocID"          , input string( v-in-code               ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "qnty"                , input string( v-fact-qnty             ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "cst"                 , input string( v-cst-code              ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "supp"                , input string( v-supp-type + string( v-supp-code ) ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "hostCode"            , input string( v-parts-host-code       ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "contractCode"        , input string( v-parts-contract-code   ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "sumr"                , input string( v-sum-rubl              ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "VATr"                , input string( v-vat-rubl              ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "SLTr"                , input string( v-slt-rubl              ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "roadTaxr"            , input string( v-road-tax-rubl         ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "transportr"          , input string( v-transport-rubl        ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "otherr"              , input string( v-other-rubl            ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "exciser"             , input string( v-excise-rubl           ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "sumb"                , input string( v-sum-base              ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "VATb"                , input string( v-vat-base              ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "SLTb"                , input string( v-slt-base              ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "roadTaxb"            , input string( v-road-tax-base         ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "transportb"          , input string( v-transport-base        ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "otherb"              , input string( v-other-base            ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "exciseb"             , input string( v-excise-base           ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "contractSuppCode"    , input v-supp-dog-code                  , input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "contractSuppNo"      , input v-supp-ndog                      , input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "contractSuppDate"    , input v-supp-ddog                      , input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "countryCode"         , input v-country-code                   , input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "priceCli":U          , input string( v-parts-price-cli       ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "cliBaseRate":U       , input string( v-parts-cli-base-rate   ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "vatType":U           , input string( v-parts-vat-type        ), input 0 ).
            run bgelib-tag-put in this-procedure ( input 1, input "exchCode":U          , input string( v-parts-exch-code       ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "attrExchRate":U      , input string( v-parts-attr-exch-rate  ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "attrExchScale":U     , input string( v-parts-attr-exch-scale ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "attrUnitCli":U       , input string( v-parts-attr-unit-cli   ), input 0 ).
            run bgelib-tag-close in this-procedure ( input 0, input "linePart" ).
        end.        /* p-parts = yes */
        if p-cst = yes
        then do:
            assign
                v-parts-cst-code = v-parts-cst-code
                                    + ( if ( v-cst-code <> ?
                                        and trim( v-cst-code )   <> ""
                                        and trim( v-parts-cst-code ) <> "" )
                                        then "; "
                                        else ""  )
                                    + v-cst-code
            .
        end.        /* p-cst = yes */
    end.
    if p-cst = yes
    and v-parts-cst-code <> ""
    then do:
        run bgelib-tag-open in this-procedure ( input 0, input "lineCST", input "" ).
        run bgelib-tag-put in this-procedure ( input 1, input "docID"  , input p-doc-code       , input 0 ).
        run bgelib-tag-put in this-procedure ( input 1, input "goodID" , input ( if p-gds-code = 0 then "" else string( p-gds-code ) ), input 0 ).
        run bgelib-tag-put in this-procedure ( input 1, input "CST"      , input v-parts-cst-code , input 0 ).
        run bgelib-tag-close in this-procedure ( input 0, input "lineCST" ).
    end.        /* if p-cst = yes */
end.
end procedure. /* export-parts */



/*==========================================================================*/
procedure export-gds-dtl :
define input parameter p-ext-doc-type   as character        no-undo.
define input parameter p-doc-code       as character        no-undo.
define input parameter p-gds-code       as integer          no-undo.
define input parameter p-artic          as character        no-undo.
define input parameter p-prod-type      as character        no-undo.
define input parameter p-prod-code      as integer          no-undo.

    define variable v-doc-qnty       as decimal       no-undo.
    define variable v-fact-qnty      as decimal       no-undo.
    define variable v-sum-base       as decimal       no-undo.
    define variable v-sum-rubl       as decimal       no-undo.
    define variable v-vat-base       as decimal       no-undo.
    define variable v-vat-rubl       as decimal       no-undo.
    define variable v-slt-base       as decimal       no-undo.
    define variable v-slt-rubl       as decimal       no-undo.
    define variable v-road-tax-base  as decimal       no-undo.
    define variable v-road-tax-rubl  as decimal       no-undo.

    define buffer buf_gds-dtl       for ub.gds-dtl.
    define buffer buf_gds-prt       for ub.gds-prt.
    define buffer buf_trn-doc       for ub.trn-doc.
    define buffer buf_doc-line      for ub.doc-line.
do
for buf_gds-dtl
  , buf_gds-prt
  , buf_trn-doc
  , buf_doc-line
on error undo, return error
:
    find first buf_trn-doc no-lock
         where buf_trn-doc.doc-code = p-doc-code
    no-error.
    if not available buf_trn-doc
    then do:
        run bgelib-write-log in this-procedure (
              input p-log-file-name
            , input 1
            , input substitute( "*** ERR: *** Не найден документ '&1'."
                                , p-doc-code
                            )
        ).
        undo, return error.
    end.
    find first buf_doc-line no-lock
         where buf_doc-line.doc-code    = p-doc-code
           and buf_doc-line.artic       = p-artic
           and buf_doc-line.prod-type   = p-prod-type
           and buf_doc-line.prod-code   = p-prod-code
    no-error.
    if not available buf_doc-line
    then do:
        run bgelib-write-log in this-procedure (
              input p-log-file-name
            , input 1
            , input substitute( "*** ERR: *** Не найдена строка документа '&1' с артикулом товара '&2'."
                                , p-doc-code
                                , p-artic
                            )
        ).
        undo, return error.
    end.
    for each buf_gds-dtl no-lock
       where buf_gds-dtl.prod-type  = p-prod-type
         and buf_gds-dtl.prod-code  = p-prod-code
         and buf_gds-dtl.artic      = p-artic
         and buf_gds-dtl.doc-code   = p-doc-code
    :
        find first buf_gds-prt no-lock
             where buf_gds-prt.node-code = buf_gds-dtl.prt-code
        .
        { str/out-vatp.i calc-gds-dtl buf_doc-line. buf_trn-doc. buf_gds-dtl. }
        assign
            v-doc-qnty            = buf_gds-dtl.doc-qnty
            v-fact-qnty           = buf_gds-dtl.fact-qnty
            v-sum-rubl            = price-rubl-with-tax-sale    * v-fact-qnty
            v-vat-rubl            = vat-rubl-buyer              * v-fact-qnty
            v-slt-rubl            = slt-rubl-sale               * v-fact-qnty
            v-road-tax-rubl       = road-tax-rubl-sale          * v-fact-qnty
            v-sum-base            = price-base-with-tax-sale    * v-fact-qnty
            v-vat-base            = vat-base-buyer              * v-fact-qnty
            v-slt-base            = slt-base-sale               * v-fact-qnty
            v-road-tax-base       = road-tax-base-sale          * v-fact-qnty
        .
        run bgelib-tag-open in this-procedure ( input 0, input "lineDtl", input "" ).
        run bgelib-tag-put in this-procedure ( input 1, input "docID"   , input p-doc-code                 , input 0 ).
        run bgelib-tag-put in this-procedure ( input 1, input "goodID"  , input ( if p-gds-code = 0 then "" else string( p-gds-code ) ), input 0 ).
        run bgelib-tag-put in this-procedure ( input 1, input "dtlName"   , input string( buf_gds-prt.f-name ), input 2 ).
        if p-ext-doc-type = {&TDEDT_Inv}
        or p-ext-doc-type = {&TDEDT_Peresort}
        or p-ext-doc-type = {&TDEDT_Corr_Acc_Price}
        or p-ext-doc-type = {&TDEDT_Corr_Minus_Parts}
        then do:
            run bgelib-tag-put in this-procedure ( input 1, input "qnty"      , input string( v-doc-qnty                ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "beforeQnty", input string( v-fact-qnty - v-doc-qnty  ), input 2 ).
            run bgelib-tag-put in this-procedure ( input 1, input "afterQnty" , input string( v-fact-qnty               ), input 2 ).
        end.        /* if p-ext-doc-type = {&TDEDT_Inv} */
        else do:
            run bgelib-tag-put in this-procedure ( input 1, input "qnty"      , input string( v-fact-qnty               ), input 2 ).
        end.        /* NOT ( if p-ext-doc-type = {&TDEDT_Inv} ) */
        run bgelib-tag-put in this-procedure ( input 1, input "sumr"      , input string( v-sum-rubl         ), input 2 ).
        run bgelib-tag-put in this-procedure ( input 1, input "VATr"      , input string( v-vat-rubl         ), input 2 ).
        run bgelib-tag-put in this-procedure ( input 1, input "SLTr"      , input string( v-slt-rubl         ), input 2 ).
        run bgelib-tag-put in this-procedure ( input 1, input "roadTaxr"  , input string( v-road-tax-rubl    ), input 2 ).
        run bgelib-tag-put in this-procedure ( input 1, input "sumb"      , input string( v-sum-base         ), input 2 ).
        run bgelib-tag-put in this-procedure ( input 1, input "VATb"      , input string( v-vat-base         ), input 2 ).
        run bgelib-tag-put in this-procedure ( input 1, input "SLTb"      , input string( v-slt-base         ), input 2 ).
        run bgelib-tag-put in this-procedure ( input 1, input "roadTaxb"  , input string( v-road-tax-base    ), input 2 ).
        run bgelib-tag-close in this-procedure ( input 0, input "lineDtl" ).
    end.        /* for each buf_gds-dtl no-lock */
end.
end procedure. /* export-gds-dtl */


/*==========================================================================*/
procedure export-chk-pay-code :
define input parameter p-doc-line-recid     as recid            no-undo.
define input parameter p-trn-doc-doc-code   as character        no-undo.
define input parameter p-trn-doc-out-code   as character        no-undo.
define input parameter p-is-petrol          as logical          no-undo.
define input parameter p-is-pieces          as logical          no-undo.
define input parameter p-goods-gds-code     as integer          no-undo.
define input parameter p-goods-gds-type     as character        no-undo.

    define variable v-cash-pay-not-specified      as logical      no-undo.

do
on error undo, return error
:
    run get-cash-pay in this-procedure (
          input p-ext-doc-type
        , input p-doc-line-recid
        , input p-trn-doc-out-code
        , output v-cash-pay-not-specified
    ).
    if v-cash-pay-not-specified = no
    then do:
        if p-pay-desk = yes
        then do:
            if p-is-petrol = yes
            and p-is-pieces = no
            then do:        /*топливо - таблица treal-2*/
                for each treal-2
                    where treal-2.gds-code = p-goods-gds-code
                break by treal-2.pay-desk
                        by treal-2.cpay-code
                        by treal-2.curr-code
                        by treal-2.prefix
                on error undo, return error
                :
                    if treal-2.is-pay = no then do:
                       next.
                    end.
                    run bgelib-tag-open in this-procedure ( input 0
                                                            , input (if treal-2.prefix = '':U
                                                                    then "linePayDesk"      /*суммирующая запись по всем префиксам*/                                    /*суммирующая запись по всем префиксам*/                                    /*суммирующая запись по всем префиксам*/
                                                                    else "linePayDeskCard")
                                                            , input "" ).
                    run bgelib-tag-put in this-procedure ( input 1, input "docID"       , input p-trn-doc-doc-code                  , input 0 ).
                    run bgelib-tag-put in this-procedure ( input 1, input "goodID"      , input p-goods-gds-code                    , input 0 ).
                    run bgelib-tag-put in this-procedure ( input 1, input "PayDeskCode" , input string( treal-2.pay-desk )          , input 0 ).
                    run bgelib-tag-put in this-procedure ( input 1, input "payCode"     , input string( treal-2.cpay-code )         , input 0 ).
                    if treal-2.prefix <> '':U then do:
                        run bgelib-tag-put in this-procedure ( input 1, input "num"         , input string( treal-2.prefix )            , input 0 ).
                    end.
                    run bgelib-tag-put in this-procedure ( input 1, input "qnty"        , input string( v-is-out * treal-2.qnty1 )  , input 3 ).
                    run bgelib-tag-put in this-procedure ( input 1, input "sumr"        , input string( v-is-out * treal-2.netto-rubl )  , input 2 ).
                    run bgelib-tag-put in this-procedure ( input 1, input "sumb"        , input string( v-is-out * treal-2.netto )  , input 2 ).
                    run bgelib-tag-close in this-procedure ( input 0
                                                            , input (if treal-2.prefix = '':U
                                                                    then "linePayDesk"
                                                                    else "linePayDeskCard")
                                                            ).
                end.
            end.        /* топливо */
            else do:
                case p-goods-gds-type:
                    when {&gds-goods}
                    then do:        /*товары таблица treal-3*/
                        for each treal-3 no-lock
                            where treal-3.gds-code = p-goods-gds-code
                        break by treal-3.pay-desk
                                by treal-3.cpay-code
                                by treal-3.curr-code
                                by treal-3.prefix
                        on error undo, return error
                        :
                            if treal-3.is-pay = no  then do:
                                next.
                            end.
                            run bgelib-tag-open in this-procedure ( input 0
                                                                    , input (if treal-3.prefix = '':U
                                                                            then "linePayDesk"
                                                                            else "linePayDeskCard")
                                                                    , input "" ).
                            run bgelib-tag-put in this-procedure ( input 1, input "docID"       , input p-trn-doc-doc-code                  , input 0 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "goodID"      , input p-goods-gds-code                    , input 0 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "payDeskCode" , input string( treal-3.pay-desk )          , input 0 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "payCode"     , input string( treal-3.cpay-code )         , input 0 ).
                            if treal-3.prefix <> '':U then do:
                                run bgelib-tag-put in this-procedure ( input 1, input "num"         , input string( treal-3.prefix )            , input 0 ).
                            end.
                            run bgelib-tag-put in this-procedure ( input 1, input "qnty"        , input string( v-is-out * treal-3.qnty1 )  , input 3 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "sumr"        , input string( v-is-out * treal-3.netto-rubl )  , input 2 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "sumb"        , input string( v-is-out * treal-3.netto )  , input 2 ).
                            run bgelib-tag-close in this-procedure ( input 0
                                                                    , input (if treal-3.prefix = '':U
                                                                            then  "linePayDesk"
                                                                            else "linePayDeskCard"
                                                                            )
                                                                    ).
                        end.
                    end.
                    when {&gds-office}
                    then do:        /*услуги таблица  treal-4*/
                        for each treal-4 no-lock
                            where treal-4.gds-code = p-goods-gds-code
                        break by treal-4.pay-desk
                                by treal-4.cpay-code
                                by treal-4.curr-code
                                by treal-4.prefix
                        on error undo, return error
                        :
                            if treal-4.is-pay = no   then do:
                                next.
                            end.
                            run bgelib-tag-open in this-procedure ( input 0
                                                                    , input (if treal-4.prefix = '':U
                                                                            then "linePayDesk"
                                                                            else "linePayDeskCard")
                                                                    , input "" ).
                            run bgelib-tag-put in this-procedure ( input 1, input "docID"       , input p-trn-doc-doc-code                  , input 0 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "goodID"      , input p-goods-gds-code                    , input 0 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "payDeskCode" , input string( treal-4.pay-desk )          , input 0 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "payCode"     , input string( treal-4.cpay-code )         , input 0 ).
                            if treal-4.prefix <> '':U then do:
                                run bgelib-tag-put in this-procedure ( input 1, input "num"         , input string( treal-4.prefix )            , input 0 ).
                            end.
                            run bgelib-tag-put in this-procedure ( input 1, input "qnty"        , input string( v-is-out * treal-4.qnty1 )  , input 3 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "sumr"        , input string( v-is-out * treal-4.netto-rubl )  , input 2 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "sumb"        , input string( v-is-out * treal-4.netto )  , input 2 ).

                            run bgelib-tag-close in this-procedure ( input 0
                                                                    , input (if treal-4.prefix = '':U
                                                                            then "linePayDesk"
                                                                            else "linePayDeskCard"
                                                                            )
                                                                    ).
                        end.
                    end.
                end case.       /*case p-goods-gds-type*/
            end.        /* не топливо */
        end.        /* if p-pay-desk = yes */
        else do:
            if p-is-petrol = yes
            and p-is-pieces = no
            then do:        /*топливо - таблица treal-2*/
                for each treal-2 No-LOCK
                where treal-2.gds-code = p-goods-gds-code
                on error undo, return error
                :
                    if treal-2.is-pay = no then do:
                        next.
                    end.
                    run bgelib-tag-open in this-procedure ( input 0
                                                            , input (if treal-2.prefix = '':U
                                                                    then "linePayCode"
                                                                    else  "linePayCodeCard")
                                                            , input "" ).
                    run bgelib-tag-put in this-procedure ( input 1, input "docID"       , input p-trn-doc-doc-code                  , input 0 ).
                    run bgelib-tag-put in this-procedure ( input 1, input "goodID"      , input p-goods-gds-code                    , input 0 ).
                    run bgelib-tag-put in this-procedure ( input 1, input "code"        , input string( treal-2.cpay-code )         , input 0 ).
                    if treal-2.prefix <> '':U then do:
                        run bgelib-tag-put in this-procedure ( input 1, input "num"     , input string( treal-2.prefix )            , input 0 ).
                    end.
                    run bgelib-tag-put in this-procedure ( input 1, input "qnty"        , input string( v-is-out * treal-2.qnty1 )  , input 3 ).
                    run bgelib-tag-put in this-procedure ( input 1, input "sumr"        , input string( v-is-out * treal-2.netto-rubl )  , input 2 ).
                    run bgelib-tag-put in this-procedure ( input 1, input "sumb"        , input string( v-is-out * treal-2.netto )  , input 2 ).
                    run bgelib-tag-close in this-procedure ( input 0
                                                            , input (if treal-2.prefix = '':U
                                                                    then "linePayCode"
                                                                    else "linePayCodeCard"
                                                                    )
                                                            ).
                end.
            end.        /* топливо */
            else do:
                case p-goods-gds-type:
                    when {&gds-goods}
                    then do:        /*товары таблица treal-3*/
                        for each treal-3 no-lock
                        where treal-3.gds-code = p-goods-gds-code
                        on error undo, return error
                        :
                            if treal-3.is-pay = no then NEXT.
                            run bgelib-tag-open in this-procedure ( input 0
                                                                    , input (if treal-3.prefix = '':U
                                                                            then "linePayCode"
                                                                            else "linePayCodeCard")
                                                                    , input "" ).
                            run bgelib-tag-put in this-procedure ( input 1, input "docID"       , input p-trn-doc-doc-code                  , input 0 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "goodID"      , input p-goods-gds-code                    , input 0 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "code"        , input string( treal-3.cpay-code )         , input 0 ).
                            if treal-3.prefix <> '':U then do:
                                run bgelib-tag-put in this-procedure ( input 1, input "num"     , input string( treal-3.prefix )            , input 0 ).
                            end.
                            run bgelib-tag-put in this-procedure ( input 1, input "qnty"        , input string( v-is-out * treal-3.qnty1 )  , input 3 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "sumr"        , input string( v-is-out * treal-3.netto-rubl )  , input 2 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "sumb"        , input string( v-is-out * treal-3.netto )  , input 2 ).
                            run bgelib-tag-close in this-procedure ( input 0
                                                                    , input (if treal-3.prefix = '':U
                                                                            then "linePayCode"
                                                                            else "linePayCodeCard"
                                                                            )
                                                                    ).
                        end.
                    end.
                    when {&gds-office}
                    then do:        /*услуги таблица  treal-4*/
                        for each treal-4 no-lock
                        where treal-4.gds-code = p-goods-gds-code
                        on error undo, return error
                        :
                            if treal-4.is-pay = no then NEXT.

                            run bgelib-tag-open in this-procedure ( input 0
                                                                    , input (if treal-4.prefix = '':U
                                                                            then "linePayCode"
                                                                            else "linePayCodeCard")
                                                                    , input "" ).
                            run bgelib-tag-put in this-procedure ( input 1, input "docID"       , input p-trn-doc-doc-code                  , input 0 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "goodID"      , input p-goods-gds-code                    , input 0 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "code"        , input string( treal-4.cpay-code )         , input 0 ).
                            if treal-4.prefix <> '':U then do:
                                run bgelib-tag-put in this-procedure ( input 1, input "num"     , input string( treal-4.prefix )            , input 0 ).
                            end.
                            run bgelib-tag-put in this-procedure ( input 1, input "qnty"        , input string( v-is-out * treal-4.qnty1 )  , input 3 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "sumr"        , input string( v-is-out * treal-4.netto-rubl )  , input 2 ).
                            run bgelib-tag-put in this-procedure ( input 1, input "sumb"        , input string( v-is-out * treal-4.netto )  , input 2 ).
                            run bgelib-tag-close in this-procedure ( input 0
                                                                    , input (if treal-4.prefix = '':U
                                                                            then "linePayCode"
                                                                            else "linePayCodeCard" )
                                                                            ).
                        end.
                    end.
                end case.       /*case p-goods-gds-type*/
            end.        /* не топливо */
        end.        /* NOT ( if p-pay-desk = yes ) */
    end.
end.
end procedure. /* export-chk-pay-code */


/*==========================================================================*/
procedure fill_bgelib_goods :
define input parameter p-parent-handle  as handle           no-undo.
define input parameter p-gds-code       as integer          no-undo.

do
on error undo, return error
:
    if p-parent-handle :get-signature( "cb-fill_bgelib_goods" ) <> "":U
    then do:
        run cb-fill_bgelib_goods in p-parent-handle (
            input p-gds-code
        ).
    end.
end.
end procedure. /* fill_bgelib_goods */

/*==========================================================================*/
procedure fill_bgelib_clients :
define input parameter p-parent-handle  as handle           no-undo.
define input parameter p-obj-type       as character        no-undo.
define input parameter p-obj-code       as integer          no-undo.

do
on error undo, return error
:
    if p-parent-handle :get-signature( "cb-fill_bgelib_clients" ) <> "":U
    then do:
        run cb-fill_bgelib_clients in p-parent-handle (
              input p-obj-type
            , input p-obj-code
        ).
    end.
end.
end procedure. /* fill_bgelib_goods */