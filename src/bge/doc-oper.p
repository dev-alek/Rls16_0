block-level on error undo, throw.
/*

$Revision: a61e6bb0c7e0, 2871, rls $
$Author: SSlivenko $
$Date: Пн ноя 22 19:49:10 2021 +0300 $
$Workfile: doc-oper.p $
$Archive: bge/doc-oper.p $

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
    p-need-doc-rvs      - надо ли выгружать сверки до/после слива по топливным приходным накладным
    sOutFile            - имя файла .xm1 для вывода (вызывающая программа создает и по завершении
                            экспорта переименовывает этот файл в .xml. Сделано для синхронизации с
                            блоком импорта во внешней бухгалтерии.
    v-bge-xml-log-file-name            - полное имя файла для записи событий.
    p-parent-handle     - handle вызывающей процедуры
    hEDT                - handle поля лога (EDITOR) окна вывода
    hCNT                - handle поля счётчика (FILL-IN) окна вывода
*/

define input parameter p-host-code       as character               no-undo.
define input parameter p-obj-type        as character               no-undo.
define input parameter p-obj-code        as integer                 no-undo.
define input parameter p-ext-doc-type    as character               no-undo.
define input parameter p-oper-name       as character               no-undo.
define input parameter p-fact-order-from like ub.stk-tot.fact-order    no-undo.
define input parameter p-fact-order-to   like ub.stk-tot.fact-order    no-undo.
define input parameter p-date-from       as date                    no-undo.
define input parameter p-date-to         as date                    no-undo.
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
define input parameter p-parent-handle   as handle                  no-undo.
define input parameter hEDT              as handle                  no-undo.
define input parameter hCNT              as handle                  no-undo.

define variable vss-revision    as character no-undo init "$Revision: a61e6bb0c7e0, 2871, rls $":U .
define variable vss-author      as character no-undo init "$Author: SSlivenko $":U .
define variable vss-date        as character no-undo init "$Date: Пн ноя 22 19:49:10 2021 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: doc-oper.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/doc-oper.p $":U .
define variable vss-description as character no-undo init "Экспорт документов по архивам".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ bge/bge-xml.i  }
{ str/lib-trn.i  }
{ str/trdcalib.i }
{ str/in-vatp.i def  }
{ str/out-vatp.i def }
{ str/clcprtsl.i     }
{ trg/factord.i  }
{ ref/gds-attr.i }
{ gbl/thbjattr.i }
{ cmp/str-glbl.i }
{ ref/extclass.i }
{ adm/auto-def.i    }

&scoped-define version-string "15.0 " + replace( vss-revision + vss-date, "$", " " )

/*v-PartsAlcAttrBottingDate (1-1) - Дата разлива алкогольной продукции                                              */
/*v-PartsAlcAttrAlcType (1-1) - Код вида алкогольной продукции                                                      */
/*v-PartsAlcAttrAlcCode (1-1) - Код товара в ЕГАИС                                                                  */
/*v-PartsAlcAttrRefA (1-1) - Справка А                                                                              */
/*v-PartsAlcAttrRefB (1-1) - Справка Б                                                                              */
/*v-PartsAlcAttrProd (1-1) - Наименование\ИНН\КПП производителя. Эта информация берется из внешнего классификатора!!*/
/*v-PartsAlcAttrQu ()alityCertify (1-1) - Путь к файлу удостоверения качества для алкогольной продукции             */
/*v-PartsAlcAttrCertifPath (1-1) - Путь к файлу сертификата соответствия для алкогольной продукции                  */
/*v-PartsAlcAttrImpCode (1-1) - Код импортера                                                                       */
/*v-PartsAlcAttrImpType (1-1) - Тип импортера                                                                       */

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

define variable v-qnty            like ub.ot-tot.fact-qnty  no-undo.
define variable v-pay-code        like ub.trn-doc.fact-date no-undo.
define variable v-parts-cst-code  like ub.parts.cst-code    no-undo.
define variable v-exists-operation          as logical      no-undo.
define variable v-exists-sale_ot-supp-tot   as logical      no-undo.
define variable v-is-petrol                 as logical      no-undo.
define variable v-is-pieces                 as logical      no-undo.
define variable v-is-alco                 as logical      no-undo.
define variable v-petrol-weight             as decimal      no-undo.
define variable v-weight-not-specified      as logical      no-undo.
define variable v-cash-pay-not-specified    as logical      no-undo.
define variable v-host-code                 as integer      no-undo.
define variable v-base-code                 as integer      no-undo.
define variable v-base-code-okv             as integer      no-undo.
define variable v-is-out                    as integer      no-undo.

define variable v-country-code  as character        no-undo.
define variable v-supp-type     as character        no-undo.
define variable v-supp-code     as integer          no-undo.
define variable v-in-code       as character        no-undo.
define variable v-cst-code      as character        no-undo.
define variable v-curr-r-b      as character        no-undo.

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



/*define temp-table temp_PlDoc no-undo  */
/*        field fact-qnty as decimal    */
/*        field cli-fact-qnty as decimal*/
/*        field pl-code   as integer    */
/*                                      */
/*                                      */
/*        index pi is primary unique    */
/*            pl-code.                  */
       
       
        
            
            
            
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

define buffer  X_ext-classif-attr for ub.ext-classif-attr.
define buffer buf_ext-classif     for ub.ext-classif.
define buffer buf_alc-type-gds    for ub.alc-type-gds .
define buffer buf_alc-type        for ub.alc-type .

define temp-table tt-ot-line no-undo like ub.ot-line.

/*определение таблиц необходимых для разбивки чеков по платежам*/
{ ref/cp-attr.i }
{ rep/cpapcep.i  "NEW SHARED" }
{ rep/cpapcep.i  "proc" }
{ rep/real-2df.i "NEW SHARED" treal-2 bge }
{ rep/realg3df.i "NEW SHARED" treal-3 bge }
{ rep/real-4df.i "NEW SHARED" treal-4 bge }


do
on error undo, return error return-value
:
ASSIGN
  v-exists-operation        = no
  v-bge-xml-log-file-name   = sLogFile
.
{ gbl/hostcode.i p-obj-type p-obj-code v-host-code }
{ gbl/basecode.i v-host-code v-base-code }
run get-base-code-okv in this-procedure (
      input v-base-code
    , output v-base-code-okv
).
run cpapcep in this-procedure .

RUN wp-XMLWriteCNT( hCNT, "" ).

{ gbl/curr-r-b.i
    v-curr-r-b
}
run bge-xml-read-config in this-procedure ( input ?
                                          , input ?
                                          ).
if v-bge-xml-bgefmt <> "dbf":U
then do:
  if v-bge-xml-bgeflold <> "oracle":u
  then do:
    OUTPUT STREAM stmXMLOut TO VALUE( sOutFile + "xm1" ) CONVERT TARGET "1251" APPEND.
  end.
end.
run export-documents in this-procedure .
if v-bge-xml-bgefmt <> "dbf":U
then do:
  if v-bge-xml-bgeflold <> "oracle":u
  then do:
    output stream stmxmlout close.
  end.
end.

end.

