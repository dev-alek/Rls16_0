block-level on error undo, throw.
/*

$Revision: a61e6bb0c7e0, 2871, rls $
$Author: SSlivenko $
$Date: 2021/11/22 16:49:10 $
$Workfile: doc-incr.p $
$Archive: bge/doc-incr.p $

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
    p-need-chk          - надо ли выгружать чеки
    sOutFile            - имя файла .xm1 для вывода (вызывающая программа создает и по завершении
                            экспорта переименовывает этот файл в .xml. Сделано для синхронизации с
                            блоком импорта во внешней бухгалтерии.
    sLogFile            - полное имя файла для записи событий.
    hEDT                - handle поля лога (EDITOR) окна вывода
    hCNT                - handle поля счётчика (FILL-IN) окна вывода
*/
define input parameter p-host-code       as character               no-undo.
define input parameter p-cur-date        as date                    no-undo.
define input parameter p-start-date      as date                    no-undo.
define input parameter p-obj-type        as character               no-undo.
define input parameter p-obj-code        as integer                 no-undo.
define input parameter p-pay-code        as logical                 no-undo.
define input parameter p-cst             as logical                 no-undo.
define input parameter p-parts           as logical                 no-undo.
define input parameter p-chk-pay-code    as logical                 no-undo.
define input parameter p-pay-desk        as logical                 no-undo.
define input parameter p-pay-desk-cards  as logical                 no-undo.
define input parameter p-need-chk        as logical                 no-undo.
define input parameter p-need-doc-rvs    as logical                 no-undo.
define input parameter sOutFile          as character               no-undo.
define input parameter sLogFile          as character               no-undo.
define input parameter p-parent-proc     as handle                  no-undo.
define input parameter hEDT              as handle                  no-undo.
define input parameter hCNT              as handle                  no-undo.
define input parameter p-doc-type        as character               no-undo.
define input parameter p-doc-code        as character               no-undo.

define variable vss-revision    as character no-undo init "$Revision: a61e6bb0c7e0, 2871, rls $":U .
define variable vss-author      as character no-undo init "$Author: SSlivenko $":U .
define variable vss-date        as character no-undo init "$Date: 2021/11/22 16:49:10 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: doc-incr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/doc-incr.p $":U .
define variable vss-description as character no-undo init "Экспорт документов по архивам".
{ cmp/vssrevis.i        }
{ cmp/trg-def.i         }
{ bge/bge-xml.i         }
{ str/lib-trn.i         }
{ str/trdcalib.i        }
{ str/in-vatp.i def     }
{ str/out-vatp.i def    }
{ gbl/thbjattr.i }
{ ref/extclass.i }
{ ref/gds-attr.i }

define variable v-parts-cst-code  like ub.parts.cst-code     no-undo.
define variable v-exists-sale_ot-supp-tot   as logical      no-undo.
define variable v-is-petrol                 as logical      no-undo.
define variable v-is-pieces                 as logical      no-undo.
define variable v-petrol-weight             as decimal      no-undo.
define variable v-petrol-density            as decimal      no-undo.
define variable v-weight-not-specified      as logical      no-undo.
define variable v-host-code                 as integer       no-undo.
define variable v-base-code                 as integer       no-undo.
define variable v-base-code-okv             as integer       no-undo.
define variable v-is-out                    as integer       no-undo.
define variable v-inkas-pay-desk-type like ub.inkas-pay-desk.doc-type no-undo.
define variable v-found-paycode     as logical      no-undo.
define variable v-found-paycard     as logical      no-undo.

define variable v-supp-type     as character      no-undo.
define variable v-supp-code     as integer        no-undo.
define variable v-in-code       as character      no-undo.
define variable v-cst-code      as character      no-undo.

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

define temp-table tt-docs no-undo
  field fact-order  as decimal
  field doc-code    as character
  field doc-type    as character
index pi is primary unique
  fact-order
  doc-code
  doc-type
index doc
  doc-code
  doc-type
.

define buffer buf_goods for ub.goods.

/*определение таблиц необходимых для разбивки чеков по платежам*/
{ ref/cp-attr.i }
{ rep/cpapcep.i  "NEW SHARED" }
{ rep/cpapcep.i  "proc" }
{ rep/real-2df.i "NEW SHARED" treal-2 bge }
{ rep/realg3df.i "NEW SHARED" treal-3 bge }
{ rep/real-4df.i "NEW SHARED" treal-4 bge }
{ trg/factord.i  }

&scoped-define version-string "15.0 " + replace( vss-revision + vss-date, "$", " " )

do
on error undo, return error return-value
:
if not valid-handle( p-parent-proc )
then do:
    return.
end.
{ gbl/hostcode.i p-obj-type p-obj-code v-host-code }
{ gbl/basecode.i v-host-code v-base-code }

run get-base-code-okv in this-procedure (
      input v-base-code
    , output v-base-code-okv
).

run cpapcep in this-procedure .
run bge-xml-read-config in this-procedure ( input ?
                                          , input ?
                                          ).

if v-bge-xml-bgeflold <> "oracle":u
then do:
  OUTPUT STREAM stmXMLOut TO VALUE( sOutFile + "xm1" ) CONVERT TARGET "1251" APPEND.
end.

RUN wp-XMLWriteCNT( hCNT, "" ).
run export-documents in this-procedure .

if v-bge-xml-bgeflold <> "oracle":u
then do:
  output stream stmxmlout close.
end.

end.

/*==========================================================================*/
procedure export-documents :
do
on error undo, return error return-value
:
    define variable v-ext-doc-type      as character    no-undo.
    define variable v-doc-code          as character    no-undo.
    define variable v-doc-date          as date         no-undo.
    define variable v-fact-date         as date         no-undo.
    define variable v-reason-code       as integer      no-undo.
    define variable v-doc-PS            as character    no-undo.
    define variable v-firm-code         as character    no-undo.
    define variable v-ord-num           as character    no-undo.
    define variable v-ship-num          as character    no-undo.
    define variable v-ship-date         as date         no-undo.
    define variable v-pay-code          as integer      no-undo.
    define variable v-out-code          as character    no-undo.
    define variable v-fact-order        as decimal      no-undo.
    define variable v-sys-date          as date         no-undo.
    define variable v-sys-time          as character    no-undo.
    
    define variable v-supp-dog-code     as character    no-undo.
    define variable v-supp-ndog         as character    no-undo.
    define variable v-supp-ddog         as character    no-undo.

    define variable v-exp-ora-filename  as character    no-undo.
    define variable v-ora-exp-seq-num   as integer      no-undo.
    define variable v-date-from         as date         no-undo.
    define variable v-date-to           as date         no-undo.
    define variable v-obj-list          as character    no-undo.
    define variable v-error-message     as character    no-undo.
    define variable v-stop-fo           as decimal      no-undo.     
    
    define variable v-is-envd_              as logical      no-undo.   
    define variable vartype                 as character    no-undo.
    define variable varenvd                 as character    no-undo.                          
    define variable v-pr-doc-type           as logical      no-undo. 
    define variable v-sum-all-parts         as decimal      no-undo. 

    define buffer buf_trn-doc       for ub.trn-doc.
    define buffer buf_c-trn-doc     for ub.c-trn-doc.
    define buffer buf_price-doc     for ub.price-doc.
    define buffer buf_contract      for ub.contract.
    define buffer buf_ord-doc       for ub.ord-doc.
    define buffer buf_tt-docs       for tt-docs.
    define buffer buf_ot-tot        for ub.ot-tot.
    define buffer buf_doc-pl        for ub.doc-pl.


    if v-bge-xml-bgeflold = "oracle":u
    then do:
      assign
        v-obj-list = substitute( "&1,&2" , p-obj-type , p-obj-code )
      .
    end.

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

    /* выгрузка отдельного документа для Ora */
    if v-bge-xml-bgeflold = "oracle":u and
       p-doc-type <> ?                 and
       p-doc-code <> ?
    then do:
      case p-doc-type :
        when {&table_price-doc}
        then do:
          find first buf_price-doc no-lock
            where buf_price-doc.doc-num = p-doc-code
          no-error .
          if available buf_price-doc
          then do:
            output stream stmxmlout close.
            run bge-xml-ora-exp-filename in this-procedure ( input {&table_price-doc}
                                                           , input buf_price-doc.doc-num
                                                           , input p-obj-code
                                                           , output v-exp-ora-filename
                                                           , output v-ora-exp-seq-num
                                                           ) no-error .
            if error-status :error = yes
            then do:
              run wp-XMLWriteLog in this-procedure ( input sLogFile
                                                    , input 1
                                                    , input substitute( "Ошибка экспорта документа переоценки. Номер документа: &1. &2. &3 &4 "
                                                                        , buf_price-doc.doc-num
                                                                        , return-value
                                                                        , trim(error-status :get-message(1))
                                                                        , trim(error-status :get-message(2))
                                                                      )
                                                    ).
              undo, return error return-value . /* --->>>--- */
            end.
            run bge-xml-write-header in this-procedure (
                  input v-exp-ora-filename
                , input v-exp-ora-filename + "xml"
                , input {&version-string}
                , input 0
                , input v-date-from
                , input 0
                , input v-date-to
                , input 0
                , input v-obj-list
                , input ""
                , input p-pay-code
                , input p-cst
                , input p-parts
                , input p-chk-pay-code
                , input p-pay-desk
                , input p-pay-desk-cards
                , input no
                , input no
            ).
            OUTPUT STREAM stmXMLOut TO VALUE( v-exp-ora-filename + "xm1" ) CONVERT TARGET "1251" APPEND.
            run wp-XMLWriteLog in this-procedure ( input sLogFile
                                                  , input 1
                                                  , input substitute( "Выгрузка документа &1 в пакет &2."
                                                                    , buf_price-doc.doc-num
                                                                    , v-exp-ora-filename + "xml"
                                                                    )
                                                  ).
            assign
                v-doc-code     = buf_price-doc.doc-num
                v-doc-date     = buf_price-doc.doc-date
                v-fact-date    = buf_price-doc.fact-date
                v-reason-code  = 0
                v-doc-ps       = buf_price-doc.ps
                v-fact-order   = buf_price-doc.fact-order
                v-sys-date     = buf_price-doc.sys-date
                v-sys-time     = buf_price-doc.sys-time
            .
            run export-from-archive (
                  input {&TDEDT_Overturn}
                , input v-doc-code
                , input v-doc-date
                , input v-fact-date
                , input v-reason-code
                , input v-doc-ps
                , input v-fact-order
                , input v-sys-date
                , input v-sys-time
                , input ""
                , input ""
                , input ""
                , input ?
                , input 0
                , input ""
                , input ""
                , input ""
                , input 0
                , input ""
                , input ""
                , input ""
                , input ""
                , input ?
                , input ?
                , input ?
            ) no-error.
            if error-status :error
            then do:
                run wp-XMLWriteLog in this-procedure (
                      input sLogFile
                    , input 1
                    , input substitute( "Ошибка экспорта документа переоценки. Номер документа: &1. &2. &3 &4 "
                                        , v-doc-code
                                        , return-value
                                        , trim(error-status :get-message(1))
                                        , trim(error-status :get-message(2))
                                      )
                ).
                undo, return error return-value . /* --->>>--- */
            end.
            output stream stmxmlout close.
            run xml-bge-write-footer in this-procedure ( input v-exp-ora-filename ).
            run bge/setbgedt.p ( input {&table_price-doc}
                               , input v-doc-code
                               , input p-cur-date
                               ) no-error .
            if error-status :error = yes
            then do:
              run wp-XMLWriteLog in this-procedure ( input sLogFile
                                                    , input 1
                                                    , input substitute( "Ошибка установки даты выгрузки. Номер документа: &1. &2. &3 &4 "
                                                                        , v-doc-code
                                                                        , return-value
                                                                        , trim(error-status :get-message(1))
                                                                        , trim(error-status :get-message(2))
                                                                      )
                                                    ).
              if v-bge-xml-bgeflold = "oracle":u
              then do:
                return error .
              end.
            end.
            run wp-XMLWriteLog in this-procedure ( input sLogFile
                                                  , input 1
                                                  , input substitute( "Выгрузка документа &1 в пакет &2 завершена."
                                                                    , buf_price-doc.doc-num
                                                                    , v-exp-ora-filename + "xml"
                                                                    )
                                                  ).
          end. /* if available buf_price-doc */
        end. /* when {&table_price-doc} */
        when {&table_c-trn-doc}
        then do:
          export-deleted-documents:
          for each buf_c-trn-doc no-lock
            where buf_c-trn-doc.obj-type = p-obj-type
              and buf_c-trn-doc.obj-code = p-obj-code
              and buf_c-trn-doc.is-del   = yes
              and buf_c-trn-doc.doc-code = p-doc-code
          on error undo, return error return-value
          :
              if buf_c-trn-doc.bge-date = ?
              then do:
                output stream stmxmlout close.
                run bge-xml-ora-exp-filename in this-procedure ( input {&table_c-trn-doc}
                                                              , input buf_c-trn-doc.doc-code
                                                              , input p-obj-code
                                                              , output v-exp-ora-filename
                                                              , output v-ora-exp-seq-num
                                                              ) no-error .
                if error-status :error = yes
                then do:
                    run wp-XMLWriteLog in this-procedure ( input sLogFile
                                                        , input 1
                                                        , input substitute( "Ошибка экспорта удаленного документа. Номер документа: &1. &2. &3 &4 "
                                                                          , buf_c-trn-doc.doc-code
                                                                          , return-value
                                                                          , trim(error-status :get-message(1))
                                                                          , trim(error-status :get-message(2))
                                                                          )
                                                        ).
                    undo export-deleted-documents, next export-deleted-documents.
                end.
                run bge-xml-write-header in this-procedure (
                      input v-exp-ora-filename
                    , input v-exp-ora-filename + "xml"
                    , input {&version-string}
                    , input 0
                    , input v-date-from
                    , input 0
                    , input v-date-to
                    , input 0
                    , input v-obj-list
                    , input buf_c-trn-doc.ext-doc-type
                    , input p-pay-code
                    , input p-cst
                    , input p-parts
                    , input p-chk-pay-code
                    , input p-pay-desk
                    , input p-pay-desk-cards
                    , input no
                    , input no
                ).
                OUTPUT STREAM stmXMLOut TO VALUE( v-exp-ora-filename + "xm1" ) CONVERT TARGET "1251" APPEND.
                run wp-XMLWriteLog in this-procedure ( input sLogFile
                                                      , input 1
                                                      , input substitute( "Выгрузка удаленного документа &1 в пакет &2."
                                                                        , buf_c-trn-doc.doc-code
                                                                        , v-exp-ora-filename + "xml"
                                                                        )
                                                      ).


                assign
                    v-doc-code     = buf_c-trn-doc.doc-code
                .
                run export-deleted-docs in this-procedure (
                      input v-doc-code
                    , input buf_c-trn-doc.corr-user-db-num
                    , input buf_c-trn-doc.chip-num
                ) no-error.
                if error-status :error
                then do:
                    run wp-XMLWriteLog in this-procedure (
                          input sLogFile
                        , input 1
                        , input substitute( "Ошибка экспорта удаленного документа. Номер документа: &1. &2. &3 &4 "
                                            , v-doc-code
                                            , return-value
                                            , trim(error-status :get-message(1))
                                            , trim(error-status :get-message(2))
                                        )
                    ).
                    undo export-deleted-documents, next export-deleted-documents.
                end.
                output stream stmxmlout close.
                run xml-bge-write-footer in this-procedure ( input v-exp-ora-filename ).
                run bge/setbgedt.p ( input {&table_c-trn-doc}
                                   , input buf_c-trn-doc.doc-code
                                   , input p-cur-date
                                   ) no-error .
                if error-status :error = yes
                then do:
                  run wp-XMLWriteLog in this-procedure ( input sLogFile
                                                       , input 1
                                                       , input substitute( "Ошибка установки даты выгрузки. Номер документа: &1. &2. &3 &4 "
                                                                           , buf_c-trn-doc.doc-code
                                                                           , return-value
                                                                           , trim(error-status :get-message(1))
                                                                           , trim(error-status :get-message(2))
                                                                         )
                                                       ).
                  if v-bge-xml-bgeflold = "oracle":u
                  then do:
                    return error .
                  end.
                end.
                run wp-XMLWriteLog in this-procedure ( input sLogFile
                                                      , input 1
                                                      , input substitute( "Выгрузка удаленного документа &1 в пакет &2 завершена."
                                                                        , buf_c-trn-doc.doc-code
                                                                        , v-exp-ora-filename + "xml"
                                                                        )
                                                      ).
              end.
          end.        /* for each buf_c-trn-doc */
        end. /* when {&table_c-trn-doc} */
        when {&table_trn-doc}
        then do:
          find first buf_trn-doc no-lock
            where buf_trn-doc.doc-code = p-doc-code
          no-error .
          if available buf_trn-doc
          then do:
            output stream stmxmlout close.
            run bge-xml-ora-exp-filename in this-procedure ( input {&table_trn-doc}
                                                            , input buf_trn-doc.doc-code
                                                            , input p-obj-code
                                                            , output v-exp-ora-filename
                                                            , output v-ora-exp-seq-num
                                                            ) no-error .
            if error-status :error = yes
            then do:
              run wp-XMLWriteLog in this-procedure ( input sLogFile
                                                    , input 1
                                                    , input substitute( "Ошибка экспорта документа. Номер документа: &1. &2. &3 &4 "
                                                                        , buf_trn-doc.doc-code
                                                                        , return-value
                                                                        , trim(error-status :get-message(1))
                                                                        , trim(error-status :get-message(2))
                                                                      )
                                                    ).
              undo, return error return-value . /* --->>>--- */
            end.
            run bge-xml-write-header in this-procedure (
                  input v-exp-ora-filename
                , input v-exp-ora-filename + "xml"
                , input {&version-string}
                , input 0
                , input v-date-from
                , input 0
                , input v-date-to
                , input 0
                , input v-obj-list
                , input buf_trn-doc.ext-doc-type
                , input p-pay-code
                , input p-cst
                , input p-parts
                , input p-chk-pay-code
                , input p-pay-desk
                , input p-pay-desk-cards
                , input no
                , input no
            ).
            OUTPUT STREAM stmXMLOut TO VALUE( v-exp-ora-filename + "xm1" ) CONVERT TARGET "1251" APPEND.
            run wp-XMLWriteLog in this-procedure ( input sLogFile
                                                  , input 1
                                                  , input substitute( "Выгрузка документа &1 в пакет &2."
                                                                    , buf_trn-doc.doc-code
                                                                    , v-exp-ora-filename + "xml"
                                                                    )
                                                  ).
            assign
                v-supp-dog-code = "":U
                v-supp-ndog     = "":U
                v-supp-ddog     = "":U
            .
            run fill_bge-xml_clients in this-procedure (
                  input p-parent-proc
                , input buf_trn-doc.cli-type
                , input buf_trn-doc.cli-code
            ).
            assign
                v-ext-doc-type = buf_trn-doc.ext-doc-type
                v-doc-code     = buf_trn-doc.doc-code
                v-doc-date     = buf_trn-doc.doc-date
                v-fact-date    = buf_trn-doc.fact-date
                v-reason-code  = buf_trn-doc.reason-code
                v-doc-ps       = buf_trn-doc.ps
                v-fact-order   = buf_trn-doc.fact-order
                v-sys-date     = buf_trn-doc.sys-date
                v-sys-time     = buf_trn-doc.sys-time
                v-firm-code    = buf_trn-doc.cli-type + string( buf_trn-doc.cli-code )
                v-ord-num      = buf_trn-doc.ord-num
                v-ship-num     = buf_trn-doc.ship-num
                v-ship-date    = buf_trn-doc.ship-date
                v-pay-code     = buf_trn-doc.pay-code
                v-out-code     = buf_trn-doc.out-code
            .
            if v-ext-doc-type = {&TDEDT_Pri_Vnesh}
            or v-ext-doc-type = {&TDEDT_Corr_Acc_Price}
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
            run export-from-archive (
                  input v-ext-doc-type
                , input v-doc-code
                , input v-doc-date
                , input v-fact-date
                , input v-reason-code
                , input v-doc-ps
                , input v-fact-order
                , input v-sys-date
                , input v-sys-time
                , input v-firm-code
                , input v-ord-num
                , input v-ship-num
                , input v-ship-date
                , input v-pay-code
                , input buf_trn-doc.hold-doc-code-child
                , input buf_trn-doc.hold-doc-code-parent
                , input buf_trn-doc.hold-obj-type
                , input buf_trn-doc.hold-obj-code
                , input v-out-code
                , input v-supp-dog-code
                , input v-supp-ndog
                , input v-supp-ddog
                , input buf_trn-doc.d-card
                , input buf_trn-doc.cli-type
                , input buf_trn-doc.cli-code
            ) no-error.
            if error-status :error
            then do:
                run wp-XMLWriteLog in this-procedure (
                      input sLogFile
                    , input 1
                    , input substitute( "Ошибка экспорта складского документа. Номер документа: &1. &2. &3 &4 "
                                        , v-doc-code
                                        , return-value
                                        , trim(error-status :get-message(1))
                                        , trim(error-status :get-message(2))
                                      )
                ).
                undo, return error return-value. /* --->>>--- */
            end.
            /* Пометить выгруженные - прописать поле trn-doc.bge-date */
            output stream stmxmlout close.
            run xml-bge-write-footer in this-procedure ( input v-exp-ora-filename ).
            run bge/setbgedt.p ( input {&table_trn-doc}
                               , input buf_trn-doc.doc-code
                               , input p-cur-date
                               ) no-error .
            if error-status :error = yes
            then do:
              run wp-XMLWriteLog in this-procedure ( input sLogFile
                                                    , input 1
                                                    , input substitute( "Ошибка установки даты выгрузки. Номер документа: &1. &2. &3 &4 "
                                                                        , buf_trn-doc.doc-code
                                                                        , return-value
                                                                        , trim(error-status :get-message(1))
                                                                        , trim(error-status :get-message(2))
                                                                      )
                                                    ).
              if v-bge-xml-bgeflold = "oracle":u
              then do:
                return error .
              end.
            end.

            run wp-XMLWriteLog in this-procedure ( input sLogFile
                                                  , input 1
                                                  , input substitute( "Выгрузка документа &1 в пакет &2 завершена."
                                                                    , buf_trn-doc.doc-code
                                                                    , v-exp-ora-filename + "xml"
                                                                    )
                                                  ).
          end. /* if available buf_trn-doc */
        end. /* when {&table_trn-doc} */
        when {&table_ord-doc}
        then do:
          find first buf_ord-doc no-lock
            where buf_ord-doc.doc-code = p-doc-code
          no-error .
          if available buf_ord-doc
          then do:
            run bge/doc-ord.p ( input yes
                              , input p-host-code
                              , input p-obj-type
                              , input p-obj-code
                              , input p-start-date
                              , input ?
                              , input {&o-p}
                              , input {&ord-rcv}
                              , input sOutFile
                              , input sLogFile
                              , input p-parent-proc
                              , input hEDT
                              , input hCNT
                              , input buf_ord-doc.doc-code
                              ) no-error .
            if error-status :error
            then do:
                run wp-XMLWriteLog in this-procedure ( input sLogFile
                                                    , input 1
                                                    , input substitute( "Ошибка экспорта заказа: &5. &1&2.&1&3&1&4 "
                                                                      , {&new-line}
                                                                      , return-value
                                                                      , trim(error-status :get-message(1))
                                                                      , trim(error-status :get-message(2))
                                                                      , p-doc-code
                                                                      )
                                                    ).
            end.
          end.
        end. /* when {&table_ord-doc} */
        otherwise do:
          undo, return error substitute( "Недопустимый тип документа: &1 ":U , p-doc-type ) .
        end.
      end case.
      return . /* --->>>--- */
    end.

    find last buf_ot-tot no-lock
      where buf_ot-tot.obj-type = p-obj-type
        and buf_ot-tot.obj-code = p-obj-code
    use-index obj-ot
    no-error .                            
    
    if not available buf_ot-tot
    then do:
      run wp-XMLWriteLog in this-procedure ( input sLogFile
                                           , input 1
                                           , input "Не найдены архивы...":U
                                           ).
      undo, return error.
    end.
    assign
      v-stop-fo = buf_ot-tot.fact-order
    .

    run wp-XMLWriteLog in this-procedure ( input sLogFile
                                         , input 1
                                         , input 'Сбор документов для выгрузки'
                                         ).

    empty temp-table buf_tt-docs.
    /* собираем все выгружаемые документы переоценок */
    _price-doc-cycle:
    for each buf_price-doc no-lock
       where buf_price-doc.obj-type = p-obj-type
         and buf_price-doc.obj-code = p-obj-code
         and buf_price-doc.bge-date = ?
         and buf_price-doc.status_  = {&act-overvalue}
         and buf_price-doc.fact-date >= p-start-date
         and buf_price-doc.fact-order > 0
    use-index bge-obj
    on error undo, return error
    :
      if buf_price-doc.fact-order > v-stop-fo
      then do:
        next _price-doc-cycle.
      end.
      find first buf_tt-docs no-lock
        where buf_tt-docs.fact-order  = buf_price-doc.fact-order
          and buf_tt-docs.doc-code    = buf_price-doc.doc-num
          and buf_tt-docs.doc-type    = {&table_price-doc}
      no-error .
      if not available buf_tt-docs
      then do:
        create buf_tt-docs.
        assign
          buf_tt-docs.fact-order = buf_price-doc.fact-order
          buf_tt-docs.doc-code   = buf_price-doc.doc-num
          buf_tt-docs.doc-type   = {&table_price-doc}
        .
      end.
    end.

    /* собираем все выгружаемые документы */
    _trn-doc-cycle:
    for each buf_trn-doc no-lock
       where buf_trn-doc.obj-type = p-obj-type
         and buf_trn-doc.obj-code = p-obj-code
         and buf_trn-doc.bge-date = ?
         and buf_trn-doc.status_  = {&fact}
         and buf_trn-doc.fact-date >= p-start-date
         and buf_trn-doc.fact-order > 0
    on error undo, return error
    :
      if buf_trn-doc.fact-order > v-stop-fo
      then do:
        next _trn-doc-cycle.
      end.
      find first buf_tt-docs no-lock
        where buf_tt-docs.fact-order  = buf_trn-doc.fact-order
          and buf_tt-docs.doc-code    = buf_trn-doc.doc-code
          and buf_tt-docs.doc-type    = {&table_trn-doc}
      no-error .
      if not available buf_tt-docs
      then do:
        create buf_tt-docs.
        assign
          buf_tt-docs.fact-order = buf_trn-doc.fact-order
          buf_tt-docs.doc-code   = buf_trn-doc.doc-code
          buf_tt-docs.doc-type   = {&table_trn-doc}
        .
      end.
    end.

    run wp-XMLWriteLog in this-procedure ( input sLogFile
                                         , input 1
                                         , input 'Выгрузка документов по fact-order...'
                                         ).  
                                         
                                       
    _docs-cycle:
    for each buf_tt-docs no-lock  
    : 
      find first buf_trn-doc share-lock
        where buf_trn-doc.doc-code = buf_tt-docs.doc-code          
        no-error .
        
      if avail buf_trn-doc 
        then assign v-ext-doc-type = buf_trn-doc.ext-doc-type .
      else v-ext-doc-type = " " .       
        
      if  v-ext-doc-type = {&TDEDT_Pri_Vnesh}            
          /* or v-ext-doc-type = {&TDEDT_Ras_Vnesh_VP}    возврат поставщику */
          then assign v-pr-doc-type = YES .    

      { str/tdat-val.i                                    
         buf_tt-docs.doc-code
         {&trdcattr-envd}
         varenvd 
         vartype } 
            
      if    varenvd eq "YES"                                                          
          and v-pr-doc-type eq YES
          then                
          v-is-envd_ = YES .  
      else  v-is-envd_ = NO .   

      if v-is-envd_ = YES 
        then                                                                         
        run calc-lines in this-procedure (
        input  buf_tt-docs.doc-code ,
        output v-sum-all-parts
        ) no-error. 
      else  
        v-sum-all-parts = 0 .    
    
      _export-block:
      do transaction
      on error undo _export-block , return error return-value
      :
        case buf_tt-docs.doc-type
        :
          when {&table_price-doc}
          then do:
            find first buf_price-doc share-lock
              where buf_price-doc.doc-num = buf_tt-docs.doc-code
            no-wait
            no-error .
            if not available buf_price-doc
            then do:
              run wp-XMLWriteLog in this-procedure ( input sLogFile
                                                   , input 1
                                                   , input substitute( "Документ &1 обрабатывается. Выгрузка приостановлена."
                                                                       , buf_tt-docs.doc-code
                                                                       , return-value
                                                                       , trim(error-status :get-message(1))
                                                                       , trim(error-status :get-message(2))
                                                                     )
                                                   ).
              undo _export-block, return . /* --->>>--- */
            end.
            if available buf_price-doc
            then do:
              if v-bge-xml-bgeflold = "oracle":u
              then do:
                output stream stmxmlout close.
                run bge-xml-ora-exp-filename in this-procedure ( input {&table_price-doc}
                                                              , input buf_tt-docs.doc-code
                                                              , input p-obj-code
                                                              , output v-exp-ora-filename
                                                              , output v-ora-exp-seq-num
                                                              ) no-error .
                if error-status :error = yes
                then do:
                  run wp-XMLWriteLog in this-procedure ( input sLogFile
                                                      , input 1
                                                      , input substitute( "Ошибка экспорта документа переоценки. Номер документа: &1. &2. &3 &4 "
                                                                          , buf_tt-docs.doc-code
                                                                          , return-value
                                                                          , trim(error-status :get-message(1))
                                                                          , trim(error-status :get-message(2))
                                                                        )
                                                      ).

                  undo _export-block, return . /* --->>>--- */
                end.
                run bge-xml-write-header in this-procedure (
                      input v-exp-ora-filename
                    , input v-exp-ora-filename + "xml"
                    , input {&version-string}
                    , input 0
                    , input v-date-from
                    , input 0
                    , input v-date-to
                    , input 0
                    , input v-obj-list
                    , input ""
                    , input p-pay-code
                    , input p-cst
                    , input p-parts
                    , input p-chk-pay-code
                    , input p-pay-desk
                    , input p-pay-desk-cards
                    , input no
                    , input no
                ).
                OUTPUT STREAM stmXMLOut TO VALUE( v-exp-ora-filename + "xm1" ) CONVERT TARGET "1251" APPEND.
                run wp-XMLWriteLog in this-procedure ( input sLogFile
                                                    , input 1
                                                    , input substitute( "Выгрузка документа &1 в пакет &2."
                                                                      , buf_tt-docs.doc-code
                                                                      , v-exp-ora-filename + "xml"
                                                                      )
                                                    ).
              end.
              assign
                  v-doc-code     = buf_price-doc.doc-num
                  v-doc-date     = buf_price-doc.doc-date
                  v-fact-date    = buf_price-doc.fact-date
                  v-reason-code  = 0
                  v-doc-ps       = buf_price-doc.ps
                  v-fact-order   = buf_price-doc.fact-order
                  v-sys-date     = buf_price-doc.sys-date
                  v-sys-time     = buf_price-doc.sys-time
              .
              run export-from-archive (
                    input {&TDEDT_Overturn}
                  , input v-doc-code
                  , input v-doc-date
                  , input v-fact-date
                  , input v-reason-code
                  , input v-doc-ps
                  , input v-fact-order
                  , input v-sys-date
                  , input v-sys-time
                  , input ""
                  , input ""
                  , input ""
                  , input ?
                  , input 0
                  , input ""
                  , input ""
                  , input ""
                  , input 0
                  , input ""
                  , input ""
                  , input ""
                  , input ""
                  , input ?
                  , input ?
                  , input ?
                  , input v-is-envd_ 
                  , input v-sum-all-parts
              ) no-error.
              if error-status :error
              then do:
                  run wp-XMLWriteLog in this-procedure (
                        input sLogFile
                      , input 1
                      , input substitute( "Ошибка экспорта документа переоценки. Номер документа: &1. &2. &3 &4 "
                                          , v-doc-code
                                          , return-value
                                          , trim(error-status :get-message(1))
                                          , trim(error-status :get-message(2))
                                        )
                  ).
                  if v-bge-xml-bgeflold = "oracle":u
                  then do:
                    undo _export-block, return . /* --->>>--- */
                  end.
                  else do:
                    undo _export-block, next _docs-cycle.
                  end.
              end.
              if v-bge-xml-bgeflold = "oracle":u
              then do:
                output stream stmxmlout close.
                run xml-bge-write-footer in this-procedure ( input v-exp-ora-filename ).
                run bge/setbgedt.p ( input {&table_price-doc}
                                   , input v-doc-code
                                   , input p-cur-date
                                   ) no-error .
                if error-status :error = yes
                then do:
                  run wp-XMLWriteLog in this-procedure ( input sLogFile
                                                       , input 1
                                                       , input substitute( "Ошибка установки даты выгрузки. Номер документа: &1. &2. &3 &4 "
                                                                           , v-doc-code
                                                                           , return-value
                                                                           , trim(error-status :get-message(1))
                                                                           , trim(error-status :get-message(2))
                                                                         )
                                                       ).
                  undo _export-block, return error .
                end.
                run wp-XMLWriteLog in this-procedure ( input sLogFile
                                                    , input 1
                                                    , input substitute( "Выгрузка документа &1 в пакет &2 завершена."
                                                                      , buf_tt-docs.doc-code
                                                                      , v-exp-ora-filename + "xml"
                                                                      )
                                                    ).
              end.
              else do:
                run run-callback-write-doc-code in this-procedure ( input p-parent-proc
                                                                  , input {&table_price-doc}
                                                                  , input v-doc-code
                                                                  , input sLogFile
                                                                  ).
              end.

            end. /* if available buf_price-doc */
          end. /* when {&table_price-doc} */
          when {&table_trn-doc}
          then do:
            find first buf_trn-doc share-lock
              where buf_trn-doc.doc-code = buf_tt-docs.doc-code
            no-error .
            if not available buf_trn-doc
            then do:
              run wp-XMLWriteLog in this-procedure ( input sLogFile
                                                   , input 1
                                                   , input substitute( "Документ &1 обрабатывается. Выгрузка приостановлена."
                                                                       , buf_tt-docs.doc-code
                                                                       , return-value
                                                                       , trim(error-status :get-message(1))
                                                                       , trim(error-status :get-message(2))
                                                                     )
                                                   ).
              undo _export-block, return . /* --->>>--- */
            end.
            if available buf_trn-doc
            then do:
              if v-bge-xml-bgeflold = "oracle":u
              then do:
                output stream stmxmlout close.
                run bge-xml-ora-exp-filename in this-procedure ( input {&table_trn-doc}
                                                              , input buf_tt-docs.doc-code
                                                              , input p-obj-code
                                                              , output v-exp-ora-filename
                                                              , output v-ora-exp-seq-num
                                                              ) no-error .
                if error-status :error = yes
                then do:
                  run wp-XMLWriteLog in this-procedure ( input sLogFile
                                                      , input 1
                                                      , input substitute( "Ошибка экспорта документа. Номер документа: &1. &2. &3 &4 "
                                                                          , buf_tt-docs.doc-code
                                                                          , return-value
                                                                          , trim(error-status :get-message(1))
                                                                          , trim(error-status :get-message(2))
                                                                        )
                                                      ).
                  if v-bge-xml-bgeflold = "oracle":u
                  then do:
                    undo _export-block, return . /* --->>>--- */
                  end.
                  else do:
                    undo _export-block, next _docs-cycle.
                  end.
                end.
                run bge-xml-write-header in this-procedure (
                      input v-exp-ora-filename
                    , input v-exp-ora-filename + "xml"
                    , input {&version-string}
                    , input 0
                    , input v-date-from
                    , input 0
                    , input v-date-to
                    , input 0
                    , input v-obj-list
                    , input buf_trn-doc.ext-doc-type
                    , input p-pay-code
                    , input p-cst
                    , input p-parts
                    , input p-chk-pay-code
                    , input p-pay-desk
                    , input p-pay-desk-cards
                    , input no
                    , input no
                ).
                OUTPUT STREAM stmXMLOut TO VALUE( v-exp-ora-filename + "xm1" ) CONVERT TARGET "1251" APPEND.
                run wp-XMLWriteLog in this-procedure ( input sLogFile
                                                    , input 1
                                                    , input substitute( "Выгрузка документа &1 в пакет &2."
                                                                      , buf_tt-docs.doc-code
                                                                      , v-exp-ora-filename + "xml"
                                                                      )
                                                    ).
              end.

              assign
                  v-supp-dog-code = "":U
                  v-supp-ndog     = "":U
                  v-supp-ddog     = "":U
              .
              run fill_bge-xml_clients in this-procedure (
                    input p-parent-proc
                  , input buf_trn-doc.cli-type
                  , input buf_trn-doc.cli-code
              ).
              assign
                  v-ext-doc-type = buf_trn-doc.ext-doc-type
                  v-doc-code     = buf_trn-doc.doc-code
                  v-doc-date     = buf_trn-doc.doc-date
                  v-fact-date    = buf_trn-doc.fact-date
                  v-reason-code  = buf_trn-doc.reason-code
                  v-doc-ps       = buf_trn-doc.ps
                  v-fact-order   = buf_trn-doc.fact-order
                  v-sys-date     = buf_trn-doc.sys-date
                  v-sys-time     = buf_trn-doc.sys-time
                  v-firm-code    = buf_trn-doc.cli-type + string( buf_trn-doc.cli-code )
                  v-ord-num      = buf_trn-doc.ord-num
                  v-ship-num     = buf_trn-doc.ship-num
                  v-ship-date    = buf_trn-doc.ship-date
                  v-pay-code     = buf_trn-doc.pay-code
                  v-out-code     = buf_trn-doc.out-code
              .
              if v-ext-doc-type = {&TDEDT_Pri_Vnesh}
              or v-ext-doc-type = {&TDEDT_Corr_Acc_Price}
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
              run export-from-archive (
                    input v-ext-doc-type
                  , input v-doc-code
                  , input v-doc-date
                  , input v-fact-date
                  , input v-reason-code
                  , input v-doc-ps
                  , input v-fact-order
                  , input v-sys-date
                  , input v-sys-time
                  , input v-firm-code
                  , input v-ord-num
                  , input v-ship-num
                  , input v-ship-date
                  , input v-pay-code
                  , input buf_trn-doc.hold-doc-code-child
                  , input buf_trn-doc.hold-doc-code-parent
                  , input buf_trn-doc.hold-obj-type
                  , input buf_trn-doc.hold-obj-code
                  , input v-out-code
                  , input v-supp-dog-code
                  , input v-supp-ndog
                  , input v-supp-ddog
                  , input buf_trn-doc.d-card
                  , input buf_trn-doc.cli-type
                  , input buf_trn-doc.cli-code 
                  , input v-is-envd_
                  , input v-sum-all-parts
              ) no-error.
              if error-status :error
              then do:
                  run wp-XMLWriteLog in this-procedure (
                        input sLogFile
                      , input 1
                      , input substitute( "Ошибка экспорта складского документа. Номер документа: &1. &2. &3 &4 "
                                          , v-doc-code
                                          , return-value
                                          , trim(error-status :get-message(1))
                                          , trim(error-status :get-message(2))
                                        )
                  ).
                  if v-bge-xml-bgeflold = "oracle":u
                  then do:
                    undo _export-block, return . /* --->>>--- */
                  end.
                  else do:
                    undo _export-block, next _docs-cycle.
                  end.
              end.
              /* Пометить выгруженные - прописать поле trn-doc.bge-date */
              if v-bge-xml-bgeflold = "oracle":u
              then do:
                output stream stmxmlout close.
                run xml-bge-write-footer in this-procedure ( input v-exp-ora-filename ).
                run bge/setbgedt.p ( input {&table_trn-doc}
                                   , input buf_trn-doc.doc-code
                                   , input p-cur-date
                                   ) no-error .
                if error-status :error = yes
                then do:
                  run wp-XMLWriteLog in this-procedure ( input sLogFile
                                                       , input 1
                                                       , input substitute( "Ошибка установки даты выгрузки. Номер документа: &1. &2. &3 &4 "
                                                                           , buf_trn-doc.doc-code
                                                                           , return-value
                                                                           , trim(error-status :get-message(1))
                                                                           , trim(error-status :get-message(2))
                                                                         )
                                                       ).
                  undo _export-block, return error .
                end.
                run wp-XMLWriteLog in this-procedure ( input sLogFile
                                                    , input 1
                                                    , input substitute( "Выгрузка документа &1 в пакет &2 завершена."
                                                                      , buf_tt-docs.doc-code
                                                                      , v-exp-ora-filename + "xml"
                                                                      )
                                                    ).
              end.
              else do:
                run run-callback-write-doc-code in this-procedure ( input p-parent-proc
                                                                  , input {&table_trn-doc}
                                                                  , input buf_trn-doc.doc-code
                                                                  , input sLogFile
                                                                  ).
              end.
            end. /* if available buf_trn-doc */
          end. /* when {&table_trn-doc} */
        end case.
      end.
    end.
    run wp-XMLWriteLog in this-procedure ( input sLogFile
                                         , input 1
                                         , input 'Выгрузка удаленных документов...'
                                         ).
    export-deleted-documents:
    for each buf_c-trn-doc no-lock
       where buf_c-trn-doc.obj-type = p-obj-type
         and buf_c-trn-doc.obj-code = p-obj-code
         and buf_c-trn-doc.is-del   = yes
    on error undo, return error
    :
      _export-block:
      do transaction
      on error undo _export-block , return error return-value
      :
        if buf_c-trn-doc.bge-date = ?
        then do:
          if v-bge-xml-bgeflold = "oracle":u
          then do:
            output stream stmxmlout close.
            run bge-xml-ora-exp-filename in this-procedure ( input {&table_c-trn-doc}
                                                           , input buf_c-trn-doc.doc-code
                                                           , input p-obj-code
                                                           , output v-exp-ora-filename
                                                           , output v-ora-exp-seq-num
                                                           ) no-error .
            if error-status :error = yes
            then do:
                run wp-XMLWriteLog in this-procedure ( input sLogFile
                                                     , input 1
                                                     , input substitute( "Ошибка экспорта удаленного документа. Номер документа: &1. &2. &3 &4 "
                                                                       , buf_c-trn-doc.doc-code
                                                                       , return-value
                                                                       , trim(error-status :get-message(1))
                                                                       , trim(error-status :get-message(2))
                                                                       )
                                                     ).
                if v-bge-xml-bgeflold = "oracle":u
                then do:
                  undo export-deleted-documents, return . /* --->>>--- */
                end.
                else do:
                  undo export-deleted-documents, next export-deleted-documents.
                end.
            end.
            run bge-xml-write-header in this-procedure (
                  input v-exp-ora-filename
                , input v-exp-ora-filename + "xml"
                , input {&version-string}
                , input 0
                , input v-date-from
                , input 0
                , input v-date-to
                , input 0
                , input v-obj-list
                , input buf_c-trn-doc.ext-doc-type
                , input p-pay-code
                , input p-cst
                , input p-parts
                , input p-chk-pay-code
                , input p-pay-desk
                , input p-pay-desk-cards
                , input no
                , input no
            ).
            OUTPUT STREAM stmXMLOut TO VALUE( v-exp-ora-filename + "xm1" ) CONVERT TARGET "1251" APPEND.
            run wp-XMLWriteLog in this-procedure ( input sLogFile
                                                  , input 1
                                                  , input substitute( "Выгрузка удаленного документа &1 в пакет &2."
                                                                    , buf_c-trn-doc.doc-code
                                                                    , v-exp-ora-filename + "xml"
                                                                    )
                                                  ).

          end.

          assign
	            v-doc-code     = buf_c-trn-doc.doc-code
          .
          run export-deleted-docs in this-procedure (
                input v-doc-code
              , input buf_c-trn-doc.corr-user-db-num
              , input buf_c-trn-doc.chip-num
          ) no-error.
          if error-status :error
          then do:
              run wp-XMLWriteLog in this-procedure (
                    input sLogFile
                  , input 1
                  , input substitute( "Ошибка экспорта удаленного документа. Номер документа: &1. &2. &3 &4 "
                                      , v-doc-code
                                      , return-value
                                      , trim(error-status :get-message(1))
                                      , trim(error-status :get-message(2))
                                  )
              ).
              if v-bge-xml-bgeflold = "oracle":u
              then do:
                undo export-deleted-documents, return . /* --->>>--- */
              end.
              else do:
                undo export-deleted-documents, next export-deleted-documents.
              end.
          end.
          if v-bge-xml-bgeflold = "oracle":u
          then do:
            output stream stmxmlout close.
            run xml-bge-write-footer in this-procedure ( input v-exp-ora-filename ).
            run bge/setbgedt.p ( input {&table_c-trn-doc}
                               , input buf_c-trn-doc.doc-code
                               , input p-cur-date
                               ) no-error .
            if error-status :error = yes
            then do:
              run wp-XMLWriteLog in this-procedure ( input sLogFile
                                                    , input 1
                                                    , input substitute( "Ошибка установки даты выгрузки. Номер документа: &1. &2. &3 &4 "
                                                                        , buf_c-trn-doc.doc-code
                                                                        , return-value
                                                                        , trim(error-status :get-message(1))
                                                                        , trim(error-status :get-message(2))
                                                                      )
                                                    ).
              undo _export-block, return error .
            end.

            run wp-XMLWriteLog in this-procedure ( input sLogFile
                                                  , input 1
                                                  , input substitute( "Выгрузка удаленного документа &1 в пакет &2 завершена."
                                                                    , buf_c-trn-doc.doc-code
                                                                    , v-exp-ora-filename + "xml"
                                                                    )
                                                  ).

          end.
          else do:
            /* Пометить выгруженные - прописать поле c-trn-doc.bge-date */
            run run-callback-write-doc-code in this-procedure ( input p-parent-proc
                                                              , input {&table_c-trn-doc}
                                                              , input buf_c-trn-doc.doc-code
                                                              , input sLogFile
                                                              ).
          end.
        end.
      end. /* _export-block */
    end.        /* for each buf_c-trn-doc */

    if v-bge-xml-bgeflold = "oracle":u
    then do:
      run bge/doc-ord.p ( input yes
                        , input p-host-code
                        , input p-obj-type
                        , input p-obj-code
                        , input p-start-date
                        , input ?
                        , input {&o-p}
                        , input {&ord-rcv}
                        , input sOutFile
                        , input sLogFile
                        , input p-parent-proc
                        , input hEDT
                        , input hCNT
                        , input ?
                        ) no-error .
      if error-status :error
      then do:
          run wp-XMLWriteLog in this-procedure ( input sLogFile
                                              , input 1
                                              , input substitute( "Ошибка экспорта заказов. &1&2.&1&3&1&4 "
                                                                , {&new-line}
                                                                , return-value
                                                                , trim(error-status :get-message(1))
                                                                , trim(error-status :get-message(2))
                                                                )
                                              ).
      end.
    end. /* if v-bge-xml-bgeflold = "oracle":u */
    empty temp-table buf_tt-docs.
