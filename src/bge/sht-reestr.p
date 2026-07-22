block-level on error undo, throw.
/*

$Revision: 19a7bcd6f844, 1625, rls $
$Author: SMMolotkov $
$Date: Tue Nov 06 04:41:39 2018 +0300 $
$Workfile: sht-reestr.p $
$Archive: bge/sht-reestr.p $

Экспорт отчёта-реестра документов выгрузки в Лексему

Автор: Молотков Сергей Михайлович
Дата создания: 26/03/18
Author: Molotkov Sergey
Creation date: 26/03/18

Input:

Output:

*/
define variable vss-revision    as character no-undo init "$Revision: 19a7bcd6f844, 1625, rls $":U .
define variable vss-author      as character no-undo init "$Author: SMMolotkov $":U .
define variable vss-date        as character no-undo init "$Date: Tue Nov 06 04:41:39 2018 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: sht-reestr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/sht-reestr.p $":U .
define variable vss-description as character no-undo init "Экспорт отчёта-реестра документов выгрузки в Лексему".
{cmp/vssrevis.i}

define input parameter p-obj-type   as character   no-undo.
define input parameter p-obj-code   as integer     no-undo.
define input parameter p-shift-date as date        no-undo.
define input parameter p-shift-num  as integer     no-undo.
define input parameter sOutFile     as character   no-undo.
define input parameter sLogFile     as character   no-undo.
define input parameter hEDT         as handle      no-undo.
define input parameter hCNT         as handle      no-undo.

{ cmp/str-glbl.i } /* &fact,&bef-TDEDT_... */
{ bge/bge-xml.i  } /* stmxmlout */
{ cmp/trg-def.i  }
{ str/in-vatp.i  def  buf_parts.  buf_trn-doc.  " "  loc }

/* Перечень документов с кодами операций, попадающих в отчет-реестр */
&scoped-define op-exp-list '{&bef-TDEDT_Pri_Vnesh},{&bef-TDEDT_Ras_Vnesh},{&bef-TDEDT_Ras_Vnesh_VP},~
{&bef-TDEDT_Ras_Vnesh_Kass},{&bef-TDEDT_Vozvrat_Vnesh},{&bef-TDEDT_Vozvrat_Vnesh_Kass},~
{&bef-TDEDT_Spi_Vnesh},{&bef-TDEDT_Inv},{&bef-TDEDT_Peresort},{&bef-TDEDT_Pri_Perem},{&bef-TDEDT_Ras_Perem},~
{&bef-TDEDT_Vozvrat_Perem},{&bef-TDEDT_Spi_Prvo},{&bef-TDEDT_Pri_Prvo},{&bef-TDEDT_Overturn},fbr':U

define variable v-store-name       as character no-undo .
define variable v-qnty-before      as decimal no-undo .
define variable v-qnty-after       as decimal no-undo .
define variable v-doc-sumr-before  as decimal no-undo .
define variable v-doc-sumr-after   as decimal no-undo .
define variable v-cost-sumr-before as decimal no-undo .
define variable v-cost-sumr-after  as decimal no-undo .
define variable v-cost-sumr        as decimal no-undo .
define buffer buf_trn-doc     for ub.trn-doc .
define buffer buf_doc-line    for ub.doc-line .
define buffer buf_parts       for ub.parts .
define buffer buf_trn-doc-sum for ub.trn-doc-sum .
define buffer buf_gds-dtl     for ub.gds-dtl .
define buffer buf_price-doc   for ub.price-doc .
define buffer buf_fbr-doc     for ub.fbr-doc .