/*==========================================================================*/
procedure export-documents :
do
on error undo, return error
:
/*                                                                           */
/*                   define variable   v-shift-date  as character    no-undo.*/
/*                   define variable   v-shift-num   as character    no-undo.*/

    define variable v-doc-code              as character    no-undo.
    define variable v-obj-type              as character    no-undo.
    define variable v-obj-code              as integer      no-undo.
    define variable v-fact-order            as decimal      no-undo.
    define variable v-crsa-sum-type         as character    no-undo.
    define variable v-sale-sum-type         as character    no-undo.
    define variable v-cost-sum-type         as character    no-undo.
    define variable v-doc-exists            as logical      no-undo.
    define variable v-trn-doc-out-code      as character    no-undo.
    define variable v-trn-doc-office        as logical      no-undo.
    define variable v-ot-tot-sale-exists    as logical      no-undo.
    define variable v-ot-tot-cost-exists    as logical      no-undo.
    define variable v-ot-tot-crsa-exists    as logical      no-undo.
    define variable v-exists-before         as logical      no-undo.
    define variable v-exists-after          as logical      no-undo.
    define variable v-exp-ora-filename      as character    no-undo.
    define variable v-date-from             as date         no-undo.
    define variable v-date-to               as date         no-undo.
    define variable v-obj-list              as character    no-undo.
    define variable v-ora-exp-seq-num       as integer      no-undo.

    define buffer buf_ot-tot-crsa-loop     for ub.ot-tot.
    define buffer buf_ot-line-crsa-loop    for ub.ot-line.
    define buffer buf_cost_ot-supp-line    for ub.ot-supp-line.
    define buffer buf_sale_ot-supp-line    for ub.ot-supp-line.
    define buffer buf_cost_ot-supp-tot     for ub.ot-supp-tot.
    define buffer buf_sale_ot-supp-tot     for ub.ot-supp-tot.
    define variable v-is-envd_              as logical      no-undo.   
    define variable vartype                 as character    no-undo.
    define variable varenvd                 as character    no-undo. 
    define variable v-sum-all-parts         as decimal      no-undo.
    define variable v-pr-doc-type           as logical      no-undo.           

    assign
      v-obj-list = substitute( "&1,&2" , p-obj-type , p-obj-code )
    .

    if  p-ext-doc-type = {&TDEDT_Pri_Vnesh} 
        /* or p-ext-doc-type = {&TDEDT_Ras_Vnesh_VP}     возврат поставщику*/ 
        then assign v-pr-doc-type = YES .                                                            

    export-documents-arch:
    for each buf_ot-tot-crsa-loop no-lock
       where buf_ot-tot-crsa-loop.obj-type     = p-obj-type
         and buf_ot-tot-crsa-loop.obj-code     = p-obj-code
         and buf_ot-tot-crsa-loop.ext-doc-type = p-ext-doc-type
         and buf_ot-tot-crsa-loop.fact-order   > p-fact-order-from
         and buf_ot-tot-crsa-loop.fact-order  <= p-fact-order-to
         and buf_ot-tot-crsa-loop.sum-type     = {&arh-crsa}
         and buf_ot-tot-crsa-loop.cat-id       = {&root-cat-id}
    on error undo, return error
    :
         { str/tdat-val.i                                    
         buf_ot-tot-crsa-loop.doc-code
         {&trdcattr-envd}
         varenvd 
         vartype } 
            
        if    varenvd eq "YES"                                                          
          and v-pr-doc-type eq YES
          then                
          v-is-envd_ = YES .  
        else  v-is-envd_ = NO .                                                 
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
            v-doc-code              = buf_ot-tot-crsa-loop.doc-code
            v-obj-type              = buf_ot-tot-crsa-loop.obj-type
            v-obj-code              = buf_ot-tot-crsa-loop.obj-code
            v-fact-order            = buf_ot-tot-crsa-loop.fact-order
            v-ot-tot-sale-exists    = no
            v-ot-tot-cost-exists    = no
            v-ot-tot-crsa-exists    = no
        .
        assign v-sum-all-parts = 0 .
        if v-is-envd_ = YES 
          then                                                                         
          run calc-lines in this-procedure (
                    input  v-doc-code
                  , output v-sum-all-parts
          ) no-error. 
        if not v-exists-operation
        then do:
            run wp-XMLWriteEDT( hEDT, 8, "Операция " + string( p-oper-name ) ).
            run wp-XMLWriteLog( v-bge-xml-log-file-name, 0, "&Line" ).
            run wp-XMLWriteLog( v-bge-xml-log-file-name, 1, "XML - Вывод операции " + string( p-oper-name ) + " (" + p-ext-doc-type + ")" ).
            assign
                v-exists-operation = yes
            .
        end.

        run wp-XMLWriteLog in this-procedure ( input v-bge-xml-log-file-name
                                             , input 1
                                             , input substitute( "Выгрузка документа &1 в пакет &2"
                                                               , v-doc-code
                                                               , sOutFile
                                                               )
                                             ).

        if v-bge-xml-bgefmt <> "dbf":U
        then do:
            output stream stmxmlout close.
            if v-bge-xml-bgeflold = "oracle":u
            then do:
              run bge-xml-ora-exp-filename in this-procedure ( input ?
                                                             , input ?
                                                             , input p-obj-code
                                                             , output v-exp-ora-filename
                                                             , output v-ora-exp-seq-num
                                                             ) no-error .
              if error-status :error = yes
              then do:
                run wp-XMLWriteLog in this-procedure ( input sLogFile
                                                     , input 1
                                                     , input substitute( "Ошибка экспорта документа из архива. Номер документа: &1. &2. &3 &4 "
                                                                       , v-doc-code
                                                                       , return-value
                                                                       , trim(error-status :get-message(1))
                                                                       , trim(error-status :get-message(2))
                                                                       )
                                                     ).
                undo export-documents-arch, next export-documents-arch.
              end.
            run bge-xml-write-header in this-procedure (
                    input v-exp-ora-filename
                  , input v-exp-ora-filename + "xml"
                  , input {&version-string}
                  , input 0
                  , input p-date-from
                  , input 0
                  , input p-date-to
                  , input 0
                  , input v-obj-list
                  , input p-ext-doc-type
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
            end.
            else do:
              OUTPUT STREAM stmXMLOut TO VALUE( sOutFile + "xm1" ) CONVERT TARGET "1251" APPEND.
            end.
        end.

        run export-header in this-procedure (
                  input v-doc-code
                , input v-obj-type
                , input v-obj-code
                , input v-fact-order
                , input p-ext-doc-type
                , output v-doc-exists
                , output v-trn-doc-out-code
                , output v-trn-doc-office

        ) no-error.
            if error-status :error = yes
              then do:
                run wp-XMLWriteLog in this-procedure ( input sLogFile
                                                     , input 1
                                                     , input substitute( "Ошибка экспорта документа в шапке документа. Номер документа: &1. &2. &3 &4 "
                                                                       , v-doc-code
                                                                       , return-value
                                                                       , trim(error-status :get-message(1))
                                                                       , trim(error-status :get-message(2))
                                                                       )
        ).
                undo export-documents-arch, next export-documents-arch.
              end.
        case p-ext-doc-type
        :
            when {&TDEDT_Overturn}
            then do:
                if v-doc-exists
                and v-trn-doc-office = no
                then do:
                    run export-price-doc-ot-tot in this-procedure (
                          input v-doc-code
                        , input {&arh-crsa}
                        , input buf_ot-tot-crsa-loop.cat-id
                    ).
                    assign
                        v-ot-tot-crsa-exists = yes
                    .
                end.
            end.
            otherwise do:
                if  v-doc-exists = yes
                and p-pay-code = yes
                or ( p-chk-pay-code = yes
                and ( p-ext-doc-type = {&TDEDT_Ras_Vnesh_Kass} or p-ext-doc-type = {&TDEDT_Vozvrat_Vnesh_Kass} ) )
                then do:
                    run export-pay-code in this-procedure (
                          input v-doc-code
                        , input p-ext-doc-type
                        , input v-trn-doc-out-code
                        , input p-pay-desk
                        , input p-pay-desk-cards
                        , output v-is-out
                    ).
                end.
                if v-doc-exists = yes
                then do:
                    if v-trn-doc-office = no
                    then do:
                        run export-trn-doc-ot-tot in this-procedure (
                              input v-doc-code
                            , input {&arh-sale}
                            , input buf_ot-tot-crsa-loop.cat-id
                            , input buf_ot-tot-crsa-loop.fact-qnty
                            , input p-ext-doc-type
                            , input p-pay-code
                            , input-output v-ot-tot-sale-exists
                            , input-output v-ot-tot-cost-exists
                            , input-output v-ot-tot-crsa-exists
                            , input v-is-envd_
                            , input v-sum-all-parts
                        ).
                        run export-trn-doc-ot-tot in this-procedure (
                              input v-doc-code
                            , input {&arh-cost}
                            , input buf_ot-tot-crsa-loop.cat-id
                            , input buf_ot-tot-crsa-loop.fact-qnty
                            , input p-ext-doc-type
                            , input p-pay-code
                            , input-output v-ot-tot-sale-exists
                            , input-output v-ot-tot-cost-exists
                            , input-output v-ot-tot-crsa-exists
                            , input v-is-envd_
                            , input v-sum-all-parts
                        ).
                        run export-trn-doc-ot-tot in this-procedure (
                              input v-doc-code
                            , input {&arh-crsa}
                            , input buf_ot-tot-crsa-loop.cat-id
                            , input buf_ot-tot-crsa-loop.fact-qnty
                            , input p-ext-doc-type
                            , input p-pay-code
                            , input-output v-ot-tot-sale-exists
                            , input-output v-ot-tot-cost-exists
                            , input-output v-ot-tot-crsa-exists
                            , input v-is-envd_
                            , input v-sum-all-parts
                        ).
                    end.        /* if v-trn-doc-office = no */
                    else do:
                        run export-trn-doc-ot-tot in this-procedure (
                              input v-doc-code
                            , input {&arh-sale-service}
                            , input buf_ot-tot-crsa-loop.cat-id
                            , input buf_ot-tot-crsa-loop.fact-qnty
                            , input p-ext-doc-type
                            , input p-pay-code
                            , input-output v-ot-tot-sale-exists
                            , input-output v-ot-tot-cost-exists
                            , input-output v-ot-tot-crsa-exists
                            , input v-is-envd_
                            , input v-sum-all-parts
                        ).
                        run export-trn-doc-ot-tot in this-procedure (
                              input v-doc-code
                            , input {&arh-cost-service}
                            , input buf_ot-tot-crsa-loop.cat-id
                            , input buf_ot-tot-crsa-loop.fact-qnty
                            , input p-ext-doc-type
                            , input p-pay-code
                            , input-output v-ot-tot-sale-exists
                            , input-output v-ot-tot-cost-exists
                            , input-output v-ot-tot-crsa-exists
                            , input v-is-envd_
                            , input v-sum-all-parts
                        ).
                        run export-trn-doc-ot-tot in this-procedure (
                              input v-doc-code
                            , input {&arh-crsa-service}
                            , input buf_ot-tot-crsa-loop.cat-id
                            , input buf_ot-tot-crsa-loop.fact-qnty
                            , input p-ext-doc-type
                            , input p-pay-code
                            , input-output v-ot-tot-sale-exists
                            , input-output v-ot-tot-cost-exists
                            , input-output v-ot-tot-crsa-exists
                            , input v-is-envd_
                            , input v-sum-all-parts
                        ).
                    end.        /* NOT ( if v-trn-doc-office = no ) */
                end.        /* if v-doc-exists = yes */
                else do:    /* Если не удалось определить тип документа - с услугами или товарами - выгружаются строки по товарам */
                    run export-trn-doc-ot-tot in this-procedure (
                          input v-doc-code
                        , input {&arh-sale}
                        , input buf_ot-tot-crsa-loop.cat-id
                        , input buf_ot-tot-crsa-loop.fact-qnty
                        , input p-ext-doc-type
                        , input p-pay-code
                        , input-output v-ot-tot-sale-exists
                        , input-output v-ot-tot-cost-exists
                        , input-output v-ot-tot-crsa-exists
                        , input v-is-envd_
                        , input v-sum-all-parts
                    ).
                    run export-trn-doc-ot-tot in this-procedure (
                          input v-doc-code
                        , input {&arh-cost}
                        , input buf_ot-tot-crsa-loop.cat-id
                        , input buf_ot-tot-crsa-loop.fact-qnty
                        , input p-ext-doc-type
                        , input p-pay-code
                        , input-output v-ot-tot-sale-exists
                        , input-output v-ot-tot-cost-exists
                        , input-output v-ot-tot-crsa-exists
                        , input v-is-envd_
                        , input v-sum-all-parts
                    ).
                    run export-trn-doc-ot-tot in this-procedure (
                          input v-doc-code
                        , input {&arh-crsa}
                        , input buf_ot-tot-crsa-loop.cat-id
                        , input buf_ot-tot-crsa-loop.fact-qnty
                        , input p-ext-doc-type
                        , input p-pay-code
                        , input-output v-ot-tot-sale-exists
                        , input-output v-ot-tot-cost-exists
                        , input-output v-ot-tot-crsa-exists
                        , input v-is-envd_
                        , input v-sum-all-parts
                    ).
                end.        /* NOT ( if v-doc-exists = yes ) */
            end.
        end case.
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
                run wp-XMLWriteLog(
                      input v-bge-xml-log-file-name
                    , input 1
                    , input substitute( "*** WRN: *** Не удалось проверить документ инвентаризации N: &1. &2. &3. &4"
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
            run wp-xmltagopen( 3, "paySum", "" ).
            for each temp_cost_cat-id_ot-supp-tot
            on error undo, return error
            :
                run wp-xmltagopen( 4,  string( temp_cost_cat-id_ot-supp-tot.cat-id ), "" ).
                for each temp_cost_cli_ot-supp-tot
                where temp_cost_cli_ot-supp-tot.cat-id = temp_cost_cat-id_ot-supp-tot.cat-id
                on error undo, return error
                :
                    run fill_bge-xml_clients in this-procedure (
                          input p-parent-handle
                        , input temp_cost_cli_ot-supp-tot.cli-type
                        , input temp_cost_cli_ot-supp-tot.cli-code
                    ).
                    if v-bge-xml-bgefmt = "dbf":U
                    then do:
                        run set-dbf-out-file-name in this-procedure (
                              input substitute( "hspc_&1":U, temp_cost_cli_ot-supp-tot.cat-id )
                            , input v-doc-code
                        ).
                    end.
                    run wp-xmltagopen( 5, "firm", "" ).
                    run wp-xmltagput( 6, "type", string( temp_cost_cli_ot-supp-tot.cli-type ), 2 ).
                    run wp-xmltagput( 6, "code", string( temp_cost_cli_ot-supp-tot.cli-code ), 2 ).
                    run wp-xmltagopen( 6, "cost", "" ).
                    if temp_cost_cli_ot-supp-tot.sum-rubl < 0
                    then do:
                        run wp-xmltagput( 8, "sign", "-1", 0 ).
                    end.
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
                         where buf_sale_ot-supp-tot.doc-code = v-doc-code
                           and buf_sale_ot-supp-tot.cli-type = temp_cost_cli_ot-supp-tot.cli-type
                           and buf_sale_ot-supp-tot.cli-code = temp_cost_cli_ot-supp-tot.cli-code
                           and buf_sale_ot-supp-tot.sum-type = {&arh-sale}
                           and buf_sale_ot-supp-tot.cat-id   = {&single-cat-id}
                    no-error.
                    if available buf_sale_ot-supp-tot
                    then do:
                        if v-bge-xml-bgefmt = "dbf":U
                        then do:
                            run set-dbf-out-file-name in this-procedure (
                                  input substitute( "hsps_&1":U, temp_cost_cli_ot-supp-tot.cat-id )
                                , input v-doc-code
                            ).
                        end.
                        run wp-xmltagopen( 6, "sale" , "" ).
                        if buf_sale_ot-supp-tot.sum-rubl < 0
                        then do:
                            run wp-xmltagput( 8, "sign", "-1", 0 ).
                        end.
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
                    end.        /* available buf_sale_ot-supp-tot */
                    run wp-xmltagclose( 5, "firm" ).
                end.        /* for each temp_cost_cli_ot-supp-tot */
                run wp-xmltagclose( 4,  string( temp_cost_cat-id_ot-supp-tot.cat-id ) ).
            end.      /* for each temp_cost_cat-id_ot-supp-tot */
            run wp-xmltagclose( 3,  "paySum" ).
        end.        /* if p-pay-code = yes */
        def var f as log no-undo.
        def var l as log no-undo.
        for each buf_ot-line-crsa-loop no-lock
          where buf_ot-line-crsa-loop.doc-code = v-doc-code
          and buf_ot-line-crsa-loop.sum-type = {&arh-crsa}
          break
          by buf_ot-line-crsa-loop.artic
          by buf_ot-line-crsa-loop.prod-type
          by buf_ot-line-crsa-loop.prod-code
          
        on error undo, return error
        :                          
          assign
          f = first-of (buf_ot-line-crsa-loop.artic) or first-of (buf_ot-line-crsa-loop.prod-type) or first-of (buf_ot-line-crsa-loop.prod-code)
          l = last-of (buf_ot-line-crsa-loop.artic) or last-of (buf_ot-line-crsa-loop.prod-type) or last-of (buf_ot-line-crsa-loop.prod-code).
            if f
            then do:
              create tt-ot-line.
              buffer-copy buf_ot-line-crsa-loop except buf_ot-line-crsa-loop.cat-id
                  to tt-ot-line.
            end.
            if (l and not f) or (not l and not f)
            then do:
              assign
                tt-ot-line.sum-base         =	tt-ot-line.sum-base        +	buf_ot-line-crsa-loop.sum-base      
                tt-ot-line.sum-rubl         =	tt-ot-line.sum-rubl        +	buf_ot-line-crsa-loop.sum-rubl      
                tt-ot-line.VAT-base         =	tt-ot-line.VAT-base        +	buf_ot-line-crsa-loop.VAT-base      
                tt-ot-line.VAT-rubl         =	tt-ot-line.VAT-rubl        +	buf_ot-line-crsa-loop.VAT-rubl      
                tt-ot-line.SLT-base         =	tt-ot-line.SLT-base        +	buf_ot-line-crsa-loop.SLT-base      
                tt-ot-line.SLT-rubl         =	tt-ot-line.SLT-rubl        +	buf_ot-line-crsa-loop.SLT-rubl      
                tt-ot-line.road-tax-base    =	tt-ot-line.road-tax-base   +	buf_ot-line-crsa-loop.road-tax-base 
                tt-ot-line.road-tax-rubl    =	tt-ot-line.road-tax-rubl   +	buf_ot-line-crsa-loop.road-tax-rubl 
                tt-ot-line.transport-base   =	tt-ot-line.transport-base  +	buf_ot-line-crsa-loop.transport-base
                tt-ot-line.transport-rubl   =	tt-ot-line.transport-rubl  +	buf_ot-line-crsa-loop.transport-rubl
                tt-ot-line.other-base       =	tt-ot-line.other-base      +	buf_ot-line-crsa-loop.other-base    
                tt-ot-line.other-rubl       =	tt-ot-line.other-rubl      +	buf_ot-line-crsa-loop.other-rubl    
                tt-ot-line.excise-base      =	tt-ot-line.excise-base     +	buf_ot-line-crsa-loop.excise-base   
                tt-ot-line.excise-rubl      =	tt-ot-line.excise-rubl     +	buf_ot-line-crsa-loop.excise-rubl   
                tt-ot-line.fact-qnty        =	tt-ot-line.fact-qnty       +	buf_ot-line-crsa-loop.fact-qnty     
                .
            end.
            if l
            then do:
              run export-document-lines in this-procedure (
                    input recid( tt-ot-line )
                  , input v-exists-before
                  , input v-exists-after
                  , input v-doc-code
                  , input v-ot-tot-sale-exists
                  , input v-ot-tot-cost-exists
                  , input v-ot-tot-crsa-exists
                  , input v-trn-doc-out-code 
                  , input v-is-envd_
              ).
              empty temp-table tt-ot-line.
            end.
        end.        /* for each buf_ot-line-crsa-loop no-lock */
        for each buf_ot-line-crsa-loop no-lock
           where buf_ot-line-crsa-loop.doc-code = v-doc-code
             and buf_ot-line-crsa-loop.sum-type = {&arh-crsa-service}
        on error undo, return error
        :
            create tt-ot-line.
            buffer-copy buf_ot-line-crsa-loop
                to tt-ot-line.
            run export-document-lines in this-procedure (
                  input recid( tt-ot-line )
                , input v-exists-before
                , input v-exists-after
                , input v-doc-code
                , input v-ot-tot-sale-exists
                , input v-ot-tot-cost-exists
                , input v-ot-tot-crsa-exists
                , input v-trn-doc-out-code
                , input v-is-envd_
            ).
            empty temp-table tt-ot-line.
        end.        /* for each buf_ot-line-crsa-loop no-lock */
        if p-need-chk = yes
        then do:
            if p-ext-doc-type = {&TDEDT_Ras_Vnesh_Kass}
            or p-ext-doc-type = {&TDEDT_Vozvrat_Vnesh_Kass}
            then do:
                run export-checks in this-procedure (
                      input p-ext-doc-type
                    , input v-doc-code
                    , input v-obj-type
                    , input v-obj-code
                ).
            end.
        end.        /* if p-need-checks = yes  */
        run wp-xmltagclose( 2, "operation" ).
        run wp-XMLWriteLog in this-procedure ( input v-bge-xml-log-file-name
                                             , input 1
                                             , input substitute( "Выгрузка документа &1 в пакет &2 завершена."
                                                               , v-doc-code
                                                               , sOutFile
                                                               )
                                             ).
        output stream stmxmlout close.
        if v-bge-xml-bgeflold = "oracle":u
        then do:
          run xml-bge-write-footer in this-procedure ( input v-exp-ora-filename ).
        end.
    end.        /* for each buf_ot-tot-crsa-loop */
end.
end procedure. /* export-documents */

/*==========================================================================*/
procedure export-document-lines :
do
on error undo, return error
:

/*define input parameter p-obj-type   as character        no-undo.*/
/*define input parameter p-obj-code   as integer          no-undo.*/
/*define input parameter p-shift-date as date             no-undo.*/
/*define input parameter p-shift-num  as integer          no-undo.*/


define input parameter p-ot-line-loop-recid     as recid            no-undo.
define input parameter p-exists-before          as logical          no-undo.
define input parameter p-exists-after           as logical          no-undo.
define input parameter p-doc-code               as character        no-undo.
define input parameter p-ot-tot-sale-exists     as logical          no-undo.
define input parameter p-ot-tot-cost-exists     as logical          no-undo.
define input parameter p-ot-tot-crsa-exists     as logical          no-undo.
define input parameter p-trn-doc-out-code       as character        no-undo.
define input parameter p-is-envd_               as logical          no-undo.

    define variable v-fact-qnty             as decimal      no-undo.
/*    define variable v-cli-fact-qnty             as decimal      no-undo.*/
    define variable v-doc-qnty              as decimal      no-undo.
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
    define variable v-parts-host-code       as integer      no-undo.
    define variable v-parts-contract-code   as integer      no-undo.
    define variable v-price-prev            as decimal      no-undo.

    define variable v-parts-price-cli       as decimal      no-undo.
    define variable v-parts-cli-base-rate   as decimal      no-undo.
    define variable v-parts-vat-type        as character    no-undo.
    define variable v-parts-exch-code       as integer      no-undo.
    define variable v-parts-attr-exch-rate  as decimal      no-undo.
    define variable v-parts-attr-exch-scale as integer      no-undo.
    define variable v-parts-attr-unit-cli   as character    no-undo.

    define variable v-scale-is-empty        as logical      no-undo.
    define variable v-supp-dog-code         as character    no-undo.
    define variable v-supp-ndog             as character    no-undo.
    define variable v-supp-ddog             as character    no-undo.
    define variable v-found-paycode         as logical      no-undo.
    define variable v-found-paycard         as logical      no-undo.
    define variable v-petrol-density        as decimal      no-undo.

    define buffer buf_doc-line              for ub.doc-line.
    
    define buffer buf_doc-pl                for ub.doc-pl .
    define buffer buf_parts                 for ub.parts.
    define buffer buf_parts-attr            for ub.parts-attr.
    define buffer buf_sale_ot-supp-line     for ub.ot-supp-line.
    define buffer buf_contract              for ub.contract.
    define buffer buf_goods                 for ub.goods.
    define buffer buf_clients               for ub.clients.
    define buffer buf_price-list            for ub.price-list.
    define buffer buf_units                 for ub.units.
    define buffer buf_doc-line-attr         for ub.doc-line-attr.

/*    define buffer buf_temp_PlDoc             for temp_PlDoc.*/
  define variable ii                   as integer no-undo.
    define variable v-attrcode           as char no-undo.
    define variable v-SectionName        as char no-undo.
    define variable v-DocQnty            as decimal no-undo.
    define variable v-CliQnty            as decimal no-undo .
    define variable v-FactQnty           as decimal no-undo.
    define variable v-DocDensity         as decimal no-undo.
    define variable v-FactDensity        as decimal no-undo.
    define variable v-TankVol            as decimal no-undo.
    define variable v-TankDensity        as decimal no-undo.
    define variable v-TankDensityPomi    as decimal no-undo.
    define variable v-TankVolPomi        as decimal no-undo.  
    define variable v-tank-vol           as decimal no-undo .
    define variable v-tank-density       as decimal no-undo .
    define variable v-SectionNum         as integer no-undo.
    define variable v-total-tank-density as decimal no-undo.
    define variable v-tankweight         as decimal no-undo.
    define variable v-sum-line           as decimal no-undo .
        
    define buffer buf_ot-line-crsa-loop     for tt-ot-line.
    define buffer buf_parts-root            for parts-root.

    
    find first buf_ot-line-crsa-loop no-lock
         where recid( buf_ot-line-crsa-loop ) = p-ot-line-loop-recid
    .
    if v-bge-xml-bgefmt = "dbf":U
    then do:
        run set-dbf-out-file-name in this-procedure (
              input substitute( "lhdr&1_":U, buf_ot-line-crsa-loop.artic )
            , input p-doc-code
        ).
    end.
    run wp-xmltagopen( 3, "linedoc", "" ).
    
   
    
    
    find first buf_goods no-lock
         where buf_goods.artic      = buf_ot-line-crsa-loop.artic
           and buf_goods.prod-type  = buf_ot-line-crsa-loop.prod-type
           and buf_goods.prod-code  = buf_ot-line-crsa-loop.prod-code
    no-error.
    if available buf_goods
    then do:
        run wp-xmltagput( 4, "good",      string( buf_goods.gds-code ), 0 ).
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
        run wp-xmltagput( 4, "artic",     string( buf_goods.artic    ), 0 ).
        run wp-xmltagput( 4, "prodtype",  string( buf_goods.prod-type), 0 ).
        run wp-xmltagput( 4, "prodcode",  string( buf_goods.prod-code), 0 ).
        run wp-xmltagput( 4, "type",      string( buf_goods.gds-type ), 0 ).
        run fill_bge-xml_goods in this-procedure (
              input p-parent-handle
            , input buf_goods.gds-code
        ).
    end.      /* available buf_goods  */
    else do:
        run wp-xmltagput( 4, "good",      "", 0 ).
        run wp-xmltagput( 4, "artic",     "", 0 ).
        run wp-xmltagput( 4, "prodtype",  "", 0 ).
        run wp-xmltagput( 4, "prodcode",  "", 0 ).
        run wp-xmltagput( 4, "type",      "", 0 ).
    end.      /* NOT available buf_goods  */
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
          or p-ext-doc-type = {&TDEDT_Ras_Vnesh_VP} then do:
            if available buf_goods then do:
              run wp-xmltagput( 4, "deadline",  string( buf_goods.deadline ), 0 ).
            end.
            else do:
              run wp-xmltagput( 4, "deadline",  "", 0 ).
            end.
          end.
        end.
        
        
        
        find first buf_doc-line no-lock
              where buf_doc-line.doc-code   = p-doc-code
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
                run get-petrol-weight in this-procedure (
                      input p-ext-doc-type
                    , input recid( buf_doc-line )
                    , input p-trn-doc-out-code
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
                    run wp-xmltagput( 4, "petrolDensity",  trim(string( v-petrol-density , ">>>>>>>>>9.9999999999")), 0 ).
                    run wp-xmltagput( 4, "quantityDoc",   string( buf_doc-line.doc-qnty            ), 0 ).
                    run wp-xmltagput( 4, "petrolDensityDoc",    trim(string( buf_doc-line.doc-density , ">>>>>>>>>9.9999999999")), 0 ).

                  
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
                                v-tank-density = v-tank-density + decimal(doc-line-attr.attr-value) .
  
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
                            
                        run wp-xmltagput( 4, "petrolTankDensity",    trim(string(v-total-tank-density , ">>>>>>>>>9.9999999999")), 0 ).
                    end.
                end.
                if p-ext-doc-type = {&TDEDT_Inv}
                or p-ext-doc-type = {&TDEDT_Peresort}
                or p-ext-doc-type = {&TDEDT_Corr_Acc_Price}
                or p-ext-doc-type = {&TDEDT_Corr_Minus_Parts}
                then do:
                    define buffer buf_inv-line      for ub.inv-line.
                    find first buf_inv-line no-lock
                         where buf_inv-line.doc-code  = buf_doc-line.doc-code
                           and buf_inv-line.artic     = buf_doc-line.artic
                           and buf_inv-line.prod-type = buf_doc-line.prod-type
                           and buf_inv-line.prod-code = buf_doc-line.prod-code
                    no-error.
                    if available buf_inv-line
                    then do:
                        run wp-xmltagput( 4, "petrolInvFactStk",   string( buf_inv-line.after-cli-qnty ), 0 ).
                    end.
                end.
                define variable v-before-qnty      as decimal      no-undo.
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
                    run wp-XMLWriteLog in this-procedure (
                          input v-bge-xml-log-file-name
                        , input 1
                        , input substitute( "*** ERR *** Ошибка вычисления количеств до и после для топлива. Документ &1. Товар &2 &3 &4. &5. &6. &7. &8."
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
                    if p-ext-doc-type <> {&TDEDT_Inv}
                    and p-ext-doc-type <> {&TDEDT_Peresort}
                    and p-ext-doc-type <> {&TDEDT_Corr_Acc_Price}
                    and p-ext-doc-type <> {&TDEDT_Corr_Minus_Parts}
                    then do:
                        assign
                            v-diff-qnty     = ( buf_doc-line.doc-qnty - buf_doc-line.fact-qnty ) * v-diff-qnty / buf_doc-line.fact-qnty
                            v-abs-diff-qnty = absolute( v-diff-qnty )
                        .
                    end.
                    run wp-xmltagput in this-procedure ( input 4, input "petrolBeforeQnty":U  , input string( v-before-qnty     ), input 1 ).
                    run wp-xmltagput in this-procedure ( input 4, input "petrolAfterQnty":U   , input string( v-after-qnty      ), input 1 ).
                    run wp-xmltagput in this-procedure ( input 4, input "petrolDiffQnty":U    , input string( v-diff-qnty       ), input 1 ).
                    run wp-xmltagput in this-procedure ( input 4, input "petrolAbsDiffQnty":U , input string( v-abs-diff-qnty   ), input 1 ).
                end.
                
                define buffer buf_rvs-line      for ub.rvs-line .
                define buffer buf_rvs-doc       for ub.rvs-doc .
                  
                for each buf_doc-pl where buf_doc-pl.obj-type = buf_doc-line.obj-type
                                      and buf_doc-pl.obj-code = buf_doc-line.obj-code
                                      and buf_doc-pl.out-code = buf_doc-line.doc-code
                                      and buf_doc-pl.gds-code = buf_goods.gds-code
                                      :
                
                run wp-xmltagopen in this-procedure ( input 4, input "PLDoc", input "" ).
                run wp-xmltagput( 5, "PLCode",   string(buf_doc-pl.pl-code) , 0 ).
                run wp-xmltagput( 5, "PLQnty",  string(buf_doc-pl.fact-qnty) , 0 ).
                run wp-xmltagput( 5, "PLWeigth",  string(buf_doc-pl.cli-fact-qnty) , 0 ).
                run wp-xmltagput( 5, "PLDensity",  string((buf_doc-pl.cli-fact-qnty / buf_doc-pl.fact-qnty),"->>>>>>>>>9.9999999999") , 0 ).
                
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
            end.        /* if v-is-petrol  = yes */
            /*---END----------- Для топлива дополнительно экспортировать вес ---------------------*/
        end.      /* available buf_doc-line  */
        
        
        
        else do:
            run wp-XMLWriteLog(  v-bge-xml-log-file-name, 1, substitute( "*** ERR *** Не найдена строка документа &1. Товар &2 &3 &4."
                                                    , p-doc-code
                                                    , buf_ot-line-crsa-loop.artic
                                                    , buf_ot-line-crsa-loop.prod-type
                                                    , buf_ot-line-crsa-loop.prod-code
                                                    )
                              ).
        end.      /* NOT ( available buf_doc-line  ) */
        if available buf_goods
        then do:
            if v-is-petrol  = yes
            and v-is-pieces = no
            then do:
                if v-bge-xml-shift-mode = yes
                then do:
                    define variable v-attr-exists   as logical      no-undo.
                    if p-ext-doc-type = {&TDEDT_Pri_Vnesh}
                    then do:        /* В атрибутах строки документа прихода может быть определена нефтебаза поставки */
                        define variable v-ptbotype      as character    no-undo.
                        define variable v-ptbocode      as integer      no-undo.
                        run get-doc-line-attr-character in this-procedure (
                            input p-doc-code
                            , input buf_goods.gds-code
                            , input {&trdcattr-ptbobj}
                            , output v-ptbotype
                            , output v-attr-exists
                        ).
                        if v-attr-exists
                        then do:
                            run get-doc-line-attr-integer in this-procedure (
                                input p-doc-code
                                , input buf_goods.gds-code
                                , input {&trdcattr-ptbobj}
                                , output v-ptbocode
                                , output v-attr-exists
                            ).
                            if v-attr-exists
                            then do:
                                find first buf_clients no-lock
                                    where buf_clients.obj-type = v-ptbotype
                                    and buf_clients.obj-code = v-ptbocode
                                no-error.
                                if available buf_clients
                                then do:
                                    run wp-xmltagput( 4, "ptbObjType":U, string( buf_clients.obj-type ), 0 ).
                                    run wp-xmltagput( 4, "ptbObjCode":U, string( buf_clients.obj-code ), 0 ).
                                    run wp-xmltagput( 4, "ptbObjName":U, string( buf_clients.obj-name ), 0 ).
                                end.
                            end.
                        end.
                    end.        /* if p-ext-doc-type = {&TDEDT_Pri_Vnesh} */
                    define variable v-autoent-obj-type      as character    no-undo.
                    define variable v-autoent-obj-code      as integer      no-undo.
                    run get-doc-line-attr-character in this-procedure (
                        input p-doc-code
                        , input buf_goods.gds-code
                        , input {&trdcattr-autoent}
                        , output v-autoent-obj-type
                        , output v-attr-exists
                    ).
                    if v-attr-exists
                    then do:
                        run get-doc-line-attr-integer in this-procedure (
                            input p-doc-code
                            , input buf_goods.gds-code
                            , input {&trdcattr-autoent}
                            , output v-autoent-obj-code
                            , output v-attr-exists
                        ).
                        if v-attr-exists
                        then do:
                            find first buf_clients no-lock
                                where buf_clients.obj-type = v-autoent-obj-type
                                and buf_clients.obj-code = v-autoent-obj-code
                            no-error.
                            if available buf_clients
                            then do:
                                run wp-xmltagput( 4, "autoentObjType":U, string( buf_clients.obj-type ), 0 ).
                                run wp-xmltagput( 4, "autoentObjCode":U, string( buf_clients.obj-code ), 0 ).
                                run wp-xmltagput( 4, "autoentObjName":U, string( buf_clients.obj-name ), 0 ).
                            end.
                        end.
                    end.
                    define variable v-car-num      as character    no-undo.
                    run get-doc-line-attr-character in this-procedure (
                        input p-doc-code
                        , input buf_goods.gds-code
                        , input "car-num":U
                        , output v-car-num
                        , output v-attr-exists
                    ).
                    if v-attr-exists = yes
                    then do:
                        run wp-xmltagput( 4, "petrolCarNum":U, string( v-car-num ), 0 ).
                    end.
                end.        /* if v-bge-xml-shift-mode = yes */
            end.        /* if v-is-petrol  = yes */
            else do:        /* Для ТНП */

                if p-ext-doc-type = {&TDEDT_Pri_Vnesh}
                then do:        /* Недовозы ТНП */

                end.        /* if p-ext-doc-type = {&TDEDT_Pri_Vnesh} */
            end.        /* if v-is-petrol  = yes */
        end.        /* if available buf_goods */
    end.      /* p-ext-doc-type <> {&TDEDT_Overturn} */
    else do:
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
            run wp-xmltagput( 4, "priceListQnty", string( buf_price-list.doc-qnty ), 0 ).
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
    run wp-xmltagput( 4, "quantity" , string( v-qnty )      , 0 ).
    run wp-xmltagput( 4, "comment"  , string( buf_goods.ps ), 0 ).
    
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
                     
                run wp-xmltagopen in this-procedure ( input 4, input "Tank", input "" ).
                run wp-xmltagput( 5, "TankNum",   v-SectionName , 0 ).
                run wp-xmltagput( 5, "TankDocVol",  string(v-DocQnty  ) , 0 ).
                run wp-xmltagput( 5, "TankDocDensity",  trim(string(v-DocDensity , ">>>>>>>>>9.9999999999")) , 0 ).
                run wp-xmltagput( 5, "TankVol",  string(v-TankVol   ) , 0 ).
                run wp-xmltagput( 5, "TankDensity",  trim(string(v-TankDensity , ">>>>>>>>>9.9999999999")) , 0 ).
                run wp-xmltagput( 5, "TankFactVol",  string(v-FactQnty ) , 0 ).
                run wp-xmltagput( 5, "TankFactDensity",  trim(string(v-FactDensity , ">>>>>>>>>9.9999999999")) , 0 ).
                run wp-xmltagput( 5, "RdcDensity",  trim(string(v-TankDensityPomi , ">>>>>>>>>9.9999999999")) , 0 ).
                run wp-xmltagput( 5, "RdcVol",  string( v-TankVolPomi) , 0 ).
                run wp-xmltagclose in this-procedure ( input 4, input "Tank"  ).
                        
            end.
        end.
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
            run wp-xmltagopen in this-procedure ( input 4, input "dtlSum", input "" ).
            run export-gds-dtl in this-procedure (
                  input p-ext-doc-type
                , input p-doc-code
                , input buf_goods.artic
                , input buf_goods.prod-type
                , input buf_goods.prod-code
            ) no-error.
            if error-status :error
            then do:
                run wp-XMLWriteLog in this-procedure (
                      input v-bge-xml-log-file-name
                    , input 1
                    , input substitute( "*** ERR *** Ошибка выгрузки признаков" )
                ).
            end.
            run wp-xmltagclose in this-procedure ( input 4, input "dtlSum" ).
        end.

        assign
        v-sum-line = 0 .        
        
        if p-is-envd_ eq YES and 
           p-parts eq NO 
          then do: 
          
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
                    { str/in-vatp.i calc-parts buf_parts. " " loc}
                    assign
                    v-sum-line = v-sum-line + ((price-rubl-with-tax-loc / (100 + buf_doc-line.VAT-pc )) * buf_doc-line.VAT-pc)  * buf_parts.fact-qnty  .
            end.
        end.


        if p-cst = yes
        or p-parts = yes
        then do:        /* Надо экспортировать номера ГТД или партии */
            if p-parts = yes
            then do:
                run wp-xmltagopen in this-procedure ( input 4, input "partsSum", input "" ).
            end.        /* if p-parts = yes */
            assign
                v-parts-cst-code = "":U
                v-supp-dog-code  = "":U
                v-supp-ndog      = "":U
                v-supp-ddog      = "":U
            .
 

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
                    ASSIGN
/*                                v-vat-pc              = vat-pc-loc*/
/*                                v-slt-pc              = slt-pc-loc*/
                        v-fact-qnty           = buf_parts.fact-qnty
                        v-doc-qnty            = buf_parts.qnty
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
                end.        /* if p-parts = yes */
                if available buf_goods
                    then 
                do:
    
                    v-is-alco = no.
                    RUN gds-attr-value(
                        ub.buf_goods.gds-code,
                        {&attr-alcohol-prod},
                        OUTPUT v-par-val,
                        OUTPUT v-par-type
                        ).
                    IF v-par-val <> "" AND
                        v-par-val <> "no" THEN
                    DO: /* 1 */
                    v-is-alco = yes.
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
                            v-PartsAlcAttrProd =   v-naim   + v-inn  + v-kpp .
                        end.  
                    end.
                    
                    find first buf_parts-attr no-lock
                         where buf_parts-attr.in-code   = buf_parts.in-code
                           and buf_parts-attr.gds-code  = buf_goods.gds-code
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
/*                                    v-parts-VAt-pc = parts.vat-pc*/
/*                                    v-parts-SLT-pc = parts.SLT-pc*/
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
                if p-parts = yes
                then do:
                    if v-bge-xml-bgefmt = "dbf":U
                    then do:
                        run set-dbf-out-file-name in this-procedure (
                              input substitute( "lprt&1&2_":U, buf_parts.artic, buf_parts.part-code )
                            , input p-doc-code
                        ).
                    end.
                    if v-bge-xml-shift-mode = yes
                    and available buf_doc-line
                    then do:        /* Вычисляем суммы по документу для партий */
                        define variable v-doc-sum-r    as decimal      no-undo.
                        define variable v-doc-sum-b    as decimal      no-undo.
                        define buffer buf_trn-doc       for ub.trn-doc.
                        find first buf_trn-doc no-lock
                             where buf_trn-doc.doc-code = buf_doc-line.doc-code
                        no-error.
                        if available buf_trn-doc
                        then do:
                            create tt-clcparts.
                            buffer-copy buf_parts to tt-clcparts.
                            run clcprtsl_calc-parts in this-procedure (
                                  input recid( tt-clcparts )
                                , input yes
                                , input no
                                , input buf_doc-line.road-tax       /* parroad-tax      */
                                , input buf_doc-line.excise         /* parexcise        */
                                , input buf_doc-line.VAT-pc         /* parvat-pc        */
                                , input buf_doc-line.cons-vat-pc    /* parcons-vat-pc   */
                                , input buf_doc-line.SLT-pc         /* parslt-pc        */
                                , input buf_trn-doc.base-rate       /* parbase-rate     */
                                , input buf_trn-doc.base-scale      /* parbase-scale    */
                                , input "":U                        /* parr-b           */
                                , input 0.0                         /* parcur-base      */
                                , input 0.0                         /* parcurroad-tax   */
                                , input 0.0                         /* parcurexcise     */
                                , input 0.0                         /* parcurvat-pc     */
                                , input 0.0                         /* parcurcons-vat-pc*/
                                , input 0.0                         /* parcurslt-pc     */
                            ).
                            find first tt-allsum-line
                                 where tt-allsum-line.sum-type = {&sum-general}
                            no-error.
                            if available tt-allsum-line
                            then do:
                                assign
                                    v-doc-sum-r = tt-allsum-line.sum-dsc-rubl-doc
                                    v-doc-sum-b = tt-allsum-line.sum-dsc-base-doc
                                .
                            end.
                        end.        /* if available buf_trn-doc */
                    end.        /* if v-bge-xml-shift-mode = yes */
                   
                    if p-is-envd_ eq YES then
                    assign
                    v-sum-line = v-sum-line + ((price-rubl-with-tax-loc / (100 + buf_doc-line.VAT-pc )) * buf_doc-line.VAT-pc)  * v-fact-qnty  .
                    
                    run wp-xmltagopen in this-procedure ( input 5, input "part":U, input "" ).
                    run wp-xmltagput in this-procedure ( input 6, input "doc_ID":U              , input string( v-in-code               ), input 2 ).
                    run wp-xmltagput in this-procedure ( input 6, input "qnty":U                , input string( v-fact-qnty             ), input 2 ).
                    run wp-xmltagput in this-procedure ( input 6, input "docQnty":U             , input string( v-doc-qnty              ), input 2 ).
                    run wp-xmltagput in this-procedure ( input 6, input "cst":U                 , input string( v-cst-code              ), input 2 ).
                    run wp-xmltagput in this-procedure ( input 6, input "supp":U                , input string( v-supp-type + string( v-supp-code ) ), input 2 ).
                    run wp-xmltagput in this-procedure ( input 6, input "hostCode":U            , input string( v-parts-host-code       ), input 2 ).
                    run wp-xmltagput in this-procedure ( input 6, input "contractCode":U        , input string( v-parts-contract-code   ), input 2 ).
                    run wp-xmltagput in this-procedure ( input 6, input "sumr":U                , input string( v-sum-rubl              ), input 1 ).
                    run wp-xmltagput in this-procedure ( input 6, input "docSumr":U             , input string( v-doc-sum-r             ), input 2 ).
/*                    run wp-xmltagput in this-procedure ( input 6, input "docPl":U             , input string( v-doc-pl-r             ), input 2 ).*/

                    if p-is-envd_ eq NO then 
                      run wp-xmltagput in this-procedure ( input 6, input "VATr":U                , input string( v-vat-rubl              ), input 2 ).
                    else
                      run wp-xmltagput in this-procedure ( input 6, input "VATr":U                , input string(((price-rubl-with-tax-loc / (100 + buf_doc-line.VAT-pc )) * buf_doc-line.VAT-pc)  * v-fact-qnty  ), input 2 ).
                    
                    run wp-xmltagput in this-procedure ( input 6, input "SLTr":U                , input string( v-slt-rubl              ), input 2 ).
                    run wp-xmltagput in this-procedure ( input 6, input "roadTaxr":U            , input string( v-road-tax-rubl         ), input 2 ).
                    run wp-xmltagput in this-procedure ( input 6, input "transportr":U          , input string( v-transport-rubl        ), input 2 ).
                    run wp-xmltagput in this-procedure ( input 6, input "otherr":U              , input string( v-other-rubl            ), input 2 ).
                    run wp-xmltagput in this-procedure ( input 6, input "exciser":U             , input string( v-excise-rubl           ), input 2 ).
                    run wp-xmltagput in this-procedure ( input 6, input "sumb":U                , input string( v-sum-base              ), input 2 ).
                    run wp-xmltagput in this-procedure ( input 6, input "docSumb":U             , input string( v-doc-sum-b             ), input 2 ).
                    run wp-xmltagput in this-procedure ( input 6, input "VATb":U                , input string( v-vat-base              ), input 2 ).
                    run wp-xmltagput in this-procedure ( input 6, input "SLTb":U                , input string( v-slt-base              ), input 2 ).
                    run wp-xmltagput in this-procedure ( input 6, input "roadTaxb":U            , input string( v-road-tax-base         ), input 2 ).
                    run wp-xmltagput in this-procedure ( input 6, input "transportb":U          , input string( v-transport-base        ), input 2 ).
                    run wp-xmltagput in this-procedure ( input 6, input "otherb":U              , input string( v-other-base            ), input 2 ).
                    run wp-xmltagput in this-procedure ( input 6, input "exciseb":U             , input string( v-excise-base           ), input 2 ).
                    run wp-xmltagput in this-procedure ( input 6, input "contractSuppCode":U    , input v-supp-dog-code                  , input 0 ).
                    run wp-xmltagput in this-procedure ( input 6, input "contractSuppNo":U      , input v-supp-ndog                      , input 0 ).
                    run wp-xmltagput in this-procedure ( input 6, input "contractSuppDate":U    , input v-supp-ddog                      , input 0 ).
                    run wp-xmltagput in this-procedure ( input 6, input "contractSuppDateXml":U , input bge-xml-str-date(v-supp-ddog)    , input 0 ).
                    run wp-xmltagput in this-procedure ( input 6, input "countryCode":U         , input v-country-code                   , input 0 ).
                    run wp-xmltagput in this-procedure ( input 6, input "priceCli":U        , input string( v-parts-price-cli       ), input 2 ).
                    run wp-xmltagput in this-procedure ( input 6, input "cliBaseRate":U     , input string( v-parts-cli-base-rate   ), input 2 ).
                    run wp-xmltagput in this-procedure ( input 6, input "vatType":U         , input string( v-parts-vat-type        ), input 0 ).
                    run wp-xmltagput in this-procedure ( input 6, input "exchCode":U        , input string( v-parts-exch-code       ), input 2 ).
                    run wp-xmltagput in this-procedure ( input 6, input "attrExchRate":U    , input string( v-parts-attr-exch-rate  ), input 2 ).
                    run wp-xmltagput in this-procedure ( input 6, input "attrExchScale":U   , input string( v-parts-attr-exch-scale ), input 2 ).
                    run wp-xmltagput in this-procedure ( input 6, input "attrUnitCli":U     , input string( v-parts-attr-unit-cli   ), input 0 ).
                    
                    
                    IF v-is-alco THEN
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
                if v-bge-xml-bgefmt = "dbf":U
                then do:
                    run set-dbf-out-file-name in this-procedure (
                          input substitute( "lhdr&1_":U, buf_ot-line-crsa-loop.artic )
                        , input p-doc-code
                    ).
                end.
                run wp-xmltagput in this-procedure ( 4, "CSTCode",    string( v-parts-cst-code ), 0 ).
            end.        /* if p-cst = yes */
        end.        /* if p-ext-doc-type <> {&TDEDT_Overturn} */
        if v-bge-xml-bgefmt = "dbf":U
        then do:
            run set-dbf-out-file-name in this-procedure (
                  input substitute( "lhdr&1_":U, buf_goods.artic )
                , input p-doc-code
            ).
        end.
        /*---START--------- дополнительно экспортируем разброску по типам кассовых платежей----------*/
        if v-bge-xml-bgefmt = "dbf":U
        then do:
            run set-dbf-out-file-name in this-procedure (
                  input substitute( "lchk&1_":U, buf_goods.artic )
                , input p-doc-code
            ).
        end.
        if p-chk-pay-code = yes
        and available buf_doc-line
        then do:
            run get-cash-pay in this-procedure (
                  input p-ext-doc-type
                , input recid( buf_doc-line )
                , input p-trn-doc-out-code
                , output v-cash-pay-not-specified
            ).
            if v-cash-pay-not-specified = no
            then do:
                run export-goods-pay-desk in this-procedure (
                      input buf_goods.gds-code
                    , input buf_goods.gds-type
                    , input v-is-petrol
                    , input v-is-pieces
                ).
            end.
        end. /* p-chk-pay-code = yes*/
    end.        /* p-ext-doc-type <> {&TDEDT_Overturn} */
    else do:
        /* Для переоценки не надо пытыться выгрузить ГТД */
    end.        /* NOT ( p-ext-doc-type <> {&TDEDT_Overturn} ) */
/*--E------- Для всех кроме переоценки выводим строку ГТД и количество ----------*/

    if buf_goods.gds-type = {&gds-office}
    then do:
        if p-ot-tot-sale-exists = yes
        then do:
            run export-ot-line in this-procedure (
                  input p-doc-code
                , input buf_ot-line-crsa-loop.artic
                , input buf_ot-line-crsa-loop.prod-type
                , input buf_ot-line-crsa-loop.prod-code
                , input {&arh-sale-service}
                , p-is-envd_
                , v-sum-line
            ).
        end.
        if p-ot-tot-cost-exists = yes
        then do:
            run export-ot-line in this-procedure (
                  input p-doc-code
                , input buf_ot-line-crsa-loop.artic
                , input buf_ot-line-crsa-loop.prod-type
                , input buf_ot-line-crsa-loop.prod-code
                , input {&arh-cost-service}
                , p-is-envd_
                , v-sum-line
            ).
        end.
        if p-ot-tot-crsa-exists = yes
        then do:
            run export-ot-line in this-procedure (
                  input p-doc-code
                , input buf_ot-line-crsa-loop.artic
                , input buf_ot-line-crsa-loop.prod-type
                , input buf_ot-line-crsa-loop.prod-code
                , input {&arh-crsa-service}
                , p-is-envd_
                , v-sum-line
            ).
        end.
    end.        /* if buf_goods.gds-type = {&gds-office}  */
    else do:
        if p-ot-tot-sale-exists = yes
        then do:
            run export-ot-line in this-procedure (
                  input p-doc-code
                , input buf_ot-line-crsa-loop.artic
                , input buf_ot-line-crsa-loop.prod-type
                , input buf_ot-line-crsa-loop.prod-code
                , input {&arh-sale}
                , p-is-envd_
                , v-sum-line
            ).
        end.
        if p-ot-tot-cost-exists = yes
        then do:
            run export-ot-line in this-procedure (
                  input p-doc-code
                , input buf_ot-line-crsa-loop.artic
                , input buf_ot-line-crsa-loop.prod-type
                , input buf_ot-line-crsa-loop.prod-code
                , input {&arh-cost}
                , p-is-envd_
                , v-sum-line
            ).
        end.
        if p-ot-tot-crsa-exists = yes
        then do:
            run export-ot-line in this-procedure (
                  input p-doc-code
                , input buf_ot-line-crsa-loop.artic
                , input buf_ot-line-crsa-loop.prod-type
                , input buf_ot-line-crsa-loop.prod-code
                , input {&arh-crsa}
                , p-is-envd_
                , v-sum-line
            ).
        end.
    end.        /* NOT ( if buf_goods.gds-type = {&gds-office}  ) */
    /* Для инвентаризации */
    if p-ext-doc-type = {&TDEDT_Inv}
    or p-ext-doc-type = {&TDEDT_Peresort}
    or p-ext-doc-type = {&TDEDT_Corr_Acc_Price}
    or p-ext-doc-type = {&TDEDT_Corr_Minus_Parts}
    then do:
        run export-before-and-after-inv-line in this-procedure (
              input p-doc-code
            , input buf_goods.artic
            , input buf_goods.gds-code
            , input p-exists-before
            , input p-exists-after
            , input ( v-is-petrol = yes and v-is-pieces = no and v-weight-not-specified  = no )
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
                    run fill_bge-xml_clients in this-procedure (
                          input p-parent-handle
                        , input temp_cost_cli_ot-supp-line.cli-type
                        , input temp_cost_cli_ot-supp-line.cli-code
                    ).
                    if v-bge-xml-bgefmt = "dbf":U
                    then do:
                        run set-dbf-out-file-name in this-procedure (
                              input substitute( "lspc&1&2_":U, temp_cost_cat-id_ot-supp-line.artic, temp_cost_cat-id_ot-supp-line.cat-id )
                            , input p-doc-code
                        ).
                    end.
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
                        if v-bge-xml-bgefmt = "dbf":U
                        then do:
                            run set-dbf-out-file-name in this-procedure (
                                 input substitute( "lsps&1&2_":U, buf_sale_ot-supp-line.artic, temp_cost_cat-id_ot-supp-line.cat-id )
                                , input p-doc-code
                            ).
                        end.
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
end.
end procedure. /* export-document-lines */

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
        no-error
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
            if v-bge-xml-bgefmt = "dbf":U
            then do:
                run set-dbf-out-file-name in this-procedure (
                      input "hbiv":U
                    , input p-doc-code
                ).
            end.
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
            run wp-XMLWriteLog( input v-bge-xml-log-file-name, input 1, input "*** ERR *** Не найдена запись trn-doc-sum с sum-type = {&sum-before-doc} для документа " + string( p-doc-code ) ).
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
            if v-bge-xml-bgefmt = "dbf":U
            then do:
                run set-dbf-out-file-name in this-procedure (
                      input "haiv":U
                    , input p-doc-code
                ).
            end.
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
            run wp-XMLWriteLog( input v-bge-xml-log-file-name, input 1, input "*** ERR *** Не найдена запись trn-doc-sum с sum-type = {&sum-after-doc} для документа " + string( p-doc-code ) ).
        end.        /* NOT ( available buf_trn-doc-sum ) */
    end.        /* if lookup( {&sum-after-doc}, v-attr-value ) <> 0 */
end.
end procedure. /* export-before-and-after-inv-trn */


/*==========================================================================*/
procedure export-before-and-after-inv-line :
do
on error undo, return error
:
define input parameter p-doc-code           as character        no-undo.
define input parameter p-artic              as character        no-undo.
define input parameter p-gds-code           as integer          no-undo.
define input parameter p-exists-before      as logical          no-undo.
define input parameter p-exists-after       as logical          no-undo.
define input parameter p-need-petrol-weight as logical          no-undo.

    define buffer buf_doc-line-sum  for ub.doc-line-sum.
    define buffer buf_inv-line      for ub.inv-line.
    define buffer buf_goods         for ub.goods.

    if p-need-petrol-weight = yes
    then do:
        find first buf_goods no-lock
             where buf_goods.gds-code = p-gds-code
        no-error.
        if available buf_goods
        then do:
            find first buf_inv-line no-lock
                 where buf_inv-line.doc-code   = p-doc-code
                   and buf_inv-line.artic      = buf_goods.artic
                   and buf_inv-line.prod-type  = buf_goods.prod-type
                   and buf_inv-line.prod-code  = buf_goods.prod-code
            no-error.
            if available buf_inv-line
            then do:
                run wp-xmltagput( input 3, input "petrolWeightBefore", input string( buf_inv-line.before-cli-qnty ), input 0 ).
            end.
        end.
    end.
    if p-exists-before = yes
    then do:
        find first buf_doc-line-sum no-lock
             where buf_doc-line-sum.doc-code = p-doc-code
               and buf_doc-line-sum.gds-code = p-gds-code
               and buf_doc-line-sum.sum-type = {&sum-before-doc}
        no-error.
        if available buf_doc-line-sum
        then do:
            if v-bge-xml-bgefmt = "dbf":U
            then do:
                run set-dbf-out-file-name in this-procedure (
                      input substitute( "lbiv&1_":U, p-artic )
                    , input p-doc-code
                ).
            end.
            run wp-xmltagput( input 3, input "quantityBefore", input string( buf_doc-line-sum.fact-qnty ), input 2 ).
            run wp-xmltagopen( input 3, input "beforeSum", input "" ).
            run wp-xmltagput( input 4, input "qnty", input string( buf_doc-line-sum.fact-qnty ), input 2 ).
                run wp-xmltagopen( input 4, input "saleSum", input "" ).
                    run wp-xmltagput( input 5, input "sumr",        input string( buf_doc-line-sum.crsa-sum-rubl       ), input 1 ).
                    run wp-xmltagput( input 5, input "VATr",        input string( buf_doc-line-sum.crsa-vat-rubl       ), input 2 ).
                    run wp-xmltagput( input 5, input "SLTr",        input string( buf_doc-line-sum.crsa-slt-rubl       ), input 2 ).
                    run wp-xmltagput( input 5, input "roadTaxr",    input string( buf_doc-line-sum.crsa-road-tax-rubl  ), input 2 ).
                    run wp-xmltagput( input 5, input "transportr",  input string( buf_doc-line-sum.crsa-transport-rubl ), input 2 ).
                    run wp-xmltagput( input 5, input "otherr",      input string( buf_doc-line-sum.crsa-other-rubl     ), input 2 ).
                    run wp-xmltagput( input 5, input "exciser",     input string( buf_doc-line-sum.crsa-excise-rubl    ), input 2 ).
                    run wp-xmltagput( input 5, input "sumb",        input string( buf_doc-line-sum.crsa-sum-base       ), input 2 ).
                    run wp-xmltagput( input 5, input "VATb",        input string( buf_doc-line-sum.crsa-vat-base       ), input 2 ).
                    run wp-xmltagput( input 5, input "SLTb",        input string( buf_doc-line-sum.crsa-slt-base       ), input 2 ).
                    run wp-xmltagput( input 5, input "roadTaxb",    input string( buf_doc-line-sum.crsa-road-tax-base  ), input 2 ).
                    run wp-xmltagput( input 5, input "transportb",  input string( buf_doc-line-sum.crsa-transport-base ), input 2 ).
                    run wp-xmltagput( input 5, input "otherb",      input string( buf_doc-line-sum.crsa-other-base     ), input 2 ).
                    run wp-xmltagput( input 5, input "exciseb",     input string( buf_doc-line-sum.crsa-excise-base    ), input 2 ).
                run wp-xmltagclose( input 4, input "saleSum" ).
                run wp-xmltagopen( input 4, input "costSum", input "" ).
                    run wp-xmltagput( input 5, input "sumr",        input string( buf_doc-line-sum.cost-sum-rubl       ), input 1 ).
                    run wp-xmltagput( input 5, input "VATr",        input string( buf_doc-line-sum.cost-vat-rubl       ), input 2 ).
                    run wp-xmltagput( input 5, input "SLTr",        input string( buf_doc-line-sum.cost-slt-rubl       ), input 2 ).
                    run wp-xmltagput( input 5, input "roadTaxr",    input string( buf_doc-line-sum.cost-road-tax-rubl  ), input 2 ).
                    run wp-xmltagput( input 5, input "transportr",  input string( buf_doc-line-sum.cost-transport-rubl ), input 2 ).
                    run wp-xmltagput( input 5, input "otherr",      input string( buf_doc-line-sum.cost-other-rubl     ), input 2 ).
                    run wp-xmltagput( input 5, input "exciser",     input string( buf_doc-line-sum.cost-excise-rubl    ), input 2 ).
                    run wp-xmltagput( input 5, input "sumb",        input string( buf_doc-line-sum.cost-sum-base       ), input 2 ).
                    run wp-xmltagput( input 5, input "VATb",        input string( buf_doc-line-sum.cost-vat-base       ), input 2 ).
                    run wp-xmltagput( input 5, input "SLTb",        input string( buf_doc-line-sum.cost-slt-base       ), input 2 ).
                    run wp-xmltagput( input 5, input "roadTaxb",    input string( buf_doc-line-sum.cost-road-tax-base  ), input 2 ).
                    run wp-xmltagput( input 5, input "transportb",  input string( buf_doc-line-sum.cost-transport-base ), input 2 ).
                    run wp-xmltagput( input 5, input "otherb",      input string( buf_doc-line-sum.cost-other-base     ), input 2 ).
                    run wp-xmltagput( input 5, input "exciseb",     input string( buf_doc-line-sum.cost-excise-base    ), input 2 ).
                run wp-xmltagclose( input 4, input "costSum" ).
            run wp-xmltagclose( input 3, input "beforeSum" ).
        end.        /* available buf_doc-line-sum */
        else do:
            run wp-XMLWriteLog( input v-bge-xml-log-file-name, input 1, input "*** ERR *** Не найдена запись doc-line-sum с sum-type = {&sum-before-doc} для документа " + string( p-doc-code ) ).
        end.        /* NOT ( available buf_doc-line-sum ) */
    end.        /* if p-exists-before = yes */
    if available buf_inv-line
    then do:
        run wp-xmltagput( input 3, input "petrolWeightAfter",  input string( buf_inv-line.after-cli-qnty  ), input 0 ).
    end.
    if p-exists-after = yes
    then do:
        find first buf_doc-line-sum no-lock
             where buf_doc-line-sum.doc-code = p-doc-code
               and buf_doc-line-sum.gds-code = p-gds-code
               and buf_doc-line-sum.sum-type = {&sum-after-doc}
        no-error.
        if available buf_doc-line-sum
        then do:
            if v-bge-xml-bgefmt = "dbf":U
            then do:
                run set-dbf-out-file-name in this-procedure (
                      input substitute( "laiv&1_":U, p-artic )
                    , input p-doc-code
                ).
            end.
            run wp-xmltagput( input 3, input "quantityAfter", input string( buf_doc-line-sum.fact-qnty ), input 2 ).
            run wp-xmltagopen( input 3, input "afterSum", input "" ).
            run wp-xmltagput( input 4, input "qnty", input string( buf_doc-line-sum.fact-qnty ), input 2 ).
                run wp-xmltagopen( input 4, input "saleSum", input "" ).
                    run wp-xmltagput( input 5, input "sumr",        input string( buf_doc-line-sum.crsa-sum-rubl       ), input 1 ).
                    run wp-xmltagput( input 5, input "VATr",        input string( buf_doc-line-sum.crsa-vat-rubl       ), input 2 ).
                    run wp-xmltagput( input 5, input "SLTr",        input string( buf_doc-line-sum.crsa-slt-rubl       ), input 2 ).
                    run wp-xmltagput( input 5, input "roadTaxr",    input string( buf_doc-line-sum.crsa-road-tax-rubl  ), input 2 ).
                    run wp-xmltagput( input 5, input "transportr",  input string( buf_doc-line-sum.crsa-transport-rubl ), input 2 ).
                    run wp-xmltagput( input 5, input "otherr",      input string( buf_doc-line-sum.crsa-other-rubl     ), input 2 ).
                    run wp-xmltagput( input 5, input "exciser",     input string( buf_doc-line-sum.crsa-excise-rubl    ), input 2 ).
                    run wp-xmltagput( input 5, input "sumb",        input string( buf_doc-line-sum.crsa-sum-base       ), input 2 ).
                    run wp-xmltagput( input 5, input "VATb",        input string( buf_doc-line-sum.crsa-vat-base       ), input 2 ).
                    run wp-xmltagput( input 5, input "SLTb",        input string( buf_doc-line-sum.crsa-slt-base       ), input 2 ).
                    run wp-xmltagput( input 5, input "roadTaxb",    input string( buf_doc-line-sum.crsa-road-tax-base  ), input 2 ).
                    run wp-xmltagput( input 5, input "transportb",  input string( buf_doc-line-sum.crsa-transport-base ), input 2 ).
                    run wp-xmltagput( input 5, input "otherb",      input string( buf_doc-line-sum.crsa-other-base     ), input 2 ).
                    run wp-xmltagput( input 5, input "exciseb",     input string( buf_doc-line-sum.crsa-excise-base    ), input 2 ).
                run wp-xmltagclose( input 4, input "saleSum" ).
                run wp-xmltagopen( input 4, input "costSum", input "" ).
                    run wp-xmltagput( input 5, input "sumr",        input string( buf_doc-line-sum.cost-sum-rubl       ), input 1 ).
                    run wp-xmltagput( input 5, input "VATr",        input string( buf_doc-line-sum.cost-vat-rubl       ), input 2 ).
                    run wp-xmltagput( input 5, input "SLTr",        input string( buf_doc-line-sum.cost-slt-rubl       ), input 2 ).
                    run wp-xmltagput( input 5, input "roadTaxr",    input string( buf_doc-line-sum.cost-road-tax-rubl  ), input 2 ).
                    run wp-xmltagput( input 5, input "transportr",  input string( buf_doc-line-sum.cost-transport-rubl ), input 2 ).
                    run wp-xmltagput( input 5, input "otherr",      input string( buf_doc-line-sum.cost-other-rubl     ), input 2 ).
                    run wp-xmltagput( input 5, input "exciser",     input string( buf_doc-line-sum.cost-excise-rubl    ), input 2 ).
                    run wp-xmltagput( input 5, input "sumb",        input string( buf_doc-line-sum.cost-sum-base       ), input 2 ).
                    run wp-xmltagput( input 5, input "VATb",        input string( buf_doc-line-sum.cost-vat-base       ), input 2 ).
                    run wp-xmltagput( input 5, input "SLTb",        input string( buf_doc-line-sum.cost-slt-base       ), input 2 ).
                    run wp-xmltagput( input 5, input "roadTaxb",    input string( buf_doc-line-sum.cost-road-tax-base  ), input 2 ).
                    run wp-xmltagput( input 5, input "transportb",  input string( buf_doc-line-sum.cost-transport-base ), input 2 ).
                    run wp-xmltagput( input 5, input "otherb",      input string( buf_doc-line-sum.cost-other-base     ), input 2 ).
                    run wp-xmltagput( input 5, input "exciseb",     input string( buf_doc-line-sum.cost-excise-base    ), input 2 ).
                run wp-xmltagclose( input 4, input "costSum" ).
            run wp-xmltagclose( input 3, input "afterSum" ).
        end.        /* available buf_doc-line-sum */
        else do:
            run wp-XMLWriteLog( input v-bge-xml-log-file-name, input 1, input "*** ERR *** Не найдена запись doc-line-sum с sum-type = {&sum-after-doc} для документа " + string( p-doc-code ) ).
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

  do
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
procedure export-gds-dtl :
define input parameter p-ext-doc-type   as character        no-undo.
define input parameter p-doc-code       as character        no-undo.
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
        run wp-XMLWriteLog in this-procedure (
              input v-bge-xml-log-file-name
            , input 1
            , input substitute( "*** ERR *** Выгрузка признаков: не найден документ с номером '&1'"
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
        run wp-XMLWriteLog in this-procedure (
              input v-bge-xml-log-file-name
            , input 1
            , input substitute( "*** ERR *** Выгрузка признаков: не найдена строка документа с номером '&1' и артикулом товара '&2'"
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
        if v-bge-xml-bgefmt = "dbf":U
        then do:
            run set-dbf-out-file-name in this-procedure (
                  input substitute( "ldtl&1&2_":U, buf_gds-dtl.artic, buf_gds-dtl.prt-code )
                , input p-doc-code
            ).
        end.
        run wp-xmltagopen in this-procedure ( input 5, input "dtl", input "" ).
        run wp-xmltagput in this-procedure ( input 6, input "dtlName"   , input string( buf_gds-prt.f-name ), input 2 ).
        if p-ext-doc-type = {&TDEDT_Inv}
        or p-ext-doc-type = {&TDEDT_Peresort}
        or p-ext-doc-type = {&TDEDT_Corr_Acc_Price}
        or p-ext-doc-type = {&TDEDT_Corr_Minus_Parts}
        then do:
            run wp-xmltagput in this-procedure ( input 6, input "qnty"          , input string( v-doc-qnty                  ), input 2 ).
            run wp-xmltagput in this-procedure ( input 6, input "beforeQnty"    , input string( v-fact-qnty - v-doc-qnty    ), input 2 ).
            run wp-xmltagput in this-procedure ( input 6, input "afterQnty"     , input string( v-fact-qnty                 ), input 2 ).
        end.        /* if p-ext-doc-type = {&TDEDT_Inv} */
        else do:
            run wp-xmltagput in this-procedure ( input 6, input "qnty"      , input string( v-fact-qnty        ), input 2 ).
        end.        /* NOT ( if p-ext-doc-type = {&TDEDT_Inv} ) */
        run wp-xmltagput in this-procedure ( input 6, input "sumr"      , input string( v-sum-rubl         ), input 1 ).
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
procedure export-header :
define input parameter p-doc-code           as character        no-undo.
define input parameter p-obj-type           as character        no-undo.
define input parameter p-obj-code           as integer          no-undo.
define input parameter p-fact-order         as decimal          no-undo.
define input parameter p-ext-doc-type       as character        no-undo.
define output parameter p-doc-exists        as logical          no-undo.
define output parameter p-trn-doc-out-code  as character        no-undo.
define output parameter p-trn-doc-office    as logical          no-undo.

    define variable v-doc-date        as date         no-undo.
    define variable v-fact-date       as date         no-undo.
    define variable v-fact-time       as integer      no-undo.
    define variable v-shift-date      as date         no-undo.
    define variable v-shift-num       as integer      no-undo.
    define variable v-shift-name      as character    no-undo.
    define variable v-reason-code     as integer      no-undo.
    define variable v-doc-PS          as character    no-undo.
    define variable v-sys-date        as date         no-undo.
    define variable v-sys-time        as character    no-undo.
    define variable v-temp-char       as character    no-undo.

    define variable v-supp-dog-code   as character    no-undo.
    define variable v-supp-ndog       as character    no-undo.
    define variable v-supp-ddog       as character    no-undo.
    define variable v-attr-value      as character    no-undo.
    define variable v-attr-type       as character    no-undo.
    define variable v-ext-doc-type    as character    no-undo.
    define variable v-d-card          as character    no-undo.
    define variable v-supp-in-doc-no  as character    no-undo.

    define variable v-doc-exch-code   as integer      no-undo.
    define variable v-doc-exch-rate   as decimal      no-undo.
    define variable v-doc-exch-scale  as integer      no-undo.    
    define variable v-idContr         as character    no-undo. 


    define buffer buf_trn-doc       for ub.trn-doc.
    define buffer buf_price-doc     for ub.price-doc.
    define buffer buf_contract      for ub.contract.
    define buffer buf_ord-chain     for ub.ord-chain.
    define buffer buf_ord-doc-rcv   for ub.ord-doc-rcv.

do
for buf_trn-doc
  , buf_price-doc
  , buf_contract
  , buf_ord-chain
  , buf_ord-doc-rcv
on error undo, return error
:
    assign
        v-supp-dog-code   = "":U
        v-supp-ndog       = "":U
        v-supp-ddog       = "":U
        v-d-card          = "":U
        v-ext-doc-type    = p-ext-doc-type
        v-doc-exch-code   = ?
        v-doc-exch-rate   = ?
        v-doc-exch-scale  = ?
    .
    if p-ext-doc-type <> {&TDEDT_Overturn}
    then do:        /* По номеру документа достать даты и примечание. */
        find first buf_trn-doc no-lock
             where buf_trn-doc.doc-code = p-doc-code
        no-error.
        if not available buf_trn-doc
        then do:
            run wp-XMLWriteLog in this-procedure (
                  input v-bge-xml-log-file-name
                , input 1
                , input substitute( "*** WRN *** Не удалось найти документ &1 (&2)", p-doc-code, p-ext-doc-type )
            ).
            assign
                p-doc-exists        = no
                p-trn-doc-out-code  = "":U
                p-trn-doc-office    = no
                v-doc-date          = ?
                v-fact-date         = ?
                v-fact-time         = 0
                v-shift-date        = ?
                v-shift-num         = 0
                v-shift-name        = "":U
                v-reason-code       = 0
                v-doc-PS            = "":U
            .
        end.
        else do:
            assign
                p-doc-exists        = yes
                p-trn-doc-out-code  = buf_trn-doc.out-code
                p-trn-doc-office    = buf_trn-doc.office
                v-doc-date          = buf_trn-doc.doc-date
                v-fact-date         = buf_trn-doc.fact-date
                v-fact-time         = buf_trn-doc.fact-time
                v-shift-date        = buf_trn-doc.shift-date
                v-shift-num         = buf_trn-doc.shift-num
                v-reason-code       = buf_trn-doc.reason-code
                v-doc-PS            = buf_trn-doc.ps
                v-sys-date          = buf_trn-doc.sys-date
                v-sys-time          = buf_trn-doc.sys-time
                v-d-card            = buf_trn-doc.d-card
                v-doc-exch-code     = buf_trn-doc.exch-code
                v-doc-exch-rate     = buf_trn-doc.exch-rate
                v-doc-exch-scale    = buf_trn-doc.exch-scale
            .
            { str/shiftnam.i
                buf_trn-doc.obj-type
                buf_trn-doc.obj-code
                v-shift-date
                v-shift-num
                v-shift-name
                v-temp-char
                no-error
            }
            if p-ext-doc-type = {&TDEDT_Pri_Vnesh}
            then do:
              run bge-xml-resolve-ext-doc-type in this-procedure ( input  p-ext-doc-type
                                                                 , input  buf_trn-doc.cli-type
                                                                 , input  buf_trn-doc.cli-code
                                                                 , output v-ext-doc-type
                                                                 ).
            end. /* if p-ext-doc-type = {&TDEDT_Pri_Vnesh} */
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
                            v-supp-ddog          = string(buf_contract.contract-date, "99.99.9999")
                        .
                    end.
                end.
            end.        /* if p-ext-doc-type = {&TDEDT_Pri_Vnesh} */
        end.
    end.      /* if p-ext-doc-type <> {&TDEDT_Overturn} */
    else do:        /* По номеру переоценки достать даты и примечание. */
        find first buf_price-doc no-lock
             where buf_price-doc.doc-num = p-doc-code
        no-error.
        if not available buf_price-doc
        then do:
            run wp-XMLWriteLog in this-procedure (
                  input v-bge-xml-log-file-name
                , input 1
                , input substitute( "*** WRN *** Не удалось найти документ переоценки &1", p-doc-code )
            ).
            assign
                p-doc-exists    = no
                v-doc-date      = ?
                v-fact-date     = ?
                v-fact-time     = 0
                v-shift-date    = ?
                v-shift-num     = 0
                v-shift-name    = "":U
                v-reason-code   = 0
                v-doc-PS        = "":U
            .
        end.
        else do:
            assign
                p-doc-exists    = yes
                v-doc-date      = buf_price-doc.doc-date
                v-fact-date     = buf_price-doc.fact-date
                v-fact-time     = buf_price-doc.fact-time
                v-shift-date    = buf_price-doc.shift-date
                v-shift-num     = buf_price-doc.shift-num
                v-reason-code   = 0
                v-doc-PS        = buf_price-doc.ps
                v-sys-date      = buf_price-doc.sys-date
                v-sys-time      = buf_price-doc.sys-time
            .
            { str/shiftnam.i
                buf_price-doc.obj-type
                buf_price-doc.obj-code
                v-shift-date
                v-shift-num
                v-shift-name
                v-temp-char
                no-error
            }
        end.
    end.      /* if NOT( p-ext-doc-type <> {&TDEDT_Overturn} ) */
    run wp-XMLWriteCnt( hcnt, "   " + string( p-doc-code ) + " от " + string( v-fact-date ) ) .
    process events.
    if v-bge-xml-bgefmt = "dbf":U
    then do:
        run set-dbf-out-file-name in this-procedure (
              input "head":U
            , input p-doc-code
        ).
    end.  
                              
    { str/tdat-val.i p-doc-code {&trdcattr-idCountryContr} v-idContr v-attr-type no-error }  
    
    run wp-xmltagopen( 2, "operation","" ).
    run wp-xmltagput( 3, "referenceNo",        string( p-doc-code                   ), 0 ).
    run wp-xmltagput( 3, "codeOperation",      string( v-ext-doc-type               ), 0 ).
    run wp-xmltagput( 3, "host",               string( p-host-code                  ), 0 ).
    run wp-xmltagput( 3, "store",              p-obj-type + string( p-obj-code )     , 0 ).
    run wp-xmltagput( 3, "factOrder",          string( p-fact-order )                , 0 ).
    run wp-xmltagput( 3, "sysDate",            string(v-sys-date , "99.99.9999")     , 0 ).
    run wp-xmltagput( 3, "sysDateXml",         bge-xml-date( v-sys-date )            , 0 ).
    run wp-xmltagput( 3, "sysTime",            string( v-sys-time )                  , 0 ).
    run wp-xmltagput( 3, "dateDoc",            string( v-doc-date , "99.99.9999" )   , 0 ).
    run wp-xmltagput( 3, "dateDocXml",         bge-xml-date( v-doc-date )            , 0 ).
    run wp-xmltagput( 3, "dateFact",           string( v-fact-date , "99.99.9999")   , 0 ).
    run wp-xmltagput( 3, "dateFactXml",        bge-xml-date( v-fact-date )           , 0 ).
    run wp-xmltagput( 3, "timeFact",           string( v-fact-time, "hh:mm:ss"      ), 0 ).
    run wp-xmltagput( 3, "shiftDate",          string( v-shift-date , "99.99.9999")  , 0 ).
    run wp-xmltagput( 3, "shiftDateXml",       bge-xml-date( v-shift-date )          , 0 ).
    run wp-xmltagput( 3, "shiftNum",           string( v-shift-num                  ), 0 ).
    run wp-xmltagput( 3, "shiftName",          string( v-shift-name                 ), 0 ).
    run wp-xmltagput( 3, "valutCode",          string( v-base-code                  ), 0 ).
    run wp-xmltagput( 3, "valutCodeOKV",       string( v-base-code-okv              ), 0 ). 
    
    run wp-xmltagput( 3, "GosContract",        string( v-idContr                 ), 0 ).        
    
    run wp-xmltagput( input 3, input "exchCode"   , input string( v-doc-exch-code                     ), input 0 ).
    run wp-xmltagput( input 3, input "exchRate"   , input string( v-doc-exch-rate                     ), input 0 ).
    run wp-xmltagput( input 3, input "exchScale"  , input string( v-doc-exch-scale                    ), input 0 ).

    if p-ext-doc-type <> {&TDEDT_Overturn}
    then do:
        run fill_bge-xml_clients in this-procedure (
              input p-parent-handle
            , input buf_trn-doc.cli-type
            , input buf_trn-doc.cli-code
        ).
        run wp-xmltagput( 3, "firm",                 buf_trn-doc.cli-type + string( buf_trn-doc.cli-code ), 0 ).
        run wp-xmltagput( 3, "extNumber",            string( buf_trn-doc.ord-num                     ), 0 ).
        run wp-xmltagput( 3, "outNumber",            string( buf_trn-doc.ship-num                    ), 0 ).
        run wp-xmltagput( 3, "outDate",              string( buf_trn-doc.ship-date , "99.99.9999")    , 0 ).
        run wp-xmltagput( 3, "outDateXml",           bge-xml-date( buf_trn-doc.ship-date )            , 0 ).
        run wp-xmltagput( 3, "paymentCode",          string( buf_trn-doc.pay-code                    ), 0 ).
        run wp-xmltagput( 3, "InterFirmDocChild",    string( buf_trn-doc.hold-doc-code-child         ), 0 ).
        run wp-xmltagput( 3, "InterFirmDocParent",   string( buf_trn-doc.hold-doc-code-parent        ), 0 ).
        run wp-xmltagput( 3, "InterFirmObjType",     string( buf_trn-doc.hold-obj-type               ), 0 ).
        run wp-xmltagput( 3, "InterFirmObjCode",     string( buf_trn-doc.hold-obj-code               ), 0 ).
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
        run wp-xmltagput( 3, "suppInDocDate",     v-attr-value, 0 ).
        run wp-xmltagput( 3, "suppInDocDateXml",  bge-xml-str-date(v-attr-value), 0 ).
        { str/tdat-val.i
            p-doc-code
            {&trdcattr-nids}
            v-attr-value
            v-attr-type
        }
        run wp-xmltagput( 3, "suppInDocNo"         , v-attr-value                  , 0 ).
        run wp-xmltagput( 3, "contractSuppCode"    , v-supp-dog-code               , 0 ).
        run wp-xmltagput( 3, "contractSuppNo"      , v-supp-ndog                   , 0 ).
        run wp-xmltagput( 3, "contractSuppDate"    , v-supp-ddog                   , 0 ).
        run wp-xmltagput( 3, "contractSuppDateXml" , bge-xml-str-date(v-supp-ddog) , 0 ).
        { str/tdat-val.i
            p-doc-code
            {&trdcattr-ddog}
            v-attr-value
            v-attr-type
            no-error
        }
        if error-status :error
        then do:
            run wp-XMLWriteLog(
                  input v-bge-xml-log-file-name
                , input 1
                , substitute( "*** ERR *** Ошибка чтения атрибута даты договора для приходной накладной &1 ", p-doc-code )
            ).
        end.
        run wp-xmltagput( 3, "contractDate"   , v-attr-value                    , 0 ).
        run wp-xmltagput( 3, "contractDateXml", bge-xml-str-date(v-attr-value)  , 0 ).
        { str/tdat-val.i
            p-doc-code
            {&trdcattr-ndog}
            v-attr-value
            v-attr-type
            no-error
        }
        if error-status :error
        then do:
            run wp-XMLWriteLog(
                  input v-bge-xml-log-file-name
                , input 1
                , substitute( "*** ERR *** Ошибка чтения атрибута номера договора для приходной накладной &1 ", p-doc-code )
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
        run wp-xmltagput( 3, "sfDate"   , v-attr-value                  , 0 ).
        run wp-xmltagput( 3, "sfDateXml", bge-xml-str-date(v-attr-value), 0 ).
        { str/tdat-val.i
            p-doc-code
            {&trdcattr-ndov}
            v-attr-value
            v-attr-type
        no-error }
        if ( not error-status :error )
        and v-attr-value <> ?
        and v-attr-value <> "":U
        then do:
            run wp-xmltagput( 3, "doverNo":U, string( v-attr-value ), 0 ).
        end.
        { str/tdat-val.i
            p-doc-code
            {&trdcattr-ddov}
            v-attr-value
            v-attr-type
        no-error }
        if ( not error-status :error )
        and v-attr-value <> ?
        and v-attr-value <> "":U
        then do:
            run wp-xmltagput( 3, "doverDate":U   , string( v-attr-value )          , 0 ).
            run wp-xmltagput( 3, "doverDateXml":U, bge-xml-str-date( v-attr-value ), 0 ).
        end.
    end.      /* p-ext-doc-type <> {&TDEDT_Overturn} */
    run wp-xmltagput( input 3, input "reasonCode"   ,  input string( v-reason-code ), input 1 ).
    run wp-xmltagput( 3, "outCode",  p-trn-doc-out-code, 0 ).
    run wp-xmltagput( input 3, input "comment"      ,  input v-doc-PS               , input 0 ).

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
    run wp-xmltagput( input 3, input "dCard"   ,  input v-d-card , input 0 ).

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
        (v-tech-pass or can-find(first ub.sale-doc where ub.sale-doc.doc-code = p-doc-code and ub.sale-doc.doc-kind = {&sale-add-tech-refuell}))
    then do:
      run safe-wp-xmltagput in this-procedure ( input 3, input "techfuel":U  , input "yes":u, input 1 ).
    end. /* if p-ext-doc-type = {&TDEDT_Spi_Vnesh} */

    /* приход техпролив */
    if p-ext-doc-type = {&TDEDT_Pri_Vnesh} and
        (v-tech-pass or can-find(first ub.sale-doc where ub.sale-doc.doc-code = p-doc-code and ub.sale-doc.doc-kind = {&sale-add2-in-tech-refuell}))
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
end procedure. /* export-header */


/*==========================================================================*/
/*==                  Суммы по видам кассовых платежей                    ==*/
/*==========================================================================*/
procedure export-pay-code :
define input parameter p-doc-code           as character        no-undo.
define input parameter p-ext-doc-type       as character        no-undo.
define input parameter p-trn-doc-out-code   as character        no-undo.
define input parameter p-pay-desk           as logical          no-undo.
define input parameter p-pay-desk-cards     as logical          no-undo.


define output parameter p-is-out            as integer          no-undo.

    define variable v-inkas-pay-desk-type    as character    no-undo.

define buffer buf_sale-doc     for ub.sale-doc.
do
for buf_sale-doc
on error undo, return error
:
    case p-ext-doc-type :
        when {&TDEDT_Ras_Vnesh_Kass}
        then do:
            assign
                p-is-out                = 1
                v-inkas-pay-desk-type   = {&income}
            .
            find first buf_sale-doc no-lock
                 where buf_sale-doc.doc-code = p-doc-code
            no-error.
        end.
        when {&TDEDT_Vozvrat_Vnesh_Kass}
        then do:
            assign
                p-is-out                = -1
                v-inkas-pay-desk-type   = {&expense}
            .
            find first buf_sale-doc no-lock
                 where buf_sale-doc.doc-code = p-trn-doc-out-code
            no-error.
        end.
    end case.
    if available buf_sale-doc
    then do:
        run bge/bgepych2.p (
              input buf_sale-doc.inkas-code
            , input p-ext-doc-type
            , input p-pay-desk
            , input p-pay-desk-cards
            , input yes /*p-petrol*/
            , input yes /*p-goods*/
            , input yes /*p-services*/
        )no-error.
                if ERROR-STATUS:error then do:
                    run wp-XMLWriteLog(  
                          sLogFile, 
                          1, 
                          substitute("&1 (Документ &2)", if return-value <> "" then return-value else error-status:get-message(1), p-doc-code) 
                    ).
                    run write-to-log( vss-workfile + {&space-char} +
                                    substitute("&1 (Документ &2)", if return-value <> "" then return-value else error-status:get-message(1), p-doc-code) 
                                    ) .
                end.    
/*        if p-pay-code = yes*/
/*        then do:*/
            run get-inkas-pay-desk in this-procedure (
                  input buf_sale-doc.inkas-code
                , input buf_sale-doc.obj-type
                , input buf_sale-doc.obj-code
                , input v-inkas-pay-desk-type
            ) no-error .
            if error-status:error
            then do:
                run wp-XMLWriteLog(
                      input v-bge-xml-log-file-name
                    , input 1
                    , input substitute( "*** ERR *** Не удалось рассчитать разбивку по кодам оплат по документу &1. &2. &3. &4", p-doc-code, return-value, trim( error-status :get-message( 1 ) ), trim( error-status :get-message( 2 ) ) )
                ).
            end.
            if v-bge-xml-bgefmt = "dbf":U
            then do:
                run set-dbf-out-file-name in this-procedure (
                      input "hcss":U
                    , input p-doc-code
                ).
            end.
            run wp-xmltagopen( 3, "cassSum","" ).
            for each temp_inkas-pay
            on error undo, return error
            :
                run wp-xmltagopen( 4, "payCode", "" ).
                run wp-xmltagput( 5, "code", string( temp_inkas-pay.pay-code            ), 0 ).
                run wp-xmltagput( 5, "sum",  string( p-is-out * temp_inkas-pay.tot-sum  ), 2 ).
                run wp-xmltagput( 5, "sumb", string( p-is-out * temp_inkas-pay.tot-base ), 2 ).
                run wp-xmltagput( 5, "sumr", string( p-is-out * temp_inkas-pay.tot-rubl ), 2 ).
                run wp-xmltagclose( 4, "payCode" ).
            end.
            run wp-xmltagclose( 3, "cassSum" ).
/*        end. */
    end.        /* available buf_sale-doc */
    else do:
        if p-ext-doc-type = {&TDEDT_Ras_Vnesh_Kass}
        or p-ext-doc-type = {&TDEDT_Vozvrat_Vnesh_Kass}
        then do:
            run wp-XMLWriteLog(
                  input v-bge-xml-log-file-name
                , input 1
                , input substitute( "*** ERR *** Не найден buf_inkas для документа расхода или возврата по кассе &1", p-doc-code )
            ).
        end.
    end.        /* NOT available buf_inkas */
end.
end procedure. /* export-pay-code */


/*==========================================================================*/
procedure export-price-doc-ot-tot :
define input parameter p-doc-code   as character        no-undo.
define input parameter p-sum-type   as character        no-undo.
define input parameter p-cat-id     as character        no-undo.

    define buffer buf_ot-tot        for ub.ot-tot.
do
for buf_ot-tot
on error undo, return error
:
    find first buf_ot-tot no-lock
         where buf_ot-tot.doc-code = p-doc-code
           and buf_ot-tot.sum-type = {&arh-crsa}
           and buf_ot-tot.cat-id   = p-cat-id
    no-error.
    if not available buf_ot-tot
    then do:
        run wp-XMLWriteLog in this-procedure (
              input v-bge-xml-log-file-name
            , input 1
            , input substitute( "В архиве не найдена запись документа переоценки &1 c sum-type = &2", p-doc-code, {&arh-crsa} )
        ).
    end.
    else do:
        if v-bge-xml-bgefmt = "dbf":U
        then do:
            run set-dbf-out-file-name in this-procedure (
                  input "hpss":U
                , input p-doc-code
            ).
        end.
        run wp-xmltagopen( 3, "saleSum","" ).
        run wp-xmltagput( 4, "sumr"      , string( buf_ot-tot.sum-rubl        ), 1 ).
        run wp-xmltagput( 4, "VATr"      , string( buf_ot-tot.vat-rubl        ), 2 ).
        run wp-xmltagput( 4, "SLTr"      , string( buf_ot-tot.slt-rubl        ), 2 ).
        run wp-xmltagput( 4, "roadTaxr"  , string( buf_ot-tot.road-tax-rubl   ), 2 ).
        run wp-xmltagput( 4, "transportr", string( buf_ot-tot.transport-rubl  ), 2 ).
        run wp-xmltagput( 4, "otherr"    , string( buf_ot-tot.other-rubl      ), 2 ).
        run wp-xmltagput( 4, "exciser"   , string( buf_ot-tot.excise-rubl     ), 2 ).
        run wp-xmltagput( 4, "sumb"      , string( buf_ot-tot.sum-base        ), 2 ).
        run wp-xmltagput( 4, "VATb"      , string( buf_ot-tot.vat-base        ), 2 ).
        run wp-xmltagput( 4, "SLTb"      , string( buf_ot-tot.slt-base        ), 2 ).
        run wp-xmltagput( 4, "roadTaxb"  , string( buf_ot-tot.road-tax-base   ), 2 ).
        run wp-xmltagput( 4, "transportb", string( buf_ot-tot.transport-base  ), 2 ).
        run wp-xmltagput( 4, "otherb"    , string( buf_ot-tot.other-base      ), 2 ).
        run wp-xmltagput( 4, "exciseb"   , string( buf_ot-tot.excise-base     ), 2 ).
        run wp-xmltagclose( 3, "saleSum" ).
    end.
end.
end procedure. /* export-price-doc-ot-tot */


/*==========================================================================*/
procedure export-trn-doc-ot-tot :
define input parameter p-doc-code                   as character        no-undo.
define input parameter p-sum-type                   as character        no-undo.
define input parameter p-cat-id                     as character        no-undo.
define input parameter p-fact-qnty                  as decimal          no-undo.
define input parameter p-ext-doc-type               as character        no-undo.
define input parameter p-pay-code                   as logical          no-undo.
define input-output parameter p-ot-tot-sale-exists  as logical          no-undo.
define input-output parameter p-ot-tot-cost-exists  as logical          no-undo.
define input-output parameter p-ot-tot-crsa-exists  as logical          no-undo.
define input parameter        p-is-envd_            as logical          no-undo.
define input parameter        p-sum-all-parts_      as decimal          no-undo.

    define variable v-ot-tot-sale-exists    as logical      no-undo.
    define variable v-ot-tot-cost-exists    as logical      no-undo.
    define variable v-ot-tot-crsa-exists    as logical      no-undo.

    define buffer buf_ot-tot        for ub.ot-tot.
do
for buf_ot-tot
on error undo, return error
:
    find first buf_ot-tot no-lock
         where buf_ot-tot.doc-code = p-doc-code
           and buf_ot-tot.sum-type = p-sum-type
           and buf_ot-tot.cat-id   = p-cat-id
    no-error.
    if not available buf_ot-tot
    then do:
        /* Проверок на наличие записи в архиве просто нет. Если нет - значит, так оно и должно быть. */
    end.        /* if not available buf_ot-tot */
    else do:
        case p-sum-type
        :
            when {&arh-sale}
            or when {&arh-sale-service}
            then do:
                assign
                    p-ot-tot-sale-exists = yes
                .
                if v-bge-xml-bgefmt = "dbf":U
                then do:
                    run set-dbf-out-file-name in this-procedure (
                          input "hdsm":U
                        , input p-doc-code
                    ).
                end.
                run wp-xmltagopen( 3, "docSum","" ).
                run wp-xmltagput( 4, "sumr"      , string( abs( buf_ot-tot.sum-rubl       ) ), 1 ).
                
                if p-is-envd_ eq NO then
                  run wp-xmltagput( 4, "VATr"    , string( abs( buf_ot-tot.vat-rubl       ) ), 2 ).  
                else
                  run wp-xmltagput( 4, "VATr"    , string( abs( p-sum-all-parts_          ) ), 2 ).  

                run wp-xmltagput( 4, "SLTr"      , string( abs( buf_ot-tot.slt-rubl       ) ), 2 ).
                run wp-xmltagput( 4, "roadTaxr"  , string( abs( buf_ot-tot.road-tax-rubl  ) ), 2 ).
                run wp-xmltagput( 4, "transportr", string( abs( buf_ot-tot.transport-rubl ) ), 2 ).
                run wp-xmltagput( 4, "otherr"    , string( abs( buf_ot-tot.other-rubl     ) ), 2 ).
                run wp-xmltagput( 4, "exciser"   , string( abs( buf_ot-tot.excise-rubl    ) ), 2 ).
                run wp-xmltagput( 4, "sumb"      , string( abs( buf_ot-tot.sum-base       ) ), 2 ).
                run wp-xmltagput( 4, "VATb"      , string( abs( buf_ot-tot.vat-base       ) ), 2 ).
                run wp-xmltagput( 4, "SLTb"      , string( abs( buf_ot-tot.slt-base       ) ), 2 ).
                run wp-xmltagput( 4, "roadTaxb"  , string( abs( buf_ot-tot.road-tax-base  ) ), 2 ).
                run wp-xmltagput( 4, "transportb", string( abs( buf_ot-tot.transport-base ) ), 2 ).
                run wp-xmltagput( 4, "otherb"    , string( abs( buf_ot-tot.other-base     ) ), 2 ).
                run wp-xmltagput( 4, "exciseb"   , string( abs( buf_ot-tot.excise-base    ) ), 2 ).
                run wp-xmltagclose( 3, "docSum" ).
            end.        /* when {&arh-sale-service} */
            when {&arh-cost}
            or when {&arh-cost-service}
            then do:
                assign
                    p-ot-tot-cost-exists = yes
                .
                if v-bge-xml-bgefmt = "dbf":U
                then do:
                    run set-dbf-out-file-name in this-procedure (
                          input "hcsm":U
                        , input p-doc-code
                    ).
                end.
                run wp-xmltagopen( 3, "costSum", "" ).
                run wp-xmltagput( 4, "sumr",        string( abs( buf_ot-tot.sum-rubl       ) ), 1 ).

                
                if p-is-envd_ eq NO then
                  run wp-xmltagput( 4, "VATr" ,     string( abs( buf_ot-tot.vat-rubl       ) ), 2 ). 
                else
                  run wp-xmltagput( 4, "VATr" ,     string( abs( p-sum-all-parts_          ) ), 2 ).  
                
                run wp-xmltagput( 4, "SLTr",        string( abs( buf_ot-tot.slt-rubl       ) ), 2 ).
                run wp-xmltagput( 4, "roadTaxr",    string( abs( buf_ot-tot.road-tax-rubl  ) ), 2 ).
                run wp-xmltagput( 4, "transportr",  string( abs( buf_ot-tot.transport-rubl ) ), 2 ).
                run wp-xmltagput( 4, "otherr",      string( abs( buf_ot-tot.other-rubl     ) ), 2 ).
                run wp-xmltagput( 4, "exciser",     string( abs( buf_ot-tot.excise-rubl    ) ), 2 ).
                run wp-xmltagput( 4, "sumb",        string( abs( buf_ot-tot.sum-base       ) ), 2 ).
                run wp-xmltagput( 4, "VATb",        string( abs( buf_ot-tot.vat-base       ) ), 2 ).
                run wp-xmltagput( 4, "SLTb",        string( abs( buf_ot-tot.slt-base       ) ), 2 ).
                run wp-xmltagput( 4, "roadTaxb",    string( abs( buf_ot-tot.road-tax-base  ) ), 2 ).
                run wp-xmltagput( 4, "transportb",  string( abs( buf_ot-tot.transport-base ) ), 2 ).
                run wp-xmltagput( 4, "otherb",      string( abs( buf_ot-tot.other-base     ) ), 2 ).
                run wp-xmltagput( 4, "exciseb",     string( abs( buf_ot-tot.excise-base    ) ), 2 ).
                run wp-xmltagclose( 3, "costSum" ).
                run fill-temp-cost-supp in this-procedure (
                    input p-doc-code
                ).
            end.        /* when {&arh-cost-service} */
            when {&arh-crsa}
            or when {&arh-crsa-service}
            then do:
                assign
                    p-ot-tot-crsa-exists = yes
                .
                if v-bge-xml-bgefmt = "dbf":U
                then do:
                    run set-dbf-out-file-name in this-procedure (
                          input "hssm":U
                        , input p-doc-code
                    ).
                end.
                run wp-xmltagopen( 3, "saleSum", "" ).
                run wp-xmltagput( 4, "sumr",         string( abs( buf_ot-tot.sum-rubl        ) ), 1 ).
                run wp-xmltagput( 4, "VATr",         string( abs( buf_ot-tot.vat-rubl        ) ), 2 ).
                run wp-xmltagput( 4, "SLTr",         string( abs( buf_ot-tot.slt-rubl        ) ), 2 ).
                run wp-xmltagput( 4, "roadTaxr",     string( abs( buf_ot-tot.road-tax-rubl   ) ), 2 ).
                run wp-xmltagput( 4, "transportr",   string( abs( buf_ot-tot.transport-rubl  ) ), 2 ).
                run wp-xmltagput( 4, "otherr",       string( abs( buf_ot-tot.other-rubl      ) ), 2 ).
                run wp-xmltagput( 4, "exciser",      string( abs( buf_ot-tot.excise-rubl     ) ), 2 ).
                run wp-xmltagput( 4, "sumb",         string( abs( buf_ot-tot.sum-base        ) ), 2 ).
                run wp-xmltagput( 4, "VATb",         string( abs( buf_ot-tot.vat-base        ) ), 2 ).
                run wp-xmltagput( 4, "SLTb",         string( abs( buf_ot-tot.slt-base        ) ), 2 ).
                run wp-xmltagput( 4, "roadTaxb",     string( abs( buf_ot-tot.road-tax-base   ) ), 2 ).
                run wp-xmltagput( 4, "transportb",   string( abs( buf_ot-tot.transport-base  ) ), 2 ).
                run wp-xmltagput( 4, "otherb",       string( abs( buf_ot-tot.other-base      ) ), 2 ).
                run wp-xmltagput( 4, "exciseb",      string( abs( buf_ot-tot.excise-base     ) ), 2 ).
                run wp-xmltagclose( 3, "saleSum" ).
                run fill-temp-cost-supp in this-procedure (
                    input p-doc-code
                ).
            end.        /* when {&arh-crsa-service} */
        end case.       /* case p-sum-type */
    end.        /* NOT ( if not available buf_ot-tot ) */
end.
end procedure. /* export-trn-doc-ot-tot */

/*==========================================================================*/
procedure fill-temp-cost-supp :
define input parameter p-doc-code   as character        no-undo.

    define buffer buf_cost_ot-supp-tot     for ub.ot-supp-tot.
    define buffer buf_sale_ot-supp-tot     for ub.ot-supp-tot.
    define buffer buf_cost_ot-supp-line    for ub.ot-supp-line.
    define buffer buf_sale_ot-supp-line    for ub.ot-supp-line.
do
on error undo, return error
:
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
            run fill_bge-xml_clients in this-procedure (
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
                run wp-XMLWriteLog(  v-bge-xml-log-file-name,
                                            1,
                                    "*** WRN: *** Найдено больше одной записи ot-supp-line для документа "
                                    + string( p-doc-code )
                ).
            end.
        end.        /* if buf_cost_ot-supp-line.sum-type = {&arh-cost} + {&arh-supp} */
    end.      /* for each buf_cost_ot-supp-line */
end.
end procedure. /* fill-temp-cost-supp */


/*==========================================================================*/
procedure export-ot-line :
define input parameter p-doc-code   as character        no-undo.
define input parameter p-artic      as character        no-undo.
define input parameter p-prod-type  as character        no-undo.
define input parameter p-prod-code  as integer          no-undo.
define input parameter p-sum-type   as character        no-undo.
define input parameter p-is-envd    as logical          no-undo.
define input parameter p-sum-line_  as decimal          no-undo.

    define buffer buf_ot-line       for ub.ot-line.
do
for buf_ot-line
on error undo, return error
:
    find first buf_ot-line no-lock
         where buf_ot-line.doc-code    = p-doc-code
           and buf_ot-line.artic       = p-artic
           and buf_ot-line.prod-type   = p-prod-type
           and buf_ot-line.prod-code   = p-prod-code
           and buf_ot-line.sum-type    = p-sum-type
           and buf_ot-line.sum-rubl    <> 0
    no-error.
    if available buf_ot-line
    then do:
        case p-sum-type
        :
            when {&arh-sale}
            or when {&arh-sale-service}
            then do:
                if v-bge-xml-bgefmt = "dbf":U
                then do:
                    run set-dbf-out-file-name in this-procedure (
                          input substitute( "ldsm&1_":U, p-artic )
                        , input p-doc-code
                    ).
                end.
                 
                      
                      
                      
                      
                run wp-xmltagopen( 4, "docSum", "" ).
                run wp-xmltagput( 5, "rateVAT",    string( entry( 1, buf_ot-line.cat-id ) ), 2 ).
                run wp-xmltagput( 5, "rateSLT",    string( entry( 2, buf_ot-line.cat-id ) ), 2 ).
                if p-ext-doc-type = {&TDEDT_Overturn}
                then do:
                        run wp-xmltagput( 5, "sumr",       string( buf_ot-line.sum-rubl         ), 1 ).
                        
                        if p-is-envd eq NO then
                          run wp-xmltagput( 5, "VATr",       string( buf_ot-line.vat-rubl       ), 2 ).
                        else
                          run wp-xmltagput( 5, "VATr",       string( p-sum-line_                ), 2 ).  
                        
                        run wp-xmltagput( 5, "SLTr",       string( buf_ot-line.slt-rubl         ), 2 ).
                        run wp-xmltagput( 5, "roadTaxr",   string( buf_ot-line.road-tax-rubl    ), 2 ).
                        run wp-xmltagput( 5, "transportr", string( buf_ot-line.transport-rubl   ), 2 ).
                        run wp-xmltagput( 5, "otherr",     string( buf_ot-line.other-rubl       ), 2 ).
                        run wp-xmltagput( 5, "exciser",    string( buf_ot-line.excise-rubl      ), 2 ).
                        run wp-xmltagput( 5, "sumb",       string( buf_ot-line.sum-base         ), 2 ).
                        run wp-xmltagput( 5, "VATb",       string( buf_ot-line.vat-base         ), 2 ).
                        run wp-xmltagput( 5, "SLTb",       string( buf_ot-line.slt-base         ), 2 ).
                        run wp-xmltagput( 5, "roadTaxb",   string( buf_ot-line.road-tax-base    ), 2 ).
                        run wp-xmltagput( 5, "transportb", string( buf_ot-line.transport-base   ), 2 ).
                        run wp-xmltagput( 5, "otherb",     string( buf_ot-line.other-base       ), 2 ).
                        run wp-xmltagput( 5, "exciseb",    string( buf_ot-line.excise-base      ), 2 ).
                end.      /* p-ext-doc-type = {&TDEDT_Overturn} */
                else do:
                        run wp-xmltagput( 5, "sumr",       string( abs( buf_ot-line.sum-rubl       ) ), 1 ).
                        
                        if p-is-envd eq NO then
                          run wp-xmltagput( 5, "VATr",       string( abs( buf_ot-line.vat-rubl     ) ), 2 ).
                        else
                          run wp-xmltagput( 5, "VATr",       string( abs( p-sum-line_              ) ), 2 ).  
                        
                        run wp-xmltagput( 5, "SLTr",       string( abs( buf_ot-line.slt-rubl       ) ), 2 ).
                        run wp-xmltagput( 5, "roadTaxr",   string( abs( buf_ot-line.road-tax-rubl  ) ), 2 ).
                        run wp-xmltagput( 5, "transportr", string( abs( buf_ot-line.transport-rubl ) ), 2 ).
                        run wp-xmltagput( 5, "otherr",     string( abs( buf_ot-line.other-rubl     ) ), 2 ).
                        run wp-xmltagput( 5, "exciser",    string( abs( buf_ot-line.excise-rubl    ) ), 2 ).
                        run wp-xmltagput( 5, "sumb",       string( abs( buf_ot-line.sum-base       ) ), 2 ).
                        run wp-xmltagput( 5, "VATb",       string( abs( buf_ot-line.vat-base       ) ), 2 ).
                        run wp-xmltagput( 5, "SLTb",       string( abs( buf_ot-line.slt-base       ) ), 2 ).
                        run wp-xmltagput( 5, "roadTaxb",   string( abs( buf_ot-line.road-tax-base  ) ), 2 ).
                        run wp-xmltagput( 5, "transportb", string( abs( buf_ot-line.transport-base ) ), 2 ).
                        run wp-xmltagput( 5, "otherb",     string( abs( buf_ot-line.other-base     ) ), 2 ).
                        run wp-xmltagput( 5, "exciseb",    string( abs( buf_ot-line.excise-base    ) ), 2 ).
                end.      /* NOT ( p-ext-doc-type = {&TDEDT_Overturn} ) */
                run wp-xmltagclose( 4, "docSum" ).
            end.        /* when {&arh-sale-service} */
            when {&arh-cost}
            or when {&arh-cost-service}
            then do:
                if v-bge-xml-bgefmt = "dbf":U
                then do:
                    run set-dbf-out-file-name in this-procedure (
                          input substitute( "lcsm&1_":U, buf_ot-line.artic )
                        , input p-doc-code
                    ).
                end.
                run wp-xmltagopen( 4, "costSum", "" ).
                run wp-xmltagput( 5, "sumr",       string( abs( buf_ot-line.sum-rubl       ) ), 1 ).
                
                if p-is-envd eq NO then
                  run wp-xmltagput( 5, "VATr",       string( abs( buf_ot-line.vat-rubl     ) ), 2 ).
                else
                  run wp-xmltagput( 5, "VATr",       string( abs( p-sum-line_              ) ), 2 ).    
                
                run wp-xmltagput( 5, "SLTr",       string( abs( buf_ot-line.slt-rubl       ) ), 2 ).
                run wp-xmltagput( 5, "roadTaxr",   string( abs( buf_ot-line.road-tax-rubl  ) ), 2 ).
                run wp-xmltagput( 5, "transportr", string( abs( buf_ot-line.transport-rubl ) ), 2 ).
                run wp-xmltagput( 5, "otherr",     string( abs( buf_ot-line.other-rubl     ) ), 2 ).
                run wp-xmltagput( 5, "exciser",    string( abs( buf_ot-line.excise-rubl    ) ), 2 ).
                run wp-xmltagput( 5, "sumb",       string( abs( buf_ot-line.sum-base       ) ), 2 ).
                run wp-xmltagput( 5, "VATb",       string( abs( buf_ot-line.vat-base       ) ), 2 ).
                run wp-xmltagput( 5, "SLTb",       string( abs( buf_ot-line.slt-base       ) ), 2 ).
                run wp-xmltagput( 5, "roadTaxb",   string( abs( buf_ot-line.road-tax-base  ) ), 2 ).
                run wp-xmltagput( 5, "transportb", string( abs( buf_ot-line.transport-base ) ), 2 ).
                run wp-xmltagput( 5, "otherb",     string( abs( buf_ot-line.other-base     ) ), 2 ).
                run wp-xmltagput( 5, "exciseb",    string( abs( buf_ot-line.excise-base    ) ), 2 ).
                run wp-xmltagclose( 4, "costSum" ).
            end.        /* when {&arh-cost-service} */
            when {&arh-crsa}
            or when {&arh-crsa-service}
            then do:
                if v-bge-xml-bgefmt = "dbf":U
                then do:
                    run set-dbf-out-file-name in this-procedure (
                          input substitute( "lssm&1_":U, buf_ot-line.artic )
                        , input p-doc-code
                    ).
                end.
                if p-ext-doc-type = {&TDEDT_Overturn}
                then do:
                    run wp-xmltagopen( 4, "saleSum", "" ).
                    run wp-xmltagput( 5, "sumr",       string( buf_ot-line.sum-rubl        ), 1 ).
                    run wp-xmltagput( 5, "VATr",       string( buf_ot-line.vat-rubl        ), 2 ).
                    run wp-xmltagput( 5, "SLTr",       string( buf_ot-line.slt-rubl        ), 2 ).
                    run wp-xmltagput( 5, "roadTaxr",   string( buf_ot-line.road-tax-rubl   ), 2 ).
                    run wp-xmltagput( 5, "transportr", string( buf_ot-line.transport-rubl  ), 2 ).
                    run wp-xmltagput( 5, "otherr",     string( buf_ot-line.other-rubl      ), 2 ).
                    run wp-xmltagput( 5, "exciser",    string( buf_ot-line.excise-rubl     ), 2 ).
                    run wp-xmltagput( 5, "sumb",       string( buf_ot-line.sum-base        ), 2 ).
                    run wp-xmltagput( 5, "VATb",       string( buf_ot-line.vat-base        ), 2 ).
                    run wp-xmltagput( 5, "SLTb",       string( buf_ot-line.slt-base        ), 2 ).
                    run wp-xmltagput( 5, "roadTaxb",   string( buf_ot-line.road-tax-base   ), 2 ).
                    run wp-xmltagput( 5, "transportb", string( buf_ot-line.transport-base  ), 2 ).
                    run wp-xmltagput( 5, "otherb",     string( buf_ot-line.other-base      ), 2 ).
                    run wp-xmltagput( 5, "exciseb",    string( buf_ot-line.excise-base     ), 2 ).
                    run wp-xmltagclose( 4, "saleSum" ).
                end.
                else do:
                    run wp-xmltagopen( 4, "saleSum", "" ).
                    run wp-xmltagput( 5, "sumr",       string( abs( buf_ot-line.sum-rubl       ) ), 1 ).
                    run wp-xmltagput( 5, "VATr",       string( abs( buf_ot-line.vat-rubl       ) ), 2 ).
                    run wp-xmltagput( 5, "SLTr",       string( abs( buf_ot-line.slt-rubl       ) ), 2 ).
                    run wp-xmltagput( 5, "roadTaxr",   string( abs( buf_ot-line.road-tax-rubl  ) ), 2 ).
                    run wp-xmltagput( 5, "transportr", string( abs( buf_ot-line.transport-rubl ) ), 2 ).
                    run wp-xmltagput( 5, "otherr",     string( abs( buf_ot-line.other-rubl     ) ), 2 ).
                    run wp-xmltagput( 5, "exciser",    string( abs( buf_ot-line.excise-rubl    ) ), 2 ).
                    run wp-xmltagput( 5, "sumb",       string( abs( buf_ot-line.sum-base       ) ), 2 ).
                    run wp-xmltagput( 5, "VATb",       string( abs( buf_ot-line.vat-base       ) ), 2 ).
                    run wp-xmltagput( 5, "SLTb",       string( abs( buf_ot-line.slt-base       ) ), 2 ).
                    run wp-xmltagput( 5, "roadTaxb",   string( abs( buf_ot-line.road-tax-base  ) ), 2 ).
                    run wp-xmltagput( 5, "transportb", string( abs( buf_ot-line.transport-base ) ), 2 ).
                    run wp-xmltagput( 5, "otherb",     string( abs( buf_ot-line.other-base     ) ), 2 ).
                    run wp-xmltagput( 5, "exciseb",    string( abs( buf_ot-line.excise-base    ) ), 2 ).
                    run wp-xmltagclose( 4, "saleSum" ).
                end.
            end.        /* when {&arh-crsa-service} */
        end case.       /* case p-sum-type */
    end.
end.
end procedure. /* export-ot-line */

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
procedure set-dbf-out-file-name :
define input parameter p-prefix     as character        no-undo.
define input parameter p-doc-code   as character        no-undo.

    define variable v-file-name    as character    no-undo.
do
on error undo, return error
:
    assign
        v-file-name = trim( p-doc-code )
    .
    if v-file-name = "":U
    then do:
        assign
            v-file-name = "noname":U
        .
    end.
    else do:
        assign
            v-file-name = replace( v-file-name, "*":U, "#":U )
        .
    end.
    assign
        p-prefix = replace( p-prefix, "*":U, "_":U )
    .
    assign
        p-prefix = replace( p-prefix, "/":U, "_":U )
    .
    assign
        p-prefix = replace( p-prefix, "\":U, "_":U )
    .
    assign
        p-prefix = replace( p-prefix, ":":U, "_":U )
    .
    assign
        p-prefix = replace( p-prefix, "?":U, "_":U )
    .
    assign
        p-prefix = replace( p-prefix, '"':U, "_":U )
    .
    assign
        p-prefix = replace( p-prefix, ">":U, "_":U )
    .
    assign
        p-prefix = replace( p-prefix, "<":U, "_":U )
    .
    assign
        p-prefix = replace( p-prefix, "|":U, "_":U )
    .
    assign
        v-bge-xml-dbf-file-name = substitute( "&1/&2&3.d":U
                                            , sOutFile
                                            , p-prefix
                                            , v-file-name
                                            )
    .
end.
end procedure. /* set-dbf-out-file-name */



/*==========================================================================*/
procedure get-doc-line-attr-character :
define input parameter p-doc-code               as character        no-undo.
define input parameter p-gds-code               as integer          no-undo.
define input parameter p-attr-code              as character        no-undo.
define output parameter p-attr-value-character  as character        no-undo.
define output parameter p-attr-exists           as logical          no-undo.

    define buffer buf_doc-line-attr for ub.doc-line-attr.
    define buffer buf_doc-attr for ub.doc-attr.
do
on error undo, return error
:

    find first buf_doc-attr no-lock
         where buf_doc-attr.doc-code    = p-doc-code
           and buf_doc-attr.attr-code   = p-attr-code
    no-error.

    case p-attr-code:
      when {&trdcattr-autoent} then do:
        assign
          p-attr-value-character = entry (1, buf_doc-attr.attr-value, ";")
        no-error.
        if error-status :error
        then do:
            assign
                p-attr-exists = no
            .
        end.
        else do:
            assign
                p-attr-exists = yes
            .
        end.
      end.
      /*when {&trdcattr-autoent} then do:
        assign
          p-attr-value-character = entry (2, buf_doc-attr.attr-value, ";")
        no-error.
        if error-status :error
        then do:
            assign
                p-attr-exists = no
            .
        end.
        else do:
            assign
                p-attr-exists = yes
            .
        end.
      end.*/
      when {&trdcattr-ptbobj} then do:
        assign
          p-attr-value-character = entry (1, buf_doc-attr.attr-value, ";")
        no-error.
        if error-status :error
        then do:
            assign
                p-attr-exists = no
            .
        end.
        else do:
            assign
                p-attr-exists = yes
            .
        end.
      end.
      /*when {&trdcattr-ptbobj} then do:
        assign
          p-attr-value-character = entry (2, buf_doc-attr.attr-value, ";")
        no-error.
        if error-status :error
        then do:
            assign
                p-attr-exists = no
            .
        end.
        else do:
            assign
                p-attr-exists = yes
            .
        end.
      end.*/
      when {&trdcattr-ptb-item-pour} or 
      when {&trdcattr-car-num} or
      when {&trdcattr-fio-driver} or
      when {&trdcattr-time-income}
      then do:
        assign
            p-attr-value-character = buf_doc-attr.attr-value
        no-error.
        if error-status :error
        then do:
            assign
                p-attr-exists = no
            .
        end.
        else do:
            assign
                p-attr-exists = yes
            .
        end.
      end.
      otherwise do:
        find first buf_doc-line-attr no-lock
             where buf_doc-line-attr.doc-code    = p-doc-code
               and buf_doc-line-attr.gds-code    = p-gds-code
               and buf_doc-line-attr.attr-code   = p-attr-code
        no-error.
        if available buf_doc-line-attr
        then do:
            assign
                p-attr-value-character = buf_doc-line-attr.attr-value
                p-attr-exists          = yes
            .
        end.
        else do:
            assign
                p-attr-exists          = no
            .
        end.        
      end.
    end case.

end.
end procedure. /* get-doc-line-attr-character */

/*==========================================================================*/
procedure get-doc-line-attr-integer :
define input parameter p-doc-code               as character        no-undo.
define input parameter p-gds-code               as integer          no-undo.
define input parameter p-attr-code              as character        no-undo.
define output parameter p-attr-value-integer    as integer          no-undo.
define output parameter p-attr-exists           as logical          no-undo.

    define buffer buf_doc-line-attr for ub.doc-line-attr.
    define buffer buf_doc-attr for ub.doc-attr.
do
on error undo, return error
:


    find first buf_doc-attr no-lock
         where buf_doc-attr.doc-code    = p-doc-code
           and buf_doc-attr.attr-code   = p-attr-code
    no-error.

    case p-attr-code:
      when {&trdcattr-autoent} then do:
        assign
          p-attr-value-integer = integer (entry (2, buf_doc-attr.attr-value, ";"))
        no-error.
        if error-status :error
        then do:
            assign
                p-attr-exists = no
            .
        end.
        else do:
            assign
                p-attr-exists = yes
            .
        end.
      end.
      when {&trdcattr-ptbobj} then do:
        assign
          p-attr-value-integer = integer (entry (2, buf_doc-attr.attr-value, ";"))
        no-error.
        if error-status :error
        then do:
            assign
                p-attr-exists = no
            .
        end.
        else do:
            assign
                p-attr-exists = yes
            .
        end.
      end.
      otherwise do:
        find first buf_doc-line-attr no-lock
             where buf_doc-line-attr.doc-code    = p-doc-code
               and buf_doc-line-attr.gds-code    = p-gds-code
               and buf_doc-line-attr.attr-code   = p-attr-code
        no-error.
        if available buf_doc-line-attr
        then do:
            assign
                p-attr-value-integer = integer (buf_doc-line-attr.attr-value)
            no-error.
          if error-status :error
          then do:
              assign
                  p-attr-exists = no
              .
          end.
          else do:
              assign
                  p-attr-exists = yes
              .
          end.
        end.
        else do:
            assign
                p-attr-exists          = no
            .
        end.        
      end.
    end case.

end.
end procedure. /* get-doc-line-attr-integer */


/*==========================================================================*/
procedure export-goods-pay-desk :
define input parameter p-gds-code   as integer          no-undo.
define input parameter p-gds-type   as character        no-undo.
define input parameter p-is-petrol  as logical          no-undo.
define input parameter p-is-pieces  as logical          no-undo.

    define variable v-found-paycode     as logical      no-undo.
    define variable v-found-paycard     as logical      no-undo.
do
on error undo, return error
:
    if p-pay-desk = yes
    then do:
        run wp-xmltagopen( 4, "goodPayDesk", "" ).
        if p-is-petrol = yes
        and p-is-pieces = no
        then do:        /*топливо - таблица treal-2*/
            for each treal-2
                where treal-2.gds-code = p-gds-code
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
                if treal-2.is-pay = no  then do:
                end.
                else do:
                    if treal-2.prefix = '':U then do:
                    /*суммирующая запись по всем префиксам*/
                    v-found-paycode = yes.
                    run wp-xmltagopen( 6, "payCode", "" ).
                    run wp-xmltagput( 7, "code", string( treal-2.cpay-code ), 0 ).
                    run wp-xmltagput( 7, "quantity", string( v-is-out * treal-2.qnty1 ), 3 ).
                        run wp-xmltagput( 7, "sumr", string( v-is-out * treal-2.netto-rubl ), 1 ).
                    run wp-xmltagput( 7, "sumb", string( v-is-out * treal-2.netto ), 1 ).
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
                    run wp-xmltagput( 9, "sumr", string( v-is-out * treal-2.netto-rubl ), 2 ).
                    run wp-xmltagput( 9, "sumb", string( v-is-out * treal-2.netto ), 2 ).
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
            case p-gds-type:
                when {&gds-goods}
                then do:        /*товары таблица treal-3*/
                    for each treal-3 no-lock
                        where treal-3.gds-code = p-gds-code
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
                            run wp-xmltagput( 7, "sumr", string( v-is-out * treal-3.netto-rubl ), 2 ).
                            run wp-xmltagput( 7, "sumb", string( v-is-out * treal-3.netto ), 2 ).
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
                            run wp-xmltagput( 9, "sumr", string( v-is-out * treal-3.netto-rubl ), 2 ).
                            run wp-xmltagput( 9, "sumb", string( v-is-out * treal-3.netto ), 2 ).
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
                        where treal-4.gds-code = p-gds-code
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
                            run wp-xmltagput( 7, "sumr", string( v-is-out * treal-4.netto-rubl ), 2 ).
                            run wp-xmltagput( 7, "sumb", string( v-is-out * treal-4.netto ), 2 ).
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
                            run wp-xmltagput( 9, "sumr", string( v-is-out * treal-4.netto-rubl ), 2 ).
                            run wp-xmltagput( 9, "sumb", string( v-is-out * treal-4.netto ), 2 ).
                            run wp-xmltagclose( 8, "payCard").
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
            end case.       /*case p-gds-type*/
        end.        /* не топливо */
        run wp-xmltagclose( 4, "goodPayDesk" ).
    end.        /* if p-pay-desk = yes */
    else do:
        run wp-xmltagopen( 4, "goodPayCode", "" ).
        if p-is-petrol = yes
        and p-is-pieces = no
        then do:        /*топливо - таблица treal-2*/
            for each treal-2 No-LOCK
            where treal-2.gds-code = p-gds-code
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
                    run wp-xmltagput( 6, "sumr", string( v-is-out * treal-2.netto-rubl ), 1 ).
                    run wp-xmltagput( 6, "sumb", string( v-is-out * treal-2.netto ), 1 ).
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
                    run wp-xmltagput( 8, "sumr", string( v-is-out * treal-2.netto-rubl ), 1 ).
                    run wp-xmltagput( 8, "sumb", string( v-is-out * treal-2.netto ), 1 ).
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
            end. /*for each treal-2 No-LOCK*/
        end.        /* топливо */
        else do:
            case p-gds-type:
                when {&gds-goods}
                then do:        /*товары таблица treal-3*/
                    for each treal-3 no-lock
                    where treal-3.gds-code = p-gds-code
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
                            run wp-xmltagput( 6, "sumr", string( v-is-out * treal-3.netto-rubl ), 2 ).
                            run wp-xmltagput( 6, "sumb", string( v-is-out * treal-3.netto ), 2 ).
                            end.
                            if treal-3.prefix <> '':U then do:
                            if not v-found-paycard then do:
                                run wp-xmltagopen( 6, "payCards", "" ).
                                v-found-paycard = yes.
                            end.
                            run wp-xmltagopen( 7, "payCard", "" ).
                            run wp-xmltagput( 8, "code", string( treal-3.prefix ), 0 ).
                            run wp-xmltagput( 8, "quantity", string( v-is-out * treal-3.qnty1 ), 3 ).
                            run wp-xmltagput( 8, "sumr", string( v-is-out * treal-3.netto-rubl ), 2 ).
                            run wp-xmltagput( 8, "sumb", string( v-is-out * treal-3.netto ), 2 ).
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
                    where treal-4.gds-code = p-gds-code
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
                            run wp-xmltagput( 6, "sumr", string( v-is-out * treal-4.netto-rubl ), 2 ).
                            run wp-xmltagput( 6, "sumb", string( v-is-out * treal-4.netto ), 2 ).
                            end.
                            if treal-4.prefix <> '':U then do:
                            if not v-found-paycard then do:
                                run wp-xmltagopen( 6, "payCards", "" ).
                                v-found-paycard = yes.
                            end.
                            run wp-xmltagopen( 7, "payCard","" ).
                            run wp-xmltagput( 8, "num", string( treal-4.prefix ), 0 ).
                            run wp-xmltagput( 8, "quantity", string( v-is-out * treal-4.qnty1 ), 3 ).
                            run wp-xmltagput( 8, "sumr", string( v-is-out * treal-4.netto-rubl ), 2 ).
                            run wp-xmltagput( 8, "sumb", string( v-is-out * treal-4.netto ), 2 ).
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
            end case.       /*case p-gds-type*/
        end.        /* не топливо */
        run wp-xmltagclose( 4, "goodPayCode" ).
    end.        /* NOT ( if p-pay-desk = yes ) */

end.
end procedure. /* export-goods-pay-desk */


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
        run wp-xmltagput( input 4, input "CHDoc"    , input string( buf_chk-doc.doc-num   )                              , input 2 ).
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
                      input p-parent-handle
                    , input buf_chk-doc.d-card
                ).
                run fill_bge-xml_clients in this-procedure (
                      input p-parent-handle
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
            run wp-xmltagput( input 5, input "pump"         , input string( buf_chk-gds.pump)           , input 2 ).
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
  end. /* bc-cycle: */end.
end procedure. /* export-bc-price */

/*==========================================================================*/
procedure calc-lines :
do
on error undo, return error
:
  define input parameter  p-doc-code      as character        no-undo.
  define output parameter p-sum-all-parts as decimal          no-undo.
                                                            
  DEFINE BUFFER t-doc FOR trn-doc.  
           
  define variable p-fact-qnty             as decimal      no-undo.
                                     
  find first t-doc no-lock
       where t-doc.doc-code   = p-doc-code
       no-error.
  if avail t-doc then         
       ASSIGN 
       p-sum-all-parts = vat-rubl .
       
end .         
end procedure.