end.
end procedure. /* export-documents */


/*==========================================================================*/
procedure export-from-archive :
define input parameter p-ext-doc-type           as character        no-undo.
define input parameter p-doc-code               as character        no-undo.
define input parameter p-doc-date               as date             no-undo.
define input parameter p-fact-date              as date             no-undo.
define input parameter p-reason-code            as integer          no-undo.
define input parameter p-doc-PS                 as character        no-undo.
define input parameter p-fact-order             as decimal          no-undo.
define input parameter p-sys-date               as date             no-undo.
define input parameter p-sys-time               as character        no-undo.
define input parameter p-firm-code              as character        no-undo.
define input parameter p-ord-num                as character        no-undo.
define input parameter p-ship-num               as character        no-undo.
define input parameter p-ship-date              as date             no-undo.
define input parameter p-payment-code           as integer          no-undo.
define input parameter p-hold-doc-code-child    as character        no-undo.
define input parameter p-hold-doc-code-parent   as character        no-undo.
define input parameter p-hold-obj-type          as character        no-undo.
define input parameter p-hold-obj-code          as integer          no-undo.
define input parameter p-out-code               as character        no-undo.
define input parameter p-supp-dog-code          as character        no-undo.
define input parameter p-supp-ndog              as character        no-undo.
define input parameter p-supp-ddog              as character        no-undo.
define input parameter p-d-card                 as character        no-undo.
define input parameter p-cli-type               as character        no-undo.
define input parameter p-cli-code               as integer          no-undo.

define input parameter p-is-envd_               as logical          no-undo.
define input parameter p-sum-all-parts          as decimal          no-undo.
    define variable v-exists-before     as logical      no-undo.
    define variable v-exists-after      as logical      no-undo.
    define variable v-obj-type          as character    no-undo.
    define variable v-obj-code          as integer      no-undo.
    define variable v-qnty              as decimal      no-undo.

    define variable v-excise-base       as decimal      no-undo.
    define variable v-country-code      as character    no-undo.
    define variable v-excise-rubl       as decimal      no-undo.
    define variable v-transport-base    as decimal      no-undo.
    define variable v-transport-rubl    as decimal      no-undo.
    define variable v-other-base        as decimal      no-undo.
    define variable v-other-rubl        as decimal      no-undo.
    define variable v-today             as date         no-undo.
    define variable v-time              as integer      no-undo.
    define variable v-scale-is-empty    as logical      no-undo.
    
           define variable ii                      as integer   no-undo.
        define variable v-attrcode              as char no-undo.
        define variable v-SectionName           as char no-undo.
        define variable v-DocQnty               as decimal no-undo.
        define variable v-CliQnty               as decimal no-undo.
        define variable v-FactQnty              as decimal no-undo.
        define variable v-FactDensity           as decimal no-undo.
        define variable v-DocDensity            as decimal no-undo.
        define variable v-TankVol               as decimal no-undo.
        define variable v-TankDensity           as decimal no-undo.
        define variable v-TankDensityPomi       as decimal no-undo.
        define variable v-TankVolPomi           as decimal no-undo.  
        define variable v-tank-vol              as decimal   no-undo .
        define variable v-tank-density          as decimal   no-undo .
        define variable v-SectionNum            as integer   no-undo.
        define variable v-total-tank-density    as decimal   no-undo.
        define variable v-tankweight            as decimal   no-undo.   
        
        define variable v-sum-parts             as decimal   no-undo.
        
    define buffer buf_ot-tot-sale           for ub.ot-tot.
    define buffer buf_ot-tot-cost           for ub.ot-tot.
    define buffer buf_ot-tot-crsa           for ub.ot-tot.
    define buffer buf_ot-tot-crsa-loop      for ub.ot-tot.
    define buffer buf_ot-line-sale          for ub.ot-line.
    define buffer buf_ot-line-cost          for ub.ot-line.
    define buffer buf_ot-line-crsa          for ub.ot-line.
    define buffer buf_ot-line-crsa-loop     for ub.ot-line.
    define buffer buf_cost_ot-supp-line     for ub.ot-supp-line.
    define buffer buf_sale_ot-supp-line     for ub.ot-supp-line.
    define buffer buf_cost_ot-supp-tot      for ub.ot-supp-tot.
    define buffer buf_sale_ot-supp-tot      for ub.ot-supp-tot.
    define buffer buf_doc-line              for ub.doc-line.
    define buffer buf_parts                 for ub.parts.
    define buffer buf_parts-attr            for ub.parts-attr.
    define buffer buf_parts-root            for parts-root.
    define buffer buf_doc-line-sum          for ub.doc-line-sum.
    define buffer buf_inkas                 for ub.inkas.
    define buffer buf_units                 for ub.units.
    define buffer buf_price-list            for ub.price-list.
    define buffer buf_doc-line-attr         for ub.doc-line-attr.
    define buffer buf_doc-pl                for ub.doc-pl.

do
for buf_ot-tot-sale
  , buf_ot-tot-cost
  , buf_ot-tot-crsa
  , buf_ot-tot-crsa-loop
  , buf_ot-line-sale
  , buf_ot-line-cost
  , buf_ot-line-crsa
  , buf_ot-line-crsa-loop
  , buf_cost_ot-supp-line
  , buf_sale_ot-supp-line
  , buf_cost_ot-supp-tot
  , buf_sale_ot-supp-tot
  , buf_doc-line
  , buf_parts
  , buf_parts-attr
  , buf_parts-root
  , buf_doc-line-sum
  , buf_inkas
  , buf_units
  , buf_price-list