do on error undo, return error :
  output stream stmxmlout to value( soutfile + "xm1" ) convert target "1251" append.
  run wp-XMLWriteCNT( hCNT, "" ).
  run wp-XMLWriteEDT( hEDT, 4, "Операция: Выгрузка отчёта-реестра документов." ).
  run wp-XMLWriteLog( sLogFile, 0, "&Line" ).
  run wp-XMLWriteLog( sLogFile, 1, "XML - Вывод операции: Выгрузка отчёта-реестра документов." ).

  /* 28/III-2018 тег objCode переименовать в store
                 выводить как в документах Идентификтор контрагента: <"орг"|"чел"|"скл"|"маг"><Номер> */
  v-store-name = substitute("&1&2", p-obj-type, p-obj-code).
      
  /* пройти все документы за смену */
  for each buf_trn-doc no-lock
     where buf_trn-doc.obj-type   = p-obj-type
       and buf_trn-doc.obj-code   = p-obj-code
       and buf_trn-doc.shift-date = p-shift-date
       and buf_trn-doc.shift-num  = p-shift-num  
       and buf_trn-doc.status_    = {&fact}
       and can-do ({&op-exp-list}, buf_trn-doc.ext-doc-type) = true
  :
    run wp-xmltagopen ( input 2, input "expDocument", input "" ).
    run wp-xmltagput( input 3, input "store",         input v-store-name,             input 0 ). /* Номер объекта */
    run wp-xmltagput( input 3, input "shiftNum",      input buf_trn-doc.shift-num,    input 0 ). /* Номер смены */
    run wp-xmltagput( input 3, input "shiftDate",     input string(buf_trn-doc.shift-date, "99.99.9999"), input 0 ). /* Дата смены */
    run wp-xmltagput( input 3, input "codeOperation", input buf_trn-doc.ext-doc-type, input 0 ). /* Код операции */
    run wp-xmltagput( input 3, input "factOrder"    , input string(buf_trn-doc.fact-order), input 0 ). /* Порядковый номер документа */
    run wp-xmltagput( input 3, input "dateDoc"      , input string(buf_trn-doc.doc-date,   "99.99.9999"), input 0 ). /* Дата документа */
    
    /* 28/III-2018 в тег referenceNo выводить Уникальный номер торговой операции (Код документа) пример: 21512-1м */
    run wp-xmltagput( input 3, input "referenceNo"  , input buf_trn-doc.doc-code,     input 0 ). /* Идентификатор контрагента */
    
    /* 29/III-2018 добавить тег <firm>, вытягивать код контрагента из документов ( по аналогии с выгрузкой документов) */
    run wp-xmltagput( input 3, input "firm",          input buf_trn-doc.cli-type + string( buf_trn-doc.cli-code ), input 0 ).
    
    /* 02/IV-2018 для расчёта учётной цены воспользоваться процедурой in-vat.p. Она по линиям возвращает всю структуру цен */
    v-cost-sumr = 0 .
    for each buf_doc-line no-lock
       where buf_doc-line.doc-code = buf_trn-doc.doc-code :
      for each buf_parts no-lock
         where buf_parts.out-code  = buf_doc-line.doc-code
           and buf_parts.obj-type  = buf_doc-line.obj-type
           and buf_parts.obj-code  = buf_doc-line.obj-code
           and buf_parts.artic     = buf_doc-line.artic
           and buf_parts.prod-type = buf_doc-line.prod-type
           and buf_parts.prod-code = buf_doc-line.prod-code :
        { str/in-vatp.i  calc-parts  buf_parts.  buf_trn-doc.  " "  loc }
        v-cost-sumr = v-cost-sumr + price-rubl-with-tax-locloc * buf_parts.fact-qnty .
      end . /* end_of for_each_parts */    
    end . /* end_of for_each_doc-line */    
    case buf_trn-doc.ext-doc-type :
      /* 28/III-2018 - для документов инвентаризации
                       теги количество (quantity), суммы в ценах по документу и учетных ценах разделить на теги _до и _после */
      /* 30/III-2018 - пересортицу выгружать так же, как инвентаризацию */
      when {&TDEDT_Inv} or
      when {&TDEDT_Peresort} then do :
        do: /* суммы _до и _после инвентаризации берутся из trn-doc-sum, как в doc-oper.p::ln2483 */
          find first buf_trn-doc-sum no-lock
               where buf_trn-doc-sum.doc-code = buf_trn-doc.doc-code
                 and buf_trn-doc-sum.sum-type = {&sum-before-doc}
            no-error.
          if available buf_trn-doc-sum then assign
            v-qnty-before      = buf_trn-doc-sum.fact-qnty
            v-doc-sumr-before  = buf_trn-doc-sum.crsa-sum-rubl
            v-cost-sumr-before = buf_trn-doc-sum.cost-sum-rubl
          .
          else assign
            v-qnty-before      = 0
            v-doc-sumr-before  = 0
            v-cost-sumr-before = 0
          .
          find first buf_trn-doc-sum no-lock
               where buf_trn-doc-sum.doc-code = buf_trn-doc.doc-code
                 and buf_trn-doc-sum.sum-type = {&sum-after-doc}
            no-error.
          if available buf_trn-doc-sum then assign
            v-qnty-after       = buf_trn-doc-sum.fact-qnty
            v-doc-sumr-after   = buf_trn-doc-sum.crsa-sum-rubl
            v-cost-sumr-after  = buf_trn-doc-sum.cost-sum-rubl
          .
          else assign
            v-qnty-after       = 0
            v-doc-sumr-after   = 0
            v-cost-sumr-after  = 0
          .
        end . /* end_of взятие сумм инвентаризации */
        /* 29/III-2018 Давай все-таки сделаем инвентаризацию как в выгрузке документов:
<beforeSum>
<qnty>
<DocSum_SumR>
<CostSum_SumR>
</beforeSum>

<afterSum>
<qnty>
<DocSum_SumR>
<CostSum_SumR>
</afterSum>
        */
        run wp-xmltagopen ( input 3, input "beforeSum", input "" ).
        run wp-xmltagput( input 4, input "qnty"         , input string(v-qnty-before),      input 0 ).
        run wp-xmltagput( input 4, input "DocSum_SumR"  , input string(v-doc-sumr-before),  input 0 ).
        run wp-xmltagput( input 4, input "CostSum_SumR" , input string(v-cost-sumr-before), input 0 ).
        run wp-xmltagclose( input 3, input "beforeSum" ).
        run wp-xmltagopen ( input 3, input "afterSum",  input "" ).
        run wp-xmltagput( input 4, input "qnty"         , input string(v-qnty-after),       input 0 ).
        run wp-xmltagput( input 4, input "DocSum_SumR"  , input string(v-doc-sumr-after),   input 0 ).
        run wp-xmltagput( input 4, input "CostSum_SumR" , input string(v-cost-sumr-after),  input 0 ).
        run wp-xmltagclose( input 3, input "afterSum" ).
      end . /* end_of when_TDEDT_Inv */
      /* 30/III-2018 - для документов "касса возврат" и "касса продажа" суммы выводить из полей, 
                       которые отображаются в экранной форме модуля str/docsuppn.w */  
      when {&TDEDT_Vozvrat_Vnesh_Kass} or
      when {&TDEDT_Ras_Vnesh_Kass} then do :
        run wp-xmltagput( input 3, input "quantity"     , input string(buf_trn-doc.fact-qnty), input 0 ).
        run wp-xmltagput( input 3, input "DocSum_SumR"  , input string(buf_trn-doc.tot-fact - buf_trn-doc.tot-calc),  input 0 ).
        /* 30/III-2018 - учётные суммы временно не выгружаем, пока не разберёмся - где у нас что
        v-cost-sumr = 0 .
        for each buf_gds-dtl no-lock
           where buf_gds-dtl.doc-code = buf_trn-doc.doc-code :
          v-cost-sumr = v-cost-sumr + buf_gds-dtl.price-rubl * buf_gds-dtl.fact-qnty .
        end . /* end_of for_each_buf_gds-dtl */
        */
        run wp-xmltagput( input 3, input "CostSum_SumR" , input string(v-cost-sumr),  input 0 ).
      end . /* end_of TDEDT_Vozvrat_Vnesh_Kass,TDEDT_Ras_Vnesh_Kass */
      otherwise do : 
        /* 29/III-2018 - в quantity выгружать количество факт, а не по документу (сделать как в выгрузке документов) */
        run wp-xmltagput( input 3, input "quantity"     , input string(buf_trn-doc.fact-qnty), input 0 ). /* Количество товара */
        run wp-xmltagput( input 3, input "DocSum_SumR"  , input string(buf_trn-doc.tot-doc),   input 0 ). /* Контрольная сумма в ценах по документу */
        /* 30/III-2018 - все суммы в учётных ценах выгружать из gds-dtl */
        /*
        v-cost-sumr = 0 .
        for each buf_gds-dtl no-lock
           where buf_gds-dtl.doc-code = buf_trn-doc.doc-code :
          v-cost-sumr = v-cost-sumr + buf_gds-dtl.price-rubl * buf_gds-dtl.fact-qnty .
        end . /* end_of for_each_buf_gds-dtl */
        */
        run wp-xmltagput( input 3, input "CostSum_SumR" , input string(v-cost-sumr),  input 0 ). /* Контрольная сумма в учетных ценах */
      end .
    end case .
    
    run wp-xmltagclose( input 2, input "expDocument" ).
  end . /* end_of for_each buf_trn-doc */
  
  /* {&TDEDT_Overturn} - переоценка лежит в отдельной таблице ub.price-doc */
  for each buf_price-doc no-lock
     where buf_price-doc.obj-type   = p-obj-type
       and buf_price-doc.obj-code   = p-obj-code
       and buf_price-doc.shift-date = p-shift-date
       and buf_price-doc.shift-num  = p-shift-num  
       and buf_price-doc.status_    = {&act-overvalue}
  :
    run wp-xmltagopen ( input 2, input "expDocument", input "" ).
    run wp-xmltagput( input 3, input "store",         input v-store-name,            input 0 ).
    run wp-xmltagput( input 3, input "shiftNum",      input buf_price-doc.shift-num, input 0 ).
    run wp-xmltagput( input 3, input "shiftDate",     input string(buf_price-doc.shift-date, "99.99.9999"), input 0 ).
    run wp-xmltagput( input 3, input "codeOperation", input {&TDEDT_Overturn},       input 0 ).
    run wp-xmltagput( input 3, input "factOrder"    , input string(buf_price-doc.fact-order), input 0 ).
    run wp-xmltagput( input 3, input "dateDoc"      , input string(buf_price-doc.doc-date,   "99.99.9999"), input 0 ).
    run wp-xmltagput( input 3, input "referenceNo"  , input buf_price-doc.doc-num,   input 0 ).
    /* run wp-xmltagput( input 3, input "firm",          input buf_trn-doc.cli-type + string( buf_trn-doc.cli-code ), input 0 ). */
    run wp-xmltagput( input 3, input "quantity"     , input string(buf_price-doc.rest-qnty), input 1 ).
    run wp-xmltagput( input 3, input "DocSum_SumR"  , input string(buf_price-doc.sale-base), input 1 ).
    run wp-xmltagclose( input 2, input "expDocument" ).
  end . /* end_of for_each buf_price-doc */

  /* fbr - производство бистро лежит в отдельной таблице ub.fbr-doc */
  /* 30/III-2018 - fbr не выгружаем; используем то, что выгрузится из trn-doc
  for each buf_fbr-doc no-lock
     where buf_fbr-doc.obj-type   = p-obj-type
       and buf_fbr-doc.obj-code   = p-obj-code
       and buf_fbr-doc.shift-date = p-shift-date
       and buf_fbr-doc.shift-num  = p-shift-num  
       and buf_fbr-doc.status_    = {&fact}
  :
    run wp-xmltagopen ( input 2, input "expDocument", input "" ).
    run wp-xmltagput( input 3, input "store",         input v-store-name,          input 0 ).
    run wp-xmltagput( input 3, input "shiftNum",      input buf_fbr-doc.shift-num, input 0 ).
    run wp-xmltagput( input 3, input "shiftDate",     input string(buf_fbr-doc.shift-date, "99.99.9999"), input 0 ).
    run wp-xmltagput( input 3, input "codeOperation", input 'fbr',                 input 0 ).
    run wp-xmltagput( input 3, input "dateDoc"      , input string(buf_fbr-doc.doc-date,   "99.99.9999"), input 0 ).
    run wp-xmltagput( input 3, input "referenceNo"  , input buf_fbr-doc.doc-code,   input 0 ).
    
    find first buf_trn-doc no-lock
         where buf_trn-doc.out-code = buf_fbr-doc.doc-code no-error.
    if available buf_trn-doc then
    run wp-xmltagput( input 3, input "firm",          input substitute("&1&2", buf_trn-doc.cli-type, buf_trn-doc.cli-code), input 0 ).
    
    run wp-xmltagput( input 3, input "quantity"     , input string(buf_fbr-doc.in-qnty), input 0 ).
    run wp-xmltagput( input 3, input "DocSum_SumR"  , input string(buf_fbr-doc.in-sale), input 0 ).
    run wp-xmltagput( input 3, input "CostSum_SumR" , input string(buf_fbr-doc.in-rubl), input 0 ).
    run wp-xmltagclose( input 2, input "expDocument" ).
  end . /* end_of for_each buf_fbr-doc */
  */

  /* 03/IX-2018 - В файл d_....xml попадают и удаленные документы с тегом isDel=yes,
                  А в файл реестра - нет. Про удаленные документы в ТЗ ничего нет.
     04/IX-2018 - Удалённые документы выгружать не нужно. В реестр выгружаются только активные документы.                
  */
  
  run wp-XMLWriteLog in this-procedure
  ( input sLogFile
  , input 1
  , input substitute( "Выгрузка отчёта-реестра документов в пакет &1 завершена."
                     , sOutFile
                    )
  ).
  output stream stmxmlout close.
end . /* end_of doe */