on error undo, return error return-value
on endkey undo, return error return-value
:
    find first buf_ot-tot-crsa-loop no-lock
         where buf_ot-tot-crsa-loop.doc-code    = p-doc-code
           and buf_ot-tot-crsa-loop.sum-type    = {&arh-crsa}
           and buf_ot-tot-crsa-loop.cat-id      = {&root-cat-id}
    no-error.
    if not available buf_ot-tot-crsa-loop
    then do:
        run wp-XMLWriteLog( sLogFile, 1, substitute("Для документа &1 не найдена запись в архиве." , p-doc-code )).
        undo, return error .
    end.
    assign
        v-obj-type = buf_ot-tot-crsa-loop.obj-type
        v-obj-code = buf_ot-tot-crsa-loop.obj-code
    .
    case p-ext-doc-type
    :
        when {&TDEDT_Overturn}
        then do:
            find first buf_ot-tot-sale no-lock
                 where buf_ot-tot-sale.doc-code = p-doc-code
                   and buf_ot-tot-sale.sum-type = {&arh-crsa}
                   and buf_ot-tot-sale.cat-id   = buf_ot-tot-crsa-loop.cat-id
            no-error.
            if not available buf_ot-tot-sale
            then do:
                run wp-XMLWriteLog( sLogFile, 1, "Не найден документ переоценки " + string( p-doc-code ) ).
                undo, return error.
            end.
        end.
        otherwise do:
            find first buf_ot-tot-sale no-lock
                 where buf_ot-tot-sale.doc-code = p-doc-code
                   and buf_ot-tot-sale.sum-type = {&arh-sale}
                   and buf_ot-tot-sale.cat-id   = buf_ot-tot-crsa-loop.cat-id
            no-error.
            if not available buf_ot-tot-sale
            then do:
                find first buf_ot-tot-sale no-lock
                     where buf_ot-tot-sale.doc-code = p-doc-code
                       and buf_ot-tot-sale.sum-type = {&arh-sale-service}
                       and buf_ot-tot-sale.cat-id   = buf_ot-tot-crsa-loop.cat-id
                no-error.
            end.
            if not available buf_ot-tot-sale
            then do:
                if buf_ot-tot-crsa-loop.fact-qnty <> 0
                then do:
                    run wp-XMLWriteLog( sLogFile, 1, "В архивах нет записей sum-type = {&arh-sale} или {&arh-sale-service} для документа номер " + string( p-doc-code ) + " ( ext-doc-type = " + p-ext-doc-type + ")" ).
                end.
/*                    undo, return .*/
            end.
            else do:
                if buf_ot-tot-crsa-loop.fact-qnty <> buf_ot-tot-sale.fact-qnty
                then do:
                    run wp-XMLWriteLog( sLogFile, 1, "Не совпадает фактическое количество для записей архивов sum-type = {&arh-sale} и {&arh-crsa} для документа номер " + string( p-doc-code ) + " ( ext-doc-type = " + p-ext-doc-type + ")" ).
                end.
            end.
        end.
    end case.
    run wp-XMLWriteCnt( hcnt, "   " + string( p-doc-code ) + " от " + string( p-fact-date ) ) .
    process events.
    run write-doc-header in this-procedure (
          input v-obj-type
        , input v-obj-code
        , input p-ext-doc-type
        , input p-doc-code
        , input p-doc-date
        , input p-fact-date
        , input p-reason-code
        , input p-doc-PS
        , input p-fact-order
        , input p-sys-date
        , input p-sys-time
        , input p-firm-code
        , input p-ord-num
        , input p-ship-num
        , input p-ship-date
        , input p-payment-code
        , input p-hold-doc-code-child
        , input p-hold-doc-code-parent
        , input p-hold-obj-type
        , input p-hold-obj-code
        , input p-out-code
        , input p-supp-dog-code
        , input p-supp-ndog
        , input p-supp-ddog
        , input p-d-card
        , input p-cli-type
        , input p-cli-code
    ) no-error.

    /*---START--------- Суммы по видам кассовых платежей ---------------------*/
    if p-ext-doc-type <> {&TDEDT_Overturn}
    and p-pay-code = yes
    or ( p-chk-pay-code = yes
    and ( p-ext-doc-type = {&TDEDT_Ras_Vnesh_Kass} or p-ext-doc-type = {&TDEDT_Vozvrat_Vnesh_Kass} ) )
    then do:
            case p-ext-doc-type :
                when {&TDEDT_Ras_Vnesh_Kass}
                then do:
                    assign
                        v-is-out                = 1
                        v-inkas-pay-desk-type   = {&income}
                    .
                    find first buf_inkas no-lock
                            where buf_inkas.inkas-code = p-doc-code
                    no-error.
                end.
                when {&TDEDT_Vozvrat_Vnesh_Kass}
                then do:
                    assign
                        v-is-out                = -1
                        v-inkas-pay-desk-type   = {&expense}
                    .
                    find first buf_inkas no-lock
                            where buf_inkas.inkas-code = p-out-code
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
                ) no-error.
                if ERROR-STATUS:error then do:
                    run wp-XMLWriteLog(  sLogFile, 1, error-status:get-message(1) + string( p-doc-code ) ).
                end.    
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
                        run wp-XMLWriteLog(  sLogFile, 1, "*** ERR: *** Не удалось рассчитать разбивку по кодам оплат по документу N "+ string( p-doc-code ) ).
                    end.
                    run wp-xmltagopen( 3, "cassSum","" ).
                    for each temp_inkas-pay
                    on error undo, return error
                    :
                        run wp-xmltagopen( 4, "payCode", "" ).
                        run wp-xmltagput( 5, "code", string( temp_inkas-pay.pay-code ), 0 ).
                        run wp-xmltagput( 5, "sum",  string( v-is-out * temp_inkas-pay.tot-sum ),  1 ).
                        run wp-xmltagput( 5, "sumb", string( v-is-out * temp_inkas-pay.tot-base ), 1 ).
                        run wp-xmltagput( 5, "sumr", string( v-is-out * temp_inkas-pay.tot-rubl ), 1 ).
                        run wp-xmltagclose( 4, "payCode" ).
                    end.
                    run wp-xmltagclose( 3, "cassSum" ).
                end. /*p-pay-code = yes*/
            end.        /* available inkas */
            else do:
                if p-ext-doc-type = {&TDEDT_Ras_Vnesh_Kass}
                or p-ext-doc-type = {&TDEDT_Vozvrat_Vnesh_Kass}
                then do:
                    run wp-XMLWriteLog(  sLogFile, 1, "*** ERR: *** Не найден inkas для документа расхода или возврата по кассе N " + string( p-doc-code ) ).
                end.
            end.        /* NOT available inkas */
    end.
    /*---END----------- Суммы по видам кассовых платежей ---------------------*/
    /* Цены документа */
    if available buf_ot-tot-sale
    then do:
        run wp-xmltagopen( 3, "docSum","" ).
        run wp-xmltagput( 4, "sumr"      , string( abs( buf_ot-tot-sale.sum-rubl       ) ), 1 ).
        
        if p-is-envd_ eq NO then
          run wp-xmltagput( 4, "VATr"      , string( abs( buf_ot-tot-sale.vat-rubl     ) ), 1 ). 
        else
          run wp-xmltagput( 4, "VATr"      , string( abs( p-sum-all-parts              ) ), 1 ).  
          
        run wp-xmltagput( 4, "SLTr"      , string( abs( buf_ot-tot-sale.slt-rubl       ) ), 1 ).
        run wp-xmltagput( 4, "roadTaxr"  , string( abs( buf_ot-tot-sale.road-tax-rubl  ) ), 1 ).
        run wp-xmltagput( 4, "transportr", string( abs( buf_ot-tot-sale.transport-rubl ) ), 1 ).
        run wp-xmltagput( 4, "otherr"    , string( abs( buf_ot-tot-sale.other-rubl     ) ), 1 ).
        run wp-xmltagput( 4, "exciser"   , string( abs( buf_ot-tot-sale.excise-rubl    ) ), 1 ).
        run wp-xmltagput( 4, "sumb"      , string( abs( buf_ot-tot-sale.sum-base       ) ), 1 ).
        run wp-xmltagput( 4, "VATb"      , string( abs( buf_ot-tot-sale.vat-base       ) ), 1 ).
        run wp-xmltagput( 4, "SLTb"      , string( abs( buf_ot-tot-sale.slt-base       ) ), 1 ).
        run wp-xmltagput( 4, "roadTaxb"  , string( abs( buf_ot-tot-sale.road-tax-base  ) ), 1 ).
        run wp-xmltagput( 4, "transportb", string( abs( buf_ot-tot-sale.transport-base ) ), 1 ).
        run wp-xmltagput( 4, "otherb"    , string( abs( buf_ot-tot-sale.other-base     ) ), 1 ).
        run wp-xmltagput( 4, "exciseb"   , string( abs( buf_ot-tot-sale.excise-base    ) ), 1 ).
        run wp-xmltagclose( 3, "docSum" ).
    end.
    /* Учетные цены */
    if p-ext-doc-type <> {&TDEDT_Overturn}
    then do:
        find first buf_ot-tot-cost no-lock
             where buf_ot-tot-cost.doc-code    = p-doc-code
               and buf_ot-tot-cost.sum-type    = {&arh-cost}
               and buf_ot-tot-cost.cat-id      = {&root-cat-id}
        no-error.
        if not available buf_ot-tot-cost
        then do:
            find first buf_ot-tot-cost no-lock
                 where buf_ot-tot-cost.doc-code    = p-doc-code
                   and buf_ot-tot-cost.sum-type    = {&arh-cost-service}
                   and buf_ot-tot-cost.cat-id      = {&root-cat-id}
            no-error.
        end.
        if available buf_ot-tot-cost
        then do:
            run wp-xmltagopen( 3, "costSum", "" ).
            run wp-xmltagput( 4, "sumr",        string( abs( buf_ot-tot-cost.sum-rubl       ) ), 1 ).
            
            if p-is-envd_ eq NO then
              run wp-xmltagput( 4, "VATr",        string( abs( buf_ot-tot-cost.vat-rubl     ) ), 1 ). 
            else 
              run wp-xmltagput( 4, "VATr",        string( abs( p-sum-all-parts              ) ), 1 ).
            
            run wp-xmltagput( 4, "SLTr",        string( abs( buf_ot-tot-cost.slt-rubl       ) ), 1 ).
            run wp-xmltagput( 4, "roadTaxr",    string( abs( buf_ot-tot-cost.road-tax-rubl  ) ), 1 ).
            run wp-xmltagput( 4, "transportr",  string( abs( buf_ot-tot-cost.transport-rubl ) ), 1 ).
            run wp-xmltagput( 4, "otherr",      string( abs( buf_ot-tot-cost.other-rubl     ) ), 1 ).
            run wp-xmltagput( 4, "exciser",     string( abs( buf_ot-tot-cost.excise-rubl    ) ), 1 ).
            run wp-xmltagput( 4, "sumb",        string( abs( buf_ot-tot-cost.sum-base       ) ), 1 ).
            run wp-xmltagput( 4, "VATb",        string( abs( buf_ot-tot-cost.vat-base       ) ), 1 ).
            run wp-xmltagput( 4, "SLTb",        string( abs( buf_ot-tot-cost.slt-base       ) ), 1 ).
            run wp-xmltagput( 4, "roadTaxb",    string( abs( buf_ot-tot-cost.road-tax-base  ) ), 1 ).
            run wp-xmltagput( 4, "transportb",  string( abs( buf_ot-tot-cost.transport-base ) ), 1 ).
            run wp-xmltagput( 4, "otherb",      string( abs( buf_ot-tot-cost.other-base     ) ), 1 ).
            run wp-xmltagput( 4, "exciseb",     string( abs( buf_ot-tot-cost.excise-base    ) ), 1 ).
            run wp-xmltagclose( 3, "costSum" ).
        end.      /* available buf_ot-tot-cost  */
        else do:
            if available buf_ot-tot-sale
            then do:
                run wp-XMLWriteLog( sLogFile, 1, "*** ERR: *** В архиве не найдена запись с sum-type = {&arh-cost} или {&arh-cost-service} для документа " + string( p-doc-code ) ).
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
            where buf_cost_ot-supp-tot.doc-code = p-doc-code
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
            where buf_cost_ot-supp-line.doc-code = p-doc-code
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
                    run wp-XMLWriteLog(  sLogFile,
                                                1,
                                        "*** WARN: *** Найдено больше одной записи ot-supp-line для документа "
                                        + string( p-doc-code )
                    ).
                end.
            end.        /* if buf_cost_ot-supp-line.sum-type = {&arh-cost} + {&arh-supp} */
        end.      /* for each buf_cost_ot-supp-line */
    end.      /* p-ext-doc-type <> {&TDEDT_Overturn}  */
    else do:
        /* Для переоценки не надо искать буфер cost */
    end.      /* NOT ( p-ext-doc-type <> {&TDEDT_Overturn}  ) */
    /* Продажные цены */
    run wp-xmltagopen( 3, "saleSum", "" ).
    run wp-xmltagput( 4, "sumr",         string( abs( buf_ot-tot-crsa-loop.sum-rubl        ) ), 1 ).
    run wp-xmltagput( 4, "VATr",         string( abs( buf_ot-tot-crsa-loop.vat-rubl        ) ), 2 ).
    run wp-xmltagput( 4, "SLTr",         string( abs( buf_ot-tot-crsa-loop.slt-rubl        ) ), 2 ).
    run wp-xmltagput( 4, "roadTaxr",     string( abs( buf_ot-tot-crsa-loop.road-tax-rubl   ) ), 2 ).
    run wp-xmltagput( 4, "transportr",   string( abs( buf_ot-tot-crsa-loop.transport-rubl  ) ), 2 ).
    run wp-xmltagput( 4, "otherr",       string( abs( buf_ot-tot-crsa-loop.other-rubl      ) ), 2 ).
    run wp-xmltagput( 4, "exciser",      string( abs( buf_ot-tot-crsa-loop.excise-rubl     ) ), 2 ).
    run wp-xmltagput( 4, "sumb",         string( abs( buf_ot-tot-crsa-loop.sum-base        ) ), 2 ).
    run wp-xmltagput( 4, "VATb",         string( abs( buf_ot-tot-crsa-loop.vat-base        ) ), 2 ).
    run wp-xmltagput( 4, "SLTb",         string( abs( buf_ot-tot-crsa-loop.slt-base        ) ), 2 ).
    run wp-xmltagput( 4, "roadTaxb",     string( abs( buf_ot-tot-crsa-loop.road-tax-base   ) ), 2 ).
    run wp-xmltagput( 4, "transportb",   string( abs( buf_ot-tot-crsa-loop.transport-base  ) ), 2 ).
    run wp-xmltagput( 4, "otherb",       string( abs( buf_ot-tot-crsa-loop.other-base      ) ), 2 ).
    run wp-xmltagput( 4, "exciseb",      string( abs( buf_ot-tot-crsa-loop.excise-base     ) ), 2 ).
    run wp-xmltagclose( 3, "saleSum" ).
    /* Для инвентаризации */
    if p-ext-doc-type = {&TDEDT_Inv}
    or p-ext-doc-type = {&TDEDT_Peresort}
    or p-ext-doc-type = {&TDEDT_Corr_Acc_Price}
    or p-ext-doc-type = {&TDEDT_Corr_Minus_Parts}
    then do:
        run utl/cuaddsum.p (
            input p-doc-code
        ) no-error.
        if error-status :error
        then do:
            run wp-XMLWriteLog(
                    input sLogFile
                , input 1
                , input substitute( "*** WARN: *** Не удалось проверить документ инвентаризации N: &1. &2. &3. &4"
                                    , p-doc-code
                                    , return-value
                                    , trim(error-status :get-message(1))
                                    , trim(error-status :get-message(2))
                                )
            ).
        end.
        run export-before-and-after-inv-trn in this-procedure (
                input p-doc-code
            , output v-exists-before
            , output v-exists-after
        ).
    end.        /* if p-ext-doc-type = {&TDEDT_Inv} */
    if p-pay-code = yes
    then do:    /* По поставщикам */
        run wp-xmltagopen( 3, "paySum", "" ).
        for each temp_cost_cat-id_ot-supp-tot
        on error undo, return error
        :
            run wp-xmltagopen( 4,  string( temp_cost_cat-id_ot-supp-tot.cat-id ), "" ).
            for each temp_cost_cli_ot-supp-tot
            where temp_cost_cli_ot-supp-tot.cat-id = temp_cost_cat-id_ot-supp-tot.cat-id
            on error undo, return error
            :
                run wp-xmltagopen( 5, "firm", "" ).
                run wp-xmltagput( 6, "type", string( temp_cost_cli_ot-supp-tot.cli-type ), 2 ).
                run wp-xmltagput( 6, "code", string( temp_cost_cli_ot-supp-tot.cli-code ), 2 ).
                run wp-xmltagopen( 6, "cost", "" ).
                if temp_cost_cli_ot-supp-tot.sum-rubl < 0
                then do:
                    run wp-xmltagput( 8, "sign", "-1", 0 ).
                end.
                run wp-xmltagput( 7, "qnty",         string( abs( temp_cost_cli_ot-supp-tot.fact-qnty        ) ), 2 ).
                run wp-xmltagput( 7, "sumr",         string( bge-xml-normalize-dec( abs( temp_cost_cli_ot-supp-tot.sum-rubl ) ) ), 1 ).
                run wp-xmltagput( 7, "VATr",         string( abs( temp_cost_cli_ot-supp-tot.vat-rubl         ) ), 2 ).
                run wp-xmltagput( 7, "SLTr",         string( abs( temp_cost_cli_ot-supp-tot.slt-rubl         ) ), 2 ).
                run wp-xmltagput( 7, "roadTaxr",     string( abs( temp_cost_cli_ot-supp-tot.road-tax-rubl    ) ), 2 ).
                run wp-xmltagput( 7, "transportr",   string( abs( temp_cost_cli_ot-supp-tot.transport-rubl   ) ), 2 ).
                run wp-xmltagput( 7, "otherr",       string( abs( temp_cost_cli_ot-supp-tot.other-rubl       ) ), 2 ).
                run wp-xmltagput( 7, "exciser",      string( abs( temp_cost_cli_ot-supp-tot.excise-rubl      ) ), 2 ).
                run wp-xmltagput( 7, "sumb",         string( abs( temp_cost_cli_ot-supp-tot.sum-base         ) ), 2 ).
                run wp-xmltagput( 7, "VATb",         string( abs( temp_cost_cli_ot-supp-tot.vat-base         ) ), 2 ).
                run wp-xmltagput( 7, "SLTb",         string( abs( temp_cost_cli_ot-supp-tot.slt-base         ) ), 2 ).
                run wp-xmltagput( 7, "roadTaxb",     string( abs( temp_cost_cli_ot-supp-tot.road-tax-base    ) ), 2 ).
                run wp-xmltagput( 7, "transportb",   string( abs( temp_cost_cli_ot-supp-tot.transport-base   ) ), 2 ).
                run wp-xmltagput( 7, "otherb",       string( abs( temp_cost_cli_ot-supp-tot.other-base       ) ), 2 ).
                run wp-xmltagput( 7, "exciseb",      string( abs( temp_cost_cli_ot-supp-tot.excise-base      ) ), 2 ).
                run wp-xmltagclose( 6, "cost" ).
                find first buf_sale_ot-supp-tot no-lock
                    where buf_sale_ot-supp-tot.doc-code = p-doc-code
                    and buf_sale_ot-supp-tot.cli-type = temp_cost_cli_ot-supp-tot.cli-type
                    and buf_sale_ot-supp-tot.cli-code = temp_cost_cli_ot-supp-tot.cli-code
                    and buf_sale_ot-supp-tot.sum-type = {&arh-sale}
                    and buf_sale_ot-supp-tot.cat-id   = {&single-cat-id}
                no-error.
                if available buf_sale_ot-supp-tot
                then do:
                    run wp-xmltagopen( 6, "sale" , "" ).
                    if buf_sale_ot-supp-tot.sum-rubl < 0
                    then do:
                        run wp-xmltagput( 8, "sign", "-1", 0 ).
                    end.
                    run wp-xmltagput( 7, "qnty",       string( abs( buf_sale_ot-supp-tot.fact-qnty      )                                                                         ), 2 ).
                    run wp-xmltagput( 7, "sumr",       string( bge-xml-normalize-dec( abs( buf_sale_ot-supp-tot.sum-rubl       ) / buf_sale_ot-supp-tot.fact-qnty  * temp_cost_cli_ot-supp-tot.fact-qnty ) ), 1 ).
                    run wp-xmltagput( 7, "VATr",       string( abs( buf_sale_ot-supp-tot.vat-rubl       ) / buf_sale_ot-supp-tot.fact-qnty  * temp_cost_cli_ot-supp-tot.fact-qnty ), 2 ).
                    run wp-xmltagput( 7, "SLTr",       string( abs( buf_sale_ot-supp-tot.slt-rubl       ) / buf_sale_ot-supp-tot.fact-qnty  * temp_cost_cli_ot-supp-tot.fact-qnty ), 2 ).
                    run wp-xmltagput( 7, "roadTaxr",   string( abs( buf_sale_ot-supp-tot.road-tax-rubl  ) / buf_sale_ot-supp-tot.fact-qnty  * temp_cost_cli_ot-supp-tot.fact-qnty ), 2 ).
                    run wp-xmltagput( 7, "transportr", string( abs( buf_sale_ot-supp-tot.transport-rubl ) / buf_sale_ot-supp-tot.fact-qnty  * temp_cost_cli_ot-supp-tot.fact-qnty ), 2 ).
                    run wp-xmltagput( 7, "otherr",     string( abs( buf_sale_ot-supp-tot.other-rubl     ) / buf_sale_ot-supp-tot.fact-qnty  * temp_cost_cli_ot-supp-tot.fact-qnty ), 2 ).
                    run wp-xmltagput( 7, "exciser",    string( abs( buf_sale_ot-supp-tot.excise-rubl    ) / buf_sale_ot-supp-tot.fact-qnty  * temp_cost_cli_ot-supp-tot.fact-qnty ), 2 ).
                    run wp-xmltagput( 7, "sumb",       string( abs( buf_sale_ot-supp-tot.sum-base       ) / buf_sale_ot-supp-tot.fact-qnty  * temp_cost_cli_ot-supp-tot.fact-qnty ), 2 ).
                    run wp-xmltagput( 7, "VATb",       string( abs( buf_sale_ot-supp-tot.vat-base       ) / buf_sale_ot-supp-tot.fact-qnty  * temp_cost_cli_ot-supp-tot.fact-qnty ), 2 ).
                    run wp-xmltagput( 7, "SLTb",       string( abs( buf_sale_ot-supp-tot.slt-base       ) / buf_sale_ot-supp-tot.fact-qnty  * temp_cost_cli_ot-supp-tot.fact-qnty ), 2 ).
                    run wp-xmltagput( 7, "roadTaxb",   string( abs( buf_sale_ot-supp-tot.road-tax-base  ) / buf_sale_ot-supp-tot.fact-qnty  * temp_cost_cli_ot-supp-tot.fact-qnty ), 2 ).
                    run wp-xmltagput( 7, "transportb", string( abs( buf_sale_ot-supp-tot.transport-base ) / buf_sale_ot-supp-tot.fact-qnty  * temp_cost_cli_ot-supp-tot.fact-qnty ), 2 ).
                    run wp-xmltagput( 7, "otherb",     string( abs( buf_sale_ot-supp-tot.other-base     ) / buf_sale_ot-supp-tot.fact-qnty  * temp_cost_cli_ot-supp-tot.fact-qnty ), 2 ).
                    run wp-xmltagput( 7, "exciseb",    string( abs( buf_sale_ot-supp-tot.excise-base    ) / buf_sale_ot-supp-tot.fact-qnty  * temp_cost_cli_ot-supp-tot.fact-qnty ), 2 ).
                    run wp-xmltagclose( 6,  "sale" ).
                end.        /* available buf_sale_ot-supp-line */
                run wp-xmltagclose( 5, "firm" ).
            end.        /* for each temp_cost_cli_ot-supp-tot */
            run wp-xmltagclose( 4,  string( temp_cost_cat-id_ot-supp-tot.cat-id ) ).
        end.      /* for each temp_cost_cat-id_ot-supp-tot */
        run wp-xmltagclose( 3,  "paySum" ).
    end.        /* if p-pay-code = yes */
/* Обработка строк документа */
    for each buf_ot-line-crsa-loop no-lock
        where buf_ot-line-crsa-loop.doc-code = p-doc-code
            and ( buf_ot-line-crsa-loop.sum-type = {&arh-crsa}
            or buf_ot-line-crsa-loop.sum-type = {&arh-crsa-service} )
    on error undo, return error
    :
/*            for each buf_ot-line-sale no-lock*/
/*               where buf_ot-line-sale.doc-code = p-doc-code*/
/*                 and buf_ot-line-sale.sum-type = buf_ot-tot-sale.sum-type*/
/*            on error undo, return error*/
/*            :*/
        run wp-xmltagopen( 3, "linedoc", "" ).
        find first buf_goods no-lock
          where     buf_goods.artic      = buf_ot-line-crsa-loop.artic
                and buf_goods.prod-type  = buf_ot-line-crsa-loop.prod-type
                and buf_goods.prod-code  = buf_ot-line-crsa-loop.prod-code
        no-error.
        if available buf_goods
        then do:
            run fill_bge-xml_goods in this-procedure (
                  input p-parent-proc
                , input buf_goods.gds-code
            ).
            run wp-xmltagput( 4, "good",      string( buf_goods.gds-code )    , 0 ).
            if p-ext-doc-type = {&TDEDT_Peresort}
            then do :
              find first buf_parts-root no-lock where buf_parts-root.doc-code = p-doc-code
                                                  and buf_parts-root.gds-code = buf_goods.gds-code
                                                  no-error .
              if available buf_parts-root
              and buf_parts-root.orig-gds-code > 0
              then 
              run wp-xmltagput( 4, "orig-gds-code",      string( buf_parts-root.orig-gds-code ), 0 ).                                    
            end.
            run wp-xmltagput( 4, "artic",     string( buf_goods.artic    )    , 0 ).
            run wp-xmltagput( 4, "prodtype",  string( buf_goods.prod-type)    , 0 ).
            run wp-xmltagput( 4, "prodcode",  string( buf_goods.prod-code)    , 0 ).
            run wp-xmltagput( 4, "type",      string( buf_goods.gds-type )    , 0 ).
        end.      /* available goods  */
        else do:
            run wp-xmltagput( 4, "good",    "", 0 ).
            run wp-xmltagput( 4, "artic"   , "" , 0 ).
            run wp-xmltagput( 4, "prodtype", "" , 0 ).
            run wp-xmltagput( 4, "prodcode", "" , 0 ).
            run wp-xmltagput( 4, "type",    "", 0 ).
        end.      /* NOT available goods  */
        find first buf_units no-lock
                where buf_units.unit-name  = buf_goods.unit-base
        no-error.
        if available buf_units
        then do:
            run wp-xmltagput( 4, "unitType",    string( buf_units.type ), 0 ).
        end.      /* available units */
        else do:
                run wp-xmltagput( 4, "unitType",   "",   0 ).
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
            if v-bge-xml-bgeflold <> "oracle":u then do:
              if p-ext-doc-type = {&TDEDT_Pri_vnesh}
              or p-ext-doc-type = {&TDEDT_Ras_Vnesh_VP} 
              or p-ext-doc-type = {&TDEDT_Ras_Vnesh}
              or p-ext-doc-type = {&WDEDT_Put_Cli} 
              then do:
                if available buf_goods then do:
                  run wp-xmltagput( 4, "deadline",  string( buf_goods.deadline ), 0 ).
                end.
                else do:
                  run wp-xmltagput( 4, "deadline",  "", 0 ).
                end.
              end.
            end.
            find first buf_doc-line no-lock
                where buf_doc-line.doc-code = p-doc-code
                    and buf_doc-line.artic      = buf_ot-line-crsa-loop.artic
                    and buf_doc-line.prod-type  = buf_ot-line-crsa-loop.prod-type
                    and buf_doc-line.prod-code  = buf_ot-line-crsa-loop.prod-code
            no-error.
            if available buf_doc-line
            then do:
                run wp-xmltagput( 4, "wait"         , string( buf_doc-line.wt-brutto        ), 0 ).
                run wp-xmltagput( 4, "place"        , string( buf_doc-line.num-place        ), 0 ).
                run wp-xmltagput( 4, "priceCli"     , string( buf_doc-line.price-cli        ), 0 ).
                run wp-xmltagput( 4, "cliBaseRate"  , string( buf_doc-line.cli-base-rate    ), 0 ).
                /*---START--------- Для топлива дополнительно экспортировать вес ---------------------*/
                if v-is-petrol  = yes
                and v-is-pieces = no
                then do:
                    run get-petrol-weight in this-procedure
                    (     input p-ext-doc-type
                        , input recid( buf_doc-line )
                        , input p-out-code
                        , output v-petrol-weight
                        , output v-weight-not-specified
                    ).
                    if v-weight-not-specified = no
                    then do:
                        assign
                            v-petrol-density = abs ( if buf_ot-line-crsa-loop.fact-qnty = 0
                                                    then 0
                                                    else v-petrol-weight / buf_ot-line-crsa-loop.fact-qnty )
                        .
                        run wp-xmltagput( 4, "petrolWeight",   string( v-petrol-weight            ), 0 ).
                        run wp-xmltagput( 4, "petrolDensity",  trim(string( v-petrol-density , ">>9.9999999999")), 0 ).
                        run wp-xmltagput( 4, "quantityDoc",   string( buf_doc-line.doc-qnty            ), 0 ).
                        run wp-xmltagput( 4, "petrolDensityDoc",    trim(string( buf_doc-line.doc-density , ">>>>>>>>>9.9999999999")), 0 ).
                        
                        find first buf_goods no-lock
                        where buf_goods.artic      = buf_doc-line.artic
                          and buf_goods.prod-type  = buf_doc-line.prod-type
                          and buf_goods.prod-code  = buf_doc-line.prod-code.
                        
                  find first   doc-line-attr where doc-line-attr.doc-code = p-doc-code 
                            and doc-line-attr.gds-code = buf_goods.gds-code 
                            and doc-line-attr.attr-code = "n" no-lock no-error.
      
                        if available doc-line-attr then
           
                            assign
                                v-SectionNum = integer ( doc-line-attr.attr-value) .         
            
                        else   v-SectionNum = 1 .
                        v-tank-vol = 0 .
                        v-tank-density  = 0.
                        v-tankweight = 0 .
     
                         do ii = 1 to v-SectionNum :
                   
             
                            for each doc-line-attr where doc-line-attr.doc-code = p-doc-code
                                and doc-line-attr.gds-code = buf_goods.gds-code
                                and    (entry (1, doc-line-attr.attr-code, {&delim-par})) =  'tank-vol'
                                and (v-SectionNum = 1 or (num-entries (doc-line-attr.attr-code, {&delim-par}) > 1 and (entry (2, doc-line-attr.attr-code, {&delim-par})) = string (ii) and v-SectionNum > 1)):

                                assign
                                    v-tank-vol = v-tank-vol + decimal ( doc-line-attr.attr-value)  .
  
                            end.
                            
                            for each doc-line-attr where doc-line-attr.doc-code = p-doc-code
                                and doc-line-attr.gds-code = buf_goods.gds-code
                                and    (entry (1, doc-line-attr.attr-code, {&delim-par})) =  'tank-vol'
                                and (v-SectionNum = 1 or (num-entries (doc-line-attr.attr-code, {&delim-par}) > 1 and (entry (2, doc-line-attr.attr-code, {&delim-par})) = string (ii) and v-SectionNum > 1)):

                                assign
                                    v-tank-density =    v-tank-density + decimal(doc-line-attr.attr-value) .
  
                            end.
                            for each doc-line-attr where doc-line-attr.doc-code = p-doc-code
                                and doc-line-attr.gds-code = buf_goods.gds-code
                                and    (entry (1, doc-line-attr.attr-code, {&delim-par})) =  'tank-weight'  
                                and (v-SectionNum = 1 or (num-entries (doc-line-attr.attr-code, {&delim-par}) > 1 and (entry (2, doc-line-attr.attr-code, {&delim-par})) = string (ii) and v-SectionNum > 1)):
                                v-tankweight =  v-tankweight + decimal (doc-line-attr.attr-value).
                            end.
                        end.
                        
                        if v-tank-vol <> 0 then
                            run wp-xmltagput( 4, "petrolTankVol",   trim(string(v-tank-vol , ">>>>>>>>>9.9999999999")), 0 ).             
                     
                        if v-tank-density <> 0 and v-tankweight  <> 0  then 
                        do :
                            v-total-tank-density = v-tankweight / v-tank-density .
                            
                            run wp-xmltagput( 4, "petrolTankDensity",    trim(string(v-total-tank-density , "->>>>>>>>>9.9999999999")), 0 ).
                        end.
                    end.
                
                define buffer buf_rvs-line      for ub.rvs-line .
                define buffer buf_rvs-doc       for ub.rvs-doc .
                                    
                for each buf_doc-pl where buf_doc-pl.obj-type = buf_doc-line.obj-type
                                      and buf_doc-pl.obj-code = buf_doc-line.obj-code
                                      and buf_doc-pl.out-code = buf_doc-line.doc-code
                                      and buf_doc-pl.gds-code = buf_goods.gds-code  :
                
                run wp-xmltagopen in this-procedure ( input 4, input "PLDoc", input "" ).
                run wp-xmltagput( 5, "PLCode",   string(buf_doc-pl.pl-code) , 0 ).
                run wp-xmltagput( 5, "PLQnty",  string(buf_doc-pl.fact-qnty) , 0 ).
                run wp-xmltagput( 5, "PLWeigth",  string(buf_doc-pl.cli-fact-qnty) , 0 ).
                run wp-xmltagput( 5, "PLDensity",  string( (buf_doc-pl.cli-fact-qnty / buf_doc-pl.fact-qnty), "->>>>>>>>>9.99") , 0 ).
                
                if p-need-doc-rvs
                and (p-ext-doc-type = {&TDEDT_Pri_Vnesh} or p-ext-doc-type = {&TDEDT_Pri_Perem})
                then do :
                  for first buf_rvs-doc no-lock where buf_rvs-doc.out-code = buf_doc-line.doc-code
                                                  and buf_rvs-doc.rvs-type = {&rvs-before-doc},
                  first buf_rvs-line where buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code
                                       and buf_rvs-line.obj-type = buf_rvs-doc.obj-type
                                       and buf_rvs-line.obj-code = buf_rvs-doc.obj-code
                                       and buf_rvs-line.pl-code = buf_doc-pl.pl-code
                                       and buf_rvs-line.gds-code = buf_doc-pl.gds-code :
                    run wp-xmltagput( 5, "PLQntyBeforeDoc",  string(buf_rvs-line.state-measure-qnty) , 0 ).
                    run wp-xmltagput( 5, "PLWeigthBeforeDoc",  string(buf_rvs-line.state-measure-cli-qnty) , 0 ).
                  end .
                  for first buf_rvs-doc no-lock where buf_rvs-doc.out-code = buf_doc-line.doc-code
                                                  and buf_rvs-doc.rvs-type = {&rvs-after-doc},
                  first buf_rvs-line where buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code
                                       and buf_rvs-line.obj-type = buf_rvs-doc.obj-type
                                       and buf_rvs-line.obj-code = buf_rvs-doc.obj-code
                                       and buf_rvs-line.pl-code = buf_doc-pl.pl-code
                                       and buf_rvs-line.gds-code = buf_doc-pl.gds-code :
                    run wp-xmltagput( 5, "PLQntyAfterDoc",  string(buf_rvs-line.state-measure-qnty) , 0 ).
                    run wp-xmltagput( 5, "PLWeigthAfterDoc",  string(buf_rvs-line.state-measure-cli-qnty) , 0 ).
                  end .
                end .
                
                run wp-xmltagclose in this-procedure ( input 4, input "PLDoc"  ).                                          
                                          
                end.             
                    end.
                end.
                /*---END----------- Для топлива дополнительно экспортировать вес ---------------------*/
                  /* available buf_doc-line  */
            else do:
                run wp-XMLWriteLog(  sLogFile, 1, "*** ERR: *** Не найдено строк документа " + string( p-doc-code ) ).
            end.      /* NOT ( available buf_doc-line  ) */
        end.      /* p-ext-doc-type <> {&TDEDT_Overturn} */
        else do:
          define variable v-price-prev as decimal   no-undo .
          assign
              v-price-prev = 0.0
          .
          find first buf_price-list no-lock
            where buf_price-list.doc-num    = p-doc-code
              and buf_price-list.main-price = yes
              and buf_price-list.artic      = buf_ot-line-crsa-loop.artic
              and buf_price-list.prod-type  = buf_ot-line-crsa-loop.prod-type
              and buf_price-list.prod-code  = buf_ot-line-crsa-loop.prod-code
          no-error.
          if available buf_price-list
          then do:
              define variable v-void-char     as character    no-undo.
              define variable v-void-dec      as decimal      no-undo.
              { gbl/bcodeprc.i
                  buf_price-list.obj-type
                  buf_price-list.obj-code
                  buf_price-list.b-code
                  0
                  buf_price-list.fact-order
                  v-void-char
                  v-price-prev
                  v-void-dec
                  v-void-dec
              }
              run wp-xmltagput( 4, "priceListQnty", string( buf_price-list.doc-qnty   ), 0 ).
              run wp-xmltagput( 4, "priceSale"    , string( buf_price-list.price-sale ), 0 ).
          end.
          run wp-xmltagput( 4, "pricePrev"        , string( v-price-prev        ), 0 ).

          run export-bc-price in this-procedure ( input buf_price-list.obj-type
                                                , input buf_price-list.obj-code
                                                , input p-doc-code
                                                , input buf_price-list.b-code
                                                ) .

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
        run wp-xmltagput( 4, "quantity",   string( v-qnty ), 0 ).
        run wp-xmltagput( 4, "comment",    string( buf_goods.ps ), 0 ).
/*--S------- Для всех кроме переоценки выводим строку ГТД и количество ----------*/

    if v-is-petrol  = yes                                                                                 
            and v-is-pieces = no                                                                              
            then                                                                                              
        do: 
            
            /*            find first   doc-line-attr where doc-line-attr.doc-code = p-doc-code*/
            /*                and doc-line-attr.gds-code = buf_goods.gds-code                 */
            /*                and doc-line-attr.attr-code = "n" no-lock no-error.             */
            /*                                                                                */
            /*            if available doc-line-attr then                                     */
            /*                                                                                */
            /*                assign                                                          */
            /*                    v-SectionNum = integer ( doc-line-attr.attr-value) .        */
            /*                                                                                */
            /*                else   v-SectionNum = 1 .                                       */
            do ii = 1 to v-SectionNum :
                   
             
                for each doc-line-attr where doc-line-attr.doc-code = p-doc-code
                    and doc-line-attr.gds-code = buf_goods.gds-code
                    and  not  doc-line-attr.attr-code = "n" 
                    and (v-SectionNum = 1 or (num-entries (doc-line-attr.attr-code, {&delim-par}) > 1 and (entry (2, doc-line-attr.attr-code, {&delim-par})) = string (ii) and v-SectionNum > 1)):
        
                    /*                          v-attrCode = entry (1, doc-line-attr.attr-code, {&delim-par}) .*/
                    /*        if error-status:error then next.      
                            
                                                                          */
                     
                               
                            
                        
                        
                                                 
                    case (entry (1, doc-line-attr.attr-code, {&delim-par})):
                        when 'section-name' then 
                            do:
                                assign
                                    v-SectionName = doc-line-attr.attr-value no-error.
                            end.
                        when 'doc-qnty' then 
                            do:
                                assign
                                    v-DocQnty = decimal (doc-line-attr.attr-value) no-error.
                            end.
                        when 'fact-qnty' then 
                            do:
                                assign
                                    v-FactQnty = decimal (doc-line-attr.attr-value) 
                                    v-CliQnty  = v-DocDensity * v-FactQnty no-error.
                            end.
                        when 'fact-dens' then 
                            do:
                                assign
                                    v-FactDensity = decimal (doc-line-attr.attr-value) .
                            end.   
                            
                        when 'doc-dens' then 
                            do:
                                assign
                                    v-DocDensity = decimal (doc-line-attr.attr-value) 
                                    v-CliQnty    = v-DocDensity * v-FactQnty no-error.
                            end.
                        when 'tank-vol' then 
                            do:
                                assign
                                    v-TankVol = decimal (doc-line-attr.attr-value) no-error.
                            end.
                        when 'tank-density' then 
                            do:
                                assign
                                    v-TankDensity = decimal (doc-line-attr.attr-value) no-error.
                            end.
        
                        when 'tank-density-pomi' then 
                            do:
                                assign
                                    v-TankDensityPomi = decimal (doc-line-attr.attr-value) no-error.
                            end.
                        when 'tank-vol-pomi' then 
                            do:
                                assign
                                    v-TankVolPomi = decimal (doc-line-attr.attr-value) no-error.
                            end.
        
                    end  case.
                end.
                     
                run wp-xmltagopen in this-procedure ( input 3, input "Tank", input "" ).
                run wp-xmltagput( 4, "TankNum",   v-SectionName , 0 ).
                run wp-xmltagput( 4, "TankDocVol",  string(v-DocQnty  ) , 0 ).
                run wp-xmltagput( 4, "TankDocDensity",  trim(string(v-DocDensity , ">>>>>>>>>9.9999999999")) , 0 ).
                run wp-xmltagput( 4, "TankVol",  string(v-TankVol   ) , 0 ).
                run wp-xmltagput( 4, "TankDensity",  trim(string(v-TankDensity , ">>>>>>>>>9.9999999999")) , 0 ).
                run wp-xmltagput( 5, "TankFactVol",  string(v-FactQnty ) , 0 ).
                run wp-xmltagput( 5, "TankFactDensity",  trim(string(v-FactDensity , ">>>>>>>>>9.9999999999")) , 0 ).
                run wp-xmltagput( 4, "RdcDensity",  trim(string(v-TankDensityPomi , ">>>>>>>>>9.9999999999")) , 0 ).
                run wp-xmltagput( 4, "RdcVol",  string( v-TankVolPomi) , 0 ).
                run wp-xmltagclose in this-procedure ( input 3, input "Tank"  ).
                        
            end.
  
        end.

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
                run wp-xmltagopen in this-procedure ( input 4, input "dtlSum", input "" ).
                run export-gds-dtl in this-procedure (
                      input p-doc-code
                    , input buf_goods.artic
                    , input buf_goods.prod-type
                    , input buf_goods.prod-code
                ).
                run wp-xmltagclose in this-procedure ( input 4, input "dtlSum" ).
            end.
            if p-cst = yes
            or p-parts = yes
            then do:        /* Надо экспортировать номера ГТД или партии */
                if p-parts = yes
                then do:
                    run wp-xmltagopen in this-procedure ( input 4, input "partsSum", input "" ).
                end.        /* if p-parts = yes */
                assign
                    v-parts-cst-code = ""
                .
                assign v-sum-parts = 0 .
                for each buf_parts no-lock
                    where buf_parts.out-code   = p-doc-code
                        and buf_parts.obj-type   = buf_ot-line-crsa-loop.obj-type
                        and buf_parts.obj-code   = buf_ot-line-crsa-loop.obj-code
                        and buf_parts.prod-type  = buf_ot-line-crsa-loop.prod-type
                        and buf_parts.prod-code  = buf_ot-line-crsa-loop.prod-code
                        and buf_parts.artic      = buf_ot-line-crsa-loop.artic
                        and buf_parts.status_    = true
                on error undo, return error return-value
                :
                    if p-parts = yes
                    then do:
                        { str/in-vatp.i calc-parts buf_parts. " " loc}
                                                      
                        v-sum-parts = v-sum-parts + ((price-rubl-with-tax-loc / (100 + buf_parts.VAT-pc )) * buf_parts.VAT-pc)  * buf_parts.fact-qnty .
                        run export-part in this-procedure (
                              input ( if available buf_goods then buf_goods.gds-code else 0 )
                            , input rowid( buf_parts )
                            , input p-is-envd_
                        ).
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
                if p-parts = yes
                then do:
                    run wp-xmltagclose in this-procedure ( input 4, input "partsSum" ).
                end.        /* if p-parts = yes */
                if p-cst = yes
                then do:
                    run wp-xmltagput in this-procedure ( 4, "CSTCode",    string( v-parts-cst-code ), 0 ).
                end.        /* if p-cst = yes */
            end.        /* if p-ext-doc-type <> {&TDEDT_Overturn} */
            /*---START--------- дополнительно экспортируем разброску по типам кассовых платежей----------*/
            if p-chk-pay-code = yes
            and available buf_doc-line
            and available buf_goods
            then do:
                run export-chk-pay-code in this-procedure (
                      input p-ext-doc-type
                    , input recid( buf_doc-line )
                    , input p-out-code
                    , input p-pay-desk
                    , input v-is-petrol
                    , input v-is-pieces
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
                    where buf_ot-line-sale.doc-code    = p-doc-code
                    and buf_ot-line-sale.artic       = buf_ot-line-crsa-loop.artic
                    and buf_ot-line-sale.prod-type   = buf_ot-line-crsa-loop.prod-type
                    and buf_ot-line-sale.prod-code   = buf_ot-line-crsa-loop.prod-code
                    and buf_ot-line-sale.sum-type    = buf_ot-tot-sale.sum-type
            no-error.
            if available buf_ot-line-sale
            then do:
                run wp-xmltagopen( 4, "docSum", "" ).
                run wp-xmltagput( 5, "rateVAT",    string( entry( 1, buf_ot-line-sale.cat-id ) ), 2 ).
                run wp-xmltagput( 5, "rateSLT",    string( entry( 2, buf_ot-line-sale.cat-id ) ), 2 ).
                if p-ext-doc-type = {&TDEDT_Overturn}
                then do:
                        run wp-xmltagput( 5, "sumr",       string( buf_ot-line-sale.sum-rubl         ), 1 ).
                        
                        if p-is-envd_ eq NO then
                          run wp-xmltagput( 5, "VATr",       string( buf_ot-line-sale.vat-rubl       ), 2 ).
                        else
                          run wp-xmltagput( 5, "VATr",       string( v-sum-parts                     ), 2 ).
                        
                        run wp-xmltagput( 5, "SLTr",       string( buf_ot-line-sale.slt-rubl         ), 2 ).
                        run wp-xmltagput( 5, "roadTaxr",   string( buf_ot-line-sale.road-tax-rubl    ), 2 ).
                        run wp-xmltagput( 5, "transportr", string( buf_ot-line-sale.transport-rubl   ), 2 ).
                        run wp-xmltagput( 5, "otherr",     string( buf_ot-line-sale.other-rubl       ), 2 ).
                        run wp-xmltagput( 5, "exciser",    string( buf_ot-line-sale.excise-rubl      ), 2 ).
                        run wp-xmltagput( 5, "sumb",       string( buf_ot-line-sale.sum-base         ), 2 ).
                        run wp-xmltagput( 5, "VATb",       string( buf_ot-line-sale.vat-base         ), 2 ).
                        run wp-xmltagput( 5, "SLTb",       string( buf_ot-line-sale.slt-base         ), 2 ).
                        run wp-xmltagput( 5, "roadTaxb",   string( buf_ot-line-sale.road-tax-base    ), 2 ).
                        run wp-xmltagput( 5, "transportb", string( buf_ot-line-sale.transport-base   ), 2 ).
                        run wp-xmltagput( 5, "otherb",     string( buf_ot-line-sale.other-base       ), 2 ).
                        run wp-xmltagput( 5, "exciseb",    string( buf_ot-line-sale.excise-base      ), 2 ).
                end.      /* p-ext-doc-type = {&TDEDT_Overturn} */
                else do:
                        run wp-xmltagput( 5, "sumr",       string( abs( buf_ot-line-sale.sum-rubl       ) ), 1 ).
                        
                        if p-is-envd_ eq NO then
                          run wp-xmltagput( 5, "VATr",       string( abs( buf_ot-line-sale.vat-rubl     ) ), 2 ).
                        else
                          run wp-xmltagput( 5, "VATr",       string( v-sum-parts                        ), 2 ).                 
                        
                        run wp-xmltagput( 5, "SLTr",       string( abs( buf_ot-line-sale.slt-rubl       ) ), 2 ).
                        run wp-xmltagput( 5, "roadTaxr",   string( abs( buf_ot-line-sale.road-tax-rubl  ) ), 2 ).
                        run wp-xmltagput( 5, "transportr", string( abs( buf_ot-line-sale.transport-rubl ) ), 2 ).
                        run wp-xmltagput( 5, "otherr",     string( abs( buf_ot-line-sale.other-rubl     ) ), 2 ).
                        run wp-xmltagput( 5, "exciser",    string( abs( buf_ot-line-sale.excise-rubl    ) ), 2 ).
                        run wp-xmltagput( 5, "sumb",       string( abs( buf_ot-line-sale.sum-base       ) ), 2 ).
                        run wp-xmltagput( 5, "VATb",       string( abs( buf_ot-line-sale.vat-base       ) ), 2 ).
                        run wp-xmltagput( 5, "SLTb",       string( abs( buf_ot-line-sale.slt-base       ) ), 2 ).
                        run wp-xmltagput( 5, "roadTaxb",   string( abs( buf_ot-line-sale.road-tax-base  ) ), 2 ).
                        run wp-xmltagput( 5, "transportb", string( abs( buf_ot-line-sale.transport-base ) ), 2 ).
                        run wp-xmltagput( 5, "otherb",     string( abs( buf_ot-line-sale.other-base     ) ), 2 ).
                        run wp-xmltagput( 5, "exciseb",    string( abs( buf_ot-line-sale.excise-base    ) ), 2 ).
                end.      /* NOT ( p-ext-doc-type = {&TDEDT_Overturn} ) */
                run wp-xmltagclose( 4, "docSum" ).
            end.        /* if available buf_ot-line-sale */
            else do:
/*                run wp-XMLWriteLog( sLogFile, 1, "В архиве не найдена cтрока документа с sum-type = {&arh-sale} или {&arh-crsa} для документа номер " + string( p-doc-code ) + " ( ext-doc-type = " + p-ext-doc-type + ")" + ", артикул товара " + buf_ot-line-crsa-loop.artic ).*/
            end.        /* if NOT( available buf_ot-line-sale ) */
        end.        /* if available buf_ot-tot-sale */
        /* Учетные цены */
        if p-ext-doc-type <> {&TDEDT_Overturn}
        then do:
            if available buf_ot-tot-cost
            then do:
                find first buf_ot-line-cost no-lock
                        where buf_ot-line-cost.doc-code   = p-doc-code
                        and buf_ot-line-cost.artic      = buf_ot-line-crsa-loop.artic
                        and buf_ot-line-cost.prod-type  = buf_ot-line-crsa-loop.prod-type
                        and buf_ot-line-cost.prod-code  = buf_ot-line-crsa-loop.prod-code
                        and buf_ot-line-cost.sum-type   = buf_ot-tot-cost.sum-type
                no-error.
                if available buf_ot-line-cost
                then do:
                        run wp-xmltagopen( 4, "costSum", "" ).
                        run wp-xmltagput( 5, "sumr",       string( abs( buf_ot-line-cost.sum-rubl       ) ), 1 ).
                        
                        if p-is-envd_ eq NO then
                          run wp-xmltagput( 5, "VATr",       string( abs( buf_ot-line-cost.vat-rubl     ) ), 2 ).  
                        else
                          run wp-xmltagput( 5, "VATr",       string( v-sum-parts                        ), 2 ).  
                        
                        run wp-xmltagput( 5, "SLTr",       string( abs( buf_ot-line-cost.slt-rubl       ) ), 2 ).
                        run wp-xmltagput( 5, "roadTaxr",   string( abs( buf_ot-line-cost.road-tax-rubl  ) ), 2 ).
                        run wp-xmltagput( 5, "transportr", string( abs( buf_ot-line-cost.transport-rubl ) ), 2 ).
                        run wp-xmltagput( 5, "otherr",     string( abs( buf_ot-line-cost.other-rubl     ) ), 2 ).
                        run wp-xmltagput( 5, "exciser",    string( abs( buf_ot-line-cost.excise-rubl    ) ), 2 ).
                        run wp-xmltagput( 5, "sumb",       string( abs( buf_ot-line-cost.sum-base       ) ), 2 ).
                        run wp-xmltagput( 5, "VATb",       string( abs( buf_ot-line-cost.vat-base       ) ), 2 ).
                        run wp-xmltagput( 5, "SLTb",       string( abs( buf_ot-line-cost.slt-base       ) ), 2 ).
                        run wp-xmltagput( 5, "roadTaxb",   string( abs( buf_ot-line-cost.road-tax-base  ) ), 2 ).
                        run wp-xmltagput( 5, "transportb", string( abs( buf_ot-line-cost.transport-base ) ), 2 ).
                        run wp-xmltagput( 5, "otherb",     string( abs( buf_ot-line-cost.other-base     ) ), 2 ).
                        run wp-xmltagput( 5, "exciseb",    string( abs( buf_ot-line-cost.excise-base    ) ), 2 ).
                        run wp-xmltagclose( 4, "costSum" ).
                end.      /* available buf_ot-line-cost */
                else do:
                    if ( buf_ot-line-crsa-loop.ext-doc-type = {&TDEDT_Inv}
                        or buf_ot-line-crsa-loop.ext-doc-type = {&TDEDT_Peresort}
                        or buf_ot-line-crsa-loop.ext-doc-type = {&TDEDT_Corr_Acc_Price}
                        or buf_ot-line-crsa-loop.ext-doc-type = {&TDEDT_Corr_Minus_Parts} )
                    and buf_ot-line-crsa-loop.fact-qnty = 0
                    then do:
                        /* В этом случае строки в архиве не создаются, это не ошибка */
                    end.
                    else do:
/*                        run wp-XMLWriteLog( sLogFile, 1, "Не найден ot-line с sum-type = {&arh-cost} или {&arh-cost-service} для документа " + string( p-doc-code ) + ", артикул товара " + string( buf_ot-line-crsa-loop.artic ) ).*/
                    end.
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
        run wp-xmltagopen( 4, "saleSum", "" ).
        run wp-xmltagput( 5, "sumr",       string( abs( buf_ot-line-crsa-loop.sum-rubl       ) ), 1 ).
        run wp-xmltagput( 5, "VATr",       string( abs( buf_ot-line-crsa-loop.vat-rubl       ) ), 2 ).
        run wp-xmltagput( 5, "SLTr",       string( abs( buf_ot-line-crsa-loop.slt-rubl       ) ), 2 ).
        run wp-xmltagput( 5, "roadTaxr",   string( abs( buf_ot-line-crsa-loop.road-tax-rubl  ) ), 2 ).
        run wp-xmltagput( 5, "transportr", string( abs( buf_ot-line-crsa-loop.transport-rubl ) ), 2 ).
        run wp-xmltagput( 5, "otherr",     string( abs( buf_ot-line-crsa-loop.other-rubl     ) ), 2 ).
        run wp-xmltagput( 5, "exciser",    string( abs( buf_ot-line-crsa-loop.excise-rubl    ) ), 2 ).
        run wp-xmltagput( 5, "sumb",       string( abs( buf_ot-line-crsa-loop.sum-base       ) ), 2 ).
        run wp-xmltagput( 5, "VATb",       string( abs( buf_ot-line-crsa-loop.vat-base       ) ), 2 ).
        run wp-xmltagput( 5, "SLTb",       string( abs( buf_ot-line-crsa-loop.slt-base       ) ), 2 ).
        run wp-xmltagput( 5, "roadTaxb",   string( abs( buf_ot-line-crsa-loop.road-tax-base  ) ), 2 ).
        run wp-xmltagput( 5, "transportb", string( abs( buf_ot-line-crsa-loop.transport-base ) ), 2 ).
        run wp-xmltagput( 5, "otherb",     string( abs( buf_ot-line-crsa-loop.other-base     ) ), 2 ).
        run wp-xmltagput( 5, "exciseb",    string( abs( buf_ot-line-crsa-loop.excise-base    ) ), 2 ).
        run wp-xmltagclose( 4, "saleSum" ).
        /* Для инвентаризации */
        if p-ext-doc-type = {&TDEDT_Inv}
        or p-ext-doc-type = {&TDEDT_Peresort}
        or p-ext-doc-type = {&TDEDT_Corr_Acc_Price}
        or p-ext-doc-type = {&TDEDT_Corr_Minus_Parts}
        then do:
            run export-before-and-after-inv-line in this-procedure (
                    input p-doc-code
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
                run wp-xmltagopen( 4, "paySum", "" ).
                for each temp_cost_cat-id_ot-supp-line
                    where temp_cost_cat-id_ot-supp-line.artic        = buf_ot-line-crsa-loop.artic
                        and temp_cost_cat-id_ot-supp-line.prod-type    = buf_ot-line-crsa-loop.prod-type
                        and temp_cost_cat-id_ot-supp-line.prod-code    = buf_ot-line-crsa-loop.prod-code
                on error undo, return error
                :
                    run wp-xmltagopen( 5, string( temp_cost_cat-id_ot-supp-line.cat-id ), "" ).
                    for each temp_cost_cli_ot-supp-line
                    where temp_cost_cli_ot-supp-line.artic        = temp_cost_cat-id_ot-supp-line.artic
                        and temp_cost_cli_ot-supp-line.prod-type  = temp_cost_cat-id_ot-supp-line.prod-type
                        and temp_cost_cli_ot-supp-line.prod-code  = temp_cost_cat-id_ot-supp-line.prod-code
                        and temp_cost_cli_ot-supp-line.cat-id     = temp_cost_cat-id_ot-supp-line.cat-id
                    on error undo, return error
                    :
                        run wp-xmltagopen( 6,  "firm", "" ).
                        run wp-xmltagput( 7, "type", string( temp_cost_cli_ot-supp-line.cli-type ), 2 ).
                        run wp-xmltagput( 7, "code", string( temp_cost_cli_ot-supp-line.cli-code ), 2 ).
                        run wp-xmltagopen( 7, "cost" ,"" ).
                        if temp_cost_cli_ot-supp-line.sum-rubl < 0
                        then do:
                            run wp-xmltagput( 8, "sign", "-1", 0 ).
                        end.
                        run wp-xmltagput( 8, "qnty",        string( abs( temp_cost_cli_ot-supp-line.fact-qnty        ) ), 2 ).
                        run wp-xmltagput( 8, "sumr",        string( abs( temp_cost_cli_ot-supp-line.sum-rubl         ) ), 1 ).
                        run wp-xmltagput( 8, "VATr",        string( abs( temp_cost_cli_ot-supp-line.vat-rubl         ) ), 2 ).
                        run wp-xmltagput( 8, "SLTr",        string( abs( temp_cost_cli_ot-supp-line.slt-rubl         ) ), 2 ).
                        run wp-xmltagput( 8, "roadTaxr",    string( abs( temp_cost_cli_ot-supp-line.road-tax-rubl    ) ), 2 ).
                        run wp-xmltagput( 8, "transportr",  string( abs( temp_cost_cli_ot-supp-line.transport-rubl   ) ), 2 ).
                        run wp-xmltagput( 8, "otherr",      string( abs( temp_cost_cli_ot-supp-line.other-rubl       ) ), 2 ).
                        run wp-xmltagput( 8, "exciser",     string( abs( temp_cost_cli_ot-supp-line.excise-rubl      ) ), 2 ).
                        run wp-xmltagput( 8, "sumb",        string( abs( temp_cost_cli_ot-supp-line.sum-base         ) ), 2 ).
                        run wp-xmltagput( 8, "VATb",        string( abs( temp_cost_cli_ot-supp-line.vat-base         ) ), 2 ).
                        run wp-xmltagput( 8, "SLTb",        string( abs( temp_cost_cli_ot-supp-line.slt-base         ) ), 2 ).
                        run wp-xmltagput( 8, "roadTaxb",    string( abs( temp_cost_cli_ot-supp-line.road-tax-base    ) ), 2 ).
                        run wp-xmltagput( 8, "transportb",  string( abs( temp_cost_cli_ot-supp-line.transport-base   ) ), 2 ).
                        run wp-xmltagput( 8, "otherb",      string( abs( temp_cost_cli_ot-supp-line.other-base       ) ), 2 ).
                        run wp-xmltagput( 8, "exciseb",     string( abs( temp_cost_cli_ot-supp-line.excise-base      ) ), 2 ).
                        run wp-xmltagclose( 7,  "cost" ).
                        find first buf_sale_ot-supp-line no-lock
                                where buf_sale_ot-supp-line.doc-code    = p-doc-code
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
                            run wp-xmltagopen( 7, "sale", "" ).
                            if buf_sale_ot-supp-line.sum-rubl < 0
                            then do:
                                run wp-xmltagput( 8, "sign", "-1", 0 ).
                            end.
                            run wp-xmltagput( 8, "qnty",       string( abs( buf_sale_ot-supp-line.fact-qnty        )                                                                           ), 2 ).
                            run wp-xmltagput( 8, "sumr",       string( bge-xml-normalize-dec( abs( buf_sale_ot-supp-line.sum-rubl         ) / buf_sale_ot-supp-line.fact-qnty  * temp_cost_cli_ot-supp-line.fact-qnty ) ), 1 ).
                            run wp-xmltagput( 8, "VATr",       string( abs( buf_sale_ot-supp-line.vat-rubl         ) / buf_sale_ot-supp-line.fact-qnty  * temp_cost_cli_ot-supp-line.fact-qnty ), 2 ).
                            run wp-xmltagput( 8, "SLTr",       string( abs( buf_sale_ot-supp-line.slt-rubl         ) / buf_sale_ot-supp-line.fact-qnty  * temp_cost_cli_ot-supp-line.fact-qnty ), 2 ).
                            run wp-xmltagput( 8, "roadTaxr",   string( abs( buf_sale_ot-supp-line.road-tax-rubl    ) / buf_sale_ot-supp-line.fact-qnty  * temp_cost_cli_ot-supp-line.fact-qnty ), 2 ).
                            run wp-xmltagput( 8, "transportr", string( abs( buf_sale_ot-supp-line.transport-rubl   ) / buf_sale_ot-supp-line.fact-qnty  * temp_cost_cli_ot-supp-line.fact-qnty ), 2 ).
                            run wp-xmltagput( 8, "otherr",     string( abs( buf_sale_ot-supp-line.other-rubl       ) / buf_sale_ot-supp-line.fact-qnty  * temp_cost_cli_ot-supp-line.fact-qnty ), 2 ).
                            run wp-xmltagput( 8, "exciser",    string( abs( buf_sale_ot-supp-line.excise-rubl      ) / buf_sale_ot-supp-line.fact-qnty  * temp_cost_cli_ot-supp-line.fact-qnty ), 2 ).
                            run wp-xmltagput( 8, "sumb",       string( abs( buf_sale_ot-supp-line.sum-base         ) / buf_sale_ot-supp-line.fact-qnty  * temp_cost_cli_ot-supp-line.fact-qnty ), 2 ).
                            run wp-xmltagput( 8, "VATb",       string( abs( buf_sale_ot-supp-line.vat-base         ) / buf_sale_ot-supp-line.fact-qnty  * temp_cost_cli_ot-supp-line.fact-qnty ), 2 ).
                            run wp-xmltagput( 8, "SLTb",       string( abs( buf_sale_ot-supp-line.slt-base         ) / buf_sale_ot-supp-line.fact-qnty  * temp_cost_cli_ot-supp-line.fact-qnty ), 2 ).
                            run wp-xmltagput( 8, "roadTaxb",   string( abs( buf_sale_ot-supp-line.road-tax-base    ) / buf_sale_ot-supp-line.fact-qnty  * temp_cost_cli_ot-supp-line.fact-qnty ), 2 ).
                            run wp-xmltagput( 8, "transportb", string( abs( buf_sale_ot-supp-line.transport-base   ) / buf_sale_ot-supp-line.fact-qnty  * temp_cost_cli_ot-supp-line.fact-qnty ), 2 ).
                            run wp-xmltagput( 8, "otherb",     string( abs( buf_sale_ot-supp-line.other-base       ) / buf_sale_ot-supp-line.fact-qnty  * temp_cost_cli_ot-supp-line.fact-qnty ), 2 ).
                            run wp-xmltagput( 8, "exciseb",    string( abs( buf_sale_ot-supp-line.excise-base      ) / buf_sale_ot-supp-line.fact-qnty  * temp_cost_cli_ot-supp-line.fact-qnty ), 2 ).
                            run wp-xmltagclose( 7, "sale" ).
                        end.        /* available buf_sale_ot-supp-line */
                        run wp-xmltagclose( 6,  "firm" ).
                    end.
                    run wp-xmltagclose( 5, string( temp_cost_cat-id_ot-supp-line.cat-id ) ).
                end.      /* for each temp_cost_cat-id_ot-supp-line */
                run wp-xmltagclose( 4, "paySum" ).
            end.        /* if p-pay-code = yes */
        end.      /* p-ext-doc-type <> {&TDEDT_Overturn} */
        else do:
            /* Для переоценки не надо искать pay */
        end.      /* NOT ( p-ext-doc-type <> {&TDEDT_Overturn} ) */
        run wp-xmltagclose( 3, "linedoc" ).
    end.        /* for each buf_ot-line-sale no-lock */
    if p-need-chk = yes
    then do:
        if p-ext-doc-type = {&TDEDT_Ras_Vnesh_Kass}
        or p-ext-doc-type = {&TDEDT_Vozvrat_Vnesh_Kass}
        then do:
            run export-checks in this-procedure (
                    input p-ext-doc-type
                , input p-doc-code
                , input v-obj-type
                , input v-obj-code
            ).
        end.
    end.        /* if p-need-checks = yes  */
    run wp-xmltagclose( 2, "operation" ).
end.
end procedure. /* export-from-archive */

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
            run wp-xmltagopen( input 3, input "beforeSum", input "" ).
            run wp-xmltagput( input 4, input "qnty", input string( buf_trn-doc-sum.fact-qnty ) , 2 ).
                run wp-xmltagopen( input 4, input "saleSum", input "" ).
                    run wp-xmltagput( input 5, input "sumr",        input string( buf_trn-doc-sum.crsa-sum-rubl       ), input 1 ).
                    run wp-xmltagput( input 5, input "VATr",        input string( buf_trn-doc-sum.crsa-vat-rubl       ), input 2 ).
                    run wp-xmltagput( input 5, input "SLTr",        input string( buf_trn-doc-sum.crsa-slt-rubl       ), input 2 ).
                    run wp-xmltagput( input 5, input "roadTaxr",    input string( buf_trn-doc-sum.crsa-road-tax-rubl  ), input 2 ).
                    run wp-xmltagput( input 5, input "transportr",  input string( buf_trn-doc-sum.crsa-transport-rubl ), input 2 ).
                    run wp-xmltagput( input 5, input "otherr",      input string( buf_trn-doc-sum.crsa-other-rubl     ), input 2 ).
                    run wp-xmltagput( input 5, input "exciser",     input string( buf_trn-doc-sum.crsa-excise-rubl    ), input 2 ).
                    run wp-xmltagput( input 5, input "sumb",        input string( buf_trn-doc-sum.crsa-sum-base       ), input 2 ).
                    run wp-xmltagput( input 5, input "VATb",        input string( buf_trn-doc-sum.crsa-vat-base       ), input 2 ).
                    run wp-xmltagput( input 5, input "SLTb",        input string( buf_trn-doc-sum.crsa-slt-base       ), input 2 ).
                    run wp-xmltagput( input 5, input "roadTaxb",    input string( buf_trn-doc-sum.crsa-road-tax-base  ), input 2 ).
                    run wp-xmltagput( input 5, input "transportb",  input string( buf_trn-doc-sum.crsa-transport-base ), input 2 ).
                    run wp-xmltagput( input 5, input "otherb",      input string( buf_trn-doc-sum.crsa-other-base     ), input 2 ).
                    run wp-xmltagput( input 5, input "exciseb",     input string( buf_trn-doc-sum.crsa-excise-base    ), input 2 ).
                run wp-xmltagclose( input 4, input "saleSum" ).
                run wp-xmltagopen( input 4, input "costSum", input "" ).
                    run wp-xmltagput( input 5, input "sumr",        input string( buf_trn-doc-sum.cost-sum-rubl       ), input 1 ).
                    run wp-xmltagput( input 5, input "VATr",        input string( buf_trn-doc-sum.cost-vat-rubl       ), input 2 ).
                    run wp-xmltagput( input 5, input "SLTr",        input string( buf_trn-doc-sum.cost-slt-rubl       ), input 2 ).
                    run wp-xmltagput( input 5, input "roadTaxr",    input string( buf_trn-doc-sum.cost-road-tax-rubl  ), input 2 ).
                    run wp-xmltagput( input 5, input "transportr",  input string( buf_trn-doc-sum.cost-transport-rubl ), input 2 ).
                    run wp-xmltagput( input 5, input "otherr",      input string( buf_trn-doc-sum.cost-other-rubl     ), input 2 ).
                    run wp-xmltagput( input 5, input "exciser",     input string( buf_trn-doc-sum.cost-excise-rubl    ), input 2 ).
                    run wp-xmltagput( input 5, input "sumb",        input string( buf_trn-doc-sum.cost-sum-base       ), input 2 ).
                    run wp-xmltagput( input 5, input "VATb",        input string( buf_trn-doc-sum.cost-vat-base       ), input 2 ).
                    run wp-xmltagput( input 5, input "SLTb",        input string( buf_trn-doc-sum.cost-slt-base       ), input 2 ).
                    run wp-xmltagput( input 5, input "roadTaxb",    input string( buf_trn-doc-sum.cost-road-tax-base  ), input 2 ).
                    run wp-xmltagput( input 5, input "transportb",  input string( buf_trn-doc-sum.cost-transport-base ), input 2 ).
                    run wp-xmltagput( input 5, input "otherb",      input string( buf_trn-doc-sum.cost-other-base     ), input 2 ).
                    run wp-xmltagput( input 5, input "exciseb",     input string( buf_trn-doc-sum.cost-excise-base    ), input 2 ).
                run wp-xmltagclose( input 4, input "costSum" ).
            run wp-xmltagclose( input 3, input "beforeSum" ).
        end.        /* available buf_trn-doc-sum */
        else do:
            run wp-XMLWriteLog( input sLogFile, input 1, input "*** ERR: *** Не найдена запись trn-doc-sum с sum-type = {&sum-before-doc} для документа " + string( p-doc-code ) ).
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
            run wp-xmltagopen( input 3, input "afterSum", input "" ).
            run wp-xmltagput( input 4, input "qnty", input string( buf_trn-doc-sum.fact-qnty ), input 2 ).
                run wp-xmltagopen( input 4, input "saleSum", input "" ).
                    run wp-xmltagput( input 5, input "sumr",        input string( buf_trn-doc-sum.crsa-sum-rubl       ), input 1 ).
                    run wp-xmltagput( input 5, input "VATr",        input string( buf_trn-doc-sum.crsa-vat-rubl       ), input 2 ).
                    run wp-xmltagput( input 5, input "SLTr",        input string( buf_trn-doc-sum.crsa-slt-rubl       ), input 2 ).
                    run wp-xmltagput( input 5, input "roadTaxr",    input string( buf_trn-doc-sum.crsa-road-tax-rubl  ), input 2 ).
                    run wp-xmltagput( input 5, input "transportr",  input string( buf_trn-doc-sum.crsa-transport-rubl ), input 2 ).
                    run wp-xmltagput( input 5, input "otherr",      input string( buf_trn-doc-sum.crsa-other-rubl     ), input 2 ).
                    run wp-xmltagput( input 5, input "exciser",     input string( buf_trn-doc-sum.crsa-excise-rubl    ), input 2 ).
                    run wp-xmltagput( input 5, input "sumb",        input string( buf_trn-doc-sum.crsa-sum-base       ), input 2 ).
                    run wp-xmltagput( input 5, input "VATb",        input string( buf_trn-doc-sum.crsa-vat-base       ), input 2 ).
                    run wp-xmltagput( input 5, input "SLTb",        input string( buf_trn-doc-sum.crsa-slt-base       ), input 2 ).
                    run wp-xmltagput( input 5, input "roadTaxb",    input string( buf_trn-doc-sum.crsa-road-tax-base  ), input 2 ).
                    run wp-xmltagput( input 5, input "transportb",  input string( buf_trn-doc-sum.crsa-transport-base ), input 2 ).
                    run wp-xmltagput( input 5, input "otherb",      input string( buf_trn-doc-sum.crsa-other-base     ), input 2 ).
                    run wp-xmltagput( input 5, input "exciseb",     input string( buf_trn-doc-sum.crsa-excise-base    ), input 2 ).
                run wp-xmltagclose( input 4, input "saleSum" ).
                run wp-xmltagopen( input 4, input "costSum", input "" ).
                    run wp-xmltagput( input 5, input "sumr",        input string( buf_trn-doc-sum.cost-sum-rubl       ), input 1 ).
                    run wp-xmltagput( input 5, input "VATr",        input string( buf_trn-doc-sum.cost-vat-rubl       ), input 2 ).
                    run wp-xmltagput( input 5, input "SLTr",        input string( buf_trn-doc-sum.cost-slt-rubl       ), input 2 ).
                    run wp-xmltagput( input 5, input "roadTaxr",    input string( buf_trn-doc-sum.cost-road-tax-rubl  ), input 2 ).
                    run wp-xmltagput( input 5, input "transportr",  input string( buf_trn-doc-sum.cost-transport-rubl ), input 2 ).
                    run wp-xmltagput( input 5, input "otherr",      input string( buf_trn-doc-sum.cost-other-rubl     ), input 2 ).
                    run wp-xmltagput( input 5, input "exciser",     input string( buf_trn-doc-sum.cost-excise-rubl    ), input 2 ).
                    run wp-xmltagput( input 5, input "sumb",        input string( buf_trn-doc-sum.cost-sum-base       ), input 2 ).
                    run wp-xmltagput( input 5, input "VATb",        input string( buf_trn-doc-sum.cost-vat-base       ), input 2 ).
                    run wp-xmltagput( input 5, input "SLTb",        input string( buf_trn-doc-sum.cost-slt-base       ), input 2 ).
                    run wp-xmltagput( input 5, input "roadTaxb",    input string( buf_trn-doc-sum.cost-road-tax-base  ), input 2 ).
                    run wp-xmltagput( input 5, input "transportb",  input string( buf_trn-doc-sum.cost-transport-base ), input 2 ).
                    run wp-xmltagput( input 5, input "otherb",      input string( buf_trn-doc-sum.cost-other-base     ), input 2 ).
                    run wp-xmltagput( input 5, input "exciseb",     input string( buf_trn-doc-sum.cost-excise-base    ), input 2 ).
                run wp-xmltagclose( input 4, input "costSum" ).
            run wp-xmltagclose( input 3, input "afterSum" ).
        end.        /* available buf_trn-doc-sum */
        else do:
            run wp-XMLWriteLog( input sLogFile, input 1, input "*** ERR: *** Не найдена запись trn-doc-sum с sum-type = {&sum-after-doc} для документа " + string( p-doc-code ) ).
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
            run wp-xmltagput( input 3, input "quantityBefore", input string( buf_doc-line-sum.fact-qnty ), input 1 ).
            if p-need-petrol-weight = yes
            then do:
                run wp-xmltagput( input 3, input "petrolWeightBefore", input string( buf_doc-line-sum.fact-qnty * p-petrol-density ), input 0 ).
            end.
            run wp-xmltagopen( input 3, input "beforeSum", input "" ).
                run wp-xmltagput( input 4, input "qnty", input string( buf_doc-line-sum.fact-qnty ), input 1 ).
                run wp-xmltagopen( input 4, input "saleSum", input "" ).
                    run wp-xmltagput( input 5, input "sumr",        input string( buf_doc-line-sum.crsa-sum-rubl       ), input 1 ).
                    run wp-xmltagput( input 5, input "VATr",        input string( buf_doc-line-sum.crsa-vat-rubl       ), input 1 ).
                    run wp-xmltagput( input 5, input "SLTr",        input string( buf_doc-line-sum.crsa-slt-rubl       ), input 1 ).
                    run wp-xmltagput( input 5, input "roadTaxr",    input string( buf_doc-line-sum.crsa-road-tax-rubl  ), input 1 ).
                    run wp-xmltagput( input 5, input "transportr",  input string( buf_doc-line-sum.crsa-transport-rubl ), input 1 ).
                    run wp-xmltagput( input 5, input "otherr",      input string( buf_doc-line-sum.crsa-other-rubl     ), input 1 ).
                    run wp-xmltagput( input 5, input "exciser",     input string( buf_doc-line-sum.crsa-excise-rubl    ), input 1 ).
                    run wp-xmltagput( input 5, input "sumb",        input string( buf_doc-line-sum.crsa-sum-base       ), input 1 ).
                    run wp-xmltagput( input 5, input "VATb",        input string( buf_doc-line-sum.crsa-vat-base       ), input 1 ).
                    run wp-xmltagput( input 5, input "SLTb",        input string( buf_doc-line-sum.crsa-slt-base       ), input 1 ).
                    run wp-xmltagput( input 5, input "roadTaxb",    input string( buf_doc-line-sum.crsa-road-tax-base  ), input 1 ).
                    run wp-xmltagput( input 5, input "transportb",  input string( buf_doc-line-sum.crsa-transport-base ), input 1 ).
                    run wp-xmltagput( input 5, input "otherb",      input string( buf_doc-line-sum.crsa-other-base     ), input 1 ).
                    run wp-xmltagput( input 5, input "exciseb",     input string( buf_doc-line-sum.crsa-excise-base    ), input 1 ).
                run wp-xmltagclose( input 4, input "saleSum" ).
                run wp-xmltagopen( input 4, input "costSum", input "" ).
                    run wp-xmltagput( input 5, input "sumr",        input string( buf_doc-line-sum.cost-sum-rubl       ), input 1 ).
                    run wp-xmltagput( input 5, input "VATr",        input string( buf_doc-line-sum.cost-vat-rubl       ), input 1 ).
                    run wp-xmltagput( input 5, input "SLTr",        input string( buf_doc-line-sum.cost-slt-rubl       ), input 1 ).
                    run wp-xmltagput( input 5, input "roadTaxr",    input string( buf_doc-line-sum.cost-road-tax-rubl  ), input 1 ).
                    run wp-xmltagput( input 5, input "transportr",  input string( buf_doc-line-sum.cost-transport-rubl ), input 1 ).
                    run wp-xmltagput( input 5, input "otherr",      input string( buf_doc-line-sum.cost-other-rubl     ), input 1 ).
                    run wp-xmltagput( input 5, input "exciser",     input string( buf_doc-line-sum.cost-excise-rubl    ), input 1 ).
                    run wp-xmltagput( input 5, input "sumb",        input string( buf_doc-line-sum.cost-sum-base       ), input 1 ).
                    run wp-xmltagput( input 5, input "VATb",        input string( buf_doc-line-sum.cost-vat-base       ), input 1 ).
                    run wp-xmltagput( input 5, input "SLTb",        input string( buf_doc-line-sum.cost-slt-base       ), input 1 ).
                    run wp-xmltagput( input 5, input "roadTaxb",    input string( buf_doc-line-sum.cost-road-tax-base  ), input 1 ).
                    run wp-xmltagput( input 5, input "transportb",  input string( buf_doc-line-sum.cost-transport-base ), input 1 ).
                    run wp-xmltagput( input 5, input "otherb",      input string( buf_doc-line-sum.cost-other-base     ), input 1 ).
                    run wp-xmltagput( input 5, input "exciseb",     input string( buf_doc-line-sum.cost-excise-base    ), input 1 ).
                run wp-xmltagclose( input 4, input "costSum" ).
            run wp-xmltagclose( input 3, input "beforeSum" ).
        end.        /* available buf_doc-line-sum */
        else do:
            run wp-XMLWriteLog( input sLogFile, input 1, input "*** ERR: *** Не найдена запись doc-line-sum с sum-type = {&sum-before-doc} для документа " + string( p-doc-code ) ).
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
            run wp-xmltagput( input 3, input "quantityAfter", input string( buf_doc-line-sum.fact-qnty ), input 1 ).
            if p-need-petrol-weight = yes
            then do:
                run wp-xmltagput( input 3, input "petrolWeightAfter",  input string( buf_doc-line-sum.fact-qnty * p-petrol-density ), input 0 ).
            end.
            run wp-xmltagopen( input 3, input "afterSum", input "" ).
              run wp-xmltagput( input 4, input "qnty", input string( buf_doc-line-sum.fact-qnty ), input 1 ).
                run wp-xmltagopen( input 4, input "saleSum", input "" ).
                    run wp-xmltagput( input 5, input "sumr",        input string( buf_doc-line-sum.crsa-sum-rubl       ), input 1 ).
                    run wp-xmltagput( input 5, input "VATr",        input string( buf_doc-line-sum.crsa-vat-rubl       ), input 1 ).
                    run wp-xmltagput( input 5, input "SLTr",        input string( buf_doc-line-sum.crsa-slt-rubl       ), input 1 ).
                    run wp-xmltagput( input 5, input "roadTaxr",    input string( buf_doc-line-sum.crsa-road-tax-rubl  ), input 1 ).
                    run wp-xmltagput( input 5, input "transportr",  input string( buf_doc-line-sum.crsa-transport-rubl ), input 1 ).
                    run wp-xmltagput( input 5, input "otherr",      input string( buf_doc-line-sum.crsa-other-rubl     ), input 1 ).
                    run wp-xmltagput( input 5, input "exciser",     input string( buf_doc-line-sum.crsa-excise-rubl    ), input 1 ).
                    run wp-xmltagput( input 5, input "sumb",        input string( buf_doc-line-sum.crsa-sum-base       ), input 1 ).
                    run wp-xmltagput( input 5, input "VATb",        input string( buf_doc-line-sum.crsa-vat-base       ), input 1 ).
                    run wp-xmltagput( input 5, input "SLTb",        input string( buf_doc-line-sum.crsa-slt-base       ), input 1 ).
                    run wp-xmltagput( input 5, input "roadTaxb",    input string( buf_doc-line-sum.crsa-road-tax-base  ), input 1 ).
                    run wp-xmltagput( input 5, input "transportb",  input string( buf_doc-line-sum.crsa-transport-base ), input 1 ).
                    run wp-xmltagput( input 5, input "otherb",      input string( buf_doc-line-sum.crsa-other-base     ), input 1 ).
                    run wp-xmltagput( input 5, input "exciseb",     input string( buf_doc-line-sum.crsa-excise-base    ), input 1 ).
                run wp-xmltagclose( input 4, input "saleSum" ).
                run wp-xmltagopen( input 4, input "costSum", input "" ).
                    run wp-xmltagput( input 5, input "sumr",        input string( buf_doc-line-sum.cost-sum-rubl       ), input 1 ).
                    run wp-xmltagput( input 5, input "VATr",        input string( buf_doc-line-sum.cost-vat-rubl       ), input 1 ).
                    run wp-xmltagput( input 5, input "SLTr",        input string( buf_doc-line-sum.cost-slt-rubl       ), input 1 ).
                    run wp-xmltagput( input 5, input "roadTaxr",    input string( buf_doc-line-sum.cost-road-tax-rubl  ), input 1 ).
                    run wp-xmltagput( input 5, input "transportr",  input string( buf_doc-line-sum.cost-transport-rubl ), input 1 ).
                    run wp-xmltagput( input 5, input "otherr",      input string( buf_doc-line-sum.cost-other-rubl     ), input 1 ).
                    run wp-xmltagput( input 5, input "exciser",     input string( buf_doc-line-sum.cost-excise-rubl    ), input 1 ).
                    run wp-xmltagput( input 5, input "sumb",        input string( buf_doc-line-sum.cost-sum-base       ), input 1 ).
                    run wp-xmltagput( input 5, input "VATb",        input string( buf_doc-line-sum.cost-vat-base       ), input 1 ).
                    run wp-xmltagput( input 5, input "SLTb",        input string( buf_doc-line-sum.cost-slt-base       ), input 1 ).
                    run wp-xmltagput( input 5, input "roadTaxb",    input string( buf_doc-line-sum.cost-road-tax-base  ), input 1 ).
                    run wp-xmltagput( input 5, input "transportb",  input string( buf_doc-line-sum.cost-transport-base ), input 1 ).
                    run wp-xmltagput( input 5, input "otherb",      input string( buf_doc-line-sum.cost-other-base     ), input 1 ).
                    run wp-xmltagput( input 5, input "exciseb",     input string( buf_doc-line-sum.cost-excise-base    ), input 1 ).
                run wp-xmltagclose( input 4, input "costSum" ).
            run wp-xmltagclose( input 3, input "afterSum" ).
        end.        /* available buf_doc-line-sum */
        else do:
            run wp-XMLWriteLog( input sLogFile, input 1, input "*** ERR: *** Не найдена запись doc-line-sum с sum-type = {&sum-after-doc} для документа " + string( p-doc-code ) ).
        end.        /* NOT ( available buf_doc-line-sum ) */
    end.        /* if p-exists-after = yes */
end.
end procedure. /* export-before-and-after-inv-line */

/*==========================================================================*/
procedure get-petrol-weight :
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
    define buffer buf_inv-line      for ub.inv-line.
do
for buf_doc-line
  , buf_rvs-doc
  , buf_rvs-line
  , buf_goods
  , buf_doc-pl
  , buf_inv-line
on error undo, return error
:
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
    find first buf_inv-line no-lock
         where buf_inv-line.doc-code    = buf_doc-line.doc-code
           and buf_inv-line.artic       = buf_doc-line.artic
           and buf_inv-line.prod-type   = buf_doc-line.prod-type
           and buf_inv-line.prod-code   = buf_doc-line.prod-code
    no-error.
    if available buf_inv-line
    then do:
        case p-ext-doc-type:
            when {&TDEDT_Pri_Vnesh}
            or when {&TDEDT_Vozvrat_Vnesh}
            or when {&TDEDT_Spi_Vnesh}
            or when {&TDEDT_Pri_Vnesh}
            or when {&TDEDT_Vozvrat_Vnesh_Kass}
            or when {&TDEDT_Ras_Vnesh_VP}
            or when {&TDEDT_Ras_Vnesh_Kass}
            then do:
                assign
                    p-petrol-weight        = buf_inv-line.wast-cli-qnty
                    p-weight-not-specified = no
                .
            end.        /* when {&TDEDT_Pri_Vnesh} */
            when {&TDEDT_Inv}
            or when {&TDEDT_Peresort}
            or when {&TDEDT_Corr_Acc_Price}
            or when {&TDEDT_Corr_Minus_Parts}
            then do:
                assign
                    p-petrol-weight        = buf_doc-line.cli-qnty
                    p-weight-not-specified = no
                .
            end.        /* when {&TDEDT_Inv} */
            otherwise do:
                assign
                    p-weight-not-specified = yes
                .
            end.        /* otherwise */
        end case.
    end.        /* if available buf_inv-line */
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
       where buf_inkas-pay-desk.inkas-code = p-inkas-code
         and buf_inkas-pay-desk.doc-type = p-inkas-pay-desk-type
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
procedure export-checks :

define input parameter p-ext-doc-type   as character    no-undo.
define input parameter p-doc-code       as character    no-undo.
define input parameter p-obj-type       as character    no-undo.
define input parameter p-obj-code       as integer      no-undo.

    define variable v-write-off as logical no-undo .
    /*признак чека со списанными товарами*/

    define buffer buf_chk-doc       for ub.chk-doc.
    define buffer buf_chk-doc-attr  for ub.chk-doc-attr.
    define buffer buf_chk-gds       for ub.chk-gds.
    define buffer buf_chk-pay       for ub.chk-pay.
    define buffer buf_chk-pay-attr  for ub.chk-pay-attr.
    define buffer buf_bar-code      for ub.bar-code.
    define buffer buf_goods         for ub.goods.
    define buffer buf_c-chk-doc     for ub.c-chk-doc.
    define buffer buf_chk-discnt    for ub.chk-discnt.
    define buffer buf_dis-card      for ub.dis-card.
    define buffer buf_chk-gds-pay   for ub.chk-gds-pay.
    define variable v-RRN               as character no-undo.

do
for buf_chk-doc
  , buf_chk-gds
  , buf_chk-pay
  , buf_bar-code
  , buf_goods
  , buf_c-chk-doc
  , buf_chk-discnt
  , buf_dis-card
on error undo, return error
:
    for each buf_chk-doc no-lock
       where buf_chk-doc.out-code = p-doc-code
    :
        if buf_chk-doc.correct = no then next.
        if lookup(string(buf_chk-doc.chk-type), {&no-sale-receipt-codes}) > 0 then next.

        find first buf_dis-card no-lock
              where buf_dis-card.d-card = buf_chk-doc.d-card
        no-error.

        run wp-xmltagopen( input 3, input "check"   , input "" ).
        run wp-xmltagput( input 4, input "type"     , input string( buf_chk-doc.office   )                               , input 2 ).
        run wp-xmltagput( input 4, input "num"      , input string( buf_chk-doc.chk-num  )                               , input 2 ).
        run wp-xmltagput( input 4, input "doccode"  , input string( buf_chk-doc.doc-code )                               , input 2 ).
/*        run wp-xmltagput( input 4, input "type"     , input ( if buf_chk-doc.netto >= 0 then {&income} else {&return} )  , input 2 ).*/
        run wp-xmltagput( input 4, input "desk"     , input string( buf_chk-doc.pay-desk )                               , input 2 ).
        run wp-xmltagput( input 4, input "date"     , input string( buf_chk-doc.chk-date, "99.99.9999" )                 , input 2 ).
        run wp-xmltagput( input 4, input "dateXml"  , input bge-xml-date( buf_chk-doc.chk-date )                         , input 2 ).
        run wp-xmltagput( input 4, input "time"     , input string( buf_chk-doc.chk-time, "HH:MM:SS" )                   , input 2 ).
        run wp-xmltagput( input 4, input "shiftDate", input string( buf_chk-doc.shift-date, "99.99.9999" )               , input 2 ).
        run wp-xmltagput( input 4, input "shiftDateXml", input bge-xml-date( buf_chk-doc.shift-date )                    , input 2 ).
        run wp-xmltagput( input 4, input "shiftNum" , input string( buf_chk-doc.shift-num )                              , input 2 ).
        run wp-xmltagput( input 4, input "dCard"    , input string( buf_chk-doc.d-card   )                               , input 2 ).
        if available buf_dis-card
        then do:
          run wp-xmltagput( input 4, input "dCardCliType" , input string( buf_dis-card.cli-type )                        , input 2 ).
          run wp-xmltagput( input 4, input "dCardCliCode" , input string( buf_dis-card.cli-code )                        , input 2 ).
        end.
        run wp-xmltagput( input 4, input "discnt"   , input string( buf_chk-doc.discnt   )                               , input 2 ).
        run wp-xmltagput( input 4, input "cashier"  , input string( buf_chk-doc.cashier  )                               , input 1 ).
        run wp-xmltagput( input 4, input "cashierPsnCode"  , input string( buf_chk-doc.cashier-psn-code  )               , input 1 ).
        run wp-xmltagput( input 4, input "salesMan" , input string( buf_chk-doc.sales-man )                              , input 2 ).
        run wp-xmltagput( input 4, input "zNumber"  , input string( buf_chk-doc.z-number )                               , input 2 ).
        find first buf_c-chk-doc
             where buf_c-chk-doc.doc-code   = buf_chk-doc.doc-code
               and buf_c-chk-doc.obj-type   = buf_chk-doc.obj-type
               and buf_c-chk-doc.obj-code   = buf_chk-doc.obj-code
               and buf_c-chk-doc.is-add     = yes
        use-index pi /* по doc-code быстрее  */
        no-error.
        if available buf_c-chk-doc
        then do:        /* Чек сделан вручную */
            run wp-xmltagput( input 4, input "manualMaked"  , input "yes":U                                , input 2 ).
        end.
        find first buf_c-chk-doc
             where buf_c-chk-doc.doc-code   = buf_chk-doc.doc-code
               and buf_c-chk-doc.obj-type   = buf_chk-doc.obj-type
               and buf_c-chk-doc.obj-code   = buf_chk-doc.obj-code
               and buf_c-chk-doc.is-add     = no
               and buf_c-chk-doc.is-del     = no
        use-index pi /* по doc-code быстрее  */
        no-error.
        if available buf_c-chk-doc
        then do:        /* Чек изменен вручную */
            run wp-xmltagput( input 4, input "manualChanged"  , input "yes":U                               , input 2 ).
        end.
        find first buf_chk-doc-attr where buf_chk-doc-attr.doc-code  eq buf_chk-doc.doc-code
                                      and buf_chk-doc-attr.attr-code eq "CHNumberKKT"
             no-lock no-error.
        if avail buf_chk-doc-attr
        then
           run wp-xmltagput( input 4, input "CHNumberKKT", input buf_chk-doc-attr.attr-value, input 2 ).
        find first buf_chk-doc-attr where buf_chk-doc-attr.doc-code  eq buf_chk-doc.doc-code
                                      and buf_chk-doc-attr.attr-code eq "CHNumberFN"
             no-lock no-error.
        if avail buf_chk-doc-attr
        then
           run wp-xmltagput( input 4, input "CHNumberFN", input buf_chk-doc-attr.attr-value, input 2 ).

        if buf_chk-doc.d-card <> "":U
        then do:
            if available buf_dis-card
            then do:
                run fill_bge-xml_dis-card in this-procedure (
                      input p-parent-proc
                    , input buf_chk-doc.d-card
                ).
                run fill_bge-xml_clients in this-procedure (
                      input p-parent-proc
                    , input buf_dis-card.cli-type
                    , input buf_dis-card.cli-code
                ).
            end.
        end.
        assign
            v-write-off = no
        .
        if buf_chk-doc.sub-discnt <> 0
        then do:
          /*убедимся что это не скидка на итог на списанные блюда*/
          if buf_chk-doc.chk-type = integer({&rcpt-return-write-off})
          then do:
            assign
                v-write-off = yes
            .
          end.
          else do:
            /*придется порускать по товарам и посмотреть коды списания*/
            _for:
            for each buf_chk-gds no-lock where
                    buf_chk-gds.doc-code = buf_chk-doc.doc-code :
              if buf_Chk-gds.write-off-code <> ?
              and buf_Chk-gds.write-off-code <> 0 then do:
                assign
                v-write-off = yes.
                leave _for.
              end.
            end.
          end.
        end.
        /*это сумма списанных товаров как скидку на итог выгрузим 0*/
        if v-write-off then
        run wp-xmltagput( input 4, input "subDiscnt", input string( 0 )                                                  , input 2 ).
        else
        run wp-xmltagput( input 4, input "subDiscnt", input string( buf_chk-doc.sub-discnt )                             , input 2 ).
        run wp-xmltagput( input 4, input "totDoc"   , input string( buf_chk-doc.tot-doc )                                , input 2 ).
        for each buf_chk-gds no-lock
           where buf_chk-gds.doc-code = buf_chk-doc.doc-code
        :
            find first buf_bar-code no-lock
                 where buf_bar-code.b-code = buf_chk-gds.b-code
            .
/*            find first buf_goods    no-lock*/
/*                 where buf_goods.gds-code = buf_bar-code.gds-code*/
/*            .*/
            run wp-xmltagopen( input 4, input "checkGds", input "" ).
            run wp-xmltagput( input 5, input "gdsCode"      , input string( buf_bar-code.gds-code )     , input 2 ).
            run wp-xmltagput( input 5, input "qnty"         , input string( buf_chk-gds.doc-qnty )      , input 2 ).
            run wp-xmltagput( input 5, input "priceBase"    , input string( buf_chk-gds.price-base )    , input 2 ).
            run wp-xmltagput( input 5, input "priceService" , input string( buf_chk-gds.price-service ) , input 2 ).
            run wp-xmltagput( input 5, input "priceDiscnt"  , input string( buf_chk-gds.discnt )        , input 2 ).
            run wp-xmltagput( input 5, input "lineNum"      , input string( buf_chk-gds.line-num )      , input 2 ).
            run wp-xmltagput( input 5, input "pump"         , input string( buf_chk-gds.pump )          , input 2 ).
            run wp-xmltagput( input 5, input "pl"           , input string( buf_chk-gds.loc1)           , input 2 ).
            run wp-xmltagput( input 5, input "nozzle"       , input string( buf_chk-gds.nozzle-code)    , input 2 ).            
            run wp-xmltagput( input 5, input "density"      , input string( buf_chk-gds.density)        , input 2 ).
            run wp-xmltagput( input 5, input "roadTax"      , input string( buf_chk-gds.road-tax )      , input 2 ).
            run wp-xmltagput( input 5, input "crcCode"      , input string( entry(1, buf_chk-gds.src-code, {&delim-par}) )      , input 2 ).
            run wp-xmltagput( input 5, input "srcQnty"      , input string( buf_chk-gds.src-qnty )      , input 2 ).
            run wp-xmltagput( input 5, input "srcPrice"     , input string( buf_chk-gds.src-price )     , input 2 ).
            run wp-xmltagput( input 5, input "VATRate"      , input string( buf_chk-gds.vat-pc      )   , input 2 ).
            run wp-xmltagput( input 5, input "VAT"          , input string( buf_chk-gds.vat-sum-rubl)   , input 2 ). 
            run wp-xmltagclose( input 4, input "checkGds" ).
        end.      /* for each buf_chk-gds no-lock */
        for each buf_chk-pay no-lock
           where buf_chk-pay.doc-code = buf_chk-doc.doc-code
        :
            run wp-xmltagopen( input 4, input "checkPay", input "" ).
            run wp-xmltagput( input 5, input "payCode"      , input string( buf_chk-pay.pay-code )     , input 2 ).
            run wp-xmltagput( input 5, input "payCard"      , input string( buf_chk-pay.pay-card )     , input 2 ).
            v-RRN = '' .
            for first buf_chk-pay-attr no-lock
                where buf_chk-pay-attr.doc-code = buf_chk-pay.doc-code 
                and buf_chk-pay-attr.attr-code = "CPDOC" 
                and buf_chk-pay-attr.line-num = buf_chk-pay.line-num  :
                v-RRN = buf_chk-pay-attr.attr-value .
            end.       
            if v-RRN = '' 
            then 
            do: 
                for first buf_chk-pay-attr no-lock
                    where buf_chk-pay-attr.doc-code = buf_chk-pay.doc-code 
                    and buf_chk-pay-attr.attr-code = "RRN"
                    and buf_chk-pay-attr.line-num = buf_chk-pay.line-num:
                    v-RRN = buf_chk-pay-attr.attr-value .
                end.
            end.
            run wp-xmltagput( input 5, input "OperationCode", input v-RRN                              , input 2 ).
            run wp-xmltagput( input 5, input "currCode"     , input string( buf_chk-pay.curr-code )    , input 0 ).
            run wp-xmltagput( input 5, input "sumBase"      , input string( buf_chk-pay.tot-base )     , input 2 ).
            run wp-xmltagput( input 5, input "sumRubl"      , input string( buf_chk-pay.tot-rubl )     , input 2 ).
            run wp-xmltagput( input 5, input "sumTot"       , input string( buf_chk-pay.tot-sum  )     , input 2 ).
            run wp-xmltagput( input 5, input "lineNum"      , input string( buf_chk-pay.line-num  )    , input 2 ).
            run wp-xmltagclose( input 4, input "checkPay" ).
        end.        /* for each buf_chk-pay no-lock */
        for each buf_chk-gds-pay no-lock
           where buf_chk-gds-pay.doc-code = buf_chk-doc.doc-code
        :
            run wp-xmltagopen( input 4, input "checkGdsPay", input "" ).
            run wp-xmltagput( input 5, input "line-num"      , input string( buf_chk-gds-pay.line-num )     , input 2 ).
            run wp-xmltagput( input 5, input "cpline-num"    , input string( buf_chk-gds-pay.cpline-num )   , input 2 ).
            run wp-xmltagput( input 5, input "sum-rubl"      , input string( buf_chk-gds-pay.tot-r-b )      , input 2 ).
            run wp-xmltagput( input 5, input "CGPqnty"       , input string( buf_chk-gds-pay.eff-doc-qnty ) , input 2 ).     
            run wp-xmltagput( input 5, input "pay-code"      , input string( buf_chk-gds-pay.pay-code )     , input 2 ).
            run wp-xmltagclose( input 4, input "checkGdsPay" ).
        end.     /* for each buf_chk-gds-pay */ 

&scop discnt-type-code string(buf_chk-discnt.discnt-type)
&scop discnt-target-code string(buf_chk-discnt.line-type)
&scop discnt-v-code string(buf_chk-discnt.value-type)

        for each buf_chk-discnt no-lock
          where buf_chk-discnt.doc-code = buf_chk-doc.doc-code
            and buf_chk-discnt.record-type = 0
        :
          run wp-xmltagopen in this-procedure ( input 4, input "checkDiscount"   , input "" ).
          run wp-xmltagput in this-procedure ( input 5, input "lineNum"          , input string( buf_chk-discnt.line-num )         , input 1 ).
          run wp-xmltagput in this-procedure ( input 5, input "discntVName"      , input {&discnt-v-name}                          , input 1 ).
          run wp-xmltagput in this-procedure ( input 5, input "objectLineNum"    , input string( buf_chk-discnt.object-line-num )  , input 1 ).
          run wp-xmltagput in this-procedure ( input 5, input "discntTargetName" , input {&discnt-target-name}                     , input 1 ).
          run wp-xmltagput in this-procedure ( input 5, input "discntTypeName"   , input {&discnt-type-name}                       , input 1 ).
          run wp-xmltagput in this-procedure ( input 5, input "discntValueAbs"   , input string( buf_chk-discnt.discnt-value-abs ) , input 1 ).
          run wp-xmltagput in this-procedure ( input 5, input "discntValuePcnt"  , input string( buf_chk-discnt.discnt-value-pcnt ), input 1 ).
          run wp-xmltagput in this-procedure ( input 5, input "srcDCard"         , input string( buf_chk-discnt.src-d-card )       , input 2 ).
          run wp-xmltagput in this-procedure ( input 5, input "discntKategory"   , input string( if buf_chk-discnt.src-d-card <> ''
                                                                                                 and buf_chk-discnt.src-d-card <> ?
                                                                                                 and available buf_dis-card
                                                                                                 and buf_dis-card.d-card = buf_chk-discnt.src-d-card
                                                                                                 and buf_chk-discnt.kateg = ?
                                                                                                 then buf_dis-card.category
                                                                                                 else buf_chk-discnt.kateg )        , input 2 ).
          run wp-xmltagput in this-procedure ( input 5, input "discntType"        , input string(buf_chk-discnt.discnt-type)  , input 1 ).
          run wp-xmltagclose in this-procedure ( input 4, input "checkDiscount" ).
        end. /* for each buf_chk-dicsnt no-lock  */
        /*Добавляем в выгрузку скидок еще и скидки, которыми выравниваются погрешности*/
        for each buf_chk-discnt no-lock
          where buf_chk-discnt.doc-code = buf_chk-doc.doc-code
            and buf_chk-discnt.record-type = 2
        :
          run wp-xmltagopen in this-procedure ( input 4, input "checkDiscount"   , input "" ).
          run wp-xmltagput in this-procedure ( input 5, input "lineNum"          , input string( buf_chk-discnt.line-num )         , input 1 ).
          run wp-xmltagput in this-procedure ( input 5, input "discntVName"      , input {&discnt-v-name}                          , input 1 ).
          run wp-xmltagput in this-procedure ( input 5, input "objectLineNum"    , input string( buf_chk-discnt.object-line-num )  , input 1 ).
          run wp-xmltagput in this-procedure ( input 5, input "discntTargetName" , input {&discnt-target-name}                     , input 1 ).
          run wp-xmltagput in this-procedure ( input 5, input "discntTypeName"   , input {&discnt-type-name}                       , input 1 ).
          run wp-xmltagput in this-procedure ( input 5, input "discntValueAbs"   , input string( buf_chk-discnt.discnt-value-abs ) , input 1 ).
          run wp-xmltagput in this-procedure ( input 5, input "discntValuePcnt"  , input string( buf_chk-discnt.discnt-value-pcnt ), input 1 ).
          run wp-xmltagput in this-procedure ( input 5, input "srcDCard"         , input string( buf_chk-discnt.src-d-card )       , input 2 ).
          run wp-xmltagput in this-procedure ( input 5, input "discntKategory"   , input string( if buf_chk-discnt.src-d-card <> ''
                                                                                                 and buf_chk-discnt.src-d-card <> ?
                                                                                                 and available buf_dis-card
                                                                                                 and buf_dis-card.d-card = buf_chk-discnt.src-d-card
                                                                                                 and buf_chk-discnt.kateg = ?
                                                                                                 then buf_dis-card.category
                                                                                                 else buf_chk-discnt.kateg )        , input 2 ).
          run wp-xmltagput in this-procedure ( input 5, input "discntType"        , input string(buf_chk-discnt.discnt-type)  , input 1 ).                                                                                                 
          run wp-xmltagclose in this-procedure ( input 4, input "checkDiscount" ).
        end. /* for each buf_chk-dicsnt no-lock  */


        run wp-xmltagclose( input 3, input "check" ).
    end.        /* for each buf_chk-doc no-lock */
end.
end procedure. /* export-checks */

/*==========================================================================*/
procedure run-callback-write-doc-code :
do
on error undo, return error
:
define input parameter p-handle         as handle       no-undo.
define input parameter p-type           as character    no-undo.
define input parameter p-doc-code       as character    no-undo.
define input parameter p-log-file       as character    no-undo.

define variable v-procedure-name    as char no-undo.

case p-type
:
    when {&table_price-doc}
    then do:
      assign
        v-procedure-name = "fill-temp-pr-doc-num":U
      .
    end. /* when {&table_price-doc} */
    when {&table_trn-doc}
    then do:
      assign
        v-procedure-name = "fill-temp-doc-code":U
      .
    end. /* when {&table_trn-doc} */
    when {&table_c-trn-doc}
    then do:
      assign
        v-procedure-name = "fill-temp-del-doc-code":U
      .
    end. /* when {&table_c-trn-doc} */
    when {&table_ord-doc}
    then do:
      assign
        v-procedure-name = "fill-temp-ord-doc-code":U
      .
    end. /* when {&table-ord-doc} */
end case.       /* case p-type */

if lookup( v-procedure-name, p-handle :internal-entries ) > 0
then do:
    run value( v-procedure-name ) in p-handle ( input p-doc-code ) no-error.
    if error-status :error
    then do:
        run wp-XMLWriteLog in this-procedure (
              input p-log-file
            , input 1
            , input substitute( "Ошибка при вызове callback - процедуры &1.", v-procedure-name )
        ).
    end.
end.
else do:                           /* нет такой процедуры */
    run wp-XMLWriteLog in this-procedure (
          input p-log-file
        , input 1
        , input substitute( "Не найдена callback - процедура &1.", v-procedure-name )
    ).
end.

end.
end procedure. /* run-callback-write-doc-code */

/*==========================================================================*/
procedure export-deleted-docs :
define input parameter p-doc-code           as character        no-undo.
define input parameter p-corr-user-db-num   as integer          no-undo.
define input parameter p-chip-num           as integer          no-undo.

    define buffer buf_c-trn-doc     for ub.c-trn-doc.

    define variable v-firm-code as character no-undo .
do
for buf_c-trn-doc
on error undo, return error
:
    find first buf_c-trn-doc no-lock
         where buf_c-trn-doc.doc-code           = p-doc-code
           and buf_c-trn-doc.corr-user-db-num   = p-corr-user-db-num
           and buf_c-trn-doc.chip-num           = p-chip-num
    .
    assign
      v-firm-code = buf_c-trn-doc.cli-type + string( buf_c-trn-doc.cli-code )
    .
    run wp-XMLWriteCnt( input hcnt, input substitute( "Удаленный: &1 от &2", p-doc-code, buf_c-trn-doc.fact-date ) ).
    process events.
    run wp-xmltagopen( input 2, input "operation", input "" ).
    run wp-xmltagput( input 3, input "referenceNo"  , input buf_c-trn-doc.doc-code                                   , input 0 ).
    run wp-xmltagput( input 3, input "isDel"        , input "yes"                                                    , input 0 ).
    run wp-xmltagput( input 3, input "flagDel"      , input buf_c-trn-doc.is-del                                     , input 0 ).
    run wp-xmltagput( input 3, input "codeOperation", input string( buf_c-trn-doc.ext-doc-type                      ), input 0 ).
    run wp-xmltagput( input 3, input "host"         , input string( buf_c-trn-doc.host-code                         ), input 0 ).
    run wp-xmltagput( input 3, input "store"        , input buf_c-trn-doc.obj-type + string( buf_c-trn-doc.obj-code ), input 0 ).
    run wp-xmltagput( input 3, input "dateDel"      , input string( buf_c-trn-doc.corr-date ,"99.99.9999"           ), input 0 ).
    run wp-xmltagput( input 3, input "dateDelXml"   , input bge-xml-date( buf_c-trn-doc.corr-date )                  , input 0 ).
    run wp-xmltagput( input 3, input "dateDoc"      , input string( buf_c-trn-doc.doc-date  ,"99.99.9999"           ), input 0 ).
    run wp-xmltagput( input 3, input "dateDocXml"   , input bge-xml-date( buf_c-trn-doc.doc-date )                   , input 0 ).
    run wp-xmltagput( input 3, input "dateFact"     , input string( buf_c-trn-doc.fact-date ,"99.99.9999"           ), input 0 ).
    run wp-xmltagput( input 3, input "dateFactXml"  , input bge-xml-date( buf_c-trn-doc.fact-date )                  , input 0 ).

    if buf_c-trn-doc.ext-doc-type <> {&TDEDT_Overturn}
    then do:
      run wp-xmltagput( input 3, input "firm"         , input v-firm-code                                              , input 0 ).
    end.

    run wp-xmltagput( input 3, input "outCode"      , input string( buf_c-trn-doc.out-code                          ), input 0 ).
    run wp-xmltagput( input 3, input "comment"      , input buf_c-trn-doc.PS                                         , input 0).
    run wp-xmltagclose( input 2, input "operation" ).
end.
end procedure. /* export-deleted-docs */


/*==========================================================================*/
procedure export-gds-dtl :
define input parameter p-doc-code   as character        no-undo.
define input parameter p-artic      as character        no-undo.
define input parameter p-prod-type  as character        no-undo.
define input parameter p-prod-code  as integer          no-undo.

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
    .
    find first buf_doc-line no-lock
         where buf_doc-line.doc-code    = p-doc-code
           and buf_doc-line.artic       = p-artic
           and buf_doc-line.prod-type   = p-prod-type
           and buf_doc-line.prod-code   = p-prod-code
    .
    for each buf_gds-dtl no-lock
       where buf_gds-dtl.prod-type  = p-prod-type
         and buf_gds-dtl.prod-code  = p-prod-code
         and buf_gds-dtl.artic      = p-artic
         and buf_gds-dtl.doc-code   = p-doc-code
    :
        find first buf_gds-prt no-lock
             where buf_gds-prt.node-code = buf_gds-dtl.prt-code
        no-error .
        { str/out-vatp.i calc-gds-dtl buf_doc-line. buf_trn-doc. buf_gds-dtl. }
        assign
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
        run wp-xmltagopen in this-procedure ( input 5, input "dtl", input "" ).
        run wp-xmltagput in this-procedure ( input 6
                                           , input "dtlName"
                                           , input if available buf_gds-prt then string( buf_gds-prt.f-name ) else ""
                                           , input 2
                                           ).
        run wp-xmltagput in this-procedure ( input 6, input "qnty"      , input string( v-fact-qnty        ), input 2 ).
        run wp-xmltagput in this-procedure ( input 6, input "sumr"      , input string( v-sum-rubl         ), input 2 ).
        run wp-xmltagput in this-procedure ( input 6, input "VATr"      , input string( v-vat-rubl         ), input 2 ).
        run wp-xmltagput in this-procedure ( input 6, input "SLTr"      , input string( v-slt-rubl         ), input 2 ).
        run wp-xmltagput in this-procedure ( input 6, input "roadTaxr"  , input string( v-road-tax-rubl    ), input 2 ).
        run wp-xmltagput in this-procedure ( input 6, input "sumb"      , input string( v-sum-base         ), input 2 ).
        run wp-xmltagput in this-procedure ( input 6, input "VATb"      , input string( v-vat-base         ), input 2 ).
        run wp-xmltagput in this-procedure ( input 6, input "SLTb"      , input string( v-slt-base         ), input 2 ).
        run wp-xmltagput in this-procedure ( input 6, input "roadTaxb"  , input string( v-road-tax-base    ), input 2 ).
        run wp-xmltagclose in this-procedure ( input 5, input "dtl" ).
    end.        /* for each buf_gds-dtl no-lock */
end.
end procedure. /* export-gds-dtl */

/*==========================================================================*/
procedure write-doc-header :
define input parameter p-obj-type               as character        no-undo.
define input parameter p-obj-code               as integer          no-undo.
define input parameter p-ext-doc-type           as character        no-undo.
define input parameter p-doc-code               as character        no-undo.
define input parameter p-doc-date               as date             no-undo.
define input parameter p-fact-date              as date             no-undo.
define input parameter p-reason-code            as integer          no-undo.
define input parameter p-doc-PS                 as character        no-undo.
define input parameter p-fact-order             as decimal          no-undo.
define input parameter p-sys-date               as date             no-undo.
define input parameter p-sys-time               as character        no-undo.
define input parameter p-firm-code              as character        no-undo.
define input parameter p-ord-num                as character        no-undo.
define input parameter p-ship-num               as character        no-undo.
define input parameter p-ship-date              as date             no-undo.
define input parameter p-payment-code           as integer          no-undo.
define input parameter p-hold-doc-code-child    as character        no-undo.
define input parameter p-hold-doc-code-parent   as character        no-undo.
define input parameter p-hold-obj-type          as character        no-undo.
define input parameter p-hold-obj-code          as integer          no-undo.
define input parameter p-out-code               as character        no-undo.
define input parameter p-supp-dog-code          as character        no-undo.
define input parameter p-supp-ndog              as character        no-undo.
define input parameter p-supp-ddog              as character        no-undo.
define input parameter p-d-card                 as character        no-undo.
define input parameter p-cli-type               as character        no-undo.
define input parameter p-cli-code               as integer          no-undo.

  define variable v-attr-value        as character    no-undo.
  define variable v-attr-type         as character    no-undo.
  define variable v-ext-doc-type      as character    no-undo.
  define variable v-doc-exch-code     as integer      no-undo.
  define variable v-doc-exch-rate     as decimal      no-undo.
  define variable v-doc-exch-scale    as integer      no-undo.
  define variable v-fact-time         as integer      no-undo.
  define variable v-idContr           as character    no-undo. 
  
  define buffer buf_ord-chain   for ub.ord-chain.
  define buffer buf_ord-doc-rcv for ub.ord-doc-rcv.
  define buffer buf_trn-doc     for ub.trn-doc.


do
for buf_ord-chain
  , buf_ord-doc-rcv
  , buf_trn-doc
on error undo, return error
:
    assign
      v-ext-doc-type    = p-ext-doc-type
      v-doc-exch-code   = ?
      v-doc-exch-rate   = ?
      v-doc-exch-scale  = ?
      v-fact-time = ?
    .
    if p-ext-doc-type = {&TDEDT_Pri_Vnesh}
    then do:
      run bge-xml-resolve-ext-doc-type in this-procedure ( input  p-ext-doc-type
                                                         , input  p-cli-type
                                                         , input  p-cli-code
                                                         , output v-ext-doc-type
                                                         ).
    end. /* if p-ext-doc-type = {&TDEDT_Pri_Vnesh} */

    find first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = p-doc-code
    no-error .
    if available buf_trn-doc
    then do:
      assign
        v-doc-exch-code   = buf_trn-doc.exch-code
        v-doc-exch-rate   = buf_trn-doc.exch-rate
        v-doc-exch-scale  = buf_trn-doc.exch-scale
        v-fact-time       = buf_trn-doc.fact-time
      .
    end.
    
    { str/tdat-val.i p-doc-code {&trdcattr-idCountryContr} v-idContr v-attr-type no-error } 

    run wp-xmltagopen( 2, "operation","" ).
    run wp-xmltagput( input 3, input "referenceNo"  , input string( p-doc-code                          ), input 0 ).
    run wp-xmltagput( input 3, input "codeOperation", input string( v-ext-doc-type                      ), input 0 ).
    run wp-xmltagput( input 3, input "host"         , input string( p-host-code                         ), input 0 ).
    run wp-xmltagput( input 3, input "store"        , input p-obj-type + string( p-obj-code )            , input 0 ).
    run wp-xmltagput( input 3, input "factOrder"    , input string( p-fact-order                        ), input 0 ).
    run wp-xmltagput( input 3, input "sysDate"      , input string( p-sys-date ,"99.99.9999"            ), input 0 ).
    run wp-xmltagput( input 3, input "sysDateXml"   , input bge-xml-date( p-sys-date )                   , input 0 ).
    run wp-xmltagput( input 3, input "sysTime"      , input string( p-sys-time                          ), input 0 ).
    run wp-xmltagput( input 3, input "dateDoc"      , input string( p-doc-date,"99.99.9999"             ), input 0 ).
    run wp-xmltagput( input 3, input "dateDocXml"   , input bge-xml-date( p-doc-date )                   , input 0 ).
    run wp-xmltagput( input 3, input "dateFact"     , input string( p-fact-date,"99.99.9999"            ), input 0 ).
    run wp-xmltagput( input 3, input "dateFactXml"  , input bge-xml-date( p-fact-date )                  , input 0 ).
    run wp-xmltagput( input 3, input "timeFact"     , input string( v-fact-time,"hh:mm:ss"              ), input 1 ).
    run wp-xmltagput( input 3, input "valutCode"    , input string( v-base-code                         ), input 0 ).
    run wp-xmltagput( input 3, input "valutCodeOKV" , input string( v-base-code-okv                     ), input 0 ).
    
    run wp-xmltagput( input 3, input "GosContract"  , input string( v-idContr                           ), input 0 ).  
    
    run wp-xmltagput( input 3, input "exchCode"     , input string( v-doc-exch-code                     ), input 0 ).
    run wp-xmltagput( input 3, input "exchRate" , input string( v-doc-exch-rate                     ), input 0 ).
    run wp-xmltagput( input 3, input "exchScale", input string( v-doc-exch-scale                    ), input 0 ).

    if p-ext-doc-type <> {&TDEDT_Overturn}
    then do:
        run wp-xmltagput( 3, "firm",                 p-firm-code                             , 0 ).
        run wp-xmltagput( 3, "extNumber",            string( p-ord-num                      ), 0 ).
        run wp-xmltagput( 3, "outNumber",            string( p-ship-num                     ), 0 ).
        run wp-xmltagput( 3, "outDate",              string( p-ship-date,  "99.99.9999"     ), 0 ).
        run wp-xmltagput( 3, "outDateXml",           bge-xml-date( p-ship-date )             , 0 ).
        run wp-xmltagput( 3, "paymentCode",          string( p-payment-code                 ), 0 ).
        run wp-xmltagput( 3, "InterFirmDocChild",    string( p-hold-doc-code-child          ), 0 ).
        run wp-xmltagput( 3, "InterFirmDocParent",   string( p-hold-doc-code-parent         ), 0 ).
        run wp-xmltagput( 3, "InterFirmObjType",     string( p-hold-obj-type                ), 0 ).
        run wp-xmltagput( 3, "InterFirmObjCode",     string( p-hold-obj-code                ), 0 ).
        { str/tdat-val.i
            p-doc-code
            {&trdcattr-dov}
            v-attr-value
            v-attr-type
        }
        run wp-xmltagput( 3, "authority",     v-attr-value, 0 ).
        { str/tdat-val.i
            p-doc-code
            {&trdcattr-dids}
            v-attr-value
            v-attr-type
        }
        run wp-xmltagput( 3, "suppInDocDate"   , v-attr-value                    , 0 ).
        run wp-xmltagput( 3, "suppInDocDateXml", bge-xml-str-date( v-attr-value ), 0 ).
    end.      /* p-ext-doc-type <> {&TDEDT_Overturn} */

    { str/tdat-val.i
          p-doc-code
          {&trdcattr-nids}
          v-attr-value
          v-attr-type
    }
    run wp-xmltagput( 3, "suppInDocNo"         , v-attr-value                    , 0 ).

    if p-ext-doc-type <> {&TDEDT_Overturn}
    then do:
        run wp-xmltagput( 3, "contractSuppCode"    , p-supp-dog-code                 , 0 ).
        run wp-xmltagput( 3, "contractSuppNo"      , p-supp-ndog                     , 0 ).
        run wp-xmltagput( 3, "contractSuppDate"    , p-supp-ddog                     , 0 ).
        run wp-xmltagput( 3, "contractSuppDateXml" , bge-xml-str-date( p-supp-ddog ) , 0 ).
        { str/tdat-val.i
            p-doc-code
            {&trdcattr-ddog}
            v-attr-value
            v-attr-type
            no-error
        }
        if error-status :error
        then do:
            run wp-XMLWriteLog in this-procedure (
                  input sLogFile
                , input 1
                , substitute( "*** ERR: *** Ошибка чтения атрибута даты договора для приходной накладной N &1 ", p-doc-code )
            ).
        end.
        run wp-xmltagput( 3, "contractDate"   , v-attr-value                    , 0 ).
        run wp-xmltagput( 3, "contractDateXml", bge-xml-str-date( v-attr-value ), 0 ).
        { str/tdat-val.i
            p-doc-code
            {&trdcattr-ndog}
            v-attr-value
            v-attr-type
            no-error
        }
        if error-status :error
        then do:
            run wp-XMLWriteLog in this-procedure (
                  input sLogFile
                , input 1
                , substitute( "*** ERR: *** Ошибка чтения атрибута номера договора для приходной накладной N &1 ", p-doc-code )
            ).
        end.
        run wp-xmltagput( 3, "contractNo",     v-attr-value, 0 ).
        { str/tdat-val.i
            p-doc-code
            {&trdcattr-nsf}
            v-attr-value
            v-attr-type
        }
        run wp-xmltagput( 3, "sfNo",     v-attr-value, 0 ).
        { str/tdat-val.i
            p-doc-code
            {&trdcattr-dsf}
            v-attr-value
            v-attr-type
        }
        run wp-xmltagput( 3, "sfDate"   , v-attr-value                    , 0 ).
        run wp-xmltagput( 3, "sfDateXml", bge-xml-str-date( v-attr-value ), 0 ).

    end.      /* p-ext-doc-type <> {&TDEDT_Overturn} */
    run wp-xmltagput( input 3, input "reasonCode"   , input string( p-reason-code )                      , input 1 ).
    run wp-xmltagput( input 3, input "outCode"      , input p-out-code                                   , input 0 ).
    run wp-xmltagput( input 3, input "comment"      , input p-doc-PS                                     , input 0 ).

    find first buf_ord-chain no-lock
      where buf_ord-chain.rel-doc-code =  p-doc-code
        and buf_ord-chain.rel-doc-type = 'trn':u
    no-error .
    if available buf_ord-chain
    then do:
      find first buf_ord-doc-rcv no-lock
        where buf_ord-doc-rcv.rcv-code = buf_ord-chain.doc-code
      no-error .
      if available buf_ord-doc-rcv
      then do:
        run wp-xmltagput( input 3, input "ordDocCode"     ,  input string( buf_ord-doc-rcv.doc-code  ), input 1 ).
        run wp-xmltagput( input 3, input "ordOutDocCode"  ,  input string( buf_ord-doc-rcv.cons-code ), input 0 ).
      end.
    end.
    run wp-xmltagput( input 3, input "dCard"   ,  input p-d-card , input 0 ).
    /* списание техпролив */
    def var v-value as character no-undo.
    def var v-type  as character no-undo.
    def var v-tech-pass as logical no-undo.
    { str/tdat-val.i                                    
      p-doc-code
      {&trdcattr-techpass}
      v-value 
      v-type 
      no-error
    }
    assign
      v-tech-pass = yes when v-value = "yes".
    if p-ext-doc-type = {&TDEDT_Spi_Vnesh} and
        (can-find(first ub.sale-doc where ub.sale-doc.doc-code = p-doc-code and ub.sale-doc.doc-kind = {&sale-add-tech-refuell}) or v-tech-pass)
    then do:
      run safe-wp-xmltagput in this-procedure ( input 3, input "techfuel":U  , input "yes":u, input 1 ).
    end. /* if p-ext-doc-type = {&TDEDT_Spi_Vnesh} */

    /* приход техпролив */
    if p-ext-doc-type = {&TDEDT_Pri_Vnesh} and
        (can-find(first ub.sale-doc where ub.sale-doc.doc-code = p-doc-code and ub.sale-doc.doc-kind = {&sale-add2-in-tech-refuell}) or v-tech-pass)
    then do:
      run safe-wp-xmltagput in this-procedure ( input 3, input "techfuel":U  , input "yes":u, input 1 ).
    end. /* if p-ext-doc-type = {&TDEDT_Pri_Vnesh} */
    if p-ext-doc-type = {&TDEDT_Pri_Vnesh}
    then do:
      { str/tdat-val.i
        p-doc-code
        {&trdcattr-is-lgas-corr}
        v-attr-value
        v-attr-type
        no-error
      }
      if not error-status:error and v-attr-value = "yes" then do:
        run wp-xmltagput( input 3, input "lgascorr"  ,  input "yes", input 0 ).
      end.
    end.
end.
end procedure. /* write-doc-header */


/*==========================================================================*/
procedure export-part :
define input parameter p-gds-code           as integer          no-undo.
define input parameter p-parts-rowid        as rowid            no-undo.

define input parameter  p-is-envd           as logical          no-undo.
define variable v-PartsAlcAttrBottingDate like parts.alc-bottling-date no-undo.
define variable v-PartsAlcAttrAlcType like ub.alc-type.alc-type-code no-undo.
define variable v-PartsAlcAttrAlcCode as char no-undo.
define variable v-PartsAlcAttrRefA like parts.alc-ref-ab-path no-undo.
define variable v-PartsAlcAttrRefB like parts.alc-ref-ab-path no-undo.
define variable v-PartsAlcAttrProd as char no-undo.
define variable v-PartsAlcAttrQu like parts.alc-quality-certif-path no-undo.
define variable v-PartsAlcAttrCertifPath like parts.alc-certif-path no-undo.
define variable v-PartsAlcAttrImpCode like parts.alc-imp-code no-undo.
define variable v-PartsAlcAttrImpType like parts.alc-imp-type no-undo.
DEFINE VARIABLE v-par-val             AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-par-type            AS CHARACTER NO-UNDO.

define variable v-prod as character no-undo.
define variable v-value-character     as character     no-undo .
define variable v-value-decimal       as decimal       no-undo .
define variable v-value-integer       as integer       no-undo .
define variable v-value-logical       as logical       no-undo .
define variable v-value-type          as character     no-undo .
define variable v-value-date          as date          no-undo .
define variable v-ext-sys             as integer       no-undo .
define variable v-inn as character no-undo.
define variable v-kpp as character no-undo.
define variable v-naim as character no-undo.

    define variable v-fact-qnty             as decimal      no-undo.
    define variable v-sum-base              as decimal      no-undo.
    define variable v-sum-rubl              as decimal      no-undo.
    define variable v-vat-base              as decimal      no-undo.
    define variable v-vat-rubl              as decimal      no-undo.
    define variable v-slt-base              as decimal      no-undo.
    define variable v-slt-rubl              as decimal      no-undo.
    define variable v-road-tax-base         as decimal      no-undo.
    define variable v-road-tax-rubl         as decimal      no-undo.
    define variable v-excise-base           as decimal      no-undo.
    define variable v-excise-rubl           as decimal      no-undo.
    define variable v-transport-base        as decimal      no-undo.
    define variable v-transport-rubl        as decimal      no-undo.
    define variable v-other-base            as decimal      no-undo.
    define variable v-other-rubl            as decimal      no-undo.

    define variable v-supp-dog-code         as character    no-undo.
    define variable v-supp-ndog             as character    no-undo.
    define variable v-supp-ddog             as character    no-undo.
    define variable v-parts-host-code       as integer      no-undo.
    define variable v-parts-contract-code   as integer      no-undo.
    define variable v-country-code          as character    no-undo.

    define variable v-parts-price-cli       as decimal       no-undo.
    define variable v-parts-cli-base-rate   as decimal       no-undo.
    define variable v-parts-vat-type        as character     no-undo.
    define variable v-parts-exch-code       as integer       no-undo.
    define variable v-parts-attr-exch-rate  as decimal       no-undo.
    define variable v-parts-attr-exch-scale as integer       no-undo.
    define variable v-parts-attr-unit-cli   as character     no-undo.

define buffer  X_ext-classif-attr for ext-classif-attr.
define buffer buf_ext-classif for ub.ext-classif.
define buffer buf_alc-type-gds    for ub.alc-type-gds .
define buffer buf_alc-type        for ub.alc-type .


    define buffer buf_contract      for ub.contract.
    define buffer buf_parts         for ub.parts.
    define buffer buf_goods         for ub.goods.
    define buffer buf_parts-attr    for ub.parts-attr.
do
for buf_contract
  , buf_parts
  , buf_parts-attr
on error undo, return error
:
        find first buf_parts no-lock
             where rowid( buf_parts ) = p-parts-rowid
        .
        assign
            v-supp-dog-code  = "":U
            v-supp-ndog      = "":U
            v-supp-ddog      = "":U
        .
        { str/in-vatp.i calc-parts buf_parts. " " loc}
        ASSIGN
/*                                v-vat-pc              = vat-pc-loc*/
/*                                v-slt-pc              = slt-pc-loc*/
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
                    where buf_contract.host-code       = v-host-code
                    and buf_contract.contract-code   = buf_parts.contract-code
            no-error.
            if available buf_contract
            then do:
                assign
                    v-supp-ndog          = string( buf_contract.contract-prn-code )
                    v-supp-ddog          = string( buf_contract.contract-date, "99.99.9999" )
                .
            end.
        end.
        find first buf_goods no-lock
                where buf_goods.gds-code = p-gds-code
        no-error.
        if available buf_goods
        then do:
            
            
            RUN gds-attr-value(
                ub.buf_goods.gds-code,
                {&attr-alcohol-prod},
                OUTPUT v-par-val,
                OUTPUT v-par-type
                ).
            IF v-par-val <> "" AND
                v-par-val <> "no" THEN
            DO: /* 1 */
            assign                           
                            v-PartsAlcAttrRefA        = "":U
                            v-PartsAlcAttrRefB        = "":U
                            v-PartsAlcAttrAlcCode     = "":U 
                            v-PartsAlcAttrAlcType     = "":U 
                            v-PartsAlcAttrQu          = "":U
                            v-PartsAlcAttrCertifPath  = "":U
                            v-PartsAlcAttrImpCode     = 0
                            v-PartsAlcAttrImpType     = "":U 
                            v-prod = "":U
                            v-inn = "":U
                            v-kpp = "":U
                            v-naim = "":U 
                            v-PartsAlcAttrProd =  "":U
                            .
            
                          run adm/shattri.p (
                            input "get":U
                            ,input '':U
                            ,input 0
                            ,input {&attr-egais-host}
                            ,input {&attr-egais-host_egais-exsys}
                            ,output v-value-character
                            ,output v-value-date
                            ,output v-value-decimal
                            ,output v-value-integer
                            ,output v-value-logical
                            ,output v-value-type
                            ,input-output TABLE thbjattr_thbj-attr
                            ) no-error .
                        assign 
                            v-ext-sys = v-value-integer . 
                            
                            
                    
               assign
                            v-PartsAlcAttrBottingDate = buf_parts.alc-bottling-date
                            v-PartsAlcAttrRefA        = entry(1,buf_parts.alc-ref-ab-path, ",")
                            v-PartsAlcAttrRefB        = entry(2,buf_parts.alc-ref-ab-path,",")    
                            when num-entries (buf_parts.alc-ref-ab-path) > 1
                            v-PartsAlcAttrAlcCode     = entry(3,buf_parts.alc-ref-ab-path,",")    
                            when num-entries (buf_parts.alc-ref-ab-path) > 2
                            v-PartsAlcAttrAlcType     = entry(4,buf_parts.alc-ref-ab-path,",")    
                            when num-entries (buf_parts.alc-ref-ab-path) > 3
                            v-PartsAlcAttrQu          = buf_parts.alc-quality-certif-path
                            v-PartsAlcAttrCertifPath  = buf_parts.alc-certif-path
                            v-PartsAlcAttrImpCode     = buf_parts.alc-imp-code
                            v-PartsAlcAttrImpType     = buf_parts.alc-imp-type
                            .
                             if not v-PartsAlcAttrAlcType > '' then  for first buf_alc-type-gds where buf_alc-type-gds.gds-code = ub.buf_goods.gds-code no-lock,
                                      first buf_alc-type where buf_alc-type.alc-type-inner-code = buf_alc-type-gds.alc-type-inner-code no-lock:
                                       v-PartsAlcAttrAlcType =  buf_alc-type.alc-type-code.     
                                   end.
           
           
                      find first buf_ext-classif no-lock where buf_ext-classif.classif-subject = {&table_goods}
                            and buf_ext-classif.classif-name = {&extclass_goods_esys}
                            and buf_ext-classif.db-num = 0
                            and buf_ext-classif.key#_one = buf_goods.gds-code
                            and buf_ext-classif.key#_two = v-ext-sys
                            no-error.

                        if available buf_ext-classif then 
                        do: 
                            
                            v-prod = entry (1, buf_ext-classif.CharKey_Two, chr(4)).
                            v-inn = entry(4, v-prod, chr(5)) + "/" no-error.
                            v-kpp = entry(2, v-prod, chr(5)) + "/" no-error.
                            v-naim =   entry(3, v-prod, chr(5)) no-error. 
                            v-PartsAlcAttrProd =    v-naim   + v-inn    + v-kpp .
                        end.  
                    end.
           
                    
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
/*                                        p-fact-date = buf_parts-attr.fact-date*/
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
/*                                    v-parts-VAt-pc = parts.vat-pc*/
/*                                    v-parts-SLT-pc = parts.SLT-pc*/
/*                                    v-purch-code = buf_parts.purch-code*/
/*                                    p-fact-date = ?*/
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
        end.        /* if available buf_goods */
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
        end.        /* NOT ( if available buf_goods ) */
        run wp-xmltagopen in this-procedure ( input 5, input "part", input "" ).
        run wp-xmltagput in this-procedure ( input 6, input "doc_ID"            , input string( v-in-code               ), input 2 ).
        run wp-xmltagput in this-procedure ( input 6, input "qnty"              , input string( v-fact-qnty             ), input 2 ).
        run wp-xmltagput in this-procedure ( input 6, input "cst"               , input string( v-cst-code              ), input 2 ).
        run wp-xmltagput in this-procedure ( input 6, input "supp"              , input string( v-supp-type + string( v-supp-code ) ), input 2 ).
        run wp-xmltagput in this-procedure ( input 6, input "hostCode"          , input string( v-parts-host-code       ), input 2 ).
        run wp-xmltagput in this-procedure ( input 6, input "contractCode"      , input string( v-parts-contract-code   ), input 2 ).
        run wp-xmltagput in this-procedure ( input 6, input "sumr"                , input string( v-sum-rubl              ), input 1 ).

        if p-is-envd eq NO then
          run wp-xmltagput in this-procedure ( input 6, input "VATr"                , input string( v-vat-rubl         ), input 2 ).
        else 
          run wp-xmltagput in this-procedure ( input 6, input "VATr"                , input string(((price-rubl-with-tax-loc / (100 + buf_parts.VAT-pc )) * buf_parts.VAT-pc)  * buf_parts.fact-qnty ), input 2 ).
        
        run wp-xmltagput in this-procedure ( input 6, input "SLTr"              , input string( v-slt-rubl              ), input 2 ).
        run wp-xmltagput in this-procedure ( input 6, input "roadTaxr"          , input string( v-road-tax-rubl         ), input 2 ).
        run wp-xmltagput in this-procedure ( input 6, input "transportr"        , input string( v-transport-rubl        ), input 2 ).
        run wp-xmltagput in this-procedure ( input 6, input "otherr"            , input string( v-other-rubl            ), input 2 ).
        run wp-xmltagput in this-procedure ( input 6, input "exciser"           , input string( v-excise-rubl           ), input 2 ).
        run wp-xmltagput in this-procedure ( input 6, input "sumb"              , input string( v-sum-base              ), input 2 ).
        run wp-xmltagput in this-procedure ( input 6, input "VATb"              , input string( v-vat-base              ), input 2 ).
        run wp-xmltagput in this-procedure ( input 6, input "SLTb"              , input string( v-slt-base              ), input 2 ).
        run wp-xmltagput in this-procedure ( input 6, input "roadTaxb"          , input string( v-road-tax-base         ), input 2 ).
        run wp-xmltagput in this-procedure ( input 6, input "transportb"        , input string( v-transport-base        ), input 2 ).
        run wp-xmltagput in this-procedure ( input 6, input "otherb"            , input string( v-other-base            ), input 2 ).
        run wp-xmltagput in this-procedure ( input 6, input "exciseb"           , input string( v-excise-base           ), input 2 ).
        run wp-xmltagput in this-procedure ( input 6, input "contractSuppCode"  , input v-supp-dog-code                  , input 0 ).
        run wp-xmltagput in this-procedure ( input 6, input "contractSuppNo"    , input v-supp-ndog                      , input 0 ).
        run wp-xmltagput in this-procedure ( input 6, input "contractSuppDate"  , input v-supp-ddog                      , input 0 ).
        run wp-xmltagput in this-procedure ( input 6, input "contractSuppDateXml" , input bge-xml-str-date(v-supp-ddog)    , input 0 ).
        run wp-xmltagput in this-procedure ( input 6, input "countryCode"       , input string( v-country-code          ), input 2 ).
        run wp-xmltagput in this-procedure ( input 6, input "priceCli":U        , input string( v-parts-price-cli       ), input 2 ).
        run wp-xmltagput in this-procedure ( input 6, input "cliBaseRate":U     , input string( v-parts-cli-base-rate   ), input 2 ).
        run wp-xmltagput in this-procedure ( input 6, input "vatType":U         , input string( v-parts-vat-type        ), input 0 ).
        run wp-xmltagput in this-procedure ( input 6, input "exchCode":U        , input string( v-parts-exch-code       ), input 2 ).
        run wp-xmltagput in this-procedure ( input 6, input "attrExchRate":U    , input string( v-parts-attr-exch-rate  ), input 2 ).
        run wp-xmltagput in this-procedure ( input 6, input "attrExchScale":U   , input string( v-parts-attr-exch-scale ), input 2 ).
        run wp-xmltagput in this-procedure ( input 6, input "attrUnitCli":U     , input string( v-parts-attr-unit-cli   ), input 0 ).


    IF v-par-val <> "" AND
        v-par-val <> "no" THEN
    DO: /* 1 */
        run wp-xmltagopen in this-procedure ( input 6, input "PartsAlcAttr":U, input "" ).
        run wp-xmltagput in this-procedure ( input 7, input "PartsAlcAttrBottingDate":U              , input string( v-PartsAlcAttrBottingDate               ), input 2 ).
        run wp-xmltagput in this-procedure ( input 7, input "PartsAlcAttrAlcType":U              , input string( v-PartsAlcAttrAlcType               ), input 2 ).
        run wp-xmltagput in this-procedure ( input 7, input "PartsAlcAttrAlcCode":U              , input string( v-PartsAlcAttrAlcCode               ), input 2 ).
        run wp-xmltagput in this-procedure ( input 7, input "PartsAlcAttrRefA":U              , input string( v-PartsAlcAttrRefA             ), input 2 ).
        run wp-xmltagput in this-procedure ( input 7, input "PartsAlcAttrRefB":U              , input string( v-PartsAlcAttrRefB              ), input 2 ).
        run wp-xmltagput in this-procedure ( input 7, input "PartsAlcAttrProd":U              , input string( v-PartsAlcAttrProd              ), input 2 ).
        run wp-xmltagput in this-procedure ( input 7, input "PartsAlcAttrQualityCertify":U              , input string( v-PartsAlcAttrQu               ), input 2 ).
        run wp-xmltagput in this-procedure ( input 7, input "PartsAlcAttrCertifPath":U              , input string( v-PartsAlcAttrCertifPath               ), input 2 ).
        run wp-xmltagput in this-procedure ( input 7, input "PartsAlcAttrImpCode":U              , input string( v-PartsAlcAttrImpCode               ), input 2 ).
        run wp-xmltagput in this-procedure ( input 7, input "PartsAlcAttrImpType":U              , input string( v-PartsAlcAttrImpType               ), input 2 ).
        
        run wp-xmltagclose in this-procedure ( input 6, input "PartsAlcAttr":U ).
                   
    end.
    run wp-xmltagclose in this-procedure ( input 5, input "part":U ).
end.
end procedure. /* export-part */

/*==========================================================================*/
procedure fill_bge-xml_goods :
define input parameter p-parent-handle  as handle           no-undo.
define input parameter p-gds-code       as integer          no-undo.

do
on error undo, return error
:
    if p-parent-handle :get-signature( "cb-fill_bge-xml_goods" ) <> "":U
    then do:
        run cb-fill_bge-xml_goods in p-parent-handle (
            input p-gds-code
        ).
    end.
end.
end procedure. /* fill_bge-xml_goods */


/*==========================================================================*/
procedure fill_bge-xml_clients :
define input parameter p-parent-handle  as handle           no-undo.
define input parameter p-obj-type       as character        no-undo.
define input parameter p-obj-code       as integer          no-undo.

do
on error undo, return error
:
    if p-parent-handle :get-signature( "cb-fill_bge-xml_clients" ) <> "":U
    then do:
        run cb-fill_bge-xml_clients in p-parent-handle (
              input p-obj-type
            , input p-obj-code
        ).
    end.
end.
end procedure. /* fill_bge-xml_goods */


/*==========================================================================*/
procedure fill_bge-xml_dis-card :
define input parameter p-parent-handle  as handle           no-undo.
define input parameter p-d-card         as character        no-undo.

do
on error undo, return error
:
    if p-parent-handle :get-signature( "cb-fill_bge-xml_dis-card" ) <> "":U
    then do:
        run cb-fill_bge-xml_dis-card in p-parent-handle (
            input p-d-card
        ).
    end.
end.
end procedure. /* fill_bge-xml_goods */

/*==========================================================================*/
procedure export-chk-pay-code :
define input parameter p-ext-doc-type       as character        no-undo.
define input parameter p-doc-line-recid     as recid            no-undo.
define input parameter p-out-code           as character        no-undo.
define input parameter p-pay-desk           as logical          no-undo.
define input parameter p-is-petrol          as logical          no-undo.
define input parameter p-is-pieces          as logical          no-undo.

    define variable v-cash-pay-not-specified      as logical      no-undo.
do
on error undo, return error
:
    run get-cash-pay in this-procedure (
          input p-ext-doc-type
        , input p-doc-line-recid
        , input p-out-code
        , output v-cash-pay-not-specified
    ).
    if v-cash-pay-not-specified = no
    then do:
        if p-pay-desk = yes
        then do:
            run wp-xmltagopen( 4, "goodPayDesk", "" ).
            if p-is-petrol = yes
            and p-is-pieces = no
            then do:        /*топливо - таблица treal-2*/
                for each treal-2
                    where treal-2.gds-code = buf_goods.gds-code
                break by treal-2.pay-desk
                        by treal-2.cpay-code
                        by treal-2.curr-code
                        by treal-2.prefix
                on error undo, return error
                :
                    if first-of( treal-2.pay-desk )
                    then do:
                        run wp-xmltagopen( 5, "payDesk", "" ).
                        run wp-xmltagput( 6, "code", string( treal-2.pay-desk ), 0 ).
                    end.
                    if first-of(treal-2.curr-code) then do:
                        assign
                        v-found-paycode = no
                        v-found-paycard = no
                        .
                    end.
                    if treal-2.is-pay = no then do:
                    end.
                    else do:
                      if treal-2.prefix = '':U then do:
                          /*суммирующая запись по всем префиксам*/
                          v-found-paycode = yes.
                          run wp-xmltagopen( 6, "payCode", "" ).
                          run wp-xmltagput( 7, "code", string( treal-2.cpay-code ), 0 ).
                          run wp-xmltagput( 7, "quantity", string( v-is-out * treal-2.qnty1 ), 3 ).
                          run wp-xmltagput( 7, "sumr", string( v-is-out * treal-2.netto ), 2 ).
                      end.
                      if treal-2.prefix <> '':U then do:
                          /*сюда попадем только если p-pay-desk-cards = yes и уже была запись с prefix = '':U*/
                          if not v-found-paycard then do:
                          /*на первом префиксе открывающий тэг payCards для все префиксов*/
                          run wp-xmltagopen( 7, "payCards", "" ).
                          v-found-paycard = yes.
                          end.
                          run wp-xmltagopen( 8, "payCard", "" ).
                          run wp-xmltagput( 9, "num", string( treal-2.prefix ), 0 ).
                          run wp-xmltagput( 9, "quantity", string( v-is-out * treal-2.qnty1 ), 3 ).
                          run wp-xmltagput( 9, "sumr", string( v-is-out * treal-2.netto ), 2 ).
                          run wp-xmltagclose( 8, "payCard").
                      end.
                      if last-of(treal-2.curr-code) then do:
                          if v-found-paycard then do:
                          run wp-xmltagclose( 7, "payCards" ).
                          end.
                          if v-found-paycode then do:
                          run wp-xmltagclose( 6, "payCode" ).
                          end.
                      end.
                    end.
                    if last-of( treal-2.pay-desk )
                    then do:
                        run wp-xmltagclose( 5, "payDesk" ).
                    end.
                end.
            end.        /* топливо */
            else do:
                case buf_goods.gds-type:
                    when {&gds-goods}
                    then do:        /*товары таблица treal-3*/
                        for each treal-3 no-lock
                            where treal-3.gds-code = buf_goods.gds-code
                        break by treal-3.pay-desk
                                by treal-3.cpay-code
                                by treal-3.curr-code
                                by treal-3.prefix
                        on error undo, return error
                        :
                            if first-of( treal-3.pay-desk )
                            then do:
                                run wp-xmltagopen( 5, "payDesk", "" ).
                                run wp-xmltagput( 6, "code", string( treal-3.pay-desk ), 0 ).
                            end.
                            if first-of( treal-3.curr-code) then do:
                                assign
                                v-found-paycode = no
                                v-found-paycard = no
                                .
                            end.
                            if treal-3.is-pay = no then do:
                            end.
                            else do:
                              if treal-3.prefix = '':U then do:
                                  /*суммирующая запись по всем префиксам*/
                                  v-found-paycode = yes.
                                  run wp-xmltagopen( 6, "payCode", "" ).
                                  run wp-xmltagput( 7, "code", string( treal-3.cpay-code ), 0 ).
                                  run wp-xmltagput( 7, "quantity", string( v-is-out * treal-3.qnty1 ), 3 ).
                                  run wp-xmltagput( 7, "sumr", string( v-is-out * treal-3.netto ), 2 ).
                              end.
                              if treal-3.prefix <> '':U then do:
                                  /*сюда попадем только если p-pay-desk-cards = yes и уже была запись с prefix = '':U*/
                                  if not v-found-paycard then do:
                                  /*на первом префиксе открывающий тэг payCards для все префиксов*/
                                  run wp-xmltagopen( 7, "payCards", "" ).
                                  v-found-paycard = yes.
                                  end.
                                  run wp-xmltagopen( 8, "payCard", "" ).
                                  run wp-xmltagput( 9, "num", string( treal-3.prefix ), 0 ).
                                  run wp-xmltagput( 9, "quantity", string( v-is-out * treal-3.qnty1 ), 3 ).
                                  run wp-xmltagput( 9, "sumr", string( v-is-out * treal-3.netto ), 2 ).
                                  run wp-xmltagclose( 8, "payCard").
                              end.
                              if last-of( treal-3.curr-code ) then do:
                                  if v-found-paycard then do:
                                  run wp-xmltagclose( 7, "payCards" ).
                                  end.
                                  if v-found-paycode then do:
                                  run wp-xmltagclose( 6, "payCode" ).
                                  end.
                              end.
                            end.
                            if last-of( treal-3.pay-desk )
                            then do:
                                run wp-xmltagclose( 5, "payDesk" ).
                            end.
                        end.
                    end.
                    when {&gds-office}
                    then do:        /*услуги таблица  treal-4*/
                        for each treal-4 no-lock
                            where treal-4.gds-code = buf_goods.gds-code
                        break by treal-4.pay-desk
                                by treal-4.cpay-code
                                by treal-4.curr-code
                                by treal-4.prefix
                        on error undo, return error
                        :
                            if first-of( treal-4.pay-desk )
                            then do:
                                run wp-xmltagopen( 5, "payDesk", "" ).
                                run wp-xmltagput( 6, "code", string( treal-4.pay-desk ), 0 ).
                            end.
                            if first-of( treal-4.curr-code )
                            then do:
                                assign
                                v-found-paycode = no
                                v-found-paycard = no
                                .
                            end.
                            if treal-4.is-pay = no then do:
                            end.
                            else do:
                              if treal-4.prefix = '':U then do:
                                  /*суммирующая запись по всем префиксам*/
                                  v-found-paycode = yes.
                                  run wp-xmltagopen( 6, "payCode","" ).
                                  run wp-xmltagput( 7, "code", string( treal-4.cpay-code ), 0 ).
                                  run wp-xmltagput( 7, "quantity", string( v-is-out * treal-4.qnty1 ), 3 ).
                                  run wp-xmltagput( 7, "sumr", string( v-is-out * treal-4.netto ), 2 ).
                              end.
                              if treal-4.prefix <> '':U then do:
                              /*сюда попадем только если p-pay-desk-cards = yes и уже была запись с prefix = '':U*/
                                  if not v-found-paycard then do:
                                  /*на первом префиксе открывающий тэг payCards для все префиксов*/
                                  run wp-xmltagopen( 7, "payCards", "" ).
                                  v-found-paycard = yes.
                                  end.
                                  run wp-xmltagopen( 8, "payCard", "" ).
                                  run wp-xmltagput( 9, "num", string( treal-4.prefix ), 0 ).
                                  run wp-xmltagput( 9, "quantity", string( v-is-out * treal-4.qnty1 ), 3 ).
                                  run wp-xmltagput( 9, "sumr", string( v-is-out * treal-4.netto ), 2 ).
                                  run wp-xmltagclose( 8, "payCard" ).
                              end.
                              if last-of( treal-4.curr-code ) then do:
                                  if v-found-paycard then do:
                                  run wp-xmltagclose( 7, "payCards" ).
                                  end.
                                  if v-found-paycode then do:
                                  run wp-xmltagclose( 6, "payCode" ).
                                  end.
                              end.
                            end.
                            if last-of( treal-4.pay-desk )
                            then do:
                                run wp-xmltagclose( 5, "payDesk" ).
                            end.
                        end.
                    end.
                end case.       /*case goods.gds-type*/
            end.        /* не топливо */
            run wp-xmltagclose( 4, "goodPayDesk" ).
        end.        /* if p-pay-desk = yes */
        else do:
            run wp-xmltagopen( 4, "goodPayCode", "" ).
            if p-is-petrol = yes
            and p-is-pieces = no
            then do:        /*топливо - таблица treal-2*/
                for each treal-2 No-LOCK
                where treal-2.gds-code = buf_goods.gds-code
                break by treal-2.pay-desk
                        by treal-2.cpay-code
                        by treal-2.curr-code
                        by treal-2.prefix
                on error undo, return error
                :
                    if first-of( treal-2.curr-code ) then do:
                        assign
                        v-found-paycode = no
                        v-found-paycard = no
                        .
                    end.
                    if treal-2.is-pay = no then do:
                    end.
                    else do:
                      if treal-2.prefix = '':U then do:
                          /*суммирующая запись по всем префиксам*/
                          v-found-paycode = yes.
                          run wp-xmltagopen( 5, "payCode", "" ).
                          run wp-xmltagput( 6, "code", string( treal-2.cpay-code ), 0 ).
                          run wp-xmltagput( 6, "quantity", string( v-is-out * treal-2.qnty1 ), 3 ).
                          run wp-xmltagput( 6, "sumr", string( v-is-out * treal-2.netto ), 2 ).
                      end.
                      if treal-2.prefix <> '':U then do:
                          /*сюда попадем только если p-pay-desk-cards = yes и уже была запись с prefix = '':U*/
                          if not v-found-paycard then do:
                          /*на первом префиксе открывающий тэг payCards для все префиксов*/
                          run wp-xmltagopen( 6, "payCards", "" ).
                          v-found-paycard = yes.
                          end.
                          run wp-xmltagopen( 7, "payCard", "" ).
                          run wp-xmltagput( 8, "num", string( treal-2.prefix ), 0 ).
                          run wp-xmltagput( 8, "quantity", string( v-is-out * treal-2.qnty1 ), 3 ).
                          run wp-xmltagput( 8, "sumr", string( v-is-out * treal-2.netto ), 2 ).
                          run wp-xmltagclose( 7, "payCard" ).
                      end.
                      if last-of( treal-2.curr-code) then do:
                          if v-found-paycard then do:
                          run wp-xmltagclose( 6, "payCards" ).
                          end.
                          if v-found-paycode then do:
                          run wp-xmltagclose( 5, "payCode" ).
                          end.
                      end.
                   end.
                end.
            end.        /* топливо */
            else do:
                case buf_goods.gds-type:
                    when {&gds-goods}
                    then do:        /*товары таблица treal-3*/
                        for each treal-3 no-lock
                        where treal-3.gds-code = buf_goods.gds-code
                        break by treal-3.pay-desk
                                by treal-3.cpay-code
                                by treal-3.curr-code
                                by treal-3.prefix
                        on error undo, return error
                        :
                            if first-of( treal-3.curr-code ) then do:
                                assign
                                v-found-paycode = no
                                v-found-paycard = no
                                .
                            end.
                            if treal-3.is-pay = no then do:
                            end.
                            else do:
                              if treal-3.prefix = '':U then do:
                                  /*суммирующая запись по всем префиксам*/
                                  v-found-paycode = yes.
                                  run wp-xmltagopen( 5, "payCode", "" ).
                                  run wp-xmltagput( 6, "code", string( treal-3.cpay-code ), 0 ).
                                  run wp-xmltagput( 6, "quantity", string( v-is-out * treal-3.qnty1 ), 3 ).
                                  run wp-xmltagput( 6, "sumr", string( v-is-out * treal-3.netto ), 2 ).
                              end.
                              if treal-3.prefix <> '':U then do:
                                  if not v-found-paycard then do:
                                  run wp-xmltagopen( 6, "payCards", "" ).
                                  v-found-paycard = yes.
                                  end.
                                  run wp-xmltagopen( 7, "payCard", "" ).
                                  run wp-xmltagput( 8, "code", string( treal-3.prefix ), 0 ).
                                  run wp-xmltagput( 8, "quantity", string( v-is-out * treal-3.qnty1 ), 3 ).
                                  run wp-xmltagput( 8, "sumr", string( v-is-out * treal-3.netto ), 2 ).
                                  run wp-xmltagclose( 7, "payCard" ).
                              end.
                              if last-of(treal-3.curr-code) then do:
                                  if v-found-paycard then do:
                                  run wp-xmltagclose( 6, "payCards" ).
                                  end.
                                  if v-found-paycode then do:
                                  run wp-xmltagclose( 5, "payCode" ).
                                  end.
                              end.
                            end.
                        end.
                    end.
                    when {&gds-office}
                    then do:        /*услуги таблица  treal-4*/
                        for each treal-4 no-lock
                        where treal-4.gds-code = buf_goods.gds-code
                        break by treal-4.pay-desk
                                by treal-4.cpay-code
                                by treal-4.curr-code
                                by treal-4.prefix
                        on error undo, return error
                        :
                            if first-of (treal-4.curr-code) then do:
                                assign
                                v-found-paycode = no
                                v-found-paycard = no
                                .
                            end.
                            if treal-4.is-pay = no then do:
                            end.
                            else do:
                              if treal-4.prefix = '':U then do:
                                  /*суммирующая запись по всем префиксам*/
                                  v-found-paycode = yes.
                                  run wp-xmltagopen( 5, "payCode","" ).
                                  run wp-xmltagput( 6, "code", string( treal-4.cpay-code ), 0 ).
                                  run wp-xmltagput( 6, "quantity", string( v-is-out * treal-4.qnty1 ), 3 ).
                                  run wp-xmltagput( 6, "sumr", string( v-is-out * treal-4.netto ), 2 ).
                              end.
                              if treal-4.prefix <> '':U then do:
                                  if not v-found-paycard then do:
                                  run wp-xmltagopen( 6, "payCards", "" ).
                                  v-found-paycard = yes.
                                  end.
                                  run wp-xmltagopen( 7, "payCard","" ).
                                  run wp-xmltagput( 8, "num", string( treal-4.prefix ), 0 ).
                                  run wp-xmltagput( 8, "quantity", string( v-is-out * treal-4.qnty1 ), 3 ).
                                  run wp-xmltagput( 8, "sumr", string( v-is-out * treal-4.netto ), 2 ).
                                  run wp-xmltagclose( 7, "payCard" ).
                              end.
                              if last-of( treal-4.curr-code ) then do:
                                  if v-found-paycard then do:
                                  run wp-xmltagclose( 6, "payCards" ).
                                  end.
                                  if v-found-paycode then do:
                                  run wp-xmltagclose( 5, "payCode" ).
                                  end.
                              end.
                           end.
                        end.
                    end.
                end case.       /*case goods.gds-type*/
            end.        /* не топливо */
            run wp-xmltagclose( 4, "goodPayCode" ).
        end.        /* NOT ( if p-pay-desk = yes ) */
    end.
end.
end procedure. /* export-chk-pay-code */

/*==========================================================================*/
procedure get-base-code-okv :
define input parameter p-base-code          as integer          no-undo.
define output parameter p-base-code-okv     as integer          no-undo.

    define buffer buf_currency      for ub.currency.
do
for buf_currency
on error undo, return error
:
    find first buf_currency no-lock
         where buf_currency.curr-code = p-base-code
    .
    assign
        p-base-code-okv = buf_currency.okv-code
    .
end.
end procedure. /* get-valutCode */


/*==========================================================================*/
procedure export-bc-price :
  define input  parameter p-obj-type  as character no-undo .
  define input  parameter p-obj-code  as integer   no-undo .
  define input  parameter p-doc-code  as character no-undo .
  define input  parameter p-b-code    as integer   no-undo .

  define buffer base-bar-code             for ub.bar-code.
  define buffer buf_bar-code              for ub.bar-code.
  define buffer buf_units                 for ub.units.
  define buffer buf_price-list            for ub.price-list.

  define variable v-doc-num     as character          no-undo .
  define variable v-price-sale  as decimal            no-undo .
  define variable v-road-tax    as decimal            no-undo .
  define variable v-excise      as decimal            no-undo .


do for base-bar-code
     , buf_bar-code
     , buf_units
     , buf_price-list
on error undo, return error return-value
:
  find base-bar-code no-lock
    where base-bar-code.b-code = p-b-code
  no-error .
  if not available base-bar-code
  then do:
    return . /* --->>>--- */
  end.
  bc-cycle:
  for each buf_price-list no-lock
    where  buf_price-list.doc-num     = p-doc-code
      and  buf_price-list.price-type  = ''
    , each buf_bar-code no-lock
    where buf_bar-code.b-code    = buf_price-list.b-code
      and buf_bar-code.gds-code  = base-bar-code.gds-code
      and buf_bar-code.node-code = base-bar-code.node-code
      and buf_bar-code.part-code = base-bar-code.part-code
      and buf_bar-code.in-code   = base-bar-code.in-code
  :
    assign
      v-price-sale = buf_price-list.price-sale
    .
    run wp-xmltagopen in this-procedure ( input 4, input "bcPrice", input "" ).
    run wp-xmltagput( 5, "bCode"      , string( buf_bar-code.b-code         ), 0 ).
    run wp-xmltagput( 5, "unitCli"    , string( buf_bar-code.unit-cli       ), 0 ).
    run wp-xmltagput( 5, "cliBaseRate", string( buf_bar-code.cli-base-rate  ), 0 ).
    run wp-xmltagput( 5, "priceSale"  , string( v-price-sale                ), 0 ).
    run wp-xmltagclose in this-procedure ( input 4, input "bcPrice" ).
  end. /* bc-cycle: */
end.
end procedure. /* export-bc-price */
/*==========================================================================*/
procedure calc-lines :
do
on error undo, return error
:
  define input parameter  p-doc-code      as character        no-undo.
  define output parameter p-sum-all-parts as decimal          no-undo.
                                                            
  DEFINE BUFFER t-doc FOR trn-doc.  
  define variable p-fact-qnty             as decimal          no-undo.
                                     
  find first t-doc no-lock
       where t-doc.doc-code   = p-doc-code
       no-error.
  if avail t-doc then         
       ASSIGN 
       p-sum-all-parts = vat-rubl .         
        
end .         
end procedure.


